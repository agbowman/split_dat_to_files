CREATE PROGRAM bed_run_oc_dta
 SET filename = "CER_INSTALL:ps_oc_dta.csv"
 SET scriptname = "bed_ens_oc_dta_ps"
 EXECUTE bed_dm_dbimport filename, scriptname, 5000
END GO
