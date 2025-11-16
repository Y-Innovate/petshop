         PRINT ON,NOGEN
PETB00   DFHMSD TYPE=MAP,MODE=INOUT,LANG=COBOL
         TITLE 'DEMO APP PRIMARY OPTION MENU'
PETB00   DFHMDI SIZE=(24,80),CTRL=(HONEOM,FREEKB),                     *
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
         DFHMDF POS=(2,30),LENGTH=19,INITIAL='PRIMARY OPTION MENU',    *
               ATTRB=(PROT,BRT)
NOW      DFHMDF POS=(2,72),LENGTH=8,INITIAL='HH:MM:SS',                *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(3,1),LENGTH=1,INITIAL=' ',                        *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(5,26),LENGTH=12,INITIAL='1. REFTABLES',           *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(6,26),LENGTH=9,INITIAL='2. STORES',               *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(7,26),LENGTH=12,INITIAL='3. SUPPLIERS',           *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(8,26),LENGTH=11,INITIAL='4. PRODUCTS',            *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(9,26),LENGTH=12,INITIAL='5. INVENTORY',           *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(10,26),LENGTH=10,INITIAL='6. ANIMALS',            *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(11,26),LENGTH=23,INITIAL='7. PRICES AND DISCOUNTS'*
               ,ATTRB=(PROT,BRT)
         DFHMDF POS=(13,26),LENGTH=14,INITIAL='Make a choice:',        *
               ATTRB=(PROT,BRT)
CHOICE   DFHMDF POS=(13,41),LENGTH=1,INITIAL='_',                      *
               ATTRB=(UNPROT,NORM,IC)
         DFHMDF POS=(13,43),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
ERRMSG   DFHMDF POS=(22,1),LENGTH=78,INITIAL=' ',                      *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(23,1),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(24,1),LENGTH=10,INITIAL='PF3 = Exit',             *
               ATTRB=(PROT,BRT)
         DFHMSD TYPE=FINAL
         END