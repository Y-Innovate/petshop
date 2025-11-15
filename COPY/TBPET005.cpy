      ******************************************************************
      * DCLGEN TABLE(TBPET005)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET005))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET005 TABLE
           ( INVENTORYID                    INTEGER NOT NULL,
             STOREID                        INTEGER NOT NULL,
             PRODUCTID                      INTEGER NOT NULL,
             SELLBYDATE                     TIMESTAMP NOT NULL,
             INSTOCK                        INTEGER NOT NULL,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET005                           *
      ******************************************************************
       01  DCLTBPET005.
           10 INVENTORYID          PIC S9(9) USAGE COMP-5.
           10 STOREID              PIC S9(9) USAGE COMP-5.
           10 PRODUCTID            PIC S9(9) USAGE COMP-5.
           10 SELLBYDATE           PIC X(26).
           10 INSTOCK              PIC S9(9) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 9       *
      ******************************************************************