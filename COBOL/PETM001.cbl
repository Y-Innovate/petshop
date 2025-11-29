       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM001
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET001 REFTABLES table.                                     *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET001                           *
      *   TBPET001 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: TABLEID required                           *
      *     08 03 = Error: TABKEY required                            *
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

           EXEC SQL INCLUDE TBPET001 END-EXEC.

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

       01 W-LPETM001.
           COPY LPETM001.

       01 W-LPETA900.
           COPY LPETA900.

       LINKAGE SECTION.
       01 P-LPETM001.
           COPY LPETM001.

       PROCEDURE DIVISION USING P-LPETM001.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM001 = N'00'
              EVALUATE OPCODE OF W-LPETM001
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
           MOVE P-LPETM001 TO W-LPETM001

           MOVE N'00' TO RETURNCODE OF W-LPETM001
           MOVE N'00' TO REASONCODE OF W-LPETM001
           MOVE SPACES TO INFOMESSAGE OF W-LPETM001
           .
       R001-INIT-END. 
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM001 NOT = N'C'
           AND OPCODE OF W-LPETM001 NOT = N'R'
           AND OPCODE OF W-LPETM001 NOT = N'U'
           AND OPCODE OF W-LPETM001 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'01' TO REASONCODE OF W-LPETM001
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM001
           END-IF

           IF  RETURNCODE OF W-LPETM001 = N'00'
           AND TABLEID OF W-LPETM001 = SPACES
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'02' TO REASONCODE OF W-LPETM001
              MOVE N'TABLEID is required' TO INFOMESSAGE OF W-LPETM001
           END-IF

           IF  RETURNCODE OF W-LPETM001 = N'00'
           AND TABKEY OF W-LPETM001 = SPACES
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'03' TO REASONCODE OF W-LPETM001
              MOVE N'TABKEY' TO INFOMESSAGE OF W-LPETM001
           END-IF

           IF OPCODE OF W-LPETM001 = N'C'
           OR OPCODE OF W-LPETM001 = N'U'
              IF CREATEDBY OF W-LPETM001 = SPACES
              OR CREATEDBY OF W-LPETM001 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM001 = SPACES
              OR UPDATEDBY OF W-LPETM001 = LOW-VALUES
                 MOVE 'PETA900' TO W-PGMNAME
                 
                 CALL W-PGMNAME USING W-LPETA900

                 IF RETURNCODE OF W-LPETA900 = N'00'
                    IF CREATEDBY OF W-LPETM001 = SPACES
                    OR CREATEDBY OF W-LPETM001 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            CREATEDBY OF W-LPETM001
                    END-IF

                    IF UPDATEDBY OF W-LPETM001 = SPACES
                    OR UPDATEDBY OF W-LPETM001 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            UPDATEDBY OF W-LPETM001
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM001
                    MOVE N'90' TO REASONCODE OF W-LPETM001
                    MOVE INFOMESSAGE OF W-LPETA900 TO
                         INFOMESSAGE OF W-LPETM001
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
           MOVE W-LPETM001 TO P-LPETM001
           .
       R009-FINISH-END. 
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET001 REFTABLES             *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET001.CREATEDDATE,
                     :DCLTBPET001.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET001
                     (TABLEID,
                      TABKEY,
                      TABVALUE,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET001.TABLEID,
                     :DCLTBPET001.TABKEY,
                     :DCLTBPET001.TABVALUE
                       :DCLTBPET001.TABVALUE-IND,
                     :DCLTBPET001.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET001.UPDATEDBY,
                     CURRENT_TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CREATEDDATE OF DCLTBPET001 TO
                   CREATEDDATE OF W-LPETM001
              MOVE UPDATEDDATE OF DCLTBPET001 TO
                   UPDATEDDATE OF W-LPETM001
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'11' TO REASONCODE OF W-LPETM001
              MOVE N'TBPET001 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM001 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'12' TO REASONCODE OF W-LPETM001
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM001
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END. 
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET001 REFTABLES             *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE TABLEID OF W-LPETM001 TO TABLEID OF DCLTBPET001
           MOVE TABKEY OF W-LPETM001 TO TABKEY OF DCLTBPET001

           EXEC SQL
              SELECT TABVALUE,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET001.TABVALUE
                       :DCLTBPET001.TABVALUE-IND,
                     :DCLTBPET001.CREATEDBY,
                     :DCLTBPET001.CREATEDDATE,
                     :DCLTBPET001.UPDATEDBY,
                     :DCLTBPET001.UPDATEDDATE
                FROM TBPET001
               WHERE TABLEID = :DCLTBPET001.TABLEID
                 AND TABKEY = :DCLTBPET001.TABKEY
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              IF TABVALUE-IND OF DCLTBPET001 < 0
                 MOVE LOW-VALUES TO TABVALUE OF W-LPETM001
              ELSE
                 MOVE TABVALUE OF DCLTBPET001 TO
                      TABVALUE OF W-LPETM001
              END-IF
              MOVE CREATEDBY   OF DCLTBPET001 TO
                   CREATEDBY   OF W-LPETM001
              MOVE CREATEDDATE OF DCLTBPET001 TO
                   CREATEDDATE OF W-LPETM001
              MOVE UPDATEDBY   OF DCLTBPET001 TO
                   UPDATEDBY   OF W-LPETM001
              MOVE UPDATEDDATE OF DCLTBPET001 TO
                   UPDATEDDATE OF W-LPETM001
           WHEN 100
              MOVE N'04' TO RETURNCODE OF W-LPETM001
              MOVE N'01' TO REASONCODE OF W-LPETM001
              MOVE N'TBPET001 entry not found' TO
                   INFOMESSAGE OF W-LPETM001 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'21' TO REASONCODE OF W-LPETM001
              STRING N'SELECT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM001
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END. 
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET001 REFTABLES               *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET001.CREATEDDATE,
                     :DCLTBPET001.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET001
                 SET TABVALUE    = :DCLTBPET001.TABVALUE
                                     :DCLTBPET001.TABVALUE-IND,
                     UPDATEDBY   = :DCLTBPET001.UPDATEDBY,
                     UPDATEDDATE = CURRENT TIMESTAMP
               WHERE TABLEID = :DCLTBPET001.TABLEID
                 AND TABKEY  = :DCLTBPET001.TABKEY
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CREATEDDATE OF DCLTBPET001 TO
                   CREATEDDATE OF W-LPETM001
              MOVE UPDATEDDATE OF DCLTBPET001 TO
                   UPDATEDDATE OF W-LPETM001 
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'31' TO REASONCODE OF W-LPETM001
              MOVE N'TBPET001 entry not found' TO
                   INFOMESSAGE OF W-LPETM001 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'32' TO REASONCODE OF W-LPETM001
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM001
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END. 
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET001 REFTABLES             *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE TABLEID OF W-LPETM001 TO TABLEID OF DCLTBPET001
           MOVE TABKEY OF W-LPETM001 TO TABKEY OF DCLTBPET001

           EXEC SQL
              DELETE
                FROM TBPET001
               WHERE TABLEID = :DCLTBPET001.TABLEID
                 AND TABKEY = :DCLTBPET001.TABKEY
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'41' TO REASONCODE OF W-LPETM001
              MOVE N'TBPET001 entry not found' TO
                   INFOMESSAGE OF W-LPETM001 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM001
              MOVE N'42' TO REASONCODE OF W-LPETM001
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM001
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END. 
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET001           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE TABLEID OF W-LPETM001 TO TABLEID OF DCLTBPET001
           MOVE TABKEY  OF W-LPETM001 TO TABKEY  OF DCLTBPET001
           IF TABVALUE OF W-LPETM001 = LOW-VALUES
              MOVE -1 TO TABVALUE-IND OF DCLTBPET001
              MOVE LOW-VALUES TO TABVALUE OF DCLTBPET001
           ELSE
              MOVE 0 TO TABVALUE-IND OF DCLTBPET001
              MOVE TABVALUE  OF W-LPETM001 TO TABVALUE OF DCLTBPET001
           END-IF
           MOVE CREATEDBY OF W-LPETM001 TO CREATEDBY OF DCLTBPET001
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM001) TO
              CREATEDDATE OF DCLTBPET001
           MOVE UPDATEDBY OF W-LPETM001 TO UPDATEDBY OF DCLTBPET001
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM001) TO
              UPDATEDDATE OF DCLTBPET001
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

       END PROGRAM PETM001.