CREATE PROGRAM dm_rmc_test_comp:dba
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
   IF (textlen(concat(sbr_fprefix,sbr_fext)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    SET dm_err->eproc = concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
     sbr_fext)
    SET dm_err->user_action =
    "Please enter a file prefix and extension that does not exceed a length of 24."
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=1)
    WHILE (fini=0)
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
      SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
      IF (findfile(fname)=0)
       SET fini = 1
      ENDIF
    ENDWHILE
    IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
      sbr_fext))=1)
     SET guf_return_val = 0
    ENDIF
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
    AND textlen(sbr_dlogfile) <= 30
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
    AND trim(sbr_logfile) != ""
    AND textlen(sbr_logfile) <= 30)
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
    FREE DEFINE rtl2
    DEFINE rtl2 value(ddf_fname)
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
 IF ((validate(drc_tab_info->cnt,- (1))=- (1))
  AND (validate(drc_tab_info->cnt,- (2))=- (2)))
  FREE RECORD drc_tab_info
  RECORD drc_tab_info(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 r_table_name = vc
      2 batch_flag = i4
      2 batch_column = vc
      2 r_min_f8 = f8
      2 r_max_f8 = f8
      2 suffix = vc
      2 r_exist_ind = i2
      2 merge_delete_ind = i2
      2 current_state_ind = i2
      2 current_state_par_col = vc
      2 current_state_grp_col = vc
      2 current_state_parent = vc
      2 versioning_ind = i2
      2 versioning_alg = vc
      2 insert_only_ind = i2
      2 active_ind_ind = i2
      2 effective_col_ind = i2
      2 beg_col_name = vc
      2 end_col_name = vc
      2 active_name = vc
      2 root_column = vc
      2 meaningful_cnt = i4
      2 long_ind = i2
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
        3 root_entity_name = vc
        3 root_entity_attr = vc
        3 parent_entity_col = vc
        3 exception_flg = i4
        3 constant_value = vc
        3 ins_dml_override = vc
        3 upd_dml_override = vc
        3 unique_ident_ind = i2
        3 merge_delete_ind = i2
        3 defining_att_ind = i2
        3 meaningful_ind = i2
        3 meaningful_pos = i4
        3 notnull_ind = i2
        3 idcd_ind = i2
        3 pk_ind = i2
        3 ccl_data_type = vc
        3 db_data_type = vc
        3 long_ind = i2
        3 check_null = i2
        3 trailing_space_cnt = i4
  )
 ENDIF
 IF ((validate(drlc_meaningful->cnt,- (1))=- (1))
  AND (validate(drlc_meaningful->cnt,- (2))=- (2)))
  FREE RECORD drlc_meaningful
  RECORD drlc_meaningful(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
  )
 ENDIF
 IF ((validate(drlc_defining->cnt,- (1))=- (1))
  AND (validate(drlc_defining->cnt,- (2))=- (2)))
  FREE RECORD drlc_defining
  RECORD drlc_defining(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
    1 noncnt = i4
    1 nonqual[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
    1 patcnt = i4
    1 patqual[*]
      2 str = vc
  )
 ENDIF
 DECLARE drc_get_meta_data(dgmd_rec=vc(ref),dgmd_table=vc) = i4
 DECLARE drcc_find_rows(dfr_info=vc(ref),dfr_tab_name=vc,dfr_context=vc,dfr_delete_ind=i2,dfr_batch=
  vc) = i2
 DECLARE drcc_create_report(dcr_file=vc,dcr_reply=vc(ref),dcr_new_ind=i2) = i2
 DECLARE drcc_get_meaningful(dgm_mstr=vc(ref),dgm_info=vc(ref),dgm_row_pos=i4,dgm_col_pos=i4,dgm_pos=
  i4) = i2
 DECLARE drcc_query_parent(dqp_map=vc(ref),dqp_info=vc(ref),dqp_table_name=vc,dqp_value=f8,dqp_r_ind=
  i2) = i2
 DECLARE drcc_get_batch(dgb_mstr=vc(ref),dbg_info=vc(ref),dgb_table=vc) = i2
 DECLARE drcc_load_report(dlr_mstr=vc(ref),dlr_info=vc(ref),dlr_temp=vc(ref),dlr_cur_pos=vc,
  dlr_env_name=vc,
  dlr_del_ind=i2) = i2
 DECLARE drcc_get_log_type(dglt_mstr=vc(ref),dglt_target_id=f8) = i2
 DECLARE drcc_get_inserts(dgi_info=vc(ref),dgi_cur_pos=i4,dgi_context=vc) = i4
 DECLARE drcc_log_error_info(dlei_table_name=vc,dlei_proc=vc,dlei_error=vc,dlei_name=vc) = i2
 DECLARE drcc_get_cut_cnt(dgcc_info=vc(ref),dgcc_cur_pos=i4) = i4
 SUBROUTINE drc_get_meta_data(dgmd_rec,dgmd_table)
   DECLARE dgmd_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgmd_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dgmd_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgmd_tbl_idx = i4 WITH protect, noconstant(0)
   DECLARE dgmd_done_ind = i4 WITH protect, noconstant(0)
   DECLARE dgmd_retry_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgmd_max_mean = i4 WITH protect, noconstant(0)
   DECLARE dgmd_def_loop = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Gathering table level meta-data"
   SELECT INTO "NL:"
    FROM dm_tables_doc_local drt
    WHERE drt.table_name=dgmd_table
    DETAIL
     dgmd_rec->cnt = (dgmd_rec->cnt+ 1), stat = alterlist(dgmd_rec->qual,dgmd_rec->cnt), dgmd_rec->
     qual[dgmd_rec->cnt].r_table_name = cutover_tab_name(drt.table_name,drt.table_suffix),
     dgmd_rec->qual[dgmd_rec->cnt].table_name = drt.table_name, dgmd_rec->qual[dgmd_rec->cnt].
     merge_delete_ind = drt.merge_delete_ind, dgmd_rec->qual[dgmd_rec->cnt].suffix = drt.table_suffix
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No table qualified for table ",dgmd_table," in table level meta-data")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Gathering column level meta data"
   SELECT INTO "NL:"
    FROM dm_columns_doc_local drt,
     user_tab_cols utc
    PLAN (drt
     WHERE drt.table_name=dgmd_table)
     JOIN (utc
     WHERE utc.table_name=dgmd_table
      AND utc.column_name=drt.column_name
      AND utc.virtual_column="NO"
      AND utc.hidden_column="NO"
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND di.info_name=utc.column_name
       AND sqlpassthru(" utc.table_name like di.info_char")))))
    DETAIL
     dgmd_col_cnt = (dgmd_col_cnt+ 1)
     IF (mod(dgmd_col_cnt,10)=1)
      stat = alterlist(dgmd_rec->qual[dgmd_rec->cnt].col_qual,(dgmd_col_cnt+ 9))
     ENDIF
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].column_name = drt.column_name, dgmd_rec->
     qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].unique_ident_ind = drt.unique_ident_ind, dgmd_rec->
     qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].exception_flg = drt.exception_flg,
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].constant_value = drt.constant_value,
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].parent_entity_col = cnvtupper(drt
      .parent_entity_col), dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_name =
     cnvtupper(drt.root_entity_name),
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_attr = cnvtupper(drt
      .root_entity_attr), dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].merge_delete_ind = drt
     .merge_delete_ind, dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].defining_att_ind = 1
     IF (drt.column_name IN ("*_ID", "*_CD", "CODE_VALUE")
      AND utc.data_type IN ("NUMBER", "FLOAT"))
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].idcd_ind = 1
     ELSE
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].idcd_ind = 0
     ENDIF
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].db_data_type = utc.data_type, dgmd_rec->
     qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].check_null = 0
     IF (utc.data_type IN ("BLOB", "LONG RAW", "CLOB", "LONG"))
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].long_ind = 1, dgmd_rec->qual[dgmd_rec->cnt
      ].long_ind = 1
     ELSE
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].long_ind = 0
     ENDIF
     IF (drt.column_name="ACTIVE_IND")
      dgmd_rec->qual[dgmd_rec->cnt].active_ind_ind = 1, dgmd_rec->qual[dgmd_rec->cnt].active_name =
      drt.column_name
     ENDIF
     IF (drt.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
     "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
     "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM"))
      dgmd_rec->qual[dgmd_rec->cnt].beg_col_name = drt.column_name
     ENDIF
     IF (drt.column_name IN ("END_EFFECTIVE_DT_TM", "PRSNL_END_EFFECTIVE_DT_TM",
     "END_EFFECTIVE_UTC_DT_TM", "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM"))
      dgmd_rec->qual[dgmd_rec->cnt].end_col_name = drt.column_name
     ENDIF
     IF (drt.table_name="PERSON"
      AND drt.column_name="PERSON_ID")
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_name = "PERSON", dgmd_rec->
      qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].root_entity_attr = "PERSON_ID", dgmd_rec->qual[
      dgmd_rec->cnt].root_column = "PERSON_ID"
     ENDIF
     IF (drt.table_name=drt.root_entity_name
      AND drt.column_name=drt.root_entity_attr)
      dgmd_rec->qual[dgmd_rec->cnt].root_column = drt.column_name
     ENDIF
    FOOT REPORT
     stat = alterlist(dgmd_rec->qual[dgmd_rec->cnt].col_qual,dgmd_col_cnt), dgmd_rec->qual[dgmd_rec->
     cnt].col_cnt = dgmd_col_cnt
     IF ((dgmd_rec->qual[dgmd_rec->cnt].beg_col_name != "")
      AND (dgmd_rec->qual[dgmd_rec->cnt].end_col_name != ""))
      dgmd_rec->qual[dgmd_rec->cnt].effective_col_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No columns qualified from column level meta-data query for table ",
     dgmd_table)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM dm2_user_notnull_cols d
    WHERE d.table_name=dgmd_table
    DETAIL
     dgmd_col_idx = 0, dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,
      d.column_name,dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].column_name)
     IF (dgmd_col_idx > 0)
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].notnull_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    build(l.type,l.len), l.*, utc.data_type
    FROM dtableattr a,
     dtableattrl l,
     user_tab_columns utc
    PLAN (a
     WHERE a.table_name=dgmd_table)
     JOIN (l
     WHERE l.structtype="F"
      AND btest(l.stat,11)=0)
     JOIN (utc
     WHERE utc.table_name=a.table_name
      AND utc.column_name=l.attr_name)
    DETAIL
     dgmd_col_idx = 0, dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,
      l.attr_name,dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].column_name)
     IF (dgmd_col_idx > 0)
      IF (l.type="F")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "F8"
      ELSEIF (l.type="I")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "I4"
      ELSEIF (l.type="C")
       IF (utc.data_type="CHAR")
        dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = build(l.type,l.len)
       ELSE
        dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "VC"
       ENDIF
      ELSEIF (l.type="Q")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "DQ8"
      ELSEIF (l.type="M")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].ccl_data_type = "DM12"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=dgmd_table
     AND cv.code_set=4000220
     AND cv.active_ind=1
     AND cv.cdf_meaning="INSERT_ONLY"
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].insert_only_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.display=dgmd_table
     AND cv.code_set=255351
     AND cv.active_ind=1
     AND cv.cdf_meaning != "NONE"
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].versioning_ind = 1, dgmd_rec->qual[dgmd_rec->cnt].versioning_alg
      = cv.cdf_meaning
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(dgmd_rec->qual[dgmd_rec->cnt].col_cnt)),
     dm_info i
    PLAN (d
     WHERE (dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].idcd_ind=0))
     JOIN (i
     WHERE i.info_domain=concat("RDDS TRANS COLUMN:",dgmd_rec->qual[dgmd_rec->cnt].table_name)
      AND (i.info_name=dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].column_name))
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].idcd_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,dguc_reply->rs_tbl_cnt,dgmd_table,dguc_reply->
    dtd_hold[dgmd_tbl_idx].tbl_name)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
     (dummyt d2  WITH seq = dguc_reply->dtd_hold[dgmd_tbl_idx].pk_cnt)
    PLAN (d)
     JOIN (d2
     WHERE (dguc_reply->dtd_hold[dgmd_tbl_idx].pk_hold[d2.seq].pk_name=dgmd_rec->qual[dgmd_rec->cnt].
     col_qual[d.seq].column_name))
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].pk_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,drlc_meaningful->cnt,dgmd_table,drlc_meaningful->qual[
    dgmd_tbl_idx].table_name)
   IF (dgmd_tbl_idx > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
      (dummyt d2  WITH seq = drlc_meaningful->qual[dgmd_tbl_idx].col_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (drlc_meaningful->qual[dgmd_tbl_idx].col_qual[d2.seq].column_name=dgmd_rec->qual[dgmd_rec
      ->cnt].col_qual[d.seq].column_name)
       AND  NOT ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].db_data_type IN ("LONG*", "BLOB",
      "CLOB"))))
     DETAIL
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].meaningful_ind = 1, dgmd_rec->qual[dgmd_rec->cnt]
      .col_qual[d.seq].meaningful_pos = d2.seq, dgmd_rec->qual[dgmd_rec->cnt].meaningful_cnt = (
      dgmd_rec->qual[dgmd_rec->cnt].meaningful_cnt+ 1)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dgmd_max_mean = drlc_meaningful->qual[dgmd_tbl_idx].col_cnt
    FOR (dgmd_col_loop = 1 TO dgmd_rec->qual[dgmd_rec->cnt].col_cnt)
      IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col > " ")
       AND (dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].meaningful_ind=1))
       SET dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,dgmd_rec->
        qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col,dgmd_rec->qual[dgmd_rec->cnt].
        col_qual[dgmd_col_idx].column_name)
       SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].meaningful_ind = 2
       IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].meaningful_pos=0))
        SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].meaningful_pos = (dgmd_max_mean+ 1)
        SET dgmd_max_mean = (dgmd_max_mean+ 1)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   FOR (dgmd_def_loop = 1 TO drlc_defining->patcnt)
     FOR (dgmd_col_loop = 1 TO dgmd_rec->qual[dgmd_rec->cnt].col_cnt)
       IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].column_name=patstring(drlc_defining
        ->patqual[dgmd_def_loop].str)))
        SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].defining_att_ind = 0
       ENDIF
     ENDFOR
   ENDFOR
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,drlc_defining->noncnt,dgmd_table,drlc_defining->
    nonqual[dgmd_tbl_idx].table_name)
   IF (dgmd_tbl_idx > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
      (dummyt d2  WITH seq = drlc_defining->nonqual[dgmd_tbl_idx].col_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (drlc_defining->nonqual[dgmd_tbl_idx].col_qual[d2.seq].column_name=dgmd_rec->qual[
      dgmd_rec->cnt].col_qual[d.seq].column_name))
     DETAIL
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].defining_att_ind = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dgmd_tbl_idx = locateval(dgmd_tbl_idx,1,drlc_defining->cnt,dgmd_table,drlc_defining->qual[
    dgmd_tbl_idx].table_name)
   IF (dgmd_tbl_idx > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = dgmd_rec->qual[dgmd_rec->cnt].col_cnt),
      (dummyt d2  WITH seq = drlc_defining->qual[dgmd_tbl_idx].col_cnt)
     PLAN (d)
      JOIN (d2
      WHERE (drlc_defining->qual[dgmd_tbl_idx].col_qual[d2.seq].column_name=dgmd_rec->qual[dgmd_rec->
      cnt].col_qual[d.seq].column_name)
       AND  NOT ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].db_data_type IN ("LONG*", "BLOB",
      "CLOB"))))
     DETAIL
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[d.seq].defining_att_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   FOR (dgmd_col_loop = 1 TO dgmd_rec->qual[dgmd_rec->cnt].col_cnt)
     IF ((dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col > " ")
      AND (dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].defining_att_ind=1))
      SET dgmd_col_idx = locateval(dgmd_col_idx,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,dgmd_rec->
       qual[dgmd_rec->cnt].col_qual[dgmd_col_loop].parent_entity_col,dgmd_rec->qual[dgmd_rec->cnt].
       col_qual[dgmd_col_idx].column_name)
      SET dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_idx].defining_att_ind = 2
     ENDIF
   ENDFOR
   SELECT INTO "NL:"
    FROM dm_refchg_dml d
    WHERE d.table_name=dgmd_table
     AND dml_attribute IN ("INS_VAL_STR", "UPD_VAL_STR")
    DETAIL
     dgmd_col_idx = locateval(dgmd_col_cnt,1,dgmd_rec->qual[dgmd_rec->cnt].col_cnt,d.column_name,
      dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].column_name)
     IF (dgmd_col_idx > 0)
      IF (d.dml_attribute="INS_VAL_STR")
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].ins_dml_override = d.dml_value
      ELSE
       dgmd_rec->qual[dgmd_rec->cnt].col_qual[dgmd_col_cnt].upd_dml_override = d.dml_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS AUDIT BATCH TABLE"
     AND d.info_name=dgmd_table
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].batch_flag = d.info_number, dgmd_rec->qual[dgmd_rec->cnt].
     batch_column = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgmd_table="DCP_FORMS_DEF")
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_ind = 1
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_par_col = "DCP_FORM_INSTANCE_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_grp_col = "DCP_FORMS_REF_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_parent = "DCP_FORMS_REF"
   ELSEIF (dgmd_table="DCP_INPUT_REF")
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_ind = 1
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_par_col = "DCP_SECTION_INSTANCE_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_grp_col = "DCP_SECTION_REF_ID"
    SET dgmd_rec->qual[dgmd_rec->cnt].current_state_parent = "DCP_SECTION_REF"
   ENDIF
   SELECT INTO "NL:"
    FROM user_tables u
    WHERE (u.table_name=dgmd_rec->qual[dgmd_rec->cnt].r_table_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    RETURN(- (2))
   ENDIF
   SELECT INTO "NL:"
    FROM dtable d
    WHERE (d.table_name=dgmd_rec->qual[dgmd_rec->cnt].r_table_name)
    DETAIL
     dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind=0))
    WHILE (dgmd_done_ind=0)
      SET drl_reply->status = ""
      SET drl_reply->status_msg = ""
      CALL get_lock("RDDS $R CREATION",dgmd_rec->qual[dgmd_rec->cnt].r_table_name,0,drl_reply)
      IF ((drl_reply->status="F"))
       CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       SET dgmd_done_ind = 1
      ELSEIF ((drl_reply->status="S"))
       EXECUTE oragen3 dgmd_rec->qual[dgmd_rec->cnt].r_table_name
       SET dgmd_done_ind = 1
       SET drl_reply->status = ""
       SET drl_reply->status_msg = ""
       CALL remove_lock("RDDS $R CREATION",dgmd_rec->qual[dgmd_rec->cnt].r_table_name,currdbhandle,
        drl_reply)
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg("",dm_err->logfile,1)
        SET dgmd_done_ind = 1
       ENDIF
      ELSE
       CALL pause(10)
       SELECT INTO "NL:"
        FROM dtable d
        WHERE (d.table_name=dgmd_rec->qual[dgmd_rec->cnt].r_table_name)
        DETAIL
         dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind = 1
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dgmd_done_ind = 1
       ENDIF
       IF ((dgmd_rec->qual[dgmd_rec->cnt].r_exist_ind=1))
        SET dgmd_done_ind = 1
       ELSE
        IF (dgmd_retry_cnt=3)
         CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
         SET dm_err->emsg = drl_reply->status_msg
         SET dm_err->err_ind = 1
         SET dgmd_done_ind = 1
        ENDIF
        SET dgmd_retry_cnt = (dgmd_retry_cnt+ 1)
       ENDIF
      ENDIF
    ENDWHILE
    RETURN(- (1))
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(dgmd_rec->cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE drcc_find_rows(dfr_info,dfr_tab_name,dfr_context,dfr_delete_ind,dfr_batch_str)
   DECLARE dfr_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dfr_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dfr_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dfr_par_tab = i4 WITH protect, noconstant(0)
   DECLARE dfr_par_loop = i4 WITH protect, noconstant(0)
   DECLARE dfr_par_r_table = vc WITH protect, noconstant("")
   DECLARE dfr_pk_where = vc WITH protect, noconstant("")
   DECLARE dfr_col_list = vc WITH protect, noconstant("")
   DECLARE dfr_pe_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dfr_stmt_cnt = i4
   DECLARE dfr_dtype_def = vc
   FREE RECORD dfr_stmt
   RECORD dfr_stmt(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD dfr_temp
   RECORD dfr_temp(
     1 cnt = i4
     1 stmt[*]
       2 str = vc
   )
   SET dfr_tab_pos = locateval(dfr_tab_loop,1,dfr_info->cnt,dfr_tab_name,dfr_info->qual[dfr_tab_loop]
    .table_name)
   SET dfr_pk_where = concat(" (r.RDDS_DELETE_IND = ",trim(cnvtstring(dfr_delete_ind)),
    " and r.rdds_status_flag < 9000")
   IF (dfr_context != char(42))
    SET dfr_pk_where = concat(dfr_pk_where," and (r.rdds_context_name = '",dfr_context,
     "' or r.rdds_context_name like '",dfr_context,
     "::%' or r.rdds_context_name like '%::",dfr_context,"' or r.rdds_context_name like '%::",
     dfr_context,"::%')")
   ENDIF
   SET dm_err->eproc = "Evaluate generic non-delete rows"
   SET stat = alterlist(dfr_stmt->stmt,4000)
   SET dfr_stmt->stmt[1].str =
   "rdb asis(^ insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value,^) "
   IF (dfr_delete_ind=0)
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
   ELSE
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value,r_rowid,r_ptam_hash_value,status)(select distinct vals_r.tname as tabname,^)"
   ENDIF
   SET dfr_stmt->stmt[3].str =
   "asis(^vals_r.cname as colname, vals_r.value as r_value, vals_l.value as l_value,^)"
   SET dfr_stmt->stmt[4].str =
   "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
   SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
    dfr_info->qual[dfr_tab_pos].table_name," l, ^)")
   SET dfr_stmt->stmt[6].str = concat("asis(^")
   IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
    AND dfr_delete_ind=0)
    SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str,dfr_info->qual[dfr_tab_pos].
     current_state_parent," s, ")
   ENDIF
   SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str," table ( column_diff_varray (^)")
   SET dfr_stmt_cnt = 7
   SET stat = alterlist(dfr_temp->stmt,1000)
   SET dfr_temp->cnt = 1
   IF (dfr_delete_ind=1
    AND (dfr_info->qual[dfr_tab_pos].merge_delete_ind=0))
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF (dfr_delete_ind=1
    AND (dfr_info->qual[dfr_tab_pos].merge_delete_ind=1))
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF ((((dfr_info->qual[dfr_tab_pos].merge_delete_ind=0)
    AND (dfr_info->qual[dfr_tab_pos].versioning_ind=0)
    AND (dfr_info->qual[dfr_tab_pos].current_state_ind=0)) OR ((dfr_info->qual[dfr_tab_pos].
   versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG2"))) )
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].defining_att_ind=1)) OR ((((dfr_info
      ->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)) OR ((dfr_info->qual[dfr_tab_pos].
      col_qual[dfr_col_loop].pk_ind=1))) ))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ELSE
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].defining_att_ind=1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].root_column)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].current_state_par_col)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   ENDFOR
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R, table ( column_diff_varray ( ^)"
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,
      "r.rdds_ptam_match_result","-1",0)
     SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,"r.","l.",0)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   ENDFOR
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_L where ^)"
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
    AND dfr_delete_ind=0)
    SET dfr_par_tab = locateval(dfr_par_loop,1,dfr_info->cnt,dfr_info->qual[dfr_tab_pos].
     current_state_parent,dfr_info->qual[dfr_par_loop].table_name)
    IF (dfr_par_tab=0)
     SET dfr_par_tab = drc_get_meta_data(dfr_info,dfr_info->qual[dfr_tab_pos].current_state_parent)
     IF (dfr_par_tab=0)
      RETURN(1)
     ELSEIF ((dfr_par_tab=- (1)))
      RETURN(- (1))
     ELSEIF ((dfr_par_tab=- (2)))
      SET dfr_par_tab = dfr_info->cnt
      SET dfr_par_r_table = dfr_info->qual[dfr_par_tab].table_name
     ELSE
      SET dfr_par_r_table = dfr_info->qual[dfr_par_tab].r_table_name
     ENDIF
    ELSE
     SET dfr_par_r_table = dfr_info->qual[dfr_par_tab].r_table_name
    ENDIF
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r.",dfr_info->qual[dfr_tab_pos].
     current_state_par_col," in (select r1.",dfr_info->qual[dfr_par_tab].root_column," from ",
     dfr_par_r_table," r1 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
     AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
     IF (findstring("$R",dfr_par_r_table,0,0) > 0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r1.",0),
       ") and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and r1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",r1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","r1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"r1.","r2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," r2 where ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r2.",0),
        ") and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r2.",dfr_info->qual[dfr_par_tab].
       active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and s.",dfr_info->qual[dfr_tab_pos].
      current_state_grp_col," = r.",dfr_info->qual[dfr_tab_pos].current_state_grp_col,"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
      AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (s.",dfr_info->qual[dfr_par_tab].
       active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (s.",dfr_info->qual[dfr_par_tab].
        active_name," = 0 and s.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ s.",dfr_info->qual[dfr_par_tab].
        end_col_name," >= sysdate and not (^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_col_list = ""
       FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
           SET dfr_dtype_def = "'AbyZ12%$90'"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
           SET dfr_dtype_def = "-123"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
           SET dfr_dtype_def = "-123.456"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"
          )))
           SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
          ENDIF
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
           IF (dfr_col_list="")
            SET dfr_col_list = concat("s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name)
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name)
           ENDIF
          ELSE
           IF (dfr_col_list="")
            SET dfr_col_list = concat("nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name,",",dfr_dtype_def,
             ")")
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name,",",
             dfr_dtype_def,")")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
         dfr_col_list,"s.","l2.",0),"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_par_tab].
        table_name," l2 where l2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," = s.",dfr_info->qual[dfr_tab_pos].current_state_par_col,"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
        AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
       dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
       column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and (1 = 1 ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("The current state table of ",dfr_info->qual[dfr_tab_pos].table_name,
      " with parent table of ",dfr_info->qual[dfr_tab_pos].current_state_parent,
      " is currently not supported")
     RETURN(1)
    ENDIF
   ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=0)
    AND ((dfr_delete_ind=0
    AND  NOT ((dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))) OR (
   dfr_delete_ind=1)) )
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF (dfr_delete_ind=0
    AND (dfr_info->qual[dfr_tab_pos].versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
     active_name," = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
      active_name," = 0 and r.",dfr_info->qual[dfr_tab_pos].beg_col_name," <= sysdate and ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r.",dfr_info->qual[dfr_tab_pos].
      end_col_name," >= sysdate and not (^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_col_list = ""
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
         SET dfr_dtype_def = "'AbyZ12%$90'"
        ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
         SET dfr_dtype_def = "-123"
        ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type="F8"))
         SET dfr_dtype_def = "-123.456"
        ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"))
        )
         SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
        ENDIF
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=1))
         IF (dfr_col_list="")
          SET dfr_col_list = concat("r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
           column_name)
         ELSE
          SET dfr_col_list = concat(dfr_col_list,",r.",dfr_info->qual[dfr_tab_pos].col_qual[
           dfr_col_loop].column_name)
         ENDIF
        ELSE
         IF (dfr_col_list="")
          SET dfr_col_list = concat("nvl(","r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
           column_name,",",dfr_dtype_def,
           ")")
         ELSE
          SET dfr_col_list = concat(dfr_col_list,",nvl(","r.",dfr_info->qual[dfr_tab_pos].col_qual[
           dfr_col_loop].column_name,",",
           dfr_dtype_def,")")
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
       dfr_col_list,"r.","r1.",0),"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
      r_table_name," r1 where r1.",dfr_info->qual[dfr_tab_pos].active_name," = 1))^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (l.",dfr_info->qual[dfr_tab_pos].
     active_name," = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l.",dfr_info->qual[dfr_tab_pos].
      active_name," = 0 and l.",dfr_info->qual[dfr_tab_pos].beg_col_name," <= sysdate and ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ l.",dfr_info->qual[dfr_tab_pos].
      end_col_name," >= sysdate and not (^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_col_list,"r.","l.",0),
      ") in (select ",replace(dfr_col_list,"r.","l1.",0),"^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
      table_name," l1 where l1.",dfr_info->qual[dfr_tab_pos].active_name," = 1))^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
   ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
    AND dfr_delete_ind=0)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = " asis(^)^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
   ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
    AND dfr_delete_ind=1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = " asis(^)^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Table type not able to be identified: ",dfr_info->qual[dfr_tab_pos].
     table_name)
    RETURN(1)
   ENDIF
   SET dfr_stmt->stmt[dfr_stmt_cnt].str =
   "asis(^) and (vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
   SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   IF (dfr_delete_ind=0)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and (vals_r.value != vals_l.value ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat(
     "asis(^ or ((vals_r.value is null and vals_l.value is not null) or ",
     " (vals_r.value is not null and vals_l.value is null)))^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
   ENDIF
   SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ))^) go"
   SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
   IF (drlc_debug_flag > 0)
    SELECT INTO "dm_rmc_r_live_debug.txt"
     FROM (dummyt d  WITH seq = dfr_stmt_cnt)
     DETAIL
      dfr_stmt->stmt[d.seq].str, row + 1
     WITH nocounter, maxrow = 1, maxcol = 4000,
      format = variable, formfeed = none, append
    ;end select
   ENDIF
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF ((((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
    AND dfr_delete_ind=0) OR ((((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
    AND dfr_delete_ind=0) OR ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
    AND dfr_delete_ind=0)) )) )
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_r.cname as colname, vals_r.value as r_value, 'RDDS NO VAL',^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
     " table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 6
    SET dfr_temp->cnt = 1
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind >= 1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select r1.",dfr_info->qual[dfr_par_tab].root_column," from ",
      dfr_par_r_table," r1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
      AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r1.",0),
        ") and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r1.",dfr_info->qual[dfr_par_tab].
       active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_par_tab].
        active_name," = 0 and r1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r1.",dfr_info->qual[dfr_par_tab].
        end_col_name," >= sysdate and not (^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_col_list = ""
       FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
           SET dfr_dtype_def = "'AbyZ12%$90'"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
           SET dfr_dtype_def = "-123"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
           SET dfr_dtype_def = "-123.456"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"
          )))
           SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
          ENDIF
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
           IF (dfr_col_list="")
            SET dfr_col_list = concat("r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name)
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",r1.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name)
           ENDIF
          ELSE
           IF (dfr_col_list="")
            SET dfr_col_list = concat("nvl(","r1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop]
             .column_name,",",dfr_dtype_def,
             ")")
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",nvl(","r1.",dfr_info->qual[dfr_par_tab].
             col_qual[dfr_col_loop].column_name,",",
             dfr_dtype_def,")")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
         dfr_col_list,"r1.","r2.",0),"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," r2 where ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF (findstring("$R",dfr_par_r_table,0,0) > 0)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_pk_where,"r.","r2.",0),
         ") and ^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ r2.",dfr_info->qual[dfr_par_tab].
        active_name," = 1))^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) ^)"
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("The current state table of ",dfr_info->qual[dfr_tab_pos].table_name,
       " with parent table of ",dfr_info->qual[dfr_tab_pos].current_state_parent,
       " is currently not supported")
      RETURN(1)
     ENDIF
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and exists (select 'x' from ",dfr_info->
     qual[dfr_tab_pos].table_name," l1 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_and_ind = 0
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name=dfr_info->qual[dfr_tab_pos
      ].current_state_grp_col))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].exception_flg=12))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l1.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_info->qual[dfr_tab_pos].current_state_parent," d1 ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ where (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
       current_state_parent," d2 where d2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ) and not exists (select 'x' from ",
     dfr_info->qual[dfr_tab_pos].table_name," l2 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_and_ind = 0
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_batch_str,"<suffix>","l2",0),
      " ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_and_ind = 1
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
      column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l2.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_info->qual[dfr_tab_pos].current_state_parent," d1 ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ where (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
       current_state_parent," d2 where d2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ELSE
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^) go "
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_l.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_l.cname as colname, 'RDDS NO VAL', vals_l.value as l_value,^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_l.r_rowid as r_rowid, vals_l.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].table_name," l, ^)")
    SET dfr_stmt->stmt[6].str = "asis(^"
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str,dfr_info->qual[dfr_tab_pos].
      current_state_parent," s, ")
    ENDIF
    SET dfr_stmt->stmt[6].str = concat(dfr_stmt->stmt[6].str," table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 7
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,
       "r.rdds_ptam_match_result","-1",0)
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,"r.","l.",0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_L where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     IF ((dfr_info->qual[dfr_par_tab].versioning_ind=1)
      AND (dfr_info->qual[dfr_par_tab].versioning_alg IN ("ALG1", "ALG3")))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (s.",dfr_info->qual[dfr_par_tab].
       active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (s.",dfr_info->qual[dfr_par_tab].
        active_name," = 0 and s.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ s.",dfr_info->qual[dfr_par_tab].
        end_col_name," >= sysdate and not (^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_col_list = ""
       FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
           SET dfr_dtype_def = "'AbyZ12%$90'"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
           SET dfr_dtype_def = "-123"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
           SET dfr_dtype_def = "-123.456"
          ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12"
          )))
           SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
          ENDIF
          IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
           IF (dfr_col_list="")
            SET dfr_col_list = concat("s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name)
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name)
           ENDIF
          ELSE
           IF (dfr_col_list="")
            SET dfr_col_list = concat("nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
             column_name,",",dfr_dtype_def,
             ")")
           ELSE
            SET dfr_col_list = concat(dfr_col_list,",nvl(","s.",dfr_info->qual[dfr_par_tab].col_qual[
             dfr_col_loop].column_name,",",
             dfr_dtype_def,")")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
         dfr_col_list,"s.","l2.",0),"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
        current_state_parent," l2 where l2.",dfr_info->qual[dfr_par_tab].active_name," = 1))^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
       current_state_par_col," = s.",dfr_info->qual[dfr_tab_pos].current_state_par_col," and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("The current state table of ",dfr_info->qual[dfr_tab_pos].table_name,
       " with parent table of ",dfr_info->qual[dfr_tab_pos].current_state_parent,
       " is currently not supported")
      RETURN(1)
     ENDIF
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ exists (select 'x' from ",dfr_info->qual[
     dfr_tab_pos].r_table_name," r1 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_pk_where = replace(dfr_pk_where,"r.","r1.",0)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
       "r1",0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name=dfr_info->qual[dfr_tab_pos
      ].current_state_grp_col))
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r1.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].merge_delete_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].exception_flg=12))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r1.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_par_r_table," d1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF (findstring("$R",dfr_par_r_table,0,0) > 0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d1.",0),
       ")^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^  and (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," d2 where ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d2.",0),
        ")^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and d2.",dfr_info->qual[dfr_par_tab].
       active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ) and not exists (select 'x' from ",
     dfr_info->qual[dfr_tab_pos].r_table_name," r2 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_pk_where = replace(dfr_pk_where,"r1.","r2.",0)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
       "r2",0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1)
       AND (((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
      dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
      column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
       IF (dfr_and_ind=1)
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_and_ind = 1
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
       AND (dfr_info->qual[dfr_tab_pos].versioning_alg="ALG5")
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r2.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select d1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_par_r_table," d1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF (findstring("$R",dfr_par_r_table,0,0) > 0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d1.",0),
       ")^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (d1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (d1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and d1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ d1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_col_list = ""
      FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_par_tab].col_cnt)
        IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].unique_ident_ind=1))
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dfr_dtype_def = "'AbyZ12%$90'"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dfr_dtype_def = "-123"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type="F8"))
          SET dfr_dtype_def = "-123.456"
         ELSEIF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dfr_dtype_def = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
         ENDIF
         IF ((dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].notnull_ind=1))
          IF (dfr_col_list="")
           SET dfr_col_list = concat("d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name)
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name)
          ENDIF
         ELSE
          IF (dfr_col_list="")
           SET dfr_col_list = concat("nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[dfr_col_loop].
            column_name,",",dfr_dtype_def,
            ")")
          ELSE
           SET dfr_col_list = concat(dfr_col_list,",nvl(","d1.",dfr_info->qual[dfr_par_tab].col_qual[
            dfr_col_loop].column_name,",",
            dfr_dtype_def,")")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_col_list,") in (select ",replace(
        dfr_col_list,"d1.","d2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_par_r_table," d2 where ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF (findstring("$R",dfr_par_r_table,0,0) > 0)
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r1.","d2.",0),
        ")^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and d2.",dfr_info->qual[dfr_par_tab].
       active_name," = 1))^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^)^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^) go "
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET dfr_pk_where = replace(dfr_pk_where,"r2.","r.",0)
   ENDIF
   IF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
    AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4"))
    AND dfr_delete_ind=0)
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_r.cname as colname, vals_r.value as r_value, 'RDDS NO VAL',^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
     dfr_info->qual[dfr_tab_pos].table_name," l,",
     " table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 6
    SET dfr_temp->cnt = 1
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind >= 1)) OR ((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
     AND dfr_batch_str > " ")
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>","r",
       0)," ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
     active_name," = 0^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and r.",dfr_info->qual[dfr_tab_pos].
      end_col_name," <= sysdate ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and not exists (select 'x' from ",dfr_info
     ->qual[dfr_tab_pos].r_table_name," r1 where (^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^r1.",dfr_info->qual[dfr_tab_pos].active_name,
     " = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or r1.",dfr_info->qual[dfr_tab_pos].
      end_col_name," >= sysdate ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDIF
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ) and ",replace(dfr_pk_where,"r.","r1.",0),
     ")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r1.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r1.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat(
     "asis(^) and r.updt_dt_tm in (select max(r2.updt_Dt_Tm) from ",dfr_info->qual[dfr_tab_pos].
     r_table_name," r2 where ^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_pk_where,"r.","r2.",0),")^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r2.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = r.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r2.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and r.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^))^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
     active_name," = 1^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
        col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop]
        .column_name,"^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
         dfr_col_loop].column_name," is null)^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) ^) go"
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF (dfr_delete_ind=0)
    SET stat = alterlist(dfr_stmt->stmt,4000)
    SET dfr_stmt->stmt[1].str =
    "rdb asis(^insert into dm_refchg_comp_gttd (table_name, column_name, r_column_value, ^)"
    SET dfr_stmt->stmt[2].str =
    "asis(^l_column_value, r_rowid, r_ptam_hash_value, status)(select vals_r.tname as tabname,^)"
    SET dfr_stmt->stmt[3].str =
    "asis(^vals_r.cname as colname, vals_r.value as r_value, vals_l.value as l_value,^)"
    SET dfr_stmt->stmt[4].str =
    "asis(^vals_r.r_rowid as r_rowid, vals_r.r_ptam_hash as ptam_hash, null from ^)"
    SET dfr_stmt->stmt[5].str = concat("asis(^",dfr_info->qual[dfr_tab_pos].r_table_name," r, ",
     dfr_info->qual[dfr_tab_pos].table_name," l, table ( column_diff_varray (^)")
    SET dfr_stmt_cnt = 6
    SET dfr_temp->cnt = 1
    FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
      IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1)) OR ((((dfr_info->
      qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[
      dfr_col_loop].unique_ident_ind=1))) ))
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].long_ind=0)
       AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].upd_dml_override != "T1.*"))
       IF ((dfr_temp->cnt > 1))
        SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^ , ^)"
        SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       ENDIF
       SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^COLUMN_DIFF_DATA('",dfr_info->qual[
        dfr_tab_pos].table_name,"', '",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name,
        "', ^)")
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("VC", "C*")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name,"^)")
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("I4", "I2", "F8"
       )))
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")||'::'||r.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
        ELSE
         SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos
          ].col_qual[dfr_col_loop].column_name,")^)")
        ENDIF
       ELSEIF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].ccl_data_type IN ("DQ8", "DM12")))
        SET dfr_temp->stmt[dfr_temp->cnt].str = concat("asis(^to_char(r.",dfr_info->qual[dfr_tab_pos]
         .col_qual[dfr_col_loop].column_name,",'DD-MON-YYYY HH24:MI:SS')^)")
       ENDIF
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
       SET dfr_temp->stmt[dfr_temp->cnt].str = "asis(^, r.rowid, r.rdds_ptam_match_result)^)"
       SET dfr_temp->cnt = (dfr_temp->cnt+ 1)
      ENDIF
    ENDFOR
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) VALS_R , table ( column_diff_varray (^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    FOR (dfr_col_loop = 1 TO (dfr_temp->cnt - 1))
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,
       "r.rdds_ptam_match_result","-1",0)
      SET dfr_temp->stmt[dfr_col_loop].str = replace(dfr_temp->stmt[dfr_col_loop].str,"r.","l.",0)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = dfr_temp->stmt[dfr_col_loop].str
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    ENDFOR
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) VALS_L where ^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",dfr_pk_where,"^)")
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    SET dfr_stmt->stmt[dfr_stmt_cnt].str =
    "asis(^ and r.rowid in (select r_rowid from dm_refchg_comp_gttd))^)"
    SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
    IF ((dfr_info->qual[dfr_tab_pos].current_state_ind=1))
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1)
        AND (dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].column_name != dfr_info->qual[
       dfr_tab_pos].current_state_par_col)) OR ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].
       column_name=dfr_info->qual[dfr_tab_pos].current_state_grp_col))) )
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) ^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and l.",dfr_info->qual[dfr_tab_pos].
      current_state_par_col," in (select l1.",dfr_info->qual[dfr_tab_pos].current_state_par_col,
      " from ",
      dfr_info->qual[dfr_par_tab].table_name," l1 where ^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
      AND dfr_batch_str > " ")
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ ",replace(dfr_batch_str,"<suffix>","l1",0
        )," and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ (l1.",dfr_info->qual[dfr_par_tab].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_par_tab].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l1.",dfr_info->qual[dfr_par_tab].
       active_name," = 0 and l1.",dfr_info->qual[dfr_par_tab].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ l1.",dfr_info->qual[dfr_par_tab].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_col_list,"d1.","l1.",0),
       ") in (select ",replace(dfr_col_list,"d1.","l2.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_par_tab].
       table_name," l2 where l2.",dfr_info->qual[dfr_par_tab].active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
       AND dfr_batch_str > " ")
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
         "l2",0)," ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^)"
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)) and (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSEIF ((((dfr_info->qual[dfr_tab_pos].merge_delete_ind=0)
     AND (dfr_info->qual[dfr_tab_pos].versioning_ind=0)) OR ((dfr_info->qual[dfr_tab_pos].
    versioning_ind=1)
     AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG2", "ALG5")))) )
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ELSE
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ( ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSEIF ((dfr_info->qual[dfr_tab_pos].versioning_ind=1)
     AND (dfr_info->qual[dfr_tab_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (l.",dfr_info->qual[dfr_tab_pos].
      active_name," = 1^)")
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     IF ((dfr_info->qual[dfr_tab_pos].effective_col_ind=1))
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (l.",dfr_info->qual[dfr_tab_pos].
       active_name," = 0 and l.",dfr_info->qual[dfr_tab_pos].beg_col_name," <= sysdate and ^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ l.",dfr_info->qual[dfr_tab_pos].
       end_col_name," >= sysdate and not (^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^",replace(dfr_col_list,"r.","l.",0),
       ") in (select ",replace(dfr_col_list,"r.","l1.",0),"^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ from ",dfr_info->qual[dfr_tab_pos].
       table_name," l1 where l1.",dfr_info->qual[dfr_tab_pos].active_name," = 1^)")
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      IF ((dfr_info->qual[dfr_tab_pos].batch_flag > 0)
       AND dfr_batch_str > " ")
       SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and ",replace(dfr_batch_str,"<suffix>",
         "l1",0)," ^)")
       SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
      ENDIF
      SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ )) ^)"
      SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     ENDIF
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^) and (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSEIF ((dfr_info->qual[dfr_tab_pos].merge_delete_ind=1))
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].unique_ident_ind=1))
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
         col_qual[dfr_col_loop].column_name," = l.",dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop
         ].column_name,"^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].notnull_ind=0))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].column_name," is null)^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ and (r.",dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_col_loop].parent_entity_col," = l.",dfr_info->qual[dfr_tab_pos].col_qual[
          dfr_col_loop].parent_entity_col,"^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
         SET dfr_pe_col_idx = locateval(dfr_pe_col_idx,1,dfr_info->qual[dfr_tab_pos].col_cnt,dfr_info
          ->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col,dfr_info->qual[dfr_tab_pos].
          col_qual[dfr_pe_col_idx].column_name)
         IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_pe_col_idx].notnull_ind=0))
          SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or (r.",dfr_info->qual[dfr_tab_pos].
           col_qual[dfr_pe_col_idx].column_name," is null and l.",dfr_info->qual[dfr_tab_pos].
           col_qual[dfr_pe_col_idx].column_name," is null)^)")
          SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
         ENDIF
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^)^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     SET drcc_and_ind = 0
     FOR (dfr_col_loop = 1 TO dfr_info->qual[dfr_tab_pos].col_cnt)
       IF ((((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].pk_ind=1)) OR ((dfr_info->qual[
       dfr_tab_pos].col_qual[dfr_col_loop].meaningful_ind=1))) )
        IF (drcc_and_ind=1)
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ or ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ELSE
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ( ^)"
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
        SET drcc_and_ind = 1
        SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ vals_r.cname = '",dfr_info->qual[
         dfr_tab_pos].col_qual[dfr_col_loop].column_name,"'^)")
        SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        IF ((dfr_info->qual[dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col > " "))
         SET dfr_stmt->stmt[dfr_stmt_cnt].str = concat("asis(^ or vals_r.cname = '",dfr_info->qual[
          dfr_tab_pos].col_qual[dfr_col_loop].parent_entity_col,"'^)")
         SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ ) ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ and vals_r.cname = vals_l.cname and vals_r.tname = vals_l.tname ^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str = "asis(^ and ((vals_r.cname, vals_r.r_rowid) not in (^)"
     SET dfr_stmt_cnt = (dfr_stmt_cnt+ 1)
     SET dfr_stmt->stmt[dfr_stmt_cnt].str =
     "asis(^ select column_name, r_rowid from dm_refchg_comp_gttd))) ^) go"
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Table type not able to be identified: ",dfr_info->qual[dfr_tab_pos].
      table_name)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dfr_stmt->stmt,dfr_stmt_cnt)
    IF (drlc_debug_flag > 0)
     SELECT INTO "dm_rmc_r_live_debug.txt"
      FROM (dummyt d  WITH seq = dfr_stmt_cnt)
      DETAIL
       dfr_stmt->stmt[d.seq].str, row + 1
      WITH nocounter, maxrow = 1, maxcol = 4000,
       format = variable, formfeed = none, append
     ;end select
    ENDIF
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DFR_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_create_report(dcr_file,dcr_reply,dcr_new_ind)
   IF (dcr_new_ind=1)
    SELECT INTO value(dcr_file)
     FROM (dummyt d  WITH seq = dcr_reply->text_cnt)
     DETAIL
      dcr_reply->text_qual[d.seq].str, row + 1
     WITH nocounter, maxrow = 1, maxcol = 4000,
      format = variable, formfeed = none
    ;end select
   ELSE
    SELECT INTO value(dcr_file)
     FROM (dummyt d  WITH seq = dcr_reply->text_cnt)
     DETAIL
      dcr_reply->text_qual[d.seq].str, row + 1
     WITH nocounter, maxrow = 1, maxcol = 4000,
      format = variable, formfeed = none, append
    ;end select
   ENDIF
   IF (check_error("Create header for table")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_meaningful(dgm_mstr,dgm_info,dgm_row_pos,dgm_col_pos,dgm_pos)
   DECLARE dgm_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dgm_ret_ind = i2 WITH protect, noconstant(0)
   DECLARE dgm_parent = vc WITH protect, noconstant("")
   DECLARE dgm_pe_name_idx = i4 WITH protect, noconstant(0)
   DECLARE dgm_unresolved_ind = i2 WITH protect, noconstant(0)
   DECLARE dgm_m_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_un_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_md_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_md_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgm_break = vc WITH protect, noconstant("")
   DECLARE dgm_md_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dgm_m_idx = i4 WITH protect, noconstant(0)
   FREE RECORD dgm_map
   RECORD dgm_map(
     1 col_cnt = i4
     1 col_qual[*]
       2 table_name = vc
       2 column_name = vc
       2 column_value = vc
       2 null_ind = i2
       2 t_space_cnt = i4
       2 mngfl_pos = i4
   )
   FREE RECORD dgm_unresolved
   RECORD dgm_unresolved(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 column_value = vc
       2 tspace_cnt = i4
       2 resolved_ind = i2
       2 level = i2
   )
   SET dgm_col_idx = locateval(dgm_col_loop,1,dgm_info->qual[dgm_pos].col_cnt,dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].column_name,dgm_info->qual[dgm_pos].col_qual[dgm_col_loop].
    column_name)
   IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_null_ind=1))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = "[NULL]"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSEIF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_value="RDDS NO VAL"))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = "RDDS NO VAL"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSE
    IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].ccl_data_type IN ("DQ8", "DM12", "VC", "C*")))
     IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_tscnt > 0)
      AND size(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_value)=0)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = fillstring(value(
        dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_tscnt),"<")
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str,"<","<SPACE>",0)
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].r_value
     ENDIF
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
      dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = replace(dgm_mstr->
      diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str,char(0),"<CHAR(0)>",0)
    ELSE
     IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].idcd_ind=1)
      AND  NOT ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].exception_flg IN (1, 6, 7, 9, 10,
     11)))
      AND value(dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].constant_value)=null)
      IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name != dgm_info->qual[dgm_pos].
      root_column))
       SET dgm_unresolved_ind = 1
       SET dgm_unresolved->cnt = 1
       SET stat = alterlist(dgm_unresolved->qual,1)
       SET dgm_unresolved->qual[1].table_name = dgm_info->qual[dgm_pos].table_name
       SET dgm_unresolved->qual[1].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].r_value
       SET dgm_unresolved->qual[1].column_name = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].column_name
       SET dgm_unresolved->qual[1].level = 1
       IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col > " "))
        SET dgm_unresolved->cnt = 2
        SET stat = alterlist(dgm_unresolved->qual,2)
        SET dgm_unresolved->qual[2].table_name = dgm_info->qual[dgm_pos].table_name
        SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_mstr->diff_qual[dgm_row_pos].col_cnt,
         dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col,dgm_mstr->diff_qual[
         dgm_row_pos].col_qual[dgm_pe_name_idx].column_name)
        SET dgm_unresolved->qual[2].column_name = dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
        parent_entity_col
        SET dgm_unresolved->qual[2].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
        dgm_pe_name_idx].r_value
        SET dgm_unresolved->qual[2].level = 1
        SET dgm_unresolved->qual[2].resolved_ind = 1
       ENDIF
       WHILE (dgm_unresolved_ind=1)
         FOR (dgm_un_loop = 1 TO dgm_unresolved->cnt)
           IF ((dgm_unresolved->qual[dgm_un_loop].resolved_ind=0))
            IF (cnvtreal(dgm_unresolved->qual[dgm_un_loop].column_value) <= 0.0)
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->
             diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_value
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info
              ->qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
              column_name)
            ELSE
             SET dgm_md_tab_pos = locateval(dgm_md_tab_loop,1,dgm_info->cnt,dgm_unresolved->qual[
              dgm_un_loop].table_name,dgm_info->qual[dgm_md_tab_loop].table_name)
             SET dgm_md_col_pos = locateval(dgm_col_loop,1,dgm_info->qual[dgm_md_tab_pos].col_cnt,
              dgm_unresolved->qual[dgm_un_loop].column_name,dgm_info->qual[dgm_md_tab_pos].col_qual[
              dgm_col_loop].column_name)
             IF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].root_entity_name > " "))
              SET dgm_parent = dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].
              root_entity_name
             ELSEIF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col > " "
             ))
              SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_unresolved->cnt,dgm_info->qual[
               dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[
               dgm_pe_name_idx].column_name)
              SELECT INTO "NL:"
               var_str = evaluate_pe_name(dgm_info->qual[dgm_md_tab_pos].table_name,dgm_info->qual[
                dgm_md_tab_pos].col_qual[dgm_md_col_pos].column_name,dgm_info->qual[dgm_md_tab_pos].
                col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[dgm_pe_name_idx].
                column_value)
               FROM dual d
               DETAIL
                dgm_parent = var_str
               WITH nocounter
              ;end select
              IF (check_error(dm_err->eproc)=1)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               RETURN(1)
              ENDIF
             ELSE
              SET dgm_parent = "INVALIDTABLE"
             ENDIF
             IF (dgm_parent="INVALIDTABLE")
              SET dm_err->err_ind = 1
              SET dm_err->emsg = concat("No parent table could be found for ",dgm_info->qual[
               dgm_md_tab_pos].table_name,".",dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos]
               .column_name)
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              RETURN(1)
             ENDIF
             SET dgm_map->col_cnt = 0
             SET stat = alterlist(dgm_map->col_qual,0)
             SET dgm_ret_ind = drcc_query_parent(dgm_map,dgm_info,dgm_parent,cnvtreal(dgm_unresolved
               ->qual[dgm_un_loop].column_value),1)
             IF (((dgm_ret_ind=1) OR ((dgm_ret_ind=- (1)))) )
              RETURN(dgm_ret_ind)
             ENDIF
             SET stat = alterlist(dgm_unresolved->qual,(dgm_unresolved->cnt+ dgm_map->col_cnt))
             IF ((dgm_un_loop < dgm_unresolved->cnt))
              SET dgm_m_loop = dgm_unresolved->cnt
              WHILE (dgm_m_loop > dgm_un_loop)
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].table_name = dgm_unresolved
                ->qual[dgm_m_loop].table_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_name = dgm_unresolved
                ->qual[dgm_m_loop].column_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_value =
                dgm_unresolved->qual[dgm_m_loop].column_value
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].tspace_cnt = dgm_unresolved
                ->qual[dgm_m_loop].tspace_cnt
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].resolved_ind =
                dgm_unresolved->qual[dgm_m_loop].resolved_ind
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].level = dgm_unresolved->
                qual[dgm_m_loop].level
                SET dgm_m_loop = (dgm_m_loop - 1)
              ENDWHILE
             ENDIF
             FOR (dgm_m_loop = 1 TO dgm_map->col_cnt)
               SET dgm_m_pos = locateval(dgm_m_idx,1,dgm_map->col_cnt,dgm_m_loop,dgm_map->col_qual[
                dgm_m_idx].mngfl_pos)
               SET dgm_m_tab_pos = locateval(dgm_m_idx,1,dgm_info->cnt,dgm_parent,dgm_info->qual[
                dgm_m_idx].table_name)
               IF ((dgm_map->col_qual[dgm_m_pos].column_name != "NOMEAN"))
                SET dgm_m_col_pos = locateval(dgm_m_idx,1,dgm_info->qual[dgm_m_tab_pos].col_cnt,
                 dgm_map->col_qual[dgm_m_pos].column_name,dgm_info->qual[dgm_m_tab_pos].col_qual[
                 dgm_m_idx].column_name)
               ENDIF
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].table_name = dgm_map->col_qual[
               dgm_m_pos].table_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_name = dgm_map->col_qual[
               dgm_m_pos].column_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].tspace_cnt = dgm_map->col_qual[
               dgm_m_pos].t_space_cnt
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].level = (dgm_unresolved->qual[
               dgm_un_loop].level+ 1)
               IF ((dgm_map->col_qual[dgm_m_pos].null_ind=1))
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = "[NULL]"
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
               ELSE
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = dgm_map->col_qual[
                dgm_m_pos].column_value
                IF ((dgm_map->col_qual[dgm_m_pos].column_name="NOMEAN"))
                 SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                ELSE
                 IF ((dgm_info->qual[dgm_m_tab_pos].col_qual[dgm_m_col_pos].idcd_ind=0))
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                 ELSE
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 0
                 ENDIF
                ENDIF
               ENDIF
             ENDFOR
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_unresolved->cnt = (dgm_unresolved->cnt+ dgm_map->col_cnt)
            ENDIF
            SET dgm_unresolved_ind = 0
            FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
              IF ((dgm_unresolved->qual[dgm_m_loop].resolved_ind=0))
               SET dgm_unresolved_ind = 1
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
       ENDWHILE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_cnt = (dgm_unresolved->cnt
        - 1)
       SET stat = alterlist(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual,(
        dgm_unresolved->cnt - 1))
       FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
         IF (dgm_m_loop=1)
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_unresolved->
          qual[dgm_m_loop].column_value
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(
            dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[dgm_m_loop].
            column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = dgm_unresolved->
           qual[dgm_m_loop].table_name
          ENDIF
         ELSE
          IF ((dgm_unresolved->qual[dgm_m_loop].tspace_cnt > 0))
           IF (size(dgm_unresolved->qual[dgm_m_loop].column_value)=0)
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)]
            .mean_str = fillstring(value(dgm_unresolved->qual[dgm_m_loop].tspace_cnt),"<")
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)]
            .mean_str = replace(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(
             dgm_m_loop - 1)].mean_str,"<","<SPACE>",0)
           ELSE
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)]
            .mean_str = concat("(",dgm_unresolved->qual[dgm_m_loop].column_value,fillstring(value(
               dgm_unresolved->qual[dgm_m_loop].tspace_cnt)," "),")")
           ENDIF
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
           mean_str = dgm_unresolved->qual[dgm_m_loop].column_value
          ENDIF
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
           trans_str = concat(dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[
            dgm_m_loop].column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
           trans_str = dgm_unresolved->qual[dgm_m_loop].table_name
          ENDIF
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[(dgm_m_loop - 1)].
          level = dgm_unresolved->qual[dgm_m_loop].level
         ENDIF
       ENDFOR
      ELSE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->diff_qual[
       dgm_row_pos].col_qual[dgm_col_pos].r_value
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->
        qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      ENDIF
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].r_value
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_trans_str = concat(dgm_info->qual[
       dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_mean_str,char(0),"<CHAR(0)>",0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_null_ind=1))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = "[NULL]"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSEIF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value=dgm_mstr->diff_qual[
   dgm_row_pos].col_qual[dgm_col_pos].r_value))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_mean_str
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_trans_str
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_tscnt = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_tscnt
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt = dgm_mstr->diff_qual[
    dgm_row_pos].col_qual[dgm_col_pos].r_level_cnt
    SET stat = alterlist(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual,dgm_mstr
     ->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt)
    FOR (dgm_m_loop = 1 TO dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[dgm_m_loop].mean_str =
      dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[dgm_m_loop].mean_str
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[dgm_m_loop].trans_str
       = dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[dgm_m_loop].trans_str
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[dgm_m_loop].level =
      dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].r_level_qual[dgm_m_loop].level
    ENDFOR
   ELSEIF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value="RDDS NO VAL"))
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = "RDDS NO VAL"
    SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
     dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
   ELSE
    IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].ccl_data_type IN ("DQ8", "DM12", "VC", "C*")))
     IF ((dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_tscnt > 0)
      AND size(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value)=0)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = fillstring(value(
        dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_tscnt),"<")
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str,"<","<SPACE>",0)
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].l_value
     ENDIF
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
      dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
     SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = replace(dgm_mstr->
      diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str,char(0),"<CHAR(0)>",0)
    ELSE
     IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].idcd_ind=1)
      AND  NOT ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].exception_flg IN (1, 6, 7, 9, 10,
     11)))
      AND value(dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].constant_value)=null)
      IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name != dgm_info->qual[dgm_pos].
      root_column))
       SET dgm_unresolved_ind = 1
       SET dgm_unresolved->cnt = 1
       SET stat = alterlist(dgm_unresolved->qual,1)
       SET dgm_unresolved->qual[1].table_name = dgm_info->qual[dgm_pos].table_name
       SET dgm_unresolved->qual[1].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].l_value
       SET dgm_unresolved->qual[1].column_name = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
       dgm_col_pos].column_name
       SET dgm_unresolved->qual[1].resolved_ind = 0
       SET dgm_unresolved->qual[1].level = 1
       IF ((dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col > " "))
        SET dgm_unresolved->cnt = 2
        SET stat = alterlist(dgm_unresolved->qual,2)
        SET dgm_unresolved->qual[2].table_name = dgm_info->qual[dgm_pos].table_name
        SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_mstr->diff_qual[dgm_row_pos].col_cnt,
         dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].parent_entity_col,dgm_mstr->diff_qual[
         dgm_row_pos].col_qual[dgm_pe_name_idx].column_name)
        SET dgm_unresolved->qual[2].column_name = dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
        parent_entity_col
        SET dgm_unresolved->qual[2].column_value = dgm_mstr->diff_qual[dgm_row_pos].col_qual[
        dgm_pe_name_idx].l_value
        SET dgm_unresolved->qual[2].level = 1
        SET dgm_unresolved->qual[2].resolved_ind = 1
       ENDIF
       WHILE (dgm_unresolved_ind=1)
         FOR (dgm_un_loop = 1 TO dgm_unresolved->cnt)
           IF ((dgm_unresolved->qual[dgm_un_loop].resolved_ind=0))
            IF (cnvtreal(dgm_unresolved->qual[dgm_un_loop].column_value) <= 0.0)
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->
             diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_value
             SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info
              ->qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].
              column_name)
            ELSE
             SET dgm_md_tab_pos = locateval(dgm_md_tab_loop,1,dgm_info->cnt,dgm_unresolved->qual[
              dgm_un_loop].table_name,dgm_info->qual[dgm_md_tab_loop].table_name)
             SET dgm_md_col_pos = locateval(dgm_col_loop,1,dgm_info->qual[dgm_md_tab_pos].col_cnt,
              dgm_unresolved->qual[dgm_un_loop].column_name,dgm_info->qual[dgm_md_tab_pos].col_qual[
              dgm_col_loop].column_name)
             IF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].root_entity_name > " "))
              SET dgm_parent = dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].
              root_entity_name
             ELSEIF ((dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col > " "
             ))
              SET dgm_pe_name_idx = locateval(dgm_pe_name_idx,1,dgm_unresolved->cnt,dgm_info->qual[
               dgm_md_tab_pos].col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[
               dgm_pe_name_idx].column_name)
              SELECT INTO "NL:"
               var_str = evaluate_pe_name(dgm_info->qual[dgm_md_tab_pos].table_name,dgm_info->qual[
                dgm_md_tab_pos].col_qual[dgm_md_col_pos].column_name,dgm_info->qual[dgm_md_tab_pos].
                col_qual[dgm_md_col_pos].parent_entity_col,dgm_unresolved->qual[dgm_pe_name_idx].
                column_value)
               FROM dual d
               DETAIL
                dgm_parent = var_str
               WITH nocounter
              ;end select
              IF (check_error(dm_err->eproc)=1)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               RETURN(1)
              ENDIF
             ELSE
              SET dgm_parent = "INVALIDTABLE"
             ENDIF
             IF (dgm_parent="INVALIDTABLE")
              SET dm_err->err_ind = 1
              SET dm_err->emsg = concat("No parent table could be found for ",dgm_info->qual[
               dgm_md_tab_pos].table_name,".",dgm_info->qual[dgm_md_tab_pos].col_qual[dgm_md_col_pos]
               .column_name)
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              RETURN(1)
             ENDIF
             SET dgm_map->col_cnt = 0
             SET stat = alterlist(dgm_map->col_qual,0)
             SET dgm_ret_ind = drcc_query_parent(dgm_map,dgm_info,dgm_parent,cnvtreal(dgm_unresolved
               ->qual[dgm_un_loop].column_value),1)
             IF (((dgm_ret_ind=1) OR ((dgm_ret_ind=- (1)))) )
              RETURN(dgm_ret_ind)
             ENDIF
             SET stat = alterlist(dgm_unresolved->qual,(dgm_unresolved->cnt+ dgm_map->col_cnt))
             IF ((dgm_un_loop < dgm_unresolved->cnt))
              SET dgm_m_loop = dgm_unresolved->cnt
              WHILE (dgm_m_loop > dgm_un_loop)
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].table_name = dgm_unresolved
                ->qual[dgm_m_loop].table_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_name = dgm_unresolved
                ->qual[dgm_m_loop].column_name
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].column_value =
                dgm_unresolved->qual[dgm_m_loop].column_value
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].tspace_cnt = dgm_unresolved
                ->qual[dgm_m_loop].tspace_cnt
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].resolved_ind =
                dgm_unresolved->qual[dgm_m_loop].resolved_ind
                SET dgm_unresolved->qual[(dgm_m_loop+ dgm_map->col_cnt)].level = dgm_unresolved->
                qual[dgm_m_loop].level
                SET dgm_m_loop = (dgm_m_loop - 1)
              ENDWHILE
             ENDIF
             FOR (dgm_m_loop = 1 TO dgm_map->col_cnt)
               SET dgm_m_pos = locateval(dgm_m_pos,1,dgm_map->col_cnt,dgm_m_loop,dgm_map->col_qual[
                dgm_m_pos].mngfl_pos)
               SET dgm_m_tab_pos = locateval(dgm_m_tab_pos,1,dgm_info->cnt,dgm_parent,dgm_info->qual[
                dgm_m_tab_pos].table_name)
               IF ((dgm_map->col_qual[dgm_m_pos].column_name != "NOMEAN"))
                SET dgm_m_col_pos = locateval(dgm_m_col_pos,1,dgm_info->qual[dgm_m_tab_pos].col_cnt,
                 dgm_map->col_qual[dgm_m_pos].column_name,dgm_info->qual[dgm_m_tab_pos].col_qual[
                 dgm_m_col_pos].column_name)
               ENDIF
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].table_name = dgm_map->col_qual[
               dgm_m_pos].table_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_name = dgm_map->col_qual[
               dgm_m_pos].column_name
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].tspace_cnt = dgm_map->col_qual[
               dgm_m_pos].t_space_cnt
               SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].level = (dgm_unresolved->qual[
               dgm_un_loop].level+ 1)
               IF ((dgm_map->col_qual[dgm_m_pos].null_ind=1))
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = "[NULL]"
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
               ELSE
                SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].column_value = dgm_map->col_qual[
                dgm_m_pos].column_value
                IF ((dgm_map->col_qual[dgm_m_pos].column_name="NOMEAN"))
                 SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                ELSE
                 IF ((dgm_info->qual[dgm_m_tab_pos].col_qual[dgm_m_col_pos].idcd_ind=0))
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 1
                 ELSE
                  SET dgm_unresolved->qual[(dgm_un_loop+ dgm_m_loop)].resolved_ind = 0
                 ENDIF
                ENDIF
               ENDIF
             ENDFOR
             SET dgm_unresolved->qual[dgm_un_loop].resolved_ind = 1
             SET dgm_unresolved->cnt = (dgm_unresolved->cnt+ dgm_map->col_cnt)
            ENDIF
            SET dgm_unresolved_ind = 0
            FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
              IF ((dgm_unresolved->qual[dgm_m_loop].resolved_ind=0))
               SET dgm_unresolved_ind = 1
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
       ENDWHILE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_cnt = (dgm_unresolved->cnt
        - 1)
       SET stat = alterlist(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual,(
        dgm_unresolved->cnt - 1))
       FOR (dgm_m_loop = 1 TO dgm_unresolved->cnt)
         IF (dgm_m_loop=1)
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_unresolved->
          qual[dgm_m_loop].column_value
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(
            dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[dgm_m_loop].
            column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = dgm_unresolved->
           qual[dgm_m_loop].table_name
          ENDIF
         ELSE
          IF ((dgm_unresolved->qual[dgm_m_loop].tspace_cnt > 0))
           IF (size(dgm_unresolved->qual[dgm_m_loop].column_value)=0)
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)]
            .mean_str = fillstring(value(dgm_unresolved->qual[dgm_m_loop].tspace_cnt),"<")
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)]
            .mean_str = replace(dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(
             dgm_m_loop - 1)].mean_str,"<","<SPACE>",0)
           ELSE
            SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)]
            .mean_str = concat("(",dgm_unresolved->qual[dgm_m_loop].column_value,fillstring(value(
               dgm_unresolved->qual[dgm_m_loop].tspace_cnt)," "),")")
           ENDIF
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
           mean_str = dgm_unresolved->qual[dgm_m_loop].column_value
          ENDIF
          IF ((dgm_unresolved->qual[dgm_m_loop].column_name != "NOMEAN"))
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
           trans_str = concat(dgm_unresolved->qual[dgm_m_loop].table_name,".",dgm_unresolved->qual[
            dgm_m_loop].column_name)
          ELSE
           SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
           trans_str = dgm_unresolved->qual[dgm_m_loop].table_name
          ENDIF
          SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_level_qual[(dgm_m_loop - 1)].
          level = dgm_unresolved->qual[dgm_m_loop].level
         ENDIF
       ENDFOR
      ELSE
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
       dgm_row_pos].col_qual[dgm_col_pos].l_value
       SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->
        qual[dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      ENDIF
     ELSE
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = dgm_mstr->diff_qual[
      dgm_row_pos].col_qual[dgm_col_pos].l_value
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_trans_str = concat(dgm_info->qual[
       dgm_pos].table_name,".",dgm_info->qual[dgm_pos].col_qual[dgm_col_idx].column_name)
      SET dgm_mstr->diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str = replace(dgm_mstr->
       diff_qual[dgm_row_pos].col_qual[dgm_col_pos].l_mean_str,char(0),"<CHAR(0)>",0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_query_parent(dqp_map,dqp_info,dqp_tab_name,dqp_value,dqp_r_ind)
   DECLARE dqp_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dqp_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dqp_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dqp_root_col = vc WITH protect, noconstant("")
   DECLARE dqp_query_tab = vc WITH protect, noconstant("")
   DECLARE dqp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dqp_qual = i4 WITH protect, noconstant(0)
   DECLARE dqp_retry_ind = i2 WITH protect, noconstant(0)
   DECLARE dqp_done_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dqp_parse
   RECORD dqp_parse(
     1 stmt[*]
       2 str = vc
   )
   SET dqp_tab_pos = locateval(dqp_tab_loop,1,dqp_info->cnt,dqp_tab_name,dqp_info->qual[dqp_tab_loop]
    .table_name)
   IF (dqp_tab_pos=0)
    SET dqp_tab_pos = drc_get_meta_data(dqp_info,dqp_tab_name)
    IF (dqp_tab_pos=0)
     RETURN(1)
    ELSEIF ((dqp_tab_pos=- (1)))
     RETURN(- (1))
    ELSEIF ((dqp_tab_pos=- (2)))
     SET dqp_tab_pos = dqp_info->cnt
     SET dqp_r_ind = 0
    ENDIF
   ENDIF
   IF ((dqp_info->qual[dqp_tab_pos].r_exist_ind=0))
    SET dqp_r_ind = 0
   ENDIF
   IF (dqp_r_ind=1)
    SET dqp_query_tab = dqp_info->qual[dqp_tab_pos].r_table_name
   ELSE
    SET dqp_query_tab = dqp_tab_name
   ENDIF
   SET dqp_root_col = dqp_info->qual[dqp_tab_pos].root_column
   IF (dqp_root_col="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Could not find top level column for ",dqp_tab_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF ((dqp_info->qual[dqp_tab_pos].meaningful_cnt > 0))
    WHILE (dqp_done_ind=0)
      SET stat = alterlist(dqp_parse->stmt,200)
      SET dqp_parse->stmt[1].str = 'select into "NL:"'
      SET dqp_cnt = 2
      SET dqp_qual = 0
      FOR (dqp_col_loop = 1 TO dqp_info->qual[dqp_tab_pos].col_cnt)
        IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].meaningful_ind > 0))
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].notnull_ind=0))
          IF (dqp_cnt > 2)
           SET dqp_parse->stmt[dqp_cnt].str = ", "
           SET dqp_cnt = (dqp_cnt+ 1)
          ENDIF
          SET dqp_parse->stmt[dqp_cnt].str = concat("n",trim(cnvtstring(dqp_col_loop)),
           " = nullind(r.",dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].column_name,")")
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("VC", "C*")))
          IF (dqp_cnt > 2)
           SET dqp_parse->stmt[dqp_cnt].str = ", "
           SET dqp_cnt = (dqp_cnt+ 1)
          ENDIF
          SET dqp_parse->stmt[dqp_cnt].str = concat("ts",trim(cnvtstring(dqp_col_loop)),
           " = length(r.",dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].column_name,")")
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
        ENDIF
      ENDFOR
      SET dqp_parse->stmt[dqp_cnt].str = concat(" from ",dqp_query_tab," r where ")
      SET dqp_cnt = (dqp_cnt+ 1)
      IF (dqp_r_ind=1)
       SET dqp_parse->stmt[dqp_cnt].str = " r.rdds_delete_ind = 0 and r.rdds_status_flag < 9000 and "
       SET dqp_cnt = (dqp_cnt+ 1)
      ENDIF
      SET dqp_parse->stmt[dqp_cnt].str = concat(" r.",dqp_root_col," = dqp_value ")
      SET dqp_cnt = (dqp_cnt+ 1)
      IF (dqp_tab_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
       SET dqp_parse->stmt[dqp_cnt].str = concat(" or (r.",dqp_tab_name,
        "_ID = dqp_value and (r.active_Ind = 1 or ",
        "(r.active_ind = 0 and r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))))")
       SET dqp_cnt = (dqp_cnt+ 1)
      ENDIF
      SET dqp_parse->stmt[dqp_cnt].str = " detail dqp_qual = dqp_qual + 1"
      SET dqp_cnt = (dqp_cnt+ 1)
      FOR (dqp_col_loop = 1 TO dqp_info->qual[dqp_tab_pos].col_cnt)
        IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].meaningful_ind > 0))
         SET dqp_parse->stmt[dqp_cnt].str = concat(" dqp_map->col_cnt = dqp_map->col_cnt + 1",
          " stat = alterlist(dqp_map->col_qual, dqp_map->col_cnt) ")
         SET dqp_cnt = (dqp_cnt+ 1)
         SET dqp_parse->stmt[dqp_cnt].str = concat(
          " dqp_map->col_qual[dqp_map->col_cnt].table_name = '",dqp_tab_name,"'")
         SET dqp_cnt = (dqp_cnt+ 1)
         SET dqp_parse->stmt[dqp_cnt].str = concat(
          " dqp_map->col_qual[dqp_map->col_cnt].column_name = '",dqp_info->qual[dqp_tab_pos].
          col_qual[dqp_col_loop].column_name,"'")
         SET dqp_cnt = (dqp_cnt+ 1)
         SET dqp_parse->stmt[dqp_cnt].str = concat(
          " dqp_map->col_qual[dqp_map->col_cnt].mngfl_pos = ",trim(cnvtstring(dqp_info->qual[
            dqp_tab_pos].col_qual[dqp_col_loop].meaningful_pos)))
         SET dqp_cnt = (dqp_cnt+ 1)
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].notnull_ind=0))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].null_ind = n",trim(cnvtstring(dqp_col_loop)))
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
         IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("VC", "C*")))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = r.",dqp_info->qual[dqp_tab_pos].
           col_qual[dqp_col_loop].column_name)
          SET dqp_cnt = (dqp_cnt+ 1)
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].t_space_cnt = ts",trim(cnvtstring(dqp_col_loop)),
           " - size(dqp_map->col_qual[dqp_map->col_cnt].column_value)")
          SET dqp_cnt = (dqp_cnt+ 1)
         ELSEIF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("I4", "I2")))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = cnvtstring(r.",dqp_info->qual[
           dqp_tab_pos].col_qual[dqp_col_loop].column_name,")")
          SET dqp_cnt = (dqp_cnt+ 1)
         ELSEIF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type="F8"))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = cnvtstring(r.",dqp_info->qual[
           dqp_tab_pos].col_qual[dqp_col_loop].column_name,",20,3)")
          SET dqp_cnt = (dqp_cnt+ 1)
         ELSEIF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].ccl_data_type IN ("DQ8", "DM12")
         ))
          SET dqp_parse->stmt[dqp_cnt].str = concat(
           " dqp_map->col_qual[dqp_map->col_cnt].column_value = format(r.",dqp_info->qual[dqp_tab_pos
           ].col_qual[dqp_col_loop].column_name,",'DD-MMM-YYYY HH:MM:SS;;D')")
          SET dqp_cnt = (dqp_cnt+ 1)
         ENDIF
        ENDIF
      ENDFOR
      SET dqp_parse->stmt[dqp_cnt].str = " with nocounter go"
      SET stat = alterlist(dqp_parse->stmt,dqp_cnt)
      EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DQP_PARSE")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dqp_done_ind = 1
      ELSE
       IF (dqp_qual=0
        AND dqp_r_ind=1
        AND dqp_retry_ind=0)
        SET dqp_query_tab = dqp_tab_name
        SET dqp_retry_ind = 1
        SET dqp_r_ind = 0
        SET stat = alterlist(dqp_parse->stmt,0)
       ELSE
        SET dqp_done_ind = 1
       ENDIF
      ENDIF
    ENDWHILE
    IF ((dm_err->err_ind=1))
     RETURN(1)
    ENDIF
    IF (dqp_qual=0)
     FOR (dqp_col_loop = 1 TO dqp_info->qual[dqp_tab_pos].col_cnt)
       IF ((dqp_info->qual[dqp_tab_pos].col_qual[dqp_col_loop].meaningful_ind > 0))
        SET dqp_map->col_cnt = (dqp_map->col_cnt+ 1)
        SET stat = alterlist(dqp_map->col_qual,dqp_map->col_cnt)
        SET dqp_map->col_qual[dqp_map->col_cnt].table_name = dqp_tab_name
        SET dqp_map->col_qual[dqp_map->col_cnt].column_name = dqp_info->qual[dqp_tab_pos].col_qual[
        dqp_col_loop].column_name
        SET dqp_map->col_qual[dqp_map->col_cnt].mngfl_pos = dqp_info->qual[dqp_tab_pos].col_qual[
        dqp_col_loop].meaningful_pos
        SET dqp_map->col_qual[dqp_map->col_cnt].column_value = "<ORPHAN VALUE>"
       ENDIF
     ENDFOR
    ENDIF
    IF (dqp_qual > 1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Multiple meaningful data sets were found for table ",dqp_tab_name,
      " and value ",trim(cnvtstring(dqp_value)))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    FOR (dqp_col_loop = 1 TO dqp_map->col_cnt)
     IF (size(dqp_map->col_qual[dqp_col_loop].column_value)=0)
      IF ((dqp_map->col_qual[dqp_col_loop].t_space_cnt > 0))
       SET dqp_map->col_qual[dqp_col_loop].column_value = "<SPACE>"
      ELSE
       SET dqp_map->col_qual[dqp_col_loop].column_value = "[NULL]"
      ENDIF
     ENDIF
     SET dqp_map->col_qual[dqp_col_loop].column_value = replace(dqp_map->col_qual[dqp_col_loop].
      column_value,char(0),"<CHAR(0)>",0)
    ENDFOR
   ELSE
    SET dqp_map->col_cnt = (dqp_map->col_cnt+ 1)
    SET stat = alterlist(dqp_map->col_qual,dqp_map->col_cnt)
    SET dqp_map->col_qual[dqp_map->col_cnt].table_name = dqp_tab_name
    SET dqp_map->col_qual[dqp_map->col_cnt].column_name = "NOMEAN"
    SET dqp_map->col_qual[dqp_map->col_cnt].mngfl_pos = 1
    SET dqp_map->col_qual[dqp_map->col_cnt].column_value =
    "<No meaningful data setup for this table.>"
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_batch(dgb_mstr,dgb_info,dgb_table,dgb_delete_ind)
   DECLARE dgb_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dgb_tab_idx = i4 WITH protect, noconstant(0)
   DECLARE dgb_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgb_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dgb_md_loop = i4 WITH protect, noconstant(0)
   DECLARE dgb_col_list = vc WITH protect, noconstant("")
   FREE RECORD dgb_md
   RECORD dgb_md(
     1 cnt = i4
     1 qual[*]
       2 r_rowid = vc
       2 col_cnt = i4
       2 col_str = vc
       2 col_qual[*]
         3 column_name = vc
         3 value = vc
   )
   SET dgb_tab_idx = locateval(dgb_tab_loop,1,dgb_info->cnt,dgb_table,dgb_info->qual[dgb_tab_loop].
    table_name)
   SET stat = alterlist(dgb_mstr->diff_qual,0)
   SET dgb_mstr->diff_cnt = 0
   IF (((dgb_delete_ind=1) OR ((dgb_info->qual[dgb_tab_idx].merge_delete_ind=0)
    AND (dgb_info->qual[dgb_tab_idx].versioning_alg != "ALG5")
    AND (dgb_info->qual[dgb_tab_idx].current_state_ind=0))) )
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ELSEIF ((dgb_md->cnt > 100))
     SET dgb_col_idx = 100
    ELSE
     SET dgb_col_idx = dgb_md->cnt
    ENDIF
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_col_idx))
     SET c.status = "PROCESS"
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF ((dgb_info->qual[dgb_tab_idx].current_state_ind=1))
    SET dgb_col_list = concat("'",dgb_info->qual[dgb_tab_idx].current_state_grp_col,"'")
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = dgb_md->cnt),
      dm_refchg_comp_gttd c
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid)
       AND parser(concat(" c.column_name in (",dgb_col_list,")")))
     ORDER BY c.column_name
     DETAIL
      dgb_md->qual[d.seq].col_cnt = (dgb_md->qual[d.seq].col_cnt+ 1), stat = alterlist(dgb_md->qual[d
       .seq].col_qual,dgb_md->qual[d.seq].col_cnt), dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].
      col_cnt].column_name = c.column_name
      IF (c.r_column_value="RDDS NO VAL")
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.l_column_value
      ELSE
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.r_column_value
      ENDIF
      IF ((dgb_md->qual[d.seq].col_cnt=1))
       dgb_md->qual[d.seq].col_str = dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value
      ELSE
       dgb_md->qual[d.seq].col_str = concat(dgb_md->qual[d.seq].col_str,"||",dgb_md->qual[d.seq].
        col_qual[dgb_md->qual[d.seq].col_cnt].value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dgb_md->qual,(dgb_md->cnt+ 1))
    FOR (dgb_md_loop = 1 TO (dgb_md->cnt - 1))
      FOR (dgb_col_loop = 1 TO (dgb_md->cnt - 1))
        IF ((dgb_md->qual[dgb_md_loop].col_str > dgb_md->qual[(dgb_md_loop+ 1)].col_str))
         SET dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid = dgb_md->qual[dgb_md_loop].r_rowid
         SET dgb_md->qual[(dgb_md->cnt+ 1)].col_str = dgb_md->qual[dgb_md_loop].col_str
         SET dgb_md->qual[dgb_md_loop].r_rowid = dgb_md->qual[(dgb_md_loop+ 1)].r_rowid
         SET dgb_md->qual[dgb_md_loop].col_str = dgb_md->qual[(dgb_md_loop+ 1)].col_str
         SET dgb_md->qual[(dgb_md_loop+ 1)].r_rowid = dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid
         SET dgb_md->qual[(dgb_md_loop+ 1)].col_str = dgb_md->qual[(dgb_md->cnt+ 1)].col_str
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(dgb_md->qual,dgb_md->cnt)
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_md->cnt))
     SET c.status = "PROCESS"
     PLAN (d
      WHERE (dgb_md->qual[d.seq].col_str=dgb_md->qual[1].col_str))
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF ((dgb_info->qual[dgb_tab_idx].versioning_ind=1)
    AND (dgb_info->qual[dgb_tab_idx].versioning_alg="ALG5"))
    FOR (dgb_md_loop = 1 TO dgb_info->qual[dgb_tab_idx].col_cnt)
      IF ((dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].exception_flg=12))
       IF (dgb_col_list="")
        SET dgb_col_list = concat("'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].column_name,
         "'")
       ELSE
        SET dgb_col_list = concat(dgb_col_list,",'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop]
         .column_name,"'")
       ENDIF
      ENDIF
    ENDFOR
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = dgb_md->cnt),
      dm_refchg_comp_gttd c
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid)
       AND parser(concat(" c.column_name in (",dgb_col_list,")")))
     ORDER BY c.column_name
     DETAIL
      dgb_md->qual[d.seq].col_cnt = (dgb_md->qual[d.seq].col_cnt+ 1), stat = alterlist(dgb_md->qual[d
       .seq].col_qual,dgb_md->qual[d.seq].col_cnt), dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].
      col_cnt].column_name = c.column_name
      IF (c.r_column_value="RDDS NO VAL")
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.l_column_value
      ELSE
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.r_column_value
      ENDIF
      IF ((dgb_md->qual[d.seq].col_cnt=1))
       dgb_md->qual[d.seq].col_str = dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value
      ELSE
       dgb_md->qual[d.seq].col_str = concat(dgb_md->qual[d.seq].col_str,"||",dgb_md->qual[d.seq].
        col_qual[dgb_md->qual[d.seq].col_cnt].value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dgb_md->qual,(dgb_md->cnt+ 1))
    FOR (dgb_md_loop = 1 TO (dgb_md->cnt - 1))
      FOR (dgb_col_loop = 1 TO (dgb_md->cnt - 1))
        IF ((dgb_md->qual[dgb_md_loop].col_str > dgb_md->qual[(dgb_md_loop+ 1)].col_str))
         SET dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid = dgb_md->qual[dgb_md_loop].r_rowid
         SET dgb_md->qual[(dgb_md->cnt+ 1)].col_str = dgb_md->qual[dgb_md_loop].col_str
         SET dgb_md->qual[dgb_md_loop].r_rowid = dgb_md->qual[(dgb_md_loop+ 1)].r_rowid
         SET dgb_md->qual[dgb_md_loop].col_str = dgb_md->qual[(dgb_md_loop+ 1)].col_str
         SET dgb_md->qual[(dgb_md_loop+ 1)].r_rowid = dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid
         SET dgb_md->qual[(dgb_md_loop+ 1)].col_str = dgb_md->qual[(dgb_md->cnt+ 1)].col_str
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(dgb_md->qual,dgb_md->cnt)
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_md->cnt))
     SET c.status = "PROCESS"
     PLAN (d
      WHERE (dgb_md->qual[d.seq].col_str=dgb_md->qual[1].col_str))
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF ((dgb_info->qual[dgb_tab_idx].merge_delete_ind=1))
    FOR (dgb_md_loop = 1 TO dgb_info->qual[dgb_tab_idx].col_cnt)
      IF ((dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].merge_delete_ind=1))
       IF (dgb_col_list="")
        SET dgb_col_list = concat("'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop].column_name,
         "'")
       ELSE
        SET dgb_col_list = concat(dgb_col_list,",'",dgb_info->qual[dgb_tab_idx].col_qual[dgb_md_loop]
         .column_name,"'")
       ENDIF
      ENDIF
    ENDFOR
    SELECT DISTINCT INTO "NL:"
     d.r_rowid
     FROM dm_refchg_comp_gttd d
     DETAIL
      dgb_md->cnt = (dgb_md->cnt+ 1), stat = alterlist(dgb_md->qual,dgb_md->cnt), dgb_md->qual[dgb_md
      ->cnt].r_rowid = d.r_rowid
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((dgb_md->cnt=0))
     RETURN(0)
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = dgb_md->cnt),
      dm_refchg_comp_gttd c
     PLAN (d)
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid)
       AND parser(concat(" c.column_name in (",dgb_col_list,")")))
     ORDER BY c.column_name
     DETAIL
      dgb_md->qual[d.seq].col_cnt = (dgb_md->qual[d.seq].col_cnt+ 1), stat = alterlist(dgb_md->qual[d
       .seq].col_qual,dgb_md->qual[d.seq].col_cnt), dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].
      col_cnt].column_name = c.column_name
      IF (c.r_column_value="RDDS NO VAL")
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.l_column_value
      ELSE
       dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value = c.r_column_value
      ENDIF
      IF ((dgb_md->qual[d.seq].col_cnt=1))
       dgb_md->qual[d.seq].col_str = dgb_md->qual[d.seq].col_qual[dgb_md->qual[d.seq].col_cnt].value
      ELSE
       dgb_md->qual[d.seq].col_str = concat(dgb_md->qual[d.seq].col_str,"||",dgb_md->qual[d.seq].
        col_qual[dgb_md->qual[d.seq].col_cnt].value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Loading batch data into MSTR_DATA")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET stat = alterlist(dgb_md->qual,(dgb_md->cnt+ 1))
    FOR (dgb_md_loop = 1 TO (dgb_md->cnt - 1))
      FOR (dgb_col_loop = 1 TO (dgb_md->cnt - 1))
        IF ((dgb_md->qual[dgb_md_loop].col_str > dgb_md->qual[(dgb_md_loop+ 1)].col_str))
         SET dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid = dgb_md->qual[dgb_md_loop].r_rowid
         SET dgb_md->qual[(dgb_md->cnt+ 1)].col_str = dgb_md->qual[dgb_md_loop].col_str
         SET dgb_md->qual[dgb_md_loop].r_rowid = dgb_md->qual[(dgb_md_loop+ 1)].r_rowid
         SET dgb_md->qual[dgb_md_loop].col_str = dgb_md->qual[(dgb_md_loop+ 1)].col_str
         SET dgb_md->qual[(dgb_md_loop+ 1)].r_rowid = dgb_md->qual[(dgb_md->cnt+ 1)].r_rowid
         SET dgb_md->qual[(dgb_md_loop+ 1)].col_str = dgb_md->qual[(dgb_md->cnt+ 1)].col_str
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(dgb_md->qual,dgb_md->cnt)
    UPDATE  FROM dm_refchg_comp_gttd c,
      (dummyt d  WITH seq = value(dgb_md->cnt))
     SET c.status = "PROCESS"
     PLAN (d
      WHERE (dgb_md->qual[d.seq].col_str=dgb_md->qual[1].col_str))
      JOIN (c
      WHERE (c.r_rowid=dgb_md->qual[d.seq].r_rowid))
     WITH nocounter
    ;end update
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   SET dgb_tab_idx = locateval(dgb_tab_loop,1,dgb_info->cnt,dgb_table,dgb_info->qual[dgb_tab_loop].
    table_name)
   SELECT INTO "NL:"
    rn = nullind(d.r_column_value), ln = nullind(d.l_column_value), rts = length(d.r_column_value),
    lts = length(d.l_column_value)
    FROM dm_refchg_comp_gttd d
    WHERE d.status="PROCESS"
    ORDER BY d.r_rowid, d.column_name
    HEAD d.r_rowid
     dgb_mstr->diff_cnt = (dgb_mstr->diff_cnt+ 1), stat = alterlist(dgb_mstr->diff_qual,dgb_mstr->
      diff_cnt), dgb_mstr->table_name = dgb_table,
     dgb_mstr->diff_qual[dgb_mstr->diff_cnt].log_type = "NONE", dgb_mstr->diff_qual[dgb_mstr->
     diff_cnt].context = "NONE"
    DETAIL
     dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt = (dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
     col_cnt+ 1), stat = alterlist(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual,dgb_mstr->
      diff_qual[dgb_mstr->diff_cnt].col_cnt), dgb_mstr->diff_qual[dgb_mstr->diff_cnt].ptam_hash = d
     .r_ptam_hash_value,
     dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt
     ].column_name = d.column_name, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
     diff_qual[dgb_mstr->diff_cnt].col_cnt].r_null_ind = rn, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
     col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt].l_null_ind = ln,
     dgb_col_idx = locateval(dgb_col_loop,1,dgb_info->qual[dgb_tab_idx].col_cnt,d.column_name,
      dgb_info->qual[dgb_tab_idx].col_qual[dgb_col_loop].column_name)
     IF ((dgb_info->qual[dgb_tab_idx].col_qual[dgb_col_idx].parent_entity_col > " "))
      IF (d.r_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = substring(1,(findstring("::",d.r_column_value,1,0) - 1),d.r_column_value)
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = d.r_column_value
      ENDIF
      IF (d.l_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = substring(1,(findstring("::",d.l_column_value,1,0) - 1),d.l_column_value)
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = d.l_column_value
      ENDIF
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt = (dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt+ 1), stat = alterlist(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual,dgb_mstr->
       diff_qual[dgb_mstr->diff_cnt].col_cnt), dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt].column_name = dgb_info->qual[dgb_tab_idx].
      col_qual[dgb_col_idx].parent_entity_col,
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt].r_null_ind = rn, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[
      dgb_mstr->diff_cnt].col_cnt].l_null_ind = ln
      IF (d.r_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = substring((findstring("::",d.r_column_value,1,0)+ 2),rts,d.r_column_value),
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_tscnt = (((rts - size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
        diff_qual[dgb_mstr->diff_cnt].col_cnt].r_value)) - 2) - size(dgb_mstr->diff_qual[dgb_mstr->
        diff_cnt].col_qual[(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt - 1)].r_value))
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value = d.r_column_value
      ENDIF
      IF (d.l_column_value != "RDDS NO VAL")
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = substring((findstring("::",d.l_column_value,1,0)+ 2),lts,d.l_column_value),
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_tscnt = (((lts - size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
        diff_qual[dgb_mstr->diff_cnt].col_cnt].l_value)) - 2) - size(dgb_mstr->diff_qual[dgb_mstr->
        diff_cnt].col_qual[(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt - 1)].l_value))
      ELSE
       dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].l_value = d.l_column_value
      ENDIF
     ELSE
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt].r_value = d.r_column_value, dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr
      ->diff_qual[dgb_mstr->diff_cnt].col_cnt].l_value = d.l_column_value, dgb_mstr->diff_qual[
      dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_cnt].r_tscnt = (rts -
      size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
       col_cnt].r_value)),
      dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->diff_qual[dgb_mstr->diff_cnt].
      col_cnt].l_tscnt = (lts - size(dgb_mstr->diff_qual[dgb_mstr->diff_cnt].col_qual[dgb_mstr->
       diff_qual[dgb_mstr->diff_cnt].col_cnt].l_value))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Loading batch data into MSTR_DATA")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (drlc_debug_flag > 0
    AND curqual > 0)
    SELECT
     *
     FROM dm_refchg_comp_gttd
     WHERE status="PROCESS"
     ORDER BY r_rowid, column_name
     WITH nocounter
    ;end select
    SET drlc_debug_flag = 0
    IF (check_error("Updating batch of rows to PROCESS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   DELETE  FROM dm_refchg_comp_gttd d
    WHERE d.status="PROCESS"
    WITH nocounter
   ;end delete
   IF (check_error("Removing data loaded into MSTR_DATA from DM_REFCHG_COMP_GTTD")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_load_report(dlr_mstr,dlr_info,dlr_temp,dlr_cur_pos,dlr_env_name,dlr_del_ind)
   DECLARE dlr_row_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_mcol_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dlr_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dlr_mcol_pos = i4 WITH protect, noconstant(0)
   DECLARE dlr_mean_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_data_loop = i4 WITH protect, noconstant(0)
   DECLARE dlr_top_level_ind = i2 WITH protect, noconstant(0)
   DECLARE dlr_max_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlr_nomean = vc WITH protect, noconstant("<No meaningful data setup for this table.>")
   DECLARE dlr_size = i4 WITH protect, noconstant(0)
   SET dlr_size = size(dlr_temp->text_qual,5)
   IF (dlr_del_ind=1)
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
      IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
       SET dlr_size = (dlr_size+ 10000)
       SET stat = alterlist(dlr_temp->text_qual,dlr_size)
      ENDIF
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
       "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
       encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>")
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      IF ((dlr_info->qual[dlr_cur_pos].merge_delete_ind=0))
       SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
       "<IDENT_STR>Data to be deleted: </IDENT_STR>"
      ELSE
       SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
       "<IDENT_STR>Data Set to be deleted: </IDENT_STR>"
      ENDIF
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].merge_delete_ind=0))
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].pk_ind=1))
          SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
           dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
           dlr_row_loop].col_qual[dlr_col_loop].column_name)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_loop].l_mean_str),
           "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
           "</PK_COL>")
          IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_attr=dlr_info->qual[
          dlr_cur_pos].col_qual[dlr_col_idx].column_name)
           AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_name=dlr_info->qual[
          dlr_cur_pos].table_name))
           IF ((dlr_info->qual[dlr_cur_pos].meaningful_cnt=0))
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_nomean),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].
             table_name,"</INFO_COL></PK_INFO>")
           ELSE
            FOR (dlr_mean_loop = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
              IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].meaningful_ind=1))
               SET dlr_mcol_pos = locateval(dlr_mcol_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
                dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].column_name,dlr_mstr->diff_qual[
                dlr_row_loop].col_qual[dlr_mcol_loop].column_name)
               SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
               SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                 l_mean_str),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].col_qual[
                dlr_mean_loop].column_name,"</INFO_COL></PK_INFO>")
               FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
               l_level_cnt)
                SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
                SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                 encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                  l_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
                 dlr_row_loop].col_qual[dlr_mcol_pos].l_level_qual[dlr_data_loop].trans_str,
                 "</INFO_COL></PK_INFO>")
               ENDFOR
              ENDIF
            ENDFOR
           ENDIF
          ELSE
           IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
            FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
            l_level_cnt)
             SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
              encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
               l_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
              dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,
              "</INFO_COL></PK_INFO>")
            ENDFOR
           ENDIF
          ENDIF
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
         ENDIF
        ELSE
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=1))
          SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
           dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
           dlr_row_loop].col_qual[dlr_col_loop].column_name)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
           "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
           "</PK_COL>")
          IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
           FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
           l_level_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
              dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
             col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
           ENDFOR
          ENDIF
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
         ENDIF
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
    ENDFOR
   ELSEIF ((dlr_info->qual[dlr_cur_pos].merge_delete_ind=0)
    AND (dlr_info->qual[dlr_cur_pos].versioning_alg != "ALG5")
    AND (dlr_info->qual[dlr_cur_pos].current_state_ind=0))
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str != "RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
       "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
       encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>",
       "<IDENT_STR>Data affected: </IDENT_STR>")
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<MD_IND>0</MD_IND>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].pk_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
          "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</PK_COL>")
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_attr=dlr_info->qual[
         dlr_cur_pos].col_qual[dlr_col_idx].column_name)
          AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_name=dlr_info->qual[
         dlr_cur_pos].table_name))
          IF ((dlr_info->qual[dlr_cur_pos].meaningful_cnt=0))
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
            encode_html_string(dlr_nomean),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].
            table_name,"</INFO_COL></PK_INFO>")
          ELSE
           FOR (dlr_mean_loop = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
             IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].meaningful_ind=1))
              SET dlr_mcol_pos = locateval(dlr_mcol_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
               dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].column_name,dlr_mstr->diff_qual[
               dlr_row_loop].col_qual[dlr_mcol_loop].column_name)
              SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
              SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
               encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].l_mean_str
                ),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].
               column_name,"</INFO_COL></PK_INFO>")
              FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
              l_level_cnt)
               SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
               SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                 l_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
                dlr_row_loop].col_qual[dlr_mcol_pos].l_level_qual[dlr_data_loop].trans_str,
                "</INFO_COL></PK_INFO>")
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
         ELSE
          IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
           FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
           l_level_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
              dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
             col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
           ENDFOR
          ENDIF
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
      "<CHANGE_TYPE><CHANGE_STR>Data values to be modified: </CHANGE_STR>"
      FOR (dlr_col_idx = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_cnt)
        IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_mean_str != dlr_mstr->
        diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_info->qual[dlr_cur_pos].col_cnt,dlr_mstr->
          diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,dlr_info->qual[dlr_cur_pos].
          col_qual[dlr_col_loop].column_name)
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_loop].column_name != dlr_info->qual[
         dlr_cur_pos].root_column))
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>0</SET_CNT>"
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_COL>",
           dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,
           "</CHANGE_COL><OLD_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[
            dlr_col_idx].l_mean_str),"</OLD_VAL><NEW_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str),
           "</NEW_VAL>")
          SET dlr_max_cnt = greatest(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].
           l_level_cnt,dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt)
          FOR (dlr_data_loop = 1 TO dlr_max_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_cnt < dlr_data_loop)
            )
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
             "<CHANGE_INFO><OLD_COL></OLD_COL><OLD_VAL></OLD_VAL>"
            ELSE
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><OLD_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].
              trans_str,"</OLD_COL><OLD_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].mean_str),"</OLD_VAL>")
            ENDIF
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt >= dlr_data_loop
            ))
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
              text_cnt].str,"<NEW_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].mean_str),"</NEW_VAL><NEW_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].
              trans_str,
              "</NEW_COL>")
            ENDIF
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
             text_cnt].str,"</CHANGE_INFO>")
          ENDFOR
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA></SET_DATA>"
         ENDIF
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
     ENDIF
    ENDFOR
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str="RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
       "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
       encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>",
       "<IDENT_STR>Data to be inactivated: </IDENT_STR>")
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<MD_IND>0</MD_IND>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].pk_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_mean_str),
          "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</PK_COL>")
         IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_attr=dlr_info->qual[
         dlr_cur_pos].col_qual[dlr_col_idx].column_name)
          AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].root_entity_name=dlr_info->qual[
         dlr_cur_pos].table_name))
          IF ((dlr_info->qual[dlr_cur_pos].meaningful_cnt=0))
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
            encode_html_string(dlr_nomean),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].
            table_name,"</INFO_COL></PK_INFO>")
          ELSE
           FOR (dlr_mean_loop = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
             IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].meaningful_ind=1))
              SET dlr_mcol_pos = locateval(dlr_mcol_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
               dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].column_name,dlr_mstr->diff_qual[
               dlr_row_loop].col_qual[dlr_mcol_loop].column_name)
              SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
              SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
               encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].r_mean_str
                ),"</INFO_VAL><INFO_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_mean_loop].
               column_name,"</INFO_COL></PK_INFO>")
              FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
              r_level_cnt)
               SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
               SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
                encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_mcol_pos].
                 r_level_qual[dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[
                dlr_row_loop].col_qual[dlr_mcol_pos].r_level_qual[dlr_data_loop].trans_str,
                "</INFO_COL></PK_INFO>")
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
         ELSE
          IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_cnt > 0))
           FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
           r_level_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
             encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_qual[
              dlr_data_loop].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
             col_qual[dlr_col_pos].r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
           ENDFOR
          ENDIF
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
     ENDIF
    ENDFOR
   ELSE
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<ROW_DATA><ENV>",dlr_env_name,
     "</ENV><LOG_TYPE>",dlr_mstr->diff_qual[dlr_row_loop].log_type,"</LOG_TYPE><CONTEXT_NAME>",
     encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].context),"</CONTEXT_NAME>",
     "<IDENT_STR>Data Set affected: </IDENT_STR>")
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<MD_IND>1</MD_IND>"
    FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
      IF ((dlr_info->qual[dlr_cur_pos].current_state_ind=1)
       AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name=dlr_info->qual[dlr_cur_pos]
      .current_state_grp_col))
       SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[1].col_cnt,dlr_info->qual[
        dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[1].col_qual[dlr_col_loop].
        column_name)
       IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str="RDDS NO VAL"))
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ELSE
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ENDIF
      ELSEIF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=1)
       AND (dlr_info->qual[dlr_cur_pos].merge_delete_ind=1))
       SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[1].col_cnt,dlr_info->qual[
        dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[1].col_qual[dlr_col_loop].
        column_name)
       IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str="RDDS NO VAL"))
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ELSE
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ENDIF
      ELSEIF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg=12)
       AND (dlr_info->qual[dlr_cur_pos].versioning_ind=1)
       AND (dlr_info->qual[dlr_cur_pos].versioning_alg="ALG5"))
       SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[1].col_cnt,dlr_info->qual[
        dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[1].col_qual[dlr_col_loop].
        column_name)
       IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str="RDDS NO VAL"))
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].r_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           r_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ELSE
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_DATA><PK_VAL>",
         encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_mean_str),
         "</PK_VAL><PK_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
         "</PK_COL>")
        IF ((dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt > 0))
         FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_cnt)
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<PK_INFO><INFO_VAL>",
           encode_html_string(dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].l_level_qual[dlr_data_loop
            ].mean_str),"</INFO_VAL><INFO_COL>",dlr_mstr->diff_qual[1].col_qual[dlr_col_pos].
           l_level_qual[dlr_data_loop].trans_str,"</INFO_COL></PK_INFO>")
         ENDFOR
        ENDIF
        SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
        SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</PK_DATA>"
       ENDIF
      ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
    "<CHANGE_TYPE><CHANGE_STR>Data affected: </CHANGE_STR>"
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str != "RDDS NO VAL")
      AND (dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].r_mean_str != "RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>1</SET_CNT>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=0)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg != 12)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name != dlr_info->qual[
        dlr_cur_pos].current_state_grp_col)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].meaningful_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
          "</CHANGE_VAL><CHANGE_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</CHANGE_COL>")
         IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
          FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
          l_level_cnt)
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><CINFO_VAL>",
            encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
             dlr_data_loop].mean_str),"</CINFO_VAL><CINFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
            col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</CINFO_COL></CHANGE_INFO>")
          ENDFOR
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA>"
        ENDIF
      ENDFOR
      FOR (dlr_col_idx = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_cnt)
        IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_mean_str != dlr_mstr->
        diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str))
         IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
          SET dlr_size = (dlr_size+ 10000)
          SET stat = alterlist(dlr_temp->text_qual,dlr_size)
         ENDIF
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_info->qual[dlr_cur_pos].col_cnt,dlr_mstr->
          diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,dlr_info->qual[dlr_cur_pos].
          col_qual[dlr_col_loop].column_name)
         IF ((((dlr_info->qual[dlr_cur_pos].current_state_ind=0)) OR ((dlr_info->qual[dlr_cur_pos].
         current_state_ind=1)
          AND (dlr_info->qual[dlr_cur_pos].root_column != dlr_info->qual[dlr_cur_pos].col_qual[
         dlr_col_pos].column_name)
          AND (dlr_info->qual[dlr_cur_pos].current_state_par_col != dlr_info->qual[dlr_cur_pos].
         col_qual[dlr_col_pos].column_name))) )
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<GRP_CNT>1</GRP_CNT>"
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<GROUP_DATA><OLD_COL>",dlr_mstr->
           diff_qual[dlr_row_loop].col_qual[dlr_col_idx].column_name,"</OLD_COL><OLD_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_mean_str),
           "</OLD_VAL><NEW_VAL>",
           encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_mean_str),
           "</NEW_VAL>")
          SET dlr_max_cnt = greatest(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].
           l_level_cnt,dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt)
          FOR (dlr_data_loop = 1 TO dlr_max_cnt)
            SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_cnt < dlr_data_loop)
            )
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(
              "<GROUP_INFO><OLD_COL>-</OLD_COL><OLD_VAL>-</OLD_VAL>")
            ELSE
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<GROUP_INFO><OLD_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].
              trans_str,"</OLD_COL><OLD_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].l_level_qual[dlr_data_loop].mean_str),"</OLD_VAL>")
            ENDIF
            IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_cnt >= dlr_data_loop
            ))
             SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
              text_cnt].str,"<NEW_VAL>",encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].
               col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].mean_str),"</NEW_VAL><NEW_COL>",
              dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_idx].r_level_qual[dlr_data_loop].
              trans_str,
              "</NEW_COL>")
            ENDIF
            SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat(dlr_temp->text_qual[dlr_temp->
             text_cnt].str,"</GROUP_INFO>")
          ENDFOR
          SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
          SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</GROUP_DATA>"
         ENDIF
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</SET_DATA>"
     ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
    "<CHANGE_TYPE><CHANGE_STR>Data to be added to set:</CHANGE_STR>"
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].l_mean_str="RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>1</SET_CNT>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((((dlr_info->qual[dlr_cur_pos].merge_delete_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=0)) OR ((((dlr_info
        ->qual[dlr_cur_pos].versioning_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].versioning_alg="ALG5")
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg != 12)) OR ((dlr_info->
        qual[dlr_cur_pos].current_state_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].current_state_grp_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name)
         AND (dlr_info->qual[dlr_cur_pos].current_state_par_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name))) ))
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].meaningful_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_mean_str),
          "</CHANGE_VAL><CHANGE_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</CHANGE_COL>")
         IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_cnt > 0))
          FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
          r_level_cnt)
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><CINFO_VAL>",
            encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].r_level_qual[
             dlr_data_loop].mean_str),"</CINFO_VAL><CINFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
            col_qual[dlr_col_pos].r_level_qual[dlr_data_loop].trans_str,"</CINFO_COL></CHANGE_INFO>")
          ENDFOR
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<GRP_CNT>0</GRP_CNT></SET_DATA>"
     ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str =
    "<CHANGE_TYPE><CHANGE_STR>Data to be deleted from set:</CHANGE_STR>"
    FOR (dlr_row_loop = 1 TO dlr_mstr->diff_cnt)
     IF (((dlr_size - 1000) <= dlr_temp->text_cnt))
      SET dlr_size = (dlr_size+ 10000)
      SET stat = alterlist(dlr_temp->text_qual,dlr_size)
     ENDIF
     IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[1].r_mean_str="RDDS NO VAL"))
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<SET_DATA><SET_CNT>1</SET_CNT>"
      FOR (dlr_col_idx = 1 TO dlr_info->qual[dlr_cur_pos].col_cnt)
        IF ((((dlr_info->qual[dlr_cur_pos].merge_delete_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].merge_delete_ind=0)) OR ((((dlr_info
        ->qual[dlr_cur_pos].versioning_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].versioning_alg="ALG5")
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].exception_flg != 12)) OR ((dlr_info->
        qual[dlr_cur_pos].current_state_ind=1)
         AND (dlr_info->qual[dlr_cur_pos].current_state_grp_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name)
         AND (dlr_info->qual[dlr_cur_pos].current_state_par_col != dlr_info->qual[dlr_cur_pos].
        col_qual[dlr_col_idx].column_name))) ))
         AND (dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].meaningful_ind=1))
         SET dlr_col_pos = locateval(dlr_col_loop,1,dlr_mstr->diff_qual[dlr_row_loop].col_cnt,
          dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,dlr_mstr->diff_qual[
          dlr_row_loop].col_qual[dlr_col_loop].column_name)
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_DATA><CHANGE_VAL>",
          encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_mean_str),
          "</CHANGE_VAL><CHANGE_COL>",dlr_info->qual[dlr_cur_pos].col_qual[dlr_col_idx].column_name,
          "</CHANGE_COL>")
         IF ((dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_cnt > 0))
          FOR (dlr_data_loop = 1 TO dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].
          l_level_cnt)
           SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
           SET dlr_temp->text_qual[dlr_temp->text_cnt].str = concat("<CHANGE_INFO><CINFO_VAL>",
            encode_html_string(dlr_mstr->diff_qual[dlr_row_loop].col_qual[dlr_col_pos].l_level_qual[
             dlr_data_loop].mean_str),"</CINFO_VAL><CINFO_COL>",dlr_mstr->diff_qual[dlr_row_loop].
            col_qual[dlr_col_pos].l_level_qual[dlr_data_loop].trans_str,"</CINFO_COL></CHANGE_INFO>")
          ENDFOR
         ENDIF
         SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
         SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_DATA>"
        ENDIF
      ENDFOR
      SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
      SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "<GRP_CNT>0</GRP_CNT></SET_DATA>"
     ENDIF
    ENDFOR
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</CHANGE_TYPE>"
    SET dlr_temp->text_cnt = (dlr_temp->text_cnt+ 1)
    SET dlr_temp->text_qual[dlr_temp->text_cnt].str = "</ROW_DATA>"
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_log_type(dglt_mstr,dglt_target_id)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = dglt_mstr->diff_cnt),
     dm_chg_log dl
    PLAN (d
     WHERE (dglt_mstr->diff_qual[d.seq].ptam_hash > 0.0))
     JOIN (dl
     WHERE (dl.table_name=dglt_mstr->table_name)
      AND (dl.ptam_match_result=dglt_mstr->diff_qual[d.seq].ptam_hash)
      AND ((dl.target_env_id+ 0)=dglt_target_id))
    ORDER BY dl.updt_dt_tm
    DETAIL
     dglt_mstr->diff_qual[d.seq].log_type = dl.log_type, dglt_mstr->diff_qual[d.seq].context = dl
     .context_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcc_get_inserts(dgi_info,dgi_cur_pos,dgi_context)
   DECLARE dgi_pk_where = vc WITH protect, noconstant("")
   DECLARE dgi_col_list = vc WITH protect, noconstant("")
   DECLARE dgi_loop = i4 WITH protect, noconstant(0)
   DECLARE dgi_nullval = vc WITH protect, noconstant("")
   DECLARE dgi_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgi_ret_val = i4 WITH protect, noconstant(0)
   DECLARE dgi_par_tab = i4 WITH protect, noconstant(0)
   DECLARE dgi_par_loop = i4 WITH protect, noconstant(0)
   DECLARE dgi_par_r_table = vc WITH protect, noconstant("")
   DECLARE dgi_par_col_list = vc WITH protect, noconstant("")
   DECLARE dgi_stmt_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dgi_stmt
   RECORD dgi_stmt(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD dgi_collist
   RECORD dgi_collist(
     1 cnt = i4
     1 list[*]
       2 col = vc
     1 parcnt = i4
     1 parlist[*]
       2 col = vc
   )
   SET dgi_pk_where = concat(" r.RDDS_DELETE_IND = 0 and r.rdds_status_flag < 9000")
   IF (dgi_context != char(42))
    SET dgi_pk_where = concat(dgi_pk_where," and (r.rdds_context_name = '",dgi_context,
     "' or r.rdds_context_name = patstring('",dgi_context,
     "::*') or r.rdds_context_name = patstring('*::",dgi_context,
     "') or r.rdds_context_name = patstring ('*::",dgi_context,"::*'))")
   ENDIF
   FOR (dgi_loop = 1 TO dgi_info->qual[dgi_cur_pos].col_cnt)
    IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type IN ("VC", "C*")))
     SET dgi_nullval = "'AbyZ12%$90'"
    ELSEIF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type IN ("I4", "I2")))
     SET dgi_nullval = "-123"
    ELSEIF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type="F8"))
     SET dgi_nullval = "-123.456"
    ELSEIF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].ccl_data_type IN ("DQ8", "DM12")))
     SET dgi_nullval = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
    ENDIF
    IF ((dgi_info->qual[dgi_cur_pos].current_state_ind=1))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].column_name=dgi_info->qual[dgi_cur_pos].
     current_state_grp_col))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSEIF ((dgi_info->qual[dgi_cur_pos].merge_delete_ind=1))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].merge_delete_ind=1))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSEIF ((dgi_info->qual[dgi_cur_pos].versioning_ind=1)
     AND (dgi_info->qual[dgi_cur_pos].versioning_alg="ALG5"))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].exception_flg=12))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSEIF ((dgi_info->qual[dgi_cur_pos].versioning_ind=1)
     AND (dgi_info->qual[dgi_cur_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].unique_ident_ind=1))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ELSE
     IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].pk_ind=1))
      SET dgi_collist->cnt = (dgi_collist->cnt+ 1)
      SET stat = alterlist(dgi_collist->list,dgi_collist->cnt)
      IF ((dgi_info->qual[dgi_cur_pos].col_qual[dgi_loop].notnull_ind=1))
       SET dgi_collist->list[dgi_collist->cnt].col = concat("r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name)
      ELSE
       SET dgi_collist->list[dgi_collist->cnt].col = concat("nullval(r.",dgi_info->qual[dgi_cur_pos].
        col_qual[dgi_loop].column_name,", ",dgi_nullval,")")
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   IF ((dgi_info->qual[dgi_cur_pos].current_state_ind=0))
    SET stat = alterlist(dgi_stmt->stmt,4)
    SET dgi_stmt->stmt[1].str = concat("select into 'NL:' cnt = count(*) from ",dgi_info->qual[
     dgi_cur_pos].r_table_name," r where ")
    SET dgi_stmt->stmt[2].str = concat(dgi_pk_where," and not exists(")
    SET dgi_stmt->stmt[3].str = "select 'x'"
    SET dgi_stmt->stmt[4].str = concat(" from ",dgi_info->qual[dgi_cur_pos].table_name," l where ")
    SET dgi_stmt_cnt = 4
    FOR (dgi_loop = 1 TO dgi_collist->cnt)
      SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
      SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
      IF (dgi_stmt_cnt=5)
       SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_collist->list[dgi_loop].col," = ",replace(
         dgi_collist->list[dgi_loop].col,"r.","l.",0))
      ELSE
       SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and ",dgi_collist->list[dgi_loop].col," = ",
        replace(dgi_collist->list[dgi_loop].col,"r.","l.",0))
      ENDIF
    ENDFOR
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str,")")
    SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
    IF ((dgi_info->qual[dgi_cur_pos].versioning_ind=1))
     IF ((dgi_info->qual[dgi_cur_pos].versioning_alg IN ("ALG1", "ALG3", "ALG4")))
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and (r.",dgi_info->qual[dgi_cur_pos].
       active_name," = 1")
      IF ((dgi_info->qual[dgi_cur_pos].effective_col_ind=1))
       SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str," or r.",
        dgi_info->qual[dgi_cur_pos].end_col_name," > cnvtdatetime(curdate,curtime3)")
      ENDIF
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str," )")
     ELSEIF ((dgi_info->qual[dgi_cur_pos].versioning_alg IN ("ALG2", "ALG5")))
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and r.",dgi_info->qual[dgi_cur_pos].
       end_col_name," > cnvtdatetime(curdate,curtime3)")
     ENDIF
     SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
     SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
     SET dgi_stmt->stmt[dgi_stmt_cnt].str = " detail dgi_ret_val = cnt with nocounter go"
    ELSE
     SET dgi_stmt->stmt[dgi_stmt_cnt].str = " detail dgi_ret_val = cnt with nocounter go"
    ENDIF
   ELSE
    SET dgi_par_tab = locateval(dgi_par_loop,1,dgi_info->cnt,dgi_info->qual[dgi_cur_pos].
     current_state_parent,dgi_info->qual[dgi_par_loop].table_name)
    IF (dgi_par_tab=0)
     SET dgi_par_tab = drc_get_meta_data(dgi_info,dgi_info->qual[dgi_cur_pos].current_state_parent)
     IF (dgi_par_tab=0)
      RETURN(- (1))
     ELSEIF ((dgi_par_tab=- (1)))
      RETURN(- (2))
     ELSEIF ((dgi_par_tab=- (2)))
      SET dgi_par_tab = dgi_info->cnt
      SET dgi_par_r_table = dgi_info->qual[dgi_par_tab].table_name
     ELSE
      SET dgi_par_r_table = dgi_info->qual[dgi_par_tab].r_table_name
     ENDIF
    ELSE
     SET dgi_par_r_table = dgi_info->qual[dgi_par_tab].r_table_name
    ENDIF
    IF ((((dgi_info->qual[dgi_par_tab].versioning_ind != 1)) OR ( NOT ((dgi_info->qual[dgi_par_tab].
    versioning_alg IN ("ALG1", "ALG3"))))) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("The current state table of ",dgi_info->qual[dgi_cur_pos].table_name,
      " with parent table of ",dgi_info->qual[dgi_cur_pos].current_state_parent,
      " is currently not supported")
     RETURN(- (1))
    ENDIF
    SET stat = alterlist(dgi_stmt->stmt,100)
    SET dgi_stmt->stmt[1].str = concat("select into 'NL:' cnt = count(*) from ",dgi_info->qual[
     dgi_cur_pos].r_table_name," r where ")
    SET dgi_stmt->stmt[2].str = dgi_pk_where
    SET dgi_stmt->stmt[3].str = " and exists (select 'x' "
    SET dgi_stmt->stmt[4].str = concat(" from ",dgi_par_r_table," r1 where ")
    IF (findstring("$R",dgi_par_r_table,0,0) > 0)
     SET dgi_stmt->stmt[4].str = concat(dgi_stmt->stmt[4].str,replace(dgi_pk_where,"r.","r1.",0),
      " and ")
    ENDIF
    SET dgi_stmt->stmt[5].str = concat(" r1.",dgi_info->qual[dgi_cur_pos].current_state_par_col,
     " = r.",dgi_info->qual[dgi_cur_pos].current_state_par_col," and ")
    SET dgi_stmt->stmt[6].str = concat(" (r1.",dgi_info->qual[dgi_par_tab].active_name," =  1")
    IF ((dgi_info->qual[dgi_par_tab].effective_col_ind=1))
     SET dgi_stmt->stmt[7].str = concat(" or (r1.",dgi_info->qual[dgi_par_tab].active_name,
      " = 0 and ","r1.",dgi_info->qual[dgi_par_tab].beg_col_name,
      " <= cnvtdatetime(curdate,curtime3)")
     SET dgi_stmt->stmt[8].str = concat(" and r1.",dgi_info->qual[dgi_par_tab].end_col_name,
      " >= cnvtdatetime(curdate,curtime3)")
     FOR (dgi_loop = 1 TO dgi_info->qual[dgi_par_tab].col_cnt)
       IF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].unique_ident_ind=1))
        IF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type IN ("VC", "C*")))
         SET dgi_nullval = "'AbyZ12%$90'"
        ELSEIF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type IN ("I4", "I2")))
         SET dgi_nullval = "-123"
        ELSEIF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type="F8"))
         SET dgi_nullval = "-123.456"
        ELSEIF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].ccl_data_type IN ("DQ8", "DM12")))
         SET dgi_nullval = "to_date('18-JAN-1799 01:23:45','DD-MON-YYYY HH24:MI:SS')"
        ENDIF
        SET dgi_collist->parcnt = (dgi_collist->parcnt+ 1)
        SET stat = alterlist(dgi_collist->parlist,dgi_collist->parcnt)
        IF ((dgi_info->qual[dgi_par_tab].col_qual[dgi_loop].notnull_ind=1))
         SET dgi_collist->parlist[dgi_collist->parcnt].col = concat("r1.",dgi_info->qual[dgi_par_tab]
          .col_qual[dgi_loop].column_name)
        ELSE
         SET dgi_collist->parlist[dgi_collist->parcnt].col = concat("nullval(","r1.",dgi_info->qual[
          dgi_par_tab].col_qual[dgi_loop].column_name,",",dgi_nullval,
          ")")
        ENDIF
       ENDIF
     ENDFOR
     SET dgi_stmt->stmt[9].str = " and exists (select 'x' from "
     SET dgi_stmt->stmt[10].str = concat(dgi_par_r_table," r2 where ")
     IF (findstring("$R",dgi_par_r_table,0,0) > 0)
      SET dgi_stmt->stmt[10].str = concat(dgi_stmt->stmt[10].str,replace(dgi_pk_where,"r.","r2.",0),
       " and ")
     ENDIF
     SET dgi_stmt_cnt = 11
     SET dgi_stmt->stmt[11].str = concat(" r2.",dgi_info->qual[dgi_par_tab].active_name," = 1")
     FOR (dgi_loop = 1 TO dgi_collist->parcnt)
      SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and ",dgi_collist->parlist[dgi_loop].col," = ",
       replace(dgi_collist->parlist[dgi_loop].col,"r1.","r2.",0))
     ENDFOR
     SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(dgi_stmt->stmt[dgi_stmt_cnt].str,"))")
     SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    ELSE
     SET dgi_stmt_cnt = 7
    ENDIF
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = " )) "
    SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and not exists (select 'x' from ",dgi_info->qual[
     dgi_cur_pos].table_name," l")
    FOR (dgi_loop = 1 TO dgi_collist->cnt)
     SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
     IF (dgi_loop=1)
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" where ",replace(dgi_collist->list[dgi_loop].col,
        "r.","l.",0)," = ",dgi_collist->list[dgi_loop].col)
     ELSE
      SET dgi_stmt->stmt[dgi_stmt_cnt].str = concat(" and ",replace(dgi_collist->list[dgi_loop].col,
        "r.","l.",0)," = ",dgi_collist->list[dgi_loop].col)
     ENDIF
    ENDFOR
    SET dgi_stmt_cnt = (dgi_stmt_cnt+ 1)
    SET dgi_stmt->stmt[dgi_stmt_cnt].str = ") detail dgi_ret_val = cnt with nocounter go"
    SET stat = alterlist(dgi_stmt->stmt,dgi_stmt_cnt)
   ENDIF
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DGI_STMT")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(dgi_ret_val)
 END ;Subroutine
 SUBROUTINE drcc_log_error_info(dlei_table_name,dlei_proc,dlei_error,dlei_name)
   DECLARE dlei_ret_ind = i2 WITH protect, noconstant(0)
   SET dm_err->err_ind = 0
   FREE RECORD dlei_data
   RECORD dlei_data(
     1 text_cnt = i4
     1 text_qual[*]
       2 str = vc
   )
   SET dlei_data->text_cnt = 4
   SET stat = alterlist(dlei_data->text_qual,4)
   SET dlei_data->text_qual[1].str = concat("<TABLE_DATA><TABLE_NAME>",dlei_table_name,
    "</TABLE_NAME>")
   SET dlei_data->text_qual[2].str =
   "<ERROR_IND>1</ERROR_IND><ERROR_INFO>The report errored during the auditing of this table.</ERROR_INFO>"
   SET dlei_data->text_qual[3].str = concat("<ERROR_PROC>PROC=",encode_html_string(dlei_proc),
    "</ERROR_PROC>")
   SET dlei_data->text_qual[4].str = concat("<ERROR_MSG>ERROR=",encode_html_string(dlei_error),
    "</ERROR_MSG></TABLE_DATA>")
   SET dlei_ret_ind = drcc_create_report(dlei_name,dlei_data,0)
   RETURN(dlei_ret_ind)
 END ;Subroutine
 SUBROUTINE drcc_get_cut_cnt(dgcc_info,dgcc_cur_pos)
   DECLARE dgcc_return = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    y = count(*)
    FROM (parser(dgcc_info->qual[dgcc_cur_pos].r_table_name) r)
    WHERE r.rdds_status_flag < 9000
    DETAIL
     dgcc_return = y
    WITH nocounter
   ;end select
   IF (check_error("Getting count of uncutover rows")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(dgcc_return)
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
 DECLARE parse_string(i_string=vc,i_string_delim=vc,io_string_rs=vc(ref)) = null
 DECLARE encode_html_string(io_string=vc) = vc
 DECLARE copy_xsl(i_template_name=vc,i_file_name=vc) = i2
 DECLARE dmda_get_file_name(i_env_id=f8,i_env_name=vc,i_mnu_hdg=vc,i_default_name=vc,i_file_xtn=vc)
  = vc
 SUBROUTINE parse_string(i_string,i_string_delim,io_string_rs)
   DECLARE ps_delim_len = i4 WITH protect, noconstant(size(i_string_delim))
   DECLARE ps_str_len = i4 WITH protect, noconstant(size(i_string))
   DECLARE ps_start = i4 WITH protect, noconstant(1)
   DECLARE ps_pos = i4 WITH protect, noconstant(0)
   DECLARE ps_num_found = i4 WITH protect, noconstant(0)
   DECLARE ps_idx = i4 WITH protect, noconstant(0)
   DECLARE ps_loop = i4 WITH protect, noconstant(0)
   DECLARE ps_temp_string = vc WITH protect, noconstant("")
   SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   SET ps_num_found = size(io_string_rs->qual,5)
   WHILE (ps_pos > 0)
     SET ps_num_found = (ps_num_found+ 1)
     SET ps_temp_string = substring(ps_start,(ps_pos - ps_start),i_string)
     IF (ps_num_found > 1)
      SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
       values)
     ELSE
      SET ps_idx = 0
     ENDIF
     IF (ps_idx=0)
      SET stat = alterlist(io_string_rs->qual,ps_num_found)
      SET io_string_rs->qual[ps_num_found].values = ps_temp_string
     ELSE
      SET ps_num_found = (ps_num_found - 1)
     ENDIF
     SET ps_start = (ps_pos+ ps_delim_len)
     SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   ENDWHILE
   IF (ps_start <= ps_str_len)
    SET ps_num_found = (ps_num_found+ 1)
    SET ps_temp_string = substring(ps_start,((ps_str_len - ps_start)+ 1),i_string)
    IF (ps_num_found > 1)
     SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
      values)
    ELSE
     SET ps_idx = 0
    ENDIF
    IF (ps_idx=0)
     SET stat = alterlist(io_string_rs->qual,ps_num_found)
     SET io_string_rs->qual[ps_num_found].values = ps_temp_string
    ELSE
     SET ps_num_found = (ps_num_found - 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_html_string(i_string)
   SET i_string = replace(i_string,"&","&amp;",0)
   SET i_string = replace(i_string,"<","&lt;",0)
   SET i_string = replace(i_string,">","&gt;",0)
   RETURN(i_string)
 END ;Subroutine
 SUBROUTINE copy_xsl(i_template_name,i_file_name)
   SET dm_err->eproc = "Copying Stylesheet"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE cx_cmd = vc WITH protect, noconstant("")
   DECLARE cx_status = i4 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET cx_cmd = concat("COPY CER_INSTALL:",trim(i_template_name,3)," CCLUSERDIR:",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSE
    SET cx_cmd = concat("cp $cer_install/",trim(i_template_name,3)," $CCLUSERDIR/",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_get_file_name(i_env_id,i_env_name,i_mnu_hdg,i_default_name,i_file_xtn)
   SET dm_err->eproc = "Getting report file name"
   DECLARE dgfn_file_name = vc
   DECLARE dgfn_menu = i2
   DECLARE dgfn_file_xtn = vc
   DECLARE dgfn_default_name = vc
   IF (findstring(".",i_file_xtn)=0)
    SET dgfn_file_xtn = cnvtlower(concat(".",i_file_xtn))
   ELSE
    SET dgfn_file_xtn = cnvtlower(i_file_xtn)
   ENDIF
   IF (findstring(".",i_default_name) > 0)
    SET dgfn_default_name = cnvtlower(substring(1,(findstring(".",i_default_name) - 1),i_default_name
      ))
   ELSE
    SET dgfn_default_name = cnvtlower(i_default_name)
   ENDIF
   CALL check_lock("RDDS FILENAME LOCK",concat(dgfn_default_name,dgfn_file_xtn),drl_reply)
   IF ((drl_reply->status="F"))
    RETURN("-1")
   ELSEIF ((drl_reply->status="Z"))
    SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
         currdbhandle))),dgfn_default_name)),currdbhandle)
   ENDIF
   SET stat = initrec(drl_reply)
   SET dgfn_menu = 0
   WHILE (dgfn_menu=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,concat("***  ",i_mnu_hdg,"  ***"))
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(i_env_id))
     CALL text(4,40,i_env_name)
     CALL text(7,3,"Please enter a report file name(0 to exit): ")
     CALL text(9,3,"NOTE: This will overwrite any file in CCLUSERDIR with the same name.")
     CALL accept(7,70,"P(30);C",trim(build(dgfn_default_name,dgfn_file_xtn)))
     SET dgfn_file_name = curaccept
     IF (dgfn_file_name="0")
      SET dgfn_menu = 1
      RETURN("-1")
     ENDIF
     IF (findstring(".",dgfn_file_name)=0)
      SET dgfn_file_name = concat(dgfn_file_name,dgfn_file_xtn)
     ENDIF
     IF (size(dgfn_file_name) > 30)
      SET dgfn_file_name = concat(trim(substring(1,(30 - size(dgfn_file_xtn)),dgfn_file_name)),
       dgfn_file_xtn)
     ENDIF
     CALL check_lock("RDDS FILENAME LOCK",dgfn_file_name,drl_reply)
     IF ((drl_reply->status="F"))
      RETURN("-1")
     ENDIF
     IF (cnvtlower(substring(findstring(".",dgfn_file_name),size(dgfn_file_name,1),dgfn_file_name))
      != cnvtlower(dgfn_file_xtn))
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgfn_file_xtn))
      CALL pause(5)
     ELSEIF ((drl_reply->status="Z"))
      CALL text(20,3,concat("File name ",dgfn_file_name,
        " is currently locked, please choose a different filename."))
      CALL pause(5)
      IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
        currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
       SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name
         ),trim(currdbhandle))
      ELSE
       SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
            currdbhandle))),dgfn_file_name)),trim(currdbhandle))
      ENDIF
     ELSE
      CALL get_lock("RDDS FILENAME LOCK",dgfn_file_name,1,drl_reply)
      IF ((drl_reply->status="F"))
       RETURN("-1")
      ELSEIF ((drl_reply->status="Z"))
       CALL text(20,3,concat("File name ",dgfn_file_name,
         " is currently locked, please choose a different filename."))
       CALL pause(5)
       IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
         currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
        SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),
          dgfn_file_name),trim(currdbhandle))
       ELSE
        SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
             currdbhandle))),dgfn_file_name)),trim(currdbhandle))
       ENDIF
      ELSE
       SET dgfn_menu = 1
      ENDIF
     ENDIF
     SET stat = initrec(drl_reply)
   ENDWHILE
   RETURN(dgfn_file_name)
 END ;Subroutine
 DECLARE evaluate_pe_name() = c255
 DECLARE length() = i4
 IF (check_logfile("dm_test_comp",".log","DM_TEST_COMP LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (validate(test_reply->status,9)=9)
  FREE RECORD test_reply
  RECORD test_reply(
    1 status = i4
  )
 ENDIF
 SET dm_err->emsg = "This is a hard-coded error"
 IF ((test_request->num_parm=1))
  SET test_reply->status = drc_get_meta_data(drc_tab_info,test_request->vc1_parm)
 ELSEIF ((test_request->num_parm=2))
  FREE RECORD drcc_reply
  RECORD drcc_reply(
    1 status = c1
    1 status_msg = vc
    1 text_cnt = i4
    1 text_qual[*]
      2 str = vc
      2 col = i4
  )
  SET drcc_reply->text_cnt = 4
  SET stat = alterlist(drcc_reply->text_qual,4)
  SET drcc_reply->text_qual[1].str = "this is string 1"
  SET drcc_reply->text_qual[2].str = "this is string 2"
  SET drcc_reply->text_qual[3].str = "this is string 3"
  SET drcc_reply->text_qual[4].str = "this is string 4"
  SET test_reply->status = drcc_create_report(test_request->vc1_parm,drcc_reply,test_request->
   i41_parm)
 ELSEIF ((test_request->num_parm=3))
  SET test_reply->status = drcc_log_error_info(test_request->vc1_parm,test_request->vc2_parm,
   test_request->vc3_parm,test_request->vc4_parm)
 ELSEIF ((test_request->num_parm=4))
  SET test_reply->status = drcc_get_log_type(mstr_data,test_request->f81_parm)
 ELSEIF ((test_request->num_parm=5))
  SET test_reply->status = drcc_get_meaningful(mstr_data,drc_tab_info,1,1,1)
 ELSEIF ((test_request->num_parm=6))
  SET test_reply->status = drcc_query_parent(dgm_map,drc_tab_info,test_request->vc1_parm,test_request
   ->f81_parm,test_request->i41_parm)
 ELSEIF ((test_request->num_parm=7))
  SET test_reply->status = drcc_get_batch(mstr_data,drc_tab_info,test_request->vc1_parm,test_request
   ->i41_parm)
 ELSEIF ((test_request->num_parm=8))
  SET test_reply->status = drcc_get_inserts(drc_tab_info,1,test_request->vc1_parm)
 ELSEIF ((test_request->num_parm=9))
  SET test_reply->status = drcc_find_rows(drc_tab_info,test_request->vc1_parm,test_request->vc2_parm,
   test_request->i41_parm,test_request->vc3_parm)
 ELSEIF ((test_request->num_parm=10))
  SET test_reply->status = drcc_get_cut_cnt(drc_tab_info,1)
 ENDIF
 CALL echo("Wrapper script for inc file")
#exit_main
END GO
