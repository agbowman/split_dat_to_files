CREATE PROGRAM dm2_diag_chg_log_triggers:dba
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
 DECLARE dm2_get_env_data(dged_use_admin_ind=i2,dged_environment_id=f8(ref)) = i2
 SUBROUTINE dm2_get_env_data(dged_use_admin_ind,dged_environment_id)
   DECLARE dged_local_env_id = f8 WITH protect, noconstant(0.0)
   IF ( NOT (dged_use_admin_ind IN (1, 0)))
    SET dged_use_admin_ind = 0
   ENDIF
   SET dm_err->eproc = "Retrieving environment id."
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dged_use_admin_ind=0)
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
    ELSE
     FROM dm_info d,
      dm_environment de
     PLAN (d
      WHERE d.info_domain="DATA MANAGEMENT"
       AND d.info_name="DM_ENV_ID")
      JOIN (de
      WHERE d.info_number=de.environment_id)
    ENDIF
    INTO "nl:"
    DETAIL
     dged_local_env_id = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = "Unable to retrieve environment data."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSE
    SET dged_environment_id = dged_local_env_id
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_get_dbase_name(dgdn_name_out=vc(ref)) = i2
 SUBROUTINE dm2_get_dbase_name(dgdn_name_out)
   SET dm_err->eproc = "Get database name from currdbname."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (validate(currdbhandle," ")=" ")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "currdbhandle is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (validate(currdbname," ") != " ")
     SET dgdn_name_out = currdbname
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "currdbname is not set."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("dgdn_name_out =",dgdn_name_out))
   ENDIF
   RETURN(1)
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
 DECLARE dm2ceil(dc_numin) = null
 DECLARE dm2floor(dc_numin) = null
 SUBROUTINE dm2ceil(dc_numin)
   SET dc_numin_save = dc_numin
   DECLARE dc_numin_vc = vc WITH noconstant("")
   DECLARE dc_numin_precision = i4 WITH noconstant(0)
   DECLARE dc_numin_decpos = i2 WITH noconstant(0)
   DECLARE dc_numin_whole = f8 WITH protect, noconstant(0.0)
   SET dc_numin_vc = cnvtstring(dc_numin_save,30,9,"R")
   SET dc_numin_decpos = findstring(".",dc_numin_vc)
   SET dc_numin_whole = cnvtreal(substring(1,(dc_numin_decpos - 1),dc_numin_vc))
   IF (dc_numin_decpos <= 0)
    RETURN(dc_numin)
   ELSE
    SET dc_numin_precision = cnvtint(substring((dc_numin_decpos+ 1),9,dc_numin_vc))
    IF (dc_numin_precision > 0)
     IF (dc_numin < 0)
      SET dc_numin_save = dc_numin_whole
     ELSE
      SET dc_numin_save = (dc_numin_whole+ 1)
     ENDIF
    ELSE
     SET dc_numin_save = dc_numin_whole
    ENDIF
    RETURN(dc_numin_save)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2floor(dc_numin)
   SET dc_numin_save = dc_numin
   DECLARE dc_numin_vc = vc WITH noconstant("")
   DECLARE dc_numin_precision = i4 WITH noconstant(0)
   DECLARE dc_numin_decpos = i2 WITH noconstant(0)
   DECLARE dc_numin_whole = f8 WITH protect, noconstant(0.0)
   SET dc_numin_vc = cnvtstring(dc_numin_save,30,9,"R")
   SET dc_numin_decpos = findstring(".",dc_numin_vc)
   SET dc_numin_whole = cnvtreal(substring(1,(dc_numin_decpos - 1),dc_numin_vc))
   IF (dc_numin_decpos <= 0)
    RETURN(dc_numin)
   ELSE
    SET dc_numin_precision = cnvtint(substring((dc_numin_decpos+ 1),9,dc_numin_vc))
    IF (dc_numin_precision > 0)
     IF (dc_numin < 0)
      SET dc_numin_save = (dc_numin_whole - 1)
     ELSE
      SET dc_numin_save = dc_numin_whole
     ENDIF
    ELSE
     SET dc_numin_save = dc_numin_whole
    ENDIF
    RETURN(dc_numin_save)
   ENDIF
 END ;Subroutine
 DECLARE val_user_privs(sbr_dummy_param=i2) = i2
 SUBROUTINE val_user_privs(sbr_dummy_param)
   SET dm_err->eproc = "Retrieving CCL user data from duaf."
   SELECT INTO "nl:"
    d.group
    FROM duaf d
    WHERE cnvtupper(d.user_name)=cnvtupper(curuser)
     AND d.group=0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0
    AND cnvtupper(curuser) != "P30INS")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user privileges"
    CALL disp_msg(concat("Current user, ",curuser,", does not have CCL DBA privileges required",
      " to run this program. Please contact your system administrator."),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_findfile(sbr_file_path=vc) = i2
 SUBROUTINE dm2_findfile(sbr_file_path)
   DECLARE dff_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dff_err_str = vc WITH protect, noconstant(" ")
   DECLARE dff_err_str2 = vc WITH protect, noconstant(" ")
   DECLARE dff_tmp_err_ind = i2 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL dm2_push_dcl(concat('@cer_install:dm2_findfile_os.com "',sbr_file_path,'"'))
    IF ((dm_err->err_ind=1))
     SET dm_err->err_ind = 0
     SET dff_tmp_err_ind = 1
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->errtext="NOT FOUND"))
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," not found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF ((dm_err->errtext="FOUND"))
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSEIF (((dff_tmp_err_ind=1) OR ( NOT ((dm_err->errtext IN ("FOUND", "NOT FOUND"))))) )
     SET dm_err->emsg = dm_err->errtext
     SET dm_err->eproc = "Error in DM2_FINDFILE"
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ELSE
    SET dff_cmd_txt = concat("test -e ",sbr_file_path,";echo $?")
    CALL dm2_push_dcl(dff_cmd_txt)
    SET dm_err->err_ind = 0
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (cnvtint(dm_err->errtext)=0)
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSE
     IF ((dm_err->debug_flag > 1))
      SET dm_err->eproc = concat("File ",sbr_file_path," not found.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_system_defs_init(sbr_sdi_regen_ind=i2) = i2
 SUBROUTINE dm2_system_defs_init(sbr_sdi_regen_ind)
   DECLARE sdi_def_cur_user = vc WITH protect, constant(cnvtupper(currdbuser))
   DECLARE sdi_def1_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def2_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def3_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def4_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def5_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue2_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue3_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_vue4_exists_ind = i2 WITH protect, noconstant(0)
   IF (checkdic("USER_VIEWS","T",0)=2)
    SET sdi_def1_exists_ind = 1
   ENDIF
   IF (checkdic("DM2_DBA_TAB_COLUMNS","T",0)=2)
    SET sdi_def2_exists_ind = 1
   ENDIF
   IF (checkdic("DM2_DBA_TAB_COLS","T",0)=2)
    SET sdi_def3_exists_ind = 1
   ENDIF
   IF (checkdic("DM2_USER_TAB_COLS","T",0)=2)
    SET sdi_def4_exists_ind = 1
   ENDIF
   IF (checkdic("PRODUCT_COMPONENT_VERSION","T",0)=2)
    SET sdi_def5_exists_ind = 1
   ENDIF
   IF (((sdi_def1_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_def1_exists_ind=1)
     DROP TABLE user_views
     IF (check_error("Dropping USER_VIEWS definition.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    DROP DDLRECORD user_views FROM DATABASE v500 WITH deps_deleted
    CREATE DDLRECORD user_views FROM DATABASE v500
 TABLE user_views
  1 view_name  = c30 CCL(view_name)
  1 text_length  = f8 CCL(text_length)
  1 text  = vc32000 CCL(text)
  1 type_text_length  = f8 CCL(type_text_length)
  1 type_text  = vc4000 CCL(type_text)
  1 oid_text_length  = f8 CCL(oid_text_length)
  1 oid_text  = vc4000 CCL(oid_text)
  1 view_type_owner  = c30 CCL(view_type_owner)
  1 view_type  = c30 CCL(view_type)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE user_views
    IF (check_error("Generating USER_VIEWS CCL definition.")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM user_views uv
    WHERE uv.view_name IN ("DM2_DBA_TAB_COLUMNS", "DM2_DBA_TAB_COLS", "DM2_USER_TAB_COLS")
    DETAIL
     CASE (uv.view_name)
      OF "DM2_DBA_TAB_COLUMNS":
       sdi_vue2_exists_ind = 1
      OF "DM2_DBA_TAB_COLS":
       sdi_vue3_exists_ind = 1
      OF "DM2_USER_TAB_COLS":
       sdi_vue4_exists_ind = 1
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error("Determining whether DM2_DBA_TAB_COLUMNS or DM2_DBA_TAB_COLS views already exist."
    )=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((sdi_vue2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_vue2_exists_ind=1)
     RDB drop view dm2_dba_tab_columns
     END ;Rdb
     IF (check_error("Dropping DM2_DBA_TAB_COLUMNS view.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    RDB asis ( "create view dm2_dba_tab_columns (" ) asis (
    "  OWNER,            TABLE_NAME,        COLUMN_NAME,      DATA_TYPE," ) asis (
    "  DATA_LENGTH,      DATA_PRECISION,    DATA_SCALE,       NULLABLE," ) asis (
    "  COLUMN_ID,        DEFAULT_LENGTH,    DATA_DEFAULT,     NUM_DISTINCT," ) asis (
    "  LOW_VALUE,        HIGH_VALUE,        DENSITY,          NUM_NULLS," ) asis (
    "  NUM_BUCKETS,      LAST_ANALYZED,     SAMPLE_SIZE,      LOGGED," ) asis (
    "  COMPACT,          IDENTITY_IND,      GENERATED" ) asis ( ") as select" ) asis (
    "  c.owner,          c.table_name,      c.column_name,    c.data_type," ) asis (
    "  c.data_length,    c.data_precision,  c.data_scale,     c.nullable," ) asis (
    "  c.column_id,      c.default_length,  c.data_default,   c.num_distinct," ) asis (
    "  c.low_value,      c.high_value,      c.density,        c.num_nulls," ) asis (
    "  c.num_buckets,    c.last_analyzed,   c.sample_size,    'N/A'," ) asis (
    "  'N/A',            'N/A',             'N/A'" ) asis ( "from dba_tab_columns c" ) asis (
    "union all" ) asis ( "select" ) asis (
    "  dc.owner,         ds.synonym_name,   dc.column_name,   dc.data_type," ) asis (
    "  dc.data_length,   dc.data_precision, dc.data_scale,    dc.nullable," ) asis (
    "  dc.column_id,     dc.default_length, dc.data_default,  dc.num_distinct," ) asis (
    "  dc.low_value,     dc.high_value,     dc.density,       dc.num_nulls," ) asis (
    "  dc.num_buckets,   dc.last_analyzed,  dc.sample_size,   'N/A'," ) asis (
    "  'N/A',            'N/A',             'N/A'" ) asis (
    "from dba_tab_columns dc, dba_synonyms ds" ) asis ( "where ds.table_name = dc.table_name" ) asis
    ( "  and ds.synonym_name != ds.table_name" ) asis ( "  and not exists " ) asis (
    "     (select c.synonym_name, count(*) " ) asis ( "          from dba_synonyms c " ) asis (
    "          where c.synonym_name = ds.synonym_name " ) asis ( "          group by c.synonym_name "
     ) asis ( "          having count(*) > 1) " )
    END ;Rdb
    IF (check_error("CREATING DM2_DBA_TAB_COLUMNS VIEW")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_def2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_def2_exists_ind=1)
     DROP TABLE dm2_dba_tab_columns
     IF (check_error("Dropping DM2_DBA_TAB_COLUMNS table def.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    DROP DDLRECORD dm2_dba_tab_columns FROM DATABASE v500 WITH deps_deleted
    CREATE DDLRECORD dm2_dba_tab_columns FROM DATABASE v500
 TABLE dm2_dba_tab_columns
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm2_dba_tab_columns
    IF (check_error("Creating DM2_DBA_TAB_COLUMNS table def.")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_vue3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_vue3_exists_ind=1)
     RDB drop view dm2_dba_tab_cols
     END ;Rdb
     IF (check_error("Dropping DM2_DBA_TAB_COLS view.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    RDB asis ( "create view dm2_dba_tab_cols (" ) asis (
    "  OWNER,            TABLE_NAME,        COLUMN_NAME,      DATA_TYPE," ) asis (
    "  DATA_LENGTH,      DATA_PRECISION,    DATA_SCALE,       NULLABLE," ) asis (
    "  COLUMN_ID,        DEFAULT_LENGTH,    DATA_DEFAULT,     NUM_DISTINCT," ) asis (
    "  LOW_VALUE,        HIGH_VALUE,        DENSITY,          NUM_NULLS," ) asis (
    "  NUM_BUCKETS,      LAST_ANALYZED,     SAMPLE_SIZE,      LOGGED," ) asis (
    "  COMPACT,          IDENTITY_IND,      GENERATED" ) asis ( ") as select" ) asis (
    "  c.owner,          c.table_name,      c.column_name,    c.data_type," ) asis (
    "  c.data_length,    c.data_precision,  c.data_scale,     c.nullable," ) asis (
    "  c.column_id,      c.default_length,  c.data_default,   c.num_distinct," ) asis (
    "  c.low_value,      c.high_value,      c.density,        c.num_nulls," ) asis (
    "  c.num_buckets,    c.last_analyzed,   c.sample_size,    'N/A'," ) asis (
    "  'N/A',            'N/A',             'N/A'" ) asis ( "from dba_tab_columns c" )
    END ;Rdb
    IF (check_error("CREATING DM2_DBA_TAB_COLS VIEW")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_def3_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_def3_exists_ind=1)
     DROP TABLE dm2_dba_tab_cols
     IF (check_error("Dropping DM2_DBA_TAB_COLS table def.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    DROP DDLRECORD dm2_dba_tab_cols FROM DATABASE v500 WITH deps_deleted
    CREATE DDLRECORD dm2_dba_tab_cols FROM DATABASE v500
 TABLE dm2_dba_tab_cols
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm2_dba_tab_cols
    IF (check_error("Creating DM2_DBA_TAB_COLS table def.")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_vue4_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_vue4_exists_ind=1)
     RDB drop view dm2_user_tab_cols
     END ;Rdb
     IF (check_error("Dropping DM2_USER_TAB_COLS view.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    CALL parser("rdb create view dm2_user_tab_cols")
    CALL parser("as select * from dm2_dba_tab_cols")
    CALL parser(concat("where owner = '",trim(currdbuser),"'"))
    CALL parser("go")
    IF (check_error("CREATING DM2_USER_TAB_COLS VIEW")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_def4_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_def4_exists_ind=1)
     DROP TABLE dm2_user_tab_cols
     IF (check_error("Dropping DM2_USER_TAB_COLS table def.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    DROP DDLRECORD dm2_user_tab_cols FROM DATABASE v500 WITH deps_deleted
    CREATE DDLRECORD dm2_user_tab_cols FROM DATABASE v500
 TABLE dm2_user_tab_cols
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc32000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = dq8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm2_user_tab_cols
    IF (check_error("Creating DM2_USER_TAB_COLS table def.")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((sdi_def5_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
    IF (sdi_def5_exists_ind=1)
     DROP TABLE product_component_version
     IF (check_error("Dropping PRODUCT_COMPONENT_VERSION table def.")=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    DROP TABLE product_component_version
    DROP DDLRECORD product_component_version FROM DATABASE v500 WITH deps_deleted
    IF (currdbver < 19)
     CREATE DDLRECORD product_component_version FROM DATABASE v500
 TABLE product_component_version
  1 product  = vc80 CCL(product)
  1 version  = vc80 CCL(version)
  1 status  = vc80 CCL(status)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE product_component_version
    ELSE
     CREATE DDLRECORD product_component_version FROM DATABASE v500
 TABLE product_component_version
  1 product  = vc80 CCL(product)
  1 version  = vc80 CCL(version)
  1 version_full  = vc160 CCL(version_full)
  1 status  = vc80 CCL(status)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE product_component_version
    ENDIF
    IF (check_error("Creating PRODUCT_COMPONENT_VERSION table def.")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_binary_search(search_item,record_structure,record_field) = i4
 SUBROUTINE dm2_binary_search(search_item,record_structure,record_field)
   DECLARE dbs_v_low = i4 WITH protect, noconstant(1)
   DECLARE dbs_v_mid = i4 WITH protect, noconstant(0)
   DECLARE dbs_v_high = i4 WITH protect, noconstant(0)
   CALL parser(concat("set dbs_v_high = size(",record_structure,",5) go"))
   WHILE (dbs_v_low <= dbs_v_high)
    SET dbs_v_mid = cnvtint(((dbs_v_high+ dbs_v_low)/ 2))
    IF (search_item=parser(build(record_structure,"[",dbs_v_mid,"]->",record_field)))
     RETURN(dbs_v_mid)
    ELSEIF (search_item < parser(build(record_structure,"[",dbs_v_mid,"]->",record_field)))
     SET dbs_v_high = (dbs_v_mid - 1)
    ELSE
     SET dbs_v_low = (dbs_v_mid+ 1)
    ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 IF (validate(retrieve_data->result_status,- (1)) < 0)
  FREE RECORD retrieve_data
  RECORD retrieve_data(
    1 result_str = vc
    1 result_status = i2
  )
  SET retrieve_data->result_status = 0
  SET retrieve_data->result_str = " "
 ENDIF
 DECLARE retrieve_data(sbr_srch_str=vc,sbr_sprtr=vc,sbr_rd_str=vc) = i2
 DECLARE dm2parse_output(sbr_attr_nbr=i4,sbr_parse_fname=vc,sbr_orientation=vc) = i2
 SUBROUTINE dm2parse_output(sbr_nbr_attr,sbr_parse_fname,sbr_orientation)
   DECLARE select_str = vc WITH protect, noconstant(" ")
   DECLARE foot_str = vc WITH protect, noconstant(" ")
   DECLARE buf_cnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE dm2_stat = i4 WITH protect, noconstant(0)
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   RECORD dm2parse_buf(
     1 qual[*]
       2 str = vc
   )
   SET select_str = concat('select into "nl:" r.line'," from rtlt r",' where r.line > " "'," detail "
    )
   FOR (attr_nbr = 1 TO sbr_nbr_attr)
     SET buf_cnt = (buf_cnt+ 1)
     IF (mod(buf_cnt,10)=1)
      SET stat = alterlist(dm2parse_buf->qual,(buf_cnt+ 9))
     ENDIF
     IF (attr_nbr=1)
      SET dm2parse_buf->qual[buf_cnt].str = concat(" if (findstring(dm2parse->attr1, r.line))",
       " cnt = cnt + 1"," if(mod(cnt,10) = 1)"," stat = alterlist(dm2parse->qual, cnt +9)"," endif",
       " if(retrieve_data(dm2parse->attr1, dm2parse->attr1sep, r.line))",
       " dm2parse->qual[cnt]->attr1val = retrieve_data->result_str"," endif")
     ELSE
      IF (sbr_orientation="V")
       SET dm2parse_buf->qual[buf_cnt].str = concat(" elseif (findstring( dm2parse->attr",trim(
         cnvtstring(attr_nbr),3)," , r.line))"," if (retrieve_data(dm2parse->attr",trim(cnvtstring(
          attr_nbr),3),
        ",dm2parse->attr",trim(cnvtstring(attr_nbr),3),"sep , r.line)) dm2parse->qual[cnt]->attr",
        trim(cnvtstring(attr_nbr),3),"val = retrieve_data->result_str endif")
      ELSE
       SET dm2parse_buf->qual[buf_cnt].str = concat(" endif if (findstring( dm2parse->attr",trim(
         cnvtstring(attr_nbr),3)," , r.line))"," if (retrieve_data(dm2parse->attr",trim(cnvtstring(
          attr_nbr),3),
        ",dm2parse->attr",trim(cnvtstring(attr_nbr),3),"sep , r.line)) dm2parse->qual[cnt]->attr",
        trim(cnvtstring(attr_nbr),3),"val = retrieve_data->result_str endif")
      ENDIF
     ENDIF
     IF (attr_nbr=sbr_nbr_attr)
      SET dm2parse_buf->qual[buf_cnt].str = concat(dm2parse_buf->qual[buf_cnt].str," endif")
     ENDIF
   ENDFOR
   SET stat = alterlist(dm2parse_buf->qual,buf_cnt)
   SET foot_str = concat(" foot report"," stat = alterlist(dm2parse->qual, cnt)"," with nocounter go"
    )
   SET dm2_stat = dm2_push_cmd("free define rtl go",1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_stat = dm2_push_cmd("free set file_loc go",1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_str = concat('set logical = file_loc "',sbr_parse_fname,'" go')
   SET dm2_stat = dm2_push_cmd(dm2_str,1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_stat = dm2_push_cmd('define rtl is "file_loc" go',1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(select_str,0))
    FOR (parse_cnt = 1 TO size(dm2parse_buf->qual,5))
     SET dm2_stat = dm2_push_cmd(dm2parse_buf->qual[parse_cnt].str,0)
     IF ( NOT (dm2_stat))
      RETURN(0)
     ENDIF
    ENDFOR
    IF (dm2_push_cmd(foot_str,1))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE retrieve_data(sbr_srch_str,sbr_sprtr,sbr_rd_str)
   SET retrieve_data->result_str = " "
   SET retrieve_data->result_status = 0
   DECLARE str_loc = i4 WITH protect, noconstant(0)
   DECLARE str_len = i4 WITH protect, noconstant(0)
   DECLARE srch_str_len = i4 WITH protect, noconstant(0)
   DECLARE sstart = i4 WITH protect, noconstant(0)
   DECLARE slength = i4 WITH protect, noconstant(0)
   IF ( NOT (sbr_sprtr IN (" ", "=")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Separator parameter invalid.  Must be either ' ' or '='."
    SET dm_err->eproc = "Separator validation."
    RETURN(0)
   ENDIF
   SET str_loc = findstring(sbr_srch_str,sbr_rd_str)
   IF (str_loc > 0)
    IF (sbr_sprtr="=")
     SET str_len = textlen(trim(sbr_rd_str))
     SET str_loc = findstring(sbr_sprtr,sbr_rd_str)
     IF (str_loc=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Separator not found.  DB2 List output contains invalid/outdated info."
      SET dm_err->eproc = concat("Locating '",sbr_sprtr,"' on line containing '",sbr_srch_str,"'.")
      RETURN(0)
     ELSE
      SET sstart = (str_loc+ 1)
      SET slength = (str_len - str_loc)
      SET retrieve_data->result_str = trim(substring(sstart,slength,sbr_rd_str),3)
      SET retrieve_data->result_status = 1
      RETURN(1)
     ENDIF
    ELSE
     SET str_len = textlen(trim(sbr_rd_str))
     SET srch_str_len = textlen(sbr_srch_str)
     SET sstart = (str_loc+ srch_str_len)
     SET slength = (((str_len - str_loc) - srch_str_len)+ 1)
     SET retrieve_data->result_str = trim(substring(sstart,slength,sbr_rd_str),3)
     SET retrieve_data->result_status = 1
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1) = i2
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_ddl_token_replacement(ddtr_text_str=vc(ref)) = i2
 DECLARE dm2_fill_seq_list(alias=vc,col_name=vc) = vc
 DECLARE dir_add_silmode_entry(entry_name=vc,entry_filename=vc) = i2
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dir_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dir_sea_sch_files(directory=vc,file_prefix=vc,schema_date=vc(ref)) = i2
 DECLARE dm2_val_sch_date_str(sbr_datestr=vc) = i2
 DECLARE dm2_fill_sch_except(sbr_dfse_from=vc) = i2
 DECLARE dm2_push_adm_maint(sbr_maint_str=vc) = i2
 DECLARE dm2_setup_dbase_env(null) = i2
 DECLARE dm2_get_suffixed_tablename(tbl_name=vc) = i2
 DECLARE prompt_for_host(sbr_host_db=vc) = i2
 DECLARE dm2_val_file_prefix(sbr_file_prefix=vc) = i2
 DECLARE dm2_toolset_usage(null) = i2
 DECLARE dir_get_obsolete_objects(null) = i2
 DECLARE dir_find_data_file(dfdf_file_found=i2(ref)) = i2
 DECLARE dir_dm2_tables_tspace_assign(null) = i2
 DECLARE dir_get_debug_trace_data(null) = i2
 DECLARE dir_managed_ddl_setup(dmds_runid=f8) = i2
 DECLARE dir_perform_wait_interval(null) = i2
 DECLARE dir_get_storage_type(dgst_db_link=vc) = i2
 DECLARE dir_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE dir_get_ddl_gen_retry(dgr_retry_ceiling=i2(ref)) = i2
 DECLARE dir_load_users_pwds(dlup_user_pwd=vc) = i2
 DECLARE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution=i2(ref),dcdosa_install_mode=vc) = i2
 DECLARE dir_check_for_package(dcfp_valid_ind=i2(ref),dcfp_env_id=f8(ref)) = i2
 DECLARE dir_get_dg_data(dgdd_assign_dg_ind=i2,dgdd_dg_override=vc,dgdd_dg_out=vc(ref)) = i2
 DECLARE dir_submit_jobs(dsj_plan_id=f8,dsj_install_mode=vc,dsj_user=vc,dsj_pword=vc,dsj_cnnct_str=vc,
  dsj_queue_name=vc,dsj_background_ind=i2) = i2
 DECLARE dir_get_adm_appl_status(dgaps_dblink=vc,dgaps_audsid=vc,dgaps_status=vc(ref)) = i2
 DECLARE dir_upd_adm_upgrade_info(null) = i2
 DECLARE dir_get_custom_constraints(null) = i2
 DECLARE dir_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 DECLARE dir_get_admin_db_link(dgadl_report_fail_ind=i2,dgadl_admin_db_link=vc(ref),dgadl_fail_ind=i2
  (ref)) = i2
 IF (validate(dm2_db_options->lob_build_ind," ")=" ")
  FREE RECORD dm2_db_options
  RECORD dm2_db_options(
    1 load_ind = i2
    1 dm2_toolset_usage = vc
    1 cursor_commit_cnt = vc
    1 new_tspace_type = vc
    1 dmt_freelist_grp = vc
    1 lob_storage_bp = vc
    1 lob_pctversion = vc
    1 lob_build_ind = vc
    1 lob_chunk = vc
    1 lob_cache = vc
    1 lob_securefile_ind = vc
    1 lob_retention = vc
    1 lob_maxsize = vc
    1 table_monitoring = vc
    1 table_monitoring_maxretry = vc
    1 db_optimizer_category = vc
    1 dbstats_gather_method = vc
    1 cbf_maxrangegroups = vc
    1 resource_busy_maxretry = vc
    1 dbstats_chk_rpt = vc
    1 readme_space_calc = vc
    1 recompile_after_alter_tbl = vc
    1 add_nn_col_nobf_ind = vc
    1 create_index_invisible = vc
    1 use_initprm_assign_dg_ind = vc
    1 assign_dg_override = vc
    1 degree_of_parallel_max = vc
    1 degree_of_parallel = vc
  )
  SET dm2_db_options->load_ind = 0
  SET dm2_db_options->dm2_toolset_usage = "NOT_SET"
  SET dm2_db_options->cursor_commit_cnt = "NOT_SET"
  SET dm2_db_options->dmt_freelist_grp = "NOT_SET"
  SET dm2_db_options->lob_pctversion = "NOT_SET"
  SET dm2_db_options->lob_chunk = "NOT_SET"
  SET dm2_db_options->lob_cache = "NOT_SET"
  SET dm2_db_options->lob_build_ind = "NOT_SET"
  SET dm2_db_options->new_tspace_type = "NOT_SET"
  SET dm2_db_options->lob_storage_bp = "NOT_SET"
  SET dm2_db_options->table_monitoring = "NOT_SET"
  SET dm2_db_options->table_monitoring_maxretry = "NOT_SET"
  SET dm2_db_options->db_optimizer_category = "NOT_SET"
  SET dm2_db_options->dbstats_gather_method = "NOT_SET"
  SET dm2_db_options->cbf_maxrangegroups = "NOT_SET"
  SET dm2_db_options->resource_busy_maxretry = "NOT_SET"
  SET dm2_db_options->dbstats_chk_rpt = "NOT_SET"
  SET dm2_db_options->readme_space_calc = "NOT_SET"
  SET dm2_db_options->recompile_after_alter_tbl = "NOT_SET"
  SET dm2_db_options->add_nn_col_nobf_ind = "NOT_SET"
  SET dm2_db_options->create_index_invisible = "NOT_SET"
  SET dm2_db_options->lob_securefile_ind = "NOT_SET"
  SET dm2_db_options->lob_retention = "NOT_SET"
  SET dm2_db_options->lob_maxsize = "NOT_SET"
  SET dm2_db_options->use_initprm_assign_dg_ind = "NOT_SET"
  SET dm2_db_options->assign_dg_override = "NOT_SET"
  SET dm2_db_options->degree_of_parallel_max = "NOT_SET"
  SET dm2_db_options->degree_of_parallel = "NOT_SET"
 ENDIF
 IF (validate(dm2_table->full_table_name," ")=" ")
  FREE RECORD dm2_table
  RECORD dm2_table(
    1 full_table_name = vc
    1 suffixed_table_name = vc
    1 table_suffix = vc
  )
  SET dm2_table->full_table_name = " "
  SET dm2_table->suffixed_table_name = " "
  SET dm2_table->table_suffix = " "
 ENDIF
 IF (validate(dm2_common1->snapshot_id,5)=5)
  FREE RECORD dm2_common1
  RECORD dm2_common1(
    1 snapshot_id = i2
  )
  SET dm2_common1->snapshot_id = 0
 ENDIF
 IF (validate(dm2_sch_except->tcnt,- (1)) < 0)
  FREE RECORD dm2_sch_except
  RECORD dm2_sch_except(
    1 tcnt = i4
    1 tbl[*]
      2 tbl_name = vc
    1 seq_cnt = i4
    1 seq[*]
      2 seq_name = vc
  )
  SET dm2_sch_except->tcnt = 0
  SET dm2_sch_except->seq_cnt = 0
 ENDIF
 IF ((validate(dm2_install_rec->snapshot_dt_tm,- (1))=- (1)))
  FREE RECORD dm2_install_rec
  RECORD dm2_install_rec(
    1 snapshot_dt_tm = f8
  )
 ENDIF
 IF (validate(dir_install_misc->ddl_failed_ind,1)=1
  AND validate(dir_install_misc->ddl_failed_ind,2)=2)
  FREE RECORD dir_install_misc
  RECORD dir_install_misc(
    1 ddl_failed_ind = i2
  )
  SET dir_install_misc->ddl_failed_ind = 0
 ENDIF
 IF ((validate(dir_silmode_requested_ind,- (1))=- (1))
  AND (validate(dir_silmode_requested_ind,- (2))=- (2)))
  DECLARE dir_silmode_requested_ind = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(dir_silmode->cnt,1)=1
  AND validate(dir_silmode->cnt,2)=2)
  FREE RECORD dir_silmode
  RECORD dir_silmode(
    1 cnt = i4
    1 qual[*]
      2 name = vc
      2 filename = vc
  )
  SET dir_silmode->cnt = 0
 ENDIF
 IF (validate(dir_batch_queue,"X")="X"
  AND validate(dir_batch_queue,"Y")="Y")
  DECLARE dir_batch_queue = vc WITH public, constant(cnvtlower(build("INSTALL$",logical("environment"
      ))))
 ENDIF
 IF (validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,1.0)=1.0
  AND validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,2.0)=2.0)
  FREE RECORD dm_ocd_setup_admin_data
  RECORD dm_ocd_setup_admin_data(
    1 dm_ocd_setup_admin_date = dq8
    1 dm2_create_system_defs = dq8
    1 dm2_set_adm_cbo = f8
  )
 ENDIF
 IF ((validate(dir_obsolete_objects->tbl_cnt,- (2))=- (2))
  AND (validate(dir_obsolete_objects->tbl_cnt,- (1))=- (1)))
  FREE RECORD dir_obsolete_objects
  RECORD dir_obsolete_objects(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
    1 ind_cnt = i4
    1 ind[*]
      2 index_name = vc
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
 ENDIF
 IF ((validate(dir_dropped_objects->obj_cnt,- (1))=- (1))
  AND (validate(dir_dropped_objects->obj_cnt,- (2))=- (2)))
  FREE RECORD dir_dropped_objects
  RECORD dir_dropped_objects(
    1 obj_cnt = i4
    1 rpt_drp_obj_ind = i2
    1 obj[*]
      2 table_name = vc
      2 name = vc
      2 type = vc
      2 reason = vc
  )
 ENDIF
 IF ((validate(dir_env_maint_rs->src_env_id,- (1))=- (1))
  AND (validate(dir_env_maint_rs->src_env_id,- (2))=- (2)))
  FREE RECORD dir_env_maint_rs
  RECORD dir_env_maint_rs(
    1 src_env_id = f8
    1 tgt_env_id = f8
    1 tgt_hist_fnd = i2
    1 process = vc
  )
  SET dir_env_maint_rs->src_env_id = 0
  SET dir_env_maint_rs->tgt_env_id = 0
  SET dir_env_maint_rs->tgt_hist_fnd = 0
  SET dir_env_maint_rs->process = "DM2NOTSET"
 ENDIF
 IF (validate(dir_tools_tspaces->data_tspace,"X")="X"
  AND validate(dir_tools_tspaces->data_tspace,"Y")="Y")
  FREE RECORD dir_tools_tspaces
  RECORD dir_tools_tspaces(
    1 data_tspace = vc
    1 index_tspace = vc
    1 lob_tspace = vc
  )
  SET dir_tools_tspaces->data_tspace = "NONE"
  SET dir_tools_tspaces->index_tspace = "NONE"
  SET dir_tools_tspaces->lob_tspace = "NONE"
 ENDIF
 IF (validate(dir_managed_ddl->setup_complete,1)=1
  AND validate(dir_managed_ddl->setup_complete,2)=2)
  FREE RECORD dir_managed_ddl
  RECORD dir_managed_ddl(
    1 setup_complete = i2
    1 managed_ddl_ind = i2
    1 oraversion = vc
    1 priority_cnt = i4
    1 priorities[*]
      2 priority = i4
    1 table_cnt = i4
    1 tables[*]
      2 table_name = vc
  )
  SET dir_managed_ddl->setup_complete = 0
  SET dir_managed_ddl->managed_ddl_ind = 0
  SET dir_managed_ddl->oraversion = "DM2NOTSET"
  SET dir_managed_ddl->priority_cnt = 0
  SET dir_managed_ddl->table_cnt = 0
 ENDIF
 IF (validate(dir_ui_misc->dm_process_event_id,1)=1
  AND validate(dir_ui_misc->dm_process_event_id,2)=2)
  FREE RECORD dir_ui_misc
  RECORD dir_ui_misc(
    1 dm_process_event_id = f8
    1 parent_script_name = vc
    1 background_ind = i2
    1 install_status = i2
    1 auto_install_ind = i2
    1 tspace_dg = vc
    1 debug_level = i4
    1 trace_flag = i2
  )
 ENDIF
 IF (validate(dir_storage_misc->src_storage_type,"x")="x"
  AND validate(dir_storage_misc->src_storage_type,"y")="y")
  FREE RECORD dir_storage_misc
  RECORD dir_storage_misc(
    1 src_storage_type = vc
    1 tgt_storage_type = vc
    1 cur_storage_type = vc
  )
  SET dir_storage_misc->src_storage_type = "DM2NOTSET"
  SET dir_storage_misc->tgt_storage_type = "DM2NOTSET"
  SET dir_storage_misc->cur_storage_type = "DM2NOTSET"
 ENDIF
 IF (validate(dir_db_users_pwds->cnt,1)=1
  AND validate(dir_db_users_pwds->cnt,2)=2)
  FREE RECORD dir_db_users_pwds
  RECORD dir_db_users_pwds(
    1 cnt = i4
    1 qual[*]
      2 user = vc
      2 pwd = vc
  )
  SET dir_db_users_pwds->cnt = 0
 ENDIF
 IF (validate(dir_custom_constraints->con_cnt,1)=1
  AND validate(dir_custom_constraints->con_cnt,2)=2)
  FREE RECORD dir_custom_constraints
  RECORD dir_custom_constraints(
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
  SET dir_custom_constraints->con_cnt = 0
 ENDIF
 IF (validate(dir_killed_appl->appl_cnt,1)=1
  AND validate(dir_killed_appl->appl_cnt,2)=2)
  FREE RECORD dir_killed_appl
  RECORD dir_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET dir_killed_appl->appl_cnt = 0
 ENDIF
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
 ENDIF
 IF (validate(dir_kill_clause,"z")="z"
  AND validate(dir_kill_clause,"y")="y")
  DECLARE dir_kill_clause = vc WITH public, constant(
   "Session was killed by V500.DM2MONPKG.KILL_IF_BLOCKING procedure.")
 ENDIF
 SUBROUTINE dir_dm2_tables_tspace_assign(null)
   IF ((dir_tools_tspaces->data_tspace != "NONE")
    AND (dir_tools_tspaces->index_tspace != "NONE")
    AND (dir_tools_tspaces->lob_tspace != "NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc =
    "Determining data_tspace from dm2_user_tables for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tables for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("D_TOOLKIT", "D_SYS_MGMT", "D_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc =
    "Determining index_tspace from dm2_user_indexes for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_indexes for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("I_TOOLKIT", "I_SYS_MGMT", "I_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->lob_tspace="NONE"))
    SET dir_tools_tspaces->lob_tspace = dir_tools_tspaces->data_tspace
    SET dm_err->eproc = "Determining lob_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("L_SYS_MGMT", "L_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->lob_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_debug_trace_data(null)
   SET dir_ui_misc->debug_level = 0
   SET dir_ui_misc->trace_flag = 0
   SET dm_err->eproc = "Query for debug flag/level"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="DEBUG_FLAG"
    DETAIL
     dir_ui_misc->debug_level = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Query for trace status"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="TRACE_FLAG"
    DETAIL
     IF (i.info_char="ON")
      dir_ui_misc->trace_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_obsolete_objects(null)
   SET dm_err->eproc = "Selecting obsolete tables and indexes from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_OBJECT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->tbl_cnt = 0, stat = alterlist(dir_obsolete_objects->tbl,
      dir_obsolete_objects->tbl_cnt), dir_obsolete_objects->ind_cnt = 0,
     stat = alterlist(dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    DETAIL
     CASE (build(di.info_char))
      OF "TABLE":
       dir_obsolete_objects->tbl_cnt = (dir_obsolete_objects->tbl_cnt+ 1),
       IF (mod(dir_obsolete_objects->tbl_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->tbl,(dir_obsolete_objects->tbl_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->tbl[dir_obsolete_objects->tbl_cnt].table_name = di.info_name
      OF "INDEX":
       dir_obsolete_objects->ind_cnt = (dir_obsolete_objects->ind_cnt+ 1),
       IF (mod(dir_obsolete_objects->ind_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->ind,(dir_obsolete_objects->ind_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->ind[dir_obsolete_objects->ind_cnt].index_name = di.info_name
     ENDCASE
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->tbl,dir_obsolete_objects->tbl_cnt), stat = alterlist(
      dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting obsolete constraints from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_CONSTRAINT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->con_cnt = 0, stat = alterlist(dir_obsolete_objects->con,
      dir_obsolete_objects->con_cnt)
    DETAIL
     dir_obsolete_objects->con_cnt = (dir_obsolete_objects->con_cnt+ 1)
     IF (mod(dir_obsolete_objects->con_cnt,10)=1)
      stat = alterlist(dir_obsolete_objects->con,(dir_obsolete_objects->con_cnt+ 9))
     ENDIF
     dir_obsolete_objects->con[dir_obsolete_objects->con_cnt].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->con,dir_obsolete_objects->con_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_obsolete_objects)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_fill_sch_except(sbr_dfse_from)
   IF ( NOT (cnvtupper(sbr_dfse_from) IN ("REMOTE", "LOCAL")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid from table indicator (should be either REMOTE or LOCAL)."
    SET dm_err->eproc = "Building exception list of tables"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt=0))
    IF (dm2_set_autocommit(1)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(sbr_dfse_from)="REMOTE")
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_src_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_user_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Determining tables that should be in dm2_sch_except record structure")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sch_except->seq_cnt=0))
    SET dm2_sch_except->seq_cnt = 1
    SET stat = alterlist(dm2_sch_except->seq,1)
    SET dm2_sch_except->seq[1].seq_name = "DM_SEQ"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_val_sch_date_str(sbr_datestr)
   DECLARE bad_sd_ind = i2 WITH protect, noconstant(0)
   DECLARE cnvt_datestr = vc WITH protect, noconstant(cnvtupper(sbr_datestr))
   IF (textlen(cnvt_datestr) != 11)
    SET bad_sd_ind = 1
   ELSEIF (substring(3,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (substring(7,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) > 31)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(8,4,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ENDIF
   IF (bad_sd_ind=1)
    SET dm_err->eproc = "Validating schema date"
    SET dm_err->err_ind = 1
    SET dm_err->user_action =
    'Please specify a valid date in the format "DD-MON-YYYY", e.g. "15-JAN-2002" '
    CALL disp_msg(concat('Invalid schema date of "',sbr_datestr,'" was passed in'),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_ddl_token_replacement(ddtr_text_str)
   DECLARE ddtr_pword = vc WITH protect, noconstant("NONE")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Before token replacement",ddtr_text_str))
   ENDIF
   IF (currdbuser="CDBA")
    IF ( NOT ((dm2_install_schema->cdba_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->cdba_p_word
    ENDIF
   ELSE
    IF ( NOT ((dm2_install_schema->v500_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->v500_p_word
    ENDIF
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL1%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL2%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL3%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC%",dm2_install_schema->cer_install,0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC2%",dm2_install_schema->ccluserdir,0)
   IF ((dm2_install_schema->servername != "NONE"))
    SET ddtr_text_str = replace(ddtr_text_str,"%SNAME%",dm2_install_schema->servername,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%UNAME%",trim(currdbuser),0)
   IF (ddtr_pword != "NONE")
    SET ddtr_text_str = replace(ddtr_text_str,"%PWD%",ddtr_pword,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DBASE%",trim(validate(currdbname," ")),0)
   IF ( NOT ((dm2_install_schema->src_v500_p_word="NONE")))
    SET ddtr_text_str = replace(ddtr_text_str,"%SRCPWD%",dm2_install_schema->src_v500_p_word,0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("After token replacement",ddtr_text_str))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_concurrent_snapshot(sbr_ccs_mode)
   DECLARE ccs_appl_id = vc WITH protect, noconstant(" ")
   DECLARE ccs_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(sbr_ccs_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      ccs_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF ((ccs_appl_id=dm2_install_schema->appl_id))
      SET dm_err->eproc = "Deleting concurrency row from dm_info - same application is restart mode."
      CALL disp_msg(" ",dm_err->logfile,0)
      DELETE  FROM dm_info di
       WHERE di.info_domain="DM2 INSTALL PROCESS"
        AND di.info_name="CONCURRENCY CHECKPOINT"
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ELSE
      SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
      CALL disp_msg(" ",dm_err->logfile,0)
      SET ccs_appl_status = dm2_get_appl_status(ccs_appl_id)
      IF (ccs_appl_status="E")
       RETURN(0)
      ELSE
       IF (ccs_appl_status="A")
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Another upgrade process is currently taking a schema snapshot."
        SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
        SET dm_err->user_action = "Please wait until other process completes and try again."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        SET dm_err->eproc = "Deleting concurrency row from dm_info - process inactive."
        CALL disp_msg(" ",dm_err->logfile,0)
        DELETE  FROM dm_info di
         WHERE di.info_domain="DM2 INSTALL PROCESS"
          AND di.info_name="CONCURRENCY CHECKPOINT"
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET dm2_install_rec->snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(dm2_install_rec->snapshot_dt_tm,
        "mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = dm2_install_schema->appl_id,
      di.info_date = cnvtdatetime(dm2_install_rec->snapshot_dt_tm), di.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), di.updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Deleting concurrency row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_row_count(rrc_table_name,rrc_row_cnt)
   DECLARE rrc_local_row_cnt = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = concat("Retrieving row count for table ",trim(rrc_table_name),".")
   SELECT INTO "nl:"
    FROM dm_user_tables_actual_stats t
    WHERE t.table_name=rrc_table_name
    DETAIL
     rrc_local_row_cnt = t.num_rows
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET rrc_row_cnt = 0.0
   ELSE
    SET rrc_row_cnt = rrc_local_row_cnt
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_setup_dbase_env(null)
   DECLARE max_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsdes_connect_str = vc WITH protect, noconstant(" ")
   IF (currdb="ORACLE")
    SET dsdes_cnnct_str = cnvtlower(build("v500","/",dm2_install_schema->v500_p_word,"@",
      dm2_install_schema->v500_connect_str))
   ELSE
    SET dsdes_cnnct_str = build("v500","/",dm2_install_schema->v500_p_word,"/",dm2_install_schema->
     v500_connect_str)
   ENDIF
   SET dm_err->eproc = "Determining if environment already set up."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE cnvtupper(e.environment_name)=cnvtupper(dm2_install_schema->target_env_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Determining next environment id."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (currdb="ORACLE")
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_env_id = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_environment e
      FOOT REPORT
       max_env_id = max(e.environment_id)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET new_env_id = (max_env_id+ 1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("max_env_id=",max_env_id))
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Inserting dm_environment row for database ",dm2_install_schema->
     target_dbase_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("insert into dm_environment de ",
     " set de.environment_id =  new_env_id ",
     ", de.environment_name =  cnvtupper(dm2_install_schema->target_env_name)",
     ", de.database_name = ' '",", de.admin_dbase_link_name = 'ADMIN1'",
     ", de.schema_version = 0.0",", de.from_schema_version = 0.0",
     ", de.v500_connect_string = dsdes_cnnct_str",", de.volume_group = 'N/A'",
     ", de.root_dir_name = 'N/A'",
     ", de.target_operating_system = dm2_sys_misc->cur_db_os ",", de.updt_applctx = 0 ",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ","  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Updating environment id with current information."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("update from dm_environment de ",
     "set  de.admin_dbase_link_name = 'ADMIN1'",", de.schema_version = 0.0",
     ", de.from_schema_version = 0.0",", de.v500_connect_string =  dsdes_cnnct_str",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ",
     "  where de.environment_name = cnvtupper(dm2_install_schema->target_env_name) ",
     "  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Prompt to confirm environment name"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm_set_env_id
   SET message = nowindow
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Determining if 'INHOUSE DOMAIN' dm_info row exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="INHOUSE DOMAIN"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dm_err->eproc = "Deleting 'INHOUSE DOMAIN' row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE prompt_for_host(sbr_host_db)
   DECLARE pfah_choice = vc WITH protect, noconstant(" ")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,concat("Creating a database connection to the ",cnvtupper(sbr_host_db)," database: "
     ),w)
   IF (currdb IN ("ORACLE", "DB2UDB"))
    CALL text(4,1,
     ">>> In the Host Name field, type the database server system's host name or IP address.")
   ELSE
    CALL text(4,1,
     ">>> In the Host Name field, type the database's server name (include named instance).")
   ENDIF
   CALL box(6,5,8,120)
   CALL text(7,7,"Host Name: ")
   CALL text(10,1,">>> Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,18,"P(100);C"," "
    WHERE  NOT (curaccept=" "))
   SET dm2_install_schema->hostname = trim(curaccept,3)
   CALL accept(10,53,"A;cu","C"
    WHERE curaccept IN ("Q", "C"))
   SET pfah_choice = curaccept
   SET message = nowindow
   IF (pfah_choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_val_file_prefix(sbr_file_prefix)
   DECLARE sbr_vfp_sch_date_fmt = f8 WITH protect
   DECLARE sbr_vfp_dir = vc WITH protect
   IF ((dm2_install_schema->process_option="DDL GEN"))
    SET dm2_install_schema->schema_prefix = ""
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSEIF (findstring("-",sbr_file_prefix) IN (0, 1))
    SET dm2_install_schema->schema_prefix = "dm2o"
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSE
    IF ((dm2_install_schema->process_option IN ("ADMIN CREATE", "ADMIN UPGRADE")))
     SET dm2_install_schema->schema_prefix = "dm2a"
    ELSE
     SET dm2_install_schema->schema_prefix = "dm2c"
    ENDIF
    IF (dm2_val_sch_date_str(sbr_file_prefix)=0)
     RETURN(0)
    ELSE
     SET sbr_vfp_sch_date_fmt = cnvtdate2(sbr_file_prefix,"DD-MMM-YYYY")
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(sbr_vfp_sch_date_fmt,"MM/DD/YYYY;;D"))
    ENDIF
   ENDIF
   IF ((((dm2_install_schema->schema_prefix="dm2o")) OR ((dm2_install_schema->process_option IN (
   "DDL GEN", "INHOUSE")))) )
    SET sbr_vfp_dir = dm2_install_schema->ccluserdir
    SET dm2_install_schema->schema_loc = "ccluserdir"
   ELSE
    SET sbr_vfp_dir = dm2_install_schema->cer_install
    SET dm2_install_schema->schema_loc = "cer_install"
   ENDIF
   IF ((dm2_install_schema->schema_prefix="dm2a"))
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),"_t.csv"))=0)
     SET dm_err->emsg = concat("CSV Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "CSV Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ELSE
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
     SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name="DM_INFO"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0
    AND checkdic("DM_INFO","T",0)=2)
    SET dm_err->eproc = "Determining if database option exists."
    FREE RECORD dtu_db_option
    RECORD dtu_db_option(
      1 info_char = vc
      1 info_date = dq8
    )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_",trim(currdb),"_DB_OPTION")
      AND d.info_name="DM2_TOOLSET_USAGE"
     DETAIL
      dtu_db_option->info_char = d.info_char, dtu_db_option->info_date = d.info_date
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     FREE RECORD dtu_db_option
     RETURN(0)
    ENDIF
    IF (curqual=1)
     IF ((dtu_db_option->info_char IN ("Y", "N"))
      AND (dtu_db_option->info_date=cnvtdatetime("22-JUN-1996 00:00:00")))
      IF ((dtu_db_option->info_char="Y"))
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM2 toolset because database option designates dm2 toolset usage")
       ENDIF
       RETURN(dtu_use_dm2_toolset)
      ELSE
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM toolset because database option designates dm toolset usage")
       ENDIF
       RETURN(dtu_use_dm_toolset)
      ENDIF
     ELSE
      IF ((dtu_db_option->info_char != "CERNER_DEFAULT"))
       IF ((dm_err->debug_flag > 0))
        CALL echo("Not using the database option because it is not set up correctly.")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Defaulting to DM2 toolset")
   ENDIF
   RETURN(dtu_use_dm2_toolset)
 END ;Subroutine
 SUBROUTINE dm2_get_suffixed_tablename(tbl_name)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   SET dm2_str = concat("select into 'nl:'"," from dm_tables_doc dtd ",
    " where dtd.table_name = cnvtupper('",tbl_name,"')",
    " detail"," dm2_table->suffixed_table_name = dtd.suffixed_table_name",
    " dm2_table->table_suffix = dtd.table_suffix"," dm2_table->full_table_name = dtd.full_table_name",
    " with nocounter",
    " go")
   IF ( NOT (dm2_push_cmd(dm2_str,1)))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_push_adm_maint(sbr_maint_str)
   DECLARE adm_maint_err = i4 WITH protect, noconstant(1)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET adm_maint_err = dm2_push_cmd(sbr_maint_str,1)
   IF (adm_maint_err=0)
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(adm_maint_err)
 END ;Subroutine
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET gas_appl_id_cvt = replace(trim(gas_appl_id,3),"*","\*",0)
    SELECT INTO "nl:"
     FROM dm2_user_views
     WHERE view_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dm2_user_views in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=0)
     SET gas_text = concat("RDB ASIS (^ ","CREATE VIEW DM2_SNAP_APPL_INFO AS ",
      " ( SELECT * FROM TABLE(SNAPSHOT_APPL_INFO('",gas_currdblink,"',-1 )) AS SNAPSHOT_APPL_INFO )",
      " ^) GO ")
     IF (dm2_push_cmd(gas_text,1) != 1)
      ROLLBACK
      RETURN(gas_error_status)
     ELSE
      COMMIT
      EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
      IF ((dm_err->err_ind=1))
       RETURN(gas_error_status)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dtable
     WHERE table_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dtable in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual != 1)
     EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(gas_error_status)
     ENDIF
    ENDIF
    SET gas_text = concat('select into "nl:" from DM2_SNAP_APPL_INFO where appl_id = "',
     gas_appl_id_cvt,'" with nocounter go')
    IF (dm2_push_cmd(gas_text,1) != 1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=1)
     RETURN(gas_active_status)
    ELSE
     RETURN(gas_inactive_status)
    ENDIF
   ELSEIF (currdb="SQLSRV")
    DECLARE gas_str_loc1 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc2 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc3 = i4 WITH protect, noconstant(0)
    DECLARE gas_spid = i4 WITH protect, noconstant(0)
    DECLARE gas_login_date = vc WITH protect, noconstant(" ")
    DECLARE gas_login_time = i4 WITH protect, noconstant(0)
    SET gas_str_loc1 = findstring("-",trim(gas_appl_id,3),1,0)
    SET gas_str_loc2 = findstring(" ",trim(gas_appl_id,3),1,1)
    SET gas_str_loc3 = findstring(":",trim(gas_appl_id,3),1,1)
    IF (((gas_str_loc1=0) OR (((gas_str_loc2=0) OR (gas_str_loc3=0)) )) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid application handle"
     SET dm_err->eproc =
     "Parsing through application handle to determine spid and login date and time"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSE
     SET gas_spid = cnvtint(build(substring(1,(gas_str_loc1 - 1),trim(gas_appl_id,3))))
     SET gas_login_date = cnvtupper(cnvtalphanum(substring((gas_str_loc1+ 1),(gas_str_loc2 -
        gas_str_loc1),trim(gas_appl_id,3))))
     SET gas_login_time = cnvtint(cnvtalphanum(substring(gas_str_loc2,(gas_str_loc3 - gas_str_loc2),
        trim(gas_appl_id,3))))
    ENDIF
    SELECT INTO "nl:"
     FROM sysprocesses p
     WHERE p.spid=gas_spid
      AND p.login_time=cnvtdatetime(cnvtdate2(gas_login_date,"DDMMMYYYY"),gas_login_time)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from sysprocesses in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ELSE
    IF (cnvtupper(gas_appl_id)="-15301")
     RETURN(gas_active_status)
    ENDIF
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from gv$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     SELECT INTO "nl:"
      FROM v$session s
      WHERE s.audsid=cnvtint(gas_appl_id)
      WITH nocounter
     ;end select
     IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(gas_error_status)
     ENDIF
     IF (curqual > 0)
      RETURN(gas_active_status)
     ELSE
      RETURN(gas_inactive_status)
     ENDIF
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_seq_list(alias,col_name)
   DECLARE in_clause = vc WITH protect, noconstant("")
   SET in_clause = concat(alias,".",col_name," IN ('DM_PLAN_ID_SEQ', 'REPORT_SEQUENCE','DM_SEQ') ")
   RETURN(in_clause)
 END ;Subroutine
 SUBROUTINE dir_add_silmode_entry(entry_name,entry_filename)
   SET dir_silmode->cnt = (dir_silmode->cnt+ 1)
   SET stat = alterlist(dir_silmode->qual,dir_silmode->cnt)
   SET dir_silmode->qual[dir_silmode->cnt].name = entry_name
   SET dir_silmode->qual[dir_silmode->cnt].filename = entry_filename
 END ;Subroutine
 SUBROUTINE dm2_cleanup_stranded_appl(null)
   DECLARE dcsa_applx = i4 WITH protect, noconstant(0)
   DECLARE dcsa_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcsa_error_msg = vc WITH protect, noconstant(" ")
   DECLARE dcsa_load_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsa_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dcsa_appl_rs
   RECORD dcsa_appl_rs(
     1 dcsa_appl_cnt = i4
     1 dcsa_appl[*]
       2 dcsa_appl_id = vc
   )
   SELECT INTO "nl:"
    FROM dm2_user_tables ut
    WHERE ut.table_name="DM2_DDL_OPS_LOG*"
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - DDL_OPS_LOG table existence check")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF (curqual=0)
    CALL echo(
     "dm2_ddl_ops_log table not found in dm2_user_tables, bypassing dm2_cleanup_stranded_appl logic..."
     )
    RETURN(1)
   ELSE
    IF ((dm_err->debug_flag > 1))
     CALL echo("Curqual from user_tables for dm2_ddl_ops_log* returned != 0")
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ddol_appl_id = ddol.appl_id
    FROM dm2_ddl_ops_log ddol
    WHERE ddol.status IN ("RUNNING", null)
     AND ddol.op_type != "*(REMOTE)*"
    HEAD REPORT
     dcsa_applx = 0
    DETAIL
     dcsa_applx = (dcsa_applx+ 1)
     IF (mod(dcsa_applx,10)=1)
      stat = alterlist(dcsa_appl_rs->dcsa_appl,(dcsa_applx+ 9))
     ENDIF
     dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id = ddol_appl_id
    FOOT REPORT
     dcsa_appl_rs->dcsa_appl_cnt = dcsa_applx, stat = alterlist(dcsa_appl_rs->dcsa_appl,dcsa_applx)
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - Select")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF ((dcsa_appl_rs->dcsa_appl_cnt > 0))
    SET dcsa_applx = 1
    WHILE ((dcsa_applx <= dcsa_appl_rs->dcsa_appl_cnt))
      SET dcsa_fmt_appl_id = dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id
      CASE (dm2_get_appl_status(value(dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id)))
       OF "I":
        IF (dir_alert_killed_appl(dcsa_load_ind,dcsa_fmt_appl_id,dcsa_kill_ind)=0)
         RETURN(0)
        ENDIF
        SET dcsa_load_ind = 0
        IF (dcsa_kill_ind=1)
         SET dcsa_error_msg = dir_kill_clause
        ELSE
         SET dcsa_error_msg = concat("Application ID ",trim(dcsa_fmt_appl_id)," is no longer active."
          )
        ENDIF
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg =
          "IMPORT operation set to ERROR since session executing no longer exists.", ddol.end_dt_tm
           = cnvtdatetime(curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status="RUNNING"
          AND ddol.op_type="IMPORT*"
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN (null, "RUNNING")
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        IF (check_error("Find_Stranded_Processes - Update")=true)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(false)
        ELSE
         COMMIT
        ENDIF
       OF "A":
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Application Id ",dcsa_fmt_appl_id," is active."))
        ENDIF
       OF "E":
        IF ((dm_err->debug_flag > 0))
         CALL echo("Error Detected in dm2_get_appl_status")
        ENDIF
        RETURN(false)
      ENDCASE
      SET dcsa_applx = (dcsa_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE dir_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
   DECLARE daka_audsid = vc WITH protect, noconstant(" ")
   DECLARE daka_audsid_start = i4 WITH protect, noconstant(0)
   DECLARE daka_audsid_end = i4 WITH protect, noconstant(0)
   DECLARE daka_applx = i4 WITH protect, noconstant(0)
   DECLARE daka_info_exists = i4 WITH protect, noconstant(0)
   SET daka_kill_ind = 0
   IF (daka_load_ind=1)
    IF (dm2_table_and_ccldef_exists("DM_INFO",daka_info_exists)=0)
     RETURN(0)
    ELSEIF (daka_info_exists=0)
     RETURN(1)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2MONPKG_LOGGER"
      AND d.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(curdate,curtime3
      )
      AND d.info_char="*AUDSID:*"
     HEAD REPORT
      dir_killed_appl->appl_cnt = 0
     DETAIL
      daka_audsid_start = findstring("AUDSID:",d.info_char,1,0), daka_audsid_end = findstring(",",d
       .info_char,daka_audsid_start,0)
      IF (daka_audsid_end=0)
       daka_audsid = substring(daka_audsid_start,((size(d.info_char)+ 1) - daka_audsid_start),d
        .info_char)
      ELSE
       daka_audsid = substring(daka_audsid_start,(daka_audsid_end - daka_audsid_start),d.info_char)
      ENDIF
      daka_audsid = trim(replace(daka_audsid,"AUDSID:","",0),3)
      IF (isnumeric(daka_audsid))
       dir_killed_appl->appl_cnt += 1
       IF (mod(dir_killed_appl->appl_cnt,10)=1)
        stat = alterlist(dir_killed_appl->appl,(dir_killed_appl->appl_cnt+ 9))
       ENDIF
       dir_killed_appl->appl[dir_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_killed_appl->appl,dir_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,dir_killed_appl->appl_cnt,daka_fmt_appl_id,
     dir_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   IF ((dm2_sys_misc->cur_os != "AXP"))
    RETURN(1)
   ENDIF
   IF (((dsbq_queue_name=" ") OR (dsbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_env_name = logical("environment")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Environment Name = ",dsbq_env_name))
   ENDIF
   IF (((dsbq_env_name=" ") OR (dsbq_env_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment name."
    SET dm_err->emsg = "Invalid environment name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("lreg -getp environment\",dsbq_env_name,
    " LocalUserName ;show symbol LREG_RESULT")
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",dsbq_cmd))
    CALL echo("*")
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errtext = replace(dm_err->errtext,'LREG_RESULT = "',"",0)
   SET dm_err->errtext = replace(dm_err->errtext,'"',"",1)
   IF (findstring("%DCL-W-UNDSYM",dm_err->errtext) > 0)
    SET dsbq_domain_user = " "
   ELSE
    SET dsbq_domain_user = trim(dm_err->errtext,3)
   ENDIF
   IF (dsbq_domain_user=" ")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Retreiving domain user from registry."
    SET dm_err->emsg = "Unable to retrieive domain user from registry."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(curuser) != cnvtupper(dsbq_domain_user))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Making sure current user is the domain user."
    SET dm_err->emsg = "Current user is not the domain user."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("sho queue /full ",dsbq_queue_name)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dsbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dsbq_queue_fnd = 0
   ELSEIF (findstring(cnvtlower(dsbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dsbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dsbq_queue_fnd = 1
   ENDIF
   IF (dsbq_queue_fnd=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dsbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dsbq_cmd = concat("init/queue/batch/start/job_limit=20 ",dsbq_queue_name)
    IF ((dm_err->debug_flag > 0))
     CALL echo("*")
     CALL echo(concat("call dcl executing: ",dsbq_cmd))
     CALL echo("*")
    ENDIF
    IF (dm2_push_dcl(dsbq_cmd)=0)
     RETURN(0)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Results of create queue command: ",dm_err->errtext))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_sea_sch_files(directory,file_prefix,schema_date)
   DECLARE dgns_dcl_find = vc WITH protect, noconstant("")
   DECLARE dgns_err_str = vc WITH protect, noconstant("")
   SET schema_date = "01-JAN-1800"
   IF ( NOT (file_prefix IN ("dm2a", "dm2o", "dm2c")))
    SET dm_err->eproc = "Validating file_prefix."
    SET dm_err->emsg = "file_prefix must be IN ('dm2a', 'dm2o', 'dm2c')"
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"%%%2*")
    ELSE
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"*")
    ENDIF
    SET dgns_err_str = "no files found"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"???3????_*")
    ELSE
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"*")
    ENDIF
    SET dgns_err_str = "file not found"
   ELSE
    IF (file_prefix="dm2a")
     IF ((dm2_sys_misc->cur_os="LNX"))
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???4* | wc -w")
     ELSE
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???1* | wc -w")
     ENDIF
    ELSE
     SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"* | wc -w")
    ENDIF
    SET dgns_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dgns_dcl_find)=0)
    IF (findstring(dgns_err_str,cnvtlower(dm_err->errtext)) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX")))
     IF (file_prefix="dm2a")
      IF ((dm2_sys_misc->cur_os="LNX"))
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???4* ")
      ELSE
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???1* ")
      ENDIF
     ELSE
      SET dgns_dcl_find = concat("ls - ",build(directory),"/",file_prefix,"* ")
     ENDIF
     SET dm_err->eproc = "Building list of schema files to gather schema date"
     IF (dm2_push_dcl(dgns_dcl_find)=0)
      RETURN(0)
     ENDIF
    ENDIF
    FREE DEFINE rtl
    FREE SET file_loc
    SET logical file_loc value(dm_err->errfile)
    DEFINE rtl "file_loc"
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     HEAD REPORT
      compare_date = cnvtdate("01011800"), stripped_date = cnvtdate("01011800")
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       starting_pos = findstring(cnvtupper(file_prefix),r.line)
      ELSE
       starting_pos = findstring(file_prefix,r.line)
      ENDIF
      stripped_date = cnvtdate(substring((starting_pos+ 4),8,r.line))
      IF (stripped_date > compare_date)
       schema_date = format(stripped_date,"DD-MMM-YYYY;;d"), compare_date = stripped_date
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_list_of_files(dglf_prefix)
   DECLARE dglf_str = vc WITH protect
   SET dm_err->eproc = "Getting help list of schema files to select from."
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dglf_str = concat("dir/version=1/columns=1 cer_install:",dglf_prefix,"*_h.dat ")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET dglf_str = concat("dir ",dm2_install_schema->cer_install,"\",dglf_prefix,"*_h.dat /B")
   ELSE
    SET dglf_str = concat('find $cer_install -name "',dglf_prefix,'*_h.dat" -print')
   ENDIF
   IF (dm2_push_dcl(value(dglf_str))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_find_data_file(dfdf_file_found)
   DECLARE dtd_data_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Finding data files"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    DETAIL
     dtd_data_file = ddf.file_name
    WITH maxqual(ddf,1), nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dfdf_file_found = findfile(dtd_data_file)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file found ind =",dfdf_file_found))
    CALL echo(build("file name =",dtd_data_file))
   ENDIF
   IF (dfdf_file_found=0)
    SET dm_err->eproc = "Datafile not visible at operating system level"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_managed_ddl_setup(dmds_runid)
   DECLARE dmds_rowcnt = f8 WITH protect, noconstant(0.0)
   DECLARE dmds_ndx = i4 WITH protect, noconstant(0)
   DECLARE dmds_priority = i4 WITH protect, noconstant(0)
   SET dir_managed_ddl->setup_complete = 0
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if Managed DDL oracle version"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_MANAGED_DDL_ORAVER"
    DETAIL
     IF (d.info_name=build(dm2_rdbms_version->level1,".",dm2_rdbms_version->level2,".",
      dm2_rdbms_version->level3,
      ".",dm2_rdbms_version->level4))
      dir_managed_ddl->oraversion = d.info_name, dir_managed_ddl->managed_ddl_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_managed_ddl->managed_ddl_ind=1))
    SET dm_err->eproc = "Check for row_cnt override for Managed DDL"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_MANAGED_DDL_ROWCNT"
     DETAIL
      dmds_rowcnt = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dmds_rowcnt > 0.0)
     SET dm_err->eproc = concat("Managed DDL Rowcnt Override: ",build(dmds_rowcnt))
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dmds_rowcnt = 10000
    ENDIF
    SET dm_err->eproc = "Load Managed DDL Priorities"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d,
      dm_dba_tables_actual_stats t
     WHERE d.run_id=dmds_runid
      AND d.op_type IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE di.info_domain="DM2_MANAGED_DDL_OP_TYPE"))
      AND d.table_name != "DM*"
      AND d.table_name=t.table_name
      AND t.num_rows > dmds_rowcnt
      AND (( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="DM2_MIXED_TABLE-EXPORT-REFERENCE"
       AND di.info_name=d.table_name))) OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_tables_doc dtd
      WHERE dtd.reference_ind=0
       AND dtd.table_name=d.table_name))))
      AND ((d.status != "COMPLETE") OR (d.status = null))
     ORDER BY d.priority, d.table_name
     HEAD d.priority
      dmds_ndx = 0, dmds_priority = d.priority
      IF ((dir_managed_ddl->priority_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->priority_cnt,dmds_priority,dir_managed_ddl->
        priorities[dmds_ndx].priority)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->priority_cnt = (dir_managed_ddl->priority_cnt+ 1)
       IF (mod(dir_managed_ddl->priority_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->priorities,(dir_managed_ddl->priority_cnt+ 99))
       ENDIF
       dir_managed_ddl->priorities[dir_managed_ddl->priority_cnt].priority = d.priority
      ENDIF
     HEAD d.table_name
      dmds_ndx = 0
      IF ((dir_managed_ddl->table_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->table_cnt,d.table_name,dir_managed_ddl->
        tables[dmds_ndx].table_name)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->table_cnt = (dir_managed_ddl->table_cnt+ 1)
       IF (mod(dir_managed_ddl->table_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->tables,(dir_managed_ddl->table_cnt+ 99))
       ENDIF
       dir_managed_ddl->tables[dir_managed_ddl->table_cnt].table_name = d.table_name
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_managed_ddl->tables,dir_managed_ddl->table_cnt), stat = alterlist(
       dir_managed_ddl->priorities,dir_managed_ddl->priority_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dir_managed_ddl->managed_ddl_ind = 0
    ENDIF
   ENDIF
   SET dir_managed_ddl->setup_complete = 1
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_managed_ddl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_perform_wait_interval(null)
   DECLARE dpwi_pause_interval = i4 WITH protect, noconstant(1)
   SET dm_err->eproc = "Obtain pause interval"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INSTALL_PKG"
     AND d.info_name="PAUSE_INTERVAL"
    DETAIL
     dpwi_pause_interval = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Pausing for ",build(dpwi_pause_interval)," minutes.")
   CALL disp_msg("",dm_err->logfile,0)
   CALL pause((dpwi_pause_interval * 60))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_storage_type(dgst_db_link)
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    SET dir_storage_misc->cur_storage_type = "AXP"
    SET dir_storage_misc->tgt_storage_type = "AXP"
    SET dir_storage_misc->src_storage_type = "AXP"
   ELSE
    IF (dgst_db_link > " "
     AND dgst_db_link != "DM2NOTSET")
     SET dm_err->eproc = "Determine source storage type from dba_data_files"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (parser(concat("dba_data_files@",dgst_db_link)) ddf)
      WHERE ddf.tablespace_name="SYSTEM"
       AND ddf.file_name=patstring("/dev/*")
      DETAIL
       dir_storage_misc->src_storage_type = "RAW"
      WITH nocounter, maxqual = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dir_storage_misc->src_storage_type = "ASM"
     ENDIF
    ENDIF
    SET dm_err->eproc = "Determine target storage type from dba_data_files"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_data_files ddf
     WHERE ddf.tablespace_name="SYSTEM"
     DETAIL
      IF (ddf.file_name=patstring("/dev/*"))
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ELSEIF (ddf.file_name=patstring("+*"))
       dir_storage_misc->cur_storage_type = "ASM", dir_storage_misc->tgt_storage_type = "ASM"
      ELSE
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ENDIF
     WITH nocounter, maxqual = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   IF (validate(dm2_tgt_storage_type,"XXX") IN ("RAW", "ASM"))
    SET dir_storage_misc->cur_storage_type = dm2_tgt_storage_type
    SET dir_storage_misc->tgt_storage_type = dm2_tgt_storage_type
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution,dcdosa_install_mode)
   DECLARE dcdosa_compare_date = vc WITH protect, noconstant("")
   DECLARE dcdosa_cer_install = vc WITH protect, noconstant("")
   DECLARE dcdosa_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm_ocd_setup_admin_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_dm2_create_system_defs_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm2_set_adm_cbo_date = dq8 WITH protect, noconstant(0.0)
   SET dcdosa_requires_execution = 0
   IF (currdb != "ORACLE")
    SET dm_err->eproc = "Admin Setup Bypassed - Database must be on Oracle to perform Admin setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "AXP", "LNX", "WIN"))))
    SET dm_err->eproc =
    "Admin Setup Bypassed - o/s must be HPX, AIX, VMS, LNX or WIN to perform Admin Setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT (dcdosa_install_mode IN ("UPTIME", "BATCHUP", "PREVIEW", "BATCHPREVIEW", "EXPRESS",
   "BATCHEXPRESS")))
    SET dm_err->eproc = "Checking install mode"
    SET dm_err->eproc = concat("Admin Setup Bypassed - Install mode needs to be ",
     " UPTIME, BATCHUP, PREVIEW, BATCHPREVIEW, EXPRESS or BATCHEXPRESS to perform Admin Setup.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("clinical database version : ",dm2_rdbms_version->level1))
   ENDIF
   SET dm_err->eproc = "Selecting dm_info rows."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    HEAD REPORT
     dcdosa_dm_info_schema_date = 0, dcdosa_dm_info_dm_ocd_setup_admin_date = 0.0,
     dcdosa_dm_info_dm2_create_system_defs_date = 0.0,
     dcdosa_dm_info_dm2_set_adm_cbo_date = 0.0
    DETAIL
     CASE (di.info_name)
      OF "SCHEMA_DATE":
       dcdosa_dm_info_schema_date = cnvtdate2(di.info_char,"DD-MMM-YYYY")
      OF "DM_OCD_SETUP_ADMIN_DATE":
       dcdosa_dm_info_dm_ocd_setup_admin_date = cnvtdatetime(di.info_char)
      OF "DM2_CREATE_SYSTEM_DEFS_DATE":
       dcdosa_dm_info_dm2_create_system_defs_date = cnvtdatetime(di.info_char)
      OF "DM2_SET_ADM_CBO_DATE":
       dcdosa_dm_info_dm2_set_adm_cbo_date = cnvtdatetime(di.info_char)
     ENDCASE
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finding newest schema file."
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdosa_cer_install = cnvtlower(trim(logical("cer_install"),3))
   IF (dcfr_sea_csv_files(dcdosa_cer_install,"dm2a",dcdosa_compare_date)=0)
    RETURN(0)
   ELSE
    IF (dcdosa_compare_date="01-JAN-1800")
     SET dm_err->eproc = "Searching for Schema files."
     SET dm_err->emsg = "No schema files present in cer_install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dcdosa_schema_date = cnvtdate2(dcdosa_compare_date,"DD-MMM-YYYY")
    ENDIF
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("dcdosa_dm_info_schema_date:",dcdosa_dm_info_schema_date))
    CALL echo(build("dcdosa_schema_date:",dcdosa_schema_date))
    CALL echo(build("dcdosa_dm_info_dm_ocd_setup_admin_date:",dcdosa_dm_info_dm_ocd_setup_admin_date)
     )
    CALL echo(build("dm_ocd_setup_admin_data->dm_ocd_setup_admin_date:",dm_ocd_setup_admin_data->
      dm_ocd_setup_admin_date))
    CALL echo(build("dcdosa_dm_info_dm2_create_system_defs_date:",
      dcdosa_dm_info_dm2_create_system_defs_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_create_system_defs:",dm_ocd_setup_admin_data->
      dm2_create_system_defs))
    CALL echo(build("dcdosa_dm_info_dm2_set_adm_cbo_date:",dcdosa_dm_info_dm2_set_adm_cbo_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_set_adm_cbo:",dm_ocd_setup_admin_data->
      dm2_set_adm_cbo))
   ENDIF
   IF ((dm2_rdbms_version->level1 < 11))
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR ((
    dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs)))
    )) )
     SET dcdosa_requires_execution = 1
     RETURN(1)
    ENDIF
   ELSE
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR (
    (((dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs))
     OR ((dcdosa_dm_info_dm2_set_adm_cbo_date < dm_ocd_setup_admin_data->dm2_set_adm_cbo))) )) )) )
     SET dcdosa_requires_execution = 1
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_for_package(dcfp_valid_ind,dcfp_env_id)
   SET dcfp_valid_ind = 0
   SET dcfp_env_id = 0.0
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypassing check for package history.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Find environment id."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_name="DM_ENV_ID"
    DETAIL
     dcfp_env_id = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = build("Look for package history for environment id :",dcfp_env_id)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ocd_log l
    WHERE l.environment_id=dcfp_env_id
    WITH nocounter, maxqual(l,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
   ELSE
    SET dcfp_valid_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_dg_data(dgdd_assign_dg_ind,dgdd_dg_override,dgdd_dg_out)
   DECLARE dgdd_dskgrp_name = vc WITH protect, noconstant("")
   DECLARE dgdd_dskgrp_state = vc WITH protect, noconstant("")
   DECLARE dgdd_chck = i2 WITH protect, noconstant(1)
   SET dm_err->eproc = "Get diskgroup information"
   CALL disp_msg("",dm_err->logfile,0)
   SET dgdd_dg_out = "NOT_SET"
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Use initprm assign dg ind->",dgdd_assign_dg_ind))
    CALL echo(build("Diskgroup override->",dgdd_dg_override))
   ENDIF
   IF (dgdd_dg_override != "NOT_SET")
    SET dm_err->eproc = "Query for state of disk group "
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dg_override
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dg_override
     SET dgdd_chck = 0
    ENDIF
   ENDIF
   IF (dgdd_assign_dg_ind=1
    AND dgdd_chck=1)
    SET dm_err->eproc = "Query for disk group using db_create_file_dest"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$parameter v
     WHERE v.name="db_create_file_dest"
     DETAIL
      dgdd_dskgrp_name = cnvtupper(v.value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (findstring("+",dgdd_dskgrp_name,1,0) > 0)
     SET dgdd_dskgrp_name = trim(replace(dgdd_dskgrp_name,"+","",1),3)
    ENDIF
    SET dm_err->eproc = "Query to validate diskgroup"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dskgrp_name
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dskgrp_name
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Determined diskgroup->",dgdd_dg_out))
   ENDIF
   IF (dgdd_dg_out != "NOT_SET")
    SET dir_ui_misc->tspace_dg = dgdd_dg_out
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_submit_jobs(dsj_plan_id,dsj_install_mode,dsj_user,dsj_pword,dsj_cnnct_str,
  dsj_queue_name,dsj_background_ind)
   DECLARE dsj_wait_time_minutes = i2 WITH protect, noconstant(15)
   DECLARE dsj_wait_timestamp = f8 WITH protect, noconstant(0.0)
   DECLARE dsj_wait_for_start = i2 WITH protect, noconstant(0)
   FREE RECORD dsj_request
   RECORD dsj_request(
     1 plan_id = f8
     1 install_mode = vc
   )
   FREE RECORD dsj_reply
   RECORD dsj_reply(
     1 install_status = vc
     1 event = vc
     1 install_mode_ret = vc
     1 message = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET dsj_request->plan_id = dsj_plan_id
   SET dsj_request->install_mode = "CURRENT"
   SET dsj_wait_timestamp = cnvtdatetime(curdate,curtime3)
   SET dm_err->eproc = "Get the status of auto installation"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm2_auto_install_status  WITH replace("REQUEST",dsj_request), replace("REPLY",dsj_reply)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    IF ((dsj_reply->install_status="EXECUTING"))
     SET dm_err->eproc = "Checking the status of the auto install process"
     SET dm_err->emsg = concat("Active package install running for ",dsj_reply->install_mode_ret)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "submit the package install to background"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_package_install,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_install_mode="*ABG")
    SET dsj_install_mode = replace(dsj_install_mode,"ABG","",2)
   ENDIF
   SET dm_err->eproc = "Waiting for background installation process to begin."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = "Check for wait time override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_SUBMIT_TIME_WAIT"
     AND d.info_name="MINUTES"
    DETAIL
     dsj_wait_time_minutes = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dsj_wait_for_start = 1
   WHILE (dsj_wait_for_start=1)
     IF (drr_cleanup_dm_info_runners(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Wait for install to begin execution."
     SELECT INTO "nl:"
      FROM dm_process dp,
       dm_process_event dpe,
       dm_process_event_dtl dped1,
       dm_process_event_dtl dped2
      PLAN (dpe
       WHERE dpe.install_plan_id=dsj_plan_id
        AND dpe.begin_dt_tm >= cnvtdatetime(dsj_wait_timestamp))
       JOIN (dp
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution)
       JOIN (dped1
       WHERE dpe.dm_process_event_id=dped1.dm_process_event_id
        AND dped1.detail_type="INSTALL_MODE"
        AND dped1.detail_text=dsj_install_mode)
       JOIN (dped2
       WHERE dped1.dm_process_event_id=dped2.dm_process_event_id
        AND dped2.detail_type="UNATTENDED_IND")
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dsj_wait_for_start = 0
     ENDIF
     IF (datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),cnvtdatetimeutc(cnvtdatetime(
        dsj_wait_timestamp)),4) > dsj_wait_time_minutes
      AND dsj_wait_for_start=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Wait time expired. Unable to detect background install process."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     CALL pause(5)
   ENDWHILE
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_install_monitor,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_background_ind=0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,concat("The ",dsj_install_mode,
      " Installation is now submitted as a background process."))
    CALL text(3,1,"This session/connection is no longer required.")
    CALL text(5,1,"Notification emails about Installation events will be sent as they occur.")
    CALL text(8,1,concat("To monitor, stop or pause the execution of the background ",
      dsj_install_mode," Installation process,"))
    CALL text(9,1,"you can execute the following in CCL:")
    CALL text(11,1,"ccl> dm2_install_plan_menu go ")
    CALL text(13,3,"Enter 'C' to continue.")
    CALL accept(13,34,"p;cduh"," "
     WHERE curaccept IN ("C"))
    CALL clear(1,1)
    SET message = nowindow
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = concat("Check if ",dcp_table_name," table is involved in a hard parse event.")
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",trim(dcp_owner),
      ".",dcp_table_name,". SQL_ID = ",
      trim(d.sql_id),", Session_Id:",trim(cnvtstring(d.session_id)),", Serial#: ",trim(cnvtstring(d
        .session_serial#)),
      ".")
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_ddl_gen_retry(dgr_retry_ceiling)
   DECLARE dgr_di_exists = i2 WITH protect, noconstant(0)
   SET dgr_retry_ceiling = 10
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgr_di_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgr_di_exists=1)
    SET dm_err->eproc = "Check for retry ceiling override."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_DDL_GEN"
      AND d.info_name="RETRY CEILING"
     DETAIL
      dgr_retry_ceiling = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgr_retry_ceiling <= 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Retry ceiling is invalid (must be greater than zero)."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_users_pwds(dlup_users_for_pwd)
   DECLARE dlup_user = vc WITH protect, noconstant("")
   DECLARE dlup_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dlup_num = i4 WITH protect, noconstant(1)
   DECLARE dlup_idx = i2 WITH protect, noconstant(0)
   DECLARE dlup_choice = vc WITH protect, noconstant("")
   IF (size(dlup_users_for_pwd)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Loading users into record structure for password prompt."
    SET dm_err->emsg = "No user specified."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading users into record structure for password prompt."
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dlup_user != dlup_notfnd)
     SET dlup_user = piece(dlup_users_for_pwd,",",dlup_num,dlup_notfnd)
     SET dlup_num = (dlup_num+ 1)
     IF (dlup_user != dlup_notfnd)
      SET dlup_idx = locateval(dlup_idx,1,dir_db_users_pwds->cnt,dlup_user,dir_db_users_pwds->qual[
       dlup_idx].user)
      IF (dlup_idx=0)
       SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
       SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = dlup_user
       CALL clear(1,1)
       CALL text(6,2,concat("Please enter password for user ",dir_db_users_pwds->qual[
         dir_db_users_pwds->cnt].user,": "))
       CALL text(10,1,"Enter 'C' to continue or 'Q' to exit process. (C or Q): ")
       CALL accept(6,50,"P(30);C"," "
        WHERE  NOT (curaccept=" "))
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = build(curaccept)
       CALL accept(10,60,"A;cu"," "
        WHERE curaccept IN ("Q", "C"))
       SET dlup_choice = curaccept
       IF (dlup_choice="Q")
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "User quit process.  "
        SET dm_err->eproc = "Prompting for database user password."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_db_users_pwds)
   ENDIF
   IF ((dir_db_users_pwds->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user/password list."
    SET dm_err->emsg = "Database user/password not loaded into memory."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_adm_appl_status(dgaps_dblink,dgaps_audsid,dgaps_status)
   SET dgaps_status = "ACTIVE"
   IF (cnvtupper(dgaps_audsid)="-15301")
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM (value(concat("GV$SESSION@",dgaps_dblink)) s)
    WHERE s.audsid=cnvtint(dgaps_audsid)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine dir_get_adm_appl_status")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM (value(concat("V$SESSION@",dgaps_dblink)) s)
     WHERE s.audsid=cnvtint(dgaps_audsid)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine dir_get_adm_appl_status")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dgaps_status = "INACTIVE"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_upd_adm_upgrade_info(null)
   DECLARE duaui_schema_date = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Deleting from dm_info for dm_ocd_setup_admin."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (dcfr_sea_csv_files(cnvtlower(trim(logical("cer_install"),3)),"dm2a",duaui_schema_date)=0)
    RETURN(0)
   ELSE
    IF (duaui_schema_date="01-JAN-1800")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Schema Date: ",duaui_schema_date))
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting schema_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "SCHEMA_DATE", di.info_char =
     duaui_schema_date,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm_ocd_setup_admin_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM_OCD_SETUP_ADMIN_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_create_system_defs_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_CREATE_SYSTEM_DEFS_DATE",
     di.info_char = format(dm_ocd_setup_admin_data->dm2_create_system_defs,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_set_adm_cbo_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_SET_ADM_CBO_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm2_set_adm_cbo,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_custom_constraints(null)
   DECLARE dgcc_constraint_index = i2 WITH protect, noconstant(0)
   SET dir_custom_constraints->con_cnt = 0
   SET stat = initrec(dir_custom_constraints)
   SET dm_err->eproc = "Retrieving custom constraints"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_CUSTOM_CONSTRAINTS"
    DETAIL
     dgcc_constraint_index = (dgcc_constraint_index+ 1)
     IF (mod(dgcc_constraint_index,10)=1)
      stat = alterlist(dir_custom_constraints->con,(dgcc_constraint_index+ 9))
     ENDIF
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_custom_constraints->con,dgcc_constraint_index), dir_custom_constraints->
     con_cnt = dgcc_constraint_index
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcc_constraint_index=0)
    SET stat = alterlist(dir_custom_constraints->con,2)
    SET dir_custom_constraints->con[1].constraint_name = "CUCIM_ACQUIRED_STUDY"
    SET dir_custom_constraints->con[2].constraint_name = "CUCIM_SERIES"
    SET dir_custom_constraints->con_cnt = 2
   ELSE
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_ACQUIRED_STUDY",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_ACQUIRED_STUDY"
    ENDIF
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_SERIES",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_SERIES"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_admin_db_link(dgadl_report_fail_ind,dgadl_admin_db_link,dgadl_fail_ind)
   DECLARE dgadl_admin_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgadl_admin_link_match = i2 WITH protect, noconstant(0)
   SET dgadl_fail_ind = 0
   SET dm_err->eproc = "Obtain Admin database link name"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_environment de,
     dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
     AND de.environment_id=di.info_number
    DETAIL
     dgadl_admin_db_link = de.admin_dbase_link_name, dgadl_admin_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (textlen(dgadl_admin_db_link)=0)
    SET dgadl_fail_ind = 1
    IF (dgadl_report_fail_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Admin database link is not valued in DM_ENVIRONMENT.admin_dbase_link_name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dgadl_fail_ind=0)
    SET dm_err->eproc = "Validate Admin database link name"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (parser(concat("cdba.dm_environment@",dgadl_admin_db_link)) de)
     WHERE de.environment_id=dgadl_admin_env_id
     DETAIL
      IF (cnvtupper(dgadl_admin_db_link)=cnvtupper(de.admin_dbase_link_name))
       dgadl_admin_link_match = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 0
    ENDIF
    IF (dgadl_admin_link_match=0)
     SET dgadl_fail_ind = 1
     IF (dgadl_report_fail_ind=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Admin database link does not exist in database or is causing data inconsistency when used."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (validate(dguc_reply->rs_tbl_cnt,0)=0)
  IF ( NOT (validate(dguc_request,0)))
   FREE RECORD dguc_request
   RECORD dguc_request(
     1 what_tables = vc
     1 is_ref_ind = i2
     1 is_mrg_ind = i2
     1 only_special_ind = i2
     1 current_remote_db = i2
     1 local_tables_ind = i2
     1 db_link = vc
     1 req_special[*]
       2 sp_tbl = vc
   )
  ENDIF
  IF ( NOT (validate(dguc_reply,0)))
   FREE RECORD dguc_reply
   RECORD dguc_reply(
     1 rs_tbl_cnt = i4
     1 dguc_err_ind = i2
     1 dguc_err_msg = vc
     1 dtd_hold[*]
       2 tbl_name = vc
       2 tbl_suffix = vc
       2 pk_cnt = i4
       2 pk_hold[*]
         3 pk_datatype = vc
         3 pk_name = vc
   )
  ENDIF
 ENDIF
 IF (validate(derg_request->env_id,- (1)) < 0)
  FREE RECORD derg_request
  RECORD derg_request(
    1 env_id = f8
    1 relationship_type = vc
  )
 ENDIF
 IF (validate(derg_reply->err_num,- (1)) < 0)
  FREE RECORD derg_reply
  RECORD derg_reply(
    1 parent_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 child_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 err_num = i4
    1 err_msg = vc
  )
 ENDIF
 DECLARE cl_parse_cnt = i4
 SET cl_parse_cnt = 0
 IF (validate(dm2_cl_trg_rec->refchg_context_chk,"NO")="NO")
  FREE RECORD dm2_cl_trg_rec
  RECORD dm2_cl_trg_rec(
    1 refchg_context_chk = vc
    1 refchg_mvr_context_chk = vc
  )
  SET dm2_cl_trg_rec->refchg_context_chk =
  "(NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG'),'DM2NULLVAL')!='NEVER-SET')"
  SET dm2_cl_trg_rec->refchg_mvr_context_chk = concat(
   "((NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'DM2NULLVAL')!='NEVER-SET')AND ",
   "(NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'DM2NULLVAL')!=to_char(envid_tbl(ct))))")
 ENDIF
 IF ((validate(dm2_cl_trg_updt_cols->tbl_cnt,- (1))=- (1)))
  IF ((validate(dm2_cl_trg_updt_cols->tbl_cnt,- (5))=- (5)))
   FREE RECORD dm2_cl_trg_updt_cols
   RECORD dm2_cl_trg_updt_cols(
     1 tbl_cnt = i4
     1 qual[*]
       2 tname = vc
       2 updt_task_exist_ind = i2
       2 updt_id_exist_ind = i2
       2 updt_applctx_exist_ind = i2
   )
  ENDIF
 ENDIF
 IF ((validate(cl_hold_buff->bg_err,- (1))=- (1)))
  FREE RECORD cl_hold_buffer
  RECORD cl_hold_buffer(
    1 bg_err = i2
    1 bg_hold[*]
      2 bg_buffer = vc
  )
 ENDIF
 IF ( NOT (validate(dcltr_circ)))
  FREE RECORD dcltr_circ
  RECORD dcltr_circ(
    1 tbl_cnt = i4
    1 tbl_qual[*]
      2 table_name = vc
      2 pk_col = vc
      2 circ_cnt = i4
      2 circ_qual[*]
        3 circ_tab = vc
        3 circ_id_col = vc
        3 circ_name_col = vc
        3 circ_exist_ind = i2
        3 circ_r_tab = vc
        3 fk_name_col = vc
        3 fk_id_col = vc
        3 fk_exist_ind = i2
  )
 ENDIF
 DECLARE refchg_trg_bld_std_when(s_rtbsw_trigger_type=vc,s_rtbsw_br_flg=i2,s_rtbsw_updt_task_exist=i2,
  s_rtbsw_flex=vc) = i2 WITH public
 DECLARE cl_push(p_text=vc) = null WITH public
 DECLARE dm2_trg_updt_cols_check(s_table_name=vc) = i2 WITH public
 DECLARE dm2_cl_trg_updt_cols(s_ctuc_tname=vc) = i2 WITH public
 DECLARE rc_push(p_text=vc) = null WITH public
 DECLARE flex_push(rc_cl_flex=vc,flex_text=vc) = null WITH public
 DECLARE binsearch_refchg(i_key=vc) = i4 WITH public
 DECLARE dcltr_get_circ_tab(dgct_table_name=vc) = i2
 SUBROUTINE refchg_trg_bld_std_when(s_rtbsw_trigger_type,s_rtbsw_br_flg,s_rtbsw_updt_task_exist,
  s_rtbsw_flex)
   DECLARE s_rtbsw_return_int = i2
   SET s_rtbsw_return_int = 1
   IF (currdb="ORACLE")
    CALL flex_push(s_rtbsw_flex,concat('ASIS(" when ( ',dm2_cl_trg_rec->refchg_context_chk,'")'))
    IF (s_rtbsw_trigger_type IN ("UPD", "ADD")
     AND s_rtbsw_updt_task_exist=1)
     CALL flex_push(s_rtbsw_flex,concat('ASIS(" and new.updt_task not in ( 15301)")'))
    ENDIF
    IF (s_rtbsw_br_flg=1)
     CALL flex_push(s_rtbsw_flex,concat('ASIS(" and ( ',dm2_cl_trg_rec->refchg_mvr_context_chk,'")'))
    ENDIF
   ENDIF
   RETURN(s_rtbsw_return_int)
 END ;Subroutine
 SUBROUTINE cl_push(p_text)
   SET cl_parse_cnt = (cl_parse_cnt+ 1)
   IF (mod(cl_parse_cnt,100)=1)
    SET stat = alterlist(cl_hold_buffer->bg_hold,(cl_parse_cnt+ 99))
   ENDIF
   SET cl_hold_buffer->bg_hold[cl_parse_cnt].bg_buffer = p_text
 END ;Subroutine
 SUBROUTINE rc_push(p_text)
   SET rc_parse_cnt = (rc_parse_cnt+ 1)
   IF (mod(rc_parse_cnt,100)=1)
    SET stat = alterlist(rc_hold_buffer->bg_hold,(rc_parse_cnt+ 99))
   ENDIF
   SET rc_hold_buffer->bg_hold[rc_parse_cnt].bg_buffer = p_text
 END ;Subroutine
 SUBROUTINE flex_push(rc_cl_flex,flex_text)
   IF (rc_cl_flex="RC")
    CALL rc_push(flex_text)
   ELSEIF (rc_cl_flex="CL")
    CALL cl_push(flex_text)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_trg_updt_cols_check(s_table_name)
   SET dm2_cl_trg_updt_cols->tbl_cnt = (dm2_cl_trg_updt_cols->tbl_cnt+ 1)
   SET stat = alterlist(dm2_cl_trg_updt_cols->qual,dm2_cl_trg_updt_cols->tbl_cnt)
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].tname = s_table_name
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 0
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 0
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 0
   SELECT INTO "nl:"
    FROM dtableattr dta,
     dtableattrl dtal
    PLAN (dta
     WHERE dta.table_name=s_table_name)
     JOIN (dtal
     WHERE dtal.structtype="F"
      AND btest(dtal.stat,11)=0
      AND dtal.attr_name IN ("UPDT_TASK", "UPDT_ID", "UPDT_APPLCTX"))
    DETAIL
     IF (dtal.attr_name="UPDT_TASK")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 1
     ELSEIF (dtal.attr_name="UPDT_ID")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 1
     ELSEIF (dtal.attr_name="UPDT_APPLCTX")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_cl_trg_updt_cols(s_ctuc_tname)
   DECLARE s_dctuc_return_int = i2
   DECLARE s_where_str = vc
   SET dm2_cl_trg_updt_cols->tbl_cnt = 0
   SET s_dctuc_return_int = 0
   SET stat = alterlist(dm2_cl_trg_updt_cols->qual,0)
   IF (s_ctuc_tname=char(42))
    SET s_where_str = "1=1"
   ELSE
    SET s_where_str = "ut.table_name = patstring(s_ctuc_tname)"
   ENDIF
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name IN (
    (SELECT
     ut.table_name
     FROM user_tables ut
     WHERE parser(s_where_str)))
    ORDER BY utc.table_name
    HEAD REPORT
     stat = alterlist(dm2_cl_trg_updt_cols->qual,10)
    HEAD utc.table_name
     dm2_cl_trg_updt_cols->tbl_cnt = (dm2_cl_trg_updt_cols->tbl_cnt+ 1)
     IF (mod(dm2_cl_trg_updt_cols->tbl_cnt,10)=1
      AND (dm2_cl_trg_updt_cols->tbl_cnt != 1))
      stat = alterlist(dm2_cl_trg_updt_cols->qual,(dm2_cl_trg_updt_cols->tbl_cnt+ 9))
     ENDIF
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].tname = utc.table_name,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 0,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 0,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 0
    DETAIL
     IF (utc.column_name="UPDT_TASK")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_ID")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_APPLCTX")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_cl_trg_updt_cols->qual,dm2_cl_trg_updt_cols->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=0)
    IF ((dm_err->debug_flag != 0))
     CALL echo(concat("Obtained column information for: ",cnvtstring(dm2_cl_trg_updt_cols->tbl_cnt),
       " table/s"))
    ENDIF
    RETURN(s_dctuc_return_int)
   ELSE
    SET s_dctuc_return_int = 1
   ENDIF
   RETURN(s_dctuc_return_int)
 END ;Subroutine
 SUBROUTINE binsearch_refchg(i_key)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   SET v_high = size(refchg_tab_r->child,5)
   IF (v_high > 0)
    WHILE (((v_high - v_low) > 1))
     SET v_mid = cnvtint(((v_high+ v_low)/ 2))
     IF ((i_key <= refchg_tab_r->child[v_mid].child_table))
      SET v_high = v_mid
     ELSE
      SET v_low = v_mid
     ENDIF
    ENDWHILE
    IF (trim(i_key,3)=trim(refchg_tab_r->child[v_high].child_table,3))
     RETURN(v_high)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dcltr_get_circ_tab(dgct_table_name)
   DECLARE dgct_info_name = vc WITH protect, noconstant(" ")
   DECLARE dgct_temp = vc WITH protect, noconstant(" ")
   DECLARE dgct_idx = i4 WITH protect, noconstant(0)
   DECLARE dgct_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgct_col_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dgct_start = i4 WITH protect, noconstant(0)
   DECLARE dgct_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgct_temp2 = vc WITH protect, noconstant(" ")
   DECLARE dgct_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dgct_temp_tab = vc WITH protect, noconstant(" ")
   DECLARE dgct_num = i4 WITH protect, noconstant(0)
   FREE RECORD dgct_tabs
   RECORD dgct_tabs(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 suffix = vc
       2 r_table_name = vc
       2 val_table_name = vc
       2 exist_ind = i2
   )
   SET dgct_info_name = concat(dgct_table_name,":*")
   SET dgct_start = (dcltr_circ->tbl_cnt+ 1)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS 7 CIRCULAR:*"
     AND di.info_name=patstring(dgct_info_name)
    ORDER BY di.info_name
    HEAD di.info_name
     dgct_col_pos = findstring(":",di.info_name), dgct_temp = substring(1,(dgct_col_pos - 1),di
      .info_name), dgct_idx = locateval(dgct_idx,1,dcltr_circ->tbl_cnt,dgct_temp,dcltr_circ->
      tbl_qual[dgct_idx].table_name)
     IF (dgct_idx=0)
      dcltr_circ->tbl_cnt = (dcltr_circ->tbl_cnt+ 1), stat = alterlist(dcltr_circ->tbl_qual,
       dcltr_circ->tbl_cnt), dgct_idx = dcltr_circ->tbl_cnt,
      dcltr_circ->tbl_qual[dgct_idx].table_name = dgct_temp
     ENDIF
    DETAIL
     dgct_col_pos = findstring(":",di.info_domain), dgct_col_pos2 = findstring(":",di.info_domain,(
      dgct_col_pos+ 1)), dgct_temp = substring((dgct_col_pos+ 1),((dgct_col_pos2 - dgct_col_pos) - 1),
      di.info_domain),
     dgct_temp2 = substring((dgct_col_pos2+ 1),30,di.info_domain), dgct_tab_pos = locateval(
      dgct_tab_pos,1,dgct_tabs->cnt,dgct_temp,dgct_tabs->qual[dgct_tab_pos].table_name,
      dgct_temp2,dgct_tabs->qual[dgct_tab_pos].column_name)
     IF (dgct_tab_pos=0)
      dgct_tabs->cnt = (dgct_tabs->cnt+ 1), stat = alterlist(dgct_tabs->qual,dgct_tabs->cnt),
      dgct_tabs->qual[dgct_tabs->cnt].table_name = dgct_temp,
      dgct_tabs->qual[dgct_tabs->cnt].column_name = dgct_temp2, dgct_tabs->qual[dgct_tabs->cnt].
      val_table_name = dgct_tabs->qual[dgct_tabs->cnt].table_name
     ENDIF
     dgct_cnt = locateval(dgct_cnt,1,dcltr_circ->tbl_qual[dgct_idx].circ_cnt,dgct_temp,dcltr_circ->
      tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_tab,
      dgct_temp2,dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_id_col)
     IF (dgct_cnt=0)
      dcltr_circ->tbl_qual[dgct_idx].circ_cnt = (dcltr_circ->tbl_qual[dgct_idx].circ_cnt+ 1),
      dgct_cnt = dcltr_circ->tbl_qual[dgct_idx].circ_cnt, stat = alterlist(dcltr_circ->tbl_qual[
       dgct_idx].circ_qual,dgct_cnt),
      dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_tab = dgct_temp, dcltr_circ->tbl_qual[
      dgct_idx].circ_qual[dgct_cnt].circ_id_col = dgct_temp2, dcltr_circ->tbl_qual[dgct_idx].
      circ_qual[dgct_cnt].circ_name_col = di.info_char,
      dgct_col_pos = findstring(":",di.info_name,1), dgct_col_pos2 = findstring(":",di.info_name,(
       dgct_col_pos+ 1))
      IF (dgct_col_pos2 > 0)
       dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_id_col = substring((dgct_col_pos+ 1),((
        dgct_col_pos2 - dgct_col_pos) - 1),di.info_name), dcltr_circ->tbl_qual[dgct_idx].circ_qual[
       dgct_cnt].fk_name_col = substring((dgct_col_pos2+ 1),(size(trim(di.info_name)) - dgct_col_pos2
        ),di.info_name)
      ELSE
       dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_id_col = substring((dgct_col_pos+ 1),(
        size(trim(di.info_name)) - dgct_col_pos),di.info_name)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_tables_doc_local d
    WHERE expand(dgct_cnt,1,dgct_tabs->cnt,d.table_name,dgct_tabs->qual[dgct_cnt].table_name)
     AND d.table_name=d.full_table_name
    DETAIL
     FOR (dgct_idx = 1 TO dgct_tabs->cnt)
       IF ((d.table_name=dgct_tabs->qual[dgct_idx].table_name))
        dgct_tabs->qual[dgct_idx].suffix = d.table_suffix
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   FOR (dgct_idx = 1 TO dgct_tabs->cnt)
     SET dgct_tabs->qual[dgct_idx].r_table_name = cutover_tab_name(dgct_tabs->qual[dgct_idx].
      table_name,dgct_tabs->qual[dgct_idx].suffix)
   ENDFOR
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE expand(dgct_cnt,1,dgct_tabs->cnt,ut.table_name,dgct_tabs->qual[dgct_cnt].r_table_name)
    DETAIL
     FOR (dgct_idx = 1 TO dgct_tabs->cnt)
       IF ((ut.table_name=dgct_tabs->qual[dgct_idx].r_table_name))
        dgct_tabs->qual[dgct_idx].val_table_name = ut.table_name
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE expand(dgct_num,1,dgct_tabs->cnt,utc.table_name,dgct_tabs->qual[dgct_num].val_table_name,
     utc.column_name,dgct_tabs->qual[dgct_num].column_name)
    DETAIL
     dgct_cnt = locateval(dgct_cnt,1,dgct_tabs->cnt,utc.table_name,dgct_tabs->qual[dgct_cnt].
      val_table_name,
      utc.column_name,dgct_tabs->qual[dgct_cnt].column_name), dgct_tabs->qual[dgct_cnt].exist_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   IF ((dcltr_circ->tbl_cnt >= dgct_start))
    SELECT INTO "nl:"
     FROM dm_columns_doc_local d
     WHERE expand(dgct_cnt,dgct_start,dcltr_circ->tbl_cnt,d.table_name,dcltr_circ->tbl_qual[dgct_cnt]
      .table_name)
      AND d.table_name=d.root_entity_name
      AND d.column_name=d.root_entity_attr
      AND  EXISTS (
     (SELECT
      "x"
      FROM user_tab_columns u
      WHERE u.table_name=d.table_name
       AND u.column_name=d.column_name))
     DETAIL
      dgct_cnt = locateval(dgct_cnt,dgct_start,dcltr_circ->tbl_cnt,d.table_name,dcltr_circ->tbl_qual[
       dgct_cnt].table_name), dcltr_circ->tbl_qual[dgct_cnt].pk_col = d.column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(- (1))
    ENDIF
   ENDIF
   FOR (dgct_idx = dgct_start TO dcltr_circ->tbl_cnt)
     FOR (dgct_cnt = 1 TO dcltr_circ->tbl_qual[dgct_idx].circ_cnt)
       SET dgct_tab_pos = locateval(dgct_tab_pos,1,dgct_tabs->cnt,dcltr_circ->tbl_qual[dgct_idx].
        circ_qual[dgct_cnt].circ_tab,dgct_tabs->qual[dgct_tab_pos].table_name,
        dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_id_col,dgct_tabs->qual[dgct_tab_pos].
        column_name)
       SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_r_tab = dgct_tabs->qual[
       dgct_tab_pos].r_table_name
       SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_exist_ind = dgct_tabs->qual[
       dgct_tab_pos].exist_ind
       IF ((dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_name_col > " "))
        SELECT INTO "nl:"
         FROM user_tab_columns utc
         WHERE (utc.table_name=dcltr_circ->tbl_qual[dgct_idx].table_name)
          AND (utc.column_name=dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_name_col)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         RETURN(- (1))
        ELSEIF (curqual > 0)
         SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_exist_ind = 1
        ENDIF
       ELSE
        SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_exist_ind = 1
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 FREE RECORD dyn_ui_search
 RECORD dyn_ui_search(
   1 qual[*]
     2 pk_value = f8
     2 other = vc
 )
 IF (validate(drdm_sequence->qual[1].seq_val,- (1)) < 0)
  FREE RECORD drdm_sequence
  RECORD drdm_sequence(
    1 qual[*]
      2 seq_name = vc
      2 seq_val = f8
  )
 ENDIF
 IF (validate(dm2_rdds_rec->mode,"NONE")="NONE")
  FREE RECORD dm2_rdds_rec
  RECORD dm2_rdds_rec(
    1 mode = vc
    1 main_process = vc
  )
 ENDIF
 IF (validate(ui_query_rec->table_name,"NONE")="NONE")
  FREE RECORD ui_query_rec
  RECORD ui_query_rec(
    1 table_name = vc
    1 dom = vc
    1 usage = vc
    1 qual[*]
      2 qtype = vc
      2 where_clause = vc
      2 cqual[*]
        3 query_idx = i2
      2 other_pk_col[*]
        3 col_name = vc
  )
  FREE RECORD ui_query_eval_rec
  RECORD ui_query_eval_rec(
    1 qual[*]
      2 root_entity_attr = f8
      2 additional_attr = vc
  )
 ENDIF
 IF (validate(select_merge_translate_rec->type,"NONE")="NONE")
  FREE RECORD select_merge_translate_rec
  RECORD select_merge_translate_rec(
    1 type = vc
  )
 ENDIF
 DECLARE find_p_e_col(sbr_p_e_name=vc,sbr_p_e_col=i4) = vc
 DECLARE dm_translate(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc) = vc
 DECLARE dm_trans2(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc,sbr_src_ind=i2) = vc
 DECLARE dm_trans3(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=f8,sbr_src_ind=i2,sbr_pe_tbl_name=vc)
  = vc
 DECLARE insert_update_row(iur_temp_tbl_cnt=i4,iur_perm_col_cnt=i4) = i2
 DECLARE query_target(qt_temp_tbl_cnt=i4,qt_perm_col_cnt=i4) = f8 WITH public
 DECLARE merge_audit(action=vc,text=vc,audit_type=i4) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE del_chg_log(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE report_missing(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = vc
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE version_exception(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = null
 DECLARE orphan_child_tab(sbr_table_name=vc,sbr_log_type=vc) = i2
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE exec_ui_query(exec_tbl_cnt=i4,exec_perm_col_cnt=i4) = f8 WITH public
 DECLARE evaluate_exec_ui_query(sbr_current_qual=i4,eval_tbl_cnt=i4,eval_perm_col_cnt=i4) = f8 WITH
 public
 DECLARE insert_noxlat(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8,sbr_orphan_ind=i2) = i2
 DECLARE add_rs_values(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = i4
 DECLARE trigger_proc_call(tpc_table_name=vc,tpc_pk_where=vc,tpc_context=vc,tpc_col_name=vc,tpc_value
  =f8) = i2
 DECLARE filter_proc_call(fpc_table_name=vc,fpc_pk_where=vc) = i2
 DECLARE replace_carrot_symbol(rcs_string=vc) = vc
 SUBROUTINE query_target(qt_temp_tbl_cnt,qt_perm_col_cnt)
   DECLARE sbr_active_value = i2
   DECLARE sbr_effective_date = f8
   DECLARE sbr_end_effective_date = f8
   DECLARE sbr_returned_value = f8
   DECLARE sbr_cur_date = f8
   DECLARE sbr_rec_size = i4
   DECLARE sbr_null_beg_ind = i2
   DECLARE sbr_null_end_ind = i2
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET drdm_return_var = 0
   IF ((dm2_ref_data_doc->tbl_qual[qt_temp_tbl_cnt].merge_delete_ind=1))
    RETURN(- (3))
   ELSE
    SET dm_err->eproc = "Query Target"
    CALL echo("")
    CALL echo("")
    CALL echo("*******************QUERY TARGET***************************")
    CALL echo("")
    CALL echo("")
    SET sbr_rec_size = 1
    SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
    SET ui_query_rec->table_name = sbr_table_name
    SET ui_query_rec->usage = ""
    SET ui_query_rec->dom = "TO"
    SET ui_query_rec->qual[sbr_rec_size].qtype = "UIONLY"
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1))
     SET sbr_rec_size = (sbr_rec_size+ 1)
     SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
     SET sbr_active_value = cnvtreal(get_value(sbr_table_name,"ACTIVE_IND","FROM"))
     IF (sbr_active_value=1)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "ACTIVE"
     ELSE
      SET ui_query_rec->qual[sbr_rec_size].qtype = "INACTIVE"
     ENDIF
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
     SET sbr_null_beg_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      beg_col_name)
     SET sbr_null_end_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      end_col_name)
     IF (((sbr_null_beg_ind=1) OR (sbr_null_end_ind=1)) )
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind = 0
     ELSE
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      CALL parser(concat("set sbr_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name," go "),1)
      CALL parser(concat("set sbr_end_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name," go "),1)
      IF (sbr_effective_date <= sbr_cur_date
       AND sbr_end_effective_date >= sbr_cur_date)
       SET ui_query_rec->qual[sbr_rec_size].qtype = "EFFECTIVE"
      ELSE
       SET ui_query_rec->qual[sbr_rec_size].qtype = "END_EFFECTIVE"
      ENDIF
     ENDIF
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "COMBO"
      SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].cqual,2)
      SET ui_query_rec->qual[sbr_rec_size].cqual[1].query_idx = 2
      SET ui_query_rec->qual[sbr_rec_size].cqual[2].query_idx = 3
     ENDIF
    ENDIF
    SET sbr_returned_value = exec_ui_query(qt_temp_tbl_cnt,qt_perm_col_cnt)
    SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].other_pk_col,0)
    RETURN(sbr_returned_value)
   ENDIF
 END ;Subroutine
 SUBROUTINE exec_ui_query(exec_tbl_cnt,exec_perm_col_cnt)
   DECLARE sbr_while_loop = i2
   DECLARE sbr_done_select = i2
   DECLARE sbr_loop = i2
   DECLARE sbr_other_loop = i2
   DECLARE query_cnt = i4
   DECLARE sbr_eff_date = f8
   DECLARE sbr_end_eff_date = f8
   DECLARE sbr_cur_date = f8
   DECLARE query_return = f8
   DECLARE rs_tab_prefix = vc
   DECLARE sbr_domain = vc
   DECLARE add_ndx = i4
   DECLARE ndx_loop = i4
   DECLARE add_col_name = vc
   DECLARE add_d_type = vc
   DECLARE euq_ord_col = vc
   SET rs_tab_prefix = concat("RS_",dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].suffix)
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET euq_ord_col = ""
   FOR (sbr_loop = 1 TO size(ui_query_eval_rec->qual,5))
     SET ui_query_eval_rec->qual[sbr_loop].additional_attr = ""
   ENDFOR
   SET sbr_loop = 1
   SET sbr_done_select = 0
   IF ((ui_query_rec->dom="FROM"))
    SET sbr_domain = "FROM"
   ELSE
    SET sbr_domain = "TO"
   ENDIF
   WHILE (sbr_loop <= size(ui_query_rec->qual,5)
    AND sbr_done_select=0)
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET query_cnt = 0
     IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].merge_ui_query_ni=1))
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[1].frag = concat("select into 'NL:' dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
      ELSE
       SET drdm_parser->statement[1].frag = "select into 'NL:' "
      ENDIF
      SET drdm_parser->statement[2].frag = concat(" from ",value(ui_query_rec->table_name)," dc ",
       " where ")
      SET drdm_parser_cnt = 3
      FOR (drdm_loop_cnt = 1 TO exec_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].unique_ident_ind=1))
         SET no_unique_ident = 1
         IF (drdm_parser_cnt > 3)
          SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ENDIF
         SET drdm_col_name = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].
         column_name
         SET drdm_from_con = concat(rs_tab_prefix,"->",sbr_domain,"_values.",drdm_col_name)
         IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_null=1))
          IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type IN ("DQ8",
          "F8", "I4", "I2")))
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = NULL")
          ELSE
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
            " = null or ",drdm_col_name," = ' ')")
          ENDIF
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSEIF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_space=1))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
           " = ' ' or ",drdm_col_name," = null)")
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSE
          CASE (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type)
           OF "DQ8":
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
             " =  cnvtdatetime(",drdm_from_con,")")
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ELSE
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
             drdm_from_con)
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          ENDCASE
         ENDIF
        ENDIF
      ENDFOR
      IF (no_unique_ident=0)
       SET insert_update_reason = "There were no unique_ident_ind's for log_id "
       SET no_insert_update = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = concat(dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].
        custom_script,": There were no unique_ident_ind's")
       RETURN(- (2))
      ENDIF
      SET sbr_current_date = cnvtdatetime(curdate,curtime3)
      CASE (ui_query_rec->qual[sbr_loop].qtype)
       OF "UIONLY":
       OF patstring("ORDER*",0):
        SET ui_query_rec->qual[sbr_loop].where_clause = ""
       OF "ACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 1"
       OF "INACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 0"
       OF "EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,"<=  cnvtdatetime(sbr_cur_date) AND dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,">= cnvtdatetime(sbr_cur_date)")
       OF "END_EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,">=  cnvtdatetime(sbr_cur_date) OR dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,"<= cnvtdatetime(sbr_cur_date)")
       OF "COMBO":
        FOR (sbr_other_loop = 1 TO size(ui_query_rec->qual[sbr_loop].cqual,5))
          SET ui_query_rec->qual[sbr_loop].where_clause = concat(ui_query_rec->qual[sbr_loop].
           where_clause,ui_query_rec->qual[ui_query_rec->qual[sbr_loop].cqual[sbr_other_loop].
           query_idx].where_clause)
        ENDFOR
      ENDCASE
      IF ((ui_query_rec->qual[sbr_loop].where_clause != ""))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(ui_query_rec->qual[sbr_loop].
        where_clause)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF ((ui_query_rec->qual[sbr_loop].qtype="ORDER:*"))
       SET euq_ord_col = substring((findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)+ 1),(size(
         ui_query_rec->qual[sbr_loop].qtype) - findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)
        ),ui_query_rec->qual[sbr_loop].qtype)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ORDER BY dc.",euq_ord_col)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" head report",
       " stat = alterlist(ui_query_eval_rec->qual, 10)"," query_cnt = 0")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" detail query_cnt = query_cnt + 1 ")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "if (mod(query_cnt,10) = 1 and query_cnt != 1)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt + 9)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" endif")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
        "ui_query_eval_rec->qual[query_cnt]->root_entity_attr = dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF (size(ui_query_rec->qual[sbr_loop].other_pk_col,5) > 0)
       IF ((ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name != ""))
        SET add_col_name = ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name
        SET add_ndx = locateval(ndx_loop,1,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_cnt,
         add_col_name,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[ndx_loop].column_name)
        IF (add_ndx > 0)
         SET add_d_type = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[add_ndx].data_type
         IF ( NOT (add_d_type IN ("VC", "C*")))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = cnvtstring(dc.",add_col_name,")")
         ELSE
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = dc.",add_col_name)
         ENDIF
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" foot report",
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt)"," with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET query_return = - (1)
       SET sbr_done_select = 1
      ELSEIF ((query_return != - (1)))
       SET query_return = evaluate_exec_ui_query(query_cnt,exec_tbl_cnt,exec_perm_col_cnt)
      ENDIF
      IF ((((query_return=- (3))) OR (query_return >= 0)) )
       SET sbr_done_select = 1
      ELSE
       SET sbr_loop = (sbr_loop+ 1)
      ENDIF
     ENDIF
   ENDWHILE
   IF ((query_return=- (2))
    AND (ui_query_rec->usage != "VERSION"))
    SET insert_update_reason = "Multiple values returned with unique indicator query for log_id "
    SET no_insert_update = 1
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "NOMV06"
    SET drdm_mini_loop_status = "NOMV06"
    ROLLBACK
    CALL orphan_child_tab(sbr_table_name,"NOMV06")
    COMMIT
   ENDIF
   RETURN(query_return)
 END ;Subroutine
 SUBROUTINE evaluate_exec_ui_query(sbr_current_qual,eval_tbl_cnt,eval_perm_col_cnt)
   DECLARE sbr_eval_loop = i4
   DECLARE sbr_trans_val = vc
   DECLARE sbr_table_name = vc
   DECLARE sbr_root_entity_attr_val = f8
   DECLARE sbr_not_translated_count = i4
   DECLARE sbr_value_pos = i4
   DECLARE sbr_temp_pk_value = f8
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET sbr_eval_loop = 1
   SET sbr_not_translated_count = 0
   IF (sbr_current_qual=0)
    RETURN(- (3))
   ELSEIF (sbr_current_qual=1)
    IF ((((ui_query_rec->usage="VERSION")
     AND sbr_temp_pk_value != 0) OR ((ui_query_rec->usage != "VERSION"))) )
     SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
     SET select_merge_translate_rec->type = "TO"
     SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_trans_val="No Trans")
      SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
      RETURN(sbr_root_entity_attr_val)
     ELSE
      IF ((ui_query_rec->usage="VERSION"))
       SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
       RETURN(sbr_root_entity_attr_val)
      ELSE
       RETURN(- (3))
      ENDIF
     ENDIF
    ELSE
     SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
     RETURN(sbr_root_entity_attr_val)
    ENDIF
   ELSE
    IF ((ui_query_rec->usage="VERSION"))
     RETURN(- (2))
    ELSE
     FOR (sbr_eval_loop = 1 TO sbr_current_qual)
       SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
       SET select_merge_translate_rec->type = "TO"
       SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
       IF (sbr_trans_val="No Trans")
        SET sbr_not_translated_count = (sbr_not_translated_count+ 1)
        SET sbr_val_pos = sbr_eval_loop
       ENDIF
     ENDFOR
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_not_translated_count=0)
      RETURN(- (3))
     ELSEIF (sbr_not_translated_count=1)
      SET current_qual = ui_query_eval_rec->qual[sbr_val_pos].root_entity_attr
      RETURN(current_qual)
     ELSE
      RETURN(- (2))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_update_row(iur_temp_tbl_cnt,iur_perm_col_cnt)
   DECLARE first_where = i2
   DECLARE active_in = i2
   DECLARE drdm_col_name = vc
   DECLARE drdm_table_name = vc
   DECLARE p_tab_ind = i2
   DECLARE sbr_data_type = vc
   DECLARE no_update_ind = i2
   DECLARE non_key_ind = i2
   DECLARE pk_cnt = i4
   DECLARE iur_tgt_pk_where = vc
   DECLARE iur_del_loop = i4
   DECLARE iur_del_ind = i2
   DECLARE iur_child_loop = i4
   DECLARE iur_child_pk_cnt = i4
   DECLARE src_pk_where = vc
   DECLARE iur_tbl_alias = vc
   SET iur_del_ind = 0
   SET drdm_table_name = concat("RS_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)
   SET dm_err->eproc = concat("Inserting or Updating Row ",cnvtstring(drdm_chg->log[drdm_log_loop].
     log_id))
   CALL echo("")
   CALL echo("")
   CALL echo("*******************INSERTING OR UPDATING ROW******************")
   CALL echo("")
   CALL echo("")
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1)
    AND (drdm_chg->log[drdm_log_loop].md_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," in (select ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          SET iur_child_pk_cnt = (iur_child_pk_cnt+ 1)
          IF (iur_child_pk_cnt=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" c.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name)
          ENDIF
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].table_name," c where ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1)
         )
          IF (iur_del_ind=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
            "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
            column_name,
            "))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
            suffix,"->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop]
            .column_name,
            ")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = 1
         ENDIF
       ENDFOR
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
           tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = ") with nocounter go"
       IF (iur_del_ind=1
        AND iur_child_pk_cnt=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
     SET iur_child_pk_cnt = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   SET iur_del_ind = 0
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," = ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          IF (iur_del_ind >= 1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,"))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,notrim(rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = (iur_del_ind+ 1)
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = " with nocounter go"
       IF (iur_del_ind=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   IF (nodelete_ind=1)
    RETURN(1)
   ENDIF
   SET p_tab_ind = 0
   SET first_where = 0
   SET no_update_ind = 0
   SET short_string = ""
   SET drdm_parser->statement[1].frag = concat("select into 'NL:' from ",value(dm2_ref_data_doc->
     tbl_qual[iur_temp_tbl_cnt].table_name)," dc where ")
   SET drdm_parser_cnt = 2
   IF ((((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0)) OR ((dm2_ref_data_doc->
   tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))) )
    SET pk_cnt = 0
    FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
       SET pk_cnt = (pk_cnt+ 1)
       SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
       data_type
       SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
        column_name)
       SET drdm_from_con = concat(drdm_table_name,"->To_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where," and ")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
        AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
        IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
          " = null or dc.",drdm_col_name," = ' ')")
        ENDIF
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF (sbr_data_type="DQ8")
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
         " = cnvtdatetime(",drdm_from_con,")")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
         " = null or dc.",drdm_col_name," = ' ')")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSE
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
         drdm_from_con)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ELSE
       SET non_key_ind = 1
      ENDIF
    ENDFOR
    IF (pk_cnt=0)
     SET nodelete_ind = 1
     SET dm_err->emsg = "The table has no primary_key information, check to see if it is mergeable."
    ELSE
     SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
     CALL parse_statements(drdm_parser_cnt)
    ENDIF
   ENDIF
   IF (curqual > 0
    AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].insert_only_ind=1))
     CALL merge_audit("FAILREASON",
      "This table is marked as insert only, so this row will not be updated.",3)
     RETURN(0)
    ELSE
     IF (new_seq_ind=1
      AND drdm_override_ind=0)
      SET no_update_ind = 1
      CALL merge_audit("FAILREASON",
       "A new sequence was created for the table, but the sequence value already exists in the target table",
       3)
      SET nodelete_ind = 1
      SET drdm_mini_loop_status = "NOMV99"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON4859"))
       IF (non_key_ind=1)
        SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].table_name,"  dc set ")
        SET drdm_parser_cnt = 2
        FOR (update_loop = 1 TO iur_perm_col_cnt)
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].db_data_type !=
          "*LOB"))
           IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].pk_ind=0))
            IF (drdm_parser_cnt > 2)
             SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
             SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
            ENDIF
            SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].
            column_name
            SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
            IF (drdm_col_name="ACTIVE_IND")
             IF (drdm_active_ind_merge=0)
              CALL parser(concat("set active_in = ",drdm_table_name,"->from_values.active_ind go"),1)
              IF (((active_in=0) OR ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[
              update_loop].exception_flg=8))) )
               IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
                AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y")
               )
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
               ELSE
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = active_in"
               ENDIF
              ELSE
               IF (((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt - pk_cnt)=1))
                SET no_update_ind = 1
               ELSE
                IF (drdm_parser_cnt=2)
                 SET drdm_parser_cnt = (drdm_parser_cnt - 1)
                ELSE
                 SET drdm_parser_cnt = (drdm_parser_cnt - 2)
                ENDIF
               ENDIF
              ENDIF
             ELSE
              IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
               AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
               SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
              ELSE
               SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.ACTIVE_IND = ",
                drdm_from_con)
              ENDIF
             ENDIF
            ELSEIF (drdm_col_name="UPDT_TASK")
             SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
            ELSEIF (drdm_col_name="UPDT_DT_TM")
             SET drdm_parser->statement[drdm_parser_cnt].frag =
             " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
            ELSEIF (drdm_col_name="UPDT_CNT")
             SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = dc.UPDT_CNT + 1"
            ELSE
             IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
              AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = null")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].data_type=
             "DQ8"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = cnvtdatetime(",drdm_from_con,")")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_space=
             1))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '"
               )
             ELSE
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
               drdm_from_con)
             ENDIF
            ENDIF
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ENDIF
          ENDIF
        ENDFOR
        IF (no_update_ind=0)
         SET drdm_parser->statement[drdm_parser_cnt].frag = " where "
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = iur_tgt_pk_where
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
        SET current_merges = (current_merges+ 1)
        SET child_merge_audit->num[current_merges].action = "UPDATE"
        SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt
        ].table_name
       ENDIF
       SET ins_ind = 0
      ELSE
       SET p_tab_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ins_ind = 1
    SET drdm_parser->statement[1].frag = concat("insert into ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," dc set ")
    SET drdm_parser_cnt = 2
    FOR (insert_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type != "*LOB")
      )
       SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].
       column_name
       SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF (drdm_col_name="UPDT_TASK")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
       ELSEIF (drdm_col_name="UPDT_DT_TM")
        SET drdm_parser->statement[drdm_parser_cnt].frag =
        " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
       ELSEIF (drdm_col_name="UPDT_CNT")
        SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = 0"
       ELSE
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_null=1)
         AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].nullable="Y"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null ")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].data_type="DQ8"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
          " = cnvtdatetime(",drdm_from_con,")")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_space=1))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
          drdm_from_con)
        ENDIF
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
    ENDFOR
    SET current_merges = (current_merges+ 1)
    SET child_merge_audit->num[current_merges].action = "INSERT"
    SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
    table_name
   ENDIF
   SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
   IF (p_tab_ind=0
    AND no_update_ind=0)
    IF (ins_ind=0
     AND non_key_ind=0)
     CALL echo("No update will be done on this table because there are no non-key columns")
    ELSE
     CALL parse_statements(drdm_parser_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))
      SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
       iur_temp_tbl_cnt].table_name," dc set ")
      SET drdm_parser_cnt = 2
      FOR (insert_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type="*LOB"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name," = (select ")
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ",dm2_rdds_get_tbl_alias(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix),".",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name)
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_get_rdds_tname(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name)," ",dm2_rdds_get_tbl_alias(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)," where ")
      SET iur_tbl_alias = concat(" ",dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].suffix))
      SET src_pk_where = " "
      SET pk_cnt = 0
      SET iur_perm_col_cnt = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt
      FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
         SET pk_cnt = (pk_cnt+ 1)
         SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
         data_type
         SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop
          ].column_name)
         SET drdm_from_con = concat(drdm_table_name,"->from_values.",drdm_col_name)
         IF (pk_cnt > 1)
          SET iur_tgt_pk_where = concat(src_pk_where," and ")
         ENDIF
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
          IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
           SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = null")
          ELSE
           SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
            " = null or ",iur_tbl_alias,".",drdm_col_name," = ' ')")
          ENDIF
         ELSEIF (sbr_data_type="DQ8")
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = cnvtdatetime(",
           drdm_from_con,")")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
          SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
           iur_tbl_alias,".",drdm_col_name," = ' ')")
         ELSE
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = ",
           drdm_from_con)
         ENDIF
        ENDIF
      ENDFOR
      IF (pk_cnt=0)
       SET nodelete_ind = 1
       SET dm_err->emsg =
       "The table has no primary_key information, check to see if it is mergeable."
       RETURN(1)
      ENDIF
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(src_pk_where,")")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" where ",iur_tgt_pk_where,
       " with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
     ENDIF
    ENDIF
   ENDIF
   FREE SET first_where
   FREE SET p_tab_ind
   FREE SET active_in
   FREE SET drdm_table_name
   IF (nodelete_ind=1)
    IF ((dm_err->ecode=288))
     SET drdm_mini_loop_status = "NOMV02"
     CALL merge_audit("FAILREASON","The row recieved a constraint violation when merged into target",
      1)
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV02")
     COMMIT
    ELSEIF ((dm_err->ecode=284))
     IF (findstring("ORA-20500:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV01"
      CALL merge_audit("FAILREASON","The row is related to a person that has been combined away",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV01")
      COMMIT
     ENDIF
     IF (findstring("ORA-20100:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV08"
      CALL merge_audit("FAILREASON","The row is trying to update the default row in target",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
      COMMIT
     ENDIF
    ENDIF
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm2_ref_data_reply->error_ind = 1
    RETURN(1)
   ELSE
    SET drdm_chg->log[drdm_log_loop].reprocess_ind = 0
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE parse_statements(drdm_parser_cnt)
   FOR (parse_loop = 1 TO drdm_parser_cnt)
     IF (parse_loop=drdm_parser_cnt)
      SET drdm_go_ind = 1
     ELSE
      SET drdm_go_ind = 0
     ENDIF
     IF ((drdm_parser->statement[parse_loop].frag=""))
      CALL echo("")
      CALL echo("")
      CALL echo("A DYNAMIC STATEMENT WAS IMPROPERLY LOADED")
      CALL echo("")
      CALL echo("")
     ENDIF
     CALL parser(drdm_parser->statement[parse_loop].frag,drdm_go_ind)
     SET drdm_parser->statement[parse_loop].frag = ""
     IF (check_error(dm_err->eproc)=1)
      IF (findstring("ORA-20100:",dm_err->emsg) > 0)
       SET drdm_mini_loop_status = "NOMV08"
       CALL merge_audit("FAILREASON",
        "The row is trying to update/insert/delete the default row in target",1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dm_translate(sbr_tbl_name,sbr_col_name,sbr_from_val)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   SET to_val = "NOXLAT"
   SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
    index_var].table_name)
   SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[index_var].column_name)
   SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
    col_qual[dt_temp_col_cnt].root_entity_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE dm_trans2(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
     index_var].table_name)
    SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
     dt_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].exception_flg=1))
     RETURN(sbr_from_val)
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name IN (
     "", " ")))
      SET to_val = "BADLOG"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name =
       "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
       col_qual[dt_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val != "No Trans"
       AND findstring(".0",to_val)=0)
       SET to_val = concat(to_val,".0")
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = sbr_from_val
   ENDIF
   SET dt_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[index_var]
    .table_name)
   IF ((dm2_ref_data_doc->tbl_qual[dt_root_tbl_cnt].mergeable_ind=0))
    SET to_val = "NOMV04"
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE select_merge_translate(sbr_f_value,sbr_t_name)
   DECLARE sbr_return_val = vc
   DECLARE drdm_dmt_scr = vc
   DECLARE except_tab = vc
   DECLARE smt_loop = i4
   DECLARE smt_tbl_pos = i4
   DECLARE smt_seq_name = vc
   DECLARE smt_seq_num = f8
   DECLARE smt_cur_table = i4
   DECLARE smt_seq_loop = i4
   DECLARE smt_seq_val = i4
   DECLARE smt_xlat_env_tgt_id = f8
   SET smt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET sbr_return_val = "No Trans"
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET smt_tbl_pos = locateval(smt_loop,1,dm2_ref_data_doc->tbl_cnt,sbr_t_name,dm2_ref_data_doc->
    tbl_qual[smt_loop].table_name)
   IF (smt_tbl_pos=0)
    SET smt_cur_table = temp_tbl_cnt
    SET smt_tbl_pos = fill_rs("TABLE",sbr_t_name)
    SET temp_tbl_cnt = smt_cur_table
   ENDIF
   IF (smt_tbl_pos=0)
    RETURN(sbr_return_val)
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].skip_seqmatch_ind != 1))
    IF (sbr_t_name="REF_TEXT_RELTN")
     SET smt_seq_name = "REFERENCE_SEQ"
    ELSE
     FOR (smt_loop = 1 TO dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].pk_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].root_entity_name=sbr_t_name))
        SET smt_seq_name = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].sequence_name
       ENDIF
     ENDFOR
    ENDIF
    IF (smt_seq_name="")
     CALL disp_msg("No Valid sequence was found",dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
     SET dm_err->err_ind = 0
     CALL merge_audit("FAILREASON","No Valid sequence was found",3)
     RETURN(sbr_return_val)
    ENDIF
    SET smt_seq_val = locateval(smt_seq_loop,1,size(drdm_sequence->qual,5),smt_seq_name,drdm_sequence
     ->qual[smt_seq_loop].seq_name)
    IF (smt_seq_val=0)
     SELECT
      IF ((dm2_rdds_rec->mode="OS"))
       WHERE d.info_domain="MERGE00SEQMATCH"
        AND d.info_name=smt_seq_name
      ELSE
       WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
         cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
        AND d.info_name=smt_seq_name
      ENDIF
      INTO "NL:"
      FROM dm_info d
      DETAIL
       smt_seq_num = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
     IF (((curqual=0) OR ((smt_seq_num=- (1)))) )
      SET smt_cur_table = temp_tbl_cnt
      EXECUTE dm2_find_sequence_match smt_seq_name, dm2_ref_data_doc->env_source_id
      SET temp_tbl_cnt = smt_cur_table
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
       SET dm_err->err_ind = 1
       SET drdm_error_ind = 1
       RETURN(sbr_return_val)
      ENDIF
      SELECT
       IF ((dm2_rdds_rec->mode="OS"))
        WHERE d.info_domain="MERGE00SEQMATCH"
         AND d.info_name=smt_seq_name
       ELSE
        WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
          cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
         AND d.info_name=smt_seq_name
       ENDIF
       INTO "NL:"
       FROM dm_info d
       DETAIL
        smt_seq_num = d.info_number
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
      ENDIF
      IF (curqual=0)
       SET drdm_error_out_ind = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = "A sequence match could not be found in DM_INFO"
       CALL disp_msg("A sequence match could not be found in DM_INFO",dm_err->logfile,1)
       RETURN("No Trans")
      ENDIF
     ENDIF
     SET stat = alterlist(drdm_sequence->qual,(size(drdm_sequence->qual,5)+ 1))
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_name = smt_seq_name
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_val = smt_seq_num
    ELSE
     SET smt_seq_num = drdm_sequence->qual[smt_seq_val].seq_val
    ENDIF
   ELSE
    SET smt_seq_num = 0
   ENDIF
   IF (cnvtreal(sbr_f_value) <= smt_seq_num)
    RETURN(sbr_f_value)
   ELSE
    SELECT
     IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSE
     ENDIF
     INTO "NL:"
     FROM dm_merge_translate dm
     DETAIL
      IF ((select_merge_translate_rec->type="TO"))
       sbr_return_val = cnvtstring(dm.from_value)
      ELSE
       sbr_return_val = cnvtstring(dm.to_value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
    ENDIF
    IF (sbr_return_val="No Trans"
     AND (global_mover_rec->loop_back_ind=1))
     SET source_table_name = dm2_get_rdds_tname("DM_MERGE_TRANSLATE")
     SELECT
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSE
      ENDIF
      INTO "NL:"
      FROM (parser(source_table_name) dm)
      DETAIL
       IF ((select_merge_translate_rec->type != "TO"))
        sbr_return_val = cnvtstring(dm.from_value)
       ELSE
        sbr_return_val = cnvtstring(dm.to_value)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (sbr_return_val != "No Trans")
    CALL rdds_del_except(sbr_t_name,cnvtreal(sbr_f_value))
   ENDIF
   RETURN(sbr_return_val)
 END ;Subroutine
 SUBROUTINE del_chg_log(sbr_table_name,sbr_log_type,sbr_target_id)
   FREE RECORD dcl_rec_parse
   RECORD dcl_rec_parse(
     1 qual[*]
       2 parse_stmts = vc
   )
   SET stat = alterlist(dcl_rec_parse->qual,3)
   DECLARE sbr_tname_flex = vc
   DECLARE sbr_flex_pos = i4
   DECLARE sbr_look_ahead = vc WITH noconstant(build(global_mover_rec->refchg_buffer,"MIN"))
   SET drdm_any_translated = 1
   SET dm_err->eproc = "Updating DM_CHG_LOG Table drdm_chg->log[drdm_log_loop].log_id"
   SET update_cnt = 0
   SET sbr_tname_flex = dm2_get_rdds_tname("DM_CHG_LOG")
   SET dcl_rec_parse->qual[1].parse_stmts = concat("select into 'nl:' from ",sbr_tname_flex)
   SET dcl_rec_parse->qual[2].parse_stmts = " d where log_id = drdm_chg->log[drdm_log_loop].log_id"
   SET dcl_rec_parse->qual[3].parse_stmts = " detail update_cnt = d.updt_cnt with nocounter go"
   EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
   ENDIF
   SET stat = alterlist(dcl_rec_parse->qual,0)
   SET stat = alterlist(dcl_rec_parse->qual,8)
   IF ((((update_cnt=drdm_chg->log[drdm_log_loop].updt_cnt)) OR (sbr_log_type="REFCHG")) )
    IF ((drdm_chg->log[drdm_log_loop].par_location > 0))
     SET sbr_flex_pos = drdm_chg->log[drdm_log_loop].par_location
    ELSE
     SET sbr_flex_pos = drdm_log_loop
    ENDIF
    SET dcl_rec_parse->qual[1].parse_stmts = concat(" update into ",sbr_tname_flex,
     " d1, (dummyt d with seq = size(drdm_pair_info->qual)) ")
    SET dcl_rec_parse->qual[2].parse_stmts = " set d1.log_type = sbr_log_type, "
    SET dcl_rec_parse->qual[3].parse_stmts = " d1.rdbhandle = NULL, "
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[4].parse_stmts = concat(
      " d1.updt_dt_tm = cnvtlookahead(sbr_look_ahead, cnvtdatetime(curdate,curtime3)),")
    ELSE
     SET dcl_rec_parse->qual[4].parse_stmts = "d1.updt_dt_tm = cnvtdatetime(curdate,curtime3),"
    ENDIF
    SET dcl_rec_parse->qual[5].parse_stmts = concat(" d1.updt_cnt = d1.updt_cnt + 1 plan d where",
     " drdm_pair_info->qual[d.seq].log_id > 0 ")
    SET dcl_rec_parse->qual[6].parse_stmts = concat(" join d1 where d1.log_id = ",
     " drdm_pair_info->qual[d.seq].log_id")
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[7].parse_stmts = " and d1.log_type = 'PROCES'"
    ELSE
     SET dcl_rec_parse->qual[7].parse_stmts = concat(" and d1.updt_cnt = ",
      " drdm_pair_info->qual[d.seq].updt_cnt")
    ENDIF
    SET dcl_rec_parse->qual[8].parse_stmts = " with nocounter go"
    EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    SET nodelete_msg = concat("Could not process log_id ",trim(cnvtstring(drdm_chg->log[drdm_log_loop
       ].log_id)),
     " because it has been updated since the mover picked it up. It will be merged next pass.")
    CALL echo("")
    CALL echo("")
    CALL echo(nodelete_msg)
    CALL echo("")
    CALL echo("")
    CALL merge_audit("FAILREASON",nodelete_msg,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE insert_merge_translate(sbr_from,sbr_to,sbr_table)
   DECLARE imt_seq_name = vc
   DECLARE imt_seq_num = f8
   DECLARE imt_seq_loop = i4
   DECLARE imt_seq_cnt = i4
   DECLARE imt_rs_cnt = i4
   DECLARE imt_return = i2
   DECLARE imt_except_tab = vc
   DECLARE imt_pk_pos = i4
   DECLARE imt_xlat_env_tgt_id = f8
   SET imt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET imt_return = 0
   SET dm_err->eproc = "Inserting Translation"
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind=0))
    FOR (imt_seq_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5))
      IF ((sbr_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].root_entity_name
      )
       AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].pk_ind=1))
       SET imt_pk_pos = imt_seq_loop
       SET imt_seq_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].
       sequence_name
      ENDIF
    ENDFOR
    SET imt_seq_cnt = locateval(imt_seq_loop,1,size(drdm_sequence->qual,5),imt_seq_name,drdm_sequence
     ->qual[imt_seq_loop].seq_name)
    SET imt_seq_num = drdm_sequence->qual[imt_seq_cnt].seq_val
    IF (sbr_to < imt_seq_num)
     SET imt_return = 1
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM dm_merge_translate dmt
    WHERE dmt.to_value=sbr_to
     AND concat(dmt.table_name,"")=sbr_table
     AND (dmt.env_source_id=dm2_ref_data_doc->env_source_id)
     AND dmt.env_target_id=imt_xlat_env_tgt_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET imt_return = 1
   ENDIF
   IF (imt_return=0)
    INSERT  FROM dm_merge_translate dm
     SET dm.from_value = sbr_from, dm.to_value = sbr_to, dm.table_name = sbr_table,
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.status_flg = drdm_chg->log[drdm_log_loop
      ].status_flg, dm.log_id = drdm_chg->log[drdm_log_loop].log_id,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.env_target_id = imt_xlat_env_tgt_id
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     IF (nvp_commit_ind=1
      AND (global_mover_rec->one_pass_ind=0))
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET imt_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
    IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND (d.column_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name)
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual=0)
     IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.from_value = sbr_from,
        d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ELSE
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.column_name = dm2_ref_data_doc->
        tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
        d.from_value = sbr_from, d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     COMMIT
    ENDIF
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET fail_merges = (fail_merges+ 1)
    SET fail_merge_audit->num[fail_merges].action = "FAILREASON"
    SET fail_merge_audit->num[fail_merges].text = "Preventing a 2 into 1 translation"
    CALL merge_audit(fail_merge_audit->num[fail_merges].action,fail_merge_audit->num[fail_merges].
     text,1)
    IF (drdm_error_out_ind=1)
     ROLLBACK
    ENDIF
   ENDIF
   RETURN(imt_return)
 END ;Subroutine
 SUBROUTINE find_p_e_col(sbr_p_e_name,sbr_p_e_col)
   DECLARE p_e_name = vc
   DECLARE r_e_name = vc
   DECLARE p_e_col = vc
   DECLARE tbl_loop = i4
   DECLARE kickout = i4
   DECLARE p_e_tbl_pos = i4
   DECLARE p_e_col_pos = i4
   DECLARE p_e_where_str = vc
   DECLARE pk_pos = i4
   DECLARE temp_name = vc
   DECLARE mult_cnt = i4
   DECLARE pk_num = i4
   DECLARE good_pk = i4
   DECLARE pk_name = vc
   DECLARE id_ind = i2
   DECLARE info_alias = vc
   DECLARE i_domain = vc
   DECLARE i_name = vc
   DECLARE p_e_dummy_cnt = i4
   DECLARE temp_r_e_name = vc
   SET p_e_name = "INVALIDTABLE"
   SET r_e_name = sbr_p_e_name
   SET info_alias = ""
   SET id_ind = 0
   SET pk_num = 0
   SET pk_name = ""
   SET good_pk = 0
   WHILE (p_e_name != r_e_name)
     SET p_e_name = r_e_name
     SET r_e_name = "INVALIDTABLE"
     SET pk_pos = 0
     SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[tbl_loop]
      .tbl_name)
     IF (pk_pos=0)
      SELECT INTO "NL:"
       FROM dtable d
       WHERE d.table_name=p_e_name
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
       SET i_name = concat(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_p_e_col].
        parent_entity_col,":",p_e_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain="RDDS_PE_ABBREVIATIONS"
         AND d.info_name=p_e_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=i_domain
         AND d.info_name=i_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       IF (info_alias="")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
        CALL echo("Parent_entity_col could not be found")
       ELSE
        SET p_e_name = info_alias
        SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[
         tbl_loop].tbl_name)
        IF (pk_pos=0)
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
         CALL echo("Parent_entity_col could not be found")
        ENDIF
       ENDIF
      ELSE
       CALL echo(concat("The following table is activity: ",p_e_name))
       SET p_e_name = "INVALIDTABLE"
       SET r_e_name = p_e_name
      ENDIF
     ENDIF
     IF (pk_pos != 0)
      IF ((dguc_reply->dtd_hold[tbl_loop].pk_cnt > 1))
       FOR (mult_cnt = 1 TO dguc_reply->dtd_hold[tbl_loop].pk_cnt)
         IF ((((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID")) OR ((((dguc_reply->
         dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*CD")) OR ((dguc_reply->dtd_hold[tbl_loop].
         pk_hold[mult_cnt].pk_name="CODE_VALUE"))) )) )
          IF ((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID"))
           SET id_ind = 1
          ENDIF
          SET pk_num = (pk_num+ 1)
          SET good_pk = mult_cnt
         ENDIF
       ENDFOR
       IF (pk_num > 1)
        IF (id_ind=1)
         CALL echo("This Parent_Entity Table has more than a single Primary Key")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
        ENDIF
       ELSE
        SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
       ENDIF
      ELSE
       SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[1].pk_name
      ENDIF
      IF (p_e_name != "INVALIDTABLE")
       SET p_e_col = pk_name
       SET p_e_tbl_pos = 0
       SET p_e_tbl_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_cnt,p_e_name,dm2_ref_data_doc->
        tbl_qual[tbl_loop].table_name)
       IF (p_e_tbl_pos=0)
        SET p_e_dummy_cnt = temp_tbl_cnt
        SET p_e_tbl_pos = fill_rs("TABLE",p_e_name)
        SET temp_tbl_cnt = p_e_dummy_cnt
        IF (p_e_tbl_pos=0)
         CALL echo("Information not found for table level meta-data")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET temp_r_e_name = r_e_name
         FOR (p_e_dummy_cnt = 1 TO dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt)
           IF ((dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].column_name=p_e_col))
            SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].
            root_entity_name
           ENDIF
         ENDFOR
         IF (temp_r_e_name=r_e_name)
          CALL echo("Information not found for table level meta-data")
          SET p_e_name = "INVALIDTABLE"
          SET r_e_name = p_e_name
         ENDIF
        ENDIF
       ENDIF
       IF (p_e_tbl_pos != 0)
        SET p_e_col_pos = 0
        SET p_e_col_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt,
         p_e_col,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[tbl_loop].column_name)
        IF (p_e_col_pos=0)
         CALL echo("Information not found in dm_columns_doc for column")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_col_pos].
         root_entity_name
        ENDIF
       ENDIF
       SET kickout = (kickout+ 1)
       IF (kickout=5)
        CALL echo("Searched through 5 Parent_entity_columns")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF (p_e_name="INVALIDTABLE")
    ROLLBACK
    SET drdm_mini_loop_status = "NOMV99"
    CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV99")
    COMMIT
   ENDIF
   RETURN(p_e_name)
 END ;Subroutine
 SUBROUTINE merge_audit(action,text,audit_type)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON", "BATCH END")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    SET ma_log_id = drdm_chg->log[drdm_log_loop].log_id
    IF (temp_tbl_cnt=0)
     SET ma_table_name = "NONE"
    ELSE
     SET ma_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     ROLLBACK
    ENDIF
    SELECT INTO "NL:"
     y = seq(dm_merge_audit_seq,nextval)
     FROM dual
     DETAIL
      ma_next_seq = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET drdm_error_out_ind = 1
    ELSE
     UPDATE  FROM dm_chg_log_audit dm
      SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
       dm.text = text, dm.table_name = ma_table_name, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE dm.dm_chg_log_audit_id=ma_next_seq
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET drdm_error_out_ind = 1
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_chg_log_audit dm
       SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
        dm.text = text, dm.table_name = ma_table_name, dm.dm_chg_log_audit_id = ma_next_seq,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET drdm_error_out_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     IF (drdm_error_out_ind=0)
      COMMIT
     ENDIF
    ENDIF
    RETURN(1)
   ENDIF
   FREE SET aud_seq
   FREE SET ma_log_id
 END ;Subroutine
 SUBROUTINE report_missing(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   DECLARE missing_cnt = i4
   DECLARE source_tab_name = vc
   DECLARE insert_log_type = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET source_tab_name = dm2_get_rdds_tname(sbr_table_name)
   SET except_log_type = "NOXLAT"
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
     IF (sbr_table_name="DCP_FORMS_REF")
      CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
     ELSEIF (sbr_table_name="DCP_SECTION_REF")
      CALL parser(" where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",
       0)
     ELSE
      CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
     ENDIF
     CALL parser(" with nocounter go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF (curqual=0)
       SET except_log_type = "ORPHAN"
       INSERT  FROM (parser(except_tab) d)
        SET d.log_type = "ORPHAN", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
         d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET nodelete_ind = 1
        SET no_insert_update = 1
        SET drdm_error_out_ind = 1
        SET dm_err->err_ind = 0
       ENDIF
      ENDIF
     ENDIF
     SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
     IF (missing_cnt > 0)
      IF (except_log_type="ORPHAN")
       SET missing_xlats->qual[missing_cnt].orphan_ind = 1
       SET missing_xlats->qual[missing_cnt].processed_ind = 1
      ELSE
       SET missing_xlats->qual[missing_cnt].orphan_ind = 0
       SET missing_xlats->qual[missing_cnt].processed_ind = 0
      ENDIF
     ENDIF
     RETURN(except_log_type)
    ELSE
     IF (except_log_type IN ("ORPHAN", "OLDVER", "NOMV*"))
      RETURN(except_log_type)
     ELSE
      CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
      IF (sbr_table_name="DCP_FORMS_REF")
       CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
      ELSEIF (sbr_table_name="DCP_SECTION_REF")
       CALL parser(
        " where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",0)
      ELSE
       CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
      ENDIF
      CALL parser(" with nocounter go",1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
      ELSE
       IF (curqual=0)
        UPDATE  FROM (parser(except_tab) d)
         SET d.log_type = "ORPHAN"
         WHERE d.table_name=sbr_table_name
          AND d.from_value=sbr_value
          AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET nodelete_ind = 1
         SET no_insert_update = 1
         SET drdm_error_out_ind = 1
         SET dm_err->err_ind = 0
        ENDIF
        RETURN("ORPHAN")
       ELSE
        SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
        IF (missing_cnt > 0)
         SET missing_xlats->qual[missing_cnt].processed_ind = 0
         SET missing_xlats->qual[missing_cnt].orphan_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(except_log_type)
 END ;Subroutine
 SUBROUTINE version_exception(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   IF ((global_mover_rec->one_pass_ind=0))
    ROLLBACK
   ENDIF
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     INSERT  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
       d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ELSEIF (except_log_type != "OLDVER")
     UPDATE  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER"
      WHERE d.table_name=sbr_table_name
       AND d.column_name=sbr_column_name
       AND d.from_value=sbr_value
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rdds_del_except(sbr_table_name,sbr_value)
   DECLARE except_tab = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   DELETE  FROM (parser(except_tab) d)
    WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.table_name=sbr_table_name
     AND d.from_value=sbr_value
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_get_rdds_tname(sbr_tname)
   DECLARE return_tname = vc
   IF ((dm2_rdds_rec->mode="OS"))
    SET return_tname = concat(trim(substring(1,28,sbr_tname)),"$F")
   ELSEIF ((dm2_rdds_rec->main_process="EXTRACTOR")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = sbr_tname
   ELSEIF ((dm2_rdds_rec->main_process="MOVER")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = concat(dm2_ref_data_doc->pre_link_name,sbr_tname,dm2_ref_data_doc->
     post_link_name)
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "The main_process and/or mode were invalid"
   ENDIF
   RETURN(return_tname)
 END ;Subroutine
 SUBROUTINE orphan_child_tab(sbr_table_name,sbr_log_type)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
   DECLARE oct_col_name = vc
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name != sbr_table_name))
    SET oct_tab_cnt = locateval(oct_tab_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
     dm2_ref_data_doc->tbl_qual[oct_tab_loop].table_name)
    IF (oct_tab_cnt=0)
     SET dm_err->err_msg = "The table name could not be found in the meta-data record structure"
     SET nodelete_ind = 1
    ENDIF
   ELSE
    SET oct_tab_cnt = temp_tbl_cnt
   ENDIF
   SET oct_col_cnt = 0
   FOR (oct_tab_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual,5))
     IF ((dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].root_entity_name=
     sbr_table_name))
      SET oct_col_cnt = oct_tab_loop
     ENDIF
   ENDFOR
   IF (oct_col_cnt=0)
    RETURN(0)
   ENDIF
   CALL parser(concat("set oct_pk_value = RS_",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].suffix,
     "->from_values.",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name,
     " go "),1)
   SET oct_excptn_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     DETAIL
      oct_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.column_name=dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name)
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end select
    SET oct_col_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (curqual=0)
    INSERT  FROM (parser(oct_excptn_tab) d)
     SET d.table_name = sbr_table_name, d.column_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].
      col_qual[oct_col_cnt].column_name, d.target_env_id = dm2_ref_data_doc->env_target_id,
      d.from_value = oct_pk_value, d.log_type = sbr_log_type
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    UPDATE  FROM (parser(oct_excptn_tab) d)
     SET d.log_type = sbr_log_type
     WHERE d.table_name=sbr_table_name
      AND d.column_name=oct_col_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_alias(sbr_tbl_suffix)
   DECLARE sbr_rgta_rtn = vc
   SET sbr_rgta_rtn = build("t",sbr_tbl_suffix)
   RETURN(sbr_rgta_rtn)
 END ;Subroutine
 SUBROUTINE insert_noxlat(sbr_table_name,sbr_column_name,sbr_value,sbr_orphan_ind)
   DECLARE inx_except_tab = vc
   DECLARE inx_log_type = vc
   DECLARE inx_col_name = vc
   SET inx_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     DETAIL
      inx_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     WITH nocounter
    ;end select
    SET inx_col_name = sbr_column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    RETURN(1)
   ENDIF
   IF (curqual=0)
    IF (sbr_orphan_ind=1)
     SET inx_log_type = "ORPHAN"
    ELSE
     SET inx_log_type = "NOXLAT"
    ENDIF
    INSERT  FROM (parser(inx_except_tab) d)
     SET d.log_type = inx_log_type, d.table_name = sbr_table_name, d.column_name = sbr_column_name,
      d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE arv_loop = i4
   DECLARE arv_cnt = i4
   DECLARE arv_found = i2
   SET arv_cnt = size(missing_xlats->qual,5)
   SET arv_found = 0
   FOR (arv_loop = 1 TO arv_cnt)
     IF ((missing_xlats->qual[arv_loop].table_name=sbr_table_name)
      AND (missing_xlats->qual[arv_loop].column_name=sbr_column_name)
      AND (missing_xlats->qual[arv_loop].missing_value=sbr_value))
      SET arv_found = 1
     ENDIF
   ENDFOR
   IF (arv_found=0)
    SET arv_cnt = (arv_cnt+ 1)
    SET stat = alterlist(missing_xlats->qual,arv_cnt)
    SET missing_xlats->qual[arv_cnt].table_name = sbr_table_name
    SET missing_xlats->qual[arv_cnt].column_name = sbr_column_name
    SET missing_xlats->qual[arv_cnt].missing_value = sbr_value
    RETURN(arv_cnt)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_trans3(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind,sbr_pe_tbl_name)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt3_temp_tbl_cnt = i4
   DECLARE dt3_temp_col_cnt = i4
   DECLARE dt3_from_con = vc
   DECLARE dt3_domain = vc
   DECLARE dt3_name = vc
   DECLARE dt3_find = i4
   DECLARE dt3_pk_column = vc
   DECLARE dt3_pk_tab_name = vc
   DECLARE dt3_root_tbl_cnt = i4
   IF (sbr_from_val=0)
    RETURN("0")
   ENDIF
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt3_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->
     tbl_qual[index_var].table_name)
    SET dt3_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->
     tbl_qual[dt3_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].exception_flg=1))
     RETURN(cnvtstring(sbr_from_val))
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
      IN ("", " ")))
      IF (sbr_pe_tbl_name != ""
       AND sbr_pe_tbl_name != " ")
       SET dt3_pk_tab_name = find_p_e_col(sbr_pe_tbl_name,dt3_temp_col_cnt)
      ELSE
       SET dt3_pk_tab_name = "INVALIDTABLE"
       SET dt3_domain = concat("RDDS_PE_ABBREV:",sbr_tbl_name)
       SET dt3_name = concat(sbr_col_name,":",dt3_pk_tab_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=dt3_domain
         AND d.info_name=dt3_name
        DETAIL
         dt3_pk_tab_name = d.info_char
        WITH nocounter
       ;end select
      ENDIF
      IF (dt3_pk_tab_name != "")
       IF (dt3_pk_tab_name != "INVALIDTABLE")
        IF (dt3_pk_tab_name="PERSON")
         SET dt3_pk_tab_name = "PRSNL"
        ENDIF
        SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dt3_pk_tab_name)
       ENDIF
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dt3_pk_tab_name,dm2_ref_data_doc->
        tbl_qual[index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET dt3_find = locateval(dt3_find,1,size(dm2_ref_data_doc->tbl_qual,5),dt3_pk_tab_name,
         dm2_ref_data_doc->tbl_qual[dt3_find].table_name)
        FOR (dt3_i = 1 TO size(dm2_ref_data_doc->tbl_qual[dt3_find].col_qual,5))
          IF ((dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].pk_ind=1)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name=dm2_ref_data_doc->
          tbl_qual[dt3_find].col_qual[dt3_i].root_entity_attr)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].root_entity_name=
          dm2_ref_data_doc->tbl_qual[dt3_find].table_name))
           SET dt3_pk_column = dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name
          ENDIF
        ENDFOR
        SET to_val = report_missing(dt3_pk_tab_name,dt3_pk_column,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
        = "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dm2_ref_data_doc->tbl_qual[
       dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
        dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[
        index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_attr,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = cnvtstring(sbr_from_val)
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE trigger_proc_call(tpc_table_name,tpc_pk_where,tpc_context,tpc_col_name,tpc_value)
   DECLARE tpc_pk_where_vc = vc
   DECLARE tpc_pktbl_cnt = i4
   DECLARE tpc_tbl_loop = i4
   DECLARE tpc_error_ind = i2
   DECLARE tpc_col_loop = i4
   DECLARE tpc_col_pos = i4
   DECLARE tpc_suffix = vc
   DECLARE tpc_pk_proc_name = vc
   DECLARE tpc_proc_name = vc
   DECLARE tpc_f8_var = f8
   DECLARE tpc_i4_var = i4
   DECLARE tpc_vc_var = vc
   DECLARE tpc_row_cnt = i4
   DECLARE tpc_row_loop = i4
   DECLARE tpc_src_tab_name = vc
   DECLARE tpc_main_proc = vc
   DECLARE tpc_uo_tname = vc
   DECLARE tpc_pkw_tab_name = vc
   SET tpc_pk_where_vc = tpc_pk_where
   SET tpc_proc_name = ""
   SET tpc_pktbl_cnt = 0
   SET tpc_pktbl_cnt = locateval(tpc_tbl_loop,1,size(pk_where_parm->qual,5),tpc_table_name,
    pk_where_parm->qual[tpc_tbl_loop].table_name)
   IF (tpc_pktbl_cnt=0)
    SET tpc_pktbl_cnt = (size(pk_where_parm->qual,5)+ 1)
    SET stat = alterlist(pk_where_parm->qual,tpc_pktbl_cnt)
    SET pk_where_parm->qual[tpc_pktbl_cnt].table_name = tpc_table_name
    SET tpc_tbl_loop = 0
    SET tpc_pkw_tab_name = dm2_get_rdds_tname("DM_REFCHG_PKW_PARM")
    SELECT INTO "NL:"
     FROM (parser(tpc_pkw_tab_name) d)
     WHERE d.table_name=tpc_table_name
     ORDER BY parm_nbr
     DETAIL
      tpc_tbl_loop = (tpc_tbl_loop+ 1), stat = alterlist(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,
       tpc_tbl_loop), pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name = d
      .column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(tpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpc_table_name,
    dm2_ref_data_doc->tbl_qual[tpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",tpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       " = ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   SET tpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   IF (tpc_pk_where_vc="")
    SET tpc_pk_where_vc = concat("WHERE t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,".",
     tpc_col_name," = tpc_value")
   ENDIF
   IF (((size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5) != 1) OR ((pk_where_parm->qual[
   tpc_pktbl_cnt].col_qual[1].col_name != tpc_col_name))) )
    SET tpc_src_tab_name = dm2_get_rdds_tname(tpc_table_name)
    SET tpc_row_cnt = 0
    CALL parser("select into 'NL:' ",0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     IF (tpc_tbl_loop > 1)
      CALL parser(" , ",0)
     ENDIF
     CALL parser(concat("var",cnvtstring(tpc_tbl_loop)," = nullind(",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,")"),0)
    ENDFOR
    CALL parser(concat("from ",tpc_src_tab_name," ",tpc_suffix," ",
      tpc_pk_where_vc,
      " detail  tpc_row_cnt = tpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, tpc_row_cnt) "),0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name," = ",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name),0)
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(tpc_tbl_loop)),0)
    ENDFOR
    CALL parser("with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
    IF (tpc_row_cnt=0)
     RETURN(0)
    ENDIF
   ELSE
    SET tpc_row_cnt = 1
    SET stat = alterlist(cust_cs_rows->qual,1)
    CALL parser(concat("set cust_cs_rows->qual[1].",tpc_col_name," = tpc_value go"),0)
   ENDIF
   SET tpc_pk_proc_name = concat("REFCHG_PK_WHERE_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SET tpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SELECT INTO "NL:"
    FROM (parser(tpc_uo_tname) u)
    WHERE u.object_name=patstring(tpc_pk_proc_name)
    DETAIL
     tpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   IF (tpc_proc_name="")
    SET dm_err->emsg = concat("A trigger procedure is not built: ",tpc_pk_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET tpc_main_proc = dm2_get_rdds_tname("PROC_REFCHG_INS_LOG")
    SET tpc_proc_name = dm2_get_rdds_tname(tpc_proc_name)
    FOR (tpc_row_loop = 1 TO tpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("RDB ASIS(^ BEGIN ",tpc_main_proc,"('",
       tpc_table_name,"',^)")
      SET drdm_parser->statement[2].frag = concat(" ASIS (^",tpc_proc_name,"('INS/UPD'^)")
      SET drdm_parser_cnt = 3
      FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
        CALL parser(concat("set tpc_col_nullind = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
          qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (tpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , NULL ^)")
         SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
          col_qual,5))].frag = concat("ASIS (^ , NULL ^)")
        ELSE
         SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_f8_var,15),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_f8_var,15),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ ,to_date('",format(
            tpc_f8_var,"DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ ,to_date('",format(tpc_f8_var,
            "DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set tpc_i4_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_i4_var),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_i4_var),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type="C*"))
          CALL parser(concat("declare tpc_c_var = C",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
            col_qual[tpc_col_pos].data_length," go"),1)
          CALL parser(concat("set tpc_c_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->qual[
            tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
         ELSE
          CALL parser(concat("set tpc_vc_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET tpc_vc_var = replace_carrot_symbol(tpc_vc_var)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "ASIS (^), dbms_utility.get_hash_value(^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^",tpc_proc_name,
       "('INS/UPD'^)")
      SET drdm_parser_cnt = ((drdm_parser_cnt+ 1)+ size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5
       ))
      SET drdm_parser->statement[drdm_parser_cnt].frag = "ASIS (^),0,1073741824.0), ^)"
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'REFCHG',0,",cnvtstring(
        reqinfo->updt_id,15),",",cnvtstring(reqinfo->updt_task),",",
       cnvtstring(reqinfo->updt_applctx),", ^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'",tpc_context,"',",
       cnvtstring(dm2_ref_data_doc->env_target_id,15),"); END; ^) GO")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET tpc_error_ind = 1
       SET tpc_row_loop = tpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(tpc_error_ind)
 END ;Subroutine
 SUBROUTINE filter_proc_call(fpc_table_name,fpc_pk_where)
   DECLARE fpc_loop = i4
   DECLARE fpc_filter_pos = i4
   DECLARE fpc_col_cnt = i4
   DECLARE fpc_tbl_loop = i4
   DECLARE fpc_col_loop = i4
   DECLARE fpc_col_pos = i4
   DECLARE fpc_error_ind = i2
   DECLARE fpc_suffix = vc
   DECLARE fpc_row_cnt = i4
   DECLARE fpc_row_loop = i4
   DECLARE fpc_col_nullind = i2
   DECLARE fpc_proc_name = vc
   DECLARE fpc_filter_proc_name = vc
   DECLARE fpc_src_tab_name = vc
   DECLARE fpc_f8_var = f8
   DECLARE fpc_i4_var = i4
   DECLARE fpc_vc_var = vc
   DECLARE fpc_return_var = i2
   DECLARE fpc_uo_tname = vc
   DECLARE fpc_filter_tab_name = vc
   SET fpc_filter_pos = locateval(fpc_loop,1,size(filter_parm->qual,5),fpc_table_name,filter_parm->
    qual[fpc_loop].table_name)
   IF (fpc_filter_pos=0)
    SET fpc_filter_pos = (size(filter_parm->qual,5)+ 1)
    SET fpc_col_cnt = 0
    SET fpc_filter_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_PARM")
    SELECT INTO "NL:"
     FROM (parser(fpc_filter_tab_name) d)
     WHERE d.table_name=fpc_table_name
      AND d.active_ind=1
     ORDER BY d.parm_nbr
     HEAD REPORT
      stat = alterlist(filter_parm->qual,fpc_filter_pos), filter_parm->qual[fpc_filter_pos].
      table_name = fpc_table_name
     DETAIL
      fpc_col_cnt = (fpc_col_cnt+ 1), stat = alterlist(filter_parm->qual[fpc_filter_pos].col_qual,
       fpc_col_cnt), filter_parm->qual[fpc_filter_pos].col_qual[fpc_col_cnt].col_name = d.column_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
    dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",fpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," = ",
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   SET fpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   SET fpc_row_cnt = 0
   SET fpc_src_tab_name = dm2_get_rdds_tname(fpc_table_name)
   CALL parser("select into 'NL:' ",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    IF (fpc_tbl_loop > 1)
     CALL parser(" , ",0)
    ENDIF
    CALL parser(concat("var",cnvtstring(fpc_tbl_loop)," = nullind(",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,")"),0)
   ENDFOR
   CALL parser(concat("from ",fpc_src_tab_name," ",fpc_suffix," ",
     fpc_pk_where,
     " detail  fpc_row_cnt = fpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, fpc_row_cnt) "),0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name," = ",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name),0)
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(fpc_tbl_loop)),0)
   ENDFOR
   CALL parser("with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 0
   ENDIF
   IF (fpc_row_cnt=0)
    RETURN(1)
   ENDIF
   SET fpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SET fpc_proc_name = ""
   SET fpc_filter_proc_name = concat("REFCHG_FILTER_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SELECT INTO "NL:"
    FROM (parser(fpc_uo_tname) u)
    WHERE u.object_name=patstring(fpc_filter_proc_name)
    DETAIL
     fpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   IF (fpc_proc_name="")
    SET dm_err->emsg = concat("A filter procedure is not built: ",fpc_filter_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET fpc_proc_name = dm2_get_rdds_tname(fpc_proc_name)
    CALL parser(concat(" declare ",fpc_proc_name,"() = i2 go"),0)
    FOR (fpc_row_loop = 1 TO fpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' ret_val = ",fpc_proc_name,
       "('UPD'")
      SET drdm_parser_cnt = 2
      FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
        CALL parser(concat("set fpc_col_nullind = cust_cs_rows->qual[fpc_row_loop].",filter_parm->
          qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (fpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = ", NULL, NULL "
        ELSE
         SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_f8_var,15),
           " , ",cnvtstring(fpc_f8_var,15))
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ,to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS'),","to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),
           "','DD-MON-YYYY HH24:MI:SS')")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set fpc_i4_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_i4_var)," , ",
           cnvtstring(fpc_i4_var))
         ELSE
          CALL parser(concat("set fpc_vc_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET fpc_vc_var = replace(fpc_vc_var,"'","''",0)
          SET fpc_vc_var = concat("'",fpc_vc_var,"'")
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",fpc_vc_var," , ",fpc_vc_var)
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag =
      ") from dual detail fpc_return_var = ret_val with nocounter go"
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET fpc_error_ind = 1
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
      IF (fpc_return_var=0)
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(fpc_return_var)
 END ;Subroutine
 SUBROUTINE replace_carrot_symbol(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   SET rcs_temp_val = replace(rcs_string,"'",'"',0)
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("^",rcs_temp_val,1,0)
   IF (rcs_pos=0)
    SET rcs_return = concat("'",rcs_temp_val,"'")
   ELSE
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(94)"
       ELSE
        SET rcs_return = concat("'",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),"'||chr(94)")
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_temp_val),"'||chr(94)")
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_temp_val))
     SET rcs_pos = findstring("^",rcs_temp_val,1,1)
     SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos),
       rcs_temp_val),"'")
    ENDIF
   ENDIF
   RETURN(rcs_return)
 END ;Subroutine
 DECLARE daclt_sub_rtn_execute_flg = i2
 SET daclt_sub_rtn_execute_flg = 0
 IF ((((dm2_install_schema->curprog != "DM2_ADD_REFCHG_LOG_TRIGGERS")) OR (size(dm2_cl_trg_updt_cols
  ->qual,5)=0)) )
  SET daclt_sub_rtn_execute_flg = 1
 ENDIF
 FREE RECORD rs_dtd_reply
 RECORD rs_dtd_reply(
   1 rs_tbl_cnt = i4
   1 dtd_hold[*]
     2 tbl_name = vc
     2 process_ind = i2
     2 updt_id_exist = i2
     2 updt_task_exist = i2
     2 tbl_suffix = vc
     2 mrg_del_ind = i2
     2 vers134_ind = i2
     2 ref_ind = i2
     2 mrg_ind = i2
     2 mrg_act_ind = i2
     2 trig_text[3]
       3 trig_name = vc
     2 pk_cnt = i4
     2 pk_hold[*]
       3 pk_datatype = vc
       3 pk_where = vc
       3 pk_name = vc
       3 trans_ind = i2
     2 del_cnt = i4
     2 del_hold[*]
       3 del_datatype = vc
       3 del_where = vc
       3 trans_ind = i2
       3 del_name = vc
     2 filter_function = vc
     2 filter_parm[*]
       3 column_name = vc
       3 data_type = vc
     2 filter_str[*]
       3 add_str = vc
       3 upd_str = vc
       3 del_str = vc
       3 statement_ind = i2
     2 pkw_function = vc
     2 pk_where_parm[*]
       3 column_name = vc
     2 pkw_vers_id = f8
 )
 FREE RECORD stmt_buffer
 RECORD stmt_buffer(
   1 err_ind = i2
   1 data[*]
     2 stmt = vc
 )
 FREE RECORD se_reply
 RECORD se_reply(
   1 err_ind = i2
 )
 DECLARE cl_move_over(i_dguc_reply=vc(ref),i_table_name=vc,i_log_type=vc,i_refchg_tab_r_find=i2,
  i_local_ind=i2) = null
 DECLARE generate_pk_where_str_ora(i_dtd_ndx=i4,o_parm_list=vc(ref),io_iu_pk_where=vc(ref),
  io_del_pk_where=vc(ref),i_local_ind=i2) = null
 DECLARE create_pk_where_function_ora(i_dtd_ndx=i4,io_drop_cnt=i4(ref),io_stmt_cnt=i4(ref),
  i_local_ind=i2) = null
 DECLARE stmt_push(io_cnt=i4(ref),p_text=vc) = null
 DECLARE create_ptam_function_ora(sbr_trg_data_rs=vc(ref),i_trg_ndx=i4,io_drop_cnt=i4(ref),
  io_stmt_cnt=i4(ref)) = i4
 DECLARE create_pkw_function_ora(sbr_trg_data_rs=vc(ref),i_trg_ndx=i4,io_drop_cnt=i4(ref),io_stmt_cnt
  =i4(ref)) = i4
 DECLARE create_colstring_function_ora(sbr_trg_data_rs=vc(ref),i_trg_ndx=i4,io_drop_cnt=i4(ref),
  io_stmt_cnt=i4(ref)) = i4
 DECLARE create_input_parm_ora(i_col_name=vc,i_col_cnt=i4) = vc
 SUBROUTINE cl_move_over(i_dguc_reply,i_table_name,i_log_type,i_refchg_tab_r_find,i_local_ind)
   FREE RECORD rs_dtd_trans
   RECORD rs_dtd_trans(
     1 dtd_hold[*]
       2 pk_hold[*]
         3 trans_ind = i2
   )
   FREE RECORD order_pk
   RECORD order_pk(
     1 ord_hold[*]
       2 ord_datatype = vc
       2 ord_where = vc
       2 trans_ind = i2
       2 ord_name = vc
   )
   DECLARE ac_suf_tbl_name = vc
   DECLARE keep_id_cnt = i4
   DECLARE updt_idx = i4 WITH protect, noconstant(0)
   DECLARE s_load_cnt = i4
   DECLARE s_del_size_hold = i4
   DECLARE s_dtd_name = vc
   DECLARE s_dcd_name = vc
   SET s_dtd_name = "DM_TABLES_DOC_LOCAL"
   SET s_dcd_name = "DM_COLUMNS_DOC_LOCAL"
   SET stat = alterlist(rs_dtd_reply->dtd_hold,size(i_dguc_reply->dtd_hold,5))
   SET final_cnt = 0
   SET updt_idx = 0
   SET stat = alterlist(rs_dtd_trans->dtd_hold,size(i_dguc_reply->dtd_hold,5))
   SET ac_suf_tbl_name = i_table_name
   IF (daclt_sub_rtn_execute_flg=1)
    IF (dm2_cl_trg_updt_cols(ac_suf_tbl_name) != 0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(i_dguc_reply->rs_tbl_cnt)),
     dm_info i,
     (dummyt dt  WITH seq = 100)
    PLAN (d)
     JOIN (dt
     WHERE (dt.seq <= i_dguc_reply->dtd_hold[d.seq].pk_cnt))
     JOIN (i
     WHERE i.info_domain=concat("RDDS TRANS COLUMN:",i_dguc_reply->dtd_hold[d.seq].tbl_name)
      AND (i.info_name=i_dguc_reply->dtd_hold[d.seq].pk_hold[dt.seq].pk_name))
    DETAIL
     IF (size(rs_dtd_trans->dtd_hold[d.seq].pk_hold,5)=0)
      stat = alterlist(rs_dtd_trans->dtd_hold[d.seq].pk_hold,i_dguc_reply->dtd_hold[d.seq].pk_cnt)
     ENDIF
     rs_dtd_trans->dtd_hold[d.seq].pk_hold[dt.seq].trans_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dtd_ndx = 0
   SET dm_err->eproc = concat("Getting tables with Merge_Delete_Ind = 1.")
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = i_dguc_reply->rs_tbl_cnt)
    DETAIL
     final_cnt = (final_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].tbl_suffix = i_dguc_reply->
     dtd_hold[d.seq].tbl_suffix, updt_idx = 0,
     updt_idx = locateval(updt_idx,1,dm2_cl_trg_updt_cols->tbl_cnt,i_dguc_reply->dtd_hold[d.seq].
      tbl_name,dm2_cl_trg_updt_cols->qual[updt_idx].tname)
     IF (updt_idx > 0)
      rs_dtd_reply->dtd_hold[final_cnt].updt_id_exist = dm2_cl_trg_updt_cols->qual[updt_idx].
      updt_id_exist_ind, rs_dtd_reply->dtd_hold[final_cnt].updt_task_exist = dm2_cl_trg_updt_cols->
      qual[updt_idx].updt_task_exist_ind
     ELSE
      rs_dtd_reply->dtd_hold[final_cnt].updt_id_exist = 0, rs_dtd_reply->dtd_hold[final_cnt].
      updt_task_exist = 0
     ENDIF
     rs_dtd_reply->dtd_hold[final_cnt].tbl_name = i_dguc_reply->dtd_hold[d.seq].tbl_name, stat =
     alterlist(rs_dtd_reply->dtd_hold[final_cnt].pk_hold,i_dguc_reply->dtd_hold[d.seq].pk_cnt)
     IF (size(rs_dtd_trans->dtd_hold[d.seq].pk_hold,5)=0)
      stat = alterlist(rs_dtd_trans->dtd_hold[d.seq].pk_hold,i_dguc_reply->dtd_hold[d.seq].pk_cnt)
     ENDIF
     dtd_col_cnt = 0, pk_loop_cnt = 0, keep_id_cnt = 0
     FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
       IF (((findstring("_ID",i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name)) OR (((
       findstring("_CD",i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name)) OR ((((
       i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name="CODE_VALUE")) OR ((rs_dtd_trans->
       dtd_hold[d.seq].pk_hold[pk_loop_cnt].trans_ind=1))) )) )) )
        keep_id_cnt = (keep_id_cnt+ 1)
       ENDIF
     ENDFOR
     pk_loop_cnt = 0
     IF (keep_id_cnt > 0)
      FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
        IF ((((i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name IN ("*_ID", "*_CD",
        "CODE_VALUE"))) OR ((rs_dtd_trans->dtd_hold[d.seq].pk_hold[pk_loop_cnt].trans_ind=1))) )
         dtd_col_cnt = (dtd_col_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].
         pk_name = i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name, rs_dtd_reply->
         dtd_hold[final_cnt].pk_hold[dtd_col_cnt].trans_ind = 1,
         rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_datatype = i_dguc_reply->dtd_hold[
         d.seq].pk_hold[pk_loop_cnt].pk_datatype
         IF (dtd_col_cnt=1)
          rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat("WHERE ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[final_cnt].tbl_suffix),".",trim(rs_dtd_reply
            ->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_name))
         ELSE
          rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat(" AND ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[final_cnt].tbl_suffix),".",trim(rs_dtd_reply
            ->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_name))
         ENDIF
        ENDIF
      ENDFOR
      pk_loop_cnt = 0
      FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
        IF ( NOT ((i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name IN ("*_ID", "*_CD",
        "CODE_VALUE")))
         AND (rs_dtd_trans->dtd_hold[d.seq].pk_hold[pk_loop_cnt].trans_ind=0))
         IF ((dtd_col_cnt=i_dguc_reply->dtd_hold[d.seq].pk_cnt))
          pk_loop_cnt = i_dguc_reply->dtd_hold[d.seq].pk_cnt
         ELSE
          dtd_col_cnt = (dtd_col_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].
          pk_name = i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name, rs_dtd_reply->
          dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_datatype = i_dguc_reply->dtd_hold[d.seq].
          pk_hold[pk_loop_cnt].pk_datatype
          IF (dtd_col_cnt=1)
           rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat("WHERE ",
            dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
             dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
          ELSE
           rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat(" AND ",
            dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
             dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      rs_dtd_reply->dtd_hold[final_cnt].pk_cnt = i_dguc_reply->dtd_hold[d.seq].pk_cnt, rs_dtd_reply->
      dtd_hold[final_cnt].mrg_del_ind = 1
     ELSE
      rs_dtd_reply->dtd_hold[final_cnt].mrg_del_ind = 0
      FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
        dtd_col_cnt = (dtd_col_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].
        pk_name = i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name, rs_dtd_reply->dtd_hold[
        final_cnt].pk_hold[dtd_col_cnt].pk_datatype = i_dguc_reply->dtd_hold[d.seq].pk_hold[
        pk_loop_cnt].pk_datatype
        IF (dtd_col_cnt=1)
         rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat("WHERE ",
          dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
           dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
        ELSE
         rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat(" AND ",
          dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
           dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
        ENDIF
      ENDFOR
      rs_dtd_reply->dtd_hold[final_cnt].pk_cnt = i_dguc_reply->dtd_hold[d.seq].pk_cnt
     ENDIF
    FOOT REPORT
     rs_dtd_reply->rs_tbl_cnt = i_dguc_reply->rs_tbl_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (i_refchg_tab_r_find=1)
    SET single_commit_table_name = "*"
   ELSE
    SET single_commit_table_name = ac_suf_tbl_name
   ENDIF
   SELECT INTO "NL:"
    duc.table_name, duc.column_name, duc.data_type
    FROM user_tab_columns duc
    WHERE list(duc.table_name,duc.column_name) IN (
    (SELECT
     dcd.table_name, dcd.column_name
     FROM (parser(s_dtd_name) dtd),
      (parser(s_dcd_name) dcd)
     WHERE dcd.merge_delete_ind=1
      AND dtd.merge_delete_ind=1
      AND dcd.table_name=dtd.table_name))
     AND table_name=patstring(single_commit_table_name)
    ORDER BY duc.table_name
    HEAD duc.table_name
     del_ndx = 0, del_ndx = locateval(del_ndx,1,rs_dtd_reply->rs_tbl_cnt,duc.table_name,rs_dtd_reply
      ->dtd_hold[del_ndx].tbl_name)
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,0)
     ENDIF
     del_col_cnt = 0, rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 2
    DETAIL
     IF (del_ndx > 0)
      del_col_cnt = (del_col_cnt+ 1)
      IF (mod(del_col_cnt,10)=1)
       stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,(del_col_cnt+ 9))
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name = duc.column_name
      IF ((rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name IN ("*_ID", "*_CD",
      "CODE_VALUE")))
       rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 1
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_datatype = duc.data_type
      IF (del_col_cnt=1)
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat("WHERE ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ELSE
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat(" AND ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ENDIF
     ENDIF
    FOOT  duc.table_name
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,del_col_cnt)
     ENDIF
     IF (del_col_cnt > 0)
      rs_dtd_reply->dtd_hold[del_ndx].del_cnt = del_col_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Loading UI information for versioning tables."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    duc.table_name, duc.column_name, duc.data_type
    FROM user_tab_columns duc
    WHERE list(duc.table_name,duc.column_name) IN (
    (SELECT
     dcd.table_name, dcd.column_name
     FROM (parser(s_dcd_name) dcd)
     WHERE ((dcd.table_name IN (
     (SELECT
      cv.display
      FROM code_value cv
      WHERE cv.code_set=255351.0
       AND cv.cdf_meaning IN ("ALG1", "ALG3", "ALG3D", "ALG4")
       AND cv.active_ind=1))) OR (dcd.table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF")))
      AND dcd.unique_ident_ind=1))
    ORDER BY duc.table_name
    HEAD duc.table_name
     del_ndx = 0, del_ndx = locateval(del_ndx,1,rs_dtd_reply->rs_tbl_cnt,duc.table_name,rs_dtd_reply
      ->dtd_hold[del_ndx].tbl_name)
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,0)
     ENDIF
     del_col_cnt = 0, rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 2, rs_dtd_reply->dtd_hold[del_ndx
     ].vers134_ind = 1
    DETAIL
     IF (del_ndx > 0)
      del_col_cnt = (del_col_cnt+ 1)
      IF (mod(del_col_cnt,10)=1)
       stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,(del_col_cnt+ 9))
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name = duc.column_name
      IF ((rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name IN ("*_ID", "*_CD",
      "CODE_VALUE")))
       rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 1
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_datatype = duc.data_type
      IF (del_col_cnt=1)
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat("WHERE ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ELSE
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat(" AND ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ENDIF
     ENDIF
    FOOT  duc.table_name
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,del_col_cnt)
     ENDIF
     IF (del_col_cnt > 0)
      rs_dtd_reply->dtd_hold[del_ndx].del_cnt = del_col_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Loading Reference/Mergeable Ind.")
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM (parser(s_dtd_name) dtd)
    WHERE dtd.table_name=patstring(ac_suf_tbl_name)
     AND dtd.reference_ind=1
    ORDER BY dtd.table_name
    DETAIL
     del_ndx = 0, del_ndx = locateval(del_ndx,1,rs_dtd_reply->rs_tbl_cnt,dtd.table_name,rs_dtd_reply
      ->dtd_hold[del_ndx].tbl_name), rs_dtd_reply->dtd_hold[del_ndx].ref_ind = dtd.reference_ind,
     rs_dtd_reply->dtd_hold[del_ndx].mrg_ind = dtd.mergeable_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(rs_dtd_reply->rs_tbl_cnt)),
     dm_info i,
     (dummyt dt  WITH seq = 100)
    PLAN (d)
     JOIN (dt
     WHERE (dt.seq <= rs_dtd_reply->dtd_hold[d.seq].del_cnt)
      AND (rs_dtd_reply->dtd_hold[d.seq].del_hold[dt.seq].trans_ind=0))
     JOIN (i
     WHERE i.info_domain=concat("RDDS TRANS COLUMN:",rs_dtd_reply->dtd_hold[d.seq].tbl_name)
      AND (i.info_name=rs_dtd_reply->dtd_hold[d.seq].del_hold[dt.seq].del_name))
    DETAIL
     rs_dtd_reply->dtd_hold[d.seq].del_hold[dt.seq].trans_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (i_log_type="REFCHG")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(rs_dtd_reply->dtd_hold,5))
     DETAIL
      s_load_cnt = 0, s_del_size_hold = 0, s_del_size_hold = size(rs_dtd_reply->dtd_hold[d.seq].
       del_hold,5),
      stat = alterlist(order_pk->ord_hold,s_del_size_hold)
      IF (s_del_size_hold > 0)
       FOR (del_cnt = 1 TO s_del_size_hold)
         IF ((((rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_name IN ("*_ID", "*_CD",
         "CODE_VALUE"))) OR ((rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].trans_ind=1))) )
          s_load_cnt = (s_load_cnt+ 1), order_pk->ord_hold[s_load_cnt].ord_name = rs_dtd_reply->
          dtd_hold[d.seq].del_hold[del_cnt].del_name, order_pk->ord_hold[s_load_cnt].ord_datatype =
          rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_datatype,
          order_pk->ord_hold[s_load_cnt].ord_where = rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].
          del_where, order_pk->ord_hold[s_load_cnt].trans_ind = 1
         ENDIF
       ENDFOR
       IF (s_load_cnt != s_del_size_hold)
        FOR (del_cnt = 1 TO s_del_size_hold)
          IF ( NOT ((rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_name IN ("*_ID", "*_CD",
          "CODE_VALUE")))
           AND (rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].trans_ind=0))
           s_load_cnt = (s_load_cnt+ 1), order_pk->ord_hold[s_load_cnt].ord_name = rs_dtd_reply->
           dtd_hold[d.seq].del_hold[del_cnt].del_name, order_pk->ord_hold[s_load_cnt].ord_datatype =
           rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_datatype,
           order_pk->ord_hold[s_load_cnt].ord_where = rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt]
           .del_where, order_pk->ord_hold[s_load_cnt].trans_ind = 0
          ENDIF
        ENDFOR
       ENDIF
       s_load_cnt = 0
       FOR (s_load_cnt = 1 TO s_del_size_hold)
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_name = "", rs_dtd_reply->dtd_hold[d
         .seq].del_hold[s_load_cnt].del_datatype = "", rs_dtd_reply->dtd_hold[d.seq].del_hold[
         s_load_cnt].del_where = "",
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].trans_ind = 0, rs_dtd_reply->dtd_hold[d
         .seq].del_hold[s_load_cnt].trans_ind = order_pk->ord_hold[s_load_cnt].trans_ind,
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_name = order_pk->ord_hold[s_load_cnt]
         .ord_name,
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_datatype = order_pk->ord_hold[
         s_load_cnt].ord_datatype
         IF (s_load_cnt=1)
          rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_where = concat("WHERE ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[d.seq].tbl_suffix),".",trim(order_pk->
            ord_hold[s_load_cnt].ord_name))
         ELSE
          rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_where = concat(" AND ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[d.seq].tbl_suffix),".",trim(order_pk->
            ord_hold[s_load_cnt].ord_name))
         ENDIF
       ENDFOR
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE create_pk_where_function_ora(i_dtd_ndx,io_drop_cnt,io_stmt_cnt,i_local_ind)
   DECLARE s_parm_list = vc
   DECLARE s_func_name = vc
   DECLARE s_drop_func_name = vc
   FREE RECORD iu_pk_where
   RECORD iu_pk_where(
     1 data[*]
       2 str = vc
   )
   FREE RECORD del_pk_where
   RECORD del_pk_where(
     1 data[*]
       2 str = vc
   )
   CALL generate_pk_where_str_ora(i_dtd_ndx,s_parm_list,iu_pk_where,del_pk_where,i_local_ind)
   IF (i_local_ind=0)
    SET s_func_name = concat("REFCHG_PK_WHERE_",rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_suffix,"_1")
    SET s_drop_func_name = ""
    SELECT INTO "NL:"
     uo.object_name
     FROM user_objects uo
     WHERE uo.object_name=patstring(concat("REFCHG_PK_WHERE_",rs_dtd_reply->dtd_hold[i_dtd_ndx].
       tbl_suffix,"*"))
      AND uo.object_type="FUNCTION"
     DETAIL
      IF (uo.object_name=concat("REFCHG_PK_WHERE_",rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_suffix,"_1")
      )
       s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PK_WHERE_",rs_dtd_reply->
        dtd_hold[i_dtd_ndx].tbl_suffix,"_2")
      ELSE
       s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PK_WHERE_",rs_dtd_reply->
        dtd_hold[i_dtd_ndx].tbl_suffix,"_1")
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SET s_func_name = concat("REFCHG_PK_WHERE_LOCAL_",rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_suffix)
   ENDIF
   SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pkw_function = s_func_name
   IF (s_drop_func_name > " ")
    SET io_drop_cnt = (io_drop_cnt+ 1)
    IF (mod(io_drop_cnt,50)=1)
     SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
    ENDIF
    SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',rs_dtd_reply->dtd_hold[
     i_dtd_ndx].pkw_function,'")'))
   CALL stmt_push(io_stmt_cnt,concat('ASIS("(',s_parm_list,') return varchar2 as ")'))
   CALL stmt_push(io_stmt_cnt,'ASIS("  v_pk_where_hold dm_chg_log.pk_where%TYPE; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("begin ")')
   CALL stmt_push(io_stmt_cnt,^ASIS("  if i_type = 'INS/UPD' then ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS("      select ")')
   FOR (pk_ndx = 1 TO size(iu_pk_where->data,5))
     CALL stmt_push(io_stmt_cnt,iu_pk_where->data[pk_ndx].str)
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" into v_pk_where_hold from dual;")')
   CALL stmt_push(io_stmt_cnt,^ASIS("  elsif i_type = 'DELETE' then ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS("      select ")')
   FOR (pk_ndx = 1 TO size(del_pk_where->data,5))
     CALL stmt_push(io_stmt_cnt,del_pk_where->data[pk_ndx].str)
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" into v_pk_where_hold from dual;")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_pk_where_hold); ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", rs_dtd_reply->dtd_hold[i_dtd_ndx].pkw_function WITH replace(
    "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE generate_pk_where_str_ora(i_dtd_ndx,o_parm_list,io_iu_pk_where,io_del_pk_where,
  i_local_ind)
   DECLARE s_temp_pk = vc
   DECLARE s_temp_pkn = vc
   DECLARE s_temp_type = vc
   DECLARE s_temp_trans_ind = i2
   DECLARE s_temp_pe_name = vc
   DECLARE s_cur_parm = vc
   DECLARE s_base1 = vc
   DECLARE s_base2 = vc
   DECLARE s_upto_id_cnt = i4
   DECLARE s_type = vc
   DECLARE s_pk_where_cnt = i4 WITH noconstant(0)
   DECLARE s_parm_cnt = i4
   DECLARE s_concat_ind = i2
   DECLARE s_temp_str = vc
   DECLARE s_insert_pkw_parm_pe_col = vc
   DECLARE s_insert_ndx = i4
   DECLARE s_dcd_name = vc
   DECLARE gpso_parm = vc
   DECLARE gpso_cnt = i4
   DECLARE gpso_idx = i4
   SET s_dcd_name = "DM_COLUMNS_DOC_LOCAL"
   SET o_parm_list = "i_type varchar2"
   FOR (type_ndx = 1 TO 2)
     SET s_concat_ind = 0
     SET s_pk_where_cnt = 0
     IF (type_ndx=1)
      SET s_type = "INS/UPD"
     ELSE
      SET s_type = "DELETE"
     ENDIF
     IF (type_ndx=1)
      SET s_parm_cnt = 0
      IF (i_local_ind=0)
       DELETE  FROM dm_refchg_pkw_parm drpp
        WHERE (drpp.table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
       ;end delete
      ENDIF
     ENDIF
     IF ((((rs_dtd_reply->dtd_hold[i_dtd_ndx].del_cnt=0)) OR (type_ndx=2
      AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
      SET s_upto_id_cnt = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_cnt
     ELSE
      SET s_upto_id_cnt = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_cnt
     ENDIF
     FOR (where_ndx = 1 TO s_upto_id_cnt)
       IF (size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5) > 0
        AND  NOT (type_ndx=2
        AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1)))
        SET s_temp_pk = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_where
        SET s_temp_pkn = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_name
        SET s_temp_type = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_datatype
        SET s_temp_trans_ind = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].trans_ind
       ELSE
        SET s_temp_pk = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_where
        SET s_temp_pkn = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_name
        SET s_temp_type = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_datatype
        SET s_temp_trans_ind = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].trans_ind
       ENDIF
       SET s_temp_pe_name = " "
       SET s_insert_pkw_parm_pe_col = " "
       SELECT
        IF (size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5) > 0
         AND  NOT (type_ndx=2
         AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1)))
         WHERE (dcd.table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
          AND (dcd.column_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_name)
          AND  NOT (dcd.parent_entity_col IN ("", " "))
        ELSE
         WHERE (dcd.table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
          AND (dcd.column_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_name)
          AND  NOT (dcd.parent_entity_col IN ("", " "))
        ENDIF
        INTO "nl:"
        dcd.parent_entity_col
        FROM (parser(s_dcd_name) dcd)
        DETAIL
         s_insert_pkw_parm_pe_col = dcd.parent_entity_col, s_temp_pe_name = concat("i_",substring(1,
           28,dcd.parent_entity_col))
        WITH nocounter
       ;end select
       SET loop_cnt = 0
       IF (type_ndx=1
        AND s_insert_pkw_parm_pe_col > " "
        AND locateval(s_insert_ndx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5),
        s_insert_pkw_parm_pe_col,rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[s_insert_ndx].del_name)=0
        AND locateval(s_insert_ndx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold,5),
        s_insert_pkw_parm_pe_col,rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[s_insert_ndx].pk_name)=0)
        SELECT INTO "NL:"
         FROM dm_refchg_pkw_parm
         WHERE column_name=s_insert_pkw_parm_pe_col
          AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
         WITH nocounter
        ;end select
        SET gpso_cnt = curqual
        IF (gpso_cnt=0)
         SET s_parm_cnt = (s_parm_cnt+ 1)
         SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
         SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name =
         s_insert_pkw_parm_pe_col
         SET o_parm_list = concat(o_parm_list,",i_",substring(1,28,s_insert_pkw_parm_pe_col),
          " VARCHAR2")
         IF (i_local_ind=0)
          INSERT  FROM dm_refchg_pkw_parm
           SET parm_nbr = s_parm_cnt, column_name = s_insert_pkw_parm_pe_col, table_name =
            rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name
           WITH nocounter
          ;end insert
         ENDIF
        ENDIF
       ENDIF
       IF (s_temp_pe_name="")
        SET s_temp_pe_name = "''''||' '||''''"
       ELSE
        SET s_temp_pe_name = concat("dm_refchg_breakup_str(",s_temp_pe_name,")")
       ENDIF
       SET s_cur_parm = concat("i_",substring(1,28,s_temp_pkn))
       CASE (s_temp_type)
        OF "VARCHAR":
        OF "ROWID":
        OF "VARCHAR2":
        OF "CHAR":
         IF (((type_ndx=1) OR (type_ndx=2
          AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
          SET gpso_parm = concat(",",s_cur_parm," ",s_temp_type)
          IF (findstring(gpso_parm,o_parm_list)=0)
           SET o_parm_list = concat(o_parm_list,",",s_cur_parm," ",s_temp_type)
          ENDIF
          IF (locateval(gpso_idx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,5),s_temp_pkn,
           rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[gpso_idx].column_name)=0)
           SET s_parm_cnt = (s_parm_cnt+ 1)
           SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
           SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = s_temp_pkn
           IF (i_local_ind=0)
            SELECT INTO "NL:"
             FROM dm_refchg_pkw_parm
             WHERE column_name=s_temp_pkn
              AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
             WITH nocounter
            ;end select
            SET gpso_cnt = curqual
            IF (gpso_cnt=0)
             INSERT  FROM dm_refchg_pkw_parm
              SET parm_nbr = s_parm_cnt, column_name = s_temp_pkn, table_name = rs_dtd_reply->
               dtd_hold[i_dtd_ndx].tbl_name
             ;end insert
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         SET s_pk_where_cnt = (s_pk_where_cnt+ 1)
         IF (s_type="INS/UPD")
          SET stat = alterlist(io_iu_pk_where->data,s_pk_where_cnt)
         ELSE
          SET stat = alterlist(io_del_pk_where->data,s_pk_where_cnt)
         ENDIF
         SET s_base1 = concat(s_temp_pk,"'||decode(",s_cur_parm,
          ",null,' is null',chr(0),'=char(0)','='||dm_refchg_breakup_str(",s_cur_parm,
          ")")
         SET s_base2 = concat(s_temp_pk,"'||decode(",s_cur_parm,
          ",null,' is null',chr(0),'=char(0)','='||dm_refchg_breakup_str(",s_cur_parm,
          "))")
         IF (where_ndx != s_upto_id_cnt)
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS("''''||'^,s_base2,
            "||''''||','||",'")')
          ELSE
           SET s_temp_str = concat(^ASIS(" '^,s_base1,")||",'")')
           IF (s_type="INS/UPD")
            SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ENDIF
          ENDIF
         ELSE
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           IF (s_concat_ind=0)
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" '^,s_base2,'")')
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS("''''||'^,s_base2,
             ^||''''||')'")^)
           ENDIF
          ELSE
           IF (s_upto_id_cnt > 1
            AND size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5) > 0)
            SET s_temp_str = concat(^ASIS(" ' '|| '^,s_base1,')")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ELSE
            SET s_temp_str = concat(^ASIS("  '^,s_base1,')")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        OF "DATE":
         IF (((type_ndx=1) OR (type_ndx=2
          AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
          SET gpso_parm = concat(",",s_cur_parm," ",s_temp_type)
          IF (findstring(gpso_parm,o_parm_list)=0)
           SET o_parm_list = concat(o_parm_list,",",s_cur_parm," ",s_temp_type)
          ENDIF
          IF (locateval(gpso_idx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,5),s_temp_pkn,
           rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[gpso_idx].column_name)=0)
           SET s_parm_cnt = (s_parm_cnt+ 1)
           SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
           SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = s_temp_pkn
           IF (i_local_ind=0)
            SELECT INTO "NL:"
             FROM dm_refchg_pkw_parm
             WHERE column_name=s_temp_pkn
              AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
             WITH nocounter
            ;end select
            SET gpso_cnt = curqual
            IF (gpso_cnt=0)
             INSERT  FROM dm_refchg_pkw_parm
              SET parm_nbr = s_parm_cnt, column_name = s_temp_pkn, table_name = rs_dtd_reply->
               dtd_hold[i_dtd_ndx].tbl_name
             ;end insert
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         SET s_pk_where_cnt = (s_pk_where_cnt+ 1)
         IF (s_type="INS/UPD")
          SET stat = alterlist(io_iu_pk_where->data,s_pk_where_cnt)
         ELSE
          SET stat = alterlist(io_del_pk_where->data,s_pk_where_cnt)
         ENDIF
         SET s_base1 = concat("'||decode(to_char(",s_cur_parm,
          "),null,' is null ',' = cnvtdatetime('||''''||to_char(",s_cur_parm,")||''''||')')")
         SET s_base2 = concat(" ''''||'",s_temp_pk,"'||decode(to_char(",s_cur_parm,
          "),null,' is null ',' = cnvtdatetime('||'",
          char(94),"'||to_char(",s_cur_parm,")||'",char(94),
          "'||')')||''''")
         IF (where_ndx != s_upto_id_cnt)
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS("',s_base2,^||','||")^)
          ELSE
           SET s_temp_str = concat(^ASIS(" '^,s_temp_pk," ",s_base1,'||")')
           IF (s_type="INS/UPD")
            SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ENDIF
          ENDIF
         ELSE
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS("',s_base2,^||')'")^)
          ELSE
           SET s_temp_str = concat(^ASIS(" '^,s_temp_pk,s_base1,'")')
           IF (s_type="INS/UPD")
            SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ENDIF
          ENDIF
         ENDIF
        ELSE
         IF (((type_ndx=1) OR (type_ndx=2
          AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
          SET gpso_parm = concat(",",s_cur_parm," ",s_temp_type)
          IF (findstring(gpso_parm,o_parm_list)=0)
           SET o_parm_list = concat(o_parm_list,",",s_cur_parm," ",s_temp_type)
          ENDIF
          IF (locateval(gpso_idx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,5),s_temp_pkn,
           rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[gpso_idx].column_name)=0)
           SET s_parm_cnt = (s_parm_cnt+ 1)
           SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
           SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = s_temp_pkn
           IF (i_local_ind=0)
            SELECT INTO "NL:"
             FROM dm_refchg_pkw_parm
             WHERE column_name=s_temp_pkn
              AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
             WITH nocounter
            ;end select
            SET gpso_cnt = curqual
            IF (gpso_cnt=0)
             INSERT  FROM dm_refchg_pkw_parm
              SET parm_nbr = s_parm_cnt, column_name = s_temp_pkn, table_name = rs_dtd_reply->
               dtd_hold[i_dtd_ndx].tbl_name
             ;end insert
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         SET s_pk_where_cnt = (s_pk_where_cnt+ 1)
         IF (s_type="INS/UPD")
          SET stat = alterlist(io_iu_pk_where->data,s_pk_where_cnt)
         ELSE
          SET stat = alterlist(io_del_pk_where->data,s_pk_where_cnt)
         ENDIF
         IF (s_temp_trans_ind=1
          AND s_type="DELETE"
          AND (((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)) OR ((rs_dtd_reply->dtd_hold[
         i_dtd_ndx].vers134_ind=1))) )
          SET s_base1 = concat("''''||'",s_temp_pk,"='||''''||',dm_trans3('||''''||'",rs_dtd_reply->
           dtd_hold[i_dtd_ndx].tbl_name,"'||''''||','||''''||'",
           s_temp_pkn,"'||''''||','||decode(to_char(",s_cur_parm,"),null,' null ',decode(trunc(",
           s_cur_parm,
           ") - ",s_cur_parm,",0,to_char(",s_cur_parm,")||'.0',to_char(",
           s_cur_parm,")))||', <SOURCE_IND>,'||",s_temp_pe_name,"||')")
          IF (where_ndx != s_upto_id_cnt)
           IF (s_concat_ind=0)
            SET s_concat_ind = 1
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" 'CONCAT('||^,s_base1,
             ",'||",'")')
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS(" ',s_base1,",'||",'")')
           ENDIF
          ELSE
           IF (s_concat_ind=0)
            SET s_concat_ind = 1
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" 'CONCAT('||^,s_base1,
             ^)'")^)
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS("',s_base1,^)'")^)
           ENDIF
          ENDIF
         ELSE
          SET s_base2 = concat("'",s_temp_pk,"'||decode(to_char(",s_cur_parm,
           "),null,' is null ',' ='||decode(trunc(",
           s_cur_parm,") - ",s_cur_parm,",0,to_char(",s_cur_parm,
           ")||'.0',to_char(",s_cur_parm,")))")
          IF (where_ndx != s_upto_id_cnt)
           IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
            AND s_type="DELETE")
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" ''''||^,s_base2,
             ^||''''||','||")^)
           ELSE
            SET s_temp_str = concat('ASIS(" ',s_base2,'||")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ENDIF
          ELSE
           IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
            AND s_type="DELETE")
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" ''''||^,s_base2,
             ^||''''||')'")^)
           ELSE
            SET s_temp_str = concat('ASIS(" ',s_base2,'")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ENDIF
          ENDIF
         ENDIF
       ENDCASE
     ENDFOR
     IF (type_ndx=1
      AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name="SEG_GRP_SEQ_R"))
      SET o_parm_list = concat(o_parm_list,",","I_SEG_CD"," ","NUMBER")
      SET s_parm_cnt = (s_parm_cnt+ 1)
      IF (i_local_ind=0)
       SET dm_err->eproc = "Inserting SEG_GRP_SEQ_R info into DM_REFCHG_PKW_PARM."
       CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
       INSERT  FROM dm_refchg_pkw_parm drpp
        SET drpp.parm_nbr = s_parm_cnt, drpp.column_name = "SEG_CD", drpp.table_name = rs_dtd_reply->
         dtd_hold[i_dtd_ndx].tbl_name
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ENDIF
      ENDIF
      SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
      SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = "SEG_CD"
      SET io_iu_pk_where->data[s_pk_where_cnt].str = concat(
       ^ASIS("'where t3292.seg_cd in(select sr.seg_cd from segment_reference sr where sr.seg_grp_cd = (^,
       "(select sr2.seg_grp_cd from segment_reference sr2 where sr2.seg_cd = '",
       "||decode(trunc(i_seg_cd) - i_seg_cd,0,to_char(i_seg_cd) ||","'.0',to_char(i_seg_cd))",
       ^||')))' ")^)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE stmt_push(io_cnt,i_text)
   SET io_cnt = (io_cnt+ 1)
   IF (mod(io_cnt,30)=1)
    SET stat = alterlist(stmt_buffer->data,(io_cnt+ 29))
   ENDIF
   SET stmt_buffer->data[io_cnt].stmt = i_text
 END ;Subroutine
 SUBROUTINE create_ptam_function_ora(sbr_trg_data_rs,i_trg_ndx,io_drop_cnt,io_stmt_cnt)
   DECLARE s_tab_name = vc WITH protect, noconstant(" ")
   DECLARE s_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_drop_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_ptam_template = vc WITH protect, noconstant(" ")
   DECLARE cpfo_ndx = i4 WITH protect, noconstant(0)
   DECLARE s_ptam_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_col_name = vc WITH protect, noconstant(" ")
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   DECLARE s_parm_name = vc WITH protect, noconstant(" ")
   DECLARE s_cust_idx = i4 WITH protect, noconstant(0)
   DECLARE s_cust_ind = i2 WITH protect, noconstant(0)
   DECLARE s_cust_parm_ind = i2 WITH protect, noconstant(0)
   DECLARE s_cust_name = vc WITH protect, noconstant(" ")
   FREE RECORD cpfo_parm
   RECORD cpfo_parm(
     1 parm_cnt = i4
     1 qual[*]
       2 parm_name = vc
   ) WITH protect
   SET s_tab_name = sbr_trg_data_rs->qual[i_trg_ndx].table_name
   SET s_ptam_func_name = concat("PTAM_MATCH_QUERY_",sbr_trg_data_rs->qual[i_trg_ndx].table_suffix)
   SET s_func_name = concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->qual[i_trg_ndx].table_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining ptam_match function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->qual[i_trg_ndx].
      table_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     IF (uo.object_name=concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->qual[i_trg_ndx].table_suffix,
      "_1"))
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->
       qual[i_trg_ndx].table_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->
       qual[i_trg_ndx].table_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET sbr_trg_data_rs->qual[i_trg_ndx].ptam_match_function = s_func_name
   IF (s_drop_func_name > " ")
    SET io_drop_cnt = (io_drop_cnt+ 1)
    IF (mod(io_drop_cnt,50)=1)
     SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
    ENDIF
    SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
   ENDIF
   SET dm_err->eproc = "Gathering PTAM match parms."
   SELECT INTO "nl:"
    dpwp.column_name
    FROM dm_pk_where_parm dpwp
    WHERE dpwp.table_name=s_tab_name
     AND dpwp.function_type="PTAM_MATCH"
     AND dpwp.delete_ind=1
    ORDER BY dpwp.parm_nbr, dpwp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,parm_cnt),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[parm_cnt].column_name = cnvtupper(dpwp.column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[parm_cnt].data_type = cnvtupper(dpwp.data_type),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[parm_cnt].exist_ind = dpwp.exist_ind, sbr_trg_data_rs
     ->qual[i_trg_ndx].ptam_parm[parm_cnt].trans_ind = dpwp.trans_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = concat("Gathering custom pl/sql info for table ",s_tab_name)
   SELECT INTO "nl:"
    FROM dm_refchg_sql_obj drso
    WHERE drso.active_ind=1
     AND drso.execution_flag IN (1, 2)
     AND drso.table_name=s_tab_name
     AND expand(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drso.column_name,
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name)
    DETAIL
     cpfo_ndx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drso.column_name,
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name), sbr_trg_data_rs->qual[i_trg_ndx
     ].ptam_parm[cpfo_ndx].object_name = drso.object_name, sbr_trg_data_rs->qual[i_trg_ndx].
     ptam_parm[cpfo_ndx].all_exist_ind = 1,
     s_cust_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (s_cust_ind=1)
    SELECT INTO "nl:"
     FROM dm_refchg_sql_obj_parm drsop
     WHERE drsop.active_ind=1
      AND expand(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drsop.object_name,
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].object_name)
     ORDER BY drsop.object_name, drsop.parm_nbr
     HEAD drsop.object_name
      cpfo_ndx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drsop
       .object_name,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].object_name), parm_cnt = 0
     DETAIL
      parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx]
       .custom_parm,parm_cnt), sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].custom_parm[
      parm_cnt].parm_name = drsop.column_name,
      s_cust_idx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drsop
       .column_name,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name)
      IF (s_cust_idx=0)
       sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].all_exist_ind = 0
      ENDIF
     FOOT  drsop.object_name
      IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].all_exist_ind=1))
       s_cust_parm_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
    SET s_cust_ind = s_cust_parm_ind
   ENDIF
   SET dm_err->eproc = concat("Gathering RE/PE info for table ",s_tab_name)
   SELECT INTO "nl:"
    dcdl.root_entity_name, dcdl.parent_entity_col
    FROM dm_columns_doc_local dcdl
    WHERE dcdl.table_name=s_tab_name
     AND expand(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),dcdl.column_name,
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name)
    DETAIL
     cpfo_ndx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),dcdl.column_name,
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name), sbr_trg_data_rs->qual[i_trg_ndx
     ].ptam_parm[cpfo_ndx].re_name = cnvtupper(dcdl.root_entity_name), sbr_trg_data_rs->qual[
     i_trg_ndx].ptam_parm[cpfo_ndx].pe_col = cnvtupper(dcdl.parent_entity_col),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].xcptn_flag = dcdl.exception_flg
     IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].trans_ind=1))
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].cnst_val = dcdl.constant_value
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = concat("Gathering pk_template for table ",s_tab_name)
   SELECT INTO "nl:"
    dpw.ptam_match_query
    FROM dm_pk_where dpw
    WHERE dpw.table_name=s_tab_name
     AND dpw.delete_ind=1
    DETAIL
     s_ptam_template = dpw.ptam_match_query, sbr_trg_data_rs->qual[i_trg_ndx].ptam_hash = dpw
     .ptam_match_hash
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
     i_trg_ndx].ptam_match_function,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
    SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     )
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(",i_db_link varchar2 default ' ') return varchar2 as v_ptam_match dm_chg_log.ptam_match_query%TYPE; ")^
    )
   CALL stmt_push(io_stmt_cnt,'ASIS("v_temp_str varchar2(4000); begin ")')
   CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',s_ptam_template,
     ' into v_ptam_match from dual; ")'))
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_ptam_match);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,io_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].ptam_match_function WITH replace
   ("REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',s_ptam_func_name,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
    SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     )
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,
    'ASIS(",i_src_id number,i_tgt_id number,i_db_link varchar2,i_local_ind number ")')
   CALL stmt_push(io_stmt_cnt,^ASIS(",i_xlat_type varchar2 default 'FROM'")^)
   CALL stmt_push(io_stmt_cnt,
    'ASIS(") return number as v_ptam_result number; v_temp_str varchar2(2000); ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("v_match_str varchar(4000); v_mapping_nbr number; begin ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("if i_local_ind = 1 then ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("   v_temp_str := ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].exist_ind=1))
      IF (cpfo_ndx=1)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
         cpfo_ndx].column_name,^='||")^))
      ELSE
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("||'::'||'^,sbr_trg_data_rs->qual[i_trg_ndx].
         ptam_parm[cpfo_ndx].column_name,^='||")^))
      ENDIF
      IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].cnst_val > ""))
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
         cpfo_ndx].cnst_val,^'")^))
      ELSE
       SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].
        column_name)
       IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type IN ("VARCHAR", "CHAR",
       "VARCHAR2")))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(i_',s_parm_name,^,'!NL!')")^))
       ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type="DATE"))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(i_',s_parm_name,
          ^,'DD-MON-YYYY HH24:MI:SS','nls_date_language=american'),'!NL!')")^))
       ELSE
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(i_',s_parm_name,
          ^,'TM9','nls_numeric_characters=''.,'''),'!NL!')")^))
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS("; else   ")')
   IF (s_cust_ind=1)
    CALL stmt_push(io_stmt_cnt,
     'ASIS("   select di.info_number into v_mapping_nbr from dm_info di where di.info_domain = ")')
    CALL stmt_push(io_stmt_cnt,
     ^ASIS("'RDDS ENV PAIR' and di.info_name = i_src_id||'::'||i_tgt_id; ")^)
   ENDIF
   CALL stmt_push(io_stmt_cnt,'ASIS(" v_match_str := ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     SET s_col_name = sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     SET s_parm_name = substring(1,28,s_col_name)
     IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].exist_ind=1))
      IF (cpfo_ndx=1)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'select ''^,s_col_name,^=''||")^))
      ELSE
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("||''::''||''^,s_col_name,^=''||")^))
      ENDIF
      IF (trim(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].object_name) > " "
       AND (sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].all_exist_ind=1))
       CALL stmt_push(io_stmt_cnt,'ASIS(" nvl( ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" to_char(")')
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'||replace('^,sbr_trg_data_rs->qual[i_trg_ndx].
         ptam_parm[cpfo_ndx].object_name,
         ^','::SOURCE TARGET MAPPING::',to_char(v_mapping_nbr))||'(2")^))
       FOR (s_cust_idx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].custom_parm,5
        ))
         SET s_cust_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].
          custom_parm[s_cust_idx].parm_name)
         CALL stmt_push(io_stmt_cnt,concat('ASIS(",:c',trim(cnvtstring(s_cust_idx)),'")'))
         SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 1)
         SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
         SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = concat("i_",s_cust_name)
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(") ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(")")')
       CALL stmt_push(io_stmt_cnt,^ASIS(",''!NL!'')")^)
      ELSEIF ((((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].trans_ind=0)) OR ((
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].xcptn_flag=1))) )
       SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 1)
       SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
       SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = concat("i_",s_parm_name)
       IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type IN ("VARCHAR", "CHAR",
       "VARCHAR2")))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(:p',trim(cnvtstring(cpfo_ndx)),^,''!NL!'')")^))
       ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type="DATE"))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(:p',trim(cnvtstring(cpfo_ndx)),
          ^,''DD-MON-YYYY HH24:MI:SS'',''nls_date_language=american''),''!NL!'')")^))
       ELSE
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(:p',trim(cnvtstring(cpfo_ndx)),
          ^,''TM9'',''nls_numeric_characters=''''.,''''''),''!NL!'')")^))
       ENDIF
      ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].cnst_val > ""))
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("''^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
         cpfo_ndx].cnst_val,^''")^))
      ELSE
       CALL stmt_push(io_stmt_cnt,'ASIS("nvl(to_char(REFCHG_TRANS(")')
       IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].re_name > ""))
        CALL stmt_push(io_stmt_cnt,concat(^ASIS("''^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
          cpfo_ndx].re_name,"'',:p",trim(cnvtstring(cpfo_ndx)),",:s",
          trim(cnvtstring(cpfo_ndx)),",:t",trim(cnvtstring(cpfo_ndx)),",:x",trim(cnvtstring(cpfo_ndx)
           ),
          ^)),''!NL!'')")^))
        SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 4)
        SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 3)].parm_name = concat("i_",s_parm_name)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 2)].parm_name = "i_src_id"
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 1)].parm_name = "i_tgt_id"
        SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = "i_xlat_type"
       ELSE
        CALL stmt_push(io_stmt_cnt,concat(^ASIS("EVALUATE_PE_NAME(''^,s_tab_name,"'',''",s_col_name,
          "'',''",
          sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].pe_col,"'',:e",trim(cnvtstring(
            cpfo_ndx)),"),:p",trim(cnvtstring(cpfo_ndx)),
          ",:s",trim(cnvtstring(cpfo_ndx)),",:t",trim(cnvtstring(cpfo_ndx)),",:x",
          trim(cnvtstring(cpfo_ndx)),^)),''!NL!'')")^))
        SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 5)
        SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 4)].parm_name = concat("i_",trim(substring(1,28,
           sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].pe_col)))
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 3)].parm_name = concat("i_",s_parm_name)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 2)].parm_name = "i_src_id"
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 1)].parm_name = "i_tgt_id"
        SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = "i_xlat_type"
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,^ASIS(" from dual'; ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" execute immediate v_match_str into v_temp_str using ")')
   FOR (cpfo_ndx = 1 TO cpfo_parm->parm_cnt)
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat('ASIS("',cpfo_parm->qual[cpfo_ndx].parm_name,'")'))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat('ASIS(", ',cpfo_parm->qual[cpfo_ndx].parm_name,'")'))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS("; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  end  if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("dbms_output.put_line (v_temp_str); ")')
   CALL stmt_push(io_stmt_cnt,
    'ASIS(" select dbms_utility.get_hash_value(v_temp_str, 0, 1073741824) into v_ptam_result from dual; ")'
    )
   CALL stmt_push(io_stmt_cnt,
    ^ASIS("  dm2_context_control('RDDS_PTAM_MATCH_RESULT_STR', v_temp_str);")^)
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_ptam_result);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", s_ptam_func_name WITH replace("REQUEST","STMT_BUFFER"), replace(
    "REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_pkw_function_ora(sbr_trg_data_rs,i_trg_ndx,io_drop_cnt,io_stmt_cnt)
   DECLARE s_tab_name = vc WITH protect, noconstant(" ")
   DECLARE s_tab_suffix = vc WITH protect, noconstant(" ")
   DECLARE s_iu_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_d_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_drop_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_iu_pkw_template = vc WITH protect, noconstant(" ")
   DECLARE s_d_pkw_template = vc WITH protect, noconstant(" ")
   DECLARE cpfo_ndx = i4 WITH protect, noconstant(0)
   DECLARE s_col_name = vc WITH protect, noconstant(" ")
   DECLARE s_parm_name = vc WITH protect, noconstant(" ")
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   DECLARE s_idx2 = i4 WITH protect, noconstant(0)
   SET s_tab_name = sbr_trg_data_rs->qual[i_trg_ndx].table_name
   SET s_tab_suffix = sbr_trg_data_rs->qual[i_trg_ndx].table_suffix
   SET s_iu_func_name = concat("REFCHG_PKW_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining insert/update function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_PKW_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     IF (uo.object_name=concat("REFCHG_PKW_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_iu_func_name = concat("REFCHG_PKW_",s_tab_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_iu_func_name = concat("REFCHG_PKW_",s_tab_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET sbr_trg_data_rs->qual[i_trg_ndx].pkw_function = s_iu_func_name
   IF (s_drop_func_name > " ")
    SET io_drop_cnt = (io_drop_cnt+ 1)
    IF (mod(io_drop_cnt,50)=1)
     SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
    ENDIF
    SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
   ENDIF
   SET s_d_func_name = concat("REFCHG_DEL_PKW_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining delete function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_DEL_PKW_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     IF (uo.object_name=concat("REFCHG_DEL_PKW_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_d_func_name = concat("REFCHG_DEL_PKW_",s_tab_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_d_func_name = concat("REFCHG_DEL_PKW_",s_tab_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_function = s_d_func_name
   IF (s_drop_func_name > " ")
    SET io_drop_cnt = (io_drop_cnt+ 1)
    IF (mod(io_drop_cnt,50)=1)
     SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
    ENDIF
    SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
   ENDIF
   SET dm_err->eproc = "Gathering REFCHG_PKW parms."
   SELECT INTO "nl:"
    dpwp.column_name
    FROM dm_pk_where_parm dpwp
    WHERE dpwp.table_name=s_tab_name
     AND dpwp.function_type="PK_WHERE"
     AND dpwp.delete_ind=0
    ORDER BY dpwp.parm_nbr, dpwp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,parm_cnt),
     sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[parm_cnt].column_name = cnvtupper(dpwp.column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[parm_cnt].data_type = cnvtupper(dpwp.data_type),
     sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[parm_cnt].nullable = "Y"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Gathering REFCHG_DEL_PKW parms."
   SELECT INTO "nl:"
    dpwp.column_name
    FROM dm_pk_where_parm dpwp
    WHERE dpwp.table_name=s_tab_name
     AND dpwp.function_type="PK_WHERE"
     AND dpwp.delete_ind=1
    ORDER BY dpwp.parm_nbr, dpwp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,
      parm_cnt), sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[parm_cnt].column_name = cnvtupper(dpwp
      .column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[parm_cnt].data_type = cnvtupper(dpwp.data_type),
     sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[parm_cnt].nullable = "Y", sbr_trg_data_rs->qual[
     i_trg_ndx].del_pkw_parm[parm_cnt].exist_ind = dpwp.exist_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Gathering nullable information."
   SELECT INTO "nl:"
    FROM dm2_user_notnull_cols dunc
    WHERE dunc.table_name=s_tab_name
    DETAIL
     s_idx2 = 0, s_idx2 = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5),
      dunc.column_name,sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[s_idx].column_name)
     IF (s_idx2 > 0)
      sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[s_idx2].nullable = "N"
     ENDIF
     s_idx2 = 0, s_idx2 = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5),dunc
      .column_name,sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[s_idx].column_name)
     IF (s_idx2 > 0)
      sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[s_idx2].nullable = "N"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = concat("Gathering pk_template for table ",s_tab_name)
   SELECT INTO "nl:"
    dpw.pk_where
    FROM dm_pk_where dpw
    WHERE dpw.table_name=s_tab_name
    DETAIL
     IF (dpw.delete_ind=0)
      s_iu_pkw_template = dpw.pk_where, sbr_trg_data_rs->qual[i_trg_ndx].pkw_hash = dpw.pk_where_hash
     ELSE
      s_d_pkw_template = dpw.pk_where, sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_hash = dpw
      .pk_where_hash
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
     i_trg_ndx].pkw_function,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
    SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name)
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       pkw_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       pkw_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(",i_db_link varchar2 default ' ',i_cs_pk_ind number default 1) ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" return varchar2 as v_iu_pk_where dm_chg_log.pk_where%TYPE; ")'
    )
   CALL stmt_push(io_stmt_cnt,'ASIS(" begin ")')
   CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',s_iu_pkw_template,
     ' into v_iu_pk_where from dual; ")'))
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_iu_pk_where);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].pkw_function WITH replace(
    "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
     i_trg_ndx].del_pkw_function,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
    SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].
     column_name)
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       del_pkw_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       del_pkw_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,^ASIS(",i_db_link varchar2 default ' ') ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" return varchar2 as v_d_pk_where dm_chg_log.pk_where%TYPE; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS(" begin ")')
   CALL stmt_push(io_stmt_cnt,concat('ASIS("   select ',s_d_pkw_template,
     ' into v_d_pk_where from dual; ")'))
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_d_pk_where);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_function WITH replace(
    "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_colstring_function_ora(sbr_trg_data_rs,i_trg_ndx,io_drop_cnt,io_stmt_cnt)
   DECLARE s_tab_name = vc WITH protect, noconstant(" ")
   DECLARE s_tab_suffix = vc WITH protect, noconstant(" ")
   DECLARE s_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_drop_func_name = vc WITH protect, noconstant(" ")
   DECLARE cpfo_ndx = i4 WITH protect, noconstant(0)
   DECLARE s_column_name = vc WITH protect, noconstant(" ")
   DECLARE s_parm_name = vc WITH protect, noconstant(" ")
   SET s_tab_name = sbr_trg_data_rs->qual[i_trg_ndx].table_name
   SET s_tab_suffix = sbr_trg_data_rs->qual[i_trg_ndx].table_suffix
   SET s_func_name = concat("REFCHG_COLSTRING_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining colstring function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_COLSTRING_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     IF (uo.object_name=concat("REFCHG_COLSTRING_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_COLSTRING_",s_tab_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_COLSTRING_",s_tab_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET sbr_trg_data_rs->qual[i_trg_ndx].colstring_function = s_func_name
   IF (s_drop_func_name > " ")
    SET io_drop_cnt = (io_drop_cnt+ 1)
    IF (mod(io_drop_cnt,50)=1)
     SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
    ENDIF
    SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
   ENDIF
   SET dm_err->eproc = "Gathering COLSTRING parms."
   SELECT INTO "nl:"
    dcp.column_name
    FROM dm_colstring_parm dcp
    WHERE dcp.table_name=s_tab_name
    ORDER BY dcp.parm_nbr, dcp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm,
      parm_cnt), sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[parm_cnt].column_name = cnvtupper(
      dcp.column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[parm_cnt].data_type = cnvtupper(dcp.data_type)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
     i_trg_ndx].colstring_function,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm,5))
    SET s_parm_name = create_input_parm_ora(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx]
     .column_name,cpfo_ndx)
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       colstring_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       colstring_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,
    'ASIS(") return varchar2 as v_colstring dm_chg_log.col_string%TYPE; begin ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  select  substr(")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm,5))
     SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx].column_name
     SET s_parm_name = create_input_parm_ora(s_column_name,cpfo_ndx)
     IF (cpfo_ndx > 1)
      CALL stmt_push(io_stmt_cnt,'ASIS("||")')
     ENDIF
     CALL stmt_push(io_stmt_cnt,concat(^ASIS("'<^,s_column_name,^>'||")^))
     IF ((sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
     "VARCHAR2", "ROWID")))
      CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(',s_parm_name,",null,'!NL!',replace(replace(",
        s_parm_name,^,'<','!&lt!'),'>','!&gt!'))||")^))
     ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx].data_type IN ("DATE")))
      CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(to_char(',s_parm_name,"),null,'!NL!',to_char(",
        s_parm_name,^,'DD-MON-YYYY HH24:MI:SS'))||")^))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(to_char(',s_parm_name,"),null,'!NL!',to_char(",
        s_parm_name,'))||")'))
     ENDIF
     CALL stmt_push(io_stmt_cnt,concat(^ASIS("'</^,s_column_name,^>'")^))
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(",1,4000) into v_colstring from dual;")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_colstring);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].colstring_function WITH replace(
    "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET s_func_name = concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining pk/ptam colstring function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     IF (uo.object_name=concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_2"
       )
     ELSE
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_1"
       )
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (s_drop_func_name > " ")
    SET io_drop_cnt = (io_drop_cnt+ 1)
    IF (mod(io_drop_cnt,50)=1)
     SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
    ENDIF
    SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
   ENDIF
   SET sbr_trg_data_rs->qual[i_trg_ndx].pk_ptam_function = s_func_name
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',s_func_name,
     '(pk_where_ind number, delete_ind number, i_colstring dm_chg_log.col_string%TYPE")'))
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(",i_db_link varchar2 default ' ',i_cs_pk_ind number default 1) ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" return varchar2 as v_where dm_chg_log.pk_where%TYPE; ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
     CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_pkw_col',format(cpfo_ndx,"##;P0"),
       ' varchar2(4000);")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
     CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ' varchar2(4000);")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_ptam_col',format(cpfo_ndx,"##;P0"),
       ' varchar2(4000);")'))
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS("begin ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("if pk_where_ind = 1 and delete_ind = 0 then ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  if ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   and instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" then ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
     SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name
     CALL stmt_push(io_stmt_cnt,concat('ASIS("    v_pkw_col',format(cpfo_ndx,"##;P0"),':= ")'))
     CALL stmt_push(io_stmt_cnt,concat(^ASIS(" substr(i_colstring,instr(i_colstring,'<^,s_column_name,
       ">',1)+",trim(cnvtstring((size(s_column_name,1)+ 2))),",instr(i_colstring,'</",
       s_column_name,">',1)-(instr(i_colstring,'<",s_column_name,">',1)+",trim(cnvtstring((size(
          s_column_name,1)+ 2))),
       ')); ")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',sbr_trg_data_rs->qual[i_trg_ndx].
       pkw_function,'(")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,'ASIS(",")')
    ENDIF
    IF ((sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
    "VARCHAR2", "ROWID")))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_pkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,'char(0)',chr(0),replace(replace(v_pkw_col",format(cpfo_ndx,"##;P0"),
       ^,'!&lt!','<'),'!&gt!','>'))")^))
    ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].data_type="DATE"))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("to_date(decode(v_pkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_pkw_col",format(cpfo_ndx,"##;P0"),^),'DD-MON-YYYY HH24:MI:SS') ")^))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_pkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_pkw_col",format(cpfo_ndx,"##;P0"),') ")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(",i_db_link, i_cs_pk_ind) into v_where from dual; ")')
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(" else raise_application_error(-20205,'Error constructing pk_where from colstring.'); ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("elsif pk_where_ind = 1 and delete_ind = 1 then ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  if ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   and instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" then ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
     SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name
     CALL stmt_push(io_stmt_cnt,concat('ASIS("    v_dpkw_col',format(cpfo_ndx,"##;P0"),':= ")'))
     CALL stmt_push(io_stmt_cnt,concat(^ASIS(" substr(i_colstring,instr(i_colstring,'<^,s_column_name,
       ">',1)+",trim(cnvtstring((size(s_column_name,1)+ 2))),",instr(i_colstring,'</",
       s_column_name,">',1)-(instr(i_colstring,'<",s_column_name,">',1)+",trim(cnvtstring((size(
          s_column_name,1)+ 2))),
       ')); ")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',sbr_trg_data_rs->qual[i_trg_ndx].
       del_pkw_function,'(")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,'ASIS(",")')
    ENDIF
    IF ((sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
    "VARCHAR2", "ROWID")))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,'char(0)',chr(0),replace(replace(v_dpkw_col",format(cpfo_ndx,"##;P0"),
       ^,'!&lt!','<'),'!&gt!','>'))")^))
    ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].data_type="DATE"))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("to_date(decode(v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_dpkw_col",format(cpfo_ndx,"##;P0"),^),'DD-MON-YYYY HH24:MI:SS') ")^))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_dpkw_col",format(cpfo_ndx,"##;P0"),') ")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(",i_db_link) into v_where from dual; ")')
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(" else raise_application_error(-20205,'Error constructing del pk_where from colstring.'); ")^
    )
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("else ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  if ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].ptam_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   and instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].ptam_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" then ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     CALL stmt_push(io_stmt_cnt,concat('ASIS("    v_ptam_col',format(cpfo_ndx,"##;P0"),':= ")'))
     CALL stmt_push(io_stmt_cnt,concat(^ASIS(" substr(i_colstring,instr(i_colstring,'<^,s_column_name,
       ">',1)+",trim(cnvtstring((size(s_column_name,1)+ 2))),",instr(i_colstring,'</",
       s_column_name,">',1)-(instr(i_colstring,'<",s_column_name,">',1)+",trim(cnvtstring((size(
          s_column_name,1)+ 2))),
       ')); ")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_match_function,'(")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,'ASIS(",")')
    ENDIF
    IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
    "VARCHAR2", "ROWID")))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_ptam_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,'char(0)',chr(0),replace(replace(v_ptam_col",format(cpfo_ndx,"##;P0"),
       ^,'!&lt!','<'),'!&gt!','>'))")^))
    ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type="DATE"))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("to_date(decode(v_ptam_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_ptam_col",format(cpfo_ndx,"##;P0"),^),'DD-MON-YYYY HH24:MI:SS') ")^))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_ptam_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_ptam_col",format(cpfo_ndx,"##;P0"),') ")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(",i_db_link) into v_where from dual; ")')
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(" else raise_application_error(-20205,'Error constructing ptam_match from colstring.'); ")^
    )
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_where);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", s_func_name WITH replace("REQUEST","STMT_BUFFER"), replace(
    "REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_input_parm_ora(i_col_name,i_col_cnt)
   DECLARE s_col_parm = vc
   IF (size(i_col_name,1) < 25)
    SET s_col_parm = concat("i_",i_col_name)
   ELSE
    SET s_col_parm = build("i_",substring(1,25,i_col_name),format(i_col_cnt,"###;P0"))
   ENDIF
   RETURN(s_col_parm)
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
 DECLARE cs93_xlat_backfill(cxb_source_id=f8) = vc
 DECLARE cs93_fix_done2(cfd_source_id=f8,cfd_target_id=f8,cfd_mock_id=f8,cfd_db_link=vc,
  cfd_seqmatch_value=f8) = vc
 DECLARE cs93_create_seqmatch(ccs_rec=vc(ref)) = vc
 SUBROUTINE seqmatch_xlats(i_sequence_name,i_source_env_id,i_table_name)
   SET dm_err->eproc = concat("Start Xlat Backfill",format(cnvtdatetime(curdate,curtime3),cclfmt->
     mediumdatetime))
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE sx_table_suffix = vc
   DECLARE sx_live_table_name = vc
   DECLARE sx_sequence_name = vc
   DECLARE sx_target_id = f8
   DECLARE sx_t_id1 = f8
   DECLARE sx_db_link = vc
   DECLARE sx_seq_match_domain = vc
   DECLARE sx_src_seq_match_domain = vc WITH protect, noconstant("")
   DECLARE sx_seq_match_num = f8
   DECLARE sx_val_loop = i4
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
   DECLARE sx_seq_match_num_src = f8 WITH protect, noconstant(0.0)
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
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_info di
       WHERE di.info_domain="RDDS IGNORE COL LIST:*"
        AND sqlpassthru(" dcd.column_name like di.info_name and dcd.table_name like di.info_char"))))
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
   SET sx_db_link = build("@MERGE",cnvtstring(i_source_env_id,20,0),cnvtstring(sx_t_id1,20,0))
   SET sx_target_id = drmmi_get_mock_id(sx_t_id1)
   IF (sx_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET sx_seq_match_domain = build("MERGE",cnvtstring(i_source_env_id,20,0),cnvtstring(sx_target_id,
     20,0),"SEQMATCH")
   SET sx_src_seq_match_domain = build("MERGE",cnvtstring(sx_target_id,20,0),cnvtstring(
     i_source_env_id,20,0),"SEQMATCH")
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
      IF (sx_sequence_name="REFERENCE_SEQ")
       SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,0.0)
       IF (sx_sec_ret="F")
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
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
     RETURN("S")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",sx_db_link)) di)
    WHERE di.info_domain=concat(sx_src_seq_match_domain,"DONE2")
     AND di.info_name=sx_sequence_name
    DETAIL
     sx_seq_match_num_src = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    IF (sx_sequence_name="REFERENCE_SEQ")
     SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,
      sx_seq_match_num_src)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
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
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di
     WHERE di.info_domain="RDDS IGNORE COL LIST:*"
      AND sqlpassthru(" dcd.column_name like di.info_name and dcd.table_name like di.info_char"))))
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
       cnt = count(*)
       FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
       WHERE parser(concat("t.",sx_tbl_list->qual[sx_val_loop].column_name,
         " between 1 and sx_seq_match_num"))
        AND parser(concat(sx_filter," = 1"))
       DETAIL
        sx_tbl_fltr_cnt = cnt
       WITH nocounter
      ;end select
      IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
        table_name)) != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SELECT INTO "nl:"
       cnt = count(ti.parent_entity_id)
       FROM dm_refchg_invalid_xlat ti
       WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
        AND ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num
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
        cnt = count(*)
        FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
        WHERE parser(concat("t.",sx_tbl_list->qual[sx_val_loop].column_name,
          " between 1 and sx_seq_match_num"))
        DETAIL
         sx_tbl_allrow_cnt = cnt
        WITH nocounter
       ;end select
       IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
         table_name)) != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       SELECT INTO "nl:"
        cnt = count(ti.parent_entity_id)
        FROM dm_refchg_invalid_xlat ti
        WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
         AND ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num
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
            sx_t_col_name," from_value , "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" table_name , ",
            i_source_env_id," env_source_id, ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" env_target_id, ",
            sx_t_col_name," to_value ,3 status_flg,sysdate updt_dt_tm "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("   from ",sx_tbl_list
            ->qual[sx_val_loop].table_name," t "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("    where ",
            sx_t_col_name," between ",sx_range_start," and ",
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
            "   and env_source_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id,20,2)))
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
            "   and env_source_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id,20,2)))
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
            "   and env_source_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id,20,2)))
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
            "   and env_source_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id,20,2)))
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
   IF (sx_sequence_name="REFERENCE_SEQ")
    SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,sx_seq_match_num
     )
    IF (sx_sec_ret="F")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
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
   SET atb_db_link = build("@MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(atb_cur_env_id,20,
     0))
   SET atb_app_task_src = concat("APPLICATION_TASK",atb_db_link)
   SET atb_dmt_src = concat("DM_MERGE_TRANSLATE",atb_db_link)
   SET atb_target_id = drmmi_get_mock_id(atb_cur_env_id)
   IF (atb_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET i_domain = build("MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(atb_target_id,20,0),
    "SEQMATCHDONE2")
   SET atb_src_domain = build("MERGE",cnvtstring(atb_target_id,20,0),cnvtstring(i_atb_source_env_id,
     20,0),"SEQMATCHDONE2")
   SET atb_seqmatch_domain = build("MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(
     atb_target_id,20,0),"SEQMATCH")
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
   SET asd_merge_link = build("@MERGE",cnvtstring(i_src_id,20,0),cnvtstring(i_tgt_id,20,0))
   SET asd_domain = build("MERGE",cnvtstring(i_tgt_mock_id,20,0),cnvtstring(i_src_id,20,0),"SEQMATCH"
    )
   SET asd_src_domain = build("MERGE",cnvtstring(i_src_id,20,0),cnvtstring(i_tgt_mock_id,20,0),
    "SEQMATCH")
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
    WHERE di.info_domain IN (asd_src_domain, concat(asd_src_domain,"DONE2"))
     AND di.info_name=i_sequence
    DETAIL
     IF (di.info_number > asd_targ_nbr)
      asd_targ_nbr = di.info_number
     ENDIF
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
 SUBROUTINE cs93_xlat_backfill(cxb_source_id)
   DECLARE cxb_target_id = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_cur_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_db_link = vc WITH protect, noconstant(" ")
   DECLARE cxb_cv_src = vc WITH protect, noconstant(" ")
   DECLARE cxb_dmt_src = vc WITH protect, noconstant(" ")
   DECLARE cxb_table_name = vc WITH protect, constant("CODE_VALUE")
   DECLARE cxb_domain = vc WITH protect, noconstant(" ")
   DECLARE cxb_info_name = vc WITH protect, constant("CODESET93")
   DECLARE cxb_next_seq = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_sec_ret = vc WITH protect, noconstant("")
   DECLARE cxb_src_domain = vc WITH protect, noconstant("")
   DECLARE cxb_seqmatch_domain = vc WITH protect, noconstant("")
   DECLARE cxb_src_number = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_seqmatch_val = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_done2_src_val = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_row_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_batch = i4 WITH protect, noconstant(0)
   DECLARE cxb_loop = i4 WITH protect, noconstant(0)
   DECLARE cxb_batch_limit = f8 WITH protect, noconstant(0.0)
   FREE RECORD cxb_rs_parser
   RECORD cxb_rs_parser(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD cxb_rs_parser_reply
   RECORD cxb_rs_parser_reply(
     1 row_count = i4
   )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     cxb_cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET cxb_db_link = build("@MERGE",cnvtstring(cxb_source_id,20),cnvtstring(cxb_cur_env_id,20))
   SET cxb_cv_src = concat("CODE_VALUE",cxb_db_link)
   SET cxb_dmt_src = concat("DM_MERGE_TRANSLATE",cxb_db_link)
   SET cxb_target_id = drmmi_get_mock_id(cxb_cur_env_id)
   IF (cxb_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET cxb_domain = build("MERGE",cnvtstring(cxb_source_id),cnvtstring(cxb_target_id),"SEQMATCHDONE2"
    )
   SET cxb_src_domain = build("MERGE",cnvtstring(cxb_target_id),cnvtstring(cxb_source_id),
    "SEQMATCHDONE2")
   SET cxb_seqmatch_domain = build("MERGE",cnvtstring(cxb_source_id),cnvtstring(cxb_target_id),
    "SEQMATCH")
   SELECT INTO "NL:"
    FROM (parser(concat("dm_info",cxb_db_link)) di)
    WHERE di.info_name="REFERENCE_SEQ"
     AND di.info_domain=cxb_src_domain
    DETAIL
     cxb_done2_src_val = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying for remote REFERENCE_SEQ DONE2 row")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     cxb_next_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = cxb_table_name,
     dcla.text = "Backfill translations in CODE_SET 93 for table CODE_VALUE", dcla.updt_applctx =
     cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->updt_task,
     dcla.audit_dt_tm = sysdate
    WHERE dcla.dm_chg_log_audit_id=cxb_next_seq
    WITH nocounter
   ;end update
   IF (check_error("Updating DM_CHG_LOG_AUDIT row for CODE_VALUE") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = cxb_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
      dcla.table_name = cxb_table_name, dcla.text =
      "Backfill translations in CODE_SET 93 for table CODE_VALUE", dcla.updt_applctx = cnvtreal(
       currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
      dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
     WITH nocounter
    ;end insert
    IF (check_error("Inserting DM_CHG_LOG_AUDIT row for CODE_VALUE") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=cxb_domain
     AND di.info_name=cxb_info_name
    WITH nocounter
   ;end select
   IF (check_error("Checking if DONE2 row exists for CODE_SET 93") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ELSEIF (curqual=0)
    SELECT INTO "nl:"
     FROM (parser(concat("dm_info",cxb_db_link)) di)
     WHERE di.info_domain=cxb_src_domain
      AND di.info_name=cxb_info_name
     DETAIL
      cxb_src_number = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for remote CODESET93 DONE2 row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual > 0)
     SET cxb_sec_ret = cs93_fix_done2(cxb_source_id,cxb_cur_env_id,cxb_target_id,cxb_db_link,
      cxb_src_number)
     IF (cxb_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     RETURN("S")
    ENDIF
    SELECT INTO "NL:"
     FROM dm_info di
     WHERE di.info_domain=cxb_seqmatch_domain
      AND di.info_name=cxb_info_name
     DETAIL
      cxb_seqmatch_val = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for local CODESET93 SEQMATCH") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (cxb_done2_src_val > cxb_seqmatch_val)
     SET cxb_seqmatch_val = cxb_done2_src_val
     UPDATE  FROM dm_info d
      SET info_number = cxb_seqmatch_val
      WHERE info_domain=cxb_seqmatch_domain
       AND info_name=cxb_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating local CODESET93 SEQMATCH to be correct") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     cnt = count(*)
     FROM code_value c
     WHERE c.code_set=93
      AND c.code_value <= cxb_seqmatch_val
     DETAIL
      cxb_row_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error("Gathering count of CODESET93 to use for NTILE")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     cnt = count(*)
     FROM dm_refchg_invalid_xlat t1
     WHERE t1.parent_entity_name="CODE_VALUE"
      AND t1.parent_entity_id <= cxb_seqmatch_val
     DETAIL
      cxb_row_cnt = (cxb_row_cnt+ cnt)
     WITH nocounter
    ;end select
    IF (check_error("Gathering count of CODESET93 to use for NTILE")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="RXLAT_BELOW_SEQ_FILL"
     DETAIL
      cxb_batch_limit = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for backfill batch size") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET cxb_batch_limit = 50000.0
    ENDIF
    SET cxb_batch = ceil((cxb_row_cnt/ cxb_batch_limit))
    SET cxb_row_cnt = 1.0
    IF (cxb_batch > 1)
     DELETE  FROM dm_info d
      WHERE info_domain="CODESET93"
       AND info_name=patstring("CODESET93*")
      WITH nocounter
     ;end delete
     IF (check_error("Removing CODSET93 Ntile rows from DM_INFO")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     CALL parser("rdb asis(^ insert into dm_info (info_domain, info_name, info_number) ^)",0)
     CALL parser("asis(^(select 'CODSET93','CODESET93'||to_char(bin,'FM00000'), max(code_value)^)",0)
     CALL parser(concat("asis(^ from (select code_value, ntile(",trim(cnvtstring(cxb_batch)),
       ") over (order by code_value) bin ^)"),0)
     CALL parser(concat(
       "asis(^ from (select code_value from code_value where code_set = 93 and code_value < ",trim(
        cnvtstring(cxb_seqmatch_val,20,1)),"^)"),0)
     CALL parser(
      "asis(^ union select t1.parent_entity_id code_value from dm_refchg_invalid_xlat t1 ^)",0)
     CALL parser(concat(
       "asis(^ where t1.parent_entity_name = 'CODE_VALUE' and t1.parent_entity_id < ",trim(cnvtstring
        (cxb_seqmatch_val,20,1)),"^)"),0)
     CALL parser("asis (^ order by code_value) group by bin) ^) go",1)
     IF (check_error("Performing NTILE statement for CODESET93")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET cxb_batch = 0
     SELECT INTO "NL:"
      FROM dm_info d
      WHERE d.info_domain="CODESET93"
       AND info_name=patstring("CODESET93*")
      ORDER BY d.info_number
      DETAIL
       cxb_batch = (cxb_batch+ 1), stat = alterlist(dm_batch_list_rep->list,cxb_batch),
       dm_batch_list_rep->list[cxb_batch].batch_num = cxb_batch,
       dm_batch_list_rep->list[cxb_batch].max_value = cnvtstring(d.info_number,20,1)
      WITH nocounter
     ;end select
     IF (check_error("Querying CODESET93 NTILE data in DM_INFO")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSE
     SET cxb_batch = 1
     SET stat = alterlist(dm_batch_list_rep->list,1)
     SET dm_batch_list_rep->list[1].batch_num = 1
     SET dm_batch_list_rep->list[1].max_value = cnvtstring(cxb_seqmatch_val,20,1)
    ENDIF
    SET stat = alterlist(cxb_rs_parser->stmt,40)
    FOR (cxb_loop = 1 TO cxb_batch)
      SET cxb_rs_parser->stmt[1].str = " rdb insert into dm_merge_translate dmt"
      SET cxb_rs_parser->stmt[2].str =
      " (dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, "
      SET cxb_rs_parser->stmt[3].str = "  dmt.status_flg, dmt.updt_dt_tm) "
      SET cxb_rs_parser->stmt[4].str = build(' (select cv.code_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[5].str = build(cxb_target_id,", cv.code_value, 3, sysdate")
      SET cxb_rs_parser->stmt[6].str = concat("from code_value cv")
      SET cxb_rs_parser->stmt[7].str = concat("where cv.code_set = 93 and cv.code_value between ",
       trim(cnvtstring(cxb_row_cnt,20,2))," and ",dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[8].str =
      " union select ti.parent_entity_id from_value, ti.parent_entity_name table_name, "
      SET cxb_rs_parser->stmt[9].str = concat(trim(cnvtstring(cxb_source_id,20,2))," env_source_id, ",
       trim(cnvtstring(cxb_target_id,20,2))," env_target_id, ")
      SET cxb_rs_parser->stmt[10].str =
      "ti.parent_entity_id to_value, 3 status_flg, sysdate updt_dt_tm "
      SET cxb_rs_parser->stmt[11].str = concat(
       'from dm_refchg_invalid_xlat ti where ti.parent_entity_name = "',cxb_table_name,
       '" and ti.parent_entity_id between ',trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[16].str = "  minus "
      SET cxb_rs_parser->stmt[17].str = build('  select from_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[18].str = build("    ",cxb_target_id,", from_value, 3, sysdate")
      SET cxb_rs_parser->stmt[19].str = concat('from dm_merge_translate where table_name = "',
       cxb_table_name,'"')
      SET cxb_rs_parser->stmt[20].str = build(" and env_source_id = ",cxb_source_id)
      SET cxb_rs_parser->stmt[21].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_target_id,
         20,2))," and from_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[22].str = "  minus "
      SET cxb_rs_parser->stmt[23].str = build('  select to_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[24].str = build("    ",cxb_target_id,", to_value, 3, sysdate")
      SET cxb_rs_parser->stmt[25].str = concat('from dm_merge_translate where table_name = "',
       cxb_table_name,'"')
      SET cxb_rs_parser->stmt[26].str = build(" and env_source_id = ",cxb_source_id)
      SET cxb_rs_parser->stmt[27].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_target_id,
         20,2))," and to_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[28].str = "  minus "
      SET cxb_rs_parser->stmt[29].str = build('  select from_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[30].str = build("    ",cxb_target_id,", from_value, 3, sysdate")
      SET cxb_rs_parser->stmt[31].str = build("from dm_merge_translate",cxb_db_link,
       ' where table_name = "',cxb_table_name,'"')
      SET cxb_rs_parser->stmt[32].str = build(" and env_source_id = ",cxb_target_id)
      SET cxb_rs_parser->stmt[33].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_source_id,
         20,2))," and from_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[34].str = "  minus "
      SET cxb_rs_parser->stmt[35].str = build('  select to_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[36].str = build("    ",cxb_target_id,", to_value, 3, sysdate")
      SET cxb_rs_parser->stmt[37].str = concat("from dm_merge_translate",cxb_db_link,
       ' where table_name = "',cxb_table_name,'"')
      SET cxb_rs_parser->stmt[38].str = build(" and env_source_id = ",cxb_target_id)
      SET cxb_rs_parser->stmt[39].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_source_id,
         20,2))," and to_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[40].str = ") go"
      EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","CXB_RS_PARSER"), replace("REPLY",
       "CXB_RS_PARSER_REPLY")
      IF (check_error("Error during CODESET 93 translation backfill") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET cxb_row_cnt = cnvtreal(dm_batch_list_rep->list[cxb_loop].max_value)
    ENDFOR
    SET cxb_sec_ret = cs93_fix_done2(cxb_source_id,cxb_cur_env_id,cxb_target_id,cxb_db_link,
     cxb_seqmatch_val)
    IF (cxb_sec_ret="F")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    COMMIT
    RETURN("S")
   ELSEIF (curqual > 0)
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE cs93_fix_done2(cfd_source_id,cfd_target_id,cfd_mock_id,cfd_db_link,cfd_seqmatch_value)
   DECLARE cfd_target_seqmatch = vc WITH protect, noconstant("")
   DECLARE cfd_target_done2 = vc WITH protect, noconstant("")
   DECLARE cfd_source_seqmatch = vc WITH protect, noconstant("")
   DECLARE cfd_source_done2 = vc WITH protect, noconstant("")
   DECLARE cfd_info_name = vc WITH protect, constant("CODESET93")
   DECLARE cfd_value = f8 WITH protect, noconstant(0.0)
   SET cfd_target_seqmatch = concat("MERGE",trim(cnvtstring(cfd_source_id,20)),trim(cnvtstring(
      cfd_mock_id,20)),"SEQMATCH")
   SET cfd_target_done2 = concat(cfd_target_seqmatch,"DONE2")
   SET cfd_source_seqmatch = concat("MERGE",trim(cnvtstring(cfd_mock_id,20)),trim(cnvtstring(
      cfd_source_id,20)),"SEQMATCH")
   SET cfd_source_done2 = concat(cfd_source_seqmatch,"DONE2")
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain=cfd_target_seqmatch
     AND di.info_name=cfd_info_name
    DETAIL
     cfd_value = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying sequence row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = cfd_target_seqmatch, di.info_name = cfd_info_name, di.info_number = 0.0,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("Inserting sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSEIF (cfd_value > 0.0)
    UPDATE  FROM dm_info di
     SET info_number = 0.0, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=cfd_target_seqmatch
      AND di.info_name=cfd_info_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SET cfd_value = 0.0
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain=cfd_target_done2
     AND di.info_name=cfd_info_name
    DETAIL
     cfd_value = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying DONE2 row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = cfd_target_done2, di.info_name = cfd_info_name, di.info_number =
      cfd_seqmatch_value,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("Inserting done2 row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSEIF (cfd_value != cfd_seqmatch_value)
    UPDATE  FROM dm_info di
     SET info_number = cfd_seqmatch_value, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=cfd_target_done2
      AND di.info_name=cfd_info_name
     WITH nocounter
    ;end update
    IF (check_error("Updating done2 row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   IF (cfd_target_id=cfd_mock_id)
    SET cfd_value = 0.0
    SELECT INTO "NL:"
     FROM (parser(concat("dm_Info",cfd_db_link)) di)
     WHERE di.info_domain=cfd_source_seqmatch
      AND di.info_name=cfd_info_name
     DETAIL
      cfd_value = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying sequence row in remote dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET di.info_domain = cfd_source_seqmatch, di.info_name = cfd_info_name, di.info_number = 0.0,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting sequence row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSEIF (cfd_value > 0.0)
     UPDATE  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET info_number = 0.0, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
       updt_applctx
      WHERE di.info_domain=cfd_source_seqmatch
       AND di.info_name=cfd_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SET cfd_value = 0.0
    SELECT INTO "NL:"
     FROM (parser(concat("dm_Info",cfd_db_link)) di)
     WHERE di.info_domain=cfd_source_done2
      AND di.info_name=cfd_info_name
     DETAIL
      cfd_value = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying done2 row in remote dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET di.info_domain = cfd_source_done2, di.info_name = cfd_info_name, di.info_number =
       cfd_seqmatch_value,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting done2 row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSEIF (cfd_value != cfd_seqmatch_value)
     UPDATE  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET info_number = cfd_seqmatch_value, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
       updt_applctx
      WHERE di.info_domain=cfd_source_done2
       AND di.info_name=cfd_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating done2 row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE cs93_create_seqmatch(ccs_rec)
   DECLARE ccs_loop = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_ENV_ID"
    DETAIL
     ccs_rec->env_id = d.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying for local environment id")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET ccs_rec->mock_id = drmmi_get_mock_id(ccs_rec->env_id)
   IF (check_error("Obtaining MOCK_ID")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    FROM dm_env_reltn d
    WHERE (d.child_env_id=ccs_rec->env_id)
     AND d.relationship_type="REFERENCE MERGE"
     AND d.post_link_name > " "
    DETAIL
     ccs_rec->env_cnt = (ccs_rec->env_cnt+ 1), stat = alterlist(ccs_rec->env_qual,ccs_rec->env_cnt),
     ccs_rec->env_qual[ccs_rec->env_cnt].parent_env_id = d.parent_env_id,
     ccs_rec->env_qual[ccs_rec->env_cnt].db_link = d.post_link_name, ccs_rec->env_qual[ccs_rec->
     env_cnt].done2_name = concat("MERGE",trim(cnvtstring(d.parent_env_id,20)),trim(cnvtstring(
        ccs_rec->mock_id,20)),"SEQMATCHDONE2")
    WITH nocounter
   ;end select
   IF (check_error("Looking for all parent relationships")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF ((ccs_rec->env_cnt > 0))
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = ccs_rec->env_cnt),
      dm_info di
     PLAN (d)
      JOIN (di
      WHERE di.info_name="REFERENCE_SEQ"
       AND (di.info_domain=ccs_rec->env_qual[d.seq].done2_name))
     DETAIL
      ccs_rec->env_qual[d.seq].done2_value = di.info_number, ccs_rec->env_qual[d.seq].done2_exist_ind
       = 1, ccs_rec->ref_seq_cnt = (ccs_rec->ref_seq_cnt+ 1)
     WITH nocounter
    ;end select
    IF (check_error("Looking for REFERENCE_SEQ DONE2 rows")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   FOR (ccs_loop = 1 TO ccs_rec->env_cnt)
     IF ((ccs_rec->env_qual[ccs_loop].done2_exist_ind=1))
      SELECT INTO "NL:"
       FROM dm_info di
       WHERE di.info_domain=concat("MERGE",trim(cnvtstring(ccs_rec->env_qual[ccs_loop].parent_env_id,
          20)),trim(cnvtstring(ccs_rec->mock_id,20)),"SEQMATCH")
        AND di.info_name="CODESET93"
       WITH nocounter
      ;end select
      IF (check_error("Querying for CODESET93 SEQMATCH row")=1)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_info di
        SET di.info_domain = concat("MERGE",trim(cnvtstring(ccs_rec->env_qual[ccs_loop].parent_env_id,
            20)),trim(cnvtstring(ccs_rec->mock_id,20)),"SEQMATCH"), di.info_name = "CODESET93", di
         .info_number = ccs_rec->env_qual[ccs_loop].done2_value,
         di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
         di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (check_error("Inserting CODESET93 SEQMATCH row")=1)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   COMMIT
   RETURN("S")
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
 DECLARE drmm_get_col_string(sbr_pk_where=vc,sbr_log_id=f8,sbr_tbl_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 DECLARE drmm_get_ptam_match_query(sbr_log_id=f8,sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) =
 null
 DECLARE drmm_get_ptam_match_result(sbr_log_id=f8,sbr_src_env_id=f8,sbr_tgt_env_id=f8,sbr_db_link=vc,
  sbr_local_ind=i2,
  sbr_trans_type=vc) = f8
 DECLARE drmm_get_pk_where(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_delete_ind=i2,sbr_db_link=vc) = vc
 DECLARE drmm_get_exploded_pkw(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_func_name(sbr_prefix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_cust_col_string(sbr_pk_where=vc,sbr_tbl_name=vc,sbr_col_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 IF ( NOT (validate(col_string_parm,0)))
  FREE RECORD col_string_parm
  RECORD col_string_parm(
    1 total = i4
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 column_name = vc
        3 in_src_ind = i2
  ) WITH protect
 ENDIF
 SUBROUTINE drmm_get_col_string(sbr_pk_where,sbr_log_id,sbr_tbl_name,sbr_tbl_suffix,sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgcs_dcl_tab_name = concat("DM_CHG_LOG",dgcs_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_COL_STRING",d.col_string)
     FROM (parser(dgcs_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ELSE
    SET dgcs_tab_name = sbr_tbl_name
    SET dgcs_tab_suffix = sbr_tbl_suffix
    SET dgcs_col_pos = locateval(dgcs_num,1,col_string_parm->total,dgcs_tab_name,col_string_parm->
     qual[dgcs_num].table_name)
    IF (dgcs_col_pos=0)
     SET dgcs_col_pos = (col_string_parm->total+ 1)
     SET stat = alterlist(col_string_parm->qual,dgcs_col_pos)
     SET col_string_parm->total = dgcs_col_pos
     SET col_string_parm->qual[dgcs_col_pos].table_name = dgcs_tab_name
     SELECT INTO "nl:"
      FROM dm_colstring_parm d
      WHERE d.table_name=dgcs_tab_name
      ORDER BY d.parm_nbr
      HEAD REPORT
       parm_cnt = 0
      DETAIL
       parm_cnt = (parm_cnt+ 1), stat = alterlist(col_string_parm->qual[dgcs_col_pos].col_qual,
        parm_cnt), col_string_parm->qual[dgcs_col_pos].col_qual[parm_cnt].column_name = d.column_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (dgcs_db_link > "")
     FOR (dgcs_col_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
       SET col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_col_loop].in_src_ind = 0
     ENDFOR
     SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
     SELECT INTO "nl:"
      FROM (parser(dgcs_utc_name) utc)
      WHERE (utc.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
       AND expand(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].col_qual,5),utc.column_name,
       col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].column_name)
       AND  NOT (column_name IN ("KEY1", "KEY2", "KEY3"))
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),utc.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF (dgcs_pos > 0)
        col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     SELECT DISTINCT INTO "nl:"
      dpwp.column_name
      FROM dm_pk_where_parm dpwp
      WHERE (dpwp.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),dpwp.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind=0))
        dgcs_miss_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     IF (dgcs_miss_ind=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(
       "PK_WHERE or PTAM_MATCH_QUERY is going to use a column that does not exist in source.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (2))
     ENDIF
    ENDIF
    SET dgcs_func_prefix = concat("REFCHG_COLSTRING_",dgcs_tab_suffix)
    SET dgcs_func_name = drmm_get_func_name(dgcs_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN(- (1))
    ENDIF
    IF (dgcs_func_name="")
     SET dm_err->emsg = concat("A col_string function is not built: ",dgcs_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(- (1))
    ENDIF
    CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
    SET dgcs_stmt_cnt = (size(col_string_parm->qual[dgcs_col_pos].col_qual,5)+ 4)
    SET stat = alterlist(parse_rs->stmt,dgcs_stmt_cnt)
    SET dgcs_qual_cnt = 0
    SET dgcs_stmt_idx = 1
    SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
    SET parse_rs->stmt[dgcs_stmt_idx].str =
    "select into 'nl:' dm2_context_control_wrapper('RDDS_COL_STRING',"
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
    FOR (dgcs_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
      SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
      IF (dgcs_loop != 1)
       SET parse_rs->stmt[dgcs_stmt_idx].str = ","
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = " "
      ENDIF
      IF (dgcs_db_link > "")
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].in_src_ind=0))
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"NULL")
       ELSE
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
         dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
       ENDIF
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
        dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
      ENDIF
    ENDFOR
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
     " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
     ",1) go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
    IF (dgcs_qual_cnt=0)
     CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_query(sbr_log_id,sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgpq_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpq_func_name = vc WITH protect, noconstant("")
   DECLARE dgpq_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpq_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpq_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpq_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_PTAM_MATCH_QUERY",d.ptam_match_query)
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ELSE
    SET dgpq_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
    SET dgpq_func_name = drmm_get_func_name(dgpq_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN
    ENDIF
    IF (dgpq_func_name="")
     SET dm_err->emsg = concat("A function is not built: ",dgpq_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN
    ENDIF
    CALL parser(concat("declare ",dgpq_func_name,"() = c2000 go"),1)
    SET stat = alterlist(parse_rs->stmt,3)
    SET parse_rs->stmt[1].str =
    "SELECT into 'nl:' sbr_ind = dm2_context_control_wrapper('RDDS_PTAM_MATCH_QUERY',"
    SET parse_rs->stmt[2].str = concat(dgpq_func_name,
     "(0,1,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpq_db_link,"')) from dual")
    SET parse_rs->stmt[3].str = " with nocounter go"
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_result(sbr_log_id,sbr_src_env_id,sbr_tgt_env_id,sbr_db_link,
  sbr_local_ind,sbr_xlat_type)
   DECLARE dgpr_ptam_result = f8 WITH protect, noconstant(0.0)
   DECLARE dgpr_src_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_tgt_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgpr_xlat_type = vc WITH protect, noconstant(" ")
   DECLARE refchg_run_ptam() = f8
   DECLARE sys_context() = c2000
   IF (sbr_db_link > " ")
    SET dgpr_db_link = sbr_db_link
   ENDIF
   IF (sbr_xlat_type > " ")
    SET dgpr_xlat_type = sbr_xlat_type
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpr_db_link)
    SELECT INTO "nl:"
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     DETAIL
      dgpr_ptam_result = d.ptam_match_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSE
    SET dgpr_src_str = concat(trim(cnvtstring(sbr_src_env_id)),".0")
    SET dgpr_tgt_str = concat(trim(cnvtstring(sbr_tgt_env_id)),".0")
    SELECT INTO "nl:"
     ptam_result = refchg_run_ptam(replace(replace(replace(replace(replace(sys_context("CERNER",
            "RDDS_PTAM_MATCH_QUERY",2000),"<SOURCE_ID>",dgpr_src_str),"<TARGET_ID>",dgpr_tgt_str),
         "<DB_LINK>",concat("'",dgpr_db_link,"'")),"<LOCAL_IND>",trim(cnvtstring(sbr_local_ind))),
       "<XLAT_TYPE>",concat("'",dgpr_xlat_type,"'")))
     FROM dual
     DETAIL
      dgpr_ptam_result = ptam_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(dgpr_ptam_result)
 END ;Subroutine
 SUBROUTINE drmm_get_pk_where(sbr_tab_name,sbr_tab_suffix,sbr_delete_ind,sbr_db_link)
   DECLARE dgpw_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpw_func_name = vc WITH protect, noconstant("")
   DECLARE dgpw_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpw_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgpw_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpw_db_link = sbr_db_link
   ENDIF
   SET dgpw_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgpw_func_name = drmm_get_func_name(dgpw_func_prefix," ")
   IF (dgpw_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgpw_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgpw_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgpw_pkw = "
   SET parse_rs->stmt[2].str = concat(dgpw_func_name,"(1,",trim(cnvtstring(sbr_delete_ind)),
    ",SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpw_db_link,
    "') from dual")
   SET parse_rs->stmt[3].str = "detail dgpw_pk_where = dgpw_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgpw_pk_where)
 END ;Subroutine
 SUBROUTINE drmm_get_func_name(sbr_prefix,sbr_db_link)
   DECLARE dgfn_func_name = vc WITH protect, noconstant("")
   DECLARE dgfn_uo_tab = vc WITH protect, noconstant("")
   DECLARE dgfn_prefix = vc WITH protect, noconstant("")
   SET dgfn_uo_tab = concat("USER_OBJECTS",sbr_db_link)
   SET dgfn_prefix = concat(sbr_prefix,"*")
   SELECT INTO "nl:"
    FROM (parser(dgfn_uo_tab) uo)
    WHERE uo.object_name=patstring(dgfn_prefix)
    DETAIL
     dgfn_func_name = uo.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgfn_func_name)
 END ;Subroutine
 SUBROUTINE drmm_get_cust_col_string(sbr_pk_where,sbr_tbl_name,sbr_col_name,sbr_tbl_suffix,
  sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   DECLARE dgcs_col_name = vc WITH protect, noconstant("")
   DECLARE dgcs_type = vc WITH protect, noconstant("")
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   SET dgcs_tab_name = sbr_tbl_name
   SET dgcs_tab_suffix = sbr_tbl_suffix
   SET dgcs_col_name = sbr_col_name
   IF (dgcs_db_link > "")
    SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
   ELSE
    SET dgcs_utc_name = "USER_TAB_COLUMNS"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dgcs_utc_name) utc)
    WHERE utc.table_name=dgcs_tab_name
     AND utc.column_name=dgcs_col_name
    DETAIL
     dgcs_type = utc.data_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (curqual=0)
    CALL disp_msg("The column being asked for does not exist in source.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ( NOT (dgcs_type IN ("DATE", "FLOAT", "NUMBER", "CHAR", "VARCHAR2")))
    CALL disp_msg("The column being asked has an incompatible data_type.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET dgcs_func_name = "REFCHG_CUST_COLSTRING"
   CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
   SET stat = alterlist(parse_rs->stmt,5)
   SET dgcs_qual_cnt = 0
   SET dgcs_stmt_idx = 1
   SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
   SET parse_rs->stmt[dgcs_stmt_idx].str =
   "select into 'nl:' dm2_context_control_wrapper('RDDS_CUST_COL_STRING',"
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat("'",dgcs_col_name,"','",dgcs_type,"',")
   IF (dgcs_type IN ("VARCHAR2", "CHAR"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,
     "0.0,cnvtdatetime(curdate,curtime3),","t",dgcs_tab_suffix,".",
     dgcs_col_name)
   ELSEIF (dgcs_type IN ("FLOAT", "NUMBER"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",cnvtdatetime(curdate,curtime3),'ABC'")
   ELSE
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"0.0,t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",'ABC'")
   ENDIF
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
    " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
    ",1) go")
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgcs_qual_cnt=0)
    CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_exploded_pkw(sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgep_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgep_func_name = vc WITH protect, noconstant("")
   DECLARE dgep_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgep_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgep_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgep_db_link = sbr_db_link
   ENDIF
   SET dgep_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgep_func_name = drmm_get_func_name(dgep_func_prefix," ")
   IF (dgep_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgep_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgep_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgep_pkw = "
   SET parse_rs->stmt[2].str = concat(dgep_func_name,
    "(1,0,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgep_db_link,"',0) from dual")
   SET parse_rs->stmt[3].str = "detail dgep_pk_where = dgep_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgep_pk_where)
 END ;Subroutine
 DECLARE pk_where_info(i_table_name=vc,i_table_suffix=vc,i_alias=vc,i_dblink=vc,i_rs_data=vc(ref)) =
 vc
 DECLARE filter_info(i_table_name=vc,i_table_suffix=vc,i_alias=vc,i_dblink=vc,i_rs_data=vc(ref)) = vc
 DECLARE call_ins_log(i_table_name=vc,i_pk_where=vc,i_log_type=vc,i_delete_ind=i2,i_updt_id=f8,
  i_updt_task=i4,i_updt_applctx=i4,i_ctx_str=vc,i_envid=f8,i_pkw_vers_id=f8,
  i_dblink=vc) = vc
 DECLARE call_ins_dcl(i_table_name=vc,i_pk_where=vc,i_log_type=vc,i_delete_ind=i2,i_updt_id=f8,
  i_updt_task=i4,i_updt_applctx=i4,i_ctx_str=vc,i_envid=f8,i_spass_log_id=f8,
  i_dblink=vc,i_pk_hash=f8,i_ptam_hash=f8) = vc
 IF ((validate(proc_refchg_ins_log_args->has_vers_id,- (99))=- (99))
  AND (validate(proc_refchg_ins_log_args->has_vers_id,- (100))=- (100)))
  FREE RECORD proc_refchg_ins_log_args
  RECORD proc_refchg_ins_log_args(
    1 has_vers_id = i2
  )
  SET proc_refchg_ins_log_args->has_vers_id = - (1)
 ENDIF
 SUBROUTINE pk_where_info(i_table_name,i_table_suffix,i_alias,i_dblink,i_rs_data)
   DECLARE pwi_qual = i4 WITH protect, noconstant(0)
   DECLARE pwi_idx1 = i4 WITH protect, noconstant(0)
   DECLARE pwi_idx2 = i4 WITH protect, noconstant(0)
   DECLARE pwi_size = i4 WITH protect, noconstant(0)
   DECLARE pwi_temp = vc
   SET pwi_size = size(i_rs_data->data,5)
   SET pwi_idx1 = locateval(pwi_idx2,1,pwi_size,trim(i_table_name),i_rs_data->data[pwi_idx2].
    table_name)
   IF (pwi_idx1=0)
    SET pwi_idx1 = (pwi_size+ 1)
    SET stat = alterlist(i_rs_data->data,pwi_idx1)
    SET i_rs_data->data[pwi_idx1].table_name = trim(i_table_name)
   ENDIF
   SET pwi_temp = build("REFCHG_PK_WHERE_",i_table_suffix,"*")
   SET dm_err->eproc = concat("Verify that ",trim(pwi_temp)," function for ",trim(i_table_name),
    " exists in the domain")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("user_objects",trim(i_dblink))) uo)
    WHERE uo.object_name=patstring(pwi_temp)
     AND (uo.last_ddl_time=
    (SELECT
     max(o.last_ddl_time)
     FROM (parser(concat("user_objects",trim(i_dblink))) o)
     WHERE o.object_name=patstring(pwi_temp)))
    DETAIL
     i_rs_data->data[pwi_idx1].pkw_function = uo.object_name, i_rs_data->data[pwi_idx1].pkw_declare
      = concat("declare ",trim(uo.object_name),trim(i_dblink),"() = c2000 go")
    WITH nocounter
   ;end select
   SET pwi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (pwi_qual=0)
    SET dm_err->emsg = concat(trim(pwi_temp)," does not exist in current domain")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET i_rs_data->data[pwi_idx1].pkw_check_ind = 1
    RETURN("E")
   ENDIF
   SET dm_err->eproc = concat("Obtaining parameters for ",trim(pwi_temp))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("dm_refchg_pkw_parm",trim(i_dblink))) drp)
    WHERE drp.table_name=trim(i_table_name)
    ORDER BY drp.parm_nbr
    HEAD REPORT
     count = 0, i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_function,
      trim(i_dblink),"('INS/UPD'"), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[
      pwi_idx1].pkw_function,trim(i_dblink),"('DELETE'")
    DETAIL
     count = (count+ 1), stat = alterlist(i_rs_data->data[pwi_idx1].pkw,count), i_rs_data->data[
     pwi_idx1].pkw[count].parm_name = trim(drp.column_name)
     IF (trim(i_alias) > "")
      i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,",",trim(
        i_alias),".",trim(drp.column_name)), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data
       ->data[pwi_idx1].pkw_del_str,",",trim(i_alias),".",trim(drp.column_name))
     ELSE
      i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,",",trim(drp
        .column_name)), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[pwi_idx1].
       pkw_del_str,",",trim(drp.column_name))
     ENDIF
    FOOT REPORT
     i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,")"),
     i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[pwi_idx1].pkw_del_str,")")
    WITH nocounter
   ;end select
   SET pwi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (pwi_qual=0)
    SET dm_err->emsg = "Could not obtain parameters for pk_where function"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("P")
   ENDIF
   SET i_rs_data->data[pwi_idx1].pkw_check_ind = 1
   RETURN("S")
 END ;Subroutine
 SUBROUTINE filter_info(i_table_name,i_table_suffix,i_alias,i_dblink,i_rs_data)
   DECLARE fi_qual = i4 WITH protect, noconstant(0)
   DECLARE fi_idx1 = i4 WITH protect, noconstant(0)
   DECLARE fi_idx2 = i4 WITH protect, noconstant(0)
   DECLARE fi_size = i4 WITH protect, noconstant(0)
   DECLARE fi_temp = vc
   SET fi_size = size(i_rs_data->data,5)
   SET fi_idx1 = locateval(fi_idx2,1,fi_size,trim(i_table_name),i_rs_data->data[fi_idx2].table_name)
   IF (fi_idx1=0)
    SET fi_idx1 = (fi_size+ 1)
    SET stat = alterlist(i_rs_data->data,fi_idx1)
    SET i_rs_data->data[fi_idx1].table_name = trim(i_table_name)
   ENDIF
   SET fi_temp = build("REFCHG_FILTER_",i_table_suffix,"*")
   SET dm_err->eproc = concat("Verify that ",trim(fi_temp)," function for ",trim(i_table_name),
    " exists in the domain")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("user_objects",trim(i_dblink))) uo)
    WHERE uo.object_name=patstring(fi_temp)
     AND (uo.last_ddl_time=
    (SELECT
     max(o.last_ddl_time)
     FROM (parser(concat("user_objects",trim(i_dblink))) o)
     WHERE o.object_name=patstring(fi_temp)))
    DETAIL
     i_rs_data->data[fi_idx1].filter_function = uo.object_name, i_rs_data->data[fi_idx1].
     filter_declare = concat("declare ",trim(uo.object_name),trim(i_dblink),"() = i2 go")
    WITH nocounter
   ;end select
   SET fi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (fi_qual=0)
    SET dm_err->eproc = concat(trim(fi_temp)," function for ",trim(i_table_name),
     " does not exists in the domain")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET i_rs_data->data[fi_idx1].filter_check_ind = 1
    RETURN("E")
   ENDIF
   SET dm_err->eproc = concat("Obtaining parameters for ",trim(fi_temp))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("dm_refchg_filter_parm",trim(i_dblink))) drp)
    WHERE drp.table_name=trim(i_table_name)
     AND drp.active_ind=1
    ORDER BY drp.parm_nbr
    HEAD REPORT
     count = 0, i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].
      filter_function,trim(i_dblink),"('ADD'"), i_rs_data->data[fi_idx1].filter_upd_str = concat(
      i_rs_data->data[fi_idx1].filter_function,trim(i_dblink),"('UPD'"),
     i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].filter_function,trim(
       i_dblink),"('DEL'")
    DETAIL
     count = (count+ 1), stat = alterlist(i_rs_data->data[fi_idx1].filter,count), i_rs_data->data[
     fi_idx1].filter[count].parm_name = trim(drp.column_name)
     IF (trim(i_alias) > "")
      i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,",",
       trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_upd_str = concat
      (i_rs_data->data[fi_idx1].filter_upd_str,",",trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_del_str = concat
      (i_rs_data->data[fi_idx1].filter_del_str,",",trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name))
     ELSE
      i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,",",
       trim(drp.column_name),",",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_upd_str =
      concat(i_rs_data->data[fi_idx1].filter_upd_str,",",trim(drp.column_name),",",trim(drp
        .column_name)), i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].
       filter_del_str,",",trim(drp.column_name),",",trim(drp.column_name))
     ENDIF
    FOOT REPORT
     i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,")"),
     i_rs_data->data[fi_idx1].filter_upd_str = concat(i_rs_data->data[fi_idx1].filter_upd_str,")"),
     i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].filter_del_str,")")
    WITH nocounter
   ;end select
   SET fi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (fi_qual=0)
    SET dm_err->emsg = "Could not obtain parameters for filter function"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("P")
   ENDIF
   SET i_rs_data->data[fi_idx1].filter_check_ind = 1
   RETURN("S")
 END ;Subroutine
 SUBROUTINE call_ins_log(i_table_name,i_pk_where,i_log_type,i_delete_ind,i_updt_id,i_updt_task,
  i_updt_applctx,i_ctx_str,i_envid,i_pkw_vers_id,i_dblink)
   DECLARE cil_delete_ind_str = vc
   DECLARE cil_updt_id_str = vc
   DECLARE cil_updt_task_str = vc
   DECLARE cil_updt_applctx_str = vc
   DECLARE cil_ctx_str = vc
   DECLARE cil_envid_str = vc
   DECLARE cil_pkw_vers_id_str = vc
   DECLARE cil_pkw = vc
   SET cil_pk = replace_carrot_symbol(i_pk_where)
   FREE RECORD dat_stmt
   RECORD dat_stmt(
     1 stmt[5]
       2 str = vc
   )
   IF (trim(i_ctx_str) > "")
    SET cil_ctx_str = trim(i_ctx_str)
   ELSE
    SET cil_ctx_str = "NULL"
   ENDIF
   IF (i_envid=0)
    SET cil_envid_str = "NULL"
   ELSE
    SET cil_envid_str = trim(cnvtstring(i_envid))
   ENDIF
   SET cil_delete_ind_str = trim(cnvtstring(i_delete_ind))
   SET cil_updt_id_str = trim(cnvtstring(i_updt_id))
   SET cil_updt_task_str = trim(cnvtstring(i_updt_task))
   SET cil_updt_applctx_str = trim(cnvtstring(i_updt_applctx))
   SET cil_pkw_vers_id_str = trim(cnvtstring(i_pkw_vers_id))
   SET dat_stmt->stmt[1].str = concat("RDB ASIS(^ BEGIN proc_refchg_ins_log",trim(i_dblink),"('",
    i_table_name,"',^)")
   SET dat_stmt->stmt[2].str = concat("ASIS(^ ",cil_pk,",^)")
   SET dat_stmt->stmt[3].str = concat("ASIS(^ dbms_utility.get_hash_value(",cil_pk,",0,1073741824.0)",
    ",'",i_log_type,
    "',",cil_delete_ind_str,",",cil_updt_id_str,",",
    cil_updt_task_str,",",cil_updt_applctx_str,"^)")
   SET dat_stmt->stmt[4].str = concat("ASIS(^,'",cil_ctx_str,"',",cil_envid_str,"^)")
   SET dm_err->eproc = "Checking to see if we should use i_pkw_vers_id"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((proc_refchg_ins_log_args->has_vers_id=- (1)))
    SELECT INTO "nl:"
     FROM (parser(concat("user_arguments",trim(i_dblink))) ua)
     WHERE ua.object_name="PROC_REFCHG_INS_LOG"
      AND ua.argument_name="I_DM_REFCHG_PKW_VERS_ID"
     DETAIL
      proc_refchg_ins_log_args->has_vers_id = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET proc_refchg_ins_log_args->has_vers_id = 0
    ENDIF
   ENDIF
   IF ((proc_refchg_ins_log_args->has_vers_id=1))
    SET dat_stmt->stmt[5].str = concat("ASIS(^,",cil_pkw_vers_id_str,"); END; ^) go")
   ELSE
    SET dat_stmt->stmt[5].str = concat("ASIS(^","); END; ^) go")
   ENDIF
   CALL echo(dat_stmt->stmt[1].str)
   CALL echo(dat_stmt->stmt[2].str)
   CALL echo(dat_stmt->stmt[3].str)
   CALL echo(dat_stmt->stmt[4].str)
   CALL echo(dat_stmt->stmt[5].str)
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DAT_STMT")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE call_ins_dcl(i_table_name,i_pk_where,i_log_type,i_delete_ind,i_updt_id,i_updt_task,
  i_updt_applctx,i_ctx_str,i_envid,i_spass_log_id,i_dblink,i_pk_hash,i_ptam_hash)
   DECLARE cil_delete_ind_str = vc
   DECLARE cil_updt_id_str = vc
   DECLARE cil_updt_task_str = vc
   DECLARE cil_updt_applctx_str = vc
   DECLARE cil_ctx_str = vc
   DECLARE cil_envid_str = vc
   DECLARE cil_spass_log_id = vc
   DECLARE cil_pk = vc
   DECLARE cil_db_link = vc
   DECLARE cil_table_name = vc
   DECLARE cil_pk_hash = vc
   DECLARE cil_ptam_hash = vc
   DECLARE cil_ptam_result = vc
   DECLARE cil_log_type = vc
   DECLARE cid_delete_ind = i2
   DECLARE cid_updt_id = f8
   DECLARE cid_updt_task = i4
   DECLARE cid_updt_applctx = i4
   DECLARE cid_i_envid = f8
   DECLARE cid_i_pk_where = vc
   DECLARE cid_ptam_str_ind = i2 WITH protect, noconstant(0)
   SET cid_delete_ind = i_delete_ind
   SET cid_updt_id = i_updt_id
   SET cid_updt_task = i_updt_task
   SET cid_updt_applctx = i_updt_applctx
   SET cid_i_envid = i_envid
   SET cid_i_pk_where = i_pk_where
   SET cil_pk = replace_carrot_symbol(cid_i_pk_where)
   FREE RECORD dat_stmt
   RECORD dat_stmt(
     1 stmt[5]
       2 str = vc
   )
   IF (trim(i_ctx_str) > "")
    SET cil_ctx_str = trim(i_ctx_str)
   ELSE
    SET cil_ctx_str = "NULL"
   ENDIF
   IF (cid_i_envid=0)
    SET cil_envid_str = "NULL"
   ELSE
    SET cil_envid_str = trim(cnvtstring(cid_i_envid))
   ENDIF
   IF (i_spass_log_id=0)
    SET cil_spass_log_id = "NULL"
   ELSE
    SET cil_spass_log_id = trim(cnvtstring(i_spass_log_id))
   ENDIF
   SET cil_delete_ind_str = trim(cnvtstring(cid_delete_ind))
   SET cil_updt_id_str = trim(cnvtstring(cid_updt_id))
   SET cil_updt_task_str = trim(cnvtstring(cid_updt_task))
   SET cil_updt_applctx_str = trim(cnvtstring(cid_updt_applctx))
   SET cil_spass_log_id = trim(cnvtstring(i_spass_log_id))
   SET cil_db_link = trim(i_dblink)
   SET cil_table_name = trim(i_table_name)
   SET cil_pk_hash = trim(cnvtstring(i_pk_hash))
   SET cil_ptam_hash = trim(cnvtstring(i_ptam_hash))
   SET cil_log_type = trim(i_log_type)
   SELECT INTO "nl:"
    FROM (parser(concat("user_source",cil_db_link)) uo)
    WHERE uo.name="PROC_REFCHG_INS_DCL"
    DETAIL
     IF (cnvtlower(uo.text)="*i_ptam_match_result_str*")
      cid_ptam_str_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "PROC_REFCHG_INS_DCL was not found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    SET cil_ptam_result = cnvtstring(drmm_get_ptam_match_result(0.0,0.0,0.0,"",1,
      "FROM"))
    SET dat_stmt->stmt[1].str = concat("RDB ASIS(^ BEGIN proc_refchg_ins_dcl",trim(cil_db_link),"('",
     cil_table_name,"',^)")
    SET dat_stmt->stmt[2].str = concat("ASIS(^ ",cil_pk,",^)")
    SET dat_stmt->stmt[3].str = concat("ASIS(^ dbms_utility.get_hash_value(",cil_pk,
     ",0,1073741824.0)",",'",cil_log_type,
     "',",cil_delete_ind_str,",",cil_updt_id_str,",",
     cil_updt_task_str,",",cil_updt_applctx_str,"^)")
    SET dat_stmt->stmt[4].str = concat("ASIS(^,'",cil_ctx_str,"',",cil_envid_str,
     ",sys_context('CERNER','RDDS_PTAM_MATCH_QUERY',2000),",
     cil_ptam_result,",sys_context('CERNER','RDDS_COL_STRING',4000)",",",cil_pk_hash,",",
     cil_ptam_hash,",",cil_spass_log_id)
    IF (cid_ptam_str_ind=1)
     SET dat_stmt->stmt[4].str = concat(dat_stmt->stmt[4].str,
      ",sys_context('CERNER','RDDS_PTAM_MATCH_RESULT_STR',4000)^)")
    ELSE
     SET dat_stmt->stmt[4].str = concat(dat_stmt->stmt[4].str,"^)")
    ENDIF
    SET dat_stmt->stmt[5].str = concat("ASIS(^","); END; ^) go")
    CALL echo(dat_stmt->stmt[1].str)
    CALL echo(dat_stmt->stmt[2].str)
    CALL echo(dat_stmt->stmt[3].str)
    CALL echo(dat_stmt->stmt[4].str)
    CALL echo(dat_stmt->stmt[5].str)
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DAT_STMT")
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 IF ((validate(drwdr_request->from_value,- (1.0))=- (1.0)))
  FREE RECORD drwdr_request
  RECORD drwdr_request(
    1 table_name = vc
    1 log_type = vc
    1 col_name = vc
    1 from_value = f8
    1 source_env_id = f8
    1 target_env_id = f8
    1 dclei_ind = i2
    1 dcl_excep_id = f8
  )
  FREE RECORD drwdr_reply
  RECORD drwdr_reply(
    1 dcle_id = f8
    1 error_ind = i2
  )
 ENDIF
 IF ( NOT (validate(drfdx_request,0)))
  FREE RECORD drfdx_request
  RECORD drfdx_request(
    1 exception_id = f8
    1 target_env_id = f8
    1 db_link = vc
    1 exclude_str = vc
  )
  FREE RECORD drfdx_reply
  RECORD drfdx_reply(
    1 err_ind = i2
    1 emsg = vc
    1 total = i4
    1 row[*]
      2 log_id = f8
      2 table_name = vc
      2 log_type = vc
      2 pk_where = vc
      2 updt_dt_tm = f8
      2 updt_task = i4
      2 updt_id = f8
      2 context_name = vc
      2 current_context_ind = i2
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
 DECLARE replace_delim_vals(rcs_string=vc,rcs_size=i4) = vc
 DECLARE replace_char(rc_string=vc) = vc
 SUBROUTINE replace_delim_vals(rcs_string,rcs_size)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   DECLARE rcs_size_diff = i4
   CALL echo(rcs_string)
   SET rcs_temp_val = rcs_string
   IF (rcs_size > 0)
    SET rcs_size_diff = (rcs_size - size(rcs_temp_val))
   ENDIF
   IF (findstring("^",rcs_temp_val,0,0) > 0)
    IF (findstring('"',rcs_temp_val,0,0) > 0)
     IF (findstring("'",rcs_temp_val,0,0) > 0)
      SET rcs_start_idx = 1
      SET rcs_pos = findstring("^",rcs_temp_val,1,0)
      WHILE (rcs_pos > 0)
        IF (rcs_start_idx=1)
         IF (rcs_pos=1)
          SET rcs_return = "char(94)"
         ELSE
          SET rcs_return = concat("concat(^",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),
           "^,char(94)")
         ENDIF
        ELSE
         SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
           rcs_temp_val),"^,char(94)")
        ENDIF
        SET rcs_start_idx = (rcs_pos+ 1)
        SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
        CALL echo(rcs_return)
      ENDWHILE
      IF (rcs_start_idx <= size(rcs_temp_val))
       SET rcs_pos = findstring("^",rcs_temp_val,1,1)
       IF (rcs_size_diff > 0)
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),fillstring(value(rcs_size_diff)," "),"^)")
       ELSE
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),"^)")
       ENDIF
      ENDIF
      CALL echo(rcs_return)
      RETURN(rcs_return)
     ELSE
      SET rcs_return = concat("'",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"'")
      RETURN(rcs_return)
     ENDIF
    ELSE
     SET rcs_return = concat('"',rcs_temp_val,fillstring(value(rcs_size_diff)," "),'"')
     RETURN(rcs_return)
    ENDIF
   ELSE
    SET rcs_return = concat("^",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"^")
    RETURN(rcs_return)
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_char(rc_string)
   DECLARE rc_return = vc
   DECLARE rc_char_pos = i4
   DECLARE rc_char_loop = i2
   DECLARE rc_delim_val = vc
   DECLARE rc_last_ind = i2
   DECLARE rc_only_ind = i2
   SET rc_return = rc_string
   SET rc_only_ind = 0
   SET rc_last_ind = 0
   SET rc_char_ind = 0
   SET rc_char_loop = 0
   WHILE (rc_char_loop=0)
    SET rc_char_pos = findstring(char(0),rc_return,0,0)
    IF (rc_char_pos > 0)
     IF (rc_char_ind=0)
      IF (findstring("'",rc_return,0,0)=0)
       SET rc_delim_val = "'"
      ELSEIF (findstring('"',rc_return,0,0)=0)
       SET rc_delim_val = '"'
      ELSEIF (findstring("^",rc_return,0,0)=0)
       SET rc_delim_val = "^"
      ENDIF
     ENDIF
     IF (rc_char_pos=size(rc_return)
      AND rc_char_pos=1)
      SET rc_return = "char(0)"
      SET rc_last_ind = 1
      SET rc_only_ind = 1
     ELSEIF (rc_char_pos=size(rc_return)
      AND rc_char_pos != 1)
      SET rc_last_ind = 1
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (rc_char_pos=1)
      IF (rc_delim_val="'")
       SET rc_return = concat("char(0),'",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val='"')
       SET rc_return = concat('char(0),"',substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val="^")
       SET rc_return = concat("char(0),^",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ENDIF
     ELSE
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),',char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET rc_char_ind = 1
    ELSE
     SET rc_char_loop = 1
    ENDIF
   ENDWHILE
   IF (rc_last_ind=0)
    SET rc_return = concat(rc_return,rc_delim_val)
   ENDIF
   IF (rc_char_ind=1
    AND rc_only_ind=0)
    SET rc_return = concat("CONCAT(",rc_return,")")
   ENDIF
   RETURN(rc_return)
 END ;Subroutine
 DECLARE replace_delim_vals(rcs_string=vc,rcs_size=i4) = vc
 DECLARE replace_char(rc_string=vc) = vc
 SUBROUTINE replace_delim_vals(rcs_string,rcs_size)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   DECLARE rcs_size_diff = i4
   CALL echo(rcs_string)
   SET rcs_temp_val = rcs_string
   IF (rcs_size > 0)
    SET rcs_size_diff = (rcs_size - size(rcs_temp_val))
   ENDIF
   IF (findstring("^",rcs_temp_val,0,0) > 0)
    IF (findstring('"',rcs_temp_val,0,0) > 0)
     IF (findstring("'",rcs_temp_val,0,0) > 0)
      SET rcs_start_idx = 1
      SET rcs_pos = findstring("^",rcs_temp_val,1,0)
      WHILE (rcs_pos > 0)
        IF (rcs_start_idx=1)
         IF (rcs_pos=1)
          SET rcs_return = "char(94)"
         ELSE
          SET rcs_return = concat("concat(^",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),
           "^,char(94)")
         ENDIF
        ELSE
         SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
           rcs_temp_val),"^,char(94)")
        ENDIF
        SET rcs_start_idx = (rcs_pos+ 1)
        SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
        CALL echo(rcs_return)
      ENDWHILE
      IF (rcs_start_idx <= size(rcs_temp_val))
       SET rcs_pos = findstring("^",rcs_temp_val,1,1)
       IF (rcs_size_diff > 0)
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),fillstring(value(rcs_size_diff)," "),"^)")
       ELSE
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),"^)")
       ENDIF
      ENDIF
      CALL echo(rcs_return)
      RETURN(rcs_return)
     ELSE
      SET rcs_return = concat("'",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"'")
      RETURN(rcs_return)
     ENDIF
    ELSE
     SET rcs_return = concat('"',rcs_temp_val,fillstring(value(rcs_size_diff)," "),'"')
     RETURN(rcs_return)
    ENDIF
   ELSE
    SET rcs_return = concat("^",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"^")
    RETURN(rcs_return)
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_char(rc_string)
   DECLARE rc_return = vc
   DECLARE rc_char_pos = i4
   DECLARE rc_char_loop = i2
   DECLARE rc_delim_val = vc
   DECLARE rc_last_ind = i2
   DECLARE rc_only_ind = i2
   SET rc_return = rc_string
   SET rc_only_ind = 0
   SET rc_last_ind = 0
   SET rc_char_ind = 0
   SET rc_char_loop = 0
   WHILE (rc_char_loop=0)
    SET rc_char_pos = findstring(char(0),rc_return,0,0)
    IF (rc_char_pos > 0)
     IF (rc_char_ind=0)
      IF (findstring("'",rc_return,0,0)=0)
       SET rc_delim_val = "'"
      ELSEIF (findstring('"',rc_return,0,0)=0)
       SET rc_delim_val = '"'
      ELSEIF (findstring("^",rc_return,0,0)=0)
       SET rc_delim_val = "^"
      ENDIF
     ENDIF
     IF (rc_char_pos=size(rc_return)
      AND rc_char_pos=1)
      SET rc_return = "char(0)"
      SET rc_last_ind = 1
      SET rc_only_ind = 1
     ELSEIF (rc_char_pos=size(rc_return)
      AND rc_char_pos != 1)
      SET rc_last_ind = 1
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (rc_char_pos=1)
      IF (rc_delim_val="'")
       SET rc_return = concat("char(0),'",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val='"')
       SET rc_return = concat('char(0),"',substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val="^")
       SET rc_return = concat("char(0),^",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ENDIF
     ELSE
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),',char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET rc_char_ind = 1
    ELSE
     SET rc_char_loop = 1
    ENDIF
   ENDWHILE
   IF (rc_last_ind=0)
    SET rc_return = concat(rc_return,rc_delim_val)
   ENDIF
   IF (rc_char_ind=1
    AND rc_only_ind=0)
    SET rc_return = concat("CONCAT(",rc_return,")")
   ENDIF
   RETURN(rc_return)
 END ;Subroutine
 DECLARE drdm_create_pk_where(dcpw_cnt=i4,dcpw_table_cnt=i4,dcpw_type=vc) = vc
 DECLARE drdm_add_pkw_col(dapc_cnt=i4,dapc_table_cnt=i4,dapc_col_cnt=i4,dapc_pk_str=vc,
  dapc_col_null_ind=i2,
  dapc_ts_ind=i2) = vc
 SUBROUTINE drdm_create_pk_where(dcpw_cnt,dcpw_table_cnt,dcpw_type)
   DECLARE dcpw_pkw_col_cnt = i4
   DECLARE dcpw_pk_str = vc
   DECLARE dcpw_suffix = vc
   DECLARE dcpw_tbl_loop = i4
   DECLARE dcpw_col_nullind = i2
   DECLARE dcpw_col_loop = i4
   DECLARE dcpw_error_ind = i2
   DECLARE dcpw_col_str = vc WITH protect, noconstant("")
   DECLARE dcpw_col_str_vc = vc WITH protect, noconstant("")
   DECLARE dcpw_ts_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpw_col_len = i4 WITH protect, noconstant(0)
   DECLARE dcpw_col_diff = i4 WITH protect, noconstant(0)
   SET dcpw_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].suffix)
   IF ((validate(cust_cs_rows->trailing_space_ind,- (5))=- (5))
    AND (validate(cust_cs_rows->trailing_space_ind,- (6))=- (6)))
    SET dcpw_ts_ind = 0
   ELSE
    SET dcpw_ts_ind = 1
   ENDIF
   SET mdr_pk_cnt = 0
   SET mdr_pk_str = ""
   IF (dcpw_type="MD")
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].merge_delete_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ELSEIF (dcpw_type="UI")
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].unique_ident_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ELSEIF (dcpw_type IN ("ALG5", "ALG7"))
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].exception_flg=12))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
    IF (dcpw_type="ALG5")
     SET dcpw_pk_str = concat(dcpw_pk_str," and ",dcpw_suffix,".",dm2_ref_data_doc->tbl_qual[
      dcpw_table_cnt].beg_col_name,
      " <= cnvtdatetime(curdate,curtime3) and ",dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].
      end_col_name," > cnvtdatetime(curdate,curtime3) ")
    ENDIF
   ELSE
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].pk_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ENDIF
   IF (dcpw_error_ind=0)
    RETURN(dcpw_pk_str)
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE drdm_add_pkw_col(dapc_cnt,dapc_table_cnt,dapc_col_cnt,dapc_pk_str,dapc_col_nullind,
  dapc_ts_ind)
   DECLARE dapc_suffix = vc
   DECLARE dapc_col_name = vc WITH protect, noconstant(" ")
   DECLARE dapc_float = f8 WITH protect, noconstant(0.0)
   DECLARE dapc_float_str = vc WITH protect, noconstant(" ")
   DECLARE dapc_col_str = vc WITH protect, noconstant(" ")
   DECLARE dapc_col_len = i4 WITH protect, noconstant(0)
   DECLARE dapc_ret = vc WITH protect, noconstant(" ")
   SET dapc_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[dapc_table_cnt].suffix)
   SET dapc_col_name = dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].column_name
   SET dapc_ret = dapc_pk_str
   IF (dapc_col_nullind=1)
    SET dapc_ret = concat(dapc_ret," ",dapc_suffix,".",dapc_col_name,
     " is NULL ")
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="F8"))
    CALL parser(concat("set dapc_float = cust_cs_rows->qual[dapc_cnt].",dapc_col_name," go"),1)
    IF (dapc_float=round(dapc_float,0))
     SET dapc_float_str = concat(trim(cnvtstring(dapc_float,20)),".0")
    ELSE
     SET dapc_float_str = build(dapc_float)
    ENDIF
    CALL parser(concat("set dapc_ret = concat(dapc_ret, ' ",dapc_suffix,".",dapc_col_name,
      " =', dapc_float_str) go"),1)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type IN ("I4",
   "I2")))
    CALL parser(concat("set dapc_ret = concat(dapc_ret, ' ",dapc_suffix,".",dapc_col_name," =',",
      "trim(cnvtstring(cust_cs_rows->qual[dapc_cnt].",dapc_col_name,")),'.0') go"),1)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type IN ("VC",
   "C*")))
    SET dapc_col_str = ""
    CALL parser(concat("set dapc_col_str = cust_cs_rows->qual[dapc_cnt].",dapc_col_name," go"),1)
    IF (dapc_ts_ind=1)
     IF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="VC"))
      CALL parser(concat("set dapc_col_len = cust_cs_rows->qual[dapc_cnt].",dapc_col_name,"_len go"),
       1)
      SET dapc_col_diff = (dapc_col_len - size(dapc_col_str))
     ELSE
      SET dapc_col_len = 0
      SET dapc_col_diff = 0
     ENDIF
    ELSE
     SET dapc_col_len = 0
     SET dapc_col_diff = 0
    ENDIF
    SET dapc_col_str = replace_char(dapc_col_str)
    IF (findstring("char(0)",dapc_col_str,0,0)=0)
     SET dapc_col_str = concat(replace_delim_vals(dapc_col_str,dapc_col_len))
    ELSE
     IF (dcp_col_diff=0)
      SET dapc_col_str = dapc_col_str
     ELSE
      SET dapc_col_str = concat(substring(1,(size(dapc_col_str) - 1),dapc_col_str),"^",fillstring(
        value(rcs_size_diff)," "),"^)")
     ENDIF
    ENDIF
    IF (((findstring(char(42),dapc_col_str) > 0) OR (((findstring(char(63),dapc_col_str) > 0) OR (
    findstring(char(92),dapc_col_str) > 0)) )) )
     SET dapc_col_str = concat("nopatstring(",dapc_col_str,")")
    ENDIF
    SET dapc_ret = concat(dapc_ret," ",dapc_suffix,".",dapc_col_name,
     "=",dapc_col_str)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="DQ8"))
    CALL parser(concat("set dapc_ret = concat(dapc_ret,' ",dapc_suffix,".",dapc_col_name,
      " =  cnvtdatetime('",
      ",trim(build(cust_cs_rows->qual[dapc_cnt].",dapc_col_name,")),","')') go"),1)
   ELSE
    SET dapc_error_ind = 1
    CALL disp_msg(concat("An unknown datatype was found when trying to create pk_where: ",
      dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type),dm_err->logfile,1)
   ENDIF
   RETURN(dapc_ret)
 END ;Subroutine
 IF (validate(drdm_sequence->qual_cnt,- (1)) < 0)
  FREE RECORD drdm_sequence
  RECORD drdm_sequence(
    1 qual[*]
      2 seq_name = vc
      2 seq_val = f8
      2 seqmatch_ind = i2
    1 qual_cnt = i4
  )
 ENDIF
 IF (validate(dm2_rdds_rec->mode,"NONE")="NONE")
  FREE RECORD dm2_rdds_rec
  RECORD dm2_rdds_rec(
    1 mode = vc
    1 main_process = vc
  )
 ENDIF
 IF (validate(select_merge_translate_rec->type,"NONE")="NONE")
  FREE RECORD select_merge_translate_rec
  RECORD select_merge_translate_rec(
    1 type = vc
    1 to_opt_ind = i2
    1 from_opt_ctxt = vc
  )
 ENDIF
 IF (validate(tpc_pkw_vers_id->data[1].dm_refchg_pkw_vers_id,- (1)) < 0)
  FREE RECORD tpc_pkw_vers_id
  RECORD tpc_pkw_vers_id(
    1 data[*]
      2 table_name = vc
      2 dm_refchg_pkw_vers_id = f8
  )
 ENDIF
 IF ((validate(multi_col_pk->table_cnt,- (1))=- (1))
  AND (validate(multi_col_pk->table_cnt,- (2))=- (2)))
  FREE RECORD multi_col_pk
  RECORD multi_col_pk(
    1 table_cnt = i4
    1 qual[*]
      2 table_name = vc
      2 column_name = vc
  )
 ENDIF
 IF (validate(drmm_hold_exception->qual[1].dcl_excep_id,- (1)) < 0)
  FREE RECORD drmm_hold_exception
  RECORD drmm_hold_exception(
    1 value_cnt = i4
    1 qual[*]
      2 dcl_excep_id = f8
      2 table_name = vc
      2 column_name = vc
      2 from_value = f8
      2 log_type = vc
  )
 ENDIF
 IF ((validate(drdm_debug_row_ind,- (1))=- (1)))
  DECLARE drdm_debug_row_ind = i2 WITH protect, noconstant(0)
 ENDIF
 DECLARE merge_audit(action=vc,text=vc,audit_type=i4) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE drcm_get_xlat(dgx_f_value=vc,dgx_t_name=vc) = f8
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE trigger_proc_call(tpc_table_name=vc,tpc_pk_where=vc,tpc_context=vc,tpc_col_name=vc,tpc_value
  =f8) = i2
 DECLARE filter_proc_call(fpc_table_name=vc,fpc_pk_where=vc,fpc_updt_applctx=f8) = i2
 DECLARE replace_carrot_symbol(rcs_string=vc) = vc
 DECLARE replace_apostrophe(rcs_string=vc) = vc
 DECLARE log_md_scommit(lms_tab_name=vc,lms_tbl_cnt=i4,lms_log_type=vc,lms_chg_cnt=i4) = i4
 DECLARE load_merge_del(lmd_cnt=i4,lmd_log_type=vc,lmd_chg_cnt=i4) = i2
 DECLARE orphan_child_tab(sbr_table_name=vc,sbr_log_type=vc,sbr_col_name=vc,sbr_from_value=f8) = i2
 DECLARE drcm_validate(sbr_dv_t_name=vc,sbr_dv_pk_where=vc,sbr_dv_table_cnt=i4) = i2
 DECLARE find_nvld_value(fnv_value=vc,fnv_table=vc,fnv_from_value=vc) = vc
 DECLARE check_backfill(i_source_id=f8,i_table_name=vc,i_tbl_pos=i4) = c1
 DECLARE redirect_to_start_row(rsr_drdm_chg_rs=vc(ref),rsr_log_pos=i4,rsr_next_row=i4(ref),
  rsr_max_size=i4(ref)) = i4
 DECLARE get_multi_col_pk(null) = i2
 DECLARE find_original_log_row(i_drdm_chg_rs=vc(ref),i_log_pos=i4) = i4
 DECLARE fill_cur_state_rs(fcs_tab_name=vc) = i4
 DECLARE drdm_hash_validate(sbr_dv_t_name=vc,sbr_dv_pk_where=vc,sbr_dv_table_cnt=i4,sbr_dv_pkw_hash=
  f8,sbr_dv_ptam_hash=f8,
  sbr_dv_delete_ind=i2,sbr_updt_applctx=f8) = f8
 DECLARE trigger_proc_dcl(tpd_log_id=f8,tpd_table_name=vc,tpd_pk_str=vc,tpd_delete_ind=i2,
  tpd_sp_log_id=f8,
  tpd_log_type=vc,tpd_context=vc) = f8
 DECLARE add_single_pass_dcl_row(i_table_name=vc,i_pk_string=vc,i_single_pass_log_id=f8,
  i_context_name=vc) = f8
 DECLARE reset_exceptions(re_tab_name=vc,re_tgt_env_id=f8,re_from_value=f8,re_data=vc(ref)) = i2
 DECLARE fill_hold_excep_rs(null) = null
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1,sbr_ccs_cur_appl_id=vc) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE load_grouper(lg_cnt=i4,lg_log_type=vc,lg_chg_cnt=i4) = i2
 DECLARE remove_cached_xlat(rcx_tab_name=vc,rcx_from_value=f8) = i2
 DECLARE add_xlat_ctxt_r(axc_tab_name=vc,axc_from_value=f8,axc_to_value=f8,axc_ctxt=vc) = i2
 DECLARE drcm_block_ptam_circ(dbp_rec=vc(ref),dbp_tbl_cnt=i4,dbp_pk_col=vc,dbp_pk_col_value=f8) =
 null
 DECLARE drcm_get_pk_str(dgps_rec=vc(ref),dgps_tab_name=vc) = vc
 DECLARE drcm_load_bulk_dcle(dlbd_tab_name=vc,dlbd_tbl_cnt=i4,dlbd_log_type=vc,dlbd_chg_cnt=i4) = i4
 SUBROUTINE parse_statements(drdm_parser_cnt)
   FOR (parse_loop = 1 TO drdm_parser_cnt)
     IF (parse_loop=drdm_parser_cnt)
      SET drdm_go_ind = 1
     ELSE
      SET drdm_go_ind = 0
     ENDIF
     IF ((drdm_parser->statement[parse_loop].frag=""))
      CALL echo("")
      CALL echo("")
      CALL echo("A DYNAMIC STATEMENT WAS IMPROPERLY LOADED")
      CALL echo("")
      CALL echo("")
     ENDIF
     CALL parser(drdm_parser->statement[parse_loop].frag,drdm_go_ind)
     SET drdm_parser->statement[parse_loop].frag = ""
     IF (check_error(dm_err->eproc)=1)
      IF (findstring("ORA-20100:",dm_err->emsg) > 0)
       SET drdm_mini_loop_status = "NOMV08"
       CALL merge_audit("FAILREASON",
        "The row is trying to update/insert/delete the default row in target",1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE drcm_get_xlat(dgx_f_value,dgx_t_name)
   DECLARE dgx_tbl_pos = i4 WITH protect, noconstant(0)
   DECLARE dgx_loop = i4 WITH protect, noconstant(0)
   DECLARE dgx_cur_table = i4 WITH protect, noconstant(0)
   DECLARE dgx_exception_flg = i4 WITH protect, noconstant(0)
   DECLARE dgx_return_val = vc WITH protect, noconstant("")
   DECLARE dgx_zero_ind = i2 WITH protect, noconstant(0)
   DECLARE dgx_mult_pk_pos = i4 WITH protect, noconstant(0)
   DECLARE dgx_mult_pk_idx = i4 WITH protect, noconstant(0)
   DECLARE dgx_xlat_func = vc WITH protect, noconstant("")
   DECLARE dgx_xlat_ret = f8 WITH protect, noconstant(0.0)
   DECLARE dgx_find_nvld_ret = vc WITH protect, noconstant("")
   DECLARE dgx_dtxc_text = vc WITH protect, noconstant("")
   SET dgx_xlat_ret = - (1.5)
   IF (dgx_t_name != "RDDS:MOVE AS IS")
    SET dgx_tbl_pos = locateval(dgx_loop,1,dm2_ref_data_doc->tbl_cnt,dgx_t_name,dm2_ref_data_doc->
     tbl_qual[dgx_loop].table_name)
    IF (cnvtreal(dgx_f_value) <= 0)
     RETURN(cnvtreal(dgx_f_value))
    ENDIF
    IF (dgx_tbl_pos=0)
     SET dgx_cur_table = temp_tbl_cnt
     SET dgx_tbl_pos = fill_rs("TABLE",dgx_t_name)
     SET temp_tbl_cnt = dgx_cur_table
     IF ((dgx_tbl_pos=- (1)))
      CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     ENDIF
     IF ((dgx_tbl_pos=- (2)))
      SET drmm_ddl_rollback_ind = 1
      RETURN(dgx_xlat_ret)
     ENDIF
    ENDIF
    IF (dgx_tbl_pos <= 0)
     RETURN(dgx_xlat_ret)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].mergeable_ind=0))
     RETURN(dgx_xlat_ret)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].skip_seqmatch_ind != 1))
     FOR (dgx_loop = 1 TO dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_qual[dgx_loop].pk_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_qual[dgx_loop].root_entity_name=dgx_t_name))
        SET dgx_exception_flg = dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_qual[dgx_loop].
        exception_flg
       ENDIF
     ENDFOR
    ENDIF
    IF ((((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].skip_seqmatch_ind != 1)) OR ((dm2_ref_data_doc->
    tbl_qual[dgx_tbl_pos].table_name="APPLICATION_TASK"))) )
     SET dgx_return_val = check_backfill(dm2_ref_data_doc->env_source_id,dgx_t_name,dgx_tbl_pos)
     IF (dgx_return_val="F"
      AND dgx_exception_flg != 1)
      RETURN(dgx_xlat_ret)
     ENDIF
    ENDIF
   ENDIF
   IF ((((global_mover_rec->xlat_from_function != "XLAT_FROM_*")) OR ((global_mover_rec->
   xlat_to_function != "XLAT_TO_*"))) )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="RDDS ENV PAIR"
      AND d.info_name=concat(cnvtstring(dm2_ref_data_doc->env_source_id,20),"::",cnvtstring(
       dm2_ref_data_doc->env_target_id,20))
     DETAIL
      global_mover_rec->xlat_to_function = concat("XLAT_TO_",cnvtstring(d.info_number,20)),
      global_mover_rec->xlat_from_function = concat("XLAT_FROM_",cnvtstring(d.info_number,20)),
      global_mover_rec->xlat_funct_nbr = d.info_number
     WITH nocounter
    ;end select
    IF (check_error("Get xlat functions") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual != 1)
     SET dm_err->emsg = "Error getting XLAT functions"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
     RETURN(dgx_xlat_ret)
    ELSE
     CALL parser(concat("declare ",global_mover_rec->xlat_to_function,"() = f8 go"),1)
     CALL parser(concat("declare ",global_mover_rec->xlat_from_function,"() = f8 go"),1)
    ENDIF
   ENDIF
   IF ((drdm_chg->log[drdm_log_loop].delete_ind=1))
    CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('MVR_DEL_LOOKUP','YES'); END; ^) GO"),1)
   ENDIF
   IF (findstring(".0",dgx_f_value,1,0) > 0)
    SET dgx_zero_ind = 1
   ELSE
    SET dgx_zero_ind = 0
   ENDIF
   SET dgx_mult_pk_pos = locateval(dgx_mult_pk_idx,1,multi_col_pk->table_cnt,dgx_t_name,multi_col_pk
    ->qual[dgx_mult_pk_idx].table_name)
   IF ((select_merge_translate_rec->type != "TO"))
    IF (dgx_mult_pk_pos > 0)
     SET dgx_find_nvld_ret = find_nvld_value("0",dgx_t_name,dgx_f_value)
    ENDIF
    IF (dgx_zero_ind=0)
     SET dgx_xlat_func = concat(global_mover_rec->xlat_from_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ".0,",cnvtstring(dgx_exception_flg))
    ELSE
     SET dgx_xlat_func = concat(global_mover_rec->xlat_from_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ",",cnvtstring(dgx_exception_flg))
    ENDIF
    IF ((global_mover_rec->cbc_ind=1)
     AND trim(select_merge_translate_rec->from_opt_ctxt) > "")
     SET dgx_xlat_func = concat(dgx_xlat_func,',"',select_merge_translate_rec->from_opt_ctxt,'"')
    ENDIF
    SET dgx_xlat_func = concat(dgx_xlat_func,")")
    SELECT INTO "nl:"
     result1 = parser(dgx_xlat_func)
     FROM dual
     DETAIL
      dgx_xlat_ret = round(result1,2)
     WITH nocounter
    ;end select
   ELSE
    IF (dgx_mult_pk_pos > 0)
     SET dgx_find_nvld_ret = find_nvld_value(dgx_f_value,dgx_t_name,"0")
    ENDIF
    IF (dgx_zero_ind=0)
     SET dgx_xlat_func = concat(global_mover_rec->xlat_to_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ".0,",cnvtstring(dgx_exception_flg),",",cnvtstring(select_merge_translate_rec->to_opt_ind),")")
    ELSE
     SET dgx_xlat_func = concat(global_mover_rec->xlat_to_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ",",cnvtstring(dgx_exception_flg),",",cnvtstring(select_merge_translate_rec->to_opt_ind),")")
    ENDIF
    SELECT INTO "nl:"
     result1 = parser(dgx_xlat_func)
     FROM dual
     DETAIL
      dgx_xlat_ret = round(result1,2)
     WITH nocounter
    ;end select
   ENDIF
   IF (drdm_debug_row_ind=1)
    DECLARE sys_context() = c2000
    SELECT INTO "nl:"
     y = sys_context("CERNER","RDDS_XLAT_CACHE_TEST")
     FROM dual
     DETAIL
      dgx_dtxc_text = y
     WITH nocounter
    ;end select
    CALL echo(dgx_dtxc_text)
    CALL parser("rdb asis(^BEGIN DM2_CONTEXT_CONTROL('RDDS_XLAT_CACHE_TEST',''); END;^) GO",1)
   ENDIF
   CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('MVR_DEL_LOOKUP','NO'); END; ^) GO"),1)
   IF (check_error("Call xlat PL/SQL") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm_err->err_ind = 0
   ENDIF
   RETURN(dgx_xlat_ret)
 END ;Subroutine
 SUBROUTINE select_merge_translate(sbr_f_value,sbr_t_name)
   DECLARE sbr_return_val = vc
   DECLARE drdm_dmt_scr = vc
   DECLARE except_tab = vc
   DECLARE smt_loop = i4
   DECLARE smt_tbl_pos = i4
   DECLARE smt_cur_table = i4
   DECLARE smt_xlat_env_tgt_id = f8
   DECLARE smt_src_tab_name = vc
   DECLARE sbr_return_val2 = vc
   DECLARE new_col_var = vc
   DECLARE smt_parent_drdm_row = i2 WITH protect, noconstant(0)
   DECLARE smt_xlat_ret = f8 WITH protect, noconstant(0.0)
   DECLARE smt_zero_ind = i2 WITH protect, noconstant(0)
   DECLARE smt_mult_pk_pos = i4 WITH protect, noconstant(0)
   DECLARE smt_mult_pk_idx = i4 WITH protect, noconstant(0)
   DECLARE smt_vld_trans = f8 WITH protect, noconstant(0.0)
   SET sbr_return_val = "No Trans"
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET smt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   IF (cnvtreal(sbr_f_value) <= 0)
    RETURN(sbr_f_value)
   ENDIF
   IF (findstring(".0",sbr_f_value,1,0) > 0)
    SET smt_zero_ind = 1
   ELSE
    SET smt_zero_ind = 0
   ENDIF
   SET smt_xlat_ret = drcm_get_xlat(sbr_f_value,sbr_t_name)
   SET smt_mult_pk_pos = locateval(smt_mult_pk_idx,1,multi_col_pk->table_cnt,sbr_t_name,multi_col_pk
    ->qual[smt_mult_pk_idx].table_name)
   IF (sbr_t_name != "RDDS:MOVE AS IS")
    SET smt_tbl_pos = locateval(smt_loop,1,dm2_ref_data_doc->tbl_cnt,sbr_t_name,dm2_ref_data_doc->
     tbl_qual[smt_loop].table_name)
    IF (smt_tbl_pos=0)
     SET smt_cur_table = temp_tbl_cnt
     SET smt_tbl_pos = fill_rs("TABLE",sbr_t_name)
     SET temp_tbl_cnt = smt_cur_table
     IF ((smt_tbl_pos=- (1)))
      CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     ENDIF
     IF ((smt_tbl_pos=- (2)))
      SET drmm_ddl_rollback_ind = 1
      RETURN(sbr_return_val)
     ENDIF
    ENDIF
    IF (smt_tbl_pos <= 0)
     RETURN(sbr_return_val)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].mergeable_ind=0))
     RETURN(sbr_return_val)
    ENDIF
    SET new_col_var = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].root_col_name
   ENDIF
   IF ((smt_xlat_ret=- (1.4)))
    IF ((select_merge_translate_rec->type="TO"))
     SET sbr_return_val = "No Source"
    ELSE
     SET sbr_return_val = "No Trans"
    ENDIF
   ELSEIF ((smt_xlat_ret=- (1.5)))
    SET sbr_return_val = "No Trans"
   ELSEIF ((smt_xlat_ret=- (1.6)))
    IF ((global_mover_rec->ptam_ind=1))
     SET sbr_return_val = "NOMV21"
     IF (smt_zero_ind=0)
      CALL orphan_child_tab(sbr_t_name,"NOMV21",new_col_var,cnvtreal(concat(trim(sbr_f_value),".0")))
     ELSE
      CALL orphan_child_tab(sbr_t_name,"NOMV21",new_col_var,cnvtreal(sbr_f_value))
     ENDIF
     SET smt_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[smt_parent_drdm_row].chg_log_reason_txt = concat(
      "Invalid translation found for table ",sbr_t_name," column ",new_col_var," with a value of ",
      sbr_return_val," in TARGET. Row will be blocked from merging.")
     SET drdm_chg->log[smt_parent_drdm_row].chg_log_reason_txt = concat(drdm_chg->log[
      smt_parent_drdm_row].chg_log_reason_txt," ",drcm_get_pk_str(dm2_ref_data_doc,drdm_chg->log[
       smt_parent_drdm_row].table_name))
    ELSE
     SET smt_src_tab_name = dm2_get_rdds_tname("DM_MERGE_TRANSLATE")
     SET sbr_return_val = "No Trans"
     IF (smt_mult_pk_pos > 0)
      SET drdm_parser->statement[1].frag = "select into 'nl:' from dm_merge_translate dm "
      SET drdm_parser->statement[2].frag =
      "where dm.env_source_id = dm2_ref_data_doc->env_source_id and "
      SET drdm_parser->statement[3].frag = "dm.env_target_id = smt_xlat_env_tgt_id and "
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
       SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
      ELSE
       SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
      ENDIF
      SET drdm_parser->statement[5].frag = "dm.from_value = cnvtreal(sbr_f_value) "
      SET drdm_parser->statement[6].frag = "detail "
      SET drdm_parser->statement[7].frag = "smt_vld_trans = dm.to_value go"
      CALL parse_statements(7)
      IF (smt_vld_trans=0.0)
       SET drdm_parser->statement[1].frag = concat("select into 'nl:' from ",smt_src_tab_name," dm ")
       SET drdm_parser->statement[2].frag = "where dm.env_source_id = smt_xlat_env_tgt_id and "
       SET drdm_parser->statement[3].frag = "dm.env_target_id = dm2_ref_data_doc->env_source_id and "
       IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
        SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
       ELSE
        SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
       ENDIF
       SET drdm_parser->statement[5].frag = "dm.to_value = cnvtreal(sbr_f_value) "
       SET drdm_parser->statement[6].frag = "detail "
       SET drdm_parser->statement[7].frag = "smt_vld_trans = dm.from_value go"
       CALL parse_statements(7)
      ENDIF
      IF (smt_vld_trans > 0.0)
       SET sbr_return_val = find_nvld_value(concat(trim(cnvtstring(smt_vld_trans,20)),".0"),
        sbr_t_name,"0")
      ENDIF
     ENDIF
     IF (sbr_return_val="No Trans")
      SET drdm_parser->statement[1].frag = "delete from dm_merge_translate dm "
      SET drdm_parser->statement[2].frag =
      "where dm.env_source_id = dm2_ref_data_doc->env_source_id and "
      SET drdm_parser->statement[3].frag = "dm.env_target_id = smt_xlat_env_tgt_id and "
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
       SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
      ELSE
       SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
      ENDIF
      IF ((select_merge_translate_rec->type != "TO"))
       SET drdm_parser->statement[5].frag = "dm.from_value = cnvtreal(sbr_f_value) go"
      ELSE
       SET drdm_parser->statement[5].frag = "dm.to_value = cnvtreal(sbr_f_value) go"
      ENDIF
      CALL parse_statements(5)
      SET drdm_parser->statement[1].frag = concat("delete from ",smt_src_tab_name," dm ")
      SET drdm_parser->statement[2].frag = "where dm.env_source_id = smt_xlat_env_tgt_id and "
      SET drdm_parser->statement[3].frag = "dm.env_target_id = dm2_ref_data_doc->env_source_id and "
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
       SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
      ELSE
       SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
      ENDIF
      IF ((select_merge_translate_rec->type != "TO"))
       SET drdm_parser->statement[5].frag = "dm.to_value = cnvtreal(sbr_f_value) go"
      ELSE
       SET drdm_parser->statement[5].frag = "dm.from_value = cnvtreal(sbr_f_value) go"
      ENDIF
      CALL parse_statements(5)
      IF ((select_merge_translate_rec->type != "TO"))
       IF (remove_cached_xlat(sbr_t_name,cnvtreal(sbr_f_value))=0)
        SET drdm_error_out_ind = 1
        SET dm_err->emsg = "Error removing xlat from cache."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm2_ref_data_reply->error_ind = 1
        SET dm2_ref_data_reply->error_msg = dm_err->emsg
        RETURN(sbr_return_val)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET sbr_return_val = concat(trim(cnvtstring(smt_xlat_ret,20)),".0")
   ENDIF
   IF (isnumeric(sbr_return_val))
    IF ((drdm_chg->log[drdm_log_loop].delete_ind=0))
     CALL rdds_del_except(sbr_t_name,cnvtreal(sbr_f_value))
     IF (drmm_ddl_rollback_ind=1)
      SET sbr_return_val = "No Trans"
     ENDIF
    ENDIF
   ENDIF
   RETURN(sbr_return_val)
 END ;Subroutine
 SUBROUTINE insert_merge_translate(sbr_from,sbr_to,sbr_table)
   DECLARE imt_seq_name = vc
   DECLARE imt_seq_num = f8
   DECLARE imt_seq_loop = i4
   DECLARE imt_seq_cnt = i4
   DECLARE imt_rs_cnt = i4
   DECLARE imt_return = i2
   DECLARE imt_except_tab = vc
   DECLARE imt_pk_pos = i4
   DECLARE imt_xlat_env_tgt_id = f8
   DECLARE imt_parent_drdm_row = i2 WITH protect, noconstant(0)
   DECLARE imt_xlat_ret = f8 WITH protect, noconstant(0.0)
   DECLARE imt_tmp_smt_type = vc WITH protect, noconstant(" ")
   DECLARE imt_tmp_smt_opt = i2 WITH protect, noconstant(0)
   SET imt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET imt_return = 0
   SET dm_err->eproc = "Inserting Translation"
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind=0))
    FOR (imt_seq_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5))
      IF ((sbr_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].root_entity_name
      )
       AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].pk_ind=1))
       SET imt_pk_pos = imt_seq_loop
       SET imt_seq_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].
       sequence_name
      ENDIF
    ENDFOR
    SET imt_seq_cnt = locateval(imt_seq_loop,1,size(drdm_sequence->qual,5),imt_seq_name,drdm_sequence
     ->qual[imt_seq_loop].seq_name)
    SET imt_seq_num = drdm_sequence->qual[imt_seq_cnt].seq_val
    IF (sbr_to < imt_seq_num)
     SET imt_return = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("sbr_to:",trim(cnvtstring(sbr_to,20))))
    CALL echo(concat("sbr_table:",sbr_table))
   ENDIF
   SET imt_tmp_smt_type = select_merge_translate_rec->type
   SET imt_tmp_smt_opt = select_merge_translate_rec->to_opt_ind
   SET select_merge_translate_rec->type = "TO"
   SET select_merge_translate_rec->to_opt_ind = 1
   SET imt_xlat_ret = drcm_get_xlat(trim(cnvtstring(sbr_to,20,2)),sbr_table)
   SET select_merge_translate_rec->type = imt_tmp_smt_type
   SET select_merge_translate_rec->to_opt_ind = imt_tmp_smt_opt
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   IF (((imt_xlat_ret > 0) OR ((imt_xlat_ret=- (1.4)))) )
    SET imt_return = 1
   ENDIF
   IF (imt_return=0)
    INSERT  FROM dm_merge_translate dm
     SET dm.from_value = sbr_from, dm.to_value = sbr_to, dm.table_name = sbr_table,
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.status_flg = (drdm_chg->log[
      drdm_log_loop].status_flg+ 100), dm.log_id = drdm_chg->log[drdm_log_loop].log_id,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.env_target_id = imt_xlat_env_tgt_id, dm
      .updt_applctx = cnvtreal(currdbhandle)
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
     )) )
      SET drmm_ddl_rollback_ind = 1
      RETURN(0)
     ELSE
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
      RETURN(0)
     ENDIF
    ELSE
     DELETE  FROM dm_refchg_invalid_xlat drix
      WHERE drix.parent_entity_id=sbr_to
       AND drix.parent_entity_name=sbr_table
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
      )) )
       SET drmm_ddl_rollback_ind = 1
       RETURN(0)
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
       RETURN(0)
      ENDIF
     ENDIF
     IF (nvp_commit_ind=1
      AND (global_mover_rec->one_pass_ind=0))
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET drwdr_reply->dcle_id = 0
    SET drwdr_reply->error_ind = 0
    SET drwdr_request->table_name = sbr_table
    SET drwdr_request->log_type = "NOMV60"
    SET drwdr_request->col_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].
    column_name
    SET drwdr_request->from_value = sbr_from
    SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
    SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
    SET drwdr_request->dclei_ind = drmm_excep_flag
    EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
     "DRWDR_REPLY")
    IF ((drwdr_reply->error_ind=1))
     IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
     )) )
      SET drmm_ddl_rollback_ind = 1
      RETURN(0)
     ELSE
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
      RETURN(0)
     ENDIF
    ENDIF
    IF ((drwdr_reply->dcle_id > 0))
     SET imt_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     IF ((drdm_chg->log[imt_parent_drdm_row].dm_chg_log_exception_id=0))
      SET drdm_chg->log[imt_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
     ENDIF
     SET drdm_chg->log[imt_parent_drdm_row].chg_log_reason_txt = concat("Translation for table ",
      sbr_table," column ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
      " source value ",
      trim(cnvtstring(sbr_from,20,2))," and target value ",trim(cnvtstring(sbr_to,20,2)),
      " could not be stored in target because of existing translation for target value ",trim(
       cnvtstring(sbr_to,20,2)))
    ENDIF
    COMMIT
    SET drdm_mini_loop_status = "NOMV60"
    SET drdm_chg->log[drdm_log_loop].chg_log_reason_txt = concat("Translation for table ",sbr_table,
     " column ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
     " source value ",
     trim(cnvtstring(sbr_from,20,2))," and target value ",trim(cnvtstring(sbr_to,20,2)),
     " could not be stored in target because of existing translation for target value ",trim(
      cnvtstring(sbr_to,20,2)))
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET fail_merges = (fail_merges+ 1)
    SET fail_merge_audit->num[fail_merges].action = "FAILREASON"
    SET fail_merge_audit->num[fail_merges].text = "Preventing a 2 into 1 translation"
    CALL merge_audit(fail_merge_audit->num[fail_merges].action,fail_merge_audit->num[fail_merges].
     text,1)
    IF (drdm_error_out_ind=1)
     ROLLBACK
    ENDIF
   ENDIF
   RETURN(imt_return)
 END ;Subroutine
 SUBROUTINE merge_audit(action,text,audit_type)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON", "BATCH END", "WAITING",
   "BATCH START", "DELETE")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    SET ma_log_id = drdm_chg->log[drdm_log_loop].log_id
    IF (temp_tbl_cnt <= 0)
     SET ma_table_name = "NONE"
    ELSE
     SET ma_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     ROLLBACK
    ENDIF
    SELECT INTO "NL:"
     y = seq(dm_merge_audit_seq,nextval)
     FROM dual
     DETAIL
      ma_next_seq = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET nodelete_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
     RETURN(0)
    ELSE
     UPDATE  FROM dm_chg_log_audit dm
      SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
       dm.text = substring(1,1000,text), dm.table_name = ma_table_name, dm.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       dm.updt_applctx = cnvtreal(currdbhandle)
      WHERE dm.dm_chg_log_audit_id=ma_next_seq
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      SET nodelete_ind = 1
      IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
      )) )
       SET drmm_ddl_rollback_ind = 1
       RETURN(0)
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
       RETURN(0)
      ENDIF
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_chg_log_audit dm
       SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
        dm.text = substring(1,1000,text), dm.table_name = ma_table_name, dm.dm_chg_log_audit_id =
        ma_next_seq,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_applctx = cnvtreal(currdbhandle)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       SET nodelete_ind = 1
       IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
       )) )
        SET drmm_ddl_rollback_ind = 1
        RETURN(0)
       ELSE
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET drdm_error_out_ind = 1
        SET dm_err->err_ind = 0
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     IF (drdm_error_out_ind=0)
      COMMIT
     ENDIF
    ENDIF
    RETURN(1)
   ENDIF
   FREE SET aud_seq
   FREE SET ma_log_id
 END ;Subroutine
 SUBROUTINE rdds_del_except(sbr_table_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE der_idx = i4
   DECLARE der_pos = i4
   DECLARE der_loop = i4
   DECLARE der_start = i4
   DECLARE der_reset = i2 WITH protect, noconstant(0)
   DECLARE der_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE der_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE der_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE der_circ_pos = i4 WITH protect, noconstant(0)
   DECLARE der_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE der_pe_name_val = vc WITH protect, noconstant("")
   DECLARE der_last_pe_col = vc WITH protect, noconstant("")
   DECLARE der_pe_id_pos = i4 WITH protect, noconstant(0)
   DECLARE der_new_loop = i4 WITH protect, noconstant(0)
   DECLARE der_log_type_str = vc WITH protect, noconstant("")
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   FREE RECORD circ_ref
   RECORD circ_ref(
     1 cnt = i4
     1 qual[*]
       2 circ_table_name = vc
       2 circ_id_col = vc
       2 circ_pe_col = vc
       2 circ_root_col = vc
       2 excptn_cnt = i4
       2 excptn_qual[*]
         3 value = f8
       2 circ_val_cnt = i4
       2 circ_val_qual[*]
         3 circ_value = f8
   )
   IF ((drdm_chg->log[drdm_log_loop].table_name=sbr_table_name))
    SET der_tab_pos = locateval(der_tab_pos,1,dm2_ref_data_doc->tbl_cnt,sbr_table_name,
     dm2_ref_data_doc->tbl_qual[der_tab_pos].table_name)
    IF ((dm2_ref_data_doc->tbl_qual[der_tab_pos].circular_cnt > 0))
     FOR (der_circ_loop = 1 TO dm2_ref_data_doc->tbl_qual[der_tab_pos].circular_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].circular_type=2))
        IF ((dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col !=
        der_last_pe_col))
         SET der_last_pe_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].
         pe_name_col
         CALL drmm_get_col_string(drdm_chg->log[drdm_log_loop].pk_where,0.0,dm2_ref_data_doc->
          tbl_qual[der_tab_pos].table_name,dm2_ref_data_doc->tbl_qual[der_tab_pos].suffix,
          dm2_ref_data_doc->post_link_name)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET nodelete_ind = 1
          SET no_insert_update = 1
          SET drdm_error_out_ind = 1
          SET dm_err->err_ind = 0
          RETURN(null)
         ENDIF
         SELECT INTO "NL:"
          col_val = refchg_colstring_get_col(sys_context("CERNER","RDDS_COL_STRING",4000),
           dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col,4,0," ",
           0,0,"FROM")
          FROM dual
          DETAIL
           der_pe_name_val = col_val
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET nodelete_ind = 1
          SET no_insert_update = 1
          SET drdm_error_out_ind = 1
          SET dm_err->err_ind = 0
          RETURN(null)
         ENDIF
         SET der_pe_id_pos = locateval(der_pe_id_pos,1,dm2_ref_data_doc->tbl_qual[der_tab_pos].
          col_cnt,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col,
          dm2_ref_data_doc->tbl_qual[der_tab_pos].col_qual[der_pe_id_pos].parent_entity_col)
         SELECT INTO "NL:"
          der_y_name = evaluate_pe_name(dm2_ref_data_doc->tbl_qual[der_tab_pos].table_name,
           dm2_ref_data_doc->tbl_qual[der_tab_pos].col_qual[der_pe_id_pos].column_name,
           dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col,
           der_pe_name_val)
          FROM dual
          DETAIL
           der_pe_name_val = der_y_name
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET nodelete_ind = 1
          SET no_insert_update = 1
          SET drdm_error_out_ind = 1
          SET dm_err->err_ind = 0
          RETURN(null)
         ENDIF
        ENDIF
        IF ((der_pe_name_val=dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].
        circ_table_name))
         IF (locateval(der_new_loop,1,circ_ref->cnt,dm2_ref_data_doc->tbl_qual[der_tab_pos].
          circ_qual[der_circ_loop].circ_table_name,circ_ref->qual[der_new_loop].circ_table_name,
          dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].circ_id_col_name,circ_ref
          ->qual[der_new_loop].circ_id_col,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[
          der_circ_loop].circ_pe_name_col,circ_ref->qual[der_new_loop].circ_pe_col)=0)
          SET circ_ref->cnt = (circ_ref->cnt+ 1)
          SET stat = alterlist(circ_ref->qual,circ_ref->cnt)
          SET circ_ref->qual[circ_ref->cnt].circ_table_name = dm2_ref_data_doc->tbl_qual[der_tab_pos]
          .circ_qual[der_circ_loop].circ_table_name
          SET circ_ref->qual[circ_ref->cnt].circ_id_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
          circ_qual[der_circ_loop].circ_id_col_name
          SET circ_ref->qual[circ_ref->cnt].circ_pe_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
          circ_qual[der_circ_loop].circ_pe_name_col
          FOR (der_circ_pos = 1 TO drmm_hold_exception->value_cnt)
            IF ((drmm_hold_exception->qual[der_circ_pos].table_name=der_pe_name_val))
             SET circ_ref->qual[circ_ref->cnt].excptn_cnt = (circ_ref->qual[circ_ref->cnt].excptn_cnt
             + 1)
             SET stat = alterlist(circ_ref->qual[circ_ref->cnt].excptn_qual,circ_ref->qual[circ_ref->
              cnt].excptn_cnt)
             SET circ_ref->qual[circ_ref->cnt].excptn_qual[circ_ref->qual[circ_ref->cnt].excptn_cnt].
             value = drmm_hold_exception->qual[der_circ_pos].from_value
            ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        IF (locateval(der_new_loop,1,circ_ref->cnt,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[
         der_circ_loop].circ_table_name,circ_ref->qual[der_new_loop].circ_table_name,
         dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].circ_id_col_name,circ_ref->
         qual[der_new_loop].circ_id_col,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[
         der_circ_loop].circ_pe_name_col,circ_ref->qual[der_new_loop].circ_pe_col)=0)
         SET circ_ref->cnt = (circ_ref->cnt+ 1)
         SET stat = alterlist(circ_ref->qual,circ_ref->cnt)
         SET circ_ref->qual[circ_ref->cnt].circ_table_name = dm2_ref_data_doc->tbl_qual[der_tab_pos].
         circ_qual[der_circ_loop].circ_table_name
         SET circ_ref->qual[circ_ref->cnt].circ_id_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
         circ_qual[der_circ_loop].circ_id_col_name
         SET circ_ref->qual[circ_ref->cnt].circ_pe_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
         circ_qual[der_circ_loop].circ_pe_name_col
         FOR (der_circ_pos = 1 TO drmm_hold_exception->value_cnt)
           IF ((drmm_hold_exception->qual[der_circ_pos].table_name=dm2_ref_data_doc->tbl_qual[
           der_tab_pos].circ_qual[der_circ_loop].circ_table_name))
            SET circ_ref->qual[circ_ref->cnt].excptn_cnt = (circ_ref->qual[circ_ref->cnt].excptn_cnt
            + 1)
            SET stat = alterlist(circ_ref->qual[circ_ref->cnt].excptn_qual,circ_ref->qual[circ_ref->
             cnt].excptn_cnt)
            SET circ_ref->qual[circ_ref->cnt].excptn_qual[circ_ref->qual[circ_ref->cnt].excptn_cnt].
            value = drmm_hold_exception->qual[der_circ_pos].from_value
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   FOR (der_circ_loop = 1 TO circ_ref->cnt)
     SET der_circ_pos = locateval(der_circ_pos,1,dm2_ref_data_doc->tbl_cnt,circ_ref->qual[
      der_circ_loop].circ_table_name,dm2_ref_data_doc->tbl_qual[der_circ_pos].table_name)
     IF (der_circ_pos=0)
      SET der_temp_pos = temp_tbl_cnt
      SET der_circ_pos = fill_rs("TABLE",circ_ref->qual[der_circ_loop].circ_table_name)
      IF ((der_circ_pos=- (1)))
       CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
       RETURN(null)
      ELSEIF ((der_circ_pos=- (2)))
       SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
        drdm_max_rs_size)
       SET drmm_ddl_rollback_ind = 1
       SET der_circ_pos = temp_tbl_cnt
       SET temp_tbl_cnt = der_temp_pos
       RETURN(null)
      ELSE
       SET temp_tbl_cnt = der_temp_pos
      ENDIF
     ENDIF
     SET circ_ref->qual[der_circ_loop].circ_root_col = dm2_ref_data_doc->tbl_qual[der_circ_pos].
     root_col_name
   ENDFOR
   FOR (der_circ_loop = 1 TO circ_ref->cnt)
     SET der_pe_name_val = dm2_get_rdds_tname(circ_ref->qual[der_circ_loop].circ_table_name)
     SET der_last_pe_col = concat('select into "NL:" ',circ_ref->qual[der_circ_loop].circ_root_col,
      " from ",der_pe_name_val," d where ",
      circ_ref->qual[der_circ_loop].circ_id_col," = ",trim(cnvtstring(sbr_value,20,1)))
     IF ((circ_ref->qual[der_circ_loop].circ_pe_col > " "))
      IF (sbr_table_name IN ("PRSNL", "PERSON"))
       SET der_last_pe_col = concat(der_last_pe_col,' and evaluate_pe_name("',circ_ref->qual[
        der_circ_loop].circ_table_name,'","',circ_ref->qual[der_circ_loop].circ_id_col,
        '","',circ_ref->qual[der_circ_loop].circ_pe_col,'",d.',circ_ref->qual[der_circ_loop].
        circ_pe_col,") in ('PRSNL','PERSON')")
      ELSE
       SET der_last_pe_col = concat(der_last_pe_col,' and evaluate_pe_name("',circ_ref->qual[
        der_circ_loop].circ_table_name,'","',circ_ref->qual[der_circ_loop].circ_id_col,
        '","',circ_ref->qual[der_circ_loop].circ_pe_col,'",d.',circ_ref->qual[der_circ_loop].
        circ_pe_col,") = '",
        sbr_table_name,"'")
      ENDIF
     ENDIF
     CALL parser(der_last_pe_col,0)
     CALL parser(concat(" detail circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_cnt = circ_ref->qual[",trim(cnvtstring(der_circ_loop)),"].circ_val_cnt + 1 "),0)
     CALL parser(concat(" stat = alterlist(circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_qual, circ_ref->qual[",trim(cnvtstring(der_circ_loop)),"].circ_val_cnt)"),0)
     CALL parser(concat(" circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_qual[circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_cnt].circ_value =  d.",
       circ_ref->qual[der_circ_loop].circ_root_col," go"),1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
      RETURN(null)
     ENDIF
   ENDFOR
   IF ((global_mover_rec->reset_xcptn_ind=1))
    SET der_reset = reset_exceptions(sbr_table_name,dm2_ref_data_doc->env_target_id,sbr_value,
     circ_ref)
    IF (der_reset=0)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
     RETURN(null)
    ENDIF
   ENDIF
   UPDATE  FROM (parser(except_tab) d)
    SET d.log_type = "DELETE"
    WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.table_name=sbr_table_name
     AND d.from_value=sbr_value
     AND d.log_type != "DELETE"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET der_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[der_parent_drdm_row].dm_chg_log_exception_id = 0.0
   ENDIF
   IF ((global_mover_rec->circ_nomv_excl_cnt=0))
    SET der_log_type_str = "e.log_type != 'DELETE'"
   ELSE
    FOR (der_new_loop = 1 TO global_mover_rec->circ_nomv_excl_cnt)
      IF (der_new_loop=1)
       SET der_log_type_str = concat("e.log_type in ('",global_mover_rec->circ_nomv_qual[der_new_loop
        ].log_type,"'")
      ELSE
       SET der_log_type_str = concat(der_log_type_str,",'",global_mover_rec->circ_nomv_qual[
        der_new_loop].log_type,"'")
      ENDIF
    ENDFOR
    SET der_log_type_str = concat(der_log_type_str,")")
   ENDIF
   FOR (der_circ_loop = 1 TO circ_ref->cnt)
    FOR (der_new_loop = 1 TO circ_ref->qual[der_circ_loop].circ_val_cnt)
      IF (der_new_loop=1)
       SET der_last_pe_col = " e.from_value in ("
      ELSE
       SET der_last_pe_col = concat(der_last_pe_col,", ")
      ENDIF
      SET der_last_pe_col = concat(der_last_pe_col,trim(cnvtstring(circ_ref->qual[der_circ_loop].
         circ_val_qual[der_new_loop].circ_value,20,1)))
      IF ((der_new_loop=circ_ref->qual[der_circ_loop].circ_val_cnt))
       SET der_last_pe_col = concat(der_last_pe_col,")")
      ENDIF
    ENDFOR
    IF ((circ_ref->qual[der_circ_loop].circ_val_cnt > 0))
     IF ((circ_ref->qual[der_circ_loop].excptn_cnt > 0))
      UPDATE  FROM (parser(except_tab) e)
       SET e.log_type = "DELETE"
       WHERE (e.target_env_id=dm2_ref_data_doc->env_target_id)
        AND (e.table_name=circ_ref->qual[der_circ_loop].circ_table_name)
        AND (e.column_name=circ_ref->qual[der_circ_loop].circ_root_col)
        AND parser(der_log_type_str)
        AND parser(der_last_pe_col)
        AND  NOT (expand(der_new_loop,1,circ_ref->qual[der_circ_loop].excptn_cnt,e.from_value,
        circ_ref->qual[der_circ_loop].excptn_qual[der_new_loop].value))
       WITH nocounter
      ;end update
     ELSE
      UPDATE  FROM (parser(except_tab) e)
       SET e.log_type = "DELETE"
       WHERE (e.target_env_id=dm2_ref_data_doc->env_target_id)
        AND (e.column_name=circ_ref->qual[der_circ_loop].circ_root_col)
        AND parser(der_log_type_str)
        AND (e.table_name=circ_ref->qual[der_circ_loop].circ_table_name)
        AND parser(der_last_pe_col)
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
   ENDFOR
   SET der_start = 1
   SET der_idx = 1
   WHILE (der_idx > 0)
    SET der_idx = locateval(der_loop,der_start,size(missing_xlats->qual,5),sbr_value,missing_xlats->
     qual[der_loop].missing_value)
    IF (der_idx > 0)
     IF ((missing_xlats->qual[der_idx].table_name=sbr_table_name)
      AND (missing_xlats->qual[der_idx].processed_ind=0)
      AND (drdm_chg->log[drdm_log_loop].single_pass_log_id > 0))
      IF (size(missing_xlats->qual,5)=der_idx)
       SET stat = alterlist(missing_xlats->qual,(der_idx - 1))
      ELSE
       FOR (der_pos = (der_idx+ 1) TO size(missing_xlats->qual,5))
         SET missing_xlats->qual[(der_pos - 1)].table_name = missing_xlats->qual[der_pos].table_name
         SET missing_xlats->qual[(der_pos - 1)].column_name = missing_xlats->qual[der_pos].
         column_name
         SET missing_xlats->qual[(der_pos - 1)].missing_value = missing_xlats->qual[der_pos].
         missing_value
       ENDFOR
       SET stat = alterlist(missing_xlats->qual,(size(missing_xlats->qual,5) - 1))
      ENDIF
      SET der_idx = 0
     ELSE
      SET der_start = (der_idx+ 1)
     ENDIF
    ENDIF
   ENDWHILE
   SET der_start = 1
   SET der_idx = 1
   WHILE (der_idx > 0)
    SET der_idx = locateval(der_loop,der_start,drmm_hold_exception->value_cnt,sbr_value,
     drmm_hold_exception->qual[der_loop].from_value,
     sbr_table_name,drmm_hold_exception->qual[der_loop].table_name)
    IF (der_idx > 0)
     IF ((drmm_hold_exception->value_cnt=der_idx))
      SET stat = alterlist(drmm_hold_exception->qual,(der_idx - 1))
      SET drmm_hold_exception->value_cnt = (drmm_hold_exception->value_cnt - 1)
     ELSE
      SET drmm_hold_exception->qual[der_idx].dcl_excep_id = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].dcl_excep_id
      SET drmm_hold_exception->qual[der_idx].table_name = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].table_name
      SET drmm_hold_exception->qual[der_idx].column_name = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].column_name
      SET drmm_hold_exception->qual[der_idx].from_value = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].from_value
      SET drmm_hold_exception->qual[der_idx].log_type = drmm_hold_exception->qual[drmm_hold_exception
      ->value_cnt].log_type
      SET stat = alterlist(drmm_hold_exception->qual,(size(drmm_hold_exception->qual,5) - 1))
      SET drmm_hold_exception->value_cnt = (drmm_hold_exception->value_cnt - 1)
     ENDIF
     SET der_idx = 0
     SET der_start = (der_idx+ 1)
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dm2_get_rdds_tname(sbr_tname)
   DECLARE return_tname = vc
   IF ((dm2_rdds_rec->mode="OS"))
    SET return_tname = concat(trim(substring(1,28,sbr_tname)),"$F")
   ELSEIF ((dm2_rdds_rec->main_process="EXTRACTOR")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = sbr_tname
   ELSEIF ((dm2_rdds_rec->main_process="MOVER")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = concat(dm2_ref_data_doc->pre_link_name,sbr_tname,dm2_ref_data_doc->
     post_link_name)
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "The main_process and/or mode were invalid"
   ENDIF
   RETURN(return_tname)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_alias(sbr_tbl_suffix)
   DECLARE sbr_rgta_rtn = vc
   SET sbr_rgta_rtn = build("t",sbr_tbl_suffix)
   RETURN(sbr_rgta_rtn)
 END ;Subroutine
 SUBROUTINE trigger_proc_call(tpc_table_name,tpc_pk_where_in,tpc_context,tpc_col_name,tpc_value)
   DECLARE tpc_pk_where_vc = vc
   DECLARE tpc_pktbl_cnt = i4
   DECLARE tpc_tbl_loop = i4
   DECLARE tpc_suffix = vc
   DECLARE tpc_pk_proc_name = vc
   DECLARE tpc_proc_name = vc
   DECLARE tpc_src_tab_name = vc
   DECLARE tpc_uo_tname = vc
   DECLARE tpc_pkw_tab_name = vc
   DECLARE tpc_parser_cnt = i4
   DECLARE tpc_row_cnt = i4
   DECLARE tpc_row_loop = i4
   DECLARE tpc_validate_ret = i2
   DECLARE tpc_all_filtered = i2
   DECLARE tpc_last_pk_where = vc
   DECLARE tpc_parent_drdm_row = i2 WITH protect, noconstant(0)
   FREE RECORD tpc_pkw_rs
   RECORD tpc_pkw_rs(
     1 qual[*]
       2 pkw = vc
       2 invalid_ind = i2
   )
   SET tpc_pk_where_vc = tpc_pk_where_in
   SET tpc_proc_name = ""
   SET tpc_pktbl_cnt = 0
   SET tpc_pktbl_cnt = locateval(tpc_tbl_loop,1,size(pk_where_parm->qual,5),tpc_table_name,
    pk_where_parm->qual[tpc_tbl_loop].table_name)
   IF (tpc_pktbl_cnt=0)
    SET tpc_pktbl_cnt = (size(pk_where_parm->qual,5)+ 1)
    SET stat = alterlist(pk_where_parm->qual,tpc_pktbl_cnt)
    SET pk_where_parm->qual[tpc_pktbl_cnt].table_name = tpc_table_name
    SET tpc_tbl_loop = 0
    SET tpc_pkw_tab_name = "DM_REFCHG_PKW_PARM"
    SELECT INTO "NL:"
     FROM (parser(tpc_pkw_tab_name) d)
     WHERE d.table_name=tpc_table_name
     ORDER BY parm_nbr
     DETAIL
      tpc_tbl_loop = (tpc_tbl_loop+ 1), stat = alterlist(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,
       tpc_tbl_loop), pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name = d
      .column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5)=0)
    CALL disp_msg(concat("No entries in DM_REFCHG_PKW_PARM for table: ",tpc_table_name),dm_err->
     logfile,1)
    SET drdm_error_out_ind = 1
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   SET temp_tbl_cnt = locateval(tpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpc_table_name,
    dm2_ref_data_doc->tbl_qual[tpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",tpc_table_name)
    IF ((temp_tbl_cnt=- (1)))
     CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1))
    ENDIF
    IF ((temp_tbl_cnt=- (2)))
     RETURN(- (2))
    ENDIF
   ENDIF
   SET tpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   IF (tpc_pk_where_vc="")
    SET tpc_pk_where_vc = concat("WHERE t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,".",
     tpc_col_name," = tpc_value")
   ENDIF
   SET tpc_pk_proc_name = concat("REFCHG_PK_WHERE_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SET tpc_uo_tname = "USER_OBJECTS"
   SELECT INTO "NL:"
    FROM (parser(tpc_uo_tname) u)
    WHERE u.object_name=patstring(tpc_pk_proc_name)
    DETAIL
     tpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   IF (tpc_proc_name="")
    SET dm_err->emsg = concat("A trigger procedure is not built: ",tpc_pk_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   CALL parser(concat("declare ",tpc_proc_name,"() = c2000 go"),1)
   SET tpc_src_tab_name = dm2_get_rdds_tname(tpc_table_name)
   SET tpc_row_cnt = 0
   SET drdm_parser->statement[1].frag = concat('select into "nl:" pkw = ',tpc_proc_name,'("INS/UPD"')
   SET tpc_parser_cnt = 2
   FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     SET drdm_parser->statement[tpc_parser_cnt].frag = " , "
     SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
     SET drdm_parser->statement[tpc_parser_cnt].frag = concat(tpc_suffix,".",pk_where_parm->qual[
      tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name)
     SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   ENDFOR
   SET drdm_parser->statement[tpc_parser_cnt].frag = ")"
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag = concat("from ",tpc_src_tab_name," ",tpc_suffix)
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag = tpc_pk_where_vc
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag = concat("detail tpc_row_cnt = tpc_row_cnt + 1 ",
    " stat = alterlist(tpc_pkw_rs->qual,tpc_row_cnt)")
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag =
   "tpc_pkw_rs->qual[tpc_row_cnt].pkw = pkw with nocounter go"
   CALL parse_statements(tpc_parser_cnt)
   IF (nodelete_ind=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   IF (tpc_row_cnt=0)
    RETURN(- (3))
   ENDIF
   FOR (tpc_row_loop = 1 TO tpc_row_cnt)
     IF ((tpc_pkw_rs->qual[tpc_row_loop].pkw != tpc_last_pk_where))
      IF (drdm_debug_row_ind=1)
       CALL echo("***PK_WHERE generated by target triggers:***")
       CALL echo(tpc_pkw_rs->qual[tpc_row_loop].pkw)
      ENDIF
      SET tpc_validate_ret = drcm_validate(tpc_table_name,tpc_pkw_rs->qual[tpc_row_loop].pkw,
       temp_tbl_cnt)
      IF (tpc_validate_ret < 0)
       IF ((tpc_validate_ret != - (4)))
        SET dm_err->emsg = concat("The PK_WHERE created by target procedure failed validation: ",
         tpc_pkw_rs->qual[tpc_row_loop].pkw)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET drdm_error_out_ind = 1
        SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1))
       ELSE
        SET tpc_pkw_rs->qual[tpc_row_loop].invalid_ind = 1
        SET tpc_all_filtered = 1
       ENDIF
      ENDIF
      IF ((tpc_pkw_rs->qual[tpc_row_loop].invalid_ind=0))
       SET tpc_all_filtered = 0
       IF (call_ins_log(tpc_table_name,tpc_pkw_rs->qual[tpc_row_loop].pkw,"REFCHG",0,reqinfo->updt_id,
        reqinfo->updt_task,reqinfo->updt_applctx,tpc_context,dm2_ref_data_doc->env_target_id,0.0,
        dm2_ref_data_doc->post_link_name)="F")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1))
       ENDIF
      ENDIF
      SET tpc_last_pk_where = tpc_pkw_rs->qual[tpc_row_loop].pkw
     ENDIF
   ENDFOR
   IF (tpc_all_filtered=1)
    RETURN(- (4))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE filter_proc_call(fpc_table_name,fpc_pk_where,fpc_updt_applctx)
   DECLARE fpc_loop = i4
   DECLARE fpc_filter_pos = i4
   DECLARE fpc_col_cnt = i4
   DECLARE fpc_tbl_loop = i4
   DECLARE fpc_col_loop = i4
   DECLARE fpc_col_pos = i4
   DECLARE fpc_error_ind = i2
   DECLARE fpc_suffix = vc
   DECLARE fpc_row_cnt = i4
   DECLARE fpc_row_loop = i4
   DECLARE fpc_col_nullind = i2
   DECLARE fpc_proc_name = vc
   DECLARE fpc_filter_proc_name = vc
   DECLARE fpc_src_tab_name = vc
   DECLARE fpc_f8_var = f8
   DECLARE fpc_i4_var = i4
   DECLARE fpc_vc_var = vc
   DECLARE fpc_return_var = i2
   DECLARE fpc_uo_tname = vc
   DECLARE fpc_filter_tab_name = vc
   DECLARE fpc_cur_state_flag = i4 WITH protect, noconstant(0)
   DECLARE fpc_cs_pos = i4 WITH protect, noconstant(0)
   DECLARE fpc_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE fpc_pkw_vc = vc WITH protect, noconstant("")
   DECLARE fpc_temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE fpc_par_pos = i4 WITH protect, noconstant(0)
   DECLARE fpc_temp_pkw = vc WITH protect, noconstant("")
   DECLARE fpc_qual = i4 WITH protect, noconstant(0)
   DECLARE fpc_test_tab_name = vc WITH protect, noconstant(" ")
   DECLARE fpc_parent_tab_name = vc WITH protect, noconstant(" ")
   SET fpc_filter_pos = locateval(fpc_loop,1,size(filter_parm->qual,5),fpc_table_name,filter_parm->
    qual[fpc_loop].table_name)
   IF (fpc_filter_pos=0)
    SET fpc_filter_pos = (size(filter_parm->qual,5)+ 1)
    SET fpc_col_cnt = 0
    SET fpc_filter_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_PARM")
    SET fpc_test_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_TEST")
    SET fpc_parent_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER")
    SELECT INTO "NL:"
     FROM (parser(fpc_filter_tab_name) d)
     WHERE d.table_name=fpc_table_name
      AND d.active_ind=1
      AND  EXISTS (
     (SELECT
      "x"
      FROM (parser(fpc_test_tab_name) t)
      WHERE t.table_name=d.table_name
       AND t.active_ind=1))
      AND  EXISTS (
     (SELECT
      "x"
      FROM (parser(fpc_parent_tab_name) f)
      WHERE f.table_name=d.table_name
       AND f.active_ind=1))
     ORDER BY d.parm_nbr
     HEAD REPORT
      stat = alterlist(filter_parm->qual,fpc_filter_pos), filter_parm->qual[fpc_filter_pos].
      table_name = fpc_table_name
     DETAIL
      fpc_col_cnt = (fpc_col_cnt+ 1), stat = alterlist(filter_parm->qual[fpc_filter_pos].col_qual,
       fpc_col_cnt), filter_parm->qual[fpc_filter_pos].col_qual[fpc_col_cnt].col_name = d.column_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
    dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",fpc_table_name)
    IF ((temp_tbl_cnt=- (1)))
     CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((temp_tbl_cnt=- (2)))
     SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
      dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
    ENDIF
   ENDIF
   SET fpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SET fpc_proc_name = ""
   SET fpc_filter_proc_name = concat("REFCHG_FILTER_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SELECT INTO "NL:"
    FROM (parser(fpc_uo_tname) u)
    WHERE u.object_name=patstring(fpc_filter_proc_name)
    DETAIL
     fpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   IF (fpc_proc_name="")
    SET dm_err->emsg = concat("A filter procedure is not built: ",fpc_filter_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ENDIF
   SET fpc_pkw_vc = fpc_pk_where
   FREE RECORD fpc_cs_rows
   CALL parser("record fpc_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," = ",
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",0)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   SET fpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   SET fpc_src_tab_name = dm2_get_rdds_tname(fpc_table_name)
   SET fpc_cur_state_flag = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].cur_state_flag
   IF (fpc_cur_state_flag > 0
    AND fpc_updt_applctx != 4310001.0)
    SET fpc_cs_pos = fill_cur_state_rs(fpc_table_name)
    IF (fpc_cs_pos=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("ERROR: Couldn't not gather current state information for table ",
      fpc_table_name,".")
     SET fpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[fpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
    IF (trim(cur_state_tabs->qual[fpc_cs_pos].parent_tab_col) > " ")
     FOR (fpc_loop = 1 TO cur_state_tabs->qual[fpc_cs_pos].parent_cnt)
       IF (findstring(cur_state_tabs->qual[fpc_cs_pos].parent_qual[fpc_loop].parent_table,fpc_pkw_vc,
        1,1) > 0)
        RETURN(1)
       ENDIF
     ENDFOR
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   SET fpc_row_cnt = 0
   CALL parser("select distinct into 'NL:' ",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     IF (fpc_tbl_loop > 1)
      CALL parser(" , ",0)
     ENDIF
     CALL parser(concat("var",cnvtstring(fpc_tbl_loop)," = nullind(",fpc_suffix,".",
       filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,")"),0)
     CALL parser(concat(",",fpc_suffix,".",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].
       col_name),0)
   ENDFOR
   CALL parser(concat("from ",fpc_src_tab_name," ",fpc_suffix," ",
     fpc_pkw_vc),0)
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].filter_string != ""))
    SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].filter_string = replace(dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].filter_string,"<MERGE LINK>",dm2_ref_data_doc->post_link_name,0)
    CALL parser(concat(" and ",replace(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].filter_string,
       "<SUFFIX>",fpc_suffix,0)),0)
   ENDIF
   CALL parser(concat(
     " detail  fpc_row_cnt = fpc_row_cnt + 1 stat = alterlist(fpc_cs_rows->qual, fpc_row_cnt) "),0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    CALL parser(concat(" fpc_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].col_qual[
      fpc_tbl_loop].col_name," = ",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name),0)
    CALL parser(concat(" fpc_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].col_qual[
      fpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(fpc_tbl_loop)),0)
   ENDFOR
   CALL parser("with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 0
   ENDIF
   IF (fpc_row_cnt=0)
    RETURN(1)
   ENDIF
   IF (fpc_proc_name > " ")
    SET fpc_proc_name = dm2_get_rdds_tname(fpc_proc_name)
    CALL parser(concat(" declare ",fpc_proc_name,"() = i2 go"),1)
    FOR (fpc_row_loop = 1 TO fpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' ret_val = ",fpc_proc_name,
       "('UPD'")
      SET drdm_parser_cnt = 2
      FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
        CALL parser(concat("set fpc_col_nullind = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->
          qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (fpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = ", NULL, NULL "
        ELSE
         SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set fpc_f8_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          IF (fpc_f8_var=round(fpc_f8_var,0))
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",trim(cnvtstring(fpc_f8_var,
              20,2))," , ",trim(cnvtstring(fpc_f8_var,20,2)))
          ELSE
           SET drdm_parser->statement[drdm_parser_cnt].frag = build(",",fpc_f8_var,",",fpc_f8_var)
          ENDIF
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set fpc_f8_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ,cnvtdatetime(",trim(cnvtstring
            (fpc_f8_var,20)),".0),cnvtdatetime(",trim(cnvtstring(fpc_f8_var,20)),".0)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set fpc_i4_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_i4_var)," , ",
           cnvtstring(fpc_i4_var))
         ELSE
          CALL parser(concat("set fpc_vc_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          IF (fpc_vc_var=char(0))
           SET drdm_parser->statement[drdm_parser_cnt].frag = ",char(0) , char(0)"
          ELSE
           SET fpc_vc_var = replace_apostrophe(fpc_vc_var)
           SET fpc_vc_var = concat("'",fpc_vc_var,"'")
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",fpc_vc_var," , ",fpc_vc_var)
          ENDIF
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag =
      ") from dual detail fpc_return_var = ret_val with nocounter go"
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET fpc_error_ind = 1
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
      IF (fpc_return_var=0)
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(fpc_return_var)
 END ;Subroutine
 SUBROUTINE replace_carrot_symbol(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   SET rcs_temp_val = replace(rcs_string,"'",'"',0)
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("^",rcs_temp_val,1,0)
   IF (rcs_pos=0)
    SET rcs_return = concat("'",rcs_temp_val,"'")
   ELSE
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(94)"
       ELSE
        SET rcs_return = concat("'",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),"'||chr(94)")
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_temp_val),"'||chr(94)")
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_temp_val))
     SET rcs_pos = findstring("^",rcs_temp_val,1,1)
     SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos),
       rcs_temp_val),"'")
    ENDIF
   ENDIF
   RETURN(rcs_return)
 END ;Subroutine
 SUBROUTINE replace_apostrophe(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_concat = vc
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("'",rcs_string,1,0)
   IF (rcs_pos != 0)
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(39)"
       ELSE
        SET rcs_return = concat('"',substring(rcs_start_idx,(rcs_pos - 1),rcs_string),'"||chr(39)')
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,'||"',substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_string),'"||chr(39)')
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("'",rcs_string,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_string))
     SET rcs_pos = findstring('"',rcs_string,1,1)
     SET rcs_return = concat(rcs_return,'||"',substring(rcs_start_idx,(size(rcs_string) - rcs_pos),
       rcs_string),'"')
    ENDIF
   ELSE
    SET rcs_return = rcs_string
   ENDIF
   RETURN(rcs_return)
 END ;Subroutine
 SUBROUTINE log_md_scommit(lms_tab_name,lms_tbl_cnt,lms_log_type,lms_chg_cnt)
   DECLARE lms_top_tbl = i4 WITH noconstant(0)
   DECLARE lms_con = i4 WITH noconstant(1)
   DECLARE lms_t_alias = vc
   DECLARE lms_pk_col = vc
   DECLARE lms_src_parent_table = vc
   DECLARE lms_p_size = i4 WITH noconstant(0)
   DECLARE lms_parent_table = vc
   DECLARE lms_parent_id_col = vc
   DECLARE lms_parent_tab_col = vc
   DECLARE lms_parent_value = f8
   DECLARE lms_pk_where = vc
   DECLARE lms_parent_loc = i4
   DECLARE lms_parent_loop = i4
   DECLARE lms_parent_cnt = i4
   DECLARE lms_temp_cnt = i4
   DECLARE lms_p_tab_name = vc
   DECLARE lms_p_t_suffix = vc
   DECLARE lms_child_idx = i4 WITH noconstant(0)
   DECLARE lms_child_idx2 = i4 WITH noconstant(0)
   DECLARE lms_parent_table_pp = vc
   DECLARE lms_pk_col_value = f8
   DECLARE lms_child_cnt = i4
   DECLARE lms_log_child = vc
   DECLARE lms_log_type_idx = i4 WITH protect, noconstant(0)
   DECLARE ll_child_return = i4
   DECLARE lms_other_col_val = f8
   DECLARE lms_source_tab_name = vc
   FREE RECORD lms_parent_vals
   RECORD lms_parent_vals(
     1 qual[*]
       2 value = f8
   )
   FREE RECORD lms_pk
   RECORD lms_pk(
     1 list[*]
       2 table_name = vc
       2 pk_where = vc
   )
   FREE RECORD lms_gc_pk
   RECORD lms_gc_pk(
     1 list[*]
       2 table_name = vc
       2 pk_where = vc
   )
   FREE RECORD lms_fv
   RECORD lms_fv(
     1 fv_cnt = i4
     1 list[*]
       2 table_name = vc
       2 from_value = f8
       2 column_name = vc
   )
   CALL echo("log_md_scommit")
   ROLLBACK
   CALL fill_hold_excep_rs(null)
   SET lms_pk_where = drdm_chg->log[lms_chg_cnt].pk_where
   IF (lms_log_type="ORPHAN")
    SET lms_log_child = "CHLDOR"
   ELSE
    SET lms_log_child = lms_log_type
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag=0))
    SET dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag = 1
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag=0))
    SET dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag = 1
   ENDIF
   FOR (lms_lp_col = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[lms_tbl_cnt]
     .col_qual[lms_lp_col].root_entity_name)
      AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].column_name=dm2_ref_data_doc
     ->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].root_entity_attr))
      SET lms_pk_col = dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].column_name
      SET lms_top_tbl = (lms_top_tbl+ 1)
     ENDIF
   ENDFOR
   IF (lms_log_type="NOMV1C")
    SET ll_child_return = drcm_load_bulk_dcle(lms_tab_name,lms_tbl_cnt,lms_log_type,lms_chg_cnt)
    RETURN(ll_child_return)
   ENDIF
   IF (lms_top_tbl=1
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].merge_delete_ind=1))
    CALL load_merge_del(lms_tbl_cnt,lms_log_child,lms_chg_cnt)
    IF ((dm_err->err_ind=1))
     RETURN(- (1))
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].version_ind=1)
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].version_type IN ("ALG5", "ALG6", "ALG7")))
    CALL load_grouper(lms_tbl_cnt,lms_log_child,lms_chg_cnt)
    IF ((dm_err->err_ind=1))
     RETURN(- (1))
    ENDIF
   ENDIF
   CALL echo(build("child flag =",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag))
   CALL echo(build("parent flag =",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag))
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag=1)
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag=1)
    AND size(trim(lms_pk_col)) > 0
    AND  NOT ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].version_type IN ("ALG5", "ALG6", "ALG7")))
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].merge_delete_ind=0))
    CALL parser('select into "NL:"',0)
    CALL parser(concat(" from ",dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name
       )," t",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].suffix),0)
    CALL parser(lms_pk_where,0)
    CALL parser(concat(" detail lms_pk_col_value = t",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].suffix,
      ".",lms_pk_col," with nocounter go"),1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
    ELSE
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name,lms_log_child,
      lms_pk_col,lms_pk_col_value)
     COMMIT
     IF (locateval(lms_log_type_idx,1,global_mover_rec->circ_nomv_excl_cnt,lms_log_child,
      global_mover_rec->circ_nomv_qual[lms_log_type_idx].log_type)=0)
      CALL drcm_block_ptam_circ(dm2_ref_data_doc,lms_tbl_cnt,lms_pk_col,lms_pk_col_value)
      IF ((dm_err->err_ind=1))
       RETURN(- (1))
      ENDIF
     ENDIF
    ENDIF
    SET lms_source_tab_name = dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name)
    IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name="DCP_FORMS_REF"))
     SELECT INTO "NL:"
      FROM (parser(lms_source_tab_name) d)
      WHERE d.dcp_form_instance_id=lms_pk_col_value
      DETAIL
       lms_other_col_val = d.dcp_forms_ref_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name,lms_log_child,
      "DCP_FORMS_REF_ID",lms_other_col_val)
     COMMIT
     SET stat = initrec(drmm_hold_exception)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name="DCP_SECTION_REF"))
     SELECT INTO "NL:"
      FROM (parser(lms_source_tab_name) d)
      WHERE d.dcp_section_instance_id=lms_pk_col_value
      DETAIL
       lms_other_col_val = d.dcp_section_ref_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name,lms_log_child,
      "DCP_SECTION_REF_ID",lms_other_col_val)
     COMMIT
     SET stat = initrec(drmm_hold_exception)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE load_merge_del(lmd_cnt,lmd_log_type,lmd_chg_cnt)
   DECLARE lmd_alias = vc
   DECLARE lmd_loop = i4
   DECLARE lms_src_fv = vc
   DECLARE lmd_temp_cnt = i4
   DECLARE lmd_qual_cnt = i4
   DECLARE lms_d_cnt = i4 WITH noconstant(0)
   DECLARE lmd_log_type_idx = i4 WITH protect, noconstant(0)
   SET lms_src_fv = dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lmd_cnt].table_name)
   SET lmd_alias = concat(" t",dm2_ref_data_doc->tbl_qual[lmd_cnt].suffix)
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 trailing_space_ind = i2")
   CALL parser(" 1 qual[*]",0)
   FOR (lmd_loop = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].merge_delete_ind=1))
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,
        " = ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type),0)
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,
        "_NULLIND = i2 "),0)
      IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type IN ("VC", "C*")))
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].
         column_name,"_LEN = i4 "),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET lmd_temp_cnt = 0
   CALL parser("select into 'nl:'",0)
   FOR (lmd_loop = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].merge_delete_ind=1))
      IF (lmd_temp_cnt > 0)
       CALL parser(" , ",0)
      ENDIF
      SET lmd_temp_cnt = (lmd_temp_cnt+ 1)
      CALL parser(concat("var",cnvtstring(lmd_loop)," = nullind(",lmd_alias,".",
        dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,")"),0)
      IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type IN ("VC", "C*")))
       CALL parser(concat(", ts",cnvtstring(lmd_loop)," = length(",lmd_alias,".",
         dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,")"),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(concat(" from  ",lms_src_fv," ",lmd_alias),0)
   CALL parser(drdm_chg->log[lmd_chg_cnt].pk_where,0)
   CALL parser("head report cust_cs_rows->trailing_space_ind = 1",0)
   CALL parser(
    " detail lmd_qual_cnt = lmd_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, lmd_qual_cnt) ",0)
   FOR (lmd_loop = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].merge_delete_ind=1))
      CALL parser(concat("cust_cs_rows->qual[lmd_qual_cnt].",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].
        col_qual[lmd_loop].column_name," = ",lmd_alias,".",
        dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name),0)
      CALL parser(concat("cust_cs_rows->qual[lmd_qual_cnt].",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].
        col_qual[lmd_loop].column_name,"_NULLIND = var",trim(cnvtstring(lmd_loop))),0)
      IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type IN ("VC", "C*")))
       CALL parser(concat("cust_cs_rows->qual[lmd_qual_cnt].",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt]
         .col_qual[lmd_loop].column_name,"_LEN = ts",trim(cnvtstring(lmd_loop))),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(" with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET lms_pk_where = drdm_create_pk_where(lmd_qual_cnt,lms_tbl_cnt,"MD")
   IF (lms_pk_where="")
    CALL disp_msg("There was an error creating the PK_WHERE string",dm_err->logfile,0)
    RETURN(- (1))
   ENDIF
   CALL parser("select into 'nl:'",0)
   CALL parser(concat("from ",lms_src_fv,lmd_alias),0)
   CALL parser(concat(lms_pk_where," detail"),0)
   FOR (lms_lp_cnt = 1 TO dm2_ref_data_doc->tbl_qual[lmd_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].root_entity_attr=dm2_ref_data_doc
     ->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].column_name)
      AND (dm2_ref_data_doc->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].root_entity_name=dm2_ref_data_doc
     ->tbl_qual[lmd_cnt].table_name))
      CALL parser(" lms_d_cnt = lms_d_cnt +1",0)
      CALL parser("stat = alterlist(lms_fv->list, lms_d_cnt)",0)
      CALL parser(concat("lms_fv->list[lms_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lmd_cnt]
        .table_name,"'"),0)
      CALL parser(concat("lms_fv->list[lms_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lmd_cnt
        ].col_qual[lms_lp_cnt].column_name,"'"),0)
      CALL parser(build("lms_fv->list[lms_d_cnt].from_value = ",lmd_alias,".",dm2_ref_data_doc->
        tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].column_name),0)
     ENDIF
   ENDFOR
   CALL parser("with nocounter,notrim go",1)
   SET lms_fv->fv_cnt = lms_d_cnt
   CALL echorecord(lms_fv)
   FOR (lms_lp_pp = 1 TO lms_d_cnt)
     CALL orphan_child_tab(lms_fv->list[lms_lp_pp].table_name,lmd_log_type,lms_fv->list[lms_lp_pp].
      column_name,lms_fv->list[lms_lp_pp].from_value)
     COMMIT
     IF (locateval(lmd_log_type_idx,1,global_mover_rec->circ_nomv_excl_cnt,lmd_log_type,
      global_mover_rec->circ_nomv_qual[lmd_log_type_idx].log_type)=0)
      CALL drcm_block_ptam_circ(dm2_ref_data_doc,lmd_cnt,lms_fv->list[lms_lp_pp].column_name,lms_fv->
       list[lms_lp_pp].from_value)
      IF ((dm_err->err_ind=1))
       RETURN(- (1))
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE drcm_load_bulk_dcle(dlbd_tab_name,dlbd_tbl_cnt,dlbd_log_type,dlbd_chg_cnt)
   DECLARE dlbd_pk_col = vc WITH protect, noconstant(" ")
   DECLARE dlbd_suffix = vc WITH protect, noconstant(" ")
   DECLARE dlbd_pk_where = vc WITH protect, noconstant(" ")
   SET dlbd_pk_where = drdm_chg->log[dlbd_chg_cnt].pk_where
   SET dlbd_pk_col = dm2_ref_data_doc->tbl_qual[dlbd_tbl_cnt].root_col_name
   SET dlbd_suffix = concat("t",dm2_ref_data_doc->tbl_qual[dlbd_tbl_cnt].suffix)
   SET dm_err->eproc = "Bulk updating DM_CHG_LOG_EXCEPTION rows"
   CALL parser(concat("update into dm_chg_log_exception",dm2_ref_data_doc->post_link_name," d"),0)
   CALL parser(" set log_type = dlbd_log_type,",0)
   CALL parser(" d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id=reqinfo->updt_id,",0)
   CALL parser(
    " d.updt_cnt = d.updt_cnt + 1, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx",
    0)
   CALL parser(" where d.table_name = dlbd_tab_name and d.column_name = dlbd_pk_col",0)
   CALL parser("    and d.target_env_id = dm2_ref_data_doc->env_target_id",0)
   CALL parser(concat(" and exists (select 'x' from ",dlbd_tab_name,dm2_ref_data_doc->post_link_name,
     " ",dlbd_suffix),0)
   CALL parser(dlbd_pk_where,0)
   CALL parser(concat(" and d.from_value = ",dlbd_suffix,".",dlbd_pk_col,")"),0)
   CALL parser(" with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Bulk inserting DM_CHG_LOG_EXCEPTION rows"
   CALL parser(concat("insert into dm_chg_log_exception",dm2_ref_data_doc->post_link_name," d"),0)
   CALL parser("( d.log_type, d.updt_dt_tm, d.updt_id, d.updt_task, d.updt_applctx, d.table_name, ",0
    )
   CALL parser(" d.column_name, d.from_value, d.target_env_id, d.dm_chg_log_exception_id)",0)
   CALL parser(" (select dlbd_log_type, cnvtdatetime(curdate,curtime3), reqinfo->updt_id, ",0)
   CALL parser(concat(" reqinfo->updt_task, reqinfo->updt_applctx, dlbd_tab_name, dlbd_pk_col,",
     dlbd_suffix,".",dlbd_pk_col,","),0)
   CALL parser(" dm2_ref_data_doc->env_target_id, seq(rdds_source_clinical_seq,nextval) ",0)
   CALL parser(concat(" from ",dlbd_tab_name,dm2_ref_data_doc->post_link_name," ",dlbd_suffix),0)
   CALL parser(dlbd_pk_where,0)
   CALL parser(concat(" and not exists (select 'x' from dm_chg_log_exception",dm2_ref_data_doc->
     post_link_name," d2"),0)
   CALL parser(" where d2.table_name = dlbd_tab_name and d2.column_name = dlbd_pk_col",0)
   CALL parser("    and d2.target_env_id = dm2_ref_data_doc->env_target_id",0)
   CALL parser(concat(" and ",dlbd_suffix,".",dlbd_pk_col," = d2.from_value)"),0)
   CALL parser(") with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE orphan_child_tab(sbr_table_name,sbr_log_type,sbr_col_name,sbr_from_value)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
   DECLARE oct_col_name = vc
   DECLARE oct_m_flag = i2 WITH noconstant(1)
   DECLARE oct_parent_drdm_row = i2 WITH protect, noconstant(0)
   CALL echo("Orphan_child_tab")
   IF (sbr_col_name=""
    AND sbr_from_value=0.0)
    SET oct_m_flag = 0
   ENDIF
   IF (oct_m_flag=0)
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name != sbr_table_name))
     SET oct_tab_cnt = locateval(oct_tab_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
      dm2_ref_data_doc->tbl_qual[oct_tab_loop].table_name)
     IF (oct_tab_cnt=0)
      SET dm_err->emsg = "The table name could not be found in the meta-data record structure"
      SET nodelete_ind = 1
     ENDIF
    ELSE
     SET oct_tab_cnt = temp_tbl_cnt
    ENDIF
    SET oct_col_cnt = 0
    FOR (oct_tab_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual,5))
      IF ((dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].root_entity_name=
      sbr_table_name))
       SET oct_col_cnt = oct_tab_loop
      ENDIF
    ENDFOR
    IF (oct_col_cnt=0)
     RETURN(0)
    ENDIF
    CALL parser(concat("set oct_pk_value = RS_",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].suffix,
      "->from_values.",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name,
      " go "),1)
    SET oct_col_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name
   ELSE
    SET oct_pk_value = sbr_from_value
    SET oct_col_name = sbr_col_name
   ENDIF
   SET drwdr_reply->dcle_id = 0
   SET drwdr_reply->error_ind = 0
   SET drwdr_request->table_name = sbr_table_name
   SET drwdr_request->log_type = sbr_log_type
   SET drwdr_request->col_name = oct_col_name
   SET drwdr_request->from_value = oct_pk_value
   SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
   SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
   SET drwdr_request->dclei_ind = drmm_excep_flag
   EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
    "DRWDR_REPLY")
   IF ((drwdr_reply->error_ind=1))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF ((drwdr_reply->dcle_id > 0))
    SET oct_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    IF ((drdm_chg->log[oct_parent_drdm_row].dm_chg_log_exception_id=0))
     SET drdm_chg->log[oct_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drcm_validate(sbr_dv_t_name,sbr_dv_pk_where,sbr_dv_table_cnt)
   DECLARE dv_col_loop = i4
   DECLARE dv_dummy_cnt = i4
   DECLARE dv_md_col_cnt = i4
   DECLARE dv_pkw_col_cnt = i4
   DECLARE dv_pk_col_cnt = i4
   DECLARE dv_and_cnt = i4
   DECLARE dv_and_pos = i4
   DECLARE dv_end_ind = i2
   DECLARE dv_fix_ind = i2
   DECLARE dv_qual_cnt = i4
   DECLARE dv_pk_where_stmt = vc
   DECLARE dv_type = vc
   DECLARE dv_ret_cnt = i4
   DECLARE dv_col_value = vc
   DECLARE dv_delim_start = i4
   DECLARE dv_delim_stop = i4
   DECLARE dv_delim_pos1 = i4
   DECLARE dv_delim_pos2 = i4
   DECLARE dv_delim_pos3 = i4
   DECLARE dv_delim_val = vc
   DECLARE dv_filter_ret = i2
   DECLARE dv_sc_ind = i2
   DECLARE dv_str1_pos = i4
   DECLARE dv_str2_pos = i4
   DECLARE dv_str3_pos = i4
   DECLARE dv_str4_pos = i4
   DECLARE dv_uc_pk_where = vc
   DECLARE dv_src_tab_name = vc
   DECLARE ver_tab_ind = i2
   DECLARE dv_t_suff_str = vc
   SET dv_t_suff_str = concat(" AND t",dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].suffix)
   SET dv_qual_cnt = 0
   SET dv_filter_ret = filter_proc_call(sbr_dv_t_name,sbr_dv_pk_where)
   IF (dv_filter_ret=0)
    RETURN(- (4))
   ENDIF
   IF (sbr_dv_t_name="SEG_GRP_SEQ_R")
    SET dv_uc_pk_where = cnvtupper(sbr_dv_pk_where)
    SET dv_str1_pos = findstring("(SELECT",dv_uc_pk_where,1)
    SET dv_str2_pos = findstring("SEGMENT_REFERENCE",dv_uc_pk_where,dv_str1_pos)
    SET dv_str3_pos = findstring("(SELECT",dv_uc_pk_where,dv_str2_pos)
    SET dv_str4_pos = findstring("SEGMENT_REFERENCE",dv_uc_pk_where,dv_str3_pos)
    IF (dv_str4_pos=0)
     RETURN(- (2))
    ELSE
     SET dv_src_tab_name = dm2_get_rdds_tname("SEGMENT_REFERENCE")
     SET drdm_chg->log[drdm_log_loop].pk_where = replace(cnvtupper(drdm_chg->log[drdm_log_loop].
       pk_where),"SEGMENT_REFERENCE",dv_src_tab_name,0)
     RETURN(drdm_log_loop)
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].merge_delete_ind=1))
    FOR (dv_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].merge_delete_ind=1))
       SET dv_md_col_cnt = (dv_md_col_cnt+ 1)
       IF (((findstring(concat(dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].
         column_name," "),sbr_dv_pk_where,1,0) > 0) OR (findstring(concat(dm2_ref_data_doc->tbl_qual[
         sbr_dv_table_cnt].col_qual[dv_col_loop].column_name,"="),sbr_dv_pk_where,1,0) > 0)) )
        SET dv_pkw_col_cnt = (dv_pkw_col_cnt+ 1)
       ENDIF
      ENDIF
    ENDFOR
    IF (dv_md_col_cnt=0)
     CALL disp_msg(concat("There were no MD columns defined for the current table: ",sbr_dv_t_name),
      dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (dv_pkw_col_cnt=dv_md_col_cnt)
     SET dv_and_cnt = 0
     SET dv_and_pos = 0
     WHILE (dv_end_ind=0)
       SET dv_dummy_cnt = 0
       SET dv_dummy_cnt = findstring(dv_t_suff_str,sbr_dv_pk_where,dv_and_pos,0)
       IF (dv_dummy_cnt=0)
        SET dv_end_ind = 1
       ELSE
        SET dv_and_cnt = (dv_and_cnt+ 1)
        SET dv_and_pos = (dv_dummy_cnt+ 3)
       ENDIF
     ENDWHILE
     IF (dv_and_cnt > 0)
      SET dv_and_position = 0
      SET dv_dummy_cnt = 1
      WHILE (dv_dummy_cnt > 0)
       SET dv_dummy_cnt = findstring("=",sbr_dv_pk_where,dv_and_position,0)
       IF (dv_dummy_cnt > 0)
        SET dv_delim_pos1 = findstring("'",sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos2 = findstring('"',sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos3 = findstring("^",sbr_dv_pk_where,dv_dummy_cnt,0)
        IF (dv_delim_pos1=0)
         SET dv_delim_pos1 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos2=0)
         SET dv_delim_pos2 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos3=0)
         SET dv_delim_pos3 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos1 < dv_delim_pos2)
         IF (dv_delim_pos1 < dv_delim_pos3)
          SET dv_delim_val = "'"
          SET dv_delim_start = dv_delim_pos1
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ELSE
         IF (dv_delim_pos2 < dv_delim_pos3)
          SET dv_delim_val = '"'
          SET dv_delim_start = dv_delim_pos2
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ENDIF
        IF (dv_delim_start < size(sbr_dv_pk_where))
         SET dv_delim_stop = findstring(dv_delim_val,sbr_dv_pk_where,(dv_delim_start+ 1),0)
         IF (dv_delim_stop > 0)
          SET dv_col_value = substring((dv_delim_start+ 1),(dv_delim_stop - (dv_delim_start+ 1)),
           sbr_dv_pk_where)
          IF (findstring(dv_t_suff_str,dv_col_value,0,0) > 0)
           SET dv_and_cnt = (dv_and_cnt - 1)
          ENDIF
          SET dv_and_position = (dv_delim_stop+ 1)
         ELSE
          SET dv_fix_ind = 1
         ENDIF
        ELSE
         SET dv_and_position = dv_delim_start
        ENDIF
       ENDIF
      ENDWHILE
     ENDIF
     IF ((dv_and_cnt != (dv_md_col_cnt - 1)))
      SET dv_fix_ind = 1
     ENDIF
    ELSE
     SET dv_fix_ind = 1
    ENDIF
    IF (dv_fix_ind=1)
     RETURN(- (1))
    ELSE
     SET dv_ret_cnt = drdm_log_loop
    ENDIF
   ELSE
    SET dv_pkw_col_cnt = 0
    FOR (dv_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_cnt)
     IF ((((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].table_name="DCP_FORMS_REF")) OR ((
     dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].table_name="DCP_SECTION_REF"))) )
      SET ver_tab_ind = 1
     ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_ind=1))
      IF ((((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_type="ALG1")) OR ((((
      dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_type="ALG3")) OR ((((dm2_ref_data_doc->
      tbl_qual[sbr_dv_table_cnt].version_type="ALG3D")) OR ((dm2_ref_data_doc->tbl_qual[
      sbr_dv_table_cnt].version_type="ALG4"))) )) )) )
       SET ver_tab_ind = 1
      ENDIF
     ENDIF
     IF (ver_tab_ind=1)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].unique_ident_ind=1))
       SET dv_pk_col_cnt = (dv_pk_col_cnt+ 1)
       IF (((findstring(concat(dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].
         column_name," "),sbr_dv_pk_where,1,0) > 0) OR (findstring(concat(dm2_ref_data_doc->tbl_qual[
         sbr_dv_table_cnt].col_qual[dv_col_loop].column_name,"="),sbr_dv_pk_where,1,0) > 0)) )
        SET dv_pkw_col_cnt = (dv_pkw_col_cnt+ 1)
       ENDIF
      ENDIF
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].pk_ind=1))
       SET dv_pk_col_cnt = (dv_pk_col_cnt+ 1)
       IF (((findstring(concat(dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].
         column_name," "),sbr_dv_pk_where,1,0) > 0) OR (findstring(concat(dm2_ref_data_doc->tbl_qual[
         sbr_dv_table_cnt].col_qual[dv_col_loop].column_name,"="),sbr_dv_pk_where,1,0) > 0)) )
        SET dv_pkw_col_cnt = (dv_pkw_col_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
    IF (dv_pk_col_cnt=0)
     CALL disp_msg(concat("There were no PK columns defined for the current table: ",sbr_dv_t_name),
      dm_err->logfile,1)
     RETURN(- (5))
    ENDIF
    IF (dv_pkw_col_cnt=dv_pk_col_cnt)
     SET dv_and_cnt = 0
     SET dv_and_pos = 0
     WHILE (dv_end_ind=0)
       SET dv_dummy_cnt = 0
       SET dv_dummy_cnt = findstring(dv_t_suff_str,sbr_dv_pk_where,dv_and_pos,0)
       IF (dv_dummy_cnt=0)
        SET dv_end_ind = 1
       ELSE
        SET dv_and_cnt = (dv_and_cnt+ 1)
        SET dv_and_pos = (dv_dummy_cnt+ 3)
       ENDIF
     ENDWHILE
     IF (dv_and_cnt > 0)
      SET dv_and_position = 0
      SET dv_dummy_cnt = 1
      WHILE (dv_dummy_cnt > 0)
       SET dv_dummy_cnt = findstring("=",sbr_dv_pk_where,dv_and_position,0)
       IF (dv_dummy_cnt > 0)
        SET dv_delim_pos1 = findstring("'",sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos2 = findstring('"',sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos3 = findstring("^",sbr_dv_pk_where,dv_dummy_cnt,0)
        IF (dv_delim_pos1=0)
         SET dv_delim_pos1 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos2=0)
         SET dv_delim_pos2 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos3=0)
         SET dv_delim_pos3 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos1 < dv_delim_pos2)
         IF (dv_delim_pos1 < dv_delim_pos3)
          SET dv_delim_val = "'"
          SET dv_delim_start = dv_delim_pos1
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ELSE
         IF (dv_delim_pos2 < dv_delim_pos3)
          SET dv_delim_val = '"'
          SET dv_delim_start = dv_delim_pos2
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ENDIF
        IF (dv_delim_start < size(sbr_dv_pk_where))
         SET dv_delim_stop = findstring(dv_delim_val,sbr_dv_pk_where,(dv_delim_start+ 1),0)
         IF (dv_delim_stop > 0)
          SET dv_col_value = substring((dv_delim_start+ 1),(dv_delim_stop - (dv_delim_start+ 1)),
           sbr_dv_pk_where)
          IF (findstring(dv_t_suff_str,dv_col_value,0,0) > 0)
           SET dv_and_cnt = (dv_and_cnt - 1)
          ENDIF
          SET dv_and_position = (dv_delim_stop+ 1)
         ELSE
          SET dv_fix_ind = 1
         ENDIF
        ELSE
         SET dv_and_position = dv_delim_start
        ENDIF
       ENDIF
      ENDWHILE
     ENDIF
     IF ((dv_and_cnt != (dv_pk_col_cnt - 1)))
      SET dv_fix_ind = 1
     ENDIF
    ELSE
     SET dv_fix_ind = 1
    ENDIF
    IF (dv_fix_ind=1)
     RETURN(- (2))
    ELSE
     SET dv_ret_cnt = drdm_log_loop
    ENDIF
   ENDIF
   RETURN(dv_ret_cnt)
 END ;Subroutine
 SUBROUTINE find_nvld_value(fnv_value,fnv_table,fnv_from_value)
   DECLARE fnv_return = vc
   DECLARE fnv_from_tab = vc
   DECLARE fnv_find_val = vc
   DECLARE fnv_tbl_name = vc
   DECLARE fnv_loc = i4
   DECLARE fnv_idx = i4
   IF (fnv_value != "0"
    AND fnv_from_value="0")
    SET fnv_from_tab = "dm_refchg_invalid_xlat"
    SET fnv_find_val = fnv_value
    SET fnv_tbl_name = trim(fnv_table)
   ELSEIF (fnv_value="0"
    AND fnv_from_value != "0")
    SET fnv_from_tab = concat("dm_refchg_invalid_xlat",dm2_ref_data_doc->post_link_name)
    SET fnv_tbl_name = concat(trim(fnv_table),dm2_ref_data_doc->post_link_name)
    SET fnv_find_val = fnv_from_value
   ENDIF
   SELECT
    IF (fnv_table IN ("PERSON", "PRSNL"))
     WHERE parent_entity_name IN ("PERSON", "PRSNL")
      AND parent_entity_id=cnvtreal(fnv_find_val)
    ELSE
     WHERE parent_entity_name=fnv_table
      AND parent_entity_id=cnvtreal(fnv_find_val)
    ENDIF
    INTO "nl:"
    FROM (parser(fnv_from_tab))
    WITH nocounter
   ;end select
   IF (check_error("Checking for invalid translation")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    SET drdm_error_out_ind = 1
   ENDIF
   IF (curqual != 0)
    IF ((multi_col_pk->table_cnt > 0))
     SET fnv_loc = locateval(fnv_idx,1,multi_col_pk->table_cnt,trim(fnv_table),multi_col_pk->qual[
      fnv_idx].table_name)
     IF (fnv_loc != 0)
      SELECT INTO "nl:"
       FROM (parser(fnv_tbl_name) d)
       WHERE parser(concat("d.",trim(multi_col_pk->qual[fnv_idx].column_name)," =",fnv_find_val))
       WITH nocounter
      ;end select
      IF (check_error("Checking for invalid translation")=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       SET drdm_error_out_ind = 1
      ENDIF
      IF (curqual=0)
       SET fnv_return = "No Trans"
      ELSE
       SET fnv_return = fnv_find_val
       DELETE  FROM (parser(fnv_from_tab))
        WHERE parent_entity_name=fnv_table
         AND parent_entity_id=cnvtreal(fnv_find_val)
        WITH nocounter
       ;end delete
       IF (check_error("Checking for invalid translation")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->err_ind = 1
        SET drdm_error_out_ind = 1
       ENDIF
      ENDIF
     ELSE
      SET fnv_return = "No Trans"
     ENDIF
    ELSE
     SET fnv_return = "No Trans"
    ENDIF
   ELSE
    SET fnv_return = fnv_find_val
   ENDIF
   RETURN(fnv_return)
 END ;Subroutine
 SUBROUTINE check_backfill(i_source_id,i_table_name,i_tbl_pos)
   DECLARE cb_ret_val = c1 WITH protect, noconstant("F")
   DECLARE cb_loop = i4 WITH protect
   DECLARE cb_seq_name = vc WITH protect
   DECLARE cb_seq_num = f8 WITH protect
   DECLARE cb_cur_table = i4 WITH protect
   DECLARE cb_info_domain = vc WITH protect
   DECLARE cb_pause_ind = i2 WITH protect, noconstant(1)
   DECLARE cb_seq_loop = i4 WITH protect
   DECLARE cb_rdb_handle = f8 WITH protect
   DECLARE cb_seq_val = i4 WITH protect
   DECLARE cb_refchg_type = vc WITH protect, noconstant("")
   DECLARE cb_refchg_status = vc WITH protect, noconstant("")
   IF (i_table_name="REF_TEXT_RELTN")
    SET cb_seq_name = "REFERENCE_SEQ"
   ELSE
    FOR (cb_loop = 1 TO dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_qual[cb_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_qual[cb_loop].root_entity_name=i_table_name))
       IF (i_table_name="APPLICATION_TASK")
        SET cb_seq_name = "APPLICATION_TASK"
       ELSE
        SET cb_seq_name = dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_qual[cb_loop].sequence_name
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (cb_seq_name="")
    CALL disp_msg("Check_Backfill: No Valid sequence was found",dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
    SET dm_err->err_ind = 0
    CALL merge_audit("FAILREASON","No Valid sequence was found",3)
    RETURN(cb_ret_val)
   ENDIF
   SET cb_seq_val = locateval(cb_seq_loop,1,size(drdm_sequence->qual,5),cb_seq_name,drdm_sequence->
    qual[cb_seq_loop].seq_name)
   IF (cb_seq_val=0
    AND i_table_name != "APPLICATION_TASK")
    SELECT
     IF ((dm2_rdds_rec->mode="OS"))
      WHERE d.info_domain="MERGE00SEQMATCH"
       AND d.info_name=cb_seq_name
     ELSE
      WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
        cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCH")
       AND d.info_name=cb_seq_name
     ENDIF
     INTO "NL:"
     FROM dm_info d
     DETAIL
      cb_seq_num = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
     RETURN(cb_ret_val)
    ENDIF
    IF (((curqual=0) OR ((cb_seq_num=- (1)))) )
     SET cb_cur_table = temp_tbl_cnt
     ROLLBACK
     SET drmm_ddl_rollback_ind = 1
     EXECUTE dm2_noupdt_seq_match cb_seq_name, dm2_ref_data_doc->env_source_id
     SET temp_tbl_cnt = cb_cur_table
     IF ((dm_err->err_ind=1))
      CALL disp_msg(concat("CHECK_BACKFILL: ",dm_err->emsg),dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 1
      SET drdm_error_ind = 1
      RETURN(cb_ret_val)
     ENDIF
     SELECT
      IF ((dm2_rdds_rec->mode="OS"))
       WHERE d.info_domain="MERGE00SEQMATCH"
        AND d.info_name=cb_seq_name
      ELSE
       WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
         cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCH")
        AND d.info_name=cb_seq_name
      ENDIF
      INTO "NL:"
      FROM dm_info d
      DETAIL
       cb_seq_num = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      RETURN(cb_ret_val)
     ENDIF
     IF (curqual=0)
      SET drdm_error_out_ind = 1
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg =
      "CHECK_BACKFILL: A sequence match could not be found in DM_INFO"
      CALL disp_msg("A sequence match could not be found in DM_INFO",dm_err->logfile,1)
      RETURN("F")
     ENDIF
    ENDIF
    SET drdm_sequence->qual_cnt = (drdm_sequence->qual_cnt+ 1)
    SET stat = alterlist(drdm_sequence->qual,drdm_sequence->qual_cnt)
    SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_name = cb_seq_name
    SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_val = cb_seq_num
    SET cb_seq_val = drdm_sequence->qual_cnt
   ELSE
    IF (i_table_name="APPLICATION_TASK")
     IF (cb_seq_val=0)
      SET drdm_sequence->qual_cnt = (drdm_sequence->qual_cnt+ 1)
      SET stat = alterlist(drdm_sequence->qual,drdm_sequence->qual_cnt)
      SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_name = "APPLICATION_TASK"
      SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_val = 0
      SET cb_seq_val = drdm_sequence->qual_cnt
     ENDIF
     SET cb_seq_num = 0
    ELSE
     SET cb_seq_num = drdm_sequence->qual[cb_seq_val].seq_val
    ENDIF
   ENDIF
   IF (cb_seq_num=0)
    IF ((drdm_sequence->qual[cb_seq_val].seqmatch_ind=0))
     SELECT INTO "nl"
      FROM dm_info di
      WHERE di.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
        cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCHDONE2")
       AND di.info_name=cb_seq_name
      WITH nocounter
     ;end select
     IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      RETURN(cb_ret_val)
     ENDIF
     IF (curqual != 0)
      SET cb_ret_val = "S"
      SET drdm_sequence->qual[cb_seq_val].seqmatch_ind = 1
      RETURN(cb_ret_val)
     ENDIF
    ELSEIF ((drdm_sequence->qual[cb_seq_val].seqmatch_ind=1))
     SET cb_ret_val = "S"
     RETURN(cb_ret_val)
    ENDIF
   ENDIF
   SET cb_info_domain = concat("XLAT BACKFILL",trim(cnvtstring(i_source_id,20)),trim(cnvtstring(
      dm2_ref_data_doc->mock_target_id,20)))
   WHILE (cb_pause_ind=1)
     SET cb_pause_ind = 0
     ROLLBACK
     SET drl_reply->status = ""
     SET drl_reply->status_msg = ""
     CALL get_lock(cb_info_domain,cb_seq_name,0,drl_reply)
     IF ((drl_reply->status="F"))
      CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = drl_reply->status_msg
      RETURN(cb_ret_val)
     ELSEIF ((drl_reply->status="Z"))
      SET cb_pause_ind = 1
     ELSE
      COMMIT
     ENDIF
     IF (cb_pause_ind=1)
      CALL echo("")
      CALL echo("")
      CALL echo("**************BACKFILL IN PROGRESS. WAIT 60 SECONDS AND TRY AGAIN***************")
      CALL echo("")
      CALL echo("")
      CALL disp_msg("********BACKFILL IN PROGRESS. WAIT 60 SECONDS AND TRY AGAIN*********",dm_err->
       logfile,0)
      CALL pause(60)
      SELECT
       IF ((dm2_rdds_rec->mode="OS"))
        WHERE d.info_domain="MERGE00SEQMATCH"
         AND d.info_name=cb_seq_name
       ELSE
        WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
          cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCH")
         AND d.info_name=cb_seq_name
       ENDIF
       INTO "NL:"
       FROM dm_info d
       DETAIL
        cb_seq_num = d.info_number
       WITH nocounter
      ;end select
      IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
       RETURN(cb_ret_val)
      ENDIF
      IF (cb_seq_num=0)
       SET cb_ret_val = "S"
       RETURN(cb_ret_val)
      ENDIF
     ENDIF
   ENDWHILE
   SET dm_err->eproc = "Gathering information from dm_refchg_process."
   SELECT INTO "nl:"
    FROM dm_refchg_process d
    WHERE d.rdbhandle_value=cnvtreal(currdbhandle)
    DETAIL
     cb_refchg_type = d.refchg_type, cb_refchg_status = d.refchg_status
    WITH nocounter
   ;end select
   IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(cb_ret_val)
   ENDIF
   CALL add_tracking_row(i_source_id,cb_refchg_type,"XLAT BCKFLL RUNNING")
   IF (cb_seq_name="APPLICATION_TASK")
    CALL seqmatch_xlats("",i_source_id,"APPLICATION_TASK")
   ELSE
    CALL seqmatch_xlats(cb_seq_name,i_source_id,"")
   ENDIF
   CALL add_tracking_row(i_source_id,cb_refchg_type,cb_refchg_status)
   SET drl_reply->status = ""
   SET drl_reply->status_msg = ""
   CALL remove_lock(cb_info_domain,cb_seq_name,currdbhandle,drl_reply)
   COMMIT
   IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(cb_ret_val)
   ENDIF
   IF (cb_seq_name != "APPLICATION_TASK")
    SET drdm_sequence->qual[cb_seq_val].seq_val = 0
   ENDIF
   SET cb_ret_val = "S"
   RETURN(cb_ret_val)
 END ;Subroutine
 SUBROUTINE redirect_to_start_row(rsr_drdm_chg,rsr_log_pos,rsr_next_row,rsr_max_size)
   DECLARE rsr_done_ind = i2
   DECLARE rsr_cur_pos = i4
   DECLARE rsr_loop = i4
   DECLARE rsr_size = i4
   DECLARE rsr_eraseable = i2
   DECLARE rsr_next_pos = i4
   SET rsr_size = size(rsr_drdm_chg->log,5)
   IF (rsr_log_pos > drdm_log_cnt)
    SET rsr_eraseable = 1
   ENDIF
   WHILE (rsr_done_ind=0)
     SET rsr_cur_pos = 0
     FOR (rsr_loop = 1 TO rsr_size)
       IF (rsr_log_pos <= drdm_log_cnt)
        IF ((rsr_drdm_chg->log[rsr_loop].next_to_process=rsr_log_pos)
         AND rsr_loop <= drdm_log_cnt)
         SET rsr_cur_pos = rsr_loop
         SET rsr_loop = rsr_size
        ENDIF
       ELSE
        IF ((rsr_drdm_chg->log[rsr_loop].next_to_process=rsr_log_pos)
         AND (rsr_drdm_chg->log[rsr_loop].table_name > ""))
         SET rsr_cur_pos = rsr_loop
         SET rsr_loop = rsr_size
        ENDIF
       ENDIF
     ENDFOR
     IF (rsr_cur_pos > 0)
      SET rsr_log_pos = rsr_cur_pos
      IF ((rsr_drdm_chg->log[rsr_log_pos].commit_ind=1))
       SET rsr_log_pos = rsr_drdm_chg->log[rsr_log_pos].next_to_process
       SET rsr_done_ind = 1
      ENDIF
     ELSE
      SET rsr_done_ind = 1
     ENDIF
   ENDWHILE
   SET drdm_mini_loop_status = ""
   SET drdm_no_trans_ind = 1
   SET nodelete_ind = 1
   SET no_insert_update = 1
   SET stat = alterlist(missing_xlats->qual,0)
   SET drmm_ddl_rollback_ind = 1
   IF (rsr_next_row > rsr_max_size)
    SET rsr_max_size = (rsr_max_size+ 10)
    SET stat = alterlist(rsr_drdm_chg->log,rsr_max_size)
   ENDIF
   CALL reinitialize_drdm(rsr_next_row)
   IF (rsr_eraseable=1
    AND rsr_log_pos <= drdm_log_cnt)
    SET rsr_done_ind = 0
    SET rsr_next_pos = rsr_log_pos
    WHILE (rsr_done_ind=0)
     SET rsr_drdm_chg->log[rsr_next_pos].exploded_ind = 0
     IF ((rsr_drdm_chg->log[rsr_next_pos].next_to_process=0))
      SET rsr_done_ind = 1
     ELSE
      SET rsr_next_pos = rsr_drdm_chg->log[rsr_next_pos].next_to_process
     ENDIF
    ENDWHILE
   ENDIF
   SET rsr_drdm_chg->log[rsr_next_row].next_to_process = rsr_log_pos
   SET rsr_next_row = (rsr_next_row+ 1)
   RETURN((rsr_next_row - 1))
 END ;Subroutine
 SUBROUTINE get_multi_col_pk(null)
  IF ((multi_col_pk->table_cnt=0))
   SET dm_err->eproc = "Obtaining a list of tables with multi-column pk"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS ROOT ENTITY MULTI COLUMN PK"
    HEAD REPORT
     multi_col_pk->table_cnt = 0
    DETAIL
     multi_col_pk->table_cnt = (multi_col_pk->table_cnt+ 1), stat = alterlist(multi_col_pk->qual,
      multi_col_pk->table_cnt), multi_col_pk->qual[multi_col_pk->table_cnt].table_name = di.info_name,
     multi_col_pk->qual[multi_col_pk->table_cnt].column_name = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE find_original_log_row(i_drdm_chg_rs,i_pos)
   DECLARE folr_done_ind = i2 WITH protect, noconstant(0)
   DECLARE folr_pos = i4 WITH protect, noconstant(i_pos)
   WHILE (folr_done_ind=0)
    SET folr_done_ind = i_drdm_chg_rs->log[folr_pos].commit_ind
    IF (folr_done_ind=0)
     SET folr_pos = i_drdm_chg_rs->log[folr_pos].next_to_process
     IF (folr_pos=0)
      SET folr_pos = i_pos
      SET folr_done_ind = 1
     ENDIF
    ENDIF
   ENDWHILE
   RETURN(folr_pos)
 END ;Subroutine
 SUBROUTINE add_single_pass_dcl_row(i_table_name,i_pk_string,i_single_pass_log_id,i_context_name)
   DECLARE v_tpd_log_id = f8 WITH protect, noconstant(0.0)
   DECLARE v_dcl = vc WITH protect, constant(dm2_get_rdds_tname("DM_CHG_LOG"))
   SET v_tpd_log_id = trigger_proc_dcl(0.0,i_table_name,i_pk_string,0,i_single_pass_log_id,
    "PROCES",i_context_name)
   IF (v_tpd_log_id > 0)
    UPDATE  FROM (parser(v_dcl) d)
     SET d.rdbhandle = currdbhandle, d.single_pass_log_id = i_single_pass_log_id, d.log_type =
      "PROCES",
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE d.log_id=v_tpd_log_id
      AND d.log_type != "PROCES"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET v_tpd_log_id = - (1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(v_tpd_log_id)
 END ;Subroutine
 SUBROUTINE fill_cur_state_rs(fcsr_tab_name)
   DECLARE fcsr_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE fcsr_num = i4 WITH protect, noconstant(0)
   DECLARE fcsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE fcsr_pkw = vc
   DECLARE fcsr_str1_pos = i4
   DECLARE fcsr_str2_pos = i4
   DECLARE fcsr_str3_pos = i4
   DECLARE fcsr_done_end = i2
   DECLARE fcsr_open_cnt = i4
   DECLARE fcsr_close_cnt = i4
   DECLARE fcsr_temp = i4 WITH protect, noconstant(0)
   DECLARE fcsr_temp2 = i4 WITH protect, noconstant(0)
   DECLARE fcsr_delim1 = i4
   DECLARE fcsr_delim2 = i4
   SET fcsr_tab_pos = locateval(fcsr_num,1,cur_state_tabs->total,fcsr_tab_name,cur_state_tabs->qual[
    fcsr_num].table_name)
   IF (fcsr_tab_pos > 0)
    RETURN(fcsr_tab_pos)
   ENDIF
   SET cur_state_tabs->total = (cur_state_tabs->total+ 1)
   SET stat = alterlist(cur_state_tabs->qual,cur_state_tabs->total)
   SET cur_state_tabs->qual[cur_state_tabs->total].table_name = fcsr_tab_name
   SET dm_err->eproc = "Gathering current state PE info."
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CURRENT STATE TABLES"
     AND d.info_name=patstring(concat(fcsr_tab_name,"*"))
    HEAD REPORT
     fcsr_cnt = 0
    DETAIL
     cur_state_tabs->qual[cur_state_tabs->total].parent_tab_col = d.info_char, fcsr_cnt = (fcsr_cnt+
     1), stat = alterlist(cur_state_tabs->qual[cur_state_tabs->total].parent_qual,fcsr_cnt),
     fcsr_temp = findstring(":",d.info_name), fcsr_temp2 = findstring(":",d.info_name,(fcsr_temp+ 1))
     IF (fcsr_temp2 > 0)
      cur_state_tabs->qual[cur_state_tabs->total].parent_qual[fcsr_cnt].parent_table = substring((
       fcsr_temp+ 1),(fcsr_temp2 - (fcsr_temp+ 1)),d.info_name)
     ELSE
      cur_state_tabs->qual[cur_state_tabs->total].parent_qual[fcsr_cnt].parent_table = substring((
       fcsr_temp+ 1),(size(trim(d.info_name),1) - fcsr_temp),d.info_name)
     ENDIF
     fcsr_temp = findstring(":",d.info_name,1,1), cur_state_tabs->qual[cur_state_tabs->total].
     parent_qual[fcsr_cnt].top_level_parent = substring((fcsr_temp+ 1),(size(trim(d.info_name),1) -
      fcsr_temp),d.info_name)
    FOOT REPORT
     cur_state_tabs->qual[cur_state_tabs->total].parent_cnt = fcsr_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET fcsr_tab_pos = cur_state_tabs->total
   RETURN(fcsr_tab_pos)
 END ;Subroutine
 SUBROUTINE drdm_hash_validate(sbr_dv_t_name,sbr_dv_pk_where,sbr_dv_table_cnt,sbr_dv_pkw_hash,
  sbr_dv_ptam_hash,sbr_dv_delete_ind,sbr_updt_applctx)
   DECLARE dv_ret_cnt = i4
   DECLARE dhv_pk_where = vc WITH protect, noconstant("")
   DECLARE dhv_filter_ret = i4 WITH protect, noconstant(0)
   IF (((sbr_dv_delete_ind=0
    AND (sbr_dv_pkw_hash != dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].pk_where_hash)) OR (
   sbr_dv_delete_ind=1
    AND (sbr_dv_pkw_hash != dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].del_pk_where_hash))) )
    RETURN(- (1))
   ENDIF
   IF ((sbr_dv_ptam_hash != dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].ptam_match_hash))
    RETURN(- (2))
   ENDIF
   SET dhv_pk_where = sbr_dv_pk_where
   IF ((((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_ind=0)) OR ((dm2_ref_data_doc->
   tbl_qual[sbr_dv_table_cnt].version_ind=1)
    AND  NOT ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_type IN ("ALG1", "ALG3", "ALG3D",
   "ALG4", "ALG5",
   "ALG6", "ALG7"))))) )
    SET dhv_filter_ret = filter_proc_call(sbr_dv_t_name,dhv_pk_where,sbr_updt_applctx)
    IF (dhv_filter_ret=0)
     RETURN(- (4))
    ENDIF
   ENDIF
   RETURN(drdm_log_loop)
 END ;Subroutine
 SUBROUTINE fill_hold_excep_rs(null)
  FOR (i = 1 TO drmm_hold_exception->value_cnt)
    SET drwdr_reply->dcle_id = 0
    SET drwdr_reply->error_ind = 0
    SET drwdr_request->table_name = drmm_hold_exception->qual[i].table_name
    SET drwdr_request->log_type = drmm_hold_exception->qual[i].log_type
    SET drwdr_request->col_name = drmm_hold_exception->qual[i].column_name
    SET drwdr_request->from_value = drmm_hold_exception->qual[i].from_value
    SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
    SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
    SET drwdr_request->dclei_ind = drmm_excep_flag
    SET drwdr_request->dcl_excep_id = drmm_hold_exception->qual[i].dcl_excep_id
    EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
     "DRWDR_REPLY")
    SET drwdr_request->dcl_excep_id = 0
  ENDFOR
  SET stat = initrec(drmm_hold_exception)
 END ;Subroutine
 SUBROUTINE trigger_proc_dcl(tpd_log_id,tpd_table_name,tpd_pk_str,tpd_delete_ind,tpd_sp_log_id,
  tpd_log_type,tpd_context)
   DECLARE tpd_pk_where = vc WITH protect, noconstant("")
   DECLARE tpd_tbl_loop = i4 WITH protect, noconstant(0)
   DECLARE tpd_suffix = vc WITH protect, noconstant("")
   DECLARE tpd_src_tab_name = vc WITH protect, noconstant("")
   DECLARE tpd_all_filtered = i2 WITH protect, noconstant(0)
   DECLARE tpd_last_pk_where = vc WITH protect, noconstant("")
   DECLARE tpd_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE tpd_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE tpd_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_idx = i4 WITH protect, noconstant(0)
   DECLARE tpd_where_str = vc WITH protect, noconstant("")
   DECLARE tpd_qual = i4 WITH protect, noconstant(0)
   DECLARE tpd_filter_ind = i2 WITH protect, noconstant(0)
   DECLARE tpd_status = vc WITH protect, noconstant("")
   DECLARE tpd_pkw_hash = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_ptam_result = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_currval = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_new_currval = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_dcl_tab = vc WITH protect, noconstant("")
   DECLARE tpd_new_log_id = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_reason_str = vc WITH protect, noconstant("")
   DECLARE tpd_ins_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_pk_where_hash = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_context_str = vc WITH protect, noconstant("")
   DECLARE tpd_log_type_str = vc WITH protect, noconstant("")
   DECLARE tpd_temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_pkw_value = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_par_pos = i4 WITH protect, noconstant(0)
   DECLARE tpd_par_name = vc WITH protect, noconstant("")
   DECLARE tpd_cur_state_flag = i4 WITH protect, noconstant(0)
   DECLARE tpd_cs_pos = i4 WITH protect, noconstant(0)
   DECLARE tpd_loop = i4 WITH protect, noconstant(0)
   DECLARE tpd_temp_pkw = vc WITH protect, noconstant("")
   DECLARE tpd_prsn_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_prsn_tab = vc WITH protect, noconstant("")
   DECLARE tpd_curqual = i4 WITH protect, noconstant(0)
   DECLARE tpd_colstr_ret = i4 WITH protect, noconstant(0)
   DECLARE tpd_curstate_flag_2_quals = i2 WITH protect, noconstant(0)
   DECLARE tpd_curstate_log_type = vc WITH protect, noconstant("")
   FREE RECORD tpd_pkw_rs
   RECORD tpd_pkw_rs(
     1 qual[*]
       2 pkw = vc
       2 log_id = f8
       2 invalid_ind = i2
       2 table_name = vc
       2 table_suffix = vc
       2 skip_filter_ind = i2
   )
   SET tpd_temp_cnt = temp_tbl_cnt
   SET tpd_tbl_cnt = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpd_table_name,
    dm2_ref_data_doc->tbl_qual[tpd_tbl_loop].table_name)
   IF (tpd_tbl_cnt=0)
    SET tpd_tbl_cnt = fill_rs("TABLE",tpd_table_name)
    IF ((tpd_tbl_cnt=- (1)))
     CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
    IF ((tpd_tbl_cnt=- (2)))
     RETURN(- (2.0))
    ENDIF
   ENDIF
   SET temp_tbl_cnt = tpd_temp_cnt
   SET tpd_suffix = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].suffix
   SET tpd_src_tab_name = dm2_get_rdds_tname(tpd_table_name)
   SET tpd_cur_state_flag = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].cur_state_flag
   IF (tpd_cur_state_flag > 0)
    SET tpd_cs_pos = fill_cur_state_rs(tpd_table_name)
    IF (tpd_cs_pos=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("ERROR: Couldn't not gather current state information for table ",
      tpd_table_name,".")
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
   ENDIF
   IF (tpd_delete_ind=1)
    SET stat = alterlist(tpd_pkw_rs->qual,1)
    SET tpd_pkw_rs->qual[1].log_id = tpd_log_id
    SET tpd_pkw_rs->qual[1].pkw = "NO PK_WHERE"
    SET tpd_pkw_rs->qual[1].table_name = tpd_table_name
    SET tpd_pkw_rs->qual[1].table_suffix = tpd_suffix
   ELSEIF (tpd_log_id > 0.0)
    IF (tpd_pk_str="")
     SET tpd_dcl_tab_name = dm2_get_rdds_tname("DM_CHG_LOG")
     SELECT INTO "nl:"
      FROM (parser(tpd_dcl_tab_name) d)
      WHERE d.log_id=tpd_log_id
      HEAD REPORT
       tpd_cnt = 0
      DETAIL
       tpd_pk_where = replace(replace(d.pk_where,"<MERGE_LINK>",dm2_ref_data_doc->post_link_name,0),
        "<VERS_CLAUSE>"," 1=1 ",0)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
    ELSE
     SET tpd_pk_where = tpd_pk_str
    ENDIF
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",tpd_src_tab_name," t",tpd_suffix),0)
    CALL parser(concat(tpd_pk_where," head report tpd_cnt = 0"),0)
    CALL parser("detail",0)
    CALL parser("tpd_cnt = tpd_cnt+1",0)
    CALL parser("stat = alterlist(tpd_pkw_rs->qual, tpd_cnt)",0)
    CALL parser(concat(
      ^tpd_pkw_rs->qual[tpd_cnt].pkw = concat('WHERE t', tpd_suffix, '.rowid = "', t^,tpd_suffix,
      ^.rowid, '"')^),0)
    CALL parser("tpd_pkw_rs->qual[tpd_cnt].table_name = tpd_table_name ",0)
    CALL parser("tpd_pkw_rs->qual[tpd_cnt].table_suffix = tpd_suffix ",0)
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
   ELSE
    IF (tpd_table_name="PRSNL")
     SET tpd_prsn_tab = dm2_get_rdds_tname("PERSON")
     SELECT INTO "nl:"
      FROM (parser(tpd_prsn_tab) p)
      WHERE parser(tpd_pk_str)
      WITH nocounter
     ;end select
     SET tpd_curqual = curqual
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
     IF (tpd_curqual > 0)
      SET stat = alterlist(tpd_pkw_rs->qual,2)
      SET tpd_pkw_rs->qual[1].pkw = concat("WHERE ",tpd_pk_str)
      SET tpd_pkw_rs->qual[1].table_name = "PERSON"
      SET tpd_pkw_rs->qual[1].table_suffix = "4859"
      SET tpd_pkw_rs->qual[1].skip_filter_ind = 1
      SET tpd_pkw_rs->qual[2].pkw = concat("WHERE ",tpd_pk_str)
      SET tpd_pkw_rs->qual[2].table_name = tpd_table_name
      SET tpd_pkw_rs->qual[2].table_suffix = tpd_suffix
      SET tpd_temp_cnt = temp_tbl_cnt
      SET tpd_prsn_cnt = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,"PERSON",dm2_ref_data_doc
       ->tbl_qual[tpd_tbl_loop].table_name)
      IF (tpd_prsn_cnt=0)
       SET tpd_prsn_cnt = fill_rs("TABLE","PERSON")
       IF ((tpd_prsn_cnt=- (1)))
        CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF ((tpd_prsn_cnt=- (2)))
        RETURN(- (2.0))
       ENDIF
      ENDIF
      SET temp_tbl_cnt = tpd_temp_cnt
     ELSE
      SET stat = alterlist(tpd_pkw_rs->qual,1)
      SET tpd_pkw_rs->qual[1].pkw = concat("WHERE ",tpd_pk_str)
      SET tpd_pkw_rs->qual[1].table_name = tpd_table_name
      SET tpd_pkw_rs->qual[1].table_suffix = tpd_suffix
     ENDIF
    ELSE
     SET stat = alterlist(tpd_pkw_rs->qual,1)
     SET tpd_pkw_rs->qual[1].pkw = concat("WHERE ",tpd_pk_str)
     SET tpd_pkw_rs->qual[1].table_name = tpd_table_name
     SET tpd_pkw_rs->qual[1].table_suffix = tpd_suffix
    ENDIF
   ENDIF
   IF (size(tpd_pkw_rs->qual,5)=0)
    RETURN(- (3.0))
   ENDIF
   SET tpd_all_filtered = 1
   SET tpd_reason_str = "This row was replaced with the following log_id(s):"
   SET tpd_ins_cnt = 0
   SET dm_err->eproc = "Getting current sequence value."
   SELECT INTO "nl:"
    tpd_val = seq(rdds_source_clinical_seq,currval)
    FROM dual
    DETAIL
     tpd_currval = tpd_val
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1.0))
   ENDIF
   FOR (tpd_idx = 1 TO size(tpd_pkw_rs->qual,5))
     SET tpd_tbl_cnt = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpd_pkw_rs->qual[tpd_idx].
      table_name,dm2_ref_data_doc->tbl_qual[tpd_tbl_loop].table_name)
     IF (tpd_delete_ind=1)
      SET tpd_pk_where_hash = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].del_pk_where_hash
     ELSE
      SET tpd_pk_where_hash = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].pk_where_hash
     ENDIF
     IF ((tpd_pkw_rs->qual[tpd_idx].log_id > 0.0))
      SET tpd_colstr_ret = drmm_get_col_string(" ",tpd_pkw_rs->qual[tpd_idx].log_id,tpd_pkw_rs->qual[
       tpd_idx].table_name,tpd_pkw_rs->qual[tpd_idx].table_suffix,dm2_ref_data_doc->post_link_name)
     ELSE
      SET tpd_colstr_ret = drmm_get_col_string(tpd_pkw_rs->qual[tpd_idx].pkw,0.0,tpd_pkw_rs->qual[
       tpd_idx].table_name,tpd_pkw_rs->qual[tpd_idx].table_suffix,dm2_ref_data_doc->post_link_name)
     ENDIF
     IF (check_error(dm_err->eproc)=1)
      CALL echo(build("tpd_colstr_ret:",tpd_colstr_ret))
      IF ((tpd_colstr_ret=- (2)))
       SET dm_err->err_ind = 0
      ENDIF
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
     SET tpd_pk_where = drmm_get_pk_where(tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pkw_rs->qual[
      tpd_idx].table_suffix,tpd_delete_ind,dm2_ref_data_doc->post_link_name)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
     IF (tpd_pk_where != tpd_last_pk_where)
      SET tpd_last_pk_where = tpd_pk_where
      IF (drdm_debug_row_ind=1)
       CALL echo("***PK_WHERE generated:***")
       CALL echo(tpd_pk_where)
      ENDIF
      IF (tpd_log_id=0.0
       AND (tpd_pkw_rs->qual[tpd_idx].table_name != "PERSON"))
       SET tpd_where_str = replace(tpd_pk_where,"<MERGE_LINK>",dm2_ref_data_doc->post_link_name,0)
       IF (tpd_cur_state_flag > 0)
        IF (tpd_cur_state_flag=2)
         FOR (tpd_loop = 1 TO cur_state_tabs->qual[tpd_cs_pos].parent_cnt)
           IF (findstring(cur_state_tabs->qual[tpd_cs_pos].parent_qual[tpd_loop].parent_table,
            tpd_where_str,1,1) > 0)
            SET tpd_curstate_flag_2_quals = 1
            SET tpd_temp_cnt = temp_tbl_cnt
            SET tpd_par_pos = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,cur_state_tabs->
             qual[tpd_cs_pos].parent_qual[tpd_loop].top_level_parent,dm2_ref_data_doc->tbl_qual[
             tpd_tbl_loop].table_name)
            IF (tpd_par_pos=0)
             SET tpd_par_pos = fill_rs("TABLE",cur_state_tabs->qual[tpd_cs_pos].parent_qual[tpd_loop]
              .top_level_parent)
             IF ((tpd_par_pos=- (1)))
              CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
              SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
              SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
              RETURN(- (1.0))
             ENDIF
             IF ((tpd_par_pos=- (2)))
              RETURN(- (2.0))
             ENDIF
             SET temp_tbl_cnt = tpd_temp_cnt
             SET tpd_loop = cur_state_tabs->qual[tpd_cs_pos].parent_cnt
            ENDIF
           ENDIF
         ENDFOR
        ELSE
         SET tpd_temp_cnt = temp_tbl_cnt
         SET tpd_par_pos = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,cur_state_tabs->qual[
          tpd_cs_pos].parent_qual[1].top_level_parent,dm2_ref_data_doc->tbl_qual[tpd_tbl_loop].
          table_name)
         IF (tpd_par_pos=0)
          SET tpd_par_pos = fill_rs("TABLE",cur_state_tabs->qual[tpd_cs_pos].parent_qual[1].
           top_level_parent)
          IF ((tpd_par_pos=- (1)))
           CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
           SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
           SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
           RETURN(- (1.0))
          ENDIF
          IF ((tpd_par_pos=- (2)))
           RETURN(- (2.0))
          ENDIF
         ENDIF
         SET temp_tbl_cnt = tpd_temp_cnt
        ENDIF
        IF (tpd_par_pos > 0)
         IF ((((dm2_ref_data_doc->tbl_qual[tpd_par_pos].version_ind=1)) OR ((dm2_ref_data_doc->
         tbl_qual[tpd_par_pos].table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF")))) )
          SET tpd_loop = 1
         ELSE
          SET tpd_loop = 3
         ENDIF
        ELSE
         SET tpd_loop = 3
        ENDIF
        SET tpd_temp_pkw = tpd_where_str
        WHILE (tpd_loop <= 3
         AND tpd_qual=0)
          IF (tpd_loop=1)
           SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>"," ACTIVE_IND = 1 ",0)
          ELSEIF (tpd_loop=2)
           IF ((dm2_ref_data_doc->tbl_qual[tpd_par_pos].effective_col_ind=1))
            SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>",concat(dm2_ref_data_doc->
              tbl_qual[tpd_par_pos].beg_col_name,"<= cnvtdatetime(curdate,curtime3) and ",
              dm2_ref_data_doc->tbl_qual[tpd_par_pos].end_col_name,
              ">= cnvtdatetime(curdate,curtime3) "),0)
           ELSE
            SET tpd_loop = 3
            SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>"," 1 = 1 ",0)
           ENDIF
          ELSE
           SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>"," 1 = 1 ",0)
          ENDIF
          CALL parser("select into 'nl:'",0)
          CALL parser(concat(" from ",tpd_src_tab_name," t",tpd_pkw_rs->qual[tpd_idx].table_suffix),0
           )
          CALL parser(concat(tpd_where_str," with nocounter,notrim go"),1)
          SET tpd_qual = curqual
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
           SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
           RETURN(- (1.0))
          ENDIF
          SET tpd_loop = (tpd_loop+ 1)
        ENDWHILE
       ENDIF
       SET tpd_where_str = concat(tpd_where_str," AND ",tpd_pk_str)
       CALL parser("select into 'nl:'",0)
       CALL parser(concat(" from ",tpd_src_tab_name," t",tpd_pkw_rs->qual[tpd_idx].table_suffix),0)
       CALL parser(concat(tpd_where_str," with nocounter,notrim go"),1)
       SET tpd_qual = curqual
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF (tpd_qual=0)
        CALL disp_msg(concat("Failed attempting to create pk_where for ",tpd_pk_str,
          ". The pk_where created: ",tpd_where_str,"does not qualify on the needed row."),dm_err->
         logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = concat(
         "Failed attempting to create required pk_where for ",tpd_pk_str,". The pk_where created: ",
         tpd_where_str,"does not qualify on the needed row.")
        RETURN(- (5.0))
       ENDIF
      ENDIF
      CALL drmm_get_ptam_match_query(0.0,tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pkw_rs->qual[
       tpd_idx].table_suffix,dm2_ref_data_doc->post_link_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
       RETURN(- (1.0))
      ENDIF
      IF (tpd_delete_ind=0
       AND (tpd_pkw_rs->qual[tpd_idx].skip_filter_ind != 1))
       IF ((((dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].version_ind=0)) OR ((dm2_ref_data_doc->
       tbl_qual[tpd_tbl_cnt].version_ind=1)
        AND  NOT ((dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].version_type IN ("ALG1", "ALG3", "ALG3D",
       "ALG4", "ALG5",
       "ALG6"))))) )
        SET tpd_filter_ind = filter_proc_call(tpd_pkw_rs->qual[tpd_idx].table_name,replace(
          tpd_pk_where,"<MERGE_LINK>",dm2_ref_data_doc->post_link_name,0),0.0)
       ELSE
        SET tpd_filter_ind = 1
       ENDIF
      ELSE
       SET tpd_filter_ind = 1
      ENDIF
      IF (tpd_filter_ind=1)
       IF (tpd_log_id=0
        AND ((tpd_cur_state_flag=1) OR (tpd_curstate_flag_2_quals=1)) )
        SET tpd_curstate_log_type = "REFCHG"
       ELSE
        SET tpd_curstate_log_type = tpd_log_type
       ENDIF
       IF ((tpd_pkw_rs->qual[tpd_idx].skip_filter_ind != 1))
        SET tpd_all_filtered = 0
       ENDIF
       SET tpd_status = call_ins_dcl(tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pk_where,
        tpd_curstate_log_type,tpd_delete_ind,reqinfo->updt_id,
        reqinfo->updt_task,reqinfo->updt_applctx,tpd_context,dm2_ref_data_doc->env_target_id,
        tpd_sp_log_id,
        dm2_ref_data_doc->post_link_name,tpd_pk_where_hash,dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].
        ptam_match_hash)
       IF (tpd_status="F")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF (tpd_log_id=0
        AND ((tpd_cur_state_flag=1) OR (tpd_curstate_flag_2_quals=1)) )
        SELECT INTO "nl:"
         tpd_val = seq(rdds_source_clinical_seq,currval)
         FROM dual
         DETAIL
          tpd_currval = tpd_val
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
        SET tpd_pk_where = concat(tpd_pk_where," AND ",tpd_pk_str)
        SET tpd_status = call_ins_dcl(tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pk_where,tpd_log_type,
         tpd_delete_ind,reqinfo->updt_id,
         reqinfo->updt_task,reqinfo->updt_applctx,tpd_context,dm2_ref_data_doc->env_target_id,
         tpd_sp_log_id,
         dm2_ref_data_doc->post_link_name,tpd_pk_where_hash,dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].
         ptam_match_hash)
        IF (tpd_status="F")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
       ENDIF
       SELECT INTO "nl:"
        tpd_val = seq(rdds_source_clinical_seq,currval)
        FROM dual
        DETAIL
         tpd_new_currval = tpd_val
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF (tpd_new_currval=tpd_currval)
        DECLARE dm_get_hash_value() = f8
        SELECT INTO "nl:"
         pkw_value = dm_get_hash_value(tpd_pk_where,0,1073741824.0)
         FROM dual
         DETAIL
          tpd_pkw_value = pkw_value
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
        SET tpd_dcl_tab = dm2_get_rdds_tname("DM_CHG_LOG")
        SET dm_err->eproc = "Searching for single pass DCL row."
        IF (tpd_context="")
         SET tpd_context_str = "d.context_name is null"
        ELSE
         SET tpd_context_str = "d.context_name = tpd_context"
        ENDIF
        IF (tpd_log_type="REFCHG")
         SET tpd_log_type_str = "d.log_type IN ('REFCHG','NORDDS')"
        ELSE
         SET tpd_log_type_str = "d.log_type IN('REFCHG','PROCES','NORDDS')"
        ENDIF
        SELECT INTO "nl:"
         d.log_id
         FROM (parser(tpd_dcl_tab) d)
         WHERE (d.table_name=tpd_pkw_rs->qual[tpd_idx].table_name)
          AND d.delete_ind=tpd_delete_ind
          AND ((d.target_env_id+ 0)=dm2_ref_data_doc->env_target_id)
          AND parser(tpd_context_str)
          AND d.pk_where=tpd_pk_where
          AND parser(tpd_log_type_str)
          AND d.pk_where_value=tpd_pkw_value
         DETAIL
          tpd_new_log_id = d.log_id
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
       ELSE
        SET tpd_new_log_id = tpd_new_currval
        SET tpd_currval = tpd_new_currval
       ENDIF
       IF (tpd_log_id > 0.0)
        IF (tpd_ins_cnt=0)
         SET tpd_reason_str = concat(tpd_reason_str," ",trim(cnvtstring(tpd_new_log_id,20)))
        ELSE
         SET tpd_reason_str = concat(tpd_reason_str,",",trim(cnvtstring(tpd_new_log_id,20)))
        ENDIF
        SET tpd_ins_cnt = (tpd_ins_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (tpd_all_filtered=1)
    RETURN(- (4.0))
   ELSE
    IF (tpd_sp_log_id=0.0)
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = tpd_reason_str
    ENDIF
    RETURN(tpd_new_log_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE reset_exceptions(re_tab_name,re_tgt_env_id,re_from_value,re_data)
   DECLARE re_dcle_name = vc WITH protect, noconstant("")
   DECLARE re_dcl_name = vc WITH protect, noconstant("")
   DECLARE re_xcptn_id = f8 WITH protect, noconstant(0.0)
   DECLARE re_tab_str = vc WITH protect, noconstant("")
   DECLARE re_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE re_idx = i4 WITH protect, noconstant(0)
   DECLARE re_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE re_where_str = vc WITH protect, noconstant(" ")
   DECLARE re_loop = i4 WITH protect, noconstant(0)
   DECLARE re_new_loop = i4 WITH protect, noconstant(0)
   DECLARE re_orig_tab = vc WITH protect, noconstant("")
   DECLARE re_circ_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE re_last_pe_name = vc WITH protect, noconstant("")
   DECLARE re_circ_name_pos = i4 WITH protect, noconstant(0)
   DECLARE re_log_type_str = vc WITH protect, noconstant("")
   FREE RECORD re_multi
   RECORD re_multi(
     1 cnt = i4
     1 qual[*]
       2 dcle_id = f8
   )
   SET re_dcle_name = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET re_orig_tab = re_tab_name
   IF (re_tab_name IN ("PERSON", "PRSNL"))
    SET re_tab_str = "d.table_name IN('PERSON','PRSNL')"
   ELSE
    SET re_tab_str = "d.table_name = re_tab_name"
   ENDIF
   SET dm_err->eproc = "Querying for dm_chg_log_exception row."
   SELECT INTO "nl:"
    FROM (parser(re_dcle_name) d)
    WHERE parser(re_tab_str)
     AND d.log_type != "DELETE"
     AND d.target_env_id=re_tgt_env_id
     AND d.from_value=re_from_value
    DETAIL
     re_xcptn_id = d.dm_chg_log_exception_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(0)
   ENDIF
   IF (re_xcptn_id > 0.0)
    SET dm_err->eproc = "Calling dm_rmc_find_dcl_xcptn"
    SET stat = initrec(drfdx_reply)
    SET drfdx_request->exclude_str = ""
    FOR (re_circ_loop = 1 TO re_data->cnt)
      IF ((drfdx_request->exclude_str=""))
       SET drfdx_request->exclude_str = concat(" table_name not in ('",re_data->qual[re_circ_loop].
        circ_table_name,"'")
      ELSE
       SET re_circ_name_pos = findstring(concat("'",re_data->qual[re_circ_loop].circ_table_name,"'"),
        drfdx_request->exclude_str,1,0)
       IF (re_circ_name_pos=0)
        SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,", '",re_data->qual[
         re_circ_loop].circ_table_name,"'")
       ENDIF
      ENDIF
    ENDFOR
    IF (findstring(",",drfdx_request->exclude_str,1,0)=0)
     SET drfdx_request->exclude_str = ""
    ELSE
     SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,")")
    ENDIF
    SET drfdx_request->exception_id = re_xcptn_id
    SET drfdx_request->target_env_id = re_tgt_env_id
    SET drfdx_request->db_link = dm2_ref_data_doc->post_link_name
    EXECUTE dm_rmc_find_dcl_xcptn  WITH replace("REQUEST","DRFDX_REQUEST"), replace("REPLY",
     "DRFDX_REPLY")
    IF ((drfdx_reply->err_ind=1))
     CALL disp_msg(drfdx_reply->emsg,dm_err->logfile,drfdx_reply->err_ind)
     SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = drfdx_reply->emsg
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Resetting related dm_chg_log rows to REFCHG."
    SET re_dcl_name = dm2_get_rdds_tname("DM_CHG_LOG")
    IF ((drfdx_reply->total > 0))
     UPDATE  FROM (parser(re_dcl_name) d),
       (dummyt d2  WITH seq = value(drfdx_reply->total))
      SET d.log_type = "REFCHG", d.dm_chg_log_exception_id = 0.0, d.chg_log_reason_txt = "",
       d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      PLAN (d2
       WHERE (drfdx_reply->row[d2.seq].current_context_ind=1))
       JOIN (d
       WHERE (d.log_id=drfdx_reply->row[d2.seq].log_id))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((global_mover_rec->circ_nomv_excl_cnt=0))
    SET re_log_type_str = "e.log_type != 'DELETE'"
   ELSE
    FOR (re_circ_loop = 1 TO global_mover_rec->circ_nomv_excl_cnt)
      IF (re_circ_loop=1)
       SET re_log_type_str = concat("e.log_type in ('",global_mover_rec->circ_nomv_qual[re_circ_loop]
        .log_type,"'")
      ELSE
       SET re_log_type_str = concat(re_log_type_str,",'",global_mover_rec->circ_nomv_qual[
        re_circ_loop].log_type,"'")
      ENDIF
    ENDFOR
    SET re_log_type_str = concat(re_log_type_str,")")
   ENDIF
   FOR (re_circ_loop = 1 TO re_data->cnt)
     SET re_multi->cnt = 0
     SET stat = alterlist(re_multi->qual,0)
     SET dm_err->eproc = "Querying for circular dm_chg_log_exception row."
     FOR (re_loop = 1 TO re_data->qual[re_circ_loop].circ_val_cnt)
       IF (re_loop=1)
        SET re_where_str = " e.from_value in ("
       ELSE
        SET re_where_str = concat(re_where_str,", ")
       ENDIF
       SET re_where_str = concat(re_where_str,trim(cnvtstring(re_data->qual[re_circ_loop].
          circ_val_qual[re_loop].circ_value,20,1)))
       IF ((re_loop=re_data->qual[re_circ_loop].circ_val_cnt))
        SET re_where_str = concat(re_where_str,")")
       ENDIF
     ENDFOR
     IF ((re_data->qual[re_circ_loop].circ_val_cnt > 0))
      IF ((re_data->qual[re_circ_loop].excptn_cnt > 0))
       SELECT INTO "nl:"
        FROM (parser(re_dcle_name) e)
        WHERE (e.table_name=re_data->qual[re_circ_loop].circ_table_name)
         AND (e.column_name=re_data->qual[re_circ_loop].circ_root_col)
         AND parser(re_log_type_str)
         AND e.target_env_id=re_tgt_env_id
         AND parser(re_where_str)
         AND  NOT (expand(re_new_loop,1,re_data->qual[re_circ_loop].excptn_cnt,e.from_value,re_data->
         qual[re_circ_loop].excptn_qual[re_new_loop].value))
        DETAIL
         re_multi->cnt = (re_multi->cnt+ 1), stat = alterlist(re_multi->qual,re_multi->cnt), re_multi
         ->qual[re_multi->cnt].dcle_id = e.dm_chg_log_exception_id
        WITH nocounter
       ;end select
      ELSE
       SELECT INTO "nl:"
        FROM (parser(re_dcle_name) e)
        WHERE (e.table_name=re_data->qual[re_circ_loop].circ_table_name)
         AND (e.column_name=re_data->qual[re_circ_loop].circ_root_col)
         AND parser(re_log_type_str)
         AND e.target_env_id=re_tgt_env_id
         AND parser(re_where_str)
        DETAIL
         re_multi->cnt = (re_multi->cnt+ 1), stat = alterlist(re_multi->qual,re_multi->cnt), re_multi
         ->qual[re_multi->cnt].dcle_id = e.dm_chg_log_exception_id
        WITH nocounter
       ;end select
      ENDIF
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
       RETURN(0)
      ENDIF
     ENDIF
     SET re_circ_tab_pos = locateval(re_circ_tab_pos,1,dm2_ref_data_doc->tbl_cnt,re_data->qual[
      re_circ_loop].circ_table_name,dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].table_name)
     SET drfdx_request->exclude_str = ""
     SET re_last_pe_name = ""
     FOR (re_loop = 1 TO dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circular_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].circular_type=2))
        IF ((dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].pe_name_col !=
        re_last_pe_name))
         SET re_last_pe_name = dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].
         pe_name_col
         IF ((drfdx_request->exclude_str=""))
          SET drfdx_request->exclude_str = concat(" table_name not in ('",dm2_ref_data_doc->tbl_qual[
           re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
         ELSE
          SET re_circ_name_pos = findstring(concat("'",dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].
            circ_qual[re_loop].circ_table_name,"'"),drfdx_request->exclude_str,1,0)
          IF (re_circ_name_pos=0)
           SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,", '",dm2_ref_data_doc
            ->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
          ENDIF
         ENDIF
        ENDIF
       ELSE
        IF ((drfdx_request->exclude_str=""))
         SET drfdx_request->exclude_str = concat(" table_name not in ('",dm2_ref_data_doc->tbl_qual[
          re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
        ELSE
         SET re_circ_name_pos = findstring(concat("'",dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].
           circ_qual[re_loop].circ_table_name,"'"),drfdx_request->exclude_str,1,0)
         IF (re_circ_name_pos=0)
          SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,", '",dm2_ref_data_doc->
           tbl_qual[re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF (findstring(",",drfdx_request->exclude_str,1,0)=0)
      SET drfdx_request->exclude_str = ""
     ELSE
      SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,")")
     ENDIF
     FOR (re_loop = 1 TO re_multi->cnt)
       IF ((re_multi->qual[re_loop].dcle_id > 0.0))
        SET dm_err->eproc = "Calling dm_rmc_find_dcl_xcptn"
        SET stat = initrec(drfdx_reply)
        SET drfdx_request->exception_id = re_multi->qual[re_loop].dcle_id
        SET drfdx_request->target_env_id = re_tgt_env_id
        SET drfdx_request->db_link = dm2_ref_data_doc->post_link_name
        EXECUTE dm_rmc_find_dcl_xcptn  WITH replace("REQUEST","DRFDX_REQUEST"), replace("REPLY",
         "DRFDX_REPLY")
        IF ((drfdx_reply->err_ind=1))
         CALL disp_msg(drfdx_reply->emsg,dm_err->logfile,drfdx_reply->err_ind)
         SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = drfdx_reply->emsg
         RETURN(0)
        ENDIF
        SET dm_err->eproc = "Resetting related dm_chg_log rows to REFCHG."
        SET re_dcl_name = dm2_get_rdds_tname("DM_CHG_LOG")
        IF ((drfdx_reply->total > 0))
         UPDATE  FROM (parser(re_dcl_name) d),
           (dummyt d2  WITH seq = value(drfdx_reply->total))
          SET d.log_type = "REFCHG", d.dm_chg_log_exception_id = 0.0, d.chg_log_reason_txt = "",
           d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          PLAN (d2
           WHERE (drfdx_reply->row[d2.seq].current_context_ind=1))
           JOIN (d
           WHERE (d.log_id=drfdx_reply->row[d2.seq].log_id))
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
          SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_concurrent_snapshot(sbr_ccs_mode,sbr_ccs_cur_appl_id)
   DECLARE ccs_appl_id = vc WITH protect, noconstant(" ")
   DECLARE ccs_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(sbr_ccs_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      ccs_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF (ccs_appl_id=sbr_ccs_cur_appl_id)
      SET dm_err->eproc = "Deleting concurrency row from dm_info - same application is restart mode."
      CALL disp_msg(" ",dm_err->logfile,0)
      DELETE  FROM dm_info di
       WHERE di.info_domain="DM2 INSTALL PROCESS"
        AND di.info_name="CONCURRENCY CHECKPOINT"
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ELSE
      SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
      CALL disp_msg(" ",dm_err->logfile,0)
      SET ccs_appl_status = dm2_get_appl_status(ccs_appl_id)
      IF (ccs_appl_status="E")
       RETURN(0)
      ELSE
       IF (ccs_appl_status="A")
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Another upgrade process is currently taking a schema snapshot."
        SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
        SET dm_err->user_action = "Please wait until other process completes and try again."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        SET dm_err->eproc = "Deleting concurrency row from dm_info - process inactive."
        CALL disp_msg(" ",dm_err->logfile,0)
        DELETE  FROM dm_info di
         WHERE di.info_domain="DM2 INSTALL PROCESS"
          AND di.info_name="CONCURRENCY CHECKPOINT"
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = sbr_ccs_cur_appl_id,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
      di.updt_id = 0, di.updt_task = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Deleting concurrency row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (cnvtupper(gas_appl_id)="-15301")
    RETURN(gas_active_status)
   ENDIF
   SELECT INTO "nl:"
    FROM gv$session s
    WHERE s.audsid=cnvtint(gas_appl_id)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine DM2_GET_APPL_STATUS")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(gas_error_status)
   ELSEIF (curqual=0)
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual > 0)
     RETURN(gas_active_status)
    ELSE
     RETURN(gas_inactive_status)
    ENDIF
   ELSE
    RETURN(gas_active_status)
   ENDIF
 END ;Subroutine
 SUBROUTINE load_grouper(lg_cnt,lg_log_type,lg_chg_cnt)
   DECLARE lg_alias = vc WITH protect, noconstant("")
   DECLARE lg_loop = i4 WITH protect, noconstant(0)
   DECLARE lg_src_fv = vc WITH protect, noconstant("")
   DECLARE lg_temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE lg_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE lg_d_cnt = i4 WITH protect, noconstant(0)
   DECLARE lg_log_type_idx = i4 WITH protect, noconstant(0)
   SET lg_src_fv = dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lg_cnt].table_name)
   SET lg_alias = concat(" t",dm2_ref_data_doc->tbl_qual[lg_cnt].suffix)
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 trailing_space_ind = i2")
   CALL parser(" 1 qual[*]",0)
   FOR (lg_loop = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].exception_flg=12))
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         " = ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type),0)
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         "_NULLIND = i2 "),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
          "_LEN = i4 "),0)
       ENDIF
      ENDIF
     ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].unique_ident_ind=1))
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         " = ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type),0)
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         "_NULLIND = i2 "),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
          "_LEN = i4 "),0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET lg_temp_cnt = 0
   CALL parser("select into 'nl:'",0)
   FOR (lg_loop = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].exception_flg=12))
       IF (lg_temp_cnt > 0)
        CALL parser(" , ",0)
       ENDIF
       SET lg_temp_cnt = (lg_temp_cnt+ 1)
       CALL parser(concat("var",cnvtstring(lg_loop)," = nullind(",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(", ts",cnvtstring(lg_loop)," = length(",lg_alias,".",
          dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       ENDIF
      ENDIF
     ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].unique_ident_ind=1))
       IF (lg_temp_cnt > 0)
        CALL parser(" , ",0)
       ENDIF
       SET lg_temp_cnt = (lg_temp_cnt+ 1)
       CALL parser(concat("var",cnvtstring(lg_loop)," = nullind(",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(", ts",cnvtstring(lg_loop)," = length(",lg_alias,".",
          dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(concat(" from  ",lg_src_fv," ",lg_alias),0)
   CALL parser(drdm_chg->log[lg_chg_cnt].pk_where,0)
   CALL parser("head report cust_cs_rows->trailing_space_ind = 1",0)
   CALL parser(
    " detail lg_qual_cnt = lg_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, lg_qual_cnt) ",0)
   FOR (lg_loop = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].exception_flg=12))
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name," = ",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name),0)
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name,"_NULLIND = var",trim(cnvtstring(lg_loop))),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
          col_qual[lg_loop].column_name,"_LEN = ts",trim(cnvtstring(lg_loop))),0)
       ENDIF
      ENDIF
     ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].unique_ident_ind=1))
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name," = ",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name),0)
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name,"_NULLIND = var",trim(cnvtstring(lg_loop))),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
          col_qual[lg_loop].column_name,"_LEN = ts",trim(cnvtstring(lg_loop))),0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(" with nocounter, notrim go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG5"))
    SET lms_pk_where = drdm_create_pk_where(lg_qual_cnt,lg_cnt,"ALG5")
   ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
    SET lms_pk_where = drdm_create_pk_where(lg_qual_cnt,lg_cnt,"UI")
   ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG7"))
    SET lms_pk_where = drdm_create_pk_where(lg_qual_cnt,lg_cnt,"ALG7")
   ENDIF
   IF (lms_pk_where="")
    CALL disp_msg("There was an error creating the PK_WHERE string",dm_err->logfile,0)
    SET dm_err->err_ind = 1
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",lg_src_fv,lg_alias),0)
    CALL parser(concat(lms_pk_where," detail"),0)
    FOR (lms_lp_cnt = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].root_entity_attr=dm2_ref_data_doc
      ->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].root_entity_name=dm2_ref_data_doc
      ->tbl_qual[lg_cnt].table_name))
       CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
       CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
       CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
         table_name,"'"),0)
       CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt]
         .col_qual[lms_lp_cnt].column_name,"'"),0)
       CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
         tbl_qual[lg_cnt].col_qual[lms_lp_cnt].column_name),0)
      ENDIF
    ENDFOR
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",lg_src_fv,lg_alias),0)
    CALL parser(lms_pk_where,0)
    CALL parser(concat(" and ",lg_alias,".active_ind = 1 and ",lg_alias,".",
      dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
    CALL parser(concat(" and ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
      " >= cnvtdatetime(curdate,curtime3)"),0)
    CALL parser(" detail ",0)
    CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
    CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      table_name,"'"),0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      root_col_name,"'"),0)
    CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->tbl_qual[
      lg_cnt].root_col_name),0)
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 1 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(concat(" order by ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
       " desc "),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim, maxrec = 1 go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 0 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(concat(" and ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
       " >= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 0 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(concat(" order by ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
       " desc "),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim, maxrec = 1 go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",lg_src_fv,lg_alias),0)
    CALL parser(lms_pk_where,0)
    CALL parser(concat(" and ",lg_alias,".active_ind = 1 and ",lg_alias,".",
      dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," >= cnvtdatetime(curdate,curtime3)"),0)
    CALL parser(" detail ",0)
    CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
    CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      table_name,"'"),0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      root_col_name,"'"),0)
    CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->tbl_qual[
      lg_cnt].root_col_name),0)
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 0 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," >= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   SET lms_fv->fv_cnt = lg_d_cnt
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(lms_fv)
   ENDIF
   FOR (lms_lp_pp = 1 TO lg_d_cnt)
     CALL orphan_child_tab(lms_fv->list[lms_lp_pp].table_name,lg_log_type,lms_fv->list[lms_lp_pp].
      column_name,lms_fv->list[lms_lp_pp].from_value)
     COMMIT
     IF (locateval(lg_log_type_idx,1,global_mover_rec->circ_nomv_excl_cnt,lg_log_type,
      global_mover_rec->circ_nomv_qual[lg_log_type_idx].log_type)=0)
      CALL drcm_block_ptam_circ(dm2_ref_data_doc,lg_cnt,lms_fv->list[lms_lp_pp].column_name,lms_fv->
       list[lms_lp_pp].from_value)
      IF ((dm_err->err_ind=1))
       RETURN(- (1))
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE remove_cached_xlat(rcx_tab_name,rcx_from_value)
   DECLARE rcx_sql_call = vc
   SET rcx_sql_call = concat("begin rdds_xlat.remove_cache_item('",rcx_tab_name,"', ",cnvtstring(
     rcx_from_value,20),"); end;")
   CALL parser(concat("RDB ASIS(^",rcx_sql_call,"^) go"),1)
   IF (check_error("Error removing cached xlat") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_xlat_ctxt_r(axc_tab_name,axc_from_value,axc_to_value,axc_ctxt)
   DECLARE axc_found_ind = i2 WITH protect, noconstant(0)
   DECLARE axc_ctxt_found_ind = i2 WITH protect, noconstant(0)
   DECLARE axc_retry_cnt = i4 WITH protect, noconstant(0)
   DECLARE axc_retry_limit = i4 WITH protect, constant(4)
   WHILE (axc_retry_cnt <= axc_retry_limit)
     SET axc_found_ind = 0
     SET axc_ctxt_found_ind = 0
     SELECT INTO "NL:"
      FROM dm_refchg_xlat_ctxt_r r
      WHERE r.table_name=axc_tab_name
       AND r.from_value=axc_from_value
       AND r.to_value=axc_to_value
      DETAIL
       axc_found_ind = 1
       IF (r.context_name=axc_ctxt)
        axc_ctxt_found_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("Error querying DM_REFCHG_XLAT_CTXT_R") != 0)
      SET axc_retry_cnt = (axc_retry_limit+ 1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
     IF (axc_found_ind=1
      AND axc_ctxt_found_ind=0)
      INSERT  FROM dm_refchg_xlat_ctxt_r r
       SET dm_refchg_xlat_ctxt_r_id = seq(dm_clinical_seq,nextval), r.table_name = axc_tab_name, r
        .from_value = axc_from_value,
        r.to_value = axc_to_value, r.context_name = axc_ctxt
       WITH nocounter
      ;end insert
      IF (check_error("Error querying DM_REFCHG_XLAT_CTXT_R") != 0)
       IF (axc_retry_cnt <= axc_retry_limit
        AND ((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) >
       0)) )
        SET dm_err->user_action =
        "No action required.  Retrying ADD_XLAT_CTXT_R logic because of constraint violation."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->user_action = ""
        SET dm_err->err_ind = 0
        SET axc_retry_cnt = (axc_retry_cnt+ 1)
       ELSE
        SET axc_retry_cnt = (axc_retry_limit+ 1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(1)
       ENDIF
      ELSE
       SET axc_retry_cnt = (axc_retry_limit+ 1)
      ENDIF
     ELSE
      SET axc_retry_cnt = (axc_retry_limit+ 1)
     ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcm_block_ptam_circ(dbp_rec,dbp_tbl_cnt,dbp_pk_col,dbp_pk_col_value)
   DECLARE dbp_idx_pos = i4 WITH protect, noconstant(0)
   DECLARE dbp_last_col_name = vc WITH protect, noconstant("")
   DECLARE dbp_last_col_value = vc WITH protect, noconstant("")
   DECLARE dbp_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE dbp_to_value = f8 WITH protect, noconstant(0)
   DECLARE dbp_temp_tab = i4 WITH protect, noconstant(0)
   SET dbp_to_value = drcm_get_xlat(cnvtstring(dbp_pk_col_value,20,1),dbp_rec->tbl_qual[dbp_tbl_cnt].
    table_name)
   IF (check_error("Error looking for translation in DRCM_BLOCK_PTAM_CIRC") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (dbp_to_value < 0.0)
    RETURN(null)
   ENDIF
   FOR (dbp_circ_loop = 1 TO dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_cnt)
    IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].other_name_col > " "))
     IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].other_id_col !=
     dbp_last_col_name))
      SET dbp_last_col_name = dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
      other_id_col
      CALL parser(concat("set dbp_last_col_value = RS_",dbp_rec->tbl_qual[dbp_tbl_cnt].suffix,
        "->from_values.",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].other_name_col,
        " go"),1)
      SELECT INTO "NL"
       y = evaluate_pe_name(dbp_rec->tbl_qual[dbp_tbl_cnt].table_name,dbp_rec->tbl_qual[dbp_tbl_cnt].
        other_circ_qual[dbp_circ_loop].other_id_col,dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[
        dbp_circ_loop].other_name_col,dbp_last_col_value)
       FROM dual
       DETAIL
        dbp_last_col_value = y
       WITH nocounter
      ;end select
      IF (check_error("Error calling EVALUATE_PE_NAME") != 0)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(null)
      ENDIF
     ENDIF
     IF ((dbp_last_col_value=dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7tab_name)
     )
      SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_last_col_value,dbp_rec->
       tbl_qual[dbp_idx_pos].table_name)
      IF (dbp_idx_pos=0)
       SET dbp_temp_tab = temp_tbl_cnt
       SET dbp_idx_pos = fill_rs("TABLE",dbp_last_col_value)
       SET temp_tbl_cnt = dbp_temp_tab
       IF ((dbp_idx_pos=- (1)))
        CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
        ROLLBACK
        SET dm_err->err_ind = 1
        RETURN(null)
       ELSEIF ((dbp_idx_pos=- (2)))
        SET drmm_ddl_rollback_ind = 1
        SET dm_err->err_ind = 1
        RETURN(null)
       ELSE
        SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_last_col_value,dbp_rec->
         tbl_qual[dbp_idx_pos].table_name)
       ENDIF
      ENDIF
      CALL parser(concat("delete from ",dbp_rec->tbl_qual[dbp_idx_pos].r_table_name," d"),0)
      CALL parser(concat("where d.",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
        7id_col," = dbp_to_value"),0)
      IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col > " "))
       CALL parser(concat(" and evaluate_pe_name('",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[
         dbp_circ_loop].7tab_name,"','",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop]
         .7id_col,"','",
         dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,"',d.",dbp_rec->
         tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,
         ") = dbp_rec->tbl_qual[dbp_tbl_cnt].table_name"),0)
      ENDIF
      CALL parser("with nocounter go",1)
     ENDIF
    ELSE
     SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_rec->tbl_qual[dbp_tbl_cnt].
      other_circ_qual[dbp_circ_loop].7tab_name,dbp_rec->tbl_qual[dbp_idx_pos].table_name)
     IF (dbp_idx_pos=0)
      SET dbp_temp_tab = temp_tbl_cnt
      SET dbp_idx_pos = fill_rs("TABLE",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop]
       .7tab_name)
      SET temp_tbl_cnt = dbp_temp_tab
      IF ((dbp_idx_pos=- (1)))
       CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
       ROLLBACK
       SET dm_err->err_ind = 1
       RETURN(null)
      ELSEIF ((dbp_idx_pos=- (2)))
       SET drmm_ddl_rollback_ind = 1
       SET dm_err->err_ind = 1
       RETURN(null)
      ELSE
       SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_rec->tbl_qual[dbp_tbl_cnt].
        other_circ_qual[dbp_circ_loop].7tab_name,dbp_rec->tbl_qual[dbp_idx_pos].table_name)
      ENDIF
     ENDIF
     CALL parser(concat("delete from ",dbp_rec->tbl_qual[dbp_idx_pos].r_table_name," d"),0)
     CALL parser(concat("where d.",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
       7id_col," = dbp_to_value"),0)
     IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col > " "))
      CALL parser(concat(" and evaluate_pe_name('",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[
        dbp_circ_loop].7tab_name,"','",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
        7id_col,"','",
        dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,"',d.",dbp_rec->
        tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,
        ") = dbp_rec->tbl_qual[dbp_tbl_cnt].table_name"),0)
     ENDIF
     CALL parser("with nocounter go",1)
    ENDIF
    IF (check_error("Error removing circular $R row") != 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
   ENDFOR
   COMMIT
 END ;Subroutine
 SUBROUTINE drcm_get_pk_str(dgps_rec,dgps_tab_name)
   DECLARE dgps_tab_idx = i4 WITH protect, noconstant(0)
   DECLARE dgps_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgps_col_val = vc WITH protect, noconstant("")
   DECLARE dgps_ret_str = vc WITH protect, noconstant("")
   SET dgps_tab_idx = locateval(dgps_tab_idx,1,dgps_rec->tbl_cnt,dgps_tab_name,dgps_rec->tbl_qual[
    dgps_tab_idx].table_name)
   FOR (dgps_col_loop = 1 TO dgps_rec->tbl_qual[dgps_tab_idx].col_cnt)
     IF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].pk_ind=1))
      IF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].check_null=1))
       SET dgps_col_val = "<NULL>"
      ELSE
       IF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].data_type="DQ8"))
        CALL parser(concat("set dgps_col_val=format(cnvtdatetime(RS_",dgps_rec->tbl_qual[dgps_tab_idx
          ].suffix,"->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].
          column_name,"), ';;Q') go"),1)
       ELSEIF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].data_type="F8"))
        CALL parser(concat("set dgps_col_val = cnvtstring(RS_",dgps_rec->tbl_qual[dgps_tab_idx].
          suffix,"->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].
          column_name,", 20,1) go"),1)
       ELSEIF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].data_type="I*"))
        CALL parser(concat("set dgps_col_val = cnvtstring(RS_",dgps_rec->tbl_qual[dgps_tab_idx].
          suffix,"->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].
          column_name,") go"),1)
       ELSE
        CALL parser(concat("set dgps_col_val = RS_",dgps_rec->tbl_qual[dgps_tab_idx].suffix,
          "->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].column_name," go"
          ),1)
       ENDIF
      ENDIF
      IF (dgps_ret_str <= " ")
       SET dgps_ret_str = concat("The primary key values of this row are: ",dgps_rec->tbl_qual[
        dgps_tab_idx].col_qual[dgps_col_loop].column_name,"=",dgps_col_val)
      ELSE
       SET dgps_ret_str = concat(dgps_ret_str,", ",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[
        dgps_col_loop].column_name,"=",dgps_col_val)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(dgps_ret_str)
 END ;Subroutine
 DECLARE upd_pkw_vers_tab(i_table_name=vc,i_table_suffix=vc) = vc
 DECLARE get_bad_pkw_vers(i_target_id=f8,i_log_id=f8,o_data_rs=vc(ref)) = vc
 DECLARE correct_dcl_pkw_vers(i_target_env_id=f8,i_log_id=f8) = vc
 SUBROUTINE upd_pkw_vers_tab(i_table_name,i_table_suffix)
   FREE RECORD upvt_list
   RECORD upvt_list(
     1 data[*]
       2 table_name = vc
       2 table_suffix = vc
       2 pkw_function = vc
       2 pkw_iu_str = vc
       2 pkw_del_str = vc
       2 pkw_declare = vc
       2 pkw_check_ind = i2
       2 pkw[*]
         3 parm_name = vc
         3 parm_data_type = vc
   )
   DECLARE upvt_count = i4
   DECLARE tbl_where_str = vc
   DECLARE upvt_loop = i4
   DECLARE upvt_loop_parm = i4
   DECLARE upvt_sub_return = vc
   DECLARE idx = i4
   DECLARE upvt_pkw = vc
   DECLARE upvt_pkw_return = vc
   SET dm_err->eproc = "Obtaining list of reference tables that have REFCHG_PK_WHERE function"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(i_table_name)=char(42))
    SELECT INTO "nl:"
     FROM user_triggers ut
     WHERE ((ut.trigger_name="REFCHG*ADD") OR (ut.trigger_name="REFCHG*ADD$C"))
     HEAD REPORT
      ut_count = 0
     DETAIL
      ut_count = (ut_count+ 1)
      IF (mod(ut_count,100)=1)
       stat = alterlist(upvt_list->data,(ut_count+ 99))
      ENDIF
      upvt_list->data[ut_count].table_name = ut.table_name, upvt_list->data[ut_count].table_suffix =
      substring(7,4,ut.trigger_name)
     FOOT REPORT
      stat = alterlist(upvt_list->data,ut_count)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
   ELSE
    SET stat = alterlist(upvt_list->data,1)
    SET upvt_list->data[1].table_name = i_table_name
    SET upvt_list->data[1].table_suffix = i_table_suffix
   ENDIF
   FOR (upvt_loop = 1 TO size(upvt_list->data,5))
    SET upvt_sub_return = pk_where_info(upvt_list->data[upvt_loop].table_name,upvt_list->data[
     upvt_loop].table_suffix,concat("t",trim(upvt_list->data[upvt_loop].table_suffix)),"",upvt_list)
    IF (trim(upvt_list->data[upvt_loop].pkw_function) > "")
     CALL parser(upvt_list->data[upvt_loop].pkw_declare,1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN("F")
     ENDIF
     SET dm_err->eproc = "Obtaining data types for the  REFCHG_PK_WHERE parameters"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM user_tab_columns utc
      WHERE (utc.table_name=upvt_list->data[upvt_loop].table_name)
       AND expand(idx,1,size(upvt_list->data[upvt_loop].pkw,5),utc.column_name,upvt_list->data[
       upvt_loop].pkw[idx].parm_name)
      DETAIL
       utc_count = 0
       FOR (utc_count = 1 TO size(upvt_list->data[upvt_loop].pkw,5))
         IF ((upvt_list->data[upvt_loop].pkw[utc_count].parm_name=utc.column_name))
          upvt_list->data[upvt_loop].pkw[utc_count].parm_data_type = utc.data_type
         ENDIF
       ENDFOR
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN("F")
     ENDIF
     FOR (upvt_loop_parm = 1 TO size(upvt_list->data[upvt_loop].pkw,5))
       IF ((upvt_list->data[upvt_loop].pkw[upvt_loop_parm].parm_data_type IN ("NUMBER", "FLOAT")))
        IF (upvt_loop_parm=1)
         SET upvt_pkw = concat(upvt_list->data[upvt_loop].pkw_function,"('INS/UPD',0")
        ELSE
         SET upvt_pkw = concat(upvt_pkw,",0")
        ENDIF
       ELSEIF ((upvt_list->data[upvt_loop].pkw[upvt_loop_parm].parm_data_type IN ("CHAR", "VARCHAR2")
       ))
        IF (upvt_loop_parm=1)
         SET upvt_pkw = concat(upvt_list->data[upvt_loop].pkw_function,"('INS/UPD','A'")
        ELSE
         SET upvt_pkw = concat(upvt_pkw,",'A'")
        ENDIF
       ELSEIF ((upvt_list->data[upvt_loop].pkw[upvt_loop_parm].parm_data_type="DATE"))
        IF (upvt_loop_parm=1)
         SET upvt_pkw = concat(upvt_list->data[upvt_loop].pkw_function,
          "('INS/UPD',cnvtdatetime('31-DEC-2100 00:00:00')")
        ELSE
         SET upvt_pkw = concat(upvt_pkw,",cnvtdatetime('31-DEC-2100 00:00:00')")
        ENDIF
       ENDIF
     ENDFOR
     SET upvt_pkw = concat(upvt_pkw,")")
     SET dm_err->eproc = "Obtaining result from the  REFCHG_PK_WHERE function"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      result1 = parser(upvt_pkw)
      FROM dual
      DETAIL
       upvt_pkw_return = result1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN("F")
     ENDIF
     SET dm_err->eproc = "Comparing new pk_where vs dm_refchg_pkw_vers"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm_refchg_pkw_vers dr
      WHERE (dr.table_name=upvt_list->data[upvt_loop].table_name)
       AND dr.active_ind=1
       AND dr.pkw_format=upvt_pkw_return
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN("F")
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_refchg_pkw_vers drpv
       SET drpv.dm_refchg_pkw_vers_id = seq(dm_clinical_seq,nextval), drpv.table_name = upvt_list->
        data[upvt_loop].table_name, drpv.pkw_format = upvt_pkw_return,
        drpv.active_ind = 1, drpv.updt_dt_tm = cnvtdatetime(curdate,curtime3), drpv.updt_task =
        reqinfo->updt_task,
        drpv.updt_cnt = 0, drpv.updt_id = reqinfo->updt_id, drpv.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       RETURN("F")
      ELSE
       UPDATE  FROM dm_refchg_pkw_vers drpv
        SET drpv.active_ind = 0, drpv.updt_task = reqinfo->updt_task, drpv.updt_cnt = (drpv.updt_cnt
         + 1),
         drpv.updt_applctx = reqinfo->updt_applctx, drpv.updt_id = reqinfo->updt_id, drpv.updt_dt_tm
          = cnvtdatetime(curdate,curtime3)
        WHERE (drpv.table_name=upvt_list->data[upvt_loop].table_name)
         AND drpv.active_ind=1
         AND drpv.pkw_format != upvt_pkw_return
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        ROLLBACK
        RETURN("F")
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   IF (trim(i_table_name)=char(42))
    SET dm_err->eproc = "Writing out DM_INFO row because we validated PKW for all tables"
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetime(curdate,curtime3), di.updt_task = reqinfo->updt_task, di
      .updt_cnt = (di.updt_cnt+ 1),
      di.updt_applctx = reqinfo->updt_applctx, di.updt_id = reqinfo->updt_id, di.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WHERE di.info_domain="RDDS INFO"
      AND di.info_name="LAST DM_REFCHG_PKW_VERS UPDATE"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_domain = "RDDS INFO", di.info_name
        = "LAST DM_REFCHG_PKW_VERS UPDATE",
       di.updt_task = reqinfo->updt_task, di.updt_cnt = 0, di.updt_applctx = reqinfo->updt_applctx,
       di.updt_id = reqinfo->updt_id, di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN("F")
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD upvt_list
   RETURN("S")
 END ;Subroutine
 SUBROUTINE get_bad_pkw_vers(i_target_id,i_log_id,o_data_rs)
   DECLARE dcl_where_log = vc
   DECLARE gb_while_ind = i4
   DECLARE gb_idx = i4 WITH noconstant(0)
   DECLARE gb_idx2 = i4
   FREE RECORD temp_data
   RECORD temp_data(
     1 cnt = i4
     1 list[*]
       2 table_name = vc
   )
   IF (i_log_id=0)
    SET dcl_where_log = "1 = 1"
   ELSE
    SET dcl_where_log = concat("dcl.log_id = ",trim(cnvtstring(i_log_id)),".0")
   ENDIF
   IF (i_log_id=0)
    SET gb_while_ind = 0
    WHILE (gb_while_ind=0)
      SET dm_err->eproc = "Updating PKWREF back to REFCHG"
      CALL disp_msg(" ",dm_err->logfile,0)
      UPDATE  FROM dm_chg_log dcl
       SET dcl.log_type = "REFCHG"
       WHERE dcl.target_env_id=i_target_id
        AND dcl.log_type="PKWREF"
       WITH maxqual(dcl,1000), nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      IF (curqual < 1000)
       SET gb_while_ind = 1
      ENDIF
    ENDWHILE
    SET gb_while_ind = 0
    WHILE (gb_while_ind=0)
      SET dm_err->eproc = "Updating PKWNOR back to NORDDS"
      CALL disp_msg(" ",dm_err->logfile,0)
      UPDATE  FROM dm_chg_log dcl
       SET dcl.log_type = "NORDDS"
       WHERE dcl.target_env_id=i_target_id
        AND dcl.log_type="PKWNOR"
       WITH maxqual(dcl,1000), nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      IF (curqual < 1000)
       SET gb_while_ind = 1
      ENDIF
    ENDWHILE
   ENDIF
   SET dm_err->eproc = "Checking dm_chg_log to see if there are rows with bad ptam_match_hash"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    dcl.table_name
    FROM dm_chg_log dcl
    WHERE dcl.target_env_id=i_target_id
     AND dcl.log_type IN ("REFCHG", "NORDDS")
     AND  NOT (dcl.ptam_match_hash IN (
    (SELECT
     dp.ptam_match_hash
     FROM dm_pk_where dp
     WHERE dp.table_name=dcl.table_name)))
     AND ((dcl.delete_ind=0) OR (dcl.delete_ind=1
     AND dcl.updt_applctx != 431001))
     AND parser(dcl_where_log)
    HEAD REPORT
     temp_data->cnt = 0
    DETAIL
     temp_data->cnt = (temp_data->cnt+ 1)
     IF (mod(temp_data->cnt,10)=1)
      stat = alterlist(temp_data->list,(temp_data->cnt+ 9))
     ENDIF
     temp_data->list[temp_data->cnt].table_name = dcl.table_name
    FOOT REPORT
     stat = alterlist(temp_data->list,temp_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF ((temp_data->cnt > 0))
    SELECT INTO "nl:"
     FROM dm_pk_where dpw
     WHERE expand(gb_idx,1,temp_data->cnt,dpw.table_name,temp_data->list[gb_idx].table_name)
     HEAD REPORT
      o_data_rs->cnt = 0, gb_idx2 = 0
     DETAIL
      gb_idx2 = locateval(gb_idx,1,o_data_rs->cnt,dpw.table_name,o_data_rs->list[gb_idx].table_name)
      IF (gb_idx2=0)
       o_data_rs->cnt = (o_data_rs->cnt+ 1), stat = alterlist(o_data_rs->list,o_data_rs->cnt),
       gb_idx2 = o_data_rs->cnt,
       o_data_rs->list[gb_idx2].table_name = dpw.table_name
      ENDIF
      IF (dpw.delete_ind=1)
       o_data_rs->list[gb_idx2].del_ptam_match_hash = dpw.ptam_match_hash
      ELSE
       o_data_rs->list[gb_idx2].ins_ptam_match_hash = dpw.ptam_match_hash
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE correct_dcl_pkw_vers(i_target_env_id,i_log_id)
   DECLARE cdpv_sub_return = vc
   DECLARE cdpv_find_zero = i4
   DECLARE idx0 = i4
   DECLARE cdpv_loop_cnt = i4
   DECLARE cdpv_cnt_ind = i2
   DECLARE cdpv_fix_0_ind = i2
   DECLARE cdpv_rowqual = i4
   DECLARE cdpv_fix_all_ind = i2
   DECLARE cdpv_idx = i4
   DECLARE dcl_log_str = vc
   DECLARE cdpv_fix_qual = i4
   DECLARE cdpv_list_cnt = i4
   DECLARE cdpv_pkw_cnt = i4
   DECLARE cdpv_idx2 = i4
   DECLARE cdpv_pkw_loop = i4
   DECLARE cdpv_log_type = vc
   DECLARE cdpv_log_str = vc
   DECLARE cdpv_cnt = i4
   DECLARE cdpv_new_pkw = vc
   DECLARE cdpv_colstr_err_ind = i2 WITH protect, noconstant(0)
   FREE RECORD cd_st
   RECORD cd_st(
     1 stmt[10]
       2 str = vc
   )
   FREE RECORD cdpv_list
   RECORD cdpv_list(
     1 data[*]
       2 table_name = vc
       2 table_suffix = vc
       2 table_alias = vc
       2 dm_refchg_pkw_vers_id = f8
       2 versioning_ind = i2
       2 pkw_str = vc
       2 pkw_declare = vc
       2 pkw_function = vc
       2 pkw_iu_str = vc
       2 pkw_del_str = vc
       2 pkw_check_ind = i2
       2 pk_where_hash = f8
       2 pkw[*]
         3 parm_name = vc
         3 parm_data_type = vc
   )
   FREE RECORD cdpv_bad_pkw
   RECORD cdpv_bad_pkw(
     1 cnt = i4
     1 list[*]
       2 del_ptam_match_hash = f8
       2 ins_ptam_match_hash = f8
       2 table_name = vc
   )
   FREE RECORD cdpv_log
   RECORD cdpv_log(
     1 cnt = i4
     1 list[*]
       2 log_id = f8
       2 log_type = vc
       2 table_name = vc
       2 pkw = vc
       2 pk_cnt = i4
       2 ctx = vc
       2 ptam_match_hash = f8
       2 ptam_match_result = f8
       2 delete_ind = i2
       2 qual[*]
         3 new_pk = vc
   )
   SET cdpv_sub_return = get_bad_pkw_vers(i_target_env_id,i_log_id,cdpv_bad_pkw)
   IF (cdpv_sub_return="F")
    RETURN("F")
   ENDIF
   CALL parser("declare sys_context() = c4000 go",1)
   IF ((cdpv_bad_pkw->cnt != 0))
    IF (i_log_id=0)
     SET dcl_log_str = "1 = 1"
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="RDDS CONFIGURATION"
       AND di.info_name="PKW FIX LIMIT"
      DETAIL
       cdpv_fix_qual = di.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN("F")
     ENDIF
     IF (curqual=0)
      SET cdpv_fix_qual = 500
     ENDIF
    ELSE
     SET dcl_log_str = concat("dcl.log_id = ",trim(cnvtstring(i_log_id)),".0")
     SET cdpv_fix_qual = 10
    ENDIF
    FOR (cdpv_cnt = 1 TO cdpv_bad_pkw->cnt)
     SET cdpv_fix_all_ind = 1
     WHILE (cdpv_fix_all_ind=1)
       SET cdpv_idx = 0
       SELECT INTO "nl:"
        FROM dm_chg_log dcl
        WHERE (dcl.table_name=cdpv_bad_pkw->list[cdpv_cnt].table_name)
         AND dcl.target_env_id=i_target_env_id
         AND ((dcl.log_type IN ("REFCHG", "NORDDS")) OR (dcl.log_type IN ("PKWREF", "PKWNOR")
         AND (( NOT (dcl.rdbhandle IN (
        (SELECT
         audsid
         FROM gv$session)))) OR (dcl.rdbhandle = null)) ))
         AND ((dcl.delete_ind=0
         AND (dcl.ptam_match_hash != cdpv_bad_pkw->list[cdpv_cnt].ins_ptam_match_hash)) OR (dcl
        .delete_ind=1
         AND (dcl.ptam_match_hash != cdpv_bad_pkw->list[cdpv_cnt].del_ptam_match_hash)
         AND dcl.updt_applctx != 4310001))
         AND parser(dcl_log_str)
        HEAD REPORT
         cdpv_log->cnt = 0, stat = alterlist(cdpv_log->list,0)
        DETAIL
         cdpv_log->cnt = (cdpv_log->cnt+ 1)
         IF (mod(cdpv_log->cnt,100)=1)
          stat = alterlist(cdpv_log->list,(cdpv_log->cnt+ 99))
         ENDIF
         cdpv_log->list[cdpv_log->cnt].log_id = dcl.log_id, cdpv_log->list[cdpv_log->cnt].log_type =
         dcl.log_type, cdpv_log->list[cdpv_log->cnt].table_name = cdpv_bad_pkw->list[cdpv_cnt].
         table_name,
         cdpv_log->list[cdpv_log->cnt].pkw = replace(dcl.pk_where,"<MERGE_LINK>"," ",0), cdpv_log->
         list[cdpv_log->cnt].pkw = replace(cdpv_log->list[cdpv_log->cnt].pkw,"<VERS_CLAUSE>"," 1=1 ",
          0), cdpv_log->list[cdpv_log->cnt].ctx = dcl.context_name,
         cdpv_log->list[cdpv_log->cnt].delete_ind = dcl.delete_ind
         IF (dcl.delete_ind=0)
          cdpv_log->list[cdpv_log->cnt].ptam_match_hash = cdpv_bad_pkw->list[cdpv_cnt].
          ins_ptam_match_hash
         ELSE
          cdpv_log->list[cdpv_log->cnt].ptam_match_hash = cdpv_bad_pkw->list[cdpv_cnt].
          del_ptam_match_hash
         ENDIF
        FOOT REPORT
         stat = alterlist(cdpv_log->list,cdpv_log->cnt)
        WITH maxqual(dcl,value(cdpv_fix_qual)), forupdatewait(dcl)
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN("F")
       ENDIF
       IF (curqual=0)
        SET cdpv_fix_all_ind = 0
       ELSE
        SET cdpv_idx = 0
        UPDATE  FROM dm_chg_log dcl
         SET dcl.rdbhandle = currdbhandle
         WHERE expand(cdpv_idx,1,cdpv_log->cnt,dcl.log_id,cdpv_log->list[cdpv_idx].log_id)
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         RETURN("F")
        ENDIF
        SET cdpv_idx = 0
        UPDATE  FROM dm_chg_log dcl
         SET dcl.log_type = "PKWREF"
         WHERE expand(cdpv_idx,1,cdpv_log->cnt,dcl.log_id,cdpv_log->list[cdpv_idx].log_id)
          AND dcl.log_type="REFCHG"
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         RETURN("F")
        ENDIF
        IF ((curqual < cdpv_log->cnt))
         SET cdpv_idx = 0
         UPDATE  FROM dm_chg_log dcl
          SET dcl.log_type = "PKWNOR"
          WHERE expand(cdpv_idx,1,cdpv_log->cnt,dcl.log_id,cdpv_log->list[cdpv_idx].log_id)
           AND dcl.log_type="NORDDS"
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          ROLLBACK
          RETURN("F")
         ELSE
          COMMIT
         ENDIF
        ELSE
         COMMIT
        ENDIF
        FOR (cdpv_pkw_cnt = 1 TO cdpv_log->cnt)
          SET cdpv_colstr_err_ind = 0
          SET cdpv_idx = 0
          SET cdpv_idx2 = 0
          SET cdpv_idx = locateval(cdpv_idx2,1,size(cdpv_list->data,5),cdpv_log->list[cdpv_pkw_cnt].
           table_name,cdpv_list->data[cdpv_idx2].table_name)
          IF (cdpv_idx=0)
           SET cdpv_idx = (size(cdpv_list->data,5)+ 1)
           SET stat = alterlist(cdpv_list->data,cdpv_idx)
           SET cdpv_list->data[cdpv_idx].table_name = cdpv_log->list[cdpv_pkw_cnt].table_name
           SELECT INTO "nl:"
            FROM dm_tables_doc_local dtl
            WHERE (dtl.table_name=cdpv_list->data[cdpv_idx].table_name)
            DETAIL
             cdpv_list->data[cdpv_idx].table_suffix = dtl.table_suffix, cdpv_list->data[cdpv_idx].
             table_alias = concat("t",trim(dtl.table_suffix))
            WITH nocounter
           ;end select
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            RETURN("F")
           ENDIF
           SELECT INTO "nl:"
            FROM dm_pk_where dpw
            WHERE (dpw.table_name=cdpv_list->data[cdpv_idx].table_name)
             AND dpw.delete_ind=0
            DETAIL
             cdpv_list->data[cdpv_idx].pk_where_hash = dpw.pk_where_hash
            WITH nocounter
           ;end select
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            RETURN("F")
           ENDIF
          ENDIF
          IF ((cdpv_log->list[cdpv_pkw_cnt].delete_ind=0))
           SET cd_st->stmt[1].str = concat("select into 'nl:' y=",cdpv_list->data[cdpv_idx].
            table_alias,".rowid ")
           SET cd_st->stmt[2].str = concat("from ",cdpv_list->data[cdpv_idx].table_name," ",cdpv_list
            ->data[cdpv_idx].table_alias)
           SET cd_st->stmt[3].str = cdpv_log->list[cdpv_pkw_cnt].pkw
           SET cd_st->stmt[4].str = "head report"
           SET cd_st->stmt[5].str = "  cdpv_log->list[cdpv_pkw_cnt].pk_cnt = 0"
           SET cd_st->stmt[6].str = "detail"
           SET cd_st->stmt[7].str =
           "  cdpv_log->list[cdpv_pkw_cnt].pk_cnt = cdpv_log->list[cdpv_pkw_cnt].pk_cnt +1"
           SET cd_st->stmt[8].str =
           "  stat=alterlist(cdpv_log->list[cdpv_pkw_cnt].qual, cdpv_log->list[cdpv_pkw_cnt].pk_cnt)"
           SET cd_st->stmt[9].str = concat(
            "  cdpv_log->list[cdpv_pkw_cnt].qual[cdpv_log->list[cdpv_pkw_cnt].pk_cnt].new_pk = ",
            ^concat('WHERE ',cdpv_list->data[cdpv_idx].table_alias,'.ROWID="',^,cdpv_list->data[
            cdpv_idx].table_alias,^.ROWID,'"')^)
           SET cd_st->stmt[10].str = "with nocounter go"
           EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","CD_ST")
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            RETURN("F")
           ENDIF
          ELSE
           SET cdpv_log->list[cdpv_pkw_cnt].pk_cnt = 1
          ENDIF
          IF ((cdpv_log->list[cdpv_pkw_cnt].pk_cnt=0))
           UPDATE  FROM dm_chg_log dcl
            SET dcl.log_type = "NO SRC", dcl.updt_dt_tm = cnvtdatetime(curdate,curtime3)
            WHERE (dcl.log_id=cdpv_log->list[cdpv_pkw_cnt].log_id)
            WITH nocounter
           ;end update
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            ROLLBACK
            RETURN("F")
           ELSE
            COMMIT
           ENDIF
          ELSEIF ((cdpv_log->list[cdpv_pkw_cnt].delete_ind=1))
           CALL drmm_get_col_string("",cdpv_log->list[cdpv_pkw_cnt].log_id,"","","")
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            RETURN("F")
           ENDIF
           CALL drmm_get_ptam_match_query(0.0,cdpv_list->data[cdpv_idx].table_name,cdpv_list->data[
            cdpv_idx].table_suffix,"")
           IF (check_error(dm_err->eproc)=1)
            IF (findstring("ORA-20205:",dm_err->emsg) > 0)
             SET dm_err->err_ind = 0
             SET cdpv_colstr_err_ind = 1
            ELSE
             CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
             RETURN("F")
            ENDIF
           ELSE
            SET cdpv_log->list[cdpv_pkw_cnt].ptam_match_result = drmm_get_ptam_match_result(0.0,0.0,
             0.0,"",1,
             "FROM")
           ENDIF
           IF ((cdpv_log->list[cdpv_pkw_cnt].log_type IN ("PKWREF", "REFCHG")))
            SET cdpv_log_str = "REFCHG"
           ELSE
            SET cdpv_log_str = "NORDDS"
           ENDIF
           IF (cdpv_colstr_err_ind=1)
            UPDATE  FROM dm_chg_log dcl
             SET dcl.log_type = cdpv_log_str, dcl.updt_applctx = 4310001
             WHERE (dcl.log_id=cdpv_log->list[cdpv_pkw_cnt].log_id)
             WITH nocounter
            ;end update
           ELSE
            UPDATE  FROM dm_chg_log dcl
             SET dcl.log_type = cdpv_log_str, dcl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcl
              .ptam_match_hash = cdpv_log->list[cdpv_pkw_cnt].ptam_match_hash,
              dcl.ptam_match_result = cdpv_log->list[cdpv_pkw_cnt].ptam_match_result, dcl
              .ptam_match_query = sys_context("CERNER","RDDS_PTAM_MATCH_QUERY",2000), dcl
              .ptam_match_result_str = sys_context("CERNER","RDDS_PTAM_MATCH_RESULT_STR",4000)
             WHERE (dcl.log_id=cdpv_log->list[cdpv_pkw_cnt].log_id)
             WITH nocounter
            ;end update
           ENDIF
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            ROLLBACK
            RETURN("F")
           ELSE
            COMMIT
           ENDIF
          ELSE
           SET cdpv_pkw_loop = 0
           FOR (cdpv_pkw_loop = 1 TO cdpv_log->list[cdpv_pkw_cnt].pk_cnt)
             IF ((cdpv_log->list[cdpv_pkw_cnt].log_type IN ("PKWREF", "REFCHG")))
              SET cdpv_log_type = "REFCHG"
             ELSE
              SET cdpv_log_type = "NORDDS"
             ENDIF
             CALL drmm_get_col_string(cdpv_log->list[cdpv_pkw_cnt].qual[cdpv_pkw_loop].new_pk,0.0,
              cdpv_list->data[cdpv_idx].table_name,cdpv_list->data[cdpv_idx].table_suffix,"")
             CALL drmm_get_ptam_match_query(0.0,cdpv_list->data[cdpv_idx].table_name,cdpv_list->data[
              cdpv_idx].table_suffix,"")
             SET cdpv_log->list[cdpv_pkw_cnt].ptam_match_result = drmm_get_ptam_match_result(0.0,0.0,
              0.0,"",1,
              "FROM")
             SET cdpv_log->list[cdpv_pkw_cnt].qual[cdpv_pkw_loop].new_pk = drmm_get_pk_where(
              cdpv_list->data[cdpv_idx].table_name,cdpv_list->data[cdpv_idx].table_suffix,0," ")
             SET cdpv_sub_return = call_ins_dcl(cdpv_list->data[cdpv_idx].table_name,cdpv_log->list[
              cdpv_pkw_cnt].qual[cdpv_pkw_loop].new_pk,cdpv_log_type,0,reqinfo->updt_id,
              reqinfo->updt_task,reqinfo->updt_applctx,cdpv_log->list[cdpv_pkw_cnt].ctx,
              i_target_env_id,0.0,
              "",cdpv_list->data[cdpv_idx].pk_where_hash,cdpv_log->list[cdpv_pkw_cnt].ptam_match_hash
              )
             IF (cdpv_sub_return="F")
              RETURN("F")
             ENDIF
           ENDFOR
           UPDATE  FROM dm_chg_log dcl
            SET dcl.log_type = "BADPKW"
            WHERE (dcl.log_id=cdpv_log->list[cdpv_pkw_cnt].log_id)
            WITH nocounter
           ;end update
           IF (check_error(dm_err->eproc)=1)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
            ROLLBACK
            RETURN("F")
           ELSE
            COMMIT
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
     ENDWHILE
    ENDFOR
   ENDIF
   SET stat = alterlist(cdpv_bad_pkw->list,0)
   SET cdpv_sub_return = get_bad_pkw_vers(i_target_env_id,i_log_id,cdpv_bad_pkw)
   IF (cdpv_sub_return="F")
    RETURN("F")
   ELSE
    RETURN("S")
   ENDIF
 END ;Subroutine
 DECLARE pk_where_info(i_table_name=vc,i_table_suffix=vc,i_alias=vc,i_dblink=vc,i_rs_data=vc(ref)) =
 vc
 DECLARE filter_info(i_table_name=vc,i_table_suffix=vc,i_alias=vc,i_dblink=vc,i_rs_data=vc(ref)) = vc
 DECLARE call_ins_log(i_table_name=vc,i_pk_where=vc,i_log_type=vc,i_delete_ind=i2,i_updt_id=f8,
  i_updt_task=i4,i_updt_applctx=i4,i_ctx_str=vc,i_envid=f8,i_pkw_vers_id=f8,
  i_dblink=vc) = vc
 DECLARE call_ins_dcl(i_table_name=vc,i_pk_where=vc,i_log_type=vc,i_delete_ind=i2,i_updt_id=f8,
  i_updt_task=i4,i_updt_applctx=i4,i_ctx_str=vc,i_envid=f8,i_spass_log_id=f8,
  i_dblink=vc,i_pk_hash=f8,i_ptam_hash=f8) = vc
 IF ((validate(proc_refchg_ins_log_args->has_vers_id,- (99))=- (99))
  AND (validate(proc_refchg_ins_log_args->has_vers_id,- (100))=- (100)))
  FREE RECORD proc_refchg_ins_log_args
  RECORD proc_refchg_ins_log_args(
    1 has_vers_id = i2
  )
  SET proc_refchg_ins_log_args->has_vers_id = - (1)
 ENDIF
 SUBROUTINE pk_where_info(i_table_name,i_table_suffix,i_alias,i_dblink,i_rs_data)
   DECLARE pwi_qual = i4 WITH protect, noconstant(0)
   DECLARE pwi_idx1 = i4 WITH protect, noconstant(0)
   DECLARE pwi_idx2 = i4 WITH protect, noconstant(0)
   DECLARE pwi_size = i4 WITH protect, noconstant(0)
   DECLARE pwi_temp = vc
   SET pwi_size = size(i_rs_data->data,5)
   SET pwi_idx1 = locateval(pwi_idx2,1,pwi_size,trim(i_table_name),i_rs_data->data[pwi_idx2].
    table_name)
   IF (pwi_idx1=0)
    SET pwi_idx1 = (pwi_size+ 1)
    SET stat = alterlist(i_rs_data->data,pwi_idx1)
    SET i_rs_data->data[pwi_idx1].table_name = trim(i_table_name)
   ENDIF
   SET pwi_temp = build("REFCHG_PK_WHERE_",i_table_suffix,"*")
   SET dm_err->eproc = concat("Verify that ",trim(pwi_temp)," function for ",trim(i_table_name),
    " exists in the domain")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("user_objects",trim(i_dblink))) uo)
    WHERE uo.object_name=patstring(pwi_temp)
     AND (uo.last_ddl_time=
    (SELECT
     max(o.last_ddl_time)
     FROM (parser(concat("user_objects",trim(i_dblink))) o)
     WHERE o.object_name=patstring(pwi_temp)))
    DETAIL
     i_rs_data->data[pwi_idx1].pkw_function = uo.object_name, i_rs_data->data[pwi_idx1].pkw_declare
      = concat("declare ",trim(uo.object_name),trim(i_dblink),"() = c2000 go")
    WITH nocounter
   ;end select
   SET pwi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (pwi_qual=0)
    SET dm_err->emsg = concat(trim(pwi_temp)," does not exist in current domain")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET i_rs_data->data[pwi_idx1].pkw_check_ind = 1
    RETURN("E")
   ENDIF
   SET dm_err->eproc = concat("Obtaining parameters for ",trim(pwi_temp))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("dm_refchg_pkw_parm",trim(i_dblink))) drp)
    WHERE drp.table_name=trim(i_table_name)
    ORDER BY drp.parm_nbr
    HEAD REPORT
     count = 0, i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_function,
      trim(i_dblink),"('INS/UPD'"), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[
      pwi_idx1].pkw_function,trim(i_dblink),"('DELETE'")
    DETAIL
     count = (count+ 1), stat = alterlist(i_rs_data->data[pwi_idx1].pkw,count), i_rs_data->data[
     pwi_idx1].pkw[count].parm_name = trim(drp.column_name)
     IF (trim(i_alias) > "")
      i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,",",trim(
        i_alias),".",trim(drp.column_name)), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data
       ->data[pwi_idx1].pkw_del_str,",",trim(i_alias),".",trim(drp.column_name))
     ELSE
      i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,",",trim(drp
        .column_name)), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[pwi_idx1].
       pkw_del_str,",",trim(drp.column_name))
     ENDIF
    FOOT REPORT
     i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,")"),
     i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[pwi_idx1].pkw_del_str,")")
    WITH nocounter
   ;end select
   SET pwi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (pwi_qual=0)
    SET dm_err->emsg = "Could not obtain parameters for pk_where function"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("P")
   ENDIF
   SET i_rs_data->data[pwi_idx1].pkw_check_ind = 1
   RETURN("S")
 END ;Subroutine
 SUBROUTINE filter_info(i_table_name,i_table_suffix,i_alias,i_dblink,i_rs_data)
   DECLARE fi_qual = i4 WITH protect, noconstant(0)
   DECLARE fi_idx1 = i4 WITH protect, noconstant(0)
   DECLARE fi_idx2 = i4 WITH protect, noconstant(0)
   DECLARE fi_size = i4 WITH protect, noconstant(0)
   DECLARE fi_temp = vc
   SET fi_size = size(i_rs_data->data,5)
   SET fi_idx1 = locateval(fi_idx2,1,fi_size,trim(i_table_name),i_rs_data->data[fi_idx2].table_name)
   IF (fi_idx1=0)
    SET fi_idx1 = (fi_size+ 1)
    SET stat = alterlist(i_rs_data->data,fi_idx1)
    SET i_rs_data->data[fi_idx1].table_name = trim(i_table_name)
   ENDIF
   SET fi_temp = build("REFCHG_FILTER_",i_table_suffix,"*")
   SET dm_err->eproc = concat("Verify that ",trim(fi_temp)," function for ",trim(i_table_name),
    " exists in the domain")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("user_objects",trim(i_dblink))) uo)
    WHERE uo.object_name=patstring(fi_temp)
     AND (uo.last_ddl_time=
    (SELECT
     max(o.last_ddl_time)
     FROM (parser(concat("user_objects",trim(i_dblink))) o)
     WHERE o.object_name=patstring(fi_temp)))
    DETAIL
     i_rs_data->data[fi_idx1].filter_function = uo.object_name, i_rs_data->data[fi_idx1].
     filter_declare = concat("declare ",trim(uo.object_name),trim(i_dblink),"() = i2 go")
    WITH nocounter
   ;end select
   SET fi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (fi_qual=0)
    SET dm_err->eproc = concat(trim(fi_temp)," function for ",trim(i_table_name),
     " does not exists in the domain")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET i_rs_data->data[fi_idx1].filter_check_ind = 1
    RETURN("E")
   ENDIF
   SET dm_err->eproc = concat("Obtaining parameters for ",trim(fi_temp))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("dm_refchg_filter_parm",trim(i_dblink))) drp)
    WHERE drp.table_name=trim(i_table_name)
     AND drp.active_ind=1
    ORDER BY drp.parm_nbr
    HEAD REPORT
     count = 0, i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].
      filter_function,trim(i_dblink),"('ADD'"), i_rs_data->data[fi_idx1].filter_upd_str = concat(
      i_rs_data->data[fi_idx1].filter_function,trim(i_dblink),"('UPD'"),
     i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].filter_function,trim(
       i_dblink),"('DEL'")
    DETAIL
     count = (count+ 1), stat = alterlist(i_rs_data->data[fi_idx1].filter,count), i_rs_data->data[
     fi_idx1].filter[count].parm_name = trim(drp.column_name)
     IF (trim(i_alias) > "")
      i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,",",
       trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_upd_str = concat
      (i_rs_data->data[fi_idx1].filter_upd_str,",",trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_del_str = concat
      (i_rs_data->data[fi_idx1].filter_del_str,",",trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name))
     ELSE
      i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,",",
       trim(drp.column_name),",",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_upd_str =
      concat(i_rs_data->data[fi_idx1].filter_upd_str,",",trim(drp.column_name),",",trim(drp
        .column_name)), i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].
       filter_del_str,",",trim(drp.column_name),",",trim(drp.column_name))
     ENDIF
    FOOT REPORT
     i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,")"),
     i_rs_data->data[fi_idx1].filter_upd_str = concat(i_rs_data->data[fi_idx1].filter_upd_str,")"),
     i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].filter_del_str,")")
    WITH nocounter
   ;end select
   SET fi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (fi_qual=0)
    SET dm_err->emsg = "Could not obtain parameters for filter function"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("P")
   ENDIF
   SET i_rs_data->data[fi_idx1].filter_check_ind = 1
   RETURN("S")
 END ;Subroutine
 SUBROUTINE call_ins_log(i_table_name,i_pk_where,i_log_type,i_delete_ind,i_updt_id,i_updt_task,
  i_updt_applctx,i_ctx_str,i_envid,i_pkw_vers_id,i_dblink)
   DECLARE cil_delete_ind_str = vc
   DECLARE cil_updt_id_str = vc
   DECLARE cil_updt_task_str = vc
   DECLARE cil_updt_applctx_str = vc
   DECLARE cil_ctx_str = vc
   DECLARE cil_envid_str = vc
   DECLARE cil_pkw_vers_id_str = vc
   DECLARE cil_pkw = vc
   SET cil_pk = replace_carrot_symbol(i_pk_where)
   FREE RECORD dat_stmt
   RECORD dat_stmt(
     1 stmt[5]
       2 str = vc
   )
   IF (trim(i_ctx_str) > "")
    SET cil_ctx_str = trim(i_ctx_str)
   ELSE
    SET cil_ctx_str = "NULL"
   ENDIF
   IF (i_envid=0)
    SET cil_envid_str = "NULL"
   ELSE
    SET cil_envid_str = trim(cnvtstring(i_envid))
   ENDIF
   SET cil_delete_ind_str = trim(cnvtstring(i_delete_ind))
   SET cil_updt_id_str = trim(cnvtstring(i_updt_id))
   SET cil_updt_task_str = trim(cnvtstring(i_updt_task))
   SET cil_updt_applctx_str = trim(cnvtstring(i_updt_applctx))
   SET cil_pkw_vers_id_str = trim(cnvtstring(i_pkw_vers_id))
   SET dat_stmt->stmt[1].str = concat("RDB ASIS(^ BEGIN proc_refchg_ins_log",trim(i_dblink),"('",
    i_table_name,"',^)")
   SET dat_stmt->stmt[2].str = concat("ASIS(^ ",cil_pk,",^)")
   SET dat_stmt->stmt[3].str = concat("ASIS(^ dbms_utility.get_hash_value(",cil_pk,",0,1073741824.0)",
    ",'",i_log_type,
    "',",cil_delete_ind_str,",",cil_updt_id_str,",",
    cil_updt_task_str,",",cil_updt_applctx_str,"^)")
   SET dat_stmt->stmt[4].str = concat("ASIS(^,'",cil_ctx_str,"',",cil_envid_str,"^)")
   SET dm_err->eproc = "Checking to see if we should use i_pkw_vers_id"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((proc_refchg_ins_log_args->has_vers_id=- (1)))
    SELECT INTO "nl:"
     FROM (parser(concat("user_arguments",trim(i_dblink))) ua)
     WHERE ua.object_name="PROC_REFCHG_INS_LOG"
      AND ua.argument_name="I_DM_REFCHG_PKW_VERS_ID"
     DETAIL
      proc_refchg_ins_log_args->has_vers_id = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET proc_refchg_ins_log_args->has_vers_id = 0
    ENDIF
   ENDIF
   IF ((proc_refchg_ins_log_args->has_vers_id=1))
    SET dat_stmt->stmt[5].str = concat("ASIS(^,",cil_pkw_vers_id_str,"); END; ^) go")
   ELSE
    SET dat_stmt->stmt[5].str = concat("ASIS(^","); END; ^) go")
   ENDIF
   CALL echo(dat_stmt->stmt[1].str)
   CALL echo(dat_stmt->stmt[2].str)
   CALL echo(dat_stmt->stmt[3].str)
   CALL echo(dat_stmt->stmt[4].str)
   CALL echo(dat_stmt->stmt[5].str)
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DAT_STMT")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE call_ins_dcl(i_table_name,i_pk_where,i_log_type,i_delete_ind,i_updt_id,i_updt_task,
  i_updt_applctx,i_ctx_str,i_envid,i_spass_log_id,i_dblink,i_pk_hash,i_ptam_hash)
   DECLARE cil_delete_ind_str = vc
   DECLARE cil_updt_id_str = vc
   DECLARE cil_updt_task_str = vc
   DECLARE cil_updt_applctx_str = vc
   DECLARE cil_ctx_str = vc
   DECLARE cil_envid_str = vc
   DECLARE cil_spass_log_id = vc
   DECLARE cil_pk = vc
   DECLARE cil_db_link = vc
   DECLARE cil_table_name = vc
   DECLARE cil_pk_hash = vc
   DECLARE cil_ptam_hash = vc
   DECLARE cil_ptam_result = vc
   DECLARE cil_log_type = vc
   DECLARE cid_delete_ind = i2
   DECLARE cid_updt_id = f8
   DECLARE cid_updt_task = i4
   DECLARE cid_updt_applctx = i4
   DECLARE cid_i_envid = f8
   DECLARE cid_i_pk_where = vc
   DECLARE cid_ptam_str_ind = i2 WITH protect, noconstant(0)
   SET cid_delete_ind = i_delete_ind
   SET cid_updt_id = i_updt_id
   SET cid_updt_task = i_updt_task
   SET cid_updt_applctx = i_updt_applctx
   SET cid_i_envid = i_envid
   SET cid_i_pk_where = i_pk_where
   SET cil_pk = replace_carrot_symbol(cid_i_pk_where)
   FREE RECORD dat_stmt
   RECORD dat_stmt(
     1 stmt[5]
       2 str = vc
   )
   IF (trim(i_ctx_str) > "")
    SET cil_ctx_str = trim(i_ctx_str)
   ELSE
    SET cil_ctx_str = "NULL"
   ENDIF
   IF (cid_i_envid=0)
    SET cil_envid_str = "NULL"
   ELSE
    SET cil_envid_str = trim(cnvtstring(cid_i_envid))
   ENDIF
   IF (i_spass_log_id=0)
    SET cil_spass_log_id = "NULL"
   ELSE
    SET cil_spass_log_id = trim(cnvtstring(i_spass_log_id))
   ENDIF
   SET cil_delete_ind_str = trim(cnvtstring(cid_delete_ind))
   SET cil_updt_id_str = trim(cnvtstring(cid_updt_id))
   SET cil_updt_task_str = trim(cnvtstring(cid_updt_task))
   SET cil_updt_applctx_str = trim(cnvtstring(cid_updt_applctx))
   SET cil_spass_log_id = trim(cnvtstring(i_spass_log_id))
   SET cil_db_link = trim(i_dblink)
   SET cil_table_name = trim(i_table_name)
   SET cil_pk_hash = trim(cnvtstring(i_pk_hash))
   SET cil_ptam_hash = trim(cnvtstring(i_ptam_hash))
   SET cil_log_type = trim(i_log_type)
   SELECT INTO "nl:"
    FROM (parser(concat("user_source",cil_db_link)) uo)
    WHERE uo.name="PROC_REFCHG_INS_DCL"
    DETAIL
     IF (cnvtlower(uo.text)="*i_ptam_match_result_str*")
      cid_ptam_str_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "PROC_REFCHG_INS_DCL was not found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    SET cil_ptam_result = cnvtstring(drmm_get_ptam_match_result(0.0,0.0,0.0,"",1,
      "FROM"))
    SET dat_stmt->stmt[1].str = concat("RDB ASIS(^ BEGIN proc_refchg_ins_dcl",trim(cil_db_link),"('",
     cil_table_name,"',^)")
    SET dat_stmt->stmt[2].str = concat("ASIS(^ ",cil_pk,",^)")
    SET dat_stmt->stmt[3].str = concat("ASIS(^ dbms_utility.get_hash_value(",cil_pk,
     ",0,1073741824.0)",",'",cil_log_type,
     "',",cil_delete_ind_str,",",cil_updt_id_str,",",
     cil_updt_task_str,",",cil_updt_applctx_str,"^)")
    SET dat_stmt->stmt[4].str = concat("ASIS(^,'",cil_ctx_str,"',",cil_envid_str,
     ",sys_context('CERNER','RDDS_PTAM_MATCH_QUERY',2000),",
     cil_ptam_result,",sys_context('CERNER','RDDS_COL_STRING',4000)",",",cil_pk_hash,",",
     cil_ptam_hash,",",cil_spass_log_id)
    IF (cid_ptam_str_ind=1)
     SET dat_stmt->stmt[4].str = concat(dat_stmt->stmt[4].str,
      ",sys_context('CERNER','RDDS_PTAM_MATCH_RESULT_STR',4000)^)")
    ELSE
     SET dat_stmt->stmt[4].str = concat(dat_stmt->stmt[4].str,"^)")
    ENDIF
    SET dat_stmt->stmt[5].str = concat("ASIS(^","); END; ^) go")
    CALL echo(dat_stmt->stmt[1].str)
    CALL echo(dat_stmt->stmt[2].str)
    CALL echo(dat_stmt->stmt[3].str)
    CALL echo(dat_stmt->stmt[4].str)
    CALL echo(dat_stmt->stmt[5].str)
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DAT_STMT")
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
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
 IF ( NOT (validate(refchg_where_query,0)))
  FREE RECORD refchg_where_query
  RECORD refchg_where_query(
    1 err_ind = i2
    1 err_msg = vc
    1 pkw_template = vc
  )
 ENDIF
 IF ( NOT (validate(refchg_collist_query,0)))
  FREE RECORD refchg_collist_query
  RECORD refchg_collist_query(
    1 err_ind = i2
    1 err_msg = vc
    1 qual[*]
      2 column_name = vc
      2 column_datatype = vc
      2 parent_entity_col = vc
      2 trans_ind = i2
      2 exist_ind = i2
      2 precision_ind = i2
      2 base62_re_name = vc
  )
 ENDIF
 IF ( NOT (validate(md_list,0)))
  FREE RECORD md_list
  RECORD md_list(
    1 tmpl_cnt = i4
    1 template[*]
      2 tmpl_name = vc
      2 col_cnt = i4
      2 qual[*]
        3 column_name = vc
        3 column_datatype = vc
        3 parent_entity_col = vc
        3 trans_ind = i2
        3 exist_ind = i2
        3 precision_ind = i2
        3 base62_re_name = vc
  )
 ENDIF
 IF ( NOT (validate(drgtd_request,0)))
  FREE RECORD drgtd_request
  RECORD drgtd_request(
    1 what_tables = vc
    1 req_special[*]
      2 sp_tbl = vc
  )
 ENDIF
 IF ( NOT (validate(drgtd_reply,0)))
  FREE RECORD drgtd_reply
  RECORD drgtd_reply(
    1 err_ind = i2
    1 err_msg = vc
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
      2 mergeable_ind = i2
      2 reference_ind = i2
      2 metadata_change_ind = i2
  )
 ENDIF
 DECLARE dci_get_rdds_identifier(null) = vc
 DECLARE dci_set_rdds_identifier(dsri_ident=vc) = null
 SUBROUTINE dci_get_rdds_identifier(null)
   DECLARE sys_context() = c4000
   DECLARE dgri_ora_version = i2 WITH protect, noconstant(0)
   DECLARE dgri_ident = vc WITH protect, noconstant("")
   DECLARE dgri_temp_err = i2 WITH protect, noconstant(0)
   DECLARE dgri_temp_emsg = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get CLIENT_IDENTIFIER."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgri_temp_err = dm_err->err_ind
   SET dgri_temp_emsg = dm_err->emsg
   SET dm_err->err_ind = 0
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dgri_ora_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dgri_ident = "NULL"
    SET dm_err->emsg = concat("Error while obtaining Oracle version.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (dgri_ora_version >= 9)
    SELECT INTO "nl:"
     y = sys_context("USERENV","CLIENT_IDENTIFIER")
     FROM dual
     DETAIL
      dgri_ident = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dgri_ident = "NULL"
     SET dm_err->emsg = concat("Error while obtaining CLIENT_IDENTIFIER.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSEIF (((dgri_ident="") OR (dgri_ident=" ")) )
     SET dgri_ident = "NULL"
    ENDIF
   ELSE
    SET dgri_ident = "NULL"
   ENDIF
   SET dm_err->err_ind = dgri_temp_err
   SET dm_err->emsg = dgri_temp_emsg
   RETURN(dgri_ident)
 END ;Subroutine
 SUBROUTINE dci_set_rdds_identifier(dsri_ident)
   DECLARE sys_context() = c4000
   DECLARE dsri_ora_version = i2 WITH protect, noconstant(0)
   DECLARE dsri_temp_err = i2 WITH protect, noconstant(0)
   DECLARE dsri_temp_emsg = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Set CLIENT_IDENTIFIER."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dsri_temp_err = dm_err->err_ind
   SET dsri_temp_emsg = dm_err->emsg
   SET dm_err->err_ind = 0
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dsri_ora_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = concat("Error while obtaining Oracle version.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (dsri_ora_version >= 9)
    IF (dsri_ident="NULL")
     RDB asis ( "begin dbms_session.clear_identifier; end;" )
     END ;Rdb
    ELSE
     CALL parser(concat(^rdb asis("begin dbms_session.set_identifier('^,dsri_ident,^'); end;") go^),1
      )
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = concat("Error while setting CLIENT_IDENTIFIER.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
   ENDIF
   SET dm_err->err_ind = dsri_temp_err
   SET dm_err->emsg = dsri_temp_emsg
 END ;Subroutine
 IF ((dm_err->debug_flag=0))
  SET trace = nocallecho
  SET message = noinformation
 ENDIF
 IF (check_logfile("dm2_log_triggers_",".log","DM2CHG_TRGR LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm2_add_chg_log_triggers..."
 CALL disp_msg("",dm_err->logfile,0)
 DECLARE drop_old_functions(io_drop_cnt=i4(ref)) = null
 DECLARE create_sc_proc_ora(i_dtd_ndx=i4,i_found_ndx=i4,io_stmt_cnt=i4(ref)) = null
 DECLARE create_sc_triggers_ora(i_dtd_find=i4,i_upto_value=i4,i_single_tab_ind=i2,io_stmt_cnt=i4(ref)
  ) = null
 DECLARE create_xlat_triggers(i_dtd_ndx=i4,io_stmt_cnt=i4(ref)) = null
 DECLARE refchg_xlat_gather(i_table_name=vc) = null
 DECLARE create_refchg_filter_function_ora(i_dtd_ndx=i4,io_drop_cnt=i4(ref),io_stmt_cnt=i4(ref)) =
 null
 DECLARE create_refchg_triggers_ora(i_dtd_ndx=i4,io_stmt_cnt=i4(ref),io_drop_cnt=i4(ref)) = null
 DECLARE xlat_trigger_check(i_trigger_name=vc,i_trigger_name_c=vc,i_cxl_drop=vc(ref)) = vc
 DECLARE xlat_trig_execute(i_trigger_name=vc,io_stmt_cnt=i4(ref)) = null
 DECLARE xlat_trig_create(i_trigger_name=vc,i_col_name=vc,i_tab_name=vc,io_stmt_cnt=i4(ref),i_flag=i4
  ) = null
 DECLARE xlat_trig_remove_invalid_xlat(i_xt_col_name=vc,i_xt_tab_name=vc,io_stmt_cnt=i4(ref)) = null
 DECLARE xlat_trig_add_invalid_xlat(i_xt_col_name=vc,i_xt_tab_name=vc,io_stmt_cnt=i4(ref)) = null
 DECLARE ac_log_type = vc WITH protect
 DECLARE ac_table_name = vc WITH protect
 DECLARE dtd_ndx = i4 WITH protect
 DECLARE upto_value = i4 WITH protect
 DECLARE dtd_find = i4 WITH protect
 DECLARE is_asterisk = i4 WITH protect
 DECLARE skip_flag = i4 WITH protect
 DECLARE add_trig_date = f8 WITH protect
 DECLARE total_trigger_cnt = i4 WITH protect
 DECLARE env_csv = vc WITH protect
 DECLARE cl_drop_cnt = i4 WITH public, noconstant(0)
 DECLARE cio_pseudo_column = vc WITH protect, noconstant("")
 DECLARE daclt_inhouse_flag = i2 WITH protect
 DECLARE daclt_tab_flag = i4 WITH protect
 DECLARE rs_ndx = i4 WITH protect
 DECLARE child_cnt = i4 WITH protect
 DECLARE daclt_proc_name = vc WITH protect
 DECLARE daclt_proc_name_new = vc WITH protect
 DECLARE daclt_trig_add = vc WITH protect
 DECLARE daclt_trig_del = vc WITH protect
 DECLARE daclt_trig_upd = vc WITH protect
 DECLARE loop_ndx_parent = i4 WITH protect
 DECLARE loop_ndx_child2 = i4 WITH protect
 DECLARE v_single_tab_ind = i2 WITH protect
 DECLARE refchg_tab_r_find = i2 WITH protect
 DECLARE child_loop = i2 WITH protect
 DECLARE parent_loop = i2 WITH protect
 DECLARE single_commit_table_name = vc WITH protect
 DECLARE v_drop_cnt = i4 WITH protect
 DECLARE v_stmt_cnt = i4 WITH protect
 DECLARE v_parm_list = vc WITH protect
 DECLARE v_trigger_name = vc WITH protect
 DECLARE v_log_type = vc WITH protect
 DECLARE updt_ndx = i2 WITH protect
 DECLARE loop_cnt = i2 WITH protect
 DECLARE trig_drop_cnt = i4 WITH protect
 DECLARE create_xlat_trig_flag = i2 WITH protect
 DECLARE trig_drop_stmt = vc WITH protect
 DECLARE daclt_tab_cnt = i4 WITH protect
 DECLARE daclt_tab_found = i4 WITH protect
 DECLARE daclt_src_id = f8 WITH protect
 DECLARE daclt_temp_tab = vc WITH protect
 DECLARE daclt_num = i4 WITH protect
 DECLARE daclt_ev_reason = vc WITH protect
 DECLARE daclt_r_event = vc WITH protect
 DECLARE daclt_dcl_curqual = i2 WITH protect
 DECLARE daclt_r_tab_name = vc WITH protect
 DECLARE sc_curqual = i4 WITH protect
 DECLARE daclt_sc_ndx = i4 WITH protect
 DECLARE sc_rmv_ndx = i4 WITH protect
 DECLARE daclt_p_ndx = i4 WITH protect, noconstant(0)
 DECLARE daclt_ndx = i4 WITH protect, noconstant(0)
 DECLARE daclt_err = i2 WITH protect, noconstant(0)
 DECLARE daclt_colstring_cnt = i4 WITH protect, noconstant(0)
 DECLARE daclt_client_ident = vc WITH protect, noconstant("")
 DECLARE daclt_xlat_idx = i4 WITH protect, noconstant(0)
 DECLARE daclt_pair_name = vc WITH protect, noconstant(" ")
 DECLARE daclt_circ_ptam_ind = i2 WITH protect, noconstant(1)
 FREE RECORD cl_drop_stmt
 RECORD cl_drop_stmt(
   1 qual[*]
     2 stmt = vc
 )
 FREE RECORD iu_pk_where
 RECORD iu_pk_where(
   1 data[*]
     2 str = vc
 )
 FREE RECORD del_pk_where
 RECORD del_pk_where(
   1 data[*]
     2 str = vc
 )
 FREE RECORD stmt_buffer
 RECORD stmt_buffer(
   1 err_ind = i2
   1 data[*]
     2 stmt = vc
 )
 FREE RECORD trig_name
 RECORD trig_name(
   1 qual[*]
     2 trig = vc
     2 trig_table = vc
 )
 FREE RECORD drop_func
 RECORD drop_func(
   1 data[*]
     2 stmt = vc
 )
 FREE RECORD daclt_nordds_rs
 RECORD daclt_nordds_rs(
   1 dnr_hold[*]
     2 table_name = vc
 )
 FREE RECORD refchg_tab_r
 RECORD refchg_tab_r(
   1 child[*]
     2 child_table = vc
     2 child_tab_sfx = vc
     2 proc_name = vc
     2 old_proc_name = vc
     2 regen_ind = i2
     2 parent[*]
       3 parent_table = vc
       3 parent_id_col = vc
       3 parent_tab_col = vc
       3 pk_where = vc
       3 md_value_str = vc
       3 md_var_str = vc
 )
 FREE RECORD refchg_xlat_create
 RECORD refchg_xlat_create(
   1 tbl[*]
     2 tbl_name = vc
     2 column_name = vc
 )
 FREE RECORD refchg_xlat_drop
 RECORD refchg_xlat_drop(
   1 qual[*]
     2 trigger_name = vc
 )
 FREE RECORD daclt_trig_info
 RECORD daclt_trig_info(
   1 qual[*]
     2 table_name = vc
     2 trigger_count = i4
 )
 FREE RECORD daclt_ptam_env_list
 RECORD daclt_ptam_env_list(
   1 ptam_on_ind = i2
   1 target_cnt = i4
   1 env_ids = vc
 )
 FREE RECORD md_request
 RECORD md_request(
   1 remote_env_id = f8
   1 local_env_id = f8
   1 post_link_name = vc
   1 table_name = vc
 )
 FREE RECORD daclt_trg_data
 RECORD daclt_trg_data(
   1 err_ind = i2
   1 err_msg = vc
   1 table_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 table_suffix = vc
     2 mergeable_ind = i2
     2 reference_ind = i2
     2 filter_function = vc
     2 filter_parm[*]
       3 column_name = vc
       3 parm_name = vc
       3 data_type = vc
     2 filter_str[*]
       3 add_str = vc
       3 upd_str = vc
       3 del_str = vc
       3 statement_ind = i2
     2 pkw_function = vc
     2 pkw_hash = f8
     2 pkw_parm[*]
       3 column_name = vc
       3 data_type = vc
       3 nullable = c1
     2 del_pkw_function = vc
     2 del_pkw_hash = f8
     2 del_pkw_parm[*]
       3 column_name = vc
       3 data_type = vc
       3 nullable = c1
       3 exist_ind = i2
     2 pk_ptam_function = vc
     2 colstring_function = vc
     2 colstring_parm[*]
       3 column_name = vc
       3 data_type = vc
     2 ptam_match_function = vc
     2 ptam_hash = f8
     2 ptam_parm[*]
       3 column_name = vc
       3 data_type = vc
       3 exist_ind = i2
       3 trans_ind = i2
       3 re_name = vc
       3 pe_col = vc
       3 xcptn_flag = i4
       3 cnst_val = vc
       3 object_name = vc
       3 ccl_data_type = vc
       3 all_exist_ind = i2
       3 custom_parm[*]
         4 parm_name = vc
 ) WITH protect
 SET add_trig_date = cnvtdatetime(curdate,curtime3)
 SET total_trigger_cnt = 0
 SET rs_ndx = 1
 SET v_single_tab_ind = 0
 SET refchg_tab_r_find = 0
 SET v_stmt_cnt = 0
 SET trig_drop_cnt = 0
 SET create_xlat_trig_flag = 0
 IF (validate(trg_regen_reason,"X")="X")
  DECLARE trg_regen_reason = vc
  SET trg_regen_reason = "Manual regeneration via ADD script"
 ENDIF
 IF (validate(trg_all_trigs_ind,- (1)) < 0)
  DECLARE trg_all_trigs_ind = i4
  SET trg_all_trigs_ind = 0
  FREE RECORD trg_event_info
  RECORD trg_event_info(
    1 cnt = i4
    1 qual[*]
      2 event_id = f8
      2 target_id = f8
  )
  SET trg_event_info->cnt = 0
 ENDIF
 SET daclt_ptam_env_list->target_cnt = 0
 SET daclt_ptam_env_list->env_ids = ""
 SET daclt_client_ident = dci_get_rdds_identifier(null)
 CALL dci_set_rdds_identifier("RDDS TRIGGER REGEN")
 IF (((reflect(parameter(1,0)) != "C*") OR (reflect(parameter(2,0)) != "C*")) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Expected syntax:  dm2_add_chg_log_triggers <table_name> <REFCHG>"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (size( $2,1) > 6)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("******INVALID TRIGGER PREFIX******")
  SET dm_err->eproc = concat("ATTEMPTED TRIGGER PREFIX WAS:", $2)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  SET ac_log_type = cnvtupper( $2)
  SET ac_table_name = cnvtupper( $1)
  SET daclt_pair_name = evaluate(ac_table_name,"PERSON","PRSNL","PRSNL","PERSON",
   " ")
 ENDIF
 IF (trg_all_trigs_ind=0)
  EXECUTE dm_rmc_check_unmapped
  IF (check_error(dm_err->eproc) > 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  EXECUTE dm2_rdds_metadata_refresh "NONE"
  IF ((dguc_reply->dguc_err_ind=1))
   SET dm_err->err_ind = 1
   GO TO exit_program
  ENDIF
  EXECUTE dm_rdds_update_trig_proc
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (((size(trim(ac_table_name),1) <= 1) OR (ichar(ac_table_name)=42)) )
   EXECUTE dm_create_rdds_logon_trg
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   daclt_src_id = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) > 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Selecting count on DM_CHG_LOG."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 SELECT INTO "NL:"
  count(*)
  FROM dm_chg_log dcl
  WITH maxqual(dcl,1)
 ;end select
 SET daclt_dcl_curqual = curqual
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Retrieving PTAM Environment Lists for current Source Environment."
 CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
 SELECT INTO "NL:"
  der.parent_env_id
  FROM dm_env_reltn der
  WHERE der.child_env_id=daclt_src_id
   AND der.relationship_type="PENDING TARGET AS MASTER"
  HEAD REPORT
   daclt_ptam_env_list->ptam_on_ind = 1
  DETAIL
   daclt_ptam_env_list->target_cnt = (daclt_ptam_env_list->target_cnt+ 1)
   IF ((daclt_ptam_env_list->target_cnt=1))
    daclt_ptam_env_list->env_ids = concat(trim(cnvtstring(der.parent_env_id)),".0")
   ELSE
    daclt_ptam_env_list->env_ids = concat(daclt_ptam_env_list->env_ids,", ",trim(cnvtstring(der
       .parent_env_id)),".0")
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name="SKIP TRIG CIRC PTAM BLOCK"
  DETAIL
   daclt_circ_ptam_ind = 0
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (check_open_event(daclt_src_id,0.0)=0)
  IF (trg_regen_reason != "Automatic Regeneration via open event"
   AND trg_regen_reason != "Automatic regeneration via readme"
   AND trg_regen_reason != "Manual regen from menu with no open event")
   IF ((validate(request->remote_env_id,- (1))=- (1)))
    SET md_request->remote_env_id = 0
   ELSE
    SET md_request->remote_env_id = request->remote_env_id
   ENDIF
   SET md_request->local_env_id = daclt_src_id
   SET md_request->table_name = ac_table_name
   EXECUTE dm2_refresh_local_meta_data  WITH replace("REQUEST","MD_REQUEST")
   IF (check_error(dm_err->eproc)=1)
    SET dguc_reply->dguc_err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   IF (daclt_pair_name > " ")
    SET md_request->table_name = daclt_pair_name
    EXECUTE dm2_refresh_local_meta_data  WITH replace("REQUEST","MD_REQUEST")
    IF (check_error(dm_err->eproc)=1)
     SET dguc_reply->dguc_err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
   ENDIF
  ENDIF
  EXECUTE dm_rmc_load_local_colstring ac_table_name
  IF ((dm_err->err_ind > 0))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (daclt_pair_name > " ")
   EXECUTE dm_rmc_load_local_colstring daclt_pair_name
   IF ((dm_err->err_ind > 0))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
 ELSE
  SELECT INTO "nl:"
   cnt = count(*)
   FROM dm_colstring_parm d
   DETAIL
    daclt_colstring_cnt = cnt
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) > 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (daclt_colstring_cnt=0)
   EXECUTE dm_rmc_load_local_colstring ac_table_name
   IF ((dm_err->err_ind > 0))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (daclt_pair_name > " ")
    EXECUTE dm_rmc_load_local_colstring daclt_pair_name
    IF ((dm_err->err_ind > 0))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
  ELSE
   EXECUTE dm_rmc_colstring_values "LOCAL", ac_table_name
   IF ((dm_err->err_ind > 0))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (daclt_pair_name > " ")
    EXECUTE dm_rmc_colstring_values "LOCAL", daclt_pair_name
    IF ((dm_err->err_ind > 0))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET drgtd_request->what_tables = ac_table_name
 IF ((drgtd_request->what_tables="PERSON"))
  SET drgtd_request->what_tables = "PRSNL"
  SET stat = alterlist(drgtd_request->req_special,1)
  SET drgtd_request->req_special[1].sp_tbl = "PERSON"
 ELSEIF ((drgtd_request->what_tables="PRSNL"))
  SET stat = alterlist(drgtd_request->req_special,1)
  SET drgtd_request->req_special[1].sp_tbl = "PERSON"
 ENDIF
 SET dm_err->eproc = "Executing DM_RMC_GET_TRG_DATA."
 EXECUTE dm_rmc_get_trg_data
 IF ((drgtd_reply->err_ind=1))
  CALL disp_msg(drgtd_reply->err_msg,dm_err->logfile,drgtd_reply->err_ind)
  SET dguc_reply->dguc_err_ind = 1
  GO TO exit_program
 ELSEIF (size(drgtd_reply->qual,5)=0)
  GO TO exit_program
 ENDIF
 SET daclt_trg_data->table_cnt = size(drgtd_reply->qual,5)
 SET stat = alterlist(daclt_trg_data->qual,daclt_trg_data->table_cnt)
 IF ((daclt_trg_data->table_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(daclt_trg_data->table_cnt))
   DETAIL
    daclt_trg_data->qual[d.seq].table_name = drgtd_reply->qual[d.seq].table_name, daclt_trg_data->
    qual[d.seq].table_suffix = drgtd_reply->qual[d.seq].table_suffix, daclt_trg_data->qual[d.seq].
    mergeable_ind = drgtd_reply->qual[d.seq].mergeable_ind,
    daclt_trg_data->qual[d.seq].reference_ind = drgtd_reply->qual[d.seq].reference_ind
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM dm_colstring_parm dcp
  WHERE expand(daclt_ndx,1,daclt_trg_data->table_cnt,dcp.table_name,daclt_trg_data->qual[daclt_ndx].
   table_name)
  ORDER BY dcp.table_name
  HEAD REPORT
   daclt_colstring_cnt = 0
  HEAD dcp.table_name
   daclt_colstring_cnt = (daclt_colstring_cnt+ 1)
  WITH nocounter
 ;end select
 IF ((daclt_colstring_cnt != daclt_trg_data->table_cnt))
  ROLLBACK
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "FAIL: Not all tables have colstring data."
  CALL disp_msg(drgtd_reply->err_msg,dm_err->logfile,1)
  SET dguc_reply->dguc_err_ind = 1
  GO TO exit_program
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Building trigger statements..."
 CALL disp_msg("",dm_err->logfile,0)
 IF (currdb="ORACLE")
  SELECT INTO "NL:"
   u.table_name
   FROM user_tables u
   WHERE u.table_name="DM_REFCHG_INVALID_XLAT"
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (curqual != 0)
   CALL refchg_xlat_gather(ac_table_name)
   IF (daclt_pair_name > " ")
    CALL refchg_xlat_gather(daclt_pair_name)
   ENDIF
   SET create_xlat_trig_flag = 1
  ENDIF
  FOR (loop_ndx = 1 TO size(refchg_tab_r->child,5))
   SET rs_ndx = locateval(rs_ndx,1,daclt_trg_data->table_cnt,refchg_tab_r->child[loop_ndx].
    child_table,daclt_trg_data->qual[rs_ndx].table_name)
   IF (rs_ndx > 0)
    IF ((refchg_tab_r->child[loop_ndx].regen_ind=1))
     CALL echo(concat("DROP PROCEDURE ",refchg_tab_r->child[loop_ndx].old_proc_name))
     CALL dm2_push_cmd(concat("RDB drop procedure ",refchg_tab_r->child[loop_ndx].old_proc_name," go"
       ),1)
    ENDIF
    SET daclt_trig_add = build("REFCHG",refchg_tab_r->child[loop_ndx].child_tab_sfx,"ADD")
    SET daclt_trig_del = build("REFCHG",refchg_tab_r->child[loop_ndx].child_tab_sfx,"DEL")
    SET daclt_trig_upd = build("REFCHG",refchg_tab_r->child[loop_ndx].child_tab_sfx,"UPD")
    SELECT INTO "NL:"
     u.trigger_name
     FROM user_triggers u
     WHERE u.trigger_name IN (daclt_trig_add, daclt_trig_del, daclt_trig_upd)
     HEAD REPORT
      cl_drop_cnt = 0
     DETAIL
      cl_drop_cnt = (cl_drop_cnt+ 1), stat = alterlist(cl_drop_stmt->qual,5), cl_drop_stmt->qual[
      cl_drop_cnt].stmt = concat("rdb drop trigger ",u.trigger_name," go")
     WITH nocounter
    ;end select
    IF (curqual > 0
     AND size(cl_drop_stmt->qual,5) > 0)
     SET dm_err->eproc = concat("Dropping RDDS triggers on ",daclt_trg_data->qual[rs_ndx].table_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     SET cl_drop_cnt = 0
     FOR (cl_drop_cnt = 1 TO size(cl_drop_stmt->qual,5))
       CALL dm2_push_cmd(cl_drop_stmt->qual[cl_drop_cnt].stmt,1)
     ENDFOR
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 FOR (daclt_num = 1 TO daclt_trg_data->table_cnt)
   IF ((daclt_trg_data->qual[daclt_num].table_name="PRSNL"))
    SET daclt_p_ndx = locateval(daclt_ndx,1,daclt_trg_data->table_cnt,"PERSON",daclt_trg_data->qual[
     daclt_ndx].table_name)
    IF (daclt_p_ndx > daclt_num)
     SET dm_err->eproc = "Creating RDDS functions and triggers for table PERSON."
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     SET daclt_err = dm2_trg_updt_cols_check("PERSON")
     IF (daclt_err < 0)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     IF ((daclt_ptam_env_list->ptam_on_ind=1)
      AND daclt_circ_ptam_ind=1)
      SET daclt_err = dcltr_get_circ_tab("PERSON")
      IF (daclt_err < 0)
       SET dm_err->err_ind = 1
       GO TO exit_program
      ENDIF
     ENDIF
     SET dm_err->eproc = "Calling create_refchg_filter_function_ora()."
     CALL create_refchg_filter_function_ora(daclt_p_ndx,v_drop_cnt,v_stmt_cnt)
     IF (check_error(dm_err->eproc)=1)
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = "Calling create_ptam_function_ora()."
     SET daclt_err = create_ptam_function_ora(daclt_trg_data,daclt_p_ndx,v_drop_cnt,v_stmt_cnt)
     IF (daclt_err < 0)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = "Calling create_pkw_function_ora()."
     SET daclt_err = create_pkw_function_ora(daclt_trg_data,daclt_p_ndx,v_drop_cnt,v_stmt_cnt)
     IF (daclt_err < 0)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = "Calling create_colstring_function_ora()."
     SET daclt_err = create_colstring_function_ora(daclt_trg_data,daclt_p_ndx,v_drop_cnt,v_stmt_cnt)
     IF (daclt_err < 0)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = "Calling create_refchg_trggers_ora()."
     SET daclt_err = create_refchg_triggers_ora(daclt_p_ndx,v_stmt_cnt,v_drop_cnt)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   IF ((((daclt_trg_data->qual[daclt_num].table_name != "PERSON")) OR (locateval(daclt_ndx,1,
    daclt_trg_data->table_cnt,"PRSNL",daclt_trg_data->qual[daclt_ndx].table_name) > daclt_num)) )
    SET dm_err->eproc = concat("Creating RDDS functions and triggers for table ",daclt_trg_data->
     qual[daclt_num].table_name,".")
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SET daclt_err = dm2_trg_updt_cols_check(daclt_trg_data->qual[daclt_num].table_name)
    IF (daclt_err < 0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
    IF ((daclt_ptam_env_list->ptam_on_ind=1)
     AND daclt_circ_ptam_ind=1)
     SET daclt_err = dcltr_get_circ_tab(daclt_trg_data->qual[daclt_num].table_name)
     IF (daclt_err < 0)
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
    ENDIF
    SET dm_err->eproc = "Calling create_refchg_filter_function_ora()."
    CALL create_refchg_filter_function_ora(daclt_num,v_drop_cnt,v_stmt_cnt)
    IF (check_error(dm_err->eproc)=1)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Calling create_ptam_function_ora()."
    SET daclt_err = create_ptam_function_ora(daclt_trg_data,daclt_num,v_drop_cnt,v_stmt_cnt)
    IF (daclt_err < 0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Calling create_pkw_function_ora()."
    SET daclt_err = create_pkw_function_ora(daclt_trg_data,daclt_num,v_drop_cnt,v_stmt_cnt)
    IF (daclt_err < 0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Calling create_colstring_function_ora()."
    SET daclt_err = create_colstring_function_ora(daclt_trg_data,daclt_num,v_drop_cnt,v_stmt_cnt)
    IF (daclt_err < 0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Calling create_refchg_trggers_ora()."
    SET daclt_err = create_refchg_triggers_ora(daclt_num,v_stmt_cnt,v_drop_cnt)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
   IF (create_xlat_trig_flag=1)
    SET dm_err->eproc = concat("Creating XLAT triggers for table ",daclt_trg_data->qual[daclt_num].
     table_name,".")
    CALL create_xlat_triggers(daclt_num,v_stmt_cnt)
   ENDIF
   CALL drop_old_functions(v_drop_cnt)
 ENDFOR
 IF (trg_all_trigs_ind=0)
  SET dm_err->eproc = "Getting REFCHG* triggers that need to be dropped off activity tables"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
  SELECT INTO "NL:"
   ut.trigger_name
   FROM user_triggers ut,
    dm_tables_doc_local dtd
   WHERE ((ut.trigger_name="REFCHG*ADD*") OR (((ut.trigger_name="REFCHG*UPD*") OR (((ut.trigger_name=
   "REFCHG*DEL*") OR (ut.trigger_name="REFCHGXLAT*")) )) ))
    AND ut.table_name=dtd.table_name
    AND ((dtd.reference_ind=0
    AND  NOT (ut.table_name IN (
   (SELECT
    rt.table_name
    FROM dm_rdds_refmrg_tables rt)))) OR ( EXISTS (
   (SELECT
    "x"
    FROM code_value cv
    WHERE cv.code_set=4001912
     AND cv.active_ind=1
     AND cv.cdf_meaning="NORDDSTRG"
     AND cv.display=ut.table_name))))
   DETAIL
    find_trigger_name_ndx = 0, find_trigger_name_ndx = locateval(find_trigger_name_ndx,1,size(
      refchg_xlat_drop,5),ut.trigger_name,refchg_xlat_drop->qual[find_trigger_name_ndx].trigger_name)
    IF (find_trigger_name_ndx=0)
     trig_drop_cnt = (trig_drop_cnt+ 1), stat = alterlist(refchg_xlat_drop->qual,trig_drop_cnt),
     refchg_xlat_drop->qual[trig_drop_cnt].trigger_name = ut.trigger_name
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc =
  "Getting REFCHG* triggers that need to be dropped off tables that do not exist on dm_tables_doc_local"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
  SELECT INTO "NL:"
   ut.trigger_name
   FROM user_triggers ut
   WHERE ((ut.trigger_name="REFCHG*ADD*") OR (((ut.trigger_name="REFCHG*UPD*") OR (((ut.trigger_name=
   "REFCHG*DEL*") OR (ut.trigger_name="REFCHGXLAT*")) )) ))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_tables_doc_local dtd
    WHERE ut.table_name=dtd.table_name)))
    AND  EXISTS (
   (SELECT
    "x"
    FROM dm_tables_doc dtd2
    WHERE ut.table_name=dtd2.table_name))
   DETAIL
    find_trigger_name_ndx = 0, find_trigger_name_ndx = locateval(find_trigger_name_ndx,1,size(
      refchg_xlat_drop,5),ut.trigger_name,refchg_xlat_drop->qual[find_trigger_name_ndx].trigger_name)
    IF (find_trigger_name_ndx=0)
     trig_drop_cnt = (trig_drop_cnt+ 1), stat = alterlist(refchg_xlat_drop->qual,trig_drop_cnt),
     refchg_xlat_drop->qual[trig_drop_cnt].trigger_name = ut.trigger_name
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc =
  "Getting REFCHG* triggers that need to be dropped off tables that do not exist on dm_tables_doc"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
  SELECT INTO "NL:"
   ut.trigger_name
   FROM user_triggers ut
   WHERE ((ut.trigger_name="REFCHG*ADD*") OR (((ut.trigger_name="REFCHG*UPD*") OR (((ut.trigger_name=
   "REFCHG*DEL*") OR (ut.trigger_name="REFCHGXLAT*")) )) ))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_tables_doc_local dtd
    WHERE ut.table_name=dtd.table_name)))
    AND ut.table_name != "*$C"
   DETAIL
    find_trigger_name_ndx = 0, find_trigger_name_ndx = locateval(find_trigger_name_ndx,1,size(
      refchg_xlat_drop,5),ut.trigger_name,refchg_xlat_drop->qual[find_trigger_name_ndx].trigger_name)
    IF (find_trigger_name_ndx=0)
     trig_drop_cnt = (trig_drop_cnt+ 1), stat = alterlist(refchg_xlat_drop->qual,trig_drop_cnt),
     refchg_xlat_drop->qual[trig_drop_cnt].trigger_name = ut.trigger_name
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = "Getting REFCHGXLAT* triggers that need to be dropped"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
  SELECT INTO "NL:"
   ut.trigger_name
   FROM user_triggers ut
   WHERE ut.trigger_name="REFCHGXLAT*"
    AND ut.table_name IN (
   (SELECT
    di.info_name
    FROM dm_info di
    WHERE di.info_domain="RDDS NO REFCHGXLAT"))
   DETAIL
    find_trigger_name_ndx = 0, find_trigger_name_ndx = locateval(find_trigger_name_ndx,1,size(
      refchg_xlat_drop,5),ut.trigger_name,refchg_xlat_drop->qual[find_trigger_name_ndx].trigger_name)
    IF (find_trigger_name_ndx=0)
     trig_drop_cnt = (trig_drop_cnt+ 1), stat = alterlist(refchg_xlat_drop->qual,trig_drop_cnt),
     refchg_xlat_drop->qual[trig_drop_cnt].trigger_name = ut.trigger_name
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  FOR (trig_drop_cnt = 1 TO size(refchg_xlat_drop->qual,5))
   SET trig_drop_stmt = concat("rdb drop trigger ",refchg_xlat_drop->qual[trig_drop_cnt].trigger_name,
    " go")
   CALL dm2_push_cmd(trig_drop_stmt,1)
  ENDFOR
 ENDIF
 SUBROUTINE create_refchg_filter_function_ora(i_trg_ndx,io_drop_cnt,io_stmt_cnt)
   DECLARE s_or_str = vc WITH protect, noconstant(" ")
   DECLARE s_mode = vc WITH protect, noconstant(" ")
   DECLARE s_if_str = vc WITH protect, noconstant(" ")
   DECLARE s_filter_ind = i2 WITH protect, noconstant(0)
   DECLARE s_filter_type = vc WITH protect, noconstant(" ")
   DECLARE s_statement_ind = i2 WITH protect, noconstant(0)
   DECLARE s_start_pos = i4 WITH protect, noconstant(0)
   DECLARE s_line_length = i4 WITH protect, noconstant(0)
   DECLARE s_continue_ind = i4 WITH protect, noconstant(0)
   DECLARE s_stmt_str = vc WITH protect, noconstant(" ")
   DECLARE s_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_drop_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_temp_str = vc WITH protect, noconstant(" ")
   DECLARE s_omf_prsnl_group_flg = i2 WITH protect, noconstant(0)
   SET s_omf_prsnl_group_flg = 1
   EXECUTE dm_rmc_filter_check daclt_trg_data->qual[i_trg_ndx].table_name
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "NL:"
    drf.filter_type, drf.statement_ind
    FROM dm_refchg_filter drf
    WHERE (drf.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
     AND drf.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_refchg_filter_parm p
     WHERE (p.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
      AND  NOT ( EXISTS (
     (SELECT
      "X"
      FROM user_tab_columns utc
      WHERE utc.table_name=p.table_name
       AND utc.column_name=p.column_name))))))
     AND  EXISTS (
    (SELECT
     "x"
     FROM dm_refchg_filter_test t
     WHERE drf.table_name=t.table_name
      AND t.active_ind=1))
    DETAIL
     s_filter_ind = 1, s_statement_ind = drf.statement_ind, s_filter_type = cnvtupper(drf.filter_type
      )
    WITH nocounter
   ;end select
   IF ((daclt_trg_data->qual[i_trg_ndx].table_name IN ("OMF_PVI_ATTRIB", "OMF_PVI_ATT_VALUE",
   "OMF_PVI_COMPONENT", "OMF_PVI_FILTER", "OMF_PVI_VO")))
    SET s_omf_prsnl_group_flg = 0
    SELECT INTO "NL:"
     FROM user_tab_columns utc
     WHERE utc.table_name="OMF_PV_ITEMS"
      AND utc.column_name="PRSNL_GROUP_ID"
     DETAIL
      s_omf_prsnl_group_flg = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
   ENDIF
   IF (s_omf_prsnl_group_flg=1)
    SET s_func_name = concat("REFCHG_FILTER_",daclt_trg_data->qual[i_trg_ndx].table_suffix,"_1")
    SET s_drop_func_name = ""
    SELECT INTO "NL:"
     uo.object_name
     FROM user_objects uo
     WHERE uo.object_name=patstring(concat("REFCHG_FILTER_",daclt_trg_data->qual[i_trg_ndx].
       table_suffix,"*"))
      AND uo.object_type="FUNCTION"
     DETAIL
      IF (uo.object_name=concat("REFCHG_FILTER_",daclt_trg_data->qual[i_trg_ndx].table_suffix,"_1"))
       s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_FILTER_",daclt_trg_data->qual[
        i_trg_ndx].table_suffix,"_2")
      ELSE
       s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_FILTER_",daclt_trg_data->qual[
        i_trg_ndx].table_suffix,"_1")
      ENDIF
     WITH nocounter
    ;end select
    SET daclt_trg_data->qual[i_trg_ndx].filter_function = s_func_name
    IF (s_drop_func_name > " ")
     SET io_drop_cnt = (io_drop_cnt+ 1)
     IF (mod(io_drop_cnt,50)=1)
      SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
     ENDIF
     SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
    ENDIF
    IF (s_filter_ind=0)
     SET daclt_trg_data->qual[i_trg_ndx].filter_function = ""
    ELSE
     SELECT INTO "nl:"
      drfp.column_name
      FROM dm_refchg_filter_parm drfp
      WHERE (drfp.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
       AND drfp.active_ind=1
      ORDER BY drfp.parm_nbr, drfp.column_name
      HEAD REPORT
       parm_cnt = 0
      DETAIL
       parm_cnt = (parm_cnt+ 1), stat = alterlist(daclt_trg_data->qual[i_trg_ndx].filter_parm,
        parm_cnt), daclt_trg_data->qual[i_trg_ndx].filter_parm[parm_cnt].column_name = cnvtupper(drfp
        .column_name),
       daclt_trg_data->qual[i_trg_ndx].filter_parm[parm_cnt].parm_name = concat(trim(substring(1,22,
          cnvtupper(drfp.column_name))),"_",trim(cnvtstring(drfp.parm_nbr)))
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      utc.data_type
      FROM user_tab_columns utc,
       (dummyt d  WITH seq = size(daclt_trg_data->qual[i_trg_ndx].filter_parm,5))
      PLAN (d)
       JOIN (utc
       WHERE (utc.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
        AND (utc.column_name=daclt_trg_data->qual[i_trg_ndx].filter_parm[d.seq].column_name))
      DETAIL
       daclt_trg_data->qual[i_trg_ndx].filter_parm[d.seq].data_type = utc.data_type
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      drft.test_str, drft.statement_ind
      FROM dm_refchg_filter_test drft
      WHERE (drft.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
       AND drft.active_ind=1
      ORDER BY drft.statement_ind
      HEAD REPORT
       test_cnt = 0
      DETAIL
       test_cnt = (test_cnt+ 1), stat = alterlist(daclt_trg_data->qual[i_trg_ndx].filter_str,test_cnt
        ), daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].add_str = drft.test_str,
       daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].upd_str = drft.test_str, daclt_trg_data->
       qual[i_trg_ndx].filter_str[test_cnt].del_str = drft.test_str, daclt_trg_data->qual[i_trg_ndx].
       filter_str[test_cnt].statement_ind = drft.statement_ind
       FOR (parm_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].filter_parm,5))
         s_temp_str = concat("::",daclt_trg_data->qual[i_trg_ndx].filter_parm[parm_ndx].column_name,
          "::"), daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].add_str = replace(
          daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].add_str,s_temp_str,concat("i_",
           daclt_trg_data->qual[i_trg_ndx].filter_parm[parm_ndx].parm_name,"_new"),0), daclt_trg_data
         ->qual[i_trg_ndx].filter_str[test_cnt].del_str = replace(daclt_trg_data->qual[i_trg_ndx].
          filter_str[test_cnt].del_str,s_temp_str,concat("i_",daclt_trg_data->qual[i_trg_ndx].
           filter_parm[parm_ndx].parm_name,"_old"),0)
       ENDFOR
       daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].upd_str = daclt_trg_data->qual[i_trg_ndx]
       .filter_str[test_cnt].add_str, daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].add_str =
       replace(daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].add_str,"<UTC_DIFF>",concat("-(",
         trim(cnvtstring((curutcdiff/ 60))),"/1440)")), daclt_trg_data->qual[i_trg_ndx].filter_str[
       test_cnt].upd_str = replace(daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].upd_str,
        "<UTC_DIFF>",concat("-(",trim(cnvtstring((curutcdiff/ 60))),"/1440)")),
       daclt_trg_data->qual[i_trg_ndx].filter_str[test_cnt].del_str = replace(daclt_trg_data->qual[
        i_trg_ndx].filter_str[test_cnt].del_str,"<UTC_DIFF>",concat("-(",trim(cnvtstring((curutcdiff
           / 60))),"/1440)"))
      WITH nocounter
     ;end select
     CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',daclt_trg_data->qual[
       i_trg_ndx].filter_function,'")'))
     CALL stmt_push(io_stmt_cnt,'ASIS("(i_mode varchar2")')
     FOR (fp_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].filter_parm,5))
      CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',daclt_trg_data->qual[i_trg_ndx].filter_parm[
        fp_ndx].parm_name,"_new ",daclt_trg_data->qual[i_trg_ndx].filter_parm[fp_ndx].data_type,'")')
       )
      CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',daclt_trg_data->qual[i_trg_ndx].filter_parm[
        fp_ndx].parm_name,"_old ",daclt_trg_data->qual[i_trg_ndx].filter_parm[fp_ndx].data_type,'")')
       )
     ENDFOR
     CALL stmt_push(io_stmt_cnt,'ASIS(") return number as v_return_val number; begin ")')
     CALL stmt_push(io_stmt_cnt,'ASIS("  v_return_val := 0; ")')
     FOR (mode_ndx = 1 TO 3)
       IF (mode_ndx=1)
        SET s_mode = "'ADD'"
       ELSEIF (mode_ndx=2)
        SET s_mode = "'UPD'"
       ELSE
        SET s_mode = "'DEL'"
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('ASIS("  if i_mode = ',s_mode,' then ")'))
       IF (s_filter_type IN ("INCLUDE", "EXCLUDE"))
        IF (s_filter_type="INCLUDE")
         CALL stmt_push(io_stmt_cnt,'ASIS("    if (")')
        ELSE
         CALL stmt_push(io_stmt_cnt,'ASIS("    if NOT (")')
        ENDIF
        SET s_or_str = " ("
        FOR (fs_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].filter_str,5))
          IF ((daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].statement_ind=0))
           IF (mode_ndx=1)
            SET s_if_str = daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].add_str
           ELSEIF (mode_ndx=2)
            SET s_if_str = daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].upd_str
           ELSE
            SET s_if_str = daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].del_str
           ENDIF
           CALL stmt_push(io_stmt_cnt,concat('ASIS("',s_or_str,s_if_str,'")'))
           SET s_or_str = ") OR ("
          ENDIF
        ENDFOR
        CALL stmt_push(io_stmt_cnt,'ASIS(")) then v_return_val :=1; end if;")')
       ENDIF
       IF (s_statement_ind=1)
        FOR (fs_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].filter_str,5))
          IF ((daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].statement_ind=1))
           IF (((s_filter_type IN ("INCLUDE", "EXCLUDE")) OR (fs_ndx > 1)) )
            CALL stmt_push(io_stmt_cnt,'ASIS("if v_return_val = 1 then ")')
           ENDIF
           IF (mode_ndx=1)
            SET s_stmt_str = daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].add_str
           ELSEIF (mode_ndx=2)
            SET s_stmt_str = daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].upd_str
           ELSE
            SET s_stmt_str = daclt_trg_data->qual[i_trg_ndx].filter_str[fs_ndx].del_str
           ENDIF
           CALL stmt_push(io_stmt_cnt,concat('ASIS("',trim(s_stmt_str,3),'")'))
           IF (((s_filter_type IN ("INCLUDE", "EXCLUDE")) OR (fs_ndx > 1)) )
            CALL stmt_push(io_stmt_cnt,'ASIS("  end if;")')
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
       CALL stmt_push(io_stmt_cnt,'ASIS("    end if;")')
     ENDFOR
     CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_return_val);")')
     CALL stmt_push(io_stmt_cnt,'ASIS("  exception")')
     CALL stmt_push(io_stmt_cnt,'ASIS("     when no_data_found then")')
     CALL stmt_push(io_stmt_cnt,'ASIS("        return(1);")')
     CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
     CALL stmt_push(io_stmt_cnt,"end go")
     SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
     EXECUTE dm2_stmt_exe "FUNCTION", daclt_trg_data->qual[i_trg_ndx].filter_function WITH replace(
      "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
     SET v_stmt_cnt = 0
     IF ((se_reply->err_ind=1))
      SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE create_refchg_triggers_ora(i_trg_ndx,io_stmt_cnt,io_drop_cnt)
   DECLARE s_type = c3 WITH protect
   DECLARE s_event = c6 WITH protect
   DECLARE s_old_new = c5 WITH protect
   DECLARE s_del_ind_str = c1 WITH protect
   DECLARE s_trigger_name = vc WITH protect, noconstant(" ")
   DECLARE s_log_type = vc WITH protect, noconstant(" ")
   DECLARE s_pkw_type = vc WITH protect, noconstant(" ")
   DECLARE ic_idx = i4 WITH protect, noconstant(0)
   DECLARE ic_idx2 = i4 WITH protect, noconstant(0)
   DECLARE ic_string = vc WITH protect, noconstant(" ")
   DECLARE cto_lob_ind = i2 WITH protect, noconstant(0)
   DECLARE cto_del_ndx = i2 WITH protect, noconstant(0)
   DECLARE s_unm_chg = i2 WITH protect, noconstant(0)
   DECLARE i_person_ndx = i4 WITH protect, noconstant(0)
   DECLARE s_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE s_col_name = vc WITH protect, noconstant(" ")
   DECLARE s_trig_suffix = vc WITH protect, noconstant(" ")
   DECLARE s_temp_loop = i4 WITH protect, noconstant(0)
   DECLARE s_curqual = i4 WITH protect, noconstant(0)
   DECLARE s_obj_cnt = i4 WITH protect, noconstant(0)
   DECLARE s_obj_str = vc WITH protect, noconstant("")
   DECLARE cto_circ_pos = i4 WITH protect, noconstant(0)
   DECLARE cto_circ_idx = i4 WITH protect, noconstant(0)
   SET csa_tbl_cnt = 0
   SET csa_col_cnt = 0
   FREE RECORD s_updt_cols
   RECORD s_updt_cols(
     1 col_cnt = i4
     1 qual[*]
       2 column_name = vc
       2 nullable = c1
   ) WITH protect
   FREE RECORD drop_rs
   RECORD drop_rs(
     1 stmt[1]
       2 str = vc
   )
   IF ((daclt_trg_data->qual[i_trg_ndx].mergeable_ind=0)
    AND (daclt_trg_data->qual[i_trg_ndx].reference_ind=1)
    AND (daclt_trg_data->qual[i_trg_ndx].table_name != "ACCOUNT"))
    SET s_log_type = "NORDDS"
   ELSE
    SET s_log_type = ac_log_type
   ENDIF
   FOR (s_temp_loop = 1 TO 2)
    IF (s_temp_loop=1)
     SET s_trig_suffix = "_TEMP"
    ELSE
     SET s_trig_suffix = " "
    ENDIF
    FOR (type_ndx = 1 TO 3)
      IF (type_ndx=1)
       SET s_type = "ADD"
       SET s_pkw_type = "INS/UPD"
       SET s_event = "INSERT"
       SET s_old_new = ":NEW."
       SET s_del_ind_str = "0"
      ELSEIF (type_ndx=2)
       SET s_type = "UPD"
       SET s_pkw_type = "INS/UPD"
       SET s_event = "UPDATE"
       SET s_old_new = ":NEW."
       SET s_del_ind_str = "0"
      ELSE
       SET s_type = "DEL"
       SET s_pkw_type = "DELETE"
       SET s_event = "DELETE"
       SET s_old_new = ":OLD."
       SET s_del_ind_str = "1"
      ENDIF
      SET s_trigger_name = concat("REFCHG",daclt_trg_data->qual[i_trg_ndx].table_suffix,s_type)
      SELECT INTO "nl:"
       FROM user_triggers ut
       WHERE ut.trigger_name=concat(s_trigger_name,"$C")
        AND (ut.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
       DETAIL
        s_trigger_name = ut.trigger_name
       WITH nocounter
      ;end select
      SET dm_err->eproc = "Verifying if unmapped users can make changes to the table"
      SET s_unm_chg = 0
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain="UNMAPPED CHANGES EXCLUDE"
        AND (di.info_name=daclt_trg_data->qual[i_trg_ndx].table_name)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       GO TO exit_program
      ENDIF
      IF (curqual != 0)
       SET s_unm_chg = 1
      ENDIF
      SET s_trigger_name = concat(s_trigger_name,s_trig_suffix)
      CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace trigger ',s_trigger_name,'")'))
      SET cto_lob_ind = 0
      SET dm_err->eproc = concat("Checking for *LOB,LONG and *RAW data type columns for ",
       daclt_trg_data->qual[i_trg_ndx].table_name,".")
      CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
      SELECT INTO "NL:"
       FROM user_tab_columns utc
       WHERE (utc.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
        AND utc.data_type IN ("LOB", "CLOB", "BLOB", "LONG", "RAW",
       "LONG RAW")
       DETAIL
        cto_lob_ind = 1
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       GO TO exit_program
      ENDIF
      IF (s_event="UPDATE"
       AND cto_lob_ind=0)
       SET dm_err->eproc = "Selecting column list for update triggers."
       CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
       SELECT INTO "NL:"
        FROM user_tab_cols utc
        WHERE (utc.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
         AND  NOT (utc.column_name IN (
        (SELECT
         drtc.column_name
         FROM dm_refchg_trg_col drtc
         WHERE (drtc.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
          AND drtc.active_ind=1)))
         AND  NOT (utc.column_name IN ("UPDT_ID", "UPDT_APPLCTX", "UPDT_CNT", "UPDT_TASK",
        "UPDT_DT_TM"))
         AND utc.hidden_column="NO"
         AND utc.virtual_column="NO"
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM dm_info di
         WHERE di.info_domain="RDDS IGNORE COL LIST:*"
          AND sqlpassthru(" utc.column_name like di.info_name and utc.table_name like di.info_char"))
        ))
        HEAD REPORT
         s_col_cnt = 0
        DETAIL
         s_col_cnt = (s_col_cnt+ 1)
         IF (mod(s_col_cnt,10)=1)
          stat = alterlist(s_updt_cols->qual,(s_col_cnt+ 9))
         ENDIF
         s_updt_cols->qual[s_col_cnt].column_name = utc.column_name, s_updt_cols->qual[s_col_cnt].
         nullable = "Y"
        FOOT REPORT
         s_updt_cols->col_cnt = s_col_cnt, stat = alterlist(s_updt_cols->qual,s_updt_cols->col_cnt)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ENDIF
       SELECT INTO "NL:"
        FROM user_tab_columns utc
        WHERE (utc.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
         AND utc.column_name IN (
        (SELECT
         di.info_name
         FROM dm_info di
         WHERE di.info_domain=concat("RDDS UPDATE OF OVERRIDE::",daclt_trg_data->qual[i_trg_ndx].
          table_name)))
        HEAD REPORT
         s_col_cnt = s_updt_cols->col_cnt
        DETAIL
         ic_idx = 0, ic_idx = locateval(ic_idx2,1,s_col_cnt,utc.column_name,s_updt_cols->qual[ic_idx2
          ].column_name)
         IF (ic_idx=0)
          s_col_cnt = (s_col_cnt+ 1)
          IF (mod(s_col_cnt,10)=1)
           stat = alterlist(s_updt_cols->qual,(s_col_cnt+ 9))
          ENDIF
          s_updt_cols->qual[s_col_cnt].column_name = utc.column_name, s_updt_cols->qual[s_col_cnt].
          nullable = "Y"
         ENDIF
        FOOT REPORT
         s_updt_cols->col_cnt = s_col_cnt, stat = alterlist(s_updt_cols->qual,s_updt_cols->col_cnt)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ENDIF
       SET dm_err->eproc = "Gathering nullable information."
       SELECT INTO "nl:"
        FROM dm2_user_notnull_cols dunc
        WHERE (dunc.table_name=daclt_trg_data->qual[i_trg_ndx].table_name)
        DETAIL
         ic_idx2 = 0, ic_idx2 = locateval(ic_idx,1,s_updt_cols->col_cnt,dunc.column_name,s_updt_cols
          ->qual[ic_idx].column_name)
         IF (ic_idx2 > 0)
          s_updt_cols->qual[ic_idx2].nullable = "N"
         ENDIF
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ENDIF
       SET ic_string = "if (NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'YES')!='YES' or "
       FOR (ic_idx = 1 TO s_updt_cols->col_cnt)
        SET s_col_name = s_updt_cols->qual[ic_idx].column_name
        IF ((s_updt_cols->qual[ic_idx].nullable="N"))
         SET ic_string = concat(ic_string," :new.",trim(s_col_name)," != :old.",trim(s_col_name),
          " or ")
        ELSE
         SET ic_string = concat(ic_string,"(:new.",trim(s_col_name)," != :old.",trim(s_col_name),
          " or (:new.",trim(s_col_name)," is null and :old.",trim(s_col_name),
          " is not null) or (:new.",
          trim(s_col_name)," is not null and :old.",trim(s_col_name)," is null)) or ")
        ENDIF
       ENDFOR
       SET ic_string = replace(ic_string,"or"," ",2)
       SET ic_string = concat(ic_string," ) then")
      ENDIF
      CALL stmt_push(io_stmt_cnt,concat('ASIS(" after ',s_event," on ",'")'))
      CALL stmt_push(io_stmt_cnt,concat('ASIS(" ',daclt_trg_data->qual[i_trg_ndx].table_name,
        ' for each row")'))
      IF (ac_log_type="REFCHG")
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" when (',dm2_cl_trg_rec->refchg_context_chk,' )")'))
      ENDIF
      CALL stmt_push(io_stmt_cnt,'ASIS(" declare ")')
      IF ((daclt_ptam_env_list->ptam_on_ind=1))
       CALL stmt_push(io_stmt_cnt,'ASIS(" v_md_vers_update varchar2(2000); ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" v_sql_stmt varchar2(2000); ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" v_rep_pk_where varchar2(2000); ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" v_rtab_cnt number; ")')
       IF (((s_event="DELETE") OR (s_event="UPDATE")) )
        CALL stmt_push(io_stmt_cnt,'ASIS(" v_del_pk_where varchar2(2000); ")')
       ENDIF
       IF ((daclt_trg_data->qual[i_trg_ndx].table_name IN ("MED_DEF_FLEX", "MED_INGRED_SET")))
        CALL stmt_push(io_stmt_cnt,
         'ASIS(" v_med_type_flag medication_definition.med_type_flag%type; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS(" v_premix_ind medication_definition.premix_ind%type; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS(" v_found_row_ind number;")')
       ENDIF
      ENDIF
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_ptam_match_hash dm_chg_log.ptam_match_hash%TYPE; ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_pk_where dm_chg_log.pk_where%TYPE; ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_ptam_match dm_chg_log.ptam_match_query%TYPE; ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_temp_str varchar2(4000); ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_ptam_result dm_chg_log.ptam_match_result%TYPE; ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_ptam_result_str varchar2(4000); ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_col_string dm_chg_log.col_string%TYPE; ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" v_ctxt_user_id number; ")')
      CALL stmt_push(io_stmt_cnt,'ASIS(" begin ")')
      IF (s_event="UPDATE"
       AND cto_lob_ind=0)
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" ',ic_string,' ")'))
      ENDIF
      CALL stmt_push(io_stmt_cnt,^ASIS(" dm2_context_control('REFCHG TRIGGER','Y');")^)
      CALL stmt_push(io_stmt_cnt,
       ^ASIS(" if (NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG'),'DM2NULLVAL')!='NO') then ")^)
      IF ((daclt_trg_data->qual[i_trg_ndx].filter_function > " "))
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" if ',
         " NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'YES')!='YES' "," OR ",daclt_trg_data->
         qual[i_trg_ndx].filter_function,' (")'))
       FOR (fp_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].filter_parm,5))
        IF (fp_ndx=1)
         CALL stmt_push(io_stmt_cnt,concat(^ASIS(" '^,s_type,^' ")^))
        ENDIF
        CALL stmt_push(io_stmt_cnt,concat('ASIS(",:new.',daclt_trg_data->qual[i_trg_ndx].filter_parm[
          fp_ndx].column_name,",:old.",daclt_trg_data->qual[i_trg_ndx].filter_parm[fp_ndx].
          column_name,'")'))
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ) = 1 then ")')
      ENDIF
      IF (s_unm_chg=0)
       CALL stmt_push(io_stmt_cnt,'ASIS("if (dm_refchg_check_unmapped = 1) then")')
      ENDIF
      IF (s_pkw_type="INS/UPD")
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_pk_where := ',daclt_trg_data->qual[i_trg_ndx].
         pkw_function,'( ")'))
       FOR (pk_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].pkw_parm,5))
         IF (pk_ndx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS("',s_old_new,daclt_trg_data->qual[i_trg_ndx].
            pkw_parm[pk_ndx].column_name,' ")'))
         ELSE
          CALL stmt_push(io_stmt_cnt,concat('ASIS(",',s_old_new,daclt_trg_data->qual[i_trg_ndx].
            pkw_parm[pk_ndx].column_name,' ")'))
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
      ELSE
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_pk_where := ',daclt_trg_data->qual[i_trg_ndx].
         del_pkw_function,'( ")'))
       FOR (pk_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].del_pkw_parm,5))
         IF (pk_ndx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS("',s_old_new,daclt_trg_data->qual[i_trg_ndx].
            del_pkw_parm[pk_ndx].column_name,' ")'))
         ELSE
          CALL stmt_push(io_stmt_cnt,concat('ASIS(",',s_old_new,daclt_trg_data->qual[i_trg_ndx].
            del_pkw_parm[pk_ndx].column_name,' ")'))
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
      ENDIF
      CALL stmt_push(io_stmt_cnt,concat('ASIS("  v_col_string := ',daclt_trg_data->qual[i_trg_ndx].
        colstring_function,'( ")'))
      FOR (pk_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].colstring_parm,5))
        IF (pk_ndx=1)
         CALL stmt_push(io_stmt_cnt,concat('ASIS("',s_old_new,daclt_trg_data->qual[i_trg_ndx].
           colstring_parm[pk_ndx].column_name,' ")'))
        ELSE
         CALL stmt_push(io_stmt_cnt,concat('ASIS(",',s_old_new,daclt_trg_data->qual[i_trg_ndx].
           colstring_parm[pk_ndx].column_name,' ")'))
        ENDIF
      ENDFOR
      CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
      CALL stmt_push(io_stmt_cnt,concat('ASIS("  v_ptam_match := ',daclt_trg_data->qual[i_trg_ndx].
        ptam_match_function,'( ")'))
      FOR (pk_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].ptam_parm,5))
        IF (pk_ndx=1)
         CALL stmt_push(io_stmt_cnt,concat('ASIS("',s_old_new,daclt_trg_data->qual[i_trg_ndx].
           ptam_parm[pk_ndx].column_name,' ")'))
        ELSE
         CALL stmt_push(io_stmt_cnt,concat('ASIS(",',s_old_new,daclt_trg_data->qual[i_trg_ndx].
           ptam_parm[pk_ndx].column_name,' ")'))
        ENDIF
      ENDFOR
      CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
      CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_ptam_match,'<SOURCE_ID>',0); ")^)
      CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_temp_str,'<TARGET_ID>',0); ")^)
      CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_temp_str,'<DB_LINK>',''' '''); ")^)
      CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_temp_str,'<LOCAL_IND>',1); ")^)
      CALL stmt_push(io_stmt_cnt,
       ^ASIS("  v_temp_str := replace(v_temp_str,'<XLAT_TYPE>','''FROM'''); ")^)
      CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := 'select '|| v_temp_str || ' from dual'; ")^)
      CALL stmt_push(io_stmt_cnt,build('ASIS("  v_ptam_match_hash := ',daclt_trg_data->qual[i_trg_ndx
        ].ptam_hash,';")'))
      CALL stmt_push(io_stmt_cnt,'ASIS("   BEGIN ")')
      CALL stmt_push(io_stmt_cnt,'ASIS("      execute immediate v_temp_str into v_ptam_result; ")')
      CALL stmt_push(io_stmt_cnt,
       ^ASIS("      v_ptam_result_str := sys_context('CERNER', 'RDDS_PTAM_MATCH_RESULT_STR',4000);")^
       )
      CALL stmt_push(io_stmt_cnt,'ASIS("   exception when others then ")')
      CALL stmt_push(io_stmt_cnt,
       'ASIS("     v_ptam_result := 0; v_ptam_match_hash := 0; v_ptam_result_str := null;")')
      CALL stmt_push(io_stmt_cnt,'ASIS("   END;")')
      SET updt_ndx = 0
      SET updt_ndx = locateval(updt_ndx,1,dm2_cl_trg_updt_cols->tbl_cnt,daclt_trg_data->qual[
       i_trg_ndx].table_name,dm2_cl_trg_updt_cols->qual[updt_ndx].tname)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS(" proc_refchg_ins_dcl('^,daclt_trg_data->qual[i_trg_ndx
        ].table_name,"',v_pk_where,dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),'",
        s_log_type,"',",
        s_del_ind_str,",",evaluate(s_pkw_type,"DELETE","0",evaluate(dm2_cl_trg_updt_cols->qual[
          updt_ndx].updt_id_exist_ind,1,build(s_old_new,"updt_id"),0,"0")),",",evaluate(
         dm2_cl_trg_updt_cols->qual[updt_ndx].updt_task_exist_ind,1,build(s_old_new,"updt_task"),0,
         "0"),
        ",",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_applctx_exist_ind,1,build(s_old_new,
          "updt_applctx"),0,"0"),",NULL",",NULL",",v_ptam_match,v_ptam_result,v_col_string,",
        evaluate(s_pkw_type,"DELETE",concat(trim(cnvtstring(daclt_trg_data->qual[i_trg_ndx].
            del_pkw_hash)),".0,"),concat(trim(cnvtstring(daclt_trg_data->qual[i_trg_ndx].pkw_hash)),
          ".0,")),"v_ptam_match_hash",',0,v_ptam_result_str);")'))
      IF (s_type="UPD")
       SET s_del_ind_str = "1"
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" if ")'))
       FOR (pk_loop_cnt = 1 TO size(daclt_trg_data->qual[i_trg_ndx].del_pkw_parm,5))
         IF ((daclt_trg_data->qual[i_trg_ndx].del_pkw_parm.exist_ind=1))
          IF (pk_loop_cnt != 1)
           CALL stmt_push(io_stmt_cnt,'ASIS(" or ")')
          ENDIF
          SET cio_pseudo_column = daclt_trg_data->qual[i_trg_ndx].del_pkw_parm[pk_loop_cnt].
          column_name
          IF ((daclt_trg_data->qual[i_trg_ndx].del_pkw_parm[pk_loop_cnt].nullable="N"))
           CALL stmt_push(io_stmt_cnt,concat('ASIS(" (:new.',cio_pseudo_column," != :old.",
             cio_pseudo_column,') ")'))
          ELSE
           CALL stmt_push(io_stmt_cnt,concat('ASIS(" (:new.',cio_pseudo_column," != :old.",
             cio_pseudo_column," or (:new.",
             cio_pseudo_column," is null and :old.",cio_pseudo_column," is not null) or (:new.",
             cio_pseudo_column,
             " is not null and :old.",cio_pseudo_column,' is null)) ")'))
          ENDIF
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" then ")')
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_pk_where := ',daclt_trg_data->qual[i_trg_ndx].
         del_pkw_function,'(")'))
       FOR (pk_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].del_pkw_parm,5))
         IF (pk_ndx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS(" :old.',daclt_trg_data->qual[i_trg_ndx].
            del_pkw_parm[pk_ndx].column_name,' ")'))
         ELSE
          CALL stmt_push(io_stmt_cnt,concat('ASIS(", :old.',daclt_trg_data->qual[i_trg_ndx].
            del_pkw_parm[pk_ndx].column_name,' ")'))
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
       CALL stmt_push(io_stmt_cnt,concat('ASIS("  v_col_string := ',daclt_trg_data->qual[i_trg_ndx].
         colstring_function,'( ")'))
       FOR (pk_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].colstring_parm,5))
         IF (pk_ndx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS(" :old.',daclt_trg_data->qual[i_trg_ndx].
            colstring_parm[pk_ndx].column_name,' ")'))
         ELSE
          CALL stmt_push(io_stmt_cnt,concat('ASIS(", :old.',daclt_trg_data->qual[i_trg_ndx].
            colstring_parm[pk_ndx].column_name,' ")'))
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
       CALL stmt_push(io_stmt_cnt,concat('ASIS("  v_ptam_match := ',daclt_trg_data->qual[i_trg_ndx].
         ptam_match_function,'( ")'))
       FOR (pk_ndx = 1 TO size(daclt_trg_data->qual[i_trg_ndx].ptam_parm,5))
         IF (pk_ndx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS(" :old.',daclt_trg_data->qual[i_trg_ndx].ptam_parm[
            pk_ndx].column_name,' ")'))
         ELSE
          CALL stmt_push(io_stmt_cnt,concat('ASIS(", :old.',daclt_trg_data->qual[i_trg_ndx].
            ptam_parm[pk_ndx].column_name,' ")'))
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
       CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_ptam_match,'<SOURCE_ID>',0); ")^)
       CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_temp_str,'<TARGET_ID>',0); ")^)
       CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_temp_str,'<DB_LINK>',''' '''); ")^
        )
       CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := replace(v_temp_str,'<LOCAL_IND>',1); ")^)
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("  v_temp_str := replace(v_temp_str,'<XLAT_TYPE>','''FROM'''); ")^)
       CALL stmt_push(io_stmt_cnt,^ASIS("  v_temp_str := 'select '|| v_temp_str || ' from dual'; ")^)
       CALL stmt_push(io_stmt_cnt,build('ASIS("  v_ptam_match_hash := ',daclt_trg_data->qual[
         i_trg_ndx].ptam_hash,';")'))
       CALL stmt_push(io_stmt_cnt,'ASIS("   BEGIN ")')
       CALL stmt_push(io_stmt_cnt,'ASIS("      execute immediate v_temp_str into v_ptam_result; ")')
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("      v_ptam_result_str := sys_context('CERNER', 'RDDS_PTAM_MATCH_RESULT_STR',4000);")^
        )
       CALL stmt_push(io_stmt_cnt,'ASIS("   exception when others then ")')
       CALL stmt_push(io_stmt_cnt,
        'ASIS("     v_ptam_result := 0;  v_ptam_match_hash := 0; v_ptam_result_str := null;")')
       CALL stmt_push(io_stmt_cnt,'ASIS("   END;")')
       SET updt_ndx = 0
       SET updt_ndx = locateval(updt_ndx,1,dm2_cl_trg_updt_cols->tbl_cnt,daclt_trg_data->qual[
        i_trg_ndx].table_name,dm2_cl_trg_updt_cols->qual[updt_ndx].tname)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS(" proc_refchg_ins_dcl('^,daclt_trg_data->qual[
         i_trg_ndx].table_name,
         "',v_pk_where,dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),'",s_log_type,"',",
         s_del_ind_str,",",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_id_exist_ind,1,
          ":new.updt_id",0,"0"),",",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_task_exist_ind,
          1,":new.updt_task",0,"0"),
         ",",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_applctx_exist_ind,1,
          ":new.updt_applctx",0,"0"),",NULL",",NULL",",v_ptam_match,v_ptam_result,v_col_string,",
         trim(cnvtstring(daclt_trg_data->qual[i_trg_ndx].del_pkw_hash)),".0,","v_ptam_match_hash",
         ',0,v_ptam_result_str);")'))
       CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
       SET s_del_ind_str = "0"
      ENDIF
      IF ((daclt_trg_data->qual[i_trg_ndx].table_name="PRSNL")
       AND s_type="ADD")
       CALL stmt_push(io_stmt_cnt,'ASIS(" BEGIN ")')
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("   v_pk_where := 'WHERE t4859.PERSON_ID='||to_char(:new.PERSON_ID)||'.0'; ")^)
       SET i_person_ndx = locateval(ic_idx,1,daclt_trg_data->table_cnt,"PERSON",daclt_trg_data->qual[
        ic_idx].table_name)
       CALL stmt_push(io_stmt_cnt,concat('ASIS("   select ',daclt_trg_data->qual[i_person_ndx].
         ptam_match_function,'(")'))
       FOR (ic_idx = 1 TO size(daclt_trg_data->qual[i_person_ndx].ptam_parm,5))
         IF (ic_idx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS("p.',daclt_trg_data->qual[i_person_ndx].ptam_parm[
            ic_idx].column_name,'")'))
         ELSE
          CALL stmt_push(io_stmt_cnt,concat('ASIS(",p.',daclt_trg_data->qual[i_person_ndx].ptam_parm[
            ic_idx].column_name,'")'))
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,concat('ASIS("),',daclt_trg_data->qual[i_person_ndx].
         colstring_function,'(")'))
       FOR (ic_idx = 1 TO size(daclt_trg_data->qual[i_person_ndx].colstring_parm,5))
         IF (ic_idx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS("p.',daclt_trg_data->qual[i_person_ndx].
            colstring_parm[ic_idx].column_name,'")'))
         ELSE
          CALL stmt_push(io_stmt_cnt,concat('ASIS(",p.',daclt_trg_data->qual[i_person_ndx].
            colstring_parm[ic_idx].column_name,'")'))
         ENDIF
       ENDFOR
       CALL stmt_push(io_stmt_cnt,
        'ASIS(") into v_ptam_match,v_col_string from person p where p.person_id = :new.person_id; ")'
        )
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("     v_temp_str := replace(v_ptam_match,'<SOURCE_ID>',0); ")^)
       CALL stmt_push(io_stmt_cnt,^ASIS("     v_temp_str := replace(v_temp_str,'<TARGET_ID>',0); ")^)
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("     v_temp_str := replace(v_temp_str,'<DB_LINK>',''' '''); ")^)
       CALL stmt_push(io_stmt_cnt,^ASIS("     v_temp_str := replace(v_temp_str,'<LOCAL_IND>',1); ")^)
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("  v_temp_str := replace(v_temp_str,'<XLAT_TYPE>','''FROM'''); ")^)
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("     v_temp_str := 'select '|| v_temp_str || ' from dual'; ")^)
       CALL stmt_push(io_stmt_cnt,build('ASIS("      v_ptam_match_hash := ',daclt_trg_data->qual[
         i_person_ndx].ptam_hash,';")'))
       CALL stmt_push(io_stmt_cnt,'ASIS("     BEGIN ")')
       CALL stmt_push(io_stmt_cnt,'ASIS("       execute immediate v_temp_str into v_ptam_result; ")')
       CALL stmt_push(io_stmt_cnt,
        ^ASIS("      v_ptam_result_str := sys_context('CERNER', 'RDDS_PTAM_MATCH_RESULT_STR',4000);")^
        )
       CALL stmt_push(io_stmt_cnt,'ASIS("       exception when others then ")')
       CALL stmt_push(io_stmt_cnt,
        'ASIS("       v_ptam_result := 0; v_ptam_match_hash := 0; v_ptam_result_str := null;")')
       CALL stmt_push(io_stmt_cnt,'ASIS("     END;")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" EXCEPTION WHEN NO_DATA_FOUND THEN ")')
       CALL stmt_push(io_stmt_cnt,'ASIS("   null;")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" END; ")')
       SET updt_ndx = 0
       SET updt_ndx = locateval(updt_ndx,1,dm2_cl_trg_updt_cols->tbl_cnt,daclt_trg_data->qual[
        i_trg_ndx].table_name,dm2_cl_trg_updt_cols->qual[updt_ndx].tname)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS(" proc_refchg_ins_dcl('PERSON',v_pk_where,^,
         "dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),'",s_log_type,"',0,",evaluate(
          dm2_cl_trg_updt_cols->qual[updt_ndx].updt_id_exist_ind,1,":new.updt_id",0,"0"),
         ",",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_task_exist_ind,1,":new.updt_task",0,
          "0"),",",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_applctx_exist_ind,1,
          ":new.updt_applctx",0,"0"),",NULL",
         ",NULL",",v_ptam_match,v_ptam_result,v_col_string,",trim(cnvtstring(daclt_trg_data->qual[
           i_person_ndx].pkw_hash)),".0,","v_ptam_match_hash",
         ',0,v_ptam_result_str);")'))
      ENDIF
      IF ((daclt_ptam_env_list->ptam_on_ind=1))
       SET daclt_r_tab_name = cutover_tab_name(daclt_trg_data->qual[i_trg_ndx].table_name,
        daclt_trg_data->qual[i_trg_ndx].table_suffix)
       CALL stmt_push(io_stmt_cnt,
        ^ASIS(" if  NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'YES') ='YES' then")^)
       CALL stmt_push(io_stmt_cnt,concat(
         ^ASIS(" select count(*) into v_rtab_cnt from user_tables where table_name = '^,
         daclt_r_tab_name,^'; ")^))
       CALL stmt_push(io_stmt_cnt,'ASIS(" if (v_rtab_cnt > 0) then ")')
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("v_md_vers_update := 'UPDATE ^,daclt_r_tab_name,
         " set rdds_status_flag = 9003 where rdds_status_flag = 0 and rdds_source_env_id in( ",
         daclt_ptam_env_list->env_ids,' ) ")'))
       CALL stmt_push(io_stmt_cnt,concat('ASIS("and rdds_ptam_match_result = :v1 and ',
         ^ nvl(rdds_ptam_match_result_str,''null_vaLue_CHeck'') = nvl(:v2,''null_vaLue_CHeck'')';")^)
        )
       CALL stmt_push(io_stmt_cnt,
        'ASIS(" Execute immediate v_md_vers_update using v_ptam_result, v_ptam_result_str;")')
       SET cto_circ_pos = locateval(cto_circ_pos,1,dcltr_circ->tbl_cnt,daclt_trg_data->qual[i_trg_ndx
        ].table_name,dcltr_circ->tbl_qual[cto_circ_pos].table_name)
       IF (cto_circ_pos > 0)
        IF ((dm_err->debug_flag > 1))
         CALL echorecord(dcltr_circ)
        ENDIF
        FOR (cto_circ_idx = 1 TO dcltr_circ->tbl_qual[cto_circ_pos].circ_cnt)
          IF ((dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_exist_ind=1)
           AND (dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].fk_exist_ind=1))
           IF ((dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].fk_name_col > " "))
            CALL stmt_push(io_stmt_cnt,concat(^ASIS(" if evaluate_pe_name('^,daclt_trg_data->qual[
              i_trg_ndx].table_name,"','",dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].
              fk_id_col,"','",
              dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].fk_name_col,"',",s_old_new,
              dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].fk_name_col,") = '",
              dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_tab,^' then")^))
           ENDIF
           CALL stmt_push(io_stmt_cnt,concat(
             ^ASIS(" select count(*) into v_rtab_cnt from user_tables where table_name = '^,
             dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_r_tab,^'; ")^))
           CALL stmt_push(io_stmt_cnt,'ASIS(" if (v_rtab_cnt > 0) then ")')
           CALL stmt_push(io_stmt_cnt,concat(^ASIS("v_md_vers_update := 'UPDATE ^,dcltr_circ->
             tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_r_tab,
             " r set r.rdds_status_flag = 9003 where r.rdds_status_flag = 0 and r.rdds_source_env_id in( ",
             daclt_ptam_env_list->env_ids,' ) ")'))
           IF ((dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_name_col > " "))
            CALL stmt_push(io_stmt_cnt,concat('ASIS("and evaluate_pe_name(:tab, :id,:name, r.',
              dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_name_col,') = :tab2")')
             )
           ENDIF
           CALL stmt_push(io_stmt_cnt,concat('ASIS("and r.',dcltr_circ->tbl_qual[cto_circ_pos].
             circ_qual[cto_circ_idx].circ_id_col," IN (select s.",dcltr_circ->tbl_qual[cto_circ_pos].
             pk_col," from ",
             daclt_r_tab_name,
             " s where s.rdds_ptam_match_result = :v1 and nvl(s.rdds_ptam_match_result_str,''null_vaLue_CHeck'') ",
             " = nvl(:v2,''null_vaLue_CHeck'') and s.rdds_source_env_id in(",daclt_ptam_env_list->
             env_ids,^))';")^))
           IF ((dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_name_col > " "))
            CALL stmt_push(io_stmt_cnt,concat(^ASIS(" Execute immediate v_md_vers_update using '^,
              dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_tab,"','",dcltr_circ->
              tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_id_col,"','",
              dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].circ_name_col,"','",
              daclt_trg_data->qual[i_trg_ndx].table_name,^',v_ptam_result,v_ptam_result_str;")^))
           ELSE
            CALL stmt_push(io_stmt_cnt,
             'ASIS(" Execute immediate v_md_vers_update using v_ptam_result,v_ptam_result_str;")')
           ENDIF
           CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
           IF ((dcltr_circ->tbl_qual[cto_circ_pos].circ_qual[cto_circ_idx].fk_name_col > " "))
            CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
       IF ((daclt_trg_data->qual[i_trg_ndx].table_name="MED_DEF_FLEX"))
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS(" select count(*) into v_rtab_cnt from user_tables where table_name = 'MED_INGRED_SET5949$R'; ")^
          ))
        CALL stmt_push(io_stmt_cnt,'ASIS(" if (v_rtab_cnt > 0) then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   v_found_row_ind := 0;")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("   select count(*) into v_rtab_cnt from user_tables where table_name = 'MEDICATION_DEF1835$R'; ")^
          ))
        CALL stmt_push(io_stmt_cnt,'ASIS("   if (v_rtab_cnt > 0) then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     begin ")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("        v_md_vers_update := 'select m.med_type_flag, m.premix_ind,1 from MEDICATION_DEF1835$R m ^,
          " where m.item_id IN(select md.item_id from MED_DEF_FLEX5942$R md ",
          " where md.rdds_ptam_match_result = :v1 and nvl(md.rdds_ptam_match_result_str, ''null_vaLue_CHeck'') ",
          " = nvl(:v2,''null_vaLue_CHeck'')"," and md.rdds_source_env_id in(",
          daclt_ptam_env_list->env_ids,
          " )) and m.rdds_delete_ind = 0 and m.rdds_status_flag = 0 and m.rdds_source_env_id in(",
          daclt_ptam_env_list->env_ids,^)'; ")^))
        CALL stmt_push(io_stmt_cnt,concat(
          'ASIS("       Execute immediate v_md_vers_update into v_med_type_flag, v_premix_ind, v_found_row_ind',
          ' using v_ptam_result,v_ptam_result_str;")'))
        CALL stmt_push(io_stmt_cnt,'ASIS("     EXCEPTION ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("      WHEN NO_DATA_FOUND  or TOO_MANY_ROWS then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("        v_premix_ind := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("        v_med_type_flag := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     END; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   end if;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   if v_found_row_ind = 0 then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     BEGIN ")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("      v_md_vers_update := 'select m.med_type_flag, m.premix_ind from MEDICATION_DEFINITION m ^,
          " where m.item_id IN(select md.item_id from MED_DEF_FLEX5942$R md ",
          " where md.rdds_ptam_match_result = :v1 and nvl(md.rdds_ptam_match_result_str,''null_vaLue_CHeck'') = ",
          " nvl(:v2,''null_vaLue_CHeck'') and md.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          ^ ))'; ")^))
        CALL stmt_push(io_stmt_cnt,concat(
          'ASIS("       Execute immediate v_md_vers_update into v_med_type_flag, ',
          ' v_premix_ind using v_ptam_result, v_ptam_result_str;")'))
        CALL stmt_push(io_stmt_cnt,'ASIS("     EXCEPTION ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("       WHEN NO_DATA_FOUND or TOO_MANY_ROWS then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("         v_premix_ind := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("         v_med_type_flag := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     END; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   end if; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   if v_med_type_flag IN(3,4) then")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("     v_md_vers_update := 'UPDATE MED_INGRED_SET5949$R m set m.rdds_status_flag = 9003^,
          " where (m.parent_item_id,m.sequence) IN(select md.item_id,md.sequence from MED_DEF_FLEX5942$R md ",
          " where md.rdds_ptam_match_result = :v1 and nvl(md.rdds_ptam_match_result_str, ''null_vaLue_CHeck'') = ",
          " nvl(:v2, ''null_vaLue_CHeck'') and md.rdds_source_env_id in(",daclt_ptam_env_list->
          env_ids,
          " )) and m.rdds_status_flag = 0 and m.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          ^) '; ")^))
        CALL stmt_push(io_stmt_cnt,
         'ASIS("     Execute immediate v_md_vers_update using v_ptam_result,v_ptam_result_str;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   elsif v_med_type_flag = 2 or v_premix_ind = 1 then")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("     v_md_vers_update := 'UPDATE MED_INGRED_SET5949$R m set m.rdds_status_flag = 9003^,
          " where m.parent_item_id IN(select md.item_id from MED_DEF_FLEX5942$R md ",
          " where md.rdds_ptam_match_result = :v1 and nvl(md.rdd_ptam_match_result_str, ''null_vaLue_CHeck'') ",
          " = nvl(:v2, ''null_vaLue_CHeck'') and md.rdds_source_env_id in(",daclt_ptam_env_list->
          env_ids,
          " )) and m.rdds_status_flag = 0 and m.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          ^) '; ")^))
        CALL stmt_push(io_stmt_cnt,
         'ASIS("     Execute immediate v_md_vers_update using v_ptam_result,v_ptam_result_str;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   end if; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
       ELSEIF ((daclt_trg_data->qual[i_trg_ndx].table_name="MED_INGRED_SET"))
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS(" select count(*) into v_rtab_cnt from user_tables where table_name = 'MED_DEF_FLEX5942$R'; ")^
          ))
        CALL stmt_push(io_stmt_cnt,'ASIS(" if (v_rtab_cnt > 0) then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   v_found_row_ind := 0;")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("   select count(*) into v_rtab_cnt from user_tables where table_name = 'MEDICATION_DEF1835$R'; ")^
          ))
        CALL stmt_push(io_stmt_cnt,'ASIS("   if (v_rtab_cnt > 0) then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     begin ")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("        v_md_vers_update := 'select m.med_type_flag, m.premix_ind,1 from MEDICATION_DEF1835$R m ^,
          " where m.item_id IN(select mi.parent_item_id from MED_INGRED_SET5949$R mi ",
          " where mi.rdds_ptam_match_result = :v1 and nvl(mi.rdds_ptam_match_result_str,''null_vaLue_CHeck'') = ",
          " nvl(:v2,''null_vaLue_CHeck'') and mi.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          " )) and m.rdds_delete_ind = 0 and m.rdds_status_flag = 0 and m.rdds_source_env_id in(",
          daclt_ptam_env_list->env_ids,^ )'; ")^))
        CALL stmt_push(io_stmt_cnt,concat(
          'ASIS("       Execute immediate v_md_vers_update into v_med_type_flag, v_premix_ind, v_found_row_ind',
          ' using v_ptam_result, v_ptam_result_str;")'))
        CALL stmt_push(io_stmt_cnt,'ASIS("     EXCEPTION ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("      WHEN NO_DATA_FOUND  or TOO_MANY_ROWS then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("        v_premix_ind := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("        v_med_type_flag := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     END; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   end if;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   if v_found_row_ind = 0 then")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     BEGIN ")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("      v_md_vers_update := 'select m.med_type_flag, m.premix_ind from MEDICATION_DEFINITION m ^,
          " where m.item_id IN(select mi.parent_item_id from MED_INGRED_SET5949$R mi ",
          " where mi.rdds_ptam_match_result = :v1 and nvl(mi.rdds_ptam_match_result_str,''null_vaLue_CHeck'') = ",
          " nvl(:v2,''null_vaLue_CHeck'') and mi.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          ^ ))'; ")^))
        CALL stmt_push(io_stmt_cnt,concat(
          'ASIS("       Execute immediate v_md_vers_update into v_med_type_flag, v_premix_ind using v_ptam_result,',
          'v_ptam_result_str;")'))
        CALL stmt_push(io_stmt_cnt,'ASIS("     EXCEPTION ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("       WHEN NO_DATA_FOUND or TOO_MANY_ROWS then ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("         v_premix_ind := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("         v_med_type_flag := 0;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("     END; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   end if; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   if v_med_type_flag IN(3,4) then")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("     v_md_vers_update := 'UPDATE MED_DEF_FLEX5942$R m set m.rdds_status_flag = 9003^,
          " where (m.item_id,m.sequence) IN(select mi.parent_item_id,mi.sequence from MED_INGRED_SET5949$R mi ",
          " where mi.rdds_ptam_match_result = :v1 and nvl(mi.rdds_ptam_match_result_str,''null_vaLue_CHeck'') =",
          " nvl(:v2,''null_vaLue_CHeck'') and mi.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          " )) and m.rdds_status_flag = 0 and m.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          ^)'; ")^))
        CALL stmt_push(io_stmt_cnt,
         'ASIS("     Execute immediate v_md_vers_update using v_ptam_result,v_ptam_result_str;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   elsif v_med_type_flag = 2 or v_premix_ind = 1 then")')
        CALL stmt_push(io_stmt_cnt,concat(
          ^ASIS("     v_md_vers_update := 'UPDATE MED_DEF_FLEX5942$R m set m.rdds_status_flag = 9003^,
          " where m.item_id IN(select mi.parent_item_id from MED_INGRED_SET5949$R mi ",
          " where mi.rdds_ptam_match_result = :v1 and nvl(mi.rdds_ptam_match_result_str,''null_vaLue_CHeck'') = ",
          " nvl(:v2,''null_vaLue_CHeck'') and mi.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          " )) and m.rdds_status_flag = 0 and m.rdds_source_env_id in(",daclt_ptam_env_list->env_ids,
          ^)'; ")^))
        CALL stmt_push(io_stmt_cnt,
         'ASIS("     Execute immediate v_md_vers_update using v_ptam_result,v_ptam_result_str;")')
        CALL stmt_push(io_stmt_cnt,'ASIS("   end if; ")')
        CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
       ENDIF
       CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
      ENDIF
      IF (s_unm_chg=0)
       CALL stmt_push(io_stmt_cnt,'ASIS(" else ")')
       CALL stmt_push(io_stmt_cnt,concat(
         ^ASIS("  v_ctxt_user_id := SYS_CONTEXT('CERNER','RDDS UPDT_ID'); ")^))
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("  v_temp_str := 'RDDS T^,daclt_trg_data->qual[
         i_trg_ndx].table_suffix,": User-'|| v_ctxt_user_id||",
         ^' not allowed to change tracked reference data'; ")^))
       CALL stmt_push(io_stmt_cnt,concat('ASIS("  RAISE_APPLICATION_ERROR(-20203 ,v_temp_str); ")'))
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" end if; ")'))
      ENDIF
      IF ((daclt_trg_data->qual[i_trg_ndx].filter_function > " "))
       CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
      ENDIF
      CALL stmt_push(io_stmt_cnt,'ASIS(" else ")')
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   proc_refchg_dcl_smry_diag('^,daclt_trg_data->qual[
        i_trg_ndx].table_name,"','TRG',",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].
         updt_task_exist_ind,1,build(s_old_new,"updt_task"),0,"0"),",",
        evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_id_exist_ind,1,build(s_old_new,"updt_id"),
         0,"0"),');")'))
      CALL stmt_push(io_stmt_cnt,'ASIS(" end if;")')
      IF (s_event="UPDATE"
       AND cto_lob_ind=0)
       CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
      ENDIF
      CALL stmt_push(io_stmt_cnt,^ASIS(" dm2_context_control('REFCHG TRIGGER','N');")^)
      CALL stmt_push(io_stmt_cnt,'ASIS(" Exception ")')
      CALL stmt_push(io_stmt_cnt,'ASIS("   When others then ")')
      CALL stmt_push(io_stmt_cnt,^ASIS("     dm2_context_control('REFCHG TRIGGER','N'); ") ^)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   proc_refchg_dcl_smry_diag('^,daclt_trg_data->qual[
        i_trg_ndx].table_name,"','XCPTN',",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].
         updt_task_exist_ind,1,build(s_old_new,"updt_task"),0,"0"),",",
        evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_id_exist_ind,1,build(s_old_new,"updt_id"),
         0,"0"),');")'))
      CALL stmt_push(io_stmt_cnt,'ASIS("     raise; ") ')
      CALL stmt_push(io_stmt_cnt,'ASIS(" end; ")')
      CALL stmt_push(io_stmt_cnt,"end go")
      SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
      EXECUTE dm2_stmt_exe "TRIGGER", s_trigger_name WITH replace("REQUEST","STMT_BUFFER"), replace(
       "REPLY","SE_REPLY")
      SET v_stmt_cnt = 0
      IF ((se_reply->err_ind=1))
       SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      SET drop_rs->stmt[1].str = concat("RDB alter trigger ",s_trigger_name," compile go")
      EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DROP_RS")
      SET dm_err->eproc = concat("Checking validity of trigger ",s_trigger_name)
      SELECT INTO "nl:"
       FROM user_objects uo
       WHERE uo.object_name=s_trigger_name
        AND uo.object_type="TRIGGER"
        AND uo.status="VALID"
       WITH nocounter
      ;end select
      SET s_curqual = curqual
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       GO TO exit_program
      ENDIF
      IF (s_curqual=0)
       SET trace = callecho
       SET message = information
       SET s_obj_str = concat(
        "ue.name IN(s_trigger_name, daclt_trg_data->qual[i_trg_ndx].pkw_function,",
        "daclt_trg_data->qual[i_trg_ndx].del_pkw_function,daclt_trg_data->qual[i_trg_ndx].colstring_function,",
        "daclt_trg_data->qual[i_trg_ndx].ptam_match_function,daclt_trg_data->qual[i_trg_ndx].pk_ptam_function"
        )
       IF ((daclt_trg_data->qual[i_trg_ndx].filter_function > " "))
        SET s_obj_str = concat(s_obj_str,",daclt_trg_data->qual[i_trg_ndx].filter_function) ")
       ELSE
        SET s_obj_str = concat(s_obj_str,")")
       ENDIF
       SELECT INTO value(dm_err->logfile)
        FROM user_errors ue
        WHERE parser(s_obj_str)
        ORDER BY ue.name, ue.sequence
        HEAD REPORT
         "USER_ERROR REPORT FOR TRIGGER ", col + 1, s_trigger_name,
         col + 1, " ON TABLE ", col + 1,
         daclt_trg_data->qual[i_trg_ndx].table_name, row + 2
        HEAD ue.name
         row + 2, col 2, ue.name,
         row + 1
        DETAIL
         daclt_txt = substring(1,175,ue.text), col 4, daclt_txt,
         row + 1
        WITH nocounter, format = variable, formfeed = none,
         maxrow = 1, maxcol = 200, append
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ENDIF
      ENDIF
      IF (s_temp_loop=1)
       IF (s_curqual=0)
        SET io_drop_cnt = 5
        SET stat = alterlist(drop_func->data,io_drop_cnt)
        SET drop_func->data[1].stmt = concat("drop function ",daclt_trg_data->qual[i_trg_ndx].
         pkw_function)
        SET drop_func->data[2].stmt = concat("drop function ",daclt_trg_data->qual[i_trg_ndx].
         del_pkw_function)
        SET drop_func->data[3].stmt = concat("drop function ",daclt_trg_data->qual[i_trg_ndx].
         colstring_function)
        SET drop_func->data[4].stmt = concat("drop function ",daclt_trg_data->qual[i_trg_ndx].
         ptam_match_function)
        SET drop_func->data[5].stmt = concat("drop function ",daclt_trg_data->qual[i_trg_ndx].
         pk_ptam_function)
        IF ((daclt_trg_data->qual[i_trg_ndx].filter_function > " "))
         SET io_drop_cnt = 6
         SET stat = alterlist(drop_func->data,io_drop_cnt)
         SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",daclt_trg_data->qual[
          i_trg_ndx].filter_function)
        ENDIF
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("The trigger ",substring(1,(size(s_trigger_name) - 5),
          s_trigger_name)," for table ",daclt_trg_data->qual[i_trg_ndx].table_name,
         " would have been invalid.")
       ENDIF
       SET drop_rs->stmt[1].str = concat("RDB drop trigger ",s_trigger_name," go")
       EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DROP_RS")
       IF (s_curqual=0)
        CALL drop_old_functions(io_drop_cnt)
        RETURN
       ENDIF
      ELSE
       IF (s_curqual=0)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("The trigger ",s_trigger_name," for table ",daclt_trg_data->qual[
         i_trg_ndx].table_name," is invalid.")
        RETURN
       ENDIF
       SET daclt_temp_tab = daclt_trg_data->qual[i_trg_ndx].table_name
       SET daclt_tab_cnt = size(daclt_trig_info->qual,5)
       SET daclt_tab_found = locateval(daclt_num,1,daclt_tab_cnt,daclt_temp_tab,daclt_trig_info->
        qual[daclt_num].table_name)
       IF (daclt_tab_found > 0)
        SET daclt_trig_info->qual[daclt_tab_found].trigger_count = (daclt_trig_info->qual[
        daclt_tab_found].trigger_count+ 1)
       ELSE
        SET daclt_tab_cnt = (size(daclt_trig_info->qual,5)+ 1)
        SET stat = alterlist(daclt_trig_info->qual,daclt_tab_cnt)
        SET daclt_trig_info->qual[daclt_tab_cnt].table_name = daclt_temp_tab
        SET daclt_trig_info->qual[daclt_tab_cnt].trigger_count = 1
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE create_sc_proc_ora(i_dtd_ndx,i_found_ndx,io_stmt_cnt)
   DECLARE s_found2_ndx = i4
   DECLARE s_loop_ndx_child = i4
   DECLARE daclt_md_flag = i2
   SET daclt_md_flag = 0
   SET s_found2_ndx = binsearch_refchg(refchg_tab_r->child[i_found_ndx].parent[1].parent_table)
   IF (s_found2_ndx > 0
    AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name != "NAME_VALUE_PREFS"))
    SET dm_err->eproc = "Building SPECIAL TABLE PROCEDURE."
    CALL disp_msg("",dm_err->logfile,0)
    CALL stmt_push(io_stmt_cnt,concat('RDB asis("create or replace procedure ',refchg_tab_r->child[
      i_found_ndx].proc_name,'")'))
    CALL stmt_push(io_stmt_cnt,concat(
      'asis("(i_child_id number, i_parent_id number, i_parent_table varchar2,")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("i_updt_id number, i_updt_task number,")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("i_updt_applctx number, i_select_str varchar2) as")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_pk_where dm_chg_log.pk_where%TYPE;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_id number;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_table varchar2(30);")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("begin")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("if(i_parent_id is null) then")'))
    CALL stmt_push(io_stmt_cnt,concat(^asis("v_parent_table := '^,refchg_tab_r->child[i_found_ndx].
      parent[1].parent_table,^';")^))
    CALL stmt_push(io_stmt_cnt,concat('asis("select ',refchg_tab_r->child[i_found_ndx].parent[1].
      parent_id_col,'")'))
    IF ((refchg_tab_r->child[i_found_ndx].parent[1].parent_tab_col > ""))
     CALL stmt_push(io_stmt_cnt,concat('asis(", ',refchg_tab_r->child[i_found_ndx].parent[1].
       parent_tab_col,'")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("into v_parent_id, v_parent_table")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('asis("into v_parent_id")'))
    ENDIF
    CALL stmt_push(io_stmt_cnt,concat('asis("from ',refchg_tab_r->child[i_found_ndx].child_table,'")'
      ))
    CALL stmt_push(io_stmt_cnt,concat('asis("where ',rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[1].
      pk_name,' = i_child_id;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("else")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_id := i_parent_id;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_table := i_parent_table;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("if(v_parent_id is not null) then")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("   ',refchg_tab_r->child[s_found2_ndx].proc_name,
      '( v_parent_id,NULL,NULL,i_updt_id,i_updt_task,i_updt_applctx,NULL);")'))
   ELSE
    CALL stmt_push(io_stmt_cnt,concat('RDB asis("create or replace procedure ',refchg_tab_r->child[
      i_found_ndx].proc_name,'")'))
    CALL stmt_push(io_stmt_cnt,concat(
      'asis("(i_child_id number, i_parent_id number, i_parent_table varchar2,")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("i_updt_id number, i_updt_task number,")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("i_updt_applctx number, i_select_str varchar2) as")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_pk_where dm_chg_log.pk_where%TYPE;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_id number;")'))
    CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_table varchar2(30);")'))
    FOR (loop_ndx = 1 TO size(refchg_tab_r->child[i_found_ndx].parent,5))
      IF ((refchg_tab_r->child[i_found_ndx].parent[loop_ndx].md_value_str > "")
       AND (refchg_tab_r->child[i_found_ndx].parent[loop_ndx].md_value_str > ""))
       SET daclt_md_flag = 1
      ENDIF
    ENDFOR
    IF (daclt_md_flag=1)
     CALL stmt_push(io_stmt_cnt,concat('asis("v_num1 number;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_num2 number;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_num3 number;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_num4 number;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_num5 number;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_num6 number;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_num7 number;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_str1 varchar2(2000);")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_str2 varchar2(2000);")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_str3 varchar2(2000);")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_str4 varchar2(2000);")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_str5 varchar2(2000);")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_date1 date;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_date2 date;")'))
    ENDIF
    CALL stmt_push(io_stmt_cnt,concat('asis("begin")'))
    IF (((trim(refchg_tab_r->child[i_found_ndx].parent[1].md_var_str) <= " "
     AND trim(refchg_tab_r->child[i_found_ndx].parent[1].md_value_str) <= " ") OR ((refchg_tab_r->
    child[i_found_ndx].child_table="NAME_VALUE_PREFS"))) )
     CALL stmt_push(io_stmt_cnt,concat('asis("if(i_parent_id is null) then")'))
     CALL stmt_push(io_stmt_cnt,concat(^asis("v_parent_table := '^,refchg_tab_r->child[i_found_ndx].
       parent[1].parent_table,^';")^))
     CALL stmt_push(io_stmt_cnt,concat('asis("select ',refchg_tab_r->child[i_found_ndx].parent[1].
       parent_id_col,'")'))
     IF ((refchg_tab_r->child[i_found_ndx].parent[1].parent_tab_col > ""))
      CALL stmt_push(io_stmt_cnt,concat('asis(", ',refchg_tab_r->child[i_found_ndx].parent[1].
        parent_tab_col,'")'))
      CALL stmt_push(io_stmt_cnt,concat('asis("into v_parent_id, v_parent_table")'))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat('asis("into v_parent_id")'))
     ENDIF
     CALL stmt_push(io_stmt_cnt,concat('asis("from ',refchg_tab_r->child[i_found_ndx].child_table,
       '")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("where ',rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[1].
       pk_name,' = i_child_id;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("else")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_id := i_parent_id;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("v_parent_table := i_parent_table;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("if(v_parent_id is not null) then")'))
    ENDIF
    IF (size(refchg_tab_r->child[i_found_ndx].parent,5)=1)
     IF (trim(refchg_tab_r->child[i_found_ndx].parent[1].md_var_str) > " "
      AND trim(refchg_tab_r->child[i_found_ndx].parent[1].md_value_str) > " ")
      CALL stmt_push(io_stmt_cnt,concat(^asis("if i_select_str > ' ' then ")^))
      CALL stmt_push(io_stmt_cnt,concat('asis(" execute immediate i_select_str into ',refchg_tab_r->
        child[i_found_ndx].parent[1].md_var_str,';")'))
      CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
      CALL stmt_push(io_stmt_cnt,concat('asis("v_pk_where := ',refchg_tab_r->child[i_found_ndx].
        parent[1].pk_where,';")'))
      CALL stmt_push(io_stmt_cnt,concat('asis("proc_refchg_ins_log(i_parent_table, v_pk_where, ")'))
      CALL stmt_push(io_stmt_cnt,concat(
        'asis("dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),")'))
      CALL stmt_push(io_stmt_cnt,concat(
        ^asis("'REFCHG', 0, i_updt_id, i_updt_task, i_updt_applctx, NULL, NULL")^))
      CALL stmt_push(io_stmt_cnt,concat('asis(", 0.0);")'))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat('asis("v_pk_where := ',refchg_tab_r->child[i_found_ndx].
        parent[1].pk_where,';")'))
     ENDIF
    ELSE
     FOR (loop_ndx = 1 TO size(refchg_tab_r->child[i_found_ndx].parent,5))
      IF (loop_ndx=1)
       CALL stmt_push(io_stmt_cnt,concat(^asis("if(v_parent_table = '^,refchg_tab_r->child[
         i_found_ndx].parent[loop_ndx].parent_table,^') then")^))
      ELSE
       CALL stmt_push(io_stmt_cnt,concat(^asis("elsif(v_parent_table = '^,refchg_tab_r->child[
         i_found_ndx].parent[loop_ndx].parent_table,^') then")^))
      ENDIF
      IF ((refchg_tab_r->child[i_found_ndx].child_table="NAME_VALUE_PREFS")
       AND (refchg_tab_r->child[i_found_ndx].parent[loop_ndx].parent_table="DCP_INPUT_REF"))
       SET s_loop_ndx_child = locateval(s_loop_ndx_child,1,size(refchg_tab_r->child,5),
        "DCP_INPUT_REF",refchg_tab_r->child[s_loop_ndx_child].child_table)
       CALL stmt_push(io_stmt_cnt,concat('asis("select dcp_section_instance_id into v_num1")'))
       CALL stmt_push(io_stmt_cnt,concat(
         'asis("from dcp_input_ref where dcp_input_ref_id = v_parent_id;")'))
       CALL stmt_push(io_stmt_cnt,concat('asis(" ',refchg_tab_r->child[s_loop_ndx_child].proc_name,
         ^(NULL,v_num1,'DCP_SECTION_REF',i_updt_id,i_updt_task,i_updt_applctx,NULL);")^))
      ELSE
       IF ((refchg_tab_r->child[i_found_ndx].parent[loop_ndx].md_var_str > "")
        AND (refchg_tab_r->child[i_found_ndx].parent[loop_ndx].md_value_str > ""))
        CALL stmt_push(io_stmt_cnt,concat(^asis("if i_select_str > ' ' then")^))
        CALL stmt_push(io_stmt_cnt,concat('asis("execute immediate i_select_str into ',refchg_tab_r->
          child[i_found_ndx].parent[loop_ndx].md_var_str,';")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('asis("v_pk_where := ',refchg_tab_r->child[i_found_ndx].
         parent[loop_ndx].pk_where,';")'))
      ENDIF
     ENDFOR
     CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
    ENDIF
    IF ((refchg_tab_r->child[i_found_ndx].child_table="NAME_VALUE_PREFS"))
     CALL stmt_push(io_stmt_cnt,concat(^asis("if(v_parent_table != 'DCP_INPUT_REF') then")^))
     CALL stmt_push(io_stmt_cnt,concat('asis("proc_refchg_ins_log(v_parent_table, v_pk_where, ")'))
     CALL stmt_push(io_stmt_cnt,concat(
       'asis("dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),")'))
     CALL stmt_push(io_stmt_cnt,concat(
       ^asis("'REFCHG', 0, i_updt_id, i_updt_task, i_updt_applctx, NULL, NULL")^))
     CALL stmt_push(io_stmt_cnt,concat('asis(", 0.0);")'))
     CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
    ELSEIF (trim(refchg_tab_r->child[i_found_ndx].parent[1].md_var_str) <= " "
     AND trim(refchg_tab_r->child[i_found_ndx].parent[1].md_value_str) <= " ")
     CALL stmt_push(io_stmt_cnt,concat('asis("proc_refchg_ins_log(v_parent_table, v_pk_where, ")'))
     CALL stmt_push(io_stmt_cnt,concat(
       'asis("dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),")'))
     CALL stmt_push(io_stmt_cnt,concat(
       ^asis("'REFCHG', 0, i_updt_id, i_updt_task, i_updt_applctx, NULL, NULL")^))
     CALL stmt_push(io_stmt_cnt,concat('asis(", 0.0);")'))
    ENDIF
   ENDIF
   IF (((trim(refchg_tab_r->child[i_found_ndx].parent[1].md_var_str) <= " "
    AND trim(refchg_tab_r->child[i_found_ndx].parent[1].md_value_str) <= " ") OR ((refchg_tab_r->
   child[i_found_ndx].child_table="NAME_VALUE_PREFS"))) )
    CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
   ENDIF
   IF ((refchg_tab_r->child[i_found_ndx].child_table="NAME_VALUE_PREFS"))
    CALL stmt_push(io_stmt_cnt,concat('asis("exception when no_data_found then null;")'))
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('asis("end;")'))
   CALL stmt_push(io_stmt_cnt,"end go")
   CALL echo(concat("Creating procedure....",refchg_tab_r->child[i_found_ndx].proc_name))
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "PROCEDURE", refchg_tab_r->child[i_found_ndx].proc_name WITH replace(
    "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET v_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE create_sc_triggers_ora(i_dtd_find,i_upto_value,i_single_tab_ind,io_stmt_cnt)
   DECLARE s_dtd_ndx = i4
   DECLARE s_found_ndx = i4
   DECLARE s_trigger_name = vc
   DECLARE s_else_list = vc
   DECLARE s_if_str = vc
   DECLARE s_parm_list = vc
   DECLARE s_log_type = vc
   DECLARE s_parent_loop_cnt = i4
   DECLARE s_parent_pk = vc
   SET s_dtd_ndx = 0
   FOR (s_dtd_ndx = i_dtd_find TO i_upto_value)
     IF (((i_single_tab_ind=0) OR ((rs_dtd_reply->dtd_hold[s_dtd_ndx].process_ind=1))) )
      SET s_found_ndx = 0
      SET s_found_ndx = binsearch_refchg(rs_dtd_reply->dtd_hold[s_dtd_ndx].tbl_name)
      IF (s_found_ndx > 0)
       SET s_trigger_name = concat("REFCHG",rs_dtd_reply->dtd_hold[s_dtd_ndx].tbl_suffix)
       SELECT INTO "nl:"
        FROM user_triggers ut
        WHERE ut.trigger_name=concat(s_trigger_name,"$C")
         AND (ut.table_name=refchg_tab_r->child[s_found_ndx].child_table)
        DETAIL
         s_trigger_name = ut.trigger_name
        WITH nocounter
       ;end select
       CALL stmt_push(io_stmt_cnt,concat('RDB asis("create or replace trigger ',s_trigger_name,'")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("before update or insert or delete")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("on ',refchg_tab_r->child[s_found_ndx].child_table,
         '")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("for each row")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("when (1 = 1)")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("declare")'))
       IF (size(rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_parm,5) > 0)
        CALL stmt_push(io_stmt_cnt,concat('asis("v_filter_type  varchar2(20);")'))
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('asis("v_trig_type  varchar2(20);")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("v_pk_where  varchar2(1000);")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("v_updt_pk_where varchar2(1000);")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("v_select_str varchar2(500);")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("v_val_str varchar2(500);")'))
       IF ((refchg_tab_r->child[s_found_ndx].child_table IN ("NAME_VALUE_PREFS")))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_prsnl_id number;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_pe_name varchar2(30);")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_pe_id number;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_no_data_found_ind number;")'))
       ELSEIF (trim(refchg_tab_r->child[s_found_ndx].parent[1].md_value_str) > " "
        AND trim(refchg_tab_r->child[s_found_ndx].parent[1].md_var_str) > " ")
        CALL stmt_push(io_stmt_cnt,concat('asis("v_fk_id number;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_no_data_found_ind number;")'))
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('asis("begin")'))
       CALL stmt_push(io_stmt_cnt,'ASIS(" if deleting then ")')
       IF (size(rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_parm,5) > 0)
        CALL stmt_push(io_stmt_cnt,^ASIS("   v_filter_type := 'DEL'; ")^)
       ENDIF
       CALL stmt_push(io_stmt_cnt,^ASIS("   v_trig_type := 'DELETE'; ")^)
       CALL stmt_push(io_stmt_cnt,'ASIS(" elsif updating then ")')
       IF (size(rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_parm,5) > 0)
        CALL stmt_push(io_stmt_cnt,^ASIS("   v_filter_type := 'UPD'; ")^)
       ENDIF
       CALL stmt_push(io_stmt_cnt,^ASIS("   v_trig_type := 'INS/UPD'; ")^)
       CALL stmt_push(io_stmt_cnt,'ASIS(" else ")')
       IF (size(rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_parm,5) > 0)
        CALL stmt_push(io_stmt_cnt,^ASIS("   v_filter_type := 'ADD'; ")^)
       ENDIF
       CALL stmt_push(io_stmt_cnt,^ASIS("   v_trig_type := 'INS/UPD'; ")^)
       CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
       IF ((rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_function > " "))
        CALL stmt_push(io_stmt_cnt,concat('ASIS(" if ',rs_dtd_reply->dtd_hold[s_dtd_ndx].
          filter_function,' (")'))
        FOR (fp_ndx = 1 TO size(rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_parm,5))
         IF (fp_ndx=1)
          CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_filter_type")'))
         ENDIF
         CALL stmt_push(io_stmt_cnt,concat('ASIS(",:new.',rs_dtd_reply->dtd_hold[s_dtd_ndx].
           filter_parm[fp_ndx].column_name,",:old.",rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_parm[
           fp_ndx].column_name,'")'))
        ENDFOR
        CALL stmt_push(io_stmt_cnt,'ASIS(" ) = 1 then ")')
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('asis("if (deleting) then")'))
       IF ((refchg_tab_r->child[s_found_ndx].child_table IN ("NAME_VALUE_PREFS")))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_pe_name := :old.parent_entity_name;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_pe_id := :old.parent_entity_id;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("else")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_pe_name := :new.parent_entity_name;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_pe_id := :new.parent_entity_id;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_prsnl_id := 0;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_no_data_found_ind := 0;")'))
        SET s_parent_loop_cnt = 0
        SET s_else_list = ""
        CALL stmt_push(io_stmt_cnt,concat('asis("begin")'))
        FOR (loop_ndx = 1 TO size(refchg_tab_r->child[s_found_ndx].parent,5))
          IF ( NOT ((refchg_tab_r->child[s_found_ndx].parent[loop_ndx].parent_table IN (
          "DCP_INPUT_REF", "CONFIG_PREFS", "DCP_FORMS_REF", "PREDEFINED_PREFS"))))
           SET s_parent_loop_cnt = (s_parent_loop_cnt+ 1)
           IF (s_parent_loop_cnt=1)
            SET s_if_str = "if"
           ELSE
            SET s_if_str = "elsif"
           ENDIF
           CALL stmt_push(io_stmt_cnt,concat('asis("',s_if_str,"(v_pe_name = '",refchg_tab_r->child[
             s_found_ndx].parent[loop_ndx].parent_table,^') then")^))
           SET loop_ndx_parent = locateval(loop_ndx_parent,1,value(size(rs_dtd_reply->dtd_hold,5)),
            refchg_tab_r->child[s_found_ndx].parent[loop_ndx].parent_table,rs_dtd_reply->dtd_hold[
            loop_ndx_parent].tbl_name)
           IF ((refchg_tab_r->child[s_found_ndx].parent[loop_ndx].md_var_str > "")
            AND (refchg_tab_r->child[s_found_ndx].parent[loop_ndx].md_value_str > ""))
            CALL stmt_push(io_stmt_cnt,concat('asis("select ',refchg_tab_r->child[s_found_ndx].
              parent[loop_ndx].md_value_str," into v_prsnl_id,v_val_str from ",refchg_tab_r->child[
              s_found_ndx].parent[loop_ndx].parent_table," where ",
              rs_dtd_reply->dtd_hold[loop_ndx_parent].pk_hold[1].pk_name,' = v_pe_id;")'))
            CALL stmt_push(io_stmt_cnt,concat(
              ^asis("v_select_str := 'select ' || v_val_str || 'from dual';")^))
           ELSE
            CALL stmt_push(io_stmt_cnt,concat('asis("select prsnl_id into v_prsnl_id from ',
              refchg_tab_r->child[s_found_ndx].parent[loop_ndx].parent_table," where ",rs_dtd_reply->
              dtd_hold[loop_ndx_parent].pk_hold[1].pk_name,' = v_pe_id;")'))
           ENDIF
          ELSE
           IF (s_else_list > " ")
            SET s_else_list = build(s_else_list,",'",refchg_tab_r->child[s_found_ndx].parent[loop_ndx
             ].parent_table,"'")
           ELSE
            SET s_else_list = build("'",refchg_tab_r->child[s_found_ndx].parent[loop_ndx].
             parent_table,"'")
           ENDIF
          ENDIF
        ENDFOR
        IF (s_else_list > "")
         CALL stmt_push(io_stmt_cnt,concat('asis("elsif v_pe_name not in (',s_else_list,') then")'))
        ELSE
         CALL stmt_push(io_stmt_cnt,concat('asis("else")'))
        ENDIF
        CALL stmt_push(io_stmt_cnt,concat('asis("if (not deleting) then")'))
        CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_pk_where := ',rs_dtd_reply->dtd_hold[s_dtd_ndx].
          pkw_function,'(v_trig_type ")'))
        FOR (pk_ndx = 1 TO size(rs_dtd_reply->dtd_hold[s_dtd_ndx].pk_where_parm,5))
          CALL stmt_push(io_stmt_cnt,concat('ASIS(",:new.',rs_dtd_reply->dtd_hold[s_dtd_ndx].
            pk_where_parm[pk_ndx].column_name,' ")'))
        ENDFOR
        CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
        SET updt_ndx = 0
        SET updt_ndx = locateval(updt_ndx,1,dm2_cl_trg_updt_cols->tbl_cnt,rs_dtd_reply->dtd_hold[
         s_dtd_ndx].tbl_name,dm2_cl_trg_updt_cols->qual[updt_ndx].tname)
        CALL stmt_push(io_stmt_cnt,concat(^ASIS(" proc_refchg_ins_log('^,rs_dtd_reply->dtd_hold[
          s_dtd_ndx].tbl_name,
          "',v_pk_where,dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),'REFCHG',0,",evaluate(
           dm2_cl_trg_updt_cols->qual[updt_ndx].updt_id_exist_ind,1,":new.updt_id",0,"0"),",",
          evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_task_exist_ind,1,":new.updt_task",0,"0"),
          ",",evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_applctx_exist_ind,1,
           ":new.updt_applctx",0,"0"),",NULL",",NULL,",
          trim(cnvtstring(rs_dtd_reply->dtd_hold[i_dtd_find].pkw_vers_id)),'.0);")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("return;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("exception")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("when no_data_found then")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_no_data_found_ind := 1;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("end;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("if(v_prsnl_id = 0) then")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("if (deleting) then")'))
       ELSEIF (trim(refchg_tab_r->child[s_found_ndx].parent[1].md_value_str) > " "
        AND trim(refchg_tab_r->child[s_found_ndx].parent[1].md_var_str) > " ")
        SET dm_err->eproc = "Obtaining primary key for parent table"
        SET s_parent_pk = ""
        SELECT INTO "nl:"
         ucc.column_name
         FROM user_cons_columns ucc
         WHERE ucc.constraint_name IN (
         (SELECT
          uc.constraint_name
          FROM user_constraints uc
          WHERE (table_name=refchg_tab_r->child[s_found_ndx].parent[1].parent_table)
           AND constraint_type="P"))
         DETAIL
          s_parent_pk = ucc.column_name
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        CALL stmt_push(io_stmt_cnt,concat('asis("v_fk_id := :old.',trim(refchg_tab_r->child[
           s_found_ndx].parent[1].parent_id_col),';")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("else")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_fk_id := :new.',trim(refchg_tab_r->child[
           s_found_ndx].parent[1].parent_id_col),';")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("v_no_data_found_ind := 0;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("begin")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("select ',trim(refchg_tab_r->child[s_found_ndx].
           parent[1].md_value_str)," into v_val_str from ",trim(refchg_tab_r->child[s_found_ndx].
           parent[1].parent_table)," where ",
          trim(s_parent_pk),' = v_fk_id;")'))
        CALL stmt_push(io_stmt_cnt,concat(
          ^asis("v_select_str := 'select ' ||v_val_str|| ' from dual'; ")^))
        CALL stmt_push(io_stmt_cnt,concat('asis("exception")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("when no_data_found then v_no_data_found_ind :=1;")')
         )
        CALL stmt_push(io_stmt_cnt,concat('asis("end;")'))
        CALL stmt_push(io_stmt_cnt,concat('asis("if (deleting) then")'))
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_pk_where := ',rs_dtd_reply->dtd_hold[s_dtd_ndx].
         pkw_function,'(v_trig_type ")'))
       FOR (pk_ndx = 1 TO size(rs_dtd_reply->dtd_hold[s_dtd_ndx].pk_where_parm,5))
         CALL stmt_push(io_stmt_cnt,concat('ASIS(",:old.',rs_dtd_reply->dtd_hold[s_dtd_ndx].
           pk_where_parm[pk_ndx].column_name,' ")'))
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
       IF ((rs_dtd_reply->dtd_hold[i_dtd_find].mrg_ind=0)
        AND (rs_dtd_reply->dtd_hold[i_dtd_find].ref_ind=1)
        AND (rs_dtd_reply->dtd_hold[i_dtd_find].tbl_name != "ACCOUNT"))
        SET s_log_type = "NORDDS"
       ELSE
        SET s_log_type = ac_log_type
       ENDIF
       SET updt_ndx = 0
       SET updt_ndx = locateval(updt_ndx,1,dm2_cl_trg_updt_cols->tbl_cnt,rs_dtd_reply->dtd_hold[
        s_dtd_ndx].tbl_name,dm2_cl_trg_updt_cols->qual[updt_ndx].tname)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS(" proc_refchg_ins_log('^,rs_dtd_reply->dtd_hold[
         s_dtd_ndx].tbl_name,"',v_pk_where,dbms_utility.get_hash_value(v_pk_where, 0, 1073741824),'",
         s_log_type,"',1,",
         evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_id_exist_ind,1,"0"),",",evaluate(
          dm2_cl_trg_updt_cols->qual[updt_ndx].updt_task_exist_ind,1,":old.updt_task",0,"0"),",",
         evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_applctx_exist_ind,1,":old.updt_applctx",0,
          "0"),
         ",NULL",",NULL,",trim(cnvtstring(rs_dtd_reply->dtd_hold[i_dtd_find].pkw_vers_id)),'.0);")'))
       IF ((refchg_tab_r->child[s_found_ndx].child_table IN ("NAME_VALUE_PREFS")))
        CALL stmt_push(io_stmt_cnt,concat('asis("elsif(v_no_data_found_ind = 0) then")'))
       ELSE
        CALL stmt_push(io_stmt_cnt,concat('asis("else")'))
       ENDIF
       IF ((refchg_tab_r->child[s_found_ndx].parent[1].parent_tab_col > ""))
        CALL stmt_push(io_stmt_cnt,concat('asis("',refchg_tab_r->child[s_found_ndx].proc_name,
          "(NULL,:new.",refchg_tab_r->child[s_found_ndx].parent[1].parent_id_col," ,:new.",
          refchg_tab_r->child[s_found_ndx].parent[1].parent_tab_col,
          ',:new.updt_id,:new.updt_task,:new.updt_applctx,v_select_str);")'))
       ELSE
        CALL stmt_push(io_stmt_cnt,concat('asis("',refchg_tab_r->child[s_found_ndx].proc_name,
          "(NULL,:new.",refchg_tab_r->child[s_found_ndx].parent[1].parent_id_col," ,'",
          refchg_tab_r->child[s_found_ndx].parent[1].parent_table,
          ^',:new.updt_id,:new.updt_task,:new.updt_applctx,v_select_str);")^))
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('asis("if(updating and :new.',rs_dtd_reply->dtd_hold[
         s_dtd_ndx].pk_hold[1].pk_name," != :old.",rs_dtd_reply->dtd_hold[s_dtd_ndx].pk_hold[1].
         pk_name,') then")'))
       CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_updt_pk_where := ',rs_dtd_reply->dtd_hold[
         s_dtd_ndx].pkw_function,'(v_trig_type ")'))
       FOR (pk_ndx = 1 TO size(rs_dtd_reply->dtd_hold[s_dtd_ndx].pk_where_parm,5))
         CALL stmt_push(io_stmt_cnt,concat('ASIS(",:old.',rs_dtd_reply->dtd_hold[s_dtd_ndx].
           pk_where_parm[pk_ndx].column_name,' ")'))
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(" ); ")')
       SET updt_ndx = 0
       SET updt_ndx = locateval(updt_ndx,1,dm2_cl_trg_updt_cols->tbl_cnt,rs_dtd_reply->dtd_hold[
        s_dtd_ndx].tbl_name,dm2_cl_trg_updt_cols->qual[updt_ndx].tname)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS(" proc_refchg_ins_log('^,rs_dtd_reply->dtd_hold[
         s_dtd_ndx].tbl_name,
         "',v_updt_pk_where,dbms_utility.get_hash_value(v_updt_pk_where, 0, 1073741824),'",s_log_type,
         "',1,",
         evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_id_exist_ind,1,"0"),",",evaluate(
          dm2_cl_trg_updt_cols->qual[updt_ndx].updt_task_exist_ind,1,":old.updt_task",0,"0"),",",
         evaluate(dm2_cl_trg_updt_cols->qual[updt_ndx].updt_applctx_exist_ind,1,":old.updt_applctx",0,
          "0"),
         ",NULL",",NULL,",trim(cnvtstring(rs_dtd_reply->dtd_hold[i_dtd_find].pkw_vers_id)),'.0);")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
       CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
       IF ((refchg_tab_r->child[s_found_ndx].child_table IN ("NAME_VALUE_PREFS")))
        CALL stmt_push(io_stmt_cnt,concat('asis("end if;")'))
       ENDIF
       IF ((rs_dtd_reply->dtd_hold[s_dtd_ndx].filter_function > " "))
        CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
       ENDIF
       CALL stmt_push(io_stmt_cnt,concat('asis("end;")'))
       CALL stmt_push(io_stmt_cnt,"end go")
       CALL echo(concat("Creating trigger....REFCHG",rs_dtd_reply->dtd_hold[s_dtd_ndx].tbl_suffix))
       SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
       EXECUTE dm2_stmt_exe "TRIGGER", s_trigger_name WITH replace("REQUEST","STMT_BUFFER"), replace(
        "REPLY","SE_REPLY")
       SET v_stmt_cnt = 0
       IF ((se_reply->err_ind=1))
        SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       SET daclt_temp_tab = rs_dtd_reply->dtd_hold[s_dtd_ndx].tbl_name
       SET daclt_tab_cnt = size(daclt_trig_info->qual,5)
       SET daclt_tab_found = locateval(daclt_num,1,daclt_tab_cnt,daclt_temp_tab,daclt_trig_info->
        qual[daclt_num].table_name)
       IF (daclt_tab_found > 0)
        SET daclt_trig_info->qual[daclt_tab_found].trigger_count = (daclt_trig_info->qual[
        daclt_tab_found].trigger_count+ 1)
       ELSE
        SET daclt_tab_cnt = (size(daclt_trig_info->qual,5)+ 1)
        SET stat = alterlist(daclt_trig_info->qual,daclt_tab_cnt)
        SET daclt_trig_info->qual[daclt_tab_cnt].table_name = daclt_temp_tab
        SET daclt_trig_info->qual[daclt_tab_cnt].trigger_count = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE drop_old_functions(io_drop_cnt)
   FREE RECORD drop_rs
   RECORD drop_rs(
     1 stmt[1]
       2 str = vc
   )
   FOR (drop_ndx = 1 TO io_drop_cnt)
     CALL echo(concat("RDB ",drop_func->data[drop_ndx].stmt," go"))
     SET drop_rs->stmt[1].str = concat("RDB ",drop_func->data[drop_ndx].stmt," go")
     EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DROP_RS")
   ENDFOR
   SET io_drop_cnt = 0
   SET stat = alterlist(drop_func->data,0)
 END ;Subroutine
 SUBROUTINE create_xlat_triggers(i_dtd_ndx,io_stmt_cnt)
   DECLARE cxl_find_tbl_ndx = i4
   DECLARE cxl_trig_ins = vc
   DECLARE cxl_trig_del = vc
   DECLARE cxl_trig_upd = vc WITH protect, noconstant("")
   DECLARE cxl_trigger_name_ins = vc
   DECLARE cxl_trigger_name_del = vc
   DECLARE cxl_trigger_name_upd = vc WITH protect, noconstant("")
   DECLARE cxl_trigger_name_ins_c = vc
   DECLARE cxl_trigger_name_del_c = vc
   DECLARE cxl_trigger_name_upd_c = vc WITH protect, noconstant("")
   DECLARE cxl_create_flg = i2
   DECLARE cxl_drop_cnt = i4
   FREE RECORD cxl_drop
   RECORD cxl_drop(
     1 trig_cnt = i4
     1 trig_qual[*]
       2 drop_stmt = vc
   )
   SET cxl_create_flg = 0
   SET cxl_find_tbl_ndx = 0
   SET cxl_find_tbl_ndx = locateval(cxl_find_tbl_ndx,1,size(refchg_xlat_create->tbl,5),daclt_trg_data
    ->qual[i_dtd_ndx].table_name,refchg_xlat_create->tbl[cxl_find_tbl_ndx].tbl_name)
   SET cxl_table_name = daclt_trg_data->qual[i_dtd_ndx].table_name
   SET cxl_trig_ins = concat("REFCHGXLAT",daclt_trg_data->qual[i_dtd_ndx].table_suffix,"INS")
   SET cxl_trig_del = concat("REFCHGXLAT",daclt_trg_data->qual[i_dtd_ndx].table_suffix,"DEL")
   SET cxl_trig_upd = concat("REFCHGXLAT",daclt_trg_data->qual[i_dtd_ndx].table_suffix,"UPD")
   IF (cxl_find_tbl_ndx > 0)
    SET cxl_create_flg = 1
    SELECT INTO "NL:"
     FROM user_triggers ut
     WHERE ut.table_name=cxl_table_name
      AND ut.trigger_name IN (concat(cxl_trig_ins,"$C"), concat(cxl_trig_del,"$C"), concat(
      cxl_trig_upd,"$C"), cxl_trig_ins, cxl_trig_del,
     cxl_trig_upd)
     DETAIL
      IF (ut.trigger_name="*INS")
       cxl_trigger_name_ins = ut.trigger_name
      ELSEIF (ut.trigger_name="*DEL")
       cxl_trigger_name_del = ut.trigger_name
      ELSEIF (ut.trigger_name="*UPD")
       cxl_trigger_name_upd = ut.trigger_name
      ELSEIF (ut.trigger_name="*INS$C")
       cxl_trigger_name_ins_c = ut.trigger_name
      ELSEIF (ut.trigger_name="*DEL$C")
       cxl_trigger_name_del_c = ut.trigger_name
      ELSEIF (ut.trigger_name="*UPD$C")
       cxl_trigger_name_upd_c = ut.trigger_name
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET cxl_trig_ins = xlat_trigger_check(cxl_trigger_name_ins,cxl_trigger_name_ins_c,cxl_drop)
    SET cxl_trig_del = xlat_trigger_check(cxl_trigger_name_del,cxl_trigger_name_del_c,cxl_drop)
    SET cxl_trig_upd = xlat_trigger_check(cxl_trigger_name_upd,cxl_trigger_name_upd_c,cxl_drop)
    IF (cxl_trig_ins <= " ")
     SET cxl_trig_ins = concat("REFCHGXLAT",daclt_trg_data->qual[i_dtd_ndx].table_suffix,"INS")
    ENDIF
    IF (cxl_trig_del <= " ")
     SET cxl_trig_del = concat("REFCHGXLAT",daclt_trg_data->qual[i_dtd_ndx].table_suffix,"DEL")
    ENDIF
    IF (cxl_trig_upd <= " ")
     SET cxl_trig_upd = concat("REFCHGXLAT",daclt_trg_data->qual[i_dtd_ndx].table_suffix,"UPD")
    ENDIF
    CALL xlat_trig_create(cxl_trig_ins,refchg_xlat_create->tbl[cxl_find_tbl_ndx].column_name,
     refchg_xlat_create->tbl[cxl_find_tbl_ndx].tbl_name,io_stmt_cnt,1)
    CALL xlat_trig_execute(cxl_trigger_name_ins,io_stmt_cnt)
    CALL xlat_trig_create(cxl_trig_del,refchg_xlat_create->tbl[cxl_find_tbl_ndx].column_name,
     refchg_xlat_create->tbl[cxl_find_tbl_ndx].tbl_name,io_stmt_cnt,2)
    CALL xlat_trig_execute(cxl_trigger_name_del,io_stmt_cnt)
    CALL xlat_trig_create(cxl_trig_upd,refchg_xlat_create->tbl[cxl_find_tbl_ndx].column_name,
     refchg_xlat_create->tbl[cxl_find_tbl_ndx].tbl_name,io_stmt_cnt,3)
    CALL xlat_trig_execute(cxl_trigger_name_upd,io_stmt_cnt)
   ENDIF
   IF (cxl_create_flg=0)
    SELECT INTO "NL:"
     FROM user_triggers ut
     WHERE ut.table_name=cxl_table_name
      AND ut.trigger_name IN (patstring(concat(cxl_trig_ins,"*")), patstring(concat(cxl_trig_del,"*")
      ), patstring(concat(cxl_trig_upd,"*")))
     DETAIL
      cxl_drop->trig_cnt = (cxl_drop->trig_cnt+ 1), stat = alterlist(cxl_drop->trig_qual,cxl_drop->
       trig_cnt), cxl_drop->trig_qual[cxl_drop->trig_cnt].drop_stmt = concat("rdb drop trigger ",ut
       .trigger_name," go")
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
   ENDIF
   IF ((cxl_drop->trig_cnt > 0))
    FOR (cxl_drop_cnt = 1 TO cxl_drop->trig_cnt)
     CALL echo(cxl_drop->trig_qual[cxl_drop_cnt].drop_stmt,1)
     CALL dm2_push_cmd(cxl_drop->trig_qual[cxl_drop_cnt].drop_stmt,1)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE xlat_trigger_check(i_trigger_name,i_trigger_name_c,i_cxl_drop)
   IF (i_trigger_name > ""
    AND i_trigger_name_c > "")
    SET i_cxl_drop->trig_cnt = (i_cxl_drop->trig_cnt+ 1)
    SET stat = alterlist(i_cxl_drop->trig_qual,i_cxl_drop->trig_cnt)
    SET i_cxl_drop->trig_qual[i_cxl_drop->trig_cnt].drop_stmt = concat("rdb drop trigger ",
     i_trigger_name_c," go")
    RETURN(i_trigger_name)
   ELSEIF (i_trigger_name > "")
    RETURN(i_trigger_name)
   ELSEIF (i_trigger_name_c > "")
    RETURN(i_trigger_name_c)
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE xlat_trig_execute(i_trigger_name,io_stmt_cnt)
   CALL echo(concat("Creating trigger....",i_trigger_name))
   SET stat = alterlist(stmt_buffer->data,io_stmt_cnt)
   EXECUTE dm2_stmt_exe "TRIGGER", i_trigger_name WITH replace("REQUEST","STMT_BUFFER"), replace(
    "REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   SET v_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE xlat_trig_create(i_trigger_name,i_col_name,i_tab_name,io_stmt_cnt,i_flag)
   CALL stmt_push(io_stmt_cnt,concat('RDB asis("create or replace trigger ',i_trigger_name,' ")'))
   IF (i_flag=1)
    CALL stmt_push(io_stmt_cnt,'asis("after insert on")')
   ELSEIF (i_flag=2)
    CALL stmt_push(io_stmt_cnt,'asis("after delete on")')
   ELSEIF (i_flag=3)
    CALL stmt_push(io_stmt_cnt,concat('asis("after update of ',i_col_name,' on ")'))
   ELSE
    SET dm_err->err_ind = 1
    SET dguc_reply->dguc_err_ind = 1
    SET dm_err->emsg = concat("Problem encountered while trying to create trigger ",i_trigger_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('asis(" ',i_tab_name,' for each row")'))
   CALL stmt_push(io_stmt_cnt,concat(^asis("DECLARE v_tab_name varchar2(30) := '^,i_tab_name,^';")^))
   CALL stmt_push(io_stmt_cnt,'asis("begin ")')
   IF (i_flag=1)
    CALL xlat_trig_remove_invalid_xlat(i_col_name,i_tab_name,io_stmt_cnt)
   ELSEIF (i_flag=2)
    CALL xlat_trig_add_invalid_xlat(i_col_name,i_tab_name,io_stmt_cnt)
   ELSEIF (i_flag=3)
    CALL stmt_push(io_stmt_cnt,'asis("if")')
    CALL stmt_push(io_stmt_cnt,concat('asis(":new.',i_col_name," != ",":old.",i_col_name,
      ' then")'))
    CALL xlat_trig_remove_invalid_xlat(i_col_name,i_tab_name,io_stmt_cnt)
    CALL stmt_push(io_stmt_cnt,'asis("begin")')
    CALL xlat_trig_add_invalid_xlat(i_col_name,i_tab_name,io_stmt_cnt)
    CALL stmt_push(io_stmt_cnt,'asis("end;")')
    CALL stmt_push(io_stmt_cnt,'asis("end if;")')
   ELSE
    SET dm_err->err_ind = 1
    SET dguc_reply->dguc_err_ind = 1
    SET dm_err->emsg = concat("Problem encountered while trying to create trigger ",i_trigger_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL stmt_push(io_stmt_cnt,'asis("end;")')
   CALL stmt_push(io_stmt_cnt,"end go")
 END ;Subroutine
 SUBROUTINE xlat_trig_remove_invalid_xlat(i_xt_col_name,i_xt_tab_name,io_stmt_cnt)
   CALL stmt_push(io_stmt_cnt,concat(
     'asis("delete /*+ INDEX (dm_refchg_invalid_xlat xpkdm_refchg_invalid_xlat)*/ from',
     ' dm_refchg_invalid_xlat")'))
   CALL stmt_push(io_stmt_cnt,concat('asis("where parent_entity_id = :new.',i_xt_col_name,' ")'))
   CALL stmt_push(io_stmt_cnt,'asis("and parent_entity_name = v_tab_name ;")')
 END ;Subroutine
 SUBROUTINE xlat_trig_add_invalid_xlat(i_xt_col_name,i_xt_tab_name,io_stmt_cnt)
   CALL stmt_push(io_stmt_cnt,'asis("insert into dm_refchg_invalid_xlat")')
   CALL stmt_push(io_stmt_cnt,'asis("(parent_entity_id,parent_entity_name,updt_id")')
   CALL stmt_push(io_stmt_cnt,'asis(",updt_task,updt_cnt,updt_dt_tm,updt_applctx)")')
   CALL stmt_push(io_stmt_cnt,concat('asis("values(:old.',i_xt_col_name,
     ',v_tab_name,0,0,0,sysdate,0);")'))
   CALL stmt_push(io_stmt_cnt,'asis(" exception when DUP_VAL_ON_INDEX then null; ")')
 END ;Subroutine
 SUBROUTINE refchg_xlat_gather(i_table_name)
   DECLARE rxg_rcd_ndx = i4
   SET dm_err->eproc = "Gathering column information on tables that need REFCHGXLAT* triggers"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    drcd.column_name
    FROM dm_columns_doc_local drcd
    WHERE drcd.table_name=patstring(i_table_name)
     AND drcd.root_entity_name=drcd.table_name
     AND drcd.root_entity_attr=drcd.column_name
     AND  EXISTS (
    (SELECT
     "X"
     FROM user_tab_columns utc
     WHERE utc.table_name=drcd.table_name
      AND utc.column_name=drcd.column_name
      AND utc.data_type IN ("NUMBER", "FLOAT")))
     AND  NOT (drcd.table_name IN (
    (SELECT
     di.info_name
     FROM dm_info di
     WHERE di.info_domain="RDDS NO REFCHGXLAT")))
    HEAD REPORT
     rxg_rcd_ndx = size(refchg_xlat_create->tbl,5)
    DETAIL
     rxg_rcd_ndx = (rxg_rcd_ndx+ 1)
     IF (mod(rxg_rcd_ndx,10)=1)
      stat = alterlist(refchg_xlat_create->tbl,(rxg_rcd_ndx+ 9))
     ENDIF
     refchg_xlat_create->tbl[rxg_rcd_ndx].tbl_name = drcd.table_name, refchg_xlat_create->tbl[
     rxg_rcd_ndx].column_name = drcd.column_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
#exit_program
 IF ((dm_err->err_ind=0)
  AND (dguc_reply->dguc_err_ind=1))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = dguc_reply->dguc_err_msg
 ELSEIF ((dm_err->err_ind=1)
  AND (((dguc_reply->dguc_err_ind=0)) OR ((dguc_reply->dguc_err_msg <= " "))) )
  SET dguc_reply->dguc_err_ind = 1
  SET dguc_reply->dguc_err_msg = dm_err->emsg
 ENDIF
 IF ((dm_err->err_ind=0))
  IF (((trg_all_trigs_ind=0) OR ((trg_event_info->cnt=0))) )
   IF (((size(trim(ac_table_name),1) > 1) OR (ichar(ac_table_name) != 42)) )
    SET daclt_r_event = "Subset of Triggers Added"
    SET daclt_ev_reason = "Manual add of subset"
   ELSE
    SET daclt_r_event = "Add Environment Triggers"
    SET daclt_ev_reason = trg_regen_reason
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,size(derg_reply->child_env_list,5))
   FOR (i = 1 TO size(derg_reply->child_env_list,5))
     SET auto_ver_request->qual[i].rdds_event = daclt_r_event
     SET auto_ver_request->qual[i].cur_environment_id = daclt_src_id
     SET auto_ver_request->qual[i].paired_environment_id = derg_reply->child_env_list[i].env_id
     SET auto_ver_request->qual[i].event_reason = daclt_ev_reason
     SET stat = alterlist(auto_ver_request->qual[i].detail_qual,size(daclt_trig_info->qual,5))
     FOR (j = 1 TO size(daclt_trig_info->qual,5))
      SET auto_ver_request->qual[i].detail_qual[j].event_detail1_txt = daclt_trig_info->qual[j].
      table_name
      SET auto_ver_request->qual[i].detail_qual[j].event_value = daclt_trig_info->qual[j].
      trigger_count
     ENDFOR
   ENDFOR
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    SET dguc_reply->dguc_err_ind = 1
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
  ELSE
   FOR (daclt_ndx = 1 TO trg_event_info->cnt)
     FOR (j = 1 TO size(daclt_trig_info->qual,5))
       INSERT  FROM dm_rdds_event_detail dred
        SET dred.dm_rdds_event_detail_id = seq(dm_seq,nextval), dred.dm_rdds_event_log_id =
         trg_event_info->qual[daclt_ndx].event_id, dred.event_detail1_txt = daclt_trig_info->qual[j].
         table_name,
         dred.event_detail_value = daclt_trig_info->qual[j].trigger_count, dred.updt_applctx =
         reqinfo->updt_applctx, dred.updt_cnt = 0,
         dred.updt_dt_tm = cnvtdatetime(curdate,curtime3), dred.updt_id = reqinfo->updt_id, dred
         .updt_task = 4310001
        WITH nocounter
       ;end insert
     ENDFOR
   ENDFOR
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    GO TO exit_program
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SET dm_err->eproc = "...Ending dm2_add_chg_log_triggers"
 CALL final_disp_msg("dm2_log_triggers_")
 SET stat = alterlist(auto_ver_request->qual,0)
 SET auto_ver_reply->status = ""
 SET auto_ver_reply->status_msg = ""
 FREE RECORD cl_drop_stmt
 FREE RECORD iu_pk_where
 FREE RECORD del_pk_where
 FREE RECORD stmt_buffer
 FREE RECORD trig_name
 FREE RECORD rs_dtd_reply
 FREE RECORD rs_dtd_trans
 FREE RECORD order_pk
 FREE RECORD drop_func
 FREE RECORD daclt_nordds_rs
 FREE RECORD refchg_tab_r
 FREE RECORD refchg_xlat_drop
 FREE RECORD refchg_xlat_create
 FREE RECORD daclt_trg_data
 IF ((dm_err->debug_flag=0))
  SET trace = callecho
  SET message = information
 ENDIF
 CALL dci_set_rdds_identifier(daclt_client_ident)
END GO
