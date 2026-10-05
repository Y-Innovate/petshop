          05 LPETM213.
             10 RETURNCODE                 PIC N(02).
             10 REASONCODE                 PIC N(02).
             10 INFOMESSAGE                PIC N(72).
             10 STOREID-FILTER             PIC S9(9) USAGE COMP-5.
             10 SUPPLIERID-FILTER          PIC S9(9) USAGE COMP-5.
             10 STOREID-SINCE              PIC S9(9) USAGE COMP-5.
             10 SUPPLIERID-SINCE           PIC S9(9) USAGE COMP-5.
             10 STORESUPPL-COUNT           PIC S9(4) USAGE COMP-5.
             10 STORESUPPL-ENTRY OCCURS 20 TIMES
                  DEPENDING ON STORESUPPL-COUNT.
                15 STOREID                 PIC S9(9) USAGE COMP-5.
                15 SUPPLIERID              PIC S9(9) USAGE COMP-5.
                15 FROMDATE                PIC N(26).
                15 TODATE                  PIC N(26).
                15 CREATEDBY               PIC N(08).
                15 CREATEDDATE             PIC N(26).
                15 UPDATEDBY               PIC N(08).
                15 UPDATEDDATE             PIC N(26).
