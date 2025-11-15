      ******************************************************************
      * DCLGEN TABLE(TBPET008)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET008))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET008 TABLE
           ( CUSTOMERID                     INTEGER NOT NULL,
             LASTNAME                       VARGRAPHIC(128) NOT NULL,
             LASTNAMEU                      VARGRAPHIC(128) NOT NULL,
             FIRSTNAME                      VARGRAPHIC(64),
             FIRSTNAMEU                     VARGRAPHIC(64),
             MIDDLENAME                     VARGRAPHIC(64),
             DATEOFBIRTH                    GRAPHIC(8),
             GENDER                         GRAPHIC(1),
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET008                           *
      ******************************************************************
       01  DCLTBPET008.
           10 CUSTOMERID           PIC S9(9) USAGE COMP-5.
           10 LASTNAME.
              49 LASTNAME-LEN      PIC S9(4) USAGE COMP-5.
              49 LASTNAME-TEXT     PIC N(128).
           10 LASTNAMEU.
              49 LASTNAMEU-LEN     PIC S9(4) USAGE COMP-5.
              49 LASTNAMEU-TEXT    PIC N(128).
           10 FIRSTNAME.
              49 FIRSTNAME-LEN     PIC S9(4) USAGE COMP-5.
              49 FIRSTNAME-TEXT    PIC N(64).
           10 FIRSTNAME-IND        PIC S9(4) USAGE COMP-5.
           10 FIRSTNAMEU.
              49 FIRSTNAMEU-LEN    PIC S9(4) USAGE COMP-5.
              49 FIRSTNAMEU-TEXT   PIC N(64).
           10 FIRSTNAMEU-IND       PIC S9(4) USAGE COMP-5.
           10 MIDDLENAME.
              49 MIDDLENAME-LEN    PIC S9(4) USAGE COMP-5.
              49 MIDDLENAME-TEXT   PIC N(64).
           10 MIDDLENAME-IND       PIC S9(4) USAGE COMP-5.
           10 DATEOFBIRTH          PIC N(8).
           10 DATEOFBIRTH-IND      PIC S9(4) USAGE COMP-5.
           10 GENDER               PIC N(1).
           10 GENDER-IND           PIC S9(4) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 12      *
      ******************************************************************