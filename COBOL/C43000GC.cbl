       IDENTIFICATION DIVISION.
       PROGRAM-ID. C43000GC.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WORK.
           05  W-RETURNCODE          PIC X(2)  VALUE '00'.
           05  W-PGMNAME             PIC X(8)  VALUE SPACES.
           05  W-EIBRESP             PIC 9(8).
           05  W-EIBRESP2            PIC 9(8).

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

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           COPY L43000GC.

       PROCEDURE DIVISION USING DFHCOMMAREA.
       MAIN SECTION.
           PERFORM R001-INIT

           PERFORM R005-DO-STUFF

           PERFORM R009-FINISH
           .

      *===============================================================*
      * R001-INIT: Program initialisations                            *
      *===============================================================*
       R001-INIT SECTION.
           DISPLAY 'C43000GC INIT'
           .
       R001-INIT-END.
           EXIT.

      *===============================================================*
      * R005-DO-STUFF                                                 *
      *===============================================================*
       R005-DO-STUFF SECTION.
           DISPLAY 'C43000GC DO-STUFF'
           .
       R005-DO-STUFF-END.
           EXIT.

      *===============================================================*
      * R009-FINISH: Program finalisations                            *
      *===============================================================*
       R009-FINISH SECTION.
           EXEC CICS
              RETURN
           END-EXEC
           .
       END PROGRAM C43000GC.
