          05 LPETM010.
             10 OPCODE             PIC N.
             10 RETURNCODE         PIC N(02).
             10 REASONCODE         PIC N(02).
             10 INFOMESSAGE        PIC N(72).
             10 ORDERID            PIC S9(9) USAGE COMP-5.
             10 STOREID            PIC S9(9) USAGE COMP-5.
             10 PURCHASEID         PIC S9(9) USAGE COMP-5.
             10 ORDERDATE          PIC N(26).
             10 PRODUCTID          PIC S9(9) USAGE COMP-5.
             10 ANIMALID           PIC S9(9) USAGE COMP-5.
             10 ORDERCOUNT         PIC S9(9) USAGE COMP-5.
             10 TYPEOFDISCOUNT     PIC N(01).
             10 PRICE              PIC S9(7)V9(2) USAGE COMP-3.
             10 DISCOUNT           PIC S9(7)V9(2) USAGE COMP-5.
             10 CREATEDBY          PIC N(08).
             10 CREATEDDATE        PIC N(26).
             10 UPDATEDBY          PIC N(08).
             10 UPDATEDDATE        PIC N(26).