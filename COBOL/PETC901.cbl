       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETC901.
      *===============================================================*
      * This program is a screen program for the PET store CICS       *
      * emergency transaction primary option menu.                    *
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
           05  C-CONT-NAME-B00       PIC X(16) VALUE 'BMS-PETB00'.
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

       COPY DFHAID.

       COPY PETB00.
       COPY PETB00 REPLACING ==PETB00I== BY ==W-PETB00I==
                             ==PETB00O== BY ==W-PETB00O==.

       LINKAGE SECTION.
       01  P-CHAR                    PIC X.

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
           MOVE LOW-VALUES TO PETB00I
           MOVE LOW-VALUES TO W-PETB00I

           MOVE C-CONT-NAME-900 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-LPETC900
           END-IF

           IF CURRENT-SCREEN OF W-LPETC900 = '00'
              SET SW-DO-INPUT-PROCESSING TO TRUE
           ELSE
              SET SW-SKIP-INPUT-PROCESSING TO TRUE
              MOVE '00' TO CURRENT-SCREEN OF W-LPETC900
           END-IF
           SET SW-DO-OUTPUT-PROCESSING TO TRUE

           MOVE C-CONT-NAME-B00 TO W-CONT-NAME

           PERFORM R910-GET-CONTAINER

           IF SW-CONT-FOUND
              SET ADDRESS OF P-CHAR TO W-CONT-POINTER
              MOVE P-CHAR(1:W-CONT-LENGTH) TO W-PETB00I

              IF SW-SKIP-INPUT-PROCESSING
                 MOVE '_' TO CHOICEI OF W-PETB00I
                 MOVE SPACES TO ERRMSGO OF W-PETB00O
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
              RECEIVE MAP('PETB00') MAPSET('PETB00')
                      INTO(PETB00I) NOHANDLE
           END-EXEC

           MOVE SPACES TO ERRMSGO OF W-PETB00O.

           IF EIBRESP = DFHRESP(NORMAL)
           OR EIBRESP = DFHRESP(MAPFAIL)
              EVALUATE EIBAID
              WHEN DFHENTER
                 PERFORM R210-CHECK-INPUT

                 IF SW-INPUT-OK
                    PERFORM R310-SWITCH-SCREEN
                 END-IF

              WHEN DFHPF3
                 MOVE '01' TO W-RETURNCODE
                 MOVE LOW-VALUES TO NEXT-SCREEN OF W-LPETC900

                 EXEC CICS 
                    SEND TEXT FROM(C-DONE) LENGTH(LENGTH OF C-DONE)
                         ERASE FREEKB NOHANDLE 
                 END-EXEC 
              END-EVALUATE
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'RECEIVE MAP ERROR PETB00 ' W-EIBRESP ' '
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

           MOVE W-APPLID         TO APPLIDO OF W-PETB00O
           STRING W-COBOL-DAY '-' W-COBOL-MONTH '-' W-COBOL-YEAR
                  DELIMITED BY SIZE
             INTO TODAYO OF W-PETB00O
           MOVE EIBTRNID         TO TRNIDO  OF W-PETB00O
           MOVE EIBTRMID         TO TRMIDO  OF W-PETB00O
           MOVE W-CURRDATE(12:8) TO NOWO    OF W-PETB00O

           IF SW-SKIP-INPUT-PROCESSING
              MOVE C-ATTR-UNPROT-MDT TO CHOICEF OF W-PETB00I
              MOVE -1 TO CHOICEL OF W-PETB00I
           END-IF

           MOVE W-PETB00I TO PETB00I

           EXEC CICS
              SEND MAP('PETB00') MAPSET('PETB00')
                   FROM(PETB00O) FREEKB ERASE CURSOR NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE C-CONT-NAME-B00 TO W-CONT-NAME
              MOVE LENGTH OF W-PETB00I TO W-CONT-LENGTH
              SET W-CONT-POINTER TO ADDRESS OF W-PETB00I

              PERFORM R920-PUT-CONTAINER
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'SEND MAP ERROR PETB00 ' W-EIBRESP ' '
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
           IF CHOICEL OF PETB00I NOT = 0
           OR CHOICEF OF PETB00I > X'80'
              MOVE CHOICEL OF PETB00I TO CHOICEL OF W-PETB00I
              MOVE CHOICEF OF PETB00I TO CHOICEF OF W-PETB00I
              MOVE CHOICEI OF PETB00I TO CHOICEI OF W-PETB00I
           END-IF

           SET SW-INPUT-OK TO TRUE

           IF  CHOICEL OF W-PETB00I = 0
           OR  CHOICEI OF W-PETB00I < '1'
           OR  CHOICEI OF W-PETB00I > '7'
              MOVE C-ATTR-UNPROT-BRT-MDT TO CHOICEF OF W-PETB00I
              MOVE -1 TO CHOICEL OF W-PETB00I
              MOVE 'INVALID CHOICE' TO ERRMSGO OF W-PETB00O
              SET SW-INPUT-ERROR TO TRUE
           END-IF
           .
       R210-CHECK-INPUT-END.
           EXIT.
       
       R310-SWITCH-SCREEN SECTION.
           EVALUATE CHOICEI OF W-PETB00I
           WHEN '1'
              MOVE '01' TO NEXT-SCREEN OF W-LPETC900
           WHEN '2'
              MOVE '02' TO NEXT-SCREEN OF W-LPETC900
           WHEN '3'
              MOVE '03' TO NEXT-SCREEN OF W-LPETC900
           WHEN '4'
              MOVE '04' TO NEXT-SCREEN OF W-LPETC900
           WHEN '5'
              MOVE '05' TO NEXT-SCREEN OF W-LPETC900
           WHEN '6'
              MOVE '06' TO NEXT-SCREEN OF W-LPETC900
           WHEN '7'
              MOVE '07' TO NEXT-SCREEN OF W-LPETC900
           END-EVALUATE

           SET SW-SKIP-OUTPUT-PROCESSING TO TRUE
           .
       R310-SWITCH-SCREEN-END.
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

       END PROGRAM PETC901.