CREATE PROGRAM bmdi_results_init_cqm
 FREE SET request
 RECORD request(
   1 app_name = vc
 )
 SET request->app_name = "BMDI_RESULTS"
 EXECUTE cqm_del_cconfig_app
 EXECUTE cqm_del_registry_app
 EXECUTE cqm_del_lconfig_app
 FREE SET request
 RECORD request(
   1 app_name = vc
   1 contrib_alias = vc
   1 target_priority = i4
   1 debug_ind = i2
   1 verbosity_flag = i2
 )
 SET request->app_name = "BMDI_RESULTS"
 SET request->contrib_alias = "CONTRIBUTOR1"
 SET request->target_priority = 99
 SET request->debug_ind = 0
 SET request->verbosity_flag = 0
 EXECUTE cqm_add_cconfig
 FREE SET request
 RECORD request(
   1 app_name = vc
   1 listener_alias = vc
   1 trig_table_ext = vc
   1 comm_params = vc
 )
 SET request->app_name = "BMDI_RESULTS"
 SET request->listener_alias = "LISTENER1"
 SET request->trig_table_ext = "1"
 SET request->comm_params = "LCK"
 EXECUTE cqm_add_lconfig
 FREE SET request
 RECORD request(
   1 app_name = vc
   1 listener_alias = vc
   1 class = vc
   1 type = vc
   1 subtype = vc
   1 subtype_detail = vc
   1 target_priority = i4
   1 debug_ind = i2
   1 verbosity_flag = i2
 )
 SET request->app_name = "BMDI_RESULTS"
 SET request->listener_alias = "LISTENER1"
 SET request->class = ""
 SET request->type = ""
 SET request->subtype = ""
 SET request->subtype_detail = ""
 SET request->target_priority = 99
 SET request->debug_ind = 0
 SET request->verbosity_flag = 0
 EXECUTE cqm_add_registry
#exit_script
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 IF (validate(reqinfo->commit_ind,0) != 0)
  SET reqinfo->commit_ind = 1
 ELSE
  COMMIT
 ENDIF
#exit_prog
END GO
