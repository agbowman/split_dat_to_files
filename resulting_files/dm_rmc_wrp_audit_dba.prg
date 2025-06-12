CREATE PROGRAM dm_rmc_wrp_audit:dba
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
 IF (validate(dra_audit->file_name,"Zyx321")="Zyx321"
  AND validate(dra_audit->file_name,"asdf0987")="asdf0987")
  FREE RECORD dra_audit
  RECORD dra_audit(
    1 file_name = vc
    1 src_env_id = f8
    1 limit_ctxt = i2
    1 sample_size = i4
    1 ctxts_to_audit = vc
    1 ctxt_null_ind = i2
    1 data_subset_ind = i2
    1 tab_cnt = i4
    1 tab_qual[*]
      2 table_name = vc
  )
 ENDIF
 IF ((validate(table_info->tab_cnt,- (24))=- (24))
  AND (validate(table_info->tab_cnt,- (19))=- (19)))
  FREE RECORD table_info
  RECORD table_info(
    1 tab_cnt = i4
    1 tables[*]
      2 table_name = vc
      2 src_filter_function = vc
      2 src_filter_str = vc
      2 tgt_filter_function = vc
      2 tgt_filter_str = vc
      2 src_pkwhere_function = vc
      2 src_pkw_str = vc
      2 src_proc_pkw_str = vc
      2 tgt_pkwhere_function = vc
      2 tgt_pkw_str = vc
      2 tgt_filter_parm_cnt = i4
      2 tgt_f_parms[*]
        3 parm_name = vc
      2 src_filter_parm_cnt = i4
      2 src_f_parms[*]
        3 parm_name = vc
      2 tgt_pkw_parm_cnt = i4
      2 tgt_pkw_parms[*]
        3 parm_name = vc
      2 src_pkw_parm_cnt = i4
      2 src_pkw_parms[*]
        3 parm_name = vc
      2 mover_string = vc
      2 exclusion_flg = i2
      2 column_cnt = i4
      2 pk_cnt = i4
      2 columns[*]
        3 column_name = vc
        3 no_compare_ind = i2
        3 no_backfill_ind = i2
        3 sequence_match = f8
        3 pe_val_cnt = i4
        3 parent_entity_vals[*]
          4 pe_table_value = vc
          4 pe_null_ind = i2
          4 tspace = i4
          4 char_0_ind = i2
          4 pe_name = vc
          4 pe_attr = vc
          4 root_entity_attr = vc
          4 root_entity_name = vc
          4 no_backfill_ind = i2
          4 exception_flg = i2
  )
 ENDIF
 DECLARE dra_gather_audit_info(dgai_info=vc(ref)) = null
 DECLARE dra_addl_tab_info(tab_info=vc(ref),dati_cnt=i4,dati_global=vc(ref),dati_md=vc(ref),
  dati_tab_loc=i4) = null
 DECLARE dra_get_pe_data(dgp_table_info=vc(ref),dgp_ti_loc=i4,dgp_peid_col=vc,dgp_pe_col=vc,
  dgp_md_rec=vc(ref),
  dgp_md_loc=i4,dgp_md_col_loc=i4,dgp_qp_rec=vc(ref),dgp_audit=vc(ref)) = null
 DECLARE dra_get_dcl_data(dgdd_tab_name=vc,dgdd_global=vc(ref),dgdd_info=vc(ref),dgdd_info_loc=i4) =
 null
 SUBROUTINE dra_gather_audit_info(dgai_info)
   SET dm_err->eproc = "Gathering audit sample size"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONFIGURATION"
     AND di.info_name="AUDIT_REPORT_SAMPLE_SIZE"
    DETAIL
     dgai_info->sample_size = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF (curqual=0)
    SET dgai_info->sample_size = 25
   ENDIF
   IF ((dgai_info->ctxt_ind=1))
    SET dm_err->eproc = "Checking for context_names to audit"
    SELECT INTO "NL:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONTEXT"
      AND di.info_name="CONTEXTS TO AUDIT"
     DETAIL
      dgai_info->ctxts_to_audit = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(null)
    ENDIF
    SET dgai_info->ctxt_null_ind = findstring("NULL",dgai_info->ctxts_to_audit,1,0)
   ENDIF
   SET stat = alterlist(dgai_info->audit_types,2)
   SET dgai_info->audit_types[1].audit_flg = 1
   SET dgai_info->audit_types[1].audit_desc = "Rows in the target domain that are not in the source"
   SET dgai_info->audit_types[2].audit_flg = 2
   SET dgai_info->audit_types[2].audit_desc = "Rows in the source domain that are not in the target"
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dra_addl_tab_info(tab_info,dati_cnt,dati_global,dati_md,dati_tab_loc)
   DECLARE dati_tgt_fltr_ind = i2 WITH protect, noconstant(0)
   DECLARE dati_src_fltr_ind = i2 WITH protect, noconstant(0)
   DECLARE dati_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE dati_loc = i4 WITH protect, noconstant(0)
   IF ((tab_info->tables[dati_cnt].table_name IN ("SEG_GRP_SEQ_R", "TIER_MATRIX")))
    SET tab_info->tables[dati_cnt].exclusion_flg = 4
   ENDIF
   FOR (dati_col_cnt = 1 TO dati_md->tbl_qual[dati_tab_loc].col_cnt)
     IF ((((dati_md->tbl_qual[dati_tab_loc].col_qual[dati_col_cnt].pk_ind=1)) OR ((dati_md->tbl_qual[
     dati_tab_loc].col_qual[dati_col_cnt].meaningful_ind=1))) )
      SET dati_md->tbl_qual[dati_tab_loc].col_qual[dati_col_cnt].audit_flag = 1
      IF ((dati_md->tbl_qual[dati_tab_loc].col_qual[dati_col_cnt].pk_ind=1))
       SET tab_info->tables[dati_cnt].pk_cnt = (tab_info->tables[dati_cnt].pk_cnt+ 1)
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=4001912.0
     AND cv.cdf_meaning="NORDDSTRG"
     AND cv.active_ind=1
     AND (cv.display=tab_info->tables[dati_cnt].table_name)
    DETAIL
     tab_info->tables[dati_cnt].exclusion_flg = 4, dati_md->tbl_qual[dati_tab_loc].mergeable_ind = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Check for table in 4001912 code_set failed"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   SET dm_err->eproc = "Checking for manual exclude in dm_info"
   SELECT INTO "NL:"
    FROM dm_info dm
    WHERE dm.info_domain="DATA MANAGEMENT"
     AND dm.info_name=concat("RDDS_MANUAL_EXCLUDE|",tab_info->tables[dati_cnt].table_name)
    DETAIL
     tab_info->tables[dati_cnt].exclusion_flg = dm.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Check for manual exclude failed"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   SELECT INTO "nl:"
    FROM dm_refchg_filter_test d
    WHERE (d.table_name=tab_info->tables[dati_cnt].table_name)
     AND d.active_ind=1
     AND  EXISTS (
    (SELECT
     "x"
     FROM dm_refchg_filter f
     WHERE f.table_name=d.table_name
      AND f.active_ind=1))
     AND  EXISTS (
    (SELECT
     "x"
     FROM dm_refchg_filter_parm p
     WHERE p.table_name=d.table_name
      AND p.active_ind=1))
    DETAIL
     dati_tgt_fltr_ind = 1, tab_info->tables[dati_cnt].mover_string = replace(replace(replace(d
        .mover_string,"<SUFFIX>","d"),"<MERGE LINK>",dati_global->db_link),"<UTC_DIFF>",concat("-(",
       trim(cnvtstring((curutcdiff/ 60))),"/1440)"))
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (parser(concat("dm_refchg_filter_test",dati_global->db_link)) d)
    WHERE (d.table_name=tab_info->tables[dati_cnt].table_name)
     AND d.active_ind=1
     AND  EXISTS (
    (SELECT
     "x"
     FROM (parser(concat("dm_refchg_filter",dati_global->db_link)) f)
     WHERE f.table_name=d.table_name
      AND f.active_ind=1))
     AND  EXISTS (
    (SELECT
     "x"
     FROM (parser(concat("dm_refchg_filter_parm",dati_global->db_link)) p)
     WHERE p.table_name=d.table_name
      AND p.active_ind=1))
    DETAIL
     dati_src_fltr_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    SET dm_err->emsg = "Check for mover filter failed"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   SET dm_err->eproc = "Checking for the function names in target"
   SELECT INTO "NL:"
    FROM user_objects o
    WHERE ((o.object_name=patstring(concat("REFCHG_FILTER_",dati_md->tbl_qual[dati_tab_loc].suffix,
      "*"))) OR (o.object_name=patstring(concat("REFCHG_PKW_",dati_md->tbl_qual[dati_tab_loc].suffix,
      "*"))))
    DETAIL
     IF (o.object_name="REFCHG_PKW*")
      tab_info->tables[dati_cnt].tgt_pkwhere_function = trim(o.object_name,3)
     ELSEIF (o.object_name="REFCHG_FILTER*"
      AND dati_tgt_fltr_ind=1)
      tab_info->tables[dati_cnt].tgt_filter_function = trim(o.object_name,3)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = concat("Filter and PKW target name check failed for  ",tab_info->tables[
     dati_cnt].table_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   SET dm_err->eproc = "Checking for the function names in source"
   SELECT INTO "NL:"
    FROM (parser(concat("user_objects",dati_global->db_link)) o)
    WHERE ((o.object_name=patstring(concat("REFCHG_FILTER_",dati_md->tbl_qual[dati_tab_loc].suffix,
      "*"))) OR (o.object_name=patstring(concat("REFCHG_PKW_",dati_md->tbl_qual[dati_tab_loc].suffix,
      "*"))))
    DETAIL
     IF (o.object_name="REFCHG_PKW*")
      tab_info->tables[dati_cnt].src_pkwhere_function = trim(o.object_name,3)
     ELSEIF (o.object_name="REFCHG_FILTER*"
      AND dati_src_fltr_ind=1)
      tab_info->tables[dati_cnt].src_filter_function = trim(o.object_name,3)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = concat("Filter and PKW source name check failed for ",tab_info->tables[
     dati_cnt].table_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   IF (dati_src_fltr_ind=1)
    SET dm_err->eproc = "Checking for parameters to be passed into the filter function"
    SELECT INTO "NL:"
     FROM (parser(concat("dm_refchg_filter_parm",dati_global->db_link)) d)
     WHERE (d.table_name=tab_info->tables[dati_cnt].table_name)
      AND d.active_ind=1
     ORDER BY d.parm_nbr
     DETAIL
      tab_info->tables[dati_cnt].src_filter_parm_cnt = (tab_info->tables[dati_cnt].
      src_filter_parm_cnt+ 1), stat = alterlist(tab_info->tables[dati_cnt].src_f_parms,tab_info->
       tables[dati_cnt].src_filter_parm_cnt), tab_info->tables[dati_cnt].src_f_parms[tab_info->
      tables[dati_cnt].src_filter_parm_cnt].parm_name = trim(d.column_name,3),
      dati_loc = locateval(dati_loc,1,dati_md->tbl_qual[dati_tab_loc].col_cnt,d.column_name,dati_md->
       tbl_qual[dati_tab_loc].col_qual[dati_loc].column_name)
      IF (dati_loc > 0
       AND (dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag=0))
       dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag = 2
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = concat("Filter function parameter check failed for ",tab_info->tables[
      dati_cnt].table_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   IF (dati_tgt_fltr_ind=1)
    SELECT INTO "NL:"
     FROM dm_refchg_filter_parm d
     WHERE (d.table_name=tab_info->tables[dati_cnt].table_name)
      AND d.active_ind=1
     ORDER BY d.parm_nbr
     DETAIL
      tab_info->tables[dati_cnt].tgt_filter_parm_cnt = (tab_info->tables[dati_cnt].
      tgt_filter_parm_cnt+ 1), stat = alterlist(tab_info->tables[dati_cnt].tgt_f_parms,tab_info->
       tables[dati_cnt].tgt_filter_parm_cnt), tab_info->tables[dati_cnt].tgt_f_parms[tab_info->
      tables[dati_cnt].tgt_filter_parm_cnt].parm_name = trim(d.column_name,3),
      dati_loc = locateval(dati_loc,1,dati_md->tbl_qual[dati_tab_loc].col_cnt,d.column_name,dati_md->
       tbl_qual[dati_tab_loc].col_qual[dati_loc].column_name)
      IF (dati_loc > 0
       AND (dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag=0))
       dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag = 2
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = concat("Filter function parameter check failed for ",tab_info->tables[
      dati_cnt].table_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   SET dm_err->eproc = "Checking for parameters to be passed into the pk_where function in source"
   SELECT INTO "NL:"
    FROM (parser(concat("dm_pk_where_parm",dati_global->db_link)) d)
    WHERE (d.table_name=tab_info->tables[dati_cnt].table_name)
     AND d.function_type="PK_WHERE"
     AND d.delete_ind=0
    ORDER BY d.parm_nbr
    DETAIL
     tab_info->tables[dati_cnt].src_pkw_parm_cnt = (tab_info->tables[dati_cnt].src_pkw_parm_cnt+ 1),
     stat = alterlist(tab_info->tables[dati_cnt].src_pkw_parms,tab_info->tables[dati_cnt].
      src_pkw_parm_cnt), tab_info->tables[dati_cnt].src_pkw_parms[tab_info->tables[dati_cnt].
     src_pkw_parm_cnt].parm_name = trim(d.column_name,3),
     dati_loc = locateval(dati_loc,1,dati_md->tbl_qual[dati_tab_loc].col_cnt,d.column_name,dati_md->
      tbl_qual[dati_tab_loc].col_qual[dati_loc].column_name)
     IF (dati_loc > 0
      AND (dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag=0))
      dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   SET dm_err->eproc = "Checking for parameters to be passed into the pk_where function in target"
   SELECT INTO "NL:"
    FROM dm_pk_where_parm d
    WHERE (d.table_name=tab_info->tables[dati_cnt].table_name)
     AND d.function_type="PK_WHERE"
     AND d.delete_ind=0
    ORDER BY d.parm_nbr
    DETAIL
     tab_info->tables[dati_cnt].tgt_pkw_parm_cnt = (tab_info->tables[dati_cnt].tgt_pkw_parm_cnt+ 1),
     stat = alterlist(tab_info->tables[dati_cnt].tgt_pkw_parms,tab_info->tables[dati_cnt].
      tgt_pkw_parm_cnt), tab_info->tables[dati_cnt].tgt_pkw_parms[tab_info->tables[dati_cnt].
     tgt_pkw_parm_cnt].parm_name = trim(d.column_name,3),
     dati_loc = locateval(dati_loc,1,dati_md->tbl_qual[dati_tab_loc].col_cnt,d.column_name,dati_md->
      tbl_qual[dati_tab_loc].col_qual[dati_loc].column_name)
     IF (dati_loc > 0
      AND (dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag=0))
      dati_md->tbl_qual[dati_tab_loc].col_qual[dati_loc].audit_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = concat("PK Where function parameter check failed for ",tab_info->tables[
     dati_cnt].table_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(tab_info)
    CALL echorecord(dati_md)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dra_get_pe_data(dgp_table_info,dgp_ti_loc,dgp_peid_col,dgp_pe_col,dgp_md_rec,dgp_md_loc,
  dgp_md_col_loc,dgp_qp_rec,dgp_audit)
   DECLARE length() = i4
   DECLARE evaluate_pe_name() = c255
   DECLARE dgp_qp_tab_loc = i4 WITH protect, noconstant(0)
   DECLARE dgp_subset_ind = i2 WITH protect, noconstant(dgp_audit->data_subset_ind)
   DECLARE dgp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgp_pk_list = vc WITH protect, noconstant(" ")
   DECLARE dgp_loc = i4 WITH protect, noconstant(0)
   DECLARE dgp_comma = i4 WITH protect, noconstant(0)
   SET dgp_qp_tab_loc = locateval(dgp_qp_tab_loc,1,dgp_qp_rec->tab_cnt,dgp_table_info->tables[
    dgp_ti_loc].table_name,dgp_qp_rec->tab_qual[dgp_qp_tab_loc].table_name)
   IF (dgp_qp_tab_loc=0)
    SET dgp_subset_ind = 0
   ENDIF
   FOR (dgp_cnt = 1 TO dgp_md_rec->tbl_qual[dgp_md_loc].col_cnt)
     IF ((dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[dgp_cnt].pk_ind=1))
      SET dgp_comma = (dgp_comma+ 1)
      IF (dgp_comma > 1)
       SET dgp_pk_list = concat(dgp_pk_list,",")
      ENDIF
      IF ((dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[dgp_cnt].nullable="Y"))
       IF ((dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[dgp_cnt].data_type="F8"))
        SET dgp_pk_list = concat(dgp_pk_list,"nullval(t.",dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[
         dgp_cnt].column_name,",-123888.4321)")
       ELSEIF ((dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[dgp_cnt].data_type="I*"))
        SET dgp_pk_list = concat(dgp_pk_list,"nullval(t.",dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[
         dgp_cnt].column_name,",-123888)")
       ELSEIF ((dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[dgp_cnt].data_type="DQ8"))
        SET dgp_pk_list = concat(dgp_pk_list,"nullval(t.",dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[
         dgp_cnt].column_name,",cnvtdatetime(cnvtdate(07231882),215212))")
       ELSE
        SET dgp_pk_list = concat(dgp_pk_list,"nullval(t.",dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[
         dgp_cnt].column_name,",'null_vaLue_CHeck_894.3')")
       ENDIF
      ELSE
       SET dgp_pk_list = concat(dgp_pk_list,"t.",dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[dgp_cnt].
        column_name)
      ENDIF
     ENDIF
   ENDFOR
   SET dgp_table_info->tables[dgp_ti_loc].column_cnt = (dgp_table_info->tables[dgp_ti_loc].column_cnt
   + 1)
   SET stat = alterlist(dgp_table_info->tables[dgp_ti_loc].columns,dgp_table_info->tables[dgp_ti_loc]
    .column_cnt)
   SET dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].
   column_name = dgp_md_rec->tbl_qual[dgp_md_loc].col_qual[dgp_md_col_loc].column_name
   SET dm_err->eproc = "Gathering parent_entity_name values from target"
   CALL parser(concat("Select distinct into 'nl:' t.",dgp_pe_col,", ni = nullind(t.",dgp_pe_col,
     "), tspc = length(t.",
     dgp_pe_col,")"),0)
   CALL parser(concat(" from ",dgp_table_info->tables[dgp_ti_loc].table_name," t "),0)
   IF (dgp_subset_ind=1)
    CALL parser(concat("where list(",dgp_pk_list,") in("),0)
    FOR (dgp_cnt = 1 TO dgp_qp_rec->cnt)
      IF (dgp_cnt=1)
       CALL parser(replace(replace(dgp_qp_rec->qual[dgp_cnt].text,"<COLUMN_LIST>",dgp_pk_list),"t.",
         concat(dgp_qp_rec->tab_qual[dgp_qp_tab_loc].table_alias,".")),0)
      ELSE
       CALL parser(replace(dgp_qp_rec->qual[dgp_cnt].text,"<DB_LINK>"," "),0)
      ENDIF
    ENDFOR
    CALL parser(")",0)
   ELSE
    CALL parser(" where 1=1 ",0)
   ENDIF
   CALL parser(concat(" order by t.",dgp_pe_col),0)
   CALL parser(" detail ",0)
   CALL parser(
    " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cnt = ",
    0)
   CALL parser(
    "    dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cnt + 1",
    0)
   CALL parser(concat(" stat = alterlist(dgp_table_info->tables[dgp_ti_loc].",
     "columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].parent_entity_vals, "),0)
   CALL parser(
    "    dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cnt)",
    0)
   CALL parser(concat(
     " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    pe_table_value = trim(t.",dgp_pe_col,")"),0)
   CALL parser(concat(
     " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    pe_null_ind = ni "),0)
   CALL parser(concat(
     " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
",
     "    tspace = (tspc - size(dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    pe_table_value))"),0)
   CALL parser(concat(" if(findstring(char(0),t.",dgp_pe_col,") > 0)"),0)
   CALL parser(concat(
     "    dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    char_0_ind = 1 "),0)
   CALL parser(" endif",0)
   CALL parser(" with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dgp_table_info)
   ENDIF
   SET dm_err->eproc = "Gathering parent_entity_name values from source"
   CALL parser(concat("Select distinct into 'nl:' t.",dgp_pe_col,", ni = nullind(t.",dgp_pe_col,
     "), tspc = length(t.",
     dgp_pe_col,")"),0)
   CALL parser(concat(" from ",dgp_table_info->tables[dgp_ti_loc].table_name,drgi_global->db_link,
     " t "),0)
   IF (dgp_subset_ind=1)
    CALL parser(concat("where list(",dgp_pk_list,") in("),0)
    FOR (dgp_cnt = 1 TO dgp_qp_rec->cnt)
      IF (dgp_cnt=1)
       CALL parser(replace(replace(dgp_qp_rec->qual[dgp_cnt].text,"<COLUMN_LIST>",dgp_pk_list),"t.",
         concat(dgp_qp_rec->tab_qual[dgp_qp_tab_loc].table_alias,".")),0)
      ELSE
       CALL parser(replace(dgp_qp_rec->qual[dgp_cnt].text,"<DB_LINK>",drgi_global->db_link),0)
      ENDIF
    ENDFOR
    CALL parser(")",0)
   ELSE
    CALL parser(" where 1=1 ",0)
   ENDIF
   CALL parser(concat(" order by t.",dgp_pe_col),0)
   CALL parser(" detail ",0)
   CALL parser(concat(" dgp_loc = locateval(dgp_loc,1,",
     "dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cnt,t.",
     dgp_pe_col,
     ",dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
",
     "    pe_table_value)"),0)
   CALL parser(" if(dgp_loc = 0)",0)
   CALL parser(
    " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cnt = ",
    0)
   CALL parser(
    "    dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cnt + 1",
    0)
   CALL parser(concat(" stat = alterlist(dgp_table_info->tables[dgp_ti_loc].",
     "columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].parent_entity_vals, "),0)
   CALL parser(
    "    dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cnt)",
    0)
   CALL parser(concat(
     " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    pe_table_value = trim(t.",dgp_pe_col,")"),0)
   CALL parser(concat(
     " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    pe_null_ind = ni "),0)
   CALL parser(concat(
     " dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
",
     "    tspace = (tspc - size(dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    pe_table_value))"),0)
   CALL parser(concat(" if(findstring(char(0),t.",dgp_pe_col,") > 0)"),0)
   CALL parser(concat(
     "    dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].",
"    parent_entity_vals[dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].pe_val_cn\
t].\
","    char_0_ind = 1 "),0)
   CALL parser(" endif",0)
   CALL parser(" endif ",0)
   CALL parser(" with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dgp_table_info)
   ENDIF
   SET dm_err->eproc = "Evaluating parent_entity values"
   FOR (dgp_cnt = 1 TO dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].
   column_cnt].pe_val_cnt)
    SELECT INTO "nl:"
     result = evaluate_pe_name(dgp_table_info->tables[dgp_ti_loc].table_name,dgp_peid_col,dgp_pe_col,
      dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].
      parent_entity_vals[dgp_cnt].pe_table_value)
     FROM dual
     DETAIL
      dgp_table_info->tables[dgp_ti_loc].columns[dgp_table_info->tables[dgp_ti_loc].column_cnt].
      parent_entity_vals[dgp_cnt].pe_name = result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dgp_table_info)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dra_get_dcl_data(dgdd_tab_name,dgdd_global,dgdd_info,dgdd_info_loc)
   DECLARE dgdd_num = i4 WITH protect, noconstant(0)
   DECLARE dgdd_loc = i4 WITH protect, noconstant(0)
   DECLARE dgdd_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dgdd_parse
   RECORD dgdd_parse(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD dgdd_data_rec
   RECORD dgdd_data_rec(
     1 cnt = i4
     1 qual[*]
       2 pk_where = vc
       2 pk_where_value = f8
       2 log_type = vc
       2 context_name = vc
       2 log_id = f8
       2 chg_log_reason_text = vc
       2 updt_dt_tm = dq8
       2 status = vc
   )
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("DCL INFO_LOC:",trim(cnvtstring(dgdd_info_loc))))
    CALL echorecord(dgdd_info)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    g.pk_where, g.pk_where_value, g.status
    FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g)
    WHERE g.status IN ("SOURCE", "TARGET")
    DETAIL
     dgdd_data_rec->cnt = (dgdd_data_rec->cnt+ 1), stat = alterlist(dgdd_data_rec->qual,dgdd_data_rec
      ->cnt), dgdd_data_rec->qual[dgdd_data_rec->cnt].pk_where = g.pk_where,
     dgdd_data_rec->qual[dgdd_data_rec->cnt].pk_where_value = g.pk_where_value, dgdd_data_rec->qual[
     dgdd_data_rec->cnt].log_type = "NO ROW", dgdd_data_rec->qual[dgdd_data_rec->cnt].log_id = 0.0,
     dgdd_data_rec->qual[dgdd_data_rec->cnt].chg_log_reason_text = "NO ROW", dgdd_data_rec->qual[
     dgdd_data_rec->cnt].context_name = "NO ROW", dgdd_data_rec->qual[dgdd_data_rec->cnt].status = g
     .status
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dgdd_data_rec)
   ENDIF
   INSERT  FROM dm_refchg_comp_gttd
    (r_column_value, r_ptam_hash_value, status)(SELECT DISTINCT
     g.pk_where, g.pk_where_value, g.status
     FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g)
     WHERE g.status IN ("SOURCE", "TARGET"))
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    ctx_nvl = nullval(d.context_name,"NULL")
    FROM (parser(concat("DM_CHG_LOG",dgdd_global->db_link)) d)
    WHERE (d.target_env_id=dgdd_global->target_id)
     AND d.table_name=dgdd_tab_name
     AND list(d.pk_where,d.pk_where_value) IN (
    (SELECT
     t.r_column_value, t.r_ptam_hash_value
     FROM dm_refchg_comp_gttd t
     WHERE t.status="SOURCE"))
    ORDER BY d.updt_dt_tm DESC
    DETAIL
     dgdd_loc = locateval(dgdd_loc,1,dgdd_data_rec->cnt,d.pk_where,dgdd_data_rec->qual[dgdd_loc].
      pk_where,
      d.pk_where_value,dgdd_data_rec->qual[dgdd_loc].pk_where_value,"SOURCE",dgdd_data_rec->qual[
      dgdd_loc].status)
     IF (dgdd_loc > 0
      AND (d.updt_dt_tm > dgdd_data_rec->qual[dgdd_loc].updt_dt_tm))
      IF (findstring(concat("::",d.context_name,"::"),concat("::",dgdd_global->ctp_value,"::")) > 0
       AND  NOT (d.log_type IN ("REFCHG", "NORDDS")))
       dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
       .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
       dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
       updt_dt_tm = d.updt_dt_tm
      ELSEIF (findstring(concat("::",d.context_name,"::"),concat("::",dgdd_global->ctp_value,"::"))
       > 0)
       dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
       .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
       dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
       updt_dt_tm = d.updt_dt_tm
      ELSE
       dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
       .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
       dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
       updt_dt_tm = d.updt_dt_tm
      ENDIF
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    ctx_nvl = nullval(d.context_name,"NULL")
    FROM dm_chg_log d
    WHERE (d.target_env_id=dgdd_global->source_id)
     AND d.table_name=dgdd_tab_name
     AND list(d.pk_where,d.pk_where_value) IN (
    (SELECT
     t.r_column_value, t.r_ptam_hash_value
     FROM dm_refchg_comp_gttd t
     WHERE t.status="TARGET"))
    ORDER BY d.updt_dt_tm DESC
    DETAIL
     dgdd_loc = locateval(dgdd_loc,1,dgdd_data_rec->cnt,d.pk_where,dgdd_data_rec->qual[dgdd_loc].
      pk_where,
      d.pk_where_value,dgdd_data_rec->qual[dgdd_loc].pk_where_value,"TARGET",dgdd_data_rec->qual[
      dgdd_loc].status)
     IF (dgdd_loc > 0
      AND (d.updt_dt_tm > dgdd_data_rec->qual[dgdd_loc].updt_dt_tm))
      IF ( NOT (d.log_type IN ("REFCHG", "NORDDS")))
       dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
       .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
       dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
       updt_dt_tm = d.updt_dt_tm
      ELSE
       dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
       .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
       dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
       updt_dt_tm = d.updt_dt_tm
      ENDIF
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dgdd_data_rec)
   ENDIF
   UPDATE  FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g),
     (dummyt d  WITH seq = dgdd_data_rec->cnt)
    SET g.log_type = dgdd_data_rec->qual[d.seq].log_type, g.log_id = dgdd_data_rec->qual[d.seq].
     log_id, g.context_name = dgdd_data_rec->qual[d.seq].context_name,
     g.chg_log_reason_txt = dgdd_data_rec->qual[d.seq].chg_log_reason_text
    PLAN (d)
     JOIN (g
     WHERE (g.pk_where=dgdd_data_rec->qual[d.seq].pk_where)
      AND (g.pk_where_value=dgdd_data_rec->qual[d.seq].pk_where_value))
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dgdd_cnt = 1
   SET stat = alterlist(dgdd_parse->stmt,500)
   SET dgdd_parse->stmt[dgdd_cnt].str = concat("rdb ASIS(^update DM_RDDS_",trim(currdbhandle),
    "_AUD_GTTD d^)")
   SET dgdd_cnt = (dgdd_cnt+ 1)
   SET dgdd_parse->stmt[dgdd_cnt].str = concat("ASIS(^ set d.pk_where = ",dgdd_info->tables[
    dgdd_info_loc].src_pkw_str,",^)")
   SET dgdd_cnt = (dgdd_cnt+ 1)
   SET dgdd_parse->stmt[dgdd_cnt].str = concat(
    "ASIS(^ d.pk_where_value = dbms_utility.get_hash_value(",dgdd_info->tables[dgdd_info_loc].
    src_pkw_str,",0,1073741824.0)^)")
   SET dgdd_cnt = (dgdd_cnt+ 1)
   SET dgdd_parse->stmt[dgdd_cnt].str =
   "ASIS(^ where d.status = 'SOURCE' and d.log_type = 'NO ROW' ^) go"
   SET stat = alterlist(dgdd_parse->stmt,dgdd_cnt)
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DGDD_PARSE")
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET stat = initrec(dgdd_data_rec)
    SELECT DISTINCT INTO "nl:"
     g.pk_where, g.pk_where_value
     FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g)
     WHERE g.status="SOURCE"
      AND g.log_type="NO ROW"
     DETAIL
      dgdd_data_rec->cnt = (dgdd_data_rec->cnt+ 1), stat = alterlist(dgdd_data_rec->qual,
       dgdd_data_rec->cnt), dgdd_data_rec->qual[dgdd_data_rec->cnt].pk_where = g.pk_where,
      dgdd_data_rec->qual[dgdd_data_rec->cnt].pk_where_value = g.pk_where_value, dgdd_data_rec->qual[
      dgdd_data_rec->cnt].log_type = "NO ROW", dgdd_data_rec->qual[dgdd_data_rec->cnt].log_id = 0.0,
      dgdd_data_rec->qual[dgdd_data_rec->cnt].chg_log_reason_text = "NO ROW", dgdd_data_rec->qual[
      dgdd_data_rec->cnt].context_name = "NO ROW", dgdd_data_rec->qual[dgdd_data_rec->cnt].status = g
      .status
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dgdd_data_rec)
    ENDIF
    INSERT  FROM dm_refchg_comp_gttd
     (r_column_value, r_ptam_hash_value, status)(SELECT DISTINCT
      g.pk_where, g.pk_where_value, g.status
      FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g)
      WHERE g.status="SOURCE"
       AND g.log_type="NO ROW")
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
    SELECT INTO "nl:"
     ctx_nvl = nullval(d.context_name,"NULL")
     FROM (parser(concat("DM_CHG_LOG",dgdd_global->db_link)) d)
     WHERE (d.target_env_id=dgdd_global->target_id)
      AND d.table_name=dgdd_tab_name
      AND list(d.pk_where,d.pk_where_value) IN (
     (SELECT
      t.r_column_value, t.r_ptam_hash_value
      FROM dm_refchg_comp_gttd t
      WHERE t.status="SOURCE"))
     ORDER BY d.updt_dt_tm DESC
     DETAIL
      dgdd_loc = locateval(dgdd_loc,1,dgdd_data_rec->cnt,d.pk_where,dgdd_data_rec->qual[dgdd_loc].
       pk_where,
       d.pk_where_value,dgdd_data_rec->qual[dgdd_loc].pk_where_value,"SOURCE",dgdd_data_rec->qual[
       dgdd_loc].status)
      IF (dgdd_loc > 0
       AND (d.updt_dt_tm > dgdd_data_rec->qual[dgdd_loc].updt_dt_tm))
       IF (findstring(concat("::",d.context_name,"::"),concat("::",dgdd_global->ctp_value,"::")) > 0
        AND  NOT (d.log_type IN ("REFCHG", "NORDDS")))
        dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
        .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
        dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
        updt_dt_tm = d.updt_dt_tm
       ELSEIF (findstring(concat("::",d.context_name,"::"),concat("::",dgdd_global->ctp_value,"::"))
        > 0)
        dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
        .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
        dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
        updt_dt_tm = d.updt_dt_tm
       ELSE
        dgdd_data_rec->qual[dgdd_loc].log_type = d.log_type, dgdd_data_rec->qual[dgdd_loc].log_id = d
        .log_id, dgdd_data_rec->qual[dgdd_loc].chg_log_reason_text = d.chg_log_reason_txt,
        dgdd_data_rec->qual[dgdd_loc].context_name = trim(ctx_nvl), dgdd_data_rec->qual[dgdd_loc].
        updt_dt_tm = d.updt_dt_tm
       ENDIF
      ENDIF
     WITH nocounter, expand = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
    UPDATE  FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g),
      (dummyt d  WITH seq = dgdd_data_rec->cnt)
     SET g.log_type = dgdd_data_rec->qual[d.seq].log_type, g.log_id = dgdd_data_rec->qual[d.seq].
      log_id, g.context_name = dgdd_data_rec->qual[d.seq].context_name,
      g.chg_log_reason_txt = dgdd_data_rec->qual[d.seq].chg_log_reason_text
     PLAN (d)
      JOIN (g
      WHERE (g.pk_where=dgdd_data_rec->qual[d.seq].pk_where)
       AND (g.pk_where_value=dgdd_data_rec->qual[d.seq].pk_where_value)
       AND g.status="SOURCE"
       AND g.log_type="NO ROW")
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
   ENDIF
 END ;Subroutine
 IF (validate(drqp_reply->tab_cnt,99)=99)
  FREE RECORD drqp_reply
  RECORD drqp_reply(
    1 tab_cnt = i4
    1 tab_qual[*]
      2 table_name = vc
      2 table_alias = vc
      2 dummyt_ind = i2
    1 col_cnt = i4
    1 col_qual[*]
      2 return_phrase = vc
      2 return_name = vc
      2 return_clause = vc
      2 func_ind = i2
      2 clause_alias = vc
      2 clause_column = vc
      2 all_col_ind = i2
    1 cnt = i4
    1 qual[*]
      2 text = vc
  )
 ENDIF
 DECLARE regen_trigs(null) = i4
 DECLARE check_open_event(cur_env_id=f8,paired_env_id=f8) = i4
 SUBROUTINE regen_trigs(null)
   DECLARE rt_err_flg = i2 WITH protect, noconstant(0)
   FREE RECORD invalid
   RECORD invalid(
     1 data[*]
       2 name = vc
   )
   SET dm_err->eproc = "Regenerating triggers..."
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_add_refchg_log_triggers
   SET dm_err->eproc = "RECOMPILING INVALID TRIGGERS"
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    HEAD REPORT
     trig_cnt = 0
    DETAIL
     trig_cnt = (trig_cnt+ 1)
     IF (mod(trig_cnt,10)=1)
      stat = alterlist(invalid->data,(trig_cnt+ 9))
     ENDIF
     invalid->data[trig_cnt].name = d1.object_name
    FOOT REPORT
     stat = alterlist(invalid->data,trig_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error checking invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   FOR (t_ndx = 1 TO size(invalid->data,5))
     CALL parser(concat("RDB ASIS(^alter trigger ",invalid->data[t_ndx].name," compile^) go"))
   ENDFOR
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    DETAIL
     v_trigger_name = d1.object_name
    WITH nocounter, maxqual(d1,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error compiling invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Triggers regenerated successfully."
    SET rt_err_flg = 0
   ELSE
    SET dm_err->eproc = "Error regenerating RDDS related triggers."
    SET rt_err_flg = 1
    RETURN(rt_err_flg)
   ENDIF
   RETURN(rt_err_flg)
 END ;Subroutine
 SUBROUTINE check_open_event(cur_env_id,paired_env_id)
   DECLARE coe_event_flg = i4 WITH protect
   IF (cur_env_id > 0
    AND paired_env_id > 0)
    SET dm_err->eproc = "Checking open events for environment pair."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND drel.paired_environment_id=paired_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND paired_environment_id=paired_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Determining reverse open events for environment pair."
     SELECT INTO "NL:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event="Begin Reference Data Sync"
       AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND drel.cur_environment_id=paired_env_id
       AND drel.paired_environment_id=cur_env_id
       AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
      (SELECT
       cur_environment_id, paired_environment_id, event_reason
       FROM dm_rdds_event_log
       WHERE cur_environment_id=paired_env_id
        AND paired_environment_id=cur_env_id
        AND rdds_event="End Reference Data Sync"
        AND rdds_event_key="ENDREFERENCEDATASYNC")))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(coe_event_flg)
     ENDIF
     IF (curqual > 0)
      SET coe_event_flg = 2
     ENDIF
    ELSE
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   IF (paired_env_id=0)
    SET dm_err->eproc = "Determining open events for current environment."
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual > 0)
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   RETURN(coe_event_flg)
 END ;Subroutine
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
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
 DECLARE drdc_to_string(dts_num=f8) = vc
 SUBROUTINE drdc_to_string(dts_num)
   DECLARE dts_str = vc WITH protect, noconstant("")
   SET dts_str = trim(cnvtstring(dts_num,20),3)
   IF (findstring(".",dts_str)=0)
    SET dts_str = concat(dts_str,".0")
   ENDIF
   RETURN(dts_str)
 END ;Subroutine
 DECLARE drmmi_set_mock_id(dsmi_cur_id=f8,dsmi_final_tgt_id=f8,dsmi_mock_ind=i2) = i4
 DECLARE drmmi_get_mock_id(dgmi_env_id=f8) = f8
 DECLARE drmmi_backfill_mock_id(dbmi_env_id=f8) = f8
 SUBROUTINE drmmi_set_mock_id(dsmi_cur_id,dsmi_final_tgt_id,dsmi_mock_ind)
   DECLARE dsmi_info_char = vc WITH protect, noconstant("")
   DECLARE dsmi_mock_str = vc WITH protect, noconstant("")
   SET dsmi_info_char = drdc_to_string(dsmi_cur_id)
   SET dm_err->eproc = "Delete current mock setting."
   DELETE  FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dsmi_mock_ind=1)
    SET dsmi_mock_str = "RDDS_MOCK_ENV_ID"
   ELSE
    SET dsmi_mock_str = "RDDS_NO_MOCK_ENV_ID"
   ENDIF
   SET dm_err->eproc = "Inserting new mock setting into dm_info."
   INSERT  FROM dm_info di
    SET di.info_domain = "DATA MANAGEMENT", di.info_name = dsmi_mock_str, di.info_number =
     dsmi_final_tgt_id,
     di.info_char = dsmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Log Mock Copy of Prod Change event."
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Mock Copy of Prod Change"
   SET auto_ver_request->qual[1].cur_environment_id = dsmi_cur_id
   SET auto_ver_request->qual[1].paired_environment_id = dsmi_final_tgt_id
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmmi_get_mock_id(dgmi_env_id)
   DECLARE dgmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgmi_info_char = vc WITH protect, noconstant("")
   IF (dgmi_env_id=0.0)
    SET dm_err->eproc = "Gathering environment_id from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dgmi_env_id = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ELSEIF (dgmi_env_id=0.0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Could not retrieve valid environment_id"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET dgmi_info_char = drdc_to_string(dgmi_env_id)
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dgmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dgmi_mock_id = di.info_number
     ELSE
      dgmi_mock_id = dgmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSEIF (curqual > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid MOCK setup detected."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgmi_mock_id=0.0)
    SET dgmi_mock_id = drmmi_backfill_mock_id(dgmi_env_id)
    IF (dgmi_mock_id < 0.0)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(dgmi_mock_id)
 END ;Subroutine
 SUBROUTINE drmmi_backfill_mock_id(dbmi_env_id)
   DECLARE dbmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dbmi_info_char = vc WITH protect, noconstant("")
   DECLARE dbmi_continue = i2 WITH protect, noconstant(0)
   SET dbmi_info_char = drdc_to_string(dbmi_env_id)
   WHILE (dbmi_continue=0)
     SET drl_reply->status = ""
     SET drl_reply->status_msg = ""
     CALL get_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,0,drl_reply)
     IF ((drl_reply->status="F"))
      CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = drl_reply->status_msg
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSEIF ((drl_reply->status="Z"))
      CALL pause(10)
     ELSE
      SET dbmi_continue = 1
     ENDIF
   ENDWHILE
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dbmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dbmi_mock_id = di.info_number
     ELSE
      dbmi_mock_id = dbmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
    RETURN(- (1))
   ENDIF
   IF (dbmi_mock_id=0.0)
    UPDATE  FROM dm_info di
     SET di.info_char = dbmi_info_char
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS_MOCK_ENV_ID"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
     RETURN(- (1))
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Updating RDDS_NO_MOCK_ENV_ID row."
     UPDATE  FROM dm_info di
      SET di.info_number = 0.0, di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->
       updt_applctx,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = reqinfo->updt_id,
       di.updt_task = reqinfo->updt_task
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_NO_MOCK_ENV_ID"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSE
      COMMIT
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = "Inserting RDDS_NO_MOCK_ENV_ID row."
      INSERT  FROM dm_info di
       SET di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS_NO_MOCK_ENV_ID", di.info_number
         = 0.0,
        di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
       RETURN(- (1))
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dbmi_mock_id = dbmi_env_id
    ELSE
     SET dm_err->eproc = "Querying for mock id."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_MOCK_ENV_ID"
       AND di.info_char=dbmi_info_char
      DETAIL
       dbmi_mock_id = di.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
   RETURN(dbmi_mock_id)
 END ;Subroutine
 DECLARE regen_trigs(null) = i4
 DECLARE check_open_event(cur_env_id=f8,paired_env_id=f8) = i4
 SUBROUTINE regen_trigs(null)
   DECLARE rt_err_flg = i2 WITH protect, noconstant(0)
   FREE RECORD invalid
   RECORD invalid(
     1 data[*]
       2 name = vc
   )
   SET dm_err->eproc = "Regenerating triggers..."
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_add_refchg_log_triggers
   SET dm_err->eproc = "RECOMPILING INVALID TRIGGERS"
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    HEAD REPORT
     trig_cnt = 0
    DETAIL
     trig_cnt = (trig_cnt+ 1)
     IF (mod(trig_cnt,10)=1)
      stat = alterlist(invalid->data,(trig_cnt+ 9))
     ENDIF
     invalid->data[trig_cnt].name = d1.object_name
    FOOT REPORT
     stat = alterlist(invalid->data,trig_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error checking invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   FOR (t_ndx = 1 TO size(invalid->data,5))
     CALL parser(concat("RDB ASIS(^alter trigger ",invalid->data[t_ndx].name," compile^) go"))
   ENDFOR
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    DETAIL
     v_trigger_name = d1.object_name
    WITH nocounter, maxqual(d1,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error compiling invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Triggers regenerated successfully."
    SET rt_err_flg = 0
   ELSE
    SET dm_err->eproc = "Error regenerating RDDS related triggers."
    SET rt_err_flg = 1
    RETURN(rt_err_flg)
   ENDIF
   RETURN(rt_err_flg)
 END ;Subroutine
 SUBROUTINE check_open_event(cur_env_id,paired_env_id)
   DECLARE coe_event_flg = i4 WITH protect
   IF (cur_env_id > 0
    AND paired_env_id > 0)
    SET dm_err->eproc = "Checking open events for environment pair."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND drel.paired_environment_id=paired_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND paired_environment_id=paired_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Determining reverse open events for environment pair."
     SELECT INTO "NL:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event="Begin Reference Data Sync"
       AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND drel.cur_environment_id=paired_env_id
       AND drel.paired_environment_id=cur_env_id
       AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
      (SELECT
       cur_environment_id, paired_environment_id, event_reason
       FROM dm_rdds_event_log
       WHERE cur_environment_id=paired_env_id
        AND paired_environment_id=cur_env_id
        AND rdds_event="End Reference Data Sync"
        AND rdds_event_key="ENDREFERENCEDATASYNC")))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(coe_event_flg)
     ENDIF
     IF (curqual > 0)
      SET coe_event_flg = 2
     ENDIF
    ELSE
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   IF (paired_env_id=0)
    SET dm_err->eproc = "Determining open events for current environment."
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual > 0)
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   RETURN(coe_event_flg)
 END ;Subroutine
 IF ((validate(drgi_global->source_id,- (12341))=- (12341)))
  FREE RECORD drgi_global
  RECORD drgi_global(
    1 start_dt_tm = dq8
    1 source_id = f8
    1 source_name = vc
    1 target_id = f8
    1 target_name = vc
    1 mock_id = f8
    1 env_mapping = f8
    1 db_link = vc
    1 cbc_ind = i2
    1 ctp_value = vc
    1 cts_value = vc
    1 ctxt_group_ind = i2
    1 default_ctxt = vc
    1 ptam_ind = i2
    1 oe_ind = i2
  )
 ENDIF
 DECLARE dgi_get_global_info(dgi_global=vc(ref)) = i2
 SUBROUTINE dgi_get_global_info(dgi_global)
   IF ((dgi_global->start_dt_tm=0.0))
    SET dgi_global->start_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF ((((dgi_global->target_id=0.0)) OR ((dgi_global->mock_id=0.0))) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
     DETAIL
      dgi_global->target_id = d.info_number, dgi_global->mock_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No local environment set.  Please run DM_SET_ENV_ID"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    SET dgi_global->mock_id = drmmi_get_mock_id(dgi_global->target_id)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dgi_global->oe_ind=0))
    SET dgi_global->oe_ind = check_open_event(dgi_global->target_id,0.0)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dgi_global->oe_ind=1))
    IF ((dgi_global->source_id=0.0))
     SELECT INTO "NL:"
      FROM dm_rdds_event_log d
      WHERE d.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND (d.cur_environment_id=dgi_global->target_id)
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_rdds_event_log l
       WHERE (l.cur_environment_id=dgi_global->target_id)
        AND l.rdds_event_key="ENDREFERENCEDATASYNC"
        AND l.event_reason=d.event_reason
        AND l.paired_environment_id=d.paired_environment_id)))
      DETAIL
       dgi_global->source_id = d.paired_environment_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
    IF ((dgi_global->db_link <= " "))
     SELECT INTO "NL:"
      FROM dm_env_reltn d
      WHERE (d.child_env_id=dgi_global->target_id)
       AND (d.parent_env_id=dgi_global->source_id)
       AND d.relationship_type="REFERENCE MERGE"
       AND d.post_link_name > " "
      DETAIL
       dgi_global->db_link = d.post_link_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
    IF ((dgi_global->env_mapping <= 0.0))
     SELECT INTO "NL:"
      FROM dm_info d
      WHERE d.info_domain="RDDS ENV PAIR"
       AND d.info_name=concat(cnvtstring(dgi_global->source_id),"::",cnvtstring(dgi_global->target_id
        ))
      DETAIL
       dgi_global->env_mapping = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
    IF ((dgi_global->ptam_ind=0))
     SELECT INTO "NL:"
      FROM dm_env_reltn d
      WHERE relationship_type="PENDING TARGET AS MASTER"
       AND (parent_env_id=dgi_global->source_id)
       AND (child_env_id=dgi_global->target_id)
      DETAIL
       dgi_global->ptam_ind = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   IF ((((dgi_global->source_name <= " ")) OR ((dgi_global->target_name <= " "))) )
    SELECT INTO "NL:"
     FROM dm_environment d
     WHERE d.environment_id IN (dgi_global->source_id, dgi_global->target_id)
     DETAIL
      IF ((d.environment_id=dgi_global->source_id))
       dgi_global->source_name = d.environment_name
      ELSE
       dgi_global->target_name = d.environment_name
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dgi_global->cbc_ind=0))
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="CUTOVER BY CONTEXT"
     DETAIL
      dgi_global->cbc_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((((dgi_global->ctp_value <= " ")) OR ((((dgi_global->cts_value <= " ")) OR ((((dgi_global->
   default_ctxt <= " ")) OR ((dgi_global->ctxt_group_ind=0))) )) )) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name IN ("CONTEXTS TO PULL", "CONTEXT TO SET", "CONTEXT GROUP_IND",
     "DEFAULT CONTEXT")
     DETAIL
      IF (d.info_name="CONTEXTS TO PULL")
       dgi_global->ctp_value = d.info_char
      ELSEIF (d.info_name="CONTEXT TO SET")
       dgi_global->cts_value = d.info_char
      ELSEIF (d.info_name="DEFAULT CONTEXT")
       dgi_global->default_ctxt = d.info_char
      ELSEIF (d.info_name="CONTEXT GROUP_IND")
       dgi_global->ctxt_group_ind = d.info_number
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE drrm_ack_mig(dam_oe_name=vc,dam_env_id=f8) = null
 DECLARE drrm_check_ack(dca_oe_name=vc) = i2
 DECLARE drrm_check_mig(dcm_check_ack_ind=i2,dcm_oe_name=vc) = i4
 DECLARE drrm_check_freeze(dcf_env_id=f8) = i2
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE drrm_ack_mig(dam_oe_name,dam_env_id)
   IF (size(trim(dam_oe_name))=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No event name passed into DRRM_ACK_MIG."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "MIGRATION ACKNOWLEDGE"
   SET auto_ver_request->qual[1].event_reason = dam_oe_name
   IF (dam_env_id=0.0)
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
     DETAIL
      auto_ver_request->qual[1].cur_environment_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET stat = initrec(auto_ver_request)
     RETURN(null)
    ENDIF
    IF ((auto_ver_request->qual[1].cur_environment_id=0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No environment_id found.  Please run DM_SET_ENV_ID to correct."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET stat = initrec(auto_ver_request)
     RETURN(null)
    ENDIF
   ELSE
    SET auto_ver_request->qual[1].cur_environment_id = dam_env_id
   ENDIF
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
   SET stat = initrec(auto_ver_reply)
   SET stat = initrec(auto_ver_request)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drrm_check_ack(dca_oe_name)
   DECLARE dca_return = i2 WITH protect, noconstant(0)
   IF (size(trim(dca_oe_name)) > 0)
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_rdds_event_log d,
      dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
      AND d.cur_environment_id=di.info_number
      AND d.rdds_event_key="MIGRATIONACKNOWLEDGE"
      AND d.event_reason=dca_oe_name
     DETAIL
      IF (cnt > 0)
       dca_return = 1
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_rdds_event_log d2,
      dm_rdds_event_log d,
      dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
      AND d.cur_environment_id=di.info_number
      AND d.rdds_event_key="MIGRATIONACKNOWLEDGE"
      AND d2.cur_environment_id=d.cur_environment_id
      AND d2.event_reason=d.event_reason
      AND d2.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND  NOT (list(d2.cur_environment_id,d2.paired_environment_id,d2.event_reason) IN (
     (SELECT
      d3.cur_environment_id, d3.paired_environment_id, d3.event_reason
      FROM dm_rdds_event_log d3
      WHERE d3.rdds_event_key="ENDREFERENCEDATASYNC"
       AND d3.cur_environment_id=di.info_number)))
     DETAIL
      IF (cnt > 0)
       dca_return = cnt
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   RETURN(dca_return)
 END ;Subroutine
 SUBROUTINE drrm_check_mig(dcm_ack_ind,dcm_oe_name)
   DECLARE PUBLIC::dcm_return = i4 WITH protect, noconstant(0)
   DECLARE PUBLIC::dcm_ack_ret = i2 WITH protect, noconstant(0)
   DECLARE PUBLIC::dcm_script_name = vc WITH protect, noconstant("DM2_MIG_STATUS_CHECK")
   IF (validate(PUBLIC::dm2_mig_status,"-1")="-1")
    DECLARE PUBLIC::dm2_mig_status = vc WITH protect, noconstant("")
   ENDIF
   IF (validate(PUBLIC::dm2_mig_utc_status,"-1")="-1")
    DECLARE PUBLIC::dm2_mig_utc_status = vc WITH protect, noconstant("")
   ENDIF
   IF (checkprg(dcm_script_name) > 0)
    EXECUTE dm2_mig_status_check
    IF (((check_error(dm_err->eproc)=1) OR (((cnvtupper(dm2_mig_status) IN ("", "ERROR")) OR (
    cnvtupper(dm2_mig_utc_status) IN ("", "ERROR"))) )) )
     IF (size(trim(dm_err->emsg))=0)
      SET dm_err->emsg = "Unexpected error occurred in DM2_MIG_STATUS_CHECK"
      SET dm_err->err_ind = 1
     ENDIF
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (cnvtupper(dm2_mig_status)="ON")
     IF (cnvtupper(dm2_mig_utc_status)="ON")
      SET dcm_return = 2
     ELSE
      SET dcm_return = 1
     ENDIF
     IF (dcm_ack_ind=1)
      SET dcm_ack_ret = drrm_check_ack(dcm_oe_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dcm_ack_ret=1)
       SET dcm_return = 0
      ENDIF
     ENDIF
    ELSE
     SET dcm_return = 0
    ENDIF
   ELSE
    SET dcm_return = 0
   ENDIF
   RETURN(dcm_return)
 END ;Subroutine
 SUBROUTINE drrm_check_freeze(dcf_env_id)
   DECLARE dcf_ret_val = i2 WITH protect, noconstant(0)
   DECLARE dcf_freeze_ind = i2 WITH protect, noconstant(0)
   DECLARE dcf_ovr_ind = i2 WITH protect, noconstant(0)
   DECLARE dcf_mig_domain = vc WITH protect, constant("DM2_MIG_STATUS_MARKER")
   DECLARE dcf_ovr_domain = vc WITH protect, constant("RDDS MIGRATION OVERRIDE")
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_name="SCHEMA_FREEZE"
     AND di.info_domain IN (dcf_mig_domain, dcf_ovr_domain)
    DETAIL
     IF (di.info_domain=dcf_mig_domain)
      dcf_freeze_ind = 1
     ELSEIF (di.info_domain=dcf_ovr_domain
      AND di.info_number=dcf_env_id
      AND di.info_date >= cnvtdatetime(curdate,curtime3))
      dcf_ovr_ind = 1
     ENDIF
    FOOT REPORT
     IF (dcf_freeze_ind=1
      AND dcf_ovr_ind=0)
      dcf_ret_val = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(dcf_ret_val)
 END ;Subroutine
 DECLARE drwa_query_file = vc WITH protect, noconstant(" ")
 DECLARE drwa_oe_ind = i4 WITH protect, noconstant(0)
 IF (check_logfile("dm_wrp_audit",".log","DM_RMC_WRP_AUDIT_LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_wrp
 ENDIF
 SET dm_err->eproc = "Starting dm_rmc_wrp_audit"
 IF (((reflect(parameter(1,0)) != "C*") OR (reflect(parameter(2,0)) != "C*")) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Expected syntax: dm_rmc_wrp_audit '<QUERY_FILE_NAME>', '<AUDIT_FILE_NAME>' go"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_wrp
 ELSE
  SET drwa_query_file = trim( $1,3)
  SET dra_audit->file_name = trim( $2,3)
  SET dra_audit->limit_ctxt = 0
 ENDIF
 IF (drrm_check_mig(1,"") > 0)
  SET dm_err->eproc = "Checking for migration status."
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("It has been detected that a database migration is in progress.  ",
   "There is an RDDS project strategy that allows for audits to run during a migration, but it requires an acknowledgement ",
   "of the strategy through DM_MERGE_DOMAIN_ADM.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_wrp
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_wrp
 ENDIF
 CALL dgi_get_global_info(drgi_global)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_wrp
 ENDIF
 SET drwa_oe_ind = check_open_event(drgi_global->target_id,0.0)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_wrp
 ENDIF
 IF (drwa_oe_ind IN (0, 2))
  SET dm_err->emsg =
  "There is currently not an open event in this environment.  Audit cannot be run without an open event."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_wrp
 ENDIF
 IF (findstring(".",dra_audit->file_name)=0)
  SET dra_audit->file_name = cnvtlower(concat(dra_audit->file_name,".xml"))
 ELSEIF (substring(findstring(".",dra_audit->file_name),size(dra_audit->file_name),dra_audit->
  file_name) != ".xml")
  SET dra_audit->file_name = cnvtlower(concat(substring(1,(findstring(".",dra_audit->file_name) - 1),
     dra_audit->file_name),".xml"))
 ENDIF
 SET dra_audit->src_env_id = drgi_global->source_id
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name IN ("V_RDDS_AUDIT_DMT", "V_RDDS_AUDIT_XLAT")
   AND uo.status="VALID"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_wrp
 ENDIF
 IF (curqual < 2)
  EXECUTE dm_rmc_create_audit_views
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_wrp
  ENDIF
 ENDIF
 EXECUTE dm_rmc_query_parser drwa_query_file
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_wrp
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(drqp_reply)
 ENDIF
 SET dra_audit->tab_cnt = drqp_reply->tab_cnt
 SET stat = alterlist(dra_audit->tab_qual,dra_audit->tab_cnt)
 FOR (drwa_cnt = 1 TO drqp_reply->tab_cnt)
   SET dra_audit->tab_qual[drwa_cnt].table_name = drqp_reply->tab_qual[drwa_cnt].table_name
 ENDFOR
 EXECUTE dm_rmc_sltn_audit
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_wrp
 ENDIF
#exit_wrp
END GO
