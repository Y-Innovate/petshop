          05 LPETM202.
             10 RETURNCODE               PIC N(02).
             10 REASONCODE               PIC N(02).
             10 INFOMESSAGE              PIC N(72).
             10 STORENAME-FILTER.
                15 STORENAME-FILTER-LEN  PIC S9(4) COMP-5.
                15 STORENAME-FILTER-TEXT PIC N(256).
             10 STOREID-SINCE            PIC S9(9) USAGE COMP-5.
             10 STORE-COUNT              PIC S9(4) USAGE COMP-5.
             10 STORE-ENTRY OCCURS 20 TIMES
                  DEPENDING ON STORE-COUNT.
                15 STOREID               PIC S9(9) USAGE COMP-5.
                15 STORENAME.
                   20 STORENAME-LEN      PIC S9(4) USAGE COMP-5.
                   20 STORENAME-TEXT     PIC N(256).
                15 STORENAMEU.
                   20 STORENAMEU-LEN     PIC S9(4) USAGE COMP-5.
                   20 STORENAMEU-TEXT    PIC N(256).
                15 STORECODE             PIC N(08).
                15 STORESTATUS           PIC N(08).
                15 CREATEDBY             PIC N(08).
                15 CREATEDDATE           PIC N(26).
                15 UPDATEDBY             PIC N(08).
                15 UPDATEDDATE           PIC N(26).