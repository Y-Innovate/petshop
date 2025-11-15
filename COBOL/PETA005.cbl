       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETA005
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET005 INVENTORY table.                                     *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET005                           *
      *   TBPET005 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: INVENTORYID required                       *
      *     08 03 = Error: STOREID required                           *
      *     08 04 = Error: PRODUCTID required                         *
      *     08 05 = Error: SELLBYDATE required                        *
      *     08 06 = Error: INSTOCK required                           *
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

           EXEC SQL INCLUDE TBPET005 END-EXEC.

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

       01 W-LPETA005.
           COPY LPETA005.

       01 W-LPETA900.
           COPY LPETA900.

       LINKAGE SECTION.
       01 P-LPETA005.
           COPY LPETA005.

       PROCEDURE DIVISION USING P-LPETA005.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETA005 = N'00'
              EVALUATE OPCODE OF W-LPETA005
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
           MOVE P-LPETA005 TO W-LPETA005

           MOVE N'00' TO RETURNCODE OF W-LPETA005
           MOVE N'00' TO REASONCODE OF W-LPETA005
           MOVE SPACES TO INFOMESSAGE OF W-LPETA005
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETA005 NOT = N'C'
           AND OPCODE OF W-LPETA005 NOT = N'R'
           AND OPCODE OF W-LPETA005 NOT = N'U'
           AND OPCODE OF W-LPETA005 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETA005
              MOVE N'01' TO REASONCODE OF W-LPETA005
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETA005
           END-IF

           IF  OPCODE OF W-LPETA005 NOT = N'C'
           AND OPCODE OF W-LPETA005 NOT = N'R'
              IF  RETURNCODE OF W-LPETA005 = N'00'
              AND INVENTORYID OF W-LPETA005 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA005
                 MOVE N'02' TO REASONCODE OF W-LPETA005
                 MOVE N'INVENTORYID is required' TO
                      INFOMESSAGE OF W-LPETA005
              END-IF
           END-IF

           IF OPCODE OF W-LPETA005 = N'R'
              IF  INVENTORYID OF W-LPETA005 = 0
              AND (STOREID OF W-LPETA005 = 0
              OR   PRODUCTID OF W-LPETA005 = 0
              OR   SELLBYDATE OF W-LPETA005 = SPACES
              OR   SELLBYDATE OF W-LPETA005 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETA005
                 MOVE N'03' TO REASONCODE OF W-LPETA005
                 MOVE N'STOREID is required' TO
                      INFOMESSAGE OF W-LPETA005
              END-IF
           END-IF

           IF OPCODE OF W-LPETA005 = N'C'
           OR OPCODE OF W-LPETA005 = N'U'
              IF  RETURNCODE OF W-LPETA005 = N'00'
              AND STOREID OF W-LPETA005 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA005
                 MOVE N'03' TO REASONCODE OF W-LPETA005
                 MOVE N'STOREID is required' TO
                      INFOMESSAGE OF W-LPETA005
              END-IF

              IF  RETURNCODE OF W-LPETA005 = N'00'
              AND PRODUCTID OF W-LPETA005 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA005
                 MOVE N'04' TO REASONCODE OF W-LPETA005
                 MOVE N'PRODUCTID is required' TO
                      INFOMESSAGE OF W-LPETA005
              END-IF

              IF   RETURNCODE OF W-LPETA005 = N'00'
              AND (SELLBYDATE OF W-LPETA005 = SPACES
              OR   SELLBYDATE OF W-LPETA005 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETA005
                 MOVE N'05' TO REASONCODE OF W-LPETA005
                 MOVE N'SELLBYDATE is required' TO
                      INFOMESSAGE OF W-LPETA005
              END-IF

              IF  RETURNCODE OF W-LPETA005 = N'00'
              AND INSTOCK OF W-LPETA005 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA005
                 MOVE N'06' TO REASONCODE OF W-LPETA005
                 MOVE N'INSTOCK is required' TO
                      INFOMESSAGE OF W-LPETA005
              END-IF

              IF CREATEDBY OF W-LPETA005 = SPACES
              OR CREATEDBY OF W-LPETA005 = LOW-VALUES
              OR UPDATEDBY OF W-LPETA005 = SPACES
              OR UPDATEDBY OF W-LPETA005 = LOW-VALUES
                 MOVE 'PETA900' TO W-PGMNAME
                 
                 CALL W-PGMNAME USING W-LPETA900

                 IF RETURNCODE OF W-LPETA900 = N'00'
                    IF CREATEDBY OF W-LPETA005 = SPACES
                    OR CREATEDBY OF W-LPETA005 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            CREATEDBY OF W-LPETA005
                    END-IF

                    IF UPDATEDBY OF W-LPETA005 = SPACES
                    OR UPDATEDBY OF W-LPETA005 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            UPDATEDBY OF W-LPETA005
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETA005
                    MOVE N'90' TO REASONCODE OF W-LPETA005
                    MOVE INFOMESSAGE OF W-LPETA900 TO
                         INFOMESSAGE OF W-LPETA005
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
           MOVE W-LPETA005 TO P-LPETA005
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET005 INVENTORY             *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT INVENTORYID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET005.INVENTORYID,
                     :DCLTBPET005.CREATEDDATE,
                     :DCLTBPET005.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET005
                     (STOREID,
                      PRODUCTID,
                      SELLBYDATE,
                      INSTOCK,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET005.STOREID,
                     :DCLTBPET005.PRODUCTID,
                     :DCLTBPET005.SELLBYDATE,
                     :DCLTBPET005.INSTOCK,
                     :DCLTBPET005.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET005.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE INVENTORYID OF DCLTBPET005 TO
                   INVENTORYID OF W-LPETA005
              MOVE CREATEDDATE OF DCLTBPET005 TO
                   CREATEDDATE OF W-LPETA005
              MOVE UPDATEDDATE OF DCLTBPET005 TO
                   UPDATEDDATE OF W-LPETA005
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETA005
              MOVE N'11' TO REASONCODE OF W-LPETA005
              MOVE N'TBPET005 duplicate entry' TO
                   INFOMESSAGE OF W-LPETA005
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA005
              MOVE N'12' TO REASONCODE OF W-LPETA005
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA005
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET005 INVENTORY             *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE INVENTORYID OF W-LPETA005 TO INVENTORYID OF DCLTBPET005
           MOVE STOREID     OF W-LPETA005 TO STOREID     OF DCLTBPET005
           MOVE PRODUCTID   OF W-LPETA005 TO PRODUCTID   OF DCLTBPET005
           MOVE FUNCTION DISPLAY-OF(SELLBYDATE OF W-LPETA005) TO
                SELLBYDATE OF DCLTBPET005

           EXEC SQL
              SELECT INVENTORYID,
                     STOREID,
                     PRODUCTID,
                     SELLBYDATE,
                     INSTOCK,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET005.INVENTORYID,
                     :DCLTBPET005.STOREID,
                     :DCLTBPET005.PRODUCTID,
                     :DCLTBPET005.SELLBYDATE,
                     :DCLTBPET005.INSTOCK,
                     :DCLTBPET005.CREATEDBY,
                     :DCLTBPET005.CREATEDDATE,
                     :DCLTBPET005.UPDATEDBY,
                     :DCLTBPET005.UPDATEDDATE
                FROM TBPET005
               WHERE ( INVENTORYID = :DCLTBPET005.INVENTORYID
                  OR  (STOREID     = :DCLTBPET005.STOREID
                 AND   PRODUCTID   = :DCLTBPET005.PRODUCTID
                 AND   SELLBYDATE  = :DCLTBPET005.SELLBYDATE))
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE INVENTORYID OF DCLTBPET005 TO
                   INVENTORYID OF W-LPETA005
              MOVE STOREID     OF DCLTBPET005 TO
                   STOREID     OF W-LPETA005
              MOVE PRODUCTID   OF DCLTBPET005 TO
                   PRODUCTID   OF W-LPETA005
              MOVE SELLBYDATE  OF DCLTBPET005 TO
                   SELLBYDATE  OF W-LPETA005
              MOVE INSTOCK     OF DCLTBPET005 TO
                   INSTOCK     OF W-LPETA005
              MOVE CREATEDBY   OF DCLTBPET005 TO
                   CREATEDBY   OF W-LPETA005
              MOVE CREATEDDATE OF DCLTBPET005 TO
                   CREATEDDATE OF W-LPETA005
              MOVE UPDATEDBY   OF DCLTBPET005 TO
                   UPDATEDBY   OF W-LPETA005
              MOVE UPDATEDDATE OF DCLTBPET005 TO
                   UPDATEDDATE OF W-LPETA005
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETA005
                MOVE N'01' TO REASONCODE OF W-LPETA005
                MOVE N'TBPET005 entry not found' TO
                   INFOMESSAGE OF W-LPETA005
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETA005
                MOVE N'21' TO REASONCODE OF W-LPETA005
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETA005
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END. 
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET005 INVENTORY               *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET005.CREATEDDATE,
                     :DCLTBPET005.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET005
                 SET STOREID     = :DCLTBPET005.STOREID,
                     PRODUCTID   = :DCLTBPET005.PRODUCTID,
                     SELLBYDATE  = :DCLTBPET005.SELLBYDATE,
                     INSTOCK     = :DCLTBPET005.INSTOCK,
                     UPDATEDBY   = :DCLTBPET005.UPDATEDBY,
                     UPDATEDDATE = CURRENT TIMESTAMP
               WHERE INVENTORYID = :DCLTBPET005.INVENTORYID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CREATEDDATE OF DCLTBPET005 TO
                   CREATEDDATE OF W-LPETA005
              MOVE UPDATEDDATE OF DCLTBPET005 TO
                   UPDATEDDATE OF W-LPETA005
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETA005
              MOVE N'31' TO REASONCODE OF W-LPETA005
              MOVE N'TBPET005 entry not found' TO
                   INFOMESSAGE OF W-LPETA005 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA005
              MOVE N'32' TO REASONCODE OF W-LPETA005
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA005
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END. 
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET005 INVENTORY             *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE INVENTORYID OF W-LPETA005 TO INVENTORYID OF DCLTBPET005

           EXEC SQL
              DELETE
                FROM TBPET005
               WHERE INVENTORYID = :DCLTBPET005.INVENTORYID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETA005
              MOVE N'41' TO REASONCODE OF W-LPETA005
              MOVE N'TBPET005 entry not found' TO
                   INFOMESSAGE OF W-LPETA005
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA005
              MOVE N'42' TO REASONCODE OF W-LPETA005
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA005
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END. 
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET005           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE INVENTORYID OF W-LPETA005 TO INVENTORYID OF DCLTBPET005
           MOVE STOREID     OF W-LPETA005 TO STOREID     OF DCLTBPET005
           MOVE PRODUCTID   OF W-LPETA005 TO PRODUCTID   OF DCLTBPET005
           MOVE FUNCTION DISPLAY-OF(SELLBYDATE OF W-LPETA005) TO
                SELLBYDATE  OF DCLTBPET005
           MOVE INSTOCK     OF W-LPETA005 TO INSTOCK     OF DCLTBPET005
           MOVE CREATEDBY   OF W-LPETA005 TO CREATEDBY   OF DCLTBPET005
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETA005) TO
              CREATEDDATE OF DCLTBPET005
           MOVE UPDATEDBY   OF W-LPETA005 TO UPDATEDBY   OF DCLTBPET005
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETA005) TO
              UPDATEDDATE OF DCLTBPET005
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

       END PROGRAM PETA005.