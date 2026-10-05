      ******************************************************************
      * DCLGEN TABLE(TBPET013)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET013))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET013 TABLE
           ( STOREID                        INTEGER NOT NULL,
             SUPPLIERID                     INTEGER NOT NULL,
             FROMDATE                       TIMESTAMP,
             TODATE                         TIMESTAMP,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET013                           *
      ******************************************************************
       01  DCLTBPET013.
           10 STOREID              PIC S9(9) USAGE COMP-5.
           10 SUPPLIERID           PIC S9(9) USAGE COMP-5.
           10 FROMDATE             PIC X(26).
           10 FROMDATE-IND         PIC S9(4) USAGE COMP-5.
           10 TODATE               PIC X(26).
           10 TODATE-IND           PIC S9(4) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 8       *
      ******************************************************************
