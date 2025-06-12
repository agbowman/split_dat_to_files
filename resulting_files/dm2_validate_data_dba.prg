CREATE PROGRAM dm2_validate_data:dba
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
 IF ((validate(dm2_compare_rec->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_compare_rec->tbl_cnt,- (2))=- (2)))
  RECORD dm2_compare_rec(
    1 chkpt_1_setup_dt = dq8
    1 chkpt_2_arch_dt = dq8
    1 src_data_link = vc
    1 hrsback = f8
    1 v500_views_ind = i2
    1 max_mm_rows = i4
    1 max_retry_secs = i4
    1 mm_retry_secs = i4
    1 rows_to_sample = i4
    1 restart_compare_ind = i2
    1 tbl_cnt = i4
    1 tab[*]
      2 owner = vc
      2 table_name = vc
      2 compare_table = i2
      2 table_exists_ind = i2
      2 tbl_chkpt_dminfo_dt = dq8
      2 ora_mod_dt = dq8
      2 last_analyzed = dq8
      2 tbl_monitoring = i2
      2 matched_ind = i2
      2 datecol = vc
      2 cmp_dt_tm = dq8
      2 cmp_cnt = i4
      2 object_id = vc
      2 skip_reason = vc
      2 src_view_name = vc
      2 tgt_view_name = vc
      2 cmp_view_name = vc
      2 union_view_name = vc
      2 nkeycol_cnt = i2
      2 nkeycols[*]
        3 column_name = vc
        3 data_type = vc
      2 keycol_cnt = i2
      2 keycols[*]
        3 column_name = vc
        3 data_type = vc
      2 orig_mm_cnt = i4
      2 curr_mm_cnt = i4
      2 mm_rec[*]
        3 recrow_match_ind = i2
        3 reccol[*]
          4 colval_char = vc
          4 colval_num = f8
          4 colval_dt = dq8
      2 chosen_key_column = vc
      2 row_cnt = i4
      2 rows[*]
        3 unique_id = f8
        3 match_ind = i2
      2 match_row_cnt = i4
      2 bottom_ptr = f8
      2 top_ptr = f8
    1 max_row_cnt = i4
    1 total_row_cnt = i4
  )
  SET dm2_compare_rec->src_data_link = "DM2NOTSET"
  SET dm2_compare_rec->hrsback = - (1)
  SET dm2_compare_rec->max_mm_rows = 20
  SET dm2_compare_rec->max_retry_secs = 180
 ENDIF
 DECLARE dcd_num = i4 WITH protect, noconstant(0)
 DECLARE dcd_get_input_data(null) = i2
 DECLARE dcd_validate_datecols(null) = i2
 DECLARE dcd_validate_uniqueidx(notnull_ind=i2) = i2
 DECLARE dcd_generate_mig_views(null) = i2
 DECLARE dcd_validate_prompt(null) = i2
 SUBROUTINE dcd_get_input_data(null)
   DECLARE done = i2 WITH protect, noconstant(0)
   DECLARE dcd_acceptdefault = vc WITH protect, noconstant("M")
   SET width = 132
   SET message = window
   IF ((dm2_compare_rec->src_data_link="DM2NOTSET"))
    DECLARE dcd_dblink = vc WITH protect, noconstant("DM2NOTSET")
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,5,131)
      CALL text(2,2,"Please provide the database link for the source database:")
      IF (dcd_dblink != "DM2NOTSET")
       CALL text(2,60,dcd_dblink)
      ENDIF
      CALL text(4,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(4,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(2,60,"P(15);CU")
        SET dm_err->eproc = "Verifying DB LINK exists"
        SELECT INTO "nl:"
         FROM dba_db_links ddl
         WHERE ddl.db_link=patstring(concat(trim(curaccept),"*"))
        ;end select
        IF (check_error(dm_err->eproc) != 0)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         CALL clear(1,1)
         CALL box(1,1,5,131)
         CALL text(2,2,"The database link given was not found.")
         CALL text(4,2,"(R)etry,(Q)uit: ")
         CALL accept(4,18,"A;cu","R"
          WHERE curaccept IN ("R", "Q"))
         IF (curaccept="Q")
          RETURN(0)
         ENDIF
        ELSE
         SET dcd_dblink = trim(curaccept)
         SET dcd_acceptdefault = "C"
        ENDIF
       OF "C":
        IF (dcd_dblink="DM2NOTSET")
         CALL clear(1,1)
         CALL box(1,1,5,131)
         CALL text(2,2,"You must enter a value for the source database link.")
         CALL text(4,2,"(R)etry,(Q)uit: ")
         CALL accept(4,18,"A;cu","R"
          WHERE curaccept IN ("R", "Q"))
         IF (curaccept="Q")
          RETURN(0)
         ENDIF
        ELSE
         SET dm2_compare_rec->src_data_link = dcd_dblink
         SET done = true
        ENDIF
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   SET done = false
   SET dcd_acceptdefault = "M"
   IF ((dm2_compare_rec->hrsback=- (1)))
    DECLARE dcd_hrsback = i4 WITH protect, noconstant(- (1))
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,7,131)
      CALL text(2,2,
       "Please provide the number of hours back the comparison process should look for recently updated data."
       )
      CALL text(4,2,"Hours Back:")
      IF ((dcd_hrsback != - (1)))
       CALL text(4,14,cnvtstring(dcd_hrsback))
      ENDIF
      CALL text(6,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(6,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(4,14,"9(4);",1
         WHERE curaccept > 0)
        SET dcd_hrsback = curaccept
        SET dcd_acceptdefault = "C"
       OF "C":
        SET dm2_compare_rec->hrsback = dcd_hrsback
        SET done = true
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   SET done = false
   SET dcd_acceptdefault = "M"
   IF ((dm2_compare_rec->tbl_cnt=0))
    DECLARE dcd_own_name = vc WITH protect, noconstant("")
    DECLARE dcd_tbl_name = vc WITH protect, noconstant("")
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,8,131)
      CALL text(2,2,"Please provide the owner and table name that should be compared.")
      CALL text(4,2,"Owner Name:")
      CALL text(4,14,dcd_own_name)
      CALL text(5,2,"Table Name:")
      CALL text(5,14,dcd_tbl_name)
      CALL text(7,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(7,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(4,14,"P(20);cu")
        SET dcd_own_name = curaccept
        CALL accept(5,14,"P(20);cu")
        SET dcd_tbl_name = curaccept
        SET dcd_acceptdefault = "C"
       OF "C":
        SET stat = alterlist(dm2_compare_rec->tab,1)
        SET dm2_compare_rec->tbl_cnt = 1
        SET dm2_compare_rec->tab[1].owner = dcd_own_name
        SET dm2_compare_rec->tab[1].table_name = dcd_tbl_name
        SET dm2_compare_rec->tab[1].datecol = "DM2NOTSET"
        SET dm2_compare_rec->tab[1].nkeycol_cnt = - (1)
        SET done = true
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_datecols(null)
   SET width = 132
   SET message = window
   RECORD dcd_datecols(
     1 list[*]
       2 columns = vc
   )
   DECLARE done = i2 WITH protect, noconstant(0)
   DECLARE dcd_acceptdefault = vc WITH protect, noconstant("M")
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[i].datecol="DM2NOTSET"))
      SET stat = initrec(dcd_datecols)
      SET dm_err->eproc = concat("Validating Date Columns for ",dm2_compare_rec->tab[i].table_name)
      SELECT INTO "nl:"
       dtc.column_name
       FROM dba_tab_columns dtc
       WHERE (dtc.table_name=dm2_compare_rec->tab[i].table_name)
        AND (dtc.owner=dm2_compare_rec->tab[i].owner)
        AND dtc.data_type="DATE"
        AND  EXISTS (
       (SELECT
        1
        FROM dba_ind_columns dic
        WHERE dic.column_name=dtc.column_name
         AND dic.table_owner=dtc.owner
         AND dic.table_name=dtc.table_name
         AND dic.column_position=1))
       HEAD REPORT
        tmp = 0, cnt = 0
       DETAIL
        cnt = (cnt+ 1)
        IF (cnt > tmp)
         tmp = (tmp+ 10), stat = alterlist(dcd_datecols->list,tmp)
        ENDIF
        dcd_datecols->list[cnt].columns = dtc.column_name
       FOOT REPORT
        stat = alterlist(dcd_datecols->list,cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) != 0)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dm2_compare_rec->tab[i].skip_reason = "Indexed date column not specified for table."
      ELSE
       SET done = false
       SET dcd_acceptdefault = "M"
       SET help =
       SELECT
        column = substring(1,30,dcd_datecols->list[d.seq].columns)
        FROM (dummyt d  WITH seq = value(size(dcd_datecols->list,5)))
       ;end select
       DECLARE dcd_datecol = vc WITH protect, noconstant("DM2NOTSET")
       WHILE ( NOT (done))
         CALL clear(1,1)
         CALL box(1,1,7,131)
         CALL text(2,2,concat("Please provide the driver date column for ",dm2_compare_rec->tab[i].
           owner,".",dm2_compare_rec->tab[i].table_name,":"))
         CALL text(4,2,"Column Name:")
         IF (dcd_datecol != "DM2NOTSET")
          CALL text(4,14,dcd_datecol)
         ENDIF
         CALL text(6,2,"(M)odify, (C)ontinue, (Q)uit: ")
         CALL accept(6,33,"A;CU",dcd_acceptdefault
          WHERE curaccept IN ("M", "C", "Q"))
         CASE (curaccept)
          OF "M":
           CALL accept(4,14,"P(30);CF")
           SET dcd_datecol = curaccept
           SET dcd_acceptdefault = "C"
          OF "C":
           SET dm2_compare_rec->tab[i].datecol = dcd_datecol
           SET done = true
          OF "Q":
           RETURN(0)
         ENDCASE
       ENDWHILE
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_uniqueidx(notnull_ind)
   RECORD dcd_ind_cols(
     1 col_cnt = i2
     1 columns[*]
       2 col_name = vc
       2 data_type = vc
   )
   SET dm_err->eproc = "Getting Unique Key Columns"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT
    IF (notnull_ind=1)
     PLAN (d
      WHERE (dm2_compare_rec->tab[d.seq].nkeycol_cnt=- (1)))
      JOIN (dic
      WHERE (dic.table_owner=dm2_compare_rec->tab[d.seq].owner)
       AND (dic.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND ((dic.index_name IN (
      (SELECT
       di.index_name
       FROM dba_indexes di
       WHERE di.uniqueness="UNIQUE"
        AND (di.owner=dm2_compare_rec->tab[d.seq].owner)
        AND (di.table_name=dm2_compare_rec->tab[d.seq].table_name)
        AND  EXISTS (
       (SELECT
        1
        FROM dba_ind_columns dic2,
         dm2_dba_notnull_cols ddnc
        WHERE dic2.index_name=di.index_name
         AND dic2.index_owner=di.owner
         AND ddnc.column_name=dic2.column_name
         AND ddnc.owner=dic2.table_owner
         AND ddnc.table_name=dic2.table_name))))) OR (dic.column_name="DM2_MIG_SEQ_ID")) )
      JOIN (dtc
      WHERE dtc.table_name=dic.table_name
       AND dtc.column_name=dic.column_name
       AND dtc.owner=dic.table_owner
       AND (dtc.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND (dtc.owner=dm2_compare_rec->tab[d.seq].owner))
      JOIN (ao
      WHERE ao.object_name=dtc.table_name
       AND ao.object_type="TABLE"
       AND ao.owner=dtc.owner)
    ELSE
     PLAN (d
      WHERE (dm2_compare_rec->tab[d.seq].nkeycol_cnt=- (1)))
      JOIN (dic
      WHERE (dic.table_owner=dm2_compare_rec->tab[d.seq].owner)
       AND (dic.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND dic.index_name IN (
      (SELECT
       di.index_name
       FROM dba_indexes di
       WHERE di.uniqueness="UNIQUE"
        AND (di.owner=dm2_compare_rec->tab[d.seq].owner)
        AND (di.table_name=dm2_compare_rec->tab[d.seq].table_name))))
      JOIN (dtc
      WHERE dtc.table_name=dic.table_name
       AND dtc.column_name=dic.column_name
       AND dtc.owner=dic.table_owner
       AND (dtc.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND (dtc.owner=dm2_compare_rec->tab[d.seq].owner))
      JOIN (ao
      WHERE ao.object_name=dtc.table_name
       AND ao.object_type="TABLE"
       AND ao.owner=dtc.owner)
    ENDIF
    INTO "nl:"
    FROM dba_tab_columns dtc,
     dba_ind_columns dic,
     all_objects ao,
     (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt))
    ORDER BY dic.table_owner, dic.table_name, dic.index_name DESC,
     dic.column_position
    HEAD dic.table_owner
     row + 0
    HEAD dic.table_name
     dm2_compare_rec->tab[d.seq].keycol_cnt = 9999, dm2_compare_rec->tab[d.seq].object_id =
     cnvtstring(ao.object_id)
    HEAD dic.index_name
     tmp = 0, stat = initrec(dcd_ind_cols)
    DETAIL
     dcd_ind_cols->col_cnt = (dcd_ind_cols->col_cnt+ 1)
     IF ((dcd_ind_cols->col_cnt > tmp))
      tmp = (tmp+ 10), stat = alterlist(dcd_ind_cols->columns,tmp)
     ENDIF
     dcd_ind_cols->columns[dcd_ind_cols->col_cnt].col_name = dic.column_name, dcd_ind_cols->columns[
     dcd_ind_cols->col_cnt].data_type = dtc.data_type
    FOOT  dic.index_name
     IF ((dcd_ind_cols->col_cnt < dm2_compare_rec->tab[d.seq].keycol_cnt))
      stat = alterlist(dm2_compare_rec->tab[d.seq].keycols,dcd_ind_cols->col_cnt), dm2_compare_rec->
      tab[d.seq].keycol_cnt = dcd_ind_cols->col_cnt
      FOR (i = 1 TO dcd_ind_cols->col_cnt)
       dm2_compare_rec->tab[d.seq].keycols[i].column_name = dcd_ind_cols->columns[i].col_name,
       dm2_compare_rec->tab[d.seq].keycols[i].data_type = dcd_ind_cols->columns[i].data_type
      ENDFOR
     ENDIF
    FOOT  dic.table_name
     IF ((dm2_compare_rec->tab[d.seq].keycol_cnt=9999))
      dm2_compare_rec->tab[d.seq].keycol_cnt = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ENDIF
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[i].keycol_cnt=0))
      SET dm2_compare_rec->tab[i].skip_reason = "A valid unique index was not found."
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Populating column list."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   DECLARE dcd_start = i4 WITH protect, noconstant(1)
   DECLARE dcd_top = i4 WITH protect, noconstant(0)
   SET dcd_top = (ceil((cnvtreal(dm2_compare_rec->tbl_cnt)/ 50)) * 50)
   SET stat = alterlist(dm2_compare_rec->tab,dcd_top)
   FOR (i = (dm2_compare_rec->tbl_cnt+ 1) TO dcd_top)
    SET dm2_compare_rec->tab[i].table_name = dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].
    table_name
    SET dm2_compare_rec->tab[i].owner = dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].owner
   ENDFOR
   SELECT INTO "nl:"
    FROM dba_tab_columns dtc,
     (dummyt d  WITH seq = value((dcd_top/ 50)))
    PLAN (d
     WHERE (dm2_compare_rec->tbl_cnt > 0)
      AND assign(dcd_start,evaluate(d.seq,1,1,(dcd_start+ 50))))
     JOIN (dtc
     WHERE expand(dcd_num,dcd_start,(dcd_start+ 49),dtc.table_name,dm2_compare_rec->tab[dcd_num].
      table_name,
      dtc.owner,dm2_compare_rec->tab[dcd_num].owner)
      AND  NOT (dtc.data_type IN ("LONG", "CLOB", "BLOB", "LONG RAW", "RAW")))
    ORDER BY dtc.owner, dtc.table_name
    HEAD dtc.owner
     row + 0
    HEAD dtc.table_name
     tmp = 0, x = locateval(dcd_num,1,dm2_compare_rec->tbl_cnt,dtc.table_name,dm2_compare_rec->tab[
      dcd_num].table_name,
      dtc.owner,dm2_compare_rec->tab[dcd_num].owner), dm2_compare_rec->tab[x].nkeycol_cnt = 0
    DETAIL
     IF (locateval(dcd_num,1,dm2_compare_rec->tab[x].keycol_cnt,dtc.column_name,dm2_compare_rec->tab[
      x].keycols[dcd_num].column_name)=0)
      dm2_compare_rec->tab[x].nkeycol_cnt = (dm2_compare_rec->tab[x].nkeycol_cnt+ 1)
      IF ((dm2_compare_rec->tab[x].nkeycol_cnt > tmp))
       tmp = (tmp+ 10), stat = alterlist(dm2_compare_rec->tab[x].nkeycols,tmp)
      ENDIF
      dm2_compare_rec->tab[x].nkeycols[dm2_compare_rec->tab[x].nkeycol_cnt].column_name = dtc
      .column_name, dm2_compare_rec->tab[x].nkeycols[dm2_compare_rec->tab[x].nkeycol_cnt].data_type
       = dtc.data_type
     ENDIF
    FOOT  dtc.table_name
     stat = alterlist(dm2_compare_rec->tab[x].nkeycols,dm2_compare_rec->tab[x].nkeycol_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm2_compare_rec->tab,dm2_compare_rec->tbl_cnt)
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Error retrieving column info."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_generate_mig_views(null)
   DECLARE dcd_key_columns = vc WITH protect, noconstant("")
   DECLARE dcd_nkey_columns = vc WITH protect, noconstant("")
   DECLARE dcd_null_keys = vc WITH protect, noconstant("")
   DECLARE dcd_null_nkeys = vc WITH protect, noconstant("")
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((((dm2_compare_rec->tab[i].owner != "V500")) OR ((dm2_compare_rec->v500_views_ind=1)))
      AND (dm2_compare_rec->tab[i].skip_reason=""))
      IF (textlen(dm2_compare_rec->tab[i].object_id) > 13)
       SET dm2_compare_rec->tab[i].skip_reason = "Object_id too long to create view"
      ELSE
       SET dcd_key_columns = dm2_compare_rec->tab[i].keycols[1].column_name
       SET dcd_null_keys = concat("null as ",dm2_compare_rec->tab[i].keycols[1].column_name)
       FOR (j = 2 TO dm2_compare_rec->tab[i].keycol_cnt)
        SET dcd_key_columns = concat(dcd_key_columns,", ",dm2_compare_rec->tab[i].keycols[j].
         column_name)
        SET dcd_null_keys = concat(dcd_null_keys,", null as ",dm2_compare_rec->tab[i].keycols[j].
         column_name)
       ENDFOR
       IF ((dm2_compare_rec->tab[1].nkeycol_cnt > 0))
        SET dcd_nkey_columns = dm2_compare_rec->tab[i].nkeycols[1].column_name
        SET dcd_null_nkeys = concat("null as ",dm2_compare_rec->tab[i].nkeycols[1].column_name)
        FOR (j = 2 TO dm2_compare_rec->tab[i].nkeycol_cnt)
         SET dcd_nkey_columns = concat(dcd_nkey_columns,", ",dm2_compare_rec->tab[i].nkeycols[j].
          column_name)
         SET dcd_null_nkeys = concat(dcd_null_nkeys,", null as ",dm2_compare_rec->tab[i].nkeycols[j].
          column_name)
        ENDFOR
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migc",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGC",dm2_compare_rec->tab[i].
         object_id," AS SELECT ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ ",dcd_key_columns,", ",dcd_nkey_columns,
         ", -1 as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"@",
         dm2_compare_rec->src_data_link," ^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^ WHERE ",dm2_compare_rec->tab[i].datecol," >   ^)"),0)
        CALL dm2_push_cmd(concat("asis(^( (SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR )^)"),0)
       ENDIF
       CALL dm2_push_cmd("asis(^MINUS^)",0)
       CALL dm2_push_cmd(concat("asis(^SELECT ",dcd_key_columns,", ",dcd_nkey_columns,
         ", -1 as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^ WHERE ",dm2_compare_rec->tab[i].datecol," > ^)"),0)
        CALL dm2_push_cmd(concat("asis(^((SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR )^)"),0)
       ENDIF
       CALL dm2_push_cmd("asis(^ UNION^)",0)
       CALL dm2_push_cmd(concat("asis(^ select ",dcd_null_keys,", ",dcd_null_nkeys,
         ", count(1) as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"@",
         dm2_compare_rec->src_data_link," ^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^WHERE ",dm2_compare_rec->tab[i].datecol," >^)"),0)
        CALL dm2_push_cmd(concat("asis(^ ((SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR ) ^) "),0)
       ENDIF
       CALL dm2_push_cmd(asis("go"),1)
       SET dm2_compare_rec->tab[i].cmp_view_name = concat("DM2MIGC",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migs",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGS",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT ",dcd_key_columns,", ",dcd_nkey_columns," FROM ",
         dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[i].table_name,"@",dm2_compare_rec->
         src_data_link,
         "^) go"),1)
       SET dm2_compare_rec->tab[i].src_view_name = concat("DM2MIGS",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migt",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGT",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT ",dcd_key_columns,", ",dcd_nkey_columns," FROM ",
         dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[i].table_name,"^) go"),1)
       SET dm2_compare_rec->tab[i].tgt_view_name = concat("DM2MIGT",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migu",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGU",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT 'SOURCE' AS SOURCE, A.* FROM ",dm2_compare_rec->tab[i]
         .src_view_name," A"," UNION ALL SELECT 'TARGET' AS TARGET, B.* FROM ",dm2_compare_rec->tab[i
         ].tgt_view_name,
         " B^) go"),1)
       SET dm2_compare_rec->tab[i].union_view_name = concat("DM2MIGU",dm2_compare_rec->tab[i].
        object_id)
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   EXECUTE oragen3 "DM2MIG*"
   IF ((dm_err->err_ind != 0))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_prompt(null)
   DECLARE dvp_sample_exists_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Determining if mismatch sample exists from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_MISMATCH"
    DETAIL
     dvp_sample_exists_ind = 1
    WITH nocounter, maxqual(di,1)
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Data Validation")
   IF (dvp_sample_exists_ind)
    CALL text(4,2,"Mismatched row data was found from a previous comparison.")
    CALL text(5,2,"(C)ontinue with previous sample, (R)estart with new sample, or (Q)uit: ")
    CALL accept(5,73,"A;CU","C"
     WHERE curaccept IN ("R", "C", "Q"))
    IF (curaccept="Q")
     SET message = nowindow
     CALL clear(1,1)
     RETURN(0)
    ENDIF
    SET dm2_compare_rec->restart_compare_ind = evaluate(curaccept,"R",1,0)
   ENDIF
   IF (((dm2_compare_rec->restart_compare_ind) OR ( NOT (dvp_sample_exists_ind))) )
    CALL text(7,2,"How many rows would you like to compare?")
    CALL accept(7,43,"99999999;",1000
     WHERE curaccept > 0)
    SET dm2_compare_rec->rows_to_sample = curaccept
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   RETURN(1)
 END ;Subroutine
 DECLARE dvd_dblink = vc WITH protect, noconstant("")
 DECLARE dvd_whereclause = vc WITH protect, noconstant(" ")
 DECLARE dvd_key_column = vc WITH protect, noconstant(" ")
 DECLARE dvd_bottom_window_ptr = f8 WITH protect, noconstant(0.0)
 DECLARE dvd_top_window_ptr = f8 WITH protect, noconstant(0.0)
 DECLARE dvd_input_file_name = vc WITH protect, noconstant("cer_install:dm2_mig_validate_tables.txt")
 DECLARE dvd_rows_to_compare = i4 WITH protect, noconstant(1000)
 DECLARE dvd_database_name = vc WITH protect, noconstant("x")
 DECLARE dvd_remote_db_name = vc WITH protect, noconstant("x")
 DECLARE dvd_tgt_view_name = vc WITH protect, noconstant("x")
 DECLARE dvd_src_view_name = vc WITH protect, noconstant("x")
 DECLARE dvd_non_v500_tab_ind = i2 WITH protect, noconstant(0)
 DECLARE dvd_retry_ind = i2 WITH protect, noconstant(0)
 DECLARE dvd_create_view_stmt = vc WITH protect, noconstant("")
 DECLARE dvd_cnt = i4 WITH protect, noconstant(0)
 DECLARE dvd_tbl_ndx = i4 WITH protect, noconstant(0)
 DECLARE dvd_greatest = f8 WITH protect, noconstant(0.0)
 DECLARE dvd_str = vc WITH protect, noconstant("")
 IF (check_logfile("dm2_validate_data",".log","dm2_validate data LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Validating inputs"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SET dvd_dblink =  $1
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->emsg =
  "Parameter usage: dm2_validate_data '<Remote database link>', <number of rows to match>, '<input file>'"
  GO TO exit_script
 ENDIF
 SET dm2_compare_rec->src_data_link = dvd_dblink
 SET dvd_rows_to_compare =  $2
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->emsg =
  "Parameter usage: dm2_validate_data '<Remote database link>', <number of rows to match>, '<input file>'"
  GO TO exit_script
 ELSEIF (dvd_rows_to_compare < 1)
  SET dm_err->emsg = "<Number of Rows to Compare> must be greater than zero."
  SET dm_err->err_ind = 1
  GO TO exit_script
 ENDIF
 SET dvd_input_file_name =  $3
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->emsg =
  "Parameter usage: dm2_validate_data '<Remote database link>', <number of rows to match>, '<input file>'"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM all_db_links adl
  WHERE adl.db_link=patstring(concat(cnvtupper(dvd_dblink),"*"))
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The database link given was not found!"
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Getting remote database name"
 SELECT INTO "nl:"
  vdb.name
  FROM (value(concat("V$DATABASE@",dvd_dblink)) vdb)
  DETAIL
   dvd_remote_db_name = vdb.name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  GO TO exit_script
 ELSEIF (dvd_remote_db_name="x")
  SET dm_err->emsg = "Could not get remote, DB name, using 'x'."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "Getting local database name"
 SELECT INTO "nl:"
  vdb.name
  FROM v$database vdb
  DETAIL
   dvd_database_name = vdb.name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  GO TO exit_script
 ELSEIF (dvd_database_name="x")
  SET dm_err->emsg = "Could not get local DB name, using 'x'."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
 ENDIF
 SET dm_err->eproc = "Dropping and re-creating DM2MIG_VALIDATE_DATA ddlrecord."
 DROP DDLRECORD dm2mig_validate_data FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dm2mig_validate_data FROM DATABASE v500
 TABLE dm2mig_validate_data
  1 unique_id  = f8 CCL(unique_id)
 END TABLE dm2mig_validate_data
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ( NOT (dcd_validate_prompt(null)))
  GO TO exit_script
 ENDIF
 SET dvd_rows_to_compare = dm2_compare_rec->rows_to_sample
 IF (dm2_compare_rec->restart_compare_ind)
  SET dm_err->eproc = "Deleting mismatch data from dm_info to start compare process."
  DELETE  FROM dm_info di
   WHERE di.info_domain="DM2_MIG_MISMATCH"
   WITH nocounter, maxcommit = 10000
  ;end delete
  IF (check_error(dm_err->eproc))
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SET dm_err->eproc = "Querying for previous mismatched data from dm_info."
 SELECT INTO "nl:"
  owner = substring(1,30,substring(1,(findstring(".",di.info_name) - 1),di.info_name)), table_name =
  substring(1,30,substring((findstring(".",di.info_name)+ 1),(findstring(":",di.info_name) - (
    findstring(".",di.info_name)+ 1)),di.info_name)), column_name = substring(1,30,substring((
    findstring(":",di.info_name)+ 1),(findstring(":",di.info_name,1,1) - (findstring(":",di.info_name
     )+ 1)),di.info_name)),
  unique_id = cnvtreal(substring((findstring(":",di.info_name,1,1)+ 1),size(di.info_name),di
    .info_name))
  FROM dm_info di
  WHERE di.info_domain="DM2_MIG_MISMATCH"
  ORDER BY owner, table_name, unique_id
  HEAD REPORT
   dm2_compare_rec->tbl_cnt = 0, stat = alterlist(dm2_compare_rec->tab,0), tbl_cnt = 0
  HEAD owner
   row + 0
  HEAD table_name
   tbl_cnt = (tbl_cnt+ 1)
   IF (mod(tbl_cnt,500)=1)
    stat = alterlist(dm2_compare_rec->tab,(tbl_cnt+ 499))
   ENDIF
   IF (owner != "V500")
    dvd_non_v500_tab_ind = 1
   ENDIF
   dm2_compare_rec->tab[tbl_cnt].owner = owner, dm2_compare_rec->tab[tbl_cnt].table_name = table_name,
   dm2_compare_rec->tab[tbl_cnt].chosen_key_column = column_name,
   dm2_compare_rec->tab[tbl_cnt].nkeycol_cnt = - (1), dm2_compare_rec->tab[tbl_cnt].bottom_ptr =
   unique_id, dm2_compare_rec->tab[tbl_cnt].compare_table = 1,
   row_cnt = 0
  DETAIL
   row_cnt = (row_cnt+ 1), dm2_compare_rec->tab[tbl_cnt].row_cnt = (dm2_compare_rec->tab[tbl_cnt].
   row_cnt+ 1), stat = alterlist(dm2_compare_rec->tab[tbl_cnt].rows,row_cnt),
   dm2_compare_rec->tab[tbl_cnt].rows[row_cnt].unique_id = unique_id, dm2_compare_rec->tab[tbl_cnt].
   rows[row_cnt].match_ind = 1
  FOOT  table_name
   dm2_compare_rec->max_row_cnt = greatest(dm2_compare_rec->max_row_cnt,dm2_compare_rec->tab[tbl_cnt]
    .row_cnt), dm2_compare_rec->tab[tbl_cnt].match_row_cnt = dm2_compare_rec->tab[tbl_cnt].row_cnt,
   dm2_compare_rec->tab[tbl_cnt].top_ptr = unique_id
  FOOT REPORT
   dm2_compare_rec->tbl_cnt = tbl_cnt, stat = alterlist(dm2_compare_rec->tab,dm2_compare_rec->tbl_cnt
    )
   IF (dm2_compare_rec->tbl_cnt)
    dvd_retry_ind = 1
   ENDIF
  WITH nocounter, nullreport
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ( NOT (dvd_retry_ind))
  SET dm_err->eproc = "Loading input file from disk."
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  IF (findfile(dvd_input_file_name) != 1)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat("Could not locate the input file! (",dvd_input_file_name,")")
   GO TO exit_script
  ELSE
   SET logical inputfile1 value(dvd_input_file_name)
   FREE DEFINE rtl2
   DEFINE rtl2 "InputFile1"
   SELECT INTO "nl:"
    tl = textlen(r.line)
    FROM rtl2t r
    HEAD REPORT
     tmp = 0, own_pointer = 0
    DETAIL
     dm2_compare_rec->tbl_cnt = (dm2_compare_rec->tbl_cnt+ 1)
     IF ((dm2_compare_rec->tbl_cnt > tmp))
      tmp = (tmp+ 20), stat = alterlist(dm2_compare_rec->tab,tmp)
     ENDIF
     own_pointer = findstring(".",r.line)
     IF (own_pointer < 1)
      dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].owner = "V500", dm2_compare_rec->tab[
      dm2_compare_rec->tbl_cnt].table_name = r.line
     ELSE
      dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].owner = substring(1,(own_pointer - 1),r.line),
      dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].table_name = substring((own_pointer+ 1),(tl -
       own_pointer),r.line)
      IF ((dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].owner != "V500"))
       dvd_non_v500_tab_ind = 1
      ENDIF
     ENDIF
     dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].nkeycol_cnt = - (1)
    FOOT REPORT
     stat = alterlist(dm2_compare_rec->tab,dm2_compare_rec->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    GO TO exit_script
   ELSEIF ((dm2_compare_rec->tbl_cnt=0))
    SET dm_err->emsg = "The input file is empty!"
    SET dm_err->err_ind = 1
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET dm_err->eproc = "Checking if tables being compared exist in TARGET."
 SELECT INTO "nl:"
  FROM dba_tables d
  DETAIL
   IF (locateval(dvd_tbl_ndx,1,dm2_compare_rec->tbl_cnt,d.owner,dm2_compare_rec->tab[dvd_tbl_ndx].
    owner,
    d.table_name,dm2_compare_rec->tab[dvd_tbl_ndx].table_name) > 0)
    dm2_compare_rec->tab[dvd_tbl_ndx].table_exists_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dvd_retry_ind=0)
  SET dm_err->eproc = "Gather database checkpoint information from SOURCE"
  SELECT INTO "nl:"
   FROM (value(concat("DM_INFO@",dm2_compare_rec->src_data_link)) di)
   WHERE di.info_domain IN ("DM2_MIG_SETUP", "DM2_MIG_DATA")
   DETAIL
    IF (di.info_domain="DM2_MIG_SETUP"
     AND di.info_name="SCHEMA_SETUP_COMPLETE")
     dm2_compare_rec->chkpt_1_setup_dt = di.info_date
    ENDIF
    IF (di.info_domain="DM2_MIG_DATA"
     AND di.info_name="ARCHIVE_COPY_FIRST_EXEC")
     dm2_compare_rec->chkpt_2_arch_dt = di.info_date
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Gather table monitoring info from SOURCE"
  SELECT INTO "nl:"
   mon_time_null = nullind(m.timestamp), last_anal_null = nullind(d.last_analyzed)
   FROM (value(concat("DBA_TABLES@",dm2_compare_rec->src_data_link)) d),
    (value(concat("ALL_TAB_MODIFICATIONS@",dm2_compare_rec->src_data_link)) m)
   WHERE outerjoin(concat(d.owner,".",d.table_name))=concat(m.table_owner,".",m.table_name)
    AND expand(dvd_cnt,1,dmr_user_list->cnt,trim(d.owner),dmr_user_list->qual[dvd_cnt].user)
   ORDER BY d.table_name
   DETAIL
    IF (locateval(dvd_tbl_ndx,1,dm2_compare_rec->tbl_cnt,d.owner,dm2_compare_rec->tab[dvd_tbl_ndx].
     owner,
     d.table_name,dm2_compare_rec->tab[dvd_tbl_ndx].table_name) > 0)
     dm2_compare_rec->tab[dvd_tbl_ndx].tbl_monitoring = evaluate(d.monitoring,"YES",1,0),
     dm2_compare_rec->tab[dvd_tbl_ndx].last_analyzed = evaluate(last_anal_null,1,0.0,d.last_analyzed),
     dm2_compare_rec->tab[dvd_tbl_ndx].ora_mod_dt = evaluate(mon_time_null,1,0.0,m.timestamp)
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Gather last checkpoint for tables from TARGET"
  SELECT INTO "nl:"
   FROM dm_info di,
    (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (di
    WHERE di.info_domain="DM2MIGC-TBLCHKPT"
     AND di.info_name=concat(dm2_compare_rec->tab[d.seq].owner,".",dm2_compare_rec->tab[d.seq].
     table_name))
   DETAIL
    dm2_compare_rec->tab[d.seq].tbl_chkpt_dminfo_dt = di.info_date
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF ((dm_err->debug_flag > 2))
   CALL echorecord(dm2_compare_rec)
  ENDIF
  FOR (dvd_cnt = 1 TO dm2_compare_rec->tbl_cnt)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("TABLE:::",dvd_cnt,":::",dm2_compare_rec->tab[dvd_cnt].table_name))
    ENDIF
    IF ((((dm2_compare_rec->tab[dvd_cnt].ora_mod_dt > dm2_compare_rec->tab[dvd_cnt].
    tbl_chkpt_dminfo_dt)) OR ((dm2_compare_rec->tab[dvd_cnt].tbl_monitoring=0))) )
     SET dm2_compare_rec->tab[dvd_cnt].compare_table = 1
    ENDIF
    IF ((dm2_compare_rec->tab[dvd_cnt].tbl_chkpt_dminfo_dt=0)
     AND (dm2_compare_rec->tab[dvd_cnt].compare_table=0))
     IF ((dm2_compare_rec->tab[dvd_cnt].ora_mod_dt > dm2_compare_rec->chkpt_2_arch_dt))
      SET dm2_compare_rec->tab[dvd_cnt].compare_table = 1
     ENDIF
     IF ((dm2_compare_rec->tab[dvd_cnt].compare_table=0)
      AND (dm2_compare_rec->chkpt_2_arch_dt=0))
      IF ((dm2_compare_rec->tab[dvd_cnt].ora_mod_dt > dm2_compare_rec->chkpt_1_setup_dt))
       SET dm2_compare_rec->tab[dvd_cnt].compare_table = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((dm2_compare_rec->tab[dvd_cnt].compare_table=0))
     IF ((dm2_compare_rec->tab[dvd_cnt].last_analyzed > dm2_compare_rec->tab[dvd_cnt].
     tbl_chkpt_dminfo_dt))
      SET dm2_compare_rec->tab[dvd_cnt].compare_table = 1
     ENDIF
    ENDIF
    IF ((dm2_compare_rec->tab[dvd_cnt].compare_table=0))
     IF ((dm2_compare_rec->tab[dvd_cnt].last_analyzed > dm2_compare_rec->chkpt_2_arch_dt)
      AND (dm2_compare_rec->tab[dvd_cnt].tbl_chkpt_dminfo_dt=0))
      SET dm2_compare_rec->tab[dvd_cnt].compare_table = 1
     ENDIF
    ENDIF
    IF ((dm2_compare_rec->tab[dvd_cnt].compare_table=0))
     IF ((dm2_compare_rec->tab[dvd_cnt].last_analyzed > dm2_compare_rec->chkpt_1_setup_dt)
      AND (dm2_compare_rec->tab[dvd_cnt].tbl_chkpt_dminfo_dt=0)
      AND (dm2_compare_rec->chkpt_2_arch_dt=0))
      SET dm2_compare_rec->tab[dvd_cnt].compare_table = 1
     ENDIF
    ENDIF
    IF ((dm2_compare_rec->tab[dvd_cnt].compare_table=0))
     IF ((dm2_compare_rec->tab[dvd_cnt].last_analyzed=0)
      AND (dm2_compare_rec->tab[dvd_cnt].tbl_chkpt_dminfo_dt=0)
      AND (dm2_compare_rec->tab[dvd_cnt].ora_mod_dt=0)
      AND (((dm2_compare_rec->chkpt_1_setup_dt > 0)) OR ((dm2_compare_rec->chkpt_2_arch_dt > 0))) )
      SET dm2_compare_rec->tab[dvd_cnt].compare_table = 1
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF ((dm_err->debug_flag > 2))
  CALL echorecord(dm2_compare_rec)
 ENDIF
 IF (dvd_non_v500_tab_ind=1)
  IF (dcd_validate_uniqueidx(0) <= 0)
   GO TO exit_script
  ENDIF
  SET dm2_compare_rec->v500_views_ind = 0
  IF (dcd_generate_mig_views(null) <= 0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET dm2_compare_rec->max_mm_rows = 0
 IF (dvd_retry_ind)
  FOR (iter = 1 TO dm2_compare_rec->tbl_cnt)
    IF ((dm2_compare_rec->tab[iter].owner != "V500"))
     SET dvd_src_view_name = dm2_compare_rec->tab[iter].src_view_name
     SET dvd_tgt_view_name = dm2_compare_rec->tab[iter].tgt_view_name
    ELSE
     SET dvd_src_view_name = build(dm2_compare_rec->tab[iter].table_name,"@",dvd_dblink)
     SET dvd_tgt_view_name = dm2_compare_rec->tab[iter].table_name
    ENDIF
    SET dvd_key_column = dm2_compare_rec->tab[iter].chosen_key_column
    SET dm_err->eproc = "Building where clause from dba_tab_columns@link."
    SELECT INTO "nl:"
     FROM dba_tab_columns dtc
     WHERE (dtc.table_name=dm2_compare_rec->tab[iter].table_name)
      AND (dtc.owner=dm2_compare_rec->tab[iter].owner)
      AND  NOT (dtc.data_type IN ("LONG", "CLOB", "BLOB", "LONG RAW", "RAW"))
     HEAD REPORT
      predicate_cnt = 0, filler_var = "xxxxxxxxxxxxx", dvd_whereclause = "("
     DETAIL
      predicate_cnt = (predicate_cnt+ 1)
      IF (predicate_cnt > 1)
       dvd_whereclause = concat(dvd_whereclause," OR")
      ENDIF
      IF (dtc.data_type IN ("NUMBER", "FLOAT"))
       filler_var = "0.0"
      ELSEIF (dtc.data_type="DATE")
       filler_var = "'01-JAN-1800'"
      ELSE
       filler_var = "'0'"
      ENDIF
      dvd_whereclause = concat(dvd_whereclause," nvl(a.",trim(dtc.column_name),", ",trim(filler_var),
       ")!=nvl(b.",trim(dtc.column_name),", ",trim(filler_var),")")
     FOOT REPORT
      dvd_whereclause = concat(dvd_whereclause,")")
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    SET dvd_bottom_window_ptr = dm2_compare_rec->tab[iter].bottom_ptr
    SET dvd_top_window_ptr = dm2_compare_rec->tab[iter].top_ptr
    SET dm_err->eproc =
    "Querying for update mismatches between source and target for existing known mismatches."
    SELECT INTO "nl:"
     x = parser(concat("a.",dvd_key_column))
     FROM (value(dvd_tgt_view_name) a),
      (value(dvd_src_view_name) b)
     WHERE parser(concat("a.",dvd_key_column)) BETWEEN dvd_bottom_window_ptr AND dvd_top_window_ptr
      AND parser(concat("b.",dvd_key_column)) BETWEEN dvd_bottom_window_ptr AND dvd_top_window_ptr
      AND parser(concat("a.",dvd_key_column))=parser(concat("b.",dvd_key_column))
      AND sqlpassthru(dvd_whereclause)
     ORDER BY x
     HEAD REPORT
      fnd = 0, start = 1
     DETAIL
      IF (assign(fnd,locateval(fnd,start,dm2_compare_rec->tab[iter].row_cnt,cnvtreal(x),
        dm2_compare_rec->tab[iter].rows[fnd].unique_id)))
       start = (fnd+ 1), dm2_compare_rec->tab[iter].rows[fnd].match_ind = 0, dm2_compare_rec->tab[
       iter].match_row_cnt = (dm2_compare_rec->tab[iter].match_row_cnt - 1)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    SET dvd_create_view_stmt = concat("RDB CREATE OR REPLACE VIEW DM2MIG_VALIDATE_DATA AS",
     " (SELECT ",dvd_key_column," AS UNIQUE_ID FROM ",dvd_src_view_name,
     " MINUS SELECT ",dvd_key_column," FROM ",dvd_tgt_view_name,")",
     " UNION "," (SELECT ",dvd_key_column," AS UNIQUE_ID FROM ",dvd_tgt_view_name,
     " MINUS SELECT ",dvd_key_column," FROM ",dvd_src_view_name,") GO")
    IF ( NOT (dm2_push_cmd(dvd_create_view_stmt,1)))
     GO TO exit_script
    ENDIF
    SET dm_err->eproc =
    "Querying for insert/delete mismatches between source and target for existing known mismatches."
    SELECT INTO "nl:"
     x = unique_id
     FROM dm2mig_validate_data
     WHERE unique_id BETWEEN dvd_bottom_window_ptr AND dvd_top_window_ptr
     ORDER BY x
     HEAD REPORT
      fnd = 0, start = 1
     DETAIL
      IF (assign(fnd,locateval(fnd,start,dm2_compare_rec->tab[iter].row_cnt,x,dm2_compare_rec->tab[
        iter].rows[fnd].unique_id)))
       start = (fnd+ 1), dm2_compare_rec->tab[iter].rows[fnd].match_ind = 0, dm2_compare_rec->tab[
       iter].match_row_cnt = (dm2_compare_rec->tab[iter].match_row_cnt - 1)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    IF ((dm2_compare_rec->tab[iter].match_row_cnt=dm2_compare_rec->tab[iter].row_cnt))
     SET dm2_compare_rec->max_mm_rows = (dm2_compare_rec->max_mm_rows+ 1)
    ENDIF
    SET dm2_compare_rec->tab[iter].curr_mm_cnt = dm2_compare_rec->tab[iter].match_row_cnt
    SET dm2_compare_rec->tab[iter].cmp_cnt = dm2_compare_rec->tab[iter].row_cnt
    SET dm2_compare_rec->tab[iter].keycol_cnt = 1
  ENDFOR
 ELSE
  FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
    IF ((dm2_compare_rec->tab[i].compare_table=1))
     SET dm_err->eproc = concat("Getting unique key column for ",dm2_compare_rec->tab[i].owner,".",
      dm2_compare_rec->tab[i].table_name)
     SELECT INTO "nl:"
      FROM dba_tab_columns dtc
      WHERE (dtc.table_name=dm2_compare_rec->tab[i].table_name)
       AND (dtc.owner=dm2_compare_rec->tab[i].owner)
       AND dtc.data_type IN ("NUMBER", "FLOAT")
       AND dtc.column_name IN (
      (SELECT
       dic.column_name
       FROM dba_ind_columns dic
       WHERE (dic.table_name=dm2_compare_rec->tab[i].table_name)
        AND (dic.table_owner=dm2_compare_rec->tab[i].owner)
        AND dic.index_name IN (
       (SELECT
        di.index_name
        FROM dba_indexes di
        WHERE (di.table_name=dm2_compare_rec->tab[i].table_name)
         AND (di.owner=dm2_compare_rec->tab[i].owner)
         AND di.uniqueness="UNIQUE"
         AND  NOT ( EXISTS (
        (SELECT
         1
         FROM dba_ind_columns dic2
         WHERE (dic2.table_name=dm2_compare_rec->tab[i].table_name)
          AND (dic2.table_owner=dm2_compare_rec->tab[i].owner)
          AND dic2.index_name=di.index_name
          AND dic2.column_position >= 2)))))))
      HEAD REPORT
       dvd_key_column = dtc.column_name, tmp = 0
      DETAIL
       tmp = (tmp+ 1)
      FOOT REPORT
       IF (tmp=1)
        dm2_compare_rec->tab[i].keycol_cnt = 1
       ENDIF
      WITH nocounter, maxqual(dtc,1)
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      GO TO exit_script
     ENDIF
     IF ((dm2_compare_rec->tab[i].keycol_cnt=1))
      SET dm_err->eproc = concat("Building where clause for ",dm2_compare_rec->tab[i].owner,".",
       dm2_compare_rec->tab[i].table_name)
      SET dvd_whereclause = " "
      SELECT INTO "nl:"
       FROM dba_tab_columns dtc
       WHERE (dtc.table_name=dm2_compare_rec->tab[i].table_name)
        AND (dtc.owner=dm2_compare_rec->tab[i].owner)
        AND  NOT (dtc.data_type IN ("LONG", "CLOB", "BLOB", "LONG RAW", "RAW"))
       HEAD REPORT
        predicate_cnt = 0, filler_var = "xxxxxxxxxxxxx", dvd_whereclause = "("
       DETAIL
        predicate_cnt = (predicate_cnt+ 1)
        IF (predicate_cnt > 1)
         dvd_whereclause = concat(dvd_whereclause," OR")
        ENDIF
        IF (dtc.data_type IN ("NUMBER", "FLOAT"))
         filler_var = "0.0"
        ELSEIF (dtc.data_type="DATE")
         filler_var = "'01-JAN-1800'"
        ELSE
         filler_var = "'0'"
        ENDIF
        dvd_whereclause = concat(dvd_whereclause," nvl(a.",trim(dtc.column_name),", ",trim(filler_var
          ),
         ")!=nvl(b.",trim(dtc.column_name),", ",trim(filler_var),")")
       FOOT REPORT
        dvd_whereclause = concat(dvd_whereclause,")")
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) != 0)
       GO TO exit_script
      ENDIF
      IF ((dm2_compare_rec->tab[i].owner != "V500"))
       SET dvd_src_view_name = dm2_compare_rec->tab[i].src_view_name
       SET dvd_tgt_view_name = dm2_compare_rec->tab[i].tgt_view_name
      ELSE
       SET dvd_src_view_name = concat(trim(dm2_compare_rec->tab[i].table_name),"@",dvd_dblink)
       SET dvd_tgt_view_name = dm2_compare_rec->tab[i].table_name
      ENDIF
      SET dm2_compare_rec->tab[i].chosen_key_column = dvd_key_column
      SET dm_err->eproc = concat("Identifying key_id for ",dm2_compare_rec->tab[i].owner,".",
       dm2_compare_rec->tab[i].table_name)
      SELECT INTO "nl:"
       x = parser(concat("min(b.",dvd_key_column,")")), y = parser(concat("max(b.",dvd_key_column,")"
         )), z = count(1)
       FROM (
        (
        (SELECT
         parser(concat("a.",dvd_key_column))
         FROM (value(dvd_src_view_name) a)
         WHERE parser(concat("a.",dvd_key_column)) IS NOT null
         ORDER BY parser(concat("a.",dvd_key_column)) DESC
         WITH sqltype("F8")))
        b)
       WHERE sqlpassthru(build("rownum<=",dvd_rows_to_compare))
       DETAIL
        dvd_bottom_window_ptr = x, dvd_top_window_ptr = y, dm2_compare_rec->tab[i].cmp_cnt = z
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_script
      ENDIF
      SET dm_err->eproc = concat("Matching source to target for ",dm2_compare_rec->tab[i].owner,".",
       dm2_compare_rec->tab[i].table_name)
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
      SET dm_err->eproc = "Querying for update mismatches between source and target."
      SELECT INTO "nl:"
       x = parser(concat("a.",dvd_key_column))
       FROM (value(dvd_tgt_view_name) a),
        (value(dvd_src_view_name) b)
       WHERE parser(concat("a.",dvd_key_column)) BETWEEN dvd_bottom_window_ptr AND dvd_top_window_ptr
        AND parser(concat("b.",dvd_key_column)) BETWEEN dvd_bottom_window_ptr AND dvd_top_window_ptr
        AND parser(concat("a.",dvd_key_column))=parser(concat("b.",dvd_key_column))
        AND sqlpassthru(dvd_whereclause)
       DETAIL
        dm2_compare_rec->tab[i].row_cnt = (dm2_compare_rec->tab[i].row_cnt+ 1)
        IF (mod(dm2_compare_rec->tab[i].row_cnt,500)=1)
         stat = alterlist(dm2_compare_rec->tab[i].rows,(dm2_compare_rec->tab[i].row_cnt+ 499))
        ENDIF
        dm2_compare_rec->tab[i].rows[dm2_compare_rec->tab[i].row_cnt].unique_id = x
       FOOT REPORT
        dm2_compare_rec->max_row_cnt = greatest(dm2_compare_rec->max_row_cnt,dm2_compare_rec->tab[i].
         row_cnt), dm2_compare_rec->total_row_cnt = (dm2_compare_rec->total_row_cnt+ dm2_compare_rec
        ->tab[i].row_cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_script
      ENDIF
      SET dvd_create_view_stmt = concat("RDB CREATE OR REPLACE VIEW DM2MIG_VALIDATE_DATA AS",
       " (SELECT ",dvd_key_column," AS UNIQUE_ID FROM ",dvd_src_view_name,
       " MINUS SELECT ",dvd_key_column," FROM ",dvd_tgt_view_name,")",
       " UNION "," (SELECT ",dvd_key_column," AS UNIQUE_ID FROM ",dvd_tgt_view_name,
       " MINUS SELECT ",dvd_key_column," FROM ",dvd_src_view_name,") GO")
      IF ( NOT (dm2_push_cmd(dvd_create_view_stmt,1)))
       GO TO exit_script
      ENDIF
      SET dm_err->eproc =
      "Querying for insert mismatches between source and target for existing known mismatches."
      SELECT INTO "nl:"
       x = unique_id
       FROM dm2mig_validate_data
       WHERE unique_id BETWEEN dvd_bottom_window_ptr AND dvd_top_window_ptr
       DETAIL
        dm2_compare_rec->tab[i].row_cnt = (dm2_compare_rec->tab[i].row_cnt+ 1)
        IF (mod(dm2_compare_rec->tab[i].row_cnt,500)=1)
         stat = alterlist(dm2_compare_rec->tab[i].rows,(dm2_compare_rec->tab[i].row_cnt+ 499))
        ENDIF
        dm2_compare_rec->tab[i].rows[dm2_compare_rec->tab[i].row_cnt].unique_id = x
       FOOT REPORT
        dm2_compare_rec->max_row_cnt = greatest(dm2_compare_rec->max_row_cnt,dm2_compare_rec->tab[i].
         row_cnt), dm2_compare_rec->total_row_cnt = (dm2_compare_rec->total_row_cnt+ dm2_compare_rec
        ->tab[i].row_cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_script
      ENDIF
      SET stat = alterlist(dm2_compare_rec->tab[i].rows,dm2_compare_rec->tab[i].row_cnt)
      SET dm2_compare_rec->tab[i].curr_mm_cnt = abs((dm2_compare_rec->tab[i].cmp_cnt -
       dm2_compare_rec->tab[i].row_cnt))
      IF ((dm2_compare_rec->tab[i].row_cnt=0))
       SET dm2_compare_rec->max_mm_rows = (dm2_compare_rec->max_mm_rows+ 1)
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (dvd_retry_ind)
  SET dm_err->eproc = "Deleting data about matches from dm_info."
  DELETE  FROM dm_info di,
    (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt)),
    (dummyt d2  WITH seq = value(dm2_compare_rec->max_row_cnt))
   SET di.seq = 0
   PLAN (d
    WHERE (dm2_compare_rec->tbl_cnt > 0))
    JOIN (d2
    WHERE (d2.seq <= dm2_compare_rec->tab[d.seq].row_cnt)
     AND (dm2_compare_rec->tab[d.seq].rows[d2.seq].match_ind=1))
    JOIN (di
    WHERE di.info_domain="DM2_MIG_MISMATCH"
     AND di.info_name=concat(dm2_compare_rec->tab[d.seq].owner,".",dm2_compare_rec->tab[d.seq].
     table_name,":",dm2_compare_rec->tab[d.seq].chosen_key_column,
     ":",trim(cnvtstring(dm2_compare_rec->tab[d.seq].rows[d2.seq].unique_id,20))))
   WITH nocounter, maxcommit = 10000
  ;end delete
  IF (check_error(dm_err->eproc))
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  COMMIT
  SET dm_err->eproc = "Updating data about mismatches in dm_info."
  UPDATE  FROM dm_info di,
    (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt)),
    (dummyt d2  WITH seq = value(dm2_compare_rec->max_row_cnt))
   SET di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (dm2_compare_rec->tbl_cnt > 0))
    JOIN (d2
    WHERE (d2.seq <= dm2_compare_rec->tab[d.seq].row_cnt)
     AND (dm2_compare_rec->tab[d.seq].rows[d2.seq].match_ind=0))
    JOIN (di
    WHERE di.info_domain="DM2_MIG_MISMATCH"
     AND di.info_name=concat(dm2_compare_rec->tab[d.seq].owner,".",dm2_compare_rec->tab[d.seq].
     table_name,":",dm2_compare_rec->tab[d.seq].chosen_key_column,
     ":",trim(cnvtstring(dm2_compare_rec->tab[d.seq].rows[d2.seq].unique_id,20))))
   WITH nocounter, maxcommit = 10000
  ;end update
  IF (check_error(dm_err->eproc))
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  COMMIT
 ELSE
  SET dm_err->eproc = "Determining if sufficient free space exists from dba_free_space."
  SELECT INTO "nl:"
   b = sum(dfs.bytes)
   FROM dba_free_space dfs
   WHERE (dfs.tablespace_name=
   (SELECT
    tablespace_name
    FROM user_tables
    WHERE table_name="DM_INFO"))
   DETAIL
    IF ((b < (((dm2_compare_rec->total_row_cnt * ((((3+ 5)+ 22)+ 30)+ 10)) * 1.10) * 1.10)))
     dm_err->err_ind = 1, dm_err->emsg =
     "Not enough free space exists to store data about mismatched rows in dm_info."
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Inserting data about mismatches into dm_info."
  INSERT  FROM dm_info di,
    (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt)),
    (dummyt d2  WITH seq = value(dm2_compare_rec->max_row_cnt))
   SET di.info_domain = "DM2_MIG_MISMATCH", di.info_name = concat(dm2_compare_rec->tab[d.seq].owner,
     ".",dm2_compare_rec->tab[d.seq].table_name,":",dm2_compare_rec->tab[d.seq].chosen_key_column,
     ":",trim(cnvtstring(dm2_compare_rec->tab[d.seq].rows[d2.seq].unique_id,20))), di.info_date =
    cnvtdatetime(curdate,curtime3),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (dm2_compare_rec->tbl_cnt > 0))
    JOIN (d2
    WHERE (d2.seq <= dm2_compare_rec->tab[d.seq].row_cnt))
    JOIN (di)
   WITH nocounter, maxcommit = 10000
  ;end insert
  IF (check_error(dm_err->eproc))
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  COMMIT
  SET dm_err->eproc = "Remove existing compare date times from dm_info"
  DELETE  FROM dm_info di,
    (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt))
   SET di.seq = 0
   PLAN (d
    WHERE d.seq > 0
     AND (dm2_compare_rec->tab[d.seq].compare_table=1))
    JOIN (di
    WHERE di.info_domain="DM2MIGC-TBLCHKPT"
     AND di.info_name=concat(dm2_compare_rec->tab[d.seq].owner,".",dm2_compare_rec->tab[d.seq].
     table_name))
   WITH nocounter, maxcommit = 10000
  ;end delete
  IF (check_error(dm_err->eproc))
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  COMMIT
  SET dm_err->eproc = "Insert compare date times into dm_info"
  INSERT  FROM dm_info di,
    (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt))
   SET di.info_domain = "DM2MIGC-TBLCHKPT", di.info_name = concat(dm2_compare_rec->tab[d.seq].owner,
     ".",dm2_compare_rec->tab[d.seq].table_name), di.info_date = cnvtdatetime(greatest(
      dm2_compare_rec->tab[d.seq].ora_mod_dt,dm2_compare_rec->tab[d.seq].last_analyzed))
   PLAN (d
    WHERE d.seq > 0
     AND (dm2_compare_rec->tab[d.seq].compare_table=1)
     AND (dm2_compare_rec->tab[d.seq].keycol_cnt=1)
     AND (dm2_compare_rec->tab[d.seq].table_exists_ind=1)
     AND (dm2_compare_rec->tab[d.seq].curr_mm_cnt=dm2_compare_rec->tab[d.seq].cmp_cnt))
    JOIN (di)
   WITH nocounter, maxcommit = 10000
  ;end insert
  IF (check_error(dm_err->eproc))
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SET dm_err->eproc = "Generating report"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO mine
  FROM dummyt d
  HEAD REPORT
   "--------------------------------------------------------------------------------------", row + 1,
   "Table Validation Report",
   row + 1, "--------------------------------------------------------------------------------------",
   row + 2,
   "Row matching was performed for tables between:", row + 1,
   CALL print(concat("  Source Database: ",dvd_remote_db_name,"@",dvd_dblink)),
   row + 1,
   CALL print(concat("  Target Database: ",dvd_database_name)), row + 2
   IF ( NOT (dvd_retry_ind))
    CALL print(concat("The most recent ",trim(cnvtstring(dvd_rows_to_compare)),
     " rows in each of the tables were matched.")), row + 2
   ENDIF
  DETAIL
   IF ((dm2_compare_rec->max_mm_rows=dm2_compare_rec->tbl_cnt))
    "Validation summary: All tables matched.", row + 1
   ELSE
    dvd_cnt = 0
    FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
      IF ((((dm2_compare_rec->tab[i].curr_mm_cnt != dm2_compare_rec->tab[i].cmp_cnt)) OR ((
      dm2_compare_rec->tab[i].keycol_cnt=0)
       AND (dm2_compare_rec->tab[i].compare_table=1))) )
       dvd_cnt = (dvd_cnt+ 1)
       IF (dvd_cnt=1)
        "Validation summary: Table mismatches found.", row + 1,
        "Following is a list of tables which did not match, or could not be checked:",
        row + 1, row + 1, col 0,
        "OWNER", col 32, "| TABLE NAME",
        col 66, "| ROWS COMPARED", col 82,
        "| ROWS MATCHED", col 97, "| PCT MATCH",
        col 113, "| COMMENTS", row + 1
       ENDIF
       col 0, dm2_compare_rec->tab[i].owner, col 32,
       "| ", dm2_compare_rec->tab[i].table_name, col 66,
       "| ",
       CALL print(format(dm2_compare_rec->tab[i].cmp_cnt,";L")), col 82,
       "| ",
       CALL print(format(dm2_compare_rec->tab[i].curr_mm_cnt,";L")), col 97,
       "| ",
       CALL print(format(((cnvtreal(dm2_compare_rec->tab[i].curr_mm_cnt)/ cnvtreal(dm2_compare_rec->
         tab[i].cmp_cnt)) * 100),"###.#;T(2)L")), col 113,
       "| "
       IF ((dm2_compare_rec->tab[i].table_exists_ind=0))
        "Table not found"
       ELSEIF ((dm2_compare_rec->tab[i].keycol_cnt=0))
        "No single column numeric key"
       ENDIF
       row + 1
      ENDIF
    ENDFOR
   ENDIF
   row + 1
   IF ((dm2_compare_rec->max_mm_rows > 0))
    "-----------------------------------------------------------------------------------", row + 1,
    "Following is a list of tables which matched:",
    row + 1, row + 1, col 0,
    "OWNER", col 32, "| TABLE NAME",
    col 66, "| ROWS COMPARED", col 82,
    "| ROWS MATCHED", col 97, "| PCT MATCH",
    row + 1
    FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
      IF ((dm2_compare_rec->tab[i].curr_mm_cnt=dm2_compare_rec->tab[i].cmp_cnt)
       AND (dm2_compare_rec->tab[i].keycol_cnt=1)
       AND (dm2_compare_rec->tab[i].compare_table=1))
       col 0, dm2_compare_rec->tab[i].owner, col 32,
       "| ", dm2_compare_rec->tab[i].table_name, col 66,
       "| ",
       CALL print(format(dm2_compare_rec->tab[i].cmp_cnt,";L")), col 82,
       "| ",
       CALL print(format(dm2_compare_rec->tab[i].curr_mm_cnt,";L")), col 97,
       "| 100", row + 1
      ENDIF
    ENDFOR
   ENDIF
   IF (dvd_retry_ind=0
    AND (dm2_compare_rec->tbl_cnt > 0))
    dvd_cnt = 0
    FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
      IF ((dm2_compare_rec->tab[i].compare_table=0)
       AND (dm2_compare_rec->tab[i].tbl_chkpt_dminfo_dt > 0))
       dvd_cnt = (dvd_cnt+ 1)
       IF (dvd_cnt=1)
        row + 1,
        "-----------------------------------------------------------------------------------", row +
        1,
        "Following is a list of tables not compared (no DML occurred on Source table since last successful compare):",
        row + 1, row + 1,
        col 0, "OWNER", col 32,
        "| TABLE NAME", col 66, "| LAST COMPARE_DT_TM",
        col 86, "| LAST_SRC_MOD_DT_TM", row + 1
       ENDIF
       col 0, dm2_compare_rec->tab[i].owner, col 32,
       "| ", dm2_compare_rec->tab[i].table_name, col 66,
       "| ",
       CALL print(format(cnvtdatetime(dm2_compare_rec->tab[i].tbl_chkpt_dminfo_dt),cclfmt->
        shortdatetime)), dvd_greatest = greatest(dm2_compare_rec->tab[i].ora_mod_dt,dm2_compare_rec->
        tab[i].last_analyzed),
       dvd_greatest = greatest(dvd_greatest,dm2_compare_rec->chkpt_2_arch_dt), dvd_greatest =
       greatest(dvd_greatest,dm2_compare_rec->chkpt_1_setup_dt), col 86,
       "| ",
       CALL print(format(dvd_greatest,cclfmt->shortdatetime)), row + 1
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter, maxcol = 200
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dm_err->debug_flag > 2))
  CALL echorecord(dm2_compare_rec)
 ENDIF
 GO TO exit_script
#exit_script
 IF ((dm_err->debug_flag > 2))
  CALL echorecord(dm2_compare_rec)
 ENDIF
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Dm2_validate_data completed succesfully."
 ELSE
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 CALL final_disp_msg("dm2_validate_data")
END GO
