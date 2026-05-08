          05 LPETM204.
             10 RETURNCODE                 PIC N(02).
             10 REASONCODE                 PIC N(02).
             10 INFOMESSAGE                PIC N(72).
             10 PRODUCTNAME-FILTER.
                15 PRODUCTNAME-FILTER-LEN  PIC S9(4) COMP-5.
                15 PRODUCTNAME-FILTER-TEXT PIC N(256).
             10 PRODUCTID-SINCE            PIC S9(9) USAGE COMP-5.
             10 PRODUCT-COUNT              PIC S9(4) USAGE COMP-5.
             10 PRODUCT-ENTRY OCCURS 20 TIMES
                  DEPENDING ON PRODUCT-COUNT.
                15 PRODUCTID               PIC S9(9) USAGE COMP-5.
                15 PRODUCTNAME.
                   20 PRODUCTNAME-LEN      PIC S9(4) USAGE COMP-5.
                   20 PRODUCTNAME-TEXT     PIC N(256).
                15 PRODUCTNAMEU.
                   20 PRODUCTNAMEU-LEN     PIC S9(4) USAGE COMP-5.
                   20 PRODUCTNAMEU-TEXT    PIC N(256).
                15 PRODUCTCODE             PIC N(08).
                15 PRODUCTSTATUS           PIC N(08).
                15 GROUPCODE               PIC N(08).
                15 SUPPLIERID              PIC S9(9) USAGE COMP-5.
                15 CREATEDBY               PIC N(08).
                15 CREATEDDATE             PIC N(26).
                15 UPDATEDBY               PIC N(08).
                15 UPDATEDDATE             PIC N(26).