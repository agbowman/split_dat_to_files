CREATE PROGRAM dm_readme_include_sql:dba
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
 DECLARE find_connect_string(null) = i4
 RECORD db_connect(
   1 connect_string = vc
   1 username = vc
   1 password = vc
   1 db_name = vc
 )
 SUBROUTINE find_connect_string(null)
   SELECT INTO "nl:"
    e.v500_connect_string
    FROM dm_info i,
     dm_environment e
    PLAN (i
     WHERE i.info_domain="DATA MANAGEMENT"
      AND i.info_name="DM_ENV_ID"
      AND i.info_number > 0.0)
     JOIN (e
     WHERE e.environment_id=i.info_number
      AND e.v500_connect_string > " ")
    DETAIL
     db_connect->connect_string = trim(e.v500_connect_string,3)
    WITH nocounter
   ;end select
   IF ( NOT (curqual))
    CALL echo("ERROR: No database connect string found.")
    RETURN(0)
   ENDIF
   IF (currdb="DB2UDB")
    SET connect_string_len = textlen(db_connect->connect_string)
    SET end_pos = findstring("/",db_connect->connect_string)
    IF (end_pos > 0)
     SET db_connect->username = cnvtlower(trim(substring(1,(end_pos - 1),db_connect->connect_string),
       3))
     SET start_pos = (end_pos+ 1)
     SET db_connect->password = cnvtlower(trim(substring(start_pos,(connect_string_len - end_pos),
        db_connect->connect_string),3))
     SET db_connect->db_name = cnvtlower(currdblink)
    ELSE
     CALL echo("ERROR:No username and password found.")
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dmai_get_cur_mod_act(dgcma_mod_out=vc(ref),dmgca_act_out=vc(ref)) = i2
 DECLARE dmai_set_mod_act(module_name=vc,action_name=vc) = null WITH protect, sql =
 "SYS.DBMS_APPLICATION_INFO.SET_MODULE", parameter
 SUBROUTINE dmai_get_cur_mod_act(dgcma_mod_out,dmgca_act_out)
   DECLARE dgcma_mod_hold = vc WITH protect, noconstant("")
   DECLARE dgcma_act_hold = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Obtaining current Module and Action"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    HEAD REPORT
     dgcma_mod_hold = vs.module, dgcma_act_hold = vs.action
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgcma_mod_out = dgcma_mod_hold
   SET dmgca_act_out = dgcma_act_hold
   RETURN(1)
 END ;Subroutine
 DECLARE end_pos = i4 WITH public, noconstant(0)
 DECLARE start_pos = i4 WITH public, noconstant(0)
 DECLARE db2_status = i2 WITH public, noconstant(0)
 DECLARE test_comp = i2 WITH public, noconstant(0)
 DECLARE plb_ind = i2 WITH public, noconstant(0)
 DECLARE oracle_version = i4
 DECLARE xcnt = i4
 DECLARE dris_incoming_module = vc WITH protect, noconstant("")
 DECLARE dris_incoming_action = vc WITH protect, noconstant("")
 DECLARE dris_current_module = vc WITH protect, noconstant("")
 DECLARE dris_current_action = vc WITH protect, noconstant("")
 DECLARE dris_cmd_strg = vc WITH protect, noconstant("")
 DECLARE dris_modact_byp_ind = i2 WITH protect, noconstant(0)
 IF (check_logfile("dm_readme_incl",".log","DM_README_INC_LOG")=0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 DECLARE find_file(null) = i4
 DECLARE create_test_file(null) = i4
 DECLARE ris_fix(f_vms=vc,f_aix=vc) = null
 DECLARE ris_run(r_command=vc) = null
 DECLARE create_compile_files(file_name=vc) = i4
 DECLARE compile_objects(file_name=vc) = null
 DECLARE check_test_compile(null) = i4
 DECLARE drop_test_objects(null) = null
 IF (validate(dm_sql_reply->status," ")=" ")
  FREE RECORD dm_sql_reply
  RECORD dm_sql_reply(
    1 status = c1
    1 msg = vc
  )
 ENDIF
 IF (validate(ris_data->file,"Z")="Z")
  RECORD ris_data(
    1 file = vc
    1 test_file = vc
    1 plb_file = vc
    1 com_file = vc
    1 new_file = vc
    1 logical_file = vc
    1 rdb_read_file = vc
  )
 ENDIF
 IF (validate(object->validationfield,"Z")="Z")
  RECORD object(
    1 validationfield = c1
    1 qual[*]
      2 original_name = vc
      2 test_name = vc
      2 object_type = vc
  )
 ENDIF
 SET ris_i = 0
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ELSE
  SET dm_sql_reply->status = "S"
 ENDIF
 IF (reflect(parameter(1,0)) > " ")
  SET ris_data->file = parameter(1,0)
  SET ris_data->file = trim(cnvtlower(ris_data->file),3)
  SET pos = findstring(":",ris_data->file)
  IF ((validate(rdb_reader_ind,- (1))=- (1)))
   IF (dmai_get_cur_mod_act(dris_incoming_module,dris_incoming_action)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   SET dris_current_module = dris_incoming_module
   SET dris_current_action = dris_incoming_action
   IF (textlen(trim(dris_incoming_module,3))=0
    AND textlen(trim(dris_incoming_action,3))=0)
    SET dris_incoming_module = "DM_README_INCLUDE_SQL"
    SET dris_incoming_action = substring(1,32,substring((pos+ 1),(textlen(ris_data->file) - pos),
      ris_data->file))
   ELSEIF (textlen(trim(dris_incoming_module,3))=0)
    SET dris_incoming_module = "DM_README_INCLUDE_SQL"
   ELSEIF (textlen(trim(dris_incoming_action,3))=0)
    SET dris_incoming_action = substring(1,32,substring((pos+ 1),(textlen(ris_data->file) - pos),
      ris_data->file))
   ENDIF
  ENDIF
  SET ris_data->test_file = concat("ccluserdir:",substring((pos+ 1),(textlen(ris_data->file) - pos),
    ris_data->file),"_temp")
  CALL echo(build("ris_data->test_file = ",ris_data->test_file))
  SET ris_data->plb_file = concat(substring(1,(textlen(ris_data->file) - 4),ris_data->file),".plb")
  IF ((ris_data->file=" "))
   SET dm_sql_reply->status = "F"
   SET dm_sql_reply->msg = "No SQL file passed in"
   CALL echo("No SQL file passed in")
   GO TO exit_script
  ENDIF
 ELSE
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = "No SQL file passed in"
  CALL echo("No SQL file passed in")
  GO TO exit_script
 ENDIF
 IF ( NOT (find_file(null)))
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = "SQL file not found"
  GO TO exit_script
 ENDIF
 IF ((validate(rdb_reader_ind,- (1))=- (1)))
  IF ( NOT (find_connect_string(null)))
   SET dm_sql_reply->status = "F"
   SET dm_sql_reply->msg = "Database signon not found"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (plb_ind=0
  AND (validate(dris_skip_test_file,- (1))=- (1)))
  SET test_comp = 1
  IF ( NOT (create_test_file(null)))
   SET dm_sql_reply->status = "F"
   SET dm_sql_reply->msg = "Test file could not be created"
   GO TO exit_script
  ENDIF
  IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
   CALL ris_fix("cclsource:","$CCLSOURCE/")
   CALL ris_fix("cer_install:","$cer_install/")
   CALL ris_fix("cer_proc:","$cer_proc/")
   CALL ris_fix("ccluserdir:","$CCLUSERDIR/")
  ELSEIF ((dm2_sys_misc->cur_os="WIN"))
   CALL ris_fix("cclsource:",build(logical("CCLSOURCE"),"\"))
   CALL ris_fix("cer_install:",build(logical("cer_install"),"\"))
   CALL ris_fix("cer_proc:",build(logical("cer_proc"),"\"))
   CALL ris_fix("ccluserdir:",build(logical("CCLUSERDIR"),"\"))
  ENDIF
  IF (currdb="ORACLE")
   IF ( NOT (create_compile_files(ris_data->test_file)))
    SET dm_sql_reply->status = "F"
    SET dm_sql_reply->msg = "Compile file could not be created"
    GO TO exit_script
   ENDIF
  ENDIF
  CALL compile_objects(ris_data->test_file)
  IF ( NOT (check_test_compile(null)))
   GO TO exit_script
  ELSE
   CALL drop_test_objects(null)
  ENDIF
 ELSE
  IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
   CALL ris_fix("cclsource:","$CCLSOURCE/")
   CALL ris_fix("cer_install:","$cer_install/")
   CALL ris_fix("cer_proc:","$cer_proc/")
   CALL ris_fix("ccluserdir:","$CCLUSERDIR/")
  ELSEIF ((dm2_sys_misc->cur_os="WIN"))
   DECLARE dris_tmp_str = vc
   SET dris_tmp_str = build(logical("CCLSOURCE"),"\")
   CALL ris_fix("cclsource:",dris_tmp_str)
   SET dris_tmp_str = build(logical("cer_install"),"\")
   CALL ris_fix("cer_install:",dris_tmp_str)
   SET dris_tmp_str = build(logical("cer_proc"),"\")
   CALL ris_fix("cer_proc:",dris_tmp_str)
   SET dris_tmp_str = build(logical("CCLUSERDIR"),"\")
   CALL ris_fix("ccluserdir:",dris_tmp_str)
  ENDIF
 ENDIF
 IF (currdb="ORACLE")
  IF ( NOT (create_compile_files(ris_data->file)))
   SET dm_sql_reply->status = "F"
   SET dm_sql_reply->msg = "Compile file could not be created"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL compile_objects(ris_data->file)
 CALL echorecord(object)
 IF ((validate(rdb_reader_ind,- (1))=- (1)))
  CALL dmai_set_mod_act(dris_current_module,dris_current_action)
 ENDIF
 SUBROUTINE ris_fix(f_vms,f_aix)
  IF (findstring(f_vms,ris_data->file))
   SET ris_data->file = trim(replace(ris_data->file,f_vms,"",1),3)
   SET ris_data->file = build(f_aix,ris_data->file)
  ENDIF
  IF (findstring(f_vms,ris_data->test_file))
   SET ris_data->test_file = trim(replace(ris_data->test_file,f_vms,"",1),3)
   SET ris_data->test_file = build(f_aix,ris_data->test_file)
   CALL echo(build("ris_data->test_file  01= ",ris_data->test_file))
  ENDIF
 END ;Subroutine
 SUBROUTINE ris_rdb_read_fix(f_vms,f_aix)
   IF (findstring(f_aix,ris_data->rdb_read_file))
    SET ris_data->rdb_read_file = replace(ris_data->rdb_read_file,f_aix,f_vms,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE ris_run(r_command)
   SET r_flag = 0
   SET r_len = size(r_command)
   CALL dcl(r_command,r_len,r_flag)
 END ;Subroutine
 SUBROUTINE find_file(null)
   IF (findfile(ris_data->plb_file))
    SET ris_data->file = ris_data->plb_file
    SET plb_ind = 1
    RETURN(1)
   ELSEIF (findfile(ris_data->file))
    RETURN(1)
   ELSE
    CALL echo(concat("ERROR: Unable to find SQL file (",ris_data->file,")."))
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_test_file(null)
   CALL echo("creating test file")
   DECLARE object_type = vc
   DECLARE temp_str = vc
   DECLARE temp2_str = vc
   DECLARE upper_str = vc
   DECLARE obj_type_found = i4
   DECLARE obj_name_found = i4
   DECLARE replace_found = i4
   DECLARE create_found = i4
   DECLARE file_name = vc
   DECLARE len_error = i2
   SET logical file_name value(ris_data->file)
   FREE DEFINE rtl2
   DEFINE rtl2 "file_name"
   IF (currdb="ORACLE")
    CALL echo(build("ris_data->test_file 02 = ",ris_data->test_file))
    SELECT INTO value(ris_data->test_file)
     t.line
     FROM rtl2t t
     HEAD REPORT
      cnt = 0, chk_num = 0, temp_num = 0,
      replace_found = 0, comment_ind = 0, len_error = 0
     DETAIL
      str_len = textlen(trim(t.line,3))
      IF (validate(rdb_reader_ind,- (1)) > 0
       AND str_len > 255)
       len_error = 1
      ELSEIF (len_error=0)
       upper_str = cnvtupper(trim(t.line,3)), temp_str = upper_str
       IF (findstring("/*",upper_str,1,0))
        comment_ind = 1
       ELSEIF (findstring("/*",upper_str,1,0)
        AND findstring("*/",upper_str,1,0))
        comment_ind = 0
       ENDIF
       IF ( NOT (((findstring("REM ",upper_str,1,0)=1) OR (findstring("--",upper_str,1,0)=1)) ))
        IF (comment_ind=0)
         pos = findstring("CREATE OR ",upper_str,1,0)
         IF (pos)
          replace_found = 0, pos = 0
         ENDIF
         IF (replace_found=0)
          pos = findstring("REPLACE ",upper_str,1,0),
          CALL echo(build("REPLACE keyword pos:",pos)), pos1 = 0,
          pos2 = 0, dynam_ind = 0, pos2 = findstring(":=",upper_str,1,0)
          IF (pos2 < pos
           AND pos2 > 0)
           dynam_ind = 1
          ENDIF
          pos1 = findstring("(",upper_str,1,0)
          IF (pos1 < pos
           AND pos1 > 0)
           dynam_ind = 1
          ENDIF
          IF (pos > 0
           AND dynam_ind=0)
           replace_found = 1, obj_type_found = 0, obj_name_found = 0,
           pos1 = 0, temp_str = trim(substring((pos+ 8),str_len,upper_str),3), str_len = textlen(trim
            (temp_str,3)),
           pos = 0
           IF (str_len > 0)
            pos = findstring(" ",temp_str,1,0)
            IF (pos)
             cnt = (cnt+ 1), stat = alterlist(object->qual,cnt), object->qual[cnt].object_type = trim
             (substring(1,(pos - 1),temp_str),3),
             temp_str = trim(substring((pos+ 1),str_len,temp_str),3), str_len = textlen(trim(temp_str,
               3)), pos = 0
             IF ((object->qual[cnt].object_type="PACKAGE"))
              IF (str_len > 0)
               pos = findstring("BODY",temp_str,1,0)
               IF (pos)
                object->qual[cnt].object_type = concat(object->qual[cnt].object_type," ",substring(
                  pos,4,temp_str)), obj_type_found = 1, package_found = 0,
                temp_str = trim(substring((pos+ 5),str_len,temp_str),3), str_len = textlen(trim(
                  temp_str,3))
               ELSE
                obj_type_found = 1, package_found = 0
               ENDIF
              ELSE
               package_found = 1
              ENDIF
             ELSE
              obj_type_found = 1, package_found = 0
             ENDIF
             IF (str_len > 0)
              pos = findstring("(",temp_str,1,0)
              IF (pos)
               object->qual[cnt].original_name = trim(substring(1,(pos - 1),temp_str),3), obj_len =
               textlen(object->qual[cnt].original_name)
               IF (obj_len > 28)
                object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                 "_R")
               ELSE
                object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
               ENDIF
               WHILE (obj_name_found=0)
                 chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].
                  test_name,object->qual[chk_num].test_name)
                 IF (chk_num=cnt)
                  obj_name_found = 1
                 ELSEIF (findstring("PACKAGE",upper_str,1,0))
                  obj_name_found = 1
                 ELSE
                  temp_num = (temp_num+ 1)
                  IF (obj_len > 28)
                   object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name
                     ),cnvtstring(temp_num),"R")
                  ELSE
                   object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                     temp_num),"R")
                  ENDIF
                 ENDIF
               ENDWHILE
              ELSEIF (findstring(" ",temp_str,1,0))
               pos = findstring(" ",temp_str,1,0), object->qual[cnt].original_name = trim(substring(1,
                 (pos - 1),temp_str),3), obj_len = textlen(object->qual[cnt].original_name)
               IF (obj_len > 28)
                object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                 "_R")
               ELSE
                object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
               ENDIF
               WHILE (obj_name_found=0)
                 chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].
                  test_name,object->qual[chk_num].test_name)
                 IF (chk_num=cnt)
                  obj_name_found = 1
                 ELSEIF (findstring("PACKAGE",upper_str,1,0))
                  obj_name_found = 1
                 ELSE
                  temp_num = (temp_num+ 1)
                  IF (obj_len > 28)
                   object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name
                     ),cnvtstring(temp_num),"R")
                  ELSE
                   object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                     temp_num),"R")
                  ENDIF
                 ENDIF
               ENDWHILE
               pos = 0
              ELSE
               object->qual[cnt].original_name = trim(substring(1,str_len,temp_str),3), obj_len =
               textlen(object->qual[cnt].original_name)
               IF (obj_len > 28)
                object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                 "_R")
               ELSE
                object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
               ENDIF
               WHILE (obj_name_found=0)
                 chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].
                  test_name,object->qual[chk_num].test_name)
                 IF (chk_num=cnt)
                  obj_name_found = 1
                 ELSEIF (findstring("PACKAGE",upper_str,1,0))
                  obj_name_found = 1
                 ELSE
                  temp_num = (temp_num+ 1)
                  IF (obj_len > 28)
                   object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name
                     ),cnvtstring(temp_num),"R")
                  ELSE
                   object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                     temp_num),"R")
                  ENDIF
                 ENDIF
               ENDWHILE
              ENDIF
             ENDIF
            ELSE
             cnt = (cnt+ 1), stat = alterlist(object->qual,cnt), object->qual[cnt].object_type = trim
             (substring(1,str_len,temp_str),3)
             IF ((object->qual[cnt].object_type="PACKAGE"))
              package_found = 1
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ELSE
          IF (obj_type_found=0
           AND package_found=1)
           temp_str = trim(upper_str,3), pos = findstring("BODY",temp_str,1,0)
           IF (pos)
            object->qual[cnt].object_type = concat(object->qual[cnt].object_type," ",substring(pos,4,
              temp_str)), obj_type_found = 1, package_found = 0,
            temp_str = trim(substring((pos+ 5),str_len,temp_str),3), str_len = textlen(trim(temp_str,
              3))
            IF (str_len > 0)
             pos = findstring("(",temp_str,1,0)
             IF (pos)
              object->qual[cnt].original_name = trim(substring(1,(pos - 1),temp_str),3), obj_len =
              textlen(object->qual[cnt].original_name)
              IF (obj_len > 28)
               object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                "_R")
              ELSE
               object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
              ENDIF
              WHILE (obj_name_found=0)
                chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
                 object->qual[chk_num].test_name)
                IF (chk_num=cnt)
                 obj_name_found = 1
                ELSEIF (findstring("PACKAGE",upper_str,1,0))
                 obj_name_found = 1
                ELSE
                 temp_num = (temp_num+ 1)
                 IF (obj_len > 28)
                  object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                   cnvtstring(temp_num),"R")
                 ELSE
                  object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                    temp_num),"R")
                 ENDIF
                ENDIF
              ENDWHILE
             ELSEIF (findstring(" ",temp_str,1,0))
              pos = findstring(" ",temp_str,1,0), object->qual[cnt].original_name = trim(substring(1,
                (pos - 1),temp_str),3), obj_len = textlen(object->qual[cnt].original_name)
              IF (obj_len > 28)
               object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                "_R")
              ELSE
               object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
              ENDIF
              WHILE (obj_name_found=0)
                chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
                 object->qual[chk_num].test_name)
                IF (chk_num=cnt)
                 obj_name_found = 1
                ELSEIF (findstring("PACKAGE",upper_str,1,0))
                 obj_name_found = 1
                ELSE
                 temp_num = (temp_num+ 1)
                 IF (obj_len > 28)
                  object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                   cnvtstring(temp_num),"R")
                 ELSE
                  object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                    temp_num),"R")
                 ENDIF
                ENDIF
              ENDWHILE
              pos = 0
             ELSE
              object->qual[cnt].original_name = trim(substring(1,str_len,temp_str),3), obj_len =
              textlen(object->qual[cnt].original_name)
              IF (obj_len > 28)
               object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                "_R")
              ELSE
               object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
              ENDIF
              WHILE (obj_name_found=0)
                chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
                 object->qual[chk_num].test_name)
                IF (chk_num=cnt)
                 obj_name_found = 1
                ELSEIF (findstring("PACKAGE",upper_str,1,0))
                 obj_name_found = 1
                ELSE
                 temp_num = (temp_num+ 1)
                 IF (obj_len > 28)
                  object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                   cnvtstring(temp_num),"R")
                 ELSE
                  object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                    temp_num),"R")
                 ENDIF
                ENDIF
              ENDWHILE
             ENDIF
            ENDIF
           ELSE
            obj_type_found = 1, package_found = 0
           ENDIF
          ELSEIF (obj_type_found=0
           AND obj_name_found=0)
           temp_str = trim(upper_str,3), pos = findstring(" ",temp_str,1,0)
           IF (pos)
            cnt = (cnt+ 1), stat = alterlist(object->qual,cnt), object->qual[cnt].object_type = trim(
             substring(1,(pos - 1),temp_str),3),
            obj_type_found = 1, temp_str = trim(substring((pos+ 1),str_len,temp_str),3), str_len =
            textlen(trim(temp_str,3)),
            pos = 0
            IF ((object->qual[cnt].object_type="PACKAGE"))
             IF (str_len > 0)
              pos = findstring("BODY",temp_str,1,0)
              IF (pos)
               object->qual[cnt].object_type = concat(object->qual[cnt].object_type," ",substring(pos,
                 4,temp_str)), obj_type_found = 1, package_found = 0,
               temp_str = trim(substring((pos+ 5),str_len,temp_str),3), str_len = textlen(trim(
                 temp_str,3))
              ELSE
               obj_type_found = 1, package_found = 0
              ENDIF
             ELSE
              package_found = 1
             ENDIF
            ELSE
             obj_type_found = 1, package_found = 0
            ENDIF
            IF (str_len > 0)
             pos = findstring("(",temp_str,1,0)
             IF (pos)
              object->qual[cnt].original_name = trim(substring(1,(pos - 1),temp_str),3), obj_len =
              textlen(object->qual[cnt].original_name)
              IF (obj_len > 28)
               object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                "_R")
              ELSE
               object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
              ENDIF
              WHILE (obj_name_found=0)
                chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
                 object->qual[chk_num].test_name)
                IF (chk_num=cnt)
                 obj_name_found = 1
                ELSEIF (findstring("PACKAGE",upper_str,1,0))
                 obj_name_found = 1
                ELSE
                 temp_num = (temp_num+ 1)
                 IF (obj_len > 28)
                  object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                   cnvtstring(temp_num),"R")
                 ELSE
                  object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                    temp_num),"R")
                 ENDIF
                ENDIF
              ENDWHILE
             ELSEIF (findstring(" ",temp_str,1,0))
              pos = findstring(" ",temp_str,1,0), object->qual[cnt].original_name = trim(substring(1,
                (pos - 1),temp_str),3), obj_len = textlen(object->qual[cnt].original_name)
              IF (obj_len > 28)
               object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                "_R")
              ELSE
               object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
              ENDIF
              WHILE (obj_name_found=0)
                chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
                 object->qual[chk_num].test_name)
                IF (chk_num=cnt)
                 obj_name_found = 1
                ELSEIF (findstring("PACKAGE",upper_str,1,0))
                 obj_name_found = 1
                ELSE
                 temp_num = (temp_num+ 1)
                 IF (obj_len > 28)
                  object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                   cnvtstring(temp_num),"R")
                 ELSE
                  object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                    temp_num),"R")
                 ENDIF
                ENDIF
              ENDWHILE
              pos = 0
             ELSE
              object->qual[cnt].original_name = trim(substring(1,str_len,temp_str),3), obj_len =
              textlen(object->qual[cnt].original_name)
              IF (obj_len > 28)
               object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                "_R")
              ELSE
               object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
              ENDIF
              WHILE (obj_name_found=0)
                chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
                 object->qual[chk_num].test_name)
                IF (chk_num=cnt)
                 obj_name_found = 1
                ELSEIF (findstring("PACKAGE",upper_str,1,0))
                 obj_name_found = 1
                ELSE
                 temp_num = (temp_num+ 1)
                 IF (obj_len > 28)
                  object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                   cnvtstring(temp_num),"R")
                 ELSE
                  object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                    temp_num),"R")
                 ENDIF
                ENDIF
              ENDWHILE
             ENDIF
            ENDIF
           ELSE
            cnt = (cnt+ 1), stat = alterlist(object->qual,cnt), object->qual[cnt].object_type = trim(
             substring(1,str_len,temp_str),3)
            IF ((object->qual[cnt].object_type="PACKAGE"))
             package_found = 1
            ENDIF
           ENDIF
          ELSEIF (obj_name_found=0)
           temp_str = trim(upper_str,3), pos = findstring("(",temp_str,1,0)
           IF (pos)
            object->qual[cnt].original_name = trim(substring(1,(pos - 1),temp_str),3), obj_len =
            textlen(object->qual[cnt].original_name)
            IF (obj_len > 28)
             object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),"_R"
              )
            ELSE
             object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
            ENDIF
            WHILE (obj_name_found=0)
              chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
               object->qual[chk_num].test_name)
              IF (chk_num=cnt)
               obj_name_found = 1
              ELSEIF (findstring("PACKAGE",upper_str,1,0))
               obj_name_found = 1
              ELSE
               temp_num = (temp_num+ 1)
               IF (obj_len > 28)
                object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                 cnvtstring(temp_num),"R")
               ELSE
                object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                  temp_num),"R")
               ENDIF
              ENDIF
            ENDWHILE
           ELSEIF (findstring(" ",temp_str,1,0))
            pos = findstring(" ",temp_str,1,0), object->qual[cnt].original_name = trim(substring(1,(
              pos - 1),temp_str),3), obj_len = textlen(object->qual[cnt].original_name)
            IF (obj_len > 28)
             object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),"_R"
              )
            ELSE
             object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
            ENDIF
            WHILE (obj_name_found=0)
              chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
               object->qual[chk_num].test_name)
              IF (chk_num=cnt)
               obj_name_found = 1
              ELSEIF (findstring("PACKAGE",upper_str,1,0))
               obj_name_found = 1
              ELSE
               temp_num = (temp_num+ 1)
               IF (obj_len > 28)
                object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                 cnvtstring(temp_num),"R")
               ELSE
                object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                  temp_num),"R")
               ENDIF
              ENDIF
            ENDWHILE
            pos = 0
           ELSE
            object->qual[cnt].original_name = trim(substring(1,str_len,temp_str),3), obj_len =
            textlen(object->qual[cnt].original_name)
            IF (obj_len > 28)
             object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),"_R"
              )
            ELSE
             object->qual[cnt].test_name = build(object->qual[cnt].original_name,"_R")
            ENDIF
            WHILE (obj_name_found=0)
              chk_num = 0, stat = expand(chk_num,1,size(object->qual,5),object->qual[cnt].test_name,
               object->qual[chk_num].test_name)
              IF (chk_num=cnt)
               obj_name_found = 1
              ELSEIF (findstring("PACKAGE",upper_str,1,0))
               obj_name_found = 1
              ELSE
               temp_num = (temp_num+ 1)
               IF (obj_len > 28)
                object->qual[cnt].test_name = build(substring(1,28,object->qual[cnt].original_name),
                 cnvtstring(temp_num),"R")
               ELSE
                object->qual[cnt].test_name = build(object->qual[cnt].original_name,cnvtstring(
                  temp_num),"R")
               ENDIF
              ENDIF
            ENDWHILE
           ENDIF
          ENDIF
         ENDIF
        ENDIF
        IF ( NOT (findstring("DROP",upper_str,1,0)))
         temp_str = " "
         IF (size(object->qual,5))
          found = 0, object_len = textlen(object->qual[cnt].original_name), pos = findstring(object->
           qual[cnt].original_name,upper_str,1,0)
          IF (pos)
           IF (substring((pos - 1),1,upper_str) != "."
            AND substring((pos+ object_len),1,upper_str) IN (" ", "(", ";", "."))
            temp_str = replace(upper_str,object->qual[cnt].original_name,object->qual[cnt].test_name,
             0), found = 1
           ENDIF
           temp2_str = " ", temp2_str = temp_str
           FOR (xcnt = 1 TO size(object->qual,5))
             object_len = textlen(object->qual[xcnt].original_name), pos = findstring(object->qual[
              xcnt].original_name,temp2_str,1,0)
             IF (pos)
              IF ( NOT ((object->qual[xcnt].original_name=object->qual[cnt].original_name)))
               IF (substring((pos+ object_len),1,temp2_str) IN ("(", "."))
                temp_str = replace(temp2_str,object->qual[xcnt].original_name,object->qual[xcnt].
                 test_name,0), temp2_str = temp_str, found = 1
               ENDIF
              ENDIF
             ENDIF
           ENDFOR
          ELSE
           temp2_str = " ", temp2_str = upper_str
           FOR (x = 1 TO size(object->qual,5))
             object_len = textlen(object->qual[x].original_name), pos = findstring(object->qual[x].
              original_name,temp2_str,1,0)
             IF (pos)
              IF ( NOT ((object->qual[x].original_name=object->qual[cnt].original_name)))
               IF (substring((pos+ object_len),1,temp2_str) IN ("(", "."))
                temp_str = replace(temp2_str,object->qual[x].original_name,object->qual[x].test_name,
                 0), temp2_str = temp_str, found = 1
               ENDIF
              ENDIF
             ENDIF
           ENDFOR
          ENDIF
          IF (found=0)
           col 0, upper_str, row + 1
          ELSE
           col 0, temp_str, row + 1
          ENDIF
         ELSE
          col 0, upper_str, row + 1
         ENDIF
        ENDIF
       ENDIF
       IF (findstring("*/",upper_str,1,0))
        comment_ind = 0
       ENDIF
      ENDIF
     WITH nocounter, noformfeed, maxcol = 2100,
      format = variable
    ;end select
    IF (len_error=1)
     CALL echo("*****ERROR: LENGTH OF EACH LINE IN INPUT FILE MUST BE < 255 CHARACTERS*****")
     RETURN(0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE create_compile_files(file_name)
   CALL echo("creating compile files")
   DECLARE com_found = i4
   IF ( NOT ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX", "WIN"))))
    IF ((validate(systimestamp,- (999.00)) != - (999.00))
     AND validate(systimestamp,999.00) != 999.00)
     SET ris_data->com_file = concat("ccluserdir:dm",format(systimestamp,"hhmmsscccccc;;q"),".com")
    ELSE
     SET ris_data->com_file = concat("ccluserdir:dm",format(curtime3,"hhmmsscc;3;m"),".com")
    ENDIF
    SELECT INTO "NL:"
     p.*
     FROM product_component_version p
     WHERE cnvtupper(p.product)="ORACLE*"
     DETAIL
      oracle_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
     WITH nocounter
    ;end select
    SELECT INTO value(ris_data->com_file)
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     DETAIL
      IF (oracle_version >= 9)
       IF (findfile("oracle_home:orauser.com"))
        CALL print("$@oracle_home:orauser"), row + 1, com_found = 1
       ELSEIF (findfile("ora_util:orauser.com"))
        CALL print("$@ora_util:orauser"), row + 1, com_found = 1
       ELSE
        CALL echo("orauser.com not found"), com_found = 0
       ENDIF
      ELSE
       IF (findfile("ora_util:orauser.com"))
        CALL print("$@ora_util:orauser"), row + 1, com_found = 1
       ELSEIF (findfile("oracle_home:orauser.com"))
        CALL print("$@oracle_home:orauser"), row + 1, com_found = 1
       ELSE
        CALL echo("orauser.com not found"), com_found = 0
       ENDIF
      ENDIF
      CALL print(concat("$sqlplus ",db_connect->connect_string," @",file_name))
     WITH nocounter, format = variable, maxrow = 1,
      noformfeed, maxcol = 500
    ;end select
    IF (com_found=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    IF ((validate(systimestamp,- (999.00)) != - (999.00))
     AND validate(systimestamp,999.00) != 999.00)
     SET ris_data->new_file = concat("dm",format(systimestamp,"hhmmsscccccc;;q"),".sql")
    ELSE
     SET ris_data->new_file = concat("dm",format(curtime3,"hhmmsscc;3;m"),".sql")
    ENDIF
    SET ris_data->logical_file = concat("ccluserdir:",ris_data->new_file)
    SET ris_data->new_file = concat("$CCLUSERDIR/",ris_data->new_file)
    IF ((validate(rdb_reader_ind,- (1))=- (1)))
     SET dm_err->eproc = "Determining whether module/action setters can be bypassed"
     SELECT INTO "nl:"
      FROM dm_info
      WHERE info_domain="DM_README_INCLUDE_SQL_OPTION"
       AND info_name="BYPASS_MODACT"
      DETAIL
       dris_modact_byp_ind = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (dris_modact_byp_ind=0)
      SET dris_cmd_strg = concat("exec DBMS_APPLICATION_INFO.SET_MODULE(module_name=>'",
       dris_incoming_module,"'",",action_name=>'",dris_incoming_action,
       "');")
     ENDIF
    ENDIF
    IF (findstring(".sql",file_name) > 0)
     IF (dris_modact_byp_ind=0
      AND (validate(rdb_reader_ind,- (1))=- (1)))
      CALL ris_run(concat('echo "',dris_cmd_strg,'" > ',ris_data->new_file))
      CALL ris_run(concat("cat ",file_name," >>",ris_data->new_file))
     ELSE
      CALL ris_run(concat("cp ",file_name," ",ris_data->new_file))
     ENDIF
     CALL ris_run(concat("chmod 777 ",ris_data->new_file))
     IF (findfile(ris_data->logical_file))
      IF (test_comp=1)
       SET ris_data->test_file = ris_data->new_file
       CALL echo(build("ris_data->test_file = 04 ",ris_data->test_file))
      ELSE
       SET ris_data->file = ris_data->new_file
       CALL echo(build("ris_data->test_file 05 = ",ris_data->test_file))
      ENDIF
     ELSE
      CALL echo("ERROR: Unable to compile SQL file.  Temporary copy process failed.")
      RETURN(0)
     ENDIF
    ENDIF
    IF ((validate(rdb_reader_ind,- (1))=- (1)))
     IF (findstring(".sql",ris_data->file) > 0)
      SELECT INTO value(ris_data->logical_file)
       FROM (dummyt d  WITH seq = 1)
       PLAN (d)
       DETAIL
        row + 2, "exit;", row + 1
       WITH nocounter, append, noformfeed,
        format = variable, maxrow = 1
      ;end select
     ELSE
      SELECT INTO value(ris_data->logical_file)
       FROM (dummyt d  WITH seq = 1)
       PLAN (d)
       DETAIL
        IF (dris_modact_byp_ind=0)
         col 0, dris_cmd_strg, row + 1
        ENDIF
        col 0, "@", col + 0,
        ris_data->file, row + 1, "exit;",
        row + 1
       WITH nocounter, noformfeed, format = variable
      ;end select
     ENDIF
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="WIN"))
    IF ((validate(systimestamp,- (999.00)) != - (999.00))
     AND validate(systimestamp,999.00) != 999.00)
     SET ris_data->new_file = concat("dm",format(systimestamp,"hhmmsscccccc;;q"),".sql")
    ELSE
     SET ris_data->new_file = concat("dm",format(curtime3,"hhmmsscc;3;m"),".sql")
    ENDIF
    SET ris_data->logical_file = ris_data->new_file
    SET ris_data->new_file = build(logical("CCLUSERDIR"),"\",ris_data->new_file)
    IF (findstring(".sql",file_name) > 0)
     CALL ris_run(concat("copy ",file_name," ",ris_data->new_file))
     IF (findfile(ris_data->logical_file))
      IF (test_comp=1)
       SET ris_data->test_file = ris_data->new_file
       CALL echo(build("ris_data->test_file = 04 ",ris_data->test_file))
      ELSE
       SET ris_data->file = ris_data->new_file
       CALL echo(build("ris_data->test_file 05 = ",ris_data->test_file))
      ENDIF
     ELSE
      CALL echo("ERROR: Unable to compile SQL file.  Temporary copy process failed.")
      RETURN(0)
     ENDIF
    ENDIF
    IF ((validate(rdb_reader_ind,- (1))=- (1)))
     IF (findstring(".sql",ris_data->file) > 0)
      SELECT INTO value(ris_data->logical_file)
       FROM (dummyt d  WITH seq = 1)
       PLAN (d)
       DETAIL
        row + 2, "exit;", row + 1
       WITH nocounter, append, noformfeed,
        format = variable, maxrow = 1
      ;end select
     ELSE
      SELECT INTO value(ris_data->logical_file)
       FROM (dummyt d  WITH seq = 1)
       PLAN (d)
       DETAIL
        col 0, "@", col + 0,
        ris_data->file, row + 1, "exit;",
        row + 1
       WITH nocounter, noformfeed, format = variable
      ;end select
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE compile_objects(file_name)
   DECLARE db2_str = vc WITH protect, noconstant(" ")
   CALL echo("compiling objects")
   IF (currdb="ORACLE")
    IF (validate(rdb_reader_ind,- (1)) > 0)
     SET ris_data->rdb_read_file = file_name
     IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
      CALL ris_rdb_read_fix("cclsource:","$CCLSOURCE/")
      CALL ris_rdb_read_fix("cer_install:","$cer_install/")
      CALL ris_rdb_read_fix("cer_proc:","$cer_proc/")
      CALL ris_rdb_read_fix("ccluserdir:","$CCLUSERDIR/")
     ENDIF
     CALL parser(concat("rdb read '",ris_data->rdb_read_file,"' with full end go"))
    ELSE
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL ris_run(concat("@",ris_data->com_file))
     ELSEIF ((dm2_sys_misc->cur_os="WIN"))
      IF (findstring(".sql",ris_data->file) > 0)
       CALL ris_run(concat(build(logical("oracle_home"),"\bin\sqlplus")," ",db_connect->
         connect_string," @",file_name))
      ELSE
       CALL ris_run(concat(build(logical("oracle_home"),"\bin\sqlplus")," ",db_connect->
         connect_string," <",file_name))
      ENDIF
     ELSE
      IF (findstring(".sql",ris_data->file) > 0)
       CALL ris_run(concat("$ORACLE_HOME/bin/sqlplus ",db_connect->connect_string," @",file_name))
      ELSE
       CALL ris_run(concat("$ORACLE_HOME/bin/sqlplus ",db_connect->connect_string," <",file_name))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_test_compile(null)
   CALL echo("checking test compile")
   FOR (x = 1 TO size(object->qual,5))
    EXECUTE dm_readme_include_sql_chk value(object->qual[x].test_name), value(object->qual[x].
     object_type)
    IF ((dm_sql_reply->status="F"))
     SET dm_sql_reply->msg = concat(object->qual[x].object_type," ",object->qual[x].original_name,
      " could not be compiled: ",dm_sql_reply->msg)
     RETURN(0)
    ENDIF
   ENDFOR
   SET test_comp = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drop_test_objects(null)
   CALL echo("dropping test objects")
   DECLARE drop_str = vc
   SET x = size(object->qual,5)
   WHILE (x >= 1)
     IF ( NOT ((object->qual[x].object_type IN ("PACKAGE BODY", "PACKAGE"))))
      SET drop_str = concat("rdb drop ",object->qual[x].object_type," ",object->qual[x].test_name,
       " go")
      CALL parser(drop_str)
     ELSEIF ((object->qual[x].object_type="PACKAGE BODY"))
      SET drop_str = concat("rdb drop PACKAGE ",object->qual[x].test_name," go")
      CALL parser(drop_str)
     ENDIF
     COMMIT
     SET x = (x - 1)
   ENDWHILE
 END ;Subroutine
#exit_script
 FREE DEFINE rtl2
 CALL echo(concat("*** Temp Filename: ",ris_data->test_file))
 IF ((validate(rdb_reader_ind,- (1))=- (1)))
  CALL dmai_set_mod_act(dris_current_module,dris_current_action)
 ENDIF
 SET dm_err->eproc = "Ending dm_readme_include_sql"
 CALL final_disp_msg("dm_readme_incl")
END GO
