CREATE PROGRAM bbt_rdm_dispense_exp_ovrd_task:dba
 EXECUTE dm_dbimport "cer_install:bbt_dispense_exp_ovrd_task.csv", "bbt_rdm_import_exception_task",
 1000
END GO
