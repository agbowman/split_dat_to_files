CREATE PROGRAM dm_cm_all_solcap:dba
 FREE RECORD dm_cm_solcap_request
 RECORD dm_cm_solcap_request(
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 solution_name = vc
   1 solcap_identifier = vc
 )
 SET dm_cm_solcap_request->start_dt_tm = request->start_dt_tm
 SET dm_cm_solcap_request->end_dt_tm = request->end_dt_tm
 SET dm_cm_solcap_request->solution_name = "CONTENT MANAGER"
 SET dm_cm_solcap_request->solcap_identifier = ""
 EXECUTE dm_solcap_get  WITH replace(dm_dsg_request,dm_cm_solcap_request)
END GO
