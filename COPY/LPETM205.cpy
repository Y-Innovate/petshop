          05 LPETM205.
             10 RETURNCODE                 PIC N(02).
             10 REASONCODE                 PIC N(02).
             10 INFOMESSAGE                PIC N(72).
             10 STOREID-FILTER             PIC S9(9) USAGE COMP-5.
             10 PRODUCTID-SINCE            PIC S9(9) USAGE COMP-5.
             10 INVENTORY-COUNT            PIC S9(4) USAGE COMP-5.
             10 INVENTORY-ENTRY OCCURS 20 TIMES
                  DEPENDING ON INVENTORY-COUNT.
                15 INVENTORYID             PIC S9(9) USAGE COMP-5.
                15 STOREID                 PIC S9(9) USAGE COMP-5.
                15 PRODUCTID               PIC S9(9) USAGE COMP-5.
                15 SELLBYDATE              PIC N(26).
                15 INSTOCK                 PIC S9(9) USAGE COMP-5.
                15 CREATEDBY               PIC N(08).
                15 CREATEDDATE             PIC N(26).
                15 UPDATEDBY               PIC N(08).
                15 UPDATEDDATE             PIC N(26).