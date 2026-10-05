"""Generate DB2 INSERT statements with initial data for the animals table
(AA000009.sql). See genRelData.py for details.

The CSV columns are
    storeCode, supplierCode, animalType, animalRace, animalName,
    animalGender, animalAge, animalCount, createdBy, updatedBy
STOREID and SUPPLIERID are looked up via STORECODE and SUPPLIERCODE, so load
the stores and suppliers first. supplierCode is optional: empty means no
supplier (bred in the store), SUPPLIERID NULL. A warning is given when the
supplier is not connected to the store in data/storesuppl.csv.

Usage:
    python genAnimals.py [-i data/animals.csv] [-e ../envs/dev1.yaml]
                         [-o animals.sql] [--days 30] [--replace]
"""
import sys

import genRelData
from genRelData import Field, csvRows, lit, sqlLiteral, warnUnknown

TABLENAME = "animals"
SCRIPT = "genAnimals.py"
FIELDS = [Field("storeCode"), Field("supplierCode", required=False),
          Field("animalType"), Field("animalRace"), Field("animalName", maxlen=255),
          Field("animalGender", maxlen=1), Field("animalAge", "int", minimum=0),
          Field("animalCount", "int", minimum=1)]
KEY = ["storeCode", "animalType", "animalRace", "animalName"]
LOOKUPS = ["stores", "suppliers"]


def check(rows, where):
    for row in rows:
        if row["animalGender"] not in ("M", "F"):
            raise ValueError(f"{where} line {row['lineno']}: animalGender must be M or F")
    warnUnknown(rows, where, "storeCode", "stores", "store")
    warnUnknown(rows, where, "supplierCode", "suppliers", "supplier")
    links = {(r["storeCode"], r["supplierCode"]) for r in csvRows("storesuppl")}
    if links:
        for row in rows:
            if row["supplierCode"] and (row["storeCode"], row["supplierCode"]) not in links:
                print(f"Warning: {where} line {row['lineno']}: supplier "
                      f"{row['supplierCode']} is not connected to store "
                      f"{row['storeCode']} in data/storesuppl.csv", file=sys.stderr)


def build(row, tables):
    froms = [("stores", "L1")]
    wheres = [f"L1.STORECODE = {sqlLiteral(row['storeCode'])}"]
    supplier = "NULL"
    if row["supplierCode"]:
        froms.append(("suppliers", "L2"))
        wheres.append(f"L2.SUPPLIERCODE = {sqlLiteral(row['supplierCode'])}")
        supplier = "L2.SUPPLIERID"
    return (f"Animal {row['animalName']} ({row['animalType']}/{row['animalRace']})"
            f" in store {row['storeCode']}",
            ["STOREID", "SUPPLIERID", "ANIMALTYPE", "ANIMALRACE", "ANIMALNAME",
             "ANIMALGENDER", "ANIMALAGE", "ANIMALCOUNT"],
            ["L1.STOREID", supplier, lit(row["animalType"]), lit(row["animalRace"]),
             lit(row["animalName"]), lit(row["animalGender"]), lit(row["animalAge"]),
             lit(row["animalCount"])],
            froms, wheres)


if __name__ == "__main__":
    genRelData.main(sys.modules[__name__])
