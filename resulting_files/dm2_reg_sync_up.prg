CREATE PROGRAM dm2_reg_sync_up
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
 DECLARE ops_get_version(_dblink=vc,_opsversion=f8(ref),_migrationinprogress=i2(ref),_errormessage=vc
  (ref)) = i2
 SUBROUTINE ops_get_version(_dblink,_opsversion,_migrationinprogress,_errormessage)
   IF (checkprg("OPS_GET_VERSION_INFO:DBA")=0)
    SET _opsversion = 1.0
    SET _migrationinprogress = 0
    SET _errormessage = ""
    RETURN(1)
   ENDIF
   FREE RECORD _versioninforequest
   RECORD _versioninforequest(
     1 db_link = vc
   )
   SET _versioninforequest->db_link = _dblink
   FREE RECORD _opsversioninfo
   RECORD _opsversioninfo(
     1 version = f8
     1 migration_in_progress = i2
     1 error = vc
   )
   EXECUTE ops_get_version_info  WITH replace("REPLY",_opsversioninfo), replace("REQUEST",
    _versioninforequest)
   DECLARE _errormsg = vc WITH protect, noconstant("")
   IF (error(_errormsg,0) != 0)
    SET _errormessage = concat("Failed to execute ops_get_version_info: ",_errormsg)
    RETURN(0)
   ENDIF
   IF ((_opsversioninfo->version=0))
    IF (trim(_opsversioninfo->error) != "")
     SET _errormessage = _opsversioninfo->error
    ELSE
     SET _errormessage = "Unknown error while executing ops_get_version_info."
    ENDIF
    RETURN(0)
   ENDIF
   SET _opsversion = _opsversioninfo->version
   SET _migrationinprogress = _opsversioninfo->migration_in_progress
   SET _errormessage = ""
   RETURN(1)
 END ;Subroutine
 IF ((validate(ddr_domain_data->tgt_exists,- (1))=- (1))
  AND validate(ddr_domain_data->tgt_exists,1)=1)
  FREE RECORD ddr_domain_data
  RECORD ddr_domain_data(
    1 process = vc
    1 get_ccluserdir = i2
    1 get_warehouse = i2
    1 get_invalid_tables = i2
    1 data_file_name = vc
    1 imp_parfile_prefix = vc
    1 exp_parfile_prefix = vc
    1 process = vc
    1 tgt_tmp_src_dir_exists = i2
    1 tgt_cer_config_dir = vc
    1 tgt_ccldir = vc
    1 tgt_ocdtools_dir = vc
    1 tgt_ccluserdir_dir = vc
    1 tgt_warehouse_dir = vc
    1 tgt_cer_install_dir = vc
    1 tgt_auth_server_id = i4
    1 tgt_auth_server_desc = vc
    1 tgt_scp_server_id = i4
    1 tgt_scp_server_desc = vc
    1 tgt_sec_server_master_id = i4
    1 tgt_sec_server_slave_id = i4
    1 tgt_sec_server_master_desc = vc
    1 tgt_sec_server_slave_desc = vc
    1 tgt_sec_server_master_lrl = vc
    1 tgt_sec_server_slave_lrl = vc
    1 tgt_tdb_server_master_id = i4
    1 tgt_tdb_server_slave_id = i4
    1 tgt_tdb_server_master_desc = vc
    1 tgt_tdb_server_slave_desc = vc
    1 tgt_tdb_count = i4
    1 tgt_server_count = i4
    1 tgt_restart_ind = i2
    1 tgt_exists = i2
    1 tgt_domain_name = vc
    1 tgt_env = vc
    1 tgt_node = vc
    1 tgt_tmp_dev = vc
    1 tgt_tmp_dir = vc
    1 tgt_tmp_dir_exists = i2
    1 tgt_tmp_full_dir = vc
    1 tgt_priv = vc
    1 tgt_priv_pwd = vc
    1 tgt_revision_level = vc
    1 tgt_user = vc
    1 tgt_pwd = vc
    1 tgt_ora_home = vc
    1 tgt_cer_data_dev = vc
    1 tgt_wh = vc
    1 tgt_wh_device = vc
    1 tgt_mng = vc
    1 tgt_mng_pwd = vc
    1 tgt_system = vc
    1 tgt_system_pwd = vc
    1 tgt_v500_pwd = vc
    1 tgt_uic = vc
    1 tgt_login_dir = vc
    1 tgt_preserve_fnd = i2
    1 tgt_preserve_ts = f8
    1 tgt_forms_fnd = i2
    1 tgt_forms_ts = f8
    1 tgt_dbas_fnd = i2
    1 tgt_dbas_ts = f8
    1 tgt_users_fnd = i2
    1 tgt_users_ts = f8
    1 tgt_sys_reg_fnd = i2
    1 tgt_sys_reg_ts = f8
    1 tgt_wh_fnd = i2
    1 tgt_wh_ts = f8
    1 tgt_ccluserdir_fnd = i2
    1 tgt_ccluserdir_ts = f8
    1 tgt_nodes_cnt = i2
    1 tgt_data_fnd = i2
    1 tgt_data_ts = f8
    1 tgt_ind_data_fnd = i2
    1 tgt_dict_fnd = i2
    1 tgt_dict_ts = f8
    1 tgt_tdb_fnd = i2
    1 tgt_tdb_ts = f8
    1 tgt_srv_def_fnd = i2
    1 tgt_srv_def_ts = f8
    1 tgt_local_user_name = vc
    1 tgt_local_group_name = vc
    1 tgt_sec_user_name = vc
    1 tgt_sec_user_fnd = i2
    1 tgt_sec_user_ts = f8
    1 tgt_env_reg_fnd = i2
    1 tgt_env_reg_ts = f8
    1 tgt_sysdef_reg_fnd = i2
    1 tgt_sysdef_reg_ts = f8
    1 tgt_invalid_tbls_fnd = i2
    1 tgt_invalid_tbls_ts = f8
    1 tgt_node_flag = i2
    1 tgt_was_arch_ind = i2
    1 tgt_preserve_pwds_cnt = i2
    1 tgt_ccl_grants_ind = i2
    1 tgt_nodes[*]
      2 node_name = vc
    1 src_ccldir = vc
    1 src_cer_config_dir = vc
    1 src_ocdtools_dir = vc
    1 src_ccluserdir_dir = vc
    1 src_warehouse_dir = vc
    1 src_cer_install_dir = vc
    1 src_auth_server_id = i4
    1 src_auth_server_desc = vc
    1 src_scp_server_id = i4
    1 src_scp_server_desc = vc
    1 src_sec_server_master_id = i4
    1 src_sec_server_slave_id = i4
    1 src_sec_server_master_desc = vc
    1 src_sec_server_slave_desc = vc
    1 src_sec_server_master_lrl = vc
    1 src_sec_server_slave_lrl = vc
    1 src_tdb_server_master_id = i4
    1 src_tdb_server_slave_id = i4
    1 src_tdb_server_master_desc = vc
    1 src_tdb_server_slave_desc = vc
    1 src_tdb_count = i4
    1 src_server_count = i4
    1 src_restart_ind = i2
    1 src_data_fnd = i2
    1 src_domain_name = vc
    1 src_db_env_name = vc
    1 src_data_ts = f8
    1 src_ind_data_fnd = i2
    1 src_dict_fnd = i2
    1 src_dict_ts = f8
    1 src_tdb_fnd = i2
    1 src_tdb_ts = f8
    1 src_srv_def_fnd = i2
    1 src_srv_def_ts = f8
    1 src_local_user_name = vc
    1 src_local_group_name = vc
    1 src_sec_user_name = vc
    1 src_sec_user_fnd = i2
    1 src_sec_user_ts = f8
    1 src_env_reg_fnd = i2
    1 src_env_reg_ts = f8
    1 src_sysdef_reg_fnd = i2
    1 src_sysdef_reg_ts = f8
    1 src_invalid_tbls_fnd = i2
    1 src_invalid_tbls_ts = f8
    1 src_wh_fnd = i2
    1 src_wh_ts = f8
    1 src_ocd_tools_fnd = i2
    1 src_ocd_tools_ts = f8
    1 src_ccldir_fnd = i2
    1 src_ccldir_ts = f8
    1 src_config_fnd = i2
    1 src_config_ts = f8
    1 src_tmp_full_dir = vc
    1 src_tmp_dir = vc
    1 src_tmp_dev = vc
    1 src_tmp_dir_exists = i2
    1 src_env = vc
    1 src_cer_data_dev = vc
    1 src_wh = vc
    1 src_wh_device = vc
    1 src_revision_level = vc
    1 src_system = vc
    1 src_system_pwd = vc
    1 src_mng = vc
    1 src_mng_pwd = vc
    1 src_priv = vc
    1 src_priv_pwd = vc
    1 src_match_tgt_node = vc
    1 src_adm_env_csv_fnd = i2
    1 src_adm_env_csv_ts = f8
    1 src_was_arch_ind = i2
    1 offline_dict_ind = i2
    1 src_nodes_cnt = i2
    1 src_ccl_grants_ind = i2
    1 src_nodes[*]
      2 node_name = vc
    1 standalone_expimp_mode = i2
    1 preserve_ind = i2
    1 preserve_user_ind = i2
    1 src_tdb_curpages = vc
    1 src_tdb_maxpages = vc
    1 src_tdb_init_size = vc
    1 src_ldap_ind = i2
    1 tgt_ldap_ind = i2
    1 src_interrogator_ind = i2
    1 src_interrogator_node = vc
    1 src_interrogator_fnd = i2
    1 src_interrogator_ts = f8
    1 src_ops_ver = f8
  )
  SET ddr_domain_data->process = "DM2NOTSET"
  SET ddr_domain_data->src_env = "DM2NOTSET"
  SET ddr_domain_data->src_tmp_dir = "DM2NOTSET"
  SET ddr_domain_data->src_tmp_full_dir = "DM2NOTSET"
  SET ddr_domain_data->src_tmp_dev = "DM2NOTSET"
  SET ddr_domain_data->src_cer_data_dev = "DM2NOTSET"
  SET ddr_domain_data->src_wh = "DM2NOTSET"
  SET ddr_domain_data->src_wh_device = "DM2NOTSET"
  SET ddr_domain_data->src_revision_level = "DM2NOTSET"
  SET ddr_domain_data->src_system = "DM2NOTSET"
  SET ddr_domain_data->src_system_pwd = "DM2NOTSET"
  SET ddr_domain_data->src_priv = "DM2NOTSET"
  SET ddr_domain_data->src_priv_pwd = "DM2NOTSET"
  SET ddr_domain_data->src_mng = "DM2NOTSET"
  SET ddr_domain_data->src_mng_pwd = "DM2NOTSET"
  SET ddr_domain_data->src_local_user_name = "DM2NOTSET"
  SET ddr_domain_data->src_local_group_name = "DM2NOTSET"
  SET ddr_domain_data->src_sec_user_name = "DM2NOTSET"
  SET ddr_domain_data->src_nodes_cnt = 0
  SET ddr_domain_data->src_ccldir = "DM2NOTSET"
  SET ddr_domain_data->src_ocdtools_dir = "DM2NOTSET"
  SET ddr_domain_data->src_ccluserdir_dir = "DM2NOTSET"
  SET ddr_domain_data->src_warehouse_dir = "DM2NOTSET"
  SET ddr_domain_data->src_cer_config_dir = "DM2NOTSET"
  SET ddr_domain_data->src_sec_server_master_lrl = "DM2NOTSET"
  SET ddr_domain_data->src_sec_server_slave_lrl = "DM2NOTSET"
  SET stat = alterlist(ddr_domain_data->src_nodes,0)
  SET ddr_domain_data->tgt_ccldir = "DM2NOTSET"
  SET ddr_domain_data->tgt_ocdtools_dir = "DM2NOTSET"
  SET ddr_domain_data->tgt_ccluserdir_dir = "DM2NOTSET"
  SET ddr_domain_data->tgt_warehouse_dir = "DM2NOTSET"
  SET ddr_domain_data->tgt_cer_config_dir = "DM2NOTSET"
  SET ddr_domain_data->tgt_env = "DM2NOTSET"
  SET ddr_domain_data->tgt_tmp_dir = "DM2NOTSET"
  SET ddr_domain_data->tgt_tmp_full_dir = "DM2NOTSET"
  SET ddr_domain_data->tgt_tmp_dev = "DM2NOTSET"
  SET ddr_domain_data->tgt_cer_data_dev = "DM2NOTSET"
  SET ddr_domain_data->tgt_wh = "DM2NOTSET"
  SET ddr_domain_data->tgt_wh_device = "DM2NOTSET"
  SET ddr_domain_data->tgt_revision_level = "DM2NOTSET"
  SET ddr_domain_data->tgt_system = "DM2NOTSET"
  SET ddr_domain_data->tgt_system_pwd = "DM2NOTSET"
  SET ddr_domain_data->tgt_priv = "DM2NOTSET"
  SET ddr_domain_data->tgt_priv_pwd = "DM2NOTSET"
  SET ddr_domain_data->tgt_mng = "DM2NOTSET"
  SET ddr_domain_data->tgt_mng_pwd = "DM2NOTSET"
  SET ddr_domain_data->tgt_local_user_name = "DM2NOTSET"
  SET ddr_domain_data->tgt_local_group_name = "DM2NOTSET"
  SET ddr_domain_data->tgt_sec_user_name = "DM2NOTSET"
  SET ddr_domain_data->tgt_sec_server_master_lrl = "DM2NOTSET"
  SET ddr_domain_data->tgt_sec_server_slave_lrl = "DM2NOTSET"
  SET ddr_domain_data->tgt_nodes_cnt = 0
  SET ddr_domain_data->tgt_node_flag = 0
  SET ddr_domain_data->tgt_domain_name = "DM2NOTSET"
  SET ddr_domain_data->tgt_auth_server_desc = "DM2NOTSET"
  SET ddr_domain_data->tgt_scp_server_desc = "DM2NOTSET"
  SET ddr_domain_data->tgt_sec_server_master_desc = "DM2NOTSET"
  SET ddr_domain_data->tgt_sec_server_slave_desc = "DM2NOTSET"
  SET ddr_domain_data->tgt_tdb_server_master_desc = "DM2NOTSET"
  SET ddr_domain_data->tgt_tdb_server_slave_desc = "DM2NOTSET"
  SET ddr_domain_data->src_auth_server_desc = "DM2NOTSET"
  SET ddr_domain_data->src_scp_server_desc = "DM2NOTSET"
  SET ddr_domain_data->src_sec_server_master_desc = "DM2NOTSET"
  SET ddr_domain_data->src_sec_server_slave_desc = "DM2NOTSET"
  SET ddr_domain_data->src_tdb_server_master_desc = "DM2NOTSET"
  SET ddr_domain_data->src_tdb_server_slave_desc = "DM2NOTSET"
  SET ddr_domain_data->src_db_env_name = "DM2NOTSET"
  SET stat = alterlist(ddr_domain_data->tgt_nodes,0)
  SET ddr_domain_data->offline_dict_ind = - (1)
  SET ddr_domain_data->imp_parfile_prefix = "inv_imp_"
  SET ddr_domain_data->exp_parfile_prefix = "inv_exp_"
  SET ddr_domain_data->data_file_name = "misc_data.dat"
  SET ddr_domain_data->standalone_expimp_mode = 0
  SET ddr_domain_data->preserve_ind = 0
  SET ddr_domain_data->src_was_arch_ind = 0
  SET ddr_domain_data->tgt_was_arch_ind = 0
  SET ddr_domain_data->tgt_preserve_pwds_cnt = 0
  SET ddr_domain_data->preserve_user_ind = 0
  SET ddr_domain_data->src_tdb_curpages = "DM2NOTSET"
  SET ddr_domain_data->src_tdb_maxpages = "DM2NOTSET"
  SET ddr_domain_data->src_tdb_init_size = "DM2NOTSET"
  SET ddr_domain_data->src_ldap_ind = 0
  SET ddr_domain_data->tgt_ldap_ind = 0
  SET ddr_domain_data->src_interrogator_ind = 0
  SET ddr_domain_data->src_interrogator_node = "DM2NOTSET"
  SET ddr_domain_data->src_ops_ver = 0
 ENDIF
 IF (validate(ddr_reg->src_reg_file,"x")="x"
  AND validate(ddr_reg->src_reg_file,"y")="y")
  FREE RECORD ddr_reg
  RECORD ddr_reg(
    1 src_reg_file = vc
    1 skcnt = i4
    1 skey[*]
      2 skeyname = vc
      2 spcnt = i4
      2 sprop[*]
        3 spropname_orig = vc
        3 spropname = vc
        3 spropval = vc
    1 tgt_reg_file = vc
    1 tkcnt = i4
    1 tkey[*]
      2 tkeyname = vc
      2 tpcnt = i4
      2 tprop[*]
        3 tpropname_orig = vc
        3 tpropname = vc
        3 tpropval = vc
    1 cur_reg_file = vc
    1 cstr_fnd = i2
    1 ckcnt = i4
    1 ckey[*]
      2 ckeyname = vc
      2 cstr_fnd = i2
      2 cpcnt = i4
      2 cprop[*]
        3 cpropname_orig = vc
        3 cpropname = vc
        3 cpropval = vc
        3 cstr_fnd = i2
  )
 ENDIF
 IF ((validate(ddr_tbl_list->owner_cnt,- (1))=- (1))
  AND validate(ddr_tbl_list->owner_cnt,1)=1)
  FREE RECORD ddr_tbl_list
  RECORD ddr_tbl_list(
    1 owner_cnt = i4
    1 logs[*]
      2 log_name = vc
    1 owner[*]
      2 owner_name = vc
      2 par_file_cnt = i2
      2 tbl_cnt = i4
      2 tbl[*]
        3 tbl_name = vc
        3 par_group = i2
  )
  SET ddr_tbl_list->owner_cnt = 0
 ENDIF
 IF (validate(ddr_scp_data->location,"x")="x"
  AND validate(ddr_scp_data->location,"y")="y")
  FREE RECORD ddr_scp_data
  RECORD ddr_scp_data(
    1 location = vc
    1 tmp_file = vc
    1 new_file = vc
  )
  SET ddr_scp_data->location = "DM2NOTSET"
  SET ddr_scp_data->tmp_file = "DM2NOTSET"
  SET ddr_scp_data->new_file = "DM2NOTSET"
 ENDIF
 IF (validate(ddr_space_needs->src_gen_loc,"x")="x"
  AND validate(ddr_space_needs->src_gen_loc,"y")="y")
  FREE RECORD ddr_space_needs
  RECORD ddr_space_needs(
    1 src_gen_loc = vc
    1 sec_cer_install_loc = vc
    1 src_dicdat_size = vc
    1 src_dicidx_size = vc
    1 src_wh_size = vc
    1 src_ocd_tools_size = vc
    1 src_ccldir_size = vc
    1 src_cer_config_size = vc
    1 src_cer_forms_size = vc
    1 src_tdb_exp_size = vc
    1 src_srv_def_size = vc
    1 src_sec_user_exp_size = vc
    1 src_env_reg_size = vc
    1 src_sys_reg_size = vc
    1 src_link_data_size = vc
    1 src_misc_data_size = vc
    1 src_ccluserdir_size = vc
    1 tgt_gen_loc = vc
    1 tgt_cer_install_loc = vc
    1 tgt_expimp_loc = vc
    1 tgt_misc_data_size = vc
    1 tgt_srv_bkup_size = vc
    1 tgt_ccluserdir_size = vc
    1 tgt_wh_size = vc
    1 tgt_tdb_exp_size = vc
    1 tgt_srv_def_size = vc
    1 tgt_sec_user_exp_size = vc
    1 tgt_env_reg_size = vc
    1 tgt_sys_reg_size = vc
    1 tgt_sys_reg_cpy_size = vc
    1 tgt_cer_forms_size = vc
    1 tgt_preserve_tbl_size = vc
    1 tgt_preserve_tbl_loc = vc
    1 tgt_dicdat_size = vc
    1 tgt_dicidx_size = vc
    1 tgt_link_data_size = vc
    1 tgt_ocd_tools_size = vc
    1 tgt_ccldir_size = vc
    1 tgt_cer_config_size = vc
    1 tgt_preserve_tbl_size = vc
    1 tot_src_temp_dir_size = vc
    1 tot_tgt_temp_dir_size = vc
    1 opt_tgt_temp_dir_size = vc
    1 tot_src_cer_install_size = vc
    1 tot_tgt_cer_install_size = vc
    1 opt_tgt_cer_install_size = vc
    1 tot_expimp_dir_size = vc
    1 src_interrogator_size = vc
  )
  SET ddr_space_needs->tgt_srv_def_size = "0.0"
  SET ddr_space_needs->tgt_env_reg_size = "0.0"
  SET ddr_space_needs->tgt_sys_reg_size = "0.0"
  SET ddr_space_needs->tgt_sys_reg_cpy_size = "0.0"
  SET ddr_space_needs->tgt_link_data_size = "0.0"
  SET ddr_space_needs->tgt_misc_data_size = "0.0"
  SET ddr_space_needs->tgt_srv_bkup_size = "0.0"
  SET ddr_space_needs->tgt_wh_size = "0.0"
  SET ddr_space_needs->tgt_ocd_tools_size = "0.0"
  SET ddr_space_needs->tgt_ccldir_size = "0.0"
  SET ddr_space_needs->tgt_ccluserdir_size = "0.0"
  SET ddr_space_needs->tgt_cer_config_size = "0.0"
  SET ddr_space_needs->tgt_cer_forms_size = "0.0"
  SET ddr_space_needs->tgt_tdb_exp_size = "0.0"
  SET ddr_space_needs->tgt_sec_user_exp_size = "0.0"
  SET ddr_space_needs->tgt_dicdat_size = "0.0"
  SET ddr_space_needs->tgt_dicidx_size = "0.0"
  SET ddr_space_needs->tgt_preserve_tbl_size = "0.0"
  SET ddr_space_needs->src_srv_def_size = "0.0"
  SET ddr_space_needs->src_env_reg_size = "0.0"
  SET ddr_space_needs->src_sys_reg_size = "0.0"
  SET ddr_space_needs->src_link_data_size = "0.0"
  SET ddr_space_needs->src_misc_data_size = "0.0"
  SET ddr_space_needs->src_wh_size = "0.0"
  SET ddr_space_needs->src_ocd_tools_size = "0.0"
  SET ddr_space_needs->src_ccldir_size = "0.0"
  SET ddr_space_needs->src_cer_config_size = "0.0"
  SET ddr_space_needs->src_cer_forms_size = "0.0"
  SET ddr_space_needs->src_tdb_exp_size = "0.0"
  SET ddr_space_needs->src_srv_def_size = "0.0"
  SET ddr_space_needs->src_sec_user_exp_size = "0.0"
  SET ddr_space_needs->src_env_reg_size = "0.0"
  SET ddr_space_needs->src_sys_reg_size = "0.0"
  SET ddr_space_needs->src_link_data_size = "0.0"
  SET ddr_space_needs->src_misc_data_size = "0.0"
  SET ddr_space_needs->tot_tgt_temp_dir_size = "0.0"
  SET ddr_space_needs->tot_tgt_cer_install_size = "0.0"
  SET ddr_space_needs->opt_tgt_temp_dir_size = "0.0"
  SET ddr_space_needs->opt_tgt_cer_install_size = "0.0"
  SET ddr_space_needs->tot_src_temp_dir_size = "0.0"
  SET ddr_space_needs->tot_src_cer_install_size = "0.0"
  SET ddr_space_needs->tot_expimp_dir_size = "0.0"
  SET ddr_space_needs->src_interrogator_size = "0.0"
 ENDIF
 IF ((validate(ddr_opsexec_servers->cnt,- (1))=- (1))
  AND validate(ddr_opsexec_servers->cnt,1)=1)
  FREE RECORD ddr_opsexec_servers
  RECORD ddr_opsexec_servers(
    1 cnt = i4
    1 servers[*]
      2 server_nbr = i4
      2 server_name = vc
      2 protect = vc
  )
  SET ddr_opsexec_servers->cnt = 0
 ENDIF
 IF ((validate(ddr_opsexec_cgs->cnt,- (1))=- (1))
  AND validate(ddr_opsexec_cgs->cnt,1)=1)
  FREE RECORD ddr_opsexec_cgs
  RECORD ddr_opsexec_cgs(
    1 cnt = i4
    1 cgs[*]
      2 server_nbr = i4
      2 cg_name = vc
      2 ocg_id = f8
  )
  SET ddr_opsexec_cgs->cnt = 0
 ENDIF
 IF ((validate(ddr_opsexec_nodes->src_node_cnt,- (1))=- (1))
  AND validate(ddr_opsexec_nodes->src_node_cnt,1)=1)
  FREE RECORD ddr_opsexec_nodes
  RECORD ddr_opsexec_nodes(
    1 src_node_cnt = i4
    1 src_nodes[*]
      2 node_name = vc
      2 tgt_map_node = vc
      2 ignore_ind = i2
      2 ocg_cnt = i4
      2 ocg_list[*]
        3 ocg_id = f8
  )
  SET ddr_opsexec_nodes->src_node_cnt = 0
 ENDIF
 IF ((validate(ddr_lreg_servers->cnt,- (1))=- (1))
  AND validate(ddr_lreg_servers->cnt,1)=1)
  FREE RECORD ddr_lreg_servers
  RECORD ddr_lreg_servers(
    1 cnt = i4
    1 qual[*]
      2 srv_nbr = i4
  )
  SET ddr_lreg_servers->cnt = 0
 ENDIF
 IF (validate(ddr_ops_info->version,1.0)=1.0
  AND validate(ddr_ops_info->version,2.0)=2.0)
  FREE RECORD ddr_ops_info
  RECORD ddr_ops_info(
    1 version = f8
    1 migration_in_progress = i2
    1 error = vc
    1 tbl_name = vc
    1 col_host = vc
    1 col_group_id = vc
    1 col_group_name = vc
    1 col_server_nbr = vc
  )
  SET ddr_ops_info->version = 0.0
  SET ddr_ops_info->migration_in_progress = 0
  SET ddr_ops_info->error = ""
  SET ddr_ops_info->tbl_name = ""
  SET ddr_ops_info->col_host = ""
  SET ddr_ops_info->col_group_id = ""
  SET ddr_ops_info->col_group_name = ""
  SET ddr_ops_info->col_server_nbr = ""
 ENDIF
 IF ((validate(ddr_backup_file_content->tgt_backup_list_cnt,- (1))=- (1))
  AND validate(ddr_backup_file_content->tgt_backup_list_cnt,1)=1)
  FREE RECORD ddr_backup_file_content
  RECORD ddr_backup_file_content(
    1 tgt_backup_list_cnt = i4
    1 tgt_backup_list[*]
      2 token = vc
      2 mode = vc
      2 fdir = vc
      2 fvalue = vc
      2 dest_dir = vc
      2 dest_fname = vc
      2 options = vc
      2 req_ind = i2
    1 src_backup_list_cnt = i4
    1 src_backup_list[*]
      2 token = vc
      2 mode = vc
      2 fdir = vc
      2 fvalue = vc
      2 dest_dir = vc
      2 dest_fname = vc
      2 options = vc
      2 req_ind = i2
  )
  SET ddr_backup_file_content->tgt_backup_list_cnt = 0
  SET stat = alterlist(ddr_backup_file_content->tgt_backup_list,0)
  SET ddr_backup_file_content->src_backup_list_cnt = 0
  SET stat = alterlist(ddr_backup_file_content->src_backup_list,0)
 ENDIF
 IF ((validate(ddr_backup_reg_content->tgt_backup_list_cnt,- (1))=- (1))
  AND validate(ddr_backup_reg_content->tgt_backup_list_cnt,1)=1)
  FREE RECORD ddr_backup_reg_content
  RECORD ddr_backup_reg_content(
    1 tgt_backup_list_cnt = i4
    1 tgt_backup_list[*]
      2 token = vc
      2 mode = vc
      2 key = vc
      2 prop = vc
      2 dest_dir = vc
      2 dest_fname = vc
      2 req_ind = i2
      2 cre_key_ind = i2
  )
  SET ddr_backup_reg_content->tgt_backup_list_cnt = 0
  SET stat = alterlist(ddr_backup_reg_content->tgt_backup_list,0)
 ENDIF
 IF ((validate(ddr_backup_srvreg_content->tgt_backup_list_cnt,- (1))=- (1))
  AND validate(ddr_backup_srvreg_content->tgt_backup_list_cnt,1)=1)
  FREE RECORD ddr_backup_srvreg_content
  RECORD ddr_backup_srvreg_content(
    1 tgt_backup_list_cnt = i4
    1 tgt_backup_list[*]
      2 token = vc
      2 mode = vc
      2 entry = vc
      2 dest_dir = vc
      2 dest_fname = vc
      2 options = vc
      2 req_ind = i2
  )
  SET ddr_backup_srvreg_content->tgt_backup_list_cnt = 0
  SET stat = alterlist(ddr_backup_srvreg_content->tgt_backup_list,0)
 ENDIF
 DECLARE max_reg_env_len = i2 WITH protect, constant(12)
 DECLARE ddr_collect_source_data(null) = i2
 DECLARE ddr_collect_target_data(null) = i2
 DECLARE ddr_get_users(null) = i2
 DECLARE ddr_get_cerforms(null) = i2
 DECLARE ddr_get_ccldbas(null) = i2
 DECLARE ddr_get_ccluserdir(dgc_prompt_only=i2) = i2
 DECLARE ddr_get_new_source_data(null) = i2
 DECLARE ddr_get_new_target_data(null) = i2
 DECLARE ddr_get_preserved_data(null) = i2
 DECLARE ddr_get_ocdtools(null) = i2
 DECLARE ddr_get_config(null) = i2
 DECLARE ddr_get_ccldir(null) = i2
 DECLARE ddr_reset_36(null) = i2
 DECLARE ddr_pop_reg_struct(dprs_type=i2,dprs_file=vc,dprs_reset=i2) = i2
 DECLARE ddr_get_misc_data(dgmd_src_ind=i2,dgmd_tgt_ind=i2) = i2
 DECLARE ddr_create_dir(dcd_dir_name=vc) = i2
 DECLARE ddr_get_env_logical(dgel_log_ret=vc(ref)) = i2
 DECLARE ddr_env_confirm(dec_src_env=i2,dec_tgt_env=i2,dec_env_to_chk=vc,dec_env_ok_ret=i2(ref)) = i2
 DECLARE ddr_node_prompt(dnp_src_node=i2,dnp_tgt_node=i2,dnp_node_ret=vc(ref)) = i2
 DECLARE ddr_dev_prompt(ddp_src_dev=i2,ddp_tgt_dev=i2,ddp_dev_ret=vc(ref)) = i2
 DECLARE ddr_dir_prompt(ddp_src_dir=i2,ddp_tgt_dir=i2,ddp_dir_ret=vc(ref)) = i2
 DECLARE ddr_clear_dir(ddd_dir_name=vc) = i2
 DECLARE ddr_read_misc_data(drmd_src_ind=i2,drmd_tgt_ind=i2) = i2
 DECLARE ddr_write_misc_data(dwmd_src_ind=i2,dwmd_tgt_ind=i2) = i2
 DECLARE ddr_get_file_date(dgfd_file_name=vc,dgfd_file_date=f8(ref)) = i2
 DECLARE ddr_lreg_oper(dlo_parm_op_type=vc,dlo_parm_req=vc,dlo_parm_ret=vc(ref)) = i2
 DECLARE ddr_summary(ds_src_ind=i2,ds_tgt_ind=i2) = i2
 DECLARE ddr_get_wh(dgw_src_ind=i2,dgw_tgt_ind=i2,dgw_prompt_only=i2) = i2
 DECLARE ddr_prompt_node_names(dpnn_src_ind=i2,dpnn_tgt_ind=i2) = i2
 DECLARE ddr_get_dicdat(dgd_src_ind=i2,dgd_tgt_ind=i2) = i2
 DECLARE ddr_get_tdb(dgt_src_ind=i2,dgt_tgt_ind=i2) = i2
 DECLARE ddr_get_srv_def(dgsd_src_ind=i2,dgsd_tgt_ind=i2) = i2
 DECLARE ddr_get_sec_user(dgsu_src_ind=i2,dgsu_tgt_ind=i2,dgsu_is_primary=i2) = i2
 DECLARE ddr_get_env_reg(dger_src_ind=i2,dger_tgt_ind=i2,dger_type=vc,dger_current=i2) = i2
 DECLARE ddr_get_invalid_tbls(dgit_src_ind=i2,dgit_tgt_ind=i2,dgit_prompt_only=i2) = i2
 DECLARE ddr_build_parfile(dbp_dir=vc,dbp_exp_prefix=vc,dbp_imp_prefix=vc) = i2
 DECLARE ddr_build_expimp_cmds(dbec_src_ind=i2,dbec_tgt_ind=i2,dbec_dir=vc,dbec_type=vc,
  dbec_cmd_file_ret=vc(ref)) = i2
 DECLARE ddr_validate_user(dvu_env_name=vc) = i2
 DECLARE ddr_validate_source_env(dvse_chk_dir=i2) = i2
 DECLARE ddr_validate_target_data(null) = i2
 DECLARE ddr_validate_source_data(null) = i2
 DECLARE ddr_create_tar_routine(dctr_dir=vc,dctr_tar_name=vc,dctr_cmd_file=vc(ref),dctr_type=vc) = i2
 DECLARE ddr_get_nodes(dgn_src_ind=i2,dgn_tgt_ind=i2) = i2
 DECLARE ddr_get_srv_id(dgsi_type=vc,dgsi_desc=vc,dgsi_server_id=vc(ref)) = i2
 DECLARE ddr_get_srv_info(dgsi_type=vc,dgsi_desc=vc,dgsi_server_id=vc(ref),dgsi_server_desc=vc(ref))
  = i2
 DECLARE ddr_get_srv_details(dgsi_type=vc,dgsi_id=vc,dgsi_desc=vc(ref),dgsd_srv_found=i2(ref)) = i2
 DECLARE ddr_get_mng_userpass(dgmu_src_ind=i2,dgmu_tgt_ind=i2) = i2
 DECLARE ddr_get_from_dir(dgfd_src_ind=i2,dgfd_logical=vc,dgfd_from_dir=vc(ref)) = i2
 DECLARE ddr_check_mng_accnt_privs(dgmu_src_ind=i2,dgmu_tgt_ind=i2,dcmap_user=vc,dcmap_pass=vc,
  dcmap_has_privs=i2(ref)) = i2
 DECLARE ddr_get_local_user_name(dglun_src_ind=i2,dglun_tgt_ind=i2) = i2
 DECLARE ddr_get_local_group_name(dglgn_src_ind=i2,dglgn_tgt_ind=i2) = i2
 DECLARE ddr_get_sec_user_name(dgsun_src_ind=i2,dgsun_tgt_ind=i2) = i2
 DECLARE ddr_scp_apply(dsa_server_id=vc,dsa_src_ind=i2,dsa_tgt_ind=i2) = i2
 DECLARE ddr_set_tgt_node_flag(null) = i2
 DECLARE ddr_get_srv_status(dgss_id=i4,dgss_desc=vc,dgss_srv_status=i2(ref)) = i2
 DECLARE ddr_backup_servers(null) = i2
 DECLARE ddr_continue_prompt(null) = i2
 DECLARE ddr_get_tgt_node_flag(null) = i2
 DECLARE ddr_parse_count(dpc_file_name=vc,dpc_count=i4(ref)) = i2
 DECLARE ddr_preserve_prompt(dpp_preserve=i2(ref)) = i2
 DECLARE ddr_preserve_check_prompt(dpcp_preserve=i2(ref)) = i2
 DECLARE ddr_get_link_data(null) = i2
 DECLARE ddr_rpt_reg_issues(null) = i2
 DECLARE ddr_check_sqlnet(dcs_src_ind=i2,dcs_tgt_ind=i2,dcs_oracle_home=vc) = i2
 DECLARE ddr_data_collection_space_needs(ddcsn_src_ind=i2,ddcsn_tgt_ind=i2) = i2
 DECLARE ddr_add_tar_error(date_src_ind=i2,date_tgt_ind=i2,date_type=vc) = i2
 DECLARE ddr_get_tar_errors(dgte_src_ind=i2,dgte_tgt_ind=i2,dgte_tar_errors_ind=i2(ref),
  dgte_tar_errors_list=vc(ref)) = i2
 DECLARE ddr_get_tdb_file(dgtf_src_ind=i2,dgtf_tgt_ind=i2,dgtf_server_id=i4,dgtf_file_ret=vc(ref)) =
 i2
 DECLARE ddr_get_adm_env(null) = i2
 DECLARE ddr_prompt_tgt_backups(null) = i2
 DECLARE ddr_lnx_findfile(dlf_file_path=vc) = i2
 DECLARE ddr_validate_preserve_pwds(null) = i2
 DECLARE ddr_get_opsexec_servers(dgos_src_ind=i2,dgos_tgt_ind=i2,dgos_set_protect_ind=i2) = i2
 DECLARE ddr_get_opsexec_node_map(null) = i2
 DECLARE ddr_update_opsexec_mapping(null) = i2
 DECLARE ddr_assign_opsexec_servers(null) = i2
 DECLARE ddr_validate_opsexec_hosts(null) = i2
 DECLARE ddr_validate_mapping(dvm_mapping_applied=i2(ref),dvm_invalid_ind=i2(ref)) = i2
 DECLARE ddr_cleanup_opsexec_mapping(null) = i2
 DECLARE ddr_get_nodes_dns(null) = i2
 DECLARE ddr_get_lreg_servers(dgls_path=vc,dgls_domain=vc) = i2
 DECLARE ddr_get_tdb_data(dgtd_file_name=vc) = i2
 DECLARE ddr_identify_ldap_usage(dilu_env=vc,dilu_domain=vc,dilu_mng=vc,dilu_mng_pwd=vc,dilu_system=
  vc,
  dilu_priv=vc,dilu_was_ind=i2,dilu_ldap_ind=i2(ref)) = i2
 DECLARE ddr_interrogator_usage(diu_interrogator_ind=i2(ref),diu_interrogator_node=vc(ref)) = i2
 DECLARE ddr_interrogator_backup(dib_mode=vc) = i2
 DECLARE ddr_get_ops_version(dgov_db_link=vc) = i2
 DECLARE ddr_backup_file_content_load(dbfcl_src_ind=i2,dbfcl_tgt_ind=i2) = i2
 DECLARE ddr_backup_file_content(dbfc_mode=vc,dbfc_fdir=vc,dbfc_fvalue=vc,dbfc_dest_dir=vc,
  dbfc_dest_fname=vc,
  dbfc_options=vc,dbfc_req_ind=i2) = i2
 DECLARE ddr_backup_reg_content_load(null) = i2
 DECLARE ddr_backup_reg_content(dbrc_mode=vc,dbrc_key=vc,dbrc_prop=vc,dbrc_dest_dir=vc,
  dbrc_dest_fname=vc,
  dbrc_req_ind=i2,dbrc_cre_key_ind=i2) = i2
 DECLARE ddr_restore_reg_content(null) = i2
 DECLARE ddr_backup_srvreg_content_load(null) = i2
 DECLARE ddr_backup_srvreg_content(dbsc_mode=vc,dbsc_entry=vc,dbsc_dest_dir=vc,dbsc_dest_fname=vc,
  dbsc_options=vc,
  dbsc_req_ind=i2) = i2
 DECLARE ddr_val_client_mnemonic(dvcm_src_ind=i2,dvcm_tgt_ind=i2,dvcm_inform_only_ind=i2,
  dvcm_invalid_data_ind=i2(ref)) = i2
 SUBROUTINE ddr_get_mng_userpass(dgmu_src_ind,dgmu_tgt_ind)
   DECLARE dgmu_ok = i2 WITH protect, noconstant(0)
   DECLARE dgmu_user = vc WITH protect, noconstant("")
   DECLARE dgmu_pass = vc WITH protect, noconstant("")
   DECLARE dgmu_has_privs = i2 WITH protect, noconstant(1)
   DECLARE dgmu_pass_mismatch = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Prompt user for ManageAccounts user/pass."
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dgmu_ok=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,20,131)
     CALL text(2,2,concat(
       "Provide the username and password for a high-privileged Millennium account containing ",
       "the ManageAccounts, ManageServers,"))
     CALL text(3,2,
      "ManageResources and ModifyServers privileges (i.e.  Cerner account is often granted these privileges)."
      )
     CALL text(5,2,"IMPORTANT:  Do not use system or systemoe user.")
     CALL text(6,2,"            Ensure that user has not expired before proceeding.")
     CALL text(8,2,"Username:")
     CALL text(9,2,"Password:")
     CALL text(13,2,"Continue/Exit [C/E]:")
     IF (dgmu_has_privs=2)
      CALL text(15,2,"The account provided could not be validated. Please retry.")
     ELSEIF (dgmu_has_privs=0)
      CALL text(15,2,
       "The account provided does not have required privileges. Please choose another account.")
     ENDIF
     CALL accept(8,12,"P(30);C"," "
      WHERE curaccept > " "
       AND  NOT (curaccept IN ("system", "systemoe", "SYSTEM", "SYSTEMOE")))
     SET dgmu_user = curaccept
     CALL accept(9,12,"P(30);C"," "
      WHERE curaccept > " ")
     SET dgmu_pass = curaccept
     CALL accept(13,23,"A;cu"," "
      WHERE curaccept IN ("C", "E"))
     IF (curaccept="E")
      CALL clear(1,1)
      SET message = nowindow
      SET dm_err->emsg = "User elected to quit from managed account user/password entry."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      IF (ddr_check_mng_accnt_privs(dgmu_src_ind,dgmu_tgt_ind,dgmu_user,dgmu_pass,dgmu_has_privs)=0)
       RETURN(0)
      ENDIF
      IF (dgmu_has_privs=1)
       SET dgmu_ok = 1
      ENDIF
     ENDIF
   ENDWHILE
   CALL clear(1,1)
   SET message = nowindow
   IF (dgmu_src_ind=1)
    SET ddr_domain_data->src_mng = dgmu_user
    SET ddr_domain_data->src_mng_pwd = dgmu_pass
   ELSE
    SET ddr_domain_data->tgt_mng = dgmu_user
    SET ddr_domain_data->tgt_mng_pwd = dgmu_pass
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_check_mng_accnt_privs(dcmap_src_ind,dcmap_tgt_ind,dcmap_user,dcmap_pass,
  dcmap_has_privs)
   DECLARE dcmap_file_name = vc WITH protect, noconstant("")
   DECLARE dcmap_cmd = vc WITH protect, noconstant("")
   DECLARE dcmap_ret = vc WITH protect, noconstant("")
   DECLARE dcmap_dir = vc WITH protect, noconstant("")
   DECLARE dcmap_domain = vc WITH protect, noconstant("")
   SET message = nowindow
   SET dm_err->eproc = "Verify that managed account provided has sufficient privileges"
   CALL disp_msg("",dm_err->logfile,0)
   IF (dcmap_src_ind=1)
    SET dcmap_dir = ddr_domain_data->src_tmp_full_dir
    SET dcmap_domain = ddr_domain_data->src_domain_name
   ELSE
    SET dcmap_dir = ddr_domain_data->tgt_tmp_full_dir
    SET dcmap_domain = ddr_domain_data->tgt_domain_name
   ENDIF
   SET dcmap_file_name = concat(dcmap_dir,"check_mng_accnt",evaluate(dm2_sys_misc->cur_os,"AXP",
     ".com",".ksh"))
   IF (dm2_findfile(dcmap_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dcmap_cmd = concat("del ",dcmap_file_name,";*")
    ELSE
     SET dcmap_cmd = concat("rm ",dcmap_file_name)
    ENDIF
    IF (dm2_push_dcl(dcmap_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to check managed account privileges :",dcmap_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dcmap_file_name)
    FROM (dummyt t  WITH seq = 1)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!check_mng_accnt.com"), row + 1,
      CALL print("$!"),
      row + 1,
      CALL print('$tgt_node = f$getsyi("nodename") '), row + 1,
      dcmap_cmd = concat('$if f$search("',dcmap_dir,'check_mng_accnt.dat") .nes. "" then delete ',
       dcmap_dir,"check_mng_accnt.dat;*"),
      CALL print(dcmap_cmd), row + 1,
      CALL print(concat("$define/user_mode sys$output ",dcmap_dir,"check_mng_accnt.dat")), row + 1,
      CALL print("$mcr cer_exe:authview"),
      row + 1,
      CALL print("$DECK"), row + 1,
      CALL print(dcmap_user), row + 1,
      CALL print(dcmap_domain),
      row + 1,
      CALL print(dcmap_pass), row + 1,
      CALL print(concat("show ",dcmap_user)), row + 1,
      CALL print("exit"),
      row + 1,
      CALL print("$EOD"), row + 1,
      CALL print("$mng_srv_priv = 0"), row + 1,
      CALL print("$mod_srv_priv = 0"),
      row + 1,
      CALL print("$mng_act_priv = 0"), row + 1,
      CALL print("$mng_res_priv = 0"), row + 1,
      CALL print("$not_valid = 0"),
      row + 1,
      CALL print(concat("$open/read PRIVS_LIST ",dcmap_dir,"check_mng_accnt.dat")), row + 1,
      CALL print("$READ_PRIVS_LIST:"), row + 1,
      CALL print("$   read/end_of_file=END_READ_PRIVS_LIST PRIVS_LIST record"),
      row + 1,
      CALL print('$   record = f$edit(record, "lowercase")'), row + 1,
      CALL print("$   length = f$length(record)"), row + 1,
      CALL print('$   pos = f$locate("manageservers", record)'),
      row + 1,
      CALL print("$   if (pos .gt. 0) .and. (pos .ne. length)"), row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      mng_srv_priv = 1"),
      row + 1,
      CALL print("$   endif"), row + 1,
      CALL print('$   pos = f$locate("modifyservers", record)'), row + 1,
      CALL print("$   if (pos .gt. 0) .and. (pos .ne. length)"),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      mod_srv_priv = 1"), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print('$   pos = f$locate("manageaccounts", record)'), row + 1,
      CALL print("$   if (pos .gt. 0) .and. (pos .ne. length)"), row + 1,
      CALL print("$   then"),
      row + 1,
      CALL print("$      mng_act_priv = 1"), row + 1,
      CALL print("$   endif"), row + 1,
      CALL print('$   pos = f$locate("manageresources", record)'),
      row + 1,
      CALL print("$   if (pos .gt. 0) .and. (pos .ne. length)"), row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      mng_res_priv = 1"),
      row + 1,
      CALL print("$   endif"), row + 1,
      CALL print('$   pos = f$locate("user authorization failure", record)'), row + 1,
      CALL print("$   if (pos .ge. 0) .and. (pos .ne. length)"),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      not_valid = 1"), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print("$  write sys$output record "), row + 1,
      CALL print("$   goto READ_PRIVS_LIST "), row + 1,
      CALL print("$END_READ_PRIVS_LIST: "),
      row + 1,
      CALL print("$   close PRIVS_LIST  "), row + 1,
      CALL print("$if (not_valid .eq. 1)"), row + 1,
      CALL print("$then"),
      row + 1,
      CALL print('$   write sys$output "Managed Account provided could NOT be validated"'), row + 1,
      CALL print("$   exit 2"), row + 1,
      CALL print("$endif"),
      row + 1,
      CALL print(
      "$if (mng_srv_priv .eq. 0) .or. (mod_srv_priv .eq. 0) .or. (mng_act_priv .eq. 0) .or. (mng_res_priv .eq. 0)"
      ), row + 1,
      CALL print("$then"), row + 1,
      CALL print(
      '$   write sys$output "Managed Account provided does NOT have sufficient privileges."'),
      row + 1,
      CALL print("$   exit 2"), row + 1,
      CALL print("$else"), row + 1,
      CALL print('$   write sys$output "Managed Account provided does have sufficient privileges."'),
      row + 1,
      CALL print("$   exit 1"), row + 1,
      CALL print("$endif"), row + 1,
      CALL print("$exit 1"),
      row + 1
     ELSE
      CALL print("#!/usr/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("# check_mng_accnt.ksh"), row + 1,
      CALL print("#"), row + 1,
      CALL print("tgt_node=`hostname`"),
      row + 1,
      CALL print(concat("pwd='",dcmap_pass,"'")), row + 1
      IF ((dm2_sys_misc->cur_os != "LNX"))
       dcmap_cmd = concat('echo "',dcmap_user,"\n",dcmap_domain,"\n",
        "$pwd",'\n" | authview "show ',dcmap_user,'" > ',dcmap_dir,
        "check_mng_accnt.dat")
      ELSE
       dcmap_cmd = concat('echo -e "',dcmap_user,"\n",dcmap_domain,"\n",
        "$pwd",'\n" | authview "show ',dcmap_user,'" > ',dcmap_dir,
        "check_mng_accnt.dat")
      ENDIF
      CALL print(dcmap_cmd), row + 1, row + 1,
      dcmap_cmd = concat("   tr '[:upper:]' '[:lower:]' < ",dcmap_dir,
       'check_mng_accnt.dat |grep "user authorization failure" '),
      CALL print(dcmap_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Managed Account provided could NOT be validated"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("fi"),
      row + 1, row + 1, dcmap_cmd = concat("   tr '[:upper:]' '[:lower:]' < ",dcmap_dir,
       'check_mng_accnt.dat |grep "manageservers" '),
      CALL print(dcmap_cmd), row + 1,
      CALL print("if [[ $? -ne 0 ]]"),
      row + 1,
      CALL print("then"), row + 1,
      CALL print('   echo "Managed Account provided does NOT have sufficient privileges"'), row + 1,
      CALL print("   exit 1"),
      row + 1,
      CALL print("fi"), row + 1,
      row + 1, dcmap_cmd = concat("   tr '[:upper:]' '[:lower:]' < ",dcmap_dir,
       'check_mng_accnt.dat |grep "modifyservers" '),
      CALL print(dcmap_cmd),
      row + 1,
      CALL print("if [[ $? -ne 0 ]]"), row + 1,
      CALL print("then"), row + 1,
      CALL print('   echo "Managed Account provided does NOT have sufficient privileges"'),
      row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("fi"), row + 1, row + 1,
      dcmap_cmd = concat("   tr '[:upper:]' '[:lower:]' < ",dcmap_dir,
       'check_mng_accnt.dat |grep "manageaccounts" '),
      CALL print(dcmap_cmd), row + 1,
      CALL print("if [[ $? -ne 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Managed Account provided does NOT have sufficient privileges"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("fi"),
      row + 1, row + 1, dcmap_cmd = concat("   tr '[:upper:]' '[:lower:]' < ",dcmap_dir,
       'check_mng_accnt.dat |grep "manageresources" '),
      CALL print(dcmap_cmd), row + 1,
      CALL print("if [[ $? -ne 0 ]]"),
      row + 1,
      CALL print("then"), row + 1,
      CALL print('   echo "Managed Account provided does NOT have sufficient privileges"'), row + 1,
      CALL print("   exit 1"),
      row + 1,
      CALL print("fi"), row + 1,
      row + 1,
      CALL print('echo "Managed Account provided does have sufficient privileges"'), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute ",dcmap_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dcmap_cmd = concat("@",dcmap_file_name)
   ELSE
    SET dcmap_cmd = concat("chmod 777 ",dcmap_file_name)
    IF (dm2_push_dcl(dcmap_cmd)=0)
     RETURN(0)
    ENDIF
    SET dcmap_cmd = concat(". ",dcmap_file_name)
   ENDIF
   IF (dm2_push_dcl(dcmap_cmd)=0)
    IF (findstring("Managed Account provided could NOT be validated",dm_err->errtext,1,1) > 0)
     SET dcmap_has_privs = 2
    ELSEIF (findstring("Managed Account provided does NOT have sufficient privileges",dm_err->errtext,
     1,1) > 0)
     SET dcmap_has_privs = 0
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    SET dcmap_has_privs = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_sec_user_name(dgsun_src_ind,dgsun_tgt_ind)
   DECLARE dgsun_sec_user_logical = vc WITH protect, noconstant("")
   DECLARE dgsun_sec_user_name = vc WITH protect, noconstant("")
   DECLARE dgsun_end_pos = i2 WITH protect, noconstant(0)
   DECLARE dgsun_length = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get Sec User File Name from logical sec_user."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgsun_sec_user_logical = trim(logical("sec_user"))
   SET dgsun_length = size(dgsun_sec_user_logical,1)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsun_end_pos = findstring(":",dgsun_sec_user_logical,1,1)
   ELSE
    SET dgsun_end_pos = findstring("/",dgsun_sec_user_logical,1,1)
   ENDIF
   SET dgsun_sec_user_name = trim(substring((dgsun_end_pos+ 1),(dgsun_length - dgsun_end_pos),
     dgsun_sec_user_logical))
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Sec User Logical: ",dgsun_sec_user_logical))
    CALL echo(concat("Sec User Name: ",dgsun_sec_user_name))
   ENDIF
   IF (dgsun_sec_user_name="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Could not retrieve sec user file name from logical 'sec_user'"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgsun_src_ind=1)
    SET ddr_domain_data->src_sec_user_name = dgsun_sec_user_name
   ELSE
    SET ddr_domain_data->tgt_sec_user_name = dgsun_sec_user_name
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_local_user_name(dglun_src_ind,dglun_tgt_ind)
   DECLARE dglun_str = vc WITH protect, noconstant("")
   DECLARE dglun_reg_ret = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get Local User Name from registry."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dglun_str = concat("\environment\",logical("environment")," LocalUserName")
   ELSE
    SET dglun_str = concat("\\environment\\",logical("environment")," LocalUserName")
   ENDIF
   IF (ddr_lreg_oper("GET",dglun_str,dglun_reg_ret)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Registry Property: ",dglun_str))
    CALL echo(concat("Local User Name: ",dglun_reg_ret))
   ENDIF
   IF (((trim(dglun_reg_ret)="") OR (trim(dglun_reg_ret)="NOPARMRETURNED")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Could not retrieve local user name from registry entry"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dglun_src_ind=1)
    SET ddr_domain_data->src_local_user_name = dglun_reg_ret
   ELSE
    SET ddr_domain_data->tgt_local_user_name = dglun_reg_ret
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_local_group_name(dglgn_src_ind,dglgn_tgt_ind)
   DECLARE dglgn_cmd = vc WITH protect, noconstant("")
   DECLARE dglgn_group = vc WITH protect, noconstant("")
   DECLARE dglgn_user = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get Local Group Name for current user from OS."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dglgn_user = evaluate(dglgn_src_ind,1,ddr_domain_data->src_local_user_name,ddr_domain_data->
    tgt_local_user_name)
   SET dglgn_cmd = concat("id -gn ",trim(dglgn_user))
   IF (dm2_push_dcl(dglgn_cmd)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (((findstring("user not found",cnvtlower(dm_err->errtext),1,1) > 0) OR ((dm_err->errtext="")))
   )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Could not retrieve local group name for user: ",dglgn_user)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dglgn_group = trim(dm_err->errtext)
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
    CALL echo(dglgn_group)
   ENDIF
   IF (dglgn_src_ind=1)
    SET ddr_domain_data->src_local_group_name = dglgn_group
   ELSE
    SET ddr_domain_data->tgt_local_group_name = dglgn_group
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_reset_36(dr3_node,dr3_env)
   DECLARE dr3_str = vc WITH protect, noconstant("")
   DECLARE dr3_ret = vc WITH protect, noconstant("")
   DECLARE dr3_err = i2 WITH protect, noconstant(0)
   DECLARE dr3_src_ind = i2 WITH protect, noconstant(0)
   DECLARE dr3_tgt_ind = i2 WITH protect, noconstant(0)
   SET dr3_err = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dr3_str = concat("\node\",dr3_node,"\domain\",dr3_env,'\servers\36 Protect "Y"')
   ELSE
    SET dr3_str = concat("\\node\\",dr3_node,"\\domain\\",dr3_env,'\\servers\\36 Protect "Y"')
   ENDIF
   IF (ddr_lreg_oper("SET",dr3_str,dr3_ret)=0)
    RETURN(0)
   ENDIF
   SET dm_err->err_ind = dr3_err
   IF (trim(dr3_env)=trim(ddr_domain_data->src_domain_name)
    AND trim(dr3_node)=trim(ddr_domain_data->src_nodes[1].node_name))
    SET dr3_src_ind = 1
   ELSE
    SET dr3_tgt_ind = 1
   ENDIF
   IF (ddr_scp_apply("36",dr3_src_ind,dr3_tgt_ind)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_scp_apply(dsa_server_id,dsa_src_ind,dsa_tgt_ind)
   DECLARE dsa_str = vc WITH protect, noconstant("")
   DECLARE dsa_file_name = vc WITH protect, noconstant("")
   DECLARE dsa_cmd = vc WITH protect, noconstant("")
   DECLARE dsa_ret = vc WITH protect, noconstant("")
   DECLARE dsa_node = vc WITH protect, noconstant(trim(cnvtlower(curnode)))
   DECLARE dsa_mng = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Apply registry changes for server: ",dsa_server_id)
   CALL disp_msg("",dm_err->logfile,0)
   IF (dsa_src_ind=1)
    SET dsa_mng = ddr_domain_data->src_mng
   ELSE
    IF ((ddr_domain_data->process="REPLICATE"))
     SET dsa_mng = ddr_domain_data->src_mng
    ELSE
     SET dsa_mng = ddr_domain_data->tgt_mng
    ENDIF
   ENDIF
   IF (get_unique_file("dsa_scp_apply",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dsa_file_name = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to apply registry changes :",dsa_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dsa_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print(concat("$mcr cer_exe:scpview ",dsa_node)), row + 1,
      CALL print("$DECK"),
      row + 1
     ELSE
      IF (dsa_src_ind=1)
       CALL print(concat("src_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1
      ELSE
       IF ((ddr_domain_data->process="REPLICATE"))
        CALL print(concat("tgt_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1
       ELSE
        CALL print(concat("tgt_mng_pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1
       ENDIF
      ENDIF
      CALL print(concat("$cer_exe/scpview  ",dsa_node," <<!")), row + 1
     ENDIF
     IF (dsa_src_ind=1)
      CALL print(ddr_domain_data->src_mng), row + 1,
      CALL print(ddr_domain_data->src_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->src_mng_pwd), row + 1
      ELSE
       CALL print("$src_mng_pwd"), row + 1
      ENDIF
     ELSE
      CALL print(dsa_mng), row + 1,
      CALL print(ddr_domain_data->tgt_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       IF ((ddr_domain_data->process="REPLICATE"))
        CALL print(ddr_domain_data->src_mng_pwd), row + 1
       ELSE
        CALL print(ddr_domain_data->tgt_mng_pwd), row + 1
       ENDIF
      ELSE
       CALL print("$tgt_mng_pwd"), row + 1
      ENDIF
     ENDIF
     CALL print(concat("apply ",dsa_server_id)), row + 1,
     CALL print("exit"),
     row + 1
     IF ((dm2_sys_misc->cur_os != "AXP"))
      CALL print("!"), row + 1
     ELSE
      CALL print("$EOD"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute ",dsa_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dsa_cmd = concat("@",dsa_file_name)
   ELSE
    SET dsa_cmd = concat("chmod 777 ",dsa_file_name)
    IF (dm2_push_dcl(dsa_cmd)=0)
     RETURN(0)
    ENDIF
    SET dsa_cmd = concat(". $CCLUSERDIR/",dsa_file_name)
   ENDIF
   IF (dm2_push_dcl(dsa_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_create_tar_routine(dctr_dir,dctr_tar_name,dctr_cmd_file,dctr_type)
   DECLARE dctr_file = vc WITH protect, noconstant("")
   DECLARE dctr_wildcard = vc WITH protect, noconstant("*")
   IF (get_unique_file("ddr_tar",".ksh")=0)
    RETURN(0)
   ELSE
    SET dctr_file = dm_err->unique_fname
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("TAR directory:",dctr_dir))
   ENDIF
   SET dm_err->eproc = concat("Create file for tar file operation:",dctr_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dctr_file)
    DETAIL
     IF (dctr_type="CCLUSERDIR")
      CALL print(concat("cd ",dctr_dir)), row + 1,
      CALL print(concat("tar -chf ",dctr_tar_name," ",dctr_dir)),
      row + 1
     ELSEIF (dctr_type="CERFORMS")
      CALL print(concat("cd ",trim(logical("cer_forms")))), row + 1,
      CALL print(concat("tar -chf ",dctr_tar_name," ",dctr_dir)),
      row + 1
     ELSEIF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX"))
      AND dctr_type="WAREHOUSE")
      CALL print(concat("cd ",dctr_dir)), row + 1,
      CALL print(concat("tar -cf ",dctr_tar_name," ",dctr_wildcard)),
      row + 1
     ELSEIF (dctr_type="CCLDIR")
      CALL print(concat("cd ",dctr_dir)), row + 1,
      CALL print("if [[ -f tar_file_list.dat ]]"),
      row + 1,
      CALL print("then"), row + 1,
      CALL print("   rm tar_file_list.dat"), row + 1,
      CALL print("fi"),
      row + 1,
      CALL print("for L_FILE in `ls $CCLDIR`"), row + 1,
      CALL print("do"), row + 1,
      CALL print(
      "  if [[ $L_FILE != 'dic.dat' && $L_FILE != 'dic.idx' && $L_FILE != 'tar_file_list.dat' ]]"),
      row + 1,
      CALL print("  then"), row + 1,
      CALL print("    echo $L_FILE >> tar_file_list.dat"), row + 1,
      CALL print("  fi"),
      row + 1,
      CALL print("done"), row + 1,
      CALL print("chmod -R 777 tar_file_list.dat"), row + 1,
      CALL print(concat("tar -chf ",dctr_tar_name," $(cat tar_file_list.dat)")),
      row + 1
     ELSE
      CALL print(concat("cd ",dctr_dir)), row + 1,
      CALL print(concat("tar -chf ",dctr_tar_name," ",dctr_wildcard)),
      row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dctr_cmd_file = dctr_file
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_config(null)
   DECLARE dgc_cmd = vc WITH protect, noconstant("")
   DECLARE dgc_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgc_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgc_str = vc WITH protect, noconstant("")
   DECLARE dgc_to_dir = vc WITH protect, noconstant("")
   DECLARE dgc_from_dir = vc WITH protect, noconstant("")
   DECLARE dgc_file_name = vc WITH protect, noconstant(concat(ddr_domain_data->src_env,"_config.sav")
    )
   DECLARE dgc_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgc_cmd_file_ret = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgc_to_dir = ddr_domain_data->src_tmp_full_dir
   ELSE
    SET dgc_to_dir = ddr_domain_data->src_tmp_full_dir
   ENDIF
   IF (ddr_get_from_dir(1,"cer_config",dgc_from_dir)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("from_dir = ",dgc_from_dir))
   ENDIF
   SET dm_err->eproc = concat("Create backup of config to ",dgc_to_dir)
   CALL disp_msg("",dm_err->logfile,0)
   SET dgc_str = concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgc_to_dir,evaluate(
     dm2_sys_misc->cur_os,"AXP",concat(dgc_file_name,dgc_suffix),dgc_file_name))
   IF (dm2_findfile(concat(dgc_to_dir,dgc_file_name)) > 0)
    IF (dm2_push_dcl(dgc_str)=0)
     RETURN(0)
    ENDIF
   ENDIF
   CASE (dm2_sys_misc->cur_os)
    OF "AXP":
     SET dgc_cmd = concat("$ backup/ignore=interlock ",dgc_from_dir," ",dgc_to_dir,dgc_file_name,
      "/save")
    ELSE
     IF (ddr_create_tar_routine(dgc_from_dir,concat(dgc_to_dir,dgc_file_name),dgc_cmd_file_ret,
      "CONFIG")=0)
      RETURN(0)
     ENDIF
     SET dgc_cmd = concat(". $CCLUSERDIR/",dgc_cmd_file_ret)
   ENDCASE
   SET dm_err->eproc = concat("Copy config to ",dgc_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   SET dgc_no_error = dm2_push_dcl(dgc_cmd)
   IF (dgc_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND findstring("BACKUP-W",dm_err->errtext,1,1) > 0
    AND findstring("BACKUP-F",dm_err->errtext,1,1)=0)
    SET dgc_no_error = 1
   ELSE
    IF (findstring("tar: couldn't get",dm_err->errtext,1,0) > 0)
     IF (ddr_add_tar_error(1,0,"CER_CONFIG")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dgc_str = replace(dm_err->errtext,"tar: couldn't get gname for gid ","",0)
    SET dgc_str = cnvtalphanum(replace(dgc_str,"tar: couldn't get uname for uid ","",0))
    IF (isnumeric(dgc_str)=1)
     SET dgc_no_error = 1
    ENDIF
   ENDIF
   IF (dgc_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(concat(dgc_to_dir,dgc_file_name))=0)
    SET dm_err->emsg = concat("Error copying config. Copy does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(concat(dgc_to_dir,dgc_file_name),dgc_file_date)=0)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->src_config_ts = dgc_file_date
   SET ddr_domain_data->src_config_fnd = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_ccldir(null)
   DECLARE dgc_cmd = vc WITH protect, noconstant("")
   DECLARE dgc_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgc_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgc_str = vc WITH protect, noconstant("")
   DECLARE dgc_to_dir = vc WITH protect, noconstant("")
   DECLARE dgc_from_dir = vc WITH protect, noconstant("")
   DECLARE dgc_file_name = vc WITH protect, noconstant(concat(ddr_domain_data->src_env,"_ccldir.sav")
    )
   DECLARE dgc_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgc_cmd_file_ret = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgc_to_dir = ddr_domain_data->src_tmp_full_dir
   ELSE
    SET dgc_to_dir = ddr_domain_data->src_tmp_full_dir
   ENDIF
   IF (ddr_get_from_dir(1,"ccldir",dgc_from_dir)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Create backup of ccldir to ",dgc_to_dir)
   CALL disp_msg("",dm_err->logfile,0)
   SET dgc_str = concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgc_to_dir,evaluate(
     dm2_sys_misc->cur_os,"AXP",concat(dgc_file_name,dgc_suffix),dgc_file_name))
   IF (dm2_findfile(concat(dgc_to_dir,dgc_file_name)) > 0)
    IF (dm2_push_dcl(dgc_str)=0)
     RETURN(0)
    ENDIF
   ENDIF
   CASE (dm2_sys_misc->cur_os)
    OF "AXP":
     SET dgc_cmd = concat("$ backup/ignore=interlock ",dgc_from_dir," ",dgc_to_dir,dgc_file_name,
      "/save ","/exclude=dic.*;*")
    ELSE
     IF (ddr_create_tar_routine(dgc_from_dir,concat(dgc_to_dir,dgc_file_name),dgc_cmd_file_ret,
      "CCLDIR")=0)
      RETURN(0)
     ENDIF
     SET dgc_cmd = concat(". $CCLUSERDIR/",dgc_cmd_file_ret)
   ENDCASE
   SET dm_err->eproc = concat("Copy ccldir to ",dgc_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   SET dgc_no_error = dm2_push_dcl(dgc_cmd)
   IF (dgc_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND findstring("BACKUP-W",dm_err->errtext,1,1) > 0
    AND findstring("BACKUP-F",dm_err->errtext,1,1)=0)
    SET dgc_no_error = 1
   ELSE
    IF (findstring("tar: couldn't get",dm_err->errtext,1,0) > 0)
     IF (ddr_add_tar_error(1,0,"CCLDIR")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dgc_str = replace(dm_err->errtext,"tar: couldn't get gname for gid ","",0)
    SET dgc_str = cnvtalphanum(replace(dgc_str,"tar: couldn't get uname for uid ","",0))
    IF (isnumeric(dgc_str)=1)
     SET dgc_no_error = 1
    ENDIF
   ENDIF
   IF (dgc_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(concat(dgc_to_dir,dgc_file_name))=0)
    SET dm_err->emsg = concat("Error copying ccldir. Copy does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(concat(dgc_to_dir,dgc_file_name),dgc_file_date)=0)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->src_ccldir_ts = dgc_file_date
   SET ddr_domain_data->src_ccldir_fnd = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_ocdtools(null)
   DECLARE dgo_cmd = vc WITH protect, noconstant("")
   DECLARE dgo_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgo_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgo_str = vc WITH protect, noconstant("")
   DECLARE dgo_to_dir = vc WITH protect, noconstant("")
   DECLARE dgo_from_dir = vc WITH protect, noconstant("")
   DECLARE dgo_file_name = vc WITH protect, noconstant(concat(ddr_domain_data->src_env,"_ocds.sav"))
   DECLARE dgo_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgo_cmd_file_ret = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgo_to_dir = ddr_domain_data->src_tmp_full_dir
   ELSE
    SET dgo_to_dir = ddr_domain_data->src_tmp_full_dir
   ENDIF
   IF (ddr_get_from_dir(1,"cer_ocdtools",dgo_from_dir)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("from_dir = ",dgo_from_dir))
   ENDIF
   SET dm_err->eproc = concat("Create backup of ocd_tools to ",dgo_to_dir)
   CALL disp_msg("",dm_err->logfile,0)
   SET dgo_str = concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgo_to_dir,evaluate(
     dm2_sys_misc->cur_os,"AXP",concat(dgo_file_name,dgo_suffix),dgo_file_name))
   IF (dm2_findfile(concat(dgo_to_dir,dgo_file_name)) > 0)
    IF (dm2_push_dcl(dgo_str)=0)
     RETURN(0)
    ENDIF
   ENDIF
   CASE (dm2_sys_misc->cur_os)
    OF "AXP":
     SET dgo_cmd = concat("$ backup/ignore=interlock ",dgo_from_dir," ",dgo_to_dir,dgo_file_name,
      "/save")
    ELSE
     IF (ddr_create_tar_routine(dgo_from_dir,concat(dgo_to_dir,dgo_file_name),dgo_cmd_file_ret,
      "OCDTOOLS")=0)
      RETURN(0)
     ENDIF
     SET dgo_cmd = concat(". $CCLUSERDIR/",dgo_cmd_file_ret)
   ENDCASE
   SET dm_err->eproc = concat("Copy ocd_tools to ",dgo_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   SET dgo_no_error = dm2_push_dcl(dgo_cmd)
   IF (dgo_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND findstring("BACKUP-W",dm_err->errtext,1,1) > 0
    AND findstring("BACKUP-F",dm_err->errtext,1,1)=0)
    SET dgo_no_error = 1
   ELSE
    IF (findstring("tar: couldn't get",dm_err->errtext,1,0) > 0)
     IF (ddr_add_tar_error(1,0,"OCD_TOOLS")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dgo_str = replace(dm_err->errtext,"tar: couldn't get gname for gid ","",0)
    SET dgo_str = cnvtalphanum(replace(dgo_str,"tar: couldn't get uname for uid ","",0))
    IF (isnumeric(dgo_str)=1)
     SET dgo_no_error = 1
    ENDIF
   ENDIF
   IF (dgo_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(concat(dgo_to_dir,dgo_file_name))=0)
    SET dm_err->emsg = concat("Error copying ocd_tools. Copy does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(concat(dgo_to_dir,dgo_file_name),dgo_file_date)=0)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->src_ocd_tools_ts = dgo_file_date
   SET ddr_domain_data->src_ocd_tools_fnd = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_ccluserdir(dgc_prompt_only)
   DECLARE dgc_cmd = vc WITH protect, noconstant("")
   DECLARE dgc_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgc_file_name = vc WITH protect, noconstant(concat(ddr_domain_data->tgt_tmp_full_dir,
     ddr_domain_data->tgt_env,"_ccluserdir.sav"))
   DECLARE dgc_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgc_str = vc WITH protect, noconstant("")
   DECLARE dgc_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgc_cmd_file_ret = vc WITH protect, noconstant("")
   DECLARE dgc_from_dir = vc WITH protect, noconstant("")
   SET dgc_str = concat(dgc_file_name,"? (Y)es or (N)o:")
   IF (dgc_prompt_only=1)
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,11,131)
    CALL text(3,4,"Would you like CCLUSERDIR to be backed up to ")
    CALL text(4,8,dgc_str)
    CALL accept(4,(size(dgc_str)+ 10),"A;cu"," "
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     SET dm_err->eproc = "User elected to not backup CCLUSERDIR."
     CALL disp_msg(" ",dm_err->logfile,0)
     SET ddr_domain_data->get_ccluserdir = 0
     CALL clear(1,1)
     SET message = nowindow
     RETURN(1)
    ELSE
     SET ddr_domain_data->get_ccluserdir = 1
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
    RETURN(1)
   ENDIF
   IF (ddr_get_from_dir(0,"ccluserdir",dgc_from_dir)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Create backup of CCLUSERDIR to ",dgc_file_name)
   CALL disp_msg("",dm_err->logfile,0)
   SET dgc_str = concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(dm2_sys_misc->
     cur_os,"AXP",concat(dgc_file_name,dgc_suffix),dgc_file_name))
   IF (dm2_findfile(dgc_file_name) > 0)
    IF (dm2_push_dcl(dgc_str)=0)
     RETURN(0)
    ENDIF
   ENDIF
   CASE (dm2_sys_misc->cur_os)
    OF "AXP":
     SET dgc_cmd = concat("$ backup/ignore=interlock ",dgc_from_dir," ",dgc_file_name,"/save")
    ELSE
     IF (ddr_create_tar_routine(dgc_from_dir,dgc_file_name,dgc_cmd_file_ret,"CCLUSERDIR")=0)
      RETURN(0)
     ENDIF
     SET dgc_cmd = concat(". $CCLUSERDIR/",dgc_cmd_file_ret)
   ENDCASE
   SET dm_err->eproc = concat("Copy CCLUSERDIR to ",dgc_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   SET dgc_no_error = dm2_push_dcl(dgc_cmd)
   IF (dgc_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND findstring("BACKUP-W",dm_err->errtext,1,1) > 0
    AND findstring("BACKUP-F",dm_err->errtext,1,1)=0)
    SET dgc_no_error = 1
   ELSE
    IF (findstring("tar: couldn't get",dm_err->errtext,1,0) > 0)
     IF (ddr_add_tar_error(0,1,"CCLUSERDIR")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dgc_str = replace(dm_err->errtext,"tar: couldn't get gname for gid ","",0)
    SET dgc_str = cnvtalphanum(replace(dgc_str,"tar: couldn't get uname for uid ","",0))
    IF (isnumeric(dgc_str)=1)
     SET dgc_no_error = 1
    ENDIF
   ENDIF
   IF (dgc_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dgc_file_name)=0)
    SET dm_err->emsg = concat("Error copying CCLUSERDIR. Copy does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(dgc_file_name,dgc_file_date)=0)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->tgt_ccluserdir_ts = dgc_file_date
   SET ddr_domain_data->tgt_ccluserdir_fnd = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_users(null)
   DECLARE dgu_file_name = vc WITH protect, noconstant(concat(ddr_domain_data->tgt_tmp_full_dir,
     ddr_domain_data->tgt_env,"_grp_users.dat"))
   DECLARE dgu_cmd = vc WITH protect, noconstant("")
   DECLARE dgu_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgu_suffix = vc WITH protect, noconstant(";*")
   SET dm_err->eproc = concat("Get users from Domain Group and copy to ",dgu_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(dgu_file_name) > 0)
    IF (dm2_push_dcl("rm"," ",dgu_file_name)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (ddr_get_local_group_name(0,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dgu_cmd = concat("lsgroup -f -a users ",ddr_domain_data->tgt_local_group_name,
     " | grep users | cut -f2 -d= > ",dgu_file_name)
   ELSE
    SET dgu_cmd = concat("/usr/sam/lbin/get_gr_mems ",ddr_domain_data->tgt_local_group_name,"  > ",
     dgu_file_name)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("ddr_get_users dcl command: ",dgu_cmd))
   ENDIF
   IF (dm2_push_dcl(dgu_cmd)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(dgu_file_name,dgu_file_date)=0)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->tgt_users_fnd = 1
   SET ddr_domain_data->tgt_users_ts = dgu_file_date
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_ccldbas(null)
   DECLARE dgc_file_name = vc WITH protect, noconstant(concat(ddr_domain_data->tgt_tmp_full_dir,
     ddr_domain_data->tgt_env,"_dbas.dat"))
   DECLARE dgc_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgc_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgc_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Get CCL group 0 users and copy to ",dgc_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgc_str = concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(dm2_sys_misc->
     cur_os,"AXP",concat(dgc_file_name,dgc_suffix),dgc_file_name))
   IF (dm2_findfile(dgc_file_name) > 0)
    IF (dm2_push_dcl(dgc_str)=0)
     RETURN(0)
    ENDIF
   ENDIF
   FREE SET dgc_file_logical
   SET logical dgc_file_logical dgc_file_name
   SELECT INTO "dgc_file_logical"
    FROM duaf d
    WHERE d.group=0
    DETAIL
     dgc_str = trim(d.user_name), col 0, dgc_str,
     row + 1
    WITH noheading, nocounter, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(dgc_file_name,dgc_file_date)=0)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->tgt_dbas_fnd = 1
   SET ddr_domain_data->tgt_dbas_ts = dgc_file_date
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_cerforms(null)
   DECLARE dgc_find_str = vc WITH protect, noconstant("")
   DECLARE dgc_frm_found = i2 WITH protect, noconstant(0)
   DECLARE dgc_que_found = i2 WITH protect, noconstant(0)
   DECLARE dgc_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgc_str = vc WITH protect, noconstant("")
   DECLARE dgc_cmd = vc WITH protect, noconstant("")
   DECLARE dgc_file = vc WITH protect, noconstant("")
   DECLARE dgc_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgc_cmd_file_ret = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Copy TARGET cer_forms data to ",ddr_domain_data->tgt_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgc_file = concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,"_frmque.sav")
   SET dm_err->eproc = concat("Remove cer_forms data from ",ddr_domain_data->tgt_tmp_full_dir)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dgc_found = dm2_findfile(dgc_file)
   IF (dgc_found > 0)
    IF (dm2_push_dcl(concat("rm ",dgc_file))=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dgc_find_str = concat(trim(logical("cer_forms")),"/","form*")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    SET dgc_frm_found = dm2_findfile(dgc_find_str)
   ELSE
    SET dgc_frm_found = ddr_lnx_findfile(dgc_find_str)
   ENDIF
   IF (dgc_frm_found=1)
    SET dgc_str = "form*"
   ENDIF
   SET dgc_find_str = concat(trim(logical("cer_forms")),"/","queue*")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    SET dgc_que_found = dm2_findfile(dgc_find_str)
   ELSE
    SET dgc_que_found = ddr_lnx_findfile(dgc_find_str)
   ENDIF
   IF (dgc_que_found=1)
    IF (dgc_frm_found=1)
     SET dgc_str = concat(dgc_str," queue*")
    ELSE
     SET dgc_str = "queue*"
    ENDIF
   ENDIF
   IF (((dgc_que_found=1) OR (dgc_frm_found=1)) )
    IF (ddr_create_tar_routine(dgc_str,dgc_file,dgc_cmd_file_ret,"CERFORMS")=0)
     RETURN(0)
    ENDIF
    SET dgc_cmd = concat(". $CCLUSERDIR/",dgc_cmd_file_ret)
    SET dm_err->eproc = concat("Copy $cer_forms data to ",dgc_file)
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->disp_dcl_err_ind = 0
    SET dgc_no_error = dm2_push_dcl(dgc_cmd)
    IF (dgc_no_error=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dm_err)
     ENDIF
    ENDIF
    IF (findstring("tar: couldn't get",dm_err->errtext,1,0) > 0)
     IF (ddr_add_tar_error(0,1,"CER_FORMS")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dgc_str = replace(dm_err->errtext,"tar: couldn't get gname for gid ","",0)
    SET dgc_str = cnvtalphanum(replace(dgc_str,"tar: couldn't get uname for uid ","",0))
    IF (isnumeric(dgc_str)=1)
     SET dgc_no_error = 1
    ENDIF
    IF (dgc_no_error=0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_findfile(dgc_file)=0)
     SET dm_err->emsg = concat("Error copying $cer_forms data. Copy does not exist:",dgc_file)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (ddr_get_file_date(dgc_file,dgc_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->tgt_forms_ts = dgc_file_date
    SET ddr_domain_data->tgt_forms_fnd = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_preserved_data(null)
   DECLARE dgpd_file_full = vc WITH protect, noconstant("")
   DECLARE dgpd_file_date = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = "Preserve data from TARGET"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgpd_file_full = concat(ddr_domain_data->tgt_tmp_full_dir,drr_clin_copy_data->preserve_tbl_pre,
    evaluate(dm2_sys_misc->cur_os,"AXP","*.*;*","*.*"))
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF (dm2_findfile(dgpd_file_full) > 0)
     IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgpd_file_full))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF (ddr_lnx_findfile(dgpd_file_full) > 0)
     IF (dm2_push_dcl(concat("rm ",dgpd_file_full))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dgpd_file_full = concat(ddr_domain_data->tgt_tmp_full_dir,"dm2s",drr_clin_copy_data->
    preserve_sch_dt,evaluate(dm2_sys_misc->cur_os,"AXP","*.*;*","*.*"))
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF (dm2_findfile(dgpd_file_full) > 0)
     IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgpd_file_full))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF (ddr_lnx_findfile(dgpd_file_full) > 0)
     IF (dm2_push_dcl(concat("rm ",dgpd_file_full))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET drr_clin_copy_data->temp_location = ddr_domain_data->tgt_tmp_full_dir
   SET drr_clin_copy_data->standalone_expimp_process = ddr_domain_data->standalone_expimp_mode
   EXECUTE dm2_preserve_tables
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   IF ((ddr_domain_data->preserve_ind=1))
    SET ddr_domain_data->tgt_preserve_fnd = 1
    IF (ddr_get_file_date(dgpd_file_full,dgpd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->tgt_preserve_ts = dgpd_file_date
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_wh(dgw_src_ind,dgw_tgt_ind,dgw_prompt_only)
   DECLARE dgw_cmd_file = vc WITH protect, noconstant("")
   DECLARE dgw_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgw_cmd = vc WITH protect, noconstant("")
   DECLARE dgw_env = vc WITH protect, noconstant(evaluate(dgw_src_ind,1,ddr_domain_data->src_env,
     ddr_domain_data->tgt_env))
   DECLARE dgw_file_full = vc WITH protect, noconstant("")
   DECLARE dgw_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgw_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgw_str = vc WITH protect, noconstant("")
   DECLARE dgw_cmd_file_ret = vc WITH protect, noconstant("")
   DECLARE dgw_from_dir = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgw_file_full = concat(evaluate(dgw_src_ind,1,ddr_domain_data->src_tmp_full_dir,
      ddr_domain_data->tgt_tmp_full_dir),evaluate(dgw_src_ind,1,ddr_domain_data->src_env,
      ddr_domain_data->tgt_env),"_",evaluate(dgw_src_ind,1,ddr_domain_data->src_wh,ddr_domain_data->
      tgt_wh),".sav")
   ELSE
    SET dgw_file_full = concat(evaluate(dgw_src_ind,1,ddr_domain_data->src_tmp_full_dir,
      ddr_domain_data->tgt_tmp_full_dir),evaluate(dgw_src_ind,1,ddr_domain_data->src_env,
      ddr_domain_data->tgt_env),"_wh.sav")
   ENDIF
   IF (dgw_prompt_only=1)
    IF ((ddr_domain_data->get_warehouse=0))
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,20,131)
     CALL text(3,4,"Would you like to backup the warehouse (Y)es, (N)o?")
     CALL accept(3,60,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      SET ddr_domain_data->get_warehouse = 1
     ELSE
      SET ddr_domain_data->get_warehouse = 0
     ENDIF
    ENDIF
    IF ((ddr_domain_data->get_warehouse=1))
     CALL box(1,1,20,131)
     CALL text(5,4,concat("The ",evaluate(dgw_src_ind,1,"SOURCE","TARGET"),
       " warehouse will be backed up to "))
     CALL text(6,8,dgw_file_full)
     CALL text(8,4,"Please verify you have sufficient space allocated to ")
     CALL text(9,8,concat(evaluate(dgw_src_ind,1,ddr_domain_data->src_tmp_full_dir,ddr_domain_data->
        tgt_tmp_full_dir)," before continuing."))
     CALL text(11,4,'Enter "C" to Continue or "Q" to Quit: ')
     CALL accept(11,43,"A;cu"," "
      WHERE curaccept IN ("C", "Q"))
     IF (curaccept="Q")
      CALL clear(1,1)
      SET message = nowindow
      SET dm_err->emsg = "User elected to quit from warehouse backup prompt."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Warehouse Backup"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = concat("Remove:",dgw_file_full)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dgw_file_full) > 0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(dm2_sys_misc
       ->cur_os,"AXP",concat(dgw_file_full,dgw_suffix),dgw_file_full)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (ddr_get_from_dir(dgw_src_ind,"cer_wh",dgw_from_dir)=0)
     RETURN(0)
    ENDIF
    SET dgw_cmd = concat("$ backup/ignore=interlock ",dgw_from_dir," ",dgw_file_full,"/save")
   ELSE
    SET dgw_str = evaluate(dgw_src_ind,1,ddr_domain_data->src_wh_device,ddr_domain_data->
     tgt_wh_device)
    IF (ddr_create_tar_routine(dgw_str,dgw_file_full,dgw_cmd_file_ret,"WAREHOUSE")=0)
     RETURN(0)
    ENDIF
    SET dgw_cmd = concat(". $CCLUSERDIR/",dgw_cmd_file_ret)
   ENDIF
   SET dm_err->eproc = concat("Copy warehouse to ",dgw_file_full)
   CALL disp_msg("",dm_err->logfile,0)
   SET dm_err->disp_dcl_err_ind = 0
   SET dgw_no_error = dm2_push_dcl(dgw_cmd)
   IF (dgw_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND findstring("BACKUP-W",dm_err->errtext,1,1) > 0
    AND findstring("BACKUP-F",dm_err->errtext,1,1)=0)
    SET dgw_no_error = 1
   ELSE
    IF (findstring("tar: couldn't get",dm_err->errtext,1,0) > 0)
     IF (ddr_add_tar_error(dgw_src_ind,dgw_tgt_ind,"WAREHOUSE")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dgw_str = replace(dm_err->errtext,"tar: couldn't get gname for gid ","",0)
    SET dgw_str = cnvtalphanum(replace(dgw_str,"tar: couldn't get uname for uid ","",0))
    IF (isnumeric(dgw_str)=1)
     SET dgw_no_error = 1
    ENDIF
   ENDIF
   IF (dgw_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dgw_file_full)=0)
    SET dm_err->emsg = concat("Error copying ",evaluate(dgw_src_ind,1,"SOURCE","TARGET"),
     " warehouse. Copy does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(dgw_file_full,dgw_file_date)=0)
    RETURN(0)
   ENDIF
   IF (dgw_src_ind=1)
    SET ddr_domain_data->src_wh_ts = dgw_file_date
    SET ddr_domain_data->src_wh_fnd = 1
   ELSE
    SET ddr_domain_data->tgt_wh_ts = dgw_file_date
    SET ddr_domain_data->tgt_wh_fnd = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_lreg_oper(dlo_parm_op_type,dlo_parm_req,dlo_parm_ret)
   DECLARE dlo_cmd = vc WITH protect, noconstant("")
   DECLARE dlo_no_error = i2 WITH protect, noconstant(0)
   IF (get_unique_file("ddr_get_reg",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dlo_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to perform [",trim(dlo_parm_op_type),
    "] action in registry:",dlo_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dlo_file)
    DETAIL
     IF (dlo_parm_op_type="GET")
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$ mcr cer_exe:lreg -getp ",dlo_parm_req)), row + 1,
       CALL print("$ write sys$output lreg_result"),
       row + 1
      ELSE
       dlo_cmd = concat("$cer_exe/lreg -getp ",dlo_parm_req),
       CALL print(concat("$cer_exe/lreg -getp ",dlo_parm_req)), row + 1
      ENDIF
     ELSEIF (dlo_parm_op_type="SET")
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$ mcr cer_exe:lreg -setp ",dlo_parm_req)), row + 1,
       CALL print("$ write sys$output lreg_result"),
       row + 1
      ELSE
       dlo_cmd = concat("$cer_exe/lreg -setp ",dlo_parm_req),
       CALL print(concat("$cer_exe/lreg -setp ",dlo_parm_req)), row + 1
      ENDIF
     ELSEIF (dlo_parm_op_type="CREATE")
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$ mcr cer_exe:lreg -crek ",dlo_parm_req)), row + 1
      ELSE
       dlo_cmd = concat("$cer_exe/lreg -crek ",dlo_parm_req),
       CALL print(concat("$cer_exe/lreg -crek ",dlo_parm_req)), row + 1
      ENDIF
     ELSEIF (dlo_parm_op_type="REMOVEKEY")
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$ mcr cer_exe:lreg -remk ",dlo_parm_req)), row + 1,
       CALL print("$ write sys$output lreg_result"),
       row + 1
      ELSE
       dlo_cmd = concat("$cer_exe/lreg -remk ",dlo_parm_req),
       CALL print(concat("$cer_exe/lreg -remk ",dlo_parm_req)), row + 1
      ENDIF
     ELSE
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$ mcr cer_exe:lreg -delp ",dlo_parm_req)), row + 1,
       CALL print("$ write sys$output lreg_result"),
       row + 1
      ELSE
       dlo_cmd = concat("$cer_exe/lreg -delp ",dlo_parm_req),
       CALL print(concat("$cer_exe/lreg -delp ",dlo_parm_req)), row + 1
      ENDIF
     ENDIF
    WITH nocounter, maxcol = 2000, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dlo_cmd > "")
    SET dm_err->eproc = concat("Operation for registry: ",dlo_cmd)
   ELSE
    SET dm_err->eproc = concat("Operation for registry: ",dlo_parm_req)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgfd_cmd = concat("@",dlo_file)
   ELSE
    SET dgfd_cmd = concat(". $CCLUSERDIR/",dlo_file)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   SET dlo_no_error = dm2_push_dcl(dgfd_cmd)
   IF (dlo_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ENDIF
   IF (validate(dm2_lreg_allow_for_blanks,- (1))=1)
    SET dm2_lreg_allow_for_blanks = 0
    IF (((findstring("unable",dm_err->errtext,1,1)) OR (((findstring("key not found",dm_err->errtext,
     1,1)) OR (findstring("property not found",dm_err->errtext,1,1))) )) )
     SET dlo_no_error = 1
     SET dlo_parm_ret = "NOPARMRETURNED"
    ELSE
     SET dlo_parm_ret = dm_err->errtext
    ENDIF
   ELSE
    IF (((findstring("unable",dm_err->errtext,1,1)) OR ((((dm_err->errtext="")) OR (((findstring(
     "key not found",dm_err->errtext,1,1)) OR (findstring("property not found",dm_err->errtext,1,1)
    )) )) )) )
     SET dlo_no_error = 1
     SET dlo_parm_ret = "NOPARMRETURNED"
    ELSE
     SET dlo_parm_ret = dm_err->errtext
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("parm_value: <<",dlo_parm_ret,">>"))
   ENDIF
   IF (dlo_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_build_expimp_cmds(dbec_src_ind,dbec_tgt_ind,dbec_dir,dbec_type,dbec_cmd_file_ret)
   DECLARE dbec_file = vc WITH protect, noconstant("")
   DECLARE dbec_oraloc = vc WITH protect, noconstant("")
   DECLARE dbec_operation = vc WITH protect, noconstant("")
   DECLARE dbec_cnt = i4 WITH protect, noconstant(0)
   DECLARE dbec_user_cnt = i4 WITH protect, noconstant(0)
   DECLARE dbec_suffix = vc WITH protect, noconstant("")
   DECLARE dbec_log_cnt = i4 WITH protect, noconstant(0)
   DECLARE dbec_pword = vc WITH protect, noconstant("")
   DECLARE dbec_connect = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Building EXPORT/IMPORT command for Invalid tables"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dbec_src_ind=1)
    SET dbec_pword = dm2_install_schema->src_v500_p_word
    SET dbec_connect = dm2_install_schema->src_v500_connect_str
   ELSE
    SET dbec_pword = dm2_install_schema->v500_p_word
    SET dbec_connect = dm2_install_schema->v500_connect_str
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   CASE (dm2_sys_misc->cur_os)
    OF "AXP":
     CASE (dm2_rdbms_version->level1)
      OF 8:
       SET dbec_oraloc = "ora_root:[rdbms]"
      OF 9:
       SET dbec_oraloc = "ora_root:[bin]"
      ELSE
       SET dbec_oraloc = "ora_root:[bin]"
     ENDCASE
    ELSE
     SET dbec_oraloc = trim(logical("oracle_home"))
     SET dbec_oraloc = trim(build(trim(dbec_oraloc),"/bin/"))
   ENDCASE
   IF (get_unique_file(concat("invalid_data_",cnvtlower(dbec_type)),evaluate(dm2_sys_misc->cur_os,
     "AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dbec_file = dm_err->unique_fname
   ENDIF
   SET dbec_file = concat(dbec_dir,dbec_file)
   SET dm_err->eproc = concat("Create operation file:",dbec_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dbec_file_logical dbec_file
   SELECT INTO "dbec_file_logical"
    DETAIL
     FOR (dbec_user_cnt = 1 TO ddr_tbl_list->owner_cnt)
       FOR (dbec_cnt = 1 TO ddr_tbl_list->owner[dbec_user_cnt].par_file_cnt)
         dbec_log_cnt = (dbec_log_cnt+ 1), stat = alterlist(ddr_tbl_list->logs,dbec_log_cnt),
         dbec_suffix = concat(trim(cnvtstring(dbec_user_cnt)),trim(cnvtstring(dbec_cnt)))
         IF (dbec_type="EXP")
          ddr_tbl_list->logs[dbec_log_cnt].log_name = concat(dbec_dir,ddr_domain_data->
           exp_parfile_prefix,dbec_suffix,".log")
          IF ((dm2_sys_misc->cur_os="AXP"))
           dbec_operation = concat("$mcr ",dbec_oraloc,"exp ","v500/",dbec_pword,
            "@",dbec_connect," file=",dbec_dir,ddr_domain_data->exp_parfile_prefix,
            dbec_suffix,".dmp"," log=",ddr_tbl_list->logs[dbec_log_cnt].log_name," parfile=",
            dbec_dir,ddr_domain_data->exp_parfile_prefix,dbec_suffix,".par")
          ELSE
           dbec_operation = concat(dbec_oraloc,"exp ","v500/",dbec_pword,"@",
            dbec_connect," file=",dbec_dir,ddr_domain_data->exp_parfile_prefix,dbec_suffix,
            ".dmp"," log=",ddr_tbl_list->logs[dbec_log_cnt].log_name," parfile=",dbec_dir,
            ddr_domain_data->exp_parfile_prefix,dbec_suffix,".par")
          ENDIF
         ELSE
          ddr_tbl_list->logs[dbec_log_cnt].log_name = concat(dbec_dir,ddr_domain_data->
           imp_parfile_prefix,dbec_suffix)
          IF ((dm2_sys_misc->cur_os="AXP"))
           dbec_operation = concat("$mcr ",dbec_oraloc,"imp ","v500/",dbec_pword,
            "@",dbec_connect," file=",dbec_dir,ddr_domain_data->imp_parfile_prefix,
            dbec_suffix,".dmp"," log=",ddr_tbl_list->logs[dbec_log_cnt].log_name," parfile=",
            dbec_dir,ddr_domain_data->imp_parfile_prefix,dbec_suffix,".par")
          ELSE
           dbec_operation = concat(dbec_oraloc,"imp ","v500/",dbec_pword,"@",
            dbec_connect," file=",dbec_dir,ddr_domain_data->imp_parfile_prefix,dbec_suffix,
            ".dmp"," log=",ddr_tbl_list->logs[dbec_log_cnt].log_name," parfile=",dbec_dir,
            ddr_domain_data->imp_parfile_prefix,dbec_suffix,".par")
          ENDIF
         ENDIF
         col 0, dbec_operation, row + 1
       ENDFOR
     ENDFOR
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dbec_cmd_file_ret = dbec_file
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_build_parfile(dbp_dir,dbp_exp_prefix,dbp_imp_prefix)
   DECLARE dbp_par_file = vc WITH protect, noconstant("")
   DECLARE dbp_dat_file = vc WITH protect, noconstant("")
   DECLARE dbp_imp_par_file = vc WITH protect, noconstant("")
   DECLARE dbp_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dbp_user_cnt = i4 WITH protect, noconstant(0)
   DECLARE dbp_obj_name = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Building par files."
   CALL disp_msg(" ",dm_err->logfile,0)
   FOR (dbp_user_cnt = 1 TO ddr_tbl_list->owner_cnt)
     FOR (dbp_tbl_cnt = 1 TO ddr_tbl_list->owner[dbp_user_cnt].par_file_cnt)
       SET dbp_imp_par_file = build(dbp_dir,dbp_imp_prefix,dbp_user_cnt,dbp_tbl_cnt,".par")
       SET dbp_par_file = build(dbp_dir,dbp_exp_prefix,dbp_user_cnt,dbp_tbl_cnt,".par")
       SET dbp_dat_file = build(dbp_dir,dbp_exp_prefix,dbp_user_cnt,dbp_tbl_cnt,".dat")
       IF ((dm_err->debug_flag > 0))
        CALL echo(dbp_imp_par_file)
        CALL echo(dbp_par_file)
        CALL echo(dbp_dat_file)
       ENDIF
       SET dm_err->eproc = concat("Now creating the par file: <",dbp_par_file,">")
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       SELECT INTO value(dbp_par_file)
        FROM (dummyt d  WITH seq = ddr_tbl_list->owner[dbp_user_cnt].tbl_cnt)
        WHERE (ddr_tbl_list->owner[dbp_user_cnt].tbl[d.seq].par_group=dbp_tbl_cnt)
        HEAD REPORT
         col 0, "TABLES=(", char_cnt = 8
        DETAIL
         dbp_obj_name = concat(ddr_tbl_list->owner[dbp_user_cnt].owner_name,".",ddr_tbl_list->owner[
          dbp_user_cnt].tbl[d.seq].tbl_name), char_cnt = ((char_cnt+ size(dbp_obj_name,1))+ 3)
         IF (char_cnt >= 512)
          row + 1, char_cnt = (size(dbp_obj_name,1)+ 3)
         ENDIF
         col + 0, '"', dbp_obj_name,
         '"', ","
        FOOT REPORT
         col- (1), ")", row + 1,
         col 0, "direct=y", row + 1,
         col 0, "compress=n", row + 1
        WITH nocounter, format = variable, formfeed = none,
         maxrow = 1, maxcol = 512
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Now creating the dat file: <",dbp_dat_file,">")
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       SELECT INTO value(dbp_dat_file)
        FROM (dummyt d  WITH seq = ddr_tbl_list->owner[dbp_user_cnt].tbl_cnt)
        WHERE (ddr_tbl_list->owner[dbp_user_cnt].tbl[d.seq].par_group=dbp_tbl_cnt)
        DETAIL
         dbp_obj_name = concat(ddr_tbl_list->owner[dbp_user_cnt].owner_name,".",ddr_tbl_list->owner[
          dbp_user_cnt].tbl[d.seq].tbl_name), col 0, dbp_obj_name,
         row + 1
        WITH nocounter, format = variable, formfeed = none,
         maxrow = 1, maxcol = 512
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating import parfile: ",dbp_imp_par_file)
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       SELECT INTO value(dbp_imp_par_file)
        FROM (dummyt d  WITH seq = 1)
        DETAIL
         col 0, "buffer=100000", row + 1,
         col 0, "ignore=y ", row + 1,
         col 0, "commit=y", row + 1,
         col 0, "fromuser=", ddr_tbl_list->owner[dbp_user_cnt].owner_name,
         row + 1, col 0, "touser=",
         ddr_tbl_list->owner[dbp_user_cnt].owner_name, row + 1
        WITH nocounter, format = stream, maxrow = 1,
         maxcol = 512, formfeed = none
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_summary(ds_src_ind,ds_tgt_ind)
   DECLARE ds_line = vc WITH protect, noconstant(fillstring(129,"-"))
   DECLARE ds_rpt_file = vc WITH protect, noconstant("")
   DECLARE ds_str = vc WITH protect, noconstant("")
   DECLARE ds_cnt = i4 WITH protect, noconstant(0)
   DECLARE ds_tar_errors_ind = i2 WITH protect, noconstant(0)
   DECLARE ds_tar_errors_list = vc WITH protect, noconstant("NONE")
   DECLARE ds_reg_src_env = vc WITH protect, noconstant("")
   DECLARE ds_reg_tgt_env = vc WITH protect, noconstant("")
   IF (size(ddr_domain_data->src_env,1) > max_reg_env_len)
    SET ds_reg_src_env = substring(1,max_reg_env_len,ddr_domain_data->src_env)
   ELSE
    SET ds_reg_src_env = ddr_domain_data->src_env
   ENDIF
   IF (size(ddr_domain_data->tgt_env,1) > max_reg_env_len)
    SET ds_reg_tgt_env = substring(1,max_reg_env_len,ddr_domain_data->tgt_env)
   ELSE
    SET ds_reg_tgt_env = ddr_domain_data->tgt_env
   ENDIF
   IF (ddr_get_tar_errors(ds_src_ind,ds_tgt_ind,ds_tar_errors_ind,ds_tar_errors_list)=0)
    RETURN(0)
   ENDIF
   IF (get_unique_file("ddr_collect_data",".rpt")=0)
    RETURN(0)
   ELSE
    SET ds_rpt_file = dm_err->unique_fname
   ENDIF
   IF (ds_src_ind=1)
    SET ds_rpt_file = concat(ddr_domain_data->src_tmp_full_dir,ds_rpt_file)
   ELSE
    SET ds_rpt_file = concat(ddr_domain_data->tgt_tmp_full_dir,ds_rpt_file)
   ENDIF
   SET logical ds_rpt_file_logical ds_rpt_file
   SELECT INTO "ds_rpt_file_logical"
    HEAD REPORT
     col 0, "DATA COLLECTION SUMMARY", row + 1,
     ds_str = concat("Data collected from ",evaluate(ds_src_ind,1,ddr_domain_data->src_tmp_full_dir,
       ddr_domain_data->tgt_tmp_full_dir)), col 0, ds_str,
     row + 3, col 0, "Data",
     col 100, "Date Collected", row + 2,
     col 0, ds_line, row + 1
    DETAIL
     IF (ds_src_ind=1)
      IF (findstring("OCD_TOOLS",ds_tar_errors_list,1,0) > 0)
       ds_str = "**SOURCE OCD TOOLS:"
      ELSE
       ds_str = "SOURCE OCD TOOLS:"
      ENDIF
      col 0, ds_str, ds_str = concat(ddr_domain_data->src_env,"_ocds.sav"),
      col 40, ds_str, ds_str = evaluate(ddr_domain_data->src_ocd_tools_ts,0.0,"NOT COLLECTED",format(
        ddr_domain_data->src_ocd_tools_ts,";;Q")),
      col 100, ds_str, row + 1,
      ds_str = "SOURCE DICTIONARY:", col 0, ds_str,
      col 40, "dic.dat", ds_str = evaluate(ddr_domain_data->src_dict_ts,0.0,"NOT COLLECTED",format(
        ddr_domain_data->src_dict_ts,";;Q")),
      col 100, ds_str, row + 1
      IF (findstring("CCLDIR",ds_tar_errors_list,1,0) > 0)
       ds_str = "**SOURCE CCLDIR:"
      ELSE
       ds_str = "SOURCE CCLDIR:"
      ENDIF
      col 0, ds_str, ds_str = concat(ddr_domain_data->src_env,"_ccldir.sav"),
      col 40, ds_str, ds_str = evaluate(ddr_domain_data->src_ccldir_ts,0.0,"NOT COLLECTED",format(
        ddr_domain_data->src_ccldir_ts,";;Q")),
      col 100, ds_str, row + 1
      IF (findstring("CER_CONFIG",ds_tar_errors_list,1,0) > 0)
       ds_str = "**SOURCE CER_CONFIG:"
      ELSE
       ds_str = "SOURCE CER_CONFIG:"
      ENDIF
      col 0, ds_str, col 40,
      ddr_domain_data->src_env, "_config.sav", ds_str = evaluate(ddr_domain_data->src_config_ts,0.0,
       "NOT COLLECTED",format(ddr_domain_data->src_config_ts,";;Q")),
      col 100, ds_str, row + 1,
      ds_str = "SOURCE TDB:", col 0, ds_str,
      col 40, ddr_domain_data->src_env, "_tdb.msg",
      ds_str = evaluate(ddr_domain_data->src_tdb_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->
        src_tdb_ts,";;Q")), col 100, ds_str,
      row + 1, ds_str = "SOURCE SERVER DEFINITIONS LIST:", col 0,
      ds_str
      FOR (cur_node = 1 TO ddr_domain_data->src_nodes_cnt)
        col 40, ddr_domain_data->src_domain_name, "_",
        ddr_domain_data->src_nodes[cur_node].node_name, "_save.scp", ds_str = evaluate(
         ddr_domain_data->src_srv_def_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->src_srv_def_ts,
          ";;Q")),
        col 100, ds_str, row + 1,
        ds_str = ""
      ENDFOR
      IF ((ddr_domain_data->src_was_arch_ind=0))
       ds_str = "SOURCE SEC USER", col 0, ds_str,
       col 40, ddr_domain_data->src_env, "_sec_user.dat",
       ds_str = evaluate(ddr_domain_data->src_sec_user_ts,0.0,"NOT COLLECTED",format(ddr_domain_data
         ->src_sec_user_ts,";;Q")), col 100, ds_str,
       row + 1
      ENDIF
      ds_str = "SOURCE ENV REGISTRY:", col 0, ds_str,
      col 40, ds_reg_src_env, "_env.reg",
      ds_str = evaluate(ddr_domain_data->src_env_reg_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->
        src_env_reg_ts,";;Q")), col 100, ds_str,
      row + 1, ds_str = "SOURCE SYSTEM DEFINITION REGISTRY:", col 0,
      ds_str, col 40, ds_reg_src_env,
      "_sysdef.reg", ds_str = evaluate(ddr_domain_data->src_sysdef_reg_ts,0.0,"NOT COLLECTED",format(
        ddr_domain_data->src_sysdef_reg_ts,";;Q")), col 100,
      ds_str, row + 1
      IF (findstring("WAREHOUSE",ds_tar_errors_list,1,0) > 0)
       col 0, "**SOURCE WAREHOUSE BACKUP:"
      ELSE
       col 0, "SOURCE WAREHOUSE BACKUP:"
      ENDIF
      IF ((dm2_sys_misc->cur_os="AXP"))
       col 40, ddr_domain_data->src_env, "_",
       ddr_domain_data->src_wh, ".sav"
      ELSE
       col 40, ddr_domain_data->src_env, "_wh.sav"
      ENDIF
      ds_str = evaluate(ddr_domain_data->src_wh_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->
        src_wh_ts,";;Q")), col 100, ds_str,
      row + 1, ds_str = "SOURCE ADMIN ENV CSV:", col 0,
      ds_str, col 40, "dm2_",
      ddr_domain_data->src_db_env_name, "_env_hist_summary.txt", ds_str = evaluate(ddr_domain_data->
       src_adm_env_csv_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->src_adm_env_csv_ts,";;Q")),
      col 100, ds_str, row + 1
      IF ((ddr_domain_data->src_invalid_tbls_fnd=1))
       ds_str = "SOURCE NON-STANDARD TABLES", col 0, ds_str,
       ds_str = concat(ddr_domain_data->exp_parfile_prefix,"*.dmp"), col 40, ds_str,
       ds_str = evaluate(ddr_domain_data->src_invalid_tbls_ts,0.0,"NOT COLLECTED",format(
         ddr_domain_data->src_invalid_tbls_ts,";;Q")), col 100, ds_str,
       row + 1
      ENDIF
      IF ((ddr_domain_data->src_interrogator_fnd=1))
       ds_str = "SOURCE INRERROGATOR BACKUP DIRECTORY", col 0, ds_str,
       ds_str = concat(ddr_domain_data->src_env,"_dafsolr.sav"), col 40, ds_str,
       ds_str = evaluate(ddr_domain_data->src_interrogator_ts,0.0,"NOT COLLECTED",format(
         ddr_domain_data->src_interrogator_ts,";;Q")), col 100, ds_str,
       row + 1
      ENDIF
      col 0, "GENERAL SOURCE DATA", ds_str = evaluate(ddr_domain_data->src_data_ts,0.0,
       "NOT COLLECTED",format(ddr_domain_data->src_data_ts,";;Q")),
      col 100, ds_str, row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       ds_str = "Warehouse Directory:", col 2, ds_str,
       ds_str = ddr_domain_data->src_warehouse_dir, col 40, ds_str,
       row + 1, ds_str = "CCLDIR Directory:", col 2,
       ds_str, ds_str = ddr_domain_data->src_ccldir, col 40,
       ds_str, row + 1, ds_str = "CER_CONFIG Directory:",
       col 2, ds_str, ds_str = ddr_domain_data->src_cer_config_dir,
       col 40, ds_str, row + 1,
       ds_str = "CCLUSERDIR Directory:", col 2, ds_str,
       ds_str = ddr_domain_data->src_ccluserdir_dir, col 40, ds_str,
       row + 1, ds_str = "OCDTOOLS Directory:", col 2,
       ds_str, ds_str = ddr_domain_data->src_ocdtools_dir, col 40,
       ds_str, row + 1
      ENDIF
      ds_str = "CER_DATA Device:", col 2, ds_str,
      ds_str = ddr_domain_data->src_cer_data_dev, col 40, ds_str,
      row + 1, ds_str = "Warehouse:", col 2,
      ds_str, ds_str = ddr_domain_data->src_wh, col 40,
      ds_str, row + 1, ds_str = "Warehouse Device:",
      col 2, ds_str, ds_str = ddr_domain_data->src_wh_device,
      col 40, ds_str, row + 1,
      ds_str = "Rev Level:", col 2, ds_str,
      ds_str = ddr_domain_data->src_revision_level, col 40, ds_str,
      row + 1, ds_str = "System User:", col 2,
      ds_str, ds_str = ddr_domain_data->src_system, col 40,
      ds_str, row + 1, ds_str = "System Password:",
      col 2, ds_str, ds_str = ddr_domain_data->src_system_pwd,
      col 40, ds_str, row + 1,
      ds_str = "Priv User:", col 2, ds_str,
      ds_str = ddr_domain_data->src_priv, col 40, ds_str,
      row + 1, ds_str = "Priv Password:", col 2,
      ds_str, ds_str = ddr_domain_data->src_priv_pwd, col 40,
      ds_str, row + 1, ds_str = "ManageAccount User:",
      col 2, ds_str, ds_str = ddr_domain_data->src_mng,
      col 40, ds_str, row + 1,
      ds_str = "ManageAccount Password:", col 2, ds_str,
      ds_str = ddr_domain_data->src_mng_pwd, col 40, ds_str,
      row + 1, ds_str = "Sec User File Name:", col 2,
      ds_str, ds_str = ddr_domain_data->src_sec_user_name, col 40,
      ds_str, row + 1, ds_str = "Local User Name:",
      col 2, ds_str, ds_str = ddr_domain_data->src_local_user_name,
      col 40, ds_str, row + 1,
      ds_str = "Authorize Server ID:", col 2, ds_str,
      ds_str = build(ddr_domain_data->src_auth_server_id), col 40, ds_str,
      row + 1, ds_str = "Authorize Server Description:", col 2,
      ds_str, ds_str = ddr_domain_data->src_auth_server_desc, col 40,
      ds_str, row + 1, ds_str = "SCP Server ID:",
      col 2, ds_str, ds_str = build(ddr_domain_data->src_scp_server_id),
      col 40, ds_str, row + 1,
      ds_str = "SCP Server Description:", col 2, ds_str,
      ds_str = ddr_domain_data->src_scp_server_desc, col 40, ds_str,
      row + 1, ds_str = "TDB Server Master ID:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->src_tdb_server_master_id,0,"NOT FOUND",build(
        ddr_domain_data->src_tdb_server_master_id)), col 40,
      ds_str, row + 1, ds_str = "TDB Server Master Description:",
      col 2, ds_str, ds_str = evaluate(ddr_domain_data->src_tdb_server_master_id,0,"NOT FOUND",
       ddr_domain_data->src_tdb_server_master_desc),
      col 40, ds_str, row + 1,
      ds_str = "TDB Server Slave ID:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->src_tdb_server_slave_id,0,"NOT FOUND",build(ddr_domain_data
        ->src_tdb_server_slave_id)), col 40, ds_str,
      row + 1, ds_str = "TDB Server Slave Description:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->src_tdb_server_slave_id,0,"NOT FOUND",
       ddr_domain_data->src_tdb_server_slave_desc), col 40,
      ds_str, row + 1, ds_str = "Security Server Master ID:",
      col 2, ds_str, ds_str = evaluate(ddr_domain_data->src_sec_server_master_id,0,"NOT FOUND",build(
        ddr_domain_data->src_sec_server_master_id)),
      col 40, ds_str, row + 1,
      ds_str = "Security Server Master Description:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->src_sec_server_master_id,0,"NOT FOUND",ddr_domain_data->
       src_sec_server_master_desc), col 40, ds_str,
      row + 1, ds_str = "Security Slave Server ID:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->src_sec_server_slave_id,0,"NOT FOUND",build(
        ddr_domain_data->src_sec_server_slave_id)), col 40,
      ds_str, row + 1, ds_str = "Security Slave Server Description:",
      col 2, ds_str, ds_str = evaluate(ddr_domain_data->src_sec_server_slave_id,0,"NOT FOUND",
       ddr_domain_data->src_sec_server_slave_desc),
      col 40, ds_str, row + 1,
      ds_str = "WAS Security Architecture Enabled:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->src_was_arch_ind,1,"YES","NO"), col 40, ds_str,
      row + 1, ds_str = "Offline Dictionary Enabled:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->offline_dict_ind,1,"YES","NO"), col 40,
      ds_str, row + 1, ds_str = "Domain Name:",
      col 2, ds_str, col 40,
      ddr_domain_data->src_domain_name, row + 1, ds_str = "Application Node(s):",
      col 2, ds_str
      FOR (ds_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
        col 40, ddr_domain_data->src_nodes[ds_cnt].node_name, row + 1
      ENDFOR
      IF (ds_tar_errors_ind > 0)
       row + 1, ds_str = concat(
        "** TAR file(s) were generated with invalid user/group id warnings while gathering: ",
        ds_tar_errors_list), col 2,
       ds_str, row + 1
      ENDIF
      ds_str = "LDAP Enabled:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->src_ldap_ind,1,"YES","NO"), col 40, ds_str,
      row + 1
     ELSE
      ds_str = "TARGET DICTIONARY:", col 0, ds_str,
      col 40, "dic.dat", ds_str = evaluate(ddr_domain_data->tgt_dict_ts,0.0,"NOT COLLECTED",format(
        ddr_domain_data->tgt_dict_ts,";;Q")),
      col 100, ds_str, row + 1,
      ds_str = "TARGET TDB:", col 0, ds_str,
      col 40, ddr_domain_data->tgt_env, "_tdb.msg",
      ds_str = evaluate(ddr_domain_data->tgt_tdb_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->
        tgt_tdb_ts,";;Q")), col 100, ds_str,
      row + 1, ds_str = "TARGET SERVER DEFINITIONS LIST:", col 0,
      ds_str
      FOR (cur_node = 1 TO ddr_domain_data->tgt_nodes_cnt)
        col 40, ddr_domain_data->tgt_domain_name, "_",
        ddr_domain_data->tgt_nodes[cur_node].node_name, "_save.scp", ds_str = evaluate(
         ddr_domain_data->tgt_srv_def_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->tgt_srv_def_ts,
          ";;Q")),
        col 100, ds_str, row + 1
      ENDFOR
      IF ((ddr_domain_data->tgt_was_arch_ind=0))
       ds_str = "TARGET SEC USER", col 0, ds_str,
       col 40, ddr_domain_data->tgt_env, "_sec_user.dat",
       ds_str = evaluate(ddr_domain_data->tgt_sec_user_ts,0.0,"NOT COLLECTED",format(ddr_domain_data
         ->tgt_sec_user_ts,";;Q")), col 100, ds_str,
       row + 1
      ENDIF
      ds_str = "TARGET ENV REGISTRY:", col 0, ds_str,
      col 40, ds_reg_tgt_env, "_env.reg",
      ds_str = evaluate(ddr_domain_data->tgt_env_reg_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->
        tgt_env_reg_ts,";;Q")), col 100, ds_str,
      row + 1, ds_str = "TARGET SYSTEM DEFINITION REGISTRY:", col 0,
      ds_str, col 40, ds_reg_tgt_env,
      "_sysdef.reg", ds_str = evaluate(ddr_domain_data->tgt_sysdef_reg_ts,0.0,"NOT COLLECTED",format(
        ddr_domain_data->tgt_sysdef_reg_ts,";;Q")), col 100,
      ds_str, row + 1
      IF (findstring("WAREHOUSE",ds_tar_errors_list,1,0) > 0)
       col 0, "**TARGET WAREHOUSE BACKUP:"
      ELSE
       col 0, "TARGET WAREHOUSE BACKUP:"
      ENDIF
      IF ((dm2_sys_misc->cur_os="AXP"))
       col 40, ddr_domain_data->tgt_env, "_",
       ddr_domain_data->tgt_wh, ".sav"
      ELSE
       col 40, ddr_domain_data->tgt_env, "_wh.sav"
      ENDIF
      ds_str = evaluate(ddr_domain_data->tgt_wh_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->
        tgt_wh_ts,";;Q")), col 100, ds_str,
      row + 1
      IF ((dm2_sys_misc->cur_os != "AXP"))
       col 0, "TARGET USERS BACKUP:", col 40,
       ddr_domain_data->tgt_env, "_grp_users.dat", ds_str = evaluate(ddr_domain_data->tgt_users_ts,
        0.0,"NOT COLLECTED",format(ddr_domain_data->tgt_users_ts,";;Q")),
       col 100, ds_str, row + 1
      ENDIF
      col 0, "TARGET DBAS BACKUP:", col 40,
      ddr_domain_data->tgt_env, "_dbas.dat", ds_str = evaluate(ddr_domain_data->tgt_dbas_ts,0.0,
       "NOT COLLECTED",format(ddr_domain_data->tgt_dbas_ts,";;Q")),
      col 100, ds_str, row + 1,
      col 0, "TARGET SYSTEM REGISTRY BACKUP:", col 40,
      ds_reg_tgt_env, "_sys.reg", ds_str = evaluate(ddr_domain_data->tgt_sys_reg_ts,0.0,
       "NOT COLLECTED",format(ddr_domain_data->tgt_sys_reg_ts,";;Q")),
      col 100, ds_str, row + 1
      IF (findstring("CCLUSERDIR",ds_tar_errors_list,1,0) > 0)
       col 0, "**TARGET CCLUSERDIR BACKUP:"
      ELSE
       col 0, "TARGET CCLUSERDIR BACKUP:"
      ENDIF
      col 40, ddr_domain_data->tgt_env, "_ccluserdir.sav",
      ds_str = evaluate(ddr_domain_data->tgt_ccluserdir_ts,0.0,"NOT COLLECTED",format(ddr_domain_data
        ->tgt_ccluserdir_ts,";;Q")), col 100, ds_str,
      row + 1
      IF ((ddr_domain_data->tgt_invalid_tbls_fnd=1))
       ds_str = "TARGET NON-STANDARD TABLES", col 0, ds_str,
       ds_str = concat(ddr_domain_data->exp_parfile_prefix,"*.dmp"), col 40, ds_str,
       ds_str = evaluate(ddr_domain_data->tgt_invalid_tbls_ts,0.0,"NOT COLLECTED",format(
         ddr_domain_data->tgt_invalid_tbls_ts,";;Q")), col 100, ds_str,
       row + 1
      ENDIF
      IF ((ddr_domain_data->tgt_preserve_fnd=1))
       col 0, "TARGET PRESERVED TABLES:", col 40,
       "Preserved data found.", ds_str = evaluate(ddr_domain_data->tgt_preserve_ts,0.0,
        "NOT COLLECTED",format(ddr_domain_data->tgt_preserve_ts,";;Q")), col 100,
       ds_str, row + 1
      ENDIF
      IF ((ddr_domain_data->tgt_forms_fnd=1)
       AND (dm2_sys_misc->cur_os != "AXP")
       AND (ddr_domain_data->tgt_forms_ts != cnvtdatetime("22-JUL-1978")))
       ds_str = "TARGET CER_FORMS", col 0, ds_str,
       col 40, ddr_domain_data->tgt_env, "_frmque.sav",
       ds_str = evaluate(ddr_domain_data->tgt_forms_ts,0.0,"NOT COLLECTED",format(ddr_domain_data->
         tgt_forms_ts,";;Q")), col 100, ds_str,
       row + 1
      ENDIF
      col 0, "GENERAL TARGET DATA", ds_str = evaluate(ddr_domain_data->tgt_data_ts,0.0,
       "NOT COLLECTED",format(ddr_domain_data->tgt_data_ts,";;Q")),
      col 100, ds_str, row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       ds_str = "Warehouse Directory:", col 2, ds_str,
       ds_str = ddr_domain_data->tgt_warehouse_dir, col 40, ds_str,
       row + 1, ds_str = "CCLDIR Directory:", col 2,
       ds_str, ds_str = ddr_domain_data->tgt_ccldir, col 40,
       ds_str, row + 1, ds_str = "CER_CONFIG Directory:",
       col 2, ds_str, ds_str = ddr_domain_data->tgt_cer_config_dir,
       col 40, ds_str, row + 1,
       ds_str = "CCLUSERDIR Directory:", col 2, ds_str,
       ds_str = ddr_domain_data->tgt_ccluserdir_dir, col 40, ds_str,
       row + 1, ds_str = "OCDTOOLS Directory:", col 2,
       ds_str, ds_str = ddr_domain_data->tgt_ocdtools_dir, col 40,
       ds_str, row + 1
      ENDIF
      ds_str = "CER_DATA Device:", col 2, ds_str,
      ds_str = ddr_domain_data->tgt_cer_data_dev, col 40, ds_str,
      row + 1, ds_str = "Warehouse:", col 2,
      ds_str, ds_str = ddr_domain_data->tgt_wh, col 40,
      ds_str, row + 1, ds_str = "Warehouse Device:",
      col 2, ds_str, ds_str = ddr_domain_data->tgt_wh_device,
      col 40, ds_str, row + 1,
      ds_str = "Rev Level:", col 2, ds_str,
      ds_str = ddr_domain_data->tgt_revision_level, col 40, ds_str,
      row + 1, ds_str = "System User:", col 2,
      ds_str, ds_str = ddr_domain_data->tgt_system, col 40,
      ds_str, row + 1, ds_str = "System Password:",
      col 2, ds_str, ds_str = ddr_domain_data->tgt_system_pwd,
      col 40, ds_str, row + 1,
      ds_str = "Priv User:", col 2, ds_str,
      ds_str = ddr_domain_data->tgt_priv, col 40, ds_str,
      row + 1, ds_str = "Priv Password:", col 2,
      ds_str, ds_str = ddr_domain_data->tgt_priv_pwd, col 40,
      ds_str, row + 1, ds_str = "ManageAccount User:",
      col 2, ds_str, ds_str = ddr_domain_data->tgt_mng,
      col 40, ds_str, row + 1,
      ds_str = "ManageAccount Password:", col 2, ds_str,
      ds_str = ddr_domain_data->tgt_mng_pwd, col 40, ds_str,
      row + 1, ds_str = "Sec User File Name:", col 2,
      ds_str, ds_str = ddr_domain_data->tgt_sec_user_name, col 40,
      ds_str, row + 1, ds_str = "Local User Name:",
      col 2, ds_str, ds_str = ddr_domain_data->tgt_local_user_name,
      col 40, ds_str, row + 1,
      ds_str = "Authorize Server ID:", col 2, ds_str,
      ds_str = build(ddr_domain_data->tgt_auth_server_id), col 40, ds_str,
      row + 1, ds_str = "Authorize Server Description:", col 2,
      ds_str, ds_str = ddr_domain_data->tgt_auth_server_desc, col 40,
      ds_str, row + 1, ds_str = "SCP Server ID:",
      col 2, ds_str, ds_str = build(ddr_domain_data->tgt_scp_server_id),
      col 40, ds_str, row + 1,
      ds_str = "SCP Server Description:", col 2, ds_str,
      ds_str = ddr_domain_data->tgt_scp_server_desc, col 40, ds_str,
      row + 1, ds_str = "TDB Server Master ID:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->tgt_tdb_server_master_id,0,"NOT FOUND",build(
        ddr_domain_data->tgt_tdb_server_master_id)), col 40,
      ds_str, row + 1, ds_str = "TDB Server Master Description:",
      col 2, ds_str, ds_str = evaluate(ddr_domain_data->tgt_tdb_server_master_id,0,"NOT FOUND",
       ddr_domain_data->tgt_tdb_server_master_desc),
      col 40, ds_str, row + 1,
      ds_str = "TDB Server Slave ID:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->tgt_tdb_server_slave_id,0,"NOT FOUND",build(ddr_domain_data
        ->tgt_tdb_server_slave_id)), col 40, ds_str,
      row + 1, ds_str = "TDB Server Slave Description:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->tgt_tdb_server_slave_id,0,"NOT FOUND",
       ddr_domain_data->tgt_tdb_server_slave_desc), col 40,
      ds_str, row + 1, ds_str = "Security Server Master ID:",
      col 2, ds_str, ds_str = evaluate(ddr_domain_data->tgt_sec_server_master_id,0,"NOT FOUND",build(
        ddr_domain_data->tgt_sec_server_master_id)),
      col 40, ds_str, row + 1,
      ds_str = "Security Server Master Description:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->tgt_sec_server_master_id,0,"NOT FOUND",ddr_domain_data->
       tgt_sec_server_master_desc), col 40, ds_str,
      row + 1, ds_str = "Security Server Slave ID:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->tgt_sec_server_slave_id,0,"NOT FOUND",build(
        ddr_domain_data->tgt_sec_server_slave_id)), col 40,
      ds_str, row + 1, ds_str = "Security Server Slave Description:",
      col 2, ds_str, ds_str = evaluate(ddr_domain_data->tgt_sec_server_slave_id,0,"NOT FOUND",
       ddr_domain_data->tgt_sec_server_slave_desc),
      col 40, ds_str, row + 1,
      ds_str = "WAS Security Architecture Enabled:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->tgt_was_arch_ind,1,"YES","NO"), col 40, ds_str,
      row + 1, ds_str = "Target Passwords Preserved Count:", col 2,
      ds_str, ds_str = evaluate(ddr_domain_data->tgt_preserve_pwds_cnt,0,"0",build(ddr_domain_data->
        tgt_preserve_pwds_cnt)), col 40,
      ds_str, row + 1, ds_str = "Offline Dictionary Enabled:",
      col 2, ds_str, ds_str = evaluate(ddr_domain_data->offline_dict_ind,1,"YES","NO"),
      col 40, ds_str, row + 1,
      ds_str = "Domain Name:", col 2, ds_str,
      col 40, ddr_domain_data->tgt_domain_name, row + 1,
      ds_str = "Application Node Type:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->tgt_node_flag,1,"Single Target Node",2,"Primary Target Node",
       "Secondary Target Node"), col 40, ds_str,
      row + 1, ds_str = "Application Node(s):", col 2,
      ds_str
      FOR (ds_cnt = 1 TO ddr_domain_data->tgt_nodes_cnt)
        col 40, ddr_domain_data->tgt_nodes[ds_cnt].node_name, row + 1
      ENDFOR
      IF (ds_tar_errors_ind > 0)
       row + 1, ds_str = concat(
        "** TAR file(s) were generated with invalid user/group id warnings while gathering: ",
        ds_tar_errors_list), col 2,
       ds_str, row + 1
      ENDIF
      ds_str = "LDAP Enabled:", col 2, ds_str,
      ds_str = evaluate(ddr_domain_data->tgt_ldap_ind,1,"YES","NO"), col 40, ds_str,
      row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dm_err->eproc = concat("Skipping display of Data Collection Summary Report (",ds_rpt_file,")"
     )
    CALL disp_msg("",dm_err->logfile,0)
    IF ((drer_email_list->email_cnt > 0))
     SET drer_email_det->msgtype = "ACTIONREQ"
     SET drer_email_det->status = "REPORT"
     SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
     SET drer_email_det->step = "DATA COLLECTION SUMMARY REPORT"
     SET drer_email_det->email_level = 1
     SET drer_email_det->logfile = dm_err->logfile
     SET drer_email_det->err_ind = dm_err->err_ind
     SET drer_email_det->eproc = dm_err->eproc
     SET drer_email_det->emsg = dm_err->emsg
     SET drer_email_det->user_action = dm_err->user_action
     SET drer_email_det->attachment = ds_rpt_file
     CALL drer_add_body_text(concat("DATA COLLECTION SUMMARY REPORT was generated at ",format(
        drer_email_det->status_dt_tm,";;q")),1)
     CALL drer_add_body_text(concat("User Action : Please review the report to ensure ",
       "all the data has been collected."),0)
     CALL drer_add_body_text(concat("Report file name : ",trim(ds_rpt_file,3)),0)
     IF (drer_compose_email(null)=1)
      CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
       email_level)
     ENDIF
     CALL drer_reset_pre_err(null)
    ENDIF
   ELSE
    FREE DEFINE rtl2
    DEFINE rtl2 "ds_rpt_file_logical"
    SELECT INTO mine
     t.line
     FROM rtl2t t
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
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_env_reg(dger_src_ind,dger_tgt_ind,dger_type,dger_current_ind)
   DECLARE dger_cmd_file = vc WITH protect, noconstant("")
   DECLARE dger_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dger_cmd = vc WITH protect, noconstant("")
   DECLARE dger_cer_reg = vc WITH protect, noconstant(trim(logical("cer_reg")))
   DECLARE dger_env = vc WITH protect, noconstant(evaluate(dger_src_ind,1,ddr_domain_data->src_env,
     ddr_domain_data->tgt_env))
   DECLARE dger_suffix = vc WITH protect, noconstant(";*")
   DECLARE dger_file_full = vc WITH protect, noconstant("")
   DECLARE dger_file_trim = vc WITH protect, noconstant("")
   DECLARE dger_reg_file = vc WITH protect, noconstant("")
   DECLARE dger_str = vc WITH protect, noconstant("")
   DECLARE dger_domain = vc WITH protect, noconstant("")
   DECLARE dger_ret_val = vc WITH protect, noconstant("")
   DECLARE dger_reg_src_env = vc WITH protect, noconstant("")
   DECLARE dger_reg_tgt_env = vc WITH protect, noconstant("")
   DECLARE dger_reg_cur_env = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Export registry information."
   CALL disp_msg("",dm_err->logfile,0)
   IF (size(ddr_domain_data->src_env,1) > max_reg_env_len)
    SET dger_reg_src_env = substring(1,max_reg_env_len,ddr_domain_data->src_env)
   ELSE
    SET dger_reg_src_env = ddr_domain_data->src_env
   ENDIF
   IF (size(ddr_domain_data->tgt_env,1) > max_reg_env_len)
    SET dger_reg_tgt_env = substring(1,max_reg_env_len,ddr_domain_data->tgt_env)
   ELSE
    SET dger_reg_tgt_env = ddr_domain_data->tgt_env
   ENDIF
   IF (dger_current_ind=0)
    SET dger_file_trim = concat(evaluate(dger_src_ind,1,dger_reg_src_env,dger_reg_tgt_env),evaluate(
      dger_type,"DEFINITION","_env","SYSTEM","_sys",
      "SYSTEM_DEFINITIONS","_sysdef"))
    SET dger_file_full = concat(evaluate(dger_src_ind,1,ddr_domain_data->src_tmp_full_dir,
      ddr_domain_data->tgt_tmp_full_dir),dger_file_trim,".reg")
   ELSE
    IF (ddr_get_env_logical(dger_env)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Get domain name."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET dger_str = concat("\\environment\\",dger_env," Domain")
    IF (ddr_lreg_oper("GET",dger_str,dger_ret_val)=0)
     RETURN(0)
    ENDIF
    SET dger_domain = dger_ret_val
    IF (dger_ret_val="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve domain name property for ",dger_env)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (size(dger_env,1) > max_reg_env_len)
     SET dger_reg_cur_env = substring(1,max_reg_env_len,dger_env)
    ELSE
     SET dger_reg_cur_env = dger_env
    ENDIF
    SET dger_file_trim = concat(dger_reg_cur_env,evaluate(dger_type,"DEFINITION","_c_env","SYSTEM",
      "_c_sys",
      "SYSTEM_DEFINITIONS","_c_sysdef","NODE_DOMAIN","_c_node_dom"))
    SET dger_file_full = concat(evaluate(dm2_sys_misc->cur_os,"AXP",trim(logical("ccluserdir")),
      concat(trim(logical("ccluserdir")),"/")),dger_file_trim,".reg")
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET dger_cer_reg = concat(dger_cer_reg,"/")
   ENDIF
   SET dger_reg_file = concat(dger_cer_reg,dger_file_trim,".reg ")
   SET dm_err->eproc = concat("Remove:",dger_reg_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dger_reg_file) > 0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(dm2_sys_misc
       ->cur_os,"AXP",concat(dger_reg_file,dger_suffix),dger_reg_file)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Remove:",dger_file_full)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dger_file_full) > 0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(dm2_sys_misc
       ->cur_os,"AXP",concat(dger_file_full,dger_suffix),dger_file_full)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (get_unique_file("get_env_reg",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dger_cmd_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to export REGISTRY info:",dger_cmd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dger_cmd_file)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$mcr cer_exe:lregview"), row + 1
     ELSE
      CALL print("$cer_exe/lregview <<!"), row + 1
     ENDIF
     IF (dger_type="DEFINITION")
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("copy \environment\",dger_env,"\definitions \\",dger_file_trim," -sub")),
       row + 1
      ELSE
       CALL print(concat("copy \\\system\\environment\\",dger_env,"\\definitions \\\",dger_file_trim,
        " -sub")), row + 1
      ENDIF
     ELSEIF (dger_type="SYSTEM_DEFINITIONS")
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("copy \definitions\vmsalpha\environment \\",dger_file_trim," -sub")), row +
       1
      ELSEIF ((dm2_sys_misc->cur_os="HPX"))
       CALL print(concat("copy \\\system\\definitions\\hpuxia64\\environment \\\",dger_file_trim,
        " -sub")), row + 1
      ELSEIF ((dm2_sys_misc->cur_os="AIX"))
       CALL print(concat("copy \\\system\\definitions\\aixrs6000\\environment \\\",dger_file_trim,
        " -sub")), row + 1
      ELSEIF ((dm2_sys_misc->cur_os="LNX"))
       CALL print(concat("copy \\\system\\definitions\\linuxx86-64\\environment \\\",dger_file_trim,
        " -sub")), row + 1
      ENDIF
     ELSEIF (dger_type="NODE_DOMAIN")
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("copy \node\",trim(curnode),"\domain\",trim(dger_domain)," \\",
        dger_file_trim," -sub")), row + 1
      ELSE
       CALL print(concat("copy \\\system\\node\\",trim(curnode),"\\domain\\",trim(dger_domain)," \\\",
        dger_file_trim," -sub")), row + 1
      ENDIF
     ELSE
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("copy \\system \\",dger_file_trim," -sub")), row + 1
      ELSE
       CALL print(concat("copy \\\system \\\",dger_file_trim," -sub")), row + 1
      ENDIF
     ENDIF
     CALL print("exit")
     IF ((dm2_sys_misc->cur_os != "AXP"))
      row + 1,
      CALL print("!"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Export REGISTRY info to ",dger_reg_file)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dger_cmd = concat("@",dger_cmd_file)
   ELSE
    SET dger_cmd = concat(". $CCLUSERDIR/",dger_cmd_file)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dger_cmd)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (((findstring("bad syntax",dm_err->errtext,1,1) > 0) OR (findstring("key not found",dm_err->
    errtext,1,1) > 0)) )
    SET dm_err->emsg = concat("Error exporting REGISTRY:",dger_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Copy REGISTRY info to ",dger_file_full)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dger_cmd = concat(evaluate(dm2_sys_misc->cur_os,"AXP","backup/new ","cp -p "),dger_cer_reg,
    dger_file_trim,".reg ",dger_file_full)
   IF (dm2_push_dcl(dger_cmd)=0)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dger_file_full)=0)
    SET dm_err->emsg = concat("Error copying Registry keys. Registry copy does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dger_current_ind=0)
    IF (ddr_get_file_date(dger_file_full,dger_file_date)=0)
     RETURN(0)
    ENDIF
    IF (dger_type="DEFINITION")
     IF (dger_src_ind=1)
      SET ddr_domain_data->src_env_reg_ts = dger_file_date
      SET ddr_domain_data->src_env_reg_fnd = 1
     ELSE
      SET ddr_domain_data->tgt_env_reg_ts = dger_file_date
      SET ddr_domain_data->tgt_env_reg_fnd = 1
     ENDIF
    ELSEIF (dger_type="SYSTEM_DEFINITIONS")
     IF (dger_src_ind=1)
      SET ddr_domain_data->src_sysdef_reg_ts = dger_file_date
      SET ddr_domain_data->src_sysdef_reg_fnd = 1
     ELSE
      SET ddr_domain_data->tgt_sysdef_reg_ts = dger_file_date
      SET ddr_domain_data->tgt_sysdef_reg_fnd = 1
     ENDIF
    ELSE
     SET ddr_domain_data->tgt_sys_reg_ts = dger_file_date
     SET ddr_domain_data->tgt_sys_reg_fnd = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_invalid_tbls(dgit_src_ind,dgit_tgt_ind,dgit_prompt_only)
   DECLARE dgit_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgit_dmpfile = vc WITH protect, noconstant("")
   DECLARE dgit_cmd_file = vc WITH protect, noconstant("")
   DECLARE dgit_cmd = vc WITH protect, noconstant("")
   DECLARE dgit_dir = vc WITH protect, noconstant("")
   DECLARE dgit_user_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgit_ndx = i4 WITH protect, noconstant(0)
   DECLARE dgit_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgit_log_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgit_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dgit_rpt_errors = i4 WITH protect, noconstant(0)
   DECLARE dgit_accept = vc WITH proteect, noconstant("")
   DECLARE dgit_str = vc WITH protect, noconstant("")
   DECLARE dgit_rpt_file = vc WITH protect, noconstant("")
   DECLARE dgit_confirm_ret = i2 WITH protect, noconstant(0)
   DECLARE dgit_continue = i2 WITH protect, noconstant(1)
   DECLARE dgit_mng_cust_usrs_ind = i2 WITH protect, noconstant(1)
   IF (dgit_prompt_only=0)
    SET dgit_dir = evaluate(dgit_src_ind,1,ddr_domain_data->src_tmp_full_dir,ddr_domain_data->
     tgt_tmp_full_dir)
    SET dgit_dmpfile = evaluate(dm2_sys_misc->cur_os,"AXP",concat(dgit_dir,ddr_domain_data->
      exp_parfile_prefix,"*.dmp;*"),concat(dgit_dir,ddr_domain_data->exp_parfile_prefix,"*.dmp"))
    SET dm_err->eproc = concat("Remove:",dgit_dmpfile)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os != "LNX"))
     IF (dm2_findfile(concat(dgit_dmpfile)) > 0)
      IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgit_dmpfile))=0)
       RETURN(0)
      ENDIF
     ENDIF
    ELSE
     IF (ddr_lnx_findfile(concat(dgit_dmpfile)) > 0)
      IF (dm2_push_dcl(concat("rm ",dgit_dmpfile))=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
    SET dgit_dir = evaluate(dgit_src_ind,1,ddr_domain_data->src_tmp_full_dir,ddr_domain_data->
     tgt_tmp_full_dir)
    SET dgit_dmpfile = evaluate(dm2_sys_misc->cur_os,"AXP",concat(dgit_dir,ddr_domain_data->
      exp_parfile_prefix,"*.par;*"),concat(dgit_dir,ddr_domain_data->exp_parfile_prefix,"*.par"))
    SET dm_err->eproc = concat("Remove:",dgit_dmpfile)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os != "LNX"))
     IF (dm2_findfile(concat(dgit_dmpfile)) > 0)
      IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgit_dmpfile))=0)
       RETURN(0)
      ENDIF
     ENDIF
    ELSE
     IF (ddr_lnx_findfile(concat(dgit_dmpfile)) > 0)
      IF (dm2_push_dcl(concat("rm ",dgit_dmpfile))=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
    SET dgit_dir = evaluate(dgit_src_ind,1,ddr_domain_data->src_tmp_full_dir,ddr_domain_data->
     tgt_tmp_full_dir)
    SET dgit_dmpfile = evaluate(dm2_sys_misc->cur_os,"AXP",concat(dgit_dir,ddr_domain_data->
      exp_parfile_prefix,"*.dat;*"),concat(dgit_dir,ddr_domain_data->exp_parfile_prefix,"*.dat"))
    SET dm_err->eproc = concat("Remove:",dgit_dmpfile)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os != "LNX"))
     IF (dm2_findfile(concat(dgit_dmpfile)) > 0)
      IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgit_dmpfile))=0)
       RETURN(0)
      ENDIF
     ENDIF
    ELSE
     IF (ddr_lnx_findfile(concat(dgit_dmpfile)) > 0)
      IF (dm2_push_dcl(concat("rm ",dgit_dmpfile))=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (dgit_prompt_only=1
    AND validate(drrr_responsefile_in_use,0)=1)
    SET drr_cleanup_drop_list->list_loaded_ind = 0
    EXECUTE dm2_invalid_tables_rpt
    IF ((dm_err->err_ind > 0))
     RETURN(0)
    ENDIF
    SET ddr_domain_data->get_invalid_tables = 0
    RETURN(1)
   ENDIF
   IF (dgit_prompt_only=1)
    WHILE (dgit_continue=1)
      SET drr_cleanup_drop_list->list_loaded_ind = 0
      EXECUTE dm2_invalid_tables_rpt
      IF ((dm_err->err_ind > 0))
       RETURN(0)
      ENDIF
      IF ((drr_cleanup_drop_list->cnt > 0))
       IF (drr_confirm_invalid_tables(dgit_mng_cust_usrs_ind,dgit_confirm_ret)=0)
        RETURN(0)
       ENDIF
       CASE (dgit_confirm_ret)
        OF 0:
         SET dm_err->err_ind = 1
         SET dm_err->emsg = "User Chose to Quit from Invalid Tables Report Confirmation Prompt"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        OF 1:
         SET dgit_continue = 0
        OF 2:
         EXECUTE dm2_manage_custom_users
         IF ((dm_err->err_ind > 0))
          RETURN(0)
         ENDIF
       ENDCASE
      ELSE
       SET dgit_continue = 0
      ENDIF
    ENDWHILE
    IF ((drr_cleanup_drop_list->list_loaded_ind=0))
     IF (drr_get_invalid_tables_list(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((drr_cleanup_drop_list->cnt > 0)
     AND (ddr_domain_data->standalone_expimp_mode=0))
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,5,131)
     CALL text(3,4,"Would you like to have the invalid tables exported for you? (Y)es or (N)o :")
     CALL accept(3,84,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     CALL clear(1,1)
     SET message = nowindow
     IF (curaccept="N")
      SET ddr_domain_data->get_invalid_tables = 0
      RETURN(1)
     ELSE
      SET ddr_domain_data->get_invalid_tables = 1
      RETURN(1)
     ENDIF
    ELSEIF ((drr_cleanup_drop_list->cnt > 0))
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,5,131)
     CALL text(3,4,concat("If you wish to take an export of any of the invalid tables, ",
       "exports should be taken at this time."))
     CALL text(4,4,"Press enter to continue.")
     CALL accept(4,30,"p;cu"," "
      WHERE curaccept IN (" "))
     CALL clear(1,1)
     SET message = nowindow
     SET ddr_domain_data->get_invalid_tables = 0
     RETURN(1)
    ELSE
     SET ddr_domain_data->get_invalid_tables = 0
     RETURN(1)
    ENDIF
   ENDIF
   SET dm_err->eproc = "User elected to export invalid tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   FOR (dgit_cnt = 1 TO drr_cleanup_drop_list->cnt)
     IF ((ddr_tbl_list->owner_cnt > 0))
      IF (locateval(dgit_ndx,1,size(ddr_tbl_list->owner,5),drr_cleanup_drop_list->qual[dgit_cnt].
       owner,ddr_tbl_list->owner[dgit_ndx].owner_name) > 0)
       SET dgit_user_cnt = dgit_ndx
      ELSE
       SET ddr_tbl_list->owner_cnt = (ddr_tbl_list->owner_cnt+ 1)
       SET dgit_user_cnt = ddr_tbl_list->owner_cnt
       SET stat = alterlist(ddr_tbl_list->owner,ddr_tbl_list->owner_cnt)
       SET ddr_tbl_list->owner[ddr_tbl_list->owner_cnt].owner_name = drr_cleanup_drop_list->qual[
       dgit_cnt].owner
      ENDIF
     ELSE
      SET ddr_tbl_list->owner_cnt = (ddr_tbl_list->owner_cnt+ 1)
      SET dgit_user_cnt = ddr_tbl_list->owner_cnt
      SET stat = alterlist(ddr_tbl_list->owner,ddr_tbl_list->owner_cnt)
      SET ddr_tbl_list->owner[ddr_tbl_list->owner_cnt].owner_name = drr_cleanup_drop_list->qual[
      dgit_cnt].owner
     ENDIF
     SET ddr_tbl_list->owner[dgit_user_cnt].tbl_cnt = (ddr_tbl_list->owner[dgit_user_cnt].tbl_cnt+ 1)
     SET stat = alterlist(ddr_tbl_list->owner[dgit_user_cnt].tbl,ddr_tbl_list->owner[dgit_user_cnt].
      tbl_cnt)
     IF (mod(ddr_tbl_list->owner[dgit_user_cnt].tbl_cnt,400)=1)
      SET ddr_tbl_list->owner[dgit_user_cnt].par_file_cnt = (ddr_tbl_list->owner[dgit_user_cnt].
      par_file_cnt+ 1)
     ENDIF
     SET ddr_tbl_list->owner[dgit_user_cnt].tbl[ddr_tbl_list->owner[dgit_user_cnt].tbl_cnt].tbl_name
      = drr_cleanup_drop_list->qual[dgit_cnt].table_name
     SET ddr_tbl_list->owner[dgit_user_cnt].tbl[ddr_tbl_list->owner[dgit_user_cnt].tbl_cnt].par_group
      = ddr_tbl_list->owner[dgit_user_cnt].par_file_cnt
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_tbl_list)
   ENDIF
   IF (ddr_build_parfile(dgit_dir,ddr_domain_data->exp_parfile_prefix,ddr_domain_data->
    imp_parfile_prefix)=0)
    RETURN(0)
   ENDIF
   IF (ddr_build_expimp_cmds(dgit_src_ind,dgit_tgt_ind,dgit_dir,"IMP",dgit_cmd_file)=0)
    RETURN(0)
   ENDIF
   IF (ddr_build_expimp_cmds(dgit_src_ind,dgit_tgt_ind,dgit_dir,"EXP",dgit_cmd_file)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Executing export file:",dgit_cmd_file)
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgit_cmd = concat("@",dgit_cmd_file)
   ELSE
    SET dgit_cmd = concat(". ",dgit_cmd_file)
   ENDIF
   IF (dm2_push_dcl(dgit_cmd)=0)
    RETURN(0)
   ENDIF
   FOR (dgit_log_cnt = 1 TO size(ddr_tbl_list->logs,5))
     SET dm_err->eproc = concat("Checking logfile for errors:",ddr_tbl_list->logs[dgit_log_cnt].
      log_name)
     CALL disp_msg("",dm_err->logfile,0)
     IF (drr_check_log_for_errors(1.0,ddr_tbl_list->logs[dgit_log_cnt].log_name,0,dgit_error_ind)=0)
      RETURN(0)
     ENDIF
     IF (dgit_error_ind > 0)
      SET dgit_rpt_errors = 1
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(drr_errors_encountered)
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_tbl_list)
    CALL echorecord(drr_errors_encountered)
   ENDIF
   IF (dgit_rpt_errors=1)
    SET dm_err->eproc = "Report errors to User"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    WHILE ( NOT (dgit_accept IN ("C", "Q")))
      SET dm_err->eproc = "Report errors to User"
      SET dgit_accept = ""
      SET message = window
      SET width = 132
      CALL clear(1,1)
      CALL box(1,1,10,131)
      CALL text(3,4,"Errors occurred during Export:")
      CALL text(4,4,'  Enter "V" to view errors. ')
      CALL text(5,4,'  Enter "C" to continue and ignore errors. ')
      CALL text(6,4,'  Enter "Q" to quit and exit process. ')
      CALL accept(3,37,"A;cu"," "
       WHERE curaccept IN ("C", "Q", "V"))
      SET dgit_accept = curaccept
      CALL clear(1,1)
      SET message = nowindow
      IF (dgit_accept="Q")
       SET dm_err->emsg = "User elected to Quit after encountering Export errors."
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dgit_accept="V")
       IF (get_unique_file("ddr_exp_err",".rpt")=0)
        RETURN(0)
       ELSE
        SET dgit_rpt_file = concat("ccluserdir:",dm_err->unique_fname)
       ENDIF
       SET logical dgit_rpt_file_logical dgit_rpt_file
       SELECT INTO "dgit_rpt_file_logical"
        HEAD REPORT
         col 0, "EXPORT ERROR REPORT", row + 3,
         dgit_str = concat("If error(s) are ignorable, add error(s) to ",
          "dm2_ignorable_errors.dat file located in ccluserdir."), col 0, dgit_str,
         row + 2, col 0, "Example: EXP-12345 would be added as 1 line in dm2_ignorable_errors.dat",
         row + 1
        DETAIL
         FOR (dgit_log_cnt = 1 TO drr_errors_encountered->cmd_cnt)
           row + 2, col 0, "Errors recorded in ",
           drr_errors_encountered->qual[dgit_log_cnt].logfile_name, row + 2, col 0,
           "_____________________________________________________________________________", row + 1
           FOR (dgit_cnt = 1 TO drr_errors_encountered->qual[dgit_log_cnt].error_cnt)
             dgit_str = concat(drr_errors_encountered->qual[dgit_log_cnt].qual[dgit_cnt].error,":",
              drr_errors_encountered->qual[dgit_log_cnt].qual[dgit_cnt].error_desc), col 0, dgit_str,
             row + 1
           ENDFOR
         ENDFOR
        WITH nocounter, formfeed = none, maxcol = 5000,
         format = variable
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       FREE DEFINE rtl2
       DEFINE rtl2 "dgit_rpt_file_logical"
       SELECT INTO mine
        t.line
        FROM rtl2t t
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
      ENDIF
    ENDWHILE
    CALL clear(1,1)
    SET message = nowindow
   ENDIF
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF (dm2_findfile(dgit_dmpfile)=0)
     SET dm_err->emsg = concat("Error exporting invalid tables. Dumpfile does not exist:",
      dgit_dmpfile)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    IF (ddr_lnx_findfile(dgit_dmpfile)=0)
     SET dm_err->emsg = concat("Error exporting invalid tables. Dumpfile does not exist:",
      dgit_dmpfile)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dgit_dmpfile = concat(dgit_dir,ddr_domain_data->exp_parfile_prefix,"*.dmp")
   SET dgit_file_date = 0.0
   IF (ddr_get_file_date(dgit_dmpfile,dgit_file_date)=0)
    RETURN(0)
   ENDIF
   IF (dgit_src_ind=1)
    SET ddr_domain_data->src_invalid_tbls_ts = dgit_file_date
    SET ddr_domain_data->src_invalid_tbls_fnd = 1
   ELSE
    SET ddr_domain_data->tgt_invalid_tbls_ts = dgit_file_date
    SET ddr_domain_data->tgt_invalid_tbls_fnd = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_sec_user(dgsu_src_ind,dgsu_tgt_ind,dgsu_is_primary)
   DECLARE dgsu_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgsu_user_file = vc WITH protect, noconstant(concat(evaluate(dgsu_src_ind,1,
      ddr_domain_data->src_tmp_full_dir,ddr_domain_data->tgt_tmp_full_dir),evaluate(dgsu_src_ind,1,
      ddr_domain_data->src_env,ddr_domain_data->tgt_env),"_sec_user.dat"))
   DECLARE dgsu_str = vc WITH protect, noconstant("")
   DECLARE dgsu_useri_file = vc WITH protect, noconstant("")
   DECLARE dgsu_cer_config = vc WITH protect, noconstant("")
   IF (dgsu_is_primary=1)
    SET dgsu_user_file = concat(ddr_domain_data->tgt_tmp_full_dir,"primary_sec_user.dat")
   ENDIF
   SET dgsu_useri_file = replace(dgsu_user_file,".dat",".idx")
   SET dm_err->eproc = "Copy cer_config sec user file to temporary directory."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(dgsu_user_file) > 0)
    SET dm_err->eproc = concat("Remove:",dgsu_user_file)
    CALL disp_msg("",dm_err->logfile,0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgsu_user_file))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (dm2_findfile(dgsu_useri_file) > 0)
     SET dm_err->eproc = concat("Remove:",dgsu_useri_file)
     CALL disp_msg("",dm_err->logfile,0)
     IF (dm2_push_dcl(concat("rm ",dgsu_useri_file))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (ddr_get_from_dir(dgsu_src_ind,"cer_config",dgsu_cer_config)=0)
    RETURN(0)
   ENDIF
   IF (dgsu_src_ind=1)
    SET dgsu_str = "SOURCE"
   ELSE
    IF (dgsu_is_primary=1)
     SET dgsu_str = "PRIMARY TARGET"
    ELSE
     SET dgsu_str = "TARGET"
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Obtain ",dgsu_str," SEC USER copy.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","backup/ignore=interlock ","cp")," ",
     dgsu_cer_config,evaluate(dgsu_src_ind,1,ddr_domain_data->src_sec_user_name,ddr_domain_data->
      tgt_sec_user_name),".dat ",
     dgsu_user_file))=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","copy ","cp")," ",dgsu_cer_config,
      evaluate(dgsu_src_ind,1,ddr_domain_data->src_sec_user_name,ddr_domain_data->tgt_sec_user_name),
      ".idx ",
      dgsu_useri_file))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_findfile(dgsu_user_file)=0)
    SET dm_err->emsg = concat("Error copying ",dgsu_str,
     " sec user. The sec user file does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (dm2_findfile(dgsu_useri_file)=0)
     SET dm_err->emsg = concat("Error copying ",dgsu_str,
      " sec user. The sec user index file does not exist.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_get_file_date(dgsu_user_file,dgsu_file_date)=0)
    RETURN(0)
   ENDIF
   IF (dgsu_src_ind=1)
    SET ddr_domain_data->src_sec_user_ts = dgsu_file_date
    SET ddr_domain_data->src_sec_user_fnd = 1
   ELSE
    SET ddr_domain_data->tgt_sec_user_ts = dgsu_file_date
    SET ddr_domain_data->tgt_sec_user_fnd = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_nodes(dgn_src_ind,dgn_tgt_ind)
   DECLARE dgn_file = vc WITH protect, noconstant("")
   DECLARE dgn_cmd = vc WITH protect, noconstant("")
   DECLARE dgn_found_start = i2 WITH protect, noconstant(0)
   DECLARE dgn_errfile = vc WITH protect, noconstant("")
   DECLARE dgn_found_curnode = i2 WITH protect, noconstant(0)
   DECLARE dgn_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgn_ndx = i4 WITH protect, noconstant(0)
   IF (get_unique_file("get_nodes",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dgn_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to obtain listing of nodes from SCP:",dgn_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dgn_file)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$mcr cer_exe:scpview "), row + 1,
      CALL print("$DECK"),
      row + 1
     ELSE
      IF (dgn_src_ind=1)
       CALL print(concat("src_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1
      ELSE
       CALL print(concat("tgt_mng_pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1
      ENDIF
      CALL print("$cer_exe/scpview  <<!"), row + 1
     ENDIF
     IF (dgn_src_ind=1)
      CALL print(ddr_domain_data->src_mng), row + 1,
      CALL print(ddr_domain_data->src_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->src_mng_pwd), row + 1
      ELSE
       CALL print("$src_mng_pwd"), row + 1
      ENDIF
     ELSE
      CALL print(ddr_domain_data->tgt_mng), row + 1,
      CALL print(ddr_domain_data->tgt_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->tgt_mng_pwd), row + 1
      ELSE
       CALL print("$tgt_mng_pwd"), row + 1
      ENDIF
     ENDIF
     CALL print("nodes"), row + 1,
     CALL print("exit"),
     row + 1
     IF ((dm2_sys_misc->cur_os != "AXP"))
      CALL print("!"), row + 1
     ELSE
      CALL print("$EOD"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain node listing from SCP."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgn_cmd = concat("@",dgn_file)
   ELSE
    SET dgn_cmd = concat(". $CCLUSERDIR/",dgn_file)
   ENDIF
   IF (dm2_push_dcl(dgn_cmd)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (((findstring("bad command",dm_err->errtext,1,1) > 0) OR (findstring(
    "node not offering services",dm_err->errtext,1,1) > 0)) )
    SET dm_err->emsg = concat("Error exporting server definitions:",dgn_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgn_errfile = dm_err->errfile
   SET dm_err->eproc = concat("Parse node listing from:",dgn_errfile)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dgn_data_file dgn_errfile
   FREE DEFINE rtl
   DEFINE rtl "dgn_data_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     IF ((dm_err->debug_flag > 0))
      CALL echo(t.line)
     ENDIF
     IF (dgn_found_start=1)
      IF (dgn_src_ind=1)
       ddr_domain_data->src_nodes_cnt = (ddr_domain_data->src_nodes_cnt+ 1), stat = alterlist(
        ddr_domain_data->src_nodes,ddr_domain_data->src_nodes_cnt), ddr_domain_data->src_nodes[
       ddr_domain_data->src_nodes_cnt].node_name = cnvtlower(trim(t.line,3))
      ELSE
       ddr_domain_data->tgt_nodes_cnt = (ddr_domain_data->tgt_nodes_cnt+ 1), stat = alterlist(
        ddr_domain_data->tgt_nodes,ddr_domain_data->tgt_nodes_cnt), ddr_domain_data->tgt_nodes[
       ddr_domain_data->tgt_nodes_cnt].node_name = cnvtlower(trim(t.line,3))
      ENDIF
      IF (cnvtlower(trim(t.line,3))=trim(cnvtlower(curnode)))
       dgn_found_curnode = 1
      ENDIF
     ENDIF
     IF (findstring("----",t.line,1,1) > 0)
      dgn_found_start = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_domain_data)
   ENDIF
   IF (((dgn_src_ind=1
    AND (ddr_domain_data->src_nodes_cnt=0)) OR (dgn_tgt_ind=1
    AND (ddr_domain_data->tgt_nodes_cnt=0))) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to obtaing listing of nodes from SCP"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgn_found_curnode=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Current node,",trim(curnode)," not found via SCP nodes command.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgn_cnt = evaluate(dgn_src_ind,1,ddr_domain_data->src_nodes_cnt,ddr_domain_data->tgt_nodes_cnt
    )
   IF (dgn_cnt > 1)
    FREE RECORD dgn_work
    RECORD dgn_work(
      1 nodes_cnt = i4
      1 nodes[*]
        2 keep = i2
        2 node_name = vc
    )
    IF (dgn_src_ind=1)
     SET dgn_work->nodes_cnt = ddr_domain_data->src_nodes_cnt
    ELSE
     SET dgn_work->nodes_cnt = ddr_domain_data->tgt_nodes_cnt
    ENDIF
    SET stat = alterlist(dgn_work->nodes,dgn_work->nodes_cnt)
    FOR (dgn_ndx = 1 TO dgn_work->nodes_cnt)
      IF (dgn_src_ind=1)
       SET dgn_work->nodes[dgn_ndx].node_name = ddr_domain_data->src_nodes[dgn_ndx].node_name
       SET ddr_domain_data->src_nodes[dgn_ndx].node_name = ""
      ELSE
       SET dgn_work->nodes[dgn_ndx].node_name = ddr_domain_data->tgt_nodes[dgn_ndx].node_name
       SET ddr_domain_data->tgt_nodes[dgn_ndx].node_name = ""
      ENDIF
    ENDFOR
    FOR (dgn_ndx = 1 TO dgn_work->nodes_cnt)
      IF ((dgn_work->nodes[dgn_ndx].node_name=cnvtlower(trim(curnode))))
       IF (dgn_src_ind=1)
        SET ddr_domain_data->src_nodes[1].node_name = dgn_work->nodes[dgn_ndx].node_name
       ELSE
        SET ddr_domain_data->tgt_nodes[1].node_name = dgn_work->nodes[dgn_ndx].node_name
       ENDIF
      ENDIF
    ENDFOR
    SET dgn_cnt = 1
    FOR (dgn_ndx = 1 TO dgn_work->nodes_cnt)
      IF ((dgn_work->nodes[dgn_ndx].node_name != cnvtlower(trim(curnode))))
       SET dgn_cnt = (dgn_cnt+ 1)
       IF (dgn_src_ind=1)
        SET ddr_domain_data->src_nodes[dgn_cnt].node_name = dgn_work->nodes[dgn_ndx].node_name
       ELSE
        SET ddr_domain_data->tgt_nodes[dgn_cnt].node_name = dgn_work->nodes[dgn_ndx].node_name
       ENDIF
      ENDIF
    ENDFOR
    FREE RECORD dgn_work
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF (dgn_src_ind=1)
     IF ((ddr_domain_data->src_nodes_cnt=drrr_misc_data->src_app_node_cnt))
      FOR (dgn_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
        IF (locateval(dgn_ndx,1,drrr_misc_data->src_app_node_cnt,ddr_domain_data->src_nodes[dgn_cnt].
         node_name,drrr_misc_data->src_app_nodes[dgn_ndx].node_name)=0)
         SET dm_err->eproc = concat(
          "Validating Source node list retrieved from scp to node list specified in response file.")
         SET dm_err->emsg = concat("SCP Source node (",trim(ddr_domain_data->src_nodes[dgn_cnt].
           node_name,3),") not found in list specified in response file.")
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
      ENDFOR
     ELSE
      SET dm_err->eproc = concat(
       "Validating Source node list retrieved from scp to node list specified in response file.")
      SET dm_err->emsg = concat("SCP Source node list count (",trim(cnvtstring(ddr_domain_data->
         src_nodes_cnt),3),") does not match node count in resposne file (",trim(cnvtstring(
         drrr_misc_data->src_app_node_cnt),3),").")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF ((ddr_domain_data->tgt_nodes_cnt=drrr_misc_data->tgt_app_node_cnt))
      FOR (dgn_cnt = 1 TO ddr_domain_data->tgt_nodes_cnt)
        IF (locateval(dgn_ndx,1,drrr_misc_data->tgt_app_node_cnt,ddr_domain_data->tgt_nodes[dgn_cnt].
         node_name,drrr_misc_data->tgt_app_nodes[dgn_ndx].node_name)=0)
         SET dm_err->eproc = concat(
          "Validating Target node list retrieved from scp to node list specified in response file.")
         SET dm_err->emsg = concat("SCP Target node (",trim(ddr_domain_data->tgt_nodes[dgn_cnt].
           node_name,3),") not found in list specified in response file.")
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
      ENDFOR
     ELSE
      SET dm_err->eproc = concat(
       "Validating Target node list retrieved from scp to node list specified in response file.")
      SET dm_err->emsg = concat("SCP Target node list count (",trim(cnvtstring(ddr_domain_data->
         tgt_nodes_cnt),3),") does not match node count in resposne file (",trim(cnvtstring(
         drrr_misc_data->tgt_app_node_cnt),3),").")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_set_tgt_node_flag(null)
   DECLARE dstnf_srv_status = i2 WITH protect, noconstant(0)
   DECLARE dstnf_ok = i2 WITH protect, noconstant(1)
   DECLARE dstnf_accept = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Determine type of target node"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (validate(dm2_refresh_force_secondary,0)=1)
    SET ddr_domain_data->tgt_node_flag = 3
    RETURN(1)
   ENDIF
   IF ((ddr_domain_data->tgt_nodes_cnt=1))
    SET ddr_domain_data->tgt_node_flag = 1
   ELSEIF ((ddr_domain_data->tgt_nodes_cnt > 1))
    SET ddr_domain_data->tgt_node_flag = 3
    IF ((ddr_domain_data->tgt_tdb_server_master_id > 0))
     IF (ddr_get_srv_status(ddr_domain_data->tgt_tdb_server_master_id,ddr_domain_data->
      tgt_tdb_server_master_desc,dstnf_srv_status)=0)
      RETURN(0)
     ENDIF
     IF (dstnf_srv_status=1)
      IF ((ddr_domain_data->tgt_was_arch_ind=1))
       SET ddr_domain_data->tgt_node_flag = 2
      ELSE
       IF ((ddr_domain_data->tgt_sec_server_master_id > 0))
        IF (ddr_get_srv_status(ddr_domain_data->tgt_sec_server_master_id,ddr_domain_data->
         tgt_sec_server_master_desc,dstnf_srv_status)=0)
         RETURN(0)
        ENDIF
        IF (dstnf_srv_status=1)
         SET ddr_domain_data->tgt_node_flag = 2
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("tgt_node_flag = ",ddr_domain_data->tgt_node_flag))
    ENDIF
    IF ((ddr_domain_data->tgt_node_flag IN (1, 2)))
     IF ((drrr_rf_data->tgt_primary_app_node != trim(cnvtlower(curnode))))
      SET dm_err->eproc = concat(
       "Validating Target node flag based on server configuration and specified primary app ",
       "node specified in response file.")
      SET dm_err->emsg = concat(
       "Primary node detected, but current node does not match primary app node specified in ",
       "response file.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF ((drrr_rf_data->tgt_primary_app_node=trim(cnvtlower(curnode))))
      SET dm_err->eproc = concat(
       "Validating Target node flag based on server configuration and specified primary app ",
       "node specified in response file.")
      SET dm_err->emsg = concat(
       "Secondary node detected, but current node matches primary app node specified in ",
       "response file.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF ((ddr_domain_data->tgt_node_flag IN (2, 3)))
     SET dm_err->eproc = "Node Type confirmation"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     WHILE (dstnf_ok=1)
       IF ((dm_err->debug_flag != 511))
        SET message = window
       ENDIF
       SET width = 132
       CALL clear(1,1)
       CALL box(1,1,22,131)
       CALL text(1,2,"APPLICATION NODE TYPE CONFIRMATION SCREEN ")
       IF ((ddr_domain_data->tgt_node_flag=2))
        CALL text(3,2,
         "It has been determined that this node is the PRIMARY NODE of a multi-node target")
       ELSEIF ((ddr_domain_data->tgt_node_flag=3))
        CALL text(3,2,
         "It has been determined that this node is the SECONDARY NODE of a multi-node target")
       ENDIF
       CALL text(5,2,"Is this information correct: (Y)es,(N)o,(Q)uit?")
       CALL accept(5,50,"A;cu"," "
        WHERE curaccept IN ("Y", "N", "Q"))
       SET dstnf_accept = curaccept
       IF (dstnf_accept="N")
        CALL text(6,2,concat("The current node will now be changed to ",evaluate(ddr_domain_data->
           tgt_node_flag,2,"SECONDARY","PRIMARY")))
        CALL text(7,2,"Are you sure?: (Y)es,(N)o")
        CALL accept(7,28,"A;cu"," "
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         SET dstnf_ok = 0
         IF ((ddr_domain_data->tgt_node_flag=2))
          SET ddr_domain_data->tgt_node_flag = 3
         ELSEIF ((ddr_domain_data->tgt_node_flag=3))
          SET ddr_domain_data->tgt_node_flag = 2
         ENDIF
        ENDIF
       ELSEIF (dstnf_accept="Q")
        SET dstnf_ok = 0
        SET message = nowindow
        SET dm_err->emsg = "User elected to quit from Target Node Type Confirmation"
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        SET dstnf_ok = 0
       ENDIF
     ENDWHILE
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
   ENDIF
   IF ((ddr_domain_data->tgt_node_flag IN (1, 2)))
    IF ((ddr_domain_data->tgt_was_arch_ind=0))
     IF ((ddr_domain_data->tgt_sec_server_master_id=0))
      SET dm_err->eproc = "Validating Security Master Server on Target Node"
      SET dm_err->emsg = "Security Master Server does not exist on current target node"
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((ddr_domain_data->tgt_tdb_server_master_id=0))
     SET dm_err->eproc = "Validating Transaction Database Master Server on Target Node"
     SET dm_err->emsg = "Transaction Database Master Server does not exist on current target node"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_srv_status(dgss_id,dgss_desc,dgss_srv_status)
   DECLARE dgss_file_name = vc WITH protect, noconstant("")
   DECLARE dgss_cmd = vc WITH protect, noconstant("")
   DECLARE dgss_inst_fnd = i2 WITH protect, noconstant(0)
   DECLARE dgss_id_str = vc WITH protect, noconstant("")
   DECLARE dgss_desc_str = vc WITH protect, noconstant("")
   SET dgss_id_str = trim(cnvtstring(dgss_id))
   SET dgss_desc_str = trim(cnvtlower(dgss_desc))
   SET dm_err->eproc = concat("Get server status for server: ",dgss_desc_str,"(id = ",dgss_id_str,")"
    )
   CALL disp_msg("",dm_err->logfile,0)
   SET dgss_file_name = concat(ddr_domain_data->tgt_tmp_full_dir,"server_status",evaluate(
     dm2_sys_misc->cur_os,"AXP",".com",".ksh"))
   IF (dm2_findfile(dgss_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgss_cmd = concat("del ",dgss_file_name,";*")
    ELSE
     SET dgss_cmd = concat("rm ",dgss_file_name)
    ENDIF
    IF (dm2_push_dcl(dgss_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to get server instance :",dgss_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dgss_file_name)
    FROM (dummyt t  WITH seq = 1)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!server_status.com"), row + 1,
      CALL print("$srv_fnd=0"),
      row + 1,
      CALL print("$srv_inst=0"), row + 1,
      CALL print("$stat_pos=0"), row + 1,
      CALL print("$id_pos=0"),
      row + 1,
      CALL print("$desc_pos=0"), row + 1,
      CALL print('$tgt_node = f$getsyi("nodename") '), row + 1, dgss_cmd = concat('$   if f$search("',
       ddr_domain_data->tgt_tmp_full_dir,'server_status.dat") .nes. "" then delete ',ddr_domain_data
       ->tgt_tmp_full_dir,"server_status.dat;*"),
      CALL print(dgss_cmd), row + 1,
      CALL print(concat("$   define/user_mode sys$output ",ddr_domain_data->tgt_tmp_full_dir,
       "server_status.dat")),
      row + 1,
      CALL print("$mcr cer_exe:scpview 'tgt_node'"), row + 1,
      CALL print("$DECK"), row + 1,
      CALL print(ddr_domain_data->tgt_mng),
      row + 1,
      CALL print(ddr_domain_data->tgt_domain_name), row + 1,
      CALL print(ddr_domain_data->tgt_mng_pwd), row + 1,
      CALL print("find -inst -gt 0"),
      row + 1,
      CALL print("exit"), row + 1,
      CALL print("$EOD"), row + 1,
      CALL print(concat("$   open/read SERVER_LIST ",ddr_domain_data->tgt_tmp_full_dir,
       "server_status.dat")),
      row + 1,
      CALL print("$   READ_SERVER_LIST:"), row + 1,
      CALL print("$      read/end_of_file=END_READ_SERVER_LIST SERVER_LIST record"), row + 1,
      CALL print('$      record = f$edit(record, "lowercase")'),
      row + 1,
      CALL print("$      length = f$length(record)"), row + 1,
      CALL print(concat('$      id_pos = f$locate("',dgss_id_str,'", record)')), row + 1,
      CALL print("$      if (id_pos .ne. length)"),
      row + 1,
      CALL print("$      then"), row + 1,
      CALL print(concat('$         desc_pos = f$locate("',dgss_desc_str,'", record)')), row + 1,
      CALL print("$         if (desc_pos .gt. 0) .and. (desc_pos .ne. length)"),
      row + 1,
      CALL print("$         then"), row + 1,
      CALL print("$            srv_inst = 1"), row + 1,
      CALL print("$         endif"),
      row + 1,
      CALL print("$      endif"), row + 1,
      CALL print("$!     write sys$output record "), row + 1,
      CALL print("$      if (srv_inst .eq. 0)"),
      row + 1,
      CALL print("$      then"), row + 1,
      CALL print("$         goto READ_SERVER_LIST "), row + 1,
      CALL print("$      endif"),
      row + 1,
      CALL print("$   END_READ_SERVER_LIST: "), row + 1,
      CALL print("$      close SERVER_LIST  "), row + 1,
      CALL print("$   if (srv_inst .eq. 0) "),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print('$      write sys$output "Server does not have an instance."'), row + 1,
      CALL print("$      exit 1"),
      row + 1,
      CALL print("$   else"), row + 1,
      CALL print('$      write sys$output "Server has an instance."'), row + 1,
      CALL print("$      exit 1"),
      row + 1,
      CALL print("$   endif"), row + 1
     ELSE
      CALL print("#!/usr/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("# server_status.ksh"), row + 1,
      CALL print("#"), row + 1,
      CALL print("srv_inst=0"),
      row + 1,
      CALL print("tgt_node=`hostname`"), row + 1,
      CALL print(concat("tgt_mng_pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1,
      CALL print(concat("$cer_exe/scpview $tgt_node <<!>",ddr_domain_data->tgt_tmp_full_dir,
       "server_status.dat")),
      row + 1,
      CALL print(ddr_domain_data->tgt_mng), row + 1,
      CALL print(ddr_domain_data->tgt_domain_name), row + 1,
      CALL print("$tgt_mng_pwd"),
      row + 1,
      CALL print("find -inst -gt 0"), row + 1,
      CALL print("exit"), row + 1,
      CALL print("!"),
      row + 1, row + 1,
      CALL print(concat("   tr '[:upper:]' '[:lower:]' < ",ddr_domain_data->tgt_tmp_full_dir,
       'server_status.dat|grep "',dgss_id_str,'" |grep "',
       dgss_desc_str,'"')),
      row + 1, row + 1,
      CALL print("   if [[ $? -eq 0 ]]"),
      row + 1,
      CALL print("   then"), row + 1,
      CALL print("      srv_inst=1"), row + 1,
      CALL print("   fi"),
      row + 1, row + 1,
      CALL print("if [[ $srv_inst -eq 0 ]]"),
      row + 1,
      CALL print("then"), row + 1,
      CALL print('   echo "Server does not have an instance."'), row + 1,
      CALL print("fi"),
      row + 1, row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute ",dgss_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgss_cmd = concat("@",dgss_file_name)
   ELSE
    SET dgss_cmd = concat("chmod 777 ",dgss_file_name)
    IF (dm2_push_dcl(dgss_cmd)=0)
     RETURN(0)
    ENDIF
    SET dgss_cmd = concat(". ",dgss_file_name)
   ENDIF
   IF (dm2_push_dcl(dgss_cmd)=0)
    RETURN(0)
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (findstring("Server does not have an instance",dm_err->errtext,1,1) > 0)
     SET dgss_inst_fnd = 0
    ELSE
     SET dgss_inst_fnd = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (dgss_inst_fnd=1)
    SET dgss_file_name = concat(ddr_domain_data->tgt_tmp_full_dir,"server_status",evaluate(
      dm2_sys_misc->cur_os,"AXP",".com",".ksh"))
    IF (dm2_findfile(dgss_file_name) > 0)
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgss_cmd = concat("del ",dgss_file_name,";*")
     ELSE
      SET dgss_cmd = concat("rm ",dgss_file_name)
     ENDIF
     IF (dm2_push_dcl(dgss_cmd)=0)
      RETURN(0)
     ENDIF
    ELSE
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Create file to get server status :",dgss_file_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO value(dgss_file_name)
     FROM (dummyt t  WITH seq = 1)
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print("$!server_status.com"), row + 1,
       CALL print("$srv_fnd=0"),
       row + 1,
       CALL print("$srv_pos=0"), row + 1,
       CALL print('$tgt_node = f$getsyi("nodename") '), row + 1, dgss_cmd = concat(
        '$   if f$search("',ddr_domain_data->tgt_tmp_full_dir,
        'server_status.dat") .nes. "" then delete ',ddr_domain_data->tgt_tmp_full_dir,
        "server_status.dat;*"),
       CALL print(dgss_cmd), row + 1,
       CALL print(concat("$   define/user_mode sys$output ",ddr_domain_data->tgt_tmp_full_dir,
        "server_status.dat")),
       row + 1,
       CALL print("$mcr cer_exe:scpview 'tgt_node'"), row + 1,
       CALL print("$DECK"), row + 1,
       CALL print(ddr_domain_data->tgt_mng),
       row + 1,
       CALL print(ddr_domain_data->tgt_domain_name), row + 1,
       CALL print(ddr_domain_data->tgt_mng_pwd), row + 1,
       CALL print("server -state running"),
       row + 1,
       CALL print("exit"), row + 1,
       CALL print("$EOD"), row + 1,
       CALL print(concat("$   open/read SERVER_LIST ",ddr_domain_data->tgt_tmp_full_dir,
        "server_status.dat")),
       row + 1,
       CALL print("$   READ_SERVER_LIST:"), row + 1,
       CALL print("$      read/end_of_file=END_READ_SERVER_LIST SERVER_LIST record"), row + 1,
       CALL print('$      record = f$edit(record, "lowercase")'),
       row + 1,
       CALL print("$      length = f$length(record)"), row + 1,
       CALL print(concat('$      srv_pos = f$locate("',dgss_desc_str,'", record)')), row + 1,
       CALL print("$      if (srv_pos .gt. 0) .and. (srv_pos .ne. length)"),
       row + 1,
       CALL print("$      then"), row + 1,
       CALL print("$            srv_fnd = 1"), row + 1,
       CALL print("$      endif"),
       row + 1,
       CALL print("$!     write sys$output record "), row + 1,
       CALL print("$      if (srv_fnd .eq. 0)"), row + 1,
       CALL print("$      then"),
       row + 1,
       CALL print("$         goto READ_SERVER_LIST "), row + 1,
       CALL print("$      endif"), row + 1,
       CALL print("$   END_READ_SERVER_LIST: "),
       row + 1,
       CALL print("$      close SERVER_LIST  "), row + 1,
       CALL print("$   if (srv_fnd .eq. 0)"), row + 1,
       CALL print("$   then"),
       row + 1,
       CALL print('$      write sys$output "Server failed to run."'), row + 1,
       CALL print("$      exit 1"), row + 1,
       CALL print("$   else"),
       row + 1,
       CALL print('$      write sys$output "Server is running."'), row + 1,
       CALL print("$      exit 1"), row + 1,
       CALL print("$   endif"),
       row + 1
      ELSE
       CALL print("#!/usr/bin/ksh"), row + 1,
       CALL print("#"),
       row + 1,
       CALL print("# server_status.ksh"), row + 1,
       CALL print("#"), row + 1,
       CALL print("srv_fnd=0"),
       row + 1,
       CALL print("tgt_node=`hostname`"), row + 1,
       CALL print(concat("tgt_mng_pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1,
       CALL print(concat("$cer_exe/scpview $tgt_node <<!>",ddr_domain_data->tgt_tmp_full_dir,
        "server_status.dat")),
       row + 1,
       CALL print(ddr_domain_data->tgt_mng), row + 1,
       CALL print(ddr_domain_data->tgt_domain_name), row + 1,
       CALL print("$tgt_mng_pwd"),
       row + 1,
       CALL print("server -state running"), row + 1,
       CALL print("exit"), row + 1,
       CALL print("!"),
       row + 1, row + 1,
       CALL print(concat("   tr '[:upper:]' '[:lower:]' < ",ddr_domain_data->tgt_tmp_full_dir,
        'server_status.dat|grep "',dgss_desc_str,'"')),
       row + 1, row + 1,
       CALL print("   if [[ $? -eq 0 ]]"),
       row + 1,
       CALL print("   then"), row + 1,
       CALL print("      srv_fnd=1"), row + 1,
       CALL print("   fi"),
       row + 1, row + 1,
       CALL print("if [[ $srv_fnd -eq 0 ]]"),
       row + 1,
       CALL print("then"), row + 1,
       CALL print('   echo "Server failed to run."'), row + 1,
       CALL print("fi"),
       row + 1, row + 1
      ENDIF
     WITH nocounter, maxcol = 500, format = variable,
      maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Execute ",dgss_file_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgss_cmd = concat("@",dgss_file_name)
    ELSE
     SET dgss_cmd = concat("chmod 777 ",dgss_file_name)
     IF (dm2_push_dcl(dgss_cmd)=0)
      RETURN(0)
     ENDIF
     SET dgss_cmd = concat(". ",dgss_file_name)
    ENDIF
    IF (dm2_push_dcl(dgss_cmd)=0)
     RETURN(0)
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring("Server failed to run",dm_err->errtext,1,1) > 0)
      SET dgss_srv_status = 0
     ELSE
      SET dgss_srv_status = 1
     ENDIF
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ELSE
    SET dgss_srv_status = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_backup_servers(null)
   DECLARE dbs_cmd_file = vc WITH protect, noconstant("")
   DECLARE dbs_cmd = vc WITH protect, noconstant("")
   DECLARE dbs_env = vc WITH protect, noconstant(ddr_domain_data->tgt_env)
   DECLARE dbs_node = vc WITH protect, noconstant(trim(cnvtlower(curnode)))
   DECLARE dbs_dir_name = vc WITH protect, noconstant("")
   DECLARE dbs_file_name = vc WITH protect, noconstant("")
   DECLARE dbs_key_not_found = i2 WITH protect, noconstant(0)
   DECLARE dbs_slash = vc WITH protect, noconstant("\\")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dbs_slash = "\"
   ENDIF
   SET dbs_cmd = concat("\",dbs_slash,"system",dbs_slash,"node",
    dbs_slash,trim(curnode),dbs_slash,"domain",dbs_slash,
    ddr_domain_data->tgt_domain_name,dbs_slash,"servers")
   SET dm_err->eproc = concat("Delete any files in cer_reg with name secondary*.reg")
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dbs_file_name = evaluate(dm2_sys_misc->cur_os,"AXP","cer_reg:secondary*.reg;*",
    "$cer_reg/secondary*.reg")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF (dm2_findfile(dbs_file_name) > 0)
     IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dbs_file_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF (ddr_lnx_findfile(dbs_file_name) > 0)
     IF (dm2_push_dcl(concat("rm ",dbs_file_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = "Backup servers 31, 32, 34, 35 on secondary target node"
   CALL disp_msg("",dm_err->logfile,0)
   IF (get_unique_file("backup_servers",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dbs_cmd_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to backup servers :",dbs_cmd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dbs_cmd_file)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$mcr cer_exe:lregview"), row + 1
     ELSE
      CALL print("$cer_exe/lregview <<!"), row + 1
     ENDIF
     CALL print(concat("cd ",dbs_cmd)), row + 1,
     CALL print(concat("copy 31 \",dbs_slash,"secondary_31_backup -sub")),
     row + 1,
     CALL print(concat("copy 32 \",dbs_slash,"secondary_32_backup -sub")), row + 1,
     CALL print(concat("copy 34 \",dbs_slash,"secondary_34_backup -sub")), row + 1,
     CALL print(concat("copy 35 \",dbs_slash,"secondary_35_backup -sub")),
     row + 1,
     CALL print("exit")
     IF ((dm2_sys_misc->cur_os != "AXP"))
      row + 1,
      CALL print("!"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute file: ",dbs_cmd_file)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dbs_cmd = concat("@",dbs_cmd_file)
   ELSE
    SET dbs_cmd = concat(". $CCLUSERDIR/",dbs_cmd_file)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dbs_cmd)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   SET dm_err->eproc = concat("Copy server backups to ",ddr_domain_data->tgt_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dbs_file_name = evaluate(dm2_sys_misc->cur_os,"AXP","cer_reg:secondary*.reg",
    "$cer_reg/secondary*.reg")
   SET dbs_dir_name = ddr_domain_data->tgt_tmp_full_dir
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF (dm2_findfile(dbs_file_name) > 0)
     IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","backup/log","cp -p")," ",
       dbs_file_name," ",dbs_dir_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF (ddr_lnx_findfile(dbs_file_name) > 0)
     IF (dm2_push_dcl(concat("cp -p ",dbs_file_name," ",dbs_dir_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_srv_def(dgsd_src_ind,dgsd_tgt_ind)
   DECLARE dgsd_ret = vc WITH protect, noconstant("")
   DECLARE dgsd_cmd = vc WITH protect, noconstant("")
   DECLARE dgsd_36_exists = i2 WITH protect, noconstant(0)
   DECLARE dgsd_err_file = vc WITH protect, noconstant("")
   DECLARE dgsd_stat = i2 WITH protect, noconstant(0)
   DECLARE dgsd_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgsd_str = vc WITH protect, noconstant("")
   DECLARE dgsd_scp_file = vc WITH protect, noconstant("")
   DECLARE dgsd_file = vc WITH protect, noconstant("")
   DECLARE dgsd_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgsd_changed = i2 WITH protect, noconstant(0)
   DECLARE dgsd_env = vc WITH protect, noconstant(evaluate(dgsd_src_ind,1,ddr_domain_data->
     src_domain_name,ddr_domain_data->tgt_domain_name))
   DECLARE dgsd_scp_dir = vc WITH protect, noconstant(evaluate(dgsd_src_ind,1,ddr_domain_data->
     src_tmp_full_dir,ddr_domain_data->tgt_tmp_full_dir))
   DECLARE dgsd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgsd_node = vc WITH protect, noconstant(evaluate(dgsd_src_ind,1,ddr_domain_data->
     src_nodes[1].node_name,ddr_domain_data->tgt_nodes[1].node_name))
   DECLARE dgsd_cnt_file = vc WITH protect, noconstant(concat(ddr_domain_data->src_tmp_full_dir,
     ddr_domain_data->src_env,"_scp.txt"))
   DECLARE dgsd_server_count = i4 WITH protect, noconstant(0)
   IF (get_unique_file("ddr_get_reg",".err")=0)
    RETURN(0)
   ELSE
    SET dgsd_err_file = dm_err->unique_fname
   ENDIF
   IF (dgsd_src_ind=1)
    FOR (dgsd_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
      SET dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->src_nodes[dgsd_cnt].
       node_name,"_save.scp")
      SET dm_err->eproc = concat("Remove:",dgsd_scp_file)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      IF (dm2_findfile(dgsd_scp_file) > 0)
       IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(
          dm2_sys_misc->cur_os,"AXP",concat(dgsd_scp_file,dgsd_suffix),dgsd_scp_file)))=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    FOR (dgsd_cnt = 1 TO ddr_domain_data->tgt_nodes_cnt)
      SET dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->tgt_nodes[dgsd_cnt].
       node_name,"_save.scp")
      SET dm_err->eproc = concat("Remove:",dgsd_scp_file)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      IF (dm2_findfile(dgsd_scp_file) > 0)
       IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(
          dm2_sys_misc->cur_os,"AXP",concat(dgsd_scp_file,dgsd_suffix),dgsd_scp_file)))=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET dm_err->eproc = "Check if Server 36 exists."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsd_str = concat("\node\",dgsd_node,"\domain\",dgsd_env,"\servers\36 Protect")
   ELSE
    SET dgsd_str = concat("\\node\\",dgsd_node,"\\domain\\",dgsd_env,"\\servers\\36 Protect")
   ENDIF
   IF (ddr_lreg_oper("GET",dgsd_str,dgsd_ret)=0)
    RETURN(0)
   ENDIF
   IF (dgsd_ret="NOPARMRETURNED")
    SET dgsd_36_exists = 0
   ELSE
    SET dgsd_36_exists = 1
   ENDIF
   IF (dgsd_36_exists=1
    AND dgsd_ret != "N")
    SET dgsd_changed = 1
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsd_str = concat("\node\",dgsd_node,"\domain\",dgsd_env,'\servers\36 Protect "N"')
    ELSE
     SET dgsd_str = concat("\\node\\",dgsd_node,"\\domain\\",dgsd_env,'\\servers\\36 Protect "N"')
    ENDIF
    IF (ddr_lreg_oper("SET",dgsd_str,dgsd_ret)=0)
     RETURN(0)
    ENDIF
    IF (ddr_scp_apply("36",dgsd_src_ind,dgsd_tgt_ind)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsd_str = concat("\node\",dgsd_node,"\domain\",dgsd_env,"\servers\36 Protect")
    ELSE
     SET dgsd_str = concat("\\node\\",dgsd_node,"\\domain\\",dgsd_env,"\\servers\\36 Protect")
    ENDIF
    IF (ddr_lreg_oper("GET",dgsd_str,dgsd_ret)=0)
     RETURN(0)
    ENDIF
    IF (dgsd_ret != "N")
     SET dm_err->emsg = "Error setting protect property for server 36."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (get_unique_file("get_src_srvdef",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    IF (dgsd_changed=1)
     CALL ddr_reset_36(dgsd_node,dgsd_env)
    ENDIF
    RETURN(0)
   ELSE
    SET dgsd_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to obtain SERVER DEFINITIONS:",dgsd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dgsd_file)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print(concat("$mcr cer_exe:scpview ",dgsd_node)), row + 1,
      CALL print("$DECK"),
      row + 1
     ELSE
      IF (dgsd_src_ind=1)
       CALL print(concat("src_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1
      ELSE
       CALL print(concat("tgt_mng_pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1
      ENDIF
      CALL print(concat("$cer_exe/scpview ",dgsd_node," <<!")), row + 1
     ENDIF
     IF (dgsd_src_ind=1)
      CALL print(ddr_domain_data->src_mng), row + 1,
      CALL print(ddr_domain_data->src_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->src_mng_pwd), row + 1
      ELSE
       CALL print("$src_mng_pwd"), row + 1
      ENDIF
     ELSE
      CALL print(ddr_domain_data->tgt_mng), row + 1,
      CALL print(ddr_domain_data->tgt_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->tgt_mng_pwd), row + 1
      ELSE
       CALL print("$tgt_mng_pwd"), row + 1
      ENDIF
     ENDIF
     IF (dgsd_src_ind=1)
      FOR (dgsd_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
        CALL print(concat("select ",ddr_domain_data->src_nodes[dgsd_cnt].node_name)), row + 1,
        dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->src_nodes[dgsd_cnt].
         node_name,"_save.scp"),
        CALL print(concat("export ",dgsd_scp_file)), row + 1
      ENDFOR
     ELSE
      FOR (dgsd_cnt = 1 TO ddr_domain_data->tgt_nodes_cnt)
        CALL print(concat("select ",ddr_domain_data->tgt_nodes[dgsd_cnt].node_name)), row + 1,
        dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->tgt_nodes[dgsd_cnt].
         node_name,"_save.scp"),
        CALL print(concat("export ",dgsd_scp_file)), row + 1
      ENDFOR
     ENDIF
     CALL print("exit"), row + 1
     IF ((dm2_sys_misc->cur_os != "AXP"))
      CALL print("!"), row + 1
     ELSE
      CALL print("$EOD"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dgsd_changed=1)
     CALL ddr_reset_36(dgsd_node,dgsd_env)
    ENDIF
    RETURN(0)
   ENDIF
   IF (dgsd_src_ind=1)
    SET dm_err->eproc = "Obtain SOURCE SERVER DEFINITIONS."
   ELSE
    SET dm_err->eproc = "Obtain TARGET SERVER DEFINITIONS."
   ENDIF
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsd_cmd = concat("@",dgsd_file)
   ELSE
    SET dgsd_cmd = concat(". $CCLUSERDIR/",dgsd_file)
   ENDIF
   IF (dm2_push_dcl(dgsd_cmd)=0)
    IF (dgsd_changed=1)
     CALL ddr_reset_36(dgsd_node,dgsd_env)
    ENDIF
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    IF (dgsd_changed=1)
     CALL ddr_reset_36(dgsd_node,dgsd_env)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (((findstring("bad command",dm_err->errtext,1,1) > 0) OR (findstring(
    "node not offering services",dm_err->errtext,1,1) > 0)) )
    SET dm_err->emsg = concat("Error exporting server definitions:",dgsd_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dgsd_changed=1)
     CALL ddr_reset_36(dgsd_node,dgsd_env)
    ENDIF
    RETURN(0)
   ENDIF
   IF (dgsd_src_ind=1)
    FOR (dgsd_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
      SET dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->src_nodes[dgsd_cnt].
       node_name,"_save.scp")
      SET dm_err->eproc = concat("Check:",dgsd_scp_file)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      IF (dm2_findfile(dgsd_scp_file)=0)
       SET dm_err->emsg = concat(
        "Error exporting SOURCE server definitions. Server definitions export does not exist.")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       IF (dgsd_changed=1)
        CALL ddr_reset_36(dgsd_node,dgsd_env)
       ENDIF
       RETURN(0)
      ENDIF
    ENDFOR
   ELSE
    FOR (dgsd_cnt = 1 TO ddr_domain_data->tgt_nodes_cnt)
      SET dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->tgt_nodes[dgsd_cnt].
       node_name,"_save.scp")
      SET dm_err->eproc = concat("Check:",dgsd_scp_file)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      IF (dm2_findfile(dgsd_scp_file)=0)
       SET dm_err->emsg = concat(
        "Error exporting TARGET server definitions. Server definitions export does not exist.")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       IF (dgsd_changed=1)
        CALL ddr_reset_36(dgsd_node,dgsd_env)
       ENDIF
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   IF (dgsd_src_ind=1)
    SET ddr_domain_data->src_srv_def_fnd = 1
    SET dgsd_file_date = 0.0
    SET dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->src_nodes[1].node_name,
     "_save.scp")
    IF (ddr_get_file_date(dgsd_scp_file,dgsd_file_date)=0)
     IF (dgsd_changed=1)
      CALL ddr_reset_36(dgsd_node,dgsd_env)
     ENDIF
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_srv_def_ts = dgsd_file_date
   ELSE
    SET dgsd_scp_file = concat(dgsd_scp_dir,dgsd_env,"_",ddr_domain_data->tgt_nodes[1].node_name,
     "_save.scp")
    SET ddr_domain_data->tgt_srv_def_fnd = 1
    SET dgsd_file_date = 0.0
    IF (ddr_get_file_date(dgsd_scp_file,dgsd_file_date)=0)
     IF (dgsd_changed=1)
      CALL ddr_reset_36(dgsd_node,dgsd_env)
     ENDIF
     RETURN(0)
    ENDIF
    SET ddr_domain_data->tgt_srv_def_ts = dgsd_file_date
   ENDIF
   IF (dgsd_src_ind=1)
    IF (dgsd_changed=1)
     CALL ddr_reset_36(dgsd_node,dgsd_env)
     IF ((dm_err->err_ind > 0))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dgsd_src_ind=1)
    IF (get_unique_file("get_src_srv_cnt",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
     RETURN(0)
    ELSE
     SET dgsd_file = dm_err->unique_fname
    ENDIF
    SET dm_err->eproc = concat("Create file to obtain Source Server count:",dgsd_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO value(dgsd_file)
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$define/user_mode sys$output ",dgsd_cnt_file)), row + 1,
       CALL print(concat("$mcr cer_exe:scpview ",dgsd_node)),
       row + 1,
       CALL print("$DECK"), row + 1
      ELSE
       CALL print(concat("src_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1,
       CALL print(concat("$cer_exe/scpview ",dgsd_node,"  <<!>",dgsd_cnt_file)),
       row + 1
      ENDIF
      CALL print(ddr_domain_data->src_mng), row + 1,
      CALL print(ddr_domain_data->src_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->src_mng_pwd), row + 1
      ELSE
       CALL print("$src_mng_pwd"), row + 1
      ENDIF
      CALL print("dir"), row + 1,
      CALL print("exit"),
      row + 1
      IF ((dm2_sys_misc->cur_os != "AXP"))
       CALL print("!"), row + 1
      ELSE
       CALL print("$EOD"), row + 1
      ENDIF
     WITH nocounter, maxcol = 500, format = variable,
      maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Obtain Source Server count."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsd_cmd = concat("@",dgsd_file)
    ELSE
     SET dgsd_cmd = concat(". $CCLUSERDIR/",dgsd_file)
    ENDIF
    IF (dm2_push_dcl(dgsd_cmd)=0)
     RETURN(0)
    ENDIF
    IF (ddr_parse_count(dgsd_cnt_file,dgsd_server_count)=0)
     RETURN(0)
    ENDIF
    IF (dgsd_server_count < 10)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Source server count is less than 10."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_server_count = dgsd_server_count
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_tdb(dgt_src_ind,dgt_tgt_ind)
   DECLARE dgt_file = vc WITH protect, noconstant("")
   DECLARE dgt_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgt_cmd = vc WITH protect, noconstant("")
   DECLARE dgt_tdb_file = vc WITH protect, noconstant(concat(evaluate(dgt_src_ind,1,ddr_domain_data->
      src_tmp_full_dir,ddr_domain_data->tgt_tmp_full_dir),evaluate(dgt_src_ind,1,ddr_domain_data->
      src_env,ddr_domain_data->tgt_env),"_tdb.msg"))
   DECLARE dgt_suffix = vc WITH protect, noconstant(";*")
   DECLARE dgt_tdb_count = i4 WITH protect, noconstant(0)
   DECLARE dgt_cnt_file = vc WITH protect, noconstant(concat(ddr_domain_data->src_tmp_full_dir,
     ddr_domain_data->src_env,"_tdb.txt"))
   SET dm_err->eproc = concat("Remove:",dgt_tdb_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dgt_tdb_file) > 0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(dm2_sys_misc
       ->cur_os,"AXP",concat(dgt_tdb_file,dgt_suffix),dgt_tdb_file)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (get_unique_file("get_tdb",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dgt_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to obtain TDB info:",dgt_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dgt_file)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("mcr cer_exe:tdbview system"), row + 1,
      CALL print("$DECK"),
      row + 1
     ELSE
      IF (dgt_src_ind=1)
       CALL print(concat("src_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1
      ELSE
       CALL print(concat("tgt_mng_pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1
      ENDIF
      CALL print("$cer_exe/tdbview system <<!"), row + 1
     ENDIF
     IF (dgt_src_ind=1)
      CALL print(ddr_domain_data->src_mng), row + 1,
      CALL print(ddr_domain_data->src_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->src_mng_pwd), row + 1
      ELSE
       CALL print("$src_mng_pwd"), row + 1
      ENDIF
      CALL print(concat("export * ",ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,
       "_tdb.msg")), row + 1
     ELSE
      CALL print(ddr_domain_data->tgt_mng), row + 1,
      CALL print(ddr_domain_data->tgt_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->tgt_mng_pwd), row + 1
      ELSE
       CALL print("$tgt_mng_pwd"), row + 1
      ENDIF
      CALL print(concat("export * ",ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
       "_tdb.msg")), row + 1
     ENDIF
     CALL print("exit"), row + 1
     IF ((dm2_sys_misc->cur_os != "AXP"))
      CALL print("!"), row + 1
     ELSE
      CALL print("$EOD"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain TDB export."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgt_cmd = concat("@",dgt_file)
   ELSE
    SET dgt_cmd = concat(". $CCLUSERDIR/",dgt_file)
   ENDIF
   IF (dm2_push_dcl(dgt_cmd)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   SET dm_err->errtext = replace(dm_err->errtext,"Transaction Database (TDB) Viewer","",0)
   IF (size(dm_err->errtext) > 0)
    SET dm_err->emsg = concat("Error exporting TDB:",dm_err->errtext)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dgt_tdb_file)=0)
    SET dm_err->emsg = concat("Error exporting TDB. TDB export does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (ddr_get_file_date(dgt_tdb_file,dgt_file_date)=0)
    RETURN(0)
   ENDIF
   IF (dgt_src_ind=1)
    SET ddr_domain_data->src_tdb_ts = dgt_file_date
    SET ddr_domain_data->src_tdb_fnd = 1
   ELSE
    SET ddr_domain_data->tgt_tdb_ts = dgt_file_date
    SET ddr_domain_data->tgt_tdb_fnd = 1
   ENDIF
   IF (dgt_src_ind=1)
    IF (get_unique_file("get_src_tdb_cnt",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
     RETURN(0)
    ELSE
     SET dgt_file = dm_err->unique_fname
    ENDIF
    SET dm_err->eproc = concat("Create file to obtain Source TDB count:",dgt_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO value(dgt_file)
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$define/user_mode sys$output ",dgt_cnt_file)), row + 1,
       CALL print("$mcr cer_exe:tdbview system"),
       row + 1,
       CALL print("$DECK"), row + 1
      ELSE
       CALL print(concat("src_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1,
       CALL print(concat("$cer_exe/tdbview system <<!>",dgt_cnt_file)),
       row + 1
      ENDIF
      CALL print(ddr_domain_data->src_mng), row + 1,
      CALL print(ddr_domain_data->src_domain_name),
      row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(ddr_domain_data->src_mng_pwd), row + 1
      ELSE
       CALL print("$src_mng_pwd"), row + 1
      ENDIF
      CALL print("dir"), row + 1,
      CALL print("exit"),
      row + 1
      IF ((dm2_sys_misc->cur_os != "AXP"))
       CALL print("!"), row + 1
      ELSE
       CALL print("$EOD"), row + 1
      ENDIF
     WITH nocounter, maxcol = 500, format = variable,
      maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Obtain Source TDB count."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgt_cmd = concat("@",dgt_file)
    ELSE
     SET dgt_cmd = concat(". $CCLUSERDIR/",dgt_file)
    ENDIF
    IF (dm2_push_dcl(dgt_cmd)=0)
     RETURN(0)
    ENDIF
    IF (ddr_parse_count(dgt_cnt_file,dgt_tdb_count)=0)
     RETURN(0)
    ENDIF
    IF (dgt_tdb_count < 10)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Source TDB count is less than 10."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_tdb_count = dgt_tdb_count
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_parse_count(dpc_file_name,dpc_count)
   SET dm_err->eproc = concat("Parse out count from file ",dpc_file_name)
   CALL disp_msg("",dm_err->logfile,0)
   SET dpc_count = 0
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dpc_file_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     first_char = ""
    DETAIL
     first_char = ""
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("LINE = ",r.line))
     ENDIF
     first_char = substring(1,1,r.line)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("first_char=",first_char))
     ENDIF
     IF (((cnvtint(first_char) > 0) OR (first_char="0")) )
      dpc_count = (dpc_count+ 1)
     ENDIF
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_dicdat(dgd_src_ind,dgd_tgt_ind)
   DECLARE dgd_file_str = vc WITH protect, noconstant("")
   DECLARE dgd_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dgd_cerinstall = vc WITH protect, noconstant(trim(logical("cer_install")))
   DECLARE dgd_str = vc WITH protect, noconstant("")
   SET dgd_file_str = concat(dgd_cerinstall,evaluate(dm2_sys_misc->cur_os,"AXP","dm_dict.dat;*",
     "/dm_dict.dat"))
   SET dm_err->eproc = concat("Remove:",dgd_file_str)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dgd_file_str) > 0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgd_file_str))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET dgd_file_str = concat(dgd_cerinstall,"/","dm_dict.idx")
    SET dm_err->eproc = concat("Remove:",dgd_file_str)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF (dm2_findfile(dgd_file_str) > 0)
     IF (dm2_push_dcl(concat("rm ",dgd_file_str))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dgd_file_str = concat(evaluate(dgd_src_ind,1,ddr_domain_data->src_tmp_full_dir,ddr_domain_data
     ->tgt_tmp_full_dir),evaluate(dm2_sys_misc->cur_os,"AXP","dic.dat;*","dic.dat"))
   SET dm_err->eproc = concat("Remove:",dgd_file_str)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dgd_file_str) > 0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",dgd_file_str))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET dgd_file_str = concat(evaluate(dgd_src_ind,1,ddr_domain_data->src_tmp_full_dir,
      ddr_domain_data->tgt_tmp_full_dir),"dic.idx")
    SET dm_err->eproc = concat("Remove:",dgd_file_str)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF (dm2_findfile(dgd_file_str) > 0)
     IF (dm2_push_dcl(concat("rm ",dgd_file_str))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = "Create copy of dictionary using DM_CREATE_A_DICTIONARY"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   EXECUTE dm_create_a_dictionary
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgd_file_str = concat(dgd_cerinstall,evaluate(dm2_sys_misc->cur_os,"AXP","dm_dict.dat",
     "/dm_dict.dat"))
   IF (dm2_findfile(dgd_file_str)=0)
    SET dm_err->emsg = concat(
     "Error creating copy of SOURCE dictionary. Dictionary copy does not exist.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgd_file_str = concat(dgd_cerinstall,evaluate(dm2_sys_misc->cur_os,"AXP","dm_dict.dat",
     "/dm_dict.dat"))
   SET dgd_str = concat(evaluate(dm2_sys_misc->cur_os,"AXP","rename","mv")," ",dgd_file_str," ",
    dgd_cerinstall,
    evaluate(dm2_sys_misc->cur_os,"AXP","dic.dat","/dic.dat"))
   IF (dm2_push_dcl(dgd_str)=0)
    RETURN(0)
   ENDIF
   SET dgd_file_str = concat(dgd_cerinstall,evaluate(dm2_sys_misc->cur_os,"AXP","dm_dict.idx",
     "/dm_dict.idx"))
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET dgd_str = concat("mv ",dgd_file_str," ",dgd_cerinstall,"/dic.idx")
    IF (dm2_push_dcl(dgd_str)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dgd_file_str = concat(dgd_cerinstall,evaluate(dm2_sys_misc->cur_os,"AXP","dic.dat","/dic.dat")
    )
   IF (ddr_get_file_date(dgd_file_str,dgd_file_date)=0)
    RETURN(0)
   ENDIF
   IF (dgd_src_ind=1)
    SET ddr_domain_data->src_dict_ts = dgd_file_date
    SET ddr_domain_data->src_dict_fnd = 1
   ELSE
    SET ddr_domain_data->tgt_dict_ts = dgd_file_date
    SET ddr_domain_data->tgt_dict_fnd = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_prompt_node_names(dpnn_src_ind,dpnn_tgt_ind)
   DECLARE dpnn_rows_max = i4 WITH protect, constant(23)
   DECLARE dpnn_col_max = i4 WITH protect, constant(80)
   DECLARE dpnn_node_list = vc WITH protect, noconstant("")
   DECLARE dpnn_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpnn_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpnn_col_num = i4 WITH protect, noconstant(2)
   DECLARE dpnn_length = i4 WITH protect, noconstant(0)
   DECLARE dpnn_exit = i2 WITH protect, noconstant(0)
   DECLARE dpnn_ndx = i2 WITH protect, noconstant(0)
   DECLARE dpnn_accept = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Node name confirmation"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   FREE RECORD dpnn_work
   RECORD dpnn_work(
     1 nodes_cnt = i4
     1 nodes[*]
       2 keep = i2
       2 node_name = vc
   )
   IF (dpnn_src_ind=1)
    SET dpnn_work->nodes_cnt = ddr_domain_data->src_nodes_cnt
   ELSE
    SET dpnn_work->nodes_cnt = ddr_domain_data->tgt_nodes_cnt
   ENDIF
   SET stat = alterlist(dpnn_work->nodes,dpnn_work->nodes_cnt)
   FOR (dpnn_ndx = 1 TO dpnn_work->nodes_cnt)
    IF (dpnn_src_ind=1)
     SET dpnn_work->nodes[dpnn_ndx].node_name = ddr_domain_data->src_nodes[dpnn_ndx].node_name
    ELSE
     SET dpnn_work->nodes[dpnn_ndx].node_name = ddr_domain_data->tgt_nodes[dpnn_ndx].node_name
    ENDIF
    SET dpnn_work->nodes[dpnn_ndx].keep = 1
   ENDFOR
   IF ((dm_err->debug_flag != 722))
    SET message = window
   ENDIF
   SET width = 132
   CALL clear(1,1)
   CALL clear(1,1)
   CALL box(1,1,22,131)
   CALL text(1,dpnn_col_num,"APPLICATION NODE CONFIRMATION SCREEN ")
   CALL text(3,dpnn_col_num,concat("Are the following nodes correct for environment: ",evaluate(
      dpnn_src_ind,1,ddr_domain_data->src_env,ddr_domain_data->tgt_env),"?"))
   CALL text(7,dpnn_col_num,concat(evaluate(dpnn_src_ind,1,"SOURCE","TARGET"),
     " Application Nodes Obtained from SCP: "))
   SET dpnn_node_list = ""
   FOR (dpnn_cnt = 1 TO dpnn_work->nodes_cnt)
     IF ((dpnn_work->nodes_cnt > 1)
      AND dpnn_cnt != 1)
      SET dpnn_node_list = concat(dpnn_node_list,", ",dpnn_work->nodes[dpnn_cnt].node_name)
     ELSE
      SET dpnn_node_list = dpnn_work->nodes[dpnn_cnt].node_name
     ENDIF
   ENDFOR
   SET dpnn_cnt = 0
   SET dpnn_row_cnt = 9
   WHILE (dpnn_cnt < size(dpnn_node_list)
    AND dpnn_row_cnt < dpnn_rows_max)
     CALL clear(dpnn_row_cnt,dpnn_col_num,129)
     IF (size(dpnn_node_list) < dpnn_col_max)
      CALL text(dpnn_row_cnt,(dpnn_col_num+ 2),trim(substring((dpnn_cnt+ 1),dpnn_col_max,
         dpnn_node_list)))
      SET dpnn_length = dpnn_col_max
     ELSE
      SET dpnn_length = findstring(",",substring((dpnn_cnt+ 1),dpnn_col_max,dpnn_node_list),(dpnn_cnt
       + 1),1)
      IF (dpnn_length=0)
       SET dpnn_length = dpnn_col_max
      ENDIF
      CALL text(dpnn_row_cnt,(dpnn_col_num+ 2),trim(substring((dpnn_cnt+ 1),dpnn_length,
         dpnn_node_list)))
     ENDIF
     SET dpnn_cnt = (dpnn_cnt+ dpnn_length)
     SET dpnn_row_cnt = (dpnn_row_cnt+ 1)
   ENDWHILE
   CALL text(5,dpnn_col_num,"(Y)es,(N)o,(Q)uit?")
   CALL accept(5,(21+ dpnn_col_num),"A;cu"," "
    WHERE curaccept IN ("Y", "N", "Q"))
   SET dpnn_accept = curaccept
   CALL clear(1,1)
   SET message = nowindow
   IF (dpnn_accept="Q")
    SET dm_err->emsg = "User elected to quit from Application Node entry"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dpnn_accept="N")
    SET dm_err->emsg = concat("User entered that nodes obtained from SCP were not correct for ",
     evaluate(dpnn_src_ind,1,ddr_domain_data->src_env,ddr_domain_data->tgt_env))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_new_source_data(null)
   DECLARE dgnsd_grants_file = vc WITH protect, noconstant(concat(ddr_domain_data->src_tmp_full_dir,
     ddr_domain_data->src_env,"_ccl_grants.txt"))
   DECLARE dgnsd_interrogator_ind = i2 WITH protect, noconstant(0)
   DECLARE dgnsd_interrogator_node = vc WITH protect, noconstant("")
   DECLARE dgnsd_utc_mock_db_name = vc WITH protect, noconstant("")
   DECLARE dgnsd_tgt_db_name = vc WITH protect, noconstant("")
   DECLARE dgnsd_idx = i4 WITH protect, noconstant(0)
   DECLARE dgnsd_invalid_cm_ind = i2 WITH protect, noconstant(0)
   DECLARE dgnsd_invalid_cust_user_ind = i2 WITH protect, noconstant(0)
   DECLARE dgnsd_invalid_dt_data_ind = i2 WITH protect, noconstant(0)
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dm2_install_schema->src_v500_p_word = drrr_rf_data->src_db_user_pwd
    SET dm2_install_schema->src_v500_connect_str = drrr_rf_data->src_db_cnct_str
    SET ddr_domain_data->src_env = trim(cnvtlower(drrr_rf_data->src_env_name))
    SET ddr_domain_data->src_mng = drrr_rf_data->src_high_priv_user
    SET ddr_domain_data->src_mng_pwd = drrr_rf_data->src_high_priv_user_pwd
   ENDIF
   IF ((dm2_install_schema->src_v500_p_word="NONE"))
    SET dm2_install_schema->dbase_name = "SOURCE"
    SET dm2_install_schema->u_name = "V500"
    EXECUTE dm2_connect_to_dbase "PC"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
   ENDIF
   SET dm2_install_schema->dbase_name = currdbname
   SELECT INTO "nl:"
    FROM dm_environment de,
     dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_ENV_ID"
     AND de.environment_id=d.info_number
    DETAIL
     ddr_domain_data->src_db_env_name = trim(cnvtlower(de.environment_name))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = "Could not obtain environment name"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF (ddr_val_client_mnemonic(1,0,0,dgnsd_invalid_cm_ind)=0)
     RETURN(0)
    ENDIF
    IF (drr_verify_custom_users(0,dgnsd_invalid_cust_user_ind)=0)
     RETURN(0)
    ENDIF
    IF (drr_verify_admin_content(0,dgnsd_invalid_dt_data_ind)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_get_misc_data(1,0)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_nodes(1,0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if UTC migration is in progress"
   IF (validate(dm2_mig_utc_status,"-1")="-1")
    DECLARE dm2_mig_utc_status = vc WITH protect, noconstant("")
   ENDIF
   EXECUTE dm2_mig_status_check
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (cnvtupper(dm2_mig_utc_status)="ERROR")
    SET dm_err->eproc = "Check UTC migration status."
    SET dm_err->emsg = "Unexpected error occurred in DM2_MIG_STATUS_CHECK"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(dm2_mig_utc_status)="ON")
    SET dm_err->eproc = "Checking for Mock database name."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_MIG_UTC_MOCK_DB_NAME"
     DETAIL
      dgnsd_utc_mock_db_name = cnvtupper(trim(d.info_name))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Checking if UTC Migration in process."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_RR_UTC_MIG_INFLIGHT_CHK"
      AND d.info_name="BYPASS_CHECK"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dm_err->eproc =
     "Bypassing UTC Migration-in-process check due to replicate/refresh bypass override."
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     IF (validate(drrr_responsefile_in_use,0)=1)
      SET dgnsd_tgt_db_name = cnvtupper(trim(drrr_rf_data->tgt_db_name))
     ELSE
      SET message = window
      SET width = 132
      CALL clear(1,1)
      CALL box(1,1,5,131)
      CALL text(3,8,"Please enter the TARGET database name: ")
      CALL accept(3,48,"P(10);CU"," "
       WHERE curaccept > " ")
      SET dgnsd_tgt_db_name = cnvtupper(trim(curaccept))
      SET message = nowindow
      CALL clear(1,1)
     ENDIF
     IF (dgnsd_tgt_db_name != dgnsd_utc_mock_db_name)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("UTC migration is in progress. This process cannot continue.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET dm_err->eproc = concat("Bypassing UTC Migration-in-process because ",dgnsd_utc_mock_db_name,
       " is a mock db.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ENDIF
   IF ((ddr_domain_data->src_interrogator_ind=1))
    IF (ddr_interrogator_usage(dgnsd_interrogator_ind,dgnsd_interrogator_node)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_domain_data->src_interrogator_ind != dgnsd_interrogator_ind))
     SET dm_err->err_ind = 1
     SET dm_err->eproc =
     "Determine Interrogator Server #520 is running on source application node(s)"
     IF ((dgnsd_interrogator_ind > ddr_domain_data->src_interrogator_ind))
      SET dm_err->emsg = concat(
       "Interrogator Solution(server 520) is running on More than one Source APP nodes ")
     ELSE
      SET dm_err->emsg = concat("Interrogator Solution not enabled (server 520 not running on any ",
       "application node) but response file chose to copy Interrogator Solution")
     ENDIF
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_interrogator_node = dgnsd_interrogator_node
   ENDIF
   IF (validate(dm2_bypass_space_needs_calc,0)=0
    AND (validate(dm2_bypass_space_needs_calc,- (1))=- (1)))
    IF (ddr_data_collection_space_needs(1,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_get_invalid_tbls(1,0,1)=0)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dm_err->eproc = "Using response file - bypassing source node list validation."
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    IF (ddr_prompt_node_names(1,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_cleanup_opsexec_mapping(null)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_opsexec_servers(1,0,1)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_dicdat(1,0)=0)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->get_warehouse = 1
   IF ((ddr_domain_data->get_warehouse=1))
    IF (ddr_get_wh(1,0,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_get_ocdtools(null)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_ccldir(null)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_config(null)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_tdb(1,0)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_srv_def(1,0)=0)
    RETURN(0)
   ENDIF
   IF ((ddr_domain_data->src_was_arch_ind=0))
    IF (ddr_get_sec_user(1,0,0)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Using WAS Architecture - bypassing copy of source sec user."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (ddr_get_env_reg(1,0,"DEFINITION",0)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_env_reg(1,0,"SYSTEM_DEFINITIONS",0)=0)
    RETURN(0)
   ENDIF
   IF ((ddr_domain_data->get_invalid_tables=1))
    IF (ddr_get_invalid_tbls(1,0,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    IF (ddr_get_link_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_get_adm_env(null)=0)
    RETURN(0)
   ENDIF
   SET decg_export_fname = dgnsd_grants_file
   EXECUTE dm2_export_ccl_grants
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dgnsd_grants_file) > 0)
    SET ddr_domain_data->src_ccl_grants_ind = 1
   ENDIF
   IF ((ddr_domain_data->src_interrogator_ind=1))
    IF (ddr_interrogator_backup("BACKUP")=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_backup_file_content_load(1,0)=0)
    RETURN(0)
   ENDIF
   IF ((ddr_backup_file_content->src_backup_list_cnt > 0))
    FOR (dgnsd_idx = 1 TO ddr_backup_file_content->src_backup_list_cnt)
      IF (ddr_backup_file_content(ddr_backup_file_content->src_backup_list[dgnsd_idx].mode,
       ddr_backup_file_content->src_backup_list[dgnsd_idx].fdir,ddr_backup_file_content->
       src_backup_list[dgnsd_idx].fvalue,ddr_backup_file_content->src_backup_list[dgnsd_idx].dest_dir,
       ddr_backup_file_content->src_backup_list[dgnsd_idx].dest_fname,
       ddr_backup_file_content->src_backup_list[dgnsd_idx].options,ddr_backup_file_content->
       src_backup_list[dgnsd_idx].req_ind)=0)
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   IF (ddr_write_misc_data(1,0)=0)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF (drr_add_default_scd_row(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_summary(1,0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_new_target_data(null)
   DECLARE dgntd_src_was_arch_ind = i2 WITH protect, noconstant(0)
   DECLARE dgntd_src_ora_ver = i2 WITH protect, noconstant(0)
   DECLARE dgntd_src_characterset = vc WITH protect, noconstant("")
   DECLARE dgntd_tgt_characterset = vc WITH protect, noconstant("")
   DECLARE dgntd_grants_file = vc WITH protect, noconstant(concat(ddr_domain_data->tgt_tmp_full_dir,
     ddr_domain_data->tgt_env,"_ccl_grants.txt"))
   DECLARE dgntd_utc_ind = i2 WITH protect, noconstant(0)
   DECLARE dgntd_date_mode = vc WITH protect, noconstant("")
   DECLARE dgntd_part_enabled_ind = i2 WITH protect, noconstant(0)
   DECLARE dgntd_part_usage_ind = i2 WITH protect, noconstant(0)
   DECLARE dgntd_idx = i4 WITH protect, noconstant(0)
   DECLARE dgntd_invalid_cm_ind = i2 WITH protect, noconstant(0)
   DECLARE dgntd_invalid_dt_data_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get [new] target data."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((ddr_domain_data->process="REPLICATE"))
    IF (ddr_get_misc_data(0,1)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_tgt_node_flag(null)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_env_reg(0,1,"DEFINITION",0)=0)
     RETURN(0)
    ENDIF
    IF (ddr_write_misc_data(0,1)=0)
     RETURN(0)
    ENDIF
   ELSEIF ((ddr_domain_data->process="REFRESH"))
    IF (validate(drrr_responsefile_in_use,0)=1)
     IF (ddr_val_client_mnemonic(0,1,0,dgntd_invalid_cm_ind)=0)
      RETURN(0)
     ENDIF
     IF (drr_verify_admin_content(0,dgntd_invalid_dt_data_ind)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm2_install_schema->src_v500_p_word = drrr_rf_data->src_db_user_pwd
     SET dm2_install_schema->src_v500_connect_str = drrr_rf_data->src_db_cnct_str
     SET ddr_domain_data->src_domain_name = drrr_rf_data->src_domain_name
    ENDIF
    SET dm2_install_schema->dbase_name = '"SOURCE"'
    SET dm2_install_schema->u_name = "V500"
    IF ((dm2_install_schema->src_v500_p_word != "NONE")
     AND (dm2_install_schema->src_v500_connect_str != "NONE"))
     SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     SET dm2_force_connect_string = 1
     EXECUTE dm2_connect_to_dbase "PC"
     SET dm2_force_connect_string = 0
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
    ENDIF
    IF ((((ddr_domain_data->src_domain_name="")) OR ((ddr_domain_data->src_domain_name="DM2NOTSET")
    )) )
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,5,131)
     CALL text(3,8,"Please enter the SOURCE domain: ")
     CALL accept(3,40,"P(30);CU"," "
      WHERE curaccept > " ")
     SET ddr_domain_data->src_domain_name = cnvtlower(curaccept)
     SET message = nowindow
     CALL clear(1,1)
    ENDIF
    IF ((validate(dm2_bypass_was_check,- (1))=- (1)))
     IF (drr_identify_was_usage(ddr_domain_data->src_domain_name,dgntd_src_was_arch_ind)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->src_was_arch_ind = dgntd_src_was_arch_ind
    ENDIF
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dgntd_src_ora_ver = dm2_rdbms_version->level1
    SET dm_err->eproc = "Determining SOURCE character set from v$nls_parameters."
    SELECT INTO "nl:"
     FROM v$nls_parameters vnp
     WHERE vnp.parameter="NLS_CHARACTERSET"
     DETAIL
      dgntd_src_characterset = vnp.value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Check if source has gone through UTC conversion."
    SELECT INTO "nl:"
     FROM dm2_ddl_ops
     WHERE process_option IN ("UTC CONVERSION UPTIME", "UTC CONVERSION DOWNTIME")
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dgntd_utc_ind = 1
    ENDIF
    IF (dgntd_utc_ind=0)
     SET dm_err->eproc = "Check if UTC migration is in progress"
     IF (validate(dm2_mig_utc_status,"-1")="-1")
      DECLARE dm2_mig_utc_status = vc WITH protect, noconstant("")
     ENDIF
     EXECUTE dm2_mig_status_check
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF (cnvtupper(dm2_mig_utc_status)="ERROR")
      SET dm_err->eproc = "Check UTC migration status."
      SET dm_err->emsg = "Unexpected error occurred in DM2_MIG_STATUS_CHECK"
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (cnvtupper(dm2_mig_utc_status)="ON")
      SET dgntd_utc_ind = 1
     ENDIF
    ENDIF
    SET dm_err->eproc =
    "Check if source has partitioning option enabled and has partitioned objects."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dpr_identify_partition_usage(1,dgntd_part_enabled_ind,dgntd_part_usage_ind)=0)
     RETURN(0)
    ENDIF
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET dm2_install_schema->v500_p_word = drrr_rf_data->tgt_db_user_pwd
     SET dm2_install_schema->v500_connect_str = drrr_rf_data->tgt_db_cnct_str
     SET ddr_domain_data->tgt_env = trim(cnvtlower(drrr_rf_data->tgt_env_name))
     SET ddr_domain_data->tgt_mng = drrr_rf_data->tgt_high_priv_user
     SET ddr_domain_data->tgt_mng_pwd = drrr_rf_data->tgt_high_priv_user_pwd
    ENDIF
    IF ((((dm2_install_schema->v500_p_word="NONE")) OR ((dm2_install_schema->v500_connect_str="NONE")
    )) )
     SET dm2_install_schema->dbase_name = "TARGET"
     SET dm2_install_schema->u_name = "V500"
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
    ELSE
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    SET dm2_install_schema->dbase_name = currdbname
    SET dm2_install_schema->target_dbase_name = currdbname
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Determining TARGET character set from v$nls_parameters."
    SELECT INTO "nl:"
     FROM v$nls_parameters vnp
     WHERE vnp.parameter="NLS_CHARACTERSET"
     DETAIL
      dgntd_tgt_characterset = vnp.value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (validate(dm2_bypass_oraver_check,- (1)) != 1)
     IF (validate(drrr_rf_data->tgt_db_copy_type,"DM2NOTSET")="ALTERNATE"
      AND validate(drrr_rf_data->target_refresh,"DM2NOTSET")="YES"
      AND (((dgntd_src_ora_ver < dm2_rdbms_version->level1)) OR ((dgntd_src_ora_ver >
     dm2_rdbms_version->level1)
      AND ((dgntd_src_ora_ver != 19) OR ((dm2_rdbms_version->level1 != 11))) )) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Cross Oracle refresh versions (high-level) compare."
      SET dm_err->emsg = concat("Target Oracle version (",trim(cnvtstring(dm2_rdbms_version->level1)),
       ") and Source Oracle version (",trim(cnvtstring(dgntd_src_ora_ver)),
       ") are not valid for Cross Oracle Refresh.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (((validate(drrr_rf_data->tgt_db_copy_type,"DM2NOTSET") != "ALTERNATE") OR (validate(
      drrr_rf_data->target_refresh,"DM2NOTSET") != "YES"))
      AND (dm2_rdbms_version->level1 != dgntd_src_ora_ver))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verify Target and Source Oracle versions (high-level) match."
      SET dm_err->emsg = concat("Target Oracle version (",trim(cnvtstring(dm2_rdbms_version->level1)),
       ") does not match Source Oracle version (",trim(cnvtstring(dgntd_src_ora_ver)),").")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dgntd_tgt_characterset != dgntd_src_characterset
     AND validate(dm2_bypass_charset_check,- (1)) != 1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verify Target and Source Characterset match."
     SET dm_err->emsg = concat("Target Characterset (",trim(dgntd_tgt_characterset),
      ") does not match Source Characterset (",trim(dgntd_src_characterset),").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgntd_utc_ind=1)
     SET dgntd_date_mode = trim(logical("DATE_MODE"))
     IF (cnvtupper(dgntd_date_mode) != "UTC")
      SET dm_err->eproc = "Checking if UTC Migration in process."
      SELECT INTO "nl:"
       FROM dm_info d
       WHERE d.info_domain="DM2_RR_UTC_MATCH_CHK"
        AND d.info_name="BYPASS_CHECK"
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      IF (curqual > 0)
       SET dm_err->eproc = "Bypassing UTC conversion check due to replicate/refresh bypass override."
       CALL disp_msg("",dm_err->logfile,0)
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat(
        "Source is going through or has completed a UTC Conversion while Target remains a local domain. ",
        "This process cannot continue.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
    IF (dgntd_part_usage_ind=1)
     SET dm_err->eproc = "Check if target partitioning option is enabled."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dpr_identify_partition_usage(0,dgntd_part_enabled_ind,dgntd_part_usage_ind)=0)
      RETURN(0)
     ENDIF
     IF (dgntd_part_enabled_ind=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(
       "Target partitioning option (v$option) is disabled and Source has partitioned objects. ",
       "Partitioning must be enabled in Target to proceed.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_get_misc_data(0,1)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_domain_data->tgt_was_arch_ind != ddr_domain_data->src_was_arch_ind))
     SET dm_err->eproc = concat("WAS Security Architecture different between Source and Target.",
      "The refresh process will use Source Security Architecture when setting up Target.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (validate(dm2_bypass_space_needs_calc,0)=0
     AND (validate(dm2_bypass_space_needs_calc,- (1))=- (1)))
     IF (ddr_data_collection_space_needs(0,1)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_prompt_tgt_backups(null)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_nodes(0,1)=0)
     RETURN(0)
    ENDIF
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET dm_err->eproc = "Using response file - bypassing source node list validation."
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     IF (ddr_prompt_node_names(0,1)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_set_tgt_node_flag(null)=0)
     RETURN(0)
    ENDIF
    IF (ddr_cleanup_opsexec_mapping(null)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_opsexec_servers(0,1,1)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_domain_data->tgt_node_flag=3))
     IF (ddr_backup_servers(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET dm_err->eproc = "Using response file - bypassing ccluserdir backup prompt."
     CALL disp_msg(" ",dm_err->logfile,0)
     SET ddr_domain_data->get_ccluserdir = evaluate(drrr_rf_data->tgt_backup_ccluserdir,"YES",1,0)
    ELSE
     IF (ddr_get_ccluserdir(1)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET dm_err->eproc = "Using response file - bypassing warehouse backup prompt."
     CALL disp_msg(" ",dm_err->logfile,0)
     SET ddr_domain_data->get_warehouse = evaluate(drrr_rf_data->tgt_backup_warehouse,"YES",1,0)
    ELSE
     IF (ddr_get_wh(0,1,1)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((ddr_domain_data->get_warehouse=1))
     IF (ddr_get_wh(0,1,0)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((ddr_domain_data->get_ccluserdir=1))
     IF (ddr_get_ccluserdir(0)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_get_tdb(0,1)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_srv_def(0,1)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_domain_data->tgt_was_arch_ind=0))
     IF (ddr_get_sec_user(0,1,0)=0)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = "Using WAS Architecture - bypassing copy of target sec user."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (ddr_get_env_reg(0,1,"DEFINITION",0)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_env_reg(0,1,"SYSTEM_DEFINITIONS",0)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_env_reg(0,1,"SYSTEM",0)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_sys_misc->cur_os != "AXP"))
     IF (ddr_get_cerforms(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_get_ccldbas(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX")))
     IF (ddr_get_users(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_get_dicdat(0,1)=0)
     RETURN(0)
    ENDIF
    IF ((((ddr_domain_data->preserve_ind=1)) OR ((ddr_domain_data->preserve_user_ind=1))) )
     IF (ddr_get_preserved_data(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    EXECUTE dm2_repl_preserve_pwds
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (ddr_validate_preserve_pwds(null)=0)
     RETURN(0)
    ENDIF
    SET decg_export_fname = dgntd_grants_file
    EXECUTE dm2_export_ccl_grants
    IF ((dm_err->err_ind > 0))
     RETURN(0)
    ENDIF
    IF (dm2_findfile(dgntd_grants_file) > 0)
     SET ddr_domain_data->tgt_ccl_grants_ind = 1
    ENDIF
    IF (ddr_backup_file_content_load(0,1)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_backup_file_content->tgt_backup_list_cnt > 0))
     FOR (dgntd_idx = 1 TO ddr_backup_file_content->tgt_backup_list_cnt)
       IF (ddr_backup_file_content(ddr_backup_file_content->tgt_backup_list[dgntd_idx].mode,
        ddr_backup_file_content->tgt_backup_list[dgntd_idx].fdir,ddr_backup_file_content->
        tgt_backup_list[dgntd_idx].fvalue,ddr_backup_file_content->tgt_backup_list[dgntd_idx].
        dest_dir,ddr_backup_file_content->tgt_backup_list[dgntd_idx].dest_fname,
        ddr_backup_file_content->tgt_backup_list[dgntd_idx].options,ddr_backup_file_content->
        tgt_backup_list[dgntd_idx].req_ind)=0)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
    IF (ddr_backup_reg_content_load(null)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_backup_reg_content->tgt_backup_list_cnt > 0))
     FOR (dgntd_idx = 1 TO ddr_backup_reg_content->tgt_backup_list_cnt)
       IF (ddr_backup_reg_content(ddr_backup_reg_content->tgt_backup_list[dgntd_idx].mode,
        ddr_backup_reg_content->tgt_backup_list[dgntd_idx].key,ddr_backup_reg_content->
        tgt_backup_list[dgntd_idx].prop,ddr_backup_reg_content->tgt_backup_list[dgntd_idx].dest_dir,
        ddr_backup_reg_content->tgt_backup_list[dgntd_idx].dest_fname,
        ddr_backup_reg_content->tgt_backup_list[dgntd_idx].req_ind,ddr_backup_reg_content->
        tgt_backup_list[dgntd_idx].cre_key_ind)=0)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
    IF (ddr_backup_srvreg_content_load(null)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_backup_srvreg_content->tgt_backup_list_cnt > 0))
     FOR (dgntd_idx = 1 TO ddr_backup_srvreg_content->tgt_backup_list_cnt)
       IF (ddr_backup_srvreg_content(ddr_backup_srvreg_content->tgt_backup_list[dgntd_idx].mode,
        ddr_backup_srvreg_content->tgt_backup_list[dgntd_idx].entry,ddr_backup_srvreg_content->
        tgt_backup_list[dgntd_idx].dest_dir,ddr_backup_srvreg_content->tgt_backup_list[dgntd_idx].
        dest_fname,ddr_backup_srvreg_content->tgt_backup_list[dgntd_idx].options,
        ddr_backup_srvreg_content->tgt_backup_list[dgntd_idx].req_ind)=0)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
    IF (ddr_write_misc_data(0,1)=0)
     RETURN(0)
    ENDIF
    IF (ddr_summary(0,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_file_date(dgfd_file_name,dgfd_file_date)
   DECLARE dgfd_cmd = vc WITH protect, noconstant("")
   DECLARE dgfd_dir_ret_file = vc WITH protect, noconstant("")
   DECLARE dgfd_date_str = vc WITH protect, noconstant("")
   DECLARE dgfd_name_cut = vc WITH protect, noconstant("")
   DECLARE dgfd_delim = vc WITH protect, noconstant(evaluate(dm2_sys_misc->cur_os,"AXP","]","/"))
   IF (findstring(dgfd_delim,dgfd_file_name,1,1) > 0)
    SET dgfd_name_cut = substring((findstring(dgfd_delim,dgfd_file_name,1,1)+ 1),(size(dgfd_file_name
      ) - findstring(dgfd_delim,dgfd_file_name,1,1)),dgfd_file_name)
   ELSEIF ((dm2_sys_misc->cur_os="AXP")
    AND findstring(":",dgfd_file_name,1,1) > 0)
    SET dgfd_name_cut = substring((findstring(":",dgfd_file_name,1,1)+ 1),(size(dgfd_file_name) -
     findstring(":",dgfd_file_name,1,1)),dgfd_file_name)
   ELSE
    SET dgfd_name_cut = dgfd_file_name
   ENDIF
   SET dm_err->eproc = concat("Check if ",dgfd_file_name," exists.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF (dm2_findfile(dgfd_file_name)=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "File does not exist. Unable to obtain date."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    IF (ddr_lnx_findfile(dgfd_file_name)=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "File does not exist. Unable to obtain date."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (get_unique_file("chkdate",".dat")=0)
    RETURN(0)
   ELSE
    SET dgfd_dir_ret_file = dm_err->unique_fname
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dm_err->eproc = concat("Pipe dir into ",dgfd_dir_ret_file," to later get date of file.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET dgfd_cmd = concat("pipe dir/date ",dgfd_file_name," > ",dgfd_dir_ret_file)
    CALL dcl(dgfd_cmd,size(dgfd_cmd),dm_err->ecode)
    IF ((dm_err->ecode=0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("ERROR Executing ",dgfd_cmd)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Pipe list into ",dgfd_dir_ret_file," to later get date of file.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET dgfd_cmd = concat("ls -lt ",dgfd_file_name," | awk '{print $6,$7,$8}' > ",dgfd_dir_ret_file)
    CALL dcl(dgfd_cmd,size(dgfd_cmd),dm_err->ecode)
    IF ((dm_err->ecode=0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("ERROR Executing ",dgfd_cmd)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgfd_name_cut = replace(dgfd_name_cut,"*.*;*","",0)
   ELSE
    SET dgfd_name_cut = replace(dgfd_name_cut,"*.dmp","",0)
   ENDIF
   SET dm_err->eproc = concat("Open ",dgfd_dir_ret_file," to parse date.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dgfd_data_file dgfd_dir_ret_file
   FREE DEFINE rtl
   DEFINE rtl "dgfd_data_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    HEAD REPORT
     dgfd_date_str = "x"
    DETAIL
     IF ((dm_err->debug_flag > 2))
      CALL echo(t.line)
     ENDIF
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (dgfd_date_str="")
       IF (findstring("-",t.line,1,0) > 0)
        dgfd_date_str = substring((findstring("-",t.line,1,0) - 2),(findstring(".",t.line,1,1)+ 2),t
         .line)
       ENDIF
      ELSE
       IF (findstring(cnvtupper(dgfd_name_cut),cnvtupper(t.line),1,1) > 0)
        IF (findstring("-",t.line,1,0) > 0)
         dgfd_date_str = substring((findstring("-",t.line,1,0) - 2),(findstring(".",t.line,1,1)+ 2),t
          .line)
        ELSE
         dgfd_date_str = ""
        ENDIF
       ENDIF
      ENDIF
     ELSE
      IF (dgfd_date_str="x")
       CASE (cnvtupper(substring(1,3,t.line)))
        OF "JAN":
         xmonth = 1
        OF "FEB":
         xmonth = 2
        OF "MAR":
         xmonth = 3
        OF "APR":
         xmonth = 4
        OF "MAY":
         xmonth = 5
        OF "JUN":
         xmonth = 6
        OF "JUL":
         xmonth = 7
        OF "AUG":
         xmonth = 8
        OF "SEP":
         xmonth = 9
        OF "OCT":
         xmonth = 10
        OF "NOV":
         xmonth = 11
        OF "DEC":
         xmonth = 12
       ENDCASE
       IF (findstring(":",substring(7,6,t.line),1,0) > 0)
        IF (xmonth > month(cnvtdatetime(curdate,curtime3)))
         xyear = (year(curdate) - 1)
        ELSE
         xyear = year(curdate)
        ENDIF
        xtime = substring((findstring(":",t.line,1,0) - 2),5,t.line)
       ELSE
        xyear = cnvtint(substring(7,6,t.line)), xtime = "00:00"
       ENDIF
       xday = cnvtint(substring(5,2,t.line)), xdatestr = build(xday,"-",cnvtupper(substring(1,3,t
          .line)),"-",xyear,
        concat(" ",xtime)), xdateint = cnvtdatetime(xdatestr)
       IF ((dm_err->debug_flag > 0))
        CALL echo(xday),
        CALL echo(xyear),
        CALL echo(xmonth),
        CALL echo(xdatestr),
        CALL echo(xtime)
       ENDIF
       dgfd_date_str = trim(xdatestr)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("DATE FOUND:",dgfd_date_str))
   ENDIF
   SET dgfd_file_date = cnvtdatetime(evaluate(dgfd_date_str,"x","0.0",dgfd_date_str))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_write_misc_data(dwmd_src_ind,dwmd_tgt_ind)
   DECLARE dwmd_file = vc WITH protect, noconstant(concat(evaluate(dwmd_src_ind,1,ddr_domain_data->
      src_tmp_full_dir,ddr_domain_data->tgt_tmp_full_dir),ddr_domain_data->data_file_name))
   DECLARE dwmd_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dwmd_str = vc WITH protect, noconstant("")
   DECLARE dwmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dwmd_suffix = vc WITH protect, noconstant(";*")
   IF (dm2_findfile(dwmd_file) > 0)
    IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","del","rm")," ",evaluate(dm2_sys_misc
       ->cur_os,"AXP",concat(dwmd_file,dwmd_suffix),dwmd_file)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Writing source data to ",dwmd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dwmd_config_file dwmd_file
   SELECT INTO "dwmd_config_file"
    DETAIL
     IF (dwmd_src_ind=1)
      dwmd_str = concat('src_cer_data_dev,"',ddr_domain_data->src_cer_data_dev,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('src_wh,"',ddr_domain_data->src_wh,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat('src_wh_device,"',ddr_domain_data->src_wh_device,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('src_cer_install_dir,"',ddr_domain_data->src_cer_install_dir,'"'), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat('src_revision_level,"',ddr_domain_data->src_revision_level,'"'), col
       0,
      dwmd_str, row + 1, dwmd_str = concat('src_system,"',ddr_domain_data->src_system,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('src_system_pwd,"',ddr_domain_data->src_system_pwd,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat("offline_dict_ind,",build(ddr_domain_data->offline_dict_ind)), col 0,
      dwmd_str, row + 1, dwmd_str = concat('src_domain_name,"',ddr_domain_data->src_domain_name,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('src_priv,"',ddr_domain_data->src_priv,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('src_priv_pwd,"',ddr_domain_data->src_priv_pwd,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat('src_mng,"',ddr_domain_data->src_mng,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('src_mng_pwd,"',ddr_domain_data->src_mng_pwd,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('src_sec_user_name,"',ddr_domain_data->src_sec_user_name,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat('src_local_user_name,"',ddr_domain_data->
       src_local_user_name,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("src_auth_server_id,",build(ddr_domain_data->src_auth_server_id)), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat('src_auth_server_desc,"',ddr_domain_data->src_auth_server_desc,'"'),
      col 0,
      dwmd_str, row + 1, dwmd_str = concat("src_scp_server_id,",build(ddr_domain_data->
        src_scp_server_id)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('src_scp_server_desc,"',ddr_domain_data->src_scp_server_desc,'"'), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat("src_tdb_server_master_id,",build(ddr_domain_data->
        src_tdb_server_master_id)), col 0,
      dwmd_str, row + 1, dwmd_str = concat('src_tdb_server_master_desc,"',ddr_domain_data->
       src_tdb_server_master_desc,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("src_tdb_server_slave_id,",build(ddr_domain_data->src_tdb_server_slave_id)),
      col 0, dwmd_str,
      row + 1, dwmd_str = concat('src_tdb_server_slave_desc,"',ddr_domain_data->
       src_tdb_server_slave_desc,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat("src_sec_server_master_id,",build(ddr_domain_data->
        src_sec_server_master_id)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('src_sec_server_master_desc,"',ddr_domain_data->src_sec_server_master_desc,
       '"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('src_sec_server_master_lrl,"',ddr_domain_data->
       src_sec_server_master_lrl,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat("src_sec_server_slave_id,",build(ddr_domain_data->
        src_sec_server_slave_id)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('src_sec_server_slave_desc,"',ddr_domain_data->src_sec_server_slave_desc,'"'),
      col 0, dwmd_str,
      row + 1, dwmd_str = concat('src_sec_server_slave_lrl,"',ddr_domain_data->
       src_sec_server_slave_lrl,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat("src_tdb_count,",build(ddr_domain_data->src_tdb_count)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("src_server_count,",build(ddr_domain_data->src_server_count)), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat('src_db_env_name,"',ddr_domain_data->src_db_env_name,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat("src_was_arch_ind,",build(ddr_domain_data->
        src_was_arch_ind)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("src_ccl_grants_ind,",build(ddr_domain_data->src_ccl_grants_ind)), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat("src_ops_ver,",build(ddr_domain_data->src_ops_ver)), col 0,
      dwmd_str, row + 1
      IF ((dm2_sys_misc->cur_os="AXP"))
       dwmd_str = concat('src_ccldir,"',ddr_domain_data->src_ccldir,'"'), col 0, dwmd_str,
       row + 1, dwmd_str = concat('src_ccluserdir_dir,"',ddr_domain_data->src_ccluserdir_dir,'"'),
       col 0,
       dwmd_str, row + 1, dwmd_str = concat('src_ocdtools_dir,"',ddr_domain_data->src_ocdtools_dir,
        '"'),
       col 0, dwmd_str, row + 1,
       dwmd_str = concat('src_warehouse_dir,"',ddr_domain_data->src_warehouse_dir,'"'), col 0,
       dwmd_str,
       row + 1, dwmd_str = concat('src_cer_config_dir,"',ddr_domain_data->src_cer_config_dir,'"'),
       col 0,
       dwmd_str, row + 1
      ENDIF
      FOR (dwmd_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
        dwmd_str = concat("node_name,",ddr_domain_data->src_nodes[dwmd_cnt].node_name), col 0,
        dwmd_str,
        row + 1
      ENDFOR
      dwmd_str = concat('src_tdb_curpages,"',build(ddr_domain_data->src_tdb_curpages),'"'), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat('src_tdb_maxpages,"',build(ddr_domain_data->src_tdb_maxpages),'"'),
      col 0,
      dwmd_str, row + 1, dwmd_str = concat('src_tdb_init_size,"',build(ddr_domain_data->
        src_tdb_init_size),'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("src_ldap_ind,",build(ddr_domain_data->src_ldap_ind)), col 0, dwmd_str,
      row + 1
     ELSE
      dwmd_str = concat('tgt_cer_data_dev,"',ddr_domain_data->tgt_cer_data_dev,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('tgt_wh,"',ddr_domain_data->tgt_wh,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat('tgt_wh_device,"',ddr_domain_data->tgt_wh_device,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('tgt_cer_install_dir,"',ddr_domain_data->tgt_cer_install_dir,'"'), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat('tgt_revision_level,"',ddr_domain_data->tgt_revision_level,'"'), col
       0,
      dwmd_str, row + 1, dwmd_str = concat('tgt_system,"',ddr_domain_data->tgt_system,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('tgt_system_pwd,"',ddr_domain_data->tgt_system_pwd,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat("offline_dict_ind,",build(ddr_domain_data->offline_dict_ind)), col 0,
      dwmd_str, row + 1, dwmd_str = concat('tgt_domain_name,"',ddr_domain_data->tgt_domain_name,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('tgt_priv,"',ddr_domain_data->tgt_priv,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('tgt_priv_pwd,"',ddr_domain_data->tgt_priv_pwd,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat('tgt_mng,"',ddr_domain_data->tgt_mng,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('tgt_mng_pwd,"',ddr_domain_data->tgt_mng_pwd,'"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('tgt_sec_user_name,"',ddr_domain_data->tgt_sec_user_name,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat('tgt_local_user_name,"',ddr_domain_data->
       tgt_local_user_name,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("tgt_auth_server_id,",build(ddr_domain_data->tgt_auth_server_id)), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat('tgt_auth_server_desc,"',ddr_domain_data->tgt_auth_server_desc,'"'),
      col 0,
      dwmd_str, row + 1, dwmd_str = concat("tgt_scp_server_id,",build(ddr_domain_data->
        tgt_scp_server_id)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('tgt_scp_server_desc,"',ddr_domain_data->tgt_scp_server_desc,'"'), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat("tgt_tdb_server_master_id,",build(ddr_domain_data->
        tgt_tdb_server_master_id)), col 0,
      dwmd_str, row + 1, dwmd_str = concat('tgt_tdb_server_master_desc,"',ddr_domain_data->
       tgt_tdb_server_master_desc,'"'),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("tgt_tdb_server_slave_id,",build(ddr_domain_data->tgt_tdb_server_slave_id)),
      col 0, dwmd_str,
      row + 1, dwmd_str = concat('tgt_tdb_server_slave_desc,"',ddr_domain_data->
       tgt_tdb_server_slave_desc,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat("tgt_sec_server_master_id,",build(ddr_domain_data->
        tgt_sec_server_master_id)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('tgt_sec_server_master_desc,"',ddr_domain_data->tgt_sec_server_master_desc,
       '"'), col 0, dwmd_str,
      row + 1, dwmd_str = concat('tgt_sec_server_master_lrl,"',ddr_domain_data->
       tgt_sec_server_master_lrl,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat("tgt_sec_server_slave_id,",build(ddr_domain_data->
        tgt_sec_server_slave_id)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat('tgt_sec_server_slave_desc,"',ddr_domain_data->tgt_sec_server_slave_desc,'"'),
      col 0, dwmd_str,
      row + 1, dwmd_str = concat('tgt_sec_server_slave_lrl,"',ddr_domain_data->
       tgt_sec_server_slave_lrl,'"'), col 0,
      dwmd_str, row + 1, dwmd_str = concat("tgt_node_flag,",build(ddr_domain_data->tgt_node_flag)),
      col 0, dwmd_str, row + 1,
      dwmd_str = concat("tgt_was_arch_ind,",build(ddr_domain_data->tgt_was_arch_ind)), col 0,
      dwmd_str,
      row + 1, dwmd_str = concat("tgt_ccl_grants_ind,",build(ddr_domain_data->tgt_ccl_grants_ind)),
      col 0,
      dwmd_str, row + 1
      FOR (dwmd_cnt = 1 TO ddr_domain_data->tgt_nodes_cnt)
        dwmd_str = concat("node_name,",ddr_domain_data->tgt_nodes[dwmd_cnt].node_name), col 0,
        dwmd_str,
        row + 1
      ENDFOR
      dwmd_str = concat("tgt_ldap_ind,",build(ddr_domain_data->tgt_ldap_ind)), col 0, dwmd_str,
      row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dwmd_src_ind=1)
    SET ddr_domain_data->src_data_fnd = 1
   ELSE
    SET ddr_domain_data->tgt_data_fnd = 1
   ENDIF
   IF (ddr_get_file_date(dwmd_file,dwmd_file_date)=0)
    RETURN(0)
   ENDIF
   IF (dwmd_src_ind=1)
    SET ddr_domain_data->src_data_ts = dwmd_file_date
   ELSE
    SET ddr_domain_data->tgt_data_ts = dwmd_file_date
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_misc_data(dgmd_src_ind,dgmd_tgt_ind)
   DECLARE dgmd_env = vc WITH protect, noconstant("")
   DECLARE dgmd_str = vc WITH protect, noconstant("")
   DECLARE dgmd_ret_val = vc WITH protect, noconstant("")
   DECLARE dgmd_domain = vc WITH protect, noconstant("")
   DECLARE dgmd_wh = vc WITH protect, noconstant("")
   DECLARE dgmd_server_id = vc WITH protect, noconstant("")
   DECLARE dgmd_server_desc = vc WITH protect, noconstant("")
   DECLARE dgmd_from_dir = vc WITH protect, noconstant("")
   DECLARE dgmd_replicate_tgt_skip = i2 WITH protect, noconstant(0)
   DECLARE dgmd_user = vc WITH protect, noconstant("")
   DECLARE dgmd_pass = vc WITH protect, noconstant("")
   DECLARE dgmd_has_privs = i2 WITH protect, noconstant(1)
   DECLARE dgmd_was_ind = i2 WITH protect, noconstant(0)
   DECLARE dgmd_tdb_file = vc WITH protect, noconstant("")
   DECLARE dgmd_ldap_ind = i2 WITH protect, noconstant(0)
   IF (dgmd_tgt_ind=1
    AND (ddr_domain_data->process="REPLICATE"))
    SET dgmd_replicate_tgt_skip = 1
   ENDIF
   SET dgmd_env = evaluate(dgmd_src_ind,1,ddr_domain_data->src_env,ddr_domain_data->tgt_env)
   IF (dgmd_src_ind=1)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET ddr_domain_data->src_cer_data_dev = substring(1,(findstring(":",trim(logical("cer_data")),1,
       1) - 1),trim(logical("cer_data")))
    ELSE
     SET ddr_domain_data->src_cer_data_dev = trim(logical("cer_data"))
    ENDIF
   ELSE
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET ddr_domain_data->tgt_cer_data_dev = substring(1,(findstring(":",trim(logical("cer_data")),1,
       1) - 1),trim(logical("cer_data")))
    ELSE
     SET ddr_domain_data->tgt_cer_data_dev = trim(logical("cer_data"))
    ENDIF
   ENDIF
   SET dm_err->eproc = "Get domain name."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dgmd_str = concat("\\environment\\",dgmd_env," Domain")
   IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
    RETURN(0)
   ENDIF
   SET dgmd_domain = dgmd_ret_val
   IF (dgmd_src_ind=1)
    SET ddr_domain_data->src_domain_name = dgmd_ret_val
   ELSE
    SET ddr_domain_data->tgt_domain_name = dgmd_ret_val
   ENDIF
   IF (dgmd_ret_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve domain name property for ",dgmd_env)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((validate(dm2_bypass_was_check,- (1))=- (1)))
    IF (drr_identify_was_usage(dgmd_domain,dgmd_was_ind)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_was_arch_ind = dgmd_was_ind
    ELSE
     SET ddr_domain_data->tgt_was_arch_ind = dgmd_was_ind
    ENDIF
   ENDIF
   SET dm_err->eproc = "Get warehouse."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgmd_str = concat("\environment\",dgmd_env,' "warehouse1"')
   ELSE
    SET dgmd_str = concat("\\environment\\",dgmd_env,' "warehouse1"')
   ENDIF
   IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
    RETURN(0)
   ENDIF
   IF (dgmd_ret_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve warehouse name for ",dgmd_env)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgmd_wh = cnvtlower(dgmd_ret_val)
   IF (dgmd_src_ind=1)
    SET ddr_domain_data->src_wh = cnvtlower(dgmd_ret_val)
   ELSE
    SET ddr_domain_data->tgt_wh = cnvtlower(dgmd_ret_val)
   ENDIF
   IF (dgmd_src_ind=1)
    SET ddr_domain_data->src_wh_device = evaluate(dm2_sys_misc->cur_os,"AXP",substring(1,(findstring(
       ":",trim(logical("cer_wh1")),1,1) - 1),trim(logical("cer_wh1"))),trim(logical("cer_wh")))
   ELSE
    SET ddr_domain_data->tgt_wh_device = evaluate(dm2_sys_misc->cur_os,"AXP",substring(1,(findstring(
       ":",trim(logical("cer_wh1")),1,1) - 1),trim(logical("cer_wh1"))),trim(logical("cer_wh")))
   ENDIF
   IF (dgmd_src_ind=1)
    SET ddr_domain_data->src_cer_install_dir = trim(logical("cer_install"))
   ELSE
    SET ddr_domain_data->tgt_cer_install_dir = trim(logical("cer_install"))
   ENDIF
   SET dm_err->eproc = "Get revision level."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgmd_str = concat("\warehouse\",dgmd_wh,' "revision level"')
   ELSE
    SET dgmd_str = concat("\\warehouse\\",dgmd_wh,' "revision level"')
   ENDIF
   IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
    RETURN(0)
   ENDIF
   IF (dgmd_ret_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve revision level property for ",dgmd_wh)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgmd_src_ind=1)
    SET ddr_domain_data->src_revision_level = cnvtlower(dgmd_ret_val)
   ELSE
    SET ddr_domain_data->tgt_revision_level = cnvtlower(dgmd_ret_val)
   ENDIF
   SET dgmd_str = "$cer_exe/server_ctrl"
   IF (dm2_findfile(dgmd_str) > 0)
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_revision_level = "2015.01"
    ELSE
     SET ddr_domain_data->tgt_revision_level = "2015.01"
    ENDIF
   ENDIF
   IF (dgmd_replicate_tgt_skip=0)
    SET dm_err->eproc = "Get priv user."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\51 logonuser")
    ELSE
     SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,
      "\\servers\\51 logonuser")
    ENDIF
    IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_ret_val="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve priv user for ",dgmd_domain)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_priv = dgmd_ret_val
    ELSE
     SET ddr_domain_data->tgt_priv = dgmd_ret_val
    ENDIF
    SET dm_err->eproc = "Get system password."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\51 logonpassword")
    ELSE
     SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,
      "\\servers\\51 logonpassword")
    ENDIF
    IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_ret_val="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve priv user password for ",dgmd_domain)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_priv_pwd = dgmd_ret_val
    ELSE
     SET ddr_domain_data->tgt_priv_pwd = dgmd_ret_val
    ENDIF
    SET dm_err->eproc = "Get source system."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\57 logonuser")
    ELSE
     SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,
      "\\servers\\57 logonuser")
    ENDIF
    IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_ret_val="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve system user for ",dgmd_domain)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_system = dgmd_ret_val
    ELSE
     SET ddr_domain_data->tgt_system = dgmd_ret_val
    ENDIF
    SET dm_err->eproc = "Get system password."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\57 logonpassword")
    ELSE
     SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,
      "\\servers\\57 logonpassword")
    ENDIF
    IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_ret_val="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve system user password for ",dgmd_domain)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_system_pwd = dgmd_ret_val
    ELSE
     SET ddr_domain_data->tgt_system_pwd = dgmd_ret_val
    ENDIF
    IF (((trim(logical("ccldiraccess"),3)="") OR (((trim(logical("ccldir1"),3)="") OR (trim(logical(
      "ccldir2"),3)="")) )) )
     SET ddr_domain_data->offline_dict_ind = 0
    ELSE
     SET ddr_domain_data->offline_dict_ind = 1
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=0)
     IF (ddr_get_mng_userpass(dgmd_src_ind,dgmd_tgt_ind)=0)
      RETURN(0)
     ENDIF
    ELSE
     IF (dgmd_src_ind=1)
      SET dgmd_user = ddr_domain_data->src_mng
      SET dgmd_pass = ddr_domain_data->src_mng_pwd
     ELSE
      SET dgmd_user = ddr_domain_data->tgt_mng
      SET dgmd_pass = ddr_domain_data->tgt_mng_pwd
     ENDIF
     IF (ddr_check_mng_accnt_privs(dgmd_src_ind,dgmd_tgt_ind,dgmd_user,dgmd_pass,dgmd_has_privs)=0)
      RETURN(0)
     ENDIF
     IF (dgmd_has_privs=1)
      SET dm_err->eproc = "Managed account provided has the required privileges."
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
     ELSEIF (dgmd_has_privs=2)
      SET dm_err->eproc = "Verify the managed account provided has sufficient privileges"
      SET dm_err->emsg = "The managed account provided could not be validated."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (dgmd_has_privs=0)
      SET dm_err->eproc = "Verify the managed account provided has sufficient privileges"
      SET dm_err->emsg =
      "The account provided does not have required privileges. Please choose another account."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((validate(dm2_bypass_ldap_check,- (1))=- (1)))
     IF (dgmd_src_ind=1)
      IF (ddr_identify_ldap_usage(dgmd_env,dgmd_domain,ddr_domain_data->src_mng,ddr_domain_data->
       src_mng_pwd,ddr_domain_data->src_system,
       ddr_domain_data->src_priv,dgmd_was_ind,dgmd_ldap_ind)=0)
       RETURN(0)
      ENDIF
      SET ddr_domain_data->src_ldap_ind = dgmd_ldap_ind
     ELSE
      IF (ddr_identify_ldap_usage(dgmd_env,dgmd_domain,ddr_domain_data->tgt_mng,ddr_domain_data->
       tgt_mng_pwd,ddr_domain_data->tgt_system,
       ddr_domain_data->tgt_priv,dgmd_was_ind,dgmd_ldap_ind)=0)
       RETURN(0)
      ENDIF
      SET ddr_domain_data->tgt_ldap_ind = dgmd_ldap_ind
     ENDIF
    ENDIF
   ELSE
    SET ddr_domain_data->tgt_priv = "system"
    SET ddr_domain_data->tgt_priv_pwd = "system"
    SET ddr_domain_data->tgt_system = "systemoe"
    SET ddr_domain_data->tgt_system_pwd = "systemoe"
    SET ddr_domain_data->tgt_mng = "cerner"
    SET ddr_domain_data->tgt_mng_pwd = "v5system"
   ENDIF
   IF (ddr_get_sec_user_name(dgmd_src_ind,dgmd_tgt_ind)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_local_user_name(dgmd_src_ind,dgmd_tgt_ind)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (ddr_get_local_group_name(dgmd_src_ind,dgmd_tgt_ind)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dgmd_replicate_tgt_skip=0)
    IF (ddr_get_srv_info(evaluate(dgmd_src_ind,1,"src","tgt"),"authorize",dgmd_server_id,
     dgmd_server_desc)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_auth_server_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->src_auth_server_desc = dgmd_server_desc
    ELSE
     SET ddr_domain_data->tgt_auth_server_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->tgt_auth_server_desc = dgmd_server_desc
    ENDIF
    IF (dgmd_src_ind=1)
     IF ( NOT ((ddr_domain_data->src_auth_server_id > 0)))
      SET dm_err->eproc = "Finding Authorize server id and description"
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find Authorize Server for SRC Domain: ",dgmd_domain)
      RETURN(0)
     ENDIF
    ELSE
     IF ( NOT ((ddr_domain_data->tgt_auth_server_id > 0)))
      SET dm_err->eproc = "Finding Authorize server id and description"
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find Authorize Server for TGT Domain: ",dgmd_domain)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_get_srv_info(evaluate(dgmd_src_ind,1,"src","tgt"),"transaction database master",
     dgmd_server_id,dgmd_server_desc)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_tdb_server_master_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->src_tdb_server_master_desc = dgmd_server_desc
    ELSE
     SET ddr_domain_data->tgt_tdb_server_master_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->tgt_tdb_server_master_desc = dgmd_server_desc
    ENDIF
    IF (ddr_get_srv_info(evaluate(dgmd_src_ind,1,"src","tgt"),"transaction database slave",
     dgmd_server_id,dgmd_server_desc)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_tdb_server_slave_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->src_tdb_server_slave_desc = dgmd_server_desc
    ELSE
     SET ddr_domain_data->tgt_tdb_server_slave_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->tgt_tdb_server_slave_desc = dgmd_server_desc
    ENDIF
    IF (dgmd_src_ind=1)
     IF ( NOT ((ddr_domain_data->src_tdb_server_master_id > 0)))
      SET dm_err->eproc = "Finding TDB server id and description"
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find Transaction Database Master Server for SRC domain: ",
       dgmd_domain)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF ( NOT ((((ddr_domain_data->tgt_tdb_server_master_id > 0)) OR ((ddr_domain_data->
     tgt_tdb_server_slave_id > 0))) ))
      SET dm_err->eproc = "Finding TDB server id and description"
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find both, Master AND Slave TDB Servers for TGT Domain: ",
       dgmd_domain)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_get_srv_info(evaluate(dgmd_src_ind,1,"src","tgt"),"server control panel",dgmd_server_id,
     dgmd_server_desc)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_scp_server_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->src_scp_server_desc = dgmd_server_desc
    ELSE
     SET ddr_domain_data->tgt_scp_server_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->tgt_scp_server_desc = dgmd_server_desc
    ENDIF
    IF (dgmd_src_ind=1)
     IF ( NOT ((ddr_domain_data->src_scp_server_id > 0)))
      SET dm_err->eproc = "Finding Server Control Panel server id and description"
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find server control panel Server for SRC Domain: ",
       dgmd_domain)
      RETURN(0)
     ENDIF
    ELSE
     IF ( NOT ((ddr_domain_data->tgt_scp_server_id > 0)))
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find server control panel Server for TGT Domain: ",
       dgmd_domain)
      RETURN(0)
     ENDIF
    ENDIF
    IF (ddr_get_srv_info(evaluate(dgmd_src_ind,1,"src","tgt"),"security master",dgmd_server_id,
     dgmd_server_desc)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_sec_server_master_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->src_sec_server_master_desc = dgmd_server_desc
    ELSE
     SET ddr_domain_data->tgt_sec_server_master_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->tgt_sec_server_master_desc = dgmd_server_desc
    ENDIF
    IF (cnvtint(dgmd_server_id) > 0)
     SET dm_err->eproc = "Get Security Master's property Lock Request Limit."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\",
       trim(dgmd_server_id),'\prop "Lock Request Limit"')
     ELSE
      SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,"\\servers\\",
       trim(dgmd_server_id),'\\prop "Lock Request Limit"')
     ENDIF
     IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
      RETURN(0)
     ENDIF
     IF (dgmd_src_ind=1)
      SET ddr_domain_data->src_sec_server_master_lrl = dgmd_ret_val
     ELSE
      SET ddr_domain_data->tgt_sec_server_master_lrl = dgmd_ret_val
     ENDIF
    ENDIF
    IF (ddr_get_srv_info(evaluate(dgmd_src_ind,1,"src","tgt"),"security slave",dgmd_server_id,
     dgmd_server_desc)=0)
     RETURN(0)
    ENDIF
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_sec_server_slave_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->src_sec_server_slave_desc = dgmd_server_desc
    ELSE
     SET ddr_domain_data->tgt_sec_server_slave_id = cnvtint(dgmd_server_id)
     SET ddr_domain_data->tgt_sec_server_slave_desc = dgmd_server_desc
    ENDIF
    IF (cnvtint(dgmd_server_id) > 0)
     SET dm_err->eproc = "Get Security Slave's property Lock Request Limit."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\",
       trim(dgmd_server_id),'\prop "Lock Request Limit"')
     ELSE
      SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,"\\servers\\",
       trim(dgmd_server_id),'\\prop "Lock Request Limit"')
     ENDIF
     IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
      RETURN(0)
     ENDIF
     IF (dgmd_src_ind=1)
      SET ddr_domain_data->src_sec_server_slave_lrl = dgmd_ret_val
     ELSE
      SET ddr_domain_data->tgt_sec_server_slave_lrl = dgmd_ret_val
     ENDIF
    ENDIF
    IF (dgmd_src_ind=1)
     IF ( NOT ((((ddr_domain_data->src_sec_server_master_id > 0)) OR ((ddr_domain_data->
     src_sec_server_slave_id > 0))) )
      AND dgmd_was_ind=0)
      SET dm_err->eproc = "Finding Security server id and description"
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(
       "Failed to find both, Master AND Slave Security Servers for SRC Domain: ",dgmd_domain)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF ( NOT ((((ddr_domain_data->tgt_sec_server_master_id > 0)) OR ((ddr_domain_data->
     tgt_sec_server_slave_id > 0))) )
      AND dgmd_was_ind=0)
      SET dm_err->eproc = "Finding Security server id and description"
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(
       "Failed to find both, Master AND Slave Security Servers for TGT Domain: ",dgmd_domain)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((ddr_domain_data->process="REFRESH")
      AND (ddr_domain_data->tgt_sec_server_master_id > 0))
      SET dm_err->eproc = "Check if Security Master is Protected."
      CALL disp_msg("",dm_err->logfile,0)
      IF ((dm2_sys_misc->cur_os="AXP"))
       SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\",
        trim(cnvtstring(ddr_domain_data->tgt_sec_server_master_id))," Protect")
      ELSE
       SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,"\\servers\\",
        trim(cnvtstring(ddr_domain_data->tgt_sec_server_master_id))," Protect")
      ENDIF
      IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
       RETURN(0)
      ENDIF
      IF (cnvtupper(dgmd_ret_val) != "Y"
       AND dgmd_was_ind=0)
       SET dm_err->eproc = "Set Security Master to Protected."
       CALL disp_msg("",dm_err->logfile,0)
       IF ((dm2_sys_misc->cur_os="AXP"))
        SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\",
         trim(cnvtstring(ddr_domain_data->tgt_sec_server_master_id)),' Protect "Y"')
       ELSE
        SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,"\\servers\\",
         trim(cnvtstring(ddr_domain_data->tgt_sec_server_master_id)),' Protect "Y"')
       ENDIF
       IF (ddr_lreg_oper("SET",dgmd_str,dgmd_ret_val)=0)
        RETURN(0)
       ENDIF
       IF (ddr_scp_apply(cnvtstring(ddr_domain_data->tgt_sec_server_master_id),dgmd_src_ind,
        dgmd_tgt_ind)=0)
        RETURN(0)
       ENDIF
       IF ((dm2_sys_misc->cur_os="AXP"))
        SET dgmd_str = concat("\node\",trim(curnode),"\domain\",dgmd_domain,"\servers\",
         trim(cnvtstring(ddr_domain_data->tgt_sec_server_master_id))," Protect")
       ELSE
        SET dgmd_str = concat("\\node\\",trim(curnode),"\\domain\\",dgmd_domain,"\\servers\\",
         trim(cnvtstring(ddr_domain_data->tgt_sec_server_master_id))," Protect")
       ENDIF
       IF (ddr_lreg_oper("GET",dgmd_str,dgmd_ret_val)=0)
        RETURN(0)
       ENDIF
       IF (cnvtupper(dgmd_ret_val) != "Y")
        SET dm_err->emsg = "Error setting protect property for Security Master."
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (dgmd_src_ind=1)
    IF (ddr_get_tdb_file(1,0,ddr_domain_data->src_tdb_server_master_id,dgmd_tdb_file)=0)
     RETURN(0)
    ENDIF
    IF (ddr_get_tdb_data(dgmd_tdb_file)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dgmd_src_ind=1
    AND (dm2_sys_misc->cur_os="AXP"))
    IF (ddr_get_from_dir(1,"ccluserdir",dgmd_from_dir)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (dgmd_src_ind=1)
     SET ddr_domain_data->src_warehouse_dir = ""
     SET ddr_domain_data->src_cer_config_dir = ""
     SET ddr_domain_data->src_ccluserdir_dir = ""
     SET ddr_domain_data->src_ocdtools_dir = ""
     SET ddr_domain_data->src_ccldir = ""
    ENDIF
   ENDIF
   IF (dgmd_src_ind=0)
    SET ddr_domain_data->tgt_warehouse_dir = ""
    SET ddr_domain_data->tgt_cer_config_dir = ""
    SET ddr_domain_data->tgt_ccluserdir_dir = ""
    SET ddr_domain_data->tgt_ocdtools_dir = ""
    SET ddr_domain_data->tgt_ccldir = ""
   ENDIF
   IF (dgmd_src_ind=1)
    IF (ddr_get_ops_version("")=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_ops_ver = ddr_ops_info->version
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_read_misc_data(drmd_src_ind,drmd_tgt_ind)
   DECLARE drmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE drmd_file = vc WITH protect, noconstant(concat(evaluate(drmd_src_ind,1,ddr_domain_data->
      src_tmp_full_dir,ddr_domain_data->tgt_tmp_full_dir),ddr_domain_data->data_file_name))
   DECLARE drmd_file_date = f8 WITH protect, noconstant(0.0)
   FREE RECORD drmd_cmd
   RECORD drmd_cmd(
     1 qual[*]
       2 rs_item = vc
       2 rs_item_value = vc
   )
   SET dm_err->eproc = concat("Read ",drmd_file)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET logical drmd_config_file drmd_file
   FREE DEFINE rtl
   DEFINE rtl "drmd_config_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     drmd_cnt = (drmd_cnt+ 1), stat = alterlist(drmd_cmd->qual,drmd_cnt), drmd_cmd->qual[drmd_cnt].
     rs_item = substring(1,(findstring(",",t.line,1,0) - 1),t.line),
     drmd_cmd->qual[drmd_cnt].rs_item_value = substring((findstring(",",t.line,1,0)+ 1),(size(t.line)
       - findstring(",",t.line,1,0)),t.line)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drmd_cmd)
   ENDIF
   IF (drmd_src_ind=0)
    SET stat = alterlist(ddr_domain_data->tgt_nodes,0)
    SET ddr_domain_data->tgt_nodes_cnt = 0
   ELSE
    SET stat = alterlist(ddr_domain_data->src_nodes,0)
    SET ddr_domain_data->src_nodes_cnt = 0
   ENDIF
   SET drmd_cnt = 0
   FOR (drmd_cnt = 1 TO size(drmd_cmd->qual,5))
     IF ((drmd_cmd->qual[drmd_cnt].rs_item="node_name"))
      IF (drmd_src_ind=1)
       SET ddr_domain_data->src_nodes_cnt = (ddr_domain_data->src_nodes_cnt+ 1)
       SET stat = alterlist(ddr_domain_data->src_nodes,ddr_domain_data->src_nodes_cnt)
       SET ddr_domain_data->src_nodes[ddr_domain_data->src_nodes_cnt].node_name = drmd_cmd->qual[
       drmd_cnt].rs_item_value
      ELSE
       SET ddr_domain_data->tgt_nodes_cnt = (ddr_domain_data->tgt_nodes_cnt+ 1)
       SET stat = alterlist(ddr_domain_data->tgt_nodes,ddr_domain_data->tgt_nodes_cnt)
       SET ddr_domain_data->tgt_nodes[ddr_domain_data->tgt_nodes_cnt].node_name = drmd_cmd->qual[
       drmd_cnt].rs_item_value
      ENDIF
     ELSE
      CALL parser(concat("set ddr_domain_data->",drmd_cmd->qual[drmd_cnt].rs_item," = ",drmd_cmd->
        qual[drmd_cnt].rs_item_value," go"),1)
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drmd_cmd)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_validate_source_data(null)
   DECLARE dvsd_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dvsd_str = vc WITH protect, noconstant("")
   DECLARE dvsd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvsd_scp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvsd_cerinstall = vc WITH protect, noconstant(trim(logical("cer_install")))
   DECLARE dvsd_reg_src_env = vc WITH protect, noconstaint
   IF (size(ddr_domain_data->src_env,1) > max_reg_env_len)
    SET dvsd_reg_src_env = substring(1,max_reg_env_len,ddr_domain_data->src_env)
   ELSE
    SET dvsd_reg_src_env = ddr_domain_data->src_env
   ENDIF
   SET ddr_domain_data->src_restart_ind = 0
   SET ddr_domain_data->src_data_fnd = 0
   SET ddr_domain_data->src_data_ts = 0
   SET ddr_domain_data->src_ind_data_fnd = 0
   SET ddr_domain_data->src_dict_fnd = 0
   SET ddr_domain_data->src_dict_ts = 0
   SET ddr_domain_data->src_tdb_fnd = 0
   SET ddr_domain_data->src_tdb_ts = 0
   SET ddr_domain_data->src_srv_def_fnd = 0
   SET ddr_domain_data->src_srv_def_ts = 0
   SET ddr_domain_data->src_sec_user_fnd = 0
   SET ddr_domain_data->src_sec_user_ts = 0
   SET ddr_domain_data->src_env_reg_fnd = 0
   SET ddr_domain_data->src_sysdef_reg_ts = 0
   SET ddr_domain_data->src_sysdef_reg_fnd = 0
   SET ddr_domain_data->src_env_reg_ts = 0
   SET ddr_domain_data->src_invalid_tbls_fnd = 0
   SET ddr_domain_data->src_invalid_tbls_ts = 0
   SET ddr_domain_data->src_ocd_tools_fnd = 0
   SET ddr_domain_data->src_ocd_tools_ts = 0
   SET ddr_domain_data->src_wh_fnd = 0
   SET ddr_domain_data->src_wh_ts = 0
   SET ddr_domain_data->src_ccldir_fnd = 0
   SET ddr_domain_data->src_ccldir_ts = 0
   SET ddr_domain_data->src_config_fnd = 0
   SET ddr_domain_data->src_config_ts = 0
   SET ddr_domain_data->src_tdb_count = 0
   SET ddr_domain_data->src_server_count = 0
   SET ddr_domain_data->src_adm_env_csv_fnd = 0
   SET ddr_domain_data->src_adm_env_csv_ts = 0
   SET dm_err->eproc = concat("Check SOURCE DATA",ddr_domain_data->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->data_file_name)) > 0)
    SET ddr_domain_data->src_data_fnd = 1
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->data_file_name),
     dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_data_ts = dvsd_file_date
    IF (ddr_read_misc_data(1,0)=0)
     RETURN(0)
    ELSE
     IF ((dm2_sys_misc->cur_os != "AXP"))
      SET ddr_domain_data->src_warehouse_dir = ""
      SET ddr_domain_data->src_cer_config_dir = ""
      SET ddr_domain_data->src_ccluserdir_dir = ""
      SET ddr_domain_data->src_ocdtools_dir = ""
      SET ddr_domain_data->src_ccldir = ""
     ENDIF
     IF ((((ddr_domain_data->src_cer_data_dev="DM2NOTSET")) OR ((((ddr_domain_data->src_wh=
     "DM2NOTSET")) OR ((((ddr_domain_data->src_wh_device="DM2NOTSET")) OR ((((ddr_domain_data->
     src_revision_level="DM2NOTSET")) OR ((((ddr_domain_data->src_system="DM2NOTSET")) OR ((((
     ddr_domain_data->src_system_pwd="DM2NOTSET")) OR ((((ddr_domain_data->src_priv="DM2NOTSET")) OR
     ((((ddr_domain_data->src_priv_pwd="DM2NOTSET")) OR ((((ddr_domain_data->src_mng="DM2NOTSET"))
      OR ((((ddr_domain_data->src_mng_pwd="DM2NOTSET")) OR ((((ddr_domain_data->
     src_tdb_server_master_id=0)) OR ((((ddr_domain_data->src_scp_server_id=0)) OR ((((
     ddr_domain_data->src_auth_server_id=0)) OR ((((ddr_domain_data->src_local_user_name="DM2NOTSET")
     ) OR ((((ddr_domain_data->src_ccldir="DM2NOTSET")) OR ((((ddr_domain_data->src_warehouse_dir=
     "DM2NOTSET")) OR ((((ddr_domain_data->src_cer_config_dir="DM2NOTSET")) OR ((((ddr_domain_data->
     src_ccluserdir_dir="DM2NOTSET")) OR ((((ddr_domain_data->src_ocdtools_dir="DM2NOTSET")) OR ((((
     ddr_domain_data->offline_dict_ind=- (1))) OR ((((ddr_domain_data->src_nodes_cnt=0)) OR ((((
     ddr_domain_data->src_tdb_count=0)) OR ((((ddr_domain_data->src_db_env_name="DM2NOTSET")) OR ((((
     ddr_domain_data->src_tdb_curpages="DM2NOTSET")) OR ((((ddr_domain_data->src_tdb_maxpages=
     "DM2NOTSET")) OR ((ddr_domain_data->src_tdb_init_size="DM2NOTSET"))) )) )) )) )) )) )) )) )) ))
     )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      SET ddr_domain_data->src_ind_data_fnd = 0
     ELSE
      IF ((ddr_domain_data->src_was_arch_ind=1))
       SET ddr_domain_data->src_ind_data_fnd = 1
      ELSE
       IF ((((ddr_domain_data->src_sec_user_name="DM2NOTSET")) OR ((ddr_domain_data->
       src_sec_server_master_id=0)
        AND (ddr_domain_data->src_sec_server_slave_id=0))) )
        SET ddr_domain_data->src_ind_data_fnd = 0
       ELSE
        SET ddr_domain_data->src_ind_data_fnd = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ddr_domain_data->src_data_fnd = 0
   ENDIF
   IF ((ddr_domain_data->src_ind_data_fnd=0))
    SET dvsd_str = "Source data missing from misc_data.dat file include:  "
    IF ((ddr_domain_data->src_cer_data_dev="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"cer_data_dev, ")
    ENDIF
    IF ((ddr_domain_data->src_wh="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"wh, ")
    ENDIF
    IF ((ddr_domain_data->src_wh_device="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"wh_device, ")
    ENDIF
    IF ((ddr_domain_data->src_revision_level="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"revision_level, ")
    ENDIF
    IF ((ddr_domain_data->src_system="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"system, ")
    ENDIF
    IF ((ddr_domain_data->src_system_pwd="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"system_pwd, ")
    ENDIF
    IF ((ddr_domain_data->src_priv="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"priv, ")
    ENDIF
    IF ((ddr_domain_data->src_priv_pwd="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"priv_pwd, ")
    ENDIF
    IF ((ddr_domain_data->src_mng="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"mng, ")
    ENDIF
    IF ((ddr_domain_data->src_mng_pwd="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"mng_pwd, ")
    ENDIF
    IF ((ddr_domain_data->src_tdb_server_master_id=0))
     SET dvsd_str = concat(dvsd_str,"tdb_server_master_id, ")
    ENDIF
    IF ((ddr_domain_data->src_scp_server_id=0))
     SET dvsd_str = concat(dvsd_str,"scp_server_id, ")
    ENDIF
    IF ((ddr_domain_data->src_auth_server_id=0))
     SET dvsd_str = concat(dvsd_str,"auth_server_id, ")
    ENDIF
    IF ((ddr_domain_data->src_local_user_name="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"local_user_name, ")
    ENDIF
    IF ((ddr_domain_data->src_ccldir="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"ccldir, ")
    ENDIF
    IF ((ddr_domain_data->src_warehouse_dir="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"warehouse_dir, ")
    ENDIF
    IF ((ddr_domain_data->src_cer_config_dir="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"cer_config_dir, ")
    ENDIF
    IF ((ddr_domain_data->src_ccluserdir_dir="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"ccluserdir_dir, ")
    ENDIF
    IF ((ddr_domain_data->src_ocdtools_dir="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"ocdtools_dir, ")
    ENDIF
    IF ((ddr_domain_data->offline_dict_ind=- (1)))
     SET dvsd_str = concat(dvsd_str,"offline_dict_ind, ")
    ENDIF
    IF ((ddr_domain_data->src_nodes_cnt=0))
     SET dvsd_str = concat(dvsd_str,"src_nodes, ")
    ENDIF
    IF ((ddr_domain_data->src_tdb_count=0))
     SET dvsd_str = concat(dvsd_str,"tdb_count, ")
    ENDIF
    IF ((ddr_domain_data->src_db_env_name="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"db_env_name, ")
    ENDIF
    IF ((ddr_domain_data->src_tdb_curpages="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"tdb_curpages, ")
    ENDIF
    IF ((ddr_domain_data->src_tdb_maxpages="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"tdb_maxpages, ")
    ENDIF
    IF ((ddr_domain_data->src_tdb_init_size="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"tdb_init_size, ")
    ENDIF
    IF ((ddr_domain_data->src_was_arch_ind=0)
     AND (ddr_domain_data->src_sec_user_name="DM2NOTSET"))
     SET dvsd_str = concat(dvsd_str,"sec_user_name, ")
    ENDIF
    IF ((ddr_domain_data->src_was_arch_ind=0)
     AND (ddr_domain_data->src_sec_server_master_id=0)
     AND (ddr_domain_data->src_sec_server_slave_id=0))
     SET dvsd_str = concat(dvsd_str,"sec_server_master/slave_id(s), ")
    ENDIF
    SET dvsd_str = replace(dvsd_str,",","",2)
    SET dm_err->eproc = dvsd_str
    CALL disp_msg(" ",dm_err->logfile,0)
    SET ddr_domain_data->src_restart_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE ",dvsd_cerinstall,"DIC.DAT")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((((dm2_sys_misc->cur_os="AXP")
    AND dm2_findfile(concat(dvsd_cerinstall,"dic.dat")) > 0) OR ((dm2_sys_misc->cur_os != "AXP")
    AND dm2_findfile(concat(dvsd_cerinstall,"/dic.dat")) > 0
    AND dm2_findfile(concat(dvsd_cerinstall,"/dic.idx")) > 0)) )
    SET ddr_domain_data->src_dict_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(concat(dvsd_cerinstall,evaluate(dm2_sys_misc->cur_os,"AXP","dic.dat",
       "/dic.dat")),dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_dict_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_dict_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE ",dvsd_cerinstall,
     "DIC.DAT.  Dictionary not found in cer_install.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE OCD_TOOLS in ",ddr_domain_data->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dvsd_str = concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,"_ocds.sav")
   IF (dm2_findfile(dvsd_str) > 0)
    SET ddr_domain_data->src_ocd_tools_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(dvsd_str,dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_ocd_tools_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_ocd_tools_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE OCD_TOOLS in ",build(ddr_domain_data->src_tmp_full_dir),
     ".  OCD_TOOLS file not found.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE CCLDIR in ",ddr_domain_data->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dvsd_str = concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,"_ccldir.sav")
   IF (dm2_findfile(dvsd_str) > 0)
    SET ddr_domain_data->src_ccldir_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(dvsd_str,dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_ccldir_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_ccldir_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE CCLDIR in ",build(ddr_domain_data->src_tmp_full_dir),
     ".  CCLDIR file not found.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE CER_CONFIG in ",ddr_domain_data->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dvsd_str = concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,"_config.sav")
   IF (dm2_findfile(dvsd_str) > 0)
    SET ddr_domain_data->src_config_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(dvsd_str,dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_config_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_config_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE CER_CONFIG in ",build(ddr_domain_data->src_tmp_full_dir),
     ".  CER_CONFIG file not found.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE TDB in ",ddr_domain_data->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,"_tdb.msg")) >
   0)
    SET ddr_domain_data->src_tdb_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,
      "_tdb.msg"),dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_tdb_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_tdb_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE TDB in ",build(ddr_domain_data->src_tmp_full_dir),
     ".  TDB file not found.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE SERVER DEFINITIONS in ",ddr_domain_data->src_tmp_full_dir
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dvsd_scp_cnt = 0
   FOR (dvsd_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
     SET dvsd_str = ""
     SET dvsd_str = concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_domain_name,"_",
      ddr_domain_data->src_nodes[dvsd_cnt].node_name,"_save.scp")
     IF (dm2_findfile(dvsd_str) > 0)
      SET dvsd_scp_cnt = (dvsd_scp_cnt+ 1)
     ENDIF
   ENDFOR
   IF ((dvsd_scp_cnt=ddr_domain_data->src_nodes_cnt))
    SET ddr_domain_data->src_srv_def_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_domain_name,
      "_",ddr_domain_data->src_nodes[1].node_name,"_save.scp"),dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_srv_def_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_srv_def_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE SERVER DEFINITIONS in ",build(ddr_domain_data->
      src_tmp_full_dir),".  SCP file(s) not found.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((ddr_domain_data->src_was_arch_ind=0))
    SET dm_err->eproc = concat("Check SOURCE SEC_USER in ",ddr_domain_data->src_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,
      "_sec_user.dat")) > 0)
     SET ddr_domain_data->src_sec_user_fnd = 1
     SET dvsd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,
       "_sec_user.dat"),dvsd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->src_sec_user_ts = dvsd_file_date
    ELSE
     SET ddr_domain_data->src_sec_user_fnd = 0
     SET dm_err->eproc = concat("Check SOURCE SEC_USER in ",build(ddr_domain_data->src_tmp_full_dir),
      ".  SEC_USER file not found.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE ENV REGISTRY SETTINGS in ",ddr_domain_data->
    src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,dvsd_reg_src_env,"_env.reg")) > 0)
    SET ddr_domain_data->src_env_reg_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,dvsd_reg_src_env,"_env.reg"),
     dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_env_reg_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_env_reg_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE ENV REGISTRY SETTINGS in ",build(ddr_domain_data->
      src_tmp_full_dir),".  ENVIRONMENT Registry file not found.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE SYSTEM DEFINITION REGISTRY SETTINGS in ",ddr_domain_data
    ->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,dvsd_reg_src_env,"_sysdef.reg")) > 0)
    SET ddr_domain_data->src_sysdef_reg_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,dvsd_reg_src_env,"_sysdef.reg"),
     dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_sysdef_reg_ts = dvsd_file_date
   ELSE
    SET ddr_domain_data->src_sysdef_reg_fnd = 0
    SET dm_err->eproc = concat("Check SOURCE SYSTEM DEFINITION REGISTRY SETTINGS in ",build(
      ddr_domain_data->src_tmp_full_dir),".  SYSTEM_DEFINITIONS Registry file not found.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE NON-STANDARD tables in ",ddr_domain_data->
    src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dvsd_file = concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->exp_parfile_prefix,
    "*.dmp")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF (dm2_findfile(dvsd_file) > 0)
     SET ddr_domain_data->src_invalid_tbls_fnd = 1
     SET dvsd_file_date = 0.0
     IF (ddr_get_file_date(dvsd_file,dvsd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->src_invalid_tbls_ts = dvsd_file_date
    ELSE
     SET ddr_domain_data->src_invalid_tbls_fnd = 0
    ENDIF
   ELSE
    IF (ddr_lnx_findfile(dvsd_file) > 0)
     SET ddr_domain_data->src_invalid_tbls_fnd = 1
     SET dvsd_file_date = 0.0
     IF (ddr_get_file_date(dvsd_file,dvsd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->src_invalid_tbls_ts = dvsd_file_date
    ELSE
     SET ddr_domain_data->src_invalid_tbls_fnd = 0
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE Warehouse backup in ",ddr_domain_data->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(evaluate(dm2_sys_misc->cur_os,"AXP",concat(ddr_domain_data->src_tmp_full_dir,
      ddr_domain_data->src_env,"_",ddr_domain_data->src_wh,".sav"),concat(ddr_domain_data->
      src_tmp_full_dir,ddr_domain_data->src_env,"_wh.sav"))) > 0)
    SET ddr_domain_data->src_wh_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(evaluate(dm2_sys_misc->cur_os,"AXP",concat(ddr_domain_data->
       src_tmp_full_dir,ddr_domain_data->src_env,"_",ddr_domain_data->src_wh,".sav"),concat(
       ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,"_wh.sav")),dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_wh_ts = dvsd_file_date
   ELSE
    IF ((ddr_domain_data->process="REFRESH"))
     SET ddr_domain_data->src_wh_fnd = 0
     SET dm_err->eproc = concat("Check SOURCE Warehouse backup in ",build(ddr_domain_data->
       src_tmp_full_dir),".  Warehouse backup file not found.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     SET ddr_domain_data->src_wh_fnd = 1
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE Admin env history csv files ",ddr_domain_data->
    src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drr_validate_adm_env_csv(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_db_env_name)=0
   )
    SET ddr_domain_data->src_adm_env_csv_fnd = 0
    SET dm_err->eproc =
    "Check SOURCE Admin env history csv files.  Admin env history csv files not found."
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    SET ddr_domain_data->src_adm_env_csv_fnd = 1
    SET dvsd_file_date = 0.0
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,"dm2_",ddr_domain_data->
      src_db_env_name,"_env_hist_summary.txt"),dvsd_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_adm_env_csv_ts = dvsd_file_date
   ENDIF
   SET dm_err->eproc = concat("Check Source DAFSOLR backup in ",ddr_domain_data->src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((ddr_domain_data->src_interrogator_ind=1))
    IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,"_dafsolr.sav"
      )) > 0)
     SET dvsd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_env,
       "_dafsolr.sav"),dvsd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->src_interrogator_ts = dvsd_file_date
     SET ddr_domain_data->src_interrogator_fnd = 1
    ELSE
     SET ddr_domain_data->src_interrogator_fnd = 0
     SET dm_err->eproc = concat("Could not find Interrogator backup file in ",ddr_domain_data->
      src_tmp_full_dir)
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF ((ddr_domain_data->src_data_fnd=1)
    AND (ddr_domain_data->src_dict_fnd=1)
    AND (ddr_domain_data->src_tdb_fnd=1)
    AND (ddr_domain_data->src_srv_def_fnd=1)
    AND (ddr_domain_data->src_sysdef_reg_fnd=1)
    AND (ddr_domain_data->src_env_reg_fnd=1)
    AND (ddr_domain_data->src_ind_data_fnd=1)
    AND (ddr_domain_data->src_wh_fnd=1)
    AND (ddr_domain_data->src_ccldir_fnd=1)
    AND (ddr_domain_data->src_config_fnd=1)
    AND (ddr_domain_data->src_ocd_tools_fnd=1)
    AND (ddr_domain_data->src_adm_env_csv_fnd=1))
    IF ((ddr_domain_data->src_was_arch_ind=1))
     SET ddr_domain_data->src_restart_ind = 1
    ELSE
     IF ((ddr_domain_data->src_sec_user_fnd=1))
      SET ddr_domain_data->src_restart_ind = 1
     ELSE
      SET ddr_domain_data->src_restart_ind = 0
     ENDIF
    ENDIF
   ELSE
    SET ddr_domain_data->src_restart_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_collect_source_data(null)
   DECLARE dcsd_log_ret = vc WITH protect, noconstant("")
   DECLARE dcsd_node_ret = vc WITH protect, noconstant("")
   DECLARE dcsd_dev_ret = vc WITH protect, noconstant("")
   DECLARE dcsd_dir_ret = vc WITH protect, noconstant("")
   DECLARE dcsd_env_ok_ret = i2 WITH protect, noconstant(0)
   DECLARE dcsd_recollect = i2 WITH protect, noconstant(0)
   DECLARE dcsd_mode = i2 WITH protect, noconstant(0)
   DECLARE dcsd_ora_home = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Collect SOURCE data."
   CALL disp_msg("",dm_err->logfile,0)
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dm_err->eproc = "Response file detected and will be used to collect data."
    CALL disp_msg("",dm_err->logfile,0)
    IF (validate(drrr_rf_data->responsefile_version,"X")="X"
     AND validate(drrr_rf_data->responsefile_version,"Z")="Z")
     SET dm_err->eproc = "Verify response file structures accessible"
     SET dm_err->emsg = "Response file structure could not be accessed."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drrr_rf_data)
     CALL echorecord(drrr_misc_data)
    ENDIF
    IF ((drrr_rf_data->tgt_copy_interrogator="YES"))
     SET ddr_domain_data->src_interrogator_ind = 1
    ENDIF
   ENDIF
   IF (ddr_get_env_logical(dcsd_log_ret)=0)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF (cnvtlower(dcsd_log_ret) != cnvtlower(drrr_rf_data->src_env_name))
     SET dm_err->eproc = concat("Verify Source response file environment (",drrr_rf_data->
      src_env_name,") with current enviornment (",dcsd_log_ret,").")
     SET dm_err->emsg = "Environments specified do not match."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_env = cnvtlower(dcsd_log_ret)
   ELSE
    IF (ddr_env_confirm(1,0,dcsd_log_ret,dcsd_env_ok_ret)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND (ddr_domain_data->src_tmp_dev="DM2NOTSET"))
    IF (ddr_dev_prompt(1,0,dcsd_dev_ret)=0)
     RETURN(0)
    ELSE
     SET ddr_domain_data->src_tmp_dev = dcsd_dev_ret
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET ddr_domain_data->src_tmp_full_dir = build(drrr_rf_data->src_app_temp_dir,ddr_domain_data->
     src_env,"/")
   ELSEIF ((ddr_domain_data->src_tmp_full_dir="DM2NOTSET"))
    IF (ddr_dir_prompt(1,0,dcsd_dir_ret)=0)
     RETURN(0)
    ELSE
     SET ddr_domain_data->src_tmp_dir = dcsd_dir_ret
     SET ddr_domain_data->src_tmp_full_dir = evaluate(dm2_sys_misc->cur_os,"AXP",concat(
       ddr_domain_data->src_tmp_dev,":[",dcsd_dir_ret,".",ddr_domain_data->src_env,
       "]"),concat(dcsd_dir_ret,ddr_domain_data->src_env,"/"))
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os != "LNX"))
    IF ( NOT (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,"*.*"))))
     SET ddr_domain_data->src_tmp_dir_exists = 0
     SET ddr_domain_data->src_restart_ind = 0
    ELSE
     SET ddr_domain_data->src_tmp_dir_exists = 1
    ENDIF
   ELSE
    IF ( NOT (ddr_lnx_findfile(concat(ddr_domain_data->src_tmp_full_dir,"*.*"))))
     SET ddr_domain_data->src_tmp_dir_exists = 0
     SET ddr_domain_data->src_restart_ind = 0
    ELSE
     SET ddr_domain_data->src_tmp_dir_exists = 1
    ENDIF
   ENDIF
   IF ((ddr_domain_data->src_tmp_dir_exists=1))
    IF (ddr_validate_source_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((ddr_domain_data->src_restart_ind=1))
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dcsd_recollect = 1
    ELSE
     IF (ddr_summary(1,0)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Previous Start Prompt"
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,131)
     CALL text(1,2,"PREVIOUS START ATTEMPTED")
     CALL text(3,4,"Would you like to recollect ALL data again or proceed with collected data?")
     CALL text(4,4,
      'Enter "P" to proceed with currently collected data specified in previous summary screen.')
     CALL text(5,4,'Enter "R" to recollect data.')
     CALL text(6,4,'Enter "Q" to Quit.')
     CALL accept(3,80,"A;cu"," "
      WHERE curaccept IN ("R", "P", "Q"))
     CALL clear(1,1)
     SET message = nowindow
     IF (curaccept="Q")
      SET dm_err->emsg = "User elected to not continue."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curaccept="R")
      SET dcsd_recollect = 1
     ENDIF
    ENDIF
   ELSEIF ((ddr_domain_data->src_tmp_dir_exists=1))
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = "Not all data present, data will be recollected."
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,6,131)
     CALL text(3,4,concat("The ",ddr_domain_data->src_tmp_full_dir,
       " directory exists and will be cleared."))
     CALL text(5,4,'Enter "Y" to proceed. Enter "N" to abort process.')
     CALL accept(5,67,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     CALL clear(1,1)
     SET message = nowindow
     IF (curaccept="N")
      SET dm_err->emsg = concat("User elected to not continue with the removal of ",ddr_domain_data->
       src_tmp_full_dir)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_domain_data)
   ENDIF
   IF ((((ddr_domain_data->src_restart_ind=0)) OR ((ddr_domain_data->src_restart_ind=1)
    AND dcsd_recollect=1)) )
    IF (der_determine_expimp_mode(dcsd_mode)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->standalone_expimp_mode = dcsd_mode
    IF (ddr_create_dir(ddr_domain_data->src_tmp_full_dir)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_tmp_dir_exists = 1
    IF ( NOT ((dm2_sys_misc->cur_os="AXP")))
     SET dcsd_ora_home = trim(logical("oracle_home"))
     IF (ddr_check_sqlnet(1,0,dcsd_ora_home)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET stat = alterlist(ddr_domain_data->src_nodes,0)
    SET ddr_domain_data->src_nodes_cnt = 0
    SET ddr_domain_data->get_ccluserdir = 0
    SET ddr_domain_data->get_warehouse = 0
    SET ddr_domain_data->get_invalid_tables = 0
    SET ddr_domain_data->src_restart_ind = 0
    IF (ddr_get_new_source_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_validate_target_data(null)
   DECLARE dvtd_log_ret = vc WITH protect, noconstant("")
   DECLARE dvtd_node_ret = vc WITH protect, noconstant("")
   DECLARE dvtd_dev_ret = vc WITH protect, noconstant("")
   DECLARE dvtd_dir_ret = vc WITH protect, noconstant("")
   DECLARE dvtd_env_ok_ret = i2 WITH protect, noconstant(0)
   DECLARE dvtd_recollect = i2 WITH protect, noconstant(0)
   DECLARE dvtd_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dvtd_pd_present = i2 WITH protect, noconstant(0)
   DECLARE dvtd_file = vc WITH protect, noconstant("")
   DECLARE dvtd_find_str = vc WITH protect, noconstant("")
   DECLARE dvtd_found = i2 WITH protect, noconstant(0)
   DECLARE dvtd_scp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvtd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvtd_str = vc WITH protect, noconstant("")
   DECLARE dvtd_cerinstall = vc WITH protect, noconstant(trim(logical("cer_install")))
   DECLARE dvtd_reg_tgt_env = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Validate TARGET data."
   CALL disp_msg("",dm_err->logfile,0)
   IF (ddr_get_env_logical(dvtd_log_ret)=0)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    IF (cnvtlower(dvtd_log_ret) != cnvtlower(drrr_rf_data->tgt_env_name))
     SET dm_err->eproc = concat("Verify response file Target environment (",drrr_rf_data->
      tgt_env_name,") with current enviornment (",dvtd_log_ret,").")
     SET dm_err->emsg = "Environments specified do not match."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->tgt_env = cnvtlower(dvtd_log_ret)
   ELSE
    IF (ddr_env_confirm(0,1,dvtd_log_ret,dvtd_env_ok_ret)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND (ddr_domain_data->tgt_tmp_full_dir="DM2NOTSET"))
    IF (ddr_dev_prompt(0,1,dvtd_dev_ret)=0)
     RETURN(0)
    ELSE
     SET ddr_domain_data->tgt_tmp_dev = dvtd_dev_ret
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    SET ddr_domain_data->tgt_tmp_full_dir = build(drrr_rf_data->tgt_app_temp_dir,ddr_domain_data->
     tgt_env,"/")
    SET ddr_domain_data->tgt_tmp_dir = drrr_rf_data->tgt_app_temp_dir
    SET dvtd_dir_ret = drrr_rf_data->tgt_app_temp_dir
   ELSEIF ((ddr_domain_data->tgt_tmp_full_dir="DM2NOTSET"))
    IF (ddr_dir_prompt(0,1,dvtd_dir_ret)=0)
     RETURN(0)
    ELSE
     SET ddr_domain_data->tgt_tmp_dir = dvtd_dir_ret
     SET ddr_domain_data->tgt_tmp_full_dir = evaluate(dm2_sys_misc->cur_os,"AXP",concat(
       ddr_domain_data->tgt_tmp_dev,":[",dvtd_dir_ret,".",ddr_domain_data->tgt_env,
       "]"),concat(dvtd_dir_ret,ddr_domain_data->tgt_env,"/"))
    ENDIF
   ENDIF
   IF ((ddr_domain_data->process="REPLICATE"))
    IF ( NOT (dm2_find_dir(ddr_domain_data->tgt_tmp_full_dir)))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validate Target temporary directory during Replicate."
     SET dm_err->emsg = concat("Fail to find Target temp dir ",ddr_domain_data->tgt_tmp_full_dir)
     CALL disp_msg(dm_err->emsg,dm_err->eproc,1)
     RETURN(0)
    ELSE
     SET ddr_domain_data->tgt_tmp_dir_exists = 1
    ENDIF
   ELSEIF ((ddr_domain_data->process="REFRESH"))
    IF ((dm2_sys_misc->cur_os != "LNX"))
     IF ( NOT (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,"*.*"))))
      SET ddr_domain_data->tgt_tmp_dir_exists = 0
      SET ddr_domain_data->tgt_restart_ind = 0
     ELSE
      SET ddr_domain_data->tgt_tmp_dir_exists = 1
     ENDIF
    ELSE
     IF ( NOT (ddr_lnx_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,"*.*"))))
      SET ddr_domain_data->tgt_tmp_dir_exists = 0
      SET ddr_domain_data->tgt_restart_ind = 0
     ELSE
      SET ddr_domain_data->tgt_tmp_dir_exists = 1
     ENDIF
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    SET ddr_domain_data->src_env = cnvtlower(drrr_rf_data->src_env_name)
   ELSEIF ((ddr_domain_data->src_env="DM2NOTSET"))
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,5,131)
    IF ((ddr_domain_data->process="REFRESH"))
     CALL text(3,4,"What is the SOURCE environment name from which TARGET is being refreshed from?")
    ELSEIF ((ddr_domain_data->process="REPLICATE"))
     CALL text(3,4,"What is the SOURCE environment name from which TARGET is being replicated from?")
    ENDIF
    CALL accept(3,83,"P(30);CUF"," "
     WHERE curaccept > " ")
    SET ddr_domain_data->src_env = cnvtlower(curaccept)
    SET message = nowindow
    CALL clear(1,1)
   ENDIF
   SET ddr_domain_data->src_tmp_full_dir = evaluate(dm2_sys_misc->cur_os,"AXP",concat(ddr_domain_data
     ->tgt_tmp_dev,":[",dvtd_dir_ret,".",ddr_domain_data->src_env,
     "]"),concat(dvtd_dir_ret,ddr_domain_data->src_env,"/"))
   IF ( NOT (dm2_find_dir(ddr_domain_data->src_tmp_full_dir)))
    SET ddr_domain_data->tgt_tmp_src_dir_exists = 0
    IF ((ddr_domain_data->process="REPLICATE"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validate Source temporary directory during Replicate."
     SET dm_err->emsg = concat("Fail to find Source temp dir ",ddr_domain_data->src_tmp_full_dir)
     CALL disp_msg(dm_err->emsg,dm_err->eproc,1)
     RETURN(0)
    ENDIF
   ELSE
    SET ddr_domain_data->tgt_tmp_src_dir_exists = 1
   ENDIF
   IF ((ddr_domain_data->process="REPLICATE"))
    SET ddr_domain_data->tgt_restart_ind = 0
    RETURN(1)
   ENDIF
   IF (size(ddr_domain_data->tgt_env,1) > max_reg_env_len)
    SET dvtd_reg_tgt_env = substring(1,max_reg_env_len,ddr_domain_data->tgt_env)
   ELSE
    SET dvtd_reg_tgt_env = ddr_domain_data->tgt_env
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(concat("dvtd_reg_tgt_env = ",dvtd_reg_tgt_env))
   ENDIF
   IF ((ddr_domain_data->tgt_tmp_dir_exists=1))
    SET ddr_domain_data->tgt_restart_ind = 0
    SET ddr_domain_data->tgt_data_fnd = 0
    SET ddr_domain_data->tgt_data_ts = 0
    SET ddr_domain_data->tgt_ind_data_fnd = 0
    SET ddr_domain_data->tgt_dict_fnd = 0
    SET ddr_domain_data->tgt_dict_ts = 0
    SET ddr_domain_data->tgt_tdb_fnd = 0
    SET ddr_domain_data->tgt_tdb_ts = 0
    SET ddr_domain_data->tgt_srv_def_fnd = 0
    SET ddr_domain_data->tgt_srv_def_ts = 0
    SET ddr_domain_data->tgt_sec_user_fnd = 0
    SET ddr_domain_data->tgt_sec_user_ts = 0
    SET ddr_domain_data->tgt_env_reg_fnd = 0
    SET ddr_domain_data->tgt_env_reg_ts = 0
    SET ddr_domain_data->tgt_invalid_tbls_fnd = 0
    SET ddr_domain_data->tgt_invalid_tbls_ts = 0
    SET ddr_domain_data->tgt_preserve_fnd = 0
    SET ddr_domain_data->tgt_forms_fnd = 0
    SET ddr_domain_data->tgt_forms_ts = 0
    SET ddr_domain_data->tgt_dbas_fnd = 0
    SET ddr_domain_data->tgt_dbas_ts = 0
    SET ddr_domain_data->tgt_users_fnd = 0
    SET ddr_domain_data->tgt_users_ts = 0
    SET ddr_domain_data->tgt_sys_reg_fnd = 0
    SET ddr_domain_data->tgt_sys_reg_ts = 0
    SET ddr_domain_data->tgt_sysdef_reg_fnd = 0
    SET ddr_domain_data->tgt_sysdef_reg_ts = 0
    SET ddr_domain_data->tgt_wh_fnd = 0
    SET ddr_domain_data->tgt_wh_ts = 0
    SET ddr_domain_data->tgt_ccluserdir_fnd = 0
    SET ddr_domain_data->tgt_ccluserdir_ts = 0
    SET dm_err->eproc = concat("Check TARGET DATA",ddr_domain_data->tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->data_file_name)) > 0)
     SET ddr_domain_data->tgt_data_fnd = 1
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->data_file_name),
      dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_data_ts = dvtd_file_date
     IF (ddr_read_misc_data(0,1)=0)
      RETURN(0)
     ELSE
      SET ddr_domain_data->tgt_warehouse_dir = ""
      SET ddr_domain_data->tgt_cer_config_dir = ""
      SET ddr_domain_data->tgt_ccluserdir_dir = ""
      SET ddr_domain_data->tgt_ocdtools_dir = ""
      SET ddr_domain_data->tgt_ccldir = ""
      IF ((((ddr_domain_data->tgt_cer_data_dev="DM2NOTSET")) OR ((((ddr_domain_data->tgt_wh=
      "DM2NOTSET")) OR ((((ddr_domain_data->tgt_wh_device="DM2NOTSET")) OR ((((ddr_domain_data->
      tgt_revision_level="DM2NOTSET")) OR ((((ddr_domain_data->tgt_system="DM2NOTSET")) OR ((((
      ddr_domain_data->tgt_system_pwd="DM2NOTSET")) OR ((((ddr_domain_data->tgt_priv="DM2NOTSET"))
       OR ((((ddr_domain_data->tgt_priv_pwd="DM2NOTSET")) OR ((((ddr_domain_data->tgt_mng="DM2NOTSET"
      )) OR ((((ddr_domain_data->tgt_mng_pwd="DM2NOTSET")) OR ((((ddr_domain_data->
      tgt_tdb_server_master_id=0)
       AND (ddr_domain_data->tgt_tdb_server_slave_id=0)) OR ((((ddr_domain_data->tgt_scp_server_id=0)
      ) OR ((((ddr_domain_data->tgt_auth_server_id=0)) OR ((((ddr_domain_data->tgt_local_user_name=
      "DM2NOTSET")) OR ((((ddr_domain_data->tgt_ccldir="DM2NOTSET")) OR ((((ddr_domain_data->
      tgt_warehouse_dir="DM2NOTSET")) OR ((((ddr_domain_data->tgt_cer_config_dir="DM2NOTSET")) OR (((
      (ddr_domain_data->tgt_ccluserdir_dir="DM2NOTSET")) OR ((((ddr_domain_data->tgt_ocdtools_dir=
      "DM2NOTSET")) OR ((((ddr_domain_data->offline_dict_ind=- (1))) OR ((((ddr_domain_data->
      tgt_nodes_cnt=0)) OR ((ddr_domain_data->tgt_node_flag=0))) )) )) )) )) )) )) )) )) )) )) )) ))
      )) )) )) )) )) )) )) )) )
       SET ddr_domain_data->tgt_ind_data_fnd = 0
      ELSE
       IF ((ddr_domain_data->tgt_was_arch_ind=1))
        SET ddr_domain_data->tgt_ind_data_fnd = 1
       ELSE
        IF ((((ddr_domain_data->tgt_sec_user_name="DM2NOTSET")) OR ((ddr_domain_data->
        tgt_sec_server_master_id=0)
         AND (ddr_domain_data->tgt_sec_server_slave_id=0))) )
         SET ddr_domain_data->tgt_ind_data_fnd = 0
        ELSE
         SET ddr_domain_data->tgt_ind_data_fnd = 1
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Check for TARGET preserved passwords")
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (ddr_validate_preserve_pwds(null)=0)
     RETURN(0)
    ENDIF
    IF ((ddr_domain_data->tgt_preserve_pwds_cnt=- (1)))
     SET ddr_domain_data->tgt_ind_data_fnd = 0
    ENDIF
    IF ((ddr_domain_data->tgt_ind_data_fnd=0))
     SET ddr_domain_data->tgt_restart_ind = 0
     RETURN(1)
    ENDIF
    SET dm_err->eproc = concat("Check TARGET ENV REGISTRY SETTINGS in ",ddr_domain_data->
     tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,dvtd_reg_tgt_env,"_env.reg")) > 0)
     SET ddr_domain_data->tgt_env_reg_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,dvtd_reg_tgt_env,"_env.reg"),
      dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_env_reg_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_env_reg_fnd = 0
    ENDIF
    SET dm_err->eproc = concat("Check TARGET ",dvtd_cerinstall,"/dic.dat")
    CALL disp_msg(" ",dm_err->logfile,0)
    IF ((((dm2_sys_misc->cur_os="AXP")
     AND dm2_findfile(concat(dvtd_cerinstall,"dic.dat")) > 0) OR ((dm2_sys_misc->cur_os != "AXP")
     AND dm2_findfile(concat(dvtd_cerinstall,"/dic.dat")) > 0
     AND dm2_findfile(concat(dvtd_cerinstall,"/dic.idx")) > 0)) )
     SET ddr_domain_data->tgt_dict_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(concat(dvtd_cerinstall,evaluate(dm2_sys_misc->cur_os,"AXP","dic.dat",
        "/dic.dat")),dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_dict_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_dict_fnd = 0
    ENDIF
    SET dm_err->eproc = concat("Check TARGET TDB in ",ddr_domain_data->tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,"_tdb.msg"))
     > 0)
     SET ddr_domain_data->tgt_tdb_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
       "_tdb.msg"),dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_tdb_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_tdb_fnd = 0
    ENDIF
    SET dm_err->eproc = concat("Check TARGET SERVER DEFINITIONS in ",ddr_domain_data->
     tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dvtd_scp_cnt = 0
    FOR (dvtd_cnt = 1 TO ddr_domain_data->tgt_nodes_cnt)
      SET dvtd_str = ""
      SET dvtd_str = concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_domain_name,"_",
       ddr_domain_data->tgt_nodes[dvtd_cnt].node_name,"_save.scp")
      IF (dm2_findfile(dvtd_str) > 0)
       SET dvtd_scp_cnt = (dvtd_scp_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((dvtd_scp_cnt=ddr_domain_data->tgt_nodes_cnt))
     SET ddr_domain_data->tgt_srv_def_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_domain_name,
       "_",ddr_domain_data->tgt_nodes[1].node_name,"_save.scp"),dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_srv_def_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_srv_def_fnd = 0
    ENDIF
    IF ((ddr_domain_data->tgt_was_arch_ind=0))
     SET dm_err->eproc = concat("Check TARGET SEC_USER in ",ddr_domain_data->tgt_tmp_full_dir)
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
       "_sec_user.dat")) > 0)
      SET ddr_domain_data->tgt_sec_user_fnd = 1
      SET dvtd_file_date = 0.0
      IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
        "_sec_user.dat"),dvtd_file_date)=0)
       RETURN(0)
      ENDIF
      SET ddr_domain_data->tgt_sec_user_ts = dvtd_file_date
     ELSE
      SET ddr_domain_data->tgt_sec_user_fnd = 0
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Check TARGET SYSTEM DEFINITION REGISTRY SETTINGS in ",ddr_domain_data
     ->tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,dvtd_reg_tgt_env,"_sysdef.reg")) > 0)
     SET ddr_domain_data->tgt_sysdef_reg_fnd = 1
     SET dvsd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,dvtd_reg_tgt_env,"_sysdef.reg"),
      dvsd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_sysdef_reg_ts = dvsd_file_date
    ELSE
     SET ddr_domain_data->tgt_sysdef_reg_fnd = 0
    ENDIF
    SET dm_err->eproc = concat("Check TARGET NON-STANDARD tables in ",ddr_domain_data->
     tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dvtd_file = concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->exp_parfile_prefix,
     "*.dmp")
    IF ((dm2_sys_misc->cur_os != "LNX"))
     IF (dm2_findfile(dvtd_file) > 0)
      SET ddr_domain_data->tgt_invalid_tbls_fnd = 1
      SET dvtd_file_date = 0.0
      IF (ddr_get_file_date(dvtd_file,dvtd_file_date)=0)
       RETURN(0)
      ENDIF
      SET ddr_domain_data->tgt_invalid_tbls_ts = dvtd_file_date
     ELSE
      SET ddr_domain_data->tgt_invalid_tbls_fnd = 0
     ENDIF
    ELSE
     IF (ddr_lnx_findfile(dvtd_file) > 0)
      SET ddr_domain_data->tgt_invalid_tbls_fnd = 1
      SET dvtd_file_date = 0.0
      IF (ddr_get_file_date(dvtd_file,dvtd_file_date)=0)
       RETURN(0)
      ENDIF
      SET ddr_domain_data->tgt_invalid_tbls_ts = dvtd_file_date
     ELSE
      SET ddr_domain_data->tgt_invalid_tbls_fnd = 0
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Check TARGET Warehouse backup in ",ddr_domain_data->tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dvtd_file = concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,"_",
      ddr_domain_data->tgt_wh,".sav")
    ELSE
     SET dvtd_file = concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,"_wh.sav")
    ENDIF
    IF (dm2_findfile(dvtd_file) > 0)
     SET ddr_domain_data->tgt_wh_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(dvtd_file,dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_wh_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_wh_fnd = 0
    ENDIF
    SET dm_err->eproc = concat("Check for preserved data in ",ddr_domain_data->tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_clin_copy_data->temp_location = ddr_domain_data->tgt_tmp_full_dir
    SET dm2_install_schema->schema_prefix = "dm2s"
    IF (drr_chk_for_preserved_data(dvtd_pd_present)=0)
     RETURN(0)
    ENDIF
    IF (dvtd_pd_present=1)
     SET ddr_domain_data->tgt_preserve_fnd = 1
     SET dvtd_file = concat(ddr_domain_data->tgt_tmp_full_dir,drr_clin_copy_data->preserve_tbl_pre,
      evaluate(dm2_sys_misc->cur_os,"AXP","*.*;*","*.*"))
     IF (ddr_get_file_date(dvtd_file,dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_preserve_ts = dvtd_file_date
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET ddr_domain_data->tgt_forms_fnd = 1
     SET ddr_domain_data->tgt_forms_ts = cnvtdatetime("22-JUL-1978")
    ELSE
     SET dm_err->eproc = "Check TARGET for cer_forms data"
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dvtd_find_str = concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
      "_frmque.sav")
     SET dvtd_found = dm2_findfile(dvtd_find_str)
     IF (dvtd_found > 0)
      IF (ddr_get_file_date(dvtd_find_str,dvtd_file_date)=0)
       RETURN(0)
      ENDIF
      SET ddr_domain_data->tgt_forms_fnd = 1
      SET ddr_domain_data->tgt_forms_ts = dvtd_file_date
     ELSE
      SET dvtd_find_str = concat(trim(logical("cer_forms")),"/","form*")
      IF ((dm2_sys_misc->cur_os != "LNX"))
       SET dvtd_found = dm2_findfile(dvtd_find_str)
       IF (dvtd_found=0)
        SET dvtd_find_str = concat(ddr_domain_data->tgt_tmp_full_dir,"queue*")
        SET dvtd_found = dm2_findfile(dvtd_find_str)
       ENDIF
      ELSE
       SET dvtd_found = ddr_lnx_findfile(dvtd_find_str)
       IF (dvtd_found=0)
        SET dvtd_find_str = concat(ddr_domain_data->tgt_tmp_full_dir,"queue*")
        SET dvtd_found = ddr_lnx_findfile(dvtd_find_str)
       ENDIF
      ENDIF
      IF (dvtd_found > 0)
       SET ddr_domain_data->tgt_forms_fnd = 0
      ELSE
       SET ddr_domain_data->tgt_forms_fnd = 1
       SET ddr_domain_data->tgt_forms_ts = cnvtdatetime("22-JUL-1978")
      ENDIF
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Check CCL DBA backup in ",ddr_domain_data->tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,"_dbas.dat"))
     > 0)
     SET ddr_domain_data->tgt_dbas_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
       "_dbas.dat"),dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_dbas_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_dbas_fnd = 0
    ENDIF
    IF ((dm2_sys_misc->cur_os IN ("AXP", "LNX")))
     SET ddr_domain_data->tgt_users_fnd = 1
    ELSE
     SET dm_err->eproc = concat("Check for TARGET USERS BACKUP in ",ddr_domain_data->tgt_tmp_full_dir
      )
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
       "_grp_users.dat")) > 0)
      SET ddr_domain_data->tgt_users_fnd = 1
      SET dvtd_file_date = 0.0
      IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
        "_grp_users.dat"),dvtd_file_date)=0)
       RETURN(0)
      ENDIF
      SET ddr_domain_data->tgt_users_ts = dvtd_file_date
     ELSE
      SET ddr_domain_data->tgt_users_fnd = 0
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Check for SYS REGISTRY SETTINGS in ",ddr_domain_data->
     tgt_tmp_full_dir)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,dvtd_reg_tgt_env,"_sys.reg")) > 0)
     SET ddr_domain_data->tgt_sys_reg_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,dvtd_reg_tgt_env,"_sys.reg"),
      dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_sys_reg_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_sys_reg_fnd = 0
    ENDIF
    SET dm_err->eproc = concat("Check TARGET CCLUSERDIR backup in ",ddr_domain_data->tgt_tmp_full_dir
     )
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
      "_ccluserdir.sav")) > 0)
     SET ddr_domain_data->tgt_ccluserdir_fnd = 1
     SET dvtd_file_date = 0.0
     IF (ddr_get_file_date(concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,
       "_ccluserdir.sav"),dvtd_file_date)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_ccluserdir_ts = dvtd_file_date
    ELSE
     SET ddr_domain_data->tgt_ccluserdir_fnd = 0
    ENDIF
    IF ((ddr_domain_data->tgt_data_fnd=1)
     AND (ddr_domain_data->tgt_tdb_fnd=1)
     AND (ddr_domain_data->tgt_srv_def_fnd=1)
     AND (ddr_domain_data->tgt_sysdef_reg_fnd=1)
     AND (ddr_domain_data->tgt_env_reg_fnd=1)
     AND (ddr_domain_data->tgt_ind_data_fnd=1)
     AND (ddr_domain_data->tgt_dbas_fnd=1)
     AND (ddr_domain_data->tgt_users_fnd=1)
     AND (ddr_domain_data->tgt_sys_reg_fnd=1)
     AND (ddr_domain_data->tgt_forms_fnd=1))
     IF ((ddr_domain_data->tgt_was_arch_ind=1))
      SET ddr_domain_data->tgt_restart_ind = 1
     ELSE
      IF ((ddr_domain_data->tgt_sec_user_fnd=1))
       SET ddr_domain_data->tgt_restart_ind = 1
      ELSE
       SET ddr_domain_data->tgt_restart_ind = 0
      ENDIF
     ENDIF
    ELSE
     SET ddr_domain_data->tgt_restart_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_collect_target_data(null)
   DECLARE dctd_recollect = i2 WITH protect, noconstant(0)
   DECLARE dctd_str = vc WITH protect, noconstant("")
   DECLARE dctd_mode = i2 WITH protect, noconstant(0)
   DECLARE dvtd_preserve_ret = i2 WITH protect, noconstant(0)
   DECLARE dvtd_run_id = i4 WITH protect, noconstant(0)
   DECLARE dvtd_total_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvtd_complete_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvtd_left_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvtd_running_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvtd_failed_cnt = i4 WITH protect, noconstant(0)
   DECLARE dctd_ora_home = vc WITH protect, noconstant("")
   DECLARE dctd_prim_node = vc WITH protect, noconstant("")
   DECLARE dctd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dctd_cmd = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Collect TARGET data."
   CALL disp_msg("",dm_err->logfile,0)
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    SET dm_err->eproc = "Response file detected and will be used to collect data."
    CALL disp_msg("",dm_err->logfile,0)
    IF (validate(drrr_rf_data->responsefile_version,"X")="X"
     AND validate(drrr_rf_data->responsefile_version,"Z")="Z")
     SET dm_err->eproc = "Verify response file structures accessible"
     SET dm_err->emsg = "Response file structure could not be accessed."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drrr_rf_data)
     CALL echorecord(drrr_misc_data)
    ENDIF
    SET dm2_install_schema->v500_p_word = drrr_rf_data->tgt_db_user_pwd
    SET dm2_install_schema->v500_connect_str = drrr_rf_data->tgt_db_cnct_str
    SET dm2_install_schema->target_dbase_name = drrr_rf_data->tgt_db_name
    SET ddr_domain_data->tgt_env = trim(cnvtlower(drrr_rf_data->tgt_env_name))
    SET ddr_domain_data->tgt_mng = drrr_rf_data->tgt_high_priv_user
    SET ddr_domain_data->tgt_mng_pwd = drrr_rf_data->tgt_high_priv_user_pwd
    SET dctd_prim_node = drrr_rf_data->tgt_primary_app_node
    IF ((drrr_misc_data->tgt_retain_db_user_cnt > 0))
     SET drr_retain_db_users->cnt = drrr_misc_data->tgt_retain_db_user_cnt
     SET stat = alterlist(drr_retain_db_users->user,drr_retain_db_users->cnt)
     FOR (dctd_cnt = 1 TO drr_retain_db_users->cnt)
       SET drr_retain_db_users->user[dctd_cnt].user_name = drrr_misc_data->tgt_retain_db_users[
       dctd_cnt].user_name
     ENDFOR
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm2_install_schema)
     CALL echorecord(ddr_domain_data)
     CALL echorecord(drr_retain_db_users)
    ENDIF
   ENDIF
   IF (ddr_validate_target_data(null)=0)
    RETURN(0)
   ENDIF
   IF ((ddr_domain_data->process="REFRESH")
    AND (ddr_domain_data->tgt_tmp_src_dir_exists=0))
    SET dctd_str = evaluate(dm2_sys_misc->cur_os,"AXP",concat(ddr_domain_data->tgt_tmp_dev,":[",
      ddr_domain_data->tgt_tmp_dir,".",ddr_domain_data->src_env,
      "]"),concat(ddr_domain_data->tgt_tmp_dir,ddr_domain_data->src_env,"/"))
    IF (ddr_create_dir(dctd_str)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->tgt_tmp_src_dir_exists = 1
   ENDIF
   IF ((ddr_domain_data->tgt_restart_ind=1)
    AND (ddr_domain_data->process="REFRESH"))
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET dctd_recollect = 1
     SET dm_err->eproc =
     "Target data previously collected.  Forcing recollection as part of response file path."
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     IF (ddr_summary(0,1)=0)
      RETURN(0)
     ENDIF
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,7,131)
     CALL text(1,2,"PREVIOUS START ATTEMPTED")
     CALL text(3,4,"Would you like to recollect ALL data again or proceed with collected data?")
     CALL text(4,4,
      'Enter "P" to proceed with currently collected data specified in previous summary screen.')
     CALL text(5,4,'Enter "R" to recollect data.')
     CALL text(6,4,'Enter "Q" to Quit.')
     CALL accept(3,80,"A;cu"," "
      WHERE curaccept IN ("R", "P", "Q"))
     CALL clear(1,1)
     SET message = nowindow
     IF (curaccept="Q")
      SET dm_err->emsg = "User elected to not continue."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curaccept="R")
      SET dctd_recollect = 1
     ENDIF
    ENDIF
   ELSEIF ((ddr_domain_data->tgt_tmp_dir_exists=1)
    AND (ddr_domain_data->process="REFRESH"))
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET dm_err->eproc = "Not all data present, data will be recollected."
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,6,131)
     CALL text(3,4,concat("The ",ddr_domain_data->tgt_tmp_full_dir,
       " directory exists and will be cleared."))
     CALL text(5,4,'Enter "Y" to proceed. Enter "N" to abort process.')
     CALL accept(5,67,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     CALL clear(1,1)
     SET message = nowindow
     IF (curaccept="N")
      SET dm_err->emsg = concat("User elected to not continue with the removal of ",ddr_domain_data->
       tgt_tmp_full_dir)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_domain_data)
   ENDIF
   IF ((((ddr_domain_data->tgt_restart_ind=0)) OR ((ddr_domain_data->tgt_restart_ind=1)
    AND dctd_recollect=1)) )
    IF ((ddr_domain_data->process="REFRESH"))
     IF ((dm2_sys_misc->cur_os IN ("AIX", "LNX", "HPX")))
      SET dctd_cmd = concat("chmod 777 $CCLUSERDIR/")
      IF (dm2_push_dcl(dctd_cmd)=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF (ddr_create_dir(ddr_domain_data->tgt_tmp_full_dir)=0)
      RETURN(0)
     ENDIF
    ELSEIF ((ddr_domain_data->process="REPLICATE")
     AND validate(drrr_responsefile_in_use,- (1))=1)
     IF (ddr_create_dir(ddr_domain_data->tgt_tmp_full_dir)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((ddr_domain_data->process="REFRESH"))
     IF (der_determine_expimp_mode(dctd_mode)=0)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->standalone_expimp_mode = dctd_mode
     SET ddr_domain_data->preserve_user_ind = 0
     IF ((ddr_domain_data->standalone_expimp_mode=1))
      IF (validate(drrr_responsefile_in_use,- (1))=1)
       IF (dctd_prim_node=cnvtlower(trim(curnode)))
        SET ddr_domain_data->preserve_ind = evaluate(drrr_rf_data->tgt_preserve_data,"YES",1,0)
        SET ddr_domain_data->preserve_user_ind = evaluate(drr_retain_db_users->cnt,0,0,1)
       ELSE
        IF ((dm_err->debug_flag > 0))
         CALL echo("Not on primary application node - skipping preserve logic")
        ENDIF
        SET ddr_domain_data->preserve_ind = 0
       ENDIF
      ELSE
       IF (ddr_preserve_prompt(dvtd_preserve_ret)=0)
        RETURN(0)
       ENDIF
       SET ddr_domain_data->preserve_ind = dvtd_preserve_ret
      ENDIF
      IF ((((ddr_domain_data->preserve_ind=1)) OR ((ddr_domain_data->preserve_user_ind=1))) )
       IF ((((dm2_install_schema->target_dbase_name="NONE")) OR ((((dm2_install_schema->v500_p_word=
       "NONE")) OR ((dm2_install_schema->v500_connect_str="NONE"))) )) )
        SET dm2_install_schema->dbase_name = '"TARGET"'
        SET dm2_install_schema->u_name = "V500"
        SET dm2_force_connect_string = 1
        EXECUTE dm2_connect_to_dbase "PC"
        SET dm2_force_connect_string = 0
        IF ((dm_err->err_ind=1))
         RETURN(0)
        ENDIF
        SET dm2_install_schema->target_dbase_name = currdbname
        SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
        SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
       ENDIF
       IF (der_manage_admin_data(dm2_install_schema->target_dbase_name,"DM2_ADMIN_DM_INFO","S","ALL",
        "")=0)
        RETURN(0)
       ENDIF
       IF ((der_expimp_data->setup_complete_ind=0))
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->eproc = "Validating standalone export setup work has been completed."
        SET dm_err->emsg = "Setup work not completed for standalone export process."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       SET der_expimp_data->preserve_from_begin = 1
       SET dm_err->eproc = "Get Clin Copy-Preserve DDL from Target."
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       SELECT INTO "nl:"
        FROM dm2_ddl_ops_log ddol
        WHERE (ddol.run_id=
        (SELECT
         ddo.run_id
         FROM dm2_ddl_ops ddo
         WHERE ddo.process_option="CLIN COPY-PRESERVE"))
         AND ddol.status="COMPLETE"
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSEIF (curqual > 0)
        IF (validate(drrr_responsefile_in_use,- (1))=1)
         SET der_expimp_data->preserve_from_begin = 1
        ELSE
         SET dvtd_preserve_ret = 0
         IF (ddr_preserve_check_prompt(dvtd_preserve_ret)=0)
          RETURN(0)
         ENDIF
         IF (dvtd_preserve_ret=1)
          SET der_expimp_data->preserve_from_begin = 0
         ELSE
          SET der_expimp_data->preserve_from_begin = 1
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSE
      SET ddr_domain_data->preserve_ind = 1
     ENDIF
    ENDIF
    SET ddr_domain_data->tgt_tmp_dir_exists = 1
    IF ( NOT ((dm2_sys_misc->cur_os="AXP")))
     SET dctd_ora_home = trim(logical("oracle_home"))
     IF (ddr_check_sqlnet(0,1,dctd_ora_home)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET stat = alterlist(ddr_domain_data->tgt_nodes,0)
    SET ddr_domain_data->tgt_nodes_cnt = 0
    SET ddr_domain_data->tgt_restart_ind = 0
    SET ddr_domain_data->get_ccluserdir = 0
    SET ddr_domain_data->get_warehouse = 0
    SET ddr_domain_data->get_invalid_tables = 0
    IF (ddr_get_new_target_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_create_dir(dcd_dir_name)
   DECLARE dcd_cmd_txt = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Create directory:",dcd_dir_name)
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm2_find_dir(dcd_dir_name))
    SET dm_err->eproc = concat("Clear the following directory:",dcd_dir_name)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (ddr_clear_dir(dcd_dir_name)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Create the following directory:",dcd_dir_name)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dcd_cmd_txt = concat("create/dir/vers=1/prot=(s:rwed,o:rwed,g:rwed,w:rwed) ",dcd_dir_name)
    ELSE
     SET dcd_cmd_txt = concat("mkdir -pm 755 ",dcd_dir_name)
    ENDIF
    IF (dm2_push_dcl(dcd_cmd_txt)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_clear_dir(ddd_dir_name)
   DECLARE ddd_cmd_txt = vc WITH protect, noconstant("")
   DECLARE ddd_dir_txt = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Clear the following directory:",ddd_dir_name)
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET ddd_cmd_txt = concat("delete ",ddd_dir_name,"*.*;*")
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(ddd_cmd_txt)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dm_err)
     ENDIF
    ENDIF
    IF (findstring("file not found",dm_err->errtext,1,0)=0
     AND (dm_err->errtext != ""))
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET ddd_cmd_txt = concat("rm -f ",ddd_dir_name,"*.*")
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(ddd_cmd_txt)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dm_err)
     ENDIF
    ENDIF
    IF (findstring("does not exist",dm_err->errtext,1,0)=0
     AND findstring("not found",dm_err->errtext,1,0)=0
     AND (dm_err->errtext != ""))
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET ddd_cmd_txt = concat("for i in `ls -ld ",ddd_dir_name,
     "* | awk {'print $9'}`;do rm -rf $i ;done")
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(ddd_cmd_txt)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dm_err)
     ENDIF
    ENDIF
    IF (findstring("does not exist",dm_err->errtext,1,0)=0
     AND findstring("not found",dm_err->errtext,1,0)=0
     AND findstring("No such file or directory",dm_err->errtext,1,0)=0
     AND (dm_err->errtext != ""))
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_env_confirm(dec_src_env,dec_tgt_env,dec_env_to_chk,dec_env_ok_ret)
   DECLARE dec_prompt_str = vc WITH protect, noconstant("")
   SET dec_prompt_str = concat("Is ",dec_env_to_chk," the correct Environment Name for ",evaluate(
     dec_src_env,1,"SOURCE","TARGET")," environment (Y,N)?")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,5,131)
   CALL text(3,4,dec_prompt_str)
   CALL accept(3,(size(dec_prompt_str)+ 5),"A;cu"," "
    WHERE curaccept IN ("Y", "N"))
   SET dec_env_ok_ret = evaluate(curaccept,"Y",1,0)
   CALL clear(1,1)
   SET message = nowindow
   IF (dec_env_ok_ret=1)
    IF (dec_src_env=1)
     SET ddr_domain_data->src_env = cnvtlower(dec_env_to_chk)
    ELSE
     SET ddr_domain_data->tgt_env = cnvtlower(dec_env_to_chk)
    ENDIF
   ELSE
    SET dm_err->emsg = concat('Environment obtained from "environment" logical, ',dec_env_to_chk,
     " ,is not correct.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_env_logical(dgel_log_ret)
   SET dm_err->eproc = "Get environment name via environment logical"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dgel_log_ret = ""
   SET dgel_log_ret = cnvtlower(trim(logical("environment")))
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("ENVIRONMENT LOGICAL:",dgel_log_ret))
   ENDIF
   IF (trim(dgel_log_ret) > " ")
    RETURN(1)
   ELSE
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE ddr_node_prompt(dnp_src_node,dnp_tgt_node,dnp_node_ret)
   SET dm_err->eproc = "Prompt user for node name."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,5,131)
   CALL text(3,4,concat("Is this process being run from the ",evaluate(dnp_src_node,0,"TARGET",
      "SOURCE")," primary application node?"))
   CALL accept(3,64,"A;cu"," "
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SET dnp_node_ret = cnvtlower(trim(curnode))
   ELSE
    SET message = nowindow
    SET dm_err->emsg = concat("Process must be run from ",evaluate(dnp_src_node,0,"TARGET","SOURCE"),
     " application node.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   IF (dnp_src_node=1)
    SET ddr_domain_data->src_nodes_cnt = (ddr_domain_data->src_nodes_cnt+ 1)
    SET stat = alterlist(ddr_domain_data->src_nodes,ddr_domain_data->src_nodes_cnt)
    SET ddr_domain_data->src_nodes[ddr_domain_data->src_nodes_cnt].node_name = dnp_node_ret
   ELSE
    SET ddr_domain_data->tgt_nodes_cnt = (ddr_domain_data->tgt_nodes_cnt+ 1)
    SET stat = alterlist(ddr_domain_data->tgt_nodes,ddr_domain_data->tgt_nodes_cnt)
    SET ddr_domain_data->tgt_nodes[ddr_domain_data->tgt_nodes_cnt].node_name = dnp_node_ret
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_dev_prompt(ddp_src_dev,ddp_tgt_dev,ddp_dev_ret)
   DECLARE ddp_str = vc WITH protect, noconstant("")
   SET ddp_str = concat("Enter ",evaluate(ddp_src_dev,1,"SOURCE","TARGET"),
    " device name for storage of temporary files:")
   SET dm_err->eproc = "Prompt user for device name."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,5,131)
   CALL text(3,4,ddp_str)
   CALL accept(3,(size(ddp_str)+ 5),"P(30);CF"," "
    WHERE curaccept != " ")
   IF (findstring(":",trim(curaccept),1,1)=size(trim(curaccept)))
    SET ddp_dev_ret = cnvtlower(substring(1,(size(trim(curaccept)) - 1),curaccept))
   ELSE
    SET ddp_dev_ret = cnvtlower(curaccept)
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_dir_prompt(ddp_src_dir,ddp_tgt_dir,ddp_dir_ret)
   DECLARE ddp_file_delim = vc WITH protect, noconstant("")
   DECLARE ddp_example_txt = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Prompt user for temporary directory."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,6,131)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET ddp_example_txt = concat("replicate_backup.",trim(cnvtlower(curnode)))
    SET ddp_file_delim = "]"
   ELSE
    SET ddp_example_txt = concat("/cerner/replicate_backup/",trim(cnvtlower(curnode)),"/")
    SET ddp_file_delim = "/"
   ENDIF
   CALL text(3,4,concat("Enter Temporary Directory for ",evaluate(ddp_src_dir,1,"SOURCE","TARGET"),
     " (i.e. ",ddp_example_txt,"):"))
   CALL accept(5,8,"P(90);C",""
    WHERE  NOT (curaccept=""))
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET ddp_dir_ret = curaccept
   ELSE
    IF (substring(1,1,curaccept) != ddp_file_delim)
     SET ddp_dir_ret = concat(ddp_file_delim,curaccept)
    ELSE
     SET ddp_dir_ret = curaccept
    ENDIF
    IF (findstring(ddp_file_delim,trim(ddp_dir_ret),1,1) != size(trim(ddp_dir_ret)))
     SET ddp_dir_ret = concat(trim(ddp_dir_ret),ddp_file_delim)
    ENDIF
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_validate_user(dvu_env_name)
   DECLARE dvu_str = vc WITH protect, noconstant("")
   DECLARE dvu_reg_ret = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Validating User"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os != "AXP")
    AND cnvtupper(curuser) != "ROOT")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Current user is not the ROOT user."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((dm2_sys_misc->cur_os="AXP"))
    SET dvu_str = concat("\environment\",dvu_env_name," LocalUserName")
    IF (ddr_lreg_oper("GET",dvu_str,dvu_reg_ret)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(curuser) != cnvtupper(dvu_reg_ret))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Making sure current user is the domain user."
     SET dm_err->emsg = "Current user is not the domain user."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_validate_source_env(dvse_chk_dir)
   DECLARE dvse_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Prompt for SOURCE environment name"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((ddr_domain_data->src_env="DM2NOTSET"))
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET ddr_domain_data->src_env = cnvtlower(drrr_rf_data->src_env_name)
    ELSE
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,5,131)
     CALL text(3,4,"Please enter SOURCE environment name:")
     CALL accept(3,44,"P(30);C"," "
      WHERE curaccept > " ")
     SET ddr_domain_data->src_env = curaccept
     CALL clear(1,1)
     SET message = nowindow
    ENDIF
   ENDIF
   IF (dvse_chk_dir=1)
    SET dvse_str = evaluate(dm2_sys_misc->cur_os,"AXP",concat(ddr_domain_data->tgt_tmp_dev,":[",
      ddr_domain_data->tgt_tmp_dir,".",ddr_domain_data->src_env,
      "]"),concat(ddr_domain_data->tgt_tmp_dir,ddr_domain_data->src_env,"/"))
    SET dm_err->eproc = concat("Verify that ",dvse_str," directory exists")
    IF ( NOT (dm2_find_dir(dvse_str)))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Directory for SOURCE environment does not exist."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_pop_reg_struct(dprs_type,dprs_file,dprs_reset)
   DECLARE dprs_str = vc WITH protect, noconstant("")
   DECLARE dprs_new = i2 WITH protect, noconstant(0)
   DECLARE dprs_new_key = i2 WITH protect, noconstant(0)
   DECLARE dprs_new_prop = i2 WITH protect, noconstant(0)
   DECLARE dprs_ckcnt = i4 WITH protect, noconstant(0)
   DECLARE dprs_skcnt = i4 WITH protect, noconstant(0)
   DECLARE dprs_tkcnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Open ",dprs_file," and load registry data")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dprs_reset=1)
    CASE (dprs_type)
     OF 1:
      FOR (dprs_skcnt = 1 TO ddr_reg->skcnt)
       SET ddr_reg->skey[dprs_skcnt].spcnt = 0
       SET stat = alterlist(ddr_reg->skey[dprs_skcnt].sprop,0)
      ENDFOR
      SET ddr_reg->skcnt = 0
      SET stat = alterlist(ddr_reg->skey,ddr_reg->skcnt)
     OF 2:
      FOR (dprs_tkcnt = 1 TO ddr_reg->tkcnt)
       SET ddr_reg->tkey[dprs_tkcnt].tpcnt = 0
       SET stat = alterlist(ddr_reg->tkey[dprs_tkcnt].tprop,0)
      ENDFOR
      SET ddr_reg->tkcnt = 0
      SET stat = alterlist(ddr_reg->tkey,ddr_reg->tkcnt)
     OF 3:
      FOR (dprs_ckcnt = 1 TO ddr_reg->ckcnt)
       SET ddr_reg->ckey[dprs_ckcnt].cpcnt = 0
       SET stat = alterlist(ddr_reg->ckey[dprs_ckcnt].cprop,0)
      ENDFOR
      SET ddr_reg->ckcnt = 0
      SET stat = alterlist(ddr_reg->ckey,ddr_reg->ckcnt)
    ENDCASE
   ENDIF
   FREE SET dprs_data_file
   SET logical dprs_data_file dprs_file
   FREE DEFINE rtl3
   DEFINE rtl3 "dprs_data_file"
   SELECT INTO "nl:"
    t.line
    FROM rtl3t t
    WHERE t.line > " "
    HEAD REPORT
     dprs_new = 1
    DETAIL
     dprs_str = trim(t.line,3)
     CASE (dprs_type)
      OF 1:
       IF (substring(1,2,dprs_str)="[\")
        ddr_reg->skcnt = (ddr_reg->skcnt+ 1), stat = alterlist(ddr_reg->skey,ddr_reg->skcnt), ddr_reg
        ->skey[ddr_reg->skcnt].skeyname = cnvtlower(substring(2,(size(dprs_str) - 2),dprs_str))
       ELSE
        IF (substring(1,1,dprs_str) != "\"
         AND (ddr_reg->skcnt > 0))
         ddr_reg->skey[ddr_reg->skcnt].spcnt = (ddr_reg->skey[ddr_reg->skcnt].spcnt+ 1), stat =
         alterlist(ddr_reg->skey[ddr_reg->skcnt].sprop,ddr_reg->skey[ddr_reg->skcnt].spcnt), ddr_reg
         ->skey[ddr_reg->skcnt].sprop[ddr_reg->skey[ddr_reg->skcnt].spcnt].spropname_orig = substring
         (1,(findstring("=",dprs_str,1,0) - 1),dprs_str),
         ddr_reg->skey[ddr_reg->skcnt].sprop[ddr_reg->skey[ddr_reg->skcnt].spcnt].spropname =
         cnvtlower(substring(1,(findstring("=",dprs_str,1,0) - 1),dprs_str)), ddr_reg->skey[ddr_reg->
         skcnt].sprop[ddr_reg->skey[ddr_reg->skcnt].spcnt].spropval = substring((findstring("=",
           dprs_str,1,0)+ 1),(size(dprs_str) - findstring("=",dprs_str,1,0)),dprs_str)
        ENDIF
       ENDIF
      OF 2:
       IF (substring(1,2,dprs_str)="[\")
        ddr_reg->tkcnt = (ddr_reg->tkcnt+ 1), stat = alterlist(ddr_reg->tkey,ddr_reg->tkcnt), ddr_reg
        ->tkey[ddr_reg->tkcnt].tkeyname = cnvtlower(substring(2,(size(dprs_str) - 2),dprs_str))
       ELSE
        IF (substring(1,1,dprs_str) != "\"
         AND (ddr_reg->tkcnt > 0))
         ddr_reg->tkey[ddr_reg->tkcnt].tpcnt = (ddr_reg->tkey[ddr_reg->tkcnt].tpcnt+ 1), stat =
         alterlist(ddr_reg->tkey[ddr_reg->tkcnt].tprop,ddr_reg->tkey[ddr_reg->tkcnt].tpcnt), ddr_reg
         ->tkey[ddr_reg->tkcnt].tprop[ddr_reg->tkey[ddr_reg->tkcnt].tpcnt].tpropname_orig = substring
         (1,(findstring("=",dprs_str,1,0) - 1),dprs_str),
         ddr_reg->tkey[ddr_reg->tkcnt].tprop[ddr_reg->tkey[ddr_reg->tkcnt].tpcnt].tpropname =
         cnvtlower(substring(1,(findstring("=",dprs_str,1,0) - 1),dprs_str)), ddr_reg->tkey[ddr_reg->
         tkcnt].tprop[ddr_reg->tkey[ddr_reg->tkcnt].tpcnt].tpropval = substring((findstring("=",
           dprs_str,1,0)+ 1),(size(dprs_str) - findstring("=",dprs_str,1,0)),dprs_str)
        ENDIF
       ENDIF
      OF 3:
       IF (substring(1,2,dprs_str)="[\")
        ddr_reg->ckcnt = (ddr_reg->ckcnt+ 1), stat = alterlist(ddr_reg->ckey,ddr_reg->ckcnt), ddr_reg
        ->ckey[ddr_reg->ckcnt].ckeyname = cnvtlower(substring(2,(size(dprs_str) - 2),dprs_str))
       ELSE
        IF (substring(1,1,dprs_str) != "\"
         AND (ddr_reg->ckcnt > 0))
         ddr_reg->ckey[ddr_reg->ckcnt].cpcnt = (ddr_reg->ckey[ddr_reg->ckcnt].cpcnt+ 1), stat =
         alterlist(ddr_reg->ckey[ddr_reg->ckcnt].cprop,ddr_reg->ckey[ddr_reg->ckcnt].cpcnt), ddr_reg
         ->ckey[ddr_reg->ckcnt].cprop[ddr_reg->ckey[ddr_reg->ckcnt].cpcnt].cpropname_orig = substring
         (1,(findstring("=",dprs_str,1,0) - 1),dprs_str),
         ddr_reg->ckey[ddr_reg->ckcnt].cprop[ddr_reg->ckey[ddr_reg->ckcnt].cpcnt].cpropname =
         cnvtlower(substring(1,(findstring("=",dprs_str,1,0) - 1),dprs_str)), ddr_reg->ckey[ddr_reg->
         ckcnt].cprop[ddr_reg->ckey[ddr_reg->ckcnt].cpcnt].cpropval = substring((findstring("=",
           dprs_str,1,0)+ 1),(size(dprs_str) - findstring("=",dprs_str,1,0)),dprs_str)
        ENDIF
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_reg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_srv_info(dgsi_type,dgsi_tag,dgsi_server_id,dgsi_server_desc)
   DECLARE dgsi_file_name = vc WITH protect, noconstant("")
   DECLARE dgsi_cmd = vc WITH protect, noconstant("")
   DECLARE dgsi_path = vc WITH protect, noconstant("")
   DECLARE dgsi_domain_name = vc WITH protect, noconstant("")
   DECLARE dgsi_user = vc WITH protect, noconstant("")
   DECLARE dgsi_pw = vc WITH protect, noconstant("")
   DECLARE dgsi_srv_path = vc WITH protect, noconstant("")
   DECLARE dgsi_srv_found_flag = i2 WITH protect, noconstant(0)
   DECLARE dgsi_tmp_err_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Find server id and description for ",dgsi_tag)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dgsi_type="src")
    SET dgsi_domain_name = ddr_domain_data->src_domain_name
    SET dgsi_user = ddr_domain_data->src_mng
    SET dgsi_pw = ddr_domain_data->src_mng_pwd
    SET dgsi_path = ddr_domain_data->src_tmp_full_dir
   ELSEIF (dgsi_type="tgt")
    SET dgsi_path = ddr_domain_data->tgt_tmp_full_dir
    SET dgsi_domain_name = ddr_domain_data->tgt_domain_name
    SET dgsi_user = ddr_domain_data->tgt_mng
    SET dgsi_pw = ddr_domain_data->tgt_mng_pwd
   ENDIF
   SET dgsi_server_id = "0"
   SET dgsi_server_desc = "NOT FOUND"
   CASE (dgsi_tag)
    OF "authorize":
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsi_srv_path = "cer_exe:auth_server.exe"
     ELSE
      SET dgsi_srv_path = "cer_exe/auth_server"
     ENDIF
    OF "transaction database master":
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsi_srv_path = "cer_exe:tdb_server.exe -param *master*"
     ELSE
      SET dgsi_srv_path = "cer_exe/tdb_server -param *master*"
     ENDIF
    OF "transaction database slave":
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsi_srv_path = "cer_exe:tdb_server.exe -param *slave*"
     ELSE
      SET dgsi_srv_path = "cer_exe/tdb_server -param *slave*"
     ENDIF
    OF "server control panel":
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsi_srv_path = "cer_exe:scp_server.exe"
     ELSE
      SET dgsi_srv_path = "cer_exe/scp_server"
     ENDIF
    OF "security master":
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsi_srv_path = "cer_exe:sec_server.exe -param *master*"
     ELSE
      SET dgsi_srv_path = "cer_exe/sec_server -param *master*"
     ENDIF
    OF "security slave":
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsi_srv_path = "cer_exe:sec_server.exe -param -not *master*"
     ELSE
      SET dgsi_srv_path = "cer_exe/sec_server -param -not *master*"
     ENDIF
   ENDCASE
   SET dgsi_file_name = concat(dgsi_path,"server_id.dat")
   IF (dm2_findfile(dgsi_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsi_cmd = concat("del ",dgsi_file_name,";*")
    ELSE
     SET dgsi_cmd = concat("rm ",dgsi_file_name)
    ENDIF
    IF (dm2_push_dcl(dgsi_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dgsi_file_name = concat(dgsi_path,"server_name",evaluate(dm2_sys_misc->cur_os,"AXP",".com",
     ".ksh"))
   IF (dm2_findfile(dgsi_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsi_cmd = concat("del ",dgsi_file_name,";*")
    ELSE
     SET dgsi_cmd = concat("rm ",dgsi_file_name)
    ENDIF
    IF (dm2_push_dcl(dgsi_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to find server id for ",dgsi_tag,": ",dgsi_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dgsi_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!server_name.com"), row + 1,
      CALL print("$!"),
      row + 1,
      CALL print('$tgt_node=f$getsyi("nodename")'), row + 1,
      dgsi_cmd = concat('$if f$search("',dgsi_path,'find_server_id.dat") .nes. "" then delete ',
       dgsi_path,"find_server_id.dat;*"),
      CALL print(dgsi_cmd), row + 1,
      CALL print('$server_id = "NOT_FOUND"'), row + 1,
      CALL print('$server_desc = "NOT_FOUND"'),
      row + 1,
      CALL print('$srv_path = "NONE"'), row + 1,
      CALL print("$id_pos = 0"), row + 1,
      CALL print("$desc_pos = 0"),
      row + 1,
      CALL print("$row_num = 0"), row + 1,
      CALL print("$srv_row_num = 0"), row + 1,
      CALL print("$tries = 0"),
      row + 1,
      CALL print(concat("$define/user_mode sys$output ",dgsi_path,"find_server_id.dat")), row + 1,
      CALL print("$mcr cer_exe:scpview 'tgt_node'"), row + 1,
      CALL print("$DECK"),
      row + 1,
      CALL print(dgsi_user), row + 1,
      CALL print(dgsi_domain_name), row + 1,
      CALL print(dgsi_pw),
      row + 1,
      CALL print(concat("find -path ",dgsi_srv_path)), row + 1,
      CALL print("exit"), row + 1,
      CALL print("$EOD"),
      row + 1,
      CALL print(concat("$open/read SERVER_LIST ",dgsi_path,"find_server_id.dat")), row + 1,
      CALL print("$tries = tries + 1"), row + 1,
      CALL print("$READ_SERVER_LIST:"),
      row + 1,
      CALL print("$   read/end_of_file=END_READ_SERVER_LIST SERVER_LIST record"), row + 1,
      CALL print("$   row_num = row_num + 1"), row + 1,
      CALL print("$   length = f$length(record)"),
      row + 1,
      CALL print('$   if(f$locate("No matching entries found" ,record) .ne. length)'), row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      goto END_READ_SERVER_LIST "),
      row + 1,
      CALL print("$   endif"), row + 1,
      CALL print("$   if (row_num .eq. srv_row_num)"), row + 1,
      CALL print("$   then"),
      row + 1,
      CALL print('$      server_id = f$element(0, " ", record)'), row + 1,
      CALL print("$      server_desc = f$extract(desc_pos, length, record)"), row + 1,
      CALL print("$   else"),
      row + 1,
      CALL print('$      id_pos = f$locate("id" ,record)'), row + 1,
      CALL print("$      if (id_pos .ne. length)"), row + 1,
      CALL print("$      then"),
      row + 1,
      CALL print('$         desc_pos = f$locate("description" ,record)'), row + 1,
      CALL print("$         if (desc_pos .gt. 0) .and. (desc_pos .ne. length)"), row + 1,
      CALL print("$         then"),
      row + 1,
      CALL print("$            srv_row_num = row_num + 2"), row + 1,
      CALL print("$         endif"), row + 1,
      CALL print("$      endif"),
      row + 1,
      CALL print("$   endif"), row + 1,
      CALL print("$!  write sys$output record "), row + 1,
      CALL print("$   goto READ_SERVER_LIST "),
      row + 1,
      CALL print("$END_READ_SERVER_LIST: "), row + 1,
      CALL print("$   close SERVER_LIST  "), row + 1, dgsi_cmd = concat('$if f$search("',dgsi_path,
       'server_id.dat") .nes. "" then delete ',dgsi_path,"server_id.dat;*"),
      CALL print(dgsi_cmd), row + 1,
      CALL print(concat("$define sys$output ",dgsi_path,"server_id.dat")),
      row + 1,
      CALL print('$if (server_id .eqs. "NOT_FOUND") .or. (server_desc .eqs. "NOT_FOUND")'), row + 1,
      CALL print("$then"), row + 1,
      CALL print(concat('$   write sys$output "Error : Server ',dgsi_tag,' is not found."')),
      row + 1,
      CALL print("$   deassign sys$output"), row + 1,
      CALL print("$   exit 1"), row + 1,
      CALL print("$else"),
      row + 1,
      CALL print(concat(^$   write sys$output "server_id=''server_id'"^)), row + 1,
      CALL print(concat(^$   write sys$output "server_desc=''server_desc'"^)), row + 1,
      CALL print("$   deassign sys$output"),
      row + 1,
      CALL print("$exit 1"), row + 1,
      CALL print("$   endif"), row + 1
     ELSE
      CALL print("#!/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("tgt_node=`hostname`"), row + 1,
      CALL print(concat("system_pwd='",dgsi_pw,"'")), row + 1,
      CALL print(concat("srv_path='",dgsi_srv_path,"'")),
      row + 1,
      CALL print(concat("$cer_exe/scpview $tgt_node <<!>",dgsi_path,"server_name.dat")), row + 1,
      CALL print(dgsi_user), row + 1,
      CALL print(dgsi_domain_name),
      row + 1,
      CALL print("$system_pwd"), row + 1,
      CALL print("find -path $srv_path"), row + 1,
      CALL print("exit"),
      row + 1,
      CALL print("!"), row + 1,
      row + 1, dgsi_cmd = concat("server_id=$(grep '^[0-9]' ",dgsi_path,"server_name.dat|"), dgsi_cmd
       = concat(dgsi_cmd,^awk -F" " '{print $1}')^),
      CALL print(dgsi_cmd), row + 1, dgsi_cmd = concat("server_desc=$(grep '^[0-9]' ",dgsi_path,
       "server_name.dat|"),
      dgsi_cmd = concat(dgsi_cmd,^awk 'BEGIN { FS = "[0-9]+[ \t]+" } ; { print $2 }')^),
      CALL print(dgsi_cmd), row + 1,
      CALL print("if [[ -z $server_id || -z $server_desc ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print(concat('   echo "Error : Server ',dgsi_tag,' is not found."')), row + 1,
      dgsi_cmd = concat('   echo "Error : Server ',dgsi_tag,' is not found." >>',dgsi_path,
       "server_id.dat"),
      CALL print(dgsi_cmd), row + 1,
      CALL print("else"), row + 1, dgsi_cmd = concat('   echo "server_id=$server_id" >>',dgsi_path,
       "server_id.dat"),
      CALL print(dgsi_cmd), row + 1, dgsi_cmd = concat('   echo "server_desc=$server_desc" >>',
       dgsi_path,"server_id.dat"),
      CALL print(dgsi_cmd), row + 1,
      CALL print("fi"),
      row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echo("Failed to create ksh.")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute file: ",dgsi_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsi_cmd = concat("@",dgsi_file_name)
   ELSE
    SET dgsi_cmd = concat("chmod 777 ",dgsi_file_name)
    IF (dm2_push_dcl(dgsi_cmd)=0)
     RETURN(0)
    ENDIF
    SET dgsi_cmd = concat(". ",dgsi_file_name)
   ENDIF
   SET dgsi_tmp_err_ind = dm_err->err_ind
   IF (dm2_push_dcl(dgsi_cmd)=0)
    RETURN(0)
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (findstring("Error : Server",dm_err->errtext,1,1) > 0)
     SET dgsi_srv_found_flag = 0
     SET dgsi_server_id = "0"
     SET dgsi_server_desc = "NOT FOUND"
     SET dm_err->err_ind = dgsi_tmp_err_ind
    ELSE
     SET dgsi_srv_found_flag = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (dgsi_srv_found_flag=1)
    SET dgsi_file_name = concat(dgsi_path,"server_id.dat")
    IF (dm2_findfile(dgsi_file_name)=0)
     IF ((dm_err->err_ind=0))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Find file ",dgsi_file_name)
      SET dm_err->emsg = concat("Failed to find ",dgsi_file_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Parse out server id and description for ",dgsi_tag)
    CALL disp_msg("",dm_err->logfile,0)
    FREE DEFINE rtl2
    FREE SET file_loc
    SET logical file_loc value(dgsi_file_name)
    DEFINE rtl2 "file_loc"
    SELECT INTO "nl:"
     r.line
     FROM rtl2t r
     HEAD REPORT
      beg_pos = 0, end_pos = 0
     DETAIL
      beg_pos = 0, end_pos = 0
      IF ((dm_err->debug_flag > 1))
       CALL echo(concat("LINE = ",r.line))
      ENDIF
      beg_pos = findstring("=",r.line,1,0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("BEG_POS=",beg_pos))
      ENDIF
      end_pos = size(trim(r.line))
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("END_POS=",end_pos))
      ENDIF
      IF (beg_pos > 0
       AND end_pos > 0)
       IF (findstring("Error : Server",trim(r.line),1,0) > 0)
        dgsi_server_id = "0", dgsi_server_desc = "NOT FOUND"
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dgsi_server_id=",dgsi_server_id)),
         CALL echo(build("dgsi_server_desc=",dgsi_server_desc))
        ENDIF
       ELSEIF (findstring("server_id",trim(r.line),1,0) > 0)
        dgsi_server_id = substring((beg_pos+ 1),(end_pos - beg_pos),r.line)
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dgsi_server_id=",dgsi_server_id))
        ENDIF
       ELSEIF (findstring("server_desc",trim(r.line),1,0) > 0)
        dgsi_server_desc = substring((beg_pos+ 1),(end_pos - beg_pos),r.line)
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dgsi_server_desc=",dgsi_server_desc))
        ENDIF
       ELSE
        dgsi_server_id = "0", dgsi_server_desc = "NOT FOUND"
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dgsi_server_id=",dgsi_server_id)),
         CALL echo(build("dgsi_server_desc=",dgsi_server_desc))
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter, maxcol = 255
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (((dgsi_server_id="") OR (dgsi_server_desc="")) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Failed to extract server id and/or description for ",dgsi_tag)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_srv_details(dgsd_type,dgsd_id,dgsd_desc,dgsd_srv_found)
   DECLARE dgsd_file_name = vc WITH protect, noconstant("")
   DECLARE dgsd_cmd = vc WITH protect, noconstant("")
   DECLARE dgsd_path = vc WITH protect, noconstant("")
   DECLARE dgsd_domain_name = vc WITH protect, noconstant("")
   DECLARE dgsd_user = vc WITH protect, noconstant("")
   DECLARE dgsd_pw = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Getting server details for ",dgsd_id," from SCP")
   CALL disp_msg("",dm_err->logfile,0)
   IF (dgsd_type="src")
    SET dgsd_domain_name = ddr_domain_data->src_domain_name
    SET dgsd_user = ddr_domain_data->src_mng
    SET dgsd_pw = ddr_domain_data->src_mng_pwd
    SET dgsd_path = ddr_domain_data->src_tmp_full_dir
   ELSEIF (dgsd_type="tgt")
    SET dgsd_path = ddr_domain_data->tgt_tmp_full_dir
    SET dgsd_domain_name = ddr_domain_data->tgt_domain_name
    SET dgsd_user = ddr_domain_data->tgt_mng
    SET dgsd_pw = ddr_domain_data->tgt_mng_pwd
   ENDIF
   SET dgsd_srv_found = 0
   SET dgsd_desc = "NOT FOUND"
   SET dgsd_file_name = concat(dgsd_path,"server_details.dat")
   IF (dm2_findfile(dgsd_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsd_cmd = concat("del ",dgsd_file_name,";*")
    ELSE
     SET dgsd_cmd = concat("rm ",dgsd_file_name)
    ENDIF
    IF (dm2_push_dcl(dgsd_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dgsd_file_name = concat(dgsd_path,"server_details",evaluate(dm2_sys_misc->cur_os,"AXP",".com",
     ".ksh"))
   IF (dm2_findfile(dgsd_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsd_cmd = concat("del ",dgsd_file_name,";*")
    ELSE
     SET dgsd_cmd = concat("rm ",dgsd_file_name)
    ENDIF
    IF (dm2_push_dcl(dgsd_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to find server details:",dgsd_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dgsd_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!server_details.com"), row + 1,
      CALL print("$!"),
      row + 1,
      CALL print('tgt_node=f$getsyi("nodename")'), row + 1,
      dgsd_cmd = concat('$if f$search("',dgsd_path,'find_server_details.dat") .nes. "" then delete ',
       dgsd_path,"find_server_details.dat;*"),
      CALL print(dgsd_cmd), row + 1,
      CALL print('$server_desc = "NOT_FOUND"'), row + 1,
      CALL print("$desc_pos = 0"),
      row + 1,
      CALL print(concat("$define/user_mode sys$output ",dgsd_path,"find_server_details.dat")), row +
      1,
      CALL print("$mcr cer_exe:scpview 'tgt_node'"), row + 1,
      CALL print("$DECK"),
      row + 1,
      CALL print(dgsd_user), row + 1,
      CALL print(dgsd_domain_name), row + 1,
      CALL print(dgsd_pw),
      row + 1,
      CALL print(concat("show ",dgsd_id)), row + 1,
      CALL print("exit"), row + 1,
      CALL print("$EOD"),
      row + 1,
      CALL print(concat("$open/read SERVER_LIST ",dgsd_path,"find_server_details.dat")), row + 1,
      CALL print("$READ_SERVER_LIST:"), row + 1,
      CALL print("$   read/end_of_file=END_READ_SERVER_LIST SERVER_LIST record"),
      row + 1,
      CALL print('$   record = f$edit(record, "lowercase")'), row + 1,
      CALL print("$   length = f$length(record)"), row + 1,
      CALL print('$   if(f$locate("entry not found" ,record) .ne. length)'),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      goto END_READ_SERVER_LIST "), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print(concat('$   desc_pos = f$locate("description: " ,record)')), row + 1,
      CALL print("$   length = f$length(record)"), row + 1,
      CALL print("$   if (desc_pos .gt. 0) .and. (desc_pos .ne. length)"),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      server_desc = f$extract(desc_pos, length, record)"), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print("$!  write sys$output record "), row + 1,
      CALL print("$   goto READ_SERVER_LIST "), row + 1,
      CALL print("$END_READ_SERVER_LIST: "),
      row + 1,
      CALL print("$   close SERVER_LIST  "), row + 1,
      dgsd_cmd = concat('$if f$search("',dgsd_path,'server_details.dat") .nes. "" then delete ',
       dgsd_path,"server_details.dat;*"),
      CALL print(dgsd_cmd), row + 1,
      CALL print(concat("$define sys$output ",dgsd_path,"server_details.dat")), row + 1,
      CALL print('$if server_desc .eqs. "NOT_FOUND"'),
      row + 1,
      CALL print("$then"), row + 1,
      CALL print(concat('$   write sys$output "Error : Server ',dgsd_id,' is not found."')), row + 1,
      CALL print("$   deassign sys$output"),
      row + 1,
      CALL print("$   exit 1"), row + 1,
      CALL print("$else"), row + 1,
      CALL print(concat(^$   write sys$output "server_desc=''server_desc'"^)),
      row + 1,
      CALL print("$   deassign sys$output"), row + 1,
      CALL print("$exit 1"), row + 1,
      CALL print("$   endif"),
      row + 1
     ELSE
      CALL print("#!/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("tgt_node=`hostname`"), row + 1,
      CALL print(concat("system_pwd='",dgsd_pw,"'")), row + 1,
      CALL print(concat("$cer_exe/scpview $tgt_node <<!>",dgsd_path,"find_server_details.dat")),
      row + 1,
      CALL print(dgsd_user), row + 1,
      CALL print(dgsd_domain_name), row + 1,
      CALL print("$system_pwd"),
      row + 1,
      CALL print(concat("show ",dgsd_id)), row + 1,
      CALL print("exit"), row + 1,
      CALL print("!"),
      row + 1, row + 1, dgsd_cmd = concat("server_desc=$(tr '[:upper:]' '[:lower:]' < ",dgsd_path,
       ^find_server_details.dat|grep "description:" |awk -F"description: " '{print $2}')^),
      CALL print(dgsd_cmd), row + 1,
      CALL print("if [[ $server_desc = '' ]]"),
      row + 1,
      CALL print("then"), row + 1,
      CALL print(concat('   echo "Error : Server ',dgsd_id,' is not found." > ',dgsd_path,
       "server_details.dat")), row + 1,
      CALL print("else"),
      row + 1, dgsd_cmd = concat('   echo "server_desc=$server_desc" >',dgsd_path,
       "server_details.dat"),
      CALL print(dgsd_cmd),
      row + 1,
      CALL print("   fi"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echo("Failed to create ksh.")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Find server desc for server: ",dgsd_id)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsd_cmd = concat("@",dgsd_file_name)
   ELSE
    SET dgsd_cmd = concat("chmod 777 ",dgsd_file_name)
    IF (dm2_push_dcl(dgsd_cmd)=0)
     RETURN(0)
    ENDIF
    SET dgsd_cmd = concat(". ",dgsd_file_name)
   ENDIF
   IF (dm2_push_dcl(dgsd_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   SET dgsd_file_name = concat(dgsd_path,"server_details.dat")
   IF (dm2_findfile(dgsd_file_name)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Find file ",dgsd_file_name)
     SET dm_err->emsg = concat("Failed to find ",dgsd_file_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Parse out server desc for ",dgsd_id)
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dgsd_file_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     beg_pos = 0, end_pos = 0
    DETAIL
     beg_pos = 0, end_pos = 0
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("LINE = ",r.line))
     ENDIF
     beg_pos = findstring("=",r.line,1,0)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("BEG_POS=",beg_pos))
     ENDIF
     end_pos = size(trim(r.line))
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("END_POS=",end_pos))
     ENDIF
     IF (beg_pos > 0
      AND end_pos > 0)
      IF (findstring("Error :",trim(r.line),1,0) > 0)
       dgsd_srv_found = 0, dgsd_desc = "NOT FOUND"
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dgsd_desc=",dgsd_desc))
       ENDIF
      ELSEIF (findstring("server_desc",trim(r.line),1,0) > 0)
       dgsd_srv_found = 1, dgsd_desc = substring((beg_pos+ 1),(end_pos - beg_pos),r.line)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dgsd_desc=",dgsd_desc))
       ENDIF
      ELSE
       dgsd_srv_found = 0, dgsd_desc = "NOT FOUND"
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dgsd_desc=",dgsd_desc))
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dgsd_desc="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Failed to find server desc for ",dgsd_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dgsd_srv_found = 0
    RETURN(0)
   ELSEIF (dgsd_desc="NOT FOUND")
    SET dgsd_srv_found = 0
   ELSE
    SET dgsd_srv_found = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_srv_id(dgsi_type,dgsi_desc,dgsi_server_id)
   DECLARE dgsi_file_name = vc WITH protect, noconstant("")
   DECLARE dgsi_cmd = vc WITH protect, noconstant("")
   DECLARE dgsi_path = vc WITH protect, noconstant("")
   DECLARE dgsi_domain_name = vc WITH protect, noconstant("")
   DECLARE dgsi_user = vc WITH protect, noconstant("")
   DECLARE dgsi_pw = vc WITH protect, noconstant("")
   IF (dgsi_type="src")
    SET dgsi_domain_name = ddr_domain_data->src_domain_name
    SET dgsi_user = ddr_domain_data->src_mng
    SET dgsi_pw = ddr_domain_data->src_mng_pwd
    SET dgsi_path = ddr_domain_data->src_tmp_full_dir
   ELSEIF (dgsi_type="tgt")
    SET dgsi_path = ddr_domain_data->tgt_tmp_full_dir
    SET dgsi_domain_name = ddr_domain_data->tgt_domain_name
    SET dgsi_user = ddr_domain_data->tgt_mng
    SET dgsi_pw = ddr_domain_data->tgt_mng_pwd
   ENDIF
   SET dgsi_file_name = concat(dgsi_path,"server_id.dat")
   IF (dm2_findfile(dgsi_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsi_cmd = concat("del ",dgsi_file_name,";*")
    ELSE
     SET dgsi_cmd = concat("rm ",dgsi_file_name)
    ENDIF
    IF (dm2_push_dcl(dgsi_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dgsi_file_name = concat(dgsi_path,"server_name",evaluate(dm2_sys_misc->cur_os,"AXP",".com",
     ".ksh"))
   IF (dm2_findfile(dgsi_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgsi_cmd = concat("del ",dgsi_file_name,";*")
    ELSE
     SET dgsi_cmd = concat("rm ",dgsi_file_name)
    ENDIF
    IF (dm2_push_dcl(dgsi_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to find server id:",dgsi_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dgsi_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!server_name.com"), row + 1,
      CALL print("$!"),
      row + 1,
      CALL print('tgt_node=f$getsyi("nodename")'), row + 1,
      dgsi_cmd = concat('$if f$search("',dgsi_path,'find_server_id.dat") .nes. "" then delete ',
       dgsi_path,"find_server_id.dat;*"),
      CALL print(dgsi_cmd), row + 1,
      CALL print('$server_id = "NOT_FOUND"'), row + 1,
      CALL print("$desc_pos = 0"),
      row + 1,
      CALL print(concat("$define/user_mode sys$output ",dgsi_path,"find_server_id.dat")), row + 1,
      CALL print("$mcr cer_exe:scpview 'tgt_node'"), row + 1,
      CALL print("$DECK"),
      row + 1,
      CALL print(dgsi_user), row + 1,
      CALL print(dgsi_domain_name), row + 1,
      CALL print(dgsi_pw),
      row + 1,
      CALL print(concat('find -descrip "',dgsi_desc,'"')), row + 1,
      CALL print("exit"), row + 1,
      CALL print("$EOD"),
      row + 1,
      CALL print(concat("$open/read SERVER_LIST ",dgsi_path,"find_server_id.dat")), row + 1,
      CALL print("$READ_SERVER_LIST:"), row + 1,
      CALL print("$   read/end_of_file=END_READ_SERVER_LIST SERVER_LIST record"),
      row + 1,
      CALL print('$   record = f$edit(record, "lowercase")'), row + 1,
      dgsi_desc = replace(dgsi_desc,"*","",2),
      CALL print(concat('$   desc_pos = f$locate("',trim(dgsi_desc),'" ,record)')), row + 1,
      CALL print("$   length = f$length(record)"), row + 1,
      CALL print("$   if (desc_pos .gt. 0) .and. (desc_pos .ne. length)"),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print('$      server_id = f$element(0, " ", record)'), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print("$!  write sys$output record "), row + 1,
      CALL print("$   goto READ_SERVER_LIST "), row + 1,
      CALL print("$END_READ_SERVER_LIST: "),
      row + 1,
      CALL print("$   close SERVER_LIST  "), row + 1,
      dgsi_cmd = concat('$if f$search("',dgsi_path,'server_id.dat") .nes. "" then delete ',dgsi_path,
       "server_id.dat;*"),
      CALL print(dgsi_cmd), row + 1,
      CALL print(concat("$define sys$output ",dgsi_path,"server_id.dat")), row + 1,
      CALL print('$if server_id .eqs. "NOT_FOUND"'),
      row + 1,
      CALL print("$then"), row + 1,
      CALL print(concat('$   write sys$output "Error : Server ',dgsi_desc,' is not found."')), row +
      1,
      CALL print("$   deassign sys$output"),
      row + 1,
      CALL print("$   exit 1"), row + 1,
      CALL print("$else"), row + 1,
      CALL print(concat(^$   write sys$output "server_id=''server_id'"^)),
      row + 1,
      CALL print("$   deassign sys$output"), row + 1,
      CALL print("$exit 1"), row + 1,
      CALL print("$   endif"),
      row + 1
     ELSE
      CALL print("#!/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("tgt_node=`hostname`"), row + 1,
      CALL print(concat("system_pwd='",dgsi_pw,"'")), row + 1,
      CALL print(concat("$cer_exe/scpview $tgt_node <<!>",dgsi_path,"server_name.dat")),
      row + 1,
      CALL print(dgsi_user), row + 1,
      CALL print(dgsi_domain_name), row + 1,
      CALL print("$system_pwd"),
      row + 1,
      CALL print(concat('find -descrip "',dgsi_desc,'"')), row + 1,
      CALL print("exit"), row + 1,
      CALL print("!"),
      row + 1, row + 1, dgsi_desc = replace(dgsi_desc,"*","",2),
      dgsi_cmd = concat("server_id=$(tr '[:upper:]' '[:lower:]' < ",dgsi_path,
       'server_name.dat|tail -n 5|grep "',trim(dgsi_desc),^" |awk -F" " '{print $1}')^),
      CALL print(dgsi_cmd), row + 1,
      CALL print("if [[ -z $server_id ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print(concat('   echo "Error : Server ',dgsi_desc,' is not found."')), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, dgsi_cmd = concat('   echo "server_id=$server_id" >',dgsi_path,"server_id.dat"),
      CALL print(dgsi_cmd),
      row + 1,
      CALL print("   fi"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echo("Failed to create ksh.")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Find server id for ",dgsi_desc)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsi_cmd = concat("@",dgsi_file_name)
   ELSE
    SET dgsi_cmd = concat("chmod 777 ",dgsi_file_name)
    IF (dm2_push_dcl(dgsi_cmd)=0)
     RETURN(0)
    ENDIF
    SET dgsi_cmd = concat(". ",dgsi_file_name)
   ENDIF
   IF (dm2_push_dcl(dgsi_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   SET dgsi_file_name = concat(dgsi_path,"server_id.dat")
   IF (dm2_findfile(dgsi_file_name)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Find file ",dgsi_file_name)
     SET dm_err->emsg = concat("Failed to find ",dgsi_file_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Parse out server id for ",dgsi_desc)
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dgsi_file_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     beg_pos = 0, end_pos = 0
    DETAIL
     beg_pos = 0, end_pos = 0
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("LINE = ",r.line))
     ENDIF
     beg_pos = findstring("=",r.line,1,0)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("BEG_POS=",beg_pos))
     ENDIF
     end_pos = size(trim(r.line))
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("END_POS=",end_pos))
     ENDIF
     IF (beg_pos > 0
      AND end_pos > 0)
      IF (findstring("server_id",trim(r.line),1,0) > 0)
       dgsi_server_id = substring((beg_pos+ 1),(end_pos - beg_pos),r.line)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dgsi_server_id=",dgsi_server_id))
       ENDIF
      ENDIF
     ENDIF
     IF (findstring("Error :",trim(r.line),1,0) > 0)
      dm_err->err_ind = 1, dm_err->emsg = concat("Failed to find server id for ",dgsi_desc)
     ENDIF
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dgsi_server_id="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Failed to find server id for ",dgsi_desc)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_from_dir(dgfd_src_ind,dgfd_logical,dgfd_from_dir)
   SET dm_err->eproc = concat("Find directory path for logical ",dgfd_logical)
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dgfd_loop = i2 WITH protect, noconstant(1)
   DECLARE dgfd_path = vc WITH protect, noconstant("")
   DECLARE dgfd_subpath = vc WITH protect, noconstant("")
   DECLARE dgfd_beg_pos = i4 WITH protect, noconstant(0)
   DECLARE dgfd_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dgfd_logical_name = vc WITH protect, noconstant("")
   SET dgfd_logical_name = dgfd_logical
   WHILE (dgfd_loop)
    SET dgfd_path = parser(concat("trim(logical('",dgfd_logical_name,"'))"))
    IF (dgfd_path="")
     IF (dgfd_logical_name="cer_ocdtools")
      IF ((dm2_sys_misc->cur_os="AXP"))
       SET dgfd_path = replace(trim(logical("cer_ocd")),"]","tools]",2)
      ELSE
       SET dgfd_path = concat(trim(logical("cer_ocd")),"/tools")
      ENDIF
      SET dgfd_loop = 0
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Logical ",dgfd_logical_name," is not defined.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (findstring("[",dgfd_path,1,0) > 0)
       SET dgfd_loop = 0
      ELSE
       SET dgfd_logical_name = dgfd_path
      ENDIF
     ELSE
      IF (findstring("/",dgfd_path,1,0) > 0)
       SET dgfd_loop = 0
      ELSE
       SET dgfd_logical_name = dgfd_path
      ENDIF
     ENDIF
    ENDIF
   ENDWHILE
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (findstring(".]",dgfd_path,1,0) > 0)
     IF (((dgfd_logical_name="ccldir") OR (dgfd_logical_name="cer_config"))
      AND dgfd_src_ind=1)
      SET dgfd_from_dir = replace(dgfd_path,".]","]",2)
     ELSE
      SET dgfd_from_dir = replace(dgfd_path,"]","..]*.*;*",2)
     ENDIF
    ELSE
     IF ( NOT (((dgfd_logical_name="ccldir") OR (dgfd_logical_name="cer_config")) )
      AND dgfd_src_ind=1)
      SET dgfd_from_dir = replace(dgfd_path,"]","...]*.*;*",2)
     ELSE
      SET dgfd_from_dir = dgfd_path
     ENDIF
    ENDIF
   ELSE
    SET dgfd_from_dir = concat(dgfd_path,"/")
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("from_dir = ",dgfd_from_dir))
   ENDIF
   IF (dgfd_src_ind=1
    AND (dm2_sys_misc->cur_os="AXP"))
    SET dgfd_beg_pos = findstring("[",dgfd_path,0)
    IF (findstring(".]",dgfd_path,1,0) > 0)
     SET dgfd_end_pos = findstring(".]",dgfd_path,0)
    ELSE
     SET dgfd_end_pos = findstring("]",dgfd_path,0)
    ENDIF
    SET dgfd_subpath = substring((dgfd_beg_pos+ 1),((dgfd_end_pos - dgfd_beg_pos) - 1),dgfd_path)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("subpath = ",dgfd_subpath))
    ENDIF
    CASE (dgfd_logical)
     OF "cer_config":
      SET ddr_domain_data->src_cer_config_dir = dgfd_subpath
     OF "ccldir":
      SET ddr_domain_data->src_ccldir = dgfd_subpath
     OF "cer_ocdtools":
      SET ddr_domain_data->src_ocdtools_dir = dgfd_subpath
     OF "cer_wh":
      SET ddr_domain_data->src_warehouse_dir = dgfd_subpath
     OF "ccluserdir":
      SET ddr_domain_data->src_ccluserdir_dir = dgfd_subpath
    ENDCASE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_continue_prompt(null)
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,20,131)
   CALL text(2,2,concat("Most Recent eproc: ",dm_err->eproc))
   CALL text(3,2,concat("Most Recent emsg (if any): ",dm_err->emsg))
   CALL text(4,2,concat("Do you want to continue?"))
   CALL text(5,2,"[Y]es or [N]o:")
   CALL accept(5,16,"A;cu"," "
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="N")
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->emsg = concat("I elect not to continue because ",dm_err->emsg)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_tgt_node_flag(null)
   DECLARE dgtnf_file = vc WITH protect, noconstant(concat(ddr_domain_data->src_tmp_full_dir,
     "target_misc_data.dat"))
   IF (dm2_findfile(dgtnf_file)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Find file ",dgtnf_file)
     SET dm_err->emsg = concat("Failed to find ",dgtnf_file)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Read ",dgtnf_file," to set tgt_node_flag.")
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc dgtnf_file
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    HEAD REPORT
     beg_pos = 0, length = 0
    DETAIL
     IF (findstring("tgt_node_flag=",t.line,1,0) > 0)
      length = size(trim(t.line)), beg_pos = findstring("=",t.line,1,0), ddr_domain_data->
      tgt_node_flag = cnvtint(substring((beg_pos+ 1),(length - beg_pos),t.line))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("tgt_node_flag = ",ddr_domain_data->tgt_node_flag))
   ENDIF
   IF ( NOT ((ddr_domain_data->tgt_node_flag IN (1, 2, 3))))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid tgt_node_flag ",ddr_domain_data->tgt_node_flag)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_preserve_prompt(dpp_preserve)
   DECLARE dpp_curaccept = vc WITH protect, noconstant("")
   SET dpp_preserve = 0
   SET dm_err->eproc = "Prompt user whether to preserve Target data."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,6,131)
   CALL text(4,8,"Preserve data from TARGET database (Y/N) : ")
   CALL accept(4,52,"A;cu"," "
    WHERE curaccept IN ("Y", "N"))
   SET message = nowindow
   CALL clear(1,1)
   SET dpp_curaccept = curaccept
   IF (dpp_curaccept="Y")
    SET dpp_preserve = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_preserve_check_prompt(dpcp_preserve)
   DECLARE dpcp_curaccept = vc WITH protect, noconstant("")
   SET dpcp_preserve = 0
   SET dm_err->eproc = "Prompt user whether to preserve Target data should continue or restart."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,6,131)
   CALL text(4,8,
    "Preserve data from TARGET database in process.  Enter 'C' to continue or 'R' to restart (C/R) : "
    )
   CALL accept(4,104,"A;cu"," "
    WHERE curaccept IN ("C", "R"))
   SET message = nowindow
   CALL clear(1,1)
   SET dpcp_curaccept = curaccept
   IF (dpcp_curaccept="C")
    SET dpcp_preserve = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_link_data(null)
   DECLARE dgld_cfnd = i4 WITH protect, noconstant(0)
   DECLARE dgld_pfnd = i4 WITH protect, noconstant(0)
   DECLARE dgld_jfnd = i4 WITH protect, noconstant(0)
   DECLARE dgld_file = vc WITH protect, noconstant(build(ddr_domain_data->src_tmp_full_dir,
     "link_data.dat"))
   DECLARE dgld_str = vc WITH protect, noconstant("")
   DECLARE dgld_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Determining if CPLINK, PURGE and JVM symbolic link rows exist in dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_REPLICATE_LINK"=di.info_domain
     AND (("PURGE"=di.info_name) OR ((("CPLINK"=di.info_name) OR ("JVM"=di.info_name)) ))
    DETAIL
     IF (di.info_name="PURGE")
      dgld_pfnd = 1
     ELSEIF (di.info_name="CPLINK")
      dgld_cfnd = 1
     ELSEIF (di.info_name="JVM")
      dgld_jfnd = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgld_pfnd=0)
    SET dm_err->eproc = "Inserting PURGE symbolic link data into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_LINK", di.info_name = "PURGE", di.info_number = 1,
      di.info_char = "<$cer_exe/purge><$cer_proc/purge>"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   IF (dgld_cfnd=0)
    SET dm_err->eproc = "Inserting CPLINK symbolic link data into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_LINK", di.info_name = "CPLINK", di.info_number = 1,
      di.info_char = "<$cer_exe/cplink><$cer_proc/cplink>"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   IF (dgld_jfnd=0)
    SET dm_err->eproc = "Inserting JVM symbolic link data into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_LINK", di.info_name = "JVM", di.info_number = 1,
      di.info_char = "<$cer_wh/jvm>"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RECORD dgld_link_list(
     1 cnt = i4
     1 qual[*]
       2 sym_link_name = vc
       2 full_file_name = vc
       2 full_link_name = vc
       2 link_fnd = i2
   )
   SET dm_err->eproc = "Selecting list of symbolic link data from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_REPLICATE_LINK"=di.info_domain
     AND 1=di.info_number
    HEAD REPORT
     tmp1 = 0, dgld_link_list->cnt = 0, stat = alterlist(dgld_link_list->qual,0)
    DETAIL
     IF (substring(1,1,di.info_char)="<"
      AND findstring(">",di.info_char,0) > 0)
      dgld_link_list->cnt = (dgld_link_list->cnt+ 1), stat = alterlist(dgld_link_list->qual,
       dgld_link_list->cnt), dgld_link_list->qual[dgld_link_list->cnt].sym_link_name = di.info_name,
      tmp1 = findstring(">",di.info_char,0), dgld_link_list->qual[dgld_link_list->cnt].full_link_name
       = substring(2,(tmp1 - 2),di.info_char)
      IF (tmp1 != size(trim(di.info_char)))
       dgld_link_list->qual[dgld_link_list->cnt].full_file_name = substring((tmp1+ 2),((size(trim(di
          .info_char)) - tmp1) - 2),di.info_char)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dgld_link_list->cnt > 0))
    FOR (dgld_cnt = 1 TO dgld_link_list->cnt)
      SET dgld_str = concat("test -h ",dgld_link_list->qual[dgld_cnt].full_link_name,";echo $?")
      CALL dm2_push_dcl(dgld_str)
      SET dm_err->err_ind = 0
      IF (parse_errfile(dm_err->errfile)=0)
       RETURN(0)
      ENDIF
      IF (cnvtint(dm_err->errtext)=0)
       IF ((dm_err->debug_flag > 1))
        SET dm_err->eproc = concat("Symbolic Link ",dgld_link_list->qual[dgld_cnt].full_link_name,
         " found.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       SET dgld_link_list->qual[dgld_cnt].link_fnd = 1
      ELSE
       IF ((dm_err->debug_flag > 1))
        SET dm_err->eproc = concat("Symbolic Link ",dgld_link_list->qual[dgld_cnt].full_link_name,
         " not found.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       SET dgld_link_list->qual[dgld_cnt].link_fnd = 0
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dgld_link_list)
    ENDIF
    IF (dm2_findfile(dgld_file) > 0)
     IF (dm2_push_dcl(concat("rm ",dgld_file))=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = "Writing source data to link_data.dat"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET logical dgld_config_file dgld_file
    SELECT INTO "dgld_config_file"
     DETAIL
      FOR (dgld_cnt = 1 TO dgld_link_list->cnt)
        IF ((dgld_link_list->qual[dgld_cnt].link_fnd=1))
         dgld_str = concat(dgld_link_list->qual[dgld_cnt].sym_link_name," ",dgld_link_list->qual[
          dgld_cnt].full_link_name," ",dgld_link_list->qual[dgld_cnt].full_file_name), col 0,
         dgld_str,
         row + 1
        ENDIF
      ENDFOR
     WITH nocounter, maxcol = 500, format = variable,
      maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_rpt_reg_issues(null)
   DECLARE drri_log_ret = vc WITH protect, noconstant("")
   DECLARE drri_env_ok_ret = i2 WITH protect, noconstant(0)
   DECLARE drri_ckcnt = i4 WITH protect, noconstant(0)
   DECLARE drri_ckpcnt = i4 WITH protect, noconstant(0)
   DECLARE drri_fname = vc WITH protect, noconstant("")
   DECLARE drri_full_fname = vc WITH protect, noconstant("")
   DECLARE drri_str = vc WITH protect, noconstant("")
   DECLARE drri_ret_val = vc WITH protect, noconstant("")
   DECLARE drri_tm_key = vc WITH protect, noconstant("")
   DECLARE drri_max_pcnt = i4 WITH protect, noconstant(0)
   DECLARE drri_reg_tgt_env = vc WITH protect, noconstant("")
   IF ((ddr_domain_data->tgt_env="DM2NOTSET"))
    IF (ddr_get_env_logical(drri_log_ret)=0)
     RETURN(0)
    ENDIF
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     IF (cnvtlower(drri_log_ret) != cnvtlower(drrr_rf_data->tgt_env_name))
      SET dm_err->eproc = concat("Verify Target response file environment (",drrr_rf_data->
       tgt_env_name,") with current enviornment (",drri_log_ret,").")
      SET dm_err->emsg = "Environments specified do not match."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET ddr_domain_data->tgt_env = cnvtlower(dcsd_log_ret)
    ELSE
     IF (ddr_env_confirm(0,1,drri_log_ret,drri_env_ok_ret)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (size(ddr_domain_data->tgt_env,1) > max_reg_env_len)
    SET drri_reg_tgt_env = substring(1,max_reg_env_len,ddr_domain_data->tgt_env)
   ELSE
    SET drri_reg_tgt_env = ddr_domain_data->tgt_env
   ENDIF
   IF ((ddr_domain_data->tgt_domain_name="DM2NOTSET"))
    SET dm_err->eproc = "Get domain name."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET drri_str = concat("\\environment\\",ddr_domain_data->tgt_env," Domain")
    IF (ddr_lreg_oper("GET",drri_str,drri_ret_val)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->tgt_domain_name = drri_ret_val
    IF (drri_ret_val="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve domain name property for ",ddr_domain_data->
      tgt_env)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_validate_source_env(0)=0)
    RETURN(0)
   ENDIF
   SET message = nowindow
   IF (ddr_get_env_reg(0,0,"DEFINITION",1)=0)
    RETURN(0)
   ENDIF
   SET ddr_reg->cur_reg_file = build(dm2_install_schema->ccluserdir,drri_reg_tgt_env,"_c_env.reg")
   IF (ddr_pop_reg_struct(3,ddr_reg->cur_reg_file,1)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_env_reg(0,0,"NODE_DOMAIN",1)=0)
    RETURN(0)
   ENDIF
   SET ddr_reg->cur_reg_file = build(dm2_install_schema->ccluserdir,drri_reg_tgt_env,
    "_c_node_dom.reg")
   IF (ddr_pop_reg_struct(3,ddr_reg->cur_reg_file,0)=0)
    RETURN(0)
   ENDIF
   FOR (drri_ckcnt = 1 TO ddr_reg->ckcnt)
     IF (drri_ckcnt=1)
      SET drri_tm_key = build("\environment\",trim(ddr_domain_data->tgt_env),"\definitions")
      SET ddr_reg->ckey[drri_ckcnt].ckeyname = drri_tm_key
     ELSEIF ((ddr_reg->ckey[drri_ckcnt].ckeyname="\"))
      SET drri_tm_key = build("\node\",trim(curnode),"\domain\",trim(ddr_domain_data->tgt_domain_name
        ))
      SET ddr_reg->ckey[drri_ckcnt].ckeyname = drri_tm_key
     ELSE
      SET ddr_reg->ckey[drri_ckcnt].ckeyname = build(drri_tm_key,ddr_reg->ckey[drri_ckcnt].ckeyname)
     ENDIF
     IF ((ddr_reg->ckey[drri_ckcnt].cpcnt > drri_max_pcnt))
      SET drri_max_pcnt = ddr_reg->ckey[drri_ckcnt].cpcnt
     ENDIF
     FOR (drri_ckpcnt = 1 TO ddr_reg->ckey[drri_ckcnt].cpcnt)
       IF (findstring(cnvtupper(ddr_domain_data->src_env),cnvtupper(ddr_reg->ckey[drri_ckcnt].cprop[
         drri_ckpcnt].cpropval),1,0) > 0)
        SET ddr_reg->ckey[drri_ckcnt].cprop[drri_ckpcnt].cstr_fnd = 1
        SET ddr_reg->ckey[drri_ckcnt].cstr_fnd = 1
        SET ddr_reg->cstr_fnd = 1
       ENDIF
     ENDFOR
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_reg)
   ENDIF
   IF ((ddr_reg->cstr_fnd=1))
    IF (get_unique_file("dm2_reg_warn",".rpt")=0)
     RETURN(0)
    ENDIF
    SET drri_fname = cnvtlower(dm_err->unique_fname)
    SET drri_full_fname = build(dm2_install_schema->ccluserdir,cnvtlower(dm_err->unique_fname))
    IF (validate(drrr_responsefile_in_use,- (1))=1)
     SET drri_fname = build(drrr_misc_data->active_dir,cnvtlower(dm_err->unique_fname))
     SET drri_full_fname = build(drrr_misc_data->active_dir,cnvtlower(dm_err->unique_fname))
    ENDIF
    SET dm_err->eproc = concat("Creating TARGET Registry Warning Report ",drri_full_fname)
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO value(drri_fname)
     keyname = substring(1,100,ddr_reg->ckey[d.seq].ckeyname)
     FROM (dummyt d  WITH seq = value(ddr_reg->ckcnt)),
      (dummyt d2  WITH seq = value(drri_max_pcnt))
     PLAN (d
      WHERE (ddr_reg->ckey[d.seq].cstr_fnd=1))
      JOIN (d2
      WHERE (d2.seq <= ddr_reg->ckey[d.seq].cpcnt)
       AND (ddr_reg->ckey[d.seq].cprop[d2.seq].cstr_fnd=1))
     ORDER BY ddr_reg->ckey[d.seq].ckeyname
     HEAD REPORT
      "Target Registry Warning Report", row + 1,
      "-----------------------------------------------------------------------------",
      row + 1, "Report Location:  ", drri_full_fname,
      row + 1, row + 1,
      "The following Target registry property values contain the Source environment ",
      ddr_domain_data->src_env, ".", row + 2,
      "Review the Target properties to ensure they reflect the correct values.", row + 1
     HEAD PAGE
      row + 1, col 7, "Property Name",
      col 50, "Property Value", row + 1,
      col 7, "-------------", col 50,
      "--------------", row + 1
     HEAD keyname
      "Key:  ", ddr_reg->ckey[d.seq].ckeyname, row + 1
     DETAIL
      col 7, ddr_reg->ckey[d.seq].cprop[d2.seq].cpropname, col 50,
      ddr_reg->ckey[d.seq].cprop[d2.seq].cpropval, row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxcol = 512
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ( NOT (validate(drrr_responsefile_in_use,- (1))=1))
     SET dm_err->eproc = concat("Displaying TARGET Registry Warning Report ",drri_full_fname)
     FREE DEFINE rtl2
     DEFINE rtl2 value(drri_fname)
     SELECT INTO mine
      t.line
      FROM rtl2t t
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
    ELSE
     IF ((drer_email_list->email_cnt > 0))
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "TARGET Registry Warning Report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      SET drer_email_det->attachment = drri_full_fname
      CALL drer_add_body_text(concat("TARGET Registry Warning Report was generated at ",format(
         drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat("User Action : Please review the report to ensure ",
        "Target properties reflect the correct values."),0)
      CALL drer_add_body_text(concat("Report file name : ",drri_full_fname),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Target Registry Warnings Detected:  Report can be found in : ",
     drri_full_fname)
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_check_sqlnet(dcs_src_ind,dcs_tgt_ind,dcs_oracle_home)
   DECLARE dcs_sqlnet_file = vc WITH protect, noconstant("")
   DECLARE dcs_sqlnet_dir = vc WITH protect, noconstant("")
   DECLARE dcs_sqlnet_path = vc WITH protect, noconstant("")
   DECLARE dcs_file_name = vc WITH protect, noconstant("")
   DECLARE dcs_dir = vc WITH protect, noconstant("")
   DECLARE dcs_cmd = vc WITH protect, noconstant("")
   DECLARE dcs_val = vc WITH protect, noconstant("DM2NOTSET")
   SET dm_err->eproc = "Verify that sqlnet.ora file has the bequeath_detach parameter"
   CALL disp_msg("",dm_err->logfile,0)
   SET dcs_sqlnet_file = "sqlnet.ora"
   SET dcs_sqlnet_dir = concat(dcs_oracle_home,"/network/admin/")
   SET dcs_sqlnet_path = concat(dcs_sqlnet_dir,dcs_sqlnet_file)
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("ORACLE_HOME: ",dcs_oracle_home))
    CALL echo(concat("DIRECTORY: ",dcs_sqlnet_dir))
    CALL echo(concat("FILE: ",dcs_sqlnet_file))
    CALL echo(concat("FULL PATH: ",dcs_sqlnet_path))
   ENDIF
   IF (trim(dcs_oracle_home)="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Oracle Home value passed in is invalid"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (findstring("10.",dcs_oracle_home,1,1)=0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Parse through sqlnet.ora"
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dcs_sqlnet_path)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     beg_pos = 0, end_pos = 0
    DETAIL
     beg_pos = 0, end_pos = 0
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("LINE = ",r.line))
     ENDIF
     beg_pos = findstring("=",r.line,1,0)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("BEG_POS=",beg_pos))
     ENDIF
     end_pos = size(trim(r.line))
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("END_POS=",end_pos))
     ENDIF
     IF (beg_pos > 0
      AND end_pos > 0)
      IF (findstring("bequeath_detach",cnvtlower(trim(r.line)),1,0) > 0)
       dcs_val = replace(substring((beg_pos+ 1),(end_pos - beg_pos),r.line)," ","",0)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dcs_val=",dcs_val))
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtlower(dcs_val) != "yes")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(
     "bequeath_detach property either does NOT exist or is NOT set correctly ",
     "in $ORACLE_HOME/network/admin/sqlnet.ora")
    SET dm_err->user_action =
    "Modify the sqlnet.ora file to have the following line (without quotes): 'bequeath_detach=yes'"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_data_collection_space_needs(ddcsn_src_ind,ddcsn_tgt_ind)
   DECLARE ddcsn_file_name = vc WITH protect, noconstant("")
   DECLARE ddcsn_cmd = vc WITH protect, noconstant("")
   DECLARE ddcsn_path = vc WITH protect, noconstant("")
   DECLARE ddcsn_domain_name = vc WITH protect, noconstant("")
   DECLARE ddcsn_user = vc WITH protect, noconstant("")
   DECLARE ddcsn_tmp_dir = vc WITH protect, noconstant("")
   DECLARE ddcsn_srv_path = vc WITH protect, noconstant("")
   DECLARE ddcsn_srv_found_flag = i2 WITH protect, noconstant(0)
   DECLARE ddcsn_tmp_err_ind = i2 WITH protect, noconstant(0)
   DECLARE ddcsn_ccldir = vc WITH protect, noconstant("")
   DECLARE ddcsn_ccluserdir_dir = vc WITH protect, noconstant("")
   DECLARE ddcsn_warehouse_dir = vc WITH protect, noconstant("")
   DECLARE ddcsn_cer_config_dir = vc WITH protect, noconstant("")
   DECLARE ddcsn_ocdtools_dir = vc WITH protect, noconstant("")
   DECLARE ddcsn_cer_forms_dir = vc WITH protect, noconstant("")
   DECLARE ddcsn_tdb_id = i4 WITH protect, noconstant(0)
   DECLARE ddcsn_tdb_file = vc WITH protect, noconstant("")
   DECLARE ddcsn_temp_size = vc WITH protect, noconstant("")
   DECLARE ddcsn_size_nbr = f8 WITH protect, noconstant(0.0)
   DECLARE ddcsn_cnt = i4 WITH protect, noconstant(0)
   DECLARE ddcsn_str = vc WITH protect, noconstant("")
   DECLARE ddcsn_report_destination = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Calculate space needs for various ",evaluate(ddcsn_tgt_ind,1,"TGT",
     "SRC")," components ")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (ddr_get_from_dir(ddcsn_src_ind,"cer_config",ddcsn_cer_config_dir)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_from_dir(ddcsn_src_ind,"ccldir",ddcsn_ccldir)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_from_dir(ddcsn_src_ind,"cer_ocdtools",ddcsn_ocdtools_dir)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_from_dir(ddcsn_src_ind,"cer_wh",ddcsn_warehouse_dir)=0)
    RETURN(0)
   ENDIF
   IF (ddr_get_from_dir(ddcsn_src_ind,"ccluserdir",ddcsn_ccluserdir_dir)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (ddr_get_from_dir(ddcsn_src_ind,"cer_forms",ddcsn_cer_forms_dir)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddcsn_src_ind=1)
    SET ddcsn_domain_name = ddr_domain_data->src_domain_name
    SET ddcsn_path = ddr_domain_data->src_tmp_full_dir
    IF ((ddr_domain_data->src_tdb_server_master_id > 0))
     SET ddcsn_tdb_id = ddr_domain_data->src_tdb_server_master_id
    ENDIF
   ELSEIF (ddcsn_tgt_ind=1)
    SET ddcsn_domain_name = ddr_domain_data->tgt_domain_name
    SET ddcsn_path = ddr_domain_data->tgt_tmp_full_dir
    IF ((ddr_domain_data->tgt_tdb_server_master_id > 0))
     SET ddcsn_tdb_id = ddr_domain_data->tgt_tdb_server_master_id
    ELSEIF ((ddr_domain_data->tgt_tdb_server_slave_id > 0))
     SET ddcsn_tdb_id = ddr_domain_data->tgt_tdb_server_slave_id
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(ddcsn_domain_name)
    CALL echo(ddcsn_ccldir)
    CALL echo(ddcsn_ccluserdir_dir)
    CALL echo(ddcsn_warehouse_dir)
    CALL echo(ddcsn_cer_config_dir)
    CALL echo(ddcsn_ocdtools_dir)
   ENDIF
   SET ddcsn_file_name = concat(ddcsn_path,"space_needs.dat")
   IF (dm2_findfile(ddcsn_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET ddcsn_cmd = concat("del ",ddcsn_file_name,";*")
    ELSE
     SET ddcsn_cmd = concat("rm ",ddcsn_file_name)
    ENDIF
    IF (dm2_push_dcl(ddcsn_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET ddcsn_file_name = concat(ddcsn_path,"calc_space_needs",evaluate(dm2_sys_misc->cur_os,"AXP",
     ".com",".ksh"))
   IF (dm2_findfile(ddcsn_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET ddcsn_cmd = concat("del ",ddcsn_file_name,";*")
    ELSE
     SET ddcsn_cmd = concat("rm ",ddcsn_file_name)
    ENDIF
    IF (dm2_push_dcl(ddcsn_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (ddr_get_tdb_file(ddcsn_src_ind,ddcsn_tgt_ind,ddcsn_tdb_id,ddcsn_tdb_file)=0)
    RETURN(0)
   ENDIF
   CALL echo(ddcsn_tdb_file)
   SET dm_err->eproc = concat("Create file to calculate space needs: ",ddcsn_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(ddcsn_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!calc_space_needs.com"), row + 1,
      CALL print("$!"),
      row + 1,
      CALL print('$tgt_node=f$getsyi("nodename")'), row + 1,
      ddcsn_cmd = concat('$if f$search("',ddcsn_path,'sn_temp.dat") .nes. "" then delete ',ddcsn_path,
       "sn_temp.dat;*"),
      CALL print(ddcsn_cmd), row + 1,
      CALL print(concat("$define/user_mode sys$output ",ddcsn_path,"sn_temp.dat")), row + 1,
      CALL print(concat("$open/write SPACE_NEEDS ",ddcsn_path,"space_needs.dat")),
      row + 1, ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",ddcsn_ccldir,
       "dic.dat"," /out=",
       ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print(
      '$call get_size "dicdat"                                                            '), row + 1,
      ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",ddcsn_warehouse_dir,
       " /out=",ddcsn_path,
       "sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      CALL print(
      '$call get_size "warehouse"                                                            '), row
       + 1, ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",
       ddcsn_ocdtools_dir," /out=",ddcsn_path,
       "sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      CALL print(
      '$call get_size "ocd_tools"                                                            '),
      row + 1, ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",ddcsn_ccldir,
       " /out=",ddcsn_path,
       "sn_temp.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print(
      '$call get_size "ccldir"                                                            '), row + 1,
      ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",ddcsn_cer_config_dir,
       " /out=",ddcsn_path,
       "sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      CALL print(
      '$call get_size "cer_config"                                                            '), row
       + 1, ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",ddcsn_tdb_file,
       " /out=",ddcsn_path,
       "sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      CALL print(
      '$call get_size "tdb_export"                                                            '),
      row + 1, ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",
       ddcsn_cer_config_dir,"sec_user.dat"," /out=",
       ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print(
      '$call get_size "sec_user_export"                                                            '),
      row + 1,
      ddcsn_cmd = concat("pipe dir /grand_total/size=all/size=units=bytes "," ",ddcsn_ccluserdir_dir,
       " /out=",ddcsn_path,
       "sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      CALL print(
      '$call get_size "ccluserdir"                                                            '), row
       + 1,
      CALL print("$deassign sys$output"),
      row + 1,
      CALL print("$close SPACE_NEEDS  "), row + 1,
      CALL print(
      "$!----------------------                                                              "), row
       + 1,
      CALL print(
      "$!subroutine definition                                                               "),
      row + 1,
      CALL print(
      "$!----------------------                                                              "), row
       + 1,
      CALL print(
      "$!------------------------------------                                                "), row
       + 1,
      CALL print(
      "$! subroutine:                                                                        "),
      row + 1,
      CALL print(
      "$!      get_size - get size from sn_temp.dat                                          "), row
       + 1,
      CALL print(
      "$!-----------------------------------                                                 "), row
       + 1,
      CALL print(
      "$GET_SIZE:                                                                               "),
      row + 1,
      CALL print(
      "$SUBROUTINE                                                                           "), row
       + 1,
      CALL print('$size = " "'), row + 1,
      CALL print("$length = 0"),
      row + 1,
      CALL print("$size_pos = 0"), row + 1,
      CALL print(concat("$open/read SN_TEMP ",ddcsn_path,"sn_temp.dat")), row + 1,
      CALL print("$READ_SN_TEMP:"),
      row + 1,
      CALL print("$   read/end_of_file=END_SN_TEMP SN_TEMP record"), row + 1,
      CALL print("$   length = f$length(record)"), row + 1,
      CALL print('$   if(f$locate("no such file" ,record) .ne. length)'),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print("$      goto END_SN_TEMP"), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print('$   if(f$locate("Grand total" ,record) .ne. length)'), row + 1,
      CALL print("$   then"), row + 1,
      CALL print('$      if(f$locate("files," ,record) .ne. length)'),
      row + 1,
      CALL print("$      then"), row + 1,
      CALL print('$         size_pos = f$locate("files," ,record) + 6'), row + 1,
      CALL print("$         size = f$extract(size_pos,length - size_pos,record)"),
      row + 1,
      CALL print("$         goto END_SN_TEMP "), row + 1,
      CALL print("$      else"), row + 1,
      CALL print('$         if(f$locate("file," ,record) .ne. length)'),
      row + 1,
      CALL print("$         then"), row + 1,
      CALL print('$            size_pos = f$locate("file," ,record) + 5'), row + 1,
      CALL print("$            size = f$extract(size_pos,length - size_pos,record)"),
      row + 1,
      CALL print("$            goto END_SN_TEMP "), row + 1,
      CALL print("$         endif"), row + 1,
      CALL print("$      endif"),
      row + 1,
      CALL print("$   endif"), row + 1,
      CALL print("$   goto READ_SN_TEMP"), row + 1,
      CALL print("$END_SN_TEMP: "),
      row + 1,
      CALL print("$   close SN_TEMP  "), row + 1,
      CALL print('$   if (size .eqs. " ")'), row + 1,
      CALL print("$   then"),
      row + 1,
      CALL print("$      deassign sys$output"), row + 1,
      CALL print(^$      write sys$output "Error :Could not determine size for ''p1'"^), row + 1,
      CALL print("$      exit 1"),
      row + 1,
      CALL print("$   else"), row + 1,
      CALL print(^$      write SPACE_NEEDS "''p1'=''size'"^), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print(
      "$ENDSUBROUTINE                                                                        "), row
       + 1
     ELSE
      CALL print("#!/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("tgt_node=`hostname`"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_ccldir,"dic.dat > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for dic.dat"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "dicdat="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_ccldir,"dic.idx > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for dic.idx"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "dicidx="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_warehouse_dir," > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for warehouse"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "warehouse="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_ocdtools_dir," > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for ocd_tools"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "ocd_tools="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_ccldir," > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for ccldir"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "ccldir="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_cer_config_dir," > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for cer_config"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "cer_config="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_cer_forms_dir," > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for cer_forms"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "cer_forms="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1,
      ddcsn_cmd = concat("du -sk ",ddcsn_tdb_file," > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for tdb_export"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "tdb_export="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1
      IF ((((ddr_domain_data->src_was_arch_ind=0)
       AND ddcsn_src_ind=1) OR ((ddr_domain_data->tgt_was_arch_ind=0)
       AND ddcsn_tgt_ind=1)) )
       ddcsn_cmd = concat("du -sk ",ddcsn_cer_config_dir,"sec_user.dat > ",ddcsn_path,"sn_temp.dat"),
       CALL print(ddcsn_cmd), row + 1,
       ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
        'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
       CALL print(ddcsn_cmd), row + 1,
       CALL print("if [[ $? -eq 0 ]]"), row + 1,
       CALL print("then"),
       row + 1,
       CALL print('   echo "Error :Could not determine size for sec_user"'), row + 1,
       CALL print("   exit 1"), row + 1,
       CALL print("else"),
       row + 1, ddcsn_cmd = concat(^   awk '{print "sec_user="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
        ddcsn_path,"space_needs.dat"),
       CALL print(ddcsn_cmd),
       row + 1,
       CALL print("fi"), row + 1
      ENDIF
      ddcsn_cmd = concat("du -sk ",ddcsn_ccluserdir_dir," > ",ddcsn_path,"sn_temp.dat"),
      CALL print(ddcsn_cmd), row + 1,
      ddcsn_cmd = concat("tr '[:upper:]' '[:lower:]' < ",ddcsn_path,
       'sn_temp.dat |grep "a file or directory in the path name does not exist" '),
      CALL print(ddcsn_cmd), row + 1,
      CALL print("if [[ $? -eq 0 ]]"), row + 1,
      CALL print("then"),
      row + 1,
      CALL print('   echo "Error :Could not determine size for ccluserdir"'), row + 1,
      CALL print("   exit 1"), row + 1,
      CALL print("else"),
      row + 1, ddcsn_cmd = concat(^   awk '{print "ccluserdir="$1}' ^,ddcsn_path,"sn_temp.dat >> ",
       ddcsn_path,"space_needs.dat"),
      CALL print(ddcsn_cmd),
      row + 1,
      CALL print("fi"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echo("Failed to create ksh.")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute file: ",ddcsn_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET ddcsn_cmd = concat("@",ddcsn_file_name)
   ELSE
    SET ddcsn_cmd = concat("chmod 777 ",ddcsn_file_name)
    IF (dm2_push_dcl(ddcsn_cmd)=0)
     RETURN(0)
    ENDIF
    SET ddcsn_cmd = concat(". ",ddcsn_file_name)
   ENDIF
   SET ddcsn_tmp_err_ind = dm_err->err_ind
   IF (dm2_push_dcl(ddcsn_cmd)=0)
    RETURN(0)
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (findstring("Error : Could not determine",dm_err->errtext,1,1) > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Unable to determine space needs estimate"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   SET ddcsn_file_name = concat(ddcsn_path,"space_needs.dat")
   IF (dm2_findfile(ddcsn_file_name)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Find file ",ddcsn_file_name)
     SET dm_err->emsg = concat("Failed to find ",ddcsn_file_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Parse out space needs from space_needs.dat"
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(ddcsn_file_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     beg_pos = 0, end_pos = 0
    DETAIL
     beg_pos = 0, end_pos = 0
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("LINE = ",r.line))
     ENDIF
     beg_pos = findstring("=",r.line,1,0)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("BEG_POS=",beg_pos))
     ENDIF
     end_pos = size(trim(r.line))
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("END_POS=",end_pos))
     ENDIF
     IF (beg_pos > 0
      AND end_pos > 0)
      ddcsn_temp_size = substring((beg_pos+ 1),(end_pos - beg_pos),r.line)
      IF ((dm2_sys_misc->cur_os="AXP"))
       ddcsn_pos = findstring("KB",ddcsn_temp_size,0)
       IF (ddcsn_pos > 0)
        ddcsn_temp_size = substring(1,(textlen(ddcsn_temp_size) - ddcsn_pos),ddcsn_temp_size)
       ENDIF
       ddcsn_pos = findstring("MB",ddcsn_temp_size,0)
       IF (ddcsn_pos > 0)
        ddcsn_temp_size = substring(1,(ddcsn_pos - 1),ddcsn_temp_size), ddcsn_temp_size = cnvtstring(
         (cnvtreal(trim(ddcsn_temp_size)) * 1024))
       ENDIF
       ddcsn_pos = findstring("GB",ddcsn_temp_size,0)
       IF (ddcsn_pos > 0)
        ddcsn_temp_size = substring(1,(ddcsn_pos - 1),ddcsn_temp_size), ddcsn_temp_size = cnvtstring(
         ((cnvtreal(trim(ddcsn_temp_size)) * 1024) * 1024))
       ENDIF
      ENDIF
      IF (findstring("dicdat",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_dicdat_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_dicdat_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("dicidx",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_dicidx_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_dicidx_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("warehouse",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_wh_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_wh_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("ocd_tools",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_ocd_tools_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_ocd_tools_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("ccldir",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_ccldir_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_ccldir_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("cer_config",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_cer_config_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_cer_config_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("cer_forms",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_cer_forms_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_cer_forms_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("tdb_export",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_tdb_exp_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_tdb_exp_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("sec_user",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_sec_user_exp_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_sec_user_exp_size = ddcsn_temp_size
       ENDIF
      ELSEIF (findstring("ccluserdir",trim(r.line),1,0) > 0)
       IF (ddcsn_src_ind=1)
        ddr_space_needs->src_ccluserdir_size = ddcsn_temp_size
       ELSE
        ddr_space_needs->tgt_ccluserdir_size = ddcsn_temp_size
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_load_preserved_table_data("TABLE"," ")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_preserved_tables_data)
   ENDIF
   IF ((drr_preserved_tables_data->cnt > 0))
    SET ddcsn_size_nbr = 0.0
    SET dm_err->eproc = "Retieve space needs for preserved tables from user_segments"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM user_segments us
     WHERE us.segment_type="TABLE"
     DETAIL
      IF (locateval(ddcsn_cnt,1,drr_preserved_tables_data->cnt,us.segment_name,
       drr_preserved_tables_data->tbl[ddcsn_cnt].table_name) > 0)
       ddcsn_size_nbr = (ddcsn_size_nbr+ us.bytes)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET ddcsn_size_nbr = cnvtreal((ddcsn_size_nbr/ 1024.0))
    SET ddr_space_needs->tgt_preserve_tbl_size = cnvtstring(ddcsn_size_nbr)
   ENDIF
   IF (ddcsn_src_ind=1)
    IF ((ddr_domain_data->src_interrogator_ind=1))
     IF (ddr_interrogator_backup("SIZE")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (ddcsn_src_ind=1)
    SET ddr_space_needs->src_srv_def_size = "50.0"
    SET ddr_space_needs->src_env_reg_size = "1.0"
    SET ddr_space_needs->src_sys_reg_size = "1.0"
    SET ddr_space_needs->src_link_data_size = "1.0"
    SET ddr_space_needs->src_misc_data_size = "1.0"
    SET ddcsn_size_nbr = (((((((((((cnvtreal(ddr_space_needs->src_wh_size)+ cnvtreal(ddr_space_needs
     ->src_ocd_tools_size))+ cnvtreal(ddr_space_needs->src_ccldir_size))+ cnvtreal(ddr_space_needs->
     src_cer_config_size))+ cnvtreal(ddr_space_needs->src_tdb_exp_size))+ cnvtreal(ddr_space_needs->
     src_srv_def_size))+ cnvtreal(ddr_space_needs->src_sec_user_exp_size))+ cnvtreal(ddr_space_needs
     ->src_env_reg_size))+ cnvtreal(ddr_space_needs->src_sys_reg_size))+ cnvtreal(ddr_space_needs->
     src_link_data_size))+ cnvtreal(ddr_space_needs->src_misc_data_size))+ cnvtreal(ddr_space_needs->
     src_interrogator_size))
    SET ddcsn_size_nbr = (ddcsn_size_nbr/ 1024)
    SET ddr_space_needs->tot_src_temp_dir_size = cnvtstring(ddcsn_size_nbr)
    SET ddcsn_size_nbr = (cnvtreal(ddr_space_needs->src_dicdat_size)+ cnvtreal(ddr_space_needs->
     src_dicidx_size))
    SET ddcsn_size_nbr = (ddcsn_size_nbr/ 1024)
    SET ddr_space_needs->tot_src_cer_install_size = cnvtstring(ddcsn_size_nbr)
   ELSE
    SET ddr_space_needs->tgt_srv_def_size = "50.0"
    SET ddr_space_needs->tgt_env_reg_size = "1.0"
    SET ddr_space_needs->tgt_sys_reg_size = "1.0"
    SET ddr_space_needs->tgt_link_data_size = "1.0"
    SET ddr_space_needs->tgt_misc_data_size = "1.0"
    SET ddr_space_needs->tgt_srv_bkup_size = "1.0"
    SET ddr_space_needs->tgt_sys_reg_cpy_size = "1.0"
    SET ddcsn_size_nbr = ((((((((((cnvtreal(ddr_space_needs->tgt_wh_size)+ cnvtreal(ddr_space_needs->
     tgt_ccluserdir_size))+ cnvtreal(ddr_space_needs->tgt_cer_forms_size))+ cnvtreal(ddr_space_needs
     ->tgt_tdb_exp_size))+ cnvtreal(ddr_space_needs->tgt_srv_def_size))+ cnvtreal(ddr_space_needs->
     tgt_srv_bkup_size))+ cnvtreal(ddr_space_needs->tgt_sec_user_exp_size))+ cnvtreal(ddr_space_needs
     ->tgt_env_reg_size))+ cnvtreal(ddr_space_needs->tgt_sys_reg_size))+ cnvtreal(ddr_space_needs->
     tgt_sys_reg_cpy_size))+ cnvtreal(ddr_space_needs->tgt_misc_data_size))
    SET ddcsn_size_nbr = cnvtreal((ddcsn_size_nbr/ 1024))
    SET ddr_space_needs->tot_tgt_temp_dir_size = cnvtstring(ddcsn_size_nbr)
    SET ddcsn_size_nbr = (cnvtreal(ddr_space_needs->tgt_dicdat_size)+ cnvtreal(ddr_space_needs->
     tgt_dicidx_size))
    SET ddcsn_size_nbr = cnvtreal((ddcsn_size_nbr/ 1024))
    SET ddr_space_needs->tot_tgt_cer_install_size = cnvtstring(ddcsn_size_nbr)
    SET ddcsn_size_nbr = ((((((((cnvtreal(ddr_space_needs->tgt_cer_forms_size)+ cnvtreal(
     ddr_space_needs->tgt_tdb_exp_size))+ cnvtreal(ddr_space_needs->tgt_srv_def_size))+ cnvtreal(
     ddr_space_needs->tgt_srv_bkup_size))+ cnvtreal(ddr_space_needs->tgt_sec_user_exp_size))+
    cnvtreal(ddr_space_needs->tgt_env_reg_size))+ cnvtreal(ddr_space_needs->tgt_sys_reg_size))+
    cnvtreal(ddr_space_needs->tgt_sys_reg_cpy_size))+ cnvtreal(ddr_space_needs->tgt_misc_data_size))
    SET ddcsn_size_nbr = cnvtreal((ddcsn_size_nbr/ 1024))
    SET ddr_space_needs->opt_tgt_temp_dir_size = cnvtstring(ddcsn_size_nbr)
    SET ddcsn_size_nbr = (cnvtreal(ddr_space_needs->tgt_dicdat_size)+ cnvtreal(ddr_space_needs->
     tgt_dicidx_size))
    SET ddcsn_size_nbr = cnvtreal((ddcsn_size_nbr/ 1024))
    SET ddr_space_needs->opt_tgt_cer_install_size = cnvtstring(ddcsn_size_nbr)
   ENDIF
   SET dm_err->eproc = "Display space needs estimates report"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF (get_unique_file("dm2_dom_spc_needs",".rpt")=0)
     RETURN(0)
    ENDIF
    SET ddcsn_report_destination = dm_err->unique_fname
    SET drr_rpt_file = build(drrr_misc_data->active_dir,ddcsn_report_destination)
    SELECT INTO value(ddcsn_report_destination)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      IF (ddcsn_src_ind=1)
       row + 0, col 0, "Source Data Collection requires the following space needs: "
      ELSE
       row + 0, col 0, "Target Data Collection requires the following space needs: "
      ENDIF
     DETAIL
      IF (ddcsn_src_ind=1)
       ddcsn_str = concat(ddcsn_path," :   ",build(ddr_space_needs->tot_src_temp_dir_size,"MB")), row
        + 2, col 0,
       ddcsn_str, ddcsn_str = concat("cer_install : ",build(ddr_space_needs->tot_src_cer_install_size,
         "MB")), row + 2,
       col 0, ddcsn_str
       IF ((ddr_domain_data->src_interrogator_node != trim(curnode))
        AND (ddr_domain_data->src_interrogator_ind=1))
        ddcsn_str = concat(drrr_rf_data->tgt_interrogator_tmp_dir," :   ",build(ddr_space_needs->
          src_interrogator_size,"MB")), row + 2, col 0,
        ddcsn_str
       ENDIF
      ELSE
       row + 2, col 0, "If ALL Target Data (including optional components) is Collected:",
       ddcsn_str = concat(ddcsn_path," :   ",build(ddr_space_needs->tot_tgt_temp_dir_size,"MB")), row
        + 2, col 0,
       ddcsn_str, ddcsn_str = concat("cer_install : ",build(ddr_space_needs->tot_tgt_cer_install_size,
         "MB")), row + 1,
       col 0, ddcsn_str
       IF ((der_expimp_data->tgt_temp_dir != ""))
        ddcsn_str = concat(der_expimp_data->tgt_temp_dir," : ",ddr_space_needs->tgt_preserve_tbl_size,
         "MB"), row + 1, col 0,
        ddcsn_str
       ENDIF
       row + 2, col 0, "If only REQUIRED Target Data (excluding optional components) is Collected:",
       ddcsn_str = concat(ddcsn_path," :   ",build(ddr_space_needs->opt_tgt_temp_dir_size,"MB")), row
        + 2, col 0,
       ddcsn_str, ddcsn_str = concat("cer_install : ",build(ddr_space_needs->opt_tgt_cer_install_size,
         "MB")), row + 1,
       col 0, ddcsn_str
      ENDIF
      row + 2, col 0, "Verify space needs are met before continuing"
     WITH nocounter, nullreport, maxcol = 132,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Skipping display of SPACE NEEDS ESTIMATES REPORT (",
     ddcsn_report_destination,")")
    CALL disp_msg("",dm_err->logfile,0)
    IF ((drer_email_list->email_cnt > 0))
     SET drer_email_det->msgtype = "ACTIONREQ"
     SET drer_email_det->status = "REPORT"
     SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
     SET drer_email_det->step = "SPACE NEEDS ESTIMATES REPORT"
     SET drer_email_det->email_level = 1
     SET drer_email_det->logfile = dm_err->logfile
     SET drer_email_det->err_ind = dm_err->err_ind
     SET drer_email_det->eproc = dm_err->eproc
     SET drer_email_det->emsg = dm_err->emsg
     SET drer_email_det->user_action = dm_err->user_action
     SET drer_email_det->attachment = ddcsn_report_destination
     CALL drer_add_body_text(concat("SPACE NEEDS ESTIMATES REPORT was generated at ",format(
        drer_email_det->status_dt_tm,";;q")),1)
     CALL drer_add_body_text(concat("User Action : Please review the report to ensure ",
       "required space is available."),0)
     CALL drer_add_body_text(concat("Report file name : ",trim(ddcsn_report_destination,3)),0)
     IF (drer_compose_email(null)=1)
      CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
       email_level)
     ENDIF
     CALL drer_reset_pre_err(null)
    ENDIF
   ELSE
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,20,131)
    CALL text(2,2,concat(evaluate(ddcsn_src_ind,1,"Source","Target"),
      " Data Collection requires the following space needs: "))
    IF (ddcsn_src_ind=1)
     CALL text(5,2,concat(ddcsn_path," :   ",build(ddr_space_needs->tot_src_temp_dir_size,"MB")))
     CALL text(7,2,concat("cer_install : ",build(ddr_space_needs->tot_src_cer_install_size,"MB")))
    ELSE
     CALL text(4,2,"If ALL Target Data (including optional components) is Collected:")
     CALL text(5,2,concat(ddcsn_path," :   ",build(ddr_space_needs->tot_tgt_temp_dir_size,"MB")))
     CALL text(6,2,concat("cer_install : ",build(ddr_space_needs->tot_tgt_cer_install_size,"MB")))
     IF ((der_expimp_data->tgt_temp_dir != ""))
      CALL text(7,2,concat(der_expimp_data->tgt_temp_dir," : ",ddr_space_needs->tgt_preserve_tbl_size,
        "MB"))
     ENDIF
     CALL text(9,2,"If only REQUIRED Target Data (excluding optional components) is Collected:")
     CALL text(10,2,concat(ddcsn_path," :   ",build(ddr_space_needs->opt_tgt_temp_dir_size,"MB")))
     CALL text(11,2,concat("cer_install : ",build(ddr_space_needs->opt_tgt_cer_install_size,"MB")))
    ENDIF
    CALL text(14,2,"Verify space needs are met before continuing")
    CALL text(16,2,"Continue/Exit [C/E]:")
    CALL accept(16,23,"A;cu"," "
     WHERE curaccept IN ("C", "E"))
    IF (curaccept="E")
     CALL clear(1,1)
     SET message = nowindow
     SET dm_err->emsg = "User elected to quit from space needs estimate report"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->eproc = "Space needs have been verified by the user"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_tdb_file(dgtf_src_ind,dgtf_tgt_ind,dgtf_server_id,dgtf_file_ret)
   DECLARE dgtf_file_name = vc WITH protect, noconstant("")
   DECLARE dgtf_cmd = vc WITH protect, noconstant("")
   DECLARE dgtf_path = vc WITH protect, noconstant("")
   DECLARE dgtf_domain_name = vc WITH protect, noconstant("")
   DECLARE dgtf_user = vc WITH protect, noconstant("")
   DECLARE dgtf_pw = vc WITH protect, noconstant("")
   DECLARE dgtf_srv_found_flag = i2 WITH protect, noconstant(0)
   DECLARE dgtf_tmp_err_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Find TDB file name from SCP entry for TDB id: ",build(dgtf_server_id))
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dgtf_src_ind=1)
    SET dgtf_domain_name = ddr_domain_data->src_domain_name
    SET dgtf_path = ddr_domain_data->src_tmp_full_dir
    SET dgtf_user = ddr_domain_data->src_mng
    SET dgtf_pw = ddr_domain_data->src_mng_pwd
   ELSEIF (dgtf_tgt_ind=1)
    SET dgtf_path = ddr_domain_data->tgt_tmp_full_dir
    SET dgtf_domain_name = ddr_domain_data->tgt_domain_name
    SET dgtf_user = ddr_domain_data->tgt_mng
    SET dgtf_pw = ddr_domain_data->tgt_mng_pwd
   ENDIF
   SET dgtf_file_ret = "NOT FOUND"
   SET dgtf_file_name = concat(dgtf_path,"server_entry.dat")
   IF (dm2_findfile(dgtf_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgtf_cmd = concat("del ",dgtf_file_name,";*")
    ELSE
     SET dgtf_cmd = concat("rm ",dgtf_file_name)
    ENDIF
    IF (dm2_push_dcl(dgtf_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dgtf_file_name = concat(dgtf_path,"server_file_name.dat")
   IF (dm2_findfile(dgtf_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgtf_cmd = concat("del ",dgtf_file_name,";*")
    ELSE
     SET dgtf_cmd = concat("rm ",dgtf_file_name)
    ENDIF
    IF (dm2_push_dcl(dgtf_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dgtf_file_name = concat(dgtf_path,"get_file_name",evaluate(dm2_sys_misc->cur_os,"AXP",".com",
     ".ksh"))
   IF (dm2_findfile(dgtf_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgtf_cmd = concat("del ",dgtf_file_name,";*")
    ELSE
     SET dgtf_cmd = concat("rm ",dgtf_file_name)
    ENDIF
    IF (dm2_push_dcl(dgtf_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to find server file name for ",build(dgtf_server_id),": ",
    dgtf_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dgtf_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!get_file_name.com"), row + 1,
      CALL print("$!"),
      row + 1,
      CALL print('$tgt_node=f$getsyi("nodename")'), row + 1,
      dgtf_cmd = concat('$if f$search("',dgtf_path,'server_entry.dat") .nes. "" then delete ',
       dgtf_path,"server_entry.dat;*"),
      CALL print(dgtf_cmd), row + 1,
      CALL print('$file_name = "NOT_FOUND"'), row + 1,
      CALL print("$param_pos = 0"),
      row + 1,
      CALL print('$param_str = "NOT FOUND"'), row + 1,
      CALL print("$tries = 0"), row + 1,
      CALL print(concat("$define/user_mode sys$output ",dgtf_path,"server_entry.dat")),
      row + 1,
      CALL print("$mcr cer_exe:scpview 'tgt_node'"), row + 1,
      CALL print("$DECK"), row + 1,
      CALL print(dgtf_user),
      row + 1,
      CALL print(dgtf_domain_name), row + 1,
      CALL print(dgtf_pw), row + 1,
      CALL print(concat("show ",build(dgtf_server_id))),
      row + 1,
      CALL print("exit"), row + 1,
      CALL print("$EOD"), row + 1,
      CALL print(concat("$open/read TDB_FILE ",dgtf_path,"server_entry.dat")),
      row + 1,
      CALL print("$tries = tries + 1"), row + 1,
      CALL print("$READ_TDB_FILE:"), row + 1,
      CALL print("$   read/end_of_file=END_READ_TDB_FILE TDB_FILE record"),
      row + 1,
      CALL print("$   length = f$length(record)"), row + 1,
      CALL print('$   if(f$locate("entry not found" ,record) .ne. length)'), row + 1,
      CALL print("$   then"),
      row + 1,
      CALL print("$      goto END_READ_TDB_FILE "), row + 1,
      CALL print("$   endif"), row + 1,
      CALL print('$   if(f$locate("parameters:" ,record) .ne. length)'),
      row + 1,
      CALL print("$   then"), row + 1,
      CALL print('$      param_pos = f$locate("-" ,record)'), row + 1,
      CALL print("$      param_str = f$extract(param_pos,length-param_pos,record)"),
      row + 1,
      CALL print('$      file_name = f$element(2," ",param_str)'), row + 1,
      CALL print("$      goto END_READ_TDB_FILE "), row + 1,
      CALL print("$   endif"),
      row + 1,
      CALL print("$!  write sys$output record "), row + 1,
      CALL print("$   goto READ_TDB_FILE "), row + 1,
      CALL print("$END_READ_TDB_FILE: "),
      row + 1,
      CALL print("$   close TDB_FILE  "), row + 1,
      CALL print("$deassign sys$output"), row + 1, dgtf_cmd = concat('$if f$search("',dgtf_path,
       'server_file_name.dat") .nes. "" then delete ',dgtf_path,"server_file_name.dat;*"),
      CALL print(dgtf_cmd), row + 1,
      CALL print(concat("$define sys$output ",dgtf_path,"server_file_name.dat")),
      row + 1,
      CALL print('$if (file_name .eqs. "NOT_FOUND") .or. (param_str .eqs. "NOT_FOUND")'), row + 1,
      CALL print("$then"), row + 1,
      CALL print(concat('$   write sys$output "error : server File is not found."')),
      row + 1,
      CALL print("$   exit 1"), row + 1,
      CALL print("$else"), row + 1,
      CALL print(concat(^$   write sys$output "server_file_name=''file_name'"^)),
      row + 1,
      CALL print("$   deassign sys$output"), row + 1,
      CALL print("$   exit 1"), row + 1,
      CALL print("$endif"),
      row + 1
     ELSE
      CALL print("#!/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("tgt_node=`hostname`"), row + 1,
      CALL print(concat("system_pwd='",dgtf_pw,"'")), row + 1,
      CALL print(concat("$cer_exe/scpview $tgt_node <<!>",dgtf_path,"server_entry.dat")),
      row + 1,
      CALL print(dgtf_user), row + 1,
      CALL print(dgtf_domain_name), row + 1,
      CALL print("$system_pwd"),
      row + 1,
      CALL print(concat("show ",build(dgtf_server_id))), row + 1,
      CALL print("exit"), row + 1,
      CALL print("!"),
      row + 1, row + 1, dgtf_cmd = concat("file_name=$(grep 'parameters:' ",dgtf_path,
       "server_entry.dat|"),
      dgtf_cmd = concat(dgtf_cmd,^awk -F"-" '{print $2}' | ^), dgtf_cmd = concat(dgtf_cmd,
       ^awk -F" " '{print $3}')^),
      CALL print(dgtf_cmd),
      row + 1,
      CALL print("if [[ -z $file_name ]]"), row + 1,
      CALL print("then"), row + 1,
      CALL print(concat('   echo "error : server File is not found."')),
      row + 1, dgtf_cmd = concat('   echo "error : server File is not found." >> ',dgtf_path,
       "server_file_name.dat"),
      CALL print(dgtf_cmd),
      row + 1,
      CALL print("else"), row + 1,
      dgtf_cmd = concat('   echo "server_file_name=$file_name" >> ',dgtf_path,"server_file_name.dat"),
      CALL print(dgtf_cmd), row + 1,
      CALL print("fi"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echo("Failed to create ksh.")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute file: ",dgtf_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgtf_cmd = concat("@",dgtf_file_name)
   ELSE
    SET dgtf_cmd = concat("chmod 777 ",dgtf_file_name)
    IF (dm2_push_dcl(dgtf_cmd)=0)
     RETURN(0)
    ENDIF
    SET dgtf_cmd = concat(". ",dgtf_file_name)
   ENDIF
   SET dgtf_tmp_err_ind = dm_err->err_ind
   IF (dm2_push_dcl(dgtf_cmd)=0)
    RETURN(0)
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (findstring("error : server File is not found",dm_err->errtext,1,1) > 0)
     SET dgtf_srv_found_flag = 0
     SET dgtf_file_ret = "NOT FOUND"
     SET dm_err->err_ind = dgtf_tmp_err_ind
    ELSE
     SET dgtf_srv_found_flag = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (dgtf_srv_found_flag=1)
    SET dgtf_file_name = concat(dgtf_path,"server_file_name.dat")
    IF (dm2_findfile(dgtf_file_name)=0)
     IF ((dm_err->err_ind=0))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Find file ",dgtf_file_name)
      SET dm_err->emsg = concat("Failed to find ",dgtf_file_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Parse out server file name for server id ",build(dgtf_server_id))
    CALL disp_msg("",dm_err->logfile,0)
    FREE DEFINE rtl2
    FREE SET file_loc
    SET logical file_loc value(dgtf_file_name)
    DEFINE rtl2 "file_loc"
    SELECT INTO "nl:"
     r.line
     FROM rtl2t r
     HEAD REPORT
      beg_pos = 0, end_pos = 0
     DETAIL
      beg_pos = 0, end_pos = 0
      IF ((dm_err->debug_flag > 1))
       CALL echo(concat("LINE = ",r.line))
      ENDIF
      beg_pos = findstring("=",r.line,1,0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("BEG_POS=",beg_pos))
      ENDIF
      end_pos = size(trim(r.line))
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("END_POS=",end_pos))
      ENDIF
      IF (beg_pos > 0
       AND end_pos > 0)
       IF (findstring("error : server",trim(r.line),1,0) > 0)
        dgtf_file_ret = "NOT FOUND"
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dgtf_file_ret=",dgtf_file_ret))
        ENDIF
       ELSEIF (findstring("server_file_name",trim(r.line),1,0) > 0)
        dgtf_file_ret = substring((beg_pos+ 1),(end_pos - beg_pos),r.line)
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dgtf_file_ret=",dgtf_file_ret))
        ENDIF
       ELSE
        dgtf_file_ret = "NOT FOUND"
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dgtf_file_ret=",dgtf_file_ret))
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter, maxcol = 255
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (((dgtf_file_ret="NOT FOUND") OR (dgtf_file_ret="")) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Failed to extract server file name for ",build(dgtf_server_id))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_findfile(dgtf_file_ret)=0)
     IF ( NOT ((dm2_sys_misc->cur_os="AXP")))
      IF (dm2_findfile(build("$",dgtf_file_ret))=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Failed to find server file name for ",build(dgtf_server_id))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       SET dgtf_file_ret = build("$",dgtf_file_ret)
      ENDIF
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find server file name for ",build(dgtf_server_id))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF ((dm_err->err_ind=1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_add_tar_error(date_src_ind,date_tgt_ind,date_type)
   DECLARE date_file = vc WITH protect, noconstant(concat(evaluate(date_src_ind,1,ddr_domain_data->
      src_tmp_full_dir,ddr_domain_data->tgt_tmp_full_dir),"tar_error_list.dat"))
   DECLARE date_cmd = vc WITH protect, noconstant("")
   IF (dm2_findfile(date_file)=0)
    SET date_cmd = concat("touch ",date_file)
    IF (dm2_push_dcl(date_cmd)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Writing tar error info to ",date_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "LNX"))
    SET date_cmd = concat('echo "',date_type,' | \c" >> ',date_file)
   ELSE
    SET date_cmd = concat('echo -e "',date_type,' | \c" >> ',date_file)
   ENDIF
   IF (dm2_push_dcl(date_cmd)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_tar_errors(dgte_src_ind,dgte_tgt_ind,dgte_tar_errors_ind,dgte_tar_errors_list)
   DECLARE dgte_file_name = vc WITH protect, noconstant("")
   DECLARE dgte_cmd = vc WITH protect, noconstant("")
   DECLARE dgte_path = vc WITH protect, noconstant("")
   DECLARE dgte_domain_name = vc WITH protect, noconstant("")
   DECLARE dgte_user = vc WITH protect, noconstant("")
   DECLARE dgte_pw = vc WITH protect, noconstant("")
   DECLARE dgte_srv_path = vc WITH protect, noconstant("")
   DECLARE dgte_err_found_flag = i2 WITH protect, noconstant(0)
   DECLARE dgte_tmp_err_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Find TAR error list file: tar_error_list.dat"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dgte_src_ind=1)
    SET dgte_domain_name = ddr_domain_data->src_domain_name
    SET dgte_path = ddr_domain_data->src_tmp_full_dir
   ELSEIF (dgte_tgt_ind=1)
    SET dgte_path = ddr_domain_data->tgt_tmp_full_dir
    SET dgte_domain_name = ddr_domain_data->tgt_domain_name
   ENDIF
   SET dgte_tar_errors_ind = 0
   SET dgte_err_found_flag = 0
   SET dgte_file_name = concat(dgte_path,"tar_error_list.dat")
   IF (dm2_findfile(dgte_file_name)=0)
    SET dgte_tar_errors_ind = 0
    SET dgte_tar_errors_list = "NONE"
    SET dm_err->eproc = "TAR error list file not found"
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Parse out tar errors "
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dgte_file_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF (textlen(trim(r.line)) > 2)
      IF ((dm_err->debug_flag > 1))
       CALL echo(concat("LINE = ",r.line))
      ENDIF
      dgte_tar_errors_list = r.line, dgte_tar_errors_ind = 1
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("dgte_tar_errors_list=",dgte_tar_errors_list)),
       CALL echo(build("dgte_tar_errors_ind=",dgte_tar_errors_ind))
      ENDIF
     ENDIF
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (((dgte_tar_errors_list="NONE") OR (dgte_tar_errors_list="")) )
    SET dgte_tar_errors_ind = 0
   ELSE
    SET dgte_tar_errors_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_adm_env(null)
   DECLARE dgae_file = vc WITH protect, noconstant("")
   DECLARE dgae_file_date = f8 WITH protect, noconstant(0.0)
   EXECUTE dm2_capture_env_history ddr_domain_data->src_tmp_full_dir, ddr_domain_data->
   src_db_env_name
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Check SOURCE Admin env history files ",ddr_domain_data->
    src_tmp_full_dir)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drr_validate_adm_env_csv(ddr_domain_data->src_tmp_full_dir,ddr_domain_data->src_db_env_name)=0
   )
    RETURN(0)
   ELSE
    SET dgae_file = concat(ddr_domain_data->src_tmp_full_dir,drr_env_hist_misc->summary_file)
    IF (ddr_get_file_date(dgae_file,dgae_file_date)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET ddr_domain_data->src_adm_env_csv_ts = dgae_file_date
   SET ddr_domain_data->src_adm_env_csv_fnd = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_prompt_tgt_backups(null)
   DECLARE dptb_rpt_file = vc WITH protect, noconstant("")
   DECLARE dptb_str = vc WITH protect, noconstant("")
   DECLARE dptb_locndx = i4 WITH protect, noconstant(0)
   DECLARE dptd_user_exists = i4 WITH protect, noconstant(0)
   FREE RECORD dptb_db_users
   RECORD dptb_db_users(
     1 cnt = i4
     1 qual[*]
       2 db_user_name = vc
   )
   SET dptb_db_users->cnt = 0
   SET dm_err->eproc = "Getting all non oracle database users."
   SELECT INTO "nl:"
    FROM dba_users u
    WHERE "CDBA" != u.username
     AND  NOT (u.username IN (
    (SELECT
     di.info_name
     FROM dm_info di
     WHERE di.info_domain="DM2_ORACLE_USER"
      AND di.info_number=1)))
    ORDER BY u.username
    HEAD REPORT
     dptb_db_users->cnt = 0, stat = alterlist(dptb_db_users->qual,dptb_db_users->cnt)
    DETAIL
     dptb_db_users->cnt = (dptb_db_users->cnt+ 1), stat = alterlist(dptb_db_users->qual,dptb_db_users
      ->cnt), dptb_db_users->qual[dptb_db_users->cnt].db_user_name = u.username
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (get_unique_file("dm2_tgt_db_backup",".rpt")=0)
    RETURN(0)
   ELSE
    SET dptb_rpt_file = dm_err->unique_fname
   ENDIF
   SET dptb_rpt_file = concat(ddr_domain_data->tgt_tmp_dir,dptb_rpt_file)
   SET logical dptb_rpt_file_logical dptb_rpt_file
   SET dm_err->eproc = "Generating target database backup report."
   SELECT INTO dptb_rpt_file_logical
    HEAD REPORT
     col 30,
     CALL print("TARGET DATABASE BACKUP WARNING REPORT"), row + 1
    DETAIL
     col 0, "BACKUP EXISTING TARGET DATA BEFORE REFRESH", row + 1,
     dptb_str = concat("Environment Name: ",ddr_domain_data->tgt_env), row + 1, col 0,
     dptb_str, dptb_str = concat("Database Name: ",dm2_install_schema->target_dbase_name), col 40,
     dptb_str, row + 1, dptb_str = concat(
      "If using Cerner tools that only refreshes the V500 user, only tables owned by V500 will be ",
      "dropped on TARGET prior to"),
     row + 1, col 0, dptb_str,
     dptb_str = concat(
      "performing imports from SOURCE. If you wish to take an export of any of the V500 tables, ",
      "exports should be taken at this time."), row + 1, col 0,
     dptb_str, row + 1, dptb_str = concat(
      "If using the Alternate Database Restore method, all tables, regardless of owner, currently on ",
      "TARGET will be dropped prior to"),
     row + 1, col 0, dptb_str,
     dptb_str = concat(
      "restore from SOURCE. If you wish to take an export of any [database users/tables] in TARGET, ",
      "exports should be taken at this"), row + 1, col 0,
     dptb_str, row + 1, col 0,
     "time.", row + 1
     IF ((dptb_db_users->cnt > 0))
      IF (validate(drrr_responsefile_in_use,- (1))=1)
       row + 1, col 0, "DATABASE USERS [*denotes user marked to be retained]:",
       row + 1
      ELSE
       row + 1, col 0, "DATABASE USERS:",
       row + 1
      ENDIF
     ENDIF
     FOR (dptb_locndx = 1 TO dptb_db_users->cnt)
       IF (validate(drrr_responsefile_in_use,- (1))=1
        AND (drrr_misc_data->tgt_retain_db_user_cnt > 0))
        IF (locateval(dptd_user_exists,1,drrr_misc_data->tgt_retain_db_user_cnt,dptb_db_users->qual[
         dptb_locndx].db_user_name,drrr_misc_data->tgt_retain_db_users[dptd_user_exists].user_name)
         > 0)
         dptb_str = concat(dptb_db_users->qual[dptb_locndx].db_user_name,"*"), row + 1, col 0,
         dptb_str
        ELSE
         row + 1, col 0, dptb_db_users->qual[dptb_locndx].db_user_name
        ENDIF
       ELSE
        row + 1, col 0, dptb_db_users->qual[dptb_locndx].db_user_name
       ENDIF
     ENDFOR
    WITH nocounter, nullreport, maxcol = 132,
     format = variable, formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    SET dm_err->eproc = concat("Skipping display of Backup Warning Prompt.")
    CALL disp_msg("",dm_err->logfile,0)
    IF ((drer_email_list->email_cnt > 0))
     SET drer_email_det->msgtype = "ACTIONREQ"
     SET drer_email_det->status = "REPORT"
     SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
     SET drer_email_det->step = "TARGET DATABASE BACKUP WARNING REPORT"
     SET drer_email_det->email_level = 1
     SET drer_email_det->logfile = dm_err->logfile
     SET drer_email_det->err_ind = dm_err->err_ind
     SET drer_email_det->eproc = dm_err->eproc
     SET drer_email_det->emsg = dm_err->emsg
     SET drer_email_det->user_action = dm_err->user_action
     SET drer_email_det->attachment = dptb_rpt_file
     CALL drer_add_body_text(concat("Target Database Backup Report was generated at ",format(
        drer_email_det->status_dt_tm,";;q")),1)
     CALL drer_add_body_text(concat(
       "User Action : Please review the Target Database Backup Report and ",
       "take any necessary exports at this time."),0)
     CALL drer_add_body_text(concat("Report file name : ",trim(dptb_rpt_file,3)),0)
     IF (drer_compose_email(null)=1)
      CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
       email_level)
     ENDIF
     CALL drer_reset_pre_err(null)
    ENDIF
   ELSE
    SET dm_err->eproc = "Prompt user to take backups of any Target tables that will be dropped."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    FREE DEFINE rtl2
    DEFINE rtl2 "dptb_rpt_file_logical"
    SELECT INTO mine
     t.line
     FROM rtl2t t
     DETAIL
      col 0, t.line, row + 1
     WITH nocounter, maxcol = 2001
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Prompt for target database backup report confirmation."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,8,100)
    CALL text(3,2,"TARGET DATABASE BACKUP REPORT CONFIRMATION PROMPT")
    CALL text(5,2,"Press 'C' to continue data collection process or 'Q' to quit:")
    CALL accept(5,64,"A;cu"," "
     WHERE curaccept IN ("C", "Q"))
    SET message = nowindow
    CALL clear(1,1)
    IF (curaccept="Q")
     SET dm_err->emsg = "User choose to quit from target database backup report confirmation prompt."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_lnx_findfile(dlf_file_path)
   DECLARE dlf_cmd_txt = vc WITH protect, noconstant(" ")
   SET dlf_cmd_txt = concat("ls ",dlf_file_path,";echo $?")
   CALL dm2_push_dcl(dlf_cmd_txt)
   SET dm_err->err_ind = 0
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (cnvtint(dm_err->errtext)=0)
    IF ((dm_err->debug_flag > 1))
     SET dm_err->eproc = concat("File ",dlf_file_path," found.")
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSE
    IF ((dm_err->debug_flag > 1))
     SET dm_err->eproc = concat("File ",dlf_file_path," not found.")
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_validate_preserve_pwds(null)
   SET dm_err->eproc = "Retrieve count of preserved passwords from admin dm_info"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET ddr_domain_data->tgt_preserve_pwds_cnt = 0
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain="DM2_REPLICATE_USER_PWDS_CNT"
     AND d.info_name=cnvtupper(trim(currdbname))
    DETAIL
     ddr_domain_data->tgt_preserve_pwds_cnt = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET ddr_domain_data->tgt_preserve_pwds_cnt = - (1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_opsexec_servers(dgos_src_ind,dgos_tgt_ind,dgos_set_protect_ind)
   SET dm_err->eproc = "Retrieve OpsExec server list"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgos_file_name = vc WITH protect, noconstant("")
   DECLARE dgos_cmd = vc WITH protect, noconstant("")
   DECLARE dgos_path = vc WITH protect, noconstant("")
   DECLARE dgos_domain_name = vc WITH protect, noconstant("")
   DECLARE dgos_user = vc WITH protect, noconstant("")
   DECLARE dgos_pw = vc WITH protect, noconstant("")
   DECLARE dgos_str = vc WITH protect, noconstant("")
   DECLARE dgos_ret = vc WITH protect, noconstant("")
   DECLARE dgos_idx = i4 WITH protect, noconstant(0)
   DECLARE dgos_srv_nbr = vc WITH protect, noconstant("")
   DECLARE dgos_srv_desc = vc WITH protect, noconstant("")
   IF (dgos_src_ind=1)
    SET dgos_domain_name = ddr_domain_data->src_domain_name
    SET dgos_user = ddr_domain_data->src_mng
    SET dgos_pw = ddr_domain_data->src_mng_pwd
    SET dgos_path = ddr_domain_data->src_tmp_full_dir
   ELSE
    SET dgos_path = ddr_domain_data->tgt_tmp_full_dir
    SET dgos_domain_name = ddr_domain_data->tgt_domain_name
    SET dgos_user = ddr_domain_data->tgt_mng
    SET dgos_pw = ddr_domain_data->tgt_mng_pwd
   ENDIF
   SET dgos_file_name = concat(dgos_path,"get_opsexec_servers",evaluate(dm2_sys_misc->cur_os,"AXP",
     ".com",".ksh"))
   IF (dm2_findfile(dgos_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgos_cmd = concat("del ",dgos_file_name,";*")
    ELSE
     SET dgos_cmd = concat("rm ",dgos_file_name)
    ENDIF
    IF (dm2_push_dcl(dgos_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to find OpsExec servers: ",dgos_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dgos_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print("$!get_opsexec_servers.com"), row + 1,
      CALL print("$!"),
      row + 1,
      CALL print('$tgt_node=f$getsyi("nodename")'), row + 1,
      dgos_cmd = concat('$if f$search("',dgos_path,'opsexec_servers.dat") .nes. "" then delete ',
       dgos_path,"opsexec_servers.dat;*"),
      CALL print(dgos_cmd), row + 1,
      CALL print(concat("$define/user_mode sys$output ",dgos_path,"opsexec_servers.dat")), row + 1,
      CALL print("$mcr cer_exe:scpview 'tgt_node'"),
      row + 1,
      CALL print("$DECK"), row + 1,
      CALL print(dgos_user), row + 1,
      CALL print(dgos_domain_name),
      row + 1,
      CALL print(dgos_pw), row + 1,
      CALL print(concat("find -descrip OpsExec*")), row + 1,
      CALL print("exit"),
      row + 1,
      CALL print("$EOD"), row + 1,
      CALL print("$exit 1"), row + 1
     ELSE
      CALL print("#!/bin/ksh"), row + 1,
      CALL print("#"),
      row + 1,
      CALL print("tgt_node=`hostname`"), row + 1,
      CALL print(concat("system_pwd='",dgos_pw,"'")), row + 1,
      CALL print(concat("$cer_exe/scpview $tgt_node <<!>",dgos_path,"opsexec_servers.dat")),
      row + 1,
      CALL print(dgos_user), row + 1,
      CALL print(dgos_domain_name), row + 1,
      CALL print("$system_pwd"),
      row + 1,
      CALL print("find -descrip OpsExec*"), row + 1,
      CALL print("exit"), row + 1,
      CALL print("!"),
      row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echo("Failed to create ksh.")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute file: ",dgos_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgos_cmd = concat("@",dgos_file_name)
   ELSE
    SET dgos_cmd = concat("chmod 777 ",dgos_file_name)
    IF (dm2_push_dcl(dgos_cmd)=0)
     RETURN(0)
    ENDIF
    SET dgos_cmd = concat(". ",dgos_file_name)
   ENDIF
   IF (dm2_push_dcl(dgos_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   SET dgos_file_name = concat(dgos_path,"opsexec_servers.dat")
   IF (dm2_findfile(dgos_file_name)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Find file ",dgos_file_name)
     SET dm_err->emsg = concat("Failed to find ",dgos_file_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Parse out server id and description for Ops Exec Servers"
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dgos_file_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     id_pos = 0, desc_pos = 0, ddr_opsexec_servers->cnt = 0,
     stat = alterlist(ddr_opsexec_servers->servers,ddr_opsexec_servers->cnt)
    DETAIL
     pos = 0, dgos_srv_nbr = "DM2NOTSET", dgos_srv_desc = "DM2NOTSET"
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("LINE = ",r.line))
     ENDIF
     IF (findstring("No matching entries found",r.line,1,0)=0)
      IF (substring(1,2,r.line)="id")
       id_pos = 1, desc_pos = findstring("description",r.line,1,0)
      ELSE
       IF (id_pos > 0
        AND desc_pos > 0)
        pos = findstring(" ",r.line,1,0),
        CALL echo(build("POS = ",pos))
        IF (pos > 0
         AND  NOT (pos >= textlen(trim(r.line))))
         dgos_srv_nbr = substring(1,(pos - 1),r.line), dgos_srv_desc = substring(desc_pos,((textlen(r
           .line) - desc_pos)+ 1),r.line)
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("SRV_NBR=",dgos_srv_nbr)),
          CALL echo(build("SRV_DESC=",dgos_srv_desc))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF (dgos_srv_nbr != "DM2NOTSET"
      AND dgos_srv_desc != "DM2NOTSET")
      ddr_opsexec_servers->cnt = (ddr_opsexec_servers->cnt+ 1)
      IF (mod(ddr_opsexec_servers->cnt,50)=1)
       stat = alterlist(ddr_opsexec_servers->servers,(ddr_opsexec_servers->cnt+ 49))
      ENDIF
      ddr_opsexec_servers->servers[ddr_opsexec_servers->cnt].server_name = dgos_srv_desc,
      ddr_opsexec_servers->servers[ddr_opsexec_servers->cnt].server_nbr = cnvtint(dgos_srv_nbr)
     ENDIF
    FOOT REPORT
     stat = alterlist(ddr_opsexec_servers->servers,ddr_opsexec_servers->cnt)
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_opsexec_servers)
   ENDIF
   IF ((ddr_opsexec_servers->cnt=0))
    SET dm_err->eproc = "No OpsExec servers were found in SCP"
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    FOR (dgos_idx = 1 TO ddr_opsexec_servers->cnt)
      IF ((dm2_sys_misc->cur_os="AXP"))
       SET dgos_str = concat("\node\",build(curnode),"\domain\",dgos_domain_name,"\servers\",
        build(ddr_opsexec_servers->servers[dgos_idx].server_nbr)," Protect")
      ELSE
       SET dgos_str = concat("\\node\\",build(curnode),"\\domain\\",dgos_domain_name,"\\servers\\",
        build(ddr_opsexec_servers->servers[dgos_idx].server_nbr)," Protect")
      ENDIF
      IF (ddr_lreg_oper("GET",dgos_str,dgos_ret)=0)
       RETURN(0)
      ENDIF
      IF (dgos_ret != "N")
       SET dm_err->emsg = build("The following OpsExec server is protected:",ddr_opsexec_servers->
        servers[dgos_idx].server_name,"(",ddr_opsexec_servers->servers[dgos_idx].server_nbr,")")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_validate_opsexec_hosts(null)
   DECLARE dvoh_idx = i4 WITH protect, noconstant(0)
   DECLARE dvoh_idx2 = i4 WITH protect, noconstant(0)
   DECLARE dvoh_idx3 = i4 WITH protect, noconstant(0)
   DECLARE dvoh_str1 = vc WITH protect, noconstant("")
   DECLARE dvoh_str2 = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Retrieve current OpsExec host list"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    hn = parser(concat("o.",ddr_ops_info->col_host))
    FROM (value(ddr_ops_info->tbl_name) o)
    WHERE o.active_ind=1
    ORDER BY parser(concat("o.",ddr_ops_info->col_host))
    HEAD REPORT
     ddr_opsexec_nodes->src_node_cnt = 0, stat = alterlist(ddr_opsexec_nodes->src_nodes,
      ddr_opsexec_nodes->src_node_cnt)
    DETAIL
     IF (hn > " "
      AND hn != "SCOUT")
      ddr_opsexec_nodes->src_node_cnt = (ddr_opsexec_nodes->src_node_cnt+ 1), stat = alterlist(
       ddr_opsexec_nodes->src_nodes,ddr_opsexec_nodes->src_node_cnt), ddr_opsexec_nodes->src_nodes[
      ddr_opsexec_nodes->src_node_cnt].node_name = cnvtupper(hn),
      ddr_opsexec_nodes->src_nodes[ddr_opsexec_nodes->src_node_cnt].tgt_map_node = "DM2NOTSET"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((curqual=0) OR ((ddr_opsexec_nodes->src_node_cnt=0))) )
    SET dm_err->eproc = "No active hosts found in Operations control group table"
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_opsexec_nodes)
   ENDIF
   FOR (dvoh_idx = 1 TO ddr_opsexec_nodes->src_node_cnt)
    SET dvoh_str1 = cnvtlower(ddr_opsexec_nodes->src_nodes[dvoh_idx].node_name)
    IF (locateval(dvoh_idx2,1,ddr_domain_data->tgt_nodes_cnt,dvoh_str1,ddr_domain_data->tgt_nodes[
     dvoh_idx2].node_name)=0)
     IF (locateval(dvoh_idx3,1,ddr_domain_data->src_nodes_cnt,dvoh_str1,ddr_domain_data->src_nodes[
      dvoh_idx3].node_name) > 0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verifying existence of OpsExec Hosts in Target Node list"
      SET dm_err->emsg = concat("Host ",ddr_opsexec_nodes->src_nodes[dvoh_idx].node_name,
       " does not exist in Target Node List from SCP")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_validate_mapping(dvm_mapping_applied,dvm_invalid_ind)
   DECLARE dvm_idx = i4 WITH protect, noconstant(0)
   DECLARE dvm_idx2 = i4 WITH protect, noconstant(0)
   DECLARE dvm_pos = i4 WITH protect, noconstant(0)
   DECLARE dvm_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Validating Ops Exec node mappings")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_OPSEXEC_NODE_MAPPING"
     AND di.info_char=concat(cnvtupper(ddr_domain_data->src_domain_name),"::",cnvtupper(
      ddr_domain_data->tgt_domain_name))
    HEAD REPORT
     ddr_opsexec_nodes->src_node_cnt = 0, stat = alterlist(ddr_opsexec_nodes->src_nodes,
      ddr_opsexec_nodes->src_node_cnt)
    DETAIL
     ddr_opsexec_nodes->src_node_cnt = (ddr_opsexec_nodes->src_node_cnt+ 1), stat = alterlist(
      ddr_opsexec_nodes->src_nodes,ddr_opsexec_nodes->src_node_cnt), dvm_pos = findstring("::",di
      .info_name,0,1)
     IF (dvm_pos > 0)
      ddr_opsexec_nodes->src_nodes[ddr_opsexec_nodes->src_node_cnt].node_name = substring(1,(dvm_pos
        - 1),di.info_name), ddr_opsexec_nodes->src_nodes[ddr_opsexec_nodes->src_node_cnt].
      tgt_map_node = substring((dvm_pos+ 2),((textlen(di.info_name) - dvm_pos) - 1),di.info_name)
     ENDIF
     IF ((di.info_number=- (1)))
      ddr_opsexec_nodes->src_nodes[ddr_opsexec_nodes->src_node_cnt].ignore_ind = 1
     ELSEIF (di.info_number=1)
      dvm_mapping_applied = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((ddr_opsexec_nodes->src_node_cnt=0))
    SET dm_err->eproc = "No OpsExec Mapping was found"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dvm_invalid_ind = 1
    RETURN(1)
   ENDIF
   IF (dvm_mapping_applied=1)
    SET dm_err->eproc = "OpsExec Mapping has already been applied"
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    hn = parser(concat("o.",ddr_ops_info->col_host))
    FROM (value(ddr_ops_info->tbl_name) o)
    ORDER BY parser(concat("o.",ddr_ops_info->col_host))
    DETAIL
     IF (hn > " "
      AND hn != "SCOUT")
      dvm_str = cnvtlower(trim(hn))
      IF (locateval(dvm_idx,1,ddr_domain_data->src_nodes_cnt,dvm_str,ddr_domain_data->src_nodes[
       dvm_idx].node_name) > 0)
       IF (locateval(dvm_idx2,1,ddr_opsexec_nodes->src_node_cnt,trim(hn),ddr_opsexec_nodes->
        src_nodes[dvm_idx2].node_name)=0)
        dvm_invalid_ind = 1
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dvm_invalid_ind=1)
    SET dm_err->eproc = concat(
     "All OpsExec Hosts from ops_control_group are not accounted for in the existing mapping")
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   FOR (dvm_idx = 1 TO ddr_opsexec_nodes->src_node_cnt)
     IF ((ddr_opsexec_nodes->src_nodes[dvm_idx].ignore_ind=0))
      SET dvm_str = cnvtlower(ddr_opsexec_nodes->src_nodes[dvm_idx].tgt_map_node)
      IF (locateval(dvm_idx2,1,ddr_domain_data->tgt_nodes_cnt,dvm_str,ddr_domain_data->tgt_nodes[
       dvm_idx2].node_name)=0)
       SET dm_err->eproc = concat("Host ",ddr_opsexec_nodes->src_nodes[dvm_idx].tgt_map_node,
        " does not exist in Target Node List from SCP")
       CALL disp_msg("",dm_err->logfile,0)
       SET dvm_invalid_ind = 1
       RETURN(1)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_opsexec_node_map(null)
   DECLARE dgonm_idx = i4 WITH protect, noconstant(0)
   DECLARE dgonm_idx2 = i4 WITH protect, noconstant(0)
   DECLARE dgonm_idx3 = i4 WITH protect, noconstant(0)
   DECLARE dgonm_loc = i4 WITH protect, noconstant(0)
   DECLARE dgonm_row = i4 WITH protect, noconstant(0)
   DECLARE dgonm_invalid = i2 WITH protect, noconstant(0)
   DECLARE dgonm_continue = i2 WITH protect, noconstant(1)
   DECLARE dgonm_get_mapping = i2 WITH protect, noconstant(0)
   DECLARE dgonm_mapping_applied = i2 WITH protect, noconstant(0)
   DECLARE dgonm_write_to_dm_info = i2 WITH protect, noconstant(0)
   DECLARE dgonm_str = vc WITH protect, noconstant("")
   IF (ddr_validate_mapping(dgonm_mapping_applied,dgonm_get_mapping)=0)
    RETURN(0)
   ENDIF
   IF (dgonm_mapping_applied=1)
    RETURN(1)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dgonm_get_mapping = 1
   ELSE
    IF (dgonm_get_mapping=0)
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL box(1,1,24,132)
     CALL text(2,2,"OPS EXEC SERVERS MAINTAINENCE [SOURCE->TARGET NODE MAPPING]")
     CALL text(5,2,"A valid mapping was found between source and target nodes. ")
     CALL text(7,2,"Press C to Continue the process using the existing mapping OR ")
     CALL text(8,2,"Press M to Modify the mapping before proceeding.")
     CALL text(12,2,"Your Choice [C/M]:")
     CALL accept(12,23,"A;cu","C"
      WHERE curaccept IN ("C", "M"))
     IF (curaccept="M")
      SET dgonm_get_mapping = 1
     ELSE
      SET dgonm_get_mapping = 0
     ENDIF
     SET message = nowindow
    ENDIF
   ENDIF
   IF (dgonm_get_mapping=1)
    SET dm_err->eproc = "Retrieve current OpsExec host list"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     hn = parser(concat("o.",ddr_ops_info->col_host))
     FROM (value(ddr_ops_info->tbl_name) o)
     ORDER BY parser(concat("o.",ddr_ops_info->col_host))
     HEAD REPORT
      ddr_opsexec_nodes->src_node_cnt = 0, stat = alterlist(ddr_opsexec_nodes->src_nodes,
       ddr_opsexec_nodes->src_node_cnt)
     DETAIL
      IF (hn > " "
       AND hn != "SCOUT")
       dgonm_str = cnvtupper(trim(hn))
       IF (locateval(dgonm_idx3,1,ddr_opsexec_nodes->src_node_cnt,cnvtupper(hn),ddr_opsexec_nodes->
        src_nodes[dgonm_idx3].node_name)=0)
        ddr_opsexec_nodes->src_node_cnt = (ddr_opsexec_nodes->src_node_cnt+ 1), stat = alterlist(
         ddr_opsexec_nodes->src_nodes,ddr_opsexec_nodes->src_node_cnt), ddr_opsexec_nodes->src_nodes[
        ddr_opsexec_nodes->src_node_cnt].node_name = dgonm_str,
        ddr_opsexec_nodes->src_nodes[ddr_opsexec_nodes->src_node_cnt].tgt_map_node = "DM2NOTSET",
        dgonm_str = cnvtlower(trim(hn))
        IF (locateval(dgonm_idx,1,ddr_domain_data->src_nodes_cnt,dgonm_str,ddr_domain_data->
         src_nodes[dgonm_idx].node_name) > 0)
         ddr_opsexec_nodes->src_nodes[ddr_opsexec_nodes->src_node_cnt].ignore_ind = 0
        ELSE
         ddr_opsexec_nodes->src_nodes[ddr_opsexec_nodes->src_node_cnt].ignore_ind = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((curqual=0) OR ((ddr_opsexec_nodes->src_node_cnt=0))) )
     SET dm_err->eproc = "No active hosts found in Operations control group table"
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(ddr_opsexec_nodes)
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=1)
     FOR (dgonm_idx = 1 TO ddr_opsexec_nodes->src_node_cnt)
       IF ((ddr_opsexec_nodes->src_nodes[dgonm_idx].ignore_ind=0))
        SET dgonm_loc = locateval(dgonm_idx2,1,drrr_misc_data->tgt_opsexec_map_cnt,ddr_opsexec_nodes
         ->src_nodes[dgonm_idx].node_name,drrr_misc_data->tgt_opsexec_map[dgonm_idx2].src_node)
        IF (dgonm_loc=0)
         SET dm_err->eproc = concat("Verifying all hosts are accounted for in ",
          "OpsExec Mapping specified in response file.")
         SET dm_err->emsg = concat("Source Host, ",ddr_opsexec_nodes->src_nodes[dgonm_idx].node_name,
          " does not have a corresponding target mapped node in resposne file")
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ELSE
         SET ddr_opsexec_nodes->src_nodes[dgonm_idx].tgt_map_node = cnvtupper(drrr_misc_data->
          tgt_opsexec_map[dgonm_loc].tgt_node)
        ENDIF
       ENDIF
     ENDFOR
     SET dgonm_write_to_dm_info = 1
    ELSE
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL box(1,1,24,132)
     CALL text(2,2,"OPS EXEC SERVERS MAINTAINENCE [SOURCE->TARGET NODE MAPPING]")
     CALL text(5,2,concat("For each source node listed as an Ops Exec Host, ",
       "select a valid target app node to map the corresponding Ops Exec servers"))
     SET help = pos(10,80,10,35)
     SET help =
     SELECT INTO "nl:"
      target_node = substring(1,30,cnvtupper(ddr_domain_data->tgt_nodes[t.seq].node_name))
      FROM (dummyt t  WITH seq = value(ddr_domain_data->tgt_nodes_cnt))
      WITH nocounter
     ;end select
     CALL text(10,2,concat("SOURCE NODE",fillstring(30," "),"TARGET NODE TO MAP"))
     CALL text(11,2,fillstring(75,"-"))
     SET dgonm_row = 12
     FOR (dgonm_idx = 1 TO ddr_opsexec_nodes->src_node_cnt)
       IF ((ddr_opsexec_nodes->src_nodes[dgonm_idx].ignore_ind=0))
        CALL text(dgonm_row,2,ddr_opsexec_nodes->src_nodes[dgonm_idx].node_name)
        SET dgonm_continue = 1
        WHILE (dgonm_continue=1)
          CALL accept(dgonm_row,40,"P(30);CUF",ddr_opsexec_nodes->src_nodes[dgonm_idx].tgt_map_node
           WHERE curaccept > " ")
          SET ddr_opsexec_nodes->src_nodes[dgonm_idx].tgt_map_node = curaccept
          SET dgonm_str = cnvtlower(ddr_opsexec_nodes->src_nodes[dgonm_idx].tgt_map_node)
          IF (locateval(dgonm_idx2,1,ddr_domain_data->tgt_nodes_cnt,dgonm_str,ddr_domain_data->
           tgt_nodes[dgonm_idx2].node_name)=0)
           CALL text(8,2,
            "**The value entered is not a valid Target Node. Please choose a node from the help list"
            )
          ELSE
           CALL clear(8,2,100)
           SET dgonm_continue = 0
          ENDIF
        ENDWHILE
        SET dgonm_row = (dgonm_row+ 1)
       ENDIF
     ENDFOR
     SET help = off
     CALL text(22,2,"Continue/Exit [C/E]:")
     CALL accept(22,23,"A;cu","C"
      WHERE curaccept IN ("C", "E"))
     CALL clear(1,1)
     SET message = nowindow
     IF (curaccept="E")
      SET dm_err->emsg = "User elected to quit from Ops Exec servers node mapping menu."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET dgonm_write_to_dm_info = 1
     ENDIF
    ENDIF
    IF (dgonm_write_to_dm_info=1)
     SET dm_err->eproc = concat("Deleting Ops Exec node mappings from dm_info")
     CALL disp_msg("",dm_err->logfile,0)
     DELETE  FROM dm_info di
      WHERE di.info_domain="DM2_OPSEXEC_NODE_MAPPING"
       AND di.info_char=concat(cnvtupper(ddr_domain_data->src_domain_name),"::",cnvtupper(
        ddr_domain_data->tgt_domain_name))
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Inserting Ops Exec node mappings into dm_info")
     CALL disp_msg("",dm_err->logfile,0)
     INSERT  FROM dm_info di,
       (dummyt d  WITH seq = value(ddr_opsexec_nodes->src_node_cnt))
      SET di.info_domain = "DM2_OPSEXEC_NODE_MAPPING", di.info_char = concat(cnvtupper(
         ddr_domain_data->src_domain_name),"::",cnvtupper(ddr_domain_data->tgt_domain_name)), di
       .info_name = concat(ddr_opsexec_nodes->src_nodes[d.seq].node_name,"::",ddr_opsexec_nodes->
        src_nodes[d.seq].tgt_map_node),
       di.info_number = evaluate(ddr_opsexec_nodes->src_nodes[d.seq].ignore_ind,0,0,1,- (1)), di
       .info_date = cnvtdatetime(curdate,curtime3)
      PLAN (d
       WHERE d.seq > 0)
       JOIN (di)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_opsexec_nodes)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_update_opsexec_mapping(null)
   DECLARE duom_idx = i4 WITH protect, noconstant(0)
   DECLARE duom_active_cv = f8 WITH protect, noconstant(0.0)
   DECLARE duom_inactive_cv = f8 WITH protect, noconstant(0.0)
   DECLARE duom_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Get code value for active and inactive indicators")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=48
     AND c.cdf_meaning IN ("ACTIVE", "INACTIVE")
    DETAIL
     IF (c.cdf_meaning="ACTIVE")
      duom_active_cv = c.code_value
     ELSEIF (c.cdf_meaning="INACTIVE")
      duom_inactive_cv = c.code_value
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Retrieving OCG Ids for each valid host from ops_control_groups")
   CALL disp_msg("",dm_err->logfile,0)
   FOR (duom_idx = 1 TO ddr_opsexec_nodes->src_node_cnt)
     IF ((ddr_opsexec_nodes->src_nodes[duom_idx].ignore_ind=0))
      SET dm_err->eproc = "Getting list from Operations control group table for each host"
      SELECT INTO "nl:"
       FROM (value(ddr_ops_info->tbl_name) o)
       WHERE (cnvtupper(parser(concat("o.",ddr_ops_info->col_host)))=ddr_opsexec_nodes->src_nodes[
       duom_idx].node_name)
       HEAD REPORT
        ddr_opsexec_nodes->src_nodes[duom_idx].ocg_cnt = 0, stat = alterlist(ddr_opsexec_nodes->
         src_nodes[duom_idx].ocg_list,ddr_opsexec_nodes->src_nodes[duom_idx].ocg_cnt)
       DETAIL
        ddr_opsexec_nodes->src_nodes[duom_idx].ocg_cnt = (ddr_opsexec_nodes->src_nodes[duom_idx].
        ocg_cnt+ 1), duom_cnt = ddr_opsexec_nodes->src_nodes[duom_idx].ocg_cnt
        IF (mod(duom_cnt,10)=1)
         stat = alterlist(ddr_opsexec_nodes->src_nodes[duom_idx].ocg_list,(duom_cnt+ 9))
        ENDIF
        ddr_opsexec_nodes->src_nodes[duom_idx].ocg_list[duom_cnt].ocg_id = parser(concat("o.",
          ddr_ops_info->col_group_id))
       FOOT REPORT
        stat = alterlist(ddr_opsexec_nodes->src_nodes[duom_idx].ocg_list,ddr_opsexec_nodes->
         src_nodes[duom_idx].ocg_cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   SET dm_err->eproc = concat("Updating Ops Exec node mappings into ops_control_groups")
   CALL disp_msg("",dm_err->logfile,0)
   FOR (duom_idx = 1 TO ddr_opsexec_nodes->src_node_cnt)
     IF ((ddr_opsexec_nodes->src_nodes[duom_idx].ignore_ind=0))
      IF ((ddr_opsexec_nodes->src_nodes[duom_idx].ocg_cnt > 0))
       SET dm_err->eproc = concat("Updating ",ddr_ops_info->tbl_name," with target mapped nodes for ",
        ddr_opsexec_nodes->src_nodes[duom_idx].node_name)
       UPDATE  FROM (value(ddr_ops_info->tbl_name) o),
         (dummyt d  WITH seq = value(ddr_opsexec_nodes->src_nodes[duom_idx].ocg_cnt))
        SET parser(concat("o.",ddr_ops_info->col_host)) = ddr_opsexec_nodes->src_nodes[duom_idx].
         tgt_map_node, parser(concat("o.",ddr_ops_info->col_server_nbr)) = 0
        PLAN (d
         WHERE d.seq > 0)
         JOIN (o
         WHERE (parser(concat("o.",ddr_ops_info->col_group_id))=ddr_opsexec_nodes->src_nodes[duom_idx
         ].ocg_list[d.seq].ocg_id))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   UPDATE  FROM dm_info di
    SET di.info_number = 1
    WHERE di.info_domain="DM2_OPSEXEC_NODE_MAPPING"
     AND di.info_char=concat(cnvtupper(ddr_domain_data->src_domain_name),"::",cnvtupper(
      ddr_domain_data->tgt_domain_name))
     AND di.info_number=0
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_cleanup_opsexec_mapping(null)
   DECLARE duom_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Deleting Ops Exec node mappings from dm_info")
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_OPSEXEC_NODE_MAPPING"
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
 SUBROUTINE ddr_assign_opsexec_servers(null)
   DECLARE daos_idx = i4 WITH protect, noconstant(0)
   DECLARE daos_idx2 = i4 WITH protect, noconstant(0)
   DECLARE daos_str = vc WITH protect, noconstant("")
   DECLARE daos_ret = vc WITH protect, noconstant("")
   DECLARE daos_cur_assigned_idx = i4 WITH protect, noconstant(0)
   DECLARE daos_file_name = vc WITH protect, noconstant("")
   DECLARE daos_cmd = vc WITH protect, noconstant("")
   DECLARE daos_path = vc WITH protect, noconstant("")
   DECLARE daos_srv_file = vc WITH protect, noconstant("")
   DECLARE daos_srv_param = vc WITH protect, noconstant("")
   DECLARE daos_dyn_where = vc WITH protect, noconstant("")
   SET dm_err->eproc =
   "Retrieve OpsExec servers from Operations control group table for current node"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((ddr_domain_data->src_ops_ver > 1.0))
    SET daos_dyn_where = concat(
     ' cnvtupper(parser(concat("o.", ddr_ops_info->col_host))) = cnvtupper(trim(curnode))',
     " and o.beg_effective_dt_tm <= cnvtdatetime (curdate, curtime3)",
     " and o.end_effective_dt_tm > cnvtdatetime (curdate, curtime3)")
   ELSE
    SET daos_dyn_where =
    ' cnvtupper(parser(concat("o.", ddr_ops_info->col_host))) = cnvtupper(trim(curnode))'
   ENDIF
   SELECT INTO "nl:"
    FROM (value(ddr_ops_info->tbl_name) o)
    WHERE o.active_ind=1
     AND parser(daos_dyn_where)
    HEAD REPORT
     ddr_opsexec_cgs->cnt = 0, stat = alterlist(ddr_opsexec_cgs->cgs,ddr_opsexec_cgs->cnt)
    DETAIL
     ddr_opsexec_cgs->cnt = (ddr_opsexec_cgs->cnt+ 1)
     IF (mod(ddr_opsexec_cgs->cnt,50)=1)
      stat = alterlist(ddr_opsexec_cgs->cgs,(ddr_opsexec_cgs->cnt+ 49))
     ENDIF
     ddr_opsexec_cgs->cgs[ddr_opsexec_cgs->cnt].ocg_id = parser(concat("o.",ddr_ops_info->
       col_group_id)), ddr_opsexec_cgs->cgs[ddr_opsexec_cgs->cnt].cg_name = parser(concat("o.",
       ddr_ops_info->col_group_name))
    FOOT REPORT
     stat = alterlist(ddr_opsexec_cgs->cgs,ddr_opsexec_cgs->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((curqual=0) OR ((ddr_opsexec_cgs->cnt=0))) )
    SET dm_err->eproc =
    "No OpsExec Control Groups were found in Operations control group table for current node"
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (ddr_get_lreg_servers(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_domain_name)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Assigning OpsExec server numbers in the range 660-699"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET daos_idx2 = 660
   WHILE (daos_idx2 < 700
    AND (daos_cur_assigned_idx < ddr_opsexec_cgs->cnt))
    IF (locateval(daos_idx,1,ddr_lreg_servers->cnt,daos_idx2,ddr_lreg_servers->qual[daos_idx].srv_nbr
     )=0)
     SET daos_cur_assigned_idx = (daos_cur_assigned_idx+ 1)
     SET ddr_opsexec_cgs->cgs[daos_cur_assigned_idx].server_nbr = daos_idx2
    ENDIF
    SET daos_idx2 = (daos_idx2+ 1)
   ENDWHILE
   SET dm_err->eproc = "Assigning OpsExec server numbers in the range 3285-3544"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET daos_idx2 = 3285
   WHILE (daos_idx2 < 3545
    AND (daos_cur_assigned_idx < ddr_opsexec_cgs->cnt))
    IF (locateval(daos_idx,1,ddr_lreg_servers->cnt,daos_idx2,ddr_lreg_servers->qual[daos_idx].srv_nbr
     )=0)
     SET daos_cur_assigned_idx = (daos_cur_assigned_idx+ 1)
     SET ddr_opsexec_cgs->cgs[daos_cur_assigned_idx].server_nbr = daos_idx2
    ENDIF
    SET daos_idx2 = (daos_idx2+ 1)
   ENDWHILE
   IF ((daos_cur_assigned_idx < ddr_opsexec_cgs->cnt))
    IF ((validate(dm2_skip_unassigned_opsexec_servers,- (1))=- (1)))
     SET dm_err->eproc = "Assigning OpsExec server numbers"
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Unable to assign server numbers for all OpsExec cgs"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_opsexec_cgs)
   ENDIF
   SET dm_err->eproc = concat("Updating OpsExec server numbers into Operations control group table")
   CALL disp_msg("",dm_err->logfile,0)
   UPDATE  FROM (value(ddr_ops_info->tbl_name) o),
     (dummyt d  WITH seq = value(ddr_opsexec_cgs->cnt))
    SET parser(concat("o.",ddr_ops_info->col_server_nbr)) = ddr_opsexec_cgs->cgs[d.seq].server_nbr
    PLAN (d
     WHERE d.seq > 0)
     JOIN (o
     WHERE (parser(concat("o.",ddr_ops_info->col_group_name))=ddr_opsexec_cgs->cgs[d.seq].cg_name)
      AND (parser(concat("o.",ddr_ops_info->col_group_id))=ddr_opsexec_cgs->cgs[d.seq].ocg_id))
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   SET daos_file_name = concat(ddr_domain_data->tgt_tmp_full_dir,"assign_opsexec_servers",evaluate(
     dm2_sys_misc->cur_os,"AXP",".com",".ksh"))
   IF (dm2_findfile(daos_file_name) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET daos_cmd = concat("del ",daos_file_name,";*")
    ELSE
     SET daos_cmd = concat("rm ",daos_file_name)
    ENDIF
    IF (dm2_push_dcl(daos_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to add OpsExec servers: ",daos_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((ddr_domain_data->src_ops_ver > 1.0))
    SET daos_srv_param = "ops_srvexecutor"
   ELSE
    SET daos_srv_param = "ops_srvexec"
   ENDIF
   SELECT INTO value(daos_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print(concat("$mcr cer_exe:scpview ",trim(curnode))), row + 1,
      CALL print("$DECK"),
      row + 1
     ELSE
      CALL print("tgt_node=`hostname`"), row + 1
      IF ((ddr_domain_data->process="REFRESH"))
       CALL print(concat("pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1
      ELSEIF ((ddr_domain_data->process="REPLICATE"))
       CALL print(concat("pwd='",ddr_domain_data->src_mng_pwd,"'")), row + 1
      ENDIF
      CALL print(concat("$cer_exe/scpview $tgt_node <<!")), row + 1
     ENDIF
     CALL print(ddr_domain_data->src_mng), row + 1,
     CALL print(ddr_domain_data->tgt_domain_name),
     row + 1
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF ((ddr_domain_data->process="REFRESH"))
       CALL print(ddr_domain_data->tgt_mng_pwd), row + 1
      ELSEIF ((ddr_domain_data->process="REPLICATE"))
       CALL print(ddr_domain_data->src_mng_pwd), row + 1
      ENDIF
     ELSE
      CALL print("$pwd"), row + 1
     ENDIF
     FOR (daos_idx = 1 TO ddr_opsexec_cgs->cnt)
       IF ((ddr_opsexec_cgs->cgs[daos_idx].server_nbr > 0))
        daos_cmd = concat("add ",build(ddr_opsexec_cgs->cgs[daos_idx].server_nbr),
         ' -descrip "OpsExec_',ddr_opsexec_cgs->cgs[daos_idx].cg_name,'"',
         " -path cer_exe/srv_drvr -param cer_exe/",daos_srv_param," -inst 0"," -user ",
         ddr_domain_data->src_priv,
         " -password ",ddr_domain_data->tgt_priv_pwd,' -restart y -prop cgname="',ddr_opsexec_cgs->
         cgs[daos_idx].cg_name,'"',
         ' -prop DependencyGroup=4 -prop "Rdbms User Name"=noccl'),
        CALL print(daos_cmd), row + 1
       ENDIF
     ENDFOR
     CALL print("exit"), row + 1
     IF ((dm2_sys_misc->cur_os != "AXP"))
      CALL print("!"), row + 1
     ELSE
      CALL print("$EOD"), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echo("Failed to create ksh/com file to add OpsExec servers.")
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute file: ",daos_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET daos_cmd = concat("@",daos_file_name)
   ELSE
    SET daos_cmd = concat("chmod 777 ",daos_file_name)
    IF (dm2_push_dcl(daos_cmd)=0)
     RETURN(0)
    ENDIF
    SET daos_cmd = concat(". ",daos_file_name)
   ENDIF
   IF (dm2_push_dcl(daos_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   SET dm_err->eproc = concat("Verify opsexec servers have been created")
   CALL disp_msg(" ",dm_err->logfile,0)
   FOR (daos_idx = 1 TO ddr_opsexec_cgs->cnt)
     IF ((ddr_opsexec_cgs->cgs[daos_idx].server_nbr > 0))
      IF ((dm2_sys_misc->cur_os="AXP"))
       SET daos_str = concat("\node\",trim(curnode),"\domain\",ddr_domain_data->tgt_domain_name,
        "\servers\",
        build(ddr_opsexec_cgs->cgs[daos_idx].server_nbr)," Servername")
      ELSE
       SET daos_str = concat("\\node\\",trim(curnode),"\\domain\\",ddr_domain_data->tgt_domain_name,
        "\\servers\\",
        build(ddr_opsexec_cgs->cgs[daos_idx].server_nbr)," Servername")
      ENDIF
      IF (ddr_lreg_oper("GET",daos_str,daos_ret)=0)
       RETURN(0)
      ENDIF
      IF (daos_ret != build("OpsExec_",ddr_opsexec_cgs->cgs[daos_idx].cg_name))
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Server for control group",ddr_opsexec_cgs->cgs[daos_idx].cg_name,
        "(",build(ddr_opsexec_cgs->cgs[daos_idx].server_nbr),") not created successfully")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ELSE
      SET dm_err->eproc = concat("Server was not created for the following control group: ",
       ddr_opsexec_cgs->cgs[daos_idx].cg_name)
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_nodes_dns(null)
   DECLARE dgnd_file = vc WITH protect, noconstant("")
   DECLARE dgnd_cmd = vc WITH protect, noconstant("")
   DECLARE dgnd_found_start = i2 WITH protect, noconstant(0)
   DECLARE dgnd_found_node_name = i2 WITH protect, noconstant(0)
   DECLARE dgnd_errfile = vc WITH protect, noconstant("")
   DECLARE dgnd_found_curnode = i2 WITH protect, noconstant(0)
   DECLARE dgnd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgnd_pos = i4 WITH protect, noconstant(0)
   DECLARE dgnd_str = vc WITH protect, noconstant("")
   IF (get_unique_file("get_nodes",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dgnd_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Create file to obtain listing of nodes from DNS:",dgnd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dgnd_file)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print(concat("$mcr cer_exe:testdns ",ddr_domain_data->tgt_domain_name)), row + 1
     ELSE
      CALL print(concat("$cer_exe/testdns ",ddr_domain_data->tgt_domain_name)), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain node listing from DNS."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgnd_cmd = concat("@",dgnd_file)
   ELSE
    SET dgnd_cmd = concat(". $CCLUSERDIR/",dgnd_file)
   ENDIF
   IF (dm2_push_dcl(dgnd_cmd)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (((findstring("bad command",dm_err->errtext,1,1) > 0) OR (findstring("Domain lookup failed",
    dm_err->errtext,1,1) > 0)) )
    SET dm_err->emsg = concat("Error getting target nodes from DNS:",dgnd_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgnd_errfile = dm_err->errfile
   SET dm_err->eproc = concat("Parse node listing from:",dgnd_errfile)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dgnd_data_file dgnd_errfile
   FREE DEFINE rtl
   DEFINE rtl "dgnd_data_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     IF ((dm_err->debug_flag > 0))
      CALL echo(t.line)
     ENDIF
     dgnd_cnt = (dgnd_cnt+ 1)
     IF (dgnd_found_node_name=1)
      IF (findstring(".",t.line,dgnd_pos,0) > 0)
       dgnd_str = trim(cnvtupper(substring(1,(findstring(".",t.line,dgnd_pos,0) - dgnd_pos),t.line)))
      ELSE
       dgnd_str = substring(dgnd_pos,(findstring(" ",t.line,dgnd_pos,0) - dgnd_pos),t.line)
      ENDIF
      ddr_domain_data->tgt_nodes_cnt = (ddr_domain_data->tgt_nodes_cnt+ 1), stat = alterlist(
       ddr_domain_data->tgt_nodes,ddr_domain_data->tgt_nodes_cnt), ddr_domain_data->tgt_nodes[
      ddr_domain_data->tgt_nodes_cnt].node_name = cnvtlower(trim(dgnd_str,3))
      IF (trim(cnvtlower(dgnd_str))=trim(cnvtlower(curnode)))
       dgnd_found_curnode = 1
      ENDIF
     ENDIF
     IF (dgnd_found_start=1
      AND dgnd_found_node_name=0)
      dgnd_pos = findstring("Node Name",t.line,1,0)
      IF (dgnd_pos > 0)
       dgnd_found_node_name = 1
      ENDIF
     ENDIF
     IF (findstring("DNS SRV lookup for Cerner domain",t.line,1,1) > 0)
      dgnd_found_start = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_domain_data)
   ENDIF
   IF ((ddr_domain_data->tgt_nodes_cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to obtaing listing of nodes from DNS"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgnd_found_curnode=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Current node,",trim(curnode)," not found via testdns command.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_lreg_servers(dgls_path,dgls_domain)
   DECLARE dgls_idx = i4 WITH protect, noconstant(0)
   DECLARE dgls_file_name = vc WITH protect, noconstant("")
   DECLARE dgls_cmd = vc WITH protect, noconstant("")
   DECLARE dgls_str = vc WITH protect, noconstant("")
   DECLARE dgls_srv_file = vc WITH protect, noconstant("")
   SET dgls_srv_file = concat(dgls_path,"lreg_srv_list.txt")
   IF (dm2_findfile(dgls_srv_file) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dgls_cmd = concat("del ",dgls_srv_file,";*")
    ELSE
     SET dgls_cmd = concat("rm ",dgls_srv_file)
    ENDIF
    IF (dm2_push_dcl(dgls_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Create file to store list of servers defined in registry in ",
    dgls_srv_file)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (get_unique_file("ddr_get_srv_list",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dgls_file_name = dm_err->unique_fname
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgls_str = concat("\node\",trim(curnode),"\domain\",dgls_domain,"\servers")
   ELSE
    SET dgls_str = concat("\\node\\",trim(curnode),"\\domain\\",dgls_domain,"\\servers")
   ENDIF
   SELECT INTO value(dgls_file_name)
    DETAIL
     IF ((dm2_sys_misc->cur_os="AXP"))
      CALL print(concat("$ mcr cer_exe:lreg -enumk ",dgls_str," ",dgls_srv_file)), row + 1
     ELSE
      CALL print(concat("$cer_exe/lreg -enumk ",dgls_str," ",dgls_srv_file)), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgls_cmd = concat("@",dgls_file_name)
   ELSE
    SET dgls_cmd = concat(". $CCLUSERDIR/",dgls_file_name)
   ENDIF
   IF (dm2_push_dcl(dgls_cmd)=0)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dgls_srv_file) > 0)
    SET dm_err->eproc = concat("Read ",dgls_srv_file)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET logical dgls_lreg_file dgls_srv_file
    FREE DEFINE rtl
    DEFINE rtl "dgls_lreg_file"
    SELECT INTO "nl:"
     t.line
     FROM rtlt t
     WHERE t.line > " "
     DETAIL
      IF (isnumeric(trim(t.line)))
       dgls_idx = cnvtint(trim(t.line)), ddr_lreg_servers->cnt = (ddr_lreg_servers->cnt+ 1), stat =
       alterlist(ddr_lreg_servers->qual,ddr_lreg_servers->cnt),
       ddr_lreg_servers->qual[ddr_lreg_servers->cnt].srv_nbr = dgls_idx
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     SET dm_err->eproc = "Creating file with list of servers defined in lreg"
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Unable to create file :",dgls_srv_file)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 10))
    CALL echorecord(ddr_lreg_servers)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_tdb_data(dgtd_file_name)
   DECLARE dgtd_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgtd_beg_pos = i4 WITH protect, noconstant(0)
   DECLARE dgtd_str = vc WITH protect, noconstant("")
   DECLARE dgtd_curpages = vc WITH protect, noconstant(" ")
   DECLARE dgtd_maxpages = vc WITH protect, noconstant(" ")
   DECLARE dgtd_init_size = vc WITH protect, noconstant(" ")
   DECLARE dgtd_file_temp = vc WITH protect, noconstant(" ")
   DECLARE dgtd_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgtd_file_full = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Get sizing information for TDB file name: ",build(dgtd_file_name))
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (get_unique_file("dm2_tdb_tmp",".dat")=0)
    RETURN(0)
   ELSE
    SET dgtd_file_temp = dm_err->unique_fname
   ENDIF
   SET dgtd_file_full = build(dm2_install_schema->ccluserdir,dgtd_file_temp)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(concat(evaluate(dm2_sys_misc->cur_os,"AXP","backup/ignore=interlock","cp -p")," ",
     dgtd_file_name," ",dgtd_file_full))=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_findfile(dgtd_file_full)=0)
    SET dm_err->eproc = concat("Copy TDB file (",build(dgtd_file_name),") to CCLUSERDIR (",build(
      dgtd_file_full),").")
    SET dm_err->emsg = concat("Error copying tdb file. Copy does not exist in CCLUSERDIR.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgtd_cmd = concat("mcr cer_exe:pagemgr -dump ",dgtd_file_full)
   ELSE
    SET dgtd_cmd = concat("$cer_exe/pagemgr -dump ",dgtd_file_full)
   ENDIF
   IF (dm2_push_dcl(dgtd_cmd)=0)
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
     dgtd_beg_pos = 0, dgtd_str = fillstring(132," ")
    DETAIL
     dgtd_beg_pos = 0, dgtd_str = "", dgtd_beg_pos = findstring("size:",r.line)
     IF (dgtd_beg_pos > 0)
      CALL echo("Found <curpages> line..."), dgtd_str = trim(substring((dgtd_beg_pos+ 5),textlen(trim
         (r.line)),r.line),3), dgtd_curpages = trim(substring(1,(findstring(" ",dgtd_str) - 1),
        dgtd_str))
      IF ((dm_err->debug_flag >= 1))
       CALL echo(concat("curpages = ",dgtd_curpages))
      ENDIF
     ELSE
      dgtd_beg_pos = findstring("extent:",r.line)
      IF (dgtd_beg_pos > 0)
       CALL echo("Found <maxpages> line..."), dgtd_str = trim(substring((dgtd_beg_pos+ 7),textlen(
          trim(r.line)),r.line),3), dgtd_maxpages = trim(substring(1,(findstring(" ",dgtd_str) - 1),
         dgtd_str))
       IF ((dm_err->debug_flag >= 1))
        CALL echo(concat("maxpages = ",dgtd_maxpages))
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parse out curpages/maxpages sizes from tdb file.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgtd_cmd = concat("mcr cer_exe:tdbmgr -dump ",dgtd_file_full)
   ELSE
    SET dgtd_cmd = concat("$cer_exe/tdbmgr -dump ",dgtd_file_full)
   ENDIF
   IF (dm2_push_dcl(dgtd_cmd)=0)
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
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("LINE = ",r.line))
     ENDIF
     dgtd_beg_pos = 0, dgtd_str = "", dgtd_beg_pos = findstring("size:",r.line)
     IF (dgtd_beg_pos > 0)
      CALL echo("Found <init_size> line..."), dgtd_str = trim(substring((dgtd_beg_pos+ 5),textlen(
         trim(r.line)),r.line),3), dgtd_init_size = trim(substring(1,(findstring(" ",dgtd_str) - 1),
        dgtd_str))
      IF ((dm_err->debug_flag >= 1))
       CALL echo(concat("init_size = ",dgtd_init_size))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parse out init_size from tdb file.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET ddr_domain_data->src_tdb_curpages = dgtd_curpages
   SET ddr_domain_data->src_tdb_maxpages = dgtd_maxpages
   SET ddr_domain_data->src_tdb_init_size = dgtd_init_size
   IF (cnvtint(ddr_domain_data->src_tdb_curpages) > 0
    AND cnvtint(ddr_domain_data->src_tdb_maxpages) > 0
    AND cnvtint(ddr_domain_data->src_tdb_init_size) > 0)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Curpage/maxpages/init_size information for TDB file (",build(
       dgtd_file_name),") retrieved and values greater than zero.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Verify curpage/maxpages/init_size information for TDB file (",build(
      dgtd_file_name),") is greater than zero.")
    SET dm_err->emsg = concat("TDB information not found or not valued (values retrieved:  ",build(
      ddr_domain_data->src_tdb_curpages,"/",ddr_domain_data->src_tdb_maxpages,"/",ddr_domain_data->
      src_tdb_init_size),").")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_identify_ldap_usage(dilu_env,dilu_domain,dilu_mng,dilu_mng_pwd,dilu_system,dilu_priv,
  dilu_was_ind,dilu_ldap_ind)
   DECLARE dilu_os_str = vc WITH protect, noconstant("aixrs6000")
   DECLARE dilu_echo = vc WITH protect, noconstant("echo")
   DECLARE dilu_prop = vc WITH protect, noconstant("")
   DECLARE dilu_str = vc WITH protect, noconstant("")
   DECLARE dilu_ret = vc WITH protect, noconstant("")
   DECLARE dilu_cmd = vc WITH protect, noconstant(" ")
   DECLARE dilu_begpos = i2 WITH protect, noconstant(0)
   DECLARE dilu_file_name = vc WITH protect, noconstant("")
   DECLARE dilu_defaults_fnd = i2 WITH protect, noconstant(0)
   DECLARE dilu_system_default = vc WITH protect, noconstant("")
   DECLARE dilu_ret_full = vc WITH protect, noconstant("")
   DECLARE dilu_ret_log = vc WITH protect, noconstant("")
   DECLARE dilu_output_mng = vc WITH protect, noconstant("")
   DECLARE dilu_output_system = vc WITH protect, noconstant("")
   DECLARE dilu_output_priv = vc WITH protect, noconstant("")
   DECLARE dilu_mng_value = vc WITH protect, noconstant("")
   DECLARE dilu_system_value = vc WITH protect, noconstant("")
   DECLARE dilu_priv_value = vc WITH protect, noconstant("")
   DECLARE dilu_config_value = vc WITH protect, noconstant("")
   SET dilu_ldap_ind = 0
   IF ((dm2_sys_misc->cur_os="HPX"))
    SET dilu_os_str = "hpuxia64"
   ELSEIF ((dm2_sys_misc->cur_os="LNX"))
    SET dilu_os_str = "linuxx86-64"
    SET dilu_echo = "echo -e"
   ENDIF
   SET dilu_prop = build(cnvtupper(dilu_domain),"_ExternalAuthenticationMethod")
   IF ( NOT ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))))
    SET dm_err->eproc = concat("Skipping LDAP usage check.  ",trim(dm2_sys_misc->cur_os),
     " is an unsupported operating system.")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dilu_was_ind=1)
    SET dm_err->eproc = concat("Check if LDAP enabled in database (EA_CONFIG).")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM ea_config ec
     WHERE cnvtupper(ec.realm)=cnvtupper(dilu_domain)
      AND cnvtupper(ec.config_name)="LDAP/ENABLED"
     DETAIL
      dilu_config_value = ec.config_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dilu_config_value="1")
     SET dilu_ldap_ind = 1
     SET dm_err->eproc = "LDAP is enabled."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Check for ",trim(dilu_prop)," registry property.")
    CALL disp_msg("",dm_err->logfile,0)
    SET dilu_str = concat("\\environment\\",trim(dilu_env),"\\definitions\\",dilu_os_str,
     "\\environment ",
     trim(dilu_prop))
    SET dilu_value = "LDAP_AUTH"
    IF (ddr_lreg_oper("GET",dilu_str,dilu_ret)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(dilu_ret)=dilu_value)
     SET dilu_ldap_ind = 1
     SET dm_err->eproc = "LDAP is enabled."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF (dilu_ret="NOPARMRETURNED")
     SET dm_err->eproc = concat("Check for ",trim(dilu_prop)," environment logical (via getlog).")
     CALL disp_msg("",dm_err->logfile,0)
     SET dilu_cmd = concat("$cer_exe/getlog ",dilu_prop)
     IF (dm2_push_dcl(dilu_cmd)=0)
      RETURN(0)
     ELSEIF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ELSE
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat("Parsing dm_err->errtext for: ",dilu_prop))
      ENDIF
      SET dilu_ret_full = dm_err->errtext
      SET dilu_ret_log = ""
      IF (findstring("not defined",dm_err->errtext)=0)
       SET dilu_begpos = findstring("[global]",dm_err->errtext)
       IF (dilu_begpos > 0)
        SET dilu_ret_log = substring((findstring("-->",dm_err->errtext,dilu_begpos,1)+ 4),((textlen(
          dm_err->errtext)+ 1) - (findstring("-->",dm_err->errtext,dilu_begpos,1)+ 4)),dm_err->
         errtext)
       ENDIF
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat("dm_err->errtext:[",dm_err->errtext,"]"))
       CALL echo(concat("dilu_ret_log:[",dilu_ret_log,"]"))
      ENDIF
      IF (cnvtupper(dilu_ret_log)=dilu_value)
       SET dilu_ldap_ind = 1
       SET dm_err->eproc = "LDAP is enabled."
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = "Determine LDAP system default setting."
   CALL disp_msg("",dm_err->logfile,0)
   IF (get_unique_file("dm2_ldap_default_chk",".ksh")=0)
    RETURN(0)
   ELSE
    SET dilu_file_name = dm_err->unique_fname
   ENDIF
   SET dilu_output_name = replace(dilu_file_name,".ksh",".dat")
   SET dm_err->eproc = concat("Create file to determine LDAP system default setting : ",
    dilu_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dilu_file_name)
    FROM (dummyt t  WITH seq = 1)
    DETAIL
     CALL print("#!/usr/bin/ksh"), row + 1,
     CALL print(concat("pwd='",dilu_mng_pwd,"'")),
     row + 1, dilu_cmd = concat(dilu_echo,' "',dilu_mng,"\n",dilu_domain,
      '\n$pwd\n" | authview "show -defaults" '),
     CALL print(dilu_cmd),
     row + 1, row + 1
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute ",dilu_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dilu_cmd = concat("chmod 777 ",dilu_file_name)
   IF (dm2_push_dcl(dilu_cmd)=0)
    RETURN(0)
   ENDIF
   SET dilu_cmd = concat(". ",dm2_install_schema->ccluserdir,dilu_file_name)
   IF (dm2_push_dcl(dilu_cmd)=0)
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
     IF (findstring("default password lifetime",cnvtlower(r.line),1,0) > 0)
      dilu_defaults_fnd = 1
     ENDIF
     dilu_begpos = 0, dilu_begpos = findstring("directory indicator",cnvtlower(r.line))
     IF (dilu_begpos > 0)
      dilu_system_default = trim(substring((dilu_begpos+ 19),textlen(trim(r.line)),r.line),3)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parse out directory indicator from authview output.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag >= 1))
    CALL echo(concat("defaults found indicator = ",cnvtstring(dilu_defaults_fnd)))
    CALL echo(concat("directory indicator = ",dilu_system_default))
   ENDIF
   IF (dilu_defaults_fnd=0)
    SET dm_err->eproc = "Determine LDAP system default setting."
    SET dm_err->emsg = "Unable to retrieve default policy settings from authview (show -defaults)."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (get_unique_file("dm2_get_acct_data",".ksh")=0)
    RETURN(0)
   ELSE
    SET dilu_file_name = dm_err->unique_fname
   ENDIF
   SET dilu_output_mng = build(replace(dilu_file_name,".ksh","_1.dat"))
   SET dilu_output_system = build(replace(dilu_file_name,".ksh","_2.dat"))
   SET dilu_output_priv = build(replace(dilu_file_name,".ksh","_3.dat"))
   SET dm_err->eproc = concat("Create file to determine account setting : ",dilu_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dilu_file_name)
    FROM (dummyt t  WITH seq = 1)
    DETAIL
     CALL print("#!/usr/bin/ksh"), row + 1,
     CALL print(concat("pwd='",dilu_mng_pwd,"'")),
     row + 1, dilu_cmd = concat(dilu_echo,' "',dilu_mng,"\n",dilu_domain,
      '\n$pwd\n" | authview "show ',dilu_mng," -out ",dm2_install_schema->ccluserdir,dilu_output_mng,
      '"'),
     CALL print(dilu_cmd),
     row + 1, dilu_cmd = concat(dilu_echo,' "',dilu_mng,"\n",dilu_domain,
      '\n$pwd\n" | authview "show ',dilu_system," -out ",dm2_install_schema->ccluserdir,
      dilu_output_system,
      '"'),
     CALL print(dilu_cmd),
     row + 1, dilu_cmd = concat(dilu_echo,' "',dilu_mng,"\n",dilu_domain,
      '\n$pwd\n" | authview "show ',dilu_priv," -out ",dm2_install_schema->ccluserdir,
      dilu_output_priv,
      '"'),
     CALL print(dilu_cmd),
     row + 1, row + 1
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute ",dilu_file_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dilu_cmd = concat("chmod 777 ",dilu_file_name)
   IF (dm2_push_dcl(dilu_cmd)=0)
    RETURN(0)
   ENDIF
   SET dilu_cmd = concat(". ",dm2_install_schema->ccluserdir,dilu_file_name)
   IF (dm2_push_dcl(dilu_cmd)=0)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dilu_output_mng)=0)
    SET dm_err->eproc = concat("Execute file to determine account setting : ",dilu_file_name)
    SET dm_err->emsg = concat('Authview "show ',dilu_mng,'" did not create output file ',build(
      dilu_output_mng)," in CCLUSERDIR.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dilu_output_system)=0)
    SET dm_err->eproc = concat("Execute file to determine account setting : ",dilu_file_name)
    SET dm_err->emsg = concat('Authview "show ',dilu_system,'" did not create output file ',build(
      dilu_output_system)," in CCLUSERDIR.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(dilu_output_priv)=0)
    SET dm_err->eproc = concat("Execute file to determine account setting : ",dilu_file_name)
    SET dm_err->emsg = concat('Authview "show ',dilu_priv,'" did not create output file ',build(
      dilu_output_priv)," in CCLUSERDIR.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dilu_defaults_fnd = 0
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dilu_output_mng)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF (findstring("password life:",cnvtlower(r.line),1,0) > 0)
      dilu_defaults_fnd = 1
     ENDIF
     dilu_begpos = 0, dilu_begpos = findstring("directory user:",cnvtlower(r.line))
     IF (dilu_begpos > 0)
      dilu_mng_value = trim(substring((dilu_begpos+ 15),textlen(trim(r.line)),r.line),3)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parse out ",trim(dilu_mng)," account directory user from authview output."
     )) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag >= 1))
    CALL echo(concat("user defaults found indicator = ",cnvtstring(dilu_defaults_fnd)))
    CALL echo(concat(trim(dilu_mng)," directory user value = ",dilu_mng_value))
   ENDIF
   IF (dilu_defaults_fnd=0)
    SET dm_err->eproc = concat("Determine ",dilu_mng," user default setting.")
    SET dm_err->emsg =
    "Unable to retrieve user default settings from authview (show <user>) command."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dilu_defaults_fnd = 0
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dilu_output_system)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF (findstring("password life:",cnvtlower(r.line),1,0) > 0)
      dilu_defaults_fnd = 1
     ENDIF
     dilu_begpos = 0, dilu_begpos = findstring("directory user:",cnvtlower(r.line))
     IF (dilu_begpos > 0)
      dilu_system_value = trim(substring((dilu_begpos+ 15),textlen(trim(r.line)),r.line),3)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parse out ",trim(dilu_system),
     " account directory user from authview output.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag >= 1))
    CALL echo(concat("user defaults found indicator = ",cnvtstring(dilu_defaults_fnd)))
    CALL echo(concat(trim(dilu_system)," directory user value = ",dilu_system_value))
   ENDIF
   IF (dilu_defaults_fnd=0)
    SET dm_err->eproc = concat("Determine ",dilu_system," user default setting.")
    SET dm_err->emsg =
    "Unable to retrieve user default settings from authview (show <user>) command."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dilu_defaults_fnd = 0
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dilu_output_priv)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF (findstring("password life:",cnvtlower(r.line),1,0) > 0)
      dilu_defaults_fnd = 1
     ENDIF
     dilu_begpos = 0, dilu_begpos = findstring("directory user:",cnvtlower(r.line))
     IF (dilu_begpos > 0)
      dilu_priv_value = trim(substring((dilu_begpos+ 15),textlen(trim(r.line)),r.line),3)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parse out ",trim(dilu_priv),
     " account directory user from authview output.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag >= 1))
    CALL echo(concat("user defaults found indicator = ",cnvtstring(dilu_defaults_fnd)))
    CALL echo(concat(trim(dilu_priv)," directory user value = ",dilu_priv_value))
   ENDIF
   IF (dilu_defaults_fnd=0)
    SET dm_err->eproc = concat("Determine ",dilu_priv," user default setting.")
    SET dm_err->emsg =
    "Unable to retrieve user default settings from authview (show <user>) command."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(dilu_mng_value)="Y") OR (((cnvtupper(dilu_system_value)="Y") OR (cnvtupper(
    dilu_priv_value)="Y")) )) )
    SET dm_err->eproc = concat("Verify accounts [",dilu_mng,",",dilu_system,",",
     dilu_priv,"] are not LDAP enabled.")
    SET dm_err->emsg =
    "One or more of these accounts are LDAP enabled which is an invalid configuration."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (cnvtupper(dilu_system_default)="Y"
    AND ((cnvtupper(dilu_mng_value) != "N") OR (((cnvtupper(dilu_system_value) != "N") OR (cnvtupper(
    dilu_priv_value) != "N")) )) )
    SET dm_err->eproc = concat("Verify accounts [",dilu_mng,",",dilu_system,",",
     dilu_priv,"] are not LDAP enabled.")
    SET dm_err->emsg =
    "One or more of these accounts are LDAP enabled, by system default, which is an invalid configuration."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_interrogator_usage(diu_interrogator_ind,diu_interrogator_node)
   DECLARE diu_file_name = vc WITH protect, noconstant("")
   DECLARE diu_src_node = vc WITH protect, noconstant("")
   DECLARE diu_node_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Get Interrogator server (520) status.")
   CALL disp_msg("",dm_err->logfile,0)
   SET diu_file_name = concat(ddr_domain_data->src_tmp_full_dir,"intrrgtr_srvr_stat.ksh")
   SET diu_interrogator_ind = 0
   SET diu_interrogator_node = ""
   FOR (diu_node_cnt = 1 TO ddr_domain_data->src_nodes_cnt)
     SET diu_src_node = ddr_domain_data->src_nodes[diu_node_cnt].node_name
     IF (dm2_findfile(diu_file_name) > 0)
      IF (dm2_push_dcl(concat("rm ",diu_file_name))=0)
       RETURN(0)
      ENDIF
     ELSE
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
     SET dm_err->eproc = concat("Create file to get server status :",diu_file_name)
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO value(diu_file_name)
      FROM (dummyt t  WITH seq = 1)
      DETAIL
       CALL print("#!/usr/bin/ksh"), row + 1,
       CALL print("#"),
       row + 1,
       CALL print("# intrrgtr_srvr_stat.ksh"), row + 1,
       CALL print("#"), row + 1,
       CALL print(concat("src_mng_pwd='",ddr_domain_data->src_mng_pwd,"'")),
       row + 1,
       CALL print(concat("$cer_exe/scpview ",diu_src_node," <<!>",ddr_domain_data->src_tmp_full_dir,
        "intrrgtr_srvr_stat.dat")), row + 1,
       CALL print(ddr_domain_data->src_mng), row + 1,
       CALL print(ddr_domain_data->src_domain_name),
       row + 1,
       CALL print("$src_mng_pwd"), row + 1,
       CALL print("server -entry 520"), row + 1,
       CALL print("exit"),
       row + 1,
       CALL print("!"), row + 1,
       row + 1,
       CALL print(concat("tr '[:upper:]' '[:lower:]' < ",ddr_domain_data->src_tmp_full_dir,
        "intrrgtr_srvr_stat.dat|grep -e '^[0-9]'|grep 'running'")), row + 1,
       row + 1,
       CALL print("if [[ $? -eq 0 ]]"), row + 1,
       CALL print("then"), row + 1,
       CALL print('   echo "Server is running"'),
       row + 1,
       CALL print("fi"), row + 1,
       row + 1
      WITH nocounter, maxcol = 500, format = variable,
       maxrow = 1
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Execute ",diu_file_name)
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dm2_push_dcl(concat("chmod 777 ",diu_file_name))=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_dcl(concat(". ",diu_file_name))=0)
      RETURN(0)
     ELSE
      IF (parse_errfile(dm_err->errfile)=0)
       RETURN(0)
      ENDIF
      IF (findstring("Server is running",dm_err->errtext) > 0)
       SET diu_interrogator_ind = (diu_interrogator_ind+ 1)
       SET diu_interrogator_node = diu_src_node
      ENDIF
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_interrogator_backup(dib_mode)
   DECLARE dib_cmd_file_ret = vc WITH protect, noconstant("")
   DECLARE dib_log_str = vc WITH protect, noconstant("")
   DECLARE dib_str = vc WITH protect, noconstant("")
   DECLARE dib_tmp_remote_mode = i2 WITH protect, noconstant(0)
   DECLARE dib_src_intrrgtr_dir_loc = vc WITH protect, noconstant("")
   DECLARE dib_file_name = vc WITH protect, noconstant(concat(ddr_domain_data->src_env,"_dafsolr.sav"
     ))
   DECLARE dib_cmd = vc WITH protect, noconstant("")
   DECLARE dib_no_error = i2 WITH protect, noconstant(0)
   DECLARE dib_file_date = f8 WITH protect, noconstant(0.0)
   DECLARE dib_tmp_dir = vc WITH protect, noconstant("")
   DECLARE dib_kfile_name = vc WITH protect, noconstant("")
   DECLARE dib_cur_node = vc WITH protect, noconstant("")
   DECLARE dib_ccluserdir = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Backup of the Interrogator solution content.")
   CALL disp_msg("",dm_err->logfile,0)
   IF ((ddr_domain_data->src_interrogator_node=trim(curnode)))
    SET dib_tmp_remote_mode = 0
   ELSE
    SET dib_tmp_remote_mode = 1
   ENDIF
   SET dm_err->eproc = concat("Get the Interrogator Data location row from DM_INFO.")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    di.info_char
    FROM dm_info di
    WHERE di.info_domain="ICD9 Interrogator"
     AND di.info_name="SolR Data Location Row"
    DETAIL
     dib_src_intrrgtr_dir_loc = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Interrogator Data Location Row does not exist in DM_INFO."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dib_tmp_remote_mode=1)
    SET dib_cmd = concat("ssh -o batchmode=yes -o numberofpasswordprompts=0 root@",ddr_domain_data->
     src_interrogator_node,' echo "Source_APP_Node:\`hostname\`"')
    SET dm_err->eproc = concat("Executing: ",dib_cmd)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(dib_cmd)=0
     AND (dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Output returned from ssh command = ",dm_err->errtext))
    ENDIF
    IF (findstring("SOURCE_APP_NODE:",cnvtupper(dm_err->errtext),1,0) > 0)
     IF (findstring(cnvtupper(ddr_domain_data->src_interrogator_node),cnvtupper(dm_err->errtext),
      findstring("SOURCE_APP_NODE:",cnvtupper(dm_err->errtext),1,0),0)=0)
      SET dm_err->err_ind = 1
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
    ENDIF
    IF ((dm_err->err_ind=1))
     SET dm_err->eproc = concat("Verify SSH setup between Primary Source APP node (",trim(cnvtupper(
        curnode)),") and Remote Source APP node (",cnvtupper(ddr_domain_data->src_interrogator_node),
      ") for the root user.")
     SET dm_err->emsg = concat(
      "SSH command did not return the Remote Source App node.  On the Primary Source App node as ",
      "the root user, verify that the following o/s command returns a 'SOURCE_APP_NODE' value of ",
      ddr_domain_data->src_interrogator_node,": ",dib_cmd)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   WHILE (findstring("{",dib_src_intrrgtr_dir_loc,1,0) > 0)
     SET dib_log_str = substring((findstring("{",dib_src_intrrgtr_dir_loc,1,0)+ 1),((findstring("}",
       dib_src_intrrgtr_dir_loc,1,0) - findstring("{",dib_src_intrrgtr_dir_loc,1,0)) - 1),
      dib_src_intrrgtr_dir_loc)
     SET dib_str = trim(logical(trim(dib_log_str)))
     SET dib_src_intrrgtr_dir_loc = replace(dib_src_intrrgtr_dir_loc,concat("{",trim(dib_log_str),"}"
       ),trim(dib_str),0)
   ENDWHILE
   SET dib_src_intrrgtr_dir_loc = substring(0,(findstring("dafsolr",dib_src_intrrgtr_dir_loc,1,0)+ 7),
    dib_src_intrrgtr_dir_loc)
   IF (dib_tmp_remote_mode=0)
    IF ( NOT (dm2_find_dir(dib_src_intrrgtr_dir_loc)))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("No directory exists with ",dib_src_intrrgtr_dir_loc)
     SET dm_err->emsg = concat("Failed to find ",dib_src_intrrgtr_dir_loc)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(1," "," "," ",concat("du -sk ",dib_src_intrrgtr_dir_loc,
       " | awk '{print $1}'"),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
     SET ddr_space_needs->src_interrogator_size = trim(dor_flex_cmd->cmd[1].flex_output)
    ENDIF
   ENDIF
   IF (dib_tmp_remote_mode=1)
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(0,"root",ddr_domain_data->src_interrogator_node," ",concat("test -d ",
      dib_src_intrrgtr_dir_loc," ;echo $?"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output="1"))
     IF ((dm2ftpr->exists_ind=0))
      SET dm_err->eproc = concat("Verify directory (",dib_src_intrrgtr_dir_loc,") exists on node (",
       ddr_domain_data->src_interrogator_node,").")
      SET dm_err->emsg = concat("Interrogator directory (",dib_src_intrrgtr_dir_loc,
       ") not found on remote source APP node (",ddr_domain_data->src_interrogator_node,").")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(0,"root",ddr_domain_data->src_interrogator_node," ",concat("du -sk ",
      dib_src_intrrgtr_dir_loc),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    SET ddr_space_needs->src_interrogator_size = substring(1,(findstring("/",trim(dor_flex_cmd->cmd[1
       ].flex_output),1,0) - 2),trim(dor_flex_cmd->cmd[1].flex_output))
   ENDIF
   IF (dib_mode="SIZE")
    RETURN(1)
   ENDIF
   IF (dib_tmp_remote_mode=0)
    SET dm_err->eproc = concat("Creating a command file to backup Interrogator directory.")
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (ddr_create_tar_routine(dib_src_intrrgtr_dir_loc,concat(ddr_domain_data->src_tmp_full_dir,
      dib_file_name),dib_cmd_file_ret,"DAFSOLR")=0)
     RETURN(0)
    ENDIF
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(1," "," "," ",concat(". $CCLUSERDIR/",dib_cmd_file_ret),
     " ","EC")
    SET dm_err->disp_dcl_err_ind = 0
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ELSE
     SET dib_no_error = 1
    ENDIF
    IF (findstring("tar: couldn't get",trim(dor_flex_cmd->cmd[1].flex_output),1,0) > 0)
     IF (ddr_add_tar_error(1,0,"DAFSOLR")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dib_str = replace(trim(dor_flex_cmd->cmd[1].flex_output),"tar: couldn't get gname for gid ",
     "",0)
    SET dib_str = cnvtalphanum(replace(dib_str,"tar: couldn't get uname for gid ","",0))
    IF (isnumeric(dib_str)=1)
     SET dib_no_error = 1
    ENDIF
    IF (dib_no_error=0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,dib_file_name))=0)
     SET dm_err->emsg = concat("Error copying ",dib_file_name,": file does not exist.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,dib_file_name),dib_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_interrogator_ts = dib_file_date
    SET ddr_domain_data->src_interrogator_fnd = 1
   ENDIF
   IF (dib_tmp_remote_mode=1)
    SET dib_tmp_dir = drrr_rf_data->tgt_interrogator_tmp_dir
    SET dm_err->eproc = concat("Verify directory (",dib_tmp_dir,") exists on node (",ddr_domain_data
     ->src_interrogator_node,").")
    CALL disp_msg("",dm_err->logfile,0)
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(0,"root",ddr_domain_data->src_interrogator_node," ",concat("test -d ",
      dib_tmp_dir," ;echo $?"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output="1"))
     SET dm_err->eproc = concat("Verify directory (",dib_tmp_dir,") exists on node (",ddr_domain_data
      ->src_interrogator_node,").")
     SET dm_err->emsg = concat("Interrogator temporary directory (",dib_tmp_dir,
      ") not found on remote source APP node (",ddr_domain_data->src_interrogator_node,").")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((validate(dm2_bypass_intrrgtr_space_check,- (1))=- (1)))
     CALL echo(concat("Free Space Check String: ",dib_str))
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(0,"root",ddr_domain_data->src_interrogator_node," ",concat(
       '"LANG=C df -kP ',dib_tmp_dir,^"|grep -v Filesys|awk '{print \$4}'^),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
     SET dib_size_str = trim(dor_flex_cmd->cmd[1].flex_output)
     IF (cnvtreal(ddr_space_needs->src_interrogator_size) > cnvtreal(trim(dib_size_str)))
      SET dm_err->eproc = concat("Verify to check if there is enough space on directory ",dib_tmp_dir
       )
      SET dm_err->emsg = concat(dib_tmp_dir," doesnot have enouhgh space on ",ddr_domain_data->
       src_interrogator_node)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc =
     "User requested bypass of Interrogator temporary directory free space check."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET dm_err->eproc = concat("Creating a command file to backup Interrogator directory.")
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (ddr_create_tar_routine(dib_src_intrrgtr_dir_loc,concat(dib_tmp_dir,dib_file_name),
     dib_cmd_file_ret,"DAFSOLR")=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Copy command file ",dib_cmd_file_ret," to remote source APP node.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dib_ccluserdir = trim(logical("CCLUSERDIR"))
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(0,"root",ddr_domain_data->src_interrogator_node,concat(dib_ccluserdir,"/",
      dib_cmd_file_ret)," ",
     concat(dib_tmp_dir,dib_cmd_file_ret),"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Execute command file ",dib_cmd_file_ret," on remote source APP node."
     )
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(0,"root",ddr_domain_data->src_interrogator_node," ",concat(". ",dib_tmp_dir,
      "/",dib_cmd_file_ret),
     " ","EC")
    SET dm_err->disp_dcl_err_ind = 0
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ELSE
     SET dib_no_error = 1
    ENDIF
    IF (findstring("tar: couldn't get",trim(dor_flex_cmd->cmd[1].flex_output),1,0) > 0)
     IF (ddr_add_tar_error(1,0,"DAFSOLR")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dib_str = replace(trim(dor_flex_cmd->cmd[1].flex_output),"tar: couldn't get gname for gid ",
     "",0)
    SET dib_str = cnvtalphanum(replace(dib_str,"tar: couldn't get uname for gid ","",0))
    IF (isnumeric(dib_str)=1)
     SET dib_no_error = 1
    ENDIF
    IF (dib_no_error=0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Copy ",dib_file_name," file from remote source APP node (",
     ddr_domain_data->src_interrogator_node,").")
    CALL disp_msg("",dm_err->logfile,0)
    SET dm2ftpr->user_name = "root"
    SET dm2ftpr->remote_host = ddr_domain_data->src_interrogator_node
    SET dm2ftpr->options = "-b"
    CALL dfr_add_getops_line(" "," "," "," "," ",
     1)
    CALL dfr_add_getops_line(" ",ddr_domain_data->src_tmp_full_dir,trim(dib_file_name),trim(
      dib_tmp_dir),trim(dib_file_name),
     0)
    IF (dfr_get_file(null)=0)
     RETURN(0)
    ENDIF
    CALL dfr_add_getops_line(" "," "," "," "," ",
     1)
    IF (dm2_findfile(concat(ddr_domain_data->src_tmp_full_dir,dib_file_name))=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Copy ",dib_file_name," file from remote source APP node (",
      ddr_domain_data->src_interrogator_node,").")
     SET dm_err->emsg = concat("Faild to copy ",dib_file_name," file from remote source APP node (",
      ddr_domain_data->src_interrogator_node,") to primary source APP node.")
     RETURN(0)
    ENDIF
    IF (ddr_get_file_date(concat(ddr_domain_data->src_tmp_full_dir,dib_file_name),dib_file_date)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->src_interrogator_ts = dib_file_date
    SET ddr_domain_data->src_interrogator_fnd = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_get_ops_version(dgov_db_link)
  IF ((validate(dm2_bypass_opsexec_maint,- (1))=- (1)))
   IF (ops_get_version(dgov_db_link,ddr_ops_info->version,ddr_ops_info->migration_in_progress,
    ddr_ops_info->error)=0)
    SET dm_err->eproc = "Get Operations version."
    SET dm_err->emsg = ddr_ops_info->error
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((ddr_ops_info->migration_in_progress=1))
    SET dm_err->eproc = "Get Operations version."
    SET dm_err->emsg = "Operations migration in progress.  Cannot proceed."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((ddr_ops_info->version > 1.0))
    SET ddr_ops_info->tbl_name = "OPS2_CTRL_GROUP"
    SET ddr_ops_info->col_host = "host_name"
    SET ddr_ops_info->col_group_id = "ops2_ctrl_group_id"
    SET ddr_ops_info->col_group_name = "ctrl_group_name"
    SET ddr_ops_info->col_server_nbr = "server_entry_nbr"
   ELSE
    SET ddr_ops_info->tbl_name = "OPS_CONTROL_GROUP"
    SET ddr_ops_info->col_host = "host"
    SET ddr_ops_info->col_group_id = "ops_control_grp_id"
    SET ddr_ops_info->col_group_name = "name"
    SET ddr_ops_info->col_server_nbr = "server_number"
   ENDIF
   SET dm_err->eproc = concat("Operations [Major] Version: ",cnvtstring(ddr_ops_info->version))
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_backup_file_content_load(dbfcl_src_ind,dbfcl_tgt_ind)
   DECLARE dbfcl_token_prefix = vc WITH protect, noconstant("")
   DECLARE dbfcl_domain = vc WITH protect, noconstant("")
   DECLARE dbfcl_temp_dir = vc WITH protect, noconstant("")
   DECLARE dbfcl_env = vc WITH protect, noconstant("")
   DECLARE dbfcl_file = vc WITH protect, noconstant(build(dm2_install_schema->cer_install,
     "dm2_rr_backup_file_content.csv"))
   DECLARE dbfcl_cust_file = vc WITH protect, noconstant(build(dm2_install_schema->cer_install,
     "dm2_rr_backup_file_content_<env>.csv"))
   DECLARE dbfcl_work_file = vc WITH protect, noconstant("")
   DECLARE dbfcl_file_cnt = i2 WITH protect, noconstant(1)
   DECLARE dbfcl_cntr = i2 WITH protect, noconstant(0)
   DECLARE dbfcl_fatal_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dbfcl_fatal_str = vc WITH protect, noconstant("")
   DECLARE dbfcl_str = vc WITH protect, noconstant("")
   DECLARE dbfcl_token = vc WITH protect, noconstant("")
   DECLARE dbfcl_mode = vc WITH protect, noconstant("")
   DECLARE dbfcl_fdir = vc WITH protect, noconstant("")
   DECLARE dbfcl_fvalue = vc WITH protect, noconstant("")
   DECLARE dbfcl_dest_dir = vc WITH protect, noconstant("")
   DECLARE dbfcl_dest_fname = vc WITH protect, noconstant("")
   DECLARE dbfcl_options = vc WITH protect, noconstant("")
   DECLARE dbfcl_req_ind = vc WITH protect, noconstant("")
   DECLARE dbfcl_active_ind = vc WITH protect, noconstant("")
   DECLARE dbfcl_idx = i4 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os != "LNX"))
    RETURN(1)
   ENDIF
   IF (((dbfcl_src_ind=0
    AND dbfcl_tgt_ind=0) OR (dbfcl_src_ind=1
    AND dbfcl_tgt_ind=1)) )
    SET dm_err->eproc = "Validating input indicators."
    SET dm_err->emsg =
    "Invalid input combination.  Need to specifiy either source or target indicator and not both."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dbfcl_src_ind=1)
    SET dbfcl_token_prefix = "SRC"
    SET dbfcl_domain = ddr_domain_data->src_domain_name
    SET dbfcl_temp_dir = ddr_domain_data->src_tmp_full_dir
    SET dbfcl_env = ddr_domain_data->src_env
   ELSE
    SET dbfcl_token_prefix = "TGT"
    SET dbfcl_domain = ddr_domain_data->tgt_domain_name
    SET dbfcl_temp_dir = ddr_domain_data->tgt_tmp_full_dir
    SET dbfcl_env = ddr_domain_data->tgt_env
   ENDIF
   IF (substring(size(dbfcl_temp_dir),1,dbfcl_temp_dir)="/")
    SET dbfcl_temp_dir = trim(replace(dbfcl_temp_dir,"/","",2),3)
   ENDIF
   SET dbfcl_cust_file = replace(dbfcl_cust_file,"<env>",dbfcl_env,0)
   IF (dm2_findfile(dbfcl_cust_file) > 0)
    SET dbfcl_file_cnt = (dbfcl_file_cnt+ 1)
   ENDIF
   FOR (dbfcl_cntr = 1 TO dbfcl_file_cnt)
     IF (dbfcl_cntr=1)
      SET dbfcl_work_file = dbfcl_file
     ELSE
      SET dbfcl_work_file = dbfcl_cust_file
     ENDIF
     SET dm_err->eproc = concat("Open ",dbfcl_work_file," and load backend file content.")
     CALL disp_msg("",dm_err->logfile,0)
     FREE SET dbfcl_data_file
     SET logical dbfcl_data_file dbfcl_work_file
     FREE DEFINE rtl3
     DEFINE rtl3 "dbfcl_data_file"
     SELECT INTO "nl:"
      t.line
      FROM rtl3t t
      WHERE t.line > " "
      DETAIL
       IF (dbfcl_fatal_err_ind=0)
        dbfcl_str = trim(t.line,3)
        IF ((dm_err->debug_flag > 4))
         CALL echo(concat("line = ",dbfcl_str))
        ENDIF
        IF (substring(1,3,dbfcl_str)=dbfcl_token_prefix)
         dbfcl_str = replace(dbfcl_str,"<<domain>>",dbfcl_domain,0), dbfcl_str = replace(dbfcl_str,
          "<<temp_full_dir>>",dbfcl_temp_dir,0), dbfcl_str = replace(dbfcl_str,"<<node>>",trim(
           cnvtlower(curnode),3),0),
         dbfcl_str = replace(dbfcl_str,"<<env>>",dbfcl_env,0)
         IF ((dm_err->debug_flag > 4))
          CALL echo(concat("line_w_tokens_replaced = ",dbfcl_str))
         ENDIF
         dbfcl_token = trim(piece(dbfcl_str,",",1,"Not Found"),3), dbfcl_mode = trim(piece(dbfcl_str,
           ",",2,"Not Found"),3), dbfcl_fdir = trim(piece(dbfcl_str,",",3,"Not Found"),3),
         dbfcl_fvalue = trim(piece(dbfcl_str,",",4,"Not Found"),3), dbfcl_dest_dir = trim(piece(
           dbfcl_str,",",5,"Not Found"),3), dbfcl_dest_fname = trim(piece(dbfcl_str,",",6,"Not Found"
           ),3),
         dbfcl_options = trim(piece(dbfcl_str,",",7,"Not Found"),3), dbfcl_req_ind = trim(piece(
           dbfcl_str,",",8,"Not Found"),3), dbfcl_active_ind = trim(piece(dbfcl_str,",",9,"Not Found"
           ),3)
         IF ((dm_err->debug_flag > 4))
          CALL echo(concat("token = ",dbfcl_token)),
          CALL echo(concat("mode = ",dbfcl_mode)),
          CALL echo(concat("fdir = ",dbfcl_fdir)),
          CALL echo(concat("fvalue = ",dbfcl_fvalue)),
          CALL echo(concat("dest_dir = ",dbfcl_dest_dir)),
          CALL echo(concat("dest_fname = ",dbfcl_dest_fname)),
          CALL echo(concat("options = ",dbfcl_options)),
          CALL echo(concat("req_ind = ",dbfcl_req_ind)),
          CALL echo(concat("active_ind = ",dbfcl_active_ind))
         ENDIF
         dbfcl_idx = 0
         IF (dbfcl_mode IN ("COPY", "TAR", "FINDCOPY")
          AND dbfcl_fdir != "Not Found"
          AND textlen(dbfcl_fdir) > 0
          AND findstring(" ",dbfcl_fdir,1)=0
          AND dbfcl_fvalue != "Not Found"
          AND textlen(dbfcl_fvalue) > 0
          AND ((dbfcl_mode="COPY"
          AND findstring(" ",dbfcl_fvalue,1)=0) OR (((dbfcl_mode="FINDCOPY"
          AND substring(1,5,dbfcl_fvalue)="find "
          AND findstring(dbfcl_fdir,dbfcl_fvalue,1,0) > 0) OR (dbfcl_mode="TAR"
          AND size(dbfcl_fvalue)=findstring("/",dbfcl_fvalue,0,0)
          AND findstring(" ",dbfcl_fvalue,1)=0)) ))
          AND dbfcl_dest_dir != "Not Found"
          AND textlen(dbfcl_dest_dir) > 0
          AND findstring(" ",dbfcl_dest_dir,1)=0
          AND ((dbfcl_mode IN ("COPY", "TAR")
          AND substring(1,size(dbfcl_temp_dir),dbfcl_dest_dir)=dbfcl_temp_dir) OR (dbfcl_mode=
         "FINDCOPY"
          AND substring(1,(size(dbfcl_temp_dir)+ 1),dbfcl_dest_dir)=build(dbfcl_temp_dir,"/")
          AND (size(dbfcl_dest_dir) > (size(dbfcl_temp_dir)+ 2))))
          AND dbfcl_dest_fname != "Not Found"
          AND textlen(dbfcl_dest_fname) > 0
          AND ((dbfcl_mode IN ("COPY", "TAR")
          AND findstring(" ",dbfcl_dest_fname,1)=0) OR (dbfcl_mode="FINDCOPY"
          AND findstring("$f",dbfcl_dest_fname,1) > 0))
          AND ((substring(1,1,dbfcl_options)="-") OR (dbfcl_options="none"))
          AND findstring(" ",dbfcl_options,1)=0
          AND dbfcl_req_ind IN ("0", "1")
          AND dbfcl_active_ind IN ("0", "1")
          AND ((dbfcl_token_prefix="SRC"
          AND dbfcl_mode="FINDCOPY"
          AND (((ddr_backup_file_content->src_backup_list_cnt > 0)
          AND locateval(dbfcl_idx,1,ddr_backup_file_content->src_backup_list_cnt,dbfcl_dest_dir,
          ddr_backup_file_content->src_backup_list[dbfcl_idx].dest_dir)=0) OR ((
         ddr_backup_file_content->src_backup_list_cnt=0))) ) OR (((dbfcl_token_prefix="TGT"
          AND dbfcl_mode="FINDCOPY"
          AND (((ddr_backup_file_content->tgt_backup_list_cnt > 0)
          AND locateval(dbfcl_idx,1,ddr_backup_file_content->tgt_backup_list_cnt,dbfcl_dest_dir,
          ddr_backup_file_content->tgt_backup_list[dbfcl_idx].dest_dir)=0) OR ((
         ddr_backup_file_content->tgt_backup_list_cnt=0))) ) OR (((dbfcl_token_prefix="SRC"
          AND dbfcl_mode != "FINDCOPY"
          AND (((ddr_backup_file_content->src_backup_list_cnt > 0)
          AND locateval(dbfcl_idx,1,ddr_backup_file_content->src_backup_list_cnt,dbfcl_dest_fname,
          ddr_backup_file_content->src_backup_list[dbfcl_idx].dest_fname)=0) OR ((
         ddr_backup_file_content->src_backup_list_cnt=0))) ) OR (dbfcl_token_prefix="TGT"
          AND dbfcl_mode != "FINDCOPY"
          AND (((ddr_backup_file_content->tgt_backup_list_cnt > 0)
          AND locateval(dbfcl_idx,1,ddr_backup_file_content->tgt_backup_list_cnt,dbfcl_dest_fname,
          ddr_backup_file_content->tgt_backup_list[dbfcl_idx].dest_fname)=0) OR ((
         ddr_backup_file_content->tgt_backup_list_cnt=0))) )) )) )) )
          IF (dbfcl_token_prefix="SRC"
           AND dbfcl_active_ind="1")
           ddr_backup_file_content->src_backup_list_cnt = (ddr_backup_file_content->
           src_backup_list_cnt+ 1), stat = alterlist(ddr_backup_file_content->src_backup_list,
            ddr_backup_file_content->src_backup_list_cnt), ddr_backup_file_content->src_backup_list[
           ddr_backup_file_content->src_backup_list_cnt].token = dbfcl_token,
           ddr_backup_file_content->src_backup_list[ddr_backup_file_content->src_backup_list_cnt].
           mode = dbfcl_mode, ddr_backup_file_content->src_backup_list[ddr_backup_file_content->
           src_backup_list_cnt].fdir = dbfcl_fdir, ddr_backup_file_content->src_backup_list[
           ddr_backup_file_content->src_backup_list_cnt].fvalue = dbfcl_fvalue,
           ddr_backup_file_content->src_backup_list[ddr_backup_file_content->src_backup_list_cnt].
           dest_dir = dbfcl_dest_dir, ddr_backup_file_content->src_backup_list[
           ddr_backup_file_content->src_backup_list_cnt].dest_fname = dbfcl_dest_fname,
           ddr_backup_file_content->src_backup_list[ddr_backup_file_content->src_backup_list_cnt].
           options = dbfcl_options,
           ddr_backup_file_content->src_backup_list[ddr_backup_file_content->src_backup_list_cnt].
           req_ind = cnvtint(dbfcl_req_ind)
          ELSEIF (dbfcl_token_prefix="TGT"
           AND dbfcl_active_ind="1")
           ddr_backup_file_content->tgt_backup_list_cnt = (ddr_backup_file_content->
           tgt_backup_list_cnt+ 1), stat = alterlist(ddr_backup_file_content->tgt_backup_list,
            ddr_backup_file_content->tgt_backup_list_cnt), ddr_backup_file_content->tgt_backup_list[
           ddr_backup_file_content->tgt_backup_list_cnt].token = dbfcl_token,
           ddr_backup_file_content->tgt_backup_list[ddr_backup_file_content->tgt_backup_list_cnt].
           mode = dbfcl_mode, ddr_backup_file_content->tgt_backup_list[ddr_backup_file_content->
           tgt_backup_list_cnt].fdir = dbfcl_fdir, ddr_backup_file_content->tgt_backup_list[
           ddr_backup_file_content->tgt_backup_list_cnt].fvalue = dbfcl_fvalue,
           ddr_backup_file_content->tgt_backup_list[ddr_backup_file_content->tgt_backup_list_cnt].
           dest_dir = dbfcl_dest_dir, ddr_backup_file_content->tgt_backup_list[
           ddr_backup_file_content->tgt_backup_list_cnt].dest_fname = dbfcl_dest_fname,
           ddr_backup_file_content->tgt_backup_list[ddr_backup_file_content->tgt_backup_list_cnt].
           options = dbfcl_options,
           ddr_backup_file_content->tgt_backup_list[ddr_backup_file_content->tgt_backup_list_cnt].
           req_ind = cnvtint(dbfcl_req_ind)
          ENDIF
         ELSE
          dbfcl_fatal_str = trim(dbfcl_str), dbfcl_fatal_err_ind = 1
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (dbfcl_fatal_err_ind=1)
      SET dm_err->emsg = concat("One or more fields for record in csv is invalid (",trim(
        dbfcl_fatal_str),").")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(ddr_backup_file_content)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_backup_file_content(dbfc_mode,dbfc_fdir,dbfc_fvalue,dbfc_dest_dir,dbfc_dest_fname,
  dbfc_options,dbfc_req_ind)
   DECLARE dbfc_dir_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dbfc_cmd = vc WITH protect, noconstant(" ")
   DECLARE dbfc_bckup_file = vc WITH protect, noconstant("dm2_bkup_file")
   DECLARE dbfc_str = vc WITH protect, noconstant("")
   DECLARE dbfc_no_error = i2 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os != "LNX"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Backup file where mode is (",dbfc_mode,"), directory is (",dbfc_fdir,
    ") and filename is (",
    dbfc_fvalue,").")
   CALL disp_msg("",dm_err->logfile,0)
   SET dm_err->eproc = concat("Validating existence of destination directory (",build(dbfc_dest_dir),
    ").")
   CALL disp_msg("",dm_err->logfile,0)
   SET dbfc_dir_found_ind = 0
   SET dbfc_dir_found_ind = dm2_find_dir(dbfc_dest_dir)
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   IF (dbfc_dir_found_ind=0)
    SET dm_err->eproc = concat("Creating destination directory (",build(dbfc_dest_dir),
     ") and opening permissions.")
    CALL disp_msg("",dm_err->logfile,0)
    SET dbfc_cmd = concat("mkdir -p ",dbfc_dest_dir)
    IF (dm2_push_dcl(dbfc_cmd)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dbfc_cmd = concat("chmod 777 ",dbfc_dest_dir)
   IF (dm2_push_dcl(dbfc_cmd)=0)
    RETURN(0)
   ENDIF
   IF (dbfc_mode IN ("COPY", "TAR"))
    SET dm_err->eproc = concat("Verifying existence of destination file ",build(dbfc_dest_dir,"/",
      dbfc_dest_fname),".")
    CALL disp_msg("",dm_err->logfile,0)
    IF (dm2_findfile(build(dbfc_dest_dir,"/",dbfc_dest_fname)) > 0)
     IF (dm2_push_dcl(concat("rm ",build(dbfc_dest_dir,"/",dbfc_dest_fname)))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Verifying existence of destination file(s) in ",build(dbfc_dest_dir),
     ".")
    CALL disp_msg("",dm_err->logfile,0)
    SET dbfc_cmd = concat("find ",build(dbfc_dest_dir)," -type f -print|wc -l")
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(dbfc_cmd)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (trim(dm_err->errtext,3) != "0")
     IF (dm2_push_dcl(concat("find ",build(dbfc_dest_dir)," -type f -exec rm {} \;"))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Verify input backup directory (",dbfc_fdir,").")
   CALL disp_msg("",dm_err->logfile,0)
   SET dbfc_dir_found_ind = 0
   SET dbfc_dir_found_ind = dm2_find_dir(dbfc_fdir)
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   IF (dbfc_dir_found_ind=0)
    IF (dbfc_req_ind=1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating directory for backup : ",dbfc_fdir)
     SET dm_err->emsg = concat("Directory (",dbfc_fdir,") not found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dm_err->eproc = concat("Backup directory (",dbfc_fdir,
      ") not found and backup of content not required.")
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   IF (dbfc_mode="TAR")
    SET dm_err->eproc = concat("Validating directory for ",dbfc_mode," backup : ",build(dbfc_fdir,"/",
      dbfc_fvalue))
    CALL disp_msg("",dm_err->logfile,0)
    SET dbfc_dir_found_ind = 0
    SET dbfc_dir_found_ind = dm2_find_dir(build(dbfc_fdir,"/",dbfc_fvalue))
    IF ((dm_err->err_ind > 0))
     RETURN(0)
    ENDIF
    IF (dbfc_dir_found_ind=0)
     IF (dbfc_req_ind=1)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating directory/filename for ",dbfc_mode," backup : ",build(
        dbfc_fdir,"/",dbfc_fvalue))
      SET dm_err->emsg = concat("Directory/filename (",build(dbfc_fdir,"/",dbfc_fvalue),
       ") not found.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET dm_err->eproc = concat("Backup directory/filename for ",dbfc_mode," backup (",build(
        dbfc_fdir,"/",dbfc_fvalue),") not found and backup of content not required.")
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   IF (dbfc_mode="COPY")
    SET dm_err->eproc = concat("Validating file for ",dbfc_mode," backup (",build(dbfc_fdir,"/",
      dbfc_fvalue),").")
    CALL disp_msg("",dm_err->logfile,0)
    IF (dm2_findfile(build(dbfc_fdir,"/",dbfc_fvalue))=0)
     IF (dbfc_req_ind=1)
      SET dm_err->eproc = concat("Validating file for ",dbfc_mode," backup : ",build(dbfc_fdir,"/",
        dbfc_fvalue))
      SET dm_err->emsg = concat("File (",build(dbfc_fdir,"/",dbfc_fvalue),") not found.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET dm_err->eproc = concat("Backup file for ",dbfc_mode," backup (",build(dbfc_fdir,"/",
        dbfc_fvalue),") not found and backup of content not required.")
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ENDIF
    ENDIF
   ELSE
    IF (dbfc_mode="FINDCOPY")
     SET dm_err->eproc = concat("Validating backup files for ",dbfc_mode,": ",build(dbfc_fvalue))
     SET dbfc_cmd = concat(dbfc_fvalue,"|wc -l")
    ELSE
     SET dm_err->eproc = concat("Validating backup files for ",dbfc_mode,": ",build(dbfc_fdir,"/",
       dbfc_fvalue))
     SET dbfc_cmd = concat("find ",build(dbfc_fdir,"/",replace(dbfc_fvalue,"/","")),
      " -type f -o -type d -print|wc -l")
    ENDIF
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(dbfc_cmd)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (trim(dm_err->errtext,3)="0")
     IF (dbfc_req_ind=1)
      SET dm_err->eproc = concat("Validating backup files for ",dbfc_mode,": ",evaluate(dbfc_mode,
        "FINDCOPY",build(dbfc_fvalue),build(dbfc_fdir,"/",dbfc_fvalue)))
      SET dm_err->emsg = concat("Expected files to backup not found in ",evaluate(dbfc_mode,
        "FINDCOPY",build(dbfc_fvalue),build(dbfc_fdir,"/",dbfc_fvalue)),".")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET dm_err->eproc = concat("Expected files for ",dbfc_mode," to backup not found in ",evaluate(
        dbfc_mode,"FINDCOPY",build(dbfc_fvalue),build(dbfc_fdir,"/",dbfc_fvalue)),
       " and backup of content not required.")
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   IF (dbfc_mode="COPY")
    SET dm_err->eproc = concat("Complete backup of ",build(dbfc_fdir,"/",dbfc_fvalue)," to ",build(
      dbfc_dest_dir,"/",dbfc_dest_fname),".")
    CALL disp_msg("",dm_err->logfile,0)
    SET dbfc_cmd = concat("\cp -f ",trim(evaluate(dbfc_options,"none","",dbfc_options),3)," ",build(
      dbfc_fdir,"/",dbfc_fvalue)," ",
     build(dbfc_dest_dir,"/",dbfc_dest_fname))
    IF (dm2_push_dcl(dbfc_cmd)=0)
     RETURN(0)
    ENDIF
    IF (dm2_findfile(build(dbfc_dest_dir,"/",dbfc_dest_fname))=0)
     SET dm_err->eproc = concat("Validating backup file for COPY: ",build(dbfc_dest_dir,"/",
       dbfc_dest_fname))
     SET dm_err->emsg = concat("File (",build(dbfc_dest_dir,"/",dbfc_dest_fname),") not found.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSEIF (dbfc_mode IN ("FINDCOPY", "TAR"))
    IF (get_unique_file(dbfc_bckup_file,".ksh")=0)
     RETURN(0)
    ENDIF
    SET dbfc_bckup_file = dm_err->unique_fname
    SET dm_err->eproc = concat("Create file for copy file operation: ",dbfc_bckup_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO value(dbfc_bckup_file)
     DETAIL
      IF (dbfc_mode="FINDCOPY")
       CALL print("#!/bin/ksh"), row + 1,
       CALL print("#"),
       row + 1,
       CALL print(concat("for f in `",dbfc_fvalue,"`")), row + 1,
       CALL print("do"), row + 1,
       CALL print(concat("  filename=`",dbfc_dest_fname,"`")),
       row + 1,
       CALL print(concat("\cp ",trim(evaluate(dbfc_options,"none","",dbfc_options),3)," $f ",build(
         dbfc_dest_dir,"/$filename"))), row + 1,
       CALL print("done"), row + 1
      ELSE
       CALL print(concat("cd ",dbfc_fdir)), row + 1,
       CALL print(concat("tar ",trim(evaluate(dbfc_options,"none","",dbfc_options),3)," ",build(
         dbfc_dest_dir,"/",dbfc_dest_fname)," ",
        dbfc_fvalue)),
       row + 1
      ENDIF
     WITH nocounter, maxcol = 500, format = variable,
      maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dbfc_mode="FINDCOPY")
     SET dm_err->eproc = concat('Complete backup of files from "',build(dbfc_fvalue),'" in ',
      dbfc_fdir," directory to ",
      build(dbfc_dest_dir)," based on find command.")
     CALL disp_msg("",dm_err->logfile,0)
     SET dbfc_cmd = concat("chmod 777 ",build(dm2_install_schema->ccluserdir,dbfc_bckup_file))
     IF (dm2_push_dcl(dbfc_cmd)=0)
      RETURN(0)
     ENDIF
     SET dbfc_cmd = concat(". ",build(dm2_install_schema->ccluserdir,dbfc_bckup_file))
     IF (dm2_push_dcl(dbfc_cmd)=0)
      RETURN(0)
     ENDIF
     SET dbfc_cmd = concat("find ",build(dbfc_dest_dir)," -type f -print|wc -l")
     SET dm_err->disp_dcl_err_ind = 0
     IF (dm2_push_dcl(dbfc_cmd)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (trim(dm_err->errtext,3)="0")
      SET dm_err->eproc = concat("Validating backup file for FINDCOPY: ",build(dbfc_dest_dir))
      SET dm_err->emsg = concat("Expected files not copied to ",build(dbfc_dest_dir),".")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = concat("Complete tar backup of ",build(dbfc_fdir,"/",dbfc_fvalue)," to ",
      build(dbfc_dest_dir,"/",dbfc_dest_fname),".")
     CALL disp_msg("",dm_err->logfile,0)
     SET dbfc_cmd = concat(". ",build(dm2_install_schema->ccluserdir,dbfc_bckup_file))
     SET dm_err->disp_dcl_err_ind = 0
     SET dbfc_no_error = dm2_push_dcl(dbfc_cmd)
     IF (dbfc_no_error=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ELSE
      IF (parse_errfile(dm_err->errfile)=0)
       RETURN(0)
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echorecord(dm_err)
      ENDIF
     ENDIF
     SET dbfc_str = replace(dm_err->errtext,"tar: couldn't get gname for gid ","",0)
     SET dbfc_str = cnvtalphanum(replace(dbfc_str,"tar: couldn't get uname for uid ","",0))
     IF (isnumeric(dbfc_str)=1)
      SET dbfc_no_error = 1
     ENDIF
     IF (dbfc_no_error=0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dm2_findfile(build(dbfc_dest_dir,"/",dbfc_dest_fname))=0)
      SET dm_err->emsg = concat("Error copying ",dbfc_fvalue,".  Backup file ",build(dbfc_dest_dir,
        "/",dbfc_dest_fname)," does not exist.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_backup_reg_content_load(null)
   DECLARE dbrcl_token_prefix = vc WITH protect, noconstant("")
   DECLARE dbrcl_domain = vc WITH protect, noconstant("")
   DECLARE dbrcl_temp_dir = vc WITH protect, noconstant("")
   DECLARE dbrcl_env = vc WITH protect, noconstant("")
   DECLARE dbrcl_file = vc WITH protect, noconstant(build(dm2_install_schema->cer_install,
     "dm2_rr_backup_reg_content.csv"))
   DECLARE dbrcl_cust_file = vc WITH protect, noconstant(build(dm2_install_schema->cer_install,
     "dm2_rr_backup_reg_content_<env>.csv"))
   DECLARE dbrcl_work_file = vc WITH protect, noconstant("")
   DECLARE dbrcl_file_cnt = i2 WITH protect, noconstant(1)
   DECLARE dbrcl_cntr = i2 WITH protect, noconstant(0)
   DECLARE dbrcl_str = vc WITH protect, noconstant("")
   DECLARE dbrcl_orig_str = vc WITH protect, noconstant("")
   DECLARE dbrcl_token = vc WITH protect, noconstant("")
   DECLARE dbrcl_mode = vc WITH protect, noconstant("")
   DECLARE dbrcl_key = vc WITH protect, noconstant("")
   DECLARE dbrcl_orig_key = vc WITH protect, noconstant("")
   DECLARE dbrcl_prop = vc WITH protect, noconstant("")
   DECLARE dbrcl_orig_prop = vc WITH protect, noconstant("")
   DECLARE dbrcl_dest_dir = vc WITH protect, noconstant("")
   DECLARE dbrcl_dest_fname = vc WITH protect, noconstant("")
   DECLARE dbrcl_orig_dest_fname = vc WITH protect, noconstant("")
   DECLARE dbrcl_cre_key_ind = vc WITH protect, noconstant("")
   DECLARE dbrcl_req_ind = vc WITH protect, noconstant("")
   DECLARE dbrcl_active_ind = vc WITH protect, noconstant("")
   DECLARE dbrcl_fatal_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dbrcl_fatal_str = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    RETURN(1)
   ENDIF
   SET dbrcl_token_prefix = "TGT"
   SET dbrcl_domain = ddr_domain_data->tgt_domain_name
   SET dbrcl_temp_dir = ddr_domain_data->tgt_tmp_full_dir
   SET dbrcl_env = ddr_domain_data->tgt_env
   IF (substring(size(dbrcl_temp_dir),1,dbrcl_temp_dir)="/")
    SET dbrcl_temp_dir = trim(replace(dbrcl_temp_dir,"/","",2),3)
   ENDIF
   SET dbrcl_cust_file = replace(dbrcl_cust_file,"<env>",dbrcl_env,0)
   IF (dm2_findfile(dbrcl_cust_file) > 0)
    SET dbrcl_file_cnt = (dbrcl_file_cnt+ 1)
   ENDIF
   FOR (dbrcl_cntr = 1 TO dbrcl_file_cnt)
     IF (dbrcl_cntr=1)
      SET dbrcl_work_file = dbrcl_file
     ELSE
      SET dbrcl_work_file = dbrcl_cust_file
     ENDIF
     SET dm_err->eproc = concat("Open ",dbrcl_work_file," and load backend file content.")
     CALL disp_msg("",dm_err->logfile,0)
     FREE SET dbrcl_data_file
     SET logical dbrcl_data_file dbrcl_work_file
     FREE DEFINE rtl3
     DEFINE rtl3 "dbrcl_data_file"
     SELECT INTO "nl:"
      t.line
      FROM rtl3t t
      WHERE t.line > " "
      DETAIL
       IF (dbrcl_fatal_err_ind=0)
        dbrcl_str = trim(t.line,3), dbrcl_orig_str = dbrcl_str
        IF ((dm_err->debug_flag > 4))
         CALL echo(concat("line = ",dbrcl_str))
        ENDIF
        IF (substring(1,3,dbrcl_str)=dbrcl_token_prefix)
         dbrcl_str = replace(dbrcl_str,"<<domain>>",dbrcl_domain,0), dbrcl_str = replace(dbrcl_str,
          "<<temp_full_dir>>",dbrcl_temp_dir,0), dbrcl_str = replace(dbrcl_str,"<<node>>",trim(
           cnvtlower(curnode),3),0),
         dbrcl_str = replace(dbrcl_str,"<<env>>",dbrcl_env,0)
         IF ((dm_err->debug_flag > 4))
          CALL echo(concat("line_w_tokens_replaced = ",dbrcl_str))
         ENDIF
         dbrcl_token = trim(piece(dbrcl_str,",",1,"Not Found"),3), dbrcl_mode = trim(piece(dbrcl_str,
           ",",2,"Not Found"),3), dbrcl_key = trim(piece(dbrcl_str,",",3,"Not Found"),3),
         dbrcl_prop = trim(piece(dbrcl_str,",",4,"Not Found"),3), dbrcl_dest_dir = trim(piece(
           dbrcl_str,",",5,"Not Found"),3), dbrcl_orig_dest_fname = trim(piece(dbrcl_orig_str,",",6,
           "Not Found"),3),
         dbrcl_dest_fname = trim(piece(dbrcl_str,",",6,"Not Found"),3), dbrcl_req_ind = trim(piece(
           dbrcl_str,",",7,"Not Found"),3), dbrcl_cre_key_ind = trim(piece(dbrcl_str,",",8,
           "Not Found"),3),
         dbrcl_active_ind = trim(piece(dbrcl_str,",",9,"Not Found"),3)
         IF ((dm_err->debug_flag > 4))
          CALL echo(concat("token = ",dbrcl_token)),
          CALL echo(concat("mode = ",dbrcl_mode)),
          CALL echo(concat("key = ",dbrcl_key)),
          CALL echo(concat("prop = ",dbrcl_prop)),
          CALL echo(concat("dest_dir = ",dbrcl_dest_dir)),
          CALL echo(concat("dest_fname = ",dbrcl_dest_fname)),
          CALL echo(concat("req_ind = ",dbrcl_req_ind)),
          CALL echo(concat("cre_key_ind = ",dbrcl_cre_key_ind)),
          CALL echo(concat("active_ind = ",dbrcl_active_ind))
         ENDIF
         IF (dbrcl_mode="GET"
          AND dbrcl_key != "Not Found"
          AND textlen(dbrcl_key) > 0
          AND dbrcl_prop != "Not Found"
          AND textlen(dbrcl_prop) > 0
          AND dbrcl_dest_dir != "Not Found"
          AND textlen(dbrcl_dest_dir) > 0
          AND findstring(" ",dbrcl_dest_dir,1)=0
          AND substring(1,size(dbrcl_temp_dir),dbrcl_dest_dir)=dbrcl_temp_dir
          AND dbrcl_dest_fname != "Not Found"
          AND textlen(dbrcl_dest_fname) > 0
          AND findstring(" ",dbrcl_dest_fname,1)=0
          AND dbrcl_orig_dest_fname != "Not Found"
          AND textlen(dbrcl_orig_dest_fname) > 0
          AND findstring(" ",dbrcl_orig_dest_fname,1)=0
          AND findstring("<<",dbrcl_orig_dest_fname,1)=0
          AND findstring(">>",dbrcl_orig_dest_fname,1)=0
          AND dbrcl_req_ind IN ("0", "1")
          AND dbrcl_cre_key_ind IN ("0", "1")
          AND dbrcl_active_ind IN ("0", "1"))
          IF (dbrcl_token_prefix="TGT"
           AND dbrcl_active_ind="1")
           ddr_backup_reg_content->tgt_backup_list_cnt = (ddr_backup_reg_content->tgt_backup_list_cnt
           + 1), stat = alterlist(ddr_backup_reg_content->tgt_backup_list,ddr_backup_reg_content->
            tgt_backup_list_cnt), ddr_backup_reg_content->tgt_backup_list[ddr_backup_reg_content->
           tgt_backup_list_cnt].token = dbrcl_token,
           ddr_backup_reg_content->tgt_backup_list[ddr_backup_reg_content->tgt_backup_list_cnt].mode
            = dbrcl_mode, ddr_backup_reg_content->tgt_backup_list[ddr_backup_reg_content->
           tgt_backup_list_cnt].key = dbrcl_key, ddr_backup_reg_content->tgt_backup_list[
           ddr_backup_reg_content->tgt_backup_list_cnt].prop = dbrcl_prop,
           ddr_backup_reg_content->tgt_backup_list[ddr_backup_reg_content->tgt_backup_list_cnt].
           dest_dir = dbrcl_dest_dir, ddr_backup_reg_content->tgt_backup_list[ddr_backup_reg_content
           ->tgt_backup_list_cnt].dest_fname = dbrcl_dest_fname, ddr_backup_reg_content->
           tgt_backup_list[ddr_backup_reg_content->tgt_backup_list_cnt].cre_key_ind = cnvtint(
            dbrcl_cre_key_ind),
           ddr_backup_reg_content->tgt_backup_list[ddr_backup_reg_content->tgt_backup_list_cnt].
           req_ind = cnvtint(dbrcl_req_ind)
          ENDIF
         ELSE
          dbrcl_fatal_str = trim(dbrcl_str), dbrcl_fatal_err_ind = 1
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (dbrcl_fatal_err_ind=1)
      SET dm_err->emsg = concat("One or more fields for record in csv is invalid (",trim(
        dbrcl_fatal_str),").")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(ddr_backup_reg_content)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_backup_reg_content(dbrc_mode,dbrc_key,dbrc_prop,dbrc_dest_dir,dbrc_dest_fname,
  dbrc_req_ind,dbrc_cre_key_ind)
   DECLARE dbrc_dir_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dbrc_cmd = vc WITH protect, noconstant(" ")
   DECLARE dbrc_ret = vc WITH protect, noconstant("")
   DECLARE dbrc_bckup_file = vc WITH protect, noconstant(" ")
   DECLARE dbrc_reg_file = vc WITH protect, noconstant("dm2_get_reg_prop")
   DECLARE dbrc_no_error = i2 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os != "LNX"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Backup registry content where mode is (",dbrc_mode,"), key is (",
    dbrc_key,") and prop is (",
    dbrc_prop,").")
   CALL disp_msg("",dm_err->logfile,0)
   SET dbrc_dir_found_ind = 0
   SET dbrc_dir_found_ind = dm2_find_dir(dbrc_dest_dir)
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   IF (dbrc_dir_found_ind=0)
    SET dm_err->eproc = concat("Creating destination directory (",build(dbrc_dest_dir),
     ") and opening permissions.")
    CALL disp_msg("",dm_err->logfile,0)
    SET dbrc_cmd = concat("mkdir -p ",dbrc_dest_dir)
    IF (dm2_push_dcl(dbrc_cmd)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dbrc_cmd = concat("chmod 777 ",dbrc_dest_dir)
   IF (dm2_push_dcl(dbrc_cmd)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Verifying existence of destination file ",build(dbrc_dest_dir,"/",
     dbrc_dest_fname),".")
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm2_findfile(build(dbrc_dest_dir,"/",dbrc_dest_fname)) > 0)
    IF (dm2_push_dcl(concat("rm ",build(dbrc_dest_dir,"/",dbrc_dest_fname)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Check for ",trim(dbrc_key)," key and ",trim(dbrc_prop)," property.")
   CALL disp_msg("",dm_err->logfile,0)
   IF (get_unique_file(dbrc_reg_file,".ksh")=0)
    RETURN(0)
   ENDIF
   SET dbrc_reg_file = dm_err->unique_fname
   SET dm_err->eproc = concat("Create file get registry value: ",dbrc_reg_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dbrc_reg_file)
    DETAIL
     CALL print(concat("$cer_exe/lreg -getp ",trim(dbrc_key)," ",trim(dbrc_prop))), row + 1
    WITH nocounter, maxcol = 2000, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgfd_cmd = concat(". $CCLUSERDIR/",dbrc_reg_file)
   SET dm_err->disp_dcl_err_ind = 0
   SET dbrc_no_error = dm2_push_dcl(dgfd_cmd)
   IF (dbrc_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
    ENDIF
   ENDIF
   IF (((findstring("unable",dm_err->errtext,1,1)) OR (((findstring("key not found",dm_err->errtext,1,
    1)) OR (findstring("property not found",dm_err->errtext,1,1))) )) )
    IF ((dm_err->errtext=""))
     SET dbrc_no_error = 1
     SET dbrc_ret = ""
    ELSE
     SET dbrc_no_error = 1
     SET dbrc_ret = "NOPARMRETURNED"
    ENDIF
   ELSE
    SET dbrc_ret = dm_err->errtext
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("parm_value: <<",dbrc_ret,">>"))
   ENDIF
   IF (dbrc_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dbrc_ret="NOPARMRETURNED")
    IF (dbrc_req_ind=1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Check for ",trim(dbrc_key)," key and ",trim(dbrc_prop)," property.")
     SET dm_err->emsg = "Property not found."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dm_err->eproc = concat(trim(dbrc_key)," key and ",trim(dbrc_prop),
      " property not found and backup of content not required.")
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   SET dbrc_ret = evaluate(findstring(" ",dbrc_ret,1),0,dbrc_ret,build('"',dbrc_ret,'"'))
   SET dm_err->eproc = concat("Validating existence of destination directory (",build(dbrc_dest_dir),
    ").")
   CALL disp_msg("",dm_err->logfile,0)
   SET dbrc_bckup_file = build(dbrc_dest_dir,"/",dbrc_dest_fname)
   SET dm_err->eproc = concat("Create file for copy registry operations: ",dbrc_bckup_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dbrc_bckup_file)
    DETAIL
     IF (dbrc_cre_key_ind=1)
      CALL print(concat("$cer_exe/lreg -crek ",dbrc_key)), row + 1
     ENDIF
     CALL print(concat("$cer_exe/lreg -setp ",dbrc_key," ",evaluate(findstring(" ",dbrc_prop,1),0,
       dbrc_prop,build('"',dbrc_prop,'"'))," ",
      dbrc_ret)), row + 1
    WITH nocounter, maxcol = 2000, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_restore_reg_content(null)
   DECLARE drrc_idx = i4 WITH protect, noconstant(0)
   DECLARE drrc_cmd = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    RETURN(1)
   ENDIF
   IF (ddr_backup_reg_content_load(null)=0)
    RETURN(0)
   ENDIF
   IF ((ddr_backup_reg_content->tgt_backup_list_cnt > 0))
    FOR (drrc_idx = 1 TO ddr_backup_reg_content->tgt_backup_list_cnt)
      SET dm_err->eproc = concat("Verifying existence of ",build(ddr_backup_reg_content->
        tgt_backup_list[drrc_idx].dest_dir,"/",ddr_backup_reg_content->tgt_backup_list[drrc_idx].
        dest_fname),".")
      CALL disp_msg("",dm_err->logfile,0)
      IF (dm2_findfile(build(ddr_backup_reg_content->tgt_backup_list[drrc_idx].dest_dir,"/",
        ddr_backup_reg_content->tgt_backup_list[drrc_idx].dest_fname)) > 0)
       SET dm_err->eproc = concat("Execute ksh ",build(ddr_backup_reg_content->tgt_backup_list[
         drrc_idx].dest_dir,"/",ddr_backup_reg_content->tgt_backup_list[drrc_idx].dest_fname),
        " to restore registry content.")
       CALL disp_msg(" ",dm_err->logfile,0)
       SET drrc_cmd = concat(". ",build(ddr_backup_reg_content->tgt_backup_list[drrc_idx].dest_dir,
         "/",ddr_backup_reg_content->tgt_backup_list[drrc_idx].dest_fname))
       IF (dm2_push_dcl(drrc_cmd)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_backup_srvreg_content_load(null)
   DECLARE dbscl_token_prefix = vc WITH protect, noconstant("")
   DECLARE dbscl_domain = vc WITH protect, noconstant("")
   DECLARE dbscl_temp_dir = vc WITH protect, noconstant("")
   DECLARE dbscl_env = vc WITH protect, noconstant("")
   DECLARE dbscl_file = vc WITH protect, noconstant(build(dm2_install_schema->cer_install,
     "dm2_rr_backup_srvreg_content.csv"))
   DECLARE dbscl_cust_file = vc WITH protect, noconstant(build(dm2_install_schema->cer_install,
     "dm2_rr_backup_srvreg_content_<env>.csv"))
   DECLARE dbscl_work_file = vc WITH protect, noconstant("")
   DECLARE dbscl_file_cnt = i2 WITH protect, noconstant(1)
   DECLARE dbscl_cntr = i2 WITH protect, noconstant(0)
   DECLARE dbscl_str = vc WITH protect, noconstant("")
   DECLARE dbscl_orig_str = vc WITH protect, noconstant("")
   DECLARE dbscl_token = vc WITH protect, noconstant("")
   DECLARE dbscl_mode = vc WITH protect, noconstant("")
   DECLARE dbscl_entry = vc WITH protect, noconstant("")
   DECLARE dbscl_dest_dir = vc WITH protect, noconstant("")
   DECLARE dbscl_dest_fname = vc WITH protect, noconstant("")
   DECLARE dbscl_orig_dest_fname = vc WITH protect, noconstant("")
   DECLARE dbscl_req_ind = vc WITH protect, noconstant("")
   DECLARE dbscl_options = vc WITH protect, noconstant("")
   DECLARE dbscl_active_ind = vc WITH protect, noconstant("")
   DECLARE dbscl_fatal_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dbscl_fatal_str = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    RETURN(1)
   ENDIF
   SET dbscl_token_prefix = "TGT"
   SET dbscl_domain = ddr_domain_data->tgt_domain_name
   SET dbscl_temp_dir = ddr_domain_data->tgt_tmp_full_dir
   SET dbscl_env = ddr_domain_data->tgt_env
   IF (substring(size(dbscl_temp_dir),1,dbscl_temp_dir)="/")
    SET dbscl_temp_dir = trim(replace(dbscl_temp_dir,"/","",2),3)
   ENDIF
   SET dbscl_cust_file = replace(dbscl_cust_file,"<env>",dbscl_env,0)
   IF (dm2_findfile(dbscl_cust_file) > 0)
    SET dbscl_file_cnt = (dbscl_file_cnt+ 1)
   ENDIF
   FOR (dbscl_cntr = 1 TO dbscl_file_cnt)
     IF (dbscl_cntr=1)
      SET dbscl_work_file = dbscl_file
     ELSE
      SET dbscl_work_file = dbscl_cust_file
     ENDIF
     SET dm_err->eproc = concat("Open ",dbscl_work_file," and load backend file content.")
     CALL disp_msg("",dm_err->logfile,0)
     FREE SET dbscl_data_file
     SET logical dbscl_data_file dbscl_work_file
     FREE DEFINE rtl3
     DEFINE rtl3 "dbscl_data_file"
     SELECT INTO "nl:"
      t.line
      FROM rtl3t t
      WHERE t.line > " "
      DETAIL
       IF (dbscl_fatal_err_ind=0)
        dbscl_str = trim(t.line,3), dbscl_orig_str = dbscl_str
        IF ((dm_err->debug_flag > 4))
         CALL echo(concat("line = ",dbscl_str))
        ENDIF
        IF (substring(1,3,dbscl_str)=dbscl_token_prefix)
         dbscl_str = replace(dbscl_str,"<<domain>>",dbscl_domain,0), dbscl_str = replace(dbscl_str,
          "<<temp_full_dir>>",dbscl_temp_dir,0), dbscl_str = replace(dbscl_str,"<<node>>",trim(
           cnvtlower(curnode),3),0),
         dbscl_str = replace(dbscl_str,"<<env>>",dbscl_env,0)
         IF ((dm_err->debug_flag > 4))
          CALL echo(concat("line_w_tokens_replaced = ",dbscl_str))
         ENDIF
         dbscl_token = trim(piece(dbscl_str,",",1,"Not Found"),3), dbscl_mode = trim(piece(dbscl_str,
           ",",2,"Not Found"),3), dbscl_entry = trim(piece(dbscl_str,",",3,"Not Found"),3),
         dbscl_dest_dir = trim(piece(dbscl_str,",",4,"Not Found"),3), dbscl_dest_fname = trim(piece(
           dbscl_str,",",5,"Not Found"),3), dbscl_options = trim(piece(dbscl_str,",",6,"Not Found"),3
          ),
         dbscl_req_ind = trim(piece(dbscl_str,",",7,"Not Found"),3), dbscl_active_ind = trim(piece(
           dbscl_str,",",8,"Not Found"),3)
         IF ((dm_err->debug_flag > 4))
          CALL echo(concat("token = ",dbscl_token)),
          CALL echo(concat("mode = ",dbscl_mode)),
          CALL echo(concat("entry = ",dbscl_entry)),
          CALL echo(concat("dest_dir = ",dbscl_dest_dir)),
          CALL echo(concat("dest_fname = ",dbscl_dest_fname)),
          CALL echo(concat("orig_dest_fname = ",dbscl_orig_dest_fname)),
          CALL echo(concat("options = ",dbscl_options)),
          CALL echo(concat("req_ind = ",dbscl_req_ind)),
          CALL echo(concat("active_ind = ",dbscl_active_ind))
         ENDIF
         IF (dbscl_mode="EXPORT"
          AND dbscl_entry != "Not Found"
          AND textlen(dbscl_entry) > 0
          AND dbscl_dest_dir != "Not Found"
          AND textlen(dbscl_dest_dir) > 0
          AND findstring(" ",dbscl_dest_dir,1)=0
          AND substring(1,size(dbscl_temp_dir),dbscl_dest_dir)=dbscl_temp_dir
          AND dbscl_dest_fname != "Not Found"
          AND textlen(dbscl_dest_fname) > 0
          AND findstring(" ",dbscl_dest_fname,1)=0
          AND dbscl_orig_dest_fname != "Not Found"
          AND textlen(dbscl_orig_dest_fname) > 0
          AND findstring(" ",dbscl_orig_dest_fname,1)=0
          AND findstring("<<",dbscl_orig_dest_fname,1)=0
          AND findstring(">>",dbscl_orig_dest_fname,1)=0
          AND ((substring(1,1,dbscl_options)="-") OR (dbscl_options="none"))
          AND dbscl_req_ind IN ("0", "1")
          AND dbscl_active_ind IN ("0", "1"))
          IF (dbscl_token_prefix="TGT"
           AND dbscl_active_ind="1")
           ddr_backup_srvreg_content->tgt_backup_list_cnt = (ddr_backup_srvreg_content->
           tgt_backup_list_cnt+ 1), stat = alterlist(ddr_backup_srvreg_content->tgt_backup_list,
            ddr_backup_srvreg_content->tgt_backup_list_cnt), ddr_backup_srvreg_content->
           tgt_backup_list[ddr_backup_srvreg_content->tgt_backup_list_cnt].token = dbscl_token,
           ddr_backup_srvreg_content->tgt_backup_list[ddr_backup_srvreg_content->tgt_backup_list_cnt]
           .mode = dbscl_mode, ddr_backup_srvreg_content->tgt_backup_list[ddr_backup_srvreg_content->
           tgt_backup_list_cnt].entry = dbscl_entry, ddr_backup_srvreg_content->tgt_backup_list[
           ddr_backup_srvreg_content->tgt_backup_list_cnt].dest_dir = dbscl_dest_dir,
           ddr_backup_srvreg_content->tgt_backup_list[ddr_backup_srvreg_content->tgt_backup_list_cnt]
           .dest_fname = dbscl_dest_fname, ddr_backup_srvreg_content->tgt_backup_list[
           ddr_backup_srvreg_content->tgt_backup_list_cnt].options = dbscl_options,
           ddr_backup_srvreg_content->tgt_backup_list[ddr_backup_srvreg_content->tgt_backup_list_cnt]
           .req_ind = cnvtint(dbscl_req_ind)
          ENDIF
         ELSE
          dbscl_fatal_str = trim(dbscl_str), dbscl_fatal_err_ind = 1
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (dbscl_fatal_err_ind=1)
      SET dm_err->emsg = concat("One or more fields for record in csv is invalid (",trim(
        dbscl_fatal_str),").")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(ddr_backup_srvreg_content)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_backup_srvreg_content(dbsc_mode,dbsc_entry,dbsc_dest_dir,dbsc_dest_fname,dbsc_options,
  dbsc_req_ind)
   DECLARE dbsc_dir_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dbsc_cmd = vc WITH protect, noconstant(" ")
   DECLARE dbsc_file = vc WITH protect, noconstant("dm2_bkup_regsrv")
   IF ((dm2_sys_misc->cur_os != "LNX"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Backup server registry content where mode is (",dbsc_mode,
    "), entry is (",dbsc_entry,").")
   CALL disp_msg("",dm_err->logfile,0)
   SET dbsc_dir_found_ind = 0
   SET dbsc_dir_found_ind = dm2_find_dir(dbsc_dest_dir)
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   IF (dbsc_dir_found_ind=0)
    SET dm_err->eproc = concat("Creating destination directory (",build(dbsc_dest_dir),
     ") and opening permissions.")
    CALL disp_msg("",dm_err->logfile,0)
    SET dbsc_cmd = concat("mkdir -p ",dbsc_dest_dir)
    IF (dm2_push_dcl(dbsc_cmd)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dbsc_cmd = concat("chmod 777 ",dbsc_dest_dir)
   IF (dm2_push_dcl(dbsc_cmd)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Verifying existence of destination file ",build(dbsc_dest_dir,"/",
     dbsc_dest_fname),".")
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm2_findfile(build(dbsc_dest_dir,"/",dbsc_dest_fname)) > 0)
    IF (dm2_push_dcl(concat("rm ",build(dbsc_dest_dir,"/",dbsc_dest_fname)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (get_unique_file(dbsc_file,".ksh")=0)
    RETURN(0)
   ENDIF
   SET dbsc_file = dm_err->unique_fname
   SET dm_err->eproc = concat("Create file to backup specific server definitions: ",dbsc_file)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dbsc_file)
    DETAIL
     CALL print(concat("tgt_mng_pwd='",ddr_domain_data->tgt_mng_pwd,"'")), row + 1,
     CALL print(concat("$cer_exe/scpview ",trim(cnvtlower(curnode))," <<!")),
     row + 1,
     CALL print(ddr_domain_data->tgt_mng), row + 1,
     CALL print(ddr_domain_data->tgt_domain_name), row + 1,
     CALL print("$tgt_mng_pwd"),
     row + 1,
     CALL print(concat(dbsc_mode," ",build(dbsc_dest_dir,"/",dbsc_dest_fname)," ",dbsc_entry,
      " ",trim(evaluate(dbsc_options,"none","",dbsc_options),3))), row + 1,
     CALL print("exit"), row + 1,
     CALL print("!"),
     row + 1
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute ksh (",dbsc_file,
    ") to backup server registry content where mode is (",dbsc_mode,"), entry is (",
    dbsc_entry,").")
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dbsc_cmd = concat(". $CCLUSERDIR/",dbsc_file)
   IF (dm2_push_dcl(dbsc_cmd)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dm_err)
   ENDIF
   IF (((findstring("bad command",dm_err->errtext,1,1) > 0) OR (findstring(
    "node not offering services",dm_err->errtext,1,1) > 0)) )
    SET dm_err->emsg = concat("Error exporting server definitions: ",dbsc_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_findfile(build(dbsc_dest_dir,"/",dbsc_dest_fname))=0)
    IF (dbsc_req_ind=1)
     SET dm_err->eproc = concat("Validating registry server content for (",dbsc_mode,") of entry (",
      dbsc_entry,").")
     SET dm_err->emsg = concat("File (",build(dbsc_dest_dir,"/",dbsc_dest_fname),") not found.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dm_err->eproc = concat("Backup file for registry server content for (",dbsc_mode,
      ") of entry (",dbsc_entry,") not found and backup of content not required.")
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddr_val_client_mnemonic(dvcm_src_ind,dvcm_tgt_ind,dvcm_inform_only_ind,
  dvcm_invalid_data_ind)
   DECLARE dvcm_rf_client_mnemonic = vc WITH protect, noconstant(drrr_rf_data->client_mnemonic)
   DECLARE dvcm_reg_path = vc WITH protect, noconstant("")
   DECLARE dvcm_reg_val = vc WITH protect, noconstant("")
   DECLARE dvcm_dm_info_val = vc WITH protect, noconstant("")
   DECLARE dvcm_logical_val = vc WITH protect, noconstant("")
   DECLARE dvcm_msg = vc WITH protect, noconstant("")
   DECLARE dvcm_invalid_reg_ind = i2 WITH protect, noconstant(0)
   DECLARE dvcm_invalid_dm_info_ind = i2 WITH protect, noconstant(0)
   DECLARE dvcm_invalid_logical_ind = i2 WITH protect, noconstant(0)
   SET dvcm_invalid_data_ind = 0
   IF (((dvcm_src_ind=0
    AND dvcm_tgt_ind=0) OR (dvcm_src_ind=1
    AND dvcm_tgt_ind=1)) )
    SET dm_err->eproc = "Validating input indicators."
    SET dm_err->emsg =
    "Invalid input combination.  Need to specifiy either source or target indicator and not both."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dvcm_src_ind=1
    AND validate(dm2_bypass_src_val_client_mnemonic,- (1))=1) OR (dvcm_tgt_ind=1
    AND validate(dm2_bypass_tgt_val_client_mnemonic,- (1))=1)) )
    SET dm_err->eproc = concat("Bypassing validation of client mnemonic for ",evaluate(dvcm_src_ind,1,
      "SOURCE","TARGET"),".")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dvcm_reg_path = "\\definitions\\aixrs6000\\Environment\\ CLIENT_MNEMONIC"
   ELSEIF ((dm2_sys_misc->cur_os="LNX"))
    SET dvcm_reg_path = "\\definitions\\linuxx86-64\\Environment\\ CLIENT_MNEMONIC"
   ELSE
    RETURN(1)
   ENDIF
   SET dm_err->eproc =
   "Verifying if client mnemonic value in the response file matches the value in the registry."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (ddr_lreg_oper("GET",dvcm_reg_path,dvcm_reg_val)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("CLIENT_MNEMONIC in registry: ",dvcm_reg_val))
   ENDIF
   IF (cnvtupper(dvcm_rf_client_mnemonic) != cnvtupper(dvcm_reg_val))
    IF (dvcm_src_ind=1)
     SET dvcm_invalid_reg_ind = 1
    ELSE
     IF (ddr_lreg_oper("SET",concat(dvcm_reg_path," ",dvcm_rf_client_mnemonic),dvcm_reg_val)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc =
   "Verifying if client mnemonic value in the response file matches the value in DM_INFO."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="CLIENT MNEMONIC"
    DETAIL
     dvcm_dm_info_val = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("CLIENT_MNEMONIC in DM_INFO: ",dvcm_dm_info_val))
   ENDIF
   IF (cnvtupper(dvcm_rf_client_mnemonic) != dvcm_dm_info_val)
    IF (dvcm_src_ind=1)
     SET dvcm_invalid_dm_info_ind = 1
    ELSE
     SET dm_err->eproc =
     "Inserting/Updating client mnemonic value in DM_INFO with the response file value."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     MERGE INTO dm_info di
     USING DUAL ON (di.info_domain="DATA MANAGEMENT"
      AND di.info_name="CLIENT MNEMONIC")
     WHEN MATCHED THEN
     (UPDATE
      SET di.info_char = cnvtupper(dvcm_rf_client_mnemonic), di.updt_dt_tm = cnvtdatetime(curdate,
        curtime3)
      WHERE 1=1
     ;end update
     )
     WHEN NOT MATCHED THEN
     (INSERT  FROM di
      (di.info_domain, di.info_name, di.info_char,
      di.updt_dt_tm)
      VALUES("DATA MANAGEMENT", "CLIENT MNEMONIC", cnvtupper(dvcm_rf_client_mnemonic),
      cnvtdatetime(curdate,curtime3))
      WITH nocounter
     ;end insert
     )
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc =
   "Verifying if client mnemonic value in the response file matches the logical value."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dvcm_logical_val = logical("client_mnemonic")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("CLIENT_MNEMONIC in logical (local): ",dvcm_logical_val))
   ENDIF
   IF (cnvtupper(dvcm_rf_client_mnemonic) != cnvtupper(dvcm_logical_val)
    AND dvcm_src_ind=1)
    SET dvcm_invalid_logical_ind = 1
   ENDIF
   IF (((dvcm_invalid_reg_ind=1) OR (((dvcm_invalid_dm_info_ind=1) OR (dvcm_invalid_logical_ind=1))
   )) )
    SET dvcm_msg = concat(
     "Client mnemonic value is invalid at the following locations when compared ",
     "against the response file(",dvcm_rf_client_mnemonic,"):")
    IF (dvcm_invalid_reg_ind=1)
     SET dvcm_msg = concat(dvcm_msg," Registry(",dvcm_reg_val,"),")
    ENDIF
    IF (dvcm_invalid_dm_info_ind=1)
     SET dvcm_msg = concat(dvcm_msg," DM_INFO(",dvcm_dm_info_val,"),")
    ENDIF
    IF (dvcm_invalid_logical_ind=1)
     SET dvcm_msg = concat(dvcm_msg," Logical(",dvcm_logical_val,").")
    ENDIF
    IF (findstring(",",dvcm_msg,1,1)=textlen(dvcm_msg))
     SET dvcm_msg = replace(dvcm_msg,",",".",2)
    ENDIF
    IF (dvcm_inform_only_ind=1)
     SET dvcm_invalid_data_ind = 1
     SET dm_err->eproc = dvcm_msg
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc =
     "Validating client mnemonic value from the registry against the response file."
     SET dm_err->emsg = dvcm_msg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
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
 DECLARE drer_email_setup(des_src_env=vc,des_tgt_env=vc) = i2
 DECLARE drer_fill_email_list(dfel_src_env=vc,dfel_tgt_env=vc) = i2
 DECLARE drer_compose_email(null) = i2
 DECLARE drer_send_email(dse_subject=vc,dse_file_name=vc,dse_level=i4) = i2
 DECLARE drer_send_test_emails(dste_level=i4) = i2
 DECLARE drer_add_body_text(dabt_in_text=vc,dabt_in_reset_ind=i2) = null
 DECLARE drer_reset_pre_err(null) = null
 DECLARE drer_get_client(null) = i2
 DECLARE drer_redhat_version(null) = i2
 IF ((validate(drer_email_list->level_cnt,- (99))=- (99))
  AND validate(drer_email_list->level_cnt,99)=99)
  FREE RECORD drer_email_list
  RECORD drer_email_list(
    1 max_email_level = i4
    1 email_cnt = i4
    1 change_ind = i2
    1 email[*]
      2 address = vc
      2 level = i4
    1 level_cnt = i4
    1 email_level[*]
      2 level = i4
      2 email_list = vc
  )
  SET drer_email_list->max_email_level = 2
 ENDIF
 IF ((validate(drer_email_det->email_level,- (99))=- (99))
  AND validate(drer_email_det->email_level,99)=99)
  FREE RECORD drer_email_det
  RECORD drer_email_det(
    1 subject = vc
    1 process = vc
    1 msgtype = vc
    1 status = vc
    1 status_dt_tm = f8
    1 client = vc
    1 src_env = vc
    1 src_node = vc
    1 tgt_env = vc
    1 tgt_node = vc
    1 step = vc
    1 email_level = i4
    1 file_name = vc
    1 component_name = vc
    1 eproc = vc
    1 err_ind = i2
    1 emsg = vc
    1 user_action = vc
    1 logfile = vc
    1 restart_ind = i2
    1 body_cnt = i4
    1 body[*]
      2 txt = vc
    1 attachment = vc
  )
  SET drer_email_det->subject = "DM2NOTSET"
  SET drer_email_det->process = "DM2NOTSET"
  SET drer_email_det->msgtype = "DM2NOTSET"
  SET drer_email_det->status = "DM2NOTSET"
  SET drer_email_det->client = "DM2NOTSET"
  SET drer_email_det->src_env = "DM2NOTSET"
  SET drer_email_det->src_node = "DM2NOTSET"
  SET drer_email_det->tgt_env = "DM2NOTSET"
  SET drer_email_det->tgt_node = "DM2NOTSET"
  SET drer_email_det->step = "DM2NOTSET"
  SET drer_email_det->file_name = "DM2NOTSET"
  SET drer_email_det->component_name = "DM2NOTSET"
  SET drer_email_det->eproc = "DM2NOTSET"
  SET drer_email_det->emsg = "DM2NOTSET"
  SET drer_email_det->user_action = "DM2NOTSET"
  SET drer_email_det->logfile = "DM2NOTSET"
  SET drer_email_det->attachment = "DM2NOTSET"
 ENDIF
 SUBROUTINE drer_email_setup(des_src_env,des_tgt_env)
   DECLARE des_iter = i4 WITH protect, noconstant(0)
   DECLARE des_index = i4 WITH protect, noconstant(0)
   DECLARE des_remove_location = i4 WITH protect, noconstant(0)
   DECLARE des_level = i4 WITH protect, noconstant(0)
   DECLARE des_working = i2 WITH protect, noconstant(0)
   DECLARE des_pre_max_level = i4 WITH protect, noconstant(0)
   DECLARE des_help_str = vc WITH protect, noconstant(" ")
   IF (drer_fill_email_list(des_src_env,des_tgt_env)=0)
    RETURN(0)
   ENDIF
   FOR (des_iter = 1 TO drer_email_list->max_email_level)
     IF ((des_iter=drer_email_list->max_email_level))
      SET des_help_str = concat(des_help_str,trim(cnvtstring(des_iter)))
     ELSE
      SET des_help_str = concat(des_help_str,trim(cnvtstring(des_iter)),",")
     ENDIF
   ENDFOR
   WHILE (true)
     SET width = 132
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Setup Email Addresses")
     IF ((drer_email_list->email_cnt > 0))
      CALL text(4,4,"EMAIL ADDRESS")
      CALL text(4,80,"EMAIL LEVEL")
      FOR (des_index = 1 TO least(15,drer_email_list->email_cnt))
       CALL text((5+ des_index),4,concat(build(des_index),".  ",drer_email_list->email[des_index].
         address))
       CALL text((5+ des_index),80,trim(cnvtstring(drer_email_list->email[des_index].level)))
      ENDFOR
     ENDIF
     CALL clear(23,2,129)
     IF ((drer_email_list->email_cnt=0))
      CALL text(23,2,"(A)dd new email address, (S)ave, (Q)uit: ")
      CALL accept(23,80,"A;CU"," "
       WHERE curaccept IN ("A", "S", "Q"))
     ELSEIF ((drer_email_list->email_cnt < 15))
      IF ((drer_email_list->change_ind=0))
       CALL text(23,2,concat("(A)dd new email address, (R)emove existing email address, (S)ave,",
         " (T)est email addresses, (Q)uit: "))
       CALL accept(23,124,"A;CU"," "
        WHERE curaccept IN ("A", "R", "S", "T", "Q"))
      ELSE
       CALL text(23,2,concat("(A)dd new email address, (R)emove existing email address, (S)ave,",
         " (Q)uit: "))
       CALL accept(23,124,"A;CU"," "
        WHERE curaccept IN ("A", "R", "S", "Q"))
      ENDIF
     ELSE
      IF ((drer_email_list->change_ind=0))
       CALL text(23,2,"(R)emove existing email address, (S)ave, (T)est email addresses, (Q)uit: ")
       CALL accept(23,99,"A;CU"," "
        WHERE curaccept IN ("R", "S", "T", "Q"))
      ELSE
       CALL text(23,2,"(R)emove existing email address, (S)ave, (Q)uit: ")
       CALL accept(23,99,"A;CU"," "
        WHERE curaccept IN ("R", "S", "Q"))
      ENDIF
     ENDIF
     CASE (curaccept)
      OF "A":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Add:")
       CALL accept(21,24,"P(80);CHU","NONE"
        WHERE ((findstring("@",curaccept) > 0
         AND findstring(".",curaccept) > 0
         AND findstring("@",curaccept) < findstring(".",curaccept,1,1)) OR (curaccept="NONE")) )
       IF (curaccept != "NONE"
        AND locateval(des_index,1,drer_email_list->email_cnt,curaccept,drer_email_list->email[
        des_index].address)=0)
        SET drer_email_list->email_cnt = (drer_email_list->email_cnt+ 1)
        SET stat = alterlist(drer_email_list->email,drer_email_list->email_cnt)
        SET drer_email_list->email[drer_email_list->email_cnt].address = curaccept
        SET drer_email_list->change_ind = 1
       ENDIF
       CALL clear(22,2,129)
       CALL text(22,2,"Email level to Add:")
       SET help = fix(value(des_help_str))
       CALL accept(22,24,"99;F",0
        WHERE (curaccept < drer_email_list->max_email_level))
       SET drer_email_list->email[drer_email_list->email_cnt].level = curhelp
       CALL clear(21,2,129)
       CALL clear(22,2,129)
      OF "R":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Remove, by number:")
       CALL accept(21,38,"99;H",0
        WHERE curaccept BETWEEN 0 AND drer_email_list->email_cnt)
       SET des_remove_location = curaccept
       IF (des_remove_location > 0)
        FOR (des_iter = des_remove_location TO (drer_email_list->email_cnt - 1))
         SET drer_email_list->email[des_iter].address = drer_email_list->email[(des_iter+ 1)].address
         SET drer_email_list->email[des_iter].level = drer_email_list->email[(des_iter+ 1)].level
        ENDFOR
        SET stat = alterlist(drer_email_list->email,(drer_email_list->email_cnt - 1))
        SET drer_email_list->email_cnt = (drer_email_list->email_cnt - 1)
        SET drer_email_list->change_ind = 1
       ENDIF
       CALL clear(21,2,129)
      OF "S":
       IF ((dm_err->debug_flag=722))
        SET message = nowindow
       ENDIF
       IF ((drer_email_list->change_ind=1))
        SET dm_err->eproc = "Deleting existing email rows from dm2_admin_dm_info."
        DELETE  FROM dm2_admin_dm_info di
         WHERE di.info_domain=value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",
           cnvtupper(des_src_env),"_",
           cnvtupper(des_tgt_env)))
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF ((drer_email_list->email_cnt > 0))
         SET dm_err->eproc = "Inserting new email rows into dm2_admin_dm_info."
         INSERT  FROM dm2_admin_dm_info di,
           (dummyt d  WITH seq = value(drer_email_list->email_cnt))
          SET di.info_domain = value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",
             cnvtupper(des_src_env),"_",
             cnvtupper(des_tgt_env))), di.info_name = drer_email_list->email[d.seq].address, di
           .info_number = drer_email_list->email[d.seq].level
          PLAN (d)
           JOIN (di)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ENDIF
        COMMIT
       ENDIF
       IF (drer_fill_email_list(des_src_env,des_tgt_env)=0)
        RETURN(0)
       ENDIF
       IF ((drer_email_list->email_cnt > 0))
        CALL clear(23,2,129)
        CALL text(23,2,"Changes have been saved.  Would you like to send a test email (Y/N)?")
        CALL accept(23,70,"A;CU"," "
         WHERE curaccept IN ("Y", "N"))
        CASE (curaccept)
         OF "Y":
          IF (drer_send_test_emails(1)=0)
           RETURN(0)
          ENDIF
        ENDCASE
       ENDIF
      OF "T":
       IF (drer_send_test_emails(1)=0)
        RETURN(0)
       ENDIF
       CALL clear(21,2,129)
       CALL text(21,2,"A test email has been sent.  Press <enter> to continue.")
       CALL accept(21,58,"A;CH"," ")
       CALL clear(21,2,129)
      OF "Q":
       RETURN(1)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_fill_email_list(dfel_src_env,dfel_tgt_env)
   IF (validate(drrr_responsefile_in_use,0)=1)
    RETURN(1)
   ENDIF
   DECLARE dfel_table_name = vc WITH protect, noconstant("DM2NOTSET")
   IF (((dfel_src_env="DM2NOTSET") OR (dfel_tgt_env="DM2NOTSET")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Evaluate input parameters for subroutine drer_fill_email_list."
    SET dm_err->emsg = "Input parameter(s) is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drer_get_client(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE cnvtupper(ds.synonym_name)="DM2_ADMIN_DM_INFO"
     AND ds.owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dfel_table_name = "DM2_ADMIN_DM_INFO"
   ELSE
    SET dm_err->eproc = "ADMIN CONNECTION"
    CALL disp_msg("",dm_err->logfile,0)
    SET dm2_install_schema->dbase_name = "ADMIN"
    SET dm2_install_schema->u_name = "CDBA"
    IF ((dm2_install_schema->cdba_p_word="DM2NOTSET"))
     EXECUTE dm2_connect_to_dbase "PC"
    ELSE
     SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
    ENDIF
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dfel_table_name = "DM_INFO"
   ENDIF
   SET dm_err->eproc = concat("Querying for list of email addresses from ",dfel_table_name)
   SELECT INTO "nl:"
    FROM (parser(dfel_table_name) di)
    WHERE di.info_domain=value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",cnvtupper(
       dfel_src_env),"_",
      cnvtupper(dfel_tgt_env)))
    ORDER BY di.info_number, di.info_name
    HEAD REPORT
     level_cnt = 0, email_cnt = 0
    HEAD di.info_number
     level_cnt = (level_cnt+ 1), drer_email_list->level_cnt = level_cnt, stat = alterlist(
      drer_email_list->email_level,level_cnt),
     drer_email_list->email_level[level_cnt].level = di.info_number, drer_email_list->email_level[
     level_cnt].email_list = ""
    DETAIL
     email_cnt = (email_cnt+ 1), stat = alterlist(drer_email_list->email,email_cnt), drer_email_list
     ->email[email_cnt].address = di.info_name,
     drer_email_list->email[email_cnt].level = di.info_number
     IF ((drer_email_list->email_level[level_cnt].email_list=""))
      drer_email_list->email_level[level_cnt].email_list = di.info_name
     ELSE
      drer_email_list->email_level[level_cnt].email_list = concat(drer_email_list->email_level[
       level_cnt].email_list,",",di.info_name)
     ENDIF
     drer_email_list->email_cnt = email_cnt
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
    CALL echorecord(drer_email_list)
    SET message = window
   ENDIF
   IF (dfel_table_name="DM_INFO")
    IF ((((dm2_install_schema->target_dbase_name="DM2NOTSET")) OR ((dm2_install_schema->v500_p_word=
    "DM2NOTSET"))) )
     SET dm2_install_schema->dbase_name = '"TARGET"'
     SET dm2_install_schema->u_name = "V500"
     EXECUTE dm2_connect_to_dbase "PC"
    ELSE
     SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
    ENDIF
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_compose_email(null)
   DECLARE def_line = vc WITH protect, noconstant(" ")
   DECLARE def_cnt = i4 WITH protect, noconstant(0)
   IF ((drer_email_det->status="EXECUTING"))
    SET drer_email_det->msgtype = "PROGRESS"
    IF ((drer_email_det->restart_ind=0))
     SET def_line = concat(drer_email_det->step," started at ",format(drer_email_det->status_dt_tm,
       ";;q"))
    ELSE
     SET def_line = concat(drer_email_det->step," restarted at ",format(drer_email_det->status_dt_tm,
       ";;q"))
    ENDIF
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    CALL drer_add_body_text(def_line,0)
   ELSEIF ((drer_email_det->status="COMPLETE"))
    SET drer_email_det->msgtype = "PROGRESS"
    SET def_line = concat(drer_email_det->step," completed at ",format(drer_email_det->status_dt_tm,
      ";;q"))
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    CALL drer_add_body_text(def_line,0)
   ELSEIF ((drer_email_det->status="FAILED"))
    SET drer_email_det->msgtype = "ACTIONREQ"
    SET def_line = concat("Component Name :",drer_email_det->component_name)
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Process Description :",drer_email_det->eproc)
    CALL drer_add_body_text(def_line,0)
    SET def_line = concat("Error Message :",drer_email_det->emsg)
    CALL drer_add_body_text(def_line,0)
    IF ((drer_email_det->user_action > "")
     AND (drer_email_det->user_action != "DM2NOTSET")
     AND (drer_email_det->user_action != "NONE"))
     SET def_line = concat("User Action :",drer_email_det->user_action)
     CALL drer_add_body_text(def_line,0)
    ENDIF
    IF (findstring("/",drer_email_det->logfile)=0)
     SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    ELSE
     SET def_line = concat("Log file name is : ",drer_email_det->logfile)
    ENDIF
    CALL drer_add_body_text(def_line,0)
   ENDIF
   SET drer_email_det->subject = concat("PROCESS: ",evaluate(drer_email_det->process,"DM2NOTSET",
     "N/A",trim(drer_email_det->process)),", MSGTYPE: ",evaluate(drer_email_det->msgtype,"DM2NOTSET",
     "N/A",trim(drer_email_det->msgtype)),", STATUS: ",
    evaluate(drer_email_det->status,"DM2NOTSET","N/A",trim(drer_email_det->status)),", CLIENT: ",
    evaluate(drer_email_det->client,"DM2NOTSET","N/A",trim(drer_email_det->client)))
   IF (get_unique_file("dm2_rr_email",".dat")=0)
    RETURN(0)
   ENDIF
   SET drer_email_det->file_name = dm_err->unique_fname
   SET dm_err->eproc = concat("Generate file ",drer_email_det->file_name)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(drer_email_det->file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     def_line = concat("SRC_ENV/SRC_NODE:",evaluate(drer_email_det->src_env,"DM2NOTSET","N/A",trim(
        drer_email_det->src_env)),"/",evaluate(drer_email_det->src_node,"DM2NOTSET","N/A",trim(
        drer_email_det->src_node)),", TGT_ENV/TGT_NODE:",
      evaluate(drer_email_det->tgt_env,"DM2NOTSET","N/A",trim(drer_email_det->tgt_env)),"/",evaluate(
       drer_email_det->tgt_node,"DM2NOTSET","N/A",trim(drer_email_det->tgt_node)),", STEP: ",evaluate
      (drer_email_det->step,"DM2NOTSET","N/A",trim(drer_email_det->step)),
      ", EMAIL DT/TM: ",format(cnvtdatetime(curdate,curtime3),";;q")),
     CALL print(def_line), row + 1,
     row + 2
     FOR (def_cnt = 1 TO drer_email_det->body_cnt)
      CALL print(drer_email_det->body[def_cnt].txt),row + 2
     ENDFOR
    WITH nocounter, maxcol = 2000, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_send_email(dse_subject,dse_file_name,dse_level)
   DECLARE dse_iter = i4 WITH protect, noconstant(0)
   DECLARE dse_idx = i4 WITH protect, noconstant(0)
   DECLARE dse_file = vc WITH protect, noconstant("")
   DECLARE dse_lnx_version = f8 WITH protect, noconstant(0)
   IF (((trim(dse_subject)="DM2NOTSET") OR (trim(dse_file_name)="DM2NOTSET")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters <Subject, File Name> can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dse_level > drer_email_list->max_email_level))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameter email level is not valid."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   WHILE (dse_idx=0)
    SET dse_idx = locateval(dse_idx,1,drer_email_list->level_cnt,dse_level,drer_email_list->
     email_level[dse_idx].level)
    IF (dse_idx=0
     AND (dse_level < drer_email_list->max_email_level))
     SET dse_level = (dse_level+ 1)
    ELSEIF (dse_idx=0
     AND (dse_level=drer_email_list->max_email_level))
     RETURN(1)
    ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
    CALL echo(build("dse_idx = ",dse_idx))
   ENDIF
   IF (((dse_idx <= 0) OR ((dse_idx > drer_email_list->level_cnt))) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameter dse_level is invalid"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((drer_email_list->email_level[dse_idx].email_list=""))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Email list can not be blank"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dse_iter = dse_idx TO drer_email_list->level_cnt)
    IF ((drer_email_det->attachment != "DM2NOTSET")
     AND (dm2_sys_misc->cur_os IN ("AIX", "LNX", "HPX")))
     SET dse_file = replace(drer_email_det->attachment,".","w.",2)
     IF (dm2_push_dcl(concat(^sed 's/$'"/`echo \\^,'\\\r`/"'," ",drer_email_det->attachment," > ",
       dse_file))=0)
      SET dm_err->err_ind = 0
      SET dse_file = drer_email_det->attachment
     ENDIF
     SET drer_email_det->attachment = "DM2NOTSET"
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     IF (dm2_push_dcl(concat('MAIL/SUBJECT="',build(dse_subject),'" ',build(dse_file_name),' "',
       build(drer_email_list->email_level[dse_iter].email_list),'"'))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="LNX"))
     IF (dse_file != "")
      SET dse_lnx_version = drer_redhat_version(null)
      IF (dse_lnx_version >= 6)
       IF (dm2_push_dcl(concat("cat ",dse_file_name,' | mail -s "',dse_subject,'" -a ',
         dse_file,' "',drer_email_list->email_level[dse_iter].email_list,'"'))=0)
        RETURN(0)
       ENDIF
      ELSE
       IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
         dse_file,'`) | mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].
         email_list,
         '"'))=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter]
       .email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="AIX"))
     IF (dse_file != "")
      IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
        dse_file,'`) | mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].email_list,
        '"'))=0)
       RETURN(0)
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter]
       .email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="HPX"))
     IF (dse_file != "")
      IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
        dse_file,'`) | mailx -m -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].
        email_list,
        '"'))=0)
       RETURN(0)
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mailx -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter
       ].email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_send_test_emails(dste_level)
   DECLARE dste_test_file_name = vc WITH protect, noconstant("")
   DECLARE dste_iter = i4 WITH protect, noconstant(0)
   DECLARE dste_email_list = vc WITH protect, noconstant("")
   SET dste_test_file_name = build(logical("CCLUSERDIR"),evaluate(dm2_sys_misc->cur_os,"AXP",
     "dm2_email_test.txt","/dm2_email_test.txt"))
   SET dm_err->eproc = "Attempting to create a test file to be emailed."
   SELECT INTO value(dste_test_file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test email"
    WITH nocounter, maxcol = 100, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(drer_send_email("Test email",dste_test_file_name,dste_level))
 END ;Subroutine
 SUBROUTINE drer_add_body_text(dabt_in_text,dabt_in_reset_ind)
   IF (dabt_in_reset_ind=1)
    SET drer_email_det->body_cnt = 1
    SET stat = alterlist(drer_email_det->body,1)
    SET drer_email_det->body[drer_email_det->body_cnt].txt = dabt_in_text
   ELSE
    SET drer_email_det->body_cnt = (drer_email_det->body_cnt+ 1)
    SET stat = alterlist(drer_email_det->body,drer_email_det->body_cnt)
    SET drer_email_det->body[drer_email_det->body_cnt].txt = dabt_in_text
   ENDIF
 END ;Subroutine
 SUBROUTINE drer_reset_pre_err(null)
   SET dm_err->err_ind = drer_email_det->err_ind
   SET dm_err->emsg = drer_email_det->emsg
   SET dm_err->eproc = drer_email_det->eproc
   SET dm_err->user_action = drer_email_det->user_action
 END ;Subroutine
 SUBROUTINE drer_get_client(null)
   SET dm_err->eproc = "Get Client Mnemonic."
   CALL disp_msg("",dm_err->logfile,0)
   SET drer_email_det->client = cnvtupper(logical("client_mnemonic"))
   IF ((((drer_email_det->client="DM2NOTSET")) OR ((drer_email_det->client=""))) )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      drer_email_det->client = trim(cnvtupper(d.info_char))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_redhat_version(null)
   DECLARE drv_lnx_ver_temp = vc WITH protect, constant(build2("dm2_os_ver_",cnvtdatetime(curdate,
      curtime3),".dat"))
   DECLARE drv_cmd_lnx_ver = vc WITH protect, constant(build2("cat /etc/redhat-release >> ",trim(
      drv_lnx_ver_temp,3)))
   DECLARE drv_cmd_length = i4 WITH protect, noconstant(textlen(drv_cmd_lnx_ver))
   DECLARE drv_status = i4 WITH protect, noconstant(0)
   DECLARE drv_version = vc WITH protect, noconstant("")
   DECLARE drv_dcl_output = vc WITH protect, noconstant("")
   DECLARE drv_return_value = f8 WITH protect, noconstant(0)
   DECLARE drv_continue = i2 WITH protect, noconstant(true)
   DECLARE drv_iwknt = i4 WITH protect, noconstant(1)
   SET stat = remove(drv_lnx_ver_temp)
   CALL dcl(drv_cmd_lnx_ver,drv_cmd_length,drv_status)
   FREE DEFINE rtl
   DEFINE rtl drv_lnx_ver_temp
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     drv_dcl_output = cnvtupper(trim(r.line,3))
    WITH nocounter
   ;end select
   SET stat = remove(drv_lnx_ver_temp)
   SET drv_version = substring((findstring("RELEASE",drv_dcl_output)+ 8),1,drv_dcl_output)
   IF (isnumeric(drv_version)=1)
    WHILE (drv_continue
     AND drv_iwknt < 4)
     SET drv_iwknt = (drv_iwknt+ 1)
     IF (isnumeric(substring(((findstring("RELEASE",drv_dcl_output)+ 8)+ drv_iwknt),1,drv_dcl_output)
      )=1)
      IF (drv_iwknt=2)
       SET drv_version = concat(trim(drv_version,3),".",substring(((findstring("RELEASE",
          drv_dcl_output)+ 8)+ drv_iwknt),1,drv_dcl_output))
      ELSE
       SET drv_version = concat(trim(drv_version,3),substring(((findstring("RELEASE",drv_dcl_output)
         + 8)+ drv_iwknt),1,drv_dcl_output))
      ENDIF
     ELSE
      SET drv_continue = false
     ENDIF
    ENDWHILE
    IF (isnumeric(drv_version) > 0)
     SET drv_return_value = cnvtreal(drv_version)
    ENDIF
   ENDIF
   CALL echo(build("RHEL Version = ",drv_return_value))
   RETURN(drv_return_value)
 END ;Subroutine
 DECLARE drsu_prelim(null) = i2
 DECLARE drsu_get_lines(null) = i2
 DECLARE drsu_order_struct(null) = i2
 DECLARE drsu_scroll(ds_rec_str=vc) = vc
 DECLARE drsu_main_screen_header(null) = i2
 DECLARE drsu_child_screen_header(dcsh_mode=vc) = i2
 DECLARE drsu_driver(dd_leave=i2(ref)) = i2
 DECLARE drsu_work_menu(dwm_screen_return=vc(ref)) = i2
 DECLARE drsu_screen_fill(holder=i2) = i2
 DECLARE drsu_del_reg(ddr_line_ndx=i4) = i2
 DECLARE drsu_apply_reg(das_line_ndx=i4,das_from=vc) = i2
 DECLARE drsu_longview(dl_line_ndx=i4,dl_mode=vc) = i2
 DECLARE drsu_set_lreg(dsl_ndx=i4,dsl_key=vc,dsl_prop=vc,dsl_val=vc,dsl_op_type=vc) = i2
 DECLARE ddr_reg_format = vc WITH protect, noconstant("")
 DECLARE drsu_rs_prefix = vc WITH protect, constant("drsu_screen")
 DECLARE drsu_leave = i2 WITH protect, noconstant(0)
 FREE RECORD drsu_screen
 RECORD drsu_screen(
   1 top_line = i4
   1 bottom_line = i4
   1 cur_line = i4
   1 max_scroll = i4
   1 max_value = i4
 )
 FREE RECORD drsu_line
 RECORD drsu_line(
   1 line_cnt = i4
   1 line[*]
     2 cdeleted = i2
     2 keyline = i2
     2 skey = vc
     2 sprop = vc
     2 sval = vc
     2 tkey = vc
     2 tprop = vc
     2 tval = vc
     2 ckeyexists = i2
     2 ckey = vc
     2 cprop = vc
     2 cval = vc
 )
 IF (check_logfile("dm2_reg_sync_up",".log","dm2_reg_sync_up")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm2_reg_sync_up"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (drsu_prelim(null)=0)
  GO TO exit_program
 ENDIF
 IF (drsu_get_lines(null)=0)
  GO TO exit_program
 ENDIF
 IF ((drsu_line->line_cnt=0))
  SET dm_err->eproc = "Check for registry data"
  SET dm_err->emsg = "No Registry Data Returned"
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (drsu_order_struct(null)=0)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag != 722))
  SET message = window
 ENDIF
 IF ((dm2_sys_misc->cur_os="AXP"))
  SET ddr_reg_format = concat("\environment\",ddr_domain_data->tgt_env,"\definitions")
 ELSE
  SET ddr_reg_format = concat("\\environment\\",ddr_domain_data->tgt_env,"\\definitions")
 ENDIF
 WHILE (drsu_leave=0)
   SET drsu_screen->top_line = 1
   SET drsu_screen->cur_line = 1
   SET drsu_screen->bottom_line = 0
   SET drsu_screen->max_scroll = 16
   IF (drsu_driver(drsu_leave)=0)
    GO TO exit_program
   ENDIF
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
 ENDWHILE
 IF (drsu_leave=1)
  IF (ddr_rpt_reg_issues(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 GO TO exit_program
 SUBROUTINE drsu_set_lreg(dsl_ndx,dsl_key,dsl_prop,dsl_val,dsl_op_type)
   DECLARE dsl_str = vc WITH protect, noconstant("")
   DECLARE dsl_ret = vc WITH protect, noconstant("")
   DECLARE dsl_cmd = vc WITH protect, noconstant("")
   DECLARE dsl_cnt = i4 WITH protect, noconstant(0)
   IF (dsl_op_type="SET"
    AND (drsu_line->line[dsl_ndx].ckeyexists=0))
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dsl_str = concat(ddr_reg_format,dsl_key)
    ELSE
     SET dsl_str = concat(ddr_reg_format,replace(dsl_key,"\","\\",0))
    ENDIF
    IF (ddr_lreg_oper("CREATE",dsl_str,dsl_ret)=0)
     RETURN(0)
    ENDIF
    FOR (dsl_cnt = 1 TO drsu_line->line_cnt)
      IF ((drsu_line->line[dsl_ndx].ckey=drsu_line->line[dsl_cnt].ckey))
       SET drsu_line->line[dsl_cnt].ckeyexists = 1
      ENDIF
    ENDFOR
   ENDIF
   SET dsl_str = ""
   IF (dsl_op_type="SET")
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dsl_str = concat(ddr_reg_format,dsl_key," ",dsl_prop,' "',
      dsl_val,'"')
    ELSE
     SET dsl_str = concat(ddr_reg_format,replace(dsl_key,"\","\\",0)," ",dsl_prop,' "',
      dsl_val,'"')
    ENDIF
   ELSE
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dsl_str = concat(ddr_reg_format,dsl_key," ",dsl_prop)
    ELSE
     SET dsl_str = concat(ddr_reg_format,replace(dsl_key,"\","\\",0)," ",dsl_prop)
    ENDIF
   ENDIF
   IF (ddr_lreg_oper(dsl_op_type,dsl_str,dsl_ret)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dsl_str = concat(ddr_reg_format,dsl_key," ",dsl_prop)
   ELSE
    SET dsl_str = concat(ddr_reg_format,replace(dsl_key,"\","\\",0)," ",dsl_prop)
   ENDIF
   IF (ddr_lreg_oper("GET",dsl_str,dsl_ret)=0)
    RETURN(0)
   ENDIF
   IF (dsl_op_type="DEL")
    IF (dsl_ret != "NOPARMRETURNED")
     SET message = nowindow
     SET dm_err->emsg = concat("Unable to delete property:",dsl_prop)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    IF (cnvtupper(trim(dsl_ret,3)) != cnvtupper(trim(dsl_val,3))
     AND dsl_val != "")
     SET message = nowindow
     SET dm_err->emsg = concat("Unable to set property:",dsl_prop," to ",dsl_val)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsl_op_type="DEL")
    CALL clear(23,1,131)
    CALL text(23,1,"Parameter removed successfully")
    CALL pause(1)
   ELSE
    CALL clear(23,1,131)
    CALL text(23,1,"Parameter set successfully")
    CALL pause(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_driver(dd_leave)
   DECLARE dd_screen_return = vc WITH protect, noconstant("")
   DECLARE dd_continue = i2 WITH protect, noconstant(0)
   WHILE (dd_continue=0)
     SET dd_screen_return = " "
     IF (drsu_work_menu(dd_screen_return)=0)
      RETURN(0)
     ENDIF
     CASE (dd_screen_return)
      OF "EXIT":
       SET dd_leave = 1
       SET dd_continue = 1
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_work_menu(dwm_screen_return)
   DECLARE dwm_correct = i2 WITH protect, noconstant(0)
   DECLARE dwm_accept = vc WITH protect, noconstant("")
   DECLARE dwm_prop = vc WITH protect, noconstant("")
   DECLARE dwm_scroll_accept = vc WITH protect, noconstant("")
   CALL clear(1,1)
   IF (drsu_main_screen_header(null)=0)
    RETURN(0)
   ENDIF
   SET display_line = 5
   SET drsu_screen->max_value = drsu_line->line_cnt
   SET drsu_screen->max_scroll = 16
   IF ((drsu_screen->cur_line <= 1))
    SET drsu_screen->top_line = 1
    SET drsu_screen->cur_line = 1
    SET drsu_screen->bottom_line = 0
   ENDIF
   IF (drsu_screen_fill(1)=0)
    RETURN(0)
   ENDIF
   SET dwm_screen_return = ""
   SET dwm_scroll_accept = drsu_scroll(drsu_rs_prefix)
   IF (dwm_scroll_accept IN ("S", "T"))
    IF ((drsu_line->line[drsu_screen->cur_line].cprop != ""))
     SET dwm_prop = drsu_line->line[drsu_screen->cur_line].cprop
    ELSEIF ((drsu_line->line[drsu_screen->cur_line].sprop != ""))
     SET dwm_prop = drsu_line->line[drsu_screen->cur_line].sprop
    ELSE
     SET dwm_prop = drsu_line->line[drsu_screen->cur_line].tprop
    ENDIF
   ENDIF
   CASE (dwm_scroll_accept)
    OF "M":
     IF (drsu_longview(drsu_screen->cur_line,"MODIFY")=0)
      RETURN(0)
     ENDIF
    OF "E":
     SET dwm_screen_return = "EXIT"
    OF "R":
     IF ((((drsu_line->line[drsu_screen->cur_line].cprop="")) OR ((drsu_line->line[drsu_screen->
     cur_line].cdeleted=1))) )
      CALL clear(23,1,132)
      CALL text(23,2,"Unable to remove CURRENT since <not defined>.")
      CALL pause(4)
     ELSE
      CALL clear(23,1,132)
      CALL text(23,2,"Confirm Change:  (C)onfirm property removal or (Q)uit without removing :")
      CALL accept(23,92,"p;cu"," "
       WHERE curaccept IN ("C", "Q"))
      CALL clear(23,1,132)
      IF (curaccept="C")
       IF (drsu_set_lreg(drsu_screen->cur_line,drsu_line->line[drsu_screen->cur_line].ckey,drsu_line
        ->line[drsu_screen->cur_line].cprop,drsu_line->line[drsu_screen->cur_line].cval,"DEL")=0)
        RETURN(0)
       ENDIF
       SET drsu_line->line[drsu_screen->cur_line].cdeleted = 1
       SET drsu_line->line[drsu_screen->cur_line].cval = ""
      ENDIF
     ENDIF
    OF "S":
     CALL clear(23,1,132)
     CALL text(23,2,
      "Confirm Change:  (C)onfirm property update with SOURCE value or (Q)uit without updating :")
     CALL accept(23,92,"p;cu"," "
      WHERE curaccept IN ("C", "Q"))
     CALL clear(23,1,132)
     IF (curaccept="C")
      IF (((size(drsu_line->line[drsu_screen->cur_line].cprop)=0) OR ((drsu_line->line[drsu_screen->
      cur_line].cdeleted=1)))
       AND size(drsu_line->line[drsu_screen->cur_line].sprop)=0)
       CALL clear(23,1,132)
       CALL text(23,2,
        "Unable to update with SOURCE value since SOURCE and CURRENT are <not defined>.")
       CALL pause(4)
      ELSEIF ((drsu_line->line[drsu_screen->cur_line].sprop=""))
       IF (drsu_set_lreg(drsu_screen->cur_line,drsu_line->line[drsu_screen->cur_line].ckey,drsu_line
        ->line[drsu_screen->cur_line].cprop,drsu_line->line[drsu_screen->cur_line].cval,"DEL")=0)
        RETURN(0)
       ENDIF
       SET drsu_line->line[drsu_screen->cur_line].cdeleted = 1
       SET drsu_line->line[drsu_screen->cur_line].cval = ""
      ELSE
       SET drsu_line->line[drsu_screen->cur_line].cprop = dwm_prop
       SET drsu_line->line[drsu_screen->cur_line].cval = drsu_line->line[drsu_screen->cur_line].sval
       SET drsu_line->line[drsu_screen->cur_line].cdeleted = 0
       IF (drsu_set_lreg(drsu_screen->cur_line,drsu_line->line[drsu_screen->cur_line].ckey,drsu_line
        ->line[drsu_screen->cur_line].cprop,drsu_line->line[drsu_screen->cur_line].cval,"SET")=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    OF "T":
     CALL clear(23,1,132)
     CALL text(23,2,
      "Confirm Change:  (C)onfirm property update with TARGET value or (Q)uit without updating :")
     CALL accept(23,92,"p;cu"," "
      WHERE curaccept IN ("C", "Q"))
     CALL clear(23,1,132)
     IF (curaccept="C")
      IF (((size(drsu_line->line[drsu_screen->cur_line].cprop)=0) OR ((drsu_line->line[drsu_screen->
      cur_line].cdeleted=1)))
       AND size(drsu_line->line[drsu_screen->cur_line].tprop)=0)
       CALL clear(23,1,132)
       CALL text(23,2,
        "Unable to update with TARGET value since TARGET and CURRENT are <not defined>.")
       CALL pause(4)
      ELSEIF ((drsu_line->line[drsu_screen->cur_line].tprop=""))
       IF (drsu_set_lreg(drsu_screen->cur_line,drsu_line->line[drsu_screen->cur_line].ckey,drsu_line
        ->line[drsu_screen->cur_line].cprop,drsu_line->line[drsu_screen->cur_line].cval,"DEL")=0)
        RETURN(0)
       ENDIF
       SET drsu_line->line[drsu_screen->cur_line].cdeleted = 1
       SET drsu_line->line[drsu_screen->cur_line].cval = ""
      ELSE
       SET drsu_line->line[drsu_screen->cur_line].cprop = dwm_prop
       SET drsu_line->line[drsu_screen->cur_line].cval = drsu_line->line[drsu_screen->cur_line].tval
       SET drsu_line->line[drsu_screen->cur_line].cdeleted = 0
       IF (drsu_set_lreg(drsu_screen->cur_line,drsu_line->line[drsu_screen->cur_line].ckey,drsu_line
        ->line[drsu_screen->cur_line].cprop,drsu_line->line[drsu_screen->cur_line].cval,"SET")=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    OF "V":
     IF (drsu_longview(drsu_screen->cur_line,"VIEW")=0)
      RETURN(0)
     ENDIF
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_scroll(ds_rec_str)
   DECLARE ds_new_start = i4 WITH protect, noconstant(0)
   DECLARE ds_top_line = i4 WITH protect, noconstant(0)
   DECLARE ds_bottom_line = i4 WITH protect, noconstant(0)
   DECLARE ds_max_value = i4 WITH protect, noconstant(0)
   DECLARE ds_max_scroll = i4 WITH protect, noconstant(0)
   DECLARE ds_cur_line = i4 WITH protect, noconstant(0)
   DECLARE ds_disp_cont = i2 WITH protect, noconstant(0)
   DECLARE ds_scroll_accept = vc WITH protect, noconstant(" ")
   CALL parser(concat("set ds_top_line = ",ds_rec_str,"->top_line go"))
   CALL parser(concat("set ds_bottom_line = ",ds_rec_str,"->bottom_line go"))
   CALL parser(concat("set ds_max_value = ",ds_rec_str,"->max_value go"))
   CALL parser(concat("set ds_max_scroll = ",ds_rec_str,"->max_scroll go"))
   CALL parser(concat("set ds_cur_line = ",ds_rec_str,"->cur_line go"))
   CALL line(21,1,132,hor)
   CALL clear(22,1,132)
   CALL text(22,2,
    "Action Items:(V)iew; (M)odify; Apply (T)arget; Apply (S)ource; (R)emove; (E)xit Menu;")
   WHILE (ds_scroll_accept=" ")
    CALL accept(22,90,"p;cus"," "
     WHERE curaccept IN ("V", "E", "T", "S", "R",
     "M"))
    CASE (curscroll)
     OF 0:
      SET ds_scroll_accept = curaccept
     OF 1:
      IF (ds_cur_line=ds_bottom_line)
       SET ds_cur_line = ds_top_line
      ELSE
       IF (ds_cur_line >= ds_max_value)
        SET ds_cur_line = ds_top_line
       ELSE
        SET ds_cur_line = (ds_cur_line+ 1)
       ENDIF
      ENDIF
      CALL parser(concat("set ",ds_rec_str,"->cur_line = ",cnvtstring(ds_cur_line)," go"))
      CALL parser(concat("call ",ds_rec_str,"_fill(1) go"))
     OF 2:
      IF (ds_cur_line=ds_top_line)
       SET ds_cur_line = ds_bottom_line
      ELSE
       SET ds_cur_line = (ds_cur_line - 1)
      ENDIF
      CALL parser(concat("set ",ds_rec_str,"->cur_line = ",cnvtstring(ds_cur_line)," go"))
      CALL parser(concat("call ",ds_rec_str,"_fill(1) go"))
     OF 5:
      SET ds_new_start = 0
      IF (ds_top_line > ds_max_scroll)
       SET ds_top_line = (ds_top_line - ds_max_scroll)
       SET ds_bottom_line = ((ds_top_line+ ds_max_scroll) - 1)
      ELSE
       SET ds_top_line = 1
       IF ((ds_max_value > (ds_max_scroll - 1)))
        SET ds_bottom_line = (ds_top_line+ (ds_max_scroll - 1))
       ELSE
        SET ds_bottom_line = ds_max_value
       ENDIF
      ENDIF
      SET ds_cur_line = ds_top_line
      CALL parser(concat("set ",ds_rec_str,"->cur_line = ",cnvtstring(ds_cur_line)," go"))
      CALL parser(concat("set ",ds_rec_str,"->top_line = ",cnvtstring(ds_top_line)," go"))
      CALL parser(concat("set ",ds_rec_str,"->bottom_line  = ",cnvtstring(ds_bottom_line)," go"))
      CALL parser(concat("call ",ds_rec_str,"_fill(1) go"))
     OF 6:
      SET ds_new_start = 0
      SET ds_new_start = (ds_top_line+ ds_max_scroll)
      IF (ds_max_value >= ds_new_start)
       SET ds_top_line = ds_new_start
       SET ds_cur_line = ds_top_line
       IF (((ds_top_line+ (ds_max_scroll - 1)) <= ds_max_value))
        SET ds_bottom_line = (ds_top_line+ (ds_max_scroll - 1))
       ELSE
        SET ds_bottom_line = ds_max_value
       ENDIF
      ELSE
       SET ds_bottom_line = ds_max_value
      ENDIF
      CALL parser(concat("set ",ds_rec_str,"->cur_line = ",cnvtstring(ds_cur_line)," go"))
      CALL parser(concat("set ",ds_rec_str,"->top_line = ",cnvtstring(ds_top_line)," go"))
      CALL parser(concat("set ",ds_rec_str,"->bottom_line  = ",cnvtstring(ds_bottom_line)," go"))
      CALL parser(concat("call ",ds_rec_str,"_fill(1) go"))
    ENDCASE
   ENDWHILE
   CALL parser(concat("set ",ds_rec_str,"->top_line = ",cnvtstring(ds_top_line)," go"))
   CALL parser(concat("set ",ds_rec_str,"->bottom_line  = ",cnvtstring(ds_bottom_line)," go"))
   CALL parser(concat("set ",ds_rec_str,"->max_value = ",cnvtstring(ds_max_value)," go"))
   CALL parser(concat("set ",ds_rec_str,"->cur_line = ",cnvtstring(ds_cur_line)," go"))
   CALL parser(concat("set ",ds_rec_str,"->max_scroll = ",cnvtstring(ds_max_scroll)," go"))
   SET ds_scroll_accept = ""
   CASE (curaccept)
    OF "T":
     IF ((drsu_line->line[drsu_screen->cur_line].keyline=0))
      SET ds_scroll_accept = "T"
     ENDIF
    OF "R":
     IF ((drsu_line->line[drsu_screen->cur_line].keyline=0))
      SET ds_scroll_accept = "R"
     ENDIF
    OF "S":
     IF ((drsu_line->line[drsu_screen->cur_line].keyline=0))
      SET ds_scroll_accept = "S"
     ENDIF
    OF "E":
     SET ds_scroll_accept = "E"
    OF "M":
     IF ((drsu_line->line[drsu_screen->cur_line].keyline=0))
      SET ds_scroll_accept = "M"
     ENDIF
    OF "V":
     IF ((drsu_line->line[drsu_screen->cur_line].keyline=0))
      SET ds_scroll_accept = "V"
     ENDIF
   ENDCASE
   RETURN(ds_scroll_accept)
 END ;Subroutine
 SUBROUTINE drsu_screen_fill(holder)
   DECLARE fds_screen_cnt = i4 WITH protect, noconstant(0)
   DECLARE fds_first = i2 WITH protect, noconstant(0)
   DECLARE fds_str = vc WITH protect, noconstant("")
   SET display_line = 5
   SET drsu_screen->max_scroll = 16
   IF (((drsu_screen->top_line+ drsu_screen->max_scroll) > drsu_screen->max_value))
    SET drsu_screen->bottom_line = drsu_screen->max_value
   ELSE
    SET drsu_screen->bottom_line = (drsu_screen->top_line+ (drsu_screen->max_scroll - 1))
   ENDIF
   FOR (display_loop = drsu_screen->top_line TO drsu_screen->bottom_line)
     IF ((display_loop=drsu_screen->cur_line))
      CALL video(r)
      IF ((drsu_line->line[display_loop].keyline=1))
       CALL clear(23,1,132)
       IF ((drsu_line->line[display_loop].ckeyexists=0))
        SET fds_str = concat(trim(replace(ddr_reg_format,"\\","\",0)),drsu_line->line[display_loop].
         ckey," <key not defined>")
       ELSE
        SET fds_str = concat(trim(replace(ddr_reg_format,"\\","\",0)),drsu_line->line[display_loop].
         ckey)
       ENDIF
       IF (size(fds_str) >= 128)
        IF ((drsu_line->line[display_loop].ckeyexists=0))
         SET fds_str = concat(substring(1,107,fds_str),"..<key not defined>")
        ELSE
         SET fds_str = concat(substring(1,125,fds_str),"...")
        ENDIF
       ENDIF
       CALL text(23,1,fds_str)
      ELSE
       CALL clear(23,1,132)
      ENDIF
     ELSE
      CALL video(n)
     ENDIF
     CALL clear(display_line,1,132)
     IF ((drsu_line->line[display_loop].keyline=1))
      SET fds_str = concat("KEY:",trim(replace(ddr_reg_format,"\\","\",0)),drsu_line->line[
       display_loop].ckey)
      SET fds_str = substring(1,120,fds_str)
      CALL text(display_line,1,fds_str)
     ELSE
      IF ((drsu_line->line[display_loop].cprop != ""))
       IF (size(drsu_line->line[display_loop].cprop) >= 19)
        CALL text(display_line,2,concat(substring(1,16,drsu_line->line[display_loop].cprop),"..."))
       ELSE
        CALL text(display_line,2,drsu_line->line[display_loop].cprop)
       ENDIF
      ELSEIF ((drsu_line->line[display_loop].sprop != ""))
       IF (size(drsu_line->line[display_loop].sprop) >= 19)
        CALL text(display_line,2,concat(substring(1,16,drsu_line->line[display_loop].sprop),"..."))
       ELSE
        CALL text(display_line,2,drsu_line->line[display_loop].sprop)
       ENDIF
      ELSE
       IF (size(drsu_line->line[display_loop].tprop) >= 19)
        CALL text(display_line,2,concat(substring(1,16,drsu_line->line[display_loop].tprop),"..."))
       ELSE
        CALL text(display_line,2,drsu_line->line[display_loop].tprop)
       ENDIF
      ENDIF
      IF (size(drsu_line->line[display_loop].cval) >= 36)
       CALL text(display_line,22,concat(substring(1,33,drsu_line->line[display_loop].cval),"..."))
      ELSE
       IF ((((drsu_line->line[display_loop].cprop="")) OR ((drsu_line->line[display_loop].cdeleted=1)
       )) )
        CALL text(display_line,22,"<not defined>")
       ELSE
        CALL text(display_line,22,drsu_line->line[display_loop].cval)
       ENDIF
      ENDIF
      IF (size(drsu_line->line[display_loop].sval) >= 36)
       CALL text(display_line,58,concat(substring(1,33,drsu_line->line[display_loop].sval),"..."))
      ELSE
       IF ((drsu_line->line[display_loop].sprop=""))
        CALL text(display_line,58,"<not defined>")
       ELSE
        CALL text(display_line,58,drsu_line->line[display_loop].sval)
       ENDIF
      ENDIF
      IF (size(drsu_line->line[display_loop].tval) >= 36)
       CALL text(display_line,94,concat(substring(1,33,drsu_line->line[display_loop].tval),"..."))
      ELSE
       IF ((drsu_line->line[display_loop].tprop=""))
        CALL text(display_line,94,"<not defined>")
       ELSE
        CALL text(display_line,94,drsu_line->line[display_loop].tval)
       ENDIF
      ENDIF
     ENDIF
     SET display_line = (display_line+ 1)
   ENDFOR
   IF (display_line < 21)
    CALL video(n)
    FOR (display_blank = display_line TO 21)
      CALL clear(display_blank,1,132)
    ENDFOR
   ENDIF
   CALL video(n)
   IF ((drsu_line->line[drsu_screen->cur_line].keyline=0))
    IF ((drsu_screen->max_value > drsu_screen->bottom_line)
     AND (drsu_screen->top_line=1))
     CALL clear(23,60,72)
     CALL text(23,60,"More available, use <PgDown> key to scroll list")
    ELSEIF ((drsu_screen->max_value > drsu_screen->bottom_line))
     CALL clear(23,60,72)
     CALL text(23,60,"More available, use <PgUp>/<PgDown> keys to scroll list")
    ELSE
     CALL clear(23,60,72)
     CALL text(23,60,"Bottom of list, use <PgUp> key to scroll list")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE drsu_main_screen_header(null)
   CALL clear(1,1)
   CALL text(1,53,concat("*** REGISTRY SYNC UP ***"))
   CALL text(3,22,"Current")
   CALL text(3,58,"Source")
   CALL text(3,94,"Target")
   CALL line(4,1,132,horizontal)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_child_screen_header(dcsh_mode)
   CALL clear(1,1)
   CALL text(1,53,concat("*** REGISTRY SYNC UP ***"))
   CALL text(3,2,"Key:")
   CALL text(4,2,"Property:")
   CALL text(5,2,"Current:")
   CALL line(6,1,132,horizontal)
   CALL text(8,4,"Current:")
   CALL text(10,4,"Source:")
   CALL text(12,4,"Target:")
   CALL line(18,1,132,horizontal)
   IF (dcsh_mode="MODIFY")
    CALL text(19,2,"Press <enter> after editing...")
    CALL text(21,2,"(C)onfirm property update or (Q)uit without saving:")
   ENDIF
   IF (dcsh_mode="VIEW")
    CALL text(21,2,"(Q)uit back to main menu:")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_longview(dl_line_ndx,dl_mode)
   DECLARE dl_correct = i2 WITH protect, noconstant(0)
   DECLARE dl_accept = vc WITH protect, noconstant("")
   DECLARE dl_prop = vc WITH protect, noconstant("")
   IF (drsu_child_screen_header(dl_mode)=0)
    RETURN(0)
   ENDIF
   CALL text(3,6,drsu_line->line[dl_line_ndx].ckey)
   IF ((drsu_line->line[dl_line_ndx].cprop != ""))
    CALL text(4,11,drsu_line->line[dl_line_ndx].cprop)
    SET dl_prop = drsu_line->line[dl_line_ndx].cprop
   ELSEIF ((drsu_line->line[dl_line_ndx].sprop != ""))
    CALL text(4,11,drsu_line->line[dl_line_ndx].sprop)
    SET dl_prop = drsu_line->line[dl_line_ndx].sprop
   ELSE
    CALL text(4,11,drsu_line->line[dl_line_ndx].tprop)
    SET dl_prop = drsu_line->line[dl_line_ndx].tprop
   ENDIF
   IF ((drsu_line->line[dl_line_ndx].cprop=""))
    CALL text(5,10,"<not defined>")
   ELSE
    CALL text(5,10,drsu_line->line[dl_line_ndx].cval)
   ENDIF
   IF ((((drsu_line->line[dl_line_ndx].cprop="")) OR ((drsu_line->line[dl_line_ndx].cdeleted=1))) )
    CALL text(8,13,"<not defined>")
   ELSE
    CALL text(8,13,drsu_line->line[dl_line_ndx].cval)
   ENDIF
   IF ((drsu_line->line[dl_line_ndx].sprop=""))
    CALL text(10,13,"<not defined>")
   ELSE
    CALL text(10,13,drsu_line->line[dl_line_ndx].sval)
   ENDIF
   IF ((drsu_line->line[dl_line_ndx].tprop=""))
    CALL text(12,13,"<not defined>")
   ELSE
    CALL text(12,13,drsu_line->line[dl_line_ndx].tval)
   ENDIF
   IF (dl_mode="VIEW")
    CALL accept(21,30,"p;cu"," "
     WHERE curaccept IN ("Q"))
   ELSE
    WHILE (dl_correct=0)
      CALL accept(8,13,"P(120);C"," "
       WHERE curaccept != "")
      SET dl_accept = curaccept
      CALL clear(23,1,132)
      CALL text(23,2,"Is the value entered correct (Y)es or (No)?:")
      CALL accept(23,48,"p;cu"," "
       WHERE curaccept IN ("Y", "N"))
      CALL clear(23,1,132)
      IF (curaccept="Y")
       SET dl_correct = 1
      ENDIF
    ENDWHILE
    CALL accept(21,54,"p;cu"," "
     WHERE curaccept IN ("C", "Q"))
    IF (curaccept="C")
     SET drsu_line->line[dl_line_ndx].cprop = dl_prop
     SET drsu_line->line[dl_line_ndx].cval = dl_accept
     SET drsu_line->line[dl_line_ndx].cdeleted = 0
     IF (drsu_set_lreg(dl_line_ndx,drsu_line->line[dl_line_ndx].ckey,drsu_line->line[dl_line_ndx].
      cprop,drsu_line->line[dl_line_ndx].cval,"SET")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_order_struct(null)
   DECLARE dos_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD drsu_linex
   RECORD drsu_linex(
     1 line_cnt = i4
     1 line[*]
       2 keyline = i2
       2 skey = vc
       2 sprop = vc
       2 sval = vc
       2 tkey = vc
       2 tprop = vc
       2 tval = vc
       2 ckeyexists = i2
       2 ckey = vc
       2 cprop = vc
       2 cval = vc
   )
   SET drsu_linex->line_cnt = drsu_line->line_cnt
   SET stat = alterlist(drsu_linex->line,drsu_linex->line_cnt)
   SET dm_err->eproc = "Order structure by KEY"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(drsu_line->line_cnt))
    PLAN (d
     WHERE d.seq > 0)
    ORDER BY drsu_line->line[d.seq].ckey
    DETAIL
     dos_cnt = (dos_cnt+ 1), drsu_linex->line[dos_cnt].skey = drsu_line->line[d.seq].skey, drsu_linex
     ->line[dos_cnt].sprop = drsu_line->line[d.seq].sprop,
     drsu_linex->line[dos_cnt].sval = drsu_line->line[d.seq].sval, drsu_linex->line[dos_cnt].tkey =
     drsu_line->line[d.seq].tkey, drsu_linex->line[dos_cnt].tprop = drsu_line->line[d.seq].tprop,
     drsu_linex->line[dos_cnt].tval = drsu_line->line[d.seq].tval, drsu_linex->line[dos_cnt].ckey =
     drsu_line->line[d.seq].ckey, drsu_linex->line[dos_cnt].ckeyexists = drsu_line->line[d.seq].
     ckeyexists,
     drsu_linex->line[dos_cnt].cprop = drsu_line->line[d.seq].cprop, drsu_linex->line[dos_cnt].cval
      = drsu_line->line[d.seq].cval
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drsu_linex)
   ENDIF
   SET dos_cnt = 0
   SET stat = alterlist(drsu_line->line,0)
   SET drsu_line->line_cnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(drsu_linex->line_cnt))
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     drsu_line->line_cnt = (drsu_line->line_cnt+ 1), stat = alterlist(drsu_line->line,drsu_line->
      line_cnt), drsu_line->line[drsu_line->line_cnt].ckey = drsu_linex->line[d.seq].ckey,
     drsu_line->line[drsu_line->line_cnt].ckeyexists = drsu_linex->line[d.seq].ckeyexists, drsu_line
     ->line[drsu_line->line_cnt].keyline = 1
    DETAIL
     IF ((drsu_linex->line[d.seq].ckey != drsu_line->line[drsu_line->line_cnt].ckey))
      drsu_line->line_cnt = (drsu_line->line_cnt+ 1), stat = alterlist(drsu_line->line,drsu_line->
       line_cnt), drsu_line->line[drsu_line->line_cnt].ckey = drsu_linex->line[d.seq].ckey,
      drsu_line->line[drsu_line->line_cnt].ckeyexists = drsu_linex->line[d.seq].ckeyexists, drsu_line
      ->line[drsu_line->line_cnt].keyline = 1
     ENDIF
     drsu_line->line_cnt = (drsu_line->line_cnt+ 1), stat = alterlist(drsu_line->line,drsu_line->
      line_cnt), drsu_line->line[drsu_line->line_cnt].skey = drsu_linex->line[d.seq].skey,
     drsu_line->line[drsu_line->line_cnt].sprop = drsu_linex->line[d.seq].sprop, drsu_line->line[
     drsu_line->line_cnt].sval = drsu_linex->line[d.seq].sval, drsu_line->line[drsu_line->line_cnt].
     tkey = drsu_linex->line[d.seq].tkey,
     drsu_line->line[drsu_line->line_cnt].tprop = drsu_linex->line[d.seq].tprop, drsu_line->line[
     drsu_line->line_cnt].tval = drsu_linex->line[d.seq].tval, drsu_line->line[drsu_line->line_cnt].
     ckey = drsu_linex->line[d.seq].ckey,
     drsu_line->line[drsu_line->line_cnt].ckeyexists = drsu_linex->line[d.seq].ckeyexists, drsu_line
     ->line[drsu_line->line_cnt].cprop = drsu_linex->line[d.seq].cprop, drsu_line->line[drsu_line->
     line_cnt].cval = drsu_linex->line[d.seq].cval
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FREE RECORD drsu_linex
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drsu_line)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_get_lines(null)
   DECLARE dgl_kcnt = i4 WITH protect, noconstant(0)
   DECLARE dgl_pcnt = i4 WITH protect, noconstant(0)
   DECLARE dgl_ccnt = i4 WITH protect, noconstant(0)
   DECLARE dgl_found_ndx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Format registry entries"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   FOR (dgl_kcnt = 1 TO ddr_reg->ckcnt)
     FOR (dgl_pcnt = 1 TO ddr_reg->ckey[dgl_kcnt].cpcnt)
       SET drsu_line->line_cnt = (drsu_line->line_cnt+ 1)
       SET stat = alterlist(drsu_line->line,drsu_line->line_cnt)
       SET drsu_line->line[drsu_line->line_cnt].ckey = ddr_reg->ckey[dgl_kcnt].ckeyname
       SET drsu_line->line[drsu_line->line_cnt].skey = ddr_reg->ckey[dgl_kcnt].ckeyname
       SET drsu_line->line[drsu_line->line_cnt].tkey = ddr_reg->ckey[dgl_kcnt].ckeyname
       SET drsu_line->line[drsu_line->line_cnt].cprop = ddr_reg->ckey[dgl_kcnt].cprop[dgl_pcnt].
       cpropname_orig
       SET drsu_line->line[drsu_line->line_cnt].cval = ddr_reg->ckey[dgl_kcnt].cprop[dgl_pcnt].
       cpropval
       SET drsu_line->line[drsu_line->line_cnt].ckeyexists = 1
     ENDFOR
   ENDFOR
   FOR (dgl_kcnt = 1 TO ddr_reg->skcnt)
     FOR (dgl_pcnt = 1 TO ddr_reg->skey[dgl_kcnt].spcnt)
       SET dgl_found_ndx = 0
       FOR (dgl_ccnt = 1 TO drsu_line->line_cnt)
         IF (cnvtlower(ddr_reg->skey[dgl_kcnt].sprop[dgl_pcnt].spropname_orig)=cnvtlower(drsu_line->
          line[dgl_ccnt].cprop))
          IF ((ddr_reg->skey[dgl_kcnt].skeyname=drsu_line->line[dgl_ccnt].ckey))
           SET dgl_found_ndx = dgl_ccnt
          ENDIF
         ENDIF
       ENDFOR
       IF (dgl_found_ndx > 0)
        SET drsu_line->line[dgl_found_ndx].skey = ddr_reg->skey[dgl_kcnt].skeyname
        SET drsu_line->line[dgl_found_ndx].sprop = ddr_reg->skey[dgl_kcnt].sprop[dgl_pcnt].
        spropname_orig
        SET drsu_line->line[dgl_found_ndx].sval = ddr_reg->skey[dgl_kcnt].sprop[dgl_pcnt].spropval
       ELSE
        SET drsu_line->line_cnt = (drsu_line->line_cnt+ 1)
        SET stat = alterlist(drsu_line->line,drsu_line->line_cnt)
        SET drsu_line->line[drsu_line->line_cnt].skey = ddr_reg->skey[dgl_kcnt].skeyname
        SET drsu_line->line[drsu_line->line_cnt].tkey = ddr_reg->skey[dgl_kcnt].skeyname
        SET drsu_line->line[drsu_line->line_cnt].ckey = ddr_reg->skey[dgl_kcnt].skeyname
        SET drsu_line->line[drsu_line->line_cnt].sprop = ddr_reg->skey[dgl_kcnt].sprop[dgl_pcnt].
        spropname_orig
        SET drsu_line->line[drsu_line->line_cnt].sval = ddr_reg->skey[dgl_kcnt].sprop[dgl_pcnt].
        spropval
       ENDIF
     ENDFOR
   ENDFOR
   FOR (dgl_kcnt = 1 TO ddr_reg->tkcnt)
     FOR (dgl_pcnt = 1 TO ddr_reg->tkey[dgl_kcnt].tpcnt)
       SET dgl_found_ndx = 0
       FOR (dgl_ccnt = 1 TO drsu_line->line_cnt)
         IF (cnvtlower(ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].tpropname_orig)=cnvtlower(drsu_line->
          line[dgl_ccnt].cprop))
          IF ((ddr_reg->tkey[dgl_kcnt].tkeyname=drsu_line->line[dgl_ccnt].ckey))
           SET dgl_found_ndx = dgl_ccnt
          ENDIF
         ENDIF
       ENDFOR
       IF (dgl_found_ndx > 0)
        SET drsu_line->line[dgl_found_ndx].tkey = ddr_reg->tkey[dgl_kcnt].tkeyname
        SET drsu_line->line[dgl_found_ndx].tprop = ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].
        tpropname_orig
        SET drsu_line->line[dgl_found_ndx].tval = ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].tpropval
       ELSE
        SET dgl_found_ndx = 0
        FOR (dgl_ccnt = 1 TO drsu_line->line_cnt)
          IF (cnvtlower(ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].tpropname_orig)=cnvtlower(drsu_line->
           line[dgl_ccnt].sprop))
           IF ((ddr_reg->tkey[dgl_kcnt].tkeyname=drsu_line->line[dgl_ccnt].skey))
            SET dgl_found_ndx = dgl_ccnt
           ENDIF
          ENDIF
        ENDFOR
        IF (dgl_found_ndx > 0)
         SET drsu_line->line[dgl_found_ndx].tkey = ddr_reg->tkey[dgl_kcnt].tkeyname
         SET drsu_line->line[dgl_found_ndx].tprop = ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].
         tpropname_orig
         SET drsu_line->line[dgl_found_ndx].tval = ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].tpropval
        ELSE
         SET drsu_line->line_cnt = (drsu_line->line_cnt+ 1)
         SET stat = alterlist(drsu_line->line,drsu_line->line_cnt)
         SET drsu_line->line[drsu_line->line_cnt].tkey = ddr_reg->tkey[dgl_kcnt].tkeyname
         SET drsu_line->line[drsu_line->line_cnt].skey = ddr_reg->tkey[dgl_kcnt].tkeyname
         SET drsu_line->line[drsu_line->line_cnt].ckey = ddr_reg->tkey[dgl_kcnt].tkeyname
         SET drsu_line->line[drsu_line->line_cnt].tprop = ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].
         tpropname_orig
         SET drsu_line->line[drsu_line->line_cnt].tval = ddr_reg->tkey[dgl_kcnt].tprop[dgl_pcnt].
         tpropval
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   FOR (dgl_kcnt = 1 TO ddr_reg->skcnt)
     IF (locateval(dgl_found_ndx,1,ddr_reg->ckcnt,ddr_reg->skey[dgl_kcnt].skeyname,ddr_reg->ckey[
      dgl_found_ndx].ckeyname) > 0)
      FOR (dgl_pcnt = 1 TO drsu_line->line_cnt)
        IF ((drsu_line->line[dgl_pcnt].ckey=ddr_reg->skey[dgl_kcnt].skeyname))
         SET drsu_line->line[dgl_pcnt].ckeyexists = 1
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FOR (dgl_kcnt = 1 TO ddr_reg->tkcnt)
     IF (locateval(dgl_found_ndx,1,ddr_reg->ckcnt,ddr_reg->tkey[dgl_kcnt].tkeyname,ddr_reg->ckey[
      dgl_found_ndx].ckeyname) > 0)
      FOR (dgl_pcnt = 1 TO drsu_line->line_cnt)
        IF ((drsu_line->line[dgl_pcnt].ckey=ddr_reg->tkey[dgl_kcnt].tkeyname))
         SET drsu_line->line[dgl_pcnt].ckeyexists = 1
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drsu_line)
    CALL echorecord(ddr_reg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsu_prelim(null)
   DECLARE dp_log_ret = vc WITH protect, noconstant("")
   DECLARE dp_dev_ret = vc WITH protect, noconstant("")
   DECLARE dp_dir_ret = vc WITH protect, noconstant("")
   DECLARE ddr_reg_ret = vc WITH protect, noconstant("")
   DECLARE dp_str = vc WITH protect, noconstant("")
   IF ((ddr_domain_data->tgt_env="DM2NOTSET"))
    IF (ddr_get_env_logical(dp_log_ret)=0)
     RETURN(0)
    ENDIF
    SET ddr_domain_data->tgt_env = cnvtlower(dp_log_ret)
   ENDIF
   IF (ddr_validate_user(ddr_domain_data->tgt_env)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND (ddr_domain_data->tgt_tmp_full_dir="DM2NOTSET"))
    IF (ddr_dev_prompt(0,1,dp_dev_ret)=0)
     RETURN(0)
    ELSE
     SET ddr_domain_data->tgt_tmp_dev = dp_dev_ret
    ENDIF
   ENDIF
   IF ((ddr_domain_data->tgt_tmp_full_dir="DM2NOTSET"))
    IF (ddr_dir_prompt(0,1,dp_dir_ret)=0)
     RETURN(0)
    ELSE
     SET ddr_domain_data->tgt_tmp_dir = dp_dir_ret
     SET ddr_domain_data->tgt_tmp_full_dir = evaluate(dm2_sys_misc->cur_os,"AXP",concat(
       ddr_domain_data->tgt_tmp_dev,":[",dp_dir_ret,".",ddr_domain_data->tgt_env,
       "]"),concat(dp_dir_ret,ddr_domain_data->tgt_env,"/"))
    ENDIF
   ENDIF
   IF ( NOT (dm2_find_dir(ddr_domain_data->tgt_tmp_full_dir)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Directory entered does not exist:",ddr_domain_data->tgt_tmp_full_dir)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Validate registry file exists for TARGET"
   IF (size(ddr_domain_data->tgt_env,1) > max_reg_env_len)
    SET dp_str = concat(ddr_domain_data->tgt_tmp_full_dir,substring(1,max_reg_env_len,ddr_domain_data
      ->tgt_env),"_env.reg")
   ELSE
    SET dp_str = concat(ddr_domain_data->tgt_tmp_full_dir,ddr_domain_data->tgt_env,"_env.reg")
   ENDIF
   IF (dm2_findfile(dp_str)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Registry file does not exist:",dp_str)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Read in TARGET registry settings"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET ddr_reg->tgt_reg_file = dp_str
   IF (ddr_pop_reg_struct(2,ddr_reg->tgt_reg_file,1)=0)
    RETURN(0)
   ENDIF
   IF (ddr_validate_source_env(1)=0)
    RETURN(0)
   ENDIF
   SET dp_str = evaluate(dm2_sys_misc->cur_os,"AXP",concat(ddr_domain_data->tgt_tmp_dev,":[",
     ddr_domain_data->tgt_tmp_dir,".",ddr_domain_data->src_env,
     "]"),concat(ddr_domain_data->tgt_tmp_dir,ddr_domain_data->src_env,"/"))
   IF (size(ddr_domain_data->src_env,1) > max_reg_env_len)
    SET dp_str = concat(dp_str,substring(1,max_reg_env_len,ddr_domain_data->src_env),"_env.reg")
   ELSE
    SET dp_str = concat(dp_str,ddr_domain_data->src_env,"_env.reg")
   ENDIF
   SET dm_err->eproc = "Validate registry file exists for SOURCE"
   IF (dm2_findfile(dp_str)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Registry file does not exist:",dp_str)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Read in SOURCE registry settings"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET ddr_reg->src_reg_file = dp_str
   IF (ddr_pop_reg_struct(1,ddr_reg->src_reg_file,1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Read in CURRENT registry settings"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (ddr_get_env_reg(0,0,"DEFINITION",1)=0)
    RETURN(0)
   ENDIF
   IF (size(ddr_domain_data->tgt_env,1) > max_reg_env_len)
    SET ddr_reg->cur_reg_file = concat("ccluserdir:",substring(1,max_reg_env_len,ddr_domain_data->
      tgt_env),"_c_env.reg")
   ELSE
    SET ddr_reg->cur_reg_file = concat("ccluserdir:",ddr_domain_data->tgt_env,"_c_env.reg")
   ENDIF
   IF (ddr_pop_reg_struct(3,ddr_reg->cur_reg_file,1)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 SET message = nowindow
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(ddr_reg)
  CALL echorecord(drsu_line)
  CALL echorecord(drsu_screen)
 ENDIF
 FREE RECORD drsu_screen
 FREE RECORD drsu_line
 FREE RECORD ddr_reg
 SET dm_err->eproc = "dm2_reg_sync_up completed"
 CALL final_disp_msg("dm2_reg_sync_up")
END GO
