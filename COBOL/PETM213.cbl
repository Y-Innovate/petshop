       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETM213
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET013 STORESUPPL table.                                    *
      * ------------------------------------------------------------- *
      * Input:                                                        *
      *   STOREID-FILTER, SUPPLIERID-FILTER: 0 = no filter            *
      *   STOREID-SINCE, SUPPLIERID-SINCE: pagination, return entries *
      *     after this key (both 0 = start at the beginning)          *
      * Output:                                                       *
      *   Up to 20 entries ordered by STOREID, SUPPLIERID. NULL       *
      *   FROMDATE and TODATE are returned as spaces.                 *
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

           EXEC SQL INCLUDE TBPET013 END-EXEC.

       01 WORK.
          05 W-PGMNAME                     PIC X(8).
          05 W-SQLCODE                     PIC -99999.
          05 W-STOREID-FILTER              PIC S9(9) COMP-5.
          05 W-SUPPLIERID-FILTER           PIC S9(9) COMP-5.
          05 W-STOREID-SINCE               PIC S9(9) COMP-5.
          05 W-SUPPLIERID-SINCE            PIC S9(9) COMP-5.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM213.
           COPY LPETM213.

       PROCEDURE DIVISION USING P-LPETM213.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R007-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM213 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE
                UNTIL RETURNCODE OF P-LPETM213 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR STORESUPPL-COUNT OF P-LPETM213 >= 20
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
           MOVE N'00' TO RETURNCODE OF P-LPETM213
           MOVE N'00' TO REASONCODE OF P-LPETM213
           MOVE SPACES TO INFOMESSAGE OF P-LPETM213

           MOVE 0 TO STORESUPPL-COUNT OF P-LPETM213

           MOVE STOREID-FILTER OF P-LPETM213 TO W-STOREID-FILTER
           MOVE SUPPLIERID-FILTER OF P-LPETM213 TO W-SUPPLIERID-FILTER
           MOVE STOREID-SINCE OF P-LPETM213 TO W-STOREID-SINCE
           MOVE SUPPLIERID-SINCE OF P-LPETM213 TO W-SUPPLIERID-SINCE
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R007-OPEN-CURSOR: Open DB2 cursor for SELECT STORESUPPL       *
      *===============================================================*
       R007-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  STOREID,
                         SUPPLIERID,
                         FROMDATE,
                         TODATE,
                         CREATEDBY,
                         CREATEDDATE,
                         UPDATEDBY,
                         UPDATEDDATE
                   FROM  TBPET013
                  WHERE (:W-STOREID-FILTER = 0
                     OR  STOREID    = :W-STOREID-FILTER)
                    AND (:W-SUPPLIERID-FILTER = 0
                     OR  SUPPLIERID = :W-SUPPLIERID-FILTER)
                    AND (STOREID    > :W-STOREID-SINCE
                     OR (STOREID    = :W-STOREID-SINCE
                    AND  SUPPLIERID > :W-SUPPLIERID-SINCE))
                  ORDER  BY STOREID, SUPPLIERID
                  FETCH  FIRST 20 ROWS ONLY
                    FOR  FETCH ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE

              MOVE N'08' TO RETURNCODE OF P-LPETM213
              MOVE N'01' TO REASONCODE OF P-LPETM213
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM213
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
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT STORESUPPL     *
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE

              MOVE N'08' TO RETURNCODE OF P-LPETM213
              MOVE N'02' TO REASONCODE OF P-LPETM213
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM213
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT STORESUPPL     *
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
               INTO :DCLTBPET013.STOREID,
                    :DCLTBPET013.SUPPLIERID,
                    :DCLTBPET013.FROMDATE
                      :DCLTBPET013.FROMDATE-IND,
                    :DCLTBPET013.TODATE
                      :DCLTBPET013.TODATE-IND,
                    :DCLTBPET013.CREATEDBY,
                    :DCLTBPET013.CREATEDDATE,
                    :DCLTBPET013.UPDATEDBY,
                    :DCLTBPET013.UPDATEDDATE
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO STORESUPPL-COUNT OF P-LPETM213

                 MOVE STOREID OF DCLTBPET013 TO
                      STOREID OF P-LPETM213(
                         STORESUPPL-COUNT OF P-LPETM213)
                 MOVE SUPPLIERID OF DCLTBPET013 TO
                      SUPPLIERID OF P-LPETM213(
                         STORESUPPL-COUNT OF P-LPETM213)
                 IF FROMDATE-IND OF DCLTBPET013 < 0
                    MOVE SPACES TO
                         FROMDATE OF P-LPETM213(
                            STORESUPPL-COUNT OF P-LPETM213)
                 ELSE
                    MOVE FROMDATE OF DCLTBPET013 TO
                         FROMDATE OF P-LPETM213(
                            STORESUPPL-COUNT OF P-LPETM213)
                 END-IF
                 IF TODATE-IND OF DCLTBPET013 < 0
                    MOVE SPACES TO
                         TODATE OF P-LPETM213(
                            STORESUPPL-COUNT OF P-LPETM213)
                 ELSE
                    MOVE TODATE OF DCLTBPET013 TO
                         TODATE OF P-LPETM213(
                            STORESUPPL-COUNT OF P-LPETM213)
                 END-IF
                 MOVE CREATEDBY OF DCLTBPET013 TO
                      CREATEDBY OF P-LPETM213(
                         STORESUPPL-COUNT OF P-LPETM213)
                 MOVE CREATEDDATE OF DCLTBPET013 TO
                      CREATEDDATE OF P-LPETM213(
                         STORESUPPL-COUNT OF P-LPETM213)
                 MOVE UPDATEDBY OF DCLTBPET013 TO
                      UPDATEDBY OF P-LPETM213(
                         STORESUPPL-COUNT OF P-LPETM213)
                 MOVE UPDATEDDATE OF DCLTBPET013 TO
                      UPDATEDDATE OF P-LPETM213(
                         STORESUPPL-COUNT OF P-LPETM213)
              WHEN 100
                 IF STORESUPPL-COUNT OF P-LPETM213 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM213
                    MOVE N'01' TO REASONCODE OF P-LPETM213
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM213
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE

                 MOVE N'08' TO RETURNCODE OF P-LPETM213
                 MOVE N'03' TO REASONCODE OF P-LPETM213
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM213
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

       END PROGRAM PETM213.
