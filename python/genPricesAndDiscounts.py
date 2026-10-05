"""Generate DB2 INSERT statements with initial data for the pricesAndDiscounts
table (AA000010.sql). See genRelData.py for details.

The CSV columns are
    storeCode, productCode, animalType, animalRace, animalName,
    price, discount, fromDate, toDate, createdBy, updatedBy
Each row prices either a product (productCode) or an animal (animalType,
animalRace and animalName, which identify the animal within the store),
like PETM007 expects. STOREID, PRODUCTID and ANIMALID are looked up, so load
the stores, products and animals first. price and/or discount must be given
(DECIMAL(9,2), price above 0, discount not 0); fromDate and toDate are
optional, like in genStoreSuppl.py.

Usage:
    python genPricesAndDiscounts.py [-i data/pricesanddiscounts.csv]
                                    [-e ../envs/dev1.yaml]
                                    [-o pricesanddiscounts.sql]
                                    [--days 30] [--replace]
"""
import sys

import genRelData
from genRelData import Field, csvRows, lit, sqlLiteral, warnUnknown

TABLENAME = "pricesanddiscounts"
SCRIPT = "genPricesAndDiscounts.py"
FIELDS = [Field("storeCode"), Field("productCode", required=False),
          Field("animalType", required=False), Field("animalRace", required=False),
          Field("animalName", required=False, maxlen=255),
          Field("price", "dec", required=False), Field("discount", "dec", required=False),
          Field("fromDate", "from", required=False), Field("toDate", "to", required=False)]
KEY = ["storeCode", "productCode", "animalType", "animalRace", "animalName"]
LOOKUPS = ["stores", "products", "animals"]
ANIMAL = ("animalType", "animalRace", "animalName")


def check(rows, where):
    for row in rows:
        at = f"{where} line {row['lineno']}"
        animal = [row[f] for f in ANIMAL]
        if any(animal) and not all(animal):
            raise ValueError(f"{at}: give animalType, animalRace and animalName together")
        if bool(row["productCode"]) == all(animal):
            raise ValueError(f"{at}: give either productCode or an animal")
        if row["price"] is None and row["discount"] is None:
            raise ValueError(f"{at}: give price and/or discount")
        if row["price"] is not None and row["price"] <= 0:
            raise ValueError(f"{at}: price must be above 0")
        if row["discount"] is not None and row["discount"] == 0:
            raise ValueError(f"{at}: discount must not be 0")
        if row["fromDate"] and row["toDate"] and row["toDate"] < row["fromDate"]:
            raise ValueError(f"{at}: toDate before fromDate")
    warnUnknown(rows, where, "storeCode", "stores", "store")
    warnUnknown(rows, where, "productCode", "products", "product")
    animals = {tuple(r[k] for k in ("storeCode",) + ANIMAL) for r in csvRows("animals")}
    stocked = {(r["storeCode"], r["productCode"]) for r in csvRows("inventory")}
    for row in rows:
        at = f"{where} line {row['lineno']}"
        if row["animalName"] and animals and \
                tuple(row[k] for k in ("storeCode",) + ANIMAL) not in animals:
            print(f"Warning: {at}: animal not in data/animals.csv for store "
                  f"{row['storeCode']}", file=sys.stderr)
        if row["productCode"] and stocked and (row["storeCode"], row["productCode"]) not in stocked:
            print(f"Warning: {at}: product {row['productCode']} is not in stock in "
                  f"store {row['storeCode']} in data/inventory.csv", file=sys.stderr)


def build(row, tables):
    froms = [("stores", "L1")]
    wheres = [f"L1.STORECODE = {sqlLiteral(row['storeCode'])}"]
    if row["productCode"]:
        froms.append(("products", "L2"))
        wheres.append(f"L2.PRODUCTCODE = {sqlLiteral(row['productCode'])}")
        product, animal, what = "L2.PRODUCTID", "NULL", f"product {row['productCode']}"
    else:
        froms.append(("animals", "L3"))
        wheres += ["L3.STOREID = L1.STOREID",
                   f"L3.ANIMALTYPE = {sqlLiteral(row['animalType'])}",
                   f"L3.ANIMALRACE = {sqlLiteral(row['animalRace'])}",
                   f"L3.ANIMALNAME = {sqlLiteral(row['animalName'])}"]
        product, animal, what = "NULL", "L3.ANIMALID", f"animal {row['animalName']}"
    return (f"Store {row['storeCode']} {what}",
            ["STOREID", "PRODUCTID", "ANIMALID", "PRICE", "DISCOUNT", "FROMDATE", "TODATE"],
            ["L1.STOREID", product, animal, lit(row["price"]), lit(row["discount"]),
             lit(row["fromDate"]), lit(row["toDate"])],
            froms, wheres)


if __name__ == "__main__":
    genRelData.main(sys.modules[__name__])
