          05 LPETA002.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 STOREID            PIC S9(9) USAGE COMP-5.
             10 STORECODE          PIC N(08).
             10 STORESTATUS        PIC N(08).
             10 STORENAME.
                49 STORENAME-LEN   PIC S9(4) USAGE COMP-5.
                49 STORENAME-TEXT  PIC N(255).
             10 STORENAMEU.
                49 STORENAMEU-LEN  PIC S9(4) USAGE COMP-5.
                49 STORENAMEU-TEXT PIC N(255).
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).