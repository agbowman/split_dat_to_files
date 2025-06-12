CREATE PROGRAM dm_rmc_event_rpt:dba
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
 DECLARE parse_string(i_string=vc,i_string_delim=vc,io_string_rs=vc(ref)) = null
 DECLARE encode_html_string(io_string=vc) = vc
 DECLARE copy_xsl(i_template_name=vc,i_file_name=vc) = i2
 DECLARE dmda_get_file_name(i_env_id=f8,i_env_name=vc,i_mnu_hdg=vc,i_default_name=vc,i_file_xtn=vc,
  i_type=vc) = vc
 SUBROUTINE parse_string(i_string,i_string_delim,io_string_rs)
   DECLARE ps_delim_len = i4 WITH protect, noconstant(size(i_string_delim))
   DECLARE ps_str_len = i4 WITH protect, noconstant(size(i_string))
   DECLARE ps_start = i4 WITH protect, noconstant(1)
   DECLARE ps_pos = i4 WITH protect, noconstant(0)
   DECLARE ps_num_found = i4 WITH protect, noconstant(0)
   DECLARE ps_idx = i4 WITH protect, noconstant(0)
   DECLARE ps_loop = i4 WITH protect, noconstant(0)
   DECLARE ps_temp_string = vc WITH protect, noconstant("")
   SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   SET ps_num_found = size(io_string_rs->qual,5)
   WHILE (ps_pos > 0)
     SET ps_num_found = (ps_num_found+ 1)
     SET ps_temp_string = substring(ps_start,(ps_pos - ps_start),i_string)
     IF (ps_num_found > 1)
      SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
       values)
     ELSE
      SET ps_idx = 0
     ENDIF
     IF (ps_idx=0)
      SET stat = alterlist(io_string_rs->qual,ps_num_found)
      SET io_string_rs->qual[ps_num_found].values = ps_temp_string
     ELSE
      SET ps_num_found = (ps_num_found - 1)
     ENDIF
     SET ps_start = (ps_pos+ ps_delim_len)
     SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   ENDWHILE
   IF (ps_start <= ps_str_len)
    SET ps_num_found = (ps_num_found+ 1)
    SET ps_temp_string = substring(ps_start,((ps_str_len - ps_start)+ 1),i_string)
    IF (ps_num_found > 1)
     SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
      values)
    ELSE
     SET ps_idx = 0
    ENDIF
    IF (ps_idx=0)
     SET stat = alterlist(io_string_rs->qual,ps_num_found)
     SET io_string_rs->qual[ps_num_found].values = ps_temp_string
    ELSE
     SET ps_num_found = (ps_num_found - 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_html_string(i_string)
   SET i_string = replace(i_string,"&","&amp;",0)
   SET i_string = replace(i_string,"<","&lt;",0)
   SET i_string = replace(i_string,">","&gt;",0)
   RETURN(i_string)
 END ;Subroutine
 SUBROUTINE copy_xsl(i_template_name,i_file_name)
   SET dm_err->eproc = "Copying Stylesheet"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE cx_cmd = vc WITH protect, noconstant("")
   DECLARE cx_status = i4 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET cx_cmd = concat("COPY CER_INSTALL:",trim(i_template_name,3)," CCLUSERDIR:",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSE
    SET cx_cmd = concat("cp $cer_install/",trim(i_template_name,3)," $CCLUSERDIR/",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_get_file_name(i_env_id,i_env_name,i_mnu_hdg,i_default_name,i_file_xtn,i_type)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgfn_file_name = vc
   DECLARE dgfn_menu = i2
   DECLARE dgfn_file_xtn = vc
   DECLARE dgfn_default_name = vc
   IF (findstring(".",i_file_xtn)=0)
    SET dgfn_file_xtn = cnvtlower(concat(".",i_file_xtn))
   ELSE
    SET dgfn_file_xtn = cnvtlower(i_file_xtn)
   ENDIF
   IF (findstring(".",i_default_name) > 0)
    SET dgfn_default_name = cnvtlower(substring(1,(findstring(".",i_default_name) - 1),i_default_name
      ))
   ELSE
    SET dgfn_default_name = cnvtlower(i_default_name)
   ENDIF
   CALL check_lock("RDDS FILENAME LOCK",concat(dgfn_default_name,dgfn_file_xtn),drl_reply)
   IF ((drl_reply->status="F"))
    RETURN("-1")
   ELSEIF ((drl_reply->status="Z"))
    SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
         currdbhandle))),dgfn_default_name)),currdbhandle)
   ENDIF
   SET stat = initrec(drl_reply)
   SET dgfn_menu = 0
   WHILE (dgfn_menu=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,concat("***  ",i_mnu_hdg,"  ***"))
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(i_env_id))
     CALL text(4,40,i_env_name)
     CALL text(7,3,concat("Please enter a file name for ",i_type," (0 to exit): "))
     CALL text(9,3,"NOTE: This will overwrite any file in CCLUSERDIR with the same name.")
     SET accept = nopatcheck
     CALL accept(7,70,"P(30);C",trim(build(dgfn_default_name,dgfn_file_xtn)))
     SET accept = patcheck
     SET dgfn_file_name = curaccept
     IF (dgfn_file_name="0")
      SET dgfn_menu = 1
      RETURN("-1")
     ENDIF
     IF (findstring(".",dgfn_file_name)=0)
      SET dgfn_file_name = concat(dgfn_file_name,dgfn_file_xtn)
     ENDIF
     IF (size(dgfn_file_name) > 30)
      SET dgfn_file_name = concat(trim(substring(1,(30 - size(dgfn_file_xtn)),dgfn_file_name)),
       dgfn_file_xtn)
     ENDIF
     CALL check_lock("RDDS FILENAME LOCK",dgfn_file_name,drl_reply)
     IF ((drl_reply->status="F"))
      RETURN("-1")
     ENDIF
     IF (cnvtlower(substring(findstring(".",dgfn_file_name),size(dgfn_file_name,1),dgfn_file_name))
      != cnvtlower(dgfn_file_xtn))
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgfn_file_xtn))
      CALL pause(5)
     ELSEIF ((drl_reply->status="Z"))
      CALL text(20,3,concat("File name ",dgfn_file_name,
        " is currently locked, please choose a different filename."))
      CALL pause(5)
      IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
        currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
       SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name
         ),trim(currdbhandle))
      ELSE
       SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
            currdbhandle))),dgfn_file_name)),trim(currdbhandle))
      ENDIF
     ELSE
      CALL get_lock("RDDS FILENAME LOCK",dgfn_file_name,1,drl_reply)
      IF ((drl_reply->status="F"))
       RETURN("-1")
      ELSEIF ((drl_reply->status="Z"))
       CALL text(20,3,concat("File name ",dgfn_file_name,
         " is currently locked, please choose a different filename."))
       CALL pause(5)
       IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
         currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
        SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),
          dgfn_file_name),trim(currdbhandle))
       ELSE
        SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
             currdbhandle))),dgfn_file_name)),trim(currdbhandle))
       ENDIF
      ELSE
       SET dgfn_menu = 1
      ENDIF
     ENDIF
     SET stat = initrec(drl_reply)
   ENDWHILE
   RETURN(dgfn_file_name)
 END ;Subroutine
 DECLARE rer_create_header(rer_xml_file=vc,rch_info=vc(ref)) = i2
 DECLARE drer_xml_file = vc WITH protect, noconstant("")
 DECLARE drer_idx = i4 WITH protect, noconstant(0)
 DECLARE drer_pos = i4 WITH protect, noconstant(0)
 DECLARE drer_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE drer_det_pos = i4 WITH protect, noconstant(0)
 FREE RECORD drer_event_info
 RECORD drer_event_info(
   1 cur_env_id = f8
   1 cur_env_name = vc
   1 src_env_id = f8
   1 src_env_name = vc
   1 open_event_id = f8
   1 open_event_name = vc
   1 event_start = dq8
   1 event_end = dq8
   1 user_id = f8
   1 user_nff = vc
   1 open_cd_rlse = i4
   1 cur_cd_rlse = i4
   1 cd_diff = i4
   1 s_open_cd_rlse = i4
   1 s_cur_cd_rlse = i4
   1 s_cd_diff = i4
   1 days_cnt = i4
   1 cbc_setting = vc
   1 date[*]
     2 event_date = vc
     2 events_cnt = i4
     2 event[*]
       3 event_type = vc
       3 type_cnt = i4
       3 event_info[*]
         4 event_id = f8
         4 event_reason = vc
         4 event_date = dq8
         4 event_user_id = f8
         4 event_user_nff = vc
         4 mvr_ctxt = vc
         4 detail_cnt = i4
         4 details[*]
           5 detail_id = f8
           5 event_det1 = vc
           5 event_det2 = vc
           5 event_det3 = vc
           5 event_val = i4
 )
 IF ((validate(request->target_env_id,- (1))=- (1)))
  IF ((validate(request->open_event_id,- (1))=- (1)))
   SET reply->status = "F"
   SET reply->error_msg = "REQUEST record structure was not declared."
   GO TO exit_event_rpt
  ENDIF
 ENDIF
 IF (check_logfile("dm_rmc_event_rpt",".log","dm_rmc_event_rpt")=0)
  GO TO exit_event_rpt
 ENDIF
 SET drer_event_info->cur_env_id = request->target_env_id
 SET drer_event_info->open_event_id = request->open_event_id
 SET drer_xml_file = request->xml_file_name
 SET reply->status = "S"
 SET reply->error_msg = ""
 SELECT INTO "nl:"
  FROM dm_environment de
  WHERE (de.environment_id=drer_event_info->cur_env_id)
  DETAIL
   drer_event_info->cur_env_name = de.environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SELECT INTO "nl:"
  FROM dm_rdds_event_log d1,
   dm_environment de,
   prsnl p
  WHERE (d1.dm_rdds_event_log_id=drer_event_info->open_event_id)
   AND (d1.cur_environment_id=drer_event_info->cur_env_id)
   AND d1.paired_environment_id=de.environment_id
   AND outerjoin(d1.updt_id)=p.person_id
  DETAIL
   drer_event_info->src_env_id = d1.paired_environment_id, drer_event_info->src_env_name = de
   .environment_name, drer_event_info->event_start = cnvtdatetime(d1.event_dt_tm),
   drer_event_info->open_event_name = d1.event_reason, drer_event_info->user_id = d1.updt_id,
   drer_event_id = d1.dm_rdds_event_log_id
   IF (p.person_id > 0)
    drer_event_info->user_nff = p.name_full_formatted
   ELSE
    drer_event_info->user_nff = "No User Data Present"
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ELSEIF (curqual=0)
  SET reply->status = "F"
  SET reply->error_msg = "Open Event Information does not match."
  GO TO exit_event_rpt
 ENDIF
 SET dm_err->eproc = "Query detail table for Cutover by Context setting."
 SET drer_event_info->cbc_setting = "Off"
 SELECT INTO "nl:"
  FROM dm_rdds_event_detail d
  WHERE d.dm_rdds_event_log_id=drer_event_id
   AND d.event_detail1_txt="Cutover by Context Setting"
  DETAIL
   IF (d.event_detail_value=0)
    drer_event_info->cbc_setting = "Off"
   ELSE
    drer_event_info->cbc_setting = "On"
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SET dm_err->eproc = "Query for close event date."
 SELECT INTO "nl:"
  FROM dm_rdds_event_log d1
  WHERE (d1.cur_environment_id=drer_event_info->cur_env_id)
   AND d1.rdds_event="End Reference Data Sync"
   AND d1.rdds_event_key="ENDREFERENCEDATASYNC"
   AND (d1.event_reason=drer_event_info->open_event_name)
  DETAIL
   drer_event_info->event_end = d1.event_dt_tm
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ELSEIF (curqual=0)
  SET drer_event_info->event_end = cnvtdatetime("31-DEC-2100")
 ENDIF
 SELECT INTO "nl:"
  y = max(rie.req_version_nbr)
  FROM dm_rdds_req_install_env rie
  WHERE (rie.environment_id=drer_event_info->cur_env_id)
   AND req_type="CODE"
   AND req_name="RDDS"
   AND rie.updt_dt_tm < cnvtdatetime(drer_event_info->event_start)
  DETAIL
   drer_event_info->open_cd_rlse = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SELECT INTO "nl:"
  y = max(rie.req_version_nbr)
  FROM dm_rdds_req_install_env rie
  WHERE (rie.environment_id=drer_event_info->cur_env_id)
   AND req_type="CODE"
   AND req_name="RDDS"
   AND rie.updt_dt_tm < cnvtdatetime(drer_event_info->event_end)
  DETAIL
   drer_event_info->cur_cd_rlse = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_rdds_req_install_env rie
  WHERE (rie.environment_id=drer_event_info->cur_env_id)
   AND req_type="CODE"
   AND req_name="RDDS"
   AND rie.updt_dt_tm > cnvtdatetime(drer_event_info->event_start)
   AND rie.updt_dt_tm < cnvtdatetime(drer_event_info->event_end)
  DETAIL
   drer_event_info->cd_diff = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SELECT INTO "nl:"
  y = max(rie.req_version_nbr)
  FROM dm_rdds_req_install_env rie
  WHERE (rie.environment_id=drer_event_info->src_env_id)
   AND req_type="CODE"
   AND req_name="RDDS"
   AND rie.updt_dt_tm < cnvtdatetime(drer_event_info->event_start)
  DETAIL
   drer_event_info->s_open_cd_rlse = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SELECT INTO "nl:"
  y = max(rie.req_version_nbr)
  FROM dm_rdds_req_install_env rie
  WHERE (rie.environment_id=drer_event_info->src_env_id)
   AND req_type="CODE"
   AND req_name="RDDS"
   AND rie.updt_dt_tm < cnvtdatetime(drer_event_info->event_end)
  DETAIL
   drer_event_info->s_cur_cd_rlse = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_rdds_req_install_env rie
  WHERE (rie.environment_id=drer_event_info->src_env_id)
   AND req_type="CODE"
   AND req_name="RDDS"
   AND rie.updt_dt_tm > cnvtdatetime(drer_event_info->event_start)
   AND rie.updt_dt_tm < cnvtdatetime(drer_event_info->event_end)
  DETAIL
   drer_event_info->s_cd_diff = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SET dm_err->eproc = "Collect rdds merge/cutover event information"
 SELECT INTO "nl:"
  evt_dt_fmt = format(el.event_dt_tm,"WWW, DD MMM, YYYY;;d")
  FROM dm_rdds_event_log el,
   prsnl p
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_info di
   WHERE di.info_domain="RDDS OPEN EVENT RPT"
    AND di.info_name=el.rdds_event_key)))
   AND el.event_dt_tm >= cnvtdatetime(drer_event_info->event_start)
   AND el.event_dt_tm <= evaluate(cnvtdatetime(drer_event_info->event_end),cnvtdatetime(
    "31-DEC-2100 00:00:00"),cnvtdatetime(curdate,curtime3),cnvtdatetime(drer_event_info->event_end))
   AND el.dm_rdds_event_log_id > 0.0
   AND (el.cur_environment_id=drer_event_info->cur_env_id)
   AND outerjoin(el.updt_id)=p.person_id
  ORDER BY el.event_dt_tm
  HEAD REPORT
   dt_cnt = 0
  HEAD evt_dt_fmt
   IF (((mod(dt_cnt,100)=0) OR (dt_cnt=0)) )
    stat = alterlist(drer_event_info->date,(dt_cnt+ 100))
   ENDIF
   dt_cnt = (dt_cnt+ 1), drer_event_info->date[dt_cnt].event_date = evt_dt_fmt, evt_cnt = 0
  HEAD el.rdds_event_key
   IF (((mod(evt_cnt,100)=0) OR (evt_cnt=0)) )
    stat = alterlist(drer_event_info->date[dt_cnt].event,(evt_cnt+ 100))
   ENDIF
   evt_cnt = (evt_cnt+ 1), drer_event_info->date[dt_cnt].event[evt_cnt].event_type = el.rdds_event,
   info_cnt = 0
  DETAIL
   IF (((mod(info_cnt,100)=0) OR (info_cnt=0)) )
    stat = alterlist(drer_event_info->date[dt_cnt].event[evt_cnt].event_info,(info_cnt+ 100))
   ENDIF
   info_cnt = (info_cnt+ 1), drer_event_info->date[dt_cnt].events_cnt = (drer_event_info->date[dt_cnt
   ].events_cnt+ 1), drer_event_info->date[dt_cnt].event[evt_cnt].event_info[info_cnt].event_reason
    = el.event_reason,
   drer_event_info->date[dt_cnt].event[evt_cnt].event_info[info_cnt].event_date = el.event_dt_tm,
   drer_event_info->date[dt_cnt].event[evt_cnt].event_info[info_cnt].event_id = el
   .dm_rdds_event_log_id, drer_event_info->date[dt_cnt].event[evt_cnt].event_info[info_cnt].
   event_user_id = el.updt_id
   IF (el.updt_id > 0)
    drer_event_info->date[dt_cnt].event[evt_cnt].event_info[info_cnt].event_user_nff = concat(trim(p
      .name_full_formatted,3)," (",trim(p.username,3),")")
   ELSE
    drer_event_info->date[dt_cnt].event[evt_cnt].event_info[info_cnt].event_user_nff =
    "No User Data Present"
   ENDIF
  FOOT  el.rdds_event_key
   drer_event_info->date[dt_cnt].event[evt_cnt].type_cnt = info_cnt, stat = alterlist(drer_event_info
    ->date[dt_cnt].event[evt_cnt].event_info,info_cnt)
  FOOT  evt_dt_fmt
   evt_cnt = drer_event_info->date[dt_cnt].events_cnt, stat = alterlist(drer_event_info->date[dt_cnt]
    .event,evt_cnt)
  FOOT REPORT
   drer_event_info->days_cnt = dt_cnt, stat = alterlist(drer_event_info->date,dt_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 FOR (d = 1 TO drer_event_info->days_cnt)
   FOR (e = 1 TO drer_event_info->date[d].events_cnt)
     IF ((drer_event_info->date[d].event[e].event_type IN ("Starting RDDS Movers",
     "Creating Sequence Match Row", "Cutover Started", "Mover Batch Size Setting",
     "Mover Log Level Setting")))
      SET drer_idx = 0
      SELECT INTO "nl:"
       FROM dm_rdds_event_detail red
       WHERE expand(drer_idx,1,drer_event_info->date[d].event[e].type_cnt,red.dm_rdds_event_log_id,
        drer_event_info->date[d].event[e].event_info[drer_idx].event_id)
       ORDER BY red.dm_rdds_event_log_id, red.event_detail1_txt
       HEAD red.dm_rdds_event_log_id
        drer_pos = 0, drer_pos = locateval(drer_pos,1,drer_event_info->date[d].event[e].type_cnt,red
         .dm_rdds_event_log_id,drer_event_info->date[d].event[e].event_info[drer_pos].event_id),
        det_cnt = drer_event_info->date[d].event[e].event_info[drer_pos].detail_cnt
       DETAIL
        det_cnt = (det_cnt+ 1), stat = alterlist(drer_event_info->date[d].event[e].event_info[
         drer_pos].details,det_cnt)
        IF (red.event_detail1_txt="CONTEXTS TO PULL")
         drer_event_info->date[d].event[e].event_info[drer_pos].mvr_ctxt = concat(trim(
           drer_event_info->date[d].event[e].event_info[drer_pos].mvr_ctxt,3),trim(replace(red
            .event_detail2_txt,"::",'","'),3))
        ELSE
         drer_event_info->date[d].event[e].event_info[drer_pos].details[det_cnt].detail_id = red
         .dm_rdds_event_detail_id, drer_event_info->date[d].event[e].event_info[drer_pos].details[
         det_cnt].event_det1 = red.event_detail1_txt, drer_event_info->date[d].event[e].event_info[
         drer_pos].details[det_cnt].event_det2 = red.event_detail2_txt,
         drer_event_info->date[d].event[e].event_info[drer_pos].details[det_cnt].event_det3 = red
         .event_detail3_txt, drer_event_info->date[d].event[e].event_info[drer_pos].details[det_cnt].
         event_val = red.event_detail_value, drer_event_info->date[d].event[e].event_info[drer_pos].
         detail_cnt = det_cnt
        ENDIF
       FOOT  red.dm_rdds_event_log_id
        drer_pos = 0
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET message = nowindow
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       GO TO exit_event_rpt
      ENDIF
     ELSEIF ((drer_event_info->date[d].event[e].event_type IN ("Add Environment Triggers",
     "Subset of Triggers Added", "Drop Environment Triggers", "Subset of Triggers Dropped")))
      SET drer_idx = 0
      SELECT DISTINCT INTO "nl:"
       red.event_detail1_txt
       FROM dm_rdds_event_detail red
       WHERE expand(drer_idx,1,drer_event_info->date[d].event[e].type_cnt,red.dm_rdds_event_log_id,
        drer_event_info->date[d].event[e].event_info[drer_idx].event_id)
       ORDER BY red.dm_rdds_event_log_id, red.event_detail1_txt
       HEAD red.dm_rdds_event_log_id
        drer_pos = 0, drer_pos = locateval(drer_pos,1,drer_event_info->date[d].event[e].type_cnt,red
         .dm_rdds_event_log_id,drer_event_info->date[d].event[e].event_info[drer_pos].event_id),
        det_cnt = drer_event_info->date[d].event[e].event_info[drer_pos].detail_cnt
       DETAIL
        det_cnt = (det_cnt+ 1), stat = alterlist(drer_event_info->date[d].event[e].event_info[
         drer_pos].details,det_cnt), drer_event_info->date[d].event[e].event_info[drer_pos].details[
        det_cnt].detail_id = red.dm_rdds_event_detail_id,
        drer_event_info->date[d].event[e].event_info[drer_pos].details[det_cnt].event_det1 = red
        .event_detail1_txt, drer_event_info->date[d].event[e].event_info[drer_pos].details[det_cnt].
        event_det2 = red.event_detail2_txt, drer_event_info->date[d].event[e].event_info[drer_pos].
        details[det_cnt].event_det3 = red.event_detail3_txt,
        drer_event_info->date[d].event[e].event_info[drer_pos].details[det_cnt].event_val = red
        .event_detail_value, drer_event_info->date[d].event[e].event_info[drer_pos].detail_cnt =
        det_cnt
       FOOT  red.dm_rdds_event_log_id
        drer_pos = 0
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET message = nowindow
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       GO TO exit_event_rpt
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 IF ((rer_create_header(drer_xml_file,drer_event_info)=- (1)))
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SELECT INTO value(drer_xml_file)
  FROM (dummyt d  WITH seq = drer_event_info->days_cnt)
  HEAD REPORT
   row + 2
  DETAIL
   "<event_day_data>", row + 1, "  <event_date>",
   drer_event_info->date[d.seq].event_date, "</event_date>", row + 1,
   evt_cnt = build(cnvtstring(drer_event_info->date[d.seq].events_cnt)), "  <event_type_count>",
   evt_cnt,
   "</event_type_count>", row + 1
   FOR (e = 1 TO drer_event_info->date[d.seq].events_cnt)
     FOR (ei = 1 TO drer_event_info->date[d.seq].event[e].type_cnt)
       ev_dt = build(format(drer_event_info->date[d.seq].event[e].event_info[ei].event_date,
         "DD/MMM/YYYY HH:MM;;d")), "    <event_info>", row + 1,
       "      <event_name>", drer_event_info->date[d.seq].event[e].event_type, "</event_name>",
       row + 1, ev_user = drer_event_info->date[d.seq].event[e].event_info[ei].event_user_nff
       IF ((drer_event_info->date[d.seq].event[e].event_type="Starting RDDS Movers"))
        FOR (ed = 1 TO drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt)
         ev_val = build(cnvtstring(drer_event_info->date[d.seq].event[e].event_info[ei].details[ed].
           event_val)),
         CASE (drer_event_info->date[d.seq].event[e].event_info[ei].details[ed].event_det1)
          OF "Number of Movers Started":
           "      <event_cnt>",ev_val," movers started</event_cnt>",
           row + 1,"      <event_detail><event_det>Started by ",ev_user,
           "</event_det></event_detail>",row + 1,"      <event_detail><event_det>Started on ",
           ev_dt,"</event_det></event_detail>",row + 1
          OF "CONTEXT GROUP_IND":
           drer_pos = 0,drer_idx = 0,
           IF ((drer_event_info->date[d.seq].event[e].event_info[ei].details[ed].event_val=1))
            drer_pos = locateval(drer_idx,1,drer_event_info->date[d.seq].event[e].event_info[ei].
             detail_cnt,"CONTEXT TO SET",drer_event_info->date[d.seq].event[e].event_info[ei].
             details[drer_idx].event_det1),
            "      <event_detail><event_det>Context Setup = Group</event_det></event_detail>", row +
            1,
            "      <event_detail><event_det>Context to set = '", drer_event_info->date[d.seq].event[e
            ].event_info[ei].details[drer_pos].event_det2, "'</event_det></event_detail>",
            row + 1
           ELSE
            drer_pos = locateval(drer_idx,1,drer_event_info->date[d.seq].event[e].event_info[ei].
             detail_cnt,"DEFAULT CONTEXT",drer_event_info->date[d.seq].event[e].event_info[ei].
             details[drer_idx].event_det1),
            "      <event_detail><event_det>Context Setup = Maintain</event_det></event_detail>", row
             + 1,
            "      <event_detail><event_det>Default Context = '", drer_event_info->date[d.seq].event[
            e].event_info[ei].details[drer_pos].event_det2, "'</event_det></event_detail>",
            row + 1
           ENDIF
         ENDCASE
        ENDFOR
        "      <event_detail><event_det>Contexts to pull = ", row + 1, '"',
        drer_event_info->date[d.seq].event[e].event_info[ei].mvr_ctxt, '"', row + 1,
        "      </event_det></event_detail>", row + 1
       ELSEIF ((drer_event_info->date[d.seq].event[e].event_type="Creating Sequence Match Row"))
        ev_cnt = build(cnvtstring(drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt)),
        "      <event_cnt>", ev_cnt,
        " sequences matched</event_cnt>", row + 1, "      <event_detail><event_det>Created by ",
        ev_user, "</event_det></event_detail>", row + 1,
        "      <event_detail><event_det>", drer_event_info->date[d.seq].event[e].event_info[ei].
        event_reason, "</event_det></event_detail>",
        row + 1
        FOR (ed = 1 TO drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt)
          ev_val = build(cnvtstring(drer_event_info->date[d.seq].event[e].event_info[ei].details[ed].
            event_val)), "      <event_detail><event_det>", drer_event_info->date[d.seq].event[e].
          event_info[ei].details[ed].event_det1,
          " = ", ev_val, "</event_det></event_detail>",
          row + 1
        ENDFOR
       ELSEIF ((drer_event_info->date[d.seq].event[e].event_type IN ("Cutover Started")))
        drer_det_pos = locateval(drer_det_pos,1,drer_event_info->date[d.seq].event[e].event_info[ei].
         detail_cnt,"Number of Cutovers Started",drer_event_info->date[d.seq].event[e].event_info[ei]
         .details[drer_det_pos].event_det1), ev_cnt = build(cnvtstring(drer_event_info->date[d.seq].
          event[e].event_info[ei].details[drer_det_pos].event_val)), "      <event_cnt>",
        ev_cnt, " cutover processes</event_cnt>", row + 1,
        "      <event_detail><event_det>Started by ", ev_user, "</event_det></event_detail>",
        row + 1, "      <event_detail><event_det>Started on ", ev_dt,
        "</event_det></event_detail>", row + 1
        FOR (drer_det_pos = 1 TO drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt)
          IF ((drer_event_info->date[d.seq].event[e].event_info[ei].details[drer_det_pos].event_det1=
          "RDDS CONTEXT TO CUTOVER"))
           "      <event_detail><event_det>Context to Cutover = ", drer_event_info->date[d.seq].
           event[e].event_info[ei].details[drer_det_pos].event_det2, "</event_det></event_detail>",
           row + 1
          ENDIF
        ENDFOR
       ELSEIF ((drer_event_info->date[d.seq].event[e].event_type IN ("Add Environment Triggers",
       "Subset of Triggers Added", "Drop Environment Triggers", "Subset of Triggers Dropped")))
        ev_cnt = build(cnvtstring(drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt)),
        "      <event_cnt>", ev_cnt,
        " tables</event_cnt>", row + 1, "      <event_detail><event_det>",
        drer_event_info->date[d.seq].event[e].event_info[ei].event_reason,
        "</event_det></event_detail>", row + 1,
        "      <event_detail><event_det>Modified by", ev_user, "</event_det></event_detail>",
        row + 1
        FOR (ed = 1 TO drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt)
          "      <event_detail><event_det>", drer_event_info->date[d.seq].event[e].event_info[ei].
          details[ed].event_det1, "</event_det></event_detail>",
          row + 1
        ENDFOR
       ELSEIF ((drer_event_info->date[d.seq].event[e].event_type IN ("Mover Batch Size Setting")))
        "      <event_cnt> N/A </event_cnt>", row + 1
        IF ((drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt > 0))
         ev_val = build(cnvtstring(drer_event_info->date[d.seq].event[e].event_info[ei].details[1].
           event_val))
        ELSE
         ev_val = "0"
        ENDIF
        "      <event_detail><event_det>Modified by", ev_user, "</event_det></event_detail>",
        row + 1, "      <event_detail><event_det>Batch Size = ", ev_val,
        "</event_det></event_detail>", row + 1
       ELSEIF ((drer_event_info->date[d.seq].event[e].event_type IN ("Mover Log Level Setting")))
        "      <event_cnt> N/A </event_cnt>", row + 1
        IF ((drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt > 0))
         FOR (ed = 1 TO drer_event_info->date[d.seq].event[e].event_info[ei].detail_cnt)
           IF ((drer_event_info->date[d.seq].event[e].event_info[ei].details[ed].event_val=0))
            "      <event_detail><event_det>Reduce RDDS Mover Log Level</event_det></event_detail>",
            row + 1
           ELSE
            "      <event_detail><event_det>Increase RDDS Mover Log Level</event_det></event_detail>",
            row + 1
           ENDIF
         ENDFOR
        ELSE
         "      <event_detail><event_det>Data not present</event_det></event_detail>", row + 1
        ENDIF
       ELSEIF ((drer_event_info->date[d.seq].event[e].event_type IN (
       "Unprocessed $R Resets Acknowledged")))
        "      <event_cnt> N/A </event_cnt>", row + 1,
        "      <event_detail><event_det> Database Integrity Concerns for Cutover Acknowledged</event_det></event_detail>",
        row + 1, "      <event_detail><event_det>Acknowledged by ", ev_user,
        "</event_det></event_detail>", row + 1, "      <event_detail><event_det>Acknowledged on ",
        ev_dt, "</event_det></event_detail>", row + 1
       ELSE
        "      <event_cnt> N/A </event_cnt>", row + 1, "      <event_detail><event_det>User - ",
        ev_user, "</event_det></event_detail>", row + 1,
        "      <event_detail><event_det>Date - ", ev_dt, "</event_det></event_detail>",
        row + 1
       ENDIF
       "    </event_info>", row + 1
     ENDFOR
   ENDFOR
   "</event_day_data>", row + 1
  FOOT REPORT
   row + 1, "</event_audit_data>"
  WITH nocounter, formfeed = none, maxrow = 1,
   maxcol = 400, append
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 IF ((copy_xsl("event_audit.xsl",replace(cnvtlower(drer_xml_file),".xml",".xsl"))=- (1)))
  SET message = nowindow
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_event_rpt
 ENDIF
 SUBROUTINE rer_create_header(rer_xml_file,rch_info)
   DECLARE rch_xsl_file = vc
   SET rch_xsl_file = replace(cnvtlower(rer_xml_file),".xml",".xsl",1)
   SET dm_err->eproc = "Creating header information for XML file..."
   SELECT INTO value(rer_xml_file)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, '<?xml-stylesheet href="', rch_xsl_file,
     '" type="text/xsl"?>', row + 1, "<event_audit_data>",
     row + 1, dlir_rpt_dt_tm = format(sysdate,";;Q"), row + 1,
     "<audit_date_start>", dlir_rpt_dt_tm, "</audit_date_start>",
     row + 1, "<audit_description_type>RDDS Open Event Report</audit_description_type>", row + 1,
     "<file_name>", rer_xml_file, "</file_name>",
     row + 1, "<source_environment_id>", rch_info->src_env_id,
     "</source_environment_id>", row + 1, "<source_environment_name>",
     rch_info->src_env_name, "</source_environment_name>", row + 1,
     "<target_environment_id>", rch_info->cur_env_id, "</target_environment_id>",
     row + 1, "<target_environment_name>", rch_info->cur_env_name,
     "</target_environment_name>", row + 1, "<event_name>",
     rch_info->open_event_name, "</event_name>", row + 1,
     "<cutover_by_context>", rch_info->cbc_setting, "</cutover_by_context>",
     row + 1, "<opened_by>", rch_info->user_nff,
     "</opened_by>", open_dt = format(rch_info->event_start,"DD-MMM-YYYY HH:MM:SS;;D"), row + 1,
     "<event_open_date>", open_dt, "</event_open_date>",
     close_dt = format(rch_info->event_end,"DD-MMM-YYYY HH:MM:SS;;D"), row + 1, "<event_end_date>",
     close_dt, "</event_end_date>", row + 1,
     "<open_code_rel>", rch_info->open_cd_rlse, "</open_code_rel>",
     row + 1, "<current_rel>", rch_info->cur_cd_rlse,
     "</current_rel>", row + 1, "<rdds_vers_diff>",
     rch_info->cd_diff, "</rdds_vers_diff>", row + 1,
     "<src_open_code_rel>", rch_info->s_open_cd_rlse, "</src_open_code_rel>",
     row + 1, "<src_current_rel>", rch_info->s_cur_cd_rlse,
     "</src_current_rel>", row + 1, "<src_rdds_vers_diff>",
     rch_info->s_cd_diff, "</src_rdds_vers_diff>", row + 1
    WITH nocounter, formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_event_rpt
 IF ((dm_err->err_ind != 0))
  ROLLBACK
  SET reply->status = "F"
  SET reply->error_msg = dm_err->emsg
 ENDIF
 SET dm_err->eproc = "...Ending dm_rmc_event_rpt"
 CALL final_disp_msg("dm_rmc_event_rpt")
END GO
