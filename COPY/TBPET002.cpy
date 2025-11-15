      ******************************************************************
      * DCLGEN TABLE(TBPET002)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COBOL(TBPET002))                  *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE  TBPET002 TABLE
           ( STOREID                        INTEGER NOT NULL,
             STORECODE                      GRAPHIC(8) NOT NULL,
             STORESTATUS                    GRAPHIC(8) NOT NULL,
             STORENAME                      VARGRAPHIC(255) NOT NULL,
             STORENAMEU                     VARGRAPHIC(255) NOT NULL,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET002                           *
      ******************************************************************
       01  DCLTBPET002.
           10 STOREID              PIC S9(9) USAGE COMP-5.
           10 STORECODE            PIC N(8).
           10 STORESTATUS          PIC N(8).
           10 STORENAME.
              49 STORENAME-LEN     PIC S9(4) USAGE COMP-5.
              49 STORENAME-TEXT    PIC N(255).
           10 STORENAMEU.
              49 STORENAMEU-LEN    PIC S9(4) USAGE COMP-5.
              49 STORENAMEU-TEXT   PIC N(255).
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 9       *
      ******************************************************************