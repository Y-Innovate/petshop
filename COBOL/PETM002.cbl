       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM002
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET002 STORES table.                                        *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET002                           *
      *   TBPET002 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: STOREID required                           *
      *     08 03 = Error: STORECODE required                         *
      *     08 04 = Error: STORESTATUS required                       *
      *     08 05 = Error: STORENAMEU required                        *
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

           EXEC SQL INCLUDE TBPET002 END-EXEC.

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

       01 W-LPETM002.
           COPY LPETM002.

       01 W-LPETA900.
           COPY LPETA900.

       LINKAGE SECTION.
       01 P-LPETM002.
           COPY LPETM002.

       PROCEDURE DIVISION USING P-LPETM002.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM002 = N'00'
              EVALUATE OPCODE OF W-LPETM002
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
           MOVE P-LPETM002 TO W-LPETM002

           MOVE N'00' TO RETURNCODE OF W-LPETM002
           MOVE N'00' TO REASONCODE OF W-LPETM002
           MOVE SPACES TO INFOMESSAGE OF W-LPETM002
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM002 NOT = N'C'
           AND OPCODE OF W-LPETM002 NOT = N'R'
           AND OPCODE OF W-LPETM002 NOT = N'U'
           AND OPCODE OF W-LPETM002 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM002
              MOVE N'01' TO REASONCODE OF W-LPETM002
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM002
           END-IF

           IF  OPCODE OF W-LPETM002 NOT = N'C'
           AND OPCODE OF W-LPETM002 NOT = N'R'
              IF  RETURNCODE OF W-LPETM002 = N'00'
              AND STOREID OF W-LPETM002 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM002
                 MOVE N'02' TO REASONCODE OF W-LPETM002
                 MOVE N'STOREID is required' TO
                      INFOMESSAGE OF W-LPETM002
              END-IF
           END-IF

           IF OPCODE OF W-LPETM002 = N'R'
              IF   RETURNCODE OF W-LPETM002 = N'00'
              AND  STOREID    OF W-LPETM002 = 0
              AND (STORECODE  OF W-LPETM002 = SPACES
              OR   STORECODE  OF W-LPETM002 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM002
                 MOVE N'03' TO REASONCODE OF W-LPETM002
                 MOVE N'STORECODE is required' TO
                      INFOMESSAGE OF W-LPETM002
              END-IF
           END-IF

           IF OPCODE OF W-LPETM002 = N'C'
           OR OPCODE OF W-LPETM002 = N'U'
              IF  RETURNCODE OF W-LPETM002 = N'00'
              AND STORECODE OF W-LPETM002 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM002
                 MOVE N'03' TO REASONCODE OF W-LPETM002
                 MOVE N'STORECODE is required' TO
                      INFOMESSAGE OF W-LPETM002
              END-IF

              IF  RETURNCODE OF W-LPETM002 = N'00'
              AND STORESTATUS OF W-LPETM002 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM002
                 MOVE N'04' TO REASONCODE OF W-LPETM002
                 MOVE N'STORESTATUS is required' TO
                      INFOMESSAGE OF W-LPETM002
              END-IF

              IF   RETURNCODE OF W-LPETM002 = N'00'
              AND (STORENAME-LEN OF W-LPETM002 = 0
              OR   STORENAME-TEXT OF W-LPETM002 (1:
                      STORENAME-LEN OF W-LPETM002) = SPACES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM002
                 MOVE N'05' TO REASONCODE OF W-LPETM002
                 MOVE N'STORENAME is required' TO
                      INFOMESSAGE OF W-LPETM002
              END-IF

              IF CREATEDBY OF W-LPETM002 = SPACES
              OR CREATEDBY OF W-LPETM002 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM002 = SPACES
              OR UPDATEDBY OF W-LPETM002 = LOW-VALUES
                 MOVE 'PETA900' TO W-PGMNAME
                 
                 CALL W-PGMNAME USING W-LPETA900

                 IF RETURNCODE OF W-LPETA900 = N'00'
                    IF CREATEDBY OF W-LPETM002 = SPACES
                    OR CREATEDBY OF W-LPETM002 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            CREATEDBY OF W-LPETM002
                    END-IF

                    IF UPDATEDBY OF W-LPETM002 = SPACES
                    OR UPDATEDBY OF W-LPETM002 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            UPDATEDBY OF W-LPETM002
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM002
                    MOVE N'90' TO REASONCODE OF W-LPETM002
                    MOVE INFOMESSAGE OF W-LPETA900 TO
                         INFOMESSAGE OF W-LPETM002
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
           MOVE W-LPETM002 TO P-LPETM002
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET002 STORES                *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT STOREID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET002.STOREID,
                     :DCLTBPET002.CREATEDDATE,
                     :DCLTBPET002.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET002
                     (STORECODE,
                      STORESTATUS,
                      STORENAME,
                      STORENAMEU,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET002.STORECODE,
                     :DCLTBPET002.STORESTATUS,
                     :DCLTBPET002.STORENAME,
                     :DCLTBPET002.STORENAMEU,
                     :DCLTBPET002.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET002.UPDATEDBY,
                     CURRENT_TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE STOREID     OF DCLTBPET002 TO STOREID OF W-LPETM002
              MOVE CREATEDDATE OF DCLTBPET002 TO
                   CREATEDDATE OF W-LPETM002
              MOVE UPDATEDDATE OF DCLTBPET002 TO
                   UPDATEDDATE OF W-LPETM002
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM002
              MOVE N'11' TO REASONCODE OF W-LPETM002
              MOVE N'TBPET002 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM002
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM002
              MOVE N'12' TO REASONCODE OF W-LPETM002
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM002
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET002 STORES                *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE STOREID   OF W-LPETM002 TO STOREID   OF DCLTBPET002
           MOVE STORECODE OF W-LPETM002 TO STORECODE OF DCLTBPET002

           EXEC SQL
              SELECT STOREID,
                     STORECODE,
                     STORESTATUS,
                     STORENAME,
                     STORENAMEU,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET002.STOREID,
                     :DCLTBPET002.STORECODE,
                     :DCLTBPET002.STORESTATUS,
                     :DCLTBPET002.STORENAME,
                     :DCLTBPET002.STORENAMEU,
                     :DCLTBPET002.CREATEDBY,
                     :DCLTBPET002.CREATEDDATE,
                     :DCLTBPET002.UPDATEDBY,
                     :DCLTBPET002.UPDATEDDATE
                FROM TBPET002
               WHERE (STOREID = :DCLTBPET002.STOREID
                  OR  STORECODE = :DCLTBPET002.STORECODE)
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE STOREID     OF DCLTBPET002 TO
                   STOREID     OF W-LPETM002
              MOVE STORECODE   OF DCLTBPET002 TO
                   STORECODE   OF W-LPETM002
              MOVE STORESTATUS OF DCLTBPET002 TO
                   STORESTATUS OF W-LPETM002
              MOVE STORENAME   OF DCLTBPET002 TO
                   STORENAME   OF W-LPETM002
              MOVE STORENAMEU  OF DCLTBPET002 TO
                   STORENAMEU  OF W-LPETM002
              MOVE CREATEDBY   OF DCLTBPET002 TO
                   CREATEDBY   OF W-LPETM002
              MOVE CREATEDDATE OF DCLTBPET002 TO
                   CREATEDDATE OF W-LPETM002
              MOVE UPDATEDBY   OF DCLTBPET002 TO
                   UPDATEDBY   OF W-LPETM002
              MOVE UPDATEDDATE OF DCLTBPET002 TO
                   UPDATEDDATE OF W-LPETM002
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM002
                MOVE N'01' TO REASONCODE OF W-LPETM002
                MOVE N'TBPET002 entry not found' TO
                   INFOMESSAGE OF W-LPETM002
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM002
                MOVE N'21' TO REASONCODE OF W-LPETM002
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM002
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END. 
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET002 STORES                  *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET002.CREATEDDATE,
                     :DCLTBPET002.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET002
                 SET STORECODE   = :DCLTBPET002.STORECODE,
                     STORESTATUS = :DCLTBPET002.STORESTATUS,
                     STORENAME   = :DCLTBPET002.STORENAME,
                     STORENAMEU  = :DCLTBPET002.STORENAMEU,
                     UPDATEDBY   = :DCLTBPET002.UPDATEDBY,
                     UPDATEDDATE = CURRENT TIMESTAMP
               WHERE STOREID = :DCLTBPET002.STOREID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CREATEDDATE OF DCLTBPET002 TO
                   CREATEDDATE OF W-LPETM002
              MOVE UPDATEDDATE OF DCLTBPET002 TO
                   UPDATEDDATE OF W-LPETM002
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM002
              MOVE N'31' TO REASONCODE OF W-LPETM002
              MOVE N'TBPET002 entry not found' TO
                   INFOMESSAGE OF W-LPETM002 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM002
              MOVE N'32' TO REASONCODE OF W-LPETM002
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM002
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END. 
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET002 STORES                *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE STOREID OF W-LPETM002 TO STOREID OF DCLTBPET002

           EXEC SQL
              DELETE
                FROM TBPET002
               WHERE STOREID = :DCLTBPET002.STOREID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM002
              MOVE N'41' TO REASONCODE OF W-LPETM002
              MOVE N'TBPET002 entry not found' TO
                   INFOMESSAGE OF W-LPETM002
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM002
              MOVE N'42' TO REASONCODE OF W-LPETM002
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM002
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END. 
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET002           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE STOREID     OF W-LPETM002 TO STOREID     OF DCLTBPET002
           MOVE STORECODE   OF W-LPETM002 TO STORECODE   OF DCLTBPET002
           MOVE STORESTATUS OF W-LPETM002 TO STORESTATUS OF DCLTBPET002
           MOVE STORENAME   OF W-LPETM002 TO STORENAME   OF DCLTBPET002
           MOVE STORENAME-LEN OF W-LPETM002 TO
                STORENAMEU-LEN OF DCLTBPET002
           MOVE FUNCTION UPPER-CASE(STORENAME-TEXT OF W-LPETM002(1:
                   STORENAME-LEN OF W-LPETM002)) TO
                STORENAMEU-TEXT OF DCLTBPET002
           MOVE CREATEDBY   OF W-LPETM002 TO CREATEDBY   OF DCLTBPET002
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM002) TO
              CREATEDDATE   OF DCLTBPET002
           MOVE UPDATEDBY   OF W-LPETM002 TO UPDATEDBY   OF DCLTBPET002
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM002) TO
              UPDATEDDATE   OF DCLTBPET002
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

       END PROGRAM PETM002.