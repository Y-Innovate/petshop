"""Generate DB2 INSERT statements with initial data for the inventory table
(AA000008.sql). See genRelData.py for details.

The CSV columns are
    storeCode, productCode, sellByDate, inStock, createdBy, updatedBy
STOREID and PRODUCTID are looked up via STORECODE and PRODUCTCODE, so load
the stores and products first. sellByDate is a DB2 timestamp or a date (the
end of that day). A product may be in stock more than once per store, with
different sell-by dates. A warning is given when the product's supplier is
not connected to the store in data/storesuppl.csv.

Usage:
    python genInventory.py [-i data/inventory.csv] [-e ../envs/dev1.yaml]
                           [-o inventory.sql] [--days 30] [--replace]
"""
import sys

import genRelData
from genRelData import Field, csvRows, lit, sqlLiteral, warnUnknown

TABLENAME = "inventory"
SCRIPT = "genInventory.py"
FIELDS = [Field("storeCode"), Field("productCode"), Field("sellByDate", "to"),
          Field("inStock", "int", minimum=0)]
KEY = ["storeCode", "productCode", "sellByDate"]
LOOKUPS = ["stores", "products"]


def check(rows, where):
    warnUnknown(rows, where, "storeCode", "stores", "store")
    warnUnknown(rows, where, "productCode", "products", "product")
    supplierOf = {r["productCode"]: r["supplierCode"] for r in csvRows("products")}
    links = {(r["storeCode"], r["supplierCode"]) for r in csvRows("storesuppl")}
    if links:
        for row in rows:
            supplier = supplierOf.get(row["productCode"])
            if supplier and (row["storeCode"], supplier) not in links:
                print(f"Warning: {where} line {row['lineno']}: supplier {supplier} of "
                      f"product {row['productCode']} is not connected to store "
                      f"{row['storeCode']} in data/storesuppl.csv", file=sys.stderr)


def build(row, tables):
    return (f"Store {row['storeCode']} product {row['productCode']}"
            f" sell by {row['sellByDate'][:10]}",
            ["STOREID", "PRODUCTID", "SELLBYDATE", "INSTOCK"],
            ["L1.STOREID", "L2.PRODUCTID", lit(row["sellByDate"]), lit(row["inStock"])],
            [("stores", "L1"), ("products", "L2")],
            [f"L1.STORECODE = {sqlLiteral(row['storeCode'])}",
             f"L2.PRODUCTCODE = {sqlLiteral(row['productCode'])}"])


if __name__ == "__main__":
    genRelData.main(sys.modules[__name__])
