      ******************************************************************
      * DCLGEN TABLE(TBPET011)                                         *
      *        LIBRARY(YBTKS.DEMOBOB.COPY(TBPET011))                   *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE TBPET011 TABLE
           ( ADDRESSID                      INTEGER NOT NULL,
             ADDRESSTYPE                    GRAPHIC(8) NOT NULL,
             OWNERID                        INTEGER NOT NULL,
             FROMDATE                       TIMESTAMP,
             TODATE                         TIMESTAMP,
             ADDRESSLINE1                   VARGRAPHIC(128),
             ADDRESSLINE2                   VARGRAPHIC(128),
             POSTALCODE                     VARGRAPHIC(15),
             CITY                           VARGRAPHIC(128),
             REGION                         VARGRAPHIC(128),
             COUNTRY                        VARGRAPHIC(128),
             CREATEDBY                      GRAPHIC(8) NOT NULL,
             CREATEDDATE                    TIMESTAMP NOT NULL,
             UPDATEDBY                      GRAPHIC(8) NOT NULL,
             UPDATEDDATE                    TIMESTAMP NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE TBPET011                           *
      ******************************************************************
       01  DCLTBPET011.
           10 ADDRESSID            PIC S9(9) USAGE COMP-5.
           10 ADDRESSTYPE          PIC N(8).
           10 OWNERID              PIC S9(9) USAGE COMP-5.
           10 FROMDATE             PIC X(26).
           10 FROMDATE-IND         PIC S9(4) USAGE COMP-5.
           10 TODATE               PIC X(26).
           10 TODATE-IND           PIC S9(4) USAGE COMP-5.
           10 ADDRESSLINE1.
              49 ADDRESSLINE1-LEN  PIC S9(4) USAGE COMP-5.
              49 ADDRESSLINE1-TEXT PIC N(128).
           10 ADDRESSLINE1-IND     PIC S9(4) USAGE COMP-5.
           10 ADDRESSLINE2.
              49 ADDRESSLINE2-LEN  PIC S9(4) USAGE COMP-5.
              49 ADDRESSLINE2-TEXT PIC N(128).
           10 ADDRESSLINE2-IND     PIC S9(4) USAGE COMP-5.
           10 POSTALCODE.
              49 POSTALCODE-LEN    PIC S9(4) USAGE COMP-5.
              49 POSTALCODE-TEXT   PIC N(15).
           10 POSTALCODE-IND       PIC S9(4) USAGE COMP-5.
           10 CITY.
              49 CITY-LEN          PIC S9(4) USAGE COMP-5.
              49 CITY-TEXT         PIC N(128).
           10 CITY-IND             PIC S9(4) USAGE COMP-5.
           10 REGION.
              49 REGION-LEN        PIC S9(4) USAGE COMP-5.
              49 REGION-TEXT       PIC N(128).
           10 REGION-IND           PIC S9(4) USAGE COMP-5.
           10 COUNTRY.
              49 COUNTRY-LEN       PIC S9(4) USAGE COMP-5.
              49 COUNTRY-TEXT      PIC N(128).
           10 COUNTRY-IND          PIC S9(4) USAGE COMP-5.
           10 CREATEDBY            PIC N(8).
           10 CREATEDDATE          PIC X(26).
           10 UPDATEDBY            PIC N(8).
           10 UPDATEDDATE          PIC X(26).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 15      *
      ******************************************************************
