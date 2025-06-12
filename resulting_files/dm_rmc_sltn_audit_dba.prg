CREATE PROGRAM dm_rmc_sltn_audit:dba
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
 DECLARE drcm_get_imp_file(dgf_name=vc,dgf_file=vc,dgf_xtn=vc) = vc
 DECLARE drcm_check_context(dcc_ctxt_name=vc,dcc_null_allowed_ind=i2) = i2
 DECLARE drcm_file_complete(dfc_name=vc,dfc_files=vc(ref),dvc_type=vc,dfc_error_ind=i2) = null
 DECLARE check_error_gui(ceg_proc=vc,ceg_menu_screen=vc,ceg_env_name=vc,ceg_env_id=f8) = i4
 DECLARE drcm_dbase_connect(ddc_password=vc(ref),ddc_sid=vc(ref)) = i4
 DECLARE drcm_retry_connect(retry_reason=vc) = i4
 DECLARE drcm_check_user(null) = i2
 IF ((validate(drcm_files->cnt,- (2))=- (2)))
  FREE RECORD drcm_files
  RECORD drcm_files(
    1 cnt = i4
    1 qual[*]
      2 file_name = vc
  )
 ENDIF
 SUBROUTINE drcm_get_imp_file(dgf_name,dgf_file,dgf_xtn)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgf_file_name = vc WITH protect, noconstant("")
   DECLARE dgf_full_file = vc WITH protect, noconstant("")
   DECLARE dgf_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgf_valid_ind = i2 WITH protect, noconstant(1)
   DECLARE dgf_title = vc WITH protect, noconstant("")
   SET dgf_title = concat("*** ",dgf_name," ***")
   WHILE (dgf_done_ind=0)
     SET dgf_valid_ind = 1
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgf_name,
       " to be imported from (0 to exit): "))
     CALL text(9,3,concat("Example: myfilename",dgf_xtn))
     CALL text(10,3,concat("NOTE: File must be located in CCLUSERDIR "))
     SET accept = nopatcheck
     CALL accept(7,3,"P(30);CU",value(dgf_file))
     SET accept = patcheck
     SET dgf_file_name = curaccept
     SET dgf_file_name = cnvtlower(dgf_file_name)
     IF (dgf_file_name="0")
      RETURN("0")
     ENDIF
     IF (findstring(".",dgf_file_name)=0)
      SET dgf_file_name = concat(dgf_file_name,dgf_xtn)
     ELSEIF (substring(findstring(".",dgf_file_name),((size(dgf_file_name,1) - findstring(".",
       dgf_file_name))+ 1),dgf_file_name) != dgf_xtn)
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgf_xtn))
      CALL pause(3)
      SET dgf_valid_ind = 0
     ENDIF
     IF (size(dgf_file_name,1) >= 31)
      SET dgf_valid_ind = 0
     ENDIF
     IF (dgf_valid_ind=1)
      SET dgf_full_file = concat(trim(logical("CCLUSERDIR")),"/",dgf_file_name)
      IF (findfile(value(dgf_full_file))=0)
       SET message = window
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,4,132)
       CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
       CALL text(6,3,concat(dgf_file_name," could not be found in CCLLUSERDIR."))
       CALL text(7,3,"Please ensure file is located in CCLUSERDIR")
       CALL text(10,3,"Press enter to continue.")
       CALL accept(10,28,"P;E"," ")
      ELSE
       SET dgf_done_ind = 1
      ENDIF
      SET dgf_file_name = dgf_full_file
     ENDIF
   ENDWHILE
   RETURN(dgf_file_name)
 END ;Subroutine
 SUBROUTINE drcm_check_context(dcc_ctxt_name,dcc_null_allowed_ind)
   DECLARE dcc_valid_ind = i2 WITH protect, noconstant(0)
   IF (size(trim(dcc_ctxt_name),1) <= 24
    AND dcc_ctxt_name != "ALL"
    AND findstring(":",dcc_ctxt_name)=0
    AND size(trim(dcc_ctxt_name),1) > 0
    AND ((dcc_ctxt_name != "NULL"
    AND dcc_null_allowed_ind=0) OR (dcc_ctxt_name="NULL"
    AND dcc_null_allowed_ind=1)) )
    SET dcc_valid_ind = 1
   ELSE
    SET dcc_valid_ind = 0
   ENDIF
   RETURN(dcc_valid_ind)
 END ;Subroutine
 SUBROUTINE drcm_file_complete(dfc_name,dfc_files,dfc_type,dfc_num,dfc_error_ind,dfc_env_name,
  dfc_env_id)
   DECLARE dfc_title = vc WITH protect, noconstant("")
   DECLARE dfc_pos = i4 WITH protect, noconstant(0)
   DECLARE dfc_loop = i4 WITH protect, noconstant(0)
   DECLARE dfc_line = i4 WITH protect, noconstant(11)
   SET dfc_title = concat("*** ",dfc_name," ***")
   IF (dfc_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(4,75,"ENVIRONMENT ID:")
    CALL text(4,20,"ENVIRONMENT NAME:")
    CALL text(4,95,cnvtstring(dfc_env_id))
    CALL text(4,40,dfc_env_name)
    CALL text(7,3,concat(dfc_type," complete!"))
    IF (dfc_type="Export")
     CALL text(8,3,concat(trim(cnvtstring(dfc_num))," rows were exported"))
    ENDIF
    CALL text(9,3,
     "For optimal viewing, the following file(s) needs to be moved from CCLUSERDIR to a PC:")
    CALL text(10,3,"-----------------------------")
    FOR (dfc_loop = 1 TO dfc_files->cnt)
     CALL text(dfc_line,3,dfc_files->qual[dfc_loop].file_name)
     SET dfc_line = (dfc_line+ 1)
    ENDFOR
    CALL text(dfc_line,3,"-----------------------------")
    CALL text((dfc_line+ 2),3,"Press enter to return:")
    CALL accept((dfc_line+ 2),26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(7,3,concat(dfc_type," was not successful.  The following error occurred!"))
    SET dfc_pos = drdc_wrap_menu_lines(dm_err->emsg,8,3,"   ",0,
     120)
    CALL text((dfc_pos+ 1),3,"Press enter to return:")
    CALL accept((dfc_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE check_error_gui(ceg_proc,ceg_menu_screen,ceg_env_name,ceg_env_id)
   DECLARE ceg_error = i4 WITH protect, noconstant(0)
   DECLARE ceg_size = i4 WITH protect, noconstant(0)
   SET ceg_error = check_error(ceg_proc)
   IF (ceg_error != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,7,132)
    CALL text(3,floor(((66 - 5) - (size(ceg_menu_screen)/ 2))),concat("***  ",ceg_menu_screen,"  ***"
      ))
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,ceg_env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(ceg_env_id))
    SET ceg_size = size(dm_err->emsg)
    CALL text(9,3,trim(substring(1,125,dm_err->emsg)))
    IF (ceg_size > 125)
     CALL text(10,3,trim(substring(126,125,dm_err->emsg)))
    ENDIF
    CALL text(12,3,"Press ENTER to continue")
    CALL accept(12,28,"P;E"," ")
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE drcm_dbase_connect(ddc_password,ddc_sid)
   DECLARE dc_retry_ans = i2 WITH protect, noconstant(0)
   DECLARE dc_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_con_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_attempt_connection = i2 WITH protect, noconstant(0)
   DECLARE dc_ind = i2 WITH protect, noconstant(0)
   DECLARE dc_db_tab = vc WITH protect, noconstant(" ")
   SET dc_ind = dm2_get_rdbms_version(null)
   IF (dc_ind=0)
    RETURN(- (1))
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 12))
    SET dc_db_tab = "V$PDBS"
   ELSE
    SET dc_db_tab = "V$DATABASE"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dc_db_tab) db)
    DETAIL
     dc_db_name = db.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Get current database name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   WHILE (dc_attempt_connection=0)
     SET dm2_install_schema->dbase_name = dc_db_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = ""
     SET dm2_install_schema->connect_str = ""
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg="User quit process*"))
       SET retry_ans = drcm_retry_connect("Q")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       RETURN(- (1))
      ENDIF
     ELSE
      SET ddc_password = dm2_install_schema->p_word
      SET ddc_sid = dm2_install_schema->connect_str
      SELECT INTO "nl:"
       FROM (parser(dc_db_tab) db)
       DETAIL
        dc_con_db_name = db.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = "Get current database name"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (dc_db_name != dc_con_db_name)
       SET retry_ans = drcm_retry_connect("D")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       SET dc_attempt_connection = 1
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drcm_retry_connect(retry_reason)
   CALL clear(1,1)
   SET width = 132
   IF (retry_reason="D")
    CALL text(11,3,
     "   Database connect information provided for WRONG database.  Movers cannot be started.")
    CALL text(13,3,concat("     Menu started in database ",dc_db_name))
    CALL text(14,3,concat("     Connect information provided for database ",dc_con_db_name))
   ELSE
    CALL text(11,3,"   Unable to make database connection")
    CALL text(12,21,"   or")
    CALL text(13,3,"   Database connect information provided is incorrect.")
   ENDIF
   CALL text(20,3,"   Would you like to retry database connection? (Y/N)")
   CALL accept(20,59,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    RETURN(1)
   ELSE
    RETURN(2)
    CALL clear(1,1)
    SET width = 132
    CALL text(11,3,"   Please EXIT out of this CCL session and start a new one")
    CALL text(20,20,"Press ENTER to continue")
    CALL accept(20,60,"P;E"," ")
    SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
    CALL disp_msg(dm_err->err_msg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(2)
   ENDIF
 END ;Subroutine
 SUBROUTINE drcm_check_user(null)
   DECLARE dcu_ret = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND cnvtupper(p.username) IN ("SYSTEM", "SYSTEMOE", "CERNER")
    DETAIL
     dcu_ret = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(- (1))
   ENDIF
   RETURN(dcu_ret)
 END ;Subroutine
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 IF (validate(tmc_md_info)=0)
  FREE RECORD tmc_md_info
  RECORD tmc_md_info(
    1 tbl_cnt = i4
    1 tbl_qual[*]
      2 table_name = vc
      2 r_table_name = vc
      2 r_exists_ind = i2
      2 mergeable_ind = i2
      2 reference_ind = i2
      2 version_ind = i2
      2 version_type = vc
      2 merge_ui_query = vc
      2 merge_ui_query_ni = i2
      2 suffix = vc
      2 merge_delete_ind = i2
      2 skip_seqmatch_ind = i2
      2 insert_only_ind = i2
      2 update_only_ind = i2
      2 active_ind_ind = i2
      2 effective_col_ind = i2
      2 beg_col_name = vc
      2 end_col_name = vc
      2 lob_process_type = vc
      2 check_dual_build_ind = i2
      2 cur_state_flag = i4
      2 pre_scan_ind = i2
      2 cs_parent_cnt = i4
      2 cs_parent_tab_col = vc
      2 cs_parent_qual[*]
        3 cs_parent_table = vc
      2 pk_where_hash = f8
      2 del_pk_where_hash = f8
      2 ptam_match_hash = f8
      2 overrule_nomv06_ind = i2
      2 root_col_name = vc
      2 multi_col_pk_ind = i2
      2 filter_string = vc
      2 circ_cnt = i4
      2 circ_qual[*]
        3 circ_table_name = vc
        3 circ_fk_id = vc
        3 circ_pe_name = vc
        3 self_fk_id = vc
        3 self_pe_name = vc
      2 mean_gather_cnt = i4
      2 col_cnt = i4
      2 col_qual[*]
        3 column_name = vc
        3 internal_column_id = i4
        3 unique_ident_ind = i2
        3 exception_flg = i4
        3 constant_value = vc
        3 parent_entity_col = vc
        3 sequence_name = vc
        3 root_entity_name = vc
        3 root_entity_attr = vc
        3 merge_delete_ind = i2
        3 data_type = vc
        3 data_length = i4
        3 db_data_type = vc
        3 db_data_length = i4
        3 src_db_data_type = vc
        3 binary_long_ind = i2
        3 pk_ind = i2
        3 code_set = i4
        3 base62_re_name = vc
        3 nullable = c1
        3 idcd_ind = i2
        3 defining_attribute_ind = i2
        3 version_nbr_child_ind = i2
        3 parent_table = vc
        3 parent_pk_col = vc
        3 parent_vers_col = vc
        3 child_fk_col = vc
        3 meaningful_ind = i2
        3 meaningful_pos = i4
        3 defining_col_ind = i2
        3 relevant_ind = i2
        3 matching_ind = i2
        3 support_ind = i2
        3 pe_name_audit_cnt = i4
        3 pe_name_audit_qual[*]
          4 pe_name_value = vc
        3 execution_flag = i4
        3 object_name = vc
        3 masked_object_name = vc
        3 ccl_data_type = vc
        3 parm_cnt = i4
        3 parm_list[*]
          4 column_name = vc
        3 pk_required_ind = i2
        3 data_default = vc
        3 in_src_ind = i2
        3 xlat_ind = i2
        3 audit_flag = i4
  )
 ENDIF
 DECLARE tmc_get_md(tgm_table_name=vc) = null
 DECLARE drm_check_rem_cols(dcrc_tab_name=vc,dcrc_db_link=vc) = null
 DECLARE drm_md_wrp(dmw_table_name=vc,dmw_db_link=vc) = null
 SUBROUTINE tmc_get_md(tgm_table_name)
   DECLARE tgm_num = i4 WITH protect, noconstant(0)
   DECLARE tgm_cnt = i4 WITH protect, noconstant(0)
   DECLARE tgm_idx = i4 WITH protect, noconstant(0)
   DECLARE tgm_tbl_pos = i4 WITH protect, noconstant(0)
   DECLARE tgm_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE tgm_temp_pos2 = i4 WITH protect, noconstant(0)
   DECLARE tgm_pk_cnt = i4 WITH protect, noconstant(0)
   DECLARE tgm_match_ind = i2 WITH protect, noconstant(0)
   DECLARE tgm_relevant_ind = i2 WITH protect, noconstant(0)
   DECLARE tgm_support_ind = i2 WITH protect, noconstant(0)
   FREE RECORD tgm_pattern
   RECORD tgm_pattern(
     1 pat_cnt = i4
     1 pat_qual[*]
       2 pattern = vc
   )
   SET dm_err->eproc = "Starting TMC_GET_MD subroutine"
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   DECLARE get_r_tab_name(i_table_name=vc) = c30 WITH sql = "RDDS_META_DATA.GET_R_TABLE_NAME",
   parameter
   DECLARE get_mergeable_ind(i_table_name=vc) = i2 WITH sql = "RDDS_META_DATA.GET_MERGEABLE_IND",
   parameter
   DECLARE get_reference_ind(i_table_name=vc) = i2 WITH sql = "RDDS_META_DATA.GET_REFERENCE_IND",
   parameter
   DECLARE get_version_ind(i_table_name=vc) = i2 WITH sql = "RDDS_META_DATA.GET_VERSION_IND",
   parameter
   DECLARE get_version_type(i_table_name=vc) = c10 WITH sql = "RDDS_META_DATA.GET_VERSION_TYPE",
   parameter
   DECLARE get_merge_ui_query(i_table_name=vc) = c255 WITH sql = "RDDS_META_DATA.GET_MERGE_UI_QUERY",
   parameter
   DECLARE get_merge_ui_query_ni(i_table_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_MERGE_UI_QUERY_NI", parameter
   DECLARE get_suffix(i_table_name=vc) = c4 WITH sql = "RDDS_META_DATA.GET_SUFFIX", parameter
   DECLARE get_merge_delete_ind(i_table_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_MERGE_DELETE_IND", parameter
   DECLARE get_skip_seqmatch_ind(i_table_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_SKIP_SEQMATCH_IND", parameter
   DECLARE get_insert_only_ind(i_table_name=vc) = i2 WITH sql = "RDDS_META_DATA.GET_INSERT_ONLY_IND",
   parameter
   DECLARE get_update_only_ind(i_table_name=vc) = i2 WITH sql = "RDDS_META_DATA.GET_UPDATE_ONLY_IND",
   parameter
   DECLARE get_active_ind_ind(i_table_name=vc) = i2 WITH sql = "RDDS_META_DATA.GET_ACTIVE_IND_IND",
   parameter
   DECLARE get_effective_col_ind(i_table_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_EFFECTIVE_COL_IND", parameter
   DECLARE get_beg_col_name(i_table_name=vc) = c30 WITH sql = "RDDS_META_DATA.GET_BEG_COL_NAME",
   parameter
   DECLARE get_end_col_name(i_table_name=vc) = c30 WITH sql = "RDDS_META_DATA.GET_END_COL_NAME",
   parameter
   DECLARE get_check_dual_build_ind(i_table_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_CHECK_DUAL_BUILD_IND", parameter
   DECLARE get_cur_state_flag(i_table_name=vc) = i4 WITH sql = "RDDS_META_DATA.GET_CUR_STATE_FLAG",
   parameter
   DECLARE get_pk_where_hash(i_table_name=vc) = f8 WITH sql = "RDDS_META_DATA.GET_PK_WHERE_HASH",
   parameter
   DECLARE get_del_pk_where_hash(i_table_name=vc) = f8 WITH sql =
   "RDDS_META_DATA.GET_DEL_PK_WHERE_HASH", parameter
   DECLARE get_ptam_match_hash(i_table_name=vc) = f8 WITH sql = "RDDS_META_DATA.GET_PTAM_MATCH_HASH",
   parameter
   DECLARE get_overrule_nomv06_ind(i_table_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_OVERRULE_NOMV06_IND", parameter
   DECLARE get_root_col_name(i_table_name=vc) = c30 WITH sql = "RDDS_META_DATA.GET_ROOT_COL_NAME",
   parameter
   DECLARE get_unique_ident_ind(i_table_name=vc,i_column_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_UNIQUE_IDENT_IND", parameter
   DECLARE get_exp_flg(i_table_name=vc,i_column_name=vc) = i4 WITH sql =
   "RDDS_META_DATA.GET_EXCPTN_FLAG", parameter
   DECLARE get_const_val(i_table_name=vc,i_column_name=vc) = c255 WITH sql =
   "RDDS_META_DATA.GET_CONSTANT_VALUE", parameter
   DECLARE get_pe_col(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_PARENT_ENTITY_COL", parameter
   DECLARE get_seq_name(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_SEQUENCE_NAME", parameter
   DECLARE get_re_name(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_ROOT_ENTITY_NAME", parameter
   DECLARE get_re_attr(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_ROOT_ENTITY_ATTR", parameter
   DECLARE get_col_md_ind(i_table_name=vc,i_column_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_COL_MERGE_DELETE_IND", parameter
   DECLARE get_data_type(i_table_name=vc,i_column_name=vc) = c10 WITH sql =
   "RDDS_META_DATA.GET_DATA_TYPE", parameter
   DECLARE get_data_length(i_table_name=vc,i_column_name=vc) = i4 WITH sql =
   "RDDS_META_DATA.GET_DATA_LENGTH", parameter
   DECLARE get_bin_long_ind(i_table_name=vc,i_column_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_BINARY_LONG_IND", parameter
   DECLARE get_pk_ind(i_table_name=vc,i_column_name=vc) = i2 WITH sql = "RDDS_META_DATA.GET_PK_IND",
   parameter
   DECLARE get_code_set(i_table_name=vc,i_column_name=vc) = i4 WITH sql =
   "RDDS_META_DATA.GET_CODE_SET", parameter
   DECLARE get_nullable(i_table_name=vc,i_column_name=vc) = c1 WITH sql =
   "RDDS_META_DATA.GET_NULLABLE", parameter
   DECLARE get_idcd_ind(i_table_name=vc,i_column_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_IDCD_IND", parameter
   DECLARE get_def_att_ind(i_table_name=vc,i_column_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_DEFINING_ATTRIBUTE_IND", parameter
   DECLARE get_vers_nbr_chld_ind(i_table_name=vc,i_column_name=vc) = i2 WITH sql =
   "RDDS_META_DATA.GET_VERSION_NBR_CHILD_IND", parameter
   DECLARE get_vers_par_tbl(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_VERS_PARENT_TABLE", parameter
   DECLARE get_vers_par_pk_col(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_VERS_PARENT_PK_COL", parameter
   DECLARE get_vers_par_vers_col(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_VERS_PARENT_VERS_COL", parameter
   DECLARE get_vers_chld_fk_col(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_VERS_CHILD_FK_COL", parameter
   DECLARE get_execution_flag(i_table_name=vc,i_column_name=vc) = i4 WITH sql =
   "RDDS_META_DATA.GET_EXECUTION_FLAG", parameter
   DECLARE get_object_name(i_table_name=vc,i_column_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_OBJECT_NAME", parameter
   DECLARE get_masked_object_name(i_table_name=vc,i_column_name=vc) = c50 WITH sql =
   "RDDS_META_DATA.GET_MASKED_OBJECT_NAME", parameter
   DECLARE get_internal_column_id(i_table_name=vc,i_column_name=vc) = i4 WITH sql =
   "RDDS_META_DATA.GET_INTERNAL_COLUMN_ID", parameter
   DECLARE get_base62_info(i_table_name=vc,i_columns_name=vc) = c30 WITH sql =
   "RDDS_META_DATA.GET_BASE62_INFO", parameter
   SET tgm_num = locateval(tgm_num,1,tmc_md_info->tbl_cnt,tgm_table_name,tmc_md_info->tbl_qual[
    tgm_num].table_name)
   IF (tgm_num > 0)
    RETURN
   ENDIF
   SET dm_err->eproc = "Loading meta-data into package"
   CALL parser(concat("RDB ASIS(^BEGIN RDDS_META_DATA.LOAD_TABLE_INFO('",tgm_table_name,
     "'); END; ^) go"),1)
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET dm_err->eproc = concat("Gathering meta-data for table ",tgm_table_name)
   SELECT INTO "nl:"
    r_tab = get_r_tab_name(tgm_table_name), merge_ind = get_mergeable_ind(tgm_table_name), ref_ind =
    get_reference_ind(tgm_table_name),
    vers_ind = get_version_ind(tgm_table_name), vers_type = get_version_type(tgm_table_name),
    mui_query = get_merge_ui_query(tgm_table_name),
    mui_query_ni = get_merge_ui_query_ni(tgm_table_name), tab_suffix = get_suffix(tgm_table_name),
    md_ind = get_merge_delete_ind(tgm_table_name),
    skip_seqmatch = get_skip_seqmatch_ind(tgm_table_name), ins_only_ind = get_insert_only_ind(
     tgm_table_name), upd_only_ind = get_update_only_ind(tgm_table_name),
    act_ind = get_active_ind_ind(tgm_table_name), eff_col_ind = get_effective_col_ind(tgm_table_name),
    beg_col = get_beg_col_name(tgm_table_name),
    end_col = get_end_col_name(tgm_table_name), check_db_ind = get_check_dual_build_ind(
     tgm_table_name), cs_flag = get_cur_state_flag(tgm_table_name),
    pkw_hash = get_pk_where_hash(tgm_table_name), del_pkw_hash = get_del_pk_where_hash(tgm_table_name
     ), ptam_hash = get_ptam_match_hash(tgm_table_name),
    overrule_ind = get_overrule_nomv06_ind(tgm_table_name), root_col = get_root_col_name(
     tgm_table_name)
    FROM dual
    HEAD REPORT
     tgm_cnt = tmc_md_info->tbl_cnt
    DETAIL
     tgm_cnt = (tgm_cnt+ 1), stat = alterlist(tmc_md_info->tbl_qual,tgm_cnt), tmc_md_info->tbl_qual[
     tgm_cnt].table_name = tgm_table_name,
     tmc_md_info->tbl_qual[tgm_cnt].r_table_name = r_tab, tmc_md_info->tbl_qual[tgm_cnt].
     mergeable_ind = merge_ind, tmc_md_info->tbl_qual[tgm_cnt].reference_ind = ref_ind,
     tmc_md_info->tbl_qual[tgm_cnt].version_ind = vers_ind, tmc_md_info->tbl_qual[tgm_cnt].
     version_type = vers_type, tmc_md_info->tbl_qual[tgm_cnt].merge_ui_query = mui_query,
     tmc_md_info->tbl_qual[tgm_cnt].merge_ui_query_ni = mui_query_ni, tmc_md_info->tbl_qual[tgm_cnt].
     suffix = tab_suffix, tmc_md_info->tbl_qual[tgm_cnt].merge_delete_ind = md_ind,
     tmc_md_info->tbl_qual[tgm_cnt].skip_seqmatch_ind = skip_seqmatch, tmc_md_info->tbl_qual[tgm_cnt]
     .insert_only_ind = ins_only_ind, tmc_md_info->tbl_qual[tgm_cnt].update_only_ind = upd_only_ind,
     tmc_md_info->tbl_qual[tgm_cnt].active_ind_ind = act_ind, tmc_md_info->tbl_qual[tgm_cnt].
     effective_col_ind = eff_col_ind, tmc_md_info->tbl_qual[tgm_cnt].beg_col_name = beg_col,
     tmc_md_info->tbl_qual[tgm_cnt].end_col_name = end_col, tmc_md_info->tbl_qual[tgm_cnt].
     check_dual_build_ind = check_db_ind, tmc_md_info->tbl_qual[tgm_cnt].cur_state_flag = cs_flag,
     tmc_md_info->tbl_qual[tgm_cnt].pk_where_hash = pkw_hash, tmc_md_info->tbl_qual[tgm_cnt].
     del_pk_where_hash = del_pkw_hash, tmc_md_info->tbl_qual[tgm_cnt].ptam_match_hash = ptam_hash,
     tmc_md_info->tbl_qual[tgm_cnt].overrule_nomv06_ind = overrule_ind, tmc_md_info->tbl_qual[tgm_cnt
     ].root_col_name = root_col
    FOOT REPORT
     tmc_md_info->tbl_cnt = tgm_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ELSEIF (daf_is_blank(tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].r_table_name))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Unable to retrieve meta-data for table ",tgm_table_name)
    SET tmc_md_info->tbl_cnt = (tmc_md_info->tbl_cnt - 1)
    SET stat = alterlist(tmc_md_info->tbl_qual,tmc_md_info->tbl_cnt)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    ui_ind = get_unique_ident_ind(tgm_table_name,utc.column_name), exp_flg = get_exp_flg(
     tgm_table_name,utc.column_name), const_val = get_const_val(tgm_table_name,utc.column_name),
    pe_col = get_pe_col(tgm_table_name,utc.column_name), seq_name = get_seq_name(tgm_table_name,utc
     .column_name), re_name = get_re_name(tgm_table_name,utc.column_name),
    re_attr = get_re_attr(tgm_table_name,utc.column_name), col_md_ind = get_col_md_ind(tgm_table_name,
     utc.column_name), datatype = get_data_type(tgm_table_name,utc.column_name),
    datalen = get_data_length(tgm_table_name,utc.column_name), bin_long_ind = get_bin_long_ind(
     tgm_table_name,utc.column_name), pk_ind = get_pk_ind(tgm_table_name,utc.column_name),
    cd_set = get_code_set(tgm_table_name,utc.column_name), v_nullable = get_nullable(tgm_table_name,
     utc.column_name), idcd_ind = get_idcd_ind(tgm_table_name,utc.column_name),
    def_att_ind = get_def_att_ind(tgm_table_name,utc.column_name), vers_nbr_chld_ind =
    get_vers_nbr_chld_ind(tgm_table_name,utc.column_name), vers_par_tbl = get_vers_par_tbl(
     tgm_table_name,utc.column_name),
    vers_par_pk_col = get_vers_par_pk_col(tgm_table_name,utc.column_name), vers_chld_fk_col =
    get_vers_chld_fk_col(tgm_table_name,utc.column_name), exec_flg = get_execution_flag(
     tgm_table_name,utc.column_name),
    mask_name = get_masked_object_name(tgm_table_name,utc.column_name), obj_name = get_object_name(
     tgm_table_name,utc.column_name), int_col_id = get_internal_column_id(tgm_table_name,utc
     .column_name),
    base62_re_name = get_base62_info(tgm_table_name,utc.column_name)
    FROM user_tab_cols utc
    WHERE utc.table_name=tgm_table_name
     AND utc.hidden_column="NO"
     AND utc.virtual_column="NO"
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di
     WHERE di.info_domain="RDDS IGNORE COL LIST:*"
      AND sqlpassthru(" utc.column_name like di.info_name and utc.table_name like di.info_char"))))
    ORDER BY utc.column_name
    HEAD REPORT
     tgm_cnt = 0
    DETAIL
     tgm_cnt = (tgm_cnt+ 1)
     IF (mod(tgm_cnt,10)=1)
      stat = alterlist(tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual,(tgm_cnt+ 9))
     ENDIF
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].internal_column_id = int_col_id,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].column_name = utc.column_name,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].unique_ident_ind = ui_ind,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].exception_flg = exp_flg,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].constant_value = const_val,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].parent_entity_col = pe_col,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].sequence_name = seq_name,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].root_entity_name = re_name,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].root_entity_attr = re_attr,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].merge_delete_ind = col_md_ind,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].db_data_type = datatype,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].db_data_length = datalen,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].binary_long_ind = bin_long_ind,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].pk_ind = pk_ind, tmc_md_info->
     tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].code_set = cd_set,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].nullable = v_nullable, tmc_md_info
     ->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].idcd_ind = idcd_ind, tmc_md_info->tbl_qual[
     tmc_md_info->tbl_cnt].col_qual[tgm_cnt].defining_attribute_ind = def_att_ind,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].version_nbr_child_ind =
     vers_nbr_chld_ind, tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].parent_table =
     vers_par_tbl, tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].parent_pk_col =
     vers_par_pk_col,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].child_fk_col = vers_chld_fk_col,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].execution_flag = exec_flg,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].masked_object_name = mask_name,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].object_name = obj_name,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].data_default = utc.data_default,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].defining_col_ind = 1,
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_cnt].base62_re_name = base62_re_name
    FOOT REPORT
     tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_cnt = tgm_cnt, stat = alterlist(tmc_md_info->
      tbl_qual[tmc_md_info->tbl_cnt].col_qual,tgm_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET tgm_tbl_pos = tmc_md_info->tbl_cnt
   IF (daf_is_blank(tmc_md_info->tbl_qual[tgm_tbl_pos].root_col_name))
    FOR (tgm_idx = 1 TO tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
      IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].root_entity_name=tmc_md_info->
      tbl_qual[tgm_tbl_pos].table_name)
       AND (tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].root_entity_attr=tmc_md_info->
      tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].column_name))
       SET tmc_md_info->tbl_qual[tgm_tbl_pos].root_col_name = tmc_md_info->tbl_qual[tgm_tbl_pos].
       col_qual[tgm_idx].column_name
       SET tgm_idx = tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM dm_refchg_filter_test d
    WHERE d.table_name=tgm_table_name
     AND d.mover_string != ""
     AND d.mover_string IS NOT null
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
     tmc_md_info->tbl_qual[tgm_tbl_pos].filter_string = d.mover_string
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS MD PRE-SCAN TABLE"
     AND d.info_name=tgm_table_name
    DETAIL
     tmc_md_info->tbl_qual[tgm_tbl_pos].pre_scan_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].cur_state_flag > 0))
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CURRENT STATE TABLES"
      AND d.info_name=patstring(concat(tgm_table_name,"*"))
     HEAD REPORT
      tgm_cnt = 0
     DETAIL
      tgm_cnt = (tgm_cnt+ 1), stat = alterlist(tmc_md_info->tbl_qual[tgm_tbl_pos].cs_parent_qual,
       tgm_cnt), tgm_temp_pos = findstring(":",d.info_name),
      tgm_temp_pos2 = findstring(":",d.info_name,(tgm_temp_pos+ 1))
      IF (tgm_temp_pos2 > 0)
       tmc_md_info->tbl_qual[tgm_tbl_pos].cs_parent_qual[tgm_cnt].cs_parent_table = substring((
        tgm_temp_pos+ 1),(tgm_temp_pos2 - tgm_temp_pos),d.info_name)
      ELSE
       tmc_md_info->tbl_qual[tgm_tbl_pos].cs_parent_qual[tgm_cnt].cs_parent_table = substring((
        tgm_temp_pos+ 1),(size(trim(d.info_name),1) - tgm_temp_pos),d.info_name)
      ENDIF
      tmc_md_info->tbl_qual[tgm_tbl_pos].cs_parent_tab_col = d.info_char
     FOOT REPORT
      tmc_md_info->tbl_qual[tgm_tbl_pos].cs_parent_cnt = tgm_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF (daf_is_blank(tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[1].data_type))
    SELECT INTO "NL:"
     build(l.type,l.len), l.*, utc.data_type
     FROM dtableattr a,
      dtableattrl l,
      user_tab_cols utc
     PLAN (a
      WHERE (a.table_name=tmc_md_info->tbl_qual[tgm_tbl_pos].table_name))
      JOIN (l
      WHERE l.structtype="F"
       AND btest(l.stat,11)=0)
      JOIN (utc
      WHERE utc.table_name=a.table_name
       AND utc.column_name=l.attr_name
       AND utc.hidden_column="NO"
       AND utc.virtual_column="NO"
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_info di
       WHERE di.info_domain="RDDS IGNORE COL LIST:*"
        AND sqlpassthru("utc.column_name like di.info_name and utc.table_name like di.info_char")))))
     DETAIL
      tgm_cnt = locateval(tgm_cnt,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,l.attr_name,
       tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].column_name), tmc_md_info->tbl_qual[
      tgm_tbl_pos].col_qual[tgm_cnt].data_length = l.len
      IF (l.type="F")
       tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].data_type = "F8"
      ELSEIF (l.type="I")
       tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].data_type = "I4"
      ELSEIF (l.type="C")
       IF (utc.data_type="CHAR")
        tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].data_type = build(l.type,l.len)
       ELSE
        tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].data_type = "VC"
       ENDIF
      ELSEIF (l.type="Q")
       tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].data_type = "DQ8"
      ENDIF
      IF (daf_is_not_blank(tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].masked_object_name))
       IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].data_type != "VC"))
        tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].ccl_data_type = tmc_md_info->tbl_qual[
        tgm_tbl_pos].col_qual[tgm_cnt].data_type
       ELSE
        tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_cnt].ccl_data_type = build(l.type,l.len)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables utc
    WHERE (utc.table_name=tmc_md_info->tbl_qual[tgm_tbl_pos].r_table_name)
    DETAIL
     tmc_md_info->tbl_qual[tgm_tbl_pos].r_exists_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   FOR (tgm_idx = 1 TO tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
     IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].execution_flag > 0))
      SELECT INTO "nl:"
       FROM dm_refchg_sql_obj_parm d
       WHERE (d.object_name=tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].masked_object_name)
        AND d.active_ind=1
       ORDER BY d.parm_nbr
       HEAD REPORT
        tgm_cnt = 0
       DETAIL
        tgm_cnt = (tgm_cnt+ 1), stat = alterlist(tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx]
         .parm_list,tgm_cnt), tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].parm_list[tgm_cnt]
        .column_name = d.column_name
       FOOT REPORT
        tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].parm_cnt = tgm_cnt
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) > 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
      IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].column_name=tmc_md_info->tbl_qual[
      tgm_tbl_pos].root_col_name)
       AND (tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].execution_flag=3))
       FOR (tgm_num = 1 TO tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].parm_cnt)
         IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].column_name != tmc_md_info->
         tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].parm_list[tgm_num].column_name))
          SET tgm_temp_pos = locateval(tgm_temp_pos,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,
           tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].parm_list[tgm_num].column_name,
           tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].column_name)
          SET tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].pk_required_ind = 1
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain=patstring(concat("RDDS CIRCULAR:",tmc_md_info->tbl_qual[tgm_tbl_pos].
      table_name,":*"))
    DETAIL
     tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt = (tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt+ 1),
     stat = alterlist(tmc_md_info->tbl_qual[tgm_tbl_pos].circ_qual,tmc_md_info->tbl_qual[tgm_tbl_pos]
      .circ_cnt), tmc_md_info->tbl_qual[tgm_tbl_pos].circ_qual[tmc_md_info->tbl_qual[tgm_tbl_pos].
     circ_cnt].circ_table_name = substring(1,(findstring(":",di.info_name,1,0) - 1),di.info_name),
     tmc_md_info->tbl_qual[tgm_tbl_pos].circ_qual[tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt].
     circ_fk_id = substring((findstring(":",di.info_name,1,0)+ 1),30,di.info_name), tmc_md_info->
     tbl_qual[tgm_tbl_pos].circ_qual[tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt].circ_pe_name = di
     .info_char
     IF (di.info_number=2)
      tmc_md_info->tbl_qual[tgm_tbl_pos].circ_qual[tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt].
      circ_pe_name = substring((findstring(":",di.info_domain,1,1)+ 1),30,di.info_name), tgm_idx =
      locateval(tgm_idx,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,tmc_md_info->tbl_qual[
       tgm_tbl_pos].circ_qual[tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt].circ_pe_name,tmc_md_info->
       tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].parent_entity_col), tmc_md_info->tbl_qual[tgm_tbl_pos]
      .circ_qual[tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt].circ_fk_id = tmc_md_info->tbl_qual[
      tgm_tbl_pos].col_qual[tgm_idx].column_name
     ELSE
      tmc_md_info->tbl_qual[tgm_tbl_pos].circ_qual[tmc_md_info->tbl_qual[tgm_tbl_pos].circ_cnt].
      circ_fk_id = substring((findstring(":",di.info_domain,1,1)+ 1),30,di.info_name)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM dm_refchg_attribute d
    WHERE (d.table_name=tmc_md_info->tbl_qual[tgm_tbl_pos].table_name)
     AND expand(tgm_num,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,d.column_name,tmc_md_info->
     tbl_qual[tgm_tbl_pos].col_qual[tgm_num].column_name)
     AND d.attribute_name IN ("MEANINGFUL_IND", "MEANINGFUL_POS")
    DETAIL
     tgm_temp_pos = locateval(tgm_num,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,d.column_name,
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_num].column_name)
     IF (d.attribute_name="MEANINGFUL_IND")
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].meaningful_ind = d.attribute_value
      IF (d.attribute_value=1
       AND (((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].parent_entity_col > " ")) OR
      ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].root_entity_name > " ")
       AND (((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].root_entity_attr !=
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].column_name)) OR ((tmc_md_info->
      tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].root_entity_name != tmc_md_info->tbl_qual[
      tgm_tbl_pos].table_name))) )) )
       tmc_md_info->tbl_qual[tgm_tbl_pos].mean_gather_cnt = (tmc_md_info->tbl_qual[tgm_tbl_pos].
       mean_gather_cnt+ 1)
      ENDIF
     ELSE
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].meaningful_pos = d.attribute_value
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (curqual=0)
    SET tgm_cnt = 0
    FOR (tgm_idx = 1 TO tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
      IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].unique_ident_ind=1))
       SET tgm_cnt = (tgm_cnt+ 1)
       SET tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].meaningful_ind = 1
       SET tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].meaningful_pos = tgm_cnt
       IF (((daf_is_not_blank(tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].parent_entity_col)
       ) OR (daf_is_not_blank(tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].root_entity_name)
        AND (((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].root_entity_attr != tmc_md_info->
       tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].column_name)) OR ((tmc_md_info->tbl_qual[tgm_tbl_pos].
       col_qual[tgm_idx].root_entity_name != tmc_md_info->tbl_qual[tgm_tbl_pos].table_name))) )) )
        SET tmc_md_info->tbl_qual[tgm_tbl_pos].mean_gather_cnt = (tmc_md_info->tbl_qual[tgm_tbl_pos].
        mean_gather_cnt+ 1)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS NON DEFINING PATTERN"
    DETAIL
     tgm_pattern->pat_cnt = (tgm_pattern->pat_cnt+ 1), stat = alterlist(tgm_pattern->pat_qual,
      tgm_pattern->pat_cnt), tgm_pattern->pat_qual[tgm_pattern->pat_cnt].pattern = d.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   FOR (tgm_idx = 1 TO tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
     FOR (tgm_num = 1 TO tgm_pattern->pat_cnt)
       IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].column_name=patstring(tgm_pattern->
        pat_qual[tgm_num].pattern)))
        SET tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].defining_col_ind = 0
        SET tgm_num = tgm_pattern->pat_cnt
       ENDIF
     ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    FROM dm_refchg_attribute dra
    WHERE (dra.table_name=tmc_md_info->tbl_qual[tgm_tbl_pos].table_name)
     AND expand(tgm_num,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,dra.column_name,tmc_md_info->
     tbl_qual[tgm_tbl_pos].col_qual[tgm_num].column_name)
     AND dra.attribute_name IN ("DEFINING_COL_IND", "NON_DEFINING_COL_IND")
    DETAIL
     tgm_temp_pos = locateval(tgm_num,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,dra.column_name,
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_num].column_name)
     IF (dra.attribute_name="DEFINING_COL_IND")
      tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_temp_pos].defining_col_ind = 1
     ELSEIF (dra.attribute_name="NON_DEFINING_COL_IND")
      tmc_md_info->tbl_qual[tmc_md_info->tbl_cnt].col_qual[tgm_temp_pos].defining_col_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM dm_refchg_attribute d
    WHERE (d.table_name=tmc_md_info->tbl_qual[tgm_tbl_pos].table_name)
     AND expand(tgm_num,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,d.column_name,tmc_md_info->
     tbl_qual[tgm_tbl_pos].col_qual[tgm_num].column_name)
     AND d.attribute_name IN ("RELEVANT_IND", "MATCHING_IND", "SUPPORT_IND", "AUDIT_PE_NAME_TAB")
    ORDER BY d.attribute_char
    DETAIL
     tgm_temp_pos = locateval(tgm_num,1,tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt,d.column_name,
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_num].column_name)
     IF (d.attribute_name="RELEVANT_IND")
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].relevant_ind = d.attribute_value,
      tgm_relevant_ind = 1
     ELSEIF (d.attribute_name="MATCHING_IND")
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].matching_ind = d.attribute_value,
      tgm_match_ind = 1
     ELSEIF (d.attribute_name="SUPPORT_IND")
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].support_ind = d.attribute_value,
      tgm_support_ind = 1
     ELSEIF (d.attribute_name="AUDIT_PE_NAME_TAB")
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].pe_name_audit_cnt = (tmc_md_info->
      tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].pe_name_audit_cnt+ 1), stat = alterlist(
       tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].pe_name_audit_qual,tmc_md_info->
       tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].pe_name_audit_cnt), tgm_idx = tmc_md_info->
      tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].pe_name_audit_cnt,
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_temp_pos].pe_name_audit_qual[tgm_idx].
      pe_name_value = d.attribute_char
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (tgm_match_ind=0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
     PLAN (d
      WHERE (tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].unique_ident_ind=1))
     DETAIL
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].matching_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF (tgm_support_ind=0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
     PLAN (d
      WHERE (tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].unique_ident_ind=1))
     DETAIL
      tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].support_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF (tgm_relevant_ind=0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
     PLAN (d
      WHERE (tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].defining_col_ind=1)
       AND (tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].matching_ind=0))
     DETAIL
      IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].column_name != tmc_md_info->tbl_qual[
      tgm_tbl_pos].root_col_name))
       tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[d.seq].relevant_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   FOR (tgm_idx = 1 TO tmc_md_info->tbl_qual[tgm_tbl_pos].col_cnt)
     IF ((tmc_md_info->tbl_qual[tgm_tbl_pos].col_qual[tgm_idx].pk_ind=1))
      SET tgm_pk_cnt = (tgm_pk_cnt+ 1)
     ENDIF
   ENDFOR
   IF (tgm_pk_cnt > 1)
    SET tmc_md_info->tbl_qual[tgm_tbl_pos].multi_col_pk_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE drm_check_rem_cols(dcrc_tab_name,dcrc_db_link)
   DECLARE dcrc_idx = i4 WITH protect, noconstant(0)
   DECLARE dcrc_col_loc = i4 WITH protect, noconstant(0)
   DECLARE dcrc_tab_loc = i4 WITH protect, noconstant(0)
   SET dcrc_tab_loc = locateval(dcrc_tab_loc,1,tmc_md_info->tbl_cnt,dcrc_tab_name,tmc_md_info->
    tbl_qual[dcrc_tab_loc].table_name)
   SELECT INTO "nl:"
    FROM (parser(concat("user_tab_cols",dcrc_db_link)) utc)
    WHERE (utc.table_name=tmc_md_info->tbl_qual[dcrc_tab_loc].table_name)
     AND expand(dcrc_idx,1,tmc_md_info->tbl_qual[dcrc_tab_loc].col_cnt,utc.column_name,tmc_md_info->
     tbl_qual[dcrc_tab_loc].col_qual[dcrc_idx].column_name)
    DETAIL
     dcrc_col_loc = locateval(dcrc_col_loc,1,tmc_md_info->tbl_qual[dcrc_tab_loc].col_cnt,utc
      .column_name,tmc_md_info->tbl_qual[dcrc_tab_loc].col_qual[dcrc_col_loc].column_name)
     IF (dcrc_col_loc > 0)
      tmc_md_info->tbl_qual[dcrc_tab_loc].col_qual[dcrc_col_loc].in_src_ind = 1, tmc_md_info->
      tbl_qual[dcrc_tab_loc].col_qual[dcrc_col_loc].src_db_data_type = utc.data_type
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE drm_md_wrp(dmw_table_name,dmw_db_link)
   DECLARE dmw_temp_pos = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Starting DRM_MD_WRP subroutine"
   CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
   CALL tmc_get_md(dmw_table_name)
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (daf_is_not_blank(dmw_db_link))
    CALL drm_check_rem_cols(dmw_table_name,dmw_db_link)
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
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
 DECLARE dm_rmc_ins_dcla_row(dridr_log_id=f8,dridr_action=vc,dridr_table=vc,dridr_text=vc) = null
 SUBROUTINE dm_rmc_ins_dcla_row(dridr_log_id,dridr_action,dridr_table,dridr_text)
   DECLARE dridr_seq = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     dridr_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(null)
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = dridr_log_id, dcla.action = dridr_action, dcla.table_name = dridr_table,
     dcla.text = dridr_text, dcla.updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcla.audit_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WHERE dcla.dm_chg_log_audit_id=dridr_seq
    WITH nocounter
   ;end update
   IF (check_error("Logging data to dm_chg_log_audit") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(null)
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = dridr_seq, dcla.log_id = dridr_log_id, dcla.action = dridr_action,
      dcla.table_name = dridr_table, dcla.text = dridr_text, dcla.updt_applctx = cnvtreal(
       currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcla.audit_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error("Logging data to dm_chg_log_audit") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   RETURN(null)
 END ;Subroutine
 IF ((dm_err->debug_flag >= 1))
  SET trace = echoinput
  SET trace = echoinput2
  SET trace = rdbbind
  SET trace = rdbdebug
  SET trace = callecho
  CALL trace(7)
 ENDIF
 DECLARE print_xml_header(sfile=vc,sxslfile=vc,pxh_global=vc(ref)) = i2 WITH protect
 DECLARE print_xml_footer(sfile=vc) = i2 WITH protect
 DECLARE evaluate_pe_name() = c255 WITH protect
 DECLARE print_table_header(pth_file=vc,pth_tab_info=vc(ref),tab_info_loc=i4,pth_md_info=vc(ref),
  md_info_loc=i4) = null
 DECLARE print_xml_body(sfile=vc,pxb_audit_info=vc(ref),pxb_md_info=vc(ref),pxb_md_loc=i4) = null
 FREE RECORD dra_info
 RECORD dra_info(
   1 sample_size = i4
   1 ctxt_ind = i2
   1 ctxts_to_audit = vc
   1 ctxt_null_ind = i2
   1 audit_types[*]
     2 audit_flg = i4
     2 audit_desc = vc
     2 audit_cnt = i4
     2 audit_msg = vc
     2 log_type_cnt = i4
     2 log_types[*]
       3 log_type = vc
       3 cnt = i4
 )
 DECLARE dra_start_date = dq8 WITH protect, noconstant(0.0)
 DECLARE dra_oe_ind = i4 WITH protect, noconstant(0)
 DECLARE dra_tab_loc = i4 WITH protect, noconstant(0)
 DECLARE dra_end_date = dq8 WITH protect, noconstant(0.0)
 DECLARE dra_col_loc = i4 WITH protect, noconstant(0)
 DECLARE dra_col_cnt = i4 WITH protect, noconstant(0)
 DECLARE dra_cnt = i4 WITH protect, noconstant(0)
 IF ((validate(dra_disp_ind,- (5))=- (5)))
  DECLARE dra_disp_ind = i2 WITH protect, noconstant(1)
 ENDIF
 IF (check_logfile("dm_rmc_sltn_audit",".log","DM_RMC_SLTN_AUDIT_LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Starting dm_rdds_audit"
 CALL disp_msg("",dm_err->logfile,0)
 CALL dm_rmc_ins_dcla_row(0.0,"RDDS AUDIT","NONE","Starting Audit and gathering domain info")
 SET dra_start_date = cnvtdatetime(curdate,curtime2)
 IF ((dra_audit->file_name <= " "))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Audit filename not specified"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dra_audit->src_env_id <= 0.0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Source environment_id not specified"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ( NOT ((dra_audit->limit_ctxt IN (0, 1))))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Invalid limit by context_name option specified"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dra_audit->data_subset_ind=1)
  AND (validate(drqp_reply->tab_cnt,- (54))=- (54)))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Data subset option requires dqrp_reply record structure to be filled out"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET drcm_files->cnt = 2
 SET stat = alterlist(drcm_files->qual,drcm_files->cnt)
 SET drcm_files->qual[1].file_name = dra_audit->file_name
 SET drcm_files->qual[2].file_name = replace(dra_audit->file_name,".xml",".xsl")
 SET dm_err->eproc = "Gathering domain information"
 CALL disp_msg("",dm_err->logfile,0)
 CALL dgi_get_global_info(drgi_global)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET stat = print_xml_header(dra_audit->file_name,replace(dra_audit->file_name,".xml",".xsl"),
  drgi_global)
 SET dra_oe_ind = check_open_event(drgi_global->target_id,0.0)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 IF (dra_oe_ind IN (0, 2))
  SET dm_err->emsg =
  "There is currently not an open event in this environment.  Audit cannot be run without an open event."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 IF ((dra_audit->limit_ctxt=1))
  SET dra_info->ctxt_ind = 1
 ENDIF
 CALL dra_gather_audit_info(dra_info)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET table_info->tab_cnt = dra_audit->tab_cnt
 SET stat = alterlist(table_info->tables,dra_audit->tab_cnt)
 IF ((dm_err->debug_flag >= 1))
  CALL echorecord(dra_audit)
 ENDIF
 FOR (dra_cnt = 1 TO dra_audit->tab_cnt)
   CALL dm_rmc_ins_dcla_row(0.0,"RDDS AUDIT",dra_audit->tab_qual[dra_cnt].table_name,concat(
     "Gathering metadata for table: ",dra_audit->tab_qual[dra_cnt].table_name," (",trim(cnvtstring(
       dra_cnt))," of ",
     trim(cnvtstring(dra_audit->tab_cnt))," table(s))"))
   SET table_info->tables[dra_cnt].table_name = dra_audit->tab_qual[dra_cnt].table_name
   SET dm_err->eproc = concat("Gathering metadata for table: ",dra_audit->tab_qual[dra_cnt].
    table_name)
   CALL disp_msg("",dm_err->logfile,0)
   CALL drm_md_wrp(table_info->tables[dra_cnt].table_name,drgi_global->db_link)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_script
   ENDIF
   SET dra_tab_loc = locateval(dra_tab_loc,1,tmc_md_info->tbl_cnt,table_info->tables[dra_cnt].
    table_name,tmc_md_info->tbl_qual[dra_tab_loc].table_name)
   IF (dra_tab_loc > 0)
    CALL dra_addl_tab_info(table_info,dra_cnt,drgi_global,tmc_md_info,dra_tab_loc)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_script
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Unable to find metadata for table ",table_info->tables[dra_cnt].
     table_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   SET stat = print_table_header(dra_audit->file_name,table_info,dra_cnt,tmc_md_info,dra_tab_loc)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_script
   ENDIF
   FOR (dra_col_cnt = 1 TO tmc_md_info->tbl_qual[dra_tab_loc].col_cnt)
     IF ((tmc_md_info->tbl_qual[dra_tab_loc].col_qual[dra_col_cnt].pk_ind=1)
      AND (tmc_md_info->tbl_qual[dra_tab_loc].col_qual[dra_col_cnt].parent_entity_col > " "))
      CALL dra_get_pe_data(table_info,dra_cnt,tmc_md_info->tbl_qual[dra_tab_loc].col_qual[dra_col_cnt
       ].column_name,tmc_md_info->tbl_qual[dra_tab_loc].col_qual[dra_col_cnt].parent_entity_col,
       tmc_md_info,
       dra_tab_loc,dra_col_cnt,drqp_reply,dra_audit)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Creating Audit Global Temp Table"
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm_create_audit_gttd table_info->tables[dra_cnt].table_name
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = concat("Running Audit Query for table ",table_info->tables[dra_cnt].table_name
    )
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm_rmc_audit_query table_info->tables[dra_cnt].table_name
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = "Gathering DM_CHG_LOG data for table data"
   CALL disp_msg("",dm_err->logfile,0)
   CALL dra_get_dcl_data(table_info->tables[dra_cnt].table_name,drgi_global,table_info,dra_cnt)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_script
   ENDIF
   SET stat = print_xml_body(dra_audit->file_name,dra_info,tmc_md_info,dra_tab_loc)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   DELETE  FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g)
    WHERE 1=1
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 ENDFOR
 SET dra_end_date = cnvtdatetime(curdate,curtime2)
 SET stat = print_xml_footer(dra_audit->file_name)
 CALL copy_xsl("dm_rdds_audit.xsl",replace(dra_audit->file_name,".xml",".xsl"))
 IF (dra_disp_ind=1)
  CALL drcm_file_complete("RDDS SOLUTION DATA AUDIT",drcm_files,"Audit",0,dm_err->err_ind,
   drgi_global->target_name,drgi_global->target_id)
 ENDIF
 SUBROUTINE print_xml_header(sfile,sxslfile,pxh_global)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   DECLARE sauditmsg = vc WITH protect, noconstant(" ")
   IF ((dra_audit->limit_ctxt=1))
    SET sauditmsg = concat(sauditmsg,
     " The audit output has been limited to specific context name(s): ",dra_audit->ctxts_to_audit)
   ENDIF
   SELECT INTO value(sfile)
    FROM dummyt d
    DETAIL
     CALL print(concat('<?xml-stylesheet href="',sxslfile,'" type="text/xsl"?>')), row + 1,
     "<rdds_audit_data>",
     row + 1, "<audit_date_start>", dra_start_date"DD-MMM-YYYY HH:MM:SS;;D",
     "</audit_date_start>", row + 1, "<source_environment_id>",
     pxh_global->source_id, "</source_environment_id>", row + 1,
     "<source_environment_name>", pxh_global->source_name, "</source_environment_name>",
     row + 1, "<target_environment_id>", pxh_global->target_id,
     "</target_environment_id>", row + 1, "<target_environment_name>",
     pxh_global->target_name, "</target_environment_name>", row + 1,
     "<audit_message>", sauditmsg, "</audit_message>",
     row + 1
    WITH nocounter, maxrow = 1, maxcol = 4000,
     format = variable, formfeed = none
   ;end select
   RETURN(null)
 END ;Subroutine
 SUBROUTINE print_table_header(pth_file,pth_tab_info,tab_info_loc,pth_md_info,md_info_loc)
  SELECT INTO value(pth_file)
   FROM dummyt d
   DETAIL
    '<table_name id="', table_info->tables[tab_info_loc].table_name, '">',
    row + 1
   WITH nocounter, maxrow = 1, maxcol = 4000,
    format = variable, formfeed = none, append
  ;end select
  RETURN(null)
 END ;Subroutine
 SUBROUTINE print_xml_body(sfile,pxb_audit_info,pxb_md_info,pxb_md_loc)
   DECLARE ilogtypeidx = i4 WITH protect, noconstant(0)
   DECLARE iaudittypeidx = i4 WITH protect, noconstant(0)
   DECLARE iauditrowidx = i4 WITH protect, noconstant(0)
   DECLARE iauditcolidx = i4 WITH protect, noconstant(0)
   DECLARE iprintrowstag = i4 WITH protect, noconstant(0)
   DECLARE srowstart = vc WITH protect, noconstant("")
   DECLARE srowend = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Writing XML Data"
   CALL disp_msg("",dm_err->logfile,0)
   SET pxb_audit_info->audit_types[1].log_type_cnt = 0
   SET pxb_audit_info->audit_types[1].audit_cnt = 0
   SET stat = alterlist(pxb_audit_info->audit_types[1].log_types,pxb_audit_info->audit_types[1].
    log_type_cnt)
   SET pxb_audit_info->audit_types[2].log_type_cnt = 0
   SET pxb_audit_info->audit_types[2].audit_cnt = 0
   SET stat = alterlist(pxb_audit_info->audit_types[2].log_types,pxb_audit_info->audit_types[2].
    log_type_cnt)
   SELECT INTO "nl:"
    g.log_type, cnt = count(*)
    FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g)
    WHERE g.status="TARGET"
    GROUP BY g.log_type
    ORDER BY g.log_type
    DETAIL
     pxb_audit_info->audit_types[1].log_type_cnt = (pxb_audit_info->audit_types[1].log_type_cnt+ 1),
     stat = alterlist(pxb_audit_info->audit_types[1].log_types,pxb_audit_info->audit_types[1].
      log_type_cnt), pxb_audit_info->audit_types[1].log_types[pxb_audit_info->audit_types[1].
     log_type_cnt].log_type = g.log_type,
     pxb_audit_info->audit_types[1].log_types[pxb_audit_info->audit_types[1].log_type_cnt].cnt = cnt,
     pxb_audit_info->audit_types[1].audit_cnt = (pxb_audit_info->audit_types[1].audit_cnt+ cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    g.log_type, cnt = count(*)
    FROM (parser(concat("dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd")) g)
    WHERE g.status="SOURCE"
    GROUP BY g.log_type
    ORDER BY g.log_type
    DETAIL
     pxb_audit_info->audit_types[2].log_type_cnt = (pxb_audit_info->audit_types[2].log_type_cnt+ 1),
     stat = alterlist(pxb_audit_info->audit_types[2].log_types,pxb_audit_info->audit_types[2].
      log_type_cnt), pxb_audit_info->audit_types[2].log_types[pxb_audit_info->audit_types[2].
     log_type_cnt].log_type = g.log_type,
     pxb_audit_info->audit_types[2].log_types[pxb_audit_info->audit_types[2].log_type_cnt].cnt = cnt,
     pxb_audit_info->audit_types[2].audit_cnt = (pxb_audit_info->audit_types[2].audit_cnt+ cnt)
    WITH nocounter
   ;end select
   CALL parser("select into value(sFile)",0)
   CALL parser(concat(" from dm_rdds_",trim(cnvtstring(currdbhandle)),"_aud_gttd g, dm_info di"),0)
   CALL parser(" where g.status in('SOURCE','TARGET') ",0)
   CALL parser(" and outerjoin(g.log_type) = di.info_name ",0)
   CALL parser(" and di.info_domain = outerjoin('RDDS CONFIGURATION:AUDITABLE NOMV') ",0)
   CALL parser(" order by g.status, g.log_type",0)
   CALL parser(" head g.status",0)
   CALL parser("   iPrintRowsTag = 0",0)
   CALL parser("   if(g.status = 'TARGET')",0)
   CALL parser("      pxb_type_cnt = 1",0)
   CALL parser("   elseif(g.status = 'SOURCE')",0)
   CALL parser("      pxb_type_cnt = 2",0)
   CALL parser("   endif",0)
   CALL parser("   call print(concat(^<audit id='^, trim(cnvtstring(pxb_type_cnt),3),^'>^))",0)
   CALL parser("   row+1",0)
   CALL parser(concat(
     "   call print(concat('<audit_description>', pxb_audit_info->audit_types[pxb_type_cnt].audit_desc,",
     "'</audit_description>'))"),0)
   CALL parser("   row+1",0)
   CALL parser("   if (pxb_audit_info->audit_types[pxb_type_cnt].audit_cnt > 0)",0)
   CALL parser(concat("      call print(concat('<row_count>', ",
     "trim(cnvtstring(pxb_audit_info->audit_types[pxb_type_cnt].audit_cnt),3),'</row_count>'))"),0)
   CALL parser("      row+1",0)
   CALL parser("      iAuditRowIdx = 1",0)
   CALL parser("   elseif (pxb_audit_info->audit_types[pxb_type_cnt].audit_cnt = 0 AND ",0)
   CALL parser("   pxb_audit_info->audit_types[pxb_type_cnt].audit_msg <= '')",0)
   CALL parser("      call print('<row_count>NO DIFFERENCES FOUND</row_count>')",0)
   CALL parser("      row+1",0)
   CALL parser("   else  ",0)
   CALL parser(concat("      call print(concat('<row_count>',",
     "encode_html_string (pxb_audit_info->audit_types[pxb_type_cnt].audit_msg),'</row_count>'))"),0)
   CALL parser("      row+1",0)
   CALL parser("   endif ;pxb_audit_info->audit_types[pxb_type_cnt].audit_cnt > 0",0)
   CALL parser("   if (pxb_audit_info->audit_types[pxb_type_cnt].log_type_cnt > 0)",0)
   CALL parser("      call print('<log_types>')",0)
   CALL parser(
    "      for (iLogTypeIdx = 1 to pxb_audit_info->audit_types[pxb_type_cnt].log_type_cnt)",0)
   CALL parser("         row+1",0)
   CALL parser(concat("         call print(concat(^<log_type id='^, ",
     "pxb_audit_info->audit_types[pxb_type_cnt].log_types[iLogTypeIdx].log_type,^'>^))"),0)
   CALL parser("         row+1",0)
   CALL parser("         call print(concat('<log_count>', trim(cnvtstring(",0)
   CALL parser(
    "         pxb_audit_info->audit_types[pxb_type_cnt].log_types[iLogTypeIdx].cnt),3), '</log_count>'))",
    0)
   CALL parser("         row+1",0)
   CALL parser(
    "         call print(concat('<log_inv>', evaluate(di.info_number,1.0,^Yes^,^No^), '</log_inv>'))",
    0)
   CALL parser("         row+1",0)
   CALL parser("         call print('</log_type>')",0)
   CALL parser("      endfor ;Log Types",0)
   CALL parser("      row+1",0)
   CALL parser("      call print('</log_types>')",0)
   CALL parser("   endif ;log_type_cnt > 0",0)
   CALL parser("detail",0)
   CALL parser("   if (iAuditRowIdx = 1)",0)
   CALL parser("      iPrintRowsTag = 1",0)
   CALL parser("      '<audit_rows>'",0)
   CALL parser("   endif ;iAuditRowIdx = 1",0)
   CALL parser("   row+1",0)
   CALL parser('   if (g.status = "TARGET")',0)
   CALL parser('      sRowStart = "<target_row>"',0)
   CALL parser('      sRowEnd = "</target_row>"',0)
   CALL parser('   elseif (g.status = "SOURCE")',0)
   CALL parser('      sRowStart = "<source_row>"',0)
   CALL parser('      sRowEnd = "</source_row>"',0)
   CALL parser("   else",0)
   CALL parser('      sRowStart = "<difference_row>"',0)
   CALL parser('      sRowEnd = "</difference_row>"',0)
   CALL parser("   endif",0)
   CALL parser("   call print(sRowStart)",0)
   CALL parser("   row+1",0)
   CALL parser("   call print(concat(^<log_type id='^, g.log_type,^'></log_type>^))",0)
   CALL parser("   call print(concat(^<context_name id='^,trim(g.context_name),^'></context_name>^))",
    0)
   CALL parser('        if (g.status = "SOURCE")',0)
   CALL parser("           row+1",0)
   CALL parser(
    "       call print(concat('<source_value><LOG_ID>',trim(cnvtstring(g.log_id,20,2)),'</LOG_ID></source_value>'))",
    0)
   CALL parser("           row+1",0)
   CALL parser(concat(
     "           call print(concat('<source_value><FILTERED>',evaluate(g.filtered_ind,1,^No^,^Yes^),",
     "'</FILTERED></source_value>'))"),0)
   CALL parser("           row+1",0)
   CALL parser("        else",0)
   CALL parser("           row+1",0)
   CALL parser(
    "        call print(concat('<target_value><LOG_ID>',trim(cnvtstring(g.log_id,20,2)),'</LOG_ID></target_value>'))",
    0)
   CALL parser("           row+1",0)
   CALL parser(concat(
     "           call print(concat('<target_value><FILTERED>',evaluate(g.filtered_ind,1,^No^,^Yes^),",
     "'</FILTERED></target_value>'))"),0)
   CALL parser("           row+1",0)
   CALL parser("        endif",0)
   CALL parser("   row+1",0)
   FOR (iauditcolidx = 1 TO pxb_md_info->tbl_qual[pxb_md_loc].col_cnt)
     IF ((((pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].meaningful_ind=1)) OR ((
     pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].pk_ind=1))) )
      CALL parser('        if (g.status = "SOURCE")',0)
      CALL parser('            call print("<source_value>")',0)
      CALL parser(concat("            call print(concat('<',pxb_md_info->tbl_qual[",trim(cnvtstring(
          pxb_md_loc)),"].col_qual[",trim(cnvtstring(iauditcolidx)),"].column_name,'>'))"),0)
      CALL parser("            row+1",0)
      IF ((pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].data_type="*C*"))
       CALL parser(concat("call print(encode_html_string(g.",pxb_md_info->tbl_qual[pxb_md_loc].
         col_qual[iauditcolidx].column_name,"))"),0)
      ELSEIF ((pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].data_type="DQ8"))
       CALL parser(concat("call print(format(g.",pxb_md_info->tbl_qual[pxb_md_loc].col_qual[
         iauditcolidx].column_name,",';;Q'))"),0)
      ELSE
       CALL parser(concat("call print(g.",pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].
         column_name,")"),0)
      ENDIF
      CALL parser("            row+1",0)
      CALL parser(concat('            call print(concat("</", pxb_md_info->tbl_qual[',trim(cnvtstring
         (pxb_md_loc)),"].col_qual[",trim(cnvtstring(iauditcolidx)),'].column_name, ">"))'),0)
      CALL parser('            call print("</source_value>")',0)
      CALL parser("        else",0)
      CALL parser("           row+1",0)
      CALL parser('            call print("<target_value>")',0)
      CALL parser(concat("            call print(concat('<',pxb_md_info->tbl_qual[",trim(cnvtstring(
          pxb_md_loc)),"].col_qual[",trim(cnvtstring(iauditcolidx)),"].column_name,'>'))"),0)
      CALL parser("            row+1",0)
      IF ((pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].data_type="*C*"))
       CALL parser(concat("call print(encode_html_string(g.",pxb_md_info->tbl_qual[pxb_md_loc].
         col_qual[iauditcolidx].column_name,"))"),0)
      ELSEIF ((pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].data_type="DQ8"))
       CALL parser(concat("call print(format(g.",pxb_md_info->tbl_qual[pxb_md_loc].col_qual[
         iauditcolidx].column_name,",';;Q'))"),0)
      ELSE
       CALL parser(concat("call print(g.",pxb_md_info->tbl_qual[pxb_md_loc].col_qual[iauditcolidx].
         column_name,")"),0)
      ENDIF
      CALL parser("            row+1",0)
      CALL parser(concat('            call print(concat("</", pxb_md_info->tbl_qual[',trim(cnvtstring
         (pxb_md_loc)),"].col_qual[",trim(cnvtstring(iauditcolidx)),'].column_name, ">"))'),0)
      CALL parser('            call print("</target_value>")',0)
      CALL parser("         endif ;audit_flg = 2 or 3 and pk_ind != 1",0)
     ENDIF
   ENDFOR
   CALL parser("   row+1",0)
   CALL parser("   call print(sRowEnd)",0)
   CALL parser("   iAuditRowIdx = iAuditRowIdx + 1",0)
   CALL parser("foot g.status ",0)
   CALL parser("   ;If there were audit rows found, print the end tag",0)
   CALL parser("   if (iPrintRowsTag > 0)",0)
   CALL parser("      row+1",0)
   CALL parser('      "</audit_rows>"',0)
   CALL parser("   endif ;iPrintRowsTag > 0",0)
   CALL parser("   row+1",0)
   CALL parser('   "</audit>"',0)
   CALL parser("foot report",0)
   CALL parser("   row+1",0)
   CALL parser('   "</table_name>"',0)
   CALL parser(
    "WITH  NOCOUNTER , MAXROW = 1 , MAXCOL = 4000 , FORMAT = VARIABLE , APPEND , FORMFEED = NONE go ",
    1)
   IF (curqual=0)
    SELECT INTO value(sfile)
     FROM dual
     DETAIL
      row + 1, "</table_name>"
     WITH nocounter, maxrow = 1, maxcol = 4000,
      format = variable, append, formfeed = none
    ;end select
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE print_xml_footer(sfile)
  SELECT INTO value(sfile)
   FROM dummyt d
   DETAIL
    "<audit_date_end>", dra_end_date"DD-MMM-YYYY HH:MM:SS;;D", "</audit_date_end>",
    row + 1, "</rdds_audit_data>"
   WITH nocounter, maxrow = 1, maxcol = 4000,
    format = variable, formfeed = none, append
  ;end select
  RETURN(1)
 END ;Subroutine
#exit_script
 CALL dm2_get_rdbms_version(null)
 IF (check_error("Retrieving Oracle version from product_component_version") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "Dropping GTTD..."
 CALL disp_msg("",dm_err->logfile,0)
 IF ((dm2_rdbms_version->level1 >= 10))
  CALL parser(concat("rdb drop table DM_RDDS_",trim(currdbhandle),"_AUD_GTTD purge go"),1)
 ELSE
  CALL parser(concat("rdb drop table DM_RDDS_",trim(currdbhandle),"_AUD_GTTD go"),1)
 ENDIF
 CALL parser(concat("drop table DM_RDDS_",trim(currdbhandle),"_AUD_GTTD go"),1)
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 FREE RECORD table_info
END GO
