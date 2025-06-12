CREATE PROGRAM dm_add_cmb_triggers:dba
 SET c_mod = "DM_ADD_CMB_TRIGGERS 000"
 EXECUTE dm2_combine_triggers "*"
END GO
