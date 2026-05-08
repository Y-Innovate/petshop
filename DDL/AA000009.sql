-- Create animals table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create animals tablespace
   CREATE TABLESPACE {{ANIMALS_TBSNAME}}
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
                       BUFFERPOOL BP0
                       LOCKSIZE ANY
                       LOCKMAX SYSTEM
                       CLOSE YES
                       COMPRESS NO
                       CCSID      UNICODE
                       DEFINE YES
                       MAXROWS 255
                       INSERT ALGORITHM 0;

-- Create animals table
   CREATE TABLE {{SCHEMA}}.{{ANIMALS_TBNAME}}
      (ANIMALID       INTEGER NOT NULL GENERATED ALWAYS
          AS IDENTITY 
             (START WITH 1, INCREMENT BY 1, CACHE 20, NO CYCLE,
              NO ORDER, MAXVALUE 2147483647, MINVALUE 1),
       STOREID        INTEGER NOT NULL,
       ANIMALTYPE     GRAPHIC(8) NOT NULL,
       ANIMALRACE     GRAPHIC(8) NOT NULL,
       ANIMALNAME     VARGRAPHIC(255) NOT NULL,
       ANIMALGENDER   GRAPHIC(1) NOT NULL,
       ANIMALAGE      INTEGER NOT NULL,
       ANIMALCOUNT    INTEGER NOT NULL,
       CREATEDBY      GRAPHIC(8) NOT NULL,
       CREATEDDATE    TIMESTAMP NOT NULL,
       UPDATEDBY      GRAPHIC(8) NOT NULL,
       UPDATEDDATE    TIMESTAMP NOT NULL,
       CONSTRAINT ANIMALIDKEY
       PRIMARY KEY (ANIMALID))
      IN {{DBNAME}}.{{ANIMALS_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create inventory index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{ANIMALS_IXNAME1}}
      ON {{SCHEMA}}.{{ANIMALS_TBNAME}}
       (ANIMALID ASC)
      USING STOGROUP {{STOGROUP}}
     PRIQTY -1 SECQTY -1
     ERASE  NO
     FREEPAGE 0 PCTFREE 10
     GBPCACHE CHANGED
     NOT CLUSTER
     COMPRESS NO
     INCLUDE NULL KEYS
     BUFFERPOOL BP0
     CLOSE NO
     COPY NO
     DEFER NO
     DEFINE YES
     PIECESIZE 2 G;

-- Create products index for STOREID, ANIMALTYPE, ANIMALRACE, ANIMALNAME
   CREATE UNIQUE INDEX {{SCHEMA}}.{{ANIMALS_IXNAME2}}
      ON {{SCHEMA}}.{{ANIMALS_TBNAME}}
       (STOREID    ASC,
        ANIMALTYPE ASC,
        ANIMALRACE ASC,
        ANIMALNAME ASC)
      USING STOGROUP {{STOGROUP}}
     PRIQTY -1 SECQTY -1
     ERASE  NO
     FREEPAGE 0 PCTFREE 10
     GBPCACHE CHANGED
     NOT CLUSTER
     COMPRESS NO
     INCLUDE NULL KEYS
     BUFFERPOOL BP0
     CLOSE NO
     COPY NO
     DEFER NO
     DEFINE YES
     PIECESIZE 2 G;

-- Create foreign key on STOREID
   ALTER TABLE {{SCHEMA}}.{{ANIMALS_TBNAME}}
     FOREIGN KEY REANI_STOREID (STOREID)
     REFERENCES {{SCHEMA}}.{{STORES_TBNAME}} (STOREID)
     ON DELETE RESTRICT ENFORCED;

   COMMIT;