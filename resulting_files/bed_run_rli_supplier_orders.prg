CREATE PROGRAM bed_run_rli_supplier_orders
 SET filename = "CER_INSTALL:bed_rli_supplier_orders.csv"
 SET scriptname = "bed_imp_rli_supplier_orders"
 EXECUTE dm_dbimport filename, scriptname, 15000
END GO
