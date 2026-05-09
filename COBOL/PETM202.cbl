       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETM202
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET002 STORES table.                                        *
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
          05 W-PGMNAME                  PIC X(8).
          05 W-SQLCODE                  PIC -99999.
          05 W-STORENAME-FILTER.
             49 W-STORENAME-FILTER-LEN  PIC S9(4) COMP-5.
             49 W-STORENAME-FILTER-TEXT PIC N(256).
          05 W-STOREID-SINCE            PIC S9(9) COMP-5.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM202.
           COPY LPETM202.

       PROCEDURE DIVISION USING P-LPETM202.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R005-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM202 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE 
                UNTIL RETURNCODE OF P-LPETM202 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR STORE-COUNT OF P-LPETM202 >= 20
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
           MOVE N'00' TO RETURNCODE OF P-LPETM202
           MOVE N'00' TO REASONCODE OF P-LPETM202
           MOVE SPACES TO INFOMESSAGE OF P-LPETM202

           MOVE 0 TO STORE-COUNT OF P-LPETM202

           IF STORENAME-FILTER-LEN OF P-LPETM202 = 0
              MOVE 1 TO W-STORENAME-FILTER-LEN
              MOVE N'%' TO W-STORENAME-FILTER-TEXT(1:1)
           ELSE
              IF STORENAME-FILTER-TEXT OF P-LPETM202(1:
                    STORENAME-FILTER-LEN OF P-LPETM202) NOT = SPACES
                 MOVE 1 TO W-STORENAME-FILTER-LEN
                 STRING FUNCTION UPPER-CASE(
                           STORENAME-FILTER-TEXT OF P-LPETM202(1:
                              STORENAME-FILTER-LEN OF P-LPETM202))
                        N'%'
                        DELIMITED BY SIZE
                   INTO W-STORENAME-FILTER-TEXT
                   WITH POINTER W-STORENAME-FILTER-LEN
                 SUBTRACT 1 FROM W-STORENAME-FILTER-LEN
              END-IF
           END-IF

           MOVE STOREID-SINCE OF P-LPETM202 TO W-STOREID-SINCE
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R005-OPEN-CURSOR: Open DB2 cursor for SELECT STORES           *
      *===============================================================*
       R005-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  STOREID,
                         STORENAME,
                         STORENAMEU,
                         STORECODE,
                         STORESTATUS,
                         CREATEDBY,
                         CREATEDDATE,
                         UPDATEDBY,
                         UPDATEDDATE
                   FROM  TBPET002
                  WHERE  STORENAMEU LIKE :W-STORENAME-FILTER
                    AND  STOREID    >    :W-STOREID-SINCE
                    FOR  FETCH ONLY
                  FETCH  FIRST 20 ROWS ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM202
              MOVE N'01' TO REASONCODE OF P-LPETM202
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM202
              PERFORM R900-DSNTIAR
           END-IF
           .
       R005-OPEN-CURSOR-END.
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
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT STORES         *
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM202
              MOVE N'02' TO REASONCODE OF P-LPETM202
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM202
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT STORES         *
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
               INTO :DCLTBPET002.STOREID,
                    :DCLTBPET002.STORENAME,
                    :DCLTBPET002.STORENAMEU,
                    :DCLTBPET002.STORECODE,
                    :DCLTBPET002.STORESTATUS,
                    :DCLTBPET002.CREATEDBY,
                    :DCLTBPET002.CREATEDDATE,
                    :DCLTBPET002.UPDATEDBY,
                    :DCLTBPET002.UPDATEDDATE
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO STORE-COUNT OF P-LPETM202

                 MOVE STOREID OF DCLTBPET002 TO STOREID OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE STORENAME-LEN OF DCLTBPET002 TO
                         STORENAME-LEN OF P-LPETM202(
                            STORE-COUNT OF P-LPETM202)
                 MOVE STORENAME-TEXT OF DCLTBPET002(1:
                         STORENAME-LEN OF DCLTBPET002) TO
                      STORENAME-TEXT OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE STORENAMEU-LEN OF DCLTBPET002 TO
                         STORENAMEU-LEN OF P-LPETM202(
                            STORE-COUNT OF P-LPETM202)
                 MOVE STORENAMEU-TEXT OF DCLTBPET002(1:
                         STORENAMEU-LEN OF DCLTBPET002) TO
                      STORENAMEU-TEXT OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE STORECODE OF DCLTBPET002 TO
                      STORECODE OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE STORESTATUS OF DCLTBPET002 TO
                      STORESTATUS OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE CREATEDBY OF DCLTBPET002 TO
                      CREATEDBY OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE CREATEDDATE OF DCLTBPET002 TO
                      CREATEDDATE OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE UPDATEDBY OF DCLTBPET002 TO
                      UPDATEDBY OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
                 MOVE UPDATEDDATE OF DCLTBPET002 TO
                      UPDATEDDATE OF P-LPETM202(
                         STORE-COUNT OF P-LPETM202)
              WHEN 100
                 IF STORE-COUNT OF P-LPETM202 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM202
                    MOVE N'01' TO REASONCODE OF P-LPETM202
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM202 
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE
              
                 MOVE N'08' TO RETURNCODE OF P-LPETM202
                 MOVE N'03' TO REASONCODE OF P-LPETM202
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM202
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

       END PROGRAM PETM202.