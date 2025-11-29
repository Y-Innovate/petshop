          05 LPETM201.
             10 RETURNCODE        PIC N(02).
             10 REASONCODE        PIC N(02).
             10 INFOMESSAGE       PIC N(72).
             10 TABLEID-FILTER    PIC N(08).
             10 TABLEID-SINCE     PIC N(08).
             10 TABKEY-SINCE      PIC N(08).
             10 REFTABLE-COUNT    PIC S9(4) USAGE COMP-5.
             10 REFTABLE-ENTRY OCCURS 20 TIMES
                  DEPENDING ON REFTABLE-COUNT.
                15 TABLEID        PIC N(08).
                15 TABKEY         PIC N(08).
                15 TABVALUE.
                   20 TABVALUE-LEN   PIC S9(4) USAGE COMP-5.
                   20 TABVALUE-TEXT  PIC N(256).
                15 CREATEDBY         PIC N(08).
                15 CREATEDDATE       PIC N(26).
                15 UPDATEDBY         PIC N(08).
                15 UPDATEDDATE       PIC N(26).