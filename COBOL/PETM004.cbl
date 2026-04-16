       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM004
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET004 PRODUCTS table.                                      *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET004                           *
      *   TBPET004 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: PRODUCTID required                         *
      *     08 03 = Error: PRODUCTCODE required                       *
      *     08 04 = Error: PRODUCTSTATUS required                     *
      *     08 05 = Error: PRODUCTNAMEU required                      *
      *     08 06 = Error: GROUPCODE required                         *
      *     08 07 = Error: SUPPLIERID required                        *
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

           EXEC SQL INCLUDE TBPET004 END-EXEC.

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

       01 W-LPETM004.
           COPY LPETM004.

       01 W-LPETA990.
           COPY LPETA990.

       LINKAGE SECTION.
       01 P-LPETM004.
           COPY LPETM004.

       PROCEDURE DIVISION USING P-LPETM004.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM004 = N'00'
              EVALUATE OPCODE OF W-LPETM004
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
           MOVE P-LPETM004 TO W-LPETM004

           MOVE N'00' TO RETURNCODE OF W-LPETM004
           MOVE N'00' TO REASONCODE OF W-LPETM004
           MOVE SPACES TO INFOMESSAGE OF W-LPETM004
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM004 NOT = N'C'
           AND OPCODE OF W-LPETM004 NOT = N'R'
           AND OPCODE OF W-LPETM004 NOT = N'U'
           AND OPCODE OF W-LPETM004 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM004
              MOVE N'01' TO REASONCODE OF W-LPETM004
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM004
           END-IF

           IF  OPCODE OF W-LPETM004 NOT = N'C'
           AND OPCODE OF W-LPETM004 NOT = N'R'
              IF  RETURNCODE OF W-LPETM004 = N'00'
              AND PRODUCTID OF W-LPETM004 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM004
                 MOVE N'02' TO REASONCODE OF W-LPETM004
                 MOVE N'PRODUCTID is required' TO
                      INFOMESSAGE OF W-LPETM004
              END-IF
           END-IF

           IF OPCODE OF W-LPETM004 = N'R'
              IF   RETURNCODE  OF W-LPETM004 = N'00'
              AND  PRODUCTID   OF W-LPETM004 = 0
              AND (PRODUCTCODE OF W-LPETM004 = SPACES
              OR   PRODUCTCODE OF W-LPETM004 = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM004
                 MOVE N'03' TO REASONCODE OF W-LPETM004
                 MOVE N'PRODUCTCODE is required' TO
                      INFOMESSAGE OF W-LPETM004
              END-IF
           END-IF

           IF OPCODE OF W-LPETM004 = N'C'
           OR OPCODE OF W-LPETM004 = N'U'
              IF  RETURNCODE OF W-LPETM004 = N'00'
              AND PRODUCTCODE OF W-LPETM004 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM004
                 MOVE N'03' TO REASONCODE OF W-LPETM004
                 MOVE N'PRODUCTCODE is required' TO
                      INFOMESSAGE OF W-LPETM004
              END-IF

              IF  RETURNCODE OF W-LPETM004 = N'00'
              AND PRODUCTSTATUS OF W-LPETM004 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM004
                 MOVE N'04' TO REASONCODE OF W-LPETM004
                 MOVE N'PRODUCTSTATUS is required' TO
                      INFOMESSAGE OF W-LPETM004
              END-IF

              IF   RETURNCODE OF W-LPETM004 = N'00'
              AND (PRODUCTNAME-LEN OF W-LPETM004 = 0
              OR   PRODUCTNAME-TEXT OF W-LPETM004 (1:
                      PRODUCTNAME-LEN OF W-LPETM004) = SPACES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM004
                 MOVE N'05' TO REASONCODE OF W-LPETM004
                 MOVE N'PRODUCTNAME is required' TO
                      INFOMESSAGE OF W-LPETM004
              END-IF

              IF  RETURNCODE OF W-LPETM004 = N'00'
              AND GROUPCODE OF W-LPETM004 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM004
                 MOVE N'06' TO REASONCODE OF W-LPETM004
                 MOVE N'GROUPCODE is required' TO
                      INFOMESSAGE OF W-LPETM004
              END-IF

              IF  RETURNCODE OF W-LPETM004 = N'00'
              AND SUPPLIERID OF W-LPETM004 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM004
                 MOVE N'07' TO REASONCODE OF W-LPETM004
                 MOVE N'SUPPLIERID is required' TO
                      INFOMESSAGE OF W-LPETM004
              END-IF

              IF CREATEDBY OF W-LPETM004 = SPACES
              OR CREATEDBY OF W-LPETM004 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM004 = SPACES
              OR UPDATEDBY OF W-LPETM004 = LOW-VALUES
                 MOVE 'PETA990' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA990

                 IF RETURNCODE OF W-LPETA990 = N'00'
                    IF CREATEDBY OF W-LPETM004 = SPACES
                    OR CREATEDBY OF W-LPETM004 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            CREATEDBY OF W-LPETM004
                    END-IF

                    IF UPDATEDBY OF W-LPETM004 = SPACES
                    OR UPDATEDBY OF W-LPETM004 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            UPDATEDBY OF W-LPETM004
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM004
                    MOVE N'90' TO REASONCODE OF W-LPETM004
                    MOVE INFOMESSAGE OF W-LPETA990 TO
                         INFOMESSAGE OF W-LPETM004
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
           MOVE W-LPETM004 TO P-LPETM004
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET004 PRODUCTS             *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT PRODUCTID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET004.PRODUCTID,
                     :DCLTBPET004.CREATEDDATE,
                     :DCLTBPET004.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET004
                     (PRODUCTCODE,
                      PRODUCTSTATUS,
                      PRODUCTNAME,
                      PRODUCTNAMEU,
                      GROUPCODE,
                      SUPPLIERID,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET004.PRODUCTCODE,
                     :DCLTBPET004.PRODUCTSTATUS,
                     :DCLTBPET004.PRODUCTNAME,
                     :DCLTBPET004.PRODUCTNAMEU,
                     :DCLTBPET004.GROUPCODE,
                     :DCLTBPET004.SUPPLIERID,
                     :DCLTBPET004.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET004.UPDATEDBY,
                     CURRENT_TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE PRODUCTID   OF DCLTBPET004 TO PRODUCTID OF W-LPETM004
              MOVE CREATEDDATE OF DCLTBPET004 TO
                   CREATEDDATE OF W-LPETM004
              MOVE UPDATEDDATE OF DCLTBPET004 TO
                   UPDATEDDATE OF W-LPETM004
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM004
              MOVE N'11' TO REASONCODE OF W-LPETM004
              MOVE N'TBPET004 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM004
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM004
              MOVE N'12' TO REASONCODE OF W-LPETM004
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM004
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET004 PRODUCTS              *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE PRODUCTID   OF W-LPETM004 TO PRODUCTID   OF DCLTBPET004
           MOVE PRODUCTCODE OF W-LPETM004 TO PRODUCTCODE OF DCLTBPET004

           EXEC SQL
              SELECT PRODUCTID,
                     PRODUCTCODE,
                     PRODUCTSTATUS,
                     PRODUCTNAME,
                     PRODUCTNAMEU,
                     GROUPCODE,
                     SUPPLIERID,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET004.PRODUCTID,
                     :DCLTBPET004.PRODUCTCODE,
                     :DCLTBPET004.PRODUCTSTATUS,
                     :DCLTBPET004.PRODUCTNAME,
                     :DCLTBPET004.PRODUCTNAMEU,
                     :DCLTBPET004.GROUPCODE,
                     :DCLTBPET004.SUPPLIERID,
                     :DCLTBPET004.CREATEDBY,
                     :DCLTBPET004.CREATEDDATE,
                     :DCLTBPET004.UPDATEDBY,
                     :DCLTBPET004.UPDATEDDATE
                FROM TBPET004
               WHERE (PRODUCTID   = :DCLTBPET004.PRODUCTID
                  OR  PRODUCTCODE = :DCLTBPET004.PRODUCTCODE)
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE PRODUCTID     OF DCLTBPET004 TO
                   PRODUCTID     OF W-LPETM004
              MOVE PRODUCTCODE   OF DCLTBPET004 TO
                   PRODUCTCODE   OF W-LPETM004
              MOVE PRODUCTSTATUS OF DCLTBPET004 TO
                   PRODUCTSTATUS OF W-LPETM004
              MOVE PRODUCTNAME   OF DCLTBPET004 TO
                   PRODUCTNAME   OF W-LPETM004
              MOVE PRODUCTNAMEU  OF DCLTBPET004 TO
                   PRODUCTNAMEU  OF W-LPETM004
              MOVE GROUPCODE     OF DCLTBPET004 TO
                   GROUPCODE     OF W-LPETM004
              MOVE SUPPLIERID    OF DCLTBPET004 TO
                   SUPPLIERID    OF W-LPETM004
              MOVE CREATEDBY     OF DCLTBPET004 TO
                   CREATEDBY     OF W-LPETM004
              MOVE CREATEDDATE   OF DCLTBPET004 TO
                   CREATEDDATE   OF W-LPETM004
              MOVE UPDATEDBY     OF DCLTBPET004 TO
                   UPDATEDBY     OF W-LPETM004
              MOVE UPDATEDDATE   OF DCLTBPET004 TO
                   UPDATEDDATE   OF W-LPETM004
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM004
                MOVE N'01' TO REASONCODE OF W-LPETM004
                MOVE N'TBPET004 entry not found' TO
                   INFOMESSAGE OF W-LPETM004
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM004
                MOVE N'21' TO REASONCODE OF W-LPETM004
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM004
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END.
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET004 PRODUCTS                *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET004.CREATEDDATE,
                     :DCLTBPET004.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET004
                 SET PRODUCTCODE   = :DCLTBPET004.PRODUCTCODE,
                     PRODUCTSTATUS = :DCLTBPET004.PRODUCTSTATUS,
                     PRODUCTNAME   = :DCLTBPET004.PRODUCTNAME,
                     PRODUCTNAMEU  = :DCLTBPET004.PRODUCTNAMEU,
                     GROUPCODE     = :DCLTBPET004.GROUPCODE,
                     SUPPLIERID    = :DCLTBPET004.SUPPLIERID,
                     UPDATEDBY     = :DCLTBPET004.UPDATEDBY,
                     UPDATEDDATE   = CURRENT TIMESTAMP
               WHERE PRODUCTID = :DCLTBPET004.PRODUCTID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CREATEDDATE OF DCLTBPET004 TO
                   CREATEDDATE OF W-LPETM004
              MOVE UPDATEDDATE OF DCLTBPET004 TO
                   UPDATEDDATE OF W-LPETM004
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM004
              MOVE N'31' TO REASONCODE OF W-LPETM004
              MOVE N'TBPET004 entry not found' TO
                   INFOMESSAGE OF W-LPETM004
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM004
              MOVE N'32' TO REASONCODE OF W-LPETM004
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM004
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END.
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET004 PRODUCTS              *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE PRODUCTID OF W-LPETM004 TO PRODUCTID OF DCLTBPET004

           EXEC SQL
              DELETE
                FROM TBPET004
               WHERE PRODUCTID = :DCLTBPET004.PRODUCTID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM004
              MOVE N'41' TO REASONCODE OF W-LPETM004
              MOVE N'TBPET004 entry not found' TO
                   INFOMESSAGE OF W-LPETM004
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM004
              MOVE N'42' TO REASONCODE OF W-LPETM004
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM004
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END.
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET004           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE PRODUCTID         OF W-LPETM004 TO
                PRODUCTID         OF DCLTBPET004
           MOVE PRODUCTCODE       OF W-LPETM004 TO
                PRODUCTCODE       OF DCLTBPET004
           MOVE PRODUCTSTATUS     OF W-LPETM004 TO
                PRODUCTSTATUS     OF DCLTBPET004
           MOVE PRODUCTNAME       OF W-LPETM004 TO
                PRODUCTNAME       OF DCLTBPET004
           MOVE PRODUCTNAME-LEN   OF W-LPETM004 TO
                PRODUCTNAMEU-LEN  OF DCLTBPET004
           MOVE FUNCTION UPPER-CASE(PRODUCTNAME-TEXT OF W-LPETM004(1:
                   PRODUCTNAME-LEN OF W-LPETM004)) TO
                PRODUCTNAMEU-TEXT OF DCLTBPET004
           MOVE GROUPCODE         OF W-LPETM004 TO
                GROUPCODE         OF DCLTBPET004
           MOVE SUPPLIERID        OF W-LPETM004 TO
                SUPPLIERID        OF DCLTBPET004
           MOVE CREATEDBY         OF W-LPETM004 TO
                CREATEDBY         OF DCLTBPET004
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM004) TO
              CREATEDDATE OF DCLTBPET004
           MOVE UPDATEDBY         OF W-LPETM004 TO
                UPDATEDBY         OF DCLTBPET004
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM004) TO
              UPDATEDDATE OF DCLTBPET004
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

       END PROGRAM PETM004.
