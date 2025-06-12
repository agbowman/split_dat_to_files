CREATE PROGRAM dm2_capture_schema_ocdtest:dba
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
 DECLARE open_sch_files(sbr_for_modify=i4) = i4
 DECLARE create_sch_files(null) = i4
 DECLARE close_sch_files(null) = i4
 DECLARE copy_sch_files(null) = i4
 DECLARE open_sch_file(sbr_osf_modind=i4,sbr_osf_fname=vc,sbr_osf_rndx=i4) = i4
 DECLARE val_sch_file_ver(sbr_vsf_rndx=i4) = i4
 DECLARE make_sch_file_defs(sbr_msf_rndx=i4) = i4
 DECLARE del_sch_file(sbr_dsf_ffname=vc,sbr_dsf_fname=vc) = i4
 DECLARE del_sch_files(null) = i2
 DECLARE copy_sch_file(sbr_src_fname=vc,sbr_tgt_fname=vc) = i4
 DECLARE check_sch_files(null) = i4
 DECLARE prep_sch_file(rec_ndx=i4) = i4
 DECLARE gen_sch_files(null) = i4
 DECLARE dsfi_load_schema_file_defs(dsfi_schema_set=vc) = i4
 DECLARE dsfi_load_schema_files(dlsf_desc=vc,dlsf_process_option=vc) = i2
 DECLARE dsfi_pop_dmheader(sfidx=i4) = null
 DECLARE dsfi_pop_dmtable(sfidx=i4) = null
 DECLARE dsfi_pop_dmcolumn(sfidx=i4) = null
 DECLARE dsfi_pop_dmindex(sfidx=i4) = null
 DECLARE dsfi_pop_dmindcol(sfidx=i4) = null
 DECLARE dsfi_pop_dmcons(sfidx=i4) = null
 DECLARE dsfi_pop_dmconscol(sfidx=i4) = null
 DECLARE dsfi_pop_dmseq(sfidx=i4) = null
 DECLARE dsfi_pop_dmtbldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmcoldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmtdprec(sfidx=i4) = null
 DECLARE dsfi_pop_dmtspace(sfidx=i4) = null
 IF ((validate(dm2_sch_file->file_cnt,- (1))=- (1)))
  RECORD dm2_sch_file(
    1 sf_ver = i4
    1 file_cnt = i4
    1 src_dir_osfmt = vc
    1 dest_dir_cclfmt = vc
    1 dest_dir_osfmt = vc
    1 ending_punct = vc
    1 file_prefix = vc
    1 qual[*]
      2 file_suffix = vc
      2 table_name = vc
      2 db_name = vc
      2 size = vc
      2 data_size = vc
      2 key_size = vc
      2 db_key = vc
      2 key_cnt = i4
      2 kqual[*]
        3 key_col = vc
      2 data_cnt = i4
      2 dqual[*]
        3 data_col = vc
  )
  SET dm2_sch_file->sf_ver = 1
  CASE (dm2_sys_misc->cur_os)
   OF "AXP":
    SET dm2_sch_file->ending_punct = " "
   OF "WIN":
    SET dm2_sch_file->ending_punct = "\"
   ELSE
    SET dm2_sch_file->ending_punct = "/"
  ENDCASE
  IF (dsfi_load_schema_file_defs("TABLE_INFO") != 1)
   SET dm_err->err_ind = 1
  ENDIF
 ENDIF
 SUBROUTINE create_sch_files(null)
   DECLARE csf_concurrency_cnt = i4 WITH noconstant(0)
   DECLARE sch_file_status = i4
   DECLARE di_insert_ind = i2 WITH noconstant(0)
   DECLARE pause_length = i2 WITH noconstant(60)
   DECLARE csf_done_ind = i2 WITH noconstant(0)
   DECLARE csf_retry_cnt = i2 WITH noconstant(0)
   DECLARE csf_skip_ind = i2 WITH noconstant(0)
   SET dm2_sch_file->dest_dir_osfmt = build(logical(dm2_sch_file->dest_dir_cclfmt),dm2_sch_file->
    ending_punct)
   WHILE (csf_done_ind=0
    AND (dm_err->err_ind=0))
     SET csf_done_ind = 1
     SET csf_skip_ind = 0
     IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
      WHILE (csf_concurrency_cnt < 2
       AND (dm_err->err_ind=0))
        IF (dm2_set_autocommit(1)=1)
         SELECT INTO "nl:"
          FROM dm_info d
          WHERE d.info_domain="DM2 TOOLS"
           AND d.info_name="CREATING SCHEMA FILES"
          WITH nocounter
         ;end select
         IF (curqual > 0)
          SET csf_concurrency_cnt = (csf_concurrency_cnt+ 1)
          IF (csf_concurrency_cnt=2)
           SET dm_err->emsg =
           "Another process is currently generating schema file definitions, please try again later."
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 1
          ELSE
           SET dm_err->eproc = concat(
            "Another process is currently generating schema file definitions.  Pausing ",trim(
             cnvtstring(pause_length))," seconds before trying again. Please wait.")
           CALL disp_msg(" ",dm_err->logfile,0)
           CALL pause(pause_length)
          ENDIF
         ELSE
          IF (check_error("Checking for concurrency row in dm_info ")=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ENDIF
          SET csf_concurrency_cnt = 2
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     IF ((dm_err->err_ind=0))
      SET sch_file_status = check_sch_files(null)
      CASE (sch_file_status)
       OF 0:
        SET dm_err->err_ind = 1
       OF 1:
        SET dm_err->eproc = "ALL CORE SCHEMA FILE COMPONENTS EXIST"
        CALL disp_msg(" ",dm_err->logfile,0)
        FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
          IF (prep_sch_file(csf_file_cnt)=0)
           SET dm_err->err_ind = 1
           SET csf_file_cnt = dm2_sch_file->file_cnt
          ENDIF
        ENDFOR
       OF 2:
        IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
         SET dm_err->eproc = "INSERT CONCURRENCY ROW INTO DM_INFO"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info d
          SET d.info_domain = "DM2 TOOLS", d.info_name = "CREATING SCHEMA FILES", d.info_date = null,
           d.info_char = " ", d.info_number = 0.0, d.info_long_id = 0.0,
           d.updt_applctx = 0, d.updt_task = 0.0, d.updt_cnt = 0,
           d.updt_id = 0.0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WITH nocounter
         ;end insert
         IF (check_error("Inserting dm_info row for concurrency ")=1)
          IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
           SET csf_retry_cnt = (csf_retry_cnt+ 1)
           IF (csf_retry_cnt < 2)
            SET dm_err->err_ind = 0
            SET csf_done_ind = 0
            SET csf_skip_ind = 1
            SET dm_err->eproc = concat(
             "Another process is currently generating schema file definitions.  Pausing ",trim(
              cnvtstring(pause_length))," seconds before trying again. Please wait.")
            CALL disp_msg(" ",dm_err->logfile,0)
            CALL pause(pause_length)
           ELSE
            SET dm_err->emsg =
            "Another process is currently generating schema file definitions, please try again later."
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ENDIF
          ELSE
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ROLLBACK
          ENDIF
         ELSE
          COMMIT
          SET di_insert_ind = 1
         ENDIF
        ENDIF
        IF ((dm_err->err_ind=0)
         AND csf_skip_ind=0)
         SET dm_err->eproc = "REGENERATE CORE SCHEMA FILE COMPONENTS"
         CALL disp_msg(" ",dm_err->logfile,0)
         CALL gen_sch_files(null)
        ENDIF
      ENDCASE
     ENDIF
   ENDWHILE
   IF (di_insert_ind=1)
    SET dm_err->eproc = "REMOVE CONCURRENCY ROW FROM DM_INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info d
     WHERE d.info_domain="DM2 TOOLS"
      AND d.info_name="CREATING SCHEMA FILES"
     WITH nocounter
    ;end delete
    COMMIT
    IF ((dm_err->err_ind=0))
     IF (check_error("Deleting dm_info row for concurrency ")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
   CALL dm2_set_autocommit(0)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE open_sch_file(sbr_osf_modind,sbr_osf_fname,sbr_osf_rndx)
   DECLARE osf_tempstr = vc WITH noconstant(" ")
   IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," go"),1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," is ",build("'",
      sbr_osf_fname,"'")),0)
   IF (sbr_osf_modind=1)
    CALL dm2_push_cmd(" with modify",0)
    SET osf_tempstr = " with modify"
   ENDIF
   IF (dm2_push_cmd(" go",1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE open_sch_files(sbr_for_modify)
   DECLARE file_name_for_open = vc
   DECLARE dsfi = i4 WITH public, noconstant(0)
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
     SET file_name_for_open = build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->
       file_prefix),cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
     IF (val_sch_file_ver(dsfi)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSEIF (make_sch_file_defs(dsfi)=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag=1))
      SET dm_err->eproc = concat("Opening ",file_name_for_open)
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (open_sch_file(sbr_for_modify,file_name_for_open,dsfi)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE val_sch_file_ver(sbr_vsf_rndx)
   DECLARE vsfv_datacnt = i4 WITH noconstant(0)
   DECLARE vsfv_keycnt = i4 WITH noconstant(0)
   DECLARE vsfv_match_col_ind = i2 WITH noconstant(0)
   DECLARE vsfv_match_db_ind = i2 WITH noconstant(0)
   DECLARE vsfv_temp_str = vc WITH noconstant("")
   SELECT INTO "nl:"
    d.table_name
    FROM dtable d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_vsf_rndx].db_name)
     AND (d.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
    DETAIL
     vsfv_match_db_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE (a.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    HEAD REPORT
     start_pos = 0, end_pos = 0, x = 0,
     y = 0
    DETAIL
     FOR (x = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].
       data_col))
       end_pos = 0
       IF (trim(l.attr_name,3)="FILLER")
        start_pos = findstring("FILLER = c",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
        start_pos = (start_pos+ 10), end_pos = findstring(" CCL(FILLER)",dm2_sch_file->qual[
         sbr_vsf_rndx].dqual[x].data_col)
        IF (l.len=cnvtint(substring(start_pos,(end_pos - start_pos),dm2_sch_file->qual[sbr_vsf_rndx].
          dqual[x].data_col)))
         vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
        ENDIF
       ELSE
        vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
       ENDIF
      ENDIF
     ENDFOR
     FOR (y = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].key_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].key_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].
       key_col))
       end_pos = 0, vsfv_keycnt = (vsfv_keycnt+ 1), y = dm2_sch_file->qual[sbr_vsf_rndx].key_cnt
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for columns on ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
    CALL echo(build("dm_err->err_ind = ",dm_err->err_ind))
   ENDIF
   IF ((vsfv_datacnt=dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
    AND (vsfv_keycnt=dm2_sch_file->qual[sbr_vsf_rndx].key_cnt))
    SET vsfv_match_col_ind = 1
   ENDIF
   IF (vsfv_match_col_ind=1
    AND vsfv_match_db_ind=1)
    RETURN(1)
   ELSE
    CALL disp_msg(concat(dm2_sch_file->qual[sbr_vsf_rndx].table_name,
      " definition not correct in CCL dictionary"),dm_err->logfile,0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE make_sch_file_defs(sbr_msf_rndx)
   DECLARE current_db = vc
   DECLARE msfd_estr = vc
   DECLARE msfd_ret_val = i2 WITH noconstant(0)
   DECLARE drop_needed = i2 WITH noconstant(0)
   IF ((dm_err->debug_flag=1))
    SET dm_err->eproc = concat("Making CCL definition for ",dm2_sch_file->qual[sbr_msf_rndx].
     table_name)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dtable d
    WHERE (d.table_name=dm2_sch_file->qual[sbr_msf_rndx].table_name)
    DETAIL
     drop_needed = 1, current_db = d.file_name
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
      " from database ",current_db," WITH DEPS_DELETED go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop database ",current_db," with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET drop_needed = 0
   SELECT INTO "nl:"
    FROM dfile d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_msf_rndx].db_name)
    DETAIL
     drop_needed = 1
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
      " with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_push_cmd(concat("create database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
     " organization(indexed) format(variable) size(",dm2_sch_file->qual[sbr_msf_rndx].size,") ",
     dm2_sch_file->qual[sbr_msf_rndx].db_key," go"),1)=0)
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("create ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
     " from database ",dm2_sch_file->qual[sbr_msf_rndx].db_name," table ",
     dm2_sch_file->qual[sbr_msf_rndx].table_name),0)
   CALL dm2_push_cmd(" 1 key1 ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].key_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].kqual[i].key_col),0)
   ENDFOR
   CALL dm2_push_cmd(" 1 data ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].data_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].dqual[i].data_col),0)
   ENDFOR
   IF (dm2_push_cmd(concat("end table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
    RETURN(0)
   ENDIF
   SET msfd_estr = concat("Making def for ",dm2_sch_file->qual[sbr_msf_rndx].table_name)
   SET msfd_ret_val = val_sch_file_ver(sbr_msf_rndx)
   IF (msfd_ret_val=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = msfd_estr
     CALL disp_msg(" ",dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE close_sch_files(null)
   FOR (close_cnt = 1 TO dm2_sch_file->file_cnt)
     IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[close_cnt].db_name," go"),1)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE copy_sch_files(null)
  DECLARE target_name = vc
  FOR (csfi = 1 TO dm2_sch_file->file_cnt)
    SET target_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[csfi].file_suffix)
     )
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
    IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".dat"),build(dm2_sch_file->
      dest_dir_osfmt,target_name,".dat"))=0)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".idx"),build(dm2_sch_file->
       dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE del_sch_file(sbr_dsf_fname)
  IF ((dm2_sys_misc->cur_os="WIN"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname,";\*"))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSE
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("rm ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE copy_sch_file(sbr_src_fname,sbr_tgt_fname)
  IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
   IF (dm2_push_dcl(concat("cp ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(concat("chmod 777 ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ELSE
   IF (dm2_push_dcl(concat("copy ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE check_sch_files(null)
   DECLARE csf_file_name = vc WITH noconstant("")
   DECLARE csf_val_ver_ind = i2 WITH noconstant(0)
   FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
     SET csf_file_name = concat(dm2_install_schema->ccluserdir,dm2_sch_file->qual[csf_file_cnt].
      table_name)
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ENDIF
     ELSE
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ELSEIF ( NOT (findfile(concat(trim(csf_file_name,3),".idx"))))
       RETURN(2)
      ENDIF
     ENDIF
     IF (val_sch_file_ver(csf_file_cnt)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSE
       SET csf_val_ver_ind = 1
      ENDIF
     ENDIF
   ENDFOR
   IF (csf_val_ver_ind=1)
    RETURN(2)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE prep_sch_file(rec_ndx)
   DECLARE psf_target_name = vc
   DECLARE psf_target_name2 = vc
   DECLARE psf_estr = vc
   DECLARE psf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET psf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET psf_fext = ".dat/.idx"
   ELSE
    SET psf_fext = ".dat"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("dm2_sch_file->dest_dir_osfmt=",dm2_sch_file->dest_dir_osfmt))
    CALL echo(build("size(dm2_sch_file->dest_dir_osfmt,1)=",size(dm2_sch_file->dest_dir_osfmt,1)))
    CALL echo(concat("dm2_sch_file->file_prefix=",dm2_sch_file->file_prefix))
    CALL echo(concat("dm2_sch_file->qual[rec_ndx]->file_suffix=",dm2_sch_file->qual[rec_ndx].
      file_suffix))
   ENDIF
   SET psf_target_name = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
    cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("psf_target_name=",psf_target_name))
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET psf_target_name2 = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".idx")
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "WIN", "LNX")))
    IF (del_sch_file(psf_target_name)=0)
     RETURN(0)
    ENDIF
    IF (del_sch_file(psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[rec_ndx
       ].table_name,".dat"))),psf_target_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
        rec_ndx].table_name,".idx"))),psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (open_sch_file(1,build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat"),rec_ndx)=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(concat("delete from ",dm2_sch_file->qual[rec_ndx].table_name," where 1=1 go"),1)=
   0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gen_sch_files(null)
   DECLARE gsf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET gsf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET gsf_fext = ".dat/.idx"
   ELSE
    SET gsf_fext = ".dat"
   ENDIF
   FOR (gsf_cnt = 1 TO dm2_sch_file->file_cnt)
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".dat"))))=0)
       RETURN(0)
      ENDIF
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".idx"))))=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF (dm2_push_cmd(concat('select into table "',dm2_sch_file->qual[gsf_cnt].table_name,'"',
       " key1=fillstring(",dm2_sch_file->qual[gsf_cnt].key_size,
       '," "),'," data=fillstring(",dm2_sch_file->qual[gsf_cnt].data_size,'," ") ',
       " from dummyt order key1 with organization=indexed GO"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[gsf_cnt].table_name," go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[gsf_cnt].table_name,
       " from database ",dm2_sch_file->qual[gsf_cnt].table_name," with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[gsf_cnt].table_name,
       " with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (make_sch_file_defs(gsf_cnt)=0)
      RETURN(0)
     ENDIF
     IF (prep_sch_file(gsf_cnt)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_file_defs(dsfi_schema_set)
  CASE (cnvtupper(dsfi_schema_set))
   OF "TABLE_INFO":
    SET dm2_sch_file->file_cnt = 11
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmheader(1)
    CALL dsf_pop_dmtable(2)
    CALL dsf_pop_dmcolumn(3)
    CALL dsf_pop_dmindex(4)
    CALL dsf_pop_dmindcol(5)
    CALL dsf_pop_dmcons(6)
    CALL dsf_pop_dmconscol(7)
    CALL dsf_pop_dmseq(8)
    CALL dsf_pop_dmtbldoc(9)
    CALL dsf_pop_dmcoldoc(10)
    CALL dsf_pop_dmtsprec(11)
   OF "TSPACE":
    SET dm2_sch_file->file_cnt = 1
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmtspace(1)
  ENDCASE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmheader(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_h"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMHEADER"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1058"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1028"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "DESCRIPTION = c30 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SOURCE_RDBMS = c20 CCL(SOURCE_RDBMS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "ADMIN_LOAD_IND = i4 CCL(ADMIN_LOAD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "SF_VERSION = i4 CCL(SF_VERSION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtable(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_t"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTABLE"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1208"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1178"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30  CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 21
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLESPACE_NAME = c30 CCL(TABLESPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "INDEX_TSPACE = c30 CCL(INDEX_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TSPACE_NI = i2 CCL(INDEX_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "LONG_TSPACE = c30 CCL(LONG_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TSPACE_NI = i2 CCL(LONG_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "PCT_USED = f8 CCL(PCT_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "SCHEMA_DATE = dq8 CCL(SCHEMA_DATE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "SCHEMA_INSTANCE = i4 CCL(SCHEMA_INSTANCE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "LONG_TSPACE_TYPE = c1 CCL(LONG_TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[21].data_col = "FILLER = c990 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcolumn(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLUMN"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1343"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1283"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "COLUMN_SEQ = i4 CCL(COLUMN_SEQ)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_TYPE = c18 CCL(DATA_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DATA_LENGTH = i4 CCL(DATA_LENGTH)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "NULLABLE = c1 CCL(NULLABLE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "DATA_DEFAULT = c254 CCL(DATA_DEFAULT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "DATA_DEFAULT_NI = i2 CCL(DATA_DEFAULT_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DATA_DEFAULT2 = c500 CCL(DATA_DEFAULT2)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "VIRTUAL_COLUMN = c3 CCL(VIRTUAL_COLUMN)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c497 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindex(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_i"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDEX"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1140"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1080"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME =  c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 13
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_IND_NAME = c30 CCL(FULL_IND_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UNIQUE_IND = i2 CCL(UNIQUE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TSPACE_NAME = c30 CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "INDEX_TYPE = c30 CCL(INDEX_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "FILLER = c931 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindcol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_ic"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "COLUMN_POSITION = i4 CCL(COLUMN_POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcons(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_c"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONS"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1408"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1348"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_CONS_NAME = c30 CCL(FULL_CONS_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CONSTRAINT_TYPE = c1 CCL(CONSTRAINT_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "STATUS_IND = i2 CCL(STATUS_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col =
   "R_CONSTRAINT_NAME = c30 CCL(R_CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col =
   "PARENT_TABLE_NAME = c30 CCL(PARENT_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col =
   "PARENT_TABLE_COLUMNS = c255 CCL(PARENT_TABLE_COLUMNS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DELETE_RULE = c9 CCL(DELETE_RULE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c991 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmconscol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONSCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "POSITION =  i4 CCL(POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmseq(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_sq"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMSEQ"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1079"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1049"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "MIN_VALUE = f8  CCL(MIN_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "MAX_VALUE = f8 CCL(MAX_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INCREMENT_BY = f8 CCL(INCREMENT_BY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "CYCLE_FLAG = c1 CCL(CYCLE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LAST_NUMBER = f8 CCL(LAST_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtbldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_td"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTBLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2041"
   SET dm2_sch_file->qual[dsfcnt].data_size = "2011"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 20
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col =
   "DATA_MODEL_SECTION = c80 CCL(DATA_MODEL_SECTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "STATIC_ROWS = i4 CCL(STATIC_ROWS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "REFERENCE_IND = i2 CCL(REFERENCE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "HUMAN_REQD_IND = i2 CCL(HUMAN_REQD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "DROP_IND = i2 CCL(DROP_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TABLE_SUFFIX = c4 CCL(TABLE_SUFFIX)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "FULL_TABLE_NAME = c30 CCL(FULL_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "SUFFIXED_TABLE_NAME = c18 CCL(SUFFIXED_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "DEFAULT_ROW_IND = i2 CCL(DEFAULT_ROW_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "PERSON_CMB_TRIGGER_TYPE = c10 CCL(PERSON_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ENCNTR_CMB_TRIGGER_TYPE = c10 CCL(ENCNTR_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "MERGE_UI_QUERY = c255 CCL(MERGE_UI_QUERY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "MERGEABLE_IND  = i2 CCL(MERGEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = i2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "MERGE_ACTIVE_IND = i2 CCL(MERGE_ACTIVE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "DATA_DISP_FLAG = i2 CCL(DATA_DISP_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcoldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cd"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2043"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1983"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 19
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CODE_SET = i4 CCL(CODE_SET)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "FLAG_IND = i2 CCL(FLAG_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UNIQUE_IDENT_IND = i2 CCL(UNIQUE_IDENT_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "ROOT_ENTITY_NAME = c30 CCL(ROOT_ENTITY_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "ROOT_ENTITY_ATTR = c30 CCL(ROOT_ENTITY_ATTR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "CONSTANT_VALUE = c255 CCL(CONSTANT_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "PARENT_ENTITY_COL = c30 CCL(PARENT_ENTITY_COL)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "EXCEPTION_FLG = i4 CCL(EXCEPTION_FLG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "DEFINING_ATTRIBUTE_IND = i2 CCL(DEFINING_ATTRIBUTE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "MERGE_UPDATEABLE_IND = i2 CCL(MERGE_UPDATEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "NLS_COL_IND = i2 CCL(NLS_COL_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col =
   "ABSOLUTE_DATE_IND = i2 CCL(ABSOLUTE_DATE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = I2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TZ_RULE_FLAG = I2 CCL(TZ_RULE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtsprec(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tp"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTSPREC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1152"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1118"
   SET dm2_sch_file->qual[dsfcnt].key_size = "34"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 34)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "PRECEDENCE = i4 CCL(PRECEDENCE)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "DATA_TABLESPACE = c30 CCL(DATA_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_EXTENT_SIZE = f8 CCL(DATA_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TABLESPACE = c30 CCL(INDEX_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INDEX_EXTENT_SIZE = f8 CCL(INDEX_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TABLESPACE = c30 CCL(LONG_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "LONG_EXTENT_SIZE = f8 CCL(LONG_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtspace(dsfcnt)
   SET dm2_sch_file->qual[1].file_suffix = "_ts"
   SET dm2_sch_file->qual[1].table_name = "DMTSPACE"
   SET dm2_sch_file->qual[1].db_name = build(dm2_sch_file->qual[1].table_name,dm2_sch_file->sf_ver)
   SET dm2_sch_file->qual[1].size = "1056"
   SET dm2_sch_file->qual[1].data_size = "1026"
   SET dm2_sch_file->qual[1].key_size = "30"
   SET dm2_sch_file->qual[1].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[1].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[1].kqual,dm2_sch_file->qual[1].key_cnt)
   SET dm2_sch_file->qual[1].kqual[1].key_col = "TSPACE_NAME = c30  CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[1].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[1].dqual,dm2_sch_file->qual[1].data_cnt)
   SET dm2_sch_file->qual[1].dqual[1].data_col = "BYTES_NEEDED = f8  CCL(BYTES_NEEDED)"
   SET dm2_sch_file->qual[1].dqual[2].data_col = "EXT_MGMT = c10 CCL(EXT_MGMT)"
   SET dm2_sch_file->qual[1].dqual[3].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[1].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_files(dlsf_desc,dlsf_process_option)
   DECLARE dlsf_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_i_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_ic_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_c_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_cc_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ind_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_icol_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_cons_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ccol_cnt = i4 WITH protect, noconstant(0)
   IF ((cur_sch->tbl_cnt <= 0))
    SET dm_err->eproc = "NO TABLES IN CURRENT SCHEMA"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No tables found for the schema snapshot."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FOR (dlsf_tbl_cnt = 1 TO value(cur_sch->tbl_cnt))
     SET cur_sch->tbl[dlsf_tbl_cnt].capture_ind = 1
   ENDFOR
   SET dm_err->eproc = "POPULATE DMHEADER SCHEMA FILE WITH HEADER INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmheader dh
    SET dh.description = dlsf_desc, dh.admin_load_ind = 0, dh.source_rdbms = currdb,
     dh.sf_version = 1
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMTABLE SCHEMA FILE WITH TABLE INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmtable t,
     (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    SET t.seq = 1, t.table_name = cur_sch->tbl[d.seq].tbl_name, t.tablespace_name = cur_sch->tbl[d
     .seq].tspace_name,
     t.index_tspace = dm2_dft_clin_itspace, t.index_tspace_ni = 0, t.long_tspace = cur_sch->tbl[d.seq
     ].long_tspace,
     t.long_tspace_ni = cur_sch->tbl[d.seq].long_tspace_ni, t.init_ext = cur_sch->tbl[d.seq].init_ext,
     t.next_ext = cur_sch->tbl[d.seq].next_ext,
     t.pct_increase = cur_sch->tbl[d.seq].pct_increase, t.pct_used = cur_sch->tbl[d.seq].pct_used, t
     .pct_free = cur_sch->tbl[d.seq].pct_free,
     t.bytes_allocated = cur_sch->tbl[d.seq].bytes_allocated, t.bytes_used = cur_sch->tbl[d.seq].
     bytes_used, t.schema_date = cur_sch->tbl[d.seq].schema_date,
     t.schema_instance = cur_sch->tbl[d.seq].schema_instance, t.alpha_feature_nbr = 0, t
     .feature_number = 0,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.tspace_type = cur_sch->tbl[d.seq].ext_mgmt, t
     .long_tspace_type = cur_sch->tbl[d.seq].lext_mgmt,
     t.max_ext = cur_sch->tbl[d.seq].max_ext
    PLAN (d
     WHERE (cur_sch->tbl[d.seq].capture_ind=1))
     JOIN (t
     WHERE (cur_sch->tbl[d.seq].tbl_name=t.table_name))
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMCOLUMN SCHEMA FILE WITH COLUMN INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].tbl_col_cnt > dlsf_max_tc_cnt))
      dlsf_max_tc_cnt = cur_sch->tbl[d.seq].tbl_col_cnt
     ENDIF
     dlsf_tc_cnt = (dlsf_tc_cnt+ cur_sch->tbl[d.seq].tbl_col_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_tc_cnt > 0)
    INSERT  FROM dmcolumn tc,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_tc_cnt))
     SET tc.seq = 1, tc.table_name = cur_sch->tbl[d.seq].tbl_name, tc.column_name = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].col_name,
      tc.column_seq = cur_sch->tbl[d.seq].tbl_col[d2.seq].col_seq, tc.data_type = cur_sch->tbl[d.seq]
      .tbl_col[d2.seq].data_type, tc.data_length = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_length,
      tc.nullable = cur_sch->tbl[d.seq].tbl_col[d2.seq].nullable, tc.data_default = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].data_default, tc.data_default_ni = cur_sch->tbl[d.seq].tbl_col[d2.seq].
      data_default_ni,
      tc.data_default2 = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_default, tc.virtual_column =
      cur_sch->tbl[d.seq].tbl_col[d2.seq].virtual_column
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].tbl_col_cnt))
      JOIN (tc
      WHERE (cur_sch->tbl[d.seq].tbl_name=tc.table_name)
       AND (cur_sch->tbl[d.seq].tbl_col[d2.seq].col_name=tc.column_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("No column information found for tables.",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMINDEX SCHEMA FILE WITH INDEX INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].ind_cnt > dlsf_max_i_cnt))
      dlsf_max_i_cnt = cur_sch->tbl[d.seq].ind_cnt
     ENDIF
     dlsf_ind_cnt = (dlsf_ind_cnt+ cur_sch->tbl[d.seq].ind_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_i_cnt > 0)
    INSERT  FROM dmindex i,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     SET i.seq = 1, i.table_name = cur_sch->tbl[d.seq].tbl_name, i.index_name = cur_sch->tbl[d.seq].
      ind[d2.seq].ind_name,
      i.full_ind_name = cur_sch->tbl[d.seq].ind[d2.seq].full_ind_name, i.pct_increase = cur_sch->tbl[
      d.seq].ind[d2.seq].pct_increase, i.pct_free = cur_sch->tbl[d.seq].ind[d2.seq].pct_free,
      i.init_ext = cur_sch->tbl[d.seq].ind[d2.seq].init_ext, i.next_ext = cur_sch->tbl[d.seq].ind[d2
      .seq].next_ext, i.bytes_allocated = cur_sch->tbl[d.seq].ind[d2.seq].bytes_allocated,
      i.bytes_used = cur_sch->tbl[d.seq].ind[d2.seq].bytes_used, i.unique_ind = cur_sch->tbl[d.seq].
      ind[d2.seq].unique_ind, i.tspace_name = cur_sch->tbl[d.seq].ind[d2.seq].tspace_name,
      i.tspace_type = cur_sch->tbl[d.seq].ind[d2.seq].ext_mgmt, i.index_type = cur_sch->tbl[d.seq].
      ind[d2.seq].index_type, i.max_ext = cur_sch->tbl[d.seq].ind[d2.seq].max_ext
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
      JOIN (i
      WHERE (cur_sch->tbl[d.seq].tbl_name=i.table_name)
       AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=i.index_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMINDCOL SCHEMA FILE WITH INDEX COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt > dlsf_max_ic_cnt))
       dlsf_max_ic_cnt = cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt
      ENDIF
      dlsf_icol_cnt = (dlsf_icol_cnt+ cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_ic_cnt > 0)
     INSERT  FROM dmindcol ic,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_i_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_ic_cnt))
      SET ic.seq = 1, ic.table_name = cur_sch->tbl[d.seq].tbl_name, ic.index_name = cur_sch->tbl[d
       .seq].ind[d2.seq].ind_name,
       ic.column_name = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name, ic.column_position
        = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt))
       JOIN (ic
       WHERE (cur_sch->tbl[d.seq].tbl_name=ic.table_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=ic.index_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name=ic.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for indexes.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "POPULATE DMCONS SCHEMA FILE WITH CONSTRAINT INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].cons_cnt > dlsf_max_c_cnt))
      dlsf_max_c_cnt = cur_sch->tbl[d.seq].cons_cnt
     ENDIF
     dlsf_cons_cnt = (dlsf_cons_cnt+ cur_sch->tbl[d.seq].cons_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_c_cnt > 0)
    INSERT  FROM dmcons c,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     SET c.seq = 1, c.table_name = cur_sch->tbl[d.seq].tbl_name, c.constraint_name = cur_sch->tbl[d
      .seq].cons[d2.seq].cons_name,
      c.full_cons_name = cur_sch->tbl[d.seq].cons[d2.seq].full_cons_name, c.constraint_type = cur_sch
      ->tbl[d.seq].cons[d2.seq].cons_type, c.status_ind = cur_sch->tbl[d.seq].cons[d2.seq].status_ind,
      c.r_constraint_name = cur_sch->tbl[d.seq].cons[d2.seq].r_constraint_name, c.parent_table_name
       = cur_sch->tbl[d.seq].cons[d2.seq].parent_table, c.parent_table_columns = cur_sch->tbl[d.seq].
      cons[d2.seq].parent_table_columns,
      c.delete_rule = cur_sch->tbl[d.seq].cons[d2.seq].delete_rule
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
      JOIN (c
      WHERE (cur_sch->tbl[d.seq].tbl_name=c.table_name)
       AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=c.constraint_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMCONSCOL SCHEMA FILE WITH CONSTRAINT COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt > dlsf_max_cc_cnt))
       dlsf_max_cc_cnt = cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt
      ENDIF
      dlsf_ccol_cnt = (dlsf_ccol_cnt+ cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_cc_cnt > 0)
     INSERT  FROM dmconscol cc,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_c_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_cc_cnt))
      SET cc.seq = 1, cc.table_name = cur_sch->tbl[d.seq].tbl_name, cc.constraint_name = cur_sch->
       tbl[d.seq].cons[d2.seq].cons_name,
       cc.column_name = cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name, cc.position =
       cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt))
       JOIN (cc
       WHERE (cur_sch->tbl[d.seq].tbl_name=cc.table_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=cc.constraint_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name=cc.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for constraints.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_sch_files(null)
   DECLARE dsf_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsf_name = vc WITH protect, noconstant("")
   FOR (dsf_cnt = 1 TO dm2_sch_file->file_cnt)
     SET dsf_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[dsf_cnt].file_suffix
       ))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".idx"))=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_sch_files_inc
 IF (validate(cur_sch->tbl_cnt,- (1)) < 0)
  FREE RECORD cur_sch
  RECORD cur_sch(
    1 rdbms = vc
    1 mviews_active_ind = i2
    1 dm_info_exists_ind = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 tbl_name = vc
      2 tspace_name = vc
      2 long_tspace = vc
      2 long_tspace_ni = i2
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 capture_ind = i2
      2 schema_date = dq8
      2 schema_instance = i4
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 row_cnt = f8
      2 ext_mgmt = c1
      2 lext_mgmt = c1
      2 max_ext = f8
      2 reference_ind = i2
      2 mview_flag = i2
      2 mview_exists_ind = i2
      2 mview_syn_status = vc
      2 ddl_excl_ind = i2
      2 rowdeps_ind = i2
      2 tbl_col_cnt = i4
      2 partitioned_ind = i2
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 virtual_column = vc
        3 hidden_column = vc
      2 ind_cnt = i4
      2 ind_tspace = vc
      2 ind_tspace_ni = i2
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 tspace_name = vc
        3 tspace_name_ni = i2
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 unique_ind = i2
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_change_ind = i2
        3 ext_mgmt = c1
        3 max_ext = f8
        3 visibility = vc
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 ddl_excl_ind = i2
        3 partitioned_ind = i2
        3 cur_cons_idx = i4
        3 cur_tmp_cons_idx = i4
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 r_constraint_name = vc
        3 orig_r_cons_name = vc
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 delete_rule = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 fk_cnt = i4
        3 fk[*]
          4 tbl_ndx = i4
          4 cons_ndx = i4
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 ext_mgmt = c1
      2 pct_increase = f8
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 capture_ind = i2
  )
  SET cur_sch->tbl_cnt = 0
 ENDIF
 IF (validate(tgtsch->tbl_cnt,- (1)) < 0)
  FREE RECORD tgtsch
  RECORD tgtsch(
    1 source_rdbms = vc
    1 schema_date = dq8
    1 alpha_feature_nbr = i4
    1 diff_ind = i2
    1 warn_ind = i2
    1 tbl_cnt = i4
    1 ddl_excl_ind = i2
    1 tbl[*]
      2 tbl_name = vc
      2 longlob_col_cnt = i4
      2 gtt_flag = i2
      2 last_analyzed_dt_tm = dq8
      2 orig_tbl_name = vc
      2 full_tbl_name = vc
      2 suff_tbl_name = vc
      2 new_ind = i2
      2 diff_ind = i2
      2 warn_ind = i2
      2 combine_ind = i2
      2 reference_ind = i4
      2 child_tbl_ind = i2
      2 tspace_name = vc
      2 cur_idx = i4
      2 row_cnt = f8
      2 cur_bytes_allocated = f8
      2 cur_bytes_used = f8
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 size = f8
      2 ind_size = f8
      2 long_size = f8
      2 total_space = f8
      2 free_space = f8
      2 schema_date = dq8
      2 schema_instance = i4
      2 alpha_feature_nbr = i4
      2 feature_number = i4
      2 updt_dt_tm = dq8
      2 long_tspace = vc
      2 dext_mgmt = c1
      2 iext_mgmt = c1
      2 lext_mgmt = c1
      2 ttspace_new_ind = i2
      2 itspace_new_ind = i2
      2 ltspace_new_ind = i2
      2 table_suffix = vc
      2 logical_rowid_column_ind = i2
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 afd_schema_instance = i4
      2 pull_from_afd = i2
      2 rowid_col_fnd = i2
      2 xrid_ind_fnd = i2
      2 ttsp_set_ind = i2
      2 itsp_set_ind = i2
      2 ltsp_set_ind = i2
      2 new_lob_col_ind = i2
      2 ttspace_assignment_choice = vc
      2 itspace_assignment_choice = vc
      2 ltspace_assignment_choice = vc
      2 tbl_col_cnt = i4
      2 max_ext = f8
      2 ind_rename_cnt = i4
      2 ind_replace_cnt = i4
      2 ddl_excl_ind = i2
      2 clu_idx = i2
      2 rowdeps_ind = i2
      2 metadata_loc_flg = i2
      2 part_ind = i2
      2 part_active_ind = i2
      2 partitioning_type = vc
      2 subpartitioning_type = vc
      2 partition_count = i4
      2 subpartition_count = i4
      2 interval = vc
      2 autolist = vc
      2 indexing_off_ind = i2
      2 row_mvmnt_ind = i2
      2 part_col_cnt = i4
      2 part_col[*]
        3 column_name = vc
        3 position = i2
      2 subpart_col_cnt = i4
      2 subpart_col[*]
        3 column_name = vc
        3 position = i2
      2 part_tsp_cnt = i4
      2 part_tsp[*]
        3 tablespace_name = vc
      2 subpart_tsp_cnt = i4
      2 subpart_tsp[*]
        3 tablespace_name = vc
      2 part_cnt = i4
      2 part[*]
        3 template_ind = i2
        3 indexing_off_ind = i2
        3 partition_name = vc
        3 subpartition_name = vc
        3 high_value = vc
        3 partition_position = i2
        3 subpartition_position = i2
        3 tablespace_name = vc
      2 ind_rename[*]
        3 cur_ind_name = vc
        3 temp_ind_name = vc
        3 final_ind_name = vc
        3 drop_cur_ind = i2
        3 drop_temp_ind = i2
        3 rename_cur_ind = i2
        3 rename_temp_ind = i2
        3 cur_ind_tspace_name = vc
        3 cur_ind_idx = i4
        3 drop_early_ind = i2
        3 ddl_excl_ind = i2
        3 rename_with_drop_ind = i2
      2 ind_replace[*]
        3 ind_name = vc
        3 temp_ind_name = vc
      2 ind_rebuild_cnt = i4
      2 ind_rebuild[*]
        3 initial_ind_name = vc
        3 interm_ind_name = vc
        3 final_ind_name = vc
        3 cons_name = vc
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 new_ind = i2
        3 diff_dtype_ind = i2
        3 diff_dlength_ind = i2
        3 diff_nullable_ind = i2
        3 null_to_notnull_ind = i2
        3 diff_default_ind = i2
        3 cur_idx = i4
        3 size = f8
        3 diff_backfill = i2
        3 backfill_op_exists = i2
        3 virtual_column = vc
        3 part_ind = i2
        3 part_active_ind = i2
        3 lob_part_cnt = i4
        3 lob_part[*]
          4 template_ind = i2
          4 partition_name = vc
          4 subpartition_name = vc
          4 partition_position = i2
          4 subpartition_position = i2
          4 tablespace_name = vc
      2 ind_tspace = vc
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 size = f8
        3 unique_ind = i2
        3 cur_bytes_allocated = f8
        3 cur_bytes_used = f8
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_ind = i2
        3 visibility_change_ind = i2
        3 part_ind = i2
        3 rebuild_ind = i2
        3 part_active_ind = i2
        3 partitioning_type = vc
        3 subpartitioning_type = vc
        3 partition_count = i4
        3 subpartition_count = i4
        3 interval = vc
        3 autolist = vc
        3 locality = vc
        3 partial_ind = i2
        3 part_col_cnt = i4
        3 part_col[*]
          4 column_name = vc
          4 position = i2
        3 part_tsp_cnt = i4
        3 part_tsp[*]
          4 tablespace_name = vc
        3 subpart_tsp_cnt = i4
        3 subpart_tsp[*]
          4 tablespace_name = vc
        3 part_cnt = i4
        3 part[*]
          4 partition_name = vc
          4 subpartition_name = vc
          4 high_value = vc
          4 partition_position = i2
          4 subpartition_position = i2
          4 tablespace_name = vc
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_unique_ind = i2
        3 diff_col_ind = i2
        3 diff_cons_ind = i2
        3 diff_type_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 rename_ind = i2
        3 replace_ind = i2
        3 temp_ind = i2
        3 tspace_name = vc
        3 ext_mgmt = c1
        3 max_ext = f8
        3 ddl_excl_ind = i2
      2 ind_drop_cnt = i4
      2 ind_drop[*]
        3 ind_name = vc
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 r_constraint_name = vc
        3 index_idx = i4
        3 delete_rule = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_col_ind = i2
        3 diff_status_ind = i2
        3 diff_parent_ind = i2
        3 diff_ind_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 fk_cnt = i4
        3 ddl_excl_ind = i2
      2 cons_drop_cnt = i4
      2 cons_drop[*]
        3 cons_name = vc
        3 cons_type = c1
        3 cur_cons_idx = i4
        3 ddl_excl_ind = i2
      2 mview_flag = i2
      2 mview_cc_build_ind = i2
      2 mview_build_ind = i2
      2 mview_log_cnt = i2
      2 mview_logs[*]
        3 table_name = vc
      2 mview_piece_cnt = i2
      2 mview_piece[*]
        3 txt = vc
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 pct_increase = f8
      2 new_ind = i2
      2 cur_idx = i4
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
      2 bytes_free_reqd = f8
      2 min_total_bytes = f8
    1 backfill_ops_cnt = i4
    1 backfill_ops[*]
      2 op_id = f8
      2 gen_dt_tm = dq8
      2 status = vc
      2 reset_backfill = i2
      2 delete_row = i2
      2 table_name = vc
      2 tgt_tbl_idx = i4
      2 col_cnt = i4
      2 col[*]
        3 tgt_col_idx = i4
        3 col_name = vc
      2 backfill_method = vc
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 new_ind = i2
      2 diff_ind = i2
    1 tspace_diff_ind = i2
    1 user_cnt = i4
    1 user[*]
      2 new_ind = i2
      2 diff_ind = i2
      2 user_name = vc
      2 instance = i4
      2 cur_instance = i4
      2 pull_from_admin = i2
      2 default_tspace = vc
      2 default_tspace_size = f8
      2 temp_tspace = vc
      2 temp_tspace_size = f8
      2 priv_cnt = i4
      2 privs[*]
        3 priv_name = vc
      2 quota_cnt = i4
      2 quota[*]
        3 tspace_name = vc
    1 clu_cnt = i4
    1 clu[*]
      2 cluster_name = vc
      2 table_name = vc
      2 cluster_tsp_name = vc
      2 index_name = vc
      2 cluster_index_tsp_name = vc
      2 col_list_def = vc
      2 new_ind = i2
      2 clucol_cnt = i4
      2 clucol[*]
        3 column_name = vc
        3 data_type = vc
        3 data_length = i4
        3 col_pos = i2
  )
  SET tgtsch->tbl_cnt = 0
  SET tgtsch->backfill_ops_cnt = 0
  SET tgtsch->user_cnt = 0
  SET tgtsch->tspace_cnt = 0
 ENDIF
 SET dm_err->logfile = "dm2_cso_logfile"
 DECLARE x_header = vc
 SET x_header = "Schema install driver output log"
 CALL init_logfile(value(dm_err->logfile),x_header)
 DECLARE cs_sch_date_str = vc
 DECLARE cs_sch_date_fmt = f8
 DECLARE cs_file_prefix = vc
 DECLARE cs_dest_dir = vc
 DECLARE mod_ind = i2
 DECLARE call_from_capture = i2
 DECLARE max_tc_cnt = i4
 DECLARE max_i_cnt = i2
 DECLARE max_ic_cnt = i2
 DECLARE max_c_cnt = i2
 DECLARE max_cc_cnt = i2
 DECLARE dm2_call_prog = vc WITH public, noconstant("DM2_CAPTURE_SCHEMA")
 DECLARE cs_af_nbr = i4
 SET af_nbr =  $2
 SET f_nbr = 8888
 SET cs_sch_date_str =  $1
 IF (cursys="AIX")
  SET cs_dest_dir = "$CCLUSERDIR"
 ELSE
  SET cs_dest_dir = "CCLUSERDIR"
 ENDIF
 SET cs_sch_date_fmt = cnvtdate2(cs_sch_date_str,"DD-MMM-YYYY")
 SET cs_file_prefix = cnvtalphanum(format(cs_sch_date_fmt,"MM/DD/YYYY;;D"))
 SET af_file_prefix = build(cnvtstring(af_nbr),"ocd")
 SET mod_ind = 1
 SET call_from_capture = 1
 CALL create_sch_files(af_file_prefix,cs_dest_dir)
 CALL open_sch_files(mod_ind,af_file_prefix,"CCLUSERDIR")
 EXECUTE dm2_get_cursch
 INSERT  FROM dmheader dh
  SET dh.admin_load_ind = 1, dh.source_rdbms = currdb
  WITH nocounter
 ;end insert
 INSERT  FROM dmtspace ts,
   (dummyt d  WITH seq = value(cur_sch->tspace_cnt))
  SET ts.tablespace_name = cur_sch->tspace[d.seq].tspace_name, ts.init_extent = cur_sch->tspace[d.seq
   ].initial_extent, ts.next_extent = cur_sch->tspace[d.seq].next_extent,
   ts.pct_increase = cur_sch->tspace[d.seq].pct_increase, ts.tspace_type = cur_sch->tspace[d.seq].
   tspace_type, ts.tspace_type_ni = cur_sch->tspace[d.seq].tspace_type_ni,
   ts.pagesize = cur_sch->tspace[d.seq].pagesize, ts.nodegroup = cur_sch->tspace[d.seq].nodegroup, ts
   .nodegroup_ni = cur_sch->tspace[d.seq].nodegroup_ni,
   ts.bufferpool_name = cur_sch->tspace[d.seq].bufferpool_name, ts.bufferpool_name_ni = cur_sch->
   tspace[d.seq].bufferpool_name_ni, ts.schema_date = cnvtdatetime(cs_sch_date_str),
   ts.alpha_feature_nbr = af_nbr, ts.feature_number = f_nbr, ts.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  PLAN (d)
   JOIN (ts
   WHERE (cur_sch->tspace[d.seq].tspace_name=ts.tablespace_name))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 INSERT  FROM dmtable t,
   (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
  SET t.table_name = cur_sch->tbl[d.seq].tbl_name, t.tablespace_name = cur_sch->tbl[d.seq].
   tspace_name, t.index_tspace = cur_sch->tbl[d.seq].ind_tspace,
   t.index_tspace_ni = cur_sch->tbl[d.seq].ind_tspace_ni, t.long_tspace = cur_sch->tbl[d.seq].
   long_tspace, t.long_tspace_ni = cur_sch->tbl[d.seq].long_tspace_ni,
   t.init_ext = cur_sch->tbl[d.seq].init_ext, t.next_ext = cur_sch->tbl[d.seq].next_ext, t
   .pct_increase = cur_sch->tbl[d.seq].pct_increase,
   t.pct_used = cur_sch->tbl[d.seq].pct_used, t.pct_free = cur_sch->tbl[d.seq].pct_free, t
   .schema_date = cnvtdatetime(cs_sch_date_str),
   t.alpha_feature_nbr = af_nbr, t.feature_number = f_nbr, t.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  PLAN (d)
   JOIN (t
   WHERE (cur_sch->tbl[d.seq].tbl_name=t.table_name))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 SET max_tc_cnt = 0
 FOR (cs_cnt1 = 1 TO cur_sch->tbl_cnt)
   IF ((cur_sch->tbl[cs_cnt1].tbl_col_cnt > max_tc_cnt))
    SET max_tc_cnt = cur_sch->tbl[cs_cnt1].tbl_col_cnt
   ENDIF
 ENDFOR
 INSERT  FROM dmcolumn tc,
   (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
   (dummyt d2  WITH seq = value(max_tc_cnt))
  SET tc.table_name = cur_sch->tbl[d.seq].tbl_name, tc.column_name = cur_sch->tbl[d.seq].tbl_col[d2
   .seq].col_name, tc.column_seq = cur_sch->tbl[d.seq].tbl_col[d2.seq].col_seq,
   tc.data_type = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_type, tc.data_length = cur_sch->tbl[d.seq]
   .tbl_col[d2.seq].data_length, tc.nullable = cur_sch->tbl[d.seq].tbl_col[d2.seq].nullable,
   tc.data_default = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_default, tc.data_default_ni = cur_sch->
   tbl[d.seq].tbl_col[d2.seq].data_default_ni
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= cur_sch->tbl[d.seq].tbl_col_cnt))
   JOIN (tc
   WHERE (cur_sch->tbl[d.seq].tbl_name=tc.table_name)
    AND (cur_sch->tbl[d.seq].tbl_col[d2.seq].col_name=tc.column_name))
  WITH nocounter, outerjoin = d2, dontexist
 ;end insert
 SET max_i_cnt = 0
 FOR (cs_cnt1 = 1 TO cur_sch->tbl_cnt)
   IF ((cur_sch->tbl[cs_cnt1].ind_cnt > max_i_cnt))
    SET max_i_cnt = cur_sch->tbl[cs_cnt1].ind_cnt
   ENDIF
 ENDFOR
 INSERT  FROM dmindex i,
   (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
   (dummyt d2  WITH seq = value(max_i_cnt))
  SET i.table_name = cur_sch->tbl[d.seq].tbl_name, i.index_name = cur_sch->tbl[d.seq].ind[d2.seq].
   ind_name, i.full_ind_name = cur_sch->tbl[d.seq].ind[d2.seq].full_ind_name,
   i.tablespace_name = cur_sch->tbl[d.seq].ind[d2.seq].tspace_name, i.tablespace_name_ni = cur_sch->
   tbl[d.seq].ind[d2.seq].tspace_name_ni, i.pct_increase = cur_sch->tbl[d.seq].ind[d2.seq].
   pct_increase,
   i.pct_free = cur_sch->tbl[d.seq].ind[d2.seq].pct_free, i.init_ext = cur_sch->tbl[d.seq].ind[d2.seq
   ].init_ext, i.next_ext = cur_sch->tbl[d.seq].ind[d2.seq].next_ext,
   i.unique_ind = cur_sch->tbl[d.seq].ind[d2.seq].unique_ind
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
   JOIN (i
   WHERE (cur_sch->tbl[d.seq].tbl_name=i.table_name)
    AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=i.index_name))
  WITH nocounter, outerjoin = d2, dontexist
 ;end insert
 SET max_ic_cnt = 0
 FOR (cs_cnt1 = 1 TO cur_sch->tbl_cnt)
   FOR (cs_cnt2 = 1 TO cur_sch->tbl[cs_cnt1].ind_cnt)
     IF ((cur_sch->tbl[cs_cnt1].ind[cs_cnt2].ind_col_cnt > max_ic_cnt))
      SET max_ic_cnt = cur_sch->tbl[cs_cnt1].ind[cs_cnt2].ind_col_cnt
     ENDIF
   ENDFOR
 ENDFOR
 INSERT  FROM dmindcol ic,
   (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
   (dummyt d2  WITH seq = value(max_i_cnt)),
   (dummyt d3  WITH seq = value(max_ic_cnt))
  SET ic.table_name = cur_sch->tbl[d.seq].tbl_name, ic.index_name = cur_sch->tbl[d.seq].ind[d2.seq].
   ind_name, ic.column_name = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name,
   ic.column_position = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_position
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
   JOIN (d3
   WHERE (d3.seq <= cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt))
   JOIN (ic
   WHERE (cur_sch->tbl[d.seq].tbl_name=ic.table_name)
    AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=ic.index_name)
    AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name=ic.column_name))
  WITH nocounter, outerjoin = d3, dontexist
 ;end insert
 SET max_c_cnt = 0
 FOR (cs_cnt1 = 1 TO cur_sch->tbl_cnt)
   IF ((cur_sch->tbl[cs_cnt1].cons_cnt > max_c_cnt))
    SET max_c_cnt = cur_sch->tbl[cs_cnt1].cons_cnt
   ENDIF
 ENDFOR
 INSERT  FROM dmcons c,
   (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
   (dummyt d2  WITH seq = value(max_c_cnt))
  SET c.table_name = cur_sch->tbl[d.seq].tbl_name, c.constraint_name = cur_sch->tbl[d.seq].cons[d2
   .seq].cons_name, c.full_cons_name = cur_sch->tbl[d.seq].cons[d2.seq].full_cons_name,
   c.constraint_type = cur_sch->tbl[d.seq].cons[d2.seq].cons_type, c.status_ind = cur_sch->tbl[d.seq]
   .cons[d2.seq].status_ind, c.r_constraint_name = cur_sch->tbl[d.seq].cons[d2.seq].r_constraint_name,
   c.parent_table_name = cur_sch->tbl[d.seq].cons[d2.seq].parent_table, c.parent_table_columns =
   cur_sch->tbl[d.seq].cons[d2.seq].parent_table_columns
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
   JOIN (c
   WHERE (cur_sch->tbl[d.seq].tbl_name=c.table_name)
    AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=c.constraint_name))
  WITH nocounter, outerjoin = d2, dontexist
 ;end insert
 SET max_cc_cnt = 0
 FOR (cs_cnt1 = 1 TO cur_sch->tbl_cnt)
   FOR (cs_cnt2 = 1 TO cur_sch->tbl[cs_cnt1].cons_cnt)
     IF ((cur_sch->tbl[cs_cnt1].cons[cs_cnt2].cons_col_cnt > max_cc_cnt))
      SET max_cc_cnt = cur_sch->tbl[cs_cnt1].cons[cs_cnt2].cons_col_cnt
     ENDIF
   ENDFOR
 ENDFOR
 INSERT  FROM dmconscol cc,
   (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
   (dummyt d2  WITH seq = value(max_c_cnt)),
   (dummyt d3  WITH seq = value(max_cc_cnt))
  SET cc.table_name = cur_sch->tbl[d.seq].tbl_name, cc.constraint_name = cur_sch->tbl[d.seq].cons[d2
   .seq].cons_name, cc.column_name = cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name,
   cc.position = cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_position
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
   JOIN (d3
   WHERE (d3.seq <= cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt))
   JOIN (cc
   WHERE (cur_sch->tbl[d.seq].tbl_name=cc.table_name)
    AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=cc.constraint_name)
    AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name=cc.column_name))
  WITH nocounter, outerjoin = d3, dontexist
 ;end insert
 IF ((cur_sch->sequence_cnt > 0))
  INSERT  FROM dmseq s,
    (dummyt d  WITH seq = value(cur_sch->sequence_cnt))
   SET s.sequence_name = cur_sch->sequence[d.seq].seq_name, s.min_value = cur_sch->sequence[d.seq].
    min_val, s.max_value = cur_sch->sequence[d.seq].max_val,
    s.increment_by = cur_sch->sequence[d.seq].increment_by, s.cycle_flag = cur_sch->sequence[d.seq].
    cycle_flag, s.schema_date = cnvtdatetime(cs_sch_date_str),
    s.alpha_feature_nbr = af_nbr, s.feature_number = f_nbr, s.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   PLAN (d)
    JOIN (s
    WHERE (cur_sch->sequence[d.seq].seq_name=s.sequence_name))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
 ENDIF
 RECORD dtd(
   1 qual[*]
     2 tname = vc
     2 dms = vc
     2 desc = vc
     2 def = vc
     2 static_rows = i4
     2 updt_cnt = i4
     2 ref_ind = i2
     2 human_reqd_ind = i2
     2 drop_ind = i2
     2 table_suffix = c4
 )
 SET td_cnt = 0
 SELECT INTO "nl:"
  t.*
  FROM dm2_tables_doc t
  ORDER BY t.table_name
  HEAD REPORT
   td_cnt = 0
  DETAIL
   td_cnt = (td_cnt+ 1), stat = alterlist(dtd->qual,td_cnt), dtd->qual[td_cnt].tname = t.table_name,
   dtd->qual[td_cnt].dms = t.data_model_section, dtd->qual[td_cnt].desc = t.description, dtd->qual[
   td_cnt].def = t.definition,
   dtd->qual[td_cnt].static_rows = t.static_rows, dtd->qual[td_cnt].updt_cnt = t.updt_cnt, dtd->qual[
   td_cnt].ref_ind = t.reference_ind,
   dtd->qual[td_cnt].human_reqd_ind = t.human_reqd_ind, dtd->qual[td_cnt].drop_ind = t.drop_ind, dtd
   ->qual[td_cnt].table_suffix = t.table_suffix
  WITH nocounter
 ;end select
 INSERT  FROM dmtbldoc td,
   (dummyt d  WITH seq = value(td_cnt))
  SET td.table_name = dtd->qual[d.seq].tname, td.data_model_section = dtd->qual[d.seq].dms, td
   .description = dtd->qual[d.seq].desc,
   td.definition = dtd->qual[d.seq].def, td.static_rows = dtd->qual[d.seq].static_rows, td.updt_cnt
    = dtd->qual[d.seq].updt_cnt,
   td.reference_ind = dtd->qual[d.seq].ref_ind, td.human_reqd_ind = dtd->qual[d.seq].human_reqd_ind,
   td.drop_ind = dtd->qual[d.seq].drop_ind,
   td.table_suffix = dtd->qual[d.seq].table_suffix
  PLAN (d)
   JOIN (td
   WHERE (dtd->qual[d.seq].tname=td.table_name))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 COMMIT
 FREE RECORD dtd
 RECORD dcd(
   1 qual[*]
     2 tname = vc
     2 cname = vc
     2 sname = vc
     2 cs = i4
     2 desc = vc
     2 def = vc
     2 flag_ind = i2
     2 updt_cnt = i4
     2 unique_ident_ind = i2
     2 re_name = vc
     2 re_attr = vc
     2 const_val = vc
     2 parent_entity_col = vc
     2 exception_flg = i4
     2 defining_attr_ind = i2
     2 merge_updt_ind = i2
     2 nls_col_ind = i2
 )
 SET cd_cnt = 0
 SELECT INTO "nl:"
  t.*
  FROM dm2_columns_doc t
  ORDER BY t.table_name
  HEAD REPORT
   cd_cnt = 0
  DETAIL
   cd_cnt = (cd_cnt+ 1), stat = alterlist(dcd->qual,cd_cnt), dcd->qual[cd_cnt].tname = t.table_name,
   dcd->qual[cd_cnt].cname = t.column_name, dcd->qual[cd_cnt].sname = t.sequence_name, dcd->qual[
   cd_cnt].cs = t.code_set,
   dcd->qual[cd_cnt].desc = t.description, dcd->qual[cd_cnt].def = t.definition, dcd->qual[cd_cnt].
   flag_ind = t.flag_ind,
   dcd->qual[cd_cnt].updt_cnt = t.updt_cnt, dcd->qual[cd_cnt].unique_ident_ind = t.unique_ident_ind,
   dcd->qual[cd_cnt].re_name = t.root_entity_name,
   dcd->qual[cd_cnt].re_attr = t.root_entity_attr, dcd->qual[cd_cnt].const_val = t.constant_value,
   dcd->qual[cd_cnt].parent_entity_col = t.parent_entity_col,
   dcd->qual[cd_cnt].exception_flg = t.exception_flg, dcd->qual[cd_cnt].defining_attr_ind = t
   .defining_attribute_ind, dcd->qual[cd_cnt].merge_updt_ind = t.merge_updateable_ind,
   dcd->qual[cd_cnt].nls_col_ind = t.nls_col_ind
  WITH nocounter
 ;end select
 INSERT  FROM dmcoldoc cd,
   (dummyt d  WITH seq = value(cd_cnt))
  SET cd.table_name = dcd->qual[d.seq].tname, cd.column_name = dcd->qual[d.seq].cname, cd
   .sequence_name = dcd->qual[d.seq].sname,
   cd.code_set = dcd->qual[d.seq].cs, cd.description = dcd->qual[d.seq].desc, cd.definition = dcd->
   qual[d.seq].def,
   cd.flag_ind = dcd->qual[d.seq].flag_ind, cd.updt_cnt = dcd->qual[d.seq].updt_cnt, cd
   .root_entity_name = dcd->qual[d.seq].re_name,
   cd.root_entity_attr = dcd->qual[d.seq].re_attr, cd.constant_value = dcd->qual[d.seq].const_val, cd
   .parent_entity_col = dcd->qual[d.seq].parent_entity_col,
   cd.exception_flg = dcd->qual[d.seq].exception_flg, cd.defining_attribute_ind = dcd->qual[d.seq].
   defining_attr_ind, cd.merge_updateable_ind = dcd->qual[d.seq].merge_updt_ind,
   cd.nls_col_ind = dcd->qual[d.seq].nls_col_ind
  PLAN (d)
   JOIN (cd
   WHERE (dcd->qual[d.seq].tname=cd.table_name)
    AND (dcd->qual[d.seq].cname=cd.column_name))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 COMMIT
END GO
