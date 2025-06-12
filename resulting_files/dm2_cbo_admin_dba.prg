CREATE PROGRAM dm2_cbo_admin:dba
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
 FREE RECORD sql_statement
 RECORD sql_statement(
   1 statement_hash = f8
   1 sql_id = f8
   1 outline_name = vc
   1 sqltext_cnt = i4
   1 sqltext[*]
     2 text_line = vc
 )
 DECLARE dca_cur_opt_mode = i4 WITH protect, noconstant(0)
 DECLARE dca_alter_trigger(dat_trigger_name=vc,dat_trigger_status=vc) = i2
 DECLARE dca_reports_screen(null) = i2
 DECLARE drs_sql_plan(null) = i2
 DECLARE dca_maintenance_screen(null) = i2
 DECLARE dms_reset_single_sql(null) = i2
 DECLARE dms_reset_all_sql(null) = i2
 DECLARE dca_enable_implementer(null) = i2
 DECLARE dca_disable_implementer(null) = i2
 IF (check_logfile("dm2_cbo_admin",".log","dm2_cbo_admin LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Checking if RDBMS is Oracle"
 IF (currdb != "ORACLE")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Auto Exit - Not running Oracle"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 CALL dm2_get_rdbms_version(null)
 SET dm_err->eproc = "Checking if Oracle version is 9 or higher."
 IF ((dm2_rdbms_version->level1 < 9))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "This program can only be executed in Oracle 9 or higher."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET width = 132
 SET message = window
 WHILE (true)
   IF ( NOT (dcr_get_optimizer_settings(null)))
    GO TO exit_script
   ENDIF
   SET dca_cur_opt_mode = dcr_get_opt_mode_by_name(dcr_optvalues->implementer_opt_mode)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"CBO Administration Program")
   CALL text(2,(104 - size(dcr_optvalues->implementer_opt_mode)),concat("Current Optimizer Setting: ",
     build(dcr_optvalues->implementer_opt_mode)))
   CALL text(4,10,"1. Set up servers to run in CBO mode")
   CALL text(5,10,"2. Set up servers to run in RBO mode")
   CALL text(6,10,"3. Turn CBO Implementer on")
   CALL text(7,10,"4. Turn CBO Implementer off")
   CALL text(8,10,"5. Reports")
   CALL text(9,10,"6. Maintenance")
   CALL text(11,10,"Your Selection(0 to Exit)?")
   CALL accept(11,37,"9;",0
    WHERE curaccept IN (0, 1, 2, 3, 4,
    5, 6))
   CASE (curaccept)
    OF 0:
     GO TO exit_script
    OF 1:
     CASE (dca_switch_cbo_prompt(null))
      OF "Y":
       CALL clear(1,1)
       SET message = nowindow
       EXECUTE dm_set_session_param "CBO"
       IF (dm_err->err_ind)
        GO TO exit_script
       ENDIF
       IF ( NOT (dca_alter_trigger("DM2_NOANALYZE","ENABLE")))
        GO TO exit_script
       ENDIF
       EXECUTE dm_create_optimizer_objects
       IF (dm_err->err_ind)
        GO TO exit_script
       ENDIF
       EXECUTE dm_set_system_parameters
       IF (dm_err->err_ind)
        GO TO exit_script
       ENDIF
     ENDCASE
    OF 2:
     CASE (dca_switch_rbo_prompt(null))
      OF "Y":
       CALL clear(1,1)
       SET message = nowindow
       EXECUTE dm_set_session_param "RBO"
       IF (dm_err->err_ind)
        GO TO exit_script
       ENDIF
       IF (dca_alter_trigger("DM2_NOANALYZE","DISABLE")=0)
        GO TO exit_script
       ENDIF
       EXECUTE dm_create_optimizer_objects
       IF (dm_err->err_ind)
        GO TO exit_script
       ENDIF
     ENDCASE
    OF 3:
     CALL clear(1,1)
     SET message = nowindow
     IF ( NOT (dca_enable_implementer(null)))
      GO TO exit_script
     ENDIF
    OF 4:
     CALL clear(1,1)
     SET message = nowindow
     IF ( NOT (dca_disable_implementer(null)))
      GO TO exit_script
     ENDIF
    OF 5:
     IF ( NOT (dca_reports_screen(null)))
      GO TO exit_script
     ENDIF
    OF 6:
     IF ( NOT (dca_maintenance_screen(null)))
      GO TO exit_script
     ENDIF
   ENDCASE
 ENDWHILE
 SUBROUTINE dca_alter_trigger(dat_trigger_name,dat_trigger_status)
   DECLARE dat_text = vc WITH private, noconstant("")
   SET dm_err->eproc = "Selecting trigger from dm2_user_triggers."
   SELECT INTO "nl:"
    u.trigger_name
    FROM dm2_user_triggers u
    WHERE u.trigger_name=dat_trigger_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = concat("Altering trigger [",build(dat_trigger_name),"] to [",build(
      dat_trigger_status),"]")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dat_text = concat("RDB ALTER TRIGGER ",build(dat_trigger_name)," ",build(dat_trigger_status),
     " GO")
    RETURN(dm2_push_cmd(dat_text,1))
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Trigger not found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dca_reports_screen(null)
  WHILE (true)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,24,131)
    CALL text(2,2,"CBO Reports")
    CALL text(2,(104 - size(dcr_optvalues->implementer_opt_mode)),concat(
      "Current Optimizer Setting: ",build(dcr_optvalues->implementer_opt_mode)))
    CALL text(4,10,"1. Currently Running SQL")
    CALL text(5,10,"2. SQL Report")
    CALL text(6,10,"3. Tuning Status / Best Optimizer Mode Summary")
    CALL text(7,10,"4. Statistics Reporting Menu")
    CALL text(10,10,"Your Selection(0 to Exit)?")
    CALL accept(10,37,"9;",0
     WHERE curaccept IN (0, 1, 2, 3, 4))
    CASE (curaccept)
     OF 0:
      RETURN(1)
     OF 1:
      EXECUTE dm2_cur_sql
      IF (dm_err->err_ind)
       RETURN(0)
      ENDIF
     OF 2:
      EXECUTE dm2_cbo_sql_report
      IF (dm_err->err_ind)
       GO TO exit_script
      ENDIF
     OF 3:
      EXECUTE dm2_cbo_tuning_report
      IF (dm_err->err_ind)
       GO TO exit_script
      ENDIF
     OF 4:
      EXECUTE dm2_dbstats_menu
      IF (dm_err->err_ind)
       GO TO exit_script
      ENDIF
     OF 5:
      IF ( NOT (drs_sql_plan(null)))
       RETURN(0)
      ENDIF
    ENDCASE
  ENDWHILE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drs_sql_plan(null)
   DECLARE dsp_hash_value = f8 WITH protect, noconstant(0.0)
   DECLARE dsp_hash_change = i2 WITH protect, noconstant(0)
   SET dsp_hash_change = 0
   WHILE (true)
     SET width = 132
     SET message = window
     SET accept = nopatcheck
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"SQL Plan Report")
     CALL text(5,2,"Hash_Value:")
     CALL text(5,14,cnvtstring(dsp_hash_value,16))
     CALL text(21,2,"(C)reate Report, (M)odify, (V)iew SQL Report, (Q)uit:")
     CASE (dsp_hash_change)
      OF 0:
       CALL accept(21,56,"A;CU","V"
        WHERE curaccept IN ("C", "M", "V", "Q"))
      OF 1:
       CALL accept(21,56,"A;CU","M"
        WHERE curaccept IN ("C", "M", "V", "Q"))
      OF 2:
       CALL accept(21,56,"A;CU","C"
        WHERE curaccept IN ("C", "M", "V", "Q"))
      OF 3:
       CALL accept(21,56,"A;CU","Q"
        WHERE curaccept IN ("C", "M", "V", "Q"))
     ENDCASE
     CASE (curaccept)
      OF "C":
       SET dm_err->eproc =
       "Selecting data from dm_sql_perf_dtl_plan/dm_sql_perf_dtl/dm_sql_performance into CCL displayer."
       SELECT INTO mine
        dsp.hash_value, dspd.optimizer_mode, dspdp.vsql_plan_ident,
        dspdp.operation, dspdp.options, dspdp.object_name,
        dspdp.object_ident, dspdp.object_owner, dspdp.object_node,
        dspdp.optimizer, dspdp.parent_ident, dspdp.depth,
        dspdp.position, dspdp.search_columns, dspdp.cost,
        dspdp.cardinality, dspdp.bytes, dspdp.other_tag,
        dspdp.other, dspdp.distribution, dspdp.cpu_cost,
        dspdp.io_cost, dspdp.temp_space, dspdp.access_predicates,
        dspdp.filter_predicates, dsp.dm_sql_id
        FROM dm_sql_perf_dtl_plan dspdp,
         dm_sql_perf_dtl dspd,
         dm_sql_performance dsp
        WHERE dsp.hash_value=dsp_hash_value
         AND dspd.dm_sql_perf_dtl_id=dspdp.dm_sql_perf_dtl_id
         AND dspdp.dm_sql_id=dsp.dm_sql_id
         AND dsp.dm_sql_id=dspd.dm_sql_id
        ORDER BY dsp.dm_sql_id, dspd.optimizer_mode, dspdp.vsql_plan_ident
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       SET dsp_hash_change = 3
      OF "M":
       CALL accept(5,14,"N(16);CH",dsp_hash_value)
       SET dsp_hash_value = cnvtreal(curaccept)
       SET dsp_hash_change = 2
      OF "V":
       EXECUTE dm2_cbo_sql_report
       IF (dm_err->err_ind)
        RETURN(0)
       ENDIF
       SET dsp_hash_change = 1
      OF "Q":
       RETURN(1)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dca_maintenance_screen(null)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"CBO Maintenance")
     CALL text(2,(104 - size(dcr_optvalues->implementer_opt_mode)),concat(
       "Current Optimizer Setting: ",build(dcr_optvalues->implementer_opt_mode)))
     CALL text(4,10,"1. Reset single SQL statement to be re-tuned")
     CALL text(5,10,"2. Reset ALL SQL statements to be re-tuned")
     CALL text(7,10,"Your Selection(0 to Exit)?")
     CALL accept(7,37,"9;",0
      WHERE curaccept IN (0, 1, 2))
     CASE (curaccept)
      OF 0:
       RETURN(1)
      OF 1:
       IF (dms_reset_single_sql(null)=0)
        RETURN(0)
       ENDIF
      OF 2:
       IF (dms_reset_all_sql(null)=0)
        RETURN(0)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dms_reset_single_sql(null)
   DECLARE drss_msg = vc WITH private, noconstant("")
   DECLARE drss_counter = i4 WITH private, noconstant(0)
   DECLARE drss_txt = vc WITH private, noconstant("")
   DECLARE drss_hash_value = f8 WITH protect, noconstant(0.0)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"SQL Reset Selection Prompt")
     CALL text(5,2,"Please provide a hash_value that the CBO Implementer should set to be re-tuned.")
     IF ((sql_statement->statement_hash=0.0))
      CALL text(7,2,"Hash_Value:")
     ELSE
      CALL text(7,2,concat("Hash_Value: ",cnvtstring(sql_statement->statement_hash,16)))
     ENDIF
     CALL text(9,2,"SQL:")
     FOR (drss_counter = 1 TO least(10,sql_statement->sqltext_cnt))
       CALL text((9+ drss_counter),2,sql_statement->sqltext[drss_counter].text_line)
     ENDFOR
     CALL text(21,2,"(S)elect, (R)eset, (V)iew SQL Report, (Q)uit:")
     CALL text(23,2,drss_msg)
     CALL accept(21,56,"A;CU","Q"
      WHERE curaccept IN ("S", "R", "V", "Q"))
     SET drss_msg = ""
     CASE (curaccept)
      OF "Q":
       SET sql_statement->statement_hash = 0.0
       SET sql_statement->sqltext_cnt = 0
       SET stat = alterlist(sql_statement->sqltext,sql_statement->sqltext_cnt)
       RETURN(1)
      OF "S":
       CALL accept(7,14,"N(16);CH"," ")
       SET drss_hash_value = cnvtreal(curaccept)
       SET sql_statement->statement_hash = 0.0
       SET sql_statement->sqltext_cnt = 0
       SET stat = alterlist(sql_statement->sqltext,sql_statement->sqltext_cnt)
       IF (drss_hash_value != 0.0)
        SET dm_err->eproc = "Selecting sql_statement from dm_sql_performance/dm_sql_perf_text."
        SELECT INTO "nl:"
         FROM dm_sql_performance dsp,
          dm_sql_perf_text dspt
         WHERE dsp.dm_sql_id=dspt.dm_sql_id
          AND dsp.hash_value=drss_hash_value
          AND  NOT (dsp.dm_sql_id IN (
         (SELECT
          di.info_number
          FROM dm_info di
          WHERE di.info_domain="DM_CBO_IMPLEMENTER"
           AND di.info_name="RESET_SINGLE*")))
          AND  NOT ( EXISTS (
         (SELECT
          "X"
          FROM dm_info di
          WHERE di.info_domain="DM_CBO_IMPLEMENTER"
           AND di.info_name="RESET_ALL")))
         ORDER BY dsp.hash_value, dspt.sql_text_seq
         HEAD dsp.hash_value
          sql_statement->statement_hash = drss_hash_value, sql_statement->sql_id = dsp.dm_sql_id
         DETAIL
          sql_statement->sqltext_cnt = (sql_statement->sqltext_cnt+ 1), stat = alterlist(
           sql_statement->sqltext,sql_statement->sqltext_cnt), sql_statement->sqltext[sql_statement->
          sqltext_cnt].text_line = dspt.sql_text
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc))
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         RETURN(0)
        ENDIF
        IF ((sql_statement->statement_hash=0.0))
         SET drss_msg = "Invalid Hash_Value supplied"
        ENDIF
       ENDIF
      OF "R":
       IF ((sql_statement->statement_hash=0.0))
        CALL clear(23,2,125)
        SET drss_msg = "You must (S)elect a SQL statement first."
       ELSE
        CASE (dms_sql_reset_prompt(null))
         OF "Y":
          SET drss_txt = build("RESET_SINGLE_",sql_statement->sql_id)
          SET dm_err->eproc = "Selecting from dm_info to see if row is already marked for reset."
          SELECT INTO "nl:"
           FROM dm_info di
           WHERE di.info_domain="DM_CBO_IMPLEMENTER"
            AND di.info_name=value(drss_txt)
            AND (di.info_number=sql_statement->sql_id)
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc))
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           RETURN(0)
          ENDIF
          IF (curqual=0)
           SET dm_err->eproc = "Inserting row into dm_info to mark single tuned SQL to be reset."
           INSERT  FROM dm_info di
            SET di.info_domain = "DM_CBO_IMPLEMENTER", di.info_name = value(drss_txt), di.info_number
              = sql_statement->sql_id
            WITH nocounter
           ;end insert
           IF (check_error(dm_err->eproc))
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            ROLLBACK
            RETURN(0)
           ELSE
            COMMIT
           ENDIF
          ENDIF
          SET message = window
          CALL clear(1,1)
          CALL box(1,1,24,131)
          CALL text(4,10,concat("The statement has been reset.  Press enter to return."))
          CALL accept(4,64,"P;CHE"," ")
        ENDCASE
        SET sql_statement->statement_hash = 0.0
        SET sql_statement->sqltext_cnt = 0
        SET stat = alterlist(sql_statement->sqltext,sql_statement->sqltext_cnt)
       ENDIF
      OF "V":
       SET sql_statement->statement_hash = 0.0
       SET sql_statement->sqltext_cnt = 0
       SET stat = alterlist(sql_statement->sqltext,sql_statement->sqltext_cnt)
       EXECUTE dm2_cbo_sql_report
       IF (dm_err->err_ind)
        RETURN(0)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dms_reset_all_sql(null)
  CASE (dms_sql_reset_prompt(null))
   OF "N":
    RETURN(1)
   OF "Y":
    SET dm_err->eproc =
    "Selecting from dm_info to see if RESET_ALL alreadys exists for DM_CBO_IMPLEMENTER."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM_CBO_IMPLEMENTER"
      AND di.info_name="RESET_ALL"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Inserting row into dm_info to mark ALL previously tuned SQL to be reset."
     INSERT  FROM dm_info di
      SET di.info_domain = "DM_CBO_IMPLEMENTER", di.info_name = "RESET_ALL"
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,24,131)
    CALL text(4,10,concat("ALL SQL statements have been reset.  Press enter to return."))
    CALL accept(4,70,"P;CHE"," ")
  ENDCASE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dms_sql_reset_prompt(null)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL video(b)
   CALL text(2,10,"Warning!!")
   CALL video(n)
   CALL text(4,10,"This will reset the best optimizer mode determined by the CBO Implementer process"
    )
   CALL text(5,10,
    "for the selected SQL statement(s).  This may temporarily affect the performance of the selected SQL"
    )
   CALL text(6,10,"statement(s) until the best optimizer mode is determined again.")
   CALL text(8,10,"Do you want to continue? (Y/N):")
   CALL accept(8,42,"A;CU","N"
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE dca_switch_cbo_prompt(null)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL video(b)
   CALL text(2,10,"Warning!!")
   CALL video(n)
   CALL text(4,10,"Database Statistics MUST be current before turning Cerner's CBO Implementer ON.")
   CALL text(5,10,
    "The accuracy of Cerner's CBO Implementation process is dependent upon current statistics.")
   CALL text(6,10,
    "When Cerner's CBO Implementer is initially turned on, the performance of SQL statements may be")
   CALL text(7,10,"temporarily affected until the best optimizer mode has been determined.")
   CALL text(8,10,
    "Database statistics need to be gathered on a routine basis to ensure Oracle will optimize SQL efficiently."
    )
   CALL text(10,10,"Do you want to continue? (Y/N):")
   CALL accept(10,42,"A;CU","N"
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE dca_switch_rbo_prompt(null)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL video(b)
   CALL text(2,10,"Warning!!")
   CALL video(n)
   CALL text(4,10,"You are requesting the database environment to be set to run in RULE.")
   CALL text(6,10,"Do you want to continue? (Y/N):")
   CALL accept(6,42,"A;CU","N"
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE dca_enable_implementer(null)
   IF (((((currev * 1000000)+ (currevminor * 1000))+ currevminor2) < 8003010))
    SET dm_err->eproc = "Verify CCL version."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "CCL Version must be 8.3.10 or higher to run the CBO Implementer."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   EXECUTE dm_load_cbo_stat
   IF (dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dca_disable_implementer(null)
   SET dm_err->eproc = "Updating dm_info row to turn on CBO Implementer."
   UPDATE  FROM dm_info di
    SET di.info_char = "ROUTINEX"
    WHERE di.info_domain="DM_STAT_GATHER"
     AND di.info_name="DM_CBO_IMPLEMENTER"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (dm_err->err_ind)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
 ENDIF
 SET dm_err->eproc = "Ending dm2_cbo_admin."
 CALL final_disp_msg("dm2_cbo_admin")
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
