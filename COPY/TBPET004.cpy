      ******************************************************************
      * DCLGEN TABLE(TBPET004)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET004))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET004 TABLE
           ( PRODUCTID                      INTEGER NOT NULL,
             PRODUCTCODE                    GRAPHIC(8) NOT NULL,
             PRODUCTSTATUS                  GRAPHIC(8) NOT NULL,
             PRODUCTNAME                    VARGRAPHIC(255) NOT NULL,
             PRODUCTNAMEU                   VARGRAPHIC(255) NOT NULL,
             GROUPCODE                      GRAPHIC(8) NOT NULL,
             SUPPLIERID                     INTEGER NOT NULL,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET004                           *
      ******************************************************************
       01  DCLTBPET004.
           10 PRODUCTID            PIC S9(9) USAGE COMP-5.
           10 PRODUCTCODE          PIC N(8).
           10 PRODUCTSTATUS        PIC N(8).
           10 PRODUCTNAME.
              49 PRODUCTNAME-LEN   PIC S9(4) USAGE COMP-5.
              49 PRODUCTNAME-TEXT  PIC N(255).
           10 PRODUCTNAMEU.
              49 PRODUCTNAMEU-LEN  PIC S9(4) USAGE COMP-5.
              49 PRODUCTNAMEU-TEXT PIC N(255).
           10 GROUPCODE            PIC N(8).
           10 SUPPLIERID           PIC S9(9) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 11      *
      ******************************************************************