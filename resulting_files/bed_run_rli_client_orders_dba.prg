CREATE PROGRAM bed_run_rli_client_orders:dba
 SET filename = "CER_INSTALL:bed_rli_client_orders.csv"
 SET scriptname = "bed_imp_rli_client_orders"
 EXECUTE dm_dbimport filename, scriptname, 5000
END GO
