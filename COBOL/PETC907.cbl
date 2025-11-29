       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETC907.
      *===============================================================*
      * This program is a screen program for the PET store CICS       *
      * emergency transaction to manipulate ANIMALS records.          *
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
           05  C-CONT-NAME-B06       PIC X(16) VALUE 'BMS-PETB06'.
           05  C-CHNL-NAME           PIC X(16) VALUE 'PT90-CHANNEL'.
           05  C-DONE                PIC X(04) VALUE 'DONE'.
           05  C-ATTR-UNPROT-MDT     PIC X     VALUE X'C1'.
           05  C-ATTR-UNPROT-BRT-MDT PIC X     VALUE X'C9'.

           05  W-RETURNCODE          PIC X(2)  VALUE '00'.
           05  W-PGMNAME             PIC X(8)  VALUE SPACES.
           05  W-APPLID              PIC X(08) VALUE SPACES.
           05  W-ANIMALID            PIC 9(8).
           05  W-STOREID             PIC 9(8).
           05  W-ANIMALAGE           PIC 9(8).
           05  W-ANIMALCOUNT         PIC 9(8).
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
       
       01  W-LPETM001.
           COPY LPETM001.
       
       01  W-LPETM006.
           COPY LPETM006.

       COPY DFHAID.

       COPY PETB06.
       COPY PETB06 REPLACING ==PETB06I== BY ==W-PETB06I==
                             ==PETB06O== BY ==W-PETB06O==.

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

      *===============================================================*
      * R001-INIT: Program initialisations                            *
      *===============================================================*
       R001-INIT SECTION.
           MOVE LOW-VALUES TO PETB06I
           MOVE LOW-VALUES TO W-PETB06I

           MOVE C-CONT-NAME-900 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-LPETC900
           END-IF

           IF CURRENT-SCREEN OF W-LPETC900 = '06'
              SET SW-DO-INPUT-PROCESSING TO TRUE
           ELSE
              SET SW-SKIP-INPUT-PROCESSING TO TRUE
              MOVE '06' TO CURRENT-SCREEN OF W-LPETC900
           END-IF
           SET SW-DO-OUTPUT-PROCESSING TO TRUE

           MOVE C-CONT-NAME-B06 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-PETB06I

              IF SW-SKIP-INPUT-PROCESSING
                 MOVE '_' TO ACTIONI OF W-PETB06I
                 MOVE SPACES TO ERRMSGO OF W-PETB06O
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

       R110-INPUT-PROC SECTION.
           EXEC CICS
              RECEIVE MAP('PETB06') MAPSET('PETB06')
                      INTO(PETB06I) NOHANDLE
           END-EXEC

           MOVE SPACES TO ERRMSGO OF W-PETB06O.

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
              STRING 'RECEIVE MAP ERROR PETB06 ' W-EIBRESP ' '
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

           MOVE W-APPLID         TO APPLIDO OF W-PETB06O
           STRING W-COBOL-DAY '-' W-COBOL-MONTH '-' W-COBOL-YEAR
                  DELIMITED BY SIZE
             INTO TODAYO OF W-PETB06O
           MOVE EIBTRNID         TO TRNIDO  OF W-PETB06O
           MOVE EIBTRMID         TO TRMIDO  OF W-PETB06O
           MOVE W-CURRDATE(12:8) TO NOWO    OF W-PETB06O

           IF SW-SKIP-INPUT-PROCESSING
              MOVE C-ATTR-UNPROT-MDT TO STOREIDF OF W-PETB06I
              MOVE -1 TO STOREIDL OF W-PETB06I
           END-IF

           MOVE W-PETB06I TO PETB06I

           EXEC CICS
              SEND MAP('PETB06') MAPSET('PETB06')
                   FROM(PETB06O) FREEKB ERASE CURSOR NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE C-CONT-NAME-B06 TO W-CONT-NAME
              MOVE LENGTH OF W-PETB06I TO W-CONT-LENGTH
              SET W-CONT-POINTER TO ADDRESS OF W-PETB06I

              PERFORM R920-PUT-CONTAINER
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'SEND MAP ERROR PETB06 ' W-EIBRESP ' '
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

           IF   ACTIONL OF W-PETB06I = 0
           OR  (ACTIONI OF W-PETB06I NOT = 'C'
           AND  ACTIONI OF W-PETB06I NOT = 'R'
           AND  ACTIONI OF W-PETB06I NOT = 'U'
           AND  ACTIONI OF W-PETB06I NOT = 'D')
              MOVE C-ATTR-UNPROT-BRT-MDT TO ACTIONF OF W-PETB06I
              MOVE -1 TO ACTIONL OF W-PETB06I
              MOVE 'INVALID ACTION' TO ERRMSGO OF W-PETB06O
              SET SW-INPUT-ERROR TO TRUE
           END-IF

           IF ACTIONI OF W-PETB06I NOT = 'D'
              IF STOREIDL OF W-PETB06I = 0
              OR STOREIDI OF W-PETB06I = SPACES
                 MOVE C-ATTR-UNPROT-BRT-MDT TO STOREIDF OF W-PETB06I
                 IF SW-INPUT-OK
                    MOVE -1 TO STOREIDL OF W-PETB06I
                    MOVE 'INVALID STOREID' TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF ANIMLTPL OF W-PETB06I = 0
              OR ANIMLTPI OF W-PETB06I = SPACES
                 MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLTPF OF W-PETB06I
                 IF SW-INPUT-OK
                    MOVE -1 TO ANIMLTPL OF W-PETB06I
                    MOVE 'INVALID ANIMALTYPE' TO
                         ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF ANIMLRCL OF W-PETB06I = 0
              OR ANIMLRCI OF W-PETB06I = SPACES
                 MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLRCF OF W-PETB06I
                 IF SW-INPUT-OK
                    MOVE -1 TO ANIMLRCL OF W-PETB06I
                    MOVE 'INVALID ANIMALRACE' TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF ANIMLNML OF W-PETB06I = 0
              OR ANIMLNMI OF W-PETB06I = SPACES
                 MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLNMF OF W-PETB06I
                 IF SW-INPUT-OK
                    MOVE -1 TO ANIMLNML OF W-PETB06I
                    MOVE 'INVALID ANIMALNAME' TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF
           END-IF

           IF ACTIONI OF W-PETB06I = 'C'
           OR ACTIONI OF W-PETB06I = 'U'
              IF   ANIMLGEL OF W-PETB06I = 0
              OR  (ANIMLGEI OF W-PETB06I NOT = 'M'
              AND  ANIMLGEI OF W-PETB06I NOT = 'F')
                 MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLGEF OF W-PETB06I
                 IF SW-INPUT-OK
                    MOVE -1 TO ANIMLGEL OF W-PETB06I
                    MOVE 'INVALID ANIMALGENDER' TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF ANIMLAGL OF W-PETB06I = 0
              OR ANIMLAGI OF W-PETB06I = ZEROS
                 MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLAGF OF W-PETB06I
                 IF SW-INPUT-OK
                    MOVE -1 TO ANIMLAGL OF W-PETB06I
                    MOVE 'INVALID ANIMALAGE' TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF ANIMLCOL OF W-PETB06I = 0
              OR ANIMLCOI OF W-PETB06I = ZEROS
                 MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLCOF OF W-PETB06I
                 IF SW-INPUT-OK
                    MOVE -1 TO ANIMLCOL OF W-PETB06I
                    MOVE 'INVALID ANIMALCOUNT' TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF SW-INPUT-OK
                 INITIALIZE W-LPETM001
                 MOVE N'R' TO OPCODE OF W-LPETM001
                 MOVE N'ANMLTYPE' TO TABLEID OF W-LPETM001
                 MOVE FUNCTION NATIONAL-OF(ANIMLTPI OF W-PETB06I) TO
                      TABKEY OF W-LPETM001
              
                 MOVE 'PETM001' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETM001

                 IF RETURNCODE OF W-LPETM001 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLTPF OF W-PETB06I
                    MOVE -1 TO ANIMLTPL OF W-PETB06I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETM001)
                         TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF SW-INPUT-OK
                 INITIALIZE W-LPETM001
                 MOVE N'R' TO OPCODE OF W-LPETM001
                 MOVE N'ANMLRACE' TO TABLEID OF W-LPETM001
                 MOVE FUNCTION NATIONAL-OF(ANIMLRCI OF W-PETB06I) TO
                      TABKEY OF W-LPETM001
                 
                 MOVE 'PETM001' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETM001

                 IF RETURNCODE OF W-LPETM001 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO ANIMLRCF OF W-PETB06I
                    MOVE -1 TO ANIMLRCL OF W-PETB06I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETM001)
                         TO ERRMSGO OF W-PETB06O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF
           END-IF
           .
       R210-CHECK-INPUT-END.
           EXIT.

       R310-PROCESS-BMS SECTION.
           IF STOREIDL OF PETB06I NOT = 0
           OR STOREIDF OF PETB06I > X'80'
              MOVE STOREIDL OF PETB06I TO STOREIDL OF W-PETB06I
              MOVE STOREIDF OF PETB06I TO STOREIDF OF W-PETB06I
              MOVE STOREIDI OF PETB06I TO STOREIDI OF W-PETB06I
           END-IF

           IF ANIMLTPL OF PETB06I NOT = 0
           OR ANIMLTPF OF PETB06I > X'80'
              MOVE ANIMLTPL OF PETB06I TO ANIMLTPL OF W-PETB06I
              MOVE ANIMLTPF OF PETB06I TO ANIMLTPF OF W-PETB06I
              MOVE FUNCTION UPPER-CASE(ANIMLTPI OF PETB06I) TO
                   ANIMLTPI OF W-PETB06I
           END-IF

           IF ANIMLRCL OF PETB06I NOT = 0
           OR ANIMLRCF OF PETB06I > X'80'
              MOVE ANIMLRCL OF PETB06I TO ANIMLRCL OF W-PETB06I
              MOVE ANIMLRCF OF PETB06I TO ANIMLRCF OF W-PETB06I
              MOVE FUNCTION UPPER-CASE(ANIMLRCI OF PETB06I) TO
                   ANIMLRCI OF W-PETB06I
           END-IF

           IF ANIMLNML OF PETB06I NOT = 0
           OR ANIMLNMF OF PETB06I > X'80'
              MOVE ANIMLNML OF PETB06I TO ANIMLNML OF W-PETB06I
              MOVE ANIMLNMF OF PETB06I TO ANIMLNMF OF W-PETB06I
              MOVE ANIMLNMI OF PETB06I TO ANIMLNMI OF W-PETB06I
           END-IF

           IF ANIMLGEL OF PETB06I NOT = 0
           OR ANIMLGEF OF PETB06I > X'80'
              MOVE ANIMLGEL OF PETB06I TO ANIMLGEL OF W-PETB06I
              MOVE ANIMLGEF OF PETB06I TO ANIMLGEF OF W-PETB06I
              MOVE FUNCTION UPPER-CASE(ANIMLGEI OF PETB06I) TO
                   ANIMLGEI OF W-PETB06I
           END-IF

           IF ANIMLAGL OF PETB06I NOT = 0
           OR ANIMLAGF OF PETB06I > X'80'
              MOVE ANIMLAGL OF PETB06I TO ANIMLAGL OF W-PETB06I
              MOVE ANIMLAGF OF PETB06I TO ANIMLAGF OF W-PETB06I
              MOVE ANIMLAGI OF PETB06I TO ANIMLAGI OF W-PETB06I
           END-IF

           IF ANIMLCOL OF PETB06I NOT = 0
           OR ANIMLCOF OF PETB06I > X'80'
              MOVE ANIMLCOL OF PETB06I TO ANIMLCOL OF W-PETB06I
              MOVE ANIMLCOF OF PETB06I TO ANIMLCOF OF W-PETB06I
              MOVE ANIMLCOI OF PETB06I TO ANIMLCOI OF W-PETB06I
           END-IF

           IF ACTIONL OF PETB06I NOT = 0
           OR ACTIONF OF PETB06I > X'80'
              MOVE ACTIONL OF PETB06I TO ACTIONL OF W-PETB06I
              MOVE ACTIONF OF PETB06I TO ACTIONF OF W-PETB06I
              MOVE FUNCTION UPPER-CASE(ACTIONI OF PETB06I) TO
                   ACTIONI OF W-PETB06I
           END-IF

           SET W-IE-POINTER TO ADDRESS OF STOREIDL OF W-PETB06I
           PERFORM R800-INPUT-EDIT
           IF STOREIDL OF W-PETB06I > 0
              MOVE LENGTH OF STOREIDI OF W-PETB06I TO
                   STOREIDL OF W-PETB06I
              EXEC CICS
                 BIF DEEDIT FIELD(STOREIDI OF W-PETB06I)
                            LENGTH(LENGTH OF STOREIDI OF W-PETB06I)
              END-EXEC
           END-IF

           SET W-IE-POINTER TO ADDRESS OF ANIMLTPL OF W-PETB06I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF ANIMLRCL OF W-PETB06I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF ANIMLNML OF W-PETB06I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF ANIMLGEL OF W-PETB06I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF ANIMLAGL OF W-PETB06I
           PERFORM R800-INPUT-EDIT
           IF ANIMLAGL OF W-PETB06I > 0
              MOVE LENGTH OF ANIMLAGI OF W-PETB06I TO
                   ANIMLAGL OF W-PETB06I
              EXEC CICS
                 BIF DEEDIT FIELD(ANIMLAGI OF W-PETB06I)
                            LENGTH(LENGTH OF ANIMLAGI OF W-PETB06I)
              END-EXEC
           END-IF

           SET W-IE-POINTER TO ADDRESS OF ANIMLCOL OF W-PETB06I
           PERFORM R800-INPUT-EDIT
           IF ANIMLCOL OF W-PETB06I > 0
              MOVE LENGTH OF ANIMLCOI OF W-PETB06I TO
                   ANIMLCOL OF W-PETB06I
              EXEC CICS
                 BIF DEEDIT FIELD(ANIMLCOI OF W-PETB06I)
                            LENGTH(LENGTH OF ANIMLCOI OF W-PETB06I)
              END-EXEC
           END-IF
           .
       R310-PROCESS-BMS-END.
           EXIT.

       R320-PERFORM-ACTION SECTION.
           INITIALIZE W-LPETM006

           MOVE FUNCTION NATIONAL-OF(ACTIONI OF W-PETB06I) TO
                OPCODE OF W-LPETM006
           MOVE ANIMLIDI OF W-PETB06I TO W-ANIMALID
           MOVE W-ANIMALID TO ANIMALID OF W-LPETM006

           IF OPCODE OF W-LPETM001 NOT = N'D'
              MOVE STOREIDI OF W-PETB06I TO W-STOREID
              MOVE W-STOREID TO STOREID OF W-LPETM006
              MOVE FUNCTION NATIONAL-OF(ANIMLTPI OF W-PETB06I) TO
                   ANIMALTYPE OF W-LPETM006
              MOVE FUNCTION NATIONAL-OF(ANIMLRCI OF W-PETB06I) TO
                   ANIMALRACE OF W-LPETM006
              MOVE ANIMLNML OF W-PETB06I TO ANIMALNAME-LEN OF W-LPETM006
              MOVE FUNCTION NATIONAL-OF(ANIMLNMI OF W-PETB06I) TO
                   ANIMALNAME-TEXT OF W-LPETM006
           END-IF

           IF OPCODE OF W-LPETM006 = N'C'
           OR OPCODE OF W-LPETM006 = N'U'
              MOVE ANIMLGEI OF W-PETB06I TO ANIMALGENDER OF W-LPETM006
              MOVE ANIMLAGI OF W-PETB06I TO W-ANIMALAGE
              MOVE W-ANIMALAGE TO ANIMALAGE OF W-LPETM006
              MOVE ANIMLCOI OF W-PETB06I TO W-ANIMALCOUNT
              MOVE W-ANIMALCOUNT TO ANIMALCOUNT OF W-LPETM006
           END-IF

           MOVE 'PETM006' TO W-PGMNAME

           CALL W-PGMNAME USING W-LPETM006

           MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETM006) TO
                ERRMSGO OF W-PETB06O
           
           IF  RETURNCODE OF W-LPETM006 = N'00'
              IF OPCODE OF W-LPETM006 NOT = N'D'
                 MOVE ANIMALID OF W-LPETM006 TO W-ANIMALID
                 MOVE W-ANIMALID TO ANIMLIDI OF W-PETB06I
                 MOVE 8          TO ANIMLIDL OF W-PETB06I
                 MOVE STOREID OF W-LPETM006 TO W-STOREID
                 MOVE W-STOREID TO STOREIDI OF W-PETB06I
                 MOVE 8         TO STOREIDL OF W-PETB06I
                 MOVE FUNCTION DISPLAY-OF(ANIMALTYPE OF W-LPETM006) TO
                      ANIMLTPI OF W-PETB06I
                 MOVE 8 TO ANIMLTPL OF W-PETB06I
                 MOVE FUNCTION DISPLAY-OF(ANIMALRACE OF W-LPETM006)
                      TO ANIMLRCI OF W-PETB06I
                 MOVE 8 TO ANIMLRCL OF W-PETB06I
                 MOVE FUNCTION DISPLAY-OF(
                         ANIMALNAME-TEXT OF W-LPETM006(1:
                            ANIMALNAME-LEN OF W-LPETM006)) TO
                      ANIMLNMI OF W-PETB06I
                 IF ANIMALNAME-LEN OF W-LPETM006 >= 60
                    MOVE 60 TO ANIMLNML OF W-PETB06I
                 ELSE
                    MOVE ANIMALNAME-LEN OF W-LPETM006 TO
                         ANIMLNML OF W-PETB06I
                 END-IF
                 MOVE FUNCTION DISPLAY-OF(ANIMALGENDER OF W-LPETM006) TO
                      ANIMLGEI OF W-PETB06I
                 MOVE 1 TO ANIMLGEL OF W-PETB06I
                 MOVE ANIMALAGE OF W-LPETM006 TO W-ANIMALAGE
                 MOVE W-ANIMALAGE TO ANIMLAGI OF W-PETB06I
                 MOVE 8           TO ANIMLAGL OF W-PETB06I
                 MOVE ANIMALCOUNT OF W-LPETM006 TO W-ANIMALCOUNT
                 MOVE W-ANIMALCOUNT TO ANIMLCOI OF W-PETB06I
                 MOVE 8             TO ANIMLCOL OF W-PETB06I
                 MOVE FUNCTION DISPLAY-OF(CREATEDBY OF W-LPETM006) TO
                      CREBYI OF W-PETB06I
                 MOVE 8 TO CREBYL OF W-PETB06I
                 MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM006) TO
                      CREDATEI OF W-PETB06I
                 MOVE 19 TO CREDATEL OF W-PETB06I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDBY OF W-LPETM006) TO
                      UPDBYI OF W-PETB06I
                 MOVE 8 TO UPDBYL OF W-PETB06I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM006) TO
                      UPDDATEI OF W-PETB06I
                 MOVE 19 TO UPDDATEL OF W-PETB06I
              ELSE
                 MOVE LOW-VALUES TO ANIMLIDI OF W-PETB06I
                 MOVE 0          TO ANIMLIDL OF W-PETB06I
                 MOVE LOW-VALUES TO STOREIDI OF W-PETB06I
                 MOVE 0          TO STOREIDL OF W-PETB06I
                 MOVE LOW-VALUES TO ANIMLTPI OF W-PETB06I 
                 MOVE 0          TO ANIMLTPL OF W-PETB06I
                 MOVE LOW-VALUES TO ANIMLRCI OF W-PETB06I
                 MOVE 0          TO ANIMLRCL OF W-PETB06I
                 MOVE LOW-VALUES TO ANIMLNMI OF W-PETB06I
                 MOVE 0          TO ANIMLNML OF W-PETB06I
                 MOVE LOW-VALUES TO ANIMLGEI OF W-PETB06I
                 MOVE 0          TO ANIMLGEL OF W-PETB06I
                 MOVE LOW-VALUES TO ANIMLAGI OF W-PETB06I
                 MOVE 0          TO ANIMLAGL OF W-PETB06I
                 MOVE LOW-VALUES TO ANIMLCOI OF W-PETB06I
                 MOVE 0          TO ANIMLCOL OF W-PETB06I
                 MOVE LOW-VALUES TO CREBYI   OF W-PETB06I
                 MOVE 0          TO CREBYL   OF W-PETB06I
                 MOVE LOW-VALUES TO CREDATEI OF W-PETB06I
                 MOVE 0          TO CREDATEL OF W-PETB06I
                 MOVE LOW-VALUES TO UPDBYI   OF W-PETB06I
                 MOVE 0          TO UPDBYL   OF W-PETB06I
                 MOVE LOW-VALUES TO UPDDATEI OF W-PETB06I
                 MOVE 0          TO UPDDATEL OF W-PETB06I
              END-IF

              MOVE LOW-VALUES TO ACTIONI OF W-PETB06I
              MOVE 0          TO ACTIONL OF W-PETB06I
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

       END PROGRAM PETC907.