      ******************************************************************
      * DCLGEN TABLE(TBPET012)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET012))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET012 TABLE
           ( CONTACTINFOID                  INTEGER NOT NULL,
             CONTACTINFOTYPE                GRAPHIC(8) NOT NULL,
             OWNERTYPE                      GRAPHIC(1) NOT NULL,
             OWNERID                        INTEGER NOT NULL,
             CONTACTDATA                    VARGRAPHIC(255),
             FROMDATE                       TIMESTAMP,
             TODATE                         TIMESTAMP,
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET012                           *
      ******************************************************************
       01  DCLTBPET012.
           10 CONTACTINFOID        PIC S9(9) USAGE COMP-5.
           10 CONTACTINFOTYPE      PIC N(8).
           10 OWNERTYPE            PIC N(1).
           10 OWNERID              PIC S9(9) USAGE COMP-5.
           10 CONTACTDATA.
              49 CONTACTDATA-LEN   PIC S9(4) USAGE COMP-5.
              49 CONTACTDATA-TEXT  PIC N(255).
           10 CONTACTDATA-IND      PIC S9(4) USAGE COMP-5.
           10 FROMDATE             PIC X(26).
           10 FROMDATE-IND         PIC S9(4) USAGE COMP-5.
           10 TODATE               PIC X(26).
           10 TODATE-IND           PIC S9(4) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 11      *
      ******************************************************************