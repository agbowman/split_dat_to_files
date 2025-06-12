CREATE PROGRAM bbd_rdm_dbimport_ques_depend:dba
 EXECUTE dm_dbimport "cer_install:bbd_ques_depend_import.CSV", "BB_RDM_IMPORT_QUES_DEPEND", 1000
END GO
