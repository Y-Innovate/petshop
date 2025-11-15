      ******************************************************************
      * DCLGEN TABLE(TBPET009)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET009))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET009 TABLE
           ( PURCHASEID                     INTEGER NOT NULL,
             PURCHASEDATE                   TIMESTAMP NOT NULL,
             CUSTOMERID                     INTEGER,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET009                           *
      ******************************************************************
       01  DCLTBPET009.
           10 PURCHASEID           PIC S9(9) USAGE COMP-5.
           10 PURCHASEDATE         PIC X(26).
           10 CUSTOMERID           PIC S9(9) USAGE COMP-5.
           10 CUSTOMERID-IND       PIC S9(4) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 7       *
      ******************************************************************