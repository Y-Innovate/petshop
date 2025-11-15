-- Create reftables table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create reftables tablespace
   CREATE TABLESPACE {{REFTABLES_TBSNAME}}
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

-- Create reftables table
   CREATE TABLE {{SCHEMA}}.{{REFTABLES_TBNAME}}
      (TABLEID     GRAPHIC(8)      NOT NULL,
       TABKEY      GRAPHIC(8)      NOT NULL,
       TABVALUE    VARGRAPHIC(255),
       CREATEDBY   GRAPHIC(8)      NOT NULL,
       CREATEDDATE TIMESTAMP       NOT NULL,
       UPDATEDBY   GRAPHIC(8)      NOT NULL,
       UPDATEDDATE TIMESTAMP       NOT NULL,
       CONSTRAINT TABLEIDKEY
       PRIMARY KEY (TABLEID,TABKEY))
      IN {{DBNAME}}.{{REFTABLES_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create reftables index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{REFTABLES_IXNAME1}}
     ON {{SCHEMA}}.{{REFTABLES_TBNAME}}
      (TABLEID  ASC,
       TABKEY   ASC)
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