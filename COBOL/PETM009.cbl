       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM009
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET009 PURCHASES table.                                     *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET009                           *
      *   TBPET009 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: PURCHASEID required                        *
      *     08 03 = Error: PURCHASEDATE required                      *
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

           EXEC SQL INCLUDE TBPET009 END-EXEC.

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

       01 W-LPETM009.
           COPY LPETM009.

       01 W-LPETA990.
           COPY LPETA990.

       LINKAGE SECTION.
       01 P-LPETM009.
           COPY LPETM009.

       PROCEDURE DIVISION USING P-LPETM009.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM009 = N'00'
              EVALUATE OPCODE OF W-LPETM009
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
           MOVE P-LPETM009 TO W-LPETM009

           MOVE N'00' TO RETURNCODE OF W-LPETM009
           MOVE N'00' TO REASONCODE OF W-LPETM009
           MOVE SPACES TO INFOMESSAGE OF W-LPETM009
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM009 NOT = N'C'
           AND OPCODE OF W-LPETM009 NOT = N'R'
           AND OPCODE OF W-LPETM009 NOT = N'U'
           AND OPCODE OF W-LPETM009 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM009
              MOVE N'01' TO REASONCODE OF W-LPETM009
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM009
           END-IF

           IF OPCODE OF W-LPETM009 NOT = N'C'
              IF  RETURNCODE OF W-LPETM009 = N'00'
              AND PURCHASEID OF W-LPETM009 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM009
                 MOVE N'02' TO REASONCODE OF W-LPETM009
                 MOVE N'PURCHASEID is required' TO
                      INFOMESSAGE OF W-LPETM009
              END-IF
           END-IF

           IF OPCODE OF W-LPETM009 = N'C'
           OR OPCODE OF W-LPETM009 = N'U'
              IF   RETURNCODE OF W-LPETM009 = N'00'
              AND (PURCHASEDATE OF W-LPETM009 = SPACES
              OR   PURCHASEDATE OF W-LPETM009 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM009
                 MOVE N'03' TO REASONCODE OF W-LPETM009
                 MOVE N'PURCHASEDATE is required' TO
                      INFOMESSAGE OF W-LPETM009
              END-IF

              IF CREATEDBY OF W-LPETM009 = SPACES
              OR CREATEDBY OF W-LPETM009 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM009 = SPACES
              OR UPDATEDBY OF W-LPETM009 = LOW-VALUES
                 MOVE 'PETA990' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA990

                 IF RETURNCODE OF W-LPETA990 = N'00'
                    IF CREATEDBY OF W-LPETM009 = SPACES
                    OR CREATEDBY OF W-LPETM009 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            CREATEDBY OF W-LPETM009
                    END-IF

                    IF UPDATEDBY OF W-LPETM009 = SPACES
                    OR UPDATEDBY OF W-LPETM009 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            UPDATEDBY OF W-LPETM009
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM009
                    MOVE N'90' TO REASONCODE OF W-LPETM009
                    MOVE INFOMESSAGE OF W-LPETA990 TO
                         INFOMESSAGE OF W-LPETM009
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
           MOVE W-LPETM009 TO P-LPETM009
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET009 PURCHASES             *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT PURCHASEID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET009.PURCHASEID,
                     :DCLTBPET009.CREATEDDATE,
                     :DCLTBPET009.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET009
                     (PURCHASEDATE,
                      CUSTOMERID,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET009.PURCHASEDATE,
                     :DCLTBPET009.CUSTOMERID
                       :DCLTBPET009.CUSTOMERID-IND,
                     :DCLTBPET009.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET009.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE PURCHASEID  OF DCLTBPET009 TO
                   PURCHASEID  OF W-LPETM009
              MOVE CREATEDDATE OF DCLTBPET009 TO
                   CREATEDDATE OF W-LPETM009
              MOVE UPDATEDDATE OF DCLTBPET009 TO
                   UPDATEDDATE OF W-LPETM009
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM009
              MOVE N'11' TO REASONCODE OF W-LPETM009
              MOVE N'TBPET009 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM009
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM009
              MOVE N'12' TO REASONCODE OF W-LPETM009
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM009
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET009 PURCHASES             *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE PURCHASEID OF W-LPETM009 TO PURCHASEID OF DCLTBPET009

           EXEC SQL
              SELECT PURCHASEDATE,
                     CUSTOMERID,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET009.PURCHASEDATE,
                     :DCLTBPET009.CUSTOMERID
                       :DCLTBPET009.CUSTOMERID-IND,
                     :DCLTBPET009.CREATEDBY,
                     :DCLTBPET009.CREATEDDATE,
                     :DCLTBPET009.UPDATEDBY,
                     :DCLTBPET009.UPDATEDDATE
                FROM TBPET009
               WHERE CUSTOMERID = :DCLTBPET009.CUSTOMERID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE PURCHASEDATE OF DCLTBPET009 TO
                   PURCHASEDATE OF W-LPETM009
              IF CUSTOMERID-IND OF DCLTBPET009 < 0
                 MOVE 0 TO CUSTOMERID OF W-LPETM009
              ELSE
                 MOVE CUSTOMERID OF DCLTBPET009 TO
                      CUSTOMERID OF W-LPETM009
              END-IF
              MOVE CREATEDBY   OF DCLTBPET009 TO
                   CREATEDBY   OF W-LPETM009
              MOVE CREATEDDATE OF DCLTBPET009 TO
                   CREATEDDATE OF W-LPETM009
              MOVE UPDATEDBY   OF DCLTBPET009 TO
                   UPDATEDBY   OF W-LPETM009
              MOVE UPDATEDDATE OF DCLTBPET009 TO
                   UPDATEDDATE OF W-LPETM009
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM009
                MOVE N'01' TO REASONCODE OF W-LPETM009
                MOVE N'TBPET009 entry not found' TO
                   INFOMESSAGE OF W-LPETM009
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM009
                MOVE N'21' TO REASONCODE OF W-LPETM009
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM009
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END.
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET009 PURCHASES               *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT UPDATEDDATE
                INTO :DCLTBPET009.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET009
                 SET PURCHASEDATE = :DCLTBPET009.PURCHASEDATE,
                     CUSTOMERID   = :DCLTBPET009.CUSTOMERID
                                     :DCLTBPET009.CUSTOMERID-IND,
                     UPDATEDBY   = :DCLTBPET009.UPDATEDBY,
                     UPDATEDDATE = CURRENT TIMESTAMP
               WHERE PURCHASEID = :DCLTBPET009.PURCHASEID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE UPDATEDDATE OF DCLTBPET009 TO
                   UPDATEDDATE OF W-LPETM009
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM009
              MOVE N'31' TO REASONCODE OF W-LPETM009
              MOVE N'TBPET009 entry not found' TO
                   INFOMESSAGE OF W-LPETM009
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM009
              MOVE N'32' TO REASONCODE OF W-LPETM009
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM009
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END.
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET009 PURCHASES             *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE PURCHASEID OF W-LPETM009 TO PURCHASEID OF DCLTBPET009

           EXEC SQL
              DELETE
                FROM TBPET009
               WHERE PURCHASEID = :DCLTBPET009.PURCHASEID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM009
              MOVE N'41' TO REASONCODE OF W-LPETM009
              MOVE N'TBPET009 entry not found' TO
                   INFOMESSAGE OF W-LPETM009
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM009
              MOVE N'42' TO REASONCODE OF W-LPETM009
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM009
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END.
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET009           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE FUNCTION DISPLAY-OF(PURCHASEDATE OF W-LPETM009) TO
                PURCHASEDATE OF DCLTBPET009
           IF CUSTOMERID OF W-LPETM009 = 0
              MOVE -1 TO CUSTOMERID-IND OF DCLTBPET009
              MOVE 0 TO CUSTOMERID OF DCLTBPET009
           ELSE
              MOVE 0 TO CUSTOMERID-IND OF DCLTBPET009
              MOVE CUSTOMERID OF W-LPETM009 TO CUSTOMERID OF DCLTBPET009
           END-IF
           MOVE CREATEDBY    OF W-LPETM009 TO CREATEDBY   OF DCLTBPET009
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM009) TO
              CREATEDDATE OF DCLTBPET009
           MOVE UPDATEDBY    OF W-LPETM009 TO UPDATEDBY   OF DCLTBPET009
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM009) TO
              UPDATEDDATE OF DCLTBPET009
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

       END PROGRAM PETM009.
