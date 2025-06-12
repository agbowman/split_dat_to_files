CREATE PROGRAM dm2_rdds_event_copy:dba
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
 DECLARE drec_src_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drec_tgt_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drec_open_event = vc WITH noconstant(" ")
 DECLARE drec_cp_open_ind = i2 WITH noconstant(0)
 DECLARE drec_i = i4 WITH noconstant(0)
 DECLARE drec_event_id = f8 WITH noconstant(0.0)
 DECLARE new_list_size = i4 WITH protect, noconstant(0)
 DECLARE cur_list_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE event_copy_cnt = i4 WITH protect, noconstant(0)
 DECLARE event_detail_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD drec_r_tabs
 RECORD drec_r_tabs(
   1 r_tab_cnt = i4
   1 qual[*]
     2 r_tab = vc
 )
 FREE RECORD event_copy
 RECORD event_copy(
   1 qual[*]
     2 old_dm_rdds_event_log_id = f8
     2 new_dm_rdds_event_log_id = f8
     2 details[*]
       3 dm_rdds_event_log_id = f8
       3 event_detail1_txt = vc
       3 event_detail2_txt = vc
       3 event_detail3_txt = vc
       3 event_detail_value = f8
       3 updt_id = f8
       3 updt_dt_tm = dq8
       3 updt_task = i4
       3 updt_applctx = f8
       3 updt_cnt = i4
     2 rdds_event = vc
     2 event_dt_tm = dq8
     2 cur_environment_id = f8
     2 paired_environment_id = f8
     2 event_reason = vc
     2 osuser = vc
     2 machine = vc
     2 terminal = vc
     2 module = vc
     2 program_name = vc
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
     2 rdds_event_key = vc
 )
 IF (check_logfile("dm2_rdds_event_copy",".log","dm2_rdds_event_copy")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning dm2_rdds_event_copy"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET drec_src_env_id =  $1
 SET drec_tgt_env_id =  $2
 SET dm_err->eproc = "Gather event rows"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  x = seq(dm_seq,nextval), d1.dm_rdds_event_log_id, d1.rdds_event,
  d1.event_dt_tm, d1.paired_environment_id, y = concat("Replicate Copy - Source ID: ",trim(cnvtstring
    (drec_src_env_id,20),3)),
  d1.osuser, d1.machine, d1.terminal,
  d1.module, d1.program, d1.updt_id,
  d1.updt_dt_tm, d1.updt_task, d1.updt_cnt,
  d1.rdds_event_key
  FROM dm_rdds_event_log d1
  WHERE d1.cur_environment_id=drec_src_env_id
   AND list(d1.rdds_event_key,d1.event_dt_tm) IN (
  (SELECT
   d2.rdds_event_key, event_dt_tm = max(d2.event_dt_tm)
   FROM dm_rdds_event_log d2,
    dm_info di
   WHERE di.info_domain="RDDS EVENT REPLICATE"
    AND d2.rdds_event_key=di.info_name
    AND d2.cur_environment_id=drec_src_env_id
   GROUP BY d2.rdds_event_key))
  HEAD REPORT
   event_copy_cnt = 0
  DETAIL
   event_copy_cnt = (event_copy_cnt+ 1)
   IF (mod(event_copy_cnt,10)=1)
    stat = alterlist(event_copy->qual,(event_copy_cnt+ 9))
   ENDIF
   event_copy->qual[event_copy_cnt].new_dm_rdds_event_log_id = cnvtreal(x), event_copy->qual[
   event_copy_cnt].old_dm_rdds_event_log_id = d1.dm_rdds_event_log_id, event_copy->qual[
   event_copy_cnt].rdds_event = d1.rdds_event,
   event_copy->qual[event_copy_cnt].event_dt_tm = cnvtdatetime(d1.event_dt_tm), event_copy->qual[
   event_copy_cnt].cur_environment_id = drec_tgt_env_id, event_copy->qual[event_copy_cnt].
   paired_environment_id = d1.paired_environment_id,
   event_copy->qual[event_copy_cnt].event_reason = y, event_copy->qual[event_copy_cnt].osuser = d1
   .osuser, event_copy->qual[event_copy_cnt].machine = d1.machine,
   event_copy->qual[event_copy_cnt].terminal = d1.terminal, event_copy->qual[event_copy_cnt].module
    = d1.module, event_copy->qual[event_copy_cnt].program_name = d1.program,
   event_copy->qual[event_copy_cnt].updt_id = d1.updt_id, event_copy->qual[event_copy_cnt].updt_dt_tm
    = cnvtdatetime(d1.updt_dt_tm), event_copy->qual[event_copy_cnt].updt_task = d1.updt_task,
   event_copy->qual[event_copy_cnt].updt_cnt = d1.updt_cnt, event_copy->qual[event_copy_cnt].
   rdds_event_key = d1.rdds_event_key
  WITH nocounter
 ;end select
 IF (check_error("Gather the source event rows for copy to target environment") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (event_copy_cnt > 0)
  SET dm_err->eproc = "Insert event rows"
  CALL disp_msg(" ",dm_err->logfile,0)
  INSERT  FROM dm_rdds_event_log drel,
    (dummyt d  WITH seq = value(event_copy_cnt))
   SET drel.dm_rdds_event_log_id = event_copy->qual[d.seq].new_dm_rdds_event_log_id, drel.rdds_event
     = event_copy->qual[d.seq].rdds_event, drel.event_dt_tm = cnvtdatetime(event_copy->qual[d.seq].
     event_dt_tm),
    drel.cur_environment_id = event_copy->qual[d.seq].cur_environment_id, drel.paired_environment_id
     = event_copy->qual[d.seq].paired_environment_id, drel.event_reason = event_copy->qual[d.seq].
    event_reason,
    drel.osuser = event_copy->qual[d.seq].osuser, drel.machine = event_copy->qual[d.seq].machine,
    drel.terminal = event_copy->qual[d.seq].terminal,
    drel.module = event_copy->qual[d.seq].module, drel.program = event_copy->qual[d.seq].program_name,
    drel.updt_id = event_copy->qual[d.seq].updt_id,
    drel.updt_dt_tm = cnvtdatetime(event_copy->qual[d.seq].updt_dt_tm), drel.updt_task = event_copy->
    qual[d.seq].updt_task, drel.updt_cnt = event_copy->qual[d.seq].updt_cnt,
    drel.rdds_event_key = event_copy->qual[d.seq].rdds_event_key
   PLAN (d)
    JOIN (drel)
   WITH nocounter
  ;end insert
  IF (check_error("Insert the source event rows for copy to target environment") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = "Gather event detail rows"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET cur_list_size = size(event_copy->qual,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(event_copy->qual,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET event_copy->qual[idx].old_dm_rdds_event_log_id = event_copy->qual[cur_list_size].
    old_dm_rdds_event_log_id
  ENDFOR
  SELECT INTO "NL:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    dm_rdds_event_detail d
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (d
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),d.dm_rdds_event_log_id,event_copy->qual[idx].
     old_dm_rdds_event_log_id))
   HEAD REPORT
    num1 = 0, event_detail_cnt = 0
   DETAIL
    IF (d.event_detail1_txt > "")
     index = locateval(num1,1,cur_list_size,d.dm_rdds_event_log_id,event_copy->qual[num1].
      old_dm_rdds_event_log_id)
     WHILE (index != 0)
       event_detail_cnt = (size(event_copy->qual[index].details,5)+ 1), stat = alterlist(event_copy->
        qual[index].details,event_detail_cnt), event_copy->qual[index].details[event_detail_cnt].
       dm_rdds_event_log_id = event_copy->qual[index].new_dm_rdds_event_log_id,
       event_copy->qual[index].details[event_detail_cnt].event_detail1_txt = d.event_detail1_txt,
       event_copy->qual[index].details[event_detail_cnt].event_detail2_txt = d.event_detail2_txt,
       event_copy->qual[index].details[event_detail_cnt].event_detail3_txt = d.event_detail3_txt,
       event_copy->qual[index].details[event_detail_cnt].event_detail_value = d.event_detail_value,
       event_copy->qual[index].details[event_detail_cnt].updt_id = d.updt_id, event_copy->qual[index]
       .details[event_detail_cnt].updt_task = d.updt_task,
       event_copy->qual[index].details[event_detail_cnt].updt_applctx = d.updt_applctx, event_copy->
       qual[index].details[event_detail_cnt].updt_cnt = d.updt_cnt, index = locateval(num1,(index+ 1),
        cur_list_size,d.dm_rdds_event_log_id,event_copy->qual[num1].old_dm_rdds_event_log_id)
     ENDWHILE
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error("Gather the source detail rows for copy to target environment") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET stat = alterlist(event_copy->qual,cur_list_size)
  FOR (i = 1 TO value(event_copy_cnt))
    IF (size(event_copy->qual[i].details,5) > 0)
     SET dm_err->eproc = "Insert detail rows"
     CALL disp_msg(" ",dm_err->logfile,0)
     INSERT  FROM dm_rdds_event_detail dred,
       (dummyt d  WITH seq = value(size(event_copy->qual[i].details,5)))
      SET dred.dm_rdds_event_detail_id = seq(dm_seq,nextval), dred.dm_rdds_event_log_id = event_copy
       ->qual[i].details[d.seq].dm_rdds_event_log_id, dred.event_detail1_txt = event_copy->qual[i].
       details[d.seq].event_detail1_txt,
       dred.event_detail2_txt = event_copy->qual[i].details[d.seq].event_detail2_txt, dred
       .event_detail3_txt = event_copy->qual[i].details[d.seq].event_detail3_txt, dred
       .event_detail_value = event_copy->qual[i].details[d.seq].event_detail_value,
       dred.updt_id = event_copy->qual[i].details[d.seq].updt_id, dred.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), dred.updt_task = event_copy->qual[i].details[d.seq].updt_task,
       dred.updt_applctx = event_copy->qual[i].details[d.seq].updt_applctx, dred.updt_cnt =
       event_copy->qual[i].details[d.seq].updt_cnt
      PLAN (d)
       JOIN (dred)
      WITH nocounter
     ;end insert
     IF (check_error("Insert the source detail rows for copy to target environment") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET drec_cp_open_ind = 0
 SELECT INTO "nl:"
  FROM dm_rdds_event_log d1
  WHERE d1.cur_environment_id=drec_src_env_id
   AND d1.rdds_event="Begin Reference Data Sync"
   AND d1.rdds_event_key="BEGINREFERENCEDATASYNC"
   AND  NOT (list(d1.cur_environment_id,d1.paired_environment_id,d1.event_reason) IN (
  (SELECT
   drela.cur_environment_id, drela.paired_environment_id, drela.event_reason
   FROM dm_rdds_event_log drela
   WHERE drela.cur_environment_id=drec_src_env_id
    AND drela.rdds_event="End Reference Data Sync"
    AND drela.rdds_event_key="ENDREFERENCEDATASYNC")))
  DETAIL
   drec_open_event = d1.event_reason, drec_event_id = d1.dm_rdds_event_log_id
  WITH nocounter
 ;end select
 IF (check_error("Find open event information.") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (drec_event_id > 0)
  SET drec_r_tabs->r_tab_cnt = 0
  SELECT INTO "nl:"
   FROM user_tables ut
   WHERE ut.table_name="*$R"
   DETAIL
    IF (((mod(drec_r_tabs->r_tab_cnt,20)=0) OR ((drec_r_tabs->r_tab_cnt=0))) )
     stat = alterlist(drec_r_tabs->qual,(drec_r_tabs->r_tab_cnt+ 20))
    ENDIF
    drec_r_tabs->r_tab_cnt = (drec_r_tabs->r_tab_cnt+ 1), drec_r_tabs->qual[drec_r_tabs->r_tab_cnt].
    r_tab = ut.table_name
   WITH nocounter
  ;end select
  IF (check_error("Find $R table names.") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF ((drec_r_tabs->r_tab_cnt > 0))
   SET stat = alterlist(drec_r_tabs->qual,drec_r_tabs->r_tab_cnt)
   FOR (drec_i = 1 TO drec_r_tabs->r_tab_cnt)
     SELECT INTO "nl:"
      FROM dtable d
      WHERE (d.table_name=drec_r_tabs->qual[drec_i].r_tab)
      WITH nocounter
     ;end select
     IF (check_error("Find $R table ccl definition.") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (curqual > 0)
      SELECT INTO "nl:"
       FROM (parser(drec_r_tabs->qual[drec_i].r_tab) r)
       WHERE r.rdds_status_flag < 9000
       WITH nocounter, maxqual(r,1)
      ;end select
      IF (check_error("Find uncutover $R rows.") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      IF (curqual > 0)
       SET drec_i = (drec_r_tabs->r_tab_cnt+ 1)
       SET drec_cp_open_ind = 1
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (drec_cp_open_ind=1)
  SET dm_err->eproc = "Gather and insert OPEN event row"
  CALL disp_msg(" ",dm_err->logfile,0)
  INSERT  FROM dm_rdds_event_log drel
   (drel.dm_rdds_event_log_id, drel.rdds_event, drel.event_dt_tm,
   drel.cur_environment_id, drel.paired_environment_id, drel.event_reason,
   drel.osuser, drel.machine, drel.terminal,
   drel.module, drel.program, drel.updt_id,
   drel.updt_dt_tm, drel.updt_task, drel.updt_cnt,
   drel.rdds_event_key)(SELECT
    seq(dm_seq,nextval), d1.rdds_event, d1.event_dt_tm,
    drec_tgt_env_id, d1.paired_environment_id, drec_open_event,
    d1.osuser, d1.machine, d1.terminal,
    d1.module, d1.program, d1.updt_id,
    d1.updt_dt_tm, d1.updt_task, d1.updt_cnt,
    d1.rdds_event_key
    FROM dm_rdds_event_log d1
    WHERE d1.cur_environment_id=drec_src_env_id
     AND d1.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND d1.event_reason=drec_open_event
     AND d1.dm_rdds_event_log_id=drec_event_id)
   WITH nocounter
  ;end insert
  IF (check_error("Copy the source open event row to target environment") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  INSERT  FROM dm_rdds_event_detail dred
   (dred.dm_rdds_event_detail_id, dred.dm_rdds_event_log_id, dred.event_detail1_txt,
   dred.updt_applctx, dred.updt_dt_tm, dred.updt_id,
   dred.updt_task, dred.updt_cnt)(SELECT
    seq(dm_seq,nextval), d1.dm_rdds_event_log_id, concat("Replicate Copy from: ",trim(cnvtstring(
       drec_src_env_id,20,0),3)),
    d1.updt_applctx, d1.updt_dt_tm, d1.updt_id,
    d1.updt_task, d1.updt_cnt
    FROM dm_rdds_event_log d1
    WHERE d1.cur_environment_id=drec_tgt_env_id
     AND d1.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND d1.event_reason=drec_open_event)
   WITH nocounter
  ;end insert
  IF (check_error("Copy the source open event detail rows to target environment") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
#exit_program
 IF ((dm_err->err_ind != 0))
  ROLLBACK
 ENDIF
 SET dm_err->eproc = "...Ending dm2_rdds_event_copy"
 CALL final_disp_msg("dm2_rdds_event_copy")
END GO
