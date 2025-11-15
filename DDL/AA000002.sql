-- Create storage group for petstore database.

-- Set SQLID
   SET CURRENT SQLID='{{SQLID}}';

-- Create storage group
   CREATE STOGROUP {{STOGROUP}}
                   VOLUMES('*')
                   VCAT {{STOGROUP_VCAT}}
                   STORCLAS {{STOGROUP_STORCLAS}};

   COMMIT;