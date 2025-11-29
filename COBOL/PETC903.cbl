       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETC903.
      *===============================================================*
      * This program is a screen program for the PET store CICS       *
      * emergency transaction to manipulate STORES records.           *
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
           05  C-CONT-NAME-B02       PIC X(16) VALUE 'BMS-PETB02'.
           05  C-CHNL-NAME           PIC X(16) VALUE 'PT90-CHANNEL'.
           05  C-DONE                PIC X(04) VALUE 'DONE'.
           05  C-ATTR-UNPROT-MDT     PIC X     VALUE X'C1'.
           05  C-ATTR-UNPROT-BRT-MDT PIC X     VALUE X'C9'.

           05  W-RETURNCODE          PIC X(2)  VALUE '00'.
           05  W-PGMNAME             PIC X(8)  VALUE SPACES.
           05  W-APPLID              PIC X(08) VALUE SPACES.
           05  W-STOREID             PIC 9(8).
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
       
       01  W-LPETM002.
           COPY LPETM002.

       COPY DFHAID.

       COPY PETB02.
       COPY PETB02 REPLACING ==PETB02I== BY ==W-PETB02I==
                             ==PETB02O== BY ==W-PETB02O==.

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
           MOVE LOW-VALUES TO PETB02I
           MOVE LOW-VALUES TO W-PETB02I

           MOVE C-CONT-NAME-900 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-LPETC900
           END-IF

           IF CURRENT-SCREEN OF W-LPETC900 = '02'
              SET SW-DO-INPUT-PROCESSING TO TRUE
           ELSE
              SET SW-SKIP-INPUT-PROCESSING TO TRUE
              MOVE '02' TO CURRENT-SCREEN OF W-LPETC900
           END-IF
           SET SW-DO-OUTPUT-PROCESSING TO TRUE

           MOVE C-CONT-NAME-B02 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-PETB02I

              IF SW-SKIP-INPUT-PROCESSING
                 MOVE '_' TO ACTIONI OF W-PETB02I
                 MOVE SPACES TO ERRMSGO OF W-PETB02O
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
              RECEIVE MAP('PETB02') MAPSET('PETB02')
                      INTO(PETB02I) NOHANDLE
           END-EXEC

           MOVE SPACES TO ERRMSGO OF W-PETB02O.

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
              STRING 'RECEIVE MAP ERROR PETB02 ' W-EIBRESP ' '
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

           MOVE W-APPLID         TO APPLIDO OF W-PETB02O
           STRING W-COBOL-DAY '-' W-COBOL-MONTH '-' W-COBOL-YEAR
                  DELIMITED BY SIZE
             INTO TODAYO OF W-PETB02O
           MOVE EIBTRNID         TO TRNIDO  OF W-PETB02O
           MOVE EIBTRMID         TO TRMIDO  OF W-PETB02O
           MOVE W-CURRDATE(12:8) TO NOWO    OF W-PETB02O

           IF SW-SKIP-INPUT-PROCESSING
              MOVE C-ATTR-UNPROT-MDT TO STORECDF OF W-PETB02I
              MOVE -1 TO STORECDL OF W-PETB02I
           END-IF

           MOVE W-PETB02I TO PETB02I

           EXEC CICS
              SEND MAP('PETB02') MAPSET('PETB02')
                   FROM(PETB02O) FREEKB ERASE CURSOR NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE C-CONT-NAME-B02 TO W-CONT-NAME
              MOVE LENGTH OF W-PETB02I TO W-CONT-LENGTH
              SET W-CONT-POINTER TO ADDRESS OF W-PETB02I

              PERFORM R920-PUT-CONTAINER
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'SEND MAP ERROR PETB02 ' W-EIBRESP ' '
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

           IF   ACTIONL OF W-PETB02I = 0
           OR  (ACTIONI OF W-PETB02I NOT = 'C'
           AND  ACTIONI OF W-PETB02I NOT = 'R'
           AND  ACTIONI OF W-PETB02I NOT = 'U'
           AND  ACTIONI OF W-PETB02I NOT = 'D')
              MOVE C-ATTR-UNPROT-BRT-MDT TO ACTIONF OF W-PETB02I
              MOVE -1 TO ACTIONL OF W-PETB02I
              MOVE 'INVALID ACTION' TO ERRMSGO OF W-PETB02O
              SET SW-INPUT-ERROR TO TRUE
           END-IF

           IF STORECDL OF W-PETB02I = 0
           OR STORECDI OF W-PETB02I = SPACES
              MOVE C-ATTR-UNPROT-BRT-MDT TO STORECDF OF W-PETB02I
              IF SW-INPUT-OK
                 MOVE -1 TO STORECDL OF W-PETB02I
                 MOVE 'INVALID STORECODE' TO ERRMSGO OF W-PETB02O
                 SET SW-INPUT-ERROR TO TRUE
              END-IF
           END-IF

           IF ACTIONI OF W-PETB02I = 'C'
           OR ACTIONI OF W-PETB02I = 'U'
              IF STORESTL OF W-PETB02I = 0
              OR STORESTI OF W-PETB02I = SPACES
                 MOVE C-ATTR-UNPROT-BRT-MDT TO STORESTF OF W-PETB02I
                 IF SW-INPUT-OK
                    MOVE -1 TO STORESTL OF W-PETB02I
                    MOVE 'INVALID STORESTATUS' TO ERRMSGO OF W-PETB02O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF

              IF SW-INPUT-OK
                 INITIALIZE W-LPETM001
                 MOVE N'R' TO OPCODE OF W-LPETM001
                 MOVE N'STORSTAT' TO TABLEID OF W-LPETM001
                 MOVE FUNCTION NATIONAL-OF(STORESTI OF W-PETB02I) TO
                      TABKEY OF W-LPETM001
              
                 MOVE 'PETM001' TO W-PGMNAME

                 CALL W-PGMNAME USING W-LPETM001

                 IF RETURNCODE OF W-LPETM001 NOT = N'00'
                    MOVE C-ATTR-UNPROT-BRT-MDT TO STORESTF OF W-PETB02I
                    MOVE -1 TO STORESTL OF W-PETB02I
                    MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETM001)
                         TO ERRMSGO OF W-PETB02O
                    SET SW-INPUT-ERROR TO TRUE
                 END-IF
              END-IF
           END-IF
           .
       R210-CHECK-INPUT-END.
           EXIT.

       R310-PROCESS-BMS SECTION.
           IF STORECDL OF PETB02I NOT = 0
           OR STORECDF OF PETB02I > X'80'
              MOVE STORECDL OF PETB02I TO STORECDL OF W-PETB02I
              MOVE STORECDF OF PETB02I TO STORECDF OF W-PETB02I
              MOVE FUNCTION UPPER-CASE(STORECDI OF PETB02I) TO
                   STORECDI OF W-PETB02I
           END-IF

           IF STORESTL OF PETB02I NOT = 0
           OR STORESTF OF PETB02I > X'80'
              MOVE STORESTL OF PETB02I TO STORESTL OF W-PETB02I
              MOVE STORESTF OF PETB02I TO STORESTF OF W-PETB02I
              MOVE FUNCTION UPPER-CASE(STORESTI OF PETB02I) TO
                   STORESTI OF W-PETB02I
           END-IF

           IF STORNM1L OF PETB02I NOT = 0
           OR STORNM1F OF PETB02I > X'80'
              MOVE STORNM1L OF PETB02I TO STORNM1L OF W-PETB02I
              MOVE STORNM1F OF PETB02I TO STORNM1F OF W-PETB02I
              MOVE STORNM1I OF PETB02I TO STORNM1I OF W-PETB02I
           END-IF

           IF STORNM2L OF PETB02I NOT = 0
           OR STORNM2F OF PETB02I > X'80'
              MOVE STORNM2L OF PETB02I TO STORNM2L OF W-PETB02I
              MOVE STORNM2F OF PETB02I TO STORNM2F OF W-PETB02I
              MOVE STORNM2I OF PETB02I TO STORNM2I OF W-PETB02I
           END-IF

           IF STORNM3L OF PETB02I NOT = 0
           OR STORNM3F OF PETB02I > X'80'
              MOVE STORNM3L OF PETB02I TO STORNM3L OF W-PETB02I
              MOVE STORNM3F OF PETB02I TO STORNM3F OF W-PETB02I
              MOVE STORNM3I OF PETB02I TO STORNM3I OF W-PETB02I
           END-IF

           IF STORNM4L OF PETB02I NOT = 0
           OR STORNM4F OF PETB02I > X'80'
              MOVE STORNM4L OF PETB02I TO STORNM4L OF W-PETB02I
              MOVE STORNM4F OF PETB02I TO STORNM4F OF W-PETB02I
              MOVE STORNM4I OF PETB02I TO STORNM4I OF W-PETB02I
           END-IF

           IF STORNM5L OF PETB02I NOT = 0
           OR STORNM5F OF PETB02I > X'80'
              MOVE STORNM5L OF PETB02I TO STORNM5L OF W-PETB02I
              MOVE STORNM5F OF PETB02I TO STORNM5F OF W-PETB02I
              MOVE STORNM5I OF PETB02I TO STORNM5I OF W-PETB02I
           END-IF

           IF ACTIONL OF PETB02I NOT = 0
           OR ACTIONF OF PETB02I > X'80'
              MOVE ACTIONL OF PETB02I TO ACTIONL OF W-PETB02I
              MOVE ACTIONF OF PETB02I TO ACTIONF OF W-PETB02I
              MOVE FUNCTION UPPER-CASE(ACTIONI OF PETB02I) TO
                   ACTIONI OF W-PETB02I
           END-IF

           SET W-IE-POINTER TO ADDRESS OF STORECDL OF W-PETB02I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF STORESTL OF W-PETB02I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF STORNM1L OF W-PETB02I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF STORNM2L OF W-PETB02I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF STORNM3L OF W-PETB02I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF STORNM4L OF W-PETB02I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF STORNM5L OF W-PETB02I
           PERFORM R800-INPUT-EDIT
           .
       R310-PROCESS-BMS-END.
           EXIT.

       R320-PERFORM-ACTION SECTION.
           INITIALIZE W-LPETM002

           MOVE FUNCTION NATIONAL-OF(ACTIONI OF W-PETB02I) TO
                OPCODE OF W-LPETM002
           MOVE STOREIDI OF W-PETB02I TO STOREID OF W-LPETM002
           MOVE FUNCTION NATIONAL-OF(STORECDI OF W-PETB02I) TO
                STORECODE OF W-LPETM002
           
           IF OPCODE OF W-LPETM001 NOT = N'D'
              MOVE FUNCTION NATIONAL-OF(STORESTI OF W-PETB02I) TO
                   STORESTATUS OF W-LPETM002
           END-IF

           IF OPCODE OF W-LPETM002 = N'C'
           OR OPCODE OF W-LPETM002 = N'U'
              MOVE STORNM1L OF W-PETB02I TO STORENAME-LEN OF W-LPETM002
              MOVE FUNCTION NATIONAL-OF(STORNM1I OF W-PETB02I) TO
                   STORENAME-TEXT OF W-LPETM002
           END-IF

           MOVE 'PETM002' TO W-PGMNAME

           CALL W-PGMNAME USING W-LPETM002

           MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETM002) TO
                ERRMSGO OF W-PETB02O
           
           IF  RETURNCODE OF W-LPETM002 = N'00'
              IF OPCODE OF W-LPETM002 NOT = N'D'
                 MOVE STOREID OF W-LPETM002 TO W-STOREID
                 MOVE W-STOREID TO STOREIDI OF W-PETB02I
                 MOVE 8         TO STOREIDL OF W-PETB02I
                 MOVE FUNCTION DISPLAY-OF(STORECODE OF W-LPETM002) TO
                      STORECDI OF W-PETB02I
                 MOVE 8 TO STORECDL OF W-PETB02I
                 MOVE FUNCTION DISPLAY-OF(STORESTATUS OF W-LPETM002) TO
                      STORESTI OF W-PETB02I
                 MOVE 8 TO STORESTL OF W-PETB02I
                 MOVE FUNCTION DISPLAY-OF(
                         STORENAME-TEXT OF W-LPETM002(1:
                            STORENAME-LEN OF W-LPETM002)) TO
                      STORNM1I OF W-PETB02I
                 IF STORENAME-LEN OF W-LPETM002 >= 60
                    MOVE 60 TO STORNM1L OF W-PETB02I
                 ELSE
                    MOVE STORENAME-LEN OF W-LPETM002 TO
                         STORNM1L OF W-PETB02I
                 END-IF
                 MOVE FUNCTION DISPLAY-OF(CREATEDBY OF W-LPETM002) TO
                      CREBYI OF W-PETB02I
                 MOVE 8 TO CREBYL OF W-PETB02I
                 MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM002) TO
                      CREDATEI OF W-PETB02I
                 MOVE 19 TO CREDATEL OF W-PETB02I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDBY OF W-LPETM002) TO
                      UPDBYI OF W-PETB02I
                 MOVE 8 TO UPDBYL OF W-PETB02I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM002) TO
                      UPDDATEI OF W-PETB02I
                 MOVE 19 TO UPDDATEL OF W-PETB02I
              ELSE
                 MOVE LOW-VALUES TO STOREIDI OF W-PETB02I
                 MOVE 0          TO STOREIDL OF W-PETB02I
                 MOVE LOW-VALUES TO STORECDI OF W-PETB02I
                 MOVE 0          TO STORECDL OF W-PETB02I
                 MOVE LOW-VALUES TO STORESTI OF W-PETB02I 
                 MOVE 0          TO STORESTL OF W-PETB02I
                 MOVE LOW-VALUES TO STORNM1I OF W-PETB02I
                 MOVE 0          TO STORNM1L OF W-PETB02I
                 MOVE LOW-VALUES TO STORNM2I OF W-PETB02I
                 MOVE 0          TO STORNM2L OF W-PETB02I
                 MOVE LOW-VALUES TO STORNM3I OF W-PETB02I
                 MOVE 0          TO STORNM3L OF W-PETB02I
                 MOVE LOW-VALUES TO STORNM4I OF W-PETB02I
                 MOVE 0          TO STORNM4L OF W-PETB02I
                 MOVE LOW-VALUES TO STORNM5I OF W-PETB02I
                 MOVE 0          TO STORNM5L OF W-PETB02I
                 MOVE LOW-VALUES TO CREBYI   OF W-PETB02I
                 MOVE 0          TO CREBYL   OF W-PETB02I
                 MOVE LOW-VALUES TO CREDATEI OF W-PETB02I
                 MOVE 0          TO CREDATEL OF W-PETB02I
                 MOVE LOW-VALUES TO UPDBYI   OF W-PETB02I
                 MOVE 0          TO UPDBYL   OF W-PETB02I
                 MOVE LOW-VALUES TO UPDDATEI OF W-PETB02I
                 MOVE 0          TO UPDDATEL OF W-PETB02I
              END-IF

              MOVE LOW-VALUES TO ACTIONI OF W-PETB02I
              MOVE 0          TO ACTIONL OF W-PETB02I
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

       END PROGRAM PETC903.