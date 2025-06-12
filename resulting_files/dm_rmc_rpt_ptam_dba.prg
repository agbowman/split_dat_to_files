CREATE PROGRAM dm_rmc_rpt_ptam:dba
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE drdc_to_string(dts_num=f8) = vc
 SUBROUTINE drdc_to_string(dts_num)
   DECLARE dts_str = vc WITH protect, noconstant("")
   SET dts_str = trim(cnvtstring(dts_num,20),3)
   IF (findstring(".",dts_str)=0)
    SET dts_str = concat(dts_str,".0")
   ENDIF
   RETURN(dts_str)
 END ;Subroutine
 DECLARE drmmi_set_mock_id(dsmi_cur_id=f8,dsmi_final_tgt_id=f8,dsmi_mock_ind=i2) = i4
 DECLARE drmmi_get_mock_id(dgmi_env_id=f8) = f8
 DECLARE drmmi_backfill_mock_id(dbmi_env_id=f8) = f8
 SUBROUTINE drmmi_set_mock_id(dsmi_cur_id,dsmi_final_tgt_id,dsmi_mock_ind)
   DECLARE dsmi_info_char = vc WITH protect, noconstant("")
   DECLARE dsmi_mock_str = vc WITH protect, noconstant("")
   SET dsmi_info_char = drdc_to_string(dsmi_cur_id)
   SET dm_err->eproc = "Delete current mock setting."
   DELETE  FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dsmi_mock_ind=1)
    SET dsmi_mock_str = "RDDS_MOCK_ENV_ID"
   ELSE
    SET dsmi_mock_str = "RDDS_NO_MOCK_ENV_ID"
   ENDIF
   SET dm_err->eproc = "Inserting new mock setting into dm_info."
   INSERT  FROM dm_info di
    SET di.info_domain = "DATA MANAGEMENT", di.info_name = dsmi_mock_str, di.info_number =
     dsmi_final_tgt_id,
     di.info_char = dsmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Log Mock Copy of Prod Change event."
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Mock Copy of Prod Change"
   SET auto_ver_request->qual[1].cur_environment_id = dsmi_cur_id
   SET auto_ver_request->qual[1].paired_environment_id = dsmi_final_tgt_id
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmmi_get_mock_id(dgmi_env_id)
   DECLARE dgmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgmi_info_char = vc WITH protect, noconstant("")
   IF (dgmi_env_id=0.0)
    SET dm_err->eproc = "Gathering environment_id from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dgmi_env_id = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ELSEIF (dgmi_env_id=0.0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Could not retrieve valid environment_id"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET dgmi_info_char = drdc_to_string(dgmi_env_id)
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dgmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dgmi_mock_id = di.info_number
     ELSE
      dgmi_mock_id = dgmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSEIF (curqual > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid MOCK setup detected."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgmi_mock_id=0.0)
    SET dgmi_mock_id = drmmi_backfill_mock_id(dgmi_env_id)
    IF (dgmi_mock_id < 0.0)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(dgmi_mock_id)
 END ;Subroutine
 SUBROUTINE drmmi_backfill_mock_id(dbmi_env_id)
   DECLARE dbmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dbmi_info_char = vc WITH protect, noconstant("")
   DECLARE dbmi_continue = i2 WITH protect, noconstant(0)
   SET dbmi_info_char = drdc_to_string(dbmi_env_id)
   WHILE (dbmi_continue=0)
     SET drl_reply->status = ""
     SET drl_reply->status_msg = ""
     CALL get_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,0,drl_reply)
     IF ((drl_reply->status="F"))
      CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = drl_reply->status_msg
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSEIF ((drl_reply->status="Z"))
      CALL pause(10)
     ELSE
      SET dbmi_continue = 1
     ENDIF
   ENDWHILE
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dbmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dbmi_mock_id = di.info_number
     ELSE
      dbmi_mock_id = dbmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
    RETURN(- (1))
   ENDIF
   IF (dbmi_mock_id=0.0)
    UPDATE  FROM dm_info di
     SET di.info_char = dbmi_info_char
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS_MOCK_ENV_ID"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
     RETURN(- (1))
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Updating RDDS_NO_MOCK_ENV_ID row."
     UPDATE  FROM dm_info di
      SET di.info_number = 0.0, di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->
       updt_applctx,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = reqinfo->updt_id,
       di.updt_task = reqinfo->updt_task
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_NO_MOCK_ENV_ID"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSE
      COMMIT
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = "Inserting RDDS_NO_MOCK_ENV_ID row."
      INSERT  FROM dm_info di
       SET di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS_NO_MOCK_ENV_ID", di.info_number
         = 0.0,
        di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
       RETURN(- (1))
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dbmi_mock_id = dbmi_env_id
    ELSE
     SET dm_err->eproc = "Querying for mock id."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_MOCK_ENV_ID"
       AND di.info_char=dbmi_info_char
      DETAIL
       dbmi_mock_id = di.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
   RETURN(dbmi_mock_id)
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
 DECLARE regen_trigs(null) = i4
 DECLARE check_open_event(cur_env_id=f8,paired_env_id=f8) = i4
 SUBROUTINE regen_trigs(null)
   DECLARE rt_err_flg = i2 WITH protect, noconstant(0)
   FREE RECORD invalid
   RECORD invalid(
     1 data[*]
       2 name = vc
   )
   SET dm_err->eproc = "Regenerating triggers..."
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_add_refchg_log_triggers
   SET dm_err->eproc = "RECOMPILING INVALID TRIGGERS"
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    HEAD REPORT
     trig_cnt = 0
    DETAIL
     trig_cnt = (trig_cnt+ 1)
     IF (mod(trig_cnt,10)=1)
      stat = alterlist(invalid->data,(trig_cnt+ 9))
     ENDIF
     invalid->data[trig_cnt].name = d1.object_name
    FOOT REPORT
     stat = alterlist(invalid->data,trig_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error checking invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   FOR (t_ndx = 1 TO size(invalid->data,5))
     CALL parser(concat("RDB ASIS(^alter trigger ",invalid->data[t_ndx].name," compile^) go"))
   ENDFOR
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    DETAIL
     v_trigger_name = d1.object_name
    WITH nocounter, maxqual(d1,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error compiling invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Triggers regenerated successfully."
    SET rt_err_flg = 0
   ELSE
    SET dm_err->eproc = "Error regenerating RDDS related triggers."
    SET rt_err_flg = 1
    RETURN(rt_err_flg)
   ENDIF
   RETURN(rt_err_flg)
 END ;Subroutine
 SUBROUTINE check_open_event(cur_env_id,paired_env_id)
   DECLARE coe_event_flg = i4 WITH protect
   IF (cur_env_id > 0
    AND paired_env_id > 0)
    SET dm_err->eproc = "Checking open events for environment pair."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND drel.paired_environment_id=paired_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND paired_environment_id=paired_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Determining reverse open events for environment pair."
     SELECT INTO "NL:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event="Begin Reference Data Sync"
       AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND drel.cur_environment_id=paired_env_id
       AND drel.paired_environment_id=cur_env_id
       AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
      (SELECT
       cur_environment_id, paired_environment_id, event_reason
       FROM dm_rdds_event_log
       WHERE cur_environment_id=paired_env_id
        AND paired_environment_id=cur_env_id
        AND rdds_event="End Reference Data Sync"
        AND rdds_event_key="ENDREFERENCEDATASYNC")))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(coe_event_flg)
     ENDIF
     IF (curqual > 0)
      SET coe_event_flg = 2
     ENDIF
    ELSE
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   IF (paired_env_id=0)
    SET dm_err->eproc = "Determining open events for current environment."
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual > 0)
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   RETURN(coe_event_flg)
 END ;Subroutine
 IF ((validate(drgi_global->source_id,- (12341))=- (12341)))
  FREE RECORD drgi_global
  RECORD drgi_global(
    1 start_dt_tm = dq8
    1 source_id = f8
    1 source_name = vc
    1 target_id = f8
    1 target_name = vc
    1 mock_id = f8
    1 env_mapping = f8
    1 db_link = vc
    1 cbc_ind = i2
    1 ctp_value = vc
    1 cts_value = vc
    1 ctxt_group_ind = i2
    1 default_ctxt = vc
    1 ptam_ind = i2
    1 oe_ind = i2
  )
 ENDIF
 DECLARE dgi_get_global_info(dgi_global=vc(ref)) = i2
 SUBROUTINE dgi_get_global_info(dgi_global)
   IF ((dgi_global->start_dt_tm=0.0))
    SET dgi_global->start_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF ((((dgi_global->target_id=0.0)) OR ((dgi_global->mock_id=0.0))) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
     DETAIL
      dgi_global->target_id = d.info_number, dgi_global->mock_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No local environment set.  Please run DM_SET_ENV_ID"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET dgi_global->mock_id = drmmi_get_mock_id(dgi_global->target_id)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dgi_global->oe_ind=0))
    SET dgi_global->oe_ind = check_open_event(dgi_global->target_id,0.0)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dgi_global->oe_ind=1))
    IF ((dgi_global->source_id=0.0))
     SELECT INTO "NL:"
      FROM dm_rdds_event_log d
      WHERE d.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND (d.cur_environment_id=dgi_global->target_id)
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_rdds_event_log l
       WHERE (l.cur_environment_id=dgi_global->target_id)
        AND l.rdds_event_key="ENDREFERENCEDATASYNC"
        AND l.event_reason=d.event_reason
        AND l.paired_environment_id=d.paired_environment_id)))
      DETAIL
       dgi_global->source_id = d.paired_environment_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
    IF ((dgi_global->db_link <= " "))
     SELECT INTO "NL:"
      FROM dm_env_reltn d
      WHERE (d.child_env_id=dgi_global->target_id)
       AND (d.parent_env_id=dgi_global->source_id)
       AND d.relationship_type="REFERENCE MERGE"
       AND d.post_link_name > " "
      DETAIL
       dgi_global->db_link = d.post_link_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
    IF ((dgi_global->env_mapping <= 0.0))
     SELECT INTO "NL:"
      FROM dm_info d
      WHERE d.info_domain="RDDS ENV PAIR"
       AND d.info_name=concat(cnvtstring(dgi_global->source_id),"::",cnvtstring(dgi_global->target_id
        ))
      DETAIL
       dgi_global->env_mapping = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
    IF ((dgi_global->ptam_ind=0))
     SELECT INTO "NL:"
      FROM dm_env_reltn d
      WHERE relationship_type="PENDING TARGET AS MASTER"
       AND (parent_env_id=dgi_global->source_id)
       AND (child_env_id=dgi_global->target_id)
      DETAIL
       dgi_global->ptam_ind = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   IF ((((dgi_global->source_name <= " ")) OR ((dgi_global->target_name <= " "))) )
    SELECT INTO "NL:"
     FROM dm_environment d
     WHERE d.environment_id IN (dgi_global->source_id, dgi_global->target_id)
     DETAIL
      IF ((d.environment_id=dgi_global->source_id))
       dgi_global->source_name = d.environment_name
      ELSE
       dgi_global->target_name = d.environment_name
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dgi_global->cbc_ind=0))
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="CUTOVER BY CONTEXT"
     DETAIL
      dgi_global->cbc_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((((dgi_global->ctp_value <= " ")) OR ((((dgi_global->cts_value <= " ")) OR ((((dgi_global->
   default_ctxt <= " ")) OR ((dgi_global->ctxt_group_ind=0))) )) )) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name IN ("CONTEXTS TO PULL", "CONTEXT TO SET", "CONTEXT GROUP_IND",
     "DEFAULT CONTEXT")
     DETAIL
      IF (d.info_name="CONTEXTS TO PULL")
       dgi_global->ctp_value = d.info_char
      ELSEIF (d.info_name="CONTEXT TO SET")
       dgi_global->cts_value = d.info_char
      ELSEIF (d.info_name="DEFAULT CONTEXT")
       dgi_global->default_ctxt = d.info_char
      ELSEIF (d.info_name="CONTEXT GROUP_IND")
       dgi_global->ctxt_group_ind = d.info_number
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 IF (validate(drqp_reply->tab_cnt,99)=99)
  FREE RECORD drqp_reply
  RECORD drqp_reply(
    1 tab_cnt = i4
    1 tab_qual[*]
      2 table_name = vc
      2 table_alias = vc
      2 dummyt_ind = i2
    1 col_cnt = i4
    1 col_qual[*]
      2 return_phrase = vc
      2 return_name = vc
      2 return_clause = vc
      2 func_ind = i2
      2 clause_alias = vc
      2 clause_column = vc
      2 all_col_ind = i2
    1 cnt = i4
    1 qual[*]
      2 text = vc
  )
 ENDIF
 DECLARE drrm_create_subject(dcs_event_type=vc,dcs_events=vc(ref),dcs_tgt_only_ind=i2) = i2
 DECLARE drrm_generate_email_file(dgef_event_type=vc,dgef_events=vc(ref)) = i2
 DECLARE drrm_generate_email_text(dgeb_event_idx=i4,dgeb_events=vc(ref),dgeb_event_type=i4) = i2
 DECLARE drrm_send_email(subject=vc,address_list=vc,file_name=vc) = i2
 SUBROUTINE drrm_create_subject(dcs_event_type,dcs_events,dcs_tgt_only_ind)
   DECLARE dcs_subject_prefix = vc
   DECLARE dcs_file_location = vc WITH protect, noconstant(logical("CCLUSERDIR"))
   DECLARE dcs_sys = vc WITH protect, noconstant("")
   IF (validate(cursys2,"-1000")="-1000"
    AND validate(cursys2,"-9999")="-9999")
    SET dcs_sys = cursys
   ELSE
    SET dcs_sys = cursys2
   ENDIF
   SET dm_err->eproc = "Getting client specified subject prefix."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    di.info_char
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=concat("RDDSPREF",dcs_events->link_name)
     AND di.info_name="E-Mail Subject Prefix"
    DETAIL
     dcs_subject_prefix = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "No row was found in dm_info for E-Mail Subject Prefix"
    RETURN(0)
   ENDIF
   IF (dcs_tgt_only_ind=1)
    SET dcs_events->subject_text = concat(dcs_subject_prefix,": ","RDDS ",dcs_event_type," - ",
     dcs_events->target_env_name)
   ELSE
    SET dcs_events->subject_text = concat(dcs_subject_prefix,": ","RDDS ",dcs_event_type," - ",
     dcs_events->source_env_name," to ",dcs_events->target_env_name)
   ENDIF
   SET dm_err->eproc = "Writing client specified subject prefix to email file."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   IF (get_unique_file("dm_rmc_email",".txt")=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Unable to create unique file name"
    GO TO exit_drrm
   ENDIF
   IF (dcs_sys="AXP")
    SET dcs_events->file_name = build(dcs_file_location,dm_err->unique_fname)
   ELSE
    SET dcs_events->file_name = build(dcs_file_location,"/",dm_err->unique_fname)
   ENDIF
   SELECT INTO dcs_events->file_name
    FROM dummyt d
    DETAIL
     row + 1, col 1, dcs_events->subject_text
    WITH append, formfeed = none, format = variable,
     maxrow = 1, nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_generate_email_file(dgef_event_type,dgef_events)
   DECLARE dgef_size = i4
   DECLARE dgef_last_loop = i4
   DECLARE dgef_flag = i4
   SET dgef_last_loop = 0
   SET dgef_flag = 0
   SET dgef_size = 0
   WHILE (dgef_flag=0)
     SET dgef_size = (dgef_size+ 1)
     SET dm_err->eproc = "Generating E-Mail file."
     CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
     SELECT INTO dgef_events->file_name
      subject_text = dgef_events->subject_text, text_line = dgef_events->qual[dgef_size].body_text[d
      .seq].text_line
      FROM (dummyt d  WITH seq = size(dgef_events->qual[dgef_size].body_text,5))
      DETAIL
       IF ((dgef_event_type=dgef_events->qual[dgef_size].msg_type_name))
        IF ((dgef_events->qual[dgef_size].header_ind=1))
         col 1, dgef_events->qual[dgef_size].body_text[d.seq].text_line
        ELSE
         IF ((dgef_events->qual[dgef_size].event_type="Auto-Cutover Error"))
          col 5, dgef_events->qual[dgef_size].event_detail1_txt, col 22,
          "     ----     ", col 39, dgef_events->qual[dgef_size].event_detail2_txt
         ELSEIF ((dgef_events->qual[dgef_size].event_type IN ("Orphaned Mover", "Stale Mover")))
          col 2, dgef_events->qual[dgef_size].event_detail1_txt
         ELSE
          col 2, dgef_events->qual[dgef_size].body_text[d.seq].text_line
         ENDIF
        ENDIF
        row + 1
       ENDIF
      WITH append, formfeed = none, format = variable,
       maxrow = 1, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      RETURN(0)
     ENDIF
     IF ((dgef_size=dgef_events->unrprtd_cnt))
      SET dgef_flag = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_generate_email_text(dgeb_event_idx,dgeb_events,dgeb_event_type)
   DECLARE dgeb_num_lines = i4 WITH protect, noconstant(0)
   DECLARE dgeb_tstart = i4 WITH protect, noconstant(0)
   DECLARE dgeb_fstart = i4 WITH protect, noconstant(0)
   DECLARE dgeb_flstr1 = i4 WITH protect, noconstant(0)
   DECLARE dgeb_flstr2 = i4 WITH protect, noconstant(0)
   CASE (dgeb_events->qual[dgeb_event_idx].event_type)
    OF "Move Finished":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,4)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 100))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   RDDS Movers have processed all of the pending DM_CHG_LOG rows for event ",dgeb_events->
      target_event_name,".")
     SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line =
     "   Please refer to change log report for detailed analysis of processing history."
    OF "Auto-Cutover Started":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,3)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 100))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   Auto-Cutover process for event ",dgeb_events->target_event_name,
      " has been started by mover process: ",dgeb_events->qual[dgeb_event_idx].event_reason,".")
    OF "Auto-Cutover Finished":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,3)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 100))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   Auto-Cutover process for event ",dgeb_events->target_event_name," has finished.")
    OF "Status Report":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Status"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,2)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Status ",trim(cnvtstring(
        (dgeb_event_idx+ 200))),":")
    OF "Stale Mover":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line concat(
       "   One or more of the mover processes for event: ",dgeb_events->target_event_name,
       " are stalled,") " and are not processing DM_CHG_LOG rows."
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please refer to the following log files in CCLUSERDIR of the ",dgeb_events->
       target_env_name," domain,")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      "or any remote nodes running RDDS movers, to see why."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "-----------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = "          LOG FILES"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line = "-----LOG FILE-----"
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = dgeb_events->qual[dgeb_event_idx
      ].event_detail1_txt
     ENDIF
    OF "Orphaned Mover":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
       "   One or more of the mover processes have abnormally terminated for event ",dgeb_events->
       target_event_name,".")
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please refer to the following log files in CCLUSERDIR of the ",dgeb_events->
       target_env_name," domain,")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      "or any remote nodes running RDDS movers, to see details."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "-----------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = "          LOG FILES"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line = "-----LOG FILE-----"
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = dgeb_events->qual[dgeb_event_idx
      ].event_detail1_txt
     ENDIF
    OF "Auto-Cutover Error":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
       "   One or more errors occurred during the Auto-Cutover that was performed for event ",
       dgeb_events->target_event_name,".")
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please look in the DM_MERGE_DOMAIN_ADM at the View Cutover Warnings report in the ",
       drrm_events->target_env_name," domain.")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      " domain to find the errors on the table pair(s) below."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "---------------------------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line =
      "                 CUTOVER WARNINGS"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line =
      "---Temporary Table-------------------Live Table----------"
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     ENDIF
    OF "Unprocessed $R Resets":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,8)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line =
      "   There are database integrity concerns for cutover that require evaluation for correction and acknowledgement."
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line =
      "   The cutover process will not be allowed to start until these rows are acknowledged."
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line = "   To view the report:"
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = concat(
       "      Merge Domain Administration Menu -> RDDS Status and Monitoring Tools -> ",
       "Dual Build Reports/Configuration")
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "      -> View Database Integrity Concerns for Cutover"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = concat(
       "   Number of Unprocessed Rows: ",cnvtstring(dgeb_events->qual[dgeb_event_idx].event_value))
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     ENDIF
    OF "Auto Cutover Dual Build Issues":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,8)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 300))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line =
      "   The mover detected that dual build was performed in the target environment.  "
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line =
      "   The cutover process will not automatically be started until these database integrity concerns are acknowledged."
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line = "   To view the report:"
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = concat(
       "      Merge Domain Administration Menu -> RDDS Status and Monitoring Tools -> ",
       "Dual Build Reports/Configuration")
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "      -> View Database Integrity Concerns for Cutover"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = concat(
       "Number of Unprocessed Rows: ",cnvtstring(dgeb_events->qual[dgeb_event_idx].event_value))
     ELSE
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     ENDIF
    OF "Task Queue Error":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Warning"
     IF ((dgeb_events->qual[dgeb_event_idx].header_ind=1))
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,9)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Warning ",trim(
        cnvtstring((dgeb_event_type+ 400))),":")
      SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
       "   One or more of the tasks attempting to run the ",dgeb_events->qual[dgeb_event_idx].
       event_reason," have abnormally terminated.")
      SET dgeb_events->qual[dgeb_event_idx].body_text[4].text_line = concat(
       "   Please refer to the following task details for explaination. ")
      SET dgeb_events->qual[dgeb_event_idx].body_text[5].text_line =
      "   If help is required, please log an SR to Common Service/Database Architecture/Foundations."
      SET dgeb_events->qual[dgeb_event_idx].body_text[6].text_line = " "
      SET dgeb_events->qual[dgeb_event_idx].body_text[7].text_line =
      "-----------------------------------------"
      SET dgeb_events->qual[dgeb_event_idx].body_text[8].text_line = "             TASK QUEUE ERRORS"
      SET dgeb_events->qual[dgeb_event_idx].body_text[9].text_line =
      "-----------------------------------------"
     ELSE
      IF (size(dgeb_events->qual[dgeb_event_idx].event_detail2_txt,1) > 100)
       SET dgeb_num_lines = (ceil((size(dgeb_events->qual[dgeb_event_idx].event_detail2_txt,1)/ 100.0
        ))+ 2)
      ELSE
       SET dgeb_num_lines = 3
      ENDIF
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,dgeb_num_lines)
      SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = concat("   Task Description: ",
       trim(dgeb_events->qual[dgeb_event_idx].event_detail1_txt,3))
      SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("   Log File Name: ",trim
       (dgeb_events->qual[dgeb_event_idx].event_detail3_txt,3))
      SET dgeb_fstart = 1
      FOR (dgeb_i = 3 TO dgeb_num_lines)
        IF (dgeb_i=3)
         SET dgeb_events->qual[dgeb_event_idx].body_text[dgeb_i].text_line = concat(
          "   Error Message: ",substring(dgeb_fstart,100,dgeb_events->qual[dgeb_event_idx].
           event_detail2_txt))
         SET dgeb_fstart = (dgeb_fstart+ 100)
        ELSE
         SET dgeb_events->qual[dgeb_event_idx].body_text[dgeb_i].text_line = concat(
          "                ",substring(dgeb_fstart,100,dgeb_events->qual[dgeb_event_idx].
           event_detail2_txt))
         SET dgeb_fstart = (dgeb_fstart+ 100)
        ENDIF
      ENDFOR
      SET dgeb_num_lines = (dgeb_num_lines+ 1)
      SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,dgeb_num_lines)
      SET dgeb_events->qual[dgeb_event_idx].body_text[dgeb_num_lines].text_line =
      "-----------------------------------------"
     ENDIF
    OF "Task Queue Finished":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Notification"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,3)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = " "
     SET dgeb_events->qual[dgeb_event_idx].body_text[2].text_line = concat("Notification ",trim(
       cnvtstring((dgeb_event_type+ 200))),":")
     SET dgeb_events->qual[dgeb_event_idx].body_text[3].text_line = concat(
      "   All of the pending tasks have been completed for the ",dgeb_events->qual[dgeb_event_idx].
      event_reason,".")
    OF "Practice":
     SET dgeb_events->qual[dgeb_event_idx].msg_type_name = "Practice"
     SET stat = alterlist(dgeb_events->qual[dgeb_event_idx].body_text,1)
     SET dgeb_events->qual[dgeb_event_idx].body_text[1].text_line = "This is a test email."
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_send_email(subject,address_list,file_name)
   DECLARE dse_sys = vc
   IF (validate(cursys2,"-1000")="-1000"
    AND validate(cursys2,"-9999")="-9999")
    SET dse_sys = cursys
   ELSE
    SET dse_sys = cursys2
   ENDIF
   IF (((trim(subject)="") OR (((trim(address_list)="") OR (trim(file_name)="")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dse_sys="AXP")
    CALL dm2_push_dcl(concat('MAIL/SUBJECT="',build(subject),'" ',build(file_name),' "',
      build(address_list),'"'))
   ELSEIF (dse_sys IN ("AIX", "LNX"))
    CALL dm2_push_dcl(concat('mail -s "',subject,'" "',address_list,'" < ',
      file_name))
   ELSEIF (dse_sys="HPX")
    CALL dm2_push_dcl(concat('mailx -s "',subject,'" "',address_list,'" < ',
      file_name))
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   ENDIF
   SET stat = remove(file_name)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 DECLARE drrac_get_env(dge_name=vc(ref),dge_id=f8(ref)) = null
 DECLARE drrac_del_audits(dda_table_name=vc) = null
 DECLARE drrac_get_file_name(dgfn_prefix=vc,dgfn_table_name=vc,dgfn_suffix=vc) = vc
 DECLARE drrac_get_audit_cnt(dgac_table_name=vc) = i4
 DECLARE drrac_get_audit_data(dgad_table_name=vc,dgad_data=vc(ref)) = null
 SUBROUTINE drrac_get_env(dge_name,dge_id)
   SELECT INTO "NL:"
    FROM dm_environment d,
     dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
     AND d.environment_id=di.info_number
    DETAIL
     dge_name = d.environment_name, dge_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Getting environment information") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drrac_del_audits(dda_table_name)
   DECLARE dda_parse_str = vc WITH protect, noconstant(" ")
   IF (dda_table_name="ALL TABLES")
    SET dda_parse_str = " 1 = 1"
   ELSE
    SET dda_parse_str = concat(" d.pref_section = '",dda_table_name,"'")
   ENDIF
   DELETE  FROM long_text_reference l
    WHERE l.parent_entity_name="DM_PREFS"
     AND list(l.long_text_id,l.parent_entity_id) IN (
    (SELECT
     d.parent_entity_id, d.pref_id
     FROM dm_prefs d
     WHERE d.application_nbr=0
      AND d.person_id=0.0
      AND d.pref_domain="RDDS AUDIT QUERY"
      AND parser(dda_parse_str)))
    WITH nocounter
   ;end delete
   IF (check_error("Deleting audit info from LONG_TEXT_REFERENCE") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   DELETE  FROM dm_prefs d
    WHERE d.application_nbr=0
     AND d.person_id=0.0
     AND d.pref_domain="RDDS AUDIT QUERY"
     AND parser(dda_parse_str)
    WITH nocounter
   ;end delete
   IF (check_error("Deleteing audit info from DM_PREFS") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drrac_get_file_name(dgfn_prefix,dgfn_table_name,dgfn_suffix)
   DECLARE dgfn_mnemonic = vc WITH protect, noconstant(logical("CLIENT_MNEMONIC"))
   DECLARE dgfn_ret = vc WITH protect, noconstant(" ")
   IF (((daf_is_blank(dgfn_prefix)) OR (daf_is_blank(dgfn_table_name))) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Invalid parameters detected: Both the audit type and table name are required."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(" ")
   ENDIF
   IF (daf_is_not_blank(dgfn_mnemonic))
    SET dgfn_ret = concat(dgfn_mnemonic,"_")
   ENDIF
   SET dgfn_ret = concat(dgfn_ret,dgfn_prefix,"_",dgfn_table_name)
   IF (daf_is_not_blank(dgfn_suffix))
    SET dgfn_ret = concat(dgfn_ret,"_",dgfn_suffix)
   ENDIF
   SET dgfn_ret = concat(dgfn_ret,".dat")
   RETURN(cnvtlower(dgfn_ret))
 END ;Subroutine
 SUBROUTINE drrac_get_audit_cnt(dgac_table_name)
   DECLARE dgac_ret = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    cnt = count(*)
    FROM dm_prefs d
    WHERE d.application_nbr=0
     AND d.person_id=0.0
     AND d.pref_domain="RDDS AUDIT QUERY"
     AND d.pref_section=patstring(dgac_table_name)
    DETAIL
     dgac_ret = cnt
    WITH nocounter
   ;end select
   IF (check_error("Querying for Audit by TableName") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   RETURN(dgac_ret)
 END ;Subroutine
 SUBROUTINE drrac_get_audit_data(dgad_table_name,dgad_data)
   SELECT INTO "NL:"
    y = nullind(d.pref_str)
    FROM long_text_reference l,
     dm_prefs d
    WHERE d.application_nbr=0
     AND d.person_id=0.0
     AND d.pref_domain="RDDS AUDIT QUERY"
     AND d.pref_section=dgad_table_name
     AND l.long_text_id=d.parent_entity_id
    HEAD REPORT
     outbuf = fillstring(32767," "), retlen = 0
    DETAIL
     dgad_data->query_cnt = (dgad_data->query_cnt+ 1), stat = alterlist(dgad_data->query_qual,
      dgad_data->query_cnt)
     IF (y=1)
      dgad_data->query_qual[dgad_data->query_cnt].query_name = d.pref_section
     ELSE
      dgad_data->query_qual[dgad_data->query_cnt].query_name = concat(trim(d.pref_section),"::",d
       .pref_str)
     ENDIF
     retlen = 1, offset = 0, freers = 0
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,l.long_text), offset = (offset+ retlen)
       IF (freers=0)
        dgad_data->query_qual[dgad_data->query_cnt].query_text = notrim(outbuf)
       ELSE
        dgad_data->query_qual[dgad_data->query_cnt].query_text = notrim(concat(notrim(dgad_data->
           query_qual[dgad_data->query_cnt].query_text),notrim(substring(1,retlen,outbuf))))
       ENDIF
       freers = 1
     ENDWHILE
     dgad_data->query_qual[dgad_data->query_cnt].query_text = trim(dgad_data->query_qual[dgad_data->
      query_cnt].query_text,5)
    WITH nocounter, rdbarrayfetch = 1
   ;end select
   IF (check_error("Querying for Audit queries") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 DECLARE rdds_audit_query = vc WITH protect, noconstant(" ")
 DECLARE rdds_audit_file = vc WITH protect, noconstant(" ")
 DECLARE rpa_tab_name = vc WITH protect, noconstant(" ")
 DECLARE rpa_audit_name = vc WITH protect, noconstant(" ")
 DECLARE rpa_max_rows = i4 WITH protect, noconstant(10000)
 DECLARE rpa_rows_found = i4 WITH protect, noconstant(0)
 DECLARE rpa_idx = i4 WITH protect, noconstant(0)
 DECLARE drrp_mnemonic = vc WITH protect, noconstant(logical("CLIENT_MNEMONIC"))
 DECLARE drrp_file_name = vc WITH protect, noconstant(" ")
 DECLARE drrp_subject = vc WITH protect, noconstant(" ")
 DECLARE drrp_heading_ind = i2 WITH protect, noconstant(0)
 DECLARE drrp_auto_ind = i2 WITH protect, noconstant(0)
 DECLARE dm_refchg_b62tob10(p1=vc) = f8
 DECLARE drrp_query_exec(rqe_query=vc,rqe_src_ind=i2,rqe_db_link=vc,rqe_file_name=vc,rqe_heading_ind=
  i2(ref)) = null
 DECLARE drrp_query_del(rqd_query=vc,rqd_audit_file=vc) = null
 IF (validate(drpa_request)=0)
  FREE RECORD drpa_request
  RECORD drpa_request(
    1 table_name = vc
    1 ctxt_cnt = i4
    1 ctxt_qual[*]
      2 ctxt_name = vc
  )
 ENDIF
 IF (validate(drrp_reply)=0)
  FREE RECORD drrp_reply
  RECORD drrp_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 FREE RECORD drrp_query
 RECORD drrp_query(
   1 cnt = i4
   1 qual[*]
     2 file_name = vc
     2 audit_name = vc
     2 query_id = f8
 )
 FREE RECORD drrga_reply
 RECORD drrga_reply(
   1 query_cnt = i4
   1 query_qual[*]
     2 query_text = vc
     2 query_name = vc
 )
 FREE RECORD drrga_request
 RECORD drrga_request(
   1 table_name = vc
   1 db_link = vc
 )
 SET dm_err->eproc = "Starting dm_rmc_rpt_ptam..."
 IF (check_logfile("dm_rmc_rpt_ptam",".log","DM_RMC_RPT_PTAM LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dgi_get_global_info(drgi_global)=1)
  GO TO exit_program
 ENDIF
 IF (validate(drrp_email)=0)
  DECLARE drrp_email = vc WITH protect, noconstant(" ")
 ENDIF
 IF (validate(drrp_request)=0)
  SET rpa_tab_name = trim(cnvtupper( $1))
  SET drpa_request->table_name = rpa_tab_name
 ELSE
  SET rpa_tab_name = drrp_request->table_name
  SET drpa_request->table_name = rpa_tab_name
  SET drpa_request->ctxt_cnt = drrp_request->ctxt_cnt
  SET stat = moverec(drrp_request->ctxt_qual,drpa_request->ctxt_qual)
 ENDIF
 EXECUTE dm_rmc_ptam_audit
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_prefs d
  WHERE d.pref_domain="RDDS AUDIT CONFIG"
   AND d.pref_section IN ("MAX ROW LIMIT", "AUTO-GEN AUDIT")
   AND d.pref_name="PTAM"
   AND d.application_nbr=0
   AND d.person_id=0
  DETAIL
   IF (d.pref_section="AUTO-GEN AUDIT")
    drrp_auto_ind = d.pref_nbr
   ELSEIF (d.pref_nbr > 0)
    rpa_max_rows = d.pref_nbr
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cnt = count(*)
  FROM dm_refchg_comp_gttd s
  WHERE s.status="1"
  DETAIL
   rpa_rows_found = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (rpa_rows_found >= rpa_max_rows)
  ROLLBACK
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(trim(cnvtstring(rpa_rows_found))," rows were found for table ",trim(
    rpa_tab_name),". The report will be skipped.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 CALL echo(concat("rows found:",trim(cnvtstring(rpa_rows_found))))
 CALL echo(concat("max rows:",trim(cnvtstring(rpa_max_rows))))
 SELECT INTO "nl:"
  FROM dm_prefs d
  WHERE d.application_nbr=0
   AND d.person_id=0
   AND d.pref_domain="RDDS AUDIT QUERY"
   AND d.pref_section=rpa_tab_name
   AND d.parent_entity_name="LONG_TEXT_REFERENCE"
  DETAIL
   drrp_query->cnt = (drrp_query->cnt+ 1), stat = alterlist(drrp_query->qual,drrp_query->cnt),
   drrp_query->qual[drrp_query->cnt].query_id = d.parent_entity_id,
   drrp_query->qual[drrp_query->cnt].file_name = d.pref_name, drrp_query->qual[drrp_query->cnt].
   audit_name = d.pref_str
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((drrp_query->cnt=0))
  IF (drrp_auto_ind=1)
   SET drrga_request->table_name = rpa_tab_name
   SET drrga_request->db_link = drgi_global->db_link
   EXECUTE dm_rmc_rpt_gen_audit
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET drrp_query->cnt = drrga_reply->query_cnt
   SET stat = alterlist(drrp_query->qual,drrp_query->cnt)
   FOR (rpa_idx = 1 TO drrp_query->cnt)
     IF (findstring("::",drrga_reply->query_qual[rpa_idx].query_name) > 0)
      SET drrp_query->qual[rpa_idx].audit_name = substring((findstring("::",drrga_reply->query_qual[
        rpa_idx].query_name)+ 2),size(drrga_reply->query_qual[rpa_idx].query_name),drrga_reply->
       query_qual[rpa_idx].query_name)
     ENDIF
   ENDFOR
  ELSE
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat("No Audit Query found for ",rpa_tab_name)
   GO TO exit_program
  ENDIF
 ENDIF
 FOR (rpa_idx = 1 TO drrp_query->cnt)
   SET rdds_audit_query = " "
   SET dm_err->eproc = "Gathering query text from long_text_reference"
   SET drrp_heading_ind = 0
   IF ((drrp_query->qual[rpa_idx].query_id=0)
    AND (drrga_reply->query_cnt > 0))
    SET rdds_audit_query = drrga_reply->query_qual[rpa_idx].query_text
   ELSE
    SELECT INTO "nl:"
     FROM long_text_reference l
     WHERE (l.long_text_id=drrp_query->qual[rpa_idx].query_id)
     HEAD REPORT
      outbuf = fillstring(32767," "), offset = 0, retlen = 0,
      freers = 0
     DETAIL
      retlen = 1
      WHILE (retlen > 0)
        retlen = blobget(outbuf,offset,l.long_text), offset = (offset+ retlen)
        IF (freers=0)
         rdds_audit_query = notrim(outbuf)
        ELSE
         rdds_audit_query = notrim(concat(notrim(rdds_audit_query),notrim(substring(1,retlen,outbuf))
           ))
        ENDIF
        freers = 1
      ENDWHILE
      rdds_audit_query = trim(rdds_audit_query,5)
     WITH nocounter, rdbarrayfetch = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
   IF (daf_is_blank(rdds_audit_query))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No Audit Query found for ",rpa_tab_name)
    GO TO exit_program
   ENDIF
   SET drrp_file_name = drrac_get_file_name("PTAM",rpa_tab_name,drrp_query->qual[rpa_idx].audit_name)
   CALL drrp_query_exec(rdds_audit_query,0," ",drrp_file_name,drrp_heading_ind)
   CALL drrp_query_exec(rdds_audit_query,1,drgi_global->db_link,drrp_file_name,drrp_heading_ind)
   CALL drrp_query_del(rdds_audit_query,drrp_file_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET rdds_audit_file = concat(rdds_audit_file,", ",drrp_file_name)
   SET drrp_subject = concat("PTAM Audit Output - ",rpa_tab_name)
   IF (daf_is_not_blank(drrp_email))
    IF (drrm_send_email(drrp_subject,drrp_email,drrp_file_name)=0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
   ENDIF
 ENDFOR
 SET rdds_audit_file = substring(2,size(rdds_audit_file),rdds_audit_file)
 SET drrp_reply->status = "S"
 SET drrp_reply->status_msg = concat("Audit created. Filename(s): ",rdds_audit_file)
 SUBROUTINE drrp_query_exec(rqe_query,rqe_src_ind,rqe_db_link,rqe_file_name,rqe_heading_ind)
   DECLARE rqe_temp_query = vc WITH protect, noconstant(rqe_query)
   DECLARE rqe_domain_str = vc WITH protect, noconstant(" ")
   DECLARE rqe_domain_flag = vc WITH protect, noconstant(" ")
   DECLARE rqe_with_str = vc WITH protect, noconstant(" ")
   IF (rqe_src_ind=1)
    SET rqe_domain_str = "SOURCE"
    SET rqe_domain_flag = "^1^"
   ELSE
    SET rqe_domain_str = "TARGET"
    SET rqe_domain_flag = "^2^"
   ENDIF
   IF (rqe_heading_ind=1)
    SET rqe_with_str = ", append, noheading"
   ENDIF
   SET rqe_temp_query = replace(rqe_temp_query,"<FILE_NAME>",rqe_file_name,0)
   SET rqe_temp_query = replace(rqe_temp_query,"<DB_LINK_TAG>",rqe_db_link,0)
   SET rqe_temp_query = replace(rqe_temp_query,"<SELECT_TAG>",concat(
     ",LOG_ID = s.l_column_value ,BLOCKING_LOG_ID = s.r_column_value,CONTEXT_NAME = s.column_name",
     ",DOMAIN = '",rqe_domain_str,"'"),0)
   SET rqe_temp_query = replace(rqe_temp_query,"<DOMAIN_FLAG>",rqe_domain_flag,0)
   SET rqe_temp_query = replace(rqe_temp_query,"<WITH_TAG>",rqe_with_str,0)
   CALL parser(concat(rqe_temp_query," go"),1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (curqual > 0)
    SET rqe_heading_ind = 1
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE drrp_query_del(rqd_query,rqd_audit_file)
   DECLARE rqd_temp_query = vc WITH protect, noconstant(rqd_query)
   DECLARE rqd_temp_str = vc WITH protect, noconstant(" ")
   DECLARE rqe_domain_str = vc WITH protect, noconstant(" ")
   DECLARE rqe_domain_flag = vc WITH protect, noconstant(" ")
   DECLARE rqd_with_pos = i4 WITH protect, noconstant(0)
   DECLARE rqd_with_str = vc WITH protect, noconstant(" ")
   SET stat = initrec(drqp_reply)
   EXECUTE dm_rmc_get_select_list rqd_query
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET rqd_with_str = replace(rqd_query,"<WITH_TAG>",", append, noheading",0)
   SET rqd_with_str = substring(findstring(notrim(" WITH "),cnvtupper(rqd_with_str),1,1),size(
     rqd_with_str,1),rqd_with_str)
   SET rqd_temp_query = concat(" select into '",rqd_audit_file,"'")
   FOR (rqd_idx = 1 TO drqp_reply->col_cnt)
     IF (findstring("<SELECT_TAG>",drqp_reply->col_qual[rqd_idx].return_phrase)=0)
      SET rqd_temp_query = concat(rqd_temp_query,' " ",')
     ELSE
      SET rqd_temp_query = concat(rqd_temp_query,
       '" ",LOG_ID = s.l_column_value ,BLOCKING_LOG_ID = s.r_column_value,CONTEXT_NAME = s.column_name,',
       "DOMAIN = evaluate(s.status,'1','SOURCE','TARGET'),")
     ENDIF
   ENDFOR
   SET rqd_temp_query = substring(1,(size(rqd_temp_query) - 1),rqd_temp_query)
   SET rqd_temp_query = concat(rqd_temp_query,
    " from dm_refchg_comp_gttd s where s.r_ptam_hash_value = -1 ",rqd_with_str)
   CALL parser(concat(rqd_temp_query," go"),1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   RETURN
 END ;Subroutine
#exit_program
 IF (check_error(dm_err->eproc)=1)
  SET drrp_reply->status = "F"
  SET drrp_reply->status_msg = dm_err->emsg
 ENDIF
END GO
