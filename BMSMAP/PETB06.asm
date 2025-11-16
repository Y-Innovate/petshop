         PRINT ON,NOGEN
PETB06   DFHMSD TYPE=MAP,MODE=INOUT,LANG=COBOL
         TITLE 'PET STORE APP ANIMALS'
PETB06   DFHMDI SIZE=(24,80),CTRL=(HONEOM,FREEKB),                     *
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
         DFHMDF POS=(2,36),LENGTH=7,INITIAL='ANIMALS',                 *
               ATTRB=(PROT,BRT)
NOW      DFHMDF POS=(2,72),LENGTH=8,INITIAL='HH:MM:SS',                *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(3,1),LENGTH=1,INITIAL=' ',                        *
               ATTRB=(PROT,BRT)
         DFHMDF POS=(5,3),LENGTH=13,INITIAL='ANIMALID:    ',           *
               ATTRB=(PROT,BRT)
ANIMLID  DFHMDF POS=(5,17),LENGTH=8,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(5,26),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(6,3),LENGTH=13,INITIAL='STOREID:     ',           *
               ATTRB=(PROT,BRT)
STOREID  DFHMDF POS=(6,17),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM,IC)
         DFHMDF POS=(6,26),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(7,3),LENGTH=13,INITIAL='ANIMALTYPE:  ',           *
               ATTRB=(PROT,BRT)
ANIMLTP  DFHMDF POS=(7,17),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(7,26),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(8,3),LENGTH=13,INITIAL='ANIMALRACE:  ',           *
               ATTRB=(PROT,BRT)
ANIMLRC  DFHMDF POS=(8,17),LENGTH=8,INITIAL='________',                *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(8,26),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(9,3),LENGTH=13,INITIAL='ANIMALNAME:  ',           *
               ATTRB=(PROT,BRT)
ANIMLNM  DFHMDF POS=(9,17),LENGTH=60,INITIAL='_________________________*
               ___________________________________',                   *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(9,78),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(10,3),LENGTH=13,INITIAL='ANIMALGENDER:',          *
               ATTRB=(PROT,BRT)
ANIMLGE  DFHMDF POS=(10,17),LENGTH=1,INITIAL='_',                      *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(10,19),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(11,3),LENGTH=13,INITIAL='ANIMALAGE:   ',          *
               ATTRB=(PROT,BRT)
ANIMLAG  DFHMDF POS=(11,17),LENGTH=8,INITIAL='________',               *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(11,26),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(12,3),LENGTH=13,INITIAL='ANIMALCOUNT: ',          *
               ATTRB=(PROT,BRT)
ANIMLCO  DFHMDF POS=(12,17),LENGTH=8,INITIAL='________',               *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(12,26),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
         DFHMDF POS=(13,3),LENGTH=12,INITIAL='CRE BY:     ',           *
               ATTRB=(PROT,BRT)
CREBY    DFHMDF POS=(13,16),LENGTH=8,INITIAL='        ',               *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(14,3),LENGTH=12,INITIAL='CRE DATE:   ',           *
               ATTRB=(PROT,BRT)
CREDATE  DFHMDF POS=(14,16),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(15,3),LENGTH=12,INITIAL='UPD BY:     ',           *
               ATTRB=(PROT,BRT)
UPDBY    DFHMDF POS=(15,16),LENGTH=8,INITIAL='        ',               *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(16,3),LENGTH=12,INITIAL='UPD DATE:   ',           *
               ATTRB=(PROT,BRT)
UPDDATE  DFHMDF POS=(16,16),LENGTH=19,INITIAL='                   ',   *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(18,3),LENGTH=12,INITIAL='Action:     ',           *
               ATTRB=(PROT,BRT)
ACTION   DFHMDF POS=(18,16),LENGTH=1,INITIAL='_',                      *
               ATTRB=(UNPROT,NORM)
         DFHMDF POS=(18,18),LENGTH=1,INITIAL=' ',                      *
               ATTRB=(PROT,BRT,ASKIP)
ERRMSG   DFHMDF POS=(22,1),LENGTH=78,INITIAL=' ',                      *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(23,1),LENGTH=1,INITIAL=' ',                       *
               ATTRB=(PROT,NORM)
         DFHMDF POS=(24,1),LENGTH=10,INITIAL='PF3 = Exit',             *
               ATTRB=(PROT,BRT)
         DFHMSD TYPE=FINAL
         END