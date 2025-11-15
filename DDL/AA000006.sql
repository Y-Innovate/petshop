-- Create suppliers table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create suppliers tablespace
   CREATE TABLESPACE {{SUPPLIERS_TBSNAME}}
                       IN {{DBNAME}}
                       USING STOGROUP {{STOGROUP}}
                       PRIQTY 40 SECQTY 40
                       ERASE  NO
                       FREEPAGE 0 PCTFREE 5 FOR UPDATE 0
                       GBPCACHE CHANGED
                       TRACKMOD YES
                       MAXPARTITIONS 254
                       LOGGED
                       DSSIZE 4 G
                       SEGSIZE 4
                       BUFFERPOOL BP2
                       LOCKSIZE ANY
                       LOCKMAX SYSTEM
                       CLOSE YES
                       COMPRESS NO
                       CCSID      UNICODE
                       DEFINE YES
                       MAXROWS 255
                       INSERT ALGORITHM 0;

-- Create suppliers table
   CREATE TABLE {{SCHEMA}}.{{SUPPLIERS_TBNAME}}
      (SUPPLIERID  INTEGER NOT NULL GENERATED ALWAYS
          AS IDENTITY 
             (START WITH 1, INCREMENT BY 1, CACHE 20, NO CYCLE,
              NO ORDER, MAXVALUE 2147483647, MINVALUE 1),
       SUPPLIERCODE   GRAPHIC(8) NOT NULL,
       SUPPLIERSTATUS GRAPHIC(8) NOT NULL,
       SUPPLIERNAME   VARGRAPHIC(255) NOT NULL,
       SUPPLIERNAMEU  VARGRAPHIC(255) NOT NULL,
       CREATEDBY      GRAPHIC(8) NOT NULL,
       CREATEDDATE    TIMESTAMP NOT NULL,
       UPDATEDBY      GRAPHIC(8) NOT NULL,
       UPDATEDDATE    TIMESTAMP NOT NULL,
       CONSTRAINT SUPPLIERIDKEY
       PRIMARY KEY (SUPPLIERID))
      IN {{DBNAME}}.{{SUPPLIERS_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create suppliers index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{SUPPLIERS_IXNAME1}}
      ON {{SCHEMA}}.{{SUPPLIERS_TBNAME}}
       (SUPPLIERID ASC)
      USING STOGROUP {{STOGROUP}}
     PRIQTY -1 SECQTY -1
     ERASE  NO
     FREEPAGE 0 PCTFREE 10
     GBPCACHE CHANGED
     NOT CLUSTER
     COMPRESS NO
     INCLUDE NULL KEYS
     BUFFERPOOL BP3
     CLOSE NO
     COPY NO
     DEFER NO
     DEFINE YES
     PIECESIZE 2 G;

-- Create suppliers index for SUPPLIERCODE
   CREATE UNIQUE INDEX {{SCHEMA}}.{{SUPPLIERS_IXNAME2}}
      ON {{SCHEMA}}.{{SUPPLIERS_TBNAME}}
       (SUPPLIERCODE ASC)
      USING STOGROUP {{STOGROUP}}
     PRIQTY -1 SECQTY -1
     ERASE  NO
     FREEPAGE 0 PCTFREE 10
     GBPCACHE CHANGED
     NOT CLUSTER
     COMPRESS NO
     INCLUDE NULL KEYS
     BUFFERPOOL BP3
     CLOSE NO
     COPY NO
     DEFER NO
     DEFINE YES
     PIECESIZE 2 G;

-- Create suppliers index for SUPPLIERNAMEU
   CREATE UNIQUE INDEX {{SCHEMA}}.{{SUPPLIERS_IXNAME3}}
      ON {{SCHEMA}}.{{SUPPLIERS_TBNAME}}
       (SUPPLIERNAMEU ASC,
        SUPPLIERID    ASC)
     USING STOGROUP {{STOGROUP}}
     PRIQTY -1 SECQTY -1
     ERASE  NO
     FREEPAGE 0 PCTFREE 10
     GBPCACHE CHANGED
     NOT CLUSTER
     COMPRESS NO
     INCLUDE NULL KEYS
     BUFFERPOOL BP3
     CLOSE NO
     COPY NO
     DEFER NO
     DEFINE YES
     PIECESIZE 2 G;

   COMMIT;