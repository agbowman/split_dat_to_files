CREATE PROGRAM dm2_install_plan_menu
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
 IF (validate(drr_flex_sched->sched_set_up,8)=8
  AND validate(drr_flex_sched->sched_set_up,9)=9)
  FREE RECORD drr_flex_sched
  RECORD drr_flex_sched(
    1 sched_set_up = i2
    1 status = i2
    1 max_runners = i2
    1 runner_time_limit = i2
    1 readme_time_periods = i2
    1 schema_time_periods = i2
    1 readme_schedule[*]
      2 time_period = vc
      2 start_time = f8
      2 end_time = f8
      2 num_of_runners = i2
      2 start_time_hh = i2
      2 start_time_am_pm = c2
      2 end_time_hh = i2
      2 end_time_am_pm = c2
      2 start_time_hhmm = f8
      2 end_time_hhmm = f8
    1 schema_schedule[*]
      2 time_period = vc
      2 start_time = f8
      2 end_time = f8
      2 num_of_runners = i2
      2 start_time_hh = i2
      2 start_time_am_pm = c2
      2 end_time_hh = i2
      2 end_time_am_pm = c2
      2 start_time_hhmm = f8
      2 end_time_hhmm = f8
    1 pkg_using_schedule = i2
    1 pkg_number = vc
    1 pkg_install_mode = vc
    1 num_sched_runners = i2
    1 num_active_runners = i2
    1 num_stopping_runners = i2
    1 tot_num_runners = i2
    1 num_runners_to_stop = i2
    1 num_runners_to_start = i2
  )
  SET drr_flex_sched->sched_set_up = 0
  SET drr_flex_sched->status = 0
  SET drr_flex_sched->max_runners = 10
  SET drr_flex_sched->runner_time_limit = - (1)
  SET drr_flex_sched->readme_time_periods = 0
  SET drr_flex_sched->schema_time_periods = 0
  SET drr_flex_sched->pkg_using_schedule = 0
  SET drr_flex_sched->pkg_number = "DM2NOTSET"
  SET drr_flex_sched->pkg_install_mode = "DM2NOTSET"
  SET drr_flex_sched->num_sched_runners = 0
  SET drr_flex_sched->num_active_runners = 0
  SET drr_flex_sched->num_stopping_runners = 0
  SET drr_flex_sched->tot_num_runners = 0
  SET drr_flex_sched->num_runners_to_stop = 0
  SET drr_flex_sched->num_runners_to_start = 0
 ENDIF
 IF (validate(drr_runner_misc->mode,"X")="X"
  AND validate(drr_runner_misc->mode,"Y")="Y")
  FREE RECORD drr_runner_misc
  RECORD drr_runner_misc(
    1 mode = vc
    1 runner_identifier = vc
  )
  SET drr_runner_misc->mode = "DM2NOTSET"
  SET drr_runner_misc->runner_identifier = "DM2NOTSET"
 ENDIF
 DECLARE time_periods = i2
 DECLARE drr_submit_background_process(dsbp_user=vc,dsbp_pword=vc,dsbp_cnnect_str=vc,dsbp_queue_name=
  vc,dsbp_process_type=vc,
  dsbp_plan_id=f8,dsbp_install_mode=vc) = i2
 DECLARE drr_get_process_status(dgps_process_type=vc,dgps_plan_id=f8,dgps_status_out=i2(ref)) = i2
 DECLARE drr_cleanup_process_event() = i2
 DECLARE drr_cleanup_dm_info_runners() = i2
 DECLARE drr_cleanup_dm_info_sched_usage() = i2
 DECLARE drr_stop_installs_using_flex_sched() = i2
 DECLARE drr_stop_runners(dsr_mode=vc,dsr_number=i2) = i2
 DECLARE drr_start_runners(dstr_num_runners=i2,dstr_user=vc,dstr_pword=vc,dstr_cnnect_str=vc,
  dstr_queue_name=vc) = i2
 DECLARE drr_get_flexible_schedule() = i2
 DECLARE drr_use_flexible_schedule(dufs_prompt_ind=i2,dufs_pkg_number=vc,dufs_install_mode=vc,
  dufs_sel_ret=vc(ref)) = i2
 DECLARE drr_maintain_runners(dmr_user=vc,dmr_pword=vc,dmr_cnnect_str=vc,dmr_queue_name=vc,dm_process
  =vc) = i2
 DECLARE drr_check_pkg_appl_status(dcpas_appl_id=vc,dcpas_pkg_status=i2(ref)) = i2
 DECLARE drr_check_runner_status(dcrs_runner_type=vc,dcrs_appl_id=vc,dcrs_status=i2(ref)) = i2
 DECLARE drr_insert_runner_row(dirr_runner_type=vc,dirr_appl_id=vc,dirr_desc=vc,dirr_status=i2,
  dirr_plan_id=f8) = i2
 DECLARE drr_assign_file_to_installs(dafi_detail_type=vc,dafi_file_name=vc,dafi_event_id=f8) = i2
 DECLARE drr_remove_runner_row(drrr_runner_type=vc,drrr_appl_id=vc) = i2
 DECLARE drr_modify_install_status(dmis_plan_id=f8,dmis_appl_id=vc,dmis_status=i2,dmis_reason=vc,
  dmis_requester=vc) = i2
 DECLARE drr_rr_insert_runner_row(drirr_runner_identifier=vc,drirr_appl_id=vc) = i2
 DECLARE drr_rr_check_runner_status(drcrs_runner_identifier=vc,drcrs_appl_id=vc,drcrs_status=i2(ref))
  = i2
 DECLARE drr_rr_cleanup_dm_info_runners(null) = i2
 DECLARE drr_rr_remove_runner_row(drrrr_runner_identifier=vc,drrrr_appl_id=vc) = i2
 DECLARE drr_rr_maintain_runners(drmr_user=vc,drmr_pword=vc,drmr_cnnct_str=vc,drmr_runners=i2,
  drmr_runner_identifier=vc) = i2
 DECLARE drr_rr_start_runners(drstr_num_runners=i2,drstr_user=vc,drstr_pword=vc,drstr_cnnct_str=vc,
  drstr_identifier=vc) = i2
 DECLARE drr_cleanup_adm_dm_info_runners(dcadir_dblink=vc) = i2
 DECLARE drr_chk_active_runners(dcar_dblink=vc,dcar_count=i4(ref)) = i2
 SET modify curaliasreuse 1
 SUBROUTINE drr_submit_background_process(dsbp_user,dsbp_pword,dsbp_cnnct_str,dsbp_queue_name,
  dsbp_process_type,dsbp_plan_id,dsbp_install_mode)
   DECLARE dsbp_connect_string = vc WITH protect, noconstant(" ")
   DECLARE dsbp_file_name = vc WITH protect, noconstant(" ")
   DECLARE dsbp_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE dsbp_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbp_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbp_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE dsbp_debug_flag = vc WITH protect, noconstant("0")
   DECLARE dsbp_stat = i4 WITH protect, noconstant(0)
   DECLARE dsbp_file_prefix = vc WITH protect, noconstant(" ")
   DECLARE dsbp_plan_id_str = vc WITH protect, noconstant(trim(cnvtstring(abs(dsbp_plan_id))))
   DECLARE dsbp_pkg_install_mode = vc WITH protect, noconstant(" ")
   DECLARE dsbp_mtr_install_mode = vc WITH protect, noconstant(" ")
   IF (((dsbp_user=" ") OR (dsbp_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Invalid database connection information for subroutine drr_submit_background_process"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dsbp_cnnct_str > " "
    AND dsbp_cnnct_str != "NONE")
    SET dsbp_connect_string = build("'",dsbp_user,"/",dsbp_pword,"@",
     dsbp_cnnct_str,"'")
   ELSE
    SET dsbp_connect_string = build("'",dsbp_user,"/",dsbp_pword,"'")
   ENDIF
   SET dsbp_debug_flag = cnvtstring(dm_err->debug_flag)
   IF (dsbp_process_type=dpl_package_install)
    SET dsbp_file_prefix = "dm2obb"
   ELSEIF (dsbp_process_type=dpl_install_monitor)
    SET dsbp_file_prefix = "dm2obm"
   ELSEIF (dsbp_process_type=dpl_admin_upgrade)
    SET dsbp_file_prefix = "dm2ob_admupg"
   ENDIF
   IF (get_unique_file(concat(dsbp_file_prefix,dsbp_plan_id_str),".log")=0)
    RETURN(0)
   ENDIF
   SET dsbp_logfile_name = dm_err->unique_fname
   SET dsbp_file_name = replace(dsbp_logfile_name,".log",".ksh",0)
   IF (dsbp_process_type=dpl_package_install)
    SET dsbp_file_prefix = "dm2obb"
   ELSEIF (dsbp_process_type=dpl_install_monitor)
    SET dsbp_file_prefix = "dm2obm"
   ELSEIF (dsbp_process_type=dpl_admin_upgrade)
    SET dsbp_file_prefix = "dm2ob_admupg"
   ENDIF
   SET dsbp_pkg_install_mode = dsbp_install_mode
   SET dsbp_mtr_install_mode = dsbp_install_mode
   IF (((dsbp_install_mode="*ABG"
    AND dsbp_process_type=dpl_package_install) OR (dsbp_process_type=dpl_admin_upgrade)) )
    IF (dir_get_debug_trace_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsbp_install_mode="*ABG")
    SET dsbp_mtr_install_mode = replace(dsbp_install_mode,"ABG","",2)
   ELSE
    SET dsbp_pkg_install_mode = concat(dsbp_install_mode,"BG")
   ENDIF
   SET dm_err->eproc = "Creating job to execute background process."
   SELECT INTO trim(dsbp_file_name)
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "# Executing Background Runner...", row + 1,
     col 0, "#", row + 1,
     col 0, ". $cer_mgr/",
     CALL print(trim(cnvtlower(logical("environment")))),
     "_environment.ksh", row + 1, col 0,
     "ccl <<!", row + 1, col 0,
     "SET TRACE NORANGECACHE 0 go", row + 1, col 0,
     "free define oraclesystem go", row + 1, col 0,
     "define oraclesystem ", dsbp_connect_string, " go"
     IF (((dsbp_install_mode="*ABG"
      AND dsbp_process_type=dpl_package_install) OR (dsbp_process_type=dpl_admin_upgrade)) )
      IF ((dir_ui_misc->debug_level > 0))
       row + 1, col 0, "set dm2_debug_flag = ",
       dir_ui_misc->debug_level, " go"
      ENDIF
      IF ((dir_ui_misc->trace_flag=1))
       row + 1, col 0, "set trace rdbdebug go",
       row + 1, col 0, "set trace rdbbind go",
       row + 1, col 0, "set trace rdbbind2 go"
      ENDIF
     ELSE
      row + 1, col 0, "set dm2_debug_flag = ",
      dsbp_debug_flag, " go"
     ENDIF
     row + 1
     IF (dsbp_process_type=dpl_admin_upgrade)
      col 0, "declare dm2_admin_upgrade_os_session_logfile = vc with public,noconstant('",
      dsbp_logfile_name,
      "') go"
     ELSE
      col 0, "declare dm2_package_os_session_logfile = vc with public,noconstant('",
      dsbp_logfile_name,
      "') go"
     ENDIF
     row + 1
     IF (dsbp_process_type=dpl_package_install)
      col 0, "ocd_incl_Schema2 ", dsbp_plan_id_str,
      ", '", dsbp_pkg_install_mode, "' go"
     ELSEIF (dsbp_process_type=dpl_install_monitor)
      col 0, "dm2_install_monitor ", dsbp_plan_id_str,
      ",'", dsbp_mtr_install_mode, "' go"
     ELSEIF (dsbp_process_type=dpl_admin_upgrade)
      col 0, "dm_ocd_setup_admin go"
     ENDIF
     row + 1, col 0, "exit",
     row + 1, col 0, "!",
     row + 1, col 0, "sleep 30"
    WITH nocounter, maxrow = 1, format = variable,
     formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbp_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",dsbp_file_name)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("drr_submit_background_process changing permissions for ",
     dsbp_file_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(dsbp_chmod_cmd)=0)
    RETURN(0)
   ENDIF
   SET dsbp_exec_cmd = concat("nohup ","$CCLUSERDIR/",dsbp_file_name," > $CCLUSERDIR/",
    dsbp_logfile_name,
    " 2>&1 &")
   SET dm_err->eproc = concat("Executing ",trim(dsbp_file_name)," - results will be logged to ",trim(
     dsbp_logfile_name),".")
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcl(dsbp_exec_cmd,size(dsbp_exec_cmd),dsbp_stat)
   IF (dsbp_stat=0)
    IF (parse_errfile(dsbp_logfile_name)=0)
     RETURN(0)
    ENDIF
    SET dm_err->disp_msg_emsg = dm_err->errtext
    SET dm_err->emsg = dm_err->disp_msg_emsg
    SET dm_err->eproc = concat("dm2_push_dcl executing: ",dsbp_exec_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbp_exec_cmd = concat("ps -ef | grep ",dsbp_file_name," | grep -v grep")
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbp_exec_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dsbp_file_name,dm_err->errtext)=0)
    SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
    SET dm_err->emsg = dm_err->disp_msg_emsg
    SET dm_err->eproc = concat("Validating ",trim(dsbp_file_name)," was successfully executed.")
    SET dm_err->err_ind = 1
    CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_process_status(dgps_process_type,dgps_plan_id,dgps_status_out)
   DECLARE dgps_dm_info_exists = i2 WITH protect, noconstant(0)
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgps_dm_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgps_dm_info_exists != 1)
    SET dm_err->eproc = "DM_INFO does not exist. Setting status to execute by default."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgps_status_out = 1
    RETURN(1)
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   SET dgps_status_out = 0
   SET dm_err->eproc = "Query for process status"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=cnvtupper(dgps_process_type)
     AND d.info_char=trim(cnvtstring(dgps_plan_id))
    DETAIL
     dgps_status_out = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_assign_file_to_installs(dafi_detail_type,dafi_file_name,dafi_event_id)
   DECLARE dfsi_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsfi_ndx = i4 WITH protect, noconstant(0)
   DECLARE dfsi_optimizer_hint = vc WITH protect, noconstant("")
   SET dfsi_optimizer_hint = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   FREE RECORD dsfi_id
   RECORD dsfi_id(
     1 id_cnt = i4
     1 qual[*]
       2 event_id = f8
       2 found = i2
   )
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (dafi_event_id=0)
    SET dm_err->eproc = "Gather any active Package Install event ids"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_process dp,
      dm_process_event dpe
     WHERE dp.dm_process_id=dpe.dm_process_id
      AND dp.process_name=dpl_package_install
      AND dp.action_type=dpl_execution
      AND (( NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_failure, dpl_success))) OR (dpe
     .event_status = null))
     DETAIL
      dsfi_id->id_cnt = (dsfi_id->id_cnt+ 1), stat = alterlist(dsfi_id->qual,dsfi_id->id_cnt),
      dsfi_id->qual[dsfi_id->id_cnt].event_id = dpe.dm_process_event_id
     WITH nocounter, orahintcbo(value(dfsi_optimizer_hint))
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dsfi_id->id_cnt=0))
     RETURN(1)
    ENDIF
   ELSE
    SET dsfi_id->id_cnt = (dsfi_id->id_cnt+ 1)
    SET stat = alterlist(dsfi_id->qual,dsfi_id->id_cnt)
    SET dsfi_id->qual[dsfi_id->id_cnt].event_id = dafi_event_id
   ENDIF
   SET dm_err->eproc = "Query for event details"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event_dtl dped,
     (dummyt d  WITH seq = value(dsfi_id->id_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dped
     WHERE (dped.dm_process_event_id=dsfi_id->qual[d.seq].event_id)
      AND dped.detail_type=cnvtupper(dafi_detail_type))
    DETAIL
     dsfi_id->qual[d.seq].found = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dsfi_id)
   ENDIF
   IF (locateval(dsfi_ndx,1,dsfi_id->id_cnt,0,dsfi_id->qual[dsfi_ndx].found) > 0)
    FOR (dsfi_cnt = 1 TO dsfi_id->id_cnt)
      IF ((dsfi_id->qual[dsfi_cnt].found=0))
       CALL dm2_process_log_add_detail_text(cnvtupper(dafi_detail_type),dafi_file_name)
       SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = 0
       SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime
       (curdate,curtime3)
       IF (dm2_process_log_dtl_row(dsfi_id->qual[dsfi_cnt].event_id,0)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_dm_info_runners(null)
   DECLARE dcdir_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdir_applx = i4 WITH protect, noconstant(0)
   FREE RECORD dcdir_appl_rs
   RECORD dcdir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   IF (dm2_table_and_ccldef_exists("DM_INFO",dcdir_dm_info_fnd_ind)=0)
    RETURN(0)
   ENDIF
   IF (dcdir_dm_info_fnd_ind=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(
      "DM_INFO table not found in dm2_user_tables, bypassing dm2_cleanup_dm_info_runners logic...")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Getting a distinct list of appl ids attached to a runner..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
    "DM2_README_RUNNER", "DM2_SET_READY_TO_RUN",
    "DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR", "DM2_ADS_DRIVER_GEN:AUDSID",
    "DM2_ADS_CHILDEST_GEN:AUDSID")
    HEAD REPORT
     dcdir_applx = 0
    DETAIL
     dcdir_applx = (dcdir_applx+ 1)
     IF (mod(dcdir_applx,10)=1)
      stat = alterlist(dcdir_appl_rs->qual,(dcdir_applx+ 9))
     ENDIF
     dcdir_appl_rs->qual[dcdir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     dcdir_appl_rs->cnt = dcdir_applx, stat = alterlist(dcdir_appl_rs->qual,dcdir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcdir_appl_rs->cnt > 0))
    SET dcdir_applx = 1
    WHILE ((dcdir_applx <= dcdir_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(dcdir_appl_rs->qual[dcdir_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdir_appl_rs->qual[dcdir_applx].appl_id," is not active."
          ))
       ENDIF
       DELETE  FROM dm_info di
        WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
        "DM2_README_RUNNER", "DM2_SET_READY_TO_RUN",
        "DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR", "DM2_ADS_DRIVER_GEN:AUDSID",
        "DM2_ADS_CHILDEST_GEN:AUDSID")
         AND (di.info_name=dcdir_appl_rs->qual[dcdir_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing dm_info runner row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdir_appl_rs->qual[dcdir_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET dcdir_applx = (dcdir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   IF (dpl_ui_chk(dm2_process_rs->process_name)=0)
    RETURN(0)
   ENDIF
   IF ((((dm2_process_event_rs->ui_allowed_ind=1)) OR ((dm2_process_rs->process_name=dpl_sample))) )
    IF (drr_cleanup_process_event(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_process_event(null)
   DECLARE dcpe_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcpe_ndx = i4 WITH protect, noconstant(0)
   DECLARE dcpe_optimize_hint = vc WITH protect, noconstant("")
   DECLARE dcpe_optimize_hint1 = vc WITH protect, noconstant("")
   SET dcpe_optimize_hint = concat(" LEADING(DP DPE DPED)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)","INDEX(DPED XIE1DM_PROCESS_EVENT_DTL) ")
   SET dcpe_optimize_hint1 = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   IF (dpl_ui_chk(dm2_process_rs->process_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=0)
    AND (dm2_process_rs->process_name != dpl_sample))
    RETURN(1)
   ENDIF
   FREE RECORD dcpe_appl
   RECORD dcpe_appl(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
       2 plan_id = f8
       2 event_id = f8
       2 process_name = vc
       2 active_ind = i2
   )
   SET dm_err->eproc = "Getting distinct list of active processes in DM_PROCESS_EVENT..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.dm_process_id=dpe.dm_process_id
     AND dpe.dm_process_event_id=dped.dm_process_event_id
     AND dp.process_name IN (dpl_package_install, dpl_background_runner, dpl_install_runner,
    dpl_install_monitor, dpl_sample)
     AND (( NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_failure, dpl_success))) OR (dpe
    .event_status = null))
     AND dped.detail_type=dpl_audsid
    HEAD REPORT
     dcpe_appl->cnt = 0, stat = alterlist(dcpe_appl->qual,dcpe_appl->cnt)
    DETAIL
     dcpe_appl->cnt = (dcpe_appl->cnt+ 1), stat = alterlist(dcpe_appl->qual,dcpe_appl->cnt),
     dcpe_appl->qual[dcpe_appl->cnt].appl_id = dped.detail_text,
     dcpe_appl->qual[dcpe_appl->cnt].plan_id = dpe.install_plan_id, dcpe_appl->qual[dcpe_appl->cnt].
     event_id = dpe.dm_process_event_id, dcpe_appl->qual[dcpe_appl->cnt].process_name = dp
     .process_name,
     dcpe_appl->qual[dcpe_appl->cnt].active_ind = 1
    WITH nocounter, nullreport, orahintcbo(value(dcpe_optimize_hint))
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcpe_appl)
   ENDIF
   IF ((dcpe_appl->cnt > 0))
    FOR (dcpe_cnt = 1 TO dcpe_appl->cnt)
      IF ((dcpe_appl->qual[dcpe_cnt].active_ind=1))
       CASE (dm2_get_appl_status(value(dcpe_appl->qual[dcpe_cnt].appl_id)))
        OF "I":
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Application Id for event ",dcpe_appl->qual[dcpe_cnt].appl_id,
            " is not active."))
         ENDIF
         SET dm_err->eproc = "Mark appl_id for event as inactive"
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = value(dcpe_appl->cnt))
          PLAN (d
           WHERE d.seq > 0
            AND (dcpe_appl->qual[d.seq].appl_id=dcpe_appl->qual[dcpe_cnt].appl_id))
          DETAIL
           dcpe_appl->qual[d.seq].active_ind = 0
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Application Id for event ",dcpe_appl->qual[dcpe_cnt].appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 1))
          CALL echo("Error Detected in drr_cleanup_process_event")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No active processes found in DM_PROCESS_EVENT **********")
    ENDIF
    RETURN(1)
   ENDIF
   IF (locateval(dcpe_ndx,1,dcpe_appl->cnt,0,dcpe_appl->qual[dcpe_ndx].active_ind) > 0)
    SET dm_err->eproc = "Marking DM_PROCESS_EVENT rows as inactive"
    UPDATE  FROM dm_process_event dpe,
      (dummyt d  WITH seq = value(dcpe_appl->cnt))
     SET dpe.event_status = dpl_failed, dpe.message_txt = concat(dpe.message_txt,
       ": ACTIVE STATUS FOUND WITHOUT ACTIVE EVENT PROCESS")
     PLAN (d
      WHERE (dcpe_appl->qual[d.seq].active_ind=0))
      JOIN (dpe
      WHERE (dpe.dm_process_event_id=dcpe_appl->qual[d.seq].event_id)
       AND (( NOT (dpe.event_status IN (dpl_complete, dpl_failed))) OR (dpe.event_status = null))
       AND dpe.begin_dt_tm IS NOT null
       AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900"))
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
    IF (locateval(dcpe_ndx,1,dcpe_appl->cnt,dpl_package_install,dcpe_appl->qual[dcpe_ndx].
     process_name) > 0)
     FOR (dcpe_cnt = 1 TO dcpe_appl->cnt)
       IF ((dcpe_appl->qual[dcpe_ndx].process_name=dpl_package_install)
        AND (dcpe_appl->qual[dcpe_ndx].active_ind=0))
        SET dm_err->eproc =
        "Mark any package installs as inactive for package installs without active events "
        UPDATE  FROM dm_process_event dpe1
         SET dpe1.event_status = dpl_failed, dpe1.message_txt = concat(dpe1.message_txt,
           ": ACTIVE STATUS FOUND WITHOUT ACTIVE EVENT PROCESS")
         WHERE dpe1.dm_process_event_id IN (
         (SELECT
          dpe.dm_process_event_id
          FROM dm_process dp,
           dm_process_event dpe
          WHERE dp.process_name=dpl_package_install
           AND action_type=dpl_itinerary_event
           AND (dpe.install_plan_id=dcpe_appl->qual[dcpe_ndx].plan_id)
           AND (( NOT (dpe.event_status IN (dpl_complete, dpl_failed, dpl_success, dpl_failure))) OR
          (dpe.event_status = null))
           AND dpe.begin_dt_tm IS NOT null
           AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")
          WITH orahintcbo(value(dcpe_optimize_hint1))))
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
     ENDFOR
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_dm_info_sched_usage(null)
   DECLARE dcdisu_applx = i4 WITH protect, noconstant(0)
   FREE RECORD dcdisu_appl_rs
   RECORD dcdisu_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc =
   "Getting a distinct list of appl ids attached to a package install using installation schedule..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_char
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
    HEAD REPORT
     dcdisu_applx = 0
    DETAIL
     dcdisu_applx = (dcdisu_applx+ 1)
     IF (mod(dcdisu_applx,10)=1)
      stat = alterlist(dcdisu_appl_rs->qual,(dcdisu_applx+ 9))
     ENDIF
     dcdisu_appl_rs->qual[dcdisu_applx].appl_id = trim(di.info_char,3)
    FOOT REPORT
     dcdisu_appl_rs->cnt = dcdisu_applx, stat = alterlist(dcdisu_appl_rs->qual,dcdisu_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcdisu_appl_rs->cnt > 0))
    SET dcdisu_applx = 1
    WHILE ((dcdisu_applx <= dcdisu_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(dcdisu_appl_rs->qual[dcdisu_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(build("Application Id ",dcdisu_appl_rs->qual[dcdisu_applx].appl_id,
          " is not active."))
       ENDIF
       DELETE  FROM dm_info di
        WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
         AND (di.info_char=dcdisu_appl_rs->qual[dcdisu_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing dm_info pkg row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdisu_appl_rs->qual[dcdisu_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET dcdisu_applx = (dcdisu_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_stop_installs_using_flex_sched(null)
   DECLARE dsiufs_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dsiufs_work
   RECORD dsiufs_work(
     1 cnt = i4
     1 qual[*]
       2 plan_id = f8
       2 appl_id = vc
   )
   SET dm_err->eproc = "Stopping (inactivating) all package installs using installation schedule..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
     AND di.info_number > 0
    DETAIL
     dsiufs_work->cnt = (dsiufs_work->cnt+ 1), stat = alterlist(dsiufs_work->qual,dsiufs_work->cnt),
     dsiufs_work->qual[dsiufs_work->cnt].plan_id = abs(cnvtreal(di.info_name)),
     dsiufs_work->qual[dsiufs_work->cnt].appl_id = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    FOR (dsiufs_cnt = 1 TO dsiufs_work->cnt)
     IF (drr_modify_install_status(dsiufs_work->qual[dsiufs_cnt].plan_id,dsiufs_work->qual[dsiufs_cnt
      ].appl_id,0,concat("User ",curuser," requested stop of all Installs"),"STOP ALL INSTALLS")=0)
      RETURN(0)
     ENDIF
     IF ((dnotify->status=1)
      AND (dm2_process_event_rs->ui_allowed_ind=1))
      SET dnotify->process = "INSTALLPLAN"
      SET dnotify->plan_id = abs(dsiufs_work->qual[dsiufs_cnt].plan_id)
      SET dnotify->install_status = "STOPPED"
      SET dnotify->event = "Stopping All Active Install Plans"
      SET dnotify->msgtype = dpl_warning
      CALL dn_add_body_text(concat("User ",curuser,
        " has requested all Install Plans using the Installation ","Scheduler to Stop at ",format(
         cnvtdatetime(curdate,curtime3),";;q")),1)
      CALL dn_add_body_text(" ",0)
      CALL dn_add_body_text(concat("Install Plan ",trim(cnvtstring(dsiufs_work->qual[dsiufs_cnt].
          plan_id))," has been stopped"),0)
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = abs(dsiufs_work->qual[dsiufs_cnt].plan_id)
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,"EMAIL:STOP_FLEXSCHED_INSTALL")
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      IF (dn_notify(null)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_modify_install_status(dmis_plan_id,dmis_appl_id,dmis_status,dmis_reason,
  dmis_requester)
   DECLARE dmis_cur_status = i2 WITH protect, noconstant(- (1))
   DECLARE dmis_cur_applid = vc WITH protect, noconstant("")
   DECLARE dmis_msg = vc WITH protect, noconstant("")
   DECLARE dmis_event_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmis_status_changed_ind = i2 WITH protect, noconstant(0)
   IF (drr_get_process_status("DM2_INSTALL_PKG",dmis_plan_id,dmis_cur_status)=0)
    RETURN(0)
   ENDIF
   IF (dmis_cur_status=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Install in a Stop status. Exiting.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Obtain current appl_id for plan_id ",build(dmis_plan_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_PKG"
     AND cnvtreal(di.info_char)=dmis_plan_id
    DETAIL
     dmis_cur_applid = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmis_cur_status != dmis_status)
    SET dm_err->eproc = concat("Update DM2_INSTALL_PKG status for plan_id ",build(dmis_plan_id),
     " to ",build(dmis_status))
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_number = dmis_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)
       )
     WHERE di.info_domain="DM2_INSTALL_PKG"
      AND di.info_name=dmis_cur_applid
      AND cnvtreal(di.info_char)=dmis_plan_id
      AND di.info_number != dmis_status
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dmis_status_changed_ind = 1
    ELSE
     SET dm_err->eproc = concat("Install status for ",build(dmis_plan_id)," already set to ",build(
       dmis_status))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ENDIF
    IF (dmis_status_changed_ind=1)
     SET dm_err->eproc = concat("Update install status for plan_id ",build(dmis_plan_id)," to ",build
      (dmis_status))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = dmis_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3
         ))
      WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
       AND di.info_name=dmis_cur_applid
       AND di.info_char=trim(cnvtstring(dmis_plan_id))
       AND di.info_number != dmis_status
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dpl_ui_chk(dpl_package_install)=0)
      RETURN(0)
     ENDIF
     IF ((dm2_process_event_rs->ui_allowed_ind=1))
      SET dm_err->eproc = "Query for the process event id"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM dm_process dp,
        dm_process_event dpe,
        dm_process_event_dtl dped
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dpe.dm_process_event_id=dped.dm_process_event_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution
        AND dped.detail_type="AUDSID"
        AND dped.detail_text=dmis_appl_id
        AND dpe.install_plan_id=dmis_plan_id
       DETAIL
        dmis_event_id = dpe.dm_process_event_id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      CASE (dmis_status)
       OF 2:
        SET dmis_msg = "PAUSED"
       OF 0:
        SET dmis_msg = "STOPPED"
       OF 1:
        SET dmis_msg = "EXECUTING"
      ENDCASE
      SET dm_err->eproc = "Update the process event for the event status change"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      UPDATE  FROM dm_process_event dpe1
       SET dpe1.event_status = dmis_msg
       WHERE dpe1.dm_process_event_id=dmis_event_id
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dmis_status=2)
       SET dm_err->eproc = "Update status change reason"
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_process_event_dtl dtl
        SET dtl.detail_text = dmis_reason
        WHERE dtl.dm_process_event_id=dmis_event_id
         AND dtl.detail_type="LAST_STATUS_MESSAGE"
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        CALL dm2_process_log_add_detail_text("LAST_STATUS_MESSAGE",dmis_reason)
        SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date =
        cnvtdatetime(curdate,curtime3)
        IF (dm2_process_log_dtl_row(dmis_event_id,0)=0)
         ROLLBACK
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
      COMMIT
      SET dm_err->eproc = "Log installation status change event"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = dmis_plan_id
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,"MODIFY_INSTALL_STATUS")
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      CALL dm2_process_log_add_detail_text("NEW_STATUS",cnvtstring(dmis_status))
      CALL dm2_process_log_add_detail_text("OLD_STATUS",cnvtstring(dmis_cur_status))
      CALL dm2_process_log_add_detail_text("MENU_NAME",dmis_requester)
      CALL dm2_process_log_add_detail_text("STATUS_CHANGE_REASON",dmis_reason)
      IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
       RETURN(0)
      ENDIF
      CALL dpl_upd_dped_last_status(dmis_event_id,dmis_reason,0.0,cnvtdatetime(curdate,curtime3))
     ENDIF
    ENDIF
    IF (dmis_status IN (0, 2))
     IF (drr_stop_runners("ALL",0)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_stop_runners(dsr_mode,dsr_number)
   IF ( NOT (cnvtupper(dsr_mode) IN ("ALL", "LONG_RUNNING", "NUM_RUNNERS")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input mode for subroutine drr_stop_runners"
    SET dm_err->eproc = "Validating input mode."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dsr_mode IN ("LONG_RUNNING", "NUM_RUNNERS")
    AND dsr_number=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_stop_runners"
    SET dm_err->eproc = "Validating input number."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   DECLARE dsr_applx = i4 WITH protect, noconstant(0)
   DECLARE dsr_interval = vc WITH protect, noconstant(" ")
   FREE RECORD dsr_appl_rs
   RECORD dsr_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   IF (cnvtupper(dsr_mode)="ALL")
    SET dm_err->eproc = "Stopping (inactivating) all runners..."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (cnvtupper(dsr_mode)="LONG_RUNNING")
    SET dsr_interval = build(dsr_number,"H")
    SET dm_err->eproc = concat(
     "Getting a distinct list of appl ids attached to runners that have been running longer than ",
     trim(cnvtstring(dsr_number),3)," hour(s)...")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     di.info_name
     FROM dm_info di
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
      AND di.info_date <= cnvtdatetimeutc(cnvtdatetime(cnvtlookbehind(dsr_interval)))
     HEAD REPORT
      dsr_applx = 0
     DETAIL
      dsr_applx = (dsr_applx+ 1)
      IF (mod(dsr_applx,10)=1)
       stat = alterlist(dsr_appl_rs->qual,(dsr_applx+ 9))
      ENDIF
      dsr_appl_rs->qual[dsr_applx].appl_id = trim(di.info_name,3)
     FOOT REPORT
      dsr_appl_rs->cnt = dsr_applx, stat = alterlist(dsr_appl_rs->qual,dsr_appl_rs->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dsr_appl_rs->cnt > 0))
     SET dm_err->eproc = concat(
      "Stopping (inactivating) all runners that have been running longer than ",trim(cnvtstring(
        dsr_number),3)," hour(s)...")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di,
       (dummyt d  WITH seq = value(dsr_appl_rs->cnt))
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
      PLAN (d)
       JOIN (di
       WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
       "DM2_README_RUNNER")
        AND (di.info_name=dsr_appl_rs->qual[d.seq].appl_id))
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
   ELSE
    SET dm_err->eproc = concat("Getting the ",trim(cnvtstring(dsr_number))," oldest runner(s).")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     di.info_name
     FROM dm_info di
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
     ORDER BY di.info_date
     HEAD REPORT
      dsr_applx = 0
     DETAIL
      IF (dsr_applx < dsr_number)
       dsr_applx = (dsr_applx+ 1)
       IF (mod(dsr_applx,10)=1)
        stat = alterlist(dsr_appl_rs->qual,(dsr_applx+ 9))
       ENDIF
       dsr_appl_rs->qual[dsr_applx].appl_id = trim(di.info_name,3)
      ENDIF
     FOOT REPORT
      dsr_appl_rs->cnt = dsr_applx, stat = alterlist(dsr_appl_rs->qual,dsr_appl_rs->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dsr_appl_rs)
    ENDIF
    IF ((dsr_appl_rs->cnt > 0))
     SET dm_err->eproc = concat("Stopping the ",trim(cnvtstring(dsr_number))," oldest runner(s).")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di,
       (dummyt d  WITH seq = value(dsr_appl_rs->cnt))
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
      PLAN (d)
       JOIN (di
       WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
       "DM2_README_RUNNER")
        AND (di.info_name=dsr_appl_rs->qual[d.seq].appl_id))
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
 SUBROUTINE drr_start_runners(dstr_num_runners,dstr_user,dstr_pword,dstr_cnnct_str,dstr_queue_name)
   DECLARE dstr_connect_string = vc WITH protect, noconstant(" ")
   DECLARE dstr_file_name = vc WITH protect, noconstant(" ")
   DECLARE dstr_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE dstr_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE dstr_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE dstr_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE dstr_debug_flag = vc WITH protect, noconstant("0")
   DECLARE dstr_stat = i4 WITH protect, noconstant(0)
   IF (dstr_num_runners <= 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating input number - number of runners to start."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (((dstr_user=" ") OR (dstr_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid database connection information for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dstr_cnnct_str > " "
    AND dstr_cnnct_str != "NONE")
    SET dstr_connect_string = build("'",dstr_user,"/",dstr_pword,"@",
     dstr_cnnct_str,"'")
   ELSE
    SET dstr_connect_string = build("'",dstr_user,"/",dstr_pword,"'")
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=1))
    IF (dir_get_debug_trace_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dstr_debug_flag = cnvtstring(dm_err->debug_flag)
   FOR (dstr_loop_cnt = 1 TO dstr_num_runners)
     IF (get_unique_file("dm2_bckgrnd_runner_",".log")=0)
      RETURN(0)
     ENDIF
     SET dstr_logfile_name = dm_err->unique_fname
     SET dstr_file_name = replace(dstr_logfile_name,".log",".ksh",0)
     SET dm_err->eproc = "Creating job to execute background runner."
     SELECT INTO trim(dstr_file_name)
      DETAIL
       col 0, "#!/usr/bin/ksh", row + 1,
       col 0, "# Executing Background Runner...", row + 1,
       col 0, "#", row + 1,
       col 0, ". $cer_mgr/",
       CALL print(trim(cnvtlower(logical("environment")))),
       "_environment.ksh", row + 1, col 0,
       "ccl <<!", row + 1, col 0,
       "SET TRACE NORANGECACHE 0 go", row + 1, col 0,
       "free define oraclesystem go", row + 1, col 0,
       "define oraclesystem ", dstr_connect_string, " go"
       IF ((dir_ui_misc->auto_install_ind=1))
        IF ((dir_ui_misc->debug_level > 0))
         row + 1, col 0, "set dm2_debug_flag = ",
         dir_ui_misc->debug_level, " go"
        ENDIF
        IF ((dir_ui_misc->trace_flag=1))
         row + 1, col 0, "set trace rdbdebug go",
         row + 1, col 0, "set trace rdbbind go",
         row + 1, col 0, "set trace rdbbind2 go"
        ENDIF
       ELSE
        row + 1, col 0, "set dm2_debug_flag = ",
        dstr_debug_flag, " go"
       ENDIF
       row + 1, col 0, "dm2_background_runner '",
       dstr_user, "', '", dstr_pword,
       "', '", dstr_cnnct_str, "', 'PACKAGE' go",
       row + 1, col 0, "exit",
       row + 1, col 0, "!",
       row + 1, col 0, "sleep 30"
      WITH nocounter, maxrow = 1, format = variable,
       formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dstr_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",dstr_file_name)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("drr_start_runners changing permissions for ",dstr_file_name,".")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (dm2_push_dcl(dstr_chmod_cmd)=0)
      RETURN(0)
     ENDIF
     SET dstr_exec_cmd = concat("nohup ","$CCLUSERDIR/",dstr_file_name," > $CCLUSERDIR/",
      dstr_logfile_name,
      " 2>&1 &")
     SET dm_err->eproc = concat("Executing ",trim(dstr_file_name)," - results will be logged to ",
      trim(dstr_logfile_name),".")
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcl(dstr_exec_cmd,size(dstr_exec_cmd),dstr_stat)
     IF (dstr_stat=0)
      IF (parse_errfile(dstr_logfile_name)=0)
       RETURN(0)
      ENDIF
      SET dm_err->disp_msg_emsg = dm_err->errtext
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",dstr_exec_cmd)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dstr_exec_cmd = concat("ps -ef | grep ",dstr_file_name," | grep -v grep")
     SET dm_err->disp_dcl_err_ind = 0
     IF (dm2_push_dcl(dstr_exec_cmd)=0)
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(dstr_file_name,dm_err->errtext)=0)
      SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("Validating ",trim(dstr_file_name)," was successfully executed.")
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag < 3))
      IF (remove(dstr_file_name)=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Could not remove ",dstr_file_name," from ccluserdir.")
       SET dm_err->eproc = "Removing background ksh/com file from ccluserdir."
       CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_flexible_schedule(null)
   DECLARE dgfs_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgfs_idx = i4 WITH protect, noconstant(0)
   DECLARE dgfs_time_period = vc WITH protect, noconstant(" ")
   DECLARE dgfs_process = vc WITH protect, noconstant(" ")
   SET stat = alterlist(drr_flex_sched->readme_schedule,0)
   SET stat = alterlist(drr_flex_sched->schema_schedule,0)
   SET drr_flex_sched->readme_time_periods = 0
   SET drr_flex_sched->schema_time_periods = 0
   SET dm_err->eproc = "Getting installation schedule data..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    (di.info_domain, di.info_name, di.info_date,
    di.info_char, di.info_number)(SELECT
     "DM2_FLEXIBLE_SCHEDULE_README", do.info_name, do.info_date,
     do.info_char, do.info_number
     FROM dm_info do
     WHERE do.info_domain="DM2_FLEXIBLE_SCHEDULE"
      AND  NOT (do.info_name IN ("STATUS", "RUNNER TIME LIMIT")))
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   INSERT  FROM dm_info di
    (di.info_domain, di.info_name, di.info_date,
    di.info_char, di.info_number)(SELECT
     "DM2_FLEXIBLE_SCHEDULE_SCHEMA", do.info_name, do.info_date,
     do.info_char, do.info_number
     FROM dm_info do
     WHERE do.info_domain="DM2_FLEXIBLE_SCHEDULE"
      AND  NOT (do.info_name IN ("STATUS", "RUNNER TIME LIMIT")))
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_FLEXIBLE_SCHEDULE"
     AND  NOT (di.info_name IN ("STATUS", "RUNNER TIME LIMIT"))
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEXIBLE_SCHEDULE*"
    ORDER BY di.info_domain, di.updt_cnt
    HEAD di.info_domain
     dgfs_cnt = 0, dgfs_process = substring(23,textlen(di.info_domain),di.info_domain)
    DETAIL
     IF (di.info_name="STATUS")
      drr_flex_sched->sched_set_up = 1, drr_flex_sched->status = evaluate(cnvtupper(di.info_char),
       "ON",1,0)
     ENDIF
     IF (di.info_name="RUNNER TIME LIMIT")
      drr_flex_sched->runner_time_limit = di.info_number
     ENDIF
     IF (di.info_name="TIME PERIOD*")
      dgfs_time_period = trim(cnvtupper(substring(1,(findstring("-",di.info_name) - 1),di.info_name))
       )
      IF (dgfs_process="README")
       dgfs_idx = 0
       IF (dgfs_cnt > 0)
        dgfs_idx = locateval(dgfs_idx,1,dgfs_cnt,dgfs_time_period,drr_flex_sched->readme_schedule[
         dgfs_idx].time_period)
       ENDIF
       IF (dgfs_idx=0)
        dgfs_cnt = (dgfs_cnt+ 1)
        IF (mod(dgfs_cnt,5)=1)
         stat = alterlist(drr_flex_sched->readme_schedule,(dgfs_cnt+ 4))
        ENDIF
        dgfs_idx = dgfs_cnt
       ENDIF
       drr_flex_sched->readme_schedule[dgfs_idx].time_period = dgfs_time_period
       IF (findstring("START",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->readme_schedule[dgfs_idx].start_time = di.info_number
       ELSEIF (findstring("END",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->readme_schedule[dgfs_idx].end_time = di.info_number
       ELSE
        drr_flex_sched->readme_schedule[dgfs_idx].num_of_runners = di.info_number
       ENDIF
      ELSEIF (dgfs_process="SCHEMA")
       dgfs_idx = 0
       IF (dgfs_cnt > 0)
        dgfs_idx = locateval(dgfs_idx,1,dgfs_cnt,dgfs_time_period,drr_flex_sched->schema_schedule[
         dgfs_idx].time_period)
       ENDIF
       IF (dgfs_idx=0)
        dgfs_cnt = (dgfs_cnt+ 1)
        IF (mod(dgfs_cnt,5)=1)
         stat = alterlist(drr_flex_sched->schema_schedule,(dgfs_cnt+ 4))
        ENDIF
        dgfs_idx = dgfs_cnt
       ENDIF
       drr_flex_sched->schema_schedule[dgfs_idx].time_period = dgfs_time_period
       IF (findstring("START",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->schema_schedule[dgfs_idx].start_time = di.info_number
       ELSEIF (findstring("END",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->schema_schedule[dgfs_idx].end_time = di.info_number
       ELSE
        drr_flex_sched->schema_schedule[dgfs_idx].num_of_runners = di.info_number
       ENDIF
      ENDIF
     ENDIF
    FOOT  di.info_domain
     IF (dgfs_process="README")
      drr_flex_sched->readme_time_periods = dgfs_cnt, stat = alterlist(drr_flex_sched->
       readme_schedule,drr_flex_sched->readme_time_periods)
     ELSEIF (dgfs_process="SCHEMA")
      drr_flex_sched->schema_time_periods = dgfs_cnt, stat = alterlist(drr_flex_sched->
       schema_schedule,drr_flex_sched->schema_time_periods)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET drr_flex_sched->sched_set_up = 0
    SET drr_flex_sched->status = 0
   ENDIF
   IF ((drr_flex_sched->runner_time_limit=- (1)))
    SET drr_flex_sched->runner_time_limit = 10
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(drr_flex_sched)
   ENDIF
   IF ((dm_err->debug_flag > 622))
    SET message = nowindow
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL echorecord(drr_flex_sched)
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_use_flexible_schedule(dufs_prompt_ind,dufs_pkg_number,dufs_install_mode,dufs_sel_ret)
   DECLARE dufs_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dufs_choice = vc WITH protect, noconstant(" ")
   DECLARE dufs_idx = i2 WITH protect, noconstant(0)
   DECLARE dufs_hold_time = vc WITH protect, noconstant("")
   SET dufs_sel_ret = ""
   IF ((( NOT (dufs_prompt_ind IN (0, 1))) OR (((dufs_install_mode=" ") OR (dufs_pkg_number=" ")) ))
   )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input for subroutine drr_use_flexible_schedule"
    SET dm_err->eproc = "Validating information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->pkg_number="DM2NOTSET"))
    SET drr_flex_sched->pkg_number = dufs_pkg_number
   ENDIF
   IF ((drr_flex_sched->pkg_install_mode="DM2NOTSET"))
    SET drr_flex_sched->pkg_install_mode = dufs_install_mode
   ENDIF
   IF (currdb != "ORACLE")
    SET dm_err->eproc =
    "Package will not attempt to use installation schedule because RDBMS is not Oracle"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF ( NOT ((drr_flex_sched->pkg_install_mode IN ("BATCHUP", "BATCHPRECYCLE", "BATCHDOWN",
   "BATCHPOST", "BATCHEXPRESS"))))
    SET dm_err->eproc = "Package will not attempt to use installation schedule due to install mode."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (drr_cleanup_dm_info_sched_usage(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_get_flexible_schedule(null)=0)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->status=0))
    SET dm_err->eproc =
    "Package will not use installation schedule because it's not set up or currently turned on."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (dm2_rr_toolset_usage(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->dm2_toolset_usage="N"))
    SET dm_err->eproc =
    "Package will not use installation schedule because old dm tools being used for readme processing"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (dufs_prompt_ind=1)
    WHILE ( NOT (dufs_choice IN ("C", "Q")))
      SET message = window
      SET width = 132
      CALL clear(1,1)
      CALL video(n)
      CALL text(2,1,"Installation Scheduler: ",w)
      CALL text(4,1,concat("Please confirm Installation Scheduler configuration:"))
      CALL text(6,1,concat("Status:",evaluate(drr_flex_sched->status,0,"OFF","ON")))
      CALL text(6,12,"README(R) SCHEMA(S)")
      CALL text(9,1,"(R)")
      SET dufs_line_cnt = 8
      CALL text(dufs_line_cnt,5,"Time Slot")
      CALL text(dufs_line_cnt,18,"Start Time")
      CALL text(dufs_line_cnt,34,"End Time")
      CALL text(dufs_line_cnt,49,"Num Runners")
      FOR (dufs_idx = 1 TO drr_flex_sched->readme_time_periods)
        SET dufs_line_cnt = (dufs_line_cnt+ 1)
        SET drr_flex_sched->readme_schedule[dufs_idx].time_period = cnvtstring(dufs_idx)
        SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hhmm = drr_flex_sched->
        readme_schedule[dufs_idx].start_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->readme_schedule[dufs_idx].
          start_time_hhmm,"HH;;s"))
        SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->readme_schedule[dufs_idx].start_time_hh=0))
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hhmm = drr_flex_sched->
        readme_schedule[dufs_idx].end_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->readme_schedule[dufs_idx].end_time_hhmm,
          "HH;;s"))
        SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->readme_schedule[dufs_idx].end_time_hh=0))
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->readme_schedule[dufs_idx].num_of_runners = drr_flex_sched->
        readme_schedule[dufs_idx].num_of_runners
        CALL text(dufs_line_cnt,5,cnvtstring(dufs_idx))
        CALL text(dufs_line_cnt,19,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].start_time_hh
          ))
        CALL text(dufs_line_cnt,22,drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm)
        CALL text(dufs_line_cnt,34,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].end_time_hh))
        CALL text(dufs_line_cnt,37,drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm)
        CALL text(dufs_line_cnt,49,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].
          num_of_runners))
      ENDFOR
      SET dufs_line_cnt = (dufs_line_cnt+ 1)
      CALL text(dufs_line_cnt,1,"(S)")
      FOR (dufs_idx = 1 TO drr_flex_sched->schema_time_periods)
        IF (dufs_idx != 1)
         SET dufs_line_cnt = (dufs_line_cnt+ 1)
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].time_period = cnvtstring(dufs_idx)
        SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hhmm = drr_flex_sched->
        schema_schedule[dufs_idx].start_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->schema_schedule[dufs_idx].
          start_time_hhmm,"HH;;s"))
        SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->schema_schedule[dufs_idx].start_time_hh=0))
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hhmm = drr_flex_sched->
        schema_schedule[dufs_idx].end_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->schema_schedule[dufs_idx].end_time_hhmm,
          "HH;;s"))
        SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->schema_schedule[dufs_idx].end_time_hh=0))
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].num_of_runners = drr_flex_sched->
        schema_schedule[dufs_idx].num_of_runners
        CALL text(dufs_line_cnt,5,cnvtstring(dufs_idx))
        CALL text(dufs_line_cnt,19,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].start_time_hh
          ))
        CALL text(dufs_line_cnt,22,drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm)
        CALL text(dufs_line_cnt,34,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].end_time_hh))
        CALL text(dufs_line_cnt,37,drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm)
        CALL text(dufs_line_cnt,49,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].
          num_of_runners))
      ENDFOR
      SET dufs_line_cnt = (dufs_line_cnt+ 2)
      CALL text(dufs_line_cnt,1,concat("(C)ontinue with above schedule, (M)odify, (Q)uit :"))
      CALL accept(dufs_line_cnt,53,"A;cu"," "
       WHERE curaccept IN ("Q", "C", "M"))
      SET dufs_choice = curaccept
      SET dufs_sel_ret = dufs_choice
      SET message = nowindow
      IF (dufs_choice="M")
       EXECUTE dm2_flexible_schedule_menu
       IF ((dm_err->err_ind > 0))
        RETURN(0)
       ENDIF
       IF (drr_get_flexible_schedule(null)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
   IF ((drr_flex_sched->status=1))
    SET dm_err->eproc =
    "Determining if DM_INFO row to denote the package is using the installation schedule exists..."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_char = currdbhandle,
      di.info_number = 1,
      di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.updt_applctx = 0, di
      .updt_cnt = 0,
      di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
      AND (di.info_name=drr_flex_sched->pkg_number)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->eproc =
     "Inserting DM_INFO row to denote the package is using the installation schedule..."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_FLEX_SCHED_USAGE", di.info_name = drr_flex_sched->pkg_number, di
       .info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
       di.info_char = currdbhandle, di.info_number = 1, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(
         curdate,curtime3)),
       di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
       di.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ELSE
     COMMIT
    ENDIF
    SET drr_flex_sched->pkg_using_schedule = 1
   ELSE
    SET drr_flex_sched->pkg_using_schedule = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_maintain_runners(dmr_user,dmr_pword,dmr_cnnct_str,dmr_queue_name,dm_process)
   DECLARE dmr_curtime_hhmm = f8 WITH protect, noconstant(0.0)
   DECLARE dmr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dmr_env_name = vc WITH protect, noconstant(" ")
   DECLARE dmr_time_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dmr_process_status = i2 WITH protect, noconstant(0)
   SET drr_flex_sched->num_sched_runners = 0
   SET drr_flex_sched->num_active_runners = 0
   SET drr_flex_sched->num_runners_to_stop = 0
   SET drr_flex_sched->num_runners_to_start = 0
   SET drr_flex_sched->num_stopping_runners = 0
   SET drr_flex_sched->tot_num_runners = 0
   IF (((dmr_user=" ") OR (dmr_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid database connection information for subroutine drr_maintain_runners"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->pkg_using_schedule=1)
    AND (dm2_process_event_rs->ui_allowed_ind=1))
    IF (drr_get_process_status("DM2_INSTALL_MONITOR",abs(cnvtreal(drr_flex_sched->pkg_number)),
     dmr_process_status)=0)
     RETURN(0)
    ENDIF
    IF (dmr_process_status=0)
     IF (drr_submit_background_process(dm2_install_schema->u_name,dm2_install_schema->p_word,
      dm2_install_schema->connect_str,dmr_queue_name,dpl_install_monitor,
      cnvtreal(drr_flex_sched->pkg_number),drr_flex_sched->pkg_install_mode)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_get_flexible_schedule(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_stop_runners("LONG_RUNNING",drr_flex_sched->runner_time_limit)=0)
    RETURN(0)
   ENDIF
   SET dmr_curtime_hhmm = curtime
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("CUrrent time in HHMM = ",dmr_curtime_hhmm))
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc =
    "Determining how many runners should be running based on installation schedule..."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm_process="README")
    SET time_periods = drr_flex_sched->readme_time_periods
   ELSEIF (dm_process="SCHEMA")
    SET time_periods = drr_flex_sched->schema_time_periods
   ENDIF
   FOR (dmr_cnt = 1 TO time_periods)
    IF (dm_process="README")
     SET curalias schedule drr_flex_sched->readme_schedule[dmr_cnt]
    ELSEIF (dm_process="SCHEMA")
     SET curalias schedule drr_flex_sched->schema_schedule[dmr_cnt]
    ENDIF
    IF ((schedule->start_time=schedule->end_time))
     SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
     SET dmr_cnt = time_periods
     SET dmr_time_fnd_ind = 1
    ELSEIF ((schedule->start_time < schedule->end_time))
     IF ((dmr_curtime_hhmm >= schedule->start_time)
      AND (dmr_curtime_hhmm < schedule->end_time))
      SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
      SET dmr_cnt = time_periods
      SET dmr_time_fnd_ind = 1
     ENDIF
    ELSE
     IF ((((dmr_curtime_hhmm >= schedule->start_time)
      AND dmr_curtime_hhmm < 2400) OR (dmr_curtime_hhmm >= 0000
      AND (dmr_curtime_hhmm < schedule->end_time))) )
      SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
      SET dmr_cnt = time_periods
      SET dmr_time_fnd_ind = 1
     ENDIF
    ENDIF
   ENDFOR
   IF (dmr_time_fnd_ind=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Number of runners could not be retrieved for current time."
    SET dm_err->eproc = "Retrieving number of runners to execute from installation schedule."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSE
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat(trim(cnvtstring(drr_flex_sched->num_sched_runners)),
      " runner(s) should be running.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Determining how many runners are actively running..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_BACKGROUND_RUNNER"
    DETAIL
     IF (di.info_number=1)
      drr_flex_sched->num_active_runners = (drr_flex_sched->num_active_runners+ 1)
     ELSE
      drr_flex_sched->num_stopping_runners = (drr_flex_sched->num_stopping_runners+ 1)
     ENDIF
     drr_flex_sched->tot_num_runners = (drr_flex_sched->tot_num_runners+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat(trim(cnvtstring(drr_flex_sched->num_active_runners)),
     " runner(s) currently running.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((drr_flex_sched->tot_num_runners=drr_flex_sched->num_sched_runners))
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc =
     "Currently running the specified number of runners from installation schedule..."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF ((drr_flex_sched->tot_num_runners > drr_flex_sched->num_sched_runners))
    IF ((drr_flex_sched->num_active_runners=0))
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat(
       "No active runners to stop at this time: All existing runners have been marked to stop.")
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ENDIF
    ELSEIF ((drr_flex_sched->num_active_runners < drr_flex_sched->tot_num_runners))
     IF ((drr_flex_sched->num_active_runners <= drr_flex_sched->num_sched_runners))
      SET drr_flex_sched->num_runners_to_stop = drr_flex_sched->num_active_runners
      IF ((dm_err->debug_flag > 0))
       SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop
          ))," active runner(s)...")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
       RETURN(0)
      ENDIF
     ELSE
      SET drr_flex_sched->num_runners_to_stop = (drr_flex_sched->num_active_runners - (drr_flex_sched
      ->num_sched_runners - drr_flex_sched->num_stopping_runners))
      IF ((dm_err->debug_flag > 0))
       SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop
          ))," active runner(s)...")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ELSEIF ((drr_flex_sched->num_active_runners=drr_flex_sched->tot_num_runners))
     SET drr_flex_sched->num_runners_to_stop = (drr_flex_sched->num_active_runners - drr_flex_sched->
     num_sched_runners)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop)
        )," active runner(s)...")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET drr_flex_sched->num_runners_to_start = (drr_flex_sched->num_sched_runners - drr_flex_sched->
    tot_num_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Need to start ",trim(cnvtstring(drr_flex_sched->num_runners_to_start
        ))," runner(s)...")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (drr_start_runners(drr_flex_sched->num_runners_to_start,dmr_user,dmr_pword,dmr_cnnct_str,
     dmr_queue_name)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
   SET curalias schedule off
 END ;Subroutine
 SUBROUTINE drr_check_pkg_appl_status(dcpas_appl_id,dcpas_pkg_status)
   SET dm_err->eproc =
   "Determining if appl id attached to a package install using installation schedule is active."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
     AND di.info_char=dcpas_appl_id
     AND di.info_number=1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcpas_pkg_status = 1
   ELSE
    SET dcpas_pkg_status = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_check_runner_status(dcrs_runner_type,dcrs_appl_id,dcrs_status)
   SET dm_err->eproc = "Evaluating whether the runner has been marked to stop."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dcrs_status = 0
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dcrs_runner_type
     AND di.info_name=dcrs_appl_id
    DETAIL
     dcrs_status = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_insert_runner_row(dirr_runner_type,dirr_appl_id,dirr_desc,dirr_status,dirr_plan_id)
   DECLARE dirr_process_name = vc WITH protect, noconstant("NOTSET")
   CASE (dirr_runner_type)
    OF "DM2_INSTALL_RUNNER":
     SET dirr_process_name = dpl_install_runner
    OF "DM2_BACKGROUND_RUNNER":
     SET dirr_process_name = dpl_background_runner
    OF "DM2_INSTALL_PKG":
     SET dirr_process_name = dpl_package_install
    OF "DM2_INSTALL_MONITOR":
     SET dirr_process_name = dpl_install_monitor
    OF "DM2_ADS_DRIVER_GEN:AUDSID":
     SET dirr_process_name = dpl_sample
    OF "DM2_ADS_CHILDEST_GEN:AUDSID":
     SET dirr_process_name = dpl_sample
    OF "DM2_ADS_RUNNER:AUDSID":
     SET dirr_process_name = dpl_sample
   ENDCASE
   IF (dpl_ui_chk(dirr_process_name)=0)
    RETURN(0)
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=1)
    AND dirr_process_name != "NOTSET")
    SET dm2_process_event_rs->install_plan_id = dirr_plan_id
    SET dm2_process_event_rs->status = dpl_executing
    CALL dm2_process_log_add_detail_text(dpl_logfilemain,dm_err->logfile)
    SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime(
     curdate,curtime3)
    CALL dm2_process_log_add_detail_text(dpl_audsid,currdbhandle)
    CASE (dirr_process_name)
     OF dpl_install_runner:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",0.0)
      CALL dm2_process_log_add_detail_number("SCHEDULER_IND",0.0)
     OF dpl_background_runner:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",1.0)
      CALL dm2_process_log_add_detail_number("SCHEDULER_IND",1.0)
     OF dpl_install_monitor:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",1.0)
    ENDCASE
    SET dm2_process_rs->process_name = dirr_process_name
    CALL dm2_process_log_row(dirr_process_name,dpl_execution,dpl_no_prev_id,1)
    SET dir_ui_misc->dm_process_event_id = dm2_process_event_rs->dm_process_event_id
    SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->install_plan_id = dirr_plan_id
    SET dm2_process_event_rs->status = dpl_complete
    CALL dm2_process_log_add_detail_text(dpl_audit_name,concat(dirr_process_name,"-STARTED"))
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dirr_process_name=dpl_sample)
    SET dm2_process_event_rs->status = dpl_executing
    CALL dm2_process_log_add_detail_text(dpl_logfilemain,dm_err->logfile)
    SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime(
     curdate,curtime3)
    CALL dm2_process_log_add_detail_text(dpl_audsid,currdbhandle)
    SET dm2_process_rs->process_name = dirr_process_name
    CALL dm2_process_log_row(dirr_process_name,dpl_execution,dpl_no_prev_id,1)
    SET dir_ui_misc->dm_process_event_id = dm2_process_event_rs->dm_process_event_id
   ENDIF
   SET dm_err->eproc = concat("Determining if DM_INFO runner row for ",trim(dirr_runner_type,3),
    " and appl id ",trim(dirr_appl_id,3)," exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dirr_runner_type
     AND di.info_name=dirr_appl_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Inserting DM_INFO runner row for ",trim(dirr_runner_type,3),
     " and appl id ",trim(dirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = dirr_runner_type, di.info_name = dirr_appl_id, di.info_date =
      cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.info_char =
      IF (dirr_runner_type IN ("DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR")) trim(cnvtstring(
         dirr_plan_id))
      ELSE dirr_desc
      ENDIF
      , di.info_number = dirr_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    SET dm_err->eproc = concat("Updating DM_INFO runner row for ",trim(dirr_runner_type,3),
     " and appl id ",trim(dirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_char =
      IF (dirr_runner_type IN ("DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR")) trim(cnvtstring(
         dirr_plan_id))
      ELSE dirr_desc
      ENDIF
      , di.info_number = dirr_status,
      di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.updt_applctx = 0, di
      .updt_cnt = 0,
      di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WHERE di.info_domain=dirr_runner_type
      AND di.info_name=dirr_appl_id
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_remove_runner_row(drrr_runner_type,drrr_appl_id)
   DECLARE drrr_process_name = vc WITH protect, noconstant("")
   DECLARE drrr_install_plan_number = f8 WITH protect, noconstant(0.0)
   DECLARE drrr_err_ind = i2 WITH protect, noconstant(0)
   DECLARE drrr_emsg = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrr_eproc = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrr_optimizer_hint = vc WITH protect, noconstant("")
   SET drrr_err_ind = dm_err->err_ind
   SET drrr_emsg = dm_err->emsg
   SET drrr_eproc = dm_err->eproc
   SET dm_err->err_ind = 0
   SET dm_err->emsg = ""
   SET dm_err->eproc = ""
   SET drrr_optimizer_hint = concat(" LEADING(DP DPE )","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   CASE (drrr_runner_type)
    OF "DM2_INSTALL_RUNNER":
     SET drrr_process_name = dpl_install_runner
    OF "DM2_BACKGROUND_RUNNER":
     SET drrr_process_name = dpl_background_runner
    OF "DM2_INSTALL_PKG":
     SET drrr_process_name = dpl_package_install
    OF "DM2_INSTALL_MONITOR":
     SET drrr_process_name = dpl_install_monitor
    OF "DM2_ADS_DRIVER_GEN:AUDSID":
     SET drrr_process_name = dpl_sample
    OF "DM2_ADS_CHILDEST_GEN:AUDSID":
     SET drrr_process_name = dpl_sample
    OF "DM2_ADS_RUNNER:AUDSID":
     SET drrr_process_name = dpl_sample
   ENDCASE
   IF (drrr_process_name=dpl_sample)
    IF ((((dm_err->err_ind=0)) OR ((dm_err->debug_flag > 0))) )
     SET dm_err->eproc = "Update process event to appropriate status"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = evaluate(drrr_err_ind,1,"FAILED","COMPLETE"), dpe.message_txt = evaluate(
       drrr_err_ind,1,substring(1,1900,drrr_emsg),"Removed runner row")
     WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   CALL dpl_ui_chk(drrr_process_name)
   IF ((dm2_process_event_rs->ui_allowed_ind=1))
    IF ((((dm_err->err_ind=0)) OR ((dm_err->debug_flag > 0))) )
     SET dm_err->eproc = "Update process event to appropriate status"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = evaluate(drrr_err_ind,1,"FAILED","COMPLETE"), dpe.message_txt = evaluate(
       drrr_err_ind,1,substring(1,1900,drrr_emsg),"Removed runner row")
     WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
    IF (drrr_err_ind=1
     AND drrr_process_name=dpl_package_install)
     IF ((dm_err->err_ind=0))
      SET dm_err->eproc = "Obtain the Install_Plan_Id for the AudSid"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain="DM2_INSTALL_PKG"
        AND di.info_name=drrr_appl_id
       DETAIL
        drrr_install_plan_number = cnvtreal(di.info_char)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ENDIF
     ENDIF
     IF (curqual > 0)
      IF ((dm_err->err_ind=0))
       SET dm_err->eproc = "Update the event status for the removed runners"
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_process_event dpe1
        SET dpe1.event_status = dpl_failed, dpe1.message_txt = dm_err->emsg
        WHERE dpe1.dm_process_event_id IN (
        (SELECT
         dpe.dm_process_event_id
         FROM dm_process dp,
          dm_process_event dpe
         WHERE dp.dm_process_id=dpe.dm_process_id
          AND dp.process_name=dpl_package_install
          AND dp.action_type=dpl_itinerary_event
          AND dpe.install_plan_id=drrr_install_plan_number
          AND (( NOT (dpe.event_status IN (dpl_success, dpl_complete, dpl_failure, dpl_failed))) OR (
         dpe.event_status = null))
          AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")
          AND dpe.begin_dt_tm IS NOT null
         WITH orahintcbo(value(drrr_optimizer_hint))))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((dm_err->err_ind=0))
     SET dm_err->eproc = "Obtain the Install_Plan_Id from DM_PROCESS_EVENT"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_process_event dpe
      WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
      DETAIL
       drrr_install_plan_number = dpe.install_plan_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
    IF ((dm_err->err_ind=0))
     IF (curqual > 0)
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = drrr_install_plan_number
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,concat(drrr_process_name,evaluate(
         drrr_err_ind,0,"-COMPLETE","-FAILED")))
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      CALL dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->err_ind=0))
    SET dm_err->eproc = concat("Remove DM_INFO runner row for ",trim(drrr_runner_type,3),
     " and appl id ",trim(drrr_appl_id,3))
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain=drrr_runner_type
      AND di.info_name=drrr_appl_id
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->err_ind = drrr_err_ind
   SET dm_err->emsg = drrr_emsg
   SET dm_err->eproc = drrr_eproc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_insert_runner_row(drirr_runner_identifier,drirr_appl_id)
   IF (drr_rr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Determining if Admin DM_INFO runner row for ",trim(
     drirr_runner_identifier,3)," and appl id ",trim(drirr_appl_id,3)," exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drirr_runner_identifier
     AND di.info_name=drirr_appl_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Inserting Admin DM_INFO runner row for ",trim(drirr_runner_identifier,
      3)," and appl id ",trim(drirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di
     SET di.info_domain = drirr_runner_identifier, di.info_name = drirr_appl_id, di.info_date =
      cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.info_number = 1, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di
      .updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    SET dm_err->eproc = concat("Updating Admin DM_INFO runner row for ",trim(drirr_runner_identifier,
      3)," and appl id ",trim(drirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm2_admin_dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_number = 1, di
      .updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = reqinfo->updt_task
     WHERE di.info_domain=drirr_runner_identifier
      AND di.info_name=drirr_appl_id
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_check_runner_status(drcrs_runner_identifier,drcrs_appl_id,drcrs_status)
   SET dm_err->eproc = concat("Evaluating whether main/runner session (",drcrs_runner_identifier,
    ") has been marked to stop.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET drcrs_status = 0
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drcrs_runner_identifier
     AND di.info_name=drcrs_appl_id
    DETAIL
     drcrs_status = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_cleanup_dm_info_runners(null)
   DECLARE drcdir_applx = i4 WITH protect, noconstant(0)
   FREE RECORD drcdir_appl_rs
   RECORD drcdir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Getting a distinct list of appl ids attached to a replicate runner..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm2_admin_dm_info di
    WHERE di.info_domain IN ("RR_RUNNER*", "RR_MAIN*")
    HEAD REPORT
     drcdir_applx = 0
    DETAIL
     drcdir_applx = (drcdir_applx+ 1)
     IF (mod(drcdir_applx,10)=1)
      stat = alterlist(drcdir_appl_rs->qual,(drcdir_applx+ 9))
     ENDIF
     drcdir_appl_rs->qual[drcdir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     drcdir_appl_rs->cnt = drcdir_applx, stat = alterlist(drcdir_appl_rs->qual,drcdir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drcdir_appl_rs->cnt > 0))
    SET drcdir_applx = 1
    WHILE ((drcdir_applx <= drcdir_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(drcdir_appl_rs->qual[drcdir_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",drcdir_appl_rs->qual[drcdir_applx].appl_id,
          " is not active."))
       ENDIF
       DELETE  FROM dm2_admin_dm_info di
        WHERE di.info_domain IN ("RR_RUNNER*", "RR_MAIN*")
         AND (di.info_name=drcdir_appl_rs->qual[drcdir_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing Admin dm_info runner row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",drcdir_appl_rs->qual[drcdir_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET drcdir_applx = (drcdir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_remove_runner_row(drrrr_runner_identifier,drrrr_appl_id)
   DECLARE drrrr_err_ind = i2 WITH protect, noconstant(0)
   DECLARE drrrr_emsg = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrrr_eproc = vc WITH protect, noconstant("DM2NOTSET")
   SET drrrr_err_ind = dm_err->err_ind
   SET drrrr_emsg = dm_err->emsg
   SET drrrr_eproc = dm_err->eproc
   SET dm_err->err_ind = 0
   SET dm_err->emsg = ""
   SET dm_err->eproc = ""
   SET dm_err->eproc = concat("Remove Admin DM_INFO runner row for ",trim(drrrr_runner_identifier,3),
    " and appl id ",trim(drrrr_appl_id,3))
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain=drrrr_runner_identifier
     AND di.info_name=drrrr_appl_id
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
   SET dm_err->err_ind = drrrr_err_ind
   SET dm_err->emsg = drrrr_emsg
   SET dm_err->eproc = drrrr_eproc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_maintain_runners(drmr_user,drmr_pword,drmr_cnnct_str,drmr_runners,
  drmr_runner_identifier)
   DECLARE drmr_active_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_stopping_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_total_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_num_runners_to_start = i2 WITH protect, noconstant(0)
   IF (drr_rr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = concat(trim(cnvtstring(drmr_runners))," runner(s) should be running.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "Determining how many background runners are running..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drmr_runner_identifier
    DETAIL
     IF (di.info_number=1)
      drmr_active_runners = (drmr_active_runners+ 1)
     ELSE
      drmr_stopping_runners = (drmr_stopping_runners+ 1)
     ENDIF
     drmr_total_runners = (drmr_total_runners+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("Total Runners:    ",trim(cnvtstring(drmr_total_runners))))
    CALL echo(concat("Active Runners:   ",trim(cnvtstring(drmr_active_runners))))
    CALL echo(concat("Stopping Runners: ",trim(cnvtstring(drmr_stopping_runners))))
   ENDIF
   IF (drmr_stopping_runners > 0)
    SET dm_err->eproc = "Validating status of replicate background runners."
    SET dm_err->emsg = "Background runners have been marked to stop, exiting process."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drmr_total_runners=drmr_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = "Currently running the specified number of runners..."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (drmr_total_runners < drmr_runners)
    SET drmr_num_runners_to_start = (drmr_runners - drmr_total_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Need to start ",trim(cnvtstring(drmr_num_runners_to_start)),
      " runner(s)...")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (drr_rr_start_runners(drmr_num_runners_to_start,drmr_user,drmr_pword,drmr_cnnct_str,
     drmr_runner_identifier)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_start_runners(drstr_num_runners,drstr_user,drstr_pword,drstr_cnnct_str,
  drstr_identifier)
   DECLARE drstr_connect_string = vc WITH protect, noconstant(" ")
   DECLARE drstr_file_name = vc WITH protect, noconstant(" ")
   DECLARE drstr_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE drstr_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE drstr_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE drstr_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE drstr_debug_flag = vc WITH protect, noconstant("0")
   DECLARE drstr_stat = i4 WITH protect, noconstant(0)
   DECLARE drstr_logfile_ident = vc WITH protect, noconstant(" ")
   DECLARE drstr_name = vc WITH protect, noconstant(" ")
   IF (drstr_num_runners <= 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_rr_start_runners"
    SET dm_err->eproc = "Validating input number - number of runners to start."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (((drstr_user=" ") OR (((drstr_pword=" ") OR (drstr_identifier=" ")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating input passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drstr_cnnct_str > " "
    AND drstr_cnnct_str != "NONE")
    SET drstr_connect_string = build("'",drstr_user,"/",drstr_pword,"@",
     drstr_cnnct_str,"'")
   ELSE
    SET drstr_connect_string = build("'",drstr_user,"/",drstr_pword,"'")
   ENDIF
   CALL echo(concat("connect string = ",drstr_connect_string))
   SET drstr_debug_flag = cnvtstring(dm_err->debug_flag)
   FOR (drstr_loop_cnt = 1 TO drstr_num_runners)
     IF (findstring("ccluserdir",drrr_misc_data->active_dir,1,1) > 0)
      SET drstr_name = "dm2_rrr_bckgrnd_"
     ELSE
      SET drstr_name = "dm2_rrr_background_"
     ENDIF
     IF (get_unique_file(drstr_name,".ksh")=0)
      RETURN(0)
     ENDIF
     SET drstr_logfile_name = replace(dm_err->unique_fname,".ksh",".log",0)
     SET drstr_logfile_ident = replace(dm_err->unique_fname,drstr_name,"",0)
     SET drstr_logfile_ident = build("'",trim(replace(drstr_logfile_ident,".log","",0),3),"'")
     SET drstr_file_name = dm_err->unique_fname
     SET drstr_logfile_name = build(drrr_misc_data->active_dir,drstr_logfile_name)
     SET dm_err->eproc = concat("Creating job (",drstr_file_name,") to execute background runner.")
     SELECT INTO trim(drstr_file_name)
      DETAIL
       col 0, "#!/usr/bin/ksh", row + 1,
       col 0, "# Executing Replicate/Refresh Background Runner...", row + 1,
       col 0, "#", row + 1,
       col 0, ". $cer_mgr/",
       CALL print(trim(cnvtlower(logical("environment")))),
       "_environment.ksh", row + 1, col 0,
       "ccl <<!", row + 1, col 0,
       "free define oraclesystem go", row + 1, col 0,
       "define oraclesystem ", drstr_connect_string, " go",
       row + 1, col 0, "set dm2_debug_flag = ",
       drstr_debug_flag, " go", row + 1,
       col 0, "set dm2_rrr_log_identifier = ", drstr_logfile_ident,
       " go", row + 1, col 0,
       "dm2_background_runner '", drstr_user, "', '",
       drstr_pword, "', '", drstr_cnnct_str,
       "', '", drstr_identifier, "' go",
       row + 1, col 0, "exit",
       row + 1, col 0, "!",
       row + 1, col 0, "sleep 30"
      WITH nocounter, maxrow = 1, format = variable,
       formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET drstr_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",drstr_file_name)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("drr_rr_start_runners changing permissions for ",drstr_file_name,"."
       )
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (dm2_push_dcl(drstr_chmod_cmd)=0)
      RETURN(0)
     ENDIF
     SET drstr_exec_cmd = concat("nohup ","$CCLUSERDIR/",drstr_file_name," > ",drstr_logfile_name,
      " 2>&1 &")
     CALL echo(concat("exec_cmd = ",drstr_exec_cmd))
     SET dm_err->eproc = concat("Executing ",trim(drstr_file_name)," - results will be logged to ",
      trim(drstr_logfile_name),".")
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcl(drstr_exec_cmd,size(drstr_exec_cmd),drstr_stat)
     IF (drstr_stat=0)
      IF (parse_errfile(drstr_logfile_name)=0)
       RETURN(0)
      ENDIF
      SET dm_err->disp_msg_emsg = dm_err->errtext
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",drstr_exec_cmd)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET drstr_exec_cmd = concat("ps -ef | grep ",drstr_file_name," | grep -v grep")
     SET dm_err->disp_dcl_err_ind = 0
     IF (dm2_push_dcl(drstr_exec_cmd)=0)
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(drstr_file_name,dm_err->errtext)=0)
      SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("Validating ",trim(drstr_file_name)," was successfully executed.")
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag < 3))
      IF (remove(drstr_file_name)=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Could not remove ",drstr_file_name," from ccluserdir.")
       SET dm_err->eproc = "Removing replicate/refresh background ksh file from ccluserdir."
       CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_adm_dm_info_runners(dcadir_dblink)
   DECLARE dcadir_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dcadir_applx = i4 WITH protect, noconstant(0)
   DECLARE dcadir_appl_status = vc WITH protect, noconstant("")
   RECORD dcadir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Getting a distinct list of admin appl ids attached to a runner."
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM (value(concat("DM_INFO@",dcadir_dblink)) di)
    WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
    HEAD REPORT
     dcadir_applx = 0
    DETAIL
     dcadir_applx = (dcadir_applx+ 1)
     IF (mod(dcadir_applx,10)=1)
      stat = alterlist(dcadir_appl_rs->qual,(dcadir_applx+ 9))
     ENDIF
     dcadir_appl_rs->qual[dcadir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     dcadir_appl_rs->cnt = dcadir_applx, stat = alterlist(dcadir_appl_rs->qual,dcadir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcadir_appl_rs->cnt > 0))
    SET dcadir_applx = 1
    WHILE ((dcadir_applx <= dcadir_appl_rs->cnt))
      IF (dir_get_adm_appl_status(dcadir_dblink,value(dcadir_appl_rs->qual[dcadir_applx].appl_id),
       dcadir_appl_status)=0)
       RETURN(0)
      ENDIF
      CASE (dcadir_appl_status)
       OF "INACTIVE":
        IF ((dm_err->debug_flag > 1))
         CALL echo(concat("Admin Application Id is",dcadir_appl_rs->qual[dcadir_applx].appl_id,
           " is not active."))
        ENDIF
        SET dm_err->eproc = "Removing dm_info runner row(s) - admin appl id no longer active.."
        IF ((dm_err->debug_flag > 1))
         CALL disp_msg(" ",dm_err->logfile,0)
        ENDIF
        DELETE  FROM (value(concat("DM_INFO@",dcadir_dblink)) di)
         WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
          AND (di.info_name=dcadir_appl_rs->qual[dcadir_applx].appl_id)
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       OF "ACTIVE":
        IF ((dm_err->debug_flag > 1))
         CALL echo(concat("Admin Application Id is",dcadir_appl_rs->qual[dcadir_applx].appl_id,
           " is active."))
        ENDIF
      ENDCASE
      SET dcadir_applx = (dcadir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_chk_active_runners(dcar_dblink,dcar_count_ind)
   SET dcar_count_ind = 0
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_cleanup_adm_dm_info_runners(dcar_dblink)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check for active background runners"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN ("DM2_SCHEMA_RUNNER", "DM2_README_RUNNER")
    WITH nocounter, maxqual(di,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcar_count_ind = 1
   ELSE
    SET dm_err->eproc = "Check for active admin background runners"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (value(concat("DM_INFO@",dcar_dblink)) di)
     WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
     WITH nocounter, maxqual(di,1)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcar_count_ind = 1
    ENDIF
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
 SUBROUTINE dipr_update_install_itinerary(duit_status,duit_itin_id,duit_plan_id)
   DECLARE duit_msg = vc WITH protect, noconstant("")
   DECLARE duit_optimizer_hint = vc WITH protect, noconstant("")
   SET duit_optimizer_hint = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   CASE (duit_status)
    OF 2:
     SET duit_msg = "PAUSED"
    OF 0:
     SET duit_msg = "STOPPED"
    OF 1:
     SET duit_msg = "EXECUTING"
   ENDCASE
   IF (duit_itin_id=0)
    SET dm_err->eproc = "Update itinerary status"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe1
     SET dpe1.event_status = duit_msg, dpe1.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE dpe1.dm_process_event_id IN (
     (SELECT
      dpe.dm_process_event_id
      FROM dm_process dp,
       dm_process_event dpe
      WHERE dp.dm_process_id=dpe.dm_process_id
       AND dp.process_name=dpl_package_install
       AND dp.action_type=dpl_itinerary_event
       AND dpe.install_plan_id=duit_plan_id
       AND  NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_success, dpl_failure))
       AND ((dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")) OR (dpe.begin_dt_tm = null))
      WITH orahintcbo(value(duit_optimizer_hint))))
      AND dpe1.event_status != duit_msg
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Update itinerary status for event_id"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = duit_msg, dpe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE dpe.dm_process_event_id=duit_itin_id
      AND dpe.event_status != duit_msg
     WITH nocounter
    ;end update
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
 SUBROUTINE dipr_setup_install_itinerary(dsit_plan_id,dsit_plan_type)
   DECLARE dsit_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsit_ndx = i4 WITH protect, noconstant(0)
   SET dip_itin_rs->itin_cnt = 0
   SET stat = alterlist(dip_itin_rs->itin_step,dip_itin_rs->itin_cnt)
   SET dip_itin_rs->install_plan_id = dsit_plan_id
   SET stat = alterlist(dip_itin_rs->itin_step,9)
   CALL dipr_add_itin_step("BATCHUP",1,1,"Setup","BATCHUP:SETUP")
   CALL dipr_add_itin_step("BATCHUP",1,2,"Code Sets","BATCHUP:CODE_SETS")
   CALL dipr_add_itin_step("BATCHUP",1,3,"Pre-Schema Readmes","BATCHUP:PRE-SCHEMA_READMES")
   CALL dipr_add_itin_step("BATCHUP",1,4,"Schema","BATCHUP:SCHEMA")
   CALL dipr_add_itin_step("BATCHUP",1,5,"Application / Task / Request (ATRs)","BATCHUP:ATRS")
   CALL dipr_add_itin_step("BATCHUP",1,6,"Purge Templates","BATCHUP:PURGE_TEMPLATES")
   CALL dipr_add_itin_step("BATCHUP",1,7,"Post-Schema Readmes","BATCHUP:POST-SCHEMA_READMES")
   IF (dsit_plan_type="NO-DT")
    CALL dipr_add_itin_step("BATCHPRECYCLE",1,2,"Readmes","BATCHPRECYCLE:READMES")
   ENDIF
   IF (dsit_plan_type != "NO-DT")
    CALL dipr_add_itin_step("BATCHDOWN",1,2,"Readmes","BATCHDOWN:READMES")
   ENDIF
   CALL dipr_add_itin_step("BATCHPOST",1,2,"Readmes","BATCHPOST:READMES")
   SET dm_err->eproc = "Query for itinerary information"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.process_name=dpl_package_install
     AND dp.action_type=dpl_itinerary_event
     AND dpe.dm_process_id=dp.dm_process_id
     AND (dpe.install_plan_id=dip_itin_rs->install_plan_id)
     AND dped.dm_process_event_id=dpe.dm_process_event_id
     AND dped.detail_type="ITINERARY_KEY"
    DETAIL
     dsit_ndx = locateval(dsit_ndx,1,dip_itin_rs->itin_cnt,dped.detail_text,dip_itin_rs->itin_step[
      dsit_ndx].itinerary_key)
     IF (dsit_ndx > 0)
      dip_itin_rs->itin_step[dsit_ndx].dm_process_event_id = dpe.dm_process_event_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   FOR (dsit_cnt = 1 TO dip_itin_rs->itin_cnt)
     IF ((dip_itin_rs->itin_step[dsit_cnt].dm_process_event_id=0))
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
      SET dm2_process_event_rs->install_plan_id = dsit_plan_id
      CALL dm2_process_log_add_detail_text("ITINERARY_KEY",dip_itin_rs->itin_step[dsit_cnt].
       itinerary_key)
      CALL dm2_process_log_add_detail_text("INSTALL_MODE",dip_itin_rs->itin_step[dsit_cnt].
       install_mode)
      CALL dm2_process_log_add_detail_text("STEP_NAME",dip_itin_rs->itin_step[dsit_cnt].step_name)
      CALL dm2_process_log_add_detail_number("STEP_NUMBER",cnvtreal(dip_itin_rs->itin_step[dsit_cnt].
        step_number))
      CALL dm2_process_log_add_detail_number("LEVEL_NUMBER",cnvtreal(dip_itin_rs->itin_step[dsit_cnt]
        .level_number))
      IF (dm2_process_log_row(dpl_package_install,dpl_itinerary_event,dpl_no_prev_id,1)=0)
       RETURN(0)
      ENDIF
      SET dip_itin_rs->itin_step[dsit_cnt].dm_process_event_id = dm2_process_event_rs->
      dm_process_event_id
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_add_itin_step(dais_mode,dais_level,dais_step_nbr,dais_step_name,dais_itin_key)
   SET dip_itin_rs->itin_cnt = (dip_itin_rs->itin_cnt+ 1)
   SET stat = alterlist(dip_itin_rs->itin_step,dip_itin_rs->itin_cnt)
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].install_mode = dais_mode
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].level_number = dais_level
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_number = dais_step_nbr
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_name = dais_step_name
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].itinerary_key = dais_itin_key
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_get_install_itinerary(dgit_plan_id)
   SET dip_itin_rs->install_plan_id = dgit_plan_id
   SET dm_err->eproc = "Load itinerary data from process tables"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.dm_process_id=dpe.dm_process_id
     AND dp.process_name=dpl_package_install
     AND dp.action_type=dpl_itinerary_event
     AND (dpe.install_plan_id=dip_itin_rs->install_plan_id)
     AND dpe.dm_process_event_id=dped.dm_process_event_id
    ORDER BY dpe.dm_process_event_id, dped.detail_type
    HEAD REPORT
     dip_itin_rs->itin_cnt = 0
    HEAD dpe.dm_process_event_id
     dip_itin_rs->itin_cnt = (dip_itin_rs->itin_cnt+ 1), stat = alterlist(dip_itin_rs->itin_step,
      dip_itin_rs->itin_cnt), dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].dm_process_event_id = dpe
     .dm_process_event_id
    DETAIL
     CASE (dped.detail_type)
      OF dpl_install_mode:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].install_mode = dped.detail_text,
       IF (cnvtdatetime(dpe.begin_dt_tm) > cnvtdatetime("01-JAN-1900"))
        dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].begin_dt_tm = cnvtdatetime(dpe.begin_dt_tm)
       ENDIF
       ,
       IF (cnvtdatetime(dpe.end_dt_tm) > cnvtdatetime("01-JAN-1900"))
        dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].end_dt_tm = cnvtdatetime(dpe.end_dt_tm)
       ENDIF
       ,dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].event_status = dpe.event_status
      OF dpl_itinerary_key:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].itinerary_key = dped.detail_text
      OF dpl_step_number:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_number = dped.detail_number
      OF dpl_level:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].level_number = dped.detail_number
      OF dpl_step_name:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_name = dped.detail_text
      OF dpl_parent_step_name:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].parent_step_name = dped.detail_text
      OF dpl_parent_level_number:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].parent_level_number = dped.detail_number
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_get_plan_nbr(null)
   DECLARE dgpn_continue = i2 WITH protect, noconstant(1)
   DECLARE dgpn_invalid = i2 WITH protect, noconstant(0)
   DECLARE dgpn_notfound = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Obtaining Plan ID"
   WHILE (dgpn_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"INSTALL PLAN MENU [GET PLAN]")
     IF (dgpn_invalid=1)
      CALL text(4,2,concat(drr_flex_sched->pkg_number," is an Invalid Plan ID. Please Retry."))
      SET dgpn_invalid = 0
     ELSEIF (dgpn_notfound=1)
      CALL text(4,2,concat("Install activity not found for Install Plan Number: ",drr_flex_sched->
        pkg_number,". Please Retry"))
      SET dgpn_notfound = 0
     ENDIF
     CALL text(5,2,"Install Plan ID: ")
     SET help = pos(5,50,10,60)
     SET help =
     SELECT DISTINCT INTO "nl:"
      plan_id = install_plan_id
      FROM dm_install_plan
      ORDER BY install_plan_id DESC
      WITH nocounter
     ;end select
     CALL accept(5,20,"9(11);F")
     SET drr_flex_sched->pkg_number = cnvtstring(abs(curaccept))
     CALL text(7,2,"(C)ontinue, (M)odify, (B)ack :")
     CALL accept(7,34,"p;cu","C"
      WHERE curaccept IN ("C", "M", "B"))
     SET message = nowindow
     CASE (curaccept)
      OF "B":
       SET dm_err->emsg = "Plan ID was not provided"
       SET dm_err->err_ind = 1
       SET dgpn_continue = 0
      OF "C":
       CALL text(8,2,"Validating Install Plan...")
       SET dm_err->eproc = "Verifying that Install Plan ID exists"
       SELECT INTO "nl:"
        FROM dm_install_plan dip
        WHERE dip.install_plan_id=cnvtreal(drr_flex_sched->pkg_number)
        WITH nocounter, maxqual(dip,1)
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL dipr_disp_error_msg(null)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET dgpn_invalid = 1
       ELSE
        SET dm_err->eproc = "Verifying that Install Plan ID has current activity"
        SELECT INTO "nl:"
         FROM dm_process dp,
          dm_process_event dpe
         PLAN (dp
          WHERE dp.process_name=value(dpl_package_install)
           AND dp.action_type=value(dpl_execution)
           AND dp.program_name="DM2_INSTALL_PKG")
          JOIN (dpe
          WHERE dp.dm_process_id=dpe.dm_process_id
           AND dpe.install_plan_id=cnvtreal(drr_flex_sched->pkg_number))
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL dipr_disp_error_msg(null)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET dgpn_continue = 0
        ELSE
         SET dgpn_notfound = 1
        ENDIF
       ENDIF
      OF "M":
       SET dgpn_continue = 1
     ENDCASE
   ENDWHILE
   SET dipm_misc_data->install_plan_id = cnvtreal(drr_flex_sched->pkg_number)
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_disp_error_msg(null)
   SET message = nowindow
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dipr_get_cur_dpe_data(dgcdd_install)
   SET dipm_misc_data->cur_mode = "DM2NOTSET"
   SET dm_err->eproc = "Retrieving most recent dm_process_event row for package install execution"
   IF ((dm_err->debug_flag > 0))
    CALL dipr_disp_error_msg(null)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    PLAN (dpe
     WHERE dpe.install_plan_id=dgcdd_install)
     JOIN (dp
     WHERE dpe.dm_process_id=dp.dm_process_id
      AND dp.process_name=value(dpl_package_install)
      AND dp.action_type=value(dpl_execution)
      AND dp.program_name="DM2_INSTALL_PKG")
     JOIN (dped
     WHERE dpe.dm_process_event_id=dped.dm_process_event_id
      AND dped.detail_type=value(dpl_install_mode))
    ORDER BY dpe.begin_dt_tm DESC
    HEAD REPORT
     cur_dpe_set = 0
    DETAIL
     IF (cur_dpe_set=0)
      IF (cnvtupper(trim(dped.detail_text)) != "BATCHPREVIEW")
       cur_dpe_set = 1
      ENDIF
      IF (cnvtupper(dipm_misc_data->cur_mode) != cnvtupper(trim(dped.detail_text)))
       dipm_misc_data->cur_dpe_id = dpe.dm_process_event_id, dir_ui_misc->dm_process_event_id = dpe
       .dm_process_event_id, dipm_misc_data->cur_dpe_status = dpe.event_status,
       dipm_misc_data->cur_mode = cnvtupper(trim(dped.detail_text))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = "Unable to retrieve current package install execution"
    SET dm_err->err_ind = 1
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dipr_setup_install_itinerary(dsit_plan_id=f8,dsit_plan_type=vc) = i2
 DECLARE dipr_add_itin_step(dais_mode=vc,dais_level=i2,dais_step_nbr=i2,dais_step_name=vc,
  dais_itin_key=vc) = i2
 DECLARE dipr_get_install_itinerary(dgit_plan_id=f8) = i2
 DECLARE dipr_update_install_itinerary(duit_status=i2,duit_itin_id=f8,duit_plan_id=f8) = i2
 DECLARE dipr_get_cur_dpe_data(dgcdd_install_plan=f8) = i2
 DECLARE dipr_get_plan_nbr(null) = i2
 DECLARE dipr_disp_error_msg(null) = i2
 IF ((validate(dip_itin_rs->itin_cnt,- (1))=- (1))
  AND (validate(dip_itin_rs->itin_cnt,- (2))=- (2)))
  FREE RECORD dip_itin_rs
  RECORD dip_itin_rs(
    1 install_plan_id = f8
    1 itin_cnt = i4
    1 itin_step[*]
      2 dm_process_event_id = f8
      2 event_status = vc
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 message_txt = vc
      2 itinerary_key = vc
      2 install_mode = vc
      2 level_number = i2
      2 step_number = i4
      2 step_name = vc
      2 parent_step_name = vc
      2 parent_level_number = i2
  )
 ENDIF
 IF ((validate(dipm_misc_data->install_plan_id,- (1))=- (1))
  AND (validate(dipm_misc_data->install_plan_id,- (2))=- (2)))
  FREE RECORD dipm_misc_data
  RECORD dipm_misc_data(
    1 install_plan_id = f8
    1 cur_dpe_id = f8
    1 cur_mode = vc
    1 cur_itin_dpe_id = f8
    1 cur_appl_id = f8
    1 cur_method = vc
    1 cur_dpe_status = vc
    1 cur_install_event = vc
  )
  SET dipm_misc_data->install_plan_id = 0.0
  SET dipm_misc_data->cur_dpe_id = 0.0
  SET dipm_misc_data->cur_mode = "DM2NOTSET"
  SET dipm_misc_data->cur_itin_dpe_id = 0.0
  SET dipm_misc_data->cur_appl_id = 0.0
  SET dipm_misc_data->cur_method = "DM2NOTSET"
  SET dipm_misc_data->cur_dpe_status = "DM2NOTSET"
  SET dipm_misc_data->cur_install_event = "DM2NOTSET"
 ENDIF
 SUBROUTINE dn_get_notify_settings(null)
   DECLARE dgns_type = vc WITH protect, noconstant("")
   DECLARE dgns_error_reset_ind = i2 WITH protect, noconstant(0)
   DECLARE dgns_emsg = vc WITH protect, noconstant("")
   DECLARE dgns_eproc = vc WITH protect, noconstant("")
   DECLARE dgns_user_action = vc WITH protect, noconstant("")
   IF ((dm_err->err_ind=1))
    SET dgns_error_reset_ind = 1
    SET dgns_emsg = dm_err->emsg
    SET dgns_eproc = dm_err->eproc
    SET dgns_user_action = dm_err->user_action
    SET dm_err->err_ind = 0
    SET dm_err->emsg = ""
   ENDIF
   IF ((dnotify->client="DM2NOTSET"))
    SET dm_err->eproc = "Get Client Mnemonic."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      dnotify->client = trim(cnvtupper(d.info_char))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to retrieve Client Mnemonic."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     IF (dgns_error_reset_ind=1)
      CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dnotify->env_name="DM2NOTSET"))
    SET dm_err->eproc = "Get Environment Name."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_NAME"
     DETAIL
      dnotify->env_name = trim(cnvtupper(d.info_char))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to retrieve Environment Name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     IF (dgns_error_reset_ind=1)
      CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   SET dnotify->email_cnt = 0
   SET stat = alterlist(dnotify->email,0)
   SET dnotify->email_address_list = ""
   SET dnotify->status = 0
   SET dnotify->test_single_ind = 0
   SET dnotify->test_email_failed = 0
   SET dm_err->eproc = "Retrieve current automated notification settings from DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2NOTIFY"
    ORDER BY i.info_name
    DETAIL
     dgns_type = i.info_name
     IF (substring(1,5,dgns_type)="EMAIL")
      dgns_type = "EMAIL"
     ENDIF
     CASE (dgns_type)
      OF "STATUS":
       dnotify->status = i.info_number
      OF "EMAIL":
       IF (trim(dnotify->email_address_list,3)="")
        dnotify->email_address_list = trim(cnvtupper(i.info_char),3)
       ELSE
        dnotify->email_address_list = concat(dnotify->email_address_list,",",trim(cnvtupper(i
           .info_char),3))
       ENDIF
       ,dnotify->email_cnt = (dnotify->email_cnt+ 1),stat = alterlist(dnotify->email,dnotify->
        email_cnt),dnotify->email[dnotify->email_cnt].address = trim(cnvtupper(i.info_char),3)
      OF "SUPPRESSION_FLAG":
       dnotify->suppression_flag = i.info_number
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,1)
    IF (dgns_error_reset_ind=1)
     CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
    ENDIF
    RETURN(0)
   ENDIF
   IF (dgns_error_reset_ind=1)
    CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_save_notify_settings(null)
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
   ENDIF
   DECLARE dsns_email_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Delete existing automated notification settings from DM_INFO."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DELETE  FROM dm_info
    WHERE info_domain="DM2NOTIFY"
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Write current automated notification settings to DM_INFO."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info i
    SET i.info_domain = "DM2NOTIFY", i.info_name = "STATUS", i.info_number = dnotify->status,
     i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   INSERT  FROM dm_info i
    SET i.info_domain = "DM2NOTIFY", i.info_name = "METHOD", i.info_char = trim(dnotify->
      install_method,3),
     i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dnotify->email_address_list = ""
   FOR (dsns_email_cnt = 1 TO dnotify->email_cnt)
     INSERT  FROM dm_info i
      SET i.info_domain = "DM2NOTIFY", i.info_name = concat("EMAIL",cnvtstring(dsns_email_cnt)), i
       .info_char = dnotify->email[dsns_email_cnt].address,
       i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg("",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dnotify->email[dsns_email_cnt].new_ind=1))
      IF (trim(dnotify->email_address_list,3)="")
       SET dnotify->email_address_list = trim(dnotify->email[dsns_email_cnt].address,3)
      ELSE
       SET dnotify->email_address_list = concat(dnotify->email_address_list,",",trim(dnotify->email[
         dsns_email_cnt].address,3))
      ENDIF
     ENDIF
   ENDFOR
   INSERT  FROM dm_info i
    SET i.info_domain = "DM2NOTIFY", i.info_name = "SUPPRESSION_FLAG", i.info_number = dnotify->
     suppression_flag,
     i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   SET dm2_process_event_rs->install_plan_id = 0
   SET dm2_process_event_rs->status = dpl_complete
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
   CALL dm2_process_log_add_detail_text(dpl_audit_name,"NOTIFICATION_CHANGED")
   CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
   CALL dm2_process_log_add_detail_number("STATUS",cnvtreal(dnotify->status))
   FOR (dsns_email_cnt = 1 TO dnotify->email_cnt)
     CALL dm2_process_log_add_detail_text(concat("EMAIL",cnvtstring(dsns_email_cnt)),dnotify->email[
      dsns_email_cnt].address)
   ENDFOR
   CALL dm2_process_log_row(dpl_notification,dpl_auditlog,dpl_no_prev_id,1)
   SET dnotify->test_single_ind = 1
   SET dnotify->process = "TEST NOTIFICATION"
   SET dnotify->install_status = "N/A"
   SET dnotify->msgtype = "N/A"
   SET dnotify->file_name = dn_test_file_name
   CALL dn_add_body_text("This is a test email.",1)
   SET dm2_process_event_rs->install_plan_id = 0
   SET dm2_process_event_rs->status = dpl_complete
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
   CALL dm2_process_log_add_detail_text(dpl_audit_name,"EMAIL: NOTIFICATION_CHANGED")
   CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
   IF (dn_notify(null)=0)
    SET dnotify->test_email_failed = 1
   ENDIF
   FOR (dsns_email_cnt = 1 TO dnotify->email_cnt)
     IF ((dnotify->email[dsns_email_cnt].new_ind=1))
      SET dnotify->email[dsns_email_cnt].new_ind = 0
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_confirm_install_notification(dcin_ret_action)
   DECLARE dcin_row = i4 WITH protect, noconstant(0)
   DECLARE dcin_email_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcin_error_reset_ind = i2 WITH protect, noconstant(0)
   DECLARE dcin_emsg = vc WITH protect, noconstant("")
   DECLARE dcin_eproc = vc WITH protect, noconstant("")
   DECLARE dcin_user_action = vc WITH protect, noconstant("")
   DECLARE dcin_continue = i2 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET dcin_error_reset_ind = 1
    SET dcin_emsg = dm_err->emsg
    SET dcin_eproc = dm_err->eproc
    SET dcin_user_action = dm_err->user_action
    SET dm_err->err_ind = 0
    SET dm_err->emsg = ""
   ENDIF
   SET dcin_continue = 1
   WHILE (dcin_continue)
     SET dm_err->eproc = "Confirm automated notification settings."
     CALL disp_msg("",dm_err->logfile,0)
     IF (dn_get_notify_settings(null)=0)
      IF (dcin_error_reset_ind=1)
       CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
      ENDIF
      RETURN(0)
     ENDIF
     SET width = 132
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Please modify any Automated Notification Settings at this time.")
     SET dcin_row = 2
     IF ((dnotify->status=0)
      AND (dnotify->install_method="UNATTENDED"))
      SET dcin_row = (dcin_row+ 2)
      CALL text(dcin_row,2,"For Unattended Installs, Automated Notification Status must be ON.")
     ENDIF
     SET dcin_row = (dcin_row+ 2)
     CALL text(dcin_row,2,concat("Status : ",evaluate(dnotify->status,1,"ON","OFF")))
     IF ((dnotify->status=1))
      SET dcin_row = (dcin_row+ 1)
      CALL text(dcin_row,2,concat("DDL retry alert Status : ",evaluate(dnotify->suppression_flag,0,
         "ON","OFF")))
     ENDIF
     SET dcin_row = (dcin_row+ 1)
     CALL text(dcin_row,2,"Email addresses :")
     FOR (dcin_email_cnt = 1 TO dnotify->email_cnt)
       IF (dcin_email_cnt < 14)
        SET dcin_row = (dcin_row+ 1)
        CALL text(dcin_row,2,concat(trim(cnvtstring(dcin_email_cnt)),") ",trim(dnotify->email[
           dcin_email_cnt].address)))
       ELSE
        SET dcin_row = (dcin_row+ 1)
        CALL text(dcin_row,2,"Please use (M) option to review all email addresses...")
       ENDIF
     ENDFOR
     CALL text(23,2,"(C)ontinue, (M)odify Notification Settings, (Q)uit: ")
     CALL accept(23,60,"P;CU"," "
      WHERE curaccept IN ("C", "M", "Q"))
     IF (curaccept="M")
      SET dcin_ret_action = "M"
      EXECUTE dm2_install_plan_menu_notify
      IF ((dm_err->err_ind=1))
       IF (dcin_error_reset_ind=1)
        CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
       ENDIF
       RETURN(0)
      ENDIF
     ELSEIF (curaccept="C")
      SET dcin_ret_action = "C"
      SET dcin_continue = 0
     ELSEIF (curaccept="Q")
      SET dcin_ret_action = "Q"
      SET dcin_continue = 0
      SET dm_err->eproc = "Confirm automated notification settings."
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "User choose to Quit."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      IF (dcin_error_reset_ind=1)
       CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
      ENDIF
      RETURN(0)
     ENDIF
   ENDWHILE
   IF (dcin_error_reset_ind=1)
    CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
   ENDIF
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_notify(null)
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
   ENDIF
   DECLARE dn_line = vc WITH protect, noconstant("")
   DECLARE dn_cnt = i4 WITH protect, noconstant(0)
   DECLARE dn_error_reset_ind = i2 WITH protect, noconstant(0)
   DECLARE dn_emsg = vc WITH protect, noconstant("")
   DECLARE dn_eproc = vc WITH protect, noconstant("")
   DECLARE dn_user_action = vc WITH protect, noconstant("")
   DECLARE dn_dclcmd = vc WITH protect, noconstant("")
   DECLARE dn_status = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET dn_error_reset_ind = 1
    SET dn_emsg = dm_err->emsg
    SET dn_eproc = dm_err->eproc
    SET dn_user_action = dm_err->user_action
    SET dm_err->err_ind = 0
    SET dm_err->emsg = ""
   ENDIF
   IF ((dnotify->test_single_ind=0))
    IF (dn_get_notify_settings(null)=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((dnotify->email_address_list="")) OR ((dnotify->email_address_list="DM2NOTSET"))) )
    SET dm_err->emsg = concat(
     "Notification is bypassed due to notification email is not set up.  Subject: ",dnotify->
     email_subject)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ENDIF
    RETURN(1)
   ENDIF
   SET dnotify->email_subject = concat(evaluate(dnotify->process,"DM2NOTSET","N/A",trim(dnotify->
      process)),", MSGTYPE: ",evaluate(dnotify->msgtype,"DM2NOTSET","N/A",trim(dnotify->msgtype)),
    ", STATUS: ",evaluate(dnotify->install_status,"DM2NOTSET","N/A",trim(dnotify->install_status)),
    ", ENV: ",evaluate(dnotify->env_name,"DM2NOTSET","N/A",trim(dnotify->env_name)))
   IF ((dm_err->debug_flag > 0))
    CALL echo(dnotify->email_subject)
   ENDIF
   SET dm_err->eproc = "Generate email notification."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF ((dnotify->status != 1))
    SET dm_err->emsg = concat(
     "Notification is bypassed due to notification status is OFF.  Subject: ",dnotify->email_subject)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ENDIF
    RETURN(1)
   ENDIF
   IF (((trim(dnotify->file_name)="") OR (trim(dnotify->file_name)="DM2NOTSET")) )
    IF (get_unique_file("dm2notify",".dat")=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
    SET dnotify->file_name = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Generate file ",dnotify->file_name)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(dnotify->file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     IF ((dnotify->test_single_ind=0))
      dn_line = concat("PLAN_ID: ",evaluate(cnvtstring(dnotify->plan_id),"-1","N/A",trim(cnvtstring(
          dnotify->plan_id))),", CLIENT: ",evaluate(dnotify->client,"DM2NOTSET","N/A",trim(dnotify->
         client)),", MODE: ",
       evaluate(dnotify->mode,"DM2NOTSET","N/A",trim(dnotify->mode)),", EVENT: ",evaluate(dnotify->
        event,"DM2NOTSET","N/A",trim(dnotify->event)),", EMAIL DT/TM: ",format(cnvtdatetime(curdate,
         curtime3),";;q")),
      CALL print(dn_line), row + 1,
      row + 2
     ENDIF
     FOR (dn_cnt = 1 TO dnotify->body_cnt)
      CALL print(dnotify->body[dn_cnt].txt),row + 1
     ENDFOR
    WITH nocounter, maxcol = 2000, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Failed to create file ",dnotify->file_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dn_dclcmd = concat('MAIL/SUBJECT="',build(dnotify->email_subject),'" ',build(dnotify->
      file_name),' "',
     build(dnotify->email_address_list),'"')
   ELSEIF ((dm2_sys_misc->cur_os IN ("AIX", "LNX")))
    SET dn_dclcmd = concat('mail -s "',dnotify->email_subject,'" "',dnotify->email_address_list,
     '" < ',
     dnotify->file_name)
   ELSEIF ((dm2_sys_misc->cur_os="HPX"))
    SET dn_dclcmd = concat('mailx -s "',dnotify->email_subject,'" "',dnotify->email_address_list,
     '" < ',
     dnotify->file_name)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("email command : ",dn_dclcmd))
    CALL echorecord(dnotify)
   ENDIF
   SET dn_status = 0
   CALL dcl(dn_dclcmd,size(dn_dclcmd),dn_status)
   IF (dn_status=0)
    SET dm_err->eproc = concat("Email ",dnotify->file_name," to address : ",dnotify->
     email_address_list)
    SET dm_err->emsg = "Failed to send email notification."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ELSE
     SET dm_err->err_ind = 1
    ENDIF
    RETURN(0)
   ELSE
    CALL dm2_process_log_add_detail_text("EMAIL_SUBJECT",dn_line)
    FOR (dn_cnt = 1 TO dnotify->body_cnt)
      SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
      SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
      SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = "BODY"
      SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = trim(
       substring(1,1500,dnotify->body[dn_cnt].txt))
      SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = dn_cnt
    ENDFOR
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dnotify->email_subject = "DM2NOTSET"
   SET dnotify->process = "DM2NOTSET"
   SET dnotify->install_status = "DM2NOTSET"
   SET dnotify->event = "DM2NOTSET"
   SET dnotify->msgtype = "DM2NOTSET"
   SET stat = alterlist(dnotify->body,0)
   SET dnotify->body_cnt = 0
   IF (dn_error_reset_ind=1)
    CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
   ENDIF
   SET dnotify->test_single_ind = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_add_body_text(dabt_in_text,dabt_in_reset_ind)
   IF (dabt_in_reset_ind=1)
    SET dnotify->body_cnt = 1
    SET stat = alterlist(dnotify->body,1)
    SET dnotify->body[dnotify->body_cnt].txt = dabt_in_text
   ELSE
    SET dnotify->body_cnt = (dnotify->body_cnt+ 1)
    SET stat = alterlist(dnotify->body,dnotify->body_cnt)
    SET dnotify->body[dnotify->body_cnt].txt = dabt_in_text
   ENDIF
 END ;Subroutine
 SUBROUTINE dn_reset_pre_err(drpe_emsg,drpe_eproc,drpe_user_action)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = drpe_emsg
   SET dm_err->eproc = drpe_eproc
   SET dm_err->user_action = drpe_user_action
 END ;Subroutine
 DECLARE dn_test_file_name = vc WITH protect, noconstant("DM2NOTSET")
 IF ((dm2_sys_misc->cur_os="AXP"))
  SET dn_test_file_name = build(logical("CCLUSERDIR"),"dm2_install_plan_notify_test.txt")
 ELSE
  SET dn_test_file_name = build(logical("CCLUSERDIR"),"/dm2_install_plan_notify_test.txt")
 ENDIF
 IF ((validate(dnotify->status,- (99))=- (99))
  AND validate(dnotify->status,722)=722)
  FREE RECORD dnotify
  RECORD dnotify(
    1 status = i2
    1 install_method = vc
    1 file_name = vc
    1 email_address_list = vc
    1 email_subject = vc
    1 process = vc
    1 plan_id = f8
    1 client = vc
    1 mode = vc
    1 install_status = vc
    1 env_name = vc
    1 event = vc
    1 msgtype = vc
    1 test_single_ind = i2
    1 test_email_failed = i2
    1 suppression_flag = i4
    1 body_cnt = i4
    1 body[*]
      2 txt = vc
    1 email_cnt = i4
    1 email[*]
      2 address = vc
      2 new_ind = i2
  )
  SET dnotify->status = 0
  SET dnotify->install_method = "ATTENDED"
  SET dnotify->file_name = "DM2NOTSET"
  SET dnotify->email_subject = "DM2NOTSET"
  SET dnotify->email_address_list = "DM2NOTSET"
  SET dnotify->process = "DM2NOTSET"
  SET dnotify->plan_id = - (1)
  SET dnotify->client = "DM2NOTSET"
  SET dnotify->mode = "DM2NOTSET"
  SET dnotify->install_status = "DM2NOTSET"
  SET dnotify->env_name = "DM2NOTSET"
  SET dnotify->event = "DM2NOTSET"
  SET dnotify->msgtype = "DM2NOTSET"
  SET dnotify->test_single_ind = 0
  SET dnotify->test_email_failed = 0
  SET dnotify->body_cnt = 0
  SET dnotify->email_cnt = 0
  SET dnotify->suppression_flag = 0
 ENDIF
 DECLARE dn_get_notify_settings(null) = i2
 DECLARE dn_save_notify_settings(null) = i2
 DECLARE dn_confirm_install_notification(dcin_ret_action=c1(ref)) = i2
 DECLARE dn_notify(null) = i2
 DECLARE dn_add_body_text(dabt_in_text=vc,dabt_in_reset_ind=i2) = null
 DECLARE dn_reset_pre_err(drpe_emsg=vc,drpe_eproc=vc,drpe_user_action=vc) = null
 DECLARE dipm_logfile_prefix = vc WITH protect, constant("dm2_inst_plan_menu")
 DECLARE dipm_continue_loop = i2 WITH protect, noconstant(1)
 DECLARE dipm_option = vc WITH protect, noconstant("R")
 DECLARE dipm_cur_itin_dpe_id = f8 WITH protect, noconstant(0.0)
 DECLARE dipm_cur_is_status = vc WITH protect, noconstant(" ")
 DECLARE dipm_is_paused = i2 WITH protect, noconstant(0)
 DECLARE dipm_last_status_time = vc WITH protect, noconstant(" ")
 DECLARE dipm_last_status_msg = vc WITH protect, noconstant(" ")
 DECLARE dipm_cnt = i2 WITH protect, noconstant(0)
 DECLARE dipm_cur_logfile = vc WITH protect, noconstant(" ")
 DECLARE dipm_cur_ref_logfile = vc WITH protect, noconstant(" ")
 DECLARE dipm_modify_install_status(dmist_install_plan=f8,dmist_install_mode=vc,dmist_dpe_id=f8,
  dmist_appl_ident=vc) = i2
 DECLARE dipm_tspace_rpt(dtr_install_plan=f8,dtr_dpe_id=f8) = i2
 SET width = 132
 IF (check_logfile(dipm_logfile_prefix,".log","dm2_install_plan_menu")=0)
  CALL dipr_disp_error_msg(null)
  GO TO exit_program
 ENDIF
 SET dm2_process_rs->process_name = value(dpl_package_install)
 IF (dpl_ui_chk(dm2_process_rs->process_name)=0)
  GO TO exit_program
 ENDIF
 IF ((dm2_process_event_rs->ui_allowed_ind=0))
  SET dm_err->emsg = "Install Plan Menu cannot be viewd because required schema does not exist"
  SET dm_err->err_ind = 1
  CALL dipr_disp_error_msg(null)
  GO TO exit_program
 ENDIF
 IF ((dipm_misc_data->install_plan_id=0))
  IF (dipr_get_plan_nbr(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 WHILE (dipm_continue_loop=1)
   IF (drr_cleanup_dm_info_runners(null)=0)
    CALL dipr_disp_error_msg(null)
    GO TO exit_program
   ENDIF
   SET dipm_misc_data->cur_dpe_id = 0
   IF (dipr_get_cur_dpe_data(dipm_misc_data->install_plan_id)=0)
    GO TO exit_program
   ENDIF
   IF (drr_get_flexible_schedule(null)=0)
    GO TO exit_program
   ENDIF
   SET dipm_cur_is_status = evaluate(drr_flex_sched->status,1,"ON","OFF")
   SET dm_err->eproc = "Retrieving current process details for package install execution"
   IF ((dm_err->debug_flag > 0))
    CALL dipr_disp_error_msg(null)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event dpe,
     dm_process_event_dtl dped
    PLAN (dpe
     WHERE (dpe.dm_process_event_id=dipm_misc_data->cur_dpe_id))
     JOIN (dped
     WHERE dpe.dm_process_event_id=dped.dm_process_event_id)
    DETAIL
     IF (dped.detail_type="AUDSID")
      dipm_misc_data->cur_appl_id = cnvtreal(trim(dped.detail_text,3))
     ENDIF
     IF (dped.detail_type=value(dpl_unattended))
      IF (dped.detail_number=1)
       dipm_misc_data->cur_method = "UNATTENDED"
      ELSE
       dipm_misc_data->cur_method = "ATTENDED"
      ENDIF
     ENDIF
     IF (dped.detail_type="LOGFILE:MAIN")
      dipm_cur_logfile = dped.detail_text
     ENDIF
     IF (dped.detail_type="LOGFILE:BACKGROUND*")
      dipm_cur_ref_logfile = dped.detail_text
     ENDIF
     dipm_misc_data->cur_dpe_status = dpe.event_status
     IF (dped.detail_type="LAST_STATUS_MESSAGE")
      dipm_last_status_msg = dped.detail_text, dipm_last_status_time = format(dped.detail_dt_tm,
       "DD-MMM-YYYY HH:MM:SS;;D")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = "Unable to retrieve current package install execution"
    SET dm_err->err_ind = 1
    CALL dipr_disp_error_msg(null)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Retrieving most recent itinerary event for current package install execution"
   IF ((dm_err->debug_flag > 0))
    CALL dipr_disp_error_msg(null)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event dpe2,
     dm_process dp2,
     dm_process_event_dtl dped2
    PLAN (dpe2
     WHERE (dpe2.install_plan_id=dipm_misc_data->install_plan_id))
     JOIN (dp2
     WHERE dpe2.dm_process_id=dp2.dm_process_id
      AND dp2.process_name=value(dpl_package_install)
      AND dp2.action_type=value(dpl_itinerary_event))
     JOIN (dped2
     WHERE dpe2.dm_process_event_id=dped2.dm_process_event_id
      AND dped2.detail_type="STEP_NAME")
    ORDER BY dpe2.begin_dt_tm DESC, dpe2.dm_process_event_id DESC
    DETAIL
     dipm_misc_data->cur_itin_dpe_id = dpe2.dm_process_event_id, dipm_misc_data->cur_install_event =
     dped2.detail_text
    WITH nocounter, maxrec = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = concat("Unable to retrieve itinerary data for Install Plan ",drr_flex_sched->
     pkg_number)
    SET dm_err->err_ind = 1
    CALL dipr_disp_error_msg(null)
    GO TO exit_program
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dipm_misc_data)
   ENDIF
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL text(2,2,"INSTALL PLAN MENU [MAIN]")
   CALL text(2,70,"DATE/TIME: ")
   CALL text(2,80,format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D"))
   CALL text(4,2,"Plan Number: ")
   CALL text(4,18,drr_flex_sched->pkg_number)
   CALL text(5,2,"Plan Method: ")
   CALL text(5,18,dipm_misc_data->cur_method)
   CALL text(5,40,"Installation Scheduler: ")
   CALL text(5,65,dipm_cur_is_status)
   CALL text(7,2,"Current Mode: ")
   CALL text(7,30,dipm_misc_data->cur_mode)
   CALL text(8,2,"Current Install Event: ")
   IF ((dipm_misc_data->cur_mode="BATCHPREVIEW"))
    CALL text(8,30,"N/A")
   ELSE
    CALL text(8,30,dipm_misc_data->cur_install_event)
   ENDIF
   CALL text(9,2,"Current Install Status: ")
   CALL text(9,30,dipm_misc_data->cur_dpe_status)
   CALL text(10,2,"Last Status Time: ")
   CALL text(10,30,dipm_last_status_time)
   CALL text(11,2,"Last Status Message: ")
   CALL text(11,30,dipm_last_status_msg)
   IF ((dipm_misc_data->cur_dpe_status=value(dpl_failed)))
    CALL text(12,30,concat("Review logfile ",evaluate(dipm_misc_data->cur_method,"UNATTENDED",
       dipm_cur_ref_logfile,dipm_cur_logfile)," in CCLUSERDIR for more details."))
   ENDIF
   CALL text(14,2,"Note: This Menu will refresh every 10 seconds")
   CALL text(16,5,"1. Installation Reports")
   CALL text(17,5,"2. Installation Scheduler")
   CALL text(18,5,"3. Installation Notification")
   CALL text(16,50,"4. Installation Monitoring")
   CALL text(17,50,"5. Modify Install Status")
   CALL text(18,50,"6. Tablespace Needs Maintainence")
   CALL text(20,5,"Your selection (0 to go back or 'R' to (R)efresh: ")
   SET accept = time(10)
   CALL accept(20,56,"X;CU","R"
    WHERE curaccept IN ("0", "1", "2", "3", "4",
    "5", "6", "R"))
   SET accept = notime
   SET dipm_option = curaccept
   SET message = nowindow
   CASE (dipm_option)
    OF "0":
     SET dipm_continue_loop = 0
    OF "1":
     EXECUTE dm2_install_plan_menu_reports
     IF ((dm_err->err_ind > 0))
      GO TO exit_program
     ENDIF
     SET dipm_continue_loop = 1
    OF "2":
     EXECUTE dm2_flexible_schedule_menu
     IF ((dm_err->err_ind > 0))
      GO TO exit_program
     ENDIF
     SET dipm_continue_loop = 1
    OF "3":
     EXECUTE dm2_install_plan_menu_notify
     IF ((dm_err->err_ind > 0))
      GO TO exit_program
     ENDIF
     SET dipm_continue_loop = 1
    OF "4":
     EXECUTE dm2_install_plan_menu_mon
     IF ((dm_err->err_ind > 0))
      GO TO exit_program
     ENDIF
     SET dipm_continue_loop = 1
    OF "5":
     IF (dipm_modify_install_status(dipm_misc_data->install_plan_id,dipm_misc_data->cur_mode,
      dipm_misc_data->cur_dpe_id,trim(cnvtstring(dipm_misc_data->cur_appl_id)))=0)
      GO TO exit_program
     ENDIF
     SET dipm_continue_loop = 1
    OF "6":
     IF (dipm_tspace_rpt(dipm_misc_data->install_plan_id,dipm_misc_data->cur_dpe_id)=0)
      GO TO exit_program
     ENDIF
     SET dipm_continue_loop = 1
    ELSE
     SET dipm_continue_loop = 1
   ENDCASE
 ENDWHILE
 GO TO exit_program
 SUBROUTINE dipm_modify_install_status(dmist_install_plan,dmist_install_mode,dmist_dpe_id,
  dmist_appl_ident)
   DECLARE dmist_continue = i2 WITH protect, noconstant(1)
   DECLARE dmist_cur_status = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dmist_new_status = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dmist_chk_status = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dmist_status_val = i2 WITH protect, noconstant(0)
   DECLARE dmist_accept = vc WITH protect, noconstant("")
   DECLARE dmist_text = vc WITH protect, noconstant("")
   DECLARE dmist_cnt = i2 WITH protect, noconstant(0)
   DECLARE dmist_idx = i2 WITH protect, noconstant(0)
   FREE RECORD dmist_pauses
   RECORD dmist_pauses(
     1 cnt = i4
     1 qual[*]
       2 dtl_id = f8
       2 dtl_type = vc
   )
   FREE RECORD dmist_status
   RECORD dmist_status(
     1 cnt = i4
     1 qual[*]
       2 status = vc
       2 val = vc
   )
   SET dm_err->eproc = "Obtaining Current Install Status"
   IF (drr_get_process_status("DM2_INSTALL_PKG",dmist_install_plan,dmist_status_val)=0)
    RETURN(0)
   ENDIF
   IF (dmist_status_val=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,3,132)
    CALL text(2,2,"INSTALL PLAN MENU [MODIFY INSTALL STATUS]")
    CALL text(2,70,"DATE/TIME: ")
    CALL text(2,80,format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D"))
    CALL text(5,2,"The Install Status cannot be Modified. Press <Enter> to Continue. ")
    CALL accept(5,70,"p;cu"," "
     WHERE curaccept IN (" "))
    SET message = nowindow
    RETURN(1)
   ENDIF
   SET dmist_cur_status = evaluate(dmist_status_val,1,value(dpl_executing),2,value(dpl_paused))
   IF (((dmist_cur_status="DM2NOTSET") OR (dmist_cur_status < " ")) )
    SET dm_err->emsg = "Failed to obtain Current Install Status"
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dmist_new_status = dmist_cur_status
   WHILE (dmist_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"INSTALL PLAN MENU [MODIFY INSTALL STATUS]")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D"))
     CALL text(5,2,"Current Install Status: ")
     CALL text(5,30,dmist_cur_status)
     CALL text(7,2,"New Install Status:")
     CALL text(7,30,dmist_new_status)
     CALL text(9,2,"(M)odify, (S)ave, (B)ack: ")
     CALL accept(9,30,"p;cu","S"
      WHERE curaccept IN ("M", "S", "B"))
     SET dmist_accept = curaccept
     SET message = nowindow
     CASE (dmist_accept)
      OF "B":
       SET dmist_new_status = dmist_cur_status
       SET dmist_continue = 0
      OF "M":
       SET message = window
       SET dm_err->eproc = "Setting New Install Status"
       CALL clear(7,30,11)
       SET stat = alterlist(dmist_status->qual,2)
       IF (dmist_cur_status=value(dpl_executing))
        SET dmist_status->qual[1].status = "PAUSE"
        SET dmist_status->qual[2].status = "STOP"
        SET dmist_status->qual[1].val = value(dpl_paused)
        SET dmist_status->qual[2].val = value(dpl_stopped)
       ELSEIF (dmist_cur_status=value(dpl_paused))
        SET dmist_status->qual[1].status = "EXECUTE"
        SET dmist_status->qual[2].status = "STOP"
        SET dmist_status->qual[1].val = value(dpl_executing)
        SET dmist_status->qual[2].val = value(dpl_stopped)
       ENDIF
       SET help = pos(4,80,10,50)
       SET help =
       SELECT INTO "nl:"
        new_status = dmist_status->qual[d.seq].status
        FROM (dummyt d  WITH seq = size(dmist_status->qual,5))
        WITH nocounter
       ;end select
       CALL accept(7,30,"A(8);CF")
       IF (curhelp > 0)
        SET dmist_new_status = dmist_status->qual[curhelp].val
       ELSE
        SET dmist_cnt = 0
        SET dmist_idx = locateval(dmist_cnt,1,size(dmist_status->qual,5),curaccept,dmist_status->
         qual[dmist_cnt].status)
        IF (dmist_idx > 0)
         SET dmist_new_status = dmist_status->qual[dmist_idx].val
         SET help = off
        ELSE
         CALL text(9,2,"Invalid Status. Please Retry.Press <Enter> to Continue.")
         CALL accept(9,70,"p;cu"," "
          WHERE curaccept IN (" "))
        ENDIF
       ENDIF
       SET message = nowindow
       SET dmist_continue = 1
      OF "S":
       IF (cnvtupper(dmist_cur_status) != cnvtupper(dmist_new_status))
        SET dmist_status_val = evaluate(cnvtupper(dmist_new_status),value(dpl_stopped),0,value(
          dpl_executing),1,
         value(dpl_paused),2)
        SET dm_err->eproc = "Modifying Install Status"
        IF (drr_modify_install_status(dmist_install_plan,dmist_appl_ident,dmist_status_val,concat(
          "User (",curuser,") modified Install Status to ",dmist_new_status),
         "DM2_INSTALL_PLAN_MENU: MODIFY INSTALL STATUS")=0)
         RETURN(0)
        ENDIF
        SET dm_err->eproc = "Notifying users of change in Install Status"
        SET dnotify->process = "INSTALLPLAN"
        SET dnotify->plan_id = dmist_install_plan
        SET dnotify->install_status = dmist_new_status
        SET dnotify->event = "Modify Install Status"
        SET dnotify->mode = dmist_install_mode
        SET dnotify->msgtype = evaluate(dmist_status_val,1,value(dpl_progress),value(dpl_actionreq))
        SET dmist_text = concat("The Install Plan Status was modified from ",dmist_cur_status," to ",
         dmist_new_status," by ",
         curuser," at ",format(cnvtdatetime(curdate,curtime3),";;q"),".")
        IF (dn_add_body_text(dmist_text,1)=0)
         RETURN(0)
        ENDIF
        SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
        SET dm2_process_event_rs->status = dpl_complete
        SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
        SET dm2_process_event_rs->install_plan_id = dmist_install_plan
        CALL dm2_process_log_add_detail_text(dpl_audit_name,
         "EMAIL:DM2_INSTALL_PLAN_MENU:MODIFY_INSTALL_STATUS")
        IF (dn_notify(null)=0)
         RETURN(0)
        ENDIF
        IF (drr_get_process_status("DM2_INSTALL_PKG",dmist_install_plan,dmist_status_val)=0)
         RETURN(0)
        ENDIF
        SET dmist_chk_status = evaluate(dmist_status_val,1,value(dpl_executing),2,value(dpl_paused),
         0,value(dpl_stopped))
        IF (dmist_chk_status != dmist_new_status)
         SET dm_err->err_ind = 1
         SET dm_err->emsg = concat("Unable to modify install status from ",dmist_cur_status," to ",
          dmist_new_status)
         CALL dipr_disp_error_msg(null)
         RETURN(0)
        ENDIF
        IF (dmist_cur_status=value(dpl_paused)
         AND dmist_new_status != value(dpl_paused))
         SET dm_err->eproc = "Gathering list of ISSUED pause points"
         IF ((dm_err->debug_flag > 0))
          CALL dipr_disp_error_msg(null)
         ENDIF
         SELECT INTO "nl:"
          FROM dm_process_event dpe,
           dm_process_event_dtl dped
          PLAN (dpe
           WHERE dpe.dm_process_event_id=dmist_dpe_id)
           JOIN (dped
           WHERE dpe.dm_process_event_id=dped.dm_process_event_id
            AND dped.detail_type="SYSPAUSE:*")
          HEAD REPORT
           dmist_cnt = 0
          DETAIL
           dmist_cnt = (dmist_cnt+ 1)
           IF (mod(dmist_cnt,10)=1)
            stat = alterlist(dmist_pauses->qual,(dmist_cnt+ 9))
           ENDIF
           dmist_pauses->qual[dmist_cnt].dtl_id = dped.dm_process_event_dtl_id, dmist_pauses->qual[
           dmist_cnt].dtl_type = dped.detail_type
          FOOT REPORT
           dmist_pauses->cnt = dmist_cnt, stat = alterlist(dmist_pauses->qual,dmist_pauses->cnt)
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL dipr_disp_error_msg(null)
          RETURN(0)
         ENDIF
         IF ((dm_err->debug_flag > 0))
          CALL echorecord(dmist_pauses)
         ENDIF
         IF ((dmist_pauses->cnt > 0))
          SET dm_err->eproc = "Inserting CONFIRMED row for pause points"
          IF ((dm_err->debug_flag > 0))
           CALL dipr_disp_error_msg(null)
          ENDIF
          INSERT  FROM dm_process_event_dtl dped,
            (dummyt d  WITH seq = value(dmist_pauses->cnt))
           SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id
             = dmist_dpe_id, dped.detail_type = dmist_pauses->qual[d.seq].dtl_type,
            dped.detail_text = "CONFIRMED", dped.detail_dt_tm = cnvtdatetime(curdate,curtime3)
           PLAN (d
            WHERE d.seq > 0)
            JOIN (dped)
           WITH nocounter
          ;end insert
          IF (check_error(dm_err->eproc)=1)
           ROLLBACK
           CALL dipr_disp_error_msg(null)
           RETURN(0)
          ELSE
           COMMIT
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       SET dmist_continue = 0
     ENDCASE
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipm_tspace_rpt(dtr_install_plan,dtr_dpe_id)
   DECLARE dtr_continue = i2 WITH protect, noconstant(1)
   DECLARE dtr_no_rpts = i2 WITH protect, noconstant(0)
   DECLARE dtr_idx = i2 WITH protect, noconstant(0)
   DECLARE dtr_strt = i2 WITH protect, noconstant(0)
   DECLARE dtr_end = i2 WITH protect, noconstant(0)
   DECLARE dtr_accept = vc WITH protect, noconstant("")
   DECLARE dtr_text = vc WITH protect, noconstant("")
   DECLARE dtr_cnt = i2 WITH protect, noconstant(0)
   DECLARE dtr_tspace_to_manage_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dtr_reports
   RECORD dtr_reports(
     1 cnt = i4
     1 qual[*]
       2 dpe_id = f8
       2 rpt_file_name = vc
       2 rpt_file_date = dq8
   )
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    SET dm_err->eproc = "Check if tablespaces available to manage."
    SELECT INTO "nl:"
     FROM dm2_tspace_size d
     WHERE d.install_type="PACKAGE"
      AND d.install_type_value=cnvtstring((dtr_install_plan * - (1)))
      AND ((d.install_status != "SUCCESS") OR (d.install_status = null))
     HEAD REPORT
      dtr_tspace_to_manage_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL dipr_disp_error_msg(null)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Processing tablespace needs reports for current package install"
   IF ((dm2_sys_misc->cur_db_os="AXP")
    AND dtr_tspace_to_manage_ind=1)
    SET rtspace->install_type = "PACKAGE"
    SET rtspace->install_type_value = cnvtstring((dtr_install_plan * - (1)))
    SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->status = dpl_complete
    SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->install_plan_id = dtr_install_plan
    CALL dm2_process_log_add_detail_text(dpl_audit_name,"DM2_TSPACE_MENU_STARTED")
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     RETURN(0)
    ENDIF
    EXECUTE dm2_tspace_menu
    IF ((dm_err->err_ind > 0))
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    SET dm_err->eproc = "Obtaining list of tablespace needs reports from dm_process_event/DTL"
    SELECT INTO "nl:"
     FROM dm_process dp,
      dm_process_event dpe,
      dm_process_event_dtl dped
     PLAN (dp
      WHERE dp.process_name=value(dpl_package_install)
       AND dp.action_type=value(dpl_report))
      JOIN (dpe
      WHERE dp.dm_process_id=dpe.dm_process_id
       AND dpe.install_plan_id=cnvtreal(drr_flex_sched->pkg_number))
      JOIN (dped
      WHERE dpe.dm_process_event_id=dped.dm_process_event_id
       AND dped.detail_type="REPORT_NAME"
       AND dped.detail_text="TSPACE_NEEDS:*"
       AND dped.detail_number=dtr_dpe_id)
     HEAD REPORT
      dtr_cnt = 0
     DETAIL
      dtr_cnt = (dtr_cnt+ 1)
      IF (mod(dtr_cnt,10)=1)
       stat = alterlist(dtr_reports->qual,(dtr_cnt+ 9))
      ENDIF
      dtr_reports->qual[dtr_cnt].dpe_id = dpe.dm_process_event_id, dtr_reports->qual[dtr_cnt].
      rpt_file_name = trim(dped.detail_text), dtr_reports->qual[dtr_cnt].rpt_file_date = cnvtdatetime
      (dped.detail_dt_tm)
     FOOT REPORT
      dtr_reports->cnt = dtr_cnt, stat = alterlist(dtr_reports->qual,dtr_reports->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL dipr_disp_error_msg(null)
     RETURN(0)
    ENDIF
    WHILE (dtr_continue=1)
      SET message = window
      CALL clear(1,1)
      CALL box(1,1,3,132)
      CALL text(2,2,"INSTALL PLAN MENU [TABLESPACE NEEDS REPORTS]")
      CALL text(2,70,"DATE/TIME: ")
      CALL text(2,80,format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D"))
      IF ((dtr_reports->cnt=0))
       CALL text(5,2,"No Tablespace Needs reports exist. Press <enter> to go back.")
       CALL accept(5,62,"p;cu"," "
        WHERE curaccept IN (" "))
       SET dtr_continue = 0
      ELSE
       CALL text(5,2,"The Following Tablespace Needs reports are Available: ")
       SET dtr_strt = 6
       SET dtr_end = ((dtr_strt+ dtr_reports->cnt)+ 2)
       FOR (dtr_idx = 1 TO dtr_reports->cnt)
         CALL text((dtr_strt+ dtr_idx),2,concat(build(dtr_idx),". ",dtr_reports->qual[dtr_idx].
           rpt_file_name))
       ENDFOR
       CALL text(dtr_end,2,"Your selection or 0 to go back: ")
       CALL accept(dtr_end,34,"9"
        WHERE curaccept >= 0
         AND (curaccept <= dtr_reports->cnt))
       CASE (curaccept)
        OF 0:
         SET dtr_continue = 0
        ELSE
         SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
         SET dm2_process_event_rs->status = dpl_complete
         SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
         SET dm2_process_event_rs->install_plan_id = dtr_install_plan
         CALL dm2_process_log_add_detail_text(dpl_audit_name,concat("VIEWRPT:",dtr_reports->qual[
           curaccept].rpt_file_name))
         CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
         IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
          RETURN(0)
         ENDIF
         SET dm_err->eproc = "Displaying selected tablespace needs report"
         SET message = nowindow
         SELECT INTO "MINE"
          detail_text
          FROM dm_process_event_dtl dped
          WHERE (dped.dm_process_event_id=dtr_reports->qual[curaccept].dpe_id)
           AND dped.detail_type="BODY"
          ORDER BY dped.detail_number
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL dipr_disp_error_msg(null)
          RETURN(0)
         ENDIF
         SET message = window
       ENDCASE
      ENDIF
    ENDWHILE
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 SET message = nowindow
 SET dm_err->eproc = "LEAVING dm2_install_plan_menu"
 CALL final_disp_msg(dipm_logfile_prefix)
END GO
