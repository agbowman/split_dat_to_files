CREATE PROGRAM bhs_dup_mrn_load_temp:dba
 EXECUTE kia_dm_dbimport "bhscust:bhs_dup_mrn.dat", "bhs_dup_mrn_load_temp_child", 100000,
 0
END GO
