CREATE PROGRAM bed_run_client_org
 SET filename = "CER_INSTALL:BED_IMP_CLIENT_ORG.CSV"
 SET scriptname = "bed_imp_client_org"
 EXECUTE dm_dbimport filename, scriptname, 10000
END GO
