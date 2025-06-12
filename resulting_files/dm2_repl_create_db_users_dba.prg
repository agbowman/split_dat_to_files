CREATE PROGRAM dm2_repl_create_db_users:dba
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
 DECLARE drr_val_write_privs(dvwp_full_dir=vc) = i4
 DECLARE drr_clin_copy_setup(dccs_whereto=vc(ref)) = i2
 DECLARE drr_clin_copy_restart_chk(null) = i2
 DECLARE drr_check_log_for_errors(dclfe_op_id=f8,dclfe_oper_logfile=vc,dclfe_force_load_ind=i2,
  dclfe_err_ind=i2(ref)) = i2
 DECLARE drr_load_mixed_table_data(dlmtd_force_load_ind=i2) = i2
 DECLARE drr_get_dmp_log_loc(dgdll_op_id=f8,dgdll_dmp_loc_out=vc(ref)) = i2
 DECLARE drr_load_ref_table_data(force_load_ind=i2) = i2
 DECLARE drr_get_exp_dmp_loc(dgedl_dmp_loc_out=vc(ref)) = i2
 DECLARE drr_load_preserved_table_data(dlp_source=vc,dlp_file=vc) = i2
 DECLARE drr_prompt_preserve_data(null) = i2
 DECLARE drr_chk_for_preserved_data(dcf_chk_ret=i2(ref)) = i2
 DECLARE drr_display_summary_screen(null) = i2
 DECLARE drr_get_invalid_tables_list(null) = i2
 DECLARE drr_process_invalid_tables(null) = i2
 DECLARE drr_get_dbase_created_date(dgdcd_created_date=f8(ref)) = i2
 DECLARE drr_prompt_schema_date(dpsd_row=i4(ref)) = null
 DECLARE drr_prompt_loc(dpl_row=i4(ref),dpl_type=vc) = i2
 DECLARE drr_get_max_clin_copy_run_id(dgm_run_id=f8(ref)) = i2
 DECLARE drr_get_custom_tables_list(null) = i2
 DECLARE drr_validate_ref_data_link(null) = i2
 DECLARE drr_ads_domain_check(dadc_db_link=vc,dadc_ads_domain_ind=i2(ref)) = i2
 DECLARE drr_prompt_ads_config(dpac_response=c1(ref)) = i2
 DECLARE drr_validate_tgtdblink(dvt_tgt_host=vc,dvt_tgt_ora_ver=i2,dvt_src_host=vc) = i2
 DECLARE drr_validate_adm_env_csv(dvae_path=vc,dvae_src_env=vc) = i2
 DECLARE drr_set_src_env_path(null) = null
 DECLARE drr_confirm_invalid_tables(dcit_manage_opt_ind=i2,dcit_confirm_ret=i2(ref)) = i2
 DECLARE drr_column_and_ccldef_exists(dcce_table_name=vc,dcce_column_name=vc,dcce_exists_ind=i2(ref))
  = i2
 DECLARE drr_identify_was_usage(diwu_domain=vc,diwu_was_ind=i2(ref)) = i2
 DECLARE drr_restore_col_checks(drcc_src=vc,drcc_sti=i4,drcc_sci=i4,drcc_pti=i4,drcc_pci=i4,
  drcc_tti=i4,drcc_tc=i4) = i2
 DECLARE drr_restore_tbl_checks(drtc_src=vc,drtc_sti=i4,drtc_pti=i4) = i2
 DECLARE drr_restore_report(null) = i2
 DECLARE drr_restore_col_mismatch(null) = i2
 DECLARE drr_restore_tbl_mismatch(null) = i2
 DECLARE drr_cleanup_drr_copy(dcdc_drr_cleanup=vc(ref)) = i2
 DECLARE drr_load_chunk_imp_tbls(dlcit_db_link=vc,dlcit_get_chunks_ind=i2) = i2
 DECLARE drr_get_mixtbl_ref_rows(dgmrr_db_name=vc) = i2
 DECLARE drr_upd_mixtbl_ref_rows(dumrr_db_name=vc,dumrr_run_id=i2) = i2
 DECLARE drr_refresh_drop_restrict(drdr_mode=vc,drdr_restart_ind=i2) = i2
 DECLARE drr_drop_user_restrict_ksh(null) = i2
 DECLARE drr_verify_admin_content(dvac_inform_only_ind=i2,dvac_invalid_data_ind=i2(ref)) = i2
 DECLARE drr_add_default_scd_row(null) = i2
 DECLARE drr_verify_custom_users(dvcu_inform_only_ind=i2,dvcu_invalid_cust_user_ind=i2(ref)) = i2
 DECLARE drr_drop_db_link(dddl_link_name=vc) = i2
 DECLARE drr_check_db_link(dcdl_in_db_link_name=vc,dcdl_out_db_link_fnd_ind=i2(ref)) = i2
 DECLARE drr_del_preserved_ts(dcdl_tgt_db_name=vc) = i2
 IF (validate(drr_clin_copy_ddl->dccd_cnt,1)=1
  AND validate(drr_clin_copy_ddl->dccd_cnt,2)=2)
  FREE RECORD drr_clin_copy_ddl
  RECORD drr_clin_copy_ddl(
    1 dccd_cnt = i4
    1 qual[*]
      2 dccd_op_type = vc
      2 dccd_priority = i4
      2 dccd_operation = vc
  )
 ENDIF
 IF (validate(drr_preserved_tables_data->cnt,1)=1
  AND validate(drr_preserved_tables_data->cnt,2)=2)
  FREE RECORD drr_preserved_tables_data
  RECORD drr_preserved_tables_data(
    1 refresh_ind = i2
    1 restore_groups_str = vc
    1 restore_foul = i2
    1 foul_grp_str = vc
    1 res_rep_name = vc
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 group = vc
      2 table_suffix = vc
      2 prefix = vc
      2 refresh_ind = i2
      2 tgtsch_idx = i4
      2 partial_ind = i2
      2 exp_where_clause = vc
      2 restore_in_phases = i2
      2 extra_src_cols = i2
      2 extra_pre_cols = i2
      2 pres_tbl_not_in_src = i2
      2 restore_foul = i2
      2 reason_cnt = i4
      2 restore_foul_reasons[*]
        3 text = vc
      2 long_cols_exist = i2
      2 col_diff = i2
      2 col_cnt = i4
      2 col[*]
        3 col_name = vc
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = vc
        3 diff_dtype_ind = i2
        3 diff_dlength_ind = i2
        3 diff_nullable_ind = i2
        3 diff_default_ind = i2
  )
  SET drr_preserved_tables_data->cnt = 0
  SET drr_preserved_tables_data->refresh_ind = 0
  SET drr_preserved_tables_data->restore_foul = 0
 ENDIF
 IF (validate(drr_group->cnt,1)=1
  AND validate(drr_group->cnt,2)=2)
  FREE RECORD drr_group
  RECORD drr_group(
    1 cnt = i4
    1 grp[*]
      2 group = vc
      2 restore = i2
      2 prompt_ind = i2
  )
 ENDIF
 IF (validate(drr_retain_db_users->cnt,1)=1
  AND validate(drr_retain_db_users->cnt,2)=2)
  FREE RECORD drr_retain_db_users
  RECORD drr_retain_db_users(
    1 cnt = i4
    1 user[*]
      2 user_name = vc
  )
  SET drr_retain_db_users->cnt = 0
 ENDIF
 IF (validate(drr_cleanup_warnings->cnt,1)=1
  AND validate(drr_cleanup_warnings->cnt,2)=2)
  RECORD drr_cleanup_warnings(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 message = vc
  )
  SET drr_cleanup_warnings->cnt = 0
 ENDIF
 IF (validate(drr_cleanup_drop_list->cnt,1)=1
  AND validate(drr_cleanup_drop_list->cnt,2)=2)
  RECORD drr_cleanup_drop_list(
    1 list_loaded_ind = i2
    1 cnt = i4
    1 qual[*]
      2 owner = vc
      2 table_name = vc
  )
 ENDIF
 IF (validate(drr_mvdrop_list->cnt,1)=1
  AND validate(drr_mvdrop_list->cnt,2)=2)
  RECORD drr_mvdrop_list(
    1 list_loaded_ind = i2
    1 cnt = i4
    1 qual[*]
      2 owner = vc
      2 mv_name = vc
  )
 ENDIF
 IF (validate(drr_custom_tables->cnt,1)=1
  AND validate(drr_custom_tables->cnt,2)=2)
  RECORD drr_custom_tables(
    1 list_loaded_ind = i2
    1 cnt = i4
    1 qual[*]
      2 owner_table = vc
      2 owner = vc
      2 table_name = vc
  )
 ENDIF
 IF ((validate(drr_ads_ext->table_cnt,- (1))=- (1))
  AND validate(drr_ads_ext->table_cnt,2)=2)
  FREE SET drr_ads_ext
  RECORD drr_ads_ext(
    1 tbl_cnt = i4
    1 sample_percent = i2
    1 config_id = f8
    1 tgt_p_word = vc
    1 tgt_connect_str = vc
    1 tbl[*]
      2 owner = vc
      2 table_name = vc
      2 deldups_ind = i2
      2 dupind_name = vc
      2 pk_col_cnt = i2
      2 pk_col[*]
        3 col_name = vc
      2 col_fnd = i2
      2 object_id = vc
      2 extract_cnt = i4
      2 nomove = i2
      2 move_all = i2
      2 ext[*]
        3 config_extract_id = f8
        3 extract_id = f8
        3 driver_extract_id = f8
        3 table_extract_nbr = i4
        3 table_extract_inst = i4
        3 active_ind = i2
        3 extract_method = vc
        3 apply_where_ind = i2
        3 data_class_type = vc
        3 where_clause = vc
        3 purge_where_clause = vc
        3 expimp_level = i4
        3 driver_table_ind = i2
        3 driver_table_name = vc
        3 driver_keycol_name = vc
        3 expimp_parent_table_name = vc
        3 dupdel_skip_ind = i2
        3 nomove = i2
  )
 ENDIF
 IF (validate(drr_preserve_db_users->cnt,1)=1
  AND validate(drr_preserve_db_users->cnt,2)=2)
  FREE RECORD drr_preserve_db_users
  RECORD drr_preserve_db_users(
    1 cnt = i4
    1 user[*]
      2 user_name = vc
  )
  SET drr_preserve_db_users->cnt = 0
 ENDIF
 IF ((validate(drr_priority_group_matrix->cnt,- (1))=- (1)))
  FREE RECORD drr_priority_group_matrix
  RECORD drr_priority_group_matrix(
    1 cnt = i2
    1 priority_group[*]
      2 group_name = vc
      2 priority_from_range = i4
      2 priority_to_range = i4
      2 group_prefix = c10
  )
  SET drr_priority_group_matrix->cnt = 0
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "EXPORTS"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 0
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range = 9
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ex"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "CREATE TABLES"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 9
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  100
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ct"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "IMPORTS"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 99
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  200
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "im"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "CREATE INDEXES"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 199
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  400
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ci"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "CREATE CONSTRAINTS"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 399
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  500
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "cc"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "RUN UTILITIES"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 699
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  800
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ru"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "ALL DDL"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 0
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  2000
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "all"
 ENDIF
 IF (validate(drr_clin_copy_data->temp_location,"-x")="-x"
  AND validate(drr_clin_copy_data->temp_location,"y")="y")
  FREE RECORD drr_clin_copy_data
  RECORD drr_clin_copy_data(
    1 temp_location = vc
    1 ref_par_file_cnt = i2
    1 mixed_tables_parfile_name = vc
    1 ind_mixed_parfile_prefix = vc
    1 exp_all_prefix = vc
    1 imp_all_prefix = vc
    1 exp_ref_prefix = vc
    1 imp_ref_prefix = vc
    1 exp_pts_prefix = vc
    1 imp_pts_prefix = vc
    1 export_rpt_name = vc
    1 import_rpt_name = vc
    1 starting_point = vc
    1 checkpoint_ind = i2
    1 exp_file_prefix = vc
    1 imp_file_prefix = vc
    1 create_truncate_cmds = i2
    1 src_was_ind = i2
    1 src_env_name = vc
    1 src_env_id = f8
    1 tgt_was_ind = i2
    1 tgt_env_name = vc
    1 tgt_db_env_name = vc
    1 tgt_env_id = f8
    1 exp_imp_utility_location = vc
    1 process = vc
    1 preserve_tbl_pre = vc
    1 preserve_sch_dt = vc
    1 summary_screen_issued = i2
    1 src_db_created = f8
    1 tgt_db_created = f8
    1 tgt_mock_env = i2
    1 exp_rdds_prefix = vc
    1 imp_rdds_prefix = vc
    1 standalone_expimp_process = i2
    1 licensed_to_ads = i2
    1 ads_chosen_ind = i2
    1 ads_config_id = f8
    1 ads_name = vc
    1 ads_mod_dt_tm = f8
    1 ads_pct = f8
    1 src_ads_ind = i2
    1 tgt_domain_name = vc
    1 src_domain_name = vc
    1 purge_chosen_ind = i2
    1 ddl_excl_rpt_name = vc
  )
  SET drr_clin_copy_data->process = "DM2NOTSET"
  SET drr_clin_copy_data->preserve_tbl_pre = "dm2_preserve_table"
  SET drr_clin_copy_data->preserve_sch_dt = "02022002"
  SET drr_clin_copy_data->summary_screen_issued = 0
  SET drr_clin_copy_data->temp_location = "DM2NOTSET"
  SET drr_clin_copy_data->ref_par_file_cnt = 0
  SET drr_clin_copy_data->mixed_tables_parfile_name = "dm2_mixed_tables.par"
  SET drr_clin_copy_data->ind_mixed_parfile_prefix = "dm2_mixtbl_"
  SET drr_clin_copy_data->exp_all_prefix = "exp_v500_all"
  SET drr_clin_copy_data->imp_all_prefix = "imp_v500_all"
  SET drr_clin_copy_data->exp_ref_prefix = "exp_v500_ref"
  SET drr_clin_copy_data->imp_ref_prefix = "imp_v500_ref"
  SET drr_clin_copy_data->exp_pts_prefix = "exp_v500_pts"
  SET drr_clin_copy_data->imp_pts_prefix = "imp_v500_pts"
  SET drr_clin_copy_data->exp_file_prefix = "dm2_export"
  SET drr_clin_copy_data->imp_file_prefix = "dm2_import"
  SET drr_clin_copy_data->starting_point = "DM2NOTSET"
  SET drr_clin_copy_data->src_env_name = "DM2NOTSET"
  SET drr_clin_copy_data->tgt_env_name = "DM2NOTSET"
  SET drr_clin_copy_data->tgt_db_env_name = "DM2NOTSET"
  SET drr_clin_copy_data->create_truncate_cmds = 0
  IF (validate(dm2_troubleshoot_replicate,1)=1
   AND validate(dm2_troubleshoot_replicate,2)=2)
   SET drr_clin_copy_data->checkpoint_ind = 0
  ELSE
   SET drr_clin_copy_data->checkpoint_ind = 1
  ENDIF
  SET drr_clin_copy_data->tgt_mock_env = 1
  SET drr_clin_copy_data->exp_rdds_prefix = "exp_v500_rdds"
  SET drr_clin_copy_data->imp_rdds_prefix = "imp_v500_rdds"
  SET drr_clin_copy_data->standalone_expimp_process = 0
  SET drr_clin_copy_data->ads_name = "DM2NOTSET"
  SET drr_clin_copy_data->src_was_ind = 0
  SET drr_clin_copy_data->tgt_was_ind = 0
  SET drr_clin_copy_data->ddl_excl_rpt_name = ""
 ENDIF
 IF (validate(drr_mixed_tables_data->cnt,1)=1
  AND validate(drr_mixed_tables_data->cnt,2)=2)
  FREE RECORD drr_mixed_tables_data
  RECORD drr_mixed_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 table_suffix = vc
      2 where_clause_cnt = i2
      2 qual[*]
        3 process_type = vc
        3 data_type = vc
        3 where_clause = vc
      2 prefix = vc
      2 num_rows = f8
      2 last_analyzed = dq8
      2 ref_num_rows_set_ind = i2
      2 ref_num_rows = f8
  )
  SET drr_mixed_tables_data->cnt = 0
 ENDIF
 IF (validate(drr_ignored_errors->cnt,1)=1
  AND validate(drr_ignored_errors->cnt,2)=2)
  FREE RECORD drr_ignored_errors
  RECORD drr_ignored_errors(
    1 cnt = i4
    1 drr_ignorable_errfile = vc
    1 qual[*]
      2 error = vc
  )
  SET drr_ignored_errors->cnt = 0
  SET drr_ignored_errors->drr_ignorable_errfile = "dm2_ignorable_errors.dat"
 ENDIF
 IF (validate(drr_errors_encountered->cmd_cnt,1)=1
  AND validate(drr_errors_encountered->cmd_cnt,2)=2)
  FREE RECORD drr_errors_encountered
  RECORD drr_errors_encountered(
    1 cmd_cnt = i4
    1 qual[*]
      2 dee_op_id = f8
      2 error_cnt = i4
      2 logfile_name = vc
      2 force_reset_ind = i2
      2 qual[*]
        3 error = vc
        3 error_desc = vc
  )
  SET drr_errors_encountered->cmd_cnt = 0
 ENDIF
 IF (validate(drr_ref_tables_data->cnt,1)=1
  AND validate(drr_ref_tables_data->cnt,2)=2)
  FREE RECORD drr_ref_tables_data
  RECORD drr_ref_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET drr_ref_tables_data->cnt = 0
 ENDIF
 IF (validate(drr_all_tables_data->cnt,1)=1
  AND validate(drr_all_tables_data->cnt,2)=2)
  FREE RECORD drr_all_tables_data
  RECORD drr_all_tables_data(
    1 par_file_cnt = i2
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET drr_all_tables_data->cnt = 0
  SET drr_all_tables_data->par_file_cnt = 0
 ENDIF
 IF (validate(drr_rdds_tables_data->cnt,1)=1
  AND validate(drr_rdds_tables_data->cnt,2)=2)
  FREE RECORD drr_rdds_tables_data
  RECORD drr_rdds_tables_data(
    1 par_file_cnt = i2
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET drr_rdds_tables_data->cnt = 0
  SET drr_rdds_tables_data->par_file_cnt = 0
 ENDIF
 IF ((validate(drr_env_hist_misc->cnt,- (1))=- (1))
  AND (validate(drr_env_hist_misc->cnt,- (2))=- (2)))
  FREE RECORD drr_env_hist_misc
  RECORD drr_env_hist_misc(
    1 path = vc
    1 summary_file = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 table_alias = vc
      2 csv_file_name = vc
      2 row_count = vc
      2 date = vc
      2 load = i2
  )
  SET drr_env_hist_misc->cnt = 0
  SET drr_env_hist_misc->path = "DM2NOTSET"
  SET drr_env_hist_misc->summary_file = "DM2NOTSET"
 ENDIF
 IF ((validate(drr_retry_imp_data->tbl_cnt,- (1))=- (1))
  AND (validate(drr_retry_imp_data->tbl_cnt,- (2))=- (2)))
  FREE RECORD drr_retry_imp_data
  RECORD drr_retry_imp_data(
    1 create_chunk_cmds = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 owner = vc
      2 table_name = vc
      2 op_type = vc
  )
 ENDIF
 IF ((validate(drr_chunk_imp_tbls->tbl_cnt,- (1))=- (1))
  AND (validate(drr_chunk_imp_tbls->tbl_cnt,- (2))=- (2)))
  FREE RECORD drr_chunk_imp_tbls
  RECORD drr_chunk_imp_tbls(
    1 tbl_cnt = i4
    1 tbl[*]
      2 owner = vc
      2 table_name = vc
      2 segment_name = vc
      2 part_ind = i2
      2 part_cnt = i4
      2 orig_num_chunks = i4
      2 num_chunks = i4
      2 chunk_cnt = i4
      2 chunks[*]
        3 min_rid = vc
        3 max_rid = vc
  )
 ENDIF
 SUBROUTINE drr_get_dmp_log_loc(dgdll_op_id,dgdll_dmp_loc_out)
   DECLARE dgdll_strt_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = concat("Find logfile for OP_ID:",build(dgdll_op_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.op_id=dgdll_op_id
    DETAIL
     dgdll_strt_pt = (findstring("log=",d.operation,1)+ 4), dgdll_end_pt = findstring(" ",d.operation,
      dgdll_strt_pt), dgdll_dmp_loc_out = substring(dgdll_strt_pt,(dgdll_end_pt - dgdll_strt_pt),d
      .operation)
     IF ((dm_err->debug_flag > 2))
      CALL echo(d.operation),
      CALL echo(dgdll_strt_pt),
      CALL echo(dgdll_end_pt),
      CALL echo(dgdll_dmp_loc_out)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dgdll_dmp_loc_out = "NOT_VALID_OP_ID"
   ELSE
    IF (dgdll_dmp_loc_out > " ")
     IF (findfile(dgdll_dmp_loc_out)=0)
      SET dgdll_dmp_loc_out = concat("NO_FILE_IN_OS:",dgdll_dmp_loc_out)
     ENDIF
    ELSE
     SET dgdll_dmp_loc_out = "NO_FILE_IN_COMMAND"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_ref_table_data(force_load_ind)
   DECLARE dlrtd_mix_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlrtd_ref_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlrtd_mix = i4 WITH protect, noconstant(0)
   DECLARE dlrtd_ref = i4 WITH protect, noconstant(0)
   IF ((drr_ref_tables_data->cnt > 0)
    AND force_load_ind=0)
    SET dm_err->eproc = "Skipping load of reference table list."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (drr_load_mixed_table_data(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading reference table list."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET drr_ref_tables_data->cnt = 0
   SET stat = alterlist(drr_ref_tables_data->tbl,drr_ref_tables_data->cnt)
   SELECT INTO "nl:"
    dut.table_name
    FROM dm_tables_doc dtd,
     dm2_user_tables dut
    PLAN (dtd
     WHERE dtd.table_name=dtd.full_table_name
      AND dtd.reference_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM user_mviews um
      WHERE um.mview_name=dut.table_name)))
      AND  NOT (dtd.table_name IN (
     (SELECT DISTINCT
      dt.drr_table_name
      FROM dm_table_relationships dt
      WHERE dt.drr_table_name="*DRR"
       AND dt.drr_flag=1))))
     JOIN (dut
     WHERE dut.table_name=dtd.table_name)
    ORDER BY dut.table_name
    DETAIL
     IF (locateval(dlrtd_mix_ndx,1,value(drr_mixed_tables_data->cnt),dut.table_name,
      drr_mixed_tables_data->tbl[dlrtd_mix_ndx].table_name)=0)
      drr_ref_tables_data->cnt = (drr_ref_tables_data->cnt+ 1)
      IF (mod(drr_ref_tables_data->cnt,2000)=1)
       stat = alterlist(drr_ref_tables_data->tbl,(drr_ref_tables_data->cnt+ 1999))
      ENDIF
      drr_ref_tables_data->tbl[drr_ref_tables_data->cnt].table_name = dut.table_name
     ELSE
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(dut.table_name),
        " is a mixed table and not loaded into Reference listing."))
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_ref_tables_data->tbl,drr_ref_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((validate(dm2_skip_cust_ref_tables,- (1))=- (1))
    AND (validate(dm2_skip_cust_ref_tables,- (2))=- (2)))
    SET dm_err->eproc = "Loading custom reference table list."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info i,
      dm2_user_tables u
     WHERE i.info_domain="DM2_CUST_REF_TABLES"
      AND i.info_name=u.table_name
     ORDER BY u.table_name
     HEAD REPORT
      dlrtd_mix_ndx = 0, dlrtd_ref_ndx = 0
     DETAIL
      dlrtd_mix = 0, dlrtd_ref = 0, dlrtd_mix = locateval(dlrtd_mix_ndx,1,value(drr_mixed_tables_data
        ->cnt),u.table_name,drr_mixed_tables_data->tbl[dlrtd_mix_ndx].table_name),
      dlrtd_ref = locateval(dlrtd_ref_ndx,1,value(drr_ref_tables_data->cnt),u.table_name,
       drr_ref_tables_data->tbl[dlrtd_ref_ndx].table_name)
      IF (dlrtd_mix=0
       AND dlrtd_ref=0)
       drr_ref_tables_data->cnt = (drr_ref_tables_data->cnt+ 1), stat = alterlist(drr_ref_tables_data
        ->tbl,drr_ref_tables_data->cnt), drr_ref_tables_data->tbl[drr_ref_tables_data->cnt].
       table_name = u.table_name
      ELSEIF (dlrtd_mix > 0)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dlrtd_mix = ",dlrtd_mix)),
        CALL echo(build("dlrtd_ref = ",dlrtd_ref)),
        CALL echo(concat(trim(u.table_name),
         " is a mixed table and not loaded into Reference listing."))
       ENDIF
      ELSEIF (dlrtd_ref > 0)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dlrtd_mix = ",dlrtd_mix)),
        CALL echo(build("dlrtd_ref = ",dlrtd_ref)),
        CALL echo(concat(trim(u.table_name)," is already in the Reference list."))
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_ref_tables_data->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Checking count of reference tables."
    SET dm_err->emsg = "No reference tables found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(drr_ref_tables_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_check_log_for_errors(dclfe_op_id,dclfe_oper_logfile,dclfe_force_load_ind,
  dclfe_err_ind)
   DECLARE dclfe_ndx = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_type = vc WITH protect, noconstant("")
   DECLARE dclfe_start = i4 WITH protect, noconstant(0)
   DECLARE dclfe_end = i4 WITH protect, noconstant(0)
   DECLARE dclfe_add_cmd = i2 WITH protect, noconstant(1)
   DECLARE dclfe_err_cnt = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_str = vc WITH protect, noconstant("")
   DECLARE dclfe_x = i4 WITH protect, noconstant(0)
   DECLARE dclfe_start = i4 WITH protect, noconstant(0)
   DECLARE dclfe_end = i4 WITH protect, noconstant(0)
   DECLARE dclfe_length = i4 WITH protect, noconstant(0)
   DECLARE dclfe_error = vc WITH protect, noconstant(" ")
   DECLARE dclfe_err_msg = vc WITH protect, noconstant("")
   DECLARE dclfe_err_msg_length = i4 WITH protect, noconstant(0)
   IF (dclfe_force_load_ind != 2)
    SET dm_err->eproc = "Check if ignorable errors file exists."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    IF (findfile(value(drr_ignored_errors->drr_ignorable_errfile)) > 0)
     SET dm_err->eproc = "Load ignorable errors."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     FREE DEFINE rtl2
     DEFINE rtl2 value(drr_ignored_errors->drr_ignorable_errfile)
     SELECT INTO "nl:"
      FROM rtl2t t
      WHERE t.line > " "
      HEAD REPORT
       drr_ignored_errors->cnt = 0
      DETAIL
       drr_ignored_errors->cnt = (drr_ignored_errors->cnt+ 1)
       IF (mod(drr_ignored_errors->cnt,10)=1)
        stat = alterlist(drr_ignored_errors->qual,(drr_ignored_errors->cnt+ 9))
       ENDIF
       drr_ignored_errors->qual[drr_ignored_errors->cnt].error = trim(t.line)
      FOOT REPORT
       stat = alterlist(drr_ignored_errors->qual,drr_ignored_errors->cnt)
      WITH nocounter
     ;end select
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(drr_ignored_errors)
    ENDIF
   ENDIF
   IF (((dclfe_force_load_ind=2
    AND dclfe_op_id=0) OR (dclfe_force_load_ind=1)) )
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = "Resetting error structure due to force load ind."
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    FOR (dclfe_err_cnt = 1 TO size(drr_errors_encountered->qual,5))
      SET stat = alterlist(drr_errors_encountered->qual[dclfe_err_cnt].qual,0)
    ENDFOR
    SET stat = alterlist(drr_errors_encountered->qual,0)
    SET dclfe_err_cnt = 0
    SET drr_errors_encountered->cmd_cnt = 0
   ENDIF
   IF (dclfe_force_load_ind=2
    AND dclfe_op_id > 0)
    SET dm_err->eproc = "Check Operation Error Message from DM2_DDL_OPS_LOG for Errors."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.op_id=dclfe_op_id
     DETAIL
      dclfe_err_msg = trim(d.error_msg,3), dclfe_err_msg_length = size(dclfe_err_msg)
      FOR (dclfe_x = 1 TO dclfe_err_msg_length)
        dclfe_start = (findstring("<<<",dclfe_err_msg,dclfe_x)+ 3), dclfe_end = (findstring(">>>",
         dclfe_err_msg,dclfe_x) - 1), dclfe_length = ((dclfe_end - dclfe_start)+ 1)
        IF (((dclfe_x+ 3) > dclfe_err_msg_length))
         dclfe_x = dclfe_err_msg_length
        ELSE
         dclfe_x = (dclfe_end+ 3)
        ENDIF
        dclfe_error = substring(dclfe_start,dclfe_length,dclfe_err_msg)
        IF ((dm_err->debug_flag > 2))
         CALL echo(concat("dclfe_error = ",dclfe_error))
        ENDIF
        dclfe_err_type = "", dclfe_ndx = 0, dclfe_start = 0,
        dclfe_end = 0, dclfe_err_str = ""
        IF (findstring("ORA-",dclfe_error,0) > 0)
         dclfe_err_type = "ORA-"
        ELSEIF (findstring("EXP-",dclfe_error,0) > 0)
         dclfe_err_type = "EXP-"
        ELSEIF (findstring("IMP-",dclfe_error,0) > 0)
         dclfe_err_type = "IMP-"
        ELSEIF (findstring("LRM-",dclfe_error,0) > 0)
         dclfe_err_type = "LRM-"
        ELSEIF (findstring("CER-",dclfe_error,0) > 0)
         dclfe_err_type = "CER-"
        ELSEIF (findstring("UDI-",dclfe_error,0) > 0)
         dclfe_err_type = "UDI-"
        ENDIF
        IF ((dm_err->debug_flag > 2))
         CALL echo(concat("dclfe_err_type = ",dclfe_err_type))
        ENDIF
        IF (dclfe_err_type > "")
         dclfe_start = findstring(dclfe_err_type,dclfe_error,0), dclfe_end = findstring(" ",
          dclfe_error,dclfe_start), dclfe_err_str = substring(dclfe_start,((dclfe_end - dclfe_start)
           - 1),dclfe_error)
         IF (dclfe_add_cmd=1)
          dclfe_err_ind = 1, drr_errors_encountered->cmd_cnt = (drr_errors_encountered->cmd_cnt+ 1),
          stat = alterlist(drr_errors_encountered->qual,drr_errors_encountered->cmd_cnt),
          drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].logfile_name =
          dclfe_oper_logfile, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].dee_op_id
           = dclfe_op_id
          IF (dclfe_err_str="*EXP-00002*"
           AND d.parent_execution_order=1)
           drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].force_reset_ind = 1
          ENDIF
          dclfe_add_cmd = 0
         ENDIF
         dclfe_ndx = 0
         IF (locateval(dclfe_ndx,1,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].
          error_cnt,dclfe_err_str,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
          dclfe_ndx].error)=0)
          dclfe_err_cnt = (dclfe_err_cnt+ 1), drr_errors_encountered->qual[drr_errors_encountered->
          cmd_cnt].error_cnt = dclfe_err_cnt, stat = alterlist(drr_errors_encountered->qual[
           drr_errors_encountered->cmd_cnt].qual,dclfe_err_cnt),
          drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[dclfe_err_cnt].error =
          dclfe_err_str, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
          dclfe_err_cnt].error_desc = substring(dclfe_end,(size(trim(d.error_msg)) - dclfe_end),
           dclfe_error)
          IF (dclfe_err_str="*EXP-00002*"
           AND d.parent_execution_order=1)
           drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].force_reset_ind = 1
          ENDIF
         ELSE
          IF ((dm_err->debug_flag > 0))
           CALL echo(concat("Skipped ",dclfe_err_str," because already in list."))
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    IF ((dm_err->debug_flag > 721))
     CALL echorecord(drr_errors_encountered)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF (dclfe_force_load_ind != 2)
    SET dm_err->eproc = "Check Operation Logfile for Errors."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    FREE DEFINE rtl2
    SET logical dclfe_operlogfile_logical dclfe_oper_logfile
    DEFINE rtl2 "dclfe_operlogfile_logical"
    SELECT INTO "nl:"
     FROM rtl2t t
     WHERE t.line > " "
     DETAIL
      dclfe_err_type = "", dclfe_ndx = 0, dclfe_start = 0,
      dclfe_end = 0, dclfe_err_str = ""
      IF (findstring("ORA-",t.line,0) > 0)
       dclfe_err_type = "ORA-"
      ELSEIF (findstring("EXP-",t.line,0) > 0)
       dclfe_err_type = "EXP-"
      ELSEIF (findstring("IMP-",t.line,0) > 0)
       dclfe_err_type = "IMP-"
      ELSEIF (findstring("LRM-",t.line,0) > 0)
       dclfe_err_type = "LRM-"
      ELSEIF (findstring("LOG FILE NOT FOUND",t.line,0) > 0)
       dclfe_err_type = "OTHER"
      ENDIF
      IF (dclfe_err_type > "")
       IF (dclfe_err_type="OTHER")
        dclfe_err_str = "", dclfe_end = 1
       ELSE
        dclfe_start = findstring(dclfe_err_type,t.line,0), dclfe_end = findstring(" ",t.line,
         dclfe_start), dclfe_err_str = substring(dclfe_start,((dclfe_end - dclfe_start) - 1),t.line)
       ENDIF
       dclfe_ndx = 0
       IF (locateval(dclfe_ndx,1,drr_ignored_errors->cnt,dclfe_err_str,drr_ignored_errors->qual[
        dclfe_ndx].error)=0)
        IF (dclfe_add_cmd=1)
         dclfe_err_ind = 1, drr_errors_encountered->cmd_cnt = (drr_errors_encountered->cmd_cnt+ 1),
         stat = alterlist(drr_errors_encountered->qual,drr_errors_encountered->cmd_cnt),
         drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].logfile_name =
         dclfe_oper_logfile, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].dee_op_id
          = dclfe_op_id, dclfe_add_cmd = 0
        ENDIF
        dclfe_ndx = 0
        IF (locateval(dclfe_ndx,1,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].
         error_cnt,dclfe_err_str,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
         dclfe_ndx].error)=0)
         dclfe_err_cnt = (dclfe_err_cnt+ 1), drr_errors_encountered->qual[drr_errors_encountered->
         cmd_cnt].error_cnt = dclfe_err_cnt, stat = alterlist(drr_errors_encountered->qual[
          drr_errors_encountered->cmd_cnt].qual,dclfe_err_cnt),
         drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[dclfe_err_cnt].error =
         dclfe_err_str, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
         dclfe_err_cnt].error_desc = substring(dclfe_end,(size(trim(t.line)) - dclfe_end),t.line)
        ELSE
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("Skipped ",dclfe_err_str," because already in list."))
         ENDIF
        ENDIF
       ELSE
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("Ignored error:",drr_ignored_errors->qual[dclfe_ndx].error," from file:",
          dclfe_oper_logfile))
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF ((dm_err->debug_flag > 721))
     CALL echorecord(drr_errors_encountered)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_mixed_table_data(dlmtd_force_load_ind)
   DECLARE dlmtd_start = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_end = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_qual_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get mixed tables"
   IF ((drr_mixed_tables_data->cnt > 0)
    AND dlmtd_force_load_ind=0)
    RETURN(1)
   ENDIF
   SET drr_mixed_tables_data->cnt = 0
   SET stat = alterlist(drr_mixed_tables_data->tbl,0)
   SELECT INTO "nl:"
    FROM dm_info di,
     dm_user_tables_actual_stats dut,
     dm_tables_doc dtd
    PLAN (di
     WHERE di.info_domain="DM2_MIXED_TABLE-*")
     JOIN (dut
     WHERE di.info_name=dut.table_name)
     JOIN (dtd
     WHERE dut.table_name=dtd.table_name)
    ORDER BY di.info_name
    HEAD di.info_name
     drr_mixed_tables_data->cnt = (drr_mixed_tables_data->cnt+ 1)
     IF (mod(drr_mixed_tables_data->cnt,10)=1)
      stat = alterlist(drr_mixed_tables_data->tbl,(drr_mixed_tables_data->cnt+ 9))
     ENDIF
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].table_name = di.info_name,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].table_suffix = dtd.table_suffix,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].prefix = cnvtlower(build(
       drr_clin_copy_data->ind_mixed_parfile_prefix,dtd.table_suffix)),
     dlmtd_qual_cnt = 0, drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].num_rows = dut
     .num_rows, drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].last_analyzed = dut
     .last_analyzed,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].ref_num_rows_set_ind = 0,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].ref_num_rows = 0.0
    DETAIL
     dlmtd_qual_cnt = (dlmtd_qual_cnt+ 1)
     IF (mod(dlmtd_qual_cnt,10)=1)
      stat = alterlist(drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual,(dlmtd_qual_cnt+ 9
       ))
     ENDIF
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].where_clause = di
     .info_char, dlmtd_start = 0, dlmtd_end = 0,
     dlmtd_start = (findstring("-",trim(di.info_domain),0)+ 1), dlmtd_end = findstring("-",trim(di
       .info_domain),dlmtd_start,1), drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual[
     dlmtd_qual_cnt].process_type = substring(dlmtd_start,(dlmtd_end - dlmtd_start),di.info_domain),
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].data_type =
     substring((dlmtd_end+ 1),(size(trim(di.info_domain)) - dlmtd_start),trim(di.info_domain))
    FOOT  di.info_name
     stat = alterlist(drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual,dlmtd_qual_cnt),
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].where_clause_cnt = dlmtd_qual_cnt
    FOOT REPORT
     stat = alterlist(drr_mixed_tables_data->tbl,drr_mixed_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Mixed Tables Exist in DM_INFO."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(drr_mixed_tables_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_exp_dmp_loc(dgedl_dmp_loc_out)
   DECLARE dgedl_strt_pt = i4 WITH protect, noconstant(0)
   DECLARE dgedl_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dgedl_str = vc WITH protect, noconstant(" ")
   DECLARE dgedl_file_delim = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgedl_file_delim = "]"
   ELSE
    SET dgedl_file_delim = "/"
   ENDIF
   SET dgedl_dmp_loc_out = "NONE"
   SET dm_err->eproc = "Verify existance of DDL Ops tables in prep for previous exp location check."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables u
    WHERE u.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual != 2)
    RETURN(1)
   ENDIF
   IF ((drr_clin_copy_data->process="RESTORE")
    AND (dm2_install_schema->run_id=0))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for prior export to grab location."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT
    IF ((drr_clin_copy_data->process="RESTORE")
     AND (dm2_install_schema->run_id > 0))
     FROM dm2_ddl_ops_log d
     WHERE (d.run_id=dm2_install_schema->run_id)
      AND d.op_type="IMPORT*"
      AND d.op_type != "*(REMOTE)*"
    ELSE
     FROM dm2_ddl_ops_log d
     WHERE d.op_type="EXPORT*"
      AND d.op_type != "*(REMOTE)*"
    ENDIF
    INTO "nl:"
    ORDER BY d.run_id DESC
    HEAD d.run_id
     dgedl_strt_pt = (findstring("file=",d.operation,1)+ 5), dgedl_end_pt = findstring(" ",d
      .operation,dgedl_strt_pt), dgedl_str = substring(dgedl_strt_pt,(dgedl_end_pt - dgedl_strt_pt),d
      .operation),
     dgedl_strt_pt = 0, dgedl_end_pt = 0, dgedl_end_pt = findstring(dgedl_file_delim,dgedl_str,1,1),
     dgedl_dmp_loc_out = substring(dgedl_strt_pt,(dgedl_end_pt - dgedl_strt_pt),dgedl_str)
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgedl_dmp_loc_out != "NONE")
    IF (findfile(dgedl_dmp_loc_out)=0)
     SET dgedl_dmp_loc_out = "NONE"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_val_write_privs(dvwp_full_dir)
   DECLARE full_fname = vc WITH protect
   IF (get_unique_file("dm2wrtprvtst",".dat")=0)
    RETURN(0)
   ENDIF
   SET full_fname = build(dvwp_full_dir,cnvtlower(dm_err->unique_fname))
   SELECT INTO value(full_fname)
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test of writing to ", dvwp_full_dir
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat("del ",dvwp_full_dir,cnvtlower(dm_err->unique_fname),";"))=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_push_dcl(concat("rm ",dvwp_full_dir,cnvtlower(dm_err->unique_fname)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_clin_copy_restart_chk(null)
   DECLARE dccrc_run_id = f8 WITH protect, noconstant(0.0)
   DECLARE dccrc_schema_date = f8 WITH protect, noconstant(0.0)
   DECLARE dccrc_ops_complete = i2 WITH protect, noconstant(0)
   DECLARE dccrc_ops_tbl_fnd = i2 WITH protect, noconstant(0)
   DECLARE dccrc_ops_log_tbl_fnd = i2 WITH protect, noconstant(0)
   DECLARE dccrc_running_ind = i2 WITH protect, noconstant(0)
   DECLARE dccrc_mig_dbx_tab_cnt = i2 WITH protect, noconstant(0)
   IF ((drr_clin_copy_data->starting_point != "DM2NOTSET"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check status of DDL tables"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables u
    WHERE u.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
    DETAIL
     IF (u.table_name="DM2_DDL_OPS1")
      dccrc_ops_tbl_fnd = 1
     ELSE
      dccrc_ops_log_tbl_fnd = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dccrc_ops_log_tbl_fnd=1)
    IF (dm2_cleanup_stranded_appl(null)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Get max Clin Copy run id from Target and determine if any are RUNNING."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.run_id IN (
     (SELECT
      max(r.run_id)
      FROM dm2_ddl_ops r
      WHERE r.process_option="CLIN COPY*"
       AND (r.run_id > dm2_install_schema->src_run_id)))
      AND d.status="RUNNING"
     DETAIL
      dccrc_running_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process="RESTORE"))
    IF (((dccrc_ops_tbl_fnd=0) OR (dccrc_ops_log_tbl_fnd=0)) )
     SET dm_err->emsg = "Error:Missing one or both DDL tables"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc =
    "Get max Clin Copy run id from Target that is greater than Source Clin Copy run id."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops d
     WHERE d.run_id IN (
     (SELECT
      max(r.run_id)
      FROM dm2_ddl_ops r
      WHERE r.process_option="CLIN COPY*"
       AND (r.run_id > dm2_install_schema->src_run_id)))
     DETAIL
      dccrc_run_id = d.run_id, dccrc_schema_date = d.schema_date
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ENDIF
    SET dm_err->eproc = build("Find operations for run id ",dccrc_run_id)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.run_id=dccrc_run_id
     DETAIL
      IF (d.status="COMPLETE")
       dccrc_ops_complete = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dccrc_ops_complete=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     IF (dccrc_running_ind=1)
      SET dm_err->eproc = concat("Replicate to be restarted - (Run Id ",trim(cnvtstring(dccrc_run_id)
        ),").  Checking for RUNNING operations.")
      SET dm_err->emsg = "Cannot start process from beginning, operations still in RUNNING status."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dm_err->eproc = build("Delete ops for Clin Copy run id ",dccrc_run_id)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      DELETE  FROM dm2_ddl_ops_log a
       WHERE a.run_id=dccrc_run_id
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dm_err->eproc = build("Delete from DM2_DDL_OPS for Clin Copy run id ",dm2_install_schema->
      run_id)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm2_ddl_ops
      WHERE run_id=dccrc_run_id
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     RETURN(1)
    ELSE
     SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
     SET dm2_install_schema->run_id = dccrc_run_id
     SET dm2_install_schema->schema_prefix = "dm2s"
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(dccrc_schema_date,"MM/DD/YYYY;;D"))
    ENDIF
   ELSEIF ((drr_clin_copy_data->process="PRESERVE"))
    IF (((dccrc_ops_tbl_fnd=0) OR (dccrc_ops_log_tbl_fnd=0)) )
     SET dm_err->emsg = "Error:Missing one or both DDL tables"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Get Clin Copy-Preserve run id from Target."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops d
     WHERE d.process_option="CLIN COPY-PRESERVE"
     DETAIL
      dccrc_run_id = d.run_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0
     AND (der_expimp_data->preserve_from_begin=1))
     IF (dccrc_running_ind=1)
      SET dm_err->eproc = concat("Replicate to be restarted - (Run Id ",trim(cnvtstring(dccrc_run_id)
        ),").  Checking for RUNNING operations.")
      SET dm_err->emsg = "Cannot start process from beginning, operations still in RUNNING status."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Delete Clin Copy-Preserve DM2_DDL_OPS_LOG rows."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm2_ddl_ops_log d
      WHERE (d.run_id=
      (SELECT
       a.run_id
       FROM dm2_ddl_ops a
       WHERE a.process_option="CLIN COPY-PRESERVE"))
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     SET dm_err->eproc = "Delete Clin Copy-Preserve DM2_DDL_OPS rows."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm2_ddl_ops d
      WHERE d.process_option="CLIN COPY-PRESERVE"
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ELSEIF (curqual > 0
     AND (der_expimp_data->preserve_from_begin=0))
     SET dm2_install_schema->run_id = dccrc_run_id
     SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
     RETURN(1)
    ELSE
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ENDIF
   ELSE
    IF ((drr_clin_copy_data->process="MIGRATION")
     AND validate(dm2_mig_dbx_in_use,- (1))=1)
     SET dm_err->eproc = "Check if DBX tables exist"
     SELECT INTO "nl:"
      dbx_tab_cnt = count(*)
      FROM dba_tables
      WHERE owner="DBX"
       AND table_name="DBX_OPS"
      DETAIL
       dccrc_mig_dbx_tab_cnt = dbx_tab_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dccrc_mig_dbx_tab_cnt > 0)
      SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
      RETURN(1)
     ELSE
      SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
      RETURN(1)
     ENDIF
    ENDIF
    IF (((dccrc_ops_tbl_fnd=0) OR (dccrc_ops_log_tbl_fnd=0)) )
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ELSEIF (dccrc_ops_tbl_fnd=1
     AND dccrc_ops_log_tbl_fnd=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ELSEIF (dccrc_ops_tbl_fnd=0
     AND dccrc_ops_log_tbl_fnd=1)
     SET dm_err->emsg = "Error:Only DM2_DDL_OPS_LOG exists"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drr_get_max_clin_copy_run_id(dccrc_run_id)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Check for completed operations other than export ops"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT
     IF ((drr_clin_copy_data->process="MIGRATION"))
      FROM dm2_ddl_ops_log d
      WHERE d.run_id=dccrc_run_id
       AND d.op_type="CREATE TABLE"
       AND d.status IN ("COMPLETE", "RUNNING")
     ELSE
      FROM dm2_ddl_ops_log d
      WHERE d.run_id=dccrc_run_id
       AND d.op_type != "*EXPORT*"
       AND d.status IN ("COMPLETE", "RUNNING")
     ENDIF
     INTO "nl:"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     IF (dccrc_running_ind=1)
      SET dm_err->eproc = concat("Replicate to be restarted - (Run Id ",trim(cnvtstring(dccrc_run_id)
        ),").  Checking for RUNNING operations.")
      SET dm_err->emsg = "Cannot start process from beginning, operations still in RUNNING status."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     RETURN(1)
    ELSE
     SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
     SET dm2_install_schema->run_id = dccrc_run_id
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for import ops which have failed (except for expired applid)"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.run_id=dccrc_run_id
     AND d.op_type="IMPORT*"
     AND d.op_type != "*(REMOTE)*"
     AND d.status="ERROR"
     AND  NOT (substring(1,14,d.error_msg)="Application Id")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET drr_clin_copy_data->create_truncate_cmds = 1
   ENDIF
   SET dm_err->eproc = "Check for refresh process ddl rows"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.run_id=dccrc_run_id
     AND d.op_type="*PRESERVED DATA*"
     AND (( NOT (substring(1,14,d.error_msg)="Application Id")) OR (d.error_msg=null))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET drr_preserved_tables_data->refresh_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_clin_copy_setup(dccs_whereto)
   DECLARE dccs_exp_loc = vc WITH protect, noconstant("")
   DECLARE dccs_src_dbase_name = vc WITH protect, noconstant("")
   DECLARE dccs_log_prefix = vc WITH protect, noconstant("")
   DECLARE dccs_tgt_dbase_name = vc WITH protect, noconstant("")
   DECLARE dccs_ndx = i4 WITH protect, noconstant(0)
   DECLARE dccs_src_created_date = f8 WITH protect, noconstant(0.0)
   DECLARE dccs_tgt_created_date = f8 WITH protect, noconstant(0.0)
   DECLARE dccs_run_id = f8 WITH protect, noconstant(0.0)
   DECLARE dccs_row = i4 WITH protect, noconstant(0)
   DECLARE dccs_admin_dminfo_name = vc WITH protect, noconstant("")
   DECLARE dccs_ads_domain_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_refresh_row = i4 WITH protect, noconstant(0)
   DECLARE dccs_response = c1 WITH protect, noconstant(" ")
   DECLARE dccs_tgt_host = vc WITH protect, noconstant(" ")
   DECLARE dccs_str = vc WITH protect, noconstant("")
   DECLARE dccs_ret = vc WITH protect, noconstant("")
   DECLARE dccs_slash = vc WITH protect, noconstant("\\")
   DECLARE dccs_file = vc WITH protect, noconstant("")
   DECLARE misc_data_item = vc WITH protect, noconstant("")
   DECLARE misc_data_item_value = vc WITH protect, noconstant("")
   DECLARE dccs_reg_file = vc WITH protect, noconstant("")
   DECLARE dccs_cmd = vc WITH protect, noconstant("")
   DECLARE dccs_restore = vc WITH protect, noconstant("")
   DECLARE dccs_was_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_src_host = vc WITH protect, noconstant("")
   DECLARE dccs_part_enabled_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_part_usage_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_tgt_ora_ver = i2 WITH protect, noconstant(0)
   FREE RECORD dccs_env
   RECORD dccs_env(
     1 env_cnt = i4
     1 qual[*]
       2 env_name = vc
       2 env_id = f8
       2 database_name = vc
   )
   FREE RECORD dccs_data_move
   RECORD dccs_data_move(
     1 cnt = i4
     1 qual[*]
       2 name = vc
       2 desc = vc
   )
   SET dccs_data_move->cnt = 4
   SET stat = alterlist(dccs_data_move->qual,4)
   SET dccs_data_move->qual[1].name = "REF"
   SET dccs_data_move->qual[1].desc = "Reference Data Only"
   SET dccs_data_move->qual[2].name = "ALL"
   SET dccs_data_move->qual[2].desc = "Reference and Activity Data"
   SET dccs_data_move->qual[3].name = "ADS"
   SET dccs_data_move->qual[3].desc = "Reference with Activity Data Sample"
   SET dccs_data_move->qual[4].name = "PRG"
   SET dccs_data_move->qual[4].desc = "Activity Data Purge"
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dm2_install_schema->cdba_p_word = drrr_rf_data->adm_db_user_pwd
    SET dm2_install_schema->cdba_connect_str = drrr_rf_data->adm_db_cnct_str
    SET dm2_install_schema->src_v500_p_word = drrr_rf_data->src_db_user_pwd
    SET dm2_install_schema->src_v500_connect_str = drrr_rf_data->src_db_cnct_str
    SET drr_clin_copy_data->src_domain_name = drrr_rf_data->src_domain_name
    SET dm2_install_schema->v500_p_word = drrr_rf_data->tgt_db_user_pwd
    SET dm2_install_schema->v500_connect_str = drrr_rf_data->tgt_db_cnct_str
    SET dm2_install_schema->schema_prefix = "dm2s"
    SET dm2_install_schema->file_prefix = cnvtalphanum(drrr_rf_data->tgt_capture_schema_date)
    IF ((drrr_rf_data->tgt_db_copy_type="ALTERNATE"))
     SET dm2_install_schema->data_to_move = "ALL"
     SET drr_clin_copy_data->process = "RESTORE"
    ELSEIF ((drrr_rf_data->tgt_db_copy_type="REFERENCE"))
     SET dm2_install_schema->data_to_move = "REF"
    ELSEIF ((drrr_rf_data->tgt_db_copy_type="ALL"))
     SET dm2_install_schema->data_to_move = "ALL"
    ELSEIF ((drrr_rf_data->tgt_db_copy_type="ADS"))
     SET dm2_install_schema->data_to_move = "ADS"
    ENDIF
    SET drr_clin_copy_data->tgt_env_name = cnvtupper(drrr_rf_data->tgt_env_name)
    SET drr_clin_copy_data->tgt_db_env_name = cnvtupper(drrr_rf_data->tgt_db_env_name)
    SET dm2_install_schema->percent_tspace = drrr_rf_data->tgt_tspace_increase_pct
    IF ((drrr_rf_data->tgt_db_copy_type="ALTERNATE"))
     SET dm2_install_schema->percent_tspace = 10
    ENDIF
    SET drr_clin_copy_data->temp_location = drrr_rf_data->tgt_app_temp_dir
    IF (findstring(drr_clin_copy_data->tgt_env_name,drr_clin_copy_data->temp_location,1,0)=0)
     SET drr_clin_copy_data->temp_location = concat(drr_clin_copy_data->temp_location,cnvtlower(
       drr_clin_copy_data->tgt_env_name),"/")
    ENDIF
    SET dccs_restore = evaluate(drrr_rf_data->tgt_restore_preserve_data,"YES","Y","N")
    SET drr_clin_copy_data->tgt_mock_env = 1
   ENDIF
   SET dm_err->eproc = "ADMIN CONNECTION"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm2_install_schema->dbase_name = "ADMIN"
   SET dm2_install_schema->u_name = "CDBA"
   IF ((drr_clin_copy_data->process="MIGRATION")
    AND validate(dmr_mig_data->adm_cdba_pwd,"DM2NOTSET") != "DM2NOTSET"
    AND validate(dmr_mig_data->adm_cdba_cnct_str,"DM2NOTSET") != "DM2NOTSET")
    SET dm2_install_schema->p_word = dmr_mig_data->adm_cdba_pwd
    SET dm2_install_schema->connect_str = dmr_mig_data->adm_cdba_cnct_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
   ELSEIF ((dm2_install_schema->cdba_p_word != "NONE")
    AND (dm2_install_schema->cdba_connect_str != "NONE"))
    SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
   ENDIF
   SET dm_err->eproc = "Populate environemnt listing while connected to admin."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment d
    ORDER BY d.environment_id DESC
    DETAIL
     dccs_env->env_cnt = (dccs_env->env_cnt+ 1), stat = alterlist(dccs_env->qual,dccs_env->env_cnt),
     dccs_env->qual[dccs_env->env_cnt].env_name = cnvtupper(d.environment_name),
     dccs_env->qual[dccs_env->env_cnt].env_id = d.environment_id, dccs_env->qual[dccs_env->env_cnt].
     database_name = d.database_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "SOURCE CONNECTION"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm2_install_schema->dbase_name = '"SOURCE"'
   SET dm2_install_schema->u_name = "V500"
   IF ((drr_clin_copy_data->process="MIGRATION")
    AND validate(dmr_mig_data->src_v500_pwd,"DM2NOTSET") != "DM2NOTSET"
    AND validate(dmr_mig_data->src_v500_cnct_str,"DM2NOTSET") != "DM2NOTSET")
    SET dm2_install_schema->p_word = dmr_mig_data->src_v500_pwd
    SET dm2_install_schema->connect_str = dmr_mig_data->src_v500_cnct_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
   ELSEIF ((dm2_install_schema->src_v500_p_word != "NONE")
    AND (dm2_install_schema->src_v500_connect_str != "NONE"))
    SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
   ENDIF
   IF ((dm2_db_options->load_ind=0))
    EXECUTE dm2_set_db_options
    IF ((dm_err->err_ind > 0))
     RETURN(0)
    ENDIF
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
     drr_clin_copy_data->src_env_name = cnvtupper(de.environment_name), drr_clin_copy_data->
     src_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dccs_src_dbase_name = currdbname
   SET dm2_install_schema->src_dbase_name = dccs_src_dbase_name
   IF (drr_get_dbase_created_date(dccs_src_created_date)=0)
    RETURN(0)
   ENDIF
   SET drr_clin_copy_data->src_db_created = dccs_src_created_date
   SET dm_err->eproc = "Get Source node name"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$instance v
    DETAIL
     dccs_src_host = v.host_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_get_max_clin_copy_run_id(dccs_run_id)=0)
    RETURN(0)
   ENDIF
   SET dm2_install_schema->src_run_id = dccs_run_id
   SET dm_err->eproc = "Check if source has partitioning option enabled and has partitioned objects."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dpr_identify_partition_usage(1,dccs_part_enabled_ind,dccs_part_usage_ind)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "TARGET CONNECTION."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm2_install_schema->dbase_name = '"TARGET"'
   SET dm2_install_schema->u_name = "V500"
   IF ((drr_clin_copy_data->process="MIGRATION")
    AND validate(dmr_mig_data->tgt_v500_pwd,"DM2NOTSET") != "DM2NOTSET"
    AND validate(dmr_mig_data->tgt_v500_cnct_str,"DM2NOTSET") != "DM2NOTSET")
    SET dm2_install_schema->p_word = dmr_mig_data->tgt_v500_pwd
    SET dm2_install_schema->connect_str = dmr_mig_data->tgt_v500_cnct_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
   ELSEIF ((dm2_install_schema->v500_p_word != "NONE")
    AND (dm2_install_schema->v500_connect_str != "NONE"))
    SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
   ENDIF
   SET dm_err->eproc = "Validate Database Connect Information"
   SET dccs_tgt_dbase_name = currdbname
   SET dm2_install_schema->target_dbase_name = dccs_tgt_dbase_name
   IF (dccs_tgt_dbase_name=dccs_src_dbase_name
    AND (validate(dm2_allow_same_db_name,- (1))=- (1)))
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Source:",dccs_src_dbase_name," and Target:",trim(dccs_tgt_dbase_name),
     " databases may not be the same.")
    SET dm2_install_schema->p_word = "NONE"
    SET dm2_install_schema->v500_p_word = "NONE"
    SET dm2_install_schema->v500_connect_str = "NONE"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_get_dbase_created_date(dccs_tgt_created_date)=0)
    RETURN(0)
   ENDIF
   SET drr_clin_copy_data->tgt_db_created = dccs_tgt_created_date
   SET dccs_tgt_ora_ver = dm2_rdbms_version->level1
   SET dm_err->eproc = concat("Get Target node name")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM v$instance v
    DETAIL
     dccs_tgt_host = v.host_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dccs_part_usage_ind=1)
    SET dm_err->eproc = "Check if target partitioning option is enabled."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dpr_identify_partition_usage(0,dccs_part_enabled_ind,dccs_part_usage_ind)=0)
     RETURN(0)
    ENDIF
    IF (dccs_part_enabled_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(
      "Target partitioning option (v$option) is disabled and Source has partitioned objects. ",
      "Partitioning must be enabled in Target to proceed.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dccs_ndx = locateval(dccs_ndx,1,size(dccs_env->qual,5),cnvtupper(drr_clin_copy_data->
      tgt_db_env_name),dccs_env->qual[dccs_ndx].env_name)
    IF (dccs_ndx=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Unable to obtain environment_id for environment_name:",cnvtupper(
       drr_clin_copy_data->tgt_db_env_name))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET drr_clin_copy_data->tgt_env_id = dccs_env->qual[dccs_ndx].env_id
    ENDIF
   ELSE
    SET dm_err->eproc = "Get environment name via environment logical"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET drr_clin_copy_data->tgt_env_name = cnvtupper(logical("environment"))
    IF ((dm_err->debug_flag=722))
     SET message = nowindow
    ELSE
     SET message = window
    ENDIF
    CALL clear(1,1)
    CALL box(1,1,5,131)
    CALL text(3,8,"Enter TARGET environment name :                  ")
    SET help =
    SELECT INTO "nl:"
     environment_name____________ = dccs_env->qual[d.seq].env_name
     FROM (dummyt d  WITH seq = size(dccs_env->qual,5))
     PLAN (d
      WHERE d.seq > 0)
     WITH nocounter
    ;end select
    SET validate =
    SELECT INTO "nl:"
     dccs_env->qual[d.seq].env_name
     FROM (dummyt d  WITH seq = size(dccs_env->qual,5))
     PLAN (d
      WHERE d.seq > 0)
     WITH nocounter
    ;end select
    CALL accept(3,70,"P(20);CUF"
     WHERE  NOT (curaccept=" "))
    SET drr_clin_copy_data->tgt_db_env_name = dccs_env->qual[curhelp].env_name
    SET drr_clin_copy_data->tgt_env_id = dccs_env->qual[curhelp].env_id
    SET dm2_install_schema->target_dbase_name = dccs_env->qual[curhelp].database_name
    SET validate = off
    SET help = off
    SET message = window
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("drr_clin_copy_data->tgt_env_id = ",drr_clin_copy_data->tgt_env_id))
    CALL echo(build("drr_clin_copy_data->tgt_env_name = ",drr_clin_copy_data->tgt_env_name))
    CALL echo(build("drr_clin_copy_data->src_env_id = ",drr_clin_copy_data->src_env_id))
    CALL echo(build("drr_clin_copy_data->src_env_name = ",drr_clin_copy_data->src_env_name))
    CALL echo(build("drr_clin_copy_data->tgt_db_env_name = ",drr_clin_copy_data->tgt_db_env_name))
   ENDIF
   SET drr_clin_copy_data->standalone_expimp_process = 1
   IF ( NOT ((drr_clin_copy_data->process IN ("MIGRATION", "RESTORE"))))
    IF ((drr_clin_copy_data->standalone_expimp_process=1))
     SET dm2_install_schema->dbase_name = "ADMIN"
     SET dm2_install_schema->u_name = "CDBA"
     SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF (der_manage_admin_data(dm2_install_schema->target_dbase_name,"DM_INFO","S","ALL","")=0)
      RETURN(0)
     ENDIF
     IF ((der_expimp_data->setup_complete_ind=0))
      SET message = nowindow
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating standalone export/import setup work has been completed."
      SET dm_err->emsg = "Setup work not completed for standalone export/import process."
      SET dm2_install_schema->p_word = "NONE"
      SET dm2_install_schema->v500_p_word = "NONE"
      SET dm2_install_schema->v500_connect_str = "NONE"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF (drr_validate_ref_data_link(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Look for ADS license key on Source DM_INFO."
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm_info@ref_data_link
      WHERE info_domain="DM2_ADS_REPLICATE"
       AND info_name="LICENSE_KEY"
       AND info_number=214
      DETAIL
       drr_clin_copy_data->licensed_to_ads = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (validate(drrr_responsefile_in_use,0)=1)
      IF ((drr_clin_copy_data->licensed_to_ads=0)
       AND (drrr_rf_data->tgt_db_copy_type="ADS"))
       SET dm_err->emsg = "Database is missing ADS license."
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((drr_clin_copy_data->process="MIGRATION"))
    SET drr_clin_copy_data->standalone_expimp_process = 0
   ENDIF
   IF ((drr_clin_copy_data->process != "MIGRATION"))
    SET dccs_str = concat(dccs_slash,"environment",dccs_slash,drr_clin_copy_data->tgt_env_name,
     " domain")
    IF (get_unique_file("ddr_get_reg",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
     RETURN(0)
    ELSE
     SET dccs_reg_file = dm_err->unique_fname
    ENDIF
    SET dm_err->eproc = concat("Create file to obtain target registry info:",dccs_reg_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO value(dccs_reg_file)
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$ mcr cer_exe:lreg -getp ",dccs_str)), row + 1,
       CALL print("$ write sys$output lreg_result"),
       row + 1
      ELSE
       CALL print(concat("$cer_exe/lreg -getp ",dccs_str)), row + 1
      ENDIF
     WITH nocounter, maxcol = 500, format = variable,
      maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Operation for registry:",dccs_str)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dccs_cmd = concat("@",dccs_reg_file)
    ELSE
     SET dccs_cmd = concat(". $CCLUSERDIR/",dccs_reg_file)
    ENDIF
    SET dm_err->disp_dcl_err_ind = 0
    SET dccs_no_error = dm2_push_dcl(dccs_cmd)
    IF (dccs_no_error=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dm_err)
     ENDIF
    ENDIF
    IF (((findstring("unable",dm_err->errtext,1,1)) OR ((((dm_err->errtext="")) OR (((findstring(
     "key not found",dm_err->errtext,1,1)) OR (findstring("property not found",dm_err->errtext,1,1)
    )) )) )) )
     SET dccs_no_error = 1
     SET dccs_ret = "NOPARMRETURNED"
    ELSE
     SET dccs_ret = dm_err->errtext
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("parm_value:",dccs_ret))
    ENDIF
    IF (dccs_no_error=0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (cnvtupper(dccs_ret)="NOPARMRETURNED")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Retieving domain name for Target environment ",drr_clin_copy_data->
      tgt_env_name)
     SET dm_err->emsg = "Failed to retrieve domain name for Target."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET drr_clin_copy_data->tgt_domain_name = cnvtupper(dccs_ret)
    ENDIF
   ENDIF
   IF (drr_clin_copy_restart_chk(null)=0)
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->starting_point="DDL_EXECUTION"))
    SET message = nowindow
    IF ((drr_clin_copy_data->standalone_expimp_process=0))
     SET dm_err->eproc = "Pull directory location for completed export operations"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     IF (drr_get_exp_dmp_loc(dccs_exp_loc)=0)
      RETURN(0)
     ENDIF
     IF (dccs_exp_loc="NONE"
      AND  NOT ((drr_clin_copy_data->process IN ("RESTORE", "MIGRATION"))))
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Could not find logfile location for completed export operation."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET drr_clin_copy_data->temp_location = dccs_exp_loc
     ENDIF
    ENDIF
    SET dm_err->eproc = "Retrieve All stored information from Admin DM_INFO."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_DATA"
      AND di.info_name=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"*")))
     DETAIL
      IF (di.info_name="*DATA_TO_MOVE")
       dm2_install_schema->data_to_move = di.info_char
      ELSEIF (di.info_name="*_TEMP_LOCATION")
       drr_clin_copy_data->temp_location = di.info_char
      ELSEIF (di.info_name="*_PERCENT_TSPACE")
       dm2_install_schema->percent_tspace = cnvtreal(di.info_char)
      ELSEIF (di.info_name="*_SRC_DOMAIN_NAME")
       drr_clin_copy_data->src_domain_name = di.info_char
      ELSEIF (di.info_name="*_RESTORE_PREV_TGT_DATA_IND")
       IF (di.info_char="Y")
        drr_preserved_tables_data->refresh_ind = 1
       ENDIF
      ELSEIF (di.info_name="*_WAS_ARCH_IND")
       IF (di.info_char="Y")
        drr_clin_copy_data->tgt_was_ind = 1
       ENDIF
      ELSEIF (di.info_name="*ADS_CONFIG_NAME")
       drr_clin_copy_data->ads_name = di.info_char, drr_clin_copy_data->ads_mod_dt_tm = di.info_date
      ELSEIF (di.info_name="*ADS_CONFIG_PCT")
       drr_clin_copy_data->ads_pct = di.info_number
      ELSEIF (di.info_name="*ADS_CONFIG_ID")
       drr_clin_copy_data->ads_config_id = di.info_number, drr_clin_copy_data->ads_chosen_ind = 1
      ELSEIF (di.info_name="*ADS_PURGE")
       drr_clin_copy_data->purge_chosen_ind = 1
      ELSEIF (di.info_name="*DDL_EXCL_RPT")
       IF (di.info_number=0)
        drr_clin_copy_data->ddl_excl_rpt_name = di.info_char
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 5))
     CALL echorecord(drr_clin_copy_data)
    ENDIF
    CALL drr_set_src_env_path(null)
    IF ( NOT ((dm2_install_schema->data_to_move IN ("REF", "ALL"))))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Invalid DATA_TO_MOVE value ",trim(dm2_install_schema->data_to_move),
      " found in DM2_ADMIN_DM_INFO on Replicate restart.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    SET dm_err->eproc = "Displaying Clin Copy Window"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dm_err->debug_flag=722))
     SET message = nowindow
    ELSE
     SET message = window
    ENDIF
    CALL clear(1,1)
    CALL box(1,1,24,131)
   ENDIF
   IF ((drr_clin_copy_data->process="RESTORE"))
    IF (validate(drrr_responsefile_in_use,0)=0)
     CALL text(2,2,"Complete Copy of Clinical Database (Alternate Database Restore Method)")
     CALL text(4,8,"Restore data previously saved from TARGET database (Y/N) : ")
     CALL accept(4,70,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     SET dccs_restore = curaccept
     SET dccs_row = 4
     IF (dccs_restore="Y")
      SET dccs_row = (dccs_row+ 2)
      CALL drr_prompt_schema_date(dccs_row)
     ENDIF
     SET dccs_row = (dccs_row+ 2)
     IF (drr_prompt_loc(dccs_row,"IMPORT")=0)
      RETURN(0)
     ENDIF
     SET dm2_install_schema->data_to_move = "ALL"
     SET dm2_install_schema->percent_tspace = 10
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,
      "Subsequent processing should NOT be performed against a production database.")
     SET dccs_row = (dccs_row+ 1)
     CALL text(dccs_row,8,
      "Please confirm that the following database represents a NON-production domain.")
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Is the TARGET database a Production domain (Y/N): ")
     CALL accept(dccs_row,70,"A;cu","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      SET message = nowindow
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "This process should not be against a production database."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF ((drr_clin_copy_data->process="MIGRATION"))
    CALL text(2,2,"Create a Copy of a Clinical Database")
    SET dccs_row = 2
    SET dccs_row = (dccs_row+ 2)
    CALL drr_prompt_schema_date(dccs_row)
    SET dm2_install_schema->data_to_move = "ALL"
    SET dccs_row = (dccs_row+ 2)
    IF (validate(dm2_mig_dbx_in_use,- (1)) != 1)
     CALL text(dccs_row,8,"Adjust tablespace size in target by what percent. (i.e. 10 or -10): ")
     SET dm2_install_schema->percent_tspace = 0
     CALL accept(dccs_row,77,"N(3)",dm2_install_schema->percent_tspace
      WHERE (curaccept > - (100))
       AND curaccept < 100)
     SET dm2_install_schema->percent_tspace = cnvtint(curaccept)
     SET drr_clin_copy_data->temp_location = dm2_install_schema->ccluserdir
     SET dccs_restore = "N"
    ENDIF
   ELSE
    IF (validate(drrr_responsefile_in_use,0)=0)
     CALL text(2,2,"Create a Copy of a Clinical Database")
     SET dccs_row = 2
     SET dccs_row = (dccs_row+ 2)
     CALL drr_prompt_schema_date(dccs_row)
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Data to move : ")
     IF ((drr_clin_copy_data->licensed_to_ads=1)
      AND (dm2_sys_misc->cur_db_os != "AXP"))
      SET help = pos(1,60,10,70)
      SET help =
      SELECT INTO "nl:"
       value = substring(1,6,dccs_data_move->qual[t.seq].name), description = substring(1,40,
        dccs_data_move->qual[t.seq].desc)
       FROM (dummyt t  WITH seq = value(dccs_data_move->cnt))
       WITH nocounter
      ;end select
      CALL accept(dccs_row,70,"P(6);CSF")
     ELSE
      SET help = fix('REF" - Reference Data Only",ALL" - Reference and Activity Data"')
      CALL accept(dccs_row,70,"P(3);CSF")
     ENDIF
     SET dm2_install_schema->data_to_move = build(cnvtupper(trim(curaccept)))
     SET help = off
    ENDIF
    IF ((dm2_install_schema->data_to_move IN ("ADS", "PRG")))
     IF ((dm2_install_schema->data_to_move="PRG"))
      SET drr_clin_copy_data->purge_chosen_ind = 1
     ENDIF
     SET dm2_install_schema->data_to_move = "ALL"
     SET drr_clin_copy_data->ads_chosen_ind = 1
     IF (drr_ads_domain_check("ref_data_link",dccs_ads_domain_ind)=0)
      RETURN(0)
     ENDIF
     IF (dccs_ads_domain_ind=1)
      IF (validate(drrr_responsefile_in_use,0)=0)
       SET dccs_refresh_row = dccs_row
       SET dccs_row = (dccs_row+ 2)
       CALL text(dccs_row,8,
        "WARNING : The Source database for this Replicate is already a ADS Domain.")
       SET dccs_row = (dccs_row+ 1)
       CALL text(dccs_row,8,"Do you wish to (C)ontinue or (Q)uit?")
       SET dccs_row = (dccs_row+ 4)
       CALL text(dccs_row,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
       CALL accept(dccs_row,70,"A;cu"," "
        WHERE curaccept IN ("Q", "C"))
       IF (curaccept="Q")
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->emsg =
        "User choose to quit due to Source database for this Replicate is already a ADS Domain."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       CALL clear((dccs_refresh_row+ 2),8,120)
       CALL clear((dccs_refresh_row+ 3),8,120)
       CALL clear(dccs_row,8,120)
       SET dccs_row = dccs_refresh_row
      ELSE
       IF ((drrr_rf_data->src_ads_domain_ind=0))
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Quit due to Source database for this Replicate is already a ADS Domain."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=0)
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Increase tablespace size in target by what percent : ")
     SET dm2_install_schema->percent_tspace = 10
     CALL accept(dccs_row,70,"9(3)",dm2_install_schema->percent_tspace
      WHERE curaccept > 0
       AND curaccept < 100)
     SET dm2_install_schema->percent_tspace = cnvtint(curaccept)
     SET dccs_row = (dccs_row+ 2)
     IF (drr_prompt_loc(dccs_row,"EXPORT")=0)
      RETURN(0)
     ENDIF
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Restore data previously saved from TARGET database (Y/N) : ")
     CALL accept(dccs_row,70,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     SET dccs_restore = curaccept
     SET drr_clin_copy_data->tgt_mock_env = 1
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process != "MIGRATION"))
    IF ((((drr_clin_copy_data->src_domain_name="")) OR ((drr_clin_copy_data->src_domain_name=
    "DM2NOTSET"))) )
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Please enter the SOURCE domain: ")
     CALL accept(dccs_row,40,"P(20);CU"
      WHERE  NOT (curaccept=" "))
     SET drr_clin_copy_data->src_domain_name = curaccept
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    SET dccs_row = (dccs_row+ 2)
    CALL text(dccs_row,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
    CALL accept(dccs_row,70,"A;cu",""
     WHERE curaccept IN ("Q", "C"))
    SET dccs_whereto = curaccept
    IF (dccs_whereto="Q")
     SET message = nowindow
     SET dm_err->eproc = "Prompt user for information needed during CLIN COPY process."
     SET dm_err->emsg = "User chose to quit from Information entry screen for CLIN COPY."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_install_schema->dbase_name = dm2_install_schema->src_dbase_name
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
   SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((validate(dm2_bypass_was_check,- (1))=- (1)))
    IF (drr_identify_was_usage(drr_clin_copy_data->src_domain_name,dccs_was_ind)=0)
     RETURN(0)
    ENDIF
    SET drr_clin_copy_data->src_was_ind = dccs_was_ind
    SET drr_clin_copy_data->tgt_was_ind = drr_clin_copy_data->src_was_ind
   ENDIF
   IF ((drr_clin_copy_data->ads_chosen_ind=1))
    IF (drr_prompt_ads_config(dccs_response)=0)
     RETURN(0)
    ELSEIF (dccs_response="Q")
     SET message = nowindow
     SET dm_err->eproc = "Prompt user for ADS information needed during CLIN COPY process."
     SET dm_err->emsg = "User chose to quit from Information entry screen for ADS."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((drr_clin_copy_data->ads_chosen_ind=1)) OR ((((drr_clin_copy_data->process="MIGRATION")) OR
   ((dm2_rdbms_version->level1 >= 11)
    AND (dm2_install_schema->data_to_move="REF"))) )) )
    IF (drr_validate_tgtdblink(dccs_tgt_host,dccs_tgt_ora_ver,dccs_src_host)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process != "MIGRATION")
    AND validate(dm2_bypass_adm_csv_load,- (1)) != 1)
    SET message = nowindow
    CALL drr_set_src_env_path(null)
    IF (drr_validate_adm_env_csv(drr_env_hist_misc->path,drr_clin_copy_data->src_env_name)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_install_schema->dbase_name = "ADMIN"
   SET dm2_install_schema->u_name = "CDBA"
   SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
   SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (((dccs_restore="Y") OR ((drr_retain_db_users->cnt > 0))) )
    IF ((drr_clin_copy_data->standalone_expimp_process=1)
     AND (drr_clin_copy_data->process="RESTORE"))
     IF (der_manage_admin_data(dm2_install_schema->target_dbase_name,"DM_INFO","S","ALL","")=0)
      RETURN(0)
     ENDIF
     IF ((der_expimp_data->setup_complete_ind=0))
      SET message = nowindow
      SET dm_err->err_ind = 1
      SET dm_err->eproc =
      "Validating standalone export/import setup work has been completed to restore data."
      SET dm_err->emsg = "Setup work not completed for standalone export/import process."
      SET dm2_install_schema->p_word = "NONE"
      SET dm2_install_schema->v500_p_word = "NONE"
      SET dm2_install_schema->v500_connect_str = "NONE"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dccs_restore="Y")
     IF (drr_prompt_preserve_data(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Delete DM2_REPLICATE_DATA for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_REPLICATE_DATA"
     AND di.info_name=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"*")))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Insert DATA_TO_MOVE for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_DATA_TO_MOVE"))), di.info_char = cnvtstring(
      dm2_install_schema->data_to_move)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Insert TEMP_DIRECTORY for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_TEMP_LOCATION"))), di.info_char = cnvtstring(
      drr_clin_copy_data->temp_location)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Insert PERCENT_TSPACE for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_PERCENT_TSPACE"))), di.info_char = cnvtstring(
      dm2_install_schema->percent_tspace)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Restore Previous Target Data Indicator row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_RESTORE_PREV_TGT_DATA_IND"))), di.info_char =
     cnvtstring(dccs_restore)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Restore Groups row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_RESTORE_GROUPS_STR"))), di.info_char =
     drr_preserved_tables_data->restore_groups_str
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Source Domain Name row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_SRC_DOMAIN_NAME"))), di.info_char = cnvtstring(
      drr_clin_copy_data->src_domain_name)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting WAS Architecture Indicator row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_WAS_ARCH_IND"))), di.info_char = evaluate(
      drr_clin_copy_data->tgt_was_ind,1,"Y","N")
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->ads_chosen_ind=1))
    SET dm_err->eproc = concat("Insert CONFIG_NAME for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_CONFIG_NAME"))), di.info_char = cnvtstring(
       drr_clin_copy_data->ads_name),
      di.info_date = cnvtdatetime(drr_clin_copy_data->ads_mod_dt_tm)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert CONFIG_ID for database ",dm2_install_schema->target_dbase_name
     )
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_CONFIG_ID"))), di.info_number =
      drr_clin_copy_data->ads_config_id
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert CONFIG_PCT for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_CONFIG_PCT"))), di.info_number =
      drr_clin_copy_data->ads_pct
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->purge_chosen_ind=1))
    SET dm_err->eproc = concat("Insert ADS Purge indicator for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_PURGE")))
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process != "DM2NOTSET"))
    SET dm_err->eproc = concat("Insert PROCESS NAME for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_PROCESS"))), di.info_char = drr_clin_copy_data->
      process
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
   SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dm2_install_schema)
    CALL echorecord(drr_clin_copy_data)
   ENDIF
   SET dm_err->eproc = "Prompt user to confirm summary screen."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    IF (drr_display_summary_screen(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_prompt_schema_date(dpsd_row)
   DECLARE dpsd_sch_date_str = vc WITH protect, noconstant("")
   CALL text(dpsd_row,8,"Enter schema date to use to capture source (in mm-dd-yyyy format ) :  ")
   SET dpsd_row = (dpsd_row+ 1)
   CALL text(dpsd_row,17,"* Do not choose date older than 30 days")
   SET dpsd_sch_date_str = "  -  -    "
   CALL accept((dpsd_row - 1),81,"NNDNNDNNNN;C",dpsd_sch_date_str
    WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM-DD-YYYY;;D")=curaccept
     AND datetimeadd(cnvtdatetime(format(cnvtdate2(curaccept,"MM-DD-YYYY"),"DD-MMM-YYYY;;D")),30) >=
    cnvtdatetime(curdate,curtime3))
   SET dpsd_sch_date_str = curaccept
   SET dm2_install_schema->schema_prefix = "dm2s"
   SET dm2_install_schema->file_prefix = cnvtalphanum(dpsd_sch_date_str)
 END ;Subroutine
 SUBROUTINE drr_prompt_loc(dpl_row,dpl_type)
   DECLARE dpl_file_delim = vc WITH protect, noconstant("")
   DECLARE dpl_exp_loc = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dpl_file_delim = "]"
   ELSE
    SET dpl_file_delim = "/"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dpl_file_delim)
   ENDIF
   CALL text(dpl_row,8,"Enter Temporary Directory for Replicate/Refresh : ")
   IF (dpl_type="IMPORT")
    SET dm_err->eproc = "Get Import Location."
   ELSEIF (dpl_type="EXPORT")
    SET dm_err->eproc = "Get Export Location."
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dpl_type="IMPORT"
    AND (dm2_install_schema->run_id=0))
    SET dpl_exp_loc = "NONE"
   ELSE
    IF (drr_get_exp_dmp_loc(dpl_exp_loc)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dpl_exp_loc="NONE")
    SET drr_clin_copy_data->temp_location = ""
   ELSE
    SET drr_clin_copy_data->temp_location = dpl_exp_loc
   ENDIF
   SET dpl_row = (dpl_row+ 1)
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(dpl_row,8,"P(90);C",drr_clin_copy_data->temp_location
     WHERE  NOT (curaccept="")
      AND findstring(dpl_file_delim,trim(curaccept),1,1)=size(trim(curaccept)))
   ELSE
    CALL accept(dpl_row,8,"P(90);C",drr_clin_copy_data->temp_location
     WHERE  NOT (curaccept="")
      AND substring(1,1,curaccept)="/")
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET drr_clin_copy_data->temp_location = curaccept
   ELSE
    IF (findstring(dpl_file_delim,trim(curaccept),1,1) != size(trim(curaccept)))
     SET drr_clin_copy_data->temp_location = concat(trim(curaccept),dpl_file_delim)
    ELSE
     SET drr_clin_copy_data->temp_location = curaccept
    ENDIF
   ENDIF
   IF (dpl_type="IMPORT")
    SET dm_err->eproc = "Validate Import Location."
   ELSEIF (dpl_type="EXPORT")
    SET dm_err->eproc = "Validate Export Location."
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL echo(curaccept)
   ENDIF
   IF (findfile(trim(curaccept))=0)
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->emsg = concat("The Export Location:",drr_clin_copy_data->temp_location,
     " was not found.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_val_write_privs(drr_clin_copy_data->temp_location)=0)
    SET message = nowindow
    SET dm_err->user_action = concat("Please log in as a user that has full privileges to ",
     drr_clin_copy_data->temp_location)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_preserved_table_data(dlp_source,dlp_file)
   DECLARE dlp_locate_var = i4 WITH protect, noconstant(0)
   DECLARE dlp_grpname = vc WITH protect, noconstant(" ")
   DECLARE dlp_excl_autotester = i2 WITH protect, noconstant(0)
   DECLARE dlp_excl_file = vc WITH protect, noconstant(" ")
   DECLARE dlp_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dlp_excl_tbl
   RECORD dlp_excl_tbl(
     1 tbl_cnt = i4
     1 qual[*]
       2 table_name = vc
       2 grpname = vc
   )
   SET dlp_excl_tbl->tbl_cnt = 0
   FREE RECORD dlp_tmp_data
   RECORD dlp_tmp_data(
     1 cnt = i4
     1 tbl[*]
       2 table_name = vc
       2 group = vc
       2 table_suffix = vc
       2 prefix = vc
       2 partial_ind = i2
       2 exp_where_clause = vc
       2 excl_ind = i2
   )
   SET drr_preserved_tables_data->cnt = 0
   SET drr_preserved_tables_data->refresh_ind = 0
   SET stat = alterlist(drr_preserved_tables_data->tbl,0)
   IF (dlp_source="TABLE")
    IF (dpr_sub_ddl_excl(" ")=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Verifying dm_info rows for preserved tables exist"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_PRESERVED_TABLE-*"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "DM_INFO rows for preserved tables are NOT present. Verify that readme 3932 has been run"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Load specific tables that are to be preserved on a Refresh."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dpr_obj_list->tbl_cnt=0))
     SELECT INTO "nl:"
      FROM dm_info di,
       dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (di
       WHERE di.info_domain="DM2_PRESERVED_TABLE-*"
        AND di.info_number=1)
       JOIN (dtd
       WHERE di.info_name=dtd.table_name)
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY di.info_name
      HEAD REPORT
       pos = 0, pos = findstring("-",di.info_domain)
      HEAD di.info_name
       drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1)
       IF (mod(drr_preserved_tables_data->cnt,10)=1)
        stat = alterlist(drr_preserved_tables_data->tbl,(drr_preserved_tables_data->cnt+ 9))
       ENDIF
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = substring((pos+ 1),size
        (di.info_domain),di.info_domain), drr_preserved_tables_data->tbl[drr_preserved_tables_data->
       cnt].table_name = di.info_name, drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt]
       .table_suffix = dtd.table_suffix,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].prefix = cnvtlower(build(
         drr_clin_copy_data->preserve_tbl_pre,dtd.table_suffix)), drr_preserved_tables_data->tbl[
       drr_preserved_tables_data->cnt].refresh_ind = 0
       IF (di.info_char > " ")
        drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].partial_ind = 1,
        drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].exp_where_clause = di
        .info_char
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_info di,
       dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (di
       WHERE di.info_domain="DM2_PRESERVED_TABLE-*"
        AND di.info_number=1)
       JOIN (dtd
       WHERE di.info_name=dtd.table_name)
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY di.info_name
      HEAD REPORT
       pos = 0, pos = findstring("-",di.info_domain)
      HEAD di.info_name
       dpl_grpname = substring((pos+ 1),size(di.info_domain),di.info_domain), dlp_locate_var = 0,
       dlp_locate_var = locateval(dlp_locate_var,1,dpr_obj_list->tbl_cnt,di.info_name,dpr_obj_list->
        obj_tbl[dlp_locate_var].dpr_tbl)
       IF (dlp_locate_var > 0)
        dlp_excl_tbl->tbl_cnt = (dlp_excl_tbl->tbl_cnt+ 1), stat = alterlist(dlp_excl_tbl->qual,
         dlp_excl_tbl->tbl_cnt), dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].table_name = di.info_name,
        dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].grpname = dpl_grpname
       ENDIF
       dlp_tmp_data->cnt = (dlp_tmp_data->cnt+ 1)
       IF (mod(dlp_tmp_data->cnt,10)=1)
        stat = alterlist(dlp_tmp_data->tbl,(dlp_tmp_data->cnt+ 9))
       ENDIF
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].group = dpl_grpname, dlp_tmp_data->tbl[dlp_tmp_data->cnt]
       .table_name = di.info_name, dlp_tmp_data->tbl[dlp_tmp_data->cnt].table_suffix = dtd
       .table_suffix,
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].prefix = cnvtlower(build(drr_clin_copy_data->
         preserve_tbl_pre,dtd.table_suffix))
       IF (di.info_char > " ")
        dlp_tmp_data->tbl[dlp_tmp_data->cnt].partial_ind = 1, dlp_tmp_data->tbl[dlp_tmp_data->cnt].
        exp_where_clause = di.info_char
       ENDIF
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].excl_ind = 0
      FOOT REPORT
       stat = alterlist(dlp_tmp_data->tbl,dlp_tmp_data->cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     FOR (dlp_cnt = 1 TO dlp_tmp_data->cnt)
       SET dlp_locate_var = 0
       SET dlp_locate_var = locateval(dlp_locate_var,1,dlp_excl_tbl->tbl_cnt,dlp_tmp_data->tbl[
        dlp_cnt].group,dlp_excl_tbl->qual[dlp_locate_var].grpname)
       IF (dlp_locate_var=0)
        SET drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1)
        IF (mod(drr_preserved_tables_data->cnt,10)=1)
         SET stat = alterlist(drr_preserved_tables_data->tbl,(drr_preserved_tables_data->cnt+ 9))
        ENDIF
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = dlp_tmp_data->tbl[
        dlp_cnt].group
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_name = dlp_tmp_data
        ->tbl[dlp_cnt].table_name
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_suffix =
        dlp_tmp_data->tbl[dlp_cnt].table_suffix
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].prefix = dlp_tmp_data->
        tbl[dlp_cnt].prefix
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].refresh_ind = 0
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].partial_ind = dlp_tmp_data
        ->tbl[dlp_cnt].partial_ind
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].exp_where_clause =
        dlp_tmp_data->tbl[dlp_cnt].exp_where_clause
       ELSE
        SET dlp_tmp_data->tbl[dlp_cnt].excl_ind = 1
       ENDIF
     ENDFOR
     SET stat = alterlist(drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt)
     SET dm_err->eproc = "Load partitioned AutoTester table."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (dtd
       WHERE dtd.table_name=dtd.full_table_name
        AND dtd.data_model_section="AUTOTESTER")
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY dtd.table_name
      DETAIL
       dlp_locate_var = 0, dlp_locate_var = locateval(dlp_locate_var,1,dpr_obj_list->tbl_cnt,dtd
        .table_name,dpr_obj_list->obj_tbl[dlp_locate_var].dpr_tbl)
       IF (dlp_locate_var > 0)
        dlp_excl_tbl->tbl_cnt = (dlp_excl_tbl->tbl_cnt+ 1), stat = alterlist(dlp_excl_tbl->qual,
         dlp_excl_tbl->tbl_cnt), dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].table_name = dtd
        .table_name,
        dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].grpname = "AUTOTESTER", dlp_excl_autotester = 1
       ENDIF
       dlp_tmp_data->cnt = (dlp_tmp_data->cnt+ 1), stat = alterlist(dlp_tmp_data->tbl,dlp_tmp_data->
        cnt), dlp_tmp_data->tbl[dlp_tmp_data->cnt].group = "AUTOTESTER",
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].table_name = dtd.table_name
      FOOT REPORT
       stat = alterlist(dlp_tmp_data->tbl,dlp_tmp_data->cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dlp_excl_autotester=0)
     SET dm_err->eproc = "Load the group of tables that are used by AutoTester."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (dtd
       WHERE dtd.table_name=dtd.full_table_name
        AND dtd.data_model_section="AUTOTESTER")
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY dtd.table_name
      DETAIL
       drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1), stat = alterlist(
        drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt), drr_preserved_tables_data->
       tbl[drr_preserved_tables_data->cnt].table_name = dtd.table_name,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = dtd.data_model_section,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_suffix = dtd.table_suffix,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].prefix = cnvtlower(build(
         drr_clin_copy_data->preserve_tbl_pre,dtd.table_suffix)),
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].refresh_ind = 0
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSEIF (dlp_excl_autotester=1)
     SET dm_err->eproc = "Set preserve exclude indicator for AutoTester."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt t  WITH seq = dlp_tmp_data->cnt)
      WHERE (dlp_tmp_data->tbl[t.seq].group="AUTOTESTER")
      DETAIL
       dlp_tmp_data->tbl[t.seq].excl_ind = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((dlp_excl_tbl->tbl_cnt > 0)
     AND validate(dpt_preserve_tables,- (1))=1)
     SET dm_err->eproc = "Create exclusion report for partitioned preserved tables."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (get_unique_file("dm2_preserve_excl",".rpt")=0)
      RETURN(0)
     ENDIF
     SET dlp_excl_file = dm_err->unique_fname
     IF (validate(drrr_responsefile_in_use,0)=1)
      SET dlp_excl_file = build(drrr_misc_data->active_dir,dlp_excl_file)
     ENDIF
     SELECT INTO value(dlp_excl_file)
      FROM (dummyt t  WITH seq = dlp_tmp_data->cnt)
      WHERE (dlp_tmp_data->tbl[t.seq].excl_ind=1)
      ORDER BY dlp_tmp_data->tbl[t.seq].group, dlp_tmp_data->tbl[t.seq].table_name
      HEAD REPORT
       row + 1, col 1,
       "***************************WARNING: Preserve Table Exclusion have been detected.************************",
       row + 1, col 1,
       "Tables displayed below cannot be preserved due to one or more tables within its group are partitioned.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "TABLE NAME",
       col 50, "GROUP_NAME", row + 1
      DETAIL
       col 10, dlp_tmp_data->tbl[t.seq].table_name, col 50,
       dlp_tmp_data->tbl[t.seq].group, row + 1
      FOOT REPORT
       col 0, "END OF REPORT"
      WITH nocounter, maxcol = 300, formfeed = none,
       maxrow = 1, nullreport
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (validate(drrr_responsefile_in_use,0)=1)
      SET dm_err->eproc = concat(
       "Using response file - Bypassing displaying of Preserve exclusion report.  ",
       "Report File may be found in :  ",dlp_excl_file)
      CALL disp_msg(" ",dm_err->logfile,0)
      IF ((drer_email_list->email_cnt > 0))
       SET drer_email_det->msgtype = "PROGRESS"
       SET drer_email_det->status = "REPORT"
       SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
       SET drer_email_det->step = "Preserve Table Exclusion Report"
       SET drer_email_det->email_level = 1
       SET drer_email_det->logfile = dm_err->logfile
       SET drer_email_det->err_ind = dm_err->err_ind
       SET drer_email_det->eproc = dm_err->eproc
       SET drer_email_det->emsg = dm_err->emsg
       SET drer_email_det->user_action = dm_err->user_action
       SET drer_email_det->attachment = dlp_excl_file
       CALL drer_add_body_text(concat("Preserve Table Exclusion report was generated at ",format(
          drer_email_det->status_dt_tm,";;q")),1)
       CALL drer_add_body_text(concat("Report file name is : ",dlp_excl_file),0)
       IF (drer_compose_email(null)=1)
        CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
         email_level)
       ENDIF
       CALL drer_reset_pre_err(null)
      ENDIF
     ELSE
      SET drer_email_det->process = "PRESERVE"
      SET drer_email_det->msgtype = "PROGRESS"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Preserve Table Exclusion Report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      SET drer_email_det->attachment = dlp_excl_file
      CALL drer_add_body_text(concat("Preserve Table Exclusion report was displayed at ",format(
         drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",dlp_excl_file),0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("ddr_domain_data->tgt_env = ",ddr_domain_data->tgt_env))
       CALL echo(build("ddr_domain_data->src_env = ",ddr_domain_data->src_env))
       CALL echo(build("ddr_domain_data->src_domain_name = ",ddr_domain_data->src_domain_name))
      ENDIF
      SET drer_email_det->src_env = ddr_domain_data->src_env
      SET drer_email_det->tgt_env = ddr_domain_data->tgt_env
      IF (drer_fill_email_list(drer_email_det->src_env,drer_email_det->tgt_env)=1
       AND (drer_email_list->email_cnt > 0))
       IF (drer_compose_email(null)=1)
        CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
         email_level)
       ENDIF
      ENDIF
      CALL drer_reset_pre_err(null)
      IF (dm2_disp_file(dlp_excl_file,"Preserve Table Exclusion Report")=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (dlp_source="FILE")
    SET dm_err->eproc = concat("Load preserved tables from ",dlp_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    FREE DEFINE rtl2
    FREE SET dlp_filename
    SET logical dlp_filename value(dlp_file)
    DEFINE rtl2 "dlp_filename"
    SELECT INTO "nl:"
     t.line
     FROM rtl2t t
     WHERE t.line > " "
     HEAD REPORT
      beg_pos = 1, end_pos = 0
     DETAIL
      beg_pos = 1, end_pos = 0, drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1)
      IF (mod(drr_preserved_tables_data->cnt,10)=1)
       stat = alterlist(drr_preserved_tables_data->tbl,(drr_preserved_tables_data->cnt+ 9))
      ENDIF
      end_pos = findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = substring(beg_pos,(
       end_pos - beg_pos),t.line), beg_pos = (end_pos+ 1), end_pos = findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_name = substring(beg_pos,(
       end_pos - beg_pos),t.line), beg_pos = (end_pos+ 1), end_pos = findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].partial_ind = evaluate(substring
       (beg_pos,(end_pos - beg_pos),t.line),"PARTIAL",1,0), beg_pos = (end_pos+ 1), end_pos =
      findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].exp_where_clause = substring(
       beg_pos,(end_pos - beg_pos),t.line), drr_preserved_tables_data->tbl[drr_preserved_tables_data
      ->cnt].table_suffix = substring((end_pos+ 1),size(t.line),t.line), drr_preserved_tables_data->
      tbl[drr_preserved_tables_data->cnt].prefix = cnvtlower(build(drr_clin_copy_data->
        preserve_tbl_pre,drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_suffix)
       ),
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].refresh_ind = 0
     FOOT REPORT
      stat = alterlist(drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(drr_preserved_tables_data)
    CALL echorecord(dlp_excl_tbl)
    CALL echorecord(dlp_tmp_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_prompt_preserve_data(null)
   DECLARE dpp_pd_present = i2 WITH protect, noconstant(0)
   SET message = nowindow
   SET dm_err->eproc = "Prompt user if restore is needed for preserved data."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dpp_prev_group = vc WITH protect, noconstant(" ")
   DECLARE dpp_row = i4 WITH protect, noconstant(0)
   DECLARE dpp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpp_restore = c1 WITH protect, noconstant(" ")
   DECLARE dpp_grp = i4 WITH protect, noconstant(0)
   DECLARE dpp_rrd = i4 WITH protect, noconstant(0)
   DECLARE dpp_printers = i4 WITH protect, noconstant(0)
   DECLARE dpp_restore_grps_str = vc WITH protect, noconstant("")
   DECLARE dpp_ndx = i4 WITH protect, noconstant(0)
   IF (drr_chk_for_preserved_data(dpp_pd_present)=0)
    RETURN(0)
   ENDIF
   IF (dpp_pd_present=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Components required for restoring preserved data NOT found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FOR (dpp_cnt = 1 TO drr_preserved_tables_data->cnt)
    SET dpp_grp = locateval(dpp_grp,1,drr_group->cnt,drr_preserved_tables_data->tbl[dpp_cnt].group,
     drr_group->grp[dpp_grp].group)
    IF (dpp_grp > 0)
     SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = drr_group->grp[dpp_grp].restore
    ELSE
     SET drr_group->cnt = (drr_group->cnt+ 1)
     SET stat = alterlist(drr_group->grp,drr_group->cnt)
     SET drr_group->grp[drr_group->cnt].group = drr_preserved_tables_data->tbl[dpp_cnt].group
     IF ((drr_group->grp[drr_group->cnt].group="NOPROMPT"))
      SET drr_group->grp[drr_group->cnt].prompt_ind = 0
      SET drr_preserved_tables_data->refresh_ind = 1
      SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
      SET drr_group->grp[drr_group->cnt].restore = 1
     ELSE
      SET drr_group->grp[drr_group->cnt].prompt_ind = 1
     ENDIF
     IF ((drr_preserved_tables_data->tbl[dpp_cnt].group != "NOPROMPT"))
      IF (validate(drrr_responsefile_in_use,0)=1)
       SET dpp_ndx = 0
       SET dpp_ndx = locateval(dpp_ndx,1,drrr_misc_data->tgt_restore_list_cnt,
        drr_preserved_tables_data->tbl[dpp_cnt].group,drrr_misc_data->tgt_restore_list[dpp_ndx].
        restore_group)
       IF (dpp_ndx > 0
        AND (drrr_misc_data->tgt_restore_list[dpp_ndx].restore_ind=1))
        SET drr_preserved_tables_data->refresh_ind = 1
        SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
        SET drr_group->grp[drr_group->cnt].restore = 1
       ELSE
        SET drr_group->grp[drr_group->cnt].restore = 0
       ENDIF
      ELSE
       IF ((drr_group->grp[drr_group->cnt].prompt_ind=1))
        SET message = window
        CALL clear(1,1)
        CALL box(1,1,24,131)
        CALL text(2,2,"Restoring Preserved Data")
        SET dpp_restore = " "
        CALL text(4,8,concat("Restore ",drr_preserved_tables_data->tbl[dpp_cnt].group," (Y/N): "))
        CALL accept(4,70,"A;cu"," "
         WHERE curaccept IN ("Y", "N"))
        SET dpp_restore = curaccept
        IF (dpp_restore="Y")
         SET drr_preserved_tables_data->refresh_ind = 1
         SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
         SET drr_group->grp[drr_group->cnt].restore = 1
        ELSE
         SET drr_group->grp[drr_group->cnt].restore = 0
        ENDIF
        CALL text(8,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
        CALL accept(8,70,"A;cu",""
         WHERE curaccept IN ("Q", "C"))
        SET dccs_whereto = curaccept
        SET message = nowindow
        IF (dccs_whereto="Q")
         SET message = nowindow
         SET dm_err->eproc = "Prompt user to restore Preserve data."
         SET dm_err->emsg = "User chose to quit from Restoring Preserved Data menu."
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   SET dpp_rrd = locateval(dpp_rrd,1,drr_group->cnt,"RRD",drr_group->grp[dpp_rrd].group)
   SET dpp_printers = locateval(dpp_printers,1,drr_group->cnt,"PRINTERS",drr_group->grp[dpp_printers]
    .group)
   IF ((drr_group->grp[dpp_rrd].restore=1)
    AND (drr_group->grp[dpp_printers].restore=0))
    SET drr_group->grp[dpp_printers].restore = 1
    FOR (dpp_cnt = 1 TO drr_preserved_tables_data->cnt)
      IF ((drr_preserved_tables_data->tbl[dpp_cnt].group="PRINTERS"))
       SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
      ENDIF
    ENDFOR
    IF (validate(drrr_responsefile_in_use,0)=0)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Restoring Preserved Data")
     CALL text(4,8,"PRINTERS will be restored when RRD group is marked to be restored.")
     CALL text(8,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
     CALL accept(8,70,"A;cu",""
      WHERE curaccept IN ("Q", "C"))
     SET dccs_whereto = curaccept
     SET message = nowindow
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dccs_whereto = "C"
   ENDIF
   IF (dccs_whereto="C")
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(drr_preserved_tables_data)
    ENDIF
    SET drr_preserved_tables_data->restore_groups_str = ""
    FOR (dpp_cnt = 1 TO drr_group->cnt)
      IF ((drr_group->grp[dpp_cnt].restore=1))
       IF ((drr_preserved_tables_data->restore_groups_str=""))
        SET drr_preserved_tables_data->restore_groups_str = build("<",drr_group->grp[dpp_cnt].group,
         ">",",")
       ELSE
        SET drr_preserved_tables_data->restore_groups_str = build(drr_preserved_tables_data->
         restore_groups_str,",","<",drr_group->grp[dpp_cnt].group,">")
       ENDIF
      ENDIF
    ENDFOR
    RETURN(1)
   ELSE
    SET message = nowindow
    SET dm_err->eproc = "Prompt user to restore Preserve data."
    SET dm_err->emsg = "User chose to quit from Restoring Preserved Data menu."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_chk_for_preserved_data(dcf_chk_ret)
   SET dm_err->eproc = "Check if preserved data was stored off before a Refresh was initiated."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dcf_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcf_dat_file = vc WITH protect, noconstant(" ")
   DECLARE dcf_dmp_file = vc WITH protect, noconstant(" ")
   DECLARE dcf_sch_file = vc WITH protect, noconstant(" ")
   DECLARE dcf_par_file = vc WITH protect, noconstant(" ")
   SET dcf_dat_file = concat(drr_clin_copy_data->temp_location,drr_clin_copy_data->preserve_tbl_pre,
    "_summary.dat")
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("summary_file =",dcf_dat_file))
   ENDIF
   IF (dm2_findfile(dcf_dat_file)=0)
    SET dcf_chk_ret = 0
    RETURN(1)
   ENDIF
   IF (drr_load_preserved_table_data("FILE",dcf_dat_file)=0)
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->standalone_expimp_process=0))
    FOR (dcf_cnt = 1 TO drr_preserved_tables_data->cnt)
      SET dcf_dmp_file = concat(drr_clin_copy_data->temp_location,drr_clin_copy_data->
       preserve_tbl_pre,drr_preserved_tables_data->tbl[dcf_cnt].table_suffix,".dmp")
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("dmp_file =",dcf_dmp_file))
      ENDIF
      IF (dm2_findfile(dcf_dmp_file)=0)
       SET dcf_chk_ret = 0
       RETURN(1)
      ENDIF
    ENDFOR
   ENDIF
   CALL dsfi_load_schema_file_defs("table_info")
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
    SET dcf_sch_file = build(drr_clin_copy_data->temp_location,dm2_install_schema->schema_prefix,
     drr_clin_copy_data->preserve_sch_dt,cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
    IF (dm2_findfile(dcf_sch_file)=0)
     SET dcf_chk_ret = 0
     RETURN(1)
    ENDIF
   ENDFOR
   CALL dsfi_load_schema_file_defs("tspace")
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
    SET dcf_sch_file = build(drr_clin_copy_data->temp_location,dm2_install_schema->schema_prefix,
     drr_clin_copy_data->preserve_sch_dt,cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
    IF (dm2_findfile(dcf_sch_file)=0)
     SET dcf_chk_ret = 0
     RETURN(1)
    ENDIF
   ENDFOR
   CALL dsfi_load_schema_file_defs("table_info")
   SET dcf_par_file = concat(drr_clin_copy_data->temp_location,drr_clin_copy_data->preserve_tbl_pre,
    "_imp.par")
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("par_file =",dcf_par_file))
   ENDIF
   IF (dm2_findfile(dcf_par_file)=0)
    SET dcf_chk_ret = 0
    RETURN(1)
   ENDIF
   SET dcf_chk_ret = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_display_summary_screen(null)
   DECLARE dds_sch_date_str = vc WITH protect, noconstant(" ")
   DECLARE dds_row = i4 WITH protect, noconstant(0)
   DECLARE dds_cnt = i4 WITH protect, noconstant(0)
   DECLARE dds_prev_group = vc WITH protect, noconstant(" ")
   DECLARE dds_file = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Display summary report."
   IF ((drr_clin_copy_data->summary_screen_issued=1))
    RETURN(1)
   ENDIF
   IF (get_unique_file("dm2_summary_report",".rpt")=0)
    RETURN(0)
   ELSE
    SET dds_file = dm_err->unique_fname
   ENDIF
   SELECT INTO value(dds_file)
    FROM dummyt d
    HEAD REPORT
     CALL print(fillstring(90,"-")), row + 1
     IF ((drr_clin_copy_data->starting_point="FROM_BEGINNING"))
      IF ((drr_clin_copy_data->process="RESTORE"))
       col 0,
       CALL print("Complete Copy of Clinical Database (Alternate Database Restore Method) Summary")
      ELSE
       col 0,
       CALL print("Create a Copy of a Clinical Database Summary")
      ENDIF
     ELSE
      IF ((drr_clin_copy_data->process="RESTORE"))
       col 0,
       CALL print(
       "Restart Complete Copy of Clinical Database (Alternate Database Restore Method) Summary")
      ELSE
       col 0,
       CALL print("Restart Copy of a Clinical Database Summary")
      ENDIF
     ENDIF
     row + 1,
     CALL print(fillstring(90,"-")), row + 1,
     col 0,
     CALL print(
     "***** PLEASE REVIEW THE VALUES BELOW. WHEN DONE, PRESS ENTER FOR CONFIRMATION SCREEN! *****"),
     row + 1,
     row + 1, col 0,
     CALL print("SOURCE"),
     col 60,
     CALL print("TARGET"), row + 1,
     col 0,
     CALL print(concat("Environment Name : ",trim(drr_clin_copy_data->src_env_name))), col 60,
     CALL print(concat("Environment Name : ",trim(drr_clin_copy_data->tgt_db_env_name))), row + 1,
     col 0,
     CALL print(concat("Database Name : ",trim(dm2_install_schema->src_dbase_name))), col 60,
     CALL print(concat("Database Name : ",trim(dm2_install_schema->target_dbase_name))),
     row + 1, col 0,
     CALL print(concat("Database Create Date  : ",format(drr_clin_copy_data->src_db_created,
       "mm-dd-yyyy;;d"))),
     col 60,
     CALL print(concat("Database Create Date  : ",format(drr_clin_copy_data->tgt_db_created,
       "mm-dd-yyyy;;d"))), row + 1,
     col 0,
     CALL print(concat("Database Password : ",trim(dm2_install_schema->src_v500_p_word))), col 60,
     CALL print(concat("Database Password : ",trim(dm2_install_schema->v500_p_word))), row + 1, col 0,
     CALL print(concat("Database Connect String : ",trim(dm2_install_schema->src_v500_connect_str))),
     col 60,
     CALL print(concat("Database Connect String : ",trim(dm2_install_schema->v500_connect_str)))
     IF ((((drr_clin_copy_data->process != "RESTORE")) OR ((drr_clin_copy_data->process="RESTORE")
      AND (drr_preserved_tables_data->refresh_ind=1))) )
      IF ((drr_clin_copy_data->starting_point="FROM_BEGINNING"))
       IF ((dm2_install_schema->file_prefix > " "))
        dds_sch_date_str = format(cnvtdate(cnvtint(build(substring(1,8,dm2_install_schema->
             file_prefix)))),"mm-dd-yyyy;;d"), row + 1, col 0,
        CALL print(concat("Schema Date = ",dds_sch_date_str))
       ENDIF
       IF ((drr_clin_copy_data->process != "MIGRATION"))
        IF ((drr_clin_copy_data->ads_chosen_ind=1))
         row + 1, col 0,
         CALL print(concat("Data to Move = Reference with Activity Data Sample Name : ",
          drr_clin_copy_data->ads_name))
        ELSE
         row + 1, col 0,
         CALL print(concat("Data to Move = ",evaluate(dm2_install_schema->data_to_move,"REF",
           "Reference Only","All")))
        ENDIF
        row + 1, col 0,
        CALL print(concat("% Tablespace Increase = ",trim(cnvtstring(dm2_install_schema->
           percent_tspace)),"%")),
        row + 1, col 0,
        CALL print(concat("Temporary Directory for Replicate/Refresh = ",drr_clin_copy_data->
         temp_location))
        IF ((drr_preserved_tables_data->refresh_ind=1))
         row + 1, col 6,
         CALL print("Restore data previously saved from TARGET database = Yes")
         FOR (dds_cnt = 1 TO drr_group->cnt)
           IF ((drr_group->grp[dds_cnt].restore=1)
            AND (drr_group->grp[dds_cnt].group != "NOPROMPT"))
            row + 1, col 6,
            CALL print(concat("Restore ",drr_group->grp[dds_cnt].group," = Yes"))
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 1, col 0,
        CALL print(concat("% Tablespace Adjustment = ",trim(cnvtstring(dm2_install_schema->
           percent_tspace)),"%"))
       ENDIF
      ENDIF
      IF ((drr_clin_copy_data->starting_point != "FROM_BEGINNING"))
       row + 1
      ENDIF
      IF ((drr_clin_copy_data->process="MIGRATION"))
       row + 1, col 0,
       CALL print("For parallel processing, open additional sessions and execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_mig_replicate_runner go "),
       row + 1, col 0,
       CALL print("To monitor the progress of a clinical copy, execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_mig_replicate_monitor go "),
       row + 1
      ELSE
       row + 1, col 0,
       CALL print("For parallel processing, open additional sessions and execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_replicate_runner go "),
       row + 1, col 0,
       CALL print("To monitor the progress of a clinical copy, execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_domain_maint go "),
       row + 1, col 0,
       CALL print("            Replicate/Refresh a Domain -> Monitor Copy of Clinical Database"),
       row + 1, row + 1
      ENDIF
      IF ((drr_clin_copy_data->starting_point != "FROM_BEGINNING"))
       row + 1
      ENDIF
     ENDIF
    FOOT REPORT
     col 0, "END OF REPORT"
    WITH nocounter, maxcol = 300, formfeed = none,
     maxrow = 1, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_disp_file(dds_file,"Clinical Database Summary Report")=0)
    RETURN(0)
   ENDIF
   SET message = window
   CALL clear(1,1)
   CALL text(4,2,"Database Summary Report Confirmation")
   CALL text(7,2,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,60,"p;cu",""
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET message = nowindow
    SET dm_err->eproc = "Displaying Clinical Database Summary."
    SET dm_err->emsg = "User chose to quit from Clinical Database Summary."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET drr_clin_copy_data->summary_screen_issued = 1
    SET message = nowindow
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_get_invalid_tables_list(null)
   DECLARE dgitl_iter = i4 WITH protect, noconstant(0)
   DECLARE dgitl_found = i4 WITH protect, noconstant(0)
   DECLARE dgitl_found2 = i4 WITH protect, noconstant(0)
   DECLARE dgitl_found3 = i4 WITH protect, noconstant(0)
   FREE RECORD tables_doc_list
   RECORD tables_doc_list(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
   )
   FREE RECORD exception_list
   RECORD exception_list(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 owner = vc
   )
   SET dm_err->eproc = "Determining if CQM* exception row exists in dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_REPLICATE_CLEANUP_EXCEPTION"=di.info_domain
     AND "CQM\*"=di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Inserting CQM* row as exception into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_CLEANUP_EXCEPTION", di.info_name = "CQM*", di.info_number =
      1
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   SET dm_err->eproc = "Selecting list of exception tables from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_REPLICATE_CLEANUP_EXCEPTION"=di.info_domain
     AND 1=di.info_number
    HEAD REPORT
     exception_list->cnt = 0, stat = alterlist(exception_list->qual,0)
    DETAIL
     exception_list->cnt = (exception_list->cnt+ 1), stat = alterlist(exception_list->qual,
      exception_list->cnt), exception_list->qual[exception_list->cnt].table_name = di.info_name,
     exception_list->qual[exception_list->cnt].owner = "V500"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->tgt_mock_env=1))
    SET exception_list->cnt = (exception_list->cnt+ 1)
    SET stat = alterlist(exception_list->qual,exception_list->cnt)
    SET exception_list->qual[exception_list->cnt].table_name = "*$R"
    SET exception_list->qual[exception_list->cnt].owner = "V500"
   ENDIF
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*$C"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*$O"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*GTTD"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*GTTP"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*GTMP"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   IF ((drr_retain_db_users->cnt > 0))
    FOR (dgitl_iter = 1 TO drr_retain_db_users->cnt)
      SET exception_list->cnt = (exception_list->cnt+ 1)
      SET stat = alterlist(exception_list->qual,exception_list->cnt)
      SET exception_list->qual[exception_list->cnt].table_name = "*"
      SET exception_list->qual[exception_list->cnt].owner = drr_retain_db_users->user[dgitl_iter].
      user_name
    ENDFOR
   ENDIF
   SET dgitl_iter = 0
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(exception_list)
   ENDIF
   SET dm_err->eproc = "Selecting list of tables from dm_tables_doc."
   SELECT DISTINCT INTO "nl:"
    dtd.table_name
    FROM dm_tables_doc dtd
    ORDER BY dtd.table_name
    HEAD REPORT
     tables_doc_list->cnt = 0, stat = alterlist(tables_doc_list->qual,tables_doc_list->cnt)
    DETAIL
     tables_doc_list->cnt = (tables_doc_list->cnt+ 1)
     IF (mod(tables_doc_list->cnt,250)=1)
      stat = alterlist(tables_doc_list->qual,(tables_doc_list->cnt+ 249))
     ENDIF
     tables_doc_list->qual[tables_doc_list->cnt].table_name = dtd.table_name
    FOOT REPORT
     stat = alterlist(tables_doc_list->qual,tables_doc_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_fill_sch_except("LOCAL")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_sch_except)
   ENDIF
   IF (drr_get_custom_tables_list(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting list of invalid tables from dm2_dba_tables."
   SELECT INTO "nl:"
    FROM dm2_dba_tables ddt
    WHERE "CDBA" != ddt.owner
     AND  NOT (ddt.owner IN (
    (SELECT
     di.info_name
     FROM dm_info di
     WHERE ((di.info_domain IN ("DM2_ORACLE_USER", "DM2_CERNER_USER")
      AND di.info_number=1) OR (di.info_domain="DM2_CUSTOM_USER"))
     WITH nordbbindcons)))
     AND ddt.table_name != "MLOG*"
    ORDER BY ddt.table_name
    HEAD REPORT
     drr_cleanup_drop_list->cnt = 0, stat = alterlist(drr_cleanup_drop_list->qual,
      drr_cleanup_drop_list->cnt), exception_ind = 0
    DETAIL
     exception_ind = 0
     FOR (dgitl_iter = 1 TO exception_list->cnt)
       IF (ddt.table_name=patstring(exception_list->qual[dgitl_iter].table_name,0)
        AND (ddt.owner=exception_list->qual[dgitl_iter].owner))
        exception_ind = 1, dgitl_iter = (exception_list->cnt+ 1)
       ENDIF
     ENDFOR
     IF (exception_ind=0)
      dgitl_found = locateval(dgitl_iter,1,tables_doc_list->cnt,ddt.table_name,tables_doc_list->qual[
       dgitl_iter].table_name), dgitl_found2 = locateval(dgitl_iter,1,dm2_sch_except->tcnt,ddt
       .table_name,dm2_sch_except->tbl[dgitl_iter].tbl_name), dgitl_found3 = locateval(dgitl_iter,1,
       drr_custom_tables->cnt,ddt.table_name,drr_custom_tables->qual[dgitl_iter].table_name,
       ddt.owner,drr_custom_tables->qual[dgitl_iter].owner)
      IF (((dgitl_found=0) OR (ddt.owner != "V500"))
       AND dgitl_found3=0
       AND dgitl_found2=0)
       drr_cleanup_drop_list->cnt = (drr_cleanup_drop_list->cnt+ 1)
       IF (mod(drr_cleanup_drop_list->cnt,25)=1)
        stat = alterlist(drr_cleanup_drop_list->qual,(drr_cleanup_drop_list->cnt+ 24))
       ENDIF
       drr_cleanup_drop_list->qual[drr_cleanup_drop_list->cnt].owner = ddt.owner,
       drr_cleanup_drop_list->qual[drr_cleanup_drop_list->cnt].table_name = ddt.table_name
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_cleanup_drop_list->qual,drr_cleanup_drop_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_cleanup_drop_list)
   ENDIF
   SET dm_err->eproc = "Getting list of Invalid Materialized Views for Invalid Tables being dropped."
   SELECT INTO "nl:"
    FROM dba_mviews dm
    WHERE (list(dm.owner,dm.mview_name)=
    (SELECT
     ddt.owner, ddt.table_name
     FROM dm2_dba_tables ddt
     WHERE "CDBA" != ddt.owner
      AND ((ddt.owner="V500"
      AND ddt.table_name != "CUST*") OR (ddt.owner != "V500"))
      AND  NOT (ddt.owner IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE ((di.info_domain IN ("DM2_ORACLE_USER", "DM2_CERNER_USER")
       AND di.info_number=1) OR (di.info_domain="DM2_CUSTOM_USER"))
      WITH nordbbindcons)))
      AND ddt.table_name != "MLOG*"
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_tables_doc dtd
      WHERE ddt.table_name=dtd.table_name)))))
    HEAD REPORT
     drr_mvdrop_list->cnt = 0, stat = alterlist(drr_mvdrop_list->qual,drr_mvdrop_list->cnt)
    DETAIL
     drr_mvdrop_list->cnt = (drr_mvdrop_list->cnt+ 1)
     IF (mod(drr_mvdrop_list->cnt,10)=1)
      stat = alterlist(drr_mvdrop_list->qual,(drr_mvdrop_list->cnt+ 9))
     ENDIF
     drr_mvdrop_list->qual[drr_mvdrop_list->cnt].owner = dm.owner, drr_mvdrop_list->qual[
     drr_mvdrop_list->cnt].mv_name = dm.mview_name
    FOOT REPORT
     stat = alterlist(drr_mvdrop_list->qual,drr_mvdrop_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_mvdrop_list)
   ENDIF
   SET drr_cleanup_drop_list->list_loaded_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_custom_tables_list(null)
   DECLARE dgct_idx = i4 WITH protect, noconstant(0)
   DECLARE dgct_purge_string = vc WITH protect, noconstant("")
   DECLARE dgct_pos = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Selecting list of custom tables from dm_info and dm2_dba_tables."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_CUSTOM_TABLE"=di.info_domain
    HEAD REPORT
     drr_custom_tables->cnt = 0, stat = alterlist(drr_custom_tables->qual,0)
    DETAIL
     drr_custom_tables->cnt = (drr_custom_tables->cnt+ 1), stat = alterlist(drr_custom_tables->qual,
      drr_custom_tables->cnt), dgct_pos = findstring(":",trim(di.info_name),1,0)
     IF (dgct_pos > 0)
      drr_custom_tables->qual[drr_custom_tables->cnt].owner = substring(1,(dgct_pos - 1),trim(di
        .info_name)), drr_custom_tables->qual[drr_custom_tables->cnt].table_name = substring((
       dgct_pos+ 1),(textlen(trim(di.info_name)) - dgct_pos),trim(di.info_name)), drr_custom_tables->
      qual[drr_custom_tables->cnt].owner_table = concat(trim(drr_custom_tables->qual[
        drr_custom_tables->cnt].owner),trim(drr_custom_tables->qual[drr_custom_tables->cnt].
        table_name))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_dba_tables ddt
    WHERE ddt.owner="V500"
     AND ddt.table_name=patstring("CUST*")
    DETAIL
     IF (locateval(dgct_idx,1,drr_custom_tables->cnt,ddt.table_name,drr_custom_tables->qual[dgct_idx]
      .table_name)=0)
      drr_custom_tables->cnt = (drr_custom_tables->cnt+ 1), stat = alterlist(drr_custom_tables->qual,
       drr_custom_tables->cnt), drr_custom_tables->qual[drr_custom_tables->cnt].table_name = ddt
      .table_name,
      drr_custom_tables->qual[drr_custom_tables->cnt].owner = ddt.owner, drr_custom_tables->qual[
      drr_custom_tables->cnt].owner_table = concat(trim(ddt.owner),trim(ddt.table_name))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_custom_tables)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_process_invalid_tables(null)
   DECLARE dpit_iter = i4 WITH protect, noconstant(0)
   DECLARE dpit_purge_string = vc WITH protect, noconstant("")
   DECLARE dpit_drop_cmd = vc WITH protect, noconstant("")
   DECLARE dpit_nodrop_ind = i2 WITH protect, noconstant(0)
   FREE RECORD all_objects_list
   RECORD all_objects_list(
     1 cnt = i4
     1 qual[*]
       2 object_name = vc
   )
   CALL dm2_get_rdbms_version(null)
   IF ((dm2_rdbms_version->level1 <= 9))
    SET dpit_purge_string = " "
   ELSE
    SET dpit_purge_string = "PURGE"
   ENDIF
   IF ((dm2_install_schema->process_option != patstring("CLIN COPY*")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Processing of invalid tables is only allowed during CLIN COPY"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dpit_iter = 1 TO drr_mvdrop_list->cnt)
     SET dpit_nodrop_ind = 0
     IF ((drr_clin_copy_data->process != "RESTORE")
      AND (drr_mvdrop_list->qual[dpit_iter].owner != "V500"))
      SET dpit_nodrop_ind = 1
     ENDIF
     IF (dpit_nodrop_ind=0)
      SET dpit_drop_cmd = concat('RDB ASIS(^DROP MATERIALIZED VIEW "',drr_mvdrop_list->qual[dpit_iter
       ].owner,'"."',drr_mvdrop_list->qual[dpit_iter].mv_name,'" ^) GO')
      IF ((dm_err->debug_flag=318))
       CALL echo(dpit_drop_cmd)
      ELSE
       IF (dm2_push_cmd(dpit_drop_cmd,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dpit_iter = 1 TO drr_cleanup_drop_list->cnt)
     SET dpit_nodrop_ind = 0
     IF ((drr_clin_copy_data->process != "RESTORE")
      AND (drr_cleanup_drop_list->qual[dpit_iter].owner != "V500"))
      SET dpit_nodrop_ind = 1
     ENDIF
     IF (dpit_nodrop_ind=0)
      SET dpit_drop_cmd = concat('RDB ASIS(^DROP TABLE "',drr_cleanup_drop_list->qual[dpit_iter].
       owner,'"."',drr_cleanup_drop_list->qual[dpit_iter].table_name,'" CASCADE CONSTRAINTS ',
       dpit_purge_string," ^) GO")
      IF ((dm_err->debug_flag=318))
       CALL echo(dpit_drop_cmd)
      ELSE
       IF (dm2_push_cmd(dpit_drop_cmd,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_cleanup_drop_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_confirm_invalid_tables(dcit_manage_opt_ind,dcit_confirm_ret)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,36,"INVALID TABLES REPORT CONFIRMATION")
   CALL text(4,2,"Is the invalid tables report correct?")
   IF (dcit_manage_opt_ind=1)
    CALL text(6,2,"The Manage Custom Users option can be leveraged to manage custom users ")
    CALL text(7,2,"that will then be exempt from the invalid tables process.")
    CALL text(8,2,
     "It will be the clients responsibility to evaluate that there is no data copied to TARGET")
    CALL text(9,2,"that still points back to the SOURCE domain/database.")
    CALL text(21,2,"(M)anage Custom Users, (C)onfirm, (Q)uit : ")
    CALL accept(21,45,"A;cu"," "
     WHERE curaccept IN ("M", "C", "Q"))
   ELSE
    CALL text(21,2,"(C)onfirm, (Q)uit : ")
    CALL accept(21,25,"A;cu"," "
     WHERE curaccept IN ("C", "Q"))
   ENDIF
   CASE (curaccept)
    OF "M":
     SET dcit_confirm_ret = 2
    OF "C":
     SET dcit_confirm_ret = 1
    OF "Q":
     SET dcit_confirm_ret = 0
   ENDCASE
   SET message = nowindow
   RETURN(1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_dbase_created_date(dgdcd_created_date)
   IF (dm2_get_rdbms_version(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving database created date"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_rdbms_version->level1 <= 11))
    SELECT INTO "nl:"
     FROM v$database v
     DETAIL
      dgdcd_created_date = v.created
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       creation_time = x.creation_time
       FROM (parser("v$pdbs") x)
       WITH sqltype("DQ8")))
      v)
     DETAIL
      dgdcd_created_date = v.creation_time
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_max_clin_copy_run_id(dgm_run_id)
   SET dm_err->eproc = "Retrieving max run_id for CLIN COPY"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_ddl_ops d
    WHERE d.run_id IN (
    (SELECT
     max(r.run_id)
     FROM dm2_ddl_ops r
     WHERE r.process_option="CLIN COPY"))
    DETAIL
     dgm_run_id = d.run_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_validate_ref_data_link(null)
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    EXECUTE dm2_create_database_link "REF_DATA_LINK", drrr_rf_data->src_db_link_cnct_desc,
    drrr_rf_data->src_db_user,
    drrr_rf_data->src_db_user_pwd, drrr_rf_data->src_db_link_host, drrr_rf_data->src_db_link_port,
    drrr_rf_data->src_db_link_svc_nm, drrr_rf_data->src_db_cred_nm, 1,
    1
   ELSE
    EXECUTE dm2_create_database_link "REF_DATA_LINK", dm2_install_schema->src_v500_connect_str,
    "V500",
    dm2_install_schema->src_v500_p_word, " ", " ",
    " ", " ", 1,
    1
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    EXECUTE dm2_create_database_link "REPL_SOURCE", drrr_rf_data->src_db_link_cnct_desc, drrr_rf_data
    ->src_db_user,
    drrr_rf_data->src_db_user_pwd, drrr_rf_data->src_db_link_host, drrr_rf_data->src_db_link_port,
    drrr_rf_data->src_db_link_svc_nm, drrr_rf_data->src_db_cred_nm, 1,
    1
   ELSE
    EXECUTE dm2_create_database_link "REPL_SOURCE", dm2_install_schema->src_v500_connect_str, "V500",
    dm2_install_schema->src_v500_p_word, " ", " ",
    " ", " ", 1,
    1
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_drop_db_link(dddl_link_name)
   DECLARE dddl_dblink_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dddl_adb_ind = i2 WITH protect, noconstant(0)
   DECLARE drop_database_link(db_link_name=vc,public_link=i4) = null WITH sql =
   "DBMS_CLOUD_ADMIN.DROP_DATABASE_LINK", parameter
   IF (drr_check_db_link(dddl_link_name,dddl_dblink_fnd_ind)=0)
    RETURN(0)
   ENDIF
   IF (dddl_dblink_fnd_ind=1)
    IF (dm2_adb_check("",dddl_adb_ind)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Removing existing database link for ",dddl_link_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dddl_adb_ind=1)
     CALL drop_database_link(dddl_link_name,cnvtbool(true))
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF (dm2_push_cmd(concat("rdb drop public database link ",dddl_link_name," go"),1)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Database link ",dddl_link_name," does not exist in database.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_ads_domain_check(dadc_db_link,dadc_ads_domain_ind)
   SET dm_err->eproc = concat("Check if domain is configured for ADS.")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dadc_db_link > "")
     FROM (parser(concat("dm_info@",dadc_db_link)) d)
    ELSE
     FROM dm_info d
    ENDIF
    INTO "nl:"
    WHERE d.info_domain="DM2_REPL_METADATA"
     AND d.info_name=parser("'ADS_CONFIG_ID'")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dadc_ads_domain_ind = 1
   ELSE
    SET dadc_ads_domain_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_prompt_ads_config(dpac_response)
   DECLARE dpac_config_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpac_config_status = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpac_config_selected = i2 WITH protect, noconstant(0)
   DECLARE dpac_config_idx = i2 WITH protect, noconstant(0)
   DECLARE dpac_purge_cnt = i2 WITH protect, noconstant(0)
   EXECUTE dm2_ads_validate_configs
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   CALL dar_clear_dads_list(null)
   SET dm_err->eproc = "Load ADS Config."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF ((drr_clin_copy_data->purge_chosen_ind=1))
     WHERE s.config_status IN ("COMPLETE", "REPLICATE_RUNNING")
      AND s.sample_method=dpl_purge
    ELSE
     WHERE s.config_status="COMPLETE"
    ENDIF
    INTO "nl:"
    FROM dm_ads_config s
    ORDER BY s.updt_dt_tm DESC
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dads_list->config_qual,(cnt+ 9))
     ENDIF
     dads_list->config_qual[cnt].config_id = s.dm_ads_config_id, dads_list->config_qual[cnt].
     config_name = cnvtupper(trim(s.config_name)), dads_list->config_qual[cnt].config_method = s
     .sample_method,
     dads_list->config_qual[cnt].config_status = s.config_status, dads_list->config_qual[cnt].
     config_pct = s.sample_percent_nbr, dads_list->config_qual[cnt].config_updt_dt_tm = s.updt_dt_tm
    FOOT REPORT
     dads_list->config_cnt = cnt, stat = alterlist(dads_list->config_qual,cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dads_list)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    IF (curqual=0)
     SET message = window
     CALL clear(1,1)
     CALL box(6,1,12,131)
     CALL text(7,5,"No valid sample was found. Please exit this menu and go to ")
     IF ((drr_clin_copy_data->purge_chosen_ind=1))
      CALL text(8,5,concat("dm2_ads_purge_adm->Manage ADS Sample. ",
        " Only Sample Names with a Status of REPLICATE READY"))
     ELSE
      CALL text(8,5,concat("dm2_domain_maint->Activity Data Sampler->Manage Activity Data Sample. ",
        " Only Sample Names with a Status of COMPLETE"))
     ENDIF
     CALL text(9,5,"can be used for Database Replicates.")
     CALL text(11,5,"Press Enter to exit the Replicate Process")
     CALL accept(11,51,"P;E"," ")
     SET dpac_config_selected = 1
     SET dpac_response = "Q"
    ENDIF
    WHILE (dpac_config_selected=0)
      SET message = window
      CALL clear(1,1)
      CALL box(1,1,24,131)
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       CALL text(2,2,"Activity Data Purge Sample Selection")
       CALL text(4,2,"Current Sample : ")
      ELSE
       CALL text(2,2,"Activity Data Sample Selection")
       CALL text(4,2,"Current Sample Name : ")
      ENDIF
      CALL text(15,2,
       "If you wish to create or modify a Sample Name, please exit this menu and go to ")
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       CALL text(16,2,concat("dm2_ads_purge_adm->Manage ADS Sample. ",
         " Only Sample Names with a Status of REPLICATE READY"))
      ELSE
       CALL text(16,2,concat("dm2_domain_maint->Activity Data Sampler->Manage Activity Data Sample. ",
         " Only Sample Names with a Status of COMPLETE"))
      ENDIF
      CALL text(17,2,"can be used for Database Replicates.")
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       SELECT INTO "nl:"
        num_keys = count(dacd.driver_key_id)
        FROM dm_ads_config_driver dacd
        WHERE (dacd.dm_ads_config_id=dads_list->config_qual[1].config_id)
        DETAIL
         dpac_purge_cnt = num_keys
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       CALL text(6,5,"SAMPLE NAME")
       CALL text(6,31,"NUMBER OF PERSONS TO PURGE")
       CALL text(6,61,"LAST MODIFIED")
       CALL line(7,5,69)
       CALL text(8,5,substring(1,30,dads_list->config_qual[1].config_name))
       CALL text(8,31,cnvtstring(dpac_purge_cnt))
       CALL text(8,61,substring(1,13,format(dads_list->config_qual[1].config_updt_dt_tm,
          "DD-MMM-YYYY;;D")))
       SET dpac_config_name = dads_list->config_qual[1].config_name
      ELSE
       SET help = pos(5,2,10,128)
       SET help =
       SELECT INTO "nl:"
        sample_name = substring(1,30,dads_list->config_qual[t.seq].config_name), status = substring(1,
         11,dads_list->config_qual[t.seq].config_status), method = substring(1,12,dads_list->
         config_qual[t.seq].config_method),
        pct = build(dads_list->config_qual[t.seq].config_pct), last_modified = substring(1,14,format(
          dads_list->config_qual[t.seq].config_updt_dt_tm,"DD-MMM-YYYY;;D"))
        FROM (dummyt t  WITH seq = value(dads_list->config_cnt))
        WITH nocounter
       ;end select
       CALL accept(4,30,"P(30);CSF")
       SET help = off
       SET dpac_config_name = build(curaccept)
      ENDIF
      SET dpac_config_selected = 1
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       CALL text(21,2,"(C)ontinue, (Q)uit : ")
       CALL accept(21,52,"A;cu"," "
        WHERE curaccept IN ("C", "Q"))
      ELSE
       CALL text(21,2,"(S)elect a Sample Name, (V)iew Driver Table Report, (C)ontinue, (Q)uit : ")
       CALL accept(21,52,"A;cu"," "
        WHERE curaccept IN ("S", "V", "C", "Q"))
      ENDIF
      IF (curaccept="S")
       SET dpac_config_selected = 0
      ELSEIF (curaccept="V")
       SET dpac_config_idx = 0
       SET dpac_config_idx = locateval(dpac_config_idx,1,dads_list->config_cnt,dpac_config_name,
        dads_list->config_qual[dpac_config_idx].config_name)
       IF (dpac_config_idx > 0)
        IF ((dads_list->config_qual[dpac_config_idx].config_status="COMPLETE"))
         SET dads_list->config_id = dads_list->config_qual[dpac_config_idx].config_id
         EXECUTE dm2_ads_rpt_dkeys
         IF ((dm_err->err_ind=1))
          SET message = nowindow
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
       SET dpac_config_selected = 0
      ELSEIF (curaccept="C")
       SET dpac_config_idx = 0
       SET dpac_config_idx = locateval(dpac_config_idx,1,dads_list->config_cnt,dpac_config_name,
        dads_list->config_qual[dpac_config_idx].config_name)
       IF (dpac_config_idx > 0)
        IF ((drr_clin_copy_data->purge_chosen_ind=1)
         AND  NOT ((dads_list->config_qual[dpac_config_idx].config_status IN ("COMPLETE",
        "REPLICATE_RUNNING"))))
         SET dpac_config_selected = 0
        ELSEIF ((drr_clin_copy_data->purge_chosen_ind=0)
         AND (dads_list->config_qual[dpac_config_idx].config_status != "COMPLETE"))
         SET dpac_config_selected = 0
        ELSE
         SET drr_clin_copy_data->ads_config_id = dads_list->config_qual[dpac_config_idx].config_id
         SET drr_clin_copy_data->ads_name = dads_list->config_qual[dpac_config_idx].config_name
         SET drr_clin_copy_data->ads_mod_dt_tm = dads_list->config_qual[dpac_config_idx].
         config_updt_dt_tm
         SET drr_clin_copy_data->ads_pct = dads_list->config_qual[dpac_config_idx].config_pct
         SET dpac_response = "C"
        ENDIF
       ELSE
        SET dpac_config_selected = 0
       ENDIF
      ELSEIF (curaccept="Q")
       SET dpac_response = "Q"
      ENDIF
    ENDWHILE
   ELSE
    SET dpac_config_idx = 0
    SET dpac_config_idx = locateval(dpac_config_idx,1,dads_list->config_cnt,drrr_rf_data->
     ads_config_name,dads_list->config_qual[dpac_config_idx].config_name)
    IF (dpac_config_idx > 0)
     SET dads_list->config_id = dads_list->config_qual[dpac_config_idx].config_id
     EXECUTE dm2_ads_rpt_dkeys
     IF ((dm_err->err_ind=1))
      SET message = nowindow
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Find config name ",drrr_rf_data->ads_config_name,
      " in completed ADS config list.")
     SET dm_err->emsg = "Failed to find config name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drr_clin_copy_data->ads_config_id = dads_list->config_qual[dpac_config_idx].config_id
    SET drr_clin_copy_data->ads_name = dads_list->config_qual[dpac_config_idx].config_name
    SET drr_clin_copy_data->ads_mod_dt_tm = dads_list->config_qual[dpac_config_idx].config_updt_dt_tm
    SET drr_clin_copy_data->ads_pct = dads_list->config_qual[dpac_config_idx].config_pct
    SET dpac_response = "C"
   ENDIF
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_validate_tgtdblink(dvt_tgt_host,dvt_tgt_ora_ver,dvt_src_host)
   DECLARE dvt_create_link = i2 WITH protect, noconstant(0)
   DECLARE dvt_link_name = vc WITH protect, noconstant("")
   DECLARE dvt_database_name = vc WITH protect, noconstant("")
   DECLARE dvt_link_validated = i2 WITH protect, noconstant(0)
   DECLARE dvt_owner = vc WITH protect, noconstant("")
   IF ((drr_clin_copy_data->process="MIGRATION"))
    SET dvt_link_name = "MIG_TARGET"
   ELSE
    SET dvt_link_name = concat("REPL_",trim(cnvtupper(dm2_install_schema->v500_connect_str)))
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    EXECUTE dm2_create_database_link dvt_link_name, drrr_rf_data->tgt_db_link_cnct_desc, drrr_rf_data
    ->tgt_db_user,
    drrr_rf_data->tgt_db_user_pwd, drrr_rf_data->tgt_db_link_host, drrr_rf_data->tgt_db_link_port,
    drrr_rf_data->tgt_db_link_svc_nm, drrr_rf_data->tgt_db_cred_nm, 1,
    0
   ELSE
    EXECUTE dm2_create_database_link dvt_link_name, dm2_install_schema->v500_connect_str, "V500",
    dm2_install_schema->v500_p_word, " ", " ",
    " ", " ", 1,
    0
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (validate(dm2_bypass_src_to_tgt_dblink_verify_ind,- (1)) != 1)
    WHILE (dvt_link_validated=0)
      SET dm_err->eproc = concat("Validating database link ",trim(dvt_link_name),
       " in Source database ",trim(dm2_install_schema->src_dbase_name)," to Target database ",
       trim(dm2_install_schema->target_dbase_name))
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT
       IF (dvt_tgt_ora_ver <= 11)
        FROM (parser(concat("v$database@",trim(dvt_link_name))) v)
       ELSE
        FROM (parser(concat("v$pdbs@",trim(dvt_link_name))) v)
       ENDIF
       INTO "nl:"
       DETAIL
        dvt_database_name = v.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL echo("ABOVE ERROR IS IGNORABLE")
      ENDIF
      IF ((((dm_err->err_ind=1)) OR (cnvtupper(dvt_database_name) != cnvtupper(dm2_install_schema->
       target_dbase_name))) )
       SET dm_err->err_ind = 0
       IF (validate(drrr_responsefile_in_use,0)=0)
        SET message = window
        CALL clear(1,1)
        CALL box(1,1,24,131)
        CALL text(2,2,"[Replicate] Source TNS Entry confirmation for Target Database")
        CALL text(4,2,concat("Please verify that appropriate",
          " TNS connect string entry exists for Target database [",trim(dm2_install_schema->
           target_dbase_name),"]."))
        CALL text(5,2,concat("on the SOURCE database node [",trim(dvt_src_host),"]"))
        CALL text(21,2,"Enter 'C' to Continue or 'Q' to Quit (C or Q) :")
        CALL accept(21,80,"A;cu"," "
         WHERE curaccept IN ("C", "Q"))
        SET message = nowindow
        IF (curaccept="Q")
         SET dm_err->err_ind = 1
         SET dm_err->emsg =
         "User choose to Quit from [Replicate] Source TNS Entry confirmation screen."
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Failed to validate database link ",trim(dvt_link_name),
         " in Source database ",trim(dm2_install_schema->src_dbase_name)," to Target database ",
         trim(dm2_install_schema->target_dbase_name))
        SET dm_err->user_action = concat("Please verify that appropriate Target database ",
         "TNS connect string entry exists for Target database [",trim(dm2_install_schema->
          target_dbase_name),"] on the Source database [",trim(dm2_install_schema->src_dbase_name),
         "] node [",trim(dvt_src_host),"].")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
      ELSE
       SET dvt_link_validated = 1
      ENDIF
    ENDWHILE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_set_src_env_path(null)
   DECLARE dsse_str = vc WITH protect, noconstant("")
   DECLARE dsse_tmp_str = vc WITH protext, noconstant("")
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("temp_location = ",drr_clin_copy_data->temp_location))
    CALL echo(build("tgt_env_name = ",drr_clin_copy_data->tgt_env_name))
    CALL echo(build("src_env_name = ",drr_clin_copy_data->src_domain_name))
   ENDIF
   SET dsse_str = substring(1,(size(drr_clin_copy_data->temp_location) - 1),drr_clin_copy_data->
    temp_location)
   CALL echo(build("dsse_str =",dsse_str))
   SET dsse_tmp_str = cnvtlower(substring((findstring("/",dsse_str,1,1)+ 1),size(drr_clin_copy_data->
      tgt_env_name),dsse_str))
   CALL echo(build("search_str =",dsse_tmp_str))
   IF (cnvtlower(drr_clin_copy_data->tgt_env_name)=dsse_tmp_str)
    SET drr_env_hist_misc->path = replace(drr_clin_copy_data->temp_location,cnvtlower(
      drr_clin_copy_data->tgt_env_name),cnvtlower(drr_clin_copy_data->src_domain_name),2)
   ELSE
    IF ((dm2_sys_misc->cur_os != "AXP"))
     SET drr_env_hist_misc->path = concat(drr_clin_copy_data->temp_location,cnvtlower(
       drr_clin_copy_data->src_domain_name),"/")
    ELSE
     SET dsse_str = concat(".",drr_clin_copy_data->src_domain_name,"]")
     SET drr_env_hist_misc->path = replace(drr_clin_copy_data->temp_location,"]",dsse_str,2)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("drr_env_hist_misc->path = ",drr_env_hist_misc->path))
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_validate_adm_env_csv(dvae_path,dvae_src_env)
   SET dm_err->eproc = "Validate Source environment history files."
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dvae_idx = i4 WITH protect, noconstant(0)
   DECLARE dvae_summary_file = vc WITH protect, noconstant("")
   SET drr_env_hist_misc->cnt = 0
   SET stat = alterlist(drr_env_hist_misc->qual,0)
   IF ( NOT (dm2_find_dir(dvae_path)))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validate directory passed in during drr_validate_adm_env_csv."
    SET dm_err->emsg = concat("Fail to find directory ",dvae_path)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drr_env_hist_misc->summary_file = concat("dm2_",trim(cnvtlower(dvae_src_env)),
    "_env_hist_summary.txt")
   IF (dm2_findfile(concat(dvae_path,drr_env_hist_misc->summary_file))=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validate if file ",dvae_path,trim(drr_env_hist_misc->summary_file),
     " exists.")
    SET dm_err->emsg =
    "Source environment history summary files could not be found in temporary directory provided."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dvae_summary_file = concat(dvae_path,drr_env_hist_misc->summary_file)
   SET dm_err->eproc = concat("Load file ",dvae_summary_file)
   CALL disp_msg("",dm_err->logfile,0)
   FREE SET inputfile
   SET logical inputfile dvae_summary_file
   FREE DEFINE rtl2
   DEFINE rtl2 "inputfile"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0, begin_ptr = 0, end_ptr = 0
    DETAIL
     IF (trim(r.line) != "")
      drr_env_hist_misc->cnt = (drr_env_hist_misc->cnt+ 1), cnt = drr_env_hist_misc->cnt, stat =
      alterlist(drr_env_hist_misc->qual,cnt),
      begin_ptr = findstring(",",r.line), end_ptr = findstring(",",r.line,(begin_ptr+ 1)),
      drr_env_hist_misc->qual[cnt].table_name = trim(substring(1,(begin_ptr - 1),r.line)),
      drr_env_hist_misc->qual[cnt].table_alias = trim(substring((begin_ptr+ 1),((end_ptr - begin_ptr)
         - 1),r.line)), begin_ptr = findstring(",",r.line,(end_ptr+ 1)), drr_env_hist_misc->qual[cnt]
      .csv_file_name = trim(substring((end_ptr+ 1),((begin_ptr - end_ptr) - 1),r.line)),
      end_ptr = findstring(",",r.line,(begin_ptr+ 1)), drr_env_hist_misc->qual[cnt].row_count = trim(
       substring((begin_ptr+ 1),((end_ptr - begin_ptr) - 1),r.line)), drr_env_hist_misc->qual[cnt].
      date = trim(substring((end_ptr+ 1),(textlen(r.line) - end_ptr),r.line))
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_env_hist_misc->qual,cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_env_hist_misc)
   ENDIF
   FOR (dvae_idx = 1 TO drr_env_hist_misc->cnt)
     IF (cnvtint(drr_env_hist_misc->qual[dvae_idx].row_count) > 0)
      IF (dm2_findfile(concat(dvae_path,drr_env_hist_misc->qual[dvae_idx].csv_file_name))=0)
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat("Validate if file ",dvae_path,trim(drr_env_hist_misc->qual[dvae_idx
         ].csv_file_name)," exists.")
       SET dm_err->emsg =
       "Source environment history files could not be found in temporary directory provided."
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_column_and_ccldef_exists(dcce_table_name,dcce_column_name,dcce_exists_ind)
   DECLARE dcce_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcce_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcce_data_type = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Validate existance of column ",dcce_column_name," on ",dcce_table_name
    )
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm2_table_column_exists(value(currdbuser),dcce_table_name,dcce_column_name,1,1,
    1,dcce_col_oradef_ind,dcce_col_ccldef_ind,dcce_data_type)=0)
    RETURN(0)
   ENDIF
   IF (dcce_col_oradef_ind=1
    AND dcce_col_ccldef_ind=1)
    SET dcce_exists_ind = 1
   ELSE
    SET dcce_exists_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_identify_was_usage(diwu_domain,diwu_was_ind)
   DECLARE diwu_exists_ind = i2 WITH protect, noconstant(0)
   SET diwu_was_ind = 0
   IF (dm2_table_and_ccldef_exists("EA_USER",diwu_exists_ind)=0)
    RETURN(0)
   ENDIF
   IF (diwu_exists_ind=0)
    SET diwu_was_ind = 0
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM ea_user eu
    WHERE cnvtupper(eu.realm)=cnvtupper(diwu_domain)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET diwu_was_ind = 1
    SET dm_err->eproc = "WAS Security architecture is turned ON"
   ELSE
    SET dm_err->eproc = "WAS Security architecture is turned OFF"
   ENDIF
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_col_checks(drcc_src,drcc_sti,drcc_sci,drcc_pti,drcc_pci,drcc_tti,drcc_tc)
   IF (drcc_src="T")
    SET curalias drcc_src_col tgtsch->tbl[drcc_sti].tbl_col[drcc_sci]
   ELSEIF (drcc_src="C")
    SET curalias drcc_src_col cur_sch->tbl[drcc_sti].tbl_col[drcc_sci]
   ENDIF
   SET curalias drcc_pre_tbl drr_preserved_tables_data->tbl[drcc_pti]
   SET curalias drcc_pre_col drr_preserved_tables_data->tbl[drcc_pti].col[drcc_pci]
   SET curalias drcc_tgt_col tgtsch->tbl[drcc_tti].tbl_col[drcc_tc]
   SET dm_err->eproc = "Check for preserve restore column mismatch for source and target"
   IF ((drcc_src_col->data_length != drcc_pre_col->data_length))
    SET drcc_pre_col->diff_dlength_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    IF ((drcc_pre_col->data_length > drcc_src_col->data_length))
     SET drcc_tgt_col->data_length = drcc_pre_col->data_length
    ELSE
     SET drcc_tgt_col->data_length = drcc_src_col->data_length
    ENDIF
   ENDIF
   IF ((drcc_src_col->data_type != drcc_pre_col->data_type))
    SET drcc_pre_col->diff_dtype_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    IF ( NOT ((drcc_src_col->data_type IN ("CHAR*", "VARCHAR*", "NUMBER", "FLOAT")))
     AND  NOT ((drcc_pre_col->data_type IN ("CHAR*", "VARCHAR*", "NUMBER", "FLOAT"))))
     SET drr_preserved_tables_data->restore_foul = 1
     SET drcc_pre_tbl->restore_foul = 1
     SET drcc_pre_tbl->reason_cnt = (drcc_pre_tbl->reason_cnt+ 1)
     SET stat = alterlist(drcc_pre_tbl->restore_foul_reasons,drcc_pre_tbl->reason_cnt)
     SET drcc_pre_tbl->restore_foul_reasons[drcc_pre_tbl->reason_cnt].text =
     "Column data type differences found that are not supported."
    ELSE
     IF ((drcc_src_col->data_type="*CHAR*"))
      SET drcc_tgt_col->data_type = "VARCHAR2"
     ELSE
      SET drcc_tgt_col->data_type = drcc_src_col->data_type
     ENDIF
    ENDIF
   ENDIF
   IF ((((drcc_src_col->data_default_ni != drcc_pre_col->data_default_ni)) OR ((drcc_src_col->
   data_default_ni=drcc_pre_col->data_default_ni)
    AND (drcc_src_col->data_default != drcc_pre_col->data_default))) )
    SET drcc_pre_col->diff_default_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    SET drcc_tgt_col->data_default = drcc_src_col->data_default
    SET drcc_tgt_col->data_default_ni = drcc_src_col->data_default_ni
   ENDIF
   IF ((drcc_src_col->nullable != drcc_pre_col->nullable))
    SET drcc_pre_col->diff_nullable_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    SET drcc_tgt_col->nullable = drcc_pre_col->nullable
   ENDIF
   SET curalias drcc_src_col off
   SET curalias drcc_pre_tbl off
   SET curalias drcc_pre_col off
   SET curalias drcc_tgt_col off
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_tbl_checks(drtc_src,drtc_sti,drtc_pti)
   DECLARE drtc_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drtc_pre_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drtc_src_col_idx = i2 WITH protect, noconstant(0)
   IF (drtc_src="T")
    SET curalias drtc_src_rs tgtsch->tbl[drtc_sti]
   ELSEIF (drtc_src="C")
    SET curalias drtc_src_rs cur_sch->tbl[drtc_sti]
   ENDIF
   SET curalias drtc_pre_tbl drr_preserved_tables_data->tbl[drtc_pti]
   SET dm_err->eproc = "Check for preserve restore table mismatch for source and target"
   FOR (drtc_src_idx = 1 TO drtc_src_rs->tbl_col_cnt)
     SET drtc_col_idx = 0
     SET drtc_col_idx = locateval(drtc_col_idx,1,drtc_pre_tbl->col_cnt,drtc_src_rs->tbl_col[
      drtc_src_idx].col_name,drtc_pre_tbl->col[drtc_col_idx].col_name)
     IF (drtc_col_idx=0)
      SET drtc_pre_tbl->extra_src_cols = 1
      IF ((dm2_rdbms_version->level1 >= 11))
       SET drtc_pre_tbl->restore_in_phases = 1
       IF ((drtc_pre_tbl->long_cols_exist > 0))
        SET drr_preserved_tables_data->restore_foul = 1
        SET drtc_pre_tbl->restore_foul = 1
        SET drtc_pre_tbl->reason_cnt = (drtc_pre_tbl->reason_cnt+ 1)
        SET stat = alterlist(drtc_pre_tbl->restore_foul_reasons,drtc_pre_tbl->reason_cnt)
        SET drtc_pre_tbl->restore_foul_reasons[drtc_pre_tbl->reason_cnt].text =
        "Extra Source columns not in Preserved table and Preserved table contains [long/long raw] columns."
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (drtc_src="C")
    FOR (drtc_pre_col_idx = 1 TO drtc_pre_tbl->col_cnt)
      SET drtc_src_col_idx = 0
      SET drtc_src_col_idx = locateval(drtc_src_col_idx,1,drtc_src_rs->tbl_col_cnt,drtc_pre_tbl->col[
       drtc_pre_col_idx].col_name,drtc_src_rs->tbl_col[drtc_src_col_idx].col_name)
      IF (drtc_src_col_idx=0)
       SET drtc_pre_tbl->extra_pre_cols = 1
      ENDIF
    ENDFOR
   ENDIF
   SET curalias drtc_pre_tbl off
   SET curalias drtc_src_rs off
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_report(null)
   DECLARE drr_tbl_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_grp_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_tblr_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_grpr_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_foul_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_rpt_file = vc WITH protect, noconstant("")
   DECLARE drr_tbl_first = i2 WITH protect, noconstant(0)
   DECLARE drr_col_first = i2 WITH protect, noconstant(0)
   DECLARE drr_res_first = i2 WITH protect, noconstant(0)
   DECLARE drr_grp_str = vc WITH protect, noconstant("")
   DECLARE drr_fact_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_fact_idxg = i2 WITH protect, noconstant(0)
   DECLARE drr_grp_cnt = i2 WITH protect, noconstant(0)
   DECLARE drr_tbl_cnt = i2 WITH protect, noconstant(0)
   DECLARE drr_col_cnt = i2 WITH protect, noconstant(0)
   DECLARE drr_rep_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_str = vc WITH protect, noconstant("")
   DECLARE drr_rrd_str = vc WITH protect, noconstant("")
   DECLARE drr_no_cols = i2 WITH protect, noconstant(0)
   IF (validate(drr_res_rpt->grp_cnt,1)=1
    AND validate(drr_res_rpt->grp_cnt,2)=2)
    FREE RECORD drr_res_rpt
    RECORD drr_res_rpt(
      1 grp_cnt = i2
      1 grp[*]
        2 group = vc
        2 refresh_ind = i2
        2 tbl_cnt = i2
        2 tbl[*]
          3 tbl_name = vc
          3 foul_reason = vc
        2 fact_cnt = i2
        2 fact[*]
          3 tbl_name = vc
          3 tbl_not_in_src = i2
          3 extra_src_cols = i2
          3 extra_pre_cols = i2
          3 col_diff = i2
          3 refresh_ind = i2
          3 restore_foul = i2
          3 col_cnt = i2
          3 col[*]
            4 col_name = vc
            4 diff_dtype_ind = i2
            4 diff_dlength_ind = i2
            4 diff_nullable_ind = i2
            4 diff_default_ind = i2
    )
    SET drr_res_rpt->grp_cnt = 0
   ENDIF
   SET dm_err->eproc = "Loading Foul Reason and Table Facts into record structure"
   FOR (drr_tbl_idx = 1 TO drr_preserved_tables_data->cnt)
     SET drr_grp_idx = 0
     SET drr_grp_idx = locateval(drr_grp_idx,1,drr_res_rpt->grp_cnt,drr_preserved_tables_data->tbl[
      drr_tbl_idx].group,drr_res_rpt->grp[drr_grp_idx].group)
     IF (drr_grp_idx=0)
      SET drr_res_rpt->grp_cnt = (drr_res_rpt->grp_cnt+ 1)
      SET stat = alterlist(drr_res_rpt->grp,drr_res_rpt->grp_cnt)
      SET drr_res_rpt->grp[drr_res_rpt->grp_cnt].group = drr_preserved_tables_data->tbl[drr_tbl_idx].
      group
      SET drr_res_rpt->grp[drr_res_rpt->grp_cnt].refresh_ind = drr_preserved_tables_data->tbl[
      drr_tbl_idx].refresh_ind
      SET drr_grp_idx = drr_res_rpt->grp_cnt
     ENDIF
     IF ((drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind=1)
      AND (drr_preserved_tables_data->tbl[drr_tbl_idx].restore_foul=1))
      FOR (drr_foul_idx = 1 TO drr_preserved_tables_data->tbl[drr_tbl_idx].reason_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].tbl_cnt = (drr_res_rpt->grp[drr_res_rpt->grp_cnt].tbl_cnt+
        1)
        SET stat = alterlist(drr_res_rpt->grp[drr_grp_idx].tbl,drr_res_rpt->grp[drr_grp_idx].tbl_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].tbl[drr_res_rpt->grp[drr_grp_idx].tbl_cnt].tbl_name =
        drr_preserved_tables_data->tbl[drr_tbl_idx].table_name
        SET drr_res_rpt->grp[drr_grp_idx].tbl[drr_res_rpt->grp[drr_grp_idx].tbl_cnt].foul_reason =
        drr_preserved_tables_data->tbl[drr_tbl_idx].restore_foul_reasons[drr_foul_idx].text
      ENDFOR
     ENDIF
     IF ((((drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind=1)) OR ((
     drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind=0)
      AND (drr_preserved_tables_data->tbl[drr_tbl_idx].pres_tbl_not_in_src=1))) )
      SET drr_res_rpt->grp[drr_grp_idx].fact_cnt = (drr_res_rpt->grp[drr_grp_idx].fact_cnt+ 1)
      SET stat = alterlist(drr_res_rpt->grp[drr_grp_idx].fact,drr_res_rpt->grp[drr_grp_idx].fact_cnt)
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].tbl_name =
      drr_preserved_tables_data->tbl[drr_tbl_idx].table_name
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].tbl_not_in_src
       = drr_preserved_tables_data->tbl[drr_tbl_idx].pres_tbl_not_in_src
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].extra_src_cols
       = drr_preserved_tables_data->tbl[drr_tbl_idx].extra_src_cols
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].extra_pre_cols
       = drr_preserved_tables_data->tbl[drr_tbl_idx].extra_pre_cols
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].col_diff =
      drr_preserved_tables_data->tbl[drr_tbl_idx].col_diff
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].refresh_ind =
      drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].restore_foul =
      drr_preserved_tables_data->tbl[drr_tbl_idx].restore_foul
      SET drr_tbl_cnt = drr_res_rpt->grp[drr_grp_idx].fact_cnt
      FOR (drr_col_idx = 1 TO drr_preserved_tables_data->tbl[drr_tbl_idx].col_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col_cnt = (drr_res_rpt->grp[drr_grp_idx].
        fact[drr_tbl_cnt].col_cnt+ 1)
        SET drr_col_cnt = drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col_cnt
        SET stat = alterlist(drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col,drr_col_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].col_name =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].col_name
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_dtype_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_dtype_ind
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_dlength_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_dlength_ind
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_nullable_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_nullable_ind
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_default_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_default_ind
      ENDFOR
     ENDIF
   ENDFOR
   IF (get_unique_file("dm2_res_rpt",".rpt")=0)
    RETURN(0)
   ENDIF
   SET drr_rpt_file = dm_err->unique_fname
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET drr_rpt_file = build(drrr_misc_data->active_dir,drr_rpt_file)
   ENDIF
   SET drr_preserved_tables_data->res_rep_name = drr_rpt_file
   SET dm_err->eproc = "Generating report for Restore Preserve Tables"
   IF ((drr_res_rpt->grp_cnt > 0))
    SET drr_preserved_tables_data->foul_grp_str = " "
    SET drr_rrd_str = " "
    SELECT INTO value(drr_rpt_file)
     FROM (dummyt t  WITH seq = 1)
     HEAD REPORT
      col 90, "RESTORE GROUP REPORT", row + 2,
      col 0, "Restore Groups: "
      FOR (drr_grp_idx = 1 TO drr_res_rpt->grp_cnt)
        IF ((drr_res_rpt->grp[drr_grp_idx].refresh_ind=1))
         IF ((drr_res_rpt->grp[drr_grp_idx].group != "NOPROMPT"))
          IF (drr_grp_idx=1
           AND (drr_grp_idx != drr_res_rpt->grp_cnt))
           drr_grp_str = concat(drr_res_rpt->grp[drr_grp_idx].group,", ")
          ELSEIF ((drr_grp_idx=drr_res_rpt->grp_cnt))
           drr_grp_str = concat(drr_grp_str,drr_res_rpt->grp[drr_grp_idx].group)
          ELSE
           drr_grp_str = concat(drr_grp_str,drr_res_rpt->grp[drr_grp_idx].group,", ")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      col 30, drr_grp_str
     DETAIL
      FOR (drr_grp_idx = 1 TO drr_res_rpt->grp_cnt)
        IF ((drr_res_rpt->grp[drr_grp_idx].tbl_cnt > 0))
         IF ((drr_preserved_tables_data->foul_grp_str=""))
          drr_preserved_tables_data->foul_grp_str = drr_res_rpt->grp[drr_grp_idx].group
         ELSE
          drr_preserved_tables_data->foul_grp_str = concat(drr_preserved_tables_data->foul_grp_str,
           ",",drr_res_rpt->grp[drr_grp_idx].group)
         ENDIF
        ENDIF
      ENDFOR
      IF ((drr_preserved_tables_data->foul_grp_str="*PRINTERS*")
       AND (drr_preserved_tables_data->foul_grp_str != "*RRD*")
       AND drr_grp_str="*RRD*")
       drr_preserved_tables_data->foul_grp_str = concat(drr_preserved_tables_data->foul_grp_str,
        ",RRD"), drr_rrd_str =
       "* RRD forced to be deselected along with PRINTERS (RRD  has no invalid tables)."
      ENDIF
      IF ((drr_preserved_tables_data->restore_foul=1))
       row + 1, col 0, "Invalid Restore Groups: ",
       col 30, drr_preserved_tables_data->foul_grp_str
       IF (drr_rrd_str != " ")
        row + 2, col 0, drr_rrd_str,
        row + 1, col 0,
        "USER ACTION: Invalid Restore Groups must be deselected in order to continue process."
       ELSE
        row + 2, col 0,
        "USER ACTION: Invalid Restore Groups must be deselected in order to continue process."
       ENDIF
       row + 2, col 0, "INVALID RESTORE GROUP/TABLE REASONS",
       row + 2, col 0, "GROUP",
       col 17, "TABLE", col 49,
       "REASON", row + 1, col 0,
       CALL print(fillstring(15,"-")), col 17,
       CALL print(fillstring(30,"-")),
       col 49,
       CALL print(fillstring(30,"-"))
       FOR (drr_grpr_idx = 1 TO drr_res_rpt->grp_cnt)
         IF ((drr_res_rpt->grp[drr_grpr_idx].tbl_cnt > 0))
          row + 1, col 0, drr_res_rpt->grp[drr_grpr_idx].group,
          drr_res_first = 1
          FOR (drr_tblr_idx = 1 TO drr_res_rpt->grp[drr_grpr_idx].tbl_cnt)
            IF (drr_res_first=1)
             drr_res_first = 0, col 17, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].tbl_name,
             col 49, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].foul_reason
            ELSE
             row + 1, col 17, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].tbl_name,
             col 49, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].foul_reason
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       drr_str = concat(
        "* Tables with an asterisk (*) in following RESTORE TABLE/COLUMN DIFFERENCES section",
        "are those tables that are part of a restore group that must be deselected."), row + 2, col 0,
       drr_str
      ENDIF
      row + 2, col 0, "RESTORE TABLE/COLUMN DIFFERENCES",
      row + 2, col 49, "TABLE EXISTS",
      col 63, "MARK FOR", col 73,
      "EXTRA COLUMNS", col 88, "EXTRA COLUMNS",
      col 103, "  COLUMN", col 147,
      "DIFF", col 153, "DIFF",
      col 161, "DIFF", col 171,
      "DIFF", row + 1, col 0,
      "GROUP", col 17, "TABLE NAME",
      col 49, "IN SOURCE", col 63,
      "RESTORE", col 73, "IN SOURCE",
      col 88, "IN TARGET", col 103,
      "DIFFERENCE", col 115, "COLUMN NAME",
      col 147, "TYPE", col 153,
      "LENGTH", col 161, "NULLABLE",
      col 171, "DEFAULT", row + 1,
      col 0,
      CALL print(fillstring(15,"-")), col 17,
      CALL print(fillstring(30,"-")), col 49,
      CALL print(fillstring(12,"-")),
      col 63,
      CALL print(fillstring(8,"-")), col 73,
      CALL print(fillstring(13,"-")), col 88,
      CALL print(fillstring(13,"-")),
      col 103,
      CALL print(fillstring(10,"-")), col 115,
      CALL print(fillstring(30,"-")), col 147,
      CALL print(fillstring(4,"-")),
      col 153,
      CALL print(fillstring(6,"-")), col 161,
      CALL print(fillstring(8,"-")), col 171,
      CALL print(fillstring(7,"-")),
      drr_no_cols = 1
      FOR (drr_fact_idxg = 1 TO drr_res_rpt->grp_cnt)
        IF ((drr_res_rpt->grp[drr_fact_idxg].group != "NOPROMPT"))
         drr_tbl_first = 1
         FOR (drr_fact_idx = 1 TO drr_res_rpt->grp[drr_fact_idxg].fact_cnt)
           IF ((((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
            AND (((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src=1)) OR ((((
           drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].extra_src_cols=1)) OR ((((drr_res_rpt->
           grp[drr_fact_idxg].fact[drr_fact_idx].extra_pre_cols=1)) OR ((drr_res_rpt->grp[
           drr_fact_idxg].fact[drr_fact_idx].col_diff=1))) )) )) ) OR ((drr_res_rpt->grp[
           drr_fact_idxg].fact[drr_fact_idx].refresh_ind=0)
            AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src=1))) )
            IF (drr_tbl_first=1)
             IF (drr_no_cols=1)
              drr_no_cols = 0
             ENDIF
             drr_tbl_first = 0
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].restore_foul=1))
              row + 1, col 0, drr_res_rpt->grp[drr_fact_idxg].group,
              col 16, "*"
             ELSE
              row + 1, col 0, drr_res_rpt->grp[drr_fact_idxg].group
             ENDIF
             col 17, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_name
            ELSE
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].restore_foul=1))
              row + 1, col 16, "*",
              col 17, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_name
             ELSE
              row + 1, col 17, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_name
             ENDIF
            ENDIF
            IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
             AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src != 1))
             col 49, "Y"
            ELSE
             col 49, "N"
            ENDIF
            IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=0)
             AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src=1))
             col 63, "N"
            ELSE
             col 63, "Y"
            ENDIF
            IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src != 1))
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].extra_src_cols=1))
              col 73, "Y"
             ELSE
              col 73, "N"
             ENDIF
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].extra_pre_cols=1))
              col 88, "Y"
             ELSE
              col 88, "N"
             ENDIF
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col_diff=1))
              col 103, "Y", drr_col_first = 1
              FOR (drr_rep_col_idx = 1 TO drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col_cnt)
                IF ((((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_dtype_ind=1)) OR ((((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[
                drr_rep_col_idx].diff_dlength_ind=1)) OR ((((drr_res_rpt->grp[drr_fact_idxg].fact[
                drr_fact_idx].col[drr_rep_col_idx].diff_nullable_ind=1)) OR ((drr_res_rpt->grp[
                drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].diff_default_ind=1))) )) )) )
                 IF (drr_col_first=1)
                  drr_col_first = 0, col 115, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[
                  drr_rep_col_idx].col_name
                 ELSE
                  row + 1, col 115, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[
                  drr_rep_col_idx].col_name
                 ENDIF
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_dtype_ind=1))
                 col 147, "Y"
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_dlength_ind=1))
                 col 153, "Y"
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_nullable_ind=1))
                 col 161, "Y"
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_default_ind=1))
                 col 171, "Y"
                ENDIF
              ENDFOR
             ELSE
              col 103, "N"
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      IF (drr_no_cols=1)
       row + 2, col 0, "No table/column differences found."
      ENDIF
     WITH nocounter, maxcol = 250, format = variable,
      formfeed = none
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_no_cols=1)
    SET dm_err->eproc = concat("Skipping display of RESTORE GROUP REPORT (",drr_rpt_file,
     ") upon no differences")
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ELSE
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = concat("Skipping display of RESTORE GROUP REPORT (",drr_rpt_file,")")
     CALL disp_msg("",dm_err->logfile,0)
     IF ((drer_email_list->email_cnt > 0)
      AND (drr_res_rpt->grp_cnt > 0))
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "RESTORE GROUP REPORT"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      SET drer_email_det->attachment = drr_rpt_file
      CALL drer_add_body_text(concat("RESTORE GROUP REPORT was generated at ",format(drer_email_det->
         status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat("User Action : Please review the report to ensure ",
        "no invalid reasons exist for the tables."),0)
      CALL drer_add_body_text(concat("Report file name : ",trim(drr_rpt_file,3)),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
    ELSE
     IF ((dm2_install_schema->process_option="CLIN COPY")
      AND (drer_email_list->email_cnt > 0))
      SET drer_email_det->process = drr_clin_copy_data->process
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "PAUSED"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "RESTORE GROUP REPORT"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("RESTORE GROUP REPORT ","was displayed at ",format(
         drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat("User Action : Return to dm2_domain_maint main session and ",
        "review Restore Group Report displayed on the screen.  Press <enter> to continue."),0)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",drr_rpt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
     IF (dm2_disp_file(drr_rpt_file," ")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_col_mismatch(null)
   DECLARE drcm_pre_t = i2 WITH protect, noconstant(0)
   DECLARE drcm_tgt_t = i2 WITH protect, noconstant(0)
   DECLARE drcm_cur_t = i2 WITH protect, noconstant(0)
   DECLARE drcm_tgt_c = i2 WITH protect, noconstant(0)
   DECLARE drcm_cur_c = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check for preserve restore column mismatch for source and target"
   FOR (drcm_pre_t = 1 TO drr_preserved_tables_data->cnt)
     IF ((drr_preserved_tables_data->tbl[drcm_pre_t].refresh_ind=1))
      SET drcm_tgt_t = drr_preserved_tables_data->tbl[drcm_pre_t].tgtsch_idx
      IF (drcm_tgt_t > 0)
       SET drcm_cur_t = 0
       SET drcm_cur_t = locateval(drcm_cur_t,1,cur_sch->tbl_cnt,drr_preserved_tables_data->tbl[
        drcm_pre_t].table_name,cur_sch->tbl[drcm_cur_t].tbl_name)
       IF (drcm_cur_t > 0)
        FOR (drcm_pre_c = 1 TO drr_preserved_tables_data->tbl[drcm_pre_t].col_cnt)
          SET drcm_tgt_c = 0
          SET drcm_tgt_c = locateval(drcm_tgt_c,1,tgtsch->tbl[drcm_tgt_t].tbl_col_cnt,
           drr_preserved_tables_data->tbl[drcm_pre_t].col[drcm_pre_c].col_name,tgtsch->tbl[drcm_tgt_t
           ].tbl_col[drcm_tgt_c].col_name)
          IF (drcm_tgt_c > 0)
           SET drcm_cur_c = 0
           SET drcm_cur_c = locateval(drcm_cur_c,1,cur_sch->tbl[drcm_cur_t].tbl_col_cnt,
            drr_preserved_tables_data->tbl[drcm_pre_t].col[drcm_pre_c].col_name,cur_sch->tbl[
            drcm_cur_t].tbl_col[drcm_cur_c].col_name)
           IF (drcm_cur_c > 0)
            IF (drr_restore_col_checks("C",drcm_cur_t,drcm_cur_c,drcm_pre_t,drcm_pre_c,
             drcm_tgt_t,drcm_tgt_c)=0)
             SET dm_err->err_ind = 1
             RETURN(0)
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_tbl_mismatch(null)
   DECLARE drtm_pre_t = i2 WITH protect, noconstant(0)
   DECLARE drtm_tgt_t = i2 WITH protect, noconstant(0)
   DECLARE drtm_cur_t = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check for preserve restore table mismatch for source and target"
   FOR (drtm_pre_t = 1 TO drr_preserved_tables_data->cnt)
     IF ((drr_preserved_tables_data->tbl[drtm_pre_t].refresh_ind=1))
      SET drtm_tgt_t = 0
      SET drtm_tgt_t = locateval(drtm_tgt_t,1,tgtsch->tbl_cnt,drr_preserved_tables_data->tbl[
       drtm_pre_t].table_name,tgtsch->tbl[drtm_tgt_t].tbl_name)
      IF (drtm_tgt_t > 0)
       IF ((drr_clin_copy_data->process="RESTORE"))
        SET drtm_cur_t = 0
        SET drtm_cur_t = locateval(drtm_cur_t,1,cur_sch->tbl_cnt,drr_preserved_tables_data->tbl[
         drtm_pre_t].table_name,cur_sch->tbl[drtm_cur_t].tbl_name)
        IF (drtm_cur_t > 0)
         IF (drr_restore_tbl_checks("C",drtm_cur_t,drtm_pre_t)=0)
          RETURN(0)
         ENDIF
        ENDIF
       ELSE
        IF (drr_restore_tbl_checks("T",drtm_tgt_t,drtm_pre_t)=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (drr_restore_report(null)=0)
    RETURN(0)
   ENDIF
   IF ((drr_preserved_tables_data->restore_foul=1))
    SET dm_err->err_ind = 1
    SET dm_err->eproc =
    "Validating preserved tables to be restored for acceptable column differences in order to successfully complete restore."
    SET dm_err->emsg = concat(
     "Preserved tables to be restored have column differences that prevent ability to restore table(s)",
     ".  The following preserved table groups cannot be restored:  ",drr_preserved_tables_data->
     foul_grp_str,".  In order to continue process, de-select these groups that cannot be restored",
     ".  For explanation of those table column differences preventing restore, see")
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->emsg = concat(dm_err->emsg," ",drr_preserved_tables_data->res_rep_name,".")
    ELSE
     SET dm_err->emsg = concat(dm_err->emsg," ",drr_preserved_tables_data->res_rep_name,
      " located in CCLUSERDIR.")
    ENDIF
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_drr_copy(dcdc_drr_cleanup)
   SET dcdc_drr_cleanup = "NONE"
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF (cnvtupper(drrr_rf_data->tgt_expimp_drr_shadow_tables)="NO"
     AND cnvtupper(drr_clin_copy_data->process)="RESTORE")
     SET dcdc_drr_cleanup = "RR_ALL"
    ENDIF
   ELSEIF (cnvtupper(drr_clin_copy_data->process)="RESTORE")
    SET dcdc_drr_cleanup = "ALL"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_chunk_imp_tbls(dlcit_db_link,dlcit_load_chunks_ind)
   DECLARE dlcit_dblink_exists = i2 WITH protect, noconstant(0)
   DECLARE dlcit_chunk_tbl_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlcit_tmp = i4 WITH protect, noconstant(0)
   DECLARE dlcit_clu_tbl_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlcit_di_tbl_owner = vc WITH protect, noconstant("")
   DECLARE dlcit_di_tbl_name = vc WITH protect, noconstant("")
   DECLARE dlcit_where_clause = vc WITH protect, noconstant("")
   DECLARE dlcit_dba_extents = vc WITH protect, noconstant("")
   DECLARE dlcit_dba_objects = vc WITH protect, noconstant("")
   DECLARE dlcit_part_cnt = i4 WITH protect, noconstant(0)
   IF (textlen(trim(dlcit_db_link))=0)
    SET dm_err->eproc = "No database link was specified. Skipping database link validation."
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    IF (drr_check_db_link(cnvtupper(trim(dlcit_db_link)),dlcit_dblink_exists)=0)
     RETURN(0)
    ENDIF
    IF (dlcit_dblink_exists=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(dlcit_db_link," dblink does not exist. Cannot progress further.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET stat = initrec(drr_chunk_imp_tbls)
   SET dm_err->eproc = concat("Querying dm_info to check if any tables are marked for chunk imports")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dlcit_dblink_exists=0)
     FROM dm_info di
    ELSE
     FROM (parser(concat("dm_info@",dlcit_db_link)) di)
    ENDIF
    INTO "nl:"
    di.info_name, di.info_number
    WHERE di.info_domain="DM2_RR_CHUNK_IMPORTS"
    ORDER BY di.info_name
    DETAIL
     dlcit_di_tbl_owner = substring(1,(findstring(".",di.info_name,1,0) - 1),di.info_name),
     dlcit_di_tbl_name = substring((findstring(".",di.info_name,1,1)+ 1),textlen(di.info_name),di
      .info_name), drr_chunk_imp_tbls->tbl_cnt = (drr_chunk_imp_tbls->tbl_cnt+ 1)
     IF (mod(drr_chunk_imp_tbls->tbl_cnt,10)=1)
      stat = alterlist(drr_chunk_imp_tbls->tbl,(drr_chunk_imp_tbls->tbl_cnt+ 9))
     ENDIF
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].owner = dlcit_di_tbl_owner,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].table_name = dlcit_di_tbl_name,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].segment_name = dlcit_di_tbl_name,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].orig_num_chunks = di.info_number,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].num_chunks = di.info_number,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].chunk_cnt = 0
    FOOT REPORT
     stat = alterlist(drr_chunk_imp_tbls->tbl,drr_chunk_imp_tbls->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_chunk_imp_tbls->tbl_cnt > 0))
    CALL echo(concat("***",build(drr_chunk_imp_tbls->tbl_cnt," tables qualified for chunk imports***"
       )))
   ELSE
    CALL echo("***No tables qualified for chunk imports***")
   ENDIF
   SET dm_err->eproc = "Querying dba_tables to fetch the list of clustered tables"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dlcit_dblink_exists=0)
     FROM dba_tables dt
    ELSE
     FROM (parser(concat("dba_tables@",dlcit_db_link)) dt)
    ENDIF
    INTO "nl:"
    WHERE dt.owner=currdbuser
     AND dt.cluster_name IS NOT null
    DETAIL
     IF (locateval(dlcit_clu_tbl_ndx,1,drr_chunk_imp_tbls->tbl_cnt,dt.table_name,drr_chunk_imp_tbls->
      tbl[dlcit_clu_tbl_ndx].table_name) > 0)
      drr_chunk_imp_tbls->tbl[dlcit_clu_tbl_ndx].segment_name = dt.cluster_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Querying dba_tables to fetch the list of partitioned tables"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dlcit_dblink_exists=0)
     FROM dba_tables dt
    ELSE
     FROM (parser(concat("dba_tables@",dlcit_db_link)) dt)
    ENDIF
    INTO "nl:"
    WHERE dt.owner=currdbuser
     AND dt.partitioned="YES"
    DETAIL
     IF (locateval(dlcit_clu_tbl_ndx,1,drr_chunk_imp_tbls->tbl_cnt,dt.table_name,drr_chunk_imp_tbls->
      tbl[dlcit_clu_tbl_ndx].table_name) > 0)
      drr_chunk_imp_tbls->tbl[dlcit_clu_tbl_ndx].part_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_chunk_imp_tbls)
   ENDIF
   IF (dlcit_load_chunks_ind=1)
    SET dlcit_dba_extents = concat("dba_extents",evaluate(dlcit_dblink_exists,1,concat("@",
       dlcit_db_link," ")," "))
    SET dlcit_dba_objects = concat("dba_objects",evaluate(dlcit_dblink_exists,1,concat("@",
       dlcit_db_link," ")," "))
    IF ((dm_err->debug_flag > 1))
     CALL echo(concat("dlcit_dba_extents = ",dlcit_dba_extents))
     CALL echo(concat("dlcit_dba_objects = ",dlcit_dba_objects))
    ENDIF
    FOR (dlcit_tbl_idx = 1 TO drr_chunk_imp_tbls->tbl_cnt)
      SET dlcit_where_clause = concat("de.segment_type = 'TABLE'")
      IF ((drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].part_ind=1))
       SET dm_err->eproc = "Obtain number of partitions for partitioned table."
       CALL disp_msg(" ",dm_err->logfile,0)
       SELECT
        IF (dlcit_dblink_exists=0)
         FROM dba_objects do
        ELSE
         FROM (parser(concat("dba_objects@",dlcit_db_link)) do)
        ENDIF
        INTO "nl:"
        tbl_part_cnt = count(*)
        WHERE do.owner=currdbuser
         AND do.object_type="TABLE PARTITION"
         AND (do.object_name=drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].table_name)
        DETAIL
         dlcit_part_cnt = tbl_part_cnt
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       IF ((dlcit_part_cnt > drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks))
        SET drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks = 1
       ELSE
        SET drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks = round((drr_chunk_imp_tbls->tbl[
         dlcit_tbl_idx].num_chunks/ dlcit_part_cnt),0)
       ENDIF
       SET dlcit_where_clause = concat("de.segment_type = 'TABLE PARTITION'")
       SET drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].part_cnt = dlcit_part_cnt
      ENDIF
      SET dm_err->eproc = concat("Load chunk tables to import during reference copy. Processing ",
       drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].table_name)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM (
        (
        (SELECT
         min_rid = sqlpassthru(
          "dbms_rowid.rowid_create( 1, t.data_object_id, t.lo_fno, t.lo_block, 0 )"), max_rid =
         sqlpassthru("dbms_rowid.rowid_create( 1, t.data_object_id, t.hi_fno, t.hi_block, 10000 )")
         FROM (
          (
          (SELECT DISTINCT
           p.grp, sqlpassthru(concat(
             "first_value(p.relative_fno) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) lo_fno")), sqlpassthru(concat(
             "first_value(p.block_id) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) lo_block")),
           sqlpassthru(concat(
             "last_value(p.relative_fno) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) hi_fno")), sqlpassthru(concat(
             "last_value(p.block_id+blocks-1) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) hi_block")), sqlpassthru(
            "sum(blocks) over (partition by grp) sum_blocks"),
           p.data_object_id
           FROM (
            (
            (SELECT
             de.relative_fno, de.block_id, de.blocks,
             sqlpassthru(concat(
               "trunc((sum(de.blocks) over (order by de.relative_fno, de.block_id)-0.01)/(sum(de.blocks) ",
               "over ()/",cnvtstring(drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks),")) grp")),
             do.data_object_id
             FROM (parser(concat(dlcit_dba_extents)) de),
              (parser(concat(dlcit_dba_objects)) do)
             WHERE parser(dlcit_where_clause)
              AND parser(concat("de.owner = '",drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].owner,"'"))
              AND parser(concat("de.segment_name = '",drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].
               segment_name,"'"))
              AND de.owner=do.owner
              AND de.segment_name=do.object_name
              AND de.segment_type=do.object_type))
            p)))
          t)
         ORDER BY min_rid
         WITH sqltype("c30","c30")))
        a)
       DETAIL
        drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunk_cnt = (drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].
        chunk_cnt+ 1), dlcit_tmp = drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunk_cnt
        IF (mod(dlcit_tmp,50)=1)
         stat = alterlist(drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks,(dlcit_tmp+ 49))
        ENDIF
        drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks[dlcit_tmp].min_rid = a.min_rid,
        drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks[dlcit_tmp].max_rid = a.max_rid
       FOOT REPORT
        stat = alterlist(drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks,drr_chunk_imp_tbls->tbl[
         dlcit_tbl_idx].chunk_cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drr_chunk_imp_tbls)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_mixtbl_ref_rows(dgmrr_db_name)
   DECLARE dgmrr_table_name = vc WITH protect, noconstant("")
   DECLARE dgmrr_mix_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Check if there are mixed table reference rows in ",trim(cnvtupper(
      dgmrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_MIXTBL_REFDATA_CNT"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = concat("There are no mixed table reference rows for ",trim(cnvtupper(
       dgmrr_db_name)),".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
   ELSE
    SET dm_err->eproc = concat("Merge DM2_MIXTBL_REFDATA_CNT rows from ",trim(cnvtupper(dgmrr_db_name
       ))," to Admin DM_INFO.")
    CALL disp_msg("",dm_err->logfile,0)
    MERGE INTO dm2_admin_dm_info d
    USING (SELECT
     info_domain, info_name, info_number
     FROM dm_info
     WHERE info_domain="DM2_MIXTBL_REFDATA_CNT")
    DI ON (d.info_domain=di.info_domain
     AND d.info_name=concat(trim(dgmrr_db_name),"_",di.info_name))
    WHEN MATCHED THEN
    (UPDATE
     SET d.info_number = di.info_number, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE 1=1
    ;end update
    )
    WHEN NOT MATCHED THEN
    (INSERT  FROM d
     (info_domain, info_name, info_number,
     updt_dt_tm)
     VALUES("DM2_MIXTBL_REFDATA_CNT", concat(trim(dgmrr_db_name),"_",di.info_name), di.info_number,
     cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end insert
    )
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Remove DM2_MIXTBL_REFDATA_CNT rows from ",trim(cnvtupper(
       dgmrr_db_name))," DM_INFO.")
    CALL disp_msg("",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2_MIXTBL_REFDATA_CNT"
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Obtain latest mixed table reference rows for ",trim(cnvtupper(
      dgmrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain="DM2_MIXTBL_REFDATA_CNT"
     AND d.info_name=patstring(concat(dgmrr_db_name,"_*"))
     AND d.info_number > 0
    DETAIL
     dgmrr_table_name = replace(d.info_name,concat(dgmrr_db_name,"_"),""), dgmrr_mix_idx = 0,
     dgmrr_mix_idx = locateval(dgmrr_mix_idx,1,drr_mixed_tables_data->cnt,dgmrr_table_name,
      drr_mixed_tables_data->tbl[dgmrr_mix_idx].table_name)
     IF (dgmrr_mix_idx > 0)
      drr_mixed_tables_data->tbl[dgmrr_mix_idx].ref_num_rows_set_ind = 1, drr_mixed_tables_data->tbl[
      dgmrr_mix_idx].ref_num_rows = d.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_upd_mixtbl_ref_rows(dumrr_db_name,dumrr_run_id)
   FREE RECORD dumrr_mixed_tables_data
   RECORD dumrr_mixed_tables_data(
     1 cnt = i4
     1 tbl[*]
       2 table_name = vc
       2 num_rows = f8
   )
   DECLARE dumrr_info_name = vc WITH protect, noconstant("")
   DECLARE dumrr_info_number = i4 WITH protect, noconstant(0)
   DECLARE dumrr_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Obtain latest mixed table reference rows for ",trim(cnvtupper(
      dumrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.table_name, dumrr_mixed_row_cnt_sum = sum(d.row_cnt)
    FROM dm2_ddl_ops_log d
    WHERE d.run_id=dumrr_run_id
     AND d.op_type="EXPORT/IMPORT - MIXED DATA (REMOTE)"
     AND d.status="COMPLETE"
    GROUP BY d.table_name
    HEAD REPORT
     dumrr_mixed_tables_data->cnt = 0, stat = alterlist(dumrr_mixed_tables_data->tbl,0)
    DETAIL
     dumrr_mixed_tables_data->cnt = (dumrr_mixed_tables_data->cnt+ 1)
     IF (mod(dumrr_mixed_tables_data->cnt,10)=1)
      stat = alterlist(dumrr_mixed_tables_data->tbl,(dumrr_mixed_tables_data->cnt+ 9))
     ENDIF
     dumrr_mixed_tables_data->tbl[dumrr_mixed_tables_data->cnt].table_name = d.table_name,
     dumrr_mixed_tables_data->tbl[dumrr_mixed_tables_data->cnt].num_rows = dumrr_mixed_row_cnt_sum
    FOOT REPORT
     stat = alterlist(dumrr_mixed_tables_data->tbl,dumrr_mixed_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Update Admin DM_INFO rows for ",trim(cnvtupper(dumrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dumrr_idx = 1 TO dumrr_mixed_tables_data->cnt)
     SET dm_err->eproc = concat("Update Admin DM_INFO row for ",trim(dumrr_mixed_tables_data->tbl[
       dumrr_idx].table_name))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SET dumrr_info_name = concat(trim(cnvtupper(dumrr_db_name)),"_",trim(dumrr_mixed_tables_data->
       tbl[dumrr_idx].table_name))
     SET dumrr_info_number = dumrr_mixed_tables_data->tbl[dumrr_idx].num_rows
     MERGE INTO dm2_admin_dm_info d
     USING DUAL ON (d.info_domain="DM2_MIXTBL_REFDATA_CNT"
      AND d.info_name=trim(dumrr_info_name))
     WHEN MATCHED THEN
     (UPDATE
      SET d.info_number = dumrr_info_number, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE 1=1
     ;end update
     )
     WHEN NOT MATCHED THEN
     (INSERT  FROM d
      (info_domain, info_name, info_number,
      updt_dt_tm)
      VALUES("DM2_MIXTBL_REFDATA_CNT", trim(dumrr_info_name), dumrr_info_number,
      cnvtdatetime(curdate,curtime3))
      WITH nocounter
     ;end insert
     )
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_refresh_drop_restrict(drdr_mode,drdr_restart_ind)
   DECLARE drdr_info_char = vc WITH protect, noconstant("")
   IF ( NOT (drdr_mode IN ("I", "D")))
    SET dm_err->eproc = "Verify the input mode in DM_INFO to drop V500 user in restrict mode."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input mode option."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm2_install_schema->dbase_name = "ADMIN"
   SET dm2_install_schema->u_name = "CDBA"
   SET dm2_install_schema->p_word = drrr_rf_data->adm_db_user_pwd
   SET dm2_install_schema->connect_str = drrr_rf_data->adm_db_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Querying DM_INFO for the row to restart target database checkpoint row."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_REFRESH_RESTRICT_DATABASE"
     AND di.info_name=cnvtupper(drrr_rf_data->tgt_db_name)
    DETAIL
     drdr_info_char = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drdr_mode="D")
    IF (curqual=1)
     SET dm_err->eproc = "Removing the restrict database row from DM_INFO."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm_info di
      WHERE di.info_domain="DM2_REFRESH_RESTRICT_DATABASE"
       AND di.info_name=cnvtupper(drrr_rf_data->tgt_db_name)
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     COMMIT
    ELSE
     SET dm_err->eproc =
     "Could not find the restrict database checkpoint row from DM_INFO. Possible manual intervention occurred."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ELSE
    IF (((curqual=1
     AND drdr_restart_ind=1
     AND drdr_info_char="INITIATED") OR (curqual=0
     AND drdr_restart_ind=0)) )
     IF (drr_drop_user_restrict_ksh(null)=0)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc =
     "Database should be in stable state to continue without the need to put database in restricted mode."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_install_schema->u_name = "SYS"
   SET dm2_install_schema->p_word = drrr_rf_data->tgt_sys_pwd
   SET dm2_install_schema->connect_str = drrr_rf_data->tgt_db_cnct_str
   SET dm2_install_schema->dbase_name = '"TARGET"'
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_drop_user_restrict_ksh(null)
   DECLARE ddurk_full_ksh_name = vc WITH protect, noconstant("")
   DECLARE ddurk_line = vc WITH protect, noconstant("")
   DECLARE ddurk_text = vc WITH protect, noconstant("")
   DECLARE ddurk_tgt_db_ver = i4 WITH protect, noconstant(0)
   DECLARE ddurk_tgt_ora_home = vc WITH protect, noconstant("")
   DECLARE ddurk_sqlfile = vc WITH protect, noconstant("")
   DECLARE ddurk_logfile = vc WITH protect, noconstant("")
   DECLARE ddurk_full_logfile = vc WITH protect, noconstant("")
   DECLARE ddurk_file_loc = vc WITH protect, noconstant("")
   DECLARE ddurk_cmd = vc WITH protect, noconstant("")
   DECLARE ddurk_ksh_error_msg = vc WITH protect, noconstant("")
   SET ddurk_full_ksh_name = concat("dm2_restrict_",cnvtlower(drrr_rf_data->tgt_db_name),"_db.ksh")
   SET ddurk_file_loc = drrr_rf_data->tgt_db_temp_dir
   SET ddurk_sqlfile = concat(ddurk_file_loc,"restrict_drop_v500.sql")
   SET ddurk_du_sqlfile = concat(ddurk_file_loc,"restrict_drop_user_v500.sql")
   SET ddurk_logfile = concat(ddurk_file_loc,"restrict_drop_v500.log")
   SET ddurk_du_logfile = concat(ddurk_file_loc,"restrict_drop_user_v500.log")
   SET ddurk_full_logfile = concat(ddurk_file_loc,"restrict_drop_v500_full.log")
   SET ddurk_tgt_db_ver = cnvtint(drrr_rf_data->tgt_db_oracle_ver)
   IF (findstring("/",drrr_rf_data->tgt_db_oracle_home,1,1)=size(drrr_rf_data->tgt_db_oracle_home))
    SET ddurk_tgt_ora_home = substring(1,(size(drrr_rf_data->tgt_db_oracle_home,1) - 1),drrr_rf_data
     ->tgt_db_oracle_home)
   ELSE
    SET ddurk_tgt_ora_home = drrr_rf_data->tgt_db_oracle_home
   ENDIF
   SET dm_err->eproc = concat("Create ksh file ",ddurk_full_ksh_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(ddurk_full_ksh_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     IF (ddurk_tgt_db_ver=19)
      col 0, "#!/bin/ksh", row + 1,
      ddurk_line = build("TGT_DB_NAME=",cnvtupper(drrr_rf_data->tgt_db_name)), col 0, ddurk_line,
      row + 1, ddurk_line = concat("export ORACLE_SID=",cnvtlower(drrr_rf_data->tgt_cdb_cnct_str)),
      col 0,
      ddurk_line, row + 1, ddurk_line = concat("export ORACLE_HOME=",ddurk_tgt_ora_home),
      col 0, ddurk_line, row + 1,
      col 0, "USER_TO_DROP=V500", row + 1,
      ddurk_line = build("DROP_V500_SQLFILE=",ddurk_sqlfile), col 0, ddurk_line,
      row + 1, ddurk_line = build("DROP_USER_V500_SQLFILE=",ddurk_du_sqlfile), col 0,
      ddurk_line, row + 1, ddurk_line = build("DROP_V500_SQL_LOGFILE=",ddurk_logfile),
      col 0, ddurk_line, row + 1,
      ddurk_line = build("DROP_USER_V500_SQL_LOGFILE=",ddurk_du_logfile), col 0, ddurk_line,
      row + 1, ddurk_line = build("DROP_V500_LOGFILE=",ddurk_full_logfile), col 0,
      ddurk_line, row + 1, col 0,
      "USER_EXISTS_IND=0", row + 1, col 0,
      " ", row + 1, col 0,
      "CheckDBMode()", row + 1, col 0,
      "{", row + 1, col 0,
      "  rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      '  echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "set serveroutput on;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "declare " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  db_mode varchar2(10);" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  restricted_mode varchar2(10);" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "begin" >> ${DROP_V500_SQLFILE}', row + 1, ddurk_line = concat(
       '  echo " select open_mode,restricted into db_mode,restricted_mode from v\$pdbs ',
       ^ where name = '${TGT_DB_NAME}';" >> ${DROP_V500_SQLFILE}^),
      col 0, ddurk_line, row + 1,
      col 0, ^  echo " dbms_output.put_line('DB_MODE is: ' || db_mode);" >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0,
      ^  echo " dbms_output.put_line('RESTRICTED_MODE is: ' || restricted_mode);" >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0, '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "end;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "/" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "exit" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "  ", row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '   EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '   EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "   exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, "  ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0001:error - Error retrieving database mode info."', row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, '  DB_MODE=`grep "DB_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3-4`', row + 1,
      col 0,
      '  RESTRICTED_MODE=`grep "RESTRICTED_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3`', row
       + 1,
      col 0, '  EchoMessage "`date`: DB_MODE=${DB_MODE}"', row + 1,
      col 0, '  EchoMessage "`date`: RESTRICTED=${RESTRICTED_MODE}"', row + 1,
      col 0, "}", row + 1,
      col 0, " ", row + 1,
      col 0, "StartupDB()", row + 1,
      col 0, "{", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0,
      "  #Logfile will not be removed since output from CheckDBMode function is evaluated from the logfile.",
      row + 1,
      col 0, "  arg1=$1", row + 1,
      col 0, "  ", row + 1,
      col 0, '  echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  if [[ "$arg1" = "READ WRITE" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  elif [[ "$arg1" = "RESTRICT" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup restrict;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, " ", row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '    EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0003:error - Error while starting the database in $arg1 mode."',
      row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, "  CheckDBMode", row + 1,
      col 0, "   ", row + 1,
      col 0, '  if [[ ${DB_MODE} == "READ WRITE" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "`date`: Pluggable database has been opened in $arg1 mode."', row + 1,
      col 0, "  else", row + 1,
      col 0,
      '    EchoMessage "CER-0010:error - Pluggable database is not running in READ WRITE mode."', row
       + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      ddurk_line = concat('  if [[ $arg1 == "RESTRICT" && ${RESTRICTED_MODE} == "YES" || ',
       '$arg1 == "READ WRITE" && ${RESTRICTED_MODE} == "NO" ]]'), col 0, ddurk_line,
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "`date`: Pluggable database is opened in $arg1 mode."',
      row + 1, col 0, "  else",
      row + 1, col 0,
      '    EchoMessage "CER-0011:error - Pluggable database is not in appropriate RESTRICTED mode." "1"',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, "  ",
      row + 1, col 0, "  #Starting DB service",
      row + 1, col 0, "  StartupService ",
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "StartupService() ",
      row + 1, col 0, "{ ",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE} ",
      row + 1, col 0,
      "  ${ORACLE_HOME}/bin/srvctl start service -d c${TGT_DB_NAME} > ${DROP_V500_SQL_LOGFILE} ",
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]] ",
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage `date` "KSH for Setup ending in error."',
      row + 1, col 0, "    exit 1 ",
      row + 1, col 0, "  fi ",
      row + 1, col 0, " ",
      row + 1, col 0,
      "  $ORACLE_HOME/bin/srvctl status service -d c${TGT_DB_NAME} -s s${TGT_DB_NAME} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      '  SERVICE_RUNNING_IND=`grep -i "Service s${TGT_DB_NAME} is running" ${DROP_V500_SQL_LOGFILE} | wc -l`',
      row + 1, col 0,
      '  echo "`date`:Service running indicator(1 - up/0 - down): ${SERVICE_RUNNING_IND}" >>${DROP_V500_SQL_LOGFILE}',
      row + 1, col 0, "  if [[ ${SERVICE_RUNNING_IND} -eq 0 ]]",
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0009:error - Database service is not running."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  else ",
      row + 1, col 0, '    EchoMessage "`date`: Database service is up and running."',
      row + 1, col 0, "  fi",
      row + 1, col 0, "} ",
      row + 1, col 0, " ",
      row + 1, col 0, "OpenDB()",
      row + 1, col 0, "{",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, ddurk_line = concat('  echo "alter session set container=${TGT_DB_NAME};" | ',
       'echo "alter pluggable database ${TGT_DB_NAME} open force;" | ',
       "${ORACLE_HOME}/bin/sqlplus '/as sysdba' > ${DROP_V500_SQL_LOGFILE}"), col 0,
      ddurk_line, row + 1, col 0,
      " ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      " ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0004:error - Error while starting the database in READ WRITE mode."', row
       + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi ", row + 1, col 0,
      '  EchoMessage "`date`: Pluggable database is opened with force."', row + 1, col 0,
      "}", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow()", row + 1, col 0,
      "{", row + 1, col 0,
      "  rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      "  arg1=$1", row + 1, col 0,
      '  EchoMessage "`date`: Attempting to merge Admin checkpoint row with $arg1 status."', row + 1,
      col 0,
      "  #Merging into dm_info to mark the initiation of restrict database", row + 1, col 0,
      '  echo "begin " > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  merge into dm_info x " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  using dual " >> ${DROP_V500_SQLFILE}', row + 1, ddurk_line = concat(
       ^  echo "  on (x.info_domain='DM2_REFRESH_RESTRICT_DATABASE' and x.info_name='${TGT_DB_NAME}')"^,
       "  >> ${DROP_V500_SQLFILE}"),
      col 0, ddurk_line, row + 1,
      col 0, '  echo "  when matched then " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, ^  echo "   update set x.info_char = '$arg1', " >> ${DROP_V500_SQLFILE}^, row + 1,
      col 0, '  echo "   x.updt_dt_tm = sysdate " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "  when not matched then " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      '  echo "   insert(x.info_domain, x.info_name, x.info_char, x.updt_dt_tm) " >> ${DROP_V500_SQLFILE}',
      row + 1,
      col 0,
      ^  echo "   values ('DM2_REFRESH_RESTRICT_DATABASE','${TGT_DB_NAME}','$arg1',sysdate); " >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0, '  echo "   commit;"   >> ${DROP_V500_SQLFILE}     ', row + 1,
      col 0, '  echo "exception "  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "  when others then"  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "    dbms_output.put_line(sqlerrm);"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "    rollback; "  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "end; "  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "/"   >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "exit; " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "  ", row + 1,
      ddurk_line = build(" ${ORACLE_HOME}/bin/sqlplus -L '",drrr_rf_data->adm_db_user,"/",
       drrr_rf_data->adm_db_user_pwd,"@",
       drrr_rf_data->adm_db_cnct_str,"' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE} "), col 0,
      ddurk_line,
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]",
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, " ",
      row + 1, col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]',
      row + 1, col 0, "  then",
      row + 1, col 0,
      '    EchoMessage "CER-0005:error - Error while merging dm_info row with $arg1 status."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, '  EchoMessage "`date`: Admin checkpoint row merged with $arg1 status."',
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "CheckDBUserExistence()",
      row + 1, col 0, "{",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, "  USER_EXISTS_IND=0",
      row + 1, col 0, '  echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "set serveroutput on;" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "declare " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  user_exists_ind number := 0;" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "begin" >> ${DROP_V500_SQLFILE}',
      row + 1, ddurk_line = concat('  echo "select count(*) into user_exists_ind from dba_users ',
       ^where username='${USER_TO_DROP}';" >> ${DROP_V500_SQLFILE}^), col 0,
      ddurk_line, row + 1, col 0,
      ^  echo " dbms_output.put_line('USER_EXISTS_IND is: ' || user_exists_ind);" >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "end;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "/" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "exit" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "  ", row + 1, col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      " ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]] ", row + 1, col 0,
      "  then ", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1 ", row + 1, col 0,
      "  fi ", row + 1, col 0,
      "  ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]] ', row + 1, col 0,
      "  then ", row + 1, col 0,
      '    EchoMessage "CER-0008:error - Error retrieving user info."', row + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1 ", row + 1, col 0,
      "  fi ", row + 1, col 0,
      "  ", row + 1, col 0,
      '  USER_EXISTS_IND=`grep "USER_EXISTS_IND is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3`    ',
      row + 1, col 0,
      "  ", row + 1, col 0,
      "  if [[ ${USER_EXISTS_IND} -eq 0 ]] ", row + 1, col 0,
      "  then ", row + 1, col 0,
      '    EchoMessage "`date`: User ${USER_TO_DROP} does not exist."', row + 1, col 0,
      "  else ", row + 1, col 0,
      '    EchoMessage "`date`: User ${USER_TO_DROP} exists."', row + 1, col 0,
      "  fi ", row + 1, col 0,
      "} ", row + 1, col 0,
      " ", row + 1, col 0,
      "EchoMessage()", row + 1, col 0,
      "{", row + 1, col 0,
      " echo $1", row + 1, col 0,
      ' echo "`date`: $1" >> ${DROP_V500_LOGFILE}', row + 1, col 0,
      "}", row + 1, col 0,
      " ", row + 1, col 0,
      "#Main process", row + 1, col 0,
      "rm -f ${DROP_V500_LOGFILE}", row + 1, col 0,
      'EchoMessage "`date`: Beginning of the logfile to drop ${USER_TO_DROP} user."', row + 1, col 0,
      " ", row + 1, col 0,
      "#Check the status of the database.", row + 1, col 0,
      "#Verify the open_mode is in a valid state to be shutdown.", row + 1, col 0,
      "CheckDBMode", row + 1, col 0,
      " ", row + 1, col 0,
      "#If the database is in any mode other than READ WRITE, open the database in READ WRITE mode.",
      row + 1, col 0,
      'if [[ ${DB_MODE} != "READ WRITE" ]]', row + 1, col 0,
      "then  ", row + 1, col 0,
      "  StartupDB 'READ WRITE'", row + 1, col 0,
      "fi", row + 1, col 0,
      'if [[ ${RESTRICTED_MODE} == "YES" ]]', row + 1, col 0,
      "then", row + 1, col 0,
      "  OpenDB", row + 1, col 0,
      "fi", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow 'INITIATED' ", row + 1, col 0,
      " ", row + 1, col 0,
      "CheckDBMode", row + 1, col 0,
      "#Check if user exists.", row + 1, col 0,
      "CheckDBUserExistence", row + 1, col 0,
      " ", row + 1, col 0,
      "#Perform shutting down the database, startup in restrict to drop the user operations only ",
      row + 1, col 0,
      "#when the user exists, otherwise ignore all below code and move on.", row + 1, col 0,
      "if [[ ${USER_EXISTS_IND} -eq 1 ]]", row + 1, col 0,
      "then", row + 1, col 0,
      "  #Shutdown the database if open_mode of the pdb is 'READ WRITE'", row + 1, col 0,
      '  if [[ ${DB_MODE} == "READ WRITE" ]]', row + 1, col 0,
      "  then", row + 1, ddurk_line = concat(
       '    EchoMessage "`date`: User ${USER_TO_DROP} exists and the pdb is in ${DB_MODE} mode. ',
       'Shutting down."'),
      col 0, ddurk_line, row + 1,
      col 0, "    rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, '    echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "shutdown immediate;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "    ", row + 1,
      col 0, "    if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "    then", row + 1,
      col 0, '      EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '      EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "      exit 1", row + 1,
      col 0, "    fi", row + 1,
      col 0, "    ", row + 1,
      col 0, '    if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "    then", row + 1,
      col 0, '      EchoMessage "CER-0002:error - Error while shutting down the database."', row + 1,
      col 0, "      cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '      EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "      exit 1", row + 1,
      col 0, "    fi", row + 1,
      col 0, "  fi", row + 1,
      col 0, "  ", row + 1,
      col 0, "  #Verify the open_mode is in a valid state to be started up.", row + 1,
      col 0, "  CheckDBMode", row + 1,
      col 0, "   ", row + 1,
      col 0, "  #Startup the database", row + 1,
      col 0, '  if [[ ${DB_MODE} == "MOUNTED" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0,
      '    EchoMessage "`date`: Pluggable database in ${DB_MODE} mode.Starting the DB in RESTRICT mode."',
      row + 1,
      col 0, "    StartupDB 'RESTRICT'", row + 1,
      col 0, "    CheckDBMode", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, '  if [[ ${DB_MODE} == "READ WRITE" && ${RESTRICTED_MODE} == "YES" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0,
      '    EchoMessage "`date`: Pluggable database in restricted mode. Attempting to drop the user."',
      row + 1,
      col 0, "    #Lock and drop the user. Confirm it is dropped.", row + 1,
      col 0, "    rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, '    echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "set serveroutput on;"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "begin " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      "    #Putting the session to sleep after startup, so Oracle catches up to the execution.", row
       + 1,
      col 0, '    echo "  dbms_session.sleep(5);"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      ^    echo "  execute immediate 'alter user ${USER_TO_DROP} account lock';"  >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0,
      "    #Putting the session to sleep after locking V500, to give time so new connections are not established.",
      row + 1,
      col 0, '    echo "  dbms_session.sleep(15);"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      ^    echo "  execute immediate 'drop user ${USER_TO_DROP} cascade';"  >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0, '    echo "EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo " when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "end;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "/" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "    ", row + 1,
      col 0, "    cat ${DROP_V500_SQLFILE} > ${DROP_USER_V500_SQLFILE}", row + 1,
      col 0, "    ", row + 1,
      col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "    CheckDBUserExistence", row + 1,
      col 0, "    if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1,
      col 0, "    then", row + 1,
      col 0, "      COUNTER=1", row + 1,
      col 0, "      while [[ ${COUNTER} -le 3 ]]", row + 1,
      col 0, "      do", row + 1,
      col 0, '        EchoMessage "`date`: Attempt ${COUNTER} to drop the user."', row + 1,
      col 0,
      "        ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "        ((COUNTER++))", row + 1,
      col 0, "        CheckDBUserExistence", row + 1,
      col 0, "        if [[ $USER_EXISTS_IND -eq 0 ]]", row + 1,
      col 0, "        then", row + 1,
      col 0, "          COUNTER=4", row + 1,
      col 0, "        fi    ", row + 1,
      col 0, "      done", row + 1,
      col 0, " ", row + 1,
      col 0, "      if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1,
      col 0, "      then", row + 1,
      col 0, '        EchoMessage "CER-0006:error - Error while dropping the user."', row + 1,
      col 0, "        cat ${DROP_USER_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '        EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "        exit 1", row + 1,
      col 0, "      fi", row + 1,
      col 0, "    fi    ", row + 1,
      col 0, " ", row + 1,
      col 0, "    OpenDB", row + 1,
      col 0, "  fi", row + 1,
      col 0, "fi  ", row + 1,
      col 0, " ", row + 1,
      col 0, "UpdateAdminCheckpointRow 'COMPLETED' ", row + 1,
      col 0, 'EchoMessage "`date`: Drop user in restricted mode successful."', row + 1
     ELSE
      col 0, "#!/bin/ksh", row + 1,
      ddurk_text = build("TGT_DB_NAME=",cnvtupper(drrr_rf_data->tgt_db_name)), col 0, ddurk_text,
      row + 1, ddurk_text = concat("export ORACLE_SID=",cnvtlower(drrr_rf_data->tgt_db_cnct_str)),
      col 0,
      ddurk_text, row + 1, ddurk_text = concat("export ORACLE_HOME=",ddurk_tgt_ora_home),
      col 0, ddurk_text, row + 1,
      ddurk_text = build("USER_TO_DROP=V500"), col 0, ddurk_text,
      row + 1, ddurk_text = build("DROP_V500_SQLFILE=",ddurk_sqlfile), col 0,
      ddurk_text, row + 1, ddurk_line = build("DROP_USER_V500_SQLFILE=",ddurk_du_sqlfile),
      col 0, ddurk_line, row + 1,
      ddurk_text = build("DROP_V500_SQL_LOGFILE=",ddurk_logfile), col 0, ddurk_text,
      row + 1, ddurk_line = build("DROP_USER_V500_SQL_LOGFILE=",ddurk_du_logfile), col 0,
      ddurk_line, row + 1, ddurk_text = build("DROP_V500_LOGFILE=",ddurk_full_logfile),
      col 0, ddurk_text, row + 1,
      col 0, "USER_EXISTS_IND=0", row + 1,
      col 0, " ", row + 1,
      col 0, "StartupDB()", row + 1,
      col 0, "{", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, "  arg1=$1", row + 1,
      col 0, "  ", row + 1,
      col 0, '  if [[ "$arg1" = "READ WRITE" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup;" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  elif [[ "$arg1" = "RESTRICT" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup restrict;" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, " ", row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '    EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0003:error - Error while starting the database in $arg1 mode."',
      row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, '  EchoMessage "`date`: Database is opened in $arg1 mode."', row + 1,
      col 0, "}", row + 1,
      col 0, " ", row + 1,
      col 0, "OpenDB()", row + 1,
      col 0, "{", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE}", row + 1,
      ddurk_text = concat(
       ^  echo "alter system disable restricted session;" | ${ORACLE_HOME}/bin/sqlplus '/as sysdba' ^,
       "> ${DROP_V500_SQL_LOGFILE}"), col 0, ddurk_text,
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]",
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage `date` "KSH for Setup ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, " ",
      row + 1, col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]',
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0004:error - Error disabling restricted session."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi ",
      row + 1, col 0, '  EchoMessage "`date`: Restrict mode on databse is disabled."',
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "UpdateAdminCheckpointRow() ",
      row + 1, col 0, "{",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, "  arg1=$1",
      row + 1, col 0,
      '  EchoMessage "`date`: Attempting to merge Admin checkpoint row with $arg1 status."',
      row + 1, col 0, "  #Merging into dm_info to mark the initiation of restrict database",
      row + 1, col 0, '  echo "begin" > ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  merge into dm_info x " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  using dual " >> ${DROP_V500_SQLFILE}',
      row + 1, ddurk_text = concat(
       ^  echo "  on (x.info_domain='DM2_REFRESH_RESTRICT_DATABASE' and x.info_name='${TGT_DB_NAME}')"^,
       " >> ${DROP_V500_SQLFILE}"), col 0,
      ddurk_text, row + 1, col 0,
      '  echo "  when matched then " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      ^  echo "   update set x.info_char = '$arg1', " >> ${DROP_V500_SQLFILE}^, row + 1, col 0,
      '  echo "   x.updt_dt_tm = sysdate " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  when not matched then " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "   insert(x.info_domain, x.info_name, x.info_char, x.updt_dt_tm) " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0,
      ^  echo "   values ('DM2_REFRESH_RESTRICT_DATABASE','${TGT_DB_NAME}','$arg1',sysdate); " >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '  echo "  commit;"   >> ${DROP_V500_SQLFILE}     ', row + 1, col 0,
      '  echo "exception" >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "  when others then"  >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "    dbms_output.put_line(sqlerrm);"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "    rollback; "  >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "end; "  >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "/"   >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "exit; " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "  ", row + 1, ddurk_line = build(" ${ORACLE_HOME}/bin/sqlplus -L  '",drrr_rf_data->adm_db_user,
       "/",drrr_rf_data->adm_db_user_pwd,"@",
       drrr_rf_data->adm_db_cnct_str,"' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE} "),
      col 0, ddurk_line, row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '    EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, "  ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0005:error - Error while merging dm_info row with $arg1 status."',
      row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, '  EchoMessage "`date`: Admin checkpoint row merged with $arg1 status."', row + 1,
      col 0, "} ", row + 1,
      col 0, " ", row + 1,
      col 0, "CheckDBUserExistence() ", row + 1,
      col 0, "{ ", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE} ", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE} ", row + 1,
      col 0, "  USER_EXISTS_IND=0 ", row + 1,
      col 0, '  echo "set serveroutput on;" > ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "declare " >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "  user_exists_ind number := 0;" >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "begin" >> ${DROP_V500_SQLFILE} ', row + 1,
      ddurk_text = concat(
       ^  echo "select count(*) into user_exists_ind from dba_users where username='${USER_TO_DROP}';"^,
       "  >> ${DROP_V500_SQLFILE}"), col 0, ddurk_text,
      row + 1, col 0,
      ^  echo " dbms_output.put_line('USER_EXISTS_IND is: ' || user_exists_ind);" >> ${DROP_V500_SQLFILE} ^,
      row + 1, col 0, '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "end;" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "/" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "exit" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, " ",
      row + 1, col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE} ",
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]] ",
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage `date` "KSH for Setup ending in error."',
      row + 1, col 0, "    exit 1 ",
      row + 1, col 0, "  fi ",
      row + 1, col 0, "  ",
      row + 1, col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]] ',
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "CER-0008:error - Error retrieving user info."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1 ",
      row + 1, col 0, "  fi ",
      row + 1, col 0, " ",
      row + 1, col 0,
      '  USER_EXISTS_IND=`grep "USER_EXISTS_IND is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3` ',
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ${USER_EXISTS_IND} -eq 0 ]] ",
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "`date`: User ${USER_TO_DROP} does not exist."',
      row + 1, col 0, "  else ",
      row + 1, col 0, '    EchoMessage "`date`: User ${USER_TO_DROP} exists."',
      row + 1, col 0, "  fi ",
      row + 1, col 0, "} ",
      row + 1, col 0, " ",
      row + 1, col 0, "EchoMessage()",
      row + 1, col 0, "{",
      row + 1, col 0, " echo $1",
      row + 1, col 0, ' echo "`date`: $1" >> ${DROP_V500_LOGFILE}',
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "#Main process",
      row + 1, col 0, "rm -f ${DROP_V500_LOGFILE}",
      row + 1, col 0, 'EchoMessage "`date`: Beginning of the logfile to drop ${USER_TO_DROP} user."',
      row + 1, col 0, " ",
      row + 1, col 0, "TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)",
      row + 1, col 0, "#If the database is down during the first run, startup in readwrite mode.",
      row + 1, col 0, "if [[ ${TGT_DB_STATUS_IND} -eq 0 ]]",
      row + 1, col 0, "then",
      row + 1, col 0, '  EchoMessage "`date`: Database is down. Starting up in READ WRITE mode."',
      row + 1, col 0, "  StartupDB 'READ WRITE'",
      row + 1, col 0, "fi",
      row + 1, col 0, " ",
      row + 1, col 0, "TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)",
      row + 1, col 0, "#Check the status of the database.",
      row + 1, col 0, "if [[ ${TGT_DB_STATUS_IND} -gt 0 ]]",
      row + 1, col 0, "then",
      row + 1, col 0,
      '  echo "`date`: DB is running. Retrieving the db_mode and restricted_mode." >> ${DROP_V500_SQL_LOGFILE} ',
      row + 1, col 0, "  #Verify the open_mode is in a valid state to be shutdown.",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, '  echo "set serveroutput on;" > ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "declare " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  db_mode varchar2(10);" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  restricted_mode varchar2(10);" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "begin" >> ${DROP_V500_SQLFILE}',
      row + 1, ddurk_text = build('  echo " select open_mode into db_mode from v\$database ',
       ^ where name = '${TGT_DB_NAME}';" >> ${DROP_V500_SQLFILE}^), col 0,
      ddurk_text, row + 1, col 0,
      '  echo " select logins into restricted_mode from v\$instance;" >> ${DROP_V500_SQLFILE}', row
       + 1, col 0,
      ^  echo " dbms_output.put_line('DB_MODE is: ' || db_mode);" >> ${DROP_V500_SQLFILE}^, row + 1,
      col 0,
      ^  echo " dbms_output.put_line('RESTRICTED_MODE is: ' || restricted_mode);" >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "end;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "/" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "exit" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "  ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      "  ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0001:error - Error retrieving database mode info."', row + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      '  DB_MODE=`grep "DB_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3-4`', row + 1, col 0,
      '  RESTRICTED_MODE=`grep "RESTRICTED_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3`', row
       + 1, col 0,
      '  EchoMessage "`date`: DB_MODE=${DB_MODE}"', row + 1, col 0,
      '  EchoMessage "`date`: RESTRICTED=${RESTRICTED_MODE}"', row + 1, col 0,
      "fi", row + 1, col 0,
      "#If the database is in any mode other than READ WRITE, open the database in READ WRITE mode.",
      row + 1, col 0,
      'if [[ ${DB_MODE} != "READ WRITE" ]]', row + 1, col 0,
      "then  ", row + 1, col 0,
      '  EchoMessage "`date`: Database is in ${DB_MODE} mode. Opening database."', row + 1, col 0,
      "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      "  echo 'alter database open;' | ${ORACLE_HOME}/bin/sqlplus '/as sysdba' > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      " ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      " ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0007:error - Error while starting the database in READ WRITE mode."', row
       + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi ", row + 1, col 0,
      "fi", row + 1, col 0,
      'if [[ ${RESTRICTED_MODE} == "RESTRICTED" ]]', row + 1, col 0,
      "then", row + 1, col 0,
      '  EchoMessage "`date`: Database is restricted. Opening DB to disable restriction."', row + 1,
      col 0,
      "  #Call disable restricted session module.", row + 1, col 0,
      "  OpenDB", row + 1, col 0,
      "fi", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow 'INITIATED' ", row + 1, col 0,
      " ", row + 1, col 0,
      "CheckDBUserExistence", row + 1, col 0,
      " ", row + 1, col 0,
      "#Perform shutting down the database, startup in restrict to drop the user operations only ",
      row + 1, col 0,
      "#when the user exists, otherwise ignore all below code and move on.", row + 1, col 0,
      "if [[ ${USER_EXISTS_IND} -eq 1 ]]", row + 1, col 0,
      "then", row + 1, col 0,
      "  #Shutdown the database", row + 1, col 0,
      "  if [[ ${TGT_DB_STATUS_IND} -gt 0 ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "`date`: User ${USER_TO_DROP} exists. Shutting down the database."', row + 1,
      col 0,
      "    rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      '    echo "shutdown immediate;" > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "exit;"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "    ", row + 1, col 0,
      "    if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "    then", row + 1, col 0,
      '      EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '      EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "      exit 1", row + 1, col 0,
      "    fi", row + 1, col 0,
      "    ", row + 1, col 0,
      '    if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "    then", row + 1, col 0,
      '      EchoMessage "CER-0002:error - Error while shutting down the database."', row + 1, col 0,
      "      cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '      EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "      exit 1", row + 1, col 0,
      "    fi", row + 1, col 0,
      "    ", row + 1, col 0,
      "  fi", row + 1, col 0,
      "  ", row + 1, col 0,
      "  #Check the database status before starting in restrict mode.", row + 1, col 0,
      "  TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)", row + 1, col 0,
      "  ", row + 1, col 0,
      "  #Startup the database", row + 1, col 0,
      "  if [[ ${TGT_DB_STATUS_IND} -eq 0 ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "`date`: Starting the database in RESTRICT mode."', row + 1, col 0,
      "    StartupDB 'RESTRICT'", row + 1, col 0,
      "  fi", row + 1, col 0,
      "  ", row + 1, col 0,
      "  TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)", row + 1, col 0,
      "  if [[ ${TGT_DB_STATUS_IND} -gt 0 ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "`date`: Attempting to drop the user ${USER_TO_DROP}."', row + 1, col 0,
      "    #Lock and drop the user. Confirm it is dropped.", row + 1, col 0,
      "    rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      '    echo "set serveroutput on;"  > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "begin " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "  dbms_lock.sleep(5);"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      ^    echo "  execute immediate 'alter user ${USER_TO_DROP} account lock';"  >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '    echo "  dbms_lock.sleep(15);"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      ^    echo "  execute immediate 'drop user ${USER_TO_DROP} cascade';"  >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '    echo "EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo " when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "end;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "/" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "    ", row + 1, col 0,
      "    cat ${DROP_V500_SQLFILE} > ${DROP_USER_V500_SQLFILE}", row + 1, col 0,
      "    ", row + 1, col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "    CheckDBUserExistence", row + 1, col 0,
      "    if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1, col 0,
      "    then", row + 1, col 0,
      "      COUNTER=1", row + 1, col 0,
      "      while [[ ${COUNTER} -le 3 ]]", row + 1, col 0,
      "      do", row + 1, col 0,
      '        EchoMessage "`date`: Attempt ${COUNTER} to drop the user."', row + 1, col 0,
      "        ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "        ((COUNTER++))", row + 1, col 0,
      "        CheckDBUserExistence", row + 1, col 0,
      "        if [[ $USER_EXISTS_IND -eq 0 ]]", row + 1, col 0,
      "        then", row + 1, col 0,
      "          COUNTER=4", row + 1, col 0,
      "        fi    ", row + 1, col 0,
      "      done", row + 1, col 0,
      "      ", row + 1, col 0,
      "      if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1, col 0,
      "      then", row + 1, col 0,
      '        EchoMessage "CER-0006:error - Error while dropping the user."', row + 1, col 0,
      "        cat ${DROP_USER_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '        EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "        exit 1", row + 1, col 0,
      "      fi", row + 1, col 0,
      "    fi    ", row + 1, col 0,
      " ", row + 1, col 0,
      "    OpenDB", row + 1, col 0,
      "    ", row + 1, col 0,
      "  fi", row + 1, col 0,
      "fi  ", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow 'COMPLETED' ", row + 1, col 0,
      " ", row + 1, col 0,
      'EchoMessage "`date`: Drop user in restricted mode successful."', row + 1
     ENDIF
    WITH nocounter, format = lfstream, formfeed = none,
     maxrow = 1, maxcol = 512
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   SET dm2ftpr->user_name = "oracle"
   SET dm2ftpr->user_pwd = "oracle"
   SET dm2ftpr->remote_host = drrr_rf_data->tgt_db_node
   SET dm2ftpr->options = "-b"
   CALL dfr_add_putops_line(" "," "," "," "," ",
    1)
   CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),ddurk_full_ksh_name,concat(
     ddurk_file_loc,"/"),ddurk_full_ksh_name,
    0)
   IF (dfr_put_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_putops_line(" "," "," "," "," ",
    1)
   SET ddurk_cmd = concat("su - oracle -c 'ssh oracle@",drrr_rf_data->tgt_db_node," ",ddurk_file_loc,
    ddurk_full_ksh_name,
    "'")
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(ddurk_cmd)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errfile = "NONE"
   IF (findstring("CER-",cnvtupper(dm_err->errtext),1,0) > 0)
    SET ddurk_ksh_error_msg = concat("Fatal error:  ",substring(findstring("CER-",cnvtupper(dm_err->
        errtext),1,1),(size(dm_err->errtext) - findstring("CER-",cnvtupper(dm_err->errtext),1,1)),
      dm_err->errtext),".")
    SET dm_err->eproc = concat("Executing ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target ",
     "database node ",drrr_rf_data->tgt_db_node,".")
    SET dm_err->emsg = concat("Error(s) detected during ksh execution. ",ddurk_ksh_error_msg)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (findstring("DROP USER IN RESTRICTED MODE SUCCESSFUL",cnvtupper(dm_err->errtext),1,0) > 0)
    SET dm_err->eproc = concat("Execution of ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target database node (",
     drrr_rf_data->tgt_db_node,") to drop V500 user was successful.")
    CALL disp_msg("",dm_err->logfile,0)
   ELSE
    SET dm_err->eproc = concat("Executing ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target ",
     "database node ",drrr_rf_data->tgt_db_node,".")
    SET dm_err->emsg = concat(
     "Unable to verify successful execution of ksh file. Command executed:  ",build(ddurk_cmd))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=0))
    SET dm_err->eproc = concat("Removing ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target database node ",
     drrr_rf_data->tgt_db_node)
    CALL disp_msg("",dm_err->logfile,0)
    IF (dm2_findfile(concat(build(logical("ccluserdir"),"/"),ddurk_full_ksh_name)))
     IF (dm2_push_dcl(concat("rm ",build(logical("ccluserdir"),"/"),ddurk_full_ksh_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET ddurk_cmd = ""
    SET ddurk_cmd = concat("su - oracle -c 'ssh oracle@",drrr_rf_data->tgt_db_node,' "rm -f ',
     ddurk_file_loc,ddurk_full_ksh_name,
     ^"'^)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(ddurk_cmd)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    SET ddurk_cmd = ""
    SET ddurk_cmd = concat("su - oracle -c 'ssh oracle@",drrr_rf_data->tgt_db_node,' "rm -f ',
     ddurk_full_logfile," ",
     ddurk_logfile," ",ddurk_sqlfile," ",ddurk_du_logfile,
     " ",ddurk_du_sqlfile,^"'^)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(ddurk_cmd)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_verify_admin_content(dvac_inform_only_ind,dvac_invalid_data_ind)
   DECLARE dvac_msg = vc WITH protect, noconstant("")
   DECLARE dvac_idx = i4 WITH protect, noconstant(0)
   DECLARE dvac_tidx = i4 WITH protect, noconstant(0)
   DECLARE dvac_invalid_tbl_file = vc WITH protect, noconstant("")
   IF (validate(dm2_bypass_verify_adm_cont,- (1))=1)
    SET dm_err->eproc = "Bypassing validation of Admin content before data collection."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   FREE RECORD dvac_invalid_tbl
   RECORD dvac_invalid_tbl(
     1 cnt = i4
     1 tables[*]
       2 tbl_name = vc
   )
   SET dvac_invalid_tbl->cnt = 0
   FREE RECORD dvac_dup_tbl
   RECORD dvac_dup_tbl(
     1 cnt = i4
     1 suffixes[*]
       2 suffix = vc
       2 tbl_cnt = i4
       2 tables[*]
         3 tbl_name = vc
   )
   SET dvac_dup_tbl->cnt = 0
   FREE RECORD dvac_missing_tp_tbl
   RECORD dvac_missing_tp_tbl(
     1 cnt = i4
     1 tables[*]
       2 tbl_name = vc
   )
   SET dvac_missing_tp_tbl->cnt = 0
   SET dm_err->eproc =
   "Verify if any INVALID table documentation rows are found for the existing Millennium tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_tables_doc dt
    WHERE ((dt.table_suffix="0") OR (((dt.full_table_name=null) OR (dt.full_table_name="")) ))
     AND table_name IN (
    (SELECT
     x.table_name
     FROM dba_tables x
     WHERE x.owner=currdbuser))
    DETAIL
     dvac_invalid_tbl->cnt = (dvac_invalid_tbl->cnt+ 1), stat = alterlist(dvac_invalid_tbl->tables,
      dvac_invalid_tbl->cnt), dvac_invalid_tbl->tables[dvac_invalid_tbl->cnt].tbl_name = dt
     .table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Verify if any DUPLICATE table documentation rows are found for the existing Millennium tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_tables_doc dt
    WHERE ((table_name=full_table_name) OR (((full_table_name = null) OR (textlen(trim(
      full_table_name,5))=0)) ))
     AND table_suffix IN (
    (SELECT
     x.table_suffix
     FROM dm_tables_doc x
     WHERE ((x.full_table_name=x.table_name) OR (((textlen(trim(full_table_name,5))=0) OR (x
     .full_table_name = null)) ))
      AND x.table_name IN (
     (SELECT
      t.table_name
      FROM dba_tables t
      WHERE t.owner=currdbuser))
     GROUP BY x.table_suffix
     HAVING count(*) > 1))
     AND table_name IN (
    (SELECT
     x.table_name
     FROM dba_tables x
     WHERE x.owner=currdbuser))
    DETAIL
     dvac_idx = 0
     IF (locateval(dvac_idx,1,size(dvac_dup_tbl->suffixes,5),dt.table_suffix,dvac_dup_tbl->suffixes[
      dvac_idx].suffix)=0)
      dvac_dup_tbl->cnt = (dvac_dup_tbl->cnt+ 1), stat = alterlist(dvac_dup_tbl->suffixes,
       dvac_dup_tbl->cnt), dvac_dup_tbl->suffixes[dvac_dup_tbl->cnt].suffix = dt.table_suffix,
      dvac_idx = dvac_dup_tbl->cnt
     ENDIF
     dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt = (dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt+ 1), stat
      = alterlist(dvac_dup_tbl->suffixes[dvac_idx].tables,dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt),
     dvac_dup_tbl->suffixes[dvac_idx].tables[dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt].tbl_name = dt
     .table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Verify if any MISSING table precedence documentation rows are found for the existing Millennium tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    td.table_name
    FROM dba_tables t,
     dm_tables_doc td
    WHERE t.owner=currdbuser
     AND  NOT (t.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1"))
     AND t.table_name=td.table_name
     AND td.owner=t.owner
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_ts_precedence tp
     WHERE t.table_name=tp.table_name
      AND t.owner=tp.owner)))
    DETAIL
     dvac_missing_tp_tbl->cnt = (dvac_missing_tp_tbl->cnt+ 1), stat = alterlist(dvac_missing_tp_tbl->
      tables,dvac_missing_tp_tbl->cnt), dvac_missing_tp_tbl->tables[dvac_missing_tp_tbl->cnt].
     tbl_name = td.table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dvac_invalid_tbl)
    CALL echorecord(dvac_dup_tbl)
    CALL echorecord(dvac_missing_tp_tbl)
   ENDIF
   IF ((((dvac_invalid_tbl->cnt > 0)) OR ((((dvac_dup_tbl->cnt > 0)) OR ((dvac_missing_tp_tbl->cnt >
   0))) )) )
    SET dvac_invalid_data_ind = 1
    SET dm_err->eproc = "Create invalid admin content report gathered before data collection."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (get_unique_file("dm2_invalid_adm_cont",".rpt")=0)
     RETURN(0)
    ENDIF
    SET dvac_invalid_tbl_file = concat(build(logical("ccluserdir"),"/"),dm_err->unique_fname)
    SELECT INTO value(dvac_invalid_tbl_file)
     FROM dual
     DETAIL
      row + 1, col 1,
      "***************************WARNING: Invalid Admin Content has been detected.************************",
      row + 1
      IF ((dvac_invalid_tbl->cnt > 0))
       row + 1, col 1, "Tables displayed below have invalid documentation rows.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "TABLE NAME",
       row + 1
       FOR (dvac_idx = 1 TO dvac_invalid_tbl->cnt)
         col 10, dvac_invalid_tbl->tables[dvac_idx].tbl_name, row + 1
       ENDFOR
      ENDIF
      IF ((dvac_dup_tbl->cnt > 0))
       row + 1, col 1, "Tables displayed below have duplicate suffixes.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "SUFFIX NAME",
       col 40, "TABLE NAME", row + 1
       FOR (dvac_idx = 1 TO dvac_dup_tbl->cnt)
         col 10, dvac_dup_tbl->suffixes[dvac_idx].suffix
         FOR (dvac_tidx = 1 TO dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt)
           col 40, dvac_dup_tbl->suffixes[dvac_idx].tables[dvac_tidx].tbl_name, row + 1
         ENDFOR
       ENDFOR
      ENDIF
      IF ((dvac_missing_tp_tbl->cnt > 0))
       row + 1, col 1, "Tables displayed below are missing table precedence rows.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "TABLE NAME",
       row + 1
       FOR (dvac_idx = 1 TO dvac_missing_tp_tbl->cnt)
         col 10, dvac_missing_tp_tbl->tables[dvac_idx].tbl_name, row + 1
       ENDFOR
      ENDIF
     FOOT REPORT
      row + 1, col 0, "END OF REPORT"
     WITH nocounter, maxcol = 300, formfeed = none,
      maxrow = 1, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drer_email_list->email_cnt > 0))
     SET drer_email_det->msgtype = "ACTIONREQ"
     SET drer_email_det->status = "REPORT"
     SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
     SET drer_email_det->step = "Invalid Admin Content Report"
     SET drer_email_det->email_level = 1
     SET drer_email_det->logfile = dm_err->logfile
     SET drer_email_det->err_ind = dm_err->err_ind
     SET drer_email_det->eproc = dm_err->eproc
     SET drer_email_det->emsg = dm_err->emsg
     SET drer_email_det->user_action = dm_err->user_action
     SET drer_email_det->attachment = dvac_invalid_tbl_file
     CALL drer_add_body_text(concat("Invalid Admin Content Report created at ",format(drer_email_det
        ->status_dt_tm,";;q")),1)
     CALL drer_add_body_text(concat("Report file name is : ",dvac_invalid_tbl_file),0)
     IF (drer_compose_email(null)=1)
      CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
       email_level)
     ENDIF
     CALL drer_reset_pre_err(null)
    ENDIF
    SET dvac_msg = "Invalid Admin Content found."
    IF (dvac_inform_only_ind=1)
     SET dm_err->eproc = dvac_msg
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if invalid admin content found for the Millennium tables."
     SET dm_err->emsg = dvac_msg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_add_default_scd_row(null)
   DECLARE dadsr_def_row_id = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Verify if default row needs to be added for SCD_TERM_DATA table."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dma_sql_obj_inst dsoi
    WHERE dsoi.process_type="ADD_DEFAULT_ROW"
     AND dsoi.object_type="TABLE"
     AND dsoi.object_name="SCD_TERM_DATA"
     AND dsoi.table_name=dsoi.object_name
    DETAIL
     dadsr_def_row_id = dsoi.dma_sql_obj_inst_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dadsr_def_row_id=0)
    SELECT INTO "nl:"
     seqval = seq(dm_seq,nextval)
     FROM dual
     DETAIL
      dadsr_def_row_id = seqval
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting rows in dma_sql_obj_inst table for SCD_TERM_DATA table."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dma_sql_obj_inst dsoi
     SET dsoi.dma_sql_obj_inst_id = dadsr_def_row_id, dsoi.process_type = "ADD_DEFAULT_ROW", dsoi
      .object_type = "TABLE",
      dsoi.object_owner = "V500", dsoi.object_name = "SCD_TERM_DATA", dsoi.table_name =
      "SCD_TERM_DATA",
      dsoi.object_instance = 1, dsoi.active_ind = 1, dsoi.updt_cnt = 0,
      dsoi.updt_id = 0, dsoi.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsoi.updt_task = 15301,
      dsoi.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->eproc =
   "Verifying if dma_sql_obj_inst_attr table has a matching row for SCD_TERM_DATA table."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dma_sql_obj_inst_attr dsoia
    WHERE dsoia.dma_sql_obj_inst_id=dadsr_def_row_id
     AND dsoia.attr_name="COLUMN_LIST"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Inserting row in dma_sql_obj_inst_attr table for SCD_TERM_DATA table."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dma_sql_obj_inst_attr dsoia
     SET dsoia.dma_sql_obj_inst_attr_id = seq(dm_seq,nextval), dsoia.dma_sql_obj_inst_id =
      dadsr_def_row_id, dsoia.attr_name = "COLUMN_LIST",
      dsoia.attr_seg_nbr = 1, dsoia.attr_value_char = "SCD_TERM_DATA_ID", dsoia.attr_value_num = 0.0,
      dsoia.updt_cnt = 0, dsoia.updt_id = 0, dsoia.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dsoia.updt_task = 15301, dsoia.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_verify_custom_users(dvcu_inform_only_ind,dvcu_invalid_cust_user_ind)
   DECLARE dvcu_custom_users_msg = vc WITH protect, noconstant("")
   DECLARE dvcu_invalid_custom_users = vc WITH protect, noconstant("")
   IF (validate(dm2_bypass_verify_cust_users,- (1))=1)
    SET dm_err->eproc = "Bypassing validation of any database users that are marked custom."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Verifying if any CERNER Solution users have been marked as CUSTOM users."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_CUSTOM_USER"
     AND ((di.info_name IN ("V500_OTG", "CER_CASVC", "CER_CONF", "CER_PREF", "CER_IAWARE",
    "CER_CENTRAL")) OR (((di.info_name="V500_BO*") OR (((di.info_name="V500_ETL*") OR (((di.info_name
    ="V500_MODEL*") OR (di.info_name="V500_DM*")) )) )) ))
    DETAIL
     IF (textlen(trim(dvcu_invalid_custom_users))=0)
      dvcu_invalid_custom_users = trim(di.info_name)
     ELSE
      dvcu_invalid_custom_users = concat(dvcu_invalid_custom_users,", ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dvcu_invalid_cust_user_ind = 1
    SET dvcu_custom_users_msg = concat("Invalid database users found that are marked as custom: ",
     dvcu_invalid_custom_users)
    IF (dvcu_inform_only_ind=1)
     SET dm_err->eproc = dvcu_custom_users_msg
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if any invalid database users exist."
     SET dm_err->emsg = dvcu_custom_users_msg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_check_db_link(dcdl_in_db_link_name,dcdl_out_db_link_fnd_ind)
   DECLARE dcdl_cur_db_link_name = vc WITH protect, noconstant("")
   DECLARE dcdl_db_link_cnt = i2 WITH protect, noconstant(0)
   DECLARE dcdl_pos = i2 WITH protect, noconstant(0)
   SET dcdl_out_db_link_fnd_ind = 0
   SET dm_err->eproc = concat("Check if database link ",dcdl_in_db_link_name," exists.")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    dl.db_link
    FROM all_db_links dl
    WHERE parser(build(" dl.db_link = '",dcdl_in_db_link_name,"*'"))
    DETAIL
     dcdl_pos = 0, dcdl_pos = findstring(".",dl.db_link,1)
     IF (dcdl_pos > 0)
      dcdl_cur_db_link_name = substring(1,(dcdl_pos - 1),dl.db_link)
     ELSE
      dcdl_cur_db_link_name = dl.db_link
     ENDIF
     IF (trim(cnvtupper(dcdl_cur_db_link_name))=trim(cnvtupper(dcdl_in_db_link_name)))
      dcdl_db_link_cnt = (dcdl_db_link_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dcdl_db_link_cnt > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Multiple database links match input database link (",
     dcdl_in_db_link_name,").")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF (dcdl_db_link_cnt=1)
    SET dcdl_out_db_link_fnd_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_del_preserved_ts(dcdl_tgt_db_name)
   SET dm_err->eproc = concat("Delete DM2_REPLICATE_DATA for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain="DM2_REPLICATE_USER_TS"
     AND di.info_name=patstring(cnvtupper(build(dcdl_tgt_db_name,"-DB-*")))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
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
 DECLARE dcdur_create_db_users(null) = i2
 DECLARE dcdur_report_db_users_diff_tspaces(null) = i2
 DECLARE dcdur_cleanup_pwds(dcp_in_dbname=vc) = i2
 DECLARE dcdur_insert_pwds(dip_in_dbname=vc,dip_in_type=vc,dip_in_user=vc,dip_in_pwd=vc) = i2
 DECLARE dcdur_preserve_pwds(dpp_in_dbname=vc) = i2
 DECLARE dcdur_restore_pwds(drp_in_dbname=vc,drp_in_mode=vc) = i2
 DECLARE dcdur_get_server_users_pwds(dgsup_in_domain=vc) = i2
 DECLARE dcdur_prompt_tspaces(dpt_user_name=vc,dpt_db_name=vc,dpt_user_idx=i4(ref)) = i2
 DECLARE dcdur_user_tspace_cleanup(dutc_user_name=vc,dutc_db_name=vc) = i2
 DECLARE dcdur_user_tspace_load(dutl_db_name=vc) = i2
 DECLARE dcdur_insert_admin_tspace_rows(diatr_user_name=vc,diatr_db_name=vc,diatr_temp_ts=vc,
  diatr_misc_ts=vc) = i2
 DECLARE dcdur_get_db_owner_pwds(dgdop_in_dbname=vc) = i2
 IF (validate(dcdur_input->src_user,"ABC")="ABC"
  AND validate(dcdur_input->src_user,"XYZ")="XYZ")
  FREE RECORD dcdur_input
  RECORD dcdur_input(
    1 src_user = vc
    1 src_pwd = vc
    1 src_cnct_str = vc
    1 tgt_user = vc
    1 tgt_pwd = vc
    1 tgt_cnct_str = vc
    1 user_list = vc
    1 fix_tspaces_ind = c1
    1 default_tspace = vc
    1 temp_tspace = vc
    1 tgt_dbname = vc
    1 connect_back = c1
    1 replace_tspaces = c1
    1 replace_pwds = c1
  )
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_pwd = ""
  SET dcdur_input->src_cnct_str = ""
  SET dcdur_input->tgt_user = ""
  SET dcdur_input->tgt_pwd = ""
  SET dcdur_input->tgt_cnct_str = ""
  SET dcdur_input->fix_tspaces_ind = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->user_list = ""
  SET dcdur_input->tgt_dbname = ""
  SET dcdur_input->connect_back = ""
  SET dcdur_input->replace_tspaces = ""
  SET dcdur_input->replace_pwds = ""
 ENDIF
 IF (validate(dcdur_server_pwds->cnt,1)=1
  AND validate(dcdur_server_pwds->cnt,2)=2)
  FREE RECORD dcdur_server_pwds
  RECORD dcdur_server_pwds(
    1 cnt = i4
    1 qual[*]
      2 server = i4
      2 user = vc
      2 pwd = vc
  )
  SET dcdur_server_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_owner_pwds->cnt,1)=1
  AND validate(dcdur_owner_pwds->cnt,2)=2)
  FREE RECORD dcdur_owner_pwds
  RECORD dcdur_owner_pwds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 owner = vc
      2 pwd = vc
  )
  SET dcdur_owner_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_cmds->cnt,1)=1
  AND validate(dcdur_cmds->cnt,2)=2)
  FREE RECORD dcdur_cmds
  RECORD dcdur_cmds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 name = vc
      2 command = vc
      2 owner = vc
      2 default_tspace = vc
      2 temp_tspace = vc
      2 pwd = vc
      2 default_tspace_quota = vc
  )
  SET dcdur_cmds->cnt = 0
 ENDIF
 IF (validate(dcdur_user_data->misc_tspace_default,"X")="X"
  AND validate(dcdur_user_data->misc_tspace_default,"Y")="Y")
  FREE RECORD dcdur_user_data
  RECORD dcdur_user_data(
    1 misc_tspace_default = vc
    1 temp_tspace_default = vc
    1 misc_tspace_force = vc
    1 temp_tspace_force = vc
    1 user_cnt = i4
    1 users[*]
      2 user = vc
      2 misc_tspace = vc
      2 temp_tspace = vc
    1 tgt_sys_user = vc
    1 tgt_sys_pwd = vc
    1 create_user_method = vc
  )
  SET dcdur_user_data->misc_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->misc_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->tgt_sys_user = "SYS"
  SET dcdur_user_data->tgt_sys_pwd = "DM2NOTSET"
  SET dcdur_user_data->create_user_method = "DM2NOTSET"
  SET dcdur_user_data->user_cnt = 0
 ENDIF
 SUBROUTINE dcdur_create_db_users(null)
   DECLARE dcdu_iter = i4 WITH protect, noconstant(0)
   DECLARE dcdu_beg = i2 WITH protect, noconstant(0)
   DECLARE dcdu_end = i2 WITH protect, noconstant(0)
   DECLARE dcdu_str = vc WITH protect, noconstant(" ")
   DECLARE dcdu_grant_ptr = i2 WITH protect, noconstant(1)
   DECLARE dcdu_start_ptr = i2 WITH protect, noconstant(0)
   DECLARE dcdu_ndx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_index1 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_index2 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_parse_cmd = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_string = vc WITH protect, noconstant("")
   DECLARE dcdu_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_str_length = i4 WITH protect, noconstant(0)
   DECLARE dcdu_user_list = vc WITH protect, noconstant("")
   DECLARE dcdu_fix_tspaces_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_replace_from = vc WITH protect, noconstant("")
   DECLARE dcdu_replace_to = vc WITH protect, noconstant("")
   DECLARE dcdu_func_owner = vc WITH protect, noconstant("")
   DECLARE dcdu_func_name = vc WITH protect, noconstant("")
   DECLARE dcdu_create_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_idx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_db_user_pwd = vc WITH protect, noconstant("")
   DECLARE dcdu_default_tspace = vc WITH protect, noconstant("")
   DECLARE dcdu_role_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_adb_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_owner = vc WITH protect, noconstant("")
   FREE RECORD dcdu_orauser
   RECORD dcdu_orauser(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 default_tspace = vc
       2 temp_tspace = vc
       2 dt_fix_ind = i2
       2 tt_fix_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   SET dcdur_cmds->cnt = 0
   SET stat = alterlist(dcdur_cmds->qual,0)
   SET dcdur_input->connect_back = "N"
   IF (dm2_adb_check("",dcdu_adb_ind)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Creating database users and all dependent objects."
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dcdur_input->src_user))=0) OR (((size(trim(dcdur_input->src_pwd))=0) OR (((size(
    trim(dcdur_input->src_cnct_str))=0) OR (((size(trim(dcdur_input->tgt_user))=0) OR (((size(trim(
     dcdur_input->tgt_pwd))=0) OR (((size(trim(dcdur_input->tgt_cnct_str))=0) OR ((( NOT ((
   dcdur_input->replace_tspaces IN ("Y", "N")))) OR ((( NOT ((dcdur_input->replace_pwds IN ("Y", "N")
   ))) OR ((( NOT ((dcdur_input->fix_tspaces_ind IN ("Y", "N")))) OR ((((dcdur_input->fix_tspaces_ind
   ="Y")
    AND size(trim(dcdur_input->default_tspace))=0) OR ((((dcdur_input->fix_tspaces_ind="Y")
    AND size(trim(dcdur_input->temp_tspace))=0) OR (((trim(dcdur_input->user_list)="") OR (findstring
   ("(",dcdur_input->user_list,1) > 0)) )) )) )) )) )) )) )) )) )) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input variables."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = concat("Using DBMS_METADATA method to create [",trim(dcdur_input->user_list),
    "] users.")
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdur_input->connect_back = "Y"
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"SOURCE"'
   SET dm2_install_schema->u_name = dcdur_input->src_user
   SET dm2_install_schema->p_word = dcdur_input->src_pwd
   SET dm2_install_schema->connect_str = dcdur_input->src_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET stat = alterlist(dcdu_orauser->qual,0)
   SET dcdu_orauser->cnt = 0
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_users du
     WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     ORDER BY du.username
     DETAIL
      dcdu_orauser->cnt = (dcdu_orauser->cnt+ 1), stat = alterlist(dcdu_orauser->qual,dcdu_orauser->
       cnt), dcdu_orauser->qual[dcdu_orauser->cnt].user = du.username,
      dcdu_orauser->qual[dcdu_orauser->cnt].default_tspace = du.default_tablespace, dcdu_orauser->
      qual[dcdu_orauser->cnt].temp_tspace = du.temporary_tablespace, dcdu_orauser->qual[dcdu_orauser
      ->cnt].dt_fix_ind = 0,
      dcdu_orauser->qual[dcdu_orauser->cnt].tt_fix_ind = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdu_orauser)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for role exclusion list override."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.info_name
    FROM dm_info d
    WHERE info_domain="DM2_ROLE_EXLUSION_LIST_OVERRIDE"
    DETAIL
     dcdu_where_clause = concat("r.grantee not in(",d.info_name,")")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdu_where_clause <= "")
    SET dcdu_where_clause = concat(
     "r.grantee not in('CONNECT','RESOURCE','DBA','EXP_FULL_DATABASE','IMP_FULL_DATABASE',",
     "'DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','SELECT_CATALOG_ROLE',",
     "'RECOVERY_CATALOG_OWNER','HS_ADMIN_ROLE','AQ_USER_ROLE','AQ_ADMINISTRATOR_ROLE',",
     "'SNMPAGENT','SCHEDULER_ADMIN')")
   ENDIF
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve Source DDL to create Functions, Profiles, Users, Roles and Grants."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((validate(dm2_bypass_get_pwd_function_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source dependent functions' DDL used in the PASSWORD_VERIFY_FUNCTION function ",
     "of profiles for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.referenced_name, dp.referenced_owner)")
       FROM (
        (
        (SELECT DISTINCT
         d.referenced_name, d.referenced_owner
         FROM dba_profiles p,
          dba_objects o,
          dba_dependencies d
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          du.profile
          FROM dba_users du
          WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
          AND o.object_name=d.name
          AND d.referenced_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
    SET dm_err->eproc = concat(
     "Get all Source PASSWORD_VERIFY_FUNCTION functions' DDL used during create ",
     "profile for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.object_name, dp.owner)")
       FROM (
        (
        (SELECT DISTINCT
         o.object_name, o.owner
         FROM dba_profiles p,
          dba_objects o
         WHERE p.profile != "DEFAULT"
          AND p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_profiles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create/alter profile DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('PROFILE', dp.profile)")
       FROM (
        (
        (SELECT DISTINCT
         p.profile
         FROM dba_profiles p
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))))
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "PROFILE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_users_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create user DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
       WITH sqltype("C32000")))
      a)
     DETAIL
      IF ((dm_err->debug_flag > 4))
       CALL echo(concat("x = ",a.x))
      ENDIF
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),"")
       IF ((dm_err->debug_flag > 4))
        CALL echo(concat("dcdu_cmd_string = ",dcdu_cmd_string))
       ENDIF
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_beg =",dcdu_beg))
          ENDIF
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_grant_ptr =",dcdu_grant_ptr)),
           CALL echo(build("dcdu_start_ptr =",dcdu_start_ptr))
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2)
          IF ((dm_err->debug_flag > 4))
           CALL echo(concat("dcdu_parse_cmd = ",dcdu_parse_cmd))
          ENDIF
          dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,
           dcdur_cmds->qual[dcdu_index2].command)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_index2 = ",dcdu_index2))
          ENDIF
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].owner = dcdur_cmds->qual[dcdur_cmds->cnt].name,
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "USER", dcdur_cmds->qual[dcdur_cmds->cnt].command
            = dcdu_parse_cmd
           IF (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].default_tspace = substring((findstring(
              "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20)+ 1
              )) - (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 20)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].temp_tspace = substring((findstring(
              "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
              + 1)) - (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 22)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(findstring("'",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring("IDENTIFIED BY VALUES '",
               dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)+ 1)) - (findstring(
              "IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
             ),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   SET dcdu_role_where_clause = " 1=1 "
   IF ((dm2_rdbms_version->level1 > 11))
    SET dcdu_role_where_clause = " u.COMMON='NO' "
   ENDIF
   IF ((validate(dm2_bypass_get_roles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get all Source create role DDL (i.e. create role <role>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('ROLE', ROLE)")
       FROM dba_roles u
       WHERE parser(dcdu_role_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2), dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,
           dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "ROLE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_role_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for all roles (i.e. grant <role> to <role>) excluding default roles."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', r.grantee)")
       FROM dba_role_privs r
       WHERE r.grantee IN (
       (SELECT
        x.role
        FROM dba_roles x))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_system_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source system priv grant DDL for all roles (i.e. grant <sys priv> to <role>)",
     "excluding default roles.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', r.grantee)")
       FROM dba_sys_privs r
       WHERE r.grantee IN (
       (SELECT
        u.role
        FROM dba_roles u
        WHERE parser(dcdu_role_where_clause)))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_role_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for user(s) specified (i.e. grant <role> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_role_privs drp
        WHERE drp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT"
           IF (findstring('"DBA"',dcdu_parse_cmd) > 0
            AND dcdu_adb_ind=1)
            dcdu_parse_cmd = replace(dcdu_parse_cmd,'"DBA"','"PDB_DBA"')
           ENDIF
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_system_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source sys priv grant DDL (not role) for user(s) specified (i.e. grant <sys priv> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_sys_privs dsp
        WHERE dsp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_table_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Retrieve Source DDL for SYS object grants on user(s) specified."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tab_privs dtp
     WHERE dtp.owner="SYS"
      AND parser(concat("dtp.grantee in (",dcdur_input->user_list,")"))
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdur_cmds->qual[dcdur_cmds->cnt].type = "TABLE GRANT",
      dcdur_cmds->qual[dcdur_cmds->cnt].owner = dtp.owner, dcdur_cmds->qual[dcdur_cmds->cnt].name =
      dtp.table_name
      IF (dtp.privilege IN ("READ", "WRITE"))
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),
        ' ON DIRECTORY "',trim(dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ELSE
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),' ON "',trim(
         dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for Source users default tablespaces with unlimited quota."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_ts_quotas dtq,
     dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     AND du.username=dtq.username
     AND du.default_tablespace=dtq.tablespace_name
     AND (dtq.max_bytes=- (1))
    DETAIL
     dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,"USER",dcdur_cmds->qual[
      dcdu_index1].type,
      du.username,dcdur_cmds->qual[dcdu_index1].owner,du.default_tablespace,dcdur_cmds->qual[
      dcdu_index1].default_tspace)
     IF (dcdu_index1 > 0)
      dcdur_cmds->qual[dcdu_index1].default_tspace_quota = "Y"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_cmds)
   ENDIF
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"TARGET"'
   SET dm2_install_schema->u_name = dcdur_input->tgt_user
   SET dm2_install_schema->p_word = dcdur_input->tgt_pwd
   SET dm2_install_schema->connect_str = dcdur_input->tgt_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dcdur_input->connect_back = "N"
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieving Target tablespaces from dba_tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     dt.tablespace_name
     FROM dba_tablespaces dt
     DETAIL
      dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
       cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dcdu_iter = 1 TO dcdu_orauser->cnt)
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].
       default_tspace,dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].dt_fix_ind = 1
      ENDIF
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].temp_tspace,
       dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].tt_fix_ind = 1
      ENDIF
    ENDFOR
    IF (dcdu_fix_tspaces_ind=1)
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dcdu_orauser)
     ENDIF
    ELSE
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ENDIF
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,
       " user exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users u
       WHERE u.username=cnvtupper(dcdur_cmds->qual[dcdu_iter].owner)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dcdu_cmd_string = dcdur_cmds->qual[dcdu_iter].command
       IF (dcdu_fix_tspaces_ind=1)
        SET dcdu_ndx = 0
        SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_orauser->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         dcdu_orauser->qual[dcdu_ndx].user)
        IF (dcdu_ndx > 0)
         IF ((dcdu_orauser->qual[dcdu_ndx].dt_fix_ind=1))
          SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           default_tspace,'"')
          SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_input->default_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
         IF ((dcdu_orauser->qual[dcdu_ndx].tt_fix_ind=1))
          SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           temp_tspace,'"')
          SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_input->temp_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
        ENDIF
       ENDIF
       IF ((dcdur_input->replace_tspaces="Y"))
        SET dcdu_idx = 0
        IF (dcdur_prompt_tspaces(dcdur_cmds->qual[dcdu_iter].owner,dcdur_input->tgt_dbname,dcdu_idx)=
        0)
         RETURN(0)
        ENDIF
        SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         default_tspace,'"')
        SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         misc_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
        SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         temp_tspace,'"')
        SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         temp_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
       ENDIF
       IF ((dcdur_input->replace_pwds="Y"))
        SET dcdu_idx = 0
        SET dcdu_idx = locateval(dcdu_idx,1,dir_db_users_pwds->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         replace(dir_db_users_pwds->qual[dcdu_idx].user,"'","",0))
        SET dcdu_db_user_pwd = dir_db_users_pwds->qual[dcdu_idx].pwd
        SET dcdu_cmd_string = replace(dcdu_cmd_string,concat("'",dcdur_cmds->qual[dcdu_iter].pwd,"'"),
         concat('"',dcdu_db_user_pwd,'"'),0)
        SET dcdu_cmd_string = replace(dcdu_cmd_string,"IDENTIFIED BY VALUES","IDENTIFIED BY",0)
       ENDIF
       IF (dm2_push_cmd(build("rdb asis(^",dcdu_cmd_string,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,
         " user already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="ROLE"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
       " role exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_roles u
       WHERE u.role=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name," role already exists in TARGET."
         )
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="PROFILE"))
      SET dcdu_create_ind = 1
      IF (findstring("CREATE PROFILE",dcdur_cmds->qual[dcdu_iter].command,1,0) > 0)
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
        " profile exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_profiles p
        WHERE p.profile=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual > 0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name,
          " profile already exists in TARGET.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="FUNCTION"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
       dcdu_iter].name," function exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_objects o
       WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
        AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        AND o.object_type="FUNCTION"
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[dcdu_iter].
         name," function already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSE
      SET dcdu_create_ind = 1
      IF ((dcdur_cmds->qual[dcdu_iter].type="TABLE GRANT"))
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
        dcdu_iter].name," object exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_objects o
        WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
         AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat("No ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
          dcdu_iter].name," object found in TARGET, skipping TABLE GRANT command.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        SET dm_err->err_ind = 0
        SET dm_err->eproc = "THE ABOVE ERROR MESSAGE IS IGNORABLE"
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER")
      AND (dcdur_cmds->qual[dcdu_iter].default_tspace_quota="Y"))
      SET dm_err->eproc = concat("Obtain default tablespace for [",dcdur_cmds->qual[dcdu_iter].owner,
       "] user.")
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users du
       WHERE (du.username=dcdur_cmds->qual[dcdu_iter].owner)
       DETAIL
        dcdu_default_tspace = du.default_tablespace
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET dm_err->eproc = concat("Give unlimited tablespace quota to ",dcdur_cmds->qual[dcdu_iter].
       owner," user's default tablespace [",trim(dcdu_default_tspace),"].")
      CALL disp_msg(" ",dm_err->logfile,10)
      IF (dm2_push_cmd(concat("rdb asis(^alter user ",dcdur_cmds->qual[dcdu_iter].owner,
        " quota unlimited on ",trim(dcdu_default_tspace),"^) go"),1)=0)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_report_db_users_diff_tspaces(null)
   DECLARE drdudt_ndx = i4 WITH protect, noconstant(0)
   DECLARE drdudt_ndx2 = i4 WITH protect, noconstant(0)
   DECLARE drdudt_diff_tspace = i2 WITH protect, noconstant(0)
   DECLARE drdudt_str = vc WITH protect, noconstant(" ")
   DECLARE drdudt_file = vc WITH protect, noconstant("")
   FREE RECORD drdudt_user_tsp
   RECORD drdudt_user_tsp(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 create_dt_tm = dq8
       2 src_default_tspace = vc
       2 src_temp_tspace = vc
       2 tgt_default_tspace = vc
       2 tgt_temp_tspace = vc
       2 dt_diff_ind = i2
       2 tt_diff_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   IF ((dcdur_input->fix_tspaces_ind != "Y"))
    RETURN(1)
   ENDIF
   IF (((size(trim(dcdur_input->default_tspace))=0) OR (((size(trim(dcdur_input->temp_tspace))=0) OR
   (size(trim(dcdur_input->user_list))=0)) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users@ref_data_link du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_user_tsp->cnt = (drdudt_user_tsp->cnt+ 1), stat = alterlist(drdudt_user_tsp->qual,
      drdudt_user_tsp->cnt), drdudt_user_tsp->qual[drdudt_user_tsp->cnt].user = du.username,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_default_tspace = du.default_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_temp_tspace = du.temporary_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_default_tspace = "",
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_temp_tspace = "", drdudt_user_tsp->qual[
     drdudt_user_tsp->cnt].dt_diff_ind = 0, drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tt_diff_ind
      = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving tablespaces from dba_tablespaces."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    dt.tablespace_name
    FROM dba_tablespaces dt
    DETAIL
     dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
      cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Target custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_ndx = 0, drdudt_ndx = locateval(drdudt_ndx,1,drdudt_user_tsp->cnt,du.username,
      drdudt_user_tsp->qual[drdudt_ndx].user)
     IF (drdudt_ndx > 0)
      drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace = du.default_tablespace, drdudt_user_tsp->
      qual[drdudt_ndx].tgt_temp_tspace = du.temporary_tablespace, drdudt_user_tsp->qual[drdudt_ndx].
      create_dt_tm = du.created,
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_default_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_default_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_default_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace=dcdur_input->default_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].dt_diff_ind = 1
      ENDIF
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_temp_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_temp_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_temp_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_temp_tspace=dcdur_input->temp_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].tt_diff_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drdudt_user_tsp)
   ENDIF
   IF (drdudt_diff_tspace=1)
    IF (get_unique_file("dm2_db_user_tspace",".rpt")=0)
     RETURN(0)
    ENDIF
    SET drdudt_file = dm_err->unique_fname
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET drdudt_file = build(drrr_misc_data->active_dir,drdudt_file)
    ENDIF
    SET dm_err->eproc = concat(
     "Reporting Target Database users having different default/temporary tablespaces then Source (",
     trim(drdudt_file),").")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO value(drdudt_file)
     FROM (dummyt t  WITH seq = drdudt_user_tsp->cnt)
     HEAD REPORT
      col 50, "Database Users Missing Default/Temporary Tablespaces", row + 2,
      row + 1, drdudt_str = concat(
       "The following reports Source database users created in Target with different default and/or ",
       " temporary tablespaces due to the tablespaces not existing in Target."), col 0,
      drdudt_str, row + 2, row + 1,
      col 0, "Missing Default Tablespace replaced with: ", dcdur_input->default_tspace,
      row + 2, col 0, "Missing Temporary Tablespace replaced with: ",
      dcdur_input->temp_tspace, row + 2, row + 1,
      col 0, "A Default/Temporary Tablespace of '-' denotes no differences.", row + 2,
      row + 1, col 0, "User",
      col 35, "Created", col 70,
      "Source Default Tablespace", col 105, "Source Temporary Tablespace",
      row + 1, col 0, "------------------------------",
      col 35, "------------------------------", col 70,
      "------------------------------", col 105, "------------------------------",
      row + 1
     DETAIL
      IF ((((drdudt_user_tsp->qual[t.seq].dt_diff_ind=1)) OR ((drdudt_user_tsp->qual[t.seq].
      tt_diff_ind=1))) )
       drdudt_str = drdudt_user_tsp->qual[t.seq].user, col 0, drdudt_str,
       drdudt_str = format(cnvtdatetime(drdudt_user_tsp->qual[t.seq].create_dt_tm),";;q"), col 35,
       drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].dt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_default_tspace,"-"), col 70, drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].tt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_temp_tspace,"-"), col 105, drdudt_str,
       row + 1
      ENDIF
     WITH nocounter, maxcol = 250, format = variable,
      formfeed = none, maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = concat(
      "Skipping display of Database Users Missing Default/Temporary Tablespaces Report (",trim(
       drdudt_file,3),")")
     CALL disp_msg("",dm_err->logfile,0)
     IF ((drer_email_list->email_cnt > 0))
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was generated at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Please review the report to ensure desired Default/Temporary Tablespaces",
        " are used for each user."),0)
      CALL drer_add_body_text(concat("Report file name is : ",drdudt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
    ELSE
     IF ((dm2_install_schema->process_option="CLIN COPY")
      AND (drer_email_list->email_cnt > 0))
      SET drer_email_det->process = drr_clin_copy_data->process
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "PAUSED"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was displayed at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Return to dm2_domain_maint main session and review ",
        "Database Users Missing Default/Temporary Tablespaces report displayed on the screen.  Press <enter> to continue."
        ),0)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",drdudt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
     IF (dm2_disp_file(drdudt_file,"Database Users Missing Default/Temporary Tablespaces")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_cleanup_pwds(dcp_in_dbname)
   SET dm_err->eproc = concat("Delete password data in Admin DM_INFO for database ",dcp_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
     AND di.info_name=patstring(cnvtupper(build(dcp_in_dbname,"*")))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_insert_pwds(dip_in_dbname,dip_in_type,dip_in_user,dip_in_pwd)
   DECLARE dip_scrambled_pwd = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Insert user password rows for database ",dip_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dip_in_dbname))=0) OR (((size(trim(dip_in_type))=0) OR (((size(trim(dip_in_user))=
   0) OR (size(trim(dip_in_pwd))=0)) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria for insert of password."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dip_scrambled_pwd = dip_in_pwd
   IF (dip_in_type IN ("LOGIN", "SERVER"))
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 1
    SET dm2scramble->in_text = dip_in_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
    SET dip_scrambled_pwd = dm2scramble->out_text
   ENDIF
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
        dip_in_dbname),"-",trim(dip_in_type),"-",trim(dip_in_user))), di.info_char =
     dip_scrambled_pwd,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc) > 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE dcdur_preserve_pwds(dpp_in_dbname)
   DECLARE dpp_idx = i2 WITH protect, noconstant(0)
   DECLARE dpp_cmd_string = vc WITH protect, noconstant("")
   DECLARE dpp_iter = i4 WITH protect, noconstant(0)
   DECLARE dpp_owner = vc WITH protect, noconstant("")
   DECLARE dpp_str = vc WITH protect, noconstant("")
   DECLARE dpp_env = vc WITH protect, noconstant("")
   DECLARE dpp_domain = vc WITH protect, noconstant("")
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve CREATE USER DDL to retrieve password values."
   SELECT INTO "nl:"
    FROM (
     (
     (SELECT
      x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
      FROM dba_users u
      WHERE u.username != "XS$NULL"
      WITH sqltype("C32000")))
     a)
    DETAIL
     IF (findstring(";",trim(a.x,3),1) > 0)
      dpp_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
      dpp_owner = substring((findstring('"',dpp_cmd_string,1)+ 1),((findstring('"',dpp_cmd_string,(
        findstring('"',dpp_cmd_string,1)+ 1)) - findstring('"',dpp_cmd_string,1)) - 1),dpp_cmd_string
       ), dpp_idx = 0,
      dpp_idx = locateval(dpp_idx,1,dcdur_owner_pwds->cnt,dpp_owner,dcdur_owner_pwds->qual[dpp_idx].
       owner)
      IF (dpp_idx=0)
       IF (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1) > 0)
        dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1), stat = alterlist(dcdur_owner_pwds->qual,
         dcdur_owner_pwds->cnt), dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "DB",
        dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dpp_owner, dcdur_owner_pwds->qual[
        dcdur_owner_pwds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
         + 22),(findstring("'",dpp_cmd_string,((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
          + 22)+ 1)) - (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)+ 22)),dpp_cmd_string)
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   SET dm_err->eproc = "Get environment name."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dpp_env = cnvtlower(trim(logical("environment")))
   IF (trim(dpp_env) > " ")
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("ENVIRONMENT LOGICAL:",dpp_env))
    ENDIF
   ELSE
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dpp_str = concat("\\environment\\",dpp_env," Domain")
   IF (ddr_lreg_oper("GET",dpp_str,dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dpp_domain="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve domain name property for ",dpp_env)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdur_get_server_users_pwds(dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dcdur_get_db_owner_pwds(dpp_in_dbname)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_owner_pwds->cnt > 0))
    FOR (dpp_iter = 1 TO dcdur_owner_pwds->cnt)
      IF ((dcdur_owner_pwds->qual[dpp_iter].type IN ("LOGIN", "SERVER")))
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 1
       SET dm2scramble->in_text = dcdur_owner_pwds->qual[dpp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
       SET dcdur_owner_pwds->qual[dpp_iter].pwd = dm2scramble->out_text
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
    IF (dcdur_cleanup_pwds(dpp_in_dbname)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert user password rows for database ",dpp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(dcdur_owner_pwds->cnt))
     SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
         dpp_in_dbname),"-",trim(dcdur_owner_pwds->qual[d.seq].type),"-",trim(dcdur_owner_pwds->qual[
         d.seq].owner))), di.info_char = dcdur_owner_pwds->qual[d.seq].pwd,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d
      WHERE d.seq > 0)
      JOIN (di)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc) > 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_restore_pwds(drp_in_dbname,drp_in_mode)
   DECLARE drp_idx = i2 WITH protect, noconstant(0)
   DECLARE drp_cmd_string = vc WITH protect, noconstant("")
   DECLARE drp_iter = i4 WITH protect, noconstant(0)
   DECLARE drp_str = vc WITH protect, noconstant("")
   DECLARE drp_issue_cmds = i2 WITH protect, noconstant(0)
   DECLARE drp_owner = vc WITH protect, noconstant("")
   DECLARE drp_sea = vc WITH protect, noconstant("")
   DECLARE drp_file = vc WITH protect, noconstant("")
   DECLARE drp_tmp_pwd = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drp_env = vc WITH protect, noconstant("")
   DECLARE drp_domain = vc WITH protect, noconstant("")
   DECLARE drp_ret_val = vc WITH protect, noconstant("")
   DECLARE drp_tmp_owner = vc WITH protect, noconstant("")
   FREE RECORD drp_pwds
   RECORD drp_pwds(
     1 cnt = i4
     1 qual[*]
       2 owner = vc
       2 pwd = vc
   )
   FREE RECORD drp_cmds
   RECORD drp_cmds(
     1 cnt = i4
     1 qual[*]
       2 command = vc
       2 owner = vc
       2 common = vc
       2 oracle_maintained = vc
       2 pwd = vc
       2 issue_cmd = i2
   )
   IF (drp_in_mode IN ("SERVERS", "ALL"))
    SET dm_err->eproc = "Get environment name."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drp_env = cnvtlower(trim(logical("environment")))
    IF (trim(drp_env) > " ")
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("ENVIRONMENT LOGICAL:",drp_env))
     ENDIF
    ELSE
     SET dm_err->emsg = "Environment logical is not valued."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\environment\\",drp_env," Domain")
    IF (ddr_lreg_oper("GET",drp_str,drp_domain)=0)
     RETURN(0)
    ENDIF
    IF (drp_domain="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve domain name property for ",drp_env)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Retrieve server user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-SERVER*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-SERVER-")), drp_owner = replace(di.info_name,drp_sea,
       "",0), drp_pwds->cnt = (drp_pwds->cnt+ 1),
      stat = alterlist(drp_pwds->qual,drp_pwds->cnt), drp_pwds->qual[drp_pwds->cnt].owner = cnvtupper
      (drp_owner), drp_pwds->qual[drp_pwds->cnt].pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_pwds)
    ENDIF
    IF ((drp_pwds->cnt > 0))
     IF (dcdur_get_server_users_pwds(drp_domain)=0)
      RETURN(0)
     ENDIF
     IF ((dcdur_server_pwds->cnt=0))
      SET dm_err->eproc =
      "No existing server 'Rdbms Password' properties to restore preserved passwords against."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ELSE
     SET dm_err->eproc = "No preserved server passwords to restore."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((drp_pwds->cnt > 0)
     AND (dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO drp_pwds->cnt)
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 0
       SET dm2scramble->in_text = drp_pwds->qual[drp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET drp_pwds->qual[drp_iter].pwd = dm2scramble->out_text
     ENDFOR
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(drp_pwds)
     ENDIF
    ENDIF
    IF ((dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO dcdur_server_pwds->cnt)
       SET drp_tmp_owner = cnvtupper(dcdur_server_pwds->qual[drp_iter].user)
       SET drp_idx = 0
       SET drp_idx = locateval(drp_idx,1,drp_pwds->cnt,drp_tmp_owner,drp_pwds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        IF ( NOT ((dcdur_server_pwds->qual[drp_iter].server IN (58, 74))))
         SET dm_err->eproc = concat('Set "Rdbms Password" for server ',trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server)),".")
         CALL disp_msg("",dm_err->logfile,0)
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password" ','"',
          trim(drp_pwds->qual[drp_idx].pwd),'"')
         IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password"')
         IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         IF (trim(drp_ret_val) != trim(drp_pwds->qual[drp_idx].pwd))
          SET dm_err->emsg = concat('Error setting "Rdbms Password" for server ',trim(cnvtstring(
             dcdur_server_pwds->qual[drp_iter].server)),".")
          SET dm_err->err_ind = 1
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->eproc = concat("Skipping update of Rdbms Password for server ",trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server))," as already updated in earlier step.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = "Retrieving preserved password to complete restore."
        SET dm_err->emsg = concat("No preserved password found for server ",trim(cnvtstring(
           dcdur_server_pwds->qual[drp_iter].server))," and user ",trim(dcdur_server_pwds->qual[
          drp_iter].user),".")
        SET dm_err->user_action = concat(
         "After filling in <password> with original Target password, ",
         "execute the following and then rerun restore process: dm2_repl_insert_pwds 'SERVER', '",
         trim(dcdur_server_pwds->qual[drp_iter].user),"', '<password>' go")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL"))
    SET dm_err->eproc = "Retrieve database users."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT
     IF ((dm2_rdbms_version->level1 >= 12))
      FROM (
       (
       (SELECT
        username = x.username, common = x.common, oracle_maintained = x.oracle_maintained
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ELSE
      FROM (
       (
       (SELECT
        username = x.username, common = "NO", oracle_maintained = "N"
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ENDIF
     INTO "nl:"
     du.username, du.common, du.oracle_maintained
     ORDER BY du.username
     DETAIL
      drp_cmds->cnt = (drp_cmds->cnt+ 1), stat = alterlist(drp_cmds->qual,drp_cmds->cnt), drp_cmds->
      qual[drp_cmds->cnt].owner = du.username,
      drp_cmds->qual[drp_cmds->cnt].common = du.common, drp_cmds->qual[drp_cmds->cnt].
      oracle_maintained = du.oracle_maintained, drp_cmds->qual[drp_cmds->cnt].issue_cmd = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    SET dm_err->eproc = concat("Retrieve database user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-DB*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-DB-")), drp_owner = replace(di.info_name,drp_sea,"",0
       ), drp_idx = 0
      IF (drp_owner != "V500")
       drp_idx = locateval(drp_idx,1,drp_cmds->cnt,drp_owner,drp_cmds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        drp_cmds->qual[drp_idx].pwd = di.info_char, drp_cmds->qual[drp_idx].command = concat(
         "ALTER USER ",build('"',trim(drp_cmds->qual[drp_idx].owner),'"')," IDENTIFIED BY VALUES ",
         build("'",trim(drp_cmds->qual[drp_idx].pwd),"'")," account unlock")
        IF ((drp_cmds->qual[drp_idx].common="NO")
         AND (drp_cmds->qual[drp_idx].oracle_maintained="N"))
         drp_cmds->qual[drp_idx].issue_cmd = 1, drp_issue_cmds = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    IF (drp_issue_cmds=1)
     FOR (drp_iter = 1 TO drp_cmds->cnt)
       IF ((drp_cmds->qual[drp_iter].issue_cmd > 0))
        SET dm_err->eproc = concat("Restoring password for database user ",drp_cmds->qual[drp_iter].
         owner)
        CALL disp_msg("",dm_err->logfile,0)
        IF (dm2_push_cmd(build("rdb asis(^",drp_cmds->qual[drp_iter].command,"^) go"),1)=0)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->eproc = concat("Skipping restore password for user ",drp_cmds->qual[drp_iter].
         owner," because either V500, COMMON or Oracle Maintained.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
     ENDFOR
    ELSE
     SET dm_err->eproc = "No preserved database users to restore passwords against."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL", "LOGIN"))
    SET dm_err->eproc = concat("Retrieve login pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-LOGIN*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_tmp_pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drp_tmp_pwd="DM2NOTSET")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating preserved login password in Admin DM_INFO."
     SET dm_err->emsg = "No login password found."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 0
    SET dm2scramble->in_text = drp_tmp_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET drp_tmp_pwd = dm2scramble->out_text
    SET dm_err->eproc = 'Set "Rdbms Password" in registry, for the database property.'
    CALL disp_msg("",dm_err->logfile,0)
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ',
     '"',trim(drp_tmp_pwd),'"')
    IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
    IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (trim(drp_ret_val) != trim(drp_tmp_pwd))
     SET dm_err->emsg = 'Error setting "Rdbms Password" for database property in registry.'
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_server_users_pwds(dgsup_in_domain)
   DECLARE dgsup_idx = i2 WITH protect, noconstant(0)
   DECLARE dgsup_cmd_string = vc WITH protect, noconstant("")
   DECLARE dgsup_iter = i4 WITH protect, noconstant(0)
   DECLARE dgsup_str = vc WITH protect, noconstant("")
   DECLARE dgsup_num = i4 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err1 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err2 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_str = vc WITH protect, noconstant("")
   DECLARE dgsup_err_msg = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms Passwords for all servers."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    HEAD REPORT
     dcdur_server_pwds->cnt = 0, stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt)
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms password",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dcdur_server_pwds->cnt = (
       dcdur_server_pwds->cnt+ 1),
       stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt), dcdur_server_pwds->qual[
       dcdur_server_pwds->cnt].pwd = dgsup_str, dcdur_server_pwds->qual[dcdur_server_pwds->cnt].
       server = dgsup_num,
       dcdur_server_pwds->qual[dcdur_server_pwds->cnt].user = ""
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms User Names for all servers with associated password property."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms user name",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dgsup_idx = 0,
       dgsup_idx = locateval(dgsup_idx,1,dcdur_server_pwds->cnt,dgsup_num,dcdur_server_pwds->qual[
        dgsup_idx].server)
       IF (dgsup_idx > 0)
        dcdur_server_pwds->qual[dgsup_idx].user = dgsup_str
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dcdur_server_pwds->cnt > 0))
    SET dm_err->eproc = "Rolling up Server User Name and Password properties."
    CALL disp_msg("",dm_err->logfile,0)
    FOR (dgsup_iter = 1 TO dcdur_server_pwds->cnt)
      IF ((dcdur_server_pwds->qual[dgsup_iter].user > "")
       AND (dcdur_server_pwds->qual[dgsup_iter].pwd > ""))
       IF ((dcdur_owner_pwds->cnt=0))
        SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
        SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter]
        .user
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
        pwd
       ELSE
        SET dgsup_idx = 0
        SET dgsup_idx = locateval(dgsup_idx,1,dcdur_owner_pwds->cnt,dcdur_server_pwds->qual[
         dgsup_iter].user,dcdur_owner_pwds->qual[dgsup_idx].owner,
         "SERVER",dcdur_owner_pwds->qual[dgsup_idx].type)
        IF (dgsup_idx > 0)
         IF ((dcdur_owner_pwds->qual[dgsup_idx].pwd != dcdur_server_pwds->qual[dgsup_iter].pwd))
          SET dgsup_fatal_err1 = 1
          IF (dgsup_fatal_str="")
           SET dgsup_fatal_str = concat(trim(dcdur_owner_pwds->qual[dgsup_idx].owner),", ")
          ELSE
           SET dgsup_fatal_str = concat(dgsup_fatal_str,trim(dcdur_owner_pwds->qual[dgsup_idx].owner),
            ", ")
          ENDIF
         ENDIF
        ELSE
         SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
         SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter
         ].user
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
         pwd
        ENDIF
       ENDIF
      ELSE
       SET dgsup_fatal_err2 = 1
      ENDIF
    ENDFOR
    IF (((dgsup_fatal_err1=1) OR (dgsup_fatal_err2=1)) )
     IF (dgsup_fatal_err2=1)
      SET dgsup_err_msg = concat(
       "'Rdbms Password' properties found without an associated 'Rdbms User Name' ","property.")
     ENDIF
     IF (dgsup_fatal_err1=1)
      SET dgsup_fatal_str = replace(dgsup_fatal_str,",","",2)
      SET dgsup_err_msg = concat(dgsup_err_msg,
       "   The following is a list of 'Rdbms User Name' property values with ",
       "inconsistent 'Rdbms Password' ","property values: ",trim(dgsup_fatal_str),
       ".")
     ENDIF
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ELSE
      SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ENDIF
     SET dgsup_err_msg = concat(trim(dgsup_err_msg,3),"   Use the following alter_server command to ",
      "reconcile issues:  ",trim(dgsup_cmd_string),".")
     SET dm_err->err_ind = 1
     SET dm_err->emsg = trim(dgsup_err_msg,3)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("No 'Rdbms Passwords' properties found for any servers.")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_load(dutl_db_name)
   DECLARE dutl_info_domain = vc WITH protect, noconstant("")
   DECLARE dutl_len = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dutl_cur_user = vc WITH protect, noconstant("")
   DECLARE dutl_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dutl_ndx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load dcdur_user_data record structure"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dcdur_user_data->user_cnt=0))
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
     SET dm_err->eproc = "Retrieve tablespace mappings for TEMP and MISC"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm2_admin_dm_info d
      WHERE cnvtupper(d.info_domain)=patstring(build("DM2_",cnvtupper(dutl_db_name),
        "_*_TSPACE_MAPPING"))
       AND cnvtupper(d.info_name) IN ("MISC_TSPACE", "TEMP_TSPACE")
      HEAD REPORT
       dcdur_user_data->user_cnt = 0, stat = alterlist(dcdur_user_data->users,dcdur_user_data->
        user_cnt)
      DETAIL
       dutl_cur_idx = 0, dutl_cur_user = "", dutl_info_domain = d.info_domain,
       dutl_len = textlen(trim(dutl_db_name)), dutl_pos = findstring(trim(cnvtupper(dutl_db_name)),
        dutl_info_domain,1,0), dutl_pos = ((dutl_pos+ dutl_len)+ 1),
       dutl_pos2 = findstring("_TSPACE_MAPPING",dutl_info_domain,1,1), dutl_cur_user = substring(
        dutl_pos,(dutl_pos2 - dutl_pos),dutl_info_domain)
       IF ((dcdur_user_data->user_cnt > 0))
        dutl_cur_idx = locateval(dutl_ndx,1,dcdur_user_data->user_cnt,dutl_cur_user,dcdur_user_data->
         users[dutl_ndx].user)
       ENDIF
       IF (dutl_cur_idx=0)
        dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1), stat = alterlist(dcdur_user_data
         ->users,dcdur_user_data->user_cnt), dcdur_user_data->users[dcdur_user_data->user_cnt].user
         = dutl_cur_user
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = d.info_char
        ENDIF
       ELSE
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].temp_tspace = d.info_char
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_user_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_insert_admin_tspace_rows(diatr_user_name,diatr_db_name,diatr_temp_ts,diatr_misc_ts)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
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
    SET dm_err->eproc = concat("Insert tablespace mappings rows into dm2_admin_dm_info for user: ",
     diatr_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = "Insert MISC TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "MISC_TSPACE", d.info_char =
      diatr_misc_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Insert TEMP TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "TEMP_TSPACE", d.info_char =
      diatr_temp_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_prompt_tspaces(dpt_user_name,dpt_db_name,dpt_user_idx)
   DECLARE dpt_temp_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_misc_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_cur_ts_tmp = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_len = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dpt_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dpt_ndx = i4 WITH protect, noconstant(0)
   DECLARE dpt_continue = i2 WITH protect, noconstant(1)
   DECLARE dpt_invalid_misc_ts = i2 WITH protect, noconstant(0)
   DECLARE dpt_invalid_temp_ts = i2 WITH protect, noconstant(0)
   IF (dcdur_user_tspace_load(dpt_db_name)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_user_data->user_cnt > 0))
    SET dpt_cur_idx = locateval(dpt_ndx,1,dcdur_user_data->user_cnt,cnvtupper(dpt_user_name),
     dcdur_user_data->users[dpt_ndx].user)
    IF (dpt_cur_idx > 0)
     SET dpt_user_idx = dpt_cur_idx
     RETURN(1)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verify that current user is a valid user"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE cnvtupper(du.username)=cnvtupper(dpt_user_name)
    DETAIL
     dpt_temp_ts_def = trim(cnvtupper(du.temporary_tablespace)), dpt_misc_ts_def = trim(cnvtupper(du
       .default_tablespace))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")
    SET dpt_misc_ts_def = drrr_rf_data->tgt_default_misc_ts
    SET dpt_temp_ts_def = drrr_rf_data->tgt_default_temp_ts
    IF (((dpt_misc_ts_def="DM2NOTSET") OR (dpt_temp_ts_def="DM2NOTSET")) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if default tablespaces are set in the response file."
     SET dm_err->emsg = concat("Invalid values found for default tablespaces in the response file. ",
      "Please provide valid inputs for s_TGT_DEFAULT_MISC_TS and s_TGT_DEFAULT_TEMP_TS tokens.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((curqual > 0) OR (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")) )
    IF ((dm_err->debug_flag > 0))
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check if override values are set for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->misc_tspace_force) != ""
    AND trim(dcdur_user_data->temp_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->temp_tspace_force) != "")
    SET dpt_misc_ts_def = dcdur_user_data->misc_tspace_force
    SET dpt_temp_ts_def = dcdur_user_data->temp_tspace_force
    IF ((dm_err->debug_flag > 0))
     CALL echo("OVERRIDING VALUES FOR TEMP AND MISC TSPACE MAPPING")
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Set default values for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve MISC tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="MISC"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->misc_tspace_default = "MISC"
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->misc_tspace_default = dcdur_user_data->users[1].misc_tspace
    ENDIF
   ENDIF
   IF (trim(dcdur_user_data->temp_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="TEMP"
      AND dt.contents="TEMPORARY"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->temp_tspace_default = "TEMP"
    ELSE
     SET dm_err->eproc = "Retrieve temp tablespace contents from dba_tablespaces"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dba_tablespaces dt
      WHERE dt.contents="TEMPORARY"
      DETAIL
       dpt_cur_ts_tmp = dt.tablespace_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dcdur_user_data->temp_tspace_default = dpt_cur_ts_tmp
     ENDIF
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->temp_tspace_default = dcdur_user_data->users[1].temp_tspace
    ENDIF
   ENDIF
   SET dm_err->eproc = "Prompt user for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dpt_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"TABLESPACE MAPPING PROMPTS")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),";;Q"))
     IF (dpt_invalid_temp_ts=1
      AND dpt_invalid_misc_ts=1)
      CALL text(5,2,concat(
        "Both MISC and TEMP tablespace mappings provided could not be validated in dba_tablespaces.",
        " Please provide an alternate mappings."))
     ELSEIF (dpt_invalid_temp_ts=1)
      CALL text(5,2,concat(
        "TEMP tablespace provided is not a valid TEMPORARY tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSEIF (dpt_invalid_misc_ts=1)
      CALL text(5,2,concat("MISC tablespace provided is not a valid tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSE
      CALL clear(5,2,100)
     ENDIF
     SET dpt_invalid_temp_ts = 0
     SET dpt_invalid_misc_ts = 0
     CALL text(7,2,concat("MISC Tablespace for ",dpt_user_name,": "))
     CALL text(9,2,concat("TEMP Tablespace for ",dpt_user_name,": "))
     CALL accept(7,40,"P(30);CU",evaluate(dcdur_user_data->misc_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->misc_tspace_default)
      WHERE curaccept != " ")
     SET dpt_misc_ts_def = trim(curaccept)
     CALL accept(9,40,"P(30);CU",evaluate(dcdur_user_data->temp_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->temp_tspace_default)
      WHERE curaccept != " ")
     SET dpt_temp_ts_def = trim(curaccept)
     CALL text(12,2,"(C)ontinue, (M)odify, (Q)uit :")
     CALL accept(12,34,"p;cu","C"
      WHERE curaccept IN ("C", "M", "Q"))
     SET message = nowindow
     CASE (curaccept)
      OF "Q":
       SET dm_err->emsg = "User Quit Process"
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dpt_misc_ts_def = "DM2NOTSET"
       SET dpt_temp_ts_def = "DM2NOTSET"
       SET dpt_continue = 0
       RETURN(0)
      OF "C":
       IF ((((dpt_misc_ts_def != dcdur_user_data->misc_tspace_default)) OR ((dpt_temp_ts_def !=
       dcdur_user_data->temp_tspace_default))) )
        SET dm_err->eproc = "Verifying that MISC and TEMP tablspace mappings provided are valid"
        CALL disp_msg(" ",dm_err->logfile,0)
        SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_temp_ts_def
          AND dt.contents="TEMPORARY"
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_temp_ts = 1
        ENDIF
        SET dm_err->eproc = "Retrieve misc tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_misc_ts_def
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_misc_ts = 1
        ENDIF
        IF (dpt_invalid_misc_ts=0
         AND dpt_invalid_temp_ts=0)
         SET dpt_continue = 0
        ELSE
         SET dpt_continue = 1
        ENDIF
       ELSE
        SET dpt_continue = 0
       ENDIF
      OF "M":
       SET dpt_continue = 1
     ENDCASE
   ENDWHILE
   IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
    RETURN(0)
   ENDIF
   SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
   SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
   SET dpt_user_idx = dcdur_user_data->user_cnt
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_cleanup(dutc_user_name,dutc_db_name)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
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
    SET dm_err->eproc = concat("Cleanup tablespace mappings rows in dm2_admin_dm_info for user: ",
     dutc_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm2_admin_dm_info d
     WHERE d.info_domain=patstring(build("DM2_",cnvtupper(dutc_db_name),"_",cnvtupper(dutc_user_name),
       "_TSPACE_MAPPING"))
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_db_owner_pwds(dgdop_in_dbname)
   DECLARE dgdop_str = vc WITH protect, noconstant("")
   DECLARE dgdop_pwd_val = vc WITH protect, noconstant("")
   DECLARE dgdop_user_val = vc WITH protect, noconstant("")
   SET dm_err->eproc = 'Get "Rdbms User Name" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms User Name" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms User Name" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_user_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_user_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms User Name property for ",trim(dgdop_in_dbname
      ))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dgdop_user_val != "v500")
    SET dm_err->emsg = concat("Retrieved Rdbms User Name for DB ",trim(dgdop_in_dbname)," is ",
     dgdop_user_val," instead of v500")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = 'Get "Rdbms Password" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms Password" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_pwd_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_pwd_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms Password property for ",trim(dgdop_in_dbname)
     )
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
   SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "LOGIN"
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dgdop_user_val
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dgdop_pwd_val
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   RETURN(1)
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
 IF (validate(dm2_remote_rdbms_version->level1,- (1)) < 0)
  FREE RECORD dm2_remote_rdbms_version
  RECORD dm2_remote_rdbms_version(
    1 version = vc
    1 level1 = i2
    1 level2 = i2
    1 level3 = i2
    1 level4 = i2
    1 level5 = i2
  )
 ENDIF
 DECLARE dm2_get_remote_rdbms_version(dgrrv_db_link=vc) = i2
 SUBROUTINE dm2_get_remote_rdbms_version(dgrrv_db_link)
   DECLARE dgrrv_level = i2 WITH protect, noconstant(0)
   DECLARE dgrrv_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrrv_prev_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrrv_loop = i2 WITH protect, noconstant(0)
   DECLARE dgrrv_len = i2 WITH protect, noconstant(0)
   DECLARE dgrrv_rows_returned = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (value(concat("DBA_TAB_COLUMNS@",dgrrv_db_link)) t1)
    WHERE t1.table_name="PRODUCT_COMPONENT_VERSION"
     AND t1.column_name="VERSION_FULL"
     AND t1.owner="SYS"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgrrv_rows_returned = curqual
   SELECT
    IF (dgrrv_rows_returned=0)
     FROM (
      (
      (SELECT
       orcl_version = t1.version
       FROM (value(concat("PRODUCT_COMPONENT_VERSION@",dgrrv_db_link)) t1)
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC80")))
      t)
    ELSE
     FROM (
      (
      (SELECT
       orcl_version = t1.version_full
       FROM (value(concat("PRODUCT_COMPONENT_VERSION@",dgrrv_db_link)) t1)
       WHERE cnvtupper(t1.product)="ORACLE*"
       WITH sqltype("VC160")))
      t)
    ENDIF
    INTO "nl:"
    DETAIL
     dm2_remote_rdbms_version->version = t.orcl_version
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
   WHILE (dgrrv_loop=0)
     SET dgrrv_level = (dgrrv_level+ 1)
     SET dgrrv_prev_loc = dgrrv_loc
     SET dgrrv_loc = 0
     SET dgrrv_loc = findstring(".",dm2_remote_rdbms_version->version,(dgrrv_prev_loc+ 1),0)
     IF (((dgrrv_loc > 0) OR (dgrrv_loc=0
      AND dgrrv_level > 1)) )
      IF (dgrrv_loc=0
       AND dgrrv_level > 1)
       SET dgrrv_len = (textlen(dm2_remote_rdbms_version->version) - dgrrv_prev_loc)
       SET dgrrv_loop = 1
      ELSE
       SET dgrrv_len = ((dgrrv_loc - dgrrv_prev_loc) - 1)
      ENDIF
      CASE (dgrrv_level)
       OF 1:
        SET dm2_remote_rdbms_version->level1 = cnvtint(substring(1,dgrrv_len,dm2_remote_rdbms_version
          ->version))
       OF 2:
        SET dm2_remote_rdbms_version->level2 = cnvtint(substring((dgrrv_prev_loc+ 1),dgrrv_len,
          dm2_remote_rdbms_version->version))
       OF 3:
        SET dm2_remote_rdbms_version->level3 = cnvtint(substring((dgrrv_prev_loc+ 1),dgrrv_len,
          dm2_remote_rdbms_version->version))
       OF 4:
        SET dm2_remote_rdbms_version->level4 = cnvtint(substring((dgrrv_prev_loc+ 1),dgrrv_len,
          dm2_remote_rdbms_version->version))
       OF 5:
        SET dm2_remote_rdbms_version->level5 = cnvtint(substring((dgrrv_prev_loc+ 1),dgrrv_len,
          dm2_remote_rdbms_version->version))
       ELSE
        SET dgrrv_loop = 1
      ENDCASE
     ELSE
      IF (dgrrv_level=1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Product component version not in expected format."
       SET dm_err->eproc = "Getting product component version"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      SET dgrrv_loop = 1
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(dm2_remote_rdbms_version)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_adb_check(dac_db_link=vc,dac_adb_ind=i2(ref)) = i2
 SUBROUTINE dm2_adb_check(dac_db_link,dac_adb_ind)
   DECLARE dac_col_cnt = i4 WITH protect, noconstant(0)
   SET dac_adb_ind = 0
   SET dm_err->eproc = "Check if connected to database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (validate(currdbhandle,"")="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "currdbhandle is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if connected to autonomous database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     FROM (parser(concat("dba_tab_columns@",dac_db_link)) dtc)
    ELSE
     FROM dba_tab_columns dtc
    ENDIF
    INTO "nl:"
    dac_col_tmp_cnt = count(*)
    WHERE dtc.owner="SYS"
     AND dtc.table_name="V_$PDBS"
     AND dtc.column_name="CLOUD_IDENTITY"
    DETAIL
     dac_col_cnt = dac_col_tmp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dac_col_cnt > 0)
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM (parser(concat("V$PDBS@",dac_db_link)) x)
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM v$pdbs x
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE drcdu_mode = vc WITH protect, constant(cnvtupper( $1))
 DECLARE drcdu_user_list = vc WITH protect, noconstant("")
 DECLARE drcdu_iter = i4 WITH protect, noconstant(0)
 DECLARE drcdu_default_tspace = vc WITH protect, noconstant("")
 DECLARE drcdu_temp_tspace = vc WITH protect, noconstant("")
 DECLARE drcdu_connect_back = i2 WITH protect, noconstant(0)
 DECLARE drcdu_standalone = i2 WITH protect, noconstant(0)
 DECLARE drcdu_connect_str = vc WITH protect, noconstant(" ")
 DECLARE drcdu_idx = i4 WITH protect, noconstant(0)
 DECLARE drcdu_ccl_ver = i4 WITH protect, constant((((cnvtint(currev) * 10000)+ (cnvtint(currevminor)
   * 100))+ cnvtint(currevminor2)))
 DECLARE drcdu_dblink_fnd_ind = i2 WITH protect, noconstant(0)
 DECLARE drcdu_adb_ind = i2 WITH protect, noconstant(0)
 FREE RECORD drcdu_exception_list
 RECORD drcdu_exception_list(
   1 cnt = i4
   1 qual[*]
     2 owner = vc
 )
 IF ((dm2_install_schema->curprog="NONE"))
  SET drcdu_standalone = 1
 ENDIF
 IF (check_logfile("dm2_repcredbusers",".log","dm2_repl_create_db_users")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm2_repl_create_db_users"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (validate(dm2_bypass_db_user_creation,- (1))=1)
  SET dm_err->eproc = "User elected to bypass databse user creation process."
  CALL disp_msg("",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 IF (drcdu_ccl_ver < 80205)
  SET dm_err->eproc = "CCL version does not support functionality.  Exiting process."
  CALL disp_msg("",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 IF ( NOT (drcdu_mode IN ("CREATE", "REPORT", "CREATE_REPORT")))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Input mode is invalid, may only be CREATE, REPORT or CREATE_REPORT."
  SET dm_err->eproc = "Input Mode Validation"
  SET dm_err->user_action = "Please enter valid mode."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (validate(drrr_responsefile_in_use,0)=1)
  SET dcdur_user_data->tgt_sys_pwd = drrr_rf_data->tgt_sys_pwd
 ENDIF
 IF ((((dm2_install_schema->src_v500_p_word="NONE")) OR ((((dm2_install_schema->src_v500_connect_str=
 "NONE")) OR ((((dm2_install_schema->v500_p_word="NONE")) OR ((dm2_install_schema->v500_connect_str=
 "NONE"))) )) ))
  AND drcdu_standalone=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Source and Target connection information not established."
  SET dm_err->eproc = "Validating Source and Target Connection Information"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (drcdu_standalone=1)
  SET dm2_install_schema->dbase_name = '"SOURCE"'
  SET dm2_install_schema->u_name = "V500"
  SET dm2_force_connect_string = 1
  SET dm_err->eproc = "Prompting for SOURCE connection."
  CALL disp_msg("",dm_err->logfile,0)
  SET drcdu_connect_back = 1
  EXECUTE dm2_connect_to_dbase "PC"
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  SET dm2_force_connect_string = 0
  SET dm2_install_schema->src_dbase_name = '"SOURCE"'
  SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
  SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
  SET dm2_install_schema->dbase_name = '"TARGET"'
  SET dm2_install_schema->u_name = "V500"
  SET dm2_force_connect_string = 1
  SET dm_err->eproc = "Prompting for TARGET connection."
  CALL disp_msg("",dm_err->logfile,0)
  EXECUTE dm2_connect_to_dbase "PC"
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  SET drcdu_connect_back = 0
  SET dm2_force_connect_string = 0
  SET dm2_install_schema->dbase_name = '"TARGET"'
  SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
  SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
 ENDIF
 IF ((dcdur_user_data->tgt_sys_pwd="DM2NOTSET")
  AND drcdu_mode != "REPORT")
  SET dm2_install_schema->dbase_name = '"TARGET"'
  SET dm2_install_schema->u_name = "SYS"
  SET dm2_force_connect_string = 1
  SET dm_err->eproc = "Prompting for TARGET connection."
  CALL disp_msg("",dm_err->logfile,0)
  SET drcdu_connect_back = 1
  EXECUTE dm2_connect_to_dbase "PC"
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  SET dm2_force_connect_string = 0
  SET dm2_install_schema->dbase_name = '"TARGET"'
  SET dcdur_user_data->tgt_sys_pwd = dm2_install_schema->p_word
  SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
 ENDIF
 SET dm2_force_connect_string = 1
 SET dm2_install_schema->dbase_name = '"TARGET"'
 SET dm2_install_schema->u_name = "V500"
 SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
 SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
 EXECUTE dm2_connect_to_dbase "CO"
 SET dm2_force_connect_string = 0
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
 SET drcdu_connect_back = 0
 IF (dm2_adb_check("",drcdu_adb_ind)=0)
  GO TO exit_program
 ENDIF
 IF (drcdu_adb_ind=1)
  SET dm_err->eproc =
  "Creation of custom schemas on Target autonomous database not currently supported."
  CALL disp_msg("",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 IF (drr_check_db_link("REF_DATA_LINK",drcdu_dblink_fnd_ind)=0)
  GO TO exit_program
 ENDIF
 IF (drcdu_dblink_fnd_ind=0)
  SET dm_err->eproc = "Determining if REF_DATA_LINK link for Source exists in Target"
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "REF_DATA_LINK not found in Target."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Selecting list of exception users from  Source dm_info."
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info@ref_data_link di
  WHERE "DM2_REPLICATE_EXCLUDE_USER"=di.info_domain
  HEAD REPORT
   drcdu_exception_list->cnt = 0, stat = alterlist(drcdu_exception_list->qual,0)
  DETAIL
   drcdu_exception_list->cnt = (drcdu_exception_list->cnt+ 1), stat = alterlist(drcdu_exception_list
    ->qual,drcdu_exception_list->cnt), drcdu_exception_list->qual[drcdu_exception_list->cnt].owner =
   di.info_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_get_remote_rdbms_version("ref_data_link")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Retrieve list of custom database users from Source."
 CALL disp_msg("",dm_err->logfile,0)
 SELECT
  IF ((dm2_remote_rdbms_version->level1 >= 12))
   FROM dba_users@ref_data_link du
   WHERE  NOT (du.username IN ("CDBA", "V500", "V500_READ", "V500_EVENT", "V500_REF"))
    AND  NOT (du.username IN (
   (SELECT
    di.info_name
    FROM dm_info@ref_data_link di
    WHERE di.info_domain="DM2_ORACLE_USER"
     AND di.info_number=1)))
    AND du.oracle_maintained="N"
    AND du.common="NO"
  ELSE
   FROM dba_users@ref_data_link du
   WHERE  NOT (du.username IN ("CDBA", "V500", "V500_READ", "V500_EVENT", "V500_REF"))
    AND  NOT (du.username IN (
   (SELECT
    di.info_name
    FROM dm_info@ref_data_link di
    WHERE di.info_domain="DM2_ORACLE_USER"
     AND di.info_number=1)))
  ENDIF
  INTO "nl:"
  ORDER BY du.username
  HEAD REPORT
   drcdu_user_list = ""
  DETAIL
   drcdu_idx = 0, drcdu_idx = locateval(drcdu_idx,1,drcdu_exception_list->cnt,du.username,
    drcdu_exception_list->qual[drcdu_idx].owner)
   IF (drcdu_idx=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Including custom user ",du.username))
    ENDIF
    IF (drcdu_user_list="")
     drcdu_user_list = build("'",du.username,"',")
    ELSE
     drcdu_user_list = build(drcdu_user_list,"'",du.username,"',")
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Excluding custom user ",du.username))
    ENDIF
   ENDIF
  FOOT REPORT
   drcdu_user_list = replace(drcdu_user_list,",","",2)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(drcdu_exception_list)
  CALL echo(concat("User List = ",drcdu_user_list))
 ENDIF
 IF (drcdu_user_list="")
  SET dm_err->eproc = "No Source custom database users to create in Target, exiting script."
  CALL disp_msg("",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Retrieve default and temporary tablespace for Target V500 database user."
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dba_users du
  WHERE du.username="V500"
  DETAIL
   drcdu_default_tspace = du.default_tablespace, drcdu_temp_tspace = du.temporary_tablespace
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "V500 database user does not exist."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dcdur_input->user_list = drcdu_user_list
 SET dcdur_input->src_user = "V500"
 SET dcdur_input->src_pwd = dm2_install_schema->src_v500_p_word
 SET dcdur_input->src_cnct_str = dm2_install_schema->src_v500_connect_str
 SET dcdur_input->tgt_user = "SYS"
 SET dcdur_input->tgt_pwd = dcdur_user_data->tgt_sys_pwd
 SET dcdur_input->tgt_cnct_str = dm2_install_schema->v500_connect_str
 SET dcdur_input->tgt_dbname = ""
 SET dcdur_input->fix_tspaces_ind = "Y"
 SET dcdur_input->default_tspace = drcdu_default_tspace
 SET dcdur_input->temp_tspace = drcdu_temp_tspace
 SET dcdur_input->replace_tspaces = "N"
 SET dcdur_input->replace_pwds = "N"
 IF (drcdu_mode IN ("CREATE", "CREATE_REPORT"))
  IF (dcdur_create_db_users(null)=0)
   IF ((dcdur_input->connect_back="Y"))
    SET drcdu_connect_back = 1
   ENDIF
   GO TO exit_program
  ENDIF
  SET dm2_force_connect_string = 1
  SET dm2_install_schema->dbase_name = '"TARGET"'
  SET dm2_install_schema->u_name = "V500"
  SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
  SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
  EXECUTE dm2_connect_to_dbase "CO"
  SET dm2_force_connect_string = 0
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  SET drcdu_connect_back = 0
 ENDIF
 IF (drcdu_mode IN ("REPORT", "CREATE_REPORT"))
  IF (dcdur_report_db_users_diff_tspaces(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 GO TO exit_program
#exit_program
 IF (drcdu_connect_back=1
  AND (dm_err->err_ind=1))
  CALL parser("free define oraclesystem go",1)
  IF ((dm2_install_schema->v500_p_word != "NONE"))
   SET drcdu_connect_str = build("V500/",dm2_install_schema->v500_p_word,"@",dm2_install_schema->
    v500_connect_str)
   CALL parser(concat("define oraclesystem '",trim(drcdu_connect_str),"' go"),1)
  ELSE
   CALL echo("*")
   CALL echo("**************************************************************************")
   CALL echo("* DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION. *")
   CALL echo("**************************************************************************")
   CALL echo("*")
  ENDIF
 ENDIF
 SET dm_err->eproc = "Ending dm2_repl_create_db_users"
 CALL final_disp_msg("dm2_repcredbusers")
END GO
