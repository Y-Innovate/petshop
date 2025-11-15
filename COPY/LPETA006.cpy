          05 LPETA006.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 ANIMALID           PIC S9(9) USAGE COMP-5.
             10 STOREID            PIC S9(9) USAGE COMP-5.
             10 ANIMALTYPE         PIC N(08).
             10 ANIMALRACE         PIC N(08).
             10 ANIMALNAME.
                49 ANIMALNAME-LEN  PIC S9(4) USAGE COMP-5.
                49 ANIMALNAME-TEXT PIC N(255).
             10 ANIMALGENDER       PIC N(01).
             10 ANIMALAGE          PIC S9(9) USAGE COMP-5.
             10 ANIMALCOUNT        PIC S9(9) USAGE COMP-5.
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).