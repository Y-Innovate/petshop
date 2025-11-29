          05 LPETM004.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 PRODUCTID          PIC S9(9) USAGE COMP-5.
             10 PRODUCTCODE        PIC N(08).
             10 PRODUCTSTATUS      PIC N(08).
             10 PRODUCTNAME.
                49 PRODUCTNAME-LEN  PIC S9(4) USAGE COMP-5.
                49 PRODUCTNAME-TEXT PIC N(255).
             10 PRODUCTNAMEU.
                49 PRODUCTNAMEU-LEN  PIC S9(4) USAGE COMP-5.
                49 PRODUCTNAMEU-TEXT PIC N(255).
             10 GROUPCODE          PIC N(08).
             10 SUPPLIERID         PIC S9(9) USAGE COMP-5.
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).