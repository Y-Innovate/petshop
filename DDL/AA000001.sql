-- Grant permissions for creating stogroup and database,
-- use of bufferpools and execute on packages to sqlid.

   GRANT CREATESG,CREATEDBA TO {{SQLID}};
   GRANT USE OF ALL BUFFERPOOLS TO {{SQLID}};
   GRANT ALL ON PACKAGE {{PKGCOLLID}}.* TO {{SQLID}};