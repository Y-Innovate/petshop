         PRINT ON,NOGEN
PETB04   DFHMSD TYPE=MAP,MODE=INOUT,LANG=COBOL
         TITLE 'PET STORE APP PRODUCTS'
PETB04   DFHMDI SIZE=(24,80),CTRL=(HONEOM,FREEKB),                     *
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
         DFHMDF POS=(2,36),LENGTH=8,INITIAL='PRODUCTS',                *
               ATTRB=(PROT,BRT)
NOW      DFHMDF POS=(2,72),LENGTH=8,INITIAL='HH:MM:SS',                *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(3,1),LENGTH=1,INITIAL=' ',                        *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(5,3),LENGTH=14,INITIAL='PRODUCTID:    ',          *
               ATTRB=(PROT,BRT)
PRODID   DFHMDF POS=(5,18),LENGTH=8,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(5,27),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(6,3),LENGTH=14,INITIAL='PRODUCTCODE:  ',          *
               ATTRB=(PROT,BRT)
PRODCD   DFHMDF POS=(6,18),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM,IC)
         DFHMDF POS=(6,27),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(7,3),LENGTH=14,INITIAL='PRODUCTSTATUS:',          *
               ATTRB=(PROT,BRT)
PRODST   DFHMDF POS=(7,18),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(7,27),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(8,3),LENGTH=14,INITIAL='PRODUCTNAME:  ',          *
               ATTRB=(PROT,BRT)
PRODNM   DFHMDF POS=(8,18),LENGTH=60,INITIAL='_________________________*
               ___________________________________',                   *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(8,79),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(9,3),LENGTH=14,INITIAL='GROUPCODE:    ',          *
               ATTRB=(PROT,BRT)
GROUPCD  DFHMDF POS=(9,18),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(9,27),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(10,3),LENGTH=14,INITIAL='SUPPLIERID:   ',         *
               ATTRB=(PROT,BRT)
SUPPLID  DFHMDF POS=(10,18),LENGTH=8,INITIAL='________',               *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(10,27),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(UNPROT,BRT,ASKIP)
         DFHMDF POS=(11,3),LENGTH=14,INITIAL='CRE BY:       ',         *
               ATTRB=(PROT,BRT)
CREBY    DFHMDF POS=(11,18),LENGTH=8,INITIAL='        ',               *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(12,3),LENGTH=14,INITIAL='CRE DATE:     ',         *
               ATTRB=(PROT,BRT)
CREDATE  DFHMDF POS=(12,18),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(13,3),LENGTH=14,INITIAL='UPD BY:       ',         *
               ATTRB=(PROT,BRT)
UPDBY    DFHMDF POS=(13,18),LENGTH=8,INITIAL='        ',               *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(14,3),LENGTH=14,INITIAL='UPD DATE:     ',         *
               ATTRB=(PROT,BRT)
UPDDATE  DFHMDF POS=(14,18),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(16,3),LENGTH=14,INITIAL='Action:       ',         *
               ATTRB=(PROT,BRT)
ACTION   DFHMDF POS=(16,18),LENGTH=1,INITIAL='_',                      *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(16,20),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
ERRMSG   DFHMDF POS=(22,1),LENGTH=78,INITIAL=' ',                      *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(23,1),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(24,1),LENGTH=10,INITIAL='PF3 = Exit',             *
               ATTRB=(PROT,BRT)
         DFHMSD TYPE=FINAL
         END
