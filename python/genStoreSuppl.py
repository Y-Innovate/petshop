"""Generate DB2 INSERT statements with initial data for the storesuppl table
(AA000016.sql), the relationship between stores and suppliers.
See genRelData.py for details.

The CSV columns are
    storeCode, supplierCode, fromDate, toDate, createdBy, updatedBy
STOREID and SUPPLIERID are looked up via STORECODE and SUPPLIERCODE, so load
the stores (genStores.py) and the suppliers (genSuppliers.py) first.

fromDate and toDate are optional (NULL when empty) and are either a DB2
timestamp (2026-01-01-00.00.00.000000) or a date (2026-01-01). A fromDate
date becomes the start of that day, a toDate date the end of that day.

Usage:
    python genStoreSuppl.py [-i data/storesuppl.csv] [-e ../envs/dev1.yaml]
                            [-o storesuppl.sql] [--days 30] [--replace]
"""
import sys

import genRelData
from genRelData import Field, lit, sqlLiteral, warnUnknown

TABLENAME = "storesuppl"
SCRIPT = "genStoreSuppl.py"
FIELDS = [Field("storeCode"), Field("supplierCode"),
          Field("fromDate", "from", required=False),
          Field("toDate", "to", required=False)]
KEY = ["storeCode", "supplierCode"]
LOOKUPS = ["stores", "suppliers"]


def check(rows, where):
    for row in rows:
        if row["fromDate"] and row["toDate"] and row["toDate"] < row["fromDate"]:
            raise ValueError(f"{where} line {row['lineno']}: toDate before fromDate")
    warnUnknown(rows, where, "storeCode", "stores", "store")
    warnUnknown(rows, where, "supplierCode", "suppliers", "supplier")


def build(row, tables):
    return (f"Store {row['storeCode']} supplier {row['supplierCode']}",
            ["STOREID", "SUPPLIERID", "FROMDATE", "TODATE"],
            ["L1.STOREID", "L2.SUPPLIERID", lit(row["fromDate"]), lit(row["toDate"])],
            [("stores", "L1"), ("suppliers", "L2")],
            [f"L1.STORECODE = {sqlLiteral(row['storeCode'])}",
             f"L2.SUPPLIERCODE = {sqlLiteral(row['supplierCode'])}"])


if __name__ == "__main__":
    genRelData.main(sys.modules[__name__])
