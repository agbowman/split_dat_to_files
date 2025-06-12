CREATE PROGRAM aps_rdm_dbimport_cvg:dba
 EXECUTE dm_dbimport "cer_install:aps_date_format_import.csv", "aps_rdm_dt_format_imprt", 1000
 EXECUTE aps_chk_date_format_import
 EXECUTE dm_readme_status
END GO
