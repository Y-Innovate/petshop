       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETM010
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET010 ORDERS table.                                        *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET010                           *
      *   TBPET010 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: ORDERID required                           *
      *     08 03 = Error: STOREID required                           *
      *     08 04 = Error: PURCHASEID required                        *
      *     08 05 = Error: ORDERDATE required                         *
      *     08 06 = Error: PRODUCTID or ANIMALID required             *
      *     08 07 = Error: ORDERCOUNT required                        *
      *     08 08 = Error: PRICE required                             *
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

           EXEC SQL INCLUDE TBPET010 END-EXEC.

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

       01 W-LPETM010.
           COPY LPETM010.

       01 W-LPETA900.
           COPY LPETA900.

       LINKAGE SECTION.
       01 P-LPETM010.
           COPY LPETM010.

       PROCEDURE DIVISION USING P-LPETM010.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM010 = N'00'
              EVALUATE OPCODE OF W-LPETM010
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
           MOVE P-LPETM010 TO W-LPETM010

           MOVE N'00' TO RETURNCODE OF W-LPETM010
           MOVE N'00' TO REASONCODE OF W-LPETM010
           MOVE SPACES TO INFOMESSAGE OF W-LPETM010
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM010 NOT = N'C'
           AND OPCODE OF W-LPETM010 NOT = N'R'
           AND OPCODE OF W-LPETM010 NOT = N'U'
           AND OPCODE OF W-LPETM010 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM010
              MOVE N'01' TO REASONCODE OF W-LPETM010
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM010
           END-IF

           IF OPCODE OF W-LPETM010 NOT = N'C'
              IF  RETURNCODE OF W-LPETM010 = N'00'
              AND ORDERID    OF W-LPETM010 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM010
                 MOVE N'02' TO REASONCODE OF W-LPETM010
                 MOVE N'ORDERID is required' TO
                      INFOMESSAGE OF W-LPETM010
              END-IF
           END-IF

           IF OPCODE OF W-LPETM010 = N'C'
           OR OPCODE OF W-LPETM010 = N'U'
              IF  RETURNCODE OF W-LPETM010 = N'00'
              AND STOREID    OF W-LPETM010 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM010
                 MOVE N'03' TO REASONCODE OF W-LPETM010
                 MOVE N'STOREID is required' TO
                      INFOMESSAGE OF W-LPETM010
              END-IF

              IF  RETURNCODE OF W-LPETM010 = N'00'
              AND PURCHASEID OF W-LPETM010 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM010
                 MOVE N'04' TO REASONCODE OF W-LPETM010
                 MOVE N'PURCHASEID is required' TO
                      INFOMESSAGE OF W-LPETM010
              END-IF

              IF   RETURNCODE OF W-LPETM010 = N'00'
              AND (ORDERDATE  OF W-LPETM010 = SPACES
              OR   ORDERDATE  OF W-LPETM010 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM010
                 MOVE N'05' TO REASONCODE OF W-LPETM010
                 MOVE N'ORDERDATE is required' TO
                      INFOMESSAGE OF W-LPETM010
              END-IF

              IF  RETURNCODE OF W-LPETM010 = N'00'
              AND PRODUCTID  OF W-LPETM010 = 0
              AND ANIMALID   OF W-LPETM010 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM010
                 MOVE N'06' TO REASONCODE OF W-LPETM010
                 MOVE N'PRODUCTID or ANIMALID is required' TO
                      INFOMESSAGE OF W-LPETM010
              END-IF

              IF  RETURNCODE OF W-LPETM010 = N'00'
              AND ORDERCOUNT OF W-LPETM010 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM010
                 MOVE N'07' TO REASONCODE OF W-LPETM010
                 MOVE N'ORDERCOUNT is required' TO
                      INFOMESSAGE OF W-LPETM010
              END-IF

              IF  RETURNCODE OF W-LPETM010 = N'00'
              AND PRICE      OF W-LPETM010 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM010
                 MOVE N'08' TO REASONCODE OF W-LPETM010
                 MOVE N'PRICE is required' TO
                      INFOMESSAGE OF W-LPETM010
              END-IF

              IF CREATEDBY OF W-LPETM010 = SPACES
              OR CREATEDBY OF W-LPETM010 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM010 = SPACES
              OR UPDATEDBY OF W-LPETM010 = LOW-VALUES
                 MOVE 'PETA900' TO W-PGMNAME
                 
                 CALL W-PGMNAME USING W-LPETA900

                 IF RETURNCODE OF W-LPETA900 = N'00'
                    IF CREATEDBY OF W-LPETM010 = SPACES
                    OR CREATEDBY OF W-LPETM010 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            CREATEDBY OF W-LPETM010
                    END-IF

                    IF UPDATEDBY OF W-LPETM010 = SPACES
                    OR UPDATEDBY OF W-LPETM010 = LOW-VALUES
                       MOVE USERID OF W-LPETA900 TO
                            UPDATEDBY OF W-LPETM010
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM010
                    MOVE N'90' TO REASONCODE OF W-LPETM010
                    MOVE INFOMESSAGE OF W-LPETA900 TO
                         INFOMESSAGE OF W-LPETM010
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
           MOVE W-LPETM010 TO P-LPETM010
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET010 ORDERS                *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT ORDERID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET010.ORDERID,
                     :DCLTBPET010.CREATEDDATE,
                     :DCLTBPET010.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET010
                     (STOREID,
                      PURCHASEID,
                      ORDERDATE,
                      PRODUCTID,
                      ANIMALID,
                      ORDERCOUNT,
                      TYPEOFDISCOUNT,
                      PRICE,
                      DISCOUNT,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET010.STOREID,
                     :DCLTBPET010.PURCHASEID,
                     :DCLTBPET010.ORDERDATE,
                     :DCLTBPET010.PRODUCTID
                       :DCLTBPET010.PRODUCTID-IND,
                     :DCLTBPET010.ANIMALID
                       :DCLTBPET010.ANIMALID-IND,
                     :DCLTBPET010.ORDERCOUNT,
                     :DCLTBPET010.TYPEOFDISCOUNT,
                     :DCLTBPET010.PRICE,
                     :DCLTBPET010.DISCOUNT
                       :DCLTBPET010.DISCOUNT-IND,
                     :DCLTBPET010.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET010.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE ORDERID     OF DCLTBPET010 TO
                   ORDERID     OF W-LPETM010
              MOVE CREATEDDATE OF DCLTBPET010 TO
                   CREATEDDATE OF W-LPETM010
              MOVE UPDATEDDATE OF DCLTBPET010 TO
                   UPDATEDDATE OF W-LPETM010
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM010
              MOVE N'11' TO REASONCODE OF W-LPETM010
              MOVE N'TBPET010 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM010
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM010
              MOVE N'12' TO REASONCODE OF W-LPETM010
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM010
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET010 ORDERS                *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE ORDERID OF W-LPETM010 TO ORDERID OF DCLTBPET010

           EXEC SQL
              SELECT STOREID,
                     PURCHASEID,
                     ORDERDATE,
                     PRODUCTID,
                     ANIMALID,
                     ORDERCOUNT,
                     TYPEOFDISCOUNT,
                     PRICE,
                     DISCOUNT,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET010.STOREID,
                     :DCLTBPET010.PURCHASEID,
                     :DCLTBPET010.ORDERDATE,
                     :DCLTBPET010.PRODUCTID
                       :DCLTBPET010.PRODUCTID-IND,
                     :DCLTBPET010.ANIMALID
                       :DCLTBPET010.ANIMALID-IND,
                     :DCLTBPET010.ORDERCOUNT,
                     :DCLTBPET010.TYPEOFDISCOUNT,
                     :DCLTBPET010.PRICE,
                     :DCLTBPET010.DISCOUNT
                       :DCLTBPET010.DISCOUNT-IND,
                     :DCLTBPET010.CREATEDBY,
                     :DCLTBPET010.CREATEDDATE,
                     :DCLTBPET010.UPDATEDBY,
                     :DCLTBPET010.UPDATEDDATE
                FROM TBPET010
               WHERE ORDERID = :DCLTBPET010.ORDERID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE STOREID    OF DCLTBPET010 TO STOREID    OF W-LPETM010
              MOVE PURCHASEID OF DCLTBPET010 TO PURCHASEID OF W-LPETM010
              MOVE ORDERDATE  OF DCLTBPET010 TO ORDERDATE  OF W-LPETM010
              IF PRODUCTID-IND OF DCLTBPET010 < 0
                 MOVE 0 TO PRODUCTID OF W-LPETM010
              ELSE
                 MOVE PRODUCTID OF DCLTBPET010 TO
                      PRODUCTID OF W-LPETM010
              END-IF
              IF ANIMALID-IND OF DCLTBPET010 < 0
                 MOVE 0 TO ANIMALID OF W-LPETM010
              ELSE
                 MOVE ANIMALID OF DCLTBPET010 TO ANIMALID OF W-LPETM010
              END-IF
              MOVE ORDERCOUNT     OF DCLTBPET010 TO
                   ORDERCOUNT     OF W-LPETM010
              MOVE TYPEOFDISCOUNT OF DCLTBPET010 TO
                   TYPEOFDISCOUNT OF W-LPETM010
              MOVE PRICE          OF DCLTBPET010 TO
                   PRICE          OF W-LPETM010
              IF DISCOUNT-IND OF DCLTBPET010 < 0
                 MOVE 0 TO DISCOUNT OF W-LPETM010
              ELSE
                 MOVE DISCOUNT OF DCLTBPET010 TO DISCOUNT OF W-LPETM010
              END-IF
              MOVE CREATEDBY   OF DCLTBPET010 TO
                   CREATEDBY   OF W-LPETM010
              MOVE CREATEDDATE OF DCLTBPET010 TO
                   CREATEDDATE OF W-LPETM010
              MOVE UPDATEDBY   OF DCLTBPET010 TO
                   UPDATEDBY   OF W-LPETM010
              MOVE UPDATEDDATE OF DCLTBPET010 TO
                   UPDATEDDATE OF W-LPETM010
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM010
                MOVE N'01' TO REASONCODE OF W-LPETM010
                MOVE N'TBPET010 entry not found' TO
                   INFOMESSAGE OF W-LPETM010
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM010
                MOVE N'21' TO REASONCODE OF W-LPETM010
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM010
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END. 
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET010 ORDERS                  *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT UPDATEDDATE
                INTO :DCLTBPET010.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET010
                 SET STOREID        = :DCLTBPET010.STOREID,
                     PURCHASEID     = :DCLTBPET010.PURCHASEID,
                     ORDERDATE      = :DCLTBPET010.ORDERDATE,
                     PRODUCTID      = :DCLTBPET010.PRODUCTID
                                        :DCLTBPET010.PRODUCTID-IND,
                     ANIMALID       = :DCLTBPET010.ANIMALID
                                        :DCLTBPET010.ANIMALID-IND,
                     ORDERCOUNT     = :DCLTBPET010.ORDERCOUNT,
                     TYPEOFDISCOUNT = :DCLTBPET010.TYPEOFDISCOUNT,
                     PRICE          = :DCLTBPET010.PRICE,
                     DISCOUNT       = :DCLTBPET010.DISCOUNT
                                        :DCLTBPET010.DISCOUNT-IND,
                     UPDATEDBY      = :DCLTBPET010.UPDATEDBY,
                     UPDATEDDATE    = CURRENT TIMESTAMP
               WHERE ORDERID = :DCLTBPET010.ORDERID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE UPDATEDDATE OF DCLTBPET010 TO
                   UPDATEDDATE OF W-LPETM010
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM010
              MOVE N'31' TO REASONCODE OF W-LPETM010
              MOVE N'TBPET010 entry not found' TO
                   INFOMESSAGE OF W-LPETM010 
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM010
              MOVE N'32' TO REASONCODE OF W-LPETM010
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM010
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END. 
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET010 ORDERS                *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE ORDERID OF W-LPETM010 TO ORDERID OF DCLTBPET010

           EXEC SQL
              DELETE
                FROM TBPET010
               WHERE ORDERID = :DCLTBPET010.ORDERID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM010
              MOVE N'41' TO REASONCODE OF W-LPETM010
              MOVE N'TBPET010 entry not found' TO
                   INFOMESSAGE OF W-LPETM010
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM010
              MOVE N'42' TO REASONCODE OF W-LPETM010
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM010
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END. 
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET010           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE STOREID    OF W-LPETM010 TO STOREID    OF DCLTBPET010
           MOVE PURCHASEID OF W-LPETM010 TO PURCHASEID OF DCLTBPET010
           MOVE FUNCTION DISPLAY-OF(ORDERDATE OF W-LPETM010) TO
                ORDERDATE OF DCLTBPET010
           IF PRODUCTID OF W-LPETM010 = 0
              MOVE -1 TO PRODUCTID-IND OF DCLTBPET010
              MOVE 0 TO PRODUCTID OF DCLTBPET010
           ELSE
              MOVE 0 TO PRODUCTID-IND OF DCLTBPET010
              MOVE PRODUCTID OF W-LPETM010 TO PRODUCTID OF DCLTBPET010
           END-IF
           IF ANIMALID OF W-LPETM010 = 0
              MOVE -1 TO ANIMALID-IND OF DCLTBPET010
              MOVE 0 TO ANIMALID OF DCLTBPET010
           ELSE
              MOVE 0 TO ANIMALID-IND OF DCLTBPET010
              MOVE ANIMALID OF W-LPETM010 TO ANIMALID OF DCLTBPET010
           END-IF
           MOVE ORDERCOUNT     OF W-LPETM010 TO
                ORDERCOUNT     OF DCLTBPET010 
           MOVE TYPEOFDISCOUNT OF W-LPETM010 TO
                TYPEOFDISCOUNT OF DCLTBPET010
           MOVE PRICE          OF W-LPETM010 TO
                PRICE          OF DCLTBPET010
           IF DISCOUNT OF W-LPETM010 = 0
              MOVE -1 TO DISCOUNT-IND OF DCLTBPET010
              MOVE 0 TO DISCOUNT OF DCLTBPET010
           ELSE
              MOVE 0 TO DISCOUNT-IND OF DCLTBPET010
              MOVE DISCOUNT OF W-LPETM010 TO DISCOUNT OF DCLTBPET010
           END-IF
           MOVE CREATEDBY    OF W-LPETM010 TO CREATEDBY   OF DCLTBPET010
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM010) TO
              CREATEDDATE OF DCLTBPET010
           MOVE UPDATEDBY    OF W-LPETM010 TO UPDATEDBY   OF DCLTBPET010
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM010) TO
              UPDATEDDATE OF DCLTBPET010
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

       END PROGRAM PETM010.