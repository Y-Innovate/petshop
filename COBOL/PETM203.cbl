       IDENTIFICATION DIVISION.
       PROGRAM-ID.  PETM203
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET003 SUPPLIERS table.                                     *
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

           EXEC SQL INCLUDE TBPET003 END-EXEC.

       01 WORK.
          05 W-PGMNAME                     PIC X(8).
          05 W-SQLCODE                     PIC -99999.
          05 W-SUPPLIERNAME-FILTER.
             49 W-SUPPLIERNAME-FILTER-LEN  PIC S9(4) COMP-5.
             49 W-SUPPLIERNAME-FILTER-TEXT PIC N(256).
          05 W-SUPPLIERID-SINCE            PIC S9(9) COMP-5.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM203.
           COPY LPETM203.

       PROCEDURE DIVISION USING P-LPETM203.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R005-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM203 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE 
                UNTIL RETURNCODE OF P-LPETM203 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR SUPPLIER-COUNT OF P-LPETM203 >= 20
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
           MOVE N'00' TO RETURNCODE OF P-LPETM203
           MOVE N'00' TO REASONCODE OF P-LPETM203
           MOVE SPACES TO INFOMESSAGE OF P-LPETM203

           MOVE 0 TO SUPPLIER-COUNT OF P-LPETM203

           IF SUPPLIERNAME-FILTER-LEN OF P-LPETM203 = 0
              MOVE 1 TO W-SUPPLIERNAME-FILTER-LEN
              MOVE N'%' TO W-SUPPLIERNAME-FILTER-TEXT(1:1)
           ELSE
              IF SUPPLIERNAME-FILTER-TEXT OF P-LPETM203(1:
                    SUPPLIERNAME-FILTER-LEN OF P-LPETM203) NOT = SPACES
                 MOVE 1 TO W-SUPPLIERNAME-FILTER-LEN
                 STRING FUNCTION UPPER-CASE(
                           SUPPLIERNAME-FILTER-TEXT OF P-LPETM203(1:
                              SUPPLIERNAME-FILTER-LEN OF P-LPETM203))
                        N'%'
                        DELIMITED BY SIZE
                   INTO W-SUPPLIERNAME-FILTER-TEXT
                   WITH POINTER W-SUPPLIERNAME-FILTER-LEN
                 SUBTRACT 1 FROM W-SUPPLIERNAME-FILTER-LEN
              END-IF
           END-IF

           MOVE SUPPLIERID-SINCE OF P-LPETM203 TO W-SUPPLIERID-SINCE
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R005-OPEN-CURSOR: Open DB2 cursor for SELECT SUPPLIERS        *
      *===============================================================*
       R005-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  SUPPLIERID,
                         SUPPLIERNAME,
                         SUPPLIERNAMEU,
                         SUPPLIERCODE,
                         SUPPLIERSTATUS,
                         CREATEDBY,
                         CREATEDDATE,
                         UPDATEDBY,
                         UPDATEDDATE
                   FROM  TBPET003
                  WHERE  SUPPLIERNAMEU LIKE :W-SUPPLIERNAME-FILTER
                    AND  SUPPLIERID    >    :W-SUPPLIERID-SINCE
                    FOR  FETCH ONLY
                  FETCH  FIRST 20 ROWS ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM203
              MOVE N'01' TO REASONCODE OF P-LPETM203
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM203
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
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT SUPPLIERS      *
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM203
              MOVE N'02' TO REASONCODE OF P-LPETM203
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM203
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT SUPPLIERS      *
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
               INTO :DCLTBPET003.SUPPLIERID,
                    :DCLTBPET003.SUPPLIERNAME,
                    :DCLTBPET003.SUPPLIERNAMEU,
                    :DCLTBPET003.SUPPLIERCODE,
                    :DCLTBPET003.SUPPLIERSTATUS,
                    :DCLTBPET003.CREATEDBY,
                    :DCLTBPET003.CREATEDDATE,
                    :DCLTBPET003.UPDATEDBY,
                    :DCLTBPET003.UPDATEDDATE
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO SUPPLIER-COUNT OF P-LPETM203

                 MOVE SUPPLIERID OF DCLTBPET003 TO
                      SUPPLIERID OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE SUPPLIERNAME-LEN OF DCLTBPET003 TO
                         SUPPLIERNAME-LEN OF P-LPETM203(
                            SUPPLIER-COUNT OF P-LPETM203)
                 MOVE SUPPLIERNAME-TEXT OF DCLTBPET003(1:
                         SUPPLIERNAME-LEN OF DCLTBPET003) TO
                      SUPPLIERNAME-TEXT OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE SUPPLIERNAMEU-LEN OF DCLTBPET003 TO
                         SUPPLIERNAMEU-LEN OF P-LPETM203(
                            SUPPLIER-COUNT OF P-LPETM203)
                 MOVE SUPPLIERNAMEU-TEXT OF DCLTBPET003(1:
                         SUPPLIERNAMEU-LEN OF DCLTBPET003) TO
                      SUPPLIERNAMEU-TEXT OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE SUPPLIERCODE OF DCLTBPET003 TO
                      SUPPLIERCODE OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE SUPPLIERSTATUS OF DCLTBPET003 TO
                      SUPPLIERSTATUS OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE CREATEDBY OF DCLTBPET003 TO
                      CREATEDBY OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE CREATEDDATE OF DCLTBPET003 TO
                      CREATEDDATE OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE UPDATEDBY OF DCLTBPET003 TO
                      UPDATEDBY OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
                 MOVE UPDATEDDATE OF DCLTBPET003 TO
                      UPDATEDDATE OF P-LPETM203(
                         SUPPLIER-COUNT OF P-LPETM203)
              WHEN 100
                 IF SUPPLIER-COUNT OF P-LPETM203 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM203
                    MOVE N'01' TO REASONCODE OF P-LPETM203
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM203 
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE
              
                 MOVE N'08' TO RETURNCODE OF P-LPETM203
                 MOVE N'03' TO REASONCODE OF P-LPETM203
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM203
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

       END PROGRAM PETM203.