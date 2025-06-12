CREATE PROGRAM dm_req_proc_ins:dba
 EXECUTE dm_dbimport "cer_install:dm_cb_request_processing.csv", "dm_cb_request_proc_load", 1000
END GO
