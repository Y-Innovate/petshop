         PRINT ON,NOGEN
PETB03   DFHMSD TYPE=MAP,MODE=INOUT,LANG=COBOL
         TITLE 'PET STORE APP SUPPLIERS'
PETB03   DFHMDI SIZE=(24,80),CTRL=(HONEOM,FREEKB),                     *
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
         DFHMDF POS=(2,35),LENGTH=9,INITIAL='SUPPLIERS',               *
               ATTRB=(PROT,BRT)
NOW      DFHMDF POS=(2,72),LENGTH=8,INITIAL='HH:MM:SS',                *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(3,1),LENGTH=1,INITIAL=' ',                        *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(5,3),LENGTH=15,INITIAL='SUPPLIERID:    ',         *
               ATTRB=(PROT,BRT)
SUPPLID  DFHMDF POS=(5,19),LENGTH=8,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(5,28),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(6,3),LENGTH=15,INITIAL='SUPPLIERCODE:  ',         *
               ATTRB=(PROT,BRT)
SUPPLCD  DFHMDF POS=(6,19),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM,IC)
         DFHMDF POS=(6,28),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(7,3),LENGTH=15,INITIAL='SUPPLIERSTATUS:',         *
               ATTRB=(PROT,BRT)
SUPPLST  DFHMDF POS=(7,19),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(7,28),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(8,3),LENGTH=15,INITIAL='SUPPLIERNAME:  ',         *
               ATTRB=(PROT,BRT)
SUPPLNM  DFHMDF POS=(8,19),LENGTH=58,INITIAL='_________________________*
               _________________________________',                     *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(8,77),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(9,3),LENGTH=15,INITIAL='CRE BY:        ',         *
               ATTRB=(PROT,BRT)
CREBY    DFHMDF POS=(9,19),LENGTH=8,INITIAL='        ',                *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(10,3),LENGTH=15,INITIAL='CRE DATE:      ',        *
               ATTRB=(PROT,BRT)
CREDATE  DFHMDF POS=(10,19),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(11,3),LENGTH=15,INITIAL='UPD BY:        ',        *
               ATTRB=(PROT,BRT)
UPDBY    DFHMDF POS=(11,19),LENGTH=8,INITIAL='        ',               *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(12,3),LENGTH=15,INITIAL='UPD DATE:      ',        *
               ATTRB=(PROT,BRT)
UPDDATE  DFHMDF POS=(12,19),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(14,3),LENGTH=15,INITIAL='Action:        ',        *
               ATTRB=(PROT,BRT)
ACTION   DFHMDF POS=(14,19),LENGTH=1,INITIAL='_',                      *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(14,21),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
ERRMSG   DFHMDF POS=(22,1),LENGTH=78,INITIAL=' ',                      *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(23,1),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(24,1),LENGTH=10,INITIAL='PF3 = Exit',             *
               ATTRB=(PROT,BRT)
         DFHMSD TYPE=FINAL
         END