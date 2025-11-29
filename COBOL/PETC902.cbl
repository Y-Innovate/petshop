       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETC902.
      *===============================================================*
      * This program is a screen program for the PET store CICS       *
      * emergency transaction to manipulate REFTABLES records.        *
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
           05  C-CONT-NAME-B01       PIC X(16) VALUE 'BMS-PETB01'.
           05  C-CHNL-NAME           PIC X(16) VALUE 'PT90-CHANNEL'.
           05  C-DONE                PIC X(04) VALUE 'DONE'.
           05  C-ATTR-UNPROT-MDT     PIC X     VALUE X'C1'.
           05  C-ATTR-UNPROT-BRT-MDT PIC X     VALUE X'C9'.

           05  W-RETURNCODE          PIC X(2)  VALUE '00'.
           05  W-PGMNAME             PIC X(8)  VALUE SPACES.
           05  W-APPLID              PIC X(08) VALUE SPACES.
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

       COPY DFHAID.

       COPY PETB01.
       COPY PETB01 REPLACING ==PETB01I== BY ==W-PETB01I==
                             ==PETB01O== BY ==W-PETB01O==.

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
           MOVE LOW-VALUES TO PETB01I
           MOVE LOW-VALUES TO W-PETB01I

           MOVE C-CONT-NAME-900 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-LPETC900
           END-IF

           IF CURRENT-SCREEN OF W-LPETC900 = '01'
              SET SW-DO-INPUT-PROCESSING TO TRUE
           ELSE
              SET SW-SKIP-INPUT-PROCESSING TO TRUE
              MOVE '01' TO CURRENT-SCREEN OF W-LPETC900
           END-IF
           SET SW-DO-OUTPUT-PROCESSING TO TRUE

           MOVE C-CONT-NAME-B01 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-PETB01I

              IF SW-SKIP-INPUT-PROCESSING
                 MOVE '_' TO ACTIONI OF W-PETB01I
                 MOVE SPACES TO ERRMSGO OF W-PETB01O
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
              RECEIVE MAP('PETB01') MAPSET('PETB01')
                      INTO(PETB01I) NOHANDLE
           END-EXEC

           MOVE SPACES TO ERRMSGO OF W-PETB01O.

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
              STRING 'RECEIVE MAP ERROR PETB01 ' W-EIBRESP ' '
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

           MOVE W-APPLID         TO APPLIDO OF W-PETB01O
           STRING W-COBOL-DAY '-' W-COBOL-MONTH '-' W-COBOL-YEAR
                  DELIMITED BY SIZE
             INTO TODAYO OF W-PETB01O
           MOVE EIBTRNID         TO TRNIDO  OF W-PETB01O
           MOVE EIBTRMID         TO TRMIDO  OF W-PETB01O
           MOVE W-CURRDATE(12:8) TO NOWO    OF W-PETB01O

           IF SW-SKIP-INPUT-PROCESSING
              MOVE C-ATTR-UNPROT-MDT TO TABIDF OF W-PETB01I
              MOVE -1 TO TABIDL OF W-PETB01I
           END-IF

           MOVE W-PETB01I TO PETB01I

           EXEC CICS
              SEND MAP('PETB01') MAPSET('PETB01')
                   FROM(PETB01O) FREEKB ERASE CURSOR NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE C-CONT-NAME-B01 TO W-CONT-NAME
              MOVE LENGTH OF W-PETB01I TO W-CONT-LENGTH
              SET W-CONT-POINTER TO ADDRESS OF W-PETB01I

              PERFORM R920-PUT-CONTAINER
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'SEND MAP ERROR PETB01 ' W-EIBRESP ' '
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

           IF   ACTIONL OF W-PETB01I = 0
           OR  (ACTIONI OF W-PETB01I NOT = 'C'
           AND  ACTIONI OF W-PETB01I NOT = 'R'
           AND  ACTIONI OF W-PETB01I NOT = 'U'
           AND  ACTIONI OF W-PETB01I NOT = 'D')
              MOVE C-ATTR-UNPROT-BRT-MDT TO ACTIONF OF W-PETB01I
              MOVE -1 TO ACTIONL OF W-PETB01I
              MOVE 'INVALID ACTION' TO ERRMSGO OF W-PETB01O
              SET SW-INPUT-ERROR TO TRUE
           END-IF

           IF TABIDL OF W-PETB01I = 0
           OR TABIDI OF W-PETB01I = SPACES
              MOVE C-ATTR-UNPROT-BRT-MDT TO TABIDF OF W-PETB01I
              IF SW-INPUT-OK
                 MOVE -1 TO TABIDL OF W-PETB01I
                 MOVE 'INVALID TABLEID' TO ERRMSGO OF W-PETB01O
              END-IF
              SET SW-INPUT-ERROR TO TRUE
           END-IF

           IF TABKEYL OF W-PETB01I = 0
           OR TABKEYI OF W-PETB01I = SPACES
              MOVE C-ATTR-UNPROT-BRT-MDT TO TABKEYF OF W-PETB01I
              IF SW-INPUT-OK
                 MOVE -1 TO TABKEYL OF W-PETB01I
                 MOVE 'INVALID TABLEKEY' TO ERRMSGO OF W-PETB01O
              END-IF
              SET SW-INPUT-ERROR TO TRUE
           END-IF
           .
       R210-CHECK-INPUT-END.
           EXIT.

       R310-PROCESS-BMS SECTION.
           IF TABIDL OF PETB01I NOT = 0
           OR TABIDF OF PETB01I > X'80'
              MOVE TABIDL OF PETB01I TO TABIDL OF W-PETB01I
              MOVE TABIDF OF PETB01I TO TABIDF OF W-PETB01I
              MOVE FUNCTION UPPER-CASE(TABIDI OF PETB01I) TO
                   TABIDI OF W-PETB01I
           END-IF

           IF TABKEYL OF PETB01I NOT = 0
           OR TABKEYF OF PETB01I > X'80'
              MOVE TABKEYL OF PETB01I TO TABKEYL OF W-PETB01I
              MOVE TABKEYF OF PETB01I TO TABKEYF OF W-PETB01I
              MOVE FUNCTION UPPER-CASE(TABKEYI OF PETB01I) TO
                   TABKEYI OF W-PETB01I
           END-IF

           IF TABVAL1L OF PETB01I NOT = 0
           OR TABVAL1F OF PETB01I > X'80'
              MOVE TABVAL1L OF PETB01I TO TABVAL1L OF W-PETB01I
              MOVE TABVAL1F OF PETB01I TO TABVAL1F OF W-PETB01I
              MOVE TABVAL1I OF PETB01I TO TABVAL1I OF W-PETB01I
           END-IF

           IF TABVAL2L OF PETB01I NOT = 0
           OR TABVAL2F OF PETB01I > X'80'
              MOVE TABVAL2L OF PETB01I TO TABVAL2L OF W-PETB01I
              MOVE TABVAL2F OF PETB01I TO TABVAL2F OF W-PETB01I
              MOVE TABVAL2I OF PETB01I TO TABVAL2I OF W-PETB01I
           END-IF

           IF TABVAL3L OF PETB01I NOT = 0
           OR TABVAL3F OF PETB01I > X'80'
              MOVE TABVAL3L OF PETB01I TO TABVAL3L OF W-PETB01I
              MOVE TABVAL3F OF PETB01I TO TABVAL3F OF W-PETB01I
              MOVE TABVAL3I OF PETB01I TO TABVAL3I OF W-PETB01I
           END-IF

           IF TABVAL4L OF PETB01I NOT = 0
           OR TABVAL4F OF PETB01I > X'80'
              MOVE TABVAL4L OF PETB01I TO TABVAL4L OF W-PETB01I
              MOVE TABVAL4F OF PETB01I TO TABVAL4F OF W-PETB01I
              MOVE TABVAL4I OF PETB01I TO TABVAL4I OF W-PETB01I
           END-IF

           IF ACTIONL OF PETB01I NOT = 0
           OR ACTIONF OF PETB01I > X'80'
              MOVE ACTIONL OF PETB01I TO ACTIONL OF W-PETB01I
              MOVE ACTIONF OF PETB01I TO ACTIONF OF W-PETB01I
              MOVE FUNCTION UPPER-CASE(ACTIONI OF PETB01I) TO
                   ACTIONI OF W-PETB01I
           END-IF

           SET W-IE-POINTER TO ADDRESS OF TABIDL OF W-PETB01I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF TABKEYL OF W-PETB01I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF TABVAL1L OF W-PETB01I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF TABVAL2L OF W-PETB01I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF TABVAL3L OF W-PETB01I
           PERFORM R800-INPUT-EDIT

           SET W-IE-POINTER TO ADDRESS OF TABVAL4L OF W-PETB01I
           PERFORM R800-INPUT-EDIT
           .
       R310-PROCESS-BMS-END.
           EXIT.

       R320-PERFORM-ACTION SECTION.
           INITIALIZE W-LPETM001

           MOVE FUNCTION NATIONAL-OF(ACTIONI OF W-PETB01I) TO
                OPCODE OF W-LPETM001
           MOVE FUNCTION NATIONAL-OF(TABIDI OF W-PETB01I) TO
                TABLEID OF W-LPETM001
           MOVE FUNCTION NATIONAL-OF(TABKEYI OF W-PETB01I) TO
                TABKEY OF W-LPETM001
           
           IF  (OPCODE OF W-LPETM001 = N'C'
           OR   OPCODE OF W-LPETM001 = N'U')
           AND  TABVAL1L OF W-PETB01I NOT = 0
              MOVE TABVAL1L OF W-PETB01I TO TABVALUE-LEN OF W-LPETM001
              MOVE FUNCTION NATIONAL-OF(TABVAL1I OF W-PETB01I) TO
                   TABVALUE-TEXT OF W-LPETM001
           END-IF

           MOVE 'PETM001' TO W-PGMNAME

           CALL W-PGMNAME USING W-LPETM001

           MOVE FUNCTION DISPLAY-OF(INFOMESSAGE OF W-LPETM001) TO
                ERRMSGO OF W-PETB01O
           
           IF  RETURNCODE OF W-LPETM001 = N'00'
              IF OPCODE OF W-LPETM001 NOT = N'D'
                 MOVE FUNCTION DISPLAY-OF(TABLEID OF W-LPETM001) TO
                      TABIDI OF W-PETB01I
                 MOVE FUNCTION DISPLAY-OF(TABKEY OF W-LPETM001) TO
                      TABKEYI OF W-PETB01I
                 MOVE FUNCTION DISPLAY-OF(TABVALUE-TEXT OF W-LPETM001(1:
                         TABVALUE-LEN OF W-LPETM001)) TO
                      TABVAL1I OF W-PETB01I
                 MOVE FUNCTION DISPLAY-OF(CREATEDBY OF W-LPETM001) TO
                      CREBYI OF W-PETB01I
                 MOVE FUNCTION DISPLAY-OF(CREATEDDATE OF W-LPETM001) TO
                      CREDATEI OF W-PETB01I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDBY OF W-LPETM001) TO
                      UPDBYI OF W-PETB01I
                 MOVE FUNCTION DISPLAY-OF(UPDATEDDATE OF W-LPETM001) TO
                      UPDDATEI OF W-PETB01I
              ELSE
                 MOVE LOW-VALUES TO TABIDI   OF W-PETB01I
                 MOVE 0          TO TABIDL   OF W-PETB01I
                 MOVE LOW-VALUES TO TABKEYI  OF W-PETB01I 
                 MOVE 0          TO TABKEYL  OF W-PETB01I
                 MOVE LOW-VALUES TO TABVAL1I OF W-PETB01I
                 MOVE 0          TO TABVAL1L OF W-PETB01I
                 MOVE LOW-VALUES TO TABVAL2I OF W-PETB01I
                 MOVE 0          TO TABVAL2L OF W-PETB01I
                 MOVE LOW-VALUES TO TABVAL3I OF W-PETB01I
                 MOVE 0          TO TABVAL3L OF W-PETB01I
                 MOVE LOW-VALUES TO TABVAL4I OF W-PETB01I
                 MOVE 0          TO TABVAL4L OF W-PETB01I
                 MOVE LOW-VALUES TO CREBYI   OF W-PETB01I
                 MOVE 0          TO CREBYL   OF W-PETB01I
                 MOVE LOW-VALUES TO CREDATEI OF W-PETB01I
                 MOVE 0          TO CREDATEL OF W-PETB01I
                 MOVE LOW-VALUES TO UPDBYI   OF W-PETB01I
                 MOVE 0          TO UPDBYL   OF W-PETB01I
                 MOVE LOW-VALUES TO UPDDATEI OF W-PETB01I
                 MOVE 0          TO UPDDATEL OF W-PETB01I
              END-IF

              MOVE LOW-VALUES TO ACTIONI OF W-PETB01I
              MOVE 0          TO ACTIONL OF W-PETB01I
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

       END PROGRAM PETC902.