CREATE PROGRAM dm_cmb_enc_mrn_rpt:dba
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
 DECLARE emp_cnt = i4
 DECLARE emp_person_mrn_cd = f8
 DECLARE emp_encntr_mrn_cd = f8
 DECLARE emp_visit_id = f8
 DECLARE emp_fin_nbr = f8
 DECLARE emp_pm_cnt = i4
 DECLARE emp_break = c128
 DECLARE dcce_stop = i4
 DECLARE dcce_start = i4
 DECLARE emp_idx = i4
 DECLARE em_defaul_dttm = vc
 DECLARE dccr_num = i4
 DECLARE dccer_pmrn = vc
 DECLARE dccer_emrn = vc
 DECLARE dccer_row_num = i4
 DECLARE dccer_denote = c3
 DECLARE dccer_fixed_flag = i2
 DECLARE mr_accept_t = i4
 DECLARE dccer_epo = vc
 DECLARE dccer_ppo = vc
 DECLARE rpt_mrn_chg_ind = i4
 SET rpt_mrn_chg_ind = - (1)
 DECLARE logfile_name = vc
 DECLARE pcp_e_mrn_cmb = f8
 SET dccer_fixed_flag = 0
 SET mr_accept_t = 0
 DECLARE cemr_err_cnt = i4
 DECLARE cemr_crt_cnt = i4
 DECLARE cemr_ncg_cnt = i4
 SET dccer_denote = " "
 SET dccer_row_num = 2
 SET em_defaul_dttm = "  -  -    "
 SET emp_break = fillstring(128,"-")
 SET emp_cnt = 0
 SET emp_pm_cnt = 0
 SET emp_fin_nbr = 0.0
 SET dcce_stop = 0
 SET dcce_start = 0
 FREE RECORD em_person
 RECORD em_person(
   1 em_cnt = i4
   1 list[*]
     2 from_id = f8
     2 to_id = f8
     2 name = vc
     2 dob = dq8
     2 pmrn_cnt = i4
     2 pmrn_list[*]
       3 person_mrn = vc
       3 pool = vc
       3 alias_pool = f8
       3 person_alias_id = f8
     2 gender = c1
     2 fin = vc
     2 regdate = dq8
     2 dischargedate = dq8
     2 enc_type = vc
     2 cmb_id = f8
     2 visit_alias = vc
     2 encntr_id = f8
     2 encntr_alias_id = f8
     2 mrn = vc
     2 epool = vc
     2 alias_pool = f8
     2 facility = vc
     2 reg_dt_tm = dq8
 )
 FREE RECORD em_time_range
 RECORD em_time_range(
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 SET em_time_range->start_dt_tm = cnvtdatetime("01-JAN-2004 00:00:00")
 SET em_time_range->end_dt_tm = cnvtdatetime(sysdate)
 FREE RECORD cemr_req
 RECORD cemr_req(
   1 updt_task = f8
   1 updt_id = f8
   1 updt_applctx = f8
 )
 DECLARE enc_mrn_em(null) = null
 DECLARE enc_mrn_pc(null) = null
 DECLARE start_logfile(null) = null
 SET message = window
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,5,132)
 CALL text(3,45,"**** COMBINE ENCOUNTER MRN REPORT ****")
 CALL text(6,2,
  "This program will help you identify and correct issues with encounter-level MRNs that were potentially "
  )
 CALL text(7,2,
  "caused by incorrect combine logic. It will evaluate encounter-level MRNs that existed at the time of the "
  )
 CALL text(8,2,
  'combine and are still "current" (i.e. active and effective) when the report is run. Please perform both '
  )
 CALL text(9,2,
  "options. You may perform an option more than once if you wish to work in smaller segments by date range."
  )
 CALL text(11,2,
  "1  Encounter-Move Report and Corrections - Identifies encounters that were moved from one person to"
  )
 CALL text(12,2,
  "   another, where the encounter-level MRN does not match any of the person's person-level MRNs.  "
  )
 CALL text(14,2,
  "2  Full Person Combine Report and Corrections - Identifies encounters involved in full person combines, "
  )
 CALL text(15,2,
  "   where the encounter-level MRN does not match a person-level MRN that was active and effective at the "
  )
 CALL text(16,2,
  "   time of the combine. *Note:  This report uses your current database setting for handling ")
 CALL text(17,2,
  "   encounter-level MRNs during person combines. If the setting was different in the past it will impact "
  )
 CALL text(18,2,
  '   the results. It will only evaluate encounters that are still "active" as defined by the current setting.'
  )
 CALL text(20,2,"0  Exit")
 CALL text(22,2,"Choose option(1,2,0)")
 CALL accept(22,90,"9",0
  WHERE curaccept IN (1, 2, 0))
 IF (curaccept=0)
  GO TO exit_program
 ENDIF
 SET mr_accept_t = curaccept
 SET message = nowindow
 IF ((xxcclseclogin->loggedin != 1))
  CALL echo("***********************************************************************************")
  CALL echo(
   "Alert: User not logged into CCLSECLOGIN. Please run CCLSECLOGIN before running this report!")
  CALL echo("***********************************************************************************")
  GO TO exit_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,emp_encntr_mrn_cd)
 IF (emp_encntr_mrn_cd=0.0)
  CALL rpt_write_log("No active, effective code_value with code_set=319, cdf_meaning='MRN'",
   logfile_name)
  GO TO exit_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,emp_person_mrn_cd)
 IF (emp_person_mrn_cd=0.0)
  CALL rpt_write_log("No active, effective code_value with code_set=4, cdf_meaning='MRN'",
   logfile_name)
  GO TO exit_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,nullterm("FIN NBR"),1,emp_fin_nbr)
 IF (emp_fin_nbr=0.0)
  CALL rpt_write_log("No active, effective code_value with code_set=319, cdf_meaning='FIN NBR'",
   logfile_name)
  GO TO exit_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,nullterm("VISITID"),1,emp_visit_id)
 IF (emp_visit_id=0.0)
  CALL rpt_write_log("No active, effective code_value with code_set=319, cdf_meaning='VISITID'",
   logfile_name)
  GO TO exit_program
 ENDIF
 CALL clear(1,1)
 SET width = 132
 CALL box(1,1,5,132)
 CALL text(3,44,"***  INPUT THE DATE RANGE FOR THE REPORT ***")
 CALL text(7,3,"NOTE: the starting date must be 01/01/2004 or later")
 CALL text(9,3,"Starting date (list in mm-dd-yyyy format): ")
 CALL text(10,3,"Ending date (list in mm-dd-yyyy format):")
 SET em_defaul_dttm = "01-01-2004"
 CALL accept(9,80,"NNDNNDNNNN;C",em_defaul_dttm
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM-DD-YYYY;;D")=curaccept
   AND day(cnvtdatetime(format(cnvtdate2(curaccept,"MM-DD-YYYY"),"DD-MMM-YYYY;;D"))) != 0
   AND month(cnvtdatetime(format(cnvtdate2(curaccept,"MM-DD-YYYY"),"DD-MMM-YYYY;;D"))) != 0)
 IF ((cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),0) > em_time_range->start_dt_tm))
  SET em_time_range->start_dt_tm = cnvtdate(cnvtalphanum(curaccept))
 ENDIF
 SET em_defaul_dttm = format(cnvtdatetime(curdate,curtime),"MM-DD-YYYY;;D")
 CALL accept(10,80,"NNDNNDNNNN;C",em_defaul_dttm
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM-DD-YYYY;;D")=curaccept
   AND day(cnvtdatetime(format(cnvtdate2(curaccept,"MM-DD-YYYY"),"DD-MMM-YYYY;;D"))) != 0
   AND month(cnvtdatetime(format(cnvtdate2(curaccept,"MM-DD-YYYY"),"DD-MMM-YYYY;;D"))) != 0)
 IF ((cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),curtime3) > em_time_range->start_dt_tm))
  SET em_time_range->end_dt_tm = cnvtdate(cnvtalphanum(curaccept))
 ENDIF
 SET message = nowindow
 CALL echorecord(em_time_range)
 CALL start_logfile(null)
 IF (mr_accept_t=1)
  CALL enc_mrn_em(null)
  IF ((em_person->em_cnt > 0))
   CALL disp_rpt("ENCOUNTER MOVE")
   SET cemr_req->updt_task = reqinfo->updt_task
   SET cemr_req->updt_id = reqinfo->updt_id
   SET cemr_req->updt_applctx = reqinfo->updt_applctx
   SET reqinfo->updt_task = 9876
   SET reqinfo->updt_id = 9876
   SET reqinfo->updt_applctx = 9876
   CALL enc_mrn_cleanup("EM","ENCOUNTER MOVE")
  ENDIF
 ELSEIF (mr_accept_t=2)
  SET stat = uar_get_meaning_by_codeset(20790,"ENCNTRMRNCMB",1,pcp_e_mrn_cmb)
  IF (pcp_e_mrn_cmb=0.0)
   CALL rpt_write_log(
    "No active, effective code_value with code_set=20790, cdf_meaning='ENCNTRMRNCMB'",logfile_name)
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_set=20790
    AND cve.code_value=pcp_e_mrn_cmb
   DETAIL
    rpt_mrn_chg_ind = cnvtint(cve.field_value)
   WITH nocounter
  ;end select
  IF (((rpt_mrn_chg_ind > 4) OR (rpt_mrn_chg_ind < 0)) )
   SET dm_err->err_ind = 1
   CALL rpt_write_log("value of cs 20790 option for ENCNTRMRNCMB is not valid",logfile_name)
   GO TO exit_program
  ENDIF
  IF (rpt_mrn_chg_ind=0)
   CALL rpt_write_log(
    "Encounter-level MRN change indicator is set so that encounter-level MRNs do not change during full person combines.",
    logfile_name)
   GO TO exit_program
  ENDIF
  CALL enc_mrn_pc(null)
  IF ((em_person->em_cnt > 0))
   CALL disp_rpt("PERSON COMBINE")
   SET cemr_req->updt_task = reqinfo->updt_task
   SET cemr_req->updt_id = reqinfo->updt_id
   SET cemr_req->updt_applctx = reqinfo->updt_applctx
   SET reqinfo->updt_task = 9876
   SET reqinfo->updt_id = 9876
   SET reqinfo->updt_applctx = 9876
   CALL enc_mrn_cleanup("PC","PERSON COMBINE")
  ENDIF
 ENDIF
 SUBROUTINE enc_mrn_pc(null)
   DECLARE rpt_active_enc_cd = f8
   SET rpt_active_enc_cd = 0.0
   SET stat = uar_get_meaning_by_codeset(261,"ACTIVE",1,rpt_active_enc_cd)
   IF (rpt_active_enc_cd=0.0)
    CALL rpt_write_log("No active, effective code_value with code_set=261, cdf_meaning='ACTIVE'",
     logfile_name)
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    pc.person_combine_id
    FROM person_alias pa,
     person p,
     alias_pool ap,
     encntr_alias ea,
     encounter e,
     person_combine_det pcd,
     person_combine pc
    PLAN (pc
     WHERE ((pc.encntr_id+ 0)=0)
      AND pc.updt_dt_tm BETWEEN cnvtdatetime(em_time_range->start_dt_tm) AND cnvtdatetime(
      em_time_range->end_dt_tm)
      AND pc.active_ind=1)
     JOIN (pcd
     WHERE pcd.person_combine_id=pc.person_combine_id
      AND pcd.entity_name="ENCOUNTER"
      AND pcd.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=pcd.entity_id
      AND e.person_id=pc.to_person_id
      AND e.active_ind=1
      AND (( NOT (rpt_mrn_chg_ind IN (2, 4))) OR (e.encntr_status_cd=rpt_active_enc_cd)) )
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.encntr_alias_type_cd=emp_encntr_mrn_cd
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ea.beg_effective_dt_tm <= pc.updt_dt_tm
      AND ea.alias_pool_cd > 0)
     JOIN (ap
     WHERE ap.alias_pool_cd=ea.alias_pool_cd
      AND ap.cmb_inactive_ind > 0
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM person_combine_det pcd2
      WHERE pcd2.person_combine_id=pc.person_combine_id
       AND pcd2.entity_name="ENCNTR_ALIAS"
       AND pcd2.entity_id=ea.encntr_alias_id)))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM person_alias pa2
      WHERE pa2.person_id=e.person_id
       AND pa2.alias_pool_cd=ea.alias_pool_cd
       AND pa2.person_alias_type_cd=emp_person_mrn_cd
       AND pa2.alias=ea.alias
       AND ((pa2.active_ind=1) OR (pa2.active_ind=0
       AND (pa2.active_status_dt_tm >
      (SELECT
       max(pcd3.updt_dt_tm)
       FROM person_combine_det pcd3
       WHERE pcd3.person_combine_id=pc.person_combine_id
        AND pcd3.active_ind=1))))
       AND pa2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND (pa2.end_effective_dt_tm >
      (SELECT
       max(pcd4.updt_dt_tm)
       FROM person_combine_det pcd4
       WHERE pcd4.person_combine_id=pc.person_combine_id
        AND pcd4.active_ind=1)))))
      AND  EXISTS (
     (SELECT
      "x"
      FROM person_alias pa3
      WHERE pa3.person_id=e.person_id
       AND pa3.alias_pool_cd=ea.alias_pool_cd
       AND pa3.person_alias_type_cd=emp_person_mrn_cd
       AND ((pa3.active_ind=1) OR (pa3.active_ind=0
       AND (pa3.active_status_dt_tm >
      (SELECT
       max(pcd5.updt_dt_tm)
       FROM person_combine_det pcd5
       WHERE pcd5.person_combine_id=pc.person_combine_id
        AND pcd5.active_ind=1))))
       AND pa3.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND (pa3.end_effective_dt_tm >
      (SELECT
       max(pcd6.updt_dt_tm)
       FROM person_combine_det pcd6
       WHERE pcd6.person_combine_id=pc.person_combine_id
        AND pcd6.active_ind=1)))))
     JOIN (p
     WHERE p.person_id=pc.to_person_id
      AND p.active_ind=1)
     JOIN (pa
     WHERE pa.person_id=pc.to_person_id
      AND pa.person_alias_type_cd=emp_person_mrn_cd)
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     emp_cnt += 1
     IF (mod(emp_cnt,100)=1)
      stat = alterlist(em_person->list,(emp_cnt+ 99))
     ENDIF
     em_person->list[emp_cnt].from_id = pc.from_person_id, em_person->list[emp_cnt].to_id = pc
     .to_person_id, em_person->list[emp_cnt].cmb_id = pc.person_combine_id,
     em_person->list[emp_cnt].encntr_id = e.encntr_id, em_person->list[emp_cnt].reg_dt_tm = e
     .reg_dt_tm, em_person->list[emp_cnt].dischargedate = e.disch_dt_tm,
     em_person->list[emp_cnt].epool = uar_get_code_display(ea.alias_pool_cd), em_person->list[emp_cnt
     ].facility = uar_get_code_display(e.loc_facility_cd), em_person->list[emp_cnt].mrn = ea.alias,
     em_person->list[emp_cnt].encntr_alias_id = ea.encntr_alias_id, em_person->list[emp_cnt].enc_type
      = uar_get_code_display(e.encntr_type_cd), em_person->list[emp_cnt].name = p.name_full_formatted,
     em_person->list[emp_cnt].gender = uar_get_code_meaning(p.sex_cd), em_person->list[emp_cnt].dob
      = p.birth_dt_tm, emp_pm_cnt = 0
    DETAIL
     IF ((em_person->list[emp_cnt].epool=uar_get_code_display(pa.alias_pool_cd))
      AND pa.active_ind=1
      AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate))
      emp_pm_cnt += 1, stat = alterlist(em_person->list[emp_cnt].pmrn_list,emp_pm_cnt), em_person->
      list[emp_cnt].pmrn_list[emp_pm_cnt].person_mrn = pa.alias,
      em_person->list[emp_cnt].pmrn_list[emp_pm_cnt].pool = uar_get_code_display(pa.alias_pool_cd),
      em_person->list[emp_cnt].pmrn_list[emp_pm_cnt].alias_pool = pa.alias_pool_cd, em_person->list[
      emp_cnt].pmrn_list[emp_pm_cnt].person_alias_id = pa.person_alias_id
     ENDIF
    FOOT  p.person_id
     em_person->list[emp_cnt].pmrn_cnt = emp_pm_cnt
    FOOT REPORT
     stat = alterlist(em_person->list,emp_cnt), em_person->em_cnt = emp_cnt
    WITH nocounter
   ;end select
   WHILE (dcce_stop < emp_cnt)
     SET dcce_start = (dcce_stop+ 1)
     SET dcce_stop += 200
     IF (dcce_stop > emp_cnt)
      SET dcce_stop = emp_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM encntr_alias ea
      WHERE expand(dccr_num,dcce_start,dcce_stop,ea.encntr_id,em_person->list[dccr_num].encntr_id)
       AND ea.encntr_alias_type_cd IN (emp_fin_nbr, emp_visit_id)
       AND ea.active_ind=1
       AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      HEAD ea.encntr_id
       pcp_idx = 0, pcp_idx = locateval(pcp_idx,dcce_start,dcce_stop,ea.encntr_id,em_person->list[
        pcp_idx].encntr_id)
      DETAIL
       IF (pcp_idx > 0)
        IF (ea.encntr_alias_type_cd=emp_fin_nbr)
         em_person->list[pcp_idx].fin = ea.alias
        ELSE
         em_person->list[pcp_idx].visit_alias = ea.alias
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (disp_rpt(dr_header=vc) =null)
  DECLARE rpt_head = vc
  SELECT INTO mine
   person_name = em_person->list[d.seq].name, reg_dt_tm = em_person->list[d.seq].reg_dt_tm
   FROM (dummyt d  WITH seq = emp_cnt)
   PLAN (d)
   ORDER BY person_name, reg_dt_tm DESC, d.seq
   HEAD REPORT
    rpt_head = concat("***",dr_header," MRN MISMATCH REPORT***"), col 40, rpt_head,
    row + 2
   HEAD PAGE
    col 10, "(*)Denotes records where an automated correction can not be performed", row + 1,
    col 10, "Note: Data derived in this report may have been truncated for display purpose", row + 2
   DETAIL
    col 0, "PERSON_ID", col 25,
    "PERSON_NAME", col 55, "GENDER",
    col 65, "MRN", col 96,
    "POOL", col 122, "BIRTHDAY",
    col 140, "VISIT_ID", row + 1,
    col 0, em_person->list[d.seq].to_id, col 25,
    em_person->list[d.seq].name, col 55, em_person->list[d.seq].gender,
    col 122, em_person->list[d.seq].dob";;D", col 140,
    em_person->list[d.seq].visit_alias
    IF ((em_person->list[d.seq].pmrn_cnt != 1))
     dccer_denote = "(*)"
    ELSE
     dccer_denote = ""
    ENDIF
    FOR (dccr_lp = 1 TO em_person->list[d.seq].pmrn_cnt)
      dccer_pmrn = substring(1,30,em_person->list[d.seq].pmrn_list[dccr_lp].person_mrn), col 65,
      dccer_pmrn,
      dccer_ppo = substring(1,30,em_person->list[d.seq].pmrn_list[dccr_lp].pool), col 96, dccer_ppo,
      row + 1
    ENDFOR
    IF ((em_person->list[d.seq].pmrn_cnt=0))
     col 65, "*NO MATCHING PERSON MRN*", row + 1
    ENDIF
    row + 1, col 3, "ENCNTR_ID",
    col 25, "MRN", col 56,
    "POOL", col 90, "FIN",
    col 110, "REG_DATE", col 125,
    "DISCHARGE_DATE", col 140, "ENC_TYPE",
    col 170, "FACILITY", row + 1,
    col 3, em_person->list[d.seq].encntr_id, dccer_emrn = build(substring(1,30,em_person->list[d.seq]
      .mrn),dccer_denote),
    col 25, dccer_emrn, dccer_epo = substring(1,30,em_person->list[d.seq].epool),
    col 56, dccer_epo, col 90,
    em_person->list[d.seq].fin, col 110, em_person->list[d.seq].reg_dt_tm";;D",
    col 125, em_person->list[d.seq].dischargedate";;D", col 140,
    em_person->list[d.seq].enc_type, col 170, em_person->list[d.seq].facility,
    row + 1, col 0, emp_break,
    row + 1
   WITH nocounter, formfeed = none, maxcol = 256
  ;end select
 END ;Subroutine
 SUBROUTINE enc_mrn_em(null)
   SELECT INTO "nl:"
    pc.encntr_id
    FROM person_alias pa,
     person p,
     encntr_alias ea,
     encounter e,
     person_combine pc
    PLAN (pc
     WHERE pc.encntr_id > 0
      AND ((pc.updt_dt_tm+ 0) BETWEEN cnvtdatetime(em_time_range->start_dt_tm) AND cnvtdatetime(
      em_time_range->end_dt_tm))
      AND pc.active_ind=1
      AND  EXISTS (
     (SELECT
      "x"
      FROM person_combine_det pcd
      WHERE pcd.person_combine_id=pc.person_combine_id
       AND pcd.entity_name="ENCOUNTER")))
     JOIN (e
     WHERE e.encntr_id=pc.encntr_id
      AND e.person_id=pc.to_person_id
      AND e.active_ind=1)
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.encntr_alias_type_cd=emp_encntr_mrn_cd
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ea.beg_effective_dt_tm <= pc.updt_dt_tm
      AND ea.alias_pool_cd > 0
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM person_combine_det pcd2
      WHERE pcd2.person_combine_id=pc.person_combine_id
       AND pcd2.entity_name="ENCNTR_ALIAS"
       AND pcd2.entity_id=ea.encntr_alias_id)))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM person_alias pa2
      WHERE pa2.person_id=e.person_id
       AND pa2.alias_pool_cd=ea.alias_pool_cd
       AND pa2.person_alias_type_cd=emp_person_mrn_cd
       AND pa2.alias=ea.alias))))
     JOIN (p
     WHERE p.person_id=pc.to_person_id
      AND p.active_ind=1)
     JOIN (pa
     WHERE pa.person_id=pc.to_person_id
      AND pa.person_alias_type_cd=emp_person_mrn_cd)
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     emp_cnt += 1
     IF (mod(emp_cnt,100)=1)
      stat = alterlist(em_person->list,(emp_cnt+ 99))
     ENDIF
     em_person->list[emp_cnt].from_id = pc.from_person_id, em_person->list[emp_cnt].to_id = pc
     .to_person_id, em_person->list[emp_cnt].cmb_id = pc.person_combine_id,
     em_person->list[emp_cnt].encntr_id = pc.encntr_id, em_person->list[emp_cnt].reg_dt_tm = e
     .reg_dt_tm, em_person->list[emp_cnt].dischargedate = e.disch_dt_tm,
     em_person->list[emp_cnt].epool = uar_get_code_display(ea.alias_pool_cd), em_person->list[emp_cnt
     ].facility = uar_get_code_display(e.loc_facility_cd), em_person->list[emp_cnt].mrn = ea.alias,
     em_person->list[emp_cnt].encntr_alias_id = ea.encntr_alias_id, em_person->list[emp_cnt].enc_type
      = uar_get_code_display(e.encntr_type_cd), em_person->list[emp_cnt].name = p.name_full_formatted,
     em_person->list[emp_cnt].gender = uar_get_code_meaning(p.sex_cd), em_person->list[emp_cnt].dob
      = p.birth_dt_tm, emp_pm_cnt = 0
    DETAIL
     IF ((em_person->list[emp_cnt].epool=uar_get_code_display(pa.alias_pool_cd))
      AND pa.active_ind=1
      AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate))
      emp_pm_cnt += 1, stat = alterlist(em_person->list[emp_cnt].pmrn_list,emp_pm_cnt), em_person->
      list[emp_cnt].pmrn_list[emp_pm_cnt].person_mrn = pa.alias,
      em_person->list[emp_cnt].pmrn_list[emp_pm_cnt].pool = uar_get_code_display(pa.alias_pool_cd),
      em_person->list[emp_cnt].pmrn_list[emp_pm_cnt].alias_pool = pa.alias_pool_cd, em_person->list[
      emp_cnt].pmrn_list[emp_pm_cnt].person_alias_id = pa.person_alias_id
     ENDIF
    FOOT  p.person_id
     em_person->list[emp_cnt].pmrn_cnt = emp_pm_cnt
    FOOT REPORT
     stat = alterlist(em_person->list,emp_cnt), em_person->em_cnt = emp_cnt
    WITH nocounter
   ;end select
   CALL echo(emp_cnt)
   WHILE (dcce_stop < emp_cnt)
     SET dcce_start = (dcce_stop+ 1)
     SET dcce_stop += 200
     IF (dcce_stop > emp_cnt)
      SET dcce_stop = emp_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM encntr_alias ea
      WHERE expand(dccr_num,dcce_start,dcce_stop,ea.encntr_id,em_person->list[dccr_num].encntr_id)
       AND ea.encntr_alias_type_cd IN (emp_fin_nbr, emp_visit_id)
       AND ea.active_ind=1
       AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      HEAD ea.encntr_id
       pcp_idx = 0, pcp_idx = locateval(pcp_idx,dcce_start,dcce_stop,ea.encntr_id,em_person->list[
        pcp_idx].encntr_id)
      DETAIL
       IF (pcp_idx > 0)
        IF (ea.encntr_alias_type_cd=emp_fin_nbr)
         em_person->list[pcp_idx].fin = ea.alias
        ELSE
         em_person->list[pcp_idx].visit_alias = ea.alias
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (enc_mrn_cleanup(emc_type=c2,emc_header=vc) =null)
   CALL clear(1,1)
   SET message = window
   SET width = 132
   CALL box(1,1,5,130)
   CALL text(3,45,concat("**** ",emc_header," MRN MISMATCH CORRECTION ****"))
   CALL text(6,2,"Please choose one of the following options:                                ")
   CALL text(7,2,"1 Make all possible automatic corrections ")
   CALL text(8,2,
    "2 View eligible individual ENCOUNTER-level MRNs, with the option to make each correction individually"
    )
   CALL text(9,2,"0 Exit without making corrections")
   CALL accept(6,90,"9",0
    WHERE curaccept IN (1, 2, 0))
   IF (curaccept=2)
    FOR (ce_lp = 1 TO em_person->em_cnt)
      IF ((em_person->list[ce_lp].pmrn_cnt=1))
       SET dccer_fixed_flag = 1
       CALL clear(11,1)
       CALL text(11,2,
        "PERSON_ID              PERSON_NAME                    MRN                           POOL")
       CALL text(12,2,build(em_person->list[ce_lp].to_id))
       CALL text(12,26,em_person->list[ce_lp].name)
       CALL text(12,56,trim(em_person->list[ce_lp].pmrn_list[1].person_mrn))
       CALL text(12,86,trim(em_person->list[ce_lp].pmrn_list[1].pool))
       CALL text(13,2,
        "ENCNTR_ID                                             ENCOUNTER-MRN                 POOL ")
       CALL text(14,2,build(em_person->list[ce_lp].encntr_id))
       CALL text(14,56,trim(em_person->list[ce_lp].mrn))
       CALL text(14,86,trim(em_person->list[ce_lp].epool))
       CALL text(16,2,concat("Change eMRN from ",trim(em_person->list[ce_lp].mrn)," to ",trim(
          em_person->list[ce_lp].pmrn_list[1].person_mrn),".                     "))
       CALL text(17,2,"Make proposed correction?(Y/N/Q)")
       CALL accept(17,90,"P;CU","Y"
        WHERE curaccept IN ("Y", "N", "Q"))
       IF (curaccept="Y")
        EXECUTE dm_cmb_enc_mrn_cleanup em_person->list[ce_lp].encntr_alias_id, em_person->list[ce_lp]
        .pmrn_list[1].person_alias_id, em_person->list[ce_lp].cmb_id,
        emc_type, logfile_name, rpt_mrn_chg_ind
        IF ((dm_err->err_ind=1))
         SET cemr_err_cnt += 1
        ELSE
         SET cemr_crt_cnt += 1
        ENDIF
       ELSEIF (curaccept="Q")
        CALL rpt_write_log("User quits from the correction",logfile_name)
        GO TO exit_program
       ENDIF
      ELSE
       SET cemr_ncg_cnt += 1
      ENDIF
    ENDFOR
    IF (dccer_fixed_flag=0)
     CALL text(11,2,"No available ENCOUNTER level MRN can be corrected")
    ENDIF
   ELSEIF (curaccept=1)
    SET message = nowindow
    FOR (ce_lp = 1 TO em_person->em_cnt)
      IF ((em_person->list[ce_lp].pmrn_cnt=1))
       EXECUTE dm_cmb_enc_mrn_cleanup em_person->list[ce_lp].encntr_alias_id, em_person->list[ce_lp].
       pmrn_list[1].person_alias_id, em_person->list[ce_lp].cmb_id,
       emc_type, logfile_name, rpt_mrn_chg_ind
       IF ((dm_err->err_ind=1))
        SET cemr_err_cnt += 1
       ELSE
        SET cemr_crt_cnt += 1
       ENDIF
      ELSE
       SET cemr_ncg_cnt += 1
      ENDIF
    ENDFOR
    IF (check_error(dm_err->eproc) != 0)
     ROLLBACK
     CALL echo(dm_err->emsg)
     GO TO exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (rpt_write_log(wl_text=vc,wl_logfile=vc) =null)
  CALL echo(wl_text)
  SELECT INTO value(wl_logfile)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    row + 1, curdate"mm/dd/yyyy;;d", " ",
    curtime3"hh:mm:ss;3;m", " ", curprog,
    row + 1, wl_text, row + 1
   WITH nocounter, format = variable, formfeed = none,
    maxrow = 1, maxcol = 200, append
  ;end select
 END ;Subroutine
 SUBROUTINE start_logfile(null)
   SET logfile_name = concat("DM_CMB_ENC_MRN",substring(1,11,cnvtstring(cnvtdatetime(sysdate))))
   SELECT INTO value(logfile_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, curdate"mm/dd/yyyy;;d", " ",
     curtime3"hh:mm:ss;;m", row + 1, "Start combine encounter MRN reprot"
    WITH nocounter, format = variable, formfeed = none,
     maxrow = 1, maxcol = 512
   ;end select
   CALL check_error(concat("Creating log file ",trim(logfile_name)))
 END ;Subroutine
#exit_program
 SET message = nowindow
 IF ((em_person->em_cnt > 0))
  SET message = nowindow
  SET reqinfo->updt_task = cemr_req->updt_task
  SET reqinfo->updt_id = cemr_req->updt_id
  SET reqinfo->updt_applctx = cemr_req->updt_applctx
  CALL echo(
   "*********************************************************************************************")
  CALL echo(concat(trim(cnvtstring(cemr_crt_cnt))," successful cleanups.",trim(cnvtstring(
      cemr_err_cnt))," errors occurred"))
  CALL echo(concat(trim(cnvtstring(cemr_ncg_cnt))," are not eligible for cleanup."))
  IF ((dm_err->err_ind=1))
   CALL echo(concat("Please see the file ccluserdir:",logfile_name,".dat for error details"))
   CALL echo(concat("Please re-run the report and cleanup after issues are resolved"))
  ENDIF
  CALL echo(
   "*********************************************************************************************")
 ENDIF
END GO
