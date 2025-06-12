CREATE PROGRAM dm2_mig_utc_add_column:dba
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
 DECLARE dmuac_tname = vc WITH protect, noconstant("")
 DECLARE dmuac_cname = vc WITH protect, noconstant("")
 DECLARE dmuac_col_id = i4 WITH protect, noconstant(0)
 DECLARE dmuac_utc_cname = vc WITH protect, noconstant("")
 DECLARE dmuac_push_cmd = vc WITH protect, noconstant("")
 IF (check_logfile("dm2_mig_utc_add_column",".log","DM2_MIG_UTC_ADD_COLUMN LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning DM2_MIG_UTC_ADD_COLUMN"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Verifying and storing input parameters."
 SET dmuac_tname = trim(cnvtupper( $1),3)
 SET dmuac_cname = trim(cnvtupper( $2),3)
 SET dm_err->eproc = "Validating Table_name input parameter."
 IF (dmuac_tname=" ")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Table name not entered."
  SET dm_err->eproc = "Table Name Validation"
  SET dm_err->user_action = "Please specify a valid table name."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Validating Column_name input parameter."
 IF (dmuac_cname=" ")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Column name not entered."
  SET dm_err->eproc = "Column Name Validation"
  SET dm_err->user_action = "Please specify a valid column name."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Retrieve the column_id for the column name passed."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dba_tab_columns dtc
  WHERE dtc.owner=currdbuser
   AND dtc.table_name=dmuac_tname
   AND dtc.column_name=dmuac_cname
  DETAIL
   dmuac_col_id = dtc.column_id
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Invalid Table/Column name."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET dmuac_utc_cname = build("UTC_TMP1_",dmuac_col_id)
 SET dmuac_push_cmd = concat("RDB ASIS (^ALTER TABLE ",trim(dmuac_tname)," ADD ",trim(dmuac_utc_cname
   )," DATE NULL ^) GO")
 IF (dm2_push_cmd(dmuac_push_cmd,1)=0)
  GO TO exit_script
 ENDIF
 GO TO exit_script
#exit_script
 SET dm_err->eproc = "Ending DM2_MIG_UTC_ADD_COLUMN"
 CALL final_disp_msg("dm2_mig_utc_add_column")
END GO
