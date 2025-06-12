CREATE PROGRAM dcp_upd_prob_icd9_snmct_c:dba
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
 IF ((validate(mn_num_children,- (1))=- (1)))
  DECLARE mn_num_children = i4 WITH protect, noconstant(0)
 ENDIF
 IF ((validate(mn_num_tabs,- (2))=- (2)))
  DECLARE mn_num_tabs = i2 WITH protect, noconstant(0)
 ENDIF
 IF ((validate(dm2_rdm_parallel_debug_ind,- (1))=- (1)))
  DECLARE dm2_rdm_parallel_debug_ind = i2 WITH protect, noconstant(0)
 ELSEIF (dm2_rdm_parallel_debug_ind=1)
  CALL echo("*** Debugging mode for parallel readmes has been enabled ***")
  DECLARE debug_spaceline = c255 WITH protect, noconstant("")
  SET debug_spaceline = fillstring(255," ")
 ENDIF
 SUBROUTINE (sbr_insert_dm_info(ps_domain=vc,ps_name=vc,ps_char=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_insert_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   CALL sbr_parallel_debug_echo(concat("Info Name:   ",ps_name))
   CALL sbr_parallel_debug_echo(concat("Info Char:   ",ps_char))
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM dm_info di
    SET di.info_domain = ps_domain, di.info_name = ps_name, di.info_number = 0,
     di.info_date = cnvtdatetime(sysdate), di.info_char = ps_char
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to insert range values into DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_insert_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_insert_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_update_dm_info(ps_domain=vc,ps_name=vc,ps_char=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_update_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   CALL sbr_parallel_debug_echo(concat("Info Name:   ",ps_name))
   CALL sbr_parallel_debug_echo(concat("Info Char:   ",ps_char))
   DECLARE errmsg = vc WITH protect, noconstant("")
   UPDATE  FROM dm_info di
    SET di.info_number = 0, di.info_date = cnvtdatetime(sysdate), di.info_char = ps_char
    WHERE di.info_domain=ps_domain
     AND di.info_name=ps_name
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update range values into DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_update_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_update_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_delete_dm_info(ps_domain=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_delete_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   DECLARE errmsg = vc WITH protect, noconstant("")
   DELETE  FROM dm_info
    WHERE info_domain=ps_domain
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from the DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_delete_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_delete_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_wipe_ranges(ms_info_domain_nm=vc,ms_child_prefix=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_wipe_ranges()")
   CALL sbr_parallel_debug_echo(concat("Domain Name:  ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Range Prefix: ",ms_child_prefix))
   DECLARE temp_range = vc WITH protect, noconstant("min:0:max:0")
   DECLARE temp_range_name = vc WITH protect, noconstant("")
   IF (sbr_delete_dm_info(ms_info_domain_nm)=0)
    CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 0")
    RETURN(0)
   ENDIF
   FOR (range_idx = 1 TO mn_num_children)
    SET temp_range_name = concat(ms_child_prefix," ",cnvtstring(range_idx))
    IF (sbr_insert_dm_info(ms_info_domain_nm,temp_range_name,temp_range)=0)
     CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 0")
     RETURN(0)
    ENDIF
   ENDFOR
   CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_count_children(ms_info_domain_nm=vc) =i4)
   CALL sbr_parallel_debug_echo("Entering sbr_count_children()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ms_info_domain_nm))
   DECLARE mn_count = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_char="SUCCESS"
    DETAIL
     mn_count += 1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to select from info_table for success row: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_count_children() return: -1")
    RETURN(- (1))
   ENDIF
   CALL sbr_parallel_debug_echo(concat("sbr_count_children() return: ",build(mn_count)))
   RETURN(mn_count)
 END ;Subroutine
 SUBROUTINE (sbr_parallel_debug_echo(ms_msg=vc) =null)
   IF (dm2_rdm_parallel_debug_ind=1)
    IF (findstring("() return:",ms_msg) > 0)
     SET mn_num_tabs = maxval(0,(mn_num_tabs - 1))
    ENDIF
    CALL echo(concat(substring(1,(mn_num_tabs * 2),debug_spaceline),trim(ms_msg,1)))
    IF (ms_msg=patstring("Entering*?"))
     SET mn_num_tabs += 1
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE sbr_create_temp_table(ps_tbl_name=vc) = null
 DECLARE sbr_run_sql(null) = i2
 DECLARE sbr_drop_sql_objects(null) = i2
 SUBROUTINE sbr_run_sql(null)
   CALL sbr_parallel_debug_echo("Entering sbr_run_sql()")
   DECLARE tmp_type = vc WITH protect, noconstant("")
   DECLARE tmp_name = vc WITH protect, noconstant("")
   DECLARE exists_ind = i2 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE ora_idx = i4 WITH protect, noconstant(0)
   DECLARE parser_stmt = vc WITH protect, noconstant("")
   FOR (ora_idx = 1 TO size(parallel_oragen3->sql_list,5))
     CALL sbr_parallel_debug_echo(concat("SQL object number: ",build(ora_idx)))
     SET exists_ind = 0
     IF (textlen(trim(parallel_oragen3->sql_list[ora_idx].message)) > 0)
      CALL echo(parallel_oragen3->sql_list[ora_idx].message)
     ENDIF
     SET tmp_type = cnvtupper(parallel_oragen3->sql_list[ora_idx].obj_type)
     SET tmp_name = cnvtupper(parallel_oragen3->sql_list[ora_idx].obj_name)
     IF (tmp_type="TABLE")
      CALL sbr_parallel_debug_echo("SQL object is a table")
      IF (sbr_drop_temp_table(tmp_name)=0)
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
      CALL echo(parallel_oragen3->sql_list[ora_idx].message)
      SET parser_stmt = concat("rdb asis(^",parallel_oragen3->sql_list[ora_idx].sql,"^) go")
      CALL sbr_parallel_debug_echo(concat("Table parser statement: ",parser_stmt))
      CALL parser(trim(parser_stmt))
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to run table SQL for '",tmp_name,"': ",errmsg)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
      IF (sbr_sync_ccl_tmp_def(tmp_name)=0)
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
     ELSEIF (tmp_type="TRIGGER")
      CALL sbr_parallel_debug_echo("SQL object is a trigger")
      SELECT INTO "nl:"
       FROM user_triggers ut
       WHERE cnvtupper(ut.trigger_name)=tmp_name
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Trigger already exists")
       SET parser_stmt = concat("rdb asis(^DROP TRIGGER ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Trigger drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop trigger '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
      CALL echo(parallel_oragen3->sql_list[ora_idx].message)
      SET parser_stmt = concat("rdb asis(^",parallel_oragen3->sql_list[ora_idx].sql,"^) go")
      CALL sbr_parallel_debug_echo(concat("Trigger SQL parser statement: ",parser_stmt))
      CALL parser(trim(parser_stmt))
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to run trigger SQL for '",tmp_name,"': ",errmsg)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
     ELSEIF (tmp_type="INDEX")
      CALL sbr_parallel_debug_echo("SQL object is an index")
      SELECT INTO "nl:"
       FROM user_indexes uai
       WHERE cnvtupper(uai.index_name)=tmp_name
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Index already exists")
       SET parser_stmt = concat("rdb asis(^DROP INDEX ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Index drop statement:",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop index '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
      CALL echo(parallel_oragen3->sql_list[ora_idx].message)
      SET parser_stmt = concat("rdb asis(^",parallel_oragen3->sql_list[ora_idx].sql,"^) go")
      CALL sbr_parallel_debug_echo(concat("Index SQL parser statement: ",parser_stmt))
      CALL parser(trim(parser_stmt))
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to run index SQL for '",tmp_name,"': ",errmsg)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
     ELSEIF (tmp_type="FUNCTION")
      CALL sbr_parallel_debug_echo("SQL object is a function")
      SELECT INTO "nl:"
       FROM user_objects uo
       WHERE uo.object_name=tmp_name
        AND uo.object_type="FUNCTION"
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Function already exists")
       SET parser_stmt = concat("rdb asis(^DROP FUNCTION ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Trigger drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop function '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
      CALL echo(parallel_oragen3->sql_list[ora_idx].message)
      SET parser_stmt = concat("rdb asis(^",parallel_oragen3->sql_list[ora_idx].sql,"^) go")
      CALL sbr_parallel_debug_echo(concat("Trigger SQL parser statement: ",parser_stmt))
      CALL parser(trim(parser_stmt))
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to run function SQL for '",tmp_name,"': ",errmsg)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
     ELSEIF (tmp_type="PROCEDURE")
      CALL sbr_parallel_debug_echo("SQL object is a procedure")
      SELECT INTO "nl:"
       FROM user_procedures up
       WHERE up.object_name=tmp_name
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Procedure already exists")
       SET parser_stmt = concat("rdb asis(^DROP PROCEDURE ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Procedure drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop procedure '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
      CALL echo(parallel_oragen3->sql_list[ora_idx].message)
      SET parser_stmt = concat("rdb asis(^",parallel_oragen3->sql_list[ora_idx].sql,"^) go")
      CALL sbr_parallel_debug_echo(concat("Procedure SQL parser statement: ",parser_stmt))
      CALL parser(trim(parser_stmt))
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to run procedure SQL for '",tmp_name,"': ",errmsg)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
     ELSEIF (tmp_type="SEQUENCE")
      CALL sbr_parallel_debug_echo("SQL object is a sequence")
      SELECT INTO "nl:"
       FROM user_sequences us
       WHERE us.sequence_name=tmp_name
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Sequence already exists")
       SET parser_stmt = concat("rdb asis(^DROP SEQUENCE ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Sequence drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop sequence '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
      CALL echo(parallel_oragen3->sql_list[ora_idx].message)
      SET parser_stmt = concat("rdb asis(^",parallel_oragen3->sql_list[ora_idx].sql,"^) go")
      CALL sbr_parallel_debug_echo(concat("Sequence SQL parser statement: ",parser_stmt))
      CALL parser(trim(parser_stmt))
      IF (error(errmsg,0) > 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Failed to run sequence SQL for '",tmp_name,"': ",errmsg)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
       RETURN(0)
      ENDIF
     ELSE
      SET readme_data->status = "F"
      SET readme_data->message = concat("An invalid object type of '",tmp_type,
       "' was specified in sbr_run_sql()")
      CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
      CALL sbr_parallel_debug_echo("sbr_run_sql() return: 0")
      RETURN(0)
     ENDIF
   ENDFOR
   CALL sbr_parallel_debug_echo("sbr_run_sql() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_drop_sql_objects(null)
   CALL sbr_parallel_debug_echo("Entering sbr_drop_sql_objects()")
   DECLARE tmp_type = vc WITH protect, noconstant("")
   DECLARE tmp_name = vc WITH protect, noconstant("")
   DECLARE parser_stmt = vc WITH protect, noconstant("")
   DECLARE exists_ind = i2 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE ora_idx = i4 WITH protect, noconstant(0)
   FOR (ora_idx = 1 TO size(parallel_drop->sql_list,5))
     CALL sbr_parallel_debug_echo(concat("SQL object number: ",build(ora_idx)))
     SET exists_ind = 0
     IF (textlen(trim(parallel_drop->sql_list[ora_idx].message)) > 0)
      CALL echo(parallel_drop->sql_list[ora_idx].message)
     ENDIF
     SET tmp_type = cnvtupper(parallel_drop->sql_list[ora_idx].obj_type)
     SET tmp_name = cnvtupper(parallel_drop->sql_list[ora_idx].obj_name)
     IF (tmp_type="TABLE")
      CALL sbr_parallel_debug_echo("SQL object is a table")
      IF (sbr_drop_temp_table(tmp_name)=0)
       CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
       RETURN(0)
      ENDIF
     ELSEIF (tmp_type="TRIGGER")
      CALL sbr_parallel_debug_echo("SQL object is a trigger")
      SELECT INTO "nl:"
       FROM user_triggers ut
       WHERE cnvtupper(ut.trigger_name)=tmp_name
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      CALL echo(parallel_drop->sql_list[ora_idx].message)
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Trigger exists")
       SET parser_stmt = concat("rdb asis(^DROP TRIGGER ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Trigger drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop trigger '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF (tmp_type="INDEX")
      CALL sbr_parallel_debug_echo("SQL object is an index")
      DECLARE tablename = vc WITH protect, noconstant("")
      SELECT INTO "nl:"
       FROM user_indexes uai
       WHERE cnvtupper(uai.index_name)=tmp_name
       DETAIL
        exists_ind = 1, tablename = uai.table_name
       WITH nocounter
      ;end select
      CALL echo(parallel_drop->sql_list[ora_idx].message)
      IF (exists_ind=1)
       IF (sbr_truncate_table(tablename)=0)
        CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
        RETURN(0)
       ENDIF
       SET parser_stmt = concat("rdb asis(^DROP INDEX ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Index drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop index '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF (tmp_type="FUNCTION")
      CALL sbr_parallel_debug_echo("SQL object is a function")
      SELECT INTO "nl:"
       FROM user_objects uo
       WHERE uo.object_name=tmp_name
        AND uo.object_type="FUNCTION"
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      CALL echo(parallel_drop->sql_list[ora_idx].message)
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Function exists")
       SET parser_stmt = concat("rdb asis(^DROP FUNCTION ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Function drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop function '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF (tmp_type="PROCEDURE")
      CALL sbr_parallel_debug_echo("SQL object is a procedure")
      SELECT INTO "nl:"
       FROM user_procedures up
       WHERE up.object_name=tmp_name
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      CALL echo(parallel_drop->sql_list[ora_idx].message)
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Function exists")
       SET parser_stmt = concat("rdb asis(^DROP PROCEDURE ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Procedure drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop procedure '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF (tmp_type="SEQUENCE")
      CALL sbr_parallel_debug_echo("SQL object is a sequence")
      SELECT INTO "nl:"
       FROM user_sequences us
       WHERE us.sequence_name=tmp_name
       DETAIL
        exists_ind = 1
       WITH nocounter
      ;end select
      CALL echo(parallel_drop->sql_list[ora_idx].message)
      IF (exists_ind=1)
       CALL sbr_parallel_debug_echo("Function exists")
       SET parser_stmt = concat("rdb asis(^DROP SEQUENCE ",tmp_name,"^) go")
       CALL sbr_parallel_debug_echo(concat("Sequence drop parser statement: ",parser_stmt))
       CALL parser(trim(parser_stmt))
       IF (error(errmsg,0) > 0)
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to drop sequence '",tmp_name,"': ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
        RETURN(0)
       ENDIF
      ENDIF
     ELSE
      SET readme_data->status = "F"
      SET readme_data->message = concat("An invalid object type of '",tmp_type,
       "' was specified in sbr_drop_sql_objects()")
      CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
      CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 0")
      RETURN(0)
     ENDIF
   ENDFOR
   CALL sbr_parallel_debug_echo("sbr_drop_sql_objects() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_add_dropped_object(ms_obj_type=vc,ms_obj_name=vc,ms_message=vc) =null)
   CALL sbr_parallel_debug_echo("Entering sbr_add_dropped_object()")
   CALL sbr_parallel_debug_echo(concat("Object Type: ",ms_obj_type))
   CALL sbr_parallel_debug_echo(concat("Object Name: ",ms_obj_name))
   CALL sbr_parallel_debug_echo(concat("Message:     ",ms_message))
   DECLARE mn_idx = i4 WITH protect, noconstant((size(parallel_drop->sql_list,5)+ 1))
   SET stat = alterlist(parallel_drop->sql_list,mn_idx)
   SET parallel_drop->sql_list[mn_idx].obj_type = trim(ms_obj_type,3)
   SET parallel_drop->sql_list[mn_idx].obj_name = trim(ms_obj_name,3)
   SET parallel_drop->sql_list[mn_idx].message = trim(ms_message,3)
   CALL sbr_parallel_debug_echo("sbr_add_dropped_object() return: <No return value>")
 END ;Subroutine
 SUBROUTINE (sbr_add_sql_stmt(ms_obj_type=vc,ms_obj_name=vc,ms_sql=vc,ms_message=vc) =null)
   CALL sbr_parallel_debug_echo("Entering sbr_add_sql_stmt()")
   CALL sbr_parallel_debug_echo(concat("Object Type: ",ms_obj_type))
   CALL sbr_parallel_debug_echo(concat("Object Name: ",ms_obj_name))
   CALL sbr_parallel_debug_echo(concat("Object SQL:  ",ms_sql))
   CALL sbr_parallel_debug_echo(concat("Message:     ",ms_message))
   DECLARE mn_idx = i4 WITH protect, noconstant((size(parallel_oragen3->sql_list,5)+ 1))
   SET stat = alterlist(parallel_oragen3->sql_list,mn_idx)
   SET parallel_oragen3->sql_list[mn_idx].obj_type = trim(ms_obj_type,3)
   SET parallel_oragen3->sql_list[mn_idx].obj_name = trim(ms_obj_name,3)
   SET parallel_oragen3->sql_list[mn_idx].message = trim(ms_message,3)
   SET parallel_oragen3->sql_list[mn_idx].sql = trim(ms_sql,3)
   CALL sbr_parallel_debug_echo("sbr_add_sql_stmt() return: <No return value>")
 END ;Subroutine
 SUBROUTINE (sbr_sync_ccl_tmp_def(tbl_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_sync_ccl_tmp_def()")
   CALL sbr_parallel_debug_echo(concat("Table Name: ",tbl_name))
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE parser_stmt = vc WITH protect, noconstant("")
   IF (sbr_create_ccl_tmp_def(tbl_name)=0)
    CALL sbr_parallel_debug_echo("sbr_sync_ccl_tmp_def() return: 0")
    RETURN(0)
   ENDIF
   IF (sbr_truncate_table(tbl_name)=0)
    CALL sbr_parallel_debug_echo("sbr_sync_ccl_tmp_def() return: 0")
    RETURN(0)
   ENDIF
   CALL sbr_parallel_debug_echo(concat("Table '",trim(tbl_name,3),"' CCL definition created"))
   CALL sbr_parallel_debug_echo("sbr_sync_ccl_tmp_def() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_create_ccl_tmp_def(tbl_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_create_ccl_tmp_def()")
   CALL sbr_parallel_debug_echo(concat("Table Name: ",tbl_name))
   DECLARE errmsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dtableattr a
    PLAN (a
     WHERE a.table_name=tbl_name)
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to select from DTABLEATTR: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_create_ccl_tmp_def() return: 0")
    RETURN(0)
   ENDIF
   IF (curqual=0)
    CALL sbr_parallel_debug_echo("CCL definition of table not found")
    EXECUTE oragen3 value(tbl_name)
    IF ((dm_err->err_ind=1))
     SET readme_data->status = "F"
     SET readme_data->message = concat(
      "Error executing oragen3 during temporary table creation of table '",tbl_name,"'")
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_create_ccl_tmp_def() return: 0")
     RETURN(0)
    ENDIF
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_create_ccl_tmp_def() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_drop_temp_table(ps_tbl_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_drop_temp_table()")
   CALL sbr_parallel_debug_echo(concat("Table Name: ",ps_tbl_name))
   DECLARE mf_oracle_ver = i4 WITH protect, noconstant(0)
   DECLARE mn_tbl_exists = i2 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE parser_stmt = vc WITH protect, noconstant("")
   SET mn_tbl_exists = 0
   SET mn_tbl_exists = sbr_table_exists(ps_tbl_name)
   IF (mn_tbl_exists=2)
    CALL sbr_parallel_debug_echo("sbr_drop_temp_table() return: 0")
    RETURN(0)
   ENDIF
   IF (mn_tbl_exists=1)
    CALL sbr_parallel_debug_echo("Table exists at Oracle level")
    SELECT INTO "nl:"
     FROM product_component_version p
     WHERE cnvtupper(p.product)="ORACLE*"
     DETAIL
      mf_oracle_ver = cnvtint(substring(1,findstring(".",p.version,1,0),p.version)),
      CALL echo(build("ORACLE_VERSION: ",mf_oracle_ver))
     WITH nocounter
    ;end select
    IF (mf_oracle_ver >= 10)
     CALL sbr_parallel_debug_echo("Running Oracle 10 or later")
     IF (sbr_truncate_table(ps_tbl_name)=0)
      CALL sbr_parallel_debug_echo("sbr_drop_temp_table() return: 0")
      RETURN(0)
     ENDIF
     SET parser_stmt = concat("rdb asis(^ drop table ",ps_tbl_name," purge ^) go")
     CALL sbr_parallel_debug_echo(concat("Oracle table drop parser statement: ",parser_stmt))
     CALL parser(trim(parser_stmt))
    ELSE
     CALL sbr_parallel_debug_echo("Running Oracle 9 or earlier")
     IF (sbr_truncate_table(ps_tbl_name)=0)
      CALL sbr_parallel_debug_echo("sbr_drop_temp_table() return: 0")
      RETURN(0)
     ENDIF
     SET parser_stmt = concat("rdb asis(^ drop table ",ps_tbl_name," ^) go")
     CALL sbr_parallel_debug_echo(concat("Oracle table drop parser statement: ",parser_stmt))
     CALL parser(trim(parser_stmt))
    ENDIF
    IF (error(errmsg,0) != 0)
     CALL echo(
      "Error dropping temporary table (rdbms level). Issue the following commands to manually drop the table.."
      )
     CALL echo(concat("rdb truncate table  ",ps_tbl_name," go "))
     CALL echo(concat("rdb drop table  ",ps_tbl_name," go "))
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error dropping temp table RDBMS level: ",errmsg)
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_drop_temp_table() return: 0")
     RETURN(0)
    ENDIF
    SET parser_stmt = concat("drop table ",ps_tbl_name," go")
    CALL sbr_parallel_debug_echo(concat("CCL table drop parser statement: ",parser_stmt))
    CALL parser(trim(parser_stmt))
    IF (error(errmsg,0) != 0)
     CALL echo(
      "Error dropping table definition (ccl level). Issue the following command to manually drop the definition:"
      )
     CALL echo(concat("drop table  ",ps_tbl_name," go "))
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error dropping temp table CCL level: ",errmsg)
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_drop_temp_table() return: 0")
     RETURN(0)
    ENDIF
    CALL sbr_parallel_debug_echo(concat("Temporary table ",ps_tbl_name," - dropped "))
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_drop_temp_table() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_truncate_table(tbl_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_truncate_table()")
   CALL sbr_parallel_debug_echo(concat("Table Name: ",tbl_name))
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE parser_stmt = vc WITH protect, noconstant("")
   DECLARE tblexistsind = i2 WITH protect, noconstant(0)
   SET tblexistsind = sbr_table_exists(tbl_name)
   IF (tblexistsind=2)
    CALL sbr_parallel_debug_echo("sbr_truncate_table() return: 0")
    RETURN(0)
   ELSEIF (tblexistsind=0)
    CALL sbr_parallel_debug_echo("sbr_truncate_table() return: 1")
    RETURN(1)
   ENDIF
   SET parser_stmt = concat("rdb asis(^ truncate table ",tbl_name," ^) go")
   CALL sbr_parallel_debug_echo(concat("Table truncation parser statement: ",parser_stmt))
   CALL parser(trim(parser_stmt))
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed in table truncation: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_truncate_table() return: 0")
    RETURN(0)
   ENDIF
   CALL sbr_parallel_debug_echo(concat("Table '",trim(tbl_name,3),"' truncated"))
   CALL sbr_parallel_debug_echo("sbr_truncate_table() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_table_exists(tbl_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_table_exists()")
   CALL sbr_parallel_debug_echo(concat("Table Name: ",tbl_name))
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE parser_stmt = vc WITH protect, noconstant("")
   DECLARE tblexistsind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name=cnvtupper(tbl_name)
    DETAIL
     tblexistsind = 1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed in checking USER_TABLES existence of '",cnvtupper(
      tbl_name),"': ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_table_exists() return: 2")
    RETURN(2)
   ENDIF
   CALL sbr_parallel_debug_echo(concat("sbr_table_exists() return: ",build(tblexistsind)))
   RETURN(tblexistsind)
 END ;Subroutine
 DECLARE sbr_dm2_rdm_resume_on_chk(null) = null
 DECLARE sbr_dm2_rdm_resume_off_chk(null) = null
 IF ((validate(mf_range_id_increment,- (1))=- (1)))
  DECLARE mf_range_id_increment = f8 WITH protect, noconstant(0.0)
  SET mf_range_id_increment = 250000
 ENDIF
 IF ((validate(mf_readme_num,- (1))=- (1)))
  DECLARE mf_readme_num = i4 WITH protect, noconstant(0)
  IF ((readme_data->readme_id > 0))
   SET mf_readme_num = readme_data->readme_id
  ELSE
   SET readme_data->status = "F"
   SET readme_data->message =
   "Readme executed incorrectly; please run readme as part of uptime steps."
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((validate(mf_maxruntime,- (1))=- (1)))
  DECLARE mf_maxruntime = f8 WITH protect, constant(7200.0)
 ENDIF
 DECLARE mf_max_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_min_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_runtime = f8 WITH protect, noconstant(0.0)
 DECLARE dq_starttime = dq8 WITH protect
 DECLARE mn_child_failed = i2 WITH protect, noconstant(0)
 DECLARE mn_rollback_seg_failed = i2 WITH protect, noconstant(0)
 DECLARE mn_deadlock_ind = i2 WITH protect, noconstant(0)
 DECLARE mf_baseline = f8 WITH protect, constant(2000.0)
 DECLARE mf_min_increment = f8 WITH protect, constant(1000.0)
 DECLARE mf_min_batch_tm = f8 WITH protect, noconstant(- (1.0))
 DECLARE mf_max_batch_tm = f8 WITH protect, noconstant(- (1.0))
 DECLARE prev_batch_size = f8 WITH protect, noconstant(cnvtreal(mf_range_id_increment))
 DECLARE dm_info_batch_size = f8 WITH protect, noconstant(cnvtreal(mf_range_id_increment))
 DECLARE new_batch_size = f8 WITH protect, noconstant(cnvtreal(mf_range_id_increment))
 SUBROUTINE sbr_dm2_rdm_resume_on_chk(null)
   IF (checkprg("DM2_RDM_RESUME_ON") > 0)
    EXECUTE dm2_rdm_resume_on
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_dm2_rdm_resume_off_chk(null)
   IF (checkprg("DM2_RDM_RESUME_OFF") > 0)
    EXECUTE dm2_rdm_resume_off
   ENDIF
 END ;Subroutine
 SUBROUTINE (sbr_claim_min_max_row(ms_info_domain_nm=vc,ms_child_prefix=vc,ms_child_max_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_claim_min_max_row()")
   CALL sbr_parallel_debug_echo(concat("Info Domain:       ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Range Name Prefix: ",ms_child_prefix))
   CALL sbr_parallel_debug_echo(concat("Max Eval Row Name: ",ms_child_max_name))
   DECLARE ms_info_name = vc WITH protect, noconstant("")
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE mf_min_range_id = f8 WITH protect, noconstant(0.0)
   DECLARE ms_min_max_string = vc WITH protect, noconstant("")
   DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
   DECLARE ml_pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_name=concat(ms_child_max_name," ",cnvtstring(mf_readme_num))
     AND di.info_char="SUCCESS"
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error selecting from DM_INFO to find previous success: ",
     errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
    RETURN(2)
   ENDIF
   IF (curqual > 0)
    SET readme_data->status = "S"
    SET readme_data->message = "Readme previously ran successfully"
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 0")
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_number=mf_readme_num
     AND di.info_name=patstring(concat(ms_child_prefix,"*"))
    DETAIL
     ms_info_name = di.info_name, ms_min_max_string = di.info_char
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error selecting from DM_INFO to see if readme started: ",
     errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
    RETURN(2)
   ENDIF
   IF (curqual=0)
    CALL sbr_parallel_debug_echo("Readme has not run previously.")
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=ms_info_domain_nm
      AND di.info_number=0
      AND di.info_name=patstring(concat(ms_child_prefix,"*"))
     DETAIL
      ms_info_name = di.info_name, ms_min_max_string = di.info_char
     WITH maxqual(di,1), forupdatewait(di), nocounter
    ;end select
    IF (error(errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error selecting from DM_INFO to find available range: ",
      errmsg)
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
     RETURN(2)
    ENDIF
    IF (curqual=1)
     CALL sbr_parallel_debug_echo("Readme has not previously claimed a range")
     UPDATE  FROM dm_info di
      SET di.info_number = mf_readme_num
      WHERE di.info_domain=ms_info_domain_nm
       AND di.info_number=0
       AND di.info_name=ms_info_name
      WITH nocounter
     ;end update
     IF (error(errmsg,0) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to obtain row level lock on DM_INFO: ",errmsg)
      CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
      CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
      RETURN(2)
     ELSE
      CALL sbr_parallel_debug_echo("Committing range claim")
      COMMIT
     ENDIF
     SET ml_end_pos = findstring(":max:",ms_min_max_string)
     SET ml_pos = (findstring("min:",ms_min_max_string)+ 4)
     SET mf_min_range_id = cnvtreal(substring(ml_pos,(ml_end_pos - ml_pos),ms_min_max_string))
     CALL sbr_parallel_debug_echo(concat("Minimum ID: ",cnvtstring(mf_min_range_id)))
     INSERT  FROM dm_info di
      SET di.info_domain = ms_info_domain_nm, di.info_name = concat(ms_child_max_name," ",cnvtstring(
         mf_readme_num)), di.info_number = mf_min_range_id,
       di.info_long_id = mf_range_id_increment, di.info_date = cnvtdatetime(sysdate), di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
     IF (error(errmsg,0) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to insert new minimum into DM_INFO: ",errmsg)
      CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
      CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
      RETURN(2)
     ELSE
      CALL sbr_parallel_debug_echo("Committing max eval row insertion")
      COMMIT
      IF (sbr_add_stats_row(mf_readme_num,ms_child_max_name,mf_min_batch_tm,mf_max_batch_tm)=0)
       CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
       RETURN(2)
      ENDIF
      CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 1")
      RETURN(1)
     ENDIF
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message = "Failed to lock or find parent row on DM_INFO for update."
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
     RETURN(2)
    ENDIF
   ELSE
    CALL sbr_parallel_debug_echo("Readme has already claimed a range")
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=ms_info_domain_nm
      AND di.info_name=concat(ms_child_max_name," ",cnvtstring(mf_readme_num))
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL sbr_parallel_debug_echo("Max evaluated ID row does not exist")
     SET ml_end_pos = findstring(":max:",ms_min_max_string)
     SET ml_pos = (findstring("min:",ms_min_max_string)+ 4)
     SET mf_min_range_id = cnvtreal(substring(ml_pos,(ml_end_pos - ml_pos),ms_min_max_string))
     CALL sbr_parallel_debug_echo(concat("Minimum ID: ",cnvtstring(mf_min_range_id)))
     INSERT  FROM dm_info di
      SET di.info_domain = ms_info_domain_nm, di.info_name = concat(ms_child_max_name," ",cnvtstring(
         mf_readme_num)), di.info_number = mf_min_range_id,
       di.info_long_id = mf_range_id_increment, di.info_date = cnvtdatetime(sysdate), di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
     IF (error(errmsg,0) != 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to insert new minimum after finding claimed row: ",
       errmsg)
      CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
      CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
      RETURN(2)
     ELSEIF (sbr_add_stats_row(mf_readme_num,ms_child_max_name,mf_min_batch_tm,mf_max_batch_tm)=0)
      CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 2")
      RETURN(2)
     ENDIF
    ENDIF
    CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 1")
    RETURN(1)
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_claim_min_max_row() return: 0")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (sbr_fetch_min_max(ms_info_domain_nm=vc,ms_child_prefix=vc,ms_child_max_name=vc,
  mf_max_range_id=f8(ref),mf_min_range_id=f8(ref)) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_fetch_min_max()")
   CALL sbr_parallel_debug_echo(concat("Domain Name:       ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Range Prefix:      ",ms_child_prefix))
   CALL sbr_parallel_debug_echo(concat("Max Eval Row Name: ",ms_child_max_name))
   CALL sbr_parallel_debug_echo(concat("Maximum ID:        ",cnvtstring(mf_max_range_id)))
   CALL sbr_parallel_debug_echo(concat("Minimum ID:        ",cnvtstring(mf_min_range_id)))
   DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
   DECLARE ml_pos = i4 WITH protect, noconstant(0)
   DECLARE mf_cur_min_id = f8 WITH protect, noconstant(0.0)
   DECLARE mf_cur_max_id = f8 WITH protect, noconstant(0.0)
   DECLARE ms_info_name = vc WITH protect, noconstant("")
   DECLARE ms_min_max_string = vc WITH protect, noconstant("")
   DECLARE errmsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_number=mf_readme_num
     AND di.info_name=patstring(concat(ms_child_prefix,"*"))
    DETAIL
     ms_min_max_string = di.info_char
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to lock or find parent row on DM_INFO for update."
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_fetch_min_max() return: 2")
    RETURN(2)
   ENDIF
   CALL sbr_parallel_debug_echo("Found range claimed by readme")
   SET ml_end_pos = findstring(":max:",ms_min_max_string)
   SET mf_max_range_id = cnvtreal(substring((ml_end_pos+ 5),textlen(ms_min_max_string),
     ms_min_max_string))
   CALL sbr_parallel_debug_echo(concat("Maximum ID: ",cnvtstring(mf_max_range_id)))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_name=concat(ms_child_max_name," ",cnvtstring(mf_readme_num))
    DETAIL
     mf_min_range_id = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL sbr_parallel_debug_echo("No max eval row found")
    SET ml_pos = (findstring("min:",ms_min_max_string)+ 4)
    SET mf_min_range_id = cnvtreal(substring(ml_pos,(ml_end_pos - ml_pos),ms_min_max_string))
    CALL sbr_parallel_debug_echo(concat("Minimum ID: ",cnvtstring(mf_min_range_id)))
   ENDIF
   IF (mf_max_range_id <= 0)
    UPDATE  FROM dm_info di
     SET di.info_char = "SUCCESS"
     WHERE di.info_domain=ms_info_domain_nm
      AND di.info_name=concat(ms_child_max_name," ",cnvtstring(mf_readme_num))
     WITH nocounter
    ;end update
    IF (error(errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to update child row in DM_INFO: ",errmsg)
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_fetch_min_max() return: 2")
     RETURN(2)
    ELSE
     COMMIT
     SET readme_data->status = "S"
     SET readme_data->message =
     "Auto-success: there were not any rows for this child readme to update or insert."
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_fetch_min_max() return: 0")
     RETURN(0)
    ENDIF
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_fetch_min_max() return: 0")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_run_child(ms_info_domain_nm=vc,ms_child_prefix=vc,ms_child_max_name=vc,ms_cc_script=
  vc,mf_max_range_id=f8,mf_min_range_id=f8) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_run_child()")
   CALL sbr_parallel_debug_echo(concat("Domain Name:       ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Range Prefix:      ",ms_child_prefix))
   CALL sbr_parallel_debug_echo(concat("Max Eval Row Name: ",ms_child_max_name))
   CALL sbr_parallel_debug_echo(concat("CC script:         ",ms_cc_script))
   CALL sbr_parallel_debug_echo(concat("Minimum ID:        ",cnvtstring(mf_min_range_id)))
   CALL sbr_parallel_debug_echo(concat("Maximum ID:        ",cnvtstring(mf_max_range_id)))
   DECLARE z = i4 WITH private, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE ms_parser_string = vc WITH protect, noconstant("")
   DECLARE ml_runner_stat = i2 WITH protect, noconstant(0)
   DECLARE ms_cur_min_id = vc WITH protect, noconstant("")
   DECLARE ms_cur_max_id = vc WITH protect, noconstant("")
   DECLARE mn_deadlock_cnt = i4 WITH protect, noconstant(0)
   SET ms_info_domain_nm = trim(ms_info_domain_nm)
   SET ms_child_prefix = trim(ms_child_prefix)
   SET ms_child_max_name = trim(ms_child_max_name)
   SET mf_min_batch_tm = - (1.0)
   SET mf_max_batch_tm = - (1.0)
   SET mf_cur_min_id = mf_min_range_id
   SET mf_cur_max_id = ((mf_cur_min_id+ mf_range_id_increment) - 1)
   CALL sbr_dm2_rdm_resume_on_chk(null)
   WHILE (mf_cur_min_id <= mf_max_range_id)
     SET mf_runtime = 0
     SET dq_starttime = cnvtdatetime(sysdate)
     IF (mf_cur_max_id > mf_max_range_id)
      SET mf_cur_max_id = mf_max_range_id
     ENDIF
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM2_README_RUNNER"
       AND di.info_name=currdbhandle
      DETAIL
       ml_runner_stat = di.info_number
      WITH nocounter
     ;end select
     IF (curqual >= 1
      AND ml_runner_stat IN (0, 2))
      SET readme_data->status = "R"
      SET readme_data->message = "Readme runner scheduled to stop; adding readme to runner pool..."
      CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
      CALL sbr_parallel_debug_echo("sbr_run_child() return: 0")
      RETURN(0)
     ENDIF
     SET ms_cur_min_id = concat(trim(cnvtstring(mf_cur_min_id),3),".00")
     SET ms_cur_max_id = concat(trim(cnvtstring(mf_cur_max_id),3),".00")
     CALL sbr_parallel_debug_echo(concat("Current minimum ID: ",ms_cur_min_id))
     CALL sbr_parallel_debug_echo(concat("Current maximum ID: ",ms_cur_max_id))
     CALL sbr_parallel_debug_echo("Calling dm_run_parallel_cc_script")
     EXECUTE dm_run_parallel_cc_script
     IF (mn_child_failed=1)
      CALL sbr_dm2_rdm_resume_off_chk(null)
      CALL sbr_parallel_debug_echo("sbr_run_child() return: 2")
      RETURN(2)
     ENDIF
     SET prev_batch_size = mf_range_id_increment
     SET new_batch_size = mf_range_id_increment
     IF (mn_rollback_seg_failed=1)
      IF (mf_range_id_increment > mf_baseline)
       SET new_batch_size = ceil((mf_range_id_increment/ 2))
      ELSEIF (mf_range_id_increment > mf_min_increment)
       SET new_batch_size = mf_min_increment
      ELSE
       SET readme_data->status = "F"
       SET readme_data->message = concat("Encountered rollback segment failure; could not recover: ",
        readme_data->message)
       CALL sbr_dm2_rdm_resume_off_chk(null)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_child() return: 2")
       RETURN(2)
      ENDIF
      SET mf_cur_max_id = ((mf_cur_min_id+ mf_range_id_increment) - 1)
      SET mn_rollback_seg_failed = 0
     ELSEIF (mn_deadlock_ind=1)
      SET mn_deadlock_ind = 0
      SET mn_deadlock_cnt += 1
      IF (mn_deadlock_cnt >= 3)
       SET readme_data->status = "F"
       SET readme_data->message = concat(
        "Reached maximum deadlock limit of 3; please check Oracle alert logs ",
        "for possible trace and debug information regarding this deadlock.")
       CALL sbr_dm2_rdm_resume_off_chk(null)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_child() return: 2")
       RETURN(2)
      ENDIF
     ELSEIF (mf_runtime >= mf_maxruntime)
      IF (mf_range_id_increment > mf_baseline)
       SET new_batch_size = ceil((mf_range_id_increment/ 2))
      ELSEIF (mf_range_id_increment > mf_min_increment)
       SET new_batch_size = mf_min_increment
      ELSE
       SET readme_data->status = "F"
       SET readme_data->message = concat(
        "Readme took too long to run, and could not reduce range increment any more. ","Failing...")
       CALL sbr_dm2_rdm_resume_off_chk(null)
       CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
       CALL sbr_parallel_debug_echo("sbr_run_child() return: 2")
       RETURN(2)
      ENDIF
     ENDIF
     CALL sbr_parallel_debug_echo(concat("New range increment: ",cnvtstring(new_batch_size)))
     IF (mn_rollback_seg_failed != 1
      AND mn_deadlock_ind != 1)
      SET mn_deadlock_cnt = 0
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain=ms_info_domain_nm
        AND di.info_name=concat(trim(ms_child_max_name)," ",cnvtstring(mf_readme_num))
       DETAIL
        dm_info_batch_size = di.info_long_id
       WITH nocounter
      ;end select
      IF (prev_batch_size=dm_info_batch_size)
       CALL sbr_parallel_debug_echo("No change in batch size on DM_INFO; using new batch size")
       SET mf_range_id_increment = new_batch_size
      ELSEIF (prev_batch_size=new_batch_size)
       CALL sbr_parallel_debug_echo(concat(
         "No change in batch size due to rollbacks or timing issues; using batch ","size on DM_INFO")
        )
       SET mf_range_id_increment = dm_info_batch_size
      ELSE
       CALL sbr_parallel_debug_echo(concat(
         "Batch size discrepancy found; using smaller value between ",cnvtstring(new_batch_size),
         " and ",cnvtstring(dm_info_batch_size)))
       SET mf_range_id_increment = minval(new_batch_size,dm_info_batch_size)
      ENDIF
      CALL sbr_parallel_debug_echo(concat("Final range increment: ",cnvtstring(mf_range_id_increment)
        ))
      IF (mf_range_id_increment != dm_info_batch_size)
       UPDATE  FROM dm_info di
        SET di.info_long_id = mf_range_id_increment, di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm =
         cnvtdatetime(sysdate)
        WHERE di.info_domain=ms_info_domain_nm
         AND di.info_name=concat(trim(ms_child_max_name)," ",cnvtstring(mf_readme_num))
        WITH nocounter
       ;end update
       IF (error(errmsg,0) > 0)
        ROLLBACK
        SET readme_data->status = "F"
        SET readme_data->message = concat("Failed to update batch size: ",errmsg)
        CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
        CALL sbr_parallel_debug_echo("sbr_run_child() return: 2")
        RETURN(2)
       ELSE
        CALL sbr_parallel_debug_echo("Commit update of range increment")
        COMMIT
       ENDIF
      ENDIF
      SET mf_cur_min_id = (mf_cur_max_id+ 1)
      SET mf_cur_max_id = ((mf_cur_min_id+ mf_range_id_increment) - 1)
     ENDIF
   ENDWHILE
   CALL sbr_dm2_rdm_resume_off_chk(null)
   UPDATE  FROM dm_info di
    SET di.info_char = "SUCCESS"
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_name=concat(ms_child_max_name," ",cnvtstring(mf_readme_num))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update child row in DM_INFO to 'SUCCESS': ",errmsg)
    CALL sbr_parallel_debug_echo("sbr_run_child() return: 2")
    RETURN(2)
   ENDIF
   CALL sbr_parallel_debug_echo("Committing 'SUCCESS' update")
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_run_child() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_add_stats_row(mf_readme_id=i4,ms_range_name=vc,mf_min_batch=f8(ref),mf_max_batch=f8(
   ref)) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_add_stats_row()")
   CALL sbr_parallel_debug_echo(concat("Readme ID:           ",cnvtstring(mf_readme_id)))
   CALL sbr_parallel_debug_echo(concat("Max Eval Row Prefix: ",ms_range_name))
   CALL sbr_parallel_debug_echo(concat("Minimum runtime:     ",cnvtstring(mf_min_batch)))
   CALL sbr_parallel_debug_echo(concat("Maximum runtime:     ",cnvtstring(mf_max_batch)))
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE maxevalstring = vc WITH protect, noconstant(concat(trim(ms_range_name,3)," ",cnvtstring(
      mf_readme_id)))
   CALL sbr_parallel_debug_echo(concat("Max Eval Row Name: ",maxevalstring))
   SELECT INTO "nl:"
    FROM dm_parallel_readme_stats dprs
    WHERE dprs.readme_id=mf_readme_id
     AND dprs.range_name=maxevalstring
    DETAIL
     mf_min_batch = dprs.min_batch_tm, mf_max_batch = dprs.max_batch_tm
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL sbr_parallel_debug_echo("DM_PARALLEL_STATS row does not exist")
    INSERT  FROM dm_parallel_readme_stats dprs
     SET dprs.readme_stats_id = seq(dm_ref_seq,nextval), dprs.readme_id = mf_readme_id, dprs
      .range_name = maxevalstring,
      dprs.total_elapsed_tm = 0, dprs.min_batch_tm = mf_min_batch, dprs.max_batch_tm = mf_max_batch,
      dprs.std_dvtn_square = 0, dprs.updt_applctx = reqinfo->updt_applctx, dprs.updt_cnt = 0,
      dprs.updt_dt_tm = cnvtdatetime(sysdate), dprs.updt_id = reqinfo->updt_id, dprs.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to insert parallel stats row: ",errmsg)
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_add_stats_row() return: 0")
     RETURN(0)
    ELSE
     COMMIT
     CALL sbr_parallel_debug_echo("Committing parallel stats row insertion")
     CALL sbr_parallel_debug_echo("sbr_add_stats_row() return: 1")
     RETURN(1)
    ENDIF
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_add_stats_row() return: 1")
   RETURN(1)
 END ;Subroutine
 DECLARE parent_script_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT")
 DECLARE range_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT RANGE")
 DECLARE child_c_script_name = vc WITH protect, constant("dcp_upd_prob_icd9_snmct_cc")
 DECLARE max_person_id_eval = vc WITH protect, constant("MAX PERSON_ID EVALUATED")
 DECLARE range_name_p2 = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT CAT5 RANGE")
 DECLARE max_num_children = i4 WITH protect, constant(5)
 DECLARE batch_size_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT BATCH SIZE")
 DECLARE oracle_hint_name = vc WITH protect, constant("DCP_UPD_PROB_ICD9_SNMCT_AUDIT ORAHINT")
 SET readme_data->status = "F"
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 DECLARE ms_child_info_domain_nm = vc WITH protect, noconstant("")
 DECLARE ms_range_prefix = vc WITH protect, noconstant("")
 DECLARE ms_child_max_name = vc WITH protect, noconstant("")
 DECLARE ms_child_script = vc WITH protect, noconstant("")
 DECLARE ms_errmsg = vc WITH protect, noconstant("")
 DECLARE dvocabtypecs = i4 WITH protect, constant(400)
 DECLARE dicd9 = f8 WITH protect, noconstant(0.0)
 DECLARE dsnmct = f8 WITH protect, noconstant(0.0)
 DECLARE dactivestatuscs = i4 WITH protect, constant(48)
 DECLARE dinactive = f8 WITH protect, noconstant(0.0)
 DECLARE dactive = f8 WITH protect, noconstant(0.0)
 DECLARE ddatastatuscs = i4 WITH protect, constant(8)
 DECLARE dauth = f8 WITH protect, noconstant(0.0)
 DECLARE systemuserid = f8 WITH protect, noconstant(0.0)
 DECLARE userorahint = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=dvocabtypecs
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.cdf_meaning IN ("ICD9", "SNMCT")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ICD9":
     dicd9 = cv.code_value
    OF "SNMCT":
     dsnmct = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving code values: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=dactivestatuscs
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.cdf_meaning IN ("INACTIVE", "ACTIVE")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "INACTIVE":
     dinactive = cv.code_value
    OF "ACTIVE":
     dactive = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving code values: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=ddatastatuscs
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.cdf_meaning IN ("AUTH")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "AUTH":
     dauth = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving code values: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 EXECUTE ccluarxrtl
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error executing ccluarxrtl: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  userid = p.person_id
  FROM prsnl p
  WHERE p.name_last_key="SYSTEM"
   AND p.name_first_key="SYSTEM"
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY p.person_id
  DETAIL
   systemuserid = userid
  WITH maxqual(p,1)
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving SYSTEM person Id: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SET ms_child_info_domain_nm = parent_script_name
 SET ms_range_prefix = range_name
 SET ms_child_max_name = max_person_id_eval
 SET ms_child_script = child_c_script_name
 SET mf_range_id_increment = 100000
 SELECT INTO "nl:"
  custom_batchsize = info_number
  FROM dm_info
  WHERE info_domain=ms_child_info_domain_nm
   AND info_name=batch_size_name
  DETAIL
   IF (custom_batchsize > 0)
    mf_range_id_increment = custom_batchsize
   ENDIF
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving user-defined batch size from DM_INFO: ",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 IF (curqual=1)
  UPDATE  FROM dm_info
   SET info_long_id = mf_range_id_increment
   WHERE info_domain=ms_child_info_domain_nm
    AND info_name=concat(ms_child_max_name," ",cnvtstring(mf_readme_num))
  ;end update
  IF (error(ms_errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "Error updating batch size for existing readme rows on DM_INFO: ",ms_errmsg)
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET userorahint =
 "LEADING (P N N2) INDEX(P XIE1PROBLEM) INDEX (N XPKNOMENCLATURE) INDEX (N2 XIE8NOMENCLATURE)"
 SELECT INTO "nl:"
  custom_orahint = trim(info_char,3)
  FROM dm_info
  WHERE info_domain=ms_child_info_domain_nm
   AND info_name=oracle_hint_name
  DETAIL
   userorahint = custom_orahint
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving user-defined oracle hint from DM_INFO: ",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 CALL echo(build("userOraHint in C: ",userorahint))
 IF (sbr_claim_min_max_row(ms_child_info_domain_nm,ms_range_prefix,ms_child_max_name) IN (2, 0))
  GO TO exit_program
 ENDIF
 IF (sbr_fetch_min_max(ms_child_info_domain_nm,ms_range_prefix,ms_child_max_name,mf_max_range_id,
  mf_min_range_id) IN (2, 0))
  GO TO exit_program
 ENDIF
 IF (sbr_sync_ccl_tmp_def("TEMP_PROB_ICD9_SNMCT")=0)
  GO TO exit_program
 ENDIF
 IF (sbr_run_child(ms_child_info_domain_nm,ms_range_prefix,ms_child_max_name,ms_child_script,
  mf_max_range_id,
  mf_min_range_id) IN (2, 0))
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme completed all work successfully"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  CALL sbr_truncate_table("TEMP_PROB_ICD9_SNMCT")
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
