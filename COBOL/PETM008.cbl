       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM008
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET008 CUSTOMERS table.                                     *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET008                           *
      *   TBPET008 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: CUSTOMERID required                        *
      *     08 03 = Error: LASTNAME required                          *
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

           EXEC SQL INCLUDE TBPET008 END-EXEC.

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

       01 W-LPETM008.
           COPY LPETM008.

       01 W-LPETA990.
           COPY LPETA990.

       LINKAGE SECTION.
       01 P-LPETM008.
           COPY LPETM008.

       PROCEDURE DIVISION USING P-LPETM008.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM008 = N'00'
              EVALUATE OPCODE OF W-LPETM008
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
           MOVE P-LPETM008 TO W-LPETM008

           MOVE N'00' TO RETURNCODE OF W-LPETM008
           MOVE N'00' TO REASONCODE OF W-LPETM008
           MOVE SPACES TO INFOMESSAGE OF W-LPETM008
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM008 NOT = N'C'
           AND OPCODE OF W-LPETM008 NOT = N'R'
           AND OPCODE OF W-LPETM008 NOT = N'U'
           AND OPCODE OF W-LPETM008 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM008
              MOVE N'01' TO REASONCODE OF W-LPETM008
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM008
           END-IF

           IF OPCODE OF W-LPETM008 NOT = N'C'
              IF  RETURNCODE OF W-LPETM008 = N'00'
              AND CUSTOMERID OF W-LPETM008 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM008
                 MOVE N'02' TO REASONCODE OF W-LPETM008
                 MOVE N'CUSTOMERID is required' TO
                      INFOMESSAGE OF W-LPETM008
              END-IF
           END-IF

           IF OPCODE OF W-LPETM008 = N'C'
           OR OPCODE OF W-LPETM008 = N'U'
              IF   RETURNCODE OF W-LPETM008 = N'00'
              AND (LASTNAME-LEN OF W-LPETM008 = 0
              OR   LASTNAME-TEXT OF W-LPETM008(1:
                      LASTNAME-LEN OF W-LPETM008) = SPACES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM008
                 MOVE N'03' TO REASONCODE OF W-LPETM008
                 MOVE N'LASTNAME is required' TO
                      INFOMESSAGE OF W-LPETM008
              END-IF

              IF CREATEDBY OF W-LPETM008 = SPACES
              OR CREATEDBY OF W-LPETM008 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM008 = SPACES
              OR UPDATEDBY OF W-LPETM008 = LOW-VALUES
                 MOVE 'PETA990' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA990

                 IF RETURNCODE OF W-LPETA990 = N'00'
                    IF CREATEDBY OF W-LPETM008 = SPACES
                    OR CREATEDBY OF W-LPETM008 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            CREATEDBY OF W-LPETM008
                    END-IF

                    IF UPDATEDBY OF W-LPETM008 = SPACES
                    OR UPDATEDBY OF W-LPETM008 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            UPDATEDBY OF W-LPETM008
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM008
                    MOVE N'90' TO REASONCODE OF W-LPETM008
                    MOVE INFOMESSAGE OF W-LPETA990 TO
                         INFOMESSAGE OF W-LPETM008
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
           MOVE W-LPETM008 TO P-LPETM008
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET008 CUSTOMERS             *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CUSTOMERID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET008.CUSTOMERID,
                     :DCLTBPET008.CREATEDDATE,
                     :DCLTBPET008.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET008
                     (LASTNAME,
                      LASTNAMEU,
                      FIRSTNAME,
                      FIRSTNAMEU,
                      MIDDLENAME,
                      DATEOFBIRTH,
                      GENDER,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET008.LASTNAME,
                     :DCLTBPET008.LASTNAMEU,
                     :DCLTBPET008.FIRSTNAME
                       :DCLTBPET008.FIRSTNAME-IND,
                     :DCLTBPET008.FIRSTNAMEU
                       :DCLTBPET008.FIRSTNAMEU-IND,
                     :DCLTBPET008.MIDDLENAME
                       :DCLTBPET008.MIDDLENAME-IND,
                     :DCLTBPET008.DATEOFBIRTH
                       :DCLTBPET008.DATEOFBIRTH-IND,
                     :DCLTBPET008.GENDER
                       :DCLTBPET008.GENDER-IND,
                     :DCLTBPET008.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET008.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CUSTOMERID  OF DCLTBPET008 TO
                   CUSTOMERID  OF W-LPETM008
              MOVE CREATEDDATE OF DCLTBPET008 TO
                   CREATEDDATE OF W-LPETM008
              MOVE UPDATEDDATE OF DCLTBPET008 TO
                   UPDATEDDATE OF W-LPETM008
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM008
              MOVE N'11' TO REASONCODE OF W-LPETM008
              MOVE N'TBPET008 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM008
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM008
              MOVE N'12' TO REASONCODE OF W-LPETM008
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM008
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET008 CUSTOMERS             *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE CUSTOMERID OF W-LPETM008 TO CUSTOMERID OF DCLTBPET008

           EXEC SQL
              SELECT LASTNAME,
                     LASTNAMEU,
                     FIRSTNAME,
                     FIRSTNAMEU,
                     MIDDLENAME,
                     DATEOFBIRTH,
                     GENDER,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET008.LASTNAME,
                     :DCLTBPET008.LASTNAMEU,
                     :DCLTBPET008.FIRSTNAME
                       :DCLTBPET008.FIRSTNAME-IND,
                     :DCLTBPET008.FIRSTNAMEU
                       :DCLTBPET008.FIRSTNAMEU-IND,
                     :DCLTBPET008.MIDDLENAME
                       :DCLTBPET008.MIDDLENAME-IND,
                     :DCLTBPET008.DATEOFBIRTH
                       :DCLTBPET008.DATEOFBIRTH-IND,
                     :DCLTBPET008.GENDER
                       :DCLTBPET008.GENDER-IND,
                     :DCLTBPET008.CREATEDBY,
                     :DCLTBPET008.CREATEDDATE,
                     :DCLTBPET008.UPDATEDBY,
                     :DCLTBPET008.UPDATEDDATE
                FROM TBPET008
               WHERE CUSTOMERID = :DCLTBPET008.CUSTOMERID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE LASTNAME  OF DCLTBPET008 TO
                   LASTNAME  OF W-LPETM008
              MOVE LASTNAMEU OF DCLTBPET008 TO
                   LASTNAMEU OF W-LPETM008
              IF FIRSTNAME-IND OF DCLTBPET008 < 0
                 MOVE 0 TO FIRSTNAME-LEN OF W-LPETM008
                 MOVE LOW-VALUES TO FIRSTNAME-TEXT OF W-LPETM008
              ELSE
                 MOVE FIRSTNAME OF DCLTBPET008 TO
                      FIRSTNAME OF W-LPETM008
              END-IF
              IF FIRSTNAMEU-IND OF DCLTBPET008 < 0
                 MOVE 0 TO FIRSTNAMEU-LEN OF W-LPETM008
                 MOVE LOW-VALUES TO FIRSTNAME-TEXT OF W-LPETM008
              ELSE
                 MOVE FIRSTNAMEU OF DCLTBPET008 TO
                      FIRSTNAMEU OF W-LPETM008
              END-IF
              IF MIDDLENAME-IND OF DCLTBPET008 < 0
                 MOVE 0 TO MIDDLENAME-LEN OF W-LPETM008
                 MOVE LOW-VALUES TO MIDDLENAME-TEXT OF W-LPETM008
              END-IF
              IF DATEOFBIRTH-IND OF DCLTBPET008 < 0
                 MOVE LOW-VALUES TO DATEOFBIRTH IN W-LPETM008
              ELSE
                 MOVE DATEOFBIRTH OF DCLTBPET008 TO
                      DATEOFBIRTH OF W-LPETM008
              END-IF
              IF GENDER-IND OF DCLTBPET008 < 0
                 MOVE LOW-VALUE TO GENDER OF W-LPETM008
              ELSE
                 MOVE GENDER OF DCLTBPET008 TO GENDER OF W-LPETM008
              END-IF
              MOVE CREATEDBY   OF DCLTBPET008 TO
                   CREATEDBY   OF W-LPETM008
              MOVE CREATEDDATE OF DCLTBPET008 TO
                   CREATEDDATE OF W-LPETM008
              MOVE UPDATEDBY   OF DCLTBPET008 TO
                   UPDATEDBY   OF W-LPETM008
              MOVE UPDATEDDATE OF DCLTBPET008 TO
                   UPDATEDDATE OF W-LPETM008
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM008
                MOVE N'01' TO REASONCODE OF W-LPETM008
                MOVE N'TBPET008 entry not found' TO
                   INFOMESSAGE OF W-LPETM008
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM008
                MOVE N'21' TO REASONCODE OF W-LPETM008
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM008
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END.
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET008 CUSTOMERS               *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT UPDATEDDATE
                INTO :DCLTBPET008.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET008
                 SET LASTNAME    = :DCLTBPET008.LASTNAME,
                     LASTNAMEU   = :DCLTBPET008.LASTNAMEU,
                     FIRSTNAME   = :DCLTBPET008.FIRSTNAME
                                     :DCLTBPET008.FIRSTNAME-IND,
                     FIRSTNAMEU  = :DCLTBPET008.FIRSTNAMEU
                                     :DCLTBPET008.FIRSTNAMEU-IND,
                     MIDDLENAME  = :DCLTBPET008.MIDDLENAME
                                     :DCLTBPET008.MIDDLENAME-IND,
                     DATEOFBIRTH = :DCLTBPET008.DATEOFBIRTH
                                     :DCLTBPET008.DATEOFBIRTH-IND,
                     GENDER      = :DCLTBPET008.GENDER
                                     :DCLTBPET008.GENDER-IND,
                     UPDATEDBY   = :DCLTBPET008.UPDATEDBY,
                     UPDATEDDATE = CURRENT TIMESTAMP
               WHERE CUSTOMERID = :DCLTBPET008.CUSTOMERID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE UPDATEDDATE OF DCLTBPET008 TO
                   UPDATEDDATE OF W-LPETM008
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM008
              MOVE N'31' TO REASONCODE OF W-LPETM008
              MOVE N'TBPET008 entry not found' TO
                   INFOMESSAGE OF W-LPETM008
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM008
              MOVE N'32' TO REASONCODE OF W-LPETM008
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM008
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END.
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET008 CUSTOMERS             *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE CUSTOMERID OF W-LPETM008 TO CUSTOMERID OF DCLTBPET008

           EXEC SQL
              DELETE
                FROM TBPET008
               WHERE CUSTOMERID = :DCLTBPET008.CUSTOMERID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM008
              MOVE N'41' TO REASONCODE OF W-LPETM008
              MOVE N'TBPET008 entry not found' TO
                   INFOMESSAGE OF W-LPETM008
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM008
              MOVE N'42' TO REASONCODE OF W-LPETM008
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM008
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END.
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET008           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE LASTNAME  OF W-LPETM008 TO LASTNAME OF DCLTBPET008
           MOVE LASTNAME-LEN  OF W-LPETM008 TO
                LASTNAMEU-LEN OF DCLTBPET008
           MOVE FUNCTION UPPER-CASE(LASTNAME-TEXT OF W-LPETM008(1:
                   LASTNAME-LEN OF W-LPETM008)) TO
                LASTNAMEU-TEXT OF DCLTBPET008
           IF FIRSTNAME-LEN OF W-LPETM008 = 0
              MOVE -1 TO FIRSTNAME-IND OF DCLTBPET008
              MOVE -1 TO FIRSTNAMEU-IND OF DCLTBPET008
              MOVE 0 TO FIRSTNAME-LEN OF DCLTBPET008
              MOVE 0 TO FIRSTNAMEU-LEN OF DCLTBPET008
              MOVE LOW-VALUES TO FIRSTNAME-TEXT OF DCLTBPET008
              MOVE LOW-VALUES TO FIRSTNAMEU-TEXT OF DCLTBPET008
           ELSE
              MOVE 0 TO FIRSTNAME-IND OF DCLTBPET008
              MOVE 0 TO FIRSTNAMEU-IND OF DCLTBPET008
              MOVE FIRSTNAME OF W-LPETM008 TO FIRSTNAME OF DCLTBPET008
              MOVE FIRSTNAME-LEN OF W-LPETM008 TO
                   FIRSTNAMEU-LEN OF DCLTBPET008
              MOVE FUNCTION UPPER-CASE(FIRSTNAME-TEXT OF W-LPETM008(1:
                      FIRSTNAME-LEN OF W-LPETM008)) TO
                   FIRSTNAMEU-TEXT OF W-LPETM008
           END-IF
           IF MIDDLENAME-LEN OF W-LPETM008 = 0
              MOVE -1 TO MIDDLENAME-IND OF DCLTBPET008
              MOVE 0 TO MIDDLENAME-LEN OF DCLTBPET008
              MOVE LOW-VALUES TO MIDDLENAME-TEXT OF DCLTBPET008
           ELSE
              MOVE 0 TO MIDDLENAME-IND OF DCLTBPET008
              MOVE MIDDLENAME OF W-LPETM008 TO MIDDLENAME OF DCLTBPET008
           END-IF
           IF DATEOFBIRTH OF W-LPETM008 = LOW-VALUES
           OR DATEOFBIRTH OF W-LPETM008 = SPACES
              MOVE -1 TO DATEOFBIRTH-IND OF DCLTBPET008
              MOVE LOW-VALUES TO DATEOFBIRTH OF DCLTBPET008
           ELSE
              MOVE 0 TO DATEOFBIRTH-IND OF DCLTBPET008
              MOVE DATEOFBIRTH OF W-LPETM008 TO
                   DATEOFBIRTH OF DCLTBPET008
           END-IF
           IF GENDER OF W-LPETM008 = LOW-VALUE
           OR GENDER OF W-LPETM008 = SPACE
              MOVE -1 TO GENDER-IND OF DCLTBPET008
              MOVE LOW-VALUE TO GENDER OF DCLTBPET008
           ELSE
              MOVE 0 TO GENDER-IND OF DCLTBPET008
              MOVE GENDER OF W-LPETM008 TO GENDER OF DCLTBPET008
           END-IF
           MOVE CREATEDBY    OF W-LPETM008 TO CREATEDBY   OF DCLTBPET008
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM008) TO
              CREATEDDATE OF DCLTBPET008
           MOVE UPDATEDBY    OF W-LPETM008 TO UPDATEDBY   OF DCLTBPET008
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM008) TO
              UPDATEDDATE OF DCLTBPET008
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

       END PROGRAM PETM008.
