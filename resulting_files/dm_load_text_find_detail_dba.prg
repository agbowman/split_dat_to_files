CREATE PROGRAM dm_load_text_find_detail:dba
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
   FROM dm2_dba_tab_columns dutc,
    dtable dt
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.table_name=dt.table_name
    AND dutc.owner=value(currdbuser)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual=0)
    RETURN("N")
   ELSE
    RETURN("F")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_table_and_ccldef_exists(dtace_table_name,dtace_found_ind)
   SELECT INTO "nl:"
    FROM dm2_dba_tab_cols dutc,
     dtable dt
    WHERE dutc.table_name=trim(cnvtupper(dtace_table_name))
     AND dutc.table_name=dt.table_name
     AND dutc.owner=value(currdbuser)
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking if ",trim(cnvtupper(dtace_table_name)),
     " table and ccl def exists"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (curqual=0)
     SET dtace_found_ind = 0
    ELSE
     SET dtace_found_ind = 1
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
 DECLARE oracle_opt = vc WITH protect, noconstant("")
 DECLARE exact_cnt = i4 WITH protect, noconstant(0)
 DECLARE tot_cnt = i4 WITH protect, noconstant(0)
 DECLARE alt_cnt = i4 WITH protect, noconstant(0)
 DECLARE pre_cnt = i4 WITH protect, noconstant(0)
 DECLARE long_cnt = i4 WITH protect, noconstant(0)
 DECLARE pre_long_cnt = i4 WITH protect, noconstant(0)
 DECLARE a_s_cd = f8 WITH protect, noconstant(0.0)
 DECLARE icd_nom_tag = f8 WITH protect, noconstant(0.0)
 DECLARE diag_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE dx_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE def_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE icd_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE pre_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE prea_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE pres_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE pret_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE rec_71_tag = vc WITH protect, noconstant("0.0")
 DECLARE icd_ord_tag = f8 WITH protect, noconstant(0.0)
 DECLARE icd_accn_tag = f8 WITH protect, noconstant(0.0)
 DECLARE icd_plan_tag = f8 WITH protect, noconstant(0.0)
 DECLARE icd_charge_tag = f8 WITH protect, noconstant(0.0)
 DECLARE rad_cd_tag = f8 WITH protect, noconstant(0.0)
 DECLARE ep_pnote_tag = f8 WITH protect, noconstant(0.0)
 DECLARE prmicd_tag = f8 WITH protect, noconstant(0.0)
 DECLARE charge_drop_tag = f8 WITH protect, noconstant(0.0)
 DECLARE desc_tag_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dt_tm_tag = vc WITH protect, noconstant("")
 DECLARE encntr_exclude_tag = vc WITH protect, noconstant("")
 DECLARE ord_stat_cdf_list = vc WITH protect, noconstant("")
 DECLARE ord_stat_list = vc WITH protect, noconstant("")
 DECLARE oef_icd_col = vc WITH protect, noconstant("")
 FREE RECORD rs_exist
 RECORD rs_exist(
   1 cnt = i4
   1 qual[*]
     2 is_there = i2
     2 lt_is_there = i2
     2 d_meaning = vc
     2 f_name_key = vc
     2 dm_text_find_id = f8
     2 d_type_flag = i4
     2 d_script_name = vc
     2 active_ind = i2
     2 d_description = vc
     2 frequency = i4
     2 l_text = vc
     2 dm_text_find_detail_id = f8
     2 long_text_id = f8
     2 multi_node_ind = i2
 )
 FREE RECORD rs_gen_terms
 RECORD rs_gen_terms(
   1 cnt = i4
   1 qual[*]
     2 term_str = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Starting Readme..."
 IF (check_logfile("dm_load_text_det",".log","DM_LOAD_TEXT_FIND_DETAIL LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET readme_data->status = "F"
  SET readme_data->message = "Unable to Create Log File"
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Starting dm_load_text_find_detail..."
 CALL disp_msg("",dm_err->logfile,0)
 IF (findfile("cer_install:dm_text_find_detail.csv")=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Cannot find dm_text_find.csv in CER_INSTALL."
  SET dm_err->emsg = "Cannot find dm_text_find.csv in CER_INSTALL."
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET tot_cnt = value(size(requestin->list_0,5))
 IF (tot_cnt > 0)
  SELECT INTO "NL:"
   FROM v$parameter v
   WHERE v.name="optimizer_mode"
   DETAIL
    oracle_opt = cnvtupper(v.value)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE"
    AND c.active_ind=1
   DETAIL
    a_s_cd = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=23549
    AND active_ind=1
    AND cdf_meaning IN ("ORDERICD9", "ACCNICD9", "PLANICD9", "CHARGEICD9")
   DETAIL
    IF (c.cdf_meaning="ORDERICD9")
     icd_ord_tag = c.code_value
    ELSEIF (c.cdf_meaning="ACCNICD9")
     icd_accn_tag = c.code_value
    ELSEIF (c.cdf_meaning="PLANICD9")
     icd_plan_tag = c.code_value
    ELSE
     icd_charge_tag = c.code_value
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=400
    AND c.cdf_meaning="ICD9"
    AND c.active_ind=1
   DETAIL
    icd_nom_tag = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=14413
    AND active_ind=1
    AND cdf_meaning="DIAGNOSIS"
   DETAIL
    diag_pnote_tag = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=14709
    AND active_ind=1
    AND cdf_meaning IN ("DX NOMEN", "DEF")
   DETAIL
    IF (c.cdf_meaning="DX NOMEN")
     dx_pnote_tag = c.code_value
    ELSE
     def_pnote_tag = c.code_value
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=12100
    AND c.cdf_meaning="ICD9CM"
    AND c.active_ind=1
   DETAIL
    icd_pnote_tag = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=6000
    AND c.cdf_meaning="RADIOLOGY"
    AND c.active_ind=1
   DETAIL
    rad_cd_tag = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=15749
    AND active_ind=1
    AND cdf_meaning IN ("PRE", "PREPARA", "PRETERM", "PRESENT")
   DETAIL
    IF (c.cdf_meaning="PRE")
     pre_pnote_tag = c.code_value
    ELSEIF (c.cdf_meaning="PREPARA")
     prea_pnote_tag = c.code_value
    ELSEIF (c.cdf_meaning="PRETERM")
     pret_pnote_tag = c.code_value
    ELSE
     pres_pnote_tag = c.code_value
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE active_ind=1
    AND code_set=71
    AND cdf_meaning="RECURRING"
   DETAIL
    IF (rec_71_tag="0.0")
     rec_71_tag = trim(cnvtstring(c.code_value,20,1))
    ELSE
     rec_71_tag = concat(rec_71_tag,",",trim(cnvtstring(c.code_value,20,1)))
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=14409
    AND cdf_meaning="EP"
    AND active_ind=1
   DETAIL
    ep_pnote_tag = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=16162
    AND cdf_meaning="PFTCHRGDROP"
    AND active_ind=1
   DETAIL
    charge_drop_tag = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=16160
    AND cdf_meaning="D_PRMICD9CD"
    AND active_ind=1
   DETAIL
    prmicd_tag = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE code_set=11000
    AND cdf_meaning="DESC"
    AND active_ind=1
   DETAIL
    desc_tag_cd = c.code_value
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF (curutc=0)
   SET dt_tm_tag = "SYSDATE"
  ELSE
   SET dt_tm_tag = "SYS_EXTRACT_UTC(SYSTIMESTAMP)"
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE c.code_set=261
    AND c.active_ind=1
    AND c.cdf_meaning IN ("CANCELLED", "DISCHARGED")
   DETAIL
    IF (encntr_exclude_tag <= " ")
     encntr_exclude_tag = trim(cnvtstring(c.code_value,20,2))
    ELSE
     encntr_exclude_tag = concat(encntr_exclude_tag,", ",trim(cnvtstring(c.code_value,20,2)))
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM dm_info d
   WHERE d.info_domain="DM_TEXT_FIND_CONFIGURATIONS:ORDER_STATUS"
   DETAIL
    IF (ord_stat_cdf_list <= " ")
     ord_stat_cdf_list = concat("'",trim(d.info_name),"'")
    ELSE
     ord_stat_cdf_list = concat(ord_stat_cdf_list,",'",trim(d.info_name),"'")
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET ord_stat_cdf_list =
   "'CANCELED','COMPLETED','DISCONTINUED','TRANS/CANCEL','VOIDEDWRSLT','DELETED'"
  ENDIF
  SELECT INTO "NL:"
   FROM code_value c
   WHERE c.code_set=6004
    AND c.active_ind=1
    AND parser(concat(" c.cdf_meaning not in (",ord_stat_cdf_list,")"))
   DETAIL
    IF (ord_stat_list <= " ")
     ord_stat_list = trim(cnvtstring(c.code_value,20,2))
    ELSE
     ord_stat_list = concat(ord_stat_list,",",trim(cnvtstring(c.code_value,20,2)))
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "No ORDER_STATUS_CD values found to query on for FUT_ORDERS ICD9 report."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET rs_gen_terms->cnt = 1
  SET stat = alterlist(rs_gen_terms->qual,1)
  SET rs_gen_terms->qual[1].term_str = "decode(instr(upper(oeff.label_text),'ICD 9'),0,"
  SELECT INTO "NL:"
   FROM dm_text_find_query d
   WHERE query_group_name="ICD9_TERM"
    AND active_ind=1
   HEAD REPORT
    oef_icd_col = ""
   DETAIL
    rs_gen_terms->cnt = (rs_gen_terms->cnt+ 1), stat = alterlist(rs_gen_terms->qual,rs_gen_terms->cnt
     ), rs_gen_terms->qual[rs_gen_terms->cnt].term_str = concat(
     "decode(instr(upper(oeff.label_text),'",trim(d.query_col_name),"'),0,")
   FOOT REPORT
    FOR (alt_cnt = 1 TO rs_gen_terms->cnt)
      IF (alt_cnt=1)
       oef_icd_col = concat(rs_gen_terms->qual[alt_cnt].term_str,"'NO','YES')")
      ELSE
       oef_icd_col = concat(rs_gen_terms->qual[alt_cnt].term_str,oef_icd_col,", 'YES')")
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF ((rs_gen_terms->cnt=0))
   SET oef_icd_col = "'N/A'"
  ENDIF
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_cnt)
   PLAN (d)
   DETAIL
    IF (oracle_opt="RULE"
     AND (requestin->list_0[d.seq].optimizer IN ("RULE", "ALL")))
     rs_exist->cnt = (rs_exist->cnt+ 1), stat = alterlist(rs_exist->qual,rs_exist->cnt), rs_exist->
     qual[rs_exist->cnt].f_name_key = cnvtupper(cnvtalphanum(requestin->list_0[d.seq].f_name)),
     rs_exist->qual[rs_exist->cnt].d_meaning = requestin->list_0[d.seq].d_meaning, rs_exist->qual[
     rs_exist->cnt].d_type_flag = cnvtint(requestin->list_0[d.seq].d_type_flag), rs_exist->qual[
     rs_exist->cnt].active_ind = cnvtint(requestin->list_0[d.seq].active_ind),
     rs_exist->qual[rs_exist->cnt].d_script_name = requestin->list_0[d.seq].d_script_name, rs_exist->
     qual[rs_exist->cnt].d_description = requestin->list_0[d.seq].d_description, rs_exist->qual[
     rs_exist->cnt].frequency = cnvtint(requestin->list_0[d.seq].frequency),
     rs_exist->qual[rs_exist->cnt].l_text = requestin->list_0[d.seq].l_text, rs_exist->qual[rs_exist
     ->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<ICD_NOM_TAG>",trim(cnvtstring(
        icd_nom_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist
      ->cnt].l_text,"<DIAG_PNOTE_TAG>",trim(cnvtstring(diag_pnote_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<DX_PNOTE_TAG>",trim(cnvtstring(dx_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text
      = replace(rs_exist->qual[rs_exist->cnt].l_text,"<DEF_PNOTE_TAG>",trim(cnvtstring(def_pnote_tag,
        20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].
      l_text,"<ICD_PNOTE_TAG>",trim(cnvtstring(icd_pnote_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<PRE_PNOTE_TAG>",trim(cnvtstring(pre_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text
      = replace(rs_exist->qual[rs_exist->cnt].l_text,"<PREA_PNOTE_TAG>",trim(cnvtstring(
        prea_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[
      rs_exist->cnt].l_text,"<PRES_PNOTE_TAG>",trim(cnvtstring(pres_pnote_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<PRET_PNOTE_TAG>",trim(cnvtstring(pret_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].
     l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<EP_PNOTE_TAG>",trim(cnvtstring(
        ep_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[
      rs_exist->cnt].l_text,"<REC_71_TAG>",rec_71_tag,0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ICD_ORD_TAG>",trim(cnvtstring(icd_ord_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text =
     replace(rs_exist->qual[rs_exist->cnt].l_text,"<ICD_ACCN_TAG>",trim(cnvtstring(icd_accn_tag,20,1)
       ),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ICD_PLAN_TAG>",trim(cnvtstring(icd_plan_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ICD_CHARGE_TAG>",trim(cnvtstring(icd_charge_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].
     l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<RAD_CD_TAG>",trim(cnvtstring(rad_cd_tag,
        20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].
      l_text,"<CHARGE_DROP_TAG>",trim(cnvtstring(charge_drop_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<PRMICD9CD_TAG>",trim(cnvtstring(prmicd_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text =
     replace(rs_exist->qual[rs_exist->cnt].l_text,"<DESC_TAG_CD>",trim(cnvtstring(desc_tag_cd,20,1)),
      0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<DT_TM_TAG>",dt_tm_tag,0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ENCNTR_EXCLUDE_TAG>",encntr_exclude_tag,0), rs_exist->qual[rs_exist->cnt].l_text = replace(
      rs_exist->qual[rs_exist->cnt].l_text,"<ORD_STAT_LIST>",ord_stat_list,0), rs_exist->qual[
     rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<OEF_ICD_COL>",oef_icd_col,
      0)
     IF ((rs_exist->qual[rs_exist->cnt].l_text > " "))
      pre_long_cnt = (pre_long_cnt+ 1)
     ENDIF
     rs_exist->qual[rs_exist->cnt].multi_node_ind = cnvtint(requestin->list_0[d.seq].multi_node_ind)
    ELSEIF (oracle_opt != "RULE"
     AND (requestin->list_0[d.seq].optimizer IN ("COST", "ALL")))
     rs_exist->cnt = (rs_exist->cnt+ 1), stat = alterlist(rs_exist->qual,rs_exist->cnt), rs_exist->
     qual[rs_exist->cnt].f_name_key = cnvtupper(cnvtalphanum(requestin->list_0[d.seq].f_name)),
     rs_exist->qual[rs_exist->cnt].d_meaning = requestin->list_0[d.seq].d_meaning, rs_exist->qual[
     rs_exist->cnt].d_type_flag = cnvtint(requestin->list_0[d.seq].d_type_flag), rs_exist->qual[
     rs_exist->cnt].active_ind = cnvtint(requestin->list_0[d.seq].active_ind),
     rs_exist->qual[rs_exist->cnt].d_script_name = requestin->list_0[d.seq].d_script_name, rs_exist->
     qual[rs_exist->cnt].d_description = requestin->list_0[d.seq].d_description, rs_exist->qual[
     rs_exist->cnt].frequency = cnvtint(requestin->list_0[d.seq].frequency),
     rs_exist->qual[rs_exist->cnt].l_text = requestin->list_0[d.seq].l_text, rs_exist->qual[rs_exist
     ->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<ICD_NOM_TAG>",trim(cnvtstring(
        icd_nom_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist
      ->cnt].l_text,"<DIAG_PNOTE_TAG>",trim(cnvtstring(diag_pnote_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<DX_PNOTE_TAG>",trim(cnvtstring(dx_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text
      = replace(rs_exist->qual[rs_exist->cnt].l_text,"<DEF_PNOTE_TAG>",trim(cnvtstring(def_pnote_tag,
        20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].
      l_text,"<ICD_PNOTE_TAG>",trim(cnvtstring(icd_pnote_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<PRE_PNOTE_TAG>",trim(cnvtstring(pre_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text
      = replace(rs_exist->qual[rs_exist->cnt].l_text,"<PREA_PNOTE_TAG>",trim(cnvtstring(
        prea_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[
      rs_exist->cnt].l_text,"<PRES_PNOTE_TAG>",trim(cnvtstring(pres_pnote_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<PRET_PNOTE_TAG>",trim(cnvtstring(pret_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].
     l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<EP_PNOTE_TAG>",trim(cnvtstring(
        ep_pnote_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[
      rs_exist->cnt].l_text,"<REC_71_TAG>",rec_71_tag,0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ICD_ORD_TAG>",trim(cnvtstring(icd_ord_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text =
     replace(rs_exist->qual[rs_exist->cnt].l_text,"<ICD_ACCN_TAG>",trim(cnvtstring(icd_accn_tag,20,1)
       ),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ICD_PLAN_TAG>",trim(cnvtstring(icd_plan_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ICD_CHARGE_TAG>",trim(cnvtstring(icd_charge_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].
     l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<RAD_CD_TAG>",trim(cnvtstring(rad_cd_tag,
        20,1)),0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].
      l_text,"<CHARGE_DROP_TAG>",trim(cnvtstring(charge_drop_tag,20,1)),0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<PRMICD9CD_TAG>",trim(cnvtstring(prmicd_tag,20,1)),0), rs_exist->qual[rs_exist->cnt].l_text =
     replace(rs_exist->qual[rs_exist->cnt].l_text,"<DESC_TAG_CD>",trim(cnvtstring(desc_tag_cd,20,1)),
      0), rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<DT_TM_TAG>",dt_tm_tag,0),
     rs_exist->qual[rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,
      "<ENCNTR_EXCLUDE_TAG>",encntr_exclude_tag,0), rs_exist->qual[rs_exist->cnt].l_text = replace(
      rs_exist->qual[rs_exist->cnt].l_text,"<ORD_STAT_LIST>",ord_stat_list,0), rs_exist->qual[
     rs_exist->cnt].l_text = replace(rs_exist->qual[rs_exist->cnt].l_text,"<OEF_ICD_COL>",oef_icd_col,
      0)
     IF ((rs_exist->qual[rs_exist->cnt].l_text > " "))
      pre_long_cnt = (pre_long_cnt+ 1)
     ENDIF
     rs_exist->qual[rs_exist->cnt].multi_node_ind = cnvtint(requestin->list_0[d.seq].multi_node_ind)
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET exact_cnt = rs_exist->cnt
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = rs_exist->cnt),
    dm_text_find df
   PLAN (d)
    JOIN (df
    WHERE (df.find_name_key=rs_exist->qual[d.seq].f_name_key))
   DETAIL
    rs_exist->qual[d.seq].dm_text_find_id = df.dm_text_find_id, pre_cnt = (pre_cnt+ 1)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rs_exist->cnt),
    dm_text_find_detail df
   PLAN (d
    WHERE (rs_exist->qual[d.seq].dm_text_find_id > 0.0))
    JOIN (df
    WHERE (df.dm_text_find_id=rs_exist->qual[d.seq].dm_text_find_id)
     AND (df.detail_meaning=rs_exist->qual[d.seq].d_meaning))
   DETAIL
    rs_exist->qual[d.seq].is_there = 1, rs_exist->qual[d.seq].dm_text_find_detail_id = df
    .dm_text_find_detail_id, rs_exist->qual[d.seq].long_text_id = df.detail_text_id
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET dm_err->eproc = "Setting LONG_TEXT_ID values"
  CALL disp_msg("",dm_err->logfile,0)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->eproc
  FOR (alt_cnt = 1 TO rs_exist->cnt)
   IF ((rs_exist->qual[alt_cnt].is_there=1))
    IF ((rs_exist->qual[alt_cnt].l_text > " ")
     AND (rs_exist->qual[alt_cnt].long_text_id=0.0))
     SELECT INTO "NL:"
      y = seq(long_data_seq,nextval)
      FROM dual d
      DETAIL
       rs_exist->qual[alt_cnt].long_text_id = y
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ELSEIF ((rs_exist->qual[alt_cnt].l_text <= " "))
     SET rs_exist->qual[alt_cnt].long_text_id = 0
    ENDIF
   ENDIF
   IF ((rs_exist->qual[alt_cnt].is_there=0)
    AND (rs_exist->qual[alt_cnt].dm_text_find_id > 0.0))
    SELECT INTO "NL:"
     y = seq(dm_clinical_seq,nextval)
     FROM dual d
     DETAIL
      rs_exist->qual[alt_cnt].dm_text_find_detail_id = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF ((rs_exist->qual[alt_cnt].l_text > " "))
     SELECT INTO "NL:"
      y = seq(long_data_seq,nextval)
      FROM dual d
      DETAIL
       rs_exist->qual[alt_cnt].long_text_id = y
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ELSE
     SET rs_exist->qual[alt_cnt].long_text_id = 0
    ENDIF
   ENDIF
  ENDFOR
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rs_exist->cnt),
    long_text_reference l
   PLAN (d
    WHERE (rs_exist->qual[d.seq].long_text_id > 0.0))
    JOIN (l
    WHERE (l.long_text_id=rs_exist->qual[d.seq].long_text_id))
   DETAIL
    rs_exist->qual[d.seq].lt_is_there = 1
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET dm_err->eproc = "Updating data in LONG_TEXT_REFERENCE"
  CALL disp_msg("",dm_err->logfile,0)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->eproc
  UPDATE  FROM long_text_reference l,
    (dummyt d  WITH seq = rs_exist->cnt)
   SET l.long_text = rs_exist->qual[d.seq].l_text, l.updt_id = reqinfo->updt_id, l.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    l.updt_applctx = reqinfo->updt_applctx, l.updt_task = reqinfo->updt_task, l.updt_cnt = (l
    .updt_cnt+ 1)
   PLAN (d
    WHERE (rs_exist->qual[d.seq].lt_is_there=1))
    JOIN (l
    WHERE (l.long_text_id=rs_exist->qual[d.seq].long_text_id))
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET dm_err->eproc = "Inserting data into long_text_reference"
  CALL disp_msg("",dm_err->logfile,0)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->eproc
  INSERT  FROM long_text_reference l,
    (dummyt d  WITH seq = rs_exist->cnt)
   SET l.long_text_id = rs_exist->qual[d.seq].long_text_id, l.parent_entity_name =
    "DM_TEXT_FIND_DETAIL", l.parent_entity_id = rs_exist->qual[d.seq].dm_text_find_detail_id,
    l.long_text = rs_exist->qual[d.seq].l_text, l.active_ind = 1, l.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_cd = a_s_cd, l.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    l.updt_id = reqinfo->updt_id, l.updt_applctx = reqinfo->updt_applctx, l.updt_task = reqinfo->
    updt_task
   PLAN (d
    WHERE (rs_exist->qual[d.seq].lt_is_there=0)
     AND (rs_exist->qual[d.seq].long_text_id > 0.0))
    JOIN (l
    WHERE (l.long_text_id=rs_exist->qual[d.seq].long_text_id))
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET dm_err->eproc = "Updating data in DM_TEXT_FIND_DETAIL"
  CALL disp_msg("",dm_err->logfile,0)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->eproc
  UPDATE  FROM dm_text_find_detail df,
    (dummyt d  WITH seq = rs_exist->cnt)
   SET df.detail_text_id = rs_exist->qual[d.seq].long_text_id, df.frequency = rs_exist->qual[d.seq].
    frequency, df.detail_description = rs_exist->qual[d.seq].d_description,
    df.detail_script_name = rs_exist->qual[d.seq].d_script_name, df.detail_type_flag = rs_exist->
    qual[d.seq].d_type_flag, df.multi_node_ind = rs_exist->qual[d.seq].multi_node_ind,
    df.updt_id = reqinfo->updt_id, df.updt_dt_tm = cnvtdatetime(curdate,curtime3), df.updt_applctx =
    reqinfo->updt_applctx,
    df.updt_task = reqinfo->updt_task, df.updt_cnt = (df.updt_cnt+ 1)
   PLAN (d
    WHERE (rs_exist->qual[d.seq].is_there=1))
    JOIN (df
    WHERE (df.dm_text_find_detail_id=rs_exist->qual[d.seq].dm_text_find_detail_id))
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET dm_err->eproc = "Inserting data into dm_text_find_detail"
  CALL disp_msg("",dm_err->logfile,0)
  SET readme_data->status = "F"
  SET readme_data->message = dm_err->eproc
  INSERT  FROM dm_text_find_detail df,
    (dummyt d  WITH seq = rs_exist->cnt)
   SET df.dm_text_find_detail_id = rs_exist->qual[d.seq].dm_text_find_detail_id, df.dm_text_find_id
     = rs_exist->qual[d.seq].dm_text_find_id, df.detail_meaning = rs_exist->qual[d.seq].d_meaning,
    df.detail_type_flag = rs_exist->qual[d.seq].d_type_flag, df.detail_script_name = rs_exist->qual[d
    .seq].d_script_name, df.detail_description = rs_exist->qual[d.seq].d_description,
    df.active_ind = rs_exist->qual[d.seq].active_ind, df.detail_text_id = rs_exist->qual[d.seq].
    long_text_id, df.frequency = rs_exist->qual[d.seq].frequency,
    df.multi_node_ind = rs_exist->qual[d.seq].multi_node_ind, df.updt_id = reqinfo->updt_id, df
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    df.updt_applctx = reqinfo->updt_applctx, df.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (rs_exist->qual[d.seq].is_there=0))
    JOIN (df
    WHERE (df.dm_text_find_detail_id=rs_exist->qual[d.seq].dm_text_find_detail_id))
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message =
  "Readme Failed.  The request structure has not been populated with csv information."
  SET dm_err->emsg =
  "Readme Failed.  The request structure has not been populated with csv information."
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Error loading dm_text_find_detail with info in dm_text_find_Detail.csv."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message =
  "Error loading dm_text_find_detail with info in dm_text_find_Detail.csv."
  GO TO exit_script
 ENDIF
 SET alt_cnt = 0
 SET long_cnt = 0
 SET dm_err->eproc = "Checking data in dm_text_find_detail"
 CALL disp_msg("",dm_err->logfile,0)
 SET readme_data->status = "F"
 SET readme_data->message = dm_err->eproc
 SELECT INTO "nl:"
  FROM dm_text_find_detail df,
   (dummyt d  WITH seq = rs_exist->cnt)
  PLAN (d
   WHERE (rs_exist->qual[d.seq].dm_text_find_id > 0.0))
   JOIN (df
   WHERE (df.dm_text_find_id=rs_exist->qual[d.seq].dm_text_find_id)
    AND (df.dm_text_find_detail_id=rs_exist->qual[d.seq].dm_text_find_detail_id)
    AND (df.detail_meaning=rs_exist->qual[d.seq].d_meaning)
    AND (df.detail_type_flag=rs_exist->qual[d.seq].d_type_flag)
    AND (df.detail_script_name=rs_exist->qual[d.seq].d_script_name)
    AND (df.detail_description=rs_exist->qual[d.seq].d_description)
    AND (df.detail_text_id=rs_exist->qual[d.seq].long_text_id)
    AND (df.frequency=rs_exist->qual[d.seq].frequency)
    AND (df.multi_node_ind=rs_exist->qual[d.seq].multi_node_ind))
  DETAIL
   alt_cnt = (alt_cnt+ 1)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 SELECT INTO "nl:"
  FROM long_text_reference l,
   (dummyt d  WITH seq = rs_exist->cnt)
  PLAN (d
   WHERE (rs_exist->qual[d.seq].dm_text_find_id > 0.0)
    AND (rs_exist->qual[d.seq].long_text_id > 0.0))
   JOIN (l
   WHERE (l.long_text_id=rs_exist->qual[d.seq].long_text_id)
    AND (l.parent_entity_id=rs_exist->qual[d.seq].dm_text_find_detail_id)
    AND l.parent_entity_name="DM_TEXT_FIND_DETAIL")
  DETAIL
   long_cnt = (long_cnt+ 1)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 IF (((pre_cnt != exact_cnt) OR (((alt_cnt != exact_cnt) OR (((long_cnt != pre_long_cnt) OR ((dm_err
 ->err_ind > 0))) )) )) )
  SET readme_data->status = "F"
  IF (pre_cnt != exact_cnt)
   SET readme_data->message = "Check failed. Not all DM_TEXT_FIND_ID FK values found."
  ELSEIF (alt_cnt != exact_cnt)
   SET readme_data->message = "Check failed. Not all rows found in dm_text_find_detail."
  ELSEIF (long_cnt != pre_long_cnt)
   SET readme_data->message = "Check failed. Not all rows found in long_text_reference."
  ELSE
   SET readme_data->message = "Check failed. Rows in request != rows in local dm_text_find_detail."
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
 IF (pre_cnt=exact_cnt
  AND alt_cnt=exact_cnt
  AND long_cnt=pre_long_cnt
  AND (dm_err->err_ind=0))
  SET readme_data->status = "S"
 ENDIF
 IF ((readme_data->status="S"))
  SET readme_data->message = "dm_text_find_detail has been updated successfully."
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
END GO
