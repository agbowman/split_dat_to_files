CREATE PROGRAM bed_run_rli_alias
 SET filename = "CER_INSTALL:bed_rli_alias.csv"
 SET scriptname = "bed_imp_rli_alias"
 EXECUTE dm_dbimport filename, scriptname, 5000
END GO
