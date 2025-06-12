CREATE PROGRAM acm_rdm_svc_provider_org_p:dba
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
 FREE RECORD range_info
 RECORD range_info(
   1 list_0[*]
     2 range_name = vc
     2 range_info = vc
     2 child_max = f8
     2 child_min = f8
 ) WITH public
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
 FREE RECORD parallel_oragen3
 RECORD parallel_oragen3(
   1 sql_list[*]
     2 obj_type = vc
     2 obj_name = vc
     2 message = vc
     2 sql = vc
 ) WITH public
 DECLARE sbr_check_for_prev_rdm(mn_readme_id=i4,mn_instance=i4) = i4
 SUBROUTINE sbr_check_for_prev_rdm(mn_readme_id,mn_instance,domain_name,range_prefix)
   CALL sbr_parallel_debug_echo("Entering sbr_check_for_prev_rdm()")
   CALL sbr_parallel_debug_echo(concat("Readme ID:       ",build(mn_readme_id)))
   CALL sbr_parallel_debug_echo(concat("Readme Instance: ",build(mn_instance)))
   CALL sbr_parallel_debug_echo(concat("Domain Name:     ",domain_name))
   DECLARE errmsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_ocd_log dol
    PLAN (dol
     WHERE dol.project_type="README"
      AND dol.project_name=trim(cnvtstring(mn_readme_id),3)
      AND dol.project_instance=mn_instance
      AND dol.status="SUCCESS"
      AND (dol.environment_id=
     (SELECT
      di.info_number
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="DM_ENV_ID")))
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error selecting from the dm_ocd_log table for past readme run: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_check_for_prev_rdm() return: 2")
    RETURN(2)
   ENDIF
   IF (curqual >= 1)
    CALL sbr_parallel_debug_echo("Record of previous readme run found")
    IF (sbr_wipe_ranges(domain_name,range_prefix)=0)
     CALL sbr_parallel_debug_echo("sbr_check_for_prev_rdm() return: 2")
     RETURN(2)
    ENDIF
    SET readme_data->status = "S"
    SET readme_data->message = concat("Previous readme ",trim(cnvtstring(mn_readme_id),3),
     " has run successfully.")
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_check_for_prev_rdm() return: 1")
    RETURN(1)
   ELSE
    CALL sbr_parallel_debug_echo("No record of previous readme run found")
    CALL sbr_parallel_debug_echo("sbr_check_for_prev_rdm() return: 0")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (sbr_handle_rollback(ms_info_domain_nm=vc,mn_num_children=i4) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_handle_rollback()")
   CALL sbr_parallel_debug_echo(concat("Domain Name:        ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Number of Children: ",build(mn_num_children)))
   DECLARE mn_child_cnt = i2 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE temp_range_name = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_ocd_log dol
    PLAN (dol
     WHERE dol.project_type="README:RBACK"
      AND dol.project_name=cnvtstring(readme_data->readme_id)
      AND (dol.project_instance=readme_data->instance)
      AND (dol.environment_id=
     (SELECT
      di.info_number
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="DM_ENV_ID")))
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error selecting the dm_ocd_log table for past readme run: ",
     errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 2")
    RETURN(2)
   ENDIF
   IF (curqual >= 1)
    CALL sbr_parallel_debug_echo("Rollback record found")
    IF (sbr_delete_dm_info(ms_info_domain_nm)=0)
     CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 2")
     RETURN(2)
    ENDIF
    CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 1")
    RETURN(1)
   ELSE
    CALL sbr_parallel_debug_echo("No rollback record found")
    SET mn_child_cnt = sbr_count_children(ms_info_domain_nm)
    IF (mn_child_cnt < 0)
     CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 2")
     RETURN(2)
    ELSEIF (mn_child_cnt >= mn_num_children)
     CALL sbr_parallel_debug_echo("Children have all run successfully")
     IF (sbr_delete_dm_info(ms_info_domain_nm)=0)
      CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 2")
      RETURN(2)
     ENDIF
     FOR (range_idx = 1 TO mn_num_children)
      SET temp_range_name = concat(trim(ms_child_prefix,3)," ",cnvtstring(range_idx))
      IF (sbr_insert_dm_info(ms_info_domain_nm,temp_range_name,"min:0:max:0")=0)
       CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 2")
       RETURN(2)
      ENDIF
     ENDFOR
     SET readme_data->status = "S"
     SET readme_data->message = concat("All ",trim(cnvtstring(mn_num_children),3),
      " readmes already successful.")
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 3")
     RETURN(3)
    ELSEIF (mn_child_cnt >= 1)
     SET readme_data->status = "S"
     SET readme_data->message = "Child scripts still processing"
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 3")
     RETURN(3)
    ENDIF
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_handle_rollback() return: 0")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE sbr_add_ranges(ms_info_domain_nm,mn_num_children)
   CALL sbr_parallel_debug_echo("Entering sbr_add_ranges()")
   CALL sbr_parallel_debug_echo(concat("Domain Name:        ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Number of Children: ",build(mn_num_children)))
   IF (sbr_delete_dm_info(ms_info_domain_nm)=0)
    CALL sbr_parallel_debug_echo("sbr_add_ranges() return: 0")
    RETURN(0)
   ENDIF
   IF (sbr_wipe_parallel_stats(readme_data->readme_id)=0)
    CALL sbr_parallel_debug_echo("sbr_add_ranges() return: 0")
    RETURN(0)
   ENDIF
   FOR (range_idx = 1 TO mn_num_children)
     IF (sbr_insert_dm_info(ms_info_domain_nm,range_info->list_0[range_idx].range_name,range_info->
      list_0[range_idx].range_info)=0)
      CALL sbr_parallel_debug_echo("sbr_add_ranges() return: 0")
      RETURN(0)
     ENDIF
   ENDFOR
   CALL sbr_parallel_debug_echo("sbr_add_ranges() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_divide_rows(mf_max_range_id=f8,mf_min_range_id=f8,ms_child_prefix=vc,ms_info_domain=
  vc,mn_num_children=i4) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_divide_rows()")
   CALL sbr_parallel_debug_echo(concat("Minimum ID:         ",cnvtstring(mf_min_range_id)))
   CALL sbr_parallel_debug_echo(concat("Maximum ID:         ",cnvtstring(mf_max_range_id)))
   CALL sbr_parallel_debug_echo(concat("Child Range Prefix: ",ms_child_prefix))
   CALL sbr_parallel_debug_echo(concat("Domain Name:        ",ms_info_domain))
   CALL sbr_parallel_debug_echo(concat("Number of Children: ",build(mn_num_children)))
   DECLARE mf_child_size = f8 WITH protect, noconstant(0.0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE mn_child_cnt = i2 WITH protect, noconstant(0)
   DECLARE mf_divisor = f8 WITH protect, noconstant(0.0)
   DECLARE mf_tmp_child_size = f8 WITH protect, noconstant(0.0)
   SET stat = alterlist(range_info->list_0,mn_num_children)
   FOR (range_idx = 1 TO mn_num_children)
    SET range_info->list_0[range_idx].range_name = concat(trim(ms_child_prefix,3)," ",cnvtstring(
      range_idx))
    CALL sbr_parallel_debug_echo(concat("Range Name: ",range_info->list_0[range_idx].range_name))
   ENDFOR
   SET mn_child_cnt = sbr_count_children(ms_info_domain)
   IF (mn_child_cnt < 0)
    CALL sbr_parallel_debug_echo("sbr_divide_rows() return: 0")
    RETURN(0)
   ELSEIF (mn_child_cnt >= mn_num_children)
    CALL sbr_parallel_debug_echo("All children have run successfully")
    IF (sbr_delete_dm_info(ms_info_domain_nm)=0)
     CALL sbr_parallel_debug_echo("sbr_divide_rows() return: 2")
     RETURN(2)
    ENDIF
    FOR (range_idx = 1 TO mn_num_children)
      IF (sbr_insert_dm_info(ms_info_domain_nm,range_info->list_0[range_idx].range_name,"min:0:max:0"
       )=0)
       CALL sbr_parallel_debug_echo("sbr_divide_rows() return: 0")
       RETURN(0)
      ENDIF
    ENDFOR
    SET readme_data->status = "S"
    SET readme_data->message = concat("All ",trim(cnvtstring(mn_num_children),3),
     " readmes already successful.")
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_divide_rows() return: 0")
    RETURN(0)
   ENDIF
   IF ((((mf_max_range_id - mf_min_range_id)/ cnvtreal(mn_num_children)) > 2147483648.00))
    CALL sbr_parallel_debug_echo("Range division exceeds maximum value of i4")
    SET mf_divisor = 2
    SET mf_tmp_child_size = ((mf_max_range_id - mf_min_range_id)/ cnvtreal(mn_num_children))
    WHILE (((mf_tmp_child_size/ mf_divisor) > 2147483648.00))
      SET mf_divisor += 1
    ENDWHILE
    CALL sbr_parallel_debug_echo(concat("Final divisor value: ",cnvtstring(mf_divisor)))
    SET mf_child_size = (cnvtreal(ceil((mf_tmp_child_size/ mf_divisor))) * mf_divisor)
   ELSE
    SET mf_child_size = ceil(((mf_max_range_id - mf_min_range_id)/ cnvtreal(mn_num_children)))
   ENDIF
   CALL sbr_parallel_debug_echo(concat("Range size: ",cnvtstring(mf_child_size)))
   FOR (range_idx = 1 TO mn_num_children)
    SET range_info->list_0[range_idx].child_max = ((mf_min_range_id+ (range_idx * mf_child_size)) - 1
    )
    SET range_info->list_0[range_idx].child_min = (mf_min_range_id+ ((range_idx - 1) * mf_child_size)
    )
   ENDFOR
   SET range_info->list_0[mn_num_children].child_max = mf_max_range_id
   FOR (range_idx = 1 TO mn_num_children)
     SET range_info->list_0[range_idx].range_info = build("min:",range_info->list_0[range_idx].
      child_min,":max:",range_info->list_0[range_idx].child_max)
   ENDFOR
   CALL sbr_parallel_debug_echo("sbr_divide_rows() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_run_parent(mf_max_range_id=f8,mf_min_range_id=f8,ms_range_prefix=vc,
  ms_info_domain_nm=vc,mn_num_children=i4) =i4)
   CALL sbr_parallel_debug_echo("Entering sbr_run_parent()")
   CALL sbr_parallel_debug_echo(concat("Minimum ID:         ",cnvtstring(mf_min_range_id)))
   CALL sbr_parallel_debug_echo(concat("Maximum ID:         ",cnvtstring(mf_max_range_id)))
   CALL sbr_parallel_debug_echo(concat("Range Prefix:       ",ms_range_prefix))
   CALL sbr_parallel_debug_echo(concat("Domain Name:        ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Number of Children: ",build(mn_num_children)))
   IF (mf_max_range_id=0)
    IF (sbr_wipe_ranges(ms_info_domain_nm,ms_range_prefix)=1)
     SET readme_data->status = "S"
     SET readme_data->message = "Max ID from table is 0"
     CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
     CALL sbr_parallel_debug_echo("sbr_run_parent() return: 0")
     RETURN(0)
    ELSE
     CALL sbr_parallel_debug_echo("sbr_run_parent() return: 2")
     RETURN(2)
    ENDIF
   ENDIF
   SET stat = sbr_divide_rows(mf_max_range_id,mf_min_range_id,ms_range_prefix,ms_info_domain_nm,
    mn_num_children)
   IF (stat IN (2, 0))
    CALL sbr_parallel_debug_echo(concat("sbr_run_parent() return: ",build(stat)))
    RETURN(stat)
   ENDIF
   IF (sbr_handle_rollback(ms_info_domain_nm,mn_num_children) IN (3, 2))
    CALL sbr_parallel_debug_echo("sbr_run_parent() return: 0")
    RETURN(0)
   ENDIF
   IF (sbr_add_ranges(ms_info_domain_nm,mn_num_children)=0)
    CALL sbr_parallel_debug_echo("sbr_run_parent() return: 0")
    RETURN(0)
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_run_parent() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_wipe_parallel_stats(mf_readme_id=f8) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_wipe_parallel_stats()")
   CALL sbr_parallel_debug_echo(concat("Readme ID: ",cnvtstring(mf_readme_id)))
   IF (mf_readme_id <= 0)
    CALL sbr_parallel_debug_echo("sbr_wipe_parallel_stats() return: 1")
    RETURN(1)
   ENDIF
   DECLARE errmsg = vc WITH protect, noconstant("")
   DELETE  FROM dm_parallel_readme_stats dprs
    WHERE dprs.readme_id IN (mf_readme_id,
    (SELECT
     dr.readme_id
     FROM dm_readme dr
     WHERE dr.parent_readme_id=mf_readme_id))
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to delete parallel timing stats: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_wipe_parallel_stats() return: 0")
    RETURN(0)
   ELSE
    CALL sbr_parallel_debug_echo("Hard-committing parallel stats wipe")
    COMMIT
    CALL sbr_parallel_debug_echo("sbr_wipe_parallel_stats() return: 1")
    RETURN(1)
   ENDIF
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 DECLARE mf_min_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_info_domain_nm = vc WITH protect, noconstant("")
 DECLARE mf_min_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_range_prefix = vc WITH protect, noconstant("")
 DECLARE ms_errmsg = vc WITH protect, noconstant("")
 SET ms_info_domain_nm = "ACM_RDM_SVC_PROVIDER_ORG"
 SET ms_range_prefix = "ACM_RDM_SVC_PROVIDER_ORG_RANGE"
 SET mn_num_children = 10.0
 SELECT INTO "nl:"
  min_val = min(e.encntr_id)
  FROM encounter e
  WHERE e.encntr_id > 0
  DETAIL
   mf_min_range_id = cnvtreal(min_val)
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error selecting the min ID: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  max_val = max(a.encntr_id)
  FROM encounter a
  DETAIL
   mf_max_range_id = cnvtreal(max_val)
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error selecting the max ID: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 IF (sbr_run_parent(mf_max_range_id,mf_min_range_id,ms_range_prefix,ms_info_domain_nm,mn_num_children
  ) IN (2, 0))
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme completed successfully"
#exit_program
 FREE RECORD parallel_oragen3
 FREE RECORD range_info
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
