CREATE PROGRAM dm2_downtime_checker:dba
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
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(rb_data,0)))
  FREE SET rb_data
  RECORD rb_data(
    1 in_house = i2
    1 batch_dt_tm = dq8
    1 env_id = f8
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
    1 readme[*]
      2 id = i4
      2 instance = i4
      2 name = vc
      2 description = vc
      2 ocd = i4
      2 driver_table = vc
      2 driver_count = i4
      2 estimated_time = f8
      2 skip = i2
      2 execution = vc
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 IF (validate(dm2_rr_misc->dm2_toolset_usage," ")=" "
  AND validate(dm2_rr_misc->dm2_toolset_usage,"1")="1")
  FREE RECORD dm2_rr_misc
  RECORD dm2_rr_misc(
    1 dm2_toolset_usage = vc
    1 readme_errors_ind = i2
    1 env_id = f8
    1 batch_dt_tm = dq8
    1 process_type = c2
    1 package_number = i4
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
  )
  SET dm2_rr_misc->dm2_toolset_usage = "NOT_SET"
  SET dm2_rr_misc->readme_errors_ind = 0
  SET dm2_rr_misc->env_id = 0.0
  SET dm2_rr_misc->batch_dt_tm = cnvtdatetimeutc("01-JAN-1800")
  SET dm2_rr_misc->process_type = ""
  SET dm2_rr_misc->package_number = 0
  SET dm2_rr_misc->execution = "NOT_SET"
  SET dm2_rr_misc->low_proj_name = ""
  SET dm2_rr_misc->high_proj_name = ""
 ENDIF
 IF ((validate(dm2_rr_spcchk->readme_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spcchk->readme_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spcchk
  RECORD dm2_rr_spcchk(
    1 space_needed = i2
    1 preup_space_needed = i2
    1 readme_cnt = i4
    1 readme_list[*]
      2 readme_id = f8
      2 spcchk_readme_id = f8
      2 script = vc
      2 tbl_cnt = i4
      2 tbl_list[*]
        3 table_name = vc
        3 large_data_loaded = i2
        3 insert_row_cnt = f8
        3 col_updt_cnt = i4
        3 col_updt[*]
          4 update_row_cnt = f8
          4 column_name = vc
  )
  SET dm2_rr_spcchk->readme_cnt = 0
  SET dm2_rr_spcchk->preup_space_needed = 0
  SET dm2_rr_spcchk->space_needed = 0
 ENDIF
 IF ((validate(dm2_rr_spc_needs->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spc_needs->tbl_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spc_needs
  RECORD dm2_rr_spc_needs(
    1 space_needed = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 skip_ind = i2
      2 large_data_loaded = i2
      2 insert_row_cnt = f8
      2 col_updt_cnt = i4
      2 col_updt[*]
        3 update_row_cnt = f8
        3 column_name = vc
      2 tgt_idx = i4
      2 cur_idx = i4
      2 space_needed = f8
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 tgt_idx = i4
        3 cur_idx = i4
        3 space_needed = f8
  )
  SET dm2_rr_spc_needs->tbl_cnt = 0
 ENDIF
 IF (validate(drr_readmes_to_run->readme_cnt,0)=0
  AND validate(drr_readmes_to_run->readme_cnt,1)=1)
  FREE RECORD drr_readmes_to_run
  RECORD drr_readmes_to_run(
    1 readme_cnt = i4
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 name = vc
      2 description = c50
      2 ocd = i4
      2 execution = vc
      2 execution_order = vc
      2 category = vc
      2 driver_table = vc
      2 execution_time = f8
      2 status = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 skip = i2
      2 driver_count = i4
      2 estimated_time = f8
      2 spchk_readme_cnt = i4
      2 spchk_readme[*]
        3 readme_id = f8
        3 instance = i4
        3 ocd = i4
        3 execution = vc
        3 script = vc
        3 skip = i2
    1 timer_readme_cnt = i4
    1 timer_readme[*]
      2 parent_readme_id = f8
      2 readme_id = f8
      2 instance = i4
      2 ocd = i4
      2 execution = vc
      2 script = vc
      2 skip = i2
    1 inactive_cnt = i4
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ((validate(dm2_rr_defined,- (1))=- (1))
  AND (validate(dm2_rr_defined,- (2))=- (2)))
  DECLARE dm2_rr_defined = i2 WITH public, constant(1)
  DECLARE dm2_rr_error = i2 WITH public, constant(0)
  DECLARE dm2_rr_warning = i2 WITH public, constant(1)
  DECLARE dm2_rr_info = i2 WITH public, constant(2)
  DECLARE dm2_rr_readme = vc WITH public, constant("README")
  DECLARE dm2_rr_dbimport = vc WITH public, constant("DBIMPORT")
  DECLARE dm2_rr_oracle = vc WITH public, constant("ORACLE")
  DECLARE dm2_rr_oracle_ref = vc WITH public, constant("ORACLEREF")
  DECLARE dm2_rr_ccl_dbimport = vc WITH public, constant("CCLDBIMPORT")
  DECLARE dm2_rr_tbl_import = vc WITH public, constant("TABLEIMPORT")
  DECLARE dm2_rr_readme_rback = vc WITH public, constant("README:RBACK")
  DECLARE dm2_rr_running = vc WITH public, constant("RUNNING")
  DECLARE dm2_rr_done = vc WITH public, constant("SUCCESS")
  DECLARE dm2_rr_failed = vc WITH public, constant("FAILED")
  DECLARE dm2_rr_reset = vc WITH public, constant("RESET")
  DECLARE dm2_rr_pre_schema_up = vc WITH public, constant("PREUP")
  DECLARE dm2_rr_post_schema_up = vc WITH public, constant("POSTUP")
  DECLARE dm2_rr_post_schema_up2 = vc WITH public, constant("POSTUP2")
  DECLARE dm2_rr_pre_cycle = vc WITH public, constant("PRECYCLE")
  DECLARE dm2_rr_pre_schema_down = vc WITH public, constant("PREDOWN")
  DECLARE dm2_rr_post_schema_down = vc WITH public, constant("POSTDOWN")
  DECLARE dm2_rr_uptime = vc WITH public, constant("UP")
  DECLARE dm2_rr_timer = vc WITH public, constant("RDMTIMER")
 ENDIF
 IF (validate(drr_killed_appl->appl_cnt,1)=1
  AND validate(drr_killed_appl->appl_cnt,2)=2)
  FREE RECORD drr_killed_appl
  RECORD drr_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET drr_killed_appl->appl_cnt = 0
 ENDIF
 DECLARE dm2_rr_toolset_usage(null) = i2
 DECLARE dm2_rr_clean_stranded_readmes(drcsr_env_id=f8) = i2
 DECLARE drr_load_readmes_to_run(null) = i2
 DECLARE drr_load_space_chk_readmes(dlscr_execution=vc,dlscr_spcchk_flag=i2(ref)) = i2
 DECLARE drr_load_timing_readmes(null) = i2
 DECLARE drr_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 SUBROUTINE dm2_rr_toolset_usage(null)
   DECLARE drtu_found_ind = i2 WITH protect, noconstant(0)
   IF ((dm2_rr_misc->dm2_toolset_usage != "NOT_SET"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   IF (dm2_table_and_ccldef_exists("DM_INFO",drtu_found_ind)=0)
    RETURN(0)
   ENDIF
   IF (drtu_found_ind=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for DM_README_TOOLSET row."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_README_TOOLSET"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm2_rr_misc->dm2_toolset_usage = "N"
   ELSEIF (curqual=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rr_clean_stranded_readmes(drcsr_env_id)
   DECLARE rcsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE rcsr_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE rcsr_error_msg = vc WITH protect, noconstant(" ")
   DECLARE rcsr_load_ind = i2 WITH protect, noconstant(1)
   DECLARE rcsr_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD rcsr_appl_rs
   RECORD rcsr_appl_rs(
     1 rcsr_appl_cnt = i4
     1 rcsr_appl[*]
       2 rcsr_appl_id = vc
       2 rcsr_validity = vc
   )
   SET dm_err->eproc = "Get distinct application ids."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    l.appl_ident
    FROM dm_ocd_log l
    WHERE l.environment_id=drcsr_env_id
     AND l.project_type=dm2_rr_readme
     AND ((l.status=dm2_rr_running) OR (l.status=null))
    HEAD REPORT
     rcsr_cnt = 0
    DETAIL
     rcsr_cnt = (rcsr_cnt+ 1)
     IF (mod(rcsr_cnt,10)=1)
      stat = alterlist(rcsr_appl_rs->rcsr_appl,(rcsr_cnt+ 9))
     ENDIF
     IF (isnumeric(l.appl_ident)=0)
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "INVALID"
     ELSE
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "VALID"
     ENDIF
     rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id = l.appl_ident
    FOOT REPORT
     rcsr_appl_rs->rcsr_appl_cnt = rcsr_cnt, stat = alterlist(rcsr_appl_rs->rcsr_appl,rcsr_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((rcsr_appl_rs->rcsr_appl_cnt > 0))
    SET rcsr_cnt = 0
    FOR (rcsr_cnt = 1 TO rcsr_appl_rs->rcsr_appl_cnt)
      IF ((rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity="INVALID"))
       SET rcsr_error_msg = "Session executing readme is no longer active"
       SET dm_err->eproc = "Update stranded readme process to failed."
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_ocd_log l
        SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(l
           .start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
        WHERE l.environment_id=drcsr_env_id
         AND l.project_type=dm2_rr_readme
         AND ((l.status=dm2_rr_running) OR (l.status = null))
         AND ((l.appl_ident = null) OR ((l.appl_ident=rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
        ))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       CASE (dm2_get_appl_status(value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)))
        OF "I":
         SET dm_err->eproc = "Update inactive readme process to failed."
         SET rcsr_fmt_appl_id = rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id
         IF (drr_alert_killed_appl(rcsr_load_ind,rcsr_fmt_appl_id,rcsr_kill_ind)=0)
          RETURN(0)
         ENDIF
         SET rcsr_load_ind = 0
         IF (rcsr_kill_ind=1)
          SET rcsr_error_msg = dir_kill_clause
         ELSE
          SET rcsr_error_msg = "Session executing readme is no longer active."
         ENDIF
         IF ((dm_err->debug_flag > 0))
          CALL disp_msg(" ",dm_err->logfile,0)
         ENDIF
         UPDATE  FROM dm_ocd_log l
          SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(
             l.start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
          WHERE l.environment_id=drcsr_env_id
           AND l.appl_ident=value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
           AND l.project_type=dm2_rr_readme
           AND ((l.status=dm2_rr_running) OR (l.status = null))
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          RETURN(0)
         ELSE
          COMMIT
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Application Id ",rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 0))
          CALL echo("Error Detected in dm2_get_appl_status")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No application IDs associated with stranded readmes **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_readmes_to_run(null)
   DECLARE dlrr_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD drr_readmes_on_pkg
   RECORD drr_readmes_on_pkg(
     1 cnt = i4
     1 qual[*]
       2 readme_id = f8
       2 instance = i4
       2 ocd = f8
       2 skip = i2
       2 run_once_ind = i2
       2 name = vc
       2 description = c50
       2 execution = vc
       2 category = vc
       2 driver_table = vc
       2 execution_time = f8
       2 skip = i2
       2 driver_count = i4
       2 estimated_time = f8
   )
   IF ((drr_readmes_to_run->readme_cnt > 0))
    SET drr_readmes_to_run->readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->readme,0)
   ENDIF
   IF ((drr_readmes_to_run->inactive_cnt > 0))
    SET drr_readmes_to_run->inactive_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->inactive,0)
   ENDIF
   IF ( NOT ((dm2_rr_misc->process_type IN ("PI", "IH", "MM"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->env_id=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment ID."
    SET dm_err->emsg = "Invalid environment_id."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->process_type="PI"))
    IF ((dm2_rr_misc->package_number=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating package number."
     SET dm_err->emsg =
     "Package number or batch number was 0.  Cannot process readmes for package install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF ( NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
    "PREDOWN", "POSTDOWN", "UP"))))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating process type."
     SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="IH")
    AND ((cnvtint(dm2_rr_misc->low_proj_name) < 0) OR (cnvtint(dm2_rr_misc->high_proj_name) <= 0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating inhouse project range."
    SET dm_err->emsg = "Invalid project range.  Cannot process inhouse readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF ((dm2_rr_misc->process_type="MM")
    AND  NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "PREDOWN", "POSTDOWN",
   "UP"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET rdm_cnt = 0
   SET inactive_cnt = 0
   IF ((dm2_rr_misc->process_type="PI"))
    SET dm_err->eproc = "Gathering list of readmes on plan..."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_readme o
     WHERE (o.ocd=dm2_rr_misc->package_number)
     ORDER BY o.readme_id
     DETAIL
      rdm_cnt = (rdm_cnt+ 1)
      IF (mod(rdm_cnt,100)=1)
       stat = alterlist(drr_readmes_on_pkg->qual,(rdm_cnt+ 99))
      ENDIF
      drr_readmes_on_pkg->qual[rdm_cnt].readme_id = o.readme_id, drr_readmes_on_pkg->qual[rdm_cnt].
      name = trim(cnvtstring(o.readme_id),3), drr_readmes_on_pkg->qual[rdm_cnt].ocd = o.ocd,
      drr_readmes_on_pkg->qual[rdm_cnt].instance = o.instance
     FOOT REPORT
      stat = alterlist(drr_readmes_on_pkg->qual,rdm_cnt), drr_readmes_on_pkg->cnt = rdm_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((drr_readmes_on_pkg->cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (r
      WHERE r.owner=currdbuser
       AND (r.readme_id=drr_readmes_on_pkg->qual[d.seq].readme_id)
       AND (r.instance > drr_readmes_on_pkg->qual[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id)
       AND  NOT (a.inst_mode IN ("PREVIEW", "BATCHPREVIEW")))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       CALL echo(concat("Instance ",build(r.instance)," from ",build(o.ocd)," for readme ",
        build(o.readme_id)," will be skipped due to being inactive on highest instance.")),
       drr_readmes_on_pkg->qual[d.seq].skip = 1
      ELSE
       CALL echo(concat("Replacing Instance ",build(drr_readmes_on_pkg->qual[d.seq].instance),
        " with instance ",build(r.instance)," from ",
        build(o.ocd)," for readme ",build(o.readme_id))), drr_readmes_on_pkg->qual[d.seq].instance =
       r.instance, drr_readmes_on_pkg->qual[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Marking completed readmes as SKIPPED."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND (l.ocd=drr_readmes_on_pkg->qual[d.seq].ocd)
       AND l.status=dm2_rr_done
       AND l.active_ind=1)
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Loading readme metadata."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_readme r,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0))
      JOIN (r
      WHERE (drr_readmes_on_pkg->qual[d.seq].readme_id=r.readme_id)
       AND (drr_readmes_on_pkg->qual[d.seq].instance=r.instance)
       AND r.owner=currdbuser)
     ORDER BY r.readme_id
     HEAD r.readme_id
      drr_readmes_on_pkg->qual[d.seq].readme_id = r.readme_id, drr_readmes_on_pkg->qual[d.seq].
      instance = r.instance, drr_readmes_on_pkg->qual[d.seq].name = trim(cnvtstring(r.readme_id),3),
      drr_readmes_on_pkg->qual[d.seq].execution = cnvtupper(trim(r.execution,3)), drr_readmes_on_pkg
      ->qual[d.seq].description = r.description, drr_readmes_on_pkg->qual[d.seq].driver_table =
      cnvtupper(trim(r.driver_table,3)),
      drr_readmes_on_pkg->qual[d.seq].execution_time = r.execution_time, drr_readmes_on_pkg->qual[d
      .seq].run_once_ind = r.run_once_ind, drr_readmes_on_pkg->qual[d.seq].estimated_time = 0,
      drr_readmes_on_pkg->qual[d.seq].driver_count = 0, drr_readmes_on_pkg->qual[d.seq].skip =
      evaluate(r.active_ind,0,1,0)
      IF ((drr_readmes_on_pkg->qual[d.seq].skip=1))
       CALL echo(concat("Skipping inactive readme ",build(r.readme_id)," instance ",build(r.instance)
        ))
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Skipping RUN ONCE Readmes"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0)
       AND (drr_readmes_on_pkg->qual[d.seq].run_once_ind=1))
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND l.status=dm2_rr_done
       AND l.active_ind=1
       AND (l.project_instance=drr_readmes_on_pkg->qual[d.seq].instance))
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_on_pkg)
    ENDIF
    SET rdm_cnt = 0
    FOR (dlrr_cnt = 1 TO drr_readmes_on_pkg->cnt)
      IF ((((dm2_rr_misc->execution != "ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution=dm2_rr_misc->execution)) OR ((dm2_rr_misc->
      execution="ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution IN ("PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
      "PREDOWN",
      "POSTDOWN", "UP")))) )
       IF ((drr_readmes_on_pkg->qual[dlrr_cnt].skip=1)
        AND (drr_readmes_on_pkg->qual[dlrr_cnt].run_once_ind=1))
        CALL echo(concat("Skip run once readme:",drr_readmes_on_pkg->qual[dlrr_cnt].name))
       ELSE
        SET rdm_cnt = (rdm_cnt+ 1)
        SET stat = alterlist(drr_readmes_to_run->readme,rdm_cnt)
        SET drr_readmes_to_run->readme[rdm_cnt].readme_id = drr_readmes_on_pkg->qual[dlrr_cnt].
        readme_id
        SET drr_readmes_to_run->readme[rdm_cnt].instance = drr_readmes_on_pkg->qual[dlrr_cnt].
        instance
        SET drr_readmes_to_run->readme[rdm_cnt].name = drr_readmes_on_pkg->qual[dlrr_cnt].name
        SET drr_readmes_to_run->readme[rdm_cnt].execution = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution
        SET drr_readmes_to_run->readme[rdm_cnt].description = drr_readmes_on_pkg->qual[dlrr_cnt].
        description
        SET drr_readmes_to_run->readme[rdm_cnt].ocd = drr_readmes_on_pkg->qual[dlrr_cnt].ocd
        SET drr_readmes_to_run->readme[rdm_cnt].driver_table = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_table
        SET drr_readmes_to_run->readme[rdm_cnt].execution_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution_time
        SET drr_readmes_to_run->readme[rdm_cnt].estimated_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        estimated_time
        SET drr_readmes_to_run->readme[rdm_cnt].driver_count = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_count
        SET drr_readmes_to_run->readme[rdm_cnt].skip = drr_readmes_on_pkg->qual[dlrr_cnt].skip
        SET drr_readmes_to_run->readme_cnt = rdm_cnt
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_to_run)
    ENDIF
    IF ((drr_readmes_to_run->readme_cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET rdm_cnt = 0
    FOR (rdm_cnt = 1 TO drr_readmes_to_run->readme_cnt)
      IF ((drr_readmes_to_run->readme[rdm_cnt].skip=0))
       CALL echo(concat("Readme ",build(drr_readmes_to_run->readme[rdm_cnt].readme_id)," will run."))
      ENDIF
    ENDFOR
   ELSEIF ((dm2_rr_misc->process_type="IH"))
    SET dm_err->eproc = "Getting list of readmes for inhouse processing."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     r.readme_id
     FROM dm_project_status_env s,
      dm_readme r
     PLAN (s
      WHERE (s.environment_id=dm2_rr_misc->env_id)
       AND s.proj_type=dm2_rr_readme
       AND cnvtint(s.proj_name) > 0
       AND s.proj_name BETWEEN dm2_rr_misc->low_proj_name AND dm2_rr_misc->high_proj_name
       AND s.dm_status = null)
      JOIN (r
      WHERE r.readme_id=cnvtint(s.proj_name)
       AND r.instance=s.source_set_instance
       AND r.owner=currdbuser)
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind)
       rdm_cnt = (rdm_cnt+ 1)
       IF (mod(rdm_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
       ENDIF
       drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
       rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
         .readme_id),3),
       drr_readmes_to_run->readme[rdm_cnt].execution = cnvtupper(trim(r.execution,3)),
       drr_readmes_to_run->readme[rdm_cnt].description = trim(r.description,3), drr_readmes_to_run->
       readme[rdm_cnt].driver_table = cnvtupper(trim(r.driver_table,3)),
       drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
       readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       IF ((drr_readmes_to_run->readme[rdm_cnt].execution IN ("PRESPCHK", "POSTSPCHK", "RDMTIMER")))
        drr_readmes_to_run->readme[rdm_cnt].skip = 1
       ENDIF
      ELSE
       inactive_cnt = (inactive_cnt+ 1)
       IF (mod(inactive_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->inactive,(inactive_cnt+ 9))
       ENDIF
       drr_readmes_to_run->inactive[inactive_cnt].name = trim(cnvtstring(r.readme_id),3),
       drr_readmes_to_run->inactive[inactive_cnt].instance = r.instance
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_readmes_to_run->inactive,inactive_cnt), stat = alterlist(
       drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt,
      drr_readmes_to_run->inactive_cnt = inactive_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="MM"))
    SET dm_err->eproc = "Gathering list of readmes to run..."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (validate(doc->source_ocd_cnt,- (1)) > 0)
     SELECT INTO "nl:"
      FROM dm_ocd_readme o,
       dm_readme r,
       (dummyt d  WITH seq = value(doc->source_ocd_cnt))
      PLAN (d)
       JOIN (o
       WHERE (o.ocd=doc->qual[d.seq].ocd_nbr))
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        l.project_name
        FROM dm_ocd_log l,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (l.environment_id=dm2_rr_misc->env_id)
         AND l.project_type=dm2_rr_readme
         AND l.ocd > 0
         AND l.project_name=trim(cnvtstring(x.readme_id),3)
         AND l.project_instance >= r.instance
         AND l.status=dm2_rr_done
         AND l.active_ind=1))))
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD REPORT
       row + 0
      HEAD r.readme_id
       IF (r.active_ind=1
        AND (r.execution=dm2_rr_misc->execution))
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
          .readme_id),3),
        drr_readmes_to_run->readme[rdm_cnt].description = r.description, drr_readmes_to_run->readme[
        rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].driver_table = cnvtupper(trim(r
          .driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Marking completed readmes as SKIPPED."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      l.status
      FROM dm_ocd_log l,
       (dummyt d  WITH seq = value(rdm_cnt))
      PLAN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND (l.project_name=drr_readmes_to_run->readme[d.seq].name)
        AND (l.ocd=drr_readmes_to_run->readme[d.seq].ocd)
        AND l.status=dm2_rr_done
        AND l.active_ind=1)
      DETAIL
       drr_readmes_to_run->readme[d.seq].skip = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      status = decode(l.seq,l.status,"NOT RUN"), start_dt_tm = decode(l.seq,l.start_dt_tm,
       cnvtdatetime(curdate,curtime)), end_dt_tm = decode(l.seq,l.end_dt_tm,cnvtdatetime(curdate,
        curtime))
      FROM dm_alpha_features_env a,
       dm_ocd_readme o,
       dm_readme r,
       dm_ocd_log l,
       dummyt d
      PLAN (a
       WHERE (a.environment_id=dm2_rr_misc->env_id)
        AND a.curr_migration_ind=1)
       JOIN (o
       WHERE o.ocd=a.alpha_feature_nbr)
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        m.project_name
        FROM dm_ocd_log m,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (m.environment_id=dm2_rr_misc->env_id)
         AND m.project_type=dm2_rr_readme
         AND m.project_name=trim(cnvtstring(x.readme_id),3)
         AND m.status=dm2_rr_done
         AND m.ocd != o.ocd))))
       JOIN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND trim(cnvtstring(r.readme_id),3)=l.project_name
        AND l.ocd=o.ocd
        AND l.project_instance=r.instance)
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD r.readme_id
       IF (r.active_ind=1)
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].description = trim(r
         .description),
        drr_readmes_to_run->readme[rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].
        execution = cnvtupper(trim(r.execution,3)), drr_readmes_to_run->readme[rdm_cnt].driver_table
         = cnvtupper(trim(r.driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].status = status, drr_readmes_to_run->readme[rdm_cnt].start_dt_tm =
        start_dt_tm,
        drr_readmes_to_run->readme[rdm_cnt].end_dt_tm = end_dt_tm, drr_readmes_to_run->readme[rdm_cnt
        ].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter, outerjoin = d
     ;end select
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_space_chk_readmes(dlscr_execution,dlscr_spcchk_flag)
   DECLARE dlscr_dyn_where = vc WITH protect, noconstant("")
   IF (dlscr_execution="ALL")
    SET dlscr_dyn_where = "r.execution in ('PRESPCHK', 'POSTSPCHK')"
   ELSE
    SET dlscr_dyn_where = concat('r.execution = "',trim(dlscr_execution),'"')
   ENDIF
   SET dm_err->eproc = "Find readmes that require space check."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_readme r,
     dm_ocd_readme o,
     dm_alpha_features_env a,
     (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    PLAN (d
     WHERE (drr_readmes_to_run->readme[d.seq].skip=0))
     JOIN (r
     WHERE (r.parent_readme_id=drr_readmes_to_run->readme[d.seq].readme_id)
      AND parser(dlscr_dyn_where)
      AND r.owner=currdbuser)
     JOIN (o
     WHERE o.readme_id=r.readme_id
      AND o.ocd > 0
      AND o.instance=r.instance)
     JOIN (a
     WHERE a.alpha_feature_nbr=o.ocd
      AND (a.environment_id=dm2_rr_misc->env_id))
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD r.readme_id
     IF (r.active_ind=1)
      dlscr_spcchk_flag = 1, drr_readmes_to_run->readme[d.seq].spchk_readme_cnt = (drr_readmes_to_run
      ->readme[d.seq].spchk_readme_cnt+ 1), stat = alterlist(drr_readmes_to_run->readme[d.seq].
       spchk_readme,drr_readmes_to_run->readme[d.seq].spchk_readme_cnt),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].instance = r.instance, drr_readmes_to_run->
      readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].ocd = o.ocd,
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].execution = r.execution, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].script = cnvtupper(r.script),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].skip = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_timing_readmes(null)
   SET dm_err->eproc = "Gathering timing readme data"
   CALL disp_msg("",dm_err->logfile,0)
   SET timer_cnt = 0
   IF ((drr_readmes_to_run->timer_readme_cnt > 0))
    SET drr_readmes_to_run->timer_readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->timer_readme,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_readme o,
     dm_readme r
    PLAN (o
     WHERE (o.ocd=dm2_rr_misc->package_number))
     JOIN (r
     WHERE r.owner=currdbuser
      AND r.readme_id=o.readme_id
      AND r.instance=o.instance
      AND r.execution="RDMTIMER")
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD REPORT
     row + 0
    HEAD r.readme_id
     IF (r.active_ind=1)
      timer_cnt = (timer_cnt+ 1)
      IF (mod(timer_cnt,10)=1)
       stat = alterlist(drr_readmes_to_run->timer_readme,(timer_cnt+ 9))
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].readme_id = r.readme_id
      IF (r.parent_readme_id > 0)
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = r.parent_readme_id
      ELSE
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = 0
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].instance = r.instance, drr_readmes_to_run->
      timer_readme[timer_cnt].ocd = o.ocd, drr_readmes_to_run->timer_readme[timer_cnt].execution = r
      .execution,
      drr_readmes_to_run->timer_readme[timer_cnt].script = cnvtupper(r.script), drr_readmes_to_run->
      timer_readme[timer_cnt].skip = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_readmes_to_run->timer_readme,timer_cnt), drr_readmes_to_run->
     timer_readme_cnt = timer_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Find highest instance of timing readmes"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((drr_readmes_to_run->timer_readme_cnt=0))
    SET dm_err->eproc = "No Category 8 readmes found to run."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ELSE
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt))
     PLAN (d)
      JOIN (r
      WHERE (r.readme_id=drr_readmes_to_run->timer_readme[d.seq].readme_id)
       AND (r.instance > drr_readmes_to_run->timer_readme[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       drr_readmes_to_run->timer_readme[d.seq].skip = 1
      ELSE
       drr_readmes_to_run->timer_readme[d.seq].instance = r.instance, drr_readmes_to_run->
       timer_readme[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Update skip flag on timing readmes"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt)),
      (dummyt d2  WITH seq = value(drr_readmes_to_run->readme_cnt))
     PLAN (d
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id > 0))
      JOIN (d2
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id=drr_readmes_to_run->readme[d2
      .seq].readme_id))
     DETAIL
      drr_readmes_to_run->timer_readme[d.seq].skip = drr_readmes_to_run->readme[d2.seq].skip
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
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
      drr_killed_appl->appl_cnt = 0
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
       drr_killed_appl->appl_cnt += 1
       IF (mod(drr_killed_appl->appl_cnt,10)=1)
        stat = alterlist(drr_killed_appl->appl,(drr_killed_appl->appl_cnt+ 9))
       ENDIF
       drr_killed_appl->appl[drr_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_killed_appl->appl,drr_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,drr_killed_appl->appl_cnt,daka_fmt_appl_id,
     drr_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE get_batch_dm_ocd_readme(gbr_gbdor_plan_id=f8,gbr_gbdor_eid=f8) = i2
 DECLARE delete_loop(sbr_dl_table=vc,sbr_dl_column=vc,sbr_dl_package_str=vc,sbr_dl_owner_ind=i2) = i2
 RECORD dgbc_data(
   1 dat_qual[*]
     2 owner = c30
     2 table_name = c30
     2 alpha_feature_nbr = f8
   1 cvs_qual[*]
     2 code_set = f8
     2 alpha_feature_nbr = f8
   1 app_qual[*]
     2 application_number = i4
     2 alpha_feature_nbr = f8
   1 tsk_qual[*]
     2 task_number = i4
     2 alpha_feature_nbr = f8
   1 req_qual[*]
     2 request_number = i4
     2 alpha_feature_nbr = f8
   1 atr_qual[*]
     2 application_number = i4
     2 task_number = i4
     2 alpha_feature_nbr = f8
   1 trr_qual[*]
     2 task_number = i4
     2 request_number = i4
     2 alpha_feature_nbr = f8
   1 rdm_qual[*]
     2 readme_id = i4
     2 ocd = i4
   1 prgtemp_cnt = i4
   1 prgtmp_qual[*]
     2 template_nbr = f8
     2 ocd = f8
     2 owner = c30
 )
 SUBROUTINE get_batch_dm_ocd_readme(gbr_gbdor_plan_id,gbr_gbdor_eid)
   DECLARE gbr_gbdor_rdm_cnt = i4 WITH protect, noconstant(0)
   IF (delete_loop("dm_ocd_readme","ocd",build(gbr_gbdor_plan_id),1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    dor.readme_id, dor.instance
    FROM dm_ocd_readme dor,
     dm_install_plan dip,
     dm_readme dr
    WHERE dip.install_plan_id=abs(gbr_gbdor_plan_id)
     AND dip.package_number=dor.ocd
     AND dor.readme_id=dr.readme_id
     AND dor.instance=dr.instance
     AND dr.owner=currdbuser
    ORDER BY dor.readme_id, dor.instance
    HEAD REPORT
     rdmcnt = 0
    HEAD dor.readme_id
     rdmcnt = (rdmcnt+ 1)
     IF (mod(rdmcnt,100)=1)
      stat = alterlist(dgbc_data->rdm_qual,(rdmcnt+ 99))
     ENDIF
    FOOT  dor.readme_id
     dgbc_data->rdm_qual[rdmcnt].readme_id = dor.readme_id, dgbc_data->rdm_qual[rdmcnt].ocd = dor.ocd
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("readme_id: [",dor.readme_id,"] instance: [",dor.instance,"] package number: [",
       dor.ocd,"]"))
     ENDIF
    FOOT REPORT
     stat = alterlist(dgbc_data->rdm_qual,rdmcnt)
    WITH nocounter
   ;end select
   IF (check_error("Installation Failed. Error while getting the latest readmes for the plan.")=1)
    CALL end_status(dm_err->eproc,gbr_gbdor_eid,gbr_gbdor_plan_id)
    RETURN(0)
   ENDIF
   FOR (gbr_gbdor_rdm_cnt = 1 TO size(dgbc_data->rdm_qual,5))
    INSERT  FROM dm_ocd_readme
     (ocd, readme_id, instance)(SELECT
      gbr_gbdor_plan_id, dor.readme_id, dor.instance
      FROM dm_ocd_readme dor
      WHERE (dor.readme_id=dgbc_data->rdm_qual[gbr_gbdor_rdm_cnt].readme_id)
       AND (dor.ocd=dgbc_data->rdm_qual[gbr_gbdor_rdm_cnt].ocd))
     WITH nocounter
    ;end insert
    IF (check_error("Installation Failed. Error while adding the latest readmes to the plan.")=1)
     CALL end_status(dm_err->eproc,gbr_gbdor_eid,gbr_gbdor_plan_id)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE delete_loop(sbr_dl_table,sbr_dl_column,sbr_dl_package_str,sbr_dl_owner_ind)
   DECLARE sbr_dl_qual_ind = i2 WITH protect, noconstant(1)
   DECLARE sbr_dl_maxqual = c5 WITH protect, constant("10000")
   DECLARE sbr_dl_prse_str = vc WITH protect, noconstant(" ")
   DECLARE sbr_dl_owner_str = vc WITH protect, noconstant(" ")
   IF (sbr_dl_owner_ind=1)
    IF (cnvtupper(sbr_dl_table)="DM_OCD_README")
     SET sbr_dl_owner_str = concat(" and exists (select 'x' from dm_readme dr ",
      "where dr.readme_id = t.readme_id and dr.owner = currdbuser)")
    ELSEIF (cnvtupper(sbr_dl_table) IN ("DM_ADM_PURGE_TOKEN", "DM_ADM_PURGE_TABLE"))
     SET sbr_dl_owner_str = concat(" and exists (select 'x' from dm_adm_purge_template d ",
      "where d.template_nbr = t.template_nbr and d.owner = currdbuser)")
    ELSE
     SET sbr_dl_owner_str = " and t.owner = currdbuser"
    ENDIF
   ENDIF
   SET sbr_dl_prse_str = concat("delete from ",sbr_dl_table," t where ",build("t.",sbr_dl_column),
    " = ",
    sbr_dl_package_str,sbr_dl_owner_str," with nocounter, maxqual(",sbr_dl_table,",",
    sbr_dl_maxqual,") go")
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("delete_loop executing: ",sbr_dl_prse_str)
    CALL echo(dm_err->asterisk_line)
    CALL echo(dm_err->eproc)
    CALL echo(dm_err->asterisk_line)
   ENDIF
   WHILE (sbr_dl_qual_ind > 0)
     CALL parser(sbr_dl_prse_str)
     IF (check_error(concat("Error deleting from ",sbr_dl_table,"."))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     SET sbr_dl_qual_ind = curqual
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 DECLARE dac_get_pkgdir(dgp_pkg=i4,dgp_pkg_loc=vc(ref)) = i2
 DECLARE dac_chk_batchover(dcb_batchcnt=i4(ref)) = i2
 DECLARE dac_pop_coldic_rec(dpcr_tab_in=vc) = i2
 DECLARE dac_prelim(dp_pkg=i4,dp_loc_ret=vc(ref),dp_batch_ret=i4(ref)) = i2
 DECLARE load_package_schema_csv(lpsc_eid=f8,lpsc_pkg_int=i4) = i2
 DECLARE determine_admin_load_method(dalm_pkg_in=i4,dalm_meth_out=i2(ref)) = i2
 DECLARE dac_parse_load_data_csv(pldc_pkg_in=f8,pldc_load_all_ind=i2) = i2
 DECLARE dac_load_cload(lc_pkg_in=f8) = i2
 DECLARE dac_aload_method_override_val = vc WITH protect, noconstant("NOT SET")
 DECLARE dac_aload_csv_file_loc = vc WITH protect, noconstant("")
 DECLARE ic_cnt = i4 WITH protect, noconstant(0)
 DECLARE init_csvcontentrow(ic_init_value=vc) = i2
 IF (validate(dac_ocd_txt_data->pkg,- (1)) < 0)
  FREE RECORD dac_ocd_txt_data
  RECORD dac_ocd_txt_data(
    1 pkg = i4
    1 file = vc
    1 archive_date = dq8
    1 type[*]
      2 name = vc
      2 rows = i4
  )
  SET dac_ocd_txt_data->file = "DM2NOTSET"
  SET dac_ocd_txt_data->pkg = 0
  SET dac_ocd_txt_data->archive_date = 0
 ENDIF
 IF (validate(dac_col_list->tbl,"-x")="-x"
  AND validate(dac_col_list->tbl,"-y")="-y")
  FREE RECORD dac_col_list
  RECORD dac_col_list(
    1 tbl = vc
    1 col[*]
      2 col_name = vc
      2 col_type = vc
  )
 ENDIF
 IF ((validate(csvcontent->csv_txt_version,- (1))=- (1))
  AND (validate(csvcontent->csv_txt_version,- (2))=- (2)))
  FREE RECORD csvcontent
  RECORD csvcontent(
    1 csv_txt_version = i4
    1 csv_packaging_field_cnt = i4
    1 csv_installation_field_cnt = i4
    1 prev_sch_inst_on_pkg = i4
    1 qual[*]
      2 table_name = vc
      2 filename = vc
      2 fileversion = vc
      2 loadscript = vc
      2 row_count = vc
      2 passive_ind = vc
      2 owner = vc
  )
 ENDIF
 SUBROUTINE init_csvcontentrow(ic_init_value)
   SET ic_cnt = 0
   SET ic_cnt = (size(csvcontent->qual,5)+ 1)
   SET stat = alterlist(csvcontent->qual,ic_cnt)
   SET csvcontent->qual[ic_cnt].table_name = ic_init_value
   SET csvcontent->qual[ic_cnt].filename = ic_init_value
   SET csvcontent->qual[ic_cnt].fileversion = ic_init_value
   SET csvcontent->qual[ic_cnt].loadscript = ic_init_value
   SET csvcontent->qual[ic_cnt].row_count = ic_init_value
   SET csvcontent->qual[ic_cnt].passive_ind = ic_init_value
   SET csvcontent->qual[ic_cnt].owner = ic_init_value
 END ;Subroutine
 SUBROUTINE dac_pop_coldic_rec(dpcr_tab_in)
   DECLARE dpcr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpcr_idx = i4 WITH protect, noconstant(0)
   DECLARE dcpr_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpr_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dpcr_data_type = vc WITH protect, noconstant("")
   SET stat = alterlist(dac_col_list->col,0)
   SET dac_col_list->tbl = ""
   SET dac_col_list->tbl = cnvtupper(dpcr_tab_in)
   SET dm_err->eproc = concat("Get list of columns in dictionary for ",dac_col_list->tbl)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FOR (dpcr_idx = 1 TO size(columns_1->list_1,5))
     SET dcpr_col_oradef_ind = 0
     SET dcpr_col_ccldef_ind = 0
     SET dpcr_data_type = ""
     IF (dm2_table_column_exists("",dac_col_list->tbl,columns_1->list_1[dpcr_idx].field_name,0,1,
      2,dcpr_col_oradef_ind,dcpr_col_ccldef_ind,dpcr_data_type)=0)
      RETURN(0)
     ENDIF
     IF (dcpr_col_ccldef_ind=1)
      SET dpcr_cnt = (dpcr_cnt+ 1)
      SET stat = alterlist(dac_col_list->col,dpcr_cnt)
      SET dac_col_list->col[dpcr_cnt].col_name = columns_1->list_1[dpcr_idx].field_name
      SET dac_col_list->col[dpcr_cnt].col_type = substring(1,1,dpcr_data_type)
     ENDIF
   ENDFOR
   IF (size(dac_col_list->col,5)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No rows identified according to dictionary for ",dac_col_list->tbl)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dac_col_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_chk_batchover(dcb_batchcnt)
   DECLARE dcb_batch_qual = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_ALOAD"
     AND d.info_name="BATCH_SIZE"
    DETAIL
     dcb_batch_qual = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dcb_batch_qual)
   ENDIF
   SET dcb_batchcnt = dcb_batch_qual
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_get_pkgdir(dgp_pkg,dgp_pkg_loc)
   DECLARE dgp_text = vc WITH protect, noconstant("")
   DECLARE dgp_num = i4 WITH protect, noconstant(0)
   SET dgp_text = cnvtlower(trim(logical("cer_ocd"),3))
   IF (cursys="AXP")
    SET dgp_num = findstring("]",dgp_text)
    IF (dgp_num > 0)
     SET dgp_text = substring(1,(dgp_num - 1),dgp_text)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dgp_num)
    CALL echo(dgp_text)
   ENDIF
   IF (cursys="AIX")
    SET dgp_pkg_loc = concat(dgp_text,"/",trim(format(dgp_pkg,"######;P0"),3),"/")
   ELSEIF (cursys="WIN")
    SET dgp_pkg_loc = concat(dgp_text,"\",trim(format(dgp_pkg,"######;P0"),3),"\")
   ELSE
    SET dgp_pkg_loc = concat(dgp_text,trim(format(dgp_pkg,"######;P0"),3),"]")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_prelim(dp_pkg,dp_loc_ret,dp_batch_ret)
   DECLARE dp_loc_hold = vc WITH protect, noconstant("")
   DECLARE dp_batch_hold = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get pkg directory."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dac_get_pkgdir(dp_pkg,dp_loc_hold)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if batch cnt should be overwritten"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dac_chk_batchover(dp_batch_hold)=0)
    RETURN(0)
   ENDIF
   SET dp_loc_ret = dp_loc_hold
   SET dp_batch_ret = dp_batch_hold
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_build_col_list(null)
  DECLARE dbcl_cnt = i4 WITH protect, noconstant(0)
  FOR (dbcl_cnt = 1 TO size(dac_col_list->col,5))
   CASE (dac_col_list->col[dbcl_cnt].col_type)
    OF "C":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ")"),0)
    OF "Q":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtdatetime(requestin->list_0[d.seq].",dac_col_list->col[
       dbcl_cnt].col_name,"))"),0)
    OF "I":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtint(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    OF "F":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtreal(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Column Name:",dac_col_list->col[dbcl_cnt].col_name,". Data_Type:",
      dac_col_list->col[dbcl_cnt].col_type," is not recognizable by load script.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
   ENDCASE
   IF (dbcl_cnt != size(dac_col_list->col,5))
    CALL dm2_push_cmd(",",0)
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE load_package_schema_csv(lpsc_eid,lpsc_pkg_int)
   DECLARE lpsc_cnt = i4 WITH protect, noconstant(0)
   DECLARE lpsc_script_call = vc WITH protect, noconstant("")
   DECLARE lpsc_script_log_op = vc WITH protect, noconstant("")
   SET dip_ccl_load_ind = 1
   SET ocd_op->cur_op = olo_load_ccl_file
   SET ocd_op->pre_op = olo_none
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Entering LOAD_PACKAGE_SCHEMA_CSV."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   CALL start_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,lpsc_eid,lpsc_pkg_int)=0)
    RETURN(0)
   ENDIF
   FOR (lpsc_cnt = 1 TO size(csvcontent->qual,5))
     IF (((cnvtupper(csvcontent->qual[lpsc_cnt].owner)=currdbuser) OR (cnvtupper(csvcontent->qual[
      lpsc_cnt].owner)="ALL")) )
      SET lpsc_script_log_op = concat("Load Script:",csvcontent->qual[lpsc_cnt].loadscript," OCD:",
       trim(cnvtstring(lpsc_pkg_int)))
      IF (findfile(concat(dac_aload_csv_file_loc,csvcontent->qual[lpsc_cnt].filename))=0)
       DELETE  FROM dm_ocd_log d
        WHERE d.environment_id=lpsc_eid
         AND d.project_type="INSTALL LOG"
         AND d.ocd=lpsc_pkg_int
        WITH nocounter
       ;end delete
       COMMIT
       SET dm_err->eproc = concat("Installation Failed. Package schema CSV file ",
        dac_aload_csv_file_loc,csvcontent->qual[lpsc_cnt].filename," not found in CER_OCD.")
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
      IF (checkprg(csvcontent->qual[lpsc_cnt].loadscript)=0)
       DELETE  FROM dm_ocd_log d
        WHERE d.environment_id=lpsc_eid
         AND d.project_type="INSTALL LOG"
         AND d.ocd=lpsc_pkg_int
        WITH nocounter
       ;end delete
       COMMIT
       SET dm_err->eproc = concat("Installation Failed. Executable script ",csvcontent->qual[lpsc_cnt
        ].loadscript," not found in dictionary.")
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
      IF ((csvcontent->qual[lpsc_cnt].loadscript IN ("DM2_ALOAD_DM_FLAGS",
      "DM2_ALOAD_OCD_README_COMP")))
       SET lpsc_script_call = concat(" execute ",csvcontent->qual[lpsc_cnt].loadscript," ",build(
         lpsc_pkg_int),',"',
        csvcontent->qual[lpsc_cnt].filename,'",',csvcontent->qual[lpsc_cnt].passive_ind,",",
        csvcontent->qual[lpsc_cnt].row_count,
        " go")
      ELSE
       SET lpsc_script_call = concat(" execute ",csvcontent->qual[lpsc_cnt].loadscript," ",build(
         lpsc_pkg_int),',"',
        csvcontent->qual[lpsc_cnt].filename,'",',csvcontent->qual[lpsc_cnt].row_count," go")
      ENDIF
      SET dm_err->eproc = concat("EXECUTING LOAD SCRIPT:",lpsc_script_call)
      CALL log_package_op(lpsc_script_log_op,ols_start,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
      CALL dm2_push_cmd(lpsc_script_call,1)
      IF ((dm_err->err_ind=1))
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL log_package_op(lpsc_script_log_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       RETURN(0)
      ENDIF
      CALL log_package_op(lpsc_script_log_op,ols_complete,lpsc_script_call,lpsc_eid,lpsc_pkg_int)
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Operation Successful. CSV Load Scripts included successfully."
   IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,lpsc_eid,lpsc_pkg_int)=0)
    RETURN(0)
   ENDIF
   CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Leaving LOAD_PACKAGE_SCHEMA_CSV."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE determine_admin_load_method(dalm_pkg_in,dalm_meth_out)
   IF (dac_aload_method_override_val="NOT SET")
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_INSTALL_PKG"
      AND d.info_name="ADMIN_LOAD_METHOD"
     DETAIL
      dac_aload_method_override_val = d.info_char
     WITH nocounter
    ;end select
    IF (check_error("Determining admin load method.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (dac_aload_method_override_val="0"
     AND currdbuser != "V500")
     SET dm_err->eproc = concat("Evaluating admin load method override for current database user ",
      currdbuser)
     SET dm_err->emsg = concat("Cannot force use of .ccl file for current database user.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dac_aload_method_override_val="0")
    SET dalm_meth_out = 0
    RETURN(1)
   ENDIF
   IF (dac_parse_load_data_csv(dalm_pkg_in,1)=0)
    RETURN(0)
   ENDIF
   IF ((csvcontent->csv_txt_version >= 1))
    SET dalm_meth_out = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_parse_load_data_csv(pldc_pkg_in,pldc_load_all_ind)
   DECLARE pldc_txt_file = vc WITH protect, noconstant("")
   DECLARE pldc_txt = vc WITH protect, noconstant("")
   DECLARE pldc_num1 = i4 WITH protect, noconstant(0)
   DECLARE pldc_num2 = i4 WITH protect, noconstant(0)
   DECLARE pldc_cnt = i4 WITH protect, noconstant(0)
   DECLARE pldc_abs_end = i4 WITH protect, noconstant(0)
   DECLARE pldc_rep_cnt = i4 WITH protect, noconstant(0)
   DECLARE pldc_line = vc WITH protect, noconstant("")
   DECLARE pldc_str = vc WITH protect, noconstant("")
   SET pldc_txt = cnvtlower(trim(logical("cer_ocd"),3))
   SET pldc_num1 = findstring("]",pldc_txt)
   IF (pldc_num1 > 0)
    SET pldc_txt = substring(1,(pldc_num1 - 1),pldc_txt)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET pldc_txt_file = concat(pldc_txt,trim(format(pldc_pkg_in,"######;P0"),3),"]")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET pldc_txt_file = concat(pldc_txt,"\",trim(format(pldc_pkg_in,"######;P0"),3),"\")
   ELSE
    SET pldc_txt_file = concat(pldc_txt,"/",trim(format(pldc_pkg_in,"######;P0"),3),"/")
   ENDIF
   SET dac_aload_csv_file_loc = pldc_txt_file
   SET pldc_txt_file = concat(pldc_txt_file,"ocd_schema_",trim(cnvtstring(pldc_pkg_in),3),".txt")
   SET dm_err->eproc = concat("Check for existence of ",pldc_txt_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ( NOT (findfile(pldc_txt_file)))
    SET dm_err->emsg = concat(pldc_txt_file," not found. Unable to open.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET stat = alterlist(csvcontent->qual,0)
   SET csvcontent->csv_txt_version = 0
   SET csvcontent->csv_packaging_field_cnt = 0
   SET csvcontent->csv_installation_field_cnt = 7
   FREE DEFINE rtl2
   SET logical pldc_file value(pldc_txt_file)
   DEFINE rtl2 "pldc_file"
   SET dm_err->eproc = "Read the .TXT file for CsvContent."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     pldc_num2 = 0, pldc_num1 = 0, pldc_line = trim(check(r.line," "))
     IF (findstring("$ALOAD$DM2ALOADVERSION,",pldc_line) > 0)
      pldc_num1 = (findstring(",",pldc_line)+ 1), csvcontent->csv_txt_version = cnvtint(substring(
        pldc_num1,(textlen(pldc_line) - (pldc_num1 - 1)),pldc_line))
     ELSEIF (findstring("$ALOAD$DM2ALOADFIELDCNT,",pldc_line) > 0)
      pldc_num1 = (findstring(",",pldc_line)+ 1), csvcontent->csv_packaging_field_cnt = cnvtint(
       substring(pldc_num1,(textlen(pldc_line) - (pldc_num1 - 1)),pldc_line))
     ELSEIF (((((findstring("$ALOAD$",pldc_line) > 0) OR (((findstring("$ALOAD2$",pldc_line) > 0) OR
     (((findstring("$ALOAD3$",pldc_line) > 0) OR (findstring("$ALOAD4$",pldc_line) > 0)) )) ))
      AND pldc_load_all_ind=1) OR (((findstring("$CLOAD$",pldc_line) > 0) OR (findstring(
      "$ALOAD$DM_TABLE_RELATIONSHIPS",pldc_line) > 0)) )) )
      CALL init_csvcontentrow("DM2PNOTSET"), pldc_cnt = size(csvcontent->qual,5), pldc_rep_cnt = 0,
      pldc_num1 = 0, pldc_abs_end = least(csvcontent->csv_installation_field_cnt,csvcontent->
       csv_packaging_field_cnt)
      IF (findstring("$ALOAD$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD$",pldc_line)+ 6)
      ELSEIF (findstring("$ALOAD2$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD2$",pldc_line)+ 7)
      ELSEIF (findstring("$ALOAD3$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD3$",pldc_line)+ 7)
      ELSEIF (findstring("$CLOAD$",pldc_line) > 0)
       pldc_num2 = (findstring("$CLOAD$",pldc_line)+ 6)
      ELSEIF (findstring("$ALOAD4$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD4$",pldc_line)+ 7)
      ENDIF
      WHILE (pldc_rep_cnt < pldc_abs_end)
        pldc_rep_cnt = (pldc_rep_cnt+ 1), pldc_num1 = pldc_num2, pldc_num2 = findstring(",",pldc_line,
         (pldc_num1+ 1),0)
        IF (pldc_num2=0)
         pldc_str = substring((pldc_num1+ 1),(textlen(pldc_line) - pldc_num1),pldc_line)
        ELSE
         pldc_str = substring((pldc_num1+ 1),((pldc_num2 - pldc_num1) - 1),pldc_line)
        ENDIF
        IF ((dm_err->debug_flag > 0))
         CALL echo("*****"),
         CALL echo(pldc_line),
         CALL echo(pldc_str),
         CALL echo(pldc_num1),
         CALL echo(pldc_num2),
         CALL echo(pldc_abs_end)
        ENDIF
        CASE (pldc_rep_cnt)
         OF 1:
          csvcontent->qual[pldc_cnt].table_name = pldc_str
         OF 2:
          csvcontent->qual[pldc_cnt].filename = pldc_str
         OF 3:
          csvcontent->qual[pldc_cnt].fileversion = pldc_str
         OF 4:
          csvcontent->qual[pldc_cnt].loadscript = pldc_str
         OF 5:
          csvcontent->qual[pldc_cnt].row_count = pldc_str
         OF 6:
          csvcontent->qual[pldc_cnt].passive_ind = pldc_str
         OF 7:
          csvcontent->qual[pldc_cnt].owner = cnvtupper(pldc_str)
        ENDCASE
      ENDWHILE
      IF ((csvcontent->qual[pldc_cnt].owner="DM2PNOTSET"))
       csvcontent->qual[pldc_cnt].owner = "V500"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Parsing .txt file for CSVCONTENT.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(csvcontent)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_load_cload(lc_pkg_in)
   IF (dac_parse_load_data_csv(lc_pkg_in,0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE log_package_op(sbr_lpo_operation=vc,sbr_lpo_status=vc,sbr_lpo_message=vc,sbr_lpo_eid=f8,
  sbr_lpo_pkg_int=i4) = i2
 DECLARE check_package_op(sbr_cpo_operation=vc,sbr_cpo_package_int=i4,sbr_cpo_eid=f8) = i2
 DECLARE bad_package_op(sbr_bpo_bad_op=vc,sbr_bpo_pre_op=vc,sbr_bpo_eid=f8,sbr_bpo_pkg_int=i4) = null
 DECLARE del_all_package_op(sbr_dapo_eid=f8,sbr_dapo_pkg_int=i4) = i2
 DECLARE check_for_compl_row(i_cfcr_operation=vc,i_cfcr_pkg=i4,i_cfcr_eid=f8,o_updt_dt_tm=f8(ref)) =
 i2
 DECLARE write_dol_row(wdr_environtment_id=f8,wdr_project_type=vc,wdr_project_name=vc,
  wdr_project_instance=i4,wdr_ocd=i4,
  wdr_batch_dt_tm=f8,wdr_status=vc,wdr_start_dt_tm=f8,wdr_end_dt_tm=f8,wdr_driver_count=i4,
  wdr_elapsed_time=f8,wdr_message=vc,wdr_active_ind=i2) = i2
 DECLARE check_dol_row(cdr_environment_id=f8,cdr_project_type=vc,cdr_project_name=vc,
  cdr_project_instance=i4,cdr_ocd=i4,
  cdr_status=vc,cdr_curqual=i4(ref)) = i2
 DECLARE maintain_archive_dt_op(mado_environment_id=f8,mado_pkg_int=i4) = i2
 DECLARE start_status(sbr_ss_install_status=vc,sbr_ss_eid=f8,sbr_ss_package_int=i4) = null
 DECLARE end_status(sbr_es_install_status=vc,sbr_es_eid=f8,sbr_es_package_int=i4) = null
 DECLARE log_package_op_event(null) = i2
 IF ((validate(lpoe->environment_id,- (1))=- (1))
  AND validate(lpoe->environment_id,1)=1)
  FREE RECORD lpoe
  RECORD lpoe(
    1 environment_id = f8
    1 project_type = vc
    1 project_name = vc
    1 project_instance = i4
    1 ocd = i4
    1 batch_dt_tm = dq8
    1 status = vc
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 message = vc
  )
 ENDIF
 IF (validate(olo_none,"X")="X")
  FREE DEFINE ocd_op
  RECORD ocd_op(
    1 cur_op = vc
    1 pre_op = vc
    1 next_op = vc
    1 bad_op = vc
    1 status = vc
    1 msg = vc
  )
  DECLARE olo_none = vc WITH public, constant("None")
  DECLARE olo_load_ccl_file = vc WITH public, constant("Load CCL File")
  DECLARE olo_batchload_ccl_files = vc WITH public, constant("Load CCL Files for Batch Install")
  DECLARE olo_schema_report = vc WITH public, constant("Display Schema Report")
  DECLARE olo_readme_report = vc WITH public, constant("Display Readme Report")
  DECLARE olo_code_sets = vc WITH public, constant("Code Sets")
  DECLARE olo_pre_uts = vc WITH public, constant("Pre-UTS Readmes")
  DECLARE olo_uptime_schema = vc WITH public, constant("Uptime Schema")
  DECLARE olo_post_uts = vc WITH public, constant("Post-UTS Readmes")
  DECLARE olo_pre_cycle = vc WITH public, constant("Pre-CYCLE Readmes")
  DECLARE olo_pre_dts = vc WITH public, constant("Pre-DTS Readmes")
  DECLARE olo_downtime_schema = vc WITH public, constant("Downtime Schema")
  DECLARE olo_post_dts = vc WITH public, constant("Post-DTS Readmes")
  DECLARE olo_atrs = vc WITH public, constant("ATRs")
  DECLARE olo_post_inst = vc WITH public, constant("Post-INST Readmes")
  DECLARE olo_preview_complete = vc WITH public, constant("Preview Mode Completed")
  DECLARE olo_adm_archive_dt = vc WITH public, constant("Admin Archive Date")
  DECLARE olo_readme_spchk = vc WITH public, constant("PREVIEW OF README SPACE CHECKS")
  DECLARE olo_load_dma_data = vc WITH public, constant("Load DMA_SQL_OBJ_INST Data")
  DECLARE ols_start = vc WITH public, constant("START")
  DECLARE ols_begin = vc WITH public, constant("START")
  DECLARE ols_running = vc WITH public, constant("RUNNING")
  DECLARE ols_error = vc WITH public, constant("ERROR")
  DECLARE ols_failed = vc WITH public, constant("ERROR")
  DECLARE ols_complete = vc WITH public, constant("COMPLETE")
  DECLARE ols_end = vc WITH public, constant("COMPLETE")
  DECLARE ols_finish = vc WITH public, constant("COMPLETE")
  DECLARE olpt_install_info = vc WITH public, constant("INSTALL_INFO")
  DECLARE olpt_install_plan = vc WITH public, constant("INSTALL_PLAN")
  DECLARE olpt_install_log = vc WITH public, constant("INSTALL LOG")
 ENDIF
 SUBROUTINE log_package_op(sbr_lpo_operation,sbr_lpo_status,sbr_lpo_message,sbr_lpo_eid,
  sbr_lpo_pkg_int)
   DECLARE sbr_lpo_prev_err_ind = i2 WITH noconstant(0)
   IF ((dm_err->err_ind=1))
    SET sbr_lpo_prev_err_ind = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("previous error indicator:",sbr_lpo_prev_err_ind))
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   UPDATE  FROM dm_ocd_log d
    SET d.status = evaluate(cnvtupper(sbr_lpo_status),ols_start,ols_running,cnvtupper(sbr_lpo_status)
      ), d.message = substring(1,255,sbr_lpo_message), d.start_dt_tm = evaluate(cnvtupper(
       sbr_lpo_status),ols_start,cnvtdatetime(curdate,curtime3),d.start_dt_tm),
     d.end_dt_tm = evaluate(cnvtupper(sbr_lpo_status),ols_complete,cnvtdatetime(curdate,curtime3),
      ols_error,cnvtdatetime(curdate,curtime3),
      null), d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE d.environment_id=sbr_lpo_eid
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(sbr_lpo_operation)
     AND d.project_instance=1
     AND d.ocd=sbr_lpo_pkg_int
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_ocd_log d
     SET d.environment_id = sbr_lpo_eid, d.project_type = "INSTALL LOG", d.project_name = cnvtupper(
       sbr_lpo_operation),
      d.project_instance = 1, d.ocd = sbr_lpo_pkg_int, d.batch_dt_tm = cnvtdatetime(curdate,curtime3),
      d.status = evaluate(cnvtupper(sbr_lpo_status),ols_start,ols_running,cnvtupper(sbr_lpo_status)),
      d.message = substring(1,255,sbr_lpo_message), d.start_dt_tm = cnvtdatetime(curdate,curtime3),
      d.end_dt_tm = evaluate(cnvtupper(sbr_lpo_status),ols_complete,cnvtdatetime(curdate,curtime3),
       ols_error,cnvtdatetime(curdate,curtime3),
       null), d.driver_count = null, d.estimated_time = null,
      d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Recording operation in the log table."
     SET dm_err->emsg = "Installation Failed. Unable to log status to dm_ocd_log table."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (check_error("Inserting or updating package status in log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    IF (sbr_lpo_prev_err_ind=1)
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
    RETURN(0)
   ELSE
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE check_package_op(sbr_cpo_operation,sbr_cpo_package_int,sbr_cpo_eid)
   IF (cnvtupper(sbr_cpo_operation)="NONE")
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=sbr_cpo_eid
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(sbr_cpo_operation)
     AND d.project_instance=1
     AND d.ocd=sbr_cpo_package_int
     AND d.status="COMPLETE"
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (check_error("Checking for operation in the log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE bad_package_op(sbr_bpo_bad_op,sbr_bpo_pre_op,sbr_bpo_eid,sbr_bpo_pkg_int)
   CALL end_status(build("Cannot execute '",sbr_bpo_bad_op,"' operation until '",sbr_bpo_pre_op,
     "' operation is complete. Install FAILED."),sbr_bpo_eid,sbr_bpo_pkg_int)
 END ;Subroutine
 SUBROUTINE del_all_package_op(sbr_dapo_eid,sbr_dapo_pkg_int)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DELETE  FROM dm_ocd_log d
    WHERE d.environment_id=sbr_dapo_eid
     AND d.project_type="INSTALL LOG"
     AND d.ocd=sbr_dapo_pkg_int
     AND d.project_name != cnvtupper(olo_load_ccl_file)
    WITH nocounter
   ;end delete
   IF (check_error("Deleting INSTALL LOG rows from the log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=sbr_dapo_eid
     AND d.project_type="INSTALL LOG"
     AND d.ocd=sbr_dapo_pkg_int
     AND d.project_name != cnvtupper(olo_load_ccl_file)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (check_error("Verifying deletion of INSTALL LOG rows from the log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_for_compl_row(i_cfcr_operation,i_cfcr_pkg,i_cfcr_eid,o_cfcr_updt_dt_tm)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Checking for complete row for operation: ",i_cfcr_operation)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=i_cfcr_eid
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(i_cfcr_operation)
     AND d.project_instance=1
     AND d.ocd=i_cfcr_pkg
     AND d.status=ols_complete
    DETAIL
     o_cfcr_updt_dt_tm = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET o_cfcr_updt_dt_tm = 0.0
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE write_dol_row(wdr_environment_id,wdr_project_type,wdr_project_name,wdr_project_instance,
  wdr_ocd,wdr_batch_dt_tm,wdr_status,wdr_start_dt_tm,wdr_end_dt_tm,wdr_driver_count,
  wdr_estimated_time,wdr_message,wdr_active_ind)
   DECLARE wdr_lpo_prev_err_ind = i2 WITH noconstant(0)
   DECLARE wdr_error_ind = i2 WITH noconstant(0)
   DECLARE wdr_prev_emsg = vc WITH noconstant(" ")
   SET wdr_lpo_prev_err_ind = dm_err->err_ind
   SET wdr_prev_emsg = dm_err->emsg
   IF (wdr_lpo_prev_err_ind=1)
    SET dm_err->err_ind = 0
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("wdr: previous error indicator:",wdr_lpo_prev_err_ind))
    CALL echo(build("wdr: previous error message:",wdr_prev_emsg))
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   UPDATE  FROM dm_ocd_log d
    SET d.batch_dt_tm = cnvtdatetime(wdr_batch_dt_tm), d.status = wdr_status, d.start_dt_tm =
     cnvtdatetime(wdr_start_dt_tm),
     d.end_dt_tm = cnvtdatetime(wdr_end_dt_tm), d.driver_count = wdr_driver_count, d.estimated_time
      = wdr_estimated_time,
     d.message = substring(1,255,wdr_message), d.active_ind = wdr_active_ind, d.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE d.environment_id=wdr_environment_id
     AND d.project_type=cnvtupper(wdr_project_type)
     AND d.project_name=cnvtupper(wdr_project_name)
     AND d.project_instance=wdr_project_instance
     AND d.ocd=wdr_ocd
    WITH nocounter
   ;end update
   IF (check_error("Updating dm_ocd_log table from write_dol_row.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET wdr_error_ind = 1
   ENDIF
   IF (wdr_error_ind=0
    AND curqual=0)
    INSERT  FROM dm_ocd_log d
     SET d.batch_dt_tm = cnvtdatetime(wdr_batch_dt_tm), d.status = wdr_status, d.start_dt_tm =
      cnvtdatetime(wdr_start_dt_tm),
      d.end_dt_tm = cnvtdatetime(wdr_end_dt_tm), d.driver_count = wdr_driver_count, d.estimated_time
       = wdr_estimated_time,
      d.message = substring(1,255,wdr_message), d.active_ind = wdr_active_ind, d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.environment_id = wdr_environment_id, d.project_type = cnvtupper(wdr_project_type), d
      .project_name = cnvtupper(wdr_project_name),
      d.project_instance = wdr_project_instance, d.ocd = wdr_ocd
     WITH nocounter
    ;end insert
    IF (check_error("Updating dm_ocd_log table from write_dol_row.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     SET wdr_error_ind = 1
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (wdr_lpo_prev_err_ind=1)
    SET dm_err->err_ind = wdr_lpo_prev_err_ind
    SET dm_err->err_msg = wdr_prev_emsg
   ENDIF
   IF (wdr_error_ind=1)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE check_dol_row(cdr_environment_id,cdr_project_type,cdr_project_name,cdr_project_instance,
  cdr_ocd,cdr_status,cdr_curqual)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=cdr_environment_id
     AND d.project_type=cnvtupper(cdr_project_type)
     AND d.project_name=cnvtupper(cdr_project_name)
     AND d.project_instance=cdr_project_instance
     AND d.ocd=cdr_ocd
     AND d.status=cdr_status
    WITH nocounter
   ;end select
   IF (check_error("Verifying dm_ocd_log row existance in check_dol_row.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET cdr_curqual = 0
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ELSE
    SET cdr_curqual = curqual
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE maintain_archive_dt_op(mado_environment_id,mado_pkg_int)
   DECLARE mado_archive_dt_tm = dq8 WITH protect, noconstant(0.00)
   DECLARE mado_output_str = vc WITH protect, noconstant(build("package <",mado_pkg_int,">"))
   DECLARE mado_updt_ind = i2 WITH protect, noconstant(1)
   SET dm_err->eproc = concat("Getting archive date and time for ",mado_output_str,".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    a.archive_dt_tm
    FROM dm_alpha_features a
    WHERE a.alpha_feature_nbr=mado_pkg_int
     AND a.owner=currdbuser
    DETAIL
     mado_archive_dt_tm = a.archive_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_ALPHA_FEATURES row found for ",mado_output_str,".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Updating Admin Archive Date row for ",mado_output_str,".")
   CALL disp_msg("",dm_err->logfile,0)
   UPDATE  FROM dm_ocd_log d
    SET d.batch_dt_tm = cnvtdatetime(mado_archive_dt_tm), d.updt_dt_tm = evaluate(datetimediff(
       cnvtdatetime(mado_archive_dt_tm),d.batch_dt_tm),0.0,d.updt_dt_tm,cnvtdatetime(curdate,curtime3
       ))
    WHERE d.environment_id=mado_environment_id
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(olo_adm_archive_dt)
     AND d.project_instance=1
     AND d.ocd=mado_pkg_int
     AND d.status="COMPLETE"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Existing row not found. Inserting Admin Archive Date row for ",
     mado_output_str,".")
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_ocd_log d
     SET d.environment_id = mado_environment_id, d.project_type = "INSTALL LOG", d.project_name =
      cnvtupper(olo_adm_archive_dt),
      d.project_instance = 1, d.ocd = mado_pkg_int, d.batch_dt_tm = cnvtdatetime(mado_archive_dt_tm),
      d.status = cnvtupper(ols_complete), d.message = " ", d.start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.end_dt_tm = cnvtdatetime(curdate,curtime3), d.driver_count = null, d.estimated_time = null,
      d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   SET dm_err->eproc = concat("Finished maintaining Admin Archive Date row for ",mado_output_str,".")
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE start_status(sbr_ss_install_status,sbr_ss_eid,sbr_ss_package_int)
   IF (dm2_set_autocommit(1)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Recording process status in DM_ALPHA_FEATURES_ENV."
   UPDATE  FROM dm_alpha_features_env defa
    SET defa.status = substring(1,100,sbr_ss_install_status), defa.start_dt_tm = cnvtdatetime(curdate,
      curtime3), defa.end_dt_tm = null
    WHERE defa.environment_id=sbr_ss_eid
     AND defa.alpha_feature_nbr=sbr_ss_package_int
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF ( NOT (curqual))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Installation Failed.  No row found for this installation."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   IF ((validate(dir_ui_misc->dm_process_event_id,- (1)) != - (1))
    AND (validate(dir_ui_misc->dm_process_event_id,- (2)) != - (2)))
    IF ((dir_ui_misc->dm_process_event_id > 0))
     CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,sbr_ss_install_status,0.0,
      cnvtdatetime(curdate,curtime3))
    ENDIF
   ENDIF
   SET dm_err->eproc = sbr_ss_install_status
   CALL disp_msg(" ",dm_err->logfile,0)
 END ;Subroutine
 SUBROUTINE end_status(sbr_es_install_status,sbr_es_eid,sbr_es_package_int)
   DECLARE sbr_es_prev_err_ind = i2 WITH public, constant(dm_err->err_ind)
   IF (dm2_set_autocommit(1)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   SET dm_err->eproc = sbr_es_install_status
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   UPDATE  FROM dm_alpha_features_env defa
    SET defa.status = substring(1,100,sbr_es_install_status), defa.end_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WHERE defa.environment_id=sbr_es_eid
     AND defa.alpha_feature_nbr=sbr_es_package_int
    WITH nocounter
   ;end update
   IF (check_error("END_STATUS subroutine: Updating row in DM_ALPHA_FEATURES_ENV.")=1)
    IF (sbr_es_prev_err_ind=0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
    ELSE
     COMMIT
    ENDIF
    RETURN(null)
   ENDIF
   IF ( NOT (curqual))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Installation Failed.  No row found for this installation."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE log_package_op_event(null)
   DECLARE sbr_lpoe_prev_err_ind = i2 WITH noconstant(0)
   IF ((dm_err->err_ind=1))
    SET sbr_lpoe_prev_err_ind = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("previous error indicator:",sbr_lpoe_prev_err_ind))
   ENDIF
   IF ((lpoe->environment_id=0))
    SET dm_err->eproc = "Inserting or updating package op event in log table."
    CALL disp_msg("log_package_op_event bypassed due to lpoe->environment_id = 0",dm_err->logfile,1)
    RETURN(1)
   ENDIF
   UPDATE  FROM dm_ocd_log d
    SET d.status = lpoe->status, d.message = substring(1,255,lpoe->message), d.start_dt_tm = evaluate
     (cnvtupper(lpoe->status),ols_start,cnvtdatetime(curdate,curtime3),d.start_dt_tm),
     d.end_dt_tm = evaluate(cnvtupper(lpoe->status),ols_complete,cnvtdatetime(curdate,curtime3),
      ols_error,cnvtdatetime(curdate,curtime3),
      null), d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (d.environment_id=lpoe->environment_id)
     AND (d.project_type=lpoe->project_type)
     AND d.project_name=cnvtupper(lpoe->project_name)
     AND d.project_instance=1
     AND (d.ocd=lpoe->ocd)
     AND d.batch_dt_tm=cnvtdatetime(lpoe->batch_dt_tm)
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_ocd_log d
     SET d.environment_id = lpoe->environment_id, d.project_type = lpoe->project_type, d.project_name
       = cnvtupper(lpoe->project_name),
      d.project_instance = 1, d.ocd = lpoe->ocd, d.batch_dt_tm = cnvtdatetime(lpoe->batch_dt_tm),
      d.status = lpoe->status, d.message = substring(1,255,lpoe->message), d.start_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.end_dt_tm = evaluate(cnvtupper(lpoe->status),ols_complete,cnvtdatetime(curdate,curtime3),
       ols_error,cnvtdatetime(curdate,curtime3),
       null), d.driver_count = null, d.estimated_time = null,
      d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error("Inserting or updating package status in log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    IF (sbr_lpoe_prev_err_ind=1)
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
    RETURN(0)
   ELSE
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE check_ccldir_logicals(null) = i2
 DECLARE check_ccl_version(null) = i2
 DECLARE check_for_readmes(cfr_eid=f8,cfr_ocd=i4) = i2
 DECLARE check_eucswapccl(null) = i2
 DECLARE load_readme_csv_data(lrcd_package_int=i4,lrcd_eid=f8) = i2
 DECLARE downtime_readme_check(drc_plan_id=f8,drc_eid=f8) = i2
 DECLARE update_dol_status_row(udsr_eid=f8,udsr_project_type=vc,udsr_project_name=vc,udsr_ocd=i4,
  udsr_status=vc) = i2
 DECLARE add_checklist_dtentry(acd_cl_num=i4,acd_dt_num=i4) = i2
 DECLARE ddc_getlog(ddcgl_lookup_val=vc,ddcgl_retval=vc(ref),ddcgl_retval_full=vc(ref)) = i2
 DECLARE ddc_logfile_prefix = vc WITH protect, noconstant("dm2_dtchk")
 DECLARE ddc_status = vc WITH protect, noconstant("")
 DECLARE ddc_ocd = i4 WITH protect, noconstant(0)
 DECLARE ddc_eid = f8 WITH protect, noconstant(0.0)
 DECLARE ddc_nlsnumchar = vc WITH protect, noconstant("")
 DECLARE ddc_session_override = vc WITH protect, noconstant("")
 DECLARE ddc_tmp_cnt = i4 WITH protect, noconstant(0)
 RECORD reply(
   1 downtime_required_ind = i2
   1 check_list_cnt = i4
   1 check_list[*]
     2 check_name = vc
     2 check_passed_ind = i2
     2 downtime_reasons_cnt = i4
     2 downtime_reasons[*]
       3 txt = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ddc_plan_packages(
   1 readmes_found_ind = i2
   1 package_cnt = i4
   1 list[*]
     2 package = i4
     2 archive_dt_tm = dq8
     2 admin_archive_dt_tm = dq8
     2 csv_content = c1
     2 readme_cnt = i4
 )
 IF (check_logfile(ddc_logfile_prefix,".log","Starting DM2_DOWNTIME_CHECKER")=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "script initialization"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Validating check_option from request."
 IF ( NOT ((request->check_option IN ("ALL", "DOMAIN", "SET_MANAGEDDT", "SET_NODT"))))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Invalid check_option."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request->check_option"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Script execution error in dm2_downtime_checker: ",dm_err->emsg)
  GO TO exit_program
 ENDIF
 SET ddc_ocd = (request->plan_id * - (1))
 IF (dm2_get_env_data(0,ddc_eid)=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request->plan_id"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
  GO TO exit_program
 ENDIF
 IF ((request->check_option IN ("SET_MANAGEDDT", "SET_NODT")))
  CASE (request->check_option)
   OF "SET_MANAGEDDT":
    SET ddc_status = "MANAGED-DT"
   OF "SET_NODT":
    SET ddc_status = "NO-DT"
  ENDCASE
  IF (update_dol_status_row(ddc_eid,"INSTALL PLAN","TYPE",ddc_ocd,ddc_status)=0)
   GO TO exit_program
  ENDIF
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Checking for NLS_NUMERIC_CHARACTERS value."
 SELECT INTO "nl:"
  v.value
  FROM nls_session_parameters v
  WHERE v.parameter="NLS_NUMERIC_CHARACTERS"
  DETAIL
   ddc_nlsnumchar = v.value
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag > 0))
  SET dm_err->eproc = concat("NLS_NUMERIC_CHARACTERS was set to <",ddc_nlsnumchar,">.")
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 IF (ddc_nlsnumchar=".,")
  SET dm_err->eproc = "NLS_NUMERIC_CHARACTERS already set to '.,' - skipping session override."
 ELSE
  SET dm_err->eproc = "Getting NLS_NUMERIC_CHARACTERS session override."
  SELECT INTO "nl:"
   d.info_char
   FROM dm_info d
   WHERE d.info_domain="DM2_TOOLS_ALTER_SESSION"
    AND d.info_name="NLS_NUMERIC_CHARACTERS"
   DETAIL
    ddc_session_override = d.info_char
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
  IF (ddc_session_override > "")
   IF (dm2_push_cmd(concat("rdb ",ddc_session_override," go"),1)=0)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF ((request->check_option="ALL"))
  SET dm_err->eproc = build("Validating plan_id <",trim(format(request->plan_id,";;i"),3),
   "> from request and loading package list.")
  CALL disp_msg("",dm_err->logfile,0)
  SELECT INTO "nl:"
   dip.package_number
   FROM dm_install_plan dip
   WHERE (dip.install_plan_id=request->plan_id)
   ORDER BY dip.package_number
   DETAIL
    ddc_plan_packages->package_cnt = (ddc_plan_packages->package_cnt+ 1)
    IF (mod(ddc_plan_packages->package_cnt,20)=1)
     stat = alterlist(ddc_plan_packages->list,(ddc_plan_packages->package_cnt+ 19))
    ENDIF
    ddc_plan_packages->list[ddc_plan_packages->package_cnt].package = dip.package_number,
    ddc_plan_packages->list[ddc_plan_packages->package_cnt].csv_content = "N", ddc_plan_packages->
    list[ddc_plan_packages->package_cnt].readme_cnt = 0
   FOOT REPORT
    stat = alterlist(ddc_plan_packages->list,ddc_plan_packages->package_cnt)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "request->plan_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
   GO TO exit_program
  ELSEIF (curqual=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Plan ID not found."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "request->plan_id"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(ddc_plan_packages)
 ENDIF
 IF ((dm2_sys_misc->cur_os != "WIN"))
  IF (check_ccldir_logicals(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (check_ccl_version(null)=0)
  GO TO exit_program
 ENDIF
 IF ((dm2_sys_misc->cur_os != "WIN"))
  IF (check_eucswapccl(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((request->check_option="ALL"))
  IF ((dm2_sys_misc->cur_os="WIN"))
   SET dm_err->eproc = "Check if DM_OCD_SETUP_ADMIN has ran in environment"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name="SCHEMA_DATE"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "request->plan_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET reply->check_list_cnt = (reply->check_list_cnt+ 1)
    SET stat = alterlist(reply->check_list,reply->check_list_cnt)
    SET reply->check_list[reply->check_list_cnt].check_name = "ADMIN_SETUP_COMPLETE"
    SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
    SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = 1
    SET ddc_tmp_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
    SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,ddc_tmp_cnt)
    SET reply->check_list[reply->check_list_cnt].downtime_reasons[ddc_tmp_cnt].txt = concat(
     "Admin setup has not been completed on environment.")
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF ((request->check_option="ALL"))
  IF (check_for_readmes(ddc_eid,ddc_ocd)=0)
   GO TO exit_program
  ENDIF
  IF ((reply->downtime_required_ind=0))
   SET ddc_status = "NO-DT"
  ELSE
   SET ddc_status = "MANAGED-DT"
  ENDIF
  IF (update_dol_status_row(ddc_eid,"INSTALL PLAN","TYPE",ddc_ocd,ddc_status)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 GO TO exit_program
 SUBROUTINE check_ccldir_logicals(null)
   DECLARE ccdl_ccldir = vc WITH protect, noconstant("NOT_SET")
   DECLARE ccdl_ccldir1 = vc WITH protect, noconstant("NOT_SET")
   DECLARE ccdl_ccldir2 = vc WITH protect, noconstant("NOT_SET")
   DECLARE ccdl_ccldiraccess = vc WITH protect, noconstant("NOT_SET")
   DECLARE ccdl_dtcnt = i4 WITH protect, noconstant(0)
   DECLARE ccdl_curr_ccldir = vc WITH protect, noconstant("NOT_SET")
   DECLARE ccdl_environment = vc WITH protect, constant(logical("environment"))
   DECLARE ccdl_getdef_cmd = vc WITH protect, noconstant(" ")
   DECLARE ccdl_clcnt = i4 WITH protect, noconstant(0)
   DECLARE ccdl_getlog_fulltext = vc WITH protect, noconstant(" ")
   DECLARE ccdl_dummy_text = vc WITH protect, noconstant(" ")
   SET reply->check_list_cnt = (reply->check_list_cnt+ 1)
   SET ccdl_clcnt = reply->check_list_cnt
   SET stat = alterlist(reply->check_list,ccdl_clcnt)
   SET reply->check_list[ccdl_clcnt].check_name = "CCLDIR_LOGICALS"
   SET reply->check_list[ccdl_clcnt].downtime_reasons_cnt = 0
   SET dm_err->eproc = "Evaluating CCLDIR logicals."
   CALL disp_msg("",dm_err->logfile,0)
   SET ccdl_ccldiraccess = cnvtupper(trim(logical("CCLDIRACCESS")))
   IF (ddc_getlog("CCLDIR",ccdl_ccldir,ccdl_getlog_fulltext)=0)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
     "Error returned calling ddc_getlog, error message: [",dm_err->emsg,"]")
    RETURN(0)
   ENDIF
   IF (ddc_getlog("CCLDIR1",ccdl_ccldir1,ccdl_getlog_fulltext)=0)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
     "Error returned calling ddc_getlog, error message: [",dm_err->emsg,"]")
    RETURN(0)
   ENDIF
   IF (ddc_getlog("CCLDIR2",ccdl_ccldir2,ccdl_getlog_fulltext)=0)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
     "Error returned calling ddc_getlog, error message: [",dm_err->emsg,"]")
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("ccdl_ccldir:[",ccdl_ccldir,"]"))
    CALL echo(concat("ccdl_ccldir1:[",ccdl_ccldir1,"]"))
    CALL echo(concat("ccdl_ccldir2:[",ccdl_ccldir2,"]"))
    CALL echo(concat("ccdl_ccldiraccess:[",ccdl_ccldiraccess,"]"))
    CALL echo(concat("ccdl_curr_ccldir:[",ccdl_curr_ccldir,"]"))
    CALL echo(concat("ccdl_environment:[",ccdl_environment,"]"))
   ENDIF
   IF ( NOT (ccdl_ccldiraccess IN ("1READ*", "1WRITE*", "2READ*", "2WRITE*")))
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat("CCLDIRACCESS [",
     ccdl_ccldiraccess,"] is not a valid value")
   ELSE
    IF (ccdl_ccldiraccess="1*")
     SET ccdl_curr_ccldir = "CCLDIR1"
    ELSE
     SET ccdl_curr_ccldir = "CCLDIR2"
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("ccdl_curr_ccldir:[",ccdl_curr_ccldir,"]"))
   ENDIF
   IF (trim(ccdl_ccldir1)="")
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt =
    "CCLDIR1 logical is not defined"
   ELSEIF (dm2_find_dir(ccdl_ccldir1)=0)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt =
    "CCLDIR1 directory does not exist"
   ENDIF
   IF (trim(ccdl_ccldir2)="")
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt =
    "CCLDIR2 logical is not defined"
   ELSEIF (dm2_find_dir(ccdl_ccldir2)=0)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt =
    "CCLDIR2 directory does not exist"
   ENDIF
   IF (ccdl_ccldir2=ccdl_ccldir1)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat("CCLDIR1 logical [",
     ccdl_ccldir1,"] and CCLDIR2 logical [",ccdl_ccldir2,
     "] values are the same.  They should be different.")
   ENDIF
   IF (ccdl_curr_ccldir="CCLDIR1"
    AND ccdl_ccldir != ccdl_ccldir1)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
     "CCLDIR1 logical value [",ccdl_ccldir1,"] and CCLDIR logical value [",ccdl_ccldir,
     "] are not in sync ",
     "with CCLDIRACCESS [",ccdl_ccldiraccess,"] for environment [",ccdl_environment,"] .")
   ENDIF
   IF (ccdl_curr_ccldir="CCLDIR2"
    AND ccdl_ccldir != ccdl_ccldir2)
    SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
    CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
    SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat("CCLDIR2 value [",
     ccdl_ccldir2,"] and CCLDIR value[",ccdl_ccldir,"] are not in sync ",
     "with CCLDIRACCESS value [",ccdl_ccldiraccess,"] for environment [",ccdl_environment,"] .")
   ENDIF
   IF (cursys="AIX"
    AND ccdl_ccldir2 != "")
    SET ccdl_getdef_cmd = "$cer_exe/get_definition -env $environment -def CCLDIR2"
    IF (dm2_push_dcl(ccdl_getdef_cmd)=0)
     IF (findstring("no such definition",dm_err->emsg) > 0)
      SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
      CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
      SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
       "CCLDIRACCESS not found in Cerner registry for environment [",ccdl_environment,"].")
     ELSE
      SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
      CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
      SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
       "Error returned from get_definition. Error message:",dm_err->errtext,"]")
     ENDIF
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
      CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
      SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = build(
       "Parsing of get_definition result failed with error message:",dm_err->emsg)
     ELSE
      IF ((dm_err->errtext != ccdl_ccldir2))
       SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
       CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
       SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
        "CCLDIR2 registry value [",dm_err->errtext,"] does not match CCLDIR2 logical value [",
        ccdl_ccldir2,"] for environment [",
        ccdl_environment,"].")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (ccdl_curr_ccldir != "NOT_SET")
    IF (ddc_getlog("CCLDIRACCESS",ccdl_dummy_text,ccdl_getlog_fulltext)=0)
     SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
     CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
     SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt = concat(
      "Error returned calling ddc_getlog, error message: [",dm_err->err_msg,"]")
     RETURN(0)
    ENDIF
    IF (findstring("[local]",ccdl_getlog_fulltext) > 0)
     SET ccdl_dtcnt = (ccdl_dtcnt+ 1)
     CALL add_checklist_dtentry(ccdl_clcnt,ccdl_dtcnt)
     SET reply->check_list[ccdl_clcnt].downtime_reasons[ccdl_dtcnt].txt =
     "CCLDIRACCESS is configured incorrectly."
    ENDIF
   ENDIF
   IF ((reply->check_list[ccdl_clcnt].downtime_reasons_cnt=0))
    SET reply->check_list[ccdl_clcnt].check_passed_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddc_getlog(ddcgl_lookup_val,ddcgl_ret_log,ddcgl_ret_full)
   DECLARE dgg_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgg_begpos = i2 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET dgg_cmd = concat("mcr cer_exe:getlog ",ddcgl_lookup_val)
   ELSE
    SET dgg_cmd = concat("$cer_exe/getlog ",ddcgl_lookup_val)
   ENDIF
   IF (dm2_push_dcl(dgg_cmd)=0)
    RETURN(0)
   ELSEIF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Parsing dm_err->errtext for: ",ddcgl_lookup_val))
    ENDIF
    SET ddcgl_ret_full = dm_err->errtext
    SET ddcgl_ret_log = ""
    IF (findstring("not defined",dm_err->errtext)=0)
     SET dgg_begpos = findstring("[global]",dm_err->errtext)
     IF (dgg_begpos > 0)
      SET ddcgl_ret_log = substring((findstring("-->",dm_err->errtext,dgg_begpos,1)+ 4),((textlen(
        dm_err->errtext)+ 1) - (findstring("-->",dm_err->errtext,dgg_begpos,1)+ 4)),dm_err->errtext)
     ENDIF
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("dm_err->errtext:[",dm_err->errtext,"]"))
     CALL echo(concat("ddcgl_ret_log:[",ddcgl_ret_log,"]"))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_checklist_dtentry(acd_cl_num,acd_dt_num)
   SET reply->check_list[acd_cl_num].check_passed_ind = 0
   SET reply->downtime_required_ind = 1
   SET reply->check_list[acd_cl_num].downtime_reasons_cnt = acd_dt_num
   SET stat = alterlist(reply->check_list[acd_cl_num].downtime_reasons,acd_dt_num)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_ccl_version(null)
   DECLARE ddc_ccv_tmp_cnt = i4 WITH protect, noconstant(0)
   SET reply->check_list_cnt = (reply->check_list_cnt+ 1)
   SET stat = alterlist(reply->check_list,reply->check_list_cnt)
   SET reply->check_list[reply->check_list_cnt].check_name = "CCL_VERSION"
   SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = 0
   SET dm_err->eproc = "Evaluating CCL version."
   CALL disp_msg("",dm_err->logfile,0)
   IF (((currev=8
    AND currevminor=3
    AND currevminor2 >= 5) OR (((currev=8
    AND currevminor > 3) OR (currev > 8)) )) )
    SET reply->check_list[reply->check_list_cnt].check_passed_ind = 1
   ELSE
    SET reply->downtime_required_ind = 1
    SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
    SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = (reply->check_list[reply->
    check_list_cnt].downtime_reasons_cnt+ 1)
    SET ddc_ccv_tmp_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
    SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,ddc_ccv_tmp_cnt)
    SET reply->check_list[reply->check_list_cnt].downtime_reasons[ddc_ccv_tmp_cnt].txt = concat(
     "CCL Version <",build(currev,".",currevminor,".",currevminor2),
     "> does not support no-downtime Install Plans. CCL Version 8.3.5 or higher is required.")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_for_readmes(cfr_eid,cfr_ocd)
   DECLARE cfr_pkgcnt = i4 WITH protect, noconstant(0)
   DECLARE cfr_file_name = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE cfr_pkg_path = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE cfr_temp_str = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE cfr_tmp_cnt = i4 WITH protect, noconstant(0)
   DECLARE cfr_tmp_float = f8 WITH protect, noconstant(0.00)
   DECLARE cfr_cerocd = vc WITH protect, constant(cnvtlower(trim(logical("cer_ocd"),3)))
   DECLARE cfr_status = vc WITH protect, noconstant("DM2_NOT_SET")
   RECORD docd_reply(
     1 status = c1
     1 err_msg = vc
   )
   SET reply->check_list_cnt = (reply->check_list_cnt+ 1)
   SET stat = alterlist(reply->check_list,reply->check_list_cnt)
   SET reply->check_list[reply->check_list_cnt].check_name = "README"
   SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = 0
   SET dm_err->eproc = "Checking for packages that have been imported into Admin."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    daf.archive_dt_tm
    FROM dm_alpha_features daf,
     (dummyt d  WITH seq = ddc_plan_packages->package_cnt)
    PLAN (d)
     JOIN (daf
     WHERE (daf.alpha_feature_nbr=ddc_plan_packages->list[d.seq].package)
      AND daf.owner=currdbuser)
    DETAIL
     ddc_plan_packages->list[d.seq].admin_archive_dt_tm = daf.archive_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "request->plan_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
    RETURN(0)
   ENDIF
   FOR (cfr_pkgcnt = 1 TO ddc_plan_packages->package_cnt)
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET cfr_path_end_loc = findstring("]",cfr_cerocd)
      IF (cfr_path_end_loc > 0)
       SET cfr_pkg_path = substring(1,(cfr_path_end_loc - 1),cfr_cerocd)
      ENDIF
      SET cfr_pkg_path = concat(cfr_pkg_path,trim(format(ddc_plan_packages->list[cfr_pkgcnt].package,
         "######;P0"),3),"]")
     ELSE
      SET cfr_pkg_path = concat(cfr_cerocd,"/",trim(format(ddc_plan_packages->list[cfr_pkgcnt].
         package,"######;P0"),3),"/")
     ENDIF
     SET cfr_file_name = build(cfr_pkg_path,"ocd_schema_",ddc_plan_packages->list[cfr_pkgcnt].package,
      ".txt")
     FREE DEFINE rtl
     SET logical cfr_file value(cfr_file_name)
     DEFINE rtl "cfr_file"
     SET dm_err->eproc = build("Loading admin data for Package <",ddc_plan_packages->list[cfr_pkgcnt]
      .package,">")
     SELECT INTO "nl:"
      r.line
      FROM rtlt r
      HEAD REPORT
       rpt_sc_loc = 0, rpt_eq_loc = 0, rpt_dttm_diff = 0,
       rpt_ps_loc = 0
      DETAIL
       rpt_sc_loc = findstring(";",r.line), rpt_ps_loc = findstring("#",r.line)
       IF (rpt_sc_loc > 0)
        rpt_eq_loc = findstring("=",r.line,rpt_sc_loc)
        IF ((rpt_eq_loc > (rpt_sc_loc+ 1)))
         cfr_temp_str = cnvtupper(trim(substring((rpt_sc_loc+ 1),((rpt_eq_loc - rpt_sc_loc) - 1),r
            .line),3))
         IF (size(trim(cfr_temp_str),3))
          IF (cfr_temp_str="ARCHIVE DATE")
           ddc_plan_packages->list[cfr_pkgcnt].archive_dt_tm = cnvtdatetime(substring((rpt_eq_loc+ 1),
             23,r.line))
           IF ((dm_err->debug_flag >= 2))
            CALL echo(r.line),
            CALL echo(substring((rpt_eq_loc+ 1),23,r.line)),
            CALL echo(ddc_plan_packages->list[cfr_pkgcnt].archive_dt_tm)
           ENDIF
          ELSEIF (cfr_temp_str="DM_OCD_README"
           AND currdbuser="V500")
           ddc_plan_packages->list[cfr_pkgcnt].readme_cnt = cnvtint(cnvtalphanum(substring((
              rpt_eq_loc+ 1),8,r.line)))
           IF ((dm_err->debug_flag >= 2))
            CALL echo(r.line),
            CALL echo(substring((rpt_eq_loc+ 1),8,r.line)),
            CALL echo(ddc_plan_packages->list[cfr_pkgcnt].readme_cnt)
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ELSEIF (rpt_ps_loc > 0)
        rpt_eq_loc = findstring("=",r.line,rpt_ps_loc)
        IF ((rpt_eq_loc > (rpt_ps_loc+ 1)))
         cfr_temp_str = cnvtupper(trim(substring((rpt_ps_loc+ 1),((rpt_eq_loc - rpt_ps_loc) - 1),r
            .line),3))
         IF (size(trim(cfr_temp_str),3))
          IF (cnvtupper(cfr_temp_str)=build(currdbuser,".DM_OCD_README"))
           ddc_plan_packages->list[cfr_pkgcnt].readme_cnt = cnvtint(cnvtalphanum(substring((
              rpt_eq_loc+ 1),8,r.line)))
           IF ((dm_err->debug_flag >= 2))
            CALL echo(r.line),
            CALL echo(substring((rpt_eq_loc+ 1),8,r.line)),
            CALL echo(ddc_plan_packages->list[cfr_pkgcnt].readme_cnt)
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ELSEIF (findstring("$ALOAD$DM2ALOADVERSION",r.line,1))
        ddc_plan_packages->list[cfr_pkgcnt].csv_content = "Y"
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      SET reply->downtime_required_ind = 1
      SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
      SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = (reply->check_list[reply->
      check_list_cnt].downtime_reasons_cnt+ 1)
      SET cfr_tmp_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
      SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,cfr_tmp_cnt)
      SET reply->check_list[reply->check_list_cnt].downtime_reasons[cfr_tmp_cnt].txt = build(
       "Unable to Load Readme Data from CSV files for Package <",ddc_plan_packages->list[cfr_pkgcnt].
       package,">")
     ENDIF
     IF ((dm_err->debug_flag >= 2))
      CALL echo(build("found <",ddc_plan_packages->list[cfr_pkgcnt].readme_cnt,
        "> readmes for package <",ddc_plan_packages->list[cfr_pkgcnt].package,">"))
     ENDIF
     IF ((ddc_plan_packages->list[cfr_pkgcnt].readme_cnt > 0))
      SET ddc_plan_packages->readmes_found_ind = 1
     ENDIF
     SET cfr_tmp_float = datetimediff(ddc_plan_packages->list[cfr_pkgcnt].archive_dt_tm,
      ddc_plan_packages->list[cfr_pkgcnt].admin_archive_dt_tm)
     IF ((dm_err->debug_flag >= 2))
      CALL echo(build("archive_dt_tm=",ddc_plan_packages->list[cfr_pkgcnt].archive_dt_tm))
      CALL echo(build("admin_archive_dt_tm=",ddc_plan_packages->list[cfr_pkgcnt].admin_archive_dt_tm)
       )
      CALL echo(build("cfr_tmp_float=",cfr_tmp_float))
     ENDIF
     IF ((ddc_plan_packages->list[cfr_pkgcnt].archive_dt_tm != ddc_plan_packages->list[cfr_pkgcnt].
     admin_archive_dt_tm))
      IF ((ddc_plan_packages->list[cfr_pkgcnt].csv_content="Y"))
       IF (load_readme_csv_data(ddc_plan_packages->list[cfr_pkgcnt].package,cfr_eid)=0)
        SET reply->downtime_required_ind = 1
        SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
        SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = (reply->check_list[reply
        ->check_list_cnt].downtime_reasons_cnt+ 1)
        SET cfr_tmp_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
        SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,cfr_tmp_cnt)
        SET reply->check_list[reply->check_list_cnt].downtime_reasons[cfr_tmp_cnt].txt = build(
         "Failed to Load Readme Data from CSV files for Package <",ddc_plan_packages->list[cfr_pkgcnt
         ].package,">")
       ENDIF
      ELSE
       SET reply->downtime_required_ind = 1
       SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
       SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = (reply->check_list[reply->
       check_list_cnt].downtime_reasons_cnt+ 1)
       SET cfr_tmp_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
       SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,cfr_tmp_cnt)
       SET reply->check_list[reply->check_list_cnt].downtime_reasons[cfr_tmp_cnt].txt = build(
        "Unable to Load Readme Data from CSV files for Package <",ddc_plan_packages->list[cfr_pkgcnt]
        .package,">")
      ENDIF
     ENDIF
   ENDFOR
   IF ((ddc_plan_packages->readmes_found_ind=1)
    AND (reply->check_list[reply->check_list_cnt].downtime_reasons_cnt=0))
    IF (downtime_readme_check(request->plan_id,cfr_eid)=0)
     SET reply->downtime_required_ind = 1
     SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
     SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = (reply->check_list[reply->
     check_list_cnt].downtime_reasons_cnt+ 1)
     SET cfr_tmp_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
     SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,cfr_tmp_cnt)
     SET reply->check_list[reply->check_list_cnt].downtime_reasons[cfr_tmp_cnt].txt =
     "Failed while checking readmes for downtime execution."
    ENDIF
   ENDIF
   IF ((ddc_plan_packages->readmes_found_ind=0)
    AND (reply->check_list[reply->check_list_cnt].downtime_reasons_cnt=0))
    SET reply->check_list[reply->check_list_cnt].check_passed_ind = 1
   ENDIF
   IF ((reply->check_list[reply->check_list_cnt].check_passed_ind=0))
    SET cfr_status = "YES"
   ELSE
    SET cfr_status = "NO"
   ENDIF
   IF (update_dol_status_row(cfr_eid,"INSTALL PLAN","DT-READMES",cfr_ocd,cfr_status)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE load_readme_csv_data(lrcd_package_int,lrcd_eid)
   DECLARE lrcd_tmp_cnt = i4 WITH protect, noconstant(0)
   DECLARE lrcd_aload_method = i2 WITH public, noconstant(0)
   RECORD tmp_csvcontent(
     1 qual[*]
       2 table_name = vc
       2 filename = vc
       2 fileversion = vc
       2 loadscript = vc
       2 row_count = vc
       2 passive_ind = vc
       2 owner = vc
   )
   IF (determine_admin_load_method(lrcd_package_int,lrcd_aload_method)=0)
    RETURN(0)
   ENDIF
   IF (lrcd_aload_method=1)
    SET dm_err->eproc = "Saving off readme data from csvcontent."
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(csvcontent->qual,5))
     WHERE (csvcontent->qual[d.seq].table_name IN ("DM_README", "DM_OCD_README"))
      AND (csvcontent->qual[d.seq].owner=currdbuser)
     DETAIL
      lrcd_tmp_cnt = (lrcd_tmp_cnt+ 1), stat = alterlist(tmp_csvcontent->qual,lrcd_tmp_cnt),
      tmp_csvcontent->qual[lrcd_tmp_cnt].table_name = csvcontent->qual[d.seq].table_name,
      tmp_csvcontent->qual[lrcd_tmp_cnt].filename = csvcontent->qual[d.seq].filename, tmp_csvcontent
      ->qual[lrcd_tmp_cnt].fileversion = csvcontent->qual[d.seq].fileversion, tmp_csvcontent->qual[
      lrcd_tmp_cnt].loadscript = csvcontent->qual[d.seq].loadscript,
      tmp_csvcontent->qual[lrcd_tmp_cnt].row_count = csvcontent->qual[d.seq].row_count,
      tmp_csvcontent->qual[lrcd_tmp_cnt].passive_ind = csvcontent->qual[d.seq].passive_ind,
      tmp_csvcontent->qual[lrcd_tmp_cnt].owner = csvcontent->qual[d.seq].owner
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(tmp_csvcontent)
    ENDIF
    SET stat = alterlist(csvcontent->qual,0)
    SET lrcd_tmp_cnt = 0
    SET dm_err->eproc = "Repopulating csvcontent."
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(tmp_csvcontent->qual,5))
     WHERE (tmp_csvcontent->qual[d.seq].table_name IN ("DM_README", "DM_OCD_README"))
     DETAIL
      lrcd_tmp_cnt = (lrcd_tmp_cnt+ 1), stat = alterlist(csvcontent->qual,lrcd_tmp_cnt), csvcontent->
      qual[lrcd_tmp_cnt].table_name = tmp_csvcontent->qual[d.seq].table_name,
      csvcontent->qual[lrcd_tmp_cnt].filename = tmp_csvcontent->qual[d.seq].filename, csvcontent->
      qual[lrcd_tmp_cnt].fileversion = tmp_csvcontent->qual[d.seq].fileversion, csvcontent->qual[
      lrcd_tmp_cnt].loadscript = tmp_csvcontent->qual[d.seq].loadscript,
      csvcontent->qual[lrcd_tmp_cnt].row_count = tmp_csvcontent->qual[d.seq].row_count, csvcontent->
      qual[lrcd_tmp_cnt].passive_ind = tmp_csvcontent->qual[d.seq].passive_ind, csvcontent->qual[
      lrcd_tmp_cnt].owner = tmp_csvcontent->qual[d.seq].owner
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(csvcontent)
    ENDIF
    SET dm_err->eproc = "Checking for row in DM_ALPHA_FEATURES_ENV."
    SELECT INTO "nl:"
     FROM dm_alpha_features_env defa
     WHERE defa.environment_id=lrcd_eid
      AND defa.alpha_feature_nbr=lrcd_package_int
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_alpha_features_env defa
      SET defa.status = "Loading readme data for downtime check.", defa.start_dt_tm = cnvtdatetime(
        curdate,curtime3), defa.end_dt_tm = null,
       defa.environment_id = lrcd_eid, defa.alpha_feature_nbr = lrcd_package_int, defa.inst_mode =
       "DOWNTIME CHECK",
       defa.calling_script = "DM2_DOWNTIME_CHECKER", defa.curr_migration_ind = 0
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
    IF (load_package_schema_csv(lrcd_eid,lrcd_package_int)=0)
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE downtime_readme_check(drc_plan_id,drc_eid)
   DECLARE drc_rm_cnt = i4 WITH protect, noconstant(0)
   DECLARE drc_tmp2_cnt = i4 WITH protect, noconstant(0)
   DECLARE drc_downtime_ind = i2 WITH protect, noconstant(0)
   IF (get_batch_dm_ocd_readme((drc_plan_id * - (1.0)),drc_eid)=0)
    RETURN(0)
   ENDIF
   SET dm2_rr_misc->process_type = "PI"
   SET dm2_rr_misc->package_number = (drc_plan_id * - (1))
   SET dm2_rr_misc->env_id = drc_eid
   SET dm2_rr_misc->execution = "ALL"
   IF (drr_load_readmes_to_run(null)=0)
    RETURN(0)
   ENDIF
   FOR (drc_rm_cnt = 1 TO drr_readmes_to_run->readme_cnt)
     IF ((drr_readmes_to_run->readme[drc_rm_cnt].execution IN (dm2_rr_pre_schema_down,
     dm2_rr_post_schema_down))
      AND (drr_readmes_to_run->readme[drc_rm_cnt].skip=0))
      SET reply->downtime_required_ind = 1
      SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
      SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = (reply->check_list[reply->
      check_list_cnt].downtime_reasons_cnt+ 1)
      SET drc_tmp2_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
      SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,drc_tmp2_cnt)
      SET reply->check_list[reply->check_list_cnt].downtime_reasons[drc_tmp2_cnt].txt = build(
       "Downtime Readme: <",drr_readmes_to_run->readme[drc_rm_cnt].readme_id,"> will run.")
     ENDIF
   ENDFOR
   IF ((reply->check_list[reply->check_list_cnt].downtime_reasons_cnt=0))
    SET reply->check_list[reply->check_list_cnt].check_passed_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE update_dol_status_row(udsr_eid,udsr_project_type,udsr_project_name,udsr_ocd,udsr_status)
  IF (validate(ddcr_calling_script,"NOT_SET") != "DM2_DOWNTIME_CHECKER_RPT")
   SET dm_err->eproc = "Updating DM_OCD_LOG row for downtime status."
   CALL disp_msg("",dm_err->logfile,0)
   UPDATE  FROM dm_ocd_log dol
    SET dol.status = udsr_status, dol.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE dol.environment_id IN (0, udsr_eid)
     AND dol.project_type=udsr_project_type
     AND dol.project_name=udsr_project_name
     AND dol.ocd=udsr_ocd
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "request->plan_id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
    ROLLBACK
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->eproc = "No row found.  Inserting DM_OCD_LOG row for downtime status."
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_ocd_log dol
     SET dol.environment_id = udsr_eid, dol.project_type = udsr_project_type, dol.project_name =
      udsr_project_name,
      dol.ocd = udsr_ocd, dol.batch_dt_tm = cnvtdatetime(curdate,curtime3), dol.status = udsr_status,
      dol.updt_dt_tm = cnvtdatetime(curdate,curtime3), dol.active_ind = 1
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "request->plan_id"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = dm_err->emsg
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE check_eucswapccl(null)
   DECLARE dce_file_name = vc WITH protect, noconstant("")
   DECLARE dce_script_path = vc WITH protect, constant(trim(logical("cer_ocdtools")))
   DECLARE dce_ccv_tmp_cnt = i4 WITH protect, noconstant(0)
   SET reply->check_list_cnt = (reply->check_list_cnt+ 1)
   SET stat = alterlist(reply->check_list,reply->check_list_cnt)
   SET reply->check_list[reply->check_list_cnt].check_name = "EUCSWAPCCL_EXISTS"
   SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = 0
   SET dm_err->eproc = "Checking for existance of $cer_ocdtools/eucswapccl.ksh/com."
   CALL disp_msg("",dm_err->logfile,0)
   SET dce_file_name = evaluate(cursys,"AXP",concat(dce_script_path,"eucswapccl.com"),concat(
     dce_script_path,"/eucswapccl.ksh"))
   IF (dm2_findfile(dce_file_name)=0)
    SET reply->check_list[reply->check_list_cnt].check_passed_ind = 0
    SET reply->check_list[reply->check_list_cnt].downtime_reasons_cnt = (reply->check_list[reply->
    check_list_cnt].downtime_reasons_cnt+ 1)
    SET dce_ccv_tmp_cnt = reply->check_list[reply->check_list_cnt].downtime_reasons_cnt
    SET stat = alterlist(reply->check_list[reply->check_list_cnt].downtime_reasons,dce_ccv_tmp_cnt)
    SET reply->check_list[reply->check_list_cnt].downtime_reasons[dce_ccv_tmp_cnt].txt = concat(
     "Offline dictionary usage requires ",dce_file_name," to be present.")
   ELSE
    SET reply->check_list[reply->check_list_cnt].check_passed_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 IF (ddc_session_override > "")
  IF (dm2_push_cmd(concat('rdb alter session set nls_numeric_characters = "',ddc_nlsnumchar,'" go'),1
   )=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dm_err->err_ind=0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->downtime_required_ind = 1
 ENDIF
 CALL echorecord(reply)
 SET dm_err->eproc = "DM2_DOWNTIME_CHECKER Completed."
 CALL final_disp_msg(ddc_logfile_prefix)
END GO
