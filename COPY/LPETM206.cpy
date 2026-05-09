          05 LPETM206.
             10 RETURNCODE                 PIC N(02).
             10 REASONCODE                 PIC N(02).
             10 INFOMESSAGE                PIC N(72).
             10 STOREID-FILTER             PIC S9(9) USAGE COMP-5.
             10 ANIMALTYPE-FILTER          PIC N(08).
             10 ANIMALRACE-FILTER          PIC N(08).
             10 ANIMALID-SINCE             PIC S9(9) USAGE COMP-5.
             10 ANIMAL-ENTRY-COUNT         PIC S9(4) USAGE COMP-5.
             10 ANIMAL-ENTRY OCCURS 20 TIMES
                  DEPENDING ON ANIMAL-ENTRY-COUNT.
                15 ANIMALID                PIC S9(9) USAGE COMP-5.
                15 STOREID                 PIC S9(9) USAGE COMP-5.
                15 ANIMALTYPE              PIC N(08).
                15 ANIMALRACE              PIC N(08).
                15 ANIMALNAME.
                   20 ANIMALNAME-LEN       PIC S9(4) USAGE COMP-5.
                   20 ANIMALNAME-TEXT      PIC N(256).
                15 ANIMALGENDER            PIC N.
                15 ANIMALAGE               PIC S9(9) USAGE COMP-5.
                15 ANIMALCOUNT             PIC S9(9) USAGE COMP-5.
                15 CREATEDBY               PIC N(08).
                15 CREATEDDATE             PIC N(26).
                15 UPDATEDBY               PIC N(08).
                15 UPDATEDDATE             PIC N(26).