          05 LPETA001.
             10 OPCODE            PIC N.
             10 RETURNCODE        PIC N(02).
             10 REASONCODE        PIC N(02).
             10 INFOMESSAGE       PIC N(72).
             10 TABLEID           PIC N(08).
             10 TABKEY            PIC N(08).
             10 TABVALUE.
                49 TABVALUE-LEN   PIC S9(4) USAGE COMP-5.
                49 TABVALUE-TEXT  PIC N(255).
             10 CREATEDBY         PIC N(08).
             10 CREATEDDATE       PIC N(26).
             10 UPDATEDBY         PIC N(08).
             10 UPDATEDDATE       PIC N(26).