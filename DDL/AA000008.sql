-- Create inventory table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create inventory tablespace
   CREATE TABLESPACE {{INVENTORY_TBSNAME}}
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

-- Create inventory table
   CREATE TABLE {{SCHEMA}}.{{INVENTORY_TBNAME}}
      (INVENTORYID    INTEGER NOT NULL GENERATED ALWAYS
          AS IDENTITY 
             (START WITH 1, INCREMENT BY 1, CACHE 20, NO CYCLE,
              NO ORDER, MAXVALUE 2147483647, MINVALUE 1),
       STOREID        INTEGER NOT NULL,
       PRODUCTID      INTEGER NOT NULL,
       SELLBYDATE     TIMESTAMP NOT NULL,
       INSTOCK        INTEGER NOT NULL,
       CREATEDBY      GRAPHIC(8) NOT NULL,
       CREATEDDATE    TIMESTAMP NOT NULL,
       UPDATEDBY      GRAPHIC(8) NOT NULL,
       UPDATEDDATE    TIMESTAMP NOT NULL,
       CONSTRAINT INVENTORYIDKEY
       PRIMARY KEY (INVENTORYID))
      IN {{DBNAME}}.{{INVENTORY_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create inventory index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{INVENTORY_IXNAME1}}
      ON {{SCHEMA}}.{{INVENTORY_TBNAME}}
       (INVENTORYID ASC)
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

-- Create products index for STOREID, PRODUCTID and SELLBYDATE
   CREATE UNIQUE INDEX {{SCHEMA}}.{{INVENTORY_IXNAME2}}
      ON {{SCHEMA}}.{{INVENTORY_TBNAME}}
       (STOREID    ASC,
        PRODUCTID  ASC,
        SELLBYDATE ASC)
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

-- Create foreign key on STOREID
   ALTER TABLE {{SCHEMA}}.{{INVENTORY_TBNAME}}
     FOREIGN KEY REINV_STOREID (STOREID)
     REFERENCES {{SCHEMA}}.{{STORES_TBNAME}} (STOREID)
     ON DELETE RESTRICT ENFORCED;

-- Create foreign key on PRODUCTID
   ALTER TABLE {{SCHEMA}}.{{INVENTORY_TBNAME}}
     FOREIGN KEY REINV_PRODUCTID (PRODUCTID)
     REFERENCES {{SCHEMA}}.{{PRODUCTS_TBNAME}} (PRODUCTID)
     ON DELETE RESTRICT ENFORCED;

   COMMIT;