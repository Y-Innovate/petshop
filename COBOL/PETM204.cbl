       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETM204
      *===============================================================*
      * This program is a list module for the PET store database's    *
      * TBPET004 PRODUCTS table.                                      *
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
          05 W-PGMNAME                     PIC X(8).
          05 W-SQLCODE                     PIC -99999.
          05 W-PRODUCTNAME-FILTER.
             49 W-PRODUCTNAME-FILTER-LEN  PIC S9(4) COMP-5.
             49 W-PRODUCTNAME-FILTER-TEXT PIC N(256).
          05 W-PRODUCTID-SINCE            PIC S9(9) COMP-5.

       01 ERROR-MESSAGE.
          05 ERROR-LEN    PIC S9(4) COMP
                                     VALUE +720.
          05 ERROR-TEXT   PIC X(72) OCCURS 10 TIMES
                INDEXED BY ERROR-INDEX.
       77 ERROR-TEXT-LEN  PIC S9(9) COMP
                                     VALUE +72.

       LINKAGE SECTION.
       01 P-LPETM204.
           COPY LPETM204.

       PROCEDURE DIVISION USING P-LPETM204.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R005-OPEN-CURSOR

           IF RETURNCODE OF P-LPETM204 = N'00'
              PERFORM R210-FETCH-CURSOR

              PERFORM WITH TEST BEFORE 
                UNTIL RETURNCODE OF P-LPETM204 NOT = N'00'
                   OR SQLCODE NOT = 0
                   OR PRODUCT-COUNT OF P-LPETM204 >= 20
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
           MOVE N'00' TO RETURNCODE OF P-LPETM204
           MOVE N'00' TO REASONCODE OF P-LPETM204
           MOVE SPACES TO INFOMESSAGE OF P-LPETM204

           MOVE 0 TO PRODUCT-COUNT OF P-LPETM204

           IF PRODUCTNAME-FILTER-LEN OF P-LPETM204 = 0
              MOVE 1 TO W-PRODUCTNAME-FILTER-LEN
              MOVE N'%' TO W-PRODUCTNAME-FILTER-TEXT(1:1)
           ELSE
              IF PRODUCTNAME-FILTER-TEXT OF P-LPETM204(1:
                    PRODUCTNAME-FILTER-LEN OF P-LPETM204) NOT = SPACES
                 MOVE 1 TO W-PRODUCTNAME-FILTER-LEN
                 STRING FUNCTION UPPER-CASE(
                           PRODUCTNAME-FILTER-TEXT OF P-LPETM204(1:
                              PRODUCTNAME-FILTER-LEN OF P-LPETM204))
                        N'%'
                        DELIMITED BY SIZE
                   INTO W-PRODUCTNAME-FILTER-TEXT
                   WITH POINTER W-PRODUCTNAME-FILTER-LEN
                 SUBTRACT 1 FROM W-PRODUCTNAME-FILTER-LEN
              END-IF
           END-IF

           MOVE PRODUCTID-SINCE OF P-LPETM204 TO W-PRODUCTID-SINCE
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R005-OPEN-CURSOR: Open DB2 cursor for SELECT PRODUCTS         *
      *===============================================================*
       R005-OPEN-CURSOR SECTION.
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT  PRODUCTID,
                         PRODUCTNAME,
                         PRODUCTNAMEU,
                         PRODUCTCODE,
                         PRODUCTSTATUS,
                         GROUPCODE,
                         SUPPLIERID,
                         CREATEDBY,
                         CREATEDDATE,
                         UPDATEDBY,
                         UPDATEDDATE
                   FROM  TBPET004
                  WHERE  PRODUCTNAMEU LIKE :W-PRODUCTNAME-FILTER
                    AND  PRODUCTID    >    :W-PRODUCTID-SINCE
                    FOR  FETCH ONLY
                  FETCH  FIRST 20 ROWS ONLY
           END-EXEC

           EXEC SQL
              OPEN C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM204
              MOVE N'01' TO REASONCODE OF P-LPETM204
              STRING N'OPEN CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM204
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
      * R190-CLOSE-CURSOR: Close DB2 cursor for SELECT PRODUCTS       *
      *===============================================================*
       R190-CLOSE-CURSOR SECTION.
           EXEC SQL
              CLOSE C1
           END-EXEC

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO W-SQLCODE
              
              MOVE N'08' TO RETURNCODE OF P-LPETM204
              MOVE N'02' TO REASONCODE OF P-LPETM204
              STRING N'CLOSE CURSOR gave SQLCODE='
                     FUNCTION NATIONAL-OF(W-SQLCODE)
                 DELIMITED BY SIZE
                 INTO INFOMESSAGE OF P-LPETM204
              PERFORM R900-DSNTIAR
           END-IF
           .
       R190-CLOSE-CURSOR-END.
           EXIT.

      *===============================================================*
      * R210-FETCH-CURSOR: Fetch DB2 cursor for SELECT PRODUCTS       *
      *===============================================================*
       R210-FETCH-CURSOR SECTION.
           EXEC SQL
              FETCH C1
               INTO :DCLTBPET004.PRODUCTID,
                    :DCLTBPET004.PRODUCTNAME,
                    :DCLTBPET004.PRODUCTNAMEU,
                    :DCLTBPET004.PRODUCTCODE,
                    :DCLTBPET004.PRODUCTSTATUS,
                    :DCLTBPET004.GROUPCODE,
                    :DCLTBPET004.SUPPLIERID,
                    :DCLTBPET004.CREATEDBY,
                    :DCLTBPET004.CREATEDDATE,
                    :DCLTBPET004.UPDATEDBY,
                    :DCLTBPET004.UPDATEDDATE
           END-EXEC

           EVALUATE SQLCODE
              WHEN 0
                 ADD 1 TO PRODUCT-COUNT OF P-LPETM204

                 MOVE PRODUCTID OF DCLTBPET004 TO
                      PRODUCTID OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE PRODUCTNAME-LEN OF DCLTBPET004 TO
                         PRODUCTNAME-LEN OF P-LPETM204(
                            PRODUCT-COUNT OF P-LPETM204)
                 MOVE PRODUCTNAME-TEXT OF DCLTBPET004(1:
                         PRODUCTNAME-LEN OF DCLTBPET004) TO
                      PRODUCTNAME-TEXT OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE PRODUCTNAMEU-LEN OF DCLTBPET004 TO
                         PRODUCTNAMEU-LEN OF P-LPETM204(
                            PRODUCT-COUNT OF P-LPETM204)
                 MOVE PRODUCTNAMEU-TEXT OF DCLTBPET004(1:
                         PRODUCTNAMEU-LEN OF DCLTBPET004) TO
                      PRODUCTNAMEU-TEXT OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE PRODUCTCODE OF DCLTBPET004 TO
                      PRODUCTCODE OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE PRODUCTSTATUS OF DCLTBPET004 TO
                      PRODUCTSTATUS OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE GROUPCODE OF DCLTBPET004 TO
                      GROUPCODE OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE SUPPLIERID OF DCLTBPET004 TO
                      SUPPLIERID OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE CREATEDBY OF DCLTBPET004 TO
                      CREATEDBY OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE CREATEDDATE OF DCLTBPET004 TO
                      CREATEDDATE OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE UPDATEDBY OF DCLTBPET004 TO
                      UPDATEDBY OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
                 MOVE UPDATEDDATE OF DCLTBPET004 TO
                      UPDATEDDATE OF P-LPETM204(
                         PRODUCT-COUNT OF P-LPETM204)
              WHEN 100
                 IF PRODUCT-COUNT OF P-LPETM204 = 0
                    MOVE N'04' TO RETURNCODE OF P-LPETM204
                    MOVE N'01' TO REASONCODE OF P-LPETM204
                    MOVE N'NOT FOUND' TO INFOMESSAGE OF P-LPETM204 
                 END-IF
              WHEN OTHER
                 MOVE SQLCODE TO W-SQLCODE
              
                 MOVE N'08' TO RETURNCODE OF P-LPETM204
                 MOVE N'03' TO REASONCODE OF P-LPETM204
                 STRING N'FETCH CURSOR gave SQLCODE='
                        FUNCTION NATIONAL-OF(W-SQLCODE)
                           DELIMITED BY SIZE
                   INTO INFOMESSAGE OF P-LPETM204
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

       END PROGRAM PETM204.