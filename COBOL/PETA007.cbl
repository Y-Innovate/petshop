       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETA007
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET007 PRICESANDDISCOUNTS table.                            *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET007                           *
      *   TBPET007 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: PADID required                             *
      *     08 03 = Error: STOREID required                           *
      *     08 04 = Error: PRODUCTID or ANIMALID required             *
      *     08 05 = Error: PRICE or DISCOUNT required                 *
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

           EXEC SQL INCLUDE TBPET007 END-EXEC.

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

       01 W-LPETA007.
           COPY LPETA007.

       01 W-LPETA900.
           COPY LPETA900.

       LINKAGE SECTION.
       01 P-LPETA007.
           COPY LPETA007.

       PROCEDURE DIVISION USING P-LPETA007.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETA007 = N'00'
              EVALUATE OPCODE OF W-LPETA007
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
           MOVE P-LPETA007 TO W-LPETA007

           MOVE N'00' TO RETURNCODE OF W-LPETA007
           MOVE N'00' TO REASONCODE OF W-LPETA007
           MOVE SPACES TO INFOMESSAGE OF W-LPETA007
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETA007 NOT = N'C'
           AND OPCODE OF W-LPETA007 NOT = N'R'
           AND OPCODE OF W-LPETA007 NOT = N'U'
           AND OPCODE OF W-LPETA007 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETA007
              MOVE N'01' TO REASONCODE OF W-LPETA007
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETA007
           END-IF

           IF  OPCODE OF W-LPETA007 NOT = N'C'
           AND OPCODE OF W-LPETA007 NOT = N'R'
              IF  RETURNCODE OF W-LPETA007 = N'00'
              AND PADID OF W-LPETA007 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA007
                 MOVE N'02' TO REASONCODE OF W-LPETA007
                 MOVE N'PADID is required' TO
                      INFOMESSAGE OF W-LPETA007
              END-IF
           END-IF

           IF OPCODE OF W-LPETA007 = N'R'
              IF    RETURNCODE OF W-LPETA007 = N'00'
              AND ( PADID      OF W-LPETA007 = 0
              OR   (STOREID    OF W-LPETA007 = 0
              AND   PRODUCTID  OF W-LPETA007 = 0
              AND   ANIMALID   OF W-LPETA007 = 0))
                 MOVE N'08' TO RETURNCODE OF W-LPETA007
                 MOVE N'04' TO REASONCODE OF W-LPETA007
                 MOVE N'PRODUCTID or ANIMALID is required' TO
                      INFOMESSAGE OF W-LPETA007
              END-IF
           END-IF

           IF OPCODE OF W-LPETA007 = N'C'
           OR OPCODE OF W-LPETA007 = N'U'
              IF  RETURNCODE OF W-LPETA007 = N'00'
              AND STOREID OF W-LPETA007 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA007
                 MOVE N'03' TO REASONCODE OF W-LPETA007
                 MOVE N'STOREID is required' TO
                      INFOMESSAGE OF W-LPETA007
              END-IF

              IF  RETURNCODE OF W-LPETA007 = N'00'
              AND PRODUCTID  OF W-LPETA007 = 0
              AND ANIMALID   OF W-LPETA007 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA007
                 MOVE N'04' TO REASONCODE OF W-LPETA007
                 MOVE N'PRODUCTID or ANIMALID is required' TO
                      INFOMESSAGE OF W-LPETA007
              END-IF

              IF  RETURNCODE OF W-LPETA007 = N'00'
              AND PRICE      OF W-LPETA007 = 0
              AND DISCOUNT   OF W-LPETA007 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETA007
                 MOVE N'05' TO REASONCODE OF W-LPETA007
                 MOVE N'PRICE or DISCOUNT is required' TO
                      INFOMESSAGE OF W-LPETA007
              END-IF

              IF CREATEDBY OF W-LPETA007 = SPACES
              OR CREATEDBY OF W-LPETA007 = LOW-VALUES
              OR UPDATEDBY OF W-LPETA007 = SPACES
              OR UPDATEDBY OF W-LPETA007 = LOW-VALUES
                 MOVE 'PETA900' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA900

                 IF RETURNCODE OF W-LPETA900 = N'00'
                    IF CREATEDBY OF W-LPETA007 = SPACES
                    OR CREATEDBY OF W-LPETA007 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            CREATEDBY OF W-LPETA007
                    END-IF

                    IF UPDATEDBY OF W-LPETA007 = SPACES
                    OR UPDATEDBY OF W-LPETA007 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            UPDATEDBY OF W-LPETA007
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETA007
                    MOVE N'90' TO REASONCODE OF W-LPETA007
                    MOVE INFOMESSAGE OF W-LPETA900 TO
                         INFOMESSAGE OF W-LPETA007
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
           MOVE W-LPETA007 TO P-LPETA007
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET007 PRICESANDDISCOUNTS    *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT PADID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET007.PADID,
                     :DCLTBPET007.CREATEDDATE,
                     :DCLTBPET007.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET007
                     (STOREID,
                      PRODUCTID,
                      ANIMALID,
                      PRICE,
                      DISCOUNT,
                      FROMDATE,
                      TODATE,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET007.STOREID,
                     :DCLTBPET007.PRODUCTID
                       :DCLTBPET007.PRODUCTID-IND,
                     :DCLTBPET007.ANIMALID
                       :DCLTBPET007.ANIMALID-IND,
                     :DCLTBPET007.PRICE
                       :DCLTBPET007.PRICE-IND,
                     :DCLTBPET007.DISCOUNT
                       :DCLTBPET007.DISCOUNT-IND,
                     :DCLTBPET007.FROMDATE
                       :DCLTBPET007.FROMDATE-IND,
                     :DCLTBPET007.TODATE
                       :DCLTBPET007.TODATE-IND,
                     :DCLTBPET007.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET007.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE PADID       OF DCLTBPET007 TO
                   PADID       OF W-LPETA007
              MOVE CREATEDDATE OF DCLTBPET007 TO
                   CREATEDDATE OF W-LPETA007
              MOVE UPDATEDDATE OF DCLTBPET007 TO
                   UPDATEDDATE OF W-LPETA007
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETA007
              MOVE N'11' TO REASONCODE OF W-LPETA007
              MOVE N'TBPET007 duplicate entry' TO
                   INFOMESSAGE OF W-LPETA007
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA007
              MOVE N'12' TO REASONCODE OF W-LPETA007
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA007
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET007 PRICESANDDISCOUNTS    *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE PADID OF W-LPETA007 TO PADID OF DCLTBPET007

           EXEC SQL
              SELECT PADID,
                     STOREID,
                     PRODUCTID,
                     ANIMALID,
                     PRICE,
                     DISCOUNT,
                     FROMDATE,
                     TODATE,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET007.PADID,
                     :DCLTBPET007.STOREID,
                     :DCLTBPET007.PRODUCTID
                       :DCLTBPET007.PRODUCTID-IND,
                     :DCLTBPET007.ANIMALID
                       :DCLTBPET007.ANIMALID-IND,
                     :DCLTBPET007.PRICE
                       :DCLTBPET007.PRICE-IND,
                     :DCLTBPET007.DISCOUNT
                       :DCLTBPET007.DISCOUNT-IND,
                     :DCLTBPET007.FROMDATE
                       :DCLTBPET007.FROMDATE-IND,
                     :DCLTBPET007.TODATE
                       :DCLTBPET007.TODATE-IND,
                     :DCLTBPET007.CREATEDBY,
                     :DCLTBPET007.CREATEDDATE,
                     :DCLTBPET007.UPDATEDBY,
                     :DCLTBPET007.UPDATEDDATE
                FROM TBPET007
               WHERE  PADID     = :DCLTBPET007.PADID
                  OR (STOREID   = :DCLTBPET007.STOREID
                 AND  PRODUCTID = :DCLTBPET007.PRODUCTID)
                  OR (STOREID   = :DCLTBPET007.STOREID
                 AND  ANIMALID  = :DCLTBPET007.ANIMALID)
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE PADID   OF DCLTBPET007 TO PADID   OF W-LPETA007
              MOVE STOREID OF DCLTBPET007 TO STOREID OF W-LPETA007
              IF PRODUCTID-IND OF DCLTBPET007 < 0
                 MOVE 0 TO PRODUCTID OF W-LPETA007
              ELSE
                 MOVE PRODUCTID OF DCLTBPET007 TO
                      PRODUCTID OF W-LPETA007
              END-IF
              IF ANIMALID-IND OF DCLTBPET007 < 0
                 MOVE 0 TO ANIMALID OF W-LPETA007
              ELSE
                 MOVE ANIMALID OF DCLTBPET007 TO ANIMALID OF W-LPETA007
              END-IF
              IF PRICE-IND OF DCLTBPET007 < 0
                 MOVE 0 TO PRICE OF W-LPETA007
              ELSE
                 MOVE PRICE OF DCLTBPET007 TO PRICE OF W-LPETA007
              END-IF
              IF DISCOUNT-IND OF DCLTBPET007 < 0
                 MOVE 0 TO DISCOUNT OF W-LPETA007
              ELSE
                 MOVE DISCOUNT OF DCLTBPET007 TO DISCOUNT OF W-LPETA007
              END-IF
              IF FROMDATE-IND OF DCLTBPET007 < 0
                 MOVE LOW-VALUES TO FROMDATE OF W-LPETA007
              ELSE
                 MOVE FROMDATE OF DCLTBPET007 TO FROMDATE OF W-LPETA007
              END-IF
              IF TODATE-IND OF DCLTBPET007 < 0
                 MOVE LOW-VALUES TO TODATE OF W-LPETA007
              ELSE
                 MOVE TODATE OF DCLTBPET007 TO TODATE OF W-LPETA007
              END-IF
              MOVE CREATEDBY    OF DCLTBPET007 TO
                   CREATEDBY    OF W-LPETA007
              MOVE CREATEDDATE  OF DCLTBPET007 TO
                   CREATEDDATE  OF W-LPETA007
              MOVE UPDATEDBY    OF DCLTBPET007 TO
                   UPDATEDBY    OF W-LPETA007
              MOVE UPDATEDDATE  OF DCLTBPET007 TO
                   UPDATEDDATE  OF W-LPETA007
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETA007
                MOVE N'01' TO REASONCODE OF W-LPETA007
                MOVE N'TBPET007 entry not found' TO
                   INFOMESSAGE OF W-LPETA007
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETA007
                MOVE N'21' TO REASONCODE OF W-LPETA007
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETA007
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END.
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET007 PRICESANDDISCOUNTS      *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET007.CREATEDDATE,
                     :DCLTBPET007.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET007
                 SET STOREID      = :DCLTBPET007.STOREID,
                     PRODUCTID    = :DCLTBPET007.PRODUCTID
                                      :DCLTBPET007.PRODUCTID-IND,
                     ANIMALID     = :DCLTBPET007.ANIMALID
                                      :DCLTBPET007.ANIMALID-IND,
                     PRICE        = :DCLTBPET007.PRICE
                                      :DCLTBPET007.PRICE-IND,
                     DISCOUNT     = :DCLTBPET007.DISCOUNT
                                      :DCLTBPET007.DISCOUNT-IND,
                     FROMDATE     = :DCLTBPET007.FROMDATE
                                      :DCLTBPET007.FROMDATE-IND,
                     TODATE       = :DCLTBPET007.TODATE
                                      :DCLTBPET007.TODATE-IND,
                     UPDATEDBY    = :DCLTBPET007.UPDATEDBY,
                     UPDATEDDATE  = CURRENT TIMESTAMP
               WHERE ANIMALID = :DCLTBPET007.ANIMALID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CREATEDDATE OF DCLTBPET007 TO
                   CREATEDDATE OF W-LPETA007
              MOVE UPDATEDDATE OF DCLTBPET007 TO
                   UPDATEDDATE OF W-LPETA007
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETA007
              MOVE N'31' TO REASONCODE OF W-LPETA007
              MOVE N'TBPET007 entry not found' TO
                   INFOMESSAGE OF W-LPETA007
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA007
              MOVE N'32' TO REASONCODE OF W-LPETA007
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA007
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END.
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET007 PRICESANDDISCOUNTS    *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE PADID OF W-LPETA007 TO PADID OF DCLTBPET007

           EXEC SQL
              DELETE
                FROM TBPET007
               WHERE PADID = :DCLTBPET007.PADID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETA007
              MOVE N'41' TO REASONCODE OF W-LPETA007
              MOVE N'TBPET007 entry not found' TO
                   INFOMESSAGE OF W-LPETA007
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETA007
              MOVE N'42' TO REASONCODE OF W-LPETA007
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETA007
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END.
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET007           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE PADID   OF W-LPETA007 TO PADID   OF DCLTBPET007
           MOVE STOREID OF W-LPETA007 TO STOREID OF DCLTBPET007
           IF PRODUCTID OF W-LPETA007 = 0
              MOVE -1 TO PRODUCTID-IND OF DCLTBPET007
           ELSE
              MOVE 0 TO PRODUCTID-IND OF DCLTBPET007
              MOVE PRODUCTID OF W-LPETA007 TO PRODUCTID OF DCLTBPET007
           END-IF
           IF ANIMALID OF W-LPETA007 = 0
              MOVE -1 TO ANIMALID-IND OF DCLTBPET007
           ELSE
              MOVE 0 TO ANIMALID-IND OF DCLTBPET007
              MOVE ANIMALID OF W-LPETA007 TO ANIMALID OF DCLTBPET007
           END-IF
           IF PRICE OF W-LPETA007 = 0
              MOVE -1 TO PRICE-IND OF DCLTBPET007
           ELSE
              MOVE 0 TO PRICE-IND OF DCLTBPET007
              MOVE PRICE OF W-LPETA007 TO PRICE OF DCLTBPET007
           END-IF
           IF DISCOUNT OF W-LPETA007 = 0
              MOVE -1 TO DISCOUNT-IND OF DCLTBPET007
           ELSE
              MOVE 0 TO DISCOUNT-IND OF DCLTBPET007
              MOVE DISCOUNT OF W-LPETA007 TO DISCOUNT OF DCLTBPET007
           END-IF
           IF FROMDATE OF W-LPETA007 = LOW-VALUES
              MOVE -1 TO FROMDATE-IND OF DCLTBPET007
           ELSE
              MOVE 0 TO FROMDATE-IND OF DCLTBPET007
              MOVE FUNCTION DISPLAY-OF(FROMDATE OF W-LPETA007) TO
                   FROMDATE OF DCLTBPET007
           END-IF
           IF TODATE OF W-LPETA007 = LOW-VALUES
              MOVE -1 TO TODATE-IND OF DCLTBPET007
           ELSE
              MOVE 0 TO TODATE-IND OF DCLTBPET007
              MOVE FUNCTION DISPLAY-OF(TODATE OF W-LPETA007) TO
                   TODATE OF DCLTBPET007
           END-IF
           MOVE CREATEDBY OF W-LPETA007 TO CREATEDBY OF DCLTBPET007
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETA007) TO
              CREATEDDATE OF DCLTBPET007
           MOVE UPDATEDBY OF W-LPETA007 TO UPDATEDBY OF DCLTBPET007
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETA007) TO
              UPDATEDDATE OF DCLTBPET007
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

       END PROGRAM PETA007.