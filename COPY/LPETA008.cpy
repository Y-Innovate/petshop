          05 LPETA008.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 CUSTOMERID         PIC S9(9) USAGE COMP-5.
             10 LASTNAME.
                49 LASTNAME-LEN    PIC S9(4) USAGE COMP-5.
                49 LASTNAME-TEXT   PIC N(128).
             10 LASTNAMEU.
                49 LASTNAMEU-LEN   PIC S9(4) USAGE COMP-5.
                49 LASTNAMEU-TEXT  PIC N(128).
             10 FIRSTNAME.
                49 FIRSTNAME-LEN   PIC S9(4) USAGE COMP-5.
                49 FIRSTNAME-TEXT  PIC N(64).
             10 FIRSTNAMEU.
                49 FIRSTNAMEU-LEN  PIC S9(4) USAGE COMP-5.
                49 FIRSTNAMEU-TEXT PIC N(64).
             10 MIDDLENAME.
                49 MIDDLENAME-LEN  PIC S9(4) USAGE COMP-5.
                49 MIDDLENAME-TEXT PIC N(64).
             10 DATEOFBIRTH        PIC N(08).
             10 GENDER             PIC N(01).
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).