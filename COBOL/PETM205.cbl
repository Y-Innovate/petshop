       IDENTIFICATION DIVISION.
       PROGRAM-ID.     PETM205
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET005 INVENTORY table.                                     *
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

           EXEC SQL INCLUDE TBPET005 END-EXEC.

       01 WORK.
          05 W-PGMNAME                     PIC X(8).
          05 W-SQLCODE                     PIC -99999.
          05 W-STOREID-FILTER              PIC S9(9) COMP-5.
          05 W-PRODUCTID-SINCE             PIC S9(9) COMP-5.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM205.
           COPY LPETM205.

       PROCEDURE DIVISION USING P-LPETM205.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R005-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM205 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE 
                UNTIL RETURNCODE OF P-LPETM205 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR INVENTORY-COUNT OF P-LPETM205 >= 20
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
           MOVE N'00' TO RETURNCODE OF P-LPETM205
           MOVE N'00' TO REASONCODE OF P-LPETM205
           MOVE SPACES TO INFOMESSAGE OF P-LPETM205

           MOVE 0 TO INVENTORY-COUNT OF P-LPETM205

           MOVE STOREID-FILTER OF P-LPETM205 TO W-STOREID-FILTER
           MOVE PRODUCTID-SINCE OF P-LPETM205 TO W-PRODUCTID-SINCE
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R005-OPEN-CURSOR: Open DB2 cursor for SELECT INVENTORY        *
      *===============================================================*
       R005-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  INVENTORYID,
                         STOREID,
                         PRODUCTID,
                         SELLBYDATE,
                         INSTOCK,
                         CREATEDBY,
                         CREATEDDATE,
                         UPDATEDBY,
                         UPDATEDDATE
                   FROM  TBPET005
                  WHERE  STOREID   = :W-STOREID-FILTER
                    AND  PRODUCTID > :W-PRODUCTID-SINCE
                    FOR  FETCH ONLY
                  FETCH  FIRST 20 ROWS ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM205
              MOVE N'01' TO REASONCODE OF P-LPETM205
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM205
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
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT INVENTORY      *
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM205
              MOVE N'02' TO REASONCODE OF P-LPETM205
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM205
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT INVENTORY      *
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
               INTO :DCLTBPET005.INVENTORYID,
                    :DCLTBPET005.STOREID,
                    :DCLTBPET005.PRODUCTID,
                    :DCLTBPET005.SELLBYDATE,
                    :DCLTBPET005.INSTOCK,
                    :DCLTBPET005.CREATEDBY,
                    :DCLTBPET005.CREATEDDATE,
                    :DCLTBPET005.UPDATEDBY,
                    :DCLTBPET005.UPDATEDDATE
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO INVENTORY-COUNT OF P-LPETM205

                 MOVE INVENTORYID OF DCLTBPET005 TO
                      INVENTORYID OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
                 MOVE STOREID OF DCLTBPET005 TO
                         STOREID OF P-LPETM205(
                            INVENTORY-COUNT OF P-LPETM205)
                 MOVE PRODUCTID OF DCLTBPET005 TO
                      PRODUCTID OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
                 MOVE SELLBYDATE OF DCLTBPET005 TO
                      SELLBYDATE OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
                 MOVE INSTOCK OF DCLTBPET005 TO
                      INSTOCK OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
                 MOVE CREATEDBY OF DCLTBPET005 TO
                      CREATEDBY OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
                 MOVE CREATEDDATE OF DCLTBPET005 TO
                      CREATEDDATE OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
                 MOVE UPDATEDBY OF DCLTBPET005 TO
                      UPDATEDBY OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
                 MOVE UPDATEDDATE OF DCLTBPET005 TO
                      UPDATEDDATE OF P-LPETM205(
                         INVENTORY-COUNT OF P-LPETM205)
              WHEN 100
                 IF INVENTORY-COUNT OF P-LPETM205 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM205
                    MOVE N'01' TO REASONCODE OF P-LPETM205
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM205 
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE
              
                 MOVE N'08' TO RETURNCODE OF P-LPETM205
                 MOVE N'03' TO REASONCODE OF P-LPETM205
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM205
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

       END PROGRAM PETM205.