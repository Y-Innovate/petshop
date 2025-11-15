       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETA011
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET011 ADDRESSES table.                                     *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET011                           *
      *   TBPET011 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: ADDRESSID required                         *
      *     08 03 = Error: ADDRESSTYPE required                       *
      *     08 11 = Error: INSERT of duplicate key                    *
      *     08 12 = Error: SQL error in INSERT                        *
      *     08 21 = Error: SQL error in SELECT                        *
      *     08 31 = Error: UPDATE of non existing key                 *
      *     08 32 = Error: SQL error in UPDATE                        *
      *     08 41 = Error: DELETE of non existing key                 *
      *     08 42 = Error: SQL error in DELETE                        *
      *     08 90 = Error: PETA900 returned non-zero                  *
      * ------------------------------------------------------------- *
      * Updates:                                                      *
      *                                                               *
      * Date     Who What                                             *
      * -------- --- ------------------------------------------------ *
      * yy/mm/dd ii  description                                      *
      *===============================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.

           EXEC SQL INCLUDE TBPET011 END-EXEC.

       01 WORK.
          05 W-PGMNAME    PIC X(8).
          05 W-SQLCODE    PIC -99999.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       01 W-LPETA011.
           COPY LPETA011.

       01 W-LPETA900.
           COPY LPETA900.

       LINKAGE SECTION.
       01 P-LPETA011.
           COPY LPETA011.

       PROCEDURE DIVISION USING P-LPETA011.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETA011 = N'00'
              EVALUATE OPCODE OF W-LPETA011
              WHEN N'C'
                 PERFORM R110-INSERT
              WHEN N'R'
                 PERFORM R120-SELECT
              WHEN N'U'
                 PERFORM R130-UPDATE
              WHEN N'D'
                 PERFORM R140-DELETE
              END-EVALUATE
           END-IF

           PERFORM R009-FINISH
           .
       MAIN-END.
           GOBACK.

      *===============================================================*
      * R001-INIT: Program initialisations                            *
      *===============================================================*
       R001-INIT SECTION.
           MOVE P-LPETA011 TO W-LPETA011

           MOVE N'00' TO RETURNCODE OF W-LPETA011
           MOVE N'00' TO REASONCODE OF W-LPETA011
           MOVE SPACES TO INFOMESSAGE OF W-LPETA011
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETA011 NOT = N'C'
           AND OPCODE OF W-LPETA011 NOT = N'R'
           AND OPCODE OF W-LPETA011 NOT = N'U'
           AND OPCODE OF W-LPETA011 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETA011
              MOVE N'01' TO REASONCODE OF W-LPETA011
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETA011
           END-IF

           IF OPCODE OF W-LPETA011 NOT = N'C'
              IF  RETURNCODE OF W-LPETA011 = N'00'
              AND ADDRESSID  OF W-LPETA011 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA011
                 MOVE N'02' TO REASONCODE OF W-LPETA011
                 MOVE N'ADDRESSID is required' TO
                      INFOMESSAGE OF W-LPETA011
              END-IF
           END-IF

           IF OPCODE OF W-LPETA011 = N'C'
           OR OPCODE OF W-LPETA011 = N'U'
              IF   RETURNCODE OF W-LPETA011 = N'00'
              AND (ADDRESSTYPE OF W-LPETA011 = SPACES
              OR   ADDRESSTYPE OF W-LPETA011 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETA011
                 MOVE N'03' TO REASONCODE OF W-LPETA011
                 MOVE N'ADDRESSTYPE is required' TO
                      INFOMESSAGE OF W-LPETA011
              END-IF

              IF CREATEDBY OF W-LPETA011 = SPACES
              OR CREATEDBY OF W-LPETA011 = LOW-VALUES
              OR UPDATEDBY OF W-LPETA011 = SPACES
              OR UPDATEDBY OF W-LPETA011 = LOW-VALUES
                 MOVE 'PETA900' TO W-PGMNAME
                 
                 CALL W-PGMNAME USING W-LPETA900

                 IF RETURNCODE OF W-LPETA900 = N'00'
                    IF CREATEDBY OF W-LPETA011 = SPACES
                    OR CREATEDBY OF W-LPETA011 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            CREATEDBY OF W-LPETA011
                    END-IF

                    IF UPDATEDBY OF W-LPETA011 = SPACES
                    OR UPDATEDBY OF W-LPETA011 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            UPDATEDBY OF W-LPETA011
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETA011
                    MOVE N'90' TO REASONCODE OF W-LPETA011
                    MOVE INFOMESSAGE OF W-LPETA900 TO
                         INFOMESSAGE OF W-LPETA011
                 END-IF
              END-IF
           END-IF
           .
       R002-CHECKPARM-END.
           EXIT.

      *===============================================================*
      * R009-FINISH: Program finalisations                            *
      *===============================================================*
       R009-FINISH SECTION.
           MOVE W-LPETA011 TO P-LPETA011
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET011 ADDRESSES             *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT ADDRESSID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET011.ADDRESSID,
                     :DCLTBPET011.CREATEDDATE,
                     :DCLTBPET011.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET011
                     (ADDRESSTYPE,
                      OWNERID,
                      FROMDATE,
                      TODATE,
                      ADDRESSLINE1,
                      ADDRESSLINE2,
                      POSTALCODE,
                      CITY,
                      REGION,
                      COUNTRY,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET011.ADDRESSTYPE,
                     :DCLTBPET011.OWNERID,
                     :DCLTBPET011.FROMDATE
                       :DCLTBPET011.FROMDATE-IND,
                     :DCLTBPET011.TODATE
                       :DCLTBPET011.TODATE-IND,
                     :DCLTBPET011.ADDRESSLINE1
                       :DCLTBPET011.ADDRESSLINE1-IND,
                     :DCLTBPET011.ADDRESSLINE2
                       :DCLTBPET011.ADDRESSLINE2-IND,
                     :DCLTBPET011.POSTALCODE
                       :DCLTBPET011.POSTALCODE-IND,
                     :DCLTBPET011.CITY
                       :DCLTBPET011.CITY-IND,
                     :DCLTBPET011.REGION
                       :DCLTBPET011.REGION-IND,
                     :DCLTBPET011.COUNTRY
                       :DCLTBPET011.COUNTRY-IND,
                     :DCLTBPET011.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET011.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE ADDRESSID   OF DCLTBPET011 TO
                   ADDRESSID   OF W-LPETA011
              MOVE CREATEDDATE OF DCLTBPET011 TO
                   CREATEDDATE OF W-LPETA011
              MOVE UPDATEDDATE OF DCLTBPET011 TO
                   UPDATEDDATE OF W-LPETA011
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETA011
              MOVE N'11' TO REASONCODE OF W-LPETA011
              MOVE N'TBPET011 duplicate entry' TO
                   INFOMESSAGE OF W-LPETA011
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA011
              MOVE N'12' TO REASONCODE OF W-LPETA011
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA011
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET011 ADDRESSES             *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE ADDRESSID OF W-LPETA011 TO ADDRESSID OF DCLTBPET011

           EXEC SQL
              SELECT ADDRESSTYPE,
                     OWNERID,
                     FROMDATE,
                     TODATE,
                     ADDRESSLINE1,
                     ADDRESSLINE2,
                     POSTALCODE,
                     CITY,
                     REGION,
                     COUNTRY,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET011.ADDRESSTYPE,
                     :DCLTBPET011.OWNERID,
                     :DCLTBPET011.FROMDATE
                       :DCLTBPET011.FROMDATE-IND,
                     :DCLTBPET011.TODATE
                       :DCLTBPET011.TODATE-IND,
                     :DCLTBPET011.ADDRESSLINE1
                       :DCLTBPET011.ADDRESSLINE1-IND,
                     :DCLTBPET011.ADDRESSLINE2
                       :DCLTBPET011.ADDRESSLINE2-IND,
                     :DCLTBPET011.POSTALCODE
                       :DCLTBPET011.POSTALCODE-IND,
                     :DCLTBPET011.CITY
                       :DCLTBPET011.CITY-IND,
                     :DCLTBPET011.REGION
                       :DCLTBPET011.REGION-IND,
                     :DCLTBPET011.COUNTRY
                       :DCLTBPET011.COUNTRY-IND,
                     :DCLTBPET011.CREATEDBY,
                     :DCLTBPET011.CREATEDDATE,
                     :DCLTBPET011.UPDATEDBY,
                     :DCLTBPET011.UPDATEDDATE
                FROM TBPET011
               WHERE ADDRESSID = :DCLTBPET011.ADDRESSID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE ADDRESSTYPE OF DCLTBPET011 TO
                   ADDRESSTYPE OF W-LPETA011
              MOVE OWNERID     OF DCLTBPET011 TO
                   OWNERID     OF W-LPETA011
              IF FROMDATE-IND OF DCLTBPET011 < 0
                 MOVE LOW-VALUES TO FROMDATE OF W-LPETA011
              ELSE
                 MOVE FUNCTION NATIONAL-OF(FROMDATE OF DCLTBPET011) TO
                      FROMDATE OF W-LPETA011
              END-IF
              IF TODATE-IND OF DCLTBPET011 < 0
                 MOVE LOW-VALUES TO TODATE OF W-LPETA011
              ELSE
                 MOVE FUNCTION NATIONAL-OF(TODATE OF DCLTBPET011) TO
                      TODATE OF W-LPETA011
              END-IF
              IF ADDRESSLINE1-IND OF DCLTBPET011 < 0
                 MOVE 0 TO ADDRESSLINE1-LEN OF W-LPETA011
                 MOVE LOW-VALUES TO ADDRESSLINE1-TEXT OF W-LPETA011
              ELSE
                 MOVE ADDRESSLINE1 OF DCLTBPET011 TO
                      ADDRESSLINE1 OF W-LPETA011
              END-IF
              IF ADDRESSLINE2-IND OF DCLTBPET011 < 0
                 MOVE 0 TO ADDRESSLINE2-LEN OF W-LPETA011
                 MOVE LOW-VALUES TO ADDRESSLINE2-TEXT OF W-LPETA011
              ELSE
                 MOVE ADDRESSLINE2 OF DCLTBPET011 TO
                      ADDRESSLINE2 OF W-LPETA011
              END-IF
              IF POSTALCODE-IND OF DCLTBPET011 < 0
                 MOVE 0 TO POSTALCODE-LEN OF W-LPETA011
                 MOVE LOW-VALUES TO POSTALCODE-TEXT OF W-LPETA011
              ELSE
                 MOVE POSTALCODE OF DCLTBPET011 TO
                      POSTALCODE OF W-LPETA011
              END-IF
              IF CITY-IND OF DCLTBPET011 < 0
                 MOVE 0 TO CITY-LEN OF W-LPETA011
                 MOVE LOW-VALUES TO CITY-TEXT OF W-LPETA011
              ELSE
                 MOVE CITY OF DCLTBPET011 TO CITY OF W-LPETA011
              END-IF
              IF REGION-IND OF DCLTBPET011 < 0
                 MOVE 0 TO REGION-LEN OF W-LPETA011
                 MOVE LOW-VALUES TO REGION-TEXT OF W-LPETA011
              ELSE
                 MOVE REGION OF DCLTBPET011 TO REGION OF W-LPETA011
              END-IF
              IF COUNTRY-IND OF DCLTBPET011 < 0
                 MOVE 0 TO COUNTRY-LEN OF W-LPETA011
                 MOVE LOW-VALUES TO COUNTRY-TEXT OF W-LPETA011
              ELSE
                 MOVE COUNTRY OF DCLTBPET011 TO COUNTRY OF W-LPETA011
              END-IF
              MOVE CREATEDBY   OF DCLTBPET011 TO
                   CREATEDBY   OF W-LPETA011
              MOVE CREATEDDATE OF DCLTBPET011 TO
                   CREATEDDATE OF W-LPETA011
              MOVE UPDATEDBY   OF DCLTBPET011 TO
                   UPDATEDBY   OF W-LPETA011
              MOVE UPDATEDDATE OF DCLTBPET011 TO
                   UPDATEDDATE OF W-LPETA011
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETA011
                MOVE N'01' TO REASONCODE OF W-LPETA011
                MOVE N'TBPET011 entry not found' TO
                   INFOMESSAGE OF W-LPETA011
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETA011
                MOVE N'21' TO REASONCODE OF W-LPETA011
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETA011
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END. 
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET011 ADDRESSES               *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT UPDATEDDATE
                INTO :DCLTBPET011.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET011
                 SET ADDRESSTYPE    = :DCLTBPET011.ADDRESSTYPE,
                     OWNERID        = :DCLTBPET011.OWNERID,
                     FROMDATE       = :DCLTBPET011.FROMDATE
                                        :DCLTBPET011.FROMDATE-IND,
                     TODATE         = :DCLTBPET011.TODATE
                                        :DCLTBPET011.TODATE-IND,
                     ADDRESSLINE1   = :DCLTBPET011.ADDRESSLINE1
                                        :DCLTBPET011.ADDRESSLINE1-IND,
                     ADDRESSLINE2   = :DCLTBPET011.ADDRESSLINE2
                                        :DCLTBPET011.ADDRESSLINE2-IND,
                     POSTALCODE     = :DCLTBPET011.POSTALCODE
                                        :DCLTBPET011.POSTALCODE-IND,
                     CITY           = :DCLTBPET011.CITY
                                        :DCLTBPET011.CITY-IND,
                     REGION         = :DCLTBPET011.REGION
                                        :DCLTBPET011.REGION-IND,
                     COUNTRY        = :DCLTBPET011.COUNTRY
                                        :DCLTBPET011.COUNTRY-IND,
                     UPDATEDBY      = :DCLTBPET011.UPDATEDBY,
                     UPDATEDDATE    = CURRENT TIMESTAMP
               WHERE ADDRESSID = :DCLTBPET011.ADDRESSID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE UPDATEDDATE OF DCLTBPET011 TO
                   UPDATEDDATE OF W-LPETA011
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETA011
              MOVE N'31' TO REASONCODE OF W-LPETA011
              MOVE N'TBPET011 entry not found' TO
                   INFOMESSAGE OF W-LPETA011 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA011
              MOVE N'32' TO REASONCODE OF W-LPETA011
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA011
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END. 
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET011 ADDRESSES             *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE ADDRESSID OF W-LPETA011 TO ADDRESSID OF DCLTBPET011

           EXEC SQL
              DELETE
                FROM TBPET011
               WHERE ADDRESSID = :DCLTBPET011.ADDRESSID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETA011
              MOVE N'41' TO REASONCODE OF W-LPETA011
              MOVE N'TBPET011 entry not found' TO
                   INFOMESSAGE OF W-LPETA011
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA011
              MOVE N'42' TO REASONCODE OF W-LPETA011
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA011
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END. 
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET011           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE ADDRESSTYPE OF W-LPETA011 TO ADDRESSTYPE OF DCLTBPET011
           MOVE OWNERID     OF W-LPETA011 TO OWNERID     OF DCLTBPET011
           IF FROMDATE OF W-LPETA011 = SPACES
           OR FROMDATE OF W-LPETA011 = LOW-VALUES
              MOVE -1 TO FROMDATE-IND OF DCLTBPET011
              MOVE LOW-VALUES TO FROMDATE OF DCLTBPET011
           ELSE
              MOVE 0 TO FROMDATE-IND OF DCLTBPET011
              MOVE FUNCTION DISPLAY-OF(FROMDATE OF W-LPETA011) TO
                   FROMDATE OF DCLTBPET011
           END-IF
           IF TODATE OF W-LPETA011 = SPACES
           OR TODATE OF W-LPETA011 = LOW-VALUES
              MOVE -1 TO TODATE-IND OF DCLTBPET011
              MOVE LOW-VALUES TO TODATE OF DCLTBPET011
           ELSE
              MOVE 0 TO TODATE-IND OF DCLTBPET011
              MOVE FUNCTION DISPLAY-OF(TODATE OF W-LPETA011) TO
                   TODATE OF DCLTBPET011
           END-IF
           IF ADDRESSLINE1-LEN OF W-LPETA011 = 0
           OR ADDRESSLINE1-TEXT OF W-LPETA011(1:
                ADDRESSLINE1-LEN OF W-LPETA011) = SPACES
           OR ADDRESSLINE1-TEXT OF W-LPETA011(1:
                ADDRESSLINE1-LEN OF W-LPETA011) = LOW-VALUES
              MOVE -1 TO ADDRESSLINE1-IND OF DCLTBPET011
              MOVE 0 TO ADDRESSLINE1-LEN OF DCLTBPET011
              MOVE LOW-VALUES TO ADDRESSLINE1-TEXT OF DCLTBPET011
           ELSE
              MOVE 0 TO ADDRESSLINE1-IND OF DCLTBPET011
              MOVE ADDRESSLINE1 OF W-LPETA011 TO
                   ADDRESSLINE1 OF DCLTBPET011
           END-IF
           IF ADDRESSLINE2-LEN OF W-LPETA011 = 0
           OR ADDRESSLINE2-TEXT OF W-LPETA011(1:
                ADDRESSLINE2-LEN OF W-LPETA011) = SPACES
           OR ADDRESSLINE2-TEXT OF W-LPETA011(1:
                ADDRESSLINE2-LEN OF W-LPETA011) = LOW-VALUES
              MOVE -1 TO ADDRESSLINE2-IND OF DCLTBPET011
              MOVE 0 TO ADDRESSLINE2-LEN OF DCLTBPET011
              MOVE LOW-VALUES TO ADDRESSLINE2-TEXT OF DCLTBPET011
           ELSE
              MOVE 0 TO ADDRESSLINE2-IND OF DCLTBPET011
              MOVE ADDRESSLINE2 OF W-LPETA011 TO
                   ADDRESSLINE2 OF DCLTBPET011
           END-IF
           IF POSTALCODE-LEN OF W-LPETA011 = 0
           OR POSTALCODE-TEXT OF W-LPETA011(1:
                POSTALCODE-LEN OF W-LPETA011) = SPACES
           OR POSTALCODE-TEXT OF W-LPETA011(1:
                POSTALCODE-LEN OF W-LPETA011) = LOW-VALUES
              MOVE -1 TO POSTALCODE-IND OF DCLTBPET011
              MOVE 0 TO POSTALCODE-LEN OF DCLTBPET011
              MOVE LOW-VALUES TO POSTALCODE-TEXT OF DCLTBPET011
           ELSE
              MOVE 0 TO POSTALCODE-IND OF DCLTBPET011
              MOVE POSTALCODE OF W-LPETA011 TO POSTALCODE OF DCLTBPET011
           END-IF
           IF CITY-LEN OF W-LPETA011 = 0
           OR CITY-TEXT OF W-LPETA011(1:CITY-LEN OF W-LPETA011) = SPACES
           OR CITY-TEXT OF W-LPETA011(1:CITY-LEN OF W-LPETA011) =
                LOW-VALUES
              MOVE -1 TO CITY-IND OF DCLTBPET011
              MOVE 0 TO CITY-LEN OF DCLTBPET011
              MOVE LOW-VALUES TO CITY-TEXT OF DCLTBPET011
           ELSE
              MOVE 0 TO CITY-IND OF DCLTBPET011
              MOVE CITY OF W-LPETA011 TO CITY OF DCLTBPET011
           END-IF
           IF REGION-LEN OF W-LPETA011 = 0
           OR REGION-TEXT OF W-LPETA011(1:REGION-LEN OF W-LPETA011) =
                SPACES
           OR REGION-TEXT OF W-LPETA011(1:REGION-LEN OF W-LPETA011) =
                LOW-VALUES
              MOVE -1 TO REGION-IND OF DCLTBPET011
              MOVE 0 TO REGION-LEN OF DCLTBPET011
              MOVE LOW-VALUES TO REGION-TEXT OF DCLTBPET011
           ELSE
              MOVE 0 TO REGION-IND OF DCLTBPET011
              MOVE REGION OF W-LPETA011 TO REGION OF DCLTBPET011
           END-IF
           IF COUNTRY-LEN OF W-LPETA011 = 0
           OR COUNTRY-TEXT OF W-LPETA011(1:
                COUNTRY-LEN OF W-LPETA011) = SPACES
           OR COUNTRY-TEXT OF W-LPETA011(1:
                COUNTRY-LEN OF W-LPETA011) = LOW-VALUES
              MOVE -1 TO COUNTRY-IND OF DCLTBPET011
              MOVE 0 TO COUNTRY-LEN OF DCLTBPET011
              MOVE LOW-VALUES TO COUNTRY-TEXT OF DCLTBPET011
           ELSE
              MOVE 0 TO COUNTRY-IND OF DCLTBPET011
              MOVE COUNTRY OF W-LPETA011 TO COUNTRY OF DCLTBPET011
           END-IF
           MOVE CREATEDBY    OF W-LPETA011 TO CREATEDBY   OF DCLTBPET011
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETA011) TO
              CREATEDDATE OF DCLTBPET011
           MOVE UPDATEDBY    OF W-LPETA011 TO UPDATEDBY   OF DCLTBPET011
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETA011) TO
              UPDATEDDATE OF DCLTBPET011
           .
       R210-COPY-TO-DCL-END. 
           EXIT.

      *===============================================================*
      * R900-DSNTIAR: Format SQLCA information to display when error  *
      *===============================================================*
       R900-DSNTIAR SECTION.
           CALL 'DSNTIAR' USING SQLCA ERROR-MESSAGE ERROR-TEXT-LEN

           PERFORM VARYING ERROR-INDEX
              FROM 1 BY 1 UNTIL ERROR-INDEX = 10
                   DISPLAY ERROR-TEXT(ERROR-INDEX)
           END-PERFORM
           .
       R900-DSNTIAR-END. 
           EXIT.

       END PROGRAM PETA011.