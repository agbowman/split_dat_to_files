CREATE PROGRAM bmdi_init_cqm:dba
 DECLARE appname = vc
 DECLARE listeneralias = vc
 SET appname = "BMDI_RESULTS"
 SET listeneralias = "CONTRIBUTOR1"
 FREE SET request
 RECORD request(
   1 app_name = vc
   1 contrib_alias = vc
   1 target_priority = i4
   1 debug_ind = i2
   1 verbosity_flag = i2
 )
 SET request->app_name = appname
 SET request->contrib_alias = listeneralias
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
 SET request->app_name = appname
 SET request->listener_alias = listeneralias
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
 SET request->app_name = appname
 SET request->listener_alias = listeneralias
 SET request->class = listeneralias
 SET request->type = ""
 SET request->subtype = ""
 SET request->subtype_detail = ""
 SET request->target_priority = 99
 SET request->debug_ind = 0
 SET request->verbosity_flag = 0
 EXECUTE cqm_add_registry
END GO
