CREATE PROGRAM bed_run_oc_con_cki_upd
 SET filename = "CER_INSTALL:oc_concept_cki.csv"
 SET scriptname = "bed_imp_oc_con_cki_upd"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
