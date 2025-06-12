CREATE PROGRAM bb_rdm_dbimport_exception_task:dba
 EXECUTE dm_dbimport "cer_install:bbt_exception_task_import.CSV", "bbt_rdm_import_exception_task",
 1000
END GO
