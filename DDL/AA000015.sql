-- Create contactinfos table in petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create contactinfos tablespace
   CREATE TABLESPACE {{CONTACTINFOS_TBSNAME}}
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

-- Create contactinfos table
   CREATE TABLE {{SCHEMA}}.{{CONTACTINFOS_TBNAME}}
      (CONTACTINFOID  INTEGER NOT NULL GENERATED ALWAYS
          AS IDENTITY 
             (START WITH 1, INCREMENT BY 1, CACHE 20, NO CYCLE,
              NO ORDER, MAXVALUE 2147483647, MINVALUE 1),
       CONTACTINFOTYPE GRAPHIC(8) NOT NULL,
       OWNERTYPE      GRAPHIC(1) NOT NULL,
       OWNERID        INTEGER NOT NULL,
       CONTACTDATA    VARGRAPHIC(255),
       FROMDATE       TIMESTAMP,
       TODATE         TIMESTAMP,
       CREATEDBY      GRAPHIC(8) NOT NULL,
       CREATEDDATE    TIMESTAMP NOT NULL,
       UPDATEDBY      GRAPHIC(8) NOT NULL,
       UPDATEDDATE    TIMESTAMP NOT NULL,
       CONSTRAINT CONTACTINFOIDKEY
       PRIMARY KEY (CONTACTINFOID))
      IN {{DBNAME}}.{{CONTACTINFOS_TBSNAME}}
      PARTITION BY SIZE
      AUDIT NONE
      DATA CAPTURE NONE
      CCSID      UNICODE
      NOT VOLATILE
      APPEND NO;

-- Create contactinfos index for primary key
   CREATE UNIQUE INDEX {{SCHEMA}}.{{CONTACTINFOS_IXNAME1}}
      ON {{SCHEMA}}.{{CONTACTINFOS_TBNAME}}
       (CONTACTINFOID ASC)
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

-- Create contactinfos index for CONTACTINFOTYPE, OWNERTYPE, OWNERID,
-- FROMDATE
   CREATE UNIQUE INDEX {{SCHEMA}}.{{CONTACTINFOS_IXNAME2}}
      ON {{SCHEMA}}.{{CONTACTINFOS_TBNAME}}
       (CONTACTINFOTYPE ASC,
        OWNERTYPE       ASC,
        OWNERID         ASC,
        FROMDATE        ASC)
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