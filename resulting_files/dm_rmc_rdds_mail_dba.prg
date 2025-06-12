CREATE PROGRAM dm_rmc_rdds_mail:dba
 SET trace progcachesize 255
 IF ((validate(drrm_email_address->address_cnt,- (1))=- (1))
  AND (validate(drrm_email_addres->address_cnt,- (2))=- (2)))
  FREE RECORD drrm_email_address
  RECORD drrm_email_address(
    1 address_cnt = i4
    1 email_address = vc
  )
 ENDIF
 IF ((validate(drrm_event_types->det_size,- (1))=- (1))
  AND (validate(drrm_event_types->det_size,- (2))=- (2)))
  FREE RECORD drrm_event_types
  RECORD drrm_event_types(
    1 det_size = i4
    1 qual[*]
      2 event_type = vc
  )
 ENDIF
 IF ((validate(drrm_events->cur_env_id,- (1))=- (1))
  AND (validate(drrm_events->cur_env_id,- (2))=- (2)))
  FREE RECORD drrm_events
  RECORD drrm_events(
    1 file_name = vc
    1 cur_env_id = f8
    1 reltn_target_env_id = f8
    1 reltn_source_env_id = f8
    1 reltn_status = vc
    1 link_name = vc
    1 source_env_id = f8
    1 target_env_id = f8
    1 source_env_name = vc
    1 target_env_name = vc
    1 unrprtd_cnt = i4
    1 source_event_name = vc
    1 target_event_name = vc
    1 subject_text = vc
    1 status_rpt_ind = i2
    1 suppression_tm = i4
    1 qual[*]
      2 event_type = vc
      2 event_log_id = f8
      2 event_reason = vc
      2 event = vc
      2 event_key = vc
      2 msg_type_name = vc
      2 event_detail1_txt = vc
      2 event_detail2_txt = vc
      2 event_detail3_txt = vc
      2 event_dt_tm = vc
      2 event_value = f8
      2 header_ind = i2
      2 body_text[*]
        3 text_line = vc
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
 DECLARE drrm_detect_auto_cutover_errors(ddace_events=vc(ref)) = i2
 DECLARE drrm_detect_orphan_movers(ddom_events=vc(ref)) = i2
 DECLARE drrm_detect_stale_movers(ddsm_events=vc(ref)) = i2
 DECLARE drrm_determine_unreported(ddu_event_type=vc,ddu_event_types=vc(ref),ddu_events=vc(ref)) = i2
 DECLARE drrm_unprocessed_r_resets(durr_events=vc(ref)) = i2
 DECLARE drrm_detect_warnings(ddtq_events=vc(ref),ddtq_event_name=vc) = i2
 SUBROUTINE drrm_detect_auto_cutover_errors(ddace_events)
   DECLARE ddace_last_cnt = f8
   DECLARE ddace_look_ahead = f8
   DECLARE ddace_cur_time = f8
   DECLARE ddace_last_report = f8
   DECLARE ddace_write_event_cnt = i4
   DECLARE ddace_curqual = i4
   SET dm_err->eproc = "Determing if current environment is in an Auto-Cutover relationship."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_env_reltn der
    WHERE (der.parent_env_id=ddace_events->source_env_id)
     AND (der.child_env_id=ddace_events->target_env_id)
     AND der.relationship_type="AUTO CUTOVER"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    RETURN(1)
   ELSE
    SET dm_err->eproc = "Retrieving date time of last Auto-Cutover Error event reported."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE (drel.cur_environment_id=ddace_events->target_env_id)
      AND (drel.paired_environment_id=ddace_events->source_env_id)
      AND drel.rdds_event_key="AUTOCUTOVERERROR"
     DETAIL
      row + 0
     FOOT REPORT
      ddace_last_cnt = cnvtdatetime(max(drel.event_dt_tm))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
    SET ddace_curqual = curqual
    IF (ddace_curqual=0)
     SET ddace_last_cnt = cnvtdatetime("01-JAN-1800 00:00:00")
    ENDIF
    SET dm_err->eproc = "Retrieving information about all Auto-Cutover table processing errors."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT DISTINCT INTO "NL:"
     drw.table_name
     FROM dm_refchg_warning drw
     WHERE drw.updt_dt_tm >= cnvtdatetime(ddace_last_cnt)
      AND drw.warning_type="TABLE PROCESSING ERROR"
      AND (drw.source_env_id=ddace_events->source_env_id)
     HEAD REPORT
      stat = alterlist(auto_ver_request->qual,1), auto_ver_request->qual[1].rdds_event =
      "Auto-Cutover Error", auto_ver_request->qual[1].cur_environment_id = ddace_events->
      target_env_id,
      auto_ver_request->qual[1].paired_environment_id = ddace_events->source_env_id
     DETAIL
      ddace_write_event_cnt = (ddace_write_event_cnt+ 1), stat = alterlist(auto_ver_request->qual[1].
       detail_qual,ddace_write_event_cnt), auto_ver_request->qual[1].detail_qual[
      ddace_write_event_cnt].event_detail1_txt = drw.table_name,
      auto_ver_request->qual[1].detail_qual[ddace_write_event_cnt].event_detail2_txt = drw.table_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
    FOR (ddace_loop = 1 TO ddace_write_event_cnt)
      IF ((ddace_events->qual[ddace_loop].event_type="Auto-Cutover Error"))
       SET auto_ver_request->qual[1].detail_qual[ddace_loop].event_detail2_txt = get_reg_tab_name(
        auto_ver_request->qual[1].detail_qual[ddace_loop].event_detail2_txt,"")
      ENDIF
    ENDFOR
    SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    EXECUTE dm_rmc_auto_verify_setup
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
    COMMIT
    SET dm_err->eproc = "Finding last Auto-Cutover Error Event reported."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     FROM dm_rdds_event_detail dred
     WHERE dred.dm_rdds_event_log_id IN (
     (SELECT
      drel.dm_rdds_event_log_id
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key="REPORTEMAILED"
       AND (drel.cur_environment_id=ddace_events->target_env_id)
       AND (drel.paired_environment_id=ddace_events->source_env_id)))
      AND dred.event_detail1_txt="EVENT REPORTED"
      AND dred.event_detail2_txt="Auto-Cutover Error"
     DETAIL
      row + 0
     FOOT REPORT
      ddace_last_report = cnvtdatetime(max(dred.updt_dt_tm))
     WITH nocounter
    ;end select
    SET ddace_curqual = curqual
    IF (((curqual=0) OR (ddace_last_report=0)) )
     SET ddace_last_report = cnvtdatetime("01-JAN-1800 00:00:00")
    ENDIF
    SET ddace_look_ahead = cnvtlookahead(build(value(ddace_events->suppression_tm),",H"),
     ddace_last_report)
    SET ddace_cur_time = cnvtdatetime(curdate,curtime3)
    IF (cnvtdatetime(ddace_cur_time) >= cnvtdatetime(ddace_look_ahead))
     SET dm_err->eproc = "Reporting Auto Cutover Errors recorded post last report e-mailed."
     CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
     SELECT INTO "NL:"
      FROM dm_rdds_event_detail dred
      WHERE dred.dm_rdds_event_log_id IN (
      (SELECT
       drel.dm_rdds_event_log_id
       FROM dm_rdds_event_log drel
       WHERE drel.rdds_event_key="AUTOCUTOVERERROR"
        AND (drel.cur_environment_id=ddace_events->target_env_id)
        AND (drel.paired_environment_id=ddace_events->source_env_id)
        AND drel.event_dt_tm >= cnvtdatetime(ddace_last_report)))
      HEAD REPORT
       ddace_events->unrprtd_cnt = (ddace_events->unrprtd_cnt+ 1), stat = alterlist(ddace_events->
        qual,ddace_events->unrprtd_cnt), ddace_events->qual[ddace_events->unrprtd_cnt].header_ind = 1,
       ddace_events->qual[ddace_events->unrprtd_cnt].event_type = "Auto-Cutover Error", ddace_events
       ->qual[ddace_events->unrprtd_cnt].event_detail1_txt = "EVENT REPORTED", ddace_events->qual[
       ddace_events->unrprtd_cnt].event_reason = "EVENT REPORTED"
      DETAIL
       ddace_events->unrprtd_cnt = (ddace_events->unrprtd_cnt+ 1), stat = alterlist(ddace_events->
        qual,ddace_events->unrprtd_cnt), ddace_events->qual[ddace_events->unrprtd_cnt].event_type =
       "Auto-Cutover Error",
       ddace_events->qual[ddace_events->unrprtd_cnt].event = "Auto-Cutover Error", ddace_events->
       qual[ddace_events->unrprtd_cnt].event_detail1_txt = dred.event_detail1_txt, ddace_events->
       qual[ddace_events->unrprtd_cnt].event_detail2_txt = dred.event_detail2_txt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET stat = initrec(auto_ver_request)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_detect_orphan_movers(ddom_events)
   DECLARE ddom_event_type_loop = i4
   DECLARE ddom_drop_mover_loop = i4
   DECLARE ddom_write_event_cnt = i4
   DECLARE ddom_curqual = i4
   DECLARE ddom_last_report = f8
   DECLARE ddom_look_ahead = f8
   DECLARE ddom_cur_time = f8
   SET ddom_write_event_cnt = 0
   FREE RECORD ddom_drop_orphan_movers
   RECORD ddom_drop_orphan_movers(
     1 orphan_cnt = i4
     1 qual[*]
       2 orphan_mover_id = f8
   )
   SET dm_err->eproc = "Finding any orphaned mover processes."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT DISTINCT INTO "NL:"
    drp.log_file
    FROM dm_refchg_process drp
    WHERE  NOT (drp.rdbhandle_value IN (
    (SELECT
     g.audsid
     FROM gv$session g)))
     AND drp.refchg_status="MOVER RUNNING"
     AND (drp.env_source_id=ddom_events->source_env_id)
    ORDER BY drp.last_action_dt_tm DESC
    HEAD REPORT
     stat = alterlist(auto_ver_request->qual,1), auto_ver_request->qual[1].rdds_event =
     "Orphaned Mover", auto_ver_request->qual[1].cur_environment_id = ddom_events->target_env_id,
     auto_ver_request->qual[1].paired_environment_id = ddom_events->source_env_id
    DETAIL
     ddom_drop_orphan_movers->orphan_cnt = (ddom_drop_orphan_movers->orphan_cnt+ 1), stat = alterlist
     (ddom_drop_orphan_movers->qual,ddom_drop_orphan_movers->orphan_cnt), ddom_drop_orphan_movers->
     qual[ddom_drop_orphan_movers->orphan_cnt].orphan_mover_id = drp.dm_refchg_process_id,
     ddom_write_event_cnt = (ddom_write_event_cnt+ 1), stat = alterlist(auto_ver_request->qual[1].
      detail_qual,ddom_write_event_cnt), auto_ver_request->qual[1].detail_qual[ddom_write_event_cnt].
     event_detail1_txt = drp.log_file,
     auto_ver_request->qual[1].detail_qual[ddom_write_event_cnt].event_detail2_txt = drp.process_name
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   FOR (ddom_drop_mover_loop = 1 TO ddom_drop_orphan_movers->orphan_cnt)
    DELETE  FROM dm_refchg_process drp
     WHERE (drp.dm_refchg_process_id=ddom_drop_orphan_movers->qual[ddom_drop_mover_loop].
     orphan_mover_id)
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
   ENDFOR
   SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   EXECUTE dm_rmc_auto_verify_setup
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   COMMIT
   SET dm_err->eproc = "Finding last Orphan Movers Event reported."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_rdds_event_detail dred
    WHERE dred.dm_rdds_event_log_id IN (
    (SELECT
     drel.dm_rdds_event_log_id
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="REPORTEMAILED"
      AND (drel.cur_environment_id=ddom_events->target_env_id)
      AND (drel.paired_environment_id=ddom_events->source_env_id)))
     AND dred.event_detail1_txt="EVENT REPORTED"
     AND dred.event_detail2_txt="Orphaned Mover"
    DETAIL
     row + 0
    FOOT REPORT
     ddom_last_report = cnvtdatetime(max(dred.updt_dt_tm))
    WITH nocounter
   ;end select
   SET ddom_curqual = curqual
   IF (((curqual=0) OR (ddom_last_report=0)) )
    SET ddom_last_report = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
   SET ddom_look_ahead = cnvtlookahead(build(value(ddom_events->suppression_tm),",H"),
    ddom_last_report)
   SET ddom_cur_time = cnvtdatetime(curdate,curtime3)
   IF (cnvtdatetime(ddom_cur_time) >= cnvtdatetime(ddom_look_ahead))
    SET dm_err->eproc = "Reporting Orphan movers recorded post last report e-mailed."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     FROM dm_rdds_event_detail dred
     WHERE dred.dm_rdds_event_log_id IN (
     (SELECT
      drel.dm_rdds_event_log_id
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key="ORPHANEDMOVER"
       AND (drel.cur_environment_id=ddom_events->target_env_id)
       AND (drel.paired_environment_id=ddom_events->source_env_id)
       AND drel.event_dt_tm >= cnvtdatetime(ddom_last_report)))
     HEAD REPORT
      ddom_events->unrprtd_cnt = (ddom_events->unrprtd_cnt+ 1), stat = alterlist(ddom_events->qual,
       ddom_events->unrprtd_cnt), ddom_events->qual[ddom_events->unrprtd_cnt].header_ind = 1,
      ddom_events->qual[ddom_events->unrprtd_cnt].event_type = "Orphaned Mover", ddom_events->qual[
      ddom_events->unrprtd_cnt].event_detail1_txt = "EVENT REPORTED", ddom_events->qual[ddom_events->
      unrprtd_cnt].event_detail2_txt = "Orphaned Mover"
     DETAIL
      ddom_events->unrprtd_cnt = (ddom_events->unrprtd_cnt+ 1), stat = alterlist(ddom_events->qual,
       ddom_events->unrprtd_cnt), ddom_events->qual[ddom_events->unrprtd_cnt].event_type =
      "Orphaned Mover",
      ddom_events->qual[ddom_events->unrprtd_cnt].event = "Orphaned Mover", ddom_events->qual[
      ddom_events->unrprtd_cnt].event_detail1_txt = dred.event_detail1_txt, ddom_events->qual[
      ddom_events->unrprtd_cnt].event_detail2_txt = dred.event_detail2_txt
     WITH nocounter
    ;end select
   ENDIF
   SET stat = initrec(auto_ver_request)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_detect_stale_movers(ddsm_events)
   DECLARE ddsm_event_type_loop = i4
   DECLARE ddsm_write_event_cnt = i4
   DECLARE ddsm_curqual = i4
   DECLARE ddsm_last_report = f8
   DECLARE ddsm_look_ahead = f8
   DECLARE ddsm_cur_time = f8
   SET dm_err->eproc = "Finding any stale mover processes."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT DISTINCT INTO "NL:"
    drp.log_file
    FROM dm_refchg_process drp,
     dm_info di
    WHERE drp.rdbhandle_value IN (
    (SELECT
     g.audsid
     FROM gv$session g))
     AND drp.refchg_status="MOVER RUNNING"
     AND drp.refchg_type="MOVER PROCESS"
     AND di.info_domain="DATA MANAGEMENT"
     AND di.info_name="RDDS STOP TIME"
     AND drp.last_action_dt_tm < di.info_date
    HEAD REPORT
     stat = alterlist(auto_ver_request->qual,1), auto_ver_request->qual[1].rdds_event = "Stale Mover",
     auto_ver_request->qual[1].cur_environment_id = ddsm_events->target_env_id,
     auto_ver_request->qual[1].paired_environment_id = ddsm_events->source_env_id
    DETAIL
     ddsm_write_event_cnt = (ddsm_write_event_cnt+ 1), stat = alterlist(auto_ver_request->qual[1].
      detail_qual,ddsm_write_event_cnt), auto_ver_request->qual[1].detail_qual[ddsm_write_event_cnt].
     event_detail1_txt = drp.log_file,
     auto_ver_request->qual[1].detail_qual[ddsm_write_event_cnt].event_detail2_txt = drp.process_name,
     auto_ver_request->qual[1].detail_qual[ddsm_write_event_cnt].event_detail3_txt =
     "LAST_ACTION_DT_TM", auto_ver_request->qual[1].detail_qual[ddsm_write_event_cnt].event_value =
     drp.last_action_dt_tm
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   EXECUTE dm_rmc_auto_verify_setup
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   COMMIT
   SET dm_err->eproc = "Finding last Stale Movers Event reported."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_rdds_event_detail dred
    WHERE dred.dm_rdds_event_log_id IN (
    (SELECT
     drel.dm_rdds_event_log_id
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="REPORTEMAILED"
      AND (drel.cur_environment_id=ddsm_events->target_env_id)
      AND (drel.paired_environment_id=ddsm_events->source_env_id)))
     AND dred.event_detail1_txt="EVENT REPORTED"
     AND dred.event_detail2_txt="Stale Mover"
    DETAIL
     row + 0
    FOOT REPORT
     ddsm_last_report = cnvtdatetime(max(dred.updt_dt_tm))
    WITH nocounter
   ;end select
   SET ddsm_curqual = curqual
   IF (((curqual=0) OR (ddsm_last_report=0)) )
    SET ddsm_last_report = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
   SET ddsm_look_ahead = cnvtlookahead(build(value(ddsm_events->suppression_tm),",H"),
    ddsm_last_report)
   SET ddsm_cur_time = cnvtdatetime(curdate,curtime3)
   IF (cnvtdatetime(ddsm_cur_time) >= cnvtdatetime(ddsm_look_ahead))
    SET dm_err->eproc = "Reporting Stale movers recorded post last report e-mailed."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     FROM dm_rdds_event_detail dred
     WHERE dred.dm_rdds_event_log_id IN (
     (SELECT
      drel.dm_rdds_event_log_id
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key="STALEMOVER"
       AND (drel.cur_environment_id=ddsm_events->target_env_id)
       AND (drel.paired_environment_id=ddsm_events->source_env_id)
       AND drel.event_dt_tm >= cnvtdatetime(ddsm_last_report)))
     HEAD REPORT
      ddsm_events->unrprtd_cnt = (ddsm_events->unrprtd_cnt+ 1), stat = alterlist(ddsm_events->qual,
       ddsm_events->unrprtd_cnt), ddsm_events->qual[ddsm_events->unrprtd_cnt].header_ind = 1,
      ddsm_events->qual[ddsm_events->unrprtd_cnt].event_type = "Stale Mover", ddsm_events->qual[
      ddsm_events->unrprtd_cnt].event_detail1_txt = "EVENT REPORTED", ddsm_events->qual[ddsm_events->
      unrprtd_cnt].event_detail2_txt = "Stale Mover"
     DETAIL
      ddsm_events->unrprtd_cnt = (ddsm_events->unrprtd_cnt+ 1), stat = alterlist(ddsm_events->qual,
       ddsm_events->unrprtd_cnt), ddsm_events->qual[ddsm_events->unrprtd_cnt].event_type =
      "Stale Mover",
      ddsm_events->qual[ddsm_events->unrprtd_cnt].event = "Stale Mover", ddsm_events->qual[
      ddsm_events->unrprtd_cnt].event_detail1_txt = dred.event_detail1_txt, ddsm_events->qual[
      ddsm_events->unrprtd_cnt].event_detail2_txt = dred.event_detail2_txt
     WITH nocounter
    ;end select
   ENDIF
   SET stat = initrec(auto_ver_request)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_determine_unreported(ddu_event_type,ddu_event_types,ddu_events)
   DECLARE ddu_event_type_upper = vc
   DECLARE ddu_max_reported_dt_tm = f8
   DECLARE ddu_event_type_loop = i4
   FOR (ddu_event_type_loop = 1 TO ddu_event_types->det_size)
     SET ddu_event_type_upper = cnvtupper(trim(cnvtalphanum(ddu_event_types->qual[ddu_event_type_loop
        ].event_type)))
     SET dm_err->eproc = "Finding unreported events."
     CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
     SELECT INTO "NL:"
      y_dt_tm = max(dred.updt_dt_tm)
      FROM dm_rdds_event_detail dred
      WHERE dred.dm_rdds_event_log_id IN (
      (SELECT
       drela.dm_rdds_event_log_id
       FROM dm_rdds_event_log drela
       WHERE drela.rdds_event_key="REPORTEMAILED"
        AND (drela.paired_environment_id=ddu_events->source_env_id)
        AND (drela.cur_environment_id=ddu_events->target_env_id)
        AND drela.event_reason=ddu_event_type))
       AND dred.event_detail1_txt="EVENT REPORTED"
       AND (dred.event_detail2_txt=ddu_event_types->qual[ddu_event_type_loop].event_type)
      DETAIL
       row + 0
      FOOT REPORT
       ddu_max_reported_dt_tm = y_dt_tm
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Getting unreported events info."
     CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
     SELECT
      IF (ddu_max_reported_dt_tm > 0)
       WHERE drel.event_dt_tm > cnvtdatetime(ddu_max_reported_dt_tm)
        AND drel.rdds_event_key=ddu_event_type_upper
        AND (drel.paired_environment_id=ddu_events->source_env_id)
        AND (drel.cur_environment_id=ddu_events->target_env_id)
      ELSE
       WHERE drel.rdds_event_key=ddu_event_type_upper
        AND (drel.paired_environment_id=ddu_events->source_env_id)
        AND (drel.cur_environment_id=ddu_events->target_env_id)
      ENDIF
      INTO "NL:"
      drel.dm_rdds_event_log_id, drel.event_reason, drel.rdds_event,
      drel.rdds_event_key, drel.cur_environment_id, drel.paired_environment_id
      FROM dm_rdds_event_log drel
      DETAIL
       ddu_events->unrprtd_cnt = (ddu_events->unrprtd_cnt+ 1), stat = alterlist(ddu_events->qual,
        ddu_events->unrprtd_cnt), ddu_events->qual[ddu_events->unrprtd_cnt].header_ind = 1,
       ddu_events->qual[ddu_events->unrprtd_cnt].event_type = ddu_event_types->qual[
       ddu_event_type_loop].event_type, ddu_events->qual[ddu_events->unrprtd_cnt].event_log_id = drel
       .dm_rdds_event_log_id, ddu_events->qual[ddu_events->unrprtd_cnt].event_reason = drel
       .event_reason,
       ddu_events->qual[ddu_events->unrprtd_cnt].event = drel.rdds_event, ddu_events->qual[ddu_events
       ->unrprtd_cnt].event_key = drel.rdds_event_key, ddu_events->qual[ddu_events->unrprtd_cnt].
       event_detail1_txt = "EVENT REPORTED",
       ddu_events->qual[ddu_events->unrprtd_cnt].event_detail2_txt = ddu_event_types->qual[
       ddu_event_type_loop].event_type, ddu_events->qual[ddu_events->unrprtd_cnt].event_value = drel
       .dm_rdds_event_log_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_unprocessed_r_resets(durr_events)
   DECLARE durr_event_type_loop = i4 WITH protect, noconstant(0)
   DECLARE durr_write_event_cnt = i4 WITH protect, noconstant(0)
   DECLARE durr_auto_cutover_ind = i2 WITH protect, noconstant(0)
   DECLARE durr_last_report = f8 WITH protect, noconstant(0.0)
   DECLARE durr_look_ahead = f8 WITH protect, noconstant(0.0)
   DECLARE durr_cur_time = f8 WITH protect, noconstant(0.0)
   DECLARE durr_max_event_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(0,0))
   DECLARE durr_rdds_event = vc WITH protect, noconstant("")
   DECLARE durr_rdds_event_key = vc WITH protect, noconstant("")
   DECLARE durr_num_errors = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Determine if auto_cutover is setup."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_env_reltn der
    WHERE (der.parent_env_id=durr_events->source_env_id)
     AND (der.child_env_id=durr_events->target_env_id)
     AND der.relationship_type IN ("PLANNED CUTOVER", "AUTO CUTOVER")
    DETAIL
     IF (der.relationship_type="AUTO CUTOVER")
      durr_auto_cutover_ind = 1, durr_rdds_event = "Auto Cutover Dual Build Issues",
      durr_rdds_event_key = "AUTOCUTOVERDUALBUILDISSUES"
     ELSE
      durr_auto_cutover_ind = 0, durr_rdds_event = "Unprocessed $R Resets", durr_rdds_event_key =
      "UNPROCESSEDRRESETS"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finding any unprocessed $R reset rows."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    x = max(drel.event_dt_tm)
    FROM dm_rdds_event_log drel
    WHERE (drel.cur_environment_id=durr_events->target_env_id)
     AND (drel.paired_environment_id=durr_events->source_env_id)
     AND drel.rdds_event_key=durr_rdds_event_key
    DETAIL
     durr_max_event_dt_tm = cnvtdatetime(x)
    WITH nocounter
   ;end select
   IF (durr_max_event_dt_tm=0.00)
    SET durr_max_event_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (durr_auto_cutover_ind=0)
    SELECT INTO "NL:"
     y = count(*)
     FROM dm_refchg_rtable_reset drrr
     WHERE drrr.reset_status IN ("UNPROCESSED", "SEVERE")
      AND drrr.updt_dt_tm > cnvtdatetime(durr_max_event_dt_tm)
     HEAD REPORT
      stat = alterlist(auto_ver_request->qual,1), auto_ver_request->qual[1].rdds_event =
      durr_rdds_event, auto_ver_request->qual[1].cur_environment_id = durr_events->target_env_id,
      auto_ver_request->qual[1].paired_environment_id = durr_events->source_env_id
     DETAIL
      stat = alterlist(auto_ver_request->qual[1].detail_qual,1), auto_ver_request->qual[1].
      detail_qual[1].event_detail1_txt = "Number of Unprocessed Rows", auto_ver_request->qual[1].
      detail_qual[1].event_value = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    IF ((auto_ver_request->qual[1].detail_qual[1].event_value > 0))
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   SET dm_err->eproc =
   "Finding last Unprocessed $R Resets/Auto Cutover Dual Build Issues Event reported."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    z = max(dred.updt_dt_tm)
    FROM dm_rdds_event_detail dred
    WHERE dred.dm_rdds_event_log_id IN (
    (SELECT
     drel.dm_rdds_event_log_id
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="REPORTEMAILED"
      AND (drel.cur_environment_id=durr_events->target_env_id)
      AND (drel.paired_environment_id=durr_events->source_env_id)))
     AND dred.event_detail1_txt="EVENT REPORTED"
     AND dred.event_detail2_txt=durr_rdds_event
    DETAIL
     durr_last_report = cnvtdatetime(z)
    WITH nocounter
   ;end select
   IF (durr_last_report=0.00)
    SET durr_last_report = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
   SET durr_look_ahead = cnvtlookahead(build(value(durr_events->suppression_tm),",H"),
    durr_last_report)
   SET durr_cur_time = cnvtdatetime(curdate,curtime3)
   IF (cnvtdatetime(durr_cur_time) >= cnvtdatetime(durr_look_ahead))
    SET dm_err->eproc = concat("Reporting ",durr_rdds_event," recorded post last report e-mailed.")
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     x = sum(dred.event_detail_value)
     FROM dm_rdds_event_detail dred
     WHERE dred.dm_rdds_event_log_id IN (
     (SELECT
      drel.dm_rdds_event_log_id
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key=durr_rdds_event_key
       AND (drel.cur_environment_id=durr_events->target_env_id)
       AND (drel.paired_environment_id=durr_events->source_env_id)
       AND drel.event_dt_tm > cnvtdatetime(durr_last_report)))
     HEAD REPORT
      durr_events->unrprtd_cnt = (durr_events->unrprtd_cnt+ 1), stat = alterlist(durr_events->qual,
       durr_events->unrprtd_cnt), durr_events->qual[durr_events->unrprtd_cnt].header_ind = 1,
      durr_events->qual[durr_events->unrprtd_cnt].event_value = cnvtreal(x), durr_events->qual[
      durr_events->unrprtd_cnt].event_type = durr_rdds_event, durr_events->qual[durr_events->
      unrprtd_cnt].event_detail1_txt = "EVENT REPORTED",
      durr_events->qual[durr_events->unrprtd_cnt].event_detail2_txt = durr_rdds_event
     DETAIL
      durr_events->unrprtd_cnt = (durr_events->unrprtd_cnt+ 1), stat = alterlist(durr_events->qual,
       durr_events->unrprtd_cnt), durr_events->qual[durr_events->unrprtd_cnt].event_type =
      durr_rdds_event,
      durr_events->qual[durr_events->unrprtd_cnt].event = durr_rdds_event, durr_events->qual[
      durr_events->unrprtd_cnt].event_value = dred.event_detail_value, durr_events->qual[durr_events
      ->unrprtd_cnt].event_detail1_txt = dred.event_detail1_txt,
      durr_events->qual[durr_events->unrprtd_cnt].event_detail2_txt = dred.event_detail2_txt,
      durr_num_errors = x
     WITH nocounter
    ;end select
   ENDIF
   IF (durr_num_errors=0)
    SET durr_events->unrprtd_cnt = (durr_events->unrprtd_cnt - 2)
    SET stat = alterlist(durr_events->qual,durr_events->unrprtd_cnt)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_detect_warnings(ddtq_events,ddtq_event_name)
   DECLARE ddtq_curqual = i4 WITH protect, noconstant(0)
   DECLARE ddtq_last_report = f8 WITH protect, noconstant(0.0)
   DECLARE ddtq_look_ahead = f8 WITH protect, noconstant(0.0)
   DECLARE ddtq_cur_time = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = concat("Finding last ",ddtq_event_name," Event reported.")
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_rdds_event_detail dred
    WHERE dred.dm_rdds_event_log_id IN (
    (SELECT
     drel.dm_rdds_event_log_id
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="REPORTEMAILED"
      AND (drel.cur_environment_id=ddtq_events->target_env_id)
      AND (drel.paired_environment_id=ddtq_events->source_env_id)))
     AND dred.event_detail1_txt="EVENT REPORTED"
     AND dred.event_detail2_txt=ddtq_event_name
    DETAIL
     row + 0
    FOOT REPORT
     ddtq_last_report = cnvtdatetime(max(dred.updt_dt_tm))
    WITH nocounter
   ;end select
   SET ddtq_curqual = curqual
   IF (((curqual=0) OR (ddtq_last_report=0)) )
    SET ddtq_last_report = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
   SET ddtq_look_ahead = cnvtlookahead(build(value(ddtq_events->suppression_tm),",H"),
    ddtq_last_report)
   SET ddtq_cur_time = cnvtdatetime(curdate,curtime3)
   IF (cnvtdatetime(ddtq_cur_time) >= cnvtdatetime(ddtq_look_ahead))
    SET dm_err->eproc = concat("Reporting ",ddtq_event_name," recorded post last report e-mailed.")
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     FROM dm_rdds_event_detail dred,
      dm_rdds_event_log drel
     WHERE dred.dm_rdds_event_log_id=drel.dm_rdds_event_log_id
      AND drel.rdds_event_key=cnvtupper(cnvtalphanum(ddtq_event_name))
      AND (drel.cur_environment_id=ddtq_events->target_env_id)
      AND (drel.paired_environment_id=ddtq_events->source_env_id)
      AND drel.event_dt_tm >= cnvtdatetime(ddtq_last_report)
     ORDER BY drel.event_reason
     HEAD drel.event_reason
      ddtq_events->unrprtd_cnt = (ddtq_events->unrprtd_cnt+ 1), stat = alterlist(ddtq_events->qual,
       ddtq_events->unrprtd_cnt), ddtq_events->qual[ddtq_events->unrprtd_cnt].header_ind = 1,
      ddtq_events->qual[ddtq_events->unrprtd_cnt].event_reason = drel.event_reason, ddtq_events->
      qual[ddtq_events->unrprtd_cnt].event_type = ddtq_event_name, ddtq_events->qual[ddtq_events->
      unrprtd_cnt].event_detail1_txt = "EVENT REPORTED",
      ddtq_events->qual[ddtq_events->unrprtd_cnt].event_detail2_txt = ddtq_event_name
     DETAIL
      ddtq_events->unrprtd_cnt = (ddtq_events->unrprtd_cnt+ 1), stat = alterlist(ddtq_events->qual,
       ddtq_events->unrprtd_cnt), ddtq_events->qual[ddtq_events->unrprtd_cnt].event_type =
      ddtq_event_name,
      ddtq_events->qual[ddtq_events->unrprtd_cnt].event = ddtq_event_name, ddtq_events->qual[
      ddtq_events->unrprtd_cnt].event_detail1_txt = dred.event_detail1_txt, ddtq_events->qual[
      ddtq_events->unrprtd_cnt].event_detail2_txt = replace(dred.event_detail2_txt,char(10),char(32)),
      ddtq_events->qual[ddtq_events->unrprtd_cnt].event_reason = drel.event_reason, ddtq_events->
      qual[ddtq_events->unrprtd_cnt].event_detail3_txt = dred.event_detail3_txt
     WITH nocounter
    ;end select
   ENDIF
   RETURN(1)
 END ;Subroutine
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
 DECLARE drrm_determine_source_target(ddst_events=vc(ref)) = i2
 DECLARE drrm_create_link(dcl_reltn_status=vc,dcl_events=vc(ref)) = i2
 DECLARE drrm_get_env_names(dgen_events=vc(ref)) = i2
 DECLARE drrm_get_mail_list(dgml_events=vc(ref),dgml_rec=vc(ref)) = i2
 DECLARE drrm_write_email_events(dwee_event_types=vc,dwee_email_address=vc,dwee_events=vc(ref)) = i2
 SUBROUTINE drrm_determine_source_target(ddst_events)
   DECLARE ddst_source_ind = i2
   DECLARE ddst_target_ind = i2
   SET ddst_source_ind = 0
   SET ddst_target_ind = 0
   SET dm_err->eproc = "Getting current environment's ID."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    b.environment_id
    FROM dm_info a,
     dm_environment b
    PLAN (a
     WHERE a.info_name="DM_ENV_ID"
      AND a.info_domain="DATA MANAGEMENT")
     JOIN (b
     WHERE a.info_number=b.environment_id)
    DETAIL
     ddst_events->cur_env_id = b.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Error: current environment id not found."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Validating if current environment is a target environment in any open events."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    drel.event_reason, drel.paired_environment_id
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.cur_environment_id=ddst_events->cur_env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     drela.cur_environment_id, drela.paired_environment_id, drela.event_reason
     FROM dm_rdds_event_log drela
     WHERE (drela.cur_environment_id=ddst_events->cur_env_id)
      AND drela.rdds_event="End Reference Data Sync"
      AND drela.rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     ddst_events->reltn_source_env_id = drel.paired_environment_id, ddst_events->target_event_name =
     drel.event_reason, ddst_target_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Validating if current environment is a source environment in any open events."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    drel.event_reason, drel.cur_environment_id
    FROM dm_rdds_event_log drel
    WHERE drel.rdds_event="Begin Reference Data Sync"
     AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND (drel.paired_environment_id=ddst_events->cur_env_id)
     AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
    (SELECT
     drela.cur_environment_id, drela.paired_environment_id, drela.event_reason
     FROM dm_rdds_event_log drela
     WHERE (drela.paired_environment_id=ddst_events->cur_env_id)
      AND drela.rdds_event="End Reference Data Sync"
      AND drela.rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     ddst_events->reltn_target_env_id = drel.cur_environment_id, ddst_events->source_event_name =
     drel.event_reason, ddst_source_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (ddst_source_ind=0
    AND ddst_target_ind=0)
    SET ddst_events->reltn_status = "NEITHER"
   ELSEIF (ddst_source_ind=1
    AND ddst_target_ind=0)
    SET ddst_events->reltn_status = "SOURCE"
   ELSEIF (ddst_source_ind=0
    AND ddst_target_ind=1)
    SET ddst_events->reltn_status = "TARGET"
   ELSEIF (ddst_source_ind=1
    AND ddst_target_ind=1)
    SET ddst_events->reltn_status = "BOTH"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_create_link(dcl_reltn_status,dcl_events)
   IF (dcl_reltn_status="SOURCE")
    SET dcl_events->source_env_id = dcl_events->cur_env_id
    SET dcl_events->target_env_id = dcl_events->reltn_target_env_id
   ELSEIF (dcl_reltn_status="TARGET")
    SET dcl_events->source_env_id = dcl_events->reltn_source_env_id
    SET dcl_events->target_env_id = dcl_events->cur_env_id
   ELSEIF (dcl_reltn_status="NEITHER")
    SET dcl_events->source_env_id = 0
    SET dcl_events->target_env_id = dcl_events->cur_env_id
   ELSE
    SET dm_err->eproc = "This relationship is not valid. Exiting DM_RMC_RDDS_MAIL process."
    RETURN(0)
   ENDIF
   SET dcl_events->link_name = trim(cnvtstring(dcl_events->cur_env_id))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_get_env_names(dgen_events,dgen_tgt_only_ind)
   IF (dgen_tgt_only_ind != 1)
    SET dm_err->eproc = "Getting Source environment name."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     de.environment_name
     FROM dm_environment de
     WHERE (de.environment_id=dgen_events->source_env_id)
     DETAIL
      dgen_events->source_env_name = de.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "No environment name found for source environment_id."
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Getting Target environment name."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    de.environment_name
    FROM dm_environment de
    WHERE (de.environment_id=dgen_events->target_env_id)
    DETAIL
     dgen_events->target_env_name = de.environment_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Error encountered while selecting environment name for target."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "No environment name found for target environment_id."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_get_mail_list(dgml_events,dgml_rec)
   SET dgml_rec->address_cnt = 0
   SET dgml_rec->email_address = ""
   SET dm_err->eproc = "Retrieving E-Mail Addresses."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    di.info_name
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=concat("RDDSPREF",dgml_events->link_name)
     AND di.info_char="E-Mail Address"
    DETAIL
     dgml_rec->address_cnt = (dgml_rec->address_cnt+ 1)
     IF ((dgml_rec->address_cnt > 1))
      dgml_rec->email_address = concat(dgml_rec->email_address,", ",di.info_name)
     ELSE
      dgml_rec->email_address = di.info_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "No email addresses found."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrm_write_email_events(dwee_event_types,dwee_email_address,dwee_events)
   DECLARE dwee_event_loop = i4
   DECLARE dwee_write_event_cnt = i4
   DECLARE dwee_subject = c50
   SET dwee_event_loop = 0
   SET dwee_write_event_cnt = 0
   SET dwee_subject = dwee_events->subject_text
   SET dwee_write_event_cnt = (dwee_write_event_cnt+ 1)
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Report E-Mailed"
   SET auto_ver_request->qual[1].cur_environment_id = dwee_events->target_env_id
   SET auto_ver_request->qual[1].paired_environment_id = dwee_events->source_env_id
   SET auto_ver_request->qual[1].event_reason = dwee_event_types
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,dwee_write_event_cnt)
   SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail1_txt = dwee_subject
   SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail2_txt =
   dwee_email_address
   FOR (dwee_event_loop = 1 TO size(dwee_events->qual,5))
     IF ((dwee_events->qual[dwee_event_loop].header_ind=1))
      IF ((dwee_events->qual[dwee_event_loop].event_detail1_txt > ""))
       SET dwee_write_event_cnt = (dwee_write_event_cnt+ 1)
       SET stat = alterlist(auto_ver_request->qual[1].detail_qual,dwee_write_event_cnt)
       SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail1_txt =
       dwee_events->qual[dwee_event_loop].event_detail1_txt
       IF ((dwee_events->qual[dwee_event_loop].event_type="Auto-Cutover Error"))
        SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail2_txt =
        dwee_events->qual[dwee_event_loop].event_type
       ELSE
        SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_detail2_txt =
        dwee_events->qual[dwee_event_loop].event_detail2_txt
       ENDIF
       SET auto_ver_request->qual[1].detail_qual[dwee_write_event_cnt].event_value = dwee_events->
       qual[dwee_event_loop].event_value
      ENDIF
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Executing DM_RMC_AUTO_VERIFY_SETUP."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   EXECUTE dm_rmc_auto_verify_setup
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 DECLARE cutover_tab_name(i_normal_tab_name=vc,i_table_suffix=vc) = vc
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE cutover_tab_name(i_normal_tab_name,i_table_suffix)
   DECLARE s_new_tab_name = vc WITH protect
   DECLARE s_tab_suffix = vc WITH protect
   DECLARE s_lv_num = i4 WITH protect
   DECLARE s_lv_pos = i4 WITH protect
   IF (i_table_suffix > " ")
    SET s_tab_suffix = i_table_suffix
    SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
   ELSE
    SET s_lv_pos = locateval(s_lv_num,1,size(table_data->qual,5),i_normal_tab_name,table_data->qual[
     s_lv_num].table_name)
    IF (s_lv_pos > 0)
     SET s_tab_suffix = table_data->qual[s_lv_pos].table_suffix
     SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
    ELSE
     SELECT INTO "nl:"
      FROM dm_rdds_tbl_doc dtd
      WHERE dtd.table_name=i_normal_tab_name
       AND dtd.table_name=dtd.full_table_name
      HEAD REPORT
       stat = alterlist(table_data->qual,(table_data->counter+ 1)), table_data->counter = size(
        table_data->qual,5)
      DETAIL
       table_data->qual[table_data->counter].table_name = dtd.table_name, table_data->qual[table_data
       ->counter].table_suffix = dtd.table_suffix, s_new_tab_name = concat(trim(substring(1,14,
          i_normal_tab_name)),dtd.table_suffix,"$R")
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(s_new_tab_name)
 END ;Subroutine
 DECLARE add_tracking_row(i_source_id=f8,i_refchg_type=vc,i_refchg_status=vc) = null
 DECLARE delete_tracking_row(null) = null
 DECLARE move_long(i_from_table=vc,i_to_table=vc,i_column_name=vc,i_pk_str=vc,i_source_env_id=f8,
  i_status_flag=i4) = null
 DECLARE get_reg_tab_name(i_r_tab_name=vc,i_suffix=vc) = vc
 DECLARE dcc_find_val(i_delim_str=vc,i_delim_val=vc,i_val_rec=vc(ref)) = i2
 DECLARE move_circ_long(i_from_table=vc,i_from_rtable=vc,i_from_pk=vc,i_from_prev_pk=vc,i_from_fk=vc,
  i_from_pe_col=vc,i_circ_table=vc,i_circ_column_name=vc,i_circ_fk_col=vc,i_circ_long_col=vc,
  i_source_env_id=f8,i_status_flag=i4) = null
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE add_tracking_row(i_source_id,i_refchg_type,i_refchg_status)
   DECLARE var_process = vc
   DECLARE var_sid = f8
   DECLARE var_serial_num = f8
   SELECT INTO "nl:"
    process, sid, serial#
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    DETAIL
     var_process = vs.process, var_sid = vs.sid, var_serial_num = vs.serial#
    WITH maxqual(vs,1)
   ;end select
   UPDATE  FROM dm_refchg_process
    SET refchg_type = i_refchg_type, refchg_status = i_refchg_status, last_action_dt_tm = sysdate,
     updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE rdbhandle_value=cnvtreal(currdbhandle)
   ;end update
   COMMIT
   IF (curqual=0)
    INSERT  FROM dm_refchg_process
     SET dm_refchg_process_id = seq(dm_clinical_seq,nextval), env_source_id = i_source_id,
      rdbhandle_value = cnvtreal(currdbhandle),
      process_name = var_process, log_file = dm_err->logfile, last_action_dt_tm = sysdate,
      refchg_type = i_refchg_type, refchg_status = i_refchg_status, updt_cnt = 0,
      updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
      updt_task,
      updt_dt_tm = cnvtdatetime(curdate,curtime3), session_sid = var_sid, serial_number =
      var_serial_num
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_tracking_row(null)
  DELETE  FROM dm_refchg_process
   WHERE rdbhandle_value=cnvtreal(currdbhandle)
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE move_long(i_from_table,i_to_table,i_column_name,i_pk_str,i_source_env_id,i_status_flag)
   RECORD long_col(
     1 data[*]
       2 pk_str = vc
       2 long_str = vc
   )
   SET s_rdds_where_iu_str =
   " rdds_delete_ind = 0 and rdds_source_env_id = i_source_env_id and rdds_status_flag = i_status_flag"
   DECLARE long_str = vc
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_column_name),")"),0)
   CALL parser(concat("        , pk_str=",i_pk_str),0)
   CALL parser(concat("   from ",trim(i_from_table)," l "),0)
   CALL parser(concat(" where ",s_rdds_where_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (long_str = ' ') ",0)
   CALL parser("       long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser("       long_str = notrim(concat(long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser("   long_col->data[long_cnt].pk_str = pk_str",0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(long_str,5)",0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   FOR (lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_to_table)," set ",trim(i_column_name)),0)
     CALL parser("= long_col->data[lc_ndx].long_str where ",0)
     CALL parser(long_col->data[lc_ndx].pk_str,0)
     CALL parser(" go",1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_reg_tab_name(i_r_tab_name,i_suffix)
   DECLARE s_suffix = vc
   DECLARE s_tab_name = vc
   IF (i_suffix > " ")
    SET s_suffix = i_suffix
   ELSE
    SET s_suffix = substring((size(i_r_tab_name) - 5),4,i_r_tab_name)
   ENDIF
   SELECT INTO "nl:"
    dtd.table_name
    FROM dm_rdds_tbl_doc dtd
    WHERE dtd.table_suffix=s_suffix
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     s_tab_name = dtd.table_name
    WITH nocounter
   ;end select
   RETURN(s_tab_name)
 END ;Subroutine
 SUBROUTINE dcc_find_val(i_delim_str,i_delim_val,i_val_rec)
   DECLARE dfv_temp_delim_str = vc WITH constant(concat(i_delim_val,i_delim_str,i_delim_val)),
   protect
   DECLARE dfv_temp_str = vc WITH noconstant(""), protect
   DECLARE dfv_return = i2 WITH noconstant(0), protect
   IF (size(trim(i_delim_str),1) > 0)
    FOR (i = 1 TO i_val_rec->len)
      IF (size(trim(i_val_rec->values[i].str),1) > 0)
       SET dfv_temp_str = concat(i_delim_val,i_val_rec->values[i].str,i_delim_val)
       IF (findstring(dfv_temp_str,dfv_temp_delim_str) > 0)
        SET dfv_return = 1
        RETURN(dfv_return)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(dfv_return)
 END ;Subroutine
 SUBROUTINE move_circ_long(i_from_table,i_from_rtable,i_from_pk,i_from_prev_pk,i_from_fk,
  i_from_pe_col,i_circ_table,i_circ_column_name,i_circ_fk_col,i_circ_long_col,i_source_env_id,
  i_status_flag)
   DECLARE mcl_rdds_iu_str = vc WITH protect, noconstant("")
   DECLARE move_circ_lc_ndx = i4 WITH protect, noconstant(0)
   DECLARE move_circ_long_str = vc WITH protect, noconstant("")
   DECLARE evaluate_pe_name() = c255
   RECORD long_col(
     1 data[*]
       2 long_pk = f8
       2 long_col_fk = f8
       2 long_str = vc
   )
   SET mcl_rdds_iu_str =
   " r.rdds_delete_ind = 0 and r.rdds_source_env_id = i_source_env_id and r.rdds_status_flag = i_status_flag"
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_circ_long_col),")"),0)
   CALL parser(concat("   from ",trim(i_circ_table)," l, ",trim(i_from_table)," t, "),0)
   CALL parser(concat("         ",trim(i_from_rtable)," r "),0)
   CALL parser(concat(" where l.",trim(i_circ_column_name)," = t.",i_from_fk),0)
   CALL parser(concat("    and t.",i_from_pk," = r.",i_from_prev_pk),0)
   CALL parser(concat("    and r.",i_from_pk," != r.",i_from_prev_pk),0)
   IF (i_from_pe_col > "")
    CALL parser(concat("    and evaluate_pe_name('",i_from_table,"', '",i_from_fk,"','",
      i_from_pe_col,"', r.",i_from_pe_col,") = '",i_circ_table,
      "'"),0)
   ENDIF
   CALL parser(concat("    and l.",i_circ_column_name," > 0"),0)
   CALL parser(concat("    and ",mcl_rdds_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   move_circ_long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (move_circ_long_str = ' ') ",0)
   CALL parser("       move_circ_long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser(
    "       move_circ_long_str = notrim(concat(move_circ_long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser(concat("   long_col->data[long_cnt].long_pk = t.",i_from_pk),0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(move_circ_long_str,5)",0)
   CALL parser(concat("   long_col->data[long_cnt].long_col_fk = r.",i_from_fk),0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (move_circ_lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_circ_table)," t set ",trim(i_circ_long_col)),0)
     CALL parser("= long_col->data[move_circ_lc_ndx].long_str where ",0)
     CALL parser(concat("t.",i_circ_column_name," = ",trim(cnvtstring(long_col->data[move_circ_lc_ndx
         ].long_col_fk,20,2))),0)
     CALL parser(" go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(null)
     ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE drrm_check_status_report(dcsr_events=vc(ref)) = i2
 SUBROUTINE drrm_check_status_report(dcsr_events)
   DECLARE dcsr_freq = vc
   DECLARE dcsr_daily_freq_tm = vc
   DECLARE dcsr_format_daily_freq_tm = vc
   DECLARE dcsr_hrly_freq = i4
   DECLARE dcsr_daily_freq = i4
   DECLARE dcsr_hrly_dt_tm = vc
   DECLARE dcsr_last_day = vc
   DECLARE dcsr_last_hour = vc
   DECLARE dcsr_cur_day = vc
   DECLARE dcsr_cnvt_real = i4
   DECLARE dcsr_curqual = i4
   SET dm_err->eproc = "Determining client specified status report frequency."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    di.info_char, di.info_number
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=concat("RDDSPREF",dcsr_events->link_name)
     AND di.info_name="Report Frequency"
    DETAIL
     dcsr_freq = di.info_char, dcsr_daily_freq_tm = cnvtstring(di.info_number)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcsr_events->status_rpt_ind = 0
    SET dm_err->eproc = "No frequency set."
    RETURN(1)
   ENDIF
   IF (dcsr_freq="Hourly")
    SET dm_err->eproc = "Determing last Report Emailed for Status."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="REPORTEMAILED"
      AND drel.event_reason="Status"
      AND (drel.cur_environment_id=dcsr_events->target_env_id)
      AND (drel.paired_environment_id=dcsr_events->source_env_id)
     DETAIL
      row + 0
     FOOT REPORT
      dcsr_hrly_freq = datetimediff(cnvtdatetime(curdate,curtime),max(drel.event_dt_tm),4)
     WITH nocounter
    ;end select
    SET dcsr_curqual = curqual
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
    IF (((dcsr_hrly_freq >= 60) OR (dcsr_curqual=0)) )
     SET stat = alterlist(dcsr_events->qual,1)
     SET dcsr_events->qual[1].event_detail1_txt = "EVENT REPORTED"
     SET dcsr_events->qual[1].event_detail2_txt = "Status"
     SET dcsr_events->qual[1].event_reason = "Status"
     SET dcsr_events->status_rpt_ind = 1
    ELSE
     SET dcsr_events->status_rpt_ind = 0
     RETURN(1)
    ENDIF
   ELSEIF ("Daily")
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event_key="REPORTEMAILED"
      AND drel.event_reason="Status"
      AND (drel.cur_environment_id=dcsr_events->target_env_id)
      AND (drel.paired_environment_id=dcsr_events->source_env_id)
     DETAIL
      row + 0
     FOOT REPORT
      dcsr_daily_freq = datetimediff(cnvtdatetime(curdate,curtime),max(drel.event_dt_tm),3)
     WITH nocounter
    ;end select
    SET dcsr_curqual = curqual
    IF (((dcsr_daily_freq >= 24) OR (dcsr_curqual=0)) )
     SET dcsr_hrly_dt_tm = format(cnvtdatetime(curdate,curtime3),"HH;;M")
     SET dcsr_cnvt_real = cnvtreal(dcsr_hrly_dt_tm)
     SET dcsr_hrly_dt_tm = cnvtstring(dcsr_cnvt_real)
     IF (dcsr_hrly_dt_tm=dcsr_daily_freq_tm)
      SET stat = alterlist(dcsr_events->qual,1)
      SET dcsr_events->qual[1].header_ind = 1
      SET dcsr_events->qual[1].event_detail1_txt = "EVENT REPORTED"
      SET dcsr_events->qual[1].event_detail2_txt = "Status"
      SET dcsr_events->qual[1].event_reason = "Status"
      SET dcsr_events->status_rpt_ind = 1
     ELSE
      SET dcsr_events->status_rpt_ind = 0
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE drrm_generate_status_report(dgsr_events=vc(ref)) = i2
 SUBROUTINE drrm_generate_status_report(dgsr_events)
   FREE RECORD request
   RECORD request(
     1 env_cnt = i4
     1 qual[*]
       2 environment_id = f8
   )
   FREE RECORD dgsr_report
   RECORD dgsr_report(
     1 context_set = vc
     1 context_pull = vc
     1 table_cnt = i4
     1 table_qual[*]
       2 table_name = vc
       2 log_type_cnt = i2
       2 log_cnt[*]
         3 log_type = vc
         3 log_type_sum = i4
     1 log_type_cnt = i4
     1 log_type_qual[*]
       2 log_type = vc
       2 log_type_sum = i4
   )
   DECLARE dgsr_table_idx = i4
   DECLARE dgsr_locate_table = i4
   DECLARE dgsr_log_type_idx = i4
   DECLARE dgsr_locate_type = i4
   DECLARE dgsr_log_type = vc
   DECLARE dgsr_context_cnt = i2
   DECLARE dgsr_table_log_idx = i4
   DECLARE dgsr_locate_tbl_log = i4
   DECLARE clr_log_type = vc
   DECLARE clr_pos = i4
   SET dgsr_table_idx = 0
   SET dgsr_locate_table = 0
   SET dgsr_log_type_idx = 0
   SET dgsr_locate_type = 0
   SET dgsr_log_type = ""
   SET dgsr_context_cnt = 0
   SET dgsr_table_log_idx = 0
   SET dgsr_locate_tbl_log = 0
   SET stat = alterlist(request->qual,1)
   SET request->env_cnt = 1
   SET request->qual[1].environment_id = dgsr_events->target_env_id
   SET dm_err->eproc = "Executing DM_RMC_GET_DCL_INFO."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   EXECUTE dm_rmc_get_dcl_info
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Executing DM_RMC_GET_R_INFO."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   EXECUTE dm_rmc_get_r_info
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Getting Contexts to Pull"
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONTEXT"
     AND di.info_name="CONTEXTS TO PULL"
    DETAIL
     dgsr_report->context_pull = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF ((dgsr_report->context_pull="ALL"))
    SET dm_err->eproc = "Retrieving DM_CHG_LOG context names."
    CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
    SELECT DISTINCT INTO "NL:"
     dcl.context_name
     FROM dm_chg_log dcl
     WHERE (target_env_id=dgsr_events->target_env_id)
     DETAIL
      dgsr_context_cnt = (dgsr_context_cnt+ 1)
      IF (dgsr_context_cnt=1)
       dgsr_report->context_pull = dcl.context_name
      ELSE
       dgsr_report->context_pull = concat(dgsr_report->context_pull,",",dcl.context_name)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieving current Context to Set."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONTEXT"
     AND di.info_name="CONTEXT TO SET"
    DETAIL
     dgsr_report->context_set = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Getting current DM_CHG_LOG data."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    FROM dm_rdds_event_detail d
    WHERE d.dm_rdds_event_log_id IN (
    (SELECT
     el.dm_rdds_event_log_id
     FROM dm_rdds_event_log el
     WHERE (el.cur_environment_id=dgsr_events->source_env_id)
      AND (el.paired_environment_id=dgsr_events->target_env_id)
      AND el.rdds_event_key="DMCHGLOGDATA"))
    ORDER BY d.event_detail2_txt
    DETAIL
     clr_log_type = d.event_detail1_txt, clr_pos = findstring("::",clr_log_type,1,1)
     IF (clr_pos=0)
      dgsr_log_type = substring((clr_pos+ 1),size(clr_log_type),clr_log_type)
     ELSE
      dgsr_log_type = substring((clr_pos+ 2),6,clr_log_type)
     ENDIF
     dgsr_table_idx = locateval(dgsr_locate_table,1,size(dgsr_report->table_qual,5),d
      .event_detail2_txt,dgsr_report->table_qual[dgsr_locate_table].table_name)
     IF (dgsr_table_idx=0)
      dgsr_report->table_cnt = (dgsr_report->table_cnt+ 1), stat = alterlist(dgsr_report->table_qual,
       dgsr_report->table_cnt), dgsr_report->table_qual[dgsr_report->table_cnt].table_name = d
      .event_detail2_txt,
      dgsr_report->table_qual[dgsr_report->table_cnt].log_type_cnt = (dgsr_report->table_qual[
      dgsr_report->table_cnt].log_type_cnt+ 1), stat = alterlist(dgsr_report->table_qual[dgsr_report
       ->table_cnt].log_cnt,dgsr_report->table_qual[dgsr_report->table_cnt].log_type_cnt),
      dgsr_report->table_qual[dgsr_report->table_cnt].log_cnt[dgsr_report->table_qual[dgsr_report->
      table_cnt].log_type_cnt].log_type = dgsr_log_type,
      dgsr_report->table_qual[dgsr_report->table_cnt].log_cnt[dgsr_report->table_qual[dgsr_report->
      table_cnt].log_type_cnt].log_type_sum = d.event_detail_value
     ELSE
      dgsr_table_log_idx = locateval(dgsr_locate_tbl_log,1,size(dgsr_report->table_qual[dgsr_report->
        table_cnt].log_cnt,5),dgsr_log_type,dgsr_report->table_qual[dgsr_report->table_cnt].log_cnt[
       dgsr_locate_tbl_log].log_type)
      IF (dgsr_table_log_idx=0)
       dgsr_report->table_qual[dgsr_report->table_cnt].log_type_cnt = (dgsr_report->table_qual[
       dgsr_report->table_cnt].log_type_cnt+ 1), stat = alterlist(dgsr_report->table_qual[dgsr_report
        ->table_cnt].log_cnt,dgsr_report->table_qual[dgsr_report->table_cnt].log_type_cnt),
       dgsr_report->table_qual[dgsr_report->table_cnt].log_cnt[dgsr_report->table_qual[dgsr_report->
       table_cnt].log_type_cnt].log_type = dgsr_log_type,
       dgsr_report->table_qual[dgsr_report->table_cnt].log_cnt[dgsr_report->table_qual[dgsr_report->
       table_cnt].log_type_cnt].log_type_sum = (dgsr_report->table_qual[dgsr_report->table_cnt].
       log_cnt[dgsr_report->table_qual[dgsr_report->table_cnt].log_type_cnt].log_type_sum+ d
       .event_detail_value)
      ELSE
       dgsr_report->table_qual[dgsr_report->table_cnt].log_cnt[dgsr_table_log_idx].log_type_sum = (
       dgsr_report->table_qual[dgsr_report->table_cnt].log_cnt[dgsr_table_log_idx].log_type_sum+ d
       .event_detail_value)
      ENDIF
     ENDIF
     dgsr_log_type_idx = locateval(dgsr_locate_type,1,size(dgsr_report->log_type_qual,5),
      dgsr_log_type,dgsr_report->log_type_qual[dgsr_locate_type].log_type)
     IF (dgsr_log_type_idx=0)
      dgsr_report->log_type_cnt = (dgsr_report->log_type_cnt+ 1), stat = alterlist(dgsr_report->
       log_type_qual,dgsr_report->log_type_cnt), dgsr_report->log_type_qual[dgsr_report->log_type_cnt
      ].log_type = dgsr_log_type,
      dgsr_report->log_type_qual[dgsr_report->log_type_cnt].log_type_sum = d.event_detail_value
     ELSE
      dgsr_report->log_type_qual[dgsr_log_type_idx].log_type_sum = (dgsr_report->log_type_qual[
      dgsr_log_type_idx].log_type_sum+ d.event_detail_value)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Creating DM_CHG_LOG summary report."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO dgsr_events->file_name
    subject_text = dgsr_report->log_type_qual[d.seq].log_type, text_line = dgsr_report->
    log_type_qual[d.seq].log_type_sum
    FROM (dummyt d  WITH seq = size(dgsr_report->log_type_qual,5))
    HEAD REPORT
     row + 1, col 2, "Source: ",
     col 10, dgsr_events->source_env_name, col 24,
     "(", col 25, dgsr_events->source_env_id,
     col 40, ")", row + 1,
     col 2, "Target: ", col 10,
     dgsr_events->target_env_name, col 24, "(",
     col 25, dgsr_events->target_env_id, col 40,
     ")", row + 1, col 2,
     "Contexts to Pull: ", col 20, dgsr_report->context_pull,
     row + 1, col 2, "Contexts to Set: ",
     col 20, dgsr_report->context_set, row + 1,
     col 2, "RDDS Event: ", col 19,
     dgsr_events->source_event_name, row + 1, col 1,
     "-----------------------------------------------------------------", row + 1, col 20,
     "SUMMARY COUNTS", row + 1, col 1,
     "-----------------------------------------------------------------", col 5, "Log Type",
     col 41, "Count"
    DETAIL
     row + 1, col 5, dgsr_report->log_type_qual[d.seq].log_type,
     col 35, dgsr_report->log_type_qual[d.seq].log_type_sum
    WITH append, formfeed = none, format = variable,
     maxrow = 1, nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Creating DM_CHG_LOG detailed report."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SELECT INTO dgsr_events->file_name
    FROM (dummyt d  WITH seq = size(dgsr_report->table_qual,5))
    HEAD REPORT
     row + 1, col 1, "-----------------------------------------------------------------",
     row + 1, col 20, "DETAILED COUNTS",
     row + 1, col 1, "-----Table Name-------------------Log Type------------------Count"
    DETAIL
     FOR (i = 1 TO size(dgsr_report->table_qual[d.seq].log_cnt,5))
       row + 1, col 5, dgsr_report->table_qual[d.seq].table_name,
       col 40, dgsr_report->table_qual[d.seq].log_cnt[i].log_type, col 55,
       dgsr_report->table_qual[d.seq].log_cnt[i].log_type_sum
     ENDFOR
    WITH append, formfeed = none, format = variable,
     maxrow = 1, nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (check_logfile("dm_rmc_rdds_mail",".log","DM_RMC_RDDS MAIL logfile")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_drrm
 ENDIF
 DECLARE drrm_event_loop = i4
 DECLARE drrm_events_loop = i4
 DECLARE drrm_msg_codifier = i4
 DECLARE idx = i4
 SET drrm_email_address->address_cnt = 0
 SET drrm_events->unrprtd_cnt = 0
 SET drrm_event_loop = 0
 SET drrm_events_loop = 0
 SET dm_err->eproc =
 "Determining if current environment is a source, target or both in any open RDDS events."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_determine_source_target(drrm_events)=0)
  SET dm_err->eproc =
  "Error encountered while determining if current environment is source or target in the current open event."
  GO TO exit_drrm
 ENDIF
 IF ((((drrm_events->reltn_status="SOURCE")) OR ((drrm_events->reltn_status="BOTH"))) )
  SET dm_err->eproc = "Setting relative source and target environment_id's based on open events."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_create_link("SOURCE",drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Getting environment names for relative source and target environment_id's."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_get_env_names(drrm_events,0)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Getting list of email addresses."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_get_mail_list(drrm_events,drrm_email_address)=0)
   GO TO exit_drrm
  ENDIF
  SET stat = alterlist(drrm_event_types->qual,1)
  SET drrm_event_types->det_size = 1
  SET drrm_event_types->qual[1].event_type = "Status"
 ENDIF
 SET dm_err->eproc = "Resetting to write reports as a target environment."
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((drrm_events->reltn_status="BOTH"))
  SET stat = alterlist(drrm_events->qual,0)
  SET drrm_events->unrprtd_cnt = 0
  FREE RECORD drrm_event_types
  RECORD drrm_event_types(
    1 det_size = i4
    1 qual[*]
      2 event_type = vc
  )
  SET drrm_events_loop = 0
  SET drrm_event_loop = 0
 ENDIF
 IF ((((drrm_events->reltn_status="TARGET")) OR ((drrm_events->reltn_status="BOTH"))) )
  SET stat = alterlist(drrm_event_types->qual,5)
  SET drrm_event_types->det_size = 5
  SET drrm_event_types->qual[1].event_type = "Orphaned Mover"
  SET drrm_event_types->qual[2].event_type = "Stale Mover"
  SET drrm_event_types->qual[3].event_type = "Auto-Cutover Error"
  SET drrm_event_types->qual[4].event_type = "Unprocessed $R Resets"
  SET drrm_event_types->qual[5].event_type = "Auto Cutover Dual Build Issues"
  SET dm_err->eproc = "Setting relative source and target environment_id's based on open events."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_create_link("TARGET",drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Getting environment names for relative source and target environment_id's."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_get_env_names(drrm_events,0)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Retrieving suppression duration time."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  SELECT INTO "NL:"
   FROM dm2_admin_dm_info di
   WHERE di.info_domain=concat("RDDSPREF",drrm_events->link_name)
    AND di.info_name="Suppression Duration"
   DETAIL
    drrm_events->suppression_tm = di.info_number
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Creating the email subject."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_create_subject("Warning",drrm_events,0)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Getting list of email addresses."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_get_mail_list(drrm_events,drrm_email_address)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Finding any orphaned movers to report."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_detect_orphan_movers(drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Finding any stale movers to report."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_detect_stale_movers(drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Finding any auto-cutover errors to report."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_detect_auto_cutover_errors(drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Finding any unprocessed and violation $r reset rows to report."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_unprocessed_r_resets(drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  IF ((drrm_events->unrprtd_cnt=0))
   SET dm_err->eproc = "No Warnings to Send."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SET stat = remove(drrm_events->file_name)
  ELSE
   SET dm_err->eproc = "Creating all email text."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SET drrm_msg_codifier = 0
   FOR (drrm_events_loop = 1 TO drrm_event_types->det_size)
     FOR (drrm_event_loop = 1 TO drrm_events->unrprtd_cnt)
       IF ((drrm_event_types->qual[drrm_events_loop].event_type=drrm_events->qual[drrm_event_loop].
       event_type))
        SET drrm_msg_codifier = locateval(idx,1,drrm_event_types->det_size,drrm_events->qual[
         drrm_event_loop].event_type,drrm_event_types->qual[idx].event_type)
        IF (drrm_generate_email_text(drrm_event_loop,drrm_events,drrm_msg_codifier)=0)
         GO TO exit_drrm
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   SET dm_err->eproc = "Generating the file to be sent via email."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   IF (drrm_generate_email_file("Warning",drrm_events)=0)
    GO TO exit_drrm
   ENDIF
   SET dm_err->eproc = "Sending the email."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drrm_send_email(drrm_events->subject_text,drrm_email_address->email_address,drrm_events->
    file_name)=0)
    GO TO exit_drrm
   ENDIF
   SET dm_err->eproc = "Adding events to DM_RDDS_EVENT_LOG for all events reported."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   IF (drrm_write_email_events("Warning",drrm_email_address->email_address,drrm_events)=0)
    GO TO exit_drrm
   ENDIF
  ENDIF
  SET stat = alterlist(drrm_event_types->qual,3)
  SET drrm_event_types->det_size = 3
  SET drrm_event_types->qual[1].event_type = "Move Finished"
  SET drrm_event_types->qual[2].event_type = "Auto-Cutover Started"
  SET drrm_event_types->qual[3].event_type = "Auto-Cutover Finished"
  SET dm_err->eproc = "Finding unreported events for source environment."
  SET drrm_events->unrprtd_cnt = 0
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_determine_unreported("Notification",drrm_event_types,drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Creating the email subject."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_create_subject("Notification",drrm_events,0)=0)
   GO TO exit_drrm
  ENDIF
  SET drrm_event_loop = 0
  SET dm_err->eproc = "Creating all email text."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  SET drrm_msg_codifier = 0
  FOR (drrm_events_loop = 1 TO drrm_event_types->det_size)
    FOR (drrm_event_loop = 1 TO drrm_events->unrprtd_cnt)
     SET drrm_msg_codifier = locateval(idx,1,drrm_event_types->det_size,drrm_events->qual[
      drrm_event_loop].event_type,drrm_event_types->qual[idx].event_type)
     IF (drrm_generate_email_text(drrm_event_loop,drrm_events,drrm_msg_codifier)=0)
      GO TO exit_drrm
     ENDIF
    ENDFOR
  ENDFOR
  IF ((drrm_events->unrprtd_cnt=0))
   SET dm_err->eproc = "No Notifications to Send."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   SET stat = remove(drrm_events->file_name)
  ELSE
   SET dm_err->eproc = "Generating the file to be sent via email."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   IF (drrm_generate_email_file("Notification",drrm_events)=0)
    GO TO exit_drrm
   ENDIF
   SET dm_err->eproc = "Sending the email."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   IF (drrm_send_email(drrm_events->subject_text,drrm_email_address->email_address,drrm_events->
    file_name)=0)
    GO TO exit_drrm
   ENDIF
   SET dm_err->eproc = "Adding events to DM_RDDS_EVENT_LOG for all events reported."
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   IF (drrm_write_email_events("Notification",drrm_email_address->email_address,drrm_events)=0)
    GO TO exit_drrm
   ENDIF
  ENDIF
 ELSE
  SET dm_err->eproc = "No Warnings to Send."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 ENDIF
 SET dm_err->eproc = "Resetting to write reports as an independent environment."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET stat = alterlist(drrm_events->qual,0)
 SET drrm_events->unrprtd_cnt = 0
 FREE RECORD drrm_event_types
 RECORD drrm_event_types(
   1 det_size = i4
   1 qual[*]
     2 event_type = vc
 )
 SET drrm_events_loop = 0
 SET drrm_event_loop = 0
 SET stat = alterlist(drrm_event_types->qual,1)
 SET drrm_event_types->det_size = 1
 SET drrm_event_types->qual[1].event_type = "Task Queue Error"
 SET dm_err->eproc = "Setting relative target environment_id's."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_create_link("NEITHER",drrm_events)=0)
  GO TO exit_drrm
 ENDIF
 SET dm_err->eproc = "Getting environment names for relative target environment_id."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_get_env_names(drrm_events,1)=0)
  GO TO exit_drrm
 ENDIF
 SET dm_err->eproc = "Retrieving suppression duration time."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 SELECT INTO "NL:"
  FROM dm2_admin_dm_info di
  WHERE di.info_domain=concat("RDDSPREF",drrm_events->link_name)
   AND di.info_name="Suppression Duration"
  DETAIL
   drrm_events->suppression_tm = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  GO TO exit_drrm
 ENDIF
 SET dm_err->eproc = "Creating the email subject."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_create_subject("Warning",drrm_events,1)=0)
  GO TO exit_drrm
 ENDIF
 SET dm_err->eproc = "Getting list of email addresses."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_get_mail_list(drrm_events,drrm_email_address)=0)
  GO TO exit_drrm
 ENDIF
 SET dm_err->eproc = "Finding any task queue errors to report."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_detect_warnings(drrm_events,"Task Queue Error")=0)
  GO TO exit_drrm
 ENDIF
 IF ((drrm_events->unrprtd_cnt=0))
  SET dm_err->eproc = "No Warnings to Send."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  SET stat = remove(drrm_events->file_name)
 ELSE
  SET dm_err->eproc = "Creating all email text."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  SET drrm_msg_codifier = 0
  FOR (drrm_events_loop = 1 TO drrm_event_types->det_size)
    FOR (drrm_event_loop = 1 TO drrm_events->unrprtd_cnt)
      IF ((drrm_event_types->qual[drrm_events_loop].event_type=drrm_events->qual[drrm_event_loop].
      event_type))
       SET drrm_msg_codifier = locateval(idx,1,drrm_event_types->det_size,drrm_events->qual[
        drrm_event_loop].event_type,drrm_event_types->qual[idx].event_type)
       IF (drrm_generate_email_text(drrm_event_loop,drrm_events,drrm_msg_codifier)=0)
        GO TO exit_drrm
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  SET dm_err->eproc = "Generating the file to be sent via email."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_generate_email_file("Warning",drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Sending the email."
  CALL disp_msg(" ",dm_err->logfile,0)
  IF (drrm_send_email(drrm_events->subject_text,drrm_email_address->email_address,drrm_events->
   file_name)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Adding events to DM_RDDS_EVENT_LOG for all events reported."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_write_email_events("Warning",drrm_email_address->email_address,drrm_events)=0)
   GO TO exit_drrm
  ENDIF
 ENDIF
 SET stat = alterlist(drrm_event_types->qual,1)
 SET drrm_event_types->det_size = 1
 SET drrm_event_types->qual[1].event_type = "Task Queue Finished"
 SET dm_err->eproc = "Finding unreported events."
 SET drrm_events->unrprtd_cnt = 0
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_determine_unreported("Notification",drrm_event_types,drrm_events)=0)
  GO TO exit_drrm
 ENDIF
 SET dm_err->eproc = "Creating the email subject."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 IF (drrm_create_subject("Notification",drrm_events,1)=0)
  GO TO exit_drrm
 ENDIF
 SET drrm_event_loop = 0
 SET dm_err->eproc = "Creating all email text."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 SET drrm_msg_codifier = 0
 FOR (drrm_events_loop = 1 TO drrm_event_types->det_size)
   FOR (drrm_event_loop = 1 TO drrm_events->unrprtd_cnt)
    SET drrm_msg_codifier = locateval(idx,1,drrm_event_types->det_size,drrm_events->qual[
     drrm_event_loop].event_type,drrm_event_types->qual[idx].event_type)
    IF (drrm_generate_email_text(drrm_event_loop,drrm_events,drrm_msg_codifier)=0)
     GO TO exit_drrm
    ENDIF
   ENDFOR
 ENDFOR
 IF ((drrm_events->unrprtd_cnt=0))
  SET dm_err->eproc = "No Notifications to Send."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  SET stat = remove(drrm_events->file_name)
 ELSE
  SET dm_err->eproc = "Generating the file to be sent via email."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_generate_email_file("Notification",drrm_events)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Sending the email."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_send_email(drrm_events->subject_text,drrm_email_address->email_address,drrm_events->
   file_name)=0)
   GO TO exit_drrm
  ENDIF
  SET dm_err->eproc = "Adding events to DM_RDDS_EVENT_LOG for all events reported."
  CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
  IF (drrm_write_email_events("Notification",drrm_email_address->email_address,drrm_events)=0)
   GO TO exit_drrm
  ENDIF
 ENDIF
 SET dm_err->eproc = "Ending DM_RMC_RDDS_MAIL Process."
#exit_drrm
 IF ((dm_err->err_ind=1))
  IF ((drrm_events->file_name > ""))
   SET stat = remove(drrm_events->file_name)
  ENDIF
 ENDIF
 CALL final_disp_msg("dm_rmc_rdds_mail")
 FREE RECORD drrm_events
 FREE RECORD drrm_event_types
 FREE RECORD drrm_email_address
END GO
