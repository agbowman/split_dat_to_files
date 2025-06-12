CREATE PROGRAM dm_drop_combine_triggers:dba
 SET drop_only = 1
 EXECUTE dm_combine_triggers
END GO
