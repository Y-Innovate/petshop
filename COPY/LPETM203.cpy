          05 LPETM203.
             10 RETURNCODE                  PIC N(02).
             10 REASONCODE                  PIC N(02).
             10 INFOMESSAGE                 PIC N(72).
             10  SUPPLIERNAME-FILTER.
                15 SUPPLIERNAME-FILTER-LEN  PIC S9(4) COMP-5.
                15 SUPPLIERNAME-FILTER-TEXT PIC N(256).
             10 SUPPLIERID-SINCE            PIC S9(9) USAGE COMP-5.
             10 SUPPLIER-COUNT              PIC S9(4) USAGE COMP-5.
             10 SUPPLIER-ENTRY OCCURS 20 TIMES
                  DEPENDING ON SUPPLIER-COUNT.
                15 SUPPLIERID               PIC S9(9) USAGE COMP-5.
                15 SUPPLIERNAME.
                   20 SUPPLIERNAME-LEN      PIC S9(4) USAGE COMP-5.
                   20 SUPPLIERNAME-TEXT     PIC N(256).
                15 SUPPLIERNAMEU.
                   20 SUPPLIERNAMEU-LEN     PIC S9(4) USAGE COMP-5.
                   20 SUPPLIERNAMEU-TEXT    PIC N(256).
                15 SUPPLIERCODE             PIC N(08).
                15 SUPPLIERSTATUS           PIC N(08).
                15 CREATEDBY                PIC N(08).
                15 CREATEDDATE              PIC N(26).
                15 UPDATEDBY                PIC N(08).
                15 UPDATEDDATE              PIC N(26).