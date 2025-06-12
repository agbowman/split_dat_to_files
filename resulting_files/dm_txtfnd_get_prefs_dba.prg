CREATE PROGRAM dm_txtfnd_get_prefs:dba
 SET modify maxvarlen 268435456
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
 DECLARE dtgp_him_mnem1 = vc WITH protect, constant("HIM_SOURCE_VOCAB")
 DECLARE dtgp_him_desc1 = vc WITH protect, constant(
  "Health Information Mgmt Coding System Parameters Source Vocabulary")
 DECLARE dtgp_cs_mnem1 = vc WITH protect, constant("CS_ICD10_DATE")
 DECLARE dtgp_cs_mnem2 = vc WITH protect, constant("CS_DX_TYPE")
 DECLARE dtgp_cs_mnem3 = vc WITH protect, constant("CS_PL_TYPE")
 DECLARE dtgp_cs_desc1 = vc WITH protect, constant("Charge Services ICD10 Compliance Date")
 DECLARE dtgp_cs_desc2 = vc WITH protect, constant("Charge Services ICD10 Diagnosis Type")
 DECLARE dtgp_cs_desc3 = vc WITH protect, constant("Charge Services ICD10 Procedure Type")
 DECLARE dtgp_sch_mnem1 = vc WITH protect, constant("SCH_SRCHFLTR")
 DECLARE dtgp_sch_mnem2 = vc WITH protect, constant("SCH_ICD10_DATE")
 DECLARE dtgp_sch_mnem3 = vc WITH protect, constant("SNDXSRCHFLTR")
 DECLARE dtgp_sch_desc1 = vc WITH protect, constant("Scheduling Vocabulary Search Filter")
 DECLARE dtgp_sch_desc2 = vc WITH protect, constant("Scheduling ICD10 Transition Date")
 DECLARE dtgp_sch_desc3 = vc WITH protect, constant("Scheduling SurgiNet Diagnosis Code Filter")
 DECLARE dtgp_pdir_mnem1 = vc WITH protect, constant("PDIR_DIAG_SRCH")
 DECLARE dtgp_pdir_mnem2 = vc WITH protect, constant("PDIR_DIAG_TERM")
 DECLARE dtgp_pdir_mnem3 = vc WITH protect, constant("PDIR_DIAG_TERM_AXIS")
 DECLARE dtgp_pdir_desc1 = vc WITH protect, constant("Cerner Imaging Diagnosis Search")
 DECLARE dtgp_pdir_desc2 = vc WITH protect, constant("Cerner Imaging Diagnosis Search Terminology")
 DECLARE dtgp_pdir_desc3 = vc WITH protect, constant("Cerner Imagine Diagnosis Terminology Axis")
 DECLARE dtgp_nvp_mnem1 = vc WITH protect, constant("NVP_DX_TGT_VOCAB")
 DECLARE dtgp_nvp_desc1 = vc WITH protect, constant("Physician Orders Diagnosis Target Vocabulary")
 DECLARE dtgp_nvp_mnem2 = vc WITH protect, constant("NVP_PL_AUTH_VOCAB")
 DECLARE dtgp_nvp_desc2 = vc WITH protect, constant("Physician Orders Problems Authorized Vocabulary"
  )
 DECLARE dtgp_nvp_mnem3 = vc WITH protect, constant("NVP_PL_VOCAB")
 DECLARE dtgp_nvp_desc3 = vc WITH protect, constant("Physician Orders Problems Default Vocabulary")
 DECLARE dtgp_nvp_mnem4 = vc WITH protect, constant("NVP_PL_TGT_VOCAB")
 DECLARE dtgp_nvp_desc4 = vc WITH protect, constant("Physician Orders Problems Target Vocabulary")
 DECLARE dtgp_nvp_mnem5 = vc WITH protect, constant("NVP_DX_VOCAB")
 DECLARE dtgp_nvp_desc5 = vc WITH protect, constant("Physician Orders Diagnosis Default Vocabulary")
 DECLARE dtgp_nvp_mnem6 = vc WITH protect, constant("NVP_DX_AUTH_VOCAB")
 DECLARE dtgp_nvp_desc6 = vc WITH protect, constant(
  "Physician Orders Diagnosis Authorized Vocabulary")
 DECLARE dtgp_dcp_mnem1 = vc WITH protect, constant("ORD_DIAG_CONFIG")
 DECLARE dtgp_dcp_desc1 = vc WITH protect, constant("Orders Diagnosis Behavior")
 DECLARE dtgp_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtgp_cat_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtgp_pref_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtgp_value_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtgp_att_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtgp_temp = vc WITH protect, noconstant("")
 DECLARE dtgp_temp2 = vc WITH protect, noconstant("")
 DECLARE dtgp_start_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE dtgp_load_pref(dls_rs=vc(ref),dlp_mnemonic=vc,dlp_pref_name=vc,dlp_cat_idx=i4) = null
 DECLARE dtgp_get_prefdir_data(dgpd_rs=vc(ref),dgpd_entry=vc,dgpd_mnem=vc,dgpd_pref_name=vc,
  dgpd_cat_cnt=i4) = null
 DECLARE dtgp_get_nvp_data(dgnd_rs=vc(ref),dgnd_name=vc,dgnd_mnem=vc,dgnd_pref_name=vc,dgnd_cat_cnt=
  i4) = null
 IF ((validate(dtgp_reply->cat_cnt,- (1))=- (1)))
  FREE RECORD dtgp_reply
  RECORD dtgp_reply(
    1 cat_cnt = i4
    1 cat_qual[*]
      2 cat_name = vc
      2 pref_cnt = i4
      2 pref_qual[*]
        3 mnemonic = vc
        3 pref_name = vc
        3 value_cnt = i4
        3 value_qual[*]
          4 value = vc
          4 owner_type = vc
          4 owner_name = vc
          4 owner_activeness = i2
          4 att_cnt = i4
          4 att_qual[*]
            5 att_name = vc
            5 att_value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET dm_err->eproc = "Starting dm_txtfnd_get_prefs"
 IF (check_logfile("dm_txtfnd_prefs",".log","DM_TXTFND_GET_PREFS LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Gather Diagnosis Behavior Prefs"
 SET dtgp_reply->cat_cnt = (dtgp_reply->cat_cnt+ 1)
 SET stat = alterlist(dtgp_reply->cat_qual,dtgp_reply->cat_cnt)
 SET dtgp_reply->cat_qual[dtgp_reply->cat_cnt].cat_name = "Diagnosis Behavior Preference(s)"
 SET dtgp_cat_cnt = dtgp_reply->cat_cnt
 SELECT INTO "NL:"
  cnt = count(*)
  FROM user_tab_columns u
  WHERE u.table_name="ORDER_DIAG_CONFIG"
   AND u.column_name IN ("CONFIG_MEANING", "CATALOG_TYPE_CD", "CONFIG_VALUE", "VENUE_TYPE_FLAG")
  DETAIL
   dtgp_cnt = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dtgp_cnt=4)
  SELECT INTO "NL:"
   FROM order_diag_config o,
    code_value cv1,
    code_value cv2
   WHERE o.config_meaning="DXVOCAB"
    AND cv1.code_value=o.catalog_type_cd
    AND cv2.code_value=o.config_value
   DETAIL
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt+ 1),
    stat = alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual,dtgp_reply->cat_qual[dtgp_cat_cnt].
     pref_cnt), dtgp_pref_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt,
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_dcp_mnem1, dtgp_reply
    ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_dcp_desc1, dtgp_reply->
    cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].
    pref_qual[dtgp_pref_cnt].value_cnt+ 1),
    dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
    alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt),
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
    cv2.display,
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_cnt =
    (dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_cnt+
    1), dtgp_att_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[
    dtgp_value_cnt].att_cnt, stat = alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[
     dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual,dtgp_att_cnt),
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
    dtgp_att_cnt].att_name = "Catalog Type"
    IF (o.catalog_type_cd=0.0)
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
     dtgp_att_cnt].att_value = "All"
    ELSE
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
     dtgp_att_cnt].att_value = cv1.display
    ENDIF
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_cnt =
    (dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_cnt+
    1), dtgp_att_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[
    dtgp_value_cnt].att_cnt, stat = alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[
     dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual,dtgp_att_cnt),
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
    dtgp_att_cnt].att_name = "Order Type"
    IF (o.venue_type_flag=0)
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
     dtgp_att_cnt].att_value = "All"
    ELSEIF (o.venue_type_flag=1)
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
     dtgp_att_cnt].att_value = "Inpatient"
    ELSEIF (o.venue_type_flag=2)
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
     dtgp_att_cnt].att_value = "Outpatient"
    ELSEIF (o.venue_type_flag=3)
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
     dtgp_att_cnt].att_value = "Prescription"
    ELSE
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[
     dtgp_att_cnt].att_value = "Unknown"
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL dtgp_load_pref(dtgp_reply,dtgp_dcp_mnem1,dtgp_dcp_desc1,dtgp_cat_cnt)
 SET dm_err->eproc = "Gather prefs for Health Information Management"
 SET dtgp_reply->cat_cnt = (dtgp_reply->cat_cnt+ 1)
 SET stat = alterlist(dtgp_reply->cat_qual,dtgp_reply->cat_cnt)
 SET dtgp_reply->cat_qual[dtgp_reply->cat_cnt].cat_name =
 "Health Information Management Preference(s)"
 SET dtgp_cat_cnt = dtgp_reply->cat_cnt
 SELECT INTO "NL:"
  cnt = count(*)
  FROM user_tab_columns u
  WHERE u.table_name="PRINCIPLE_TYPE_VOCAB_RELTN"
   AND u.column_name IN ("ACTIVE_IND", "BEG_EFFECTIVE_DT_TM", "END_EFFECTIVE_DT_TM",
  "SOURCE_VOCAB_CD", "PRINCIPLE_TYPE_FLAG")
  DETAIL
   dtgp_cnt = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dtgp_cnt=5)
  SELECT INTO "NL:"
   c.display
   FROM principle_type_vocab_reltn p,
    code_value c
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND p.principle_type_flag=2
    AND c.code_value=p.source_vocab_cd
   HEAD REPORT
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt+ 1),
    dtgp_pref_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt, stat = alterlist(dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual,dtgp_pref_cnt),
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_him_mnem1, dtgp_reply
    ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_him_desc1
   DETAIL
    IF ((dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt=0))
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[
     dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt+ 1), dtgp_value_cnt = dtgp_reply->cat_qual[
     dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat = alterlist(dtgp_reply->cat_qual[
      dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt),
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value = c
     .display
    ELSE
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
     concat(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].
      value,", ",c.display)
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL dtgp_load_pref(dtgp_reply,dtgp_him_mnem1,dtgp_him_desc1,dtgp_cat_cnt)
 SET dm_err->eproc = "Gather prefs for Charge Services"
 SET dtgp_reply->cat_cnt = (dtgp_reply->cat_cnt+ 1)
 SET stat = alterlist(dtgp_reply->cat_qual,dtgp_reply->cat_cnt)
 SET dtgp_reply->cat_qual[dtgp_reply->cat_cnt].cat_name = "Charge Services Preference(s)"
 SET dtgp_cat_cnt = dtgp_reply->cat_cnt
 SELECT INTO "NL:"
  cnt = count(*)
  FROM user_tab_columns u
  WHERE u.table_name="DM_INFO"
   AND u.column_name="INFO_DOMAIN_ID"
  DETAIL
   dtgp_cnt = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dtgp_cnt=0)
  SELECT INTO "NL:"
   FROM dm_info d,
    code_value c
   WHERE d.info_domain="CHARGE SERVICES"
    AND d.info_name IN ("ICD10 COMPLIANCE DATE", "ICD PRINCIPAL DIAGNOSIS TYPE",
   "ICD PRINCIPAL PROCEDURE TYPE")
    AND c.code_value=d.info_long_id
   DETAIL
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt+ 1),
    dtgp_pref_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt, stat = alterlist(dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual,dtgp_pref_cnt)
    IF (d.info_name="ICD10 COMPLIANCE DATE")
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_cs_mnem1, dtgp_reply
     ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_cs_desc1, dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].
     pref_qual[dtgp_pref_cnt].value_cnt+ 1),
     dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
     alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt),
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
     format(d.info_date,"DD-MMM-YYYY ;;Q")
    ELSEIF (d.info_name="ICD PRINCIPAL DIAGNOSIS TYPE")
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_cs_mnem2, dtgp_reply
     ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_cs_desc2, dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].
     pref_qual[dtgp_pref_cnt].value_cnt+ 1),
     dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
     alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt)
     IF (d.info_long_id=0)
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      "N/A"
     ELSE
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      c.display
     ENDIF
    ELSE
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_cs_mnem3, dtgp_reply
     ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_cs_desc3, dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].
     pref_qual[dtgp_pref_cnt].value_cnt+ 1),
     dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
     alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt)
     IF (d.info_long_id=0)
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      "N/A"
     ELSE
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      c.display
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "NL:"
   FROM dm_info d,
    code_value c,
    logical_domain l
   WHERE d.info_domain="CHARGE SERVICES"
    AND d.info_name IN ("ICD10 COMPLIANCE DATE", "ICD PRINCIPAL DIAGNOSIS TYPE",
   "ICD PRINCIPAL PROCEDURE TYPE")
    AND c.code_value=d.info_long_id
    AND l.logical_domain_id=d.info_domain_id
   DETAIL
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt+ 1),
    dtgp_pref_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt, stat = alterlist(dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual,dtgp_pref_cnt)
    IF (d.info_name="ICD10 COMPLIANCE DATE")
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_cs_mnem1, dtgp_reply
     ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_cs_desc1, dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].
     pref_qual[dtgp_pref_cnt].value_cnt+ 1),
     dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
     alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt),
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
     format(d.info_date,"DD-MMM-YYYY ;;Q")
     IF (d.info_domain_id > 0)
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].
      owner_type = "LOGICAL DOMAIN", dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].
      value_qual[dtgp_value_cnt].owner_name = l.mnemonic, dtgp_reply->cat_qual[dtgp_cat_cnt].
      pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].owner_activeness = l.active_ind
     ENDIF
    ELSEIF (d.info_name="ICD PRINCIPAL DIAGNOSIS TYPE")
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_cs_mnem2, dtgp_reply
     ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_cs_desc2, dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].
     pref_qual[dtgp_pref_cnt].value_cnt+ 1),
     dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
     alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt)
     IF (d.info_long_id=0)
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      "N/A"
     ELSE
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      c.display
     ENDIF
     IF (d.info_domain_id > 0)
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].
      owner_type = "LOGICAL DOMAIN", dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].
      value_qual[dtgp_value_cnt].owner_name = l.mnemonic, dtgp_reply->cat_qual[dtgp_cat_cnt].
      pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].owner_activeness = l.active_ind
     ENDIF
    ELSE
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_cs_mnem3, dtgp_reply
     ->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_cs_desc3, dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].
     pref_qual[dtgp_pref_cnt].value_cnt+ 1),
     dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
     alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt)
     IF (d.info_long_id=0)
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      "N/A"
     ELSE
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
      c.display
     ENDIF
     IF (d.info_domain_id > 0)
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].
      owner_type = "LOGICAL DOMAIN", dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].
      value_qual[dtgp_value_cnt].owner_name = l.mnemonic, dtgp_reply->cat_qual[dtgp_cat_cnt].
      pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].owner_activeness = l.active_ind
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL dtgp_load_pref(dtgp_reply,dtgp_cs_mnem1,dtgp_cs_desc1,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_cs_mnem2,dtgp_cs_desc2,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_cs_mnem3,dtgp_cs_desc3,dtgp_cat_cnt)
 SET dm_err->eproc = "Gather prefs for Scheduling"
 SET dtgp_reply->cat_cnt = (dtgp_reply->cat_cnt+ 1)
 SET stat = alterlist(dtgp_reply->cat_qual,dtgp_reply->cat_cnt)
 SET dtgp_reply->cat_qual[dtgp_reply->cat_cnt].cat_name = "Scheduling Preference(s)"
 SET dtgp_cat_cnt = dtgp_reply->cat_cnt
 SELECT INTO "NL:"
  cnt = count(*)
  FROM user_tab_columns u
  WHERE u.table_name="SCH_PREF"
   AND u.column_name IN ("PREF_TYPE_MEANING", "PREF_STRING", "PREF_DT_TM")
  DETAIL
   dtgp_cnt = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dtgp_cnt=3)
  SELECT INTO "NL:"
   FROM sch_pref s
   WHERE s.pref_type_meaning IN ("ICD9SRCHFLTR", "ICD9T10DATE", "SNDXSRCHFLTR")
   DETAIL
    dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt = (dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt+ 1),
    dtgp_pref_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_cnt, stat = alterlist(dtgp_reply->
     cat_qual[dtgp_cat_cnt].pref_qual,dtgp_pref_cnt)
    IF (((s.pref_type_meaning="ICD9SRCHFLTR") OR ("SNDXSRCHFLTR")) )
     IF (s.pref_type_meaning="ICD9SRCHFLTR")
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_sch_mnem1,
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_sch_desc1
     ELSEIF (s.pref_type_meaning="SNDXSRCHFLTR")
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_sch_mnem3,
      dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_sch_desc3
     ENDIF
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[
     dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt+ 1), dtgp_value_cnt = dtgp_reply->cat_qual[
     dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat = alterlist(dtgp_reply->cat_qual[
      dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt),
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value = s
     .pref_string
    ELSE
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].mnemonic = dtgp_sch_mnem2,
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].pref_name = dtgp_sch_desc2,
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt = (dtgp_reply->cat_qual[
     dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt+ 1),
     dtgp_value_cnt = dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_cnt, stat =
     alterlist(dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual,dtgp_value_cnt),
     dtgp_reply->cat_qual[dtgp_cat_cnt].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value =
     format(s.pref_dt_tm,"DD-MMM-YYYY ;;Q")
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL dtgp_load_pref(dtgp_reply,dtgp_sch_mnem1,dtgp_sch_desc1,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_sch_mnem2,dtgp_sch_desc2,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_sch_mnem3,dtgp_sch_desc3,dtgp_cat_cnt)
 SET dm_err->eproc = "Gather prefs in the PREFDIR tables"
 SET dtgp_reply->cat_cnt = (dtgp_reply->cat_cnt+ 1)
 SET stat = alterlist(dtgp_reply->cat_qual,dtgp_reply->cat_cnt)
 SET dtgp_reply->cat_qual[dtgp_reply->cat_cnt].cat_name = "Preference Manager Preference(s)"
 SET dtgp_cat_cnt = dtgp_reply->cat_cnt
 SELECT INTO "NL:"
  cnt = count(*)
  FROM user_tables u
  WHERE u.table_name IN ("PREFDIR_ENTRY", "PREFDIR_CONTEXT", "PREFDIR_VALUE", "PREFDIR_ENTRYDATA",
  "PREFDIR_DISPLAYNAME")
  DETAIL
   dtgp_cnt = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dtgp_cnt=5)
  CALL dtgp_get_prefdir_data(dtgp_reply,"diagnosis search",dtgp_pdir_mnem1,dtgp_pdir_desc1,
   dtgp_cat_cnt)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dtgp_get_prefdir_data(dtgp_reply,"diagnosis search-terminology",dtgp_pdir_mnem2,
   dtgp_pdir_desc2,dtgp_cat_cnt)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dtgp_get_prefdir_data(dtgp_reply,"diagnosis search-terminology axis",dtgp_pdir_mnem3,
   dtgp_pdir_desc3,dtgp_cat_cnt)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL dtgp_load_pref(dtgp_reply,dtgp_pdir_mnem1,dtgp_pdir_desc1,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_pdir_mnem2,dtgp_pdir_desc2,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_pdir_mnem3,dtgp_pdir_desc3,dtgp_cat_cnt)
 SET dm_err->eproc = "Gather prefs in the NVP table"
 SET dtgp_reply->cat_cnt = (dtgp_reply->cat_cnt+ 1)
 SET stat = alterlist(dtgp_reply->cat_qual,dtgp_reply->cat_cnt)
 SET dtgp_reply->cat_qual[dtgp_reply->cat_cnt].cat_name = "Cerner Practice Wizard Preference(s)"
 SET dtgp_cat_cnt = dtgp_reply->cat_cnt
 SELECT INTO "NL:"
  cnt = count(*)
  FROM user_tables u
  WHERE u.table_name IN ("NAME_VALUE_PREFS", "APP_PREFS", "DETAIL_PREFS", "VIEW_PREFS",
  "VIEW_COMP_PREFS")
  DETAIL
   dtgp_cnt = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dtgp_cnt=5)
  CALL dtgp_get_nvp_data(dtgp_reply,"DX_TARGET_VOCABULARY",dtgp_nvp_mnem1,dtgp_nvp_desc1,dtgp_cat_cnt
   )
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dtgp_get_nvp_data(dtgp_reply,"PL_Auth_Vocab*",dtgp_nvp_mnem2,dtgp_nvp_desc2,dtgp_cat_cnt)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dtgp_get_nvp_data(dtgp_reply,"PL_Vocab*",dtgp_nvp_mnem3,dtgp_nvp_desc3,dtgp_cat_cnt)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dtgp_get_nvp_data(dtgp_reply,"PL_TARGET_VOCABULARY",dtgp_nvp_mnem4,dtgp_nvp_desc4,dtgp_cat_cnt
   )
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dtgp_get_nvp_data(dtgp_reply,"DX_VOCAB*",dtgp_nvp_mnem5,dtgp_nvp_desc5,dtgp_cat_cnt)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dtgp_get_nvp_data(dtgp_reply,"DX_Auth_Vocab*",dtgp_nvp_mnem6,dtgp_nvp_desc6,dtgp_cat_cnt)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL dtgp_load_pref(dtgp_reply,dtgp_nvp_mnem1,dtgp_nvp_desc1,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_nvp_mnem2,dtgp_nvp_desc2,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_nvp_mnem3,dtgp_nvp_desc3,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_nvp_mnem4,dtgp_nvp_desc4,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_nvp_mnem5,dtgp_nvp_desc5,dtgp_cat_cnt)
 CALL dtgp_load_pref(dtgp_reply,dtgp_nvp_mnem6,dtgp_nvp_desc6,dtgp_cat_cnt)
 SELECT INTO "dm_txtfnd_pref_data.csv"
  FROM (dummyt d  WITH seq = dtgp_reply->cat_cnt)
  DETAIL
   IF (d.seq=1)
    col 0,
    "Category,Preference,Attributes,Value,Owner_Type, Owner_Name, Owner_Activeness, Report Date/Time",
    row + 1
   ENDIF
   col 0
   FOR (dtgp_pref_cnt = 1 TO dtgp_reply->cat_qual[d.seq].pref_cnt)
     FOR (dtgp_value_cnt = 1 TO dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_cnt)
       dtgp_temp = ""
       FOR (dtgp_att_cnt = 1 TO dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_qual[
       dtgp_value_cnt].att_cnt)
         IF (dtgp_att_cnt=1)
          dtgp_temp = concat(dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_qual[
           dtgp_value_cnt].att_qual[dtgp_att_cnt].att_name,"= ",dtgp_reply->cat_qual[d.seq].
           pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[dtgp_att_cnt].att_value)
         ELSE
          dtgp_temp = concat(dtgp_temp,"| ",dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].
           value_qual[dtgp_value_cnt].att_qual[dtgp_att_cnt].att_name,"= ",dtgp_reply->cat_qual[d.seq
           ].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].att_qual[dtgp_att_cnt].att_value)
         ENDIF
       ENDFOR
       dtgp_temp2 = concat('"',replace(dtgp_reply->cat_qual[d.seq].cat_name,'"',"'",0),'","',replace(
         dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].pref_name,'"',"'",0),'",')
       IF (dtgp_temp <= " ")
        dtgp_temp2 = concat(dtgp_temp2,'" ",')
       ELSE
        dtgp_temp2 = concat(dtgp_temp2,'"',replace(dtgp_temp,'"',"'",0),'",')
       ENDIF
       IF ((dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].value <=
       " "))
        dtgp_temp2 = concat(dtgp_temp2,'" ",')
       ELSE
        dtgp_temp2 = concat(dtgp_temp2,'"',replace(dtgp_reply->cat_qual[d.seq].pref_qual[
          dtgp_pref_cnt].value_qual[dtgp_value_cnt].value,'"',"'",0),'",')
       ENDIF
       IF ((dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].
       owner_type <= " "))
        dtgp_temp2 = concat(dtgp_temp2,'" ",')
       ELSE
        dtgp_temp2 = concat(dtgp_temp2,'"',replace(dtgp_reply->cat_qual[d.seq].pref_qual[
          dtgp_pref_cnt].value_qual[dtgp_value_cnt].owner_type,'"',"'",0),'",')
       ENDIF
       IF ((dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].
       owner_name <= " "))
        dtgp_temp2 = concat(dtgp_temp2,'" ",')
       ELSE
        dtgp_temp2 = concat(dtgp_temp2,'"',replace(dtgp_reply->cat_qual[d.seq].pref_qual[
          dtgp_pref_cnt].value_qual[dtgp_value_cnt].owner_name,'"',"'",0),'",')
       ENDIF
       IF ((dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_qual[dtgp_value_cnt].
       owner_name <= " "))
        dtgp_temp2 = concat(dtgp_temp2,'" ",')
       ELSE
        dtgp_temp2 = concat(dtgp_temp2,'"',evaluate(dtgp_reply->cat_qual[d.seq].pref_qual[
          dtgp_pref_cnt].value_qual[dtgp_value_cnt].owner_activeness,- (1),"N/A",0,"INACTIVE",
          1,"ACTIVE",cnvtstring(dtgp_reply->cat_qual[d.seq].pref_qual[dtgp_pref_cnt].value_qual[
           dtgp_value_cnt].owner_activeness)),'",')
       ENDIF
       dtgp_temp2 = concat(dtgp_temp2,'"',format(dtgp_start_dt_tm,"DD-MMM-YYYY HH:MM:SS ;;Q"),'"'),
       dtgp_temp2, row + 1
     ENDFOR
   ENDFOR
  WITH nocounter, maxrow = 1, maxcol = 4000,
   format = variable, formfeed = none
 ;end select
 SUBROUTINE dtgp_load_pref(dlp_rs,dlp_mnemonic,dlp_pref_name,dlp_cat_idx)
   DECLARE dlp_idx = i4 WITH protect, noconstant(0)
   SET dlp_idx = locateval(dlp_idx,1,dlp_rs->cat_qual[dlp_cat_idx].pref_cnt,dlp_mnemonic,dlp_rs->
    cat_qual[dlp_cat_idx].pref_qual[dlp_idx].mnemonic)
   IF (dlp_idx=0)
    SET dlp_rs->cat_qual[dlp_cat_idx].pref_cnt = (dlp_rs->cat_qual[dlp_cat_idx].pref_cnt+ 1)
    SET stat = alterlist(dlp_rs->cat_qual[dlp_cat_idx].pref_qual,dlp_rs->cat_qual[dlp_cat_idx].
     pref_cnt)
    SET dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_rs->cat_qual[dlp_cat_idx].pref_cnt].mnemonic =
    dlp_mnemonic
    SET dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_rs->cat_qual[dlp_cat_idx].pref_cnt].pref_name =
    dlp_pref_name
    SET dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_rs->cat_qual[dlp_cat_idx].pref_cnt].value_cnt = 1
    SET stat = alterlist(dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_rs->cat_qual[dlp_cat_idx].
     pref_cnt].value_qual,1)
    SET dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_rs->cat_qual[dlp_cat_idx].pref_cnt].value_qual[1]
    .value = "N/A"
   ELSEIF ((dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_idx].value_cnt=0))
    SET dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_idx].value_cnt = 1
    SET stat = alterlist(dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_idx].value_qual,1)
    SET dlp_rs->cat_qual[dlp_cat_idx].pref_qual[dlp_idx].value_qual[1].value = "N/A"
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dtgp_get_prefdir_data(dgpd_rs,dgpd_entry,dgpd_mnem,dgpd_pref_name,dgpd_cat_cnt)
   DECLARE dgpd_last_entry_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgpd_entry_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgpd_loop = i4 WITH protect, noconstant(0)
   DECLARE dgpd_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgpd_val_loop = i4 WITH protect, noconstant(0)
   DECLARE dgpd_merge_name = vc WITH protect, noconstant("")
   DECLARE dgpd_display_field = vc WITH protect, noconstant("")
   DECLARE dgpd_pk_col = vc WITH protect, noconstant("")
   DECLARE dgpd_start = i4 WITH protect, noconstant(0)
   DECLARE dgpd_context_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dgpd_pref_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgpd_value_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgpd_att_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgpd_valid_idx = i4 WITH protect, noconstant(0)
   FREE RECORD dgpd_data
   RECORD dgpd_data(
     1 cnt = i4
     1 qual[*]
       2 not_valid_pref_ind = i2
       2 entry_id = f8
       2 entry = vc
       2 entry_value = vc
       2 context = vc
       2 context_value = vc
       2 context_id_as_vc = vc
       2 context_act_ind = i2
       2 all_numeric_ind = i2
       2 value_cnt = i4
       2 entry_data = vc
       2 value_qual[*]
         3 value_value = vc
   )
   FREE RECORD dgpd_pers
   RECORD dgpd_pers(
     1 cnt = i4
     1 valid_cnt = i4
     1 qual[*]
       2 person_id = f8
       2 valid_ind = i2
   )
   SELECT INTO "NL:"
    FROM prefdir_entry e,
     prefdir_context c,
     prefdir_value v,
     prefdir_entrydata d
    WHERE e.value=dgpd_entry
     AND c.entry_id=e.entry_id
     AND c.value != "reference"
     AND v.entry_id=e.entry_id
     AND d.entry_id=e.entry_id
    ORDER BY e.entry_id
    HEAD e.entry_id
     dgpd_data->cnt = (dgpd_data->cnt+ 1), stat = alterlist(dgpd_data->qual,dgpd_data->cnt),
     dgpd_data->qual[dgpd_data->cnt].entry_id = e.entry_id,
     dgpd_data->qual[dgpd_data->cnt].entry = e.value, dgpd_data->qual[dgpd_data->cnt].context = c
     .value, dgpd_data->qual[dgpd_data->cnt].entry_data = d.entry_data,
     dgpd_data->qual[dgpd_data->cnt].all_numeric_ind = 1
    DETAIL
     dgpd_data->qual[dgpd_data->cnt].value_cnt = (dgpd_data->qual[dgpd_data->cnt].value_cnt+ 1), stat
      = alterlist(dgpd_data->qual[dgpd_data->cnt].value_qual,dgpd_data->qual[dgpd_data->cnt].
      value_cnt), dgpd_data->qual[dgpd_data->cnt].value_qual[dgpd_data->qual[dgpd_data->cnt].
     value_cnt].value_value = v.value
     IF (isnumeric(v.value)=0)
      dgpd_data->qual[dgpd_data->cnt].all_numeric_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_cnt = (dgpd_rs->cat_qual[dgpd_cat_cnt].pref_cnt+ 1)
   SET dgpd_pref_cnt = dgpd_rs->cat_qual[dgpd_cat_cnt].pref_cnt
   SET stat = alterlist(dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual,dgpd_pref_cnt)
   SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].mnemonic = dgpd_mnem
   SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].pref_name = dgpd_pref_name
   FOR (dgpd_loop = 1 TO dgpd_data->cnt)
    IF ((dgpd_data->qual[dgpd_loop].context="default"))
     SET dgpd_data->qual[dgpd_loop].context_value = "System"
     SET dgpd_data->qual[dgpd_loop].context_act_ind = - (1)
    ELSE
     SET dgpd_done_ind = 0
     SET dgpd_context_found_ind = 0
     SET dgpd_last_entry_id = 0.0
     SET dgpd_entry_id = dgpd_data->qual[dgpd_loop].entry_id
     WHILE (dgpd_done_ind=0)
      SELECT INTO "NL:"
       FROM prefdir_entrydata d
       WHERE d.entry_id=dgpd_entry_id
       DETAIL
        IF (((d.dist_name=concat("prefcontext=",dgpd_data->qual[dgpd_loop].context,
         ",prefroot=prefroot")) OR (d.parent_id=1.0)) )
         dgpd_done_ind = 1
        ENDIF
        IF (d.dist_name=concat("prefcontext=",dgpd_data->qual[dgpd_loop].context,",prefroot=prefroot"
         ))
         dgpd_context_found_ind = 1
        ELSE
         dgpd_last_entry_id = d.entry_id, dgpd_entry_id = d.parent_id
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(null)
      ENDIF
     ENDWHILE
     IF (dgpd_context_found_ind=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Could not find context level for ENTRY_ID = ",trim(cnvtstring(
         dgpd_data->qual[dgpd_loop].entry_id,20,1)))
      RETURN(null)
     ELSE
      SELECT INTO "NL:"
       FROM prefdir_displayname d
       WHERE d.entry_id=dgpd_last_entry_id
       DETAIL
        dgpd_data->qual[dgpd_loop].context_value = d.value, dgpd_data->qual[dgpd_loop].
        context_act_ind = - (1)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(null)
      ENDIF
      IF (cnvtlower(dgpd_data->qual[dgpd_loop].context) IN ("user", "position"))
       SET dgpd_pers->cnt = 0
       SET dgpd_pers->valid_cnt = 0
       SELECT INTO "NL:"
        FROM prefdir_group g
        WHERE g.entry_id=dgpd_last_entry_id
         AND isnumeric(g.value) > 0
        DETAIL
         dgpd_pers->cnt = (dgpd_pers->cnt+ 1), stat = alterlist(dgpd_pers->qual,dgpd_pers->cnt),
         dgpd_pers->qual[dgpd_pers->cnt].person_id = cnvtreal(g.value)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(null)
       ENDIF
       IF ((dgpd_pers->cnt=1))
        SET dgpd_pers->valid_cnt = 1
        SET dgpd_pers->qual[1].valid_ind = 1
       ELSE
        FOR (dgpd_val_loop = 1 TO dgpd_pers->cnt)
         SELECT INTO "NL:"
          FROM prefdir_entrydata p
          WHERE p.entry_id=dgpd_last_entry_id
           AND p.dist_name=concat("*,prefgroup=",trim(cnvtstring(dgpd_pers->qual[dgpd_val_loop].
             person_id,20,2)),",prefcontext=*")
          DETAIL
           dgpd_pers->qual[dgpd_val_loop].valid_ind = 1, dgpd_pers->valid_cnt = (dgpd_pers->valid_cnt
           + 1)
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(null)
         ENDIF
        ENDFOR
       ENDIF
       IF ((dgpd_pers->valid_cnt=1))
        SET dgpd_valid_idx = locateval(dgpd_valid_idx,1,dgpd_pers->cnt,1,dgpd_pers->qual[
         dgpd_valid_idx].valid_ind)
        IF (cnvtlower(dgpd_data->qual[dgpd_loop].context)="user")
         SELECT INTO "NL:"
          FROM prsnl p
          WHERE (p.person_id=dgpd_pers->qual[dgpd_valid_idx].person_id)
          DETAIL
           dgpd_data->qual[dgpd_loop].context_act_ind = p.active_ind
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(null)
         ENDIF
        ELSEIF (cnvtlower(dgpd_data->qual[dgpd_loop].context)="position")
         SELECT INTO "NL:"
          FROM code_value c
          WHERE (c.code_value=dgpd_pers->qual[dgpd_valid_idx].person_id)
          DETAIL
           dgpd_data->qual[dgpd_loop].context_act_ind = c.active_ind
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(null)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((dgpd_data->qual[dgpd_loop].not_valid_pref_ind=0))
     FOR (dgpd_val_loop = 1 TO dgpd_data->qual[dgpd_loop].value_cnt)
       IF ((dgpd_data->qual[dgpd_loop].all_numeric_ind=0))
        IF (dgpd_val_loop=1)
         SET dgpd_data->qual[dgpd_loop].entry_value = dgpd_data->qual[dgpd_loop].value_qual[
         dgpd_val_loop].value_value
        ELSE
         SET dgpd_data->qual[dgpd_loop].entry_value = concat(dgpd_data->qual[dgpd_loop].entry_value,
          ", ",dgpd_data->qual[dgpd_loop].value_qual[dgpd_val_loop].value_value)
        ENDIF
       ELSE
        IF (dgpd_val_loop=1)
         SET dgpd_start = findstring("mergename=",dgpd_data->qual[dgpd_loop].entry_data,1,0)
         IF (dgpd_start > 0)
          SET dgpd_merge_name = substring((dgpd_start+ 10),((findstring(",",dgpd_data->qual[dgpd_loop
            ].entry_data,dgpd_start,0) - dgpd_start) - 10),dgpd_data->qual[dgpd_loop].entry_data)
         ENDIF
         SET dgpd_start = findstring("fieldname=",dgpd_data->qual[dgpd_loop].entry_data,1,0)
         IF (dgpd_start > 0)
          SET dgpd_display_field = substring((dgpd_start+ 10),((findstring(",",dgpd_data->qual[
            dgpd_loop].entry_data,dgpd_start,0) - dgpd_start) - 10),dgpd_data->qual[dgpd_loop].
           entry_data)
         ENDIF
         SET dgpd_start = findstring("keyname=",dgpd_data->qual[dgpd_loop].entry_data,1,0)
         IF (dgpd_start > 0)
          SET dgpd_pk_col = substring((dgpd_start+ 8),((findstring(",",dgpd_data->qual[dgpd_loop].
            entry_data,dgpd_start,0) - dgpd_start) - 8),dgpd_data->qual[dgpd_loop].entry_data)
         ENDIF
        ENDIF
        IF (((dgpd_pk_col <= " ") OR (((dgpd_display_field <= " ") OR (dgpd_merge_name <= " ")) )) )
         IF (dgpd_val_loop=1)
          SET dgpd_data->qual[dgpd_loop].entry_value = dgpd_data->qual[dgpd_loop].value_qual[
          dgpd_val_loop].value_value
         ELSE
          SET dgpd_data->qual[dgpd_loop].entry_value = concat(dgpd_data->qual[dgpd_loop].entry_value,
           ", ",dgpd_data->qual[dgpd_loop].value_qual[dgpd_val_loop].value_value)
         ENDIF
        ELSE
         CALL parser(concat("select into 'NL:' from ",dgpd_merge_name," d"),0)
         CALL parser(concat("where d.",dgpd_pk_col,
           " = cnvtreal(dgpd_data->qual[dgpd_loop].value_qual[dgpd_val_loop].value_value)"),0)
         CALL parser(concat(
           " detail if (dgpd_val_loop = 1) dgpd_data->qual[dgpd_loop].entry_value = d.",
           dgpd_display_field),0)
         CALL parser(concat(
           " else dgpd_data->qual[dgpd_loop].entry_value = concat(dgpd_data->qual[dgpd_loop].entry_value, ",
           "', ', d.",dgpd_display_field,") endif with nocounter go"),1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(null)
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_cnt = (dgpd_rs->cat_qual[
     dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_cnt+ 1)
     SET dgpd_value_cnt = dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_cnt
     SET stat = alterlist(dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual,
      dgpd_value_cnt)
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].value =
     dgpd_data->qual[dgpd_loop].entry_value
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].att_cnt
      = (dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].att_cnt
     + 1)
     SET dgpd_att_cnt = dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[
     dgpd_value_cnt].att_cnt
     SET stat = alterlist(dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[
      dgpd_value_cnt].att_qual,dgpd_att_cnt)
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
     att_qual[dgpd_att_cnt].att_name = "Context Category"
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
     att_qual[dgpd_att_cnt].att_value = dgpd_data->qual[dgpd_loop].context
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].att_cnt
      = (dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].att_cnt
     + 1)
     SET dgpd_att_cnt = dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[
     dgpd_value_cnt].att_cnt
     SET stat = alterlist(dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[
      dgpd_value_cnt].att_qual,dgpd_att_cnt)
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
     att_qual[dgpd_att_cnt].att_name = "Context Value"
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
     att_qual[dgpd_att_cnt].att_value = dgpd_data->qual[dgpd_loop].context_value
     IF (cnvtlower(dgpd_data->qual[dgpd_loop].context)="user")
      SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
      owner_type = "User"
     ELSEIF (cnvtlower(dgpd_data->qual[dgpd_loop].context)="position")
      SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
      owner_type = "Position"
     ELSE
      SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
      owner_type = dgpd_data->qual[dgpd_loop].context
     ENDIF
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
     owner_name = dgpd_data->qual[dgpd_loop].context_value
     SET dgpd_rs->cat_qual[dgpd_cat_cnt].pref_qual[dgpd_pref_cnt].value_qual[dgpd_value_cnt].
     owner_activeness = dgpd_data->qual[dgpd_loop].context_act_ind
    ENDIF
   ENDFOR
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dtgp_get_nvp_data(dgnd_rs,dgnd_name,dgnd_mnem,dgnd_pref_name,dgnd_cat_cnt)
   DECLARE dgnd_loop = i4 WITH protect, noconstant(0)
   DECLARE dgnd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgnd_temp = vc WITH protect, noconstant("")
   DECLARE dgnd_cv_idx = i4 WITH protect, noconstant(0)
   DECLARE dgnd_pref_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgnd_value_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgnd_att_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgnd_temp_str = vc WITH protect, noconstant("")
   DECLARE dgnd_app = i4 WITH protect, noconstant(0)
   DECLARE dgnd_pos = f8 WITH protect, noconstant(0.0)
   DECLARE dgnd_prsnl = f8 WITH protect, noconstant(0.0)
   DECLARE dgnd_view = vc WITH protect, noconstant("")
   DECLARE dgnd_comp = vc WITH protect, noconstant("")
   FREE RECORD dgnd_data
   RECORD dgnd_data(
     1 cnt = i4
     1 qual[*]
       2 app_name = vc
       2 good_ind = i2
       2 pos_value = vc
       2 pos_act_ind = i2
       2 user_name = vc
       2 user_act_ind = i4
       2 pe_name = vc
       2 other = vc
       2 other2 = vc
       2 pvc_name = vc
       2 det_cnt = i4
       2 det_qual[*]
         3 pvc_value = vc
         3 merge_name = vc
         3 merge_id = f8
         3 merge_value = vc
   )
   FREE RECORD dgnd_cv
   RECORD dgnd_cv(
     1 cnt = i4
     1 qual[*]
       2 merge_name = vc
       2 merge_id = f8
       2 merge_value = vc
   )
   SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_cnt = (dgnd_rs->cat_qual[dgnd_cat_cnt].pref_cnt+ 1)
   SET dgnd_pref_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_cnt
   SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual,dgnd_pref_cnt)
   SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].mnemonic = dgnd_mnem
   SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].pref_name = concat(dgnd_pref_name,
    " (",dgnd_name,")")
   SET dgnd_app = - (1)
   SET dgnd_pos = - (1.0)
   SET dgnd_prsnl = - (1.0)
   SET dgnd_view = "txtfnd"
   SET dgnd_comp = "txtfnd"
   SELECT INTO "NL:"
    FROM app_prefs a,
     name_value_prefs n,
     application ap,
     code_value c,
     prsnl p
    WHERE n.parent_entity_name="APP_PREFS"
     AND n.pvc_name=patstring(dgnd_name)
     AND a.app_prefs_id=n.parent_entity_id
     AND a.active_ind=1
     AND ap.application_number=a.application_number
     AND c.code_value=a.position_cd
     AND p.person_id=a.prsnl_id
    ORDER BY a.application_number, a.position_cd, a.prsnl_id
    DETAIL
     IF (((a.application_number != dgnd_app) OR (((a.position_cd != dgnd_pos) OR (a.prsnl_id !=
     dgnd_prsnl)) )) )
      dgnd_data->cnt = (dgnd_data->cnt+ 1), stat = alterlist(dgnd_data->qual,dgnd_data->cnt),
      dgnd_data->qual[dgnd_data->cnt].app_name = ap.description
      IF (a.position_cd > 0)
       dgnd_data->qual[dgnd_data->cnt].pos_value = c.display, dgnd_data->qual[dgnd_data->cnt].
       pos_act_ind = c.active_ind
      ENDIF
      IF (a.prsnl_id > 0)
       dgnd_data->qual[dgnd_data->cnt].user_name = p.name_full_formatted, dgnd_data->qual[dgnd_data->
       cnt].user_act_ind = p.active_ind
      ENDIF
      dgnd_data->qual[dgnd_data->cnt].pvc_name = dgnd_name, dgnd_app = a.application_number, dgnd_pos
       = a.position_cd,
      dgnd_prsnl = a.prsnl_id
     ENDIF
     dgnd_data->qual[dgnd_data->cnt].det_cnt = (dgnd_data->qual[dgnd_data->cnt].det_cnt+ 1), dgnd_cnt
      = dgnd_data->qual[dgnd_data->cnt].det_cnt, stat = alterlist(dgnd_data->qual[dgnd_data->cnt].
      det_qual,dgnd_cnt),
     dgnd_data->qual[dgnd_data->cnt].det_qual[dgnd_cnt].pvc_value = n.pvc_value, dgnd_data->qual[
     dgnd_data->cnt].det_qual[dgnd_cnt].merge_name = n.merge_name, dgnd_data->qual[dgnd_data->cnt].
     det_qual[dgnd_cnt].merge_id = n.merge_id,
     dgnd_cv_idx = locateval(dgnd_cv_idx,1,dgnd_cv->cnt,n.merge_name,dgnd_cv->qual[dgnd_cv_idx].
      merge_name,
      n.merge_id,dgnd_cv->qual[dgnd_cv_idx].merge_id)
     IF (dgnd_cv_idx=0)
      dgnd_cv->cnt = (dgnd_cv->cnt+ 1), stat = alterlist(dgnd_cv->qual,dgnd_cv->cnt), dgnd_cv->qual[
      dgnd_cv->cnt].merge_name = n.merge_name,
      dgnd_cv->qual[dgnd_cv->cnt].merge_id = n.merge_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dgnd_app = - (1)
   SET dgnd_pos = - (1.0)
   SET dgnd_prsnl = - (1.0)
   SET dgnd_view = "txtfnd"
   SET dgnd_comp = "txtfnd"
   SELECT INTO "NL:"
    FROM detail_prefs a,
     name_value_prefs n,
     application ap,
     code_value c,
     prsnl p
    WHERE n.parent_entity_name="DETAIL_PREFS"
     AND n.pvc_name=patstring(dgnd_name)
     AND a.detail_prefs_id=n.parent_entity_id
     AND a.active_ind=1
     AND ap.application_number=a.application_number
     AND c.code_value=a.position_cd
     AND p.person_id=a.prsnl_id
    ORDER BY a.application_number, a.position_cd, a.prsnl_id,
     a.view_name, a.comp_name
    DETAIL
     IF (((a.application_number != dgnd_app) OR (((a.position_cd != dgnd_pos) OR (((a.prsnl_id !=
     dgnd_prsnl) OR (((a.view_name != dgnd_view) OR (a.comp_name != dgnd_comp)) )) )) )) )
      dgnd_data->cnt = (dgnd_data->cnt+ 1), stat = alterlist(dgnd_data->qual,dgnd_data->cnt),
      dgnd_data->qual[dgnd_data->cnt].app_name = ap.description
      IF (a.position_cd > 0)
       dgnd_data->qual[dgnd_data->cnt].pos_value = c.display, dgnd_data->qual[dgnd_data->cnt].
       pos_act_ind = c.active_ind
      ENDIF
      IF (a.prsnl_id > 0)
       dgnd_data->qual[dgnd_data->cnt].user_name = p.name_full_formatted, dgnd_data->qual[dgnd_data->
       cnt].user_act_ind = p.active_ind
      ENDIF
      dgnd_data->qual[dgnd_data->cnt].other = a.view_name, dgnd_data->qual[dgnd_data->cnt].other2 = a
      .comp_name, dgnd_data->qual[dgnd_data->cnt].pe_name = n.parent_entity_name,
      dgnd_data->qual[dgnd_data->cnt].pvc_name = dgnd_name, dgnd_app = a.application_number, dgnd_pos
       = a.position_cd,
      dgnd_prsnl = a.prsnl_id, dgnd_view = a.view_name, dgnd_comp = a.comp_name
     ENDIF
     dgnd_data->qual[dgnd_data->cnt].det_cnt = (dgnd_data->qual[dgnd_data->cnt].det_cnt+ 1), dgnd_cnt
      = dgnd_data->qual[dgnd_data->cnt].det_cnt, stat = alterlist(dgnd_data->qual[dgnd_data->cnt].
      det_qual,dgnd_cnt),
     dgnd_data->qual[dgnd_data->cnt].det_qual[dgnd_cnt].pvc_value = n.pvc_value, dgnd_data->qual[
     dgnd_data->cnt].det_qual[dgnd_cnt].merge_name = n.merge_name, dgnd_data->qual[dgnd_data->cnt].
     det_qual[dgnd_cnt].merge_id = n.merge_id,
     dgnd_cv_idx = locateval(dgnd_cv_idx,1,dgnd_cv->cnt,n.merge_name,dgnd_cv->qual[dgnd_cv_idx].
      merge_name,
      n.merge_id,dgnd_cv->qual[dgnd_cv_idx].merge_id)
     IF (dgnd_cv_idx=0)
      dgnd_cv->cnt = (dgnd_cv->cnt+ 1), stat = alterlist(dgnd_cv->qual,dgnd_cv->cnt), dgnd_cv->qual[
      dgnd_cv->cnt].merge_name = n.merge_name,
      dgnd_cv->qual[dgnd_cv->cnt].merge_id = n.merge_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dgnd_app = - (1)
   SET dgnd_pos = - (1.0)
   SET dgnd_prsnl = - (1.0)
   SET dgnd_view = "txtfnd"
   SET dgnd_comp = "txtfnd"
   SELECT INTO "NL:"
    FROM view_prefs a,
     name_value_prefs n,
     application ap,
     code_value c,
     prsnl p
    WHERE n.parent_entity_name="VIEW_PREFS"
     AND n.pvc_name=patstring(dgnd_name)
     AND a.view_prefs_id=n.parent_entity_id
     AND a.active_ind=1
     AND ap.application_number=a.application_number
     AND c.code_value=a.position_cd
     AND p.person_id=a.prsnl_id
    ORDER BY a.application_number, a.position_cd, a.prsnl_id
    DETAIL
     IF (((a.application_number != dgnd_app) OR (((a.position_cd != dgnd_pos) OR (((a.prsnl_id !=
     dgnd_prsnl) OR (((a.frame_type != dgnd_view) OR (a.view_name != dgnd_comp)) )) )) )) )
      dgnd_data->cnt = (dgnd_data->cnt+ 1), stat = alterlist(dgnd_data->qual,dgnd_data->cnt),
      dgnd_data->qual[dgnd_data->cnt].app_name = ap.description
      IF (a.position_cd > 0)
       dgnd_data->qual[dgnd_data->cnt].pos_value = c.display, dgnd_data->qual[dgnd_data->cnt].
       pos_act_ind = c.active_ind
      ENDIF
      IF (a.prsnl_id > 0)
       dgnd_data->qual[dgnd_data->cnt].user_name = p.name_full_formatted, dgnd_data->qual[dgnd_data->
       cnt].user_act_ind = p.active_ind
      ENDIF
      dgnd_data->qual[dgnd_data->cnt].other = a.frame_type, dgnd_data->qual[dgnd_data->cnt].other2 =
      a.view_name, dgnd_data->qual[dgnd_data->cnt].pe_name = n.parent_entity_name,
      dgnd_data->qual[dgnd_data->cnt].pvc_name = dgnd_name, dgnd_app = a.application_number, dgnd_pos
       = a.position_cd,
      dgnd_prsnl = a.prsnl_id, dgnd_view = a.frame_type, dgnd_comp = a.view_name
     ENDIF
     dgnd_data->qual[dgnd_data->cnt].det_cnt = (dgnd_data->qual[dgnd_data->cnt].det_cnt+ 1), dgnd_cnt
      = dgnd_data->qual[dgnd_data->cnt].det_cnt, stat = alterlist(dgnd_data->qual[dgnd_data->cnt].
      det_qual,dgnd_cnt),
     dgnd_data->qual[dgnd_data->cnt].det_qual[dgnd_cnt].pvc_value = n.pvc_value, dgnd_data->qual[
     dgnd_data->cnt].det_qual[dgnd_cnt].merge_name = n.merge_name, dgnd_data->qual[dgnd_data->cnt].
     det_qual[dgnd_cnt].merge_id = n.merge_id,
     dgnd_cv_idx = locateval(dgnd_cv_idx,1,dgnd_cv->cnt,n.merge_name,dgnd_cv->qual[dgnd_cv_idx].
      merge_name,
      n.merge_id,dgnd_cv->qual[dgnd_cv_idx].merge_id)
     IF (dgnd_cv_idx=0)
      dgnd_cv->cnt = (dgnd_cv->cnt+ 1), stat = alterlist(dgnd_cv->qual,dgnd_cv->cnt), dgnd_cv->qual[
      dgnd_cv->cnt].merge_name = n.merge_name,
      dgnd_cv->qual[dgnd_cv->cnt].merge_id = n.merge_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dgnd_app = - (1)
   SET dgnd_pos = - (1.0)
   SET dgnd_prsnl = - (1.0)
   SET dgnd_view = "txtfnd"
   SET dgnd_comp = "txtfnd"
   SELECT INTO "NL:"
    FROM view_comp_prefs a,
     name_value_prefs n,
     application ap,
     code_value c,
     prsnl p
    WHERE n.parent_entity_name="VIEW_COMP_PREFS"
     AND n.pvc_name=patstring(dgnd_name)
     AND a.view_comp_prefs_id=n.parent_entity_id
     AND a.active_ind=1
     AND ap.application_number=a.application_number
     AND c.code_value=a.position_cd
     AND p.person_id=a.prsnl_id
    ORDER BY a.application_number, a.position_cd, a.prsnl_id
    DETAIL
     IF (((a.application_number != dgnd_app) OR (((a.position_cd != dgnd_pos) OR (((a.prsnl_id !=
     dgnd_prsnl) OR (((a.view_name != dgnd_view) OR (a.comp_name != dgnd_comp)) )) )) )) )
      dgnd_data->cnt = (dgnd_data->cnt+ 1), stat = alterlist(dgnd_data->qual,dgnd_data->cnt),
      dgnd_data->qual[dgnd_data->cnt].app_name = ap.description
      IF (a.position_cd > 0)
       dgnd_data->qual[dgnd_data->cnt].pos_value = c.display, dgnd_data->qual[dgnd_data->cnt].
       pos_act_ind = c.active_ind
      ENDIF
      IF (a.prsnl_id > 0)
       dgnd_data->qual[dgnd_data->cnt].user_name = p.name_full_formatted, dgnd_data->qual[dgnd_data->
       cnt].user_act_ind = p.active_ind
      ENDIF
      dgnd_data->qual[dgnd_data->cnt].other = a.view_name, dgnd_data->qual[dgnd_data->cnt].other2 = a
      .comp_name, dgnd_data->qual[dgnd_data->cnt].pe_name = n.parent_entity_name,
      dgnd_data->qual[dgnd_data->cnt].pvc_name = dgnd_name, dgnd_app = a.application_number, dgnd_pos
       = a.position_cd,
      dgnd_prsnl = a.prsnl_id, dgnd_view = a.view_name, dgnd_comp = a.comp_name
     ENDIF
     dgnd_data->qual[dgnd_data->cnt].det_cnt = (dgnd_data->qual[dgnd_data->cnt].det_cnt+ 1), dgnd_cnt
      = dgnd_data->qual[dgnd_data->cnt].det_cnt, stat = alterlist(dgnd_data->qual[dgnd_data->cnt].
      det_qual,dgnd_cnt),
     dgnd_data->qual[dgnd_data->cnt].det_qual[dgnd_cnt].pvc_value = n.pvc_value, dgnd_data->qual[
     dgnd_data->cnt].det_qual[dgnd_cnt].merge_name = n.merge_name, dgnd_data->qual[dgnd_data->cnt].
     det_qual[dgnd_cnt].merge_id = n.merge_id,
     dgnd_cv_idx = locateval(dgnd_cv_idx,1,dgnd_cv->cnt,n.merge_name,dgnd_cv->qual[dgnd_cv_idx].
      merge_name,
      n.merge_id,dgnd_cv->qual[dgnd_cv_idx].merge_id)
     IF (dgnd_cv_idx=0)
      dgnd_cv->cnt = (dgnd_cv->cnt+ 1), stat = alterlist(dgnd_cv->qual,dgnd_cv->cnt), dgnd_cv->qual[
      dgnd_cv->cnt].merge_name = n.merge_name,
      dgnd_cv->qual[dgnd_cv->cnt].merge_id = n.merge_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (dgnd_cnt = 1 TO dgnd_cv->cnt)
     IF ((dgnd_cv->qual[dgnd_cnt].merge_name="CODE_VALUE")
      AND (dgnd_cv->qual[dgnd_cnt].merge_id > 0.0))
      SELECT INTO "NL:"
       FROM code_value c
       WHERE (c.code_value=dgnd_cv->qual[dgnd_cnt].merge_id)
       DETAIL
        dgnd_cv->qual[dgnd_cnt].merge_value = c.display
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(null)
      ENDIF
     ENDIF
   ENDFOR
   FOR (dgnd_loop = 1 TO dgnd_data->cnt)
    FOR (dgnd_cnt = 1 TO dgnd_data->qual[dgnd_loop].det_cnt)
      SET dgnd_cv_idx = locateval(dgnd_cv_idx,1,dgnd_cv->cnt,dgnd_data->qual[dgnd_loop].det_qual[
       dgnd_cnt].merge_name,dgnd_cv->qual[dgnd_cv_idx].merge_name,
       dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].merge_id,dgnd_cv->qual[dgnd_cv_idx].merge_id)
      IF (dgnd_cv_idx > 0)
       SET dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].merge_value = dgnd_cv->qual[dgnd_cv_idx].
       merge_value
      ELSE
       SET dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].merge_value = ""
      ENDIF
      IF ((((dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value > " ")) OR ((dgnd_data->qual[
      dgnd_loop].det_qual[dgnd_cnt].merge_value > " "))) )
       SET dgnd_data->qual[dgnd_loop].good_ind = 1
      ENDIF
    ENDFOR
    IF ((dgnd_data->qual[dgnd_loop].good_ind=1))
     SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_cnt = (dgnd_rs->cat_qual[
     dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_cnt+ 1)
     SET dgnd_value_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_cnt
     SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual,
      dgnd_value_cnt)
     FOR (dgnd_cnt = 1 TO dgnd_data->qual[dgnd_loop].det_cnt)
       SET dgnd_temp_str = ""
       IF ((dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].merge_value > " "))
        SET dgnd_temp = dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].merge_value
       ELSE
        IF (isnumeric(dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value) > 0)
         SELECT INTO "NL:"
          FROM code_value c
          WHERE c.code_value=cnvtreal(dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value)
          DETAIL
           dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value = c.display
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          SET dm_err->err_ind = 0
         ENDIF
        ELSE
         IF (findstring(",",dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value,1,0) > 0)
          IF (findstring(",,",dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value,1,0)=0)
           SELECT INTO "NL:"
            FROM code_value c
            WHERE parser(concat("c.code_value in (",dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].
              pvc_value,")"))
             AND code_set=400
            DETAIL
             IF (dgnd_temp_str <= " ")
              dgnd_temp_str = c.display
             ELSE
              dgnd_temp_str = concat(dgnd_temp_str,", ",c.display)
             ENDIF
            WITH nocounter
           ;end select
           IF (check_error(dm_err->eproc)=1)
            SET dm_err->err_ind = 0
            SET dgnd_temp_str = ""
           ENDIF
          ENDIF
         ENDIF
         IF (dgnd_temp_str > " ")
          SET dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value = dgnd_temp_str
         ENDIF
        ENDIF
        IF ((dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value != patstring("-1*"))
         AND (dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value != "0"))
         SET dgnd_temp = dgnd_data->qual[dgnd_loop].det_qual[dgnd_cnt].pvc_value
        ELSE
         SET dgnd_temp = ""
        ENDIF
       ENDIF
       IF (dgnd_temp > " ")
        IF ((dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
        value <= " "))
         SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
         value = dgnd_temp
        ELSE
         IF (findstring(concat(", ",dgnd_temp,", "),concat(", ",dgnd_rs->cat_qual[dgnd_cat_cnt].
           pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].value,", "),1,0)=0)
          SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
          value = concat(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
           dgnd_value_cnt].value,", ",dgnd_temp)
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF ((dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].value
      < " "))
      SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_cnt = (dgnd_rs->cat_qual[
      dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_cnt - 1)
      SET dgnd_value_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_cnt
      SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual,
       dgnd_value_cnt)
     ELSE
      IF ((dgnd_data->qual[dgnd_loop].pos_value > " "))
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_cnt = (dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt]
       .att_cnt+ 1)
       SET dgnd_att_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
       dgnd_value_cnt].att_cnt
       SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
        dgnd_value_cnt].att_qual,dgnd_att_cnt)
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_name = "Position"
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_value = dgnd_data->qual[dgnd_loop].pos_value
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       owner_type = "Position"
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       owner_name = dgnd_data->qual[dgnd_loop].pos_value
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       owner_activeness = dgnd_data->qual[dgnd_loop].pos_act_ind
      ENDIF
      IF ((dgnd_data->qual[dgnd_loop].user_name > " "))
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_cnt = (dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt]
       .att_cnt+ 1)
       SET dgnd_att_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
       dgnd_value_cnt].att_cnt
       SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
        dgnd_value_cnt].att_qual,dgnd_att_cnt)
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_name = "User Name"
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_value = dgnd_data->qual[dgnd_loop].user_name
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       owner_type = "User"
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       owner_name = dgnd_data->qual[dgnd_loop].user_name
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       owner_activeness = dgnd_data->qual[dgnd_loop].user_act_ind
      ENDIF
      IF ((dgnd_data->qual[dgnd_loop].app_name > " "))
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_cnt = (dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt]
       .att_cnt+ 1)
       SET dgnd_att_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
       dgnd_value_cnt].att_cnt
       SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
        dgnd_value_cnt].att_qual,dgnd_att_cnt)
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_name = "Application Name"
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_value = dgnd_data->qual[dgnd_loop].app_name
      ENDIF
      IF ((dgnd_data->qual[dgnd_loop].pe_name != "APP_PREFS")
       AND (dgnd_data->qual[dgnd_loop].other > " "))
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_cnt = (dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt]
       .att_cnt+ 1)
       SET dgnd_att_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
       dgnd_value_cnt].att_cnt
       SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
        dgnd_value_cnt].att_qual,dgnd_att_cnt)
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_value = dgnd_data->qual[dgnd_loop].other
       IF ((dgnd_data->qual[dgnd_loop].pe_name IN ("DETAIL_PREFS", "VIEW_COMP_PREFS")))
        SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
        att_qual[dgnd_att_cnt].att_name = "View Name"
       ELSE
        SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
        att_qual[dgnd_att_cnt].att_name = "Frame Type"
       ENDIF
      ENDIF
      IF ((dgnd_data->qual[dgnd_loop].pe_name != "APP_PREFS")
       AND (dgnd_data->qual[dgnd_loop].other2 > " "))
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_cnt = (dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt]
       .att_cnt+ 1)
       SET dgnd_att_cnt = dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
       dgnd_value_cnt].att_cnt
       SET stat = alterlist(dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[
        dgnd_value_cnt].att_qual,dgnd_att_cnt)
       SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
       att_qual[dgnd_att_cnt].att_value = dgnd_data->qual[dgnd_loop].other2
       IF ((dgnd_data->qual[dgnd_loop].pe_name IN ("DETAIL_PREFS", "VIEW_COMP_PREFS")))
        SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
        att_qual[dgnd_att_cnt].att_name = "Comp Name"
       ELSE
        SET dgnd_rs->cat_qual[dgnd_cat_cnt].pref_qual[dgnd_pref_cnt].value_qual[dgnd_value_cnt].
        att_qual[dgnd_att_cnt].att_name = "View Name"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF ((dm_err->err_ind=1))
  SET dtgp_reply->status_data.status = "F"
  CALL echo(
   "***************************************************************************************************"
   )
  CALL echo(
   "An error occurred and no CSV file has been created.  Please scroll up to find information on error."
   )
  CALL echo(
   "***************************************************************************************************"
   )
 ELSE
  SET dtgp_reply->status_data.status = "S"
  CALL echo(
   "**************************************************************************************************"
   )
  CALL echo(
   "The dm_txtfnd_pref_data.csv file has been created in CCLUSERDIR with all of the preference values."
   )
  CALL echo(
   "**************************************************************************************************"
   )
 ENDIF
END GO
