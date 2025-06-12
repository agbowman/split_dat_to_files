CREATE PROGRAM dm2_cbo_sql_report:dba
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
 IF ((validate(dcr_optvalues->force_ind,- (1))=- (1))
  AND (validate(dcr_optvalues->force_ind,- (2))=- (2)))
  FREE RECORD dcr_optvalues
  RECORD dcr_optvalues(
    1 session_opt_mode = vc
    1 implementer_opt_mode = vc
    1 force_ind = i2
  )
 ENDIF
 DECLARE dcr_get_optimizer_settings(null) = i2
 DECLARE dcr_get_purge_size(block_size=i4(ref)) = i2
 DECLARE dcr_get_newest_snapshot(snapshot_id=f8(ref)) = i2
 DECLARE dcr_get_bg_exec_threshold(threshold=f8(ref)) = i2
 DECLARE dcr_get_nearness_factor(factor=f8(ref)) = i2
 DECLARE dcr_get_opt_mode_by_num(opt_num=i4) = vc
 DECLARE dcr_get_opt_mode_by_name(opt_name=vc) = i4
 SUBROUTINE dcr_get_optimizer_settings(null)
   DECLARE dgos_info_exists = i2 WITH protect, noconstant(0)
   IF ((dcr_optvalues->force_ind=1))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Selecting current optimizer_mode from v$parameter."
   SELECT INTO "nl:"
    FROM v$parameter vp
    WHERE vp.name="optimizer_mode"
    DETAIL
     dcr_optvalues->session_opt_mode = cnvtupper(vp.value)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcr_optvalues->implementer_opt_mode = dcr_optvalues->session_opt_mode
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgos_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgos_info_exists=1)
    SET dm_err->eproc = "Selecting current optimizer mode from dm_info via info_name."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM_SET_SESSION_PARAMETERS"
      AND di.info_name="OPTIMIZER_MODE"
     DETAIL
      start = findstring("=",di.info_char), dcr_optvalues->implementer_opt_mode = cnvtupper(trim(
        substring((start+ 1),(size(di.info_char) - start),di.info_char),3))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Selecting current optimizer mode from dm_info via info_char."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM_SET_SESSION_PARAMETERS"
       AND cnvtupper(di.info_char)="*OPTIMIZER_MODE*"
      DETAIL
       start = findstring("=",di.info_char), dcr_optvalues->implementer_opt_mode = cnvtupper(trim(
         substring((start+ 1),(size(di.info_char) - start),di.info_char),3))
      WITH nocounter, nullreport
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_purge_size(block_size)
   SET dm_err->eproc = "Selecting purge batch rows from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DATA MANAGEMENT"=di.info_domain
     AND "PURGE BATCH ROWS"=di.info_name
    HEAD REPORT
     block_size = 5000
    DETAIL
     block_size = cnvtint(di.info_number)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_newest_snapshot(snapshot_id)
   SET dm_err->eproc = "Selecting newest snapshot."
   SELECT INTO "nl:"
    FROM dm_sql_mgmt dsm
    WHERE "COMPLETE"=dsm.status
    ORDER BY dsm.snap_end_dt_tm DESC
    DETAIL
     snapshot_id = dsm.snapshot_id,
     CALL cancel(1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_bg_exec_threshold(threshold)
   SET dm_err->eproc = "Selecting DM CBO IMPLEMENTER->GETS PER EXECUTE MAX threshold from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_CBO_IMPLEMENTER"
     AND di.info_name="BG_EX_THRESHOLD"
    HEAD REPORT
     threshold = 3000.0
    DETAIL
     threshold = di.info_number
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_nearness_factor(factor)
   SET dm_err->eproc = "Selecting nearness factor from dm_info"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_CBO_IMPLEMENTER"
     AND di.info_name="NEARNESS_FACTOR"
    HEAD REPORT
     factor = 1
    DETAIL
     IF (di.info_number >= 0.0
      AND di.info_number <= 100.0)
      factor = (1+ (di.info_number/ 100))
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_opt_mode_by_num(opt_num)
   RETURN(evaluate(opt_num,1,"RULE",2,"CHOOSE",
    3,"FIRST_ROWS_1",4,"FIRST_ROWS_10",5,
    "FIRST_ROWS_100",6,"FIRST_ROWS_1000",7,"FIRST_ROWS",
    8,"ALL_ROWS","UNKNOWN"))
 END ;Subroutine
 SUBROUTINE dcr_get_opt_mode_by_name(opt_name)
   RETURN(evaluate(opt_name,"RULE",1,"CHOOSE",2,
    "FIRST_ROWS_1",3,"FIRST_ROWS_10",4,"FIRST_ROWS_100",
    5,"FIRST_ROWS_1000",6,"FIRST_ROWS",7,
    "ALL_ROWS",8,0))
 END ;Subroutine
 FREE RECORD dts_prompt_data
 RECORD dts_prompt_data(
   1 opt_cnt = i4
   1 opt[*]
     2 mode = vc
   1 tuning_cnt = i4
   1 tuning[*]
     2 status = vc
   1 script_cnt = i4
   1 script[*]
     2 name = vc
   1 query_cnt = i4
   1 query[*]
     2 num = vc
 )
 FREE RECORD dts_report_data
 RECORD dts_report_data(
   1 total_dtl_cnt = i4
   1 cnt = i4
   1 qual[*]
     2 script_name = vc
     2 query_nbr_grp = i4
     2 tuning_status = vc
     2 tgt_opt_mode = i4
     2 last_change_dt_tm = dq8
     2 comments = vc
     2 query_cnt = i4
     2 query[*]
       3 dm_sql_id = f8
       3 tuning_status = vc
       3 last_tuning_dt_tm = dq8
       3 tgt_opt_mode = i4
       3 comments = vc
       3 cbo_dtl_index = i4
       3 rbo_dtl_index = i4
       3 dtl_cnt = i4
       3 dtl[*]
         4 ccl_opt_mode = i4
         4 dm_sql_perf_dtl_id = f8
         4 bg_ex = f8
         4 bg_rp = f8
         4 text_cnt = i4
         4 full_text = vc
         4 text[*]
           5 sql_text = vc
 )
 DECLARE dts_tgt_optimimzer_mode = i4 WITH protect, noconstant(0)
 DECLARE dts_tgt_optimimzer_mode_clause = vc WITH protect, noconstant("1 = 1")
 DECLARE dts_ccl_query_nbr = i4 WITH protect, noconstant(0)
 DECLARE dts_ccl_query_nbr_clause = vc WITH protect, noconstant("1 = 1")
 DECLARE dts_tuning_status = vc WITH protect, noconstant("")
 DECLARE dts_ccl_script_name = vc WITH protect, noconstant("")
 DECLARE total_table_dtl_cnt = i4 WITH protect, noconstant(0)
 IF (check_logfile("dm2_cbo_sql_report",".log","DM2_CBO_SQL_REPORT LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning dm2_cbo_sql_report"
 CALL disp_msg("",dm_err->logfile,0)
 SET message = window
 CALL clear(1,1)
 CALL box(1,1,24,131)
 SET accept = nopatcheck
 CALL text(2,2,"CBO Reports    SQL Report")
 CALL text(5,2,"Tuning Status:")
 CALL text(6,2,"Optimizer Mode:")
 CALL text(7,2,"CCL Script Name:")
 CALL text(8,2,"CCL Query Number:")
 CALL text(23,2,"Press <Shift><F5> for help list of filter options.")
 SET dm_err->eproc = "Querying for distinct tuning statuses from dm_sql_perf_master."
 SELECT DISTINCT INTO "nl:"
  dspm.tuning_status
  FROM dm_sql_perf_master dspm
  WHERE dspm.tuning_status IS NOT null
  ORDER BY dspm.tuning_status
  HEAD REPORT
   dts_prompt_data->tuning_cnt = 1, stat = alterlist(dts_prompt_data->tuning,1), dts_prompt_data->
   tuning[1].status = "*"
  DETAIL
   dts_prompt_data->tuning_cnt = (dts_prompt_data->tuning_cnt+ 1), stat = alterlist(dts_prompt_data->
    tuning,dts_prompt_data->tuning_cnt), dts_prompt_data->tuning[dts_prompt_data->tuning_cnt].status
    = dspm.tuning_status
  WITH nocounter, nullreport
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET help =
 SELECT INTO "nl:"
  substring(1,40,dts_prompt_data->tuning[d.seq].status)
  FROM (dummyt d  WITH seq = value(dts_prompt_data->tuning_cnt))
  WHERE (dts_prompt_data->tuning_cnt > 0)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 CALL accept(5,17,"P(11);CU","*")
 SET dts_tuning_status = trim(curaccept)
 SET help = off
 SET dm_err->eproc = "Querying for list of optimizer modes from dm_sql_perf_master."
 SELECT DISTINCT INTO "nl:"
  FROM dm_sql_perf_master dspm
  WHERE dspm.tuning_status=patstring(dts_tuning_status)
  HEAD REPORT
   dts_prompt_data->opt_cnt = 1, stat = alterlist(dts_prompt_data->opt,1), dts_prompt_data->opt[1].
   mode = "*"
  DETAIL
   dts_prompt_data->opt_cnt = (dts_prompt_data->opt_cnt+ 1), stat = alterlist(dts_prompt_data->opt,
    dts_prompt_data->opt_cnt), dts_prompt_data->opt[dts_prompt_data->opt_cnt].mode =
   dcr_get_opt_mode_by_num(dspm.tgt_opt_mode)
  WITH nocounter, nullreport
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET help =
 SELECT INTO "nl:"
  substring(1,20,dts_prompt_data->opt[d.seq].mode)
  FROM (dummyt d  WITH seq = value(dts_prompt_data->opt_cnt))
  WHERE (dts_prompt_data->opt_cnt > 0)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 CALL accept(6,18,"P(20);CU","*")
 IF (trim(curaccept) != char(42))
  SET dts_tgt_optimimzer_mode_clause = "dspm.tgt_opt_mode = dts_tgt_optimimzer_mode"
  SET dts_tgt_optimimzer_mode = dcr_get_opt_mode_by_name(trim(curaccept))
 ENDIF
 SET help = off
 SET dm_err->eproc = "Querying for list of script names from dm_sql_perf_master."
 SELECT DISTINCT INTO "nl:"
  dspm.ccl_script_name
  FROM dm_sql_perf_master dspm
  WHERE dspm.tuning_status=patstring(dts_tuning_status)
   AND parser(dts_tgt_optimimzer_mode_clause)
  HEAD REPORT
   dts_prompt_data->script_cnt = 1, stat = alterlist(dts_prompt_data->script,1), dts_prompt_data->
   script[1].name = "*"
  DETAIL
   dts_prompt_data->script_cnt = (dts_prompt_data->script_cnt+ 1), stat = alterlist(dts_prompt_data->
    script,dts_prompt_data->script_cnt), dts_prompt_data->script[dts_prompt_data->script_cnt].name =
   dspm.ccl_script_name
  WITH nocounter, nullreport
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET help =
 SELECT INTO "nl:"
  substring(1,20,dts_prompt_data->script[d.seq].name)
  FROM (dummyt d  WITH seq = value(dts_prompt_data->script_cnt))
  WHERE (dts_prompt_data->script_cnt > 0)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 CALL accept(7,19,"P(30);CU","*")
 SET dts_ccl_script_name = trim(curaccept)
 SET help = off
 IF ( NOT (findstring("*",dts_ccl_script_name)))
  SET dm_err->eproc = "Querying for list of CCL Query Numbers from dm_sql_perf_master."
  SELECT INTO "nl:"
   dspm.ccl_query_nbr
   FROM dm_sql_perf_master dspm
   WHERE dspm.tuning_status=patstring(dts_tuning_status)
    AND parser(dts_tgt_optimimzer_mode_clause)
    AND dspm.ccl_script_name=patstring(dts_ccl_script_name)
   HEAD REPORT
    dts_prompt_data->query_cnt = 1, stat = alterlist(dts_prompt_data->query,1), dts_prompt_data->
    query[1].num = "*"
   DETAIL
    dts_prompt_data->query_cnt = (dts_prompt_data->query_cnt+ 1), stat = alterlist(dts_prompt_data->
     query,dts_prompt_data->query_cnt)
    IF ((dspm.ccl_query_nbr=- (1)))
     dts_prompt_data->query[dts_prompt_data->query_cnt].num = "DEFAULT"
    ELSE
     dts_prompt_data->query[dts_prompt_data->query_cnt].num = cnvtstring(dspm.ccl_query_nbr)
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET help =
  SELECT INTO "nl:"
   substring(1,7,dts_prompt_data->query[d.seq].num)
   FROM (dummyt d  WITH seq = value(dts_prompt_data->query_cnt))
   WHERE (dts_prompt_data->query_cnt > 0)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL accept(8,20,"P(7);CU","*")
  IF (trim(curaccept) != char(42))
   IF (trim(curaccept)="DEFAULT")
    SET dts_ccl_query_nbr_clause = "dspm.ccl_query_nbr = -1"
   ELSE
    SET dts_ccl_query_nbr = cnvtint(trim(curaccept))
    SET dts_ccl_query_nbr_clause = "dspm.ccl_query_nbr = cnvtint(dts_ccl_query_nbr)"
   ENDIF
  ENDIF
  SET help = off
 ENDIF
 SET message = nowindow
 CALL clear(1,1)
 SET dm_err->eproc = "Selecting data from dm_sql_perf_master/dm_sql_perf/dm_sql_perf_dtl for report."
 SELECT INTO "nl:"
  FROM dm_sql_perf_master dspm,
   dm_sql_perf dsp,
   dm_sql_perf_dtl dspd
  WHERE dspm.ccl_script_name=dsp.ccl_script_name
   AND dspm.ccl_query_nbr=evaluate2(
   IF (dsp.ccl_query_nbr > 50) - (1)
   ELSE dsp.ccl_query_nbr
   ENDIF
   )
   AND dspd.dm_sql_id=dsp.dm_sql_id
   AND dspm.tuning_status=patstring(dts_tuning_status)
   AND parser(dts_tgt_optimimzer_mode_clause)
   AND dspm.ccl_script_name=patstring(dts_ccl_script_name)
   AND parser(dts_ccl_query_nbr_clause)
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_info di
   WHERE di.info_domain="DM_CBO_IMPLEMENTER:RESET_OBJECT"
    AND ((dspm.ccl_script_name=di.info_name) OR (concat(dspm.ccl_script_name,":",dspm.ccl_query_nbr)=
   di.info_name)) )))
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_info di
   WHERE di.info_domain="DM_CBO_IMPLEMENTER"
    AND di.info_name="RESET_ALL")))
  ORDER BY dspm.last_change_dt_tm DESC, dspm.ccl_script_name, dspm.ccl_query_nbr,
   dsp.dm_sql_id, dspd.ccl_opt_mode DESC
  HEAD REPORT
   stat = initrec(dts_report_data), cnt = 0, query_cnt = 0,
   dtl_cnt = 0
  HEAD dspm.last_change_dt_tm
   row + 0
  HEAD dspm.ccl_script_name
   row + 0
  HEAD dspm.ccl_query_nbr
   cnt = (cnt+ 1), stat = alterlist(dts_report_data->qual,cnt), dts_report_data->qual[cnt].
   script_name = dspm.ccl_script_name,
   dts_report_data->qual[cnt].query_nbr_grp = dspm.ccl_query_nbr, dts_report_data->qual[cnt].
   tuning_status = dspm.tuning_status, dts_report_data->qual[cnt].tgt_opt_mode = dspm.tgt_opt_mode,
   dts_report_data->qual[cnt].last_change_dt_tm = dspm.last_change_dt_tm, dts_report_data->qual[cnt].
   comments = dspm.comments, query_cnt = 0
  HEAD dsp.dm_sql_id
   query_cnt = (query_cnt+ 1), stat = alterlist(dts_report_data->qual[cnt].query,query_cnt),
   dts_report_data->qual[cnt].query[query_cnt].dm_sql_id = dsp.dm_sql_id,
   dts_report_data->qual[cnt].query[query_cnt].tuning_status = dsp.tuning_status, dts_report_data->
   qual[cnt].query[query_cnt].last_tuning_dt_tm = dsp.last_tuning_dt_tm, dts_report_data->qual[cnt].
   query[query_cnt].tgt_opt_mode = dsp.tgt_opt_mode,
   dts_report_data->qual[cnt].query[query_cnt].comments = dsp.comments, dtl_cnt = 0
  DETAIL
   dts_report_data->total_dtl_cnt = (dts_report_data->total_dtl_cnt+ 1), dtl_cnt = (dtl_cnt+ 1), stat
    = alterlist(dts_report_data->qual[cnt].query[query_cnt].dtl,dtl_cnt)
   IF (dspd.ccl_opt_mode=1)
    dts_report_data->qual[cnt].query[query_cnt].rbo_dtl_index = dtl_cnt
   ELSE
    dts_report_data->qual[cnt].query[query_cnt].cbo_dtl_index = dtl_cnt
   ENDIF
   dts_report_data->qual[cnt].query[query_cnt].dtl[dtl_cnt].ccl_opt_mode = dspd.ccl_opt_mode,
   dts_report_data->qual[cnt].query[query_cnt].dtl[dtl_cnt].dm_sql_perf_dtl_id = dspd
   .dm_sql_perf_dtl_id, dts_report_data->qual[cnt].query[query_cnt].dtl[dtl_cnt].bg_ex = (dspd
   .buffer_gets/ dspd.executions),
   dts_report_data->qual[cnt].query[query_cnt].dtl[dtl_cnt].bg_rp = (dspd.buffer_gets/ dspd
   .rows_processed)
  FOOT  dsp.dm_sql_id
   dts_report_data->qual[cnt].query[query_cnt].dtl_cnt = dtl_cnt
  FOOT  dspm.ccl_query_nbr
   dts_report_data->qual[cnt].query_cnt = query_cnt
  FOOT REPORT
   dts_report_data->cnt = cnt
  WITH nocounter, nullreport
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Querying for num_rows from user_tables."
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name="DM_SQL_PERF_DTL"
  DETAIL
   total_table_dtl_cnt = ut.num_rows
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dts_report_data->total_dtl_cnt >= (0.20 * total_table_dtl_cnt)))
  SET dm_err->eproc = "Selecting data from dm_sql_perf_text for more than 20%."
  SELECT INTO "nl:"
   FROM dm_sql_perf_text dspt,
    dm_sql_perf_dtl dspd
   WHERE dspt.dm_sql_id=dspd.dm_sql_perf_dtl_id
   ORDER BY dspt.dm_sql_id, dspt.sql_text_seq
   HEAD REPORT
    iter = 0, iter2 = 0, iter3 = 0,
    found_iter = 0, found_iter2 = 0, found_iter3 = 0,
    text_cnt = 0
   HEAD dspt.dm_sql_id
    found_iter = 0, found_iter2 = 0, found_iter3 = 0
    FOR (iter = 1 TO dts_report_data->cnt)
      FOR (iter2 = 1 TO dts_report_data->qual[iter].query_cnt)
        FOR (iter3 = 1 TO dts_report_data->qual[iter].query[iter2].dtl_cnt)
          IF ((dts_report_data->qual[iter].query[iter2].dtl[iter3].dm_sql_perf_dtl_id=dspt.dm_sql_id)
          )
           found_iter = iter, found_iter2 = iter2, found_iter3 = iter3,
           iter3 = (dts_report_data->qual[iter].query[iter2].dtl_cnt+ 1), iter2 = (dts_report_data->
           qual[iter].query_cnt+ 1), iter = (dts_report_data->cnt+ 1)
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
    IF (found_iter3)
     dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].full_text = "~", stat =
     alterlist(dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].text,0),
     text_cnt = 0
    ENDIF
   DETAIL
    IF (found_iter3)
     dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].full_text = notrim(concat(
       notrim(dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].full_text),notrim
       (dspt.sql_text))), text_cnt = (text_cnt+ 1), stat = alterlist(dts_report_data->qual[found_iter
      ].query[found_iter2].dtl[found_iter3].text,text_cnt),
     dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].text[text_cnt].sql_text =
     dspt.sql_text
    ENDIF
   FOOT  dspt.dm_sql_id
    IF (found_iter3)
     dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].full_text = substring(2,
      size(dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].full_text),
      dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].full_text),
     dts_report_data->qual[found_iter].query[found_iter2].dtl[found_iter3].text_cnt = text_cnt
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ELSE
  SET dm_err->eproc = "Selecting data from dm_sql_perf_text for less than 20%."
  SELECT INTO "nl:"
   FROM dm_sql_perf_text dspt,
    (dummyt d  WITH seq = value(dts_report_data->cnt)),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d
    WHERE (dts_report_data->cnt > 0)
     AND maxrec(d2,dts_report_data->qual[d.seq].query_cnt))
    JOIN (d2
    WHERE maxrec(d3,dts_report_data->qual[d.seq].query[d2.seq].dtl_cnt))
    JOIN (d3)
    JOIN (dspt
    WHERE (dspt.dm_sql_id=dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].dm_sql_perf_dtl_id))
   ORDER BY dspt.dm_sql_id, dspt.sql_text_seq
   HEAD REPORT
    text_cnt = 0
   HEAD dspt.dm_sql_id
    dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].full_text = "~", stat = alterlist(
     dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].text,0), text_cnt = 0
   DETAIL
    dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].full_text = notrim(concat(notrim(
       dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].full_text),notrim(dspt.sql_text))),
    text_cnt = (text_cnt+ 1), stat = alterlist(dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq]
     .text,text_cnt),
    dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].text[text_cnt].sql_text = dspt.sql_text
   FOOT  dspt.dm_sql_id
    dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].full_text = substring(2,size(
      dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].full_text),dts_report_data->qual[d.seq].
     query[d2.seq].dtl[d3.seq].full_text), dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].
    text_cnt = text_cnt
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((dm_err->debug_flag > 1))
  CALL echorecord(dts_report_data)
 ENDIF
 SET dm_err->eproc = "Displaying report to the screen."
 SELECT INTO mine
  last_change_dt_tm = dts_report_data->qual[d.seq].last_change_dt_tm
  FROM (dummyt d  WITH seq = value(dts_report_data->cnt)),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d
   WHERE (dts_report_data->cnt > 0)
    AND maxrec(d2,dts_report_data->qual[d.seq].query_cnt))
   JOIN (d2
   WHERE maxrec(d3,dts_report_data->qual[d.seq].query[d2.seq].dtl_cnt))
   JOIN (d3)
  ORDER BY d.seq, d2.seq, d3.seq
  HEAD REPORT
   iter = 0, col_start = 0, found = 0,
   CALL print("CBO Reports    SQL Report"), row + 1
  HEAD d.seq
   found = 1,
   CALL print(fillstring(131,"*")), row + 1,
   col 0,
   CALL print(concat("Script Name:       ",dts_report_data->qual[d.seq].script_name)), row + 1
   IF ((dts_report_data->qual[d.seq].query_nbr_grp=- (1)))
    col 0,
    CALL print(concat("Query Number:      ","DEFAULT")), row + 1
   ELSE
    col 0,
    CALL print(concat("Query Number:      ",format(dts_report_data->qual[d.seq].query_nbr_grp,"##;P0"
      ))), row + 1
   ENDIF
   col 0,
   CALL print(concat("Tuning Status:     ",dts_report_data->qual[d.seq].tuning_status)), row + 1,
   col 0,
   CALL print(concat("Optimizer Mode:    ",dcr_get_opt_mode_by_num(dts_report_data->qual[d.seq].
     tgt_opt_mode))), row + 1,
   col 0,
   CALL print(concat("Last Change Time:  ",format(dts_report_data->qual[d.seq].last_change_dt_tm,
     ";;Q"))), row + 1,
   row + 1
  HEAD d2.seq
   col 5,
   CALL print(concat("Cerner Identifier: ",format(cnvtint(dts_report_data->qual[d.seq].query[d2.seq].
      dm_sql_id),";L"))), row + 1,
   col 5,
   CALL print(concat("Tuning Status:     ",dts_report_data->qual[d.seq].query[d2.seq].tuning_status)),
   row + 1,
   col 5,
   CALL print(concat("Optimizer Mode:    ",dcr_get_opt_mode_by_num(dts_report_data->qual[d.seq].
     query[d2.seq].tgt_opt_mode))), row + 1
   IF ((dts_report_data->qual[d.seq].query[d2.seq].comments > ""))
    col 5,
    CALL print(concat("Comments:          ",dts_report_data->qual[d.seq].query[d2.seq].comments)),
    row + 1
   ENDIF
   col 5,
   CALL print(concat("Tuning Time:       ",format(dts_report_data->qual[d.seq].query[d2.seq].
     last_tuning_dt_tm,";;Q"))), row + 2,
   col 0,
   CALL print(concat(fillstring(29,"-"),"COST",fillstring(29,"-"))), col 64,
   CALL print(concat(fillstring(29,"-"),"RULE",fillstring(29,"-"))), row + 1, cbo_idx =
   dts_report_data->qual[d.seq].query[d2.seq].cbo_dtl_index,
   rbo_idx = dts_report_data->qual[d.seq].query[d2.seq].rbo_dtl_index
  HEAD d3.seq
   IF (d3.seq=cbo_idx)
    col_start = 0
   ELSEIF (d3.seq=rbo_idx)
    col_start = 64
   ENDIF
   col col_start, "Buffer Gets / Execution:", col + 5,
   CALL print(format(dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].bg_ex,";L")), row + 1,
   col col_start,
   "Buffer Gets / Row Processed:", col + 1,
   CALL print(format(dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].bg_rp,";L")),
   row + 2
   IF (d3.seq=cbo_idx)
    col_start = 0
   ELSEIF (d3.seq=rbo_idx)
    col_start = 64
   ENDIF
   FOR (iter = 0 TO floor((size(dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].full_text)/ 62
    )))
     col col_start,
     CALL print(substring(((iter * 62)+ 1),62,dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].
      full_text)), row + 1
   ENDFOR
   row- ((ceil((size(dts_report_data->qual[d.seq].query[d2.seq].dtl[d3.seq].full_text)/ 62))+ 4))
  FOOT  d2.seq
   row + (greatest(ceil((size(dts_report_data->qual[d.seq].query[d2.seq].dtl[cbo_idx].full_text)/ 62)
     ),ceil((size(dts_report_data->qual[d.seq].query[d2.seq].dtl[rbo_idx].full_text)/ 62)))+ 5)
  FOOT REPORT
   IF ( NOT (found))
    CALL print("There is no data to display"), row + 2
   ENDIF
   row + 3,
   CALL print(fillstring(126,"*")),
   CALL center(" END OF REPORT ",1,126)
  WITH nocounter, maxrow = 10000, nullreport
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
#exit_script
 SET message = nowindow
 CALL clear(1,1)
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "Ending dm2_cbo_sql_report"
 CALL final_disp_msg("dm2_cbo_sql_report")
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
END GO
