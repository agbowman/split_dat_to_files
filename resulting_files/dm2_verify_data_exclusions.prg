CREATE PROGRAM dm2_verify_data_exclusions
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
 IF ((validate(dmvd->rows_to_compare,- (1))=- (1))
  AND validate(dmvd->rows_to_compare,99)=99)
  FREE RECORD dmvd
  RECORD dmvd(
    1 db_link = vc
    1 owner = vc
    1 table_name = vc
    1 rows_to_compare = i4
    1 rows_to_compare_all = i4
    1 timeout = i4
    1 tbl_cnt = i4
    1 appl_id = vc
    1 ranges_per_compare = i4
    1 uow_threshold = f8
    1 tgt_to_src = i2
    1 compare_start_dt_tm = dq8
    1 final_row_ind = i2
    1 use_verify2_ind = i2
    1 tbls[*]
      2 owner = vc
      2 table_name = vc
      2 last_analyzed = dq8
      2 num_rows = f8
      2 num_distinct = f8
      2 monitoring = i2
      2 master_id = f8
      2 updt_ind = i2
      2 status = vc
      2 scui_ind = i2
      2 tgt_exists_ind = i2
      2 excl_flag = i2
      2 excl_reason = vc
      2 col_list = vc
      2 data_type_list = vc
      2 full_col_list = vc
      2 keyid_col_name = vc
      2 exclude_ind = i2
      2 src_object_id = f8
      2 max_src_keyid = f8
      2 range_start_keyid = f8
      2 range_beg_keyid = f8
      2 range_end_keyid = f8
      2 compare_keyid_min = f8
      2 compare_keyid_max = f8
      2 last_range_keyid_min = f8
      2 last_range_keyid_max = f8
      2 last_src_mod_dt_tm = dq8
      2 cur_src_mod_dt_tm = dq8
      2 beg_dt_tm = dq8
      2 mismatch_event_cnt = i4
      2 last_match_dt_tm = dq8
      2 last_compare_dt_tm = dq8
      2 last_compare_cnt = f8
      2 last_match_cnt = f8
      2 rows_to_compare = f8
      2 last_mm_beg_keyid = f8
      2 last_mm_end_keyid = f8
      2 mm_beg_keyid = f8
      2 mm_end_keyid = f8
      2 mm_cnt = i4
      2 last_mm_cnt = i4
      2 mm_cnt_scui = f8
      2 last_mm_cnt_scui = f8
      2 date_col_exists = i2
      2 date_col_name = vc
      2 last_mm_rowid = vc
      2 last_ui_str = vc
      2 mm_rowid_min = vc
      2 ui_str = vc
      2 mm_rowid_dt_tm_min = dq8
      2 mm_pull_key = i4
      2 compare_where = vc
      2 col_cnt = i4
      2 cols[*]
        3 col_name = vc
        3 data_type = vc
        3 data_value = vc
      2 mms[*]
        3 keyid = f8
        3 mm_rowid = vc
        3 mm_rowid_dt_tm = dq8
  )
  SET dmvd->db_link = "DM2NOTSET"
  SET dmvd->owner = "DM2NOTSET"
  SET dmvd->table_name = "DM2NOTSET"
  SET dmvd->rows_to_compare = 0
  SET dmvd->tbl_cnt = 0
  SET dmvd->uow_threshold = 50000
  SET dmvd->rows_to_compare_all = 2000000
  SET dmvd->appl_id = "DM2NOTSET"
  SET dmvd->timeout = 120
 ENDIF
 IF ( NOT (validate(dvdr_user_list->cnt)))
  FREE RECORD dvdr_user_list
  RECORD dvdr_user_list(
    1 change_ind = i2
    1 cnt = i4
    1 qual[*]
      2 user = vc
  )
 ENDIF
 IF ( NOT (validate(dvdr_rpt_dtl_info->owner)))
  FREE RECORD dvdr_rpt_dtl_info
  RECORD dvdr_rpt_dtl_info(
    1 owner = vc
    1 table_name = vc
    1 src_db_name = vc
    1 tgt_db_name = vc
    1 db_link = vc
    1 tbl_cnt = i4
    1 tbls_compared = i4
    1 tbls_matched = i4
    1 tbls_complete = i4
    1 comparing_cnt = i4
    1 yet_to_be_compared = i4
    1 yet_to_be_compared_pct = f8
    1 tbls_mm_cnt = i4
    1 tbls_mm_down_cnt = i4
    1 tbls_excluded = i4
    1 mtch_pct = f8
    1 mismatch_pct = f8
    1 downtime_mm_pct = f8
    1 complete_pct = f8
    1 num_owners = i4
    1 owners_list = vc
    1 comp_dt_max = dq8
    1 comp_dt_min = dq8
    1 final_row_dt_tm = dq8
    1 tbls[*]
      2 owner = vc
      2 table_name = vc
      2 master_id = f8
      2 status = vc
      2 last_analyzed = dq8
      2 monitoring = i2
      2 keyid_col_name = vc
      2 src_object_id = f8
      2 max_src_keyid = f8
      2 orig_start_key = f8
      2 last_comp_keyid_min = f8
      2 last_comp_keyid_max = f8
      2 last_mismatch_keyid_min = f8
      2 last_compare_dt_tm = dq8
      2 last_src_mod_dt_tm = dq8
      2 cur_src_mod_dt_tm = dq8
      2 last_rows_compared = f8
      2 last_rows_mismatched = f8
      2 last_match_dt_tm = dq8
      2 mismatch_event_cnt = i4
      2 total_rows_compared = f8
      2 key_range_remaining = f8
      2 excl_reason = vc
  )
  SET dvdr_rpt_dtl_info->owner = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->table_name = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->db_link = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->src_db_name = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->tgt_db_name = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->tbls_compared = 0
  SET dvdr_rpt_dtl_info->tbls_matched = 0
  SET dvdr_rpt_dtl_info->tbls_excluded = 0
  SET dvdr_rpt_dtl_info->num_owners = 0
  SET dvdr_rpt_dtl_info->owners_list = "DM2NOTSET"
 ENDIF
 DECLARE dvdr_uow_status = vc WITH protect, constant("NOCOMP-UOW")
 DECLARE dvdr_nocomp_size = vc WITH protect, constant("NOCOMP-SIZE")
 DECLARE dvdr_exclude = vc WITH protect, constant("EXCLUDE")
 DECLARE dvdr_comparing = vc WITH protect, constant("COMPARING")
 DECLARE dvdr_match = vc WITH protect, constant("MATCH")
 DECLARE dvdr_error = vc WITH protect, constant("ERROR")
 DECLARE dvdr_mismatch = vc WITH protect, constant("MISMATCH")
 DECLARE dvdr_ready = vc WITH protect, constant("READY")
 DECLARE dvdr_complete = vc WITH protect, constant("COMPLETE")
 DECLARE dvdr_progressupdate = vc WITH protect, constant("PROGRESSUPDATE")
 DECLARE dvdr_statusupdate = vc WITH protect, constant("STATUSUPDATE")
 DECLARE dvdr_get_user_connect_info(dguci_is_mig_flag=i2) = i2
 DECLARE dvdr_get_selected_user_list(dgsul_user=vc) = i2
 DECLARE dvdr_get_data_verification_info(dgdvi_is_mig=i2) = i2
 DECLARE dvdr_populate_table_list(dptl_is_mig_flag=i2) = i2
 DECLARE dvdr_get_tblmod(dgt_mode=vc) = i2
 DECLARE dvdr_setup_tables_for_compare(null) = i2
 DECLARE dvdr_write_exclusion_rows(null) = i2
 DECLARE dvdr_write_dminfo_rows(null) = i2
 DECLARE dvdr_get_verify_data_rpt_info(dgvdri_return=i2,dgvdri_quit=i2(ref)) = i2
 DECLARE dvdr_get_vdata_rpt_env_info(null) = i2
 DECLARE dvdr_load_rpt_record(null) = i2
 DECLARE dvdr_get_cur_max_src_keyid(null) = i2
 DECLARE dvdr_appid_work(daw_just_check=i2,daw_appl=vc,daw_continue=i2(ref)) = i2
 DECLARE dvdr_load_master(dlm_masterid) = i2
 DECLARE dvdr_check_stop(dcs_stop=i2(ref)) = i2
 DECLARE dvdr_get_table(dgt_masterid_out=f8(ref)) = i2
 DECLARE dvdr_cleanup_stranded(null) = i2
 DECLARE dvdr_get_verify2(null) = i2
 DECLARE dvdr_get_old_lag(dgol_lag_out=dq8(ref)) = i2
 DECLARE dvdr_parse_list(dpl_type=vc,dpl_delim=vc,dpl_str_in=vc,dpl_tbl_ndx=i2) = i2
 SUBROUTINE dvdr_parse_list(dpl_type,dpl_delim,dpl_str_in,dpl_tbl_ndx)
   IF ((dm_err->debug_flag > 0))
    CALL echo(dpl_type)
    CALL echo(dpl_str_in)
   ENDIF
   SET dpl_start_pt = 0
   SET dpl_end_pt = 0
   SET dpl_rep_cnt = 0
   IF (dpl_type="COLUMN")
    SET dmvd->tbls[dpl_tbl_ndx].col_cnt = 0
    SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,0)
   ENDIF
   IF (findstring(dpl_delim,dpl_str_in,1,0)=0)
    IF (dpl_type="COLUMN")
     SET dmvd->tbls[dpl_tbl_ndx].col_cnt = (dmvd->tbls[dpl_tbl_ndx].col_cnt+ 1)
     SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,1)
     SET dmvd->tbls[dpl_tbl_ndx].cols[1].col_name = dpl_str_in
    ELSEIF (dpl_type="DATATYPE")
     SET dmvd->tbls[dpl_tbl_ndx].cols[1].data_type = dpl_str_in
    ELSE
     SET dmvd->tbls[dpl_tbl_ndx].cols[1].data_value = dpl_str_in
    ENDIF
   ELSE
    IF (size(dpl_delim) > 1)
     SET dpl_start_pt = (size(dpl_delim)+ 1)
    ELSE
     SET dpl_start_pt = size(dpl_delim)
    ENDIF
    SET dpl_end_pt = 1
    WHILE (dpl_end_pt > 0)
      SET dpl_rep_cnt = (dpl_rep_cnt+ 1)
      SET dpl_end_pt = findstring(dpl_delim,dpl_str_in,dpl_start_pt,0)
      IF (dpl_end_pt=0
       AND dpl_type IN ("COLUMN", "DATATYPE"))
       IF (dpl_type="COLUMN")
        SET dmvd->tbls[dpl_tbl_ndx].col_cnt = (dmvd->tbls[dpl_tbl_ndx].col_cnt+ 1)
        SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,dpl_rep_cnt)
        SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].col_name = substring(dpl_start_pt,(textlen(
          dpl_str_in) - (dpl_start_pt - size(dpl_delim))),dpl_str_in)
       ELSEIF (dpl_type="DATATYPE")
        SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].data_type = substring(dpl_start_pt,(textlen(
          dpl_str_in) - (dpl_start_pt - size(dpl_delim))),dpl_str_in)
       ENDIF
      ELSE
       IF (dpl_end_pt > 0)
        IF (dpl_type="COLUMN")
         SET dmvd->tbls[dpl_tbl_ndx].col_cnt = (dmvd->tbls[dpl_tbl_ndx].col_cnt+ 1)
         SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,dpl_rep_cnt)
         SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].col_name = substring(dpl_start_pt,(dpl_end_pt
           - dpl_start_pt),dpl_str_in)
        ELSEIF (dpl_type="DATATYPE")
         SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].data_type = substring(dpl_start_pt,(dpl_end_pt
           - dpl_start_pt),dpl_str_in)
        ELSE
         SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].data_value = notrim(substring(dpl_start_pt,(
           dpl_end_pt - dpl_start_pt),dpl_str_in))
        ENDIF
       ENDIF
      ENDIF
      SET dpl_start_pt = (dpl_end_pt+ size(dpl_delim))
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE dvdr_check_stop(dcs_stop)
   SET dcs_stop = 0
   SET dm_err->eproc = "Check if compare has been marked to stop."
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_VDATA_INFO"
     AND d.info_name="DM2_VDATA_STOP_COMPARE"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcs_stop = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_cleanup_stranded(null)
   DECLARE dcs_status_ret = vc WITH protect, noconstant("")
   FREE RECORD dcs_appid
   RECORD dcs_appid(
     1 appid_cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Gather appids for rows in COMPARING status"
   SELECT DISTINCT INTO "nl:"
    d.appl_ident
    FROM dm_vdata_master d
    WHERE d.compare_status=dvdr_comparing
    DETAIL
     dcs_appid->appid_cnt = (dcs_appid->appid_cnt+ 1), stat = alterlist(dcs_appid->qual,dcs_appid->
      appid_cnt), dcs_appid->qual[dcs_appid->appid_cnt].appl_id = d.appl_ident
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    RETURN(1)
   ENDIF
   FOR (dcs_cnt = 1 TO dcs_appid->appid_cnt)
    SET dcs_status_ret = dm2_get_appl_status(dcs_appid->qual[dcs_cnt].appl_id)
    CASE (dcs_status_ret)
     OF "A":
      SET dm_err->eproc = concat(dcs_appid->qual[dcs_cnt].appl_id," is currently Active.")
      CALL disp_msg("",dm_err->logfile,10)
      RETURN(1)
     OF "I":
      SET dm_err->eproc = concat(dcs_appid->qual[dcs_cnt].appl_id," is currently Inactive.")
      CALL disp_msg("",dm_err->logfile,10)
      SET dm_err->eproc = "Set status to error due to expired appl_id."
      UPDATE  FROM dm_vdata_master d
       SET d.compare_status = dvdr_error, d.message_txt = concat(dcs_appid->qual[dcs_cnt].appl_id,
         " is currently Inactive.")
       WHERE (d.appl_ident=dcs_appid->qual[dcs_cnt].appl_id)
        AND d.compare_status=dvdr_comparing
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      COMMIT
     OF "E":
      RETURN(0)
    ENDCASE
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_table(dgt_masterid_out)
   DECLARE dgt_have_table = i2 WITH protect, noconstant(0)
   DECLARE dgt_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgt_compare_hold = f8 WITH protect, noconstant(cnvtdatetime("01-JAN-1899"))
   SET dgt_masterid_out = 0
   WHILE (dgt_have_table=0)
     SET dgt_cnt = (dgt_cnt+ 1)
     SET dm_err->eproc = "Find table to compare."
     SELECT INTO "nl:"
      FROM dm_vdata_master d
      WHERE  NOT (d.compare_status IN (dvdr_exclude, dvdr_uow_status, dvdr_comparing, dvdr_complete,
      dvdr_nocomp_size))
       AND d.updt_dt_tm > cnvtdatetime(dgt_compare_hold)
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_vdata_exclude_dtl e
       WHERE d.dm_vdata_master_id=e.dm_vdata_master_id)))
      ORDER BY d.updt_dt_tm, d.owner_name, d.table_name
      DETAIL
       dgt_masterid_out = d.dm_vdata_master_id, dgt_compare_hold = d.last_compare_dt_tm
      WITH maxqual(d,1)
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dgt_masterid_out = 0
      RETURN(1)
     ENDIF
     IF (dgt_masterid_out > 0)
      SET dm_err->eproc = "Set candidate table status to COMPARING."
      UPDATE  FROM dm_vdata_master d
       SET d.compare_status = dvdr_comparing, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
        .appl_ident = currdbhandle
       WHERE d.dm_vdata_master_id=dgt_masterid_out
        AND d.compare_status != "COMPARING"
       WITH nocounter
      ;end update
      IF (curqual > 0)
       SET dgt_have_table = 1
      ELSE
       SET dgt_masterid_out = 0
      ENDIF
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      COMMIT
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_old_lag(dgol_lag_out)
   SET dgol_lag_out = cnvtdatetime("01-JAN-1900")
   SET dm_err->eproc = "Obtain delivery lag time from Admin"
   SELECT INTO "nl:"
    mintime = min(d.info_date)
    FROM dm2_admin_dm_info d
    WHERE d.info_domain="DM2MIG_DELDATA"
     AND d.info_name="DELIV*LAG"
    DETAIL
     dgol_lag_out = cnvtdatetime(mintime)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_user_connect_info(dguci_is_mig_flag)
   SET dm_err->eproc = "Getting user connection data for source and target"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   IF (dguci_is_mig_flag=0)
    SET dm_err->eproc = "Getting Source Connect Information."
    SET dm2_install_schema->dbase_name = '"SOURCE"'
    SET dm2_install_schema->u_name = "V500"
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_force_connect_string = 0
    SET dm2_install_schema->src_dbase_name = trim(cnvtupper(currdbname))
    SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
    SET dm_err->eproc = "Getting Target Connect Information."
    SET dm2_install_schema->dbase_name = '"TARGET"'
    SET dm2_install_schema->u_name = cnvtupper(currdbuser)
    EXECUTE dm2_connect_to_dbase "PC"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->target_dbase_name = trim(cnvtupper(currdbname))
    IF (cnvtupper(currdbuser)="V500")
     SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
    ENDIF
   ELSE
    SET dm2_install_schema->src_dbase_name = dmr_mig_data->src_db_name
    SET dm2_install_schema->src_v500_p_word = dmr_mig_data->src_v500_pwd
    SET dm2_install_schema->src_v500_connect_str = dmr_mig_data->src_v500_cnct_str
    SET dm2_install_schema->target_dbase_name = dmr_mig_data->tgt_db_name
    IF (cnvtupper(currdbuser)="V500")
     SET dm2_install_schema->v500_p_word = dmr_mig_data->tgt_v500_pwd
     SET dm2_install_schema->v500_connect_str = dmr_mig_data->tgt_v500_cnct_str
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_data_verification_info(dgdvi_is_mig)
   DECLARE dgdvi_verify_data_setup_cont = i2 WITH protect, noconstant(1)
   DECLARE dgdvi_error = i2 WITH protect, noconstant(0)
   DECLARE dgdvi_default = vc WITH protect, noconstant("C")
   DECLARE dgdvi_dblink = vc WITH protect, noconstant("REF_DATA_LINK")
   DECLARE dgdvi_owner = vc WITH protect, noconstant(currdbuser)
   DECLARE dgdvi_table_name = vc WITH protect, noconstant("*")
   DECLARE dgdvi_num_rows = i4 WITH protect, noconstant(500000)
   SET dm_err->eproc = "Collecting data verification setup information"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Setting default values for data verification variables"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name IN ("DM2_VDATA_DBLINK", "DM2_VDATA_OWNER", "DM2_VDATA_TABLE_NAME",
    "DM2_VDATA_NUMROWS", "DM2_VDATA_NUMROWS_ALL",
    "DM2_VDATA_TIMEOUT", "DM2_VDATA_TGT_TO_SRC", "DM2_VDATA_UOW_THRESHOLD")
    DETAIL
     IF (di.info_name="DM2_VDATA_DBLINK"
      AND (dmvd->db_link="DM2NOTSET"))
      dgdvi_dblink = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_OWNER"
      AND (dmvd->owner="DM2NOTSET"))
      dgdvi_owner = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_TABLE_NAME"
      AND (dmvd->table_name="DM2NOTSET"))
      dgdvi_table_name = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_NUMROWS"
      AND (dmvd->rows_to_compare=0))
      dgdvi_num_rows = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_NUMROWS_ALL")
      dmvd->rows_to_compare_all = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_UOW_THRESHOLD")
      dmvd->uow_threshold = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_TIMEOUT")
      dmvd->timeout = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_TGT_TO_SRC")
      dmvd->tgt_to_src = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Validating default DB LINK"
   SELECT INTO "nl:"
    FROM dba_db_links ddl
    WHERE ddl.db_link=concat(trim(dgdvi_dblink),".WORLD")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dgdvi_dblink = ""
   ENDIF
   WHILE (dgdvi_verify_data_setup_cont=1)
     SET width = 132
     IF ((dm_err->debug_flag != 511))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Setup Data Verification")
     IF (dgdvi_is_mig=0)
      CALL text(5,2,"Source DB Link: ")
      CALL text(7,2,"Owner: ")
      CALL text(9,2,"Table Name: ")
      IF (dgdvi_error=1)
       CALL text(13,2,concat("The DB Link given (",dmvd->db_link,
         ".WORLD) was not found. Please modify."))
       SET dgdvi_default = "M"
       SET dgdvi_error = 0
      ENDIF
     ENDIF
     CALL text(11,2,"Rows to Compare: ")
     CALL text(15,2,"(C)ontinue, (M)odify, (Q)uit: ")
     IF (dgdvi_is_mig=0)
      CALL accept(5,30,"P(30);cu",dgdvi_dblink
       WHERE  NOT (trim(curaccept)=""))
      SET dgdvi_dblink = build(curaccept)
      SET accept = nopatcheck
      CALL accept(7,30,"P(30);cu",dgdvi_owner
       WHERE  NOT (trim(curaccept)=""))
      SET dgdvi_owner = build(curaccept)
      CALL accept(9,30,"P(30);cu",dgdvi_table_name
       WHERE  NOT (trim(curaccept)=""))
      SET dgdvi_table_name = build(curaccept)
     ENDIF
     CALL accept(11,30,"99999999;",dgdvi_num_rows
      WHERE curaccept > 0)
     SET dgdvi_num_rows = curaccept
     CALL accept(15,33,"A;CU",dgdvi_default
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "C":
       SET dgdvi_verify_data_setup_cont = 0
       SET dmvd->db_link = dgdvi_dblink
       SET dmvd->owner = dgdvi_owner
       SET dmvd->table_name = dgdvi_table_name
       SET dmvd->rows_to_compare = dgdvi_num_rows
       SET dm_err->eproc = "Checking to see if db_link provided is valid"
       SELECT INTO "nl:"
        FROM dba_db_links ddl
        WHERE ddl.db_link=concat(cnvtupper(dmvd->db_link),".WORLD")
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        SET dm_err->err_ind = 1
        RETURN(0)
       ELSEIF (curqual=0)
        SET dgdvi_error = 1
        SET dgdvi_verify_data_setup_cont = 1
       ENDIF
      OF "Q":
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "User Quit Process"
       RETURN(0)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_selected_user_list(dgsul_user)
   SET dm_err->eproc = "Retrieving list of users from matching selection criteria."
   SELECT INTO "nl:"
    user = trim(substring(1,30,au.username))
    FROM all_users au
    WHERE  NOT (au.username IN ("CTXSYS", "DBSNMP", "LBACSYS", "MDDATA", "MDSYS",
    "DMSYS", "OLAPSYS", "ORDPLUGINS", "ORDSYS", "OUTLN",
    "SI_INFORMTN_SCHEMA", "SYS", "SYSMAN", "SYSTEM"))
     AND au.username=patstring(trim(dgsul_user))
    ORDER BY user
    HEAD REPORT
     dvdr_user_list->cnt = 0, stat = alterlist(dvdr_user_list->qual,0), dvdr_user_list->change_ind =
     0
    DETAIL
     dvdr_user_list->cnt = (dvdr_user_list->cnt+ 1), stat = alterlist(dvdr_user_list->qual,
      dvdr_user_list->cnt), dvdr_user_list->qual[dvdr_user_list->cnt].user = user
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_save_user_list(dsul_is_mig_flag)
   DECLARE dsul_user_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsul_user_list = vc WITH protect, noconstant("")
   DECLARE dsul_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Writing dm_info row to save user list"
   IF (dsul_is_mig_flag=1)
    SET dsul_user_cnt = dmr_user_list->cnt
    SET dsul_user_list = dmr_user_list->qual[1].user
    FOR (dsul_cnt = 2 TO dmr_user_list->cnt)
      SET dsul_user_list = concat(dsul_user_list,",",dmr_user_list->qual[dsul_cnt].user)
    ENDFOR
   ELSE
    SET dsul_user_cnt = dvdr_user_list->cnt
    SET dsul_user_list = dvdr_user_list->qual[1].user
    FOR (dsul_cnt = 2 TO dvdr_user_list->cnt)
      SET dsul_user_list = concat(dsul_user_list,", ",dvdr_user_list->qual[dsul_cnt].user)
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_USERLIST"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_USERLIST", di.info_number =
      dsul_user_cnt,
      di.info_char = dsul_user_list
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = dsul_user_cnt, di.info_char = dsul_user_list
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_USERLIST"
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_perform_vdat_cleanup(null)
   SET dm_err->eproc = "Deleting rows from data verification tables"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Deleting rows from Master Table"
   DELETE  FROM dm_vdata_master dvm
    WHERE dvm.dm_vdata_master_id > 0
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Deleting rows from Exclude Detail Table"
   DELETE  FROM dm_vdata_exclude_dtl dved
    WHERE dved.dm_vdata_exclude_dtl_id > 0
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Deleting rows from Mismatch Table"
   DELETE  FROM dm_vdata_mismatch dvm
    WHERE dvm.dm_vdata_mismatch_id > 0
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_populate_table_list(dptl_is_mig_flag)
   DECLARE dptl_master_id_is_null = i2 WITH protect, noconstant(0)
   DECLARE dptl_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dptl_tbl_ndx = i4 WITH protect, noconstant(0)
   DECLARE dptl_excl_clause = vc WITH protect, noconstant("")
   DECLARE dptl_tbl = vc WITH protect, noconstant("")
   DECLARE dptl_owner = vc WITH protect, noconstant("")
   DECLARE dptl_mngd_tables = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Populating dm2_fill_sch_except record structure"
   IF ( NOT (dm2_fill_sch_except("LOCAL")))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt > 0))
    SET dm_err->eproc = "Generating table exclusion list from dm2_sch_except record structure."
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(dm2_sch_except->tcnt))
     DETAIL
      IF (d.seq=1)
       dptl_excl_clause = concat("ao.object_name NOT IN ('",dm2_sch_except->tbl[d.seq].tbl_name,"'")
      ELSE
       dptl_excl_clause = concat(dptl_excl_clause,",'",dm2_sch_except->tbl[d.seq].tbl_name,"'")
      ENDIF
     FOOT REPORT
      dptl_excl_clause = concat(dptl_excl_clause,")")
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc))
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ENDIF
   SET dptl_mngd_tables = ""
   IF (dmr_load_managed_tables(dptl_mngd_tables)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Populating the dmvd record structure with the list of tables to be verified"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    nullind_dvm_dm_vdata_master_id = nullind(dvm.dm_vdata_master_id)
    FROM (value(concat("DBA_OBJECTS@",dmvd->db_link)) ao),
     dm_vdata_master dvm
    WHERE ao.object_type="TABLE"
     AND ao.owner=patstring(cnvtupper(dmvd->owner))
     AND ao.object_name=patstring(dmvd->table_name)
     AND parser(dptl_excl_clause)
     AND parser(concat(" ao.object_name not in (",dptl_mngd_tables,")"))
     AND outerjoin(ao.owner)=dvm.owner_name
     AND outerjoin(ao.object_name)=dvm.table_name
    ORDER BY ao.owner, ao.object_name
    HEAD REPORT
     dmvd->tbl_cnt = 0, stat = alterlist(dmvd->tbls,0), dptl_tbl_cnt = 0
    DETAIL
     dptl_tbl_cnt = (dptl_tbl_cnt+ 1)
     IF (mod(dptl_tbl_cnt,500)=1)
      stat = alterlist(dmvd->tbls,(dptl_tbl_cnt+ 499))
     ENDIF
     dmvd->tbls[dptl_tbl_cnt].owner = ao.owner, dmvd->tbls[dptl_tbl_cnt].table_name = ao.object_name,
     dmvd->tbls[dptl_tbl_cnt].master_id = evaluate(nullind_dvm_dm_vdata_master_id,0,dvm
      .dm_vdata_master_id,0),
     dmvd->tbls[dptl_tbl_cnt].src_object_id = ao.object_id, dmvd->tbls[dptl_tbl_cnt].date_col_name =
     "DM2NOTSET"
     IF (textlen(cnvtstring(dmvd->tbls[dptl_tbl_cnt].src_object_id)) > 13)
      dmvd->tbls[dptl_tbl_cnt].excl_flag = 40, dmvd->tbls[dptl_tbl_cnt].excl_reason =
      "Length of Object ID exceeds limit"
     ENDIF
     IF ((dmvd->tbls[dptl_tbl_cnt].table_name=patstring("DM_VDAT*")))
      dmvd->tbls[dptl_tbl_cnt].excl_flag = 70, dmvd->tbls[dptl_tbl_cnt].excl_reason =
      "Table used for Compare Process. Not eligible for comparison"
     ENDIF
    FOOT REPORT
     dmvd->tbl_cnt = dptl_tbl_cnt, stat = alterlist(dmvd->tbls,dmvd->tbl_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ELSEIF ((dmvd->tbl_cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No valid tables returned!"
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking if tables being compared exist in TARGET."
   SELECT INTO "nl:"
    FROM dba_tables d
    DETAIL
     IF (locateval(dptl_tbl_ndx,1,dmvd->tbl_cnt,d.owner,dmvd->tbls[dptl_tbl_ndx].owner,
      d.table_name,dmvd->tbls[dptl_tbl_ndx].table_name) > 0)
      dmvd->tbls[dptl_tbl_ndx].tgt_exists_ind = 1
      IF (d.temporary="Y")
       dmvd->tbls[dptl_tbl_ndx].excl_flag = 60, dmvd->tbls[dptl_tbl_ndx].excl_reason =
       "Temporary Table: Not Verified"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (dptl_is_mig_flag=1)
    SET dm_err->eproc = "Exclude from compare if excluded from migration."
    SELECT INTO "nl:"
     FROM (value(concat("DM_INFO@",dmvd->db_link)) di)
     WHERE ((di.info_domain="DM2_MIG_EXCL"
      AND di.info_number <= 20) OR (((di.info_domain="DM2_MIG_NONGG_REP") OR (di.info_domain=
     "DM2_MIG_ALLOW_NOPK"
      AND di.info_number=0)) ))
     DETAIL
      dptl_tbl = trim(substring((findstring(".",di.info_name,1,1)+ 1),(textlen(trim(di.info_name)) -
        findstring(".",di.info_name,1,1)),di.info_name),3), dptl_owner = substring(1,(findstring(".",
        di.info_name,1,1) - 1),di.info_name)
      IF (locateval(dptl_tbl_ndx,1,dmvd->tbl_cnt,dptl_owner,dmvd->tbls[dptl_tbl_ndx].owner,
       dptl_tbl,dmvd->tbls[dptl_tbl_ndx].table_name) > 0)
       IF (di.info_domain="DM2_MIG_NONGG_REP")
        dmvd->tbls[dptl_tbl_ndx].excl_flag = 90, dmvd->tbls[dptl_tbl_ndx].excl_reason =
        "DB Migration - Manual Compare"
       ELSEIF (di.info_domain="DM2_MIG_ALLOW_NOPK")
        dmvd->tbls[dptl_tbl_ndx].excl_flag = 90, dmvd->tbls[dptl_tbl_ndx].excl_reason =
        "DB Migration - Compare Exclusion"
       ELSE
        IF ((dmvd->tbls[dptl_tbl_ndx].excl_flag=0))
         dmvd->tbls[dptl_tbl_ndx].excl_flag = di.info_number
         CASE (di.info_number)
          OF 15:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Manual Exclusion",dmvd->tbls[
           dptl_tbl_ndx].excl_flag = 30
          OF 16:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Materialized View Exclusion"
          OF 17:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Materialized View Exclusion"
          OF 18:
           dmvd->tbls[dptl_tbl_ndx].excl_reason =
           "DB Migration - Table contains column names which are duplicated."
          OF 19:
           dmvd->tbls[dptl_tbl_ndx].excl_reason =
           "DB Migration - Table contains column names which have same name as oracle data type."
          OF 20:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Invalid Data Type Exclusion"
         ENDCASE
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_setup_tables_for_compare(null)
   DECLARE dstfc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dstfc_num = i4 WITH protect, noconstant(0)
   DECLARE dstfc_pos = i4 WITH protect, noconstant(0)
   DECLARE dstfc_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dstfc_full_col_list = vc WITH protect, noconstant("")
   DECLARE dstfc_data_type_list = vc WITH protect, noconstant("")
   DECLARE dstfc_full_tname = vc WITH protect, noconstant("")
   DECLARE dstfc_ndx = i4 WITH protect, noconstant(0)
   DECLARE dstfc_lag_time = dq8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = "Setting up tables for compare"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   FREE RECORD dstfc_index
   RECORD dstfc_index(
     1 ind_cnt = i4
     1 qual[*]
       2 table_name = vc
       2 owner = vc
       2 index_name = vc
   )
   FREE RECORD dstfc_col_list
   RECORD dstfc_col_list(
     1 col_cnt = i4
     1 qual[*]
       2 owner_name = vc
       2 table_name = vc
       2 col_name = vc
   )
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->src_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dmr_load_di_filter(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain single column unique indexes"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    x = concat(trim(dtc.owner),".",trim(dtc.table_name)), dtc.column_name
    FROM dba_tab_columns dtc,
     dba_ind_columns dic
    WHERE dtc.table_name=dic.table_name
     AND dtc.column_name=dic.column_name
     AND dtc.owner=dic.table_owner
     AND dtc.table_name=patstring(dmvd->table_name)
     AND dic.table_name=patstring(dmvd->table_name)
     AND list(dic.index_name,dic.table_owner) IN (
    (SELECT
     dic2.index_name, dic2.table_owner
     FROM dba_ind_columns dic2,
      dba_indexes di
     WHERE dic2.index_name=di.index_name
      AND di.uniqueness="UNIQUE"
      AND dic2.index_owner=di.owner
      AND expand(dstfc_num,1,dvdr_user_list->cnt,dic2.table_owner,dvdr_user_list->qual[dstfc_num].
      user)
     GROUP BY dic2.index_name, dic2.table_owner
     HAVING count(dic2.column_name)=1))
    ORDER BY x, dtc.column_name
    DETAIL
     dstfc_pos = locateval(dstfc_cnt,1,dmvd->tbl_cnt,dtc.owner,dmvd->tbls[dstfc_cnt].owner,
      dtc.table_name,dmvd->tbls[dstfc_cnt].table_name)
     IF (dstfc_pos > 0)
      IF ((dmvd->tbls[dstfc_pos].scui_ind != 1))
       IF (trim(dtc.data_type) IN ("NUMBER", "FLOAT"))
        dmvd->tbls[dstfc_pos].scui_ind = 1
       ELSE
        dmvd->tbls[dstfc_pos].scui_ind = 3
       ENDIF
       dmvd->tbls[dstfc_pos].keyid_col_name = dtc.column_name, dmvd->tbls[dstfc_pos].col_list = dmvd
       ->tbls[dstfc_pos].keyid_col_name, dmvd->tbls[dstfc_pos].data_type_list = trim(dtc.data_type)
      ENDIF
     ENDIF
    WITH nocounter, noheading
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain multiple column unique indexes with highest distinct column value"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    x = concat(trim(dtc.owner),".",trim(dtc.table_name)), dtc.column_name, nd_null = nullind(dtc
     .num_distinct)
    FROM dm_dba_columns_actual_stats dtc,
     dba_ind_columns dic
    WHERE dtc.table_name=dic.table_name
     AND dtc.column_name=dic.column_name
     AND dtc.owner=dic.table_owner
     AND dic.column_position=1
     AND dtc.table_name=patstring(dmvd->table_name)
     AND dic.table_name=patstring(dmvd->table_name)
     AND list(dic.index_name,dic.table_owner) IN (
    (SELECT
     dic2.index_name, dic2.table_owner
     FROM dba_ind_columns dic2,
      dba_indexes di
     WHERE dic2.index_name=di.index_name
      AND di.uniqueness="UNIQUE"
      AND dic2.index_owner=di.owner
      AND expand(dstfc_num,1,dvdr_user_list->cnt,dic2.table_owner,dvdr_user_list->qual[dstfc_num].
      user)
     GROUP BY dic2.index_name, dic2.table_owner
     HAVING count(dic2.column_name) > 1))
    ORDER BY x, dtc.num_distinct DESC, dic.index_name,
     dic.column_position
    HEAD x
     dstfc_pos = locateval(dstfc_cnt,1,dmvd->tbl_cnt,dtc.owner,dmvd->tbls[dstfc_cnt].owner,
      dtc.table_name,dmvd->tbls[dstfc_cnt].table_name)
     IF (dstfc_pos > 0)
      IF ((dmvd->tbls[dstfc_pos].scui_ind=0))
       dmvd->tbls[dstfc_pos].num_distinct = evaluate(nd_null,1,- (1),dtc.num_distinct)
       IF (dtc.data_type IN ("NUMBER", "FLOAT"))
        dmvd->tbls[dstfc_pos].scui_ind = 2, dmvd->tbls[dstfc_pos].keyid_col_name = dtc.column_name
       ELSE
        dmvd->tbls[dstfc_pos].keyid_col_name = dtc.column_name, dmvd->tbls[dstfc_pos].scui_ind = 3
       ENDIF
       dstfc_index->ind_cnt = (dstfc_index->ind_cnt+ 1)
       IF (mod(dstfc_index->ind_cnt,100)=1)
        stat = alterlist(dstfc_index->qual,(dstfc_index->ind_cnt+ 99))
       ENDIF
       dstfc_index->qual[dstfc_index->ind_cnt].owner = dtc.owner, dstfc_index->qual[dstfc_index->
       ind_cnt].index_name = dic.index_name, dstfc_index->qual[dstfc_index->ind_cnt].table_name = dic
       .table_name
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dstfc_index->qual,dstfc_index->ind_cnt)
    WITH nocounter, noheading, orahint("ALL_ROWS"),
     orahintcbo("ALL_ROWS")
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dstfc_index)
   ENDIF
   SET dm_err->eproc = "Obtain column list for unique indexes with highest distinct value"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    x = concat(dic.table_owner,".",dic.table_name)
    FROM dba_ind_columns dic,
     dba_tab_columns dtc
    WHERE expand(dstfc_num,1,dvdr_user_list->cnt,dic.table_owner,dvdr_user_list->qual[dstfc_num].user
     )
     AND dic.table_owner=dtc.owner
     AND dic.table_name=dtc.table_name
     AND dtc.table_name=patstring(dmvd->table_name)
     AND dic.table_name=patstring(dmvd->table_name)
     AND dic.column_name=dtc.column_name
    ORDER BY x, dic.index_name, dic.column_position
    DETAIL
     dstfc_pos = locateval(dstfc_cnt,1,dstfc_index->ind_cnt,dic.table_owner,dstfc_index->qual[
      dstfc_cnt].owner,
      dic.table_name,dstfc_index->qual[dstfc_cnt].table_name,dic.index_name,dstfc_index->qual[
      dstfc_cnt].index_name)
     IF (dstfc_pos > 0)
      dstfc_pos2 = locateval(dstfc_cnt,1,dmvd->tbl_cnt,dic.table_owner,dmvd->tbls[dstfc_cnt].owner,
       dic.table_name,dmvd->tbls[dstfc_cnt].table_name)
      IF (dstfc_pos2 > 0)
       IF ((dmvd->tbls[dstfc_pos2].scui_ind IN (2, 3)))
        IF ((dmvd->tbls[dstfc_pos2].col_list=""))
         dmvd->tbls[dstfc_pos2].col_list = dic.column_name, dmvd->tbls[dstfc_pos2].data_type_list =
         dtc.data_type
        ELSE
         dmvd->tbls[dstfc_pos2].col_list = concat(dmvd->tbls[dstfc_pos2].col_list,",",dic.column_name
          ), dmvd->tbls[dstfc_pos2].data_type_list = concat(dmvd->tbls[dstfc_pos2].data_type_list,",",
          dtc.data_type)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter, noheading
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Generating column lists for all tables"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_tab_columns dtc,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dtc
     WHERE (dtc.owner=dmvd->tbls[d.seq].owner)
      AND (dtc.table_name=dmvd->tbls[d.seq].table_name)
      AND  NOT (dtc.data_type IN ("LONG*", "*LOB*", "RAW")))
    ORDER BY dtc.owner, dtc.table_name
    HEAD dtc.owner
     dstfc_full_col_list = ""
    HEAD dtc.table_name
     dstfc_full_col_list = "", dstfc_data_type_list = ""
    DETAIL
     IF ((dmvd->tbls[d.seq].scui_ind=0)
      AND (dmvd->tbls[d.seq].keyid_col_name=""))
      dmvd->tbls[d.seq].keyid_col_name = dtc.column_name
     ENDIF
     IF (dstfc_full_col_list="")
      dstfc_full_col_list = dtc.column_name, dstfc_data_type_list = dtc.data_type
     ELSE
      dstfc_full_col_list = concat(dstfc_full_col_list,",",dtc.column_name), dstfc_data_type_list =
      concat(dstfc_data_type_list,",",dtc.data_type)
     ENDIF
     IF (dtc.column_name="UPDT_DT_TM"
      AND dtc.data_type="DATE")
      dmvd->tbls[d.seq].date_col_exists = 1, dmvd->tbls[d.seq].date_col_name = "UPDT_DT_TM"
     ENDIF
     IF (dtc.data_type="DATE")
      dstfc_col_list->col_cnt = (dstfc_col_list->col_cnt+ 1), stat = alterlist(dstfc_col_list->qual,
       dstfc_col_list->col_cnt), dstfc_col_list->qual[dstfc_col_list->col_cnt].col_name = dtc
      .column_name,
      dstfc_col_list->qual[dstfc_col_list->col_cnt].table_name = dtc.table_name, dstfc_col_list->
      qual[dstfc_col_list->col_cnt].owner_name = dtc.owner
     ENDIF
    FOOT  dtc.table_name
     IF ((dmvd->tbls[d.seq].scui_ind=0))
      dmvd->tbls[d.seq].col_list = dstfc_full_col_list, dmvd->tbls[d.seq].data_type_list =
      dstfc_data_type_list
     ENDIF
     dmvd->tbls[d.seq].full_col_list = dstfc_full_col_list,
     CALL dvdr_parse_list("COLUMN",",",dmvd->tbls[d.seq].col_list,d.seq),
     CALL dvdr_parse_list("DATATYPE",",",dmvd->tbls[d.seq].data_type_list,d.seq)
    FOOT  dtc.owner
     IF ((dmvd->tbls[d.seq].scui_ind=0))
      dmvd->tbls[d.seq].col_list = dstfc_full_col_list, dmvd->tbls[d.seq].data_type_list =
      dstfc_data_type_list
     ENDIF
     dmvd->tbls[d.seq].full_col_list = dstfc_full_col_list,
     CALL dvdr_parse_list("COLUMN",",",dmvd->tbls[d.seq].col_list,d.seq),
     CALL dvdr_parse_list("DATATYPE",",",dmvd->tbls[d.seq].data_type_list,d.seq)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dmvd)
   ENDIF
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dmr_load_di_filter(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain check column overrides"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d,
     (dummyt dt  WITH seq = value(dmvd->tbl_cnt))
    PLAN (dt)
     JOIN (d
     WHERE d.info_domain IN ("DM2_MIG_CHKCOL_OVERRIDE", "DM2_MIG_NOUSE_CHKCOL",
     "DM2_MIG_COMPARE_WHERE")
      AND d.info_name=concat(dmvd->tbls[dt.seq].owner,".",dmvd->tbls[dt.seq].table_name))
    DETAIL
     IF (d.info_domain="DM2_MIG_COMPARE_WHERE")
      dmvd->tbls[dt.seq].compare_where = d.info_char
     ELSE
      IF (((d.info_domain="DM2_MIG_NOUSE_CHKCOL") OR (locateval(dstfc_ndx,1,dstfc_col_list->col_cnt,
       dmvd->tbls[dt.seq].owner,dstfc_col_list->qual[dstfc_ndx].owner_name,
       dmvd->tbls[dt.seq].table_name,dstfc_col_list->qual[dstfc_ndx].table_name,d.info_char,
       dstfc_col_list->qual[dstfc_ndx].col_name)=0)) )
       CALL echo(concat(dmvd->tbls[dt.seq].owner,".",dmvd->tbls[dt.seq].table_name,".",trim(d
         .info_char),
        " will not be used.")), dmvd->tbls[dt.seq].date_col_exists = 0, dmvd->tbls[dt.seq].
       date_col_name = "DM2NOTSET"
      ELSE
       CALL echo(concat(dmvd->tbls[dt.seq].owner,".",dmvd->tbls[dt.seq].table_name,".",trim(d
         .info_char),
        " will be used.")), dmvd->tbls[dt.seq].date_col_exists = 1, dmvd->tbls[dt.seq].date_col_name
        = d.info_char
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (validate(dm2_mig_bypass_di_cmp_wh,- (1))=1)
    SET dm_err->eproc = "Bypassing dynamic migration dm_info compare where logic."
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    SET dstfc_pos = locateval(dstfc_pos,1,dmvd->tbl_cnt,"V500",dmvd->tbls[dstfc_pos].owner,
     "DM_INFO",dmvd->tbls[dstfc_pos].table_name)
    IF (dstfc_pos > 0)
     SET dmvd->tbls[dstfc_pos].compare_where = concat(
      "where INFO_DOMAIN not in (SELECT a.info_domain ",
      "FROM (select info_name from V500.DM_INFO@ref_data_link where info_domain = 'DM2_MIG_DI_FILTER') p join ",
      "dm_info@ref_data_link a on a.info_domain like p.info_name)")
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dmvd)
   ENDIF
   FOR (dstfc_cnt = 1 TO dmvd->tbl_cnt)
    IF ((dmvd->tbls[dstfc_cnt].tgt_exists_ind != 1))
     SET dmvd->tbls[dstfc_cnt].excl_flag = 50
     SET dmvd->tbls[dstfc_cnt].excl_reason = "Table exists in source but not in target"
    ENDIF
    IF ((dmvd->tbls[dstfc_cnt].excl_flag IN (0, 50)))
     CALL echo(concat("View ",build(dstfc_cnt)," of ",build(dmvd->tbl_cnt)))
     EXECUTE dm2_verify_data_genviews dstfc_cnt
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->src_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving max and min uids for all tables with eligible index"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   FOR (dstfc_cnt = 1 TO dmvd->tbl_cnt)
    CALL echo(concat("Min/Max ",build(dstfc_cnt)," of ",build(dmvd->tbl_cnt)))
    IF ((dmvd->tbls[dstfc_cnt].scui_ind IN (1, 2))
     AND (dmvd->tbls[dstfc_cnt].excl_flag=0))
     SET dstfc_full_tname = trim(cnvtupper(concat(dmvd->tbls[dstfc_cnt].owner,".",dmvd->tbls[
        dstfc_cnt].table_name)))
     SET dm_err->eproc = concat("Retrieving MIN and MAX  for ",dstfc_full_tname)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     SELECT INTO "nl:"
      val_max = t1.max_id
      FROM (
       (
       (SELECT
        max_id = parser(concat("max(t.",dmvd->tbls[dstfc_cnt].keyid_col_name,")"))
        FROM (value(dstfc_full_tname) t)
        WITH sqltype("F8")))
       t1)
      DETAIL
       IF (val_max < 0)
        dmvd->tbls[dstfc_cnt].max_src_keyid = 0
       ELSE
        dmvd->tbls[dstfc_cnt].max_src_keyid = val_max
       ENDIF
      WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     SELECT INTO "nl:"
      val_min = t1.min_id
      FROM (
       (
       (SELECT
        min_id = parser(concat("min(t.",dmvd->tbls[dstfc_cnt].keyid_col_name,")"))
        FROM (value(dstfc_full_tname) t)
        WHERE parser(concat("t.",dmvd->tbls[dstfc_cnt].keyid_col_name," > 0"))
        WITH sqltype("F8")))
       t1)
      DETAIL
       dmvd->tbls[dstfc_cnt].range_start_keyid = val_min
      WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving src mode date times for all tables"
   IF (dvdr_get_tblmod("SETUP")=0)
    RETURN(0)
   ENDIF
   FOR (dstfc_cnt = 1 TO dmvd->tbl_cnt)
     CASE (dmvd->tbls[dstfc_cnt].scui_ind)
      OF 1:
       SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->rows_to_compare
      OF 2:
       IF ((((dmvd->tbls[dstfc_cnt].num_rows=- (1))) OR ((dmvd->tbls[dstfc_cnt].num_distinct=- (1))
       )) )
        SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->uow_threshold
       ELSEIF (((dmvd->tbls[dstfc_cnt].num_rows/ dmvd->tbls[dstfc_cnt].num_distinct) > dmvd->
       rows_to_compare))
        SET dmvd->tbls[dstfc_cnt].status = dvdr_uow_status
       ELSEIF ((dmvd->tbls[dstfc_cnt].num_rows <= dmvd->rows_to_compare))
        SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->rows_to_compare
       ELSE
        SET dmvd->tbls[dstfc_cnt].rows_to_compare = dm2ceil((dmvd->rows_to_compare/ (dmvd->tbls[
         dstfc_cnt].num_rows/ dmvd->tbls[dstfc_cnt].num_distinct)))
       ENDIF
      ELSE
       SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->rows_to_compare_all
     ENDCASE
   ENDFOR
   IF (dvdr_get_old_lag(dstfc_lag_time)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dmvd)
   ENDIF
   SET dm_err->eproc = "Updating rows in master table"
   UPDATE  FROM dm_vdata_master dvm,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    SET dvm.rows_to_compare = dmvd->tbls[d.seq].rows_to_compare, dvm.row_dt_tm_col_name = dmvd->tbls[
     d.seq].date_col_name, dvm.compare_status =
     IF ((dmvd->tbls[d.seq].status=dvdr_uow_status)) dmvd->tbls[d.seq].status
     ELSE evaluate(dmvd->tbls[d.seq].excl_flag,0,dvdr_ready,dvdr_exclude)
     ENDIF
    PLAN (d
     WHERE d.seq > 0
      AND (dmvd->tbls[d.seq].master_id != 0))
     JOIN (dvm
     WHERE (dvm.owner_name=dmvd->tbls[d.seq].owner)
      AND (dvm.table_name=dmvd->tbls[d.seq].table_name))
    WITH nocounter, maxcommit = 10000
   ;end update
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SET dm_err->eproc = "Inserting rows in master table"
   INSERT  FROM dm_vdata_master dvm,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    SET dvm.dm_vdata_master_id = seq(dm_clinical_seq,nextval), dvm.owner_name = dmvd->tbls[d.seq].
     owner, dvm.table_name = dmvd->tbls[d.seq].table_name,
     dvm.rows_to_compare = dmvd->tbls[d.seq].rows_to_compare, dvm.compare_status =
     IF ((dmvd->tbls[d.seq].status=dvdr_uow_status)) dmvd->tbls[d.seq].status
     ELSE evaluate(dmvd->tbls[d.seq].excl_flag,0,dvdr_ready,dvdr_exclude)
     ENDIF
     , dvm.column_list = dmvd->tbls[d.seq].col_list,
     dvm.data_type_list = dmvd->tbls[d.seq].data_type_list, dvm.keyid_column_name = dmvd->tbls[d.seq]
     .keyid_col_name, dvm.range_start_keyid =
     IF ((dmvd->tbls[d.seq].scui_ind IN (1, 2))) dmvd->tbls[d.seq].range_start_keyid
     ELSE 0
     ENDIF
     ,
     dvm.max_src_keyid = dmvd->tbls[d.seq].max_src_keyid, dvm.range_beg_keyid = 0, dvm
     .range_end_keyid = 0,
     dvm.object_id_src = dmvd->tbls[d.seq].src_object_id, dvm.last_src_mod_dt_tm = cnvtdatetime(
      greatest(dmvd->tbls[d.seq].last_analyzed,dmvd->tbls[d.seq].cur_src_mod_dt_tm)), dvm
     .last_compare_dt_tm = cnvtdatetime("01-JAN-1900"),
     dvm.mismatch_row_dt_tm = cnvtdatetime("01-JAN-1900"), dvm.updt_applctx = dmvd->tbls[d.seq].
     scui_ind, dvm.row_dt_tm_col_name = dmvd->tbls[d.seq].date_col_name,
     dvm.mm_pull_key_from_src_ind = 1, dvm.lag_dt_tm = cnvtdatetime(dstfc_lag_time)
    PLAN (d
     WHERE d.seq > 0
      AND (dmvd->tbls[d.seq].master_id=0))
     JOIN (dvm)
    WITH nocounter, maxcommit = 10000
   ;end insert
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM dm_vdata_master dvm,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dvm
     WHERE (dmvd->tbls[d.seq].owner=dvm.owner_name)
      AND (dmvd->tbls[d.seq].table_name=dvm.table_name))
    DETAIL
     dmvd->tbls[d.seq].master_id = dvm.dm_vdata_master_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_tblmod(dgt_mode)
   DECLARE dgt_ndx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Retrieve table mod date/time for source tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dgt_mode="COMPARE")
     FROM (value(concat("DM_DBA_TABLES_ACTUAL_STATS@",dmvd->db_link)) d),
      (value(concat("ALL_TAB_MODIFICATIONS@",dmvd->db_link)) m)
     WHERE (d.owner=dmvd->tbls[1].owner)
      AND (d.table_name=dmvd->tbls[1].table_name)
      AND outerjoin(concat(d.owner,".",d.table_name))=concat(m.table_owner,".",m.table_name)
    ELSE
     FROM (value(concat("DM_DBA_TABLES_ACTUAL_STATS@",dmvd->db_link)) d),
      (value(concat("ALL_TAB_MODIFICATIONS@",dmvd->db_link)) m)
     WHERE outerjoin(concat(d.owner,".",d.table_name))=concat(m.table_owner,".",m.table_name)
    ENDIF
    INTO "nl:"
    mon_time_null = nullind(m.timestamp), anyl_time_null = nullind(d.last_analyzed), nr_null =
    nullind(d.num_rows)
    DETAIL
     IF (locateval(dgt_ndx,1,dmvd->tbl_cnt,d.owner,dmvd->tbls[dgt_ndx].owner,
      d.table_name,dmvd->tbls[dgt_ndx].table_name) > 0)
      dmvd->tbls[dgt_ndx].cur_src_mod_dt_tm = evaluate(mon_time_null,1,cnvtdatetime("01-JAN-1900"),m
       .timestamp), dmvd->tbls[dgt_ndx].last_analyzed = evaluate(anyl_time_null,1,cnvtdatetime(
        "01-JAN-1900"),d.last_analyzed), dmvd->tbls[dgt_ndx].monitoring = evaluate(d.monitoring,"YES",
       1,0),
      dmvd->tbls[dgt_ndx].num_rows = evaluate(nr_null,1,- (1),d.num_rows)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_write_exclusion_rows(null)
   SET dm_err->eproc = "Writing exclusion rows for tables"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_vdata_exclude_dtl dved,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dved
     WHERE (dved.dm_vdata_master_id=dmvd->tbls[d.seq].master_id)
      AND (dved.exclude_reason_flag=dmvd->tbls[d.seq].excl_flag))
    DETAIL
     dmvd->tbls[d.seq].exclude_ind = 1
    WITH nocounter
   ;end select
   INSERT  FROM dm_vdata_exclude_dtl dved,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    SET dved.dm_vdata_exclude_dtl_id = seq(dm_clinical_seq,nextval), dved.dm_vdata_master_id = dmvd->
     tbls[d.seq].master_id, dved.exclude_reason_flag = dmvd->tbls[d.seq].excl_flag,
     dved.exclude_reason_txt = dmvd->tbls[d.seq].excl_reason
    PLAN (d
     WHERE (dmvd->tbls[d.seq].excl_flag != 0)
      AND (dmvd->tbls[d.seq].exclude_ind != 1))
     JOIN (dved)
    WITH nocounter, maxcommit = 10000
   ;end insert
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_write_dminfo_rows(null)
   SET dm_err->eproc = "Writing dm_info rows for current data verification parameters"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_DBLINK"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_DBLINK", di.info_char =
      cnvtupper(dmvd->db_link)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dmvd->db_link)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_DBLINK"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_SRCDB"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_SRCDB", di.info_char =
      cnvtupper(dm2_install_schema->src_dbase_name)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dm2_install_schema->src_dbase_name)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_SRCDB"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_TGTDB"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_TGTDB", di.info_char =
      cnvtupper(dm2_install_schema->target_dbase_name)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dm2_install_schema->target_dbase_name)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_TGTDB"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_OWNER"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_OWNER", di.info_char =
      cnvtupper(dmvd->owner)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dmvd->owner)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_OWNER"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_TABLE_NAME"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_TABLE_NAME", di.info_char =
      cnvtupper(dmvd->table_name)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dmvd->table_name)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_TABLE_NAME"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_NUMROWS"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_NUMROWS", di.info_number = dmvd
      ->rows_to_compare
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = dmvd->rows_to_compare
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_NUMROWS"
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_verify_data_rpt_info(dgvdri_return,dgvdri_quit)
   DECLARE dgvdri_verify_data_setup_rpt = i2 WITH protect, noconstant(1)
   DECLARE dgvdri_owner = vc WITH protect, noconstant(currdbuser)
   DECLARE dgvdri_table_name = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Collecting data verification report information"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET width = 132
   IF ((dm_err->debug_flag != 511))
    SET message = window
   ENDIF
   IF (dgvdri_return=1)
    CALL clear(1,1)
    CALL box(1,1,24,131)
    CALL text(2,2,"Data Verification Process (Mismatch Detail Report)")
    CALL text(5,2,"(C)hoose Another Table, (Q)uit: ")
    CALL accept(5,34,"A;CU","C"
     WHERE curaccept IN ("C", "Q"))
    CASE (curaccept)
     OF "C":
      SET dgvdri_owner = dvdr_rpt_dtl_info->owner
      SET dgvdri_table_name = dvdr_rpt_dtl_info->table_name
     OF "Q":
      SET dgvdri_quit = 1
      RETURN(1)
    ENDCASE
   ENDIF
   WHILE (dgvdri_verify_data_setup_rpt=1)
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Data Verification Process (Mismatch Detail Report)")
     CALL text(5,2,"Owner: ")
     CALL text(7,2,"Table Name: ")
     CALL text(5,80,"List of Valid Owners:")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM2_VDATA_INFO"
       AND di.info_name="DM2_VDATA_USERLIST"
      DETAIL
       dvdr_rpt_dtl_info->num_owners = di.info_number, dvdr_rpt_dtl_info->owners_list = di.info_char
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     CALL text(6,80,dvdr_rpt_dtl_info->owners_list)
     CALL text(9,2,"(C)ontinue, (M)odify, (Q)uit: ")
     CALL accept(5,30,"P(30);cu",dgvdri_owner
      WHERE  NOT (trim(curaccept)=""))
     SET dgvdri_owner = build(trim(curaccept))
     CALL accept(7,30,"P(30);cu",dgvdri_table_name
      WHERE  NOT (trim(curaccept)=""))
     SET dgvdri_table_name = build(trim(curaccept))
     CALL accept(9,33,"A;CU","C"
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "C":
       SET dgvdri_verify_data_setup_rpt = 0
       SET dvdr_rpt_dtl_info->owner = dgvdri_owner
       SET dvdr_rpt_dtl_info->table_name = dgvdri_table_name
      OF "Q":
       SET dgvdri_quit = 1
       RETURN(1)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_vdata_rpt_env_info(null)
   SET dm_err->eproc = "Getting environment data for source and target"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name IN ("DM2_VDATA_DBLINK", "DM2_VDATA_SRCDB", "DM2_VDATA_TGTDB")
    DETAIL
     IF (di.info_name="DM2_VDATA_DBLINK")
      dvdr_rpt_dtl_info->db_link = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_SRCDB")
      dvdr_rpt_dtl_info->src_db_name = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_TGTDB")
      dvdr_rpt_dtl_info->tgt_db_name = di.info_char
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_load_rpt_record(null)
   DECLARE dlrr_tot_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_cmp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_complete_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_mtch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_excl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_get_cur_max = i2 WITH protect, noconstant(1)
   DECLARE dlrr_unabletocompare_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Loading verification data into the reporting record structure"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Getting Summary Info"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_USERLIST"
    DETAIL
     dvdr_rpt_dtl_info->num_owners = di.info_number, dvdr_rpt_dtl_info->owners_list = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Getting Table Verification Information"
   SELECT INTO "nl:"
    nullind_dved_dm_vdata_master_id = nullind(dved.dm_vdata_master_id)
    FROM dm_vdata_master dvm,
     dm_vdata_exclude_dtl dved
    PLAN (dvm)
     JOIN (dved
     WHERE outerjoin(dvm.dm_vdata_master_id)=dved.dm_vdata_master_id)
    ORDER BY dvm.mismatch_event_cnt DESC, dvm.last_match_cnt DESC, dvm.owner_name,
     dvm.table_name
    HEAD REPORT
     dvdr_rpt_dtl_info->tbl_cnt = 0, stat = alterlist(dvdr_rpt_dtl_info->tbls,0)
    DETAIL
     IF (dvm.compare_status IN (dvdr_match, dvdr_mismatch))
      IF ((dvdr_rpt_dtl_info->comp_dt_max < dvm.last_compare_dt_tm))
       dvdr_rpt_dtl_info->comp_dt_max = dvm.last_compare_dt_tm
      ENDIF
      IF ((((dvdr_rpt_dtl_info->comp_dt_min > dvm.last_compare_dt_tm)) OR ((dvdr_rpt_dtl_info->
      comp_dt_min=0))) )
       dvdr_rpt_dtl_info->comp_dt_min = dvm.last_compare_dt_tm
      ENDIF
     ENDIF
     dlrr_tot_cnt = (dlrr_tot_cnt+ 1)
     IF (dvm.compare_status=dvdr_complete)
      dlrr_complete_cnt = (dlrr_complete_cnt+ 1)
     ELSEIF (dvm.compare_status=dvdr_match
      AND (dvdr_rpt_dtl_info->final_row_dt_tm > 0.0))
      dvdr_rpt_dtl_info->yet_to_be_compared = (dvdr_rpt_dtl_info->yet_to_be_compared+ 1)
     ELSEIF (dvm.compare_status=dvdr_match)
      dlrr_mtch_cnt = (dlrr_mtch_cnt+ 1)
     ELSEIF ((dvdr_rpt_dtl_info->final_row_dt_tm > 0.0)
      AND dvm.compare_status=dvdr_mismatch
      AND (cnvtdatetime(dvm.last_compare_dt_tm) > dvdr_rpt_dtl_info->final_row_dt_tm))
      dvdr_rpt_dtl_info->tbls_mm_down_cnt = (dvdr_rpt_dtl_info->tbls_mm_down_cnt+ 1)
     ELSEIF ((dvdr_rpt_dtl_info->final_row_dt_tm > 0.0)
      AND dvm.compare_status=dvdr_mismatch
      AND (cnvtdatetime(dvm.last_compare_dt_tm) < dvdr_rpt_dtl_info->final_row_dt_tm))
      dvdr_rpt_dtl_info->yet_to_be_compared = (dvdr_rpt_dtl_info->yet_to_be_compared+ 1)
     ELSEIF (dvm.compare_status=dvdr_mismatch)
      dvdr_rpt_dtl_info->tbls_mm_cnt = (dvdr_rpt_dtl_info->tbls_mm_cnt+ 1)
     ELSEIF (((dvm.compare_status IN (dvdr_exclude, dvdr_error)) OR (nullind_dved_dm_vdata_master_id=
     0)) )
      dlrr_excl_cnt = (dlrr_excl_cnt+ 1)
     ELSEIF (dvm.compare_status IN (dvdr_uow_status, dvdr_nocomp_size))
      dlrr_unabletocompare_cnt = (dlrr_unabletocompare_cnt+ 1)
     ELSEIF (dvm.compare_status=dvdr_ready
      AND nullind_dved_dm_vdata_master_id=1)
      dvdr_rpt_dtl_info->yet_to_be_compared = (dvdr_rpt_dtl_info->yet_to_be_compared+ 1)
     ENDIF
     dvdr_rpt_dtl_info->tbl_cnt = (dvdr_rpt_dtl_info->tbl_cnt+ 1), stat = alterlist(dvdr_rpt_dtl_info
      ->tbls,dvdr_rpt_dtl_info->tbl_cnt), dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].owner
      = dvm.owner_name,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].table_name = dvm.table_name,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].master_id = dvm.dm_vdata_master_id,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].status = dvm.compare_status,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].keyid_col_name = dvm.keyid_column_name,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].src_object_id = dvm.object_id_src,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].mismatch_event_cnt = dvm.mismatch_event_cnt,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_mismatched = dvm.last_match_cnt,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_compare_dt_tm = dvm.last_compare_dt_tm
     IF (dvm.updt_applctx IN (3, 0))
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].orig_start_key = - (1), dvdr_rpt_dtl_info->
      tbls[dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_min = - (1), dvdr_rpt_dtl_info->tbls[
      dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_max = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_mismatch_keyid_min = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_compared = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].total_rows_compared = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].key_range_remaining = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].max_src_keyid = - (1), dvdr_rpt_dtl_info->
      tbls[dvdr_rpt_dtl_info->tbl_cnt].last_src_mod_dt_tm = dvm.last_src_mod_dt_tm
     ELSE
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].max_src_keyid = dvm.max_src_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].orig_start_key = dvm.range_start_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_min = dvm.range_beg_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_max = dvm.range_end_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_mismatch_keyid_min = dvm
      .mismatch_beg_keyid, dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_src_mod_dt_tm =
      - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].key_range_remaining = (dvm.max_src_keyid -
      dvm.range_end_keyid)
      IF (dvm.updt_applctx=2)
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_compared = - (1),
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].total_rows_compared = - (1)
      ELSE
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_compared = dvm.last_compare_cnt,
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].total_rows_compared = dvm
       .ttl_rows_compared
      ENDIF
     ENDIF
     IF (((dvm.compare_status=dvdr_exclude) OR (nullind_dved_dm_vdata_master_id=0)) )
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason = dved.exclude_reason_txt
     ELSEIF (dvm.compare_status=dvdr_error)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "An error occured during comparison"
     ELSEIF (dvm.compare_status=dvdr_comparing)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "Table currently being compared", dvdr_rpt_dtl_info->comparing_cnt = (dvdr_rpt_dtl_info->
      comparing_cnt+ 1)
     ELSEIF (dvm.compare_status=dvdr_nocomp_size)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "Table size is too large (or unknown) to compare with current unique index options"
     ELSEIF (dvm.compare_status=dvdr_uow_status)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "Distinct values for leading column of composite index used is too low"
     ENDIF
    FOOT REPORT
     dlrr_cmp_cnt = (dlrr_tot_cnt - dlrr_excl_cnt), dvdr_rpt_dtl_info->yet_to_be_compared_pct = ((
     cnvtreal(dvdr_rpt_dtl_info->yet_to_be_compared)/ cnvtreal(dlrr_cmp_cnt)) * 100.0),
     dvdr_rpt_dtl_info->mtch_pct = ((cnvtreal(dlrr_mtch_cnt)/ cnvtreal(dlrr_cmp_cnt)) * 100.0),
     dvdr_rpt_dtl_info->mismatch_pct = ((cnvtreal(dvdr_rpt_dtl_info->tbls_mm_cnt)/ cnvtreal(
      dlrr_cmp_cnt)) * 100.0)
     IF ((dvdr_rpt_dtl_info->final_row_dt_tm > 0.0))
      dvdr_rpt_dtl_info->downtime_mm_pct = ((cnvtreal(dvdr_rpt_dtl_info->tbls_mm_down_cnt)/ cnvtreal(
       dlrr_cmp_cnt)) * 100.0), dvdr_rpt_dtl_info->complete_pct = ((cnvtreal(dlrr_complete_cnt)/
      cnvtreal(dlrr_cmp_cnt)) * 100.0)
     ENDIF
    WITH nocounter
   ;end select
   SET dvdr_rpt_dtl_info->tbls_compared = dlrr_cmp_cnt
   SET dvdr_rpt_dtl_info->tbls_matched = dlrr_mtch_cnt
   SET dvdr_rpt_dtl_info->tbls_complete = dlrr_complete_cnt
   SET dvdr_rpt_dtl_info->tbls_excluded = dlrr_excl_cnt
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_VDATA_INFO"
     AND d.info_name="DM2_VDATA_GET_CUR_MAX"
    DETAIL
     dlrr_get_cur_max = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (dlrr_get_cur_max=1)
    SET dm_err->eproc = "Retrieving Current Max Src Keyid for all tables"
    IF (dvdr_get_cur_max_src_keyid(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_cur_max_src_keyid(null)
   DECLARE dgcmsk_full_tname = vc WITH protect, noconstant("")
   DECLARE dgcmsk_ndx = i4 WITH protect, noconstant(0)
   DECLARE dgcmsk_no_src = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Loading Current Max Keyid values into the reporting record structure"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Retrieve table mod date/time for source tables."
   SELECT INTO "nl:"
    nullind_m_timestamp = nullind(m.timestamp), nullind_d_last_analyzed = nullind(d.last_analyzed)
    FROM (value(concat("DBA_TABLES@",dvdr_rpt_dtl_info->db_link)) d),
     (value(concat("ALL_TAB_MODIFICATIONS@",dvdr_rpt_dtl_info->db_link)) m),
     dm_vdata_master v
    WHERE v.owner_name=d.owner
     AND v.table_name=d.table_name
     AND outerjoin(concat(d.owner,".",d.table_name))=concat(m.table_owner,".",m.table_name)
    DETAIL
     IF (locateval(dgcmsk_ndx,1,dvdr_rpt_dtl_info->tbl_cnt,d.owner,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx
      ].owner,
      d.table_name,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].table_name) > 0)
      dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].cur_src_mod_dt_tm = evaluate(nullind_m_timestamp,1,
       cnvtdatetime("01-JAN-1900"),m.timestamp), dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_analyzed =
      evaluate(nullind_d_last_analyzed,1,cnvtdatetime("01-JAN-1900"),d.last_analyzed),
      dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].monitoring = evaluate(d.monitoring,"YES",1,0)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Setting default values for data verification variables"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_TGT_TO_SRC"
    DETAIL
     dgcmsk_no_src = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   FOR (dgcmsk_ndx = 1 TO dvdr_rpt_dtl_info->tbl_cnt)
     IF ((dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid > 0))
      IF ((((dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_src_mod_dt_tm < greatest(dvdr_rpt_dtl_info->
       tbls[dgcmsk_ndx].cur_src_mod_dt_tm,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_analyzed))) OR ((
      dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].monitoring=0)))
       AND  NOT ((dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].status IN (dvdr_exclude, dvdr_error))))
       SET dgcmsk_full_tname = trim(cnvtupper(concat(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].owner,".",
          dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].table_name)))
       SET dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_src_mod_dt_tm = cnvtdatetime(greatest(
         dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].cur_src_mod_dt_tm,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
         last_analyzed))
       SET dm_err->eproc = concat("Retrieving SRC max uid for ",dgcmsk_full_tname)
       SELECT INTO "nl:"
        val_max = t1.max_id
        FROM (
         (
         (SELECT
          max_id = parser(concat("max(t.",dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].keyid_col_name,")"))
          FROM (value(concat("DM2VDATS",trim(cnvtstring(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
               src_object_id)))) t)
          WITH sqltype("F8")))
         t1)
        DETAIL
         dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid = greatest(dvdr_rpt_dtl_info->tbls[
          dgcmsk_ndx].max_src_keyid,val_max), dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].key_range_remaining
          = (dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid - dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
         last_comp_keyid_max)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        SET dm_err->err_ind = 1
        RETURN(0)
       ENDIF
       IF (dgcmsk_no_src=1)
        SET dm_err->eproc = concat("Retrieving TGT max uid for ",dgcmsk_full_tname)
        SELECT INTO "nl:"
         val_max = t1.max_id
         FROM (
          (
          (SELECT
           max_id = parser(concat("max(t.",dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].keyid_col_name,")"))
           FROM (value(concat("DM2VDATT",trim(cnvtstring(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
                src_object_id)))) t)
           WITH sqltype("F8")))
          t1)
         DETAIL
          dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid = greatest(dvdr_rpt_dtl_info->tbls[
           dgcmsk_ndx].max_src_keyid,val_max), dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
          key_range_remaining = (dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid -
          dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_comp_keyid_max)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc) != 0)
         SET dm_err->err_ind = 1
         RETURN(0)
        ENDIF
       ENDIF
       SET dm_err->eproc = concat("Updating master table entry for ",dgcmsk_full_tname)
       UPDATE  FROM dm_vdata_master dvm
        SET dvm.max_src_keyid = dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid, dvm
         .last_src_mod_dt_tm = cnvtdatetime(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_src_mod_dt_tm)
        WHERE (dvm.owner_name=dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].owner)
         AND (dvm.table_name=dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].table_name)
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc) != 0)
        ROLLBACK
        SET dm_err->err_ind = 1
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_load_master(dlm_masterid)
   DECLARE dlm_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlm_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Retrieve master level information."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    comp_dt_null = nullind(d.last_compare_dt_tm)
    FROM dm_vdata_master d
    WHERE d.dm_vdata_master_id=dlm_masterid
    DETAIL
     dmvd->tbl_cnt = (dmvd->tbl_cnt+ 1), stat = alterlist(dmvd->tbls,dmvd->tbl_cnt), dmvd->tbls[dmvd
     ->tbl_cnt].owner = d.owner_name,
     dmvd->tbls[dmvd->tbl_cnt].table_name = d.table_name, dmvd->tbls[dmvd->tbl_cnt].master_id = d
     .dm_vdata_master_id, dmvd->tbls[dmvd->tbl_cnt].status = d.compare_status,
     dmvd->tbls[dmvd->tbl_cnt].keyid_col_name = d.keyid_column_name, dmvd->tbls[dmvd->tbl_cnt].
     src_object_id = d.object_id_src, dmvd->tbls[dmvd->tbl_cnt].max_src_keyid = d.max_src_keyid,
     dmvd->tbls[dmvd->tbl_cnt].range_start_keyid = d.range_start_keyid, dmvd->tbls[dmvd->tbl_cnt].
     mm_beg_keyid = d.mismatch_beg_keyid, dmvd->tbls[dmvd->tbl_cnt].mm_end_keyid = d
     .mismatch_end_keyid,
     dmvd->tbls[dmvd->tbl_cnt].compare_keyid_min = d.range_beg_keyid, dmvd->tbls[dmvd->tbl_cnt].
     compare_keyid_max = d.range_end_keyid, dmvd->tbls[dmvd->tbl_cnt].last_range_keyid_min = d
     .range_beg_keyid,
     dmvd->tbls[dmvd->tbl_cnt].last_range_keyid_max = d.range_end_keyid, dmvd->tbls[dmvd->tbl_cnt].
     last_src_mod_dt_tm = d.last_src_mod_dt_tm, dmvd->tbls[dmvd->tbl_cnt].mismatch_event_cnt = d
     .mismatch_event_cnt,
     dmvd->tbls[dmvd->tbl_cnt].last_match_dt_tm = d.last_match_dt_tm, dmvd->tbls[dmvd->tbl_cnt].
     last_compare_cnt = d.last_compare_cnt, dmvd->tbls[dmvd->tbl_cnt].last_match_cnt = d
     .last_match_cnt,
     dmvd->tbls[dmvd->tbl_cnt].last_mm_rowid = d.mismatch_rowid, dmvd->tbls[dmvd->tbl_cnt].
     last_ui_str = d.mismatch_unique_key_txt, dmvd->tbls[dmvd->tbl_cnt].last_mm_cnt = d
     .curr_mismatch_row_cnt,
     dmvd->tbls[dmvd->tbl_cnt].last_mm_cnt_scui = d.last_match_cnt, dmvd->tbls[dmvd->tbl_cnt].
     rows_to_compare = d.rows_to_compare, dmvd->tbls[dmvd->tbl_cnt].scui_ind = d.updt_applctx,
     dmvd->tbls[dmvd->tbl_cnt].last_compare_dt_tm = evaluate(comp_dt_null,1,cnvtdatetime(
       "01-JAN-1900"),d.last_compare_dt_tm), dmvd->tbls[dmvd->tbl_cnt].date_col_name = d
     .row_dt_tm_col_name
     IF ((dmvd->tbls[dmvd->tbl_cnt].date_col_name != "DM2NOTSET"))
      dmvd->tbls[dmvd->tbl_cnt].date_col_exists = 1
     ELSE
      dmvd->tbls[dmvd->tbl_cnt].date_col_exists = 0
     ENDIF
     dmvd->tbls[dmvd->tbl_cnt].mm_rowid_dt_tm_min = cnvtdatetime(d.mismatch_row_dt_tm), dmvd->tbls[
     dmvd->tbl_cnt].mm_pull_key = d.mm_pull_key_from_src_ind,
     CALL dvdr_parse_list("COLUMN",",",d.column_list,dmvd->tbl_cnt),
     CALL dvdr_parse_list("DATATYPE",",",d.data_type_list,dmvd->tbl_cnt),
     CALL dvdr_parse_list("UNIQUESTR","<#>",d.mismatch_unique_key_txt,dmvd->tbl_cnt)
    FOOT REPORT
     stat = alterlist(dmvd->tbls,dmvd->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_appid_work(daw_just_check,daw_appl,daw_continue)
   DECLARE daw_status_ret = vc WITH protect, noconstant("")
   DECLARE daw_applid_chk = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Check if compare currently running"
   CALL disp_msg("",dm_err->logfile,10)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM_VDATA_INFO"
     AND d.info_name="DM_VDATA_APPID"
    DETAIL
     daw_applid_chk = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0
    AND daw_applid_chk > " ")
    SET dm_err->eproc = concat("Check status of APPL_ID:",daw_applid_chk)
    CALL disp_msg("",dm_err->logfile,10)
    SET daw_status_ret = dm2_get_appl_status(daw_applid_chk)
    CASE (daw_status_ret)
     OF "A":
      SET daw_continue = 0
      SET dm_err->eproc = concat(daw_applid_chk," is currently Active.")
      CALL disp_msg("",dm_err->logfile,10)
      RETURN(1)
     OF "I":
      SET dm_err->eproc = concat(daw_applid_chk," is currently Inactive.")
      CALL disp_msg("",dm_err->logfile,10)
      SET daw_continue = 1
     OF "E":
      SET daw_continue = 0
      RETURN(0)
    ENDCASE
   ENDIF
   IF (daw_just_check=0)
    SET dm_err->eproc = concat("Remove APPL_ID checkpoint from DM_INFO")
    CALL disp_msg("",dm_err->logfile,10)
    DELETE  FROM dm_info d
     WHERE d.info_domain="DM_VDATA_INFO"
      AND d.info_name="DM_VDATA_APPID"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Log running compare for APPL_ID:",daw_appl)
    CALL disp_msg("",dm_err->logfile,10)
    INSERT  FROM dm_info d
     SET d.info_domain = "DM_VDATA_INFO", d.info_name = "DM_VDATA_APPID", d.info_char = daw_appl
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
    SET daw_continue = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_verify2(null)
  SET dmvd->use_verify2_ind = 1
  RETURN(1)
 END ;Subroutine
 DECLARE dvde_cnt = i4 WITH protect, noconstant(0)
 DECLARE dvde_rpt_file = vc WITH protect, noconstant("")
 DECLARE dvde_actionreq_cnt = i4 WITH protect, noconstant(0)
 DECLARE dvde_informational_cnt = i4 WITH protect, noconstant(0)
 IF (check_logfile("dm2_vdata_rexcl",".log","dm2_verify_data_exclusions LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Obtaining Verify Data Reporting information"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 IF (dvdr_get_vdata_rpt_env_info(null)=0)
  GO TO exit_script
 ENDIF
 IF ((((dvdr_rpt_dtl_info->src_db_name="DM2NOTSET")) OR ((dvdr_rpt_dtl_info->tgt_db_name="DM2NOTSET")
 )) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "No valid verification data was returned. Make sure that user is connected to target DB"
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Getting Table Verification Exclusion Information"
 SELECT INTO "nl:"
  nullind_dved_dm_vdata_master_id = nullind(dved.dm_vdata_master_id)
  FROM dm_vdata_master dvm,
   dm_vdata_exclude_dtl dved
  PLAN (dvm
   WHERE dvm.table_name != "BIN$*"
    AND dvm.compare_status IN (dvdr_uow_status, dvdr_exclude))
   JOIN (dved
   WHERE outerjoin(dvm.dm_vdata_master_id)=dved.dm_vdata_master_id)
  ORDER BY dvm.owner_name, dvm.table_name
  HEAD REPORT
   dvdr_rpt_dtl_info->tbl_cnt = 0, stat = alterlist(dvdr_rpt_dtl_info->tbls,0)
  DETAIL
   dvdr_rpt_dtl_info->tbl_cnt = (dvdr_rpt_dtl_info->tbl_cnt+ 1), stat = alterlist(dvdr_rpt_dtl_info->
    tbls,dvdr_rpt_dtl_info->tbl_cnt), dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].owner = dvm
   .owner_name,
   dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].table_name = dvm.table_name, dvdr_rpt_dtl_info
   ->tbls[dvdr_rpt_dtl_info->tbl_cnt].master_id = dvm.dm_vdata_master_id, dvdr_rpt_dtl_info->tbls[
   dvdr_rpt_dtl_info->tbl_cnt].status = dvm.compare_status
   IF (((dvm.compare_status=dvdr_exclude) OR (nullind_dved_dm_vdata_master_id=0)) )
    dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason = dved.exclude_reason_txt
   ELSEIF (dvm.compare_status=dvdr_uow_status)
    dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
    "Distinct values for leading column of composite index used is too low"
   ENDIF
   IF (((dvm.compare_status=dvdr_uow_status) OR (dved.exclude_reason_flag=80)) )
    dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].monitoring = 1, dvde_actionreq_cnt = (
    dvde_actionreq_cnt+ 1)
   ELSE
    dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].monitoring = 2, dvde_informational_cnt = (
    dvde_informational_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  GO TO exit_script
 ENDIF
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("dvde_actionreq_cnt:",dvde_actionreq_cnt))
  CALL echo(build("dvde_informational_cnt:",dvde_informational_cnt))
 ENDIF
 IF ((dm_err->debug_flag=511))
  CALL echo("************dvdr_rpt_dtl_info***************")
  CALL echorecord(dvdr_rpt_dtl_info)
 ENDIF
 SET dm_err->eproc = "Generating Data Verification Exclusion Report"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 IF (get_unique_file("dm2_vdata_rexcl",".rpt")=0)
  GO TO exit_script
 ELSE
  SET dvde_rpt_file = dm_err->unique_fname
 ENDIF
 SELECT INTO value(dvde_rpt_file)
  FROM dummyt d
  HEAD REPORT
   CALL print(fillstring(132,"-")), row + 1,
   CALL print(concat("Data Verification Exclusion Report as of ",format(cnvtdatetime(curdate,curtime3
      ),"DD-MMM-YY HH:MM;;D"))),
   row + 1,
   CALL print(fillstring(132,"-")), row + 1,
   "Data Verification Exclusions are between the following databases:", row + 1,
   CALL print(concat("  Source Database: ",dvdr_rpt_dtl_info->src_db_name,"@",dvdr_rpt_dtl_info->
    db_link)),
   row + 1,
   CALL print(concat("  Target Database: ",dvdr_rpt_dtl_info->tgt_db_name))
  DETAIL
   row + 2,
   CALL print(fillstring(132,"-")), row + 1,
   "Failure to Compare (Action Required): ",
   CALL print(dvde_actionreq_cnt), row + 1,
   CALL print(fillstring(132,"-")), row + 1
   IF (dvde_actionreq_cnt > 0)
    col 0, "OWNER.TABLE_NAME", col 40,
    "| COMPARE EXCLUSION REASON ", row + 1,
    CALL print(fillstring(80,"-")),
    row + 1
    FOR (dvde_cnt = 1 TO dvdr_rpt_dtl_info->tbl_cnt)
      IF ((dvdr_rpt_dtl_info->tbls[dvde_cnt].monitoring=1))
       col 0,
       CALL print(concat(trim(substring(1,10,dvdr_rpt_dtl_info->tbls[dvde_cnt].owner)),".",
        dvdr_rpt_dtl_info->tbls[dvde_cnt].table_name)), col 40,
       "| ",
       CALL print(substring(1,190,trim(dvdr_rpt_dtl_info->tbls[dvde_cnt].excl_reason))), row + 1
      ENDIF
    ENDFOR
   ENDIF
   row + 1,
   CALL print(fillstring(132,"-")), row + 1,
   "Not Eligible for Compare (Informational): ",
   CALL print(dvde_informational_cnt), row + 1,
   CALL print(fillstring(132,"-")), row + 1
   IF (dvde_informational_cnt > 0)
    col 0, "OWNER.TABLE_NAME", col 40,
    "| COMPARE EXCLUSION REASON ", row + 1,
    CALL print(fillstring(80,"-")),
    row + 1
    FOR (dvde_cnt = 1 TO dvdr_rpt_dtl_info->tbl_cnt)
      IF ((dvdr_rpt_dtl_info->tbls[dvde_cnt].monitoring=2))
       col 0,
       CALL print(concat(trim(substring(1,10,dvdr_rpt_dtl_info->tbls[dvde_cnt].owner)),".",
        dvdr_rpt_dtl_info->tbls[dvde_cnt].table_name)), col 40,
       "| ",
       CALL print(substring(1,190,trim(dvdr_rpt_dtl_info->tbls[dvde_cnt].excl_reason))), row + 1
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter, maxcol = 500, formfeed = none
 ;end select
 IF (check_error(dm_err->eproc))
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Displaying Data Verification Exclusion Report"
 IF (dm2_disp_file(dvde_rpt_file,"Data Verification Exclusion Report")=0)
  GO TO exit_script
 ENDIF
#exit_script
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "dm2_verify_data_exclusions completed successfully."
 ELSE
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 CALL final_disp_msg("dm2_verify_data_exclusions")
END GO
