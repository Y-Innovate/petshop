"""Shared helpers for the gen<Table>.py scripts of tables that relate other
tables and have no CODE/STATUS/NAME columns (storesuppl, animals, inventory,
pricesanddiscounts). genInitData.py does the same for stores, suppliers and
products, and this module reuses its helpers.

A generator module defines:
    TABLENAME  env/CSV name, e.g. 'animals' (ANIMALS_TBNAME, data/animals.csv)
    SCRIPT     script name for the generated header
    FIELDS     [Field(...)] CSV columns, without createdBy/updatedBy
    KEY        CSV columns that must be unique together
    LOOKUPS    tables used in build(), e.g. ['stores', 'suppliers']
    build(row, tables) -> (comment, columns, values, froms, wheres)
               columns/values exclude the audit columns; froms are
               (env table name, alias) pairs for INSERT ... SELECT lookups
    check(rows, where) optional extra validation, may warn or raise

Foreign keys are identity values, so rows refer to other tables by their
codes (or, for animals, by store, type, race and name) and the INSERT looks
the IDs up with INSERT ... SELECT. If a lookup finds nothing, that INSERT
inserts nothing (SQLCODE +100).
"""
import csv
import random
import re
import sys
from datetime import datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path

from genInitData import (DATADIR, DEFAULT_USER, IND, MAXCOL, columnList,
                         db2Timestamp, knownCodes, loadProfile, parseArgs,
                         recentTimestamps, resolve, sqlLiteral, tableName)

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
TIMESTAMP_RE = re.compile(r"^\d{4}-\d{2}-\d{2}-\d{2}\.\d{2}\.\d{2}\.\d{6}$")


class Field:
    """kind: 'text' (maxlen), 'int' (minimum), 'dec' (DECIMAL(9,2)),
    'from'/'to' (timestamp; a date becomes start/end of that day)."""

    def __init__(self, name, kind="text", required=True, maxlen=8, minimum=None):
        self.name, self.kind, self.required = name, kind, required
        self.maxlen, self.minimum = maxlen, minimum

    def convert(self, value, where):
        if value == "":
            if self.required:
                raise ValueError(f"{where}: {self.name} is empty")
            return None
        if self.kind == "text":
            if len(value) > self.maxlen:
                raise ValueError(f"{where}: {self.name} '{value}' longer than {self.maxlen}")
            return value
        if self.kind == "int":
            if not re.fullmatch(r"-?\d+", value):
                raise ValueError(f"{where}: {self.name} '{value}' is not an integer")
            if self.minimum is not None and int(value) < self.minimum:
                raise ValueError(f"{where}: {self.name} {value} is below {self.minimum}")
            return int(value)
        if self.kind == "dec":
            try:
                dec = Decimal(value)
            except InvalidOperation:
                raise ValueError(f"{where}: {self.name} '{value}' is not a number")
            if dec != dec.quantize(Decimal("0.01")) or abs(dec) >= Decimal("10000000"):
                raise ValueError(f"{where}: {self.name} {value} does not fit DECIMAL(9,2)")
            return dec
        if self.kind in ("from", "to"):
            if TIMESTAMP_RE.match(value):
                return value
            if DATE_RE.match(value):
                return value + ("-23.59.59.999999" if self.kind == "to" else "-00.00.00.000000")
            raise ValueError(f"{where}: {self.name} '{value}' is not a date or DB2 timestamp")
        raise ValueError(f"unknown kind {self.kind}")


def lit(value):
    """SQL literal for a converted CSV value."""
    if value is None:
        return "NULL"
    if isinstance(value, (int, Decimal)):
        return str(value)
    if TIMESTAMP_RE.match(value):
        return f"'{value}'"
    return sqlLiteral(value)


def readRows(mod, inputfile):
    rows = []
    with open(inputfile, "r", newline="", encoding="utf-8") as infile:
        for lineno, line in enumerate(csv.DictReader(infile), start=2):
            where = f"{inputfile} line {lineno}"
            row = {f.name: f.convert((line.get(f.name) or "").strip(), where)
                   for f in mod.FIELDS}
            row["createdBy"] = (line.get("createdBy") or "").strip() or DEFAULT_USER
            row["updatedBy"] = (line.get("updatedBy") or "").strip() or row["createdBy"]
            for field in ("createdBy", "updatedBy"):
                if len(row[field]) > 8:
                    raise ValueError(f"{where}: {field} '{row[field]}' longer than 8")
            row["lineno"] = lineno
            rows.append(row)

    keys = [tuple(r[k] for k in mod.KEY) for r in rows]
    dups = sorted({k for k in keys if keys.count(k) > 1}, key=str)
    if dups:
        raise ValueError(f"{inputfile}: duplicate {'/'.join(mod.KEY)} "
                         f"{', '.join('/'.join(map(str, k)) for k in dups)}")

    if hasattr(mod, "check"):
        mod.check(rows, str(inputfile))
    return rows


def warnUnknown(rows, where, field, tablename, prefix):
    """Warn only: the code may exist in DB2 without being in the CSV."""
    known = knownCodes(tablename, prefix)
    if known is None:
        return
    for row in rows:
        if row[field] is not None and row[field] not in known:
            print(f"Warning: {where} line {row['lineno']}: {field} '{row[field]}' "
                  f"not in data/{tablename}.csv", file=sys.stderr)


def csvRows(tablename):
    """Raw rows of data/<tablename>.csv, or [] when there is no such file."""
    datafile = DATADIR / f"{tablename}.csv"
    if not datafile.exists():
        return []
    with open(datafile, "r", newline="", encoding="utf-8") as infile:
        return [{k: (v or "").strip() for k, v in r.items()} for r in csv.DictReader(infile)]


def insertStatement(mod, tables, row, created, updated):
    comment, columns, values, froms, wheres = mod.build(row, tables)
    # DB2 does not allow an untyped NULL in a SELECT list, so leave NULL
    # columns out: they are all nullable without default and become NULL
    pairs = [(c, v) for c, v in zip(columns, values) if v != "NULL"]
    columns, values = [c for c, _ in pairs], [v for _, v in pairs]
    columns = columns + ["CREATEDBY", "CREATEDDATE", "UPDATEDBY", "UPDATEDDATE"]
    values = values + [sqlLiteral(row["createdBy"]), f"'{db2Timestamp(created)}'",
                       sqlLiteral(row["updatedBy"]), f"'{db2Timestamp(updated)}'"]
    sep = "," + "\n" + IND
    stmt = (f"   INSERT INTO {tables[mod.TABLENAME]}\n"
            f"{columnList(columns)}\n")
    if not froms:
        return comment, stmt + f"      VALUES\n       ({sep.join(values)});\n"
    return comment, stmt + (
        f"      SELECT\n"
        f"{IND}{sep.join(values)}\n"
        f"      FROM {(',' + chr(10) + '           ').join(f'{tables[t]} {a}' for t, a in froms)}\n"
        f"      WHERE {(chr(10) + '        AND ').join(wheres)};\n")


def tablesFor(mod, prfl):
    return {t: tableName(t, prfl) for t in [mod.TABLENAME] + list(mod.LOOKUPS)}


def statements(mod, prfl, rows, now, days):
    """Comment + INSERT lines for all rows of a generator module."""
    tables = tablesFor(mod, prfl)
    lines = []
    for row in rows:
        created, updated = recentTimestamps(now, days)
        comment, stmt = insertStatement(mod, tables, row, created, updated)
        lines += [f"-- {comment}", stmt]
    return lines


def finish(lines, output, what):
    sql = "\n".join(lines) + "\n"
    toolong = [l for l in sql.splitlines() if len(l) > MAXCOL]
    if toolong:
        raise ValueError(f"line longer than {MAXCOL} columns: {toolong[0]}")
    if output:
        with open(output, "w", encoding="utf-8") as outfile:
            outfile.write(sql)
        print(f"Wrote {what} to {output}", file=sys.stderr)
    else:
        sys.stdout.write(sql)


def main(mod):
    args = parseArgs(mod.TABLENAME, mod.SCRIPT)
    if args.seed is not None:
        random.seed(args.seed)

    prfl = loadProfile(args.env)
    table = tableName(mod.TABLENAME, prfl)
    rows = readRows(mod, args.input)
    now = datetime.now()

    lines = [f"-- Initial data for {mod.TABLENAME} table {table}.",
             f"-- Generated by {mod.SCRIPT} on {now:%Y-%m-%d %H:%M:%S}",
             f"-- from {Path(args.input).name}, {len(rows)} rows.",
             "",
             "-- Set SQLID",
             f"   SET CURRENT SQLID='{resolve('{{SQLID}}', prfl)}';",
             ""]
    if args.replace:
        lines += ["-- Remove existing rows",
                  f"   DELETE FROM {table};",
                  ""]
    lines += statements(mod, prfl, rows, now, args.days)
    lines.append("   COMMIT;")
    finish(lines, args.output, f"{len(rows)} {mod.TABLENAME}")
