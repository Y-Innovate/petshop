      ******************************************************************
      * DCLGEN TABLE(TBPET001)                                         *
      *        LIBRARY(YBITBUC.DEMOBOB.COBOL(TBPET001))                *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET001 TABLE
           (TABLEID                         GRAPHIC(8) NOT NULL,
             TABKEY                         GRAPHIC(8) NOT NULL,
             TABVALUE                       VARGRAPHIC(255) NOT NULL,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET001                           *
      ******************************************************************
       01 DCLTBPET001.
          10 TABLEID               PIC N(8).
          10 TABKEY                PIC N(8).
          10 TABVALUE.
             49 TABVALUE-LEN       PIC S9(4) USAGE COMP-5.
             49 TABVALUE-TEXT      PIC N(255).
          10 TABVALUE-IND          PIC S9(4) USAGE COMP-5.
          10 CREATEDBY             PIC N(8).
          10 CREATEDDATE           PIC X(26).
          10 UPDATEDBY             PIC N(8).
          10 UPDATEDDATE           PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 7       *
      ******************************************************************