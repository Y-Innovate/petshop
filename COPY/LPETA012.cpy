          05 LPETA012.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 CONTACTINFOID      PIC S9(9) USAGE COMP-5.
             10 CONTACTINFOTYPE    PIC N(08).
             10 OWNERTYPE          PIC N(01).
             10 OWNERID            PIC S9(9) USAGE COMP-5.
             10 CONTACTDATA.
                49 CONTACTDATA-LEN  PIC S9(4) USAGE COMP-5.
                49 CONTACTDATA-TEXT PIC N(255).
             10 FROMDATE           PIC N(26).
             10 TODATE             PIC N(26).
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).