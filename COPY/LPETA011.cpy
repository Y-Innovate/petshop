          05 LPETA011.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 ADDRESSID          PIC S9(9) USAGE COMP-5.
             10 ADDRESSTYPE        PIC N(08).
             10 OWNERID            PIC S9(9) USAGE COMP-5.
             10 FROMDATE           PIC N(26).
             10 TODATE             PIC N(26).
             10 ADDRESSLINE1.
                49 ADDRESSLINE1-LEN  PIC S9(4) USAGE COMP-5.
                49 ADDRESSLINE1-TEXT PIC N(128).
             10 ADDRESSLINE2.
                49 ADDRESSLINE2-LEN  PIC S9(4) USAGE COMP-5.
                49 ADDRESSLINE2-TEXT PIC N(128).
             10 POSTALCODE.
                49 POSTALCODE-LEN  PIC S9(4) USAGE COMP-5.
                49 POSTALCODE-TEXT PIC N(15).
             10 CITY.
                49 CITY-LEN        PIC S9(4) USAGE COMP-5.
                49 CITY-TEXT       PIC N(128).
             10 REGION.
                49 REGION-LEN      PIC S9(4) USAGE COMP-5.
                49 REGION-TEXT     PIC N(128).
             10 COUNTRY.
                49 COUNTRY-LEN     PIC S9(4) USAGE COMP-5.
                49 COUNTRY-TEXT    PIC N(128).
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).