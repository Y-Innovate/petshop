       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETM206
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET006 ANIMALS table.                                       *
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
          05 W-PGMNAME                     PIC X(8).
          05 W-SQLCODE                     PIC -99999.
          05 W-STOREID-FILTER              PIC S9(9) COMP-5.
          05 W-ANIMALTYPE-FILTER           PIC N(08).
          05 W-ANIMALRACE-FILTER           PIC N(08).
          05 W-ANIMALID-SINCE              PIC S9(9) COMP-5.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM206.
           COPY LPETM206.

       PROCEDURE DIVISION USING P-LPETM206.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R006-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM206 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE 
                UNTIL RETURNCODE OF P-LPETM206 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR ANIMAL-ENTRY-COUNT OF P-LPETM206 >= 20
                 PERFORM R210-FETCH-CURSOR
              END-PERFORM

              PERFORM R190-CLOSE-CURSOR
           END-IF

           PERFORM R009-FINISH
           .
       MAIN-END.
           GOBACK.

      *===============================================================*
      * R001-INIT: Program initialisations                            *
      *===============================================================*
       R001-INIT SECTION.
           MOVE N'00' TO RETURNCODE OF P-LPETM206
           MOVE N'00' TO REASONCODE OF P-LPETM206
           MOVE SPACES TO INFOMESSAGE OF P-LPETM206

           MOVE 0 TO ANIMAL-ENTRY-COUNT OF P-LPETM206

           MOVE STOREID-FILTER OF P-LPETM206 TO W-STOREID-FILTER
           IF ANIMALTYPE-FILTER IN LPETM206 = LOW-VALUES
              MOVE SPACES TO W-ANIMALTYPE-FILTER
           ELSE
                 MOVE ANIMALTYPE-FILTER OF P-LPETM206 TO
                      W-ANIMALTYPE-FILTER
           END-IF
           IF ANIMALRACE-FILTER IN LPETM206 = LOW-VALUES
              MOVE SPACES TO W-ANIMALRACE-FILTER
           ELSE
              MOVE ANIMALRACE-FILTER OF P-LPETM206 TO
                   W-ANIMALRACE-FILTER
           END-IF
           MOVE ANIMALID-SINCE OF P-LPETM206 TO W-ANIMALID-SINCE
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R006-OPEN-CURSOR: Open DB2 cursor for SELECT ANIMALS          *
      *===============================================================*
       R006-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  ANIMALID,
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
                   FROM  TBPET006
                  WHERE  STOREID   = :W-STOREID-FILTER
                    AND (:W-ANIMALTYPE-FILTER = ''
                     OR   ANIMALTYPE = :W-ANIMALTYPE-FILTER)
                    AND (:W-ANIMALRACE-FILTER = ''
                     OR   ANIMALRACE = :W-ANIMALRACE-FILTER)
                    AND  ANIMALID > :W-ANIMALID-SINCE
                    FOR  FETCH ONLY
                  FETCH  FIRST 20 ROWS ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM206
              MOVE N'01' TO REASONCODE OF P-LPETM206
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM206
              PERFORM R900-DSNTIAR
           END-IF
           .
       R006-OPEN-CURSOR-END.
           EXIT.

      *===============================================================*
      * R009-FINISH: Program finalisations                            *
      *===============================================================*
       R009-FINISH SECTION.
           CONTINUE 
           .
       R009-FINISH-END. 
           EXIT.

      *===============================================================*
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT ANIMALS        *
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM206
              MOVE N'02' TO REASONCODE OF P-LPETM206
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM206
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT ANIMALS        *
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
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
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO ANIMAL-ENTRY-COUNT OF P-LPETM206

                 MOVE ANIMALID OF DCLTBPET006 TO
                      ANIMALID OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE STOREID OF DCLTBPET006 TO
                         STOREID OF P-LPETM206(
                            ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE ANIMALTYPE OF DCLTBPET006 TO
                      ANIMALTYPE OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE ANIMALRACE OF DCLTBPET006 TO
                      ANIMALRACE OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE ANIMALNAME-LEN OF DCLTBPET006 TO
                         ANIMALNAME-LEN OF P-LPETM206(
                            ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE ANIMALNAME-TEXT OF DCLTBPET006(1:
                         ANIMALNAME-LEN OF DCLTBPET006) TO
                      ANIMALNAME-TEXT OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE ANIMALGENDER OF DCLTBPET006 TO
                      ANIMALGENDER OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE ANIMALGENDER OF DCLTBPET006 TO
                      ANIMALGENDER OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE ANIMALCOUNT OF DCLTBPET006 TO
                      ANIMALCOUNT OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE CREATEDBY OF DCLTBPET006 TO
                      CREATEDBY OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE CREATEDDATE OF DCLTBPET006 TO
                      CREATEDDATE OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE UPDATEDBY OF DCLTBPET006 TO
                      UPDATEDBY OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
                 MOVE UPDATEDDATE OF DCLTBPET006 TO
                      UPDATEDDATE OF P-LPETM206(
                         ANIMAL-ENTRY-COUNT OF P-LPETM206)
              WHEN 100
                 IF ANIMAL-ENTRY-COUNT OF P-LPETM206 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM206
                    MOVE N'01' TO REASONCODE OF P-LPETM206
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM206 
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE
              
                 MOVE N'08' TO RETURNCODE OF P-LPETM206
                 MOVE N'03' TO REASONCODE OF P-LPETM206
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM206
                 PERFORM R900-DSNTIAR
           END-EVALUATE
           .
       R210-FETCH-CURSOR-END.
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

       END PROGRAM PETM206.