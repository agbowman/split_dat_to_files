CREATE PROGRAM dm2_utc_setup:dba
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
 IF ((validate(dum_utc_data->uptime_run_id,- (999))=- (999)))
  FREE RECORD dum_utc_data
  RECORD dum_utc_data(
    1 schema_date = dq8
    1 uptime_run_id = f8
    1 downtime_run_id = f8
    1 appl_id = vc
    1 in_process = i2
    1 status = vc
    1 status_desc = vc
    1 schema_changed = i2
    1 offset = i4
    1 dst_ind = i2
    1 mig_utc_pkg_instll_ind = i2
  )
  SET dum_utc_data->uptime_run_id = 0.0
  SET dum_utc_data->downtime_run_id = 0.0
  SET dum_utc_data->appl_id = "DM2NOTSET"
  SET dum_utc_data->in_process = 0
  SET dum_utc_data->status = "DM2NOTSET"
  SET dum_utc_data->status_desc = "DM2NOTSET"
  SET dum_utc_data->schema_changed = 0
  SET dum_utc_data->offset = 0
  SET dum_utc_data->dst_ind = 0
  SET dum_utc_data->mig_utc_pkg_instll_ind = 0
 ENDIF
 IF ((validate(dus_dst_accept->cnt,- (999))=- (999)))
  FREE RECORD dus_dst_accept
  RECORD dus_dst_accept(
    1 cnt = i4
    1 start_year = i4
    1 end_year = i4
    1 method = vc
    1 qual[*]
      2 year = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
  )
  SET dus_dst_accept->method = "DM2NOTSET"
 ENDIF
 IF ((validate(dus_user_list->own_cnt,- (1))=- (1))
  AND (validate(dus_user_list->own_cnt,- (2))=- (2)))
  FREE RECORD dus_user_list
  RECORD dus_user_list(
    1 own_cnt = i2
    1 own[*]
      2 owner_name = vc
    1 cnt = i2
    1 qual[*]
      2 owner_name = vc
      2 table_name = vc
  )
  SET dus_user_list->own_cnt = 0
  SET dus_user_list->cnt = 0
 ENDIF
 IF ((validate(dum_utc_invalid_tables->cnt,- (999))=- (999)))
  FREE RECORD dum_utc_invalid_tables
  RECORD dum_utc_invalid_tables(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
  )
  SET dum_utc_invalid_tables->cnt = 0
 ENDIF
 IF ((validate(dus_std_convert_list->tbl_cnt,- (999))=- (999)))
  FREE RECORD dus_std_convert_list
  RECORD dus_std_convert_list(
    1 tbl_cnt = i2
    1 tbl[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col[*]
        3 column_name = vc
        3 no_convert_ind = i2
  )
  SET dus_std_convert_list->tbl_cnt = 0
 ENDIF
 IF ((validate(dus_date_cols->cnt,- (999))=- (999)))
  FREE RECORD dus_date_cols
  RECORD dus_date_cols(
    1 cnt = i4
    1 qual[*]
      2 tbl_name = vc
      2 col_name = vc
      2 tbl_col_name = vc
      2 dt_type_flag = i2
  )
  SET dus_date_cols->cnt = 0
 ENDIF
 IF ((validate(dus_adm_date_cols->cnt,- (999))=- (999)))
  FREE RECORD dus_adm_date_cols
  RECORD dus_adm_date_cols(
    1 cnt = i4
    1 qual[*]
      2 tbl_name = vc
      2 col_name = vc
      2 tbl_col_name = vc
      2 dt_type_flag = i2
  )
  SET dus_adm_date_cols->cnt = 0
 ENDIF
 IF ((validate(dus_v500_cust->tbl_cnt,- (999))=- (999)))
  FREE RECORD dus_v500_cust
  RECORD dus_v500_cust(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
  )
  SET dus_v500_cust->tbl_cnt = 0
 ENDIF
 DECLARE dum_check_concurrent_snapshot(dcc_mode=c1) = i2
 DECLARE dum_generate_schema_execution_script(dgs_run_id=f8,dgs_pswd=vc,dgs_constr=vc,dgs_file_name=
  vc(ref)) = i2
 DECLARE dum_stop_conversion_runner(dsc_appl_id=vc) = i2
 DECLARE dum_cleanup_stranded_appl_id(null) = i2
 DECLARE dum_check_for_new_run_id(dcf_run_id=f8,dcf_new_id_fnd=i2(ref),dcf_dbname=vc) = i2
 DECLARE dum_auto_dst_date(dadd_beg_year=i4,dadd_end_year=i4) = i2
 DECLARE dum_gen_auto_dst_file(null) = i2
 DECLARE dum_disp_dst_rpt(null) = i2
 DECLARE dum_set_timezone(dst_timezone_name=vc(ref)) = i2
 DECLARE dum_fill_user_list(dful_dbname=vc) = i2
 DECLARE ducm_status_chk(dsc_dbname=vc) = i2
 DECLARE dus_load_spec_cols(dlsc_dbname=vc) = i2
 DECLARE dum_mng_spec_cols(dmsc_dbname=vc) = i2
 DECLARE dum_load_date_columns(dldc_mode=vc,dldc_dbname=vc) = i2
 DECLARE dum_fill_v500_cust(dfvc_dbname=vc) = i2
 DECLARE dum_cust_incl_abort_gen(dciag_tgt_dbname=vc,dciag_src_orcl_ver=vc,dciag_tgt_orcl_ver=vc) =
 i2
 DECLARE dum_daylight_offset = i4 WITH protect, noconstant(0)
 DECLARE dum_offset_sign = c1 WITH protect, noconstant(" ")
 SUBROUTINE dum_check_concurrent_snapshot(dcc_mode)
   DECLARE dcc_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcc_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(dcc_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      dcc_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF ((dcc_appl_id=dum_utc_data->appl_id))
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
      SET dcc_appl_status = dm2_get_appl_status(dcc_appl_id)
      IF (dcc_appl_status="E")
       RETURN(0)
      ELSE
       IF (dcc_appl_status="A")
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
    SET is_snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(is_snapshot_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = currdbhandle,
      di.info_date = cnvtdatetime(is_snapshot_dt_tm), di.updt_applctx = 0, di.updt_cnt = 0,
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
 SUBROUTINE dum_generate_schema_execution_script(dgs_run_id,dgs_pswd,dgs_constr,dgs_file_name)
   DECLARE dgs_file_loc = vc WITH protect, noconstant(" ")
   DECLARE dgs_str1 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str2 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str3 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str4 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str5 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str6 = vc WITH protect, constant(logical("cer_exe"))
   DECLARE dgs_debug_flag = vc WITH protect, noconstant(" ")
   DECLARE dgs_rdbdebug_flag = i2 WITH protect, noconstant(0)
   DECLARE dgs_rdbbind_flag = i2 WITH protect, noconstant(0)
   SET dgs_rdbdebug_flag = trace("RDBDEBUG")
   SET dgs_rdbbind_flag = trace("RDBBIND")
   IF (cursys="AIX")
    SET dgs_file_name = build("ccluserdir:dm2_utc_main_runner_runid",cnvtint(dgs_run_id),".ksh")
   ELSEIF (cursys="AXP")
    SET dgs_file_name = build("ccluserdir:dm2_utc_main_runner_runid",cnvtint(dgs_run_id),".com")
   ENDIF
   SET dgs_debug_flag = cnvtstring(dm_err->debug_flag)
   SET dm_err->eproc = concat("Generate script ",dgs_file_name)
   CALL disp_msg("",dm_err->logfile,0)
   FREE SET dgs_file_loc
   SET logical dgs_file_loc value(dgs_file_name)
   SELECT INTO dgs_file_loc
    FROM (dummyt t  WITH seq = 1)
    DETAIL
     dgs_str1 = concat("Executing schema for run id ",cnvtstring(dgs_run_id)), dgs_str2 =
     "free define oraclesystem go"
     IF (dgs_constr > " ")
      dgs_str3 = concat("define oraclesystem 'v500/",dgs_pswd,"@",dgs_constr,"' go")
     ELSE
      dgs_str3 = concat("define oraclesystem 'v500/",dgs_pswd,"' go")
     ENDIF
     dgs_str4 = concat("execute dm2_utc_execute_schema ",cnvtstring(dgs_run_id)," go")
     IF (cursys="AIX")
      col 0, "#!/usr/bin/ksh", row + 1,
      col 0, "#", row + 1,
      dgs_str5 = concat("# ",trim(dgs_str1)), col 0, dgs_str5,
      row + 1, col 0, "#",
      row + 1, col 0, ". $cer_mgr/",
      CALL print(trim(cnvtlower(logical("environment")))), "_environment.ksh", row + 1,
      col 0, "ccl <<!", row + 1,
      col 0, dgs_str2, row + 1,
      col 0, dgs_str3, row + 1,
      col 0, "set dm2_debug_flag = ", dgs_debug_flag,
      " go", row + 1
      IF (dgs_rdbdebug_flag=1)
       col 0, "set trace rdbdebug go", row + 1
      ENDIF
      IF (dgs_rdbbind_flag=1)
       col 0, "set trace rdbbind go", row + 1
      ENDIF
      row + 1, col 0, "set dm2_utc_process_option = '",
      dm2_install_schema->process_option, "' go", row + 1,
      col 0, dgs_str4, row + 1,
      col 0, dgs_str2, row + 1,
      col 0, "exit", row + 1,
      col 0, "!", row + 1,
      col 0, "sleep 30"
     ELSEIF (cursys="AXP")
      col 0, "$!", row + 1,
      dgs_str5 = concat("$! ",trim(dgs_str1)), col 0, dgs_str5,
      row + 1, col 0, "$!",
      row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
      row + 1, col 0, "$CCL",
      row + 1, col 0, dgs_str2,
      row + 1, col 0, dgs_str3,
      row + 1, col 0, "set dm2_debug_flag = ",
      dgs_debug_flag, " go", row + 1
      IF (dgs_rdbdebug_flag=1)
       col 0, "set trace rdbdebug go", row + 1
      ENDIF
      IF (dgs_rdbbind_flag=1)
       col 0, "set trace rdbbind go", row + 1
      ENDIF
      row + 1, col 0, "set dm2_utc_process_option = '",
      dm2_install_schema->process_option, "' go", row + 1,
      col 0, dgs_str4, row + 1,
      col 0, "exit", row + 1,
      col 0, "$WAIT 00:00:30"
     ENDIF
    FOOT REPORT
     row + 0
    WITH nocounter, maxrow = 1, format = variable,
     formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_stop_conversion_runner(dsc_appl_id)
   SET dm_err->eproc = concat("Stop conversion runners ",dsc_appl_id)
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dsc_runner_active = i2 WITH protect, noconstant(0)
   DECLARE dsc_app_str = vc WITH protect, noconstant(" ")
   DECLARE dsc_app_status = c1 WITH protect, noconstant(" ")
   IF ( NOT (dsc_appl_id IN ("ALL", "PARALLEL", "MAIN")))
    SET dsc_app_status = dm2_get_appl_status(dsc_appl_id)
    IF (dsc_app_status="I")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Stop conversion runners ",dsc_appl_id)
     SET dm_err->emsg = concat("Application ID ",dsc_appl_id," passed in is inactive.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (dsc_app_status="E")
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsc_appl_id="ALL")
    SET dm_err->eproc = "Get application ids need to be inactivated for all UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for all UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (dsc_appl_id="PARALLEL")
    SET dm_err->eproc =
    "Get application ids need to be inactivated for parallel UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_char="PARALLEL_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for parallel UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_char="PARALLEL_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (dsc_appl_id="MAIN")
    SET dm_err->eproc = "Get application ids need to be inactivated for main UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_char="MAIN_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for main UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_char="MAIN_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Get application id need to be inactivated."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_name=dsc_appl_id
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = concat("Inactivate application id ",dsc_appl_id,".")
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_name=dsc_appl_id
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dsc_runner_active = 1
   WHILE (dsc_runner_active=1)
     IF (dum_cleanup_stranded_appl_id(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Verify application id ",dsc_app_str," have been removed.")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
       AND parser(concat("di.info_name in (",dsc_app_str,")"))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      CALL echo("**************************************************")
      CALL echo(
       "Waiting on current DDL operations the conversion runner(s) is working on to finish executing..."
       )
      CALL echo("**************************************************")
      CALL pause(15)
     ELSE
      SET dsc_runner_active = 0
     ENDIF
   ENDWHILE
   IF (dsc_appl_id IN ("ALL", "PARALLEL", "MAIN"))
    SET dm_err->eproc = concat("Stopped ",dsc_appl_id," UTC conversion runners successfully.")
   ELSE
    SET dm_err->eproc = concat("Stopped UTC conversion runner with application id ",dsc_appl_id,
     " successfully.")
   ENDIF
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_cleanup_stranded_appl_id(null)
   SET dm_err->eproc = "Remove inactive application id for UTC Conversion runners."
   CALL disp_msg("",dm_err->logfile,0)
   FREE RECORD dcs_app
   RECORD dcs_app(
     1 cnt = i4
     1 qual[*]
       2 app_id = vc
       2 active_ind = i2
   )
   DECLARE dcs_app_status = c1 WITH protect, noconstant(" ")
   DECLARE dcs_inactive_fnd = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Query dm_info for a distinct list of application ids."
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
    HEAD REPORT
     dcs_app->cnt = 0
    DETAIL
     dcs_app->cnt = (dcs_app->cnt+ 1)
     IF (mod(dcs_app->cnt,10)=1)
      stat = alterlist(dcs_app->qual,(dcs_app->cnt+ 9))
     ENDIF
     dcs_app->qual[dcs_app->cnt].app_id = trim(di.info_name), dcs_app->qual[dcs_app->cnt].active_ind
      = 0
    FOOT REPORT
     stat = alterlist(dcs_app->qual,dcs_app->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dcs_i = 1 TO dcs_app->cnt)
    SET dcs_app_status = dm2_get_appl_status(dcs_app->qual[dcs_i].app_id)
    IF (dcs_app_status="A")
     SET dcs_app->qual[dcs_i].active_ind = 1
    ELSEIF (dcs_app_status="I")
     SET dcs_inactive_fnd = 1
    ELSEIF (dcs_app_status="E")
     RETURN(0)
    ENDIF
   ENDFOR
   IF (dcs_inactive_fnd=1)
    SET dm_err->eproc = "Delete inactive application id from DM_INFO table."
    DELETE  FROM dm_info di,
      (dummyt t  WITH seq = value(dcs_app->cnt))
     SET di.seq = 1
     PLAN (t
      WHERE (dcs_app->qual[t.seq].active_ind=0))
      JOIN (di
      WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
       AND (di.info_name=dcs_app->qual[t.seq].app_id))
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
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_check_for_new_run_id(dcf_run_id,dcf_new_id_fnd,dcf_dbname)
   DECLARE dcf_max_run_id = f8 WITH protect, noconstant(0.0)
   SET dcf_new_id_fnd = 0
   SET dm_err->eproc = build("Find max run_id that is greater than ",dcf_run_id,
    " in DM2_DDL_OPS table.")
   SELECT
    IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
     FROM dm2_ddl_ops@ref_data_link d
     ORDER BY d.run_id
    ELSE
     FROM dm2_ddl_ops d
     WHERE d.run_id > dcf_run_id
     ORDER BY d.run_id
    ENDIF
    INTO "nl:"
    HEAD REPORT
     row + 0
    FOOT REPORT
     dcf_max_run_id = d.run_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Determine if new_run_id is found."
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(dcf_dbname,"_UTC_DATA")))
      AND di.info_name="POST_UTC_RUN_IDS"
      AND di.info_number >= dcf_max_run_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dcf_new_id_fnd = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_auto_dst_date(dadd_beg_year,dadd_end_year)
   DECLARE dadd_spr_beg_month = vc WITH protect, constant("MAR")
   DECLARE dadd_spr_end_month = i2 WITH protect, constant(6)
   DECLARE dadd_fall_beg_month = vc WITH protect, constant("SEP")
   DECLARE dadd_fall_end_month = i2 WITH protect, constant(12)
   DECLARE dadd_continue = i2 WITH protect, noconstant(0)
   DECLARE dadd_loop = i2 WITH protect, noconstant(0)
   DECLARE dadd_fnd_dst_beg = i2 WITH protect, noconstant(0)
   DECLARE dadd_fnd_dst_end = i2 WITH protect, noconstant(0)
   DECLARE dadd_temp_year = i2 WITH protect, noconstant(0)
   DECLARE dadd_beg_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dadd_end_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dadd_hr1 = i2 WITH protect, noconstant(0)
   DECLARE dadd_hr2 = i2 WITH protect, noconstant(0)
   SET dus_dst_accept->cnt = 0
   SET stat = alterlist(dus_dst_accept->qual,0)
   SET dus_dst_accept->start_year = dadd_beg_year
   SET dus_dst_accept->end_year = dadd_end_year
   SET dus_dst_accept->method = "AUTO_DETECT"
   SET dadd_continue = 1
   SET dadd_temp_year = dadd_beg_year
   SET dm_err->eproc = "Auto detecting DST datetime range."
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   WHILE (dadd_continue=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo("-----------------------------------------------------------------")
      CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"..."))
     ENDIF
     SET dadd_loop = 1
     SET dadd_fnd_dst_beg = 0
     SET dadd_beg_date = cnvtdatetime(build("01-",trim(dadd_spr_beg_month),"-",dadd_temp_year,
       " 00:00:00"))
     WHILE (dadd_loop=1)
      IF (cnvtdatetimeutc(dadd_beg_date,3)=cnvtdatetimeutc(cnvtlookahead("1,H",cnvtdatetimeutc(
         dadd_beg_date,0)),3))
       SET dadd_fnd_dst_beg = 1
       SET dadd_loop = 0
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("  Local Start Date: ",format(cnvtdatetime(dadd_beg_date),";;q")))
        CALL echo(concat("  Local Start Date (UTC): ",format(cnvtdatetimeutc(dadd_beg_date,3),";;q"))
         )
        CALL echo(concat("  Local Start Date +1 hour (UTC): ",format(cnvtdatetimeutc(cnvtlookahead(
             "1,H",cnvtdatetimeutc(dadd_beg_date,0)),3),";;q")))
       ENDIF
       SET dadd_beg_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_beg_date,0))
      ENDIF
      IF (dadd_fnd_dst_beg=0)
       SET dadd_beg_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_beg_date,0))
       IF (month(dadd_beg_date)=dadd_spr_end_month)
        SET dadd_loop = 0
       ENDIF
      ENDIF
     ENDWHILE
     SET dadd_loop = 1
     SET dadd_fnd_dst_end = 0
     SET dadd_end_date = cnvtdatetime(build("02-",trim(dadd_fall_beg_month),"-",dadd_temp_year,
       " 00:00:00"))
     IF (dadd_fnd_dst_beg=1)
      WHILE (dadd_loop=1)
        SET dadd_hr1 = hour(cnvtdatetimeutc(cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0)),3))
        SET dadd_hr2 = hour(cnvtdatetimeutc(dadd_end_date,3))
        IF (((dadd_hr1 - dadd_hr2)=2))
         SET dadd_fnd_dst_end = 1
         SET dadd_loop = 0
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("  Local End Date: ",format(cnvtdatetime(dadd_end_date),";;q")))
          CALL echo(concat("  Local End Date (UTC): ",format(cnvtdatetimeutc(dadd_end_date,3),";;q"))
           )
          CALL echo(concat("  Local End Date +1 hour (UTC): ",format(cnvtdatetimeutc(cnvtlookahead(
               "1,H",cnvtdatetimeutc(dadd_end_date,0)),3),";;q")))
         ENDIF
         SET dadd_end_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0))
         SET dadd_end_date = cnvtlookbehind("1,S",cnvtdatetimeutc(dadd_end_date,0))
        ENDIF
        IF (dadd_fnd_dst_end=0)
         SET dadd_end_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0))
         IF (month(dadd_end_date)=dadd_fall_end_month)
          SET dadd_loop = 0
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     IF (dadd_fnd_dst_beg=1
      AND dadd_fnd_dst_end=1)
      SET dus_dst_accept->cnt = (dus_dst_accept->cnt+ 1)
      SET stat = alterlist(dus_dst_accept->qual,dus_dst_accept->cnt)
      SET dus_dst_accept->qual[dus_dst_accept->cnt].year = trim(cnvtstring(dadd_temp_year))
      SET dus_dst_accept->qual[dus_dst_accept->cnt].start_dt_tm = dadd_beg_date
      SET dus_dst_accept->qual[dus_dst_accept->cnt].end_dt_tm = dadd_end_date
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"...DST starts at ",format(cnvtdatetime(
           dadd_beg_date),";;q")," and ends at ",format(cnvtdatetime(dadd_end_date),";;q")))
      ENDIF
     ELSEIF (dadd_fnd_dst_beg=0
      AND dadd_fnd_dst_end=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"...did not observe DST during this year"))
      ENDIF
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find DST end datetime for year ",trim(cnvtstring(
         dadd_temp_year))," when DST begin datetime is found.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dadd_temp_year=dadd_end_year)
      SET dadd_continue = 0
     ELSE
      SET dadd_temp_year = (dadd_temp_year+ 1)
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_dst_accept)
   ENDIF
   IF ((dus_dst_accept->cnt > 0))
    IF (dum_gen_auto_dst_file(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_gen_auto_dst_file(null)
   DECLARE dgadf_file_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dgadf_str = vc WITH protect, noconstant("")
   IF (get_unique_file("dm2_utc_dst_input",".dat")=0)
    RETURN(0)
   ENDIF
   SET dgadf_file_name = concat(dm2_install_schema->ccluserdir,dm_err->unique_fname)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file_name = ",dgadf_file_name))
   ENDIF
   SET dm_err->eproc = concat("Generate file ",dgadf_file_name,".")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dgadf_file_name)
    FROM (dummyt t  WITH seq = 1)
    HEAD REPORT
     cnt = 0
    DETAIL
     col 0, "YEAR,START_DT_TM,END_DT_TM", row + 1
     FOR (cnt = 1 TO dus_dst_accept->cnt)
       dgadf_str = concat(dus_dst_accept->qual[cnt].year,",",format(cnvtdatetime(dus_dst_accept->
          qual[cnt].start_dt_tm),"DD-MMM-YYYY HH:MM:SS;;D"),",",format(cnvtdatetime(dus_dst_accept->
          qual[cnt].end_dt_tm),"DD-MMM-YYYY HH:MM:SS;;D"))
       IF ((dm_err->debug_flag > 0))
        CALL echo(dgadf_str)
       ENDIF
       col 0, dgadf_str, row + 1
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_disp_dst_rpt(dddr_timezone_name)
   DECLARE dddr_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "UTC Conversion Daylight Savings Time Setting Confirmation"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO mine
    FROM (dummyt d  WITH seq = value(dus_dst_accept->cnt))
    ORDER BY dus_dst_accept->qual[d.seq].year
    HEAD REPORT
     col 0, "UTC Conversion Daylight Savings Time Setting Confirmation", row + 2,
     col 0, "TIME ZONE : ", col 13,
     dddr_timezone_name, col 50, "STANDARD OFFSET : ",
     dddr_str = concat(dum_offset_sign,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")), col
     68, dddr_str,
     row + 2, col 0,
     "Please scroll through each Daylight Savings Time (DST) begin and end date/times and review for accuracy.",
     row + 2, col 0, "YEAR",
     col 10, "DST Begin Date Time", col 40,
     "DST End Date Time", row + 1
    DETAIL
     col 0, dus_dst_accept->qual[d.seq].year, dddr_str = format(dus_dst_accept->qual[d.seq].
      start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),
     col 10, dddr_str, dddr_str = format(dus_dst_accept->qual[d.seq].end_dt_tm,
      "DD-MMM-YYYY HH:MM:SS;;D"),
     col 40, dddr_str, row + 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_set_timezone(dst_timezone_name)
   SET dst_timezone_name = datetimezonebyindex(curtimezonesys,dum_utc_data->offset,
    dum_daylight_offset)
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("dst_timezone_name = ",dst_timezone_name))
   ENDIF
   IF (dst_timezone_name=" "
    AND (dum_utc_data->offset=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Failed to retrieve Time Zone Name."
    SET dm_err->emsg =
    "Problem with ccl version or the curtimezonesys variable does not have a valid timezone index."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dum_utc_data->offset = ((dum_utc_data->offset/ 1000)/ 60)
    IF ((dum_utc_data->offset < 0))
     SET dum_offset_sign = "-"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("offset = ",dum_utc_data->offset))
     CALL echo(concat(dum_offset_sign,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_fill_user_list(dful_dbname)
   DECLARE dum_pos = i4 WITH protect, noconstant(0)
   DECLARE dum_loc = i4 WITH protect, noconstant(0)
   DECLARE dum_own_name = vc WITH protect, noconstant(" ")
   DECLARE dum_tbl_name = vc WITH protect, noconstant(" ")
   SET dus_user_list->own_cnt = 1
   SET stat = alterlist(dus_user_list->own,dus_user_list->own_cnt)
   SET dus_user_list->own[dus_user_list->own_cnt].owner_name = "V500"
   SET dm_err->eproc = "Loading Non-V500 Users and tables from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dful_dbname,
       "_UTC_DATA - NON-V500 USERS AND TABLES LIST")))
    DETAIL
     dum_loc = findstring("/",di.info_name,1,1)
     IF (dum_loc=0)
      dm_err->err_ind = 1, dm_err->emsg =
      "Missing / in dm2_admin_dm_info row. Valid dm2_admin_dm_info row format is USER/TABLE.",
      CALL cancel(1)
     ENDIF
     dum_own_name = substring(1,(dum_loc - 1),di.info_name), dum_tbl_name = substring((dum_loc+ 1),
      size(di.info_name),di.info_name), dum_pos = 0,
     dum_pos = locateval(dum_pos,1,dus_user_list->own_cnt,trim(cnvtupper(dum_own_name)),dus_user_list
      ->own[dum_pos].owner_name)
     IF (dum_pos=0)
      dus_user_list->own_cnt = (dus_user_list->own_cnt+ 1), stat = alterlist(dus_user_list->own,
       dus_user_list->own_cnt), dus_user_list->own[dus_user_list->own_cnt].owner_name = dum_own_name
     ENDIF
     dus_user_list->cnt = (dus_user_list->cnt+ 1), stat = alterlist(dus_user_list->qual,dus_user_list
      ->cnt), dus_user_list->qual[dus_user_list->cnt].owner_name = dum_own_name,
     dus_user_list->qual[dus_user_list->cnt].table_name = dum_tbl_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_user_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_status_chk(dsc_dbname)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dsc_dbname,"_UTC_DATA")))
     AND di.info_name="SOURCE*"
    DETAIL
     dsc_info_name = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Check for Source Environment/Database ADMIN dm_info row."
    SET dm_err->emsg = "Info_name for Source Environment/Database ADMIN dm_info row does not exist."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_spec_cols(dlsc_dbname)
   DECLARE dls_tbl_name = vc WITH protect, noconstant(" ")
   DECLARE dls_col_name = vc WITH protect, noconstant(" ")
   DECLARE dls_pos = i4 WITH protect, noconstant(0)
   DECLARE dls_tbl_idx = i4 WITH protect, noconstant(0)
   DECLARE dls_col_cnt = i4 WITH protect, noconstant(0)
   SET dus_std_convert_list->tbl_cnt = 0
   SET stat = alterlist(dus_std_convert_list->tbl,dus_std_convert_list->tbl_cnt)
   SET dm_err->eproc =
   "Load V500 table/columns requiring special conversion logic from ADMIN DM_INFO table to record."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dlsc_dbname,"_UTC_DATA - APPLY STD CONVERSION ONLY"
       )))
    HEAD REPORT
     dls_tbl_idx = 0
    DETAIL
     dls_pos = findstring("/",i.info_name,1,1), dls_tbl_name = substring(1,(dls_pos - 1),i.info_name),
     dls_col_name = substring((dls_pos+ 1),size(i.info_name),i.info_name),
     dls_tbl_idx = 0, dls_tbl_idx = locateval(dls_tbl_idx,1,dus_std_convert_list->tbl_cnt,
      dls_tbl_name,dus_std_convert_list->tbl[dls_tbl_idx].table_name)
     IF (dls_tbl_idx=0)
      dus_std_convert_list->tbl_cnt = (dus_std_convert_list->tbl_cnt+ 1)
      IF (mod(dus_std_convert_list->tbl_cnt,10)=1)
       stat = alterlist(dus_std_convert_list->tbl,(dus_std_convert_list->tbl_cnt+ 9))
      ENDIF
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].table_name = dls_tbl_name,
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col_cnt = 1, stat = alterlist(
       dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col,1),
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col[1].column_name = dls_col_name,
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col[1].no_convert_ind = i.info_number
     ELSE
      dus_std_convert_list->tbl[dls_tbl_idx].col_cnt = (dus_std_convert_list->tbl[dls_tbl_idx].
      col_cnt+ 1), dls_col_cnt = dus_std_convert_list->tbl[dls_tbl_idx].col_cnt, stat = alterlist(
       dus_std_convert_list->tbl[dls_tbl_idx].col,dls_col_cnt),
      dus_std_convert_list->tbl[dls_tbl_idx].col[dls_col_cnt].column_name = dls_col_name,
      dus_std_convert_list->tbl[dls_tbl_idx].col[dls_col_cnt].no_convert_ind = i.info_number
     ENDIF
    FOOT REPORT
     stat = alterlist(dus_std_convert_list->tbl,dus_std_convert_list->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_std_convert_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_mng_spec_cols(dmsc_dbname)
   FREE RECORD load_excl_cols
   RECORD load_excl_cols(
     1 cnt = i4
     1 qual[*]
       2 tbl_col_name = vc
       2 info_char = vc
       2 info_num = i2
   )
   DECLARE dmsc_idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(load_excl_cols->qual,0)
   SET load_excl_cols->cnt = 0
   SET dm_err->eproc = "Load Admin master V500 table/columns exclusions from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dmsc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST")
      ))
     AND di.info_number != 1
    HEAD REPORT
     load_excl_cols->cnt = 0
    DETAIL
     load_excl_cols->cnt = (load_excl_cols->cnt+ 1)
     IF (mod(load_excl_cols->cnt,1000)=1)
      stat = alterlist(load_excl_cols->qual,(load_excl_cols->cnt+ 999))
     ENDIF
     load_excl_cols->qual[load_excl_cols->cnt].tbl_col_name = di.info_name, load_excl_cols->qual[
     load_excl_cols->cnt].info_num = 1, load_excl_cols->qual[load_excl_cols->cnt].info_char =
     "LOADED FROM CSV"
    FOOT REPORT
     stat = alterlist(load_excl_cols->qual,load_excl_cols->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((load_excl_cols->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify load of Admin master date list.")
    SET dm_err->emsg = build("Admin master date list does not include any exclusion dates.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load V500 table/columns exclusions from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dmsc_dbname,
       "_UTC_DATA - APPLY STD CONVERSION ONLY")))
    HEAD REPORT
     dmsc_idx = 0
    DETAIL
     dmsc_idx = 0, dmsc_idx = locateval(dmsc_idx,1,load_excl_cols->cnt,cnvtupper(di.info_name),
      load_excl_cols->qual[dmsc_idx].tbl_col_name)
     IF (dmsc_idx > 0)
      IF (di.info_number != 1)
       dm_err->err_ind = 1, dm_err->emsg = concat("Invalid Admin DM_INFO row for ",di.info_name,
        "Info_number should always be 1."),
       CALL cancel(1)
      ENDIF
     ELSE
      IF (cnvtupper(di.info_char) != "LOADED FROM CSV")
       load_excl_cols->cnt = (load_excl_cols->cnt+ 1), stat = alterlist(load_excl_cols->qual,
        load_excl_cols->cnt), load_excl_cols->qual[load_excl_cols->cnt].tbl_col_name = di.info_name,
       load_excl_cols->qual[load_excl_cols->cnt].info_num = di.info_number
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(load_excl_cols)
   ENDIF
   SET dm_err->eproc = "Deleting Exclusion rows from Admin DM_INFO."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dmsc_dbname,"_UTC_DATA - APPLY STD CONVERSION ONLY"
       )))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Exclusion rows into Admin DM_INFO."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm2_admin_dm_info di,
     (dummyt d  WITH seq = value(size(load_excl_cols->qual,5)))
    SET di.info_domain = patstring(cnvtupper(build(dmsc_dbname,
        "_UTC_DATA - APPLY STD CONVERSION ONLY"))), di.info_name = load_excl_cols->qual[d.seq].
     tbl_col_name, di.info_number = load_excl_cols->qual[d.seq].info_num,
     di.info_char = load_excl_cols->qual[d.seq].info_char, di.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    PLAN (d)
     JOIN (di
     WHERE (load_excl_cols->qual[d.seq].tbl_col_name=di.info_name))
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_load_date_columns(dldc_mode,dldc_dbname)
   DECLARE dvdc_csv_loc = vc WITH public, constant(concat(dm2_install_schema->cer_install,
     "dm2_date_column_list.csv"))
   DECLARE dvdc_1st_comma_pos = i2 WITH protect, noconstant(0)
   DECLARE dvdc_2nd_comma_pos = i2 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_col_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_dt_type_flag = i2 WITH protect, noconstant(0)
   DECLARE dvdc_csv_rows = i4 WITH protect, noconstant(0)
   DECLARE dvdc_adm_rows_fnd = i2 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_col_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_col_missing_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_mismatch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_exists_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_missing_adm_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_idx = i4 WITH protect, noconstant(0)
   DECLARE dvdc_loop = i4 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_fnd = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_fnd = i4 WITH protect, noconstant(0)
   SET stat = alterlist(dus_date_cols->qual,0)
   SET dus_date_cols->cnt = 0
   IF ( NOT (dldc_mode IN ("V", "C", "I", "U")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verify load date columns mode entered."
    SET dm_err->emsg = concat("Mode ",dldc_mode," is not valid. Valid modes are V, C, I and U.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dldc_mode IN ("C", "I", "U")
    AND size(trim(dldc_dbname,3))=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verify load date columns database name entered."
    SET dm_err->emsg = concat("Database name [",trim(dldc_dbname),
     "] is not valid. Must specify value for check/insert/update mode.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Managing master date columns (",evaluate(dldc_mode,"V","VERIFY","C",
     "CHECK",
     "I","INSERT","UPDATE")," Mode).")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(dvdc_csv_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify file ",dvdc_csv_loc," exists.")
    SET dm_err->emsg = concat(dvdc_csv_loc," is not found.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Load master date column list from csv ",dvdc_csv_loc," into memory.")
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dvdc_csv_loc)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     dus_date_cols->cnt = 0
    DETAIL
     dvdc_csv_rows = (dvdc_csv_rows+ 1)
     IF (r.line != "TABLE_NAME,COLUMN_NAME,DATE_TYPE_FLAG"
      AND findstring(",",r.line,1,0) != findstring(",",r.line,1,1))
      dvdc_1st_comma_pos = findstring(",",r.line,1,0), dvdc_tbl_name = trim(cnvtupper(substring(1,(
         dvdc_1st_comma_pos - 1),r.line)),3), dvdc_2nd_comma_pos = findstring(",",r.line,1,1),
      dvdc_col_name = trim(cnvtupper(substring((dvdc_1st_comma_pos+ 1),((dvdc_2nd_comma_pos -
         dvdc_1st_comma_pos) - 1),r.line)),3), dvdc_dt_type_flag = cnvtint(substring((
        dvdc_2nd_comma_pos+ 1),size(r.line),r.line)), dvdc_tbl_col_name = trim(build(dvdc_tbl_name,
        "/",dvdc_col_name)),
      dvdc_idx = 0, dvdc_idx = locateval(dvdc_idx,1,dus_date_cols->cnt,dvdc_tbl_col_name,
       dus_date_cols->qual[dvdc_idx].tbl_col_name)
      IF (dvdc_idx=0)
       dus_date_cols->cnt = (dus_date_cols->cnt+ 1)
       IF (mod(dus_date_cols->cnt,1000)=1)
        stat = alterlist(dus_date_cols->qual,(dus_date_cols->cnt+ 999))
       ENDIF
       dus_date_cols->qual[dus_date_cols->cnt].tbl_name = dvdc_tbl_name, dus_date_cols->qual[
       dus_date_cols->cnt].col_name = dvdc_col_name, dus_date_cols->qual[dus_date_cols->cnt].
       dt_type_flag = dvdc_dt_type_flag,
       dus_date_cols->qual[dus_date_cols->cnt].tbl_col_name = dvdc_tbl_col_name
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 4))
      CALL echo(r.line)
     ENDIF
    FOOT REPORT
     stat = alterlist(dus_date_cols->qual,dus_date_cols->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dus_date_cols)
   ENDIF
   IF ((dus_date_cols->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify load of CSV master date list.")
    SET dm_err->emsg = build("CSV file empty.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dvdc_csv_rows - 1) != dus_date_cols->cnt))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat(
     "Verify number of rows in CSV matches with the count loaded into record structure.")
    SET dm_err->emsg = build("CSV content invalid or duplicates exist.  CSV count:",(dvdc_csv_rows -
     1)," Record structure count: ",dus_date_cols->cnt)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dldc_mode="V")
    RETURN(1)
   ENDIF
   IF (dldc_mode IN ("C", "I", "U"))
    SET dm_err->eproc = "Load master date column list from ADMIN DM_INFO into memory."
    CALL disp_msg("",dm_err->logfile,0)
    SET stat = alterlist(dus_adm_date_cols->qual,0)
    SET dus_adm_date_cols->cnt = 0
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
        )))
     HEAD REPORT
      dus_adm_date_cols->cnt = 0
     DETAIL
      dus_adm_date_cols->cnt = (dus_adm_date_cols->cnt+ 1)
      IF (mod(dus_adm_date_cols->cnt,1000)=1)
       stat = alterlist(dus_adm_date_cols->qual,(dus_adm_date_cols->cnt+ 999))
      ENDIF
      dus_adm_date_cols->qual[dus_adm_date_cols->cnt].tbl_col_name = di.info_name, dus_adm_date_cols
      ->qual[dus_adm_date_cols->cnt].tbl_name = substring(1,(findstring("/",di.info_name,1,1) - 1),di
       .info_name), dus_adm_date_cols->qual[dus_adm_date_cols->cnt].col_name = substring((findstring(
        "/",di.info_name,1,1)+ 1),size(di.info_name),di.info_name),
      dus_adm_date_cols->qual[dus_adm_date_cols->cnt].dt_type_flag = di.info_number
     FOOT REPORT
      stat = alterlist(dus_adm_date_cols->qual,dus_adm_date_cols->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dus_adm_date_cols)
    ENDIF
   ENDIF
   IF (dldc_mode IN ("C", "U"))
    IF ((dus_adm_date_cols->cnt=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verify context of master list."
     SET dm_err->emsg = "CHECK and UPDATE mode requires existence of Admin master date list rows."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dvdc_loop = 1 TO dus_date_cols->cnt)
      SET dvdc_idx = 0
      SET dvdc_idx = locateval(dvdc_idx,1,dus_adm_date_cols->cnt,dus_date_cols->qual[dvdc_loop].
       tbl_col_name,dus_adm_date_cols->qual[dvdc_idx].tbl_col_name)
      IF (dvdc_idx > 0)
       IF ((dus_date_cols->qual[dvdc_loop].dt_type_flag != dus_adm_date_cols->qual[dvdc_idx].
       dt_type_flag)
        AND (((dus_date_cols->qual[dvdc_loop].dt_type_flag=1)) OR ((dus_adm_date_cols->qual[dvdc_idx]
       .dt_type_flag=1))) )
        SET dm_err->eproc = concat("[UTC Conversion] Table/column date type flag mismatch [",trim(
          dus_date_cols->qual[dvdc_loop].tbl_col_name),"; csv - ",trim(cnvtstring(dus_date_cols->
           qual[dvdc_loop].dt_type_flag)),", admin - ",
         trim(cnvtstring(dus_adm_date_cols->qual[dvdc_idx].dt_type_flag)),"].")
        CALL disp_msg("",dm_err->logfile,0)
        SET dvdc_col_mismatch_cnt = (dvdc_col_mismatch_cnt+ 1)
       ENDIF
      ELSE
       SET dm_err->eproc = concat("[UTC Conversion] Table/column missing [",dus_date_cols->qual[
        dvdc_loop].tbl_col_name,"].")
       CALL disp_msg("",dm_err->logfile,0)
       SET dvdc_col_missing_cnt = (dvdc_col_missing_cnt+ 1)
       IF (dldc_mode="U")
        SET dm_err->eproc = concat("Check db existence of missing master date table/column [",
         dus_date_cols->qual[dvdc_loop].tbl_col_name,"].")
        CALL disp_msg("",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM user_tab_columns uc
         WHERE (uc.table_name=dus_date_cols->qual[dvdc_loop].tbl_name)
          AND (uc.column_name=dus_date_cols->qual[dvdc_loop].col_name)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET dm_err->eproc = concat("[UTC Conversion] Table/column ",trim(dus_date_cols->qual[
           dvdc_loop].tbl_col_name)," already exists in database.")
         CALL disp_msg("",dm_err->logfile,0)
         SET dvdc_col_exists_cnt = (dvdc_col_exists_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (dldc_mode="C")
     IF (((dvdc_col_mismatch_cnt > 0) OR (dvdc_col_missing_cnt > 0)) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verify master date list csv file and Admin master date list match."
      SET dm_err->emsg = concat("Table/columns missing or mismatch on date type flag.  [Missing: ",
       trim(cnvtstring(dvdc_col_missing_cnt)),"  Mismatch: ",trim(cnvtstring(dvdc_col_mismatch_cnt)),
       "].  Review logfile for complete list of missing/mismatch table/columns.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dus_adm_date_cols->cnt > dus_date_cols->cnt))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verify context of master list."
      SET dm_err->emsg = concat("CHECK mode requires the master date list count in csv file (",trim(
        cnvtstring(dus_date_cols->cnt)),") to match count of Admin master date list (",trim(
        cnvtstring(dus_adm_date_cols->cnt)),").")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dldc_mode="U"
     AND ((dvdc_col_mismatch_cnt > 0) OR (dvdc_col_exists_cnt > 0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verify master date list csv file and Admin master date list match."
     SET dm_err->emsg = concat(
      "Table/columns mismatch on date type flag or already exist in database.  [Mismatch: ",trim(
       cnvtstring(dvdc_col_mismatch_cnt)),"  Exists in DB: ",trim(cnvtstring(dvdc_col_exists_cnt)),
      "].  Review logfile for complete list of missing/mismatch table/columns.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dldc_mode="C")
     IF (dus_load_spec_cols(dldc_dbname)=0)
      RETURN(0)
     ENDIF
     FOR (dvdc_loop = 1 TO dus_date_cols->cnt)
       IF ((dus_date_cols->qual[dvdc_loop].dt_type_flag != 1))
        SET dvdc_tbl_fnd = 0
        SET dvdc_tbl_fnd = locateval(dvdc_tbl_fnd,1,dus_std_convert_list->tbl_cnt,dus_date_cols->
         qual[dvdc_loop].tbl_name,dus_std_convert_list->tbl[dvdc_tbl_fnd].table_name)
        IF (dvdc_tbl_fnd > 0)
         SET dvdc_col_fnd = 0
         SET dvdc_col_fnd = locateval(dvdc_col_fnd,1,dus_std_convert_list->tbl[dvdc_tbl_fnd].col_cnt,
          dus_date_cols->qual[dvdc_loop].col_name,dus_std_convert_list->tbl[dvdc_tbl_fnd].col[
          dvdc_col_fnd].column_name)
        ENDIF
        IF (((dvdc_tbl_fnd=0) OR (dvdc_col_fnd=0)) )
         SET dm_err->eproc = concat(
          "[UTC Conversion] Table/column exclusion date missing from Admin exclusions [",
          dus_date_cols->qual[dvdc_loop].tbl_col_name,"].")
         CALL disp_msg("",dm_err->logfile,0)
         SET dvdc_col_missing_adm_cnt = (dvdc_col_missing_adm_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     IF (dvdc_col_missing_adm_cnt > 0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc =
      "Verify master date exclusions from csv file and Admin exclusion date list match."
      SET dm_err->emsg = concat("Table/columns missing from Admin exclusions.  [Missing: ",trim(
        cnvtstring(dvdc_col_missing_adm_cnt)),
       "].  Review logfile for complete list of Admin exclusions missing table/columns.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dldc_mode="I"
    AND (dus_adm_date_cols->cnt > 0))
    SET dm_err->eproc =
    "Insert mode on restart.  Skipping work to complete initial load of Admin DM_INFO master date column list."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (((dldc_mode="I"
    AND (dus_adm_date_cols->cnt=0)) OR (dldc_mode="U")) )
    IF (dldc_mode="U")
     SET dm_err->eproc = "Deleting Master Date Columns into Admin DM_INFO."
     CALL disp_msg(" ",dm_err->logfile,0)
     DELETE  FROM dm2_admin_dm_info i
      WHERE i.info_domain=patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
         )))
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = "Inserting Master Date Columns into Admin DM_INFO."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(size(dus_date_cols->qual,5)))
     SET di.info_domain = patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
         ))), di.info_name = dus_date_cols->qual[d.seq].tbl_col_name, di.info_number = dus_date_cols
      ->qual[d.seq].dt_type_flag,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (di
      WHERE (dus_date_cols->qual[d.seq].tbl_col_name=di.info_name))
     WITH nocounter, rdbarrayinsert = 100
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    COMMIT
    IF (dum_mng_spec_cols(dldc_dbname)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_fill_v500_cust(dfvc_dbname)
   DECLARE dfvc_pos = i4 WITH protect, noconstant(0)
   DECLARE dfvc_loc = i4 WITH protect, noconstant(0)
   DECLARE dfvc_own_name = vc WITH protect, noconstant(" ")
   DECLARE dfvc_tbl_name = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Loading V500 Custom tables from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dfvc_dbname,"_UTC_DATA - V500 CUST TABLES LIST")))
    DETAIL
     dus_v500_cust->tbl_cnt = (dus_v500_cust->tbl_cnt+ 1), stat = alterlist(dus_v500_cust->tbl,
      dus_v500_cust->tbl_cnt), dus_v500_cust->tbl[dus_v500_cust->tbl_cnt].table_name = i.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_v500_cust)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_cust_incl_abort_gen(dciag_tgt_dbname,dciag_src_orcl_ver,dciag_tgt_orcl_ver)
   DECLARE dciag_fname = vc WITH protect, noconstant("")
   DECLARE dciag_parm_loc = vc WITH protect, noconstant("")
   DECLARE dciag_iter = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Create utc delivery custom tables inclusion abort file for custom tables."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dciag_parm_loc = "/ggdelivery/dirprm"
   IF (dm2_find_dir(dciag_parm_loc)=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,15,120)
    CALL text(3,2,"Enter Delivery parameter file directory location :")
    CALL accept(3,70,"P(30);C",dciag_parm_loc
     WHERE curaccept != "")
    SET dciag_parm_loc = trim(curaccept)
    SET message = nowindow
   ENDIF
   IF (dm2_find_dir(dciag_parm_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Delivery parm directory entered [",dciag_parm_loc,"] does not exist.")
    SET dm_err->eproc = "Verify delivery parm directory exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (substring(size(dciag_parm_loc),1,dciag_parm_loc) != "/")
    SET dciag_parm_loc = concat(trim(dciag_parm_loc),"/")
   ENDIF
   SET dciag_fname = concat(trim(dciag_parm_loc),"custtbls_abort.mac")
   SELECT INTO value(dciag_fname)
    FROM dummyt d
    HEAD REPORT
     col 0,
     CALL print("MACRO #custtbls_abort"), row + 1,
     col 0,
     CALL print("BEGIN"), row + 1
    DETAIL
     IF ((dus_v500_cust->tbl_cnt > 0))
      IF (dciag_src_orcl_ver < 12
       AND dciag_tgt_orcl_ver > 11)
       FOR (dciag_iter = 1 TO dus_v500_cust->tbl_cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &"
          )), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &"
          )), row + 1
       ENDFOR
      ELSE
       FOR (dciag_iter = 1 TO dus_v500_cust->tbl_cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row + 1
       ENDFOR
      ENDIF
     ENDIF
     IF ((dus_user_list->cnt > 0))
      IF (dciag_src_orcl_ver < 12
       AND dciag_tgt_orcl_ver > 11)
       FOR (dciag_iter = 1 TO dus_user_list->cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row
          + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row
          + 1
       ENDFOR
      ELSE
       FOR (dciag_iter = 1 TO dus_user_list->cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          " EVENTACTIONS (DISCARD, ABORT) &")), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          " EVENTACTIONS (DISCARD, ABORT) &")), row + 1
       ENDFOR
      ENDIF
     ENDIF
    FOOT REPORT
     IF (dciag_src_orcl_ver < 12
      AND dciag_tgt_orcl_ver > 11)
      col 0,
      CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
       ".V500.DM2_MIG_FAKE_BATCH"," EVENTACTIONS (DISCARD, ABORT) ")), row + 1
     ELSE
      col 0,
      CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME V500.DM2_MIG_FAKE_BATCH",
       " EVENTACTIONS (DISCARD, ABORT) ")), row + 1
     ENDIF
     col 0,
     CALL print("END;"), row + 1
    WITH nocounter, maxrow = 1, format = lfstream,
     noformfeed, maxcol = 2000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ((validate(dmt_min_ext_size,- (1))=- (1)))
  DECLARE dmt_min_ext_size = f8 WITH public, constant(163840.0)
 ENDIF
 IF ((validate(dm2_block_size,- (1))=- (1))
  AND (validate(dm2_block_size,- (2))=- (2)))
  IF (currdb="ORACLE")
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ELSEIF (currdb="DB2UDB")
   DECLARE dm2_block_size = f8 WITH public, constant(16384.0)
  ELSE
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ENDIF
 ENDIF
 IF ((validate(rtspace->rtspace_cnt,- (1))=- (1)))
  FREE RECORD rtspace
  RECORD rtspace(
    1 dbname = vc
    1 tmp_table_name = vc
    1 rtspace_cnt = i4
    1 sql_size_mb = f8
    1 sql_filegrowth_mb = f8
    1 install_type = vc
    1 install_type_value = vc
    1 mode = vc
    1 ddl_report_fname = vc
    1 commands_written_ind = i2
    1 database_remote = i2
    1 unique_nbr = vc
    1 temp_tspace_name = vc
    1 temp_tspace_file_type = vc
    1 temp_tspace_ttl_mb = i4
    1 temp_tspace_reserved_pct = i4
    1 temp_tspace_reserved_mb = i4
    1 temp_tspace_ttl_needed_mb = i4
    1 temp_tspace_ratio = f8
    1 temp_tspace_indexlist[*]
      2 tbl_name = vc
      2 ind_name = vc
      2 size_mb = i4
    1 qual[*]
      2 tspace_name = vc
      2 chunk_size = f8
      2 chunks_needed = i4
      2 ext_mgmt = c1
      2 tspace_id = i4
      2 cur_bytes_allocated = f8
      2 bytes_needed = f8
      2 user_bytes_to_add = f8
      2 final_bytes_to_add = f8
      2 new_ind = i2
      2 extend_ind = i2
      2 init_ext = f8
      2 next_ext = f8
      2 cont_complete_ind = i4
      2 cont_cnt = i4
      2 ct_err_msg = vc
      2 ct_err_ind = i2
      2 asm_disk_group = vc
      2 commands[*]
        3 cmd_type = vc
        3 cmd = vc
        3 lv_file = vc
        3 lv_exist_chk = i2
      2 cont[*]
        3 volume_label = vc
        3 disk_name = vc
        3 disk_idx = i4
        3 vg_name = vc
        3 pp_size_mb = f8
        3 pps_to_add = f8
        3 add_ext_ind = c1
        3 cont_tspace_rel_key = i4
        3 space_to_add = f8
        3 delete_ind = i2
        3 cont_size_mb = f8
        3 lv_file = vc
        3 new_ind = i2
        3 mwc_flag = i2
      2 temp_ind = i2
      2 user_tspace_ind = i2
  )
  SET rtspace->install_type = "DM2NOTSET"
  SET rtspace->install_type_value = "DM2NOTSET"
  SET rtspace->mode = "DM2NOTSET"
  SET rtspace->ddl_report_fname = "DM2NOTSET"
  SET rtspace->unique_nbr = ""
 ENDIF
 IF ((validate(ddtsp->tsp_cnt,- (1))=- (1)))
  FREE RECORD ddtsp
  RECORD ddtsp(
    1 nonstd_ind = i2
    1 nonstd_tgt_ind = i2
    1 tsp_cnt = i4
    1 qual[*]
      2 tspace_name = vc
      2 ext_mgmt = c1
      2 alloc_type = vc
      2 seg_space_mgmt = vc
      2 bigfile = c3
      2 nonstd_ind = i2
      2 nonstd_tgt_ind = i2
      2 lmt_ora8_ind = i2
      2 lmt_uniform_ind = i2
      2 lmt_and_not_assm = i2
      2 lmt_bigfile = i2
      2 datafile_not_ae = i2
      2 datafile_not_unlimited = i2
      2 datafile_not_assm = i2
      2 lmt_and_not_ae = i2
  )
  SET ddtsp->nonstd_ind = 0
  SET ddtsp->nonstd_tgt_ind = 0
 ENDIF
 IF ((validate(dm2_ind_tspace_assign->cnt,- (1))=- (1)))
  FREE SET dm2_ind_tspace_assign
  RECORD dm2_ind_tspace_assign(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 index_tspace = vc
      2 index_tspace_cnt = i4
      2 tspace_cnt = i4
      2 tspace[*]
        3 tspace_name = vc
        3 ind_cnt = i4
  )
  SET dm2_ind_tspace_assign->cnt = 0
 ENDIF
 IF ((validate(das_dtp->dtp_cnt,- (1))=- (1)))
  FREE RECORD das_dtp
  RECORD das_dtp(
    1 dtp_cnt = i4
    1 qual[*]
      2 tname = vc
      2 prec_cnt = i2
      2 prec[*]
        3 precedence = i2
        3 data_tspace = vc
        3 data_extent_size = f8
        3 ind_tspace = vc
        3 index_extent_size = f8
        3 long_tspace = vc
  )
  SET das_dtp->dtp_cnt = 0
 ENDIF
 IF ((validate(dtr_tspace_misc->recalc_space_needs,- (1))=- (1))
  AND (validate(dtr_tspace_misc->recalc_space_needs,- (2))=- (2)))
  FREE RECORD dtr_tspace_misc
  RECORD dtr_tspace_misc(
    1 recalc_space_needs = i2
    1 gen_id = f8
  )
  SET dtr_tspace_misc->recalc_space_needs = 0
  SET dtr_tspace_misc->gen_id = 0.0
 ENDIF
 IF ((validate(dtrt->cnt,- (1))=- (1)))
  FREE RECORD dtrt
  RECORD dtrt(
    1 cnt = i4
    1 qual[*]
      2 tspace_name = vc
  )
  SET dtrt->cnt = 0
 ENDIF
 IF ((validate(dcs_long_tspace->tspace_count,- (1))=- (1)))
  FREE SET dcs_long_tspace
  RECORD dcs_long_tspace(
    1 tspace_count = i4
    1 tspace[*]
      2 tspace_name = vc
      2 bytes = f8
      2 tbl_cnt = i4
      2 tbl[*]
        3 table_name = vc
        3 column_name = vc
  )
  SET dcs_long_tspace->tspace_count = 0
 ENDIF
 DECLARE dtr_lob_size = f8 WITH protect, constant(163840.0)
 DECLARE dtr_load_tspaces(dlt_process=vc) = i2
 DECLARE dtr_rpt_nonstd_tspace(drnt_file=vc,drnt_mode=i2) = i2
 DECLARE dtr_find_tspace(dft_tspace=vc) = i2
 DECLARE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx=i4) = i2
 DECLARE d2tr_get_man_inst_type_val(null) = i2
 DECLARE dm2_adj_size(d_adj_size=f8,d_adj_mult=f8) = f8
 DECLARE dm2_adj_init_next_ext(daine_data_to_move=vc,daine_table_type=i2,daine_table_name=vc,
  daine_init_ext=f8(ref),daine_next_ext=f8(ref)) = null
 DECLARE dtr_load_clin_tspaces(null) = i2
 SUBROUTINE dm2_adj_size(d_adj_size,d_adj_mult)
   DECLARE das_ceil_factor = f8 WITH protect, noconstant(0.0)
   DECLARE das_ret = f8 WITH protect, noconstant(0.0)
   IF (d_adj_mult > 0.0)
    SET das_ceil_factor = dm2ceil((d_adj_size/ d_adj_mult))
    SET das_ret = (d_adj_mult * das_ceil_factor)
   ELSE
    SET das_ret = d_adj_size
   ENDIF
   RETURN(das_ret)
 END ;Subroutine
 SUBROUTINE d2tr_get_man_inst_type_val(null)
   DECLARE dgmitv_info_num_hold = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Getting Manual Install_Type_Value from DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
     AND d.info_name="MANUAL"
    DETAIL
     dgmitv_info_num_hold = d.info_number
    WITH forupdatewait(d)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CASE (curqual)
    OF 1:
     SET rtspace->install_type_value = cnvtstring((dgmitv_info_num_hold+ 1))
     SET dm_err->eproc = concat("Updating Manual Install_Type_Value in DM_INFO to:",rtspace->
      install_type_value)
     CALL disp_msg("",dm_err->logfile,0)
     UPDATE  FROM dm_info d
      SET d.info_number = cnvtint(rtspace->install_type_value)
      WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
       AND d.info_name="MANUAL"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    OF 0:
     SET rtspace->install_type_value = "1"
     SET dm_err->eproc = "Inserting Manual Install_Type_Value into DM_INFO."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     INSERT  FROM dm_info d
      SET d.info_domain = "DM2_TSPACE_SIZE-MAX VALUE", d.info_name = "MANUAL", d.info_number =
       cnvtint(rtspace->install_type_value)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_find_tspace(dft_tspace)
   DECLARE dft_idx = i4 WITH protect, noconstant(0)
   SET dft_idx = locateval(dft_idx,1,ddtsp->tsp_cnt,dft_tspace,ddtsp->qual[dft_idx].tspace_name)
   RETURN(dft_idx)
 END ;Subroutine
 SUBROUTINE dtr_rpt_nonstd_tspace(drnt_file,drnt_mode)
   DECLARE drnt_nonstd_found = i2 WITH protect, noconstant(0)
   SELECT
    IF (drnt_mode=0)
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_tgt_ind=1)
    ELSE
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_ind=1)
    ENDIF
    INTO value(drnt_file)
    HEAD REPORT
     row + 2,
     CALL center("Unsupported Tablespace Configuration Report",1,126), row + 2,
     col 1,
     "The following tablespaces have been found with an unsupported configuration in the current database.",
     row + 2
    DETAIL
     col 1, "Tablespace Name:", col 20,
     ddtsp->qual[d.seq].tspace_name, row + 1, col 11,
     "Issue:"
     IF ((ddtsp->qual[d.seq].lmt_ora8_ind=1))
      col 20, "Tablespace is locally managed on Oracle 8", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_uniform_ind=1))
      col 20, "Tablespace is locally managed with uniform extents", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_and_not_assm=1))
      col 20, "Tablespace is locally managed without automatic segment-space management", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].datafile_not_ae=1))
      col 20, "Tablespace contains datafiles that are not autoextensible", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF (ddtsp->qual[d.seq].datafile_not_unlimited)
      col 20, "Tablespace contains datafiles defined with a limited maxsize (not UNLIMITED)", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     row + 2
    FOOT REPORT
     IF (drnt_nonstd_found=0)
      col 1, "No unsupported tablespaces returned.", row + 1
     ENDIF
    WITH nocounter, format = variable, nullreport,
     formfeed = none, maxcol = 512, append
   ;end select
   IF (check_error("Displaying Unsupported Tablespace Configuration Report") != 0)
    CALL disp_msg(" ",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx)
  IF ((ddtsp->qual[sbr_tsp_idx].nonstd_ind=1))
   SET ddtsp->qual[sbr_tsp_idx].nonstd_tgt_ind = 1
   SET ddtsp->nonstd_tgt_ind = 1
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_adj_init_next_ext(daine_data_to_move,daine_table_type,daine_table_name,daine_init_ext,
  daine_next_ext)
   IF (daine_next_ext=0.0)
    SET daine_init_ext = 0.0
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_init_ext > 0.0)
    SET daine_init_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_init_ext > 0.0
    AND (daine_init_ext > (5 * dm2_block_size)))
    SET daine_init_ext = dm2_adj_size(daine_init_ext,(5 * dm2_block_size))
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_next_ext > 0.0)
    SET daine_next_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_next_ext > 0.0
    AND (daine_next_ext > (5 * dm2_block_size)))
    SET daine_next_ext = dm2_adj_size(daine_next_ext,(5 * dm2_block_size))
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dtr_load_tspaces(dlt_process)
   DECLARE dlt_fatal_error = i2 WITH protect, noconstant(0)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   DECLARE dlt_31g = f8 WITH protect, noconstant((((31.0 * 1024.0) * 1024.0) * 1024.0))
   IF (dm2_get_rdbms_version(null)=0)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = "Load tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dlt_process="CLIN COPY")
     FROM dm2_dba_tablespaces dbt
    ELSEIF (dlt_process="REPORT")
     FROM dm2_dba_tablespaces dbt
     WHERE dbt.tablespace_name != "SYSTEM"
      AND  NOT (dbt.contents IN ("UNDO", "TEMPORARY"))
    ELSEIF ( NOT (currdbuser IN ("V500", "CDBA")))
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
    ELSE
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
      AND substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
    ENDIF
    INTO "nl:"
    HEAD REPORT
     ddtsp->nonstd_ind = 0, ddtsp->nonstd_tgt_ind = 0, ddtsp->tsp_cnt = 0
    DETAIL
     IF (dlt_fatal_error=0)
      ddtsp->tsp_cnt = (ddtsp->tsp_cnt+ 1)
      IF (mod(ddtsp->tsp_cnt,50)=1)
       stat = alterlist(ddtsp->qual,(ddtsp->tsp_cnt+ 49))
      ENDIF
      CASE (trim(dbt.extent_management))
       OF "DICTIONARY":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "D"
       OF "LOCAL":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "L"
       ELSE
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = " ",
        IF (currdb="ORACLE")
         dlt_fatal_error = 1
        ENDIF
      ENDCASE
      ddtsp->qual[ddtsp->tsp_cnt].tspace_name = trim(dbt.tablespace_name), ddtsp->qual[ddtsp->tsp_cnt
      ].alloc_type = trim(dbt.allocation_type), ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt = dbt
      .segment_space_management,
      ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].nonstd_tgt_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm
       = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 0, ddtsp->qual[ddtsp->tsp_cnt].datafile_not_assm = 0,
      ddtsp->qual[ddtsp->tsp_cnt].datafile_not_unlimited = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_ae = 0
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (dm2_rdbms_version->level1=8))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].alloc_type="UNIFORM"))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt != "AUTO"))
       ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND dbt.bigfile="YES")
       ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp
       ->nonstd_ind = 1
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(ddtsp->qual,ddtsp->tsp_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 10))
    CALL echorecord(ddtsp)
   ENDIF
   IF (dlt_fatal_error=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unknown extent_management value returned from dm2_dba_tablespaces"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_storage_misc->tgt_storage_type="ASM"))
    SET dm_err->eproc = "Load datafile content."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT
     IF ((dm2_install_schema->process_option="CLIN COPY"))
      FROM dm2_dba_data_files dbt
     ELSE
      FROM dm2_dba_data_files dbt
      WHERE substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
       AND ((dbt.autoextensible="NO") OR (dbt.maxbytes < dlt_31g))
     ENDIF
     INTO "nl:"
     ORDER BY dbt.tablespace_name
     HEAD dbt.tablespace_name
      dlt_ndx = locateval(dlt_ndx,1,ddtsp->tsp_cnt,dbt.tablespace_name,ddtsp->qual[dlt_ndx].
       tspace_name)
      IF (dlt_ndx > 0)
       IF (dbt.autoextensible="NO")
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_ae = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
       IF (dbt.maxbytes < dlt_31g)
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_unlimited = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
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
 SUBROUTINE dtr_load_clin_tspaces(null)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load 'clinical' tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    tspace_name = d.data_tablespace
    FROM dm_ts_precedence d
    WHERE ((d.owner="V500") UNION (
    (SELECT DISTINCT
     tspace_name = i.index_tablespace
     FROM dm_ts_precedence i
     WHERE ((i.owner="V500") UNION (
     (SELECT DISTINCT
      tspace_name = l.long_tablespace
      FROM dm_ts_precedence l
      WHERE l.owner="V500"))) )))
    ORDER BY tspace_name
    HEAD REPORT
     dtrt->cnt = 0
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1)
     IF (mod(dtrt->cnt,50)=1)
      stat = alterlist(dtrt->qual,(dtrt->cnt+ 49))
     ENDIF
     dtrt->qual[dtrt->cnt].tspace_name = trim(tspace_name)
    FOOT REPORT
     stat = alterlist(dtrt->qual,dtrt->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load 'clinical' tablespace mapping content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    d.info_char
    FROM dm_info d
    WHERE d.info_domain="DM2_TABLESPACE_MAPPING"
    ORDER BY d.info_char
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1), stat = alterlist(dtrt->qual,dtrt->cnt), dtrt->qual[dtrt->cnt].
     tspace_name = trim(d.info_char)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dtrt)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dmr_get_node_name(null) = i2
 DECLARE dmr_get_queue_contents(batch_queue=vc) = i2
 DECLARE dmr_check_directory(directory=vc) = i2
 DECLARE dmr_get_unique_file_name(directory=vc,file_prefix=vc,file_suffix=vc) = i2
 DECLARE dmr_fill_email_list(null) = i2
 DECLARE dmr_send_email(subject=vc,address_list=vc,file_name=vc) = i2
 DECLARE dmr_get_user_list(null) = i2
 DECLARE dmr_verify_v500_user(exists_ind=i2(ref)) = i2
 DECLARE dmr_initialize_mig_data(null) = null
 DECLARE dmr_prompt_connect_data(dpcd_db_type=vc,dpcd_db_user=vc,dpcd_cnct_opt=vc) = i2
 DECLARE dmr_prompt_retrieve_mig_data(dprmd_adm_db_ind=i2,dprmd_src_db_ind=i2,dprmd_tgt_db_ind=i2,
  dprmd_sys_db_ind=i2) = i2
 DECLARE dmr_chk_mig_ora_version(dcmov_error_flag=i2(ref)) = i2
 DECLARE dmr_issue_summary_screen(diss_src_db_ind=i2,diss_tgt_db_ind=i2,diss_msg=vc) = i2
 DECLARE dmr_load_mig_data(null) = i2
 DECLARE dmr_store_off_mig_data(null) = i2
 DECLARE dmr_get_gg_dir(null) = i2
 DECLARE dmr_set_gg_files(dsgf_report_capture=i2,dsgf_report_delivery=i2) = null
 DECLARE dmr_directory_prompt(mode) = i2
 DECLARE dmr_check_batch_queue(dcbq_queue_name=vc,dcbq_queue_fnd_ret=i2(ref)) = i2
 DECLARE dmr_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dmr_validate_src_and_tgt(dvst_src_ind=i2,dvst_tgt_ind=i2) = i2
 DECLARE dmr_stop_job(job_type=vc,job_mode=i2) = i2
 DECLARE dmr_get_storage_type(dgst_storage_ret=vc(ref)) = i2
 DECLARE dmr_load_managed_tables(dlmt_mng_ret=vc(ref)) = i2
 DECLARE dmr_mig_setup_gg_dir(null) = i2
 DECLARE dmr_load_di_filter(null) = i2
 DECLARE dmr_get_di_filter(null) = i2
 DECLARE dmr_create_di_macro(dcdm_in_dir=vc,dcdm_gg_version=i2) = i2
 DECLARE dmr_get_db_info(dgd_db_name=vc(ref),dgd_created_date=f8(ref)) = i2
 IF (validate(dmr_batch_queue,"X")="X"
  AND validate(dmr_batch_queue,"Y")="Y")
  DECLARE dmr_batch_queue = vc WITH public, constant(cnvtlower(build("migration$",logical(
      "environment"))))
 ENDIF
 FREE RECORD dmr_node
 RECORD dmr_node(
   1 cnt = i4
   1 qual[*]
     2 node_name = vc
     2 instance_number = f8
     2 instance_name = vc
 )
 IF ((validate(dmr_queue->cnt,- (1))=- (1))
  AND validate(dmr_queue->cnt,1)=1)
  FREE RECORD dmr_queue
  RECORD dmr_queue(
    1 cnt = i4
    1 qual[*]
      2 entry = i4
      2 jobname = vc
      2 username = vc
      2 status = vc
  )
 ENDIF
 IF ((validate(dmr_emails->cnt,- (1))=- (1))
  AND validate(dmr_emails->cnt,1)=1)
  FREE RECORD dmr_emails
  RECORD dmr_emails(
    1 change_ind = i2
    1 email_list = vc
    1 cnt = i4
    1 qual[*]
      2 email_address = vc
  )
 ENDIF
 IF ((validate(dmr_user_list->cnt,- (1))=- (1))
  AND validate(dmr_user_list->cnt,1)=1)
  FREE RECORD dmr_user_list
  RECORD dmr_user_list(
    1 change_ind = i2
    1 cnt = i4
    1 qual[*]
      2 user = vc
  )
 ENDIF
 IF ((validate(dmr_expimp->prompt_done,- (1))=- (1))
  AND validate(dmr_expimp->prompt_done,99)=99)
  FREE RECORD dmr_expimp
  RECORD dmr_expimp(
    1 prompt_done = i2
    1 mode = vc
    1 process = vc
    1 step = vc
    1 step_ready = i2
    1 src_ora_home = vc
    1 src_nls_lang = vc
    1 src_ksh_loc = vc
    1 tgt_ora_home = vc
    1 tgt_nls_lang = vc
    1 tgt_file_loc = vc
    1 ora_username = vc
    1 user_prefix = vc
    1 file_prefix = vc
    1 export_prefix = vc
    1 sqlplus_prefix = vc
    1 import_prefix = vc
    1 nohup_prefix = vc
    1 exp_utility_location = vc
    1 imp_utility_location = vc
    1 read_only_mode = i2
    1 data_chunk_size = f8
    1 diff_ora_version = i2
    1 stg_v500_p_word = vc
    1 stg_v500_cnct_str = vc
    1 stg_db_name = vc
    1 stg_node_name = vc
    1 stg_created_date = f8
    1 expimp_user_cnt = i2
    1 users[*]
      2 expimp_user = vc
  )
  SET dmr_expimp->data_chunk_size = 1000000.0
 ENDIF
 IF (validate(dmr_mig_data->dm2_mig_log,"X")="X"
  AND validate(dmr_mig_data->dm2_mig_log,"Z")="Z")
  FREE RECORD dmr_mig_data
  RECORD dmr_mig_data(
    1 dm2_mig_log = vc
    1 adm_cdba_pwd = vc
    1 adm_cdba_cnct_str = vc
    1 cur_db_type = vc
    1 tgt_v500_pwd = vc
    1 tgt_v500_cnct_str = vc
    1 tgt_sys_pwd = vc
    1 tgt_sys_cnct_str = vc
    1 tgt_storage_type = vc
    1 src_storage_type = vc
    1 src_v500_pwd = vc
    1 src_v500_cnct_str = vc
    1 src_sys_pwd = vc
    1 src_sys_cnct_str = vc
    1 src_db_name = vc
    1 src_created_date = f8
    1 src_db_os = vc
    1 src_ora_version = vc
    1 src_ora_level1 = i2
    1 src_ora_level2 = i2
    1 src_ora_level3 = i2
    1 src_ora_level4 = i2
    1 src_node_cnt = i4
    1 src_nodes[*]
      2 node_name = vc
      2 instance_number = f8
      2 instance_name = vc
    1 tgt_db_name = vc
    1 tgt_created_date = f8
    1 tgt_db_os = vc
    1 tgt_ora_version = vc
    1 tgt_ora_level1 = i2
    1 tgt_ora_level2 = i2
    1 tgt_ora_level3 = i2
    1 tgt_ora_level4 = i2
    1 tgt_node_cnt = i4
    1 tgt_nodes[*]
      2 node_name = vc
      2 instance_number = f8
      2 instance_name = vc
    1 report_all = i2
    1 report_capture = i2
    1 report_delivery = i2
    1 cap_dir = vc
    1 cap_mgr_rpt = vc
    1 cap_rpt = vc
    1 cap_err_rpt = vc
    1 del_dir = vc
    1 del_mgr_rpt = vc
    1 del_rpt = vc
    1 del_err_rpt = vc
    1 gg_capture_dir = vc
    1 gg_delivery_dir = vc
  )
  CALL dmr_initialize_mig_data(null)
 ENDIF
 IF ((validate(dmr_di_filter->cnt,- (1))=- (1))
  AND validate(dmr_di_filter->cnt,1)=1)
  RECORD dmr_di_filter(
    1 cnt = i4
    1 qual[*]
      2 name = vc
  )
 ENDIF
 SUBROUTINE dmr_initialize_mig_data(null)
   IF (cursys="AXP")
    SET dmr_mig_data->dm2_mig_log = logical("cer_install")
   ELSE
    SET dmr_mig_data->dm2_mig_log = concat(trim(logical("cer_install")),"/")
   ENDIF
   SET dmr_mig_data->adm_cdba_pwd = "DM2NOTSET"
   SET dmr_mig_data->cur_db_type = "DM2NOTSET"
   SET dmr_mig_data->adm_cdba_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->tgt_v500_pwd = "DM2NOTSET"
   SET dmr_mig_data->tgt_v500_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_v500_pwd = "DM2NOTSET"
   SET dmr_mig_data->src_v500_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_sys_pwd = "DM2NOTSET"
   SET dmr_mig_data->src_sys_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_db_name = "DM2NOTSET"
   SET dmr_mig_data->src_created_date = 0.0
   SET dmr_mig_data->src_db_os = "DM2NOTSET"
   SET dmr_mig_data->src_ora_version = "DM2NOTSET"
   SET stat = alterlist(dmr_mig_data->src_nodes,0)
   SET dmr_mig_data->src_node_cnt = 0
   SET dmr_mig_data->tgt_db_name = "DM2NOTSET"
   SET dmr_mig_data->tgt_created_date = 0.0
   SET dmr_mig_data->tgt_db_os = "DM2NOTSET"
   SET dmr_mig_data->tgt_ora_version = "DM2NOTSET"
   SET stat = alterlist(dmr_mig_data->tgt_nodes,0)
   SET dmr_mig_data->tgt_node_cnt = 0
   SET dmr_mig_data->report_all = 0
   SET dmr_mig_data->report_capture = 0
   SET dmr_mig_data->report_delivery = 0
   SET dmr_mig_data->cap_dir = "DM2NOTSET"
   SET dmr_mig_data->cap_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_err_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_dir = "DM2NOTSET"
   SET dmr_mig_data->del_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_err_rpt = "DM2NOTSET"
 END ;Subroutine
 SUBROUTINE dmr_get_db_info(dgdi_db_name,dgdi_created_date)
   SET dm_err->eproc = "Get databse name and created date"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$database v
    DETAIL
     dgdi_db_name = trim(cnvtupper(currdbname)), dgdi_created_date = v.created
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_mig_data(null)
   DECLARE dlmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlmd_file = vc WITH protect, noconstant(concat(dmr_mig_data->dm2_mig_log,
     "dm2_mig_config.txt"))
   FREE RECORD dlmd_cmd
   RECORD dlmd_cmd(
     1 qual[*]
       2 rs_item = vc
       2 rs_item_value = vc
   )
   IF (dm2_findfile(dlmd_file)=0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Attempting to access ",dlmd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dlmd_config_file dlmd_file
   FREE DEFINE rtl
   DEFINE rtl "dlmd_config_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dlmd_cnt = (dlmd_cnt+ 1), stat = alterlist(dlmd_cmd->qual,dlmd_cnt), dlmd_cmd->qual[dlmd_cnt].
     rs_item = substring(1,(findstring(",",t.line,1,0) - 1),t.line),
     dlmd_cmd->qual[dlmd_cnt].rs_item_value = substring((findstring(",",t.line,1,0)+ 1),(size(t.line)
       - findstring(",",t.line,1,0)),t.line)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dlmd_cmd)
   ENDIF
   SET dlmd_cnt = 0
   FOR (dlmd_cnt = 1 TO size(dlmd_cmd->qual,5))
     IF (findstring("_pwd",dlmd_cmd->qual[dlmd_cnt].rs_item,1,1)=0)
      CALL parser(concat("set dmr_mig_data->",dlmd_cmd->qual[dlmd_cnt].rs_item," = ",dlmd_cmd->qual[
        dlmd_cnt].rs_item_value," go"),1)
     ELSE
      CALL parser(concat("set dmr_mig_data->",dlmd_cmd->qual[dlmd_cnt].rs_item," = ",dlmd_cmd->qual[
        dlmd_cnt].rs_item_value," go"),1)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_store_off_mig_data(null)
   DECLARE dsomd_file = vc WITH protect, noconstant(concat(dmr_mig_data->dm2_mig_log,
     "dm2_mig_config.txt"))
   SET dm_err->eproc = concat("Checking if ",dsomd_file," exists.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dsomd_file) > 0)
    SET dm_err->eproc = concat("Attempting to remove ",dsomd_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (remove(dsomd_file)=0)
     SET dm_err->emsg = concat("Unable to remove ",dsomd_file)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET logical dsomd_config_file dsomd_file
   SET dm_err->eproc = concat("Creating ",dsomd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO dsomd_config_file
    DETAIL
     IF ((dmr_mig_data->adm_cdba_pwd != "DM2NOTSET"))
      CALL print(concat('adm_cdba_pwd,"',dmr_mig_data->adm_cdba_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->adm_cdba_cnct_str != "DM2NOTSET"))
      CALL print(concat('adm_cdba_cnct_str,"',dmr_mig_data->adm_cdba_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_v500_pwd != "DM2NOTSET"))
      CALL print(concat('src_v500_pwd,"',dmr_mig_data->src_v500_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_v500_cnct_str != "DM2NOTSET"))
      CALL print(concat('src_v500_cnct_str,"',dmr_mig_data->src_v500_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_sys_pwd != "DM2NOTSET"))
      CALL print(concat('src_sys_pwd,"',dmr_mig_data->src_sys_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_sys_cnct_str != "DM2NOTSET"))
      CALL print(concat('src_sys_cnct_str,"',dmr_mig_data->src_sys_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->tgt_v500_pwd != "DM2NOTSET"))
      CALL print(concat('tgt_v500_pwd,"',dmr_mig_data->tgt_v500_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->tgt_v500_cnct_str != "DM2NOTSET"))
      CALL print(concat('tgt_v500_cnct_str,"',dmr_mig_data->tgt_v500_cnct_str,'"')), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_chk_mig_ora_version(dcmov_error_flag)
   SET dcmov_error_flag = 0
   IF ((dmr_mig_data->tgt_ora_level1 < dmr_mig_data->src_ora_level1))
    SET dcmov_error_flag = 1
    RETURN(1)
   ELSEIF ((dmr_mig_data->tgt_ora_level1 > dmr_mig_data->src_ora_level1))
    RETURN(1)
   ELSE
    IF ((dmr_mig_data->tgt_ora_level2 < dmr_mig_data->src_ora_level2))
     SET dcmov_error_flag = 1
     RETURN(1)
    ELSEIF ((dmr_mig_data->tgt_ora_level2 > dmr_mig_data->src_ora_level2))
     RETURN(1)
    ELSE
     IF ((dmr_mig_data->tgt_ora_level3 < dmr_mig_data->src_ora_level3))
      SET dcmov_error_flag = 1
      RETURN(1)
     ELSEIF ((dmr_mig_data->tgt_ora_level3 > dmr_mig_data->src_ora_level3))
      RETURN(1)
     ELSE
      IF ((dmr_mig_data->tgt_ora_level4 < dmr_mig_data->src_ora_level4))
       SET dcmov_error_flag = 1
       RETURN(1)
      ELSEIF ((dmr_mig_data->tgt_ora_level4 > dmr_mig_data->src_ora_level4))
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET dcmov_error_flag = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_prompt_connect_data(dpcd_db_type,dpcd_db_user,dpcd_cnct_opt)
   DECLARE dpcd_db_pwd = vc WITH protect, noconstant("")
   DECLARE dpcd_cnct_str = vc WITH protect, noconstant("")
   IF ( NOT (dpcd_db_type IN ("ADMIN", "TARGET", "SOURCE")))
    SET dm_err->emsg = concat("Database Type ",dpcd_db_type,
     " is invalid. Type must be ADMIN, TARGET or SOURCE")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dpcd_db_type="ADMIN"
    AND dpcd_db_user != "CDBA") OR (((dpcd_db_type="TARGET"
    AND  NOT (dpcd_db_user IN ("V500", "SYS"))) OR (dpcd_db_type="SOURCE"
    AND  NOT (dpcd_db_user IN ("V500", "SYS")))) )) )
    SET dm_err->emsg = concat("Database Username ",dpcd_db_user,
     " is invalid. User must be CDBA, V500 or SYS")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT (dpcd_cnct_opt IN ("CO", "PC")))
    SET dm_err->emsg = concat("Connect option ",dpcd_cnct_opt,
     " is invalid. Connect option must be PC or CO.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dpcd_cnct_opt="CO")
    CASE (dpcd_db_type)
     OF "TARGET":
      IF (dpcd_db_user="SYS")
       SET dpcd_db_pwd = dmr_mig_data->tgt_sys_pwd
       SET dpcd_cnct_str = dmr_mig_data->tgt_sys_cnct_str
      ELSE
       SET dpcd_db_pwd = dmr_mig_data->tgt_v500_pwd
       SET dpcd_cnct_str = dmr_mig_data->tgt_v500_cnct_str
      ENDIF
     OF "SOURCE":
      IF (dpcd_db_user="SYS")
       SET dpcd_db_pwd = dmr_mig_data->src_sys_pwd
       SET dpcd_cnct_str = dmr_mig_data->src_sys_cnct_str
      ELSE
       SET dpcd_db_pwd = dmr_mig_data->src_v500_pwd
       SET dpcd_cnct_str = dmr_mig_data->src_v500_cnct_str
      ENDIF
     OF "ADMIN":
      SET dpcd_db_pwd = dmr_mig_data->adm_cdba_pwd
      SET dpcd_cnct_str = dmr_mig_data->adm_cdba_cnct_str
    ENDCASE
    IF (dpcd_db_pwd IN ("", "DM2NOTSET"))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm_err->emsg = "Password must be supplied with CO option"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dpcd_cnct_str IN ("", "DM2NOTSET"))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm_err->emsg = "Connect string must be supplied with CO option"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dpcd_db_type)
    CALL echo(dpcd_db_user)
   ENDIF
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = dpcd_db_type
   SET dm2_install_schema->u_name = dpcd_db_user
   SET dm2_install_schema->p_word = dpcd_db_pwd
   SET dm2_install_schema->connect_str = dpcd_cnct_str
   EXECUTE dm2_connect_to_dbase dpcd_cnct_opt
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dmr_mig_data->cur_db_type = dpcd_db_type
   IF (dpcd_cnct_opt="PC")
    IF (dpcd_db_type="ADMIN")
     SET dmr_mig_data->adm_cdba_pwd = dm2_install_schema->p_word
     SET dmr_mig_data->adm_cdba_cnct_str = dm2_install_schema->connect_str
     SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
    ELSEIF (dpcd_db_type="SOURCE")
     IF (dpcd_db_user="V500")
      SET dmr_mig_data->src_v500_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->src_v500_cnct_str = dm2_install_schema->connect_str
      SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
      SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
     ELSE
      SET dmr_mig_data->src_sys_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->src_sys_cnct_str = dm2_install_schema->connect_str
     ENDIF
    ELSEIF (dpcd_db_type="TARGET")
     IF (dpcd_db_user="V500")
      SET dmr_mig_data->tgt_v500_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->tgt_v500_cnct_str = dm2_install_schema->connect_str
      SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
      SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
     ELSE
      SET dmr_mig_data->tgt_sys_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->tgt_sys_cnct_str = dm2_install_schema->connect_str
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_prompt_retrieve_mig_data(dprmd_adm_db_ind,dprmd_src_db_ind,dprmd_tgt_db_ind,
  dprmd_sys_db_ind)
   DECLARE dprmd_db = vc WITH protect, noconstant("")
   DECLARE dprmd_confirm = i2 WITH protect, noconstant(0)
   DECLARE dprmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dprmd_error_ret = i2 WITH protect, noconstant(0)
   DECLARE dprmd_storage_type = vc WITH protect, noconstant("")
   IF ((( NOT (dprmd_adm_db_ind IN (0, 1))) OR ((( NOT (dprmd_src_db_ind IN (0, 1))) OR ((( NOT (
   dprmd_tgt_db_ind IN (0, 1))) OR ( NOT (dprmd_sys_db_ind IN (0, 1)))) )) )) )
    SET dm_err->emsg =
    "Invalid parameter value. Please verify that correct values are being used for available parameters."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmr_load_mig_data(null)=0)
    RETURN(0)
   ENDIF
   IF (dprmd_adm_db_ind=1)
    IF ((((dmr_mig_data->adm_cdba_pwd="DM2NOTSET")) OR ((dmr_mig_data->adm_cdba_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("ADMIN","CDBA","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "ADMIN"
    ENDIF
   ENDIF
   IF (dprmd_src_db_ind=1)
    IF ((((dmr_mig_data->src_v500_pwd="DM2NOTSET")) OR ((dmr_mig_data->src_v500_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("SOURCE","V500","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "SOURCE"
     SET dprmd_confirm = 1
    ENDIF
    IF ((((dmr_mig_data->src_db_name="DM2NOTSET")) OR ((((dmr_mig_data->src_created_date=0.0)) OR (((
    (dmr_mig_data->src_db_os="DM2NOTSET")) OR ((((dmr_mig_data->src_ora_version="DM2NOTSET")) OR ((
    dmr_mig_data->src_node_cnt=0))) )) )) )) )
     IF (dprmd_db != "SOURCE")
      IF (dmr_prompt_connect_data("SOURCE","V500","CO")=0)
       RETURN(0)
      ENDIF
      SET dprmd_db = "SOURCE"
     ENDIF
     IF (dmr_get_db_info(dmr_mig_data->src_db_name,dmr_mig_data->src_created_date)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_db_os = dm2_sys_misc->cur_db_os
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_ora_version = dm2_rdbms_version->version
     SET dmr_mig_data->src_ora_level1 = dm2_rdbms_version->level1
     SET dmr_mig_data->src_ora_level2 = dm2_rdbms_version->level2
     SET dmr_mig_data->src_ora_level3 = dm2_rdbms_version->level3
     SET dmr_mig_data->src_ora_level4 = dm2_rdbms_version->level4
     IF (dmr_get_node_name(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_node_cnt = dmr_node->cnt
     SET stat = alterlist(dmr_mig_data->src_nodes,dmr_node->cnt)
     FOR (dprmd_cnt = 1 TO dmr_node->cnt)
       SET dmr_mig_data->src_nodes[dprmd_cnt].node_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        node_name)
       SET dmr_mig_data->src_nodes[dprmd_cnt].instance_number = dmr_node->qual[dprmd_cnt].
       instance_number
       SET dmr_mig_data->src_nodes[dprmd_cnt].instance_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        instance_name)
     ENDFOR
     SET dprmd_storage_type = ""
     IF (dmr_get_storage_type(dprmd_storage_type)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_storage_type = dprmd_storage_type
    ENDIF
    IF ((((dmr_mig_data->src_sys_pwd="DM2NOTSET")) OR ((dmr_mig_data->src_sys_cnct_str="DM2NOTSET")
    ))
     AND dprmd_sys_db_ind=1)
     IF (dmr_prompt_connect_data("SOURCE","SYS","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "SOURCE"
    ENDIF
   ENDIF
   IF (dprmd_tgt_db_ind=1)
    IF ((((dmr_mig_data->tgt_v500_pwd="DM2NOTSET")) OR ((dmr_mig_data->tgt_v500_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("TARGET","V500","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "TARGET"
     SET dprmd_confirm = 1
    ENDIF
    IF ((((dmr_mig_data->tgt_db_name="DM2NOTSET")) OR ((((dmr_mig_data->tgt_created_date=0.0)) OR (((
    (dmr_mig_data->tgt_db_os="DM2NOTSET")) OR ((((dmr_mig_data->tgt_ora_version="DM2NOTSET")) OR ((
    dmr_mig_data->tgt_node_cnt=0))) )) )) )) )
     IF (dprmd_db != "TARGET")
      IF (dmr_prompt_connect_data("TARGET","V500","CO")=0)
       RETURN(0)
      ENDIF
      SET dprmd_db = "TARGET"
     ENDIF
     IF (dmr_get_db_info(dmr_mig_data->tgt_db_name,dmr_mig_data->tgt_created_date)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_db_os = dm2_sys_misc->cur_db_os
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_ora_version = dm2_rdbms_version->version
     SET dmr_mig_data->tgt_ora_level1 = dm2_rdbms_version->level1
     SET dmr_mig_data->tgt_ora_level2 = dm2_rdbms_version->level2
     SET dmr_mig_data->tgt_ora_level3 = dm2_rdbms_version->level3
     SET dmr_mig_data->tgt_ora_level4 = dm2_rdbms_version->level4
     IF (dmr_get_node_name(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_node_cnt = dmr_node->cnt
     SET stat = alterlist(dmr_mig_data->tgt_nodes,dmr_node->cnt)
     FOR (dprmd_cnt = 1 TO dmr_node->cnt)
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].node_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        node_name)
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].instance_number = dmr_node->qual[dprmd_cnt].
       instance_number
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].instance_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        instance_name)
     ENDFOR
     SET dprmd_storage_type = ""
     IF (dmr_get_storage_type(dprmd_storage_type)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_storage_type = dprmd_storage_type
    ENDIF
   ENDIF
   IF (dmr_chk_mig_ora_version(dprmd_error_ret)=0)
    RETURN(0)
   ENDIF
   IF (dprmd_src_db_ind=1)
    IF ((dmr_mig_data->src_ora_level1 < 9))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check SOURCE Oracle version."
     SET dm_err->emsg = concat("SOURCE database Oracle version (",dmr_mig_data->src_ora_version,
      ") has to be 9 and higher.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dprmd_tgt_db_ind=1)
    IF ((dmr_mig_data->tgt_ora_level1 < 9))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check Target Oracle version."
     SET dm_err->emsg = concat("Target database Oracle version (",dmr_mig_data->tgt_ora_version,
      ") has to be 9 and higher.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dmr_mig_data->tgt_db_os="AXP"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check Target domain OS."
     SET dm_err->emsg = "Target database can not be VMS."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dprmd_src_db_ind=1
    AND dprmd_tgt_db_ind=1
    AND validate(dm2_skip_create_date_check,0) != 1)
    IF ((dmr_mig_data->tgt_created_date < dmr_mig_data->src_created_date))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Compare Source created date with Target created date."
     SET dm_err->emsg =
     "Target database created date may not be lower than Source database created date."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dprmd_error_ret=1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Compare Source oracle version with Target oracle version."
     SET dm_err->emsg = concat("Target oracle version ",dmr_mig_data->tgt_ora_version,
      " can not be lower than Source oracle version ",dmr_mig_data->src_ora_version)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF (dprmd_confirm=1)
    IF (dmr_issue_summary_screen(dprmd_src_db_ind,dprmd_tgt_db_ind,"")=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_issue_summary_screen(diss_src_db_ind,diss_tgt_db_ind,diss_msg)
   DECLARE diss_node_list = vc WITH protect, noconstant("")
   DECLARE diss_cnt = i4 WITH protect, noconstant(0)
   DECLARE diss_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE diss_col_num = i4 WITH protect, noconstant(0)
   DECLARE diss_length = i4 WITH protect, noconstant(0)
   DECLARE diss_rows_max = i4 WITH protect, constant(21)
   DECLARE diss_col_max = i4 WITH protect, constant(40)
   SET diss_col_num = 2
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,"DATABASE MIGRATION SUMMARY SCREEN")
   IF (diss_src_db_ind=1)
    CALL text(3,diss_col_num,"SOURCE")
    CALL text(4,diss_col_num,concat("Database Name : ",trim(dmr_mig_data->src_db_name)))
    CALL text(5,diss_col_num,concat("Database Create Date : ",format(dmr_mig_data->src_created_date,
       "mm-dd-yyyy;;d")))
    CALL text(6,diss_col_num,concat("Database Operating System : ",trim(dmr_mig_data->src_db_os)))
    CALL text(7,diss_col_num,concat("Database Oracle Version : ",trim(dmr_mig_data->src_ora_version))
     )
    CALL text(8,diss_col_num,"Database Nodes : ")
    SET diss_node_list = ""
    FOR (diss_cnt = 1 TO dmr_mig_data->src_node_cnt)
      IF ((dmr_mig_data->src_node_cnt > 1)
       AND diss_cnt != 1)
       SET diss_node_list = concat(diss_node_list,", ",dmr_mig_data->src_nodes[diss_cnt].node_name)
      ELSE
       SET diss_node_list = dmr_mig_data->src_nodes[diss_cnt].node_name
      ENDIF
    ENDFOR
    SET diss_cnt = 0
    SET diss_row_cnt = 9
    WHILE (diss_cnt < size(diss_node_list)
     AND diss_row_cnt < diss_rows_max)
      IF (size(diss_node_list) < diss_col_max)
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_col_max,
          diss_node_list)))
       SET diss_length = diss_col_max
      ELSE
       SET diss_length = findstring(",",substring((diss_cnt+ 1),diss_col_max,diss_node_list),(
        diss_cnt+ 1),1)
       IF (diss_length=0)
        SET diss_length = diss_col_max
       ENDIF
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_length,
          diss_node_list)))
      ENDIF
      SET diss_cnt = (diss_cnt+ diss_length)
      SET diss_row_cnt = (diss_row_cnt+ 1)
    ENDWHILE
   ENDIF
   IF (diss_tgt_db_ind=1)
    SET diss_col_num = evaluate(diss_src_db_ind,1,60,2)
    CALL text(3,diss_col_num,"TARGET")
    CALL text(4,diss_col_num,concat("Database Name : ",trim(dmr_mig_data->tgt_db_name)))
    CALL text(5,diss_col_num,concat("Database Create Date : ",format(dmr_mig_data->tgt_created_date,
       "mm-dd-yyyy;;d")))
    CALL text(6,diss_col_num,concat("Database Operating System : ",trim(dmr_mig_data->tgt_db_os)))
    CALL text(7,diss_col_num,concat("Database Oracle Version : ",trim(dmr_mig_data->tgt_ora_version))
     )
    CALL text(8,diss_col_num,"Database Nodes : ")
    SET diss_node_list = ""
    FOR (diss_cnt = 1 TO dmr_mig_data->tgt_node_cnt)
      IF ((dmr_mig_data->tgt_node_cnt > 1)
       AND diss_cnt != 1)
       SET diss_node_list = concat(diss_node_list,", ",dmr_mig_data->tgt_nodes[diss_cnt].node_name)
      ELSE
       SET diss_node_list = dmr_mig_data->tgt_nodes[diss_cnt].node_name
      ENDIF
    ENDFOR
    SET diss_cnt = 0
    SET diss_row_cnt = 9
    WHILE (diss_cnt < size(diss_node_list)
     AND diss_row_cnt < diss_rows_max)
      IF (size(diss_node_list) < diss_col_max)
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_col_max,
          diss_node_list)))
       SET diss_length = diss_col_max
      ELSE
       SET diss_length = findstring(",",substring((diss_cnt+ 1),diss_col_max,diss_node_list),(
        diss_cnt+ 1),1)
       IF (diss_length=0)
        SET diss_length = diss_col_max
       ENDIF
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_length,
          diss_node_list)))
      ENDIF
      SET diss_cnt = (diss_cnt+ diss_length)
      SET diss_row_cnt = (diss_row_cnt+ 1)
    ENDWHILE
   ENDIF
   CALL video(r)
   CALL text(22,2,"PLEASE PREVIEW ALL THE VALUES BEFORE CONTINUING!")
   IF (diss_msg > "")
    CALL text(23,2,diss_msg)
   ENDIF
   CALL video(n)
   CALL text(24,2,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(24,50,"p;cu"," "
    WHERE curaccept IN ("C", "Q"))
   SET message = nowindow
   IF (curaccept="Q")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Prompt for Summary Information."
    SET dm_err->emsg = "User elected to quit at Database Migration Summary Screen."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curaccept="C")
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_get_node_name(null)
   IF ((dmr_node->cnt > 0))
    SET dmr_node->cnt = 0
    SET stat = alterlist(dmr_node->qual,0)
   ENDIF
   SET dm_err->eproc = "Determining all the node names that database resides on"
   SELECT INTO "nl:"
    FROM v$thread vt,
     gv$instance vi
    PLAN (vt)
     JOIN (vi
     WHERE vt.thread#=vi.thread#)
    ORDER BY vi.instance_number
    DETAIL
     dmr_node->cnt = (dmr_node->cnt+ 1)
     IF (mod(dmr_node->cnt,10)=1)
      stat = alterlist(dmr_node->qual,(dmr_node->cnt+ 9))
     ENDIF
     dmr_node->qual[dmr_node->cnt].instance_name = vi.instance_name, dmr_node->qual[dmr_node->cnt].
     instance_number = vi.instance_number, dmr_node->qual[dmr_node->cnt].node_name = vi.host_name
    FOOT REPORT
     stat = alterlist(dmr_node->qual,dmr_node->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(dmr_node)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_queue_contents(batch_queue)
   DECLARE dgqc_temp_line = vc WITH protect, noconstant("")
   DECLARE dgqc_field_num = i4 WITH protect, noconstant(1)
   DECLARE dgqc_start_pos = i4 WITH protect, noconstant(1)
   DECLARE dgqc_end_pos = i4 WITH protect, noconstant(1)
   DECLARE dgqc_continue = i4 WITH protect, noconstant(1)
   DECLARE dgqc_iter = i4 WITH protect, noconstant(0)
   IF (dm2_push_dcl(concat("SHOW QUEUE ",batch_queue))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
   SET dm_err->eproc = "Parsing queue contents."
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     dmr_queue->cnt = 0, stat = alterlist(dmr_queue->qual,0)
    DETAIL
     dgqc_temp_line = trim(r.line,3)
     FOR (dgqc_iter = 1 TO 5)
       dgqc_temp_line = replace(dgqc_temp_line,"  "," ",0)
     ENDFOR
     dgqc_start_pos = 1, dgqc_continue = 1
     IF (dgqc_temp_line != ""
      AND dgqc_temp_line != "Entry*"
      AND dgqc_temp_line != "-----*"
      AND dgqc_temp_line != "Batch queue*")
      WHILE (dgqc_continue=1)
        IF (dgqc_field_num <= 3
         AND findstring(" ",dgqc_temp_line,dgqc_start_pos) > 0)
         dgqc_end_pos = least(findstring(" ",dgqc_temp_line,dgqc_start_pos),(size(dgqc_temp_line)+ 1)
          )
        ELSE
         dgqc_end_pos = (size(dgqc_temp_line)+ 1)
        ENDIF
        CASE (dgqc_field_num)
         OF 1:
          dmr_queue->cnt = (dmr_queue->cnt+ 1),stat = alterlist(dmr_queue->qual,dmr_queue->cnt),
          dmr_queue->qual[dmr_queue->cnt].entry = cnvtint(substring(dgqc_start_pos,(dgqc_end_pos -
            dgqc_start_pos),dgqc_temp_line))
         OF 2:
          dmr_queue->qual[dmr_queue->cnt].jobname = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
         OF 3:
          dmr_queue->qual[dmr_queue->cnt].username = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
         OF 4:
          dmr_queue->qual[dmr_queue->cnt].status = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
        ENDCASE
        dgqc_start_pos = (dgqc_end_pos+ 1), dgqc_field_num = (dgqc_field_num+ 1)
        IF (dgqc_start_pos >= size(dgqc_temp_line))
         dgqc_continue = 0
        ENDIF
        IF (dgqc_field_num=5)
         dgqc_field_num = 1, dgqc_continue = 0
        ENDIF
      ENDWHILE
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_queue)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_check_directory(directory)
   IF (get_unique_file("dm2wrtprvtst",".dat")=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Determining if ",directory," is valid with write privs.")
   SELECT INTO value(build(directory,cnvtlower(dm_err->unique_fname)))
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test of writing to ", directory
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat("DELETE ",directory,cnvtlower(dm_err->unique_fname),";",char(42)))=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_push_dcl(concat("rm ",directory,cnvtlower(dm_err->unique_fname)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_unique_file_name(directory,file_prefix,file_suffix)
   DECLARE dgufn_continue = i2 WITH protect, noconstant(1)
   DECLARE dgufn_file_name = vc WITH protect, noconstant("")
   DECLARE dgufn_unique_tempstr = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Getting unique file name using directory: ",directory," prefix: ",
    file_prefix," and ext: ",
    file_suffix)
   IF (textlen(concat(file_prefix,file_suffix)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   WHILE (dgufn_continue=1)
     SET dgufn_unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
        cnvtdatetime(curdate,000000)) * 864000)))
     IF (directory > "")
      SET dgufn_file_name = build(directory,file_prefix,dgufn_unique_tempstr,file_suffix)
     ELSE
      SET dgufn_file_name = build(file_prefix,dgufn_unique_tempstr,file_suffix)
     ENDIF
     IF (findfile(dgufn_file_name)=0)
      SET dgufn_continue = 0
      SET dm_err->unique_fname = dgufn_file_name
     ENDIF
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_fill_email_list(null)
   SET dm_err->eproc = "Querying for list of email addresses from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_EMAILS"
    ORDER BY di.info_name
    HEAD REPORT
     dmr_emails->change_ind = 0, dmr_emails->cnt = 0, stat = alterlist(dmr_emails->qual,dmr_emails->
      cnt),
     dmr_emails->email_list = ""
    DETAIL
     dmr_emails->cnt = (dmr_emails->cnt+ 1), stat = alterlist(dmr_emails->qual,dmr_emails->cnt),
     dmr_emails->qual[dmr_emails->cnt].email_address = di.info_name
     IF ((dmr_emails->cnt=1))
      dmr_emails->email_list = di.info_name
     ELSE
      dmr_emails->email_list = concat(dmr_emails->email_list,",",di.info_name)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_send_email(subject,address_list,file_name)
   IF (((trim(subject)="") OR (((trim(address_list)="") OR (trim(file_name)="")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat('MAIL/SUBJECT="',build(subject),'" ',build(file_name),' "',
      build(address_list),'"'))=0)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_sys_misc->cur_os IN ("AIX", "LNX")))
    IF (dm2_push_dcl(concat('mail -s "',subject,'" "',address_list,'" < ',
      file_name))=0)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_sys_misc->cur_os="HPX"))
    IF (dm2_push_dcl(concat('mailx -s "',subject,'" "',address_list,'" < ',
      file_name))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_user_list(null)
   SET dm_err->eproc = "Querying for list of users from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_USER"
    ORDER BY di.info_name
    HEAD REPORT
     dmr_user_list->cnt = 0, stat = alterlist(dmr_user_list->qual,0), dmr_user_list->change_ind = 0
    DETAIL
     dmr_user_list->cnt = (dmr_user_list->cnt+ 1), stat = alterlist(dmr_user_list->qual,dmr_user_list
      ->cnt), dmr_user_list->qual[dmr_user_list->cnt].user = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_verify_v500_user(exists_ind)
   SET dm_err->eproc = "Querying for list of users from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_USER"
     AND di.info_name="V500"
    HEAD REPORT
     exists_ind = 0
    DETAIL
     exists_ind = 1
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_gg_dir(null)
   DECLARE dggd_cap_dir = vc WITH protect, noconstant("/ggcapture")
   DECLARE dggd_del_dir = vc WITH protect, noconstant("/ggdelivery")
   SET dmr_mig_data->report_all = 0
   SET dmr_mig_data->report_capture = 0
   SET dmr_mig_data->report_delivery = 0
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dggd_cap_dir = "GGCAPTURE:[000000]"
    SET dggd_del_dir = "GGDELIVERY:[000000]"
   ENDIF
   IF (dm2_find_dir(dggd_cap_dir)=1)
    SET dmr_mig_data->report_capture = 1
   ELSEIF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dm2_find_dir(dggd_del_dir)=1)
    SET dmr_mig_data->report_delivery = 1
   ELSEIF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dmr_mig_data->report_delivery=1)
    AND (dmr_mig_data->report_capture=1))
    SET dmr_mig_data->report_all = 1
   ENDIF
   CALL dmr_set_gg_files(dmr_mig_data->report_capture,dmr_mig_data->report_delivery)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_set_gg_files(dsgf_report_capture,dsgf_report_delivery)
   SET dmr_mig_data->cap_dir = "DM2NOTSET"
   SET dmr_mig_data->cap_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_err_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_dir = "DM2NOTSET"
   SET dmr_mig_data->del_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_err_rpt = "DM2NOTSET"
   IF ((dm2_sys_misc->cur_os="AXP")
    AND dsgf_report_capture=1)
    SET dmr_mig_data->cap_dir = "GGCAPTURE:[000000]"
    SET dmr_mig_data->cap_mgr_rpt = "GGCAPTURE:[DIRRPT]$MGR.$RPT"
    SET dmr_mig_data->cap_rpt = "GGCAPTURE:[DIRRPT]$CAPTURE.$RPT"
    SET dmr_mig_data->cap_err_rpt = "GGCAPTURE:[000000]GGSERR.LOG"
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND dsgf_report_delivery=1)
    SET dmr_mig_data->del_dir = "GGDELIVERY:[000000]"
    SET dmr_mig_data->del_mgr_rpt = "GGDELIVERY:[DIRRPT]$MGR.$RPT"
    SET dmr_mig_data->del_rpt = "GGDELIVERY:[DIRRPT]$DELIVERY.$RPT"
    SET dmr_mig_data->del_err_rpt = "GGDELIVERY:[000000]GGSERR.LOG"
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))
    AND dsgf_report_capture=1)
    SET dmr_mig_data->cap_dir = "/ggcapture"
    SET dmr_mig_data->cap_mgr_rpt = "/ggcapture/dirrpt/mgr.rpt"
    SET dmr_mig_data->cap_rpt = "/ggcapture/dirrpt/capture.rpt"
    SET dmr_mig_data->cap_err_rpt = "/ggcapture/ggserr.log"
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))
    AND dsgf_report_delivery=1)
    SET dmr_mig_data->del_dir = "/ggdelivery"
    SET dmr_mig_data->del_mgr_rpt = "/ggdelivery/dirrpt/mgr.rpt"
    SET dmr_mig_data->del_rpt = "/ggdelivery/dirrpt/delivery.rpt"
    SET dmr_mig_data->del_err_rpt = "/ggdelivery/ggserr.log"
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_directory_prompt(mode)
   DECLARE ddp_dir_acceptable_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_src_ora_home_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_tgt_ora_home_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_src_file_loc_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_tgt_file_loc_exists_ind = i2 WITH protect, noconstant(0)
   IF ( NOT (dm2_find_dir(evaluate(dm2_sys_misc->cur_os,"AXP","GGDELIVERY:[DIRTMP]",
     "/ggdelivery/dirtmp"))))
    SET dmr_expimp->src_ksh_loc = " "
   ELSE
    SET dmr_expimp->src_ksh_loc = evaluate(dm2_sys_misc->cur_os,"AXP","GGDELIVERY:[DIRTMP]",
     "/ggdelivery/dirtmp")
   ENDIF
   SET dm_err->eproc = "Gathering existing bulk data move rows from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
     AND di.info_name IN ("SOURCE_ORACLE_HOME", "TARGET_ORACLE_HOME", "LOCAL_DIR", "TARGET_DB_DIR")
    DETAIL
     CASE (di.info_name)
      OF "SOURCE_ORACLE_HOME":
       dmr_expimp->src_ora_home = di.info_char,ddp_src_ora_home_exists_ind = 1
      OF "TARGET_ORACLE_HOME":
       dmr_expimp->tgt_ora_home = di.info_char,ddp_tgt_ora_home_exists_ind = 1
      OF "LOCAL_DIR":
       dmr_expimp->src_ksh_loc = di.info_char,ddp_src_file_loc_exists_ind = 1
      OF "TARGET_DB_DIR":
       dmr_expimp->tgt_file_loc = di.info_char,ddp_tgt_file_loc_exists_ind = 1
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (mode=2)
    RETURN(1)
   ENDIF
   IF ((dmr_mig_data->src_ora_version != dmr_mig_data->tgt_ora_version))
    SET dmr_expimp->diff_ora_version = 1
   ENDIF
   SET dm_err->eproc = "Display Create Export/Import Files Prompts."
   CALL disp_msg("",dm_err->logfile,0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Database Migration Default Directory Locations")
   CALL text(6,2,concat("Oracle Home for Oracle ",trim(cnvtstring(dmr_mig_data->src_ora_level1)),
     " on node ",dmr_mig_data->tgt_nodes[1].node_name))
   CALL text(7,2,concat("(compatible with SOURCE database Oracle ",trim(dmr_mig_data->src_ora_version
      ),"):"))
   CALL accept(7,60,"P(50);C",dmr_expimp->src_ora_home
    WHERE  NOT (curaccept=" "))
   SET dmr_expimp->src_ora_home = trim(curaccept)
   IF (substring(size(dmr_expimp->src_ora_home),1,dmr_expimp->src_ora_home)="/")
    SET dmr_expimp->src_ora_home = replace(dmr_expimp->src_ora_home,"/","",2)
   ENDIF
   IF (ddp_src_ora_home_exists_ind)
    SET dm_err->eproc = "Updating existing SOURCE_ORACLE_HOME row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->src_ora_home
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="SOURCE_ORACLE_HOME"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new SOURCE_ORACLE_HOME row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "SOURCE_ORACLE_HOME", di.info_char
       = dmr_expimp->src_ora_home
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(9,2,concat("Oracle Home for Oracle ",trim(cnvtstring(dmr_mig_data->tgt_ora_level1)),
     " on node ",dmr_mig_data->tgt_nodes[1].node_name))
   CALL text(10,2,concat("(compatible with TARGET database Oracle ",trim(dmr_mig_data->
      tgt_ora_version),"):"))
   IF ((dmr_expimp->diff_ora_version=1))
    CALL accept(10,60,"P(50);C",dmr_expimp->tgt_ora_home
     WHERE  NOT (curaccept=" "))
    SET dmr_expimp->tgt_ora_home = trim(curaccept)
    IF (substring(size(dmr_expimp->tgt_ora_home),1,dmr_expimp->tgt_ora_home)="/")
     SET dmr_expimp->tgt_ora_home = replace(dmr_expimp->tgt_ora_home,"/","",2)
    ENDIF
   ELSE
    SET dmr_expimp->tgt_ora_home = dmr_expimp->src_ora_home
    CALL text(10,60,dmr_expimp->tgt_ora_home)
   ENDIF
   IF (ddp_tgt_ora_home_exists_ind)
    SET dm_err->eproc = "Updating existing TARGET_ORACLE_HOME row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->tgt_ora_home
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="TARGET_ORACLE_HOME"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new TARGET_ORACLE_HOME row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "TARGET_ORACLE_HOME", di.info_char
       = dmr_expimp->tgt_ora_home
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(12,2,concat("Local Directory Location:"))
   CALL text(13,4,"(where ksh/par files will be created on this node)")
   SET ddp_dir_acceptable_ind = 1
   WHILE (ddp_dir_acceptable_ind)
    IF ((dm2_sys_misc->cur_os="AXP"))
     CALL accept(12,29,"P(60);CU",dmr_expimp->src_ksh_loc
      WHERE curaccept != ""
       AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
    ELSE
     CALL accept(12,29,"P(60);C",dmr_expimp->src_ksh_loc
      WHERE curaccept != ""
       AND substring(1,1,curaccept)="/")
    ENDIF
    IF ((curaccept != dmr_expimp->src_ksh_loc))
     SET dmr_expimp->src_ksh_loc = curaccept
     IF (substring(size(dmr_expimp->src_ksh_loc),1,dmr_expimp->src_ksh_loc)="/")
      SET dmr_expimp->src_ksh_loc = replace(dmr_expimp->src_ksh_loc,"/","",2)
     ENDIF
     IF (dm2_find_dir(dmr_expimp->src_ksh_loc))
      SET ddp_dir_acceptable_ind = 0
      CALL clear(23,1,129)
     ELSE
      CALL text(23,2,"The directory entered does not exist.")
     ENDIF
    ELSE
     SET ddp_dir_acceptable_ind = 0
    ENDIF
   ENDWHILE
   IF (ddp_src_file_loc_exists_ind)
    SET dm_err->eproc = "Updating existing LOCAL_DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->src_ksh_loc
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="LOCAL_DIR"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new LOCAL_DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "LOCAL_DIR", di.info_char =
      dmr_expimp->src_ksh_loc
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(15,2,concat("Target Database Node Directory Location:"))
   CALL text(16,4,"(where ksh files will be copied to and executed from)")
   CALL accept(15,44,"P(60);C",dmr_expimp->tgt_file_loc
    WHERE curaccept != ""
     AND substring(1,1,curaccept)="/")
   SET dmr_expimp->tgt_file_loc = curaccept
   IF (substring(size(dmr_expimp->tgt_file_loc),1,dmr_expimp->tgt_file_loc)="/")
    SET dmr_expimp->tgt_file_loc = replace(dmr_expimp->tgt_file_loc,"/","",2)
   ENDIF
   IF (ddp_tgt_file_loc_exists_ind)
    SET dm_err->eproc = "Updating existing TARGET_DB_DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->tgt_file_loc
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="TARGET_DB_DIR"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new TARGET_DB_DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "TARGET_DB_DIR", di.info_char =
      dmr_expimp->tgt_file_loc
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(23,2,"Enter 'C' to continue or 'Q' to quit (C or Q): ")
   CALL accept(23,50,"P;CU"," "
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
    SET message = nowindow
    CALL clear(1,1)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   DECLARE dsbq_queue_fnd_ret = i2 WITH protect, noconstant(0)
   DECLARE dsbq_job_limit_str = vc WITH protect, noconstant(" ")
   DECLARE dsbq_job_limit = i2 WITH protect, noconstant(1)
   DECLARE dsbq_job_limit_accept = i2 WITH protect, noconstant(0)
   DECLARE dsbq_job_limit_fnd = i2 WITH protect, noconstant(0)
   DECLARE dsbq_temp_line = vc WITH protect, noconstant(" ")
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
   IF (dmr_check_batch_queue(dsbq_queue_name,dsbq_queue_fnd_ret)=0)
    RETURN(0)
   ENDIF
   IF (dsbq_queue_fnd_ret=1)
    SET dsbq_job_limit = 0
    SET dsbq_job_limit_fnd = 0
    IF (dm2_push_dcl(concat("SHOW QUEUE /full ",dsbq_queue_name))=0)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
    SET dm_err->eproc = "Parsing queue contents for job_limit."
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     DETAIL
      dsbq_temp_line = trim(r.line,3)
      FOR (dgqc_iter = 1 TO 5)
        dsbq_temp_line = replace(dsbq_temp_line,"  "," ",0)
      ENDFOR
      dsbq_start_pos = findstring("JOB_LIMIT",cnvtupper(dsbq_temp_line),1)
      IF (dsbq_start_pos > 0)
       dsbq_job_limit_fnd = 1, dsbq_end_pos = findstring(" ",dsbq_temp_line,dsbq_start_pos)
       IF (dsbq_end_pos > 0)
        dsbq_job_limit_str = trim(substring((dsbq_start_pos+ 10),(dsbq_end_pos - (dsbq_start_pos+ 10)
          ),dsbq_temp_line),3),
        CALL cancel(1)
       ELSE
        dm_err->err_ind = 1, dm_err->emsg = "Failed to parse out job_limit from queue data",
        CALL cancel(1)
       ENDIF
      ENDIF
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (((dsbq_job_limit_fnd=0) OR (isnumeric(dsbq_job_limit_str) != 1)) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to parse out job_limit for queue data."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dsbq_job_limit = cnvtint(dsbq_job_limit_str)
    ENDIF
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,"Provide a job limit (1-20) for migration batch queue (0 to Quit): ")
   CALL accept(2,67,"99",dsbq_job_limit
    WHERE curaccept BETWEEN 0 AND 20)
   SET dsbq_job_limit_accept = curaccept
   SET message = nowindow
   IF (dsbq_job_limit_accept=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Migration Batch Queue Job Limit Prompt."
    SET dm_err->emsg = "User choose to Quit."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsbq_queue_fnd_ret=0)
    SET dsbq_cmd = concat(build("init/queue/batch/start/job_limit=",dsbq_job_limit_accept)," ",
     dsbq_queue_name)
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
   ELSEIF (dsbq_queue_fnd_ret=1
    AND dsbq_job_limit_accept != dsbq_job_limit)
    SET dsbq_cmd = concat(build("set queue/job_limit=",dsbq_job_limit_accept)," ",dsbq_queue_name)
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
 SUBROUTINE dmr_check_batch_queue(dcbq_queue_name,dcbq_queue_fnd_ret)
   DECLARE dcbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dcbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dcbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dcbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dcbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dcbq_err_str = vc WITH protect, constant("no such queue")
   SET dcbq_queue_fnd_ret = 0
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating current operating system is AXP."
    SET dm_err->emsg = "Invalid current operating system."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dcbq_queue_name=" ") OR (dcbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcbq_cmd = concat("sho queue /full ",dcbq_queue_name)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dcbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dcbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dcbq_queue_fnd_ret = 0
   ELSEIF (findstring(cnvtlower(dcbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dcbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dcbq_queue_fnd_ret = 1
   ENDIF
   IF (dcbq_queue_fnd_ret=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dcbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_validate_src_and_tgt(dvst_src_ind,dvst_tgt_ind)
   DECLARE dvsat_db = vc WITH protect, noconstant("")
   DECLARE dvsat_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvsat_str = vc WITH protect, noconstant("")
   IF (dvst_src_ind=1)
    IF (dmr_prompt_connect_data("SOURCE","V500","PC")=0)
     RETURN(0)
    ENDIF
    SET dvsat_db = "SOURCE"
    IF (dmr_get_db_info(dmr_mig_data->src_db_name,dmr_mig_data->src_created_date)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_db_os = dm2_sys_misc->cur_db_os
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_ora_version = dm2_rdbms_version->version
    SET dmr_mig_data->src_ora_level1 = dm2_rdbms_version->level1
    SET dmr_mig_data->src_ora_level2 = dm2_rdbms_version->level2
    SET dmr_mig_data->src_ora_level3 = dm2_rdbms_version->level3
    SET dmr_mig_data->src_ora_level4 = dm2_rdbms_version->level4
    SET dvsat_str = ""
    IF (dmr_get_storage_type(dvsat_str)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_storage_type = dvsat_str
    IF (dmr_get_node_name(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_node_cnt = dmr_node->cnt
    SET stat = alterlist(dmr_mig_data->src_nodes,dmr_node->cnt)
    FOR (dvsat_cnt = 1 TO dmr_node->cnt)
      SET dmr_mig_data->src_nodes[dvsat_cnt].node_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       node_name)
      SET dmr_mig_data->src_nodes[dvsat_cnt].instance_number = dmr_node->qual[dvsat_cnt].
      instance_number
      SET dmr_mig_data->src_nodes[dvsat_cnt].instance_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       instance_name)
    ENDFOR
   ENDIF
   IF (dvst_tgt_ind=1)
    IF (dmr_prompt_connect_data("TARGET","V500","PC")=0)
     RETURN(0)
    ENDIF
    SET dvsat_db = "TARGET"
    SET dm_err->eproc = "Get databse name and created date"
    IF (dmr_get_db_info(dmr_mig_data->tgt_db_name,dmr_mig_data->tgt_created_date)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_db_os = dm2_sys_misc->cur_db_os
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_ora_version = dm2_rdbms_version->version
    SET dmr_mig_data->tgt_ora_level1 = dm2_rdbms_version->level1
    SET dmr_mig_data->tgt_ora_level2 = dm2_rdbms_version->level2
    SET dmr_mig_data->tgt_ora_level3 = dm2_rdbms_version->level3
    SET dmr_mig_data->tgt_ora_level4 = dm2_rdbms_version->level4
    SET dvsat_str = ""
    IF (dmr_get_storage_type(dvsat_str)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_storage_type = dvsat_str
    IF (dmr_get_node_name(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_node_cnt = dmr_node->cnt
    SET stat = alterlist(dmr_mig_data->tgt_nodes,dmr_node->cnt)
    FOR (dvsat_cnt = 1 TO dmr_node->cnt)
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].node_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       node_name)
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].instance_number = dmr_node->qual[dvsat_cnt].
      instance_number
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].instance_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       instance_name)
    ENDFOR
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF (dmr_issue_summary_screen(dvst_src_ind,dvst_tgt_ind,"")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_stop_job(job_type,job_mode)
   DECLARE dsj_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dsj_iter = i4 WITH protect, noconstant(0)
   DECLARE dsj_info_name = vc WITH protect, noconstant("")
   IF ((dm_err->debug_flag=722))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF ((((dmr_mig_data->report_all=1)) OR ((dmr_mig_data->report_capture=1))) )
    SET dsj_info_name = "STOP_CAPTURE_MONITORING"
   ELSEIF ((dmr_mig_data->report_delivery=1))
    SET dsj_info_name = "STOP_DELIVERY_MONITORING"
   ELSE
    IF (job_mode=1)
     SET message = nowindow
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Checking execution status"
    SET dm_err->emsg = "GGDELIVERY or GGCAPTURE do not exist. Unable to stop job."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dmr_get_queue_contents(dmr_batch_queue)=0)
     RETURN(0)
    ENDIF
    FOR (dsj_iter = 1 TO dmr_queue->cnt)
      IF ((dmr_queue->qual[dsj_iter].jobname=evaluate(job_type,"ARCH","DM2_MIG_COPY_ARCHIVELOGS",
       "MON","DM2_MIG_MONITORING")))
       SET dsj_found_ind = 1
      ENDIF
    ENDFOR
   ELSE
    IF (dm2_push_dcl("ps -ef | grep dm2_mig_monitoring.ksh")=0)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
    SET dm_err->eproc = "Determining if there were any results obtainted from the ps command."
    SELECT INTO "nl:"
     FROM rtlt r
     DETAIL
      IF (trim(r.line,3) != "* grep *")
       dsj_found_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsj_found_ind)
    SET dm_err->eproc = concat("Determining if STOP row exists for ",job_type," from dm_info.")
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_MIG_DATA"
      AND di.info_name=value(evaluate(job_type,"ARCH","STOP_ARCHIVE_COPY","MON",dsj_info_name))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = concat("Inserting STOP row for ",job_type," into dm_info.")
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_MIG_DATA", di.info_name = value(evaluate(job_type,"ARCH",
         "STOP_ARCHIVE_COPY","MON",dsj_info_name))
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
    IF (job_mode=1)
     CALL text(21,10,
      "The job has been marked for deletion. Please monitor with Status of Job menu option. Press <enter> to continue."
      )
     CALL accept(21,122,"A;CH"," ")
     CALL clear(21,2,129)
    ENDIF
   ELSE
    IF (job_mode=1)
     CALL text(21,10,"No matching jobs were found.  Press <enter> to continue.")
     CALL accept(21,67,"A;CH"," ")
     CALL clear(21,2,129)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_storage_type(dgst_storage_ret)
  IF ((dm2_sys_misc->cur_db_os="AXP"))
   SET dgst_storage_ret = "AXP"
  ELSE
   SET dm_err->eproc = "Determine target storage type from dba_data_files"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    WHERE ddf.tablespace_name="SYSTEM"
     AND ddf.file_name=patstring("/dev/*")
    DETAIL
     dgst_storage_ret = "RAW"
    WITH nocounter, maxqual = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dgst_storage_ret = "ASM"
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_managed_tables(dlmt_mng_ret)
   DECLARE dlmt_dm_info_exists = i2 WITH protect, noconstant(0)
   SET dlmt_mng_ret = "'DM_STAT_TABLE','PLAN_TABLE','DM_CONSTRAINT_EXCEPTIONS'"
   IF (dm2_table_and_ccldef_exists("DM_INFO",dlmt_dm_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dlmt_dm_info_exists=1)
    SET dm_err->eproc = "Loading list of managed tables from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_MIGRATION"
      AND di.info_name="MANAGED TABLES"
     DETAIL
      dlmt_mng_ret = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_mig_setup_gg_dir(null)
   DECLARE dmsgd_gg_cap_dir_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dmsgd_gg_del_dir_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dmsgd_gg_cap_loc = vc WITH protect, noconstant("")
   DECLARE dmsgd_gg_del_loc = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Determining if Directory setup row already exists in dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_GG_DATA"
     AND di.info_name IN ("GG_CAP_DIR", "GG_DEL_DIR")
    DETAIL
     IF (di.info_name="GG_CAP_DIR")
      dmsgd_gg_cap_loc = di.info_char, dmsgd_gg_cap_dir_exists_ind = 1
     ELSE
      dmsgd_gg_del_loc = di.info_char, dmsgd_gg_del_dir_exists_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Database Migration Capture/Delivery Directory Locations")
   CALL text(6,2,concat("Capture Directory Location:"))
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(6,29,"P(90);CU",dmsgd_gg_cap_loc
     WHERE curaccept != ""
      AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
   ELSE
    CALL accept(6,29,"P(90);C",dmsgd_gg_cap_loc
     WHERE curaccept != ""
      AND substring(1,1,curaccept)="/")
   ENDIF
   SET dmsgd_gg_cap_loc = curaccept
   IF (substring(size(dmsgd_gg_cap_loc),1,dmsgd_gg_cap_loc)="/")
    SET dmsgd_gg_cap_loc = trim(replace(dmsgd_gg_cap_loc,"/","",2),3)
   ENDIF
   IF (dmsgd_gg_cap_dir_exists_ind)
    SET dm_err->eproc = "Updating existing Capture DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmsgd_gg_cap_loc
     WHERE di.info_domain="DM2_MIG_GG_DATA"
      AND di.info_name="GG_CAP_DIR"
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->eproc = "Inserting new Capture DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_GG_DATA", di.info_name = "GG_CAP_DIR", di.info_char =
      dmsgd_gg_cap_loc
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   CALL text(8,2,concat("Delivery Directory Location:"))
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(8,30,"P(90);CU",dmsgd_gg_del_loc
     WHERE curaccept != ""
      AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
   ELSE
    CALL accept(8,30,"P(90);C",dmsgd_gg_del_loc
     WHERE curaccept != ""
      AND substring(1,1,curaccept)="/")
   ENDIF
   SET dmsgd_gg_del_loc = curaccept
   IF (substring(size(dmsgd_gg_del_loc),1,dmsgd_gg_del_loc)="/")
    SET dmsgd_gg_del_loc = trim(replace(dmsgd_gg_del_loc,"/","",2),3)
   ENDIF
   IF (dmsgd_gg_del_dir_exists_ind)
    SET dm_err->eproc = "Updating existing Delivery DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmsgd_gg_del_loc
     WHERE di.info_domain="DM2_MIG_GG_DATA"
      AND di.info_name="GG_DEL_DIR"
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->eproc = "Inserting new Delivery DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_GG_DATA", di.info_name = "GG_DEL_DIR", di.info_char =
      dmsgd_gg_del_loc
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_di_filter(null)
   DECLARE dldf_cnt = i4 WITH protect, noconstant(0)
   SET dldf_cnt = 0
   SET dmr_di_filter->cnt = 19
   SET stat = alterlist(dmr_di_filter->qual,dmr_di_filter->cnt)
   SET dmr_di_filter->qual[1].name = "STATS LOCK"
   SET dmr_di_filter->qual[2].name = "QUEUE DBSTATS LOCK"
   SET dmr_di_filter->qual[3].name = "FREQUENT STATS GATHER LOCK"
   SET dmr_di_filter->qual[4].name = "DM2_DBSTATS_ADJUSTMENT"
   SET dmr_di_filter->qual[5].name = "DM_HIGHLOW_MOD"
   SET dmr_di_filter->qual[6].name = "DM_HIGHLOW_MOD_HISTOGRAM"
   SET dmr_di_filter->qual[7].name = "DM2 INSTALL PROCESS"
   SET dmr_di_filter->qual[8].name = "DM2_UTC_SCHEMA_RUNNER"
   SET dmr_di_filter->qual[9].name = "DM2_MIG_DI_FILTER"
   SET dmr_di_filter->qual[10].name = "DM2_BACKGROUND_RUNNER"
   SET dmr_di_filter->qual[11].name = "DM2_INSTALL_RUNNER"
   SET dmr_di_filter->qual[12].name = "DM2_SCHEMA_RUNNER"
   SET dmr_di_filter->qual[13].name = "DM2_README_RUNNER"
   SET dmr_di_filter->qual[14].name = "DM2_SET_READY_TO_RUN"
   SET dmr_di_filter->qual[15].name = "DM2_INSTALL_PKG"
   SET dmr_di_filter->qual[16].name = "DM2_INSTALL_MONITOR"
   SET dmr_di_filter->qual[17].name = "DM2_FLEX_SCHED_USAGE"
   SET dmr_di_filter->qual[18].name = "DM2GDBS%"
   SET dmr_di_filter->qual[19].name = "DM2_MIG_STATUS_MARKER"
   SET dm_err->eproc = "Remove DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_MIG_DI_FILTER"
     AND expand(dldf_cnt,1,dmr_di_filter->cnt,di.info_name,dmr_di_filter->qual[dldf_cnt].name)
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Add DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di,
     (dummyt d  WITH seq = value(size(dmr_di_filter->qual,5)))
    SET di.info_domain = "DM2_MIG_DI_FILTER", di.info_name = dmr_di_filter->qual[d.seq].name, di
     .updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d
     WHERE d.seq > 0)
     JOIN (di)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_di_filter(null)
   DECLARE dgdf_fail_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   SET dmr_di_filter->cnt = 0
   SET stat = alterlist(dmr_di_filter->qual,dmr_di_filter->cnt)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_DI_FILTER"
    DETAIL
     IF (findstring("%",di.info_name,1,0) > 0)
      IF (((findstring("%",di.info_name,1,0) != findstring("%",di.info_name,1,1)) OR (findstring(
       "%",di.info_name,1,0) != size(trim(di.info_name)))) )
       dgdf_fail_ind = 1
      ENDIF
     ENDIF
     dmr_di_filter->cnt = (dmr_di_filter->cnt+ 1), stat = alterlist(dmr_di_filter->qual,dmr_di_filter
      ->cnt), dmr_di_filter->qual[dmr_di_filter->cnt].name = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgdf_fail_ind=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid name value."
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dmr_di_filter->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_INFO filter rows found.")
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_create_di_macro(dcdm_in_dir,dcdm_gg_version)
   DECLARE dcdm_fname = vc WITH protect, noconstant("")
   DECLARE dcdm_parm_loc = vc WITH protect, noconstant("")
   DECLARE dmuss_locndx = i4 WITH protect, noconstant(0)
   DECLARE dcdm_name = vc WITH protect, noconstant("")
   DECLARE dcdm_cmd = vc WITH protect, noconstant("")
   DECLARE dcdm_delim = vc WITH protect, noconstant("")
   IF (dcdm_gg_version > 11)
    SET dcdm_delim = "'"
   ELSE
    SET dcdm_delim = '"'
   ENDIF
   SET dm_err->eproc = "Create DM_INFO delivery filter macro."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dmr_di_filter->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_INFO filter rows found.")
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dmr_di_filter)
   ENDIF
   SET dcdm_parm_loc = dcdm_in_dir
   IF (dm2_find_dir(dcdm_parm_loc)=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,15,120)
    CALL text(3,2,"Enter Delivery parameter file directory location :")
    CALL accept(3,70,"P(30);C",dcdm_parm_loc
     WHERE curaccept != "")
    SET dcdm_parm_loc = trim(curaccept)
    SET message = nowindow
   ENDIF
   IF (dm2_find_dir(dcdm_parm_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Delivery parm directory entered [",dcdm_parm_loc,"] does not exist.")
    SET dm_err->eproc = "Verify delivery parm directory exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (substring(size(dcdm_parm_loc),1,dcdm_parm_loc) != "/")
    SET dcdm_parm_loc = concat(trim(dcdm_parm_loc),"/")
   ENDIF
   SET dcdm_fname = concat(trim(dcdm_parm_loc),"difilter.mac")
   SELECT INTO value(dcdm_fname)
    FROM (dummyt d  WITH d.seq = 1)
    DETAIL
     col 0,
     CALL print("MACRO #difilter"), row + 1,
     col 0,
     CALL print("BEGIN"), row + 1,
     col 0,
     CALL print("FILTER ( &"), row + 1
     FOR (dmuss_locndx = 1 TO dmr_di_filter->cnt)
       IF (dmuss_locndx=1)
        dcdm_cmd = "      ("
       ELSE
        dcdm_cmd = "  AND ("
       ENDIF
       IF (findstring("%",dmr_di_filter->qual[dmuss_locndx].name) > 0)
        dcdm_name = trim(replace(dmr_di_filter->qual[dmuss_locndx].name,"%","")), dcdm_cmd = concat(
         dcdm_cmd,"@STRNCMP(INFO_DOMAIN, ",dcdm_delim,dcdm_name,dcdm_delim,
         ", ",trim(cnvtstring(size(dcdm_name))),") <> 0) &")
       ELSE
        dcdm_name = trim(dmr_di_filter->qual[dmuss_locndx].name), dcdm_cmd = concat(dcdm_cmd,
         "@STRCMP (INFO_DOMAIN, ",dcdm_delim,dcdm_name,dcdm_delim,
         ") <> 0) &")
       ENDIF
       col 0,
       CALL print(dcdm_cmd), row + 1
     ENDFOR
     col 0,
     CALL print(")"), row + 1,
     col 0,
     CALL print("END;"), row + 1
    WITH nocounter, maxrow = 1, format = lfstream,
     noformfeed, maxcol = 2000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (validate(rdisk->qual[1].disk_name,"")=""
  AND validate(rdisk->qual[1].disk_name,"Z")="Z")
  FREE RECORD rdisk
  RECORD rdisk(
    1 disk_cnt = i4
    1 qual[*]
      2 disk_name = vc
      2 volume_label = vc
      2 vg_name = vc
      2 pp_size_mb = f8
      2 total_space_mb = f8
      2 free_space_mb = f8
      2 new_free_space_mb = f8
      2 root_ind = i2
      2 used_ind = vc
      2 data_tspace = i2
      2 index_tspace = i2
      2 datafile_dir_exists = i2
      2 mwc_flag = i2
      2 alloc_unit_b = f8
      2 block_size_b = f8
  )
  SET rdisk->disk_cnt = 0
 ENDIF
 IF (validate(pv_lv_list->qual[1].pv_name,"")=""
  AND validate(pv_lv_list->qual[1].pv_name,"Z")="Z")
  FREE RECORD pv_lv_list
  RECORD pv_lv_list(
    1 cnt = i4
    1 pv[*]
      2 pv_name = vc
      2 lv[*]
        3 lv_name = vc
  )
 ENDIF
 IF (validate(pv_mwc_list->pv[1].pv_name,"")=""
  AND validate(pv_mwc_list->pv[1].pv_name,"Z")="Z")
  FREE RECORD pv_mwc_list
  RECORD pv_mwc_list(
    1 cnt = i4
    1 pv[*]
      2 pv_name = vc
      2 mwc_flag = i2
  )
 ENDIF
 IF ((validate(autopop_screen->top_line,- (1))=- (1))
  AND (validate(autopop_screen->top_line,- (2))=- (2)))
  FREE RECORD autopop_screen
  RECORD autopop_screen(
    1 top_line = i4
    1 bottom_line = i4
    1 cur_line = i4
    1 max_scroll = i4
    1 max_value = i4
    1 disk_cnt = i4
    1 remain_space_add = f8
    1 user_bytes = f8
    1 disk[*]
      2 volume_label = vc
      2 disk_name = vc
      2 vg_name = vc
      2 disk_idx = i4
      2 lv_filename = vc
      2 free_disk_space_mb = f8
      2 pp_size_mb = f8
      2 pps_to_add = f8
      2 space_to_add = f8
      2 disk_tspace_rel_key = i4
      2 cont_size_mb = f8
      2 delete_ind = i4
      2 disk_full_ind = i2
      2 orig_disk_space_mb = f8
      2 mwc_flag = i2
      2 alloc_unit_b = f8
      2 block_size_b = f8
  )
 ENDIF
 IF ((validate(rvg->vg_cnt,- (1))=- (1))
  AND (validate(rvg->vg_cnt,- (2))=- (2)))
  FREE RECORD rvg
  RECORD rvg(
    1 vg_cnt = i2
    1 qual[*]
      2 vg_name = vc
      2 psize = i4
      2 ttl_pps = f8
      2 free_pps = f8
      2 free_mb = f8
  )
  SET rvg->vg_cnt = 0
 ENDIF
 IF (validate(dos_sys_filename,"X")="X"
  AND validate(dos_sys_filename,"Y")="Y")
  DECLARE dos_sys_filename = vc WITH public, noconstant("DM2NOTSET")
  IF ((dm2_sys_misc->cur_db_os="AXP"))
   SET dos_sys_filename = logical("sys$sysdevice")
  ENDIF
 ENDIF
 IF ((validate(dor_flex_cmd->dfc_cnt,- (1))=- (1))
  AND (validate(dor_flex_cmd->dfc_cnt,- (2))=- (2)))
  RECORD dor_flex_cmd(
    1 dfc_cnt = i4
    1 cmd[*]
      2 flex_cmd_file = vc
      2 flex_cmd = vc
      2 flex_output = vc
      2 flex_out_file = vc
      2 flex_cmd_type = vc
      2 flex_local = i2
      2 flex_rmt_user = vc
      2 flex_rmt_node = vc
  )
 ENDIF
 DECLARE dm2_find_dir(sbr_dir_name=vc) = i2
 DECLARE dm2_find_queue(sbr_que_name=vc) = i2
 DECLARE dm2_get_mnt_disk_info_axp(sbr_outfile=vc) = i2
 DECLARE convert_blocks_to_bytes(cbb_block_in=f8) = f8
 DECLARE convert_bytes(byte_value=f8,from_flag=c1,to_flag=c1) = f8 WITH public
 DECLARE dm2_get_vg_disk_info_aix(null) = i4 WITH public
 DECLARE dm2_parse_aix_vg_disk_file(sbr_dsk_fname=vc) = i4 WITH public
 DECLARE dm2_parse_hpux_disk_file(sbr_dsk_fname=vc) = i4 WITH public
 DECLARE dm2_assign_disk(agd_size_in=f8,agd_last_disk_ndx=i4) = i4
 DECLARE dm2_create_dir(sbr_new_dir=vc,sbr_new_dir_type=vc) = i2
 DECLARE dm2_get_vgs(null) = i2
 DECLARE dm2_get_novg_disk_info_aix(null) = i2
 DECLARE dm2_get_nomnt_disk_info_axp(null) = i2
 DECLARE dm2_extend_vg(dev_vg_name=vc,dev_disk_name=vc) = i2
 DECLARE dm2_make_vg(dmv_vg_name=vc,dmv_psize=i4,dmv_disk_name=vc) = i2
 DECLARE dm2_init_mount_disk(dim_disk_name=vc,dim_vol_lbl=vc) = vc
 DECLARE dm2_get_mwc_flag(dgm_disk_name=vc) = i2
 DECLARE dm2_sub_space_from_disk(dss_disk_ndx=i4,dss_file_size=f8) = i2
 DECLARE dm2_aix_remove_lv(sbr_arl_db_name=vc) = i2
 DECLARE dm2_rename_login_default(sbr_rld_mode=vc) = i2
 DECLARE dm2_delete_dir(ddd_dir=vc) = i2
 DECLARE dm2_reduce_vg(drv_vg_name=vc,drv_disk_name=vc) = i2
 DECLARE get_space_rounded(space_add_in=f8,pp_size_in=f8) = f8
 DECLARE dm2_parse_aix_vg(dpa_fname=vc,dpa_rvg_idx=i4) = i2
 DECLARE dm2_check_cluster_lic(null) = i2
 DECLARE dos_get_lv_for_pv(dglp_file=vc) = i2
 DECLARE dos_get_sys_dev(dgsd_file=vc) = i2
 DECLARE dos_get_mwc_value(dgmv_file=vc,dgmv_mode=i2) = i2
 DECLARE dor_get_diskgroup_info(null) = i2
 DECLARE dor_load_rdisk_into_rvg(dlrir_os=vc) = i2
 DECLARE dor_init_flex_cmds(null) = i2
 DECLARE dor_add_flex_cmd(dafc_local=i2,dafc_rmt_user=vc,dafc_rmt_node=vc,dafc_cmd_file=vc,dafc_cmd=
  vc,
  dafc_out_file=vc,dafc_cmd_type=vc) = i2
 DECLARE dm2_dismount_disk(ddd_vol_label=vc) = i2
 DECLARE dor_exec_flex_cmd(null) = i2
 DECLARE dm2_parse_mnt_disk_info_axp(dpmdia_outfile=vc) = i2
 DECLARE dor_flex_chmod_file(dfcf_file=vc,dfcf_ssh_str=vc) = i2
 SUBROUTINE dor_flex_chmod_file(dfcf_file,dfcf_ssh_str)
   DECLARE dfcf_str = vc WITH protect, noconstant(" ")
   DECLARE dfcf_stat = i2 WITH protect, noconstant(0)
   SET dfcf_str = concat(dfcf_ssh_str," chmod 777 ",dfcf_file," > ",trim(logical("ccluserdir")),
    "/dfcf_outfile.out 2>&1")
   SET dfcf_stat = 0
   SET dfcf_stat = dcl(dfcf_str,textlen(dfcf_str),dfcf_stat)
   IF ((dm_err->debug_flag > 0))
    CALL echo(dfcf_str)
   ENDIF
   IF (dfcf_stat != 1)
    IF (parse_errfile(concat(trim(logical("ccluserdir")),"/dfcf_outfile.out"))=0)
     RETURN(0)
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_exec_flex_cmd(null)
   DECLARE defc_stat = i2 WITH protect, noconstant(0)
   DECLARE defc_cnt = i2 WITH protect, noconstant(0)
   DECLARE defc_str = vc WITH protect, noconstant("")
   DECLARE defc_ssh_str = vc WITH protect, noconstant("")
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dor_flex_cmd)
   ENDIF
   FOR (defc_cnt = 1 TO dor_flex_cmd->dfc_cnt)
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
      SET defc_ssh_str = concat("ssh ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",dor_flex_cmd->
       cmd[defc_cnt].flex_rmt_node," ")
     ELSE
      SET defc_ssh_str = " "
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EF", "EFRO")))
      IF (dor_flex_chmod_file(dor_flex_cmd->cmd[defc_cnt].flex_cmd_file,defc_ssh_str)=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EF", "EFRO", "EFO")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFRO"))
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
        SET defc_str = concat(". ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",trim(logical(
           "ccluserdir")),"/defc_outfile.out")
       ELSE
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ENDIF
      ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EF"))
       SET defc_str = concat(". ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFO"))
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
        SET defc_str = concat("su - oracle -c ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ELSE
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ENDIF
      ENDIF
      SET defc_stat = 0
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFRO"))
       IF (parse_errfile(concat(trim(logical("ccluserdir")),"/defc_outfile.out"))=0)
        RETURN(0)
       ENDIF
       SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EC")))
      IF (findstring("update_reg",dor_flex_cmd->cmd[defc_cnt].flex_cmd,1,0) > 0)
       IF (drr_exec_update_reg(dor_flex_cmd->cmd[defc_cnt].flex_cmd)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file=""))
        SET dor_flex_cmd->cmd[defc_cnt].flex_out_file = concat(trim(logical("ccluserdir")),
         "/defc_outfile.out")
       ENDIF
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file="*:APPEND"))
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," >> ",substring(
          1,(findstring(":",dor_flex_cmd->cmd[defc_cnt].flex_out_file,1,1) - 1),dor_flex_cmd->cmd[
          defc_cnt].flex_out_file),
         " 2>&1")
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file="noout"))
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd)
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       ELSE
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",
         dor_flex_cmd->cmd[defc_cnt].flex_out_file,
         " 2>&1")
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
        IF (parse_errfile(dor_flex_cmd->cmd[defc_cnt].flex_out_file)=0)
         RETURN(0)
        ENDIF
        SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EFORO")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
       SET defc_str = concat("su - oracle -c ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ELSE
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file=""))
       SET dor_flex_cmd->cmd[defc_cnt].flex_out_file = concat(trim(logical("ccluserdir")),
        "/defc_outfile.out")
      ENDIF
      SET defc_stat = 0
      SET defc_str = concat(defc_str," "," > ",dor_flex_cmd->cmd[defc_cnt].flex_out_file," 2>&1")
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (parse_errfile(dor_flex_cmd->cmd[defc_cnt].flex_out_file)=0)
       RETURN(0)
      ENDIF
      SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EFRF")))
      SET defc_stat = 0
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file,
        " 2>&1")
      ELSE
       SET defc_str = concat(dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",dor_flex_cmd->cmd[
        defc_cnt].flex_out_file," 2>&1")
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",trim(logical("ccluserdir")),"/")
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("RCPBACK")))
      SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
       dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
       dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",trim(logical("ccluserdir")),"/")
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("ECRF")))
      SET defc_stat = 0
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",dor_flex_cmd
        ->cmd[defc_cnt].flex_out_file,
        " 2>&1")
      ELSE
       SET defc_str = concat(dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",dor_flex_cmd->cmd[defc_cnt].
        flex_out_file," 2>&1")
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("RCP")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," ",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",dor_flex_cmd->cmd[defc_cnt].flex_out_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (dor_flex_chmod_file(dor_flex_cmd->cmd[defc_cnt].flex_out_file,defc_ssh_str)=0)
        RETURN(0)
       ENDIF
      ELSE
       SET defc_str = concat("cp ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," ",dor_flex_cmd->cmd[
        defc_cnt].flex_out_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 722))
      SET defc_str = concat("cat ",trim(logical("ccluserdir")),"/defc_outfile.out")
      SET defc_stat = 0
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
     ENDIF
     SET dor_flex_cmd->cmd[defc_cnt].flex_output = trim(dor_flex_cmd->cmd[defc_cnt].flex_output,3)
   ENDFOR
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dor_flex_cmd)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_add_flex_cmd(dafc_local,dafc_rmt_user,dafc_rmt_node,dafc_cmd_file,dafc_cmd,
  dafc_out_file,dafc_cmd_type)
   SET dor_flex_cmd->dfc_cnt = (dor_flex_cmd->dfc_cnt+ 1)
   SET stat = alterlist(dor_flex_cmd->cmd,dor_flex_cmd->dfc_cnt)
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd_file = dafc_cmd_file
   IF (dafc_local=0)
    SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = concat('"',dafc_cmd,'"')
    IF (findstring("echo $\?",dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd,1,1) > 0)
     SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = replace(dor_flex_cmd->cmd[dor_flex_cmd->
      dfc_cnt].flex_cmd,"echo $?","echo \$?",0)
    ENDIF
   ELSE
    SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = dafc_cmd
   ENDIF
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_out_file = dafc_out_file
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd_type = dafc_cmd_type
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_local = dafc_local
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_rmt_user = dafc_rmt_user
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_rmt_node = dafc_rmt_node
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_init_flex_cmds(null)
   SET dor_flex_cmd->dfc_cnt = 0
   SET stat = alterlist(dor_flex_cmd->cmd,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_find_dir(sbr_dir_name)
   DECLARE dfd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str2 = vc WITH protect, noconstant(" ")
   DECLARE dfd_tmp_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dfd_err_str3 = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dfd_cmd_txt = concat("dir ",sbr_dir_name)
    SET dfd_err_str = "directory not found"
    SET dfd_err_str2 = "no files found"
    SET dfd_err_str3 = "error in device name"
   ELSE
    SET dfd_cmd_txt = concat("test -d ",sbr_dir_name,";echo $?")
    SET dfd_err_str = "0"
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   CALL dm2_push_dcl(dfd_cmd_txt)
   SET dm_err->disp_dcl_err_ind = 1
   IF ((dm_err->err_ind=1))
    SET dm_err->err_ind = 0
    SET dfd_tmp_err_ind = 1
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (findstring(dfd_err_str,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," not found.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF (findstring(dfd_err_str2,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," exists with no files in directory.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSEIF (findstring(dfd_err_str3,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory device ",sbr_dir_name," does not exist.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF (dfd_tmp_err_ind=1)
     SET dm_err->eproc = concat("Find directory  ",sbr_dir_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ELSE
    IF (cnvtint(dm_err->errtext)=0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," found.")
     IF ((dm_err->debug_flag > 1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSE
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," not found.")
     IF ((dm_err->debug_flag > 1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_find_queue(sbr_que_name)
   DECLARE dfd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dfd_cmd_txt = concat("sho queue ",sbr_que_name)
    SET dfd_err_str = "no such queue"
   ELSE
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(dfd_cmd_txt)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->errtext)
   ENDIF
   IF (findstring("idle",dm_err->errtext,1,0) > 0)
    RETURN(1)
   ELSE
    SET dm_err->eproc = concat("Make sure que ",sbr_que_name," is idle.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_sys_dev(dgsd_file)
   DECLARE dgsd_device_name = vc WITH protect, noconstant("")
   DECLARE dgsd_start = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Gather system device name"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET logical dgsd_sys_dev dgsd_file
   FREE DEFINE rtl
   DEFINE rtl "dgsd_sys_dev"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgsd_start = (findstring('"SYS$SYSDEVICE" = "',t.line)+ 19)
     IF ((dm_err->debug_flag > 1))
      CALL echo(t.line)
     ENDIF
     IF (dgsd_start > 0)
      dgsd_device_name = substring(dgsd_start,(findstring('"',t.line,(dgsd_start+ 1),1) - dgsd_start),
       t.line)
     ENDIF
     IF ((dm_err->debug_flag > 1))
      CALL echo(dgsd_device_name)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgsd_device_name="")
    SET dm_err->eproc = concat("Could not gather system device name from file:",dgsd_file)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
   ENDIF
   SET dos_sys_filename = dgsd_device_name
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_mwc_value(dgmv_file,dgmv_mode)
   DECLARE dgmv_cmd = vc WITH protect, noconstant("")
   DECLARE dgmv_stat = i2 WITH protect, noconstant(0)
   DECLARE dgmv_cnt = i2 WITH protect, noconstant(0)
   IF (dgmv_mode=1)
    SET dgmv_cmd = concat(
     ^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}END{print b}' | sed 's/^,
     "^| //g'`;for i in `lspv | egrep ",^"($a)" | awk '{print $1}'`;do lqueryvg -p /dev/$i -X | ^,
     ^echo $i `awk '{print" "$1}'` ;done >> ^,dgmv_file)
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("MWC command:",dgmv_cmd))
    ENDIF
    SET dm_err->eproc = "Gather MWC values"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dgmv_stat = dcl(dgmv_cmd,textlen(dgmv_cmd),dgmv_stat)
    IF (dgmv_stat=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("pv mwc listing file =",dgmv_file))
     ENDIF
    ELSE
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Validate that ",dgmv_file," exists")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF (findfile(dgmv_file)=0)
     SET dm_err->emsg = concat(dgmv_file," does not exist, unable to obtain MWC information")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Load MWC values"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET logical mwc_disk_info dgmv_file
   FREE DEFINE rtl
   DEFINE rtl "mwc_disk_info"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgmv_cnt = (dgmv_cnt+ 1)
     IF (mod(dgmv_cnt,10)=1)
      stat = alterlist(pv_mwc_list->pv,(dgmv_cnt+ 9))
     ENDIF
     pv_mwc_list->pv[dgmv_cnt].pv_name = substring(1,(findstring(" ",t.line) - 1),t.line),
     pv_mwc_list->pv[dgmv_cnt].mwc_flag = evaluate(cnvtint(substring((findstring(" ",t.line)+ 1),1,t
        .line)),1,0,1)
     IF ((pv_mwc_list->pv[dgmv_cnt].mwc_flag=0))
      pv_mwc_list->pv[dgmv_cnt].mwc_flag = 1
     ELSE
      pv_mwc_list->pv[dgmv_cnt].mwc_flag = 0
     ENDIF
    FOOT REPORT
     pv_mwc_list->cnt = dgmv_cnt, stat = alterlist(pv_mwc_list->pv,dgmv_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_lv_for_pv(dglp_file)
   DECLARE dglp_cmd = vc WITH protect, noconstant("")
   DECLARE dglp_rtl_file = vc WITH protect, noconstant("")
   DECLARE dglp_pv_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglp_lv_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglp_stat = i4 WITH protect, noconstant(0)
   SET dglp_rtl_file = concat("ccluserdir:",dglp_file)
   SET logical aix_disk_info dglp_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "aix_disk_info"
   SET dm_err->eproc = "Parse list of PVs and related LVs"
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     IF (findstring(":",t.line) > 0)
      dglp_pv_cnt = (dglp_pv_cnt+ 1), stat = alterlist(pv_lv_list->pv,dglp_pv_cnt), pv_lv_list->pv[
      dglp_pv_cnt].pv_name = substring(1,(findstring(":",t.line) - 1),t.line),
      dglp_lv_cnt = 0
     ELSE
      IF ( NOT (findstring("LV NAME",t.line)))
       dglp_lv_cnt = (dglp_lv_cnt+ 1), stat = alterlist(pv_lv_list->pv[dglp_pv_cnt].lv,dglp_lv_cnt),
       pv_lv_list->pv[dglp_pv_cnt].lv[dglp_lv_cnt].lv_name = substring(1,(findstring(" ",t.line) - 1),
        t.line)
      ENDIF
     ENDIF
    FOOT REPORT
     pv_lv_list->cnt = dglp_pv_cnt
    WITH nocounter, maxcol = 500
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(pv_lv_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_parse_mnt_disk_info_axp(dpmdia_outfile)
   DECLARE axp_rtl_file = vc WITH public, noconstant("")
   DECLARE disk_vg_hold = vc WITH public, noconstant("")
   DECLARE axp_count_hold = i4 WITH public, noconstant(0)
   DECLARE spot_end = i4 WITH public, noconstant(0)
   DECLARE spot = i4 WITH public, noconstant(0)
   SET axp_rtl_file = concat("ccluserdir:",dpmdia_outfile)
   SET logical axp_disk_info axp_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "axp_disk_info"
   SET dm_err->eproc = "Parse list of mounted disks"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    HEAD REPORT
     axp_count_hold = 0
    DETAIL
     axp_count_hold = (axp_count_hold+ 1), stat = alterlist(rdisk->qual,axp_count_hold), spot =
     findstring(",",t.line,1),
     disk_name_hold = substring(1,(spot - 1),t.line), rdisk->qual[axp_count_hold].disk_name =
     disk_name_hold
     IF (disk_name_hold=dos_sys_filename)
      rdisk->qual[axp_count_hold].root_ind = 1
     ELSE
      rdisk->qual[axp_count_hold].root_ind = 0
     ENDIF
     disk_vg_hold = substring((spot+ 2),(textlen(t.line) - spot),t.line), spot = findstring(",",
      disk_vg_hold), disk_vg_hold = substring(1,(spot - 1),disk_vg_hold),
     rdisk->qual[axp_count_hold].volume_label = disk_vg_hold, spot = 0, spot = findstring(
      "Free Space:",t.line,1),
     spot_end = findstring("Total Space:",t.line,1), disk_free_space_mb = substring(spot,((spot_end
       - spot) - 1),t.line), spot = 0,
     spot = findstring(":",disk_free_space_mb,1), disk_free_space_mb = substring((spot+ 2),(textlen(
       disk_free_space_mb) - spot),disk_free_space_mb), rdisk->qual[axp_count_hold].free_space_mb =
     convert_bytes(convert_blocks_to_bytes(cnvtreal(disk_free_space_mb)),"b","m"),
     rdisk->qual[axp_count_hold].new_free_space_mb = rdisk->qual[axp_count_hold].free_space_mb, spot
      = 0, disk_free_space_mb = "",
     spot = findstring("Total Space:",t.line,1), disk_free_space_mb = substring(spot,(textlen(t.line)
       - spot),t.line), spot = 0,
     spot = findstring(":",disk_free_space_mb,1), disk_free_space_mb = substring((spot+ 2),(textlen(
       disk_free_space_mb) - spot),disk_free_space_mb), rdisk->qual[axp_count_hold].total_space_mb =
     convert_bytes(convert_blocks_to_bytes(cnvtreal(disk_free_space_mb)),"b","m")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    SET message = nowindow
    CALL echorecord(rdisk)
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_mnt_disk_info_axp(sbr_outfile)
   SET dm_err->eproc = "Get list of mounted disks"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcl_str = vc WITH protect, noconstant(" ")
   SET dcl_str = concat("@cer_install:dm2_get_mnt_disk_info.com ",sbr_outfile)
   IF ( NOT (dm2_push_dcl(dcl_str)))
    RETURN(0)
   ENDIF
   IF (dm2_parse_mnt_disk_info_axp(sbr_outfile)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_vg_disk_info_aix(null)
   DECLARE dcl_str = vc WITH protect, noconstant(" ")
   DECLARE dcl_stat = i2 WITH protect, noconstant(0)
   DECLARE dcl_temp_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get list of disks in a volume group"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Get unique filename for disk list"
   IF (get_unique_file("dm2_disk_aix_info",".dat"))
    SET dcl_temp_file = dm_err->unique_fname
   ELSE
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Get list of disks in a volume group"
    SET dcl_str = concat(^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}^,
     "END{print b}' | sed 's/^| //g'`",
     ^;for i in `lspv | egrep "($a)" | awk '{print $1}'`;do lspv $i >> ^,dcl_temp_file,";done")
    SET dcl_stat = dcl(dcl_str,textlen(dcl_str),dcl_stat)
    IF (dcl_stat=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("disk_file =",dcl_temp_file))
     ENDIF
     IF ( NOT (dm2_parse_aix_vg_disk_file(dcl_temp_file)))
      RETURN(0)
     ELSE
      RETURN(1)
     ENDIF
    ELSE
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Use VGDISPLAY to get list of Volume Groups."
    SET dcl_str = concat("vgdisplay > ",dm_err->unique_fname," 2>/dev/null")
    SET dcl_stat = 0
    SET dcl_stat = dcl(dcl_str,textlen(dcl_str),dcl_stat)
    IF (dcl_stat=0)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ELSE
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("disk_file =",dcl_temp_file))
     ENDIF
    ENDIF
    IF (dm2_parse_hpux_disk_file(dcl_temp_file)=0)
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_load_rdisk_into_rvg(dlrir_os)
   DECLARE dlrir_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrir_vg_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrir_ndx = i4 WITH protect, noconstant(0)
   SET rvg->vg_cnt = 0
   SET stat = alterlist(rvg->qual,rvg->vg_cnt)
   FOR (dlrir_cnt = 1 TO rdisk->disk_cnt)
     IF ( NOT ((rdisk->qual[dlrir_cnt].vg_name IN ("rootvg", "/dev/vg00"))))
      IF (dlrir_cnt > 0
       AND locateval(dlrir_ndx,1,rvg->vg_cnt,rdisk->qual[dlrir_cnt].vg_name,rvg->qual[dlrir_ndx].
       vg_name) > 0)
       SET rvg->qual[dlrir_ndx].ttl_pps = (rvg->qual[dlrir_ndx].ttl_pps+ (rdisk->qual[dlrir_ndx].
       total_space_mb/ rdisk->qual[dlrir_ndx].pp_size_mb))
       SET rvg->qual[dlrir_ndx].free_pps = (rvg->qual[dlrir_ndx].free_pps+ (rdisk->qual[dlrir_cnt].
       free_space_mb/ rdisk->qual[dlrir_cnt].pp_size_mb))
       SET rvg->qual[dlrir_ndx].free_mb = (rvg->qual[dlrir_ndx].free_mb+ rdisk->qual[dlrir_cnt].
       free_space_mb)
      ELSE
       SET rvg->vg_cnt = (rvg->vg_cnt+ 1)
       SET stat = alterlist(rvg->qual,rvg->vg_cnt)
       IF (dlrir_os="HPX")
        SET rvg->qual[rvg->vg_cnt].vg_name = substring(6,(textlen(rdisk->qual[dlrir_cnt].vg_name) - 5
         ),rdisk->qual[dlrir_cnt].vg_name)
       ELSE
        SET rvg->qual[rvg->vg_cnt].vg_name = rdisk->qual[dlrir_cnt].vg_name
       ENDIF
       SET rvg->qual[rvg->vg_cnt].psize = rdisk->qual[dlrir_cnt].pp_size_mb
       SET rvg->qual[rvg->vg_cnt].ttl_pps = (rdisk->qual[dlrir_cnt].total_space_mb/ rdisk->qual[
       dlrir_cnt].pp_size_mb)
       SET rvg->qual[rvg->vg_cnt].free_pps = (rdisk->qual[dlrir_cnt].free_space_mb/ rdisk->qual[
       dlrir_cnt].pp_size_mb)
       SET rvg->qual[rvg->vg_cnt].free_mb = rdisk->qual[dlrir_cnt].free_space_mb
      ENDIF
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(rdisk)
    CALL echorecord(rvg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_get_diskgroup_info(null)
   SET stat = alterlist(rdisk->qual,0)
   SET rdisk->disk_cnt = 0
   SET dm_err->eproc = "Loading ASM diskgroups."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$asm_diskgroup v
    WHERE v.state IN ("CONNECTED", "MOUNTED")
    DETAIL
     rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
     qual[rdisk->disk_cnt].disk_name = v.name,
     rdisk->qual[rdisk->disk_cnt].total_space_mb = v.total_mb, rdisk->qual[rdisk->disk_cnt].
     free_space_mb = v.free_mb, rdisk->qual[rdisk->disk_cnt].new_free_space_mb = v.free_mb,
     rdisk->qual[rdisk->disk_cnt].alloc_unit_b = v.allocation_unit_size, rdisk->qual[rdisk->disk_cnt]
     .block_size_b = v.block_size
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(rdisk)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE convert_blocks_to_bytes(cbb_block_in)
   DECLARE cbb_bytes_per_block = f8 WITH public, noconstant(0.0)
   DECLARE cbb_return = f8 WITH public, noconstant(0.0)
   SET cbb_bytes_per_block = 512.0
   SET cbb_return = (cbb_block_in * cbb_bytes_per_block)
   RETURN(cbb_return)
 END ;Subroutine
 SUBROUTINE convert_bytes(byte_value,from_flag,to_flag)
   DECLARE mbyte_factor = f8 WITH constant(1048576.0)
   DECLARE kbyte_factor = f8 WITH constant(1024.0)
   DECLARE temp_byte_value = f8 WITH noconstant(0.0)
   CASE (from_flag)
    OF "m":
     SET byte_value = (byte_value * kbyte_factor)
    OF "k":
     SET byte_value = byte_value
    OF "b":
     SET byte_value = (byte_value/ kbyte_factor)
   ENDCASE
   CASE (to_flag)
    OF "b":
     SET temp_byte_value = byte_value
     SET temp_byte_value = (temp_byte_value * kbyte_factor)
    OF "m":
     SET temp_byte_value = byte_value
     SET temp_byte_value = (byte_value/ kbyte_factor)
    OF "k":
     SET temp_byte_value = byte_value
   ENDCASE
   SET temp_byte_value = dm2ceil(temp_byte_value)
   RETURN(temp_byte_value)
 END ;Subroutine
 SUBROUTINE dm2_assign_disk(agd_size_in,agd_last_disk_ndx)
   DECLARE agd_disk_ndx_ret = i4 WITH noconstant(0)
   DECLARE agd_disk_ndx = i4 WITH noconstant(0)
   DECLARE agd_disk_cnt = i4 WITH noconstant(0)
   DECLARE agd_size_check = f8 WITH noconstant(0.0)
   DECLARE agd_start_pt = i4 WITH noconstant(0)
   DECLARE agd_end_pt = i4 WITH noconstant(0)
   DECLARE agd_start_over = i4 WITH noconstant(0)
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = build("Assign file to disk: size_in=",agd_size_in,"; last_disk_ndx=",
     agd_last_disk_ndx)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (agd_last_disk_ndx=size(autopop_screen->disk,5))
    SET agd_start_pt = 1
   ELSE
    SET agd_start_pt = (agd_last_disk_ndx+ 1)
   ENDIF
   SET agd_end_pt = size(autopop_screen->disk,5)
   SET agd_disk_cnt = agd_start_pt
   WHILE (agd_start_over < 2
    AND agd_disk_ndx_ret=0)
     IF ((dm_err->debug_flag > 3))
      CALL echo("*************************BEGINWHILE********************")
      CALL echo(agd_disk_cnt)
      CALL echo(agd_end_pt)
      CALL echo(agd_start_over)
      CALL echo(agd_size_check)
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(autopop_screen->disk[agd_disk_cnt].disk_name)
      CALL echo(agd_disk_ndx_ret)
      CALL echo("*************************BEGINWHILEx********************")
     ENDIF
     SET agd_size_check = 0.0
     IF ((dir_storage_misc->tgt_storage_type IN ("ASM", "AXP")))
      SET agd_size_check = agd_size_in
     ELSE
      SET agd_size_check = get_space_rounded(cnvtreal(agd_size_in),autopop_screen->disk[agd_disk_cnt]
       .pp_size_mb)
     ENDIF
     IF ((dm_err->debug_flag > 3))
      CALL echo("Autopop Values")
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(agd_size_check)
     ENDIF
     IF ((autopop_screen->disk[agd_disk_cnt].free_disk_space_mb > agd_size_check))
      SET agd_disk_ndx_ret = agd_disk_cnt
      IF ((dm_err->debug_flag > 3))
       CALL echo(agd_disk_ndx_ret)
      ENDIF
     ENDIF
     IF (agd_disk_cnt=agd_end_pt
      AND agd_disk_ndx_ret=0)
      IF (agd_start_over=0)
       IF (agd_start_pt != 1)
        SET agd_disk_cnt = 1
        SET agd_end_pt = agd_last_disk_ndx
        SET agd_start_over = (agd_start_over+ 1)
       ELSE
        SET agd_start_over = 2
       ENDIF
      ELSE
       SET agd_start_over = 2
      ENDIF
     ELSE
      IF (((agd_disk_cnt+ 1) > size(autopop_screen->disk,5)))
       SET agd_disk_cnt = size(autopop_screen->disk,5)
      ELSE
       SET agd_disk_cnt = (agd_disk_cnt+ 1)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 3))
      CALL echo("*************************ENDWHILE********************")
      CALL echo(agd_disk_cnt)
      CALL echo(agd_end_pt)
      CALL echo(agd_start_over)
      CALL echo(agd_size_check)
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(autopop_screen->disk[agd_disk_cnt].disk_name)
      CALL echo(agd_disk_ndx_ret)
      CALL echo("*************************ENDWHILEx********************")
     ENDIF
   ENDWHILE
   RETURN(agd_disk_ndx_ret)
 END ;Subroutine
 SUBROUTINE dm2_sub_space_from_disk(dss_disk_ndx,dss_file_size)
   SET dm_err->eproc =
   "Substract dfile size from selected disk and reset autopop_screen disk free space."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dir_storage_misc->tgt_storage_type="RAW"))
    SET dss_file_size = get_space_rounded(cnvtreal(dss_file_size),autopop_screen->disk[dss_disk_ndx].
     pp_size_mb)
   ENDIF
   SET autopop_screen->disk[dss_disk_ndx].free_disk_space_mb = (autopop_screen->disk[dss_disk_ndx].
   free_disk_space_mb - dss_file_size)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_space_rounded(space_add_in,pp_size_in)
   DECLARE space_add_out = f8 WITH public, noconstant(0.0)
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = build("In get_space_rounded subroutine")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET space_add_out = 0.0
   IF (mod(cnvtint(space_add_in),cnvtint(pp_size_in)) > 0)
    SET space_add_out = (space_add_in+ (cnvtint(pp_size_in) - mod(cnvtint(space_add_in),cnvtint(
      pp_size_in))))
   ELSE
    SET space_add_out = space_add_in
   ENDIF
   RETURN(space_add_out)
 END ;Subroutine
 SUBROUTINE dm2_parse_aix_vg_disk_file(sbr_dsk_fname)
   DECLARE disk_str = vc WITH public
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 attr4 = vc
     1 attr4sep = vc
     1 attr5 = vc
     1 attr5sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
       2 attr4val = vc
       2 attr5val = vc
   ) WITH public
   SET dm2parse->attr1 = "PHYSICAL VOLUME:"
   SET dm2parse->attr1sep = " "
   SET dm2parse->attr2 = "VOLUME GROUP:"
   SET dm2parse->attr2sep = " "
   SET dm2parse->attr3 = "PP SIZE:"
   SET dm2parse->attr3sep = " "
   SET dm2parse->attr4 = "TOTAL PPs:"
   SET dm2parse->attr4sep = " "
   SET dm2parse->attr5 = "FREE PPs:"
   SET dm2parse->attr5sep = " "
   SET dm_err->eproc = build("Parsing list of aix disks in volume groups")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2parse_output(5,sbr_dsk_fname,"H"))
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(dm2parse)
    ENDIF
    SET stat = alterlist(rdisk->qual,size(dm2parse->qual,5))
    FOR (ts_cnt_var = 1 TO size(dm2parse->qual,5))
      SET end_pos = findstring(" ",dm2parse->qual[ts_cnt_var].attr1val)
      IF (end_pos > 1)
       SET rdisk->qual[ts_cnt_var].disk_name = substring(1,(end_pos - 1),dm2parse->qual[ts_cnt_var].
        attr1val)
       SET end_pos = 0
      ENDIF
      IF (trim(dm2parse->qual[ts_cnt_var].attr2val,3) > " ")
       SET rdisk->qual[ts_cnt_var].vg_name = trim(dm2parse->qual[ts_cnt_var].attr2val,3)
       IF (cnvtupper(rdisk->qual[ts_cnt_var].vg_name)="ROOTVG")
        SET rdisk->qual[ts_cnt_var].root_ind = 1
       ELSE
        SET rdisk->qual[ts_cnt_var].root_ind = 0
       ENDIF
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[ts_cnt_var].attr3val)
      IF (end_pos > 1)
       SET rdisk->qual[ts_cnt_var].pp_size_mb = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[
         ts_cnt_var].attr3val))
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[ts_cnt_var].attr4val)
      SET end_pos = findstring("m",dm2parse->qual[ts_cnt_var].attr4val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rdisk->qual[ts_cnt_var].total_space_mb = cnvtreal(substring((start_pos+ 1),((end_pos -
         start_pos) - 2),dm2parse->qual[ts_cnt_var].attr4val))
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[ts_cnt_var].attr5val)
      SET end_pos = findstring("m",dm2parse->qual[ts_cnt_var].attr5val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rdisk->qual[ts_cnt_var].free_space_mb = cnvtreal(substring((start_pos+ 1),((end_pos -
         start_pos) - 2),dm2parse->qual[ts_cnt_var].attr5val))
       SET rdisk->qual[ts_cnt_var].new_free_space_mb = rdisk->qual[ts_cnt_var].free_space_mb
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   IF (size(rdisk->qual,5) > 0)
    SET rdisk->disk_cnt = size(rdisk->qual,5)
    SET rdisk_filled = "Y"
    SET dm_err->eproc = build("Disk file parsed successfully")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ELSE
    CALL clear(23,1,130)
    SET dm_err->eproc = build("Parsing disk file.  RDISK not filled.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,1)
    CALL text(23,2,"Unable to load system disk information - exiting application.")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_parse_hpux_disk_file(sbr_dsk_fname)
   DECLARE disk_str = vc WITH public
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 attr4 = vc
     1 attr4sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
       2 attr4val = vc
   )
   SET dm2parse->attr1 = "VG Name"
   SET dm2parse->attr1sep = " "
   SET dm2parse->attr2 = "PE Size (Mbytes)"
   SET dm2parse->attr2sep = " "
   SET dm2parse->attr3 = "Total PE"
   SET dm2parse->attr3sep = " "
   SET dm2parse->attr4 = "Free PE"
   SET dm2parse->attr4sep = " "
   IF (dm2parse_output(4,sbr_dsk_fname,"V"))
    SET stat = alterlist(rdisk->qual,size(dm2parse->qual,5))
    FOR (ts_cnt_var = 1 TO size(dm2parse->qual,5))
      SET rdisk->qual[ts_cnt_var].disk_name = dm2parse->qual[ts_cnt_var].attr1val
      SET rdisk->qual[ts_cnt_var].vg_name = rdisk->qual[ts_cnt_var].disk_name
      IF (cnvtupper(rdisk->qual[ts_cnt_var].disk_name)="/DEV/VG00")
       SET rdisk->qual[ts_cnt_var].root_ind = 1
      ELSE
       SET rdisk->qual[ts_cnt_var].root_ind = 0
      ENDIF
      SET rdisk->qual[ts_cnt_var].pp_size_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr2val)
      SET rdisk->qual[ts_cnt_var].total_space_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr3val)
      SET rdisk->qual[ts_cnt_var].free_space_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr4val)
      SET rdisk->qual[ts_cnt_var].new_free_space_mb = rdisk->qual[ts_cnt_var].free_space_mb
      SET rdisk->qual[ts_cnt_var].total_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->qual[
      ts_cnt_var].total_space_mb)
      SET rdisk->qual[ts_cnt_var].free_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->qual[
      ts_cnt_var].free_space_mb)
      SET rdisk->qual[ts_cnt_var].new_free_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->
      qual[ts_cnt_var].new_free_space_mb)
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   IF (size(rdisk->qual,5) > 0)
    SET rdisk->disk_cnt = size(rdisk->qual,5)
    SET rdisk_filled = "Y"
    SET dm_err->eproc = build("Disk file parsed successfully")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ELSE
    CALL clear(23,1,130)
    SET dm_err->eproc = build("Parsing disk file.  RDISK not filled.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,1)
    CALL text(23,2,"Unable to load system disk information - exiting application.")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_create_dir(sbr_new_dir,sbr_new_dir_type)
   DECLARE dcd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dcd_stat = i2 WITH protect, noconstant(0)
   DECLARE dcd_strip_txt1 = vc WITH protect, noconstant("")
   DECLARE dcd_strip_txt2 = vc WITH protect, noconstant("")
   DECLARE dcd_num_hold = i2 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dcd_cmd_txt = concat("create/dir ",sbr_new_dir)
   ELSE
    SET dcd_cmd_txt = concat("mkdir ",sbr_new_dir)
   ENDIF
   CALL dm2_push_dcl(dcd_cmd_txt)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (sbr_new_dir_type="DB")
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dcd_num_hold = findstring(".",sbr_new_dir,1,1)
     SET dcd_strip_txt1 = substring(1,(dcd_num_hold - 1),sbr_new_dir)
     SET dcd_strip_txt2 = substring((dcd_num_hold+ 1),((findstring("]",sbr_new_dir,1,1) -
      dcd_num_hold) - 1),sbr_new_dir)
     SET dcd_cmd_txt = concat("set file/prot=(s:rwed,o:rwed,g:rwed,w:rwe) ",dcd_strip_txt1,"]",
      dcd_strip_txt2,".dir")
     CALL dm2_push_dcl(dcd_cmd_txt)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_delete_dir(ddd_dir)
   DECLARE ddd_cmd_txt = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET ddd_cmd_txt = concat("del ",trim(ddd_dir),";")
   ENDIF
   IF (dm2_push_dcl(ddd_cmd_txt)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_novg_disk_info_aix(null)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = "Get list of disks not in volume group and store them in rDisk."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgn_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgn_drive = vc WITH protect, noconstant(" ")
   SET dgn_cmd = "lspv | grep vpath"
   IF (dm2_push_dcl(dgn_cmd)=0)
    IF ((dm_err->err_ind=1))
     IF ((dm_err->emsg > " "))
      RETURN(0)
     ELSE
      SET dm_err->eproc = "Message reported when getting vpath is okay - process continuing"
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ELSE
    SET dgn_drive = "vpath"
   ENDIF
   IF (dgn_drive != "vpath")
    SET dgn_cmd = "lspv | grep hdisk"
    IF (dm2_push_dcl(dgn_cmd)=0)
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg > " "))
       RETURN(0)
      ELSE
       SET dm_err->eproc = "Message reported when getting hdisk is okay - process continuing"
       CALL disp_msg(" ",dm_err->logfile,0)
       SET dm_err->err_ind = 0
      ENDIF
     ENDIF
    ELSE
     SET dgn_drive = "hdisk"
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dgn_drive =",dgn_drive))
   ENDIF
   IF (dgn_drive=" ")
    SET message = nowidnow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Get list of disks not in volume group and store them in rDisk."
    SET dm_err->emsg =
    "Cerner currently recognizes only VPATH and HDISK disk names.  Unable to find a recognized storage disk name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgn_drive="hdisk")
    SET dgn_cmd = "lspv | grep hdisk | grep None"
   ELSE
    SET dgn_cmd = "lspv | grep vpath | grep None"
   ENDIF
   IF (dm2_push_dcl(dgn_cmd)=0)
    IF ((dm_err->err_ind=1))
     IF ((dm_err->emsg > " "))
      RETURN(0)
     ELSE
      SET dm_err->eproc = "Message reported when getting list of disks is okay - process continuing"
      CALL disp_msg("",dm_err->logfile,0)
      SET dm_err->err_ind = 0
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     end_pos = 0
    DETAIL
     end_pos = 0, end_pos = findstring(" ",r.line)
     IF (end_pos > 0)
      rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
      qual[rdisk->disk_cnt].disk_name = substring(1,(end_pos - 1),r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Get list of disks not in volume group.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_vgs(null)
   SET dm_err->eproc = "Get list of volume groups."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgv_cmd = vc WITH protect, noconstant(" ")
   SET rvg->vg_cnt = 0
   SET stat = alterlist(rvg->qual,0)
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dgv_cmd = "lsvg -o"
   ELSE
    SET dgv_cmd = 'vgdisplay|grep "VG Name"|cut -d/ -f3'
   ENDIF
   IF (dm2_push_dcl(dgv_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl logical("file_loc")
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     IF (trim(r.line) != "rootvg")
      rvg->vg_cnt = (rvg->vg_cnt+ 1), stat = alterlist(rvg->qual,rvg->vg_cnt), rvg->qual[rvg->vg_cnt]
      .vg_name = trim(r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Get list of volume groups.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dgv_i = 1 TO rvg->vg_cnt)
     IF ((dm2_sys_misc->cur_os="AIX"))
      SET dgv_cmd = concat("lsvg ",trim(rvg->qual[dgv_i].vg_name))
     ELSE
      SET dgv_cmd = concat("vgdisplay ",trim(rvg->qual[dgv_i].vg_name))
     ENDIF
     IF (dm2_push_dcl(dgv_cmd)=0)
      RETURN(0)
     ENDIF
     IF (dm2_parse_aix_vg(dm_err->errfile,dgv_i)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_parse_aix_vg(dpa_fname,dpa_rvg_idx)
   SET dm_err->eproc = build("Parsing volume group's infomation")
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
   ) WITH public
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dm2parse->attr1 = "PP SIZE:"
    SET dm2parse->attr1sep = " "
    SET dm2parse->attr2 = "TOTAL PPs:"
    SET dm2parse->attr2sep = " "
    SET dm2parse->attr3 = "FREE PPs:"
    SET dm2parse->attr3sep = " "
   ELSE
    SET dm2parse->attr1 = "PE Size (Mbytes)"
    SET dm2parse->attr1sep = " "
    SET dm2parse->attr2 = "Total PE"
    SET dm2parse->attr2sep = " "
    SET dm2parse->attr3 = "Free PE"
    SET dm2parse->attr3sep = " "
   ENDIF
   IF (dm2parse_output(3,dpa_fname,"H"))
    IF (size(dm2parse->qual,5)=1)
     SET dpa_i = 1
     IF ((dm2_sys_misc->cur_os="AIX"))
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr1val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].psize = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i].
         attr1val))
       SET end_pos = 0
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr2val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].ttl_pps = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i].
         attr2val))
       SET end_pos = 0
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr3val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].free_pps = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i]
         .attr3val))
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[dpa_i].attr3val)
      SET end_pos = findstring("m",dm2parse->qual[dpa_i].attr3val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rvg->qual[dpa_rvg_idx].free_mb = cnvtreal(substring((start_pos+ 1),((end_pos - start_pos)
          - 2),dm2parse->qual[dpa_i].attr3val))
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
     ELSE
      SET rvg->qual[dpa_rvg_idx].psize = cnvtreal(dm2parse->qual[dpa_i].attr1val)
      SET rvg->qual[dpa_rvg_idx].ttl_pps = cnvtreal(dm2parse->qual[dpa_i].attr2val)
      SET rvg->qual[dpa_rvg_idx].free_pps = cnvtreal(dm2parse->qual[dpa_i].attr3val)
      SET rvg->qual[dpa_rvg_idx].free_mb = (rvg->qual[dpa_rvg_idx].free_pps * rvg->qual[dpa_rvg_idx].
      psize)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(
      "Parse VG information failed.  Multiple lines of information found for VG ",rvg->qual[
      dpa_rvg_idx].vg_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_nomnt_disk_info_axp(null)
   SET dm_err->eproc = "Get list of not mounted disks"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgn_dcl_str = vc WITH protect, noconstant(" ")
   DECLARE dgn_rtl_file = vc WITH protect, noconstant("")
   DECLARE dgn_spot = i4 WITH protect, noconstant(0)
   FREE RECORD dgn_disks
   RECORD dgn_disks(
     1 disk_cnt = i4
     1 disk[*]
       2 disk_name = vc
       2 remote_ind = i2
   )
   SET dgn_dcl_str = "@cer_install:dm2_get_nomnt_disk_info.com"
   IF ( NOT (dm2_push_dcl(dgn_dcl_str)))
    RETURN(0)
   ENDIF
   SET dgn_rtl_file = "ccluserdir:dm2_disk_list.tmp"
   SET logical axp_disk_info dgn_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "axp_disk_info"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgn_disks->disk_cnt = (dgn_disks->disk_cnt+ 1), stat = alterlist(dgn_disks->disk,dgn_disks->
      disk_cnt), dgn_spot = 0,
     dgn_spot = findstring(" ",t.line,1)
     IF (dgn_spot > 0)
      dgn_disks->disk[dgn_disks->disk_cnt].disk_name = substring(1,(dgn_spot - 1),t.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dgn_i = 1 TO dgn_disks->disk_cnt)
     SET dgn_dcl_str = concat("sho device ",dgn_disks->disk[dgn_i].disk_name," /out=disk_info.tmp")
     IF ( NOT (dm2_push_dcl(dgn_dcl_str)))
      RETURN(0)
     ENDIF
     SET dgn_rtl_file = "ccluserdir:disk_info.tmp"
     SET logical axp_disk_info dgn_rtl_file
     FREE DEFINE rtl
     DEFINE rtl "axp_disk_info"
     SELECT INTO "nl:"
      t.line
      FROM rtlt t
      WHERE t.line > " "
      DETAIL
       dgn_spot = 0, dgn_spot = findstring("REMOTE MOUNT",cnvtupper(t.line),1)
       IF (dgn_spot > 0)
        dgn_disks->disk[dgn_i].remote_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("filter out disks that are remote mount") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   SET rdisk->disk_cnt = size(rdisk->qual,5)
   SELECT INTO "nl:"
    dgn_disks->disk[d.seq].disk_name
    FROM (dummyt d  WITH seq = value(dgn_disks->disk_cnt))
    WHERE (dgn_disks->disk[d.seq].remote_ind=0)
    DETAIL
     rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
     qual[rdisk->disk_cnt].disk_name = dgn_disks->disk[d.seq].disk_name
    WITH nocounter
   ;end select
   IF (check_error("Populate rDisk with not mounted disks") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dgn_disks)
    CALL echorecord(rdisk)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_make_vg(dmv_vg_name,dmv_psize,dmv_disk_name)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = concat("Create new volume group ",dmv_vg_name," with disks ",dmv_disk_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dmv_cmd = vc WITH protect, noconstant(" ")
   IF (substring(1,1,dmv_disk_name)="v")
    SET dmv_cmd = "mkvg4vp"
   ELSEIF (substring(1,1,dmv_disk_name)="h")
    SET dmv_cmd = "mkvg"
   ENDIF
   SET dmv_cmd = concat(dmv_cmd," -B -f -y ",dmv_vg_name," -s ",cnvtstring(dmv_psize),
    " ",dmv_disk_name)
   IF (dm2_push_dcl(dmv_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_extend_vg(dev_vg_name,dev_disk_name)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = concat("Extend existing volume group ",dev_vg_name," with disk ",dev_disk_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dev_cmd = vc WITH protect, noconstant(" ")
   IF (substring(1,1,dev_disk_name)="v")
    SET dev_cmd = "extendvg4vp"
   ELSEIF (substring(1,1,dev_disk_name)="h")
    SET dev_cmd = "extendvg"
   ENDIF
   SET dev_cmd = concat(dev_cmd," -f ",dev_vg_name," ",dev_disk_name)
   IF (dm2_push_dcl(dev_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_reduce_vg(drv_vg_name,drv_disk_name)
   SET dm_err->eproc = concat("Reduce existing volume group ",drv_vg_name," with disk ",drv_disk_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE drv_del_vg = i2 WITH protect, noconstant(0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,dm_err->eproc)
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   DECLARE drv_cmd = vc WITH protect, noconstant(" ")
   SET drv_cmd = concat("reducevg ",drv_vg_name," ",drv_disk_name)
   IF (dm2_push_dcl(drv_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ( NOT (drv_del_vg))
      drv_del_vg = findstring("ldeletepv",r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drv_del_vg)
    IF ((dm_err->debug_flag > 0))
     SET message = nowindow
     CALL echo(concat("vg ",drv_vg_name," was deleted."))
     SET message = window
    ENDIF
    SET dpf_existing_vg_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_init_mount_disk(dim_disk_name,dim_vol_lbl)
   SET dm_err->eproc = concat("Mount disk ",trim(dim_disk_name)," on vol_lable ",dim_vol_lbl)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dimd_cmd = vc WITH protect, noconstant(" ")
   DECLARE dimd_fnd = i2 WITH protect, noconstant(0)
   IF ((dm2_create_dom->dbtype != "ADMIN"))
    WHILE (dim_vol_lbl="dm2_not_set")
      SET width = 132
      SET message = window
      CALL clear(1,1)
      CALL text(2,1,concat("Please enter volume label to mount disk ",dim_disk_name,":"))
      CALL accept(2,60,"P(20);cu")
      SET dim_vol_lbl = curaccept
      SET dimd_fnd = 0
      SET dimd_fnd = locateval(dimd_fnd,1,size(rdisk->qual,5),dim_vol_lbl,rdisk->qual[dimd_fnd].
       volume_label)
      IF (dimd_fnd)
       CALL text(4,1,concat("The volume lable name ",dim_vol_lbl,
         " is used.  Please enter a different name."))
       CALL text(6,1,"Would you like to (C)ontinue or (Q)uit?")
       CALL accept(6,60,"P;CU","C"
        WHERE curaccept IN ("C", "Q"))
       IF (curaccept="Q")
        SET dm_err->emsg = "User choose to quit the program."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN("ERROR")
       ENDIF
       SET dim_vol_lbl = "dm2_not_set"
      ENDIF
      SET message = nowindow
    ENDWHILE
   ELSE
    SET dimd_fnd = 1
    WHILE (dimd_fnd)
      SET dimd_fnd = 0
      SET dimd_fnd = locateval(dimd_fnd,1,size(rdisk->qual,5),dim_vol_lbl,rdisk->qual[dimd_fnd].
       volume_label)
      IF (dimd_fnd)
       SET dim_vol_lbl = build("ADMIN",dpf_admin_lbl_cnt)
       SET dpf_admin_lbl_cnt = (dpf_admin_lbl_cnt+ 1)
      ENDIF
    ENDWHILE
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,concat("Initialize and Mount disk ",trim(dim_disk_name)," on vol_lable ",dim_vol_lbl
     ))
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET message = nowindow
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("ERROR")
   ENDIF
   SET message = nowindow
   SET dimd_cmd = concat("$init/head=65536/clus=16/own=[500,0]/nohigh ",trim(dim_disk_name)," ",
    dim_vol_lbl)
   IF (dm2_push_dcl(dimd_cmd)=0)
    RETURN("ERROR")
   ENDIF
   IF (dm2_check_cluster_lic(null))
    SET dimd_cmd = concat("$mount/clus/win=28/noassist ",trim(dim_disk_name)," ",dim_vol_lbl," ",
     dim_vol_lbl)
   ELSE
    IF ((dm_err->err_ind=0))
     SET dimd_cmd = concat("$mount/sys/win=28/noassist ",trim(dim_disk_name)," ",dim_vol_lbl," ",
      dim_vol_lbl)
    ELSE
     RETURN("ERROR")
    ENDIF
   ENDIF
   IF (dm2_push_dcl(dimd_cmd)=0)
    RETURN("ERROR")
   ENDIF
   RETURN(dim_vol_lbl)
 END ;Subroutine
 SUBROUTINE dm2_check_cluster_lic(null)
   SET dm_err->eproc = "Checking if vmscluster license is loaded on the system."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcc_cmd = vc WITH protect, noconstant(" ")
   DECLARE dcc_str = vc WITH protect, noconstant(" ")
   DECLARE dcc_find = i2 WITH protect, noconstant(0)
   SET dcc_cmd = "$show license vmscluster"
   SET dcc_str = "%SHOW-I-NOLICMATCH, no licenses match search criteria"
   IF (dm2_push_dcl(dcc_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     dcc_find = 0
    DETAIL
     IF (dcc_find=0)
      dcc_find = findstring(dcc_str,r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Checking if vmscluster license is loaded on the system.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcc_find > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_dismount_disk(ddd_vol_label)
   SET dm_err->eproc = concat("Dismount disk ",ddd_vol_label)
   CALL disp_msg("",dm_err->logfile,0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,dm_err->eproc)
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   DECLARE ddd_cmd = vc WITH protect, noconstant(" ")
   SET ddd_cmd = concat("dismount ",ddd_vol_label)
   IF (dm2_push_dcl(ddd_cmd)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_mwc_flag(dgm_disk_name)
   SET dm_err->eproc = concat("Get mirror-write consistency for disk ",trim(dgm_disk_name))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   DECLARE dgm_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgm_str = vc WITH protect, noconstant(" ")
   SET dgm_cmd = concat("lqueryvg -p /dev/",trim(dgm_disk_name)," -X")
   IF (dm2_push_dcl(dgm_cmd)=0)
    RETURN("e")
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN("e")
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     end_pos = 0
    DETAIL
     end_pos = findstring(" ",r.line)
     IF (end_pos > 0)
      dgm_str = substring(1,(end_pos - 1),r.line)
      IF ((dm_err->debug_flag > 0))
       CALL echo(dgm_str)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Get mirror-write consistency for disk ",trim(dgm_disk_name))) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("e")
   ENDIF
   IF (dgm_str="0")
    RETURN("y")
   ELSE
    RETURN("n")
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_aix_remove_lv(sbr_arl_db_name)
   DECLARE sbr_arl_outfile = vc WITH noconstant("dm2_not_set")
   DECLARE sbr_arl_rmlv_str = vc WITH noconstant("dm2_not_set")
   SET dm_err->eproc = "Removing raw logical volumes associated with the database."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (get_unique_file("dm2_rmlv_cmd",".out")=0)
    RETURN(0)
   ENDIF
   SET sbr_arl_outfile = dm_err->unique_fname
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET sbr_arl_rmlv_str = concat("cd /dev; ls ",char(42),cnvtlower(sbr_arl_db_name),char(42),
     " | while read a; do if [ -b $a ]; then rmlv -f $a >> ",
     sbr_arl_outfile,"; fi; done 2>&1")
   ELSE
    SET sbr_arl_rmlv_str = concat(
     "vgdisplay|grep 'VG Name'|cut -d/ -f3 |while read a; do ls /dev/$a/",char(42),cnvtlower(
      sbr_arl_db_name),char(42)," | while read z; do if [ -b $z ]; then lvremove -f $z >> ",
     sbr_arl_outfile,"; fi; done; done 2>&1")
   ENDIF
   IF (dm2_push_dcl(sbr_arl_rmlv_str)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rename_login_default(sbr_rld_mode)
   DECLARE sbr_rld_backup = vc WITH constant("BACKUP")
   DECLARE sbr_rld_restore = vc WITH constant("RESTORE")
   DECLARE sbr_rld_bkup_name = vc WITH public, constant("login_save.ccl")
   DECLARE sbr_rld_real_name = vc WITH public, constant("login_default.ccl")
   DECLARE sbr_rld_cmd_str = vc WITH public, noconstant("dm2_not_set")
   DECLARE sbr_rld_ccludir = vc WITH public, noconstant("dm2_not_set")
   CASE (cnvtupper(sbr_rld_mode))
    OF sbr_rld_backup:
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (findfile(concat("CCLUSERDIR:",sbr_rld_real_name))=0)
       SET dm_err->eproc = "No login_default.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("rename CCLUSERDIR:",sbr_rld_real_name," CCLUSERDIR:",
       sbr_rld_bkup_name)
     ELSE
      IF (findfile(concat("$CCLUSERDIR/",sbr_rld_real_name))=0)
       SET dm_err->eproc = "No login_default.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("mv -f $CCLUSERDIR/",sbr_rld_real_name," $CCLUSERDIR/",
       sbr_rld_bkup_name)
     ENDIF
    OF sbr_rld_restore:
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (findfile(concat("CCLUSERDIR:",sbr_rld_bkup_name))=0)
       SET dm_err->eproc = "No login_save.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("rename CCLUSERDIR:",sbr_rld_bkup_name," CCLUSERDIR:",
       sbr_rld_real_name)
     ELSE
      IF (findfile(concat("$CCLUSERDIR/",sbr_rld_bkup_name))=0)
       SET dm_err->eproc = "No login_save.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("mv -f $CCLUSERDIR/",sbr_rld_bkup_name," $CCLUSERDIR/",
       sbr_rld_real_name)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "DM2_RENAME_LOGIN_DEFAULT: validating mode."
     SET dm_err->emsg = concat("Invalid mode of operation: <",sbr_rld_mode,">")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
   ENDCASE
   IF (dm2_push_dcl(sbr_rld_cmd_str)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
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
 DECLARE dm2_get_remote_dbase_name(dgrdn_db_link=vc,dgrdn_name_out=vc(ref)) = i2
 SUBROUTINE dm2_get_remote_dbase_name(dgrdn_db_link,dgrdn_name_out)
   IF (dm2_get_remote_rdbms_version(dgrdn_db_link)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_remote_rdbms_version->level1 >= 12))
    SET dm_err->eproc = concat("Retrieving remote database name for PDB using link ",dgrdn_db_link)
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (value(concat("V$PDBS@",dgrdn_db_link)) v)
     DETAIL
      dgrdn_name_out = v.name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Retrieving database name using link ",dgrdn_db_link)
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (value(concat("V$DATABASE@",dgrdn_db_link)) v)
     DETAIL
      dgrdn_name_out = v.name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("dgrdn_name_out =",dgrdn_name_out))
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dus_create_func_prep(null) = i2
 DECLARE dus_create_func(dcf_func_name=vc) = i2
 DECLARE dus_validate_pkg(dvp_pkg_name=vc,dvp_obj_status=vc(ref)) = i2
 DECLARE dus_load_tables(null) = i2
 DECLARE dus_load_indexes(null) = i2
 DECLARE dus_load_constraints(null) = i2
 DECLARE dus_insert_ddl_log_rec(didlr_run_id=f8,didlr_t=i4) = i2
 DECLARE dus_new_column_ddl(dnc_t=i4,dnc_tc=i4,dnc_col_name=vc) = i2
 DECLARE dus_alter_column_ddl(dac_t=i4,dac_orig_col_idx=i4,dac_utc_col_idx=i4,dac_col_name=vc) = i2
 DECLARE dus_additional_column_ddl(dacd_t=i4,dacd_tc=i4,dacd_col_name=vc,dacd_utc_col_name=vc) = i2
 DECLARE dus_additional_table_ddl(dat_t=i4) = i2
 DECLARE dus_build_trigger(dbt_trig_name=vc,dbt_func_name=vc,dbt_t=i4,dbt_operation=vc(ref)) = null
 DECLARE dus_column_backfill_range_ddl(par_tgtidx=i4,pk_col_name=vc) = i2
 DECLARE dus_column_backfill_ddl(par_tgtidx=i4) = i2
 DECLARE dus_create_index_ddl(par_tgt_tblidx=i4,par_tgt_indidx=i4) = i2
 DECLARE dus_existing_index_ddl(dei_t=i4,dei_orig_ind_idx=i4,dei_utc_ind_idx=i4,dei_utc_ind_name=vc)
  = i2
 DECLARE dus_new_index_ddl(dni_t=i4,dni_orig_ind_idx=i4,dni_utc_ind_name=vc) = i2
 DECLARE dus_drop_index_ddl(ddi_t=i4) = i2
 DECLARE dus_additional_index_ddl(dai_t=i4) = i2
 DECLARE dus_calc_tot_size_not_null(tsnn_tblcnt=i4) = null
 DECLARE dus_cal_dmt_size(cis_dmt_size=f8,cis_nextent=f8) = f8
 DECLARE dus_cal_lmt_round_size(cis_rsize=f8,cis_cursize=f8) = f8
 DECLARE dus_set_tspace_rec(tsp_ind=c1,tbl_seq=i4,ind_seq=i4) = null
 DECLARE dus_set_tsp_chunk_size(stcs_tbl_seq=i4,stcs_ind_seq=i4,stcs_tsp_seq=i4) = null
 DECLARE dus_load_tspace(null) = i2
 DECLARE dus_load_rtspace(dlr_new_ind=i2) = i2
 DECLARE dus_debug_disp_rtspace_tspace_rec(null) = null
 DECLARE dus_calc_tspace_needs(null) = i2
 DECLARE dus_check_status(null) = i2
 DECLARE dus_post_prompt(dpp_answer_out=vc(ref)) = i2
 DECLARE dus_check_pkg(dcp_pkg_ind=i2(ref)) = i2
 DECLARE dus_pop_utc_index(dpu_t=i4,dpu_orig_ind_idx=i4,dpu_utc_ind_idx=i4,dpu_utc_ind_name=vc) = i2
 DECLARE dus_prompt_utc_data(null) = i2
 DECLARE dus_drop_rdds_trigger(null) = i2
 DECLARE dus_set_schema_date(null) = i2
 DECLARE dus_set_run_id(null) = i2
 DECLARE dus_load_post_utc_run_id(null) = i2
 DECLARE dus_create_utc_function(null) = i2
 DECLARE dus_build_ddl(null) = i2
 DECLARE dus_apply_sizing(null) = i2
 DECLARE dus_calc_col_ratio(dcc_tbl_name=vc,dcc_col_name=vc) = f8
 DECLARE dus_sort_dst_year(null) = i2
 DECLARE dus_mng_utc_status(null) = i2
 DECLARE dus_mng_utc_src_info(null) = i2
 DECLARE dus_load_datafiles(null) = i2
 DECLARE dus_rpt_exist_tsp_needs_by_dg(detnbd_file=vc,detnbd_exist_space_needs=i2(ref)) = i2
 DECLARE dus_tspace_driver(null) = i2
 DECLARE dus_alter_visibility(dav_t=i4,dav_ind_name=vc) = i2
 DECLARE dus_alter_invisible(dai_t=i4,dai_orig_ind_name=vc) = i2
 DECLARE dus_parse_dst_file(dpdf_file=vc) = i2
 DECLARE dus_sch_dt = dq8 WITH protect, noconstant(0.0)
 SET dus_sch_dt = cnvtdatetime((curdate - 365),0)
 DECLARE dus_sch_dt_fnd = i2 WITH protect, noconstant(0)
 DECLARE dus_dcl_cmd = vc WITH protect, noconstant(" ")
 DECLARE dus_err_str = vc WITH protect, noconstant(" ")
 DECLARE dus_err_str2 = vc WITH protect, noconstant(" ")
 DECLARE dus_timezone_name = vc WITH protect, noconstant(" ")
 DECLARE dus_year = vc WITH protect, noconstant(" ")
 DECLARE dus_max_run_id = f8 WITH protect, noconstant(0.0)
 DECLARE dus_updt_post_utc_id = f8 WITH protect, noconstant(0.0)
 DECLARE dus_obj_status = vc WITH protect, noconstant(" ")
 DECLARE dus_offset_hr = vc WITH protect, noconstant(" ")
 DECLARE dus_offset_min = vc WITH protect, noconstant(" ")
 DECLARE dus_offset_dst_hr = vc WITH protect, noconstant(" ")
 DECLARE dus_ddl_complete = i2 WITH protect, noconstant(0)
 DECLARE dus_skip_dm2_utc_convert = i2 WITH protect, noconstant(0)
 DECLARE dus_skip_dm2_utc_reverse = i2 WITH protect, noconstant(0)
 DECLARE dus_run_id = f8 WITH protect, noconstant(0.0)
 DECLARE dus_op_type = vc WITH protect, noconstant(" ")
 DECLARE dus_obj_name = vc WITH protect, noconstant(" ")
 DECLARE dus_table_name = vc WITH protect, noconstant(" ")
 DECLARE dus_priority = i4 WITH protect, noconstant(0)
 DECLARE dus_operation = vc WITH protect, noconstant(" ")
 DECLARE dus_tablespace_name = vc WITH protect, noconstant(" ")
 DECLARE dus_orig_col_name = vc WITH protect, noconstant(" ")
 DECLARE dus_cnvt_col_name = vc WITH protect, noconstant(" ")
 DECLARE dus_col_fnd = i4 WITH protect, noconstant(0)
 DECLARE dus_col_idx = i4 WITH protect, noconstant(0)
 DECLARE dus_utc_ind_idx = i4 WITH protect, noconstant(0)
 DECLARE dus_utc_ind_name = vc WITH protect, noconstant(" ")
 DECLARE dus_already_coalesced_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_space_need_cnt = i4 WITH protect, noconstant(0)
 DECLARE dus_space_needs_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_answer_ret = vc WITH protect, noconstant("")
 DECLARE dus_chunk_needed = i4 WITH protect, noconstant(0)
 DECLARE dus_free_chunk = i4 WITH protect, noconstant(0)
 DECLARE dus_tot_free_chunk = i4 WITH protect, noconstant(0)
 DECLARE dus_coal_stat = vc WITH protect, noconstant(" ")
 DECLARE dus_utc_col_need = i2 WITH protect, noconstant(0)
 DECLARE dus_nn_ratio = f8 WITH protect, noconstant(0.0)
 DECLARE dus_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_err_msg = vc WITH protect, noconstant(" ")
 DECLARE dus_eproc = vc WITH protect, noconstant(" ")
 DECLARE dus_updt_dt_tm_convert_override = i2 WITH protect, noconstant(0)
 DECLARE dus_t = i4 WITH protect, noconstant(1)
 DECLARE dus_tc = i4 WITH protect, noconstant(1)
 DECLARE dus_i = i4 WITH protect, noconstant(1)
 DECLARE dus_ic = i4 WITH protect, noconstant(1)
 DECLARE lmt_level_64 = f8 WITH protect, constant(65536.0)
 DECLARE lmt_level_1 = f8 WITH protect, constant(1048576.0)
 DECLARE lmt_level_8 = f8 WITH protect, constant(83388608.0)
 DECLARE lmt_level_64m = f8 WITH protect, constant(67108864.0)
 DECLARE block_size = f8 WITH protect, constant(8192.00)
 DECLARE dus_date_len = i4 WITH protect, constant(8)
 DECLARE dus_tbl_header = i4 WITH protect, constant(3)
 DECLARE dus_lmt_chnk = f8 WITH protect, constant(67108864.0)
 DECLARE dus_new_extra = f8 WITH protect, constant(1048576.0)
 DECLARE lmt_min_ext_size = f8 WITH protect, constant(65536.0)
 DECLARE dus_utc_dst_file = vc WITH protect, noconstant("")
 DECLARE dus_filename = vc WITH protect, noconstant("")
 DECLARE dus_tmp_year = vc WITH protect, noconstant("")
 DECLARE dus_tmp_dt_tm = vc WITH protect, noconstant("")
 DECLARE dus_file_error = i2 WITH protect, noconstant(0)
 DECLARE dus_input_file_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_str = vc WITH protect, noconstant(" ")
 DECLARE dus_tz_size = f8 WITH protect, noconstant(0.0)
 DECLARE dus_no_tz_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_tbl_fnd = i2 WITH protect, noconstant(0)
 DECLARE dus_col_no_cnvt = i2 WITH protect, noconstant(0)
 DECLARE dus_curr_owner = vc WITH protect, noconstant("")
 DECLARE dus_mngd_tables = vc WITH protect, noconstant("")
 DECLARE dus_add_column_only_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_no_index_build_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_loop_var = i4 WITH protect, noconstant(0)
 DECLARE dus_stg_tspace = vc WITH protect, noconstant("")
 DECLARE dus_stg_tspace_ind = i2 WITH protect, noconstant(0)
 DECLARE dus_pos = i4 WITH protect, noconstant(0)
 DECLARE dus_loc = i4 WITH protect, noconstant(0)
 DECLARE dus_idx = i4 WITH protect, noconstant(0)
 FREE RECORD tspace_rec
 RECORD tspace_rec(
   1 tsp_rec_cnt = i4
   1 warn_flag = i2
   1 tsp[*]
     2 tsp_name = vc
     2 cur_bytes = f8
     2 tsp_type = c1
     2 need_size = f8
     2 new_ind = i2
     2 final_bytes_to_add = f8
     2 warn_flag = i2
     2 ext_mgmt = c1
     2 chunk_size = f8
 )
 FREE RECORD pk_cons_tmp
 RECORD pk_cons_tmp(
   1 pk_cons_cnt = i4
   1 cons[*]
     2 cons_name = vc
     2 parent_table = vc
     2 parent_table_columns = vc
 )
 SET pk_cons_tmp->pk_cons_cnt = 0
 FREE RECORD dus_notnull_cols
 RECORD dus_notnull_cols(
   1 tbl_cnt = i4
   1 tbl[*]
     2 tbl_name = vc
     2 col_cnt = i4
     2 col[*]
       3 col_name = vc
 )
 SET dus_notnull_cols->tbl_cnt = 0
 FREE RECORD dus_nv500_std_convert_list
 RECORD dus_nv500_std_convert_list(
   1 cnt = i2
   1 qual[*]
     2 own_name = vc
     2 tbl_name = vc
     2 col_name = vc
     2 no_convert_ind = i2
 )
 SET dus_nv500_std_convert_list->cnt = 0
 FREE RECORD dus_v500_cust_cqm
 RECORD dus_v500_cust_cqm(
   1 tbl_cnt = i4
   1 tbl[*]
     2 table_name = vc
 )
 SET dus_v500_cust_cqm->tbl_cnt = 0
 FREE RECORD dus_index_swap_tspace
 RECORD dus_index_swap_tspace(
   1 cnt = i4
   1 qual[*]
     2 tbl_name = vc
     2 ind_name = vc
     2 tspace_name = vc
     2 stg_tspace_name = vc
 )
 IF (check_logfile("dm2_utc_setup",".log","dm2_utc_setup")=false)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Starting DM2_UTC_SETUP"
 CALL disp_msg(" ",dm_err->logfile,0)
 EXECUTE dm2_set_db_options
 SET dm_err->eproc = "Loading CQM tables into Record structure."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT
  IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
   FROM dba_tables@ref_data_link dt
   WHERE dt.table_name="CQM*"
    AND dt.owner="V500"
    AND  NOT (dt.table_name IN (
   (SELECT
    dtd.table_name
    FROM dm_tables_doc dtd
    WHERE dtd.table_name="CQM*"
     AND dtd.full_table_name=dtd.table_name)))
  ELSE
   FROM dba_tables dt
   WHERE dt.table_name="CQM*"
    AND dt.owner="V500"
    AND  NOT (dt.table_name IN (
   (SELECT
    dtd.table_name
    FROM dm_tables_doc dtd
    WHERE dtd.table_name="CQM*"
     AND dtd.full_table_name=dtd.table_name)))
  ENDIF
  INTO "nl:"
  DETAIL
   IF (substring(1,4,dt.table_name)="CQM_"
    AND ((substring((size(trim(dt.table_name)) - 3),4,dt.table_name)="_QUE") OR (((substring((size(
     trim(dt.table_name)) - 4),5,dt.table_name)="_TR_1") OR (substring((size(trim(dt.table_name)) - 4
    ),5,dt.table_name)="_TR_2")) )) )
    dus_v500_cust_cqm->tbl_cnt = (dus_v500_cust_cqm->tbl_cnt+ 1), stat = alterlist(dus_v500_cust_cqm
     ->tbl,dus_v500_cust_cqm->tbl_cnt), dus_v500_cust_cqm->tbl[dus_v500_cust_cqm->tbl_cnt].table_name
     = dt.table_name
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) > 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dm_err->debug_flag > 5))
  CALL echorecord(dus_v500_cust_cqm)
 ENDIF
 IF ((dus_v500_cust_cqm->tbl_cnt > 0))
  SET dm_err->eproc = "Insert or Update V500 CUST CQM TABLES into Admin DM_INFO"
  CALL disp_msg("",dm_err->logfile,0)
  FOR (dus_loop_var = 1 TO dus_v500_cust_cqm->tbl_cnt)
   MERGE INTO dm2_admin_dm_info di
   USING DUAL ON (di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
      "_UTC_DATA - V500 CUST TABLES LIST")))
    AND (di.info_name=dus_v500_cust_cqm->tbl[dus_loop_var].table_name))
   WHEN MATCHED THEN
   (UPDATE
    SET di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE 1=1
   ;end update
   )
   WHEN NOT MATCHED THEN
   (INSERT  FROM di
    (di.info_domain, di.info_name, di.updt_dt_tm)
    VALUES(patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
       "_UTC_DATA - V500 CUST TABLES LIST"))), dus_v500_cust_cqm->tbl[dus_loop_var].table_name,
    cnvtdatetime(curdate,curtime3))
    WITH nocounter
   ;end insert
   )
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
  ENDFOR
  COMMIT
 ENDIF
 IF (dm2_fill_sch_except("LOCAL")=0)
  GO TO exit_script
 ENDIF
 IF (dum_fill_v500_cust(dm2_install_schema->target_dbase_name)=0)
  GO TO exit_script
 ENDIF
 IF (dus_mng_utc_status(null)=0)
  GO TO exit_script
 ENDIF
 SET dum_utc_data->appl_id = currdbhandle
 IF (dus_mng_utc_src_info(null)=0)
  GO TO exit_script
 ENDIF
 IF (dum_set_timezone(dus_timezone_name)=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Check if uptime DDL has been completed."
 SELECT INTO "nl:"
  FROM dm2_ddl_ops_log ddol
  WHERE (ddol.run_id=dum_utc_data->uptime_run_id)
   AND ddol.op_type="CREATE SQL-TRIGGER"
   AND ddol.status="COMPLETE"
  DETAIL
   dus_ddl_complete = 1
  WITH nocounter, maxqual(ddol,1)
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dus_ddl_complete=0)
  IF (dus_prompt_utc_data(null)=0)
   GO TO exit_script
  ENDIF
  IF (dum_load_date_columns("I",dm2_install_schema->target_dbase_name)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dus_load_post_utc_run_id(null)=0)
  GO TO exit_script
 ENDIF
 IF (dum_load_date_columns("C",dm2_install_schema->target_dbase_name)=0)
  GO TO exit_script
 ENDIF
 EXECUTE dm2_verify_date_columns
 IF ((dm_err->err_ind=1))
  GO TO exit_script
 ENDIF
 IF (dus_load_spec_cols(dm2_install_schema->target_dbase_name)=0)
  GO TO exit_script
 ENDIF
 IF (dus_load_spec_cols_nv500(null)=0)
  GO TO exit_script
 ENDIF
 IF (dus_create_utc_function(null)=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Delete UTC run_ids not in 'COMPLETE' status from DM2_DDL_OPS_LOG table."
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 DELETE  FROM dm2_ddl_ops_log ddol
  WHERE ddol.run_id IN (dum_utc_data->uptime_run_id, dum_utc_data->downtime_run_id)
   AND ((ddol.status != "COMPLETE") OR (ddol.status = null))
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET dus_mngd_tables = ""
 IF (dmr_load_managed_tables(dus_mngd_tables)=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Check for ADD_COLUMNS_ONLY override row in ADMIN DM_INFO."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm2_admin_dm_info di
  WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")))
   AND di.info_name="ADD_COLUMNS_ONLY"
   AND di.info_number=1
  DETAIL
   dus_add_column_only_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) > 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = concat("Admin DM_INFO ADD_COLUMNS_ONLY override row indicator:  ",cnvtstring(
   dus_add_column_only_ind),".")
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Check for NO_INDEX_BUILD override row in ADMIN DM_INFO."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm2_admin_dm_info di
  WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")))
   AND di.info_name="NO_INDEX_BUILD"
   AND di.info_number=1
  DETAIL
   dus_no_index_build_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) > 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = concat("Admin DM_INFO NO_INDEX_BUILD override row indicator:  ",cnvtstring(
   dus_no_index_build_ind),".")
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Loading UTC_INDEX_SWAP tablespaces."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm2_admin_dm_info di
  WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
     "_UTC_INDEX_SWAP")))
  HEAD REPORT
   stat = alterlist(dus_index_swap_tspace->qual,10)
  DETAIL
   dus_index_swap_tspace->cnt = (dus_index_swap_tspace->cnt+ 1)
   IF (mod(dus_index_swap_tspace->cnt,10)=1)
    stat = alterlist(dus_index_swap_tspace->qual,(dus_index_swap_tspace->cnt+ 9))
   ENDIF
   dus_pos = findstring("/",di.info_char,1,0), dus_index_swap_tspace->qual[dus_index_swap_tspace->cnt
   ].stg_tspace_name = substring(1,(dus_pos - 1),di.info_char), dus_index_swap_tspace->qual[
   dus_index_swap_tspace->cnt].tspace_name = substring((dus_pos+ 1),size(di.info_char),di.info_char),
   dus_idx = findstring("/",di.info_name,1,0), dus_loc = findstring("/",di.info_name,1,1),
   dus_index_swap_tspace->qual[dus_index_swap_tspace->cnt].tbl_name = substring((dus_idx+ 1),((
    dus_loc - dus_idx) - 1),di.info_name),
   dus_index_swap_tspace->qual[dus_index_swap_tspace->cnt].ind_name = substring((dus_loc+ 1),size(di
     .info_name),di.info_name)
  FOOT REPORT
   stat = alterlist(dus_index_swap_tspace->qual,dus_index_swap_tspace->cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) > 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dm_err->debug_flag > 5))
  CALL echorecord(dus_index_swap_tspace)
 ENDIF
 IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
  IF (dm2_get_remote_rdbms_version("ref_data_link")=0)
   GO TO exit_script
  ENDIF
  IF (dm2_get_rdbms_version(null)=0)
   GO TO exit_script
  ENDIF
  IF (dum_cust_incl_abort_gen(dm2_install_schema->target_dbase_name,dm2_remote_rdbms_version->level1,
   dm2_rdbms_version->level1)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (dus_owr_cnt = 1 TO dus_user_list->own_cnt)
   SET tgtsch->tbl_cnt = 0
   SET stat = alterlist(tgtsch->tbl,tgtsch->tbl_cnt)
   SET dus_curr_owner = dus_user_list->own[dus_owr_cnt].owner_name
   IF (dus_load_tables(null)=0)
    GO TO exit_script
   ENDIF
   IF (dus_load_indexes(null)=0)
    GO TO exit_script
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    GO TO exit_script
   ENDIF
   IF (dus_load_constraints(null)=0)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = "Check if Source dm_info row for staging tablespace exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info@ref_data_link di
    WHERE di.info_domain="DM2_MIG_UTC_IND_TSPACE"
     AND di.info_name != "DM2NOTSET"
    DETAIL
     dus_stg_tspace_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   IF (dus_stg_tspace_ind=1
    AND (dus_index_swap_tspace->cnt=0))
    SET dm_err->eproc = "Validating UTC_INDEX_SWAP Admin dm_info rows."
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Staging tablespace found in source DM_INFO but missing corresponding Admin DM_INFO rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   IF (dus_build_ddl(null)=0)
    GO TO exit_script
   ENDIF
   IF ((dus_user_list->own[dus_owr_cnt].owner_name="V500"))
    IF (dus_tspace_driver(null)=0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET dum_utc_data->status = "SETUP_COMPLETE"
 SET dm_err->eproc = "Update UTC CONVERSION status row on ADMIN DM_INFO as COMPLETE."
 UPDATE  FROM dm2_admin_dm_info
  SET info_char = currdbhandle, info_name = dum_utc_data->status, updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  WHERE info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
     "_UTC_DATA_STATUS")))
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 GO TO exit_script
 SUBROUTINE dus_check_pkg(dcp_pkg_ind)
   SET dcp_pkg_ind = 0
   SET dm_err->eproc = "Checking for packages currently being installed."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dum_check_concurrent_snapshot("I")=0)
    RETURN(0)
   ENDIF
   IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
    SELECT DISTINCT INTO "nl:"
     ddol.appl_id
     FROM dm2_ddl_ops_log@ref_data_link ddol
     WHERE ddol.status="RUNNING"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcp_pkg_ind = 1
    ENDIF
   ENDIF
   IF (dm2_cleanup_stranded_appl(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Find all run_ids on DM2_DDL_OPS_LOG that have RUNNING or NULL status."
   SELECT
    IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
     FROM dm2_ddl_ops_log ddol
     WHERE ddol.status="RUNNING"
    ELSE
     FROM dm2_ddl_ops_log ddol
     WHERE ((ddol.status="RUNNING") OR (ddol.status = null))
    ENDIF
    DISTINCT INTO "nl:"
    ddol.appl_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcp_pkg_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_set_schema_date(null)
   SET dm_err->eproc = "Setting Schema Date for UTC conversion."
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (dus_sch_dt_fnd=0)
     SET dm_err->eproc = "Find schema date that is not used in DM2_OPS_LOG."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SET dm_err->eproc = concat("Find schema date ",format(dus_sch_dt,";;q")," on table DM2_DDL_OPS."
      )
     SELECT INTO "nl:"
      FROM dm2_ddl_ops d
      WHERE d.schema_date=cnvtdatetime(dus_sch_dt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = concat("Verify schema date ",trim(format(dus_sch_dt,"MM/DD/YYYY;;D")),
       " is not used in existing schema file names.")
      SET dus_dcl_cmd = concat(dm2_install_schema->cer_install,"dm2s",trim(cnvtalphanum(format(
          dus_sch_dt,"MM/DD/YYYY;;D"))),"_t.dat")
      IF (findfile(dus_dcl_cmd)=0)
       SET dus_sch_dt_fnd = 1
       IF ((dm_err->debug_flag > 0))
        CALL echo("Schema date is not found in schema file names.")
       ENDIF
      ELSE
       SET dus_sch_dt = cnvtdatetime((cnvtdate(dus_sch_dt) - 1),0)
      ENDIF
     ELSE
      SET dus_sch_dt = cnvtdatetime((cnvtdate(dus_sch_dt) - 1),0)
     ENDIF
   ENDWHILE
   SET dum_utc_data->schema_date = cnvtdatetime(dus_sch_dt)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dum_utc_data->schema_date = ",format(dum_utc_data->schema_date,";;q")))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_set_run_id(null)
   SET dm_err->eproc = "Setting UTC conversion Run ids."
   CALL disp_msg("",dm_err->logfile,0)
   SET dm_err->eproc = "Query for UTC Conversion Uptime/Downtime run ids from DM2_DDL_OPS."
   SELECT INTO "nl:"
    FROM dm2_ddl_ops d
    WHERE d.process_option IN ("UTC CONVERSION UPTIME", "UTC CONVERSION DOWNTIME")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Find the max run_id in dm2_ddl_ops and set uptime/downtime run_id."
    SELECT INTO "nl:"
     tmp_max_run_id = max(d.run_id)
     FROM dm2_ddl_ops d
     WHERE d.run_id IS NOT null
     DETAIL
      dum_utc_data->uptime_run_id = (tmp_max_run_id+ 1), dum_utc_data->downtime_run_id = (
      dum_utc_data->uptime_run_id+ 1)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("uptime_run_id =",dum_utc_data->uptime_run_id))
     CALL echo(build("downtime_run_id =",dum_utc_data->downtime_run_id))
    ENDIF
    SET dm_err->eproc = concat("Insert uptime run id ",cnvtstring(dum_utc_data->uptime_run_id),
     " into dm2_ddl_ops table.")
    INSERT  FROM dm2_ddl_ops d
     SET d.run_id = dum_utc_data->uptime_run_id, d.gen_dt_tm = cnvtdatetime(curdate,curtime3), d.ocd
       = 0.0,
      d.schema_date = cnvtdatetime(dum_utc_data->schema_date), d.process_option =
      "UTC CONVERSION UPTIME", d.last_checkpoint = "INITIAL"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = concat("Insert downtime run id ",cnvtstring(dum_utc_data->downtime_run_id),
     " into dm2_ddl_ops table.")
    INSERT  FROM dm2_ddl_ops d
     SET d.run_id = dum_utc_data->downtime_run_id, d.gen_dt_tm = cnvtdatetime(curdate,curtime3), d
      .ocd = 0.0,
      d.schema_date = cnvtdatetime(dum_utc_data->schema_date), d.process_option =
      "UTC CONVERSION DOWNTIME", d.last_checkpoint = "INITIAL"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_post_utc_run_id(null)
   SET dm_err->eproc = concat(
    "Retrieve all run_ids from Source dm2_ddl_ops that are greater than or equal to uptime run id ",
    cnvtstring(dum_utc_data->downtime_run_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
    SELECT INTO "nl:"
     tmp_max_run_id = max(d.run_id)
     FROM dm2_ddl_ops@ref_data_link d
     DETAIL
      dus_max_run_id = tmp_max_run_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SELECT INTO "nl:"
     tmp_max_run_id = max(d.run_id)
     FROM dm2_ddl_ops d
     WHERE (d.run_id > dum_utc_data->downtime_run_id)
     DETAIL
      dus_max_run_id = tmp_max_run_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dus_max_run_id > 0)
    SET dm_err->eproc = concat("Find run id ",cnvtstring(dus_max_run_id),"on ADMIN DM_INFO table")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"
        )))
      AND di.info_name="POST_UTC_RUN_IDS"
     DETAIL
      IF (di.info_number < dus_max_run_id)
       dus_updt_post_utc_id = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = concat("Insert run id ",cnvtstring(dus_max_run_id),
      "into ADMIN DM_INFO table")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     INSERT  FROM dm2_admin_dm_info di
      SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
          "_UTC_DATA"))), di.info_name = "POST_UTC_RUN_IDS", di.info_char = null,
       di.info_number = dus_max_run_id, di.info_date = null, di.updt_dt_tm = cnvtdatetime(curdate,
        curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ELSEIF (dus_updt_post_utc_id)
     SET dm_err->eproc = concat("Update POST UTC run id ",cnvtstring(dus_max_run_id),
      "into ADMIN DM_INFO table")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm2_admin_dm_info di
      SET di.info_number = dus_max_run_id, di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
         "_UTC_DATA")))
       AND di.info_name="POST_UTC_RUN_IDS"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_prompt_utc_data(null)
   DECLARE dpud_auto_start_year = i4 WITH protect, noconstant(1890)
   DECLARE dpud_auto_end_year = i4 WITH protect, noconstant((year(curdate)+ 10))
   DECLARE dpud_file_fnd = i2 WITH protect, noconstant(0)
   DECLARE dpud_valid_tz = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check if supported time zone."
   IF ((dm_err->debug_flag > 2))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"))
     )
     AND d.info_name="TIMEZONE_SUPPORTED"
     AND d.info_char=trim(cnvtupper(dus_timezone_name))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dpud_valid_tz = 1
   ENDIF
   IF (cnvtupper(dus_timezone_name) IN ("AMERICA/ANCHORAGE", "AMERICA/CHICAGO", "AMERICA/NEW_YORK",
   "AMERICA/DENVER", "AMERICA/LOS_ANGELES",
   "EUROPE/DUBLIN", "EUROPE/PARIS", "EUROPE/AMSTERDAM", "EUROPE/BERLIN", "AMERICA/HALIFAX",
   "AUSTRALIA/MELBOURNE", "AUSTRALIA/SYDNEY"))
    SET dpud_valid_tz = 1
   ENDIF
   IF (dpud_valid_tz=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verify supported time zone."
    SET dm_err->emsg = concat("Time zone [",trim(dus_timezone_name),
     "] is not supported.  Cannot proceed with UTC Conversion.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Find ADMIN DM_INFO override for AUTO_START_YEAR."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"))
     )
     AND d.info_name="AUTO_START_YEAR"
    DETAIL
     dpud_auto_start_year = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("AUTO_START_YEAR = ",dpud_auto_start_year))
    ENDIF
   ENDIF
   SET dm_err->eproc = "Find ADMIN DM_INFO override for AUTO_FUTURE_YEARS_INCREMENT."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"))
     )
     AND d.info_name="AUTO_FUTURE_YEARS_INCREMENT"
    DETAIL
     dpud_auto_end_year = (d.info_number+ year(curdate))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("AUTO_FUTURE_YEARS_INCREMENT = ",dpud_auto_end_year))
    ENDIF
   ENDIF
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,9,80)
   CALL text(3,3,"UTC Conversion Data Entry")
   CALL text(5,3,concat("Time Zone: ",dus_timezone_name,"    Standard Offset: ",dum_offset_sign,
     format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")))
   CALL text(7,3,"Enter 'C' to confirm time zone and offset or 'E' to exit process:")
   CALL accept(7,70,"P;CU"," "
    WHERE curaccept IN ("C", "E"))
   SET message = nowindow
   IF (curaccept="E")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Prompt user UTC Data Entry."
    SET dm_err->emsg = "User choose to exit during UTC Conversion Data Entry menu."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(dus_timezone_name) IN ("AMERICA/ANCHORAGE", "AMERICA/CHICAGO", "AMERICA/NEW_YORK",
   "AMERICA/DENVER", "AMERICA/LOS_ANGELES"))
    SET dus_utc_dst_file = concat(dm2_install_schema->cer_install,"dm2_utc_domestic_dst_ranges.dat")
   ELSE
    SET dus_utc_dst_file = build(dm2_install_schema->cer_install,"dm2_utc_",trim(cnvtlower(replace(
        dus_timezone_name,"/","_"))),"_dst_ranges.dat")
   ENDIF
   SET dm_err->eproc = concat("Verify file ",dus_utc_dst_file," exists.")
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm2_findfile(dus_utc_dst_file) > 0)
    SET dpud_file_fnd = 1
    SET dus_dst_accept->method = "FILE"
   ENDIF
   IF (dpud_file_fnd=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,16,120)
    CALL text(3,3,"UTC Conversion Data Entry - Daylight Saving Time (DST) Observance")
    CALL text(5,3,"Please confirm whether Daylight Saving Time observed.")
    CALL text(9,3,"(Y)es DST observed, (N)o DST observed, (Q)uit (Y/N/Q):")
    CALL accept(9,60,"P;CU"," "
     WHERE curaccept IN ("Y", "N", "Q"))
    IF (curaccept="Q")
     SET message = nowindow
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Prompt user for Daylight Saving Time observance."
     SET dm_err->emsg = "User chose to Quit."
     CALL disp_msg("",dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curaccept="N")
     SET dus_dst_accept->cnt = 0
     SET stat = alterlist(dus_dst_accept->qual,0)
    ELSEIF (curaccept="Y")
     SET dus_dst_accept->method = "FILE"
    ENDIF
   ENDIF
   SET message = nowindow
   IF ((dus_dst_accept->method="FILE")
    AND dpud_file_fnd=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("DST Confirmed Observed.  Now verify file ",dus_utc_dst_file,
     " exists.")
    SET dm_err->emsg = concat(dus_utc_dst_file," is not found.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dus_dst_accept->method="FILE")
    AND dpud_file_fnd=1)
    SET dm_err->eproc = concat("Validate file ",dus_utc_dst_file," content.")
    CALL disp_msg("",dm_err->logfile,0)
    IF (dus_parse_dst_file(dus_utc_dst_file)=0)
     RETURN(0)
    ENDIF
    IF (dus_input_file_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Verify file ",dus_utc_dst_file," exists.")
     SET dm_err->emsg = concat(dus_utc_dst_file," contains invalid content.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dus_dst_accept->cnt=0))
    SET dum_utc_data->dst_ind = 0
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,17,80)
    CALL text(3,3,"UTC Conversion Data Entry - Confirmation")
    CALL text(5,3,concat("Time Zone: ",dus_timezone_name,"    Standard Offset: ",dum_offset_sign,
      format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")))
    CALL text(9,3,"Daylight Saving Time has not been observed in past years.")
    CALL text(15,3,"Enter 'C' to continue or 'E' to exit process:")
    CALL accept(15,49,"P;CU","C"
     WHERE curaccept IN ("C", "E"))
    SET message = nowindow
    IF (curaccept="E")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Prompt user UTC Conversion Data Entry - Confirmation menu."
     SET dm_err->emsg = "User choose to exit during UTC Conversion Data Entry - Confirmation menu."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dum_utc_data->dst_ind = 1
    SET message = nowindow
    IF (dum_disp_dst_rpt(dus_timezone_name)=0)
     RETURN(0)
    ENDIF
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,10,80)
    CALL text(3,3,"UTC Conversion DST Data - Confirmation")
    CALL text(5,3,"Were the values from previous report correct?")
    CALL text(7,3,"Enter 'Y' to continue or 'E' to exit process:")
    CALL accept(7,49,"P;CU"," "
     WHERE curaccept IN ("Y", "E"))
    SET message = nowindow
    IF (curaccept="E")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "UTC Conversion DST Data - Confirmation menu."
     SET dm_err->emsg = "User choose to exit during UTC Conversion DST Data - Confirmation menu."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Delete old UTC DATA ADMIN DM_INFO row."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")
      ))
     AND di.info_name IN ("*DST*", "OFFSET", "CURTIMEZONESYS")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SET dm_err->eproc = build("Insert new OFFSET(",dum_utc_data->offset,") ADMIN DM_INFO row.")
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")
       )), di.info_name = "OFFSET", di.info_char = " ",
     di.info_number = dum_utc_data->offset, di.info_date = null, di.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build("Insert new Daylight Saving Time indicator(",dum_utc_data->dst_ind,
    ") ADMIN DM_INFO row.")
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")
       )), di.info_name = "DST INDICATOR", di.info_char = null,
     di.info_number = dum_utc_data->dst_ind, di.info_date = null, di.updt_dt_tm = cnvtdatetime(
      curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build("Insert new Current Time Zone(",curtimezonesys,") ADMIN DM_INFO row.")
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")
       )), di.info_name = "CURTIMEZONESYS", di.info_char = null,
     di.info_number = curtimezonesys, di.info_date = null, di.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dus_dst_accept->cnt > 0))
    IF (dus_sort_dst_year(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   FOR (dus_i = 1 TO dus_dst_accept->cnt)
     SET dm_err->eproc = concat("Insert new Daylight Saving START Time ADMIN DM_INFO row for ",
      dus_dst_accept->qual[dus_i].year)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     INSERT  FROM dm2_admin_dm_info di
      SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
          "_UTC_DATA"))), di.info_name = concat(dus_dst_accept->qual[dus_i].year," START DST"), di
       .info_char = null,
       di.info_number = dus_i, di.info_date = cnvtdatetime(dus_dst_accept->qual[dus_i].start_dt_tm),
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Insert new Daylight Saving END Time ADMIN DM_INFO row for ",
      dus_dst_accept->qual[dus_i].year)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     INSERT  FROM dm2_admin_dm_info di
      SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
          "_UTC_DATA"))), di.info_name = concat(dus_dst_accept->qual[dus_i].year," END DST"), di
       .info_char = null,
       di.info_number = dus_i, di.info_date = cnvtdatetime(dus_dst_accept->qual[dus_i].end_dt_tm), di
       .updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_create_utc_function(null)
   SET dm_err->eproc = "Create UTC functions."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dus_validate_pkg("DM2_UTC_CONVERT_PKG",dus_obj_status)=0)
    RETURN(0)
   ENDIF
   IF (dus_obj_status != "VALID"
    AND dus_ddl_complete=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validate DM2_UTC_CONVERT_PKG package."
    SET dm_err->emsg =
    "DM2_UTC_CONVERT_PKG package does not exist or is INVALID when UTC DDL has been completed."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dus_ddl_complete=1
    AND dus_obj_status="VALID")
    SET dus_skip_dm2_utc_convert = 1
   ENDIF
   IF (dus_skip_dm2_utc_convert=0)
    IF (dus_create_func_prep(null)=0)
     RETURN(0)
    ENDIF
    IF (dum_offset_sign="-")
     SET dum_offset_sign = "+"
    ELSE
     SET dum_offset_sign = "-"
    ENDIF
    IF (dus_create_func("DM2_UTC_CONVERT")=0)
     RETURN(0)
    ENDIF
    IF (dus_validate_pkg("DM2_UTC_CONVERT_PKG",dus_obj_status)=0)
     RETURN(0)
    ELSEIF (dus_obj_status != "VALID")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validate DM2_UTC_CONVERT_PKG package."
     SET dm_err->emsg = "DM2_UTC_CONVERT_PKG package is INVALID."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dus_validate_pkg("DM2_UTC_REVERSE_PKG",dus_obj_status)=0)
    RETURN(0)
   ENDIF
   IF (dus_obj_status != "VALID"
    AND dus_ddl_complete=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validate DM2_UTC_REVERSE_PKG package."
    SET dm_err->emsg =
    "DM2_UTC_REVERSE_PKG package does not exist or is INVALID when UTC DDL has been completed."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dus_ddl_complete=1
    AND dus_obj_status="VALID")
    SET dus_skip_dm2_utc_reverse = 1
   ENDIF
   IF (dus_skip_dm2_utc_reverse=0)
    IF (dus_skip_dm2_utc_convert=1)
     IF (dus_create_func_prep(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dus_skip_dm2_utc_convert=0)
     IF (dum_offset_sign="-")
      SET dum_offset_sign = "+"
     ELSE
      SET dum_offset_sign = "-"
     ENDIF
    ENDIF
    IF (dus_create_func("DM2_UTC_REVERSE")=0)
     RETURN(0)
    ENDIF
    IF (dus_validate_pkg("DM2_UTC_REVERSE_PKG",dus_obj_status)=0)
     RETURN(0)
    ELSEIF (dus_obj_status != "VALID")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validate DM2_UTC_REVERSE_PKG package."
     SET dm_err->emsg = "DM2_UTC_REVERSE_PKG package is INVALID."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_create_func_prep(null)
   SET dm_err->eproc = "Check if Daylight Saving time is observed."
   SELECT INTO "nl:"
    di.info_number
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")
      ))
     AND di.info_name IN ("DST INDICATOR", "OFFSET")
    DETAIL
     IF (di.info_name="DST INDICATOR")
      dum_utc_data->dst_ind = di.info_number
     ELSEIF (di.info_name="OFFSET")
      dum_utc_data->offset = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dum_utc_data->dst_ind=1)
    AND (dus_dst_accept->cnt=0))
    SET stat = alterlist(dus_dst_accept->qual,0)
    SET dm_err->eproc = "Find Daylight Saving time periods from ADMIN DM_INFO table."
    SELECT INTO "nl:"
     d.info_date
     FROM dm2_admin_dm_info d
     WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")
       ))
      AND d.info_name="*DST"
     ORDER BY info_date
     HEAD REPORT
      stat = alterlist(dus_dst_accept->qual,10)
     DETAIL
      IF (findstring("START",d.info_name) > 0)
       dus_dst_accept->cnt = (dus_dst_accept->cnt+ 1), dus_dst_accept->qual[dus_dst_accept->cnt].
       start_dt_tm = cnvtdatetime(d.info_date)
      ELSEIF (findstring("END",d.info_name) > 0)
       dus_dst_accept->qual[dus_dst_accept->cnt].end_dt_tm = cnvtdatetime(d.info_date)
      ENDIF
     FOOT REPORT
      stat = alterlist(dus_dst_accept->qual,dus_dst_accept->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dum_utc_data->offset < 0))
    SET dum_offset_sign = "-"
   ELSE
    SET dum_offset_sign = "+"
   ENDIF
   SET dus_offset_hr = substring(1,2,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M"))
   SET dus_offset_min = substring(4,2,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M"))
   CALL echo(build("offset_hr =",dus_offset_hr))
   CALL echo(build("offset_min = ",dus_offset_min))
   IF (dum_offset_sign="-")
    SET dus_offset_dst_hr = cnvtstring((cnvtint(dus_offset_hr) - 1))
   ELSE
    SET dus_offset_dst_hr = cnvtstring((cnvtint(dus_offset_hr)+ 1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_create_func(dcf_func_name)
   DECLARE dcf_func_str = vc WITH protect, noconstant(" ")
   DECLARE dcf_start_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE dcf_end_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE dcf_dst_offset_min = i4 WITH protect, noconstant(0)
   IF (dum_offset_sign="-")
    SET dcf_dst_offset_min = (abs(dum_utc_data->offset) - 60)
   ELSE
    SET dcf_dst_offset_min = (abs(dum_utc_data->offset)+ 60)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dcf_dst_offset_min = ",dcf_dst_offset_min))
   ENDIF
   SET dcf_func_str = concat("create or replace package ",dcf_func_name,"_PKG as function ",
    dcf_func_name,"(std_only_ind NUMBER, dt_tm_in DATE) return date; ",
    "v_dt_01021800 date := TO_DATE('01-02-1800 00:00:00','MM-DD-YYYY HH24:MI:SS'); ",
    "v_dt_01022100 date := TO_DATE('01-02-2100 00:00:00','MM-DD-YYYY HH24:MI:SS'); ")
   CALL dm2_push_cmd(concat("rdb asis(^",dcf_func_str,"^)"),0)
   IF ((dum_utc_data->dst_ind=1))
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dus_dst_accept)
    ENDIF
    FOR (dus_i = 1 TO dus_dst_accept->cnt)
      IF (dcf_func_name="DM2_UTC_CONVERT")
       SET dcf_func_str = concat("v_dt_",trim(dus_dst_accept->qual[dus_i].year),
        "_b date := TO_DATE('",format(dus_dst_accept->qual[dus_i].start_dt_tm,
         "MM-DD-YYYY HH:MM:SS;;D"),"','MM-DD-YYYY HH24:MI:SS');",
        "v_dt_",trim(dus_dst_accept->qual[dus_i].year),"_e date := TO_DATE('",format(dus_dst_accept->
         qual[dus_i].end_dt_tm,"MM-DD-YYYY HH:MM:SS;;D"),"','MM-DD-YYYY HH24:MI:SS');")
       CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
      ELSEIF (dcf_func_name="DM2_UTC_REVERSE")
       IF (dum_offset_sign="+")
        SET dcf_start_dt_tm = cnvtlookbehind(build('"',dcf_dst_offset_min,', MIN"'),cnvtdatetime(
          dus_dst_accept->qual[dus_i].start_dt_tm))
        SET dcf_end_dt_tm = cnvtlookbehind(build('"',dcf_dst_offset_min,', MIN"'),cnvtdatetime(
          dus_dst_accept->qual[dus_i].end_dt_tm))
       ELSEIF (dum_offset_sign="-")
        SET dcf_start_dt_tm = cnvtlookahead(build('"',dcf_dst_offset_min,', MIN"'),cnvtdatetime(
          dus_dst_accept->qual[dus_i].start_dt_tm))
        SET dcf_end_dt_tm = cnvtlookahead(build('"',dcf_dst_offset_min,', MIN"'),cnvtdatetime(
          dus_dst_accept->qual[dus_i].end_dt_tm))
       ENDIF
       IF ((dm_err->debug_flag > 2))
        CALL echo(build("offest = ",dcf_dst_offset_min))
        CALL echo(format(cnvtdatetime(dcf_start_dt_tm),";;q"))
        CALL echo(format(cnvtdatetime(dcf_end_dt_tm),";;q"))
       ENDIF
       SET dcf_func_str = concat("v_dt_",trim(dus_dst_accept->qual[dus_i].year),
        "_b date := TO_DATE('",format(dcf_start_dt_tm,"MM-DD-YYYY HH:MM:SS;;D"),
        "','MM-DD-YYYY HH24:MI:SS');",
        "v_dt_",trim(dus_dst_accept->qual[dus_i].year),"_e date := TO_DATE('",format(dcf_end_dt_tm,
         "MM-DD-YYYY HH:MM:SS;;D"),"','MM-DD-YYYY HH24:MI:SS');")
       CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
      ENDIF
    ENDFOR
   ENDIF
   SET dcf_func_str = concat("v_dst_offset number := ((",dus_offset_dst_hr," * ",dum_offset_sign,
    "1)/24) + ((",
    dus_offset_min," * ",dum_offset_sign,"1)/24/60);","v_nodst_offset number := ((",
    dus_offset_hr," * ",dum_offset_sign,"1)/24) + ((",dus_offset_min,
    " * ",dum_offset_sign,"1)/24/60); end;")
   IF ((dm_err->debug_flag > 0))
    CALL echo(dcf_func_str)
   ENDIF
   IF (dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^) go"),1)=0)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SET dcf_func_str = concat("create or replace package body ",dcf_func_name,"_PKG as function ",
    dcf_func_name,"(std_only_ind NUMBER, dt_tm_in DATE) RETURN DATE is v_year VARCHAR2(4); begin ",
    "if dt_tm_in = NULL then return(null); ","elsif dt_tm_in < v_dt_01021800 then return(dt_tm_in); ",
    "elsif dt_tm_in > v_dt_01022100 then return(dt_tm_in); ",
    "elsif std_only_ind = 1 then return(dt_tm_in + v_nodst_offset); ")
   CALL dm2_push_cmd(concat("rdb asis(^",dcf_func_str,"^)"),0)
   IF ((dum_utc_data->dst_ind=1))
    SET dcf_func_str = concat("else v_year := to_char(dt_tm_in,'YYYY'); ")
    CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
    FOR (dus_i = 1 TO dus_dst_accept->cnt)
      IF (dus_i=1)
       IF (cnvtupper(dus_timezone_name) IN ("AUSTRALIA/MELBOURNE", "AUSTRALIA/SYDNEY"))
        SET dcf_func_str = concat(" if v_year = '",trim(dus_dst_accept->qual[dus_i].year),
         "' then if dt_tm_in <= v_dt_",trim(dus_dst_accept->qual[dus_i].year),
         "_e or dt_tm_in >= v_dt_",
         trim(dus_dst_accept->qual[dus_i].year),"_b then return(dt_tm_in + v_dst_offset);",
         " else return(dt_tm_in + v_nodst_offset);  end if; ")
        CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
       ELSE
        SET dcf_func_str = concat(" if v_year = '",trim(dus_dst_accept->qual[dus_i].year),
         "' then if dt_tm_in between v_dt_",trim(dus_dst_accept->qual[dus_i].year),"_b and v_dt_",
         trim(dus_dst_accept->qual[dus_i].year),"_e then return(dt_tm_in + v_dst_offset);",
         " else return(dt_tm_in + v_nodst_offset);  end if; ")
        CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
       ENDIF
      ELSE
       IF (cnvtupper(dus_timezone_name) IN ("AUSTRALIA/MELBOURNE", "AUSTRALIA/SYDNEY"))
        SET dcf_func_str = concat(" elsif v_year = '",trim(dus_dst_accept->qual[dus_i].year),
         "' then if dt_tm_in <= v_dt_",trim(dus_dst_accept->qual[dus_i].year),
         "_e or dt_tm_in >= v_dt_",
         trim(dus_dst_accept->qual[dus_i].year),"_b then return(dt_tm_in + v_dst_offset);",
         " else return(dt_tm_in + v_nodst_offset);  end if; ")
        CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
       ELSE
        SET dcf_func_str = concat(" elsif v_year = '",trim(dus_dst_accept->qual[dus_i].year),
         "' then if dt_tm_in between v_dt_",trim(dus_dst_accept->qual[dus_i].year),"_b and v_dt_",
         trim(dus_dst_accept->qual[dus_i].year),"_e then return(dt_tm_in + v_dst_offset);",
         " else return(dt_tm_in + v_nodst_offset);  end if; ")
        CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET dcf_func_str = concat(" else return(dt_tm_in + v_nodst_offset); ","end if; ")
   CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
   IF ((dum_utc_data->dst_ind=1))
    SET dcf_func_str = concat("end if; ")
    CALL dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^)"),0)
   ENDIF
   SET dcf_func_str = concat("end; ","end ",dcf_func_name,"_PKG;^) go")
   IF ((dm_err->debug_flag > 0))
    CALL echo(dcf_func_str)
   ENDIF
   IF (dm2_push_cmd(concat("asis(^  ",dcf_func_str,"^) go"),1)=0)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_validate_pkg(dvp_pkg_name,dvp_obj_status)
   DECLARE dvp_pkg_status = vc WITH protect, noconstant("")
   DECLARE dvp_pkg_body_status = vc WITH protect, noconstant("")
   SET dvp_obj_status = ""
   SET dm_err->eproc = concat("Check status for Package ",dvp_pkg_name)
   SELECT INTO "nl:"
    FROM user_objects uo
    WHERE uo.object_name=cnvtupper(dvp_pkg_name)
     AND uo.object_type IN ("PACKAGE", "PACKAGE BODY")
    DETAIL
     IF (uo.object_type="PACKAGE")
      dvp_pkg_status = uo.status
     ELSEIF (uo.object_type="PACKAGE BODY")
      dvp_pkg_body_status = uo.status
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dvp_pkg_status="VALID"
    AND dvp_pkg_body_status="VALID")
    SET dvp_obj_status = "VALID"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_tables(null)
   DECLARE dlt_pos = i4 WITH protect, noconstant(0)
   DECLARE dlt_nv500_pos = i4 WITH protect, noconstant(0)
   DECLARE dlt_v500_cust = i4 WITH protect, noconstant(0)
   DECLARE dlt_v500_doc = i4 WITH protect, noconstant(0)
   FREE RECORD dlts_td_tables
   RECORD dlts_td_tables(
     1 cnt = i4
     1 tbl[*]
       2 table_name = vc
       2 reference_ind = i4
       2 table_suffix = vc
   )
   SET dlts_td_tables->cnt = 0
   SET dm_err->eproc = "Load documented tables into memory."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    td.table_name
    FROM dm_tables_doc td
    WHERE td.table_name=td.full_table_name
    HEAD REPORT
     stat = alterlist(dlts_td_tables->tbl,10)
    DETAIL
     dlts_td_tables->cnt = (dlts_td_tables->cnt+ 1)
     IF (mod(dlts_td_tables->cnt,10)=1
      AND (dlts_td_tables->cnt != 1))
      stat = alterlist(dlts_td_tables->tbl,(dlts_td_tables->cnt+ 9))
     ENDIF
     dlts_td_tables->tbl[dlts_td_tables->cnt].table_name = td.table_name, dlts_td_tables->tbl[
     dlts_td_tables->cnt].reference_ind = td.reference_ind, dlts_td_tables->tbl[dlts_td_tables->cnt].
     table_suffix = td.table_suffix
    FOOT REPORT
     stat = alterlist(dlts_td_tables->tbl,dlts_td_tables->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading NOT NULL columns from dm2_dba_notnull_cols..."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    u.column_name
    FROM dm2_dba_notnull_cols u
    WHERE u.owner=dus_curr_owner
    ORDER BY u.table_name
    HEAD REPORT
     dlt_tab_col_cnt = 0, dlt_tab_cnt = 0
    HEAD u.table_name
     dlt_tab_cnt = (dlt_tab_cnt+ 1)
     IF (mod(dlt_tab_cnt,1000)=1)
      stat = alterlist(dus_notnull_cols->tbl,(dlt_tab_cnt+ 999))
     ENDIF
     dus_notnull_cols->tbl[dlt_tab_cnt].tbl_name = u.table_name
    DETAIL
     dlt_tab_col_cnt = (dlt_tab_col_cnt+ 1)
     IF (mod(dlt_tab_col_cnt,10)=1)
      stat = alterlist(dus_notnull_cols->tbl[dlt_tab_cnt].col,(dlt_tab_col_cnt+ 9))
     ENDIF
     dus_notnull_cols->tbl[dlt_tab_cnt].col[dlt_tab_col_cnt].col_name = u.column_name
    FOOT  u.table_name
     stat = alterlist(dus_notnull_cols->tbl[dlt_tab_cnt].col,dlt_tab_col_cnt), dus_notnull_cols->tbl[
     dlt_tab_cnt].col_cnt = dlt_tab_col_cnt, dlt_tab_col_cnt = 0
    FOOT REPORT
     stat = alterlist(dus_notnull_cols->tbl,dlt_tab_cnt), dus_notnull_cols->tbl_cnt = dlt_tab_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Performing Retrieval & Load of Table Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_tab_cols c,
     dba_tables t,
     dba_objects do
    PLAN (t
     WHERE t.table_name != "MVJ*"
      AND t.temporary="N"
      AND t.owner=dus_curr_owner
      AND parser(concat(" t.table_name not in (",dus_mngd_tables,")")))
     JOIN (do
     WHERE t.owner=do.owner
      AND t.table_name=do.object_name)
     JOIN (c
     WHERE t.owner=c.owner
      AND t.table_name=c.table_name
      AND  NOT (c.hidden_column="YES"
      AND c.virtual_column="NO"))
    ORDER BY c.table_name, c.column_name
    HEAD REPORT
     dlt_table_cnt = 0, dlt_table_col_cnt = 0, dlt_loc_last_tbl = 1,
     dlt_loc_tbl = 0, dlt_loc_col = 0, dlt_num = 0,
     MACRO (data_default_cleanup)
      IF (((cnvtupper(c.data_default)="NULL") OR (((c.data_default=" ") OR (((c.data_default="") OR (
      ((c.data_default="''") OR (c.data_default='""')) )) )) )) )
       tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].data_default_ni = 1
      ENDIF
     ENDMACRO
    HEAD c.table_name
     dlt_pos = 0, dlt_v500_cust = 0, dlt_nv500_pos = 0,
     dlt_v500_doc = 0
     IF (dus_curr_owner="V500"
      AND (dlts_td_tables->cnt > 0))
      dlt_v500_doc = locateval(dlt_v500_doc,1,dlts_td_tables->cnt,c.table_name,dlts_td_tables->tbl[
       dlt_v500_doc].table_name)
     ENDIF
     IF (dus_curr_owner="V500")
      IF (dlt_v500_doc > 0)
       dlt_pos = locateval(dlt_pos,1,dm2_sch_except->tcnt,t.table_name,dm2_sch_except->tbl[dlt_pos].
        tbl_name)
      ELSE
       dlt_v500_cust = locateval(dlt_v500_cust,1,dus_v500_cust->tbl_cnt,t.table_name,dus_v500_cust->
        tbl[dlt_v500_cust].table_name)
      ENDIF
     ELSE
      dlt_nv500_pos = locateval(dlt_nv500_pos,1,dus_user_list->cnt,t.owner,dus_user_list->qual[
       dlt_nv500_pos].owner_name,
       t.table_name,dus_user_list->qual[dlt_nv500_pos].table_name)
     ENDIF
     IF (((dlt_v500_doc > 0
      AND dlt_pos=0) OR (((dlt_v500_cust > 0) OR (dlt_nv500_pos > 0)) )) )
      dlt_table_cnt = (dlt_table_cnt+ 1)
      IF (mod(dlt_table_cnt,100)=1)
       stat = alterlist(tgtsch->tbl,(dlt_table_cnt+ 99))
      ENDIF
      tgtsch->tbl[dlt_table_cnt].tbl_name = t.table_name, tgtsch->tbl[dlt_table_cnt].pct_increase = t
      .pct_increase, tgtsch->tbl[dlt_table_cnt].pct_used = t.pct_used,
      tgtsch->tbl[dlt_table_cnt].pct_free = t.pct_free, tgtsch->tbl[dlt_table_cnt].
      cur_bytes_allocated = ((t.blocks+ t.empty_blocks) * block_size), tgtsch->tbl[dlt_table_cnt].
      cur_bytes_used = (t.blocks * block_size),
      tgtsch->tbl[dlt_table_cnt].tspace_name = t.tablespace_name, tgtsch->tbl[dlt_table_cnt].init_ext
       = t.initial_extent, tgtsch->tbl[dlt_table_cnt].next_ext = t.next_extent
      IF (t.next_extent=0)
       tgtsch->tbl[dlt_table_cnt].dext_mgmt = "L"
      ELSE
       tgtsch->tbl[dlt_table_cnt].dext_mgmt = "D"
      ENDIF
      tgtsch->tbl[dlt_table_cnt].row_cnt = t.num_rows
      IF ((tgtsch->tbl[dlt_table_cnt].pct_free > 60)
       AND (tgtsch->tbl[dlt_table_cnt].pct_used=0.0))
       tgtsch->tbl[dlt_table_cnt].pct_used = 1.0
      ENDIF
      tgtsch->tbl[dlt_table_cnt].max_ext = t.max_extents
      IF (dus_curr_owner="V500")
       IF (dlt_v500_doc > 0)
        tgtsch->tbl[dlt_table_cnt].reference_ind = dlts_td_tables->tbl[dlt_v500_doc].reference_ind,
        tgtsch->tbl[dlt_table_cnt].table_suffix = dlts_td_tables->tbl[dlt_v500_doc].table_suffix
       ELSE
        tgtsch->tbl[dlt_table_cnt].table_suffix = trim(cnvtstring(do.object_id))
       ENDIF
      ELSE
       tgtsch->tbl[dlt_table_cnt].table_suffix = trim(cnvtstring(do.object_id))
      ENDIF
      IF (dlt_loc_tbl != 0)
       dlt_loc_last_tbl = dlt_loc_tbl
      ENDIF
      dlt_loc_tbl = 0, dlt_loc_tbl = locateval(dlt_num,dlt_loc_last_tbl,dus_notnull_cols->tbl_cnt,c
       .table_name,dus_notnull_cols->tbl[dlt_num].tbl_name)
     ENDIF
    DETAIL
     IF (((dlt_v500_doc > 0
      AND dlt_pos=0) OR (((dlt_v500_cust > 0) OR (dlt_nv500_pos > 0)) )) )
      dlt_table_col_cnt = (dlt_table_col_cnt+ 1)
      IF (mod(dlt_table_col_cnt,50)=1)
       stat = alterlist(tgtsch->tbl[dlt_table_cnt].tbl_col,(dlt_table_col_cnt+ 49))
      ENDIF
      tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].col_name = c.column_name, tgtsch->tbl[
      dlt_table_cnt].tbl_col[dlt_table_col_cnt].col_seq = c.column_id, tgtsch->tbl[dlt_table_cnt].
      tbl_col[dlt_table_col_cnt].data_length = c.data_length,
      tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].data_type = c.data_type, tgtsch->tbl[
      dlt_table_cnt].tbl_col[dlt_table_col_cnt].virtual_column = c.virtual_column, tgtsch->tbl[
      dlt_table_cnt].tbl_col[dlt_table_col_cnt].data_default_ni = nullind(c.data_default)
      IF ((tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].data_default_ni=0))
       data_default_cleanup
      ENDIF
      IF ((tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].data_default_ni=0))
       tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].data_default = c.data_default
      ENDIF
      IF (dlt_loc_tbl > 0)
       dlt_loc_col = locateval(dlt_num,1,dus_notnull_cols->tbl[dlt_loc_tbl].col_cnt,c.column_name,
        dus_notnull_cols->tbl[dlt_loc_tbl].col[dlt_num].col_name)
      ELSE
       dlt_loc_col = 0
      ENDIF
      IF (dlt_loc_col=0)
       tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].nullable = "Y"
      ELSE
       tgtsch->tbl[dlt_table_cnt].tbl_col[dlt_table_col_cnt].nullable = "N"
      ENDIF
     ENDIF
    FOOT  c.table_name
     IF (((dlt_v500_doc > 0
      AND dlt_pos=0) OR (((dlt_v500_cust > 0) OR (dlt_nv500_pos > 0)) )) )
      stat = alterlist(tgtsch->tbl[dlt_table_cnt].tbl_col,dlt_table_col_cnt), tgtsch->tbl[
      dlt_table_cnt].tbl_col_cnt = dlt_table_col_cnt, dlt_table_col_cnt = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(tgtsch->tbl,dlt_table_cnt), tgtsch->tbl_cnt = dlt_table_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0
    AND dus_curr_owner="V500")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Table column Information Found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Table count = ",cnvtstring(tgtsch->tbl_cnt,4,0)))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_indexes(null)
   DECLARE index_cnt = i4 WITH protect, noconstant(0)
   DECLARE index_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE tablex = i4 WITH protect, noconstant(0)
   DECLARE table_found_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Retrieving and Loading Index Information."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_dba_ind_columns c,
     dm_dba_indexes_actual_stats i
    PLAN (i
     WHERE i.index_type IN ("NORMAL", "CLUSTERED", "NONCLUSTERED", "BITMAP", "FUNCTION-BASED NORMAL")
      AND i.owner=dus_curr_owner)
     JOIN (c
     WHERE i.table_name=c.table_name
      AND i.index_name=c.index_name
      AND c.index_owner=dus_curr_owner)
    ORDER BY c.table_name, c.index_name, c.column_position
    HEAD c.table_name
     index_cnt = 0, index_col_cnt = 0
     IF (c.table_name="MVJ*")
      table_found_ind = false,
      CALL echo(concat("Excluding Materialized View Table ",trim(c.table_name)))
     ELSE
      table_found_ind = false, tablex = 0, tablex = locateval(tablex,1,tgtsch->tbl_cnt,c.table_name,
       tgtsch->tbl[tablex].tbl_name)
      IF (tablex > 0)
       table_found_ind = true
      ELSE
       CALL echo(concat("Could Not Find Table ",trim(c.table_name)," For Index ",trim(i.index_name)))
      ENDIF
     ENDIF
    HEAD c.index_name
     IF (table_found_ind=true)
      index_cnt = (index_cnt+ 1)
      IF (mod(index_cnt,10)=1)
       stat = alterlist(tgtsch->tbl[tablex].ind,(index_cnt+ 9))
      ENDIF
      tgtsch->tbl[tablex].ind[index_cnt].ind_name = i.index_name, tgtsch->tbl[tablex].ind[index_cnt].
      pct_increase = i.pct_increase, tgtsch->tbl[tablex].ind[index_cnt].pct_free = i.pct_free,
      tgtsch->tbl[tablex].ind[index_cnt].tspace_name = i.tablespace_name, tgtsch->tbl[tablex].ind[
      index_cnt].index_type = i.index_type, tgtsch->tbl[tablex].ind[index_cnt].init_ext = i
      .initial_extent,
      tgtsch->tbl[tablex].ind[index_cnt].next_ext = i.next_extent
      IF (i.next_extent=0)
       tgtsch->tbl[tablex].iext_mgmt = "L"
      ELSE
       tgtsch->tbl[tablex].iext_mgmt = "D"
      ENDIF
      tgtsch->tbl[tablex].ind[index_cnt].cur_bytes_allocated = (i.leaf_blocks * block_size), tgtsch->
      tbl[tablex].ind[index_cnt].cur_bytes_used = (i.leaf_blocks * block_size)
      IF (i.uniqueness="UNIQUE")
       tgtsch->tbl[tablex].ind[index_cnt].unique_ind = 1
      ELSEIF (i.uniqueness="NONUNIQUE")
       tgtsch->tbl[tablex].ind[index_cnt].unique_ind = 0
      ENDIF
      IF (i.visibility="INVISIBLE")
       tgtsch->tbl[tablex].ind[index_cnt].visibility_change_ind = 1
      ELSEIF (i.visibility="VISIBLE")
       tgtsch->tbl[tablex].ind[index_cnt].visibility_change_ind = 0
      ENDIF
     ENDIF
    DETAIL
     IF (table_found_ind=true)
      index_col_cnt = (index_col_cnt+ 1)
      IF (mod(index_col_cnt,10)=1)
       stat = alterlist(tgtsch->tbl[tablex].ind[index_cnt].ind_col,(index_col_cnt+ 9))
      ENDIF
      tgtsch->tbl[tablex].ind[index_cnt].ind_col[index_col_cnt].col_name = c.column_name, tgtsch->
      tbl[tablex].ind[index_cnt].ind_col[index_col_cnt].col_position = c.column_position
     ENDIF
    FOOT  c.index_name
     IF (table_found_ind=true)
      stat = alterlist(tgtsch->tbl[tablex].ind[index_cnt].ind_col,index_col_cnt), tgtsch->tbl[tablex]
      .ind[index_cnt].ind_col_cnt = index_col_cnt, index_col_cnt = 0
     ENDIF
    FOOT  c.table_name
     IF (table_found_ind=true)
      stat = alterlist(tgtsch->tbl[tablex].ind,index_cnt), tgtsch->tbl[tablex].ind_cnt = index_cnt,
      index_cnt = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_constraints(null)
   SET dm_err->eproc = "Retrieving and Loading Constraint Information."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE constraint_cnt = i4 WITH protect, noconstant(0)
   DECLARE constraint_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE pk_constraint_cnt = i4 WITH protect, noconstant(0)
   DECLARE pt_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE tablex = i4 WITH protect, noconstant(0)
   DECLARE pk_searchx = i4 WITH protect, noconstant(0)
   DECLARE table_found_ind = i2 WITH private, noconstant(0)
   DECLARE fatal_error_ind = i2 WITH protect, noconstant(0)
   DECLARE fatal_error_eproc = vc WITH protect, noconstant(" ")
   DECLARE fatal_error_emsg = c132 WITH protect, noconstant(" ")
   DECLARE pk_cons_found_ind = i2 WITH private, noconstant(0)
   DECLARE dlc_recycle_bin = vc WITH protect, noconstant(" ")
   IF ((dm2_rdbms_version->level1 > 9))
    SET dlc_recycle_bin =
    "c.table_name not in (SELECT rb.object_name FROM recyclebin rb WHERE rb.type = 'TABLE')"
   ELSE
    SET dlc_recycle_bin = "1 = 1"
   ENDIF
   SELECT INTO "nl:"
    FROM dba_cons_columns cc,
     dba_constraints c
    PLAN (c
     WHERE c.constraint_type IN ("P", "U", "R")
      AND parser(dlc_recycle_bin)
      AND c.owner=dus_curr_owner)
     JOIN (cc
     WHERE cc.constraint_name=c.constraint_name
      AND cc.owner=dus_curr_owner)
    ORDER BY c.constraint_type, c.table_name, c.constraint_name,
     cc.position
    HEAD REPORT
     fatal_error_ind = false, pk_constraint_cnt = 0, index_idx = 0,
     col_idx = 0
    HEAD c.constraint_type
     row + 0
    HEAD c.table_name
     IF (fatal_error_ind=false)
      IF (c.table_name="MVJ*")
       table_found_ind = false,
       CALL echo(concat("Excluding Materialized View Table ",trim(c.table_name)))
      ELSE
       table_found_ind = false, tablex = 0, tablex = locateval(tablex,1,tgtsch->tbl_cnt,c.table_name,
        tgtsch->tbl[tablex].tbl_name)
       IF (tablex > 0)
        IF ((dm_err->debug_flag > 5))
         CALL echo(build("tablex =",tablex)),
         CALL echo(build("cons_cnt =",tgtsch->tbl[tablex].cons_cnt)),
         CALL echo(build("tbl_name =",tgtsch->tbl[tablex].tbl_name))
        ENDIF
        table_found_ind = true, constraint_cnt = tgtsch->tbl[tablex].cons_cnt, constraint_col_cnt = 0
       ELSE
        CALL echo(concat("Could Not Find Table ",trim(c.table_name)," For Constraint ",trim(c
          .constraint_name)))
       ENDIF
      ENDIF
     ENDIF
    HEAD c.constraint_name
     IF (table_found_ind=true
      AND fatal_error_ind=false)
      pt_col_cnt = 0, constraint_cnt = (constraint_cnt+ 1), stat = alterlist(tgtsch->tbl[tablex].cons,
       constraint_cnt),
      tgtsch->tbl[tablex].cons[constraint_cnt].cons_name = c.constraint_name, tgtsch->tbl[tablex].
      cons[constraint_cnt].r_constraint_name = c.r_constraint_name, tgtsch->tbl[tablex].cons[
      constraint_cnt].index_idx = 0,
      tgtsch->tbl[tablex].cons[constraint_cnt].full_cons_name = c.index_name, tgtsch->tbl[tablex].
      cons[constraint_cnt].cons_type = c.constraint_type
      IF (c.status="ENABLED")
       tgtsch->tbl[tablex].cons[constraint_cnt].status_ind = 1
      ELSEIF (c.status="DISABLED")
       tgtsch->tbl[tablex].cons[constraint_cnt].status_ind = 0
      ENDIF
      IF (c.constraint_type="P")
       index_idx = 0, index_idx = locateval(index_idx,1,tgtsch->tbl[tablex].ind_cnt,c.index_name,
        tgtsch->tbl[tablex].ind[index_idx].ind_name)
       IF (index_idx > 0)
        tgtsch->tbl[tablex].cons[constraint_cnt].index_idx = index_idx, tgtsch->tbl[tablex].ind[
        index_idx].pk_ind = constraint_cnt
       ENDIF
       pk_cons_tmp->pk_cons_cnt = (pk_cons_tmp->pk_cons_cnt+ 1), stat = alterlist(pk_cons_tmp->cons,
        pk_cons_tmp->pk_cons_cnt), pk_cons_tmp->cons[pk_cons_tmp->pk_cons_cnt].cons_name = c
       .constraint_name,
       pk_cons_tmp->cons[pk_cons_tmp->pk_cons_cnt].parent_table = c.table_name
       IF ((dm_err->debug_flag > 5))
        CALL echo(build("Add PK =",c.constraint_name," to cnt =",pk_cons_tmp->pk_cons_cnt))
       ENDIF
      ELSEIF (c.constraint_type="R")
       pk_searchx = 0, pk_searchx = locateval(pk_searchx,1,pk_cons_tmp->pk_cons_cnt,c
        .r_constraint_name,pk_cons_tmp->cons[pk_searchx].cons_name)
       IF (pk_searchx > 0)
        tgtsch->tbl[tablex].cons[constraint_cnt].parent_table = pk_cons_tmp->cons[pk_searchx].
        parent_table, tgtsch->tbl[tablex].cons[constraint_cnt].parent_table_columns = pk_cons_tmp->
        cons[pk_searchx].parent_table_columns
       ELSE
        fatal_error_ind = true, fatal_error_eproc = "Get_Constraint_Info", fatal_error_emsg = concat(
         "Could Not Find Primary Key Constraint ",trim(c.r_constraint_name),
         " For Foreign Key Constraint ",trim(c.constraint_name))
       ENDIF
      ENDIF
     ENDIF
    DETAIL
     IF (table_found_ind=true
      AND fatal_error_ind=false)
      constraint_col_cnt = (constraint_col_cnt+ 1)
      IF (mod(constraint_col_cnt,10)=1)
       stat = alterlist(tgtsch->tbl[tablex].cons[constraint_cnt].cons_col,(constraint_col_cnt+ 9))
      ENDIF
      tgtsch->tbl[tablex].cons[constraint_cnt].cons_col[constraint_col_cnt].col_name = cc.column_name,
      tgtsch->tbl[tablex].cons[constraint_cnt].cons_col[constraint_col_cnt].col_position = cc
      .position
      IF (c.constraint_type="P")
       IF (pt_col_cnt > 0)
        pk_cons_tmp->cons[pk_cons_tmp->pk_cons_cnt].parent_table_columns = concat(pk_cons_tmp->cons[
         pk_cons_tmp->pk_cons_cnt].parent_table_columns,",",cc.column_name)
       ELSE
        pk_cons_tmp->cons[pk_cons_tmp->pk_cons_cnt].parent_table_columns = cc.column_name
       ENDIF
       pt_col_cnt = (pt_col_cnt+ 1)
      ENDIF
     ENDIF
    FOOT  c.constraint_name
     IF (table_found_ind=true
      AND fatal_error_ind=false)
      stat = alterlist(tgtsch->tbl[tablex].cons[constraint_cnt].cons_col,constraint_col_cnt), tgtsch
      ->tbl[tablex].cons[constraint_cnt].cons_col_cnt = constraint_col_cnt, constraint_col_cnt = 0
     ENDIF
    FOOT  c.table_name
     IF (table_found_ind=true
      AND fatal_error_ind=false)
      tgtsch->tbl[tablex].cons_cnt = constraint_cnt, constraint_cnt = 0
     ENDIF
    FOOT  c.constraint_type
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (fatal_error_ind=true)
    SET dm_err->eproc = fatal_error_eproc
    SET dm_err->err_ind = fatal_error_ind
    CALL disp_msg(fatal_error_emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_build_ddl(null)
   SET dm_err->eproc = "Check for updt_dt_tm column conversion override row in ADMIN DM_INFO."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"))
     )
     AND d.info_name="UPDT_DT_TM_COLUMN_CONVERT_OVERRIDE"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dus_updt_dt_tm_convert_override = 1
   ENDIF
   SET dm_err->eproc = "Find DM2_ADMIN_DM_INFO override for NO_TZ_BACKFILL."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"))
     )
     AND d.info_name="NO_TZ_BACKFILL"
    DETAIL
     dus_no_tz_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Build UTC conversion DDL."
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dus_t = 1 TO tgtsch->tbl_cnt)
     SET dus_utc_col_need = 0
     SET dus_tablespace_name = tgtsch->tbl[dus_t].tspace_name
     SET dus_tbl_fnd = 0
     IF (dus_curr_owner="V500")
      SET dus_tbl_fnd = locateval(dus_tbl_fnd,1,dus_std_convert_list->tbl_cnt,tgtsch->tbl[dus_t].
       tbl_name,dus_std_convert_list->tbl[dus_tbl_fnd].table_name)
     ELSE
      SET dus_tbl_fnd = locateval(dus_tbl_fnd,1,dus_nv500_std_convert_list->cnt,dus_curr_owner,
       dus_nv500_std_convert_list->qual[dus_tbl_fnd].own_name,
       tgtsch->tbl[dus_t].tbl_name,dus_nv500_std_convert_list->qual[dus_tbl_fnd].tbl_name)
     ENDIF
     FOR (dus_tc = 1 TO tgtsch->tbl[dus_t].tbl_col_cnt)
       IF ((tgtsch->tbl[dus_t].tbl_col[dus_tc].data_type="DATE")
        AND (tgtsch->tbl[dus_t].tbl_col[dus_tc].virtual_column="NO"))
        IF ((((tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name != "UPDT_DT_TM")) OR ((tgtsch->tbl[dus_t].
        tbl_col[dus_tc].col_name="UPDT_DT_TM")
         AND dus_updt_dt_tm_convert_override=0))
         AND substring(1,9,tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name) != "UTC_TMP1_")
         SET dus_col_no_cnvt = 0
         IF (dus_tbl_fnd > 0)
          SET dus_col_fnd = 0
          IF (dus_curr_owner="V500")
           SET dus_col_fnd = locateval(dus_col_fnd,1,dus_std_convert_list->tbl[dus_tbl_fnd].col_cnt,
            tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name,dus_std_convert_list->tbl[dus_tbl_fnd].col[
            dus_col_fnd].column_name)
          ELSE
           SET dus_col_fnd = locateval(dus_col_fnd,1,dus_nv500_std_convert_list->cnt,dus_curr_owner,
            dus_nv500_std_convert_list->qual[dus_col_fnd].own_name,
            tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name,dus_nv500_std_convert_list->qual[dus_col_fnd]
            .col_name)
          ENDIF
          IF (dus_col_fnd > 0)
           IF (dus_curr_owner="V500")
            IF ((dus_std_convert_list->tbl[dus_tbl_fnd].col[dus_col_fnd].no_convert_ind=1))
             SET dus_col_no_cnvt = 1
            ENDIF
           ELSE
            IF ((dus_nv500_std_convert_list->qual[dus_col_fnd].no_convert_ind=1))
             SET dus_col_no_cnvt = 1
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         IF (dus_col_no_cnvt=0)
          SET dus_utc_col_need = 1
          SET dus_orig_col_name = tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name
          SET dus_cnvt_col_name = build("UTC_TMP1_",tgtsch->tbl[dus_t].tbl_col[dus_tc].col_seq)
          SET dus_col_fnd = 0
          SET dus_col_fnd = locateval(dus_col_fnd,1,tgtsch->tbl[dus_t].tbl_col_cnt,dus_cnvt_col_name,
           tgtsch->tbl[dus_t].tbl_col[dus_col_fnd].col_name)
          SET dm_err->eproc = concat("Creating UTC Conversion DDL for table ",tgtsch->tbl[dus_t].
           tbl_name," in Target Schema.")
          CALL disp_msg("",dm_err->logfile,0)
          IF (dus_col_fnd > 0)
           IF (dus_add_column_only_ind=0)
            IF (dus_alter_column_ddl(dus_t,dus_tc,dus_col_fnd,dus_cnvt_col_name)=0)
             RETURN(0)
            ENDIF
           ENDIF
          ELSE
           IF (dus_new_column_ddl(dus_t,dus_tc,dus_cnvt_col_name)=0)
            RETURN(0)
           ENDIF
          ENDIF
          IF (dus_add_column_only_ind=0)
           IF (dus_additional_column_ddl(dus_t,dus_tc,dus_orig_col_name,dus_cnvt_col_name)=0)
            RETURN(0)
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF (dus_add_column_only_ind=0)
      IF (dus_additional_table_ddl(dus_t)=0)
       RETURN(0)
      ENDIF
      IF (dus_utc_col_need=1)
       IF (dus_no_index_build_ind=0)
        FOR (dus_i = 1 TO tgtsch->tbl[dus_t].ind_cnt)
          IF (substring(1,8,tgtsch->tbl[dus_t].ind[dus_i].ind_name) != "ZTC_TMP1")
           SET dus_tablespace_name = tgtsch->tbl[dus_t].ind[dus_i].tspace_name
           FOR (dus_ic = 1 TO tgtsch->tbl[dus_t].ind[dus_i].ind_col_cnt)
             IF ((((tgtsch->tbl[dus_t].ind[dus_i].ind_col[dus_ic].col_name != "UPDT_DT_TM")) OR ((
             tgtsch->tbl[dus_t].ind[dus_i].ind_col[dus_ic].col_name="UPDT_DT_TM")
              AND dus_updt_dt_tm_convert_override=0)) )
              SET dus_col_idx = 0
              SET dus_col_idx = locateval(dus_col_idx,1,tgtsch->tbl[dus_t].tbl_col_cnt,tgtsch->tbl[
               dus_t].ind[dus_i].ind_col[dus_ic].col_name,tgtsch->tbl[dus_t].tbl_col[dus_col_idx].
               col_name)
              IF (dus_col_idx > 0)
               IF ((tgtsch->tbl[dus_t].tbl_col[dus_col_idx].cur_idx > 0))
                SET tgtsch->tbl[dus_t].ind[dus_i].cur_idx = 1
                SET dus_ic = tgtsch->tbl[dus_t].ind[dus_i].ind_col_cnt
               ENDIF
              ELSE
               SET dm_err->err_ind = 1
               SET dm_err->emsg = concat("column ",tgtsch->tbl[dus_t].ind[dus_i].ind_col[dus_ic].
                col_name," in index ",tgtsch->tbl[dus_t].ind[dus_i].ind_name,
                " is not found on table ",
                tgtsch->tbl[dus_t].tbl_name)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               RETURN(0)
              ENDIF
             ENDIF
           ENDFOR
           IF ((tgtsch->tbl[dus_t].ind[dus_i].cur_idx=1))
            SET tgtsch->tbl[dus_t].ind[dus_i].cur_idx = 0
            IF (substring(12,1,tgtsch->tbl[dus_t].ind[dus_i].ind_name)="_")
             SET dus_utc_ind_name = concat(substring(1,11,tgtsch->tbl[dus_t].ind[dus_i].ind_name),
              substring(13,1,tgtsch->tbl[dus_t].ind[dus_i].ind_name))
            ELSE
             SET dus_utc_ind_name = substring(1,12,tgtsch->tbl[dus_t].ind[dus_i].ind_name)
            ENDIF
            SET dus_utc_ind_name = concat("ZTC_TMP1_",tgtsch->tbl[dus_t].table_suffix,
             dus_utc_ind_name)
            SET dus_utc_ind_idx = 0
            SET dus_utc_ind_idx = locateval(dus_utc_ind_idx,1,tgtsch->tbl[dus_t].ind_cnt,
             dus_utc_ind_name,tgtsch->tbl[dus_t].ind[dus_utc_ind_idx].ind_name)
            IF (dus_utc_ind_idx > 0)
             IF (dus_existing_index_ddl(dus_t,dus_i,dus_utc_ind_idx,dus_utc_ind_name)=0)
              RETURN(0)
             ENDIF
            ELSE
             IF (dus_new_index_ddl(dus_t,dus_i,dus_utc_ind_name)=0)
              RETURN(0)
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
        IF (dus_additional_index_ddl(dus_t)=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF (dus_add_column_only_ind=0
      AND dus_no_index_build_ind=0)
      IF (dus_drop_index_ddl(dus_t)=0)
       RETURN(0)
      ENDIF
     ENDIF
     SET dus_already_coalesced_ind = 0
   ENDFOR
   IF (dus_add_column_only_ind=0)
    IF (dus_drop_rdds_trigger(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_new_column_ddl(dnc_t,dnc_tc,dnc_col_name)
   SET dm_err->eproc = "Create and Insert new utc column ddl."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dnc_new_tc = i4 WITH protect, noconstant(0)
   SET tgtsch->diff_ind = 1
   SET tgtsch->tbl[dnc_t].diff_ind = 1
   SET tgtsch->tbl[dnc_t].tbl_col_cnt = (tgtsch->tbl[dnc_t].tbl_col_cnt+ 1)
   SET dnc_new_tc = tgtsch->tbl[dnc_t].tbl_col_cnt
   SET stat = alterlist(tgtsch->tbl[dnc_t].tbl_col,dnc_new_tc)
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].col_name = dnc_col_name
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].col_seq = 0
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].data_type = tgtsch->tbl[dnc_t].tbl_col[dnc_tc].
   data_type
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].data_length = tgtsch->tbl[dnc_t].tbl_col[dnc_tc].
   data_length
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].nullable = tgtsch->tbl[dnc_t].tbl_col[dnc_tc].nullable
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].data_default = tgtsch->tbl[dnc_t].tbl_col[dnc_tc].
   data_default
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].data_default_ni = tgtsch->tbl[dnc_t].tbl_col[dnc_tc].
   data_default_ni
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].cur_idx = dnc_tc
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].new_ind = 1
   SET tgtsch->tbl[dnc_t].tbl_col[dnc_tc].cur_idx = dnc_new_tc
   SET dus_run_id = dum_utc_data->uptime_run_id
   SET dus_op_type = "ADD COLUMN"
   SET dus_obj_name = cnvtupper(dnc_col_name)
   SET dus_table_name = trim(tgtsch->tbl[dnc_t].tbl_name)
   SET dus_priority = 20
   SET dus_operation = concat("RDB ASIS (^ ALTER TABLE ",dus_curr_owner,'."',trim(dus_table_name),
    '" ADD ',
    trim(dus_obj_name)," DATE NULL ^) GO")
   IF (dus_insert_ddl_log_rec(dus_run_id,dnc_t)=0)
    RETURN(0)
   ENDIF
   IF (dus_add_column_only_ind=0)
    IF ((tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].data_default_ni=0))
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_op_type = "ALTER COLUMN DATA DEFAULT"
     SET dus_obj_name = cnvtupper(dnc_col_name)
     SET dus_table_name = trim(tgtsch->tbl[dnc_t].tbl_name)
     SET dus_priority = 40
     SET dus_operation = concat("RDB ASIS (^ ALTER TABLE ",dus_curr_owner,'."',trim(dus_table_name),
      '" MODIFY( ',
      trim(dus_obj_name)," DEFAULT ",tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].data_default,") ^) GO")
     IF (dus_insert_ddl_log_rec(dus_run_id,dnc_t)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((tgtsch->tbl[dnc_t].tbl_col[dnc_new_tc].nullable="N"))
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_op_type = "ADD CHECK CONSTRAINT"
     SET dus_obj_name = cnvtupper(dnc_col_name)
     SET dus_table_name = trim(tgtsch->tbl[dnc_t].tbl_name)
     SET dus_priority = 50
     SET dus_operation = concat("RDB ASIS (^ ALTER TABLE ",dus_curr_owner,'."',trim(dus_table_name),
      '" MODIFY(',
      trim(dus_obj_name)," NOT NULL ENABLE NOVALIDATE) ^) GO")
     IF (dus_insert_ddl_log_rec(dus_run_id,dnc_t)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_alter_column_ddl(dac_t,dac_orig_col_idx,dac_utc_col_idx,dac_col_name)
   DECLARE dacd_v500_cust = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Create and Insert alter utc column ddl."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET tgtsch->tbl[dac_t].tbl_col[dac_orig_col_idx].cur_idx = dac_utc_col_idx
   SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].cur_idx = dac_orig_col_idx
   SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].new_ind = 0
   IF ((tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].nullable != tgtsch->tbl[dac_t].tbl_col[
   dac_orig_col_idx].nullable))
    SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].diff_nullable_ind = 1
    SET tgtsch->diff_ind = 1
    SET tgtsch->tbl[dac_t].diff_ind = 1
    IF ((tgtsch->tbl[dac_t].tbl_col[dac_orig_col_idx].nullable="N")
     AND (tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].nullable="Y"))
     SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].null_to_notnull_ind = 1
    ENDIF
   ENDIF
   IF ((tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default_ni=tgtsch->tbl[dac_t].tbl_col[
   dac_orig_col_idx].data_default_ni))
    IF ((tgtsch->tbl[dac_t].tbl_col[dac_orig_col_idx].data_default != tgtsch->tbl[dac_t].tbl_col[
    dac_utc_col_idx].data_default)
     AND (tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default_ni=0))
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("DEFAULT DIFF, orig =",tgtsch->tbl[dac_t].tbl_col[dac_orig_col_idx].
        data_default))
      CALL echo(build("utc default =",tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default))
     ENDIF
     SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].diff_default_ind = 1
     SET tgtsch->diff_ind = 1
     SET tgtsch->tbl[dac_t].diff_ind = 1
     SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default = tgtsch->tbl[dac_t].tbl_col[
     dac_orig_col_idx].data_default
    ENDIF
   ELSE
    SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].diff_default_ind = 1
    SET tgtsch->diff_ind = 1
    SET tgtsch->tbl[dac_t].diff_ind = 1
    IF ((tgtsch->tbl[dac_t].tbl_col[dac_orig_col_idx].nullable="N")
     AND (tgtsch->tbl[dac_t].tbl_col[dac_orig_col_idx].data_default_ni=1))
     SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default =
     "TO_DATE('01/01/1900 00:00:00', 'MM/DD/YYYY HH24:MI:SS')"
     SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default_ni = 0
    ELSE
     SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default = tgtsch->tbl[dac_t].tbl_col[
     dac_orig_col_idx].data_default
     SET tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default_ni = tgtsch->tbl[dac_t].tbl_col[
     dac_orig_col_idx].data_default_ni
    ENDIF
   ENDIF
   IF ((tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].diff_nullable_ind=1))
    IF ((tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].null_to_notnull_ind=0))
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_op_type = "ALTER COLUMN TO NULL"
     SET dus_obj_name = trim(cnvtupper(dac_col_name))
     SET dus_table_name = trim(tgtsch->tbl[dac_t].tbl_name)
     SET dus_priority = 40
     SET dus_operation = concat("EXECUTE DM2_SET_COLUMN_TO_NULL '",trim(dus_table_name),"','",trim(
       dus_obj_name),"' GO")
    ELSEIF ((tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].null_to_notnull_ind=1))
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_obj_name = trim(cnvtupper(dac_col_name))
     SET dus_table_name = trim(tgtsch->tbl[dac_t].tbl_name)
     SET dus_priority = 50
     IF (dus_curr_owner="V500")
      SET dacd_v500_cust = locateval(dacd_v500_cust,1,dus_v500_cust->tbl_cnt,dus_table_name,
       dus_v500_cust->tbl[dacd_v500_cust].table_name)
     ENDIF
     IF (((dacd_v500_cust > 0) OR (dus_curr_owner != "V500")) )
      SET dus_op_type = "ADD CHECK CONSTRAINT"
      SET dus_operation = concat("RDB ASIS (^ ALTER TABLE ",dus_curr_owner,'."',trim(dus_table_name),
       '" MODIFY(',
       trim(dus_obj_name)," NOT NULL ENABLE NOVALIDATE) ^) GO")
     ELSE
      SET dus_op_type = "EXEC DM2_SET_CHK_CONS-NOVALIDATE"
      SET dus_operation = concat("EXECUTE DM2_SET_CHK_CONS '",trim(dus_table_name),"','",trim(
        dus_obj_name),"','NOVALIDATE' GO")
     ENDIF
    ENDIF
    IF (dus_insert_ddl_log_rec(dus_run_id,dac_t)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].diff_default_ind=1))
    SET dus_run_id = dum_utc_data->uptime_run_id
    SET dus_op_type = "ALTER COLUMN DATA DEFAULT"
    SET dus_obj_name = trim(cnvtupper(dac_col_name))
    SET dus_table_name = trim(tgtsch->tbl[dac_t].tbl_name)
    SET dus_priority = 40
    SET dus_operation = concat("RDB ASIS (^ ALTER TABLE ",dus_curr_owner,'."',dus_table_name,
     '" MODIFY(',
     dus_obj_name," DEFAULT ")
    IF ((tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].data_default_ni=1))
     SET dus_operation = concat(dus_operation," ","NULL) ^) GO")
    ELSE
     SET dus_operation = concat(dus_operation," ",tgtsch->tbl[dac_t].tbl_col[dac_utc_col_idx].
      data_default,") ^) GO")
    ENDIF
    IF (dus_insert_ddl_log_rec(dus_run_id,dac_t)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_additional_column_ddl(dacd_t,dacd_tc,dacd_col_name,dacd_utc_col_name)
   SET dm_err->eproc = "Create and Insert additional utc column related ddl."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dacd_utc2_col_name = vc WITH protect, noconstant(" ")
   SET dacd_utc2_col_name = build("UTC_TMP2_",tgtsch->tbl[dacd_t].tbl_col[dacd_tc].col_seq)
   SET dus_run_id = dum_utc_data->downtime_run_id
   SET dus_op_type = "RENAME COLUMN"
   SET dus_obj_name = cnvtupper(dacd_col_name)
   SET dus_table_name = trim(tgtsch->tbl[dacd_t].tbl_name)
   SET dus_priority = 2010
   SET dus_operation = concat("rdb asis (^alter table ",dus_curr_owner,'."',dus_table_name,
    '" rename column ',
    '"',dacd_col_name,'" to ',dacd_utc2_col_name,"^) go")
   IF (dus_insert_ddl_log_rec(dus_run_id,dacd_t)=0)
    RETURN(0)
   ENDIF
   SET dus_run_id = dum_utc_data->downtime_run_id
   SET dus_op_type = "RENAME COLUMN"
   SET dus_obj_name = trim(cnvtupper(dacd_utc_col_name))
   SET dus_table_name = trim(tgtsch->tbl[dacd_t].tbl_name)
   SET dus_priority = 2020
   SET dus_operation = concat("rdb asis (^alter table ",dus_curr_owner,'."',dus_table_name,
    '" rename column ',
    dacd_utc_col_name,' to "',dacd_col_name,'"',"^) go")
   IF (dus_insert_ddl_log_rec(dus_run_id,dacd_t)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_additional_table_ddl(dat_t)
   DECLARE dat_backfill_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Create and Insert additional table related ddl for table ",tgtsch->
    tbl[dat_t].tbl_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dat_ut_trig_name = vc WITH protect, noconstant(" ")
   SET dat_ut_trig_name = concat("UTC_CONVERT_",tgtsch->tbl[dat_t].table_suffix)
   DECLARE dat_dt_trig_name = vc WITH protect, noconstant(" ")
   SET dat_dt_trig_name = concat("UTC_REVERSE_",tgtsch->tbl[dat_t].table_suffix)
   DECLARE dat_tz_trig_name = vc WITH protect, noconstant(" ")
   SET dat_tz_trig_name = concat("UTC_CONVERT_TZ_",tgtsch->tbl[dat_t].table_suffix)
   DECLARE dat_func_name = vc WITH protect, noconstant(" ")
   SET dat_func_name = "DM2_UTC_CONVERT_PKG.DM2_UTC_CONVERT"
   DECLARE dat_c = i4 WITH protect, noconstant(0)
   DECLARE dat_pk_idx = i4 WITH protect, noconstant(0)
   DECLARE dat_std_tbl = i4 WITH protect, noconstant(0)
   DECLARE dat_std_col = i4 WITH protect, noconstant(0)
   SET dat_std_tbl = 0
   IF (dus_curr_owner="V500")
    SET dat_std_tbl = locateval(dat_std_tbl,1,dus_std_convert_list->tbl_cnt,tgtsch->tbl[dat_t].
     tbl_name,dus_std_convert_list->tbl[dat_std_tbl].table_name)
   ELSE
    SET dat_std_tbl = locateval(dat_std_tbl,1,dus_nv500_std_convert_list->cnt,dus_curr_owner,
     dus_nv500_std_convert_list->qual[dat_std_tbl].own_name,
     tgtsch->tbl[dat_t].tbl_name,dus_nv500_std_convert_list->qual[dat_std_tbl].tbl_name)
   ENDIF
   FREE RECORD dat_bf_col
   RECORD dat_bf_col(
     1 cnt = i4
     1 tz_fnd_ind = i2
     1 date_fnd_ind = i2
     1 qual[*]
       2 utc_col_name = vc
       2 orig_col_name = vc
       2 backfill_ind = i2
       2 std_cnvt_ind = i2
       2 tz_tgtsch_col_idx = i4
   )
   IF ((dm2_install_schema->process_option="UTC"))
    SET dat_backfill_ind = 1
   ENDIF
   IF (validate(dm2_migutc_backfill_setup,- (1))=1
    AND validate(dm2_migutc_backfill_setup,- (2))=1)
    SET dat_backfill_ind = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = build("dat_backfill_ind = ",dat_backfill_ind)
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   FOR (dat_tc = 1 TO tgtsch->tbl[dat_t].tbl_col_cnt)
     IF ((tgtsch->tbl[dat_t].tbl_col[dat_tc].cur_idx > 0)
      AND substring(1,9,tgtsch->tbl[dat_t].tbl_col[dat_tc].col_name)="UTC_TMP1_")
      SET dat_bf_col->date_fnd_ind = 1
      SET dat_bf_col->cnt = (dat_bf_col->cnt+ 1)
      SET stat = alterlist(dat_bf_col->qual,dat_bf_col->cnt)
      SET dat_bf_col->qual[dat_bf_col->cnt].utc_col_name = tgtsch->tbl[dat_t].tbl_col[dat_tc].
      col_name
      SET dat_bf_col->qual[dat_bf_col->cnt].orig_col_name = tgtsch->tbl[dat_t].tbl_col[tgtsch->tbl[
      dat_t].tbl_col[dat_tc].cur_idx].col_name
      SET dat_bf_col->qual[dat_bf_col->cnt].backfill_ind = 0
      IF (dat_std_tbl > 0)
       SET dat_std_col = 0
       IF (dus_curr_owner="V500")
        SET dat_std_col = locateval(dat_std_col,1,dus_std_convert_list->tbl[dat_std_tbl].col_cnt,
         dat_bf_col->qual[dat_bf_col->cnt].orig_col_name,dus_std_convert_list->tbl[dat_std_tbl].col[
         dat_std_col].column_name)
       ELSE
        SET dat_std_col = locateval(dat_std_col,1,dus_nv500_std_convert_list->cnt,dus_curr_owner,
         dus_nv500_std_convert_list->qual[dat_std_col].own_name,
         dat_bf_col->qual[dat_bf_col->cnt].orig_col_name,dus_nv500_std_convert_list->qual[dat_std_col
         ].col_name)
       ENDIF
       IF (dat_std_col > 0)
        IF (dus_curr_owner="V500")
         IF ((dus_std_convert_list->tbl[dat_std_tbl].col[dat_std_col].no_convert_ind=0))
          SET dat_bf_col->qual[dat_bf_col->cnt].std_cnvt_ind = 1
         ELSE
          SET dat_bf_col->qual[dat_bf_col->cnt].std_cnvt_ind = 2
         ENDIF
        ELSE
         IF ((dus_nv500_std_convert_list->qual[dat_std_col].no_convert_ind=0))
          SET dat_bf_col->qual[dat_bf_col->cnt].std_cnvt_ind = 1
         ELSE
          SET dat_bf_col->qual[dat_bf_col->cnt].std_cnvt_ind = 2
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (dus_no_tz_ind=0
      AND (tgtsch->tbl[dat_t].tbl_col[dat_tc].data_type="NUMBER")
      AND (tgtsch->tbl[dat_t].tbl_col[dat_tc].col_name="*_TZ")
      AND dus_curr_owner="V500")
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat("TZ column : ",tgtsch->tbl[dat_t].tbl_col[dat_tc].col_name))
      ENDIF
      SET dat_bf_col->tz_fnd_ind = 1
      SET dat_bf_col->cnt = (dat_bf_col->cnt+ 1)
      SET stat = alterlist(dat_bf_col->qual,dat_bf_col->cnt)
      SET dat_bf_col->qual[dat_bf_col->cnt].utc_col_name = tgtsch->tbl[dat_t].tbl_col[dat_tc].
      col_name
      SET dat_bf_col->qual[dat_bf_col->cnt].orig_col_name = "TZ"
      SET dat_bf_col->qual[dat_bf_col->cnt].backfill_ind = 0
      SET dat_bf_col->qual[dat_bf_col->cnt].tz_tgtsch_col_idx = dat_tc
      SET tgtsch->tbl[dat_t].tbl_col[dat_tc].new_ind = 1
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    IF ((dat_bf_col->tz_fnd_ind=1)
     AND (dat_bf_col->date_fnd_ind=0))
     CALL echo(concat("Table has TZ col with no DATE col = ",tgtsch->tbl[dat_t].tbl_name))
    ELSEIF ((dat_bf_col->tz_fnd_ind=1)
     AND (dat_bf_col->date_fnd_ind=1))
     CALL echo(concat("Table has TZ col and DATE col = ",tgtsch->tbl[dat_t].tbl_name))
    ELSEIF ((dat_bf_col->tz_fnd_ind=0)
     AND (dat_bf_col->date_fnd_ind=0))
     CALL echo(concat("Table has no TZ col and no DATE col = ",tgtsch->tbl[dat_t].tbl_name))
    ENDIF
   ENDIF
   IF ((dat_bf_col->tz_fnd_ind=1))
    DECLARE dat_tz_operation = vc WITH protect, noconstant("")
    DECLARE dat_need_tz_trig = i2 WITH protect, noconstant(0)
    SET dm_err->eproc = concat("Check trigger ",dat_tz_trig_name," row on dm2_ddl_ops_log")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log ddol
     WHERE (ddol.run_id=dum_utc_data->uptime_run_id)
      AND ddol.op_type="CREATE SQL-TRIGGER"
      AND (ddol.table_name=tgtsch->tbl[dat_t].tbl_name)
      AND ddol.obj_name=dat_tz_trig_name
      AND ddol.status="COMPLETE"
      AND ddol.owner_name=dus_curr_owner
     DETAIL
      dat_tz_operation = ddol.operation
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     FOR (dat_c = 1 TO dat_bf_col->cnt)
       IF ((dat_bf_col->qual[dat_c].orig_col_name="TZ"))
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("TZ COL = ",dat_bf_col->qual[dat_c].utc_col_name))
         CALL echo(build("operation = ",dat_tz_operation))
        ENDIF
        IF (findstring(dat_bf_col->qual[dat_c].utc_col_name,dat_tz_operation)=0)
         SET dat_need_tz_trig = 1
         SET dat_c = dat_bf_col->cnt
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     SET dat_need_tz_trig = 1
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dat_need_tz_trig = ",dat_need_tz_trig," for table ",tgtsch->tbl[dat_t].tbl_name
       ))
    ENDIF
    IF (dat_need_tz_trig=1)
     SET tgtsch->diff_ind = 1
     SET tgtsch->tbl[dat_t].diff_ind = 1
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_op_type = "CREATE SQL-TRIGGER"
     SET dus_obj_name = dat_tz_trig_name
     SET dus_table_name = trim(tgtsch->tbl[dat_t].tbl_name)
     SET dus_priority = 30
     SET dus_operation = concat("rdb asis(^create or replace trigger ",dat_tz_trig_name,
      ' before update or insert on "',dus_table_name,'" for each row when (')
     FOR (dat_c = 1 TO dat_bf_col->cnt)
       IF ((dat_bf_col->qual[dat_c].orig_col_name="TZ"))
        SET dus_operation = concat(dus_operation," new.",dat_bf_col->qual[dat_c].utc_col_name,
         " is NULL or new.",dat_bf_col->qual[dat_c].utc_col_name,
         " =0 or")
       ENDIF
     ENDFOR
     SET dus_operation = replace(dus_operation,"or",")",2)
     SET dus_operation = concat(dus_operation," begin ")
     FOR (dat_c = 1 TO dat_bf_col->cnt)
       IF ((dat_bf_col->qual[dat_c].orig_col_name="TZ"))
        SET dus_operation = concat(dus_operation," if (:new.",dat_bf_col->qual[dat_c].utc_col_name,
         " is NULL or :new.",dat_bf_col->qual[dat_c].utc_col_name,
         " =0) then :new.",dat_bf_col->qual[dat_c].utc_col_name," := ",trim(cnvtstring(curtimezonesys
           )),"; end if;  ")
       ENDIF
     ENDFOR
     SET dus_operation = concat(dus_operation,"end; ^) go")
     IF ((dm_err->debug_flag > 0))
      CALL echo(dus_operation)
     ENDIF
     IF (dus_insert_ddl_log_rec(dus_run_id,dat_t)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dat_bf_col->date_fnd_ind=1))
    DECLARE dat_need_cnvt_trig = i2 WITH protect, noconstant(0)
    DECLARE dat_trig_operation = vc WITH protect, noconstant("")
    SET dm_err->eproc = concat("Check trigger ",dat_ut_trig_name," row on dm2_ddl_ops_log")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log ddol
     WHERE (ddol.run_id=dum_utc_data->uptime_run_id)
      AND ddol.op_type="CREATE SQL-TRIGGER"
      AND (ddol.table_name=tgtsch->tbl[dat_t].tbl_name)
      AND ddol.obj_name=dat_ut_trig_name
      AND ddol.status="COMPLETE"
      AND ddol.owner_name=dus_curr_owner
     DETAIL
      dat_trig_operation = ddol.operation
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     FOR (dat_c = 1 TO dat_bf_col->cnt)
       IF ((dat_bf_col->qual[dat_c].orig_col_name != "TZ"))
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("UTC COL = ",dat_bf_col->qual[dat_c].utc_col_name))
         CALL echo(build("operation = ",dat_trig_operation))
        ENDIF
        IF (findstring(dat_bf_col->qual[dat_c].utc_col_name,dat_trig_operation)=0)
         SET dat_need_cnvt_trig = 1
         SET dat_c = dat_bf_col->cnt
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     SET dat_need_cnvt_trig = 1
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dat_need_cnvt_trig = ",dat_need_cnvt_trig," for table ",tgtsch->tbl[dat_t].
       tbl_name))
    ENDIF
    IF (dat_need_cnvt_trig=1)
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_op_type = "CREATE SQL-TRIGGER"
     SET dus_obj_name = dat_ut_trig_name
     SET dus_table_name = trim(tgtsch->tbl[dat_t].tbl_name)
     SET dus_priority = 30
     CALL dus_build_trigger(dat_ut_trig_name,dat_func_name,dat_t,dus_operation)
     IF (dus_insert_ddl_log_rec(dus_run_id,dat_t)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dat_func_name = "DM2_UTC_REVERSE_PKG.DM2_UTC_REVERSE"
    SET dus_run_id = dum_utc_data->downtime_run_id
    SET dus_op_type = "CREATE SQL-TRIGGER"
    SET dus_obj_name = dat_dt_trig_name
    SET dus_table_name = trim(tgtsch->tbl[dat_t].tbl_name)
    SET dus_priority = 2030
    CALL dus_build_trigger(dat_dt_trig_name,dat_func_name,dat_t,dus_operation)
    IF (dus_insert_ddl_log_rec(dus_run_id,dat_t)=0)
     RETURN(0)
    ENDIF
    SET dus_run_id = dum_utc_data->downtime_run_id
    SET dus_op_type = "DROP TRIGGER"
    SET dus_obj_name = dat_ut_trig_name
    SET dus_table_name = trim(tgtsch->tbl[dat_t].tbl_name)
    SET dus_priority = 1005
    SET dus_operation = concat("rdb asis (^drop trigger ",dus_obj_name,"^) go")
    IF (dus_insert_ddl_log_rec(dus_run_id,dat_t)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dat_backfill_ind=1)
    DECLARE dat_bf_operation = vc WITH protect, noconstant(" ")
    DECLARE dat_need_backfill = i2 WITH protect, noconstant(0)
    DECLARE dat_backfill_method = vc WITH protect, noconstant(" ")
    DECLARE dat_tbl_col_idx = i4 WITH protect, noconstant(0)
    IF ((dat_bf_col->cnt > 0))
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dat_bf_col)
     ENDIF
     SET dm_err->eproc = "Check UTC COLUMN/RANGE BACKFILL row on dm2_ddl_ops_log"
     SELECT INTO "nl:"
      FROM dm2_ddl_ops_log ddol
      WHERE (ddol.run_id=dum_utc_data->uptime_run_id)
       AND ddol.op_type="UTC*BACKFILL"
       AND (ddol.table_name=tgtsch->tbl[dat_t].tbl_name)
       AND ddol.status="COMPLETE"
       AND ddol.owner_name=dus_curr_owner
      DETAIL
       dat_bf_operation = concat(dat_bf_operation,ddol.operation)
      WITH nocounter, maxqual(ddol,1)
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      FOR (dat_c = 1 TO dat_bf_col->cnt)
        IF (findstring(dat_bf_col->qual[dat_c].utc_col_name,dat_bf_operation) > 0)
         SET dat_bf_col->qual[dat_c].backfill_ind = 1
         IF ((dat_bf_col->qual[dat_c].orig_col_name="TZ")
          AND (dat_bf_col->qual[dat_c].tz_tgtsch_col_idx > 0))
          SET tgtsch->tbl[dat_t].tbl_col[dat_bf_col->qual[dat_c].tz_tgtsch_col_idx].new_ind = 0
         ENDIF
        ELSE
         SET dat_need_backfill = 1
        ENDIF
      ENDFOR
     ELSE
      SET dat_need_backfill = 1
     ENDIF
    ENDIF
    IF (dat_need_backfill=1)
     FOR (dat_pk_idx = 1 TO tgtsch->tbl[dat_t].cons_cnt)
       IF ((tgtsch->tbl[dat_t].cons[dat_pk_idx].cons_type="P")
        AND (tgtsch->tbl[dat_t].cons[dat_pk_idx].cons_col_cnt=1))
        SET dat_tbl_col_idx = 0
        SET dat_tbl_col_idx = locateval(dat_tbl_col_idx,1,tgtsch->tbl[dat_t].tbl_col_cnt,tgtsch->tbl[
         dat_t].cons[dat_pk_idx].cons_col[1].col_name,tgtsch->tbl[dat_t].tbl_col[dat_tbl_col_idx].
         col_name)
        IF (dat_tbl_col_idx=0)
         SET dm_err->eproc =
         "Finding pk table column in Target Schema in prep for backfill type detection"
         SET dm_err->emsg = concat("Could not find column:",tgtsch->tbl[dat_t].cons[dat_pk_idx].
          cons_col[1].col_name," for table ",tgtsch->tbl[dat_t].tbl_name," in Target Schema.")
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->eproc,dm_err->logfile,1)
         RETURN(0)
        ELSE
         IF ((tgtsch->tbl[dat_t].tbl_col[dat_tbl_col_idx].data_type IN ("NUMBER", "FLOAT")))
          SET dat_backfill_method = "RANGE"
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF (dat_backfill_method="RANGE")
      IF (dus_column_backfill_range_ddl(dat_t,tgtsch->tbl[dat_t].tbl_col[dat_tbl_col_idx].col_name)=0
      )
       RETURN(0)
      ENDIF
     ELSE
      IF (dus_column_backfill_ddl(dat_t)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
    IF (cnvtupper(tgtsch->tbl[dat_t].tbl_name)="CODE_VALUE"
     AND dus_curr_owner="V500")
     SET dus_run_id = dum_utc_data->downtime_run_id
     SET dus_op_type = "DROP DEFAULT TRIGGER"
     SET dus_obj_name = "TRG_0619_DR_UPDT_DEL"
     SET dus_table_name = "CODE_VALUE"
     SET dus_priority = 1010
     SET dus_operation = concat("rdb asis (^drop trigger ",dus_obj_name,"^) go")
     IF (dus_insert_ddl_log_rec(dus_run_id,dat_t)=0)
      RETURN(0)
     ENDIF
     SET dus_run_id = dum_utc_data->downtime_run_id
     SET dus_op_type = "UPDATE DEFAULT ROW"
     SET dus_obj_name = "CODE_VALUE"
     SET dus_table_name = "CODE_VALUE"
     SET dus_priority = 1015
     SET dus_operation = "rdb update CODE_VALUE set"
     FOR (dat_tc = 1 TO dat_bf_col->cnt)
       IF (dat_tc=1)
        SET dus_operation = concat(dus_operation," ",dat_bf_col->qual[dat_tc].utc_col_name," = nvl(",
         dat_bf_col->qual[dat_tc].utc_col_name,
         ", ",dat_bf_col->qual[dat_tc].orig_col_name,")")
       ELSE
        SET dus_operation = concat(dus_operation,", ",dat_bf_col->qual[dat_tc].utc_col_name,
         " = nvl( ",dat_bf_col->qual[dat_tc].utc_col_name,
         ", ",dat_bf_col->qual[dat_tc].orig_col_name,")")
       ENDIF
     ENDFOR
     SET dus_operation = concat(dus_operation," ","where code_value = 0 go")
     IF (dus_insert_ddl_log_rec(dus_run_id,dat_t)=0)
      RETURN(0)
     ENDIF
     SET dus_run_id = dum_utc_data->downtime_run_id
     SET dus_op_type = "EXECUTE DM2_ADD_DEFAULT_ROW"
     SET dus_obj_name = "CODE_VALUE"
     SET dus_table_name = "CODE_VALUE"
     SET dus_priority = 1020
     SET dus_operation = "EXECUTE DM2_ADD_DEFAULT_ROWS 'CODE_VALUE' GO"
     IF (dus_insert_ddl_log_rec(dus_run_id,dat_t)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_column_backfill_range_ddl(par_tgtidx,pk_col_name)
   SET dm_err->eproc = build("***> DCD_COLUMN_BACKFILL_RANGE_DDL <***")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dctdidx = i4 WITH protect, noconstant(0)
   DECLARE dctcbd_updt_task_col = i2 WITH protect, noconstant(0)
   DECLARE dctrbf_nncolcnt = i4 WITH protect, noconstant(0)
   DECLARE dcbr_range_increment = f8 WITH protect, noconstant(0.0)
   DECLARE dcbr_range_groups = f8 WITH protect, noconstant(0.0)
   DECLARE dcbr_pk_max = f8 WITH protect, noconstant(0.0)
   DECLARE dcbr_pk_min = f8 WITH protect, noconstant(0.0)
   DECLARE dcbr_commit_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcbr_loop = i4 WITH protect, noconstant(0)
   DECLARE dcbr_row_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE dcbr_beg_ddl = vc WITH protect, noconstant(" ")
   DECLARE dcbr_end_ddl = vc WITH protect, noconstant(" ")
   DECLARE dcbr_upd_str = vc WITH protect, noconstant(" ")
   DECLARE dcbr_where_str = vc WITH protect, noconstant(" ")
   DECLARE dcbr_max_min_str = vc WITH protect, noconstant(" ")
   DECLARE dcbr_pk_str = vc WITH protect, noconstant(" ")
   DECLARE dcbr_declare_str = vc WITH protect, noconstant(" ")
   DECLARE dcbr_rng_beg_value = f8 WITH protect, noconstant(0.0)
   DECLARE dcbr_rng_end_value = f8 WITH protect, noconstant(0.0)
   SET dcbr_row_cnt = tgtsch->tbl[par_tgtidx].row_cnt
   IF ((dm2_db_options->cursor_commit_cnt="NOT SET"))
    SET dcbr_commit_cnt = 10000
   ELSE
    SET dcbr_commit_cnt = cnvtint(dm2_db_options->cursor_commit_cnt)
   ENDIF
   SET dm_err->eproc = concat("Getting Min value for ",pk_col_name," on table:",tgtsch->tbl[
    par_tgtidx].tbl_name)
   IF (dm2_push_cmd(concat("select into 'nl:' pk_val_min = min(",pk_col_name,") from ",tgtsch->tbl[
     par_tgtidx].tbl_name," detail dcbr_pk_min = pk_val_min with nocounter go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Getting Max value for ",pk_col_name," on table:",tgtsch->tbl[
    par_tgtidx].tbl_name)
   IF (dm2_push_cmd(concat("select into 'nl:' pk_val_max = max(",trim(pk_col_name),") from ",trim(
      tgtsch->tbl[par_tgtidx].tbl_name)," detail dcbr_pk_max = pk_val_max with nocounter go"),1)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("min:",dcbr_pk_min))
    CALL echo(build("max:",dcbr_pk_max))
    CALL echo(tgtsch->tbl[par_tgtidx].tbl_name)
   ENDIF
   SET dcbr_range_groups = cnvtreal(dm2_db_options->cbf_maxrangegroups)
   IF (ceil(((dcbr_pk_max - dcbr_pk_min)/ dcbr_commit_cnt)) < dcbr_range_groups)
    SET dcbr_range_groups = ceil(((dcbr_pk_max - dcbr_pk_min)/ dcbr_commit_cnt))
   ENDIF
   IF (dcbr_range_groups=0)
    SET dcbr_range_groups = 1
   ENDIF
   SET dcbr_range_increment = round(((dcbr_pk_max - dcbr_pk_min)/ dcbr_range_groups),0)
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("Range groups:",dcbr_range_groups))
    CALL echo(build("Range increment:",dcbr_range_increment))
    CALL echo(build("Commit cnt:",dcbr_commit_cnt))
   ENDIF
   SET dcbr_beg_ddl = concat("l_unitofwork    NUMBER := ",build(dcbr_commit_cnt),"; ",
    "l_updt_start    NUMBER := 0;","l_updt_end      NUMBER := 0; ",
    "l_updt_uow      NUMBER := 0;","l_finished      PLS_INTEGER := 0; ",
    "l_maxretry      PLS_INTEGER := 3; ","l_retries       PLS_INTEGER := 0; ",
    "l_err_msg       varchar2(150); ",
    "ROLLBACK_SEGMENT_ERROR EXCEPTION; ",
    "PRAGMA          exception_init(ROLLBACK_SEGMENT_ERROR, -1562); begin ")
   SET dcbr_upd_str = concat(" l_updt_uow := l_unitofwork; ","l_updt_start := l_range_start;",
    "l_updt_end := l_range_start + l_updt_uow; ","WHILE ( l_finished = 0 )"," LOOP ",
    'BEGIN UPDATE "',dus_curr_owner,'"."',trim(tgtsch->tbl[par_tgtidx].tbl_name),'" a set  ')
   SET dctcbd_updt_task_col = 0
   SET dctrbf_nncolcnt = 0
   FOR (dctdidx = 1 TO tgtsch->tbl[par_tgtidx].tbl_col_cnt)
     IF ((tgtsch->tbl[par_tgtidx].tbl_col[dctdidx].col_name="UPDT_TASK")
      AND dus_curr_owner="V500")
      SET dctcbd_updt_task_col = 1
     ENDIF
   ENDFOR
   FOR (dctdidx = 1 TO dat_bf_col->cnt)
     IF ((dat_bf_col->qual[dctdidx].backfill_ind=0))
      IF ((((dat_bf_col->qual[dctdidx].orig_col_name != "TZ")) OR (dus_curr_owner != "V500")) )
       IF ((dm_err->debug_flag > 2))
        CALL echo(concat("Not null column:",dat_bf_col->qual[dctdidx].utc_col_name))
       ENDIF
       SET dctrbf_nncolcnt = (dctrbf_nncolcnt+ 1)
       IF (dctrbf_nncolcnt=1)
        IF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=1))
         SET dcbr_upd_str = concat(dcbr_upd_str," a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
          " nvl( a.",
          dat_bf_col->qual[dctdidx].utc_col_name,", dm2_utc_convert_pkg.dm2_utc_convert(1, a.",
          dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=0))
         SET dcbr_upd_str = concat(dcbr_upd_str," a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
          " nvl( a.",
          dat_bf_col->qual[dctdidx].utc_col_name,",dm2_utc_convert_pkg.dm2_utc_convert(0, a.",
          dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=2))
         SET dcbr_upd_str = concat(dcbr_upd_str," a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
          " nvl( a.",
          dat_bf_col->qual[dctdidx].utc_col_name,",a.",dat_bf_col->qual[dctdidx].orig_col_name,")")
        ENDIF
       ELSE
        IF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=1))
         SET dcbr_upd_str = concat(dcbr_upd_str," , a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
          " nvl( a.",
          dat_bf_col->qual[dctdidx].utc_col_name,",dm2_utc_convert_pkg.dm2_utc_convert(1, a.",
          dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=0))
         SET dcbr_upd_str = concat(dcbr_upd_str," , a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
          " nvl( a.",
          dat_bf_col->qual[dctdidx].utc_col_name,",dm2_utc_convert_pkg.dm2_utc_convert(0, a.",
          dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=2))
         SET dcbr_upd_str = concat(dcbr_upd_str," , a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
          " nvl( a.",
          dat_bf_col->qual[dctdidx].utc_col_name,",a.",dat_bf_col->qual[dctdidx].orig_col_name,")")
        ENDIF
       ENDIF
       IF (dctrbf_nncolcnt=1)
        IF ((dat_bf_col->tz_fnd_ind=0))
         SET dcbr_where_str = concat(dcbr_where_str," and ( ( a.",dat_bf_col->qual[dctdidx].
          utc_col_name," is null and a.",dat_bf_col->qual[dctdidx].orig_col_name,
          " is not null) ")
        ELSE
         SET dcbr_where_str = concat(dcbr_where_str," and ( ( a.",dat_bf_col->qual[dctdidx].
          utc_col_name," is null) ")
        ENDIF
       ELSE
        IF ((dat_bf_col->tz_fnd_ind=0))
         SET dcbr_where_str = concat(dcbr_where_str," or (a.",dat_bf_col->qual[dctdidx].utc_col_name,
          " is null and a.",dat_bf_col->qual[dctdidx].orig_col_name,
          " is not null) ")
        ELSE
         SET dcbr_where_str = concat(dcbr_where_str," or (a.",dat_bf_col->qual[dctdidx].utc_col_name,
          " is null) ")
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dctdidx = 1 TO dat_bf_col->cnt)
     IF ((dat_bf_col->qual[dctdidx].backfill_ind=0))
      IF ((dat_bf_col->qual[dctdidx].orig_col_name="TZ")
       AND dus_curr_owner="V500")
       IF ((dm_err->debug_flag > 2))
        CALL echo(concat("TZ column:",dat_bf_col->qual[dctdidx].utc_col_name))
       ENDIF
       IF (dctrbf_nncolcnt > 0)
        SET dcbr_upd_str = concat(dcbr_upd_str," , a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
         trim(cnvtstring(curtimezonesys)))
       ELSE
        SET dcbr_upd_str = concat(dcbr_upd_str," a.",dat_bf_col->qual[dctdidx].utc_col_name," = ",
         trim(cnvtstring(curtimezonesys)))
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (dctcbd_updt_task_col=1)
    SET dcbr_upd_str = concat(dcbr_upd_str," , a.UPDT_TASK = ",cnvtstring(dm2_install_schema->
      dm2_updt_task_value))
   ENDIF
   IF ((tgtsch->tbl[par_tgtidx].tbl_name="CODE_VALUE")
    AND dus_curr_owner="V500")
    SET dcbr_upd_str = concat(dcbr_upd_str," where a.",pk_col_name,
     " between l_updt_start and l_updt_end and a.",pk_col_name,
     "> 0")
   ELSE
    SET dcbr_upd_str = concat(dcbr_upd_str," where a.",pk_col_name,
     " between l_updt_start and l_updt_end")
   ENDIF
   SET dcbr_end_ddl = concat(" ; ","if l_updt_end >= l_range_end then ","l_finished := 1; ","else ",
    " commit; ",
    "l_updt_start := l_updt_end + 1; ","l_updt_end := l_updt_start + l_updt_uow ; ","end if; ",
    "EXCEPTION ","WHEN ROLLBACK_SEGMENT_ERROR then ",
    "ROLLBACK; ","l_retries := l_retries + 1; ","IF l_retries > l_maxretry then ",
    "l_err_msg:=substr(sqlerrm, 1, 150);  ","raise_application_error(-20555, l_err_msg); ",
    "  l_finished := 1; ","END IF; ","l_updt_uow := l_updt_uow / 2; ",
    "l_updt_end := l_updt_start + l_updt_uow; ","WHEN OTHERS then ",
    "ROLLBACK; ","l_err_msg:=substr(sqlerrm, 1, 150);  ",
    "raise_application_error(-20555, l_err_msg); ","l_finished := 1; ","END; ",
    "END LOOP; ","COMMIT; ","END;   ")
   SET dcbr_rng_beg_value = dcbr_pk_min
   SET dcbr_rng_end_value = (dcbr_rng_beg_value+ dcbr_range_increment)
   SET tgtsch->tbl[par_tgtidx].row_cnt = dcbr_range_increment
   FOR (dcbr_loop = 1 TO cnvtint(dcbr_range_groups))
     IF (dcbr_range_groups=1)
      SET dcbr_declare_str = concat("declare ","l_range_start   NUMBER := 0; ",
       "l_range_end     NUMBER := 0; ")
      SET dcbr_max_min_str = ""
      SET dcbr_max_min_str = concat(" IF l_range_start = 0 THEN ","  SELECT nvl(MIN(",pk_col_name,
       "),0) INTO l_range_start ",'  FROM "',
       dus_curr_owner,'"."',trim(tgtsch->tbl[par_tgtidx].tbl_name),'" ; ',"  END IF; ")
      SET dcbr_max_min_str = concat(dcbr_max_min_str," IF l_range_end = 0 THEN ","  SELECT nvl(Max(",
       pk_col_name,"),0) INTO l_range_end ",
       '  FROM "',dus_curr_owner,'"."',trim(tgtsch->tbl[par_tgtidx].tbl_name),'" ; ',
       "  END IF; ")
     ELSE
      IF (dcbr_loop=1)
       SET dcbr_declare_str = concat("declare ","l_range_start   NUMBER := 0; ",
        "l_range_end     NUMBER := ",build(dcbr_rng_end_value),"; ")
       SET dcbr_max_min_str = ""
       SET dcbr_max_min_str = concat(" IF l_range_start = 0 THEN ","  SELECT nvl(MIN(",pk_col_name,
        "),0) INTO l_range_start ",'  FROM "',
        dus_curr_owner,'"."',trim(tgtsch->tbl[par_tgtidx].tbl_name),'" ; ',"  END IF; ")
      ELSEIF (dcbr_loop=cnvtint(dcbr_range_groups))
       SET dcbr_declare_str = concat("declare ","l_range_start   NUMBER := ",build(dcbr_rng_beg_value
         ),"; ","l_range_end     NUMBER := 0;")
       SET dcbr_max_min_str = ""
       SET dcbr_max_min_str = concat(" IF l_range_end = 0 THEN ","  SELECT nvl(Max(",pk_col_name,
        "),0) INTO l_range_end ",'  FROM "',
        dus_curr_owner,'"."',trim(tgtsch->tbl[par_tgtidx].tbl_name),'" ; ',"  END IF; ")
      ELSE
       SET dcbr_declare_str = concat("declare ","l_range_start   NUMBER := ",build(dcbr_rng_beg_value
         ),"; ","l_range_end  NUMBER := ",
        build(dcbr_rng_end_value),"; ")
      ENDIF
     ENDIF
     SET dus_operation = concat("RDB ASIS(^",dcbr_declare_str," ",dcbr_beg_ddl," ",
      dcbr_max_min_str," ",dcbr_upd_str,dcbr_where_str,")",
      dcbr_end_ddl,"^) go")
     SET dcbr_max_min_str = " "
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_op_type = "UTC RANGE BACKFILL"
     SET dus_priority = 60
     SET dus_obj_name = concat("RANGE_BACKFILL(GROUP",trim(cnvtstring(dcbr_loop)),")")
     SET dus_table_name = trim(cnvtupper(tgtsch->tbl[par_tgtidx].tbl_name))
     IF (dus_insert_ddl_log_rec(dus_run_id,par_tgtidx) != 1)
      RETURN(0)
     ENDIF
     SET dcbr_rng_beg_value = (dcbr_rng_end_value+ 1)
     SET dcbr_rng_end_value = (dcbr_rng_beg_value+ dcbr_range_increment)
   ENDFOR
   SET tgtsch->tbl[par_tgtidx].row_cnt = dcbr_row_cnt
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_column_backfill_ddl(par_tgtidx)
   SET dm_err->eproc = build("***> DCD_COLUMN_BACKFILL_DDL <***")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dctdidx = i4 WITH protect, noconstant(0)
   DECLARE dctd_firstcol = i2 WITH protect, noconstant(0)
   DECLARE dctdop = vc WITH protect, noconstant(" ")
   DECLARE dctcbd_updt_task_col = i2 WITH protect, noconstant(0)
   SET dctdop = concat(' DECLARE CURSOR C1 is select rowid from "',dus_curr_owner,'"."',tgtsch->tbl[
    par_tgtidx].tbl_name,'"')
   SET dctd_firstcol = 1
   SET dctcbd_updt_task_col = 0
   FOR (dctdidx = 1 TO tgtsch->tbl[par_tgtidx].tbl_col_cnt)
     IF ((tgtsch->tbl[par_tgtidx].tbl_col[dctdidx].col_name="UPDT_TASK")
      AND dus_curr_owner="V500")
      SET dctcbd_updt_task_col = 1
     ENDIF
   ENDFOR
   FOR (dctdidx = 1 TO dat_bf_col->cnt)
     IF ((dat_bf_col->qual[dctdidx].backfill_ind=0))
      IF ((((dat_bf_col->qual[dctdidx].orig_col_name != "TZ")) OR (dus_curr_owner != "V500")) )
       IF (dctd_firstcol=1)
        SET dctd_firstcol = 0
        IF ((dat_bf_col->tz_fnd_ind=0))
         SET dctdop = concat(dctdop," where (",dat_bf_col->qual[dctdidx].utc_col_name," is null")
         SET dctdop = concat(dctdop," and ",dat_bf_col->qual[dctdidx].orig_col_name," is not null)")
        ELSE
         SET dctdop = concat(dctdop," where (",dat_bf_col->qual[dctdidx].utc_col_name," is null)")
        ENDIF
       ELSE
        IF ((dat_bf_col->tz_fnd_ind=0))
         SET dctdop = concat(dctdop," or (",dat_bf_col->qual[dctdidx].utc_col_name," is null")
         SET dctdop = concat(dctdop," and ",dat_bf_col->qual[dctdidx].orig_col_name," is not null)")
        ELSE
         SET dctdop = concat(dctdop," or (",dat_bf_col->qual[dctdidx].utc_col_name," is null)")
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SET dctdop = concat(dctdop,"; "," finished number:=0; "," commit_cnt number:=0; ",
    " err_msg varchar2(150); ",
    " snapshot_too_old EXCEPTION; "," PRAGMA exception_init(snapshot_too_old, -1555); "," BEGIN ",
    " WHILE (finished=0) LOOP ","  finished:=1;  ",
    "  BEGIN ","  FOR C1REC in C1 LOOP ",'   update "',dus_curr_owner,'"."',
    tgtsch->tbl[par_tgtidx].tbl_name,'" set')
   SET dctd_firstcol = 1
   FOR (dctdidx = 1 TO dat_bf_col->cnt)
     IF ((dat_bf_col->qual[dctdidx].backfill_ind=0))
      IF ((((dat_bf_col->qual[dctdidx].orig_col_name != "TZ")) OR (dus_curr_owner != "V500")) )
       IF (dctd_firstcol=1)
        SET dctd_firstcol = 0
        IF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=1))
         SET dctdop = concat(dctdop," ",dat_bf_col->qual[dctdidx].utc_col_name," = nvl(",dat_bf_col->
          qual[dctdidx].utc_col_name,
          ",dm2_utc_convert_pkg.dm2_utc_convert(1, ",dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=0))
         SET dctdop = concat(dctdop," ",dat_bf_col->qual[dctdidx].utc_col_name," = nvl(",dat_bf_col->
          qual[dctdidx].utc_col_name,
          ",dm2_utc_convert_pkg.dm2_utc_convert(0, ",dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=2))
         SET dctdop = concat(dctdop," ",dat_bf_col->qual[dctdidx].utc_col_name," = nvl(",dat_bf_col->
          qual[dctdidx].utc_col_name,
          ",",dat_bf_col->qual[dctdidx].orig_col_name,")")
        ENDIF
       ELSE
        IF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=1))
         SET dctdop = concat(dctdop,", ",dat_bf_col->qual[dctdidx].utc_col_name," = nvl(",dat_bf_col
          ->qual[dctdidx].utc_col_name,
          ", dm2_utc_convert_pkg.dm2_utc_convert(1, ",dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=0))
         SET dctdop = concat(dctdop,", ",dat_bf_col->qual[dctdidx].utc_col_name," = nvl(",dat_bf_col
          ->qual[dctdidx].utc_col_name,
          ", dm2_utc_convert_pkg.dm2_utc_convert(0, ",dat_bf_col->qual[dctdidx].orig_col_name,"))")
        ELSEIF ((dat_bf_col->qual[dctdidx].std_cnvt_ind=2))
         SET dctdop = concat(dctdop,", ",dat_bf_col->qual[dctdidx].utc_col_name," = nvl(",dat_bf_col
          ->qual[dctdidx].utc_col_name,
          ", ",dat_bf_col->qual[dctdidx].orig_col_name,")")
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dctdidx = 1 TO dat_bf_col->cnt)
     IF ((dat_bf_col->qual[dctdidx].backfill_ind=0))
      IF ((dat_bf_col->qual[dctdidx].orig_col_name="TZ")
       AND dus_curr_owner="V500")
       IF (dctd_firstcol=0)
        SET dctdop = concat(dctdop,", ",dat_bf_col->qual[dctdidx].utc_col_name," = ",trim(cnvtstring(
           curtimezonesys)))
       ELSE
        SET dctdop = concat(dctdop," ",dat_bf_col->qual[dctdidx].utc_col_name," = ",trim(cnvtstring(
           curtimezonesys)))
        SET dctd_firstcol = 0
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (dctcbd_updt_task_col=1)
    IF (dctd_firstcol=0)
     SET dctdop = concat(dctdop,", ")
    ENDIF
    SET dctdop = build(dctdop," UPDT_TASK = ",dm2_install_schema->dm2_updt_task_value,"  ")
   ENDIF
   SET dctdop = concat(dctdop," where rowid = c1rec.rowid; "," commit_cnt := commit_cnt+1;",
    "  IF (commit_cnt = ",dm2_db_options->cursor_commit_cnt,
    " ) THEN","   commit;","   commit_cnt := 0;","  END IF;"," END LOOP; ",
    " EXCEPTION "," WHEN snapshot_too_old then ","  finished:=0; "," WHEN OTHERS then ",
    "  rollback; ",
    "  err_msg:=substr(sqlerrm, 1, 150); ","  raise_application_error(-20555, err_msg); "," END;  ",
    " END LOOP;  "," IF (commit_cnt > 0) THEN",
    "  commit;"," END IF;"," END; ")
   SET dus_operation = concat("RDB ASIS (^",dctdop,"^) GO")
   SET dus_op_type = "UTC COLUMN BACKFILL"
   IF (cnvtupper(tgtsch->tbl[par_tgtidx].tbl_name)="DM_INFO")
    SET dus_priority = 59
   ELSE
    SET dus_priority = 60
   ENDIF
   SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[par_tgtidx].tbl_name))
   SET dus_table_name = trim(cnvtupper(tgtsch->tbl[par_tgtidx].tbl_name))
   SET dus_run_id = dum_utc_data->uptime_run_id
   IF (dus_insert_ddl_log_rec(dus_run_id,par_tgtidx) != 1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_build_trigger(dbt_trig_name,dbt_func_name,dbt_t,dbt_operation)
   SET dm_err->eproc = concat("Build trigger ",dbt_trig_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dbt_utc_col_name = vc WITH protect, noconstant(" ")
   DECLARE dbt_tc = i4 WITH protect, noconstant(0)
   SET dbt_operation = concat("rdb asis(^create or replace trigger ",dbt_trig_name,
    " before update or insert of ")
   IF (dbt_trig_name="UTC_CONVERT_4859")
    SET dbt_operation = concat(dbt_operation,' "ABS_BIRTH_DT_TM",')
   ENDIF
   FOR (dbt_tc = 1 TO dat_bf_col->cnt)
     IF ((((dat_bf_col->qual[dbt_tc].orig_col_name != "TZ")) OR (dus_curr_owner != "V500")) )
      SET dbt_operation = concat(dbt_operation,' "',dat_bf_col->qual[dbt_tc].orig_col_name,'", ')
     ENDIF
   ENDFOR
   SET dbt_operation = replace(dus_operation,",","",2)
   SET dbt_operation = concat(dbt_operation,' on "',dus_curr_owner,'"."',tgtsch->tbl[dbt_t].tbl_name,
    '" for each row begin ')
   IF (dbt_trig_name="UTC_CONVERT_4859")
    SET dbt_operation = concat(dbt_operation,
     " if nvl(to_char(:new.ABS_BIRTH_DT_TM),'DM2NULLVAL') = 'DM2NULLVAL' ",
     "then :new.ABS_BIRTH_DT_TM := :new.BIRTH_DT_TM; end if;")
   ENDIF
   FOR (dbt_tc = 1 TO dat_bf_col->cnt)
     IF ((((dat_bf_col->qual[dbt_tc].orig_col_name != "TZ")) OR (dus_curr_owner != "V500")) )
      IF (findstring("CONVERT",dbt_trig_name) > 0)
       SET dbt_utc_col_name = dat_bf_col->qual[dbt_tc].utc_col_name
      ELSE
       SET dbt_utc_col_name = replace(dat_bf_col->qual[dbt_tc].utc_col_name,"1","2",1)
      ENDIF
      SET dbt_operation = concat(dbt_operation,":new.",dbt_utc_col_name," := ")
      IF ((dat_bf_col->qual[dbt_tc].std_cnvt_ind=1))
       SET dbt_operation = concat(dbt_operation,dbt_func_name,'(1, :new."',dat_bf_col->qual[dbt_tc].
        orig_col_name,'"); ')
      ELSEIF ((dat_bf_col->qual[dbt_tc].std_cnvt_ind=0))
       SET dbt_operation = concat(dbt_operation,dbt_func_name,'(0, :new."',dat_bf_col->qual[dbt_tc].
        orig_col_name,'"); ')
      ELSEIF ((dat_bf_col->qual[dbt_tc].std_cnvt_ind=2))
       SET dbt_operation = concat(dbt_operation,':new."',dat_bf_col->qual[dbt_tc].orig_col_name,'"; '
        )
      ENDIF
     ENDIF
   ENDFOR
   SET dbt_operation = concat(dbt_operation,"end; ^) go")
   IF ((dm_err->debug_flag > 1))
    CALL echo(dbt_operation)
   ENDIF
 END ;Subroutine
 SUBROUTINE dus_existing_index_ddl(dei_t,dei_orig_ind_idx,dei_utc_ind_idx,dei_utc_ind_name)
   SET dm_err->eproc = "Create and Insert Existing Index DDL."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dei_ind_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dei_ind_chg = i2 WITH protect, noconstant(0)
   DECLARE dei_ic = i4 WITH protect, noconstant(0)
   DECLARE dei_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dei_utc_col_name = vc WITH protect, noconstant(" ")
   IF ((tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].unique_ind=tgtsch->tbl[dei_t].ind[dei_orig_ind_idx].
   unique_ind)
    AND (tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].ind_col_cnt=tgtsch->tbl[dei_t].ind[dei_orig_ind_idx]
   .ind_col_cnt))
    IF ((dm_err->debug_flag > 0))
     CALL echo("index unique_ind and column count match.")
    ENDIF
    FOR (dei_ic = 1 TO tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].ind_col_cnt)
      IF ((tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].ind_col[dei_ic].col_name != tgtsch->tbl[dei_t].
      ind[dei_orig_ind_idx].ind_col[dei_ic].col_name))
       SET dei_col_idx = 0
       SET dei_col_idx = locateval(dei_col_idx,1,tgtsch->tbl[dei_t].tbl_col_cnt,tgtsch->tbl[dei_t].
        ind[dei_orig_ind_idx].ind_col[dei_ic].col_name,tgtsch->tbl[dei_t].tbl_col[dei_col_idx].
        col_name)
       IF (dei_col_idx > 0)
        SET dei_utc_col_name = tgtsch->tbl[dei_t].tbl_col[tgtsch->tbl[dei_t].tbl_col[dei_col_idx].
        cur_idx].col_name
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("utc_col_name = ",dei_utc_col_name))
         CALL echo(build("exist_col_name = ",tgtsch->tbl[dei_t].tbl_col[tgtsch->tbl[dei_t].tbl_col[
           dei_col_idx].cur_idx].col_name))
        ENDIF
        IF ((dei_utc_col_name != tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].ind_col[dei_ic].col_name))
         SET dei_ic = tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].ind_col_cnt
         SET dei_ind_chg = 1
        ENDIF
       ELSE
        SET dei_ic = tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].ind_col_cnt
        SET dei_ind_chg = 1
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    SET dei_ind_chg = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("index_change = ",dei_ind_chg))
   ENDIF
   IF (dus_pop_utc_index(dei_t,dei_orig_ind_idx,dei_utc_ind_idx,dei_utc_ind_name)=0)
    RETURN(0)
   ENDIF
   IF (dei_ind_chg=1)
    SET tgtsch->diff_ind = 1
    SET tgtsch->tbl[dei_t].diff_ind = 1
    SET tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].new_ind = 0
    SET tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].build_ind = 1
    SET dus_run_id = dum_utc_data->uptime_run_id
    SET dus_op_type = "DROP INDEX"
    SET dus_obj_name = trim(cnvtupper(dei_utc_ind_name))
    SET dus_table_name = trim(tgtsch->tbl[dei_t].tbl_name)
    SET dus_priority = 330
    SET dus_operation = concat("RDB ASIS (^ DROP INDEX ",dus_curr_owner,'."',dus_obj_name,'"^) GO')
    IF (dus_insert_ddl_log_rec(dus_run_id,dei_t) != 1)
     RETURN(0)
    ENDIF
    IF (dus_already_coalesced_ind=0)
     SET dus_already_coalesced_ind = 1
     SET dus_run_id = dum_utc_data->uptime_run_id
     SET dus_op_type = "COALESCE TABLESPACE"
     SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].tspace_name))
     SET dus_table_name = "-1"
     SET dus_priority = 335
     SET dus_operation = concat("RDB ASIS (^ ALTER TABLESPACE ",dus_obj_name," COALESCE ^) GO")
     IF (dus_insert_ddl_log_rec(dus_run_id,dei_t) != 1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dus_create_index_ddl(dei_t,dei_utc_ind_idx)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dei_ind_chg=0
    AND (tgtsch->tbl[dei_t].ind[dei_utc_ind_idx].visibility_change_ind=1))
    IF (dus_alter_visibility(dei_t,dei_utc_ind_name)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_pop_utc_index(dpu_t,dpu_orig_ind_idx,dpu_utc_ind_idx,dpu_utc_ind_name)
   SET dm_err->eproc = concat("Setting UTC index ",dpu_utc_ind_name," with index ",tgtsch->tbl[dpu_t]
    .ind[dpu_orig_ind_idx].ind_name," information.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dpu_ic = i4 WITH protect, noconstant(0)
   DECLARE dpu_ind_col_idx = i4 WITH protect, noconstant(0)
   DECLARE dpu_var = i4 WITH protect, noconstant(0)
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].ind_name = dpu_utc_ind_name
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].pct_increase = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx
   ].pct_increase
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].pct_free = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].
   pct_free
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].init_ext = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].
   init_ext
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].next_ext = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].
   next_ext
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].bytes_allocated = tgtsch->tbl[dpu_t].ind[
   dpu_orig_ind_idx].bytes_allocated
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].bytes_used = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].
   bytes_used
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].unique_ind = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].
   unique_ind
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].pk_ind = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].
   pk_ind
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].tspace_name = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx]
   .tspace_name
   IF (dus_stg_tspace_ind=1)
    SET dpu_var = 0
    SET dpu_var = locateval(dpu_var,1,dus_index_swap_tspace->cnt,tgtsch->tbl[dpu_t].ind[
     dpu_orig_ind_idx].ind_name,dus_index_swap_tspace->qual[dpu_var].ind_name,
     tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].tspace_name,dus_index_swap_tspace->qual[dpu_var].
     stg_tspace_name)
    IF (dpu_var > 0)
     SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].tspace_name = dus_index_swap_tspace->qual[dpu_var].
     tspace_name
    ENDIF
   ENDIF
   SET stat = alterlist(tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].ind_col,0)
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].ind_col_cnt = tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx]
   .ind_col_cnt
   SET stat = alterlist(tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].ind_col,tgtsch->tbl[dpu_t].ind[
    dpu_utc_ind_idx].ind_col_cnt)
   FOR (dpu_ic = 1 TO tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].ind_col_cnt)
     SET dpu_ind_col_idx = 0
     SET dpu_ind_col_idx = locateval(dpu_ind_col_idx,1,tgtsch->tbl[dpu_t].tbl_col_cnt,tgtsch->tbl[
      dpu_t].ind[dpu_orig_ind_idx].ind_col[dpu_ic].col_name,tgtsch->tbl[dpu_t].tbl_col[
      dpu_ind_col_idx].col_name)
     IF (dpu_ind_col_idx > 0)
      IF ((tgtsch->tbl[dpu_t].tbl_col[dpu_ind_col_idx].cur_idx > 0))
       SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].ind_col[dpu_ic].col_name = tgtsch->tbl[dpu_t].
       tbl_col[tgtsch->tbl[dpu_t].tbl_col[dpu_ind_col_idx].cur_idx].col_name
      ELSE
       SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].ind_col[dpu_ic].col_name = tgtsch->tbl[dpu_t].ind[
       dpu_orig_ind_idx].ind_col[dpu_ic].col_name
      ENDIF
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("column ",tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].ind_col[dpu_ic].
       col_name," in index ",tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].ind_name,
       " is not found on table ",
       dus_curr_owner,".",tgtsch->tbl[dpu_t].tbl_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].ind_col[dpu_ic].col_position = tgtsch->tbl[dpu_t].
     ind[dpu_orig_ind_idx].ind_col[dpu_ic].col_position
   ENDFOR
   SET tgtsch->tbl[dpu_t].ind[dpu_orig_ind_idx].cur_idx = dpu_utc_ind_idx
   SET tgtsch->tbl[dpu_t].ind[dpu_utc_ind_idx].cur_idx = dpu_orig_ind_idx
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_create_index_ddl(par_tgt_tblidx,par_tgt_indidx)
   SET dm_err->eproc = build("***> CREATE_INDEX_DDL <***")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE forloopnum = i4 WITH protect, noconstant(0)
   DECLARE dcid_init_extent = i4 WITH protect, noconstant(0)
   DECLARE dcid_next_extent = i4 WITH protect, noconstant(0)
   SET dus_run_id = dum_utc_data->uptime_run_id
   SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].ind_name))
   SET dus_table_name = trim(tgtsch->tbl[par_tgt_tblidx].tbl_name)
   SET dus_op_type = "CREATE INDEX"
   SET dus_priority = 340
   SET dus_operation = "RDB ASIS (^ CREATE "
   IF ((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].unique_ind=1))
    IF ((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].index_type != "BITMAP"))
     SET dus_operation = concat(dus_operation," UNIQUE ")
    ENDIF
   ENDIF
   IF ((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].index_type="BITMAP"))
    SET dus_operation = concat(dus_operation," ",trim(tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx]
      .index_type))
   ENDIF
   SET dus_operation = concat(dus_operation," INDEX ",dus_curr_owner,".",trim(dus_obj_name),
    " ON ",dus_curr_owner,'."',trim(dus_table_name),'" (')
   FOR (forloopnum = 1 TO tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].ind_col_cnt)
    SET dus_operation = concat(dus_operation," ",trim(tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx]
      .ind_col[forloopnum].col_name))
    IF ((forloopnum != tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].ind_col_cnt))
     SET dus_operation = concat(dus_operation," , ")
    ENDIF
   ENDFOR
   SET dus_operation = concat(dus_operation,") ")
   IF ((((dm2_db_options->dmt_freelist_grp != "0")) OR ((((tgtsch->tbl[par_tgt_tblidx].ind[
   par_tgt_indidx].init_ext > 0)) OR ((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].next_ext > 0)
   )) )) )
    SET dus_operation = concat(dus_operation," STORAGE ( ")
    IF ((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].init_ext > 0))
     SET dcid_init_extent = dm2ceil((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].init_ext/ 1024))
     SET dus_operation = concat(dus_operation," INITIAL ",trim(cnvtstring(dcid_init_extent)),"K")
    ENDIF
    IF ((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].next_ext > 0))
     SET dcid_next_extent = dm2ceil((tgtsch->tbl[par_tgt_tblidx].ind[par_tgt_indidx].next_ext/ 1024))
     SET dus_operation = concat(dus_operation," NEXT ",trim(cnvtstring(dcid_next_extent)),"K")
    ENDIF
    IF ((dm2_db_options->dmt_freelist_grp != "0"))
     SET dus_operation = concat(dus_operation," FREELIST GROUPS ",dm2_db_options->dmt_freelist_grp)
    ENDIF
    SET dus_operation = concat(dus_operation," )")
   ENDIF
   SET dus_operation = concat(dus_operation," LOGGING INVISIBLE ONLINE TABLESPACE ",trim(tgtsch->tbl[
     par_tgt_tblidx].ind[par_tgt_indidx].tspace_name))
   IF ((dm2_rdbms_version->level1=9))
    SET dus_operation = concat(dus_operation," COMPUTE STATISTICS ")
   ENDIF
   SET dus_operation = concat(dus_operation," ^) GO")
   IF (dus_insert_ddl_log_rec(dus_run_id,par_tgt_tblidx) != 1)
    RETURN(0)
   ENDIF
   IF (dus_alter_visibility(par_tgt_tblidx,dus_obj_name)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_new_index_ddl(dni_t,dni_orig_ind_idx,dni_utc_ind_name)
   SET dm_err->eproc = "Create and Insert New Index DDL."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dni_utc_ind_idx = i4 WITH protect, noconstant(0)
   DECLARE dni_ind_col_idx = i4 WITH protect, noconstant(0)
   SET tgtsch->diff_ind = 1
   SET tgtsch->tbl[dni_t].diff_ind = 1
   SET tgtsch->tbl[dni_t].ind_cnt = (tgtsch->tbl[dni_t].ind_cnt+ 1)
   SET stat = alterlist(tgtsch->tbl[dni_t].ind,tgtsch->tbl[dni_t].ind_cnt)
   SET dni_utc_ind_idx = tgtsch->tbl[dni_t].ind_cnt
   SET tgtsch->tbl[dni_t].ind[dni_utc_ind_idx].new_ind = 1
   SET tgtsch->tbl[dni_t].ind[dni_utc_ind_idx].build_ind = 1
   IF (dus_pop_utc_index(dni_t,dni_orig_ind_idx,dni_utc_ind_idx,dni_utc_ind_name)=0)
    RETURN(0)
   ENDIF
   IF (dus_already_coalesced_ind=0)
    SET dus_already_coalesced_ind = 1
    SET dus_run_id = dum_utc_data->uptime_run_id
    SET dus_op_type = "COALESCE TABLESPACE"
    SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[dni_t].ind[dni_utc_ind_idx].tspace_name))
    SET dus_table_name = "-1"
    SET dus_priority = 335
    SET dus_operation = concat("RDB ASIS (^ ALTER TABLESPACE ",dus_obj_name," COALESCE ^) GO")
    IF (dus_insert_ddl_log_rec(dus_run_id,dni_t) != 1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dus_create_index_ddl(dni_t,dni_utc_ind_idx)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_drop_index_ddl(ddi_t)
   SET dm_err->eproc = "Create and Insert Drop Index DDL."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE ddi_i = i4 WITH protect, noconstant
   FOR (ddi_i = 1 TO tgtsch->tbl[ddi_t].ind_cnt)
     IF (substring(1,9,tgtsch->tbl[ddi_t].ind[ddi_i].ind_name)="ZTC_TMP1_")
      IF ((tgtsch->tbl[ddi_t].ind[ddi_i].cur_idx=0))
       SET dus_run_id = dum_utc_data->uptime_run_id
       SET dus_op_type = "DROP INDEX"
       SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[ddi_t].ind[ddi_i].ind_name))
       SET dus_table_name = trim(tgtsch->tbl[ddi_t].tbl_name)
       SET dus_priority = 330
       SET dus_operation = concat("RDB ASIS (^ DROP INDEX ",dus_curr_owner,'."',dus_obj_name,
        '" ^) GO')
       IF (dus_insert_ddl_log_rec(dus_run_id,ddi_t) != 1)
        RETURN(0)
       ENDIF
       IF (dus_already_coalesced_ind=0)
        SET dus_already_coalesced_ind = 1
        SET dus_run_id = dum_utc_data->uptime_run_id
        SET dus_op_type = "COALESCE TABLESPACE"
        SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[ddi_t].ind[ddi_i].tspace_name))
        SET dus_table_name = "-1"
        SET dus_priority = 335
        SET dus_operation = concat("RDB ASIS (^ ALTER TABLESPACE ",dus_obj_name," COALESCE ^) GO")
        IF (dus_insert_ddl_log_rec(dus_run_id,ddi_t) != 1)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_additional_index_ddl(dai_t)
   SET dm_err->eproc = "Create and Insert additional Index related DDL."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dai_pk_name = vc WITH protect, noconstant(" ")
   DECLARE dai_pk_idx = i4 WITH protect, noconstant(0)
   DECLARE dai_pk_col_list = vc WITH protect, noconstant(" ")
   DECLARE dai_fk_col_list = vc WITH protect, noconstant(" ")
   DECLARE dai_orig_ind_name = vc WITH protect, noconstant(" ")
   DECLARE dai_utc1_ind_name = vc WITH protect, noconstant(" ")
   DECLARE dai_utc2_ind_name = vc WITH protect, noconstant(" ")
   DECLARE dai_i = i4 WITH protect, noconstant(0)
   DECLARE dai_cc = i4 WITH protect, noconstant(0)
   DECLARE dai_c = i4 WITH protect, noconstant(0)
   DECLARE dai_tidx = i4 WITH protect, noconstant(0)
   FOR (dai_i = 1 TO tgtsch->tbl[dai_t].ind_cnt)
     IF (substring(1,9,tgtsch->tbl[dai_t].ind[dai_i].ind_name)="ZTC_TMP1_")
      IF ((tgtsch->tbl[dai_t].ind[dai_i].cur_idx > 0)
       AND (tgtsch->tbl[dai_t].ind[dai_i].pk_ind > 0))
       SET dai_pk_idx = tgtsch->tbl[dai_t].ind[dai_i].pk_ind
       SET dai_pk_name = trim(cnvtupper(tgtsch->tbl[dai_t].cons[dai_pk_idx].cons_name))
       SET dus_run_id = dum_utc_data->downtime_run_id
       SET dus_op_type = "DROP PK CONSTRAINT"
       SET dus_obj_name = dai_pk_name
       SET dus_table_name = trim(tgtsch->tbl[dai_t].tbl_name)
       SET dus_priority = 1310
       SET dus_operation = concat("rdb asis (^alter table ",dus_curr_owner,'."',dus_table_name,
        '" drop constraint ',
        dus_obj_name," keep index^) go")
       IF (dus_insert_ddl_log_rec(dus_run_id,dai_t) != 1)
        RETURN(0)
       ENDIF
       SET dus_run_id = dum_utc_data->downtime_run_id
       SET dus_op_type = "CREATE PK CONSTRAINT"
       SET dus_obj_name = dai_pk_name
       SET dus_table_name = trim(tgtsch->tbl[dai_t].tbl_name)
       SET dus_priority = 2410
       FOR (dai_cc = 1 TO tgtsch->tbl[dai_t].cons[dai_pk_idx].cons_col_cnt)
         IF (dai_cc=1)
          SET dai_pk_col_list = tgtsch->tbl[dai_t].cons[dai_pk_idx].cons_col[dai_cc].col_name
         ELSE
          SET dai_pk_col_list = concat(dai_pk_col_list,",",trim(tgtsch->tbl[dai_t].cons[dai_pk_idx].
            cons_col[dai_cc].col_name))
         ENDIF
       ENDFOR
       SET dus_operation = concat("rdb asis (^alter table ",dus_curr_owner,'."',dus_table_name,
        '" add constraint ',
        dus_obj_name," primary key (",dai_pk_col_list,
        ") not deferrable norely enable novalidate^) go")
       IF (dus_insert_ddl_log_rec(dus_run_id,dai_t) != 1)
        RETURN(0)
       ENDIF
       FOR (dai_tidx = 1 TO tgtsch->tbl_cnt)
         FOR (dai_c = 1 TO tgtsch->tbl[dai_tidx].cons_cnt)
           IF ((tgtsch->tbl[dai_tidx].cons[dai_c].cons_type="R")
            AND (tgtsch->tbl[dai_tidx].cons[dai_c].r_constraint_name=dai_pk_name))
            SET dus_run_id = dum_utc_data->downtime_run_id
            SET dus_op_type = "DROP FK CONSTRAINT"
            SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[dai_tidx].cons[dai_c].cons_name))
            SET dus_table_name = trim(tgtsch->tbl[dai_tidx].tbl_name)
            SET dus_priority = 1300
            FOR (dai_cc = 1 TO tgtsch->tbl[dai_tidx].cons[dai_c].cons_col_cnt)
              IF (dai_cc=1)
               SET dai_fk_col_list = trim(tgtsch->tbl[dai_tidx].cons[dai_c].cons_col[dai_cc].col_name
                )
              ELSE
               SET dai_fk_col_list = concat(dai_fk_col_list,",",trim(tgtsch->tbl[dai_tidx].cons[dai_c
                 ].cons_col[dai_cc].col_name))
              ENDIF
            ENDFOR
            SET dus_operation = concat("rdb asis (^alter table ",dus_curr_owner,'."',dus_table_name,
             '" drop constraint ',
             dus_obj_name,"^) go")
            IF (dus_insert_ddl_log_rec(dus_run_id,dai_t) != 1)
             RETURN(0)
            ENDIF
            SET dus_run_id = dum_utc_data->downtime_run_id
            SET dus_op_type = "CREATE FK CONSTRAINT"
            SET dus_obj_name = trim(cnvtupper(tgtsch->tbl[dai_tidx].cons[dai_c].cons_name))
            SET dus_table_name = trim(tgtsch->tbl[dai_tidx].tbl_name)
            SET dus_priority = 2420
            SET dus_operation = concat("rdb asis (^alter table ",dus_curr_owner,'."',dus_table_name,
             '" add constraint ',
             dus_obj_name," foreign key (",dai_fk_col_list,") references ",dus_curr_owner,
             ".",tgtsch->tbl[dai_t].tbl_name," (",dai_pk_col_list,
             ") not deferrable norely disable novalidate^) go")
            IF (dus_insert_ddl_log_rec(dus_run_id,dai_t) != 1)
             RETURN(0)
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   FOR (dai_i = 1 TO tgtsch->tbl[dai_t].ind_cnt)
     IF (substring(1,9,tgtsch->tbl[dai_t].ind[dai_i].ind_name)="ZTC_TMP1_"
      AND (tgtsch->tbl[dai_t].ind[dai_i].cur_idx > 0))
      SET dai_orig_ind_name = tgtsch->tbl[dai_t].ind[tgtsch->tbl[dai_t].ind[dai_i].cur_idx].ind_name
      SET dai_utc1_ind_name = tgtsch->tbl[dai_t].ind[dai_i].ind_name
      IF (substring(12,1,dai_orig_ind_name)="_")
       SET dai_utc2_ind_name = concat(substring(1,11,dai_orig_ind_name),substring(13,1,
         dai_orig_ind_name))
      ELSE
       SET dai_utc2_ind_name = substring(1,12,dai_orig_ind_name)
      ENDIF
      SET dai_utc2_ind_name = concat("ZTC_TMP2_",tgtsch->tbl[dai_t].table_suffix,dai_utc2_ind_name)
      SET dus_run_id = dum_utc_data->downtime_run_id
      SET dus_op_type = "RENAME INDEX"
      SET dus_obj_name = trim(cnvtupper(dai_orig_ind_name))
      SET dus_table_name = trim(tgtsch->tbl[dai_t].tbl_name)
      SET dus_priority = 1320
      SET dus_operation = concat("rdb asis (^alter index ",dus_curr_owner,".",dus_obj_name,
       " rename to ",
       dai_utc2_ind_name,"^) go")
      IF (dus_insert_ddl_log_rec(dus_run_id,dai_t) != 1)
       RETURN(0)
      ENDIF
      SET dus_run_id = dum_utc_data->downtime_run_id
      SET dus_op_type = "RENAME INDEX"
      SET dus_obj_name = trim(cnvtupper(dai_utc1_ind_name))
      SET dus_table_name = trim(tgtsch->tbl[dai_t].tbl_name)
      SET dus_priority = 1330
      SET dus_operation = concat("rdb asis (^alter index ",dus_curr_owner,".",dus_obj_name,
       " rename to ",
       dai_orig_ind_name,"^) go")
      IF (dus_insert_ddl_log_rec(dus_run_id,dai_t) != 1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   FOR (dai_i = 1 TO tgtsch->tbl[dai_t].ind_cnt)
     IF (substring(1,9,tgtsch->tbl[dai_t].ind[dai_i].ind_name)="ZTC_TMP1_"
      AND (tgtsch->tbl[dai_t].ind[dai_i].cur_idx > 0))
      IF ((tgtsch->tbl[dai_t].ind[tgtsch->tbl[dai_t].ind[dai_i].cur_idx].visibility_change_ind=1))
       SET dai_orig_ind_name = tgtsch->tbl[dai_t].ind[tgtsch->tbl[dai_t].ind[dai_i].cur_idx].ind_name
       IF (dus_alter_invisible(dai_t,dai_orig_ind_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_insert_ddl_log_rec(didlr_run_id,didlr_t)
   SET dm_err->eproc = build("*** DUS_INSERT_DDL_LOG_REC ***")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE didlr_op_id = i4 WITH protect, noconstant(0)
   DECLARE didlr_op_type = vc WITH protect, noconstant(" ")
   DECLARE didlr_operation = vc WITH protect, noconstant(" ")
   DECLARE didlr_status = vc WITH protect, noconstant(" ")
   DECLARE didlr_record_cnt = i4 WITH protect, noconstant(0)
   DECLARE didlr_max_length = i4 WITH protect, constant(4000)
   DECLARE didlr_row_cnt = f8 WITH protect, noconstant(0.0)
   IF (didlr_t > 0)
    SET didlr_row_cnt = tgtsch->tbl[didlr_t].row_cnt
   ENDIF
   SET didlr_record_cnt = 0
   IF (trim(dus_table_name)="-1")
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.run_id=didlr_run_id
      AND d.op_type=dus_op_type
      AND d.obj_name=dus_obj_name
      AND d.priority=dus_priority
     DETAIL
      didlr_record_cnt = (didlr_record_cnt+ 1), didlr_op_id = d.op_id, didlr_operation = d.operation,
      didlr_status = d.status, didlr_op_type = d.op_type
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.run_id=didlr_run_id
      AND d.op_type=dus_op_type
      AND d.obj_name=dus_obj_name
      AND d.priority=dus_priority
      AND d.table_name=dus_table_name
      AND d.owner_name=dus_curr_owner
     DETAIL
      didlr_record_cnt = (didlr_record_cnt+ 1), didlr_op_id = d.op_id, didlr_operation = d.operation,
      didlr_status = d.status, didlr_op_type = d.op_type
     WITH nocounter
    ;end select
   ENDIF
   SET dm_err->eproc = "Determining if the DDL operation is a duplicate already in dm2_ddl_ops_log"
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = build("RUN_ID= ",didlr_run_id)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = build("OP_TYPE= ",dus_op_type)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = build("OBJ_NAME= ",dus_obj_name)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = build("PRIORITY= ",dus_priority)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = build("TABLE_NAME= ",dus_table_name)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = build("OPERATION = ",dus_operation)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = build("OWNER = ",dus_curr_owner)
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (didlr_record_cnt != 0)
    IF (didlr_record_cnt=1)
     IF (textlen(trim(didlr_status)) > 0)
      DELETE  FROM dm2_ddl_ops_log
       WHERE op_id=didlr_op_id
       WITH nocounter
      ;end delete
      IF (check_error("Single row cleanup (delete) in dus_insert_ddl_log_rec")=0)
       SET dm_err->eproc = build("*** Single row clean up of duplicate row (op_id: ",didlr_op_id,
        ") was successful.  Operation was : (",didlr_operation,")")
       CALL disp_msg(" ",dm_err->logfile,0)
       COMMIT
       SET didlr_record_cnt = 0
      ELSE
       ROLLBACK
       SET dm_err->eproc = build(" Deleting duplicate DDL row for op_id: (",didlr_op_id,")")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET didlr_record_cnt = 0
     ENDIF
    ELSE
     SET dm_err->eproc = concat("More than 1 dup ddl row found for OP_TYPE: ",dus_op_type,
      " OBJ_NAME: ",dus_obj_name,"in dm2_ddl_ops_log. ")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ENDIF
   IF (didlr_record_cnt=0)
    SELECT INTO "nl:"
     didlr_max_op_id = max(d.op_id)
     FROM dm2_ddl_ops_log d
     WHERE d.op_id IS NOT null
     DETAIL
      didlr_op_id = (didlr_max_op_id+ 1)
     WITH format, nocounter
    ;end select
    SET dm_err->eproc = "Selecting max op_id from dm2_ddl_ops_log"
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    INSERT  FROM dm2_ddl_ops_log d
     SET d.op_id = didlr_op_id, d.run_id = didlr_run_id, d.gen_dt_tm = cnvtdatetime(curdate,curtime3),
      d.gen_id = 0, d.begin_dt_tm = cnvtdatetime(null), d.end_dt_tm = cnvtdatetime(null),
      d.est_duration = didlr_row_cnt, d.act_duration = 0, d.op_type = trim(dus_op_type),
      d.table_name = dus_table_name, d.tablespace_name = dus_tablespace_name, d.row_cnt =
      didlr_row_cnt,
      d.obj_name = trim(dus_obj_name), d.priority = dus_priority, d.status = null,
      d.error_msg = null, d.operation = dus_operation, d.on_error_operation = null,
      d.schema_date = null, d.schema_instance = null, d.ready_to_run_ind = 0,
      d.appl_id = dum_utc_data->appl_id, d.owner_name = dus_curr_owner
     WITH nocounter
    ;end insert
    IF (check_error("subroutine insert_ddl_log_rec:insert into dm2_ddl_ops_log")=0)
     COMMIT
    ELSE
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = build("DDL Record insert bypassed for duplicate operation: ",dus_operation)
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_apply_sizing(null)
   SET dm_err->eproc = "Sizing for new indexes."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt t  WITH seq = value(tgtsch->tbl_cnt)),
     (dummyt i  WITH seq = 100),
     user_segments u
    PLAN (t
     WHERE (tgtsch->tbl[t.seq].diff_ind=1))
     JOIN (i
     WHERE (i.seq <= tgtsch->tbl[t.seq].ind_cnt)
      AND (tgtsch->tbl[t.seq].ind[i.seq].build_ind=1)
      AND (tgtsch->tbl[t.seq].ind[i.seq].cur_idx > 0))
     JOIN (u
     WHERE u.segment_type="INDEX"
      AND (u.segment_name=tgtsch->tbl[t.seq].ind[tgtsch->tbl[t.seq].ind[i.seq].cur_idx].ind_name))
    ORDER BY u.segment_name
    DETAIL
     IF ((tgtsch->tbl[t.seq].ind[i.seq].tspace_name != u.tablespace_name))
      tgtsch->tbl[t.seq].ind[i.seq].tspace_name = u.tablespace_name
     ENDIF
     tgtsch->tbl[t.seq].ind[i.seq].size = u.bytes
     IF ((tgtsch->tbl[t.seq].iext_mgmt="D"))
      tgtsch->tbl[t.seq].ind[i.seq].size = (tgtsch->tbl[t.seq].ind[i.seq].size+ dmt_min_ext_size),
      tgtsch->tbl[t.seq].ind[i.seq].size = dus_cal_dmt_size(tgtsch->tbl[t.seq].ind[i.seq].size,tgtsch
       ->tbl[t.seq].ind[i.seq].next_ext)
     ELSE
      tgtsch->tbl[t.seq].ind[i.seq].size = (tgtsch->tbl[t.seq].ind[i.seq].size+ lmt_min_ext_size),
      tgtsch->tbl[t.seq].ind[i.seq].size = dus_cal_lmt_round_size(tgtsch->tbl[t.seq].ind[i.seq].size,
       tgtsch->tbl[t.seq].ind[i.seq].cur_bytes_allocated)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("Index -",tgtsch->tbl[t.seq].ind[i.seq].ind_name,"-size = ",tgtsch->tbl[t.seq].
       ind[i.seq].size))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Sizing for utc columns."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dus_no_tz_ind=0)
    SET dm_err->eproc = "Get TZ column size."
    SELECT INTO "nl:"
     s = sqlpassthru(build("vsize(",curtimezonesys,")"),0)
     FROM dual
     DETAIL
      dus_tz_size = s
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   FOR (dus_t = 1 TO tgtsch->tbl_cnt)
     IF ((tgtsch->tbl[dus_t].diff_ind=1))
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat("Processing existing table ",tgtsch->tbl[dus_t].tbl_name))
      ENDIF
      FOR (dus_tc = 1 TO tgtsch->tbl[dus_t].tbl_col_cnt)
       IF ((tgtsch->tbl[dus_t].tbl_col[dus_tc].new_ind=1)
        AND (tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name != "*_TZ"))
        SET dm_err->eproc = "Sizing for new utc columns"
        IF ((((tgtsch->tbl[dus_t].tbl_col[dus_tc].nullable="N")) OR ((tgtsch->tbl[dus_t].tbl_col[
        dus_tc].nullable="Y")
         AND (tgtsch->tbl[dus_t].row_cnt < 10000))) )
         SET tgtsch->tbl[dus_t].tbl_col[dus_tc].size = dus_date_len
         SET tgtsch->tbl[dus_t].size = (tgtsch->tbl[dus_t].size+ tgtsch->tbl[dus_t].tbl_col[dus_tc].
         size)
         IF ((dm_err->debug_flag > 0))
          CALL echo("***")
          CALL echo("New not Null or null with less than 10000 rows")
          CALL echo(build("tbl=",tgtsch->tbl[dus_t].tbl_name))
          CALL echo(build("col=",tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name))
          CALL echo(build("tbl_size=",tgtsch->tbl[dus_t].size))
          CALL echo("***")
         ENDIF
        ELSE
         SET dus_nn_ratio = dus_calc_col_ratio(tgtsch->tbl[dus_t].tbl_name,tgtsch->tbl[dus_t].
          tbl_col[tgtsch->tbl[dus_t].tbl_col[dus_tc].cur_idx].col_name)
         SET tgtsch->tbl[dus_t].tbl_col[dus_tc].size = (dus_date_len * dus_nn_ratio)
         SET tgtsch->tbl[dus_t].size = (tgtsch->tbl[dus_t].size+ tgtsch->tbl[dus_t].tbl_col[dus_tc].
         size)
         IF ((dm_err->debug_flag > 0))
          CALL echo("***")
          CALL echo("Null with more than 10000 rows")
          CALL echo(build("tbl=",tgtsch->tbl[dus_t].tbl_name))
          CALL echo(build("col=",tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name))
          CALL echo(build("tbl_size=",tgtsch->tbl[dus_t].size))
          CALL echo("***")
         ENDIF
        ENDIF
       ENDIF
       IF (dus_no_tz_ind=0)
        IF ((tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name="*_TZ")
         AND (tgtsch->tbl[dus_t].tbl_col[dus_tc].new_ind=1))
         SET tgtsch->tbl[dus_t].tbl_col[dus_tc].size = dus_tz_size
         SET tgtsch->tbl[dus_t].size = (tgtsch->tbl[dus_t].size+ tgtsch->tbl[dus_t].tbl_col[dus_tc].
         size)
         IF ((dm_err->debug_flag > 0))
          CALL echo("***")
          CALL echo("TZ column")
          CALL echo(build("tbl=",tgtsch->tbl[dus_t].tbl_name))
          CALL echo(build("col=",tgtsch->tbl[dus_t].tbl_col[dus_tc].col_name))
          CALL echo(build("tbl_size=",tgtsch->tbl[dus_t].size))
          CALL echo("***")
         ENDIF
        ENDIF
       ENDIF
      ENDFOR
      IF ((tgtsch->tbl[dus_t].size > 0))
       SET dm_err->eproc = "Size for column from Nullable to not NULL and new not NULL"
       CALL dus_calc_tot_size_not_null(dus_t)
       IF ((dm_err->err_ind=1))
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_calc_col_ratio(dcc_tbl_name,dcc_col_name)
   SET dm_err->eproc = concat("Calculate not null ratio for column ",dcc_col_name," on table ",
    dcc_tbl_name)
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dcc_null = f8 WITH protect, noconstant(0.0)
   DECLARE dcc_nn_ratio = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    parser(build("t.",dcc_col_name)), ni = nullind(parser(build("t.",dcc_col_name)))
    FROM (value(dcc_tbl_name) t)
    HEAD REPORT
     dcc_null = 0.0
    FOOT REPORT
     dcc_null = sum(evaluate(ni,1,1,0))
    WITH maxqual(t,10000), nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF (dcc_null != 10000)
    SET dcc_nn_ratio = ((10000 - dcc_null)/ 10000)
   ELSE
    SET dcc_nn_ratio = 0
   ENDIF
   RETURN(dcc_nn_ratio)
 END ;Subroutine
 SUBROUTINE dus_calc_tot_size_not_null(tsnn_tblcnt)
   SET dm_err->eproc = "execute dus_calc_tot_size_not_null"
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   IF (currdb="ORACLE")
    SET tgtsch->tbl[tsnn_tblcnt].size = ((tgtsch->tbl[tsnn_tblcnt].size+ dus_tbl_header) * tgtsch->
    tbl[tsnn_tblcnt].row_cnt)
    IF ((tgtsch->tbl[tsnn_tblcnt].dext_mgmt="D"))
     SET tgtsch->tbl[tsnn_tblcnt].size = dus_cal_dmt_size(tgtsch->tbl[tsnn_tblcnt].size,tgtsch->tbl[
      tsnn_tblcnt].next_ext)
    ELSE
     SET tgtsch->tbl[tsnn_tblcnt].size = dus_cal_lmt_round_size(tgtsch->tbl[tsnn_tblcnt].size,tgtsch
      ->tbl[tsnn_tblcnt].cur_bytes_allocated)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("***")
    CALL echo(build("Table:",tgtsch->tbl[tsnn_tblcnt].tbl_name))
    CALL echo(build("size=",tgtsch->tbl[tsnn_tblcnt].size))
    CALL echo("***")
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dus_cal_dmt_size(cis_dmt_size,cis_nextent)
   SET dm_err->eproc = "execute dus_cal_dmt_size"
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   DECLARE ceil_factor = i4 WITH protect, noconstant(0)
   DECLARE cds_ret_size = f8 WITH protect, noconstant(0.0)
   IF (cis_nextent=0)
    SET dm_err->emsg = "next extent is zero"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(cds_ret_size)
   ENDIF
   SET ceil_factor = 0
   SET ceil_factor = dm2ceil((cis_dmt_size/ cis_nextent))
   SET cds_ret_size = (cis_nextent * ceil_factor)
   RETURN(cds_ret_size)
 END ;Subroutine
 SUBROUTINE dus_cal_lmt_round_size(cis_rsize,cis_cursize)
   SET dm_err->eproc = "execute dus_cal_lmt_round_size"
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   DECLARE clrs_ret_size = f8 WITH protect, noconstant(0.0)
   DECLARE clrs_ttl_size = f8 WITH protect, noconstant(0.0)
   DECLARE clrs_rounding_level = f8 WITH protect, noconstant(0.0)
   DECLARE ceil_factor = i4 WITH protect, noconstant(0)
   SET ceil_factor = 0
   SET clrs_ttl_size = (cis_rsize+ cis_cursize)
   IF (cis_rsize < lmt_level_1)
    SET clrs_rounding_level = lmt_level_64
   ELSEIF (clrs_ttl_size >= lmt_level_1
    AND cis_rsize < lmt_level_8)
    SET clrs_rounding_level = lmt_level_1
   ELSEIF (clrs_ttl_size >= lmt_level_8
    AND cis_rsize < lmt_level_64m)
    SET clrs_rounding_level = lmt_level_8
   ELSE
    SET clrs_rounding_level = lmt_level_64m
   ENDIF
   SET ceil_factor = dm2ceil((cis_rsize/ clrs_rounding_level))
   SET clrs_ret_size = (clrs_rounding_level * ceil_factor)
   RETURN(clrs_ret_size)
 END ;Subroutine
 SUBROUTINE dus_load_tspace(null)
   DECLARE dlt_inx_num = i4 WITH protect, noconstant(0)
   DECLARE dlt_tsprec_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlt_rtspec = i4 WITH protect, noconstant(0)
   DECLARE dlt_tsp = i4 WITH protect, noconstant(0)
   DECLARE dlt_i = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "load existing tspace into record structures"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dlt_tsp = 1 TO value(tgtsch->tbl_cnt))
     IF ((tgtsch->tbl[dlt_tsp].diff_ind=1))
      SET dlt_inx_num = 0
      IF ((tgtsch->tbl[dlt_tsp].size > 0))
       SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,tgtsch->tbl[dlt_tsp].tspace_name,
        tspace_rec->tsp[dlt_inx_num].tsp_name)
       IF (dlt_inx_num=0)
        CALL dus_set_tspace_rec("T",dlt_tsp,0)
       ELSE
        SET tspace_rec->tsp[dlt_inx_num].cur_bytes = (tspace_rec->tsp[dlt_inx_num].cur_bytes+ tgtsch
        ->tbl[dlt_tsp].size)
        IF ((tspace_rec->tsp[dlt_inx_num].ext_mgmt="D")
         AND (tspace_rec->tsp[dlt_inx_num].chunk_size < tgtsch->tbl[dlt_tsp].next_ext))
         SET tspace_rec->tsp[dlt_inx_num].chunk_size = tgtsch->tbl[dlt_tsp].next_ext
        ENDIF
       ENDIF
      ENDIF
      FOR (dlt_i = 1 TO tgtsch->tbl[dlt_tsp].ind_cnt)
        IF ((tgtsch->tbl[dlt_tsp].ind[dlt_i].size > 0))
         SET dlt_inx_num = 0
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,tgtsch->tbl[dlt_tsp].ind[dlt_i].
          tspace_name,tspace_rec->tsp[dlt_inx_num].tsp_name)
         IF (dlt_inx_num=0)
          CALL dus_set_tspace_rec("I",dlt_tsp,dlt_i)
         ELSE
          SET tspace_rec->tsp[dlt_inx_num].cur_bytes = (tspace_rec->tsp[dlt_inx_num].cur_bytes+
          tgtsch->tbl[dlt_tsp].ind[dlt_i].size)
          CALL dus_set_tsp_chunk_size(dlt_tsp,dlt_i,dlt_inx_num)
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   SET stat = alterlist(tspace_rec->tsp,dlt_tsprec_cnt)
   SET tspace_rec->tsp_rec_cnt = dlt_tsprec_cnt
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(tspace_rec)
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_set_tspace_rec(tsp_ind,tbl_seq,ind_seq)
   SET dlt_tsprec_cnt = (dlt_tsprec_cnt+ 1)
   SET tspace_rec->tsp_rec_cnt = dlt_tsprec_cnt
   SET stat = alterlist(tspace_rec->tsp,dlt_tsprec_cnt)
   IF (tsp_ind="T")
    SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = tgtsch->tbl[tbl_seq].tspace_name
    SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes+
    tgtsch->tbl[tbl_seq].size)
    SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = tgtsch->tbl[tbl_seq].dext_mgmt
   ELSEIF (tsp_ind="I")
    SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = tgtsch->tbl[tbl_seq].iext_mgmt
    SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = tgtsch->tbl[tbl_seq].ind[ind_seq].tspace_name
    SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes+
    tgtsch->tbl[tbl_seq].ind[ind_seq].size)
   ENDIF
   SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_type = tsp_ind
   SET tspace_rec->tsp[dlt_tsprec_cnt].new_ind = 0
   IF ((tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt="D"))
    IF (tsp_ind="T")
     SET tspace_rec->tsp[dlt_tsprec_cnt].chunk_size = tgtsch->tbl[tbl_seq].next_ext
    ELSEIF (tsp_ind="I")
     CALL dus_set_tsp_chunk_size(tbl_seq,ind_seq,dlt_tsprec_cnt)
    ENDIF
   ELSE
    SET tspace_rec->tsp[dlt_tsprec_cnt].chunk_size = dus_lmt_chnk
   ENDIF
 END ;Subroutine
 SUBROUTINE dus_set_tsp_chunk_size(stcs_tbl_seq,stcs_ind_seq,stcs_tsp_seq)
   IF ((tspace_rec->tsp[stcs_tsp_seq].chunk_size < tgtsch->tbl[stcs_tbl_seq].ind[stcs_ind_seq].
   next_ext))
    SET tspace_rec->tsp[stcs_tsp_seq].chunk_size = tgtsch->tbl[stcs_tbl_seq].ind[stcs_ind_seq].
    next_ext
   ENDIF
 END ;Subroutine
 SUBROUTINE dus_calc_tspace_needs(null)
   SET dm_err->eproc = "Calculate tablespace needs."
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE coal_cnt = i4 WITH protect, noconstant(0)
   DECLARE dts_del_cnt = i4 WITH protect, noconstant(0)
   IF (currdb="ORACLE"
    AND (tspace_rec->tsp_rec_cnt > 0))
    FOR (coal_cnt = 1 TO tspace_rec->tsp_rec_cnt)
     SET dus_coal_stat = concat("rdb alter tablespace ",tspace_rec->tsp[coal_cnt].tsp_name,
      " coalesce go")
     IF (dm2_push_cmd(dus_coal_stat,1)=0)
      RETURN(0)
     ENDIF
    ENDFOR
    SET dus_space_need_cnt = 0
    SET dus_space_needs_ind = 0
    SET dm_err->eproc = "Load dm2_dba_free_space into memory"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_dba_free_space db,
      (dummyt dt  WITH seq = value(tspace_rec->tsp_rec_cnt))
     PLAN (dt)
      JOIN (db
      WHERE (db.tablespace_name=tspace_rec->tsp[dt.seq].tsp_name))
     ORDER BY db.tablespace_name
     HEAD db.tablespace_name
      fin_flag = 0, byte_tot = 0, dus_free_chunk = 0,
      dus_tot_free_chunk = 0
      IF ((dm_err->debug_flag > 2))
       CALL echo(concat("Working on tablespace - ",db.tablespace_name))
      ENDIF
      dus_chunk_needed = dm2ceil((tspace_rec->tsp[dt.seq].cur_bytes/ tspace_rec->tsp[dt.seq].
       chunk_size))
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("cur bytes = ",tspace_rec->tsp[dt.seq].cur_bytes)),
       CALL echo(build("chunk size = ",tspace_rec->tsp[dt.seq].chunk_size)),
       CALL echo(build("chunk needed = ",dus_chunk_needed))
      ENDIF
     DETAIL
      dus_free_chunk = dm2floor((db.bytes/ tspace_rec->tsp[dt.seq].chunk_size)), dus_tot_free_chunk
       = (dus_tot_free_chunk+ dus_free_chunk)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("datafile bytes = ",db.bytes)),
       CALL echo(build("chunk size = ",tspace_rec->tsp[dt.seq].chunk_size)),
       CALL echo(build("free chunk = ",dus_free_chunk)),
       CALL echo(build("tot free chunk = ",dus_tot_free_chunk))
      ENDIF
     FOOT  db.tablespace_name
      IF (dus_chunk_needed <= dus_tot_free_chunk)
       tspace_rec->tsp[dt.seq].final_bytes_to_add = 0
      ELSE
       dus_space_need_cnt = (dus_space_need_cnt+ 1), tspace_rec->tsp[dt.seq].final_bytes_to_add = (((
       dus_chunk_needed - dus_tot_free_chunk) * tspace_rec->tsp[dt.seq].chunk_size)+ dus_new_extra)
      ENDIF
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("final bytes to add = ",tspace_rec->tsp[dt.seq].final_bytes_to_add))
      ENDIF
     WITH nocounter, outerjoin = dt
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("need cnt  =",dus_space_need_cnt))
   ENDIF
   IF (dus_space_need_cnt > 0)
    SET dus_space_needs_ind = 1
    CALL dus_load_rtspace(0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (size(rtspace->qual,5)=0)
     SET dm_err->eproc = "There is no table in rTspace"
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(0)
    ENDIF
    SET rtspace->install_type = "SCHEMA_DATE"
    SET rtspace->install_type_value = format(cnvtdatetime(dum_utc_data->schema_date),"DD-MMM-YYYY;;D"
     )
    FOR (dts_del_cnt = 1 TO value(size(rtspace->qual,5)))
      SET dm_err->eproc = "Delete from dm2_tspace_size"
      DELETE  FROM dm2_tspace_size dt
       WHERE (dt.install_type=rtspace->install_type)
        AND (dt.install_type_value=rtspace->install_type_value)
        AND (dt.tspace_name=rtspace->qual[dts_del_cnt].tspace_name)
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
    ENDFOR
    SET dm_err->eproc = "Insert into dm2_tspace_size"
    INSERT  FROM dm2_tspace_size dt,
      (dummyt r  WITH seq = value(size(rtspace->qual,5)))
     SET dt.bytes_needed = rtspace->qual[r.seq].bytes_needed, dt.new_ind = rtspace->qual[r.seq].
      new_ind, dt.tspace_name = rtspace->qual[r.seq].tspace_name,
      dt.install_type = rtspace->install_type, dt.install_type_value = rtspace->install_type_value,
      dt.extent_size_bytes =
      IF ((rtspace->qual[r.seq].ext_mgmt="D")) dmt_min_ext_size
      ELSE 0
      ENDIF
      ,
      dt.updt_dt_tm = cnvtdatetime(curdate,curtime), dt.extent_management = rtspace->qual[r.seq].
      ext_mgmt, dt.chunk_size = rtspace->qual[r.seq].chunk_size
     PLAN (r
      WHERE (rtspace->qual[r.seq].bytes_needed > 0))
      JOIN (dt)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
    IF ((dm_err->debug_flag > 0))
     CALL dus_debug_disp_rtspace_tspace_rec(null)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_rtspace(dlr_new_ind)
   SET dm_err->eproc = "load the tablespace in temp record structure to rTspace"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dlr_lpcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(rtspace->qual,0)
   SET rtspace->rtspace_cnt = 0
   FOR (dlr_lpcnt = 1 TO tspace_rec->tsp_rec_cnt)
     IF ((tspace_rec->tsp[dlr_lpcnt].final_bytes_to_add > 0))
      SET rtspace->rtspace_cnt = (rtspace->rtspace_cnt+ 1)
      SET stat = alterlist(rtspace->qual,rtspace->rtspace_cnt)
      SET rtspace->qual[rtspace->rtspace_cnt].tspace_name = tspace_rec->tsp[dlr_lpcnt].tsp_name
      SET rtspace->qual[rtspace->rtspace_cnt].new_ind = dlr_new_ind
      SET rtspace->qual[rtspace->rtspace_cnt].ext_mgmt = tspace_rec->tsp[dlr_lpcnt].ext_mgmt
      SET rtspace->qual[rtspace->rtspace_cnt].bytes_needed = tspace_rec->tsp[dlr_lpcnt].
      final_bytes_to_add
      SET rtspace->qual[rtspace->rtspace_cnt].chunk_size = tspace_rec->tsp[dlr_lpcnt].chunk_size
      SET rtspace->qual[rtspace->rtspace_cnt].chunks_needed = dm2floor((rtspace->qual[rtspace->
       rtspace_cnt].bytes_needed/ rtspace->qual[rtspace->rtspace_cnt].chunk_size))
     ENDIF
   ENDFOR
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_debug_disp_rtspace_tspace_rec(null)
   DECLARE ddd_log = vc
   SET ddd_log = "utc_calc_tsp.log"
   SELECT INTO value(ddd_log)
    d.seq
    FROM (dummyt d  WITH seq = value(rtspace->rtspace_cnt))
    HEAD REPORT
     "table count = ", rtspace->rtspace_cnt, row + 1,
     "Current Database = ", currdb, row + 1,
     "rTspace"
    DETAIL
     row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
     "table number = ", d.seq, row + 1,
     "tablespace_name = ", rtspace->qual[d.seq].tspace_name, row + 1,
     "bytes needed  = ", rtspace->qual[d.seq].bytes_needed, row + 1,
     "tablespace management = ", rtspace->qual[d.seq].ext_mgmt, row + 1,
     "final_bytes_to_add = ", rtspace->qual[d.seq].final_bytes_to_add, row + 1,
     "new_ind = ", rtspace->qual[d.seq].new_ind, row + 1,
     "chunk size=", rtspace->qual[d.seq].chunk_size
    WITH nocounter
   ;end select
   SELECT INTO value(ddd_log)
    d.seq
    FROM (dummyt d  WITH seq = value(tspace_rec->tsp_rec_cnt))
    HEAD REPORT
     row + 1, ";*************************************;", row + 1,
     "table count = ", tspace_rec->tsp_rec_cnt, row + 1,
     "Current Database = ", currdb, row + 1,
     "tspace_rec"
    DETAIL
     row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
     "table number = ", d.seq, row + 1,
     "tablespace_name = ", tspace_rec->tsp[d.seq].tsp_name, row + 1,
     "tablespace management = ", tspace_rec->tsp[d.seq].ext_mgmt, row + 1,
     "final_bytes_to_add = ", tspace_rec->tsp[d.seq].final_bytes_to_add, row + 1,
     "warn_flag = ", tspace_rec->tsp[d.seq].warn_flag, row + 1,
     "tablespace type = ", tspace_rec->tsp[d.seq].tsp_type, row + 1,
     "chunk size =", tspace_rec->tsp[d.seq].chunk_size
    WITH nocounter, append
   ;end select
 END ;Subroutine
 SUBROUTINE dus_post_prompt(dpp_answer_out)
   CALL clear(1,1)
   SET message = window
   CALL text(1,1,"Tablespace Maintenance MANUAL Mode")
   CALL text(3,1,"Tablespace maintenance should be completed before continuing")
   CALL text(5,1,"(V)iew Tablespace Needs, (C)ontinue, (Q)uit:")
   CALL accept(5,46,"p;cu","V"
    WHERE curaccept IN ("V", "C", "Q"))
   SET dpp_answer_out = curaccept
   CALL clear(1,1)
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_check_status(null)
   SELECT INTO "nl:"
    FROM dm2_tspace_size d
    WHERE ((d.install_status != "SUCCESS") OR (d.install_status = null))
     AND (d.install_type=rtspace->install_type)
     AND (d.install_type_value=rtspace->install_type_value)
    WITH nocounter
   ;end select
   IF (check_error("checking status of tablespace opertations")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dus_drop_rdds_trigger(null)
   SET dm_err->eproc = "DROP RDDS trigger on DM_INFO table if they are found."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE ddr_t = i4 WITH protect, noconstant
   FREE RECORD rdds_trig
   RECORD rdds_trig(
     1 cnt = i4
     1 qual[*]
       2 trig_name = vc
   )
   SET dm_err->eproc = "Checking for RDDS trigger on DM_INFO table."
   SELECT INTO "nl:"
    FROM dm2_user_triggers u
    WHERE u.table_name="DM_INFO"
    DETAIL
     IF (substring(1,6,u.trigger_name)="REFCHG")
      rdds_trig->cnt = (rdds_trig->cnt+ 1), stat = alterlist(rdds_trig->qual,rdds_trig->cnt),
      rdds_trig->qual[rdds_trig->cnt].trig_name = u.trigger_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((rdds_trig->cnt=0))
    RETURN(1)
   ENDIF
   FOR (ddr_t = 1 TO rdds_trig->cnt)
     SET dus_run_id = dum_utc_data->downtime_run_id
     SET dus_op_type = "DROP RDDS TRIGGER"
     SET dus_obj_name = trim(cnvtupper(rdds_trig->qual[ddr_t].trig_name))
     SET dus_table_name = "DM_INFO"
     SET dus_priority = 2000
     SET dus_operation = concat("rdb asis (^drop trigger ",dus_obj_name,"^) go")
     IF (dus_insert_ddl_log_rec(dus_run_id,0) != 1)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_spec_cols_nv500(null)
   DECLARE dlsn_own_name = vc WITH protect, noconstant(" ")
   DECLARE dlsn_tbl_name = vc WITH protect, noconstant(" ")
   DECLARE dlsn_col_name = vc WITH protect, noconstant(" ")
   DECLARE dlsn_pos = i4 WITH protect, noconstant(0)
   DECLARE dlsn_loc = i4 WITH protect, noconstant(0)
   SET dm_err->eproc =
   "Load non-V500 table/columns requiring special conversion logic from ADMIN DM_INFO table to record."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
       "_UTC_DATA - NON-V500 APPLY STD CONVERSION ONLY")))
    DETAIL
     dlsn_loc = findstring("/",i.info_name,1,0), dlsn_own_name = substring(1,(dlsn_loc - 1),i
      .info_name), dlsn_pos = findstring("/",i.info_name,1,1)
     IF (dlsn_pos=dlsn_loc)
      dm_err->err_ind = 1, dm_err->emsg = concat(trim(i.info_name),
       " format is invalid. Valid format is USER/TABLE/COLUMN."),
      CALL cancel(1)
     ENDIF
     dlsn_tbl_name = substring((dlsn_loc+ 1),((dlsn_pos - dlsn_loc) - 1),i.info_name), dlsn_col_name
      = substring((dlsn_pos+ 1),size(i.info_name),i.info_name), dus_nv500_std_convert_list->cnt = (
     dus_nv500_std_convert_list->cnt+ 1)
     IF (mod(dus_nv500_std_convert_list->cnt,10)=1)
      stat = alterlist(dus_nv500_std_convert_list->qual,(dus_nv500_std_convert_list->cnt+ 9))
     ENDIF
     dus_nv500_std_convert_list->qual[dus_nv500_std_convert_list->cnt].own_name = dlsn_own_name,
     dus_nv500_std_convert_list->qual[dus_nv500_std_convert_list->cnt].tbl_name = dlsn_tbl_name,
     dus_nv500_std_convert_list->qual[dus_nv500_std_convert_list->cnt].col_name = dlsn_col_name,
     dus_nv500_std_convert_list->qual[dus_nv500_std_convert_list->cnt].no_convert_ind = i.info_number
    FOOT REPORT
     stat = alterlist(dus_nv500_std_convert_list->qual,dus_nv500_std_convert_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_nv500_std_convert_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_sort_dst_year(null)
   FREE RECORD dsdy_dst_sort
   RECORD dsdy_dst_sort(
     1 cnt = i4
     1 qual[*]
       2 year = vc
       2 start_dt_tm = dq8
       2 end_dt_tm = dq8
   )
   DECLARE dsdy_cur_year = i4 WITH protect, noconstant(year(curdate))
   DECLARE dsdy_past_year = i4 WITH protect, noconstant((dsdy_cur_year - 20))
   DECLARE dsdy_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dsdy_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Sort DST Year from ",trim(cnvtstring(dsdy_cur_year))," to ",trim(
     cnvtstring(dsdy_past_year)))
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dus_dst_accept->cnt))
    WHERE cnvtint(dus_dst_accept->qual[d.seq].year) < dsdy_cur_year
     AND cnvtint(dus_dst_accept->qual[d.seq].year) >= dsdy_past_year
    ORDER BY dus_dst_accept->qual[d.seq].year DESC
    DETAIL
     dsdy_dst_sort->cnt = (dsdy_dst_sort->cnt+ 1), stat = alterlist(dsdy_dst_sort->qual,dsdy_dst_sort
      ->cnt), dsdy_dst_sort->qual[dsdy_dst_sort->cnt].year = dus_dst_accept->qual[d.seq].year,
     dsdy_dst_sort->qual[dsdy_dst_sort->cnt].start_dt_tm = dus_dst_accept->qual[d.seq].start_dt_tm,
     dsdy_dst_sort->qual[dsdy_dst_sort->cnt].end_dt_tm = dus_dst_accept->qual[d.seq].end_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   SET dsdy_cur_idx = locateval(dsdy_cur_idx,1,dus_dst_accept->cnt,trim(cnvtstring(dsdy_cur_year)),
    dus_dst_accept->qual[dsdy_cur_idx].year)
   IF (dsdy_cur_idx > 0)
    SET dsdy_dst_sort->cnt = (dsdy_dst_sort->cnt+ 1)
    SET stat = alterlist(dsdy_dst_sort->qual,dsdy_dst_sort->cnt)
    SET dsdy_dst_sort->qual[dsdy_dst_sort->cnt].year = dus_dst_accept->qual[dsdy_cur_idx].year
    SET dsdy_dst_sort->qual[dsdy_dst_sort->cnt].start_dt_tm = dus_dst_accept->qual[dsdy_cur_idx].
    start_dt_tm
    SET dsdy_dst_sort->qual[dsdy_dst_sort->cnt].end_dt_tm = dus_dst_accept->qual[dsdy_cur_idx].
    end_dt_tm
   ENDIF
   SET dm_err->eproc = concat("Sort DST Year from ",trim(cnvtstring((dsdy_past_year - 1)))," to ",
    trim(cnvtstring(dus_dst_accept->start_year)))
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dus_dst_accept->cnt))
    WHERE cnvtint(dus_dst_accept->qual[d.seq].year) < dsdy_past_year
     AND (cnvtint(dus_dst_accept->qual[d.seq].year) >= dus_dst_accept->start_year)
    ORDER BY dus_dst_accept->qual[d.seq].year DESC
    DETAIL
     dsdy_dst_sort->cnt = (dsdy_dst_sort->cnt+ 1), stat = alterlist(dsdy_dst_sort->qual,dsdy_dst_sort
      ->cnt), dsdy_dst_sort->qual[dsdy_dst_sort->cnt].year = dus_dst_accept->qual[d.seq].year,
     dsdy_dst_sort->qual[dsdy_dst_sort->cnt].start_dt_tm = dus_dst_accept->qual[d.seq].start_dt_tm,
     dsdy_dst_sort->qual[dsdy_dst_sort->cnt].end_dt_tm = dus_dst_accept->qual[d.seq].end_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Sort DST Year from ",trim(cnvtstring((dsdy_cur_year+ 1)))," to ",trim(
     cnvtstring(dus_dst_accept->end_year)))
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dus_dst_accept->cnt))
    WHERE (cnvtint(dus_dst_accept->qual[d.seq].year) <= dus_dst_accept->end_year)
     AND cnvtint(dus_dst_accept->qual[d.seq].year) > dsdy_cur_year
    ORDER BY dus_dst_accept->qual[d.seq].year
    DETAIL
     dsdy_dst_sort->cnt = (dsdy_dst_sort->cnt+ 1), stat = alterlist(dsdy_dst_sort->qual,dsdy_dst_sort
      ->cnt), dsdy_dst_sort->qual[dsdy_dst_sort->cnt].year = dus_dst_accept->qual[d.seq].year,
     dsdy_dst_sort->qual[dsdy_dst_sort->cnt].start_dt_tm = dus_dst_accept->qual[d.seq].start_dt_tm,
     dsdy_dst_sort->qual[dsdy_dst_sort->cnt].end_dt_tm = dus_dst_accept->qual[d.seq].end_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dsdy_dst_sort)
   ENDIF
   SET dus_dst_accept->cnt = 0
   SET stat = alterlist(dus_dst_accept->qual,0)
   FOR (dsdy_idx = 1 TO dsdy_dst_sort->cnt)
     SET dus_dst_accept->cnt = (dus_dst_accept->cnt+ 1)
     SET stat = alterlist(dus_dst_accept->qual,dus_dst_accept->cnt)
     SET dus_dst_accept->qual[dus_dst_accept->cnt].year = dsdy_dst_sort->qual[dsdy_idx].year
     SET dus_dst_accept->qual[dus_dst_accept->cnt].start_dt_tm = dsdy_dst_sort->qual[dsdy_idx].
     start_dt_tm
     SET dus_dst_accept->qual[dus_dst_accept->cnt].end_dt_tm = dsdy_dst_sort->qual[dsdy_idx].
     end_dt_tm
   ENDFOR
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_dst_accept)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_mng_utc_status(null)
   DECLARE dmus_pkg_ind = i2 WITH protect, noconstant(0)
   DECLARE dmus_appl_status = c1 WITH protect, noconstant(" ")
   IF ((dum_utc_data->in_process=0))
    IF (dus_check_pkg(dmus_pkg_ind)=0)
     RETURN(0)
    ENDIF
    IF (dmus_pkg_ind=1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Checking for packages that are running DDLs."
     SET dm_err->emsg = "There are currently DDL running.  Please try again later."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dus_set_schema_date(null)=0)
     RETURN(0)
    ENDIF
    IF (dus_set_run_id(null)=0)
     RETURN(0)
    ENDIF
    SET dum_utc_data->status = "SETUP_START"
    SET dm_err->eproc = "Insert into ADMIN dm_info that puts the database in UTC CONVERSION mode."
    INSERT  FROM dm2_admin_dm_info di
     SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
         "_UTC_DATA_STATUS"))), di.info_name = dum_utc_data->status, di.info_number = dum_utc_data->
      schema_date,
      di.info_char = currdbhandle, di.info_number = 0, di.info_date = null,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
    SET dum_utc_data->in_process = 1
   ELSE
    IF ((dum_utc_data->status IN ("SETUP_COMPLETE", "SETUP_START")))
     SET dmus_appl_status = dm2_get_appl_status(dum_utc_data->appl_id)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("dmus_appl_status =",dmus_appl_status))
     ENDIF
     IF (dmus_appl_status="A")
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating UTC conversion option."
      SET dm_err->emsg = "SETUP for UTC conversion is currently running under another session."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (dmus_appl_status="I")
      SET dum_utc_data->status = "SETUP_START"
      SET dm_err->eproc = "Update ADMIN DM_INFO table with currdbhandle."
      UPDATE  FROM dm2_admin_dm_info di
       SET di.info_char = currdbhandle, di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
          "_UTC_DATA_STATUS")))
        AND (di.info_name=dum_utc_data->status)
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ELSEIF (dmus_appl_status="E")
      RETURN(0)
     ENDIF
    ENDIF
    IF ((dum_utc_data->status IN ("UPTIME", "RESTART", "HOLD")))
     IF (dus_check_pkg(dmus_pkg_ind)=0)
      RETURN(0)
     ENDIF
     IF (dmus_pkg_ind=1)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Checking for packages that are running DDLs."
      SET dm_err->emsg = "There are currently DDL running.  Please try again later."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dum_utc_data->status = "SETUP_START"
     SET dm_err->eproc = "Update ADMIN DM_INFO table with UTC status SETUP START."
     UPDATE  FROM dm2_admin_dm_info di
      SET di.info_name = dum_utc_data->status, di.info_char = currdbhandle, di.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
         "_UTC_DATA_STATUS")))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
    IF ((dum_utc_data->status IN ("DOWNTIME", "COMPLETE")))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating UTC process status."
     SET dm_err->emsg = concat("This step is not VALID.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_mng_utc_src_info(null)
   DECLARE dmusi_src_envname = vc WITH protect, noconstant("")
   DECLARE dmusi_src_dbname = vc WITH protect, noconstant("")
   DECLARE dmusi_info_name = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get the Source Environment name."
   SELECT
    IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
     FROM dm_info@ref_data_link di
     WHERE info_domain="DATA MANAGEMENT"
      AND info_name="DM_ENV_NAME"
    ELSE
     FROM dm_info di
     WHERE info_domain="DATA MANAGEMENT"
      AND info_name="DM_ENV_NAME"
    ENDIF
    INTO "nl:"
    DETAIL
     dmusi_src_envname = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Get the Source Database name."
   IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
    IF (dm2_get_remote_dbase_name("ref_data_link",dmusi_src_dbname)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_get_dbase_name(dmusi_src_dbname)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dmusi_info_name = cnvtupper(build("SOURCE_",dmusi_src_envname,"_",dmusi_src_dbname))
   SET dm_err->eproc = "Check ADMIN dm_info if row already exists prior to insert."
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA")
      ))
     AND di.info_name=dmusi_info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Insert into ADMIN dm_info when process is MIGRATION/UTC or UTC"
    INSERT  FROM dm2_admin_dm_info di
     SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"
         ))), di.info_name = dmusi_info_name
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = "Insert into ADMIN dm_info row with mode as MIGRATION/UTC or UTC"
    INSERT  FROM dm2_admin_dm_info di
     SET di.info_domain = patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"_UTC_DATA"
         ))), di.info_name = patstring(cnvtupper(build("MODE_",dm2_install_schema->process_option)))
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_datafiles(null)
   DECLARE dld_ts_cnt = i4 WITH protect, noconstant(0)
   DECLARE dld_df_cnt = i4 WITH protect, noconstant(0)
   DECLARE dld_delim = vc WITH proetect, noconstant("")
   DECLARE dld_file = vc WITH protect, noconstant("")
   DECLARE dld_spot = i4 WITH protect, noconstant(0)
   DECLARE dld_dg_ndx = i4 WITH protect, noconstant(0)
   DECLARE dld_dg_cnt = i4 WITH protect, noconstant(0)
   DECLARE dld_loc = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get list of datafiles from DM2_DBA_DATA_FILES"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_dba_data_files df,
     (dummyt d  WITH seq = size(rtspace->qual,5))
    PLAN (d
     WHERE (rtspace->qual[d.seq].new_ind=0))
     JOIN (df
     WHERE (df.tablespace_name=rtspace->qual[d.seq].tspace_name))
    ORDER BY df.tablespace_name
    HEAD REPORT
     dls_ts_cnt = 0
    HEAD df.tablespace_name
     dld_df_cnt = 0
    DETAIL
     dld_delim = "/", dld_spot = findstring(dld_delim,df.file_name,2,0), dld_loc = findstring("(",df
      .file_name,2,0)
     IF (dld_loc > 0
      AND dld_loc < dld_spot)
      dld_spot = findstring("(",df.file_name,2,0), dld_delim = "("
     ENDIF
     dld_loc = findstring(".",df.file_name,2,0)
     IF (dld_loc > 0
      AND dld_loc < dld_spot)
      dld_delim = "."
     ENDIF
     dld_df_cnt = (dld_df_cnt+ 1), stat = alterlist(rtspace->qual[d.seq].cont,dld_df_cnt), rtspace->
     qual[d.seq].cont[dld_df_cnt].cont_size_mb = convert_bytes(df.bytes,"b","m"),
     rtspace->qual[d.seq].cont[dld_df_cnt].disk_name = substring(2,(findstring(dld_delim,df.file_name,
       2,0) - 2),df.file_name), rtspace->qual[d.seq].cont_cnt = dld_df_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_rpt_exist_tsp_needs_by_dg(detnbd_file,detnbd_exist_space_needs)
   DECLARE detnbd_cnt = i4 WITH protect, noconstant(0)
   DECLARE detnbd_ndx = i4 WITH protect, noconstant(0)
   DECLARE detnbd_df_cnt = i4 WITH protect, noconstant(0)
   DECLARE detnbd_dg_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD detnbd_dg
   RECORD detnbd_dg(
     1 qual[*]
       2 dg_name = vc
       2 mb_needed = f8
       2 free_space = f8
   )
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(rtspace)
   ENDIF
   IF (size(rtspace->qual,5)=0)
    RETURN(1)
   ENDIF
   SET detnbd_exist_space_needs = 0
   FOR (detnbd_cnt = 1 TO size(rtspace->qual,5))
     IF ((rtspace->qual[detnbd_cnt].new_ind=0)
      AND (rtspace->qual[detnbd_cnt].bytes_needed > 0))
      FOR (detnbd_df_cnt = 1 TO size(rtspace->qual[detnbd_cnt].cont,5))
        SET detnbd_exist_space_needs = 1
        IF (size(detnbd_dg->qual,5)=0)
         SET detnbd_dg_cnt = (detnbd_dg_cnt+ 1)
         SET stat = alterlist(detnbd_dg->qual,detnbd_dg_cnt)
         SET detnbd_dg->qual[detnbd_dg_cnt].dg_name = rtspace->qual[detnbd_cnt].cont[detnbd_df_cnt].
         disk_name
        ELSE
         IF (locateval(detnbd_ndx,1,size(detnbd_dg->qual,5),rtspace->qual[detnbd_cnt].cont[
          detnbd_df_cnt].disk_name,detnbd_dg->qual[detnbd_ndx].dg_name)=0)
          SET detnbd_dg_cnt = (detnbd_dg_cnt+ 1)
          SET stat = alterlist(detnbd_dg->qual,detnbd_dg_cnt)
          SET detnbd_dg->qual[detnbd_dg_cnt].dg_name = rtspace->qual[detnbd_cnt].cont[detnbd_df_cnt].
          disk_name
         ENDIF
        ENDIF
        SET detnbd_dg->qual[detnbd_dg_cnt].mb_needed = (detnbd_dg->qual[detnbd_dg_cnt].mb_needed+
        convert_bytes((rtspace->qual[detnbd_cnt].bytes_needed/ size(rtspace->qual[detnbd_cnt].cont,5)
         ),"b","m"))
      ENDFOR
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Get free space for disk groups."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(detnbd_dg)
   ENDIF
   IF (size(detnbd_dg->qual,5)=0)
    CALL echo("No existing tablespaces which require space.")
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM v$asm_diskgroup v,
     (dummyt d  WITH seq = size(detnbd_dg->qual,5))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (v
     WHERE (detnbd_dg->qual[d.seq].dg_name=v.name))
    DETAIL
     detnbd_dg->qual[d.seq].free_space = v.free_mb
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(detnbd_dg)
   ENDIF
   SET dm_err->eproc = "Create the DG Space Needed report."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(detnbd_file)
    FROM (dummyt d  WITH seq = size(detnbd_dg->qual,5))
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     col 0, "Tablespace Maintenance Report", row + 2,
     col 0,
     "The following report contains disk groups and their calculated space needs that should be verified before continuing.",
     row + 1,
     col 0, "Failure to do this may result in schema failures due to lack of adequate tablespace. ",
     row + 1,
     col 0, "Example SQL commands can be found following the Glossary section.", row + 2,
     col 0, "Calculated Space Needs :  ", row + 2,
     col 0, "                                                  Calculated        Free  ", row + 1,
     col 0, "                                                  Space Needed      Space  ", row + 1,
     col 0, "  Disk Group                                       (MBYTES)        (MBYTES) ", row + 1,
     col 0, "  ___________________                           _______________   ____________ ", row +
     2
    DETAIL
     col 2, detnbd_dg->qual[d.seq].dg_name, col 49,
     detnbd_dg->qual[d.seq].mb_needed, col 64, detnbd_dg->qual[d.seq].free_space,
     row + 1
    FOOT REPORT
     row + 2, col 0, "Glossary: Interpreting the Tablespace Maintenance Report:",
     row + 2, col 0,
     "Disk Group           A logical collection of a number of physical disk devices.",
     row + 2, col 0, "Calculated",
     row + 1, col 0,
     "Space Needed         Amount of space calculated for one or more tablespaces required to",
     row + 1, col 0,
     "                        complete the schema and data load rolled up to their disk group assignment.",
     row + 2, col 0,
     "Free Space           Amount of disk group space available for use by the database.",
     row + 2
    WITH nocounter, maxcol = 500, append
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_tspace_driver(null)
   DECLARE dtd_exist_needs_space = i2 WITH protect, noconstant(0)
   DECLARE dtd_exist_rpt_filename = vc WITH protect, noconstant("")
   DECLARE dtd_new_chk = i4 WITH protect, noconstant(0)
   DECLARE dtd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtd_answer_ret = vc WITH protect, noconstant("")
   IF ((dir_storage_misc->tgt_storage_type="DM2NOTSET"))
    IF (dir_get_storage_type(" ")=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_storage_misc->tgt_storage_type != "ASM"))
    SET dm_err->eproc = concat(dir_storage_misc->tgt_storage_type," Storage type is not supported.")
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dus_apply_sizing(null)=0)
    RETURN(0)
   ENDIF
   IF (dus_load_tspace(null)=0)
    RETURN(0)
   ENDIF
   IF (dus_calc_tspace_needs(null)=0)
    RETURN(0)
   ENDIF
   IF (get_unique_file("dm2_tsp_needs_by_dg",".rpt")=0)
    RETURN(0)
   ENDIF
   SET dtd_exist_rpt_filename = dm_err->unique_fname
   IF (locateval(dtd_new_chk,1,size(rtspace->qual,5),0,rtspace->qual[dtd_new_chk].new_ind) > 0)
    IF (dus_load_datafiles(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dus_rpt_exist_tsp_needs_by_dg(dtd_exist_rpt_filename,dtd_exist_needs_space)=0)
    RETURN(0)
   ENDIF
   IF (locateval(dtd_new_chk,1,size(rtspace->qual,5),1,rtspace->qual[dtd_new_chk].new_ind) > 0)
    FOR (dtd_cnt = 1 TO size(rtspace->qual,5))
      IF ((rtspace->qual[dtd_cnt].new_ind=0))
       SET rtspace->qual[dtd_cnt].bytes_needed = 0
      ENDIF
    ENDFOR
    EXECUTE dm2_tspace_menu
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (dus_load_datafiles(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dtd_exist_needs_space > 0)
    IF (dm2_disp_file(dtd_exist_rpt_filename,concat("Report File may be found in CCLUSERDIR:",
      dtd_exist_rpt_filename))=0)
     RETURN(0)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
   WHILE ( NOT (dtd_answer_ret IN ("C", "Q")))
    IF (dus_post_prompt(dtd_answer_ret)=0)
     RETURN(0)
    ENDIF
    CASE (dtd_answer_ret)
     OF "V":
      IF (dm2_disp_file(dtd_exist_rpt_filename,concat("Report File may be found in CCLUSERDIR:",
        dtd_exist_rpt_filename))=0)
       RETURN(0)
      ENDIF
     OF "Q":
      SET dm_err->emsg = "User Chose to Quit from Tablespace Maintenance Prompt."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
    ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_alter_visibility(dav_t,dav_ind_name)
   SET dus_run_id = dum_utc_data->uptime_run_id
   SET dus_op_type = "ALTER INDEX NOPARALLEL"
   SET dus_obj_name = trim(cnvtupper(dav_ind_name))
   SET dus_table_name = trim(tgtsch->tbl[dav_t].tbl_name)
   SET dus_priority = 341
   SET dus_operation = concat("RDB ASIS (^ ALTER INDEX ",dus_curr_owner,".",trim(dus_obj_name),
    " NOPARALLEL ^) GO")
   IF (dus_insert_ddl_log_rec(dus_run_id,dav_t)=0)
    RETURN(0)
   ENDIF
   SET dus_run_id = dum_utc_data->uptime_run_id
   SET dus_op_type = "ALTER INDEX VISIBLE"
   SET dus_obj_name = trim(cnvtupper(dav_ind_name))
   SET dus_table_name = trim(tgtsch->tbl[dav_t].tbl_name)
   SET dus_priority = 342
   IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3=0)
    AND (dm2_rdbms_version->level4 >= 4))) )) )) )
    SET dus_operation = concat('DM2_FINISH_INDEX "',trim(dus_curr_owner),'","',trim(dus_table_name),
     '","',
     trim(dus_curr_owner),'","',trim(dus_obj_name),'" GO')
   ELSE
    SET dus_operation = concat("RDB ASIS (^ ALTER INDEX ",dus_curr_owner,".",trim(dus_obj_name),
     " VISIBLE ^) GO")
   ENDIF
   IF (dus_insert_ddl_log_rec(dus_run_id,dav_t)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_alter_invisible(dai_t,dai_orig_ind_name)
   SET dus_run_id = dum_utc_data->downtime_run_id
   SET dus_op_type = "ALTER INDEX INVISIBLE"
   SET dus_obj_name = trim(cnvtupper(dai_orig_ind_name))
   SET dus_priority = 1340
   SET dus_operation = concat("RDB ASIS (^ ALTER INDEX ",dus_curr_owner,".",trim(dus_obj_name),
    " INVISIBLE ^) GO")
   IF (dus_insert_ddl_log_rec(dus_run_id,dai_t)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_parse_dst_file(dpdf_file)
   SET dm_err->eproc = concat("Parse out file ",dpdf_file)
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET dus_filename
   SET logical dus_filename value(dpdf_file)
   DEFINE rtl2 "dus_filename"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t t
    WHERE t.line > " "
    HEAD REPORT
     MACRO (check_dt_format)
      dus_tmp_size = size(dus_tmp_dt_tm)
      IF (dus_tmp_size != 20)
       dus_file_error = 1
      ELSE
       IF (cnvtint(substring(1,2,dus_tmp_dt_tm))=0)
        dus_file_error = 1
       ELSE
        IF (substring(3,1,dus_tmp_dt_tm) != "-")
         dus_file_error = 1
        ELSE
         IF (cnvtint(substring(4,3,dus_tmp_dt_tm)) > 0)
          dus_file_error = 1
         ELSE
          IF (substring(7,1,dus_tmp_dt_tm) != "-")
           dus_file_error = 1
          ELSE
           IF (cnvtint(substring(8,4,dus_tmp_dt_tm))=0)
            dus_file_error = 1
           ELSE
            IF (substring(15,1,dus_tmp_dt_tm) != ":")
             dus_file_error = 1
            ELSE
             IF (substring(18,1,dus_tmp_dt_tm) != ":")
              dus_file_error = 1
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDMACRO
     , beg_pos = 1, end_pos = 0,
     header = 0, cnt = 0, length = 0
    DETAIL
     IF (dus_file_error=0)
      header = 0, beg_pos = 1, end_pos = 0,
      cnt = (cnt+ 1), length = size(trim(t.line))
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("length = ",length))
      ENDIF
      end_pos = findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      dus_tmp_year = substring(beg_pos,(end_pos - beg_pos),t.line)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("dus_tmp_year =",dus_tmp_year))
      ENDIF
      IF (cnvtint(dus_tmp_year)=0)
       IF (cnt=1)
        header = 1
       ELSE
        dus_file_error = 1
       ENDIF
      ELSE
       IF ((dus_dst_accept->start_year=0)
        AND (dus_dst_accept->end_year=0))
        dus_dst_accept->start_year = cnvtint(dus_tmp_year), dus_dst_accept->end_year = cnvtint(
         dus_tmp_year)
       ELSEIF ((cnvtint(dus_tmp_year) < dus_dst_accept->start_year))
        dus_dst_accept->start_year = cnvtint(dus_tmp_year)
       ELSEIF ((cnvtint(dus_tmp_year) > dus_dst_accept->end_year))
        dus_dst_accept->end_year = cnvtint(dus_tmp_year)
       ENDIF
       dus_dst_accept->cnt = (dus_dst_accept->cnt+ 1)
       IF (mod(dus_dst_accept->cnt,10)=1)
        stat = alterlist(dus_dst_accept->qual,(dus_dst_accept->cnt+ 9))
       ENDIF
       dus_dst_accept->qual[dus_dst_accept->cnt].year = dus_tmp_year
      ENDIF
      IF (header=0
       AND dus_file_error=0)
       beg_pos = (end_pos+ 1), end_pos = findstring(",",t.line,beg_pos,0)
       IF ((dm_err->debug_flag > 2))
        CALL echo(build("end_pos =",end_pos))
       ENDIF
       dus_tmp_dt_tm = substring(beg_pos,(end_pos - beg_pos),t.line)
       IF ((dm_err->debug_flag > 2))
        CALL echo(build("dus_tmp_dt_tm =",dus_tmp_dt_tm))
       ENDIF
       check_dt_format
       IF (dus_file_error=0)
        dus_dst_accept->qual[dus_dst_accept->cnt].start_dt_tm = cnvtdatetime(dus_tmp_dt_tm), beg_pos
         = (end_pos+ 1), end_pos = length
        IF ((dm_err->debug_flag > 2))
         CALL echo(build("end_pos =",end_pos))
        ENDIF
        dus_tmp_dt_tm = substring(beg_pos,((end_pos - beg_pos)+ 1),t.line)
        IF ((dm_err->debug_flag > 2))
         CALL echo(build("dus_tmp_dt_tm =",dus_tmp_dt_tm))
        ENDIF
        check_dt_format
        IF (dus_file_error=0)
         dus_dst_accept->qual[dus_dst_accept->cnt].end_dt_tm = cnvtdatetime(dus_tmp_dt_tm)
        ENDIF
       ENDIF
      ENDIF
      IF (dus_file_error=1)
       dm_err->err_ind = 1, dm_err->emsg = build("File ",trim(dus_utc_dst_file),
        " has incorrect format on line ",cnt)
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dus_dst_accept->qual,dus_dst_accept->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dus_file_error=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((dus_dst_accept->cnt > 0))
    SET dus_input_file_ind = 1
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dus_dst_accept)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF ((dm_err->debug_flag > 5))
  CALL echorecord(tgtsch)
 ENDIF
 SET dus_err_ind = dm_err->err_ind
 SET dus_err_msg = dm_err->emsg
 SET dus_eproc = dm_err->eproc
 SET dm_err->err_ind = 0
 CALL dum_check_concurrent_snapshot("D")
 IF ((dm_err->err_ind=0))
  SET dm_err->err_ind = dus_err_ind
  SET dm_err->emsg = dus_err_msg
  SET dm_err->eproc = dus_eproc
 ENDIF
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Ending DM2_UTC_SETUP"
 ENDIF
 CALL final_disp_msg("dm2_utc_setup")
END GO
