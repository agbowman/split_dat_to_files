CREATE PROGRAM dm2_process_queue_wrapper:dba
 IF ((validate(dcr_max_stack_size,- (1))=- (1))
  AND (validate(dcr_max_stack_size,- (2))=- (2)))
  DECLARE dcr_max_stack_size = i4 WITH protect, constant(30)
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0
  AND validate(dm_err->ecode,722)=722)
  FREE RECORD dm_err
  IF (currev >= 8)
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = vc
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ELSE
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = c132
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ENDIF
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 IF (validate(dm2_sys_misc->cur_os,"X")="X"
  AND validate(dm2_sys_misc->cur_os,"Y")="Y")
  FREE RECORD dm2_sys_misc
  RECORD dm2_sys_misc(
    1 cur_os = vc
    1 cur_db_os = vc
  )
  SET dm2_sys_misc->cur_os = validate(cursys2,cursys)
  SET dm2_sys_misc->cur_db_os = validate(currdbsys,cursys)
  IF (size(dm2_sys_misc->cur_db_os) != 3)
   SET dm2_sys_misc->cur_db_os = substring(1,(findstring(":",dm2_sys_misc->cur_db_os,1,1) - 1),
    dm2_sys_misc->cur_db_os)
  ENDIF
 ENDIF
 IF (validate(dm2_install_schema->process_option," ")=" "
  AND validate(dm2_install_schema->process_option,"NOTTHERE")="NOTTHERE")
  FREE RECORD dm2_install_schema
  RECORD dm2_install_schema(
    1 process_option = vc
    1 file_prefix = vc
    1 schema_loc = vc
    1 schema_prefix = vc
    1 target_dbase_name = vc
    1 dbase_name = vc
    1 u_name = vc
    1 p_word = vc
    1 connect_str = vc
    1 v500_p_word = vc
    1 v500_connect_str = vc
    1 cdba_p_word = vc
    1 cdba_connect_str = vc
    1 run_id = i4
    1 menu_driver = vc
    1 oragen3_ignore_dm_columns_doc = i2
    1 last_checkpoint = vc
    1 gen_id = i4
    1 restart_method = i2
    1 appl_id = vc
    1 hostname = vc
    1 ccluserdir = vc
    1 cer_install = vc
    1 servername = vc
    1 frmt_servername = vc
    1 default_fg_name = vc
    1 curprog = vc
    1 adl_username = vc
    1 tgt_sch_cleanup = i2
    1 special_ih_process = i2
    1 dbase_type = vc
    1 data_to_move = c30
    1 percent_tspace = i4
    1 src_dbase_name = vc
    1 src_v500_p_word = vc
    1 src_v500_connect_str = vc
    1 logfile_prefix = vc
    1 src_run_id = f8
    1 src_op_id = f8
    1 target_env_name = vc
    1 dm2_updt_task_value = i2
  )
  SET dm2_install_schema->process_option = "NONE"
  SET dm2_install_schema->file_prefix = "NONE"
  SET dm2_install_schema->schema_loc = "NONE"
  SET dm2_install_schema->schema_prefix = "NONE"
  SET dm2_install_schema->target_dbase_name = "NONE"
  SET dm2_install_schema->dbase_name = "NONE"
  SET dm2_install_schema->u_name = "NONE"
  SET dm2_install_schema->p_word = "NONE"
  SET dm2_install_schema->connect_str = "NONE"
  SET dm2_install_schema->v500_p_word = "NONE"
  SET dm2_install_schema->v500_connect_str = "NONE"
  SET dm2_install_schema->cdba_p_word = "NONE"
  SET dm2_install_schema->cdba_connect_str = "NONE"
  SET dm2_install_schema->run_id = 0
  SET dm2_install_schema->menu_driver = "NONE"
  SET dm2_install_schema->oragen3_ignore_dm_columns_doc = 0
  SET dm2_install_schema->last_checkpoint = "NONE"
  SET dm2_install_schema->gen_id = 0
  SET dm2_install_schema->restart_method = 0
  SET dm2_install_schema->appl_id = "NONE"
  SET dm2_install_schema->hostname = "NONE"
  SET dm2_install_schema->servername = "NONE"
  SET dm2_install_schema->default_fg_name = "NONE"
  SET dm2_install_schema->curprog = "NONE"
  SET dm2_install_schema->adl_username = "NONE"
  SET dm2_install_schema->tgt_sch_cleanup = 0
  SET dm2_install_schema->special_ih_process = 0
  SET dm2_install_schema->dbase_type = "NONE"
  SET dm2_install_schema->data_to_move = "NONE"
  SET dm2_install_schema->percent_tspace = 0
  SET dm2_install_schema->src_dbase_name = "NONE"
  SET dm2_install_schema->src_v500_p_word = "NONE"
  SET dm2_install_schema->src_v500_connect_str = "NONE"
  SET dm2_install_schema->logfile_prefix = "NONE"
  SET dm2_install_schema->src_run_id = 0
  SET dm2_install_schema->src_op_id = 0
  SET dm2_install_schema->target_env_name = "NONE"
  SET dm2_install_schema->dm2_updt_task_value = 15301
  IF ((dm2_sys_misc->cur_os="WIN"))
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"\")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"\")
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   SET dm2_install_schema->ccluserdir = logical("ccluserdir")
   SET dm2_install_schema->cer_install = logical("cer_install")
  ELSE
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"/")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"/")
  ENDIF
 ENDIF
 IF (validate(inhouse_misc->inhouse_domain,- (1)) < 0
  AND validate(inhouse_misc->inhouse_domain,722)=722)
  FREE RECORD inhouse_misc
  RECORD inhouse_misc(
    1 inhouse_domain = i2
    1 fk_err_ind = i2
    1 nonfk_err_ind = i2
    1 fk_parent_table = vc
    1 tablespace_err_code = f8
    1 foreignkey_err_code = f8
  )
  SET inhouse_misc->inhouse_domain = - (1)
  SET inhouse_misc->fk_err_ind = 0
  SET inhouse_misc->nonfk_err_ind = 0
  SET inhouse_misc->fk_parent_table = ""
  SET inhouse_misc->tablespace_err_code = 93
  SET inhouse_misc->foreignkey_err_code = 94
 ENDIF
 IF (validate(program_stack_rs->cnt,1)=1
  AND validate(program_stack_rs->cnt,2)=2)
  FREE RECORD program_stack_rs
  RECORD program_stack_rs(
    1 cnt = i4
    1 qual[*]
      2 name = vc
  )
  SET stat = alterlist(program_stack_rs->qual,dcr_max_stack_size)
 ENDIF
 DECLARE dm2_push_cmd(sbr_dpcstr=vc,sbr_cmd_end=i2) = i2
 DECLARE dm2_push_dcl(sbr_dpdstr=vc) = i2
 DECLARE get_unique_file(sbr_fprefix=vc,sbr_fext=vc) = i2
 DECLARE parse_errfile(sbr_errfile=vc) = i2
 DECLARE check_error(sbr_ceprocess=vc) = i2
 DECLARE disp_msg(sbr_demsg=vc,sbr_dlogfile=vc,sbr_derr_ind=i2) = null
 DECLARE init_logfile(sbr_logfile=vc,sbr_header_msg=vc) = i2
 DECLARE check_logfile(sbr_lprefix=vc,sbr_lext=vc,sbr_hmsg=vc) = i2
 DECLARE final_disp_msg(sbr_log_prefix=vc) = null
 DECLARE dm2_set_autocommit(sbr_dsa_flag=i2) = i2
 DECLARE dm2_prg_maint(sbr_maint_type=vc) = i2
 DECLARE dm2_set_inhouse_domain() = i2
 DECLARE dm2_table_exists(dte_table_name=vc) = c1
 DECLARE dm2_table_and_ccldef_exists(dtace_table_name=vc,dtace_found_ind=i2(ref)) = i2
 DECLARE dm2_table_column_exists(dtce_owner=vc,dtce_table_name=vc,dtce_column_name=vc,
  dtce_col_chk_ind=i2,dtce_coldef_chk_ind=i2,
  dtce_ccldef_mode=i2,dtce_col_fnd_ind=i2(ref),dtce_coldef_fnd_ind=i2(ref),dtce_data_type=vc(ref)) =
 i2
 DECLARE dm2_disp_file(ddf_fname=vc,ddf_desc=vc) = i2
 DECLARE dm2_get_program_stack(null) = vc
 DECLARE dm2_get_program_details(null) = vc
 SUBROUTINE dm2_get_program_details(null)
   DECLARE dgpd_param_num = i2 WITH protect, noconstant(1)
   DECLARE dgpd_param_type = vc WITH protect, noconstant("")
   DECLARE dgpd_param_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgpd_details = vc WITH protect, noconstant("~")
   WHILE (dgpd_param_num)
    IF (assign(dgpd_param_type,reflect(parameter(dgpd_param_num,0)))="")
     SET dgpd_param_cnt = (dgpd_param_num - 1)
     SET dgpd_param_num = 0
     IF (dgpd_param_cnt=0)
      RETURN("")
     ELSE
      RETURN(substring(3,size(dgpd_details),dgpd_details))
     ENDIF
    ELSE
     SET dgpd_details = build(dgpd_details,",")
     IF (substring(1,1,dgpd_param_type)="C")
      SET dgpd_details = build(dgpd_details,'"',parameter(dgpd_param_num,0),'"')
     ELSE
      SET dgpd_details = build(dgpd_details,parameter(dgpd_param_num,0))
     ENDIF
    ENDIF
    SET dgpd_param_num = (dgpd_param_num+ 1)
   ENDWHILE
 END ;Subroutine
 DECLARE dm2_process_log_row(process_name=vc,action_type=vc,prev_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_dtl_row(dpldr_event_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_add_detail_text(detail_type=vc,detail_text=vc) = null
 DECLARE dm2_process_log_add_detail_date(detail_type=vc,detail_date=dq8) = null
 DECLARE dm2_process_log_add_detail_number(detail_type=vc,detail_number=f8) = null
 DECLARE dpl_upd_dped_last_status(dudls_event_id=f8,dudls_text=vc,dudls_number=f8,dudls_date=dq8) =
 i2
 DECLARE dpl_ui_chk(duc_process_name=vc) = i2
 IF ((validate(dm2_process_rs->cnt,- (1))=- (1))
  AND (validate(dm2_process_rs->cnt,- (2))=- (2)))
  FREE RECORD dm2_process_rs
  RECORD dm2_process_rs(
    1 dbase_name = vc
    1 table_exists_ind = i2
    1 filled_ind = i2
    1 dm_process_id = f8
    1 process_name = vc
    1 cnt = i4
    1 qual[*]
      2 dm_process_id = f8
      2 process_name = vc
      2 program_name = vc
      2 action_type = vc
      2 search_string = vc
  )
  FREE RECORD dm2_process_event_rs
  RECORD dm2_process_event_rs(
    1 dm_process_event_id = f8
    1 status = vc
    1 message = vc
    1 ui_allowed_ind = i2
    1 install_plan_id = f8
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 detail_cnt = i4
    1 itinerary_key = vc
    1 itinerary_process_event_id = f8
    1 details[*]
      2 detail_type = vc
      2 detail_number = f8
      2 detail_text = vc
      2 detail_date = dq8
  )
  SET dm2_process_event_rs->ui_allowed_ind = 0
 ENDIF
 IF (validate(dpl_index_monitoring,"X")="X"
  AND validate(dpl_index_monitoring,"Y")="Y")
  DECLARE dpl_username = vc WITH protect, constant(curuser)
  DECLARE dpl_no_prev_id = f8 WITH protect, constant(0.0)
  DECLARE dpl_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpl_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpl_failed = vc WITH protect, constant("FAILED")
  DECLARE dpl_complete = vc WITH protect, constant("COMPLETE")
  DECLARE dpl_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpl_paused = vc WITH protect, constant("PAUSED")
  DECLARE dpl_confirmation = vc WITH protect, constant("CONFIRMATION")
  DECLARE dpl_decline = vc WITH protect, constant("DECLINE")
  DECLARE dpl_stopped = vc WITH protect, constant("STOPPED")
  DECLARE dpl_statistics = vc WITH protect, constant("DATABASE STATISTICS GATHERING")
  DECLARE dpl_cbo = vc WITH protect, constant("CBO IMPLEMENTER")
  DECLARE dpl_db_services = vc WITH protect, constant("DATABASE SERVICES")
  DECLARE dpl_package_install = vc WITH protect, constant("PACKAGE INSTALL")
  DECLARE dpl_install_runner = vc WITH protect, constant("INSTALL RUNNER")
  DECLARE dpl_background_runner = vc WITH protect, constant("BACKGROUND RUNNER")
  DECLARE dpl_install_monitor = vc WITH protect, constant("INSTALL MONITOR")
  DECLARE dpl_status_change = vc WITH protect, constant("STATUS CHANGE")
  DECLARE dpl_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpl_process_queue_runner = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER")
  DECLARE dpl_process_queue_single = vc WITH protect, constant("DM_PROCESS_QUEUE SINGLE")
  DECLARE dpl_process_queue_wrapper = vc WITH protect, constant("DM_PROCESS_QUEUE WRAPPER")
  DECLARE dpl_routine_tasks = vc WITH protect, constant("ROUTINE TASKS")
  DECLARE dpl_coalesce = vc WITH protect, constant("INDEX COALESCING")
  DECLARE dpl_custom_user_mgmt = vc WITH protect, constant("CUSTOM USERS MANAGEMENT")
  DECLARE dpl_xnt_clinical_ranges = vc WITH protect, constant(
   "ESTABLISH EXTRACT & TRANSFORM(XNT) CLINICAL RANGES")
  DECLARE dpl_cbo_stats = vc WITH protect, constant("CBO STATISTICS MANAGEMENT")
  DECLARE dpl_oragen3 = vc WITH protect, constant("ORAGEN3")
  DECLARE dpl_cap_desired_schema = vc WITH protect, constant("CAPTURE DESIRED SCHEMA")
  DECLARE dpl_app_desired_schema = vc WITH protect, constant("APPLY DESIRED SCHEMA")
  DECLARE dpl_ccl_grant = vc WITH protect, constant("CCL GRANTS")
  DECLARE dpl_plan_control = vc WITH protect, constant("PLAN CONTROL")
  DECLARE dpl_cleanup_stats_rows = vc WITH protect, constant("CLEANUP STATS ROWS")
  DECLARE dpl_index_monitoring = vc WITH protect, constant("INDEX MONITORING")
  DECLARE dpl_admin_upgrade = vc WITH protect, constant("ADMIN UPGRADE")
  DECLARE dpl_execution = vc WITH protect, constant("EXECUTION")
  DECLARE dpl_enable_table_monitoring = vc WITH protect, constant("TABLE MONITORING ENABLE")
  DECLARE dpl_table_stats_gathering = vc WITH protect, constant("GATHER TABLE STATS")
  DECLARE dpl_index_stats_gathering = vc WITH protect, constant("GATHER INDEX STATS")
  DECLARE dpl_system_stats_gathering = vc WITH protect, constant("GATHER SYSTEM STATS")
  DECLARE dpl_schema_stats_gathering = vc WITH protect, constant("GATHER SCHEMA STATS")
  DECLARE dpl_itinerary_event = vc WITH protect, constant("ITINERARY EVENT")
  DECLARE dpl_alter_index_monitoring = vc WITH protect, constant("ALTER_INDEX_MONITORING")
  DECLARE dpl_cbo_reset_script_manual = vc WITH protect, constant("CBO RESET SCRIPT MANUAL")
  DECLARE dpl_cbo_reset_script_recompile = vc WITH protect, constant("CBO RESET SCRIPT RECOMPILE")
  DECLARE dpl_cbo_reset_query_manual = vc WITH protect, constant("CBO RESET QUERY MANUAL")
  DECLARE dpl_cbo_reset_all = vc WITH protect, constant("CBO RESET ALL")
  DECLARE dpl_cbo_enable = vc WITH protect, constant("CBO ENABLED")
  DECLARE dpl_cbo_disable = vc WITH protect, constant("CBO DISABLE")
  DECLARE dpl_cbo_monitoring_init = vc WITH protect, constant("CBO MONITORING INITIATED")
  DECLARE dpl_cbo_monitoring_complete = vc WITH protect, constant("CBO MONITORING COMPLETE")
  DECLARE dpl_cbo_tuning_change = vc WITH protect, constant("CBO TUNING CHANGE")
  DECLARE dpl_cbo_tuning_nochange = vc WITH protect, constant("CBO TUNING NOCHANGE")
  DECLARE dpl_data_dump = vc WITH protect, constant("CBO DATA DUMP")
  DECLARE dpl_data_dump_purge = vc WITH protect, constant("CBO DATA DUMP PURGE")
  DECLARE dpl_activate_all = vc WITH protect, constant("ACTIVATE ALL SERVICES")
  DECLARE dpl_instance_activation = vc WITH protect, constant("ACTIVATE SERVICES BY INSTANCE")
  DECLARE dpl_tns_deployment = vc WITH protect, constant("TNS DEPLOYMENT")
  DECLARE dpl_svc_reg_upd = vc WITH protect, constant("REGISTRY SERVER UPDATE")
  DECLARE dpl_notification = vc WITH protect, constant("NOTIFICATION")
  DECLARE dpl_auditlog = vc WITH protect, constant("AUDITLOG")
  DECLARE dpl_snapshot = vc WITH protect, constant("SNAPSHOT")
  DECLARE dpl_purge = vc WITH protect, constant("CUSTOM-DELETE")
  DECLARE dpl_table = vc WITH protect, constant("TABLE")
  DECLARE dpl_index = vc WITH protect, constant("INDEX")
  DECLARE dpl_system = vc WITH protect, constant("SYSTEM")
  DECLARE dpl_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpl_cmd = vc WITH protect, constant("COMMAND")
  DECLARE dpl_est_pct = vc WITH protect, constant("ESTIMATE PERCENT")
  DECLARE dpl_owner = vc WITH protect, constant("OWNER")
  DECLARE dpl_method_opt = vc WITH protect, constant("METHOD OPT")
  DECLARE dpl_num_attempts = vc WITH protect, constant("NUM ATTEMPTS")
  DECLARE dpl_dm_sql_id = vc WITH protect, constant("DM_SQL_ID")
  DECLARE dpl_script_name = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query_nbr = vc WITH protect, constant("QUERY_NBR")
  DECLARE dpl_query_nbr_text = vc WITH protect, constant("QUERY_NBR_TEXT")
  DECLARE dpl_sqltext_hash_value = vc WITH protect, constant("SQLTEXT_HASH_VALUE")
  DECLARE dpl_host_name = vc WITH protect, constant("HOST NAME")
  DECLARE dpl_inst_name = vc WITH protect, constant("INSTANCE NAME")
  DECLARE dpl_oracle_version = vc WITH protect, constant("ORACLE VERSION")
  DECLARE dpl_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpl_column = vc WITH protect, constant("COLUMN")
  DECLARE dpl_proc_queue_runner_type = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER TYPE")
  DECLARE dpl_dpq_id = vc WITH protect, constant("DM_PROCESS_QUEUE_ID")
  DECLARE dpl_level = vc WITH protect, constant("LEVEL")
  DECLARE dpl_step_number = vc WITH protect, constant("STEP_NUMBER")
  DECLARE dpl_step_name = vc WITH protect, constant("STEP_NAME")
  DECLARE dpl_install_mode = vc WITH protect, constant("INSTALL_MODE")
  DECLARE dpl_parent_step_name = vc WITH protect, constant("PARENT_STEP_NAME")
  DECLARE dpl_parent_level_number = vc WITH protect, constant("PARENT_LEVEL_NUMBER")
  DECLARE dpl_configuration_changed = vc WITH protect, constant("CONFIGURATION CHANGED")
  DECLARE dpl_instsched_used = vc WITH protect, constant("INSTALLATION SCHEDULER USED")
  DECLARE dpl_silmode = vc WITH protect, constant("SILENT MODE USED")
  DECLARE dpl_audsid = vc WITH protect, constant("AUDSID")
  DECLARE dpl_logfilemain = vc WITH protect, constant("LOGFILE:MAIN")
  DECLARE dpl_logfilerunner = vc WITH protect, constant("LOGFILE:RUNNER")
  DECLARE dpl_logfilebackground = vc WITH protect, constant("LOGFILE:BACKGROUND")
  DECLARE dpl_logfilemonitor = vc WITH protect, constant("LOGFILE:MONITOR")
  DECLARE dpl_unattended = vc WITH protect, constant("UNATTENDED_IND")
  DECLARE dpl_itinerary_key = vc WITH protect, constant("ITINERARY_KEY")
  DECLARE dpl_report = vc WITH protect, constant("REPORT")
  DECLARE dpl_actionreq = vc WITH protect, constant("ACTIONREQ")
  DECLARE dpl_progress = vc WITH protect, constant("PROGRESS")
  DECLARE dpl_warning = vc WITH protect, constant("WARNING")
  DECLARE dpl_execution_dpe_id = vc WITH protect, constant("EXECUTION_DPE_ID")
  DECLARE dpl_itinerary_dpe_id = vc WITH protect, constant("ITINERARY_DPE_ID")
  DECLARE dpl_itinerary_key_name = vc WITH protect, constant("ITINERARY_KEY_NAME")
  DECLARE dpl_audit_name = vc WITH protect, constant("AUDIT_NAME")
  DECLARE dpl_audit_type = vc WITH protect, constant("AUDIT_TYPE")
  DECLARE dpl_sample = vc WITH protect, constant("SAMPLE")
  DECLARE dpl_drivergen_runner = vc WITH protect, constant("DM2_ADS_DRIVER_GEN:AUDSID")
  DECLARE dpl_childest_runner = vc WITH protect, constant("DM2_ADS_CHILDEST_GEN:AUDSID")
  DECLARE dpl_ads_runner = vc WITH protect, constant("DM2_ADS_RUNNER:AUDSID")
  DECLARE dpl_byconfig = vc WITH protect, constant("BYCONFIG")
  DECLARE dpl_full = vc WITH protect, constant("ALL")
  DECLARE dpl_interval = vc WITH protect, constant("EVERYNTH")
  DECLARE dpl_intervalpct = vc WITH protect, constant("EVERYNTHPCT")
  DECLARE dpl_recent = vc WITH protect, constant("RECENT")
  DECLARE dpl_none = vc WITH protect, constant("NONE")
  DECLARE dpl_custom = vc WITH protect, constant("CUSTOM")
  DECLARE dpl_static = vc WITH protect, constant("STATIC")
  DECLARE dpl_nomove = vc WITH protect, constant("NOMOVE")
  DECLARE dpl_multiple = vc WITH protect, constant("MULTIPLE")
  DECLARE dpl_driverkeygen = vc WITH protect, constant("DRIVERKEYGEN")
  DECLARE dpl_childestgen = vc WITH protect, constant("CHILDESTGEN")
  DECLARE dpl_define = vc WITH protect, constant("DEFINE")
  DECLARE dpl_invalid_schema = vc WITH protect, constant("INVALID - SCHEMA")
  DECLARE dpl_invalid_stats = vc WITH protect, constant("INVALID - STATS")
  DECLARE dpl_invalid_table = vc WITH protect, constant("INVALID - TABLE")
  DECLARE dpl_invalid_data = vc WITH protect, constant("INVALID - NO SAMPLE METADATA")
  DECLARE dpl_custom_table = vc WITH protect, constant("CUSTOM TABLE")
  DECLARE dpl_new_table = vc WITH protect, constant("NEW TABLE")
  DECLARE dpl_ready = vc WITH protect, constant("READY")
  DECLARE dpl_needsbuild = vc WITH protect, constant("NEEDSBUILD")
  DECLARE dpl_incomplete = vc WITH protect, constant("INCOMPLETE")
  DECLARE dpl_new = vc WITH protect, constant("NEW")
  DECLARE dpl_config_extract_id = vc WITH protect, constant("CONFIG_EXTRACT_ID")
  DECLARE dpl_dynselect_holder = vc WITH protect, constant("<<DYNBYCONFIG>>")
  DECLARE dpl_tgtdblink_holder = vc WITH protect, constant("<<TGTDBLINK>>")
  DECLARE dpl_ads_metadata = vc WITH protect, constant("DM2_ADS_METADATA")
  DECLARE dpl_ads_scramble_method = vc WITH protect, constant("DM2_SCRAMBLE_METHOD")
  DECLARE dpl_act = vc WITH protect, constant("ACTIVITY")
  DECLARE dpl_ref = vc WITH protect, constant("REFERENCE")
  DECLARE dpl_ref_mix = vc WITH protect, constant("REFERENCE-MIXED")
  DECLARE dpl_act_mix = vc WITH protect, constant("ACTIVITY-MIXED")
  DECLARE dpl_mix = vc WITH protect, constant("MIXED")
  DECLARE dpl_action = vc WITH protect, constant("ACTION")
  DECLARE dpl_grant_method = vc WITH protect, constant("GRANT METHOD")
  DECLARE dpl_script = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query = vc WITH protect, constant("QUERY NUMBER")
  DECLARE dpl_name = vc WITH protect, constant("USER NAME")
  DECLARE dpl_email = vc WITH protect, constant("EMAIL ADDRESS")
  DECLARE dpl_reason = vc WITH protect, constant("REASON FOR ACTION")
  DECLARE dpl_sr_nbr = vc WITH protect, constant("SR NUMBER")
  DECLARE dpl_sql_id = vc WITH protect, constant("SQL ID")
  DECLARE dpl_grant_exists = vc WITH protect, constant("GRANT EXISTS")
  DECLARE dpl_bl_exists = vc WITH protect, constant("BASELINE EXISTS")
  DECLARE dpl_grant_str = vc WITH protect, constant("GRANT OUTSTRING")
  DECLARE dpl_grant_cmd = vc WITH protect, constant("GRANT COMMAND")
  DECLARE dpl_bl_query_nbr = vc WITH protect, constant("BASELINE QUERY NUMBER")
  DECLARE dpl_bl_sql_handle = vc WITH protect, constant("BASELINE SQL HANDLE")
  DECLARE dpl_bl_sql_text = vc WITH protect, constant("BASELINE SQL TEXT")
  DECLARE dpl_bl_creator = vc WITH protect, constant("BASELINE CREATOR")
  DECLARE dpl_bl_desc = vc WITH protect, constant("BASELINE DESCRIPTION")
  DECLARE dpl_bl_enabled = vc WITH protect, constant("BASELINE ENABLED")
  DECLARE dpl_bl_accepted = vc WITH protect, constant("BASELINE ACCEPTED")
  DECLARE dpl_bl_plan_name = vc WITH protect, constant("BASELINE PLAN NAME")
  DECLARE dpl_bl_created = vc WITH protect, constant("BASELINE CREATED DT/TM")
  DECLARE dpl_bl_last_mod = vc WITH protect, constant("BASELINE LAST MODIFIED DT/TM")
  DECLARE dpl_bl_last_exec = vc WITH protect, constant("BASELINE LAST EXECUTED DT/TM")
 ENDIF
 SUBROUTINE dm2_push_cmd(sbr_dpcstr,sbr_cmd_end)
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_cmd executing: ",sbr_dpcstr))
    CALL echo("*")
   ENDIF
   CALL parser(sbr_dpcstr,1)
   SET dm_err->tempstr = concat(dm_err->tempstr," ",sbr_dpcstr)
   IF (sbr_cmd_end=1)
    IF ((dm_err->err_ind=0))
     IF (check_error(concat("dm2_push_cmd executing: ",dm_err->tempstr))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->tempstr = " "
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->tempstr = " "
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_push_dcl(sbr_dpdstr)
   DECLARE dpd_stat = i4 WITH protect, noconstant(0)
   DECLARE newstr = vc WITH protect
   DECLARE strloc = i4 WITH protect, noconstant(0)
   DECLARE temp_file = vc WITH protect, noconstant(" ")
   DECLARE str2 = vc WITH protect, noconstant(" ")
   DECLARE posx = i4 WITH protect, noconstant(0)
   DECLARE sql_warn_ind = i2 WITH protect, noconstant(0)
   DECLARE dpd_disp_dcl_err_ind = i2 WITH protect, noconstant(1)
   IF ((validate(dm_err->disp_dcl_err_ind,- (1))=- (1))
    AND (validate(dm_err->disp_dcl_err_ind,- (2))=- (2)))
    SET dpd_disp_dcl_err_ind = 1
   ELSE
    SET dpd_disp_dcl_err_ind = dm_err->disp_dcl_err_ind
    SET dm_err->disp_dcl_err_ind = 1
   ENDIF
   IF ((dm_err->errfile="NONE"))
    IF (get_unique_file("dm2_",".err")=0)
     RETURN(0)
    ELSE
     SET dm_err->errfile = dm_err->unique_fname
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AXP")))
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Cannot support additional piping outside of push dcl subroutine"
     SET dm_err->eproc = "Check push dcl command for piping character (>)."
     RETURN(0)
    ENDIF
    SET newstr = concat("pipe ",sbr_dpdstr," > ccluserdir:",dm_err->errfile)
   ELSE
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET strlength = size(trim(sbr_dpdstr))
     IF (findstring("2>&1",sbr_dpdstr) > 0)
      SET temp_file = build(substring((strloc+ 1),((strlength - strloc) - 4),sbr_dpdstr))
     ELSE
      SET temp_file = build(substring((strloc+ 1),(strlength - strloc),sbr_dpdstr))
     ENDIF
     SET newstr = sbr_dpdstr
    ELSE
     SET newstr = concat(sbr_dpdstr," > ",dm2_install_schema->ccluserdir,dm_err->errfile," 2>&1")
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_dcl executing: ",newstr))
    CALL echo("*")
   ENDIF
   CALL dcl(newstr,size(newstr),dpd_stat)
   IF (dpd_stat=0)
    IF (temp_file > " ")
     CASE (dm2_sys_misc->cur_os)
      OF "WIN":
       SET str2 = concat("copy ",temp_file," ",dm_err->errfile)
      ELSE
       IF ((dm2_sys_misc->cur_os != "AXP"))
        SET str2 = concat("cp ",temp_file," ",dm_err->errfile)
       ENDIF
     ENDCASE
     CALL dcl(str2,size(str2),dpd_stat)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (sql_warn_ind=true)
     SET dm_err->user_action = "NONE"
     SET dm_err->eproc = concat("Warning Encountered:",dm_err->errtext)
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->disp_msg_emsg = dm_err->errtext
     SET dm_err->emsg = dm_err->disp_msg_emsg
     IF (dpd_disp_dcl_err_ind=1)
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",newstr)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
     ELSE
      IF ((dm_err->debug_flag > 1))
       CALL echo("Call dcl failed- error handling done by calling script")
      ENDIF
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(concat("PARSING THROUGH - ",dm_err->errfile))
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_unique_file(sbr_fprefix,sbr_fext)
   DECLARE guf_return_val = i4 WITH protect, noconstant(1)
   DECLARE fini = i2 WITH protect, noconstant(0)
   DECLARE fname = vc WITH protect
   DECLARE unique_tempstr = vc WITH protect
   WHILE (fini=0)
     IF ((((validate(systimestamp,- (999.00))=- (999.00))
      AND validate(systimestamp,999.00)=999.00) OR (validate(dm2_bypass_unique_file,- (1))=1)) )
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
     ELSEIF ((validate(systimestamp,- (999.00)) != - (999.00))
      AND validate(systimestamp,999.00) != 999.00
      AND (validate(dm2_bypass_unique_file,- (1))=- (1))
      AND (validate(dm2_bypass_unique_file,- (2))=- (2)))
      SET unique_tempstr = format(systimestamp,"hhmmsscccccc;;q")
     ENDIF
     SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
     IF (findfile(fname)=0)
      SET fini = 1
     ENDIF
   ENDWHILE
   IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",sbr_fext
     ))=1)
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(dm_err->user_action)
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSE
    SET dm_err->unique_fname = fname
    CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   ENDIF
   RETURN(guf_return_val)
 END ;Subroutine
 SUBROUTINE parse_errfile(sbr_errfile)
   SET dm_err->errtext = " "
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(sbr_errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     dm_err->errtext = build(dm_err->errtext,r.line)
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_error(sbr_ceprocess)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE disp_msg(sbr_demsg,sbr_dlogfile,sbr_derr_ind)
   DECLARE dm_txt = c132 WITH protect
   DECLARE dm_ecode = i4 WITH protect
   DECLARE dm_emsg = c132 WITH protect
   DECLARE dm_full_emsg = vc WITH protect
   DECLARE dm_eproc_length = i4 WITH protect
   DECLARE dm_full_emsg_length = i4 WITH protect
   DECLARE dm_user_action_length = i4 WITH protect
   IF (sbr_demsg="dm_err->disp_msg_emsg")
    SET dm_full_emsg = dm_err->disp_msg_emsg
   ELSE
    SET dm_full_emsg = sbr_demsg
   ENDIF
   SET dm_eproc_length = textlen(dm_err->eproc)
   SET dm_full_emsg_length = textlen(dm_full_emsg)
   SET dm_user_action_length = textlen(dm_err->user_action)
   IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET"))
    AND trim(sbr_dlogfile) != ""
    AND sbr_derr_ind IN (0, 1, 10))
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;3;m"
      IF (sbr_derr_ind=1)
       row + 1, "* Component Name:  ", curprog,
       row + 1, "* Process Description:  "
      ENDIF
      dm_txt = substring(beg_pos,end_pos,dm_err->eproc)
      WHILE (not_done=1)
        row + 1, col 0, dm_txt
        IF (end_pos > dm_eproc_length)
         not_done = 0
        ELSE
         beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
          eproc)
        ENDIF
      ENDWHILE
      IF (sbr_derr_ind=1)
       row + 1, "* Error Message:  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_full_emsg), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_full_emsg_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,
           dm_full_emsg)
         ENDIF
       ENDWHILE
      ENDIF
      IF ((dm_err->user_action != "NONE"))
       row + 1, "* Recommended Action(s):  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_err->user_action), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_user_action_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
           user_action)
         ENDIF
       ENDWHILE
      ENDIF
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
    SET dm_ecode = error(dm_emsg,1)
   ELSEIF (sbr_dlogfile != "DM2_LOGFILE_NOTSET")
    SET dm_ecode = 1
    SET dm_emsg = "Message couldn't write to log file since name passed in was invalid."
   ENDIF
   IF (dm_ecode > 0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  Writing message to log file."))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_emsg)))
    CALL echo("*")
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   IF (sbr_derr_ind=1)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  ",dm_err->eproc))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_full_emsg)))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSEIF (sbr_derr_ind IN (0, 20))
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(dm_err->eproc)
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   SET dm_err->user_action = "NONE"
 END ;Subroutine
 SUBROUTINE init_logfile(sbr_logfile,sbr_header_msg)
   DECLARE init_return_val = i4 WITH protect, noconstant(1)
   IF (sbr_logfile != "NONE"
    AND trim(sbr_logfile) != "")
    SELECT INTO value(sbr_logfile)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;;m", row + 1, sbr_header_msg,
      row + 1, row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
    IF (check_error(concat("Creating log file ",trim(sbr_logfile)))=1)
     SET init_return_val = 0
    ELSE
     SET dm_err->eproc = concat("Log file created.  Log file name is: ",sbr_logfile)
     CALL disp_msg(" ",sbr_logfile,0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Creating log file ",trim(sbr_logfile))
    SET dm_err->emsg = concat("Log file name passed is invalid.  Name passed in is: ",trim(
      sbr_logfile))
    SET init_return_val = 0
   ENDIF
   IF (init_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   RETURN(init_return_val)
 END ;Subroutine
 SUBROUTINE check_logfile(sbr_lprefix,sbr_lext,sbr_hmsg)
   IF ((dm_err->logfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
    IF ((dm_err->debug_flag > 9))
     SET trace = echoprogsub
     IF (((currev > 8) OR (currev=8
      AND currevminor >= 1)) )
      SET trace = echosub
     ENDIF
    ENDIF
    IF (get_unique_file(sbr_lprefix,sbr_lext)=0)
     RETURN(0)
    ENDIF
    SET dm_err->logfile = dm_err->unique_fname
    IF (init_logfile(dm_err->logfile,sbr_hmsg)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_prg_maint("BEGIN")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE final_disp_msg(sbr_log_prefix)
   DECLARE plength = i2
   SET plength = textlen(sbr_log_prefix)
   IF (dm2_prg_maint("END")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->err_ind=0))
    IF (cnvtlower(sbr_log_prefix)=substring(1,plength,dm_err->logfile))
     SET dm_err->eproc = concat(dm_err->eproc,"  Log file is ccluserdir:",dm_err->logfile)
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_set_autocommit(sbr_dsa_flag)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_prg_maint(sbr_maint_type)
   IF ( NOT (cnvtupper(trim(sbr_maint_type,3)) IN ("BEGIN", "END")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid maintenance type"
    SET dm_err->eproc = "Performing program maintenance"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("********************************************************")
    CALL echo("* CCL current resource usage statistics                *")
    CALL echo("********************************************************")
    CALL trace(7)
   ENDIF
   IF (cnvtupper(trim(sbr_maint_type,3))="BEGIN")
    IF ((program_stack_rs->cnt < dcr_max_stack_size))
     SET program_stack_rs->cnt = (program_stack_rs->cnt+ 1)
     SET program_stack_rs->qual[program_stack_rs->cnt].name = curprog
    ENDIF
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    SET dm2_install_schema->curprog = curprog
   ELSE
    FOR (i = 0 TO (program_stack_rs->cnt - 1))
      IF ((program_stack_rs->qual[(program_stack_rs->cnt - i)].name=curprog))
       FOR (j = (program_stack_rs->cnt - i) TO program_stack_rs->cnt)
         SET program_stack_rs->qual[j].name = ""
       ENDFOR
       SET program_stack_rs->cnt = ((program_stack_rs->cnt - i) - 1)
       SET i = program_stack_rs->cnt
      ENDIF
    ENDFOR
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm2_get_program_stack(null))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_set_inhouse_domain(null)
   DECLARE dsid_tbl_ind = c1 WITH protect, noconstant(" ")
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET dm_err->eproc = "Inhouse Domain Detected."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET inhouse_misc->inhouse_domain = 1
    RETURN(1)
   ENDIF
   IF ((inhouse_misc->inhouse_domain=- (1)))
    SET dm_err->eproc = "Determining whether table dm_info exists"
    SET dsid_tbl_ind = dm2_table_exists("DM_INFO")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (dsid_tbl_ind="F")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="INHOUSE DOMAIN"
      WITH nocounter
     ;end select
     IF (check_error("Determine if process running in an in-house domain")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (curqual=1)
      SET inhouse_misc->inhouse_domain = 1
     ELSE
      SET inhouse_misc->inhouse_domain = 0
     ENDIF
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_table_exists(dte_table_name)
  SELECT INTO "nl:"
   FROM dm2_dba_tab_columns dutc
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.owner=value(currdbuser)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual > 0
    AND checkdic(cnvtupper(dte_table_name),"T",0)=2)
    RETURN("F")
   ELSE
    RETURN("N")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_table_and_ccldef_exists(dtace_table_name,dtace_found_ind)
   SET dtace_found_ind = 0
   SELECT INTO "nl:"
    FROM dba_tab_cols dtc
    WHERE dtc.table_name=trim(cnvtupper(dtace_table_name))
     AND dtc.owner=value(currdbuser)
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking if ",trim(cnvtupper(dtace_table_name)),
     " table and ccl def exists"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (curqual > 0
     AND checkdic(cnvtupper(dtace_table_name),"T",0)=2)
     SET dtace_found_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_table_column_exists(dtce_owner,dtce_table_name,dtce_column_name,dtce_col_chk_ind,
  dtce_coldef_chk_ind,dtce_ccldef_mode,dtce_col_fnd_ind,dtce_coldef_fnd_ind,dtce_data_type)
   DECLARE dtce_type = vc WITH protect, noconstant("")
   DECLARE dtce_len = i4 WITH protect, noconstant(0)
   SET dtce_col_fnd_ind = 0
   SET dtce_coldef_fnd_ind = 0
   SET dtce_data_type = ""
   IF (dtce_col_chk_ind=1)
    SELECT INTO "nl:"
     FROM dba_tab_cols dtc
     WHERE dtc.owner=trim(dtce_owner)
      AND dtc.table_name=trim(dtce_table_name)
      AND dtc.column_name=trim(dtce_column_name)
     WITH nocounter
    ;end select
    IF (check_error(concat("Checking if ",trim(dtce_owner),".",trim(dtce_table_name),".",
      trim(dtce_column_name)," exists"))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     IF (curqual > 0)
      SET dtce_col_fnd_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (dtce_coldef_chk_ind=1)
    IF (checkdic(cnvtupper(concat(dtce_table_name,".",dtce_column_name)),"A",0)=2)
     SET dtce_coldef_fnd_ind = 1
     IF (dtce_ccldef_mode=2)
      IF (((currev=8
       AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 81401)) OR (currev > 8
       AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 90201))) )
       CALL parser(concat(" set dtce_data_type = reflect(",dtce_table_name,".",dtce_column_name,
         ",1) go "),1)
       CALL parser(concat(" free range ",dtce_table_name," go "),1)
       SET dtce_len = cnvtint(cnvtalphanum(dtce_data_type,1))
       SET dtce_type = cnvtalphanum(dtce_data_type,2)
       IF (textlen(dtce_type)=2)
        SET dtce_type = substring(2,2,dtce_type)
       ENDIF
       SET dtce_data_type = concat(dtce_type,trim(cnvtstring(dtce_len)))
      ELSE
       SELECT INTO "nl:"
        FROM dtable t,
         dtableattr ta,
         dtableattrl tl
        WHERE t.table_name=cnvtupper(dtce_table_name)
         AND t.table_name=ta.table_name
         AND tl.attr_name=cnvtupper(dtce_column_name)
         AND tl.structtype="F"
         AND btest(tl.stat,11)=0
        DETAIL
         dtce_data_type = concat(tl.type,trim(cnvtstring(tl.len)))
        WITH nocounter
       ;end select
       IF (check_error(concat("Retrieving",trim(dtce_table_name),".",trim(dtce_column_name),
         " data type"))=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_disp_file(ddf_fname,ddf_desc)
   DECLARE ddf_row = i4 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="WIN"))
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL video(n)
    SET ddf_row = 3
    CALL box(1,1,5,132)
    CALL text(ddf_row,48,"***  REPORT GENERATED  ***")
    SET ddf_row = (ddf_row+ 4)
    CALL text(ddf_row,2,"The following report was generated in CCLUSERDIR... ")
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,5,concat("File Name:   ",trim(ddf_fname)))
    SET ddf_row = (ddf_row+ 1)
    CALL text(ddf_row,5,concat("Description: ",trim(ddf_desc)))
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,2,"Review report in CCLUSERDIR before continuing.")
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,2,"Enter 'C' to continue or 'Q' to quit:  ")
    CALL accept(ddf_row,41,"A;cu","C"
     WHERE curaccept IN ("C", "Q"))
    IF (curaccept="Q")
     CALL clear(1,1)
     SET message = nowindow
     SET dm_err->emsg = "User elected to quit from report prompt."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
   ELSE
    SET dm_err->eproc = concat("Displaying ",ddf_desc)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    FREE SET file_loc
    SET logical file_loc value(ddf_fname)
    FREE DEFINE rtl2
    DEFINE rtl2 "file_loc"
    SELECT INTO mine
     t.line
     FROM rtl2t t
     HEAD REPORT
      col 30,
      CALL print(ddf_desc), row + 1
     DETAIL
      col 0, t.line, row + 1
     FOOT REPORT
      row + 0
     WITH nocounter, maxcol = 5000
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl2
    FREE SET file_loc
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_program_stack(null)
   DECLARE stack = vc WITH protect, noconstant("PROGRAM STACK:")
   FOR (i = 1 TO (program_stack_rs->cnt - 1))
     SET stack = build(stack,program_stack_rs->qual[i].name,"->")
   ENDFOR
   IF (program_stack_rs->cnt)
    RETURN(build(stack,program_stack_rs->qual[program_stack_rs->cnt].name))
   ELSE
    RETURN(stack)
   ENDIF
 END ;Subroutine
 SUBROUTINE dpl_upd_dped_last_status(dudls_event_id,dudls_text,dudls_number,dudls_date)
   DECLARE dudls_emsg = vc WITH protect, noconstant(dm_err->emsg)
   DECLARE dudls_eproc = vc WITH protect, noconstant(dm_err->eproc)
   DECLARE dudls_err_ind = i4 WITH protect, noconstant(dm_err->err_ind)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = 0
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=0))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Existance check for Event_Id",build(dudls_event_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event d
    WHERE d.dm_process_event_id=dudls_event_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dm_err->eproc =
    "Unable to find the event_id in DM_PROCESS_EVENT. Bypass inserting of new details."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   CALL dm2_process_log_add_detail_text("LAST_STATUS_MESSAGE",dudls_text)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = dudls_date
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = dudls_number
   CALL dm2_process_log_dtl_row(dudls_event_id,1)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = dudls_err_ind
    SET dm_err->eproc = dudls_eproc
    SET dm_err->emsg = dudls_emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_ui_chk(duc_process_name)
   DECLARE duc_event_col_exists = i2 WITH protect, noconstant(0)
   DECLARE duc_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_data_type = vc WITH protect, noconstant("")
   IF ((dm2_process_event_rs->ui_allowed_ind >= 0)
    AND currdbuser="V500"
    AND (dm2_process_rs->dbase_name=currdbname))
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Unattended install previously set:",build(dm2_process_event_rs->ui_allowed_ind
        )))
    ENDIF
    RETURN(1)
   ELSE
    IF ( NOT (currdbuser IN ("V500", "STATS", "CERN_DBSTATS")))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     SET dm2_process_rs->table_exists_ind = 0
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed. Current user is not V500. Current user is ",
        currdbuser))
     ENDIF
     RETURN(1)
    ENDIF
    SET dm2_process_event_rs->ui_allowed_ind = 1
    IF ( NOT (duc_process_name IN (dpl_notification, dpl_package_install, dpl_install_runner,
    dpl_background_runner, dpl_install_monitor)))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed for ",duc_process_name))
     ENDIF
    ENDIF
    IF ((((dm2_process_rs->table_exists_ind=0)) OR ((dm2_process_rs->dbase_name != currdbname))) )
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     SET duc_event_col_exists = 0
     SET duc_col_oradef_ind = 0
     SET dm_err->eproc = "Existance check for INSTALL_PLAN_ID and DETAIL_DT_TM"
     SELECT INTO "nl:"
      FROM dm2_user_tab_cols utc
      WHERE utc.table_name IN ("DM_PROCESS_EVENT", "DM_PROCESS_EVENT_DTL")
       AND utc.column_name IN ("INSTALL_PLAN_ID", "DETAIL_DT_TM")
      DETAIL
       IF (utc.table_name="DM_PROCESS_EVENT"
        AND utc.column_name="INSTALL_PLAN_ID")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ELSEIF (utc.table_name="DM_PROCESS_EVENT_DTL"
        AND utc.column_name="DETAIL_DT_TM")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (duc_col_oradef_ind=2)
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT","INSTALL_PLAN_ID",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT_DTL","DETAIL_DT_TM",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
     ENDIF
     IF (duc_event_col_exists < 2)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required schema does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ELSE
      SET dm2_process_rs->table_exists_ind = 1
     ENDIF
    ENDIF
    IF ((dm2_process_rs->table_exists_ind=1))
     SET dm_err->eproc = "Existance check for DM_CLINICAL_SEQ"
     SELECT INTO "nl:"
      FROM dba_sequences
      WHERE sequence_owner="V500"
       AND sequence_name="DM_CLINICAL_SEQ"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required sequence does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Unattended install allowed:",build(dm2_process_event_rs->ui_allowed_ind)))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_dtl_row(dpldr_event_log_id,ignore_errors)
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_process_event_rs)
   ENDIF
   IF ((dm2_process_event_rs->detail_cnt > 0))
    SET dm_err->eproc = "Removing logging detail from dm_process_event_dtl."
    DELETE  FROM dm_process_event_dtl dtl,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dtl.seq = 0
     PLAN (d)
      JOIN (dtl
      WHERE dtl.dm_process_event_id=dpldr_event_log_id
       AND (dtl.detail_type=dm2_process_event_rs->details[d.seq].detail_type))
     WITH nocounter
    ;end delete
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
    INSERT  FROM dm_process_event_dtl dped,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
      dpldr_event_log_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
      dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
      dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
       dm2_process_event_rs->details[d.seq].detail_date)
     PLAN (d)
      JOIN (dped)
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_row(process_name,action_type,prev_log_id,ignore_errors)
   IF (dpl_ui_chk(process_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   DECLARE dplr_search = i4 WITH protect, noconstant(0)
   DECLARE dplr_event_id = f8 WITH protect, noconstant(prev_log_id)
   DECLARE dplr_stack = vc WITH protect, constant(dm2_get_program_stack(null))
   DECLARE dplr_process_name = vc WITH protect, constant(evaluate(dm2_process_rs->process_name,"",
     process_name,dm2_process_rs->process_name))
   DECLARE dplr_program_details = vc WITH protect, constant(curprog)
   DECLARE dplr_search_string = vc WITH protect, constant(build(dplr_process_name,"#",curprog,"#",
     action_type))
   SET dm2_process_rs->process_name = dplr_process_name
   IF ( NOT (dm2_process_rs->filled_ind))
    SET dm_err->eproc = "Querying for list of logged processes from dm_process."
    SELECT INTO "nl:"
     FROM dm_process dp
     HEAD REPORT
      dm2_process_rs->filled_ind = 1, dm2_process_rs->cnt = 0, stat = alterlist(dm2_process_rs->qual,
       0)
     DETAIL
      dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
      IF (mod(dm2_process_rs->cnt,10)=1)
       stat = alterlist(dm2_process_rs->qual,(dm2_process_rs->cnt+ 9))
      ENDIF
      dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dp.dm_process_id, dm2_process_rs->
      qual[dm2_process_rs->cnt].process_name = dp.process_name, dm2_process_rs->qual[dm2_process_rs->
      cnt].program_name = dp.program_name,
      dm2_process_rs->qual[dm2_process_rs->cnt].action_type = dp.action_type, dm2_process_rs->qual[
      dm2_process_rs->cnt].search_string = build(dp.process_name,"#",dp.program_name,"#",dp
       .action_type)
     FOOT REPORT
      stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (prev_log_id=0)
    IF ( NOT (assign(dplr_search,locateval(dplr_search,1,dm2_process_rs->cnt,dplr_search_string,
      dm2_process_rs->qual[dplr_search].search_string))))
     SET dm_err->eproc = "Getting next sequence for new process from dm_clinical_seq."
     SELECT INTO "nl:"
      id = seq(dm_clinical_seq,nextval)
      FROM dual
      DETAIL
       dm2_process_rs->dm_process_id = id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Inserting new process into dm_process."
     INSERT  FROM dm_process dp
      SET dp.dm_process_id = dm2_process_rs->dm_process_id, dp.process_name = dm2_process_rs->
       process_name, dp.program_name = curprog,
       dp.action_type = action_type
      WITH nocounter
     ;end insert
     IF (dpl_check_error(null))
      RETURN((1 - dm_err->err_ind))
     ENDIF
     COMMIT
     SET dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
     SET stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     SET dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dm2_process_rs->dm_process_id
     SET dm2_process_rs->qual[dm2_process_rs->cnt].process_name = dm2_process_rs->process_name
     SET dm2_process_rs->qual[dm2_process_rs->cnt].program_name = curprog
     SET dm2_process_rs->qual[dm2_process_rs->cnt].action_type = action_type
     SET dm2_process_rs->qual[dm2_process_rs->cnt].search_string = dplr_search_string
     SET dplr_search = dm2_process_rs->cnt
    ENDIF
    SET dm2_process_rs->dm_process_id = dm2_process_rs->qual[dplr_search].dm_process_id
    SET dm_err->eproc = "Getting next sequence for log row."
    SELECT INTO "nl:"
     id = seq(dm_clinical_seq,nextval)
     FROM dual
     DETAIL
      dplr_event_id = id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting logging row into dm_process_event."
    INSERT  FROM dm_process_event dpe
     SET dpe.dm_process_event_id = dplr_event_id, dpe.install_plan_id = dm2_process_event_rs->
      install_plan_id, dpe.dm_process_id = dm2_process_rs->dm_process_id,
      dpe.program_stack = dplr_stack, dpe.program_details = dplr_program_details, dpe.begin_dt_tm =
      IF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      ,
      dpe.username = dpl_username, dpe.event_status = dm2_process_event_rs->status, dpe.message_txt
       = dm2_process_event_rs->message
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    IF (action_type=dpl_auditlog
     AND process_name IN (dpl_package_install, dpl_install_monitor, dpl_background_runner,
    dpl_install_runner))
     IF ((dir_ui_misc->dm_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_execution_dpe_id,dir_ui_misc->dm_process_event_id)
     ENDIF
     IF ((dm2_process_event_rs->itinerary_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_itinerary_dpe_id,dm2_process_event_rs->
       itinerary_process_event_id)
     ENDIF
     IF (trim(dm2_process_event_rs->itinerary_key) > "")
      CALL dm2_process_log_add_detail_text(dpl_itinerary_key_name,dm2_process_event_rs->itinerary_key
       )
     ENDIF
    ENDIF
    IF ((dm2_process_event_rs->detail_cnt > 0))
     SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
     INSERT  FROM dm_process_event_dtl dped,
       (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
      SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
       dplr_event_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
       dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
       dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
        dm2_process_event_rs->details[d.seq].detail_date)
      PLAN (d)
       JOIN (dped)
      WITH nocounter
     ;end insert
    ENDIF
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Updating existing logging row in dm_process_event."
    UPDATE  FROM dm_process_event dpe
     SET dpe.end_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->end_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.end_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->end_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->end_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      , dpe.begin_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.begin_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSEIF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(curdate,curtime3)
      ELSE dpe.begin_dt_tm
      ENDIF
      , dpe.event_status = evaluate(dm2_process_event_rs->status,"",dpe.event_status,
       dm2_process_event_rs->status),
      dpe.message_txt = evaluate(dm2_process_event_rs->message,"",dpe.message_txt,
       dm2_process_event_rs->message), dpe.program_details = dplr_program_details
     WHERE dpe.dm_process_event_id=dplr_event_id
     WITH nocounter
    ;end update
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->dm_process_event_id = dplr_event_id
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = 0
   SET dm2_process_event_rs->begin_dt_tm = 0
   SET dm2_process_event_rs->install_plan_id = 0.0
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_check_error(null)
   IF (check_error(dm_err->eproc))
    ROLLBACK
    IF ( NOT (ignore_errors))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     SET dm_err->err_ind = 0
     CALL echo("The above error is ignorable.")
    ENDIF
   ENDIF
   IF (dm_err->err_ind)
    SET dm2_process_event_rs->status = ""
    SET dm2_process_event_rs->message = ""
    SET dm2_process_event_rs->detail_cnt = 0
    SET stat = alterlist(dm2_process_event_rs->details,0)
    SET dm2_process_event_rs->dm_process_event_id = 0.0
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_text(detail_type,detail_text)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = detail_text
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_date(detail_type,detail_date)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = detail_date
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_number(detail_type,detail_number)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = detail_number
 END ;Subroutine
 DECLARE ddf_autosuccess_init(null) = i2
 DECLARE ddf_check_lock(dcl_process=vc,dcl_object=vc,dcl_process_code=i2,dcl_lock_available_ind=i2(
   ref)) = i2
 DECLARE ddf_get_lock(dgl_process=vc,dgl_object=vc,dgl_process_code=i2,dgl_lock_obtained_ind=i2(ref))
  = i2
 DECLARE ddf_release_lock(drl_process=vc,drl_object=vc,drl_process_code=i2) = i2
 DECLARE ddf_get_audsid_list(dgal_process=vc,dgal_object=vc,dgal_process_code=i2) = i2
 DECLARE ddf_clean_dpq(dcd_process_type=vc,dcd_obj_name=vc) = i2
 DECLARE ddf_clean_dst(dcd_statid=vc) = i2
 DECLARE ddf_clean_dpe(dcd_process_name=vc,dcd_program_name=vc) = i2
 DECLARE ddf_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE ddf_get_publish_retry(dcp_retry_ceiling=i2(ref)) = i2
 DECLARE ddf_check_wait_pref(dcwp_pref_set_ind=i2(ref),dcwp_adb_ind=i2) = i2
 DECLARE ddf_get_object_id(dgoi_owner=vc,dgoi_table_name=vc,dgoi_object_id=f8(ref)) = i2
 DECLARE ddf_get_context_pkg_data(null) = i2
 DECLARE ddf_context_lock_maint(dclm_mode=vc,dclm_process=vc,dclm_process_code=i2,dclm_owner=vc,
  dclm_table_name=vc,
  dclm_object_id=f8,dclm_lock_ind=i2(ref)) = i2
 IF (validate(dgdt_prefs->in_object_type,"X")="X"
  AND validate(dgdt_prefs->in_object_type,"Y")="Y")
  FREE RECORD dgdt_prefs
  RECORD dgdt_prefs(
    1 in_object_type = vc
    1 in_object_owner = vc
    1 in_object_name = vc
    1 in_table_name = vc
    1 in_mode = vc
    1 in_object_id = vc
    1 table_owner = vc
    1 object_exists_ind = i2
    1 custom_prefs = vc
    1 di_exclusion = vc
    1 autosuccess_ind = i2
    1 context_lock_ind = i2
    1 context_lock_schema = vc
    1 method_opt_size254_ind_def = vc
    1 method_opt_size254_nonind_def = vc
    1 est_pct = vc
    1 est_pct_idx = vc
    1 method_opt = vc
    1 method_opt_dped = vc
    1 degree = vc
    1 degree_idx = vc
    1 cascade = vc
    1 publish = vc
    1 wait_time_pref_active = i2
    1 stale_pct = vc
    1 block_sample = vc
    1 granularity = vc
    1 granularity_idx = vc
    1 no_invalidate = vc
    1 no_invalidate_idx = vc
    1 di_est_pct = vc
    1 di_est_pct_idx = vc
    1 di_method_opt = vc
    1 di_degree = vc
    1 di_degree_idx = vc
    1 di_cascade = vc
    1 di_publish = vc
    1 di_stale_pct = vc
    1 di_block_sample = vc
    1 di_granularity = vc
    1 di_granularity_idx = vc
    1 di_no_invalidate = vc
    1 di_no_invalidate_idx = vc
    1 col_cnt = i2
    1 cols[*]
      2 column_name = vc
      2 data_type = vc
      2 method_opt = vc
      2 di_method_opt = vc
  )
  SET dgdt_prefs->autosuccess_ind = - (1)
  SET dgdt_prefs->context_lock_ind = - (1)
  SET dgdt_prefs->context_lock_schema = "DM2NOTSET"
  SET dgdt_prefs->in_object_type = "DM2NOTSET"
  SET dgdt_prefs->in_object_owner = "DM2NOTSET"
  SET dgdt_prefs->in_object_name = "DM2NOTSET"
  SET dgdt_prefs->in_table_name = "DM2NOTSET"
  SET dgdt_prefs->custom_prefs = "DM2NOTSET"
  SET dgdt_prefs->di_exclusion = "DM2NOTSET"
  SET dgdt_prefs->est_pct = "DM2NOTSET"
  SET dgdt_prefs->method_opt = "DM2NOTSET"
  SET dgdt_prefs->degree = "DM2NOTSET"
  SET dgdt_prefs->cascade = "DM2NOTSET"
  SET dgdt_prefs->publish = "DM2NOTSET"
  SET dgdt_prefs->stale_pct = "DM2NOTSET"
  SET dgdt_prefs->block_sample = "DM2NOTSET"
  SET dgdt_prefs->granularity = "DM2NOTSET"
  SET dgdt_prefs->no_invalidate = "DM2NOTSET"
  SET dgdt_prefs->est_pct_idx = "DM2NOTSET"
  SET dgdt_prefs->degree_idx = "DM2NOTSET"
  SET dgdt_prefs->granularity_idx = "DM2NOTSET"
  SET dgdt_prefs->no_invalidate_idx = "DM2NOTSET"
  SET dgdt_prefs->di_est_pct = "DM2NOTSET"
  SET dgdt_prefs->di_method_opt = "DM2NOTSET"
  SET dgdt_prefs->di_degree = "DM2NOTSET"
  SET dgdt_prefs->di_cascade = "DM2NOTSET"
  SET dgdt_prefs->di_publish = "DM2NOTSET"
  SET dgdt_prefs->di_stale_pct = "DM2NOTSET"
  SET dgdt_prefs->di_block_sample = "DM2NOTSET"
  SET dgdt_prefs->di_granularity = "DM2NOTSET"
  SET dgdt_prefs->di_no_invalidate = "DM2NOTSET"
  SET dgdt_prefs->di_est_pct_idx = "DM2NOTSET"
  SET dgdt_prefs->di_degree_idx = "DM2NOTSET"
  SET dgdt_prefs->di_granularity_idx = "DM2NOTSET"
  SET dgdt_prefs->di_no_invalidate_idx = "DM2NOTSET"
 ENDIF
 IF (validate(ddf_audsids->cnt,0)=0
  AND validate(ddf_audsids->cnt,1)=1)
  FREE RECORD ddf_audsids
  RECORD ddf_audsids(
    1 cnt = i4
    1 active_audsid_str = vc
    1 active_audsid_cnt = i4
    1 qual[*]
      2 audsid = vc
      2 active_ind = i2
  )
 ENDIF
 SUBROUTINE ddf_autosuccess_init(null)
   DECLARE ddfai_info_exists = i2 WITH protect, noconstant(0)
   DECLARE ddfai_cclversion = i4 WITH protect, constant((((cnvtint(currev) * 10000)+ (cnvtint(
     currevminor) * 100))+ cnvtint(currevminor2)))
   IF ((dgdt_prefs->autosuccess_ind=- (1)))
    IF (ddfai_cclversion < 80506)
     SET dm_err->eproc = "CCL Version 8.5.6 or higher required to run dm2*dbstats* scripts."
     SET dgdt_prefs->autosuccess_ind = 1
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Check for DM_INFO CCL definition"
    IF (checkdic("DM_INFO","T",0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "CCL Definition not found for DM_INFO for statistics processing. Auto-successing..."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Check for DM_INFO table existance"
    SELECT INTO "nl:"
     FROM dba_objects d
     WHERE d.object_name="DM_INFO"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No DM_INFO object found for statistics processing. Auto-successing..."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdbms_version->level1 < 11))
     SET dm_err->eproc = "Oracle version < 11g, Auto-successing...."
     SET dgdt_prefs->autosuccess_ind = 1
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_audsid_list(dgal_process,dgal_object,dgal_process_code)
   DECLARE dgal_audsid_list = vc WITH protect, noconstant("")
   DECLARE dgal_str = vc WITH protect, noconstant("")
   DECLARE dgal_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dgal_num = i4 WITH protect, noconstant(1)
   SET ddf_audsids->cnt = 0
   SET ddf_audsids->active_audsid_str = ""
   SET ddf_audsids->active_audsid_cnt = 0
   SET stat = alterlist(ddf_audsids->qual,ddf_audsids->cnt)
   SET dm_err->eproc = concat("Getting list of audsids from dm_info for ",dgal_process,":",
    dgal_object)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=cnvtupper(dgal_process)
     AND di.info_name=patstring(cnvtupper(dgal_object))
     AND di.info_number=dgal_process_code
    DETAIL
     dgal_audsid_list = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    WHILE (dgal_str != dgal_notfnd)
     SET dgal_str = piece(dgal_audsid_list,",",dgal_num,dgal_notfnd)
     IF (dgal_str != dgal_notfnd)
      SET ddf_audsids->cnt = (ddf_audsids->cnt+ 1)
      SET stat = alterlist(ddf_audsids->qual,ddf_audsids->cnt)
      SET ddf_audsids->qual[ddf_audsids->cnt].audsid = dgal_str
      SET dgal_num = (dgal_num+ 1)
     ENDIF
    ENDWHILE
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddf_audsids)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_lock(dcl_process,dcl_object,dcl_process_code,dcl_lock_available_ind)
   DECLARE dcl_audsid_list = vc WITH protect, noconstant("")
   DECLARE dcl_num = i4 WITH protect, noconstant(0)
   SET dcl_lock_available_ind = 0
   IF (ddf_get_audsid_list(dcl_process,dcl_object,dcl_process_code)=0)
    RETURN(0)
   ENDIF
   IF ((ddf_audsids->cnt > 0))
    FOR (dcl_num = 1 TO ddf_audsids->cnt)
      IF (dar_get_appl_status(ddf_audsids->qual[dcl_num].audsid)="A")
       IF ((ddf_audsids->qual[dcl_num].audsid != currdbhandle))
        SET ddf_audsids->qual[dcl_num].active_ind = 1
        SET ddf_audsids->active_audsid_cnt = (ddf_audsids->active_audsid_cnt+ 1)
        IF ((ddf_audsids->active_audsid_cnt=1))
         SET ddf_audsids->active_audsid_str = ddf_audsids->qual[dcl_num].audsid
        ELSE
         SET ddf_audsids->active_audsid_str = concat(ddf_audsids->active_audsid_str,",",ddf_audsids->
          qual[dcl_num].audsid)
        ENDIF
       ENDIF
      ELSE
       SET ddf_audsids->qual[dcl_num].active_ind = 0
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(ddf_audsids)
    ENDIF
    IF ((ddf_audsids->active_audsid_cnt > 0))
     SET dm_err->eproc = "Update lock row in dm_info with active audsid list"
     UPDATE  FROM dm_info di
      SET di.info_char = ddf_audsids->active_audsid_str
      WHERE di.info_domain=cnvtupper(dcl_process)
       AND di.info_name=patstring(cnvtupper(dcl_object))
       AND di.info_number=dcl_process_code
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = "Delete lock row in dm_info"
     DELETE  FROM dm_info di
      WHERE di.info_domain=cnvtupper(dcl_process)
       AND di.info_name=patstring(cnvtupper(dcl_object))
       AND di.info_number=dcl_process_code
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dcl_lock_available_ind = 1
    ENDIF
    COMMIT
   ELSE
    SET dcl_lock_available_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_lock(dgl_process,dgl_object,dgl_process_code,dgl_lock_obtained_ind)
   SET dgl_lock_obtained_ind = 0
   SET dm_err->eproc = concat("Inserting/Updating dm_info run_lock row for ",dgl_process,":",
    dgl_object)
   CALL disp_msg(" ",dm_err->logfile,10)
   SET dm_err->eproc = "Merge lock row in dm_info with current audsid"
   MERGE INTO dm_info d
   USING DUAL ON (d.info_domain=cnvtupper(dgl_process)
    AND d.info_name=cnvtupper(dgl_object)
    AND d.info_number=dgl_process_code)
   WHEN MATCHED THEN
   (UPDATE
    SET d.info_char = concat(d.info_char,",",currdbhandle)
    WHERE 1=1
   ;end update
   )
   WHEN NOT MATCHED THEN
   (INSERT  FROM d
    (info_domain, info_name, info_number,
    info_char)
    VALUES(cnvtupper(dgl_process), cnvtupper(dgl_object), dgl_process_code,
    currdbhandle)
    WITH nocounter
   ;end insert
   )
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    IF (findstring("ORA-00001",dm_err->emsg) > 0)
     SET dm_err->eproc = concat(
      "Bypass Oracle error ORA-00001.  Will retry obtaining dm_info run_lock row for ",dgl_object)
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dgl_lock_obtained_ind = 0
     SET dm_err->err_ind = 0
     SET dm_err->emsg = " "
     RETURN(1)
    ELSE
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   IF (curqual > 0)
    SET dgl_lock_obtained_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_release_lock(drl_process,drl_object,drl_process_code)
   DECLARE drl_num = i4 WITH protect, noconstant(0)
   IF (ddf_get_audsid_list(drl_process,drl_object,drl_process_code)=0)
    RETURN(0)
   ENDIF
   IF ((ddf_audsids->cnt > 0))
    FOR (drl_num = 1 TO ddf_audsids->cnt)
      IF (dar_get_appl_status(ddf_audsids->qual[drl_num].audsid)="A"
       AND (ddf_audsids->qual[drl_num].audsid != currdbhandle))
       SET ddf_audsids->qual[drl_num].active_ind = 1
       SET ddf_audsids->active_audsid_cnt = (ddf_audsids->active_audsid_cnt+ 1)
       IF ((ddf_audsids->active_audsid_cnt=1))
        SET ddf_audsids->active_audsid_str = ddf_audsids->qual[drl_num].audsid
       ELSE
        SET ddf_audsids->active_audsid_str = concat(ddf_audsids->active_audsid_str,",",ddf_audsids->
         qual[drl_num].audsid)
       ENDIF
      ELSE
       SET ddf_audsids->qual[drl_num].active_ind = 0
      ENDIF
    ENDFOR
   ENDIF
   IF ((ddf_audsids->active_audsid_cnt > 0))
    SET dm_err->eproc = concat("Updating dm_info run_lock row for ",drl_process,":",drl_object)
    CALL disp_msg(" ",dm_err->logfile,10)
    UPDATE  FROM dm_info di
     SET di.info_char = ddf_audsids->active_audsid_str
     WHERE di.info_domain=cnvtupper(drl_process)
      AND di.info_name=cnvtupper(drl_object)
      AND di.info_number=drl_process_code
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Deleting dm_info run_lock row for ",drl_process,":",drl_object)
    CALL disp_msg(" ",dm_err->logfile,10)
    DELETE  FROM dm_info di
     WHERE di.info_domain=cnvtupper(drl_process)
      AND di.info_name=cnvtupper(drl_object)
      AND di.info_number=drl_process_code
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dpq(dcd_process_type,dcd_obj_name)
   SET dm_err->eproc = concat("Clean up dm_process_queue rows for ",dcd_process_type,":",dcd_obj_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = concat("Retrieve dm_process_queue rows for ",dcd_process_type,":",dcd_obj_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE dpq.process_type=dcd_process_type
     AND dpq.object_name=patstring(dcd_obj_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("No rows found in dm_process_queue for ",dcd_process_type,":",
     dcd_obj_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Non-Existent Objects: Clean up dm_process_queue rows for ",
    dcd_process_type,":",dcd_obj_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_process_queue q
    WHERE q.process_type=dcd_process_type
     AND q.object_name=patstring(dcd_obj_name)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dba_objects d
     WHERE d.owner=q.owner_name
      AND d.object_name=q.object_name
      AND d.object_type=q.object_type)))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   SET dm_err->eproc = concat("Successful Operations: Clean up dm_process_queue rows for ",
    dcd_process_type,":",dcd_obj_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_process_queue q
    WHERE q.process_type=dcd_process_type
     AND q.object_name=patstring(dcd_obj_name)
     AND q.process_status="SUCCESS"
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_stat_table d,
      dba_objects o
     WHERE sqlpassthru("d.statid like 'DMSTG%'")
      AND sqlpassthru("d.statid = decode(o.object_type,'INDEX','DMSTG_I'||o.object_id,'DMSTG_T')")
      AND d.c1=o.object_name
      AND d.c5=o.owner
      AND d.type IN ("T", "I")
      AND sqlpassthru("d.type = decode(o.object_type,'INDEX','I','TABLE','T')")
      AND o.object_type IN ("TABLE", "INDEX")
      AND q.process_type=dcd_process_type
      AND q.owner_name=d.c5
      AND q.object_type IN ("TABLE", "INDEX")
      AND q.object_name=d.c1
      AND q.owner_name=o.owner
      AND q.object_name=o.object_name
      AND q.object_type=o.object_type)))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dst(dcd_statid)
   FREE RECORD dst_list
   RECORD dst_list(
     1 cnt = i4
     1 qual[*]
       2 statid = vc
       2 obj_name = vc
       2 owner = vc
       2 obj_exists = i2
   )
   SET dm_err->eproc = concat("Clean up dm_stat_table rows for ",dcd_statid)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dcd_statid="GOLDAVG")
    SET dm_err->eproc = "Deleting ALL GOLDAVG rows from dm_stat_table"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_stat_table dst
     WHERE dst.statid="GOLDAVG"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Retrieve dm_stat_table rows for ",dcd_statid)
   SELECT DISTINCT INTO "nl:"
    dst.statid, dst.c1, dst.c5
    FROM dm_stat_table dst
    WHERE dst.statid=patstring(dcd_statid)
    HEAD REPORT
     dst_list->cnt = 0, stat = alterlist(dst_list->qual,0)
    DETAIL
     dst_list->cnt = (dst_list->cnt+ 1), stat = alterlist(dst_list->qual,dst_list->cnt), dst_list->
     qual[dst_list->cnt].statid = dst.statid,
     dst_list->qual[dst_list->cnt].obj_name = dst.c1, dst_list->qual[dst_list->cnt].owner = dst.c5,
     dst_list->qual[dst_list->cnt].obj_exists = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dst_list->cnt=0))
    SET dm_err->eproc = concat("No rows found in dm_stat_table for ",dcd_statid)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Verifying existence of objects in dm_stat_table"
   SELECT INTO "nl:"
    FROM dba_objects do,
     (dummyt d  WITH seq = value(dst_list->cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (do
     WHERE (do.owner=dst_list->qual[d.seq].owner)
      AND (do.object_name=dst_list->qual[d.seq].obj_name))
    DETAIL
     IF ((dst_list->qual[d.seq].statid=patstring("DMSTG_I*")))
      IF (replace(dst_list->qual[d.seq].statid,"DMSTG_I","",0)=trim(cnvtstring(do.object_id)))
       dst_list->qual[d.seq].obj_exists = 1
      ENDIF
     ELSE
      dst_list->qual[d.seq].obj_exists = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dst_list)
   ENDIF
   SET dm_err->eproc = concat("Delete dm_stat_table rows for ",dcd_statid)
   DELETE  FROM dm_stat_table dst,
     (dummyt d  WITH seq = value(dst_list->cnt))
    SET dst.seq = 1
    PLAN (d
     WHERE d.seq > 0
      AND (dst_list->qual[d.seq].obj_exists=0))
     JOIN (dst
     WHERE (dst.statid=dst_list->qual[d.seq].statid)
      AND (dst.c1=dst_list->qual[d.seq].obj_name)
      AND (dst.c5=dst_list->qual[d.seq].owner))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dpe(dcd_process_name,dcd_program_name)
   DECLARE forndx1 = i4 WITH protect, noconstant(0)
   DECLARE forndx2 = i4 WITH protect, noconstant(0)
   IF ((validate(dpe_list->cnt,- (1))=- (1))
    AND (validate(dpe_list->cnt,- (2))=- (2)))
    FREE RECORD dpe_list
    RECORD dpe_list(
      1 cnt = i4
      1 qual[*]
        2 dp_id = f8
        2 program_name = vc
        2 dpe_cnt = i4
        2 qual2[*]
          3 dpe_id = f8
          3 owner = vc
          3 obj_name = vc
          3 dpe_status = vc
          3 dpe_audsid = vc
          3 dpe_current_ind = i2
    )
   ENDIF
   SET dm_err->eproc = concat("Clean up dm_process_event rows for ",dcd_process_name,":",
    dcd_program_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = concat("Retrieve dm_process rows for ",dcd_process_name,":",dcd_program_name)
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    PLAN (dp
     WHERE dp.process_name=dcd_process_name
      AND dp.program_name=patstring(dcd_program_name))
     JOIN (dpe
     WHERE dpe.dm_process_id=dp.dm_process_id
      AND dpe.event_status="EXECUTING")
     JOIN (dped
     WHERE dped.dm_process_event_id=dpe.dm_process_event_id)
    ORDER BY dp.dm_process_id, dpe.dm_process_event_id
    HEAD REPORT
     dpe_list->cnt = 0, stat = alterlist(dpe_list->qual,0)
    HEAD dp.dm_process_id
     dpe_list->cnt = (dpe_list->cnt+ 1), stat = alterlist(dpe_list->qual,dpe_list->cnt), dpe_list->
     qual[dpe_list->cnt].dp_id = dp.dm_process_id,
     dpe_list->qual[dpe_list->cnt].program_name = dp.program_name
    HEAD dpe.dm_process_event_id
     dpe_list->qual[dpe_list->cnt].dpe_cnt = (dpe_list->qual[dpe_list->cnt].dpe_cnt+ 1), stat =
     alterlist(dpe_list->qual[dpe_list->cnt].qual2,dpe_list->qual[dpe_list->cnt].dpe_cnt), dpe_list->
     qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_id = dpe
     .dm_process_event_id,
     dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_status = dpe
     .event_status
    DETAIL
     IF (dped.detail_type=dpl_owner)
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].owner = dped
      .detail_text
     ENDIF
     IF (dped.detail_type IN (dpl_table, "TABLE_NAME", dpl_index, "INDEX_NAME"))
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].obj_name = dped
      .detail_text
     ENDIF
     IF (dped.detail_type=dpl_audsid)
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_audsid = dped
      .detail_text
     ENDIF
     dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_current_ind = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dpe_list->cnt=0))
    SET dm_err->eproc = concat("No rows found in dm_process table for ",dcd_process_name,":",
     dcd_program_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dpe_list)
   ENDIF
   FOR (forndx1 = 1 TO dpe_list->cnt)
     FOR (forndx2 = 1 TO dpe_list->qual[forndx1].dpe_cnt)
       IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_status=dpl_executing))
        IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_audsid > " "))
         IF (dar_get_appl_status(dpe_list->qual[forndx1].qual2[forndx2].dpe_audsid)="A")
          SET dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
         ENDIF
        ELSE
         IF ((dpe_list->qual[forndx1].program_name=patstring("DM2_GATHER_DBSTATS*")))
          SET dm_err->eproc = concat("Checking dm_process_queue row for: ",dpe_list->qual[forndx1].
           qual2[forndx2].owner,":",dpe_list->qual[forndx1].qual2[forndx2].obj_name)
          SELECT INTO "nl:"
           FROM dm_process_queue dpq
           WHERE dpq.process_type=dpq_statistics
            AND dpq.op_type=dpq_gather
            AND (dpq.owner_name=dpe_list->qual[forndx1].qual2[forndx2].owner)
            AND (dpq.object_name=dpe_list->qual[forndx1].qual2[forndx2].obj_name)
           DETAIL
            IF (dpq.process_status=dpq_executing)
             dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
            ENDIF
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
         ELSEIF ((dpe_list->qual[forndx1].program_name=patstring("DM2_PUBLISH_DBSTATS*")))
          SET dm_err->eproc = concat("Checking dm_stat_table row for: ",dpe_list->qual[forndx1].
           qual2[forndx2].owner,":",dpe_list->qual[forndx1].qual2[forndx2].obj_name)
          SELECT INTO "nl:"
           FROM dm_stat_table dst
           WHERE dst.statid=patstring("DMSTG*")
            AND (dst.c5=dpe_list->qual[forndx1].qual2[forndx2].owner)
            AND (dst.c1=dpe_list->qual[forndx1].qual2[forndx2].obj_name)
           DETAIL
            dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
         ELSE
          SET dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
         ENDIF
        ENDIF
        IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind=0))
         SET dm_err->eproc = concat("Update dm_process_event rows for dm_process_event_id: ",trim(
           cnvtstring(dpe_list->qual[forndx1].qual2[forndx2].dpe_id)))
         CALL disp_msg(" ",dm_err->logfile,0)
         UPDATE  FROM dm_process_event dpe
          SET dpe.event_status = dpl_failure, dpe.end_dt_tm = cnvtdatetime(curdate,curtime3), dpe
           .message_txt =
           "Status updated to FAILURE by dm2_cleanup_dbstats_rows due to orphaned session",
           dpe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WHERE (dpe.dm_process_event_id=dpe_list->qual[forndx1].qual2[forndx2].dpe_id)
           AND dpe.event_status=dpl_executing
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc) != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ROLLBACK
          RETURN(0)
         ENDIF
         COMMIT
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = "Check if object being published is involved in a hard parse event"
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",dcp_owner,".",
      dcp_table_name,". SQL_ID = ",
      trim(d.sql_id),", Session_Id:",trim(cnvtstring(d.session_id)),", Serial#: ",trim(cnvtstring(d
        .session_serial#)),
      ".")
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_publish_retry(dcp_retry_ceiling)
   SET dcp_retry_ceiling = 10
   SET dm_err->eproc = "Check for retry ceiling override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2GDBS:PUBLISH_RETRY"
     AND d.info_name="RETRY CEILING"
    DETAIL
     dcp_retry_ceiling = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_wait_pref(dcwp_pref_set_ind,dcwp_adb_ind)
   DECLARE dcwp_set_pref_value = i2 WITH protect, noconstant(0)
   DECLARE dcwp_cur_pref_value = i2 WITH protect, noconstant(0)
   DECLARE dcwp_pref_available_ind = i2 WITH protect, noconstant(0)
   DECLARE get_dbms_stat_prefs(pname=vc) = c255 WITH sql = "SYS.DBMS_STATS.GET_PREFS", parameter
   DECLARE set_dbms_stat_prefs(pname=vc,pvalue=vc) = null WITH sql =
   "SYS.DBMS_STATS.SET_GLOBAL_PREFS", parameter
   SET dcwp_pref_set_ind = 0
   IF ((dm2_rdbms_version->level1=0))
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3=0)
    AND (dm2_rdbms_version->level4 >= 4))) )) )) )
    CALL echo("11204 or higher")
   ELSE
    SET dcwp_pref_set_ind = 0
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS pref not available (ORAVER)")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dcwp_adb_ind=0)
    SET dm_err->eproc = "Check if wait pref available"
    SELECT INTO "nl:"
     dcwp_sel_cnt = count(*)
     FROM (sys.optstat_hist_control$ o)
     WHERE o.sname="WAIT_TIME_TO_UPDATE_STATS"
     DETAIL
      IF (dcwp_sel_cnt > 0)
       dcwp_pref_available_ind = 1
      ELSE
       dcwp_pref_available_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dcwp_pref_available_ind=0)
    SET dcwp_pref_set_ind = 0
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS pref not available (NOT SET)")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for wait pref override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2GDBS:GLOBAL_PREF"
     AND d.info_name="WAIT_TIME_TO_UPDATE_STATS"
    DETAIL
     dcwp_set_pref_value = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcwp_cur_pref_value = - (1)
   SET dm_err->eproc = "Check value of wait pref"
   SELECT INTO "nl:"
    dcwp_sel_pref_value = get_dbms_stat_prefs("WAIT_TIME_TO_UPDATE_STATS")
    FROM dual
    DETAIL
     dcwp_cur_pref_value = cnvtint(dcwp_sel_pref_value)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcwp_cur_pref_value != dcwp_set_pref_value)
    SET dm_err->eproc = concat("Setting wait preference to ",cnvtstring(dcwp_set_pref_value))
    CALL set_dbms_stat_prefs("WAIT_TIME_TO_UPDATE_STATS",cnvtstring(dcwp_set_pref_value))
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS set to ",cnvtstring(dcwp_set_pref_value))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dcwp_pref_set_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_object_id(dgoi_owner,dgoi_table_name,dgoi_object_id)
   SET dm_err->eproc = concat("Query to retrieve object id for table_name :",dgoi_table_name)
   IF ((dm_err->debug_flag > 5))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects d
    WHERE d.owner=dgoi_owner
     AND d.object_name=dgoi_table_name
     AND d.object_type="TABLE"
    DETAIL
     dgoi_object_id = d.object_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_context_pkg_data(null)
   DECLARE dgcpd_pkg_qry_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgcpd_pkg_valid_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgcpd_contxt_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check for CERADM.SD_DB_PROCESS_CONTEXT_MGR package exists or not"
   IF ((dm_err->debug_flag > 5))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects o
    WHERE o.owner="CERADM"
     AND o.object_name="SD_DB_PROCESS_CONTEXT_MGR"
     AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    DETAIL
     dgcpd_pkg_qry_cnt = (dgcpd_pkg_qry_cnt+ 1)
     IF (o.status="VALID")
      dgcpd_pkg_valid_cnt = (dgcpd_pkg_valid_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcpd_pkg_valid_cnt=2)
    SET dgdt_prefs->context_lock_schema = "CERADM"
    SET dgdt_prefs->context_lock_ind = 1
   ELSEIF (dgcpd_pkg_qry_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid CERADM.SD_DB_PROCESS_CONTEXT_MGR package exists"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dgdt_prefs->context_lock_schema="CERADM"))
    SET dm_err->eproc = "Query for SD_DB_PROCESS_CONTEXT schema context owner "
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     dgcpd_tmp_cntxt_cnt = count(*)
     FROM dba_context dc
     WHERE dc.package="SD_DB_PROCESS_CONTEXT_MGR"
      AND dc.namespace="SD_DB_PROCESS_CONTEXT"
      AND (dc.schema=dgdt_prefs->context_lock_schema)
      AND dc.type="ACCESSED GLOBALLY"
     DETAIL
      dgcpd_contxt_cnt = dgcpd_tmp_cntxt_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgcpd_contxt_cnt=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid SD_DB_PROCESS_CONTEXT schema context owner"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    SET dgcpd_pkg_qry_cnt = 0
    SET dgcpd_pkg_valid_cnt = 0
    SET dm_err->eproc = "Check if V500.SD_DB_PROCESS_CONTEXT_MGR package exists or not"
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dba_objects o
     WHERE o.owner="V500"
      AND o.object_name="SD_DB_PROCESS_CONTEXT_MGR"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
     DETAIL
      dgcpd_pkg_qry_cnt = (dgcpd_pkg_qry_cnt+ 1)
      IF (o.status="VALID")
       dgcpd_pkg_valid_cnt = (dgcpd_pkg_valid_cnt+ 1)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgcpd_pkg_valid_cnt=2)
     SET dgdt_prefs->context_lock_schema = "V500"
     SET dgdt_prefs->context_lock_ind = 1
    ELSEIF (dgcpd_pkg_qry_cnt > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid V500.SD_DB_PROCESS_CONTEXT_MGR package exists"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    IF ((dm_err->debug_flag > 5))
     CALL echo("Old locking mechanism in use i.e via dm_info")
    ENDIF
    SET dgdt_prefs->context_lock_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_context_lock_maint(dclm_mode,dclm_process,dclm_process_code,dclm_owner,
  dclm_table_name,dclm_object_id,dclm_lock_ind)
   DECLARE check_context_sd(chkc_process=vc,chkc_key=vc,chkc_value=vc,chkc_what=i2) = i2 WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.check_context", parameter
   DECLARE check_context_v500(chkc_process=vc,chkc_key=vc,chkc_value=vc,chkc_what=i2) = i2 WITH sql
    = "V500.SD_DB_PROCESS_CONTEXT_MGR.check_context", parameter
   DECLARE set_context_sd(sc_process=vc,sc_key=vc,sc_value=vc) = null WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.set_context", parameter
   DECLARE set_context_v500(sc_process=vc,sc_key=vc,sc_value=vc) = null WITH sql =
   "V500.SD_DB_PROCESS_CONTEXT_MGR.set_context", parameter
   DECLARE clear_context_sd(clrc_process=vc,clrc_key=vc) = null WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.clear_context", parameter
   DECLARE clear_context_v500(clrc_process=vc,clrc_key=vc) = null WITH sql =
   "V500.SD_DB_PROCESS_CONTEXT_MGR.clear_context", parameter
   DECLARE dclm_get_session_id() = c30 WITH sql = "dbms_session.unique_session_id", parameter
   DECLARE dclm_session_id = vc WITH protect, noconstant("")
   DECLARE dclm_sql_cmd = vc WITH protect, noconstant("")
   DECLARE dclm_context_val = i2 WITH protect, noconstant(0)
   DECLARE dclm_process_name = vc WITH protect, noconstant("")
   DECLARE dclm_pkg_owner = vc WITH protect, noconstant("")
   DECLARE dclm_obj_id_str = vc WITH protect, noconstant("")
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    IF (ddf_get_context_pkg_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=1))
    IF (dclm_object_id=0.0)
     IF (ddf_get_object_id(dclm_owner,dclm_table_name,dclm_object_id)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dclm_obj_id_str = trim(cnvtstring(dclm_object_id))
    SET dm_err->eproc = "Query to retrieve session id "
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     dclm_session_id_tmp = dclm_get_session_id()
     FROM dual
     DETAIL
      dclm_session_id = dclm_session_id_tmp
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dclm_process_name = build(dclm_process,dclm_process_code)
   ENDIF
   IF (dclm_mode="CHECK")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("check if context lock exists for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT
      IF ((dgdt_prefs->context_lock_schema="CERADM"))
       dclm_tmp_val = check_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str,2)
      ELSE
       dclm_tmp_val = check_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str,2)
      ENDIF
      INTO "nl:"
      FROM dual
      DETAIL
       dclm_context_val = dclm_tmp_val
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dclm_context_val > 0)
      SET dclm_lock_ind = 0
     ELSE
      SET dclm_lock_ind = 1
     ENDIF
    ELSE
     IF (ddf_check_lock("STATS LOCK",dclm_table_name,dclm_process_code,dclm_lock_ind)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dclm_mode="GET")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("Get context lock  for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dgdt_prefs->context_lock_schema="CERADM"))
      CALL set_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str)
     ELSE
      CALL set_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str)
     ENDIF
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("check if context lock obtained for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT
      IF ((dgdt_prefs->context_lock_schema="CERADM"))
       dclm_tmp_val = check_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str,1)
      ELSE
       dclm_tmp_val = check_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str,1)
      ENDIF
      INTO "nl:"
      FROM dual
      DETAIL
       dclm_context_val = dclm_tmp_val
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dclm_context_val=1)
      SET dclm_lock_ind = 1
     ELSE
      SET dclm_lock_ind = 0
     ENDIF
    ELSE
     IF (ddf_get_lock("STATS LOCK",dclm_table_name,dclm_process_code,dclm_lock_ind)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dclm_mode="RELEASE")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("Release context lock on ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dgdt_prefs->context_lock_schema="CERADM"))
      CALL clear_context_sd(dclm_process_name,dclm_session_id)
     ELSE
      CALL clear_context_v500(dclm_process_name,dclm_session_id)
     ENDIF
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->err_ind=0))
      SET dclm_lock_ind = 1
     ELSE
      SET dclm_lock_ind = 0
      SET dm_err->emsg = concat("Unable to release lock on object:",dclm_owner,".",dclm_table_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF (ddf_release_lock("STATS LOCK",dclm_table_name,dclm_process_code)=0)
      RETURN(0)
     ENDIF
     SET dclm_lock_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dpqw_dpq_ptype = vc WITH public, noconstant(" ")
 DECLARE dpqw_dpq_owner = vc WITH public, noconstant(" ")
 DECLARE dpqw_dpq_oname = vc WITH public, noconstant(" ")
 DECLARE dpqw_dpq_smode = vc WITH public, noconstant(" ")
 DECLARE dpqw_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dpqw_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE dpqw_cnt = i2 WITH protect, noconstant(0)
 DECLARE dpqw_report_destination = vc WITH protect, noconstant("")
 IF ((validate(dpqw_list->ind_cnt,- (1))=- (1))
  AND (validate(dpqw_list->ind_cnt,- (2))=- (2)))
  FREE RECORD dpqw_list
  RECORD dpqw_list(
    1 dpq_id = f8
    1 obj_owner = vc
    1 obj_name = vc
    1 obj_type = vc
    1 obj_exists = i2
    1 dpq_status = vc
    1 ind_cnt = i4
    1 ind[*]
      2 dpq_id = f8
      2 index_name = vc
      2 index_owner = vc
      2 index_status = vc
  )
 ENDIF
 IF (check_logfile("dm2_dpq_wrapper",".log","dm2_process_queue_wrapper LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning dm2_process_queue_wrapper"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Verifying and storing input parameters."
 SET dpqw_dpq_ptype = trim(cnvtupper( $1))
 SET dpqw_dpq_owner = trim(cnvtupper( $2))
 SET dpqw_dpq_oname = trim(cnvtupper( $3))
 SET dpqw_dpq_smode = trim(cnvtupper( $4))
 IF (((check_error(dm_err->eproc)=1) OR (((dpqw_dpq_ptype=null) OR (((dpqw_dpq_owner=null) OR (((
 dpqw_dpq_oname=null) OR (dpqw_dpq_smode=null)) )) )) )) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "Parameter usage: dm2_process_queue_wrapper '<PROCESS_TYPE>','<OWNER>','<OBJECT_NAME>','BYTABLE/BYOBJECT'"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Stat_mode must be one of 'BYTABLE'/'BYOBJECT'"
 IF ( NOT (dpqw_dpq_smode IN ("BYTABLE", "BYOBJECT")))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("Stat_mode must be one of 'BYTABLE'/'BYOBJECT' you entered: ",
   dpqw_dpq_smode)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm2_process_event_rs->status = dpl_executing
 SET dm2_process_rs->process_name = dpl_process_queue_wrapper
 CALL dm2_process_log_add_detail_text("PROCESS_TYPE",dpqw_dpq_ptype)
 CALL dm2_process_log_add_detail_text("OBJECT_NAME",dpqw_dpq_oname)
 CALL dm2_process_log_add_detail_text("OWNER",dpqw_dpq_owner)
 CALL dm2_process_log_add_detail_text("STAT_MODE",dpqw_dpq_smode)
 IF (dm2_process_log_row(dpl_process_queue_wrapper,dpl_execution,dpl_no_prev_id,1)=0)
  GO TO exit_script
 ENDIF
 SET dpqw_log_id = dm2_process_event_rs->dm_process_event_id
 SET dm_err->eproc = "Verifying the corresponding object_name AND owner exists"
 SELECT INTO "nl:"
  FROM dba_objects do
  WHERE do.owner=dpqw_dpq_owner
   AND do.object_name=dpqw_dpq_oname
   AND do.object_type != "TABLE PARTITION"
  DETAIL
   dpqw_list->obj_exists = 1, dpqw_list->obj_type = do.object_type, dpqw_list->obj_owner = do.owner,
   dpqw_list->obj_name = do.object_name, dpqw_list->dpq_status = "ROW NOT FOUND"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET dm_err->emsg = concat("No object exist with the given object name as ",dpqw_dpq_oname,
   " and owner ",dpqw_dpq_owner)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Verifying the corresponding object_name AND process_type exists"
 SELECT INTO "nl:"
  FROM dm_process_queue dpq
  WHERE dpq.process_type=dpqw_dpq_ptype
   AND (dpq.object_name=dpqw_list->obj_name)
   AND (dpq.object_type=dpqw_list->obj_type)
  DETAIL
   dpqw_list->dpq_id = dpq.dm_process_queue_id, dpqw_list->dpq_status = dpq.process_status
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET dm_err->emsg = concat("No rows exist for ",dpqw_list->obj_name,
   " with the given process type as ",dpqw_dpq_ptype)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dpqw_dpq_smode="BYTABLE")
  SET dm_err->eproc = concat("Collecting the indexes for ",dpqw_list->obj_name)
  SELECT INTO "nl:"
   FROM dba_indexes di,
    dm_process_queue dpq
   PLAN (di
    WHERE (di.table_name=dpqw_list->obj_name))
    JOIN (dpq
    WHERE outerjoin(di.index_name)=dpq.object_name)
   DETAIL
    dpqw_list->ind_cnt = (dpqw_list->ind_cnt+ 1), stat = alterlist(dpqw_list->ind,dpqw_list->ind_cnt),
    dpqw_list->ind[dpqw_list->ind_cnt].dpq_id = dpq.dm_process_queue_id,
    dpqw_list->ind[dpqw_list->ind_cnt].index_name = di.index_name, dpqw_list->ind[dpqw_list->ind_cnt]
    .index_owner = di.owner
    IF (dpq.process_status=null)
     dpqw_list->ind[dpqw_list->ind_cnt].index_status = "ROW NOT FOUND"
    ELSE
     dpqw_list->ind[dpqw_list->ind_cnt].index_status = dpq.process_status
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 SET dm_err->eproc = "Generating report for Existing objects"
 SET dpqw_report_destination = concat("dpq_wrapper_",format(cnvtdatetime(curdate,curtime3),
   "MMDDYYHHMM;;Q"))
 SELECT INTO build(dpqw_report_destination)
  FROM (dummyt d  WITH d.seq = 1)
  HEAD REPORT
   row + 0, col 0,
   "****** PROCESSING DM_PROCESS_QUEUE ROWS [OBJECT LIST REPORT] ***********************",
   row + 2, col 0, "Type:",
   col 25, dpqw_dpq_ptype, row + 1,
   col 0, "Owner:", col 25,
   dpqw_dpq_owner, row + 1, col 0,
   "Object Name:", col 25, dpqw_dpq_oname,
   row + 1, col 0, "Mode:",
   col 25, dpqw_dpq_smode, row + 2,
   col 0, "-- The following objects were found matching the input criteria --", row + 2,
   col 0, "TYPE", col 9,
   "OWNER", col 25, "OBJECT NAME",
   col 55, "DPQ STATUS", col 70,
   "WILL BE GATHERED", row + 1, col 0,
   "-------", col 9,
   CALL print(fillstring(14,"-")),
   col 25,
   CALL print(fillstring(28,"-")), col 55,
   CALL print(fillstring(13,"-")), col 70,
   CALL print(fillstring(16,"-"))
  DETAIL
   row + 1, col 0, dpqw_list->obj_type,
   col 9, dpqw_list->obj_owner, col 25,
   dpqw_list->obj_name, col 55, dpqw_list->dpq_status
   IF ((dpqw_list->dpq_status="QUEUED"))
    col 70, "YES"
   ELSE
    col 70, "NO"
   ENDIF
   IF ((dpqw_list->ind_cnt > 0))
    FOR (locndx = 1 TO dpqw_list->ind_cnt)
      row + 1, col 0, "INDEX",
      col 9, dpqw_list->ind[locndx].index_owner, col 25,
      dpqw_list->ind[locndx].index_name, col 55, dpqw_list->ind[locndx].index_status
      IF ((dpqw_list->ind[locndx].index_status="QUEUED"))
       col 70, "YES"
      ELSE
       col 70, "NO"
      ENDIF
    ENDFOR
   ENDIF
  FOOT REPORT
   row + 2, col 0, "- If an object exists and DPQ STATUS is QUEUED, the object will be processed",
   row + 1, col 0,
   "- If an object exists, but the dm_process_queue row for that object is not present, the object will be skipped",
   row + 1, col 0,
   "- If an object exists and is in a SUCCESS or FAILURE status in dm_process_queue, no action will be taken"
  WITH nocounter, nullreport, maxcol = 132,
   format = variable, formfeed = none
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dgdt_prefs->context_lock_ind=- (1)))
  IF (ddf_get_context_pkg_data(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((dpqw_list->dpq_status="QUEUED"))
  EXECUTE dm2_process_queue_single dpqw_list->dpq_id
 ENDIF
 IF (dpqw_dpq_smode="BYTABLE")
  FOR (dpqw_idx = 1 TO dpqw_list->ind_cnt)
    IF ((dpqw_list->ind[dpqw_idx].index_status="QUEUED"))
     EXECUTE dm2_process_queue_single dpqw_list->ind[dpqw_idx].dpq_id
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 SET dm2_process_event_rs->status = evaluate(dm_err->err_ind,1,dpl_failure,dpl_success)
 SET dm2_process_event_rs->message = evaluate(dm_err->err_ind,1,dm_err->emsg,"")
 SET dpqw_err_ind = dm_err->err_ind
 SET dm_err->err_ind = 0
 CALL dm2_process_log_row(dpl_process_queue_wrapper,dpl_execution,dpqw_log_id,1)
 SET dm2_process_rs->process_name = ""
 SET dm_err->err_ind = dpqw_err_ind
 SET dm_err->eproc = "Ending dm2_process_queue_wrapper"
 CALL final_disp_msg("dm2_process_queue_wrapper")
END GO
