"""Generate DB2 INSERT statements with initial data for the reftables table
(AA000004.sql). See genRelData.py for details.

The CSV columns are
    tableID, tableKey, tableValue, createdBy, updatedBy
tableValue (the description) is optional, NULL when empty.

The CICS screen programs check these reference tables:
    STORSTAT  store status          (PETC903)
    SUPPSTAT  supplier status       (PETC904)
    PRODSTAT  product status        (PETC905)
    PRODGRCD  product group code    (PETC905)
    ANMLTYPE  animal type           (PETC907)
    ANMLRACE  animal race           (PETC907)
A warning is given for every value used in the other data/*.csv files that
is missing from its reference table.

Usage:
    python genRefTables.py [-i data/reftables.csv] [-e ../envs/dev1.yaml]
                           [-o reftables.sql] [--days 30] [--replace]
"""
import sys

import genRelData
from genRelData import Field, csvRows, lit

TABLENAME = "reftables"
SCRIPT = "genRefTables.py"
FIELDS = [Field("tableID"), Field("tableKey"),
          Field("tableValue", required=False, maxlen=255)]
KEY = ["tableID", "tableKey"]
LOOKUPS = []

# Reference table ID -> (data/<csv>.csv, column) whose values it must contain
USEDBY = {"STORSTAT": ("stores", "storeStatus"),
          "SUPPSTAT": ("suppliers", "supplierStatus"),
          "PRODSTAT": ("products", "productStatus"),
          "PRODGRCD": ("products", "groupCode"),
          "ANMLTYPE": ("animals", "animalType"),
          "ANMLRACE": ("animals", "animalRace")}


def check(rows, where):
    keys = {(r["tableID"], r["tableKey"]) for r in rows}
    for tableID, (csvname, column) in USEDBY.items():
        for value in sorted({r.get(column, "") for r in csvRows(csvname)} - {""}):
            if (tableID, value) not in keys:
                print(f"Warning: {where}: {column} '{value}' in data/{csvname}.csv "
                      f"has no {tableID} entry", file=sys.stderr)


def build(row, tables):
    return (f"{row['tableID']} {row['tableKey']}",
            ["TABLEID", "TABKEY", "TABVALUE"],
            [lit(row["tableID"]), lit(row["tableKey"]), lit(row["tableValue"])],
            [], [])


if __name__ == "__main__":
    genRelData.main(sys.modules[__name__])
