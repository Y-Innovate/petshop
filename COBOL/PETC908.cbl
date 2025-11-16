       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETC908.
      *===============================================================*
      * This program is a screen program for the PET store CICS       *
      * emergency transaction to manipulate PRICESANDDISCOUNTS records*
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
           05  C-CONT-NAME-B07       PIC X(16) VALUE 'BMS-PETB07'.
           05  C-CHNL-NAME           PIC X(16) VALUE 'PT90-CHANNEL'.
           05  C-DONE                PIC X(04) VALUE 'DONE'.
           05  C-ATTR-UNPROT-MDT     PIC X     VALUE X'C1'.
           05  C-ATTR-UNPROT-BRT-MDT PIC X     VALUE X'C9'.

           05  W-RETURNCODE          PIC X(2)  VALUE '00'.
           05  W-PGMNAME             PIC X(8)  VALUE SPACES.
           05  W-APPLID              PIC X(08) VALUE SPACES.
           05  W-PADID               PIC 9(8).
           05  W-STOREID             PIC 9(8).
           05  W-PRODUCTID           PIC 9(8).
           05  W-ANIMALID            PIC 9(8).
           05  W-PRICE               PIC 9(7)V9(2).
           05  W-PRICE-R             REDEFINES W-PRICE PIC X(9).
           05  W-DISCOUNT            PIC 9(7)V9(2).
           05  W-DISCOUNT-R          REDEFINES W-DISCOUNT PIC X(9).
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
       
       01  W-LPETA002.
           COPY LPETA002.
       
       01  W-LPETA004.
           COPY LPETA004.
       
       01  W-LPETA006.
           COPY LPETA006.
       
       01  W-LPETA007.
           COPY LPETA007.

       COPY DFHAID.

       COPY PETB07.
       COPY PETB07 REPLACING ==PETB07I== BY ==W-PETB07I==
                             ==PETB07O== BY ==W-PETB07O==.

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
           MOVE LOW-VALUES TO PETB07I
           MOVE LOW-VALUES TO W-PETB07I

           MOVE C-CONT-NAME-900 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-LPETC900
           END-IF

           IF CURRENT-SCREEN OF W-LPETC900 = '07'
              SET SW-DO-INPUT-PROCESSING TO TRUE
           ELSE
              SET SW-SKIP-INPUT-PROCESSING TO TRUE
              MOVE '07' TO CURRENT-SCREEN OF W-LPETC900
           END-IF
           SET SW-DO-OUTPUT-PROCESSING TO TRUE

           MOVE C-CONT-NAME-B07 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-PETB07I

              IF SW-SKIP-INPUT-PROCESSING
                 MOVE '_' TO ACTIONI OF W-PETB07I
                 MOVE SPACES TO ERRMSGO OF W-PETB07O
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
              RECEIVE MAP('PETB07') MAPSET('PETB07')
                      INTO(PETB07I) NOHANDLE
           END-EXEC

           MOVE SPACES TO ERRMSGO OF W-PETB07O.

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
              STRING 'RECEIVE MAP ERROR PETB07 ' W-EIBRESP ' '
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

           MOVE W-APPLID         TO APPLIDO OF W-PETB07O
           STRING W-COBOL-DAY '-' W-COBOL-MONTH '-' W-COBOL-YEAR
                  DELIMITED BY SIZE
             INTO TODAYO OF W-PETB07O
           MOVE EIBTRNID         TO TRNIDO  OF W-PETB07O
           MOVE EIBTRMID         TO TRMIDO  OF W-PETB07O
           MOVE W-CURRDATE(12:8) TO NOWO    OF W-PETB07O

           IF SW-SKIP-INPUT-PROCESSING
              MOVE C-ATTR-UNPROT-MDT TO STOREIDF OF W-PETB07I
              MOVE -1 TO STOREIDL OF W-PETB07I
           END-IF

           MOVE W-PETB07I TO PETB07I

           EXEC CICS
              SEND MAP('PETB07') MAPSET('PETB07')
                   FROM(PETB07O) FREEKB ERASE CURSOR NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE C-CONT-NAME-B07 TO W-CONT-NAME
              MOVE LENGTH OF W-PETB07I TO W-CONT-LENGTH
              SET W-CONT-POINTER TO ADDRESS OF W-PETB07I

              PERFORM R920-PUT-CONTAINER
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'SEND MAP ERROR PETB07 ' W-EIBRESP ' '
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

           IF   ACTIONL OF W-PETB07I = 0
           OR  (ACTIONI OF W-PETB07I NOT = 'C'
           AND  ACTIONI OF W-PETB07I NOT = 'R'
           AND  ACTIONI OF W-PETB07I NOT = 'U'
           AND  ACTIONI OF W-PETB07I NOT = 'D')
              MOVE C-ATTR-UNPROT-BRT-MDT TO ACTIONF OF W-PETB07I
              MOVE -1 TO ACTIONL OF W-PETB07I
              MOVE 'INVALID ACTION' TO ERRMSGO OF W-PETB07O
              SET SW-INPUT-ERROR TO TRUE
           END-IF

           IF ACTIONI OF W-PETB07I NOT = 'D'
              IF STOREIDL OF W-PETB07I = 0
              OR STOREIDI OF W-PETB07I = ZEROS
                 MOVE C-ATTR-UNPROT-BRT-MDT TO STOREIDF OF W-PETB07I
                 IF SW-INPUT-OK
                    MOVE -1 TO STOREIDL OF W-PETB07I
                    MOVE 'INVALID STOREID' TO ERRMSGO OF W-PETB07O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF  (PRODIDL  OF W-PETB07I = 0
              OR   PRODIDI  OF W-PETB07I = ZEROS)
              AND (ANIMLIDL OF W-PETB07I = 0
              OR   ANIMLIDI OF W-PETB07I = ZEROS)
                 MOVE C-ATTR-UNPROT-BRT-MDT TO PRODIDF OF W-PETB07I
                 IF SW-INPUT-OK
                    MOVE -1 TO PRODIDL OF W-PETB07I
                    MOVE 'INVALID PRODUCTID/ANIMALID' TO
                         ERRMSGO OF W-PETB07O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF
           END-IF

           IF ACTIONI OF W-PETB07I = 'C'
           OR ACTIONI OF W-PETB07I = 'U'
              IF  (PRICEL  OF W-PETB07I = 0
              OR   PRICEI  OF W-PETB07I = ZEROS)
              AND (DISCNTL OF W-PETB07I = 0
              OR   DISCNTI OF W-PETB07I = ZEROS)
                 MOVE C-ATTR-UNPROT-BRT-MDT TO PRICEF OF W-PETB07I
                 IF SW-INPUT-OK
                    MOVE -1 TO PRICEL OF W-PETB07I
                    MOVE 'INVALID PRICE/DISCOUNT' TO
                         ERRMSGO OF W-PETB07O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF SW-INPUT-OK
                 INITIALIZE W-LPETA002
                 MOVE N'R' TO OPCODE OF W-LPETA002
                 MOVE STOREIDI OF W-PETB07I TO W-STOREID
                 MOVE W-STOREID TO STOREID OF W-LPETA002
              
                 MOVE 'PETA002' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA002

                 IF RETURNCODE OF W-LPETA002 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO STOREIDF OF W-PETB07I
                    MOVE -1 TO STOREIDL OF W-PETB07I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETA002)
                         TO ERRMSGO OF W-PETB07O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF  SW-INPUT-OK
              AND PRODIDL OF W-PETB07I NOT = 0
              AND PRODIDI OF W-PETB07I NOT = ZEROES
                 INITIALIZE W-LPETA004
                 MOVE N'R' TO OPCODE OF W-LPETA004
                 MOVE PRODIDI OF W-PETB07I TO W-PRODUCTID
                 MOVE W-PRODUCTID TO PRODUCTID OF W-LPETA004
                 
                 MOVE 'PETA004' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA004

                 IF RETURNCODE OF W-LPETA004 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO PRODIDF OF W-PETB07I
                    MOVE -1 TO PRODIDL OF W-PETB07I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETA004)
                         TO ERRMSGO OF W-PETB07O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF  SW-INPUT-OK
              AND ANIMLIDL OF W-PETB07I NOT = 0
              AND ANIMLIDI OF W-PETB07I NOT = ZEROES
                 INITIALIZE W-LPETA006
                 MOVE N'R' TO OPCODE OF W-LPETA006
                 MOVE ANIMLIDI OF W-PETB07I TO W-ANIMALID
                 MOVE W-ANIMALID TO ANIMALID OF W-LPETA006
                 
                 MOVE 'PETA006' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETA006

                 IF RETURNCODE OF W-LPETA006 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLIDF OF W-PETB07I
                    MOVE -1 TO ANIMLIDL OF W-PETB07I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETA006)
                         TO ERRMSGO OF W-PETB07O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF
           END-IF
           .
       R210-CHECK-INPUT-END.
           EXIT.

       R310-PROCESS-BMS SECTION.
           IF STOREIDL OF PETB07I NOT = 0
           OR STOREIDF OF PETB07I > X'80'
              MOVE STOREIDL OF PETB07I TO STOREIDL OF W-PETB07I
              MOVE STOREIDF OF PETB07I TO STOREIDF OF W-PETB07I
              MOVE STOREIDI OF PETB07I TO STOREIDI OF W-PETB07I
           END-IF

           IF PRODIDL OF PETB07I NOT = 0
           OR PRODIDF OF PETB07I > X'80'
              MOVE PRODIDL OF PETB07I TO PRODIDL OF W-PETB07I
              MOVE PRODIDF OF PETB07I TO PRODIDF OF W-PETB07I
              MOVE PRODIDI OF PETB07I TO PRODIDI OF W-PETB07I
           END-IF

           IF ANIMLIDL OF PETB07I NOT = 0
           OR ANIMLIDF OF PETB07I > X'80'
              MOVE ANIMLIDL OF PETB07I TO ANIMLIDL OF W-PETB07I
              MOVE ANIMLIDF OF PETB07I TO ANIMLIDF OF W-PETB07I
              MOVE ANIMLIDI OF PETB07I TO ANIMLIDI OF W-PETB07I
           END-IF

           IF PRICEL OF PETB07I NOT = 0
           OR PRICEF OF PETB07I > X'80'
              MOVE PRICEL OF PETB07I TO PRICEL OF W-PETB07I
              MOVE PRICEF OF PETB07I TO PRICEF OF W-PETB07I
              MOVE PRICEI OF PETB07I TO PRICEI OF W-PETB07I
           END-IF

           IF DISCNTL OF PETB07I NOT = 0
           OR DISCNTF OF PETB07I > X'80'
              MOVE DISCNTL OF PETB07I TO DISCNTL OF W-PETB07I
              MOVE DISCNTF OF PETB07I TO DISCNTF OF W-PETB07I
              MOVE DISCNTI OF PETB07I TO DISCNTI OF W-PETB07I
           END-IF

           IF FROMDTL OF PETB07I NOT = 0
           OR FROMDTF OF PETB07I > X'80'
              MOVE FROMDTL OF PETB07I TO FROMDTL OF W-PETB07I
              MOVE FROMDTF OF PETB07I TO FROMDTF OF W-PETB07I
              MOVE FROMDTI OF PETB07I TO FROMDTI OF W-PETB07I
           END-IF

           IF TODTL OF PETB07I NOT = 0
           OR TODTF OF PETB07I > X'80'
              MOVE TODTL OF PETB07I TO TODTL OF W-PETB07I
              MOVE TODTF OF PETB07I TO TODTF OF W-PETB07I
              MOVE TODTI OF PETB07I TO TODTI OF W-PETB07I
           END-IF

           IF ACTIONL OF PETB07I NOT = 0
           OR ACTIONF OF PETB07I > X'80'
              MOVE ACTIONL OF PETB07I TO ACTIONL OF W-PETB07I
              MOVE ACTIONF OF PETB07I TO ACTIONF OF W-PETB07I
              MOVE FUNCTION UPPER-CASE(ACTIONI OF PETB07I) TO
                   ACTIONI OF W-PETB07I
           END-IF

           SET W-IE-POINTER TO ADDRESS OF STOREIDL OF W-PETB07I
           PERFORM R800-INPUT-EDIT
           IF STOREIDL OF W-PETB07I > 0
              MOVE LENGTH OF STOREIDI OF W-PETB07I TO
                   STOREIDL OF W-PETB07I
              EXEC CICS
                 BIF DEEDIT FIELD(STOREIDI OF W-PETB07I)
                            LENGTH(LENGTH OF STOREIDI OF W-PETB07I)
              END-EXEC
           END-IF

           SET W-IE-POINTER TO ADDRESS OF PRODIDL OF W-PETB07I
           PERFORM R800-INPUT-EDIT
           IF PRODIDL OF W-PETB07I > 0
              MOVE LENGTH OF PRODIDI OF W-PETB07I TO
                   PRODIDL OF W-PETB07I
              EXEC CICS
                 BIF DEEDIT FIELD(PRODIDI OF W-PETB07I)
                            LENGTH(LENGTH OF PRODIDI OF W-PETB07I)
              END-EXEC
           END-IF

           SET W-IE-POINTER TO ADDRESS OF ANIMLIDL OF W-PETB07I
           PERFORM R800-INPUT-EDIT
           IF ANIMLIDL OF W-PETB07I > 0
              MOVE LENGTH OF ANIMLIDI OF W-PETB07I TO
                   ANIMLIDL OF W-PETB07I
              EXEC CICS
                 BIF DEEDIT FIELD(ANIMLIDI OF W-PETB07I)
                            LENGTH(LENGTH OF ANIMLIDI OF W-PETB07I)
              END-EXEC
           END-IF

           SET W-IE-POINTER TO ADDRESS OF PRICEL OF W-PETB07I
           PERFORM R800-INPUT-EDIT
           IF PRICEL OF W-PETB07I > 0
              MOVE LENGTH OF PRICEI OF W-PETB07I TO
                   PRICEL OF W-PETB07I
              EXEC CICS
                 BIF DEEDIT FIELD(PRICEI OF W-PETB07I)
                            LENGTH(LENGTH OF PRICEI OF W-PETB07I)
              END-EXEC
           END-IF

           SET W-IE-POINTER TO ADDRESS OF DISCNTL OF W-PETB07I
           PERFORM R800-INPUT-EDIT
           IF DISCNTL OF W-PETB07I > 0
              MOVE LENGTH OF DISCNTI OF W-PETB07I TO
                   DISCNTL OF W-PETB07I
              EXEC CICS
                 BIF DEEDIT FIELD(DISCNTI OF W-PETB07I)
                            LENGTH(LENGTH OF DISCNTI OF W-PETB07I)
              END-EXEC
           END-IF

           SET W-IE-POINTER TO ADDRESS OF FROMDTL OF W-PETB07I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF TODTL OF W-PETB07I
           PERFORM R800-INPUT-EDIT
           .
       R310-PROCESS-BMS-END.
           EXIT.

       R320-PERFORM-ACTION SECTION.
           INITIALIZE W-LPETA007

           MOVE FUNCTION NATIONAL-OF(ACTIONI OF W-PETB07I) TO
                OPCODE OF W-LPETA007
           MOVE PADIDI OF W-PETB07I TO W-PADID
           MOVE W-PADID TO PADID OF W-LPETA007

           IF OPCODE OF W-LPETA007 NOT = N'D'
              MOVE STOREIDI OF W-PETB07I TO W-STOREID
              MOVE W-STOREID TO STOREID OF W-LPETA007
              MOVE PRODIDI OF W-PETB07I TO W-PRODUCTID
              MOVE W-PRODUCTID TO PRODUCTID OF W-LPETA007
              MOVE ANIMLIDI OF W-PETB07I TO W-ANIMALID
              MOVE W-ANIMALID TO ANIMALID OF W-LPETA007
           END-IF

           IF OPCODE OF W-LPETA007 = N'C'
           OR OPCODE OF W-LPETA007 = N'U'
              MOVE PRICEI OF W-PETB07I TO W-PRICE-R
              MOVE W-PRICE TO PRICE OF W-LPETA007
              MOVE DISCNTI OF W-PETB07I TO W-DISCOUNT-R
              MOVE W-DISCOUNT TO DISCOUNT OF W-LPETA007
              MOVE FUNCTION NATIONAL-OF(FROMDTI OF W-PETB07I) TO
                   FROMDATE OF W-LPETA007
              MOVE FUNCTION NATIONAL-OF(TODTI OF W-PETB07I) TO
                   TODATE OF W-LPETA007
           END-IF

           MOVE 'PETA007' TO W-PGMNAME

           CALL W-PGMNAME USING W-LPETA007

           MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETA007) TO
                ERRMSGO OF W-PETB07O
           
           IF  RETURNCODE OF W-LPETA007 = N'00'
              IF OPCODE OF W-LPETA007 NOT = N'D'
                 MOVE PADID OF W-LPETA007 TO W-PADID
                 MOVE W-PADID TO PADIDI OF W-PETB07I
                 MOVE 8       TO PADIDL OF W-PETB07I
                 MOVE STOREID OF W-LPETA007 TO W-STOREID
                 MOVE W-STOREID TO STOREIDI OF W-PETB07I
                 MOVE 8         TO STOREIDL OF W-PETB07I
                 MOVE PRODUCTID OF W-LPETA007 TO W-PRODUCTID
                 MOVE W-PRODUCTID TO PRODIDI OF W-PETB07I
                 MOVE 8           TO PRODIDL OF W-PETB07I
                 MOVE ANIMALID OF W-LPETA007 TO W-ANIMALID
                 MOVE W-ANIMALID TO ANIMLIDI OF W-PETB07I
                 MOVE 8          TO ANIMLIDL OF W-PETB07I
                 MOVE PRICE OF W-LPETA007 TO W-PRICE
                 MOVE W-PRICE-R TO PRICEI OF W-PETB07I
                 MOVE 9         TO PRICEL OF W-PETB07I
                 MOVE DISCOUNT OF W-LPETA007 TO W-DISCOUNT
                 MOVE W-DISCOUNT-R TO DISCNTI OF W-PETB07I
                 MOVE 9            TO DISCNTL OF W-PETB07I
                 MOVE FUNCTION DISPLAY-OF(FROMDATE OF W-LPETA007) TO
                      FROMDTI OF W-PETB07I
                 MOVE 26 TO FROMDTL OF W-PETB07I
                 MOVE FUNCTION DISPLAY-OF(TODATE OF W-LPETA007) TO
                      TODTI OF W-PETB07I
                 MOVE 26 TO TODTL OF W-PETB07I
                 MOVE FUNCTION DISPLAY-OF(CREATEDBY OF W-LPETA007) TO
                      CREBYI OF W-PETB07I
                 MOVE 8 TO CREBYL OF W-PETB07I
                 MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETA007) TO
                      CREDATEI OF W-PETB07I
                 MOVE 19 TO CREDATEL OF W-PETB07I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDBY OF W-LPETA007) TO
                      UPDBYI OF W-PETB07I
                 MOVE 8 TO UPDBYL OF W-PETB07I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETA007) TO
                      UPDDATEI OF W-PETB07I
                 MOVE 19 TO UPDDATEL OF W-PETB07I
              ELSE
                 MOVE LOW-VALUES TO PADIDI   OF W-PETB07I
                 MOVE 0          TO PADIDL   OF W-PETB07I
                 MOVE LOW-VALUES TO STOREIDI OF W-PETB07I
                 MOVE 0          TO STOREIDL OF W-PETB07I
                 MOVE LOW-VALUES TO PRODIDI  OF W-PETB07I 
                 MOVE 0          TO PRODIDL  OF W-PETB07I
                 MOVE LOW-VALUES TO ANIMLIDI OF W-PETB07I
                 MOVE 0          TO ANIMLIDL OF W-PETB07I
                 MOVE LOW-VALUES TO PRICEI   OF W-PETB07I
                 MOVE 0          TO PRICEL   OF W-PETB07I
                 MOVE LOW-VALUES TO DISCNTI  OF W-PETB07I
                 MOVE 0          TO DISCNTL  OF W-PETB07I
                 MOVE LOW-VALUES TO FROMDTI  OF W-PETB07I
                 MOVE 0          TO FROMDTL  OF W-PETB07I
                 MOVE LOW-VALUES TO TODTI    OF W-PETB07I
                 MOVE 0          TO TODTL    OF W-PETB07I
                 MOVE LOW-VALUES TO CREBYI   OF W-PETB07I
                 MOVE 0          TO CREBYL   OF W-PETB07I
                 MOVE LOW-VALUES TO CREDATEI OF W-PETB07I
                 MOVE 0          TO CREDATEL OF W-PETB07I
                 MOVE LOW-VALUES TO UPDBYI   OF W-PETB07I
                 MOVE 0          TO UPDBYL   OF W-PETB07I
                 MOVE LOW-VALUES TO UPDDATEI OF W-PETB07I
                 MOVE 0          TO UPDDATEL OF W-PETB07I
              END-IF

              MOVE LOW-VALUES TO ACTIONI OF W-PETB07I
              MOVE 0          TO ACTIONL OF W-PETB07I
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

       END PROGRAM PETC908.