       IDENTIFICATION DIVISION.
       PROGRAM-ID. PETC900.
      *===============================================================*
      * This program is a router program for the PET store CICS       *
      * emergency transaction (to manipulate the database records).   *
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
           05  CONST-CONT-NAME  PIC X(16) VALUE 'LPETC900'.
           05  CONST-CHNL-NAME  PIC X(16) VALUE 'PT90-CHANNEL'.

           05  W-RETURNCODE     PIC X(2)  VALUE '00'.
           05  W-PGMNAME        PIC X(8)  VALUE SPACES.
           
           05  W-EIBRESP        PIC 9(8).
           05  W-EIBRESP2       PIC 9(8).

           05  MSGSTR.
               10  Vstring-length      PIC S9(4) BINARY.
               10  Vstring-text.
                   15  Vstring-char    PIC X
                               OCCURS 0 TO 256 TIMES
                               DEPENDING ON Vstring-length
                                  of MSGSTR.
           05  MSGDEST                 PIC S9(9) BINARY.
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

       LINKAGE SECTION.

       PROCEDURE DIVISION.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM WITH TEST AFTER
           UNTIL W-RETURNCODE NOT = '00'
           OR CURRENT-SCREEN OF W-LPETC900 = NEXT-SCREEN OF W-LPETC900
              EVALUATE NEXT-SCREEN OF W-LPETC900 
              WHEN '00'
                 MOVE 'PETC901' TO W-PGMNAME
              WHEN '01'
                 MOVE 'PETC902' TO W-PGMNAME
              WHEN '02'
                 MOVE 'PETC903' TO W-PGMNAME
              WHEN '03'
                 MOVE 'PETC904' TO W-PGMNAME
              WHEN '04'
                 MOVE 'PETC905' TO W-PGMNAME
              WHEN '05'
                 MOVE 'PETC906' TO W-PGMNAME
              WHEN '06'
                 MOVE 'PETC907' TO W-PGMNAME
              WHEN '07'
                 MOVE 'PETC908' TO W-PGMNAME
              WHEN OTHER
                 MOVE '01' TO W-RETURNCODE
              END-EVALUATE

              IF W-RETURNCODE = '00'
                 PERFORM R100-LINK
              END-IF
           END-PERFORM

           PERFORM R009-FINISH
           .
       MAIN-END.
           GOBACK.

      *===============================================================*
      * R001-INIT: Program initialisations                            *
      *===============================================================*
       R001-INIT SECTION.
           PERFORM R910-GET-CONTAINER
           .
       R001-INIT-END. 
           EXIT.

      *===============================================================*
      * R009-FINISH: Program finalisations                            *
      *===============================================================*
       R009-FINISH SECTION.
           PERFORM R920-PUT-CONTAINER

           IF W-RETURNCODE = '00'
              EXEC CICS
                 RETURN TRANSID(EIBTRNID OF DFHEIBLK)
                        CHANNEL(CONST-CHNL-NAME)
              END-EXEC
           ELSE
              EXEC CICS
                 RETURN
              END-EXEC
           END-IF
           .
       R009-FINISH-END. 
           EXIT.

       R100-LINK SECTION.
           PERFORM R920-PUT-CONTAINER

           EXEC CICS
              LINK PROGRAM(W-PGMNAME)
                   CHANNEL(CONST-CHNL-NAME)
                   NOHANDLE
           END-EXEC
           
           IF EIBRESP = DFHRESP(NORMAL)
              PERFORM R910-GET-CONTAINER
           ELSE
              MOVE '08' TO W-RETURNCODE

              MOVE EIBRESP  TO W-EIBRESP
              MOVE EIBRESP2 TO W-EIBRESP2
              MOVE 1 TO Vstring-length
              STRING 'LINK ERROR ' W-PGMNAME ' ' W-EIBRESP ' '
                     W-EIBRESP2
                     DELIMITED BY SIZE
                INTO Vstring-text
                WITH POINTER Vstring-length
              SUBTRACT 1 FROM Vstring-length
              CALL 'CEEMOUT' USING MSGSTR, MSGDEST, FC
           END-IF
           .
       R100-LINK-END.
           EXIT.
       
       R910-GET-CONTAINER SECTION.
           EXEC CICS
              GET CONTAINER(CONST-CONT-NAME)
                  CHANNEL(CONST-CHNL-NAME)
                  INTO(W-LPETC900)
                  NOHANDLE
           END-EXEC

           IF EIBRESP = DFHRESP(NORMAL)
              CONTINUE
           ELSE
              IF EIBRESP = DFHRESP(CHANNELERR)
              OR EIBRESP = DFHRESP(CONTAINERERR)
                 MOVE LOW-VALUES TO CURRENT-SCREEN OF W-LPETC900
                 MOVE '00'       TO NEXT-SCREEN    OF W-LPETC900
              ELSE
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
           EXEC CICS
              PUT CONTAINER(CONST-CONT-NAME)
                  CHANNEL(CONST-CHNL-NAME)
                  FROM(W-LPETC900)
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
       R920-PUT-CONTAINER-END.
           EXIT.

       END PROGRAM PETC900.