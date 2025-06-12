CREATE PROGRAM dm_rmc_get_source_rows:dba
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
 DECLARE drmm_get_col_string(sbr_pk_where=vc,sbr_log_id=f8,sbr_tbl_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 DECLARE drmm_get_ptam_match_query(sbr_log_id=f8,sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) =
 null
 DECLARE drmm_get_ptam_match_result(sbr_log_id=f8,sbr_src_env_id=f8,sbr_tgt_env_id=f8,sbr_db_link=vc,
  sbr_local_ind=i2,
  sbr_trans_type=vc) = f8
 DECLARE drmm_get_pk_where(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_delete_ind=i2,sbr_db_link=vc) = vc
 DECLARE drmm_get_exploded_pkw(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_func_name(sbr_prefix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_cust_col_string(sbr_pk_where=vc,sbr_tbl_name=vc,sbr_col_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 IF ( NOT (validate(col_string_parm,0)))
  FREE RECORD col_string_parm
  RECORD col_string_parm(
    1 total = i4
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 column_name = vc
        3 in_src_ind = i2
  ) WITH protect
 ENDIF
 SUBROUTINE drmm_get_col_string(sbr_pk_where,sbr_log_id,sbr_tbl_name,sbr_tbl_suffix,sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgcs_dcl_tab_name = concat("DM_CHG_LOG",dgcs_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_COL_STRING",d.col_string)
     FROM (parser(dgcs_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ELSE
    SET dgcs_tab_name = sbr_tbl_name
    SET dgcs_tab_suffix = sbr_tbl_suffix
    SET dgcs_col_pos = locateval(dgcs_num,1,col_string_parm->total,dgcs_tab_name,col_string_parm->
     qual[dgcs_num].table_name)
    IF (dgcs_col_pos=0)
     SET dgcs_col_pos = (col_string_parm->total+ 1)
     SET stat = alterlist(col_string_parm->qual,dgcs_col_pos)
     SET col_string_parm->total = dgcs_col_pos
     SET col_string_parm->qual[dgcs_col_pos].table_name = dgcs_tab_name
     SELECT INTO "nl:"
      FROM dm_colstring_parm d
      WHERE d.table_name=dgcs_tab_name
      ORDER BY d.parm_nbr
      HEAD REPORT
       parm_cnt = 0
      DETAIL
       parm_cnt = (parm_cnt+ 1), stat = alterlist(col_string_parm->qual[dgcs_col_pos].col_qual,
        parm_cnt), col_string_parm->qual[dgcs_col_pos].col_qual[parm_cnt].column_name = d.column_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (dgcs_db_link > "")
     FOR (dgcs_col_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
       SET col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_col_loop].in_src_ind = 0
     ENDFOR
     SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
     SELECT INTO "nl:"
      FROM (parser(dgcs_utc_name) utc)
      WHERE (utc.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
       AND expand(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].col_qual,5),utc.column_name,
       col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].column_name)
       AND  NOT (column_name IN ("KEY1", "KEY2", "KEY3"))
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),utc.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF (dgcs_pos > 0)
        col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     SELECT DISTINCT INTO "nl:"
      dpwp.column_name
      FROM dm_pk_where_parm dpwp
      WHERE (dpwp.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),dpwp.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind=0))
        dgcs_miss_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     IF (dgcs_miss_ind=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(
       "PK_WHERE or PTAM_MATCH_QUERY is going to use a column that does not exist in source.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (2))
     ENDIF
    ENDIF
    SET dgcs_func_prefix = concat("REFCHG_COLSTRING_",dgcs_tab_suffix)
    SET dgcs_func_name = drmm_get_func_name(dgcs_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN(- (1))
    ENDIF
    IF (dgcs_func_name="")
     SET dm_err->emsg = concat("A col_string function is not built: ",dgcs_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(- (1))
    ENDIF
    CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
    SET dgcs_stmt_cnt = (size(col_string_parm->qual[dgcs_col_pos].col_qual,5)+ 4)
    SET stat = alterlist(parse_rs->stmt,dgcs_stmt_cnt)
    SET dgcs_qual_cnt = 0
    SET dgcs_stmt_idx = 1
    SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
    SET parse_rs->stmt[dgcs_stmt_idx].str =
    "select into 'nl:' dm2_context_control_wrapper('RDDS_COL_STRING',"
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
    FOR (dgcs_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
      SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
      IF (dgcs_loop != 1)
       SET parse_rs->stmt[dgcs_stmt_idx].str = ","
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = " "
      ENDIF
      IF (dgcs_db_link > "")
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].in_src_ind=0))
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"NULL")
       ELSE
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
         dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
       ENDIF
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
        dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
      ENDIF
    ENDFOR
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
     " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
     ",1) go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
    IF (dgcs_qual_cnt=0)
     CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_query(sbr_log_id,sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgpq_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpq_func_name = vc WITH protect, noconstant("")
   DECLARE dgpq_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpq_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpq_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpq_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_PTAM_MATCH_QUERY",d.ptam_match_query)
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ELSE
    SET dgpq_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
    SET dgpq_func_name = drmm_get_func_name(dgpq_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN
    ENDIF
    IF (dgpq_func_name="")
     SET dm_err->emsg = concat("A function is not built: ",dgpq_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN
    ENDIF
    CALL parser(concat("declare ",dgpq_func_name,"() = c2000 go"),1)
    SET stat = alterlist(parse_rs->stmt,3)
    SET parse_rs->stmt[1].str =
    "SELECT into 'nl:' sbr_ind = dm2_context_control_wrapper('RDDS_PTAM_MATCH_QUERY',"
    SET parse_rs->stmt[2].str = concat(dgpq_func_name,
     "(0,1,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpq_db_link,"')) from dual")
    SET parse_rs->stmt[3].str = " with nocounter go"
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_result(sbr_log_id,sbr_src_env_id,sbr_tgt_env_id,sbr_db_link,
  sbr_local_ind,sbr_xlat_type)
   DECLARE dgpr_ptam_result = f8 WITH protect, noconstant(0.0)
   DECLARE dgpr_src_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_tgt_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgpr_xlat_type = vc WITH protect, noconstant(" ")
   DECLARE refchg_run_ptam() = f8
   DECLARE sys_context() = c2000
   IF (sbr_db_link > " ")
    SET dgpr_db_link = sbr_db_link
   ENDIF
   IF (sbr_xlat_type > " ")
    SET dgpr_xlat_type = sbr_xlat_type
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpr_db_link)
    SELECT INTO "nl:"
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     DETAIL
      dgpr_ptam_result = d.ptam_match_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSE
    SET dgpr_src_str = concat(trim(cnvtstring(sbr_src_env_id)),".0")
    SET dgpr_tgt_str = concat(trim(cnvtstring(sbr_tgt_env_id)),".0")
    SELECT INTO "nl:"
     ptam_result = refchg_run_ptam(replace(replace(replace(replace(replace(sys_context("CERNER",
            "RDDS_PTAM_MATCH_QUERY",2000),"<SOURCE_ID>",dgpr_src_str),"<TARGET_ID>",dgpr_tgt_str),
         "<DB_LINK>",concat("'",dgpr_db_link,"'")),"<LOCAL_IND>",trim(cnvtstring(sbr_local_ind))),
       "<XLAT_TYPE>",concat("'",dgpr_xlat_type,"'")))
     FROM dual
     DETAIL
      dgpr_ptam_result = ptam_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(dgpr_ptam_result)
 END ;Subroutine
 SUBROUTINE drmm_get_pk_where(sbr_tab_name,sbr_tab_suffix,sbr_delete_ind,sbr_db_link)
   DECLARE dgpw_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpw_func_name = vc WITH protect, noconstant("")
   DECLARE dgpw_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpw_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgpw_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpw_db_link = sbr_db_link
   ENDIF
   SET dgpw_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgpw_func_name = drmm_get_func_name(dgpw_func_prefix," ")
   IF (dgpw_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgpw_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgpw_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgpw_pkw = "
   SET parse_rs->stmt[2].str = concat(dgpw_func_name,"(1,",trim(cnvtstring(sbr_delete_ind)),
    ",SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpw_db_link,
    "') from dual")
   SET parse_rs->stmt[3].str = "detail dgpw_pk_where = dgpw_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgpw_pk_where)
 END ;Subroutine
 SUBROUTINE drmm_get_func_name(sbr_prefix,sbr_db_link)
   DECLARE dgfn_func_name = vc WITH protect, noconstant("")
   DECLARE dgfn_uo_tab = vc WITH protect, noconstant("")
   DECLARE dgfn_prefix = vc WITH protect, noconstant("")
   SET dgfn_uo_tab = concat("USER_OBJECTS",sbr_db_link)
   SET dgfn_prefix = concat(sbr_prefix,"*")
   SELECT INTO "nl:"
    FROM (parser(dgfn_uo_tab) uo)
    WHERE uo.object_name=patstring(dgfn_prefix)
    DETAIL
     dgfn_func_name = uo.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgfn_func_name)
 END ;Subroutine
 SUBROUTINE drmm_get_cust_col_string(sbr_pk_where,sbr_tbl_name,sbr_col_name,sbr_tbl_suffix,
  sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   DECLARE dgcs_col_name = vc WITH protect, noconstant("")
   DECLARE dgcs_type = vc WITH protect, noconstant("")
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   SET dgcs_tab_name = sbr_tbl_name
   SET dgcs_tab_suffix = sbr_tbl_suffix
   SET dgcs_col_name = sbr_col_name
   IF (dgcs_db_link > "")
    SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
   ELSE
    SET dgcs_utc_name = "USER_TAB_COLUMNS"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dgcs_utc_name) utc)
    WHERE utc.table_name=dgcs_tab_name
     AND utc.column_name=dgcs_col_name
    DETAIL
     dgcs_type = utc.data_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (curqual=0)
    CALL disp_msg("The column being asked for does not exist in source.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ( NOT (dgcs_type IN ("DATE", "FLOAT", "NUMBER", "CHAR", "VARCHAR2")))
    CALL disp_msg("The column being asked has an incompatible data_type.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET dgcs_func_name = "REFCHG_CUST_COLSTRING"
   CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
   SET stat = alterlist(parse_rs->stmt,5)
   SET dgcs_qual_cnt = 0
   SET dgcs_stmt_idx = 1
   SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
   SET parse_rs->stmt[dgcs_stmt_idx].str =
   "select into 'nl:' dm2_context_control_wrapper('RDDS_CUST_COL_STRING',"
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat("'",dgcs_col_name,"','",dgcs_type,"',")
   IF (dgcs_type IN ("VARCHAR2", "CHAR"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,
     "0.0,cnvtdatetime(curdate,curtime3),","t",dgcs_tab_suffix,".",
     dgcs_col_name)
   ELSEIF (dgcs_type IN ("FLOAT", "NUMBER"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",cnvtdatetime(curdate,curtime3),'ABC'")
   ELSE
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"0.0,t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",'ABC'")
   ENDIF
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
    " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
    ",1) go")
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgcs_qual_cnt=0)
    CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_exploded_pkw(sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgep_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgep_func_name = vc WITH protect, noconstant("")
   DECLARE dgep_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgep_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgep_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgep_db_link = sbr_db_link
   ENDIF
   SET dgep_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgep_func_name = drmm_get_func_name(dgep_func_prefix," ")
   IF (dgep_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgep_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgep_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgep_pkw = "
   SET parse_rs->stmt[2].str = concat(dgep_func_name,
    "(1,0,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgep_db_link,"',0) from dual")
   SET parse_rs->stmt[3].str = "detail dgep_pk_where = dgep_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgep_pk_where)
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
 DECLARE tgsc_tab = vc WITH protect, noconstant("DM_CHG_LOG")
 DECLARE tgsc_pos = i4 WITH protect, noconstant(0)
 DECLARE tgsc_loop = i4 WITH protect, noconstant(0)
 DECLARE tgsc_done_loop = i4 WITH protect, noconstant(0)
 DECLARE tgsc_add_on_str = vc WITH protect, noconstant(" ")
 DECLARE tgsc_par_pos = i4 WITH protect, noconstant(0)
 DECLARE tgsc_pe_col = vc WITH protect, noconstant(" ")
 DECLARE tgsc_pe_val = vc WITH protect, noconstant(" ")
 DECLARE tgsc_par_tab = vc WITH protect, noconstant(" ")
 DECLARE tgsc_perm_pk = vc WITH protect, noconstant(" ")
 DECLARE tgsc_vers_last_ind = i4 WITH protect, noconstant(0)
 DECLARE tgsc_col_loop = i4 WITH protect, noconstant(0)
 DECLARE tgsc_log_pos = i4 WITH protect, noconstant(0)
 DECLARE tgsc_col_pos = i4 WITH protect, noconstant(0)
 DECLARE tgsc_col_ind = i4 WITH protect, noconstant(0)
 DECLARE tgsc_parse_cnt = i4 WITH protect, noconstant(0)
 DECLARE tgsc_tab_str = vc WITH protect, noconstant(" ")
 DECLARE tgsc_log_id_str = vc WITH protect, noconstant(" ")
 DECLARE tgsc_log_type_str = vc WITH protect, noconstant(" ")
 DECLARE tgsc_ctxt_str = vc WITH protect, noconstant(" ")
 DECLARE tgsc_ctxt_nullind = i2 WITH protect, noconstant(0)
 DECLARE tgsc_tab_suffix = vc WITH protect, noconstant(" ")
 DECLARE tgsc_temp_pk_where = vc WITH protect, noconstant(" ")
 DECLARE length() = i4
 DECLARE evaluate_pe_name() = c255
 FREE RECORD tgsc_info
 RECORD tgsc_info(
   1 cnt = i4
   1 qual[*]
     2 table_name = vc
     2 src_table_name = vc
     2 pk_where = vc
     2 log_id = f8
     2 updt_id = f8
     2 blocking_log_id = f8
     2 context_name = vc
     2 cur_state_exploded_ind = i2
     2 count = i4
     2 delete_ind = i2
 )
 FREE RECORD dcvp_str
 RECORD dcvp_str(
   1 cnt = i4
   1 qual[*]
     2 add_on_str = vc
     2 order_by_str = vc
     2 with_str = vc
     2 query_ind = i2
     2 cur_state_pkw = vc
 )
 FREE RECORD tgsc_parse
 RECORD tgsc_parse(
   1 stmt[*]
     2 str = vc
 )
 SET dm_err->eproc = "Starting dm_rmc_get_source_rows..."
 IF (check_logfile("dm_rmc_get_src",".log","DM_RMC_GET_SOURCE_ROWS LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ( NOT (validate(tgsc_req,0)))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("Required request record structure TGSC_REQ has not been declared.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF ( NOT (validate(tgsc_rep,0)))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Required reply record structure TGSC_REP has not been declared."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (textlen(trim(tgsc_req->db_link)) > 0)
  SET tgsc_tab = concat(tgsc_tab,tgsc_req->db_link)
 ENDIF
 IF (((daf_is_blank(tgsc_req->table_name)) OR (daf_is_blank(tgsc_req->log_type)))
  AND (tgsc_req->log_cnt=0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "Request record structure not correctly populated. Provide either a table_name/log_type or list of log_ids"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (daf_is_not_blank(tgsc_req->table_name))
  SET tgsc_tab_str = " d.table_name = patstring(tgsc_req->table_name)"
 ELSE
  SET tgsc_tab_str = " 1 = 1"
 ENDIF
 IF ((tgsc_req->log_cnt > 0))
  SET tgsc_log_id_str =
  "expand(tgsc_pos, 1, tgsc_req->log_cnt, d.log_id, tgsc_req->log_qual[tgsc_pos].log_id)"
 ELSE
  SET tgsc_log_id_str = " 1 = 1"
 ENDIF
 IF (textlen(trim(tgsc_req->log_type)) > 0)
  SET tgsc_log_type_str = "d.log_type = tgsc_req->log_type"
 ELSE
  SET tgsc_log_type_str = " 1 = 1"
 ENDIF
 IF ((tgsc_req->ctxt_cnt=1)
  AND (tgsc_req->ctxt_qual[1].ctxt_name != "NULL"))
  SET tgsc_ctxt_str = " d.context_name = patstring(tgsc_req->ctxt_qual[1].ctxt_name)"
 ELSEIF ((tgsc_req->ctxt_cnt=1))
  SET tgsc_ctxt_str = " d.context_name is null"
 ELSEIF ((tgsc_req->ctxt_cnt > 1))
  SET tgsc_ctxt_str = "( d.context_name IN("
  FOR (tgsc_pos = 1 TO tgsc_req->ctxt_cnt)
    IF ((tgsc_req->ctxt_qual[tgsc_pos].ctxt_name != "NULL"))
     SET tgsc_ctxt_str = concat(tgsc_ctxt_str,"'",tgsc_req->ctxt_qual[tgsc_pos].ctxt_name,"',")
    ELSE
     SET tgsc_ctxt_nullind = 1
    ENDIF
  ENDFOR
  SET tgsc_ctxt_str = concat(substring(1,(size(tgsc_ctxt_str,1) - 1),tgsc_ctxt_str),")")
  IF (tgsc_ctxt_nullind=1)
   SET tgsc_ctxt_str = concat(tgsc_ctxt_str," or d.context_name is null)")
  ELSE
   SET tgsc_ctxt_str = concat(tgsc_ctxt_str,")")
  ENDIF
 ELSE
  SET tgsc_ctxt_str = " 1 = 1"
 ENDIF
 SELECT INTO "NL:"
  FROM (parser(tgsc_tab) d)
  WHERE parser(tgsc_log_id_str)
   AND parser(tgsc_tab_str)
   AND parser(tgsc_ctxt_str)
   AND parser(tgsc_log_type_str)
   AND (d.target_env_id=tgsc_req->target_env_id)
  DETAIL
   tgsc_temp_pk_where = replace(d.pk_where,"<MERGE_LINK>",tgsc_req->db_link,0)
   IF (locateval(tgsc_pos,1,tgsc_info->cnt,tgsc_temp_pk_where,tgsc_info->qual[tgsc_pos].pk_where)=0)
    tgsc_info->cnt = (tgsc_info->cnt+ 1), stat = alterlist(tgsc_info->qual,tgsc_info->cnt), tgsc_info
    ->qual[tgsc_info->cnt].log_id = d.log_id,
    tgsc_info->qual[tgsc_info->cnt].table_name = d.table_name, tgsc_info->qual[tgsc_info->cnt].
    pk_where = tgsc_temp_pk_where, tgsc_info->qual[tgsc_info->cnt].src_table_name = concat(trim(d
      .table_name),tgsc_req->db_link),
    tgsc_info->qual[tgsc_info->cnt].updt_id = d.updt_id, tgsc_info->qual[tgsc_info->cnt].
    blocking_log_id = d.blocking_log_id, tgsc_info->qual[tgsc_info->cnt].context_name = d
    .context_name,
    tgsc_info->qual[tgsc_info->cnt].delete_ind = d.delete_ind
    IF (d.updt_applctx=4310001)
     tgsc_info->qual[tgsc_info->cnt].cur_state_exploded_ind = 1
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET stat = alterlist(tgsc_rep->row_qual,tgsc_info->cnt)
 SET tgsc_rep->row_cnt = tgsc_info->cnt
 FOR (tgsc_loop = 1 TO tgsc_info->cnt)
   SET tgsc_rep->table_name = tgsc_info->qual[tgsc_loop].table_name
   SET tgsc_rep->row_qual[tgsc_loop].log_id = tgsc_info->qual[tgsc_loop].log_id
   SET tgsc_rep->row_qual[tgsc_loop].blocking_log_id = tgsc_info->qual[tgsc_loop].blocking_log_id
   SET tgsc_rep->row_qual[tgsc_loop].updt_id = tgsc_info->qual[tgsc_loop].updt_id
   SET tgsc_rep->row_qual[tgsc_loop].context_name = tgsc_info->qual[tgsc_loop].context_name
   SET tgsc_rep->row_qual[tgsc_loop].pk_where = tgsc_info->qual[tgsc_loop].pk_where
   SET tgsc_rep->row_qual[tgsc_loop].delete_ind = tgsc_info->qual[tgsc_loop].delete_ind
   SET stat = initrec(dcvp_str)
   IF ((tgsc_info->qual[tgsc_loop].delete_ind=0))
    SET tgsc_pos = locateval(tgsc_pos,1,tmc_md_info->tbl_cnt,tgsc_info->qual[tgsc_loop].table_name,
     tmc_md_info->tbl_qual[tgsc_pos].table_name)
    IF (tgsc_pos=0)
     CALL drm_md_wrp(tgsc_info->qual[tgsc_loop].table_name,tgsc_req->db_link)
     SET tgsc_pos = locateval(tgsc_pos,1,tmc_md_info->tbl_cnt,tgsc_info->qual[tgsc_loop].table_name,
      tmc_md_info->tbl_qual[tgsc_pos].table_name)
    ENDIF
    IF ((tmc_md_info->tbl_qual[tgsc_pos].cur_state_flag > 0)
     AND (tgsc_info->qual[tgsc_loop].cur_state_exploded_ind=0))
     SET tgsc_perm_pk = tgsc_info->qual[tgsc_loop].pk_where
     IF ((tmc_md_info->tbl_qual[tgsc_pos].cur_state_flag=2))
      CALL drmm_get_col_string(" ",tgsc_info->qual[tgsc_loop].log_id,tgsc_info->qual[tgsc_loop].
       table_name,concat("t",tmc_md_info->tbl_qual[tgsc_pos].suffix),tgsc_req->db_link)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       GO TO exit_program
      ENDIF
      SET tgsc_pe_col = tmc_md_info->tbl_qual[tgsc_pos].cs_parent_tab_col
      DECLARE refchg_colstring_get_col() = c2000
      DECLARE sys_context() = c4000
      SELECT INTO "nl:"
       v_str = refchg_colstring_get_col(sys_context("CERNER","RDDS_COL_STRING",4000),tgsc_pe_col,4,0,
        "",
        0,0,"FROM")
       FROM dual
       DETAIL
        tgsc_pe_val = v_str
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       GO TO exit_program
      ENDIF
      SET tgsc_par_pos = locateval(tgsc_par_pos,1,tmc_md_info->tbl_qual[tgsc_pos].cs_parent_cnt,
       tgsc_pe_val,tmc_md_info->tbl_qual[tgsc_pos].cs_parent_qual[tgsc_par_pos].cs_parent_table)
      IF (tgsc_par_pos=0)
       SET tgsc_info->qual[tgsc_loop].cur_state_exploded_ind = 1
      ELSE
       SET tgsc_par_tab = tmc_md_info->tbl_qual[tgsc_pos].cs_parent_qual[tgsc_par_pos].
       cs_parent_table
      ENDIF
     ELSE
      SET tgsc_par_tab = tmc_md_info->tbl_qual[tgsc_pos].cs_parent_qual[1].cs_parent_table
     ENDIF
     IF ((tgsc_info->qual[tgsc_loop].cur_state_exploded_ind=0))
      SET tgsc_par_pos = locateval(tgsc_par_pos,1,tmc_md_info->tbl_cnt,tgsc_par_tab,tmc_md_info->
       tbl_qual[tgsc_par_pos].table_name)
      IF (tgsc_par_pos=0)
       CALL drm_md_wrp(tgsc_par_tab,tgsc_req->db_link)
       SET tgsc_par_pos = locateval(tgsc_par_pos,1,tmc_md_info->tbl_cnt,tgsc_par_tab,tmc_md_info->
        tbl_qual[tgsc_par_pos].table_name)
      ENDIF
      IF ((tmc_md_info->tbl_qual[tgsc_par_pos].version_ind=1))
       SET tgsc_add_on_str = " "
       SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
       SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
       SET dcvp_str->qual[dcvp_str->cnt].add_on_str = " "
       SET dcvp_str->qual[dcvp_str->cnt].cur_state_pkw = replace(tgsc_perm_pk,"<VERS_CLAUSE>",
        " ACTIVE_IND = 1 ",0)
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
       SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
       IF ((tmc_md_info->tbl_qual[tgsc_par_pos].effective_col_ind=1))
        SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
        SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
        SET dcvp_str->qual[dcvp_str->cnt].add_on_str = " "
        SET dcvp_str->qual[dcvp_str->cnt].cur_state_pkw = replace(tgsc_perm_pk,"<VERS_CLAUSE>",concat
         (tmc_md_info->tbl_qual[tgsc_par_pos].beg_col_name,"<= cnvtdatetime(curdate,curtime3) and ",
          tmc_md_info->tbl_qual[tgsc_par_pos].end_col_name,">= cnvtdatetime(curdate,curtime3) "),0)
        SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter,notrim go"
       ENDIF
       SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
       SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
       SET dcvp_str->qual[dcvp_str->cnt].add_on_str = " "
       SET dcvp_str->qual[dcvp_str->cnt].cur_state_pkw = replace(tgsc_perm_pk,"<VERS_CLAUSE>",
        " 1 = 1 ",0)
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      ELSE
       SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
       SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
       SET dcvp_str->qual[dcvp_str->cnt].add_on_str = " "
       SET dcvp_str->qual[dcvp_str->cnt].cur_state_pkw = replace(tgsc_perm_pk,"<VERS_CLAUSE>",
        " 1 = 1 ",0)
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
       SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((((tmc_md_info->tbl_qual[tgsc_pos].cur_state_flag=0)) OR ((tgsc_info->qual[tgsc_loop].
    cur_state_exploded_ind=1))) )
     SET tgsc_tab_suffix = concat("t",tmc_md_info->tbl_qual[tgsc_pos].suffix)
     IF ((tmc_md_info->tbl_qual[tgsc_pos].version_ind=1)
      AND (((tmc_md_info->tbl_qual[tgsc_pos].version_type IN ("ALG1", "ALG3", "ALG4"))) OR ((
     tmc_md_info->tbl_qual[tgsc_pos].version_type="ALG7")
      AND (tmc_md_info->tbl_qual[tgsc_pos].effective_col_ind=0))) )
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(tgsc_tab_suffix,".active_ind = 1 ")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
      IF ((tmc_md_info->tbl_qual[tgsc_pos].effective_col_ind=1))
       SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
       SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
       SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(tgsc_tab_suffix,".",tmc_md_info->
        tbl_qual[tgsc_pos].beg_col_name," <= cnvtdatetime(curdate,curtime3) and ",tgsc_tab_suffix,
        ".",tmc_md_info->tbl_qual[tgsc_pos].end_col_name," >= cnvtdatetime(curdate,curtime3)")
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      ENDIF
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = " "
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = " order by updt_dt_tm desc "
      SET dcvp_str->qual[dcvp_str->cnt].with_str = "with maxrec=1, nocounter, notrim go"
     ELSEIF ((((tmc_md_info->tbl_qual[tgsc_pos].merge_delete_ind=1)) OR ((tmc_md_info->tbl_qual[
     tgsc_pos].version_type="ALG5"))) )
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      IF (daf_is_not_blank(tmc_md_info->tbl_qual[tgsc_pos].root_col_name))
       SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(tmc_md_info->tbl_qual[tgsc_pos].
        root_col_name," != 0.0")
      ENDIF
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
     ELSEIF ((tmc_md_info->tbl_qual[tgsc_pos].version_type IN ("ALG6", "ALG7")))
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(" ",tgsc_tab_suffix,
       ".active_ind = 1 and ",tgsc_tab_suffix,".",
       tmc_md_info->tbl_qual[tgsc_pos].beg_col_name," <= cnvtdatetime(curdate,curtime3) and ",
       tgsc_tab_suffix,".",tmc_md_info->tbl_qual[tgsc_pos].end_col_name,
       " >= cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(" ",tgsc_tab_suffix,
       ".active_ind = 1 and ",tgsc_tab_suffix,".",
       tmc_md_info->tbl_qual[tgsc_pos].end_col_name," < cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",tmc_md_info->tbl_qual[
       tgsc_pos].end_col_name," desc")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter, notrim go"
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(" ",tgsc_tab_suffix,
       ".active_ind = 0 and ",tgsc_tab_suffix,".",
       tmc_md_info->tbl_qual[tgsc_pos].beg_col_name," <= cnvtdatetime(curdate,curtime3) and ",
       tgsc_tab_suffix,".",tmc_md_info->tbl_qual[tgsc_pos].end_col_name,
       " >= cnvtdatetime(curdate,curtime3)")
      IF ((tmc_md_info->tbl_qual[tgsc_pos].version_type="ALG7"))
       SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",tmc_md_info->tbl_qual[
        tgsc_pos].beg_col_name," desc")
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter, notrim go"
      ELSE
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      ENDIF
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(" ",tgsc_tab_suffix,
       ".active_ind = 0 and ",tgsc_tab_suffix,".",
       tmc_md_info->tbl_qual[tgsc_pos].end_col_name," < cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",tmc_md_info->tbl_qual[
       tgsc_pos].end_col_name," desc")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter, notrim go"
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(" ",tgsc_tab_suffix,
       ".active_ind = 1 and ",tgsc_tab_suffix,".",
       tmc_md_info->tbl_qual[tgsc_pos].beg_col_name," > cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(" ",tgsc_tab_suffix,
       ".active_ind = 0 and ",tgsc_tab_suffix,".",
       tmc_md_info->tbl_qual[tgsc_pos].beg_col_name," > cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",tmc_md_info->tbl_qual[
       tgsc_pos].beg_col_name," asc")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter, notrim go"
     ELSE
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].add_on_str = concat(" ")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter, notrim go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
     ENDIF
    ENDIF
   ENDIF
   FOR (drgsr_idx = 1 TO dcvp_str->cnt)
     IF ((((tgsc_rep->row_qual[tgsc_loop].src_cnt=0)) OR ((dcvp_str->qual[drgsr_idx].query_ind=1))) )
      SET tgsc_col_ind = 0
      SET tgsc_parse_cnt = 1
      SET stat = initrec(tgsc_parse)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      SET tgsc_parse->stmt[tgsc_parse_cnt].str = "select into 'nl:'"
      FOR (tgsc_col_loop = 1 TO tgsc_req->xlat_col_cnt)
       SET tgsc_col_pos = locateval(tgsc_col_pos,1,tmc_md_info->tbl_qual[tgsc_pos].col_cnt,tgsc_req->
        xlat_col_qual[tgsc_col_loop].xlat_col_name,tmc_md_info->tbl_qual[tgsc_pos].col_qual[
        tgsc_col_pos].column_name)
       IF (tgsc_col_pos > 0
        AND (((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].in_src_ind=1)) OR (textlen(trim
        (tgsc_req->db_link))=0)) )
        IF ((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].nullable="Y"))
         IF (tgsc_col_ind > 0)
          SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
          SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
          SET tgsc_parse->stmt[tgsc_parse_cnt].str = " , "
         ENDIF
         SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
         SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
         SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" n",trim(cnvtstring(tgsc_col_loop)),
          " = nullind(t",tmc_md_info->tbl_qual[tgsc_pos].suffix,".",
          tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].column_name,")")
         SET tgsc_col_ind = 1
        ENDIF
        IF ((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].data_type IN ("VC", "C*")))
         IF (tgsc_col_ind > 0)
          SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
          SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
          SET tgsc_parse->stmt[tgsc_parse_cnt].str = " , "
         ENDIF
         SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
         SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
         SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" ts",trim(cnvtstring(tgsc_col_loop)),
          " = length(t",tmc_md_info->tbl_qual[tgsc_pos].suffix,".",
          tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].column_name,")")
         SET tgsc_col_ind = 1
        ELSE
         IF (daf_is_not_blank(tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].
          parent_entity_col))
          IF (tgsc_col_ind > 0)
           SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
           SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
           SET tgsc_parse->stmt[tgsc_parse_cnt].str = " , "
          ENDIF
          SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
          SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
          SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" ev",trim(cnvtstring(tgsc_col_loop)),
           " = evaluate_pe_name('",tmc_md_info->tbl_qual[tgsc_pos].table_name,"','",
           tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].column_name,"','",tmc_md_info->
           tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].parent_entity_col,"', t",tmc_md_info->tbl_qual[
           tgsc_pos].suffix,
           ".",tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].parent_entity_col,")")
          SET tgsc_col_ind = 1
         ENDIF
        ENDIF
       ENDIF
      ENDFOR
      SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" from  ",tgsc_info->qual[tgsc_loop].
       src_table_name," t",tmc_md_info->tbl_qual[tgsc_pos].suffix)
      SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      IF (daf_is_not_blank(dcvp_str->qual[drgsr_idx].cur_state_pkw))
       SET tgsc_parse->stmt[tgsc_parse_cnt].str = dcvp_str->qual[drgsr_idx].cur_state_pkw
      ELSE
       SET tgsc_parse->stmt[tgsc_parse_cnt].str = tgsc_info->qual[tgsc_loop].pk_where
      ENDIF
      IF (daf_is_not_blank(dcvp_str->qual[drgsr_idx].add_on_str))
       SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
       SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
       SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" and ",dcvp_str->qual[drgsr_idx].add_on_str
        )
      ENDIF
      IF (daf_is_not_blank(tmc_md_info->tbl_qual[tgsc_pos].filter_string))
       SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
       SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
       SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" and ",replace(replace(tmc_md_info->
          tbl_qual[tgsc_pos].filter_string,"<MERGE LINK>",tgsc_req->db_link,0),"<SUFFIX>",concat("t",
          tmc_md_info->tbl_qual[tgsc_pos].suffix),0))
      ENDIF
      IF (daf_is_not_blank(dcvp_str->qual[drgsr_idx].order_by_str))
       SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
       SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
       SET tgsc_parse->stmt[tgsc_parse_cnt].str = dcvp_str->qual[drgsr_idx].order_by_str
      ENDIF
      SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      SET tgsc_parse->stmt[tgsc_parse_cnt].str = " detail "
      SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
         tgsc_loop)),"].src_cnt = tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].src_cnt + 1 ")
      SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" stat = alterlist(tgsc_rep->row_qual[",trim(
        cnvtstring(tgsc_loop)),"].qual, tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
       "].src_cnt) ")
      SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
         tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].src_cnt].rowid = t",
       tmc_md_info->tbl_qual[tgsc_pos].suffix,".rowid")
      FOR (tgsc_col_loop = 1 TO tgsc_req->xlat_col_cnt)
       SET tgsc_col_pos = locateval(tgsc_col_pos,1,tmc_md_info->tbl_qual[tgsc_pos].col_cnt,tgsc_req->
        xlat_col_qual[tgsc_col_loop].xlat_col_name,tmc_md_info->tbl_qual[tgsc_pos].col_qual[
        tgsc_col_pos].column_name)
       IF (tgsc_col_pos > 0
        AND (((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].in_src_ind=1)) OR (textlen(trim
        (tgsc_req->db_link))=0)) )
        SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
        SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
        SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
           tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
         "].src_cnt].col_cnt = ",
         " tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
          cnvtstring(tgsc_loop)),"].src_cnt].col_cnt +1 ")
        SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
        SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
        SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" stat = alterlist(tgsc_rep->row_qual[",
         trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
         "].src_cnt].col_qual, ",
         " tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
          cnvtstring(tgsc_loop)),"].src_cnt].col_cnt)")
        SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
        SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
        SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
           tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
         "].src_cnt].col_qual[",
         "tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
          cnvtstring(tgsc_loop)),"].src_cnt].col_cnt].col_name = '",
         tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].column_name,"'")
        IF ((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].nullable="Y"))
         SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
         SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
         SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
            tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].src_cnt].col_qual[",
          "tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
           cnvtstring(tgsc_loop)),"].src_cnt].col_cnt].col_null_ind = n",
          trim(cnvtstring(tgsc_col_loop)))
        ENDIF
        IF ((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].data_type IN ("VC", "C*")))
         SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
         SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
         SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
            tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].src_cnt].col_qual[",
          "tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
           cnvtstring(tgsc_loop)),"].src_cnt].col_cnt].col_var_value = t",
          tmc_md_info->tbl_qual[tgsc_pos].suffix,".",tmc_md_info->tbl_qual[tgsc_pos].col_qual[
          tgsc_col_pos].column_name)
         SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
         SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
         SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
            tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].src_cnt].col_qual[",
          "tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
           cnvtstring(tgsc_loop)),"].src_cnt].col_cnt].col_tspace_cnt = ts",
          trim(cnvtstring(tgsc_col_loop))," - size(tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].src_cnt].col_qual[","tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].src_cnt].col_cnt].col_var_value)")
        ELSE
         SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
         SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
         SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
            tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
          "].src_cnt].col_qual[",
          "tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
           cnvtstring(tgsc_loop)),"].src_cnt].col_cnt].col_value = t",
          tmc_md_info->tbl_qual[tgsc_pos].suffix,".",tmc_md_info->tbl_qual[tgsc_pos].col_qual[
          tgsc_col_pos].column_name)
         IF ((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].idcd_ind=1)
          AND daf_is_blank(tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].constant_value)
          AND  NOT ((tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].exception_flg IN (1, 6)))
          AND (tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].execution_flag IN (0, 3, 4)))
          IF (daf_is_not_blank(tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].
           parent_entity_col))
           SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
           SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
           SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
              tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
            "].src_cnt].col_qual[",
            "tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
             cnvtstring(tgsc_loop)),"].src_cnt].col_cnt].col_xlat_name = ev",
            trim(cnvtstring(tgsc_col_loop)))
          ELSE
           SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
           SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
           SET tgsc_parse->stmt[tgsc_parse_cnt].str = concat(" tgsc_rep->row_qual[",trim(cnvtstring(
              tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),
            "].src_cnt].col_qual[",
            "tgsc_rep->row_qual[",trim(cnvtstring(tgsc_loop)),"].qual[tgsc_rep->row_qual[",trim(
             cnvtstring(tgsc_loop)),"].src_cnt].col_cnt].col_xlat_name = '",
            tmc_md_info->tbl_qual[tgsc_pos].col_qual[tgsc_col_pos].root_entity_name,"'")
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDFOR
      SET tgsc_parse_cnt = (tgsc_parse_cnt+ 1)
      SET stat = alterlist(tgsc_parse->stmt,tgsc_parse_cnt)
      SET tgsc_parse->stmt[tgsc_parse_cnt].str = dcvp_str->qual[drgsr_idx].with_str
      EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","TGSC_PARSE")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
#exit_program
 SET dm_err->eproc = "...Ending dm_rmc_get_source_rows"
 CALL final_disp_msg("dm_rmc_get_src")
END GO
