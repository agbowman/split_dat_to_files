CREATE PROGRAM dm_auto_verify_rpt:dba
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
 DECLARE drcr_get_relationship_type(null) = i2
 DECLARE drcr_get_ptam_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_cutover_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_dual_build_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_full_circle_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_check_all_config(i_config_info_rec=vc(ref)) = null
 DECLARE drcr_get_config_text(i_config_type=vc,i_config_setting=i2) = vc
 DECLARE drcr_check_cbc_setup(i_source_env_id=f8,i_target_env_id=f8,ccs_msg=vc(ref)) = null
 IF ((validate(drcr_reltn_type_list->count,- (1))=- (1)))
  FREE RECORD drcr_reltn_type_list
  RECORD drcr_reltn_type_list(
    1 qual[*]
      2 type = vc
    1 source_env_id = f8
    1 target_env_id = f8
    1 count = i2
  )
 ENDIF
 IF ((validate(drcr_config_info->config_complete_ind,- (1))=- (1)))
  FREE RECORD drcr_config_info
  RECORD drcr_config_info(
    1 source_env_id = f8
    1 target_env_id = f8
    1 config_complete_ind = i2
    1 error_ind = i2
    1 error_msg = vc
  )
 ENDIF
 IF ((validate(drcr_ccs_info->cbc_ind,- (1))=- (1)))
  FREE RECORD drcr_ccs_info
  RECORD drcr_ccs_info(
    1 cbc_ind = i2
    1 return_ind = i2
    1 return_msg = vc
  )
 ENDIF
 SUBROUTINE drcr_get_relationship_type(null)
   DECLARE dgrt_relationship_type = vc WITH protect, noconstant("NOT CONFIGURED")
   DECLARE dgrt_ndx = i2 WITH protect, noconstant(0)
   DECLARE dgrt_return = i2 WITH protect, noconstant(- (1))
   SELECT INTO "nl:"
    FROM dm_env_reltn der
    WHERE (der.parent_env_id=drcr_reltn_type_list->source_env_id)
     AND (der.child_env_id=drcr_reltn_type_list->target_env_id)
     AND expand(dgrt_ndx,1,drcr_reltn_type_list->count,der.relationship_type,drcr_reltn_type_list->
     qual[dgrt_ndx].type)
    DETAIL
     dgrt_relationship_type = der.relationship_type
    WITH nocounter
   ;end select
   SET dgrt_return = (locateval(dgrt_ndx,1,drcr_reltn_type_list->count,dgrt_relationship_type,
    drcr_reltn_type_list->qual[dgrt_ndx].type) - 1)
   RETURN(dgrt_return)
 END ;Subroutine
 SUBROUTINE drcr_get_ptam_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "NO PENDING TARGET AS MASTER"
   SET drcr_reltn_type_list->qual[2].type = "PENDING TARGET AS MASTER"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_cutover_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "AUTO CUTOVER"
   SET drcr_reltn_type_list->qual[2].type = "PLANNED CUTOVER"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_dual_build_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "ALLOW DUAL BUILD"
   SET drcr_reltn_type_list->qual[2].type = "BLOCK DUAL BUILD"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_full_circle_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,1)
   SET drcr_reltn_type_list->count = 1
   SET drcr_reltn_type_list->qual[1].type = "RDDS MOVER CHANGES NOT LOGGED"
   RETURN((drcr_get_relationship_type(null)+ 1))
 END ;Subroutine
 SUBROUTINE drcr_check_all_config(i_config_info_rec)
  IF (drcr_get_cutover_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id) >= 0
  )
   IF (drcr_get_dual_build_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id)
    >= 0)
    SET i_config_info_rec->config_complete_ind = 1
    IF (drcr_get_full_circle_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id
     )=1)
     IF ((drcr_get_ptam_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id)=- (
     1)))
      SET i_config_info_rec->config_complete_ind = 0
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (check_error(dm_err->eproc) != 0)
   SET i_config_info_rec->error_ind = 1
   SET i_config_info_rec->error_msg = dm_err->emsg
  ELSE
   IF ((i_config_info_rec->config_complete_ind=0))
    SET i_config_info_rec->error_msg = concat(
     "The process is unable to proceed because one or more of the required mover ",
     'configurations have not been setup.  Please go to the "Configure RDDS Settings" option under the "Manage RDDS ',
     'Post Domain Copy" option in the DM_MERGE_DOMAIN_ADM script.')
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE drcr_get_config_text(i_config_type,i_config_setting)
   IF ((i_config_setting=- (1)))
    RETURN("Not Configured")
   ELSE
    CASE (trim(cnvtupper(i_config_type)))
     OF "PTAM":
      IF (i_config_setting=0)
       RETURN("NO PENDING TARGET AS MASTER")
      ELSE
       RETURN("PENDING TARGET AS MASTER")
      ENDIF
     OF "DUAL BUILD":
      IF (i_config_setting=0)
       RETURN("ALLOW DUAL BUILD")
      ELSE
       RETURN("BLOCK DUAL BUILD")
      ENDIF
     OF "CUTOVER":
      IF (i_config_setting=0)
       RETURN("AUTO CUTOVER")
      ELSE
       RETURN("PLANNED CUTOVER")
      ENDIF
     ELSE
      RETURN("Unknown Configuration Type")
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE drcr_check_cbc_setup(i_source_env_id,i_target_env_id,ccs_msg)
   DECLARE dccs_ctp = vc WITH protect, noconstant("")
   SET drcr_ccs_info->return_ind = 0
   SET drcr_ccs_info->cbc_ind = 0
   SET drcr_ccs_info->return_msg = ""
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONFIGURATION"
     AND d.info_name="CUTOVER BY CONTEXT"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET drcr_ccs_info->return_msg = dm_err->emsg
    SET drcr_ccs_info->return_ind = 1
    RETURN(null)
   ENDIF
   IF (curqual=0)
    SET drcr_ccs_info->return_ind = 0
    SET drcr_ccs_info->cbc_ind = 0
    RETURN(null)
   ELSE
    SET drcr_ccs_info->cbc_ind = 1
   ENDIF
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONTEXT"
     AND d.info_name="CONTEXTS TO PULL"
    DETAIL
     dccs_ctp = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET drcr_ccs_info->return_msg = dm_err->emsg
    SET drcr_ccs_info->return_ind = 1
    RETURN(null)
   ENDIF
   IF (((findstring("::",dccs_ctp,1,0) > 0) OR (cnvtupper(dccs_ctp)="ALL")) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="CONTEXT GROUP_IND"
      AND d.info_number=0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "The RDDS mover configuration must be set up to maintain contexts that are being pulled, ",
      "in order for cutover by context to be used.  Please correct the setup through DM_MERGE_DOMAIN_ADM."
      )
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ELSE
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="CONTEXT GROUP_IND"
      AND d.info_number=1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "When only pulling 1 context, the CONTEXT GROUP_IND row must be set to 1.  Please use DM_MERGE_DOMAIN_ADM to setup ",
      "the context information for the merge, so that it is performed correctly.")
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ENDIF
   SET dccs_ctp = concat("::",dccs_ctp,"::")
   IF (((findstring("::NULL::",cnvtupper(dccs_ctp),1,0) > 0) OR (findstring("::ALL::",cnvtupper(
     dccs_ctp),1,0) > 0)) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="DEFAULT CONTEXT"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "The RDDS mover configuration must have a default context supplied if pulling NULL or ALL. ",
      "Please correct the setup through DM_MERGE_DOMAIN_ADM.")
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM user_objects u
    WHERE u.object_name IN ("DM_RDDS_DMT_DEL", "DM_RDDS_DMT_INS", "DM_RDDS_DMT_UPD")
     AND u.object_type="TRIGGER"
     AND status="VALID"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual != 3)
    SET drcr_ccs_info->return_msg =
    "One of the DM_MERGE_TRANSLATE triggers is missing.  Please run DM_RMC_CREATE_DMT_TRIG to create the triggers."
    SET drcr_ccs_info->return_ind = 1
   ENDIF
   RETURN(null)
 END ;Subroutine
 DECLARE sort_menu(null) = null
 DECLARE detail_menu(v_sort=i4) = null
 DECLARE summary_view(null) = null
 DECLARE summary_print(null) = null
 DECLARE domain_config_print(v_pair=i4) = null
 DECLARE chg_log_print(v_pair=i4) = null
 DECLARE cutover_sum_print(v_pair=i4) = null
 DECLARE move_hist_print(v_pair=i4) = null
 DECLARE main_values(v_sort=i4) = null
 DECLARE detail_rpt_values(v_pair=i4) = null
 DECLARE parse_cntx(pc_cntx_str=vc,pc_cntx_delim=vc,pc_cntx_rs=vc(ref)) = i4
 DECLARE sv_maxshow = i4 WITH constant(12)
 FREE RECORD pc_contexts
 RECORD pc_contexts(
   1 qual[*]
     2 values = vc
 )
 IF (check_logfile("dm_auto_verify_rpt",".log","DM_AUTO_VERIFY_RPT")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->emsg = "Starting dm_auto_verify_rpt"
 FREE RECORD envpair
 RECORD envpair(
   1 envpair_cnt = i4
   1 qual[*]
     2 pair_num = i4
     2 src_id = f8
     2 src_name = vc
     2 src_usr_chg = vc
     2 trg_id = f8
     2 trg_name = vc
     2 trg_usr_chg = vc
     2 rdds_ready = vc
     2 full_circle = vc
     2 ptam_env_name = vc
     2 merge_type = vc
     2 seq_match = vc
     2 xlat_backfill = vc
     2 seq_max_cnt = i4
     2 seq_detail_cnt = i4
     2 max_drp_trg = f8
     2 max_add_trg = f8
     2 trig_chk = i2
     2 src_version = i4
     2 trg_version = i4
     2 up_bndr = i4
     2 lo_bndr = i4
     2 ver_chk = i2
     2 dblink_chk = i2
     2 trig_create_tm = dq8
     2 begin_datasync_tm = dq8
     2 end_datasync_tm = dq8
     2 cbc_ind = i2
     2 max_tier_tm = f8
     2 xcptn_reset_ind = i2
     2 dual_build_trig_ind = i2
     2 mov_reason = vc
     2 mov_start_tm = dq8
     2 mov_stop_tm = dq8
     2 mov_notstop = vc
     2 mov_asof = dq8
     2 clr_cnt = i4
     2 clr[*]
       3 clr_type = vc
       3 clr_tot = i4
       3 clr_min_tm = dq8
       3 clr_max_tm = dq8
     2 cp[*]
       3 con_pull = vc
     2 cp_all = vc
     2 cw[*]
       3 con_write = vc
     2 cw_all = vc
     2 cut_reason = vc
     2 cut_start_tm = dq8
     2 cut_stop_tm = dq8
     2 cut_notstop = vc
     2 cut_running = vc
     2 cut_ctxt_cnt = i4
     2 cut_ctxt[*]
       3 ctxt_name = vc
     2 cut_asof = dq8
     2 cut_cnt = i4
     2 cut[*]
       3 cut_type = vc
       3 cut_tot = i4
       3 cut_min_tm = dq8
       3 cut_max_tm = dq8
     2 err1_cnt = i4
     2 err[*]
       3 err_tab_name = vc
       3 err_tab_status = vc
       3 err_tab_rows = i4
       3 err_min_tm = dq8
       3 err_max_tm = dq8
     2 err_tab_tot = i4
     2 err_row_tot = f8
     2 log_cnt = i4
     2 log[*]
       3 clr_log_detail = vc
       3 clr_log_cntx = vc
       3 clr_tab_name = vc
       3 clr_log_type = vc
       3 clr_log_tot = i4
       3 clr_min_tm = dq8
       3 clr_max_tm = dq8
     2 csr_cnt = i4
     2 csr[*]
       3 csr_detail = vc
       3 csr_cntx = vc
       3 csr_tab_name = vc
       3 csr_status = vc
       3 csr_tot = i4
       3 csr_min_tm = dq8
       3 csr_max_tm = dq8
     2 mover_cnt = i4
     2 mover[*]
       3 event_begin_tm = dq8
       3 event_end_tm = dq8
       3 event_name = vc
       3 mov_start_tm = dq8
       3 mov_stop_tm = dq8
       3 cut_start_tm = dq8
       3 cut_stop_tm = dq8
       3 context_pull = vc
       3 ctp_list[*]
         4 values = vc
       3 context_set = vc
       3 cts_list[*]
         4 values = vc
       3 mstr_cntx[*]
         4 ctp = vc
         4 cts = vc
         4 group_ind = i2
         4 default = vc
 )
 CALL sort_menu(null)
 SUBROUTINE sort_menu(null)
   DECLARE sort_loop = i2 WITH protect, noconstant(0)
   SET sort_loop = 0
   WHILE (sort_loop=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,"***  RDDS STATUS REPORTS  ***")
     CALL text(7,3,"Please choose from the following sort options:")
     CALL text(9,3,"1) RDDS Readiness")
     CALL text(11,3,"2) Source Environment")
     CALL text(17,3,"0) Exit")
     CALL accept(7,50,"9",0
      WHERE curaccept IN (1, 2, 0))
     CASE (curaccept)
      OF 1:
       CALL main_values(0)
       CALL summary_view(null)
      OF 2:
       CALL main_values(1)
       CALL summary_view(null)
      OF 0:
       CALL clear(1,1)
       SET sort_loop = 1
       GO TO exit_main
     ENDCASE
   ENDWHILE
   IF (check_error("Error while executing sort_menu subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE detail_menu(v_pair)
   DECLARE dm_pair = i4
   DECLARE detail_loop = i2 WITH protect, noconstant(0)
   SET dm_pair = v_pair
   SET detail_loop = 0
   WHILE (detail_loop=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,"***  RDDS STATUS REPORTS  ***")
     CALL text(8,3,"Source: ")
     CALL text(9,3,"Target: ")
     CALL text(8,13,concat(envpair->qual[dm_pair].src_name," (",trim(cnvtstring(envpair->qual[dm_pair
         ].src_id)),")"))
     CALL text(9,13,concat(envpair->qual[dm_pair].trg_name," (",trim(cnvtstring(envpair->qual[dm_pair
         ].trg_id)),")"))
     CALL text(13,3,"Please choose from the following detail reports:")
     CALL text(15,6,"1) Domain Configuration Report")
     CALL text(16,6,"2) RDDS Change Log Report")
     CALL text(17,6,"3) RDDS Cutover Summary Report")
     CALL text(18,6,"4) RDDS Move History Report")
     CALL text(21,6,"0) Exit")
     CALL accept(13,53,"9",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      0))
     CASE (curaccept)
      OF 1:
       CALL domain_config_print(dm_pair)
      OF 2:
       CALL chg_log_print(dm_pair)
      OF 3:
       CALL cutover_sum_print(dm_pair)
      OF 4:
       CALL move_hist_print(dm_pair)
      OF 0:
       CALL clear(1,1)
       SET detail_loop = 1
       CALL summary_view(null)
     ENDCASE
   ENDWHILE
   IF (check_error("Error while executing detail_menu subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE summary_view(null)
   DECLARE menu_loop = i4 WITH noconstant(0)
   DECLARE envpair_loop = i4
   DECLARE pass_str = vc
   DECLARE pass_val = i4
   DECLARE sv_sets = i4
   DECLARE irow = i4
   DECLARE sv_min_disp = i4
   DECLARE sv_max_disp = i4
   DECLARE select_num = i4
   DECLARE sv_prev_valid_ind = i2
   DECLARE sv_next_valid_ind = i2
   DECLARE cur_numeric = i2
   SET menu_loop = 0
   SET sv_sets = envpair->envpair_cnt
   SET sv_min_disp = 1
   WHILE (menu_loop=0)
     IF ((sv_sets <= ((sv_min_disp+ sv_maxshow) - 1)))
      SET sv_max_disp = sv_sets
     ELSE
      SET sv_max_disp = ((sv_min_disp+ sv_maxshow) - 1)
     ENDIF
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(2,44,"***  RDDS STATUS REPORTS  ***")
     CALL text(3,76,"RDDS")
     CALL text(3,84,"Source")
     CALL text(3,98,"Src/Trg")
     CALL text(3,115,"Src/Trg")
     CALL text(4,6,"Source")
     CALL text(4,41,"Target")
     CALL text(4,76,"Ready")
     CALL text(4,84,"Triggers")
     CALL text(4,98,"Version")
     CALL text(4,115,"DB Link")
     SET irow = 7
     SET sv_prev_valid_ind = 0
     SET sv_next_valid_ind = 0
     FOR (envpair_loop = sv_min_disp TO sv_max_disp)
       SET select_num = value(envpair->qual[envpair_loop].pair_num)
       CALL text(irow,3,cnvtstring(select_num))
       CALL text(irow,6,concat(envpair->qual[envpair_loop].src_name," (",trim(cnvtstring(envpair->
           qual[envpair_loop].src_id)),")"))
       CALL text(irow,41,concat(envpair->qual[envpair_loop].trg_name," (",trim(cnvtstring(envpair->
           qual[envpair_loop].trg_id)),")"))
       CALL text(irow,76,envpair->qual[envpair_loop].rdds_ready)
       IF ((envpair->qual[envpair_loop].trig_chk=0))
        CALL text(irow,84,"Not Created")
       ELSE
        CALL text(irow,84,"Created")
       ENDIF
       IF ((envpair->qual[envpair_loop].ver_chk=0))
        CALL text(irow,98,"Not Compatible")
       ELSE
        CALL text(irow,98,"Compatible")
       ENDIF
       IF ((envpair->qual[envpair_loop].dblink_chk=0))
        CALL text(irow,115,"Not Complete")
       ELSE
        CALL text(irow,115,"Complete")
       ENDIF
       SET irow = (irow+ 1)
     ENDFOR
     CALL text(21,3,"P) Print Summary")
     IF (((sv_min_disp+ sv_maxshow) <= sv_sets))
      SET sv_next_valid_ind = 1
      CALL text(20,3,"D) Page Down")
     ENDIF
     IF (sv_min_disp > sv_maxshow)
      SET sv_prev_valid_ind = 1
      CALL text(19,3,"U) Page Up")
     ENDIF
     CALL text(23,3,"0) Exit this program")
     CALL text(22,3,concat("Choose ",trim(cnvtstring(sv_min_disp)),"-",trim(cnvtstring(sv_max_disp)),
       " for detail reports"))
     CALL accept(22,54,"PPP;CU","0")
     SET pass_str = trim(curaccept)
     SET cur_numeric = 0
     IF (isnumeric(pass_str)=1)
      SET cur_numeric = 1
      SET pass_val = cnvtint(pass_str)
     ENDIF
     IF (sv_prev_valid_ind=1
      AND pass_str="U")
      IF (sv_min_disp <= sv_maxshow)
       SET sv_min_disp = 1
      ELSE
       SET sv_min_disp = (sv_min_disp - sv_maxshow)
      ENDIF
     ELSEIF (sv_next_valid_ind=1
      AND pass_str="D")
      SET sv_min_disp = (sv_min_disp+ sv_maxshow)
     ELSEIF (pass_str="P")
      SET menu_loop = 1
     ELSEIF (pass_val=0
      AND cur_numeric=1)
      SET menu_loop = 1
     ELSEIF (cur_numeric=1
      AND pass_val >= sv_min_disp
      AND pass_val <= sv_max_disp)
      SET menu_loop = 1
     ELSE
      CALL text(22,58,"Invalid Entry")
      CALL pause(2)
     ENDIF
   ENDWHILE
   IF (pass_str="P")
    CALL print_summary(null)
   ELSEIF (pass_val=0)
    CALL clear(1,1)
    CALL sort_menu(null)
   ELSE
    CALL detail_rpt_values(pass_val)
    CALL detail_menu(pass_val)
   ENDIF
   IF (check_error("Error while executing summary_view subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE print_summary(null)
   DECLARE src_info = vc
   DECLARE trg_info = vc
   DECLARE pair_no = vc
   IF ((envpair->envpair_cnt=0))
    SET envpair->envpair_cnt = 1
   ENDIF
   SELECT INTO mine
    FROM (dummyt d  WITH seq = envpair->envpair_cnt)
    ORDER BY envpair->qual[d.seq].pair_num
    HEAD REPORT
     col 40, "****** RDDS STATUS REPORTS ******", row + 1
    HEAD PAGE
     col 76, "RDDS", col 84,
     "Source", col 98, "Src/Trg",
     col 115, "Src/Trg", row + 1,
     col 1, "No.", col 5,
     "Source", col 41, "Target",
     col 76, "Ready", col 84,
     "Triggers", col 98, "Version",
     col 115, "DB Link", row + 1,
     col 1,
     "--------------------------------------------------------------------------------------------------------------------------",
     row + 1
    DETAIL
     pair_no = cnvtstring(envpair->qual[d.seq].pair_num), col 1, pair_no,
     src_info = concat(envpair->qual[d.seq].src_name," (",trim(cnvtstring(envpair->qual[d.seq].src_id
        )),")"), col 5, src_info,
     trg_info = concat(envpair->qual[d.seq].trg_name," (",trim(cnvtstring(envpair->qual[d.seq].trg_id
        )),")"), col 41, trg_info,
     col 76, envpair->qual[d.seq].rdds_ready
     IF ((envpair->qual[d.seq].trig_chk=0))
      col 84, "Not Created"
     ELSE
      col 84, "Created"
     ENDIF
     IF ((envpair->qual[d.seq].ver_chk=0))
      col 98, "Not Compatible"
     ELSE
      col 98, "Compatible"
     ENDIF
     IF ((envpair->qual[d.seq].dblink_chk=0))
      col 115, "Not Complete"
     ELSE
      col 115, "Complete"
     ENDIF
     row + 1
    WITH nocounter, maxcol = 256, formfeed = none
   ;end select
   IF (check_error("Error while executing print_summary subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE domain_config_print(v_pair)
   DECLARE v_config = i4
   DECLARE version = vc
   DECLARE dblink = vc
   DECLARE src_info = vc
   DECLARE trg_info = vc
   DECLARE src_trig = vc
   DECLARE cutover_running = vc
   DECLARE cutover_err = vc
   DECLARE cntx_str1 = vc
   DECLARE cntx_str2 = vc
   DECLARE last_event = i4
   DECLARE cntx_cnt = i4
   DECLARE x = i4
   DECLARE y = i4
   DECLARE pos_a = i4
   DECLARE pos_b = i4
   DECLARE cntx_str1_a = vc
   DECLARE cntx_str2_a = vc
   DECLARE dcp_ctxt_str = vc WITH protect, noconstant(" ")
   DECLARE dcp_ctxt_str2 = vc WITH protect, noconstant(" ")
   DECLARE dcp_idx = i4 WITH protect, noconstant(0)
   DECLARE dcp_pos = i4 WITH protect, noconstant(0)
   SET x = 1
   SET y = 1
   SET v_config = v_pair
   SET src_info = concat(envpair->qual[v_config].src_name," (",trim(cnvtstring(envpair->qual[v_config
      ].src_id)),") ",envpair->qual[v_config].src_usr_chg)
   SET trg_info = concat(envpair->qual[v_config].trg_name," (",trim(cnvtstring(envpair->qual[v_config
      ].trg_id)),") ",envpair->qual[v_config].trg_usr_chg)
   IF ((envpair->qual[v_config].trig_chk=0))
    SET src_trig = "Not Created *** REQUIRED ***"
   ELSE
    SET src_trig = concat("Last Created (",trim(datetimezoneformat(envpair->qual[v_config].
       trig_create_tm,curtimezoneapp,"DD-MMM-YYYY HH:MM ZZZ")),")")
   ENDIF
   SET cutover_running = cnvtstring(envpair->qual[v_config].cut_running)
   SET cutover_err = concat(trim(cnvtstring(envpair->qual[v_config].err_tab_tot))," Tables with ",
    trim(cnvtstring(envpair->qual[v_config].err_row_tot))," unprocessed rows")
   IF ((envpair->qual[v_config].ver_chk=0))
    SET version = "Not Compatible *** REQUIRED ***"
   ELSE
    SET version = "Compatible"
   ENDIF
   IF ((envpair->qual[v_config].dblink_chk=0))
    SET dblink = "Not Complete *** REQUIRED ***"
   ELSE
    SET dblink = "Complete"
   ENDIF
   SET last_event = 1
   SET cntx_cnt = size(envpair->qual[v_config].mover[last_event].ctp_list,5)
   FOR (mhp_loop = 1 TO cntx_cnt)
    IF ((envpair->qual[v_config].mover[last_event].ctp_list[mhp_loop].values > ""))
     IF (mhp_loop=1)
      SET cntx_str1 = substring(1,22,envpair->qual[v_config].mover[last_event].ctp_list[mhp_loop].
       values)
     ELSE
      SET cntx_str1 = concat(cntx_str1,", ",substring(1,22,envpair->qual[v_config].mover[last_event].
        ctp_list[mhp_loop].values))
     ENDIF
    ENDIF
    IF ((envpair->qual[v_config].mover[last_event].cts_list[mhp_loop].values > ""))
     IF (mhp_loop=1)
      SET cntx_str2 = substring(1,22,envpair->qual[v_config].mover[last_event].cts_list[mhp_loop].
       values)
     ELSEIF ((envpair->qual[v_config].mover[last_event].cts_list[mhp_loop].values != envpair->qual[
     v_config].mover[last_event].cts_list[(mhp_loop - 1)].values))
      SET cntx_str2 = concat(cntx_str2,", ",substring(1,22,envpair->qual[v_config].mover[last_event].
        cts_list[mhp_loop].values))
     ENDIF
    ENDIF
   ENDFOR
   IF ((envpair->qual[v_config].cbc_ind=1))
    FOR (dcp_idx = 1 TO envpair->qual[v_config].cut_ctxt_cnt)
     IF (dcp_idx > 1)
      SET dcp_ctxt_str = concat(dcp_ctxt_str,",")
     ENDIF
     SET dcp_ctxt_str = concat(dcp_ctxt_str,envpair->qual[v_config].cut_ctxt[dcp_idx].ctxt_name)
    ENDFOR
   ENDIF
   SELECT INTO mine
    d.seq
    FROM dummyt d
    HEAD REPORT
     x = 1, y = 1, pos_a = 0,
     pos_b = 0, col 40, "******  RDDS STATUS REPORTS  ******",
     row + 2
    HEAD PAGE
     row + 1, col 3, "DOMAIN CONFIGURATION REPORT",
     row + 2
    DETAIL
     col 3, "Source: ", col 13,
     src_info, row + 1, col 3,
     "Target: ", col 13, trg_info,
     row + 2, col 3, "Source Triggers: ",
     col 41, src_trig, row + 1,
     col 3, "Src/Tgt Versions: ", col 41,
     version, row + 1, col 3,
     "Src/Tgt DB Link: ", col 41, dblink,
     row + 1, col 3, "Sequence Match: ",
     col 41, envpair->qual[v_config].seq_match, row + 1,
     col 3, "Translation Backfill: ", col 41,
     envpair->qual[v_config].xlat_backfill, row + 1, col 3,
     "Merge Type: ", col 41, envpair->qual[v_config].merge_type,
     row + 1, col 3, "Full Circle: ",
     col 41, envpair->qual[v_config].full_circle, row + 1,
     col 3, "Pending Target as Master: "
     IF ((envpair->qual[v_config].ptam_env_name != ""))
      col 41, envpair->qual[v_config].ptam_env_name
     ELSE
      col 41, "Disabled"
     ENDIF
     row + 1, col 3, "RDDS Tiering Last Completed:"
     IF ((envpair->qual[v_config].max_tier_tm=0))
      col 41, "Not Completed"
     ELSE
      col 41, envpair->qual[v_config].max_tier_tm"DD-MMM-YYYY HH:MM;;Q"
     ENDIF
     row + 1, col 3, "Child Exception Reset Configuration: "
     IF ((envpair->qual[v_config].xcptn_reset_ind=1))
      col 41, "Enabled"
     ELSE
      col 41, "Disabled"
     ENDIF
     row + 1, col 3, "Dual Build Trigger Configuration: "
     IF ((envpair->qual[v_config].dual_build_trig_ind=1))
      col 41, "Blocking"
     ELSEIF ((envpair->qual[v_config].dual_build_trig_ind=0))
      col 41, "Not Blocking"
     ELSE
      col 41, "Not Configured"
     ENDIF
     row + 2, col 3, "Most Recent Move Status: ",
     col + 1, envpair->qual[v_config].mov_reason, row + 1,
     col 8, "Movers Start Time through Menu: "
     IF ((envpair->qual[v_config].mov_start_tm=0))
      col + 1, "No movers started through the menu for this event"
     ELSE
      col + 1, envpair->qual[v_config].mov_start_tm"DD-MMM-YYYY HH:MM;;Q"
     ENDIF
     row + 1, col 8, "Movers Stop Time through Menu: "
     IF ((envpair->qual[v_config].mov_notstop="Running"))
      col + 1, "Movers currently running"
     ELSE
      col + 1, envpair->qual[v_config].mov_stop_tm"DD-MMM-YYYY HH:MM;;Q"
     ENDIF
     row + 1, col 8, "Contexts To Pull: "
     WHILE (x <= size(cntx_str1))
      IF (((size(cntx_str1) - x) > 90))
       pos_a = findstring(",",substring(x,90,cntx_str1),1,1)
       IF (pos_a=0)
        cntx_str1_a = substring(x,((size(cntx_str1) - x)+ 1),cntx_str1), col 27, cntx_str1_a,
        x = (size(cntx_str1)+ 1)
       ELSE
        cntx_str1_a = substring(x,pos_a,cntx_str1), col 27, cntx_str1_a,
        x = (x+ pos_a)
       ENDIF
      ELSE
       cntx_str1_a = substring(x,((size(cntx_str1) - x)+ 1),cntx_str1), col 27, cntx_str1_a,
       x = (size(cntx_str1)+ 1)
      ENDIF
      ,row + 1
     ENDWHILE
     col 8, "Contexts To Set: "
     WHILE (y <= size(cntx_str2))
      IF (((size(cntx_str2) - y) > 90))
       pos_b = findstring(",",substring(y,90,cntx_str2),1,1)
       IF (pos_b=0)
        cntx_str2_a = substring(y,((size(cntx_str2) - y)+ 1),cntx_str2), col 27, cntx_str2_a,
        y = (size(cntx_str2)+ 1)
       ELSE
        cntx_str2_a = substring(y,pos_b,cntx_str2), col 27, cntx_str2_a,
        y = (y+ pos_b)
       ENDIF
      ELSE
       cntx_str2_a = substring(y,((size(cntx_str2) - y)+ 1),cntx_str2), col 27, cntx_str2_a,
       y = (size(cntx_str2)+ 1)
      ENDIF
      ,row + 1
     ENDWHILE
     row + 1, col 8, "Change Log Rows as of",
     col + 1, envpair->qual[v_config].mov_asof"DD-MMM-YYYY HH:MM;;Q", row + 1,
     col 14, "Log Type", col 31,
     "Count", col 40, "Earliest Date/Time",
     col 62, "Last Date/Time"
     FOR (i_dcl = 1 TO size(envpair->qual[v_config].clr,5))
       row + 1, col 14, envpair->qual[v_config].clr[i_dcl].clr_type,
       col 25, envpair->qual[v_config].clr[i_dcl].clr_tot, col 40,
       envpair->qual[v_config].clr[i_dcl].clr_min_tm"DD-MMM-YYYY HH:MM;;Q", col 62, envpair->qual[
       v_config].clr[i_dcl].clr_max_tm"DD-MMM-YYYY HH:MM;;Q"
     ENDFOR
     row + 2, col 3, "Most Recent Cutover Status: ",
     col + 1, envpair->qual[v_config].mov_reason, row + 1,
     col 8, "Cutover Started: ", col + 1,
     envpair->qual[v_config].cut_start_tm"DD-MMM-YYYY HH:MM;;Q", row + 1, col 8,
     "Cutover Stopped: "
     IF ((envpair->qual[v_config].cut_notstop="Running"))
      col + 1, envpair->qual[v_config].cut_notstop
     ELSE
      col + 1, envpair->qual[v_config].cut_stop_tm"DD-MMM-YYYY HH:MM;;Q"
     ENDIF
     row + 1
     IF ((envpair->qual[v_config].cbc_ind=1))
      col 8, "Contexts Cutover: "
      WHILE (dcp_pos <= size(dcp_ctxt_str))
       IF (((size(dcp_ctxt_str) - dcp_pos) > 90))
        pos_b = findstring(",",substring(dcp_pos,90,dcp_ctxt_str),1,1)
        IF (pos_b=0)
         dcp_ctxt_str2 = substring(dcp_pos,((size(dcp_ctxt_str) - dcp_pos)+ 1),dcp_ctxt_str), col 27,
         dcp_ctxt_str2,
         dcp_pos = (size(dcp_ctxt_str)+ 1)
        ELSE
         dcp_ctxt_str2 = substring(dcp_pos,pos_b,dcp_ctxt_str), col 27, dcp_ctxt_str2,
         dcp_pos = (dcp_pos+ pos_b)
        ENDIF
       ELSE
        dcp_ctxt_str2 = substring(dcp_pos,((size(dcp_ctxt_str) - dcp_pos)+ 1),dcp_ctxt_str), col 27,
        dcp_ctxt_str2,
        dcp_pos = (size(dcp_ctxt_str)+ 1)
       ENDIF
       ,row + 1
      ENDWHILE
     ENDIF
     col 8, "Cutovers Running: ", col 26,
     cutover_running, row + 2, col 8,
     "Mirror Table Rows as of", col + 1, envpair->qual[v_config].cut_asof"DD-MMM-YYYY HH:MM;;Q",
     row + 1, col 14, "Status",
     col 31, "Count", col 40,
     "Earliest Date/Time", col 62, "Last Date/Time"
     FOR (i_dcl = 1 TO size(envpair->qual[v_config].cut,5))
       row + 1, col 14, envpair->qual[v_config].cut[i_dcl].cut_type,
       col 25, envpair->qual[v_config].cut[i_dcl].cut_tot, col 40,
       envpair->qual[v_config].cut[i_dcl].cut_min_tm"DD-MMM-YYYY HH:MM;;Q", col 62, envpair->qual[
       v_config].cut[i_dcl].cut_max_tm"DD-MMM-YYYY HH:MM;;Q"
     ENDFOR
     row + 1, col 14, "Errored: ",
     col + 1, cutover_err
    WITH nocounter, maxcol = 256, formfeed = none
   ;end select
   IF (check_error("Error while executing domain_config_print subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_log_print(v_pair)
   DECLARE v_clr = i4
   DECLARE src_info = vc
   DECLARE trg_info = vc
   SET v_clr = v_pair
   SET src_info = concat(envpair->qual[v_clr].src_name," (",trim(cnvtstring(envpair->qual[v_clr].
      src_id)),")")
   SET trg_info = concat(envpair->qual[v_clr].trg_name," (",trim(cnvtstring(envpair->qual[v_clr].
      trg_id)),")")
   SELECT INTO mine
    ctx_name = substring(1,30,envpair->qual[v_clr].log[d.seq].clr_log_cntx), tab_name = substring(1,
     30,envpair->qual[v_clr].log[d.seq].clr_tab_name)
    FROM (dummyt d  WITH seq = envpair->qual[v_clr].log_cnt)
    ORDER BY ctx_name, tab_name
    HEAD REPORT
     col 40, "******  RDDS STATUS REPORTS  ******", row + 2
    HEAD PAGE
     row + 1, col 3, "RDDS CHANGE LOG REPORT",
     row + 2, col 3, "Source: ",
     col 13, src_info, row + 1,
     col 3, "Target: ", col 13,
     trg_info, row + 2, col 3,
     "As of", col + 1, envpair->qual[v_clr].mov_asof"DD-MMM-YYYY HH:MM;;Q",
     row + 2, col 3, "Context Name",
     col 32, "Table Name", col 63,
     "Log Type", col 77, "Count",
     col 84, "Earliest Date/Time", col 104,
     "Last Date/Time", row + 1, col 1,
     "------------------------------------------------------------------------------------------------------------------------",
     row + 1
    DETAIL
     col 3, ctx_name, col 32,
     tab_name, col 63, envpair->qual[v_clr].log[d.seq].clr_log_type,
     col 71, envpair->qual[v_clr].log[d.seq].clr_log_tot, col 84,
     envpair->qual[v_clr].log[d.seq].clr_min_tm"DD-MMM-YYYY HH:MM;;Q", col 104, envpair->qual[v_clr].
     log[d.seq].clr_max_tm"DD-MMM-YYYY HH:MM;;Q",
     row + 1
    WITH nocounter, maxcol = 256, formfeed = none
   ;end select
   IF (check_error("Error from executing chg_log_print subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE cutover_sum_print(v_pair)
   DECLARE v_cut = i4
   DECLARE src_info = vc
   DECLARE trg_info = vc
   SET v_cut = v_pair
   SET src_info = concat(envpair->qual[v_cut].src_name," (",trim(cnvtstring(envpair->qual[v_cut].
      src_id)),")")
   SET trg_info = concat(envpair->qual[v_cut].trg_name," (",trim(cnvtstring(envpair->qual[v_cut].
      trg_id)),")")
   SELECT INTO mine
    ctx_name = substring(1,30,envpair->qual[v_cut].csr[d.seq].csr_cntx), tab_name = substring(1,30,
     envpair->qual[v_cut].csr[d.seq].csr_tab_name)
    FROM (dummyt d  WITH seq = envpair->qual[v_cut].csr_cnt)
    ORDER BY ctx_name DESC, tab_name
    HEAD REPORT
     col 40, "******  RDDS STATUS REPORTS  ******", row + 2
    HEAD PAGE
     row + 1, col 3, "RDDS CUTOVER SUMMARY REPORT",
     row + 2, col 3, "Source: ",
     col 13, src_info, row + 1,
     col 3, "Target: ", col 13,
     trg_info, row + 2, col 3,
     "As of", col + 1, envpair->qual[v_cut].cut_asof"DD-MMM-YYYY HH:MM;;Q",
     row + 2, col 3, "Context Name",
     col 29, "Table Name", col 60,
     "Status", col 77, "Count",
     col 84, "Earliest Date/Time", col 104,
     "Last Date/Time", row + 1, col 1,
     "------------------------------------------------------------------------------------------------------------------------",
     row + 1
    DETAIL
     col 3, ctx_name, col 29,
     tab_name
     IF ((envpair->qual[v_cut].csr[d.seq].csr_status="Errored"))
      col 60, "**Errored**"
     ELSE
      col 60, envpair->qual[v_cut].csr[d.seq].csr_status
     ENDIF
     IF ((envpair->qual[v_cut].csr[d.seq].csr_status="Errored"))
      col 77, "-----"
     ELSE
      col 71, envpair->qual[v_cut].csr[d.seq].csr_tot
     ENDIF
     col 84, envpair->qual[v_cut].csr[d.seq].csr_min_tm"DD-MMM-YYYY HH:MM;;Q", col 104,
     envpair->qual[v_cut].csr[d.seq].csr_max_tm"DD-MMM-YYYY HH:MM;;Q", row + 1
    WITH nocounter, maxcol = 256, formfeed = none
   ;end select
   IF (check_error("Error from executing cutover_sum_print subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE move_hist_print(v_pair)
   DECLARE v_mov = i4
   DECLARE src_info = vc
   DECLARE trg_info = vc
   DECLARE mhp_loop = i4
   DECLARE ctp_cnt = i4
   DECLARE cntx_str = vc
   SET v_mov = v_pair
   SET src_info = concat(envpair->qual[v_mov].src_name," (",trim(cnvtstring(envpair->qual[v_mov].
      src_id)),")")
   SET trg_info = concat(envpair->qual[v_mov].trg_name," (",trim(cnvtstring(envpair->qual[v_mov].
      trg_id)),")")
   SELECT INTO mine
    FROM (dummyt d  WITH seq = envpair->qual[v_mov].mover_cnt)
    HEAD REPORT
     col 40, "******  RDDS STATUS REPORTS  ******", row + 2
    HEAD PAGE
     row + 1, col 3, "RDDS MOVER HISTORY REPORT",
     row + 2, col 3, "Source: ",
     col 13, src_info, row + 1,
     col 3, "Target: ", col 13,
     trg_info, row + 2, col 3,
     "Movers", col 22, "Movers",
     col 41, "Cutover", col 60,
     "Cutover", col 79, "Contexts",
     col 102, "Context", row + 1,
     col 3, "Started", col 22,
     "Stopped", col 41, "Started",
     col 60, "Stopped", col 79,
     "to Pull", col 102, "to Set",
     row + 1, col 1,
     "------------------------------------------------------------------------------------------------------------------------",
     row + 1
    DETAIL
     col 2, envpair->qual[v_mov].mover[d.seq].event_name, row + 1,
     col 3, envpair->qual[v_mov].mover[d.seq].mov_start_tm"DD-MMM-YYYY HH:MM;;Q", col 22,
     envpair->qual[v_mov].mover[d.seq].mov_stop_tm"DD-MMM-YYYY HH:MM;;Q", col 41, envpair->qual[v_mov
     ].mover[d.seq].cut_start_tm"DD-MMM-YYYY HH:MM;;Q",
     col 60, envpair->qual[v_mov].mover[d.seq].cut_stop_tm"DD-MMM-YYYY HH:MM;;Q", ctp_cnt = size(
      envpair->qual[v_mov].mover[d.seq].ctp_list,5)
     FOR (mhp_loop = 1 TO ctp_cnt)
       IF ((envpair->qual[v_mov].mover[d.seq].ctp_list[mhp_loop].values > ""))
        cntx_str = substring(1,22,envpair->qual[v_mov].mover[d.seq].ctp_list[mhp_loop].values), col
        79, cntx_str
       ENDIF
       IF ((envpair->qual[v_mov].mover[d.seq].cts_list[mhp_loop].values > ""))
        cntx_str = substring(1,22,envpair->qual[v_mov].mover[d.seq].cts_list[mhp_loop].values), col
        102, cntx_str
       ENDIF
       row + 1
     ENDFOR
     row + 2
    WITH nocounter, maxcol = 256, formfeed = none
   ;end select
   IF (check_error("Error from executing move_hist_print subroutine")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE main_values(v_sort)
   FREE RECORD drvc_request
   RECORD drvc_request(
     1 current_env_id = f8
     1 paired_env_id = f8
   )
   FREE RECORD drvc_reply
   RECORD drvc_reply(
     1 target_version_nbr = i4
     1 source_version_nbr = i4
     1 valid_status_ind = i2
     1 message = vc
   )
   DECLARE sort_order = i4
   DECLARE pair_val = i4
   CALL clear(17,96)
   CALL video(b)
   CALL echo("Generating RDDS Summary Report...")
   CALL video(n)
   SET message = window
   SET sort_order = v_sort
   SET stat = alterlist(envpair->qual,0)
   SET stat = alterlist(envpair->qual,10)
   SELECT INTO "nl:"
    FROM dm_env_reltn der,
     dm_environment d,
     dm_environment de
    PLAN (der
     WHERE der.relationship_type="REFERENCE MERGE")
     JOIN (d
     WHERE d.environment_id=der.parent_env_id)
     JOIN (de
     WHERE de.environment_id=der.child_env_id)
    ORDER BY d.environment_name
    HEAD REPORT
     envpair->envpair_cnt = 0
    DETAIL
     envpair->envpair_cnt = (envpair->envpair_cnt+ 1)
     IF (mod(envpair->envpair_cnt,10)=1)
      stat = alterlist(envpair->qual,(envpair->envpair_cnt+ 9))
     ENDIF
     envpair->qual[envpair->envpair_cnt].src_id = der.parent_env_id, envpair->qual[envpair->
     envpair_cnt].trg_id = der.child_env_id, envpair->qual[envpair->envpair_cnt].pair_num = envpair->
     envpair_cnt,
     envpair->qual[envpair->envpair_cnt].src_name = d.environment_name, envpair->qual[envpair->
     envpair_cnt].trg_name = de.environment_name
    FOOT REPORT
     stat = alterlist(envpair->qual,envpair->envpair_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Get Paired Environments") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].merge_type = "Not Configured"
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_env_reltn der
    PLAN (d
     WHERE (envpair->qual[d.seq].merge_type="Not Configured"))
     JOIN (der
     WHERE (der.child_env_id=envpair->qual[d.seq].trg_id)
      AND (der.parent_env_id=envpair->qual[d.seq].src_id)
      AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER"))
    DETAIL
     IF (der.relationship_type="AUTO CUTOVER")
      envpair->qual[d.seq].merge_type = "Automatic"
     ELSE
      envpair->qual[d.seq].merge_type = "Planned"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Check if AUTO CUTOVER") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].full_circle = "Disabled"
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_env_reltn der
    PLAN (d
     WHERE (envpair->qual[d.seq].full_circle="Disabled"))
     JOIN (der
     WHERE der.relationship_type="RDDS MOVER CHANGES NOT LOGGED"
      AND (der.parent_env_id=envpair->qual[d.seq].src_id)
      AND (der.child_env_id=envpair->qual[d.seq].trg_id))
    DETAIL
     envpair->qual[d.seq].full_circle = "Enabled"
    WITH nocounter
   ;end select
   IF (check_error("Check FULL CIRCLE") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].ptam_env_name = "Not Configured"
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_env_reltn der,
     dm_environment de
    PLAN (d
     WHERE (envpair->qual[d.seq].ptam_env_name="Not Configured"))
     JOIN (der
     WHERE der.relationship_type IN ("PENDING TARGET AS MASTER", "NO PENDING TARGET AS MASTER")
      AND (der.parent_env_id=envpair->qual[d.seq].src_id)
      AND (der.child_env_id=envpair->qual[d.seq].trg_id))
     JOIN (de
     WHERE de.environment_id=der.child_env_id)
    DETAIL
     IF (der.relationship_type="PENDING TARGET AS MASTER")
      envpair->qual[d.seq].ptam_env_name = de.environment_name
     ELSE
      envpair->qual[d.seq].ptam_env_name = "Disabled"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Check PTAM") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_env_reltn der,
     dm_environment de
    PLAN (d
     WHERE (envpair->qual[d.seq].ptam_env_name="Not Configured"))
     JOIN (der
     WHERE der.relationship_type IN ("PENDING TARGET AS MASTER", "NO PENDING TARGET AS MASTER")
      AND (der.parent_env_id=envpair->qual[d.seq].trg_id)
      AND (der.child_env_id=envpair->qual[d.seq].src_id))
     JOIN (de
     WHERE de.environment_id=der.child_env_id)
    DETAIL
     IF (der.relationship_type="PENDING TARGET AS MASTER")
      envpair->qual[d.seq].ptam_env_name = de.environment_name
     ELSE
      envpair->qual[d.seq].ptam_env_name = "Disabled"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Check PTAM") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].trig_chk = 0
   ENDFOR
   SELECT INTO "nl:"
    y = max(dl.event_dt_tm)
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_rdds_event_log dl
    PLAN (d)
     JOIN (dl
     WHERE (dl.cur_environment_id=envpair->qual[d.seq].src_id)
      AND (dl.paired_environment_id=envpair->qual[d.seq].trg_id)
      AND dl.rdds_event_key="DROPENVIRONMENTTRIGGERS")
    DETAIL
     envpair->qual[d.seq].max_drp_trg = y
    WITH nocounter
   ;end select
   IF (check_error("Check SOURCE/TARGET TRIGGERS") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SELECT INTO "nl:"
    y = max(dl.event_dt_tm)
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_rdds_event_log dl
    PLAN (d)
     JOIN (dl
     WHERE (dl.cur_environment_id=envpair->qual[d.seq].src_id)
      AND (dl.paired_environment_id=envpair->qual[d.seq].trg_id)
      AND dl.rdds_event_key="ADDENVIRONMENTTRIGGERS")
    DETAIL
     envpair->qual[d.seq].max_add_trg = y
    WITH nocounter
   ;end select
   IF (check_error("Check SOURCE/TARGET TRIGGERS") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     IF (cnvtdatetime(envpair->qual[i_cnt].max_add_trg) > cnvtdatetime(envpair->qual[i_cnt].
      max_drp_trg))
      SET envpair->qual[i_cnt].trig_chk = 1
      SET envpair->qual[i_cnt].trig_create_tm = envpair->qual[i_cnt].max_add_trg
     ENDIF
   ENDFOR
   FOR (v_cnt = 1 TO envpair->envpair_cnt)
     SET drvc_request->current_env_id = envpair->qual[v_cnt].trg_id
     SET drvc_request->paired_env_id = envpair->qual[v_cnt].src_id
     EXECUTE dm_rdds_version_check  WITH replace("REQUEST","DRVC_REQUEST"), replace("REPLY",
      "DRVC_REPLY")
     IF (check_error("Check SOURCE/TARGET Versions") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
     IF ((drvc_reply->valid_status_ind=0))
      SET envpair->qual[v_cnt].ver_chk = 0
     ELSE
      SET envpair->qual[v_cnt].ver_chk = 1
     ENDIF
   ENDFOR
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].dblink_chk = 0
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_rdds_event_log dr
    PLAN (d
     WHERE (envpair->qual[d.seq].dblink_chk=0))
     JOIN (dr
     WHERE (dr.cur_environment_id=envpair->qual[d.seq].trg_id)
      AND (dr.paired_environment_id=envpair->qual[d.seq].src_id)
      AND dr.rdds_event_key="CREATINGDBLINK")
    DETAIL
     envpair->qual[d.seq].dblink_chk = 1
    WITH nocounter
   ;end select
   IF (check_error("Check SOURCE/TARGET DB LINK") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     IF ((((envpair->qual[i_cnt].trig_chk=0)) OR ((((envpair->qual[i_cnt].ver_chk=0)) OR ((envpair->
     qual[i_cnt].dblink_chk=0))) )) )
      SET envpair->qual[i_cnt].rdds_ready = "No"
     ELSE
      SET stat = initrec(drcr_config_info)
      SET drcr_config_info->source_env_id = envpair->qual[i_cnt].src_id
      SET drcr_config_info->target_env_id = envpair->qual[i_cnt].trg_id
      CALL drcr_check_all_config(drcr_config_info)
      IF ((drcr_config_info->error_ind=1))
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_main
      ENDIF
      IF ((drcr_config_info->config_complete_ind=1))
       SET envpair->qual[i_cnt].rdds_ready = "Yes"
      ELSE
       SET envpair->qual[i_cnt].rdds_ready = "No"
      ENDIF
     ENDIF
   ENDFOR
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].seq_match = "Not Complete"
     SELECT INTO "nl:"
      y = count(*)
      FROM dm_rdds_event_detail dr
      WHERE dr.dm_rdds_event_log_id IN (
      (SELECT
       dm_rdds_event_log_id
       FROM dm_rdds_event_log dl
       WHERE (dl.cur_environment_id=envpair->qual[i_cnt].trg_id)
        AND (dl.paired_environment_id=envpair->qual[i_cnt].src_id)
        AND dl.rdds_event_key="CREATINGSEQUENCEMATCHROW"))
      DETAIL
       IF (y >= 30)
        envpair->qual[i_cnt].seq_match = "Complete"
       ELSE
        envpair->qual[i_cnt].seq_match = "Not Complete"
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("Get Sequence Match count") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
   ENDFOR
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].xlat_backfill = "Not Complete"
     SELECT INTO "nl:"
      FROM dm_rdds_event_log d
      WHERE d.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
       AND (d.cur_environment_id=envpair->qual[i_cnt].trg_id)
       AND (d.paired_environment_id=envpair->qual[i_cnt].src_id)
       AND d.event_reason > ""
      DETAIL
       IF ((cnvtint(d.event_reason) > envpair->qual[i_cnt].seq_max_cnt))
        envpair->qual[i_cnt].seq_max_cnt = cnvtint(d.event_reason)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("Get Translation Backfill information") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
     SELECT INTO "nl:"
      y = count(DISTINCT dr.event_detail1_txt)
      FROM dm_rdds_event_detail dr,
       dm_rdds_event_log dl
      WHERE (dl.cur_environment_id=envpair->qual[i_cnt].trg_id)
       AND (dl.paired_environment_id=envpair->qual[i_cnt].src_id)
       AND dl.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
       AND dr.dm_rdds_event_log_id=dl.dm_rdds_event_log_id
      HEAD REPORT
       envpair->qual[i_cnt].seq_detail_cnt = 0
      DETAIL
       envpair->qual[i_cnt].seq_detail_cnt = y
      WITH nocounter
     ;end select
     IF (check_error("Get Translation Backfill information") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
     IF ((envpair->qual[i_cnt].seq_detail_cnt=envpair->qual[i_cnt].seq_max_cnt))
      SET envpair->qual[i_cnt].xlat_backfill = "Complete"
     ELSE
      SET envpair->qual[i_cnt].xlat_backfill = "Not Complete"
     ENDIF
   ENDFOR
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].src_usr_chg = "Unknown"
     SET envpair->qual[i_cnt].trg_usr_chg = "Unknown"
     SELECT INTO "nl:"
      FROM dm_rdds_event_detail dr
      WHERE dr.dm_rdds_event_log_id IN (
      (SELECT
       dm_rdds_event_log_id
       FROM dm_rdds_event_log dl
       WHERE (dl.cur_environment_id=envpair->qual[i_cnt].src_id)
        AND dl.rdds_event_key="UNMAPPEDUSERCONTEXTCHANGE"
        AND dl.event_dt_tm IN (
       (SELECT
        max(dl2.event_dt_tm)
        FROM dm_rdds_event_log dl2
        WHERE (dl2.cur_environment_id=envpair->qual[i_cnt].src_id)
         AND dl2.rdds_event_key="UNMAPPEDUSERCONTEXTCHANGE"))))
      DETAIL
       IF (dr.event_detail_value=0)
        envpair->qual[i_cnt].src_usr_chg = "Unmapped users are not allowed to make changes"
       ELSE
        envpair->qual[i_cnt].src_usr_chg = "Unmapped users are allowed to make changes"
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("Users allowed to make changes") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_main
     ENDIF
     IF (curqual=0)
      SET envpair->qual[i_cnt].src_usr_chg = "Unmapped users are allowed to make changes"
     ENDIF
     SELECT INTO "nl:"
      FROM dm_rdds_event_detail dr
      WHERE dr.dm_rdds_event_log_id IN (
      (SELECT
       dm_rdds_event_log_id
       FROM dm_rdds_event_log dl
       WHERE (dl.cur_environment_id=envpair->qual[i_cnt].trg_id)
        AND dl.rdds_event_key="UNMAPPEDUSERCONTEXTCHANGE"
        AND dl.event_dt_tm IN (
       (SELECT
        max(dl2.event_dt_tm)
        FROM dm_rdds_event_log dl2
        WHERE (dl2.cur_environment_id=envpair->qual[i_cnt].trg_id)
         AND dl2.rdds_event_key="UNMAPPEDUSERCONTEXTCHANGE"))))
      DETAIL
       IF (dr.event_detail_value=0)
        envpair->qual[i_cnt].trg_usr_chg = "Unmapped users not allowed to make changes"
       ELSE
        envpair->qual[i_cnt].trg_usr_chg = "Unmapped users allowed to make changes"
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("Users allowed to make changes") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_main
     ENDIF
     IF (curqual=0)
      SET envpair->qual[i_cnt].trg_usr_chg = "Unmapped users are allowed to make changes"
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Determining when tiering last completed."
   SELECT INTO "nl:"
    y = max(dl.event_dt_tm)
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_rdds_event_log dl
    PLAN (d)
     JOIN (dl
     WHERE (dl.cur_environment_id=envpair->qual[d.seq].trg_id)
      AND dl.rdds_event_key="TIERINGINFORMATIONLOADED")
    DETAIL
     envpair->qual[d.seq].max_tier_tm = y
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].xcptn_reset_ind = 1
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_rdds_event_detail dd
    PLAN (d
     WHERE (envpair->qual[d.seq].xcptn_reset_ind=1))
     JOIN (dd
     WHERE dd.dm_rdds_event_log_id IN (
     (SELECT
      max(dr.dm_rdds_event_log_id)
      FROM dm_rdds_event_log dr
      WHERE (dr.cur_environment_id=envpair->qual[d.seq].trg_id)
       AND (dr.paired_environment_id=envpair->qual[d.seq].src_id)
       AND dr.rdds_event_key="CHILDEXCEPTIONSETTINGCHANGE")))
    DETAIL
     envpair->qual[d.seq].xcptn_reset_ind = dd.event_detail_value
    WITH nocounter
   ;end select
   IF (check_error("Check Child Exception Reset Setting") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   FOR (i_cnt = 1 TO envpair->envpair_cnt)
     SET envpair->qual[i_cnt].dual_build_trig_ind = - (1)
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(envpair->envpair_cnt)),
     dm_env_reltn der
    PLAN (d
     WHERE (envpair->qual[d.seq].dual_build_trig_ind=- (1)))
     JOIN (der
     WHERE (der.parent_env_id=envpair->qual[d.seq].src_id)
      AND (der.child_env_id=envpair->qual[d.seq].trg_id)
      AND der.relationship_type IN ("ALLOW DUAL BUILD", "BLOCK DUAL BUILD"))
    DETAIL
     IF (der.relationship_type="BLOCK DUAL BUILD")
      envpair->qual[d.seq].dual_build_trig_ind = 1
     ELSE
      envpair->qual[d.seq].dual_build_trig_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Check Dual Build Trigger Setting") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   IF (sort_order=0)
    SET pair_val = (envpair->envpair_cnt+ 1)
    SET stat = alterlist(envpair->qual,pair_val)
    FOR (i2 = 1 TO (envpair->envpair_cnt - 1))
      FOR (i = 1 TO (envpair->envpair_cnt - 1))
        IF ((envpair->qual[i].rdds_ready > envpair->qual[(i+ 1)].rdds_ready))
         SET envpair->qual[pair_val].src_id = envpair->qual[i].src_id
         SET envpair->qual[pair_val].trg_id = envpair->qual[i].trg_id
         SET envpair->qual[pair_val].src_name = envpair->qual[i].src_name
         SET envpair->qual[pair_val].trg_name = envpair->qual[i].trg_name
         SET envpair->qual[pair_val].merge_type = envpair->qual[i].merge_type
         SET envpair->qual[pair_val].full_circle = envpair->qual[i].full_circle
         SET envpair->qual[pair_val].ptam_env_name = envpair->qual[i].ptam_env_name
         SET envpair->qual[pair_val].trig_chk = envpair->qual[i].trig_chk
         SET envpair->qual[pair_val].ver_chk = envpair->qual[i].ver_chk
         SET envpair->qual[pair_val].up_bndr = envpair->qual[i].up_bndr
         SET envpair->qual[pair_val].lo_bndr = envpair->qual[i].lo_bndr
         SET envpair->qual[pair_val].src_version = envpair->qual[i].src_version
         SET envpair->qual[pair_val].trg_version = envpair->qual[i].trg_version
         SET envpair->qual[pair_val].dblink_chk = envpair->qual[i].dblink_chk
         SET envpair->qual[pair_val].rdds_ready = envpair->qual[i].rdds_ready
         SET envpair->qual[pair_val].seq_match = envpair->qual[i].seq_match
         SET envpair->qual[pair_val].xlat_backfill = envpair->qual[i].xlat_backfill
         SET envpair->qual[pair_val].trig_create_tm = envpair->qual[i].trig_create_tm
         SET envpair->qual[pair_val].max_tier_tm = envpair->qual[i].max_tier_tm
         SET envpair->qual[pair_val].xcptn_reset_ind = envpair->qual[i].xcptn_reset_ind
         SET envpair->qual[pair_val].dual_build_trig_ind = envpair->qual[i].dual_build_trig_ind
         SET envpair->qual[i].src_id = envpair->qual[(i+ 1)].src_id
         SET envpair->qual[i].trg_id = envpair->qual[(i+ 1)].trg_id
         SET envpair->qual[i].src_name = envpair->qual[(i+ 1)].src_name
         SET envpair->qual[i].trg_name = envpair->qual[(i+ 1)].trg_name
         SET envpair->qual[i].merge_type = envpair->qual[(i+ 1)].merge_type
         SET envpair->qual[i].full_circle = envpair->qual[(i+ 1)].full_circle
         SET envpair->qual[i].ptam_env_name = envpair->qual[(i+ 1)].ptam_env_name
         SET envpair->qual[i].trig_chk = envpair->qual[(i+ 1)].trig_chk
         SET envpair->qual[i].ver_chk = envpair->qual[(i+ 1)].ver_chk
         SET envpair->qual[i].up_bndr = envpair->qual[(i+ 1)].up_bndr
         SET envpair->qual[i].lo_bndr = envpair->qual[(i+ 1)].lo_bndr
         SET envpair->qual[i].src_version = envpair->qual[(i+ 1)].src_version
         SET envpair->qual[i].trg_version = envpair->qual[(i+ 1)].trg_version
         SET envpair->qual[i].dblink_chk = envpair->qual[(i+ 1)].dblink_chk
         SET envpair->qual[i].rdds_ready = envpair->qual[(i+ 1)].rdds_ready
         SET envpair->qual[i].seq_match = envpair->qual[(i+ 1)].seq_match
         SET envpair->qual[i].xlat_backfill = envpair->qual[(i+ 1)].xlat_backfill
         SET envpair->qual[i].trig_create_tm = envpair->qual[(i+ 1)].trig_create_tm
         SET envpair->qual[i].max_tier_tm = envpair->qual[(i+ 1)].max_tier_tm
         SET envpair->qual[i].xcptn_reset_ind = envpair->qual[(i+ 1)].xcptn_reset_ind
         SET envpair->qual[i].dual_build_trig_ind = envpair->qual[(i+ 1)].dual_build_trig_ind
         SET envpair->qual[(i+ 1)].src_id = envpair->qual[pair_val].src_id
         SET envpair->qual[(i+ 1)].trg_id = envpair->qual[pair_val].trg_id
         SET envpair->qual[(i+ 1)].src_name = envpair->qual[pair_val].src_name
         SET envpair->qual[(i+ 1)].trg_name = envpair->qual[pair_val].trg_name
         SET envpair->qual[(i+ 1)].merge_type = envpair->qual[pair_val].merge_type
         SET envpair->qual[(i+ 1)].full_circle = envpair->qual[pair_val].full_circle
         SET envpair->qual[(i+ 1)].ptam_env_name = envpair->qual[pair_val].ptam_env_name
         SET envpair->qual[(i+ 1)].trig_chk = envpair->qual[pair_val].trig_chk
         SET envpair->qual[(i+ 1)].ver_chk = envpair->qual[pair_val].ver_chk
         SET envpair->qual[(i+ 1)].up_bndr = envpair->qual[pair_val].up_bndr
         SET envpair->qual[(i+ 1)].lo_bndr = envpair->qual[pair_val].lo_bndr
         SET envpair->qual[(i+ 1)].src_version = envpair->qual[pair_val].src_version
         SET envpair->qual[(i+ 1)].trg_version = envpair->qual[pair_val].trg_version
         SET envpair->qual[(i+ 1)].dblink_chk = envpair->qual[pair_val].dblink_chk
         SET envpair->qual[(i+ 1)].rdds_ready = envpair->qual[pair_val].rdds_ready
         SET envpair->qual[(i+ 1)].seq_match = envpair->qual[pair_val].seq_match
         SET envpair->qual[(i+ 1)].xlat_backfill = envpair->qual[pair_val].xlat_backfill
         SET envpair->qual[(i+ 1)].trig_create_tm = envpair->qual[pair_val].trig_create_tm
         SET envpair->qual[(i+ 1)].max_tier_tm = envpair->qual[pair_val].max_tier_tm
         SET envpair->qual[(i+ 1)].xcptn_reset_ind = envpair->qual[pair_val].xcptn_reset_ind
         SET envpair->qual[(i+ 1)].dual_build_trig_ind = envpair->qual[pair_val].dual_build_trig_ind
        ENDIF
      ENDFOR
    ENDFOR
    FOR (i2 = 1 TO (envpair->envpair_cnt - 1))
      FOR (i = 1 TO (envpair->envpair_cnt - 1))
        IF ((envpair->qual[i].src_name > envpair->qual[(i+ 1)].src_name)
         AND (envpair->qual[i].rdds_ready=envpair->qual[(i+ 1)].rdds_ready))
         SET envpair->qual[pair_val].src_id = envpair->qual[i].src_id
         SET envpair->qual[pair_val].trg_id = envpair->qual[i].trg_id
         SET envpair->qual[pair_val].src_name = envpair->qual[i].src_name
         SET envpair->qual[pair_val].trg_name = envpair->qual[i].trg_name
         SET envpair->qual[pair_val].merge_type = envpair->qual[i].merge_type
         SET envpair->qual[pair_val].full_circle = envpair->qual[i].full_circle
         SET envpair->qual[pair_val].trig_chk = envpair->qual[i].trig_chk
         SET envpair->qual[pair_val].ver_chk = envpair->qual[i].ver_chk
         SET envpair->qual[pair_val].up_bndr = envpair->qual[i].up_bndr
         SET envpair->qual[pair_val].lo_bndr = envpair->qual[i].lo_bndr
         SET envpair->qual[pair_val].src_version = envpair->qual[i].src_version
         SET envpair->qual[pair_val].trg_version = envpair->qual[i].trg_version
         SET envpair->qual[pair_val].dblink_chk = envpair->qual[i].dblink_chk
         SET envpair->qual[pair_val].rdds_ready = envpair->qual[i].rdds_ready
         SET envpair->qual[pair_val].seq_match = envpair->qual[i].seq_match
         SET envpair->qual[pair_val].xlat_backfill = envpair->qual[i].xlat_backfill
         SET envpair->qual[pair_val].trig_create_tm = envpair->qual[i].trig_create_tm
         SET envpair->qual[pair_val].max_tier_tm = envpair->qual[i].max_tier_tm
         SET envpair->qual[pair_val].xcptn_reset_ind = envpair->qual[i].xcptn_reset_ind
         SET envpair->qual[pair_val].dual_build_trig_ind = envpair->qual[i].dual_build_trig_ind
         SET envpair->qual[i].src_id = envpair->qual[(i+ 1)].src_id
         SET envpair->qual[i].trg_id = envpair->qual[(i+ 1)].trg_id
         SET envpair->qual[i].src_name = envpair->qual[(i+ 1)].src_name
         SET envpair->qual[i].trg_name = envpair->qual[(i+ 1)].trg_name
         SET envpair->qual[i].merge_type = envpair->qual[(i+ 1)].merge_type
         SET envpair->qual[i].full_circle = envpair->qual[(i+ 1)].full_circle
         SET envpair->qual[i].trig_chk = envpair->qual[(i+ 1)].trig_chk
         SET envpair->qual[i].ver_chk = envpair->qual[(i+ 1)].ver_chk
         SET envpair->qual[i].up_bndr = envpair->qual[(i+ 1)].up_bndr
         SET envpair->qual[i].lo_bndr = envpair->qual[(i+ 1)].lo_bndr
         SET envpair->qual[i].src_version = envpair->qual[(i+ 1)].src_version
         SET envpair->qual[i].trg_version = envpair->qual[(i+ 1)].trg_version
         SET envpair->qual[i].dblink_chk = envpair->qual[(i+ 1)].dblink_chk
         SET envpair->qual[i].rdds_ready = envpair->qual[(i+ 1)].rdds_ready
         SET envpair->qual[i].seq_match = envpair->qual[(i+ 1)].seq_match
         SET envpair->qual[i].xlat_backfill = envpair->qual[(i+ 1)].xlat_backfill
         SET envpair->qual[i].trig_create_tm = envpair->qual[(i+ 1)].trig_create_tm
         SET envpair->qual[i].max_tier_tm = envpair->qual[(i+ 1)].max_tier_tm
         SET envpair->qual[i].xcptn_reset_ind = envpair->qual[(i+ 1)].xcptn_reset_ind
         SET envpair->qual[i].dual_build_trig_ind = envpair->qual[(i+ 1)].dual_build_trig_ind
         SET envpair->qual[(i+ 1)].src_id = envpair->qual[pair_val].src_id
         SET envpair->qual[(i+ 1)].trg_id = envpair->qual[pair_val].trg_id
         SET envpair->qual[(i+ 1)].src_name = envpair->qual[pair_val].src_name
         SET envpair->qual[(i+ 1)].trg_name = envpair->qual[pair_val].trg_name
         SET envpair->qual[(i+ 1)].merge_type = envpair->qual[pair_val].merge_type
         SET envpair->qual[(i+ 1)].full_circle = envpair->qual[pair_val].full_circle
         SET envpair->qual[(i+ 1)].trig_chk = envpair->qual[pair_val].trig_chk
         SET envpair->qual[(i+ 1)].ver_chk = envpair->qual[pair_val].ver_chk
         SET envpair->qual[(i+ 1)].up_bndr = envpair->qual[pair_val].up_bndr
         SET envpair->qual[(i+ 1)].lo_bndr = envpair->qual[pair_val].lo_bndr
         SET envpair->qual[(i+ 1)].src_version = envpair->qual[pair_val].src_version
         SET envpair->qual[(i+ 1)].trg_version = envpair->qual[pair_val].trg_version
         SET envpair->qual[(i+ 1)].dblink_chk = envpair->qual[pair_val].dblink_chk
         SET envpair->qual[(i+ 1)].rdds_ready = envpair->qual[pair_val].rdds_ready
         SET envpair->qual[(i+ 1)].seq_match = envpair->qual[pair_val].seq_match
         SET envpair->qual[(i+ 1)].xlat_backfill = envpair->qual[pair_val].xlat_backfill
         SET envpair->qual[(i+ 1)].trig_create_tm = envpair->qual[pair_val].trig_create_tm
         SET envpair->qual[(i+ 1)].max_tier_tm = envpair->qual[pair_val].max_tier_tm
         SET envpair->qual[(i+ 1)].xcptn_reset_ind = envpair->qual[pair_val].xcptn_reset_ind
         SET envpair->qual[(i+ 1)].dual_build_trig_ind = envpair->qual[pair_val].dual_build_trig_ind
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(envpair->qual,envpair->envpair_cnt)
   ENDIF
   SET message = nowindow
 END ;Subroutine
 SUBROUTINE detail_rpt_values(v_pair)
   CALL clear(22,96)
   CALL video(b)
   CALL echo("Generating RDDS detail reports...")
   CALL video(n)
   SET message = window
   DECLARE v_source = f8
   DECLARE v_target = f8
   DECLARE started_cnt = i4
   DECLARE stopped_cnt = i4
   DECLARE num_cut = i4
   DECLARE typ_count = i4
   DECLARE mstr_cnt = i4
   DECLARE ctp_cnt = i4
   DECLARE cntx_found_ind = i2
   DECLARE list_cnt = i4
   DECLARE clr_log_type = vc
   DECLARE clr_pos = i4
   DECLARE csr_status = vc
   DECLARE csr_pos = i4
   DECLARE event_pos = i4
   DECLARE lc_loop = i4
   DECLARE drv_event_id = f8
   DECLARE drv_cnt = i4
   SET started_cnt = 0
   SET stopped_cnt = 0
   SET v_source = envpair->qual[v_pair].src_id
   SET v_target = envpair->qual[v_pair].trg_id
   SET envpair->qual[v_pair].begin_datasync_tm = cnvtdatetime("1-JAN-1900 11:00:00")
   SELECT INTO "nl:"
    FROM dm_rdds_event_log d1
    WHERE d1.cur_environment_id=v_target
     AND d1.paired_environment_id=v_source
     AND d1.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND  NOT (d1.event_reason IN (
    (SELECT
     event_reason
     FROM dm_rdds_event_log
     WHERE cur_environment_id=v_target
      AND paired_environment_id=v_source
      AND rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     envpair->qual[v_pair].mov_reason = d1.event_reason, envpair->qual[v_pair].begin_datasync_tm = d1
     .event_dt_tm, drv_event_id = d1.dm_rdds_event_log_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     y = max(d.event_dt_tm)
     FROM dm_rdds_event_log d
     WHERE d.cur_environment_id=v_target
      AND d.paired_environment_id=v_source
      AND d.rdds_event_key="BEGINREFERENCEDATASYNC"
     DETAIL
      envpair->qual[v_pair].begin_datasync_tm = y
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     d.event_reason
     FROM dm_rdds_event_log d
     WHERE d.cur_environment_id=v_target
      AND d.paired_environment_id=v_source
      AND d.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND d.event_dt_tm=cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)
     DETAIL
      envpair->qual[v_pair].mov_reason = d.event_reason, drv_event_id = d.dm_rdds_event_log_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_rdds_event_log d
     WHERE d.cur_environment_id=v_target
      AND d.paired_environment_id=v_source
      AND d.rdds_event_key="ENDREFERENCEDATASYNC"
      AND d.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)
     DETAIL
      envpair->qual[v_pair].end_datasync_tm = d.event_dt_tm
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error("Get end datasync time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SELECT INTO "nl:"
    FROM dm_rdds_event_detail d
    WHERE d.dm_rdds_event_log_id=drv_event_id
     AND d.event_detail1_txt="Cutover by Context Setting"
    DETAIL
     envpair->qual[v_pair].cbc_ind = d.event_detail_value
    WITH nocounter
   ;end select
   IF (check_error("Get cutover by context setting") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SELECT INTO "nl:"
    y = min(d1.event_dt_tm)
    FROM dm_rdds_event_log d1
    WHERE d1.cur_environment_id=v_target
     AND d1.paired_environment_id=v_source
     AND d1.rdds_event_key="STARTINGRDDSMOVERS"
     AND d1.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)
    DETAIL
     envpair->qual[v_pair].mov_start_tm = y
    WITH nocounter
   ;end select
   IF (check_error("Get mover started time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF ((envpair->qual[v_pair].mov_start_tm > 0))
    SELECT INTO "nl:"
     y = max(d1.event_dt_tm)
     FROM dm_rdds_event_log d1
     WHERE d1.cur_environment_id=v_target
      AND d1.paired_environment_id=0.0
      AND d1.rdds_event_key="STOPPINGALLRDDSMOVERS"
      AND d1.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mov_start_tm)
     DETAIL
      envpair->qual[v_pair].mov_stop_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get mover stopped time") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
   ENDIF
   IF ((envpair->qual[v_pair].mov_start_tm != 0)
    AND (envpair->qual[v_pair].mov_stop_tm=0))
    SET envpair->qual[v_pair].mov_notstop = "Running"
   ENDIF
   SELECT INTO "nl:"
    y = max(d.event_dt_tm)
    FROM dm_rdds_event_log d
    WHERE d.cur_environment_id=v_source
     AND d.paired_environment_id=v_target
     AND d.rdds_event_key="DMCHGLOGDATA"
    DETAIL
     envpair->qual[v_pair].mov_asof = y
    WITH nocounter
   ;end select
   IF (check_error("Get as of dt_tm for change log report") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SELECT INTO "nl:"
    d.event_detail2_txt
    FROM dm_rdds_event_detail d
    WHERE d.dm_rdds_event_log_id IN (
    (SELECT
     dm_rdds_event_log_id
     FROM dm_rdds_event_log
     WHERE cur_environment_id=v_target
      AND paired_environment_id=v_source
      AND rdds_event_key="STARTINGRDDSMOVER"
      AND (event_dt_tm=
     (SELECT
      max(event_dt_tm)
      FROM dm_rdds_event_log
      WHERE cur_environment_id=v_target
       AND paired_environment_id=v_source
       AND rdds_event_key="STARTINGRDDSMOVER"
       AND event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))))
     AND d.event_detail1_txt IN ("CONTEXTS TO PULL", "CONTEXT TO SET", "CONTEXT GROUP_IND")
    ORDER BY event_detail1_txt DESC
    DETAIL
     IF (d.event_detail1_txt="CONTEXTS TO PULL")
      IF ((envpair->qual[v_pair].cp_all > " "))
       envpair->qual[v_pair].cp_all = concat(envpair->qual[v_pair].cp_all,"::",d.event_detail2_txt)
      ELSE
       envpair->qual[v_pair].cp_all = d.event_detail2_txt
      ENDIF
     ELSEIF (d.event_detail1_txt="CONTEXT TO SET")
      envpair->qual[v_pair].cw_all = concat(envpair->qual[v_pair].cw_all,"::",d.event_detail2_txt)
     ELSE
      IF (d.event_detail_value=0)
       envpair->qual[v_pair].cw_all = envpair->qual[v_pair].cp_all
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Derive contexts to pull and write") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SELECT INTO "nl:"
    y = min(event_dt_tm)
    FROM dm_rdds_event_log d1
    WHERE d1.cur_environment_id=v_target
     AND d1.paired_environment_id=v_source
     AND d1.rdds_event_key="CUTOVERSTARTED"
     AND d1.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)
    DETAIL
     envpair->qual[v_pair].cut_start_tm = y
    WITH nocounter
   ;end select
   IF (check_error("Get cutover started time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SELECT INTO "nl:"
    y = max(event_dt_tm)
    FROM dm_rdds_event_log d1
    WHERE d1.cur_environment_id=v_target
     AND d1.paired_environment_id=v_source
     AND d1.rdds_event_key="CUTOVERFINISHED"
     AND d1.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].cut_start_tm)
    DETAIL
     envpair->qual[v_pair].cut_stop_tm = y
    WITH nocounter
   ;end select
   IF (check_error("Get cutover stopped time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF ((envpair->qual[v_pair].cbc_ind=1))
    SELECT DISTINCT INTO "nl:"
     d.event_detail2_txt
     FROM dm_rdds_event_detail d
     WHERE d.dm_rdds_event_log_id IN (
     (SELECT
      e.dm_rdds_event_log_id
      FROM dm_rdds_event_log e
      WHERE e.rdds_event_key="CUTOVERSTARTED"
       AND e.cur_environment_id=v_target
       AND e.paired_environment_id=v_source
       AND e.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
     HEAD REPORT
      drv_cnt = 0
     DETAIL
      drv_cnt = (drv_cnt+ 1)
      IF (mod(drv_cnt,10)=1)
       stat = alterlist(envpair->qual[v_pair].cut_ctxt,(drv_cnt+ 9))
      ENDIF
      envpair->qual[v_pair].cut_ctxt[drv_cnt].ctxt_name = d.event_detail2_txt
     FOOT REPORT
      envpair->qual[v_pair].cut_ctxt_cnt = drv_cnt, stat = alterlist(envpair->qual[v_pair].cut_ctxt,
       drv_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Get cutover contexts") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
   ENDIF
   IF ((envpair->qual[v_pair].cut_start_tm != 0)
    AND (envpair->qual[v_pair].cut_stop_tm=0))
    SET envpair->qual[v_pair].cut_notstop = "Running"
    SELECT INTO "nl:"
     x = count(*)
     FROM dm_rdds_event_log d1
     WHERE d1.cur_environment_id=v_target
      AND d1.paired_environment_id=v_source
      AND d1.rdds_event_key="CUTOVERSTARTED"
      AND d1.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)
     DETAIL
      started_cnt = x
     WITH nocounter
    ;end select
    IF (check_error("Get number of started cutover") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     x = count(*)
     FROM dm_rdds_event_log d1
     WHERE d1.cur_environment_id=v_target
      AND d1.paired_environment_id=v_source
      AND d1.rdds_event_key="CUTOVERFINISHED"
      AND d1.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)
     DETAIL
      stopped_cnt = x
     WITH nocounter
    ;end select
    IF (check_error("Get number of finished cutover") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SET num_cut = (started_cnt - stopped_cnt)
    SET envpair->qual[v_pair].cut_running = cnvtstring(num_cut)
   ELSE
    SET envpair->qual[v_pair].cut_running = "0"
   ENDIF
   SELECT INTO "nl:"
    y = max(dl.event_dt_tm)
    FROM dm_rdds_event_log dl
    WHERE dl.cur_environment_id=v_target
     AND dl.paired_environment_id=v_source
     AND dl.rdds_event_key="RTABLEDATA"
     AND dl.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)
    DETAIL
     envpair->qual[v_pair].cut_asof = y
    WITH nocounter
   ;end select
   IF (check_error("Get cutover status as of time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SELECT INTO "NL:"
    FROM dm_rdds_event_detail d
    WHERE d.dm_rdds_event_log_id IN (
    (SELECT
     el.dm_rdds_event_log_id
     FROM dm_rdds_event_log el
     WHERE el.cur_environment_id=v_source
      AND el.paired_environment_id=v_target
      AND el.rdds_event_key="DMCHGLOGDATA"
      AND el.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
    ORDER BY d.event_detail1_txt, d.event_detail2_txt
    HEAD REPORT
     envpair->qual[v_pair].log_cnt = 0
    DETAIL
     envpair->qual[v_pair].log_cnt = (envpair->qual[v_pair].log_cnt+ 1)
     IF (mod(envpair->qual[v_pair].log_cnt,10)=1)
      stat = alterlist(envpair->qual[v_pair].log,(envpair->qual[v_pair].log_cnt+ 9))
     ENDIF
     clr_log_type = d.event_detail1_txt, clr_pos = findstring("::",clr_log_type,1,1), envpair->qual[
     v_pair].log[envpair->qual[v_pair].log_cnt].clr_log_detail = clr_log_type
     IF (clr_pos=0)
      envpair->qual[v_pair].log[envpair->qual[v_pair].log_cnt].clr_log_type = clr_log_type, envpair->
      qual[v_pair].log[envpair->qual[v_pair].log_cnt].clr_log_cntx = d.event_detail3_txt
     ELSE
      envpair->qual[v_pair].log[envpair->qual[v_pair].log_cnt].clr_log_type = substring((clr_pos+ 2),
       size(clr_log_type),clr_log_type), envpair->qual[v_pair].log[envpair->qual[v_pair].log_cnt].
      clr_log_cntx = substring(1,(clr_pos - 1),clr_log_type)
     ENDIF
     envpair->qual[v_pair].log[envpair->qual[v_pair].log_cnt].clr_tab_name = d.event_detail2_txt,
     envpair->qual[v_pair].log[envpair->qual[v_pair].log_cnt].clr_log_tot = d.event_detail_value
    FOOT REPORT
     stat = alterlist(envpair->qual[v_pair].log,envpair->qual[v_pair].log_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Get change log info") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF ((envpair->qual[v_pair].log_cnt > 0))
    SELECT INTO "nl:"
     y = min(ed.event_detail_value)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].log_cnt)),
      dm_rdds_event_detail ed
     PLAN (d
      WHERE (envpair->qual[v_pair].log[d.seq].clr_min_tm=0))
      JOIN (ed
      WHERE ed.dm_rdds_event_log_id IN (
      (SELECT
       el.dm_rdds_event_log_id
       FROM dm_rdds_event_log el
       WHERE el.cur_environment_id=v_source
        AND el.paired_environment_id=v_target
        AND el.rdds_event_key="DMCHGLOGMINDATA"
        AND el.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
       AND (ed.event_detail1_txt=envpair->qual[v_pair].log[d.seq].clr_log_detail)
       AND (ed.event_detail2_txt=envpair->qual[v_pair].log[d.seq].clr_tab_name))
     DETAIL
      envpair->qual[v_pair].log[d.seq].clr_min_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get earliest date for each log type") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_detail_value)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].log_cnt)),
      dm_rdds_event_detail ed
     PLAN (d
      WHERE (envpair->qual[v_pair].log[d.seq].clr_max_tm=0))
      JOIN (ed
      WHERE ed.dm_rdds_event_log_id IN (
      (SELECT
       el.dm_rdds_event_log_id
       FROM dm_rdds_event_log el
       WHERE el.cur_environment_id=v_source
        AND el.paired_environment_id=v_target
        AND el.rdds_event_key="DMCHGLOGMAXDATA"
        AND el.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
       AND (ed.event_detail1_txt=envpair->qual[v_pair].log[d.seq].clr_log_detail)
       AND (ed.event_detail2_txt=envpair->qual[v_pair].log[d.seq].clr_tab_name))
     DETAIL
      envpair->qual[v_pair].log[d.seq].clr_max_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get latest date for each log type") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM dm_rdds_event_detail d
    WHERE d.dm_rdds_event_log_id IN (
    (SELECT
     el.dm_rdds_event_log_id
     FROM dm_rdds_event_log el
     WHERE el.cur_environment_id=v_target
      AND el.paired_environment_id=v_source
      AND el.rdds_event_key IN ("RTABLEDATA", "RTABLEWARNING")
      AND el.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
     AND  NOT (d.event_detail2_txt=" ")
    ORDER BY d.event_detail1_txt, d.event_detail2_txt
    HEAD REPORT
     envpair->qual[v_pair].csr_cnt = 0
    DETAIL
     envpair->qual[v_pair].csr_cnt = (envpair->qual[v_pair].csr_cnt+ 1)
     IF (mod(envpair->qual[v_pair].csr_cnt,10)=1)
      stat = alterlist(envpair->qual[v_pair].csr,(envpair->qual[v_pair].csr_cnt+ 9))
     ENDIF
     csr_status = d.event_detail1_txt, csr_pos = findstring("::",csr_status,1,1), envpair->qual[
     v_pair].csr[envpair->qual[v_pair].csr_cnt].csr_detail = csr_status,
     envpair->qual[v_pair].csr[envpair->qual[v_pair].csr_cnt].csr_tab_name = d.event_detail2_txt
     IF (substring((csr_pos+ 1),size(csr_status),csr_status)="WARNING")
      envpair->qual[v_pair].csr[envpair->qual[v_pair].csr_cnt].csr_status = "Errored"
     ELSEIF (csr_pos=0)
      envpair->qual[v_pair].csr[envpair->qual[v_pair].csr_cnt].csr_status = csr_status, envpair->
      qual[v_pair].csr[envpair->qual[v_pair].csr_cnt].csr_cntx = d.event_detail3_txt, envpair->qual[
      v_pair].csr[envpair->qual[v_pair].csr_cnt].csr_tot = d.event_detail_value
     ELSE
      envpair->qual[v_pair].csr[envpair->qual[v_pair].csr_cnt].csr_status = substring((csr_pos+ 2),
       size(csr_status),csr_status), envpair->qual[v_pair].csr[envpair->qual[v_pair].csr_cnt].
      csr_cntx = substring(1,(csr_pos - 1),csr_status), envpair->qual[v_pair].csr[envpair->qual[
      v_pair].csr_cnt].csr_tot = d.event_detail_value
     ENDIF
    FOOT REPORT
     stat = alterlist(envpair->qual[v_pair].csr,envpair->qual[v_pair].csr_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Get cutover status info") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF ((envpair->qual[v_pair].csr_cnt > 0))
    SELECT INTO "nl:"
     y = min(ed.event_detail_value)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].csr_cnt)),
      dm_rdds_event_detail ed
     PLAN (d
      WHERE (envpair->qual[v_pair].csr[d.seq].csr_min_tm=0)
       AND  NOT ((envpair->qual[v_pair].csr[d.seq].csr_status="Errored")))
      JOIN (ed
      WHERE ed.dm_rdds_event_log_id IN (
      (SELECT
       dm_rdds_event_log_id
       FROM dm_rdds_event_log
       WHERE cur_environment_id=v_target
        AND paired_environment_id=v_source
        AND rdds_event_key="RTABLEMINDATA"
        AND event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
       AND (ed.event_detail1_txt=envpair->qual[v_pair].csr[d.seq].csr_detail)
       AND (ed.event_detail2_txt=envpair->qual[v_pair].csr[d.seq].csr_tab_name))
     DETAIL
      envpair->qual[v_pair].csr[d.seq].csr_min_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get earliest date for each status") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_detail_value)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].csr_cnt)),
      dm_rdds_event_detail ed
     PLAN (d
      WHERE (envpair->qual[v_pair].csr[d.seq].csr_max_tm=0)
       AND  NOT ((envpair->qual[v_pair].csr[d.seq].csr_status="Errored")))
      JOIN (ed
      WHERE ed.dm_rdds_event_log_id IN (
      (SELECT
       dm_rdds_event_log_id
       FROM dm_rdds_event_log
       WHERE cur_environment_id=v_target
        AND paired_environment_id=v_source
        AND rdds_event_key="RTABLEMAXDATA"
        AND event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
       AND (ed.event_detail1_txt=envpair->qual[v_pair].csr[d.seq].csr_detail)
       AND (ed.event_detail2_txt=envpair->qual[v_pair].csr[d.seq].csr_tab_name))
     DETAIL
      envpair->qual[v_pair].csr[d.seq].csr_max_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get latest date for each status") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     ed.event_detail_value
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].csr_cnt)),
      dm_rdds_event_detail ed
     PLAN (d
      WHERE (envpair->qual[v_pair].csr[d.seq].csr_tot=0)
       AND (envpair->qual[v_pair].csr[d.seq].csr_status="Errored"))
      JOIN (ed
      WHERE ed.dm_rdds_event_log_id IN (
      (SELECT
       dl.dm_rdds_event_log_id
       FROM dm_rdds_event_log dl
       WHERE dl.cur_environment_id=v_target
        AND dl.paired_environment_id=v_source
        AND dl.rdds_event_key="RTABLEDATA"
        AND dl.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
       AND ed.event_detail1_txt="UNPROCESSED"
       AND (ed.event_detail2_txt=envpair->qual[v_pair].csr[d.seq].csr_tab_name))
     DETAIL
      envpair->qual[v_pair].csr[d.seq].csr_tot = ed.event_detail_value
     WITH nocounter
    ;end select
    IF (check_error("Get row count for errored tables") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_rdds_event_detail d
    WHERE d.dm_rdds_event_log_id IN (
    (SELECT
     dm_rdds_event_log_id
     FROM dm_rdds_event_log dl
     WHERE dl.cur_environment_id=v_target
      AND dl.paired_environment_id=v_source
      AND dl.rdds_event_key="RTABLEWARNING"
      AND dl.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
     AND  NOT (d.event_detail2_txt=" ")
    HEAD REPORT
     envpair->qual[v_pair].err1_cnt = 0
    DETAIL
     envpair->qual[v_pair].err1_cnt = (envpair->qual[v_pair].err1_cnt+ 1)
     IF (mod(envpair->qual[v_pair].err1_cnt,10)=1)
      stat = alterlist(envpair->qual[v_pair].err,(envpair->qual[v_pair].err1_cnt+ 9))
     ENDIF
     envpair->qual[v_pair].err[envpair->qual[v_pair].err1_cnt].err_tab_name = d.event_detail2_txt,
     envpair->qual[v_pair].err[envpair->qual[v_pair].err1_cnt].err_tab_status = "Errored"
    FOOT REPORT
     stat = alterlist(envpair->qual[v_pair].err,envpair->qual[v_pair].err1_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Get cutover error tables") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SET envpair->qual[v_pair].err_tab_tot = envpair->qual[v_pair].err1_cnt
   IF ((envpair->qual[v_pair].err1_cnt > 0))
    SELECT INTO "nl:"
     ed.event_detail_value
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].err1_cnt)),
      dm_rdds_event_detail ed
     PLAN (d
      WHERE (envpair->qual[v_pair].err[d.seq].err_tab_rows=0))
      JOIN (ed
      WHERE ed.dm_rdds_event_log_id IN (
      (SELECT
       dl.dm_rdds_event_log_id
       FROM dm_rdds_event_log dl
       WHERE dl.cur_environment_id=v_target
        AND dl.paired_environment_id=v_source
        AND dl.rdds_event_key="RTABLEDATA"
        AND dl.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].begin_datasync_tm)))
       AND ed.event_detail1_txt="UNPROCESSED"
       AND (ed.event_detail2_txt=envpair->qual[v_pair].err[d.seq].err_tab_name))
     DETAIL
      envpair->qual[v_pair].err[d.seq].err_tab_rows = ed.event_detail_value, envpair->qual[v_pair].
      err_row_tot = (envpair->qual[v_pair].err_row_tot+ envpair->qual[v_pair].err[d.seq].err_tab_rows
      )
     WITH nocounter
    ;end select
    IF (check_error("Get cutover error row count") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_rdds_event_log el
    WHERE el.cur_environment_id=v_target
     AND el.paired_environment_id=v_source
     AND el.rdds_event_key="BEGINREFERENCEDATASYNC"
    ORDER BY el.event_dt_tm DESC
    HEAD REPORT
     envpair->qual[v_pair].mover_cnt = 0
    DETAIL
     envpair->qual[v_pair].mover_cnt = (envpair->qual[v_pair].mover_cnt+ 1)
     IF (mod(envpair->qual[v_pair].mover_cnt,10)=1)
      stat = alterlist(envpair->qual[v_pair].mover,(envpair->qual[v_pair].mover_cnt+ 9))
     ENDIF
     envpair->qual[v_pair].mover[envpair->qual[v_pair].mover_cnt].event_begin_tm = el.event_dt_tm,
     envpair->qual[v_pair].mover[envpair->qual[v_pair].mover_cnt].event_name = el.event_reason
    FOOT REPORT
     stat = alterlist(envpair->qual[v_pair].mover,envpair->qual[v_pair].mover_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Get datasync start time for bookmark pairs") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF ((envpair->qual[v_pair].mover_cnt > 0))
    SELECT INTO "nl:"
     y = min(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].event_end_tm=0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="ENDREFERENCEDATASYNC"
       AND (ed.event_reason=envpair->qual[v_pair].mover[d.seq].event_name))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].event_end_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get datasync stop time") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = min(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_start_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm != 0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STARTINGRDDSMOVERS"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_begin_tm)
       AND ed.event_dt_tm < cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_end_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_start_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get earliest mover start time for events with end dates") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = min(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_start_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm != 0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STARTINGRDDSMOVER"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_begin_tm)
       AND ed.event_dt_tm < cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_end_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_start_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Check for interactive movers for events with end dates") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = min(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_start_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm=0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STARTINGRDDSMOVERS"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_begin_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_start_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get earliest mover start time for events without end dates") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = min(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_start_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm=0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STARTINGRDDSMOVER"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_begin_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_start_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Check for interactive movers for events without end dates") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_stop_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm != 0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STOPPINGALLRDDSMOVERS"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].mov_start_tm)
       AND ed.event_dt_tm < cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_end_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_stop_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get last mover stop time for movers with end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_stop_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm != 0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STOPPINGRDDSMOVER"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].mov_start_tm)
       AND ed.event_dt_tm < cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_end_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_stop_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get last interactive stop for movers with end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_stop_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm=0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STOPPINGALLRDDSMOVERS"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].mov_start_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_stop_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get last mover stop time for movers without end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].mov_stop_tm=0)
       AND (envpair->qual[v_pair].mover[d.seq].event_end_tm=0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="STOPPINGRDDSMOVER"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].mov_start_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].mov_stop_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get last interactive stop for movers without end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = min(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].event_end_tm != 0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="CUTOVERSTARTED"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_begin_tm)
       AND ed.event_dt_tm < cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_end_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].cut_start_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get earliest cutover start time for events with end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].event_end_tm != 0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="CUTOVERFINISHED"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].cut_start_tm)
       AND ed.event_dt_tm < cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_end_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].cut_stop_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get last cutover stop time for events with end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = min(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].event_end_tm=0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="CUTOVERSTARTED"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].event_begin_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].cut_start_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get earliest cutover start time for events without end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     y = max(ed.event_dt_tm)
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].mover_cnt)),
      dm_rdds_event_log ed
     PLAN (d
      WHERE (envpair->qual[v_pair].mover[d.seq].event_end_tm=0))
      JOIN (ed
      WHERE ed.cur_environment_id=v_target
       AND ed.paired_environment_id=v_source
       AND ed.rdds_event_key="CUTOVERFINISHED"
       AND ed.event_dt_tm > cnvtdatetime(envpair->qual[v_pair].mover[d.seq].cut_start_tm))
     DETAIL
      envpair->qual[v_pair].mover[d.seq].cut_stop_tm = y
     WITH nocounter
    ;end select
    IF (check_error("Get last cutover stop time for events without end events") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    FOR (i = 1 TO envpair->qual[v_pair].mover_cnt)
      SET mstr_cnt = 0
      SELECT INTO "nl:"
       FROM dm_rdds_event_detail ed
       WHERE ed.dm_rdds_event_log_id IN (
       (SELECT
        dm_rdds_event_log_id
        FROM dm_rdds_event_log
        WHERE cur_environment_id=v_target
         AND paired_environment_id=v_source
         AND rdds_event_key="STARTINGRDDSMOVER"
         AND event_dt_tm >= cnvtdatetime(envpair->qual[v_pair].mover[i].mov_start_tm)
         AND event_dt_tm < cnvtdatetime(envpair->qual[v_pair].mover[i].mov_stop_tm)))
        AND ed.event_detail1_txt IN ("CONTEXTS TO PULL", "CONTEXT GROUP_IND", "CONTEXT TO SET")
       ORDER BY ed.dm_rdds_event_log_id
       HEAD ed.dm_rdds_event_log_id
        mstr_cnt = (mstr_cnt+ 1), stat = alterlist(envpair->qual[v_pair].mover[i].mstr_cntx,mstr_cnt)
       DETAIL
        IF (ed.event_detail1_txt="CONTEXTS TO PULL")
         envpair->qual[v_pair].mover[i].context_pull = concat(envpair->qual[v_pair].mover[i].
          context_pull,"::",ed.event_detail2_txt)
         IF ((envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].ctp > " "))
          envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].ctp = concat(envpair->qual[v_pair].
           mover[i].mstr_cntx[mstr_cnt].ctp,"::",ed.event_detail2_txt)
         ELSE
          envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].ctp = ed.event_detail2_txt
         ENDIF
        ELSEIF (ed.event_detail1_txt="CONTEXT TO SET")
         envpair->qual[v_pair].mover[i].context_set = concat(envpair->qual[v_pair].mover[i].
          context_set,"::",ed.event_detail2_txt)
         IF ((envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].cts > " "))
          envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].cts = concat(envpair->qual[v_pair].
           mover[i].mstr_cntx[mstr_cnt].cts,"::",ed.event_detail2_txt)
         ELSE
          envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].cts = ed.event_detail2_txt
         ENDIF
        ELSE
         envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].group_ind = ed.event_detail_value,
         envpair->qual[v_pair].mover[i].mstr_cntx[mstr_cnt].default = ed.event_detail2_txt
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error("Get context values - 1") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_main
      ENDIF
    ENDFOR
    FOR (i = 1 TO value(envpair->qual[v_pair].mover_cnt))
      FOR (ii = 1 TO size(envpair->qual[v_pair].mover[i].mstr_cntx,5))
        IF ((envpair->qual[v_pair].mover[i].mstr_cntx[ii].ctp > ""))
         SET ctp_cnt = parse_cntx(envpair->qual[v_pair].mover[i].mstr_cntx[ii].ctp,"::",pc_contexts)
         SET list_cnt = size(envpair->qual[v_pair].mover[i].ctp_list,5)
         FOR (iii = 1 TO ctp_cnt)
          SET cntx_found_ind = 0
          IF ((envpair->qual[v_pair].mover[i].mstr_cntx[ii].group_ind=1))
           FOR (list_loop = 1 TO list_cnt)
             IF ((envpair->qual[v_pair].mover[i].ctp_list[list_loop].values=pc_contexts->qual[iii].
             values)
              AND (envpair->qual[v_pair].mover[i].cts_list[list_loop].values=envpair->qual[v_pair].
             mover[i].mstr_cntx[ii].cts))
              SET cntx_found_ind = 1
             ENDIF
           ENDFOR
           IF (cntx_found_ind=0)
            SET list_cnt = (list_cnt+ 1)
            SET stat = alterlist(envpair->qual[v_pair].mover[i].ctp_list,list_cnt)
            SET stat = alterlist(envpair->qual[v_pair].mover[i].cts_list,list_cnt)
            SET envpair->qual[v_pair].mover[i].ctp_list[list_cnt].values = pc_contexts->qual[iii].
            values
            SET envpair->qual[v_pair].mover[i].cts_list[list_cnt].values = envpair->qual[v_pair].
            mover[i].mstr_cntx[ii].cts
           ENDIF
          ELSEIF ((envpair->qual[v_pair].mover[i].mstr_cntx[ii].group_ind=0))
           IF ((pc_contexts->qual[iii].values="NULL"))
            FOR (list_loop = 1 TO list_cnt)
              IF ((envpair->qual[v_pair].mover[i].ctp_list[list_loop].values=pc_contexts->qual[iii].
              values)
               AND (envpair->qual[v_pair].mover[i].cts_list[list_loop].values=substring(17,size(
                envpair->qual[v_pair].mover[i].mstr_cntx[ii].default),envpair->qual[v_pair].mover[i].
               mstr_cntx[ii].default)))
               SET cntx_found_ind = 1
              ENDIF
            ENDFOR
            IF (cntx_found_ind=0)
             SET list_cnt = (list_cnt+ 1)
             SET stat = alterlist(envpair->qual[v_pair].mover[i].ctp_list,list_cnt)
             SET stat = alterlist(envpair->qual[v_pair].mover[i].cts_list,list_cnt)
             SET envpair->qual[v_pair].mover[i].ctp_list[list_cnt].values = pc_contexts->qual[iii].
             values
             SET envpair->qual[v_pair].mover[i].cts_list[list_cnt].values = substring(17,size(envpair
               ->qual[v_pair].mover[i].mstr_cntx[ii].default),envpair->qual[v_pair].mover[i].
              mstr_cntx[ii].default)
            ENDIF
           ELSEIF ((pc_contexts->qual[iii].values="ALL"))
            FOR (list_loop = 1 TO list_cnt)
              IF ((envpair->qual[v_pair].mover[i].ctp_list[list_loop].values=pc_contexts->qual[iii].
              values)
               AND (envpair->qual[v_pair].mover[i].cts_list[list_loop].values="<MAINTAIN>"))
               SET cntx_found_ind = 1
              ENDIF
            ENDFOR
            IF (cntx_found_ind=0)
             SET list_cnt = (list_cnt+ 1)
             SET stat = alterlist(envpair->qual[v_pair].mover[i].ctp_list,list_cnt)
             SET stat = alterlist(envpair->qual[v_pair].mover[i].cts_list,list_cnt)
             SET envpair->qual[v_pair].mover[i].ctp_list[list_cnt].values = pc_contexts->qual[iii].
             values
             SET envpair->qual[v_pair].mover[i].cts_list[list_cnt].values = "<MAINTAIN>"
            ENDIF
           ELSE
            FOR (list_loop = 1 TO list_cnt)
              IF ((envpair->qual[v_pair].mover[i].ctp_list[list_loop].values=pc_contexts->qual[iii].
              values)
               AND (envpair->qual[v_pair].mover[i].cts_list[list_loop].values=pc_contexts->qual[iii].
              values))
               SET cntx_found_ind = 1
              ENDIF
            ENDFOR
            IF (cntx_found_ind=0)
             SET list_cnt = (list_cnt+ 1)
             SET stat = alterlist(envpair->qual[v_pair].mover[i].ctp_list,list_cnt)
             SET stat = alterlist(envpair->qual[v_pair].mover[i].cts_list,list_cnt)
             SET envpair->qual[v_pair].mover[i].ctp_list[list_cnt].values = pc_contexts->qual[iii].
             values
             SET envpair->qual[v_pair].mover[i].cts_list[list_cnt].values = pc_contexts->qual[iii].
             values
            ENDIF
           ENDIF
          ENDIF
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((envpair->qual[v_pair].mover_cnt=0))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].log_cnt))
     ORDER BY envpair->qual[v_pair].log[d.seq].clr_log_type
     HEAD REPORT
      typ_count = 0
     DETAIL
      list_cnt = locateval(lc_loop,1,typ_count,envpair->qual[v_pair].log[d.seq].clr_log_type,envpair
       ->qual[v_pair].clr[lc_loop].clr_type)
      IF (list_cnt=0)
       typ_count = (size(envpair->qual[v_pair].clr,5)+ 1), stat = alterlist(envpair->qual[v_pair].clr,
        typ_count), envpair->qual[v_pair].clr[typ_count].clr_type = envpair->qual[v_pair].log[d.seq].
       clr_log_type
      ELSE
       typ_count = list_cnt
      ENDIF
      envpair->qual[v_pair].clr[typ_count].clr_tot = (envpair->qual[v_pair].clr[typ_count].clr_tot+
      envpair->qual[v_pair].log[d.seq].clr_log_tot)
      IF ((((envpair->qual[v_pair].clr[typ_count].clr_min_tm=0)) OR ((envpair->qual[v_pair].clr[
      typ_count].clr_min_tm > envpair->qual[v_pair].log[d.seq].clr_min_tm))) )
       envpair->qual[v_pair].clr[typ_count].clr_min_tm = envpair->qual[v_pair].log[d.seq].clr_min_tm
      ENDIF
      IF ((((envpair->qual[v_pair].clr[typ_count].clr_max_tm=0)) OR ((envpair->qual[v_pair].clr[
      typ_count].clr_max_tm < envpair->qual[v_pair].log[d.seq].clr_max_tm))) )
       envpair->qual[v_pair].clr[typ_count].clr_max_tm = envpair->qual[v_pair].log[d.seq].clr_max_tm
      ENDIF
     FOOT REPORT
      envpair->qual[v_pair].clr_cnt = typ_count
     WITH nocounter
    ;end select
    IF (check_error("Get log type info for domain config report -1") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].csr_cnt))
     WHERE (envpair->qual[v_pair].csr[d.seq].csr_status != "Errored")
     ORDER BY envpair->qual[v_pair].csr[d.seq].csr_status
     HEAD REPORT
      typ_count = 0
     DETAIL
      list_cnt = locateval(lc_loop,1,typ_count,envpair->qual[v_pair].csr[d.seq].csr_status,envpair->
       qual[v_pair].cut[lc_loop].cut_type)
      IF (list_cnt=0)
       typ_count = (size(envpair->qual[v_pair].cut,5)+ 1), stat = alterlist(envpair->qual[v_pair].cut,
        typ_count), envpair->qual[v_pair].cut[typ_count].cut_type = envpair->qual[v_pair].csr[d.seq].
       csr_status
      ELSE
       typ_count = list_cnt
      ENDIF
      envpair->qual[v_pair].cut[typ_count].cut_tot = (envpair->qual[v_pair].cut[typ_count].cut_tot+
      envpair->qual[v_pair].csr[d.seq].csr_tot)
      IF ((((envpair->qual[v_pair].cut[typ_count].cut_min_tm=0)) OR ((envpair->qual[v_pair].cut[
      typ_count].cut_min_tm > envpair->qual[v_pair].csr[d.seq].csr_min_tm))) )
       envpair->qual[v_pair].cut[typ_count].cut_min_tm = envpair->qual[v_pair].csr[d.seq].csr_min_tm
      ENDIF
      IF ((((envpair->qual[v_pair].cut[typ_count].cut_max_tm=0)) OR ((envpair->qual[v_pair].cut[
      typ_count].cut_max_tm < envpair->qual[v_pair].csr[d.seq].csr_max_tm))) )
       envpair->qual[v_pair].cut[typ_count].cut_max_tm = envpair->qual[v_pair].csr[d.seq].csr_max_tm
      ENDIF
     FOOT REPORT
      envpair->qual[v_pair].cut_cnt = typ_count
     WITH nocounter
    ;end select
    IF (check_error("Get count and dates for each status") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
   ELSE
    SET event_pos = 1
    IF (size(envpair->qual[v_pair].mover[event_pos].mstr_cntx,5) > 0)
     SET typ_count = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].log_cnt)),
       (dummyt d2  WITH seq = size(envpair->qual[v_pair].mover[event_pos].ctp_list,5))
      PLAN (d2)
       JOIN (d
       WHERE (envpair->qual[v_pair].log[d.seq].clr_log_cntx=envpair->qual[v_pair].mover[event_pos].
       ctp_list[d2.seq].values))
      DETAIL
       list_cnt = locateval(lc_loop,1,typ_count,envpair->qual[v_pair].log[d.seq].clr_log_type,envpair
        ->qual[v_pair].clr[lc_loop].clr_type)
       IF (list_cnt=0)
        typ_count = (size(envpair->qual[v_pair].clr,5)+ 1), stat = alterlist(envpair->qual[v_pair].
         clr,typ_count), envpair->qual[v_pair].clr[typ_count].clr_type = envpair->qual[v_pair].log[d
        .seq].clr_log_type
       ELSE
        typ_count = list_cnt
       ENDIF
       envpair->qual[v_pair].clr[typ_count].clr_tot = (envpair->qual[v_pair].clr[typ_count].clr_tot+
       envpair->qual[v_pair].log[d.seq].clr_log_tot)
       IF ((((envpair->qual[v_pair].clr[typ_count].clr_min_tm=0)) OR ((envpair->qual[v_pair].clr[
       typ_count].clr_min_tm > envpair->qual[v_pair].log[d.seq].clr_min_tm))) )
        envpair->qual[v_pair].clr[typ_count].clr_min_tm = envpair->qual[v_pair].log[d.seq].clr_min_tm
       ENDIF
       IF ((((envpair->qual[v_pair].clr[typ_count].clr_max_tm=0)) OR ((envpair->qual[v_pair].clr[
       typ_count].clr_max_tm < envpair->qual[v_pair].log[d.seq].clr_max_tm))) )
        envpair->qual[v_pair].clr[typ_count].clr_max_tm = envpair->qual[v_pair].log[d.seq].clr_max_tm
       ENDIF
      FOOT REPORT
       envpair->qual[v_pair].clr_cnt = typ_count
      WITH nocounter
     ;end select
     IF (check_error("Get log type info for domain config report -2") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
     SET typ_count = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].csr_cnt)),
       (dummyt d2  WITH seq = size(envpair->qual[v_pair].mover[event_pos].cts_list,5))
      PLAN (d2)
       JOIN (d
       WHERE (envpair->qual[v_pair].csr[d.seq].csr_cntx=envpair->qual[v_pair].mover[event_pos].
       cts_list[d2.seq].values)
        AND (envpair->qual[v_pair].csr[d.seq].csr_status != "Errored"))
      DETAIL
       list_cnt = locateval(lc_loop,1,typ_count,envpair->qual[v_pair].csr[d.seq].csr_status,envpair->
        qual[v_pair].cut[lc_loop].cut_type)
       IF (list_cnt=0)
        typ_count = (size(envpair->qual[v_pair].cut,5)+ 1), stat = alterlist(envpair->qual[v_pair].
         cut,typ_count), envpair->qual[v_pair].cut[typ_count].cut_type = envpair->qual[v_pair].csr[d
        .seq].csr_status
       ELSE
        typ_count = list_cnt
       ENDIF
       envpair->qual[v_pair].cut[typ_count].cut_tot = (envpair->qual[v_pair].cut[typ_count].cut_tot+
       envpair->qual[v_pair].csr[d.seq].csr_tot)
       IF ((((envpair->qual[v_pair].cut[typ_count].cut_min_tm=0)) OR ((envpair->qual[v_pair].cut[
       typ_count].cut_min_tm > envpair->qual[v_pair].csr[d.seq].csr_min_tm))) )
        envpair->qual[v_pair].cut[typ_count].cut_min_tm = envpair->qual[v_pair].csr[d.seq].csr_min_tm
       ENDIF
       IF ((((envpair->qual[v_pair].cut[typ_count].cut_max_tm=0)) OR ((envpair->qual[v_pair].cut[
       typ_count].cut_max_tm < envpair->qual[v_pair].csr[d.seq].csr_max_tm))) )
        envpair->qual[v_pair].cut[typ_count].cut_max_tm = envpair->qual[v_pair].csr[d.seq].csr_max_tm
       ENDIF
      FOOT REPORT
       envpair->qual[v_pair].cut_cnt = typ_count
      WITH nocounter
     ;end select
     IF (check_error("Get count and dates for each status") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].log_cnt))
      ORDER BY envpair->qual[v_pair].log[d.seq].clr_log_type
      HEAD REPORT
       typ_count = 0
      DETAIL
       list_cnt = locateval(lc_loop,1,typ_count,envpair->qual[v_pair].log[d.seq].clr_log_type,envpair
        ->qual[v_pair].clr[lc_loop].clr_type)
       IF (list_cnt=0)
        typ_count = (size(envpair->qual[v_pair].clr,5)+ 1), stat = alterlist(envpair->qual[v_pair].
         clr,typ_count), envpair->qual[v_pair].clr[typ_count].clr_type = envpair->qual[v_pair].log[d
        .seq].clr_log_type
       ELSE
        typ_count = list_cnt
       ENDIF
       envpair->qual[v_pair].clr[typ_count].clr_tot = (envpair->qual[v_pair].clr[typ_count].clr_tot+
       envpair->qual[v_pair].log[d.seq].clr_log_tot)
       IF ((((envpair->qual[v_pair].clr[typ_count].clr_min_tm=0)) OR ((envpair->qual[v_pair].clr[
       typ_count].clr_min_tm > envpair->qual[v_pair].log[d.seq].clr_min_tm))) )
        envpair->qual[v_pair].clr[typ_count].clr_min_tm = envpair->qual[v_pair].log[d.seq].clr_min_tm
       ENDIF
       IF ((((envpair->qual[v_pair].clr[typ_count].clr_max_tm=0)) OR ((envpair->qual[v_pair].clr[
       typ_count].clr_max_tm < envpair->qual[v_pair].log[d.seq].clr_max_tm))) )
        envpair->qual[v_pair].clr[typ_count].clr_max_tm = envpair->qual[v_pair].log[d.seq].clr_max_tm
       ENDIF
      FOOT REPORT
       envpair->qual[v_pair].clr_cnt = typ_count
      WITH nocounter
     ;end select
     IF (check_error("Get log type info for domain config report -3") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(envpair->qual[v_pair].csr_cnt))
      WHERE (envpair->qual[v_pair].csr[d.seq].csr_status != "Errored")
      ORDER BY envpair->qual[v_pair].csr[d.seq].csr_status
      HEAD REPORT
       typ_count = 0
      DETAIL
       list_cnt = locateval(lc_loop,1,typ_count,envpair->qual[v_pair].csr[d.seq].csr_status,envpair->
        qual[v_pair].cut[lc_loop].cut_type)
       IF (list_cnt=0)
        typ_count = (size(envpair->qual[v_pair].cut,5)+ 1), stat = alterlist(envpair->qual[v_pair].
         cut,typ_count), envpair->qual[v_pair].cut[typ_count].cut_type = envpair->qual[v_pair].csr[d
        .seq].csr_status
       ELSE
        typ_count = list_cnt
       ENDIF
       envpair->qual[v_pair].cut[typ_count].cut_tot = (envpair->qual[v_pair].cut[typ_count].cut_tot+
       envpair->qual[v_pair].csr[d.seq].csr_tot)
       IF ((((envpair->qual[v_pair].cut[typ_count].cut_min_tm=0)) OR ((envpair->qual[v_pair].cut[
       typ_count].cut_min_tm > envpair->qual[v_pair].csr[d.seq].csr_min_tm))) )
        envpair->qual[v_pair].cut[typ_count].cut_min_tm = envpair->qual[v_pair].csr[d.seq].csr_min_tm
       ENDIF
       IF ((((envpair->qual[v_pair].cut[typ_count].cut_max_tm=0)) OR ((envpair->qual[v_pair].cut[
       typ_count].cut_max_tm < envpair->qual[v_pair].csr[d.seq].csr_max_tm))) )
        envpair->qual[v_pair].cut[typ_count].cut_max_tm = envpair->qual[v_pair].csr[d.seq].csr_max_tm
       ENDIF
      FOOT REPORT
       envpair->qual[v_pair].cut_cnt = typ_count
      WITH nocounter
     ;end select
     IF (check_error("Get count and dates for each status") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
    ENDIF
   ENDIF
   SET message = nowindow
 END ;Subroutine
 SUBROUTINE parse_cntx(pc_cntx_str,pc_cntx_delim,pc_cntx_rs)
   DECLARE pc_delim_len = i4
   DECLARE pc_str_len = i4
   DECLARE pc_start = i4
   DECLARE pc_pos = i4
   DECLARE pc_num_found = i4
   DECLARE pc_return = vc
   DECLARE pc_idx = i4
   DECLARE pc_loop = i4
   SET stat = alterlist(pc_cntx_rs->qual,0)
   SET pc_delim_len = size(pc_cntx_delim)
   SET pc_str_len = size(pc_cntx_str)
   SET pc_start = 1
   SET pc_pos = findstring(pc_cntx_delim,pc_cntx_str,pc_start)
   SET pc_num_found = 0
   WHILE (pc_pos > 0)
     SET pc_num_found = (pc_num_found+ 1)
     IF (pc_num_found > 1)
      SET pc_idx = locateval(pc_loop,1,(pc_num_found - 1),substring(pc_start,(pc_pos - pc_start),
        pc_cntx_str),pc_cntx_rs->qual[pc_loop].values)
     ELSE
      SET pc_idx = 0
     ENDIF
     IF (pc_idx=0)
      SET stat = alterlist(pc_cntx_rs->qual,pc_num_found)
      SET pc_cntx_rs->qual[pc_num_found].values = substring(pc_start,(pc_pos - pc_start),pc_cntx_str)
     ELSE
      SET pc_num_found = (pc_num_found - 1)
     ENDIF
     SET pc_start = (pc_pos+ pc_delim_len)
     SET pc_pos = findstring(pc_cntx_delim,pc_cntx_str,pc_start)
   ENDWHILE
   IF (pc_start <= pc_str_len)
    SET pc_num_found = (pc_num_found+ 1)
    IF (pc_num_found > 1)
     SET pc_idx = locateval(pc_loop,1,(pc_num_found - 1),substring(pc_start,(pc_pos - pc_start),
       pc_cntx_str),pc_cntx_rs->qual[pc_loop].values)
    ELSE
     SET pc_idx = 0
    ENDIF
    IF (pc_idx=0)
     SET stat = alterlist(pc_cntx_rs->qual,pc_num_found)
     SET pc_cntx_rs->qual[pc_num_found].values = substring(pc_start,pc_str_len,pc_cntx_str)
    ELSE
     SET pc_num_found = (pc_num_found - 1)
    ENDIF
   ENDIF
   SET pc_idx = 0
   RETURN(pc_num_found)
 END ;Subroutine
#exit_main
 IF ((dm_err->debug_flag >= 1))
  CALL echorecord(envpair)
 ENDIF
 FREE RECORD envpair
 CALL clear(1,1)
 CALL video(n)
 SET message = nowindow
 SET dm_err->eproc = "...Ending DM_AUTO_VERIFY_RPT"
 CALL final_disp_msg("dm_auto_verify_rpt")
END GO
