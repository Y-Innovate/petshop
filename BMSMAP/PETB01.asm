         PRINT ON,NOGEN
PETB01   DFHMSD TYPE=MAP,MODE=INOUT,LANG=COBOL
         TITLE 'PET STORE APP REFTABLES'
PETB01   DFHMDI SIZE=(24,80),CTRL=(HONEOM,FREEKB),                     *
               COLUMN=SAME,LINE=NEXT,DATA=FIELD,CURSLOC=YES,           *
               TIOAPFX=YES,JUSTIFY=(LEFT)
APPLID   DFHMDF POS=(1,1),LENGTH=8,                                    *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(1,10),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(1,25),LENGTH=29,INITIAL='Y-Innovate demo pet store*
                app',ATTRB=(PROT,BRT)
TODAY    DFHMDF POS=(1,70),LENGTH=10,                                  *
               ATTRB=(PROT,NORM)
TRNID    DFHMDF POS=(2,1),LENGTH=4,                                    *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(2,6),LENGTH=1,INITIAL='-',                        *
               ATTRB=(PROT,BRT)
TRMID    DFHMDF POS=(2,8),LENGTH=4,                                    *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(2,13),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(2,34),LENGTH=9,INITIAL='REFTABLES',               *
               ATTRB=(PROT,BRT)
NOW      DFHMDF POS=(2,72),LENGTH=8,INITIAL='HH:MM:SS',                *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(3,1),LENGTH=1,INITIAL=' ',                        *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(5,3),LENGTH=9,INITIAL='TABLEID: ',                *
               ATTRB=(PROT,BRT)
TABID    DFHMDF POS=(5,13),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM,IC)
         DFHMDF POS=(5,22),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(6,3),LENGTH=9,INITIAL='TABLEKEY:',                *
               ATTRB=(PROT,BRT)
TABKEY   DFHMDF POS=(6,13),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(6,22),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(7,3),LENGTH=9,INITIAL='TABVALUE:',                *
               ATTRB=(PROT,BRT)
TABVAL1  DFHMDF POS=(7,13),LENGTH=64,INITIAL='_________________________*
               _______________________________________',               *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(7,78),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
TABVAL2  DFHMDF POS=(8,13),LENGTH=64,INITIAL='_________________________*
               _______________________________________',               *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(8,78),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
TABVAL3  DFHMDF POS=(9,13),LENGTH=64,INITIAL='_________________________*
               _______________________________________',               *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(9,78),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
TABVAL4  DFHMDF POS=(10,13),LENGTH=63,INITIAL='________________________*
               _______________________________________',               *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(10,78),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(11,3),LENGTH=9,INITIAL='CRE BY:  ',               *
               ATTRB=(PROT,BRT)
CREBY    DFHMDF POS=(11,13),LENGTH=8,INITIAL='        ',               *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(12,3),LENGTH=9,INITIAL='CRE DATE:',               *
               ATTRB=(PROT,BRT)
CREDATE  DFHMDF POS=(12,13),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(13,3),LENGTH=9,INITIAL='UPD BY:  ',               *
               ATTRB=(PROT,BRT)
UPDBY    DFHMDF POS=(13,13),LENGTH=8,INITIAL='        ',               *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(14,3),LENGTH=9,INITIAL='UPD DATE:',               *
               ATTRB=(PROT,BRT)
UPDDATE  DFHMDF POS=(14,13),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(16,3),LENGTH=9,INITIAL='Action:  ',               *
               ATTRB=(PROT,BRT)
ACTION   DFHMDF POS=(16,13),LENGTH=1,INITIAL='_',                      *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(16,15),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
ERRMSG   DFHMDF POS=(22,1),LENGTH=78,INITIAL=' ',                      *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(23,1),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(24,1),LENGTH=10,INITIAL='PF3 = Exit',             *
               ATTRB=(PROT,BRT)
         DFHMSD TYPE=FINAL
         END