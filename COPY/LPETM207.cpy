          05 LPETM207.
             10 RETURNCODE                 PIC N(02).
             10 REASONCODE                 PIC N(02).
             10 INFOMESSAGE                PIC N(72).
             10 STOREID-FILTER             PIC S9(9) USAGE COMP-5.
             10 PRODUCTID-FILTER           PIC S9(9) USAGE COMP-5.
             10 ANIMALID-FILTER            PIC S9(9) USAGE COMP-5.
             10 PADID-SINCE                PIC S9(9) USAGE COMP-5.
             10 PAD-COUNT                  PIC S9(4) USAGE COMP-5.
             10 PAD-ENTRY OCCURS 20 TIMES
                  DEPENDING ON PAD-COUNT.
                15 PADID                   PIC S9(9) USAGE COMP-5.
                15 STOREID                 PIC S9(9) USAGE COMP-5.
                15 PRODUCTID               PIC S9(9) USAGE COMP-5.
                15 ANIMALID                PIC S9(9) USAGE COMP-5.
                15 PRICE                   PIC S9(7)V9(2) USAGE COMP-3.
                15 DISCOUNT                PIC S9(7)V9(2) USAGE COMP-3.
                15 FROMDATE                PIC N(26).
                15 TODATE                  PIC N(26).
                15 CREATEDBY               PIC N(08).
                15 CREATEDDATE             PIC N(26).
                15 UPDATEDBY               PIC N(08).
                15 UPDATEDDATE             PIC N(26).