       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETM201
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET001 REFTABLES table.                                     *
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

           EXEC SQL INCLUDE TBPET001 END-EXEC.

       01 WORK.
          05 W-PGMNAME         PIC X(8).
          05 W-SQLCODE         PIC -99999.
          05 W-TABLEID-FILTER  PIC N(08).
          05 W-TABLEID-SINCE   PIC N(08).
          05 W-TABKEY-SINCE    PIC N(08).

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM201.
           COPY LPETM201.

       PROCEDURE DIVISION USING P-LPETM201.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R005-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM201 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE 
                UNTIL RETURNCODE OF P-LPETM201 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR REFTABLE-COUNT OF P-LPETM201 >= 20
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
           MOVE N'00' TO RETURNCODE OF P-LPETM201
           MOVE N'00' TO REASONCODE OF P-LPETM201
           MOVE SPACES TO INFOMESSAGE OF P-LPETM201

           MOVE 0 TO REFTABLE-COUNT OF P-LPETM201

           MOVE N'%%%%%%%%' TO W-TABLEID-FILTER
           IF  TABLEID-FILTER OF P-LPETM201 NOT = LOW-VALUES
           AND TABLEID-FILTER OF P-LPETM201 NOT = SPACES
              STRING TABLEID-FILTER OF P-LPETM201
                        DELIMITED BY SPACE
                INTO W-TABLEID-FILTER
           END-IF

           MOVE TABLEID-SINCE OF P-LPETM201 TO W-TABLEID-SINCE
           MOVE TABKEY-SINCE  OF P-LPETM201 TO W-TABKEY-SINCE
           .
       R001-INIT-END. 
           EXIT.

      *===============================================================*
      * R005-OPEN-CURSOR: Open DB2 cursor for SELECT REFTABLES        *
      *===============================================================*
       R005-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  TABLEID,
                         TABKEY,
                         TABVALUE,
                         CREATEDBY,
                         CREATEDDATE,
                         UPDATEDBY,
                         UPDATEDDATE
                   FROM  TBPET001
                  WHERE  TABLEID LIKE :W-TABLEID-FILTER
                    AND  TABLEID >=   :W-TABLEID-SINCE
                    AND (TABLEID >    :W-TABLEID-SINCE
                     OR  TABKEY  >    :W-TABKEY-SINCE)
                    FOR  FETCH ONLY
                  FETCH  FIRST 20 ROWS ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM201
              MOVE N'01' TO REASONCODE OF P-LPETM201
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM201
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
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT REFTABLES      *
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM201
              MOVE N'02' TO REASONCODE OF P-LPETM201
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM201
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT REFTABLES      *
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
               INTO :DCLTBPET001.TABLEID,
                    :DCLTBPET001.TABKEY,
                    :DCLTBPET001.TABVALUE :DCLTBPET001.TABVALUE-IND,
                    :DCLTBPET001.CREATEDBY,
                    :DCLTBPET001.CREATEDDATE,
                    :DCLTBPET001.UPDATEDBY,
                    :DCLTBPET001.UPDATEDDATE
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO REFTABLE-COUNT OF P-LPETM201

                 MOVE TABLEID OF DCLTBPET001 TO TABLEID OF P-LPETM201(
                        REFTABLE-COUNT OF P-LPETM201)
                 MOVE TABKEY  OF DCLTBPET001 TO TABKEY  OF P-LPETM201(
                        REFTABLE-COUNT OF P-LPETM201)
                 IF TABVALUE-IND OF DCLTBPET001 = 0
                    MOVE TABVALUE-LEN OF DCLTBPET001 TO 
                         TABVALUE-LEN OF P-LPETM201(
                            REFTABLE-COUNT OF P-LPETM201)
                    MOVE TABVALUE-TEXT OF DCLTBPET001(1:
                            TABVALUE-LEN OF DCLTBPET001) TO
                         TABVALUE-TEXT OF P-LPETM201(
                            REFTABLE-COUNT OF P-LPETM201)
                 END-IF
                 MOVE CREATEDBY OF DCLTBPET001 TO
                      CREATEDBY OF P-LPETM201(
                         REFTABLE-COUNT OF P-LPETM201)
                 MOVE CREATEDDATE OF DCLTBPET001 TO
                      CREATEDDATE OF P-LPETM201(
                         REFTABLE-COUNT OF P-LPETM201)
                 MOVE UPDATEDBY OF DCLTBPET001 TO
                      UPDATEDBY OF P-LPETM201(
                         REFTABLE-COUNT OF P-LPETM201)
                 MOVE UPDATEDDATE OF DCLTBPET001 TO
                      UPDATEDDATE OF P-LPETM201(
                         REFTABLE-COUNT OF P-LPETM201)
              WHEN 100
                 IF REFTABLE-COUNT OF P-LPETM201 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM201
                    MOVE N'01' TO REASONCODE OF P-LPETM201
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM201 
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE
              
                 MOVE N'08' TO RETURNCODE OF P-LPETM201
                 MOVE N'03' TO REASONCODE OF P-LPETM201
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM201
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

       END PROGRAM PETM201.