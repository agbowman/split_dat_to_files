CREATE PROGRAM dm2_queue_dbstats:dba
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
 DECLARE dm2_get_program_details(null) = vc
 SUBROUTINE dm2_get_program_details(null)
   DECLARE dgpd_param_num = i2 WITH protect, noconstant(1)
   DECLARE dgpd_param_type = vc WITH protect, noconstant("")
   DECLARE dgpd_param_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgpd_details = vc WITH protect, noconstant("~")
   WHILE (dgpd_param_num)
    IF (assign(dgpd_param_type,reflect(parameter(dgpd_param_num,0)))="")
     SET dgpd_param_cnt = (dgpd_param_num - 1)
     SET dgpd_param_num = 0
     IF (dgpd_param_cnt=0)
      RETURN("")
     ELSE
      RETURN(substring(3,size(dgpd_details),dgpd_details))
     ENDIF
    ELSE
     SET dgpd_details = build(dgpd_details,",")
     IF (substring(1,1,dgpd_param_type)="C")
      SET dgpd_details = build(dgpd_details,'"',parameter(dgpd_param_num,0),'"')
     ELSE
      SET dgpd_details = build(dgpd_details,parameter(dgpd_param_num,0))
     ENDIF
    ENDIF
    SET dgpd_param_num = (dgpd_param_num+ 1)
   ENDWHILE
 END ;Subroutine
 DECLARE dm2_process_log_row(process_name=vc,action_type=vc,prev_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_dtl_row(dpldr_event_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_add_detail_text(detail_type=vc,detail_text=vc) = null
 DECLARE dm2_process_log_add_detail_date(detail_type=vc,detail_date=dq8) = null
 DECLARE dm2_process_log_add_detail_number(detail_type=vc,detail_number=f8) = null
 DECLARE dpl_upd_dped_last_status(dudls_event_id=f8,dudls_text=vc,dudls_number=f8,dudls_date=dq8) =
 i2
 DECLARE dpl_ui_chk(duc_process_name=vc) = i2
 IF ((validate(dm2_process_rs->cnt,- (1))=- (1))
  AND (validate(dm2_process_rs->cnt,- (2))=- (2)))
  FREE RECORD dm2_process_rs
  RECORD dm2_process_rs(
    1 dbase_name = vc
    1 table_exists_ind = i2
    1 filled_ind = i2
    1 dm_process_id = f8
    1 process_name = vc
    1 cnt = i4
    1 qual[*]
      2 dm_process_id = f8
      2 process_name = vc
      2 program_name = vc
      2 action_type = vc
      2 search_string = vc
  )
  FREE RECORD dm2_process_event_rs
  RECORD dm2_process_event_rs(
    1 dm_process_event_id = f8
    1 status = vc
    1 message = vc
    1 ui_allowed_ind = i2
    1 install_plan_id = f8
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 detail_cnt = i4
    1 itinerary_key = vc
    1 itinerary_process_event_id = f8
    1 details[*]
      2 detail_type = vc
      2 detail_number = f8
      2 detail_text = vc
      2 detail_date = dq8
  )
  SET dm2_process_event_rs->ui_allowed_ind = 0
 ENDIF
 IF (validate(dpl_index_monitoring,"X")="X"
  AND validate(dpl_index_monitoring,"Y")="Y")
  DECLARE dpl_username = vc WITH protect, constant(curuser)
  DECLARE dpl_no_prev_id = f8 WITH protect, constant(0.0)
  DECLARE dpl_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpl_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpl_failed = vc WITH protect, constant("FAILED")
  DECLARE dpl_complete = vc WITH protect, constant("COMPLETE")
  DECLARE dpl_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpl_paused = vc WITH protect, constant("PAUSED")
  DECLARE dpl_confirmation = vc WITH protect, constant("CONFIRMATION")
  DECLARE dpl_decline = vc WITH protect, constant("DECLINE")
  DECLARE dpl_stopped = vc WITH protect, constant("STOPPED")
  DECLARE dpl_statistics = vc WITH protect, constant("DATABASE STATISTICS GATHERING")
  DECLARE dpl_cbo = vc WITH protect, constant("CBO IMPLEMENTER")
  DECLARE dpl_db_services = vc WITH protect, constant("DATABASE SERVICES")
  DECLARE dpl_package_install = vc WITH protect, constant("PACKAGE INSTALL")
  DECLARE dpl_install_runner = vc WITH protect, constant("INSTALL RUNNER")
  DECLARE dpl_background_runner = vc WITH protect, constant("BACKGROUND RUNNER")
  DECLARE dpl_install_monitor = vc WITH protect, constant("INSTALL MONITOR")
  DECLARE dpl_status_change = vc WITH protect, constant("STATUS CHANGE")
  DECLARE dpl_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpl_process_queue_runner = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER")
  DECLARE dpl_process_queue_single = vc WITH protect, constant("DM_PROCESS_QUEUE SINGLE")
  DECLARE dpl_process_queue_wrapper = vc WITH protect, constant("DM_PROCESS_QUEUE WRAPPER")
  DECLARE dpl_routine_tasks = vc WITH protect, constant("ROUTINE TASKS")
  DECLARE dpl_coalesce = vc WITH protect, constant("INDEX COALESCING")
  DECLARE dpl_custom_user_mgmt = vc WITH protect, constant("CUSTOM USERS MANAGEMENT")
  DECLARE dpl_xnt_clinical_ranges = vc WITH protect, constant(
   "ESTABLISH EXTRACT & TRANSFORM(XNT) CLINICAL RANGES")
  DECLARE dpl_cbo_stats = vc WITH protect, constant("CBO STATISTICS MANAGEMENT")
  DECLARE dpl_oragen3 = vc WITH protect, constant("ORAGEN3")
  DECLARE dpl_cap_desired_schema = vc WITH protect, constant("CAPTURE DESIRED SCHEMA")
  DECLARE dpl_app_desired_schema = vc WITH protect, constant("APPLY DESIRED SCHEMA")
  DECLARE dpl_ccl_grant = vc WITH protect, constant("CCL GRANTS")
  DECLARE dpl_plan_control = vc WITH protect, constant("PLAN CONTROL")
  DECLARE dpl_cleanup_stats_rows = vc WITH protect, constant("CLEANUP STATS ROWS")
  DECLARE dpl_index_monitoring = vc WITH protect, constant("INDEX MONITORING")
  DECLARE dpl_admin_upgrade = vc WITH protect, constant("ADMIN UPGRADE")
  DECLARE dpl_execution = vc WITH protect, constant("EXECUTION")
  DECLARE dpl_enable_table_monitoring = vc WITH protect, constant("TABLE MONITORING ENABLE")
  DECLARE dpl_table_stats_gathering = vc WITH protect, constant("GATHER TABLE STATS")
  DECLARE dpl_index_stats_gathering = vc WITH protect, constant("GATHER INDEX STATS")
  DECLARE dpl_system_stats_gathering = vc WITH protect, constant("GATHER SYSTEM STATS")
  DECLARE dpl_schema_stats_gathering = vc WITH protect, constant("GATHER SCHEMA STATS")
  DECLARE dpl_itinerary_event = vc WITH protect, constant("ITINERARY EVENT")
  DECLARE dpl_alter_index_monitoring = vc WITH protect, constant("ALTER_INDEX_MONITORING")
  DECLARE dpl_cbo_reset_script_manual = vc WITH protect, constant("CBO RESET SCRIPT MANUAL")
  DECLARE dpl_cbo_reset_script_recompile = vc WITH protect, constant("CBO RESET SCRIPT RECOMPILE")
  DECLARE dpl_cbo_reset_query_manual = vc WITH protect, constant("CBO RESET QUERY MANUAL")
  DECLARE dpl_cbo_reset_all = vc WITH protect, constant("CBO RESET ALL")
  DECLARE dpl_cbo_enable = vc WITH protect, constant("CBO ENABLED")
  DECLARE dpl_cbo_disable = vc WITH protect, constant("CBO DISABLE")
  DECLARE dpl_cbo_monitoring_init = vc WITH protect, constant("CBO MONITORING INITIATED")
  DECLARE dpl_cbo_monitoring_complete = vc WITH protect, constant("CBO MONITORING COMPLETE")
  DECLARE dpl_cbo_tuning_change = vc WITH protect, constant("CBO TUNING CHANGE")
  DECLARE dpl_cbo_tuning_nochange = vc WITH protect, constant("CBO TUNING NOCHANGE")
  DECLARE dpl_data_dump = vc WITH protect, constant("CBO DATA DUMP")
  DECLARE dpl_data_dump_purge = vc WITH protect, constant("CBO DATA DUMP PURGE")
  DECLARE dpl_activate_all = vc WITH protect, constant("ACTIVATE ALL SERVICES")
  DECLARE dpl_instance_activation = vc WITH protect, constant("ACTIVATE SERVICES BY INSTANCE")
  DECLARE dpl_tns_deployment = vc WITH protect, constant("TNS DEPLOYMENT")
  DECLARE dpl_svc_reg_upd = vc WITH protect, constant("REGISTRY SERVER UPDATE")
  DECLARE dpl_notification = vc WITH protect, constant("NOTIFICATION")
  DECLARE dpl_auditlog = vc WITH protect, constant("AUDITLOG")
  DECLARE dpl_snapshot = vc WITH protect, constant("SNAPSHOT")
  DECLARE dpl_purge = vc WITH protect, constant("CUSTOM-DELETE")
  DECLARE dpl_table = vc WITH protect, constant("TABLE")
  DECLARE dpl_index = vc WITH protect, constant("INDEX")
  DECLARE dpl_system = vc WITH protect, constant("SYSTEM")
  DECLARE dpl_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpl_cmd = vc WITH protect, constant("COMMAND")
  DECLARE dpl_est_pct = vc WITH protect, constant("ESTIMATE PERCENT")
  DECLARE dpl_owner = vc WITH protect, constant("OWNER")
  DECLARE dpl_method_opt = vc WITH protect, constant("METHOD OPT")
  DECLARE dpl_num_attempts = vc WITH protect, constant("NUM ATTEMPTS")
  DECLARE dpl_dm_sql_id = vc WITH protect, constant("DM_SQL_ID")
  DECLARE dpl_script_name = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query_nbr = vc WITH protect, constant("QUERY_NBR")
  DECLARE dpl_query_nbr_text = vc WITH protect, constant("QUERY_NBR_TEXT")
  DECLARE dpl_sqltext_hash_value = vc WITH protect, constant("SQLTEXT_HASH_VALUE")
  DECLARE dpl_host_name = vc WITH protect, constant("HOST NAME")
  DECLARE dpl_inst_name = vc WITH protect, constant("INSTANCE NAME")
  DECLARE dpl_oracle_version = vc WITH protect, constant("ORACLE VERSION")
  DECLARE dpl_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpl_column = vc WITH protect, constant("COLUMN")
  DECLARE dpl_proc_queue_runner_type = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER TYPE")
  DECLARE dpl_dpq_id = vc WITH protect, constant("DM_PROCESS_QUEUE_ID")
  DECLARE dpl_level = vc WITH protect, constant("LEVEL")
  DECLARE dpl_step_number = vc WITH protect, constant("STEP_NUMBER")
  DECLARE dpl_step_name = vc WITH protect, constant("STEP_NAME")
  DECLARE dpl_install_mode = vc WITH protect, constant("INSTALL_MODE")
  DECLARE dpl_parent_step_name = vc WITH protect, constant("PARENT_STEP_NAME")
  DECLARE dpl_parent_level_number = vc WITH protect, constant("PARENT_LEVEL_NUMBER")
  DECLARE dpl_configuration_changed = vc WITH protect, constant("CONFIGURATION CHANGED")
  DECLARE dpl_instsched_used = vc WITH protect, constant("INSTALLATION SCHEDULER USED")
  DECLARE dpl_silmode = vc WITH protect, constant("SILENT MODE USED")
  DECLARE dpl_audsid = vc WITH protect, constant("AUDSID")
  DECLARE dpl_logfilemain = vc WITH protect, constant("LOGFILE:MAIN")
  DECLARE dpl_logfilerunner = vc WITH protect, constant("LOGFILE:RUNNER")
  DECLARE dpl_logfilebackground = vc WITH protect, constant("LOGFILE:BACKGROUND")
  DECLARE dpl_logfilemonitor = vc WITH protect, constant("LOGFILE:MONITOR")
  DECLARE dpl_unattended = vc WITH protect, constant("UNATTENDED_IND")
  DECLARE dpl_itinerary_key = vc WITH protect, constant("ITINERARY_KEY")
  DECLARE dpl_report = vc WITH protect, constant("REPORT")
  DECLARE dpl_actionreq = vc WITH protect, constant("ACTIONREQ")
  DECLARE dpl_progress = vc WITH protect, constant("PROGRESS")
  DECLARE dpl_warning = vc WITH protect, constant("WARNING")
  DECLARE dpl_execution_dpe_id = vc WITH protect, constant("EXECUTION_DPE_ID")
  DECLARE dpl_itinerary_dpe_id = vc WITH protect, constant("ITINERARY_DPE_ID")
  DECLARE dpl_itinerary_key_name = vc WITH protect, constant("ITINERARY_KEY_NAME")
  DECLARE dpl_audit_name = vc WITH protect, constant("AUDIT_NAME")
  DECLARE dpl_audit_type = vc WITH protect, constant("AUDIT_TYPE")
  DECLARE dpl_sample = vc WITH protect, constant("SAMPLE")
  DECLARE dpl_drivergen_runner = vc WITH protect, constant("DM2_ADS_DRIVER_GEN:AUDSID")
  DECLARE dpl_childest_runner = vc WITH protect, constant("DM2_ADS_CHILDEST_GEN:AUDSID")
  DECLARE dpl_ads_runner = vc WITH protect, constant("DM2_ADS_RUNNER:AUDSID")
  DECLARE dpl_byconfig = vc WITH protect, constant("BYCONFIG")
  DECLARE dpl_full = vc WITH protect, constant("ALL")
  DECLARE dpl_interval = vc WITH protect, constant("EVERYNTH")
  DECLARE dpl_intervalpct = vc WITH protect, constant("EVERYNTHPCT")
  DECLARE dpl_recent = vc WITH protect, constant("RECENT")
  DECLARE dpl_none = vc WITH protect, constant("NONE")
  DECLARE dpl_custom = vc WITH protect, constant("CUSTOM")
  DECLARE dpl_static = vc WITH protect, constant("STATIC")
  DECLARE dpl_nomove = vc WITH protect, constant("NOMOVE")
  DECLARE dpl_multiple = vc WITH protect, constant("MULTIPLE")
  DECLARE dpl_driverkeygen = vc WITH protect, constant("DRIVERKEYGEN")
  DECLARE dpl_childestgen = vc WITH protect, constant("CHILDESTGEN")
  DECLARE dpl_define = vc WITH protect, constant("DEFINE")
  DECLARE dpl_invalid_schema = vc WITH protect, constant("INVALID - SCHEMA")
  DECLARE dpl_invalid_stats = vc WITH protect, constant("INVALID - STATS")
  DECLARE dpl_invalid_table = vc WITH protect, constant("INVALID - TABLE")
  DECLARE dpl_invalid_data = vc WITH protect, constant("INVALID - NO SAMPLE METADATA")
  DECLARE dpl_custom_table = vc WITH protect, constant("CUSTOM TABLE")
  DECLARE dpl_new_table = vc WITH protect, constant("NEW TABLE")
  DECLARE dpl_ready = vc WITH protect, constant("READY")
  DECLARE dpl_needsbuild = vc WITH protect, constant("NEEDSBUILD")
  DECLARE dpl_incomplete = vc WITH protect, constant("INCOMPLETE")
  DECLARE dpl_new = vc WITH protect, constant("NEW")
  DECLARE dpl_config_extract_id = vc WITH protect, constant("CONFIG_EXTRACT_ID")
  DECLARE dpl_dynselect_holder = vc WITH protect, constant("<<DYNBYCONFIG>>")
  DECLARE dpl_tgtdblink_holder = vc WITH protect, constant("<<TGTDBLINK>>")
  DECLARE dpl_ads_metadata = vc WITH protect, constant("DM2_ADS_METADATA")
  DECLARE dpl_ads_scramble_method = vc WITH protect, constant("DM2_SCRAMBLE_METHOD")
  DECLARE dpl_act = vc WITH protect, constant("ACTIVITY")
  DECLARE dpl_ref = vc WITH protect, constant("REFERENCE")
  DECLARE dpl_ref_mix = vc WITH protect, constant("REFERENCE-MIXED")
  DECLARE dpl_act_mix = vc WITH protect, constant("ACTIVITY-MIXED")
  DECLARE dpl_mix = vc WITH protect, constant("MIXED")
  DECLARE dpl_action = vc WITH protect, constant("ACTION")
  DECLARE dpl_grant_method = vc WITH protect, constant("GRANT METHOD")
  DECLARE dpl_script = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query = vc WITH protect, constant("QUERY NUMBER")
  DECLARE dpl_name = vc WITH protect, constant("USER NAME")
  DECLARE dpl_email = vc WITH protect, constant("EMAIL ADDRESS")
  DECLARE dpl_reason = vc WITH protect, constant("REASON FOR ACTION")
  DECLARE dpl_sr_nbr = vc WITH protect, constant("SR NUMBER")
  DECLARE dpl_sql_id = vc WITH protect, constant("SQL ID")
  DECLARE dpl_grant_exists = vc WITH protect, constant("GRANT EXISTS")
  DECLARE dpl_bl_exists = vc WITH protect, constant("BASELINE EXISTS")
  DECLARE dpl_grant_str = vc WITH protect, constant("GRANT OUTSTRING")
  DECLARE dpl_grant_cmd = vc WITH protect, constant("GRANT COMMAND")
  DECLARE dpl_bl_query_nbr = vc WITH protect, constant("BASELINE QUERY NUMBER")
  DECLARE dpl_bl_sql_handle = vc WITH protect, constant("BASELINE SQL HANDLE")
  DECLARE dpl_bl_sql_text = vc WITH protect, constant("BASELINE SQL TEXT")
  DECLARE dpl_bl_creator = vc WITH protect, constant("BASELINE CREATOR")
  DECLARE dpl_bl_desc = vc WITH protect, constant("BASELINE DESCRIPTION")
  DECLARE dpl_bl_enabled = vc WITH protect, constant("BASELINE ENABLED")
  DECLARE dpl_bl_accepted = vc WITH protect, constant("BASELINE ACCEPTED")
  DECLARE dpl_bl_plan_name = vc WITH protect, constant("BASELINE PLAN NAME")
  DECLARE dpl_bl_created = vc WITH protect, constant("BASELINE CREATED DT/TM")
  DECLARE dpl_bl_last_mod = vc WITH protect, constant("BASELINE LAST MODIFIED DT/TM")
  DECLARE dpl_bl_last_exec = vc WITH protect, constant("BASELINE LAST EXECUTED DT/TM")
 ENDIF
 SUBROUTINE dpl_upd_dped_last_status(dudls_event_id,dudls_text,dudls_number,dudls_date)
   DECLARE dudls_emsg = vc WITH protect, noconstant(dm_err->emsg)
   DECLARE dudls_eproc = vc WITH protect, noconstant(dm_err->eproc)
   DECLARE dudls_err_ind = i4 WITH protect, noconstant(dm_err->err_ind)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = 0
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=0))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Existance check for Event_Id",build(dudls_event_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event d
    WHERE d.dm_process_event_id=dudls_event_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dm_err->eproc =
    "Unable to find the event_id in DM_PROCESS_EVENT. Bypass inserting of new details."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   CALL dm2_process_log_add_detail_text("LAST_STATUS_MESSAGE",dudls_text)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = dudls_date
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = dudls_number
   CALL dm2_process_log_dtl_row(dudls_event_id,1)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = dudls_err_ind
    SET dm_err->eproc = dudls_eproc
    SET dm_err->emsg = dudls_emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_ui_chk(duc_process_name)
   DECLARE duc_event_col_exists = i2 WITH protect, noconstant(0)
   DECLARE duc_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_data_type = vc WITH protect, noconstant("")
   IF ((dm2_process_event_rs->ui_allowed_ind >= 0)
    AND currdbuser="V500"
    AND (dm2_process_rs->dbase_name=currdbname))
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Unattended install previously set:",build(dm2_process_event_rs->ui_allowed_ind
        )))
    ENDIF
    RETURN(1)
   ELSE
    IF ( NOT (currdbuser IN ("V500", "STATS", "CERN_DBSTATS")))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     SET dm2_process_rs->table_exists_ind = 0
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed. Current user is not V500. Current user is ",
        currdbuser))
     ENDIF
     RETURN(1)
    ENDIF
    SET dm2_process_event_rs->ui_allowed_ind = 1
    IF ( NOT (duc_process_name IN (dpl_notification, dpl_package_install, dpl_install_runner,
    dpl_background_runner, dpl_install_monitor)))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed for ",duc_process_name))
     ENDIF
    ENDIF
    IF ((((dm2_process_rs->table_exists_ind=0)) OR ((dm2_process_rs->dbase_name != currdbname))) )
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     SET duc_event_col_exists = 0
     SET duc_col_oradef_ind = 0
     SET dm_err->eproc = "Existance check for INSTALL_PLAN_ID and DETAIL_DT_TM"
     SELECT INTO "nl:"
      FROM dm2_user_tab_cols utc
      WHERE utc.table_name IN ("DM_PROCESS_EVENT", "DM_PROCESS_EVENT_DTL")
       AND utc.column_name IN ("INSTALL_PLAN_ID", "DETAIL_DT_TM")
      DETAIL
       IF (utc.table_name="DM_PROCESS_EVENT"
        AND utc.column_name="INSTALL_PLAN_ID")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ELSEIF (utc.table_name="DM_PROCESS_EVENT_DTL"
        AND utc.column_name="DETAIL_DT_TM")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (duc_col_oradef_ind=2)
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT","INSTALL_PLAN_ID",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT_DTL","DETAIL_DT_TM",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
     ENDIF
     IF (duc_event_col_exists < 2)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required schema does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ELSE
      SET dm2_process_rs->table_exists_ind = 1
     ENDIF
    ENDIF
    IF ((dm2_process_rs->table_exists_ind=1))
     SET dm_err->eproc = "Existance check for DM_CLINICAL_SEQ"
     SELECT INTO "nl:"
      FROM dba_sequences
      WHERE sequence_owner="V500"
       AND sequence_name="DM_CLINICAL_SEQ"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required sequence does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Unattended install allowed:",build(dm2_process_event_rs->ui_allowed_ind)))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_dtl_row(dpldr_event_log_id,ignore_errors)
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_process_event_rs)
   ENDIF
   IF ((dm2_process_event_rs->detail_cnt > 0))
    SET dm_err->eproc = "Removing logging detail from dm_process_event_dtl."
    DELETE  FROM dm_process_event_dtl dtl,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dtl.seq = 0
     PLAN (d)
      JOIN (dtl
      WHERE dtl.dm_process_event_id=dpldr_event_log_id
       AND (dtl.detail_type=dm2_process_event_rs->details[d.seq].detail_type))
     WITH nocounter
    ;end delete
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
    INSERT  FROM dm_process_event_dtl dped,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
      dpldr_event_log_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
      dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
      dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
       dm2_process_event_rs->details[d.seq].detail_date)
     PLAN (d)
      JOIN (dped)
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_row(process_name,action_type,prev_log_id,ignore_errors)
   IF (dpl_ui_chk(process_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   DECLARE dplr_search = i4 WITH protect, noconstant(0)
   DECLARE dplr_event_id = f8 WITH protect, noconstant(prev_log_id)
   DECLARE dplr_stack = vc WITH protect, constant(dm2_get_program_stack(null))
   DECLARE dplr_process_name = vc WITH protect, constant(evaluate(dm2_process_rs->process_name,"",
     process_name,dm2_process_rs->process_name))
   DECLARE dplr_program_details = vc WITH protect, constant(curprog)
   DECLARE dplr_search_string = vc WITH protect, constant(build(dplr_process_name,"#",curprog,"#",
     action_type))
   SET dm2_process_rs->process_name = dplr_process_name
   IF ( NOT (dm2_process_rs->filled_ind))
    SET dm_err->eproc = "Querying for list of logged processes from dm_process."
    SELECT INTO "nl:"
     FROM dm_process dp
     HEAD REPORT
      dm2_process_rs->filled_ind = 1, dm2_process_rs->cnt = 0, stat = alterlist(dm2_process_rs->qual,
       0)
     DETAIL
      dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
      IF (mod(dm2_process_rs->cnt,10)=1)
       stat = alterlist(dm2_process_rs->qual,(dm2_process_rs->cnt+ 9))
      ENDIF
      dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dp.dm_process_id, dm2_process_rs->
      qual[dm2_process_rs->cnt].process_name = dp.process_name, dm2_process_rs->qual[dm2_process_rs->
      cnt].program_name = dp.program_name,
      dm2_process_rs->qual[dm2_process_rs->cnt].action_type = dp.action_type, dm2_process_rs->qual[
      dm2_process_rs->cnt].search_string = build(dp.process_name,"#",dp.program_name,"#",dp
       .action_type)
     FOOT REPORT
      stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (prev_log_id=0)
    IF ( NOT (assign(dplr_search,locateval(dplr_search,1,dm2_process_rs->cnt,dplr_search_string,
      dm2_process_rs->qual[dplr_search].search_string))))
     SET dm_err->eproc = "Getting next sequence for new process from dm_clinical_seq."
     SELECT INTO "nl:"
      id = seq(dm_clinical_seq,nextval)
      FROM dual
      DETAIL
       dm2_process_rs->dm_process_id = id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Inserting new process into dm_process."
     INSERT  FROM dm_process dp
      SET dp.dm_process_id = dm2_process_rs->dm_process_id, dp.process_name = dm2_process_rs->
       process_name, dp.program_name = curprog,
       dp.action_type = action_type
      WITH nocounter
     ;end insert
     IF (dpl_check_error(null))
      RETURN((1 - dm_err->err_ind))
     ENDIF
     COMMIT
     SET dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
     SET stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     SET dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dm2_process_rs->dm_process_id
     SET dm2_process_rs->qual[dm2_process_rs->cnt].process_name = dm2_process_rs->process_name
     SET dm2_process_rs->qual[dm2_process_rs->cnt].program_name = curprog
     SET dm2_process_rs->qual[dm2_process_rs->cnt].action_type = action_type
     SET dm2_process_rs->qual[dm2_process_rs->cnt].search_string = dplr_search_string
     SET dplr_search = dm2_process_rs->cnt
    ENDIF
    SET dm2_process_rs->dm_process_id = dm2_process_rs->qual[dplr_search].dm_process_id
    SET dm_err->eproc = "Getting next sequence for log row."
    SELECT INTO "nl:"
     id = seq(dm_clinical_seq,nextval)
     FROM dual
     DETAIL
      dplr_event_id = id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting logging row into dm_process_event."
    INSERT  FROM dm_process_event dpe
     SET dpe.dm_process_event_id = dplr_event_id, dpe.install_plan_id = dm2_process_event_rs->
      install_plan_id, dpe.dm_process_id = dm2_process_rs->dm_process_id,
      dpe.program_stack = dplr_stack, dpe.program_details = dplr_program_details, dpe.begin_dt_tm =
      IF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      ,
      dpe.username = dpl_username, dpe.event_status = dm2_process_event_rs->status, dpe.message_txt
       = dm2_process_event_rs->message
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    IF (action_type=dpl_auditlog
     AND process_name IN (dpl_package_install, dpl_install_monitor, dpl_background_runner,
    dpl_install_runner))
     IF ((dir_ui_misc->dm_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_execution_dpe_id,dir_ui_misc->dm_process_event_id)
     ENDIF
     IF ((dm2_process_event_rs->itinerary_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_itinerary_dpe_id,dm2_process_event_rs->
       itinerary_process_event_id)
     ENDIF
     IF (trim(dm2_process_event_rs->itinerary_key) > "")
      CALL dm2_process_log_add_detail_text(dpl_itinerary_key_name,dm2_process_event_rs->itinerary_key
       )
     ENDIF
    ENDIF
    IF ((dm2_process_event_rs->detail_cnt > 0))
     SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
     INSERT  FROM dm_process_event_dtl dped,
       (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
      SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
       dplr_event_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
       dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
       dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
        dm2_process_event_rs->details[d.seq].detail_date)
      PLAN (d)
       JOIN (dped)
      WITH nocounter
     ;end insert
    ENDIF
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Updating existing logging row in dm_process_event."
    UPDATE  FROM dm_process_event dpe
     SET dpe.end_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->end_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.end_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->end_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->end_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      , dpe.begin_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.begin_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSEIF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(curdate,curtime3)
      ELSE dpe.begin_dt_tm
      ENDIF
      , dpe.event_status = evaluate(dm2_process_event_rs->status,"",dpe.event_status,
       dm2_process_event_rs->status),
      dpe.message_txt = evaluate(dm2_process_event_rs->message,"",dpe.message_txt,
       dm2_process_event_rs->message), dpe.program_details = dplr_program_details
     WHERE dpe.dm_process_event_id=dplr_event_id
     WITH nocounter
    ;end update
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->dm_process_event_id = dplr_event_id
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = 0
   SET dm2_process_event_rs->begin_dt_tm = 0
   SET dm2_process_event_rs->install_plan_id = 0.0
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_check_error(null)
   IF (check_error(dm_err->eproc))
    ROLLBACK
    IF ( NOT (ignore_errors))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     SET dm_err->err_ind = 0
     CALL echo("The above error is ignorable.")
    ENDIF
   ENDIF
   IF (dm_err->err_ind)
    SET dm2_process_event_rs->status = ""
    SET dm2_process_event_rs->message = ""
    SET dm2_process_event_rs->detail_cnt = 0
    SET stat = alterlist(dm2_process_event_rs->details,0)
    SET dm2_process_event_rs->dm_process_event_id = 0.0
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_text(detail_type,detail_text)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = detail_text
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_date(detail_type,detail_date)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = detail_date
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_number(detail_type,detail_number)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = detail_number
 END ;Subroutine
 DECLARE dpq_process_queue_row(null) = i2
 DECLARE dpq_update_queue_row(duqr_success=i2(ref)) = i2
 DECLARE dpq_cleanup_old_procs(dcop_proc_type=vc,dcop_maxcommit=i4) = i2
 DECLARE dpq_execute_command(dec_success=i2(ref)) = i2
 DECLARE dpq_populate_queue_rows(dpqr_proc_type=vc) = i2
 DECLARE dpq_lock_queue_row(dlqr_success=i2(ref)) = i2
 DECLARE dpq_check_end_time(dcet_beg_dt_tm=dq8,dcet_proc=vc,dcet_continue_ind=i2(ref)) = i2
 DECLARE dpq_manage_end_time(dmet_prompt_ind=i2,dmet_proc_type=vc,dmet_end_time=i4) = i2
 DECLARE dpq_remove_procs(drp_proc_type=vc,drp_status=vc,drp_maxcommit=i4) = i2
 IF ((validate(dpq_process_queue->dm_process_queue_id,- (1))=- (1))
  AND (validate(dpq_process_queue->dm_process_queue_id,- (2))=- (2)))
  FREE RECORD dpq_process_queue
  RECORD dpq_process_queue(
    1 dm_process_queue_id = f8
    1 process_type = vc
    1 op_type = vc
    1 owner_name = vc
    1 object_type = vc
    1 object_name = vc
    1 operation_txt = vc
    1 process_status = vc
    1 message_txt = vc
    1 op_method = vc
    1 priority = i4
    1 routine_tasks_ind = i2
  )
 ENDIF
 IF ((validate(dpq_proc_list->proc_cnt,- (1))=- (1))
  AND (validate(dpq_proc_list->proc_cnt,- (2))=- (2)))
  FREE RECORD dpq_proc_list
  RECORD dpq_proc_list(
    1 proc_cnt = i4
    1 qual[*]
      2 dm_process_queue_id = f8
      2 process_type = vc
      2 operation_txt = vc
      2 op_method = vc
  )
  DECLARE dpq_statistics = vc WITH protect, constant("STATISTICS")
  DECLARE dpq_freq_statistics = vc WITH protect, constant("STATISTICS_FREQ_GATHER")
  DECLARE dpq_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpq_routine_tasks = vc WITH protect, constant("ROUTINE_TASKS")
  DECLARE dpq_index_coalesce = vc WITH protect, constant("INDEX_COALESCE")
  DECLARE dpq_clinical_ranges = vc WITH protect, constant("CLINICAL_RANGES")
  DECLARE dpq_gather = vc WITH protect, constant("GATHER")
  DECLARE dpq_validate = vc WITH protect, constant("VALIDATE")
  DECLARE dpq_coalesce = vc WITH protect, constant("COALESCE")
  DECLARE dpq_queued = vc WITH protect, constant("QUEUED")
  DECLARE dpq_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpq_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpq_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpq_table = vc WITH protect, constant("TABLE")
  DECLARE dpq_index = vc WITH protect, constant("INDEX")
  DECLARE dpq_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpq_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpq_db = vc WITH protect, constant("DB")
  DECLARE dpq_dcl = vc WITH protect, constant("DCL")
 ENDIF
 SUBROUTINE dpq_process_queue_row(null)
   SET dm_err->eproc = "Validating inputs for dpq_process_queue_row"
   IF ("" IN (trim(dpq_process_queue->process_type), trim(dpq_process_queue->op_type), trim(
    dpq_process_queue->owner_name), trim(dpq_process_queue->object_type), trim(dpq_process_queue->
    object_name),
   trim(dpq_process_queue->operation_txt)))
    SET dm_err->emsg =
    "Must populate PROC_TYPE, OP_TYPE, owner_name, OBJECT_TYPE, operation_txt and OBJECT_NAME"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking for an existing row from dm_process_queue."
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE (dpq.process_type=dpq_process_queue->process_type)
     AND (dpq.op_type=dpq_process_queue->op_type)
     AND (dpq.owner_name=dpq_process_queue->owner_name)
     AND (dpq.object_type=dpq_process_queue->object_type)
     AND (dpq.object_name=dpq_process_queue->object_name)
    DETAIL
     dpq_process_queue->dm_process_queue_id = dpq.dm_process_queue_id, dpq_process_queue->
     process_status = dpq.process_status
    WITH nocounter, maxqual(dpq,1)
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual
    AND (dpq_process_queue->process_status != dpq_executing))
    SET dm_err->eproc = "Updating dm_process_queue row."
    UPDATE  FROM dm_process_queue dpq
     SET dpq.process_status = dpq_queued, dpq.operation_txt = dpq_process_queue->operation_txt, dpq
      .op_method = dpq_process_queue->op_method,
      dpq.message_txt = "", dpq.audsid = "", dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dpq.priority = evaluate(dpq_process_queue->priority,0,dpq.priority,dpq_process_queue->priority),
      dpq.routine_tasks_ind = dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSEIF (curqual
    AND (dpq_process_queue->process_status=dpq_executing))
    UPDATE  FROM dm_process_queue dpq
     SET dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpq.priority = evaluate(dpq_process_queue->
       priority,0,dpq.priority,dpq_process_queue->priority), dpq.routine_tasks_ind =
      dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Selecting new dm_process_queue_id from dual"
    SELECT INTO "nl:"
     new_id = seq(dm_clinical_seq,nextval)
     FROM dual d
     DETAIL
      dpq_process_queue->dm_process_queue_id = new_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting dm_process_queue row."
    INSERT  FROM dm_process_queue dpq
     SET dpq.process_type = dpq_process_queue->process_type, dpq.dm_process_queue_id =
      dpq_process_queue->dm_process_queue_id, dpq.op_type = dpq_process_queue->op_type,
      dpq.owner_name = dpq_process_queue->owner_name, dpq.object_type = dpq_process_queue->
      object_type, dpq.object_name = dpq_process_queue->object_name,
      dpq.operation_txt = dpq_process_queue->operation_txt, dpq.op_method = dpq_process_queue->
      op_method, dpq.process_status = dpq_queued,
      dpq.priority = evaluate(dpq_process_queue->priority,0,100,dpq_process_queue->priority), dpq
      .routine_tasks_ind = dpq_process_queue->routine_tasks_ind, dpq.gen_dt_tm = cnvtdatetime(curdate,
       curtime3),
      dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
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
 SUBROUTINE dpq_update_queue_row(duqr_success)
   SET dm_err->eproc = "Updating dm_process_queue row"
   SET duqr_success = 0
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_process_queue->process_status, dpq.message_txt = evaluate(trim(
       dpq_process_queue->message_txt),"",dpq.message_txt,dpq_process_queue->message_txt), dpq.audsid
      = "",
     dpq.end_dt_tm = cnvtdatetime(curdate,curtime3), dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual)
    SET duqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_old_procs(dcop_proc_type,dcop_maxcommit)
   DECLARE dcop_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcop_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcop_proc_type=dpq_routine_tasks)
    SET dcop_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcop_tmp_where_clause = "dpq.process_type = value(dcop_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating queued rows from DM_PROCESS_QUEUE"
   WHILE (dcop_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_queued, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)"), dpq.message_txt = ""
      WHERE parser(dcop_tmp_where_clause)
       AND ((dpq.process_status=dpq_failure) OR (dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle)) ))
      WITH nocounter, maxqual(dpq,value(dcop_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcop_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_lock_queue_row(dlqr_success)
   SET dlqr_success = 0
   SET dm_err->eproc = "Attempting to update DM_PROCESS_QUEUE row to executing."
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_executing, dpq.begin_dt_tm = cnvtdatetime(curdate,curtime3), dpq
     .audsid = currdbhandle
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     AND dpq.process_status=dpq_queued
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ELSEIF (curqual)
    SET dlqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_populate_queue_rows(dpqr_proc_type)
   DECLARE dpqr_tmp = i4 WITH protect, noconstant(0)
   DECLARE dpqr_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dpqr_proc_type=dpq_routine_tasks)
    SET dpqr_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dpqr_tmp_where_clause = "dpq.process_type = value(dpqr_proc_type)"
   ENDIF
   IF (validate(dpqrs_exec_ind,- (1))=1)
    IF ( NOT (validate(dpqrs_dpq_id,- (1)) <= 0.0))
     SET dpqr_tmp_where_clause = concat(dpqr_tmp_where_clause,
      " and dpq.dm_process_queue_id = value(dpqrs_dpq_id)")
    ELSE
     SET dm_err->eproc =
     "DPQ_POPULATE_QUEUE_ROWS was called via dm2_process_queue_runner_single with no valid dpq_id"
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   SET dpq_proc_list->proc_cnt = 0
   SET stat = alterlist(dpq_proc_list->qual,0)
   SET dm_err->eproc = "Loading operations to run from DM_PROCESS_QUEUE"
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE dpq.process_status=dpq_queued
     AND parser(dpqr_tmp_where_clause)
    ORDER BY dpq.priority, dpq.gen_dt_tm
    DETAIL
     dpq_proc_list->proc_cnt = (dpq_proc_list->proc_cnt+ 1)
     IF ((dpq_proc_list->proc_cnt > dpqr_tmp))
      dpqr_tmp = (dpqr_tmp+ 50), stat = alterlist(dpq_proc_list->qual,dpqr_tmp)
     ENDIF
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].dm_process_queue_id = dpq.dm_process_queue_id,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].process_type = dpq.process_type, dpq_proc_list->
     qual[dpq_proc_list->proc_cnt].operation_txt = dpq.operation_txt,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].op_method = dpq.op_method
    FOOT REPORT
     stat = alterlist(dpq_proc_list->qual,dpq_proc_list->proc_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_execute_command(dec_success)
   SET dm_err->eproc = "Validating inputs for dpq_execute_command"
   IF ("" IN (trim(dpq_process_queue->op_method), trim(dpq_process_queue->operation_txt)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DPQ_EXECUTE_COMMAND was called with no operation_txt or op_method"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Executing operation_txt: ",dpq_process_queue->op_method,":",
    dpq_process_queue->operation_txt)
   IF ((dpq_process_queue->op_method=dpq_db))
    SET dec_success = dm2_push_cmd(dpq_process_queue->operation_txt,1)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ELSEIF ((dpq_process_queue->op_method=dpq_dcl))
    SET dec_success = dm2_push_dcl(dpq_process_queue->operation_txt)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ENDIF
   IF (dec_success)
    SET dpq_process_queue->process_status = dpq_success
    SET dpq_process_queue->message_txt = ""
   ELSE
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_check_end_time(dcet_beg_dt_tm,dcet_proc,dcet_continue_ind)
   DECLARE dcet_tgt_end_time = dq8 WITH protect, noconstant(cnvtdatetime(curdate,cnvttime(360)))
   DECLARE dcet_fallout_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Selecting end_time from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN ("DM_PROCESS_QUEUE_RUNNER_END_TIME", "DM_PROCESS_QUEUE_RUNNER_FALLOUT")
     AND di.info_name=dcet_proc
    DETAIL
     IF (di.info_domain="DM_PROCESS_QUEUE_RUNNER_FALLOUT")
      dcet_fallout_ind = 1
     ELSE
      IF ((di.info_number=- (1)))
       dcet_tgt_end_time = datetimeadd(cnvtdatetime(curdate,curtime3),1)
      ELSE
       dcet_tgt_end_time = cnvtdatetime(curdate,cnvttime(di.info_number))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcet_beg_dt_tm > dcet_tgt_end_time)
    SET dcet_tgt_end_time = datetimeadd(dcet_tgt_end_time,1)
   ENDIF
   IF (((cnvtdatetime(curdate,curtime3) > dcet_tgt_end_time) OR (dcet_fallout_ind=1)) )
    IF (dcet_fallout_ind=1)
     SET dm_err->eproc =
     "Ending dm2_process_queue_runner because Fallout Indicator row was found in dm_info"
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dcet_continue_ind = 0
   ELSE
    SET dcet_continue_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_manage_end_time(dmet_prompt_ind,dmet_proc_type,dmet_end_time)
   DECLARE dmet_new_end_time = i4 WITH protect, noconstant(dmet_end_time)
   DECLARE dmet_update_ind = i2 WITH protect, noconstant(0)
   DECLARE dmet_menu_select = vc WITH protect, noconstant("M")
   IF (dmet_prompt_ind)
    SET dmet_new_end_time = 360
   ENDIF
   SET dm_err->eproc = "Checking for existence of end_time row from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
     AND di.info_name=dmet_proc_type
    DETAIL
     IF (dmet_prompt_ind)
      dmet_new_end_time = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dmet_update_ind = curqual
   ENDIF
   WHILE (true)
    IF (dmet_prompt_ind)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,concat(dmet_proc_type,notrim(" job menu")))
     CALL text(5,10,concat("Input the hour you want the ",dmet_proc_type,
       " job to stop at (0-23) [use -1 for no end time]:"))
     CALL text(6,10,concat("Hours:",evaluate(dmet_new_end_time,- (1),"Unlimited",cnvtstring(floor((
          dmet_new_end_time/ 60))))))
     CALL text(7,10,concat("Input the minutes you want the ",dmet_proc_type,notrim(
        " job to stop at (0-59):")))
     CALL text(8,10,concat("Minutes:",cnvtstring(evaluate(dmet_new_end_time,- (1),0,mod(
          dmet_new_end_time,60)))))
     CALL text(10,10,"(C)ontinue, (M)odify, (Q)uit:")
     CALL accept(10,41,"A;CU",dmet_menu_select
      WHERE curaccept IN ("C", "M", "Q"))
     SET dmet_menu_select = curaccept
     IF (dmet_menu_select="C")
      SET message = nowindow
      CALL clear(1,1)
     ENDIF
    ELSE
     SET dmet_menu_select = "C"
    ENDIF
    CASE (dmet_menu_select)
     OF "Q":
      RETURN(1)
     OF "C":
      IF (dmet_update_ind)
       SET dm_err->eproc = "Updating end_time row into DM_INFO"
       UPDATE  FROM dm_info di
        SET di.info_number = dmet_new_end_time
        WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
         AND di.info_name=dmet_proc_type
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET dm_err->eproc = "Inserting end_time row into DM_INFO"
       INSERT  FROM dm_info di
        SET di.info_domain = "DM_PROCESS_QUEUE_RUNNER_END_TIME", di.info_name = dmet_proc_type, di
         .info_number = dmet_new_end_time
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
      RETURN(1)
     OF "M":
      SET dmet_menu_select = "C"
      CALL accept(6,16,"NN;",evaluate(dmet_new_end_time,- (1),- (1),floor((dmet_new_end_time/ 60)))
       WHERE curaccept BETWEEN - (1) AND 23)
      SET dmet_new_end_time = evaluate(curaccept,- (1),- (1),(60 * curaccept))
      IF ((dmet_new_end_time != - (1)))
       CALL accept(8,18,"99;",0
        WHERE curaccept BETWEEN 0 AND 59)
       SET dmet_new_end_time = (dmet_new_end_time+ curaccept)
      ENDIF
    ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dpq_remove_procs(drp_proc_type,drp_status,drp_maxcommit)
   DECLARE drp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE drp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (drp_proc_type=dpq_routine_tasks)
    SET drp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET drp_tmp_where_clause = "dpq.process_type = value(drp_proc_type)"
   ENDIF
   SET dm_err->eproc = concat("Clearing out ",drp_proc_type," rows with status of ",drp_status)
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (drp_continue_ind)
     DELETE  FROM dm_process_queue dpq
      WHERE dpq.process_status=drp_status
       AND parser(drp_tmp_where_clause)
      WITH nocounter, maxqual(dpq,value(drp_maxcommit))
     ;end delete
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
     SET drp_continue_ind = curqual
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_stranded_procs(dcsp_proc_type,dcsp_maxcommit)
   DECLARE dcsp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcsp_proc_type=dpq_routine_tasks)
    SET dcsp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcsp_tmp_where_clause = "dpq.process_type = value(dcsp_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating stranded rows from DM_PROCESS_QUEUE"
   WHILE (dcsp_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_failure, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)")
      WHERE parser(dcsp_tmp_where_clause)
       AND dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle))
      WITH nocounter, maxqual(dpq,value(dcsp_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcsp_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 DECLARE ddf_autosuccess_init(null) = i2
 DECLARE ddf_check_lock(dcl_process=vc,dcl_object=vc,dcl_process_code=i2,dcl_lock_available_ind=i2(
   ref)) = i2
 DECLARE ddf_get_lock(dgl_process=vc,dgl_object=vc,dgl_process_code=i2,dgl_lock_obtained_ind=i2(ref))
  = i2
 DECLARE ddf_release_lock(drl_process=vc,drl_object=vc,drl_process_code=i2) = i2
 DECLARE ddf_get_audsid_list(dgal_process=vc,dgal_object=vc,dgal_process_code=i2) = i2
 DECLARE ddf_clean_dpq(dcd_process_type=vc,dcd_obj_name=vc) = i2
 DECLARE ddf_clean_dst(dcd_statid=vc) = i2
 DECLARE ddf_clean_dpe(dcd_process_name=vc,dcd_program_name=vc) = i2
 DECLARE ddf_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE ddf_get_publish_retry(dcp_retry_ceiling=i2(ref)) = i2
 DECLARE ddf_check_wait_pref(dcwp_pref_set_ind=i2(ref),dcwp_adb_ind=i2) = i2
 DECLARE ddf_get_object_id(dgoi_owner=vc,dgoi_table_name=vc,dgoi_object_id=f8(ref)) = i2
 DECLARE ddf_get_context_pkg_data(null) = i2
 DECLARE ddf_context_lock_maint(dclm_mode=vc,dclm_process=vc,dclm_process_code=i2,dclm_owner=vc,
  dclm_table_name=vc,
  dclm_object_id=f8,dclm_lock_ind=i2(ref)) = i2
 IF (validate(dgdt_prefs->in_object_type,"X")="X"
  AND validate(dgdt_prefs->in_object_type,"Y")="Y")
  FREE RECORD dgdt_prefs
  RECORD dgdt_prefs(
    1 in_object_type = vc
    1 in_object_owner = vc
    1 in_object_name = vc
    1 in_table_name = vc
    1 in_mode = vc
    1 in_object_id = vc
    1 table_owner = vc
    1 object_exists_ind = i2
    1 custom_prefs = vc
    1 di_exclusion = vc
    1 autosuccess_ind = i2
    1 context_lock_ind = i2
    1 context_lock_schema = vc
    1 method_opt_size254_ind_def = vc
    1 method_opt_size254_nonind_def = vc
    1 est_pct = vc
    1 est_pct_idx = vc
    1 method_opt = vc
    1 method_opt_dped = vc
    1 degree = vc
    1 degree_idx = vc
    1 cascade = vc
    1 publish = vc
    1 wait_time_pref_active = i2
    1 stale_pct = vc
    1 block_sample = vc
    1 granularity = vc
    1 granularity_idx = vc
    1 no_invalidate = vc
    1 no_invalidate_idx = vc
    1 di_est_pct = vc
    1 di_est_pct_idx = vc
    1 di_method_opt = vc
    1 di_degree = vc
    1 di_degree_idx = vc
    1 di_cascade = vc
    1 di_publish = vc
    1 di_stale_pct = vc
    1 di_block_sample = vc
    1 di_granularity = vc
    1 di_granularity_idx = vc
    1 di_no_invalidate = vc
    1 di_no_invalidate_idx = vc
    1 col_cnt = i2
    1 cols[*]
      2 column_name = vc
      2 data_type = vc
      2 method_opt = vc
      2 di_method_opt = vc
  )
  SET dgdt_prefs->autosuccess_ind = - (1)
  SET dgdt_prefs->context_lock_ind = - (1)
  SET dgdt_prefs->context_lock_schema = "DM2NOTSET"
  SET dgdt_prefs->in_object_type = "DM2NOTSET"
  SET dgdt_prefs->in_object_owner = "DM2NOTSET"
  SET dgdt_prefs->in_object_name = "DM2NOTSET"
  SET dgdt_prefs->in_table_name = "DM2NOTSET"
  SET dgdt_prefs->custom_prefs = "DM2NOTSET"
  SET dgdt_prefs->di_exclusion = "DM2NOTSET"
  SET dgdt_prefs->est_pct = "DM2NOTSET"
  SET dgdt_prefs->method_opt = "DM2NOTSET"
  SET dgdt_prefs->degree = "DM2NOTSET"
  SET dgdt_prefs->cascade = "DM2NOTSET"
  SET dgdt_prefs->publish = "DM2NOTSET"
  SET dgdt_prefs->stale_pct = "DM2NOTSET"
  SET dgdt_prefs->block_sample = "DM2NOTSET"
  SET dgdt_prefs->granularity = "DM2NOTSET"
  SET dgdt_prefs->no_invalidate = "DM2NOTSET"
  SET dgdt_prefs->est_pct_idx = "DM2NOTSET"
  SET dgdt_prefs->degree_idx = "DM2NOTSET"
  SET dgdt_prefs->granularity_idx = "DM2NOTSET"
  SET dgdt_prefs->no_invalidate_idx = "DM2NOTSET"
  SET dgdt_prefs->di_est_pct = "DM2NOTSET"
  SET dgdt_prefs->di_method_opt = "DM2NOTSET"
  SET dgdt_prefs->di_degree = "DM2NOTSET"
  SET dgdt_prefs->di_cascade = "DM2NOTSET"
  SET dgdt_prefs->di_publish = "DM2NOTSET"
  SET dgdt_prefs->di_stale_pct = "DM2NOTSET"
  SET dgdt_prefs->di_block_sample = "DM2NOTSET"
  SET dgdt_prefs->di_granularity = "DM2NOTSET"
  SET dgdt_prefs->di_no_invalidate = "DM2NOTSET"
  SET dgdt_prefs->di_est_pct_idx = "DM2NOTSET"
  SET dgdt_prefs->di_degree_idx = "DM2NOTSET"
  SET dgdt_prefs->di_granularity_idx = "DM2NOTSET"
  SET dgdt_prefs->di_no_invalidate_idx = "DM2NOTSET"
 ENDIF
 IF (validate(ddf_audsids->cnt,0)=0
  AND validate(ddf_audsids->cnt,1)=1)
  FREE RECORD ddf_audsids
  RECORD ddf_audsids(
    1 cnt = i4
    1 active_audsid_str = vc
    1 active_audsid_cnt = i4
    1 qual[*]
      2 audsid = vc
      2 active_ind = i2
  )
 ENDIF
 SUBROUTINE ddf_autosuccess_init(null)
   DECLARE ddfai_info_exists = i2 WITH protect, noconstant(0)
   DECLARE ddfai_cclversion = i4 WITH protect, constant((((cnvtint(currev) * 10000)+ (cnvtint(
     currevminor) * 100))+ cnvtint(currevminor2)))
   IF ((dgdt_prefs->autosuccess_ind=- (1)))
    IF (ddfai_cclversion < 80506)
     SET dm_err->eproc = "CCL Version 8.5.6 or higher required to run dm2*dbstats* scripts."
     SET dgdt_prefs->autosuccess_ind = 1
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Check for DM_INFO CCL definition"
    IF (checkdic("DM_INFO","T",0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "CCL Definition not found for DM_INFO for statistics processing. Auto-successing..."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Check for DM_INFO table existance"
    SELECT INTO "nl:"
     FROM dba_objects d
     WHERE d.object_name="DM_INFO"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No DM_INFO object found for statistics processing. Auto-successing..."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdbms_version->level1 < 11))
     SET dm_err->eproc = "Oracle version < 11g, Auto-successing...."
     SET dgdt_prefs->autosuccess_ind = 1
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_audsid_list(dgal_process,dgal_object,dgal_process_code)
   DECLARE dgal_audsid_list = vc WITH protect, noconstant("")
   DECLARE dgal_str = vc WITH protect, noconstant("")
   DECLARE dgal_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dgal_num = i4 WITH protect, noconstant(1)
   SET ddf_audsids->cnt = 0
   SET ddf_audsids->active_audsid_str = ""
   SET ddf_audsids->active_audsid_cnt = 0
   SET stat = alterlist(ddf_audsids->qual,ddf_audsids->cnt)
   SET dm_err->eproc = concat("Getting list of audsids from dm_info for ",dgal_process,":",
    dgal_object)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=cnvtupper(dgal_process)
     AND di.info_name=patstring(cnvtupper(dgal_object))
     AND di.info_number=dgal_process_code
    DETAIL
     dgal_audsid_list = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    WHILE (dgal_str != dgal_notfnd)
     SET dgal_str = piece(dgal_audsid_list,",",dgal_num,dgal_notfnd)
     IF (dgal_str != dgal_notfnd)
      SET ddf_audsids->cnt = (ddf_audsids->cnt+ 1)
      SET stat = alterlist(ddf_audsids->qual,ddf_audsids->cnt)
      SET ddf_audsids->qual[ddf_audsids->cnt].audsid = dgal_str
      SET dgal_num = (dgal_num+ 1)
     ENDIF
    ENDWHILE
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddf_audsids)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_lock(dcl_process,dcl_object,dcl_process_code,dcl_lock_available_ind)
   DECLARE dcl_audsid_list = vc WITH protect, noconstant("")
   DECLARE dcl_num = i4 WITH protect, noconstant(0)
   SET dcl_lock_available_ind = 0
   IF (ddf_get_audsid_list(dcl_process,dcl_object,dcl_process_code)=0)
    RETURN(0)
   ENDIF
   IF ((ddf_audsids->cnt > 0))
    FOR (dcl_num = 1 TO ddf_audsids->cnt)
      IF (dar_get_appl_status(ddf_audsids->qual[dcl_num].audsid)="A")
       IF ((ddf_audsids->qual[dcl_num].audsid != currdbhandle))
        SET ddf_audsids->qual[dcl_num].active_ind = 1
        SET ddf_audsids->active_audsid_cnt = (ddf_audsids->active_audsid_cnt+ 1)
        IF ((ddf_audsids->active_audsid_cnt=1))
         SET ddf_audsids->active_audsid_str = ddf_audsids->qual[dcl_num].audsid
        ELSE
         SET ddf_audsids->active_audsid_str = concat(ddf_audsids->active_audsid_str,",",ddf_audsids->
          qual[dcl_num].audsid)
        ENDIF
       ENDIF
      ELSE
       SET ddf_audsids->qual[dcl_num].active_ind = 0
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(ddf_audsids)
    ENDIF
    IF ((ddf_audsids->active_audsid_cnt > 0))
     SET dm_err->eproc = "Update lock row in dm_info with active audsid list"
     UPDATE  FROM dm_info di
      SET di.info_char = ddf_audsids->active_audsid_str
      WHERE di.info_domain=cnvtupper(dcl_process)
       AND di.info_name=patstring(cnvtupper(dcl_object))
       AND di.info_number=dcl_process_code
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = "Delete lock row in dm_info"
     DELETE  FROM dm_info di
      WHERE di.info_domain=cnvtupper(dcl_process)
       AND di.info_name=patstring(cnvtupper(dcl_object))
       AND di.info_number=dcl_process_code
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dcl_lock_available_ind = 1
    ENDIF
    COMMIT
   ELSE
    SET dcl_lock_available_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_lock(dgl_process,dgl_object,dgl_process_code,dgl_lock_obtained_ind)
   SET dgl_lock_obtained_ind = 0
   SET dm_err->eproc = concat("Inserting/Updating dm_info run_lock row for ",dgl_process,":",
    dgl_object)
   CALL disp_msg(" ",dm_err->logfile,10)
   SET dm_err->eproc = "Merge lock row in dm_info with current audsid"
   MERGE INTO dm_info d
   USING DUAL ON (d.info_domain=cnvtupper(dgl_process)
    AND d.info_name=cnvtupper(dgl_object)
    AND d.info_number=dgl_process_code)
   WHEN MATCHED THEN
   (UPDATE
    SET d.info_char = concat(d.info_char,",",currdbhandle)
    WHERE 1=1
   ;end update
   )
   WHEN NOT MATCHED THEN
   (INSERT  FROM d
    (info_domain, info_name, info_number,
    info_char)
    VALUES(cnvtupper(dgl_process), cnvtupper(dgl_object), dgl_process_code,
    currdbhandle)
    WITH nocounter
   ;end insert
   )
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    IF (findstring("ORA-00001",dm_err->emsg) > 0)
     SET dm_err->eproc = concat(
      "Bypass Oracle error ORA-00001.  Will retry obtaining dm_info run_lock row for ",dgl_object)
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dgl_lock_obtained_ind = 0
     SET dm_err->err_ind = 0
     SET dm_err->emsg = " "
     RETURN(1)
    ELSE
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   IF (curqual > 0)
    SET dgl_lock_obtained_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_release_lock(drl_process,drl_object,drl_process_code)
   DECLARE drl_num = i4 WITH protect, noconstant(0)
   IF (ddf_get_audsid_list(drl_process,drl_object,drl_process_code)=0)
    RETURN(0)
   ENDIF
   IF ((ddf_audsids->cnt > 0))
    FOR (drl_num = 1 TO ddf_audsids->cnt)
      IF (dar_get_appl_status(ddf_audsids->qual[drl_num].audsid)="A"
       AND (ddf_audsids->qual[drl_num].audsid != currdbhandle))
       SET ddf_audsids->qual[drl_num].active_ind = 1
       SET ddf_audsids->active_audsid_cnt = (ddf_audsids->active_audsid_cnt+ 1)
       IF ((ddf_audsids->active_audsid_cnt=1))
        SET ddf_audsids->active_audsid_str = ddf_audsids->qual[drl_num].audsid
       ELSE
        SET ddf_audsids->active_audsid_str = concat(ddf_audsids->active_audsid_str,",",ddf_audsids->
         qual[drl_num].audsid)
       ENDIF
      ELSE
       SET ddf_audsids->qual[drl_num].active_ind = 0
      ENDIF
    ENDFOR
   ENDIF
   IF ((ddf_audsids->active_audsid_cnt > 0))
    SET dm_err->eproc = concat("Updating dm_info run_lock row for ",drl_process,":",drl_object)
    CALL disp_msg(" ",dm_err->logfile,10)
    UPDATE  FROM dm_info di
     SET di.info_char = ddf_audsids->active_audsid_str
     WHERE di.info_domain=cnvtupper(drl_process)
      AND di.info_name=cnvtupper(drl_object)
      AND di.info_number=drl_process_code
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Deleting dm_info run_lock row for ",drl_process,":",drl_object)
    CALL disp_msg(" ",dm_err->logfile,10)
    DELETE  FROM dm_info di
     WHERE di.info_domain=cnvtupper(drl_process)
      AND di.info_name=cnvtupper(drl_object)
      AND di.info_number=drl_process_code
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dpq(dcd_process_type,dcd_obj_name)
   SET dm_err->eproc = concat("Clean up dm_process_queue rows for ",dcd_process_type,":",dcd_obj_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = concat("Retrieve dm_process_queue rows for ",dcd_process_type,":",dcd_obj_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE dpq.process_type=dcd_process_type
     AND dpq.object_name=patstring(dcd_obj_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("No rows found in dm_process_queue for ",dcd_process_type,":",
     dcd_obj_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Non-Existent Objects: Clean up dm_process_queue rows for ",
    dcd_process_type,":",dcd_obj_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_process_queue q
    WHERE q.process_type=dcd_process_type
     AND q.object_name=patstring(dcd_obj_name)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dba_objects d
     WHERE d.owner=q.owner_name
      AND d.object_name=q.object_name
      AND d.object_type=q.object_type)))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   SET dm_err->eproc = concat("Successful Operations: Clean up dm_process_queue rows for ",
    dcd_process_type,":",dcd_obj_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_process_queue q
    WHERE q.process_type=dcd_process_type
     AND q.object_name=patstring(dcd_obj_name)
     AND q.process_status="SUCCESS"
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_stat_table d,
      dba_objects o
     WHERE sqlpassthru("d.statid like 'DMSTG%'")
      AND sqlpassthru("d.statid = decode(o.object_type,'INDEX','DMSTG_I'||o.object_id,'DMSTG_T')")
      AND d.c1=o.object_name
      AND d.c5=o.owner
      AND d.type IN ("T", "I")
      AND sqlpassthru("d.type = decode(o.object_type,'INDEX','I','TABLE','T')")
      AND o.object_type IN ("TABLE", "INDEX")
      AND q.process_type=dcd_process_type
      AND q.owner_name=d.c5
      AND q.object_type IN ("TABLE", "INDEX")
      AND q.object_name=d.c1
      AND q.owner_name=o.owner
      AND q.object_name=o.object_name
      AND q.object_type=o.object_type)))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dst(dcd_statid)
   FREE RECORD dst_list
   RECORD dst_list(
     1 cnt = i4
     1 qual[*]
       2 statid = vc
       2 obj_name = vc
       2 owner = vc
       2 obj_exists = i2
   )
   SET dm_err->eproc = concat("Clean up dm_stat_table rows for ",dcd_statid)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dcd_statid="GOLDAVG")
    SET dm_err->eproc = "Deleting ALL GOLDAVG rows from dm_stat_table"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_stat_table dst
     WHERE dst.statid="GOLDAVG"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Retrieve dm_stat_table rows for ",dcd_statid)
   SELECT DISTINCT INTO "nl:"
    dst.statid, dst.c1, dst.c5
    FROM dm_stat_table dst
    WHERE dst.statid=patstring(dcd_statid)
    HEAD REPORT
     dst_list->cnt = 0, stat = alterlist(dst_list->qual,0)
    DETAIL
     dst_list->cnt = (dst_list->cnt+ 1), stat = alterlist(dst_list->qual,dst_list->cnt), dst_list->
     qual[dst_list->cnt].statid = dst.statid,
     dst_list->qual[dst_list->cnt].obj_name = dst.c1, dst_list->qual[dst_list->cnt].owner = dst.c5,
     dst_list->qual[dst_list->cnt].obj_exists = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dst_list->cnt=0))
    SET dm_err->eproc = concat("No rows found in dm_stat_table for ",dcd_statid)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Verifying existence of objects in dm_stat_table"
   SELECT INTO "nl:"
    FROM dba_objects do,
     (dummyt d  WITH seq = value(dst_list->cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (do
     WHERE (do.owner=dst_list->qual[d.seq].owner)
      AND (do.object_name=dst_list->qual[d.seq].obj_name))
    DETAIL
     IF ((dst_list->qual[d.seq].statid=patstring("DMSTG_I*")))
      IF (replace(dst_list->qual[d.seq].statid,"DMSTG_I","",0)=trim(cnvtstring(do.object_id)))
       dst_list->qual[d.seq].obj_exists = 1
      ENDIF
     ELSE
      dst_list->qual[d.seq].obj_exists = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dst_list)
   ENDIF
   SET dm_err->eproc = concat("Delete dm_stat_table rows for ",dcd_statid)
   DELETE  FROM dm_stat_table dst,
     (dummyt d  WITH seq = value(dst_list->cnt))
    SET dst.seq = 1
    PLAN (d
     WHERE d.seq > 0
      AND (dst_list->qual[d.seq].obj_exists=0))
     JOIN (dst
     WHERE (dst.statid=dst_list->qual[d.seq].statid)
      AND (dst.c1=dst_list->qual[d.seq].obj_name)
      AND (dst.c5=dst_list->qual[d.seq].owner))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dpe(dcd_process_name,dcd_program_name)
   DECLARE forndx1 = i4 WITH protect, noconstant(0)
   DECLARE forndx2 = i4 WITH protect, noconstant(0)
   IF ((validate(dpe_list->cnt,- (1))=- (1))
    AND (validate(dpe_list->cnt,- (2))=- (2)))
    FREE RECORD dpe_list
    RECORD dpe_list(
      1 cnt = i4
      1 qual[*]
        2 dp_id = f8
        2 program_name = vc
        2 dpe_cnt = i4
        2 qual2[*]
          3 dpe_id = f8
          3 owner = vc
          3 obj_name = vc
          3 dpe_status = vc
          3 dpe_audsid = vc
          3 dpe_current_ind = i2
    )
   ENDIF
   SET dm_err->eproc = concat("Clean up dm_process_event rows for ",dcd_process_name,":",
    dcd_program_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = concat("Retrieve dm_process rows for ",dcd_process_name,":",dcd_program_name)
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    PLAN (dp
     WHERE dp.process_name=dcd_process_name
      AND dp.program_name=patstring(dcd_program_name))
     JOIN (dpe
     WHERE dpe.dm_process_id=dp.dm_process_id
      AND dpe.event_status="EXECUTING")
     JOIN (dped
     WHERE dped.dm_process_event_id=dpe.dm_process_event_id)
    ORDER BY dp.dm_process_id, dpe.dm_process_event_id
    HEAD REPORT
     dpe_list->cnt = 0, stat = alterlist(dpe_list->qual,0)
    HEAD dp.dm_process_id
     dpe_list->cnt = (dpe_list->cnt+ 1), stat = alterlist(dpe_list->qual,dpe_list->cnt), dpe_list->
     qual[dpe_list->cnt].dp_id = dp.dm_process_id,
     dpe_list->qual[dpe_list->cnt].program_name = dp.program_name
    HEAD dpe.dm_process_event_id
     dpe_list->qual[dpe_list->cnt].dpe_cnt = (dpe_list->qual[dpe_list->cnt].dpe_cnt+ 1), stat =
     alterlist(dpe_list->qual[dpe_list->cnt].qual2,dpe_list->qual[dpe_list->cnt].dpe_cnt), dpe_list->
     qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_id = dpe
     .dm_process_event_id,
     dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_status = dpe
     .event_status
    DETAIL
     IF (dped.detail_type=dpl_owner)
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].owner = dped
      .detail_text
     ENDIF
     IF (dped.detail_type IN (dpl_table, "TABLE_NAME", dpl_index, "INDEX_NAME"))
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].obj_name = dped
      .detail_text
     ENDIF
     IF (dped.detail_type=dpl_audsid)
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_audsid = dped
      .detail_text
     ENDIF
     dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_current_ind = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dpe_list->cnt=0))
    SET dm_err->eproc = concat("No rows found in dm_process table for ",dcd_process_name,":",
     dcd_program_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dpe_list)
   ENDIF
   FOR (forndx1 = 1 TO dpe_list->cnt)
     FOR (forndx2 = 1 TO dpe_list->qual[forndx1].dpe_cnt)
       IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_status=dpl_executing))
        IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_audsid > " "))
         IF (dar_get_appl_status(dpe_list->qual[forndx1].qual2[forndx2].dpe_audsid)="A")
          SET dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
         ENDIF
        ELSE
         IF ((dpe_list->qual[forndx1].program_name=patstring("DM2_GATHER_DBSTATS*")))
          SET dm_err->eproc = concat("Checking dm_process_queue row for: ",dpe_list->qual[forndx1].
           qual2[forndx2].owner,":",dpe_list->qual[forndx1].qual2[forndx2].obj_name)
          SELECT INTO "nl:"
           FROM dm_process_queue dpq
           WHERE dpq.process_type=dpq_statistics
            AND dpq.op_type=dpq_gather
            AND (dpq.owner_name=dpe_list->qual[forndx1].qual2[forndx2].owner)
            AND (dpq.object_name=dpe_list->qual[forndx1].qual2[forndx2].obj_name)
           DETAIL
            IF (dpq.process_status=dpq_executing)
             dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
            ENDIF
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
         ELSEIF ((dpe_list->qual[forndx1].program_name=patstring("DM2_PUBLISH_DBSTATS*")))
          SET dm_err->eproc = concat("Checking dm_stat_table row for: ",dpe_list->qual[forndx1].
           qual2[forndx2].owner,":",dpe_list->qual[forndx1].qual2[forndx2].obj_name)
          SELECT INTO "nl:"
           FROM dm_stat_table dst
           WHERE dst.statid=patstring("DMSTG*")
            AND (dst.c5=dpe_list->qual[forndx1].qual2[forndx2].owner)
            AND (dst.c1=dpe_list->qual[forndx1].qual2[forndx2].obj_name)
           DETAIL
            dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
         ELSE
          SET dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
         ENDIF
        ENDIF
        IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind=0))
         SET dm_err->eproc = concat("Update dm_process_event rows for dm_process_event_id: ",trim(
           cnvtstring(dpe_list->qual[forndx1].qual2[forndx2].dpe_id)))
         CALL disp_msg(" ",dm_err->logfile,0)
         UPDATE  FROM dm_process_event dpe
          SET dpe.event_status = dpl_failure, dpe.end_dt_tm = cnvtdatetime(curdate,curtime3), dpe
           .message_txt =
           "Status updated to FAILURE by dm2_cleanup_dbstats_rows due to orphaned session",
           dpe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WHERE (dpe.dm_process_event_id=dpe_list->qual[forndx1].qual2[forndx2].dpe_id)
           AND dpe.event_status=dpl_executing
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc) != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ROLLBACK
          RETURN(0)
         ENDIF
         COMMIT
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = "Check if object being published is involved in a hard parse event"
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",dcp_owner,".",
      dcp_table_name,". SQL_ID = ",
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
 SUBROUTINE ddf_get_publish_retry(dcp_retry_ceiling)
   SET dcp_retry_ceiling = 10
   SET dm_err->eproc = "Check for retry ceiling override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2GDBS:PUBLISH_RETRY"
     AND d.info_name="RETRY CEILING"
    DETAIL
     dcp_retry_ceiling = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_wait_pref(dcwp_pref_set_ind,dcwp_adb_ind)
   DECLARE dcwp_set_pref_value = i2 WITH protect, noconstant(0)
   DECLARE dcwp_cur_pref_value = i2 WITH protect, noconstant(0)
   DECLARE dcwp_pref_available_ind = i2 WITH protect, noconstant(0)
   DECLARE get_dbms_stat_prefs(pname=vc) = c255 WITH sql = "SYS.DBMS_STATS.GET_PREFS", parameter
   DECLARE set_dbms_stat_prefs(pname=vc,pvalue=vc) = null WITH sql =
   "SYS.DBMS_STATS.SET_GLOBAL_PREFS", parameter
   SET dcwp_pref_set_ind = 0
   IF ((dm2_rdbms_version->level1=0))
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3=0)
    AND (dm2_rdbms_version->level4 >= 4))) )) )) )
    CALL echo("11204 or higher")
   ELSE
    SET dcwp_pref_set_ind = 0
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS pref not available (ORAVER)")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dcwp_adb_ind=0)
    SET dm_err->eproc = "Check if wait pref available"
    SELECT INTO "nl:"
     dcwp_sel_cnt = count(*)
     FROM (sys.optstat_hist_control$ o)
     WHERE o.sname="WAIT_TIME_TO_UPDATE_STATS"
     DETAIL
      IF (dcwp_sel_cnt > 0)
       dcwp_pref_available_ind = 1
      ELSE
       dcwp_pref_available_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dcwp_pref_available_ind=0)
    SET dcwp_pref_set_ind = 0
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS pref not available (NOT SET)")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for wait pref override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2GDBS:GLOBAL_PREF"
     AND d.info_name="WAIT_TIME_TO_UPDATE_STATS"
    DETAIL
     dcwp_set_pref_value = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcwp_cur_pref_value = - (1)
   SET dm_err->eproc = "Check value of wait pref"
   SELECT INTO "nl:"
    dcwp_sel_pref_value = get_dbms_stat_prefs("WAIT_TIME_TO_UPDATE_STATS")
    FROM dual
    DETAIL
     dcwp_cur_pref_value = cnvtint(dcwp_sel_pref_value)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcwp_cur_pref_value != dcwp_set_pref_value)
    SET dm_err->eproc = concat("Setting wait preference to ",cnvtstring(dcwp_set_pref_value))
    CALL set_dbms_stat_prefs("WAIT_TIME_TO_UPDATE_STATS",cnvtstring(dcwp_set_pref_value))
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS set to ",cnvtstring(dcwp_set_pref_value))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dcwp_pref_set_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_object_id(dgoi_owner,dgoi_table_name,dgoi_object_id)
   SET dm_err->eproc = concat("Query to retrieve object id for table_name :",dgoi_table_name)
   IF ((dm_err->debug_flag > 5))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects d
    WHERE d.owner=dgoi_owner
     AND d.object_name=dgoi_table_name
     AND d.object_type="TABLE"
    DETAIL
     dgoi_object_id = d.object_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_context_pkg_data(null)
   DECLARE dgcpd_pkg_qry_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgcpd_pkg_valid_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgcpd_contxt_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check for CERADM.SD_DB_PROCESS_CONTEXT_MGR package exists or not"
   IF ((dm_err->debug_flag > 5))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects o
    WHERE o.owner="CERADM"
     AND o.object_name="SD_DB_PROCESS_CONTEXT_MGR"
     AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    DETAIL
     dgcpd_pkg_qry_cnt = (dgcpd_pkg_qry_cnt+ 1)
     IF (o.status="VALID")
      dgcpd_pkg_valid_cnt = (dgcpd_pkg_valid_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcpd_pkg_valid_cnt=2)
    SET dgdt_prefs->context_lock_schema = "CERADM"
    SET dgdt_prefs->context_lock_ind = 1
   ELSEIF (dgcpd_pkg_qry_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid CERADM.SD_DB_PROCESS_CONTEXT_MGR package exists"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dgdt_prefs->context_lock_schema="CERADM"))
    SET dm_err->eproc = "Query for SD_DB_PROCESS_CONTEXT schema context owner "
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     dgcpd_tmp_cntxt_cnt = count(*)
     FROM dba_context dc
     WHERE dc.package="SD_DB_PROCESS_CONTEXT_MGR"
      AND dc.namespace="SD_DB_PROCESS_CONTEXT"
      AND (dc.schema=dgdt_prefs->context_lock_schema)
      AND dc.type="ACCESSED GLOBALLY"
     DETAIL
      dgcpd_contxt_cnt = dgcpd_tmp_cntxt_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgcpd_contxt_cnt=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid SD_DB_PROCESS_CONTEXT schema context owner"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    SET dgcpd_pkg_qry_cnt = 0
    SET dgcpd_pkg_valid_cnt = 0
    SET dm_err->eproc = "Check if V500.SD_DB_PROCESS_CONTEXT_MGR package exists or not"
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dba_objects o
     WHERE o.owner="V500"
      AND o.object_name="SD_DB_PROCESS_CONTEXT_MGR"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
     DETAIL
      dgcpd_pkg_qry_cnt = (dgcpd_pkg_qry_cnt+ 1)
      IF (o.status="VALID")
       dgcpd_pkg_valid_cnt = (dgcpd_pkg_valid_cnt+ 1)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgcpd_pkg_valid_cnt=2)
     SET dgdt_prefs->context_lock_schema = "V500"
     SET dgdt_prefs->context_lock_ind = 1
    ELSEIF (dgcpd_pkg_qry_cnt > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid V500.SD_DB_PROCESS_CONTEXT_MGR package exists"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    IF ((dm_err->debug_flag > 5))
     CALL echo("Old locking mechanism in use i.e via dm_info")
    ENDIF
    SET dgdt_prefs->context_lock_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_context_lock_maint(dclm_mode,dclm_process,dclm_process_code,dclm_owner,
  dclm_table_name,dclm_object_id,dclm_lock_ind)
   DECLARE check_context_sd(chkc_process=vc,chkc_key=vc,chkc_value=vc,chkc_what=i2) = i2 WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.check_context", parameter
   DECLARE check_context_v500(chkc_process=vc,chkc_key=vc,chkc_value=vc,chkc_what=i2) = i2 WITH sql
    = "V500.SD_DB_PROCESS_CONTEXT_MGR.check_context", parameter
   DECLARE set_context_sd(sc_process=vc,sc_key=vc,sc_value=vc) = null WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.set_context", parameter
   DECLARE set_context_v500(sc_process=vc,sc_key=vc,sc_value=vc) = null WITH sql =
   "V500.SD_DB_PROCESS_CONTEXT_MGR.set_context", parameter
   DECLARE clear_context_sd(clrc_process=vc,clrc_key=vc) = null WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.clear_context", parameter
   DECLARE clear_context_v500(clrc_process=vc,clrc_key=vc) = null WITH sql =
   "V500.SD_DB_PROCESS_CONTEXT_MGR.clear_context", parameter
   DECLARE dclm_get_session_id() = c30 WITH sql = "dbms_session.unique_session_id", parameter
   DECLARE dclm_session_id = vc WITH protect, noconstant("")
   DECLARE dclm_sql_cmd = vc WITH protect, noconstant("")
   DECLARE dclm_context_val = i2 WITH protect, noconstant(0)
   DECLARE dclm_process_name = vc WITH protect, noconstant("")
   DECLARE dclm_pkg_owner = vc WITH protect, noconstant("")
   DECLARE dclm_obj_id_str = vc WITH protect, noconstant("")
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    IF (ddf_get_context_pkg_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=1))
    IF (dclm_object_id=0.0)
     IF (ddf_get_object_id(dclm_owner,dclm_table_name,dclm_object_id)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dclm_obj_id_str = trim(cnvtstring(dclm_object_id))
    SET dm_err->eproc = "Query to retrieve session id "
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     dclm_session_id_tmp = dclm_get_session_id()
     FROM dual
     DETAIL
      dclm_session_id = dclm_session_id_tmp
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dclm_process_name = build(dclm_process,dclm_process_code)
   ENDIF
   IF (dclm_mode="CHECK")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("check if context lock exists for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT
      IF ((dgdt_prefs->context_lock_schema="CERADM"))
       dclm_tmp_val = check_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str,2)
      ELSE
       dclm_tmp_val = check_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str,2)
      ENDIF
      INTO "nl:"
      FROM dual
      DETAIL
       dclm_context_val = dclm_tmp_val
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dclm_context_val > 0)
      SET dclm_lock_ind = 0
     ELSE
      SET dclm_lock_ind = 1
     ENDIF
    ELSE
     IF (ddf_check_lock("STATS LOCK",dclm_table_name,dclm_process_code,dclm_lock_ind)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dclm_mode="GET")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("Get context lock  for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dgdt_prefs->context_lock_schema="CERADM"))
      CALL set_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str)
     ELSE
      CALL set_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str)
     ENDIF
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("check if context lock obtained for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT
      IF ((dgdt_prefs->context_lock_schema="CERADM"))
       dclm_tmp_val = check_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str,1)
      ELSE
       dclm_tmp_val = check_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str,1)
      ENDIF
      INTO "nl:"
      FROM dual
      DETAIL
       dclm_context_val = dclm_tmp_val
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dclm_context_val=1)
      SET dclm_lock_ind = 1
     ELSE
      SET dclm_lock_ind = 0
     ENDIF
    ELSE
     IF (ddf_get_lock("STATS LOCK",dclm_table_name,dclm_process_code,dclm_lock_ind)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dclm_mode="RELEASE")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("Release context lock on ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dgdt_prefs->context_lock_schema="CERADM"))
      CALL clear_context_sd(dclm_process_name,dclm_session_id)
     ELSE
      CALL clear_context_v500(dclm_process_name,dclm_session_id)
     ENDIF
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->err_ind=0))
      SET dclm_lock_ind = 1
     ELSE
      SET dclm_lock_ind = 0
      SET dm_err->emsg = concat("Unable to release lock on object:",dclm_owner,".",dclm_table_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF (ddf_release_lock("STATS LOCK",dclm_table_name,dclm_process_code)=0)
      RETURN(0)
     ENDIF
     SET dclm_lock_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dar_get_appl_status(gas_appl_id=vc) = c1
 SUBROUTINE dar_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   IF (cnvtupper(gas_appl_id)="-15301")
    RETURN(gas_active_status)
   ENDIF
   SELECT INTO "nl:"
    FROM gv$session s
    WHERE s.audsid=cnvtint(gas_appl_id)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine dar_get_appl_status")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(gas_error_status)
   ELSEIF (curqual=0)
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine dar_get_appl_status")=1)
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
 DECLARE dqd_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE dqd_str_pos = i4 WITH protect, noconstant(0)
 DECLARE dqd_tab_idx = i4 WITH protect, noconstant(0)
 DECLARE dqd_ind_idx = i4 WITH protect, noconstant(0)
 DECLARE dqd_aconly_ind = i2 WITH protect, noconstant(0)
 DECLARE dqd_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dqd_lock_available_ind = i2 WITH protect, noconstant(0)
 DECLARE dqd_lock_obtained_ind = i2 WITH protect, noconstant(0)
 DECLARE dqd_group_option = vc WITH protect, noconstant("BYTABLE")
 DECLARE dqd_module_name = vc WITH protect, constant("DM_STATS_PROCESS")
 DECLARE dqd_action_name = vc WITH protect, constant("QUEUE_DBSTATS")
 DECLARE dqd_original_module = vc WITH protect, noconstant("")
 DECLARE dqd_original_action = vc WITH protect, noconstant("")
 IF ((validate(dqd_list->tab_cnt,- (1))=- (1))
  AND (validate(dqd_list->tab_cnt,- (2))=- (2)))
  FREE RECORD dqd_list
  RECORD dqd_list(
    1 in_obj_type = vc
    1 in_tab_owner = vc
    1 in_tab_name = vc
    1 in_ind_owner = vc
    1 in_ind_name = vc
    1 in_mode = vc
    1 tab_cnt = i4
    1 ind_cnt = i4
    1 tab_stale_cnt = i4
    1 ind_stale_cnt = i4
    1 owntab[*]
      2 owner = vc
      2 tabname = vc
      2 ind_cnt = i4
      2 exclude_level = vc
      2 dpq_status = vc
      2 dst_status = vc
      2 stale_stats = vc
      2 gather_ind = i2
      2 tab_priority = i4
      2 ind[*]
        3 index_name = vc
        3 index_owner = vc
        3 null_ind = i2
        3 stale_stats = vc
        3 dpq_status = vc
        3 dst_status = vc
        3 exclude_level = vc
        3 gather_ind = i2
        3 ind_priority = i4
  )
 ENDIF
 IF ((validate(exclinfo->tab_cnt,- (1))=- (1))
  AND (validate(exclinfo->tab_cnt,- (2))=- (2)))
  FREE RECORD exclinfo
  RECORD exclinfo(
    1 own_cnt = i4
    1 obj_cnt = i4
    1 own[*]
      2 name = vc
      2 type = vc
    1 obj[*]
      2 owner_object_name = vc
      2 object_type = vc
  )
 ENDIF
 IF ((validate(prinfo->cnt,- (1))=- (1))
  AND (validate(prinfo->cnt,- (2))=- (2)))
  FREE RECORD prinfo
  RECORD prinfo(
    1 cnt = i4
    1 obj[*]
      2 name = vc
      2 owner = vc
      2 priority = i4
  )
 ENDIF
 DECLARE dqd_load_gather_list(null) = i2
 DECLARE dqd_preview_rpt(null) = i2
 IF (check_logfile("dm2_qdbs",".log","dm2_queue_dbstats LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning dm2_queue_dbstats"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Verifying and storing input parameters."
 SET dqd_list->in_obj_type = trim(cnvtupper( $1),3)
 SET dqd_list->in_tab_owner = trim(cnvtupper( $2),3)
 SET dqd_list->in_tab_name = trim( $3,3)
 SET dqd_list->in_ind_owner = trim(cnvtupper( $4),3)
 SET dqd_list->in_ind_name = trim( $5,3)
 SET dqd_list->in_mode = trim(cnvtupper( $6),3)
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = concat("Parameter usage: dm2_queue_dbstats  '<object_type>','<tab_owner>', ",
   "'<table_name>','<ind_owner>','<ind_name>',",
   "'<mode:[PREVIEW|PREVIEW_STALE|QUEUE|QUEUE_STALE|ACTUALONLY]>'")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Validating <object_type> and <mode> input parameters."
 IF ((( NOT ((dqd_list->in_mode IN ("QUEUE", "QUEUE_STALE", "PREVIEW", "PREVIEW_STALE", "ACTUALONLY")
 ))) OR ( NOT ((dqd_list->in_obj_type IN ("ALL", "INDEX", "TABLE"))))) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(
   "Valid values for $1 <object_type> are: [ALL|TABLE|INDEX] and for $6 <mode> are:",
   " [PREVIEW|PREVIEW_STALE|QUEUE|QUEUE_STALE]")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dmai_get_cur_mod_act(dqd_original_module,dqd_original_action)=0)
  GO TO exit_script
 ENDIF
 CALL dmai_set_mod_act(dqd_module_name,dqd_action_name)
 SET dm_err->eproc = "Check if dm2_frequent_gather_dbstats is already running"
 IF (ddf_check_lock("QUEUE DBSTATS LOCK","X",1,dqd_lock_available_ind)=0)
  GO TO exit_script
 ENDIF
 IF (dqd_lock_available_ind=1)
  IF (ddf_get_lock("QUEUE DBSTATS LOCK","X",1,dqd_lock_obtained_ind)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dqd_lock_obtained_ind=0)
  SET dm_err->eproc =
  "Unable to obtain lock to run dm2_queue_dbstats. Process will be run next cycle. Exiting Script."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_script
 ENDIF
 SET dm2_process_event_rs->status = dpl_executing
 CALL dm2_process_log_add_detail_text("OBJECT_TYPE",dqd_list->in_obj_type)
 CALL dm2_process_log_add_detail_text("TABLE_OWNER",dqd_list->in_tab_owner)
 CALL dm2_process_log_add_detail_text("TABLE_NAME",dqd_list->in_tab_name)
 CALL dm2_process_log_add_detail_text("INDEX_OWNER",dqd_list->in_ind_owner)
 CALL dm2_process_log_add_detail_text("INDEX_NAME",dqd_list->in_ind_name)
 CALL dm2_process_log_add_detail_text("MODE",dqd_list->in_mode)
 CALL dm2_process_log_add_detail_text(dpl_audsid,currdbhandle)
 CALL dm2_process_log_row(dpl_statistics,dpl_execution,dpl_no_prev_id,1)
 SET dqd_log_id = dm2_process_event_rs->dm_process_event_id
 IF ((dqd_list->in_mode="ACTUALONLY"))
  SET dqd_aconly_ind = 1
  SET dqd_list->in_mode = "QUEUE"
 ENDIF
 IF (ddf_autosuccess_init(null)=0)
  GO TO exit_script
 ELSEIF ((dgdt_prefs->autosuccess_ind=1))
  GO TO exit_script
 ENDIF
 IF ((validate(dfgd_freq_gather_ind,- (1))=- (1)))
  EXECUTE dm2_cleanup_dbstats_rows
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ENDIF
  CALL dmai_set_mod_act(dqd_module_name,dqd_action_name)
 ENDIF
 SET dm_err->eproc = "Load DM_INFO stat gathering exclusions"
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2GDBS:EXCLUDE*"
  ORDER BY di.info_domain, di.info_name
  DETAIL
   IF (di.info_domain IN ("DM2GDBS:EXCLUDE_TABLE_OWNER", "DM2GDBS:EXCLUDE_INDEX_OWNER"))
    exclinfo->own_cnt = (exclinfo->own_cnt+ 1), stat = alterlist(exclinfo->own,exclinfo->own_cnt),
    exclinfo->own[exclinfo->own_cnt].name = cnvtupper(trim(di.info_name))
    IF (di.info_domain="DM2GDBS:EXCLUDE_TABLE_OWNER")
     exclinfo->own[exclinfo->own_cnt].type = "TABLE"
    ELSE
     exclinfo->own[exclinfo->own_cnt].type = "INDEX"
    ENDIF
   ENDIF
   IF (di.info_domain IN ("DM2GDBS:EXCLUDE_TABLE", "DM2GDBS:EXCLUDE_INDEX"))
    exclinfo->obj_cnt = (exclinfo->obj_cnt+ 1), stat = alterlist(exclinfo->obj,exclinfo->obj_cnt),
    exclinfo->obj[exclinfo->obj_cnt].owner_object_name = trim(di.info_name)
    IF (di.info_domain="DM2GDBS:EXCLUDE_TABLE")
     exclinfo->obj[exclinfo->obj_cnt].object_type = "TABLE"
    ELSE
     exclinfo->obj[exclinfo->obj_cnt].object_type = "INDEX"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Retreiving DBSTATS Publishing options from DM_INFO"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DM2GDBS:PUBLISHOPTION"
  DETAIL
   IF (d.info_name="GROUPING")
    dqd_group_option = cnvtupper(d.info_char)
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dqd_group_option="BYTABLE")
  FOR (dqd_tab_idx = 1 TO exclinfo->obj_cnt)
    IF ((exclinfo->obj[dqd_tab_idx].object_type="TABLE"))
     SET dm_err->eproc = concat("Load indexes for ",exclinfo->obj[dqd_tab_idx].owner_object_name,
      " to exclude")
     SELECT INTO "nl:"
      FROM dba_indexes di
      WHERE (concat(trim(di.table_owner),".",trim(di.table_name))=exclinfo->obj[dqd_tab_idx].
      owner_object_name)
      DETAIL
       exclinfo->obj_cnt = (exclinfo->obj_cnt+ 1), stat = alterlist(exclinfo->obj,exclinfo->obj_cnt),
       exclinfo->obj[exclinfo->obj_cnt].owner_object_name = build(di.owner,".",di.index_name),
       exclinfo->obj[exclinfo->obj_cnt].object_type = "INDEX"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET dm_err->eproc = "Obtain table/index queue priority overrides"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2GDBS:OBJ_QUEUE_PRIORITY"
  HEAD REPORT
   prinfo->cnt = 0
  DETAIL
   dqd_str_pos = 0, dqd_str_pos = findstring(".",di.info_name,1,0)
   IF (dqd_str_pos > 0)
    prinfo->cnt = (prinfo->cnt+ 1), stat = alterlist(prinfo->obj,prinfo->cnt), prinfo->obj[prinfo->
    cnt].owner = substring(1,(dqd_str_pos - 1),di.info_name),
    prinfo->obj[prinfo->cnt].name = trim(substring((dqd_str_pos+ 1),size(di.info_name),di.info_name)),
    prinfo->obj[prinfo->cnt].priority = cnvtint(di.info_char)
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Flush the database monitoring information."
 CALL disp_msg("",dm_err->logfile,0)
 IF (dm2_push_cmd("RDB ASIS(^ BEGIN dbms_stats.flush_database_monitoring_info(); END; ^) go",1)=0)
  GO TO exit_script
 ENDIF
 IF (dqd_load_gather_list(null)=0)
  GO TO exit_script
 ENDIF
 IF ((dqd_list->in_mode IN ("PREVIEW", "PREVIEW_STALE")))
  IF (dqd_preview_rpt(null)=0)
   GO TO exit_script
  ENDIF
 ELSE
  FOR (dqd_tab_idx = 1 TO dqd_list->tab_cnt)
   IF ((dqd_list->owntab[dqd_tab_idx].gather_ind=1))
    SET dm_err->eproc = build("Generating queue row to gather table stats for TABLE: ","'",dqd_list->
     owntab[dqd_tab_idx].owner,".",dqd_list->owntab[dqd_tab_idx].tabname,
     "'")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dpq_process_queue->process_type = dpq_statistics
    SET dpq_process_queue->op_type = dpq_gather
    SET dpq_process_queue->owner_name = dqd_list->owntab[dqd_tab_idx].owner
    SET dpq_process_queue->object_type = dpq_table
    SET dpq_process_queue->op_method = dpq_db
    SET dpq_process_queue->object_name = dqd_list->owntab[dqd_tab_idx].tabname
    SET dpq_process_queue->priority = dqd_list->owntab[dqd_tab_idx].tab_priority
    SET dpq_process_queue->routine_tasks_ind = 0
    SET dpq_process_queue->operation_txt = build("execute dm2_gather_dbstats_tab '",dqd_list->owntab[
     dqd_tab_idx].owner,"','",dqd_list->owntab[dqd_tab_idx].tabname,"','",
     evaluate(dqd_aconly_ind,1,"ACTUALONLY","STAGE"),"' GO")
    IF (dpq_process_queue_row(null)=0)
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   IF ((dqd_list->owntab[dqd_tab_idx].ind_cnt > 0))
    FOR (dqd_ind_idx = 1 TO dqd_list->owntab[dqd_tab_idx].ind_cnt)
      IF ((dqd_list->owntab[dqd_tab_idx].ind[dqd_ind_idx].gather_ind=1))
       SET dm_err->eproc = build("Generating queue row to gather index stats for INDEX: ","'",
        dqd_list->owntab[dqd_tab_idx].ind[dqd_ind_idx].index_owner,".",dqd_list->owntab[dqd_tab_idx].
        ind[dqd_ind_idx].index_name,
        "'")
       CALL disp_msg(" ",dm_err->logfile,0)
       SET dpq_process_queue->process_type = dpq_statistics
       SET dpq_process_queue->op_type = dpq_gather
       SET dpq_process_queue->owner_name = dqd_list->owntab[dqd_tab_idx].ind[dqd_ind_idx].index_owner
       SET dpq_process_queue->object_type = dpq_index
       SET dpq_process_queue->op_method = dpq_db
       SET dpq_process_queue->object_name = dqd_list->owntab[dqd_tab_idx].ind[dqd_ind_idx].index_name
       SET dpq_process_queue->priority = dqd_list->owntab[dqd_tab_idx].ind[dqd_ind_idx].ind_priority
       SET dpq_process_queue->routine_tasks_ind = 0
       SET dpq_process_queue->operation_txt = build("execute dm2_gather_dbstats_ind '",dqd_list->
        owntab[dqd_tab_idx].ind[dqd_ind_idx].index_owner,"','",dqd_list->owntab[dqd_tab_idx].ind[
        dqd_ind_idx].index_name,"','",
        evaluate(dqd_aconly_ind,1,"ACTUALONLY","STAGE"),"' GO")
       IF (dpq_process_queue_row(null)=0)
        SET dm_err->err_ind = 0
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE dqd_load_gather_list(null)
   DECLARE dlgl_mode_where = vc WITH protect, noconstant(" 1=1 ")
   DECLARE dlgl_num = i4 WITH protect, noconstant(0)
   FREE RECORD dlgl_orauser
   RECORD dlgl_orauser(
     1 cnt = i4
     1 qual[*]
       2 user = vc
   )
   SET dm_err->eproc = "Retrieve list of Oracle users from dm_info"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_ORACLE_USER"
    DETAIL
     dlgl_orauser->cnt = (dlgl_orauser->cnt+ 1), stat = alterlist(dlgl_orauser->qual,dlgl_orauser->
      cnt), dlgl_orauser->qual[dlgl_orauser->cnt].user = d.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   IF ((dqd_list->in_mode IN ("QUEUE_STALE", "PREVIEW_STALE")))
    SET dlgl_mode_where = concat(" exists "," (select 'x' ","   from dba_tab_statistics dts ",
     "   where dts.table_name != 'BIN$*' ",
     "     and NOT expand(dlgl_num,1,dlgl_orauser->cnt,dts.owner,dlgl_orauser->qual[dlgl_num].user) ",
     "     and (dts.last_analyzed is null ","          or dts.stale_stats is null ",
     "           or dts.stale_stats = 'YES') ","     and dts.owner = dt.owner ",
     "     and dts.table_name = dt.table_name ",
     "     and dts.object_type IN ('TABLE','PARTITION','SUBPARTITION'))")
   ENDIF
   SET dm_err->eproc = "Selecting table statistics gathering candidates."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_tables dt
    WHERE dt.owner=patstring(dqd_list->in_tab_owner)
     AND dt.table_name=patstring(dqd_list->in_tab_name)
     AND dt.temporary != "Y"
     AND ((dt.iot_type != "IOT_OVERFLOW") OR (dt.iot_type = null))
     AND  NOT (expand(dlgl_num,1,dlgl_orauser->cnt,dt.owner,dlgl_orauser->qual[dlgl_num].user))
     AND parser(dlgl_mode_where)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_process_queue dpq
     WHERE dpq.process_type=dpq_freq_statistics
      AND dpq.object_type=dpq_table
      AND dpq.owner_name=dt.owner
      AND dpq.object_name=dt.table_name
      AND dpq.process_status != dpq_success)))
     AND  NOT ( EXISTS (
    (SELECT
     det.owner, det.table_name
     FROM dba_external_tables det
     WHERE det.owner=dt.owner
      AND det.table_name=dt.table_name)))
    ORDER BY dt.owner, dt.table_name
    HEAD REPORT
     owntab_cnt = 0, stat = alterlist(dqd_list->owntab,owntab_cnt)
    HEAD dt.owner
     ownexcl_ind = 0
     IF ((exclinfo->own_cnt > 0))
      locndx = 0, locndx = locateval(locndx,1,exclinfo->own_cnt,dt.owner,exclinfo->own[locndx].name,
       "TABLE",exclinfo->own[locndx].type)
      IF (locndx > 0)
       ownexcl_ind = 1
      ENDIF
     ENDIF
    DETAIL
     owntab_cnt = (owntab_cnt+ 1)
     IF (mod(owntab_cnt,50)=1)
      stat = alterlist(dqd_list->owntab,(owntab_cnt+ 49))
     ENDIF
     dqd_list->owntab[owntab_cnt].owner = trim(dt.owner), dqd_list->owntab[owntab_cnt].tabname = trim
     (dt.table_name), dqd_list->owntab[owntab_cnt].dpq_status = "NOT QUEUED",
     dqd_list->owntab[owntab_cnt].dst_status = "DM2NOTSET"
     IF ((dqd_list->in_mode IN ("QUEUE_STALE", "PREVIEW_STALE")))
      dqd_list->owntab[owntab_cnt].stale_stats = "YES"
     ELSE
      dqd_list->owntab[owntab_cnt].stale_stats = "NO"
     ENDIF
     IF (ownexcl_ind=1)
      dqd_list->owntab[owntab_cnt].exclude_level = "TABLE_OWNER"
     ENDIF
     IF ((exclinfo->obj_cnt > 0)
      AND size(trim(dqd_list->owntab[owntab_cnt].exclude_level))=0)
      locndx = 0, locndx = locateval(locndx,1,exclinfo->obj_cnt,build(dt.owner,".",dt.table_name),
       exclinfo->obj[locndx].owner_object_name)
      IF (locndx > 0)
       dqd_list->owntab[owntab_cnt].exclude_level = "TABLE"
      ENDIF
     ENDIF
     IF (size(trim(dqd_list->owntab[owntab_cnt].exclude_level))=0
      AND (dqd_list->in_obj_type != "INDEX"))
      dqd_list->owntab[owntab_cnt].gather_ind = 1
     ENDIF
    FOOT REPORT
     dqd_list->tab_cnt = owntab_cnt, stat = alterlist(dqd_list->owntab,owntab_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   IF ((dqd_list->in_mode IN ("QUEUE", "PREVIEW")))
    SET dm_err->eproc = "Classifying which tables are stale for this queue request."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tab_statistics dts
     WHERE dts.owner=patstring(dqd_list->in_tab_owner)
      AND  NOT (expand(dlgl_num,1,dlgl_orauser->cnt,dts.owner,dlgl_orauser->qual[dlgl_num].user))
      AND dts.table_name=patstring(dqd_list->in_tab_name)
      AND dts.table_name != "BIN$*"
      AND dts.object_type="TABLE"
      AND ((dts.last_analyzed = null) OR (((dts.stale_stats = null) OR (dts.stale_stats="YES")) ))
     ORDER BY dts.owner, dts.table_name
     DETAIL
      locndx = 0, locndx = locateval(locndx,1,dqd_list->tab_cnt,dts.owner,dqd_list->owntab[locndx].
       owner,
       dts.table_name,dqd_list->owntab[locndx].tabname)
      IF (locndx > 0)
       dqd_list->owntab[locndx].stale_stats = "YES"
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((dqd_list->tab_cnt > 0)
    AND (dqd_list->in_obj_type IN ("ALL", "INDEX")))
    SET dm_err->eproc = "Selecting indexes to gather for table queue candidates."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_indexes di
     WHERE di.table_owner=patstring(dqd_list->in_tab_owner)
      AND di.table_name=patstring(dqd_list->in_tab_name)
      AND di.owner=patstring(dqd_list->in_ind_owner)
      AND di.index_name=patstring(dqd_list->in_ind_name)
      AND di.index_type IN ("NORMAL", "FUNCTION-BASED NORMAL")
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info d
      WHERE d.info_domain="DM2_ORACLE_USER"
       AND d.info_name=di.table_owner)))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_process_queue dpq
      WHERE dpq.process_type=dpq_freq_statistics
       AND dpq.object_type=dpq_table
       AND dpq.owner_name=di.table_owner
       AND dpq.object_name=di.table_name
       AND dpq.process_status=dpq_queued)))
     ORDER BY di.table_owner, di.table_name, di.index_name
     HEAD di.table_owner
      dummy_var = 0
     HEAD di.table_name
      icnt = 0, locndx = 0, locndx = locateval(locndx,1,dqd_list->tab_cnt,di.table_owner,dqd_list->
       owntab[locndx].owner,
       di.table_name,dqd_list->owntab[locndx].tabname)
     DETAIL
      IF (locndx > 0)
       icnt = (icnt+ 1), stat = alterlist(dqd_list->owntab[locndx].ind,icnt), dqd_list->owntab[locndx
       ].ind[icnt].index_name = trim(di.index_name),
       dqd_list->owntab[locndx].ind[icnt].index_owner = trim(di.owner), dqd_list->owntab[locndx].ind[
       icnt].stale_stats = dqd_list->owntab[locndx].stale_stats, dqd_list->owntab[locndx].ind[icnt].
       dpq_status = "NOT QUEUED",
       dqd_list->owntab[locndx].ind[icnt].dst_status = "DM2NOTSET"
       IF ((exclinfo->own_cnt > 0))
        locndx2 = 0, locndx2 = locateval(locndx2,1,exclinfo->own_cnt,di.owner,exclinfo->own[locndx2].
         name,
         "INDEX",exclinfo->own[locndx2].type)
        IF (locndx2 > 0)
         dqd_list->owntab[locndx].ind[icnt].exclude_level = "INDEX_OWNER"
        ENDIF
       ENDIF
       IF (size(trim(dqd_list->owntab[locndx].ind[icnt].exclude_level))=0
        AND (exclinfo->obj_cnt > 0))
        locndx2 = 0, locndx2 = locateval(locndx2,1,exclinfo->obj_cnt,build(di.owner,".",di.index_name
          ),exclinfo->obj[locndx2].owner_object_name)
        IF (locndx2 > 0)
         dqd_list->owntab[locndx].ind[icnt].exclude_level = "INDEX"
        ENDIF
       ENDIF
       IF (size(trim(dqd_list->owntab[locndx].ind[icnt].exclude_level))=0)
        dqd_list->owntab[locndx].ind[icnt].gather_ind = 1
       ENDIF
      ENDIF
     FOOT  di.table_name
      IF (locndx > 0)
       dqd_list->owntab[locndx].ind_cnt = icnt
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dqd_list->tab_cnt > 0))
    SET dm_err->eproc = "Assign table priority"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     ds.owner, dlgl_qry_segment_name = nullval(c.table_name,ds.segment_name), dlgl_qry_bytes_gb = (((
     ds.bytes/ 1024.0)/ 1024.0)/ 1024.0)
     FROM dba_segments ds,
      (left JOIN dba_tables c ON ds.segment_name=c.cluster_name
       AND ds.owner=c.owner
       AND ds.segment_type="CLUSTER")
     WHERE  NOT (ds.owner IN (
     (SELECT
      d.info_name
      FROM dm_info d
      WHERE d.info_domain="DM2_ORACLE_USER")))
      AND ds.segment_type IN ("TABLE", "CLUSTER")
     ORDER BY ds.bytes DESC
     HEAD REPORT
      tmp_pr = 1001
     DETAIL
      locndx = 0, locndx2 = 0, forndx = 0,
      locndx = locateval(locndx,1,dqd_list->tab_cnt,dlgl_qry_segment_name,dqd_list->owntab[locndx].
       tabname,
       ds.owner,dqd_list->owntab[locndx].owner)
      IF (locndx > 0)
       locndx2 = locateval(locndx2,1,prinfo->cnt,dlgl_qry_segment_name,prinfo->obj[locndx2].name,
        ds.owner,prinfo->obj[locndx2].owner)
       IF (locndx2 > 0)
        dqd_list->owntab[locndx].tab_priority = prinfo->obj[locndx2].priority
       ELSE
        dqd_list->owntab[locndx].tab_priority = tmp_pr
       ENDIF
       IF ((dqd_list->owntab[locndx].ind_cnt > 0))
        FOR (forndx = 1 TO dqd_list->owntab[locndx].ind_cnt)
         locndx2 = locateval(locndx2,1,prinfo->cnt,dqd_list->owntab[locndx].ind[forndx].index_name,
          prinfo->obj[locndx2].name,
          dqd_list->owntab[locndx].ind[forndx].index_owner,prinfo->obj[locndx2].owner),
         IF (locndx2 > 0)
          dqd_list->owntab[locndx].ind[forndx].ind_priority = prinfo->obj[locndx2].priority
         ELSE
          dqd_list->owntab[locndx].ind[forndx].ind_priority = (dqd_list->owntab[locndx].tab_priority
          + 1)
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
      tmp_pr = (tmp_pr+ 2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dqd_list->tab_cnt > 0)
    AND (dqd_list->in_obj_type IN ("ALL", "TABLE")))
    SET dm_err->eproc = "Cross-checking gathering candidates against tables in DM_PROCESS_QUEUE."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_process_queue dpq
     WHERE dpq.process_type=dpq_statistics
      AND dpq.op_type=dpq_gather
      AND dpq.object_type=dpq_table
      AND dpq.owner_name=patstring(dqd_list->in_tab_owner)
      AND dpq.object_name=patstring(dqd_list->in_tab_name)
      AND dpq.process_status != dpq_success
     ORDER BY dpq.owner_name, dpq.object_name
     DETAIL
      locndx = 0, locndx = locateval(locndx,1,dqd_list->tab_cnt,dpq.owner_name,dqd_list->owntab[
       locndx].owner,
       dpq.object_name,dqd_list->owntab[locndx].tabname)
      IF (locndx > 0)
       dqd_list->owntab[locndx].dpq_status = dpq.process_status
       IF (dpq.process_status=dpq_executing)
        dqd_list->owntab[locndx].gather_ind = 0
       ENDIF
       IF (dpq.process_status=dpq_queued
        AND (dpq.priority=dqd_list->owntab[locndx].tab_priority))
        dqd_list->owntab[locndx].gather_ind = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc =
    "Cross-checking gathering candidates against publishing tables in DM_STAT_TABLE."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_stat_table dst
     WHERE dst.statid="DMSTG_T"
      AND dst.c1=patstring(dqd_list->in_tab_name)
      AND dst.c5=patstring(dqd_list->in_tab_owner)
      AND dst.type="T"
     ORDER BY dst.c5, dst.c1
     DETAIL
      locndx = 0, locndx = locateval(locndx,1,dqd_list->tab_cnt,dst.c5,dqd_list->owntab[locndx].owner,
       dst.c1,dqd_list->owntab[locndx].tabname)
      IF (locndx > 0)
       dqd_list->owntab[locndx].dst_status = "PUBLISHING", dqd_list->owntab[locndx].gather_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dqd_list->tab_cnt > 0)
    AND (dqd_list->in_obj_type IN ("ALL", "INDEX")))
    SET dm_err->eproc = "Cross checking index objects in DM_PROCESS_QUEUE to gather candidates."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_process_queue d,
      dba_indexes di
     WHERE d.process_type=dpq_statistics
      AND d.op_type=dpq_gather
      AND d.object_type=dpq_index
      AND d.process_status != dpq_success
      AND d.object_name=di.index_name
      AND d.owner_name=di.owner
      AND di.table_owner=patstring(dqd_list->in_tab_owner)
      AND di.table_name=patstring(dqd_list->in_tab_name)
      AND di.index_name=patstring(dqd_list->in_ind_name)
      AND di.owner=patstring(dqd_list->in_ind_owner)
     ORDER BY di.table_owner, di.table_name, di.index_name
     DETAIL
      locndx = 0, locndx = locateval(locndx,1,dqd_list->tab_cnt,di.table_owner,dqd_list->owntab[
       locndx].owner,
       di.table_name,dqd_list->owntab[locndx].tabname)
      IF (locndx > 0)
       locndx2 = 0, locndx2 = locateval(locndx2,1,dqd_list->owntab[locndx].ind_cnt,di.owner,dqd_list
        ->owntab[locndx].ind[locndx2].index_owner,
        di.index_name,dqd_list->owntab[locndx].ind[locndx2].index_name)
       IF (locndx2 > 0)
        dqd_list->owntab[locndx].ind[locndx2].dpq_status = d.process_status
        IF (d.process_status=dpq_executing)
         dqd_list->owntab[locndx].ind[locndx2].gather_ind = 0
        ENDIF
        IF (d.process_status=dpq_queued
         AND (d.priority=dqd_list->owntab[locndx].ind[locndx2].ind_priority))
         dqd_list->owntab[locndx].ind[locndx2].gather_ind = 0
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc =
    "Get STAGED index data from DM_STAT_TABLE and cross reference to queue candidates."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_stat_table d,
      dba_indexes di,
      dba_objects do
     WHERE d.statid="DMSTG_I*"
      AND d.type="I"
      AND d.c1=di.index_name
      AND d.c5=di.owner
      AND di.table_owner=patstring(dqd_list->in_tab_owner)
      AND di.table_name=patstring(dqd_list->in_tab_name)
      AND di.index_name=patstring(dqd_list->in_ind_name)
      AND di.owner=patstring(dqd_list->in_ind_owner)
      AND d.statid=concat("DMSTG_I",cnvtstring(do.object_id,20))
      AND d.c5=do.owner
      AND di.owner=do.owner
      AND di.index_name=do.object_name
     ORDER BY di.table_owner, di.table_name, di.owner,
      di.index_name
     HEAD di.owner
      dummy_var = 0
     HEAD di.table_name
      locndx = 0, locndx = locateval(locndx,1,dqd_list->tab_cnt,di.table_owner,dqd_list->owntab[
       locndx].owner,
       di.table_name,dqd_list->owntab[locndx].tabname)
     DETAIL
      locndx2 = 0
      IF (locndx > 0)
       locndx2 = locateval(locndx2,1,dqd_list->owntab[locndx].ind_cnt,di.owner,dqd_list->owntab[
        locndx].ind[locndx2].index_owner,
        di.index_name,dqd_list->owntab[locndx].ind[locndx2].index_name)
       IF (locndx2 > 0)
        dqd_list->owntab[locndx].ind[locndx2].dst_status = "PUBLISHING", dqd_list->owntab[locndx].
        ind[locndx2].gather_ind = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dqd_list)
    CALL echorecord(prinfo)
    CALL echorecord(exclinfo)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dqd_preview_rpt(null)
   DECLARE dlsr_report_destination = vc WITH protect, noconstant("")
   SET dlsr_report_destination = concat("dm2_queuerpt_",format(cnvtdatetime(curdate,curtime3),
     "MMDDYYHHMM;;Q"))
   SET dm_err->eproc = "Generating DBSTATS queue preview report data to file from record structure."
   SELECT INTO build(dlsr_report_destination)
    FROM (dummyt d  WITH seq = value(dqd_list->tab_cnt))
    ORDER BY dqd_list->owntab[d.seq].tabname
    HEAD REPORT
     row + 0, col 0, "****** DATABASE STATISTICS QUEUEING PREVIEW REPORT ***********************",
     row + 2, col 0, "-- Criteria specified --",
     row + 1, col 0, "Object Type:",
     col 25, dqd_list->in_obj_type, row + 1,
     col 0, "Owner Name:", col 25,
     dqd_list->in_tab_owner, row + 1, col 0,
     "Table Name:", col 25, dqd_list->in_tab_name,
     row + 1, col 0, "Index Owner:",
     col 25, dqd_list->in_ind_owner, row + 1,
     col 0, "Index Name:", col 25,
     dqd_list->in_ind_name, row + 1, col 0,
     "Mode:", col 25, dqd_list->in_mode,
     row + 2, col 0, "-- Details --",
     row + 1, col 0, "T/I",
     col 5, "OWNER", col 18,
     "TABLE_NAME", col 49, "OBJECT_NAME",
     col 80, "STALE", col 87,
     "QUEUE_STATUS", col 101, "PRIORITY",
     col 115, "EXCLUDE", row + 1,
     col 0, "---", col 5,
     CALL print(fillstring(12,"-")), col 18,
     CALL print(fillstring(30,"-")),
     col 49,
     CALL print(fillstring(30,"-")), col 80,
     "-----", col 87,
     CALL print(fillstring(13,"-")),
     col 101,
     CALL print(fillstring(13,"-")), col 115,
     "---------"
    DETAIL
     row + 1
     IF ((dqd_list->tab_cnt > 0))
      col 1, "T", col 5,
      CALL print(substring(1,12,dqd_list->owntab[d.seq].owner)), col 18, dqd_list->owntab[d.seq].
      tabname,
      col 49, dqd_list->owntab[d.seq].tabname, col 80,
      CALL print(substring(1,3,dqd_list->owntab[d.seq].stale_stats)), col 87,
      CALL print(evaluate(dqd_list->owntab[d.seq].dst_status,"DM2NOTSET",dqd_list->owntab[d.seq].
       dpq_status,dqd_list->owntab[d.seq].dst_status)),
      col 101, dqd_list->owntab[d.seq].tab_priority, col 115,
      CALL print(evaluate(dqd_list->owntab[d.seq].gather_ind,1,"NO","YES"))
      IF ((dqd_list->owntab[d.seq].ind_cnt > 0))
       FOR (locndx = 1 TO dqd_list->owntab[d.seq].ind_cnt)
         row + 1, col 1, "I",
         col 5,
         CALL print(substring(1,12,dqd_list->owntab[d.seq].ind[locndx].index_owner)), col 18,
         dqd_list->owntab[d.seq].tabname, col 49, dqd_list->owntab[d.seq].ind[locndx].index_name,
         col 80,
         CALL print(substring(1,3,dqd_list->owntab[d.seq].ind[locndx].stale_stats)), col 87,
         CALL print(evaluate(dqd_list->owntab[d.seq].ind[locndx].dst_status,"DM2NOTSET",dqd_list->
          owntab[d.seq].ind[locndx].dpq_status,dqd_list->owntab[d.seq].ind[locndx].dst_status)), col
         101, dqd_list->owntab[d.seq].ind[locndx].ind_priority,
         col 115,
         CALL print(evaluate(dqd_list->owntab[d.seq].ind[locndx].gather_ind,1,"NO","YES"))
       ENDFOR
      ENDIF
     ELSE
      col 45, "No objects qualified"
     ENDIF
    FOOT REPORT
     row + 2,
     CALL center("*** END OF REPORT ***",1,100)
    WITH nocounter, nullreport, maxcol = 132,
     format = variable, formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_disp_file(dlsr_report_destination,"Table queue report")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 SET dm2_process_event_rs->status = evaluate(dm_err->err_ind,1,dpl_failure,dpl_success)
 SET dm2_process_event_rs->message = dm_err->emsg
 SET dqd_err_ind = dm_err->err_ind
 SET dm_err->err_ind = 0
 CALL dm2_process_log_row(dpl_statistics,dpl_execution,dqd_log_id,1)
 IF (dqd_lock_obtained_ind=1)
  CALL ddf_release_lock("QUEUE DBSTATS LOCK","X",1)
 ENDIF
 SET dm_err->err_ind = dqd_err_ind
 CALL dmai_set_mod_act(dqd_original_module,dqd_original_action)
 SET dm_err->eproc = "Ending dm2_queue_dbstats"
 CALL final_disp_msg("dm2_qdbs")
END GO
