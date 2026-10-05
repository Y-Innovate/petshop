"""Generate DB2 INSERT statements with initial data for a petshop table.

Shared by the gen<Table>.py scripts for tables with the layout
    <X>ID, <X>CODE, <X>STATUS, <X>NAME, <X>NAMEU,
    [extra text columns], [foreign key IDs],
    CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE
(stores AA000005.sql, suppliers AA000006.sql, products AA000007.sql).

The data (code, status, name, extra columns, created/updated by) is read
from a CSV input file. CREATEDDATE and UPDATEDDATE are generated on every
run, so they are always recent: CREATEDDATE is a random moment within the
last --days days and UPDATEDDATE lies between CREATEDDATE and now.

<X>ID is GENERATED ALWAYS AS IDENTITY and is therefore not inserted.
<X>NAMEU is derived from <X>NAME (upper case), like the API does.

Foreign keys (e.g. SUPPLIERID in products) are identity values, so the CSV
refers to the other table by its code (supplierCode) and the INSERT looks
up the ID with INSERT ... SELECT ... WHERE SUPPLIERCODE = '...'. If the
code does not exist in DB2, that INSERT inserts nothing (SQLCODE +100).

The output is DSNTEP2 input (SQL in columns 1-72), with the {{...}} names
resolved from an envs/*.yaml profile, like profileUSS.py does.
"""
import argparse
import csv
import random
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path

import yaml

SCRIPTDIR = Path(__file__).resolve().parent
DATADIR = SCRIPTDIR / "data"

MAXCOL = 72
DEFAULT_USER = "INITLOAD"
IND = "        "


def parseArgs(tablename, script):
    parser = argparse.ArgumentParser(
        prog=script,
        description=f"Generate INSERT statements for the {tablename} table")
    parser.add_argument("-i", "--input", default=DATADIR / f"{tablename}.csv",
                        help=f"CSV input file (default: data/{tablename}.csv)")
    parser.add_argument("-e", "--env", default=SCRIPTDIR.parent / "envs" / "dev1.yaml",
                        help="environment profile (default: envs/dev1.yaml)")
    parser.add_argument("-o", "--output",
                        help="output SQL file (default: stdout)")
    parser.add_argument("--days", type=int, default=30,
                        help="created dates lie within the last DAYS days (default: 30)")
    parser.add_argument("--replace", action="store_true",
                        help="delete all existing rows before inserting")
    parser.add_argument("--seed", type=int,
                        help="random seed, for reproducible timestamps")
    return parser.parse_args()


def loadProfile(envfile):
    with open(envfile, "r") as prfl:
        return yaml.safe_load(prfl)


def resolve(text, prfl):
    # Repeat, because profile values refer to other values (PET{{DB}})
    for _ in range(10):
        new = re.sub(r"\{\{\s*(\w+)\s*\}\}", lambda m: str(prfl[m.group(1)]), text)
        if new == text:
            return new
        text = new
    raise ValueError(f"cannot resolve {text}")


def tableName(tablename, prfl):
    return resolve(f"{{{{SCHEMA}}}}.{{{{{tablename.upper()}_TBNAME}}}}", prfl)


def maxLengths(prefix, extras, lookups):
    # Max lengths according to the DDL and the openapi spec
    maxlen = {
        f"{prefix}Code": 8,
        f"{prefix}Status": 8,
        f"{prefix}Name": 255,
    }
    maxlen.update(extras)
    for _, lkprefix in lookups:
        maxlen[f"{lkprefix}Code"] = 8
    maxlen["createdBy"] = 8
    maxlen["updatedBy"] = 8
    return maxlen


def knownCodes(tablename, prefix):
    """Codes in data/<tablename>.csv, or None when there is no such file."""
    datafile = DATADIR / f"{tablename}.csv"
    if not datafile.exists():
        return None
    with open(datafile, "r", newline="", encoding="utf-8") as infile:
        return {(r.get(f"{prefix}Code") or "").strip() for r in csv.DictReader(infile)}


def readRows(inputfile, prefix, extras, lookups):
    maxlen = maxLengths(prefix, extras, lookups)
    rows = []

    with open(inputfile, "r", newline="", encoding="utf-8") as infile:
        for lineno, line in enumerate(csv.DictReader(infile), start=2):
            row = {k: (line.get(k) or "").strip() for k in maxlen}

            if not row["createdBy"]:
                row["createdBy"] = DEFAULT_USER
            if not row["updatedBy"]:
                row["updatedBy"] = row["createdBy"]

            for field, length in maxlen.items():
                if not row[field]:
                    raise ValueError(f"{inputfile} line {lineno}: {field} is empty")
                if len(row[field]) > length:
                    raise ValueError(f"{inputfile} line {lineno}: {field} "
                                     f"'{row[field]}' longer than {length}")

            row["lineno"] = lineno
            rows.append(row)

    codes = [r[f"{prefix}Code"] for r in rows]
    dups = sorted({c for c in codes if codes.count(c) > 1})
    if dups:
        raise ValueError(f"{inputfile}: duplicate {prefix}Code {', '.join(dups)}")

    # Warn only: the code may exist in DB2 without being in the CSV
    for lktable, lkprefix in lookups:
        known = knownCodes(lktable, lkprefix)
        if known is None:
            continue
        for row in rows:
            if row[f"{lkprefix}Code"] not in known:
                print(f"Warning: {inputfile} line {row['lineno']}: "
                      f"{lkprefix}Code '{row[f'{lkprefix}Code']}' "
                      f"not in data/{lktable}.csv", file=sys.stderr)

    return rows


def recentTimestamps(now, days):
    created = now - timedelta(seconds=random.uniform(0, days * 86400))
    updated = created + (now - created) * random.random()
    return created, updated


def db2Timestamp(ts):
    return ts.strftime("%Y-%m-%d-%H.%M.%S.%f")


def sqlLiteral(value, indent=IND):
    """Return a quoted SQL string, split with || when it would pass MAXCOL."""
    width = MAXCOL - len(indent) - 6
    chunks = [""]
    for char in value:
        esc = "''" if char == "'" else char
        if len(chunks[-1]) + len(esc) > width:
            chunks.append("")
        chunks[-1] += esc
    return f"\n{indent}|| ".join(f"'{c}'" for c in chunks)


def columnList(columns):
    """Return '(COL1, COL2, ...)' wrapped to fit MAXCOL."""
    lines = ["      ("]
    for i, col in enumerate(columns):
        item = col + (", " if i < len(columns) - 1 else ")")
        if len(lines[-1]) + len(item.rstrip()) > MAXCOL:
            lines[-1] = lines[-1].rstrip()
            lines.append("       ")
        lines[-1] += item
    return "\n".join(lines)


def insertStatement(table, prefix, extras, lookups, lktables, row, created, updated):
    col = prefix.upper()
    columns = [f"{col}CODE", f"{col}STATUS", f"{col}NAME", f"{col}NAMEU"]
    values = [
        sqlLiteral(row[f"{prefix}Code"]),
        sqlLiteral(row[f"{prefix}Status"]),
        sqlLiteral(row[f"{prefix}Name"]),
        sqlLiteral(row[f"{prefix}Name"].upper()),
    ]

    for field in extras:
        columns.append(field.upper())
        values.append(sqlLiteral(row[field]))

    for n, (_, lkprefix) in enumerate(lookups, start=1):
        columns.append(f"{lkprefix.upper()}ID")
        values.append(f"L{n}.{lkprefix.upper()}ID")

    columns += ["CREATEDBY", "CREATEDDATE", "UPDATEDBY", "UPDATEDDATE"]
    values += [
        sqlLiteral(row["createdBy"]),
        f"'{db2Timestamp(created)}'",
        sqlLiteral(row["updatedBy"]),
        f"'{db2Timestamp(updated)}'",
    ]

    sep = "," + "\n" + IND
    stmt = (f"   INSERT INTO {table}\n"
            f"{columnList(columns)}\n")

    if not lookups:
        return stmt + (f"      VALUES\n"
                       f"       ({sep.join(values)});\n")

    froms = [f"{lktables[n - 1]} L{n}" for n in range(1, len(lookups) + 1)]
    wheres = [f"L{n}.{lkprefix.upper()}CODE = {sqlLiteral(row[f'{lkprefix}Code'])}"
              for n, (_, lkprefix) in enumerate(lookups, start=1)]
    return stmt + (f"      SELECT\n"
                   f"{IND}{sep.join(values)}\n"
                   f"      FROM {(',' + chr(10) + '           ').join(froms)}\n"
                   f"      WHERE {(chr(10) + '        AND ').join(wheres)};\n")


def main(tablename, prefix, script, extras=None, lookups=()):
    """tablename: e.g. 'stores' (env key STORES_TBNAME, data/stores.csv)
    prefix:    e.g. 'store' (CSV columns storeCode, ..., DB2 STORECODE, ...)
    extras:    {csvField: maxlen} of extra text columns, e.g. {'groupCode': 8}
               (DB2 column = csvField in upper case)
    lookups:   [(tablename, prefix)] of foreign keys, e.g.
               [('suppliers', 'supplier')]: CSV column supplierCode,
               DB2 column SUPPLIERID looked up via SUPPLIERCODE
    """
    extras = extras or {}
    args = parseArgs(tablename, script)

    if args.seed is not None:
        random.seed(args.seed)

    prfl = loadProfile(args.env)
    table = tableName(tablename, prfl)
    lktables = [tableName(lktable, prfl) for lktable, _ in lookups]
    sqlid = resolve("{{SQLID}}", prfl)
    rows = readRows(args.input, prefix, extras, lookups)
    now = datetime.now()

    lines = [f"-- Initial data for {tablename} table {table}.",
             f"-- Generated by {script} on {now:%Y-%m-%d %H:%M:%S}",
             f"-- from {Path(args.input).name}, {len(rows)} rows.",
             "",
             "-- Set SQLID",
             f"   SET CURRENT SQLID='{sqlid}';",
             ""]

    if args.replace:
        lines += ["-- Remove existing rows",
                  f"   DELETE FROM {table};",
                  ""]

    for row in rows:
        created, updated = recentTimestamps(now, args.days)
        lines.append(f"-- {prefix.capitalize()} {row[f'{prefix}Code']}")
        lines.append(insertStatement(table, prefix, extras, lookups, lktables,
                                     row, created, updated))

    lines.append("   COMMIT;")
    sql = "\n".join(lines) + "\n"

    toolong = [l for l in sql.splitlines() if len(l) > MAXCOL]
    if toolong:
        raise ValueError(f"line longer than {MAXCOL} columns: {toolong[0]}")

    if args.output:
        with open(args.output, "w", encoding="utf-8") as outfile:
            outfile.write(sql)
        print(f"Wrote {len(rows)} {tablename} to {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(sql)
