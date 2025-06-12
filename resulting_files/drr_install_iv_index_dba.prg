CREATE PROGRAM drr_install_iv_index:dba
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
 DECLARE dm2_set_inhouse_domain() = i2
 DECLARE dm2_get_program_stack(null) = vc
 SUBROUTINE (dm2_push_cmd(sbr_dpcstr=vc,sbr_cmd_end=i2) =i2)
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
 SUBROUTINE (dm2_push_dcl(sbr_dpdstr=vc) =i2)
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
 SUBROUTINE (get_unique_file(sbr_fprefix=vc,sbr_fext=vc) =i2)
   DECLARE guf_return_val = i4 WITH protect, noconstant(1)
   DECLARE fini = i2 WITH protect, noconstant(0)
   DECLARE fname = vc WITH protect
   DECLARE unique_tempstr = vc WITH protect
   WHILE (fini=0)
     IF ((((validate(systimestamp,- (999.00))=- (999.00))
      AND validate(systimestamp,999.00)=999.00) OR (validate(dm2_bypass_unique_file,- (1))=1)) )
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(sysdate),cnvtdatetime(
          curdate,000000)) * 864000)))
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
 SUBROUTINE (parse_errfile(sbr_errfile=vc) =i2)
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
 SUBROUTINE (check_error(sbr_ceprocess=vc) =i2)
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
 SUBROUTINE (disp_msg(sbr_demsg=vc,sbr_dlogfile=vc,sbr_derr_ind=i2) =null)
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
         beg_pos = (end_pos+ 1), end_pos += 132, dm_txt = substring(beg_pos,132,dm_err->eproc)
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
          beg_pos = (end_pos+ 1), end_pos += 132, dm_txt = substring(beg_pos,132,dm_full_emsg)
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
          beg_pos = (end_pos+ 1), end_pos += 132, dm_txt = substring(beg_pos,132,dm_err->user_action)
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
 SUBROUTINE (init_logfile(sbr_logfile=vc,sbr_header_msg=vc) =i2)
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
 SUBROUTINE (check_logfile(sbr_lprefix=vc,sbr_lext=vc,sbr_hmsg=vc) =i2)
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
 SUBROUTINE (final_disp_msg(sbr_log_prefix=vc) =null)
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
 SUBROUTINE (dm2_set_autocommit(sbr_dsa_flag=i2) =i2)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (dm2_prg_maint(sbr_maint_type=vc) =i2)
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
     SET program_stack_rs->cnt += 1
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
 SUBROUTINE (dm2_table_exists(dte_table_name=vc) =c1)
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
 SUBROUTINE (dm2_table_and_ccldef_exists(dtace_table_name=vc,dtace_found_ind=i2(ref)) =i2)
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
 SUBROUTINE (dm2_table_column_exists(dtce_owner=vc,dtce_table_name=vc,dtce_column_name=vc,
  dtce_col_chk_ind=i2,dtce_coldef_chk_ind=i2,dtce_ccldef_mode=i2,dtce_col_fnd_ind=i2(ref),
  dtce_coldef_fnd_ind=i2(ref),dtce_data_type=vc(ref)) =i2)
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
 SUBROUTINE (dm2_disp_file(ddf_fname=vc,ddf_desc=vc) =i2)
   DECLARE ddf_row = i4 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="WIN"))
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL video(n)
    SET ddf_row = 3
    CALL box(1,1,5,132)
    CALL text(ddf_row,48,"***  REPORT GENERATED  ***")
    SET ddf_row += 4
    CALL text(ddf_row,2,"The following report was generated in CCLUSERDIR... ")
    SET ddf_row += 2
    CALL text(ddf_row,5,concat("File Name:   ",trim(ddf_fname)))
    SET ddf_row += 1
    CALL text(ddf_row,5,concat("Description: ",trim(ddf_desc)))
    SET ddf_row += 2
    CALL text(ddf_row,2,"Review report in CCLUSERDIR before continuing.")
    SET ddf_row += 2
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
 IF (validate(cur_sch->tbl_cnt,- (1)) < 0)
  FREE RECORD cur_sch
  RECORD cur_sch(
    1 rdbms = vc
    1 mviews_active_ind = i2
    1 dm_info_exists_ind = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 tbl_name = vc
      2 tspace_name = vc
      2 long_tspace = vc
      2 long_tspace_ni = i2
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 capture_ind = i2
      2 schema_date = dq8
      2 schema_instance = i4
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 row_cnt = f8
      2 ext_mgmt = c1
      2 lext_mgmt = c1
      2 max_ext = f8
      2 reference_ind = i2
      2 mview_flag = i2
      2 mview_exists_ind = i2
      2 mview_syn_status = vc
      2 tbl_col_cnt = i4
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 bytes_allocated = f8
        3 bytes_used = f8
      2 ind_cnt = i4
      2 ind_tspace = vc
      2 ind_tspace_ni = i2
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 tspace_name = vc
        3 tspace_name_ni = i2
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 unique_ind = i2
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_change_ind = i2
        3 ext_mgmt = c1
        3 max_ext = f8
        3 visibility = vc
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 r_constraint_name = vc
        3 orig_r_cons_name = vc
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 fk_cnt = i4
        3 fk[*]
          4 tbl_ndx = i4
          4 cons_ndx = i4
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 pct_increase = f8
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 capture_ind = i2
  )
  SET cur_sch->tbl_cnt = 0
 ENDIF
 IF (validate(tgtsch->tbl_cnt,- (1)) < 0)
  FREE RECORD tgtsch
  RECORD tgtsch(
    1 source_rdbms = vc
    1 schema_date = dq8
    1 alpha_feature_nbr = i4
    1 diff_ind = i2
    1 warn_ind = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 tbl_name = vc
      2 longlob_col_cnt = i4
      2 gtt_flag = i2
      2 last_analyzed_dt_tm = dq8
      2 orig_tbl_name = vc
      2 full_tbl_name = vc
      2 suff_tbl_name = vc
      2 new_ind = i2
      2 diff_ind = i2
      2 warn_ind = i2
      2 combine_ind = i2
      2 reference_ind = i4
      2 child_tbl_ind = i2
      2 tspace_name = vc
      2 cur_idx = i4
      2 row_cnt = f8
      2 cur_bytes_allocated = f8
      2 cur_bytes_used = f8
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 size = f8
      2 ind_size = f8
      2 long_size = f8
      2 total_space = f8
      2 free_space = f8
      2 schema_date = dq8
      2 schema_instance = i4
      2 alpha_feature_nbr = i4
      2 feature_number = i4
      2 updt_dt_tm = dq8
      2 long_tspace = vc
      2 dext_mgmt = c1
      2 iext_mgmt = c1
      2 lext_mgmt = c1
      2 ttspace_new_ind = i2
      2 itspace_new_ind = i2
      2 ltspace_new_ind = i2
      2 table_suffix = vc
      2 logical_rowid_column_ind = i2
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 afd_schema_instance = i4
      2 pull_from_afd = i2
      2 rowid_col_fnd = i2
      2 xrid_ind_fnd = i2
      2 ttsp_set_ind = i2
      2 itsp_set_ind = i2
      2 ltsp_set_ind = i2
      2 new_lob_col_ind = i2
      2 ttspace_assignment_choice = vc
      2 itspace_assignment_choice = vc
      2 ltspace_assignment_choice = vc
      2 tbl_col_cnt = i4
      2 max_ext = f8
      2 ind_rename_cnt = i4
      2 ind_rename[*]
        3 cur_ind_name = vc
        3 temp_ind_name = vc
        3 final_ind_name = vc
        3 drop_cur_ind = i2
        3 drop_temp_ind = i2
        3 rename_cur_ind = i2
        3 rename_temp_ind = i2
        3 cur_ind_tspace_name = vc
        3 cur_ind_idx = i4
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 new_ind = i2
        3 diff_dtype_ind = i2
        3 diff_dlength_ind = i2
        3 diff_nullable_ind = i2
        3 null_to_notnull_ind = i2
        3 diff_default_ind = i2
        3 cur_idx = i4
        3 size = f8
        3 diff_backfill = i2
        3 backfill_op_exists = i2
      2 ind_tspace = vc
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 size = f8
        3 unique_ind = i2
        3 cur_bytes_allocated = f8
        3 cur_bytes_used = f8
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_ind = i2
        3 visibility_change_ind = i2
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_unique_ind = i2
        3 diff_col_ind = i2
        3 diff_cons_ind = i2
        3 diff_type_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 rename_ind = i2
        3 temp_ind = i2
        3 tspace_name = vc
        3 ext_mgmt = c1
        3 max_ext = f8
      2 ind_drop_cnt = i4
      2 ind_drop[*]
        3 ind_name = vc
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 r_constraint_name = vc
        3 index_idx = i4
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_col_ind = i2
        3 diff_status_ind = i2
        3 diff_parent_ind = i2
        3 diff_ind_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 fk_cnt = i4
      2 cons_drop_cnt = i4
      2 cons_drop[*]
        3 cons_name = vc
        3 cons_type = c1
        3 cur_cons_idx = i4
      2 mview_flag = i2
      2 mview_cc_build_ind = i2
      2 mview_build_ind = i2
      2 mview_log_cnt = i2
      2 mview_logs[*]
        3 table_name = vc
      2 mview_piece_cnt = i2
      2 mview_piece[*]
        3 txt = vc
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 pct_increase = f8
      2 new_ind = i2
      2 cur_idx = i4
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
      2 bytes_free_reqd = f8
      2 min_total_bytes = f8
    1 backfill_ops_cnt = i4
    1 backfill_ops[*]
      2 op_id = f8
      2 gen_dt_tm = dq8
      2 status = vc
      2 reset_backfill = i2
      2 delete_row = i2
      2 table_name = vc
      2 tgt_tbl_idx = i4
      2 col_cnt = i4
      2 col[*]
        3 tgt_col_idx = i4
        3 col_name = vc
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 new_ind = i2
      2 diff_ind = i2
  )
  SET tgtsch->tbl_cnt = 0
  SET tgtsch->backfill_ops_cnt = 0
 ENDIF
 IF ((validate(ddr_ddl_req->ddl_cnt,- (1))=- (1))
  AND (validate(ddr_ddl_req->ddl_cnt,- (2))=- (2)))
  FREE RECORD ddr_ddl_req
  RECORD ddr_ddl_req(
    1 ddl_cnt = i4
    1 ddl_fail_cnt = i4
    1 ddl_ignore_failures = i2
    1 ddl_notify_ind = i2
    1 ddl_process = vc
    1 ddls[*]
      2 ddl_object_name = vc
      2 ddl_object_owner = vc
      2 ddl_table_owner = vc
      2 ddl_table_name = vc
      2 ddl_cmd = vc
      2 ddl_status = vc
      2 ddl_status_message = vc
      2 ddl_bypass_rsbsy_chk = i2
      2 ddl_bypass_libcache_wait_chk = i2
      2 ddl_bypass_parse_chk = i2
      2 ddl_bypass_liblock_chk = i2
  )
 ENDIF
 IF (check_logfile("drr_install_iv_index",".log","drr_install_iv_index")=0)
  GO TO exit_script
 ENDIF
 FREE RECORD csv_index
 RECORD csv_index(
   1 list[*]
     2 table_name = vc
     2 index_name = vc
     2 idx_col[*]
       3 column_name = vc
       3 column_position = i4
     2 drop_ind = i2
     2 create_ind = i2
     2 ind_name_match = i2
     2 ind_col_match = i2
     2 ind_visibility_match = i2
     2 run_drop_index = i2
     2 run_create_index = i2
     2 drop_index_ddl = vc
     2 create_index_ddl = vc
     2 set_gather_stats_ddl = vc
     2 index_tspace = vc
     2 free_bytes_mb = f8
     2 index_col_list = vc
 )
 FREE RECORD cur_index
 RECORD cur_index(
   1 tbl_list[*]
     2 table_name = vc
     2 ind_list[*]
       3 index_name = vc
       3 visibility = vc
       3 col_list_cnt = i4
       3 col_list[*]
         4 column_name = vc
         4 column_position = i4
 )
 FREE RECORD ts_data
 RECORD ts_data(
   1 tspace_cnt = i2
   1 tspace_needed_ind = i2
   1 default_index_tspace = vc
   1 default_free_bytes_mb = f8
   1 ts[*]
     2 tspace_name = vc
     2 dg_name = vc
     2 data_file_cnt = i4
     2 max_bytes_mb = f8
     2 user_bytes_mb = f8
     2 reserved_bytes_mb = f8
     2 free_bytes_mb = f8
 )
 SET ts_data->default_index_tspace = "DM2NOTSET"
 DECLARE dii_get_tablespace(null) = i2
 DECLARE dii_locidx = i4 WITH protect, noconstant(0)
 DECLARE dii_tslocidx = i4 WITH protect, noconstant(0)
 DECLARE dii_dg_name = vc WITH protect, noconstant(" ")
 DECLARE dii_tsp_reserve_pct = f8 WITH protect, noconstant(0.1)
 DECLARE dii_idx = i4 WITH protect, noconstant(0)
 DECLARE dii_idx1 = i4 WITH protect, noconstant(0)
 DECLARE dii_tidx = i4 WITH protect, noconstant(0)
 DECLARE dii_cidx = i4 WITH protect, noconstant(0)
 DECLARE dii_pos = i4 WITH protect, noconstant(0)
 DECLARE dii_ipos = i4 WITH protect, noconstant(0)
 DECLARE dii_tpos = i4 WITH protect, noconstant(0)
 DECLARE dii_cpos = i4 WITH protect, noconstant(0)
 DECLARE dii_icol = i4 WITH protect, noconstant(0)
 DECLARE dii_col_match_cnt = i4 WITH protect, noconstant(0)
 DECLARE tsidx = i4 WITH protect, noconstant(0)
 DECLARE dii_table_owner = vc WITH protect, noconstant("V500")
 DECLARE dii_index_owner = vc WITH protect, noconstant("V500")
 IF (dii_get_tablespace(null)=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Copy requestin to new rs"
 CALL disp_msg("",dm_err->logfile,0)
 SET dii_pos = 0
 SELECT INTO "nl:"
  FROM user_tables ut,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ut
   WHERE (ut.table_name=requestin->list_0[d.seq].table_name))
  DETAIL
   dii_pos += 1, stat = alterlist(csv_index->list,dii_pos), dii_idx = 0,
   dii_idx = locateval(dii_idx,1,size(csv_index->list,5),requestin->list_0[d.seq].index_name,
    csv_index->list[dii_idx].index_name)
   IF (dii_idx > 0)
    dii_icol = (size(csv_index->list[dii_idx].idx_col,5)+ 1), stat = alterlist(csv_index->list[
     dii_idx].idx_col,dii_icol), csv_index->list[dii_idx].idx_col[dii_icol].column_name = cnvtupper(
     requestin->list_0[d.seq].column_name),
    csv_index->list[dii_idx].idx_col[dii_icol].column_position = cnvtreal(requestin->list_0[d.seq].
     column_position)
   ELSE
    csv_index->list[dii_pos].table_name = cnvtupper(requestin->list_0[d.seq].table_name), csv_index->
    list[dii_pos].index_name = cnvtupper(requestin->list_0[d.seq].index_name), csv_index->list[
    dii_pos].drop_ind = cnvtreal(requestin->list_0[d.seq].drop_ind),
    csv_index->list[dii_pos].create_ind = cnvtreal(requestin->list_0[d.seq].create_ind), csv_index->
    list[dii_pos].index_tspace = "DM2NOTSET", stat = alterlist(csv_index->list[dii_pos].idx_col,1),
    csv_index->list[dii_pos].idx_col[1].column_name = cnvtupper(requestin->list_0[d.seq].column_name),
    csv_index->list[dii_pos].idx_col[1].column_position = cnvtreal(requestin->list_0[d.seq].
     column_position)
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Loading existing indexes into memory"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM user_ind_columns c,
   user_indexes i,
   (dummyt d  WITH seq = value(size(csv_index->list,5)))
  PLAN (d)
   JOIN (c
   WHERE (c.table_name=csv_index->list[d.seq].table_name))
   JOIN (i
   WHERE i.table_name=c.table_name
    AND i.index_name=c.index_name)
  ORDER BY c.table_name, c.index_name, c.column_position
  HEAD REPORT
   dii_tidx = 0
  HEAD c.table_name
   dii_idx = 0, dii_cidx = 0, dii_tpos = 0,
   dii_tpos = locateval(dii_tpos,1,size(cur_index->tbl_list,5),cnvtupper(trim(i.table_name)),
    cur_index->tbl_list[dii_tpos].table_name)
   IF (dii_tpos=0)
    dii_tidx += 1, stat = alterlist(cur_index->tbl_list,dii_tidx), cur_index->tbl_list[dii_tidx].
    table_name = i.table_name
   ELSE
    dii_tidx = dii_tpos
   ENDIF
  HEAD c.index_name
   dii_ipos = 0, dii_ipos = locateval(dii_ipos,1,size(cur_index->tbl_list[dii_tidx].ind_list,5),
    cnvtupper(trim(i.index_name)),cur_index->tbl_list[dii_tidx].ind_list[dii_ipos].index_name)
   IF (dii_ipos=0)
    dii_idx += 1, stat = alterlist(cur_index->tbl_list[dii_tidx].ind_list,dii_idx), cur_index->
    tbl_list[dii_tidx].ind_list[dii_idx].index_name = i.index_name,
    cur_index->tbl_list[dii_tidx].ind_list[dii_idx].visibility = i.visibility
   ELSE
    dii_idx = dii_ipos
   ENDIF
  DETAIL
   dii_cpos = 0, dii_cpos = locateval(dii_cpos,1,size(cur_index->tbl_list[dii_tidx].ind_list[dii_idx]
     .col_list,5),cnvtupper(trim(c.column_name)),cur_index->tbl_list[dii_tidx].ind_list[dii_idx].
    col_list[dii_cpos].column_name)
   IF (dii_cpos=0)
    dii_cidx += 1, stat = alterlist(cur_index->tbl_list[dii_tidx].ind_list[dii_idx].col_list,dii_cidx
     ), cur_index->tbl_list[dii_tidx].ind_list[dii_idx].col_list[dii_cidx].column_name = c
    .column_name,
    cur_index->tbl_list[dii_tidx].ind_list[dii_idx].col_list[dii_cidx].column_position = c
    .column_position
   ELSE
    dii_cidx = dii_cpos
   ENDIF
  FOOT  c.index_name
   stat = alterlist(cur_index->tbl_list[dii_tidx].ind_list[dii_idx].col_list,dii_cidx), cur_index->
   tbl_list[dii_tidx].ind_list[dii_idx].col_list_cnt = dii_cidx, dii_cidx = 0
  FOOT  c.table_name
   stat = alterlist(cur_index->tbl_list[dii_tidx].ind_list,dii_idx), dii_idx = 0
  WITH nocounter, maxcol = 32000
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Loop through csv indexes and compare with existing ones"
 CALL disp_msg("",dm_err->logfile,0)
 FOR (dii_idx = 1 TO value(size(csv_index->list,5)))
   SET dii_idx1 = locateval(dii_idx1,1,size(cur_index->tbl_list,5),csv_index->list[dii_idx].
    table_name,cur_index->tbl_list[dii_idx1].table_name)
   FOR (dii_idx2 = 1 TO value(size(cur_index->tbl_list[dii_idx1].ind_list,5)))
    SET dii_col_match_cnt = 0
    IF ((csv_index->list[dii_idx].ind_col_match=0))
     IF ((size(csv_index->list[dii_idx].idx_col,5)=cur_index->tbl_list[dii_idx1].ind_list[dii_idx2].
     col_list_cnt))
      FOR (dii_cidx = 1 TO value(size(csv_index->list[dii_idx].idx_col,5)))
        IF ((csv_index->list[dii_idx].idx_col[dii_cidx].column_name=cur_index->tbl_list[dii_idx1].
        ind_list[dii_idx2].col_list[dii_cidx].column_name))
         IF ((csv_index->list[dii_idx].idx_col[dii_cidx].column_position=cur_index->tbl_list[dii_idx1
         ].ind_list[dii_idx2].col_list[dii_cidx].column_position))
          SET dii_col_match_cnt += 1
         ENDIF
        ENDIF
      ENDFOR
      IF (dii_col_match_cnt=size(csv_index->list[dii_idx].idx_col,5))
       SET csv_index->list[dii_idx].ind_col_match = 1
      ENDIF
     ENDIF
     IF ((csv_index->list[dii_idx].index_name=cur_index->tbl_list[dii_idx1].ind_list[dii_idx2].
     index_name))
      SET csv_index->list[dii_idx].ind_name_match = 1
      IF ((cur_index->tbl_list[dii_idx1].ind_list[dii_idx2].visibility="INVISIBLE"))
       SET csv_index->list[dii_idx].ind_visibility_match = 1
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   SET dm_err->eproc = "Determine action on loaded indexes"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((csv_index->list[dii_idx].create_ind=1))
    IF ((csv_index->list[dii_idx].ind_col_match=0))
     IF ((csv_index->list[dii_idx].ind_name_match=1))
      IF ((csv_index->list[dii_idx].ind_visibility_match=1))
       SET csv_index->list[dii_idx].run_drop_index = 1
       SET csv_index->list[dii_idx].run_create_index = 1
      ENDIF
     ELSE
      SET csv_index->list[dii_idx].run_create_index = 1
     ENDIF
    ENDIF
   ENDIF
   IF ((csv_index->list[dii_idx].drop_ind=1)
    AND (csv_index->list[dii_idx].ind_name_match=1)
    AND (csv_index->list[dii_idx].ind_col_match=1)
    AND (csv_index->list[dii_idx].ind_visibility_match=1))
    SET csv_index->list[dii_idx].run_drop_index = 1
   ENDIF
   SET dm_err->eproc = "Execute action on loaded indexes"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((csv_index->list[dii_idx].run_drop_index=1))
    SET csv_index->list[dii_idx].drop_index_ddl = concat("drop index ",dii_index_owner,".",csv_index
     ->list[dii_idx].index_name)
    SET dm_err->eproc = concat("Drop index: ",csv_index->list[dii_idx].index_name)
    CALL disp_msg("",dm_err->logfile,0)
    IF (dii_exec_command(csv_index->list[dii_idx].drop_index_ddl,dii_index_owner,csv_index->list[
     dii_idx].index_name)=0)
     SET dm_err->err_ind = 1
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((csv_index->list[dii_idx].run_create_index=1))
    FOR (dii_cidx = 1 TO value(size(csv_index->list[dii_idx].idx_col,5)))
      IF (dii_cidx=1)
       SET csv_index->list[dii_idx].index_col_list = concat(csv_index->list[dii_idx].index_col_list,
        csv_index->list[dii_idx].idx_col[dii_cidx].column_name)
      ELSE
       SET csv_index->list[dii_idx].index_col_list = concat(csv_index->list[dii_idx].index_col_list,
        ",",csv_index->list[dii_idx].idx_col[dii_cidx].column_name)
      ENDIF
    ENDFOR
    SET dm_err->eproc = concat("Retrieving index tablespaces used by table ",csv_index->list[dii_idx]
     .table_name)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     ui.tablespace_name
     FROM user_indexes ui
     WHERE ui.index_type="NORMAL"
      AND  NOT (ui.tablespace_name IN ("MISC", "SYS", "SYSTEM", "UNDO*"))
      AND (ui.table_name=csv_index->list[dii_idx].table_name)
     ORDER BY ui.tablespace_name
     HEAD REPORT
      tsidx = 0
     DETAIL
      tsidx = locateval(tsidx,1,ts_data->tspace_cnt,ui.tablespace_name,ts_data->ts[tsidx].tspace_name
       )
      IF (tsidx > 0)
       IF ((csv_index->list[dii_idx].index_tspace="DM2NOTSET"))
        csv_index->list[dii_idx].index_tspace = ts_data->ts[tsidx].tspace_name, csv_index->list[
        dii_idx].free_bytes_mb = (ts_data->ts[tsidx].free_bytes_mb - ts_data->ts[tsidx].
        reserved_bytes_mb)
       ELSE
        IF (((ts_data->ts[tsidx].free_bytes_mb - ts_data->ts[tsidx].reserved_bytes_mb) > csv_index->
        list[dii_idx].free_bytes_mb))
         csv_index->list[dii_idx].index_tspace = ts_data->ts[tsidx].tspace_name, csv_index->list[
         dii_idx].free_bytes_mb = (ts_data->ts[tsidx].free_bytes_mb - ts_data->ts[tsidx].
         reserved_bytes_mb)
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    IF ((csv_index->list[dii_idx].index_tspace="DM2NOTSET"))
     SET csv_index->list[dii_idx].index_tspace = ts_data->default_index_tspace
     SET csv_index->list[dii_idx].free_bytes_mb = ts_data->default_free_bytes_mb
    ENDIF
    SET csv_index->list[dii_idx].create_index_ddl = concat("CREATE INDEX ",trim(dii_table_owner),".",
     trim(csv_index->list[dii_idx].index_name)," ON ",
     trim(dii_table_owner),".",trim(csv_index->list[dii_idx].table_name)," ( ",trim(csv_index->list[
      dii_idx].index_col_list),
     " )"," LOGGING ONLINE INVISIBLE TABLESPACE ",trim(csv_index->list[dii_idx].index_tspace))
    SET dm_err->eproc = concat("Creating index:",csv_index->list[dii_idx].index_name)
    CALL disp_msg("",dm_err->logfile,10)
    IF (dii_exec_command(csv_index->list[dii_idx].create_index_ddl,dii_table_owner,csv_index->list[
     dii_idx].table_name)=0)
     SET dm_err->err_ind = 1
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((csv_index->list[dii_idx].run_create_index=1))
    SET csv_index->list[dii_idx].set_gather_stats_ddl = concat('DM2_FINISH_INDEX "',trim(
      dii_table_owner),'","',trim(csv_index->list[dii_idx].table_name),'","',
     trim(dii_table_owner),'","',trim(csv_index->list[dii_idx].index_name),'" GO')
    IF (dii_exec_command(csv_index->list[dii_idx].set_gather_stats_ddl,dii_table_owner,csv_index->
     list[dii_idx].table_name)=0)
     SET dm_err->err_ind = 1
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE (dii_exec_command(dii_str=vc,dii_owner=vc,dii_table=vc) =i2)
   DECLARE dec_str = vc WITH protect, noconstant("")
   IF (findstring("DM2_FINISH_INDEX",dii_str)=0)
    SET dec_str = concat("rdb asis(^",dii_str,"^) go")
   ELSE
    SET dec_str = dii_str
   ENDIF
   SET ddr_ddl_req->ddl_process = "DRR_INSTALL_IV_INDEX"
   SET ddr_ddl_req->ddl_cnt = 0
   SET ddr_ddl_req->ddl_fail_cnt = 0
   SET stat = alterlist(ddr_ddl_req->ddls,0)
   SET ddr_ddl_req->ddl_ignore_failures = 0
   SET ddr_ddl_req->ddl_cnt += 1
   SET stat = alterlist(ddr_ddl_req->ddls,ddr_ddl_req->ddl_cnt)
   SET ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_table_owner = dii_owner
   SET ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_table_name = dii_table
   SET ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_cmd = dec_str
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_ddl_req)
   ENDIF
   SET dm_err->eproc = "Executing dm2_run_ddl to execute the DDL(s) "
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_run_ddl
   IF ((ddr_ddl_req->ddl_fail_cnt > 0))
    SET dm_err->eproc = "Executing dm2_run_ddl to execute the DDL(s) "
    SET dm_err->err_ind = 1
    SET dm_err->emsg = ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_status_message
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dii_get_tablespace(null)
   SET dm_err->eproc = "Loading existing index tablespaces for affected tables into memory"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    FROM user_indexes ui
    WHERE ui.index_type="NORMAL"
     AND ui.tablespace_name IS NOT null
     AND  NOT (ui.tablespace_name IN ("SYS", "SYSTEM", "MISC", "*UNDO*"))
    ORDER BY ui.tablespace_name
    HEAD REPORT
     ts_data->tspace_cnt = 0, stat = alterlist(ts_data->ts,ts_data->tspace_cnt)
    DETAIL
     ts_data->tspace_cnt += 1
     IF (mod(ts_data->tspace_cnt,10)=1)
      stat = alterlist(ts_data->ts,(ts_data->tspace_cnt+ 9))
     ENDIF
     ts_data->ts[ts_data->tspace_cnt].tspace_name = ui.tablespace_name, ts_data->ts[ts_data->
     tspace_cnt].dg_name = "DM2NOTSET", ts_data->ts[ts_data->tspace_cnt].data_file_cnt = 0
    FOOT REPORT
     stat = alterlist(ts_data->ts,ts_data->tspace_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading data file free space information into memory"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    ORDER BY ddf.tablespace_name, ddf.file_name
    DETAIL
     dii_locidx = locateval(dii_locidx,1,ts_data->tspace_cnt,ddf.tablespace_name,ts_data->ts[
      dii_locidx].tspace_name)
     IF (dii_locidx > 0)
      ts_data->ts[dii_locidx].data_file_cnt += 1, dii_dg_name = substring(2,(findstring("/",ddf
        .file_name,1,0) - 2),ddf.file_name)
      IF ((ts_data->ts[dii_locidx].dg_name="DM2NOTSET"))
       ts_data->ts[dii_locidx].dg_name = dii_dg_name
      ENDIF
      IF ((dii_dg_name=ts_data->ts[dii_locidx].dg_name))
       IF (ddf.autoextensible="YES")
        ts_data->ts[dii_locidx].max_bytes_mb += ((ddf.maxbytes/ 1024)/ 1024), ts_data->ts[dii_locidx]
        .user_bytes_mb += ((ddf.user_bytes/ 1024)/ 1024), ts_data->ts[dii_locidx].free_bytes_mb += ((
        (ddf.maxbytes - ddf.user_bytes)/ 1024)/ 1024),
        ts_data->ts[dii_locidx].reserved_bytes_mb = (ts_data->ts[dii_locidx].free_bytes_mb *
        dii_tsp_reserve_pct)
       ENDIF
      ENDIF
     ENDIF
    FOOT  ddf.tablespace_name
     IF (dii_locidx > 0)
      IF ((ts_data->default_index_tspace="DM2NOTSET"))
       ts_data->default_index_tspace = ddf.tablespace_name, ts_data->default_free_bytes_mb = ts_data
       ->ts[dii_locidx].free_bytes_mb
      ELSEIF ((ts_data->default_free_bytes_mb < ts_data->ts[dii_locidx].free_bytes_mb))
       ts_data->default_index_tspace = ddf.tablespace_name, ts_data->default_free_bytes_mb = ts_data
       ->ts[dii_locidx].free_bytes_mb
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF ((dm_err->debug_flag > 1))
  CALL echorecord(csv_index)
  CALL echorecord(cur_index)
  CALL echorecord(ts_data)
 ENDIF
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "DRR_INSTALL_IV_INDEX has completed"
 ENDIF
 CALL final_disp_msg("drr_install_iv_index")
END GO
