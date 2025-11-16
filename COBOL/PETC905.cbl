       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETC905.
      *===============================================================*
      * This program is a screen program for the PET store CICS       *
      * emergency transaction to manipulate PRODUCTS records.         *
      * ------------------------------------------------------------- *
      * Updates:                                                      *
      *                                                               *
      * Date     Who What                                             *
      * -------- --- ------------------------------------------------ *
      * yy/mm/dd ii  description                                      *
      *===============================================================*

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WORK.
           05  C-CONT-NAME-900       PIC X(16) VALUE 'LPETC900'.
           05  C-CONT-NAME-B04       PIC X(16) VALUE 'BMS-PETB04'.
           05  C-CHNL-NAME           PIC X(16) VALUE 'PT90-CHANNEL'.
           05  C-DONE                PIC X(04) VALUE 'DONE'.
           05  C-ATTR-UNPROT-MDT     PIC X     VALUE X'C1'.
           05  C-ATTR-UNPROT-BRT-MDT PIC X     VALUE X'C9'.

           05  W-RETURNCODE          PIC X(2)  VALUE '00'.
           05  W-PGMNAME             PIC X(8)  VALUE SPACES.
           05  W-APPLID              PIC X(08) VALUE SPACES.
           05  W-PRODID              PIC 9(8).
           05  W-SUPPLID             PIC 9(8).
           05  W-CURRDATE            PIC X(26)
               VALUE '0000-00-00 00:00:00.000000'.
           05  W-COBOLDATE.
               10  W-COBOL-YEAR      PIC X(4).
               10  W-COBOL-MONTH     PIC X(2).
               10  W-COBOL-DAY       PIC X(2).
               10  W-COBOL-HOUR      PIC X(2).
               10  W-COBOL-MINUTE    PIC X(2).
               10  W-COBOL-SECOND    PIC X(2).
               10  W-COBOL-HSEC      PIC X(2).
               10  FILLER            PIC X(5).
           05  W-EIBRESP             PIC 9(8).
           05  W-EIBRESP2            PIC 9(8).
           05  W-CONT-NAME           PIC X(16).
           05  W-CONT-POINTER        POINTER.
           05  W-CONT-LENGTH         PIC S9(9) USAGE COMP-5.
           05  W-IE-POINTER          POINTER.
           05  W-IE-IDX1             PIC S9(08) COMP-5.
           05  W-IE-IDX2             PIC S9(08) COMP-5.
           05  W-IE-IDX3             PIC S9(08) COMP-5.
           05  W-IE-ORG-LEN          PIC S9(08) COMP-5.

           05  SW-INPUT-PROCESSING   PIC X     VALUE 'N'.
               88  SW-DO-INPUT-PROCESSING      VALUE 'Y'.
               88  SW-SKIP-INPUT-PROCESSING    VALUE 'N'.
           05  SW-OUTPUT-PROCESSING  PIC X     VALUE 'N'.
               88  SW-DO-OUTPUT-PROCESSING     VALUE 'Y'.
               88  SW-SKIP-OUTPUT-PROCESSING   VALUE 'N'.
           05  SW-INPUT-OK-VAL       PIC X     VALUE 'N'.
               88  SW-INPUT-OK                 VALUE 'Y'.
               88  SW-INPUT-ERROR              VALUE 'N'.
           05  SW-CONT-FOUND-VAL     PIC X     VALUE 'N'.
               88  SW-CONT-FOUND               VALUE 'Y'.
               88  SW-CONT-MISSING             VALUE 'N'.

           05  MSGSTR.
               10  Vstring-length    PIC S9(4) BINARY.
               10  Vstring-text.
                   15  Vstring-char  PIC X
                               OCCURS 0 TO 256 TIMES
                               DEPENDING ON Vstring-length
                                  of MSGSTR.
           05  MSGDEST               PIC S9(9) BINARY.
           05  FC.
               10  Condition-Token-Value.
               COPY  CEEIGZCT.
                   15  Case-1-Condition-ID.
                       20  Severity    PIC S9(4) BINARY.
                       20  Msg-No      PIC S9(4) BINARY.
                   15  Case-2-Condition-ID
                             REDEFINES Case-1-Condition-ID.
                       20  Class-Code  PIC S9(4) BINARY.
                       20  Cause-Code  PIC S9(4) BINARY.
                   15  Case-Sev-Ctl    PIC X.
                   15  Facility-ID     PIC XXX.
               10  I-S-Info            PIC S9(9) BINARY.

       01  W-LPETC900.
           COPY LPETC900.
       
       01  W-LPETA001.
           COPY LPETA001.
       
       01  W-LPETA004.
           COPY LPETA004.

       COPY DFHAID.

       COPY PETB04.
       COPY PETB04 REPLACING ==PETB04I== BY ==W-PETB04I==
                             ==PETB04O== BY ==W-PETB04O==.

       LINKAGE SECTION.
       01  P-CHAR                    PIC X.

       01  P-INPUT-EDIT.
           05  P-FIELD-L             PIC S9(4) COMP.
           05  P-FIELD-F             PIC X.
           05  P-FIELD-I             PIC X.

       PROCEDURE DIVISION.
       MAIN SECTION.
           PERFORM R001-INIT

           IF  W-RETURNCODE = '00'
           AND SW-DO-INPUT-PROCESSING
              PERFORM R110-INPUT-PROC
           END-IF

           IF  W-RETURNCODE = '00'
           AND SW-DO-OUTPUT-PROCESSING
              PERFORM R120-OUTPUT-PROC
           END-IF

           PERFORM R009-FINISH
           .
       MAIN-END.
           GOBACK.

      *===============================================================*
      * R001-INIT: Program initialisations                            *
      *===============================================================*
       R001-INIT SECTION.
           MOVE LOW-VALUES TO PETB04I
           MOVE LOW-VALUES TO W-PETB04I

           MOVE C-CONT-NAME-900 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-LPETC900
           END-IF

           IF CURRENT-SCREEN OF W-LPETC900 = '04'
              SET SW-DO-INPUT-PROCESSING TO TRUE
           ELSE
              SET SW-SKIP-INPUT-PROCESSING TO TRUE
              MOVE '04' TO CURRENT-SCREEN OF W-LPETC900
           END-IF
           SET SW-DO-OUTPUT-PROCESSING TO TRUE

           MOVE C-CONT-NAME-B04 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-PETB04I

              IF SW-SKIP-INPUT-PROCESSING
                 MOVE '_' TO ACTIONI OF W-PETB04I
                 MOVE SPACES TO ERRMSGO OF W-PETB04O
              END-IF
           END-IF

           EXEC CICS
              ASSIGN APPLID(W-APPLID)
                     NOHANDLE
           END-EXEC
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R009-FINISH: Program finalisations                            *
      *===============================================================*
       R009-FINISH SECTION.
           MOVE C-CONT-NAME-900 TO W-CONT-NAME
           MOVE LENGTH OF W-LPETC900 TO W-CONT-LENGTH
           SET W-CONT-POINTER TO ADDRESS OF W-LPETC900

           PERFORM R920-PUT-CONTAINER

           EXEC CICS
              RETURN
           END-EXEC
           .
       R009-FINISH-END.
           EXIT.

       R110-INPUT-PROC SECTION.
           EXEC CICS
              RECEIVE MAP('PETB04') MAPSET('PETB04')
                      INTO(PETB04I) NOHANDLE
           END-EXEC

           MOVE SPACES TO ERRMSGO OF W-PETB04O.

           IF EIBRESP = DFHRESP(NORMAL)
           OR EIBRESP = DFHRESP(MAPFAIL)
              EVALUATE EIBAID
              WHEN DFHENTER
                 PERFORM R210-CHECK-INPUT

                 IF SW-INPUT-OK
                    PERFORM R320-PERFORM-ACTION
                 END-IF

              WHEN DFHPF3
                 MOVE '01' TO W-RETURNCODE
                 MOVE '00' TO NEXT-SCREEN OF W-LPETC900
              END-EVALUATE
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'RECEIVE MAP ERROR PETB04 ' W-EIBRESP ' '
                     W-EIBRESP2
                     DELIMITED BY SIZE
                INTO Vstring-text
                WITH POINTER Vstring-length
              SUBTRACT 1 FROM Vstring-length
              CALL 'CEEMOUT' USING MSGSTR, MSGDEST, FC
           END-IF
           .
       R110-INPUT-PROC-END.
           EXIT.

       R120-OUTPUT-PROC SECTION.
           MOVE FUNCTION CURRENT-DATE TO W-COBOLDATE
           STRING W-COBOL-YEAR '-' W-COBOL-MONTH '-' W-COBOL-DAY ' '
                  W-COBOL-HOUR ':' W-COBOL-MINUTE ':' W-COBOL-SECOND
                  '.' W-COBOL-HSEC '0000'
                  DELIMITED BY SIZE
             INTO W-CURRDATE

           MOVE W-APPLID         TO APPLIDO OF W-PETB04O
           STRING W-COBOL-DAY '-' W-COBOL-MONTH '-' W-COBOL-YEAR
                  DELIMITED BY SIZE
             INTO TODAYO OF W-PETB04O
           MOVE EIBTRNID         TO TRNIDO  OF W-PETB04O
           MOVE EIBTRMID         TO TRMIDO  OF W-PETB04O
           MOVE W-CURRDATE(12:8) TO NOWO    OF W-PETB04O

           IF SW-SKIP-INPUT-PROCESSING
              MOVE C-ATTR-UNPROT-MDT TO PRODCDF OF W-PETB04I
              MOVE -1 TO PRODCDL OF W-PETB04I
           END-IF

           MOVE W-PETB04I TO PETB04I

           EXEC CICS
              SEND MAP('PETB04') MAPSET('PETB04')
                   FROM(PETB04O) FREEKB ERASE CURSOR NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE C-CONT-NAME-B04 TO W-CONT-NAME
              MOVE LENGTH OF W-PETB04I TO W-CONT-LENGTH
              SET W-CONT-POINTER TO ADDRESS OF W-PETB04I

              PERFORM R920-PUT-CONTAINER
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'SEND MAP ERROR PETB04 ' W-EIBRESP ' '
                     W-EIBRESP2
                     DELIMITED BY SIZE
                INTO Vstring-text
                WITH POINTER Vstring-length
              SUBTRACT 1 FROM Vstring-length
              CALL 'CEEMOUT' USING MSGSTR, MSGDEST, FC
           END-IF
           .
       R120-OUTPUT-PROC-END.
           EXIT.

       R210-CHECK-INPUT SECTION.
           PERFORM R310-PROCESS-BMS

           SET SW-INPUT-OK TO TRUE

           IF   ACTIONL OF W-PETB04I = 0
           OR  (ACTIONI OF W-PETB04I NOT = 'C'
           AND  ACTIONI OF W-PETB04I NOT = 'R'
           AND  ACTIONI OF W-PETB04I NOT = 'U'
           AND  ACTIONI OF W-PETB04I NOT = 'D')
              MOVE C-ATTR-UNPROT-BRT-MDT TO ACTIONF OF W-PETB04I
              MOVE -1 TO ACTIONL OF W-PETB04I
              MOVE 'INVALID ACTION' TO ERRMSGO OF W-PETB04O
              SET SW-INPUT-ERROR TO TRUE
           END-IF

           IF PRODCDL OF W-PETB04I = 0
           OR PRODCDI OF W-PETB04I = SPACES
              MOVE C-ATTR-UNPROT-BRT-MDT TO PRODCDF OF W-PETB04I
              IF SW-INPUT-OK
                 MOVE -1 TO PRODCDL OF W-PETB04I
                 MOVE 'INVALID PRODUCTCODE' TO ERRMSGO OF W-PETB04O
                 SET SW-INPUT-ERROR TO TRUE
              END-IF
           END-IF

           IF ACTIONI OF W-PETB04I = 'C'
           OR ACTIONI OF W-PETB04I = 'U'
              IF PRODSTL OF W-PETB04I = 0
              OR PRODSTI OF W-PETB04I = SPACES
                 MOVE C-ATTR-UNPROT-BRT-MDT TO PRODSTF OF W-PETB04I
                 IF SW-INPUT-OK
                    MOVE -1 TO PRODSTL OF W-PETB04I
                    MOVE 'INVALID PRODUCTSTATUS' TO
                         ERRMSGO OF W-PETB04O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF GROUPCDL OF W-PETB04I = 0
              OR GROUPCDI OF W-PETB04I = SPACES
                 MOVE C-ATTR-UNPROT-BRT-MDT TO GROUPCDF OF W-PETB04I
                 IF SW-INPUT-OK
                    MOVE -1 TO GROUPCDL OF W-PETB04I
                    MOVE 'INVALID GROUPCODE' TO ERRMSGO OF W-PETB04O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF SUPPLIDL OF W-PETB04I = 0
              OR SUPPLIDI OF W-PETB04I = ZEROS
                 MOVE C-ATTR-UNPROT-BRT-MDT TO SUPPLIDF OF W-PETB04I
                 IF SW-INPUT-OK
                    MOVE -1 TO SUPPLIDL OF W-PETB04I
                    MOVE 'INVALID SUPPLIERID' TO ERRMSGO OF W-PETB04O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF SW-INPUT-OK
                 INITIALIZE W-LPETA001
                 MOVE N'R' TO OPCODE OF W-LPETA001
                 MOVE N'PRODSTAT' TO TABLEID OF W-LPETA001
                 MOVE FUNCTION NATIONAL-OF(PRODSTI OF W-PETB04I) TO
                      TABKEY OF W-LPETA001
              
                 MOVE 'PETA001' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA001

                 IF RETURNCODE OF W-LPETA001 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO PRODSTF OF W-PETB04I
                    MOVE -1 TO PRODSTL OF W-PETB04I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETA001)
                         TO ERRMSGO OF W-PETB04O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF SW-INPUT-OK
                 INITIALIZE W-LPETA001
                 MOVE N'R' TO OPCODE OF W-LPETA001
                 MOVE N'PRODGRCD' TO TABLEID OF W-LPETA001
                 MOVE FUNCTION NATIONAL-OF(GROUPCDI OF W-PETB04I) TO
                      TABKEY OF W-LPETA001
                 
                 MOVE 'PETA001' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA001

                 IF RETURNCODE OF W-LPETA001 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO GROUPCDF OF W-PETB04I
                    MOVE -1 TO GROUPCDL OF W-PETB04I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETA001)
                         TO ERRMSGO OF W-PETB04O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF
           END-IF
           .
       R210-CHECK-INPUT-END.
           EXIT.

       R310-PROCESS-BMS SECTION.
           IF PRODCDL OF PETB04I NOT = 0
           OR PRODCDF OF PETB04I > X'80'
              MOVE PRODCDL OF PETB04I TO PRODCDL OF W-PETB04I
              MOVE PRODCDF OF PETB04I TO PRODCDF OF W-PETB04I
              MOVE FUNCTION UPPER-CASE(PRODCDI OF PETB04I) TO
                   PRODCDI OF W-PETB04I
           END-IF

           IF PRODSTL OF PETB04I NOT = 0
           OR PRODSTF OF PETB04I > X'80'
              MOVE PRODSTL OF PETB04I TO PRODSTL OF W-PETB04I
              MOVE PRODSTF OF PETB04I TO PRODSTF OF W-PETB04I
              MOVE FUNCTION UPPER-CASE(PRODSTI OF PETB04I) TO
                   PRODSTI OF W-PETB04I
           END-IF

           IF PRODNML OF PETB04I NOT = 0
           OR PRODNMF OF PETB04I > X'80'
              MOVE PRODNML OF PETB04I TO PRODNML OF W-PETB04I
              MOVE PRODNMF OF PETB04I TO PRODNMF OF W-PETB04I
              MOVE PRODNMI OF PETB04I TO PRODNMI OF W-PETB04I
           END-IF

           IF GROUPCDL OF PETB04I NOT = 0
           OR GROUPCDF OF PETB04I > X'80'
              MOVE GROUPCDL OF PETB04I TO GROUPCDL OF W-PETB04I
              MOVE GROUPCDF OF PETB04I TO GROUPCDF OF W-PETB04I
              MOVE GROUPCDI OF PETB04I TO GROUPCDI OF W-PETB04I
           END-IF

           IF SUPPLIDL OF PETB04I NOT = 0
           OR SUPPLIDF OF PETB04I > X'80'
              MOVE SUPPLIDL OF PETB04I TO SUPPLIDL OF W-PETB04I
              MOVE SUPPLIDF OF PETB04I TO SUPPLIDF OF W-PETB04I
              MOVE SUPPLIDI OF PETB04I TO SUPPLIDI OF W-PETB04I
           END-IF

           IF ACTIONL OF PETB04I NOT = 0
           OR ACTIONF OF PETB04I > X'80'
              MOVE ACTIONL OF PETB04I TO ACTIONL OF W-PETB04I
              MOVE ACTIONF OF PETB04I TO ACTIONF OF W-PETB04I
              MOVE FUNCTION UPPER-CASE(ACTIONI OF PETB04I) TO
                   ACTIONI OF W-PETB04I
           END-IF

           SET W-IE-POINTER TO ADDRESS OF PRODCDL OF W-PETB04I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF PRODSTL OF W-PETB04I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF PRODNML OF W-PETB04I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF GROUPCDL OF W-PETB04I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF SUPPLIDL OF W-PETB04I
           PERFORM R800-INPUT-EDIT
           IF SUPPLIDL OF W-PETB04I > 0
              MOVE LENGTH OF SUPPLIDI OF W-PETB04I TO
                   SUPPLIDL OF W-PETB04I
              EXEC CICS
                 BIF DEEDIT FIELD(SUPPLIDI OF W-PETB04I)
                            LENGTH(LENGTH OF SUPPLIDI OF W-PETB04I)
              END-EXEC
           END-IF
           .
       R310-PROCESS-BMS-END.
           EXIT.

       R320-PERFORM-ACTION SECTION.
           INITIALIZE W-LPETA004

           MOVE FUNCTION NATIONAL-OF(ACTIONI OF W-PETB04I) TO
                OPCODE OF W-LPETA004
           MOVE PRODIDI OF W-PETB04I TO PRODUCTID OF W-LPETA004
           MOVE FUNCTION NATIONAL-OF(PRODCDI OF W-PETB04I) TO
                PRODUCTCODE OF W-LPETA004
           
           IF OPCODE OF W-LPETA001 NOT = N'D'
              MOVE FUNCTION NATIONAL-OF(PRODSTI OF W-PETB04I) TO
                   PRODUCTSTATUS OF W-LPETA004
           END-IF

           IF OPCODE OF W-LPETA004 = N'C'
           OR OPCODE OF W-LPETA004 = N'U'
              MOVE PRODNML OF W-PETB04I TO
                   PRODUCTNAME-LEN OF W-LPETA004
              MOVE FUNCTION NATIONAL-OF(PRODNMI OF W-PETB04I) TO
                   PRODUCTNAME-TEXT OF W-LPETA004
              MOVE FUNCTION NATIONAL-OF(GROUPCDI OF W-PETB04I) TO
                   GROUPCODE OF W-LPETA004
              MOVE SUPPLIDI OF W-PETB04I TO W-SUPPLID
              MOVE W-SUPPLID TO SUPPLIERID OF W-LPETA004
           END-IF

           MOVE 'PETA004' TO W-PGMNAME

           CALL W-PGMNAME USING W-LPETA004

           MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETA004) TO
                ERRMSGO OF W-PETB04O
           
           IF  RETURNCODE OF W-LPETA004 = N'00'
              IF OPCODE OF W-LPETA004 NOT = N'D'
                 MOVE PRODUCTID OF W-LPETA004 TO W-PRODID
                 MOVE W-PRODID TO PRODIDI OF W-PETB04I
                 MOVE 8        TO PRODIDL OF W-PETB04I
                 MOVE FUNCTION DISPLAY-OF(PRODUCTCODE OF W-LPETA004) TO
                      PRODCDI OF W-PETB04I
                 MOVE 8 TO PRODCDL OF W-PETB04I
                 MOVE FUNCTION DISPLAY-OF(PRODUCTSTATUS OF W-LPETA004)
                      TO PRODSTI OF W-PETB04I
                 MOVE 8 TO PRODSTL OF W-PETB04I
                 MOVE FUNCTION DISPLAY-OF(
                         PRODUCTNAME-TEXT OF W-LPETA004(1:
                            PRODUCTNAME-LEN OF W-LPETA004)) TO
                      PRODNMI OF W-PETB04I
                 IF PRODUCTNAME-LEN OF W-LPETA004 >= 58
                    MOVE 58 TO PRODNML OF W-PETB04I
                 ELSE
                    MOVE PRODUCTNAME-LEN OF W-LPETA004 TO
                         PRODNML OF W-PETB04I
                 END-IF
                 MOVE FUNCTION DISPLAY-OF(GROUPCODE OF W-LPETA004) TO
                      GROUPCDI OF W-PETB04I
                 MOVE 8 TO GROUPCDL OF W-PETB04I
                 MOVE SUPPLIERID OF W-LPETA004 TO W-SUPPLID
                 MOVE W-SUPPLID TO SUPPLIDI OF W-PETB04I
                 MOVE 8         TO SUPPLIDL OF W-PETB04I
                 MOVE FUNCTION DISPLAY-OF(CREATEDBY OF W-LPETA004) TO
                      CREBYI OF W-PETB04I
                 MOVE 8 TO CREBYL OF W-PETB04I
                 MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETA004) TO
                      CREDATEI OF W-PETB04I
                 MOVE 19 TO CREDATEL OF W-PETB04I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDBY OF W-LPETA004) TO
                      UPDBYI OF W-PETB04I
                 MOVE 8 TO UPDBYL OF W-PETB04I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETA004) TO
                      UPDDATEI OF W-PETB04I
                 MOVE 19 TO UPDDATEL OF W-PETB04I
              ELSE
                 MOVE LOW-VALUES TO PRODIDI  OF W-PETB04I
                 MOVE 0          TO PRODIDL  OF W-PETB04I
                 MOVE LOW-VALUES TO PRODCDI  OF W-PETB04I
                 MOVE 0          TO PRODCDL  OF W-PETB04I
                 MOVE LOW-VALUES TO PRODSTI  OF W-PETB04I 
                 MOVE 0          TO PRODSTL  OF W-PETB04I
                 MOVE LOW-VALUES TO PRODNMI  OF W-PETB04I
                 MOVE 0          TO PRODNML  OF W-PETB04I
                 MOVE LOW-VALUES TO GROUPCDI OF W-PETB04I
                 MOVE 0          TO GROUPCDL OF W-PETB04I
                 MOVE LOW-VALUES TO SUPPLIDI OF W-PETB04I
                 MOVE 0          TO SUPPLIDL OF W-PETB04I
                 MOVE LOW-VALUES TO CREBYI   OF W-PETB04I
                 MOVE 0          TO CREBYL   OF W-PETB04I
                 MOVE LOW-VALUES TO CREDATEI OF W-PETB04I
                 MOVE 0          TO CREDATEL OF W-PETB04I
                 MOVE LOW-VALUES TO UPDBYI   OF W-PETB04I
                 MOVE 0          TO UPDBYL   OF W-PETB04I
                 MOVE LOW-VALUES TO UPDDATEI OF W-PETB04I
                 MOVE 0          TO UPDDATEL OF W-PETB04I
              END-IF

              MOVE LOW-VALUES TO ACTIONI OF W-PETB04I
              MOVE 0          TO ACTIONL OF W-PETB04I
           END-IF
           .
       R320-PERFORM-ACTION-END.
           EXIT.

       R800-INPUT-EDIT SECTION.
           SET ADDRESS OF P-INPUT-EDIT TO W-IE-POINTER

           IF P-FIELD-L > 0
              IF P-FIELD-I(1:P-FIELD-L) = SPACES
              OR P-FIELD-I(1:P-FIELD-L) = LOW-VALUES
                 MOVE LOW-VALUES TO P-FIELD-I(1:P-FIELD-L)
                 MOVE 0 TO P-FIELD-L
              ELSE
                 PERFORM VARYING W-IE-IDX1 FROM 1 BY 1
                   UNTIL  W-IE-IDX1 > P-FIELD-L
                      OR (P-FIELD-I(W-IE-IDX1:1) NOT = SPACE
                     AND  P-FIELD-I(W-IE-IDX1:1) NOT = LOW-VALUE
                     AND  P-FIELD-I(W-IE-IDX1:1) NOT = '_')
                 END-PERFORM

                 PERFORM VARYING W-IE-IDX2 FROM P-FIELD-L BY -1
                   UNTIL  W-IE-IDX2 <= 0
                      OR (P-FIELD-I(W-IE-IDX2:1) NOT = SPACE
                     AND  P-FIELD-I(W-IE-IDX2:1) NOT = LOW-VALUE
                     AND  P-FIELD-I(W-IE-IDX2:1) NOT = '_')
                 END-PERFORM

                 IF W-IE-IDX1 > W-IE-IDX2
                    MOVE LOW-VALUES TO P-FIELD-I(1:P-FIELD-L)
                    MOVE 0 TO P-FIELD-L
                 ELSE
                    MOVE P-FIELD-L TO W-IE-ORG-LEN

                    COMPUTE P-FIELD-L = W-IE-IDX2 - W-IE-IDX1 + 1

                    PERFORM VARYING W-IE-IDX3 FROM 1 BY 1
                      UNTIL W-IE-IDX3 > P-FIELD-L
                       MOVE P-FIELD-I(W-IE-IDX1:1) TO
                            P-FIELD-I(W-IE-IDX3:1)
                       ADD 1 TO W-IE-IDX1
                    END-PERFORM

                    PERFORM VARYING W-IE-IDX3 FROM W-IE-IDX3 BY 1
                      UNTIL W-IE-IDX3 > W-IE-ORG-LEN
                       MOVE SPACE TO P-FIELD-I(W-IE-IDX3:1)
                    END-PERFORM
                 END-IF
              END-IF
           END-IF
           .
       X800-INPUT-EDIT-END.
           EXIT.

       R910-GET-CONTAINER SECTION.
           EXEC CICS
              GET CONTAINER(W-CONT-NAME)
                  CHANNEL(C-CHNL-NAME)
                  SET(W-CONT-POINTER)
                  FLENGTH(W-CONT-LENGTH)
                  NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              SET SW-CONT-FOUND TO TRUE
           ELSE
              SET SW-CONT-MISSING TO TRUE

              IF  EIBRESP NOT = DFHRESP(CHANNELERR)
              AND EIBRESP NOT = DFHRESP(CONTAINERERR)
                 MOVE '08' TO W-RETURNCODE

                 MOVE EIBRESP  TO W-EIBRESP
                 MOVE EIBRESP2 TO W-EIBRESP2
                 MOVE 1 TO Vstring-length
                 STRING 'GET CONTAINER ERROR ' W-EIBRESP ' ' W-EIBRESP2
                        DELIMITED BY SIZE
                   INTO Vstring-text
                   WITH POINTER Vstring-length
                 SUBTRACT 1 FROM Vstring-length
                 CALL 'CEEMOUT' USING MSGSTR, MSGDEST, FC
              END-IF
           END-IF
           .
       R910-GET-CONTAINER-END.
           EXIT.

       R920-PUT-CONTAINER SECTION.
           SET ADDRESS OF P-CHAR TO W-CONT-POINTER

           EXEC CICS
              PUT CONTAINER(W-CONT-NAME)
                  CHANNEL(C-CHNL-NAME)
                  FROM(P-CHAR)
                  FLENGTH(W-CONT-LENGTH)
                  NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              CONTINUE
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'PUT CONTAINER ERROR ' W-EIBRESP ' ' W-EIBRESP2
                     DELIMITED BY SIZE
                INTO Vstring-text
                WITH POINTER Vstring-length
              SUBTRACT 1 FROM Vstring-length
              CALL 'CEEMOUT' USING MSGSTR, MSGDEST, FC
           END-IF
           .
       R930-PUT-CONTAINER-END.
           EXIT.

       END PROGRAM PETC905.