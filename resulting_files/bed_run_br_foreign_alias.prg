CREATE PROGRAM bed_run_br_foreign_alias
 SET filename = "CER_INSTALL:br_foreign_alias.csv"
 SET scriptname = "bed_imp_br_foreign_alias"
 EXECUTE dm_dbimport filename, scriptname, 15000
END GO
