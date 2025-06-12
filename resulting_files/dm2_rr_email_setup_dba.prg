CREATE PROGRAM dm2_rr_email_setup:dba
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
 DECLARE drer_email_setup(des_src_env=vc,des_tgt_env=vc) = i2
 DECLARE drer_fill_email_list(dfel_src_env=vc,dfel_tgt_env=vc) = i2
 DECLARE drer_compose_email(null) = i2
 DECLARE drer_send_email(dse_subject=vc,dse_file_name=vc,dse_level=i4) = i2
 DECLARE drer_send_test_emails(dste_level=i4) = i2
 DECLARE drer_add_body_text(dabt_in_text=vc,dabt_in_reset_ind=i2) = null
 DECLARE drer_reset_pre_err(null) = null
 DECLARE drer_get_client(null) = i2
 DECLARE drer_redhat_version(null) = i2
 IF ((validate(drer_email_list->level_cnt,- (99))=- (99))
  AND validate(drer_email_list->level_cnt,99)=99)
  FREE RECORD drer_email_list
  RECORD drer_email_list(
    1 max_email_level = i4
    1 email_cnt = i4
    1 change_ind = i2
    1 email[*]
      2 address = vc
      2 level = i4
    1 level_cnt = i4
    1 email_level[*]
      2 level = i4
      2 email_list = vc
  )
  SET drer_email_list->max_email_level = 2
 ENDIF
 IF ((validate(drer_email_det->email_level,- (99))=- (99))
  AND validate(drer_email_det->email_level,99)=99)
  FREE RECORD drer_email_det
  RECORD drer_email_det(
    1 subject = vc
    1 process = vc
    1 msgtype = vc
    1 status = vc
    1 status_dt_tm = f8
    1 client = vc
    1 src_env = vc
    1 src_node = vc
    1 tgt_env = vc
    1 tgt_node = vc
    1 step = vc
    1 email_level = i4
    1 file_name = vc
    1 component_name = vc
    1 eproc = vc
    1 err_ind = i2
    1 emsg = vc
    1 user_action = vc
    1 logfile = vc
    1 restart_ind = i2
    1 body_cnt = i4
    1 body[*]
      2 txt = vc
    1 attachment = vc
  )
  SET drer_email_det->subject = "DM2NOTSET"
  SET drer_email_det->process = "DM2NOTSET"
  SET drer_email_det->msgtype = "DM2NOTSET"
  SET drer_email_det->status = "DM2NOTSET"
  SET drer_email_det->client = "DM2NOTSET"
  SET drer_email_det->src_env = "DM2NOTSET"
  SET drer_email_det->src_node = "DM2NOTSET"
  SET drer_email_det->tgt_env = "DM2NOTSET"
  SET drer_email_det->tgt_node = "DM2NOTSET"
  SET drer_email_det->step = "DM2NOTSET"
  SET drer_email_det->file_name = "DM2NOTSET"
  SET drer_email_det->component_name = "DM2NOTSET"
  SET drer_email_det->eproc = "DM2NOTSET"
  SET drer_email_det->emsg = "DM2NOTSET"
  SET drer_email_det->user_action = "DM2NOTSET"
  SET drer_email_det->logfile = "DM2NOTSET"
  SET drer_email_det->attachment = "DM2NOTSET"
 ENDIF
 SUBROUTINE drer_email_setup(des_src_env,des_tgt_env)
   DECLARE des_iter = i4 WITH protect, noconstant(0)
   DECLARE des_index = i4 WITH protect, noconstant(0)
   DECLARE des_remove_location = i4 WITH protect, noconstant(0)
   DECLARE des_level = i4 WITH protect, noconstant(0)
   DECLARE des_working = i2 WITH protect, noconstant(0)
   DECLARE des_pre_max_level = i4 WITH protect, noconstant(0)
   DECLARE des_help_str = vc WITH protect, noconstant(" ")
   IF (drer_fill_email_list(des_src_env,des_tgt_env)=0)
    RETURN(0)
   ENDIF
   FOR (des_iter = 1 TO drer_email_list->max_email_level)
     IF ((des_iter=drer_email_list->max_email_level))
      SET des_help_str = concat(des_help_str,trim(cnvtstring(des_iter)))
     ELSE
      SET des_help_str = concat(des_help_str,trim(cnvtstring(des_iter)),",")
     ENDIF
   ENDFOR
   WHILE (true)
     SET width = 132
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Setup Email Addresses")
     IF ((drer_email_list->email_cnt > 0))
      CALL text(4,4,"EMAIL ADDRESS")
      CALL text(4,80,"EMAIL LEVEL")
      FOR (des_index = 1 TO least(15,drer_email_list->email_cnt))
       CALL text((5+ des_index),4,concat(build(des_index),".  ",drer_email_list->email[des_index].
         address))
       CALL text((5+ des_index),80,trim(cnvtstring(drer_email_list->email[des_index].level)))
      ENDFOR
     ENDIF
     CALL clear(23,2,129)
     IF ((drer_email_list->email_cnt=0))
      CALL text(23,2,"(A)dd new email address, (S)ave, (Q)uit: ")
      CALL accept(23,80,"A;CU"," "
       WHERE curaccept IN ("A", "S", "Q"))
     ELSEIF ((drer_email_list->email_cnt < 15))
      IF ((drer_email_list->change_ind=0))
       CALL text(23,2,concat("(A)dd new email address, (R)emove existing email address, (S)ave,",
         " (T)est email addresses, (Q)uit: "))
       CALL accept(23,124,"A;CU"," "
        WHERE curaccept IN ("A", "R", "S", "T", "Q"))
      ELSE
       CALL text(23,2,concat("(A)dd new email address, (R)emove existing email address, (S)ave,",
         " (Q)uit: "))
       CALL accept(23,124,"A;CU"," "
        WHERE curaccept IN ("A", "R", "S", "Q"))
      ENDIF
     ELSE
      IF ((drer_email_list->change_ind=0))
       CALL text(23,2,"(R)emove existing email address, (S)ave, (T)est email addresses, (Q)uit: ")
       CALL accept(23,99,"A;CU"," "
        WHERE curaccept IN ("R", "S", "T", "Q"))
      ELSE
       CALL text(23,2,"(R)emove existing email address, (S)ave, (Q)uit: ")
       CALL accept(23,99,"A;CU"," "
        WHERE curaccept IN ("R", "S", "Q"))
      ENDIF
     ENDIF
     CASE (curaccept)
      OF "A":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Add:")
       CALL accept(21,24,"P(80);CHU","NONE"
        WHERE ((findstring("@",curaccept) > 0
         AND findstring(".",curaccept) > 0
         AND findstring("@",curaccept) < findstring(".",curaccept,1,1)) OR (curaccept="NONE")) )
       IF (curaccept != "NONE"
        AND locateval(des_index,1,drer_email_list->email_cnt,curaccept,drer_email_list->email[
        des_index].address)=0)
        SET drer_email_list->email_cnt = (drer_email_list->email_cnt+ 1)
        SET stat = alterlist(drer_email_list->email,drer_email_list->email_cnt)
        SET drer_email_list->email[drer_email_list->email_cnt].address = curaccept
        SET drer_email_list->change_ind = 1
       ENDIF
       CALL clear(22,2,129)
       CALL text(22,2,"Email level to Add:")
       SET help = fix(value(des_help_str))
       CALL accept(22,24,"99;F",0
        WHERE (curaccept < drer_email_list->max_email_level))
       SET drer_email_list->email[drer_email_list->email_cnt].level = curhelp
       CALL clear(21,2,129)
       CALL clear(22,2,129)
      OF "R":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Remove, by number:")
       CALL accept(21,38,"99;H",0
        WHERE curaccept BETWEEN 0 AND drer_email_list->email_cnt)
       SET des_remove_location = curaccept
       IF (des_remove_location > 0)
        FOR (des_iter = des_remove_location TO (drer_email_list->email_cnt - 1))
         SET drer_email_list->email[des_iter].address = drer_email_list->email[(des_iter+ 1)].address
         SET drer_email_list->email[des_iter].level = drer_email_list->email[(des_iter+ 1)].level
        ENDFOR
        SET stat = alterlist(drer_email_list->email,(drer_email_list->email_cnt - 1))
        SET drer_email_list->email_cnt = (drer_email_list->email_cnt - 1)
        SET drer_email_list->change_ind = 1
       ENDIF
       CALL clear(21,2,129)
      OF "S":
       IF ((dm_err->debug_flag=722))
        SET message = nowindow
       ENDIF
       IF ((drer_email_list->change_ind=1))
        SET dm_err->eproc = "Deleting existing email rows from dm2_admin_dm_info."
        DELETE  FROM dm2_admin_dm_info di
         WHERE di.info_domain=value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",
           cnvtupper(des_src_env),"_",
           cnvtupper(des_tgt_env)))
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF ((drer_email_list->email_cnt > 0))
         SET dm_err->eproc = "Inserting new email rows into dm2_admin_dm_info."
         INSERT  FROM dm2_admin_dm_info di,
           (dummyt d  WITH seq = value(drer_email_list->email_cnt))
          SET di.info_domain = value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",
             cnvtupper(des_src_env),"_",
             cnvtupper(des_tgt_env))), di.info_name = drer_email_list->email[d.seq].address, di
           .info_number = drer_email_list->email[d.seq].level
          PLAN (d)
           JOIN (di)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ENDIF
        COMMIT
       ENDIF
       IF (drer_fill_email_list(des_src_env,des_tgt_env)=0)
        RETURN(0)
       ENDIF
       IF ((drer_email_list->email_cnt > 0))
        CALL clear(23,2,129)
        CALL text(23,2,"Changes have been saved.  Would you like to send a test email (Y/N)?")
        CALL accept(23,70,"A;CU"," "
         WHERE curaccept IN ("Y", "N"))
        CASE (curaccept)
         OF "Y":
          IF (drer_send_test_emails(1)=0)
           RETURN(0)
          ENDIF
        ENDCASE
       ENDIF
      OF "T":
       IF (drer_send_test_emails(1)=0)
        RETURN(0)
       ENDIF
       CALL clear(21,2,129)
       CALL text(21,2,"A test email has been sent.  Press <enter> to continue.")
       CALL accept(21,58,"A;CH"," ")
       CALL clear(21,2,129)
      OF "Q":
       RETURN(1)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_fill_email_list(dfel_src_env,dfel_tgt_env)
   IF (validate(drrr_responsefile_in_use,0)=1)
    RETURN(1)
   ENDIF
   DECLARE dfel_table_name = vc WITH protect, noconstant("DM2NOTSET")
   IF (((dfel_src_env="DM2NOTSET") OR (dfel_tgt_env="DM2NOTSET")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Evaluate input parameters for subroutine drer_fill_email_list."
    SET dm_err->emsg = "Input parameter(s) is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drer_get_client(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE cnvtupper(ds.synonym_name)="DM2_ADMIN_DM_INFO"
     AND ds.owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dfel_table_name = "DM2_ADMIN_DM_INFO"
   ELSE
    SET dm_err->eproc = "ADMIN CONNECTION"
    CALL disp_msg("",dm_err->logfile,0)
    SET dm2_install_schema->dbase_name = "ADMIN"
    SET dm2_install_schema->u_name = "CDBA"
    IF ((dm2_install_schema->cdba_p_word="DM2NOTSET"))
     EXECUTE dm2_connect_to_dbase "PC"
    ELSE
     SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
    ENDIF
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dfel_table_name = "DM_INFO"
   ENDIF
   SET dm_err->eproc = concat("Querying for list of email addresses from ",dfel_table_name)
   SELECT INTO "nl:"
    FROM (parser(dfel_table_name) di)
    WHERE di.info_domain=value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",cnvtupper(
       dfel_src_env),"_",
      cnvtupper(dfel_tgt_env)))
    ORDER BY di.info_number, di.info_name
    HEAD REPORT
     level_cnt = 0, email_cnt = 0
    HEAD di.info_number
     level_cnt = (level_cnt+ 1), drer_email_list->level_cnt = level_cnt, stat = alterlist(
      drer_email_list->email_level,level_cnt),
     drer_email_list->email_level[level_cnt].level = di.info_number, drer_email_list->email_level[
     level_cnt].email_list = ""
    DETAIL
     email_cnt = (email_cnt+ 1), stat = alterlist(drer_email_list->email,email_cnt), drer_email_list
     ->email[email_cnt].address = di.info_name,
     drer_email_list->email[email_cnt].level = di.info_number
     IF ((drer_email_list->email_level[level_cnt].email_list=""))
      drer_email_list->email_level[level_cnt].email_list = di.info_name
     ELSE
      drer_email_list->email_level[level_cnt].email_list = concat(drer_email_list->email_level[
       level_cnt].email_list,",",di.info_name)
     ENDIF
     drer_email_list->email_cnt = email_cnt
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
    CALL echorecord(drer_email_list)
    SET message = window
   ENDIF
   IF (dfel_table_name="DM_INFO")
    IF ((((dm2_install_schema->target_dbase_name="DM2NOTSET")) OR ((dm2_install_schema->v500_p_word=
    "DM2NOTSET"))) )
     SET dm2_install_schema->dbase_name = '"TARGET"'
     SET dm2_install_schema->u_name = "V500"
     EXECUTE dm2_connect_to_dbase "PC"
    ELSE
     SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
    ENDIF
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_compose_email(null)
   DECLARE def_line = vc WITH protect, noconstant(" ")
   DECLARE def_cnt = i4 WITH protect, noconstant(0)
   IF ((drer_email_det->status="EXECUTING"))
    SET drer_email_det->msgtype = "PROGRESS"
    IF ((drer_email_det->restart_ind=0))
     SET def_line = concat(drer_email_det->step," started at ",format(drer_email_det->status_dt_tm,
       ";;q"))
    ELSE
     SET def_line = concat(drer_email_det->step," restarted at ",format(drer_email_det->status_dt_tm,
       ";;q"))
    ENDIF
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    CALL drer_add_body_text(def_line,0)
   ELSEIF ((drer_email_det->status="COMPLETE"))
    SET drer_email_det->msgtype = "PROGRESS"
    SET def_line = concat(drer_email_det->step," completed at ",format(drer_email_det->status_dt_tm,
      ";;q"))
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    CALL drer_add_body_text(def_line,0)
   ELSEIF ((drer_email_det->status="FAILED"))
    SET drer_email_det->msgtype = "ACTIONREQ"
    SET def_line = concat("Component Name :",drer_email_det->component_name)
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Process Description :",drer_email_det->eproc)
    CALL drer_add_body_text(def_line,0)
    SET def_line = concat("Error Message :",drer_email_det->emsg)
    CALL drer_add_body_text(def_line,0)
    IF ((drer_email_det->user_action > "")
     AND (drer_email_det->user_action != "DM2NOTSET")
     AND (drer_email_det->user_action != "NONE"))
     SET def_line = concat("User Action :",drer_email_det->user_action)
     CALL drer_add_body_text(def_line,0)
    ENDIF
    IF (findstring("/",drer_email_det->logfile)=0)
     SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    ELSE
     SET def_line = concat("Log file name is : ",drer_email_det->logfile)
    ENDIF
    CALL drer_add_body_text(def_line,0)
   ENDIF
   SET drer_email_det->subject = concat("PROCESS: ",evaluate(drer_email_det->process,"DM2NOTSET",
     "N/A",trim(drer_email_det->process)),", MSGTYPE: ",evaluate(drer_email_det->msgtype,"DM2NOTSET",
     "N/A",trim(drer_email_det->msgtype)),", STATUS: ",
    evaluate(drer_email_det->status,"DM2NOTSET","N/A",trim(drer_email_det->status)),", CLIENT: ",
    evaluate(drer_email_det->client,"DM2NOTSET","N/A",trim(drer_email_det->client)))
   IF (get_unique_file("dm2_rr_email",".dat")=0)
    RETURN(0)
   ENDIF
   SET drer_email_det->file_name = dm_err->unique_fname
   SET dm_err->eproc = concat("Generate file ",drer_email_det->file_name)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(drer_email_det->file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     def_line = concat("SRC_ENV/SRC_NODE:",evaluate(drer_email_det->src_env,"DM2NOTSET","N/A",trim(
        drer_email_det->src_env)),"/",evaluate(drer_email_det->src_node,"DM2NOTSET","N/A",trim(
        drer_email_det->src_node)),", TGT_ENV/TGT_NODE:",
      evaluate(drer_email_det->tgt_env,"DM2NOTSET","N/A",trim(drer_email_det->tgt_env)),"/",evaluate(
       drer_email_det->tgt_node,"DM2NOTSET","N/A",trim(drer_email_det->tgt_node)),", STEP: ",evaluate
      (drer_email_det->step,"DM2NOTSET","N/A",trim(drer_email_det->step)),
      ", EMAIL DT/TM: ",format(cnvtdatetime(curdate,curtime3),";;q")),
     CALL print(def_line), row + 1,
     row + 2
     FOR (def_cnt = 1 TO drer_email_det->body_cnt)
      CALL print(drer_email_det->body[def_cnt].txt),row + 2
     ENDFOR
    WITH nocounter, maxcol = 2000, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_send_email(dse_subject,dse_file_name,dse_level)
   DECLARE dse_iter = i4 WITH protect, noconstant(0)
   DECLARE dse_idx = i4 WITH protect, noconstant(0)
   DECLARE dse_file = vc WITH protect, noconstant("")
   DECLARE dse_lnx_version = f8 WITH protect, noconstant(0)
   IF (((trim(dse_subject)="DM2NOTSET") OR (trim(dse_file_name)="DM2NOTSET")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters <Subject, File Name> can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dse_level > drer_email_list->max_email_level))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameter email level is not valid."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   WHILE (dse_idx=0)
    SET dse_idx = locateval(dse_idx,1,drer_email_list->level_cnt,dse_level,drer_email_list->
     email_level[dse_idx].level)
    IF (dse_idx=0
     AND (dse_level < drer_email_list->max_email_level))
     SET dse_level = (dse_level+ 1)
    ELSEIF (dse_idx=0
     AND (dse_level=drer_email_list->max_email_level))
     RETURN(1)
    ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
    CALL echo(build("dse_idx = ",dse_idx))
   ENDIF
   IF (((dse_idx <= 0) OR ((dse_idx > drer_email_list->level_cnt))) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameter dse_level is invalid"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((drer_email_list->email_level[dse_idx].email_list=""))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Email list can not be blank"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dse_iter = dse_idx TO drer_email_list->level_cnt)
    IF ((drer_email_det->attachment != "DM2NOTSET")
     AND (dm2_sys_misc->cur_os IN ("AIX", "LNX", "HPX")))
     SET dse_file = replace(drer_email_det->attachment,".","w.",2)
     IF (dm2_push_dcl(concat(^sed 's/$'"/`echo \\^,'\\\r`/"'," ",drer_email_det->attachment," > ",
       dse_file))=0)
      SET dm_err->err_ind = 0
      SET dse_file = drer_email_det->attachment
     ENDIF
     SET drer_email_det->attachment = "DM2NOTSET"
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     IF (dm2_push_dcl(concat('MAIL/SUBJECT="',build(dse_subject),'" ',build(dse_file_name),' "',
       build(drer_email_list->email_level[dse_iter].email_list),'"'))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="LNX"))
     IF (dse_file != "")
      SET dse_lnx_version = drer_redhat_version(null)
      IF (dse_lnx_version >= 6)
       IF (dm2_push_dcl(concat("cat ",dse_file_name,' | mail -s "',dse_subject,'" -a ',
         dse_file,' "',drer_email_list->email_level[dse_iter].email_list,'"'))=0)
        RETURN(0)
       ENDIF
      ELSE
       IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
         dse_file,'`) | mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].
         email_list,
         '"'))=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter]
       .email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="AIX"))
     IF (dse_file != "")
      IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
        dse_file,'`) | mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].email_list,
        '"'))=0)
       RETURN(0)
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter]
       .email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="HPX"))
     IF (dse_file != "")
      IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
        dse_file,'`) | mailx -m -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].
        email_list,
        '"'))=0)
       RETURN(0)
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mailx -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter
       ].email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_send_test_emails(dste_level)
   DECLARE dste_test_file_name = vc WITH protect, noconstant("")
   DECLARE dste_iter = i4 WITH protect, noconstant(0)
   DECLARE dste_email_list = vc WITH protect, noconstant("")
   SET dste_test_file_name = build(logical("CCLUSERDIR"),evaluate(dm2_sys_misc->cur_os,"AXP",
     "dm2_email_test.txt","/dm2_email_test.txt"))
   SET dm_err->eproc = "Attempting to create a test file to be emailed."
   SELECT INTO value(dste_test_file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test email"
    WITH nocounter, maxcol = 100, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(drer_send_email("Test email",dste_test_file_name,dste_level))
 END ;Subroutine
 SUBROUTINE drer_add_body_text(dabt_in_text,dabt_in_reset_ind)
   IF (dabt_in_reset_ind=1)
    SET drer_email_det->body_cnt = 1
    SET stat = alterlist(drer_email_det->body,1)
    SET drer_email_det->body[drer_email_det->body_cnt].txt = dabt_in_text
   ELSE
    SET drer_email_det->body_cnt = (drer_email_det->body_cnt+ 1)
    SET stat = alterlist(drer_email_det->body,drer_email_det->body_cnt)
    SET drer_email_det->body[drer_email_det->body_cnt].txt = dabt_in_text
   ENDIF
 END ;Subroutine
 SUBROUTINE drer_reset_pre_err(null)
   SET dm_err->err_ind = drer_email_det->err_ind
   SET dm_err->emsg = drer_email_det->emsg
   SET dm_err->eproc = drer_email_det->eproc
   SET dm_err->user_action = drer_email_det->user_action
 END ;Subroutine
 SUBROUTINE drer_get_client(null)
   SET dm_err->eproc = "Get Client Mnemonic."
   CALL disp_msg("",dm_err->logfile,0)
   SET drer_email_det->client = cnvtupper(logical("client_mnemonic"))
   IF ((((drer_email_det->client="DM2NOTSET")) OR ((drer_email_det->client=""))) )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      drer_email_det->client = trim(cnvtupper(d.info_char))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_redhat_version(null)
   DECLARE drv_lnx_ver_temp = vc WITH protect, constant(build2("dm2_os_ver_",cnvtdatetime(curdate,
      curtime3),".dat"))
   DECLARE drv_cmd_lnx_ver = vc WITH protect, constant(build2("cat /etc/redhat-release >> ",trim(
      drv_lnx_ver_temp,3)))
   DECLARE drv_cmd_length = i4 WITH protect, noconstant(textlen(drv_cmd_lnx_ver))
   DECLARE drv_status = i4 WITH protect, noconstant(0)
   DECLARE drv_version = vc WITH protect, noconstant("")
   DECLARE drv_dcl_output = vc WITH protect, noconstant("")
   DECLARE drv_return_value = f8 WITH protect, noconstant(0)
   DECLARE drv_continue = i2 WITH protect, noconstant(true)
   DECLARE drv_iwknt = i4 WITH protect, noconstant(1)
   SET stat = remove(drv_lnx_ver_temp)
   CALL dcl(drv_cmd_lnx_ver,drv_cmd_length,drv_status)
   FREE DEFINE rtl
   DEFINE rtl drv_lnx_ver_temp
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     drv_dcl_output = cnvtupper(trim(r.line,3))
    WITH nocounter
   ;end select
   SET stat = remove(drv_lnx_ver_temp)
   SET drv_version = substring((findstring("RELEASE",drv_dcl_output)+ 8),1,drv_dcl_output)
   IF (isnumeric(drv_version)=1)
    WHILE (drv_continue
     AND drv_iwknt < 4)
     SET drv_iwknt = (drv_iwknt+ 1)
     IF (isnumeric(substring(((findstring("RELEASE",drv_dcl_output)+ 8)+ drv_iwknt),1,drv_dcl_output)
      )=1)
      IF (drv_iwknt=2)
       SET drv_version = concat(trim(drv_version,3),".",substring(((findstring("RELEASE",
          drv_dcl_output)+ 8)+ drv_iwknt),1,drv_dcl_output))
      ELSE
       SET drv_version = concat(trim(drv_version,3),substring(((findstring("RELEASE",drv_dcl_output)
         + 8)+ drv_iwknt),1,drv_dcl_output))
      ENDIF
     ELSE
      SET drv_continue = false
     ENDIF
    ENDWHILE
    IF (isnumeric(drv_version) > 0)
     SET drv_return_value = cnvtreal(drv_version)
    ENDIF
   ENDIF
   CALL echo(build("RHEL Version = ",drv_return_value))
   RETURN(drv_return_value)
 END ;Subroutine
 IF (check_logfile("dm2_rr_email_setup",".log","dm2_rr_email_setup LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning dm2_rr_email_setup"
 CALL disp_msg("",dm_err->logfile,0)
 SET dm2_install_schema->dbase_name = '"SOURCE"'
 SET dm2_install_schema->u_name = "V500"
 EXECUTE dm2_connect_to_dbase "PC"
 IF ((dm_err->err_ind=1))
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Get source environment_name."
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d,
   dm_environment de
  PLAN (d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="DM_ENV_ID")
   JOIN (de
   WHERE d.info_number=de.environment_id)
  DETAIL
   drer_email_det->src_env = cnvtupper(de.environment_name)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET message = window
 CALL clear(1,1)
 CALL text(2,8,"Please enter the TARGET environment name: ")
 CALL accept(2,50,"P(20);CU"
  WHERE  NOT (curaccept=" "))
 SET drer_email_det->tgt_env = curaccept
 IF (drer_email_setup(drer_email_det->src_env,drer_email_det->tgt_env)=0)
  GO TO exit_script
 ENDIF
#exit_script
 SET message = nowindow
 CALL clear(1,1)
 IF ((dm_err->debug_flag=722))
  CALL echorecord(drer_email_list)
 ENDIF
 IF ((dm_err->err_ind=1))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ELSE
  SET dm_err->eproc = "dm2_rr_email_setup completed successfully."
 ENDIF
 CALL final_disp_msg("dm2_rr_email_setup")
END GO
