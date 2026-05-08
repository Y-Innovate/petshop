-- Create customers table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create customers tablespace
   CREATE TABLESPACE {{CUSTOMERS_TBSNAME}}
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

-- Create customers table
   CREATE TABLE {{SCHEMA}}.{{CUSTOMERS_TBNAME}}
      (CUSTOMERID     INTEGER NOT NULL GENERATED ALWAYS
          AS IDENTITY 
             (START WITH 1, INCREMENT BY 1, CACHE 20, NO CYCLE,
              NO ORDER, MAXVALUE 2147483647, MINVALUE 1),
       LASTNAME       VARGRAPHIC(128) NOT NULL,
       LASTNAMEU      VARGRAPHIC(128) NOT NULL,
       FIRSTNAME      VARGRAPHIC(64),
       FIRSTNAMEU     VARGRAPHIC(64),
       MIDDLENAME     VARGRAPHIC(64),
       DATEOFBIRTH    GRAPHIC(8),
       GENDER         GRAPHIC(1),
       CREATEDBY      GRAPHIC(8) NOT NULL,
       CREATEDDATE    TIMESTAMP NOT NULL,
       UPDATEDBY      GRAPHIC(8) NOT NULL,
       UPDATEDDATE    TIMESTAMP NOT NULL,
       CONSTRAINT CUSTOMERIDKEY
       PRIMARY KEY (CUSTOMERID))
      IN {{DBNAME}}.{{CUSTOMERS_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create customers index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{CUSTOMERS_IXNAME1}}
      ON {{SCHEMA}}.{{CUSTOMERS_TBNAME}}
       (CUSTOMERID ASC)
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

-- Create customers index for LASTNAMEU, FIRSTNAMEU
   CREATE UNIQUE INDEX {{SCHEMA}}.{{CUSTOMERS_IXNAME2}}
      ON {{SCHEMA}}.{{CUSTOMERS_TBNAME}}
       (LASTNAMEU  ASC,
        FIRSTNAMEU ASC)
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