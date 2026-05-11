       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETM207
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET007 PRICESANDDISCOUNTS table.                            *
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
          05 W-PGMNAME                     PIC X(8).
          05 W-SQLCODE                     PIC -99999.
          05 W-STOREID-FILTER              PIC S9(9) COMP-5.
          05 W-PRODUCTID-FILTER            PIC S9(9) COMP-5.
          05 W-ANIMALID-FILTER             PIC S9(9) COMP-5.
          05 W-PADID-SINCE                 PIC S9(9) COMP-5.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM207.
           COPY LPETM207.

       PROCEDURE DIVISION USING P-LPETM207.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R007-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM207 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE 
                UNTIL RETURNCODE OF P-LPETM207 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR PAD-COUNT OF P-LPETM207 >= 20
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
           MOVE N'00' TO RETURNCODE OF P-LPETM207
           MOVE N'00' TO REASONCODE OF P-LPETM207
           MOVE SPACES TO INFOMESSAGE OF P-LPETM207

           MOVE 0 TO PAD-COUNT OF P-LPETM207

           MOVE STOREID-FILTER OF P-LPETM207 TO W-STOREID-FILTER
           MOVE PRODUCTID-FILTER OF P-LPETM207 TO W-PRODUCTID-FILTER
           MOVE ANIMALID-FILTER OF P-LPETM207 TO W-ANIMALID-FILTER
           MOVE PADID-SINCE OF P-LPETM207 TO W-PADID-SINCE
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R007-OPEN-CURSOR: Open DB2 cursor for SELECT PRICESANDDISCOUNT*
      *===============================================================*
       R007-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  PADID,
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
                   FROM  TBPET007
                  WHERE (:W-STOREID-FILTER = 0
                     OR  STOREID   = :W-STOREID-FILTER)
                    AND (:W-PRODUCTID-FILTER = 0
                     OR  PRODUCTID = :W-PRODUCTID-FILTER)
                    AND (:W-ANIMALID-FILTER = 0
                     OR  ANIMALID = :W-ANIMALID-FILTER)
                    AND  PADID > :W-PADID-SINCE
                    FOR  FETCH ONLY
                  FETCH  FIRST 20 ROWS ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM207
              MOVE N'01' TO REASONCODE OF P-LPETM207
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM207
              PERFORM R900-DSNTIAR
           END-IF
           .
       R007-OPEN-CURSOR-END.
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
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT PRICESANDDISCOU*
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM207
              MOVE N'02' TO REASONCODE OF P-LPETM207
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM207
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT PRICESANDDISCOU*
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
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
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO PAD-COUNT OF P-LPETM207

                 MOVE PADID OF DCLTBPET007 TO
                      PADID OF P-LPETM207(
                         PAD-COUNT OF P-LPETM207)
                 MOVE STOREID OF DCLTBPET007 TO
                         STOREID OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 IF PRODUCTID-IND OF DCLTBPET007 < 0
                    MOVE 0 TO PRODUCTID OF P-LPETM207(
                       PAD-COUNT OF P-LPETM207)
                 ELSE
                    MOVE PRODUCTID OF DCLTBPET007 TO
                         PRODUCTID OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 END-IF
                 IF ANIMALID-IND OF DCLTBPET007 < 0
                    MOVE 0 TO ANIMALID OF P-LPETM207(
                       PAD-COUNT OF P-LPETM207)
                 ELSE
                    MOVE ANIMALID OF DCLTBPET007 TO
                         ANIMALID OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 END-IF
                 IF PRICE-IND OF DCLTBPET007 < 0
                    MOVE 0 TO PRICE OF P-LPETM207(
                       PAD-COUNT OF P-LPETM207)
                 ELSE
                    MOVE PRICE OF DCLTBPET007 TO
                         PRICE OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 END-IF
                 IF DISCOUNT-IND OF DCLTBPET007 < 0
                    MOVE 0 TO DISCOUNT OF P-LPETM207(
                       PAD-COUNT OF P-LPETM207)
                 ELSE
                    MOVE DISCOUNT OF DCLTBPET007 TO
                         DISCOUNT OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 END-IF
                 IF FROMDATE-IND OF DCLTBPET007 < 0
                    MOVE '1900-01-01-00:00:00.000000' TO
                         FROMDATE OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 ELSE
                    MOVE FROMDATE OF DCLTBPET007 TO
                         FROMDATE OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 END-IF
                 IF TODATE-IND OF DCLTBPET007 < 0
                    MOVE '1900-01-01-00:00:00.000000' TO
                         TODATE OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 ELSE
                    MOVE TODATE OF DCLTBPET007 TO
                         TODATE OF P-LPETM207(
                            PAD-COUNT OF P-LPETM207)
                 END-IF
                 MOVE CREATEDBY OF DCLTBPET007 TO
                      CREATEDBY OF P-LPETM207(
                         PAD-COUNT OF P-LPETM207)
                 MOVE CREATEDDATE OF DCLTBPET007 TO
                      CREATEDDATE OF P-LPETM207(
                         PAD-COUNT OF P-LPETM207)
                 MOVE UPDATEDBY OF DCLTBPET007 TO
                      UPDATEDBY OF P-LPETM207(
                         PAD-COUNT OF P-LPETM207)
                 MOVE UPDATEDDATE OF DCLTBPET007 TO
                      UPDATEDDATE OF P-LPETM207(
                         PAD-COUNT OF P-LPETM207)
              WHEN 100
                 IF PAD-COUNT OF P-LPETM207 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM207
                    MOVE N'01' TO REASONCODE OF P-LPETM207
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM207 
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE
              
                 MOVE N'08' TO RETURNCODE OF P-LPETM207
                 MOVE N'03' TO REASONCODE OF P-LPETM207
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM207
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

       END PROGRAM PETM207.