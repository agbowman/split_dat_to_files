CREATE PROGRAM dm_ddl_gen2:dba
 EXECUTE dm_ddl_gen_main  $1,  $2, 1
END GO
