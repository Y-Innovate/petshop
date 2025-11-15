      ******************************************************************
      * DCLGEN TABLE(TBPET006)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET006))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET006 TABLE
           ( ANIMALID                       INTEGER NOT NULL,
             STOREID                        INTEGER NOT NULL,
             ANIMALTYPE                     GRAPHIC(8) NOT NULL,
             ANIMALRACE                     GRAPHIC(8) NOT NULL,
             ANIMALNAME                     VARGRAPHIC(255) NOT NULL,
             ANIMALGENDER                   GRAPHIC(1) NOT NULL,
             ANIMALAGE                      INTEGER NOT NULL,
             ANIMALCOUNT                    INTEGER NOT NULL,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET006                           *
      ******************************************************************
       01  DCLTBPET006.
           10 ANIMALID             PIC S9(9) USAGE COMP-5.
           10 STOREID              PIC S9(9) USAGE COMP-5.
           10 ANIMALTYPE           PIC N(8).
           10 ANIMALRACE           PIC N(8).
           10 ANIMALNAME.
              49 ANIMALNAME-LEN    PIC S9(4) USAGE COMP-5.
              49 ANIMALNAME-TEXT   PIC N(255).
           10 ANIMALGENDER         PIC N(1).
           10 ANIMALAGE            PIC S9(9) USAGE COMP-5.
           10 ANIMALCOUNT          PIC S9(9) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 12      *
      ******************************************************************