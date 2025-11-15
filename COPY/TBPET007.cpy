      ******************************************************************
      * DCLGEN TABLE(TBPET007)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET007))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET007 TABLE
           ( PADID                          INTEGER NOT NULL,
             STOREID                        INTEGER NOT NULL,
             PRODUCTID                      INTEGER,
             ANIMALID                       INTEGER,
             PRICE                          DECIMAL(9, 2),
             DISCOUNT                       DECIMAL(9, 2),
             FROMDATE                       TIMESTAMP,
             TODATE                         TIMESTAMP,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET007                           *
      ******************************************************************
       01  DCLTBPET007.
           10 PADID                PIC S9(9) USAGE COMP-5.
           10 STOREID              PIC S9(9) USAGE COMP-5.
           10 PRODUCTID            PIC S9(9) USAGE COMP-5.
           10 PRODUCTID-IND        PIC S9(4) USAGE COMP-5.
           10 ANIMALID             PIC S9(9) USAGE COMP-5.
           10 ANIMALID-IND         PIC S9(4) USAGE COMP-5.
           10 PRICE                PIC S9(7)V9(2) USAGE COMP-3.
           10 PRICE-IND            PIC S9(4) USAGE COMP-5.
           10 DISCOUNT             PIC S9(7)V9(2) USAGE COMP-3.
           10 DISCOUNT-IND         PIC S9(4) USAGE COMP-5.
           10 FROMDATE             PIC X(26).
           10 FROMDATE-IND         PIC S9(4) USAGE COMP-5.
           10 TODATE               PIC X(26).
           10 TODATE-IND           PIC S9(4) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 12      *
      ******************************************************************