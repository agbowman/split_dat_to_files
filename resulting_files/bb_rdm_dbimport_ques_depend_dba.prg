CREATE PROGRAM bb_rdm_dbimport_ques_depend:dba
 EXECUTE dm_dbimport "cer_install:bbt_ques_depend_import.CSV", "BB_RDM_IMPORT_QUES_DEPEND", 1000
END GO
