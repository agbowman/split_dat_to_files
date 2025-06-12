CREATE PROGRAM bbt_rdm_expspecres_task:dba
 EXECUTE dm_dbimport "cer_install:bbt_expspecres_task.csv", "bbt_rdm_import_exception_task", 1000
END GO
