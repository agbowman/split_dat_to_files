CREATE PROGRAM dm_rmc_dcl_issues:dba
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
 DECLARE drdc_wrap_menu_lines(dwml_str=vc,dwml_cur_row_pos=i4,dwml_cur_col_pos=i4,
  dwml_multi_line_buffer=vc,dwml_max_lines=i4,
  dwml_max_col=i4) = i4
 DECLARE drdc_get_name(dgn_name=vc,dgn_file=vc) = vc
 DECLARE drdc_file_success(dfs_name=vc,dfs_file_name=vc,dfs_error_ind=i2) = null
 IF ((validate(dclm_rs->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_rs
  RECORD dclm_rs(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_tier = i4
    1 del_row_ind = i2
    1 max_tier = i4
    1 num_procs = i4
    1 nomv_ind = i2
    1 mover_stale_ind = i2
    1 cycle_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 ctp_str = vc
    1 cts_str = vc
    1 group_ind = i2
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 reporting_cnt = i4
    1 reporting_qual[*]
      2 log_type = vc
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 non_ctxt_cnt = i4
    1 non_ctxt_qual[*]
      2 values = vc
  )
 ENDIF
 IF ((validate(dclm_all->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_all
  RECORD dclm_all(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 type_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 lt_cnt = i4
  )
 ENDIF
 IF ((validate(dclm_issues->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_issues
  RECORD dclm_issues(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 max_lines = i4
    1 cur_rs_pos = i4
    1 ctp_str = vc
    1 sort_flag = i4
    1 cur_flag = i4
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 lt_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 inv_ind = i2
      2 log_msg = vc
      2 child_type = vc
      2 log_type_sum = i4
      2 child_cnt_sum = i4
      2 tab_cnt = i4
      2 tab_qual[*]
        3 table_name = vc
        3 row_cnt = i4
  )
 ENDIF
 SUBROUTINE drdc_wrap_menu_lines(dwml_str,dwml_cur_row_pos,dwml_cur_col_pos,dwml_multi_line_buffer,
  dwml_max_lines,dwml_max_col)
   DECLARE dwml_temp_str = vc WITH protect, noconstant("")
   DECLARE dwml_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dwml_partial_str = vc WITH protect, noconstant("")
   DECLARE dwml_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dwml_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dwml_max_val = i4 WITH protect, noconstant(0)
   SET dwml_max_val = dwml_max_col
   IF (dwml_max_val=0)
    SET dwml_max_val = 132
   ENDIF
   SET dwml_temp_str = dwml_str
   SET dwml_done_ind = 0
   WHILE (dwml_done_ind=0)
     IF (size(dwml_temp_str) < dwml_max_val)
      SET dwml_partial_str = dwml_temp_str
      SET dwml_done_ind = 1
     ELSE
      SET dwml_partial_str = substring(1,value(dwml_max_val),dwml_temp_str)
      SET dwml_stop_pos = findstring(" ",dwml_partial_str,1,1)
      IF (dwml_stop_pos=0)
       SET dwml_stop_pos = dwml_max_val
      ENDIF
      SET dwml_partial_str = substring(1,dwml_stop_pos,dwml_temp_str)
      IF (dwml_multi_line_buffer >= " ")
       SET dwml_temp_str = concat(dwml_multi_line_buffer,substring((dwml_stop_pos+ 1),(size(
          dwml_temp_str) - dwml_stop_pos),dwml_temp_str))
      ELSE
       SET dwml_temp_str = substring((dwml_stop_pos+ 1),(size(dwml_temp_str) - dwml_stop_pos),
        dwml_temp_str)
      ENDIF
     ENDIF
     IF (((dwml_line_cnt+ 1)=dwml_max_lines)
      AND dwml_done_ind=0
      AND dwml_max_lines > 0)
      SET dwml_partial_str = concat(substring(1,(dwml_max_val - 3),dwml_partial_str),"...")
      SET dwml_done_ind = 1
     ENDIF
     CALL text(dwml_cur_row_pos,dwml_cur_col_pos,dwml_partial_str)
     SET dwml_cur_row_pos = (dwml_cur_row_pos+ 1)
     SET dwml_line_cnt = (dwml_line_cnt+ 1)
   ENDWHILE
   RETURN(dwml_cur_row_pos)
 END ;Subroutine
 SUBROUTINE drdc_get_name(dgn_name,dgn_file)
   SET dm_err->eproc = "Getting report file name"
   DECLARE dgn_file_name = vc WITH protect, noconstant("")
   DECLARE dgn_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgn_title = vc WITH protect, noconstant("")
   SET dgn_title = concat("*** ",dgn_name," ***")
   WHILE (dgn_done_ind=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgn_title)/ 2))),dgn_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgn_name,
       " report to extract into. (0 to exit): "))
     CALL accept(7,15,"P(30);CU",value(dgn_file))
     SET dgn_file_name = curaccept
     SET dgn_file_name = cnvtlower(dgn_file_name)
     IF (dgn_file_name="0")
      RETURN("-1")
      CALL text(20,3,"No extract will be made")
      CALL pause(3)
      SET dgn_done_ind = 1
     ENDIF
     IF (findstring(".",dgn_file_name)=0)
      SET dgn_file_name = concat(dgn_file_name,".csv")
      SET dgn_done_ind = 1
     ENDIF
     IF (substring(findstring(".",dgn_file_name),size(dgn_file_name,1),dgn_file_name) != ".csv")
      CALL text(20,3,"Invalid file type, file extension must be .csv")
      CALL pause(3)
     ELSE
      SET dgn_done_ind = 1
     ENDIF
   ENDWHILE
   RETURN(dgn_file_name)
 END ;Subroutine
 SUBROUTINE drdc_file_success(dfs_name,dfs_file_name,dfs_error_ind)
   DECLARE dfs_title = vc WITH protect, noconstant("")
   DECLARE dfs_pos = i4 WITH protect, noconstant(0)
   SET dfs_title = concat("*** ",dfs_name," ***")
   IF (dfs_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report complete!")
    CALL text(7,3,
     "For optimal viewing, the following file needs to be moved from CCLUSERDIR to a PC:")
    CALL text(8,3,"-----------------------------")
    CALL text(9,3,dfs_file_name)
    CALL text(10,3,"-----------------------------")
    CALL text(12,3,"Press enter to return:")
    CALL accept(12,26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report was not successful.  The following error occurred!")
    SET dfs_pos = drdc_wrap_menu_lines(dm_err->emsg,7,3,"   ",0,
     120)
    CALL text((dfs_pos+ 1),3,"Press enter to return:")
    CALL accept((dfs_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
 IF ((validate(dclmi_menu_ind,- (1))=- (1)))
  DECLARE dclmi_menu_ind = i2 WITH protect, noconstant(1)
 ENDIF
 DECLARE dcli_file_name = vc WITH protect, noconstant("")
 DECLARE dcli_accept = vc WITH protect, noconstant("")
 DECLARE dcli_refresh_screen(rs_rec=vc(ref)) = null
 DECLARE dcli_sort_screen(ss_rec=vc(ref),ss_rec_pos=i4) = null
 DECLARE dcli_print_screen(ps_file_name=vc,ps_rec=vc(ref)) = i2
 DECLARE dcli_refresh_details(rd_rec=vc(ref),rd_rec_pos=i4) = null
 DECLARE dcli_manage_details(md_rec=vc(ref),md_rec_pos=i4) = null
 DECLARE dcli_print_details(pd_file_name=vc,pd_rec=vc(ref),pd_pos=vc) = i2
 DECLARE dcli_show_help(dsi_rec=vc(ref)) = null
 DECLARE dcli_show_help_tab(dst_rec=vc(ref),dst_rec_pos=i4) = null
 SET dm_err->eproc = "Starting dm_rmc_dcl_issues"
 IF (check_logfile("dm_rmc_dcl_issues",".log","dm_rmc_dcl_issues LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_all
 ENDIF
 SET message = window
 CALL clear(1,1)
 SET width = 132
 CALL text(1,54,"RDDS Change Log Issues")
 CALL text(2,1,"Env: ")
 CALL text(2,30,"Source:")
 CALL text(2,81,"Open Event:")
 CALL text(3,1,"Current sort order:")
 CALL text(4,1,"Contexts being merged:")
 CALL text(5,1,fillstring(132,"-"))
 CALL video(b)
 CALL text(10,56,"Generating Report (may take a few minutes)...")
 SET dclm_issues->max_lines = 15
 EXECUTE dm_rmc_dcl_issues_child
 IF ((dm_err->err_ind=1))
  GO TO exit_all
 ENDIF
 CALL dcli_sort_screen(dclm_issues,0)
 WHILE (true)
   CALL video(n)
   SET accept = scroll
   CALL dcli_refresh_screen(dclm_issues)
   CALL accept(24,18,"XX;CUS","E")
   CASE (curscroll)
    OF 0:
     SET dcli_accept = curaccept
     IF (dcli_accept="E")
      GO TO exit_all
     ELSEIF (dcli_accept="H")
      SET accept = notime
      SET accept = noscroll
      CALL dcli_show_help(dclm_issues)
      SET accept = time(30)
      SET accept = scroll
     ELSEIF (dcli_accept="S")
      SET dcli_file_name = drdc_get_name("RDDS Change Log Issues","ISSUES_REPORT.CSV")
      IF (dcli_file_name != "-1")
       IF (dcli_print_screen(dcli_file_name,dclm_issues)=1)
        CALL drdc_file_success("RDDS Change Log Issues",dcli_file_name,1)
       ELSE
        CALL drdc_file_success("RDDS Change Log Issues",dcli_file_name,0)
       ENDIF
      ENDIF
     ELSEIF (dcli_accept="L")
      SET dclm_issues->sort_flag = 1
      CALL dcli_sort_screen(dclm_issues,0)
     ELSEIF (dcli_accept="I")
      SET dclm_issues->sort_flag = 0
      CALL dcli_sort_screen(dclm_issues,0)
     ELSEIF (dcli_accept="C")
      SET dclm_issues->sort_flag = 2
      CALL dcli_sort_screen(dclm_issues,0)
     ELSEIF (isnumeric(dcli_accept)=1)
      IF (((dclm_issues->max_lines+ dclm_issues->cur_rs_pos) <= dclm_issues->lt_cnt))
       IF ((cnvtint(dcli_accept) >= (dclm_issues->cur_rs_pos+ 1))
        AND (cnvtint(dcli_accept) <= (dclm_issues->max_lines+ dclm_issues->cur_rs_pos)))
        CALL dcli_manage_details(dclm_issues,cnvtint(dcli_accept))
       ELSE
        CALL text(24,1,fillstring(132," "))
        CALL text(24,1,"Invalid Entry, Try again.")
        CALL pause(3)
       ENDIF
      ELSE
       IF ((cnvtint(dcli_accept) >= (dclm_issues->cur_rs_pos+ 1))
        AND (cnvtint(dcli_accept) <= dclm_issues->lt_cnt))
        CALL dcli_manage_details(dclm_issues,cnvtint(dcli_accept))
       ELSE
        CALL text(24,1,fillstring(132," "))
        CALL text(24,1,"Invalid Entry, Try again.")
        CALL pause(3)
       ENDIF
      ENDIF
     ELSE
      CALL text(24,1,fillstring(132," "))
      CALL text(24,1,"Invalid Entry, Try again.")
      CALL pause(3)
     ENDIF
    OF 1:
    OF 6:
     IF (((dclm_issues->cur_rs_pos+ dclm_issues->max_lines) < dclm_issues->lt_cnt))
      SET dclm_issues->cur_rs_pos = (dclm_issues->cur_rs_pos+ dclm_issues->max_lines)
     ENDIF
    OF 2:
    OF 5:
     SET dclm_issues->cur_rs_pos = greatest((dclm_issues->cur_rs_pos - dclm_issues->max_lines),0)
   ENDCASE
 ENDWHILE
 SUBROUTINE dcli_refresh_screen(rs_rec)
   DECLARE rs_start = i4 WITH protect, noconstant(4)
   DECLARE rs_done_ind = i2 WITH protect, noconstant(0)
   DECLARE rs_temp_str = vc WITH protect, noconstant("")
   DECLARE rs_partial_str = vc WITH protect, noconstant("")
   DECLARE rs_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE rs_pos = i4 WITH protect, noconstant(0)
   DECLARE rs_loop = i4 WITH protect, noconstant(0)
   DECLARE rs_cnt = i4 WITH protect, noconstant(0)
   DECLARE rs_sort_string = vc WITH protect, noconstant("")
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL text(1,54,"RDDS Change Log Issues")
   CALL text(2,1,concat("Env: ",rs_rec->cur_name))
   CALL text(2,30,concat("Source: ",rs_rec->src_name))
   CALL text(2,(132 - size(concat("Open Event: ",rs_rec->oe_name))),concat("Open Event: ",rs_rec->
     oe_name))
   IF ((rs_rec->sort_flag=0))
    SET rs_sort_string = "Investigate order"
   ELSEIF ((rs_rec->sort_flag=1))
    SET rs_sort_string = "Alphabetical order"
   ELSEIF ((rs_rec->sort_flag=2))
    SET rs_sort_string = "Numeric descending order"
   ENDIF
   CALL text(3,1,concat("Current sort order: ",rs_sort_string))
   CALL text(4,1,"Contexts being merged:")
   SET rs_temp_str = replace(rs_rec->ctp_str,"::",", ",0)
   SET rs_start = drdc_wrap_menu_lines(rs_temp_str,4,24,"",2,
    109)
   CALL text(rs_start,1,fillstring(132,"-"))
   IF ((rs_rec->cur_rs_pos > 1))
    CALL text(rs_start,85," More data up... ")
   ENDIF
   SET rs_start = (rs_start+ 1)
   IF ((rs_rec->lt_cnt > 0))
    CALL text(rs_start,1,"No.")
    CALL text(rs_start,5,"LOG_TYPE")
    CALL text(rs_start,14,"COUNT")
    CALL text(rs_start,23,"CHILD")
    CALL text(rs_start,32,"INV")
    CALL text(rs_start,36,"DESCRIPTION")
    SET rs_rec->max_lines = (22 - rs_start)
    FOR (rs_stop_pos = 1 TO rs_rec->max_lines)
      IF (((rs_stop_pos+ rs_rec->cur_rs_pos) <= rs_rec->lt_cnt))
       CALL text((rs_stop_pos+ rs_start),1,trim(cnvtstring((rs_stop_pos+ rs_rec->cur_rs_pos))))
       CALL text((rs_stop_pos+ rs_start),5,rs_rec->lt_qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].
        log_type)
       CALL text((rs_stop_pos+ rs_start),14,build(rs_rec->lt_qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].
         log_type_sum))
       CALL text((rs_stop_pos+ rs_start),23,build(rs_rec->lt_qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].
         child_cnt_sum))
       IF ((rs_rec->lt_qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].inv_ind=1))
        CALL text((rs_stop_pos+ rs_start),33,"Y")
       ELSE
        CALL text((rs_stop_pos+ rs_start),33,"N")
       ENDIF
       IF (size(rs_rec->lt_qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].log_msg) > 97)
        CALL text((rs_stop_pos+ rs_start),36,concat(substring(1,94,rs_rec->lt_qual[(rs_stop_pos+
           rs_rec->cur_rs_pos)].log_msg),"..."))
       ELSE
        CALL text((rs_stop_pos+ rs_start),36,rs_rec->lt_qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].
         log_msg)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    CALL text(15,3,
     "There are no rows in a NOMV*, HOLDNG, or ORPHAN state in the DM_CHG_LOG for the target environment."
     )
   ENDIF
   SET rs_temp_str = concat(fillstring(value(((132 - size(rs_rec->refresh_time))/ 2)),"-"),rs_rec->
    refresh_time,fillstring(value(((132 - size(rs_rec->refresh_time))/ 2)),"-"))
   CALL text(23,1,rs_temp_str)
   IF (((rs_rec->max_lines+ rs_rec->cur_rs_pos) < rs_rec->lt_cnt))
    CALL text(23,85," More data down... ")
   ENDIF
   IF (((rs_rec->max_lines+ rs_rec->cur_rs_pos) <= rs_rec->lt_cnt))
    CALL text(24,1,concat("Command Options: __ (",trim(cnvtstring((rs_rec->cur_rs_pos+ 1)))," - ",
      trim(cnvtstring((rs_rec->cur_rs_pos+ rs_rec->max_lines))),
      " for table detail), (H)elp, (E)xit, (S)ave to CSV, ",
      "Sort (L)og Type or (I)nvestigate or (C)ount"))
   ELSE
    CALL text(24,1,concat("Command Options: __ (",trim(cnvtstring((rs_rec->cur_rs_pos+ 1)))," - ",
      trim(cnvtstring(rs_rec->lt_cnt)),
      " for table detail), (H)elp, (E)xit, (S)ave to CSV, Sort (L)og Type or ",
      "(I)nvestigate or (C)ount"))
   ENDIF
 END ;Subroutine
 SUBROUTINE dcli_sort_screen(ss_rec,ss_rec_pos)
   DECLARE ss_loop = i4 WITH protect, noconstant(0)
   DECLARE ss_loop1 = i4 WITH protect, noconstant(0)
   DECLARE ss_loop2 = i4 WITH protect, noconstant(0)
   IF ((ss_rec->sort_flag=0)
    AND (ss_rec->lt_cnt > 1)
    AND (ss_rec->cur_flag != 0))
    SET ss_rec->cur_flag = 0
    SET stat = alterlist(ss_rec->lt_qual,(ss_rec->lt_cnt+ 1))
    FOR (ss_loop1 = 1 TO (ss_rec->lt_cnt - 1))
      FOR (ss_loop2 = 1 TO (ss_rec->lt_cnt - 1))
        IF ((((ss_rec->lt_qual[ss_loop2].inv_ind < ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind)) OR ((
        ss_rec->lt_qual[ss_loop2].inv_ind=ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind)
         AND (ss_rec->lt_qual[ss_loop2].log_type > ss_rec->lt_qual[(ss_loop2+ 1)].log_type))) )
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].inv_ind = ss_rec->lt_qual[ss_loop2].inv_ind
         SET ss_rec->lt_qual[ss_loop2].inv_ind = ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind
         SET ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].inv_ind
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type = ss_rec->lt_qual[ss_loop2].log_type
         SET ss_rec->lt_qual[ss_loop2].log_type = ss_rec->lt_qual[(ss_loop2+ 1)].log_type
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_type = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_msg = ss_rec->lt_qual[ss_loop2].log_msg
         SET ss_rec->lt_qual[ss_loop2].log_msg = ss_rec->lt_qual[(ss_loop2+ 1)].log_msg
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_msg = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_msg
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].child_type = ss_rec->lt_qual[ss_loop2].child_type
         SET ss_rec->lt_qual[ss_loop2].child_type = ss_rec->lt_qual[(ss_loop2+ 1)].child_type
         SET ss_rec->lt_qual[(ss_loop2+ 1)].child_type = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         child_type
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type_sum = ss_rec->lt_qual[ss_loop2].
         log_type_sum
         SET ss_rec->lt_qual[ss_loop2].log_type_sum = ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         log_type_sum
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].child_cnt_sum = ss_rec->lt_qual[ss_loop2].
         child_cnt_sum
         SET ss_rec->lt_qual[ss_loop2].child_cnt_sum = ss_rec->lt_qual[(ss_loop2+ 1)].child_cnt_sum
         SET ss_rec->lt_qual[(ss_loop2+ 1)].child_cnt_sum = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         child_cnt_sum
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt = ss_rec->lt_qual[ss_loop2].tab_cnt
         SET ss_rec->lt_qual[ss_loop2].tab_cnt = ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt
         SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt
         SET stat = alterlist(ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual,ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt)
          SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual[ss_loop].table_name = ss_rec->lt_qual[
          ss_loop2].tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[
          ss_loop2].tab_qual[ss_loop].row_cnt
         ENDFOR
         SET stat = alterlist(ss_rec->lt_qual[ss_loop2].tab_qual,ss_rec->lt_qual[ss_loop2].tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[ss_loop2].tab_cnt)
          SET ss_rec->lt_qual[ss_loop2].tab_qual[ss_loop].table_name = ss_rec->lt_qual[(ss_loop2+ 1)]
          .tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[ss_loop2].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[(ss_loop2+ 1)].
          tab_qual[ss_loop].row_cnt
         ENDFOR
         SET stat = alterlist(ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual,ss_rec->lt_qual[(ss_loop2+ 1)].
          tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt)
          SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual[ss_loop].table_name = ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_qual[ss_loop].row_cnt
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((ss_rec->sort_flag=2)
    AND (ss_rec->lt_cnt > 1)
    AND (ss_rec->cur_flag != 2))
    SET ss_rec->cur_flag = 2
    SET stat = alterlist(ss_rec->lt_qual,(ss_rec->lt_cnt+ 1))
    FOR (ss_loop1 = 1 TO (ss_rec->lt_cnt - 1))
      FOR (ss_loop2 = 1 TO (ss_rec->lt_cnt - 1))
        IF ((((ss_rec->lt_qual[ss_loop2].log_type_sum < ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum))
         OR ((ss_rec->lt_qual[ss_loop2].log_type_sum=ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum)
         AND (ss_rec->lt_qual[ss_loop2].log_type > ss_rec->lt_qual[(ss_loop2+ 1)].log_type))) )
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].inv_ind = ss_rec->lt_qual[ss_loop2].inv_ind
         SET ss_rec->lt_qual[ss_loop2].inv_ind = ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind
         SET ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].inv_ind
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type = ss_rec->lt_qual[ss_loop2].log_type
         SET ss_rec->lt_qual[ss_loop2].log_type = ss_rec->lt_qual[(ss_loop2+ 1)].log_type
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_type = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_msg = ss_rec->lt_qual[ss_loop2].log_msg
         SET ss_rec->lt_qual[ss_loop2].log_msg = ss_rec->lt_qual[(ss_loop2+ 1)].log_msg
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_msg = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_msg
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].child_type = ss_rec->lt_qual[ss_loop2].child_type
         SET ss_rec->lt_qual[ss_loop2].child_type = ss_rec->lt_qual[(ss_loop2+ 1)].child_type
         SET ss_rec->lt_qual[(ss_loop2+ 1)].child_type = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         child_type
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type_sum = ss_rec->lt_qual[ss_loop2].
         log_type_sum
         SET ss_rec->lt_qual[ss_loop2].log_type_sum = ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         log_type_sum
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].child_cnt_sum = ss_rec->lt_qual[ss_loop2].
         child_cnt_sum
         SET ss_rec->lt_qual[ss_loop2].child_cnt_sum = ss_rec->lt_qual[(ss_loop2+ 1)].child_cnt_sum
         SET ss_rec->lt_qual[(ss_loop2+ 1)].child_cnt_sum = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         child_cnt_sum
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt = ss_rec->lt_qual[ss_loop2].tab_cnt
         SET ss_rec->lt_qual[ss_loop2].tab_cnt = ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt
         SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt
         SET stat = alterlist(ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual,ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt)
          SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual[ss_loop].table_name = ss_rec->lt_qual[
          ss_loop2].tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[
          ss_loop2].tab_qual[ss_loop].row_cnt
         ENDFOR
         SET stat = alterlist(ss_rec->lt_qual[ss_loop2].tab_qual,ss_rec->lt_qual[ss_loop2].tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[ss_loop2].tab_cnt)
          SET ss_rec->lt_qual[ss_loop2].tab_qual[ss_loop].table_name = ss_rec->lt_qual[(ss_loop2+ 1)]
          .tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[ss_loop2].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[(ss_loop2+ 1)].
          tab_qual[ss_loop].row_cnt
         ENDFOR
         SET stat = alterlist(ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual,ss_rec->lt_qual[(ss_loop2+ 1)].
          tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt)
          SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual[ss_loop].table_name = ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_qual[ss_loop].row_cnt
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((ss_rec->sort_flag=1)
    AND (ss_rec->lt_cnt > 1)
    AND (ss_rec->cur_flag != 1))
    SET ss_rec->cur_flag = 1
    SET stat = alterlist(ss_rec->lt_qual,(ss_rec->lt_cnt+ 1))
    FOR (ss_loop1 = 1 TO (ss_rec->lt_cnt - 1))
      FOR (ss_loop2 = 1 TO (ss_rec->lt_cnt - 1))
        IF ((ss_rec->lt_qual[ss_loop2].log_type > ss_rec->lt_qual[(ss_loop2+ 1)].log_type))
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].inv_ind = ss_rec->lt_qual[ss_loop2].inv_ind
         SET ss_rec->lt_qual[ss_loop2].inv_ind = ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind
         SET ss_rec->lt_qual[(ss_loop2+ 1)].inv_ind = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].inv_ind
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type = ss_rec->lt_qual[ss_loop2].log_type
         SET ss_rec->lt_qual[ss_loop2].log_type = ss_rec->lt_qual[(ss_loop2+ 1)].log_type
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_type = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_msg = ss_rec->lt_qual[ss_loop2].log_msg
         SET ss_rec->lt_qual[ss_loop2].log_msg = ss_rec->lt_qual[(ss_loop2+ 1)].log_msg
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_msg = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_msg
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].child_type = ss_rec->lt_qual[ss_loop2].child_type
         SET ss_rec->lt_qual[ss_loop2].child_type = ss_rec->lt_qual[(ss_loop2+ 1)].child_type
         SET ss_rec->lt_qual[(ss_loop2+ 1)].child_type = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         child_type
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].log_type_sum = ss_rec->lt_qual[ss_loop2].
         log_type_sum
         SET ss_rec->lt_qual[ss_loop2].log_type_sum = ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum
         SET ss_rec->lt_qual[(ss_loop2+ 1)].log_type_sum = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         log_type_sum
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].child_cnt_sum = ss_rec->lt_qual[ss_loop2].
         child_cnt_sum
         SET ss_rec->lt_qual[ss_loop2].child_cnt_sum = ss_rec->lt_qual[(ss_loop2+ 1)].child_cnt_sum
         SET ss_rec->lt_qual[(ss_loop2+ 1)].child_cnt_sum = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].
         child_cnt_sum
         SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt = ss_rec->lt_qual[ss_loop2].tab_cnt
         SET ss_rec->lt_qual[ss_loop2].tab_cnt = ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt
         SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt = ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt
         SET stat = alterlist(ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual,ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_cnt)
          SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual[ss_loop].table_name = ss_rec->lt_qual[
          ss_loop2].tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[(ss_rec->lt_cnt+ 1)].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[
          ss_loop2].tab_qual[ss_loop].row_cnt
         ENDFOR
         SET stat = alterlist(ss_rec->lt_qual[ss_loop2].tab_qual,ss_rec->lt_qual[ss_loop2].tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[ss_loop2].tab_cnt)
          SET ss_rec->lt_qual[ss_loop2].tab_qual[ss_loop].table_name = ss_rec->lt_qual[(ss_loop2+ 1)]
          .tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[ss_loop2].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[(ss_loop2+ 1)].
          tab_qual[ss_loop].row_cnt
         ENDFOR
         SET stat = alterlist(ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual,ss_rec->lt_qual[(ss_loop2+ 1)].
          tab_cnt)
         FOR (ss_loop = 1 TO ss_rec->lt_qual[(ss_loop2+ 1)].tab_cnt)
          SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual[ss_loop].table_name = ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_qual[ss_loop].table_name
          SET ss_rec->lt_qual[(ss_loop2+ 1)].tab_qual[ss_loop].row_cnt = ss_rec->lt_qual[(ss_rec->
          lt_cnt+ 1)].tab_qual[ss_loop].row_cnt
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((ss_rec->sort_flag=3)
    AND (ss_rec->lt_qual[ss_rec_pos].tab_cnt > 1)
    AND (ss_rec->cur_flag != 3))
    SET ss_rec->cur_flag = 3
    SET stat = alterlist(ss_rec->lt_qual[ss_rec_pos].tab_qual,(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1
     ))
    FOR (ss_loop1 = 1 TO (ss_rec->lt_qual[ss_rec_pos].tab_cnt - 1))
      FOR (ss_loop2 = 1 TO (ss_rec->lt_qual[ss_rec_pos].tab_cnt - 1))
        IF ((ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].table_name > ss_rec->lt_qual[ss_rec_pos].
        tab_qual[(ss_loop2+ 1)].table_name))
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].
         table_name = ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].table_name
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].table_name = ss_rec->lt_qual[ss_rec_pos].
         tab_qual[(ss_loop2+ 1)].table_name
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_loop2+ 1)].table_name = ss_rec->lt_qual[
         ss_rec_pos].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].table_name
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].row_cnt
          = ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].row_cnt
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].row_cnt = ss_rec->lt_qual[ss_rec_pos].
         tab_qual[(ss_loop2+ 1)].row_cnt
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_loop2+ 1)].row_cnt = ss_rec->lt_qual[ss_rec_pos
         ].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].row_cnt
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((ss_rec->sort_flag=4)
    AND (ss_rec->lt_qual[ss_rec_pos].tab_cnt > 1)
    AND (ss_rec->cur_flag != 4))
    SET ss_rec->cur_flag = 4
    SET stat = alterlist(ss_rec->lt_qual[ss_rec_pos].tab_qual,(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1
     ))
    FOR (ss_loop1 = 1 TO (ss_rec->lt_qual[ss_rec_pos].tab_cnt - 1))
      FOR (ss_loop2 = 1 TO (ss_rec->lt_qual[ss_rec_pos].tab_cnt - 1))
        IF ((((ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].row_cnt < ss_rec->lt_qual[ss_rec_pos].
        tab_qual[(ss_loop2+ 1)].row_cnt)) OR ((ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].row_cnt
        =ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_loop2+ 1)].row_cnt)
         AND (ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].table_name > ss_rec->lt_qual[ss_rec_pos]
        .tab_qual[(ss_loop2+ 1)].table_name))) )
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].
         table_name = ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].table_name
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].table_name = ss_rec->lt_qual[ss_rec_pos].
         tab_qual[(ss_loop2+ 1)].table_name
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_loop2+ 1)].table_name = ss_rec->lt_qual[
         ss_rec_pos].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].table_name
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].row_cnt
          = ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].row_cnt
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[ss_loop2].row_cnt = ss_rec->lt_qual[ss_rec_pos].
         tab_qual[(ss_loop2+ 1)].row_cnt
         SET ss_rec->lt_qual[ss_rec_pos].tab_qual[(ss_loop2+ 1)].row_cnt = ss_rec->lt_qual[ss_rec_pos
         ].tab_qual[(ss_rec->lt_qual[ss_rec_pos].tab_cnt+ 1)].row_cnt
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE dcli_print_screen(ps_file_name,ps_rec)
   DECLARE ps_temp_str = vc WITH protect, noconstant("")
   SELECT INTO value(ps_file_name)
    FROM (dummyt d  WITH seq = ps_rec->lt_cnt)
    HEAD REPORT
     col 1, ps_temp_str = concat("Source: ",ps_rec->src_name,",Target: ",ps_rec->cur_name,
      ',"Contexts being merged: ',
      replace(ps_rec->ctp_str,"::",", ",0),'"'), ps_temp_str,
     row + 1, ps_temp_str = "LOG_TYPE,COUNT,CHILD,INVESTIGATE,DESCRIPTION", ps_temp_str,
     row + 1
    DETAIL
     IF ((ps_rec->lt_qual[d.seq].inv_ind=1))
      ps_temp_str = concat('"',ps_rec->lt_qual[d.seq].log_type,'","',trim(cnvtstring(ps_rec->lt_qual[
         d.seq].log_type_sum)),'","',
       trim(cnvtstring(ps_rec->lt_qual[d.seq].child_cnt_sum)),'","Y","',ps_rec->lt_qual[d.seq].
       log_msg,'"')
     ELSE
      ps_temp_str = concat('"',ps_rec->lt_qual[d.seq].log_type,'","',trim(cnvtstring(ps_rec->lt_qual[
         d.seq].log_type_sum)),'","',
       trim(cnvtstring(ps_rec->lt_qual[d.seq].child_cnt_sum)),'","N","',ps_rec->lt_qual[d.seq].
       log_msg,'"')
     ENDIF
     ps_temp_str, row + 1
    WITH nocounter, maxrow = 1, maxcol = 1000,
     format = variable, formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dcli_manage_details(md_rec,md_rec_pos)
   DECLARE md_accept = vc WITH protect, noconstant("")
   DECLARE md_file_name = vc WITH protect, noconstant("")
   DECLARE md_log_type = vc WITH protect, noconstant("")
   DECLARE md_tab_name = vc WITH protect, noconstant("")
   SET md_rec->cur_rs_pos = 0
   WHILE (true)
     CALL video(n)
     SET accept = scroll
     CALL dcli_refresh_details(md_rec,md_rec_pos)
     CALL accept(24,18,"XXX;CUS","E")
     CASE (curscroll)
      OF 0:
       SET md_accept = curaccept
       IF (md_accept="E")
        RETURN(null)
       ELSEIF (md_accept="H")
        SET accept = notime
        SET accept = noscroll
        CALL dcli_show_help_tab(md_rec,md_rec_pos)
        SET accept = time(30)
        SET accept = scroll
       ELSEIF (md_accept="S")
        SET md_file_name = drdc_get_name(concat("RDDS Change Log ",md_rec->lt_qual[md_rec_pos].
          log_type," Issues"),concat(md_rec->lt_qual[md_rec_pos].log_type,"_REPORT.CSV"))
        IF (md_file_name != "-1")
         IF (dcli_print_details(md_file_name,md_rec,md_rec_pos)=1)
          CALL drdc_file_success(concat("RDDS Change Log ",md_rec->lt_qual[md_rec_pos].log_type,
            " Issues"),md_file_name,1)
         ELSE
          CALL drdc_file_success(concat("RDDS Change Log ",md_rec->lt_qual[md_rec_pos].log_type,
            " Issues"),md_file_name,0)
         ENDIF
        ENDIF
       ELSEIF (md_accept="T")
        SET dclm_issues->sort_flag = 3
        CALL dcli_sort_screen(md_rec,md_rec_pos)
       ELSEIF (md_accept="C")
        SET dclm_issues->sort_flag = 4
        CALL dcli_sort_screen(md_rec,md_rec_pos)
       ELSEIF (isnumeric(md_accept)=1)
        IF (((dclm_issues->max_lines+ dclm_issues->cur_rs_pos) <= dclm_issues->lt_qual[md_rec_pos].
        tab_cnt))
         IF ((cnvtint(md_accept) >= (dclm_issues->cur_rs_pos+ 1))
          AND (cnvtint(md_accept) <= (dclm_issues->max_lines+ dclm_issues->cur_rs_pos)))
          SET md_tab_name = md_rec->lt_qual[md_rec_pos].tab_qual[cnvtint(md_accept)].table_name
          SET md_log_type = md_rec->lt_qual[md_rec_pos].log_type
          EXECUTE dm_dcl_report
          IF ((((dm_err->err_ind=1)) OR ((dcl_reply->status_data.status="S"))) )
           GO TO exit_all
          ENDIF
         ELSE
          CALL text(24,1,fillstring(132," "))
          CALL text(24,1,"Invalid Entry, Try again.")
          CALL pause(3)
         ENDIF
        ELSE
         IF ((cnvtint(md_accept) >= (dclm_issues->cur_rs_pos+ 1))
          AND (cnvtint(md_accept) <= dclm_issues->lt_qual[md_rec_pos].tab_cnt))
          SET md_tab_name = md_rec->lt_qual[md_rec_pos].tab_qual[cnvtint(md_accept)].table_name
          SET md_log_type = md_rec->lt_qual[md_rec_pos].log_type
          EXECUTE dm_dcl_report
          IF ((((dm_err->err_ind=1)) OR ((dcl_reply->status_data.status="S"))) )
           GO TO exit_all
          ENDIF
         ELSE
          CALL text(24,1,fillstring(132," "))
          CALL text(24,1,"Invalid Entry, Try again.")
          CALL pause(3)
         ENDIF
        ENDIF
       ELSE
        CALL text(24,1,fillstring(132," "))
        CALL text(24,1,"Invalid Entry, Try again.")
        CALL pause(3)
       ENDIF
      OF 1:
      OF 6:
       IF (((dclm_issues->cur_rs_pos+ dclm_issues->max_lines) <= dclm_issues->lt_qual[md_rec_pos].
       tab_cnt))
        SET dclm_issues->cur_rs_pos = (dclm_issues->cur_rs_pos+ dclm_issues->max_lines)
       ENDIF
      OF 2:
      OF 5:
       SET dclm_issues->cur_rs_pos = greatest((dclm_issues->cur_rs_pos - dclm_issues->max_lines),0)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dcli_refresh_details(rd_rec,rd_rec_pos)
   DECLARE rd_start = i4 WITH protect, noconstant(4)
   DECLARE rd_done_ind = i2 WITH protect, noconstant(0)
   DECLARE rd_temp_str = vc WITH protect, noconstant("")
   DECLARE rd_partial_str = vc WITH protect, noconstant("")
   DECLARE rd_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE rd_pos = i4 WITH protect, noconstant(0)
   DECLARE rd_loop = i4 WITH protect, noconstant(0)
   DECLARE rd_cnt = i4 WITH protect, noconstant(0)
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL text(1,50,concat("RDDS Change Log ",rd_rec->lt_qual[rd_rec_pos].log_type," Issues"))
   CALL text(2,1,concat("Env: ",rd_rec->cur_name))
   CALL text(2,30,concat("Source: ",rd_rec->src_name))
   CALL text(2,(132 - size(concat("Open Event: ",rd_rec->oe_name))),concat("Open Event: ",rd_rec->
     oe_name))
   CALL text(3,1,concat("LOG TYPE: ",rd_rec->lt_qual[rd_rec_pos].log_type))
   CALL text(3,18,concat("Count: ",trim(cnvtstring(rd_rec->lt_qual[rd_rec_pos].log_type_sum))))
   SET rd_start = drdc_wrap_menu_lines(rd_rec->lt_qual[rd_rec_pos].log_msg,3,35,"",2,
    130)
   CALL text(rd_start,1,"Contexts being merged:")
   SET rd_temp_str = replace(rd_rec->ctp_str,"::",", ",0)
   SET rd_start = drdc_wrap_menu_lines(rd_temp_str,rd_start,24,"",2,
    109)
   CALL text(rd_start,1,fillstring(132,"-"))
   IF ((rd_rec->cur_rs_pos > 1))
    CALL text((rd_start+ 1),85,"More data up...")
   ENDIF
   SET rd_start = (rd_start+ 1)
   CALL text(rd_start,1,"No.")
   CALL text(rd_start,5,"TABLE_NAME")
   CALL text(rd_start,40,"COUNT")
   SET rd_rec->max_lines = (22 - rd_start)
   FOR (rd_stop_pos = 1 TO rd_rec->max_lines)
     IF (((rd_stop_pos+ rd_rec->cur_rs_pos) <= rd_rec->lt_qual[rd_rec_pos].tab_cnt))
      CALL text((rd_stop_pos+ rd_start),1,trim(cnvtstring((rd_stop_pos+ rd_rec->cur_rs_pos))))
      CALL text((rd_stop_pos+ rd_start),5,rd_rec->lt_qual[rd_rec_pos].tab_qual[(rd_stop_pos+ rd_rec->
       cur_rs_pos)].table_name)
      CALL text((rd_stop_pos+ rd_start),40,build(rd_rec->lt_qual[rd_rec_pos].tab_qual[(rd_stop_pos+
        rd_rec->cur_rs_pos)].row_cnt))
     ENDIF
   ENDFOR
   IF (((rd_rec->max_lines+ rd_rec->cur_rs_pos) <= rd_rec->lt_qual[rd_rec_pos].tab_cnt))
    CALL text((rd_start+ rd_rec->max_lines),85,"More data down...")
   ENDIF
   SET rd_temp_str = concat(fillstring(value(((132 - size(rd_rec->refresh_time))/ 2)),"-"),rd_rec->
    refresh_time,fillstring(value(((132 - size(rd_rec->refresh_time))/ 2)),"-"))
   CALL text(23,1,rd_temp_str)
   IF (((rd_rec->max_lines+ rd_rec->cur_rs_pos) <= rd_rec->lt_qual[rd_rec_pos].tab_cnt))
    CALL text(24,1,concat("Command Options: __ (",trim(cnvtstring((rd_rec->cur_rs_pos+ 1)))," - ",
      trim(cnvtstring((rd_rec->cur_rs_pos+ rd_rec->max_lines))),
      " for report), (H)elp, (E)xit, (S)ave to CSV, Sort ",
      "(T)able_Name or (C)ount"))
   ELSE
    CALL text(24,1,concat("Command Options: __ (",trim(cnvtstring((rd_rec->cur_rs_pos+ 1)))," - ",
      trim(cnvtstring(rd_rec->lt_qual[rd_rec_pos].tab_cnt)),
      " for report), (H)elp, (E)xit, (S)ave to CSV, Sort ",
      "(T)able_Name or (C)ount"))
   ENDIF
 END ;Subroutine
 SUBROUTINE dcli_print_details(pd_file_name,pd_rec,pd_pos)
   DECLARE pd_temp_str = vc WITH protect, noconstant("")
   SELECT INTO value(pd_file_name)
    FROM (dummyt d  WITH seq = pd_rec->lt_qual[pd_pos].tab_cnt)
    HEAD REPORT
     col 1, pd_temp_str = concat("Source: ",pd_rec->src_name,",Target: ",pd_rec->cur_name,
      ',"Contexts being merged: ',
      replace(pd_rec->ctp_str,"::",", ",0),'"'), pd_temp_str,
     row + 1, pd_temp_str = concat('"Description: ',pd_rec->lt_qual[pd_pos].log_msg,'"'), pd_temp_str,
     row + 1, pd_temp_str = "TABLE_NAME,COUNT,LOG_TYPE", pd_temp_str,
     row + 1
    DETAIL
     pd_temp_str = concat('"',pd_rec->lt_qual[pd_pos].tab_qual[d.seq].table_name,'","',trim(
       cnvtstring(pd_rec->lt_qual[pd_pos].tab_qual[d.seq].row_cnt)),'","',
      pd_rec->lt_qual[pd_pos].log_type,'"'), pd_temp_str, row + 1
    WITH nocounter, maxrow = 1, maxcol = 1000,
     format = variable, formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dcli_show_help(dsi_rec)
   DECLARE dsi_start = i4 WITH protect, noconstant(4)
   DECLARE dsi_temp_str = vc WITH protect, noconstant("")
   DECLARE dsi_sort_string = vc WITH protect, noconstant("")
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL text(1,54,"RDDS Change Log Issues")
   CALL text(2,1,concat("Env: ",dsi_rec->cur_name))
   CALL text(2,30,concat("Source: ",dsi_rec->src_name))
   CALL text(2,(132 - size(concat("Open Event: ",dsi_rec->oe_name))),concat("Open Event: ",dsi_rec->
     oe_name))
   IF ((dsi_rec->sort_flag=0))
    SET dsi_sort_string = "Investigate order"
   ELSEIF ((dsi_rec->sort_flag=1))
    SET dsi_sort_string = "Alphabetical order"
   ELSEIF ((dsi_rec->sort_flag=2))
    SET dsi_sort_string = "Numeric descending order"
   ENDIF
   CALL text(3,1,concat("Current sort order: ",dsi_sort_string))
   CALL text(4,1,"Contexts being merged:")
   SET dsi_temp_str = replace(dsi_rec->ctp_str,"::",", ",0)
   SET dsi_start = drdc_wrap_menu_lines(dsi_temp_str,4,24,"",2,
    109)
   CALL text(dsi_start,1,fillstring(132,"-"))
   SET dsi_start = (dsi_start+ 1)
   CALL text(dsi_start,1,
    "This report displays a summary of source change log rows that have resolved to a final non-merged LOG_TYPE."
    )
   CALL text((dsi_start+ 1),1,
    "This report can be used in the target domain to monitor the status of potential issues during the merge process."
    )
   CALL text((dsi_start+ 2),1,
    "For each LOG_TYPE this report displays the COUNT of change log rows, the count of related CHILD change log rows,"
    )
   CALL text((dsi_start+ 3),3,
    "whether this needs further INVestigation, and a short DESCRIPTION of the issue.")
   SET dsi_start = (dsi_start+ 4)
   CALL text(dsi_start,1,
    "An RDDS Event must be open in current target environment before using this report.")
   SET dsi_start = (dsi_start+ 2)
   CALL text(dsi_start,1,"The following change log rows from source are included in the report:")
   CALL text((dsi_start+ 1),5,"- rows for this target environment")
   CALL text((dsi_start+ 2),5,"- rows with context name selected for merge")
   CALL text((dsi_start+ 3),5,"- rows with LOG_TYPEs of: NOMV*, OLDVER, ORPHAN")
   SET dsi_start = (dsi_start+ 5)
   CALL text(dsi_start,1,
    "The (S)ave to CSV option will allow a CSV file to be created with the data on the screen.")
   CALL text((dsi_start+ 1),1,
    "The (L)og Type, (I)nvestigate, or (C)ount options will sort the data on the screen by that column."
    )
   SET dsi_start = (dsi_start+ 2)
   CALL text(dsi_start,1,concat(
     "Selecting a line number for table detail will show the list of table namess affected by that",
     " LOG_TYPE."))
   SET dsi_start = (dsi_start+ 3)
   CALL text(dsi_start,1,"Press Enter to (E)xit __")
   CALL accept(dsi_start,23,"X;CUS","E"
    WHERE curaccept IN ("E"))
 END ;Subroutine
 SUBROUTINE dcli_show_help_tab(dst_rec,dst_rec_pos)
   DECLARE dst_start = i4 WITH protect, noconstant(4)
   DECLARE dst_temp_str = vc WITH protect, noconstant("")
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL text(1,50,concat("RDDS Change Log ",dst_rec->lt_qual[dst_rec_pos].log_type," Issues"))
   CALL text(2,1,concat("Env: ",dst_rec->cur_name))
   CALL text(2,30,concat("Source: ",dst_rec->src_name))
   CALL text(2,(132 - size(concat("Open Event: ",dst_rec->oe_name))),concat("Open Event: ",dst_rec->
     oe_name))
   CALL text(3,1,concat("LOG TYPE: ",dst_rec->lt_qual[dst_rec_pos].log_type))
   CALL text(3,18,concat("Count: ",trim(cnvtstring(dst_rec->lt_qual[dst_rec_pos].log_type_sum))))
   SET dst_start = drdc_wrap_menu_lines(dst_rec->lt_qual[dst_rec_pos].log_msg,3,35,"",2,
    130)
   CALL text(dst_start,1,"Contexts being merged:")
   SET dst_temp_str = replace(dst_rec->ctp_str,"::",", ",0)
   SET dst_start = drdc_wrap_menu_lines(dst_temp_str,4,24,"",2,
    109)
   CALL text(dst_start,1,fillstring(132,"-"))
   SET dst_start = (dst_start+ 1)
   CALL text(dst_start,1,
    "This report displays a summary of source change log rows that have resolved to a final non-merged LOG_TYPE by TABLE_NAME."
    )
   CALL text((dst_start+ 1),1,
    "This report can be used in the target domain so that the LOG_TYPE and TABLE_NAME specific report can be run."
    )
   CALL text((dst_start+ 2),1,concat(
     "For each TABLE_NAME this report displays the COUNT of change log rows."))
   SET dst_start = (dst_start+ 3)
   CALL text(dst_start,1,
    "An RDDS Event must be open in current target environment before using this report.")
   SET dst_start = (dst_start+ 2)
   CALL text(dst_start,1,
    "The (S)ave to CSV option will allow a CSV file to be created with the data on the screen.")
   CALL text((dst_start+ 1),1,
    "The (T)able_name or (C)ount options will sort the data on the screen by that column.")
   SET dst_start = (dst_start+ 3)
   CALL text(dst_start,1,concat(
     "Selecting a line number for audit data will start the LOG_TYPE and TABLE_NAME ",
     "specific report for the options selected."))
   SET dst_start = (dst_start+ 3)
   CALL text(dst_start,1,"Press Enter to (E)xit __")
   CALL accept(dst_start,23,"X;CUS","E"
    WHERE curaccept IN ("E"))
 END ;Subroutine
#exit_all
 CALL clear(1,1)
 SET message = nowindow
 SET accept = noscroll
 IF ((dm_err->err_ind=1))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
END GO
