-- Add column CHILDFRIENDLY to animals table in petstore database.
-- 'Y' = the animal is child friendly, 'N' = it is not. Existing rows
-- get the default 'N'.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Check existing rows immediately when the check constraint is added,
-- instead of putting the table in CHECK-pending status
   SET CURRENT RULES = 'STD';

-- Add CHILDFRIENDLY column
   ALTER TABLE {{SCHEMA}}.{{ANIMALS_TBNAME}}
     ADD COLUMN CHILDFRIENDLY GRAPHIC(1) NOT NULL WITH DEFAULT 'N';

-- Only allow 'Y' and 'N'
   ALTER TABLE {{SCHEMA}}.{{ANIMALS_TBNAME}}
     ADD CONSTRAINT CKANI_CHILDFRIENDLY
     CHECK (CHILDFRIENDLY IN ('Y', 'N'));

   COMMIT;
