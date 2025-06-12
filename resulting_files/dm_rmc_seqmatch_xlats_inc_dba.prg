CREATE PROGRAM dm_rmc_seqmatch_xlats_inc:dba
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
 IF ((validate(sx_request->cnt,- (99))=- (99)))
  FREE RECORD sx_request
  RECORD sx_request(
    1 cnt = i4
    1 stmt[*]
      2 str = vc
  ) WITH protect
 ENDIF
 IF ((validate(sx_reply->row_count,- (99))=- (99)))
  FREE RECORD sx_reply
  RECORD sx_reply(
    1 row_count = i4
  ) WITH protect
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
     SET dm_err->eproc = "Inserting RDDS_NO_MOCK_ENV_ID row."
     INSERT  FROM dm_info di
      SET di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS_NO_MOCK_ENV_ID", di.info_number =
       0.0,
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
 IF (validate(dm_batch_list_req->dblg_owner,"XYZ")="XYZ"
  AND validate(dm_batch_list_req->dblg_owner,"ABC")="ABC")
  FREE RECORD dm_batch_list_req
  RECORD dm_batch_list_req(
    1 dblg_owner = vc
    1 dblg_table = vc
    1 dblg_table_id = vc
    1 dblg_column = vc
    1 dblg_where = vc
    1 dblg_mode = vc
    1 dblg_num_cnt = i4
  )
 ENDIF
 IF (validate(dm_batch_list_rep->status_msg,"XYZ")="XYZ"
  AND validate(dm_batch_list_rep->status_msg,"ABC")="ABC")
  FREE RECORD dm_batch_list_rep
  RECORD dm_batch_list_rep(
    1 status = c1
    1 status_msg = vc
    1 list[*]
      2 batch_num = i4
      2 max_value = vc
  )
 ENDIF
 DECLARE seqmatch_xlats(i_sequence_name=vc,i_source_env_id=f8,i_table_name=vc) = vc
 DECLARE app_task_backfill(i_atb_source_env_id=f8) = vc
 DECLARE seqmatch_event_chk(i_source_id=f8,i_target_id=f8,i_sequence_name=vc) = vc
 DECLARE add_src_done_2(i_src_id=f8,i_tgt_id=f8,i_tgt_mock_id=f8,i_sequence=vc) = vc
 SUBROUTINE seqmatch_xlats(i_sequence_name,i_source_env_id,i_table_name)
   SET dm_err->eproc = concat("Start Xlat Backfill",format(cnvtdatetime(curdate,curtime3),cclfmt->
     mediumdatetime))
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE sx_table_suffix = vc
   DECLARE sx_live_table_name = vc
   DECLARE sx_sequence_name = vc
   DECLARE sx_target_id = f8
   DECLARE sx_t_id1 = f8
   DECLARE sx_t_id2 = f8
   DECLARE sx_db_link = vc
   DECLARE sx_seq_match_domain = vc
   DECLARE sx_src_seq_match_domain = vc WITH protect, noconstant("")
   DECLARE sx_seq_match_num = f8
   DECLARE sx_val_loop = i4
   DECLARE sx_where_stmt = vc
   DECLARE sx_dmt_source = vc
   DECLARE sx_filter_name = vc
   DECLARE sx_filter = vc
   DECLARE sx_col_loop = i4
   DECLARE sx_next_seq = f8
   DECLARE sx_continue_ind = i2
   DECLARE sx_insert_limit = i4
   DECLARE sx_asd2_ret = vc WITH protect, noconstant("")
   DECLARE sx_sec_ret = vc WITH protect, noconstant("")
   DECLARE sx_tbl_allrow_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE sx_tbl_fltr_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE sx_range_start = vc WITH protect, noconstant("")
   DECLARE sx_range_end = vc WITH protect, noconstant("")
   DECLARE sx_range_idx = i4 WITH protect, noconstant(0)
   DECLARE sx_s_col_name = vc
   DECLARE sx_t_col_name = vc
   DECLARE sx_s_table_name = vc
   DECLARE sx_dmt_s = vc
   DECLARE sx_atb_return = vc
   FREE RECORD sx_tbl_list
   RECORD sx_tbl_list(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 suffix = vc
       2 val_cnt = i4
       2 values[*]
         3 source_val = f8
   )
   FREE RECORD sx_filter_columns
   RECORD sx_filter_columns(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   IF (trim(i_sequence_name) <= "")
    IF (trim(i_table_name) > "")
     IF (cnvtupper(i_table_name)="*$R")
      SET sx_table_suffix = substring((size(i_table_name) - 5),4,i_table_name)
      SELECT INTO "nl:"
       FROM dm_tables_doc dtd
       WHERE dtd.table_suffix=sx_table_suffix
        AND dtd.full_table_name=dtd.table_name
       DETAIL
        sx_live_table_name = dtd.table_name
       WITH nocounter
      ;end select
      IF (check_error("Obtaining live table name") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       CALL echo("*****************************************************************")
       CALL echo("")
       CALL echo("Error: seqmatch_xlats():Live table name could not be obtained from ")
       CALL echo("table_name passed in.")
       CALL echo("")
       CALL echo("*****************************************************************")
       RETURN("F")
      ENDIF
     ELSE
      SET sx_live_table_name = cnvtupper(i_table_name)
     ENDIF
     IF (cnvtupper(sx_live_table_name)="APPLICATION_TASK")
      SET sx_atb_return = app_task_backfill(i_source_env_id)
      RETURN(sx_atb_return)
     ENDIF
     SELECT INTO "nl:"
      dcd.sequence_name
      FROM dm_columns_doc dcd,
       dm_tables_doc dtd
      WHERE dtd.table_name=sx_live_table_name
       AND ((dtd.reference_ind=1) OR (dtd.table_name IN (
      (SELECT
       rt.table_name
       FROM dm_rdds_refmrg_tables rt))))
       AND dtd.table_name IN (
      (SELECT
       ut.table_name
       FROM user_tables ut))
       AND dtd.table_name=dtd.full_table_name
       AND dtd.table_name=dcd.table_name
       AND dcd.table_name=dcd.root_entity_name
       AND dcd.column_name=dcd.root_entity_attr
       AND  NOT (dtd.table_name IN (
      (SELECT
       cv.display
       FROM code_value cv
       WHERE cv.code_set=4001912
        AND cv.cdf_meaning="NORDDSTRG"
        AND cv.active_ind=1)))
      DETAIL
       sx_sequence_name = dcd.sequence_name
      WITH nocounter
     ;end select
     IF (check_error("Obtaining sequence name") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     IF (curqual=0)
      RETURN("S")
     ENDIF
    ELSE
     CALL echo("*****************************************************************")
     CALL echo("")
     CALL echo("Error: seqmatch_xlats():sequence_name and table_name passed in")
     CALL echo("were not filled out.")
     CALL echo("")
     CALL echo("*****************************************************************")
     RETURN("F")
    ENDIF
   ELSE
    SET sx_sequence_name = i_sequence_name
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     sx_t_id1 = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    CALL echo("*****************************************************************")
    CALL echo("")
    CALL echo("Error: seqmatch_xlats():no dm_info row found to obtain target_id")
    CALL echo("")
    CALL echo("*****************************************************************")
    RETURN("F")
   ENDIF
   SET sx_db_link = build("@MERGE",cnvtstring(i_source_env_id),cnvtstring(sx_t_id1))
   SET sx_target_id = drmmi_get_mock_id(sx_t_id1)
   IF (sx_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET sx_seq_match_domain = build("MERGE",cnvtstring(i_source_env_id),cnvtstring(sx_target_id),
    "SEQMATCH")
   SET sx_src_seq_match_domain = build("MERGE",cnvtstring(sx_target_id),cnvtstring(i_source_env_id),
    "SEQMATCH")
   SET sx_dmt_source = build("DM_MERGE_TRANSLATE",sx_db_link)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=sx_seq_match_domain
     AND di.info_name=sx_sequence_name
    DETAIL
     sx_seq_match_num = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (sx_seq_match_num <= 0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end select
    IF (check_error("Checking DONE2 sequence row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_domain = concat(trim(sx_seq_match_domain),"DONE2"), di.info_name = sx_sequence_name,
       di.info_number = 0,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting 0 sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ELSE
      COMMIT
      SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
      IF (sx_sec_ret="F")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
      IF (sx_asd2_ret="F")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      RETURN("S")
     ENDIF
    ELSE
     RETURN("S")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",sx_db_link)) di)
    WHERE di.info_domain=concat(sx_src_seq_match_domain,"DONE2")
     AND di.info_name=sx_sequence_name
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end select
    IF (check_error("Checking DONE2 sequence row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     UPDATE  FROM dm_info di
      SET di.info_domain = concat(trim(sx_seq_match_domain),"DONE2"), di.updt_task = 4310001, di
       .updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=sx_seq_match_domain
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence done2 row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     INSERT  FROM dm_info di
      SET di.info_domain = sx_seq_match_domain, di.info_name = sx_sequence_name, di.info_number = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = 4310001
      WITH nocounter
     ;end insert
     IF (check_error("Updating old sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ELSE
     UPDATE  FROM dm_info di
      SET di.info_number = sx_seq_match_num, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
       .updt_task = 4310001
      WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence done2 row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = 4310001
      WHERE di.info_domain=sx_seq_match_domain
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating old sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    dcd.table_name, dcd.column_name
    FROM dm_columns_doc dcd,
     dm_tables_doc dtd
    WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
    (SELECT
     rt.table_name
     FROM dm_rdds_refmrg_tables rt))))
     AND dtd.table_name=dtd.full_table_name
     AND dtd.table_name=dcd.table_name
     AND ((dcd.table_name=dcd.root_entity_name
     AND dcd.column_name=dcd.root_entity_attr) OR (((dcd.table_name="DCP_FORMS_REF"
     AND dcd.column_name="DCP_FORMS_REF_ID") OR (dcd.table_name="DCP_SECTION_REF"
     AND dcd.column_name="DCP_SECTION_REF_ID")) ))
     AND list(dcd.table_name,dcd.column_name) IN (
    (SELECT
     utc.table_name, utc.column_name
     FROM user_tab_columns utc))
     AND dcd.sequence_name=sx_sequence_name
     AND  NOT (dtd.table_name IN (
    (SELECT
     cv.display
     FROM code_value cv
     WHERE cv.code_set=4001912
      AND cv.cdf_meaning="NORDDSTRG"
      AND cv.active_ind=1)))
     AND  NOT (dtd.table_name IN (
    (SELECT
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="RDDS BACKFILL EXCLUSION")))
     AND list(dcd.table_name,dcd.column_name) IN (
    (SELECT
     utc2.table_name, utc2.column_name
     FROM (parser(build("user_tab_columns",sx_db_link)) utc2)))
    HEAD REPORT
     sx_tbl_list->cnt = 0
    DETAIL
     sx_tbl_list->cnt = (sx_tbl_list->cnt+ 1)
     IF (mod(sx_tbl_list->cnt,10)=1)
      stat = alterlist(sx_tbl_list->qual,(sx_tbl_list->cnt+ 9))
     ENDIF
     sx_tbl_list->qual[sx_tbl_list->cnt].table_name = dcd.table_name, sx_tbl_list->qual[sx_tbl_list->
     cnt].column_name = dcd.column_name, sx_tbl_list->qual[sx_tbl_list->cnt].suffix = dtd
     .table_suffix
    FOOT REPORT
     stat = alterlist(sx_tbl_list->qual,sx_tbl_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error("Obtaining tables associated with the current sequence") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF ((sx_tbl_list->cnt > 0))
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="RXLAT_BELOW_SEQ_FILL"
     DETAIL
      sx_insert_limit = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Logging creation in dm_chg_log_audit") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET sx_insert_limit = 100000
    ENDIF
    FOR (sx_val_loop = 1 TO sx_tbl_list->cnt)
      SELECT INTO "NL:"
       y = seq(dm_merge_audit_seq,nextval)
       FROM dual
       DETAIL
        sx_next_seq = y
       WITH nocounter
      ;end select
      IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET dm_err->eproc = concat("Start Table: ",sx_tbl_list->qual[sx_val_loop].table_name," ",format
       (cnvtdatetime(curdate,curtime3),cclfmt->mediumdatetime))
      CALL disp_msg("",dm_err->logfile,0)
      UPDATE  FROM dm_chg_log_audit dcla
       SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = sx_tbl_list->qual[
        sx_val_loop].table_name,
        dcla.text = concat("Backfill translations below seqmatch for sequence: ",sx_sequence_name,
         ", working on table ",cnvtstring(sx_val_loop)," of ",
         cnvtstring(sx_tbl_list->cnt),": ",sx_tbl_list->qual[sx_val_loop].table_name), dcla
        .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
        dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->
        updt_task,
        dcla.audit_dt_tm = sysdate
       WHERE dcla.dm_chg_log_audit_id=sx_next_seq
       WITH nocounter
      ;end update
      IF (check_error("Updating creation in dm_chg_log_audit") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_chg_log_audit dcla
        SET dcla.dm_chg_log_audit_id = sx_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
         dcla.table_name = sx_tbl_list->qual[sx_val_loop].table_name, dcla.text = concat(
          "Backfill translations below seqmatch for sequence: ",sx_sequence_name,
          ", working on table ",cnvtstring(sx_val_loop)," of ",
          cnvtstring(sx_tbl_list->cnt),": ",sx_tbl_list->qual[sx_val_loop].table_name), dcla
         .updt_applctx = cnvtreal(currdbhandle),
         dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
         dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
        WITH nocounter
       ;end insert
      ENDIF
      IF (check_error("Logging creation in dm_chg_log_audit") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      SET sx_filter_name = concat("REFCHG_FILTER_",sx_tbl_list->qual[sx_val_loop].suffix,"*")
      CALL echo(sx_filter_name)
      SELECT INTO "nl:"
       FROM user_objects uo
       WHERE uo.object_name=patstring(sx_filter_name)
        AND  NOT ( EXISTS (
       (SELECT
        di.info_name
        FROM dm_info di
        WHERE di.info_domain="RDDS BACKFILL FILTER EXCLUSION"
         AND (di.info_name=sx_tbl_list->qual[sx_val_loop].table_name))))
       DETAIL
        sx_filter_name = uo.object_name, sx_filter = uo.object_name
       WITH nocounter
      ;end select
      IF (check_error("Obtaining Filter") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       SET sx_filter = "1"
      ELSE
       SET sx_filter_name = concat("declare ",sx_filter_name,"()=i2 go")
       CALL parser(sx_filter_name)
       SELECT INTO "nl:"
        dr.column_name
        FROM dm_refchg_filter_parm dr
        WHERE (dr.table_name=sx_tbl_list->qual[sx_val_loop].table_name)
         AND dr.active_ind=1
        ORDER BY dr.parm_nbr
        HEAD REPORT
         sx_filter_columns->cnt = 0
        DETAIL
         sx_filter_columns->cnt = (sx_filter_columns->cnt+ 1), stat = alterlist(sx_filter_columns->
          qual,sx_filter_columns->cnt), sx_filter_columns->qual[sx_filter_columns->cnt].column_name
          = dr.column_name
        WITH nocounter
       ;end select
       IF (check_error("Obtaining columns for the filter") != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       IF (curqual > 0)
        SET sx_filter = concat(sx_filter,"('ADD'")
        FOR (sx_col_loop = 1 TO sx_filter_columns->cnt)
          SET sx_filter = concat(sx_filter,",t.",sx_filter_columns->qual[sx_col_loop].column_name,
           ",t.",sx_filter_columns->qual[sx_col_loop].column_name)
        ENDFOR
        SET sx_filter = concat(sx_filter,")")
       ELSE
        SET sx_filter = "1"
       ENDIF
      ENDIF
      SET sx_s_col_name = build("s.",sx_tbl_list->qual[sx_val_loop].column_name)
      SET sx_t_col_name = build("t.",sx_tbl_list->qual[sx_val_loop].column_name)
      SET sx_s_table_name = build(sx_tbl_list->qual[sx_val_loop].table_name,sx_db_link)
      SET sx_dmt_s = build("dm_merge_translate",sx_db_link)
      SET sx_continue_ind = 0
      SET sx_request->cnt = 1
      SET stat = alterlist(sx_request->stmt,sx_request->cnt)
      SET sx_reply->row_count = 0
      SET sx_tbl_fltr_cnt = 0
      SELECT INTO "nl:"
       cnt = count(sx_tbl_list->qual[sx_val_loop].column_name)
       FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
       WHERE ((parser(sx_tbl_list->qual[sx_val_loop].column_name) BETWEEN 1 AND sx_seq_match_num
        AND parser(sx_filter)=1) UNION (
       (SELECT
        cnt = count(ti.parent_entity_id)
        FROM dm_refchg_invalid_xlat ti
        WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
         AND ((ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num) UNION (
        (SELECT
         cnt = count(si.parent_entity_id)
         FROM (parser(concat("dm_refchg_invalid_xlat",sx_db_link)) si)
         WHERE (si.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
          AND si.parent_entity_id BETWEEN 1 AND sx_seq_match_num))) )))
       DETAIL
        sx_tbl_fltr_cnt = (sx_tbl_fltr_cnt+ cnt)
       WITH nocounter
      ;end select
      IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
        table_name)) != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (sx_tbl_fltr_cnt > sx_insert_limit)
       SET dm_batch_list_req->dblg_num_cnt = ceil((sx_tbl_fltr_cnt/ cnvtreal(sx_insert_limit)))
       SET dm_batch_list_req->dblg_where = concat(" where ",sx_tbl_list->qual[sx_val_loop].
        column_name," between 1 and ",cnvtstring(sx_seq_match_num)," and ",
        replace(sx_filter,"t.","")," = 1")
      ELSEIF (sx_tbl_fltr_cnt < sx_insert_limit
       AND sx_filter != "1")
       SET sx_tbl_allrow_cnt = 0
       SELECT INTO "nl:"
        cnt = count(sx_tbl_list->qual[sx_val_loop].column_name)
        FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
        WHERE ((parser(sx_tbl_list->qual[sx_val_loop].column_name) BETWEEN 1 AND sx_seq_match_num)
         UNION (
        (SELECT
         cnt = count(ti.parent_entity_id)
         FROM dm_refchg_invalid_xlat ti
         WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
          AND ((ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num) UNION (
         (SELECT
          cnt = count(si.parent_entity_id)
          FROM (parser(concat("dm_refchg_invalid_xlat",sx_db_link)) si)
          WHERE (si.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
           AND si.parent_entity_id BETWEEN 1 AND sx_seq_match_num))) )))
        DETAIL
         sx_tbl_allrow_cnt = (sx_tbl_allrow_cnt+ cnt)
        WITH nocounter
       ;end select
       IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
         table_name)) != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       IF (sx_tbl_allrow_cnt > sx_insert_limit)
        SET dm_batch_list_req->dblg_num_cnt = ceil((sx_tbl_allrow_cnt/ cnvtreal(sx_insert_limit)))
        SET dm_batch_list_req->dblg_where = concat(" where ",sx_tbl_list->qual[sx_val_loop].
         column_name," between 1 and ",cnvtstring(sx_seq_match_num))
       ELSE
        SET stat = alterlist(dm_batch_list_rep->list,1)
        SET dm_batch_list_rep->list[1].max_value = cnvtstring(sx_seq_match_num,20,0)
        SET dm_batch_list_req->dblg_num_cnt = 1
        SET sx_continue_ind = 1
       ENDIF
      ELSE
       CALL echo("sx_tbl_allrow_cnt < sx_insert_limit")
       SET stat = alterlist(dm_batch_list_rep->list,1)
       SET dm_batch_list_rep->list[1].max_value = cnvtstring(sx_seq_match_num,20,0)
       SET dm_batch_list_req->dblg_num_cnt = 1
       SET sx_continue_ind = 1
      ENDIF
      IF (sx_continue_ind=0)
       SET dm_batch_list_req->dblg_owner = "V500"
       SET dm_batch_list_req->dblg_table = sx_tbl_list->qual[sx_val_loop].table_name
       SET dm_batch_list_req->dblg_column = sx_tbl_list->qual[sx_val_loop].column_name
       SET dm_batch_list_req->dblg_mode = "BATCH"
       EXECUTE dm_get_batch_list
       IF ((dm_batch_list_rep->status="F"))
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
      FOR (sx_range_idx = 1 TO size(dm_batch_list_rep->list,5))
        IF (sx_range_idx=1)
         SET sx_range_start = "1"
        ELSE
         SET sx_range_start = cnvtstring(dm_batch_list_rep->list[(sx_range_idx - 1)].max_value,20,0)
        ENDIF
        IF (sx_range_idx=size(dm_batch_list_rep->list,5))
         SET sx_range_end = cnvtstring(sx_seq_match_num,20,0)
        ELSE
         SET sx_range_end = cnvtstring(dm_batch_list_rep->list[sx_range_idx].max_value,20,0)
        ENDIF
        SELECT INTO "NL:"
         y = seq(dm_merge_audit_seq,nextval)
         FROM dual
         DETAIL
          sx_next_seq = y
         WITH nocounter
        ;end select
        IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ENDIF
        CALL echo(sx_tbl_list->qual[sx_val_loop].table_name)
        UPDATE  FROM dm_chg_log_audit dcla
         SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = sx_tbl_list->qual[
          sx_val_loop].table_name,
          dcla.text = concat("Backfill translations for sequence: ",sx_sequence_name,", table: ",
           sx_tbl_list->qual[sx_val_loop].table_name," batch: ",
           cnvtstring(sx_range_idx)," of ",cnvtstring(dm_batch_list_req->dblg_num_cnt)), dcla
          .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
          dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->
          updt_task,
          dcla.audit_dt_tm = sysdate
         WHERE dcla.dm_chg_log_audit_id=sx_next_seq
         WITH nocounter
        ;end update
        IF (check_error("Logging creation in dm_chg_log_audit") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ELSE
         COMMIT
        ENDIF
        IF (curqual=0)
         INSERT  FROM dm_chg_log_audit dcla
          SET dcla.dm_chg_log_audit_id = sx_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
           dcla.table_name = sx_tbl_list->qual[sx_val_loop].table_name, dcla.text = concat(
            "Backfill translations for sequence: ",sx_sequence_name,", table: ",sx_tbl_list->qual[
            sx_val_loop].table_name," batch: ",
            cnvtstring(sx_range_idx)," of ",cnvtstring(dm_batch_list_req->dblg_num_cnt)), dcla
           .updt_applctx = cnvtreal(currdbhandle),
           dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
           dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
          WITH nocounter
         ;end insert
        ENDIF
        IF (check_error("Logging creation in dm_chg_log_audit") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ELSE
         COMMIT
        ENDIF
        SET sx_continue_ind = 0
        WHILE (sx_continue_ind=0)
          SET sx_request->stmt[1].str = concat(
           " rdb asis(^insert /*+ CCL<DM_RMC_SEQMATCH_XLATS:S> */ ","into dm_merge_translate dmt ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ( dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  dmt.status_flg, dmt.updt_dt_tm ) ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " (select from_value, table_name, env_source_id, env_target_id, to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  status_flg, updt_dt_tm from ( ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" select ",
            sx_s_col_name," from_value , "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" table_name , ",
            i_source_env_id," env_source_id, ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" env_target_id, ",
            sx_s_col_name," to_value ,3 status_flg,sysdate updt_dt_tm "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("   from ",
            sx_s_table_name," s, ",sx_tbl_list->qual[sx_val_loop].table_name," t "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("  where ",
            sx_s_col_name," = ",sx_t_col_name))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("    and ",
            sx_s_col_name," between ",sx_range_start," and ",
            sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("    and ",sx_filter,
            " = 1"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," union ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_id from_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_name table_name,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(i_source_env_id,
            " env_source_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(sx_target_id,
            " env_target_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_id to_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," 3 status_flg,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," sysdate updt_dt_tm")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  from dm_refchg_invalid_xlat ti ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " where ti.parent_entity_name = '",sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " and ti.parent_entity_id between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," union ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " si.parent_entity_id from_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " si.parent_entity_name table_name,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(i_source_env_id,
            " env_source_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(sx_target_id,
            " env_target_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " si.parent_entity_id to_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," 3 status_flg,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,"sysdate updt_dt_tm")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(
            "  from dm_refchg_invalid_xlat",sx_db_link," si "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " where si.parent_entity_name = '",sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " and si.parent_entity_id between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select from_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , from_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,"  from dm_merge_translate")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " where table_name  = '",sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(i_source_env_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and from_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , to_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,"  from dm_merge_translate")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(i_source_env_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and to_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select from_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , from_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("  from ",sx_dmt_s))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(sx_target_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and from_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , to_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("  from ",sx_dmt_s))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(sx_target_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and to_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" ) where rownum <= ",
            cnvtstring(sx_insert_limit),")^) go "))
          EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","SX_REQUEST"), replace("REPLY",
           "SX_REPLY")
          IF ((sx_reply->row_count < sx_insert_limit))
           SET sx_continue_ind = 1
          ENDIF
          IF (check_error("Inserting translations into dm_merge_translate") != 0)
           SET dm_err->err_ind = 1
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ROLLBACK
           RETURN("F")
          ELSE
           COMMIT
          ENDIF
        ENDWHILE
      ENDFOR
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
     AND di.info_name=sx_sequence_name
    WITH nocounter
   ;end select
   IF (check_error("Checking DONE2 sequence row") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    UPDATE  FROM dm_info
     SET info_domain = concat(trim(sx_seq_match_domain),"DONE2"), updt_task = 4310001
     WHERE info_domain=sx_seq_match_domain
      AND info_name=sx_sequence_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     INSERT  FROM dm_info di
      SET di.info_domain = sx_seq_match_domain, di.info_name = sx_sequence_name, di.info_number = 0,
       di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting 0 sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
     IF (sx_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain=sx_seq_match_domain
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
     IF (sx_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE app_task_backfill(i_atb_source_env_id)
   DECLARE atb_target_id = f8
   DECLARE atb_cur_env_id = f8
   DECLARE atb_mock_id = f8
   DECLARE atb_db_link = vc
   DECLARE atb_app_task_src = vc
   DECLARE atb_dmt_src = vc
   DECLARE atb_table_name = vc WITH constant("APPLICATION_TASK")
   DECLARE atb_insert_limit = i4 WITH constant(100000)
   DECLARE i_domain = vc
   DECLARE atb_next_seq = f8 WITH noconstant(0.0)
   DECLARE atb_app_task_col_cnt = i4 WITH noconstant(0)
   DECLARE atb_parser_cnt = i4 WITH noconstant(0)
   DECLARE atb_continue_ind = i2 WITH noconstant(1)
   DECLARE atb_sec_ret = vc WITH protect, noconstant("")
   DECLARE atb_asd2_ret = vc WITH protect, noconstant("")
   DECLARE atb_src_domain = vc WITH protect, noconstant("")
   DECLARE atb_seqmatch_domain = vc WITH protect, noconstant("")
   DECLARE atb_src_number = f8 WITH protect, noconstant(0.0)
   FREE RECORD atb_rs_parser
   RECORD atb_rs_parser(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD atb_rs_parser_reply
   RECORD atb_rs_parser_reply(
     1 row_count = i4
   )
   FREE RECORD atb_app_task_rs
   RECORD atb_app_task_rs(
     1 qual[*]
       2 notnull_ind = i4
       2 column_name = vc
   )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     atb_cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET atb_db_link = build("@MERGE",cnvtstring(i_atb_source_env_id),cnvtstring(atb_cur_env_id))
   SET atb_app_task_src = concat("APPLICATION_TASK",atb_db_link)
   SET atb_dmt_src = concat("DM_MERGE_TRANSLATE",atb_db_link)
   SET atb_target_id = drmmi_get_mock_id(atb_cur_env_id)
   IF (atb_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET i_domain = build("MERGE",cnvtstring(i_atb_source_env_id),cnvtstring(atb_target_id),
    "SEQMATCHDONE2")
   SET atb_src_domain = build("MERGE",cnvtstring(atb_target_id),cnvtstring(i_atb_source_env_id),
    "SEQMATCHDONE2")
   SET atb_seqmatch_domain = build("MERGE",cnvtstring(i_atb_source_env_id),cnvtstring(atb_target_id),
    "SEQMATCH")
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     atb_next_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = atb_table_name,
     dcla.text = "Backfill translations in custom ranges for table APPLICATION_TASK", dcla
     .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->updt_task,
     dcla.audit_dt_tm = sysdate
    WHERE dcla.dm_chg_log_audit_id=atb_next_seq
    WITH nocounter
   ;end update
   IF (check_error("Inserting DM_CHG_LOG_AUDIT row for APPLICATION_TASK") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = atb_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
      dcla.table_name = atb_table_name, dcla.text =
      "Backfill translations in custom ranges for table APPLICATION_TASK", dcla.updt_applctx =
      cnvtreal(currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
      dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
     WITH nocounter
    ;end insert
    IF (check_error("Inserting DM_CHG_LOG_AUDIT row for APPLICATION_TASK") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=i_domain
     AND di.info_name=atb_table_name
    WITH nocounter
   ;end select
   IF (check_error("Checking if DONE2 row exists for APPLICATION_TASK") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ELSEIF (curqual=0)
    SELECT INTO "NL:"
     FROM user_tab_columns ut,
      (parser(concat("user_tab_columns",atb_db_link)) utc)
     PLAN (ut
      WHERE ut.table_name=atb_table_name)
      JOIN (utc
      WHERE utc.table_name=atb_table_name
       AND utc.column_name=ut.column_name)
     DETAIL
      atb_app_task_col_cnt = (atb_app_task_col_cnt+ 1), stat = alterlist(atb_app_task_rs->qual,
       atb_app_task_col_cnt), atb_app_task_rs->qual[atb_app_task_col_cnt].column_name = trim(ut
       .column_name,3),
      atb_app_task_rs->qual[atb_app_task_col_cnt].notnull_ind = 0
     WITH nocounter
    ;end select
    IF (check_error("Gathering apptask columns that exist in source and target") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_user_notnull_cols unc,
      (dummyt dt  WITH seq = value(atb_app_task_col_cnt))
     PLAN (unc
      WHERE unc.table_name=atb_table_name)
      JOIN (dt
      WHERE (atb_app_task_rs->qual[dt.seq].column_name=unc.column_name))
     DETAIL
      atb_app_task_rs->qual[dt.seq].notnull_ind = 1
     WITH nocounter
    ;end select
    IF (check_error("Gathering not nullible columns on apptask") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM (parser(concat("dm_info",atb_db_link)) di)
     WHERE di.info_domain=atb_src_domain
      AND di.info_name=atb_table_name
     DETAIL
      atb_src_number = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Obtaining sequence match value") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual > 0)
     INSERT  FROM dm_info di
      SET di.info_domain = i_domain, di.info_name = atb_table_name, di.updt_task = 4310001,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.info_number = atb_src_number
      WITH nocounter
     ;end insert
     IF (check_error("Updating sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = 0, di.updt_task = 4310001, di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=atb_seqmatch_domain
       AND di.info_name=atb_table_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_number = 0, di.updt_task = 4310001, di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        di.info_domain = atb_seqmatch_domain, di.info_name = atb_table_name
       WITH nocounter
      ;end insert
      IF (check_error("Updating sequence row in dm_info") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_atb_source_env_id,atb_cur_env_id,atb_table_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
    SET stat = alterlist(atb_rs_parser->stmt,8)
    SET atb_rs_parser->stmt[1].str = " rdb insert into dm_merge_translate dmt"
    SET atb_rs_parser->stmt[2].str =
    " (dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, "
    SET atb_rs_parser->stmt[3].str = "  dmt.status_flg, dmt.updt_dt_tm) "
    SET atb_rs_parser->stmt[4].str = build(' (select at.task_number, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_rs_parser->stmt[5].str = build(atb_target_id,", at.task_number, 3, sysdate")
    SET atb_rs_parser->stmt[6].str = concat("from application_task at, ",atb_app_task_src," ats")
    SET atb_rs_parser->stmt[7].str = "where ((at.task_number between 113000 and 113999) "
    SET atb_rs_parser->stmt[8].str = "or (at.task_number between 117000 and 118999)) and "
    SET atb_parser_cnt = 8
    FOR (i = 1 TO size(atb_app_task_rs->qual,5))
      SET atb_parser_cnt = (atb_parser_cnt+ 1)
      SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
      IF ((atb_app_task_rs->qual[i].notnull_ind=0))
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("((at.",atb_app_task_rs->qual[i].
        column_name," = ats.",atb_app_task_rs->qual[i].column_name,")")
       SET atb_parser_cnt = (atb_parser_cnt+ 1)
       SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(" or (at.",atb_app_task_rs->qual[i].
        column_name," is NULL and ats.",atb_app_task_rs->qual[i].column_name," is NULL))")
      ELSE
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("at.",atb_app_task_rs->qual[i].
        column_name," = ats.",atb_app_task_rs->qual[i].column_name)
      ENDIF
      IF (i < size(atb_app_task_rs->qual,5))
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(atb_rs_parser->stmt[atb_parser_cnt].str,
        " and ")
      ENDIF
    ENDFOR
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select from_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,
     ", from_value, 3, sysdate")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     'from dm_merge_translate where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     " and ((from_value >= 113000 and from_value <= 113999) ","or (from_value >= 117000 and ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " from_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select to_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,", to_value, 3, sysdate"
     )
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     'from dm_merge_translate where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str =
    " and ((to_value >= 113000 and to_value <= 113999) or (to_value >= 117000 and "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " to_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select from_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,
     ", from_value, 3, sysdate")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("from dm_merge_translate",atb_db_link,
     ' where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     " and ((from_value >= 113000 and from_value <= 113999) ","or (from_value >= 117000 and ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " from_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select to_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,", to_value, 3, sysdate"
     )
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("from dm_merge_translate",atb_db_link,
     ' where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str =
    " and ((to_value >= 113000 and to_value <= 113999) or (to_value >= 117000 and "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " to_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = ") go"
    WHILE (atb_continue_ind=1)
      EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","ATB_RS_PARSER"), replace("REPLY",
       "ATB_RS_PARSER_REPLY")
      IF ((atb_rs_parser_reply->row_count < atb_insert_limit))
       SET atb_continue_ind = 0
      ELSE
       SET atb_continue_ind = 1
      ENDIF
      IF (check_error("Error during APPLICATION_TASK translation backfill") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
    ENDWHILE
    INSERT  FROM dm_info di
     SET di.info_domain = i_domain, di.info_name = "APPLICATION_TASK", di.info_number = 0,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("app__task_backfill - Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     SET atb_sec_ret = seqmatch_event_chk(i_atb_source_env_id,atb_cur_env_id,"APPLICATION_TASK")
     IF (atb_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET atb_asd2_ret = add_src_done_2(i_atb_source_env_id,atb_cur_env_id,atb_target_id,
      "APPLICATION_TASK")
     IF (atb_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ELSEIF (curqual > 0)
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE seqmatch_event_chk(i_source_id,i_target_id,i_sequence_name)
   DECLARE sec_link_name = vc WITH protect, noconstant("")
   DECLARE sec_done_ind = i2 WITH protect, noconstant(0)
   DECLARE sec_drel_row = f8 WITH protect, noconstant(0.0)
   DECLARE sec_drel_value = i4 WITH protect, noconstant(0)
   IF (validate(sec_lck_reply->status,"X")="X")
    FREE RECORD sec_lck_reply
    RECORD sec_lck_reply(
      1 status = c1
      1 status_msg = vc
    )
   ENDIF
   IF ((validate(sx_seq->cnt,- (9999)) != - (9999)))
    SET sec_drel_value = sx_seq->cnt
   ENDIF
   SET sec_lck_reply->status = "Z"
   SET sec_link_name = build(cnvtstring(i_source_id,20),cnvtstring(i_target_id,20))
   WHILE (sec_done_ind=0)
     SELECT INTO "nl:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
       AND drel.cur_environment_id=i_target_id
       AND drel.paired_environment_id=i_source_id
       AND  EXISTS (
      (SELECT
       "x"
       FROM dm_rdds_event_detail dred
       WHERE dred.dm_rdds_event_log_id=drel.dm_rdds_event_log_id
        AND dred.event_detail1_txt=i_sequence_name))
      DETAIL
       sec_drel_row = drel.dm_rdds_event_log_id
      WITH nocounter
     ;end select
     IF (check_error("Determining if Translation Backfill event row exists") != 0)
      RETURN("F")
     ENDIF
     IF (sec_drel_row=0)
      SELECT INTO "nl:"
       FROM dm_rdds_event_log drel
       WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
        AND drel.cur_environment_id=i_target_id
        AND drel.paired_environment_id=i_source_id
       DETAIL
        sec_drel_row = drel.dm_rdds_event_log_id
       WITH nocounter, maxqual(drel,1)
      ;end select
      IF (check_error("Determining if Translation Backfill event row exists") != 0)
       RETURN("F")
      ENDIF
     ENDIF
     IF (sec_drel_row > 0)
      UPDATE  FROM dm_rdds_event_detail dred
       SET dred.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE dred.dm_rdds_event_log_id=sec_drel_row
        AND dred.event_detail1_txt=i_sequence_name
       WITH nocounter
      ;end update
      IF (check_error("Attempting to update event detail row") != 0)
       RETURN("F")
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_rdds_event_detail dred
        SET dred.dm_rdds_event_detail_id = seq(dm_seq,nextval), dred.dm_rdds_event_log_id =
         sec_drel_row, dred.event_detail1_txt = i_sequence_name,
         dred.event_detail_value = 0.0, dred.updt_applctx = reqinfo->updt_applctx, dred.updt_cnt = 0,
         dred.updt_dt_tm = cnvtdatetime(curdate,curtime3), dred.updt_id = reqinfo->updt_id, dred
         .updt_task = 4310001
        WITH nocounter
       ;end insert
       IF (check_error("Attempting to insert new event detail row") != 0)
        RETURN("F")
       ENDIF
      ENDIF
      COMMIT
      SET sec_done_ind = 1
     ELSE
      CALL get_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",0,sec_lck_reply)
      IF ((sec_lck_reply->status="F"))
       SET dm_err->emsg = "Error while obtaining lock"
       RETURN("F")
      ELSEIF ((sec_lck_reply->status="S"))
       COMMIT
       SET stat = alterlist(auto_ver_request->qual,1)
       IF (sec_drel_value > 0)
        SET auto_ver_request->qual[1].event_reason = cnvtstring(sec_drel_value)
       ELSE
        SET auto_ver_request->qual[1].event_reason = ""
       ENDIF
       SET auto_ver_request->qual[1].rdds_event = "Translation Backfill Finished"
       SET auto_ver_request->qual[1].cur_environment_id = i_target_id
       SET auto_ver_request->qual[1].paired_environment_id = i_source_id
       SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
       SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = i_sequence_name
       SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
       EXECUTE dm_rmc_auto_verify_setup
       IF ((auto_ver_reply->status="F"))
        SET dm_err->emsg = "Error while writing event row for Translation Backfill"
        CALL remove_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",
         currdbhandle,sec_lck_reply)
        IF ((sec_lck_reply->status="F"))
         SET dm_err->emsg = "Error while releasing lock"
        ENDIF
        RETURN("F")
       ENDIF
       CALL remove_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",currdbhandle,
        sec_lck_reply)
       IF ((sec_lck_reply->status="F"))
        SET dm_err->emsg = "Error while releasing lock"
        RETURN("F")
       ENDIF
       COMMIT
       SET sec_done_ind = 1
      ELSEIF ((sec_lck_reply->status="Z"))
       CALL pause(10)
      ENDIF
     ENDIF
   ENDWHILE
   RETURN("S")
 END ;Subroutine
 SUBROUTINE add_src_done_2(i_src_id,i_tgt_id,i_tgt_mock_id,i_sequence)
   DECLARE asd_merge_link = vc WITH protect, noconstant("")
   DECLARE asd_domain = vc WITH protect, noconstant("")
   DECLARE asd_sec_ret = vc WITH protect, noconstant("")
   DECLARE asd_targ_nbr = f8 WITH protect, noconstant(0.0)
   DECLARE asd_src_domain = vc WITH protect, noconstant("")
   SET asd_merge_link = build("@MERGE",cnvtstring(i_src_id,20),cnvtstring(i_tgt_id,20))
   SET asd_domain = build("MERGE",cnvtstring(i_tgt_mock_id,20),cnvtstring(i_src_id,20),"SEQMATCH")
   SET asd_src_domain = build("MERGE",cnvtstring(i_src_id,20),cnvtstring(i_tgt_mock_id,20),"SEQMATCH"
    )
   IF (i_tgt_id != i_tgt_mock_id)
    RETURN("S")
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",asd_merge_link)) di)
    WHERE di.info_domain=concat(trim(asd_domain),"DONE2")
     AND info_name=i_sequence
    WITH nocounter
   ;end select
   IF (check_error("Obtaining done2 row from target") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    RETURN("S")
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=asd_src_domain
     AND di.info_name=i_sequence
    DETAIL
     asd_targ_nbr = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value from target") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   INSERT  FROM (parser(concat("dm_info",asd_merge_link)) di)
    SET di.info_domain = concat(trim(asd_domain),"DONE2"), di.info_number = asd_targ_nbr, di
     .updt_task = 4310001,
     di.info_name = i_sequence
    WITH nocounter
   ;end insert
   IF (check_error("Updating sequence row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",asd_merge_link)) di)
    WHERE di.info_domain=asd_domain
     AND di.info_name=i_sequence
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM (parser(concat("dm_info",asd_merge_link)) di)
     SET di.info_number = 0, di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=asd_domain
      AND di.info_name=i_sequence
     WITH nocounter
    ;end update
    IF (check_error("Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSE
    INSERT  FROM (parser(concat("dm_info",asd_merge_link)) di)
     SET di.info_number = 0, di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx,
      di.info_domain = asd_domain, di.info_name = i_sequence
     WITH nocounter
    ;end insert
    IF (check_error("Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   COMMIT
   SET asd_sec_ret = seqmatch_event_chk(i_tgt_id,i_src_id,i_sequence)
   IF (asd_sec_ret="F")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 IF (check_logfile("dm_rmc_seqmatch_inc",".log","dm_rmc_seqmatch_inc LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (validate(dm_seqmatch_req->dsr_subroutine,"Z")="Z")
  FREE RECORD dm_seqmatch_req
  RECORD dm_seqmatch_req(
    1 dsr_subroutine = vc
    1 dsr_vc1 = vc
    1 dsr_vc2 = vc
    1 dsr_vc3 = vc
    1 dsr_vc4 = vc
    1 dsr_f81 = f8
    1 dsr_f82 = f8
    1 dsr_f83 = f8
    1 dsr_f84 = f8
  )
  FREE RECORD dm_seqmatch_reply
  RECORD dm_seqmatch_reply(
    1 dsr_reply_vc = vc
    1 dsr_reply_f8 = f8
  )
 ENDIF
 CALL echo("Inside dummy prg file...")
 CALL echo(concat("Case statement ",dm_seqmatch_req->dsr_subroutine))
 CASE (cnvtupper(dm_seqmatch_req->dsr_subroutine))
  OF "SEQMATCH_EVENT_CHK":
   CALL echo("Inside dummy prg file SEQMATCH_EVENT_CHK stmt...")
   SET dm_seqmatch_reply->dsr_reply_vc = seqmatch_event_chk(dm_seqmatch_req->dsr_f81,dm_seqmatch_req
    ->dsr_f82,dm_seqmatch_req->dsr_vc1)
  OF "ADD_SRC_DONE_2":
   CALL echo("Inside dummy prg file ADD_SRC_DONE_2 stmt...")
   SET dm_seqmatch_reply->dsr_reply_vc = add_src_done_2(dm_seqmatch_req->dsr_f81,dm_seqmatch_req->
    dsr_f82,dm_seqmatch_req->dsr_f83,dm_seqmatch_req->dsr_vc1)
  OF "APP_TASK_BACKFILL":
   CALL echo("Inside dummy prg file APP_TASK_BACKFILL stmt...")
   SET dm_seqmatch_reply->dsr_reply_vc = app_task_backfill(dm_seqmatch_req->dsr_f81)
  OF "SEQMATCH_XLATS":
   CALL echo("Inside dummy prg file SEQMATCH_XLATS stmt...")
   SET dm_seqmatch_reply->dsr_reply_vc = seqmatch_xlats(dm_seqmatch_req->dsr_vc1,dm_seqmatch_req->
    dsr_f81,dm_seqmatch_req->dsr_vc2)
 ENDCASE
#exit_program
END GO
