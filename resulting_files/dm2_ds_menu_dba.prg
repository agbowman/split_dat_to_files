CREATE PROGRAM dm2_ds_menu:dba
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
 DECLARE dtr_parse_tns(dpt_fl=vc,dpt_fn=vc) = i2
 DECLARE dtr_copy_to_tnstgt(null) = i2
 DECLARE dtr_merge_to_tnstgt(null) = i2
 DECLARE dtr_reset_tnswork(null) = i2
 DECLARE dtr_tns_generate(dtg_file_location=vc,dtg_file_name=vc) = i2
 DECLARE dtr_tns_confirm(dtc_file_location=vc,dtc_file_name=vc) = i2
 DECLARE dtr_tns_deploy(dtd_file_location=vc,dtd_file_name=vc) = i2
 DECLARE dtr_tns_test_connect(null) = i2
 DECLARE dtr_get_tns_details(null) = i2
 DECLARE dtr_get_host_port_numbers(null) = i2
 DECLARE dtr_import_tns_templates(null) = i2
 DECLARE dtr_setup_tgt_template(token_name=vc) = i2
 DECLARE dtr_complete_tgt_template(null) = i2
 DECLARE dtr_add_token(token_name=vc,token_value=vc) = null
 DECLARE dtr_clear_tokens(null) = null
 DECLARE dtr_copy_tgt_template(null) = i2
 DECLARE dtr_populate_all_tns_stanzas(null) = i2
 DECLARE dtr_display_tns_report(null) = i2
 DECLARE dtr_prompt_tns_confirmation(null) = i2
 DECLARE dtr_service_connectivity_test(null) = i2
 DECLARE dtr_query_tns_details(null) = i2
 IF ((validate(tnswork->cnt,- (1))=- (1))
  AND (validate(tnswork->cnt,- (2))=- (2)))
  RECORD tnswork(
    1 db_name = vc
    1 db_connected = i2
    1 db_vip_ext = vc
    1 db_port = vc
    1 db_host_name = vc
    1 db_host_clause = vc
    1 db_domain = vc
    1 tc_user = vc
    1 tc_pwd = vc
    1 tc_inst_cnt = i2
    1 cnt = i2
    1 qual[*]
      2 tns_key = vc
      2 tns_key_full = vc
      2 db_domain = vc
      2 tns_key_type_cd = i2
      2 chg_format_ind = i2
      2 merge_ind = i2
      2 line_cnt = i2
      2 qual[*]
        3 text = vc
      2 tc_option = i2
      2 tc_num_connects = i2
      2 tc_inst_cnt = i2
      2 tcl[*]
        3 instance_name = vc
        3 host_name = vc
    1 inst_cnt = i2
    1 inst[*]
      2 instance_name = vc
      2 host_name = vc
  )
  SET tnswork->db_vip_ext = "DM2NOTSET"
  SET tnswork->db_port = "DM2NOTSET"
  SET tnswork->db_host_name = "DM2NOTSET"
  SET tnswork->db_host_clause = "DM2NOTSET"
  SET tnswork->db_domain = "DM2NOTSET"
  SET tnswork->tc_user = "DM2NOTSET"
  SET tnswork->tc_pwd = "DM2NOTSET"
  SET tnswork->inst_cnt = 0
 ENDIF
 IF ((validate(tnstgt->cnt,- (1))=- (1))
  AND (validate(tnstgt->cnt,- (2))=- (2)))
  RECORD tnstgt(
    1 cnt = i2
    1 db_name = vc
    1 db_vip_ext = vc
    1 db_port = vc
    1 db_domain = vc
    1 global_status_ind = i2
    1 qual[*]
      2 tns_key = vc
      2 tns_key_full = vc
      2 db_domain = vc
      2 tns_key_type_cd = i2
      2 mod_ind = i2
      2 status_ind = i2
      2 instance_name = vc
      2 host_name = vc
      2 line_cnt = i2
      2 qual[*]
        3 text = vc
  )
 ENDIF
 IF ((validate(tns_reply->process,- (1))=- (1))
  AND (validate(tns_reply->process,- (2))=- (2)))
  RECORD tns_reply(
    1 process = vc
    1 user_selection = vc
    1 status_ind = i2
    1 message = vc
  )
 ENDIF
 IF (validate(dtr_tns_details->vip_extension,"A")="A"
  AND validate(dtr_tns_details->vip_extension,"B")="B")
  FREE RECORD dtr_tns_details
  RECORD dtr_tns_details(
    1 spfile_ind = i2
    1 vip_extension = vc
    1 desired_db_domain = vc
  )
 ENDIF
 IF (validate(dtr_tns_templs->cnt,1)=1
  AND validate(dtr_tns_templs->cnt,2)=2)
  FREE RECORD dtr_tns_templs
  RECORD dtr_tns_templs(
    1 cnt = i4
    1 qual[*]
      2 token_name = vc
      2 line_cnt = i4
      2 lines[*]
        3 line = vc
    1 token_cnt = i4
    1 tokens[*]
      2 token_name = vc
      2 token_value = vc
    1 tgt_line_cnt = i4
    1 tgt_template[*]
      2 line = vc
    1 all_tgt_template_cnt = i4
    1 all_tgt_templates[*]
      2 line_cnt = i4
      2 qual[*]
        3 line = vc
  )
 ENDIF
 IF (validate(dtr_instance_data->ping_fail_ind,1)=1
  AND validate(dtr_instance_data->ping_fail_ind,2)=2)
  FREE RECORD dtr_instance_data
  RECORD dtr_instance_data(
    1 ping_fail_ind = i2
    1 qual[*]
      2 port_number = i4
      2 ping_fail_ind = i2
      2 emsg = vc
  )
 ENDIF
 IF (validate(dtr_connectivity->cnt,1)=1
  AND validate(dtr_connectivity->cnt,2)=2)
  FREE RECORD dtr_connectivity
  RECORD dtr_connectivity(
    1 cnt = i4
    1 qual[*]
      2 connect_string = vc
      2 connect_ind = i2
      2 emsg = vc
    1 connect_fail_ind = i2
  )
 ENDIF
 DECLARE dm2_get_dbase_name(dgdn_name_out=vc(ref)) = i2
 SUBROUTINE dm2_get_dbase_name(dgdn_name_out)
   SET dm_err->eproc = "Get database name from currdbname."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (validate(currdbhandle," ")=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "currdbhandle is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (validate(currdbname," ") != " ")
     SET dgdn_name_out = currdbname
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "currdbname is not set."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("dgdn_name_out =",dgdn_name_out))
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (validate(dm2_rdbms_version->level1,- (1)) < 0)
  FREE RECORD dm2_rdbms_version
  RECORD dm2_rdbms_version(
    1 version = vc
    1 level1 = i2
    1 level2 = i2
    1 level3 = i2
    1 level4 = i2
    1 level5 = i2
  )
 ENDIF
 DECLARE dm2_get_rdbms_version() = i2
 SUBROUTINE dm2_get_rdbms_version(null)
   DECLARE dgrv_level = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_prev_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loop = i2 WITH protect, noconstant(0)
   DECLARE dgrv_len = i2 WITH protect, noconstant(0)
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    RETURN(1)
   ENDIF
   SELECT
    IF (currdbver < 19)
     FROM (
      (
      (SELECT
       orcl_version = t1.version
       FROM product_component_version t1
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC80")))
      t)
    ELSE
     FROM (
      (
      (SELECT
       orcl_version = t1.version_full
       FROM product_component_version t1
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC160")))
      t)
    ENDIF
    INTO "nl:"
    DETAIL
     dm2_rdbms_version->version = t.orcl_version
    WITH nocounter
   ;end select
   IF (check_error("Getting product component version")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Product component version not found."
    SET dm_err->eproc = "Getting product component version"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   WHILE (dgrv_loop=0)
     SET dgrv_level = (dgrv_level+ 1)
     SET dgrv_prev_loc = dgrv_loc
     SET dgrv_loc = 0
     SET dgrv_loc = findstring(".",dm2_rdbms_version->version,(dgrv_prev_loc+ 1),0)
     IF (((dgrv_loc > 0) OR (dgrv_loc=0
      AND dgrv_level > 1)) )
      IF (dgrv_loc=0
       AND dgrv_level > 1)
       SET dgrv_len = (textlen(dm2_rdbms_version->version) - dgrv_prev_loc)
       SET dgrv_loop = 1
      ELSE
       SET dgrv_len = ((dgrv_loc - dgrv_prev_loc) - 1)
      ENDIF
      CASE (dgrv_level)
       OF 1:
        SET dm2_rdbms_version->level1 = cnvtint(substring(1,dgrv_len,dm2_rdbms_version->version))
       OF 2:
        SET dm2_rdbms_version->level2 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 3:
        SET dm2_rdbms_version->level3 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 4:
        SET dm2_rdbms_version->level4 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 5:
        SET dm2_rdbms_version->level5 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       ELSE
        SET dgrv_loop = 1
      ENDCASE
     ELSE
      IF (dgrv_level=1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Product component version not in expected format."
       SET dm_err->eproc = "Getting product component version"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      SET dgrv_loop = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 IF ((validate(daic_rac_inst_data->instance_cnt,- (999))=- (999))
  AND validate(daic_rac_inst_data->instance_cnt,999)=999)
  FREE RECORD daic_rac_inst_data
  RECORD daic_rac_inst_data(
    1 instance_cnt = i4
    1 qual[*]
      2 inst_id = i4
      2 instance_name = vc
      2 host_name = vc
      2 partial_host_name = vc
      2 thread_number = i4
  )
 ENDIF
 DECLARE dm2_active_instance_count(instance_count=i4(ref)) = i2
 IF ((validate(ddr_cerner_services->service_cnt,- (999))=- (999))
  AND validate(ddr_cerner_services->service_cnt,999)=999)
  FREE RECORD ddr_cerner_services
  RECORD ddr_cerner_services(
    1 template_id = f8
    1 dbname_suffix = vc
    1 service_cnt = i4
    1 service[*]
      2 service_name = vc
  )
 ENDIF
 DECLARE dm2_ds_get_service_list(template_id=f8) = i2
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
 DECLARE dm2_ping(host_name=vc) = i2
 SUBROUTINE dm2_ping(host_name)
  SET dm_err->eproc = concat("Ping host ",host_name)
  IF ((dm2_sys_misc->cur_os IN ("LNX", "AIX")))
   RETURN(dm2_push_dcl(concat("ping -c 1 ",host_name)))
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   RETURN(dm2_push_dcl(concat("tcpip ping /number_packets=1 ",host_name)))
  ELSEIF ((dm2_sys_misc->cur_os="HPX"))
   RETURN(dm2_push_dcl(concat("ping ",host_name," -n 1")))
  ELSE
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Operating System not supported."
   RETURN(0)
  ENDIF
 END ;Subroutine
 DECLARE ddm_dbname_suffix = vc WITH protect, noconstant("")
 DECLARE ddm_db_name = vc WITH protect, noconstant("")
 DECLARE ddm_instance_count = i4 WITH protect, noconstant(0)
 DECLARE ddm_line = vc WITH protect, noconstant(fillstring(120,"-"))
 DECLARE ddm_iter = i4 WITH protect, noconstant(0)
 DECLARE ddm_iter2 = i4 WITH protect, noconstant(0)
 DECLARE ddm_menu_1 = i2 WITH protect, noconstant(1)
 DECLARE ddm_menu_2 = i2 WITH protect, noconstant(1)
 DECLARE ddm_menu_3 = i2 WITH protect, noconstant(1)
 DECLARE ddm_temp_line = vc WITH protect, noconstant("")
 DECLARE ddm_db_domain = vc WITH protect, noconstant("")
 DECLARE ddm_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE ddm_sub_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE ddm_push_cmd = vc WITH protect, noconstant("")
 DECLARE ddm_temp_num = i4 WITH protect, noconstant(0)
 DECLARE ddm_template_id = f8 WITH protect, noconstant(0.0)
 DECLARE ddm_message = vc WITH protect, noconstant("")
 FREE RECORD dsms_svc
 RECORD dsms_svc(
   1 svc_cnt = i4
   1 svc[*]
     2 service_name = vc
     2 all_active = i2
     2 all_inactive = i2
     2 inst_cnt = i2
     2 inst[*]
       3 status = vc
       3 instance = vc
   1 inst_cnt = i2
   1 inst[*]
     2 inst_id = i4
     2 inst_name = vc
     2 host_name = vc
     2 service_cnt = i2
     2 service[*]
       3 service_name = vc
     2 service_list = vc
 )
 FREE RECORD dsms_active_svc_data
 RECORD dsms_active_svc_data(
   1 service_name = vc
   1 active_inst_cnt = i4
   1 qual[*]
     2 inst_id = i4
 )
 DECLARE ddm_load_services(null) = i2
 DECLARE ddm_display_services_report(null) = i2
 SET message = nowindow
 SET width = 132
 IF ( NOT (check_logfile("dm2_ds_menu",".log","dm2_ds_menu")))
  GO TO exit_script
 ENDIF
 IF ( NOT (dm2_get_rdbms_version(null)))
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Validate oracle version."
 IF ((((dm2_rdbms_version->level1 < 10)) OR ((dm2_rdbms_version->level1=10)
  AND (dm2_rdbms_version->level2 < 1))) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "DM2_DS_MENU is only supported for Oracle 10 release 1 or above"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ( NOT (validate(dm2_ddm_ccl_override)))
  IF (((((currev * 1000000)+ (currevminor * 1000))+ currevminor2) < 8003011))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "DM2_DS_MENU is only supported for CCL 8.3.11 or higher."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ( NOT (dm2_get_dbase_name(ddm_db_name)))
  GO TO exit_script
 ENDIF
 SET ddm_dbname_suffix = concat("_",cnvtlower(ddm_db_name))
 IF ((dm_err->debug_flag > 0))
  CALL echo(build("dbname_suffix=",ddm_dbname_suffix))
 ENDIF
 IF ( NOT (dtr_query_tns_details(null)))
  GO TO exit_script
 ENDIF
 SET ddm_db_domain = dtr_tns_details->desired_db_domain
 SET ddr_cerner_services->dbname_suffix = ddm_dbname_suffix
 IF ( NOT (dm2_ds_get_service_list(ddm_template_id)))
  GO TO exit_script
 ENDIF
 IF ( NOT (dm2_active_instance_count(ddm_instance_count)))
  GO TO exit_script
 ENDIF
 SET stat = alterlist(dtr_instance_data->qual,daic_rac_inst_data->instance_cnt)
 FOR (ddm_iter = 1 TO daic_rac_inst_data->instance_cnt)
   SET dtr_instance_data->qual[ddm_iter].port_number = 1521
 ENDFOR
 WHILE (true)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Cerner Database Services")
   CALL text(2,85,concat("Database: ",ddm_db_name))
   CALL text(4,10,"1. Show Current Cerner Database Services")
   CALL text(6,10,"2. Manage Cerner Database Services")
   CALL text(8,10,"3. Generate Cerner Database Services TNSNAMES.ORA Entries")
   CALL text(10,10,"4. Test Cerner Database Services Connectivity")
   CALL text(12,10,"5. Manage Millennium Server Usage of Cerner Database Services")
   CALL text(16,10,"Your Selection (0 to Exit)?")
   CALL accept(16,38,"9;",0
    WHERE curaccept IN (0, 1, 2, 3, 4,
    5))
   CASE (curaccept)
    OF 0:
     GO TO exit_script
    OF 1:
     CALL clear(1,1)
     SET message = nowindow
     IF ( NOT (ddm_load_services(null)))
      GO TO exit_script
     ENDIF
     IF ( NOT (ddm_display_services_report(null)))
      GO TO exit_script
     ENDIF
    OF 2:
     SET ddm_menu_1 = 1
     SET ddm_message = ""
     WHILE (ddm_menu_1)
       SET message = window
       CALL clear(1,1)
       CALL box(1,1,24,131)
       CALL text(2,2,"Manage Cerner Database Services")
       CALL text(2,85,concat("Database: ",ddm_db_name))
       CALL text(4,10,"1. Activate All Cerner Database Services On All Nodes")
       CALL text(23,2,ddm_message)
       CALL text(8,10,"Your Selection (0 to Exit)?")
       CALL accept(8,38,"9;",0
        WHERE curaccept IN (0, 1))
       CASE (curaccept)
        OF 0:
         SET ddm_menu_1 = 0
        OF 1:
         SET message = nowindow
         CALL clear(1,1)
         SET dm2_process_event_rs->status = dpl_executing
         CALL dm2_process_log_row(dpl_db_services,dpl_activate_all,dpl_no_prev_id,1)
         SET ddm_log_id = dm2_process_event_rs->dm_process_event_id
         IF ( NOT (ddm_load_services(null)))
          GO TO exit_script
         ENDIF
         FOR (ddm_iter = 1 TO dsms_svc->inst_cnt)
           SET dsms_svc->inst[ddm_iter].service_list = "service_names="
           FOR (ddm_iter2 = 1 TO ddr_cerner_services->service_cnt)
             SET dsms_svc->inst[ddm_iter].service_list = concat(dsms_svc->inst[ddm_iter].service_list,
              "'",ddr_cerner_services->service[ddm_iter2].service_name,"',")
           ENDFOR
           FOR (ddm_iter2 = 1 TO dsms_svc->inst[ddm_iter].service_cnt)
             IF ( NOT (findstring(build("'",dsms_svc->inst[ddm_iter].service[ddm_iter2].service_name,
               "'"),dsms_svc->inst[ddm_iter].service_list)))
              SET dsms_svc->inst[ddm_iter].service_list = concat(dsms_svc->inst[ddm_iter].
               service_list,"'",dsms_svc->inst[ddm_iter].service[ddm_iter2].service_name,"',")
             ENDIF
           ENDFOR
           SET dsms_svc->inst[ddm_iter].service_list = concat(substring(1,(size(dsms_svc->inst[
              ddm_iter].service_list) - 1),dsms_svc->inst[ddm_iter].service_list))
           IF (dtr_tns_details->spfile_ind)
            SET ddm_push_cmd = concat('RDB ASIS("ALTER SYSTEM SET ',dsms_svc->inst[ddm_iter].
             service_list," SCOPE=BOTH SID='",dsms_svc->inst[ddm_iter].inst_name,^'") go^)
            SET dm2_process_event_rs->status = dpl_executing
            CALL dm2_process_log_add_detail_text(dpl_inst_name,dsms_svc->inst[ddm_iter].inst_name)
            CALL dm2_process_log_add_detail_text(dpl_cmd,ddm_push_cmd)
            CALL dm2_process_log_row(dpl_db_services,dpl_instance_activation,dpl_no_prev_id,1)
            SET ddm_sub_log_id = dm2_process_event_rs->dm_process_event_id
            IF ( NOT (dm2_push_cmd(ddm_push_cmd,1)))
             SET dm2_process_event_rs->status = dpl_failure
             SET dm2_process_event_rs->message = dm_err->emsg
             CALL dm2_process_log_row(dpl_db_services,dpl_instance_activation,ddm_sub_log_id,1)
             SET dm2_process_event_rs->status = dpl_failure
             SET dm2_process_event_rs->message = dm_err->emsg
             CALL dm2_process_log_row(dpl_db_services,dpl_activate_all,ddm_log_id,1)
             GO TO exit_script
            ELSE
             SET dm2_process_event_rs->status = dpl_success
             CALL dm2_process_log_row(dpl_db_services,dpl_instance_activation,ddm_sub_log_id,1)
            ENDIF
           ENDIF
         ENDFOR
         SET dm2_process_event_rs->status = dpl_success
         CALL dm2_process_log_row(dpl_db_services,dpl_activate_all,ddm_log_id,1)
         IF (dtr_tns_details->spfile_ind)
          SET ddm_message = "Services were successfully activated."
         ELSE
          SET dm_err->eproc = "Generating report to CCL Displayer for init.ora changes."
          SELECT INTO "mine"
           FROM (dummyt d  WITH seq = value(dsms_svc->inst_cnt))
           HEAD REPORT
            col 0, "This database is not using an SPFILE.", row + 1,
            col 0,
            "The following entries will need to be made into the appropriate init.ora files as shown below:",
            row + 1,
            col 0, "", row + 1,
            col 0, "", row + 1,
            col 0, "", row + 1,
            col 0, "", row + 1
           DETAIL
            col 0, dsms_svc->inst[d.seq].inst_name, " on ",
            dsms_svc->inst[d.seq].host_name, ":", row + 1,
            col 5, dsms_svc->inst[d.seq].service_list, row + 1,
            col 0, "", row + 1
           WITH nocounter, maxrow = 1, maxcol = 2000
          ;end select
          IF (check_error(dm_err->eproc))
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_script
          ENDIF
         ENDIF
       ENDCASE
     ENDWHILE
    OF 3:
     SET ddm_menu_2 = 1
     WHILE (ddm_menu_2)
       IF ( NOT (dtr_get_tns_details(null)))
        SET ddm_menu_2 = 0
       ELSE
        IF ( NOT (dtr_get_host_port_numbers(null)))
         SET ddm_menu_2 = 0
        ELSE
         SET ddm_menu_2 = 0
         SET dtr_instance_data->ping_fail_ind = 0
         FOR (ddm_iter = 1 TO least(16,daic_rac_inst_data->instance_cnt))
           IF ( NOT (dm2_ping(concat(daic_rac_inst_data->qual[ddm_iter].partial_host_name,
             dtr_tns_details->vip_extension))))
            SET dtr_instance_data->qual[ddm_iter].ping_fail_ind = 1
            SET dtr_instance_data->qual[ddm_iter].emsg = dm_err->emsg
            SET dtr_instance_data->ping_fail_ind = 1
            SET ddm_menu_2 = 1
            SET dm_err->err_ind = 0
           ELSE
            SET dtr_instance_data->qual[ddm_iter].ping_fail_ind = 0
           ENDIF
         ENDFOR
         IF ((dtr_instance_data->ping_fail_ind=1))
          SET dm_err->eproc = "Displaying VIP network connectivity test report to the screen."
          SELECT INTO "mine"
           FROM (dummyt d  WITH seq = value(daic_rac_inst_data->instance_cnt))
           HEAD REPORT
            col 0, "Network VIP Connectivity Test Report", row + 1,
            row + 2, col 0,
            "A 'ping' command was issued for all VIP hosts to validate they are operational",
            row + 1, col 0, "and on the network.",
            row + 1, row + 2, col 0,
            "For any failures, please ensure the following:", row + 1, col 0,
            "1) The proper Oracle VIP Extension was specified.", row + 1, col 0,
            "2) This node has network connectivity to the database hosts.", row + 1, row + 2,
            col 0, "VIP Host Name", col 51,
            "Status", col 61, "Message",
            row + 1, col 0,
            CALL print(fillstring(50,"-")),
            col 51,
            CALL print(fillstring(9,"-")), col 61,
            CALL print(fillstring(60,"-")), row + 1
           DETAIL
            col 0,
            CALL print(concat(daic_rac_inst_data->qual[d.seq].partial_host_name,dtr_tns_details->
             vip_extension)), col 51,
            CALL print(evaluate(dtr_instance_data->qual[d.seq].ping_fail_ind,0,"SUCCESS","FAILURE"))
            IF (dtr_instance_data->qual[d.seq].ping_fail_ind)
             col 61,
             CALL print(substring(1,60,dtr_instance_data->qual[d.seq].emsg))
            ENDIF
            row + 1
           FOOT REPORT
            row + 1, col 0, ddm_line,
            row + 1, col 0, "End of Report"
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc))
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_script
          ENDIF
         ELSE
          IF ( NOT (dtr_populate_all_tns_stanzas(null)))
           GO TO exit_script
          ENDIF
          IF ( NOT (dtr_display_tns_report(null)))
           GO TO exit_script
          ENDIF
          CALL dtr_prompt_tns_confirmation(null)
         ENDIF
        ENDIF
       ENDIF
     ENDWHILE
    OF 4:
     IF ((dm2_install_schema->v500_p_word="NONE")
      AND (dm2_install_schema->v500_connect_str="NONE"))
      SET dm2_install_schema->u_name = "V500"
      SET dm2_install_schema->dbase_name = ddm_db_name
      SET dm2_install_schema->connect_str = ddm_db_name
      EXECUTE dm2_connect_to_dbase "PC"
      IF (dm_err->err_ind)
       GO TO exit_script
      ENDIF
      SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
      SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
     ENDIF
     SET dtr_connectivity->cnt = 0
     SET stat = alterlist(dtr_connectivity->qual,0)
     FOR (ddm_iter = 1 TO daic_rac_inst_data->instance_cnt)
       SET dtr_connectivity->cnt = (dtr_connectivity->cnt+ 1)
       SET stat = alterlist(dtr_connectivity->qual,dtr_connectivity->cnt)
       SET dtr_connectivity->qual[dtr_connectivity->cnt].connect_string = daic_rac_inst_data->qual[
       ddm_iter].instance_name
     ENDFOR
     SET dtr_connectivity->cnt = (dtr_connectivity->cnt+ 1)
     SET stat = alterlist(dtr_connectivity->qual,dtr_connectivity->cnt)
     SET dtr_connectivity->qual[dtr_connectivity->cnt].connect_string = cnvtlower(ddm_db_name)
     FOR (ddm_iter = 1 TO ddr_cerner_services->service_cnt)
       SET dtr_connectivity->cnt = (dtr_connectivity->cnt+ 1)
       SET stat = alterlist(dtr_connectivity->qual,dtr_connectivity->cnt)
       SET dtr_connectivity->qual[dtr_connectivity->cnt].connect_string = ddr_cerner_services->
       service[ddm_iter].service_name
     ENDFOR
     IF ( NOT (dtr_service_connectivity_test(null)))
      GO TO exit_script
     ENDIF
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     SET dm2_install_schema->dbase_name = ddm_db_name
     EXECUTE dm2_connect_to_dbase "CO"
     IF (dm_err->err_ind)
      GO TO exit_script
     ENDIF
    OF 5:
     EXECUTE dm2_ds_reg_maint "ASSIGN ALL"
     IF (dm_err->err_ind)
      GO TO exit_script
     ENDIF
   ENDCASE
 ENDWHILE
 SUBROUTINE ddm_display_services_report(null)
   SET dm_err->eproc = "Display Services Report"
   SELECT INTO mine
    FROM dummyt d
    HEAD REPORT
     inst_idx = 0, svc_idx = 0
    DETAIL
     col 0, "Cerner Database Services", col 60,
     "Database: ", ddm_db_name, row + 1,
     col 0, "", row + 1,
     col 0,
     CALL print(concat(
      "This report will display the Cerner Database Services that are active on currently",
      " active database instances.")), row + 1,
     col 0, "", row + 1,
     col 0, "DBinstance", col 20,
     "Hostname", row + 1, col 0,
     ddm_line, row + 1
     FOR (inst_idx = 1 TO daic_rac_inst_data->instance_cnt)
       col 0, daic_rac_inst_data->qual[inst_idx].instance_name, col 20,
       daic_rac_inst_data->qual[inst_idx].partial_host_name, row + 1
     ENDFOR
     col 0, "", row + 1,
     col 0, "", row + 1,
     col 0, "", row + 1,
     col 0, "Service Name", col 50,
     "Status", col 70, "Instance",
     row + 1, col 0, ddm_line,
     row + 1
     FOR (svc_idx = 1 TO dsms_svc->svc_cnt)
       IF ((dsms_svc->svc[svc_idx].all_active=1))
        col 0, dsms_svc->svc[svc_idx].service_name, col 50,
        "ACTIVE", col 70, "ALL",
        row + 1
       ELSEIF ((dsms_svc->svc[svc_idx].all_inactive=1))
        col 0, dsms_svc->svc[svc_idx].service_name, col 50,
        "INACTIVE", col 70, "ALL",
        row + 1
       ELSE
        col 0, dsms_svc->svc[svc_idx].service_name, col 50,
        "ACTIVE", ddm_temp_line = "~"
        FOR (inst_idx = 1 TO dsms_svc->svc[svc_idx].inst_cnt)
          IF ((dsms_svc->svc[svc_idx].inst[inst_idx].status="ACTIVE"))
           ddm_temp_line = concat(ddm_temp_line,", ",dsms_svc->svc[svc_idx].inst[inst_idx].instance)
          ENDIF
        ENDFOR
        col 70,
        CALL print(substring(4,size(ddm_temp_line),ddm_temp_line)), row + 1
       ENDIF
     ENDFOR
    FOOT REPORT
     row + 1, col 0, ddm_line,
     row + 1, col 0, "End of Report"
    WITH nocounter, maxrow = 1, maxcol = 300,
     formfeed = none
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddm_load_services(null)
   SET stat = initrec(dsms_svc)
   SET dm_err->eproc = "Load all Services into record from dm_ds_service/gv$active_services"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ds_service d,
     gv$active_services a
    WHERE outerjoin(concat(trim(cnvtlower(d.service_name)),ddm_dbname_suffix))=cnvtlower(a.name)
    ORDER BY d.service_name, a.inst_id
    HEAD REPORT
     rac_inst = 0, active_inst_idx = 0
    HEAD d.service_name
     dsms_svc->svc_cnt = (dsms_svc->svc_cnt+ 1), stat = alterlist(dsms_svc->svc,dsms_svc->svc_cnt),
     dsms_svc->svc[dsms_svc->svc_cnt].service_name = concat(trim(cnvtlower(d.service_name)),
      ddm_dbname_suffix),
     dsms_active_svc_data->active_inst_cnt = 0, stat = alterlist(dsms_active_svc_data->qual,0),
     dsms_active_svc_data->service_name = d.service_name
    DETAIL
     dsms_active_svc_data->active_inst_cnt = (dsms_active_svc_data->active_inst_cnt+ 1), stat =
     alterlist(dsms_active_svc_data->qual,dsms_active_svc_data->active_inst_cnt),
     dsms_active_svc_data->qual[dsms_active_svc_data->active_inst_cnt].inst_id = a.inst_id
    FOOT  d.service_name
     dsms_svc->svc[dsms_svc->svc_cnt].inst_cnt = daic_rac_inst_data->instance_cnt, stat = alterlist(
      dsms_svc->svc[dsms_svc->svc_cnt].inst,daic_rac_inst_data->instance_cnt)
     IF ((dsms_active_svc_data->active_inst_cnt=daic_rac_inst_data->instance_cnt))
      dsms_svc->svc[dsms_svc->svc_cnt].all_active = 1
     ELSEIF ((dsms_active_svc_data->active_inst_cnt=1)
      AND (dsms_active_svc_data->qual[1].inst_id=0.0))
      dsms_svc->svc[dsms_svc->svc_cnt].all_inactive = 1
     ENDIF
     FOR (rac_inst = 1 TO daic_rac_inst_data->instance_cnt)
      IF ((dsms_svc->svc[dsms_svc->svc_cnt].all_active=1))
       dsms_svc->svc[dsms_svc->svc_cnt].inst[rac_inst].status = "ACTIVE"
      ELSEIF ((dsms_svc->svc[dsms_svc->svc_cnt].all_inactive=1))
       dsms_svc->svc[dsms_svc->svc_cnt].inst[rac_inst].status = "INACTIVE"
      ELSE
       active_inst_idx = 0, active_inst_idx = locateval(active_inst_idx,1,dsms_active_svc_data->
        active_inst_cnt,daic_rac_inst_data->qual[rac_inst].inst_id,dsms_active_svc_data->qual[
        active_inst_idx].inst_id)
       IF (active_inst_idx > 0)
        dsms_svc->svc[dsms_svc->svc_cnt].inst[rac_inst].status = "ACTIVE"
       ELSE
        dsms_svc->svc[dsms_svc->svc_cnt].inst[rac_inst].status = "INACTIVE"
       ENDIF
      ENDIF
      ,dsms_svc->svc[dsms_svc->svc_cnt].inst[rac_inst].instance = daic_rac_inst_data->qual[rac_inst].
      instance_name
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Querying for services per instance in gv$instance/gv$active_services."
   SELECT INTO "nl:"
    FROM gv$active_services gvas,
     gv$instance gvi
    WHERE gvi.inst_id=gvas.inst_id
     AND gvas.network_name IS NOT null
    ORDER BY gvas.inst_id, gvas.name
    HEAD REPORT
     dsms_svc->inst_cnt = 0, stat = alterlist(dsms_svc->inst,0)
    HEAD gvas.inst_id
     dsms_svc->inst_cnt = (dsms_svc->inst_cnt+ 1), stat = alterlist(dsms_svc->inst,dsms_svc->inst_cnt
      ), dsms_svc->inst[dsms_svc->inst_cnt].inst_id = gvas.inst_id,
     dsms_svc->inst[dsms_svc->inst_cnt].inst_name = gvi.instance_name, dsms_svc->inst[dsms_svc->
     inst_cnt].host_name = gvi.host_name
    DETAIL
     IF (gvas.name != cnvtlower(concat(ddm_db_name,".",ddm_db_domain)))
      dsms_svc->inst[dsms_svc->inst_cnt].service_cnt = (dsms_svc->inst[dsms_svc->inst_cnt].
      service_cnt+ 1), stat = alterlist(dsms_svc->inst[dsms_svc->inst_cnt].service,dsms_svc->inst[
       dsms_svc->inst_cnt].service_cnt), dsms_svc->inst[dsms_svc->inst_cnt].service[dsms_svc->inst[
      dsms_svc->inst_cnt].service_cnt].service_name = gvas.name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dsms_svc)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (dm_err->err_ind)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ELSE
  SET dm_err->eproc = "dm2_ds_menu has completed"
 ENDIF
 CALL final_disp_msg("dm2_ds_menu")
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
 SUBROUTINE dtr_parse_tns(dpt_fl,dpt_fn)
   DECLARE dpt_file_location = vc WITH protect, noconstant(dpt_fl)
   DECLARE dpt_file_name = vc WITH protect, noconstant(dpt_fn)
   DECLARE dpt_file_loc = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE rline_nospaces = vc WITH protect, noconstant("DM2NOTSET")
   IF ( NOT (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")))
    IF ((tnswork->inst_cnt=0))
     SET dm_err->eproc = "Loading database instances."
     SELECT INTO "nl:"
      g.instance_name, g.host_name
      FROM gv$instance g
      DETAIL
       tnswork->inst_cnt = (tnswork->inst_cnt+ 1), stat = alterlist(tnswork->inst,tnswork->inst_cnt),
       tnswork->inst[tnswork->inst_cnt].instance_name = g.instance_name,
       tnswork->inst[tnswork->inst_cnt].host_name = g.host_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) > 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dpt_file_location <= "")
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dpt_file_location = "ora_root:[network.admin]"
    ELSE
     SET dpt_file_location = build(logical("ORACLE_HOME"),"/network/admin/")
    ENDIF
   ENDIF
   IF (dpt_file_name="")
    SET dpt_file_name = "tnsnames.ora"
   ENDIF
   FREE DEFINE rtl3
   FREE SET dpt_file_loc
   SET logical dpt_file_loc value(build(dpt_file_location,dpt_file_name))
   DEFINE rtl3 "dpt_file_loc"
   SET dm_err->eproc = build("Parsing <",dpt_file_location,dpt_file_name,">")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    r.line
    FROM rtl3t r
    HEAD REPORT
     charcnt = 0, newtnskeyline = 1, openparen_cnt = 0,
     closeparen_cnt = 0, connectdata_cnt = 0, description_cnt = 0,
     addresslist_cnt = 0, test_cnt = 0
    DETAIL
     test_cnt = (test_cnt+ 1), rline_nospaces = cnvtlower(trim(r.line,4))
     IF (rline_nospaces > "")
      IF (substring(1,1,rline_nospaces)="#")
       IF (newtnskeyline=1)
        tnswork->cnt = (tnswork->cnt+ 1), stat = alterlist(tnswork->qual,tnswork->cnt)
       ENDIF
       tnswork->qual[tnswork->cnt].tns_key = " ", tnswork->qual[tnswork->cnt].tns_key_type_cd = 1,
       tnswork->qual[tnswork->cnt].line_cnt = (tnswork->qual[tnswork->cnt].line_cnt+ 1),
       stat = alterlist(tnswork->qual[tnswork->cnt].qual,tnswork->qual[tnswork->cnt].line_cnt)
       IF ((tnswork->qual[tnswork->cnt].line_cnt > 1)
        AND substring(1,1,r.line) != " ")
        tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = concat(" ",r
         .line), tnswork->qual[tnswork->cnt].chg_format_ind = 1
       ELSE
        tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = r.line
       ENDIF
      ELSE
       IF (((connectdata_cnt > 1) OR (((description_cnt > 1) OR (addresslist_cnt > 1)) )) )
        dm_err->emsg = concat("The TNS Key ",tnswork->qual[tnswork->cnt].tns_key,
         " appears to have mismatching parentheses."), dm_err->user_action =
        "Please correct the tnsnames.ora file and try again.", dm_err->err_ind = 1,
        BREAK
       ELSE
        IF (newtnskeyline=1)
         tnswork->cnt = (tnswork->cnt+ 1), stat = alterlist(tnswork->qual,tnswork->cnt), tnswork->
         qual[tnswork->cnt].tns_key_type_cd = 2,
         tnswork->qual[tnswork->cnt].tns_key_full = substring(1,(findstring("=",rline_nospaces) - 1),
          rline_nospaces), tnswork->qual[tnswork->cnt].tns_key = substring(1,(findstring(".",
           rline_nospaces) - 1),rline_nospaces), tnswork->qual[tnswork->cnt].db_domain = substring((
          findstring(".",rline_nospaces)+ 1),(findstring("=",rline_nospaces) - 1),rline_nospaces),
         newtnskeyline = 0
        ENDIF
        IF ((tnswork->qual[tnswork->cnt].tns_key=concat("listeners_",tnswork->db_name)))
         IF (newtnskeyline=1
          AND (tnswork->db_domain="DM2NOTSET"))
          tnswork->db_domain = substring((findstring(".",rline_nospaces)+ 1),(findstring("=",
            rline_nospaces) - 1),rline_nospaces)
         ELSE
          IF ((((tnswork->db_vip_ext="DM2NOTSET")) OR ((((tnswork->db_host_name="DM2NOTSET")) OR ((
          tnswork->db_host_clause="DM2NOTSET"))) ))
           AND findstring("host=",rline_nospaces) > 0)
           FOR (instcnt = 1 TO tnswork->inst_cnt)
            host_pos = findstring(concat("host=",tnswork->inst[instcnt].host_name),rline_nospaces),
            IF (host_pos > 0)
             tnswork->db_host_name = tnswork->inst[instcnt].host_name, tnswork->db_host_clause =
             substring((host_pos+ 5),findstring(")",rline_nospaces,host_pos),rline_nospaces), tnswork
             ->db_vip_ext = substring(((host_pos+ size(tnswork->inst[instcnt].host_name))+ 5),
              findstring(")",rline_nospaces,host_pos),rline_nospaces)
            ENDIF
           ENDFOR
          ENDIF
          IF ((tnswork->db_port="DM2NOTSET")
           AND findstring("port=",rline_nospaces) > 0)
           port_pos = (findstring("port=",rline_nospaces)+ 5), tnswork->db_port = substring(port_pos,
            findstring(")",rline_nospaces,host_pos),rline_nospaces)
          ENDIF
         ENDIF
        ENDIF
        IF (findstring("load_balance",rline_nospaces)=0)
         tnswork->qual[tnswork->cnt].line_cnt = (tnswork->qual[tnswork->cnt].line_cnt+ 1), stat =
         alterlist(tnswork->qual[tnswork->cnt].qual,tnswork->qual[tnswork->cnt].line_cnt)
         IF ((tnswork->qual[tnswork->cnt].line_cnt=1))
          tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = trim(r.line,2
           )
         ELSEIF (substring(1,1,r.line)=" ")
          tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = r.line
         ELSE
          tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = concat(" ",r
           .line), tnswork->qual[tnswork->cnt].chg_format_ind = 1
         ENDIF
        ENDIF
        IF (findstring("CONNECT_DATA",rline_nospaces) > 0)
         connectdata_cnt = (connectdata_cnt+ 1)
        ENDIF
        IF (findstring("DESCRIPTION",rline_nospaces) > 0)
         description_cnt = (description_cnt+ 1)
        ENDIF
        IF (findstring("ADDRESS_LIST",rline_nospaces) > 0)
         addresslist_cnt = (addresslist_cnt+ 1)
        ENDIF
        FOR (charcnt = 1 TO size(rline_nospaces))
          IF (substring(charcnt,1,rline_nospaces)="(")
           openparen_cnt = (openparen_cnt+ 1)
          ELSEIF (substring(charcnt,1,rline_nospaces)=")")
           closeparen_cnt = (closeparen_cnt+ 1)
          ENDIF
        ENDFOR
        IF (openparen_cnt > 0
         AND ((openparen_cnt - closeparen_cnt)=0))
         newtnskeyline = 1, connectdata_cnt = 0, description_cnt = 0,
         addresslist_cnt = 0, openparen_cnt = 0, closeparen_cnt = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_copy_to_tnstgt(null)
   DECLARE tmpcnt1 = i4 WITH protect, noconstant(0)
   DECLARE tmpcnt2 = i4 WITH protect, noconstant(0)
   IF ((tnstgt->cnt > 0))
    FOR (tmpcnt1 = 1 TO tnstgt->cnt)
     SET tnstgt->qual[tmpcnt1].line_cnt = 0
     SET stat = alterlist(tnstgt->qual[tmpcnt1].qual,tnstgt->qual[tmpcnt1].line_cnt)
    ENDFOR
   ENDIF
   SET tnstgt->cnt = 0
   SET stat = alterlist(tnstgt->qual,tnstgt->cnt)
   SET tnstgt->cnt = tnswork->cnt
   SET stat = alterlist(tnstgt->qual,tnstgt->cnt)
   SET tmpcnt = 0
   SET tnstgt->db_vip_ext = tnswork->db_vip_ext
   SET tnstgt->db_port = tnswork->db_port
   SET tnstgt->db_domain = tnswork->db_domain
   FOR (tmpcnt1 = 1 TO tnswork->cnt)
     SET tnstgt->qual[tmpcnt1].mod_ind = 0
     SET tnstgt->qual[tmpcnt1].tns_key = tnswork->qual[tmpcnt1].tns_key
     SET tnstgt->qual[tmpcnt1].tns_key_full = tnswork->qual[tmpcnt1].tns_key_full
     SET tnstgt->qual[tmpcnt1].db_domain = tnswork->qual[tmpcnt1].db_domain
     SET tnstgt->qual[tmpcnt1].tns_key_type_cd = tnswork->qual[tmpcnt1].tns_key_type_cd
     SET tnstgt->qual[tmpcnt1].line_cnt = tnswork->qual[tmpcnt1].line_cnt
     IF ((tnstgt->qual[tmpcnt1].line_cnt > 0))
      SET stat = alterlist(tnstgt->qual[tmpcnt1].qual,tnstgt->qual[tmpcnt1].line_cnt)
      FOR (tmpcnt2 = 1 TO tnstgt->qual[tmpcnt1].line_cnt)
        SET tnstgt->qual[tmpcnt1].qual[tmpcnt2].text = tnswork->qual[tmpcnt1].qual[tmpcnt2].text
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_merge_to_tnstgt(null)
   DECLARE mrgcnt1 = i4 WITH protect, noconstant(0)
   DECLARE mrgcnt2 = i4 WITH protect, noconstant(0)
   DECLARE mrgloc = i4 WITH protect, noconstant(0)
   FOR (mrgcnt1 = 1 TO tnswork->cnt)
     IF ((tnswork->qual[mrgcnt1].merge_ind=1))
      SET mrgloc = locateval(mrgloc,1,tnstgt->cnt,tnswork->qual[mrgcnt1].tns_key,tnstgt->qual[mrgloc]
       .tns_key)
      IF (mrgloc > 0)
       SET tnstgt->qual[mrgloc].mod_ind = 2
       SET tnstgt->qual[mrgloc].tns_key_full = tnswork->qual[mrgcnt1].tns_key_full
       SET tnstgt->qual[mrgloc].db_domain = tnswork->qual[mrgcnt1].db_domain
       SET tnstgt->qual[mrgloc].tns_key_type_cd = tnswork->qual[mrgcnt1].tns_key_type_cd
       SET tnstgt->qual[mrgloc].line_cnt = tnswork->qual[mrgcnt1].line_cnt
       IF ((tnstgt->qual[mrgloc].line_cnt > 0))
        SET stat = alterlist(tnstgt->qual[mrgloc].qual,tnstgt->qual[mrgloc].line_cnt)
        FOR (mrgcnt2 = 1 TO tnstgt->qual[mrgloc].line_cnt)
          SET tnstgt->qual[mrgloc].qual[mrgcnt2].text = tnswork->qual[mrgcnt1].qual[mrgcnt2].text
        ENDFOR
       ENDIF
      ELSE
       SET tnstgt->cnt = (tnstgt->cnt+ 1)
       SET stat = alterlist(tnstgt->qual,tnstgt->cnt)
       SET tnstgt->qual[tnstgt->cnt].mod_ind = 1
       SET tnstgt->qual[tnstgt->cnt].tns_key = tnswork->qual[mrgcnt1].tns_key
       SET tnstgt->qual[tnstgt->cnt].tns_key_full = tnswork->qual[mrgcnt1].tns_key_full
       SET tnstgt->qual[tnstgt->cnt].db_domain = tnswork->qual[mrgcnt1].db_domain
       SET tnstgt->qual[tnstgt->cnt].tns_key_type_cd = tnswork->qual[mrgcnt1].tns_key_type_cd
       SET tnstgt->qual[tnstgt->cnt].line_cnt = tnswork->qual[mrgcnt1].line_cnt
       IF ((tnstgt->qual[tnstgt->cnt].line_cnt > 0))
        SET stat = alterlist(tnstgt->qual[tnstgt->cnt].qual,tnstgt->qual[tnstgt->cnt].line_cnt)
        FOR (mrgcnt2 = 1 TO tnstgt->qual[tnstgt->cnt].line_cnt)
          SET tnstgt->qual[tnstgt->cnt].qual[mrgcnt2].text = tnswork->qual[mrgcnt1].qual[mrgcnt2].
          text
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_reset_tnswork(null)
   IF ((tnswork->cnt > 0))
    FOR (tmpcnt1 = 1 TO tnswork->cnt)
      SET tnswork->qual[tmpcnt1].line_cnt = 0
      SET stat = alterlist(tnswork->qual[tmpcnt1].qual,tnswork->qual[tmpcnt1].line_cnt)
      SET tnswork->qual[tmpcnt1].tc_inst_cnt = 0
      SET stat = alterlist(tnswork->qual[tmpcnt1].tcl,tnswork->qual[tmpcnt1].tc_inst_cnt)
    ENDFOR
   ENDIF
   SET tnswork->cnt = 0
   SET stat = alterlist(tnswork->qual,tnswork->cnt)
   SET tnswork->db_name = "DM2NOTSET"
   SET tnswork->db_connected = 0
   SET tnswork->db_vip_ext = "DM2NOTSET"
   SET tnswork->db_port = "DM2NOTSET"
   SET tnswork->db_host_name = "DM2NOTSET"
   SET tnswork->db_host_clause = "DM2NOTSET"
   SET tnswork->db_domain = "DM2NOTSET"
   SET tnswork->tc_user = "DM2NOTSET"
   SET tnswork->tc_pwd = "DM2NOTSET"
   SET tnswork->inst_cnt = 0
   SET stat = alterlist(tnswork->inst,tnswork->inst_cnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_generate(dtg_file_location,dtg_file_name)
   DECLARE dtg_file_location2 = vc WITH protect, noconstant(trim(logical("CCLUSERDIR"),3))
   DECLARE dtg_file_name2 = vc WITH protect, noconstant("tnsnames.ora")
   DECLARE dtg_path_delim = vc WITH protect, noconstant("/")
   DECLARE dtg_report_str = vc WITH protect, noconstant("DM2NOTSET")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dtg_path_delim = ":"
   ENDIF
   SET dm_err->eproc = "Validating destination directory."
   IF (dtg_file_location > "")
    SET dtg_file_location2 = concat(trim(dtg_file_location,3),dtg_path_delim)
   ELSEIF (((dtg_file_location="ora_root:[network.admin]") OR (dtg_file_location=build(logical(
     "ORACLE_HOME"),"/network/admin/"))) )
    SET dm_err->emsg = "Cannot generate new tnsnames.ora file directly in the TNS_ADMIN directory."
    SET dm_err->err_ind = 1
   ELSE
    SET dtg_file_location2 = concat(dtg_file_location2,dtg_path_delim)
   ENDIF
   IF (dtg_file_name > "")
    SET dtg_file_name2 = dtg_file_name
   ENDIF
   SET dm_err->eproc = build("Generating <",dtg_file_location2,dtg_file_name2,">")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(build(dtg_file_location2,dtg_file_name2))
    d.seq
    FROM (dummyt d  WITH seq = tnstgt->cnt)
    HEAD REPORT
     rptseq = 0
    DETAIL
     rptseq = 0
     FOR (rptseq = 1 TO tnstgt->qual[d.seq].line_cnt)
       col + 0, tnstgt->qual[d.seq].qual[rptseq].text, row + 1
     ENDFOR
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 2000, format = lfstream
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_confirm(dtc_file_location,dtc_file_name)
   DECLARE dtc_user_viewed_ind = i2 WITH protect, noconstant(0)
   DECLARE dtc_done = i2 WITH protect, noconstant(0)
   DECLARE dtc_file_location2 = vc WITH protect, noconstant(trim(logical("CCLUSERDIR"),3))
   DECLARE dtc_file_name2 = vc WITH protect, noconstant("tnsnames.ora")
   DECLARE dtc_path_delim = vc WITH protect, noconstant("/")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dtc_path_delim = ":"
   ENDIF
   SET tns_reply->process = "tns_confirm"
   IF (dtc_file_location > "")
    SET dtc_file_location2 = concat(trim(dtc_file_location,3),dtc_path_delim)
   ELSE
    SET dtc_file_location2 = concat(dtc_file_location2,dtc_path_delim)
   ENDIF
   IF (dtc_file_name > "")
    SET dtc_file_name2 = trim(dtc_file_name,3)
   ENDIF
   SET width = 132
   SET message = window
   WHILE (dtc_done=0)
     CALL clear(1,1)
     CALL box(1,1,5,132)
     CALL text(3,44,"***  VERIFY TNSNAMES.ORA FILE  ***")
     CALL text(7,3,build("A new file named <",dtc_file_name2,"> has been generated to <",
       dtc_file_location2,">."))
     CALL text(8,3,"Please view and then confirm that the file is accurate before proceeding.")
     IF (dtc_user_viewed_ind=0)
      CALL text(10,3,"(V)iew, (E)xit")
      CALL accept(10,30,"P;CU","V"
       WHERE curaccept IN ("V", "E"))
     ELSE
      CALL text(10,3,"(V)iew, (C)onfirm, (E)xit")
      CALL accept(10,30,"P;CU","C"
       WHERE curaccept IN ("V", "C", "E"))
     ENDIF
     CASE (curaccept)
      OF "V":
       SET message = nowindow
       CALL echo(dm2_sys_misc->cur_os)
       CALL echo(build(dtc_file_location2,dtc_file_name2))
       FREE SET dtc_file_loc
       SET logical dtc_file_loc value(build(dtc_file_location2,dtc_file_name2))
       FREE DEFINE rtl2
       DEFINE rtl2 "dtc_file_loc"
       SELECT
        r.line
        FROM rtl2t r
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) > 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       SET dtc_user_viewed_ind = 1
       SET tns_reply->message = "File viewed"
       SET message = window
      OF "C":
       IF (dtc_user_viewed_ind=1)
        SET message = nowindow
        SET dtc_done = 1
       ENDIF
      OF "E":
       SET message = nowindow
       SET dm_err->emsg = "User chose to quit."
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_deploy(dtd_file_location,dtd_file_name)
   DECLARE dtd_file_location2 = vc WITH protect, noconstant(trim(logical("CCLUSERDIR"),3))
   DECLARE dtd_file_name2 = vc WITH protect, noconstant("tnsnames.ora")
   DECLARE dtd_path_delim = vc WITH protect, noconstant("/")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dtd_path_delim = ":"
   ENDIF
   SET tns_reply->process = "tns_deploy"
   IF (dtd_file_location > "")
    SET dtd_file_location2 = concat(trim(dtd_file_location,3),dtd_path_delim)
   ELSE
    SET dtd_file_location2 = concat(dtd_file_location2,dtd_path_delim)
   ENDIF
   IF (dtd_file_name > "")
    SET dtd_file_name2 = trim(dtd_file_name,3)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,5,132)
   CALL text(3,44,"***  DEPLOYMENT STEPS FOR TNSNAMES.ORA FILE  ***")
   CALL text(7,3,build("For each application and database node in the <",logical("environment"),
     "> environment, perform the following steps:"))
   CALL text(9,3,"1) Make a backup copy of the existing tnsnames.ora file.")
   CALL text(10,3,concat("2) From this node, copy file <",dtd_file_name2,"> from directory <",
     dtd_file_location2,">"))
   CALL text(11,3,concat(
     "   to the ORACLE_HOME/network/admin directory of each application and database node."))
   CALL text(13,3,
    "Please continue from this prompt ONLY AFTER the new tnsnames.ora file has been deployed ")
   CALL text(14,3,"successfully to all database and application nodes.")
   CALL text(16,3,"(C)ontinue, (E)xit")
   CALL accept(16,30,"P;CU","C"
    WHERE curaccept IN ("C", "E"))
   SET tns_reply->user_selection = curaccept
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_test_connect(null)
   DECLARE dttc_for_cnt = i4 WITH protect, noconstant(0)
   DECLARE dttc_done = i2 WITH protect, noconstant(0)
   DECLARE dttc_instance_str = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dttc_position_int = i4 WITH protect, noconstant(0)
   FOR (dttc_for_cnt = 1 TO tnswork->cnt)
     IF ((tnswork->qual[dttc_for_cnt].tc_option > 0))
      SET dttc_done = 0
      WHILE (dttc_done=0)
        SET dm_err->err_ind = 0
        SET dm2_install_schema->u_name = tnswork->tc_user
        SET dm2_install_schema->p_word = tnswork->tc_pwd
        SET dm2_install_schema->connect_str = tnswork->qual[dttc_for_cnt].tns_key
        EXECUTE dm2_connect_to_dbase "CO"
        IF ((dm_err->err_ind=0))
         IF ((tnswork->inst_cnt > 0))
          SET dm_err->eproc = ""
          SELECT INTO "nl:"
           i.instance_name, i.host_name
           FROM gv$instance i
           DETAIL
            tnswork->inst_cnt = (tnswork->inst_cnt+ 1), stat = alterlist(tnswork->inst,tnswork->
             inst_cnt), tnswork->inst[tnswork->inst_cnt].instance_name = i.instance_name,
            tnswork->inst[tnswork->inst_cnt].host_name = i.host_name
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc) > 0)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           RETURN(0)
          ENDIF
         ENDIF
         SET tnswork->qual[dttc_for_cnt].tc_num_connects = (tnswork->qual[dttc_for_cnt].
         tc_num_connects+ 1)
         SELECT INTO "nl:"
          v.instance_name
          FROM v$instance v
          DETAIL
           dttc_instance_str = v.instance_name
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc) > 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          RETURN(0)
         ENDIF
         SET dttc_position_int = locateval(dttc_position_int,1,tnswork->qual[dttc_for_cnt].
          tc_inst_cnt,dttc_instance_str,tnswork->qual[dttc_for_cnt].tcl[dttc_position_int].
          instance_name)
         IF (dttc_position_int=0)
          SET tnswork->qual[dttc_for_cnt].tc_inst_cnt = (tnswork->qual[dttc_for_cnt].tc_inst_cnt+ 1)
          SET stat = alterlist(tnswork->qual[dttc_for_cnt].tcl,tnswork->qual[dttc_for_cnt].
           tc_inst_cnt)
          SET tnswork->qual[dttc_for_cnt].tcl[tnswork->qual[dttc_for_cnt].tc_inst_cnt].instance_name
           = dttc_instance_str
         ENDIF
         IF ((((tnswork->qual[dttc_for_cnt].tc_option=2)) OR ((((tnswork->qual[dttc_for_cnt].
         tc_inst_cnt=tnswork->inst_cnt)) OR ((tnswork->qual[dttc_for_cnt].tc_num_connects=50))) )) )
          SET dttc_done = 1
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_get_tns_details(null)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Generate Cerner Database Services tnsnames.ora entries - Details")
     CALL text(4,2,"Please verify / supply the following database host information.")
     CALL text(6,2,"ORACLE VIP EXTENSION (e.g. '_oracle'): ")
     CALL video(r)
     CALL text(6,41,dtr_tns_details->vip_extension)
     CALL video(n)
     CALL text(7,2,concat(
       "This extension is appended to the host names to form a proper host name that represents the",
       " Oracle VIP for the database cluster."))
     CALL text(9,2,"db_domain (e.g. 'world'): ")
     CALL video(r)
     CALL text(9,28,dtr_tns_details->desired_db_domain)
     CALL video(n)
     CALL text(10,2,"This is the domain extension value to use for all generated connect strings.")
     CALL text(16,2,"(M)odify, (C)ontinue, (Q)uit: ")
     CALL accept(16,32,"A;CU","C"
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "Q":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(0)
      OF "M":
       CALL accept(6,41,"P(20);C",dtr_tns_details->vip_extension)
       SET dtr_tns_details->vip_extension = curaccept
       CALL accept(9,28,"A(50);C",dtr_tns_details->desired_db_domain)
       SET dtr_tns_details->desired_db_domain = curaccept
      OF "C":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(1)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dtr_get_host_port_numbers(null)
   DECLARE dghpn_iter = i4 WITH protect, noconstant(0)
   DECLARE dghpn_temp_num = i4 WITH protect, noconstant(0)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Generate Cerner Database Services tnsnames.ora entries - Listener Port Numbers")
     CALL text(4,7,"Host Name")
     CALL text(4,58,"Listener Port Number")
     CALL text(5,7,fillstring(50,"-"))
     CALL text(5,58,fillstring(20,"-"))
     FOR (dghpn_iter = 1 TO least(16,daic_rac_inst_data->instance_cnt))
       CALL text((5+ dghpn_iter),2,build(dghpn_iter,"."))
       CALL text((5+ dghpn_iter),7,daic_rac_inst_data->qual[dghpn_iter].partial_host_name)
       CALL text((5+ dghpn_iter),58,cnvtstring(dtr_instance_data->qual[dghpn_iter].port_number))
     ENDFOR
     CALL text(23,2,"(M)odify Port, (C)ontinue, (Q)uit: ")
     CALL accept(23,37,"A;CU","C"
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "Q":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(0)
      OF "M":
       CALL clear(23,2,129)
       CALL text(23,2,"Which host's listener port number would you like to change (e.g. 2)?")
       CALL accept(23,71,"99",0
        WHERE curaccept BETWEEN 0 AND 16)
       SET dghpn_temp_num = curaccept
       IF (dghpn_temp_num > 0
        AND (dghpn_temp_num <= daic_rac_inst_data->instance_cnt))
        CALL accept((5+ dghpn_temp_num),58,"999999")
        SET dtr_instance_data->qual[dghpn_temp_num].port_number = curaccept
       ENDIF
      OF "C":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(1)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dtr_import_tns_templates(null)
   SET stat = initrec(dtr_tns_templs)
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   SET logical ditt_file_loc "cer_install:dm2_tns_templ_svc.txt"
   DEFINE rtl "ditt_file_loc"
   SET dm_err->eproc = "Reading cer_install:dm2_tns_templ_svc.txt."
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dtr_tns_templs->cnt = (dtr_tns_templs->cnt+ 1), stat = alterlist(dtr_tns_templs->qual,
      dtr_tns_templs->cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].token_name = "<service>"
    DETAIL
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt = (dtr_tns_templs->qual[dtr_tns_templs->cnt].
     line_cnt+ 1), stat = alterlist(dtr_tns_templs->qual[dtr_tns_templs->cnt].lines,dtr_tns_templs->
      qual[dtr_tns_templs->cnt].line_cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].lines[
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt].line = r.line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   SET logical ditt_file_loc "cer_install:dm2_tns_templ_inst.txt"
   DEFINE rtl "ditt_file_loc"
   SET dm_err->eproc = "Reading cer_install:dm2_tns_templ_inst.txt."
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dtr_tns_templs->cnt = (dtr_tns_templs->cnt+ 1), stat = alterlist(dtr_tns_templs->qual,
      dtr_tns_templs->cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].token_name = "<instance>"
    DETAIL
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt = (dtr_tns_templs->qual[dtr_tns_templs->cnt].
     line_cnt+ 1), stat = alterlist(dtr_tns_templs->qual[dtr_tns_templs->cnt].lines,dtr_tns_templs->
      qual[dtr_tns_templs->cnt].line_cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].lines[
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt].line = r.line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   SET logical ditt_file_loc "cer_install:dm2_tns_templ_address.txt"
   DEFINE rtl "ditt_file_loc"
   SET dm_err->eproc = "Reading cer_install:dm2_tns_templ_address.txt."
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dtr_tns_templs->cnt = (dtr_tns_templs->cnt+ 1), stat = alterlist(dtr_tns_templs->qual,
      dtr_tns_templs->cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].token_name = "<address>"
    DETAIL
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt = (dtr_tns_templs->qual[dtr_tns_templs->cnt].
     line_cnt+ 1), stat = alterlist(dtr_tns_templs->qual[dtr_tns_templs->cnt].lines,dtr_tns_templs->
      qual[dtr_tns_templs->cnt].line_cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].lines[
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt].line = r.line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dtr_tns_templs)
   ENDIF
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_setup_tgt_template(token_name)
   DECLARE dstt_iter = i4 WITH protect, noconstant(0)
   DECLARE dstt_iter2 = i4 WITH protect, noconstant(0)
   DECLARE dstt_temp = i4 WITH protect, noconstant(0)
   DECLARE dstt_address = i4 WITH protect, noconstant(0)
   IF ( NOT (assign(dstt_temp,locateval(dstt_temp,1,dtr_tns_templs->cnt,token_name,dtr_tns_templs->
     qual[dstt_temp].token_name))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Searching for given token_name in service template management"
    SET dm_err->emsg = concat("Unable to find given token_name: ",token_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ( NOT (assign(dstt_address,locateval(dstt_address,1,dtr_tns_templs->cnt,"<address>",
     dtr_tns_templs->qual[dstt_address].token_name))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Searching for given token_name in service template management"
    SET dm_err->emsg = "Unable to find <address> token."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Transferring single token from qual portion of record stucture to tgt_template portion."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->qual[dstt_temp].line_cnt))
    HEAD REPORT
     dtr_tns_templs->tgt_line_cnt = 0, stat = alterlist(dtr_tns_templs->tgt_template,0)
    DETAIL
     IF (findstring("<cern_host_list>",dtr_tns_templs->qual[dstt_temp].lines[d.seq].line))
      FOR (dstt_iter = 1 TO evaluate(token_name,"<service>",daic_rac_inst_data->instance_cnt,1))
        FOR (dstt_iter2 = 1 TO dtr_tns_templs->qual[dstt_address].line_cnt)
          dtr_tns_templs->tgt_line_cnt = (dtr_tns_templs->tgt_line_cnt+ 1), stat = alterlist(
           dtr_tns_templs->tgt_template,dtr_tns_templs->tgt_line_cnt), dtr_tns_templs->tgt_template[
          dtr_tns_templs->tgt_line_cnt].line = replace(dtr_tns_templs->qual[dstt_temp].lines[d.seq].
           line,"<cern_host_list>",evaluate(token_name,"<service>",replace(dtr_tns_templs->qual[
             dstt_address].lines[dstt_iter2].line,">",build(dstt_iter,">")),dtr_tns_templs->qual[
            dstt_address].lines[dstt_iter2].line))
        ENDFOR
      ENDFOR
     ELSE
      dtr_tns_templs->tgt_line_cnt = (dtr_tns_templs->tgt_line_cnt+ 1), stat = alterlist(
       dtr_tns_templs->tgt_template,dtr_tns_templs->tgt_line_cnt), dtr_tns_templs->tgt_template[
      dtr_tns_templs->tgt_line_cnt].line = dtr_tns_templs->qual[dstt_temp].lines[d.seq].line
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dtr_tns_templs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_complete_tgt_template(null)
   DECLARE dctt_iter = i4 WITH protect, noconstant(0)
   SET dm_err->eproc =
   "Completing tokens in tgt_template by replacing tokens with values in service template management."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->tgt_line_cnt))
    DETAIL
     FOR (dctt_iter = 1 TO dtr_tns_templs->token_cnt)
       dtr_tns_templs->tgt_template[d.seq].line = replace(dtr_tns_templs->tgt_template[d.seq].line,
        dtr_tns_templs->tokens[dctt_iter].token_name,dtr_tns_templs->tokens[dctt_iter].token_value,0)
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dtr_tns_templs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_clear_tokens(null)
  SET dtr_tns_templs->token_cnt = 0
  SET stat = alterlist(dtr_tns_templs->tokens,0)
 END ;Subroutine
 SUBROUTINE dtr_add_token(token_name,token_value)
  DECLARE dat_temp = i4 WITH protect, noconstant(0)
  IF (assign(dat_temp,locateval(dat_temp,1,dtr_tns_templs->token_cnt,token_name,dtr_tns_templs->
    tokens[dat_temp].token_name)))
   SET dtr_tns_templs->tokens[dat_temp].token_value = token_value
  ELSE
   SET dtr_tns_templs->token_cnt = (dtr_tns_templs->token_cnt+ 1)
   SET stat = alterlist(dtr_tns_templs->tokens,dtr_tns_templs->token_cnt)
   SET dtr_tns_templs->tokens[dtr_tns_templs->token_cnt].token_name = token_name
   SET dtr_tns_templs->tokens[dtr_tns_templs->token_cnt].token_value = token_value
  ENDIF
 END ;Subroutine
 SUBROUTINE dtr_copy_tgt_template(null)
   SET dm_err->eproc =
   "Transferring single tgt_template to all_tgt_templates for service template management."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->tgt_line_cnt))
    HEAD REPORT
     dtr_tns_templs->all_tgt_template_cnt = (dtr_tns_templs->all_tgt_template_cnt+ 1), stat =
     alterlist(dtr_tns_templs->all_tgt_templates,dtr_tns_templs->all_tgt_template_cnt),
     dtr_tns_templs->all_tgt_templates[dtr_tns_templs->all_tgt_template_cnt].line_cnt =
     dtr_tns_templs->tgt_line_cnt,
     stat = alterlist(dtr_tns_templs->all_tgt_templates[dtr_tns_templs->all_tgt_template_cnt].qual,
      dtr_tns_templs->tgt_line_cnt)
    DETAIL
     dtr_tns_templs->all_tgt_templates[dtr_tns_templs->all_tgt_template_cnt].qual[d.seq].line =
     dtr_tns_templs->tgt_template[d.seq].line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_display_tns_report(null)
   DECLARE ddtr_dbase_name = vc WITH protect, noconstant("")
   DECLARE ddtr_iter = i4 WITH protect, noconstant(0)
   IF ( NOT (dm2_get_dbase_name(ddtr_dbase_name)))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Displaying tnsnames.ora entry report to the screen."
   SELECT INTO "mine"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->all_tgt_template_cnt))
    HEAD REPORT
     col 0,
     "#The following Cerner Database Service TNS entries should be added/updated into the local tnsnames.ora file.",
     row + 1,
     col 0, "", row + 1,
     col 0, "Warning:  To prevent connectivity issues:", row + 1,
     col 0, "1) Each of the following entries to be added/updated should be reviewed for accuracy.",
     row + 1,
     col 0, "2) Updates to a tnsnames.ora file should be carefully performed.", row + 1,
     col 0,
     "   Missing or extra characters (parenthesis for example) can render entire portions of a tnsnames.ora",
     row + 1,
     col 0, "   file unusable and disrupt existing connectivity.", row + 1,
     col 0, "3) New entries should always be added to the end of a tnsnames.ora file.  ", row + 1,
     col 0,
     "4) A copy of the current tnsnames.ora file should be saved under a saved name before making updates.",
     row + 1,
     col 0, "", row + 1,
     col 0, "#Cerner Database Services entries for ", ddtr_dbase_name,
     row + 1
    DETAIL
     FOR (ddtr_iter = 1 TO dtr_tns_templs->all_tgt_templates[d.seq].line_cnt)
       col 0, dtr_tns_templs->all_tgt_templates[d.seq].qual[ddtr_iter].line, row + 1
     ENDFOR
     col 0, "", row + 1
    WITH nocounter, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_prompt_tns_confirmation(null)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,
      "Generate Cerner Database Services tnsnames.ora entries - TNS Deployment Verification")
     CALL text(4,10,build(
       "Please confirm the TNS entries have been deployed to the local application node (",curnode,
       ")"))
     CALL text(6,10,"(V)iew Cerner Database Services TNS Report")
     CALL text(7,10,"(C)ontinue, TNS entries have been deployed")
     CALL text(8,10,"(Q)uit")
     CALL text(10,10,"Selection:")
     CALL accept(10,21,"A;CU","V"
      WHERE curaccept IN ("V", "C", "Q"))
     CASE (curaccept)
      OF "Q":
       SET dm2_process_event_rs->status = dpl_decline
       CALL dm2_process_log_row(dpl_db_services,dpl_tns_deployment,dpl_no_prev_id,1)
       RETURN(0)
      OF "V":
       IF ( NOT (dtr_display_tns_report(null)))
        GO TO exit_script
       ENDIF
      OF "C":
       SET dm2_process_event_rs->status = dpl_confirmation
       CALL dm2_process_log_row(dpl_db_services,dpl_tns_deployment,dpl_no_prev_id,1)
       RETURN(1)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dtr_service_connectivity_test(null)
   DECLARE dsct_iter = i4 WITH protect, noconstant(0)
   DECLARE dsct_dbase_name = vc WITH protect, noconstant("")
   IF ( NOT (dm2_get_dbase_name(dsct_dbase_name)))
    RETURN(0)
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   SET dm2_install_schema->u_name = "CER_TST"
   SET dm2_install_schema->p_word = "EG"
   SET dtr_connectivity->connect_fail_ind = 0
   FOR (dsct_iter = 1 TO dtr_connectivity->cnt)
     SET dm2_install_schema->dbase_name = dtr_connectivity->qual[dsct_iter].connect_string
     SET dm2_install_schema->connect_str = dtr_connectivity->qual[dsct_iter].connect_string
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->emsg="*ORA-01017*"))
      SET dtr_connectivity->qual[dsct_iter].connect_ind = 1
     ELSE
      SET dtr_connectivity->connect_fail_ind = 1
      SET dtr_connectivity->qual[dsct_iter].connect_ind = 0
      SET dtr_connectivity->qual[dsct_iter].emsg = dm_err->emsg
     ENDIF
     SET dm_err->err_ind = 0
   ENDFOR
   IF (dtr_connectivity->connect_fail_ind)
    SET dm_err->eproc = "Displaying service connectivity failure report."
    SELECT INTO "mine"
     FROM (dummyt d  WITH seq = value(dtr_connectivity->cnt))
     HEAD REPORT
      col 0, "Connectivity Report for Database ", dsct_dbase_name,
      row + 2, col 0, "Connect String",
      col 31, "Status", col 41,
      "Message", row + 1, col 0,
      CALL print(fillstring(30,"-")), col 31,
      CALL print(fillstring(9,"-")),
      col 41,
      CALL print(fillstring(60,"-")), row + 1
     DETAIL
      col 0, dtr_connectivity->qual[d.seq].connect_string, col 31,
      CALL print(evaluate(dtr_connectivity->qual[d.seq].connect_ind,1,"SUCCESS","FAILURE"))
      IF ( NOT (dtr_connectivity->qual[d.seq].connect_ind))
       col 41,
       CALL print(substring(findstring("ORA-",dtr_connectivity->qual[d.seq].emsg),90,dtr_connectivity
        ->qual[d.seq].emsg))
      ENDIF
      row + 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Displaying service connectivity success report."
    SELECT INTO "mine"
     FROM dummyt d
     HEAD REPORT
      col 0, "Connectivity Report for Database ", dsct_dbase_name,
      row + 2, col 0, "All Cerner Database Service connect strings were successfully tested."
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_populate_all_tns_stanzas(null)
   DECLARE dpats_iter = i4 WITH protect, noconstant(0)
   DECLARE dpats_dbase_name = vc WITH protect, noconstant("")
   IF ( NOT (dm2_get_dbase_name(dpats_dbase_name)))
    RETURN(0)
   ENDIF
   IF ( NOT (dtr_import_tns_templates(null)))
    GO TO exit_script
   ENDIF
   FOR (dpats_iter = 1 TO daic_rac_inst_data->instance_cnt)
     IF ( NOT (dtr_setup_tgt_template("<instance>")))
      GO TO exit_script
     ENDIF
     CALL dtr_clear_tokens(null)
     CALL dtr_add_token("<cern_db_domain>",dtr_tns_details->desired_db_domain)
     CALL dtr_add_token("<cern_instance_name>",daic_rac_inst_data->qual[dpats_iter].instance_name)
     CALL dtr_add_token("<cern_service_name>",cnvtlower(dpats_dbase_name))
     CALL dtr_add_token("<cern_vip_host_name>",concat(daic_rac_inst_data->qual[dpats_iter].
       partial_host_name,dtr_tns_details->vip_extension))
     CALL dtr_add_token("<cern_port>",build(dtr_instance_data->qual[dpats_iter].port_number))
     IF ( NOT (dtr_complete_tgt_template(null)))
      GO TO exit_script
     ENDIF
     IF ( NOT (dtr_copy_tgt_template(null)))
      GO TO exit_script
     ENDIF
   ENDFOR
   IF ( NOT (dtr_setup_tgt_template("<service>")))
    GO TO exit_script
   ENDIF
   CALL dtr_clear_tokens(null)
   CALL dtr_add_token("<cern_db_domain>",dtr_tns_details->desired_db_domain)
   FOR (dpats_iter = 1 TO daic_rac_inst_data->instance_cnt)
    CALL dtr_add_token(build("<cern_vip_host_name",dpats_iter,">"),concat(daic_rac_inst_data->qual[
      dpats_iter].partial_host_name,dtr_tns_details->vip_extension))
    CALL dtr_add_token(build("<cern_port",dpats_iter,">"),build(dtr_instance_data->qual[dpats_iter].
      port_number))
   ENDFOR
   CALL dtr_add_token("<cern_service_name>",cnvtlower(dpats_dbase_name))
   IF ( NOT (dtr_complete_tgt_template(null)))
    GO TO exit_script
   ENDIF
   IF ( NOT (dtr_copy_tgt_template(null)))
    GO TO exit_script
   ENDIF
   FOR (dpats_iter = 1 TO ddr_cerner_services->service_cnt)
     IF ( NOT (dtr_setup_tgt_template("<service>")))
      GO TO exit_script
     ENDIF
     CALL dtr_add_token("<cern_service_name>",ddr_cerner_services->service[dpats_iter].service_name)
     IF ( NOT (dtr_complete_tgt_template(null)))
      GO TO exit_script
     ENDIF
     IF ( NOT (dtr_copy_tgt_template(null)))
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dtr_query_tns_details(null)
   SET dm_err->eproc = "Querying for db_domain/spfile from v$parameter."
   SELECT INTO "nl:"
    value_null_ind = nullind(vp.value)
    FROM v$parameter vp
    WHERE vp.name IN ("db_domain", "spfile")
    DETAIL
     CASE (vp.name)
      OF "db_domain":
       dtr_tns_details->desired_db_domain = cnvtlower(vp.value)
      OF "spfile":
       dtr_tns_details->spfile_ind = (1 - value_null_ind)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dtr_tns_details->vip_extension = "_oracle"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_active_instance_count(instance_count)
   IF ((daic_rac_inst_data->instance_cnt > 0))
    SET daic_rac_inst_data->instance_cnt = 0
    SET stat = alterlist(daic_rac_inst_data->qual,0)
   ENDIF
   SET dm_err->eproc = "Determining how many instances are running, from v$thread/gv$instance."
   SELECT INTO "nl:"
    FROM v$thread vt,
     gv$instance vi
    WHERE vt.status="OPEN"
     AND vt.thread#=vi.thread#
    ORDER BY vi.inst_id
    DETAIL
     daic_rac_inst_data->instance_cnt = (daic_rac_inst_data->instance_cnt+ 1)
     IF (mod(daic_rac_inst_data->instance_cnt,10)=1)
      stat = alterlist(daic_rac_inst_data->qual,(daic_rac_inst_data->instance_cnt+ 9))
     ENDIF
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].inst_id = vi.inst_id,
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].instance_name = vi.instance_name,
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].host_name = vi.host_name,
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].partial_host_name = substring(1,
      evaluate(findstring(".",vi.host_name),0,size(vi.host_name),(findstring(".",vi.host_name) - 1)),
      vi.host_name), daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].thread_number = vi
     .thread#
    FOOT REPORT
     stat = alterlist(daic_rac_inst_data->qual,daic_rac_inst_data->instance_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET instance_count = curqual
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(daic_rac_inst_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_ds_get_service_list(template_id)
   IF ((((ddr_cerner_services->service_cnt=0)) OR ((template_id != ddr_cerner_services->template_id)
   )) )
    SET ddr_cerner_services->template_id = template_id
    SET dm_err->eproc = "Querying for list of all Cerner services from dm_ds_service."
    SELECT INTO "nl:"
     FROM dm_ds_service dss
     ORDER BY dss.service_name
     HEAD REPORT
      ddr_cerner_services->service_cnt = 0, stat = alterlist(ddr_cerner_services->service,0)
     DETAIL
      ddr_cerner_services->service_cnt = (ddr_cerner_services->service_cnt+ 1), stat = alterlist(
       ddr_cerner_services->service,ddr_cerner_services->service_cnt), ddr_cerner_services->service[
      ddr_cerner_services->service_cnt].service_name = cnvtlower(build(dss.service_name,
        ddr_cerner_services->dbname_suffix))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(ddr_cerner_services)
   ENDIF
   RETURN(1)
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
END GO
