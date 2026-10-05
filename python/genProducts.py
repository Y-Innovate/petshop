"""Generate DB2 INSERT statements with initial data for the products table
(AA000007.sql). See genInitData.py for details.

SUPPLIERID is looked up from the suppliers table via the supplierCode
column in the CSV, so load the suppliers (genSuppliers.py) first.

Usage:
    python genProducts.py [-i data/products.csv] [-e ../envs/dev1.yaml]
                          [-o products.sql] [--days 30] [--replace]
"""
from genInitData import main

TABLENAME, PREFIX, SCRIPT = "products", "product", "genProducts.py"
EXTRAS, LOOKUPS = {"groupCode": 8}, [("suppliers", "supplier")]

if __name__ == "__main__":
    main(TABLENAME, PREFIX, SCRIPT, extras=EXTRAS, lookups=LOOKUPS)
