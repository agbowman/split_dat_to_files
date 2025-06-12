CREATE PROGRAM dm2_dbstats_runner:dba
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
 DECLARE dpq_process_queue_row(null) = i2
 DECLARE dpq_update_queue_row(duqr_success=i2(ref)) = i2
 DECLARE dpq_cleanup_old_procs(dcop_proc_type=vc,dcop_maxcommit=i4) = i2
 DECLARE dpq_execute_command(dec_success=i2(ref)) = i2
 DECLARE dpq_populate_queue_rows(dpqr_proc_type=vc) = i2
 DECLARE dpq_lock_queue_row(dlqr_success=i2(ref)) = i2
 DECLARE dpq_check_end_time(dcet_beg_dt_tm=dq8,dcet_proc=vc,dcet_continue_ind=i2(ref)) = i2
 DECLARE dpq_manage_end_time(dmet_prompt_ind=i2,dmet_proc_type=vc,dmet_end_time=i4) = i2
 DECLARE dpq_remove_procs(drp_proc_type=vc,drp_status=vc,drp_maxcommit=i4) = i2
 IF ((validate(dpq_process_queue->dm_process_queue_id,- (1))=- (1))
  AND (validate(dpq_process_queue->dm_process_queue_id,- (2))=- (2)))
  FREE RECORD dpq_process_queue
  RECORD dpq_process_queue(
    1 dm_process_queue_id = f8
    1 process_type = vc
    1 op_type = vc
    1 owner_name = vc
    1 object_type = vc
    1 object_name = vc
    1 operation_txt = vc
    1 process_status = vc
    1 message_txt = vc
    1 op_method = vc
    1 priority = i4
    1 routine_tasks_ind = i2
  )
 ENDIF
 IF ((validate(dpq_proc_list->proc_cnt,- (1))=- (1))
  AND (validate(dpq_proc_list->proc_cnt,- (2))=- (2)))
  FREE RECORD dpq_proc_list
  RECORD dpq_proc_list(
    1 proc_cnt = i4
    1 qual[*]
      2 dm_process_queue_id = f8
      2 process_type = vc
      2 operation_txt = vc
      2 op_method = vc
  )
  DECLARE dpq_statistics = vc WITH protect, constant("STATISTICS")
  DECLARE dpq_freq_statistics = vc WITH protect, constant("STATISTICS_FREQ_GATHER")
  DECLARE dpq_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpq_routine_tasks = vc WITH protect, constant("ROUTINE_TASKS")
  DECLARE dpq_index_coalesce = vc WITH protect, constant("INDEX_COALESCE")
  DECLARE dpq_clinical_ranges = vc WITH protect, constant("CLINICAL_RANGES")
  DECLARE dpq_gather = vc WITH protect, constant("GATHER")
  DECLARE dpq_validate = vc WITH protect, constant("VALIDATE")
  DECLARE dpq_coalesce = vc WITH protect, constant("COALESCE")
  DECLARE dpq_queued = vc WITH protect, constant("QUEUED")
  DECLARE dpq_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpq_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpq_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpq_table = vc WITH protect, constant("TABLE")
  DECLARE dpq_index = vc WITH protect, constant("INDEX")
  DECLARE dpq_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpq_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpq_db = vc WITH protect, constant("DB")
  DECLARE dpq_dcl = vc WITH protect, constant("DCL")
 ENDIF
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
 IF (check_logfile("dm2_dbstats_runner",".log","DM2_DBSTATS_RUNNER LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning DM2_DBSTATS_RUNNER"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((dgdt_prefs->context_lock_ind=- (1)))
  IF (ddf_get_context_pkg_data(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE dm2_process_queue_runner dpq_statistics
 IF ((dm_err->err_ind=1))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
#exit_script
 SET dm_err->eproc = "Ending DM2_DBSTATS_RUNNER"
 CALL final_disp_msg("dm2_dbstats_runner")
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
 SUBROUTINE dpq_process_queue_row(null)
   SET dm_err->eproc = "Validating inputs for dpq_process_queue_row"
   IF ("" IN (trim(dpq_process_queue->process_type), trim(dpq_process_queue->op_type), trim(
    dpq_process_queue->owner_name), trim(dpq_process_queue->object_type), trim(dpq_process_queue->
    object_name),
   trim(dpq_process_queue->operation_txt)))
    SET dm_err->emsg =
    "Must populate PROC_TYPE, OP_TYPE, owner_name, OBJECT_TYPE, operation_txt and OBJECT_NAME"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking for an existing row from dm_process_queue."
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE (dpq.process_type=dpq_process_queue->process_type)
     AND (dpq.op_type=dpq_process_queue->op_type)
     AND (dpq.owner_name=dpq_process_queue->owner_name)
     AND (dpq.object_type=dpq_process_queue->object_type)
     AND (dpq.object_name=dpq_process_queue->object_name)
    DETAIL
     dpq_process_queue->dm_process_queue_id = dpq.dm_process_queue_id, dpq_process_queue->
     process_status = dpq.process_status
    WITH nocounter, maxqual(dpq,1)
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual
    AND (dpq_process_queue->process_status != dpq_executing))
    SET dm_err->eproc = "Updating dm_process_queue row."
    UPDATE  FROM dm_process_queue dpq
     SET dpq.process_status = dpq_queued, dpq.operation_txt = dpq_process_queue->operation_txt, dpq
      .op_method = dpq_process_queue->op_method,
      dpq.message_txt = "", dpq.audsid = "", dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dpq.priority = evaluate(dpq_process_queue->priority,0,dpq.priority,dpq_process_queue->priority),
      dpq.routine_tasks_ind = dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSEIF (curqual
    AND (dpq_process_queue->process_status=dpq_executing))
    UPDATE  FROM dm_process_queue dpq
     SET dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpq.priority = evaluate(dpq_process_queue->
       priority,0,dpq.priority,dpq_process_queue->priority), dpq.routine_tasks_ind =
      dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Selecting new dm_process_queue_id from dual"
    SELECT INTO "nl:"
     new_id = seq(dm_clinical_seq,nextval)
     FROM dual d
     DETAIL
      dpq_process_queue->dm_process_queue_id = new_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting dm_process_queue row."
    INSERT  FROM dm_process_queue dpq
     SET dpq.process_type = dpq_process_queue->process_type, dpq.dm_process_queue_id =
      dpq_process_queue->dm_process_queue_id, dpq.op_type = dpq_process_queue->op_type,
      dpq.owner_name = dpq_process_queue->owner_name, dpq.object_type = dpq_process_queue->
      object_type, dpq.object_name = dpq_process_queue->object_name,
      dpq.operation_txt = dpq_process_queue->operation_txt, dpq.op_method = dpq_process_queue->
      op_method, dpq.process_status = dpq_queued,
      dpq.priority = evaluate(dpq_process_queue->priority,0,100,dpq_process_queue->priority), dpq
      .routine_tasks_ind = dpq_process_queue->routine_tasks_ind, dpq.gen_dt_tm = cnvtdatetime(curdate,
       curtime3),
      dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_update_queue_row(duqr_success)
   SET dm_err->eproc = "Updating dm_process_queue row"
   SET duqr_success = 0
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_process_queue->process_status, dpq.message_txt = evaluate(trim(
       dpq_process_queue->message_txt),"",dpq.message_txt,dpq_process_queue->message_txt), dpq.audsid
      = "",
     dpq.end_dt_tm = cnvtdatetime(curdate,curtime3), dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual)
    SET duqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_old_procs(dcop_proc_type,dcop_maxcommit)
   DECLARE dcop_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcop_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcop_proc_type=dpq_routine_tasks)
    SET dcop_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcop_tmp_where_clause = "dpq.process_type = value(dcop_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating queued rows from DM_PROCESS_QUEUE"
   WHILE (dcop_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_queued, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)"), dpq.message_txt = ""
      WHERE parser(dcop_tmp_where_clause)
       AND ((dpq.process_status=dpq_failure) OR (dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle)) ))
      WITH nocounter, maxqual(dpq,value(dcop_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcop_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_lock_queue_row(dlqr_success)
   SET dlqr_success = 0
   SET dm_err->eproc = "Attempting to update DM_PROCESS_QUEUE row to executing."
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_executing, dpq.begin_dt_tm = cnvtdatetime(curdate,curtime3), dpq
     .audsid = currdbhandle
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     AND dpq.process_status=dpq_queued
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ELSEIF (curqual)
    SET dlqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_populate_queue_rows(dpqr_proc_type)
   DECLARE dpqr_tmp = i4 WITH protect, noconstant(0)
   DECLARE dpqr_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dpqr_proc_type=dpq_routine_tasks)
    SET dpqr_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dpqr_tmp_where_clause = "dpq.process_type = value(dpqr_proc_type)"
   ENDIF
   IF (validate(dpqrs_exec_ind,- (1))=1)
    IF ( NOT (validate(dpqrs_dpq_id,- (1)) <= 0.0))
     SET dpqr_tmp_where_clause = concat(dpqr_tmp_where_clause,
      " and dpq.dm_process_queue_id = value(dpqrs_dpq_id)")
    ELSE
     SET dm_err->eproc =
     "DPQ_POPULATE_QUEUE_ROWS was called via dm2_process_queue_runner_single with no valid dpq_id"
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   SET dpq_proc_list->proc_cnt = 0
   SET stat = alterlist(dpq_proc_list->qual,0)
   SET dm_err->eproc = "Loading operations to run from DM_PROCESS_QUEUE"
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE dpq.process_status=dpq_queued
     AND parser(dpqr_tmp_where_clause)
    ORDER BY dpq.priority, dpq.gen_dt_tm
    DETAIL
     dpq_proc_list->proc_cnt = (dpq_proc_list->proc_cnt+ 1)
     IF ((dpq_proc_list->proc_cnt > dpqr_tmp))
      dpqr_tmp = (dpqr_tmp+ 50), stat = alterlist(dpq_proc_list->qual,dpqr_tmp)
     ENDIF
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].dm_process_queue_id = dpq.dm_process_queue_id,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].process_type = dpq.process_type, dpq_proc_list->
     qual[dpq_proc_list->proc_cnt].operation_txt = dpq.operation_txt,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].op_method = dpq.op_method
    FOOT REPORT
     stat = alterlist(dpq_proc_list->qual,dpq_proc_list->proc_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_execute_command(dec_success)
   SET dm_err->eproc = "Validating inputs for dpq_execute_command"
   IF ("" IN (trim(dpq_process_queue->op_method), trim(dpq_process_queue->operation_txt)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DPQ_EXECUTE_COMMAND was called with no operation_txt or op_method"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Executing operation_txt: ",dpq_process_queue->op_method,":",
    dpq_process_queue->operation_txt)
   IF ((dpq_process_queue->op_method=dpq_db))
    SET dec_success = dm2_push_cmd(dpq_process_queue->operation_txt,1)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ELSEIF ((dpq_process_queue->op_method=dpq_dcl))
    SET dec_success = dm2_push_dcl(dpq_process_queue->operation_txt)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ENDIF
   IF (dec_success)
    SET dpq_process_queue->process_status = dpq_success
    SET dpq_process_queue->message_txt = ""
   ELSE
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_check_end_time(dcet_beg_dt_tm,dcet_proc,dcet_continue_ind)
   DECLARE dcet_tgt_end_time = dq8 WITH protect, noconstant(cnvtdatetime(curdate,cnvttime(360)))
   DECLARE dcet_fallout_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Selecting end_time from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN ("DM_PROCESS_QUEUE_RUNNER_END_TIME", "DM_PROCESS_QUEUE_RUNNER_FALLOUT")
     AND di.info_name=dcet_proc
    DETAIL
     IF (di.info_domain="DM_PROCESS_QUEUE_RUNNER_FALLOUT")
      dcet_fallout_ind = 1
     ELSE
      IF ((di.info_number=- (1)))
       dcet_tgt_end_time = datetimeadd(cnvtdatetime(curdate,curtime3),1)
      ELSE
       dcet_tgt_end_time = cnvtdatetime(curdate,cnvttime(di.info_number))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcet_beg_dt_tm > dcet_tgt_end_time)
    SET dcet_tgt_end_time = datetimeadd(dcet_tgt_end_time,1)
   ENDIF
   IF (((cnvtdatetime(curdate,curtime3) > dcet_tgt_end_time) OR (dcet_fallout_ind=1)) )
    IF (dcet_fallout_ind=1)
     SET dm_err->eproc =
     "Ending dm2_process_queue_runner because Fallout Indicator row was found in dm_info"
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dcet_continue_ind = 0
   ELSE
    SET dcet_continue_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_manage_end_time(dmet_prompt_ind,dmet_proc_type,dmet_end_time)
   DECLARE dmet_new_end_time = i4 WITH protect, noconstant(dmet_end_time)
   DECLARE dmet_update_ind = i2 WITH protect, noconstant(0)
   DECLARE dmet_menu_select = vc WITH protect, noconstant("M")
   IF (dmet_prompt_ind)
    SET dmet_new_end_time = 360
   ENDIF
   SET dm_err->eproc = "Checking for existence of end_time row from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
     AND di.info_name=dmet_proc_type
    DETAIL
     IF (dmet_prompt_ind)
      dmet_new_end_time = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dmet_update_ind = curqual
   ENDIF
   WHILE (true)
    IF (dmet_prompt_ind)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,concat(dmet_proc_type,notrim(" job menu")))
     CALL text(5,10,concat("Input the hour you want the ",dmet_proc_type,
       " job to stop at (0-23) [use -1 for no end time]:"))
     CALL text(6,10,concat("Hours:",evaluate(dmet_new_end_time,- (1),"Unlimited",cnvtstring(floor((
          dmet_new_end_time/ 60))))))
     CALL text(7,10,concat("Input the minutes you want the ",dmet_proc_type,notrim(
        " job to stop at (0-59):")))
     CALL text(8,10,concat("Minutes:",cnvtstring(evaluate(dmet_new_end_time,- (1),0,mod(
          dmet_new_end_time,60)))))
     CALL text(10,10,"(C)ontinue, (M)odify, (Q)uit:")
     CALL accept(10,41,"A;CU",dmet_menu_select
      WHERE curaccept IN ("C", "M", "Q"))
     SET dmet_menu_select = curaccept
     IF (dmet_menu_select="C")
      SET message = nowindow
      CALL clear(1,1)
     ENDIF
    ELSE
     SET dmet_menu_select = "C"
    ENDIF
    CASE (dmet_menu_select)
     OF "Q":
      RETURN(1)
     OF "C":
      IF (dmet_update_ind)
       SET dm_err->eproc = "Updating end_time row into DM_INFO"
       UPDATE  FROM dm_info di
        SET di.info_number = dmet_new_end_time
        WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
         AND di.info_name=dmet_proc_type
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET dm_err->eproc = "Inserting end_time row into DM_INFO"
       INSERT  FROM dm_info di
        SET di.info_domain = "DM_PROCESS_QUEUE_RUNNER_END_TIME", di.info_name = dmet_proc_type, di
         .info_number = dmet_new_end_time
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
      RETURN(1)
     OF "M":
      SET dmet_menu_select = "C"
      CALL accept(6,16,"NN;",evaluate(dmet_new_end_time,- (1),- (1),floor((dmet_new_end_time/ 60)))
       WHERE curaccept BETWEEN - (1) AND 23)
      SET dmet_new_end_time = evaluate(curaccept,- (1),- (1),(60 * curaccept))
      IF ((dmet_new_end_time != - (1)))
       CALL accept(8,18,"99;",0
        WHERE curaccept BETWEEN 0 AND 59)
       SET dmet_new_end_time = (dmet_new_end_time+ curaccept)
      ENDIF
    ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dpq_remove_procs(drp_proc_type,drp_status,drp_maxcommit)
   DECLARE drp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE drp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (drp_proc_type=dpq_routine_tasks)
    SET drp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET drp_tmp_where_clause = "dpq.process_type = value(drp_proc_type)"
   ENDIF
   SET dm_err->eproc = concat("Clearing out ",drp_proc_type," rows with status of ",drp_status)
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (drp_continue_ind)
     DELETE  FROM dm_process_queue dpq
      WHERE dpq.process_status=drp_status
       AND parser(drp_tmp_where_clause)
      WITH nocounter, maxqual(dpq,value(drp_maxcommit))
     ;end delete
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
     SET drp_continue_ind = curqual
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_stranded_procs(dcsp_proc_type,dcsp_maxcommit)
   DECLARE dcsp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcsp_proc_type=dpq_routine_tasks)
    SET dcsp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcsp_tmp_where_clause = "dpq.process_type = value(dcsp_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating stranded rows from DM_PROCESS_QUEUE"
   WHILE (dcsp_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_failure, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)")
      WHERE parser(dcsp_tmp_where_clause)
       AND dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle))
      WITH nocounter, maxqual(dpq,value(dcsp_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcsp_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
END GO
