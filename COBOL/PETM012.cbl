       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM012
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET012 CONTACTINFOS table.                                  *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET012                           *
      *   TBPET012 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: CONTACTINFOID required                     *
      *     08 03 = Error: CONTACTINFOTYPE required                   *
      *     08 04 = Error: OWNERTYPE required                         *
      *     08 05 = Error: OWNERID required                           *
      *     08 06 = Error: CONTACTDATA required                       *
      *     08 11 = Error: INSERT of duplicate key                    *
      *     08 12 = Error: SQL error in INSERT                        *
      *     08 21 = Error: SQL error in SELECT                        *
      *     08 31 = Error: UPDATE of non existing key                 *
      *     08 32 = Error: SQL error in UPDATE                        *
      *     08 41 = Error: DELETE of non existing key                 *
      *     08 42 = Error: SQL error in DELETE                        *
      *     08 90 = Error: PETA990 returned non-zero                  *
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

           EXEC SQL INCLUDE TBPET012 END-EXEC.

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

       01 W-LPETM012.
           COPY LPETM012.

       01 W-LPETA990.
           COPY LPETA990.

       LINKAGE SECTION.
       01 P-LPETM012.
           COPY LPETM012.

       PROCEDURE DIVISION USING P-LPETM012.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM012 = N'00'
              EVALUATE OPCODE OF W-LPETM012
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
           MOVE P-LPETM012 TO W-LPETM012

           MOVE N'00' TO RETURNCODE OF W-LPETM012
           MOVE N'00' TO REASONCODE OF W-LPETM012
           MOVE SPACES TO INFOMESSAGE OF W-LPETM012
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM012 NOT = N'C'
           AND OPCODE OF W-LPETM012 NOT = N'R'
           AND OPCODE OF W-LPETM012 NOT = N'U'
           AND OPCODE OF W-LPETM012 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM012
              MOVE N'01' TO REASONCODE OF W-LPETM012
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM012
           END-IF

           IF OPCODE OF W-LPETM012 NOT = N'C'
              IF  RETURNCODE OF W-LPETM012 = N'00'
              AND CONTACTINFOID OF W-LPETM012 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM012
                 MOVE N'02' TO REASONCODE OF W-LPETM012
                 MOVE N'CONTACTINFOID is required' TO
                      INFOMESSAGE OF W-LPETM012
              END-IF
           END-IF

           IF OPCODE OF W-LPETM012 = N'C'
           OR OPCODE OF W-LPETM012 = N'U'
              IF   RETURNCODE OF W-LPETM012 = N'00'
              AND (CONTACTINFOTYPE OF W-LPETM012 = SPACES
              OR   CONTACTINFOTYPE OF W-LPETM012 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM012
                 MOVE N'03' TO REASONCODE OF W-LPETM012
                 MOVE N'CONTACTINFOTYPE is required' TO
                      INFOMESSAGE OF W-LPETM012
              END-IF

              IF   RETURNCODE OF W-LPETM012 = N'00'
              AND (OWNERTYPE OF W-LPETM012 = SPACES
              OR   OWNERTYPE OF W-LPETM012 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM012
                 MOVE N'04' TO REASONCODE OF W-LPETM012
                 MOVE N'OWNERTYPE is required' TO
                      INFOMESSAGE OF W-LPETM012
              END-IF

              IF  RETURNCODE OF W-LPETM012 = N'00'
              AND OWNERID OF W-LPETM012 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM012
                 MOVE N'05' TO REASONCODE OF W-LPETM012
                 MOVE N'OWNERID is required' TO
                      INFOMESSAGE OF W-LPETM012
              END-IF

              IF   RETURNCODE OF W-LPETM012 = N'00'
              AND (CONTACTDATA-LEN OF W-LPETM012 = 0
              OR   CONTACTDATA-TEXT OF W-LPETM012(1:
                      CONTACTDATA-LEN OF W-LPETM012) = SPACES
              OR   CONTACTDATA-TEXT OF W-LPETM012(1:
                      CONTACTDATA-LEN OF W-LPETM012) = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM012
                 MOVE N'06' TO REASONCODE OF W-LPETM012
                 MOVE N'CONTACTDATA is required' TO
                      INFOMESSAGE OF W-LPETM012
              END-IF

              IF CREATEDBY OF W-LPETM012 = SPACES
              OR CREATEDBY OF W-LPETM012 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM012 = SPACES
              OR UPDATEDBY OF W-LPETM012 = LOW-VALUES
                 MOVE 'PETA990' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA990

                 IF RETURNCODE OF W-LPETA990 = N'00'
                    IF CREATEDBY OF W-LPETM012 = SPACES
                    OR CREATEDBY OF W-LPETM012 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            CREATEDBY OF W-LPETM012
                    END-IF

                    IF UPDATEDBY OF W-LPETM012 = SPACES
                    OR UPDATEDBY OF W-LPETM012 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            UPDATEDBY OF W-LPETM012
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM012
                    MOVE N'90' TO REASONCODE OF W-LPETM012
                    MOVE INFOMESSAGE OF W-LPETA990 TO
                         INFOMESSAGE OF W-LPETM012
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
           MOVE W-LPETM012 TO P-LPETM012
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET012 CONTACTINFOS          *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CONTACTINFOID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET012.CONTACTINFOID,
                     :DCLTBPET012.CREATEDDATE,
                     :DCLTBPET012.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET012
                     (CONTACTINFOTYPE,
                      OWNERTYPE,
                      OWNERID,
                      CONTACTDATA,
                      FROMDATE,
                      TODATE,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET012.CONTACTINFOTYPE,
                     :DCLTBPET012.OWNERTYPE,
                     :DCLTBPET012.OWNERID,
                     :DCLTBPET012.CONTACTDATA
                       :DCLTBPET012.CONTACTDATA-IND,
                     :DCLTBPET012.FROMDATE
                       :DCLTBPET012.FROMDATE-IND,
                     :DCLTBPET012.TODATE
                       :DCLTBPET012.TODATE-IND,
                     :DCLTBPET012.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET012.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CONTACTINFOID OF DCLTBPET012 TO
                   CONTACTINFOID OF W-LPETM012
              MOVE CREATEDDATE   OF DCLTBPET012 TO
                   CREATEDDATE   OF W-LPETM012
              MOVE UPDATEDDATE   OF DCLTBPET012 TO
                   UPDATEDDATE   OF W-LPETM012
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM012
              MOVE N'11' TO REASONCODE OF W-LPETM012
              MOVE N'TBPET012 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM012
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM012
              MOVE N'12' TO REASONCODE OF W-LPETM012
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM012
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET012 CONTACTINFOS          *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE CONTACTINFOID OF W-LPETM012 TO
                CONTACTINFOID OF DCLTBPET012

           EXEC SQL
              SELECT CONTACTINFOTYPE,
                     OWNERTYPE,
                     OWNERID,
                     CONTACTDATA,
                     FROMDATE,
                     TODATE,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET012.CONTACTINFOTYPE,
                     :DCLTBPET012.OWNERTYPE,
                     :DCLTBPET012.OWNERID,
                     :DCLTBPET012.CONTACTDATA
                       :DCLTBPET012.CONTACTDATA-IND,
                     :DCLTBPET012.FROMDATE
                       :DCLTBPET012.FROMDATE-IND,
                     :DCLTBPET012.TODATE
                       :DCLTBPET012.TODATE-IND,
                     :DCLTBPET012.CREATEDBY,
                     :DCLTBPET012.CREATEDDATE,
                     :DCLTBPET012.UPDATEDBY,
                     :DCLTBPET012.UPDATEDDATE
                FROM TBPET012
               WHERE CONTACTINFOID = :DCLTBPET012.CONTACTINFOID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CONTACTINFOTYPE OF DCLTBPET012 TO
                   CONTACTINFOTYPE OF W-LPETM012
              MOVE OWNERTYPE       OF DCLTBPET012 TO
                   OWNERTYPE       OF W-LPETM012
              MOVE OWNERID         OF DCLTBPET012 TO
                   OWNERID         OF W-LPETM012
              IF CONTACTDATA-IND OF DCLTBPET012 < 0
                 MOVE 0 TO CONTACTDATA-LEN OF W-LPETM012
                 MOVE LOW-VALUES TO CONTACTDATA-TEXT OF W-LPETM012
              ELSE
                 MOVE CONTACTDATA OF DCLTBPET012 TO
                      CONTACTDATA OF W-LPETM012
              END-IF
              IF FROMDATE-IND OF DCLTBPET012 < 0
                 MOVE LOW-VALUES TO FROMDATE OF W-LPETM012
              ELSE
                 MOVE FUNCTION NATIONAL-OF(FROMDATE OF DCLTBPET012) TO
                      FROMDATE OF W-LPETM012
              END-IF
              IF TODATE-IND OF DCLTBPET012 < 0
                 MOVE LOW-VALUES TO TODATE OF W-LPETM012
              ELSE
                 MOVE FUNCTION NATIONAL-OF(TODATE OF DCLTBPET012) TO
                      TODATE OF W-LPETM012
              END-IF
              MOVE CREATEDBY   OF DCLTBPET012 TO
                   CREATEDBY   OF W-LPETM012
              MOVE CREATEDDATE OF DCLTBPET012 TO
                   CREATEDDATE OF W-LPETM012
              MOVE UPDATEDBY   OF DCLTBPET012 TO
                   UPDATEDBY   OF W-LPETM012
              MOVE UPDATEDDATE OF DCLTBPET012 TO
                   UPDATEDDATE OF W-LPETM012
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM012
                MOVE N'01' TO REASONCODE OF W-LPETM012
                MOVE N'TBPET012 entry not found' TO
                   INFOMESSAGE OF W-LPETM012
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM012
                MOVE N'21' TO REASONCODE OF W-LPETM012
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM012
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END.
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET012 CONTACTINFOS            *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT UPDATEDDATE
                INTO :DCLTBPET012.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET012
                 SET CONTACTINFOTYPE = :DCLTBPET012.CONTACTINFOTYPE,
                     OWNERTYPE       = :DCLTBPET012.OWNERTYPE,
                     OWNERID         = :DCLTBPET012.OWNERID,
                     CONTACTDATA     = :DCLTBPET012.CONTACTDATA
                                         :DCLTBPET012.CONTACTDATA-IND,
                     FROMDATE        = :DCLTBPET012.FROMDATE
                                         :DCLTBPET012.FROMDATE-IND,
                     TODATE          = :DCLTBPET012.TODATE
                                         :DCLTBPET012.TODATE-IND,
                     UPDATEDBY      = :DCLTBPET012.UPDATEDBY,
                     UPDATEDDATE    = CURRENT TIMESTAMP
               WHERE CONTACTINFOID = :DCLTBPET012.CONTACTINFOID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE UPDATEDDATE OF DCLTBPET012 TO
                   UPDATEDDATE OF W-LPETM012
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM012
              MOVE N'31' TO REASONCODE OF W-LPETM012
              MOVE N'TBPET012 entry not found' TO
                   INFOMESSAGE OF W-LPETM012
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM012
              MOVE N'32' TO REASONCODE OF W-LPETM012
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM012
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END.
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET012 CONTACTINFOS          *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE CONTACTINFOID OF W-LPETM012 TO
                CONTACTINFOID OF DCLTBPET012

           EXEC SQL
              DELETE
                FROM TBPET012
               WHERE CONTACTINFOID = :DCLTBPET012.CONTACTINFOID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM012
              MOVE N'41' TO REASONCODE OF W-LPETM012
              MOVE N'TBPET012 entry not found' TO
                   INFOMESSAGE OF W-LPETM012
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM012
              MOVE N'42' TO REASONCODE OF W-LPETM012
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM012
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END.
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET012           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE CONTACTINFOTYPE OF W-LPETM012 TO
                CONTACTINFOTYPE OF DCLTBPET012
           MOVE OWNERTYPE OF W-LPETM012 TO OWNERTYPE OF DCLTBPET012
           MOVE OWNERID   OF W-LPETM012 TO OWNERID   OF DCLTBPET012
           IF CONTACTDATA-LEN OF W-LPETM012 = 0
           OR CONTACTDATA-TEXT OF W-LPETM012(1:
                CONTACTDATA-LEN OF W-LPETM012) = SPACES
           OR CONTACTDATA-TEXT OF W-LPETM012(1:
                CONTACTDATA-LEN OF W-LPETM012) = LOW-VALUES
              MOVE -1 TO CONTACTDATA-IND OF DCLTBPET012
              MOVE 0 TO CONTACTDATA-LEN OF DCLTBPET012
              MOVE LOW-VALUES TO CONTACTDATA-TEXT OF DCLTBPET012
           ELSE
              MOVE 0 TO CONTACTDATA-IND OF DCLTBPET012
              MOVE CONTACTDATA OF W-LPETM012 TO
                   CONTACTDATA OF DCLTBPET012
           END-IF
           IF FROMDATE OF W-LPETM012 = SPACES
           OR FROMDATE OF W-LPETM012 = LOW-VALUES
              MOVE -1 TO FROMDATE-IND OF DCLTBPET012
              MOVE LOW-VALUES TO FROMDATE OF DCLTBPET012
           ELSE
              MOVE 0 TO FROMDATE-IND OF DCLTBPET012
              MOVE FUNCTION DISPLAY-OF(FROMDATE OF W-LPETM012) TO
                   FROMDATE OF DCLTBPET012
           END-IF
           IF TODATE OF W-LPETM012 = SPACES
           OR TODATE OF W-LPETM012 = LOW-VALUES
              MOVE -1 TO TODATE-IND OF DCLTBPET012
              MOVE LOW-VALUES TO TODATE OF DCLTBPET012
           ELSE
              MOVE 0 TO TODATE-IND OF DCLTBPET012
              MOVE FUNCTION DISPLAY-OF(TODATE OF W-LPETM012) TO
                   TODATE OF DCLTBPET012
           END-IF
           MOVE CREATEDBY    OF W-LPETM012 TO CREATEDBY   OF DCLTBPET012
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM012) TO
              CREATEDDATE OF DCLTBPET012
           MOVE UPDATEDBY    OF W-LPETM012 TO UPDATEDBY   OF DCLTBPET012
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM012) TO
              UPDATEDDATE OF DCLTBPET012
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

       END PROGRAM PETM012.
