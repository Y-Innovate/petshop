"""Generate DB2 INSERT statements with initial data for the suppliers table
(AA000006.sql). See genInitData.py for details.

Usage:
    python genSuppliers.py [-i data/suppliers.csv] [-e ../envs/dev1.yaml]
                           [-o suppliers.sql] [--days 30] [--replace]
"""
from genInitData import main

TABLENAME, PREFIX, SCRIPT = "suppliers", "supplier", "genSuppliers.py"
EXTRAS, LOOKUPS = {}, []

if __name__ == "__main__":
    main(TABLENAME, PREFIX, SCRIPT, extras=EXTRAS, lookups=LOOKUPS)
