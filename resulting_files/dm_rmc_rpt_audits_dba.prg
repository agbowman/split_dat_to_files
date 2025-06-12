CREATE PROGRAM dm_rmc_rpt_audits:dba
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
 DECLARE drpc_manage_dmprefs(dmd_rec=vc(ref)) = null
 DECLARE drpc_get_dmprefs(dgd_rec=vc(ref)) = null
 IF ( NOT (validate(drpc_dmprefs)))
  FREE RECORD drpc_dmprefs
  RECORD drpc_dmprefs(
    1 cnt = i4
    1 qual[*]
      2 application_nbr = i4
      2 person_id = f8
      2 pref_domain = vc
      2 pref_section = vc
      2 pref_name = vc
      2 pref_nbr = i4
      2 pref_cd = f8
      2 pref_dt_tm = dq8
      2 pref_str = vc
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 reference_ind = i2
      2 delete_ind = i2
      2 no_row_ind = i2
  )
 ENDIF
 SUBROUTINE drpc_manage_dmprefs(dmd_rec)
   DECLARE dmd_idx = i4 WITH protect, noconstant(0)
   FOR (dmd_idx = 1 TO dmd_rec->cnt)
     IF ((dmd_rec->qual[dmd_idx].delete_ind=0))
      MERGE INTO dm_prefs d
      USING DUAL ON ((d.application_nbr=dmd_rec->qual[dmd_idx].application_nbr)
       AND (d.person_id=dmd_rec->qual[dmd_idx].person_id)
       AND (d.pref_domain=dmd_rec->qual[dmd_idx].pref_domain)
       AND (d.pref_name=dmd_rec->qual[dmd_idx].pref_name)
       AND (d.pref_section=dmd_rec->qual[dmd_idx].pref_section))
      WHEN MATCHED THEN
      (UPDATE
       SET d.pref_nbr = dmd_rec->qual[dmd_idx].pref_nbr, d.pref_cd = dmd_rec->qual[dmd_idx].pref_cd,
        d.pref_dt_tm = cnvtdatetime(dmd_rec->qual[dmd_idx].pref_dt_tm),
        d.pref_str = evaluate(dmd_rec->qual[dmd_idx].pref_str,"DM2NULLVAL",null,dmd_rec->qual[dmd_idx
         ].pref_str), d.parent_entity_name = evaluate(dmd_rec->qual[dmd_idx].parent_entity_name,
         "DM2NULLVAL",null,dmd_rec->qual[dmd_idx].parent_entity_name), d.parent_entity_id = dmd_rec->
        qual[dmd_idx].parent_entity_id,
        d.reference_ind = dmd_rec->qual[dmd_idx].reference_ind, d.updt_id = reqinfo->updt_id, d
        .updt_task = reqinfo->updt_task,
        d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
        .updt_cnt = (d.updt_cnt+ 1)
       WHERE 1=1
      ;end update
      )
      WHEN NOT MATCHED THEN
      (INSERT  FROM d
       (pref_id, application_nbr, person_id,
       pref_domain, pref_section, pref_name,
       pref_nbr, pref_cd, pref_dt_tm,
       pref_str, parent_entity_name, parent_entity_id,
       reference_ind, updt_id, updt_task,
       updt_applctx, updt_dt_tm)
       VALUES(seq(dm_clinical_seq,nextval), dmd_rec->qual[dmd_idx].application_nbr, dmd_rec->qual[
       dmd_idx].person_id,
       dmd_rec->qual[dmd_idx].pref_domain, dmd_rec->qual[dmd_idx].pref_section, dmd_rec->qual[dmd_idx
       ].pref_name,
       dmd_rec->qual[dmd_idx].pref_nbr, dmd_rec->qual[dmd_idx].pref_cd, cnvtdatetime(dmd_rec->qual[
        dmd_idx].pref_dt_tm),
       evaluate(dmd_rec->qual[dmd_idx].pref_str,"DM2NULLVAL",null,dmd_rec->qual[dmd_idx].pref_str),
       evaluate(dmd_rec->qual[dmd_idx].parent_entity_name,"DM2NULLVAL",null,dmd_rec->qual[dmd_idx].
        parent_entity_name), dmd_rec->qual[dmd_idx].parent_entity_id,
       dmd_rec->qual[dmd_idx].reference_ind, reqinfo->updt_id, reqinfo->updt_task,
       reqinfo->updt_applctx, cnvtdatetime(curdate,curtime3))
       WITH nocounter
      ;end insert
      )
      IF (check_error("Inserting/Updating preferences into DM_PREFS") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dmd_idx = (dmd_rec->cnt+ 1)
      ENDIF
     ELSE
      DELETE  FROM dm_prefs d
       WHERE (d.application_nbr=dmd_rec->qual[dmd_idx].application_nbr)
        AND (d.person_id=dmd_rec->qual[dmd_idx].person_id)
        AND (d.pref_domain=dmd_rec->qual[dmd_idx].pref_domain)
        AND (d.pref_name=dmd_rec->qual[dmd_idx].pref_name)
        AND (d.pref_section=dmd_rec->qual[dmd_idx].pref_section)
      ;end delete
      IF (check_error("Removing prefs from DM_PREFS") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dmd_idx = (dmd_rec->cnt+ 1)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drpc_get_dmprefs(dgd_rec)
   DECLARE dgd_idx = i4 WITH protect, noconstant(0)
   FOR (dgd_idx = 1 TO dgd_rec->cnt)
     SELECT INTO "NL:"
      ni1 = nullind(d.pref_str), ni2 = nullind(d.parent_entity_name)
      FROM dm_prefs d
      WHERE (d.application_nbr=dgd_rec->qual[dgd_idx].application_nbr)
       AND (d.person_id=dgd_rec->qual[dgd_idx].person_id)
       AND (d.pref_domain=dgd_rec->qual[dgd_idx].pref_domain)
       AND (d.pref_name=dgd_rec->qual[dgd_idx].pref_name)
       AND (d.pref_section=dgd_rec->qual[dgd_idx].pref_section)
      DETAIL
       dgd_rec->qual[dgd_idx].pref_nbr = d.pref_nbr, dgd_rec->qual[dgd_idx].pref_cd = d.pref_cd,
       dgd_rec->qual[dgd_idx].pref_dt_tm = cnvtdatetime(d.pref_dt_tm),
       dgd_rec->qual[dgd_idx].pref_str = evaluate(ni1,1,"DM2NULLVAL",d.pref_str), dgd_rec->qual[
       dgd_idx].parent_entity_name = evaluate(ni2,1,"DM2NULLVAL",d.parent_entity_name), dgd_rec->
       qual[dgd_idx].parent_entity_id = d.parent_entity_id,
       dgd_rec->qual[dgd_idx].reference_ind = d.reference_ind
      WITH nocounter
     ;end select
     IF (check_error("Querying preferences from DM_PREFS") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dmd_idx = (dmd_rec->cnt+ 1)
     ENDIF
     IF (curqual=0)
      SET dgd_rec->qual[dgd_idx].no_row_ind = 1
     ENDIF
   ENDFOR
   RETURN(null)
 END ;Subroutine
 DECLARE drdc_wrap_menu_lines(dwml_str=vc,dwml_cur_row_pos=i4,dwml_cur_col_pos=i4,
  dwml_multi_line_buffer=vc,dwml_max_lines=i4,
  dwml_max_col=i4) = i4
 DECLARE drdc_get_name(dgn_name=vc,dgn_file=vc) = vc
 DECLARE drdc_file_success(dfs_name=vc,dfs_file_name=vc,dfs_error_ind=i2) = null
 IF ((validate(dclm_rs->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_rs
  RECORD dclm_rs(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_tier = i4
    1 del_row_ind = i2
    1 max_tier = i4
    1 num_procs = i4
    1 nomv_ind = i2
    1 mover_stale_ind = i2
    1 cycle_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 ctp_str = vc
    1 cts_str = vc
    1 group_ind = i2
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 reporting_cnt = i4
    1 reporting_qual[*]
      2 log_type = vc
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 non_ctxt_cnt = i4
    1 non_ctxt_qual[*]
      2 values = vc
  )
 ENDIF
 IF ((validate(dclm_all->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_all
  RECORD dclm_all(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 type_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 lt_cnt = i4
  )
 ENDIF
 IF ((validate(dclm_issues->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_issues
  RECORD dclm_issues(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 max_lines = i4
    1 cur_rs_pos = i4
    1 ctp_str = vc
    1 sort_flag = i4
    1 cur_flag = i4
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 lt_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 inv_ind = i2
      2 log_msg = vc
      2 child_type = vc
      2 log_type_sum = i4
      2 child_cnt_sum = i4
      2 tab_cnt = i4
      2 tab_qual[*]
        3 table_name = vc
        3 row_cnt = i4
  )
 ENDIF
 SUBROUTINE drdc_wrap_menu_lines(dwml_str,dwml_cur_row_pos,dwml_cur_col_pos,dwml_multi_line_buffer,
  dwml_max_lines,dwml_max_col)
   DECLARE dwml_temp_str = vc WITH protect, noconstant("")
   DECLARE dwml_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dwml_partial_str = vc WITH protect, noconstant("")
   DECLARE dwml_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dwml_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dwml_max_val = i4 WITH protect, noconstant(0)
   SET dwml_max_val = dwml_max_col
   IF (dwml_max_val=0)
    SET dwml_max_val = 132
   ENDIF
   SET dwml_temp_str = dwml_str
   SET dwml_done_ind = 0
   WHILE (dwml_done_ind=0)
     IF (size(dwml_temp_str) < dwml_max_val)
      SET dwml_partial_str = dwml_temp_str
      SET dwml_done_ind = 1
     ELSE
      SET dwml_partial_str = substring(1,value(dwml_max_val),dwml_temp_str)
      SET dwml_stop_pos = findstring(" ",dwml_partial_str,1,1)
      IF (dwml_stop_pos=0)
       SET dwml_stop_pos = dwml_max_val
      ENDIF
      SET dwml_partial_str = substring(1,dwml_stop_pos,dwml_temp_str)
      IF (dwml_multi_line_buffer >= " ")
       SET dwml_temp_str = concat(dwml_multi_line_buffer,substring((dwml_stop_pos+ 1),(size(
          dwml_temp_str) - dwml_stop_pos),dwml_temp_str))
      ELSE
       SET dwml_temp_str = substring((dwml_stop_pos+ 1),(size(dwml_temp_str) - dwml_stop_pos),
        dwml_temp_str)
      ENDIF
     ENDIF
     IF (((dwml_line_cnt+ 1)=dwml_max_lines)
      AND dwml_done_ind=0
      AND dwml_max_lines > 0)
      SET dwml_partial_str = concat(substring(1,(dwml_max_val - 3),dwml_partial_str),"...")
      SET dwml_done_ind = 1
     ENDIF
     CALL text(dwml_cur_row_pos,dwml_cur_col_pos,dwml_partial_str)
     SET dwml_cur_row_pos = (dwml_cur_row_pos+ 1)
     SET dwml_line_cnt = (dwml_line_cnt+ 1)
   ENDWHILE
   RETURN(dwml_cur_row_pos)
 END ;Subroutine
 SUBROUTINE drdc_get_name(dgn_name,dgn_file)
   SET dm_err->eproc = "Getting report file name"
   DECLARE dgn_file_name = vc WITH protect, noconstant("")
   DECLARE dgn_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgn_title = vc WITH protect, noconstant("")
   SET dgn_title = concat("*** ",dgn_name," ***")
   WHILE (dgn_done_ind=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgn_title)/ 2))),dgn_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgn_name,
       " report to extract into. (0 to exit): "))
     CALL accept(7,15,"P(30);CU",value(dgn_file))
     SET dgn_file_name = curaccept
     SET dgn_file_name = cnvtlower(dgn_file_name)
     IF (dgn_file_name="0")
      RETURN("-1")
      CALL text(20,3,"No extract will be made")
      CALL pause(3)
      SET dgn_done_ind = 1
     ENDIF
     IF (findstring(".",dgn_file_name)=0)
      SET dgn_file_name = concat(dgn_file_name,".csv")
      SET dgn_done_ind = 1
     ENDIF
     IF (substring(findstring(".",dgn_file_name),size(dgn_file_name,1),dgn_file_name) != ".csv")
      CALL text(20,3,"Invalid file type, file extension must be .csv")
      CALL pause(3)
     ELSE
      SET dgn_done_ind = 1
     ENDIF
   ENDWHILE
   RETURN(dgn_file_name)
 END ;Subroutine
 SUBROUTINE drdc_file_success(dfs_name,dfs_file_name,dfs_error_ind)
   DECLARE dfs_title = vc WITH protect, noconstant("")
   DECLARE dfs_pos = i4 WITH protect, noconstant(0)
   SET dfs_title = concat("*** ",dfs_name," ***")
   IF (dfs_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report complete!")
    CALL text(7,3,
     "For optimal viewing, the following file needs to be moved from CCLUSERDIR to a PC:")
    CALL text(8,3,"-----------------------------")
    CALL text(9,3,dfs_file_name)
    CALL text(10,3,"-----------------------------")
    CALL text(12,3,"Press enter to return:")
    CALL accept(12,26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report was not successful.  The following error occurred!")
    SET dfs_pos = drdc_wrap_menu_lines(dm_err->emsg,7,3,"   ",0,
     120)
    CALL text((dfs_pos+ 1),3,"Press enter to return:")
    CALL accept((dfs_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
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
 DECLARE drcm_get_imp_file(dgf_name=vc,dgf_file=vc,dgf_xtn=vc) = vc
 DECLARE drcm_check_context(dcc_ctxt_name=vc,dcc_null_allowed_ind=i2) = i2
 DECLARE drcm_file_complete(dfc_name=vc,dfc_files=vc(ref),dvc_type=vc,dfc_error_ind=i2) = null
 DECLARE check_error_gui(ceg_proc=vc,ceg_menu_screen=vc,ceg_env_name=vc,ceg_env_id=f8) = i4
 DECLARE drcm_dbase_connect(ddc_password=vc(ref),ddc_sid=vc(ref)) = i4
 DECLARE drcm_retry_connect(retry_reason=vc) = i4
 DECLARE drcm_check_user(null) = i2
 IF ((validate(drcm_files->cnt,- (2))=- (2)))
  FREE RECORD drcm_files
  RECORD drcm_files(
    1 cnt = i4
    1 qual[*]
      2 file_name = vc
  )
 ENDIF
 SUBROUTINE drcm_get_imp_file(dgf_name,dgf_file,dgf_xtn)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgf_file_name = vc WITH protect, noconstant("")
   DECLARE dgf_full_file = vc WITH protect, noconstant("")
   DECLARE dgf_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgf_valid_ind = i2 WITH protect, noconstant(1)
   DECLARE dgf_title = vc WITH protect, noconstant("")
   SET dgf_title = concat("*** ",dgf_name," ***")
   WHILE (dgf_done_ind=0)
     SET dgf_valid_ind = 1
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgf_name,
       " to be imported from (0 to exit): "))
     CALL text(9,3,concat("Example: myfilename",dgf_xtn))
     CALL text(10,3,concat("NOTE: File must be located in CCLUSERDIR "))
     SET accept = nopatcheck
     CALL accept(7,3,"P(30);CU",value(dgf_file))
     SET accept = patcheck
     SET dgf_file_name = curaccept
     SET dgf_file_name = cnvtlower(dgf_file_name)
     IF (dgf_file_name="0")
      RETURN("0")
     ENDIF
     IF (findstring(".",dgf_file_name)=0)
      SET dgf_file_name = concat(dgf_file_name,dgf_xtn)
     ELSEIF (substring(findstring(".",dgf_file_name),((size(dgf_file_name,1) - findstring(".",
       dgf_file_name))+ 1),dgf_file_name) != dgf_xtn)
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgf_xtn))
      CALL pause(3)
      SET dgf_valid_ind = 0
     ENDIF
     IF (size(dgf_file_name,1) >= 31)
      SET dgf_valid_ind = 0
     ENDIF
     IF (dgf_valid_ind=1)
      SET dgf_full_file = concat(trim(logical("CCLUSERDIR")),"/",dgf_file_name)
      IF (findfile(value(dgf_full_file))=0)
       SET message = window
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,4,132)
       CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
       CALL text(6,3,concat(dgf_file_name," could not be found in CCLLUSERDIR."))
       CALL text(7,3,"Please ensure file is located in CCLUSERDIR")
       CALL text(10,3,"Press enter to continue.")
       CALL accept(10,28,"P;E"," ")
      ELSE
       SET dgf_done_ind = 1
      ENDIF
      SET dgf_file_name = dgf_full_file
     ENDIF
   ENDWHILE
   RETURN(dgf_file_name)
 END ;Subroutine
 SUBROUTINE drcm_check_context(dcc_ctxt_name,dcc_null_allowed_ind)
   DECLARE dcc_valid_ind = i2 WITH protect, noconstant(0)
   IF (size(trim(dcc_ctxt_name),1) <= 24
    AND dcc_ctxt_name != "ALL"
    AND findstring(":",dcc_ctxt_name)=0
    AND size(trim(dcc_ctxt_name),1) > 0
    AND ((dcc_ctxt_name != "NULL"
    AND dcc_null_allowed_ind=0) OR (dcc_ctxt_name="NULL"
    AND dcc_null_allowed_ind=1)) )
    SET dcc_valid_ind = 1
   ELSE
    SET dcc_valid_ind = 0
   ENDIF
   RETURN(dcc_valid_ind)
 END ;Subroutine
 SUBROUTINE drcm_file_complete(dfc_name,dfc_files,dfc_type,dfc_num,dfc_error_ind,dfc_env_name,
  dfc_env_id)
   DECLARE dfc_title = vc WITH protect, noconstant("")
   DECLARE dfc_pos = i4 WITH protect, noconstant(0)
   DECLARE dfc_loop = i4 WITH protect, noconstant(0)
   DECLARE dfc_line = i4 WITH protect, noconstant(11)
   SET dfc_title = concat("*** ",dfc_name," ***")
   IF (dfc_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(4,75,"ENVIRONMENT ID:")
    CALL text(4,20,"ENVIRONMENT NAME:")
    CALL text(4,95,cnvtstring(dfc_env_id))
    CALL text(4,40,dfc_env_name)
    CALL text(7,3,concat(dfc_type," complete!"))
    IF (dfc_type="Export")
     CALL text(8,3,concat(trim(cnvtstring(dfc_num))," rows were exported"))
    ENDIF
    CALL text(9,3,
     "For optimal viewing, the following file(s) needs to be moved from CCLUSERDIR to a PC:")
    CALL text(10,3,"-----------------------------")
    FOR (dfc_loop = 1 TO dfc_files->cnt)
     CALL text(dfc_line,3,dfc_files->qual[dfc_loop].file_name)
     SET dfc_line = (dfc_line+ 1)
    ENDFOR
    CALL text(dfc_line,3,"-----------------------------")
    CALL text((dfc_line+ 2),3,"Press enter to return:")
    CALL accept((dfc_line+ 2),26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(7,3,concat(dfc_type," was not successful.  The following error occurred!"))
    SET dfc_pos = drdc_wrap_menu_lines(dm_err->emsg,8,3,"   ",0,
     120)
    CALL text((dfc_pos+ 1),3,"Press enter to return:")
    CALL accept((dfc_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE check_error_gui(ceg_proc,ceg_menu_screen,ceg_env_name,ceg_env_id)
   DECLARE ceg_error = i4 WITH protect, noconstant(0)
   DECLARE ceg_size = i4 WITH protect, noconstant(0)
   SET ceg_error = check_error(ceg_proc)
   IF (ceg_error != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,7,132)
    CALL text(3,floor(((66 - 5) - (size(ceg_menu_screen)/ 2))),concat("***  ",ceg_menu_screen,"  ***"
      ))
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,ceg_env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(ceg_env_id))
    SET ceg_size = size(dm_err->emsg)
    CALL text(9,3,trim(substring(1,125,dm_err->emsg)))
    IF (ceg_size > 125)
     CALL text(10,3,trim(substring(126,125,dm_err->emsg)))
    ENDIF
    CALL text(12,3,"Press ENTER to continue")
    CALL accept(12,28,"P;E"," ")
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE drcm_dbase_connect(ddc_password,ddc_sid)
   DECLARE dc_retry_ans = i2 WITH protect, noconstant(0)
   DECLARE dc_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_con_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_attempt_connection = i2 WITH protect, noconstant(0)
   DECLARE dc_ind = i2 WITH protect, noconstant(0)
   DECLARE dc_db_tab = vc WITH protect, noconstant(" ")
   SET dc_ind = dm2_get_rdbms_version(null)
   IF (dc_ind=0)
    RETURN(- (1))
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 12))
    SET dc_db_tab = "V$PDBS"
   ELSE
    SET dc_db_tab = "V$DATABASE"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dc_db_tab) db)
    DETAIL
     dc_db_name = db.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Get current database name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   WHILE (dc_attempt_connection=0)
     SET dm2_install_schema->dbase_name = dc_db_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = ""
     SET dm2_install_schema->connect_str = ""
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg="User quit process*"))
       SET retry_ans = drcm_retry_connect("Q")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       RETURN(- (1))
      ENDIF
     ELSE
      SET ddc_password = dm2_install_schema->p_word
      SET ddc_sid = dm2_install_schema->connect_str
      SELECT INTO "nl:"
       FROM (parser(dc_db_tab) db)
       DETAIL
        dc_con_db_name = db.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = "Get current database name"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (dc_db_name != dc_con_db_name)
       SET retry_ans = drcm_retry_connect("D")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       SET dc_attempt_connection = 1
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drcm_retry_connect(retry_reason)
   CALL clear(1,1)
   SET width = 132
   IF (retry_reason="D")
    CALL text(11,3,
     "   Database connect information provided for WRONG database.  Movers cannot be started.")
    CALL text(13,3,concat("     Menu started in database ",dc_db_name))
    CALL text(14,3,concat("     Connect information provided for database ",dc_con_db_name))
   ELSE
    CALL text(11,3,"   Unable to make database connection")
    CALL text(12,21,"   or")
    CALL text(13,3,"   Database connect information provided is incorrect.")
   ENDIF
   CALL text(20,3,"   Would you like to retry database connection? (Y/N)")
   CALL accept(20,59,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    RETURN(1)
   ELSE
    RETURN(2)
    CALL clear(1,1)
    SET width = 132
    CALL text(11,3,"   Please EXIT out of this CCL session and start a new one")
    CALL text(20,20,"Press ENTER to continue")
    CALL accept(20,60,"P;E"," ")
    SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
    CALL disp_msg(dm_err->err_msg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(2)
   ENDIF
 END ;Subroutine
 SUBROUTINE drcm_check_user(null)
   DECLARE dcu_ret = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND cnvtupper(p.username) IN ("SYSTEM", "SYSTEMOE", "CERNER")
    DETAIL
     dcu_ret = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(- (1))
   ENDIF
   RETURN(dcu_ret)
 END ;Subroutine
 DECLARE drla_validate_audit(dva_query=vc) = null
 DECLARE drla_store_audit(dsa_query=vc,dsa_audit_param=vc,dsa_reply=vc(ref),dsa_source=vc) = null
 SUBROUTINE PUBLIC::drla_store_audit(dsa_query,dsa_audit_param,dsa_reply,dsa_source)
   DECLARE dsa_table_name = vc WITH protect, noconstant(" ")
   DECLARE dsa_colon_pos = i4 WITH protect, noconstant(0)
   DECLARE dsa_addl_info = vc WITH protect, noconstant(" ")
   DECLARE dsa_pref_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsa_ltr_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsa_pref_name = vc WITH protect, noconstant(" ")
   IF (daf_is_not_blank(dsa_query))
    CALL drla_validate_audit(dsa_query)
    IF (check_error(concat("Issuing '",dsa_audit_param,"' query")) != 0)
     SET dsa_reply->audit_err_cnt = (dsa_reply->audit_err_cnt+ 1)
     SET stat = alterlist(dsa_reply->audit_err_qual,dsa_reply->audit_err_cnt)
     SET dsa_reply->audit_err_qual[dsa_reply->audit_err_cnt].audit_param = dsa_audit_param
     SET dsa_reply->audit_err_qual[dsa_reply->audit_err_cnt].audit_error = dm_err->emsg
     SET dm_err->emsg = " "
     SET dm_err->err_ind = 0
    ELSE
     SET dsa_colon_pos = findstring("::",dsa_audit_param,1,0)
     IF (dsa_colon_pos > 0)
      SET dsa_table_name = substring(1,(dsa_colon_pos - 1),dsa_audit_param)
      SET dsa_addl_info = substring((dsa_colon_pos+ 2),size(dsa_audit_param),dsa_audit_param)
      SET dsa_pref_name = concat(dsa_source,":",dsa_table_name,":",dsa_addl_info)
     ELSE
      SET dsa_table_name = dsa_audit_param
      SET dsa_addl_info = "DM2NULLVAL"
      SET dsa_pref_name = concat(dsa_source,":",dsa_table_name)
     ENDIF
     SET dsa_pref_id = 0.0
     SET dsa_ltr_id = 0.0
     SELECT
      IF (dsa_addl_info="DM2NULLVAL")
       FROM dm_prefs d
       WHERE d.application_nbr=0
        AND d.person_id=0.0
        AND d.pref_domain="RDDS AUDIT QUERY"
        AND d.pref_section=dsa_table_name
        AND d.pref_str = null
      ELSE
       FROM dm_prefs d
       WHERE d.application_nbr=0
        AND d.person_id=0.0
        AND d.pref_domain="RDDS AUDIT QUERY"
        AND d.pref_section=dsa_table_name
        AND d.pref_str=dsa_addl_info
      ENDIF
      INTO "NL"
      DETAIL
       dsa_pref_id = d.pref_id, dsa_ltr_id = d.parent_entity_id
      WITH nocounter
     ;end select
     IF (check_error("Querying DM_PREFS") != 0)
      RETURN(null)
     ENDIF
     IF (dsa_ltr_id=0.0)
      SELECT INTO "NL:"
       y = seq(long_data_seq,nextval)
       FROM dual d
       DETAIL
        dsa_ltr_id = y
       WITH nocounter
      ;end select
      IF (check_error("Popping from LONG_DATA_SEQ") != 0)
       RETURN(null)
      ENDIF
     ENDIF
     IF (dsa_pref_id=0.0)
      SELECT INTO "NL:"
       y = seq(dm_clinical_seq,nextval)
       FROM dual d
       DETAIL
        dsa_pref_id = y
       WITH nocounter
      ;end select
      IF (check_error("Popping from DM_CLINICAL_SEQ") != 0)
       RETURN(null)
      ENDIF
     ENDIF
     UPDATE  FROM dm_prefs d
      SET pref_name = dsa_pref_name, d.pref_dt_tm = cnvtdatetime(curdate,curtime3), d
       .parent_entity_id = dsa_ltr_id,
       d.parent_entity_name = "LONG_TEXT_REFERENCE", d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
       .updt_id = reqinfo->updt_id,
       d.updt_applctx = 0, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1)
      WHERE d.pref_id=dsa_pref_id
      WITH nocounter
     ;end update
     IF (check_error("Updating DM_PREFS") != 0)
      ROLLBACK
      RETURN(null)
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_prefs d
       SET pref_name = dsa_pref_name, d.pref_dt_tm = cnvtdatetime(curdate,curtime3), d
        .parent_entity_id = dsa_ltr_id,
        d.parent_entity_name = "LONG_TEXT_REFERENCE", d.reference_ind = 1, d.application_nbr = 0,
        d.person_id = 0.0, d.pref_nbr = 0, d.pref_cd = 0.0,
        d.pref_id = dsa_pref_id, d.pref_domain = "RDDS AUDIT QUERY", d.pref_section = dsa_table_name,
        d.pref_str = evaluate(dsa_addl_info,"DM2NULLVAL",null,dsa_addl_info), d.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
        d.updt_applctx = 0, d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (check_error("Inserting DM_PREFS") != 0)
       ROLLBACK
       RETURN(null)
      ENDIF
     ENDIF
     UPDATE  FROM long_text_reference l
      SET l.long_text = dsa_query, l.parent_entity_id = dsa_pref_id, l.parent_entity_name =
       "DM_PREFS",
       l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_applctx =
       0,
       l.updt_task = reqinfo->updt_task, l.updt_cnt = (l.updt_cnt+ 1)
      WHERE l.long_text_id=dsa_ltr_id
      WITH nocounter
     ;end update
     IF (check_error("Updating LONG_TEXT_REFERENCE") != 0)
      ROLLBACK
      RETURN(null)
     ENDIF
     IF (curqual=0)
      INSERT  FROM long_text_reference l
       SET l.long_text = dsa_query, l.parent_entity_id = dsa_pref_id, l.parent_entity_name =
        "DM_PREFS",
        l.long_text_id = dsa_ltr_id, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id =
        reqinfo->updt_id,
        l.updt_applctx = 0, l.updt_task = reqinfo->updt_task, l.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (check_error("Inserting LONG_TEXT_REFERENCE") != 0)
       ROLLBACK
       RETURN(null)
      ENDIF
     ENDIF
     COMMIT
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Incomplete audit data found for '",dla_data->qual[dla_idx].audit_param,
     "'")
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::drla_validate_audit(dva_query)
   DECLARE dva_temp_str = vc WITH protect, noconstant(" ")
   SET dva_temp_str = replace(replace(replace(replace(replace(dva_query,"<SELECT_TAG>",""),
       "<DB_LINK_TAG>",""),"<DOMAIN_FLAG>","^1^"),"<WITH_TAG>",""),"<FILE_NAME>","NL:")
   CALL parser(concat(dva_temp_str," go"),1)
   RETURN(null)
 END ;Subroutine
 IF (check_logfile("dm_rmc_rpt_aud",".log","dm_rmc_rpt_audits LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 DECLARE drra_main(null) = null
 DECLARE drra_audit_types(null) = null
 DECLARE drra_gather_context(dgc_req=vc(ref),exit_ind=i2(ref)) = null
 DECLARE drra_log_type(exit_ind=i2(ref)) = vc
 DECLARE drra_num_to_run(exit_ind=i2(ref)) = vc
 DECLARE drra_run_mode(exit_ind=i2(ref)) = i2
 DECLARE drra_mail_results(exit_ind=i2(ref)) = vc
 DECLARE drra_view_status(null) = null
 DECLARE drra_ptam_audit(dpa_req=vc(ref),dpa_run_mode=i2,dpa_email=vc,exit_ind=i2(ref)) = null
 DECLARE drra_src_audit(dsa_req=vc(ref),dsa_run_mode=i2,dsa_email=vc,exit_ind=i2(ref)) = null
 DECLARE drra_config_settings(null) = null
 DECLARE drra_config_max_row(null) = null
 DECLARE drra_upload_audits(null) = null
 DECLARE drra_remove_audit(null) = null
 DECLARE drra_disp_header(ddh_msg=vc,ddh_env_name=vc,ddh_env_id=f8) = null
 DECLARE drra_disp_audit_options(ddao_str=vc) = i4
 DECLARE drra_view_audit_query(dvaq_rec=vc(ref)) = null
 DECLARE drra_show_audit_upload_error(sau_reply=vc(ref)) = null
 DECLARE drra_view_upload_dynamic(dvud_store_rep=vc(ref)) = null
 DECLARE drra_view_query_menu(null) = null
 SET modify maxvarlen 268435456
 DECLARE drra_env_name = vc WITH protect, noconstant(" ")
 DECLARE drra_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drra_err_ind = i2 WITH protect, noconstant(0)
 FREE RECORD drrp_request
 RECORD drrp_request(
   1 table_name = vc
   1 ctxt_cnt = i4
   1 ctxt_qual[*]
     2 ctxt_name = vc
 )
 FREE RECORD drss_request
 RECORD drss_request(
   1 table_name = vc
   1 ctxt_cnt = i4
   1 ctxt_qual[*]
     2 ctxt_name = vc
   1 log_type = vc
 )
 CALL drrac_get_env(drra_env_name,drra_env_id)
 SET drra_error_ind = check_error_gui("Gathering environment information","Audit Reports Menu",
  drra_env_name,drra_env_id)
 IF (drra_error_ind=1)
  GO TO exit_menu
 ENDIF
 IF (((daf_is_blank(drra_env_name)) OR (drra_env_id=0.0)) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "No environment information found, please ensure the domain is setup correctly and try again."
  SET drra_error_ind = check_error_gui("Gathering environment information","Audit Reports Menu",
   drra_env_name,drra_env_id)
  GO TO exit_menu
 ENDIF
 CALL drra_main(null)
 SUBROUTINE drra_main(null)
   DECLARE dm_end = i2 WITH protect, noconstant(0)
   WHILE (dm_end=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Audit Reports Menu",drra_env_name,drra_env_id)
     CALL text(9,3,"1. Run Audit(s)")
     CALL text(10,3,"2. View Audit Status")
     CALL text(11,3,"3. Configure Audit Settings")
     CALL text(12,3,"4. Upload Audit Queries")
     CALL text(13,3,"5. Remove Audit Query")
     CALL text(14,3,"6. View Audit Query")
     CALL text(15,3,"0. Exit")
     CALL text(7,3,"Please choose from the following options:")
     CALL accept(7,50,"99",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      6, 0))
     CASE (curaccept)
      OF 1:
       CALL drra_audit_types(null)
      OF 2:
       CALL drra_view_status(null)
      OF 3:
       CALL drra_config_settings(null)
      OF 4:
       CALL drra_upload_audits(null)
      OF 5:
       CALL drra_remove_audit(null)
      OF 6:
       CALL drra_view_query_menu(null)
      OF 0:
       SET dm_end = 1
       CALL clear(1,1)
     ENDCASE
     IF ((dm_err->err_ind=1))
      SET dm_end = 1
     ENDIF
   ENDWHILE
   RETURN
 END ;Subroutine
 SUBROUTINE drra_disp_header(ddh_msg,ddh_env_name,ddh_env_id)
   CALL box(1,1,5,132)
   CALL text(3,floor((66 - (size(ddh_msg)/ 2))),ddh_msg)
   CALL text(4,75,"ENVIRONMENT ID:")
   CALL text(4,20,"ENVIRONMENT NAME:")
   CALL text(4,95,cnvtstring(ddh_env_id,20))
   CALL text(4,40,ddh_env_name)
   RETURN
 END ;Subroutine
 SUBROUTINE drra_audit_types(null)
   DECLARE dat_end = i2 WITH protect, noconstant(0)
   DECLARE dat_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dat_num_to_run = i2 WITH protect, noconstant(0)
   DECLARE dat_run_mode = i2 WITH protect, noconstant(0)
   DECLARE dat_email = vc WITH protect, noconstant(" ")
   DECLARE dat_option = i4 WITH protect, noconstant(0)
   DECLARE dat_audit_cnt = i4 WITH protect, noconstant(0)
   DECLARE dat_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dgc_req
   RECORD dgc_req(
     1 ctxt_cnt = i4
     1 ctxt_qual[*]
       2 ctxt_name = vc
   )
   IF (dgi_get_global_info(drgi_global)=1)
    SET dat_error_ind = check_error_gui("Gathering Environment information","Run Audit Menu",
     drra_env_name,drra_env_id)
    SET dat_end = 1
   ELSE
    IF ((drgi_global->oe_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Error: No open event detected."
     SET dat_error_ind = check_error_gui("Gathering Environment information","Run Audit Menu",
      drra_env_name,drra_env_id)
     SET dat_end = 1
    ELSEIF (daf_is_blank(drgi_global->db_link))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Error: Unable to determine database link."
     SET dat_error_ind = check_error_gui("Gathering Environment information","Run Audit Menu",
      drra_env_name,drra_env_id)
     SET dat_end = 1
    ENDIF
   ENDIF
   WHILE (dat_end=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Run Audit Menu",drra_env_name,drra_env_id)
     SET dat_audit_cnt = drrac_get_audit_cnt("*")
     SET dat_error_ind = check_error_gui("Querying Audit Count","Run Audit Menu",drra_env_name,
      drra_env_id)
     IF (dat_error_ind=1)
      SET dat_end = 1
     ENDIF
     SET dat_option = drra_disp_audit_options("Please choose from the following options:")
     IF (dat_audit_cnt=0)
      SET stat = initrec(drpc_dmprefs)
      SET drpc_dmprefs->cnt = 1
      SET stat = alterlist(drpc_dmprefs->qual,drpc_dmprefs->cnt)
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_domain = "RDDS AUDIT CONFIG"
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_section = "AUTO-GEN AUDIT"
      IF (dat_option=1)
       SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_name = "PTAM"
      ELSEIF (dat_option=2)
       SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_name = "SOURCE ONLY AUDIT"
      ENDIF
      CALL drpc_get_dmprefs(drpc_dmprefs)
      SET dat_error_ind = check_error_gui("Checking Auto Generate Preference","Run Audit Menu",
       drra_env_name,drra_env_id)
      IF (dat_error_ind != 0)
       RETURN(null)
      ENDIF
      IF ((drpc_dmprefs->qual[drpc_dmprefs->cnt].no_row_ind=1))
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL drra_disp_header("Upload Audits Menu",drra_env_name,drra_env_id)
       CALL text(7,3,"There are no audit queries loaded into the system. ")
       CALL text(8,3,"Do you want the system to auto generate any required audit queries? (Y/N)")
       CALL accept(8,77,"P;CU","N"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="N")
        SET dat_end = 1
        CALL clear(1,1)
       ELSE
        CALL clear(1,1)
        SET message = window
        SET width = 132
        CALL drra_disp_header("Run Audit Menu",drra_env_name,drra_env_id)
        SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_nbr = 1
        CALL drpc_manage_dmprefs(drpc_dmprefs)
        SET dcag_error_ind = check_error_gui("Adding Auto Gen Preference","Run Audit Menu",
         drra_env_name,drra_env_id)
        IF (dcag_error_ind != 0)
         SET dat_end = 1
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ELSEIF ((drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_nbr=0))
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL drra_disp_header("Upload Audits Menu",drra_env_name,drra_env_id)
       CALL text(7,3,concat("There are no audit queries loaded into the system.  ",
         "Please choose the 'Upload Audit Queries' option (4),"))
       CALL text(8,5,
        " or 'Configure Audit Settings (3) and configure the system to auto generate the queries.")
       CALL text(9,3,"Press enter to continue...")
       CALL accept(9,30,"P;E"," ")
       SET dat_end = 1
      ENDIF
     ENDIF
     IF (dat_end=0)
      CASE (dat_option)
       OF 1:
        IF (dat_error_ind=0)
         SET stat = initrec(drrp_request)
         SET stat = initrec(dgc_req)
         SET dat_ind = 0
         CALL drra_gather_context(dgc_req,dat_ind)
         IF (dat_ind=0)
          SET stat = moverec(dgc_req->ctxt_qual,drrp_request->ctxt_qual)
          SET drrp_request->ctxt_cnt = size(drrp_request->ctxt_qual,5)
          SET drrp_request->table_name = drra_num_to_run(dat_ind)
          IF (daf_is_not_blank(drrp_request->table_name)
           AND dat_ind=0)
           SET dat_run_mode = drra_run_mode(dat_ind)
           IF (dat_run_mode=1
            AND dat_ind=0)
            SET dat_email = drra_mail_results(dat_ind)
           ENDIF
          ENDIF
          CALL drra_ptam_audit(drrp_request,dat_run_mode,dat_email,dat_ind)
          SET dat_end = 1
         ENDIF
        ENDIF
       OF 2:
        IF (dat_error_ind=0)
         SET stat = initrec(drss_request)
         SET stat = initrec(dgc_req)
         SET dat_ind = 0
         CALL drra_gather_context(dgc_req,dat_ind)
         IF (dat_ind=0)
          SET stat = moverec(dgc_req->ctxt_qual,drss_request->ctxt_qual)
          SET drss_request->ctxt_cnt = size(drss_request->ctxt_qual,5)
          SET drss_request->log_type = drra_log_type(dat_ind)
          IF (dat_ind=0)
           SET drss_request->table_name = drra_num_to_run(dat_ind)
           IF (daf_is_not_blank(drss_request->table_name)
            AND dat_ind=0)
            SET dat_run_mode = drra_run_mode(dat_ind)
            IF (dat_run_mode=1
             AND dat_ind=0)
             SET dat_email = drra_mail_results(dat_ind)
            ENDIF
           ENDIF
          ENDIF
          CALL drra_src_audit(drss_request,dat_run_mode,dat_email,dat_ind)
          SET dat_end = 1
         ENDIF
        ENDIF
       OF 0:
        SET dat_end = 1
      ENDCASE
     ENDIF
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_gather_context(dgc_rs,exit_ind)
   DECLARE dgc_ctxt_list = vc WITH protect, noconstant(" ")
   DECLARE dgc_ctxt_value = vc WITH protect, noconstant(" ")
   DECLARE dgc_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dgc_breakup_ret = vc WITH protect, noconstant(" ")
   DECLARE dgc_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgc_delim_char_num = i4 WITH protect, noconstant(0)
   DECLARE dgc_ctxt_piece = vc WITH protect, noconstant(" ")
   DECLARE dgc_idx = i4 WITH protect, noconstant(1)
   FREE RECORD dgc_ctxt
   RECORD dgc_ctxt(
     1 cnt = i4
     1 qual[*]
       2 value = c24
   )
   SET dgc_ctxt_list = drgi_global->ctp_value
   SET dgc_error_ind = check_error_gui("Gathering CONTEXTS TO PULL value","Gather Contexts Menu",
    drra_env_name,drra_env_id)
   IF (dgc_error_ind=1)
    RETURN(null)
   ENDIF
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("Gather Contexts Menu",drra_env_name,drra_env_id)
   IF (daf_is_not_blank(dgc_ctxt_list)
    AND dgc_ctxt_list != "ALL")
    SET dgc_delim_char_num = 47
    WHILE (dgc_done_ind=0
     AND dgc_delim_char_num < 127)
      IF (findstring(char(dgc_delim_char_num),dgc_ctxt_list,1,0) > 0)
       SET dgc_delim_char_num = (dgc_delim_char_num+ 1)
      ELSE
       SET dgc_done_ind = 1
      ENDIF
    ENDWHILE
    IF (dgc_done_ind=1)
     SET dgc_ctxt_list = replace(dgc_ctxt_list,"::",char(dgc_delim_char_num),0)
     SET dgc_done_ind = 0
     WHILE (dgc_done_ind=0)
      SET dgc_ctxt_piece = piece(dgc_ctxt_list,char(dgc_delim_char_num),dgc_idx,"NORDDSDELIMEXISTS")
      IF (dgc_ctxt_piece="NORDDSDELIMEXISTS")
       IF ((dgc_ctxt->cnt=0))
        SET dgc_ctxt->cnt = (dgc_ctxt->cnt+ 1)
        SET stat = alterlist(dgc_ctxt->qual,dgc_ctxt->cnt)
        SET dgc_ctxt->qual[dgc_ctxt->cnt].value = dgc_ctxt_list
       ENDIF
       SET dgc_done_ind = 1
      ELSE
       SET dgc_ctxt->cnt = (dgc_ctxt->cnt+ 1)
       SET stat = alterlist(dgc_ctxt->qual,dgc_ctxt->cnt)
       SET dgc_ctxt->qual[dgc_ctxt->cnt].value = dgc_ctxt_piece
       SET dgc_idx = (dgc_idx+ 1)
      ENDIF
     ENDWHILE
    ENDIF
    SET dgc_done_ind = 0
   ENDIF
   SET dgc_ctxt->cnt = (dgc_ctxt->cnt+ 1)
   SET stat = alterlist(dgc_ctxt->qual,dgc_ctxt->cnt)
   SET dgc_ctxt->qual[dgc_ctxt->cnt].value = "ALL"
   SET help =
   SELECT INTO "NL:"
    context_name = dgc_ctxt->qual[d.seq].value
    FROM (dummyt d  WITH seq = dgc_ctxt->cnt)
    WITH nocounter
   ;end select
   CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
   SET dgc_ctxt_list = " "
   WHILE (dgc_done_ind=0)
     CALL text(7,3,"Enter the context name you want to audit: ")
     CALL text(8,3,"Enter blank string to continue or type 'EXIT' to exit ")
     CALL text(10,3,"Entering no context names, or typing ALL, will report on ")
     CALL text(11,3,"all context names and not perform any filtering.")
     CALL accept(7,44,"P(24);CU"," ")
     SET dgc_ctxt_value = curaccept
     IF (daf_is_blank(dgc_ctxt_value))
      SET dgc_done_ind = 1
     ELSE
      IF (dgc_ctxt_value="ALL")
       SET dgc_rs->ctxt_cnt = 0
       SET stat = alterlist(dgc_rs->ctxt_qual,0)
       SET dgc_done_ind = 1
      ELSEIF (dgc_ctxt_value="EXIT")
       SET exit_ind = 1
       SET dgc_done_ind = 1
       SET dgc_ctxt_value = " "
      ELSE
       SET dgc_rs->ctxt_cnt = (dgc_rs->ctxt_cnt+ 1)
       SET stat = alterlist(dgc_rs->ctxt_qual,dgc_rs->ctxt_cnt)
       SET dgc_rs->ctxt_qual[dgc_rs->ctxt_cnt].ctxt_name = dgc_ctxt_value
       IF (daf_is_blank(dgc_ctxt_list))
        SET dgc_ctxt_list = dgc_ctxt_value
       ELSE
        SET dgc_ctxt_list = concat(dgc_ctxt_list,", ",dgc_ctxt_value)
       ENDIF
       CALL text(13,3,"The current list of contexts selected is:")
       CALL text(14,5,dgc_ctxt_list)
      ENDIF
     ENDIF
   ENDWHILE
   SET help = off
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_log_type(exit_ind)
   DECLARE drlt_while_ind = i2 WITH protect, noconstant(0)
   DECLARE drlt_log_type = vc WITH protect, noconstant(" ")
   WHILE (drlt_while_ind=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Gather Log Type Menu",drra_env_name,drra_env_id)
     CALL text(8,3,"Enter the log type you want to audit or type 'EXIT' to exit: ")
     CALL accept(8,63,"P(6);CU"," ")
     SET drlt_log_type = curaccept
     IF (drlt_log_type="EXIT")
      SET exit_ind = 1
      SET drlt_while_ind = 1
     ELSEIF (textlen(trim(drlt_log_type,3)) < 6)
      SET drlt_while_ind = 0
      CALL text(23,58,"Invalid Entry")
      CALL pause(2)
     ELSE
      SET drlt_while_ind = 1
     ENDIF
   ENDWHILE
   RETURN(drlt_log_type)
 END ;Subroutine
 SUBROUTINE drra_num_to_run(exit_ind)
   DECLARE dntr_ret_val = vc WITH protect, noconstant(" ")
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("Table Selection Menu",drra_env_name,drra_env_id)
   CALL text(7,3,"Would you like to audit [A]ll tables or a [S]ingle table or e[X]it? (A/S/X):")
   CALL accept(7,84,"P;CU","A"
    WHERE curaccept IN ("A", "S", "X"))
   IF (curaccept="A")
    SET dntr_ret_val = " "
   ELSEIF (curaccept="X")
    SET exit_ind = 1
   ELSE
    CALL text(11,3,"Select the table you would like to audit?")
    SET help =
    SELECT DISTINCT INTO "NL:"
     substring(1,30,d.pref_section)
     FROM dm_prefs d
     WHERE d.application_nbr=0
      AND d.person_id=0.0
      AND d.pref_domain="RDDS AUDIT QUERY"
     WITH nocounter
    ;end select
    CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
    CALL accept(11,45,"P(30);CU")
    SET dntr_ret_val = curaccept
   ENDIF
   SET help = off
   RETURN(dntr_ret_val)
 END ;Subroutine
 SUBROUTINE drra_run_mode(exit_ind)
   DECLARE drm_ret_val = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("Run Mode Menu",drra_env_name,drra_env_id)
   CALL text(7,3,
    "Would you like to run the audit [I]nteractively or as a [B]ackground process or e[X]it? (I/B/X):"
    )
   CALL accept(7,104,"P;CU","B"
    WHERE curaccept IN ("I", "B", "X"))
   IF (curaccept="I")
    SET drm_ret_val = 1
   ELSEIF (curaccept="X")
    SET exit_ind = 1
   ELSE
    SET drm_ret_val = 0
   ENDIF
   RETURN(drm_ret_val)
 END ;Subroutine
 SUBROUTINE drra_mail_results(exit_ind)
   DECLARE dmr_email = vc WITH protect, noconstant(" ")
   DECLARE dmr_end = i2 WITH protect, noconstant(0)
   WHILE (dmr_end=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Mail Results Menu",drra_env_name,drra_env_id)
     CALL text(7,3,
      "Would you like to receive the results of the audit via e-mail? (Y)es/(N)o/e(X)it: ")
     CALL accept(7,85,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     IF (curaccept="Y")
      CALL text(9,3,"Please input the e-mail address to send the result(s) to:")
      CALL accept(9,61,"P(50);CU")
      SET dmr_email = curaccept
      IF (((daf_is_blank(dmr_email)) OR (findstring("@",dmr_email)=0)) )
       CALL text(20,3,"Invalid Input.  Email must not be blank, and must have @ symbol in it.")
       CALL pause(3)
       SET dmr_email = " "
      ELSE
       SET dmr_end = 1
      ENDIF
     ELSEIF (curaccept="X")
      SET exit_ind = 1
      SET dmr_end = 1
     ELSE
      SET dmr_end = 1
     ENDIF
   ENDWHILE
   RETURN(dmr_email)
 END ;Subroutine
 SUBROUTINE drra_ptam_audit(dpa_req,dpa_run_mode,dpa_email,exit_ind)
  IF (exit_ind=0)
   DECLARE dpa_run_text = vc WITH protect, noconstant(evaluate(dpa_run_mode,1,"Interactively",0,
     "Background"))
   DECLARE dpa_num_text = vc WITH protect, noconstant(" ")
   DECLARE dpa_ctxt_list = vc WITH protect, noconstant(" ")
   DECLARE dpa_ctxt_idx = i4 WITH protect, noconstant(0)
   DECLARE dpa_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dpa_msg = vc WITH protect, noconstant(" ")
   IF ((dpa_req->ctxt_cnt > 0))
    FOR (dpa_ctxt_idx = 1 TO dpa_req->ctxt_cnt)
      IF (dpa_ctxt_idx=1)
       SET dpa_ctxt_list = dpa_req->ctxt_qual[dpa_ctxt_idx].ctxt_name
      ELSE
       SET dpa_ctxt_list = concat(dpa_ctxt_list,", ",dpa_req->ctxt_qual[dpa_ctxt_idx].ctxt_name)
      ENDIF
    ENDFOR
   ELSE
    SET dpa_ctxt_list = "All Contexts Audited"
   ENDIF
   IF (daf_is_blank(dpa_req->table_name))
    SET dpa_num_text = "All Tables"
   ELSE
    SET dpa_num_text = dpa_req->table_name
   ENDIF
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("PTAM Audit Menu",drra_env_name,drra_env_id)
   CALL text(7,3,"Do you want to start the below audit? (Y/N)")
   CALL text(9,3,concat("Audit Run Method: ",dpa_run_text))
   CALL text(10,3,concat("Table(s) being audited: ",dpa_num_text))
   CALL text(11,3,concat("Context(s) being audited: ",dpa_ctxt_list))
   IF (daf_is_not_blank(dpa_email))
    CALL text(12,3,concat("Audit results sent to: ",dpa_email))
   ENDIF
   CALL accept(7,51,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    IF (daf_is_not_blank(dpa_email))
     DECLARE drrp_email = vc WITH protect, noconstant(dpa_email)
    ENDIF
    IF (dpa_run_mode=1)
     SET message = nowindow
     FREE RECORD drrp_reply
     RECORD drrp_reply(
       1 status = c1
       1 status_msg = vc
     )
     EXECUTE dm_rmc_rpt_ptam
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL drra_disp_header("PTAM Audit Menu",drra_env_name,drra_env_id)
     SET dpa_error_ind = check_error_gui("Executing PTAM Audit","Execute PTAM Audit",drra_env_name,
      drra_env_id)
     IF (dpa_error_ind=0)
      CALL text(7,3,drrp_reply->status_msg)
      CALL text(8,3,"Press enter to continue...")
      CALL accept(8,30,"P;E"," ")
     ENDIF
    ELSE
     IF ((dm_err->debug_flag > 0))
      SET message = nowindow
     ENDIF
     EXECUTE dm_rmc_rpt_ptam_setup  WITH replace("DRRPS_REQUEST","DPA_REQ")
     IF ((dm_err->debug_flag > 0))
      SET message = window
     ENDIF
     SET dpa_error_ind = check_error_gui("Loading Audit tasks","Execute PTAM Audit",drra_env_name,
      drra_env_id)
     IF (dpa_error_ind=0)
      EXECUTE dm_rmc_start_process_wrp "RDDS PTAM AUDIT"
      SET dpa_error_ind = check_error_gui("Starting background processes for audits",
       "Execute PTAM Audit",drra_env_name,drra_env_id)
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_src_audit(dsa_req,dsa_run_mode,dsa_email,exit_ind)
  IF (exit_ind=0)
   DECLARE dsa_run_text = vc WITH protect, noconstant(evaluate(dsa_run_mode,1,"Interactively",0,
     "Background"))
   DECLARE dsa_num_text = vc WITH protect, noconstant(" ")
   DECLARE dsa_ctxt_list = vc WITH protect, noconstant(" ")
   DECLARE dsa_log_type = vc WITH protect, noconstant(" ")
   DECLARE dsa_ctxt_idx = i4 WITH protect, noconstant(0)
   DECLARE dsa_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dsa_msg = vc WITH protect, noconstant(" ")
   IF ((dsa_req->ctxt_cnt > 0))
    FOR (dsa_ctxt_idx = 1 TO dsa_req->ctxt_cnt)
      IF (dsa_ctxt_idx=1)
       SET dsa_ctxt_list = dsa_req->ctxt_qual[dsa_ctxt_idx].ctxt_name
      ELSE
       SET dsa_ctxt_list = concat(dsa_ctxt_list,", ",dsa_req->ctxt_qual[dsa_ctxt_idx].ctxt_name)
      ENDIF
    ENDFOR
   ELSE
    SET dsa_ctxt_list = "All Contexts Audited"
   ENDIF
   SET dsa_log_type = dsa_req->log_type
   IF (daf_is_blank(dsa_req->table_name))
    SET dsa_num_text = "All Tables"
   ELSE
    SET dsa_num_text = dsa_req->table_name
   ENDIF
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("Source Only Audit Menu",drra_env_name,drra_env_id)
   CALL text(7,3,"Do you want to start the below audit? (Y/N)")
   CALL text(9,3,concat("Audit Run Method: ",dsa_run_text))
   CALL text(10,3,concat("Table(s) being audited: ",dsa_num_text))
   CALL text(11,3,concat("Context(s) being audited: ",dsa_ctxt_list))
   CALL text(12,3,concat("Log type being audited: ",dsa_log_type))
   IF (daf_is_not_blank(dsa_email))
    CALL text(13,3,concat("Audit results sent to: ",dsa_email))
   ENDIF
   CALL accept(7,51,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    IF (daf_is_not_blank(dsa_email))
     DECLARE drrs_email = vc WITH protect, noconstant(dsa_email)
    ENDIF
    IF (dsa_run_mode=1)
     SET message = nowindow
     FREE RECORD drss_reply
     RECORD drss_reply(
       1 status = c1
       1 status_msg = vc
     )
     EXECUTE dm_rmc_rpt_src
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL drra_disp_header("Source only audit Menu",drra_env_name,drra_env_id)
     SET dsa_error_ind = check_error_gui("Executing SOURCE ONLY AUDIT","Source Only Audit Menu",
      drra_env_name,drra_env_id)
     IF (dsa_error_ind=0)
      CALL text(7,3,drss_reply->status_msg)
      CALL text(8,3,"Press enter to continue...")
      CALL accept(8,30,"P;E"," ")
     ENDIF
    ELSE
     IF ((dm_err->debug_flag > 0))
      SET message = nowindow
     ENDIF
     EXECUTE dm_rmc_rpt_src_setup  WITH replace("DRRS_REQUEST","DSA_REQ")
     IF ((dm_err->debug_flag > 0))
      SET message = window
     ENDIF
     SET dsa_error_ind = check_error_gui("Loading Audit tasks","Execute Source only audit",
      drra_env_name,drra_env_id)
     IF (dsa_error_ind=0)
      EXECUTE dm_rmc_start_process_wrp "RDDS SRC AUDIT"
      SET dsa_error_ind = check_error_gui("Starting background processes for audits",
       "Source only audit",drra_env_name,drra_env_id)
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_view_status(null)
   DECLARE dvs_end = i2 WITH protect, noconstant(0)
   DECLARE dvs_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dvs_option = i4 WITH protect, noconstant(0)
   WHILE (dvs_end=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("View Status Menu",drra_env_name,drra_env_id)
     SET dvs_option = drra_disp_audit_options("Please choose from the following options:")
     CASE (dvs_option)
      OF 1:
       EXECUTE dm_rmc_task_mon "RDDS PTAM AUDIT"
       SET dvs_error_ind = check_error_gui("Viewing status for audits","View Status Menu",
        drra_env_name,drra_env_id)
       IF (dvs_error_ind=1)
        SET dvs_end = 1
       ENDIF
      OF 2:
       EXECUTE dm_rmc_task_mon "RDDS SRC AUDIT"
       SET dvs_error_ind = check_error_gui("Viewing status for audits","View Status Menu",
        drra_env_name,drra_env_id)
       IF (dvs_error_ind=1)
        SET dvs_end = 1
       ENDIF
      OF 0:
       SET dvs_end = 1
       CALL clear(1,1)
     ENDCASE
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_config_settings(null)
   DECLARE dcs_end = i2 WITH protect, noconstant(0)
   DECLARE dcs_error_ind = i2 WITH protect, noconstant(0)
   WHILE (dcs_end=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Configure Settings Menu",drra_env_name,drra_env_id)
     CALL text(9,3,"1. Audit Row Limit")
     CALL text(10,3,"2. Automatically generate query when absent")
     CALL text(11,3,"0. Exit")
     CALL text(7,3,"Please choose from the following options:")
     CALL accept(7,45,"99",0
      WHERE curaccept IN (1, 2, 0))
     CASE (curaccept)
      OF 1:
       CALL drra_config_max_row(null)
       IF ((dm_err->err_ind=1))
        SET dcs_end = 1
       ENDIF
      OF 2:
       CALL drra_config_auto_gen(null)
       IF ((dm_err->err_ind=1))
        SET dcs_end = 1
       ENDIF
      OF 0:
       SET dcs_end = 1
     ENDCASE
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_upload_audits(null)
   DECLARE dua_error_idx = i4 WITH protect, noconstant(0)
   DECLARE dua_ret = i4 WITH protect, noconstant(0)
   DECLARE dua_loop = i4 WITH protect, noconstant(0)
   FREE RECORD dua_request
   RECORD dua_request(
     1 audit_prog = vc
   )
   FREE RECORD dua_reply
   RECORD dua_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 audit_err_cnt = i4
     1 audit_err_qual[*]
       2 audit_param = vc
       2 audit_error = vc
   )
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("Upload Audits Menu",drra_env_name,drra_env_id)
   CALL text(7,3,"Please choose how you would like to upload queries.")
   CALL text(9,3,"1. Upload audits from program")
   CALL text(10,3,"2. Dynamically generate audits for table")
   CALL text(11,3,"0. Exit")
   CALL accept(7,55,"99",0
    WHERE curaccept IN (1, 2, 0))
   SET dua_ret = curaccept
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("Upload Audits Menu",drra_env_name,drra_env_id)
   CASE (dua_ret)
    OF 1:
     CALL text(7,3,"Input the name of the compiled program you wish to upload queries from: ")
     CALL accept(7,76,"P(40);CU")
     SET dua_request->audit_prog = curaccept
     IF (daf_is_not_blank(dua_request->audit_prog))
      SET message = nowindow
      EXECUTE dm_rmc_rpt_load_audits  WITH replace("DRRLA_REQUEST","DUA_REQUEST"), replace(
       "DRRLA_REPLY","DUA_REPLY")
      CALL clear(1,1)
      SET message = window
      SET width = 132
      CALL drra_disp_header("Upload Audits Menu",drra_env_name,drra_env_id)
      IF ((dua_reply->status_data.status="S"))
       CALL text(10,3,"All Audits were successfully uploaded. Press enter to continue")
       CALL accept(10,66,"P;E"," ")
      ELSE
       CALL drra_show_audit_upload_error(dua_reply)
      ENDIF
     ENDIF
    OF 2:
     CALL drra_view_upload_dynamic(dua_reply)
   ENDCASE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_remove_audit(null)
   DECLARE dra_table_name = vc WITH protect, noconstant(" ")
   DECLARE dra_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dra_done_flag = i4 WITH protect, noconstant(0)
   WHILE (dra_done_flag=0)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Remove Audit Menu",drra_env_name,drra_env_id)
     CALL text(7,3,"Would you like to remove audits for [A]ll tables or a [S]ingle table? (A/S)")
     CALL accept(7,79,"P;CU","S"
      WHERE curaccept IN ("A", "S"))
     IF (curaccept="A")
      SET dra_table_name = "ALL TABLES"
      SET dra_done_flag = 1
     ELSE
      CALL text(9,3,"Select the table you would like to remove audits for?")
      SET help = pos(8,90,15,38)
      SET help =
      SELECT DISTINCT
       table_name = d.pref_section
       FROM dm_prefs d
       WHERE d.application_nbr=0
        AND d.person_id=0.0
        AND ((d.pref_domain="RDDS AUDIT QUERY") UNION (
       (SELECT
        "<EXIT PROMPT>"
        FROM dual)))
       ORDER BY 1
       WITH nocounter
      ;end select
      CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
      CALL accept(9,45,"P(30);CU")
      SET dra_table_name = curaccept
      IF (dra_table_name="<EXIT PROMPT>")
       SET dra_done_flag = 1
      ELSE
       SET dra_done_flag = drrac_get_audit_cnt(dra_table_name)
       SET dra_error_ind = check_error_gui("Query for Audit","Remove Audit Menu",drra_env_name,
        drra_env_id)
       IF (dra_error_ind=1)
        SET dra_done_flag = 1
       ENDIF
      ENDIF
     ENDIF
     SET help = off
     IF (dra_done_flag=0)
      CALL text(20,3,"Invalid Input.")
      CALL pause(3)
     ENDIF
   ENDWHILE
   IF (dra_error_ind=0)
    IF (dra_table_name != "<EXIT PROMPT>")
     CALL text(11,3,
      "Are you sure you want to remove audit information for the criteria listed below (Y/N): ")
     CALL text(12,3,dra_table_name)
     CALL accept(11,91,"P;CU","N"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      CALL drrac_del_audits(dra_table_name)
      SET dra_error_ind = check_error_gui("Removing Audit Information","Remove Audit Menu",
       drra_env_name,drra_env_id)
      IF (dra_error_ind=0)
       COMMIT
       CALL text(14,3,"The audit information was successfully removed. Press enter to continue.")
       CALL text(21,3,"Press Enter to continue...")
       CALL accept(21,30,"P;E"," ")
      ELSE
       ROLLBACK
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_config_max_row(null)
   DECLARE dcmr_end = i2 WITH protect, noconstant(0)
   DECLARE dcmr_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dcmr_pref_name = vc WITH protect, noconstant(" ")
   DECLARE dcmr_pref_num = i4 WITH protect, noconstant(0)
   DECLARE dcmr_prompt_str = vc WITH protect, noconstant(" ")
   DECLARE dcmr_cur_pref = i4 WITH protect, noconstant(0)
   DECLARE dcmr_option = i4 WITH protect, noconstant(0)
   WHILE (dcmr_end=0)
     SET stat = initrec(drpc_dmprefs)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Audit Row Limit Menu",drra_env_name,drra_env_id)
     SET dcmr_option = drra_disp_audit_options(
      "Please choose the audit you would like to set the limit for:")
     CASE (dcmr_option)
      OF 1:
       SET dcmr_pref_name = "PTAM"
      OF 2:
       SET dcmr_pref_name = "SOURCE ONLY AUDIT"
      OF 0:
       SET dcmr_end = 1
     ENDCASE
     IF (dcmr_end != 1)
      SET drpc_dmprefs->cnt = 1
      SET stat = alterlist(drpc_dmprefs->qual,drpc_dmprefs->cnt)
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_domain = "RDDS AUDIT CONFIG"
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_section = "MAX ROW LIMIT"
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_name = dcmr_pref_name
      CALL drpc_get_dmprefs(drpc_dmprefs)
      SET dcmr_error_ind = check_error_gui("Managing Audit Row Limit","Audit Row Limit Menu",
       drra_env_name,drra_env_id)
      IF (dcmr_error_ind=0)
       IF ((drpc_dmprefs->qual[drpc_dmprefs->cnt].no_row_ind=1))
        SET dcmr_cur_pref = 10000
       ELSE
        SET dcmr_cur_pref = drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_nbr
       ENDIF
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL drra_disp_header("Audit Row Limit Menu",drra_env_name,drra_env_id)
       SET dcmr_prompt_str = concat("What row limit would you like to set for the ",dcmr_pref_name,
        " audit")
       CALL text(7,3,dcmr_prompt_str)
       CALL text(9,3,"Enter 0 to remove setting and use system default. (10000 default)")
       CALL text(10,3,concat("The current setting is ",trim(cnvtstring(dcmr_cur_pref))))
       CALL accept(7,(size(dcmr_prompt_str)+ 4),"9(5)")
       SET dcmr_pref_num = curaccept
       IF (dcmr_pref_num=0)
        SET drpc_dmprefs->qual[drpc_dmprefs->cnt].delete_ind = 1
       ELSE
        SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_nbr = dcmr_pref_num
       ENDIF
       CALL drpc_manage_dmprefs(drpc_dmprefs)
       SET dcmr_error_ind = check_error_gui("Managing Audit Row Limit","Audit Row Limit Menu",
        drra_env_name,drra_env_id)
       IF (dcmr_error_ind=0)
        COMMIT
        IF (dcmr_pref_num=0)
         CALL text(13,3,"The setting was successfully removed. Press enter to continue.")
        ELSE
         CALL text(13,3,"The setting was successfully updated. Press enter to continue.")
        ENDIF
        CALL text(21,3,"Press Enter to continue...")
        CALL accept(21,30,"P;E"," ")
       ELSE
        ROLLBACK
       ENDIF
      ENDIF
      SET dcmr_end = 1
     ENDIF
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_config_auto_gen(null)
   DECLARE dcag_end = i2 WITH protect, noconstant(0)
   DECLARE dcag_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dcag_pref_name = vc WITH protect, noconstant(" ")
   DECLARE dcag_pref_char = vc WITH protect, noconstant(" ")
   DECLARE dcag_prompt_str = vc WITH protect, noconstant(" ")
   DECLARE dcag_cur_pref = i4 WITH protect, noconstant(0)
   DECLARE dcag_option = i4 WITH protect, noconstant(0)
   DECLARE dcag_pref_mean = vc WITH protect, noconstant(" ")
   WHILE (dcag_end=0)
     SET stat = initrec(drpc_dmprefs)
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("Automatically Generate Audit Queries Menu",drra_env_name,drra_env_id)
     SET dcag_option = drra_disp_audit_options(
      "Please choose the audit you would like to set the preference for:")
     CASE (dcag_option)
      OF 1:
       SET dcag_pref_name = "PTAM"
      OF 2:
       SET dcag_pref_name = "SOURCE ONLY AUDIT"
      OF 0:
       SET dcag_end = 1
     ENDCASE
     IF (dcag_end != 1)
      SET drpc_dmprefs->cnt = 1
      SET stat = alterlist(drpc_dmprefs->qual,drpc_dmprefs->cnt)
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_domain = "RDDS AUDIT CONFIG"
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_section = "AUTO-GEN AUDIT"
      SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_name = dcag_pref_name
      CALL drpc_get_dmprefs(drpc_dmprefs)
      SET dcag_error_ind = check_error_gui("Managing Auto Generate Audit",
       "Automatically Generate Audit Queries Menu",drra_env_name,drra_env_id)
      IF (dcag_error_ind=0)
       IF ((drpc_dmprefs->qual[drpc_dmprefs->cnt].no_row_ind=1))
        SET dcag_cur_pref = 0
       ELSE
        SET dcag_cur_pref = drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_nbr
       ENDIF
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL drra_disp_header("Automatically Generate Audit Queries Menu",drra_env_name,drra_env_id)
       SET dcag_prompt_str = concat(" for tables missing them, when running the ",dcag_pref_name,
        " audit")
       CALL text(7,3,
        "Would you like to [A]llow/[R]estrict the system to automatically generate audit queries")
       CALL text(8,5,dcag_prompt_str)
       CALL text(10,3,"Enter R to have the system not generate queries.")
       SET dcag_pref_mean = evaluate(dcag_cur_pref,1,"to allow","to not allow")
       CALL text(11,3,concat("The current setting is ",dcag_pref_mean,
         " the system to generate queries for tables missing them."))
       CALL accept(8,(size(dcag_prompt_str)+ 6),"P;CU","A"
        WHERE curaccept IN ("A", "R"))
       SET dcag_pref_char = curaccept
       IF (dcag_pref_char="A")
        SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_nbr = 1
       ELSE
        SET drpc_dmprefs->qual[drpc_dmprefs->cnt].pref_nbr = 0
       ENDIF
       CALL drpc_manage_dmprefs(drpc_dmprefs)
       SET dcag_error_ind = check_error_gui("Managing Auto Generate Audit",
        "Automatically Generate Audit Queries Menu",drra_env_name,drra_env_id)
       IF (dcag_error_ind=0)
        COMMIT
        CALL text(13,3,"The setting was successfully updated. Press enter to continue.")
        CALL text(21,3,"Press Enter to continue...")
        CALL accept(21,30,"P;E"," ")
       ELSE
        ROLLBACK
       ENDIF
      ENDIF
      SET dcag_end = 1
     ENDIF
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_disp_audit_options(ddao_str)
   DECLARE ddao_val = i4 WITH protect, noconstant(0)
   CALL text(9,3,"1. PTAM")
   CALL text(10,3,"2. SOURCE ONLY AUDIT")
   CALL text(11,3,"0. Exit")
   CALL text(7,3,ddao_str)
   CALL accept(7,(size(ddao_str)+ 4),"99",0
    WHERE curaccept IN (1, 2, 0))
   SET ddao_val = curaccept
   RETURN(ddao_val)
 END ;Subroutine
 SUBROUTINE drra_view_audit_query(dvaq_rec)
   FREE RECORD dvaq_lines
   RECORD dvaq_lines(
     1 query_cnt = i4
     1 query_qual[*]
       2 query_name = vc
       2 line_cnt = i4
       2 line_qual[*]
         3 line_text = vc
   )
   DECLARE dvaq_comma = vc WITH protect, constant(",")
   DECLARE dvaq_loj = vc WITH protect, constant(notrim(" LEFT OUTER JOIN "))
   DECLARE dvaq_join = vc WITH protect, constant(notrim(" JOIN "))
   DECLARE dvaq_from = vc WITH protect, constant(notrim(" FROM "))
   DECLARE dvaq_and = vc WITH protect, constant(notrim(" AND "))
   DECLARE dvaq_comma_pos = i4 WITH protect, noconstant(0)
   DECLARE dvaq_loj_pos = i4 WITH protect, noconstant(0)
   DECLARE dvaq_join_pos = i4 WITH protect, noconstant(0)
   DECLARE dvaq_from_pos = i4 WITH protect, noconstant(0)
   DECLARE dvaq_and_pos = i4 WITH protect, noconstant(0)
   DECLARE dvaq_query_loop = i4 WITH protect, noconstant(0)
   DECLARE dvaq_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvaq_cur_pos = i4 WITH protect, noconstant(0)
   DECLARE dvaq_query_done = i2 WITH protect, noconstant(0)
   DECLARE dvaq_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dvaq_loj_ind = i2 WITH protect, noconstant(0)
   DECLARE dvaq_temp_pos = i4 WITH protect, noconstant(0)
   FOR (dvaq_query_loop = 1 TO dvaq_rec->query_cnt)
     SET dvaq_cur_pos = 1
     SET dvaq_cnt = 0
     SET dvaq_query_done = 0
     SET dvaq_lines->query_cnt = (dvaq_lines->query_cnt+ 1)
     SET stat = alterlist(dvaq_lines->query_qual,dvaq_lines->query_cnt)
     SET dvaq_lines->query_qual[dvaq_lines->query_cnt].query_name = dvaq_rec->query_qual[
     dvaq_query_loop].query_name
     WHILE (dvaq_query_done=0)
       SET dvaq_comma_pos = findstring(dvaq_comma,cnvtupper(dvaq_rec->query_qual[dvaq_query_loop].
         query_text),(dvaq_cur_pos+ 1),0)
       SET dvaq_loj_pos = findstring(dvaq_loj,cnvtupper(dvaq_rec->query_qual[dvaq_query_loop].
         query_text),(dvaq_cur_pos+ 1),0)
       SET dvaq_join_pos = findstring(dvaq_join,cnvtupper(dvaq_rec->query_qual[dvaq_query_loop].
         query_text),(dvaq_cur_pos+ 1),0)
       SET dvaq_from_pos = findstring(dvaq_from,cnvtupper(dvaq_rec->query_qual[dvaq_query_loop].
         query_text),(dvaq_cur_pos+ 1),0)
       SET dvaq_and_pos = findstring(dvaq_and,cnvtupper(dvaq_rec->query_qual[dvaq_query_loop].
         query_text),(dvaq_cur_pos+ 1),0)
       SET dvaq_comma_pos = evaluate(dvaq_comma_pos,0,2000000000,dvaq_comma_pos)
       SET dvaq_loj_pos = evaluate(dvaq_loj_pos,0,2000000000,dvaq_loj_pos)
       SET dvaq_join_pos = evaluate(dvaq_join_pos,0,2000000000,dvaq_join_pos)
       SET dvaq_from_pos = evaluate(dvaq_from_pos,0,2000000000,dvaq_from_pos)
       SET dvaq_and_pos = evaluate(dvaq_and_pos,0,2000000000,dvaq_and_pos)
       IF (least(dvaq_and_pos,dvaq_from_pos,dvaq_join_pos,dvaq_loj_pos,dvaq_comma_pos)=2000000000
        AND greatest(dvaq_and_pos,dvaq_from_pos,dvaq_join_pos,dvaq_loj_pos,dvaq_comma_pos)=2000000000
       )
        IF (((size(dvaq_rec->query_qual[dvaq_query_loop].query_text) - dvaq_cur_pos) <= 132))
         SET dvaq_cnt = (dvaq_cnt+ 1)
         SET stat = alterlist(dvaq_lines->query_qual[dvaq_lines->query_cnt].line_qual,dvaq_cnt)
         SET dvaq_lines->query_qual[dvaq_lines->query_cnt].line_cnt = dvaq_cnt
         SET dvaq_lines->query_qual[dvaq_lines->query_cnt].line_qual[dvaq_cnt].line_text = substring(
          dvaq_cur_pos,size(dvaq_rec->query_qual[dvaq_query_loop].query_text),dvaq_rec->query_qual[
          dvaq_query_loop].query_text)
         SET dvaq_query_done = 1
        ELSE
         SET dvaq_query_done = 1
         SET dm_err->err_ind = 1
         SET dm_err->emsg = "The query could not be broken up into a readable format"
        ENDIF
       ELSE
        IF (dvaq_loj_ind=1)
         SET dvaq_temp_pos = least(dvaq_and_pos,dvaq_from_pos,dvaq_loj_pos,dvaq_comma_pos)
        ELSE
         SET dvaq_temp_pos = least(dvaq_and_pos,dvaq_from_pos,dvaq_join_pos,dvaq_loj_pos,
          dvaq_comma_pos)
        ENDIF
        IF (((dvaq_temp_pos - dvaq_cur_pos) > 132))
         SET dvaq_query_done = 1
         SET dm_err->err_ind = 1
         SET dm_err->emsg = "The query could not be broken up into a readable format"
        ELSE
         IF (dvaq_temp_pos=dvaq_loj_pos)
          SET dvaq_loj_ind = 1
         ELSE
          SET dvaq_loj_ind = 0
         ENDIF
         SET dvaq_cnt = (dvaq_cnt+ 1)
         SET stat = alterlist(dvaq_lines->query_qual[dvaq_lines->query_cnt].line_qual,dvaq_cnt)
         SET dvaq_lines->query_qual[dvaq_lines->query_cnt].line_cnt = dvaq_cnt
         SET dvaq_lines->query_qual[dvaq_lines->query_cnt].line_qual[dvaq_cnt].line_text = substring(
          dvaq_cur_pos,(dvaq_temp_pos - dvaq_cur_pos),dvaq_rec->query_qual[dvaq_query_loop].
          query_text)
         SET dvaq_cur_pos = dvaq_temp_pos
        ENDIF
       ENDIF
     ENDWHILE
     SET dvaq_error_ind = check_error_gui("Managing Audit Row Limit","Audit Row Limit Menu",
      drra_env_name,drra_env_id)
     IF (dvaq_error_ind=1)
      SET dvaq_query_loop = (dvaq_rec->query_cnt+ 1)
     ENDIF
   ENDFOR
   IF (dvaq_error_ind=0)
    SET message = nowindow
    SELECT INTO "MINE"
     FROM dual d
     DETAIL
      col 0, row 0
      FOR (dvaq_query_loop = 1 TO dvaq_lines->query_cnt)
        row + 1, col 1, "Query Name: ",
        col 13, dvaq_lines->query_qual[dvaq_query_loop].query_name
        FOR (dvaq_cnt = 1 TO dvaq_lines->query_qual[dvaq_query_loop].line_cnt)
         row + 1,dvaq_lines->query_qual[dvaq_query_loop].line_qual[dvaq_cnt].line_text
        ENDFOR
        row + 1,
        "----------------------------------------------------------------------------------------------------------",
        row + 1
      ENDFOR
     WITH nocounter, formfeed = none
    ;end select
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_show_audit_upload_error(sau_reply)
   DECLARE sau_error_idx = i4 WITH protect, noconstant(0)
   IF ((sau_reply->audit_err_cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = sau_reply->status_data.subeventstatus[1].targetobjectvalue
    CALL check_error_gui("DM_RMC_RPT_LOAD_AUDITS","Upload Audits Menu",drra_env_name,drra_env_id)
   ELSE
    CALL text(10,3,concat("There were ",trim(cnvtstring(sau_reply->audit_err_cnt)),
      " audits that failed during upload."))
    CALL text(11,3,"Do you want to see the audit error details? (Y/N)")
    CALL accept(11,53,"P;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     SELECT INTO "MINE"
      FROM dual
      DETAIL
       col 0, "AUDIT_NAME", col 40,
       "ERROR_MESSAGE"
       FOR (sau_error_idx = 1 TO sau_reply->audit_err_cnt)
         row + 1, col 0, sau_reply->audit_err_qual[sau_error_idx].audit_param,
         col 40, sau_reply->audit_err_qual[sau_error_idx].audit_error
       ENDFOR
      WITH nocounter, maxcol = 250
     ;end select
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_view_upload_dynamic(dvud_store_rep)
   FREE RECORD dvud_reply
   RECORD dvud_reply(
     1 query_cnt = i4
     1 query_qual[*]
       2 query_text = vc
       2 query_name = vc
   )
   FREE RECORD dvud_request
   RECORD dvud_request(
     1 table_name = vc
     1 db_link = vc
   )
   DECLARE dvud_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dvud_loop = i4 WITH protect, noconstant(0)
   DECLARE dvud_upload = vc WITH protect, noconstant(" ")
   CALL text(7,3,"Input the table name you wish to generate audit queries for: ")
   CALL accept(7,64,"P(40);CU")
   SET dvud_request->table_name = curaccept
   SELECT INTO "NL:"
    FROM dm_env_reltn r,
     dm_rdds_event_log l
    WHERE l.cur_environment_id=drra_env_id
     AND l.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND  NOT (list(l.paired_environment_id,l.event_reason) IN (
    (SELECT
     l2.paired_environment_id, l2.event_reason
     FROM dm_rdds_event_log l2
     WHERE l2.cur_environment_id=drra_env_id
      AND l2.rdds_event_key="ENDREFERENCEDATASYNC")))
     AND r.child_env_id=l.cur_environment_id
     AND r.parent_env_id=l.paired_environment_id
     AND r.relationship_type="REFERENCE MERGE"
    DETAIL
     dvud_request->db_link = r.post_link_name
    WITH nocounter
   ;end select
   SET dvud_error_ind = check_error_gui("Gathering DB_LINK information","Upload Audits Menu",
    drra_env_name,drra_env_id)
   IF (daf_is_not_blank(dvud_request->table_name)
    AND dvud_error_ind=0)
    SET message = nowindow
    EXECUTE dm_rmc_rpt_gen_audit  WITH replace("DRRGA_REQUEST","DVUD_REQUEST"), replace("DRRGA_REPLY",
     "DVUD_REPLY")
    CALL clear(1,1)
    SET message = window
    SET width = 132
    CALL drra_disp_header("Upload Audits Menu",drra_env_name,drra_env_id)
    SET dvud_error_ind = check_error_gui("Generating Dynamic Query","Upload Audits Menu",
     drra_env_name,drra_env_id)
    IF (dvud_error_ind=0)
     CALL drra_view_audit_query(dvud_reply)
     IF ((dm_err->err_ind=0))
      CALL clear(1,1)
      SET message = window
      SET width = 132
      CALL drra_disp_header("Upload Audits Menu",drra_env_name,drra_env_id)
      CALL text(7,3,
       "Do you want to upload the dynamic queries into the framework to be used for auditing? (Y/N)")
      CALL accept(7,95,"P;CU","Y"
       WHERE curaccept IN ("Y", "N"))
      SET dvud_upload = curaccept
      IF (dvud_upload="Y")
       FOR (dvud_loop = 1 TO dvud_reply->query_cnt)
        CALL drla_store_audit(dvud_reply->query_qual[dvud_loop].query_text,dvud_reply->query_qual[
         dvud_loop].query_name,dvud_store_rep,"DYNAMICALLY GENERATED")
        IF ((dm_err->err_ind=0))
         IF ((dvud_store_rep->audit_err_cnt > 0))
          SET dvud_store_rep->status_data.status = "F"
          SET dvud_store_rep->status_data.subeventstatus[1].targetobjectvalue =
          "One or more audit queries failed validation."
          SET dvud_loop = dvud_reply->query_cnt
         ENDIF
        ELSE
         SET dvud_store_rep->status_data.status = "F"
         SET dvud_store_rep->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
         SET dvud_loop = dvud_reply->query_cnt
        ENDIF
       ENDFOR
       IF ((dvud_store_rep->status_data.status != "F"))
        CALL text(10,3,"Dynamic queries were successfully uploaded. Press enter to continue")
        CALL accept(10,71,"P;E"," ")
       ELSE
        CALL drra_show_audit_upload_error(dvud_store_rep)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drra_view_query_menu(null)
   FREE RECORD dvqm_reply
   RECORD dvqm_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 audit_err_cnt = i4
     1 audit_err_qual[*]
       2 audit_param = vc
       2 audit_error = vc
   )
   FREE RECORD dvqm_data
   RECORD dvqm_data(
     1 query_cnt = i4
     1 query_qual[*]
       2 query_name = vc
       2 query_text = vc
   )
   DECLARE dvqm_table_name = vc WITH protect, noconstant(" ")
   DECLARE dvqm_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dvqm_done_ind = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL drra_disp_header("View Query Menu",drra_env_name,drra_env_id)
   CALL text(7,3,
    "Would you like to view an audit query that is already uploaded, or a dynamicaly generated audit query?"
    )
   CALL text(9,3,"1. View uploaded audit")
   CALL text(10,3,"2. View dynamically generated audit")
   CALL accept(7,106,"99",0
    WHERE curaccept IN (1, 2, 0))
   CASE (curaccept)
    OF 1:
     WHILE (dvqm_done_ind=0)
       CALL clear(1,1)
       SET message = window
       SET width = 132
       CALL drra_disp_header("View Query Menu",drra_env_name,drra_env_id)
       CALL text(9,3,"Select the table you would like to view audits for?")
       SET help = pos(8,90,15,38)
       SET help =
       SELECT DISTINCT
        table_name = d.pref_section
        FROM dm_prefs d
        WHERE d.application_nbr=0
         AND d.person_id=0.0
         AND ((d.pref_domain="RDDS AUDIT QUERY") UNION (
        (SELECT
         "<EXIT PROMPT>"
         FROM dual)))
        ORDER BY 1
        WITH nocounter
       ;end select
       CALL text(23,05,"HELP: Press <SHIFT><F5>  ")
       CALL accept(9,54,"P(30);CU")
       SET dvqm_table_name = curaccept
       IF (dvqm_table_name="<EXIT PROMPT>")
        SET dvqm_done_ind = 1
       ELSE
        SET dvqm_done_ind = drrac_get_audit_cnt(dvqm_table_name)
        SET dvqm_error_ind = check_error_gui("Query for Audit","View Query Menu",drra_env_name,
         drra_env_id)
        IF (dvqm_error_ind=1)
         SET dvqm_done_ind = 1
        ENDIF
       ENDIF
       SET help = off
       IF (dvqm_done_ind=0)
        CALL text(20,3,"Invalid Input.")
        CALL pause(3)
       ENDIF
     ENDWHILE
     IF (dvqm_table_name != "<EXIT PROMPT>")
      CALL drrac_get_audit_data(dvqm_table_name,dvqm_data)
      SET dvqm_error_ind = check_error_gui("Reading uploaded audits","View Query Menu",drra_env_name,
       drra_env_id)
      IF (dvqm_error_ind=0)
       CALL drra_view_audit_query(dvqm_data)
      ENDIF
     ENDIF
    OF 2:
     CALL clear(1,1)
     SET message = window
     SET width = 132
     CALL drra_disp_header("View Query Menu",drra_env_name,drra_env_id)
     CALL drra_view_upload_dynamic(dvqm_reply)
   ENDCASE
   RETURN(null)
 END ;Subroutine
#exit_menu
END GO
