*---------------------------------------------------------------------*
* Program    : PETA990                                                *
* Description: Y-Innovate Pet store demo program to determine CICS or *
*              non-CICS environment and then determine the user.      *
*---------------------------------------------------------------------*
         TITLE 'Determine runtime env and userid'
*
         COPY  ASMMSP
*
DFHEIBR  EQU   R9 
* 
         COPY  DFHEIBLK
*
PETA990  CEEENTRY AUTO=WORKDSA_SIZ,MAIN=NO,BASE=R11
*
         USING WORKDSA,R13
*
         ST    R1,PARML_PTR
*
         CALL  CEEGTST,(=A(0),=A(WORKSIZE),WORKAREA_PTR,FC0),VL,       X
               MF=(E,WORK)
*
         IF (CLC,FC0(8),NE,=XL8'0000000000000000') THEN
            L     R2,=A(12)
            B     PETA990_RET_IMMED
         ENDIF
*
         L     R10,WORKAREA_PTR
         USING WORKAREA,R10
*
         MVC   RETCODE,=A(0)
*
         L     R8,PARML_PTR
         L     R8,0(,R8)
         USING LPETA990,R8
*
         MVC   LPETA990_RETURNCODE,=CU'00'
         MVC   LPETA990_REASONCODE,=CU'00'
         XR    R0,R0
         XR    R1,R1
         LA    R2,LPETA990_INFOMESSAGE
         LA    R3,L'LPETA990_INFOMESSAGE+L'LPETA990_USERID
         MVCLU R2,R0,X'020'
*
         XR    R7,R7
         L     R7,548(,R7)             * Point to ASCB
         LR    R6,R7
         L     R7,ASCBXTCB-ASCB(,R7)   * Point to TCB
         L     R7,TCBJSCB-TCB(,R7)     * Point to JSCB
         IF (CLC,JSCBPGMN-IEZJSCB(8,R7),EQ,=CL8'DFHSIP') THEN
            EXEC CICS ADDRESS EIB(DFHEIBR)
            EXEC CICS ASSIGN USERID(WUSERID)
         ELSE
            L     R7,ASCBASSB-ASCB(,R6) * Point to ASSB
            L     R7,ASSBJSAB-ASSB(,R7) * Point to JSAB
            MVC   WUSERID,JSABUSID-JSAB(R7)
         ENDIF
*
         XR    R0,R0
         LA    R1,TROTUTF
         LA    R2,LPETA990_USERID
         LA    R3,8
         LA    R4,WUSERID
         TROT  R2,R4
*
         DROP  R8
*
PETA990_RET EQU   *
         L     R2,RETCODE
*
         CALL  CEEFRST,(WORKAREA_PTR,FC0),VL,MF=(E,WORK)
*
PETA990_RET_IMMED EQU   *
         CEETERM RC=(R2)
*
         DROP  R10,R13
*
* End of code
*
         LTORG
*
         DS    0D 
TROTUTF  DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'00200020002000200020002000200020'
         DC    X'002000200020002E003C0028002B007C'
         DC    X'00260020002000200020002000200020'
         DC    X'0020002000210024002A0029003B00AC'
         DC    X'002D002F002000200020002000200020'
         DC    X'0020002000A6002C0025005F003E003F'
         DC    X'00200020002000200020002000200020'
         DC    X'00200060003A002300400027003D0022'
         DC    X'00200061006200630064006500660067'
         DC    X'006800690020002000200020002000B1'
         DC    X'0020006A006B006C006D006E006F0070'
         DC    X'00710072002000200020002000200020'
         DC    X'0020007E007300740075007600770078'
         DC    X'0079007A002000200020002000200020'
         DC    X'005E0020002000200020002000200020'
         DC    X'00200020005B005D0020002000200020'
         DC    X'007B0041004200430044004500460047'
         DC    X'00480049002000200020002000200020'
         DC    X'007D004A004B004C004D004E004F0050'
         DC    X'00510052002000200020002000200020'
         DC    X'005C0020005300540055005600570058'
         DC    X'0059005A002000200020002000200020'
         DC    X'00300031003200330034003500360037'
         DC    X'00380039002000200020002000200020'
*
PPA                         CEEPPA
*
                            CEECAA
*
                            CEEDSA
*
WORKDSA                     DSECT
*
                            ORG   *+CEEDSASZ
*
PARML_PTR                   DS    A
WORKAREA_PTR                DS    A
FC0                         DS    3A
WORK                        DS    4A
*
WORKDSA_SIZ                 EQU   *-WORKDSA
*
WORKAREA                    DSECT
*
RETCODE                     DS    F
WUSERID                     DS    CL8
*
                            DS    0F
DFHEIPL                     DS    13F
                            DS    51F
DFHEITP1                    DS    F
*
WORKSIZE                    EQU   *-WORKAREA
*
LPETA990                    DSECT
*
LPETA990_RETURNCODE         DS    CUL4
LPETA990_REASONCODE         DS    CUL4
LPETA990_INFOMESSAGE        DS    CUL144
LPETA990_USERID             DS    CUL16
*
LPETA990_SIZ                EQU   *-LPETA990
*
         PUSH  PRINT
         PRINT OFF
         IHAASCB DSECT=YES
         IKJTCB DSECT=YES
         IEZJSCB
         IHAASSB
         IAZJSAB
         POP   PRINT
*
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
*
         END   PETA990