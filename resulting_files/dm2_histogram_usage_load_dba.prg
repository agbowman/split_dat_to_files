CREATE PROGRAM dm2_histogram_usage_load:dba
 EXECUTE dm_dbimport "cer_install:dm2_histogram_usage.csv", "dm2_hist_usage_load_rows", 500
END GO
