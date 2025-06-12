CREATE PROGRAM dm_create_active_trigger:dba
 EXECUTE dm_create_active_ind_trig  $1
END GO
