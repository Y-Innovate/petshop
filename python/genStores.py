"""Generate DB2 INSERT statements with initial data for the stores table
(AA000005.sql). See genInitData.py for details.

Usage:
    python genStores.py [-i data/stores.csv] [-e ../envs/dev1.yaml]
                        [-o stores.sql] [--days 30] [--replace]
"""
from genInitData import main

TABLENAME, PREFIX, SCRIPT = "stores", "store", "genStores.py"
EXTRAS, LOOKUPS = {}, []

if __name__ == "__main__":
    main(TABLENAME, PREFIX, SCRIPT, extras=EXTRAS, lookups=LOOKUPS)
