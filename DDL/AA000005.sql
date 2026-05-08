-- Create stores table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create stores tablespace
   CREATE TABLESPACE {{STORES_TBSNAME}}
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

-- Create stores table
   CREATE TABLE {{SCHEMA}}.{{STORES_TBNAME}}
      (STOREID     INTEGER NOT NULL GENERATED ALWAYS
          AS IDENTITY 
             (START WITH 1, INCREMENT BY 1, CACHE 20, NO CYCLE,
              NO ORDER, MAXVALUE 2147483647, MINVALUE 1),
       STORECODE   GRAPHIC(8) NOT NULL,
       STORESTATUS GRAPHIC(8) NOT NULL,
       STORENAME   VARGRAPHIC(255) NOT NULL,
       STORENAMEU  VARGRAPHIC(255) NOT NULL,
       CREATEDBY   GRAPHIC(8) NOT NULL,
       CREATEDDATE TIMESTAMP NOT NULL,
       UPDATEDBY   GRAPHIC(8) NOT NULL,
       UPDATEDDATE TIMESTAMP NOT NULL,
       CONSTRAINT STOREIDKEY
       PRIMARY KEY (STOREID))
      IN {{DBNAME}}.{{STORES_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create stores index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{STORES_IXNAME1}}
      ON {{SCHEMA}}.{{STORES_TBNAME}}
       (STOREID ASC)
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

-- Create stores index for STORECODE
   CREATE UNIQUE INDEX {{SCHEMA}}.{{STORES_IXNAME2}}
      ON {{SCHEMA}}.{{STORES_TBNAME}}
       (STORECODE ASC)
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

-- Create stores index for STORENAMEU
   CREATE UNIQUE INDEX {{SCHEMA}}.{{STORES_IXNAME3}}
      ON {{SCHEMA}}.{{STORES_TBNAME}}
       (STORENAMEU ASC,
        STOREID    ASC)
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

   COMMIT;