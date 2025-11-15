-- Create petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create petstore database
   CREATE DATABASE {{DBNAME}}
                     BUFFERPOOL BP2
                     INDEXBP    BP3
                     CCSID      UNICODE
                     STOGROUP   {{STOGROUP}};

   COMMIT;