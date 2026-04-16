       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM006
      *===============================================================*
      * This program is a CRUD module for the PET store database's    *
      * TBPET006 ANIMALS table.                                       *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   OPCODE: 'C', 'R', 'U' or 'D' for create, read, update or    *
      *            delete a row in TBPET006                           *
      *   TBPET006 Fields depending on OPCODE                         *
      * Output:                                                       *
      *   RETURNCODE and REASONCODE                                   *
      *     00 00 = Success                                           *
      *     04 01 = Not found                                         *
      *     08 01 = Error: OPCODE invalid                             *
      *     08 02 = Error: ANIMALID required                          *
      *     08 03 = Error: STOREID required                           *
      *     08 04 = Error: ANIMALTYPE required                        *
      *     08 05 = Error: ANIMALRACE required                        *
      *     08 06 = Error: ANIMALCOUNT required                       *
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

           EXEC SQL INCLUDE TBPET006 END-EXEC.

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

       01 W-LPETM006.
           COPY LPETM006.

       01 W-LPETA990.
           COPY LPETA990.

       LINKAGE SECTION.
       01 P-LPETM006.
           COPY LPETM006.

       PROCEDURE DIVISION USING P-LPETM006.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R002-CHECKPARM

           IF RETURNCODE OF W-LPETM006 = N'00'
              EVALUATE OPCODE OF W-LPETM006
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
           MOVE P-LPETM006 TO W-LPETM006

           MOVE N'00' TO RETURNCODE OF W-LPETM006
           MOVE N'00' TO REASONCODE OF W-LPETM006
           MOVE SPACES TO INFOMESSAGE OF W-LPETM006
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R002-CHECKPARM: Check parameters                              *
      *===============================================================*
       R002-CHECKPARM SECTION.
           IF  OPCODE OF W-LPETM006 NOT = N'C'
           AND OPCODE OF W-LPETM006 NOT = N'R'
           AND OPCODE OF W-LPETM006 NOT = N'U'
           AND OPCODE OF W-LPETM006 NOT = N'D'
              MOVE N'08' TO RETURNCODE OF W-LPETM006
              MOVE N'01' TO REASONCODE OF W-LPETM006
              MOVE N'OPCODE is invalid' TO INFOMESSAGE OF W-LPETM006
           END-IF

           IF  OPCODE OF W-LPETM006 NOT = N'C'
           AND OPCODE OF W-LPETM006 NOT = N'R'
              IF  RETURNCODE OF W-LPETM006 = N'00'
              AND ANIMALID OF W-LPETM006 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM006
                 MOVE N'02' TO REASONCODE OF W-LPETM006
                 MOVE N'ANIMALID is required' TO
                      INFOMESSAGE OF W-LPETM006
              END-IF
           END-IF

           IF   OPCODE OF W-LPETM006 = N'R'
              IF   ANIMALID OF W-LPETM006 = 0
              AND (STOREID  OF W-LPETM006 = 0
              OR   ANIMALTYPE OF W-LPETM006 = SPACES
              OR   ANIMALTYPE OF W-LPETM006 = LOW-VALUES
              OR   ANIMALRACE OF W-LPETM006 = SPACES
              OR   ANIMALRACE OF W-LPETM006 = LOW-VALUES
              OR   ANIMALNAME-LEN OF W-LPETM006 = 0
              OR   ANIMALNAME-TEXT OF W-LPETM006(1:
                      ANIMALNAME-LEN OF W-LPETM006) = SPACES
              OR   ANIMALNAME-TEXT OF W-LPETM006(1:
                      ANIMALNAME-LEN OF W-LPETM006) = LOW-VALUES)
                 MOVE N'08' TO RETURNCODE OF W-LPETM006
                 MOVE N'03' TO REASONCODE OF W-LPETM006
                 MOVE N'STOREID is required' TO
                      INFOMESSAGE OF W-LPETM006
              END-IF
           END-IF

           IF OPCODE OF W-LPETM006 = N'C'
           OR OPCODE OF W-LPETM006 = N'U'
              IF  RETURNCODE OF W-LPETM006 = N'00'
              AND STOREID OF W-LPETM006 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM006
                 MOVE N'03' TO REASONCODE OF W-LPETM006
                 MOVE N'STOREID is required' TO
                      INFOMESSAGE OF W-LPETM006
              END-IF

              IF  RETURNCODE OF W-LPETM006 = N'00'
              AND ANIMALTYPE OF W-LPETM006 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM006
                 MOVE N'04' TO REASONCODE OF W-LPETM006
                 MOVE N'ANIMALTYPE is required' TO
                      INFOMESSAGE OF W-LPETM006
              END-IF

              IF  RETURNCODE OF W-LPETM006 = N'00'
              AND ANIMALRACE OF W-LPETM006 = SPACES
                 MOVE N'08' TO RETURNCODE OF W-LPETM006
                 MOVE N'05' TO REASONCODE OF W-LPETM006
                 MOVE N'ANIMALRACE is required' TO
                      INFOMESSAGE OF W-LPETM006
              END-IF

              IF  RETURNCODE OF W-LPETM006 = N'00'
              AND ANIMALCOUNT OF W-LPETM006 = 0
                 MOVE N'08' TO RETURNCODE OF W-LPETM006
                 MOVE N'06' TO REASONCODE OF W-LPETM006
                 MOVE N'ANIMALCOUNT is required' TO
                      INFOMESSAGE OF W-LPETM006
              END-IF

              IF CREATEDBY OF W-LPETM006 = SPACES
              OR CREATEDBY OF W-LPETM006 = LOW-VALUES
              OR UPDATEDBY OF W-LPETM006 = SPACES
              OR UPDATEDBY OF W-LPETM006 = LOW-VALUES
                 MOVE 'PETA990' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA990

                 IF RETURNCODE OF W-LPETA990 = N'00'
                    IF CREATEDBY OF W-LPETM006 = SPACES
                    OR CREATEDBY OF W-LPETM006 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            CREATEDBY OF W-LPETM006
                    END-IF

                    IF UPDATEDBY OF W-LPETM006 = SPACES
                    OR UPDATEDBY OF W-LPETM006 = LOW-VALUES
                       MOVE USERID OF W-LPETA990 TO
                            UPDATEDBY OF W-LPETM006
                    END-IF
                 ELSE
                    MOVE N'08' TO RETURNCODE OF W-LPETM006
                    MOVE N'90' TO REASONCODE OF W-LPETM006
                    MOVE INFOMESSAGE OF W-LPETA990 TO
                         INFOMESSAGE OF W-LPETM006
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
           MOVE W-LPETM006 TO P-LPETM006
           .
       R009-FINISH-END.
           EXIT.

      *===============================================================*
      * R110-INSERT: INSERT a row into TBPET006 ANIMALS               *
      *===============================================================*
       R110-INSERT SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT ANIMALID,
                     CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET006.ANIMALID,
                     :DCLTBPET006.CREATEDDATE,
                     :DCLTBPET006.UPDATEDDATE
                FROM FINAL TABLE
                   (
              INSERT
                INTO TBPET006
                     (STOREID,
                      ANIMALTYPE,
                      ANIMALRACE,
                      ANIMALNAME,
                      ANIMALGENDER,
                      ANIMALAGE,
                      ANIMALCOUNT,
                      CREATEDBY,
                      CREATEDDATE,
                      UPDATEDBY,
                      UPDATEDDATE)
              VALUES(:DCLTBPET006.STOREID,
                     :DCLTBPET006.ANIMALTYPE,
                     :DCLTBPET006.ANIMALRACE,
                     :DCLTBPET006.ANIMALNAME,
                     :DCLTBPET006.ANIMALGENDER,
                     :DCLTBPET006.ANIMALAGE,
                     :DCLTBPET006.ANIMALCOUNT,
                     :DCLTBPET006.CREATEDBY,
                     CURRENT TIMESTAMP,
                     :DCLTBPET006.UPDATEDBY,
                     CURRENT TIMESTAMP)
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE ANIMALID OF DCLTBPET006 TO
                   ANIMALID OF W-LPETM006
              MOVE CREATEDDATE OF DCLTBPET006 TO
                   CREATEDDATE OF W-LPETM006
              MOVE UPDATEDDATE OF DCLTBPET006 TO
                   UPDATEDDATE OF W-LPETM006
           WHEN -803
              MOVE N'08' TO RETURNCODE OF W-LPETM006
              MOVE N'11' TO REASONCODE OF W-LPETM006
              MOVE N'TBPET006 duplicate entry' TO
                   INFOMESSAGE OF W-LPETM006
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM006
              MOVE N'12' TO REASONCODE OF W-LPETM006
              STRING N'INSERT gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM006
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R110-INSERT-END.
           EXIT.

      *===============================================================*
      * R120-SELECT: SELECT a row from TBPET006 ANIMALS               *
      *===============================================================*
       R120-SELECT SECTION.
           MOVE ANIMALID   OF W-LPETM006 TO ANIMALID OF DCLTBPET006
           MOVE STOREID    OF W-LPETM006 TO STOREID  OF DCLTBPET006
           MOVE ANIMALTYPE OF W-LPETM006 TO ANIMALTYPE OF DCLTBPET006
           MOVE ANIMALRACE OF W-LPETM006 TO ANIMALRACE OF DCLTBPET006
           MOVE ANIMALNAME OF W-LPETM006 TO ANIMALNAME OF DCLTBPET006

           EXEC SQL
              SELECT ANIMALID,
                     STOREID,
                     ANIMALTYPE,
                     ANIMALRACE,
                     ANIMALNAME,
                     ANIMALGENDER,
                     ANIMALAGE,
                     ANIMALCOUNT,
                     CREATEDBY,
                     CREATEDDATE,
                     UPDATEDBY,
                     UPDATEDDATE
                INTO :DCLTBPET006.ANIMALID,
                     :DCLTBPET006.STOREID,
                     :DCLTBPET006.ANIMALTYPE,
                     :DCLTBPET006.ANIMALRACE,
                     :DCLTBPET006.ANIMALNAME,
                     :DCLTBPET006.ANIMALGENDER,
                     :DCLTBPET006.ANIMALAGE,
                     :DCLTBPET006.ANIMALCOUNT,
                     :DCLTBPET006.CREATEDBY,
                     :DCLTBPET006.CREATEDDATE,
                     :DCLTBPET006.UPDATEDBY,
                     :DCLTBPET006.UPDATEDDATE
                FROM TBPET006
               WHERE ( ANIMALID   = :DCLTBPET006.ANIMALID
                  OR  (STOREID    = :DCLTBPET006.STOREID
                 AND   ANIMALTYPE = :DCLTBPET006.ANIMALTYPE
                 AND   ANIMALRACE = :DCLTBPET006.ANIMALRACE
                 AND   ANIMALNAME = :DCLTBPET006.ANIMALNAME))
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE ANIMALID     OF DCLTBPET006 TO
                   ANIMALID     OF W-LPETM006
              MOVE STOREID      OF DCLTBPET006 TO
                   STOREID      OF W-LPETM006
              MOVE ANIMALTYPE   OF DCLTBPET006 TO
                   ANIMALTYPE   OF W-LPETM006
              MOVE ANIMALRACE   OF DCLTBPET006 TO
                   ANIMALRACE   OF W-LPETM006
              MOVE ANIMALNAME   OF DCLTBPET006 TO
                   ANIMALNAME   OF W-LPETM006
              MOVE ANIMALGENDER OF DCLTBPET006 TO
                   ANIMALGENDER OF W-LPETM006
              MOVE ANIMALAGE    OF DCLTBPET006 TO
                   ANIMALAGE    OF W-LPETM006
              MOVE ANIMALCOUNT  OF DCLTBPET006 TO
                   ANIMALCOUNT  OF W-LPETM006
              MOVE CREATEDBY    OF DCLTBPET006 TO
                   CREATEDBY    OF W-LPETM006
              MOVE CREATEDDATE  OF DCLTBPET006 TO
                   CREATEDDATE  OF W-LPETM006
              MOVE UPDATEDBY    OF DCLTBPET006 TO
                   UPDATEDBY    OF W-LPETM006
              MOVE UPDATEDDATE  OF DCLTBPET006 TO
                   UPDATEDDATE  OF W-LPETM006
           WHEN 100
                MOVE N'04' TO RETURNCODE OF W-LPETM006
                MOVE N'01' TO REASONCODE OF W-LPETM006
                MOVE N'TBPET006 entry not found' TO
                   INFOMESSAGE OF W-LPETM006
           WHEN OTHER
                MOVE N'08' TO RETURNCODE OF W-LPETM006
                MOVE N'21' TO REASONCODE OF W-LPETM006
                STRING N'SELECT gave SQLCODE='
                       FUNCTION NATIONAL-OF(W-SQLCODE)
                   DELIMITED BY SIZE
                   INTO INFOMESSAGE OF W-LPETM006
                PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R120-SELECT-END.
           EXIT.

      *===============================================================*
      * R130-UPDATE: UPDATE a row in TBPET006 ANIMALS                 *
      *===============================================================*
       R130-UPDATE SECTION.
           PERFORM R210-COPY-TO-DCL

           EXEC SQL
              SELECT CREATEDDATE,
                     UPDATEDDATE
                INTO :DCLTBPET006.CREATEDDATE,
                     :DCLTBPET006.UPDATEDDATE
                FROM FINAL TABLE
                   (
              UPDATE TBPET006
                 SET STOREID      = :DCLTBPET006.STOREID,
                     ANIMALTYPE   = :DCLTBPET006.ANIMALTYPE,
                     ANIMALRACE   = :DCLTBPET006.ANIMALRACE,
                     ANIMALNAME   = :DCLTBPET006.ANIMALNAME,
                     ANIMALGENDER = :DCLTBPET006.ANIMALGENDER,
                     ANIMALAGE    = :DCLTBPET006.ANIMALAGE,
                     ANIMALCOUNT  = :DCLTBPET006.ANIMALCOUNT,
                     UPDATEDBY    = :DCLTBPET006.UPDATEDBY,
                     UPDATEDDATE  = CURRENT TIMESTAMP
               WHERE ANIMALID = :DCLTBPET006.ANIMALID
                     )
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              MOVE CREATEDDATE OF DCLTBPET006 TO
                   CREATEDDATE OF W-LPETM006
              MOVE UPDATEDDATE OF DCLTBPET006 TO
                   UPDATEDDATE OF W-LPETM006
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM006
              MOVE N'31' TO REASONCODE OF W-LPETM006
              MOVE N'TBPET006 entry not found' TO
                   INFOMESSAGE OF W-LPETM006
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM006
              MOVE N'32' TO REASONCODE OF W-LPETM006
              STRING N'UPDATE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM006
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R130-UPDATE-END.
           EXIT.

      *===============================================================*
      * R140-DELETE: DELETE a row from TBPET006 ANIMALS             *
      *===============================================================*
       R140-DELETE SECTION.
           MOVE ANIMALID OF W-LPETM006 TO ANIMALID OF DCLTBPET006

           EXEC SQL
              DELETE
                FROM TBPET006
               WHERE ANIMALID = :DCLTBPET006.ANIMALID
           END-EXEC

           MOVE SQLCODE TO W-SQLCODE

           EVALUATE SQLCODE
           WHEN 0
              CONTINUE
           WHEN 100
              MOVE N'08' TO RETURNCODE OF W-LPETM006
              MOVE N'41' TO REASONCODE OF W-LPETM006
              MOVE N'TBPET006 entry not found' TO
                   INFOMESSAGE OF W-LPETM006
           WHEN OTHER
              MOVE N'08' TO RETURNCODE OF W-LPETM006
              MOVE N'42' TO REASONCODE OF W-LPETM006
              STRING N'DELETE gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF W-LPETM006
              PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R140-DELETE-END.
           EXIT.

      *===============================================================*
      * R210-COPY-TO-DCL: Copy from copybook to DCLTBPET006           *
      *===============================================================*
       R210-COPY-TO-DCL SECTION.
           MOVE ANIMALID     OF W-LPETM006 TO ANIMALID    OF DCLTBPET006
           MOVE STOREID      OF W-LPETM006 TO STOREID     OF DCLTBPET006
           MOVE ANIMALTYPE   OF W-LPETM006 TO ANIMALTYPE  OF DCLTBPET006
           MOVE ANIMALRACE   OF W-LPETM006 TO ANIMALRACE  OF DCLTBPET006
           MOVE ANIMALNAME   OF W-LPETM006 TO ANIMALNAME  OF DCLTBPET006
           MOVE ANIMALGENDER OF W-LPETM006 TO
                ANIMALGENDER OF DCLTBPET006
           MOVE ANIMALAGE    OF W-LPETM006 TO ANIMALAGE   OF DCLTBPET006
           MOVE ANIMALCOUNT  OF W-LPETM006 TO ANIMALCOUNT OF DCLTBPET006
           MOVE CREATEDBY    OF W-LPETM006 TO CREATEDBY   OF DCLTBPET006
           MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM006) TO
              CREATEDDATE OF DCLTBPET006
           MOVE UPDATEDBY    OF W-LPETM006 TO UPDATEDBY   OF DCLTBPET006
           MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM006) TO
              UPDATEDDATE OF DCLTBPET006
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

       END PROGRAM PETM006.
