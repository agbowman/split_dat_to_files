CREATE PROGRAM dm_rmc_ui_dup_checker:dba
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
 DECLARE cutover_get_and_run_dml(i_table_name=vc,i_source_env_id=f8,i_move_long_ind=i2,i_batch_ind=i2,
  i_tgt_env_id=f8) = vc
 DECLARE create_merge_strs(i_tab_info=vc(ref)) = null
 DECLARE create_merge_stmts(i_table_name=vc,o_rs_stmts=vc(ref)) = null
 DECLARE get_meta_data(gmd_table_name=vc,gmd_tab_info=vc(ref)) = null
 DECLARE init_rs_data(ird_info=vc(ref)) = null
 DECLARE pk_data_default(i_tab_info=vc(ref),i_col_ndx=i4) = null
 DECLARE hextoraw() = vc
 DECLARE to_clob() = vc
 SUBROUTINE create_merge_stmts(i_table_name,o_rs_stmts)
   DECLARE v_temp_where_str = vc
   DECLARE v_vers_where_str = vc
   DECLARE v_ui_check_str = vc
   DECLARE v_merge_str = vc
   DECLARE v_delete_str = vc
   DECLARE v_insert_str = vc
   DECLARE v_update_str = vc
   DECLARE s_stmt_cnt = i4
   DECLARE delete_sel_str = vc
   DECLARE v_rdds_where_string = vc WITH protect
   DECLARE v_rdds_where_iu_string = vc WITH protect
   DECLARE v_rdds_where_del_string = vc WITH protect
   IF ((validate(drcd_debug_ind,- (1))=- (1)))
    DECLARE drcd_debug_ind = i2 WITH protect, constant(0)
   ENDIF
   DECLARE drcd_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE col_ndx = i4 WITH protect, noconstant(0)
   DECLARE drcd_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE drcd_circ_col_loop = i4 WITH protect, noconstant(0)
   DECLARE drcd_col_loop = i4 WITH protect, noconstant(0)
   DECLARE v_mover_string = vc
   DECLARE v_mover_alg5_string = vc
   DECLARE v_mvr_ind = i2
   DECLARE v_mvr_ch_ind = i2
   DECLARE drs_date_default = vc
   DECLARE drs_mon = vc
   DECLARE type_ndx = i4
   DECLARE cms_num = i4 WITH protect
   DECLARE cms_eff_str = vc WITH protect, noconstant("")
   DECLARE cms_type = vc WITH protect, noconstant("")
   DECLARE cms_sect_ndx = i4 WITH protect, noconstant(0)
   DECLARE v_upd1_sect2_dml = vc WITH protect, noconstant(" ")
   DECLARE v_ins1_sect1_dml = vc WITH protect, noconstant(" ")
   DECLARE cms_tier_cell_idx = i4 WITH protect, noconstant(0)
   DECLARE drcd_circ_col_idx = i4 WITH protect, noconstant(0)
   DECLARE drcd_temp_set_stmt = vc WITH protect, noconstant("")
   DECLARE drcd_temp_col_str = vc WITH protect, noconstant(" ")
   DECLARE drcd_temp_match_str = vc WITH protect, noconstant(" ")
   FREE RECORD tab_info
   RECORD tab_info(
     1 table_name = vc
     1 tab_$r = vc
     1 r_tab_exists = i2
     1 table_suffix = vc
     1 merge_delete_ind = i2
     1 versioning_ind = i2
     1 version_cdf = vc
     1 beg_eff_col_ndx = i4
     1 end_eff_col_ndx = i4
     1 pk_col_ndx = i4
     1 prev_pk_col_ndx = i4
     1 ui_match_str = vc
     1 ui_match_str_ovr = vc
     1 pk_diff_str = vc
     1 pk_match_str = vc
     1 pk_long_str = vc
     1 ui_col_list = vc
     1 ui_col_list_ovr = vc
     1 all_upd_val_str = vc
     1 all_ins_val_str = vc
     1 tm_all_upd_val_str = vc
     1 tm_all_ins_val_str = vc
     1 updt_upd_val_str = vc
     1 updt_col_list = vc
     1 updt_val_list = vc
     1 col_list = vc
     1 md_col_list = vc
     1 pk_col_list = vc
     1 default_row_str = vc
     1 long_call = vc
     1 long_pk_str = vc
     1 exception_flg9_ind = i2
     1 nullable_ui_ind = i2
     1 upd_col_list = vc
     1 upd_val_list = vc
     1 grouper_col_list = vc
     1 grouper_match_str = vc
     1 user_dt_tm_ind = i2
     1 static_active_ind = i2
     1 cols[*]
       2 long_ind = i2
       2 column_name = vc
       2 parent_entity_col = vc
       2 exception_flg = i4
       2 upd_val_str = vc
       2 ins_val_str = vc
       2 ident_ind = i2
       2 pk_ind = i2
       2 grouper_col_ind = i2
       2 md_ind = i2
       2 data_type = vc
       2 ccl_type = vc
       2 nullable = c1
       2 data_default = vc
       2 data_default_null_ind = i2
       2 sequence_name = vc
       2 circ_cnt = i4
       2 self_entity_name = vc
       2 circ_qual[*]
         3 circ_table_name = vc
         3 circ_pk_col_name = vc
         3 circ_fk_col_name = vc
         3 circ_entity_col_name = vc
   )
   FREE RECORD other_info
   RECORD other_info(
     1 table_name = vc
     1 tab_$r = vc
     1 r_tab_exists = i2
     1 table_suffix = vc
     1 merge_delete_ind = i2
     1 versioning_ind = i2
     1 version_cdf = vc
     1 beg_eff_col_ndx = i4
     1 end_eff_col_ndx = i4
     1 pk_col_ndx = i4
     1 prev_pk_col_ndx = i4
     1 ui_match_str = vc
     1 ui_match_str_ovr = vc
     1 pk_diff_str = vc
     1 pk_match_str = vc
     1 pk_long_str = vc
     1 ui_col_list = vc
     1 ui_col_list_ovr = vc
     1 all_upd_val_str = vc
     1 all_ins_val_str = vc
     1 tm_all_upd_val_str = vc
     1 tm_all_ins_val_str = vc
     1 updt_upd_val_str = vc
     1 updt_col_list = vc
     1 updt_val_list = vc
     1 col_list = vc
     1 md_col_list = vc
     1 pk_col_list = vc
     1 default_row_str = vc
     1 long_call = vc
     1 long_pk_str = vc
     1 exception_flg9_ind = i2
     1 nullable_ui_ind = i2
     1 upd_col_list = vc
     1 upd_val_list = vc
     1 grouper_col_list = vc
     1 grouper_match_str = vc
     1 user_dt_tm_ind = i2
     1 static_active_ind = i2
     1 cols[*]
       2 long_ind = i2
       2 column_name = vc
       2 parent_entity_col = vc
       2 exception_flg = i4
       2 upd_val_str = vc
       2 ins_val_str = vc
       2 ident_ind = i2
       2 pk_ind = i2
       2 grouper_col_ind = i2
       2 md_ind = i2
       2 data_type = vc
       2 ccl_type = vc
       2 nullable = c1
       2 data_default = vc
       2 data_default_null_ind = i2
       2 sequence_name = vc
       2 circ_cnt = i4
       2 self_entity_name = vc
       2 circ_qual[*]
         3 circ_table_name = vc
         3 circ_pk_col_name = vc
         3 circ_fk_col_name = vc
         3 circ_entity_col_name = vc
   )
   FREE RECORD drcd_orig_str
   RECORD drcd_orig_str(
     1 cols[*]
       2 str = vc
   )
   FREE RECORD dml_stmts
   RECORD dml_stmts(
     1 total = i4
     1 qual[*]
       2 type = vc
       2 stmt_cnt = i4
       2 stmt[*]
         3 stmt_text = vc
         3 stmt_section = i4
   ) WITH protect
   SET stat = alterlist(o_rs_stmts->stmt,0)
   SET s_stmt_cnt = 0
   SET v_rdds_where_str = concat(
    "rdds_context_name =v_context_to_set and rdds_source_env_id =v_source_env_id ",
    "and rdds_status_flag =v_status_flag"," and rowid=rbr_rowid")
   SET v_rdds_where_iu_str = concat("rdds_delete_ind = 0 and ",v_rdds_where_str)
   SET v_rdds_where_del_str = concat("rdds_delete_ind = 1 and ",v_rdds_where_str)
   CALL get_meta_data(i_table_name,tab_info)
   IF ((dm_err->err_ind=1))
    RETURN
   ENDIF
   IF ((tab_info->r_tab_exists=0))
    SET dm_err->emsg = build("****Table not found: ",tab_info->tab_$r,"****")
    SET dm_err->err_ind = 1
    RETURN
   ELSEIF (drcd_debug_ind != 1)
    SELECT INTO "nl:"
     FROM (parser(tab_info->tab_$r))
     WHERE (rdds_source_env_id=o_rs_stmts->source_env_id)
      AND rdds_status_flag < 9000
    ;end select
    IF (check_error(concat("Checking if rows need to be processed for ",tab_info->tab_$r))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual=0)
     SET dm_err->emsg = build("****No rows to process for table: ",tab_info->tab_$r,"****")
     SET dm_err->err_ind = 0
     RETURN
    ENDIF
   ENDIF
   SET dm_err->eproc = "Gathering DML extensions from DM_INFO."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CUTOVER DML::*"
     AND di.info_name=i_table_name
    ORDER BY di.info_domain
    DETAIL
     cms_type = substring(19,7,di.info_domain), type_ndx = locateval(cms_num,1,dml_stmts->total,
      cms_type,dml_stmts->qual[cms_num].type)
     IF (type_ndx=0)
      dml_stmts->total = (dml_stmts->total+ 1), stat = alterlist(dml_stmts->qual,dml_stmts->total),
      type_ndx = dml_stmts->total,
      dml_stmts->qual[type_ndx].type = cms_type
     ENDIF
     dml_stmts->qual[type_ndx].stmt_cnt = (dml_stmts->qual[type_ndx].stmt_cnt+ 1), stat = alterlist(
      dml_stmts->qual[type_ndx].stmt,dml_stmts->qual[type_ndx].stmt_cnt), dml_stmts->qual[type_ndx].
     stmt[dml_stmts->qual[type_ndx].stmt_cnt].stmt_text = di.info_char,
     dml_stmts->qual[type_ndx].stmt[dml_stmts->qual[type_ndx].stmt_cnt].stmt_section = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN
   ENDIF
   SET type_ndx = locateval(cms_num,1,dml_stmts->total,"UPDATE1",dml_stmts->qual[cms_num].type)
   IF (type_ndx > 0)
    SET cms_sect_ndx = locateval(cms_num,1,dml_stmts->qual[type_ndx].stmt_cnt,2,dml_stmts->qual[
     type_ndx].stmt[cms_num].stmt_section)
    IF (cms_sect_ndx > 0)
     SET v_upd1_sect2_dml = concat(" and ",dml_stmts->qual[type_ndx].stmt[cms_sect_ndx].stmt_text)
    ENDIF
   ENDIF
   SET type_ndx = locateval(cms_num,1,dml_stmts->total,"INSERT1",dml_stmts->qual[cms_num].type)
   IF (type_ndx > 0)
    SET cms_sect_ndx = locateval(cms_num,1,dml_stmts->qual[type_ndx].stmt_cnt,1,dml_stmts->qual[
     type_ndx].stmt[cms_num].stmt_section)
    IF (cms_sect_ndx > 0)
     SET v_ins1_sect1_dml = concat(" and ",dml_stmts->qual[type_ndx].stmt[cms_sect_ndx].stmt_text)
    ENDIF
   ENDIF
   CALL create_merge_strs(tab_info)
   SET v_mvr_ind = 0
   SELECT INTO "nl:"
    FROM dm_refchg_filter_test dr
    WHERE (dr.table_name=tab_info->table_name)
     AND trim(dr.mover_string) > " "
     AND dr.active_ind=1
    DETAIL
     v_mover_string = dr.mover_string
    WITH nocounter
   ;end select
   IF (check_error(build("While getting the mover_string for: ",tab_info->table_name))=1)
    CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
    RETURN
   ENDIF
   IF (curqual != 0)
    SET v_mover_string = replace(v_mover_string,"<SUFFIX>.","",0)
    SET v_mover_string = replace(v_mover_string,"<MERGE LINK>","",0)
    SET v_mvr_ind = 1
   ENDIF
   IF ((tab_info->merge_delete_ind=0))
    IF ((tab_info->table_name="SEG_GRP_SEQ_R"))
     SET v_delete_str = concat("delete from seg_grp_seq_r s where s.seg_cd IN ",
      "(select sr1.seg_cd from segment_reference sr1"," where sr1.seg_grp_cd in ",
      "(select sr2.seg_grp_cd from segment_reference sr2 ","where sr2.seg_cd in ",
      "(select r.seg_cd from seg_grp_seq_r3292$R r where ",v_rdds_where_iu_str," )))")
     CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_delete_str = concat("delete from seg_grp_seq_r s where s.seg_grp_seq_r_id IN ",
      "(select r.seg_grp_seq_r_id from seg_grp_seq_r3292$R r where ",v_rdds_where_str," )")
     CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ELSE
     SET v_delete_str = concat("delete from ",tab_info->table_name," where list(",tab_info->
      pk_col_list,") in (select ",
      tab_info->pk_col_list," from ",tab_info->tab_$r," where ",v_rdds_where_del_str,
      ") ")
     CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
   ENDIF
   IF ((tab_info->table_name="TIER_MATRIX"))
    SET cms_tier_cell_idx = locateval(cms_num,1,size(tab_info->cols),"TIER_CELL_ID",tab_info->cols[
     cms_num].column_name)
    IF ((tab_info->cols[cms_tier_cell_idx].exception_flg != 6))
     SET v_update_str = concat("update into ",tab_info->table_name," set ",tab_info->cols[tab_info->
      end_eff_col_ndx].column_name," = v_midminus1 ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where tier_group_cd in (select tier_group_cd from ",
      tab_info->tab_$r," where ",v_rdds_where_iu_str,
      ") "," and v_curdate between ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name," and ",
      tab_info->cols[tab_info->end_eff_col_ndx].column_name,
      " and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_update_str = concat("update into ",tab_info->table_name," set active_ind =0 ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where tier_group_cd in (select tier_group_cd from ",
      tab_info->tab_$r," where ",v_rdds_where_iu_str,
      ") "," and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " >= v_curdate and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_temp_where_str = concat(v_rdds_where_iu_str," and v_curdate between ",tab_info->cols[
      tab_info->beg_eff_col_ndx].column_name," and ",tab_info->cols[tab_info->end_eff_col_ndx].
      column_name,
      " and active_ind = 1 ")
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      tab_info->tm_all_upd_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      " and ",tab_info->pk_match_str,")"," where list(",tab_info->pk_col_list,
      ") in (select",tab_info->pk_col_list," from ",tab_info->tab_$r," r_A where ",
      v_temp_where_str,")")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->tm_all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      ' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(tab_info->
       pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_temp_where_str = concat(v_rdds_where_iu_str," and ",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name," > v_curdate "," and active_ind = 1 ")
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      tab_info->upd_val_list," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      " and ",tab_info->pk_match_str,")"," where list(",tab_info->pk_col_list,
      ") in (select",tab_info->pk_col_list," from ",tab_info->tab_$r," r_A where ",
      v_temp_where_str,")")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      ' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(tab_info->
       pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ELSE
     SET v_update_str = concat("update into ",tab_info->table_name," set active_ind =0 ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where tier_group_cd in (select tier_group_cd from ",
      tab_info->tab_$r," where ",v_rdds_where_iu_str,
      ") "," and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " >= v_curdate and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_update_str = concat("update into ",tab_info->table_name," t1 set (t1.",tab_info->cols[
      tab_info->end_eff_col_ndx].column_name)
     IF (daf_is_not_blank(tab_info->updt_col_list))
      SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
     ENDIF
     SET v_update_str = concat(v_update_str,") (select min(trunc(",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name,")-1/(24*60*60)) ")
     IF (daf_is_not_blank(tab_info->updt_val_list))
      SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
     ENDIF
     SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," r1 where ",
      v_rdds_where_iu_str,
      " and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " > v_curdate and active_ind = 1 and t1.tier_group_cd = r1.tier_group_cd)",
      " where t1.tier_group_cd in ( select tier_group_cd from ",tab_info->tab_$r,
      " where ",v_rdds_where_iu_str," and active_ind = 1 and ",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name," > v_curdate)",
      " and ",tab_info->cols[tab_info->beg_eff_col_ndx].column_name," <= v_curdate and ",tab_info->
      cols[tab_info->end_eff_col_ndx].column_name," >= v_curdate and active_ind = 1")
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_temp_where_str = concat(v_rdds_where_iu_str," and ",tab_info->cols[tab_info->
      beg_eff_col_ndx].column_name," > v_curdate "," and active_ind = 1 ")
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_temp_where_str,
      ' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(tab_info->
       pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
   ELSEIF ((tab_info->merge_delete_ind=0))
    IF ((tab_info->versioning_ind=1)
     AND  NOT ((tab_info->version_cdf IN ("ALG2", "ALG5", "ALG6", "ALG7"))))
     IF ((tab_info->table_name="WORKING_VIEW"))
      SET v_update_str = concat("update into ",tab_info->table_name," t1 set (CURRENT_WORKING_VIEW ")
      IF (daf_is_not_blank(tab_info->updt_col_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
      ENDIF
      SET v_update_str = concat(v_update_str,") (select nullval(",tab_info->pk_col_list,",0.0) ")
      IF (daf_is_not_blank(tab_info->updt_val_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
      ENDIF
      SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," R where ")
      SET drcd_ui_cnt = 0
      FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
         SET drcd_ui_cnt = (drcd_ui_cnt+ 1)
         IF (drcd_ui_cnt > 1)
          SET v_update_str = concat(v_update_str," and ")
         ENDIF
         IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
          SET v_update_str = concat(v_update_str," ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,
            "r1.","r.")," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
         ELSE
          SET v_update_str = concat(v_update_str," r.",tab_info->cols[drcd_col_cnt].column_name,
           " = t1.",tab_info->cols[drcd_col_cnt].column_name)
         ENDIF
        ENDIF
      ENDFOR
      SET v_update_str = concat(v_update_str," AND (R.ACTIVE_IND = 1 OR (r.active_ind = 0 and r.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name," <= v_curdate and r.",tab_info->cols[
       tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and not exists (",'select "x" from ',tab_info->tab_$r," r2 where ")
      SET drcd_ui_cnt = 0
      FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
         SET drcd_ui_cnt = (drcd_ui_cnt+ 1)
         IF (drcd_ui_cnt > 1)
          SET v_update_str = concat(v_update_str," and ")
         ENDIF
         IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
          SET v_update_str = concat(v_update_str," ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,
            "r1.","r2.")," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","r."))
         ELSE
          SET v_update_str = concat(v_update_str," r2.",tab_info->cols[drcd_col_cnt].column_name,
           " = r.",tab_info->cols[drcd_col_cnt].column_name)
         ENDIF
        ENDIF
      ENDFOR
      SET v_update_str = concat(v_update_str," and "," r2.active_ind = 1 ",
       "and r2.rdds_delete_ind = 0 and r2.rdds_context_name =v_context_to_set and r2.rdds_source_env_id =v_source_env_id ",
       "and r2.rdds_status_flag < 9000))) AND ",
       "r.rdds_delete_ind = 0 and r.rdds_context_name =v_context_to_set and r.rdds_source_env_id =v_source_env_id ",
       "and r.rdds_status_flag < 9000"," and rowid=rbr_rowid)")
      SET v_update_str = concat(v_update_str," where list(",tab_info->ui_col_list,") in (select ",
       tab_info->ui_col_list,
       " from ",tab_info->tab_$r," r3 where "," (R3.ACTIVE_IND = 1 OR (r3.active_ind = 0 and r3.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       " <= v_curdate and r3.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and not exists (",'select "x" from ',tab_info->tab_$r,
       " r4 where ")
      SET drcd_ui_cnt = 0
      FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
         SET drcd_ui_cnt = (drcd_ui_cnt+ 1)
         IF (drcd_ui_cnt > 1)
          SET v_update_str = concat(v_update_str," and ")
         ENDIF
         IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
          SET v_update_str = concat(v_update_str," ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,
            "r1.","r4.")," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","r3."))
         ELSE
          SET v_update_str = concat(v_update_str," r4.",tab_info->cols[drcd_col_cnt].column_name,
           " = r3.",tab_info->cols[drcd_col_cnt].column_name)
         ENDIF
        ENDIF
      ENDFOR
      SET v_update_str = concat(v_update_str," and "," r4.active_ind = 1 ",
       "and r4.rdds_delete_ind = 0 and r4.rdds_context_name =v_context_to_set and r4.rdds_source_env_id =v_source_env_id ",
       "and r4.rdds_status_flag < 9000))) AND ",
       "r3.rdds_delete_ind = 0 and r3.rdds_context_name =v_context_to_set and r3.rdds_source_env_id =v_source_env_id ",
       "and r3.rdds_status_flag < 9000"," and rowid=rbr_rowid)")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
     ENDIF
     SET v_vers_where_str = " and active_ind = 1 "
     SET v_update_str = concat("update into ",tab_info->table_name," set active_ind=0 ")
     IF ((tab_info->end_eff_col_ndx > 0))
      SET v_update_str = concat(v_update_str,", ",tab_info->cols[tab_info->end_eff_col_ndx].
       column_name," = v_curdate ")
     ENDIF
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where list (",tab_info->ui_col_list,") in (select ",
      tab_info->ui_col_list,
      " from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,") and active_ind = 1")
     IF (v_mvr_ind=1)
      SET v_update_str = concat(v_update_str," and ",v_mover_string)
     ENDIF
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     IF ((tab_info->end_eff_col_ndx > 0)
      AND (tab_info->beg_eff_col_ndx > 0))
      SET cms_eff_str = concat(" and active_ind = 0 and ",tab_info->cols[tab_info->beg_eff_col_ndx].
       column_name," <= v_curdate and ",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and not exists (",
       'select "X" from ',tab_info->tab_$r," r2 where r2.active_ind = 1 ")
      FOR (col_ndx = 1 TO size(tab_info->cols,5))
        IF ((tab_info->cols[col_ndx].ident_ind=1))
         IF ((tab_info->cols[col_ndx].nullable="N"))
          SET cms_eff_str = concat(cms_eff_str," and r2.",tab_info->cols[col_ndx].column_name,
           " = r1.",tab_info->cols[col_ndx].column_name)
         ELSE
          SET cms_eff_str = concat(cms_eff_str," and (r2.",tab_info->cols[col_ndx].column_name,
           " = r1.",tab_info->cols[col_ndx].column_name,
           " or (r2.",tab_info->cols[col_ndx].column_name," is null and r1.",tab_info->cols[col_ndx].
           column_name," is null)) ")
         ENDIF
        ENDIF
      ENDFOR
      SET cms_eff_str = concat(cms_eff_str," and r2.rdds_status_flag < 9000)")
      SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->
       upd_col_list,") (select ",
       tab_info->upd_val_list," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str,
       cms_eff_str," and ",tab_info->pk_match_str,") ","where list(",
       tab_info->pk_col_list,") in (select",tab_info->pk_col_list," from ",tab_info->tab_$r,
       " r_A where ",v_rdds_where_iu_str,replace(cms_eff_str,"r1.","r_A.",0),")")
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
     ENDIF
    ELSE
     SET v_vers_where_str = " "
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG6", "ALG7")))
     IF ((((tab_info->version_cdf="ALG6")) OR ((tab_info->version_cdf="ALG7")
      AND (tab_info->end_eff_col_ndx > 0)
      AND (tab_info->beg_eff_col_ndx > 0))) )
      SET v_update_str = concat("update from ",tab_info->table_name," t1 set (t1.",tab_info->cols[
       tab_info->end_eff_col_ndx].column_name,", t1.active_ind")
      IF (daf_is_not_blank(tab_info->updt_col_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
      ENDIF
      IF ((tab_info->user_dt_tm_ind=1))
       SET v_update_str = concat(v_update_str,") (select evaluate(least(t1.",tab_info->cols[tab_info
        ->end_eff_col_ndx].column_name,", v_curdate),v_curdate, r1.",tab_info->cols[tab_info->
        end_eff_col_ndx].column_name,
        ", t1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
        "), evaluate(r1.active_ind, 0, r1.active_ind, t1.active_Ind) ")
      ELSE
       SET v_update_str = concat(v_update_str,") (select evaluate(least(t1.",tab_info->cols[tab_info
        ->end_eff_col_ndx].column_name,", v_curdate),v_curdate, v_curdate, t1.",tab_info->cols[
        tab_info->end_eff_col_ndx].column_name,
        "), evaluate(r1.active_ind, 0, r1.active_ind, t1.active_Ind) ")
      ENDIF
      IF (daf_is_not_blank(tab_info->updt_val_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
      ENDIF
      SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," r1 where ",
       v_rdds_where_iu_str,
       " and r1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,"<= v_curdate")
      IF ((tab_info->version_cdf="ALG6"))
       FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
         IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
          IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
           SET v_update_str = concat(v_update_str," and ",tab_info->cols[drcd_col_cnt].upd_val_str,
            " = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
          ELSE
           SET v_update_str = concat(v_update_str," and r1.",tab_info->cols[drcd_col_cnt].column_name,
            " = t1.",tab_info->cols[drcd_col_cnt].column_name)
          ENDIF
         ENDIF
       ENDFOR
       SET drcd_temp_col_str = tab_info->ui_col_list
      ELSE
       SET v_update_str = concat(v_update_str," and ",tab_info->grouper_match_str)
       SET drcd_temp_col_str = tab_info->grouper_col_list
      ENDIF
      SET v_update_str = concat(v_update_str,") where list(",drcd_temp_col_str,") in (select ",
       drcd_temp_col_str,
       " from ",tab_info->tab_$r," r_A where ",v_rdds_where_iu_str," and ",
       tab_info->cols[tab_info->end_eff_col_ndx].column_name," <= v_curdate) and t1.",tab_info->cols[
       tab_info->beg_eff_col_ndx].column_name," <= v_curdate and t1.",tab_info->cols[tab_info->
       end_eff_col_ndx].column_name,
       " >= v_curdate and t1.active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
      SET v_update_str = concat("update from ",tab_info->table_name," t1 set (t1.",tab_info->cols[
       tab_info->end_eff_col_ndx].column_name,", t1.active_ind")
      IF (daf_is_not_blank(tab_info->updt_col_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_col_list)
      ENDIF
      IF ((tab_info->user_dt_tm_ind=1))
       SET v_update_str = concat(v_update_str,") (select evaluate(r1.active_ind, 0, t1.",tab_info->
        cols[tab_info->end_eff_col_ndx].column_name,", datetimeadd(r1.",tab_info->cols[tab_info->
        beg_eff_col_ndx].column_name,
        ", (-1/86400))), r1.active_ind")
      ELSE
       IF ((tab_info->static_active_ind=1)
        AND (tab_info->version_cdf="ALG6"))
        SET v_update_str = concat(v_update_str,") (select evaluate(r1.active_ind, 0, t1.",tab_info->
         cols[tab_info->end_eff_col_ndx].column_name,", v_curdate), t1.active_ind ")
       ELSE
        SET v_update_str = concat(v_update_str,") (select evaluate(r1.active_ind, 0, t1.",tab_info->
         cols[tab_info->end_eff_col_ndx].column_name,", v_curdate), 0 ")
       ENDIF
      ENDIF
      IF (daf_is_not_blank(tab_info->updt_val_list))
       SET v_update_str = concat(v_update_str,", ",tab_info->updt_val_list)
      ENDIF
      SET v_update_str = concat(v_update_str," from ",tab_info->tab_$r," r1 where ",
       v_rdds_where_iu_str,
       " and r1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,">= v_curdate")
      SET drcd_temp_match_str = " "
      IF ((tab_info->version_cdf="ALG6"))
       FOR (drcd_col_cnt = 1 TO size(tab_info->cols,5))
         IF ((tab_info->cols[drcd_col_cnt].ident_ind=1))
          IF (daf_is_blank(drcd_temp_match_str))
           IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
            SET drcd_temp_match_str = concat(" and ",tab_info->cols[drcd_col_cnt].upd_val_str," = ",
             replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
           ELSE
            SET drcd_temp_match_str = concat(" and r1.",tab_info->cols[drcd_col_cnt].column_name,
             " = t1.",tab_info->cols[drcd_col_cnt].column_name)
           ENDIF
          ELSE
           IF ((tab_info->cols[drcd_col_cnt].nullable="Y"))
            SET drcd_temp_match_str = concat(drcd_temp_match_str," and ",tab_info->cols[drcd_col_cnt]
             .upd_val_str," = ",replace(tab_info->cols[drcd_col_cnt].upd_val_str,"r1.","t1."))
           ELSE
            SET drcd_temp_match_str = concat(drcd_temp_match_str," and r1.",tab_info->cols[
             drcd_col_cnt].column_name," = t1.",tab_info->cols[drcd_col_cnt].column_name)
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       SET drcd_temp_col_str = tab_info->ui_col_list
      ELSE
       SET drcd_temp_match_str = concat(" and ",tab_info->grouper_match_str)
       SET drcd_temp_col_str = tab_info->grouper_col_list
      ENDIF
      SET v_update_str = concat(v_update_str,drcd_temp_match_str," and r1.",tab_info->cols[tab_info->
       beg_eff_col_ndx].column_name," in(select min(r2.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name,") from ",tab_info->tab_$r," r2 ",
       " where ",
       v_rdds_where_iu_str," and r2.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       ">= v_curdate ",replace(drcd_temp_match_str,"t1.","r2.",0),
       ")")
      SET v_update_str = concat(v_update_str,") where list(",drcd_temp_col_str,") in (select ",
       drcd_temp_col_str,
       " from ",tab_info->tab_$r," r_A where ",v_rdds_where_iu_str," and ",
       tab_info->cols[tab_info->end_eff_col_ndx].column_name," >= v_curdate) and t1.",tab_info->cols[
       tab_info->beg_eff_col_ndx].column_name," <= v_curdate and t1.",tab_info->cols[tab_info->
       end_eff_col_ndx].column_name,
       " >= v_curdate and t1.active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
      SET v_update_str = concat("update from ",tab_info->table_name," set active_ind = 0 ")
      IF (daf_is_not_blank(tab_info->updt_upd_val_str))
       SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
      ENDIF
      SET v_update_str = concat(v_update_str," where list (",drcd_temp_col_str,") in (select ",
       drcd_temp_col_str,
       " from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,") and ",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name," >= v_curdate and active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
      SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->end_eff_col_ndx].column_name,
       " >= v_curdate and r1.","active_ind = 1")
     ELSEIF ((tab_info->version_cdf="ALG7"))
      SET v_vers_where_str = " and active_ind = 1 "
      SET v_update_str = concat("update into ",tab_info->table_name," set active_ind=0 ")
      IF (daf_is_not_blank(tab_info->updt_upd_val_str))
       SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
      ENDIF
      SET v_update_str = concat(v_update_str," where list (",tab_info->grouper_col_list,
       ") in (select ",tab_info->grouper_col_list,
       " from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,") and active_ind = 1")
      IF (v_mvr_ind=1)
       SET v_update_str = concat(v_update_str," and ",v_mover_string)
      ENDIF
      CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
       o_rs_stmts)
     ENDIF
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     FOR (drcd_col_loop = 1 TO size(tab_info->cols,5))
       FOR (drcd_circ_loop = 1 TO tab_info->cols[drcd_col_loop].circ_cnt)
         IF ((other_info->table_name != tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].
         circ_table_name))
          CALL init_rs_data(other_info)
          CALL get_meta_data(tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_table_name,
           other_info)
         ENDIF
         SET stat = alterlist(drcd_orig_str->cols,size(other_info->cols,5))
         FOR (drcd_circ_col_loop = 1 TO size(other_info->cols,5))
           IF ((other_info->cols[drcd_circ_col_loop].pk_ind=1))
            SET tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_pk_col_name = other_info
            ->cols[drcd_circ_col_loop].column_name
           ENDIF
           SET drcd_orig_str->cols[drcd_circ_col_loop].str = other_info->cols[drcd_circ_col_loop].
           ins_val_str
           IF ((other_info->cols[drcd_circ_col_loop].column_name=tab_info->cols[drcd_col_loop].
           circ_qual[drcd_circ_loop].circ_pk_col_name))
            SET other_info->cols[drcd_circ_col_loop].ins_val_str = replace(other_info->cols[
             drcd_circ_col_loop].ins_val_str,other_info->cols[drcd_circ_col_loop].column_name,
             tab_info->cols[drcd_col_loop].column_name,0)
           ELSEIF ((other_info->cols[drcd_circ_col_loop].column_name=tab_info->cols[drcd_col_loop].
           circ_qual[drcd_circ_loop].circ_fk_col_name))
            SET other_info->cols[drcd_circ_col_loop].ins_val_str = replace(other_info->cols[
             drcd_circ_col_loop].ins_val_str,other_info->cols[drcd_circ_col_loop].column_name,
             tab_info->cols[tab_info->pk_col_ndx].column_name,0)
           ELSE
            SET other_info->cols[drcd_circ_col_loop].ins_val_str = replace(other_info->cols[
             drcd_circ_col_loop].ins_val_str,"r1.","cc.",0)
           ENDIF
         ENDFOR
         SET other_info->all_ins_val_str = " "
         SET other_info->pk_col_list = " "
         SET other_info->ui_col_list = " "
         SET other_info->upd_col_list = " "
         SET other_info->upd_val_list = " "
         SET other_info->all_upd_val_str = " "
         SET other_info->col_list = " "
         SET other_info->updt_upd_val_str = " "
         SET other_info->updt_col_list = " "
         SET other_info->updt_val_list = " "
         SET other_info->grouper_col_list = " "
         CALL create_merge_strs(other_info)
         FOR (drcd_circ_col_loop = 1 TO size(other_info->cols,5))
           SET other_info->cols[drcd_circ_col_loop].ins_val_str = drcd_orig_str->cols[
           drcd_circ_col_loop].str
         ENDFOR
         SET v_insert_str = concat("insert into ",tab_info->cols[drcd_col_loop].circ_qual[
          drcd_circ_loop].circ_table_name," t1 (",other_info->col_list,") (select ",
          other_info->all_ins_val_str," from ",tab_info->tab_$r," r1, ",tab_info->table_name,
          " t1_A, ",other_info->table_name," cc where ",replace(v_rdds_where_iu_str,"rowid=",
           "r1.rowid="))
         SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
          " != r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name," and t1_A.",
          tab_info->cols[tab_info->pk_col_ndx].column_name," = r1.",tab_info->cols[tab_info->
          prev_pk_col_ndx].column_name)
         SET v_vers_where_str = concat(v_vers_where_str,' and not exists (select "x" from ',tab_info
          ->table_name," t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),
          ")")
         IF (daf_is_not_blank(tab_info->cols[drcd_col_loop].self_entity_name))
          SET v_vers_where_str = concat(v_vers_where_str," and evaluate_pe_name('",tab_info->
           table_name,"', '",tab_info->cols[drcd_col_loop].column_name,
           "', '",tab_info->cols[drcd_col_loop].self_entity_name,"', t1_A.",tab_info->cols[
           drcd_col_loop].self_entity_name,") = '",
           other_info->table_name,"'")
         ENDIF
         SET v_vers_where_str = concat(v_vers_where_str," and cc.",other_info->cols[other_info->
          pk_col_ndx].column_name," = t1_A.",tab_info->cols[drcd_col_loop].column_name,
          " and cc.",other_info->cols[other_info->pk_col_ndx].column_name," > 0 and not exists (",
          "select 'x' from ",other_info->table_name,
          " l_A where l_A.",other_info->cols[other_info->pk_col_ndx].column_name," = r1.",tab_info->
          cols[drcd_col_loop].column_name,"))")
         SET v_insert_str = concat(v_insert_str,v_vers_where_str)
         SET v_vers_where_str = " "
         CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
          o_rs_stmts)
         SET drcd_circ_long_pos = 0
         SET drcd_circ_long_pos = locateval(drcd_circ_col_idx,1,size(other_info->cols,5),"LONG",
          other_info->cols[drcd_circ_col_idx].data_type)
         IF (drcd_circ_long_pos=0)
          SET drcd_circ_long_pos = locateval(drcd_circ_col_idx,1,size(other_info->cols,5),"LONG RAW",
           other_info->cols[drcd_circ_col_idx].data_type)
         ENDIF
         IF (drcd_circ_long_pos > 0)
          SET tab_info->long_call = concat("call move_circ_long(^",tab_info->table_name,"^ , ^",
           tab_info->tab_$r,"^ , ^",
           tab_info->cols[tab_info->pk_col_ndx].column_name,"^ , <BrEaK>^",tab_info->cols[tab_info->
           prev_pk_col_ndx].column_name,"^ ,^",tab_info->cols[drcd_col_loop].column_name,
           "^ , ^",tab_info->cols[drcd_col_loop].self_entity_name,"^ , <BrEaK>^",other_info->
           table_name,"^ , ^",
           other_info->cols[other_info->pk_col_ndx].column_name,"^ , ^",tab_info->cols[drcd_col_loop]
           .circ_qual[drcd_circ_loop].circ_fk_col_name,"^ , <BrEaK>^",other_info->cols[
           drcd_circ_long_pos].column_name,
           "^ , <BrEaK> v_source_env_id, -1*v_stmt_num)")
         ENDIF
         IF (daf_is_not_blank(tab_info->long_call))
          CALL add_stmt(tab_info->long_call,0,1,1,s_stmt_cnt,
           o_rs_stmts)
         ENDIF
         SET tab_info->long_call = ""
       ENDFOR
     ENDFOR
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = concat("t1_a.",tab_info->cols[
      tab_info->beg_eff_col_ndx].column_name)
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = "v_curdate"
     SET stat = alterlist(drcd_orig_str->cols,size(tab_info->cols,5))
     FOR (i = 1 TO size(tab_info->cols,5))
      SET drcd_orig_str->cols[i].str = tab_info->cols[i].ins_val_str
      IF ( NOT (i IN (tab_info->prev_pk_col_ndx, tab_info->pk_col_ndx)))
       SET tab_info->cols[i].ins_val_str = replace(tab_info->cols[i].ins_val_str,"r1.","t1_A.",0)
      ENDIF
     ENDFOR
     FOR (drcd_col_loop = 1 TO size(tab_info->cols,5))
       FOR (drcd_circ_loop = 1 TO tab_info->cols[drcd_col_loop].circ_cnt)
         IF (daf_is_not_blank(tab_info->cols[drcd_col_loop].self_entity_name))
          IF (drcd_circ_loop=1)
           SET tab_info->cols[drcd_col_loop].ins_val_str = replace(tab_info->cols[drcd_col_loop].
            ins_val_str,concat("t1_A.",tab_info->cols[drcd_col_loop].column_name),concat(
             "evaluate(nullval(t1_A.",tab_info->cols[drcd_col_loop].column_name,", 0), 0, t1_A.",
             tab_info->cols[drcd_col_loop].column_name,", <NeXt EvAl>)"),0)
           SET tab_info->cols[drcd_col_loop].ins_val_str = replace(tab_info->cols[drcd_col_loop].
            ins_val_str,"<NeXt EvAl>)",concat("evaluate(evaluate_pe_name('",tab_info->table_name,
             "', '",tab_info->cols[drcd_col_loop].column_name,"', '",
             tab_info->cols[drcd_col_loop].self_entity_name,"', t1_A.",tab_info->cols[drcd_col_loop].
             self_entity_name,"), '",tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].
             circ_table_name,
             "', r1.",tab_info->cols[drcd_col_loop].column_name,", "),0)
          ELSEIF ((drcd_circ_loop < tab_info->cols[drcd_col_loop].circ_cnt))
           SET tab_info->cols[drcd_col_loop].ins_val_str = concat(tab_info->cols[drcd_col_loop].
            ins_val_str,"'",tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_table_name,
            "', r1.",tab_info->cols[drcd_col_loop].column_name,
            ", ")
          ELSE
           SET tab_info->cols[drcd_col_loop].ins_val_str = concat(tab_info->cols[drcd_col_loop].
            ins_val_str,"'",tab_info->cols[drcd_col_loop].circ_qual[drcd_circ_loop].circ_table_name,
            "', r1.",tab_info->cols[drcd_col_loop].column_name,
            ", t1_A.",tab_info->cols[drcd_col_loop].column_name,"))")
          ENDIF
         ELSE
          SET tab_info->cols[drcd_col_loop].ins_val_str = replace(tab_info->cols[drcd_col_loop].
           ins_val_str,concat("t1_A.",tab_info->cols[drcd_col_loop].column_name),concat(
            "evaluate(nullval(t1_A.",tab_info->cols[drcd_col_loop].column_name,",0), 0, t1_A.",
            tab_info->cols[drcd_col_loop].column_name,", r1.",
            tab_info->cols[drcd_col_loop].column_name,")"),0)
         ENDIF
       ENDFOR
     ENDFOR
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
     SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
      " != r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name," and t1_A.",
      tab_info->cols[tab_info->pk_col_ndx].column_name," = r1.",tab_info->cols[tab_info->
      prev_pk_col_ndx].column_name)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1, ",tab_info->table_name,
      " t1_A where ",replace(v_rdds_where_iu_str,"rowid=","r1.rowid="),v_vers_where_str,
      ' and not exists (select "x" from ',tab_info->table_name,
      " t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),"))")
     SET v_vers_where_str = " "
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     FOR (i = 1 TO size(tab_info->cols,5))
       SET tab_info->cols[i].ins_val_str = drcd_orig_str->cols[i].str
     ENDFOR
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = "v_curdate"
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->end_eff_col_ndx].column_name)
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
      " = r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name)
    ENDIF
    IF ((((tab_info->user_dt_tm_ind=0)
     AND (tab_info->version_cdf="ALG6")) OR ((tab_info->version_cdf="ALG7")
     AND (tab_info->end_eff_col_ndx > 0)
     AND (tab_info->beg_eff_col_ndx > 0))) )
     SET drcd_temp_set_stmt = tab_info->upd_val_list
     SET drcd_temp_set_stmt = replace(drcd_temp_set_stmt,tab_info->cols[tab_info->beg_eff_col_ndx].
      upd_val_str,concat("evaluate(least(r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       ",v_curdate), v_curdate, r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,", t1.",
       tab_info->cols[tab_info->beg_eff_col_ndx].column_name,")"),0)
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      drcd_temp_set_stmt," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ELSE
     SET v_update_str = concat("update from ",tab_info->table_name," t1 set (",tab_info->upd_col_list,
      ") (select ",
      tab_info->upd_val_list," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ENDIF
    SET v_update_str = concat(v_update_str,v_vers_where_str," and ",tab_info->pk_match_str,")",
     " where list(",tab_info->pk_col_list,") in (select",tab_info->pk_col_list," from ",
     tab_info->tab_$r," r_A where ",v_rdds_where_iu_str,replace(v_vers_where_str,"r1.","r_A.",0),
     v_upd1_sect2_dml,
     ")")
    CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     SET v_vers_where_str = " "
    ENDIF
    IF ((tab_info->table_name="SA_REF_ACTION"))
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,")",
      " (select ",tab_info->all_ins_val_str," from ",tab_info->tab_$r,
      " r1 where r1.action_description = <BrEaK>'RDDS FILL ROW' and ",
      v_rdds_where_iu_str,' and not exists(select "x" from ',tab_info->table_name," t_A where ",
      replace(tab_info->pk_match_str,"t1.","t_A.",0),
      "))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
    IF ((tab_info->table_name="PRSNL"))
     SET v_insert_str = concat(" insert into dm_chg_log t1 ",
      " (log_type, log_id, table_name, target_env_id, pk_where, chg_dt_tm) ",
      " (select 'PRSSEC', seq(dm_clinical_seq, nextval), 'PRSNL', ",trim(cnvtstring(o_rs_stmts->
        target_env_id,20)),
      ".0, concat(r1.username,'&', r1.name_full_formatted), cnvtdatetime(curdate, curtime3) from ",
      tab_info->tab_$r," r1 where trim(r1.username) > ' ' and ",v_rdds_where_iu_str,v_vers_where_str,
      " and not exists (select 'x' from ",
      tab_info->table_name," t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),"))")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5")))
     SET v_vers_where_str = concat(" and r1.",tab_info->cols[tab_info->pk_col_ndx].column_name,
      " = r1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name)
    ENDIF
    IF ((((tab_info->user_dt_tm_ind=0)
     AND (tab_info->version_cdf="ALG6")) OR ((tab_info->version_cdf="ALG7")
     AND (tab_info->end_eff_col_ndx > 0)
     AND (tab_info->beg_eff_col_ndx > 0))) )
     SET drcd_temp_set_stmt = tab_info->all_ins_val_str
     SET drcd_temp_set_stmt = replace(drcd_temp_set_stmt,tab_info->cols[tab_info->beg_eff_col_ndx].
      ins_val_str,concat("evaluate(least(r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       ",v_curdate), v_curdate, r1.",tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
       ", v_curdate)"),0)
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      drcd_temp_set_stmt," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ELSE
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str)
    ENDIF
    SET v_insert_str = concat(v_insert_str,v_vers_where_str,v_ins1_sect1_dml,
     ' and not exists (select "x" from ',tab_info->table_name,
     " t_A where ",replace(tab_info->pk_match_str,"t1.","t_A.",0),")")
    IF ((tab_info->table_name IN ("OMF_PV_SECURITY_FILTER", "OMF_PV_COL_SEC")))
     SET v_insert_str = concat(v_insert_str,
      ' and exists (select "x" from OMF_GRID og, OMF_GRID_COLUMN ogc, OMF_VO_TYPE ovt, OMF_VO_TYPE_DISPLAY ovtd,',
      " OMF_VO_INDICATOR_GROUP ovig, OMF_INDICATOR oil "," where "," og.grid_cd = r1.grid_cd and ",
      " og.active_ind = 1 and "," ogc.grid_cd = og.grid_cd and ",
      " ovt.vo_type_cd = ogc.grid_column_cd and "," ovtd.vo_type_cd = ovt.vo_type_cd and ",
      " ovig.parent_indicator_cd = ovt.vo_indicator_cd and ",
      " ovig.vo_display_seq = ovtd.vo_display_seq and ",
      " oil.indicator_cd = ovig.child_indicator_cd and "," oil.indicator_cd = r1.indicator_cd) ",
      ' or exists (select "x" from OMF_GRID og, OMF_GRID_COLUMN ogc, OMF_INDICATOR oil '," where ",
      " og.grid_cd = r1.grid_cd and "," og.active_ind = 1 and "," ogc.grid_cd = og.grid_cd and ",
      " oil.indicator_cd = ogc.grid_column_cd and "," oil.indicator_cd = r1.indicator_cd)")
    ENDIF
    SET v_insert_str = concat(v_insert_str,")")
    IF ((tab_info->version_cdf IN ("ALG2", "ALG5", "ALG6", "ALG7")))
     SET v_vers_where_str = " "
    ENDIF
    CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    IF ((tab_info->versioning_ind=1)
     AND  NOT ((tab_info->version_cdf IN ("ALG2", "ALG5", "ALG6", "ALG7")))
     AND (tab_info->beg_eff_col_ndx > 0)
     AND (tab_info->end_eff_col_ndx > 0))
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",v_rdds_where_iu_str,
      cms_eff_str,' and not exists (select "x" from ',tab_info->table_name," t_A where ",replace(
       tab_info->pk_match_str,"t1.","t_A.",0),
      ")")
     SET v_insert_str = concat(v_insert_str,")")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
    ENDIF
    IF ((tab_info->version_cdf="ALG5"))
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->beg_eff_col_ndx].column_name)
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = "v_curdate"
     FOR (i = 1 TO size(tab_info->cols,5))
       IF ((i != tab_info->pk_col_ndx))
        SET tab_info->cols[i].ins_val_str = replace(tab_info->cols[i].ins_val_str,"r1.","t2.",0)
       ELSE
        SET tab_info->cols[i].ins_val_str = concat("seq(",tab_info->cols[i].sequence_name,",nextval)"
         )
       ENDIF
     ENDFOR
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
     SET v_vers_where_str = concat(" t2.",tab_info->cols[tab_info->pk_col_ndx].column_name," = t2.",
      tab_info->cols[tab_info->prev_pk_col_ndx].column_name)
     IF (v_mvr_ind=1)
      SET v_mover_alg5_string = concat(" and ",v_mover_string)
     ELSE
      SET v_mover_alg5_string = " "
     ENDIF
     SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,
      ") (select ",
      tab_info->all_ins_val_str," from ",tab_info->table_name," t2 "," where ",
      v_vers_where_str,v_mover_alg5_string,' and exists(select "x" from ',tab_info->tab_$r,
      " r1 where ",
      replace(tab_info->grouper_match_str,"t1.","t2.",0)," and ",v_rdds_where_iu_str," and r1.",
      tab_info->cols[tab_info->pk_col_ndx].column_name,
      " in(select min(r2.",tab_info->cols[tab_info->pk_col_ndx].column_name,") from ",tab_info->
      tab_$r," r2 ",
      " where r2.rdds_delete_ind = 0 and r2.rdds_status_flag < 9000 and ",replace(tab_info->
       grouper_match_str,"t1.","r2.",0),')) and not exists (select "x" from ',tab_info->tab_$r,
      " R_A where ",
      replace(replace(tab_info->pk_match_str,"t1.","R_A.",0),"r1.","t2.",0),
      ") and t2.active_ind = 1 )")
     CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_update_str = concat("update into ",tab_info->table_name," t1 "," set t1.active_ind=0, t1.",
      tab_info->cols[tab_info->beg_eff_col_ndx].column_name,
      " = v_curdate ")
     IF (daf_is_not_blank(tab_info->updt_upd_val_str))
      SET v_update_str = concat(v_update_str,",",tab_info->updt_upd_val_str)
     ENDIF
     SET v_update_str = concat(v_update_str," where t1.",tab_info->cols[tab_info->pk_col_ndx].
      column_name," = t1.",tab_info->cols[tab_info->prev_pk_col_ndx].column_name,
      " and exists (select 'x' from ",tab_info->tab_$r," r1 where ",tab_info->grouper_match_str,")",
      " and not exists (select 'x' from ",tab_info->tab_$r," r2 where t1.",tab_info->cols[tab_info->
      pk_col_ndx].column_name," = r2.",
      tab_info->cols[tab_info->pk_col_ndx].column_name,")"," and t1.active_ind = 1")
     IF (v_mvr_ind=1)
      SET v_update_str = concat(v_update_str," and ",v_mover_string)
     ENDIF
     CALL add_stmt(v_update_str,0,1,0,s_stmt_cnt,
      o_rs_stmts)
     SET v_vers_where_str = " "
     SET tab_info->cols[tab_info->beg_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->beg_eff_col_ndx].column_name)
     SET tab_info->cols[tab_info->end_eff_col_ndx].ins_val_str = concat("r1.",tab_info->cols[tab_info
      ->end_eff_col_ndx].column_name)
     FOR (i = 1 TO size(tab_info->cols,5))
       IF ((i != tab_info->pk_col_ndx))
        SET tab_info->cols[i].ins_val_str = replace(tab_info->cols[i].ins_val_str,"t2.","r1.",0)
       ELSE
        SET tab_info->cols[i].ins_val_str = concat("r1.",tab_info->cols[i].column_name)
       ENDIF
     ENDFOR
     SET tab_info->all_ins_val_str = " "
     SET tab_info->pk_col_list = " "
     SET tab_info->ui_col_list = " "
     SET tab_info->upd_col_list = " "
     SET tab_info->upd_val_list = " "
     SET tab_info->all_upd_val_str = " "
     SET tab_info->col_list = " "
     SET tab_info->updt_upd_val_str = " "
     SET tab_info->updt_col_list = " "
     SET tab_info->updt_val_list = " "
     SET tab_info->grouper_col_list = " "
     CALL create_merge_strs(tab_info)
    ENDIF
   ELSEIF ((tab_info->merge_delete_ind=1))
    SET v_delete_str = concat("delete from ",tab_info->table_name," where list(",tab_info->
     md_col_list,") in (select ",
     tab_info->md_col_list," from ",tab_info->tab_$r," where ",v_rdds_where_str)
    IF ((tab_info->table_name="EA_USER_ATTRIBUTE_RELTN"))
     SET v_delete_str = concat(v_delete_str," and 1 = 2 )")
    ELSE
     SET v_delete_str = concat(v_delete_str," )")
    ENDIF
    IF (daf_is_not_blank(tab_info->default_row_str))
     SET v_delete_str = concat(v_delete_str," and not (",tab_info->default_row_str," )")
    ENDIF
    IF (v_mvr_ind=1)
     SET v_delete_str = concat(v_delete_str," and ",v_mover_string)
    ENDIF
    CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    SET v_delete_str = concat("delete from ",tab_info->table_name," where list(",tab_info->
     pk_col_list,") in (select ",
     tab_info->pk_col_list," from ",tab_info->tab_$r," where ",v_rdds_where_iu_str,
     ") ")
    IF (daf_is_not_blank(tab_info->default_row_str))
     SET v_delete_str = concat(v_delete_str," and not (",tab_info->default_row_str," )")
    ENDIF
    IF (v_mvr_ind=1)
     SET v_delete_str = concat(v_delete_str," and ",v_mover_string)
    ENDIF
    IF ((tab_info->table_name="EA_USER_ATTRIBUTE_RELTN"))
     SET v_delete_str = concat(v_delete_str," and 1 = 2 ")
    ENDIF
    CALL add_stmt(v_delete_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
    SET v_insert_str = concat("insert into ",tab_info->table_name," t1 (",tab_info->col_list,")",
     " (select ",tab_info->all_ins_val_str," from ",tab_info->tab_$r," r1 where ",
     v_rdds_where_iu_str)
    IF (daf_is_not_blank(tab_info->default_row_str))
     SET v_insert_str = concat(v_insert_str," and not (",tab_info->default_row_str,") ")
    ENDIF
    IF ((tab_info->table_name="EA_USER_ATTRIBUTE_RELTN"))
     SET v_insert_str = concat(v_insert_str,
      " and r1.EA_USER_ID not in (select ea_user_id from EA_USER_ATTRIBUTE_RELTN)")
    ENDIF
    SET v_insert_str = concat(v_insert_str,")")
    CALL add_stmt(v_insert_str,0,1,0,s_stmt_cnt,
     o_rs_stmts)
   ENDIF
   IF (daf_is_not_blank(tab_info->long_call))
    CALL add_stmt(tab_info->long_call,0,1,1,s_stmt_cnt,
     o_rs_stmts)
   ENDIF
   FREE RECORD tab_info
 END ;Subroutine
 SUBROUTINE create_merge_strs(i_tab_info)
   FOR (s_col_ndx = 1 TO size(i_tab_info->cols,5))
     IF ((i_tab_info->cols[s_col_ndx].long_ind=0))
      IF ((i_tab_info->cols[s_col_ndx].pk_ind=0))
       SET i_tab_info->upd_col_list = concat(i_tab_info->upd_col_list,", t1.",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->upd_val_list = concat(i_tab_info->upd_val_list,", ",i_tab_info->cols[s_col_ndx
        ].upd_val_str)
       SET i_tab_info->all_upd_val_str = concat(i_tab_info->all_upd_val_str,", t1.",i_tab_info->cols[
        s_col_ndx].column_name," = ",i_tab_info->cols[s_col_ndx].upd_val_str)
       IF ((i_tab_info->table_name="TIER_MATRIX"))
        IF ((s_col_ndx != i_tab_info->beg_eff_col_ndx))
         SET i_tab_info->tm_all_upd_val_str = concat(i_tab_info->tm_all_upd_val_str," , ",i_tab_info
          ->cols[s_col_ndx].ins_val_str)
        ELSE
         SET i_tab_info->tm_all_upd_val_str = concat(i_tab_info->tm_all_upd_val_str,", v_todaymid")
        ENDIF
       ENDIF
      ENDIF
      SET i_tab_info->all_ins_val_str = concat(i_tab_info->all_ins_val_str," , ",i_tab_info->cols[
       s_col_ndx].ins_val_str)
      IF ((i_tab_info->table_name="TIER_MATRIX"))
       IF ((s_col_ndx != i_tab_info->beg_eff_col_ndx))
        SET i_tab_info->tm_all_ins_val_str = concat(i_tab_info->tm_all_ins_val_str," , ",i_tab_info->
         cols[s_col_ndx].ins_val_str)
       ELSE
        SET i_tab_info->tm_all_ins_val_str = concat(i_tab_info->tm_all_ins_val_str,", v_todaymid")
       ENDIF
      ENDIF
      SET i_tab_info->col_list = concat(i_tab_info->col_list,", t1.",i_tab_info->cols[s_col_ndx].
       column_name)
      IF ((i_tab_info->cols[s_col_ndx].column_name="UPDT_CNT"))
       SET i_tab_info->updt_upd_val_str = concat(i_tab_info->updt_upd_val_str,", ",i_tab_info->cols[
        s_col_ndx].column_name," = ",i_tab_info->cols[s_col_ndx].column_name,
        "+1")
       SET i_tab_info->updt_col_list = concat(i_tab_info->updt_col_list,", ",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->updt_val_list = concat(i_tab_info->updt_val_list,", t1.",i_tab_info->cols[
        s_col_ndx].column_name,"+1")
      ELSEIF ((i_tab_info->cols[s_col_ndx].column_name="UPDT_DT_TM"))
       SET i_tab_info->updt_upd_val_str = concat(i_tab_info->updt_upd_val_str,", ",i_tab_info->cols[
        s_col_ndx].column_name," = v_curdate")
       SET i_tab_info->updt_col_list = concat(i_tab_info->updt_col_list,", ",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->updt_val_list = concat(i_tab_info->updt_val_list,", v_curdate")
      ELSEIF ((i_tab_info->cols[s_col_ndx].column_name="UPDT_TASK"))
       SET i_tab_info->updt_upd_val_str = concat(i_tab_info->updt_upd_val_str,", ",i_tab_info->cols[
        s_col_ndx].column_name," = 4310001")
       SET i_tab_info->updt_col_list = concat(i_tab_info->updt_col_list,", ",i_tab_info->cols[
        s_col_ndx].column_name)
       SET i_tab_info->updt_val_list = concat(i_tab_info->updt_val_list,", 4310001")
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].md_ind=1))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", ",i_tab_info->cols[s_col_ndx]
         .column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(cnvtreal(",
           i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->md_col_list = concat(i_tab_info->md_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].pk_ind=1))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", ",i_tab_info->cols[s_col_ndx]
         .column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(cnvtreal(",
           i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->pk_col_list = concat(i_tab_info->pk_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].ident_ind=1)
       AND daf_is_blank(i_tab_info->ui_col_list_ovr))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", ",i_tab_info->cols[s_col_ndx]
         .column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
           s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(cnvtreal(",
           i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->ui_col_list = concat(i_tab_info->ui_col_list,", nullval(",i_tab_info->cols[
          s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
      IF ((i_tab_info->cols[s_col_ndx].grouper_col_ind=1))
       IF ((i_tab_info->cols[s_col_ndx].nullable="N"))
        SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", ",i_tab_info->cols[
         s_col_ndx].column_name)
       ELSE
        IF ((i_tab_info->cols[s_col_ndx].data_type IN ("NUMBER", "FLOAT")))
         IF ((i_tab_info->cols[s_col_ndx].ccl_type="F"))
          SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
           i_tab_info->cols[s_col_ndx].column_name,",-123888.4321)")
         ELSEIF ((i_tab_info->cols[s_col_ndx].ccl_type="I"))
          SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
           i_tab_info->cols[s_col_ndx].column_name,",-123888)")
         ELSE
          SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,
           ", nullval(cnvtreal(",i_tab_info->cols[s_col_ndx].column_name,"),-123888.4321)")
         ENDIF
        ELSEIF ((i_tab_info->cols[s_col_ndx].data_type="DATE"))
         SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
          i_tab_info->cols[s_col_ndx].column_name,",cnvtdatetime(cnvtdate(07231882),215212) )")
        ELSE
         SET i_tab_info->grouper_col_list = concat(i_tab_info->grouper_col_list,", nullval(",
          i_tab_info->cols[s_col_ndx].column_name,',"null_vaLue_CHeck_894.3")')
        ENDIF
       ENDIF
      ENDIF
     ELSE
      SET i_tab_info->long_pk_str = concat("set v_long_pk_str = ^",i_tab_info->pk_long_str,"^ go")
      SET i_tab_info->long_call = concat("call move_long(^",tab_info->tab_$r,"^ , ^",i_tab_info->
       table_name,"^ , ^",
       i_tab_info->cols[s_col_ndx].column_name,"^ , <BrEaK>^",i_tab_info->pk_long_str,
       "^ , v_source_env_id, -1*v_stmt_num)")
     ENDIF
   ENDFOR
   SET i_tab_info->upd_val_list = substring(2,10000,i_tab_info->upd_val_list)
   SET i_tab_info->upd_col_list = substring(2,10000,i_tab_info->upd_col_list)
   SET i_tab_info->all_upd_val_str = substring(2,10000,i_tab_info->all_upd_val_str)
   SET i_tab_info->all_ins_val_str = substring(3,10000,i_tab_info->all_ins_val_str)
   SET i_tab_info->col_list = substring(2,10000,i_tab_info->col_list)
   SET i_tab_info->md_col_list = substring(2,10000,i_tab_info->md_col_list)
   SET i_tab_info->pk_col_list = substring(2,10000,i_tab_info->pk_col_list)
   IF (daf_is_not_blank(i_tab_info->ui_col_list_ovr))
    SET i_tab_info->ui_col_list = i_tab_info->ui_col_list_ovr
   ELSE
    SET i_tab_info->ui_col_list = substring(2,10000,i_tab_info->ui_col_list)
   ENDIF
   SET i_tab_info->grouper_col_list = substring(2,10000,i_tab_info->grouper_col_list)
   IF ((i_tab_info->table_name="TIER_MATRIX"))
    SET i_tab_info->tm_all_ins_val_str = substring(3,10000,i_tab_info->tm_all_ins_val_str)
    SET i_tab_info->tm_all_upd_val_str = substring(3,10000,i_tab_info->tm_all_upd_val_str)
   ENDIF
   SET i_tab_info->updt_upd_val_str = substring(2,10000,i_tab_info->updt_upd_val_str)
   SET i_tab_info->updt_col_list = substring(2,10000,i_tab_info->updt_col_list)
   SET i_tab_info->updt_val_list = substring(2,10000,i_tab_info->updt_val_list)
 END ;Subroutine
 SUBROUTINE cutover_get_and_run_dml(i_table_name,i_source_env_id,i_move_long_ind,i_batch_ind,
  i_tgt_env_id)
   DECLARE s_cgard_return = vc WITH noconstant("S")
   FREE RECORD dml
   RECORD dml(
     1 batch_ind = i2
     1 source_env_id = f8
     1 move_long_ind = i2
     1 table_name = vc
     1 merge_stmt_ind = i2
     1 target_env_id = f8
     1 stmt[*]
       2 str = vc
       2 end_ind = i2
       2 rdb_asis_ind = i2
       2 move_long_str_ind = i2
   )
   SET dml->source_env_id = i_source_env_id
   SET dml->move_long_ind = i_move_long_ind
   SET dml->batch_ind = i_batch_ind
   SET dml->table_name = i_table_name
   SET dml->merge_stmt_ind = 1
   SET dml->target_env_id = i_tgt_env_id
   CALL create_merge_stmts(i_table_name,dml)
   IF (check_error(build("When calling Create_merge_stmts: "))=1)
    SET dm_err->err_ind = 0
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET s_cgard_return = "F"
   ENDIF
   IF (s_cgard_return="S"
    AND size(dml->stmt,5) > 0)
    EXECUTE dm_rmc_run_stmt  WITH replace("REQUEST","DML"), replace("ERR_TO_CONTINUE","DRC_CONTINUE")
    IF (check_error(build("When executing DM_RDDS_RUN_STMT: "))=1)
     SET dm_err->err_ind = 0
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET s_cgard_return = "F"
    ENDIF
   ENDIF
   RETURN(s_cgard_return)
 END ;Subroutine
 SUBROUTINE pk_data_default(i_tab_info,i_col_ndx)
  IF ((i_tab_info->cols[i_col_ndx].data_type="DATE"))
   SET drs_date_default = cnvtupper(cnvtalphanum(i_tab_info->cols[i_col_ndx].data_default))
   IF (substring(1,6,drs_date_default)="TODATE"
    AND substring(21,16,drs_date_default)="MMDDYYYYHH24MISS")
    SET i_tab_info->cols[i_col_ndx].data_default = concat("CNVTDATETIME(CNVTDATE(",substring(7,8,
      drs_date_default),"),",substring(15,6,drs_date_default),")")
   ELSEIF (drs_date_default != "SYSDATE")
    SET i_tab_info->cols[i_col_ndx].data_default = "CNVTDATETIME(CNVTDATE(12312100),0)"
   ENDIF
   SET i_tab_info->cols[i_col_ndx].data_default_null_ind = 0
  ELSEIF ((i_tab_info->cols[i_col_ndx].data_type IN ("FLOAT", "NUMBER")))
   SET i_tab_info->cols[i_col_ndx].data_default = replace(i_tab_info->cols[i_col_ndx].data_default,
    "'","",0)
  ELSEIF ((i_tab_info->cols[i_col_ndx].data_type IN ("CHAR", "VARCHAR2", "CLOB", "BLOB", "LONG",
  "LONG RAW", "RAW")))
   SET stat = findstring("'",i_tab_info->cols[i_col_ndx].data_default,1,0)
   IF (stat > 0)
    SET i_tab_info->cols[i_col_ndx].data_default = i_tab_info->cols[i_col_ndx].data_default
   ELSE
    SET i_tab_info->cols[i_col_ndx].data_default = concat("'",i_tab_info->cols[i_col_ndx].
     data_default,"'")
   ENDIF
  ELSE
   SET stat = findstring("'",i_tab_info->cols[i_col_ndx].data_default,1,0)
   IF (stat > 0)
    SET i_tab_info->cols[i_col_ndx].data_default = i_tab_info->cols[i_col_ndx].data_default
   ELSE
    SET i_tab_info->cols[i_col_ndx].data_default = concat("'",i_tab_info->cols[i_col_ndx].
     data_default,"'")
   ENDIF
  ENDIF
  IF ((i_tab_info->cols[i_col_ndx].data_default_null_ind=1))
   CASE (trim(i_tab_info->cols[i_col_ndx].data_type))
    OF "INTEGER":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "BIGINT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "SMALLINT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "INT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "TINYINT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "NUMBER":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "NUMERIC":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "DECIMAL":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "FLOAT":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "DOUBLE":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "REAL":
     SET i_tab_info->cols[i_col_ndx].data_default = "0"
    OF "VARCHAR2":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "VARCHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "NVARCHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "CHARACTER":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "CHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
    OF "NCHAR":
     SET i_tab_info->cols[i_col_ndx].data_default = "' '"
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE get_meta_data(gmd_table_name,gmd_tab_info)
   DECLARE gmd_query_tab_name = vc WITH protect, noconstant("")
   DECLARE gmd_drcd_index = i4 WITH protect, noconstant(0)
   DECLARE gmd_col_pos = i4 WITH protect, noconstant(0)
   DECLARE gmd_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE gmd_col_num = i4 WITH protect, noconstant(0)
   DECLARE gmd_ovr_ndx = i4 WITH protect, noconstant(0)
   DECLARE gmd_tp_ndx = i4 WITH protect, noconstant(0)
   DECLARE gmd_cms_num2 = i4 WITH protect, noconstant(0)
   DECLARE gmd_cms_cnt = i4 WITH protect, noconstant(0)
   DECLARE gmd_cms_i = i4 WITH protect, noconstant(0)
   DECLARE gmd_curqual = i4 WITH protect, noconstant(0)
   DECLARE gmd_alias_str = vc WITH protect, noconstant("")
   DECLARE gmd_alias_nbr = i4 WITH protect, noconstant(0)
   DECLARE gmd_merge_active_ind = i2
   DECLARE gmd_att_idx = i4 WITH protect, noconstant(0)
   FREE RECORD dml_overrides
   RECORD dml_overrides(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
       2 dml_attribute = vc
       2 dml_value = vc
       2 data_type = vc
   )
   FREE RECORD gmd_attributes
   RECORD gmd_attributes(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
       2 attribute_name = vc
       2 attribute_value = f8
       2 attribute_char = vc
       2 attribute_dt_tm = dq8
   )
   SET gmd_tab_info->table_name = gmd_table_name
   SET gmd_query_tab_name = gmd_table_name
   SET gmd_tab_info->tab_$r = cutover_tab_name(gmd_table_name,"")
   SELECT INTO "nl:"
    d.info_number
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="RDDS ACTIVE_IND MERGE"
    DETAIL
     gmd_merge_active_ind = d.info_number
    WITH nocounter
   ;end select
   IF (check_error("While checking DM_INFO.RDDS ACTIVE_IND MERGE: ")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE (ut.table_name=gmd_tab_info->tab_$r)
    DETAIL
     gmd_tab_info->r_tab_exists = 1, gmd_query_tab_name = gmd_tab_info->tab_$r
    WITH nocounter
   ;end select
   IF (check_error("While checking for existence of $R table: ")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    drd.column_name, drd.dml_attribute, drd.dml_value,
    drd.data_type
    FROM dm_refchg_dml drd
    WHERE (drd.table_name=gmd_tab_info->table_name)
    HEAD REPORT
     dml_overrides->cnt = 0
    DETAIL
     IF (drd.dml_attribute="UI_COL_LIST")
      gmd_tab_info->ui_col_list_ovr = drd.dml_value, gmd_tab_info->ui_col_list = drd.dml_value
     ELSEIF (drd.dml_attribute="UI_MATCH_STR")
      gmd_tab_info->ui_match_str_ovr = drd.dml_value, gmd_tab_info->ui_match_str = drd.dml_value
     ELSE
      dml_overrides->cnt = (dml_overrides->cnt+ 1)
      IF (mod(dml_overrides->cnt,10)=1)
       stat = alterlist(dml_overrides->qual,(dml_overrides->cnt+ 9))
      ENDIF
      dml_overrides->qual[dml_overrides->cnt].column_name = drd.column_name, dml_overrides->qual[
      dml_overrides->cnt].dml_attribute = drd.dml_attribute, dml_overrides->qual[dml_overrides->cnt].
      dml_value = drd.dml_value,
      dml_overrides->qual[dml_overrides->cnt].data_type = drd.data_type
     ENDIF
    FOOT REPORT
     stat = alterlist(dml_overrides->qual,dml_overrides->cnt)
    WITH nocounter
   ;end select
   IF (check_error("While gathering dml overrides: ")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM dm_refchg_attribute d
    WHERE (d.table_name=gmd_tab_info->table_name)
    DETAIL
     gmd_attributes->cnt = (gmd_attributes->cnt+ 1), stat = alterlist(gmd_attributes->qual,
      gmd_attributes->cnt), gmd_attributes->qual[gmd_attributes->cnt].column_name = d.column_name,
     gmd_attributes->qual[gmd_attributes->cnt].attribute_name = d.attribute_name, gmd_attributes->
     qual[gmd_attributes->cnt].attribute_value = d.attribute_value, gmd_attributes->qual[
     gmd_attributes->cnt].attribute_char = d.attribute_char,
     gmd_attributes->qual[gmd_attributes->cnt].attribute_dt_tm = d.attribute_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(build("While gathering ATTRIBUTES for the ",gmd_tab_info->table_name," table: "))=
   1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    dcd.table_name, dcd.column_name, dcd.unique_ident_ind,
    dcd.constant_value, dcd.exception_flg, dcd.merge_delete_ind,
    dtd.table_name, dtd.table_suffix, dtd.merge_delete_ind,
    dcd.root_entity_name, dcd.root_entity_attr, dcd.parent_entity_col
    FROM dm_tables_doc_local dtd,
     dm_columns_doc_local dcd
    WHERE (dtd.table_name=gmd_tab_info->table_name)
     AND (dcd.table_name=gmd_tab_info->table_name)
     AND dcd.column_name IN (
    (SELECT
     column_name
     FROM user_tab_cols utc
     WHERE utc.table_name=gmd_query_tab_name
      AND utc.hidden_column="NO"
      AND utc.virtual_column="NO"))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di
     WHERE sqlpassthru("dcd.table_name like di.info_char and dcd.column_name like di.info_name")
      AND di.info_domain="RDDS IGNORE COL LIST:*")))
    HEAD REPORT
     gmd_tab_info->table_name = dtd.table_name, gmd_tab_info->table_suffix = dtd.table_suffix,
     gmd_tab_info->merge_delete_ind = dtd.merge_delete_ind,
     gmd_col_cnt = 0
    DETAIL
     gmd_col_cnt = (gmd_col_cnt+ 1)
     IF (mod(gmd_col_cnt,10)=1)
      stat = alterlist(gmd_tab_info->cols,(gmd_col_cnt+ 10))
     ENDIF
     gmd_tab_info->cols[gmd_col_cnt].column_name = dcd.column_name, gmd_tab_info->cols[gmd_col_cnt].
     exception_flg = dcd.exception_flg, gmd_tab_info->cols[gmd_col_cnt].parent_entity_col = dcd
     .parent_entity_col,
     gmd_tab_info->cols[gmd_col_cnt].upd_val_str = build("r1.",dcd.column_name), gmd_tab_info->cols[
     gmd_col_cnt].ins_val_str = build("r1.",dcd.column_name)
     IF (((dtd.merge_delete_ind=0
      AND dcd.unique_ident_ind=1) OR (dtd.merge_delete_ind=1
      AND dcd.merge_delete_ind=1)) )
      IF (dcd.merge_delete_ind=1)
       gmd_tab_info->cols[gmd_col_cnt].md_ind = 1
      ENDIF
      gmd_tab_info->cols[gmd_col_cnt].ident_ind = 1
     ENDIF
     IF (daf_is_not_blank(dcd.constant_value)
      AND dcd.column_name != "UPDT_ID")
      gmd_tab_info->cols[gmd_col_cnt].upd_val_str = concat("t1.",dcd.column_name)
     ENDIF
     IF (dcd.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
     "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
     "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM"))
      gmd_tab_info->beg_eff_col_ndx = gmd_col_cnt
     ELSEIF (dcd.column_name IN ("END_EFFECTIVE_DT_TM", "PRSNL_END_EFFECTIVE_DT_TM",
     "END_EFFECTIVE_UTC_DT_TM", "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM"))
      gmd_tab_info->end_eff_col_ndx = gmd_col_cnt
     ELSEIF (dcd.column_name="ACTIVE_IND")
      IF (gmd_merge_active_ind=0
       AND dcd.exception_flg != 8)
       gmd_tab_info->cols[gmd_col_cnt].upd_val_str =
       "evaluate(r1.active_ind, 1, t1.active_ind, r1.active_ind)"
      ENDIF
     ENDIF
     FOR (gmd_att_idx = 1 TO gmd_attributes->cnt)
       IF ((gmd_attributes->qual[gmd_att_idx].column_name=dcd.column_name)
        AND (gmd_attributes->qual[gmd_att_idx].attribute_name="BEG_EFFECTIVE COLUMN_NAME_IND")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->beg_eff_col_ndx = gmd_col_cnt
       ELSEIF ((gmd_attributes->qual[gmd_att_idx].column_name=dcd.column_name)
        AND (gmd_attributes->qual[gmd_att_idx].attribute_name="END_EFFECTIVE COLUMN_NAME_IND")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->end_eff_col_ndx = gmd_col_cnt
       ELSEIF ((gmd_attributes->qual[gmd_att_idx].attribute_name="USER GENERATED DATE INDICATOR")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->user_dt_tm_ind = 1
       ELSEIF ((gmd_attributes->qual[gmd_att_idx].column_name=dcd.column_name)
        AND dcd.column_name="ACTIVE_IND"
        AND (gmd_attributes->qual[gmd_att_idx].attribute_name="STATIC COLUMN VALUE")
        AND (gmd_attributes->qual[gmd_att_idx].attribute_value=1))
        gmd_tab_info->static_active_ind = 1
       ENDIF
     ENDFOR
     gmd_col_pos = locateval(gmd_col_num,1,dml_overrides->cnt,dcd.column_name,dml_overrides->qual[
      gmd_col_num].column_name)
     WHILE (gmd_col_pos > 0)
      IF ((dml_overrides->qual[gmd_col_pos].dml_attribute="INS_VAL_STR"))
       gmd_tab_info->cols[gmd_col_cnt].ins_val_str = dml_overrides->qual[gmd_col_pos].dml_value
      ELSEIF ((dml_overrides->qual[gmd_col_pos].dml_attribute="UPD_VAL_STR"))
       gmd_tab_info->cols[gmd_col_cnt].upd_val_str = dml_overrides->qual[gmd_col_pos].dml_value
      ENDIF
      ,
      IF ((gmd_col_pos < dml_overrides->cnt))
       gmd_col_pos = locateval(gmd_col_num,(gmd_col_pos+ 1),dml_overrides->cnt,dcd.column_name,
        dml_overrides->qual[gmd_col_num].column_name)
      ELSE
       gmd_col_pos = 0
      ENDIF
     ENDWHILE
     gmd_tab_info->cols[gmd_col_cnt].sequence_name = dcd.sequence_name
     IF (dcd.exception_flg=12)
      gmd_tab_info->cols[gmd_col_cnt].grouper_col_ind = 1
     ENDIF
    FOOT  dtd.table_name
     stat = alterlist(gmd_tab_info->cols,gmd_col_cnt)
    WITH nocounter
   ;end select
   IF (check_error(build("While getting column list for the ",gmd_tab_info->table_name," table: "))=1
   )
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   FOR (gmd_ovr_ndx = 1 TO dml_overrides->cnt)
     IF (daf_is_blank(dml_overrides->qual[gmd_ovr_ndx].column_name))
      IF ((dml_overrides->qual[gmd_ovr_ndx].data_type="CHAR"))
       CALL parser(concat("set gmd_tab_info->",dml_overrides->qual[gmd_ovr_ndx].dml_attribute," = '",
         dml_overrides->qual[gmd_ovr_ndx].dml_value,"' go "),1)
      ELSEIF ((dml_overrides->qual[gmd_ovr_ndx].data_type="NUMBER"))
       CALL parser(concat("set gmd_tab_info->",dml_overrides->qual[gmd_ovr_ndx].dml_attribute," = ",
         dml_overrides->qual[gmd_ovr_ndx].dml_value," go "),1)
      ELSE
       SET dm_err->emsg = build("****Unrecognized data_type: ",dml_overrides->qual[gmd_ovr_ndx].
        data_type,"****")
       SET dm_err->err_ind = 0
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     (dummyt d  WITH seq = size(gmd_tab_info->cols,5))
    PLAN (d)
     JOIN (utc
     WHERE (utc.table_name=gmd_tab_info->table_name)
      AND (utc.column_name=gmd_tab_info->cols[d.seq].column_name))
    DETAIL
     gmd_tab_info->cols[d.seq].data_default = utc.data_default, gmd_tab_info->cols[d.seq].
     data_default_null_ind = nullind(utc.data_default), gmd_tab_info->cols[d.seq].data_type = utc
     .data_type
     IF (utc.data_type IN ("LONG", "LONG RAW", "RAW"))
      gmd_tab_info->cols[d.seq].long_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_CNT"
      AND utc.data_type IN ("NUMBER", "FLOAT"))
      gmd_tab_info->cols[d.seq].upd_val_str = "t1.updt_cnt+1", gmd_tab_info->cols[d.seq].ins_val_str
       = "0"
     ELSEIF (utc.column_name="UPDT_DT_TM"
      AND utc.data_type="DATE")
      gmd_tab_info->cols[d.seq].upd_val_str = "v_curdate", gmd_tab_info->cols[d.seq].ins_val_str =
      "v_curdate"
     ENDIF
     gmd_tab_info->cols[d.seq].nullable = "Y"
    WITH nocounter
   ;end select
   IF (check_error(build("While getting the datatypes for the column list for the:",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM dtableattr a,
     dtableattrl l
    PLAN (a
     WHERE (a.table_name=gmd_tab_info->table_name))
     JOIN (l
     WHERE l.structtype="F"
      AND btest(l.stat,11)=0)
    DETAIL
     gmd_col_pos = 0, gmd_col_pos = locateval(gmd_tp_ndx,1,size(gmd_tab_info->cols,5),l.attr_name,
      gmd_tab_info->cols[gmd_tp_ndx].column_name)
     IF (gmd_col_pos > 0)
      gmd_tab_info->cols[gmd_col_pos].ccl_type = l.type
     ELSE
      gmd_tab_info->cols[gmd_col_pos].ccl_type = "Z"
     ENDIF
    WITH nocounter
   ;end select
   SET gmd_cms_cnt = 0
   SELECT INTO "NL:"
    FROM dm2_user_notnull_cols unc
    WHERE expand(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),unc.column_name,gmd_tab_info->cols[
     gmd_cms_cnt].column_name)
     AND (unc.table_name=gmd_tab_info->table_name)
    DETAIL
     gmd_cms_cnt = locateval(gmd_cms_num2,1,size(gmd_tab_info->cols,5),unc.column_name,gmd_tab_info->
      cols[gmd_cms_num2].column_name)
     IF (gmd_cms_cnt > 0)
      gmd_tab_info->cols[gmd_cms_cnt].nullable = "N", gmd_cms_cnt = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(build("While getting all not nullable columns for the table: ",gmd_tab_info->
     table_name))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET gmd_cms_i = 1
   FOR (gmd_cms_i = 1 TO size(gmd_tab_info->cols,5))
     IF ((gmd_tab_info->cols[gmd_cms_i].nullable="N"))
      IF ((((gmd_tab_info->cols[gmd_cms_i].ins_val_str=concat("r1.",gmd_tab_info->cols[gmd_cms_i].
       column_name))) OR ((gmd_tab_info->cols[gmd_cms_i].upd_val_str=concat("r1.",gmd_tab_info->cols[
       gmd_cms_i].column_name)))) )
       SELECT INTO "NL:"
        FROM dm2_user_notnull_cols r1
        WHERE (r1.table_name=gmd_tab_info->tab_$r)
         AND (r1.column_name=gmd_tab_info->cols[gmd_cms_i].column_name)
        WITH nocounter
       ;end select
       SET gmd_curqual = curqual
       IF (check_error(build("While getting all not nullable columns for the table: ",gmd_tab_info->
         tab_$r))=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN
       ENDIF
       IF (gmd_curqual=0)
        CALL pk_data_default(gmd_tab_info,gmd_cms_i)
        IF ((gmd_tab_info->cols[gmd_cms_i].ins_val_str=concat("r1.",gmd_tab_info->cols[gmd_cms_i].
         column_name)))
         IF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("LONG", "CHAR", "VARCHAR2", "DATE")))
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",<BrEaK>",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("BLOB", "RAW", "LONG RAW")))
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",<BrEaK> hextoraw( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type="*CLOB"))
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",<BrEaK> to_clob( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSE
          SET gmd_tab_info->cols[gmd_cms_i].ins_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].ins_val_str,",",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ENDIF
        ENDIF
        IF ((gmd_tab_info->cols[gmd_cms_i].upd_val_str=concat("r1.",gmd_tab_info->cols[gmd_cms_i].
         column_name)))
         IF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("LONG", "CHAR", "VARCHAR2", "DATE")))
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",<BrEaK>",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type IN ("BLOB", "RAW", "LONG RAW")))
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",<BrEaK> hextoraw( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSEIF ((gmd_tab_info->cols[gmd_cms_i].data_type="*CLOB"))
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",<BrEaK> to_clob( ",gmd_tab_info->cols[gmd_cms_i].data_default,
           "))")
         ELSE
          SET gmd_tab_info->cols[gmd_cms_i].upd_val_str = build("nullval(",gmd_tab_info->cols[
           gmd_cms_i].upd_val_str,",",gmd_tab_info->cols[gmd_cms_i].data_default,")")
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((gmd_tab_info->cols[gmd_cms_i].ident_ind=1)
      AND daf_is_blank(gmd_tab_info->ui_match_str_ovr))
      IF ((gmd_tab_info->cols[gmd_cms_i].nullable="N"))
       SET gmd_tab_info->ui_match_str = concat(gmd_tab_info->ui_match_str," and t1.",gmd_tab_info->
        cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name)
      ELSE
       SET gmd_tab_info->ui_match_str = concat(gmd_tab_info->ui_match_str," and (t1.",gmd_tab_info->
        cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name,
        " or (t1.",gmd_tab_info->cols[gmd_cms_i].column_name," is null and r1.",gmd_tab_info->cols[
        gmd_cms_i].column_name," is null))")
      ENDIF
     ENDIF
     IF ((gmd_tab_info->cols[gmd_cms_i].grouper_col_ind=1))
      IF ((gmd_tab_info->cols[gmd_cms_i].nullable="N"))
       SET gmd_tab_info->grouper_match_str = concat(gmd_tab_info->grouper_match_str," and t1.",
        gmd_tab_info->cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name)
      ELSE
       SET gmd_tab_info->grouper_match_str = concat(gmd_tab_info->grouper_match_str," and (t1.",
        gmd_tab_info->cols[gmd_cms_i].column_name," = r1.",gmd_tab_info->cols[gmd_cms_i].column_name,
        " or (t1.",gmd_tab_info->cols[gmd_cms_i].column_name," is null and r1.",gmd_tab_info->cols[
        gmd_cms_i].column_name," is null))")
      ENDIF
     ENDIF
   ENDFOR
   IF (daf_is_blank(gmd_tab_info->ui_match_str_ovr))
    SET gmd_tab_info->ui_match_str = substring(6,10000,gmd_tab_info->ui_match_str)
   ENDIF
   SET gmd_tab_info->grouper_match_str = substring(6,10000,gmd_tab_info->grouper_match_str)
   SET gmd_alias_nbr = 0
   FOR (gmd_col_pos = 1 TO size(gmd_tab_info->cols,5))
     IF ((gmd_tab_info->cols[gmd_col_pos].exception_flg=9))
      SET gmd_tab_info->exception_flg9_ind = 1
      SET gmd_alias_nbr = (gmd_alias_nbr+ 1)
      SET gmd_alias_str = build("d",gmd_alias_nbr)
      SET gmd_tab_info->cols[gmd_col_pos].ins_val_str = concat("(select nullval(max(",gmd_alias_str,
       ".",trim(gmd_tab_info->cols[gmd_col_pos].column_name,3),")+1,1) from ",
       gmd_tab_info->table_name," ",gmd_alias_str," where ",replace(cnvtlower(gmd_tab_info->
         ui_match_str),"t1.",build(gmd_alias_str,"."),0),
       ")")
      CALL echo(build(gmd_tab_info->table_name,".",gmd_tab_info->cols[gmd_col_pos].column_name,
        ".ins_val_str (for sequence max+1) = ",gmd_tab_info->cols[gmd_col_pos].ins_val_str))
     ENDIF
   ENDFOR
   SET gmd_alias_nbr = 0
   SELECT INTO "nl:"
    FROM dm_refchg_version_r drvr
    WHERE (drvr.child_table=gmd_tab_info->table_name)
    DETAIL
     FOR (gmd_col_pos = 1 TO size(gmd_tab_info->cols,5))
       IF ((gmd_tab_info->cols[gmd_col_pos].column_name=drvr.child_vers_col))
        gmd_alias_nbr = (gmd_alias_nbr+ 1), gmd_alias_str = build("d",gmd_alias_nbr), gmd_tab_info->
        cols[gmd_col_pos].ins_val_str = concat("(select ",build(gmd_alias_str,"."),trim(drvr
          .parent_vers_col)," from ",trim(drvr.parent_table),
         " ",gmd_alias_str," where ",build(gmd_alias_str,"."),trim(drvr.parent_id_col),
         " = r1.",trim(drvr.child_id_col),")"),
        gmd_tab_info->cols[gmd_col_pos].upd_val_str = gmd_tab_info->cols[gmd_col_pos].ins_val_str
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(build("While getting the version of the parent table(s) of the ",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=4000220
     AND cv.cdf_meaning="INSERT_ONLY"
     AND (cv.display=gmd_tab_info->table_name)
    DETAIL
     CALL echo(build("Target as Master=",cv.display))
     FOR (gmd_col_pos = 1 TO size(gmd_tab_info->cols,5))
       gmd_tab_info->cols[gmd_col_pos].upd_val_str = build("t1.",gmd_tab_info->cols[gmd_col_pos].
        column_name)
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(build("While checking for the INSERT ONLY code_value row for the ",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    ucc.column_name
    FROM user_constraints uc,
     user_cons_columns ucc
    WHERE (uc.table_name=gmd_tab_info->table_name)
     AND uc.constraint_type="P"
     AND uc.constraint_name=ucc.constraint_name
     AND uc.table_name=ucc.table_name
     AND  NOT (uc.table_name IN (
    (SELECT
     utc.table_name
     FROM user_tab_cols utc
     WHERE utc.table_name=ucc.table_name
      AND utc.column_name=ucc.column_name
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" utc.column_name like di.info_name and utc.table_name like di.info_char")))
     )) )) )))
    DETAIL
     gmd_col_pos = 0, gmd_col_pos = locateval(gmd_drcd_index,1,size(gmd_tab_info->cols,5),ucc
      .column_name,gmd_tab_info->cols[gmd_drcd_index].column_name)
     IF ( NOT (gmd_col_pos BETWEEN 1 AND size(gmd_tab_info->cols,5)))
      dm_err->emsg = build("****Column not found in table: ",ucc.column_name,"****"), dm_err->err_ind
       = 1
     ELSE
      gmd_tab_info->cols[gmd_col_pos].pk_ind = 1, gmd_tab_info->pk_match_str = concat(gmd_tab_info->
       pk_match_str," and t1.",trim(ucc.column_name,3)," = r1.",trim(ucc.column_name,3)),
      gmd_tab_info->pk_diff_str = concat(gmd_tab_info->pk_diff_str," or t1.",trim(ucc.column_name,3),
       "!= r1.",trim(ucc.column_name,3)),
      CALL pk_data_default(tab_info,gmd_col_pos), gmd_tab_info->default_row_str = concat(gmd_tab_info
       ->default_row_str," and ",trim(gmd_tab_info->cols[gmd_col_pos].column_name,3)," = ",trim(
        gmd_tab_info->cols[gmd_col_pos].data_default,3)), gmd_tab_info->pk_long_str = concat(
       gmd_tab_info->pk_long_str,'," and ',trim(ucc.column_name,3),' = ",')
      IF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("VARCHAR", "VARCHAR2", "CHAR", "CLOB",
      "BLOB")))
       gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,'build(^"^,',trim(ucc.column_name,
         3),',^"^)')
      ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("NUMBER", "FLOAT")))
       gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,"build(",trim(ucc.column_name,3),
        ")")
      ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("DATE")))
       gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,
        '"cnvtdatetime(cnvtdate(",concat(format(',trim(ucc.column_name,3),^, "MMDDYYYY"),',',format(^,
        trim(ucc.column_name,3),
        ', "HHMMSS")),")"')
      ENDIF
     ENDIF
    FOOT REPORT
     gmd_tab_info->default_row_str = substring(6,10000,gmd_tab_info->default_row_str), gmd_tab_info->
     pk_match_str = substring(6,10000,gmd_tab_info->pk_match_str), gmd_tab_info->pk_diff_str =
     substring(5,10000,gmd_tab_info->pk_diff_str),
     gmd_tab_info->pk_long_str = concat('concat("',trim(substring(8,10000,gmd_tab_info->pk_long_str)),
      ")")
    WITH nocounter
   ;end select
   IF (check_error(concat("While getting the PK information for the ",gmd_tab_info->table_name,
     " table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     di.info_char
     FROM dm_info di
     WHERE di.info_domain=patstring(concat("RDDS PK OVERRIDE:",gmd_tab_info->table_name,"/*"))
      AND (di.info_name=gmd_tab_info->table_name)
     DETAIL
      gmd_col_pos = 0, gmd_col_pos = locateval(gmd_drcd_index,1,size(gmd_tab_info->cols,5),di
       .info_char,gmd_tab_info->cols[gmd_drcd_index].column_name)
      IF ( NOT (gmd_col_pos BETWEEN 1 AND size(gmd_tab_info->cols,5)))
       dm_err->emsg = build("****Column not found in table: ",di.info_char,"****"), dm_err->err_ind
        = 1
      ELSE
       gmd_tab_info->cols[gmd_col_pos].pk_ind = 1, gmd_tab_info->pk_match_str = concat(gmd_tab_info->
        pk_match_str," and t1.",trim(di.info_char,3)," = r1.",trim(di.info_char,3)), gmd_tab_info->
       pk_diff_str = concat(gmd_tab_info->pk_diff_str," or t1.",trim(di.info_char,3),"!= r1.",trim(di
         .info_char,3)),
       CALL pk_data_default(tab_info,gmd_col_pos), gmd_tab_info->default_row_str = concat(
        gmd_tab_info->default_row_str," and ",trim(gmd_tab_info->cols[gmd_col_pos].column_name,3),
        " = ",trim(gmd_tab_info->cols[gmd_col_pos].data_default,3)), gmd_tab_info->pk_long_str =
       concat(gmd_tab_info->pk_long_str,'," and ',trim(di.info_char,3),' = ",')
       IF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("VARCHAR", "VARCHAR2", "CHAR", "CLOB",
       "BLOB")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,'build(^"^,',trim(di.info_char,3
          ),',^"^)')
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("NUMBER", "FLOAT")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,"build(",trim(di.info_char,3),
         ")")
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("DATE")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,
         '"cnvtdatetime(cnvtdate(",concat(format(',trim(di.info_char,3),^, "MMDDYYYY"),',',format(^,
         trim(di.info_char,3),
         ', "HHMMSS")),")"')
       ENDIF
      ENDIF
     FOOT REPORT
      gmd_tab_info->default_row_str = substring(6,10000,gmd_tab_info->default_row_str), gmd_tab_info
      ->pk_match_str = substring(6,10000,gmd_tab_info->pk_match_str), gmd_tab_info->pk_diff_str =
      substring(5,10000,gmd_tab_info->pk_diff_str),
      gmd_tab_info->pk_long_str = concat('concat("',trim(substring(8,10000,gmd_tab_info->pk_long_str)
        ),")")
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     dcd.column_name
     FROM dm_columns_doc_local dcd
     WHERE (dcd.table_name=gmd_tab_info->table_name)
      AND dcd.unique_ident_ind=1
     DETAIL
      gmd_col_pos = 0, gmd_col_pos = locateval(gmd_drcd_index,1,size(gmd_tab_info->cols,5),dcd
       .column_name,gmd_tab_info->cols[gmd_drcd_index].column_name)
      IF ( NOT (gmd_col_pos BETWEEN 1 AND size(gmd_tab_info->cols,5)))
       dm_err->emsg = build("****Column not found in table: ",dcd.column_name,"****"), dm_err->
       err_ind = 1
      ELSE
       gmd_tab_info->cols[gmd_col_pos].pk_ind = 1
       IF ((gmd_tab_info->cols[gmd_col_pos].nullable="N"))
        gmd_tab_info->pk_match_str = concat(gmd_tab_info->pk_match_str," and t1.",trim(dcd
          .column_name,3)," = r1.",trim(dcd.column_name,3))
       ELSE
        gmd_tab_info->nullable_ui_ind = 1, gmd_tab_info->pk_match_str = concat(gmd_tab_info->
         pk_match_str," and (t1.",trim(dcd.column_name,3)," = r1.",trim(dcd.column_name,3),
         " or (t1.",trim(dcd.column_name,3)," is null and r1.",trim(dcd.column_name,3)," is null))")
       ENDIF
       gmd_tab_info->pk_diff_str = concat(gmd_tab_info->pk_diff_str," or t1.",trim(dcd.column_name,3),
        " != r1.",trim(dcd.column_name,3)), gmd_tab_info->pk_long_str = concat(gmd_tab_info->
        pk_long_str,'," and ',trim(dcd.column_name,3),' = ",')
       IF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("VARCHAR", "VARCHAR2", "CHAR", "CLOB",
       "BLOB")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,'build(^"^,',trim(dcd
          .column_name,3),',^"^)')
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("NUMBER", "FLOAT")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,"build(",trim(dcd.column_name,3),
         ")")
       ELSEIF ((gmd_tab_info->cols[gmd_col_pos].data_type IN ("DATE")))
        gmd_tab_info->pk_long_str = concat(gmd_tab_info->pk_long_str,
         '"cnvtdatetime(cnvtdate(",concat(format(',trim(dcd.column_name,3),
         ^, "MMDDYYYY"),',',format(^,trim(dcd.column_name,3),
         ', "HHMMSS")),")"')
       ENDIF
      ENDIF
     FOOT REPORT
      gmd_tab_info->pk_match_str = substring(6,10000,gmd_tab_info->pk_match_str), gmd_tab_info->
      pk_diff_str = substring(5,10000,gmd_tab_info->pk_diff_str), gmd_tab_info->pk_long_str = concat(
       'concat(" ',trim(substring(8,10000,gmd_tab_info->pk_long_str)),")")
     WITH nocounter
    ;end select
    IF (check_error(concat("While getting the PK information for the ",gmd_tab_info->table_name,
      " table: "))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=255351
     AND ((cv.cdf_meaning = null) OR (cv.cdf_meaning != "NONE"))
     AND (cv.display=gmd_tab_info->table_name)
     AND cv.active_ind=1
    DETAIL
     gmd_tab_info->versioning_ind = 1, gmd_tab_info->version_cdf = cv.cdf_meaning
     IF ( NOT (cv.cdf_meaning IN ("ALG2", "ALG5", "ALG6")))
      CALL echo(build(cv.cdf_meaning,": ",cv.display," = ",gmd_tab_info->beg_eff_col_ndx))
      IF ((gmd_tab_info->beg_eff_col_ndx > 0))
       gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].ins_val_str = "v_curdate", gmd_tab_info->
       cols[gmd_tab_info->beg_eff_col_ndx].upd_val_str = concat("t1.",gmd_tab_info->cols[gmd_tab_info
        ->beg_eff_col_ndx].column_name)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(build("While selecting the effective date fields for the ",gmd_tab_info->
     table_name," table: "))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET gmd_col_pos = 0
   FOR (gmd_cms_cnt = 1 TO size(gmd_tab_info->cols,5))
     IF ((gmd_tab_info->cols[gmd_cms_cnt].pk_ind=1))
      SET gmd_col_pos = (gmd_col_pos+ 1)
      SET gmd_tab_info->pk_col_ndx = gmd_cms_cnt
     ENDIF
   ENDFOR
   IF (gmd_col_pos > 1)
    SET gmd_tab_info->pk_col_ndx = 0
   ENDIF
   IF ((gmd_tab_info->version_cdf IN ("ALG2", "ALG5")))
    SET dm_err->eproc = "Gathering Previous PK column for ALG2 or ALG5 table."
    SET gmd_cms_cnt = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),1,gmd_tab_info->cols[
     gmd_cms_cnt].pk_ind)
    IF (gmd_cms_cnt > 0)
     SELECT INTO "nl:"
      FROM dm_columns_doc_local d
      WHERE (d.root_entity_name=gmd_tab_info->table_name)
       AND (d.root_entity_attr=gmd_tab_info->cols[gmd_cms_cnt].column_name)
       AND (d.column_name != gmd_tab_info->cols[gmd_cms_cnt].column_name)
       AND d.exception_flg=11
      DETAIL
       gmd_tab_info->prev_pk_col_ndx = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),d
        .column_name,gmd_tab_info->cols[gmd_cms_cnt].column_name)
       IF ((gmd_tab_info->beg_eff_col_ndx > 0))
        gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,
         ",v_curdate), v_curdate, v_curdate, t1.",gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].
         column_name,")")
       ENDIF
       CALL echo(build(gmd_tab_info->version_cdf,":",gmd_tab_info->table_name," = ",gmd_tab_info->
        end_eff_col_ndx))
       IF ((gmd_tab_info->end_eff_col_ndx > 0))
        gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,",v_curdate), r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,", v_curdate, r1.",
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,")")
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      SELECT INTO "nl:"
       FROM dm_columns_doc_local d
       WHERE (d.root_entity_name=gmd_tab_info->table_name)
        AND (d.root_entity_attr=gmd_tab_info->cols[gmd_cms_cnt].column_name)
        AND (d.column_name != gmd_tab_info->cols[gmd_cms_cnt].column_name)
        AND d.column_name="PREV*"
       DETAIL
        gmd_tab_info->prev_pk_col_ndx = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),d
         .column_name,gmd_tab_info->cols[gmd_cms_cnt].column_name)
        IF ((gmd_tab_info->beg_eff_col_ndx > 0))
         gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,
          ",v_curdate), v_curdate, v_curdate, t1.",gmd_tab_info->cols[gmd_tab_info->beg_eff_col_ndx].
          column_name,")")
        ENDIF
        CALL echo(build(gmd_tab_info->version_cdf,":",gmd_tab_info->table_name," = ",gmd_tab_info->
         end_eff_col_ndx))
        IF ((gmd_tab_info->end_eff_col_ndx > 0))
         gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].upd_val_str = concat("evaluate(least(r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,",v_curdate), r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,", v_curdate, r1.",
          gmd_tab_info->cols[gmd_tab_info->end_eff_col_ndx].column_name,")")
        ENDIF
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET dm_err->err_ind = 1
       CALL disp_msg(build("The table ",gmd_tab_info->table_name,
         " table is not correctly set up for ",gmd_tab_info->version_cdf),dm_err->logfile,1)
       RETURN
      ENDIF
     ENDIF
     IF (check_error(build("While selecting the previous pk column for the ",gmd_tab_info->table_name,
       " table: "))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     SELECT INTO "NL:"
      FROM dm_info di
      WHERE di.info_domain=patstring(concat("RDDS CIRCULAR:",gmd_tab_info->table_name,":*"))
      DETAIL
       IF (di.info_number=2)
        gmd_cms_cnt = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),trim(substring((findstring(
            ":",di.info_domain,1,1)+ 1),30,di.info_domain)),gmd_tab_info->cols[gmd_cms_cnt].
         parent_entity_col)
       ELSE
        gmd_cms_cnt = locateval(gmd_cms_cnt,1,size(gmd_tab_info->cols,5),trim(substring((findstring(
            ":",di.info_domain,1,1)+ 1),30,di.info_domain)),gmd_tab_info->cols[gmd_cms_cnt].
         column_name)
       ENDIF
       IF (gmd_cms_cnt > 0)
        gmd_tab_info->cols[gmd_cms_cnt].circ_cnt = (gmd_tab_info->cols[gmd_cms_cnt].circ_cnt+ 1),
        stat = alterlist(gmd_tab_info->cols[gmd_cms_cnt].circ_qual,gmd_tab_info->cols[gmd_cms_cnt].
         circ_cnt), gmd_tab_info->cols[gmd_cms_cnt].circ_qual[gmd_tab_info->cols[gmd_cms_cnt].
        circ_cnt].circ_table_name = substring(1,(findstring(":",di.info_name,1,1) - 1),di.info_name),
        gmd_tab_info->cols[gmd_cms_cnt].circ_qual[gmd_tab_info->cols[gmd_cms_cnt].circ_cnt].
        circ_fk_col_name = substring((findstring(":",di.info_name,1,1)+ 1),30,di.info_name),
        gmd_tab_info->cols[gmd_cms_cnt].circ_qual[gmd_tab_info->cols[gmd_cms_cnt].circ_cnt].
        circ_entity_col_name = di.info_char
        IF (di.info_number=2)
         gmd_tab_info->cols[gmd_cms_cnt].self_entity_name = substring((findstring(":",di.info_domain,
           1,1)+ 1),30,di.info_domain)
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(build("While selecting the circular references for the ",gmd_tab_info->
       table_name," table: "))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg(build("PK information does not exist for the for the ",gmd_tab_info->table_name,
       " table: "),dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE init_rs_data(ird_info)
   SET ird_info->table_name = ""
   SET ird_info->tab_$r = ""
   SET ird_info->r_tab_exists = 0
   SET ird_info->table_suffix = ""
   SET ird_info->merge_delete_ind = 0
   SET ird_info->versioning_ind = 0
   SET ird_info->version_cdf = ""
   SET ird_info->beg_eff_col_ndx = 0
   SET ird_info->end_eff_col_ndx = 0
   SET ird_info->prev_pk_col_ndx = 0
   SET ird_info->ui_match_str = ""
   SET ird_info->pk_diff_str = ""
   SET ird_info->pk_match_str = ""
   SET ird_info->pk_long_str = ""
   SET ird_info->ui_col_list = ""
   SET ird_info->all_upd_val_str = ""
   SET ird_info->all_ins_val_str = ""
   SET ird_info->tm_all_upd_val_str = ""
   SET ird_info->tm_all_ins_val_str = ""
   SET ird_info->col_list = ""
   SET ird_info->md_col_list = ""
   SET ird_info->pk_col_list = ""
   SET ird_info->default_row_str = ""
   SET ird_info->long_call = ""
   SET ird_info->long_pk_str = ""
   SET ird_info->exception_flg9_ind = 0
   SET ird_info->nullable_ui_ind = 0
   SET ird_info->upd_col_list = ""
   SET ird_info->upd_val_list = ""
   SET ird_info->grouper_col_list = ""
   SET ird_info->grouper_match_str = ""
   SET stat = alterlist(ird_info->cols,0)
   RETURN
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
 DECLARE add_stmt(i_str=vc,i_rdb_asis_ind=i2,i_end_ind=i2,i_move_long_str_ind=i2,io_stmt_cnt=i4(ref),
  io_rs_stmts=vc(ref)) = null
 SUBROUTINE add_stmt(i_str,i_rdb_asis_ind,i_end_ind,i_move_long_str_ind,io_stmt_cnt,io_rs_stmts)
   DECLARE s_max_length = i4 WITH protect
   DECLARE s_start = i4 WITH protect
   DECLARE s_str_len = i4 WITH protect
   DECLARE s_str = vc WITH protect, noconstant("")
   SET s_str = i_str
   SET s_max_length = 130
   IF (i_rdb_asis_ind=1)
    SET s_max_length = (s_max_length - 15)
    IF (findstring("v_curdate",s_str) > 0)
     SET s_max_length = (s_max_length - 50)
    ENDIF
   ENDIF
   IF (i_end_ind=1)
    SET s_max_length = (s_max_length - 7)
   ENDIF
   SET s_start = 1
   SET s_str_len = size(s_str,1)
   WHILE (s_start <= s_str_len)
    SET s_break_pos = findstring("<BrEaK>",substring(s_start,s_max_length,s_str),1,0)
    IF (s_break_pos > 0)
     SET s_break_pos = (s_break_pos - 1)
     SET io_stmt_cnt = (io_stmt_cnt+ 1)
     SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
     SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = 0
     SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,s_break_pos,s_str)
     SET s_start = ((s_start+ s_break_pos)+ 7)
    ELSEIF ((((s_str_len - s_start)+ 1) <= s_max_length))
     SET io_stmt_cnt = (io_stmt_cnt+ 1)
     SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
     SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,((s_str_len - s_start)+ 1),s_str)
     SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = i_end_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
     SET s_start = (s_str_len+ 1)
    ELSE
     SET s_space_pos = findstring(" ",substring(s_start,s_max_length,s_str),1,1)
     IF (s_space_pos=0)
      CALL echo(substring(s_start,s_max_length,s_str))
      RETURN
     ENDIF
     SET io_stmt_cnt = (io_stmt_cnt+ 1)
     SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
     SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = 0
     SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
     SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,s_space_pos,s_str)
     SET s_start = (s_start+ s_space_pos)
    ENDIF
   ENDWHILE
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
 IF (check_logfile("dm_rdds_ui_dup_",".log","dm_rdds_ui_dup_checker FILE...") != 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 DECLARE log_refchg_warning(lrw_err_msg=vc,lrw_s_env_id=f8,lrm_warning_type=vc,lrw_tbl_name=vc) = i2
 DECLARE refchg_check_table(rct_tbl=vc) = i2
 DECLARE refchg_check_ui(rcu_warning_type=vc,rcu_tbl=vc) = null
 DECLARE udc_status = i4 WITH noconstant(0)
 DECLARE udc_warning_cnt = i4 WITH noconstant(0)
 DECLARE udc_cur_env = f8
 FREE RECORD udc_warning
 RECORD udc_warning(
   1 source_env_id = f8
   1 size_cnt = i4
   1 list[*]
     2 warning_type = vc
     2 message = vc
     2 table_name = vc
 )
 FREE RECORD rcu_hp
 RECORD rcu_hp(
   1 list[*]
     2 plan_name = vc
     2 plan_name_key = vc
     2 plan_type_cd = f8
 )
 FREE RECORD rcu_cs
 RECORD rcu_cs(
   1 list[*]
     2 chart_section_desc = vc
 )
 FREE RECORD rcu_pc
 RECORD rcu_pc(
   1 list[*]
     2 description = vc
     2 version = i4
     2 ref_owner_person_id = f8
 )
 FREE RECORD rcu_srai
 RECORD rcu_srai(
   1 list[*]
     2 action_item_name_key = vc
     2 child_selection_req_ind = i2
     2 value_required_ind = i2
     2 value_type_flag = i2
 )
 FREE RECORD rcu_srg
 RECORD rcu_srg(
   1 list[*]
     2 group_prompt = vc
     2 multi_select_ind = i2
     2 selection_required_ind = i2
 )
 SET dm_err->eproc = "Starting UI checking..."
 IF ((validate(request->source_env_id,- (1))=- (1)))
  SET dm_err->emsg = "The request is not defined"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 DELETE  FROM dm_refchg_warning
  WHERE (source_env_id=request->source_env_id)
   AND warning_type IN ("DUP BEFORE CUTOVER", "DUP AFTER CUTOVER", "EXECUTION ERROR", "MISSING TABLE"
  )
  WITH nocounter
 ;end delete
 IF (check_error("Clean up table dm_refchg_warning") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ROLLBACK
  GO TO exit_program
 ENDIF
 COMMIT
 EXECUTE dm2_set_context "FIRE_RMC_TRG", "NO"
 EXECUTE dm2_set_context "FIRE_EA_TRG", "NO"
 CALL drud_tbl_wrapper("HEALTH_PLAN","ORG_PLAN_RELTN","",1)
 CALL drud_tbl_wrapper("ACCOUNT","AT_ACCT_RELTN","BE_AT_RELTN",1)
 CALL drud_tbl_wrapper("APPLICATION","PM_FLX_CONVERSATION","",1)
 CALL drud_tbl_wrapper("CHART_SECTION","CHART_FORM_SECTS","",1)
 CALL drud_tbl_wrapper("PATHWAY_CATALOG","PW_CAT_RELTN","",1)
 CALL drud_tbl_wrapper("SA_REF_ACTION_ITEM","SA_REF_GROUP_ACTION_ITEM_R","",1)
 CALL drud_tbl_wrapper("SA_REF_GROUP","SA_REF_ACTION_GROUP_R","",1)
 CALL drud_tbl_wrapper("CODE_VALUE","","",0)
 CALL drud_tbl_wrapper("ORDER_CATALOG","","",0)
 CALL drud_tbl_wrapper("RESOURCE_GROUP","","",0)
 CALL drud_tbl_wrapper("IMAGE_CLASS_TYPE","","",0)
 CALL drud_tbl_wrapper("DISCRETE_TASK_ASSAY","","",0)
 CALL drud_tbl_wrapper("ORDER_ENTRY_FIELDS","","",0)
 CALL drud_tbl_wrapper("TRACK_REFERENCE","","",0)
 ROLLBACK
 FOR (lp = 1 TO udc_warning->size_cnt)
   IF (log_refchg_warning(udc_warning->list[lp].message,request->source_env_id,udc_warning->list[lp].
    warning_type,udc_warning->list[lp].table_name)=1)
    GO TO exit_program
   ENDIF
 ENDFOR
 COMMIT
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_name="DM_ENV_ID"
   AND d.info_domain="DATA MANAGEMENT"
  DETAIL
   udc_cur_env = d.info_number
  WITH nocounter
 ;end select
 IF (check_error("Select current environment id") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ROLLBACK
  GO TO exit_program
 ENDIF
 SET stat = alterlist(auto_ver_request->qual,1)
 SET auto_ver_request->qual[1].rdds_event = "UI Dup Checker"
 SET auto_ver_request->qual[1].cur_environment_id = udc_cur_env
 SET auto_ver_request->qual[1].paired_environment_id = 0
 EXECUTE dm_rmc_auto_verify_setup
 IF ((auto_ver_reply->status="F"))
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ELSE
  COMMIT
 ENDIF
 SET stat = initrec(auto_ver_request)
 SET stat = initrec(auto_ver_reply)
 SUBROUTINE drud_tbl_wrapper(dtw_tbl,dtw_sec_tbl,dtw_thir_tbl,dtw_rollback_flag)
   IF (refchg_check_table(dtw_tbl)=0)
    SET dm_err->eproc = concat("Check duplicates before cutover for table ",dtw_tbl)
    CALL disp_msg("",dm_err->logfile,0)
    CALL refchg_check_ui("DUP BEFORE CUTOVER",dtw_tbl)
    SET dm_err->eproc = concat("Run DDL for table ",dtw_tbl)
    CALL disp_msg("",dm_err->logfile,0)
    CALL cutover_get_and_run_dml(dtw_tbl,request->source_env_id,0,0)
    IF ((dm_err->err_ind=1))
     CALL pop_warning_rs(dm_err->emsg,"EXECUTION ERROR",dtw_tbl)
     SET dm_err->err_ind = 0
    ENDIF
    IF (trim(dtw_sec_tbl) > " ")
     SET dm_err->eproc = concat("Run DDL for table ",dtw_sec_tbl)
     CALL disp_msg("",dm_err->logfile,0)
     CALL cutover_get_and_run_dml(dtw_sec_tbl,request->source_env_id,0,0)
     IF ((dm_err->err_ind=1))
      CALL pop_warning_rs(dm_err->emsg,"EXECUTION ERROR",dtw_sec_tbl)
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
    IF (trim(dtw_thir_tbl) > " ")
     SET dm_err->eproc = concat("Run DDL for table ",dtw_thir_tbl)
     CALL disp_msg("",dm_err->logfile,0)
     CALL cutover_get_and_run_dml(dtw_thir_tbl,request->source_env_id,0,0)
     IF ((dm_err->err_ind=1))
      CALL pop_warning_rs(dm_err->emsg,"EXECUTION ERROR",dtw_thir_tbl)
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Check duplicates after cutover for table ",dtw_tbl)
    CALL disp_msg("",dm_err->logfile,0)
    CALL refchg_check_ui("DUP AFTER CUTOVER",dtw_tbl)
    IF (dtw_rollback_flag=1)
     ROLLBACK
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE log_refchg_warning(lrw_err_msg,lrw_s_env_id,lrw_warning_type,lrw_tbl_name)
  INSERT  FROM dm_refchg_warning
   SET dm_refchg_warning_id = seq(dm_clinical_seq,nextval), warning_type = lrw_warning_type, message
     = lrw_err_msg,
    table_name = lrw_tbl_name, source_env_id = lrw_s_env_id, updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task, updt_id = reqinfo->updt_id,
    updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (check_error("log refchg waring to table dm_refchg_warning") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ROLLBACK
  ENDIF
 END ;Subroutine
 SUBROUTINE refchg_check_ui(rcu_warning_type,rcu_tbl)
   DECLARE rcu_hp_cnt = i4 WITH noconstant(0)
   DECLARE rcu_cs_cnt = i4 WITH noconstant(0)
   DECLARE rcu_pc_cnt = i4 WITH noconstant(0)
   DECLARE rcu_srg_cnt = i4 WITH noconstant(0)
   DECLARE rcu_srai_cnt = i4 WITH noconstant(0)
   DECLARE rcu_num = i4 WITH noconstant(0)
   IF (rcu_tbl="HEALTH_PLAN")
    SELECT INTO "nl:"
     count(*), h.plan_name, h.plan_name_key,
     h.plan_type_cd
     FROM health_plan h
     GROUP BY h.plan_name, h.plan_name_key, h.plan_type_cd
     HAVING count(*) > 1
     DETAIL
      rcu_hp_cnt = (rcu_hp_cnt+ 1)
      IF (mod(rcu_hp_cnt,50)=1)
       stat = alterlist(rcu_hp->list,(rcu_hp_cnt+ 49))
      ENDIF
      rcu_hp->list[rcu_hp_cnt].plan_name = h.plan_name, rcu_hp->list[rcu_hp_cnt].plan_name_key = h
      .plan_name_key, rcu_hp->list[rcu_hp_cnt].plan_type_cd = h.plan_type_cd
     WITH nocounter
    ;end select
    FOR (lpr = 1 TO rcu_hp_cnt)
      SELECT INTO "nl:"
       o.organization_id, count(*)
       FROM org_plan_reltn o
       WHERE o.org_plan_reltn_cd IN (
       (SELECT
        c.code_value
        FROM code_value c
        WHERE c.code_set=307
         AND c.cdf_meaning="CARRIER"))
        AND o.health_plan_id IN (
       (SELECT
        h.health_plan_id
        FROM health_plan h
        WHERE (h.plan_name=rcu_hp->list[lpr].plan_name)
         AND (h.plan_name_key=rcu_hp->list[lpr].plan_name_key)
         AND (h.plan_type_cd=rcu_hp->list[lpr].plan_type_cd)))
       GROUP BY o.organization_id
       HAVING count(*) > 1
       DETAIL
        CALL pop_warning_rs(build("UI PLAN_NAME, PLAN_NAME_KEY and PLAN_TYPE_CD have duplicates on:",
         rcu_hp->list[lpr].plan_name,",",rcu_hp->list[lpr].plan_name_key,",",
         rcu_hp->list[lpr].plan_type_cd),rcu_warning_type,"HEALTH_PLAN")
       WITH nocounter
      ;end select
    ENDFOR
   ELSEIF (rcu_tbl="ACCOUNT")
    SELECT INTO "nl:"
     FROM user_triggers u
     WHERE u.table_name="ACCOUNT"
      AND u.trigger_name="REFCHG3155_REG_MC"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      a.acct_type_cd
      FROM account a,
       at_acct_reltn aar,
       be_at_reltn bar
      WHERE a.acct_id=aar.acct_id
       AND bar.acct_templ_id=aar.acct_templ_id
      GROUP BY a.acct_type_cd
      HAVING count(*) > 1
      DETAIL
       CALL pop_warning_rs(build("UI ACCT_TYPE_CD has duplicates on:",a.acct_type_cd),
       rcu_warning_type,"ACCOUNT")
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF (rcu_tbl="APPLICATION")
    SELECT INTO "nl:"
     a.description, count(*)
     FROM application a,
      pm_flx_conversation pfc
     WHERE a.description=pfc.description
      AND a.application_number BETWEEN 117000 AND 117999
     GROUP BY a.description
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build("UI DESCRIPTION has duplicates on:",a.description),rcu_warning_type,
      "APPLICATION")
     WITH nocounter
    ;end select
   ELSEIF (rcu_tbl="CHART_SECTION")
    SELECT INTO "nl:"
     count(*)
     FROM chart_section c
     GROUP BY c.chart_section_desc
     HAVING count(*) > 1
     DETAIL
      rcu_cs_cnt = (rcu_cs_cnt+ 1)
      IF (mod(rcu_cs_cnt,50)=1)
       stat = alterlist(rcu_cs->list,(rcu_cs_cnt+ 49))
      ENDIF
      rcu_cs->list[rcu_cs_cnt].chart_section_desc = c.chart_section_desc
     WITH nocounter
    ;end select
    FOR (lpc = 1 TO rcu_cs_cnt)
      SELECT INTO "nl:"
       FROM chart_form_sects cfs
       WHERE cfs.chart_section_id IN (
       (SELECT
        c.chart_section_id
        FROM chart_section c
        WHERE (c.chart_section_desc=rcu_cs->list[lpc].chart_section_desc)))
       GROUP BY cfs.chart_format_id, cfs.cs_sequence_num
       HAVING count(*) > 1
       DETAIL
        CALL pop_warning_rs(build("UI CHART_SECTION_DESC has duplicates on:",rcu_cs->list[lpc].
         chart_section_desc),rcu_warning_type,"CHART_SECTION")
       WITH nocounter
      ;end select
    ENDFOR
   ELSEIF (rcu_tbl="PATHWAY_CATALOG")
    SELECT INTO "nl:"
     FROM pathway_catalog p
     GROUP BY p.description, p.version, p.ref_owner_person_id
     HAVING count(*) > 1
     DETAIL
      rcu_pc_cnt = (rcu_pc_cnt+ 1)
      IF (mod(rcu_pc_cnt,50)=1)
       stat = alterlist(rcu_pc->list,(rcu_pc_cnt+ 49))
      ENDIF
      rcu_pc->list[rcu_pc_cnt].description = p.description, rcu_pc->list[rcu_pc_cnt].version = p
      .version, rcu_pc->list[rcu_pc_cnt].ref_owner_person_id = p.ref_owner_person_id
     WITH nocounter
    ;end select
    FOR (lpp = 1 TO rcu_pc_cnt)
      SELECT INTO "nl:"
       FROM pw_cat_reltn pw
       WHERE pw.type_mean="GROUP"
        AND pw.pw_cat_t_id IN (
       (SELECT
        p.pathway_catalog_id
        FROM pathway_catalog p
        WHERE (p.description=rcu_pc->list[lpp].description)
         AND (p.version=rcu_pc->list[lpp].version)
         AND (p.ref_owner_person_id=rcu_pc->list[lpp].ref_owner_person_id)))
       GROUP BY pw.pw_cat_s_id
       HAVING count(*) > 1
       DETAIL
        CALL pop_warning_rs(build(
         "UI DESCRIPTION,VERSION and REF_OWNER_PERSON_ID have duplicates on:",rcu_pc->list[lpp].
         description,",",rcu_pc->list[lpp].version,",",
         rcu_pc->list[lpp].ref_owner_person_id),rcu_warning_type,"PATHWAY_CATALOG")
       WITH nocounter
      ;end select
    ENDFOR
   ELSEIF (rcu_tbl="SA_REF_ACTION_ITEM")
    SELECT INTO "nl:"
     FROM sa_ref_action_item s
     GROUP BY s.action_item_name_key, s.child_selection_req_ind, s.value_required_ind,
      s.value_type_flag
     HAVING count(*) > 1
     DETAIL
      rcu_srai_cnt = (rcu_srai_cnt+ 1)
      IF (mod(rcu_srai_cnt,50)=1)
       stat = alterlist(rcu_srai->list,(rcu_srai_cnt+ 49))
      ENDIF
      rcu_srai->list[rcu_srai_cnt].action_item_name_key = s.action_item_name_key, rcu_srai->list[
      rcu_srai_cnt].child_selection_req_ind = s.child_selection_req_ind, rcu_srai->list[rcu_srai_cnt]
      .value_required_ind = s.value_required_ind,
      rcu_srai->list[rcu_srai_cnt].value_type_flag = s.value_type_flag
     FOOT REPORT
      stat = alterlist(rcu_srai->list,rcu_srai_cnt)
     WITH nocounter
    ;end select
    FOR (lps = 1 TO rcu_srai_cnt)
      SELECT INTO "nl:"
       FROM sa_ref_group_action_item_r sa
       WHERE sa.sa_ref_action_item_id IN (
       (SELECT
        s.sa_ref_action_item_id
        FROM sa_ref_action_item s
        WHERE (s.action_item_name_key=rcu_srai->list[lps].action_item_name_key)
         AND (s.child_selection_req_ind=rcu_srai->list[lps].child_selection_req_ind)
         AND (s.value_required_ind=rcu_srai->list[lps].value_required_ind)
         AND (s.value_type_flag=rcu_srai->list[lps].value_type_flag)))
       GROUP BY sa.sa_ref_group_id
       HAVING count(*) > 1
       DETAIL
        CALL pop_warning_rs(build(
         "UI ACTION_ITEM_NAME_KEY, CHILD_SELECTION_REQ_IND,VALUE_REQUIRED_IND, VALUE_TYPE_FLAG have duplicates on:",
         rcu_srai->list[lps].action_item_name_key,",",rcu_srai->list[lps].child_selection_req_ind,",",
         rcu_srai->list[lps].value_required_ind,",",rcu_srai->list[lps].value_type_flag),
        rcu_warning_type,"SA_REF_ACTION_ITEM")
       WITH nocounter
      ;end select
    ENDFOR
   ELSEIF (rcu_tbl="SA_REF_GROUP")
    SELECT INTO "nl:"
     s.group_prompt, s.multi_select_ind, s.selection_required_ind
     FROM sa_ref_group s
     GROUP BY s.group_prompt, s.multi_select_ind, s.selection_required_ind
     HAVING count(*) > 1
     DETAIL
      rcu_srg_cnt = (rcu_srg_cnt+ 1)
      IF (mod(rcu_srg_cnt,50)=1)
       stat = alterlist(rcu_srg->list,(rcu_srg_cnt+ 49))
      ENDIF
      rcu_srg->list[rcu_srg_cnt].group_prompt = s.group_prompt, rcu_srg->list[rcu_srg_cnt].
      multi_select_ind = s.multi_select_ind, rcu_srg->list[rcu_srg_cnt].selection_required_ind = s
      .selection_required_ind
     WITH nocounter
    ;end select
    FOR (lpr = 1 TO rcu_srg_cnt)
      SELECT INTO "nl:"
       sa.sa_ref_action_id
       FROM sa_ref_action_group_r sa
       WHERE sa.sa_ref_group_id IN (
       (SELECT
        s.sa_ref_group_id
        FROM sa_ref_group s
        WHERE (s.group_prompt=rcu_srg->list[lpr].group_prompt)
         AND (s.multi_select_ind=rcu_srg->list[lpr].multi_select_ind)
         AND (s.selection_required_ind=rcu_srg->list[lpr].selection_required_ind)))
       GROUP BY sa.sa_ref_action_id
       HAVING count(*) > 1
       DETAIL
        CALL pop_warning_rs(build(
         "UI GROUP_PROMPT, MULTI_SELECT_IND AND SELECTION_REQUIRED_IND have duplicates on:",rcu_srg->
         list[lpr].group_prompt,",",rcu_srg->list[lpr].multi_select_ind,",",
         rcu_srg->list[lpr].selection_required_ind),rcu_warning_type,"SA_REF_GROUP")
       WITH nocounter
      ;end select
    ENDFOR
   ELSEIF (rcu_tbl="V500_EVENT_CODE")
    SELECT INTO "nl:"
     FROM v500_event_code v,
      code_value cv
     WHERE cv.code_set=72
      AND cv.code_value=v.event_cd
     GROUP BY v.event_cd_disp, v.event_cd_descr, v.event_set_name
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build(
       "UI EVENT_CD_DISP, EVENT_CD_DESCR AND EVENT_SET_NAME ON CODE_SET 72 have duplicates on:",v
       .event_cd_disp,",",v.event_cd_descr,",",
       v.event_set_name),rcu_warning_type,"V500_EVENT_CODE")
     WITH nocounter
    ;end select
   ELSEIF (rcu_tbl="RESOURCE_GROUP")
    SELECT INTO "nl:"
     FROM resource_group rg,
      code_value cv
     WHERE cv.code_set=221
      AND cv.code_value=rg.child_service_resource_cd
     GROUP BY cv.display_key, rg.parent_service_resource_cd
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build(
       "UI DISPLAY_KEY and PARENT_SERVICE_RESOURCE_CD ON CODE_SET 221 have duplicates on:",cv
       .display_key,",",rg.parent_service_resource_cd),rcu_warning_type,"RESOURCE_GROUP")
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=221
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM resource_group rg
      WHERE cv.code_value=rg.child_service_resource_cd)))
     GROUP BY cv.display_key, cv.cdf_meaning
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build("UI DISPLAY_KEY and CDF_MEANING ON CODE_SET 221 have duplicates on:",
       cv.display_key,",",cv.cdf_meaning),rcu_warning_type,"RESOURCE_GROUP")
     WITH nocounter
    ;end select
   ELSEIF (rcu_tbl="IMAGE_CLASS_TYPE")
    SELECT INTO "nl:"
     FROM code_value cv,
      image_class_type ict
     WHERE cv.code_set=5503
      AND cv.code_value=ict.image_class_type_cd
     GROUP BY ict.lib_group_cd, ict.parent_image_class_type_cd, cv.display_key,
      cv.description
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build(
       "UI LIB_GROUP_CD, PARENT_IMAGE_CLASS_TYPE, DISPLAY_KEY, AND DESCRIPTION have duplicates on:",
       ict.lib_group_cd,",",ict.parent_image_class_type_cd,",",
       cv.display_key,",",cv.description),rcu_warning_type,"IMAGE_CLASS_TYPE")
     WITH nocounter
    ;end select
   ELSEIF (rcu_tbl="CODE_VALUE")
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=6020
     GROUP BY cv.definition, cv.cdf_meaning
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build("UI DEFINITION and CDF_MEANING ON CODE_SET 6020 have duplicates on:",
       cv.definition,",",cv.cdf_meaning),rcu_warning_type,"CODE_VALUE")
     WITH nocounter
    ;end select
   ELSEIF (rcu_tbl="DISCRETE_TASK_ASSAY")
    SELECT INTO "nl:"
     FROM discrete_task_assay dta,
      code_value cv
     WHERE cv.code_set=14003
      AND cv.code_value=dta.task_assay_cd
     GROUP BY dta.activity_type_cd, cv.display
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build(
       "UI ACTIVITY_TYPE_CD and DISPLAY on CODE_SET 14003 have duplicates on:",dta.activity_type_cd,
       ",",cv.display),rcu_warning_type,"DISCRETE_TASK_ASSAY")
     WITH nocounter
    ;end select
   ELSEIF (rcu_tbl="ORDER_ENTRY_FIELDS")
    SELECT INTO "nl:"
     oef.catalog_type_cd, cv.display_key
     FROM order_entry_fields oef,
      code_value cv
     WHERE cv.code_set=16449
      AND oef.oe_field_id=cv.code_value
     GROUP BY oef.catalog_type_cd, cv.display_key
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build(
       "UI CATALOG_TYPE_CD and DISPLAY_KEY on CODE_SET 16449 have duplicates on:",oef.catalog_type_cd,
       ",",cv.display_key),rcu_warning_type,"ORDER_ENTRY_FIELDS")
     WITH nocounter
    ;end select
   ELSEIF (rcu_tbl="TRACK_REFERENCE")
    SELECT INTO "nl:"
     FROM track_reference tr,
      code_value cv1,
      code_value cv2
     WHERE cv1.code_set=16589
      AND tr.assoc_code_value=cv1.code_value
      AND tr.tracking_group_cd=cv2.code_value
      AND cv2.display=cv1.definition
      AND cv2.code_set=16370
     GROUP BY cv1.description
     HAVING count(*) > 1
     DETAIL
      CALL pop_warning_rs(build("UI DESCRIPTION has duplicates on:",cv1.description),rcu_warning_type,
      "TRACK_REFERENCE")
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE pop_warning_rs(pwr_msg,pwr_warning_type,pwr_tbl)
   SET udc_warning->size_cnt = (udc_warning->size_cnt+ 1)
   IF (mod(udc_warning->size_cnt,100)=1)
    SET stat = alterlist(udc_warning->list,(udc_warning->size_cnt+ 99))
   ENDIF
   SET udc_warning->list[udc_warning->size_cnt].message = pwr_msg
   SET udc_warning->list[udc_warning->size_cnt].warning_type = pwr_warning_type
   SET udc_warning->list[udc_warning->size_cnt].table_name = pwr_tbl
 END ;Subroutine
 SUBROUTINE refchg_check_table(rct_tbl)
   DECLARE rct_exist_tbl = vc
   DECLARE rct_cnt = i4 WITH noconstant(0)
   SET rct_tbl_r = cutover_tab_name(rct_tbl,"")
   SELECT INTO "nl:"
    FROM user_tables u
    WHERE u.table_name IN (rct_tbl, rct_tbl_r)
    DETAIL
     rct_exist_tbl = u.table_name, rct_cnt = (rct_cnt+ 1),
     CALL echo(u.table_name)
    WITH nocounter
   ;end select
   IF (check_error(concat("Check table ",rct_tbl," and ",rct_tbl_r)) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (rct_cnt=1)
    IF (rct_exist_tbl=rct_tbl)
     CALL pop_warning_rs(concat("Table ",rct_tbl_r," is missing"),"MISSING TABLE",rct_tbl_r)
    ELSE
     CALL pop_warning_rs(concat("Table ",rct_tbl," is missing"),"MISSING TABLE",rct_tbl)
    ENDIF
    RETURN(1)
   ELSEIF (rct_cnt=0)
    CALL pop_warning_rs(concat("Table ",rct_tbl," is missing"),"MISSING TABLE",rct_tbl)
    CALL pop_warning_rs(concat("Table ",rct_tbl_r," is missing"),"MISSING TABLE",rct_tbl_r)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_program
 FREE RECORD udc_warning
 FREE RECORD rcu_hp
 FREE RECORD rcu_cs
 FREE RECORD rcu_pc
 FREE RECORD rcu_srai
 FREE RECORD rcu_srg
 EXECUTE dm2_set_context "FIRE_RMC_TRG", "YES"
 EXECUTE dm2_set_context "FIRE_EA_TRG", "YES"
 SET dm_err->eproc = "...Ending dm_rdds_ui_dup_checker"
 CALL final_disp_msg("dm_rdds_ui_dup_")
END GO
