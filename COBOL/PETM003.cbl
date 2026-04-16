       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM003
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET003 SUPPLIERS table.                                     *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET003                           *
      *   TBPET003 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: SUPPLIERID required                        *
      *     08 03 = Error: SUPPLIERCODE required                      *
      *     08 04 = Error: SUPPLIERSTATUS required                    *
      *     08 05 = Error: SUPPLIERNAMEU required                     *
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

           EXEC SQL INCLUDE TBPET003 END-EXEC.

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

       01 W-LPETM003.
           COPY LPETM003.

       01 W-LPETA990.
           COPY LPETA990.

       LINKAGE SECTION.
       01 P-LPETM003.
           COPY LPETM003.

       PROCEDURE DIVISION USING P-LPETM003.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM003 = N'00'
              EVALUATE OPCODE OF W-LPETM003
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
           MOVE P-LPETM003 TO W-LPETM003

           MOVE N'00' TO RETURNCODE OF W-LPETM003
           MOVE N'00' TO REASONCODE OF W-LPETM003
           MOVE SPACES TO INFOMESSAGE OF W-LPETM003
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM003 NOT = N'C'
           AND OPCODE OF W-LPETM003 NOT = N'R'
           AND OPCODE OF W-LPETM003 NOT = N'U'
           AND OPCODE OF W-LPETM003 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM003
              MOVE N'01' TO REASONCODE OF W-LPETM003
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM003
           END-IF

           IF  OPCODE OF W-LPETM003 NOT = N'C'
           AND OPCODE OF W-LPETM003 NOT = N'R'
              IF  RETURNCODE OF W-LPETM003 = N'00'
              AND SUPPLIERID OF W-LPETM003 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM003
                 MOVE N'02' TO REASONCODE OF W-LPETM003
                 MOVE N'SUPPLIERID is required' TO
                      INFOMESSAGE OF W-LPETM003
              END-IF
           END-IF

           IF OPCODE OF W-LPETM003 = N'R'
              IF   RETURNCODE OF W-LPETM003 = N'00'
              AND  SUPPLIERID OF W-LPETM003 = 0
              AND (SUPPLIERCODE OF W-LPETM003 = SPACES
              OR   SUPPLIERCODE OF W-LPETM003 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM003
                 MOVE N'03' TO REASONCODE OF W-LPETM003
                 MOVE N'SUPPLIERCODE is required' TO
                      INFOMESSAGE OF W-LPETM003
              END-IF
           END-IF

           IF OPCODE OF W-LPETM003 = N'C'
           OR OPCODE OF W-LPETM003 = N'U'
              IF  RETURNCODE OF W-LPETM003 = N'00'
              AND SUPPLIERCODE OF W-LPETM003 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM003
                 MOVE N'03' TO REASONCODE OF W-LPETM003
                 MOVE N'SUPPLIERCODE is required' TO
                      INFOMESSAGE OF W-LPETM003
              END-IF

              IF  RETURNCODE OF W-LPETM003 = N'00'
              AND SUPPLIERSTATUS OF W-LPETM003 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM003
                 MOVE N'04' TO REASONCODE OF W-LPETM003
                 MOVE N'SUPPLIERSTATUS is required' TO
                      INFOMESSAGE OF W-LPETM003
              END-IF

              IF   RETURNCODE OF W-LPETM003 = N'00'
              AND (SUPPLIERNAME-LEN OF W-LPETM003 = 0
              OR   SUPPLIERNAME-TEXT OF W-LPETM003 (1:
                      SUPPLIERNAME-LEN OF W-LPETM003) = SPACES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM003
                 MOVE N'05' TO REASONCODE OF W-LPETM003
                 MOVE N'SUPPLIERNAME is required' TO
                      INFOMESSAGE OF W-LPETM003
              END-IF

              IF CREATEDBY OF W-LPETM003 = SPACES
              OR CREATEDBY OF W-LPETM003 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM003 = SPACES
              OR UPDATEDBY OF W-LPETM003 = LOW-VALUES
                 MOVE 'PETA990' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA990

                 IF RETURNCODE OF W-LPETA990 = N'00'
                    IF CREATEDBY OF W-LPETM003 = SPACES
                    OR CREATEDBY OF W-LPETM003 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            CREATEDBY OF W-LPETM003
                    END-IF

                    IF UPDATEDBY OF W-LPETM003 = SPACES
                    OR UPDATEDBY OF W-LPETM003 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            UPDATEDBY OF W-LPETM003
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM003
                    MOVE N'90' TO REASONCODE OF W-LPETM003
                    MOVE INFOMESSAGE OF W-LPETA990 TO
                         INFOMESSAGE OF W-LPETM003
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
           MOVE W-LPETM003 TO P-LPETM003
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET003 SUPPLIERS             *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT SUPPLIERID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET003.SUPPLIERID,
                     :DCLTBPET003.CREATEDDATE,
                     :DCLTBPET003.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET003
                     (SUPPLIERCODE,
                      SUPPLIERSTATUS,
                      SUPPLIERNAME,
                      SUPPLIERNAMEU,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET003.SUPPLIERCODE,
                     :DCLTBPET003.SUPPLIERSTATUS,
                     :DCLTBPET003.SUPPLIERNAME,
                     :DCLTBPET003.SUPPLIERNAMEU,
                     :DCLTBPET003.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET003.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE SUPPLIERID  OF DCLTBPET003 TO
                   SUPPLIERID  OF W-LPETM003
              MOVE SUPPLIERNAMEU-LEN OF DCLTBPET003 TO
                   SUPPLIERNAMEU-LEN OF W-LPETM003
              MOVE SUPPLIERNAMEU-TEXT OF DCLTBPET003 (1:
                      SUPPLIERNAMEU-LEN OF DCLTBPET003) TO
                   SUPPLIERNAMEU-TEXT OF W-LPETM003
              MOVE CREATEDDATE OF DCLTBPET003 TO
                   CREATEDDATE OF W-LPETM003
              MOVE UPDATEDDATE OF DCLTBPET003 TO
                   UPDATEDDATE OF W-LPETM003
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM003
              MOVE N'11' TO REASONCODE OF W-LPETM003
              MOVE N'TBPET003 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM003
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM003
              MOVE N'12' TO REASONCODE OF W-LPETM003
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM003
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET003 SUPPLIERS             *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE SUPPLIERID   OF W-LPETM003 TO SUPPLIERID OF DCLTBPET003
           MOVE SUPPLIERCODE OF W-LPETM003 TO
                SUPPLIERCODE OF DCLTBPET003

           EXEC SQL
              SELECT SUPPLIERID,
                     SUPPLIERCODE,
                     SUPPLIERSTATUS,
                     SUPPLIERNAME,
                     SUPPLIERNAMEU,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET003.SUPPLIERID,
                     :DCLTBPET003.SUPPLIERCODE,
                     :DCLTBPET003.SUPPLIERSTATUS,
                     :DCLTBPET003.SUPPLIERNAME,
                     :DCLTBPET003.SUPPLIERNAMEU,
                     :DCLTBPET003.CREATEDBY,
                     :DCLTBPET003.CREATEDDATE,
                     :DCLTBPET003.UPDATEDBY,
                     :DCLTBPET003.UPDATEDDATE
                FROM TBPET003
               WHERE (SUPPLIERID = :DCLTBPET003.SUPPLIERID
                  OR  SUPPLIERCODE = :DCLTBPET003.SUPPLIERCODE)
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE SUPPLIERID     OF DCLTBPET003 TO
                   SUPPLIERID     OF W-LPETM003
              MOVE SUPPLIERCODE   OF DCLTBPET003 TO
                   SUPPLIERCODE   OF W-LPETM003
              MOVE SUPPLIERSTATUS OF DCLTBPET003 TO
                   SUPPLIERSTATUS OF W-LPETM003
              MOVE SUPPLIERNAME   OF DCLTBPET003 TO
                   SUPPLIERNAME   OF W-LPETM003
              MOVE SUPPLIERNAMEU  OF DCLTBPET003 TO
                   SUPPLIERNAMEU  OF W-LPETM003
              MOVE CREATEDBY      OF DCLTBPET003 TO
                   CREATEDBY      OF W-LPETM003
              MOVE CREATEDDATE    OF DCLTBPET003 TO
                   CREATEDDATE    OF W-LPETM003
              MOVE UPDATEDBY      OF DCLTBPET003 TO
                   UPDATEDBY      OF W-LPETM003
              MOVE UPDATEDDATE    OF DCLTBPET003 TO
                   UPDATEDDATE    OF W-LPETM003
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM003
                MOVE N'01' TO REASONCODE OF W-LPETM003
                MOVE N'TBPET003 entry not found' TO
                   INFOMESSAGE OF W-LPETM003
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM003
                MOVE N'21' TO REASONCODE OF W-LPETM003
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM003
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END.
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET003 SUPPLIERS               *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET003.CREATEDDATE,
                     :DCLTBPET003.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET003
                 SET SUPPLIERCODE   = :DCLTBPET003.SUPPLIERCODE,
                     SUPPLIERSTATUS = :DCLTBPET003.SUPPLIERSTATUS,
                     SUPPLIERNAME   = :DCLTBPET003.SUPPLIERNAME,
                     SUPPLIERNAMEU  = :DCLTBPET003.SUPPLIERNAMEU,
                     UPDATEDBY      = :DCLTBPET003.UPDATEDBY,
                     UPDATEDDATE    = CURRENT TIMESTAMP
               WHERE SUPPLIERID = :DCLTBPET003.SUPPLIERID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE SUPPLIERNAMEU-LEN  OF DCLTBPET003 TO
                   SUPPLIERNAMEU-LEN  OF W-LPETM003
              MOVE SUPPLIERNAMEU-TEXT OF DCLTBPET003(1:
                      SUPPLIERNAMEU-LEN OF DCLTBPET003) TO
                   SUPPLIERNAMEU-TEXT OF W-LPETM003
              MOVE CREATEDDATE        OF DCLTBPET003 TO
                   CREATEDDATE        OF W-LPETM003
              MOVE UPDATEDDATE        OF DCLTBPET003 TO
                   UPDATEDDATE        OF W-LPETM003
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM003
              MOVE N'31' TO REASONCODE OF W-LPETM003
              MOVE N'TBPET003 entry not found' TO
                   INFOMESSAGE OF W-LPETM003
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM003
              MOVE N'32' TO REASONCODE OF W-LPETM003
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM003
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END.
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET003 SUPPLIERS             *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE SUPPLIERID OF W-LPETM003 TO SUPPLIERID OF DCLTBPET003

           EXEC SQL
              DELETE
                FROM TBPET003
               WHERE SUPPLIERID = :DCLTBPET003.SUPPLIERID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM003
              MOVE N'41' TO REASONCODE OF W-LPETM003
              MOVE N'TBPET003 entry not found' TO
                   INFOMESSAGE OF W-LPETM003
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM003
              MOVE N'42' TO REASONCODE OF W-LPETM003
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM003
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END.
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET003           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE SUPPLIERID     OF W-LPETM003 TO
                SUPPLIERID     OF DCLTBPET003
           MOVE SUPPLIERCODE   OF W-LPETM003 TO
                SUPPLIERCODE   OF DCLTBPET003
           MOVE SUPPLIERSTATUS OF W-LPETM003 TO
                SUPPLIERSTATUS OF DCLTBPET003
           MOVE SUPPLIERNAME   OF W-LPETM003 TO
                SUPPLIERNAME   OF DCLTBPET003
           MOVE SUPPLIERNAME-LEN OF W-LPETM003 TO
                SUPPLIERNAMEU-LEN OF DCLTBPET003
           MOVE FUNCTION UPPER-CASE(SUPPLIERNAME-TEXT OF W-LPETM003(1:
                   SUPPLIERNAME-LEN OF W-LPETM003)) TO
                SUPPLIERNAMEU-TEXT OF DCLTBPET003
           MOVE CREATEDBY      OF W-LPETM003 TO
                CREATEDBY      OF DCLTBPET003
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM003) TO
                CREATEDDATE    OF DCLTBPET003
           MOVE UPDATEDBY      OF W-LPETM003 TO
                UPDATEDBY      OF DCLTBPET003
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM003) TO
                UPDATEDDATE    OF DCLTBPET003
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

       END PROGRAM PETM003.
