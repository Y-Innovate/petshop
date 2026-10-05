-- Create storesuppl table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create storesuppl tablespace
   CREATE TABLESPACE {{STORESUPPL_TBSNAME}}
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

-- Create storesuppl table
   CREATE TABLE {{SCHEMA}}.{{STORESUPPL_TBNAME}}
      (STOREID        INTEGER NOT NULL,
       SUPPLIERID     INTEGER NOT NULL,
       FROMDATE       TIMESTAMP,
       TODATE         TIMESTAMP,
       CREATEDBY      GRAPHIC(8) NOT NULL,
       CREATEDDATE    TIMESTAMP NOT NULL,
       UPDATEDBY      GRAPHIC(8) NOT NULL,
       UPDATEDDATE    TIMESTAMP NOT NULL,
       CONSTRAINT STORESUPPLKEY
       PRIMARY KEY (STOREID,
                    SUPPLIERID))
      IN {{DBNAME}}.{{STORESUPPL_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create storesuppl index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{STORESUPPL_IXNAME1}}
      ON {{SCHEMA}}.{{STORESUPPL_TBNAME}}
       (STOREID    ASC,
        SUPPLIERID ASC)
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
   ALTER TABLE {{SCHEMA}}.{{STORESUPPL_TBNAME}}
     FOREIGN KEY RESSU_STOREID (STOREID)
     REFERENCES {{SCHEMA}}.{{STORES_TBNAME}} (STOREID)
     ON DELETE RESTRICT ENFORCED;

-- Create foreign key on SUPPLIERID
   ALTER TABLE {{SCHEMA}}.{{STORESUPPL_TBNAME}}
     FOREIGN KEY RESSU_SUPPLIERID (SUPPLIERID)
     REFERENCES {{SCHEMA}}.{{SUPPLIERS_TBNAME}} (SUPPLIERID)
     ON DELETE RESTRICT ENFORCED;

   COMMIT;