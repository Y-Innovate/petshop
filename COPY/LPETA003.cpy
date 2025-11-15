          05 LPETA003.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 SUPPLIERID         PIC S9(9) USAGE COMP-5.
             10 SUPPLIERCODE       PIC N(08).
             10 SUPPLIERSTATUS     PIC N(08).
             10 SUPPLIERNAME.
                49 SUPPLIERNAME-LEN  PIC S9(4) USAGE COMP-5.
                49 SUPPLIERNAME-TEXT PIC N(255).
             10 SUPPLIERNAMEU.
                49 SUPPLIERNAMEU-LEN  PIC S9(4) USAGE COMP-5.
                49 SUPPLIERNAMEU-TEXT PIC N(255).
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).