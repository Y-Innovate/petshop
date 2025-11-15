      ******************************************************************
      * DCLGEN TABLE(TBPET010)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET010))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET010 TABLE
           ( ORDERID                        INTEGER NOT NULL,
             STOREID                        INTEGER NOT NULL,
             PURCHASEID                     INTEGER NOT NULL,
             ORDERDATE                      TIMESTAMP NOT NULL,
             PRODUCTID                      INTEGER,
             ANIMALID                       INTEGER,
             ORDERCOUNT                     INTEGER NOT NULL,
             TYPEOFDISCOUNT                 GRAPHIC(1) NOT NULL,
             PRICE                          DECIMAL(9, 2) NOT NULL,
             DISCOUNT                       DECIMAL(9, 2),
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET010                           *
      ******************************************************************
       01  DCLTBPET010.
           10 ORDERID              PIC S9(9) USAGE COMP-5.
           10 STOREID              PIC S9(9) USAGE COMP-5.
           10 PURCHASEID           PIC S9(9) USAGE COMP-5.
           10 ORDERDATE            PIC X(26).
           10 PRODUCTID            PIC S9(9) USAGE COMP-5.
           10 PRODUCTID-IND        PIC S9(4) USAGE COMP-5.
           10 ANIMALID             PIC S9(9) USAGE COMP-5.
           10 ANIMALID-IND         PIC S9(4) USAGE COMP-5.
           10 ORDERCOUNT           PIC S9(9) USAGE COMP-5.
           10 TYPEOFDISCOUNT       PIC N(1).
           10 PRICE                PIC S9(7)V9(2) USAGE COMP-3.
           10 DISCOUNT             PIC S9(7)V9(2) USAGE COMP-3.
           10 DISCOUNT-IND         PIC S9(4) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 14      *
      ******************************************************************