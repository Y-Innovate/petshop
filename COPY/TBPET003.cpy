      ******************************************************************
      * DCLGEN TABLE(TBPET003)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET003))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET003 TABLE
           ( SUPPLIERID                     INTEGER NOT NULL,
             SUPPLIERCODE                   GRAPHIC(8) NOT NULL,
             SUPPLIERSTATUS                 GRAPHIC(8) NOT NULL,
             SUPPLIERNAME                   VARGRAPHIC(255) NOT NULL,
             SUPPLIERNAMEU                  VARGRAPHIC(255) NOT NULL,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET003                           *
      ******************************************************************
       01  DCLTBPET003.
           10 SUPPLIERID           PIC S9(9) USAGE COMP-5.
           10 SUPPLIERCODE         PIC N(8).
           10 SUPPLIERSTATUS       PIC N(8).
           10 SUPPLIERNAME.
              49 SUPPLIERNAME-LEN  PIC S9(4) USAGE COMP-5.
              49 SUPPLIERNAME-TEXT PIC N(255).
           10 SUPPLIERNAMEU.
              49 SUPPLIERNAMEU-LEN PIC S9(4) USAGE COMP-5.
              49 SUPPLIERNAMEU-TEXT PIC N(255).
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 9       *
      ******************************************************************