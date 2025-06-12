CREATE PROGRAM dm2_readme_rollback:dba
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
 IF ( NOT (validate(rm_defined,0)))
  SET rm_defined = 1
  SET rm_error = 0
  SET rm_warning = 1
  SET rm_info = 2
  SET rm_debug = 4
  SET rm_readme = "README"
  SET rm_dbimport = "DBIMPORT"
  SET rm_ccl = "CCL"
  SET rm_oracle = "ORACLE"
  SET rm_oracle_ref = "ORACLEREF"
  SET rm_ccl_dbimport = "CCLDBIMPORT"
  SET rm_tbl_import = "TABLEIMPORT"
  SET rm_running = "RUNNING"
  SET rm_done = "SUCCESS"
  SET rm_failed = "FAILED"
  SET rm_reset = "RESET"
  SET rm_pre_schema_up = "PREUP"
  SET rm_post_schema_up = "POSTUP"
  SET rm_pre_schema_down = "PREDOWN"
  SET rm_post_schema_down = "POSTDOWN"
  SET rm_uptime = "UP"
  SET rm_temp_id = 0.0
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DM_ENV_ID"
    AND i.info_number > 0.0
   DETAIL
    rm_temp_id = i.info_number
   WITH nocounter
  ;end select
  IF ( NOT (rm_temp_id))
   CALL rm_log(rm_error,"No environment ID found on the DM_INFO table for this environment.")
  ENDIF
  SET rm_env_id = rm_temp_id
  FREE SET rm_temp_id
 ENDIF
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
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 SUBROUTINE rm_log(l_level,l_message)
   IF (size(trim(l_message,3)))
    CALL echo("********************************************************************************")
    CASE (l_level)
     OF rm_error:
      CALL echo(concat("ERROR: ",l_message))
     OF rm_warning:
      CALL echo(concat("WARNING: ",l_message))
     ELSE
      CALL echo(l_message)
    ENDCASE
    CALL echo("********************************************************************************")
    IF (l_level=rm_error)
     ROLLBACK
     GO TO 9999_exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rm_row_count(rc_table)
   SET rc_count = 0
   SET rc_date = 0.0
   SET rc_so_exists = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name="SPACE_OBJECTS"
    DETAIL
     rc_so_exists = 1
    WITH nocounter
   ;end select
   IF (rc_so_exists=1)
    SELECT INTO "nl:"
     FROM dba_synonyms s
     WHERE s.synonym_name="SPACE_OBJECTS"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET rc_so_exists = 0
    ENDIF
   ENDIF
   IF (rc_so_exists=1)
    SELECT INTO "nl:"
     o.row_count
     FROM ref_report_log l,
      ref_report_parms_log p,
      ref_instance_id i,
      space_objects o
     PLAN (l
      WHERE l.report_cd=1
       AND l.end_date IS NOT null)
      JOIN (p
      WHERE p.report_seq=l.report_seq
       AND p.parm_cd=1)
      JOIN (i
      WHERE i.environment_id=rm_env_id
       AND cnvtstring(i.instance_cd)=p.parm_value)
      JOIN (o
      WHERE o.segment_name=rc_table
       AND o.report_seq=l.report_seq)
     ORDER BY l.begin_date
     DETAIL
      rc_count = o.row_count, rc_date = cnvtdatetime(l.end_date)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables t
    WHERE t.table_name=rc_table
    DETAIL
     IF (cnvtdatetime(t.last_analyzed) > rc_date)
      rc_count = t.num_rows
     ENDIF
    WITH nocounter
   ;end select
   RETURN(rc_count)
 END ;Subroutine
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
 IF ( NOT (validate(rb_data,0)))
  FREE SET rb_data
  RECORD rb_data(
    1 in_house = i2
    1 batch_dt_tm = dq8
    1 env_id = f8
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
    1 readme[*]
      2 id = i4
      2 instance = i4
      2 name = vc
      2 description = vc
      2 ocd = i4
      2 driver_table = vc
      2 driver_count = i4
      2 estimated_time = f8
      2 skip = i2
      2 execution = vc
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 IF (validate(dm2_rr_misc->dm2_toolset_usage," ")=" "
  AND validate(dm2_rr_misc->dm2_toolset_usage,"1")="1")
  FREE RECORD dm2_rr_misc
  RECORD dm2_rr_misc(
    1 dm2_toolset_usage = vc
    1 readme_errors_ind = i2
    1 env_id = f8
    1 batch_dt_tm = dq8
    1 process_type = c2
    1 package_number = i4
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
  )
  SET dm2_rr_misc->dm2_toolset_usage = "NOT_SET"
  SET dm2_rr_misc->readme_errors_ind = 0
  SET dm2_rr_misc->env_id = 0.0
  SET dm2_rr_misc->batch_dt_tm = cnvtdatetimeutc("01-JAN-1800")
  SET dm2_rr_misc->process_type = ""
  SET dm2_rr_misc->package_number = 0
  SET dm2_rr_misc->execution = "NOT_SET"
  SET dm2_rr_misc->low_proj_name = ""
  SET dm2_rr_misc->high_proj_name = ""
 ENDIF
 IF ((validate(dm2_rr_spcchk->readme_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spcchk->readme_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spcchk
  RECORD dm2_rr_spcchk(
    1 space_needed = i2
    1 preup_space_needed = i2
    1 readme_cnt = i4
    1 readme_list[*]
      2 readme_id = f8
      2 spcchk_readme_id = f8
      2 script = vc
      2 tbl_cnt = i4
      2 tbl_list[*]
        3 table_name = vc
        3 large_data_loaded = i2
        3 insert_row_cnt = f8
        3 col_updt_cnt = i4
        3 col_updt[*]
          4 update_row_cnt = f8
          4 column_name = vc
  )
  SET dm2_rr_spcchk->readme_cnt = 0
  SET dm2_rr_spcchk->preup_space_needed = 0
  SET dm2_rr_spcchk->space_needed = 0
 ENDIF
 IF ((validate(dm2_rr_spc_needs->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spc_needs->tbl_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spc_needs
  RECORD dm2_rr_spc_needs(
    1 space_needed = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 skip_ind = i2
      2 large_data_loaded = i2
      2 insert_row_cnt = f8
      2 col_updt_cnt = i4
      2 col_updt[*]
        3 update_row_cnt = f8
        3 column_name = vc
      2 tgt_idx = i4
      2 cur_idx = i4
      2 space_needed = f8
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 tgt_idx = i4
        3 cur_idx = i4
        3 space_needed = f8
  )
  SET dm2_rr_spc_needs->tbl_cnt = 0
 ENDIF
 IF (validate(drr_readmes_to_run->readme_cnt,0)=0
  AND validate(drr_readmes_to_run->readme_cnt,1)=1)
  FREE RECORD drr_readmes_to_run
  RECORD drr_readmes_to_run(
    1 readme_cnt = i4
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 name = vc
      2 description = c50
      2 ocd = i4
      2 execution = vc
      2 execution_order = vc
      2 category = vc
      2 driver_table = vc
      2 execution_time = f8
      2 status = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 skip = i2
      2 driver_count = i4
      2 estimated_time = f8
      2 spchk_readme_cnt = i4
      2 spchk_readme[*]
        3 readme_id = f8
        3 instance = i4
        3 ocd = i4
        3 execution = vc
        3 script = vc
        3 skip = i2
    1 timer_readme_cnt = i4
    1 timer_readme[*]
      2 parent_readme_id = f8
      2 readme_id = f8
      2 instance = i4
      2 ocd = i4
      2 execution = vc
      2 script = vc
      2 skip = i2
    1 inactive_cnt = i4
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ((validate(dm2_rr_defined,- (1))=- (1))
  AND (validate(dm2_rr_defined,- (2))=- (2)))
  DECLARE dm2_rr_defined = i2 WITH public, constant(1)
  DECLARE dm2_rr_error = i2 WITH public, constant(0)
  DECLARE dm2_rr_warning = i2 WITH public, constant(1)
  DECLARE dm2_rr_info = i2 WITH public, constant(2)
  DECLARE dm2_rr_readme = vc WITH public, constant("README")
  DECLARE dm2_rr_dbimport = vc WITH public, constant("DBIMPORT")
  DECLARE dm2_rr_oracle = vc WITH public, constant("ORACLE")
  DECLARE dm2_rr_oracle_ref = vc WITH public, constant("ORACLEREF")
  DECLARE dm2_rr_ccl_dbimport = vc WITH public, constant("CCLDBIMPORT")
  DECLARE dm2_rr_tbl_import = vc WITH public, constant("TABLEIMPORT")
  DECLARE dm2_rr_readme_rback = vc WITH public, constant("README:RBACK")
  DECLARE dm2_rr_running = vc WITH public, constant("RUNNING")
  DECLARE dm2_rr_done = vc WITH public, constant("SUCCESS")
  DECLARE dm2_rr_failed = vc WITH public, constant("FAILED")
  DECLARE dm2_rr_reset = vc WITH public, constant("RESET")
  DECLARE dm2_rr_pre_schema_up = vc WITH public, constant("PREUP")
  DECLARE dm2_rr_post_schema_up = vc WITH public, constant("POSTUP")
  DECLARE dm2_rr_post_schema_up2 = vc WITH public, constant("POSTUP2")
  DECLARE dm2_rr_pre_cycle = vc WITH public, constant("PRECYCLE")
  DECLARE dm2_rr_pre_schema_down = vc WITH public, constant("PREDOWN")
  DECLARE dm2_rr_post_schema_down = vc WITH public, constant("POSTDOWN")
  DECLARE dm2_rr_uptime = vc WITH public, constant("UP")
  DECLARE dm2_rr_timer = vc WITH public, constant("RDMTIMER")
 ENDIF
 IF (validate(drr_killed_appl->appl_cnt,1)=1
  AND validate(drr_killed_appl->appl_cnt,2)=2)
  FREE RECORD drr_killed_appl
  RECORD drr_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET drr_killed_appl->appl_cnt = 0
 ENDIF
 DECLARE dm2_rr_toolset_usage(null) = i2
 DECLARE dm2_rr_clean_stranded_readmes(drcsr_env_id=f8) = i2
 DECLARE drr_load_readmes_to_run(null) = i2
 DECLARE drr_load_space_chk_readmes(dlscr_execution=vc,dlscr_spcchk_flag=i2(ref)) = i2
 DECLARE drr_load_timing_readmes(null) = i2
 DECLARE drr_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 SUBROUTINE dm2_rr_toolset_usage(null)
   DECLARE drtu_found_ind = i2 WITH protect, noconstant(0)
   IF ((dm2_rr_misc->dm2_toolset_usage != "NOT_SET"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   IF (dm2_table_and_ccldef_exists("DM_INFO",drtu_found_ind)=0)
    RETURN(0)
   ENDIF
   IF (drtu_found_ind=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for DM_README_TOOLSET row."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_README_TOOLSET"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm2_rr_misc->dm2_toolset_usage = "N"
   ELSEIF (curqual=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rr_clean_stranded_readmes(drcsr_env_id)
   DECLARE rcsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE rcsr_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE rcsr_error_msg = vc WITH protect, noconstant(" ")
   DECLARE rcsr_load_ind = i2 WITH protect, noconstant(1)
   DECLARE rcsr_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD rcsr_appl_rs
   RECORD rcsr_appl_rs(
     1 rcsr_appl_cnt = i4
     1 rcsr_appl[*]
       2 rcsr_appl_id = vc
       2 rcsr_validity = vc
   )
   SET dm_err->eproc = "Get distinct application ids."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    l.appl_ident
    FROM dm_ocd_log l
    WHERE l.environment_id=drcsr_env_id
     AND l.project_type=dm2_rr_readme
     AND ((l.status=dm2_rr_running) OR (l.status=null))
    HEAD REPORT
     rcsr_cnt = 0
    DETAIL
     rcsr_cnt = (rcsr_cnt+ 1)
     IF (mod(rcsr_cnt,10)=1)
      stat = alterlist(rcsr_appl_rs->rcsr_appl,(rcsr_cnt+ 9))
     ENDIF
     IF (isnumeric(l.appl_ident)=0)
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "INVALID"
     ELSE
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "VALID"
     ENDIF
     rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id = l.appl_ident
    FOOT REPORT
     rcsr_appl_rs->rcsr_appl_cnt = rcsr_cnt, stat = alterlist(rcsr_appl_rs->rcsr_appl,rcsr_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((rcsr_appl_rs->rcsr_appl_cnt > 0))
    SET rcsr_cnt = 0
    FOR (rcsr_cnt = 1 TO rcsr_appl_rs->rcsr_appl_cnt)
      IF ((rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity="INVALID"))
       SET rcsr_error_msg = "Session executing readme is no longer active"
       SET dm_err->eproc = "Update stranded readme process to failed."
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_ocd_log l
        SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(l
           .start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
        WHERE l.environment_id=drcsr_env_id
         AND l.project_type=dm2_rr_readme
         AND ((l.status=dm2_rr_running) OR (l.status = null))
         AND ((l.appl_ident = null) OR ((l.appl_ident=rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
        ))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       CASE (dm2_get_appl_status(value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)))
        OF "I":
         SET dm_err->eproc = "Update inactive readme process to failed."
         SET rcsr_fmt_appl_id = rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id
         IF (drr_alert_killed_appl(rcsr_load_ind,rcsr_fmt_appl_id,rcsr_kill_ind)=0)
          RETURN(0)
         ENDIF
         SET rcsr_load_ind = 0
         IF (rcsr_kill_ind=1)
          SET rcsr_error_msg = dir_kill_clause
         ELSE
          SET rcsr_error_msg = "Session executing readme is no longer active."
         ENDIF
         IF ((dm_err->debug_flag > 0))
          CALL disp_msg(" ",dm_err->logfile,0)
         ENDIF
         UPDATE  FROM dm_ocd_log l
          SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(
             l.start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
          WHERE l.environment_id=drcsr_env_id
           AND l.appl_ident=value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
           AND l.project_type=dm2_rr_readme
           AND ((l.status=dm2_rr_running) OR (l.status = null))
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          RETURN(0)
         ELSE
          COMMIT
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Application Id ",rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 0))
          CALL echo("Error Detected in dm2_get_appl_status")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No application IDs associated with stranded readmes **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_readmes_to_run(null)
   DECLARE dlrr_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD drr_readmes_on_pkg
   RECORD drr_readmes_on_pkg(
     1 cnt = i4
     1 qual[*]
       2 readme_id = f8
       2 instance = i4
       2 ocd = f8
       2 skip = i2
       2 run_once_ind = i2
       2 name = vc
       2 description = c50
       2 execution = vc
       2 category = vc
       2 driver_table = vc
       2 execution_time = f8
       2 skip = i2
       2 driver_count = i4
       2 estimated_time = f8
   )
   IF ((drr_readmes_to_run->readme_cnt > 0))
    SET drr_readmes_to_run->readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->readme,0)
   ENDIF
   IF ((drr_readmes_to_run->inactive_cnt > 0))
    SET drr_readmes_to_run->inactive_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->inactive,0)
   ENDIF
   IF ( NOT ((dm2_rr_misc->process_type IN ("PI", "IH", "MM"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->env_id=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment ID."
    SET dm_err->emsg = "Invalid environment_id."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->process_type="PI"))
    IF ((dm2_rr_misc->package_number=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating package number."
     SET dm_err->emsg =
     "Package number or batch number was 0.  Cannot process readmes for package install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF ( NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
    "PREDOWN", "POSTDOWN", "UP"))))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating process type."
     SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="IH")
    AND ((cnvtint(dm2_rr_misc->low_proj_name) < 0) OR (cnvtint(dm2_rr_misc->high_proj_name) <= 0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating inhouse project range."
    SET dm_err->emsg = "Invalid project range.  Cannot process inhouse readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF ((dm2_rr_misc->process_type="MM")
    AND  NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "PREDOWN", "POSTDOWN",
   "UP"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET rdm_cnt = 0
   SET inactive_cnt = 0
   IF ((dm2_rr_misc->process_type="PI"))
    SET dm_err->eproc = "Gathering list of readmes on plan..."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_readme o
     WHERE (o.ocd=dm2_rr_misc->package_number)
     ORDER BY o.readme_id
     DETAIL
      rdm_cnt = (rdm_cnt+ 1)
      IF (mod(rdm_cnt,100)=1)
       stat = alterlist(drr_readmes_on_pkg->qual,(rdm_cnt+ 99))
      ENDIF
      drr_readmes_on_pkg->qual[rdm_cnt].readme_id = o.readme_id, drr_readmes_on_pkg->qual[rdm_cnt].
      name = trim(cnvtstring(o.readme_id),3), drr_readmes_on_pkg->qual[rdm_cnt].ocd = o.ocd,
      drr_readmes_on_pkg->qual[rdm_cnt].instance = o.instance
     FOOT REPORT
      stat = alterlist(drr_readmes_on_pkg->qual,rdm_cnt), drr_readmes_on_pkg->cnt = rdm_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((drr_readmes_on_pkg->cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (r
      WHERE r.owner=currdbuser
       AND (r.readme_id=drr_readmes_on_pkg->qual[d.seq].readme_id)
       AND (r.instance > drr_readmes_on_pkg->qual[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id)
       AND  NOT (a.inst_mode IN ("PREVIEW", "BATCHPREVIEW")))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       CALL echo(concat("Instance ",build(r.instance)," from ",build(o.ocd)," for readme ",
        build(o.readme_id)," will be skipped due to being inactive on highest instance.")),
       drr_readmes_on_pkg->qual[d.seq].skip = 1
      ELSE
       CALL echo(concat("Replacing Instance ",build(drr_readmes_on_pkg->qual[d.seq].instance),
        " with instance ",build(r.instance)," from ",
        build(o.ocd)," for readme ",build(o.readme_id))), drr_readmes_on_pkg->qual[d.seq].instance =
       r.instance, drr_readmes_on_pkg->qual[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Marking completed readmes as SKIPPED."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND (l.ocd=drr_readmes_on_pkg->qual[d.seq].ocd)
       AND l.status=dm2_rr_done
       AND l.active_ind=1)
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Loading readme metadata."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_readme r,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0))
      JOIN (r
      WHERE (drr_readmes_on_pkg->qual[d.seq].readme_id=r.readme_id)
       AND (drr_readmes_on_pkg->qual[d.seq].instance=r.instance)
       AND r.owner=currdbuser)
     ORDER BY r.readme_id
     HEAD r.readme_id
      drr_readmes_on_pkg->qual[d.seq].readme_id = r.readme_id, drr_readmes_on_pkg->qual[d.seq].
      instance = r.instance, drr_readmes_on_pkg->qual[d.seq].name = trim(cnvtstring(r.readme_id),3),
      drr_readmes_on_pkg->qual[d.seq].execution = cnvtupper(trim(r.execution,3)), drr_readmes_on_pkg
      ->qual[d.seq].description = r.description, drr_readmes_on_pkg->qual[d.seq].driver_table =
      cnvtupper(trim(r.driver_table,3)),
      drr_readmes_on_pkg->qual[d.seq].execution_time = r.execution_time, drr_readmes_on_pkg->qual[d
      .seq].run_once_ind = r.run_once_ind, drr_readmes_on_pkg->qual[d.seq].estimated_time = 0,
      drr_readmes_on_pkg->qual[d.seq].driver_count = 0, drr_readmes_on_pkg->qual[d.seq].skip =
      evaluate(r.active_ind,0,1,0)
      IF ((drr_readmes_on_pkg->qual[d.seq].skip=1))
       CALL echo(concat("Skipping inactive readme ",build(r.readme_id)," instance ",build(r.instance)
        ))
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Skipping RUN ONCE Readmes"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0)
       AND (drr_readmes_on_pkg->qual[d.seq].run_once_ind=1))
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND l.status=dm2_rr_done
       AND l.active_ind=1
       AND (l.project_instance=drr_readmes_on_pkg->qual[d.seq].instance))
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_on_pkg)
    ENDIF
    SET rdm_cnt = 0
    FOR (dlrr_cnt = 1 TO drr_readmes_on_pkg->cnt)
      IF ((((dm2_rr_misc->execution != "ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution=dm2_rr_misc->execution)) OR ((dm2_rr_misc->
      execution="ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution IN ("PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
      "PREDOWN",
      "POSTDOWN", "UP")))) )
       IF ((drr_readmes_on_pkg->qual[dlrr_cnt].skip=1)
        AND (drr_readmes_on_pkg->qual[dlrr_cnt].run_once_ind=1))
        CALL echo(concat("Skip run once readme:",drr_readmes_on_pkg->qual[dlrr_cnt].name))
       ELSE
        SET rdm_cnt = (rdm_cnt+ 1)
        SET stat = alterlist(drr_readmes_to_run->readme,rdm_cnt)
        SET drr_readmes_to_run->readme[rdm_cnt].readme_id = drr_readmes_on_pkg->qual[dlrr_cnt].
        readme_id
        SET drr_readmes_to_run->readme[rdm_cnt].instance = drr_readmes_on_pkg->qual[dlrr_cnt].
        instance
        SET drr_readmes_to_run->readme[rdm_cnt].name = drr_readmes_on_pkg->qual[dlrr_cnt].name
        SET drr_readmes_to_run->readme[rdm_cnt].execution = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution
        SET drr_readmes_to_run->readme[rdm_cnt].description = drr_readmes_on_pkg->qual[dlrr_cnt].
        description
        SET drr_readmes_to_run->readme[rdm_cnt].ocd = drr_readmes_on_pkg->qual[dlrr_cnt].ocd
        SET drr_readmes_to_run->readme[rdm_cnt].driver_table = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_table
        SET drr_readmes_to_run->readme[rdm_cnt].execution_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution_time
        SET drr_readmes_to_run->readme[rdm_cnt].estimated_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        estimated_time
        SET drr_readmes_to_run->readme[rdm_cnt].driver_count = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_count
        SET drr_readmes_to_run->readme[rdm_cnt].skip = drr_readmes_on_pkg->qual[dlrr_cnt].skip
        SET drr_readmes_to_run->readme_cnt = rdm_cnt
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_to_run)
    ENDIF
    IF ((drr_readmes_to_run->readme_cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET rdm_cnt = 0
    FOR (rdm_cnt = 1 TO drr_readmes_to_run->readme_cnt)
      IF ((drr_readmes_to_run->readme[rdm_cnt].skip=0))
       CALL echo(concat("Readme ",build(drr_readmes_to_run->readme[rdm_cnt].readme_id)," will run."))
      ENDIF
    ENDFOR
   ELSEIF ((dm2_rr_misc->process_type="IH"))
    SET dm_err->eproc = "Getting list of readmes for inhouse processing."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     r.readme_id
     FROM dm_project_status_env s,
      dm_readme r
     PLAN (s
      WHERE (s.environment_id=dm2_rr_misc->env_id)
       AND s.proj_type=dm2_rr_readme
       AND cnvtint(s.proj_name) > 0
       AND s.proj_name BETWEEN dm2_rr_misc->low_proj_name AND dm2_rr_misc->high_proj_name
       AND s.dm_status = null)
      JOIN (r
      WHERE r.readme_id=cnvtint(s.proj_name)
       AND r.instance=s.source_set_instance
       AND r.owner=currdbuser)
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind)
       rdm_cnt = (rdm_cnt+ 1)
       IF (mod(rdm_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
       ENDIF
       drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
       rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
         .readme_id),3),
       drr_readmes_to_run->readme[rdm_cnt].execution = cnvtupper(trim(r.execution,3)),
       drr_readmes_to_run->readme[rdm_cnt].description = trim(r.description,3), drr_readmes_to_run->
       readme[rdm_cnt].driver_table = cnvtupper(trim(r.driver_table,3)),
       drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
       readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       IF ((drr_readmes_to_run->readme[rdm_cnt].execution IN ("PRESPCHK", "POSTSPCHK", "RDMTIMER")))
        drr_readmes_to_run->readme[rdm_cnt].skip = 1
       ENDIF
      ELSE
       inactive_cnt = (inactive_cnt+ 1)
       IF (mod(inactive_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->inactive,(inactive_cnt+ 9))
       ENDIF
       drr_readmes_to_run->inactive[inactive_cnt].name = trim(cnvtstring(r.readme_id),3),
       drr_readmes_to_run->inactive[inactive_cnt].instance = r.instance
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_readmes_to_run->inactive,inactive_cnt), stat = alterlist(
       drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt,
      drr_readmes_to_run->inactive_cnt = inactive_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="MM"))
    SET dm_err->eproc = "Gathering list of readmes to run..."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (validate(doc->source_ocd_cnt,- (1)) > 0)
     SELECT INTO "nl:"
      FROM dm_ocd_readme o,
       dm_readme r,
       (dummyt d  WITH seq = value(doc->source_ocd_cnt))
      PLAN (d)
       JOIN (o
       WHERE (o.ocd=doc->qual[d.seq].ocd_nbr))
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        l.project_name
        FROM dm_ocd_log l,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (l.environment_id=dm2_rr_misc->env_id)
         AND l.project_type=dm2_rr_readme
         AND l.ocd > 0
         AND l.project_name=trim(cnvtstring(x.readme_id),3)
         AND l.project_instance >= r.instance
         AND l.status=dm2_rr_done
         AND l.active_ind=1))))
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD REPORT
       row + 0
      HEAD r.readme_id
       IF (r.active_ind=1
        AND (r.execution=dm2_rr_misc->execution))
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
          .readme_id),3),
        drr_readmes_to_run->readme[rdm_cnt].description = r.description, drr_readmes_to_run->readme[
        rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].driver_table = cnvtupper(trim(r
          .driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Marking completed readmes as SKIPPED."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      l.status
      FROM dm_ocd_log l,
       (dummyt d  WITH seq = value(rdm_cnt))
      PLAN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND (l.project_name=drr_readmes_to_run->readme[d.seq].name)
        AND (l.ocd=drr_readmes_to_run->readme[d.seq].ocd)
        AND l.status=dm2_rr_done
        AND l.active_ind=1)
      DETAIL
       drr_readmes_to_run->readme[d.seq].skip = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      status = decode(l.seq,l.status,"NOT RUN"), start_dt_tm = decode(l.seq,l.start_dt_tm,
       cnvtdatetime(curdate,curtime)), end_dt_tm = decode(l.seq,l.end_dt_tm,cnvtdatetime(curdate,
        curtime))
      FROM dm_alpha_features_env a,
       dm_ocd_readme o,
       dm_readme r,
       dm_ocd_log l,
       dummyt d
      PLAN (a
       WHERE (a.environment_id=dm2_rr_misc->env_id)
        AND a.curr_migration_ind=1)
       JOIN (o
       WHERE o.ocd=a.alpha_feature_nbr)
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        m.project_name
        FROM dm_ocd_log m,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (m.environment_id=dm2_rr_misc->env_id)
         AND m.project_type=dm2_rr_readme
         AND m.project_name=trim(cnvtstring(x.readme_id),3)
         AND m.status=dm2_rr_done
         AND m.ocd != o.ocd))))
       JOIN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND trim(cnvtstring(r.readme_id),3)=l.project_name
        AND l.ocd=o.ocd
        AND l.project_instance=r.instance)
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD r.readme_id
       IF (r.active_ind=1)
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].description = trim(r
         .description),
        drr_readmes_to_run->readme[rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].
        execution = cnvtupper(trim(r.execution,3)), drr_readmes_to_run->readme[rdm_cnt].driver_table
         = cnvtupper(trim(r.driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].status = status, drr_readmes_to_run->readme[rdm_cnt].start_dt_tm =
        start_dt_tm,
        drr_readmes_to_run->readme[rdm_cnt].end_dt_tm = end_dt_tm, drr_readmes_to_run->readme[rdm_cnt
        ].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter, outerjoin = d
     ;end select
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_space_chk_readmes(dlscr_execution,dlscr_spcchk_flag)
   DECLARE dlscr_dyn_where = vc WITH protect, noconstant("")
   IF (dlscr_execution="ALL")
    SET dlscr_dyn_where = "r.execution in ('PRESPCHK', 'POSTSPCHK')"
   ELSE
    SET dlscr_dyn_where = concat('r.execution = "',trim(dlscr_execution),'"')
   ENDIF
   SET dm_err->eproc = "Find readmes that require space check."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_readme r,
     dm_ocd_readme o,
     dm_alpha_features_env a,
     (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    PLAN (d
     WHERE (drr_readmes_to_run->readme[d.seq].skip=0))
     JOIN (r
     WHERE (r.parent_readme_id=drr_readmes_to_run->readme[d.seq].readme_id)
      AND parser(dlscr_dyn_where)
      AND r.owner=currdbuser)
     JOIN (o
     WHERE o.readme_id=r.readme_id
      AND o.ocd > 0
      AND o.instance=r.instance)
     JOIN (a
     WHERE a.alpha_feature_nbr=o.ocd
      AND (a.environment_id=dm2_rr_misc->env_id))
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD r.readme_id
     IF (r.active_ind=1)
      dlscr_spcchk_flag = 1, drr_readmes_to_run->readme[d.seq].spchk_readme_cnt = (drr_readmes_to_run
      ->readme[d.seq].spchk_readme_cnt+ 1), stat = alterlist(drr_readmes_to_run->readme[d.seq].
       spchk_readme,drr_readmes_to_run->readme[d.seq].spchk_readme_cnt),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].instance = r.instance, drr_readmes_to_run->
      readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].ocd = o.ocd,
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].execution = r.execution, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].script = cnvtupper(r.script),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].skip = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_timing_readmes(null)
   SET dm_err->eproc = "Gathering timing readme data"
   CALL disp_msg("",dm_err->logfile,0)
   SET timer_cnt = 0
   IF ((drr_readmes_to_run->timer_readme_cnt > 0))
    SET drr_readmes_to_run->timer_readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->timer_readme,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_readme o,
     dm_readme r
    PLAN (o
     WHERE (o.ocd=dm2_rr_misc->package_number))
     JOIN (r
     WHERE r.owner=currdbuser
      AND r.readme_id=o.readme_id
      AND r.instance=o.instance
      AND r.execution="RDMTIMER")
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD REPORT
     row + 0
    HEAD r.readme_id
     IF (r.active_ind=1)
      timer_cnt = (timer_cnt+ 1)
      IF (mod(timer_cnt,10)=1)
       stat = alterlist(drr_readmes_to_run->timer_readme,(timer_cnt+ 9))
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].readme_id = r.readme_id
      IF (r.parent_readme_id > 0)
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = r.parent_readme_id
      ELSE
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = 0
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].instance = r.instance, drr_readmes_to_run->
      timer_readme[timer_cnt].ocd = o.ocd, drr_readmes_to_run->timer_readme[timer_cnt].execution = r
      .execution,
      drr_readmes_to_run->timer_readme[timer_cnt].script = cnvtupper(r.script), drr_readmes_to_run->
      timer_readme[timer_cnt].skip = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_readmes_to_run->timer_readme,timer_cnt), drr_readmes_to_run->
     timer_readme_cnt = timer_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Find highest instance of timing readmes"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((drr_readmes_to_run->timer_readme_cnt=0))
    SET dm_err->eproc = "No Category 8 readmes found to run."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ELSE
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt))
     PLAN (d)
      JOIN (r
      WHERE (r.readme_id=drr_readmes_to_run->timer_readme[d.seq].readme_id)
       AND (r.instance > drr_readmes_to_run->timer_readme[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       drr_readmes_to_run->timer_readme[d.seq].skip = 1
      ELSE
       drr_readmes_to_run->timer_readme[d.seq].instance = r.instance, drr_readmes_to_run->
       timer_readme[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Update skip flag on timing readmes"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt)),
      (dummyt d2  WITH seq = value(drr_readmes_to_run->readme_cnt))
     PLAN (d
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id > 0))
      JOIN (d2
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id=drr_readmes_to_run->readme[d2
      .seq].readme_id))
     DETAIL
      drr_readmes_to_run->timer_readme[d.seq].skip = drr_readmes_to_run->readme[d2.seq].skip
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
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
      drr_killed_appl->appl_cnt = 0
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
       drr_killed_appl->appl_cnt += 1
       IF (mod(drr_killed_appl->appl_cnt,10)=1)
        stat = alterlist(drr_killed_appl->appl,(drr_killed_appl->appl_cnt+ 9))
       ENDIF
       drr_killed_appl->appl[drr_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_killed_appl->appl,drr_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,drr_killed_appl->appl_cnt,daka_fmt_appl_id,
     drr_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD drr_readme
 RECORD drr_readme(
   1 qual[*]
     2 ocd = i4
     2 readme_id = i4
     2 readme_inst = i2
   1 cnt = i4
 )
 DECLARE drr_rollback_criteria = vc WITH protect, noconstant("NONE")
 DECLARE drr_dminfo_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE drr_ocd = i4 WITH protect, noconstant(0)
 DECLARE drr_mode = vc WITH protect, noconstant(" ")
 DECLARE drr_batch = i2 WITH protect, noconstant(0)
 DECLARE drr_env_id = f8 WITH protect, noconstant(0.0)
 IF (check_logfile("DM2_README_ROLLBACK",".log","DM2_README_ROLLBACK log file")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Begin DM2_README_ROLLBACK"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET drr_ocd = cnvtint( $1)
 SET drr_mode = cnvtupper( $2)
 SET reply->status_data.status = "F"
 IF (drr_ocd <= 0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Package Number or Install Plan ID must be positive number."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ( NOT (drr_mode IN ("UPTIME", "DOWNTIME", "POSTINST", "BATCHUP", "BATCHDOWN",
 "BATCHPOST", "EXPRESS", "BATCHEXPRESS", "BATCHPRECYCLE")))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(drr_mode," is invalid parameter.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET drr_rollback_criteria =
 " dr.readme_category in ('LOAD','CONVERSION','MIGRATION','SQL','OTHER','MIGRATION_2')"
 SELECT INTO "nl:"
  d.info_char
  FROM dm_info d
  WHERE d.info_domain="DM2_README_ROLLBACK"
   AND d.info_name="DR ROLLBACK CRITERIA"
  DETAIL
   drr_rollback_criteria = d.info_char
  WITH nocounter
 ;end select
 IF (check_error("Getting readme rollback criteria override from DM_INFO.")=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (findstring("BATCH",drr_mode) > 0)
  SET drr_batch = 1
  SET dm_err->eproc = concat("Verifying Install Plan ID ",trim(cnvtstring(drr_ocd)),
   " exists on DM_INSTALL_PLAN.")
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dm_install_plan
   WHERE install_plan_id=drr_ocd
   WITH nocounter
  ;end select
  IF (check_error("Error checking install_plan_id on DM_INSTALL_PLAN table.")=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
  IF ( NOT (curqual))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat("Install Plan ID not found on DM_INSTALL_PLAN.")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = concat("Verifying Install Plan ID ",trim(cnvtstring(drr_ocd)),
   " exists on DM_OCD_README.")
  CALL disp_msg(" ",dm_err->logfile,0)
  SET drr_ocd = (- (1) * drr_ocd)
 ENDIF
 SET dm_err->eproc = "Getting environment ID."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="DM_ENV_ID"
  DETAIL
   drr_env_id = di.info_number
  WITH nocounter
 ;end select
 IF (check_error("Error getting the environment ID from DM_INFO.")=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF ( NOT (curqual))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "No environment ID found."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = concat("Getting readme info for package ",trim(cnvtstring(abs(drr_ocd)))," .")
 CALL disp_msg("",dm_err->logfile,0)
 SELECT
  IF (drr_mode IN ("UPTIME", "BATCHUP"))
   PLAN (dol
    WHERE dol.environment_id=drr_env_id
     AND dol.project_type="README"
     AND dol.ocd=drr_ocd)
    JOIN (dr
    WHERE cnvtint(dol.project_name)=dr.readme_id
     AND dol.project_instance=dr.instance
     AND dr.execution IN ("PREUP", "POSTUP", "POSTUP2")
     AND parser(drr_rollback_criteria))
  ELSEIF (drr_mode="BATCHPRECYCLE")
   PLAN (dol
    WHERE dol.environment_id=drr_env_id
     AND dol.project_type="README"
     AND dol.ocd=drr_ocd)
    JOIN (dr
    WHERE cnvtint(dol.project_name)=dr.readme_id
     AND dol.project_instance=dr.instance
     AND dr.execution IN ("PRECYCLE")
     AND parser(drr_rollback_criteria))
  ELSEIF (drr_mode IN ("DOWNTIME", "BATCHDOWN"))
   PLAN (dol
    WHERE dol.environment_id=drr_env_id
     AND dol.project_type="README"
     AND dol.ocd=drr_ocd)
    JOIN (dr
    WHERE cnvtint(dol.project_name)=dr.readme_id
     AND dol.project_instance=dr.instance
     AND dr.execution IN ("PREDOWN", "POSTDOWN", "PRECYCLE")
     AND parser(drr_rollback_criteria))
  ELSEIF (drr_mode IN ("POSTINST", "BATCHPOST"))
   PLAN (dol
    WHERE dol.environment_id=drr_env_id
     AND dol.project_type="README"
     AND dol.ocd=drr_ocd)
    JOIN (dr
    WHERE cnvtint(dol.project_name)=dr.readme_id
     AND dol.project_instance=dr.instance
     AND dr.execution="UP"
     AND parser(drr_rollback_criteria))
  ELSEIF (drr_mode IN ("EXPRESS", "BATCHEXPRESS"))
   PLAN (dol
    WHERE dol.environment_id=drr_env_id
     AND dol.project_type="README"
     AND dol.ocd=drr_ocd)
    JOIN (dr
    WHERE cnvtint(dol.project_name)=dr.readme_id
     AND dol.project_instance=dr.instance
     AND parser(drr_rollback_criteria))
  ELSE
  ENDIF
  INTO "nl:"
  FROM dm_ocd_log dol,
   dm_readme dr
  DETAIL
   drr_readme->cnt = (drr_readme->cnt+ 1), stat = alterlist(drr_readme->qual,drr_readme->cnt),
   drr_readme->qual[drr_readme->cnt].ocd = dol.ocd,
   drr_readme->qual[drr_readme->cnt].readme_id = dr.readme_id, drr_readme->qual[drr_readme->cnt].
   readme_inst = dr.instance
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (drr_batch=1)
  SELECT
   IF (drr_mode="BATCHUP")
    PLAN (dip
     WHERE (dip.install_plan_id=(- (1) * drr_ocd)))
     JOIN (dol
     WHERE dol.environment_id=drr_env_id
      AND dol.project_type="README"
      AND dol.ocd=dip.package_number)
     JOIN (dor
     WHERE dor.ocd=drr_ocd
      AND cnvtint(dol.project_name)=dor.readme_id
      AND dol.project_instance=dor.instance)
     JOIN (dr
     WHERE dor.readme_id=dr.readme_id
      AND dor.instance=dr.instance
      AND dr.execution IN ("PREUP", "POSTUP", "POSTUP2")
      AND parser(drr_rollback_criteria))
   ELSEIF (drr_mode="BATCHPRECYCLE")
    PLAN (dip
     WHERE (dip.install_plan_id=(- (1) * drr_ocd)))
     JOIN (dol
     WHERE dol.environment_id=drr_env_id
      AND dol.project_type="README"
      AND dol.ocd=dip.package_number)
     JOIN (dor
     WHERE dor.ocd=drr_ocd
      AND cnvtint(dol.project_name)=dor.readme_id
      AND dol.project_instance=dor.instance)
     JOIN (dr
     WHERE dor.readme_id=dr.readme_id
      AND dor.instance=dr.instance
      AND dr.execution IN ("PRECYCLE")
      AND parser(drr_rollback_criteria))
   ELSEIF (drr_mode="BATCHDOWN")
    PLAN (dip
     WHERE (dip.install_plan_id=(- (1) * drr_ocd)))
     JOIN (dol
     WHERE dol.environment_id=drr_env_id
      AND dol.project_type="README"
      AND dol.ocd=dip.package_number)
     JOIN (dor
     WHERE dor.ocd=drr_ocd
      AND cnvtint(dol.project_name)=dor.readme_id
      AND dol.project_instance=dor.instance)
     JOIN (dr
     WHERE dor.readme_id=dr.readme_id
      AND dor.instance=dr.instance
      AND dr.execution IN ("PREDOWN", "POSTDOWN", "PRECYCLE")
      AND parser(drr_rollback_criteria))
   ELSEIF (drr_mode="BATCHPOST")
    PLAN (dip
     WHERE (dip.install_plan_id=(- (1) * drr_ocd)))
     JOIN (dol
     WHERE dol.environment_id=drr_env_id
      AND dol.project_type="README"
      AND dol.ocd=dip.package_number)
     JOIN (dor
     WHERE dor.ocd=drr_ocd
      AND cnvtint(dol.project_name)=dor.readme_id
      AND dol.project_instance=dor.instance)
     JOIN (dr
     WHERE dor.readme_id=dr.readme_id
      AND dor.instance=dr.instance
      AND dr.execution="UP"
      AND parser(drr_rollback_criteria))
   ELSEIF (drr_mode="BATCHEXPRESS")
    PLAN (dip
     WHERE (dip.install_plan_id=(- (1) * drr_ocd)))
     JOIN (dol
     WHERE dol.environment_id=drr_env_id
      AND dol.project_type="README"
      AND dol.ocd=dip.package_number)
     JOIN (dor
     WHERE dor.ocd=drr_ocd
      AND cnvtint(dol.project_name)=dor.readme_id
      AND dol.project_instance=dor.instance)
     JOIN (dr
     WHERE dor.readme_id=dr.readme_id
      AND dor.instance=dr.instance
      AND parser(drr_rollback_criteria))
   ELSE
   ENDIF
   INTO "nl:"
   FROM dm_ocd_log dol,
    dm_install_plan dip,
    dm_ocd_readme dor,
    dm_readme dr
   DETAIL
    drr_readme->cnt = (drr_readme->cnt+ 1), stat = alterlist(drr_readme->qual,drr_readme->cnt),
    drr_readme->qual[drr_readme->cnt].ocd = dol.ocd,
    drr_readme->qual[drr_readme->cnt].readme_id = dr.readme_id, drr_readme->qual[drr_readme->cnt].
    readme_inst = dr.instance
   WITH nocounter
  ;end select
  IF (check_error(concat("Get readme info for packages on install plan id ",trim(cnvtstring(abs(
       drr_ocd)))," ."))=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(drr_readme)
 ENDIF
 SET dm_err->eproc = concat("Update readme history in dm_ocd_log table.")
 CALL disp_msg("",dm_err->logfile,0)
 IF ((drr_readme->cnt > 0))
  UPDATE  FROM dm_ocd_log l,
    (dummyt d  WITH seq = value(drr_readme->cnt))
   SET l.project_type = dm2_rr_readme_rback
   PLAN (d)
    JOIN (l
    WHERE l.environment_id=drr_env_id
     AND l.project_type="README"
     AND l.project_name=cnvtstring(drr_readme->qual[d.seq].readme_id)
     AND (l.project_instance=drr_readme->qual[d.seq].readme_inst)
     AND (l.ocd=drr_readme->qual[d.seq].ocd))
   WITH nocounter, maxcommit = 500
  ;end update
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ELSEIF ((curqual != drr_readme->cnt))
   SET reply->status_data.status = "F"
   SET dm_err->err_ind = 1
   SET dm_err->emsg = build("Expected number of readme rollback updates (",drr_readme->cnt,
    ") did not match actual updates (",curqual,").")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_program
 IF ((dm_err->err_ind=1))
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->ops_event = dm_err->emsg
 ELSE
  COMMIT
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(reply)
 ENDIF
 SET dm_err->eproc = "Ending DM2_README_ROLLBACK"
 CALL final_disp_msg("DM2_README_ROLLBACK")
END GO
