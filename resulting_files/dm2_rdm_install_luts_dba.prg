CREATE PROGRAM dm2_rdm_install_luts:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF ((validate(luts_list->table_cnt,- (1))=- (1))
  AND (validate(luts_list->table_cnt,- (2))=- (2)))
  FREE RECORD luts_list
  RECORD luts_list(
    01 inst_cnt = i2
    01 parallel_degree = i2
    01 table_cnt = i4
    01 table_diff_cnt = i2
    01 table_diff_txn_cnt = i2
    01 add_column_cnt = i2
    01 add_instid_column_cnt = i2
    01 add_txn_column_cnt = i2
    01 modify_dd_cnt = i2
    01 set_index_visible_cnt = i2
    01 set_txn_index_visible_cnt = i2
    01 create_index_cnt = i2
    01 rename_index_cnt = i2
    01 create_txn_index_cnt = i2
    01 disable_txn_trigger_cnt = i2
    01 create_trigger_cnt = i2
    01 create_del_trigger_cnt = i2
    01 set_col_stats_cnt = i2
    01 set_txn_col_stats_cnt = i2
    01 set_instid_col_stats_cnt = i2
    01 default_index_tspace = vc
    01 use_txn_table_synonym_ind = i2
    01 config_curr_txn_table = vc
    01 default_free_bytes_mb = f8
    01 txn_schema_ind = i2
    01 qual[*]
      02 table_is_scn = i2
      02 table_is_luts = i2
      02 table_owner = vc
      02 table_name = vc
      02 suffixed_table_name = vc
      02 table_suffix = vc
      02 diff_ind = i2
      02 diff_txn_ind = i2
      02 add_column_ind = i2
      02 add_instid_column_ind = i2
      02 add_txn_column_ind = i2
      02 add_column_ddl = vc
      02 add_txn_column_ddl = vc
      02 add_instid_column_ddl = vc
      02 add_combined_column_ddl = vc
      02 set_col_stats_ind = i2
      02 set_instid_col_stats_ind = i2
      02 set_txn_col_stats_ind = i2
      02 num_rows = f8
      02 create_index_ind = i2
      02 rename_index_ind = i2
      02 create_txn_index_ind = i2
      02 create_index_ddl = vc
      02 rename_index_ddl = vc
      02 create_txn_index_ddl = vc
      02 set_index_visible_ddl = vc
      02 set_txn_index_visible_ddl = vc
      02 set_index_visible_ind = i2
      02 set_txn_index_visible_ind = i2
      02 set_index_visible_ddl = vc
      02 set_txn_index_visible_ddl = vc
      02 index_name = vc
      02 txn_index_name = vc
      02 index_tspace = vc
      02 free_bytes_mb = f8
      02 index_col_list = vc
      02 index_txn_col_list = vc
      02 tspace_needed_mb = f8
      02 new_trigger_ind = i2
      02 create_trigger_ind = i2
      02 disable_txn_trigger_ind = i2
      02 disable_txn_trigger_ddl = vc
      02 trigger_name = vc
      02 delete_tracking_ind = i2
      02 delete_tracking_ldt_idx = i4
      02 del_trigger_name = vc
      02 create_del_trigger_ind = i2
      02 create_del_trigger_ddl = vc
      02 new_del_trigger_ind = i2
      02 txn_info_char = vc
      02 original_trigger_ddl = vc
      02 original_del_trigger_ddl = vc
      02 original_txn_trigger_ddl = vc
      02 create_trigger_ddl = vc
      02 use_inst_id_ind = i2
      02 delete_tracking_only_ind = i2
    01 asm_ind = i2
    01 dg_cnt = i2
    01 dg_space_needed_ind = i2
    01 dg[*]
      02 dg_name = vc
      02 total_bytes_mb = f8
      02 reserved_bytes_mb = f8
      02 free_bytes_mb = f8
      02 assigned_bytes_mb = f8
      02 new_ind_cnt = i4
    01 tspace_cnt = i2
    01 tspace_needed_ind = i2
    01 ts[*]
      02 tspace_name = vc
      02 dg_name = vc
      02 data_file_cnt = i4
      02 max_bytes_mb = f8
      02 user_bytes_mb = f8
      02 reserved_bytes_mb = f8
      02 free_bytes_mb = f8
      02 assigned_bytes_mb = f8
      02 assigned_ind_names = vc
      02 new_ind_cnt = i4
    01 install_by_rdm_ind = i2
  )
 ENDIF
 IF ((validate(luts_dyn_trig->table_cnt,- (1))=- (1))
  AND (validate(luts_dyn_trig->table_cnt,- (2))=- (2)))
  FREE RECORD luts_dyn_trig
  RECORD luts_dyn_trig(
    1 table_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 tn_txt = vc
      2 pen_txt = vc
      2 pei_txt = vc
      2 tpk_txt = vc
      2 data_txt = vc
      2 del_log_condition = vc
      2 txn_log_condition = vc
      2 dup_delrow_var_values = vc
  )
 ENDIF
 IF ((validate(luts_drop_list->table_cnt,- (1))=- (1))
  AND (validate(luts_drop_list->table_cnt,- (2))=- (2)))
  FREE RECORD luts_drop_list
  RECORD luts_drop_list(
    1 table_cnt = i4
    1 drop_index_cnt = i4
    1 drop_txn_index_cnt = i4
    1 drop_trigger_cnt = i4
    1 drop_del_trigger_cnt = i4
    1 drop_txn_trigger_cnt = i4
    1 drop_txn_pkg_cnt = i4
    1 qual[*]
      2 table_owner = vc
      2 table_name = vc
      2 drop_index_ind = i2
      2 drop_txn_index_ind = i2
      2 drop_index_ddl = vc
      2 drop_index_reason = vc
      2 drop_txn_index_ddl = vc
      2 drop_txn_index_reason = vc
      2 drop_trigger_ind = i2
      2 drop_txn_trigger_ind = i2
      2 drop_trigger_ddl = vc
      2 drop_trigger_reason = vc
      2 drop_del_trigger_ind = i2
      2 drop_del_trigger_ddl = vc
      2 drop_del_trigger_reason = vc
      2 drop_txn_trigger_ddl = vc
      2 drop_txn_trigger_reason = vc
      2 drop_txn_pkg_ind = i2
      2 drop_txn_pkg_ddl = vc
      2 drop_txn_pkg_name = vc
      2 drop_txn_pkg_reason = vc
  )
 ENDIF
 DECLARE dld_load_tables(null) = i2
 DECLARE dld_diff_schema(null) = i2
 DECLARE dld_diff_trigger(ddt_trigger_name=vc,ddt_table_name=vc,ddt_trigger_txt=vc,ddt_diff_ind=i2(
   ref)) = i2
 DECLARE dld_gen_lutsonly_trigger(dglt_idx=i4,dgkt_ddl_txt=vc(ref)) = i2
 DECLARE dld_gen_compound_trigger(dgct_idx=i4,dgct_ddl_txt=vc(ref)) = i2
 DECLARE dld_gen_del_compound_trigger(dgct_idx=i4,dgct_ddl_txt=vc(ref)) = i2
 DECLARE dld_compare_trigger(dct_owner=i4,dct_trigger_name=vc,dct_trigger_txt=vc,dct_from_gtt=i4) =
 i4 WITH sql = "V500.DM2DMP_UTIL.COMPARE_TRIGGER", parameter
 DECLARE dld_load_original_trigger_ddl(null) = i2
 DECLARE dld_load_curr_txn_table(null) = i2
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dm2_rdm_install_luts..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE inhouse_ind = i2 WITH protect, noconstant(0)
 SET luts_list->install_by_rdm_ind = 1
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name IN ("INHOUSE DOMAIN", "MILLPLUS IH EXCEPTION")
  ORDER BY d.info_name
  HEAD d.info_name
   IF (d.info_name="INHOUSE DOMAIN")
    inhouse_ind = (inhouse_ind+ 1)
   ELSEIF (d.info_name="MILLPLUS IH EXCEPTION")
    inhouse_ind = (inhouse_ind+ 2)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from DM_INFO: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (inhouse_ind=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success: Non Millennium+ Inhouse environment detected."
 ELSE
  EXECUTE dm2_install_luts
  IF ((dm_err->err_ind=0))
   SET readme_data->status = "S"
   SET readme_data->message = "Success: Readme performed all required tasks"
  ELSE
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed: ",dm_err->emsg)
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
