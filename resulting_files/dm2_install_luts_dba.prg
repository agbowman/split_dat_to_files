CREATE PROGRAM dm2_install_luts:dba
 SET trace progcachesize 255
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
 IF ((validate(luts_list->table_cnt,- (1))=- (1))
  AND (validate(luts_list->table_cnt,- (2))=- (2)))
  FREE RECORD luts_list
  RECORD luts_list(
    01 inst_cnt = i2
    01 parallel_degree = i2
    01 table_cnt = i4
    01 table_diff_cnt = i2
    01 table_diff_txn_cnt = i2
    01 add_column_cnt = i2
    01 add_instid_column_cnt = i2
    01 add_txn_column_cnt = i2
    01 modify_dd_cnt = i2
    01 set_index_visible_cnt = i2
    01 set_txn_index_visible_cnt = i2
    01 create_index_cnt = i2
    01 rename_index_cnt = i2
    01 create_txn_index_cnt = i2
    01 disable_txn_trigger_cnt = i2
    01 create_trigger_cnt = i2
    01 create_del_trigger_cnt = i2
    01 set_col_stats_cnt = i2
    01 set_txn_col_stats_cnt = i2
    01 set_instid_col_stats_cnt = i2
    01 default_index_tspace = vc
    01 use_txn_table_synonym_ind = i2
    01 config_curr_txn_table = vc
    01 default_free_bytes_mb = f8
    01 txn_schema_ind = i2
    01 qual[*]
      02 table_is_scn = i2
      02 table_is_luts = i2
      02 table_owner = vc
      02 table_name = vc
      02 suffixed_table_name = vc
      02 table_suffix = vc
      02 diff_ind = i2
      02 diff_txn_ind = i2
      02 add_column_ind = i2
      02 add_instid_column_ind = i2
      02 add_txn_column_ind = i2
      02 add_column_ddl = vc
      02 add_txn_column_ddl = vc
      02 add_instid_column_ddl = vc
      02 add_combined_column_ddl = vc
      02 set_col_stats_ind = i2
      02 set_instid_col_stats_ind = i2
      02 set_txn_col_stats_ind = i2
      02 num_rows = f8
      02 create_index_ind = i2
      02 rename_index_ind = i2
      02 create_txn_index_ind = i2
      02 create_index_ddl = vc
      02 rename_index_ddl = vc
      02 create_txn_index_ddl = vc
      02 set_index_visible_ddl = vc
      02 set_txn_index_visible_ddl = vc
      02 set_index_visible_ind = i2
      02 set_txn_index_visible_ind = i2
      02 set_index_visible_ddl = vc
      02 set_txn_index_visible_ddl = vc
      02 index_name = vc
      02 txn_index_name = vc
      02 index_tspace = vc
      02 free_bytes_mb = f8
      02 index_col_list = vc
      02 index_txn_col_list = vc
      02 tspace_needed_mb = f8
      02 new_trigger_ind = i2
      02 create_trigger_ind = i2
      02 disable_txn_trigger_ind = i2
      02 disable_txn_trigger_ddl = vc
      02 trigger_name = vc
      02 delete_tracking_ind = i2
      02 delete_tracking_ldt_idx = i4
      02 del_trigger_name = vc
      02 create_del_trigger_ind = i2
      02 create_del_trigger_ddl = vc
      02 new_del_trigger_ind = i2
      02 txn_info_char = vc
      02 original_trigger_ddl = vc
      02 original_del_trigger_ddl = vc
      02 original_txn_trigger_ddl = vc
      02 create_trigger_ddl = vc
      02 use_inst_id_ind = i2
      02 delete_tracking_only_ind = i2
    01 asm_ind = i2
    01 dg_cnt = i2
    01 dg_space_needed_ind = i2
    01 dg[*]
      02 dg_name = vc
      02 total_bytes_mb = f8
      02 reserved_bytes_mb = f8
      02 free_bytes_mb = f8
      02 assigned_bytes_mb = f8
      02 new_ind_cnt = i4
    01 tspace_cnt = i2
    01 tspace_needed_ind = i2
    01 ts[*]
      02 tspace_name = vc
      02 dg_name = vc
      02 data_file_cnt = i4
      02 max_bytes_mb = f8
      02 user_bytes_mb = f8
      02 reserved_bytes_mb = f8
      02 free_bytes_mb = f8
      02 assigned_bytes_mb = f8
      02 assigned_ind_names = vc
      02 new_ind_cnt = i4
    01 install_by_rdm_ind = i2
  )
 ENDIF
 IF ((validate(luts_dyn_trig->table_cnt,- (1))=- (1))
  AND (validate(luts_dyn_trig->table_cnt,- (2))=- (2)))
  FREE RECORD luts_dyn_trig
  RECORD luts_dyn_trig(
    1 table_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 tn_txt = vc
      2 pen_txt = vc
      2 pei_txt = vc
      2 tpk_txt = vc
      2 data_txt = vc
      2 del_log_condition = vc
      2 txn_log_condition = vc
      2 dup_delrow_var_values = vc
  )
 ENDIF
 IF ((validate(luts_drop_list->table_cnt,- (1))=- (1))
  AND (validate(luts_drop_list->table_cnt,- (2))=- (2)))
  FREE RECORD luts_drop_list
  RECORD luts_drop_list(
    1 table_cnt = i4
    1 drop_index_cnt = i4
    1 drop_txn_index_cnt = i4
    1 drop_trigger_cnt = i4
    1 drop_del_trigger_cnt = i4
    1 drop_txn_trigger_cnt = i4
    1 drop_txn_pkg_cnt = i4
    1 qual[*]
      2 table_owner = vc
      2 table_name = vc
      2 drop_index_ind = i2
      2 drop_txn_index_ind = i2
      2 drop_index_ddl = vc
      2 drop_index_reason = vc
      2 drop_txn_index_ddl = vc
      2 drop_txn_index_reason = vc
      2 drop_trigger_ind = i2
      2 drop_txn_trigger_ind = i2
      2 drop_trigger_ddl = vc
      2 drop_trigger_reason = vc
      2 drop_del_trigger_ind = i2
      2 drop_del_trigger_ddl = vc
      2 drop_del_trigger_reason = vc
      2 drop_txn_trigger_ddl = vc
      2 drop_txn_trigger_reason = vc
      2 drop_txn_pkg_ind = i2
      2 drop_txn_pkg_ddl = vc
      2 drop_txn_pkg_name = vc
      2 drop_txn_pkg_reason = vc
  )
 ENDIF
 DECLARE dld_load_tables(null) = i2
 DECLARE dld_diff_schema(null) = i2
 DECLARE dld_diff_trigger(ddt_trigger_name=vc,ddt_table_name=vc,ddt_trigger_txt=vc,ddt_diff_ind=i2(
   ref)) = i2
 DECLARE dld_gen_lutsonly_trigger(dglt_idx=i4,dgkt_ddl_txt=vc(ref)) = i2
 DECLARE dld_gen_compound_trigger(dgct_idx=i4,dgct_ddl_txt=vc(ref)) = i2
 DECLARE dld_gen_del_compound_trigger(dgct_idx=i4,dgct_ddl_txt=vc(ref)) = i2
 DECLARE dld_compare_trigger(dct_owner=i4,dct_trigger_name=vc,dct_trigger_txt=vc,dct_from_gtt=i4) =
 i4 WITH sql = "V500.DM2DMP_UTIL.COMPARE_TRIGGER", parameter
 DECLARE dld_load_original_trigger_ddl(null) = i2
 DECLARE dld_load_curr_txn_table(null) = i2
 SUBROUTINE dld_load_tables(null)
   DECLARE dlt_locidx = i4 WITH protect, noconstant(0)
   DECLARE dlt_drpobjidx = i4 WITH protect, noconstant(0)
   DECLARE dlt_dtd_error_list = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dlt_invalid_txn = i2 WITH protect, noconstant(0)
   DECLARE dlt_drop_threshold = i2 WITH protect, noconstant(100)
   DECLARE dlt_col_list = vc WITH protect, noconstant("")
   DECLARE dld_deltrk_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Loading trigger metadata"
   EXECUTE dm2_dbimport "cer_install:dm2_cdr_trig_meta.csv", "dm2_load_cdr_trig_csv", 100000
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_dyn_trig)
   ENDIF
   SET dm_err->eproc = "LAST_UTC_TS: Getting driver table list from DM_TABLES_DOC"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_tables_doc dtd,
     user_tables ut,
     dm_info di
    WHERE dtd.drop_ind=0
     AND dtd.table_name=di.info_name
     AND di.info_domain IN ("DM2SETUP_LAST_UTC_TS", "DM2SETUP_TXNSCN")
     AND di.info_name=ut.table_name
    ORDER BY di.info_name, di.info_domain
    HEAD REPORT
     luts_list->table_cnt = 0, stat = alterlist(luts_list->qual,luts_list->table_cnt)
    HEAD di.info_name
     luts_list->table_cnt = (luts_list->table_cnt+ 1)
     IF (mod(luts_list->table_cnt,10)=1)
      stat = alterlist(luts_list->qual,(luts_list->table_cnt+ 9))
     ENDIF
     luts_list->qual[luts_list->table_cnt].table_owner = "V500", luts_list->qual[luts_list->table_cnt
     ].table_name = dtd.table_name, luts_list->qual[luts_list->table_cnt].index_name = "DM2NOTSET",
     luts_list->qual[luts_list->table_cnt].index_col_list = "DM2NOTSET", luts_list->qual[luts_list->
     table_cnt].index_tspace = "DM2NOTSET", luts_list->qual[luts_list->table_cnt].create_trigger_ddl
      = "DM2NOTSET",
     luts_list->qual[luts_list->table_cnt].suffixed_table_name = trim(dtd.suffixed_table_name),
     luts_list->qual[luts_list->table_cnt].table_suffix = trim(dtd.table_suffix), luts_list->qual[
     luts_list->table_cnt].num_rows = ut.num_rows,
     luts_list->qual[luts_list->table_cnt].trigger_name = concat("TRG_",luts_list->qual[luts_list->
      table_cnt].table_suffix,"_LUTS"), luts_list->qual[luts_list->table_cnt].del_trigger_name =
     concat("TRG_DEL_",luts_list->qual[luts_list->table_cnt].table_suffix,"_LUTS"), luts_list->qual[
     luts_list->table_cnt].create_del_trigger_ddl = "DM2NOTSET",
     luts_list->qual[luts_list->table_cnt].new_trigger_ind = 1, luts_list->qual[luts_list->table_cnt]
     .new_del_trigger_ind = 1
     IF (di.updt_applctx=1)
      luts_list->qual[luts_list->table_cnt].use_inst_id_ind = 1
     ELSEIF (di.updt_applctx=2)
      luts_list->qual[luts_list->table_cnt].delete_tracking_only_ind = 1
     ENDIF
    DETAIL
     IF (di.info_domain="DM2SETUP_LAST_UTC_TS")
      luts_list->qual[luts_list->table_cnt].table_is_luts = di.info_number, luts_list->qual[luts_list
      ->table_cnt].index_name = concat("XCER",luts_list->qual[luts_list->table_cnt].
       suffixed_table_name), luts_list->qual[luts_list->table_cnt].add_column_ind = evaluate(
       luts_list->qual[luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->
       table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].add_instid_column_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].use_inst_id_ind,0,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].add_column_ddl = "LAST_UTC_TS TIMESTAMP(9) NULL",
      luts_list->qual[luts_list->table_cnt].add_instid_column_ddl = "INST_ID NUMBER NULL",
      luts_list->qual[luts_list->table_cnt].set_col_stats_ind = evaluate(luts_list->qual[luts_list->
       table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].set_instid_col_stats_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].use_inst_id_ind,0,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].create_index_ind = evaluate(luts_list->qual[luts_list->
       table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].set_index_visible_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].
       table_is_luts), dld_deltrk_idx = 0, dld_deltrk_idx = locateval(dld_deltrk_idx,1,luts_dyn_trig
       ->table_cnt,luts_list->qual[luts_list->table_cnt].table_name,luts_dyn_trig->tbl[dld_deltrk_idx
       ].table_name)
      IF (dld_deltrk_idx > 0)
       luts_list->qual[luts_list->table_cnt].delete_tracking_ind = 1, luts_list->qual[luts_list->
       table_cnt].delete_tracking_ldt_idx = dld_deltrk_idx
      ELSE
       luts_list->qual[luts_list->table_cnt].delete_tracking_ind = 0
      ENDIF
     ELSE
      luts_list->qual[luts_list->table_cnt].table_is_scn = evaluate(luts_list->txn_schema_ind,0,0,di
       .info_number), luts_list->qual[luts_list->table_cnt].txn_index_name = concat("XCERTXN",
       luts_list->qual[luts_list->table_cnt].suffixed_table_name), luts_list->qual[luts_list->
      table_cnt].add_txn_column_ddl = "TXN_ID_TEXT VARCHAR2(200) NULL",
      luts_list->qual[luts_list->table_cnt].add_txn_column_ind = evaluate(luts_list->qual[luts_list->
       table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].table_is_scn),
      luts_list->qual[luts_list->table_cnt].set_txn_col_stats_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].
       table_is_scn), luts_list->qual[luts_list->table_cnt].create_txn_index_ind = evaluate(luts_list
       ->qual[luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt
       ].table_is_scn),
      luts_list->qual[luts_list->table_cnt].set_txn_index_visible_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].
       table_is_scn), luts_list->qual[luts_list->table_cnt].disable_txn_trigger_ind = 0
      IF (trim(di.info_char,3) > " ")
       luts_list->qual[luts_list->table_cnt].txn_info_char = di.info_char
      ENDIF
     ENDIF
    FOOT  di.info_name
     IF ((luts_list->qual[luts_list->table_cnt].table_is_scn=1)
      AND (luts_list->qual[luts_list->table_cnt].use_inst_id_ind=1)
      AND (luts_list->qual[luts_list->table_cnt].table_is_luts=0))
      CALL echo(concat(luts_list->qual[luts_list->table_cnt].table_name,
       " is an SCN-Only table and may not use INST_ID")), luts_list->qual[luts_list->table_cnt].
      use_inst_id_ind = 0
     ENDIF
     IF ((((luts_list->qual[luts_list->table_cnt].table_is_luts=0)
      AND (luts_list->qual[luts_list->table_cnt].table_is_scn=0)) OR ((luts_list->qual[luts_list->
     table_cnt].delete_tracking_only_ind=1))) )
      luts_list->qual[luts_list->table_cnt].create_trigger_ind = 0
     ELSE
      luts_list->qual[luts_list->table_cnt].create_trigger_ind = 1
     ENDIF
     IF ((((luts_list->qual[luts_list->table_cnt].table_is_luts=0)
      AND (luts_list->qual[luts_list->table_cnt].table_is_scn=0)) OR ((luts_list->qual[luts_list->
     table_cnt].delete_tracking_ind=0))) )
      luts_list->qual[luts_list->table_cnt].create_del_trigger_ind = 0
     ELSE
      luts_list->qual[luts_list->table_cnt].create_del_trigger_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(luts_list->qual,luts_list->table_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_list)
   ENDIF
   SET luts_drop_list->table_cnt = 0
   SET luts_drop_list->drop_index_cnt = 0
   SET luts_drop_list->drop_txn_index_cnt = 0
   SET luts_drop_list->drop_trigger_cnt = 0
   SET luts_drop_list->drop_del_trigger_cnt = 0
   SET luts_drop_list->drop_txn_pkg_cnt = 0
   SET luts_drop_list->drop_txn_trigger_cnt = 0
   SET stat = alterlist(luts_drop_list->qual,0)
   SET dm_err->eproc = "Load extraneous packages"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_objects uo,
     dm_tables_doc u
    WHERE uo.owner="V500"
     AND uo.object_name="PKG*TXNSCN"
     AND uo.object_type="PACKAGE"
     AND replace(replace(uo.object_name,"PKG_",""),"_TXNSCN","")=u.table_suffix
     AND u.table_name=u.full_table_name
    ORDER BY uo.object_name
    DETAIL
     IF ((luts_list->txn_schema_ind=0))
      dlt_invalid_txn = 1,
      CALL echo(concat("SCN object found, but SCN not active: ",uo.object_name))
     ENDIF
     dlt_drpobjidx = locateval(dlt_drpobjidx,1,luts_drop_list->table_cnt,u.table_name,luts_drop_list
      ->qual[dlt_drpobjidx].table_name)
     IF (dlt_drpobjidx=0)
      luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
       qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
      luts_drop_list->qual[dlt_drpobjidx].table_name = u.table_name, luts_drop_list->qual[
      dlt_drpobjidx].table_owner = uo.owner
     ENDIF
     luts_drop_list->drop_txn_pkg_cnt = (luts_drop_list->drop_txn_pkg_cnt+ 1), luts_drop_list->qual[
     dlt_drpobjidx].drop_txn_pkg_ind = 1, luts_drop_list->qual[dlt_drpobjidx].drop_txn_pkg_name = uo
     .object_name,
     luts_drop_list->qual[dlt_drpobjidx].drop_txn_pkg_ddl = concat("drop package ",trim(uo.owner),".",
      uo.object_name), luts_drop_list->qual[dlt_drpobjidx].drop_txn_pkg_reason = concat(trim(u
       .table_name)," is no longer required")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_triggers d
    WHERE d.owner="V500"
     AND ((d.trigger_name="TRG*LUTS") OR (d.trigger_name="TRG*TXNSCN"))
    DETAIL
     dlt_locidx = locateval(dlt_locidx,1,luts_list->table_cnt,d.table_name,luts_list->qual[dlt_locidx
      ].table_name), dlt_drpobjidx = locateval(dlt_drpobjidx,1,luts_drop_list->table_cnt,d.table_name,
      luts_drop_list->qual[dlt_drpobjidx].table_name)
     IF (d.trigger_name="TRG_DEL_*LUTS"
      AND ((dlt_locidx=0) OR (dlt_locidx > 0
      AND (((luts_list->qual[dlt_locidx].table_is_scn=0)
      AND (luts_list->qual[dlt_locidx].table_is_luts=0)) OR ((luts_list->qual[dlt_locidx].
     delete_tracking_ind=0))) )) )
      IF (dlt_drpobjidx=0)
       luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
        qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
       luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
       dlt_drpobjidx].table_owner = d.owner
      ENDIF
      luts_drop_list->drop_del_trigger_cnt = (luts_drop_list->drop_del_trigger_cnt+ 1),
      luts_drop_list->qual[dlt_drpobjidx].drop_del_trigger_ind = 1, luts_drop_list->qual[
      dlt_drpobjidx].drop_del_trigger_ddl = concat("drop trigger ",trim(d.owner),".",trim(d
        .trigger_name)),
      luts_drop_list->qual[dlt_drpobjidx].drop_del_trigger_reason = concat(trim(d.table_name),
       " is not a delete-tracking table")
     ELSEIF (d.trigger_name="TRG*LUTS"
      AND d.trigger_name != "TRG_DEL_*_LUTS"
      AND ((dlt_locidx=0) OR (dlt_locidx > 0
      AND (((luts_list->qual[dlt_locidx].table_is_scn=0)
      AND (luts_list->qual[dlt_locidx].table_is_luts=0)) OR ((luts_list->qual[dlt_locidx].
     delete_tracking_only_ind=1))) )) )
      IF (dlt_drpobjidx=0)
       luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
        qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
       luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
       dlt_drpobjidx].table_owner = d.owner
      ENDIF
      luts_drop_list->drop_trigger_cnt = (luts_drop_list->drop_trigger_cnt+ 1), luts_drop_list->qual[
      dlt_drpobjidx].drop_trigger_ind = 1, luts_drop_list->qual[dlt_drpobjidx].drop_trigger_ddl =
      concat("drop trigger ",trim(d.owner),".",trim(d.trigger_name))
      IF ((luts_list->qual[dlt_locidx].delete_tracking_only_ind=1))
       luts_drop_list->qual[dlt_drpobjidx].drop_trigger_reason = concat(trim(d.table_name),
        " is delete-tracking only table")
      ELSE
       luts_drop_list->qual[dlt_drpobjidx].drop_trigger_reason = concat(trim(d.table_name),
        " is not a LUTS and SCN candidate table")
      ENDIF
     ELSEIF (d.trigger_name="TRG*TXNSCN")
      IF (dlt_drpobjidx=0)
       luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
        qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
       luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
       dlt_drpobjidx].table_owner = d.owner
      ENDIF
      luts_drop_list->drop_txn_trigger_cnt = (luts_drop_list->drop_txn_trigger_cnt+ 1),
      luts_drop_list->qual[dlt_drpobjidx].drop_txn_trigger_ind = 1, luts_drop_list->qual[
      dlt_drpobjidx].drop_txn_trigger_ddl = concat("drop trigger ",trim(d.owner),".",trim(d
        .trigger_name)),
      luts_drop_list->qual[dlt_drpobjidx].drop_txn_trigger_reason = concat(trim(d.trigger_name),
       " is no longer required")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load extraneous indexes"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_ind_columns d
    WHERE d.table_owner="V500"
     AND d.index_owner="V500"
     AND ((d.index_name="XCER*"
     AND d.column_name IN ("INST_ID", "LAST_UTC_TS")) OR (d.index_name="XCERTXN*"
     AND d.column_name="TXN_ID_TEXT"))
     AND  NOT (d.index_name IN (
    (SELECT
     di.info_char
     FROM dm_info di
     WHERE di.info_domain="DM2_INSTALL_LUTS"
      AND di.info_name="BYPASS_EXTRANEOUS_INDEX")))
     AND  NOT (d.table_name IN ("DM_DELETE_TRACKING", "DM_TXN_TRACKING"))
    ORDER BY d.table_name, d.index_name, d.column_position
    HEAD d.table_name
     dlt_locidx = 0, dlt_locidx = locateval(dlt_locidx,1,luts_list->table_cnt,d.table_name,luts_list
      ->qual[dlt_locidx].table_name)
    HEAD d.index_name
     dlt_col_list = ""
    DETAIL
     dlt_col_list = concat(dlt_col_list,",",trim(d.column_name))
     IF ((luts_list->txn_schema_ind=0)
      AND d.column_name="TXN_ID_TEXT")
      dlt_invalid_txn = 1,
      CALL echo(concat("SCN object found, but SCN not active: ",d.index_name))
     ENDIF
    FOOT  d.index_name
     dlt_col_list = replace(dlt_col_list,",","",1),
     CALL echo(concat(d.table_name,".",d.index_name,":",dlt_col_list))
     IF (((dlt_locidx=0) OR (((dlt_locidx > 0
      AND d.index_name != "XCERTXN*"
      AND (((luts_list->qual[dlt_locidx].use_inst_id_ind=1)
      AND findstring("INST_ID",dlt_col_list)=0) OR ((luts_list->qual[dlt_locidx].use_inst_id_ind=0)
      AND findstring("INST_ID",dlt_col_list) > 0)) ) OR (((dlt_locidx > 0
      AND (((luts_list->qual[dlt_locidx].table_is_scn=0)) OR ((luts_list->qual[dlt_locidx].
     table_is_luts=0))) ) OR (dlt_locidx > 0
      AND (luts_list->qual[dlt_locidx].delete_tracking_only_ind=1))) )) )) )
      dlt_drpobjidx = locateval(dlt_drpobjidx,1,luts_drop_list->table_cnt,d.table_name,luts_drop_list
       ->qual[dlt_drpobjidx].table_name)
      IF (dlt_locidx > 0
       AND (luts_list->qual[dlt_locidx].delete_tracking_only_ind=1))
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       IF (d.index_name="XCERTXN*")
        luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_ind = 1, luts_drop_list->qual[
        dlt_drpobjidx].drop_txn_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d
          .index_name)), luts_drop_list->drop_txn_index_cnt = (luts_drop_list->drop_txn_index_cnt+ 1),
        luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_reason = concat(trim(d.table_name),
         " is a DELETE TRACKING ONLY candidate table")
       ELSE
        luts_drop_list->qual[dlt_drpobjidx].drop_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx].
        drop_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d.index_name)),
        luts_drop_list->drop_index_cnt = (luts_drop_list->drop_index_cnt+ 1),
        luts_drop_list->qual[dlt_drpobjidx].drop_index_reason = concat(trim(d.table_name),
         " is a DELETE TRACKING ONLY candidate table")
       ENDIF
      ELSEIF (d.column_name="LAST_UTC_TS"
       AND ((dlt_locidx=0) OR (dlt_locidx > 0
       AND (luts_list->qual[dlt_locidx].table_is_luts=0))) )
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       luts_drop_list->qual[dlt_drpobjidx].drop_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx].
       drop_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d.index_name)),
       luts_drop_list->drop_index_cnt = (luts_drop_list->drop_index_cnt+ 1),
       luts_drop_list->qual[dlt_drpobjidx].drop_index_reason = concat(trim(d.table_name),
        " is not a LUTS candidate table")
      ELSEIF (d.column_name="TXN_ID_TEXT"
       AND ((dlt_locidx=0) OR (dlt_locidx > 0
       AND (luts_list->qual[dlt_locidx].table_is_scn=0))) )
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx
       ].drop_txn_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d.index_name)),
       luts_drop_list->drop_txn_index_cnt = (luts_drop_list->drop_txn_index_cnt+ 1),
       luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_reason = concat(trim(d.table_name),
        " is not a SCN candidate table")
      ELSEIF (dlt_locidx > 0
       AND d.index_name != "XCERTXN*"
       AND (((luts_list->qual[dlt_locidx].use_inst_id_ind=1)
       AND findstring("INST_ID",dlt_col_list)=0) OR ((luts_list->qual[dlt_locidx].use_inst_id_ind=0)
       AND findstring("INST_ID",dlt_col_list) > 0)) )
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       IF (d.index_name != "XCER_O_*")
        luts_list->qual[dlt_locidx].rename_index_ind = 1, luts_list->qual[dlt_locidx].
        rename_index_ddl = concat("alter index ",trim(d.index_owner),".",trim(d.index_name),
         " rename to ",
         "XCER_O_",luts_list->qual[dlt_locidx].suffixed_table_name)
       ENDIF
       luts_drop_list->qual[dlt_drpobjidx].drop_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx].
       drop_index_ddl = concat("drop index ",trim(d.index_owner),".","XCER_O_",luts_list->qual[
        dlt_locidx].suffixed_table_name), luts_drop_list->drop_index_cnt = (luts_drop_list->
       drop_index_cnt+ 1),
       luts_drop_list->qual[dlt_drpobjidx].drop_index_reason = concat(trim(d.table_name),
        " incorrect index structure")
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_drop_list)
   ENDIF
   IF (dlt_invalid_txn=1)
    SET dm_err->eproc = "LAST_UTC_TS: Check if invalid txn bypass is enabled"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_INSTALL_LUTS"
      AND di.info_name="DROP_INVALID_SCN_OBJ"
     DETAIL
      CALL echo("Invalid SCN object bypass found"), dlt_invalid_txn = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dlt_invalid_txn=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "One or more tables had invalid metadata. Run in PREVIEW to view listing in output."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_load_curr_txn_table(null)
   IF (textlen(luts_list->config_curr_txn_table) > 0)
    SET dm_err->eproc = concat("txn table already determined. LUTS triggers will write to ",luts_list
     ->config_curr_txn_table)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_LUTS"
     AND di.info_name="TXN_STAGING_TABLE"
    WITH nocounter
   ;end select
   IF (check_error("Checking DM_INFO for 'TXN_STAGING_TABLE' flag")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING"
    SET luts_list->use_txn_table_synonym_ind = 0
    SET dm_err->eproc =
    "'TXN_STAGING_TABLE' row does not exist in DM_INFO. LUTS triggers will write to DM_TXN_TRACKING."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects x
    WHERE x.owner="V500"
     AND x.object_name="DM_TXN_TRACKING_STG"
     AND x.object_type="TABLE"
    WITH nocounter
   ;end select
   IF (check_error("Checking for existence of DM_TXN_TRACKING_STG table")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING"
    SET luts_list->use_txn_table_synonym_ind = 0
    SET dm_err->eproc =
    "DM_TXN_TRACKING_STG table does not exist. LUTS triggers will write to DM_TXN_TRACKING."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_dependencies x
    WHERE x.owner="V500"
     AND x.name="DM_SCN_OBJECTS"
     AND x.type="PACKAGE BODY"
     AND x.referenced_name="SCOUT_STG_READ_VW"
     AND x.referenced_type="VIEW"
    WITH nocounter
   ;end select
   IF (check_error("Checking if scout procedure supports DM_TXN_TRACKING_STG table")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING"
    SET luts_list->use_txn_table_synonym_ind = 0
    SET dm_err->eproc =
    "Scout process does not support DM_TXN_TRACKING_STG table. LUTS triggers will write to DM_TXN_TRACKING."
   ELSE
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING_STG"
    SET luts_list->use_txn_table_synonym_ind = 1
    SET dm_err->eproc =
    "Scout process supports DM_TXN_TRACKING_STG table. LUTS triggers will write to DM_TXN_TRACKING_STG."
   ENDIF
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_diff_schema(null)
   DECLARE dds_locidx = i4 WITH protect, noconstant(0)
   DECLARE dds_str = vc WITH protect, noconstant("")
   DECLARE dds_cnt = i4 WITH protect, noconstant(0)
   DECLARE dds_tslocidx = i4 WITH protect, noconstant(0)
   DECLARE dds_dglocidx = i4 WITH protect, noconstant(0)
   DECLARE dds_is_11204 = i2 WITH protect, noconstant(0)
   DECLARE dds_dg_name = vc WITH protect, noconstant(" ")
   DECLARE dds_tsp_reserve_pct = f8 WITH protect, noconstant(0.1)
   DECLARE dds_tsp_raw_reserve_pct = f8 WITH protect, noconstant(0.25)
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3=0)
    AND (dm2_rdbms_version->level4 >= 4))) )) )) )
    SET dds_is_11204 = 1
   ENDIF
   SET dm_err->eproc =
   "Evaluating accurate TXN_ID_TEXT and LAST_UTC_TS column existence against driver table list"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    lutscol_no_stats = nullind(utc.last_analyzed)
    FROM user_tab_columns utc
    WHERE utc.column_name IN ("LAST_UTC_TS", "TXN_ID_TEXT", "INST_ID")
    ORDER BY utc.table_name
    HEAD utc.table_name
     dds_locidx = locateval(dds_locidx,1,luts_list->table_cnt,utc.table_name,luts_list->qual[
      dds_locidx].table_name)
    DETAIL
     IF (dds_locidx > 0)
      IF (utc.column_name="LAST_UTC_TS")
       luts_list->qual[dds_locidx].add_column_ind = 0, luts_list->qual[dds_locidx].set_col_stats_ind
        = evaluate(lutscol_no_stats,1,1,0)
      ELSEIF (utc.column_name="INST_ID")
       luts_list->qual[dds_locidx].add_instid_column_ind = 0, luts_list->qual[dds_locidx].
       set_instid_col_stats_ind = evaluate(lutscol_no_stats,1,1,0)
      ELSE
       luts_list->qual[dds_locidx].add_txn_column_ind = 0, luts_list->qual[dds_locidx].
       set_txn_col_stats_ind = evaluate(lutscol_no_stats,1,1,0)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Evaluating accurate TXN_ID_TEXT and LUTS indexing against driver table list"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_ind_columns uic,
     user_indexes ui
    WHERE ((uic.column_name="TXN_ID_TEXT"
     AND uic.column_position=1) OR (uic.column_name IN ("INST_ID", "LAST_UTC_TS")
     AND uic.column_position IN (1, 2)))
     AND ui.table_name=uic.table_name
     AND ui.index_name=uic.index_name
    ORDER BY uic.table_name
    HEAD uic.table_name
     dds_locidx = locateval(dds_locidx,1,luts_list->table_cnt,uic.table_name,luts_list->qual[
      dds_locidx].table_name)
    DETAIL
     IF (dds_locidx > 0)
      IF (uic.column_name IN ("INST_ID", "LAST_UTC_TS"))
       IF (((uic.column_name="INST_ID"
        AND uic.column_position=1
        AND (luts_list->qual[dds_locidx].use_inst_id_ind=1)) OR (uic.column_name="LAST_UTC_TS"
        AND uic.column_position=1
        AND (luts_list->qual[dds_locidx].use_inst_id_ind=0))) )
        luts_list->qual[dds_locidx].create_index_ind = 0
        IF (dds_is_11204=1
         AND ui.visibility="VISIBLE")
         luts_list->qual[dds_locidx].set_index_visible_ind = 0
        ELSE
         IF (dds_is_11204=0)
          luts_list->qual[dds_locidx].set_index_visible_ind = 0
         ENDIF
        ENDIF
       ENDIF
      ELSE
       luts_list->qual[dds_locidx].create_txn_index_ind = 0
       IF (dds_is_11204=1
        AND ui.visibility="VISIBLE")
        luts_list->qual[dds_locidx].set_txn_index_visible_ind = 0
       ELSE
        IF (dds_is_11204=0)
         luts_list->qual[dds_locidx].set_txn_index_visible_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Evaluating TXNSCN and LUTS trigger build against driver table list"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_triggers ut
    WHERE ((ut.trigger_name="TRG*LUTS") OR (ut.trigger_name="TRG*TXNSCN"))
    ORDER BY ut.table_name
    HEAD ut.table_name
     dds_locidx = locateval(dds_locidx,1,luts_list->table_cnt,ut.table_name,luts_list->qual[
      dds_locidx].table_name)
    DETAIL
     IF (dds_locidx > 0)
      IF (ut.trigger_name="TRG_DEL_*LUTS")
       luts_list->qual[dds_locidx].create_del_trigger_ind = 0, luts_list->qual[dds_locidx].
       new_del_trigger_ind = 0
      ELSEIF (ut.trigger_name="TRG*LUTS")
       luts_list->qual[dds_locidx].create_trigger_ind = 0, luts_list->qual[dds_locidx].
       new_trigger_ind = 0
      ELSE
       IF (ut.status="ENABLED")
        luts_list->qual[dds_locidx].disable_txn_trigger_ind = 1, luts_list->qual[dds_locidx].
        disable_txn_trigger_ddl = concat("alter trigger ",trim(ut.trigger_name)," disable")
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Evaluating existing triggers for differences"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dds_locidx = 1 TO luts_list->table_cnt)
     IF ((((luts_list->qual[dds_locidx].table_is_scn > 0)) OR ((luts_list->qual[dds_locidx].
     table_is_luts > 0))) )
      IF ((luts_list->qual[dds_locidx].delete_tracking_only_ind=0))
       IF ((((luts_list->qual[dds_locidx].table_is_scn=0)) OR ((luts_list->txn_schema_ind=0))) )
        IF (dld_gen_lutsonly_trigger(dds_locidx,dds_str)=0)
         RETURN(0)
        ENDIF
        SET luts_list->qual[dds_locidx].create_trigger_ddl = dds_str
       ELSE
        IF (dld_gen_compound_trigger(dds_locidx,dds_str)=0)
         RETURN(0)
        ENDIF
        SET luts_list->qual[dds_locidx].create_trigger_ddl = dds_str
       ENDIF
      ENDIF
      IF ((luts_list->qual[dds_locidx].delete_tracking_ind=1))
       IF (dld_gen_del_compound_trigger(dds_locidx,dds_str)=0)
        RETURN(0)
       ENDIF
       SET luts_list->qual[dds_locidx].create_del_trigger_ddl = dds_str
      ENDIF
      IF ((luts_list->qual[dds_locidx].new_del_trigger_ind=0))
       IF ((luts_list->qual[dds_locidx].delete_tracking_ind=1))
        IF (dld_diff_trigger(luts_list->qual[dds_locidx].del_trigger_name,luts_list->qual[dds_locidx]
         .table_name,luts_list->qual[dds_locidx].create_del_trigger_ddl,luts_list->qual[dds_locidx].
         create_del_trigger_ind)=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
      IF ((luts_list->qual[dds_locidx].new_trigger_ind=0)
       AND (luts_list->qual[dds_locidx].delete_tracking_only_ind=0))
       IF (dld_diff_trigger(luts_list->qual[dds_locidx].trigger_name,luts_list->qual[dds_locidx].
        table_name,luts_list->qual[dds_locidx].create_trigger_ddl,luts_list->qual[dds_locidx].
        create_trigger_ind)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (dld_load_original_trigger_ddl(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Accumulating LAST_UTC_TS and TXN schema change scope across tables evaluated"
   CALL disp_msg("",dm_err->logfile,0)
   SET luts_list->add_column_cnt = 0
   SET luts_list->add_instid_column_cnt = 0
   SET luts_list->create_index_cnt = 0
   SET luts_list->rename_index_cnt = 0
   SET luts_list->create_trigger_cnt = 0
   SET luts_list->create_del_trigger_cnt = 0
   SET luts_list->table_diff_cnt = 0
   SET luts_list->set_col_stats_cnt = 0
   SET luts_list->set_instid_col_stats_cnt = 0
   SET luts_list->set_index_visible_cnt = 0
   SET luts_list->disable_txn_trigger_cnt = 0
   SET luts_list->add_txn_column_cnt = 0
   SET luts_list->create_txn_index_cnt = 0
   SET luts_list->set_txn_col_stats_cnt = 0
   SET luts_list->table_diff_txn_cnt = 0
   SET luts_list->set_txn_index_visible_cnt = 0
   FOR (dds_locidx = 1 TO luts_list->table_cnt)
     IF ((luts_list->qual[dds_locidx].add_column_ind=1))
      SET luts_list->add_column_cnt = (luts_list->add_column_cnt+ 1)
      SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat(luts_list->qual[dds_locidx].
       add_combined_column_ddl,",",luts_list->qual[dds_locidx].add_column_ddl)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].add_instid_column_ind=1))
      SET luts_list->add_instid_column_cnt = (luts_list->add_instid_column_cnt+ 1)
      SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat(luts_list->qual[dds_locidx].
       add_combined_column_ddl,",",luts_list->qual[dds_locidx].add_instid_column_ddl)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_index_ind=1))
      SET luts_list->create_index_cnt = (luts_list->create_index_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].rename_index_ind=1))
      SET luts_list->rename_index_cnt = (luts_list->rename_index_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_index_visible_ind=1))
      SET luts_list->set_index_visible_cnt = (luts_list->set_index_visible_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_trigger_ind > 0))
      SET luts_list->create_trigger_cnt = (luts_list->create_trigger_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_del_trigger_ind > 0))
      SET luts_list->create_del_trigger_cnt = (luts_list->create_del_trigger_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_col_stats_ind=1))
      SET luts_list->set_col_stats_cnt = (luts_list->set_col_stats_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_instid_col_stats_ind=1))
      SET luts_list->set_instid_col_stats_cnt = (luts_list->set_instid_col_stats_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].diff_ind=1))
      SET luts_list->table_diff_cnt = (luts_list->table_diff_cnt+ 1)
     ENDIF
     IF ((luts_list->qual[dds_locidx].add_txn_column_ind=1))
      SET luts_list->add_txn_column_cnt = (luts_list->add_txn_column_cnt+ 1)
      SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat(luts_list->qual[dds_locidx].
       add_combined_column_ddl,",",luts_list->qual[dds_locidx].add_txn_column_ddl)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].disable_txn_trigger_ind=1))
      SET luts_list->disable_txn_trigger_cnt = (luts_list->disable_txn_trigger_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_txn_index_ind=1))
      SET luts_list->create_txn_index_cnt = (luts_list->create_txn_index_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_txn_index_visible_ind=1))
      SET luts_list->set_txn_index_visible_cnt = (luts_list->set_txn_index_visible_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_txn_col_stats_ind=1))
      SET luts_list->set_txn_col_stats_cnt = (luts_list->set_txn_col_stats_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].diff_txn_ind=1))
      SET luts_list->table_diff_txn_cnt = (luts_list->table_diff_txn_cnt+ 1)
     ENDIF
     SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat("ALTER TABLE ",trim(luts_list->
       qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].table_name)," ADD (",
      replace(luts_list->qual[dds_locidx].add_combined_column_ddl,",","",1),")")
   ENDFOR
   SET dm_err->eproc = "LAST_UTC_TS: Retrieving tablespace reserve percentage"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_LUTS"
     AND di.info_name IN ("RESERVE_PCT", "RAW_RESERVE_PCT")
    DETAIL
     IF (di.info_name="RESERVE_PCT")
      dds_tsp_reserve_pct = di.info_number
     ELSE
      dds_tsp_raw_reserve_pct = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF ((((luts_list->create_index_cnt > 0)) OR ((luts_list->create_txn_index_cnt > 0))) )
    SET dm_err->eproc = "LAST_UTC_TS: Retrieving ASM/RAW tablespace usage"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_data_files ddf
     WHERE tablespace_name="SYSTEM"
      AND file_name="*/dev/*"
     HEAD REPORT
      luts_list->asm_ind = 1
     DETAIL
      luts_list->asm_ind = 0
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc =
    "LAST_UTC_TS: Loading existing index tablespaces for affected tables into memory"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     FROM user_indexes ui
     WHERE ui.index_type="NORMAL"
      AND ui.tablespace_name IS NOT null
      AND  NOT (ui.tablespace_name IN ("SYS", "SYSTEM", "MISC", "*UNDO*"))
     ORDER BY ui.tablespace_name
     HEAD REPORT
      luts_list->tspace_cnt = 0, stat = alterlist(luts_list->ts,luts_list->tspace_cnt)
     DETAIL
      luts_list->tspace_cnt = (luts_list->tspace_cnt+ 1)
      IF (mod(luts_list->tspace_cnt,10)=1)
       stat = alterlist(luts_list->ts,(luts_list->tspace_cnt+ 9))
      ENDIF
      luts_list->ts[luts_list->tspace_cnt].tspace_name = ui.tablespace_name, luts_list->ts[luts_list
      ->tspace_cnt].dg_name = "DM2NOTSET", luts_list->ts[luts_list->tspace_cnt].data_file_cnt = 0
     FOOT REPORT
      stat = alterlist(luts_list->ts,luts_list->tspace_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((luts_list->asm_ind=1))
     SET dm_err->eproc = "LAST_UTC_TS: Loading data file free space information into memory"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dba_data_files ddf
      ORDER BY ddf.tablespace_name, ddf.file_name
      DETAIL
       dds_locidx = locateval(dds_locidx,1,luts_list->tspace_cnt,ddf.tablespace_name,luts_list->ts[
        dds_locidx].tspace_name)
       IF (dds_locidx > 0)
        luts_list->ts[dds_locidx].data_file_cnt = (luts_list->ts[dds_locidx].data_file_cnt+ 1),
        dds_dg_name = substring(2,(findstring("/",ddf.file_name,1,0) - 2),ddf.file_name)
        IF ((luts_list->ts[dds_locidx].dg_name="DM2NOTSET"))
         luts_list->ts[dds_locidx].dg_name = dds_dg_name
        ENDIF
        IF ((dds_dg_name=luts_list->ts[dds_locidx].dg_name))
         IF (ddf.autoextensible="YES")
          luts_list->ts[dds_locidx].max_bytes_mb = (luts_list->ts[dds_locidx].max_bytes_mb+ ((ddf
          .maxbytes/ 1024)/ 1024)), luts_list->ts[dds_locidx].user_bytes_mb = (luts_list->ts[
          dds_locidx].user_bytes_mb+ ((ddf.user_bytes/ 1024)/ 1024)), luts_list->ts[dds_locidx].
          free_bytes_mb = (luts_list->ts[dds_locidx].free_bytes_mb+ (((ddf.maxbytes - ddf.user_bytes)
          / 1024)/ 1024)),
          luts_list->ts[dds_locidx].reserved_bytes_mb = (luts_list->ts[dds_locidx].free_bytes_mb *
          dds_tsp_reserve_pct)
         ENDIF
        ENDIF
       ENDIF
      FOOT  ddf.tablespace_name
       IF (dds_locidx > 0)
        IF ((luts_list->default_index_tspace="DM2NOTSET"))
         luts_list->default_index_tspace = ddf.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ELSEIF ((luts_list->default_free_bytes_mb < luts_list->ts[dds_locidx].free_bytes_mb))
         luts_list->default_index_tspace = ddf.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "LAST_UTC_TS: Loading ASM diskgroup information into memory"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM v$asm_diskgroup vad
      HEAD REPORT
       luts_list->dg_cnt = 0, stat = alterlist(luts_list->dg,luts_list->dg_cnt)
      DETAIL
       luts_list->dg_cnt = (luts_list->dg_cnt+ 1), stat = alterlist(luts_list->dg,luts_list->dg_cnt),
       luts_list->dg[luts_list->dg_cnt].dg_name = vad.name,
       luts_list->dg[luts_list->dg_cnt].free_bytes_mb = vad.free_mb, luts_list->dg[luts_list->dg_cnt]
       .total_bytes_mb = vad.total_mb, luts_list->dg[luts_list->dg_cnt].reserved_bytes_mb = (vad
       .free_mb * dds_tsp_reserve_pct)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((luts_list->dg_cnt=0))
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "LAST_UTC_TS: No diskgroups found in v$asm_diskgroup for LAST_UTC_TS tablespace processing"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = "LAST_UTC_TS: Loading raw data file free space into memory"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      dfs.tablespace_name, free_bytes = max(dfs.bytes), file_cnt = count(dfs.file_id)
      FROM dba_free_space dfs
      GROUP BY dfs.tablespace_name
      ORDER BY dfs.tablespace_name
      DETAIL
       dds_locidx = locateval(dds_locidx,1,luts_list->tspace_cnt,dfs.tablespace_name,luts_list->ts[
        dds_locidx].tspace_name)
       IF (dds_locidx > 0)
        luts_list->ts[dds_locidx].data_file_cnt = 1, luts_list->ts[dds_locidx].free_bytes_mb = ((
        free_bytes/ 1024)/ 1024), luts_list->ts[dds_locidx].reserved_bytes_mb = (luts_list->ts[
        dds_locidx].free_bytes_mb * dds_tsp_raw_reserve_pct)
       ENDIF
      FOOT  dfs.tablespace_name
       IF (dds_locidx > 0)
        IF ((luts_list->default_index_tspace="DM2NOTSET"))
         luts_list->default_index_tspace = dfs.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ELSEIF ((luts_list->default_free_bytes_mb < luts_list->ts[dds_locidx].free_bytes_mb))
         luts_list->default_index_tspace = dfs.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    FOR (dds_locidx = 1 TO luts_list->table_cnt)
      IF ((((luts_list->qual[dds_locidx].create_index_ind=1)) OR ((luts_list->qual[dds_locidx].
      create_txn_index_ind=1))) )
       SET luts_list->qual[dds_locidx].index_col_list = evaluate(luts_list->qual[dds_locidx].
        use_inst_id_ind,1,"INST_ID,LAST_UTC_TS","LAST_UTC_TS")
       SET luts_list->qual[dds_locidx].index_txn_col_list = "TXN_ID_TEXT"
       SET dm_err->eproc = concat("LAST_UTC_TS:  Retrieving index tablespaces used by table ",
        luts_list->qual[dds_locidx].table_name)
       CALL disp_msg("",dm_err->logfile,0)
       SELECT DISTINCT INTO "nl:"
        ui.tablespace_name
        FROM user_indexes ui
        WHERE ui.index_type="NORMAL"
         AND  NOT (ui.tablespace_name IN ("MISC", "SYS", "SYSTEM", "UNDO*"))
         AND (ui.table_name=luts_list->qual[dds_locidx].table_name)
        ORDER BY ui.tablespace_name
        HEAD REPORT
         tsidx = 0
        DETAIL
         tsidx = locateval(tsidx,1,luts_list->tspace_cnt,ui.tablespace_name,luts_list->ts[tsidx].
          tspace_name)
         IF (tsidx > 0)
          IF ((luts_list->qual[dds_locidx].index_tspace="DM2NOTSET"))
           luts_list->qual[dds_locidx].index_tspace = luts_list->ts[tsidx].tspace_name
          ELSE
           IF (((luts_list->ts[tsidx].free_bytes_mb - luts_list->ts[tsidx].reserved_bytes_mb) >
           luts_list->qual[dds_locidx].free_bytes_mb))
            luts_list->qual[dds_locidx].index_tspace = luts_list->ts[tsidx].tspace_name, luts_list->
            qual[dds_locidx].free_bytes_mb = (luts_list->ts[tsidx].free_bytes_mb - luts_list->ts[
            tsidx].reserved_bytes_mb)
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF ((luts_list->qual[dds_locidx].index_tspace="DM2NOTSET"))
        SET luts_list->qual[dds_locidx].index_tspace = luts_list->default_index_tspace
        SET luts_list->qual[dds_locidx].free_bytes_mb = luts_list->default_free_bytes_mb
       ENDIF
       SET luts_list->qual[dds_locidx].create_index_ddl = concat("CREATE INDEX ",trim(luts_list->
         qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].index_name)," ON ",
        trim(luts_list->qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].table_name
         )," ( ",trim(luts_list->qual[dds_locidx].index_col_list),
        " )"," LOGGING ONLINE ",evaluate(dds_is_11204,1,"INVISIBLE "," ")," TABLESPACE ",trim(
         luts_list->qual[dds_locidx].index_tspace))
       SET luts_list->qual[dds_locidx].create_txn_index_ddl = concat("CREATE INDEX ",trim(luts_list->
         qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].txn_index_name)," ON ",
        trim(luts_list->qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].table_name
         )," ( ",trim(luts_list->qual[dds_locidx].index_txn_col_list),
        " )"," LOGGING ONLINE ",evaluate(dds_is_11204,1,"INVISIBLE "," ")," TABLESPACE ",trim(
         luts_list->qual[dds_locidx].index_tspace))
       IF ((luts_list->qual[dds_locidx].tspace_needed_mb=0))
        IF ((luts_list->qual[dds_locidx].tspace_needed_mb=0))
         SET luts_list->qual[dds_locidx].tspace_needed_mb = 1
        ENDIF
       ENDIF
       SET dds_tslocidx = locateval(dds_tslocidx,1,luts_list->tspace_cnt,luts_list->qual[dds_locidx].
        index_tspace,luts_list->ts[dds_tslocidx].tspace_name)
       IF (dds_tslocidx > 0)
        SET luts_list->ts[dds_tslocidx].assigned_bytes_mb = (luts_list->ts[dds_tslocidx].
        assigned_bytes_mb+ luts_list->qual[dds_locidx].tspace_needed_mb)
        SET luts_list->ts[dds_tslocidx].assigned_ind_names = concat(luts_list->ts[dds_tslocidx].
         assigned_ind_names,luts_list->qual[dds_locidx].index_name,",")
        SET luts_list->ts[dds_tslocidx].new_ind_cnt = (luts_list->ts[dds_tslocidx].new_ind_cnt+ 1)
        SET dds_dglocidx = locateval(dds_dglocidx,1,luts_list->dg_cnt,luts_list->ts[dds_tslocidx].
         dg_name,luts_list->dg[dds_dglocidx].dg_name)
        IF (dds_dglocidx > 0)
         SET luts_list->dg[dds_dglocidx].assigned_bytes_mb = (luts_list->dg[dds_dglocidx].
         assigned_bytes_mb+ luts_list->qual[dds_locidx].tspace_needed_mb)
         SET luts_list->dg[dds_dglocidx].new_ind_cnt = (luts_list->dg[dds_dglocidx].new_ind_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((((luts_list->set_index_visible_cnt > 0)) OR ((luts_list->set_txn_index_visible_cnt > 0))) )
    FOR (dds_locidx = 1 TO luts_list->table_cnt)
      IF ((((luts_list->qual[dds_locidx].set_index_visible_ind=1)) OR ((luts_list->qual[dds_locidx].
      set_txn_index_visible_ind=1))) )
       IF ((luts_list->qual[dds_locidx].set_index_visible_ind=1))
        SET luts_list->qual[dds_locidx].set_index_visible_ddl = concat('DM2_FINISH_INDEX "',trim(
          luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].table_name),
         '","',
         trim(luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].
          index_name),'" GO')
       ENDIF
       IF ((luts_list->qual[dds_locidx].set_txn_index_visible_ind=1))
        SET luts_list->qual[dds_locidx].set_txn_index_visible_ddl = concat('DM2_FINISH_INDEX "',trim(
          luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].table_name),
         '","',
         trim(luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].
          txn_index_name),'" GO')
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET dm_err->eproc = "LAST_UTC_TS: Checking for Disk Group impact"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dds_locidx = 1 TO luts_list->dg_cnt)
     IF ((luts_list->dg[dds_locidx].assigned_bytes_mb > (luts_list->dg[dds_locidx].free_bytes_mb -
     luts_list->dg[dds_locidx].reserved_bytes_mb)))
      SET luts_list->dg_space_needed_ind = 1
     ENDIF
   ENDFOR
   SET dm_err->eproc = "LAST_UTC_TS: Checking for Tablespace impact"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dds_locidx = 1 TO luts_list->tspace_cnt)
     IF ((luts_list->ts[dds_locidx].assigned_bytes_mb > (luts_list->ts[dds_locidx].free_bytes_mb -
     luts_list->ts[dds_locidx].reserved_bytes_mb)))
      SET luts_list->tspace_needed_ind = 1
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_diff_trigger(ddt_trigger_name,ddt_table_name,ddt_trigger_txt,ddt_diff_ind)
   DECLARE ddt_use_gtt_method = i2 WITH protect, noconstant(0)
   SET ddt_use_gtt_method = 0
   IF (textlen(ddt_trigger_txt) > 4000)
    SET ddt_use_gtt_method = 1
    CALL echo(concat(ddt_trigger_name," on ",ddt_table_name," contains ",build(textlen(
        ddt_trigger_txt)),
      " characters. Using GTT method."))
   ENDIF
   IF (ddt_use_gtt_method=1)
    SET dm_err->eproc = "Load trigger ddl into temp table"
    INSERT  FROM dmp_trig_comp dtc,
      (dummyt d  WITH seq = 1)
     SET dtc.trigger_text = ddt_trigger_txt
     PLAN (d)
      JOIN (dtc)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   SET ddt_diff_ind = 0
   SET dm_err->eproc = "Compare trigger"
   SELECT
    IF (ddt_use_gtt_method=1)
     qry_dds_diff_ind = dld_compare_trigger("V500",ddt_trigger_name,null,ddt_use_gtt_method)
    ELSE
     qry_dds_diff_ind = dld_compare_trigger("V500",ddt_trigger_name,ddt_trigger_txt,
      ddt_use_gtt_method)
    ENDIF
    INTO "nl:"
    FROM dual
    DETAIL
     IF (qry_dds_diff_ind=1)
      ddt_diff_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (ddt_use_gtt_method=1)
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_load_original_trigger_ddl(null)
   DECLARE dgod_original_ddl_str = vc WITH protect, noconstant("")
   DECLARE dgod_ddl_stmt = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Clear out GTT in prep for original DDL gather"
   DELETE  FROM shared_list_gttd
    WHERE (source_entity_id=- (722))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load list of original LUTS triggers"
   INSERT  FROM shared_list_gttd s,
     (dummyt d  WITH seq = value(luts_list->table_cnt))
    SET s.source_entity_id = - (722), s.source_entity_txt = luts_list->qual[d.seq].trigger_name, s
     .source_entity_nbr = d.seq
    PLAN (d
     WHERE (luts_list->qual[d.seq].create_trigger_ind=1)
      AND (luts_list->qual[d.seq].new_trigger_ind=0))
     JOIN (s)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   INSERT  FROM shared_list_gttd s,
     (dummyt d  WITH seq = value(luts_list->table_cnt))
    SET s.source_entity_id = - (722), s.source_entity_txt = luts_list->qual[d.seq].del_trigger_name,
     s.source_entity_nbr = d.seq
    PLAN (d
     WHERE (luts_list->qual[d.seq].create_del_trigger_ind=1)
      AND (luts_list->qual[d.seq].new_del_trigger_ind=0))
     JOIN (s)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dgod_ddl_stmt = concat("dbms_metadata.get_ddl('TRIGGER',t.trigger_name,t.owner)")
   SET dm_err->eproc = "Load original DDL for triggers"
   SELECT INTO "nl:"
    FROM (
     (
     (SELECT
      qry_dgod_ddl_str = sqlpassthru(value(dgod_ddl_stmt)), t.trigger_name, array_lookup = s
      .source_entity_nbr
      FROM dba_triggers t,
       shared_list_gttd s
      WHERE t.trigger_name="TRG*LUTS"
       AND t.owner="V500"
       AND t.trigger_name=s.source_entity_txt
       AND (s.source_entity_id=- (722))
      WITH sqltype("C32000","C100","I4")))
     d)
    DETAIL
     IF (trim(d.trigger_name)="TRG_DEL_*LUTS")
      luts_list->qual[d.array_lookup].original_del_trigger_ddl = substring(1,(findstring(
        "ALTER TRIGGER ",d.qry_dgod_ddl_str) - 1),d.qry_dgod_ddl_str), luts_list->qual[d.array_lookup
      ].original_del_trigger_ddl = replace(luts_list->qual[d.array_lookup].original_del_trigger_ddl,
       " EDITIONABLE "," ")
     ELSEIF (trim(d.trigger_name)="TRG*LUTS")
      luts_list->qual[d.array_lookup].original_trigger_ddl = substring(1,(findstring("ALTER TRIGGER ",
        d.qry_dgod_ddl_str) - 1),d.qry_dgod_ddl_str), luts_list->qual[d.array_lookup].
      original_trigger_ddl = replace(luts_list->qual[d.array_lookup].original_trigger_ddl,
       " EDITIONABLE "," ")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   ROLLBACK
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_gen_compound_trigger(dgct_idx,dgct_ddl_txt)
   DECLARE dgct_str = vc WITH protect, noconstant("")
   DECLARE dgct_deltrk_idx = i4 WITH protect, noconstant(0)
   SET dgct_deltrk_idx = luts_list->qual[dgct_idx].delete_tracking_ldt_idx
   SET dgct_str = concat("create or replace trigger ",luts_list->qual[dgct_idx].trigger_name)
   SET dgct_str = concat(dgct_str," for insert or update on ")
   SET dgct_str = concat(dgct_str," ",luts_list->qual[dgct_idx].table_name,char(10),
    " compound trigger ",
    char(10))
   IF ((luts_list->qual[dgct_idx].table_is_scn=1))
    SET dgct_str = concat(dgct_str,
     "  cur_txn_id varchar2(200) := dbms_transaction.local_transaction_id;",char(10),
     "  txn_context_name varchar2(200) := '",luts_list->qual[dgct_idx].table_suffix,
     "TXN_ID';",char(10))
   ENDIF
   IF (dgct_deltrk_idx > 0
    AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
    SET dgct_str = concat(dgct_str," write_txn_ind number := 0;",char(10))
   ENDIF
   SET dgct_str = concat(dgct_str,
    "  fire_luts_trig varchar2(10) := NVL(SYS_CONTEXT('CERNER','FIRE_LUTS_TRG'),'DM2NULLVAL');",char(
     10),"  curr_del_ind number := 0;",char(10),
    "  context_num number := to_number(nvl(sys_context('CERNER','MILLPURGE_APPL_NBR'),'0'));  ",char(
     10))
   IF ((luts_list->use_txn_table_synonym_ind=1))
    SET dgct_str = concat(dgct_str,"  curr_inst_id number := sys_context('userenv','instance'); ",
     char(10))
   ENDIF
   SET dgct_str = concat(dgct_str,"  before each row is",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgct_idx].txn_info_char)," ) then",char(
     10))
   IF ((luts_list->qual[dgct_idx].table_is_luts > 0))
    SET dgct_str = concat(dgct_str,"        :new.last_utc_ts  := sys_extract_utc(systimestamp);",char
     (10))
    IF ((luts_list->qual[dgct_idx].use_inst_id_ind=1))
     IF ((luts_list->use_txn_table_synonym_ind=1))
      SET dgct_str = concat(dgct_str,"          :NEW.INST_ID := curr_inst_id;",char(10))
     ELSE
      SET dgct_str = concat(dgct_str,"          :NEW.INST_ID := sys_context('userenv','instance');",
       char(10))
     ENDIF
    ENDIF
   ENDIF
   IF ((luts_list->qual[dgct_idx].table_is_scn > 0))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"        if (",char(10))
     SET dgct_str = concat(dgct_str,trim(replace(luts_dyn_trig->tbl[dgct_deltrk_idx].
        txn_log_condition,"<STATE>","NEW")),"        ) or (",char(10))
     SET dgct_str = concat(dgct_str,trim(replace(luts_dyn_trig->tbl[dgct_deltrk_idx].
        txn_log_condition,"<STATE>","OLD")),")",char(10))
     SET dgct_str = concat(dgct_str,"        THEN ",char(10))
     SET dgct_str = concat(dgct_str,"          write_txn_ind := 1;",char(10))
    ENDIF
    SET dgct_str = concat(dgct_str,"          :new.txn_id_text := cur_txn_id;",char(10))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"        end if;",char(10))
    ENDIF
   ENDIF
   SET dgct_str = concat(dgct_str,"    end if;",char(10),"  end before each row;",char(10))
   SET dgct_str = concat(dgct_str,"  after statement is ",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgct_idx].txn_info_char)," ) then",char(
     10))
   IF ((luts_list->qual[dgct_idx].table_is_scn > 0))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"      if (write_txn_ind = 1) then",char(10))
    ENDIF
    SET dgct_str = concat(dgct_str,
     "        if (sys_context('CERNER',txn_context_name) != cur_txn_id or sys_context('CERNER', ",
     "txn_context_name) is null)",char(10),"        then",
     char(10))
    IF ((luts_list->use_txn_table_synonym_ind=1))
     SET dgct_str = concat(dgct_str,
      "          insert into txn_staging_table(owner_name,table_name,txn_id_text,del_ind,appl_context_nbr,inst_id)",
      "values('V500','",luts_list->qual[dgct_idx].table_name,
      "',cur_txn_id,curr_del_ind,context_num,curr_inst_id);",
      char(10))
    ELSE
     SET dgct_str = concat(dgct_str,
      "          insert into dm_txn_tracking(owner_name,table_name,txn_id_text,row_scn,del_ind,appl_context_nbr)",
      "values('V500','",luts_list->qual[dgct_idx].table_name,
      "',cur_txn_id,0,curr_del_ind,context_num);",
      char(10))
    ENDIF
    SET dgct_str = concat(dgct_str,"          dm2_context_control(txn_context_name,cur_txn_id);",char
     (10),"        end if;",char(10))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"      end if;",char(10))
    ENDIF
   ENDIF
   SET dgct_str = concat(dgct_str,"    end if;",char(10),"  end after statement;",char(10),
    "end ",luts_list->qual[dgct_idx].trigger_name,";")
   SET dgct_ddl_txt = dgct_str
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_gen_del_compound_trigger(dgdct_idx,dgdct_ddl_txt)
   DECLARE dgdct_str = vc WITH protect, noconstant("")
   DECLARE dgdct_deltrk_idx = i4 WITH protect, noconstant(0)
   SET dgdct_deltrk_idx = luts_list->qual[dgdct_idx].delete_tracking_ldt_idx
   SET dgdct_str = concat("create or replace trigger ",luts_list->qual[dgdct_idx].del_trigger_name)
   SET dgdct_str = concat(dgdct_str," for delete on ")
   SET dgdct_str = concat(dgdct_str," ",luts_list->qual[dgdct_idx].table_name,char(10),
    " compound trigger ",
    char(10))
   IF ((luts_list->qual[dgdct_idx].table_is_scn=1))
    SET dgdct_str = concat(dgdct_str,
     "  cur_txn_id varchar2(200) := dbms_transaction.local_transaction_id;",char(10),
     "  txn_del_context_name varchar2(200) := '",luts_list->qual[dgdct_idx].table_suffix,
     "TXN_ID_D';",char(10))
    IF ((luts_list->use_txn_table_synonym_ind=1))
     SET dgdct_str = concat(dgdct_str,"  curr_inst_id number := sys_context('userenv','instance'); ",
      char(10))
    ENDIF
   ENDIF
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>")
    AND (luts_list->qual[dgdct_idx].table_is_scn=1))
    SET dgdct_str = concat(dgdct_str," write_txn_ind number := 0;",char(10))
   ENDIF
   SET dgdct_str = concat(dgdct_str,
    "  fire_luts_trig varchar2(10) := NVL(SYS_CONTEXT('CERNER','FIRE_LUTS_TRG'),'DM2NULLVAL');",char(
     10),"  curr_del_ind number := 1;",char(10),
    "  context_num number := to_number(nvl(sys_context('CERNER','MILLPURGE_APPL_NBR'),'0'));  ",char(
     10))
   SET dgdct_str = concat(dgdct_str,"  del_record_threshold number := 1000;",char(10),
    "   type del_record is record",char(10),
    "   (",char(10),"      tn_txt   varchar2(40)",char(10),"     ,pen_txt  varchar2(40)",
    char(10),"     ,pei_txt  number",char(10),"     ,tpk_txt  number",char(10),
    "     ,data_txt varchar2(4000)",char(10),"   );",char(10),
    "   type del_record_list is table of del_record index by binary_integer;",
    char(10),"   del_rows del_record_list;",char(10),"   del_cnt number := 0;",char(10),
    "   procedure write_deletes",char(10),"   is",char(10),
    "     write_cnt constant simple_integer := del_rows.count();",
    char(10),"     write_ndx simple_integer := 0;",char(10),"   begin",char(10),
    "     forall write_ndx in 1..write_cnt",char(10),"       insert into dm_delete_tracking",
    "       (dm_delete_tracking_id,table_name,parent_entity_name,parent_entity_id,table_pk_value,data_text,last_utc_ts,",
    "        updt_id,updt_dt_tm,updt_applctx,updt_cnt,purge_appl_nbr",
    evaluate(luts_list->qual[dgdct_idx].table_is_scn,1,",txn_id_text)",")"),char(10),
    "           values",char(10),"       (dm_delete_tracking_seq.nextval,'",
    luts_list->qual[dgdct_idx].table_name,"',del_rows(write_ndx).pen_txt,",
    "        del_rows(write_ndx).pei_txt,del_rows(write_ndx).tpk_txt,del_rows(write_ndx).data_txt,",
    "       sys_extract_utc(systimestamp),0,sysdate,0,0,context_num",evaluate(luts_list->qual[
     dgdct_idx].table_is_scn,1,",cur_txn_id);",");"),
    char(10),"     del_rows.delete();",char(10),"     del_cnt := 0;",char(10),
    "   end write_deletes;",char(10))
   SET dgdct_str = concat(dgdct_str,"  before each row is",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgdct_idx].txn_info_char)," ) then",char(
     10))
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
    SET dgdct_str = concat(dgdct_str,"        if ",char(10))
    SET dgdct_str = concat(dgdct_str,replace(luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition,
      "<STATE>","OLD"),char(10))
    SET dgdct_str = concat(dgdct_str,"        THEN ",char(10))
    IF ((luts_list->qual[dgdct_idx].table_is_scn > 0))
     SET dgdct_str = concat(dgdct_str,"          write_txn_ind := 1;",char(10))
    ENDIF
   ENDIF
   SET dgdct_str = concat(dgdct_str,"          del_cnt := del_cnt + 1;",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).tn_txt := ",evaluate(luts_dyn_trig->
     tbl[dgdct_deltrk_idx].tn_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].tn_txt),
    ";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).pen_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].pen_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     pen_txt),";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).pei_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].pei_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     pei_txt),";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).tpk_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].tpk_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     tpk_txt),";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).data_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].data_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     data_txt),";",char(10))
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].dup_delrow_var_values != "<DM2NULLVAL>"))
    SET dgdct_str = concat(dgdct_str,"          del_cnt := del_cnt + 1;",char(10))
    SET dgdct_str = concat(dgdct_str,"          ",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     dup_delrow_var_values,char(10))
   ENDIF
   SET dgdct_str = concat(dgdct_str,"          if del_cnt >= del_record_threshold then",char(10),
    "            write_deletes();",char(10),
    "          end if;",char(10))
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
    SET dgdct_str = concat(dgdct_str,"        end if;",char(10))
   ENDIF
   SET dgdct_str = concat(dgdct_str,"    end if;",char(10),"  end before each row;",char(10))
   SET dgdct_str = concat(dgdct_str,"  after statement is ",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgdct_idx].txn_info_char)," ) then",char(
     10))
   SET dgdct_str = concat(dgdct_str,"        if del_cnt > 0 then",char(10),
    "          write_deletes();",char(10),
    "        end if;",char(10))
   IF ((luts_list->qual[dgdct_idx].table_is_scn > 0))
    IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
     SET dgdct_str = concat(dgdct_str,"      if (write_txn_ind = 1) then",char(10))
    ENDIF
    SET dgdct_str = concat(dgdct_str,
     "        if (sys_context('CERNER',txn_del_context_name) != cur_txn_id or sys_context('CERNER', ",
     "txn_del_context_name) is null)",char(10),"        then",
     char(10))
    IF ((luts_list->use_txn_table_synonym_ind=1))
     SET dgdct_str = concat(dgdct_str,
      "          insert into txn_staging_table(owner_name,table_name,txn_id_text,del_ind,appl_context_nbr,inst_id)",
      "values('V500','",luts_list->qual[dgdct_idx].table_name,
      "',cur_txn_id,curr_del_ind,context_num,curr_inst_id);",
      char(10))
    ELSE
     SET dgdct_str = concat(dgdct_str,
      "          insert into dm_txn_tracking(owner_name,table_name,txn_id_text,row_scn,del_ind,appl_context_nbr)",
      "values('V500','",luts_list->qual[dgdct_idx].table_name,
      "',cur_txn_id,0,curr_del_ind,context_num);",
      char(10))
    ENDIF
    SET dgdct_str = concat(dgdct_str,
     "          dm2_context_control(txn_del_context_name,cur_txn_id);",char(10),"        end if;",
     char(10))
    IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
     SET dgdct_str = concat(dgdct_str,"      end if;",char(10))
    ENDIF
   ENDIF
   SET dgdct_str = concat(dgdct_str,"    end if;",char(10),"  end after statement;",char(10),
    "end ",luts_list->qual[dgdct_idx].del_trigger_name,";")
   SET dgdct_ddl_txt = dgdct_str
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_gen_lutsonly_trigger(dglt_idx,dglt_ddl_txt)
   DECLARE dglt_str = vc WITH protect, noconstant("")
   SET dglt_str = concat("create or replace trigger ",luts_list->qual[dglt_idx].trigger_name)
   SET dglt_str = concat(dglt_str," before insert or update on ")
   SET dglt_str = concat(dglt_str," ",luts_list->qual[dglt_idx].table_name,char(10)," for each row ",
    char(10)," when (NVL(SYS_CONTEXT('CERNER','FIRE_LUTS_TRG'),'DM2NULLVAL')  != 'NO') ",char(10))
   SET dglt_str = concat(dglt_str,"begin ",char(10))
   SET dglt_str = concat(dglt_str,concat("  :NEW.LAST_UTC_TS := SYS_EXTRACT_UTC(SYSTIMESTAMP);",char(
      10))," ")
   IF ((luts_list->qual[dglt_idx].use_inst_id_ind=1))
    SET dglt_str = concat(dglt_str,char(10),"  :NEW.INST_ID := sys_context('userenv','instance');",
     char(10))
   ENDIF
   SET dglt_str = concat(dglt_str,"exception",char(10),"when others then",char(10),
    "  null;",char(10),"end;",char(10))
   SET dglt_ddl_txt = dglt_str
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
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
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
 DECLARE dctx_set_context(dsc_i_attr_name=vc,dsc_i_value=vc) = i2
 DECLARE dctx_restore_prev_contexts(null) = i2
 IF ((validate(dm2_prev_ctxt->attr_cnt,- (1))=- (1))
  AND (validate(dm2_prev_ctxt->attr_cnt,- (2))=- (2)))
  RECORD dm2_prev_ctxt(
    1 attr_cnt = i4
    1 qual[*]
      2 attr_name = vc
      2 attr_value = vc
  )
  SET dm2_prev_ctxt->attr_cnt = 0
 ENDIF
 SUBROUTINE dctx_set_context(dsc_i_attr_name,dsc_i_value)
   DECLARE dsc_attrib_idx = i4 WITH protect, noconstant(0)
   DECLARE dsc_prev_err_ind = i2 WITH protect, noconstant(0)
   SET dsc_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   EXECUTE dm2_set_context value(dsc_i_attr_name), value(dsc_i_value)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    SET dsc_attrib_idx = locateval(dsc_attrib_idx,1,dm2_prev_ctxt->attr_cnt,dsc_i_attr_name,
     dm2_prev_ctxt->qual[dsc_attrib_idx].attr_name)
    IF (dsc_attrib_idx=0)
     SET dm2_prev_ctxt->attr_cnt = (dm2_prev_ctxt->attr_cnt+ 1)
     SET stat = alterlist(dm2_prev_ctxt->qual,dm2_prev_ctxt->attr_cnt)
     SET dm2_prev_ctxt->qual[dm2_prev_ctxt->attr_cnt].attr_name = dsc_i_attr_name
     SET dm2_prev_ctxt->qual[dm2_prev_ctxt->attr_cnt].attr_value = dsc_i_value
    ELSE
     SET dm2_prev_ctxt->qual[dsc_attrib_idx].attr_value = dsc_i_value
    ENDIF
    IF (dsc_prev_err_ind=1)
     SET dm_err->err_ind = 1
    ENDIF
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dctx_restore_prev_contexts(null)
   DECLARE drpc_cnt = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dm2_prev_ctxt)
   ENDIF
   FOR (drpc_cnt = 1 TO dm2_prev_ctxt->attr_cnt)
    EXECUTE dm2_set_context value(dm2_prev_ctxt->qual[drpc_cnt].attr_name), value(dm2_prev_ctxt->
     qual[drpc_cnt].attr_value)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 IF ((validate(ddr_ddl_req->ddl_cnt,- (1))=- (1))
  AND (validate(ddr_ddl_req->ddl_cnt,- (2))=- (2)))
  FREE RECORD ddr_ddl_req
  RECORD ddr_ddl_req(
    1 ddl_cnt = i4
    1 ddl_fail_cnt = i4
    1 ddl_ignore_failures = i2
    1 ddl_notify_ind = i2
    1 ddl_process = vc
    1 ddls[*]
      2 ddl_object_name = vc
      2 ddl_object_owner = vc
      2 ddl_table_owner = vc
      2 ddl_table_name = vc
      2 ddl_cmd = vc
      2 ddl_status = vc
      2 ddl_status_message = vc
      2 ddl_bypass_rsbsy_chk = i2
      2 ddl_bypass_libcache_wait_chk = i2
      2 ddl_bypass_parse_chk = i2
      2 ddl_bypass_liblock_chk = i2
  )
 ENDIF
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
 DECLARE dil_logfile_prefix = vc WITH protect, constant("dm2_iluts")
 DECLARE dil_last_message = vc WITH proctect, noconstant("First Display")
 DECLARE dil_reqs_met_ind = i2 WITH protect, noconstant(0)
 DECLARE dil_tspace_needs_answer = i2 WITH protect, noconstant(2)
 DECLARE dil_cmd = vc WITH protect, noconstant(" ")
 DECLARE dil_infile_name = vc WITH protect, noconstant(" ")
 DECLARE dil_txt = vc WITH protect, noconstant(" ")
 DECLARE dil_is_11204 = i2 WITH protect, noconstant(0)
 DECLARE dil_recompile_obj_ind = i2 WITH protect, noconstant(0)
 DECLARE dil_msg = vc WITH protect, noconstant(" ")
 DECLARE set_module(module_name=vc,action_name=vc) = null WITH sql =
 "SYS.DBMS_APPLICATION_INFO.SET_MODULE", parameter
 DECLARE set_client_info(client_info=vc) = null WITH sql =
 "SYS.DBMS_APPLICATION_INFO.SET_CLIENT_INFO", parameter
 DECLARE set_column_stats(ownname=vc,tabname=vc,colname=vc,nullcnt=f8,avgclen=i4,
  force=i4,no_invalidate=i4) = null WITH sql = "SYS.DBMS_STATS.SET_COLUMN_STATS", parameter
 DECLARE set_column_stats2(ownname=vc,tabname=vc,colname=vc,nullcnt=f8,avgclen=i4,
  distcnt=f8,density=f8,force=i4,no_invalidate=i4) = null WITH sql =
 "SYS.DBMS_STATS.SET_COLUMN_STATS", parameter
 DECLARE set_table_prefs(ownname=vc,tabname=vc,pname=vc,pvalue=vc) = null WITH sql =
 "SYS.DBMS_STATS.SET_TABLE_PREFS", parameter
 DECLARE dil_install_schema(null) = i2
 DECLARE dil_set_col_stats(null) = i2
 DECLARE dil_tspace_needs_prompt(null) = i2
 DECLARE dil_exec_command(dil_str=vc,dil_owner=vc,dil_table=vc) = i2
 DECLARE dil_rdm_validate_schema(null) = i2
 DECLARE dil_chk_trig(dct_idx=i4,dct_trig_type=vc) = i2
 IF (check_logfile(dil_logfile_prefix,".log","dm2_install_luts")=0)
  GO TO exit_program
 ENDIF
 IF (dm2_get_rdbms_version(null)=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Get instance count"
 SELECT INTO "nl:"
  qry_dscs_cnt = count(*)
  FROM gv$instance
  DETAIL
   luts_list->inst_cnt = qry_dscs_cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_INSTALL_LUTS"
   AND di.info_name="REQS_MET"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (((curqual > 0) OR ((dm2_rdbms_version->level1 >= 11))) )
  SET dil_reqs_met_ind = 1
 ENDIF
 IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
  AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
  AND (dm2_rdbms_version->level2=2)
  AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
  AND (dm2_rdbms_version->level2=2)
  AND (dm2_rdbms_version->level3=0)
  AND (dm2_rdbms_version->level4 >= 4))) )) )) )
  SET dil_is_11204 = 1
 ENDIF
 IF (dil_reqs_met_ind=0)
  SET dil_last_message = "DM2_INSTALL_LUTS not currently supported on Oracle versions prior to 11.1"
 ENDIF
 SET luts_list->txn_schema_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_INSTALL_LUTS"
   AND di.info_name IN ("RECOMPILE_DEP_OBJECTS", "TXN_ID_TEXT_SCHEMA", "PARALLEL_DEGREE")
  DETAIL
   IF (di.info_name="RECOMPILE_DEP_OBJECTS")
    dil_recompile_obj_ind = 1
   ELSEIF (di.info_name="TXN_ID_TEXT_SCHEMA")
    luts_list->txn_schema_ind = 1
   ELSEIF (di.info_name="PARALLEL_DEGREE")
    luts_list->parallel_degree = di.info_number
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (isnumeric(dm2_db_options->resource_busy_maxretry)=0)
  SET dm2_db_options->resource_busy_maxretry = "2400"
 ENDIF
 EXECUTE dm2_luts_utilpkg_setup
 IF ((dm_err->err_ind > 0))
  GO TO exit_program
 ENDIF
 IF ((luts_list->install_by_rdm_ind=1))
  IF (dn_get_notify_settings(null)=0)
   GO TO exit_program
  ENDIF
  IF ((dnotify->status=1))
   IF ((dnotify->suppression_flag=1))
    CALL echo("DDL retry alerts are suppressed")
    SET ddr_ddl_req->ddl_notify_ind = 0
   ELSE
    SET ddr_ddl_req->ddl_notify_ind = 1
   ENDIF
   SET ddr_ddl_req->ddl_process = "DM2_INSTALL_LUTS"
   CALL echo("Notifications are Active, emails can be sent")
  ELSE
   CALL echo("Notifications are not Active, emails cannot be sent")
  ENDIF
  IF (dil_rdm_validate_schema(null)=0)
   GO TO exit_program
  ELSE
   GO TO exit_program
  ENDIF
 ENDIF
 WHILE (true)
   SET dm_err->eproc = "LAST_UTC_TS; Set Module=MAIN"
   CALL set_module("DM2_INSTALL_LUTS","MAIN")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((dm_err->debug_flag=511))
    SET message = nowindow
   ELSE
    SET message = window
    SET width = 132
   ENDIF
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL box(1,1,24,132)
   CALL text(2,2,"Install LAST_UTC_TS column schema [MAIN]")
   CALL text(2,65,concat("DATABASE INSTANCE: ",currdblink))
   CALL text(5,2,
    "This process will validate and (if needed) install a LAST_UTC_TS timestamp column, index and trigger"
    )
   CALL text(6,2,
    "for a subset of Millennium tables. All database schema changes can be performed with users active on the system."
    )
   CALL text(8,2,"*Important* ")
   CALL text(9,5,
    "When implementing this process, make sure to involve the Database Administrator to review/approve"
    )
   CALL text(10,5,
    "the database schema changes and to monitor the system during actual installation of database schema"
    )
   CALL text(12,5,
    "1. PREVIEW:  Displays all needed database schema changes (including any index tablespace needs)"
    )
   CALL text(13,5,"2. INSTALL:  Installs all needed database schema changes")
   CALL text(14,5,"3. VALIDATE: Validates all schema for the LAST_UTC_TS column")
   CALL text(17,5,"Your Selection (0 to Exit)?")
   CALL text(20,2,concat("Last Status Message: ",dil_last_message))
   CALL accept(17,38,"9;",0
    WHERE curaccept IN (0, 1, 2, 3))
   SET message = nowindow
   CASE (curaccept)
    OF 0:
     GO TO exit_program
    OF 1:
     IF (dil_reqs_met_ind=1)
      SET dm_err->eproc = "LAST_UTC_TS: Set module to PREVIEW"
      CALL set_module("DM2_INSTALL_LUTS","PREVIEW")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      EXECUTE dm2_preview_luts "*", "*", "PREVIEW"
      IF ((dm_err->err_ind > 0))
       GO TO exit_program
      ENDIF
      SET dil_last_message = "PREVIEW MODE COMPLETED"
     ENDIF
    OF 2:
     IF (dil_reqs_met_ind=1)
      SET dm_err->eproc = "LAST_UTC_TS: Set module to PREVIEW-2"
      CALL set_module("DM2_INSTALL_LUTS","PREVIEW")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      EXECUTE dm2_preview_luts "*", "*", "PREVIEW"
      IF ((dm_err->err_ind > 0))
       GO TO exit_program
      ENDIF
      IF ((((luts_list->dg_space_needed_ind=1)) OR ((luts_list->tspace_needed_ind=1))) )
       IF (dil_tspace_needs_prompt(null)=0)
        GO TO exit_program
       ENDIF
      ENDIF
      IF (dil_tspace_needs_answer=2)
       IF (dil_install_schema(null)=0)
        GO TO exit_program
       ENDIF
       SET dil_last_message = "INSTALL COMPLETED"
      ELSE
       SET dil_last_message = "INSTALL BYPASSED"
      ENDIF
     ENDIF
    OF 3:
     IF (dil_reqs_met_ind=1)
      SET dm_err->eproc = "LAST_UTC_TS: Set module to VALIDATE"
      CALL set_module("DM2_INSTALL_LUTS","VALIDATE")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      EXECUTE dm2_preview_luts "*", "*", "VALIDATE"
      IF ((dm_err->err_ind > 0))
       GO TO exit_program
      ENDIF
      SET dil_last_message = "VALIDATE COMPLETED"
     ENDIF
   ENDCASE
 ENDWHILE
 GO TO exit_program
 SUBROUTINE dil_install_schema(null)
   DECLARE dis_idx = i4 WITH protect, noconstant(0)
   DECLARE dis_cmd = vc WITH protect, noconstant(" ")
   DECLARE dis_fallout_ind = i2 WITH protect, noconstant(0)
   DECLARE dis_pause_time = i2 WITH protect, noconstant(2)
   DECLARE dis_find_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE dis_object_id = f8 WITH protect, noconstant(0.0)
   DECLARE dis_synonym_cmd = vc WITH protect, noconstant("")
   SET message = nowindow
   SET dm_err->eproc = "LAST_UTC_TS: Set module to INSTALL"
   CALL set_module("DM2_INSTALL_LUTS","INSTALL")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking gv$session for concurrent sessions of dm2_install_luts"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM gv$session gvs
    WHERE gvs.module="DM2_INSTALL_LUTS"
     AND gvs.action="INSTALL"
     AND gvs.audsid != sqlpassthru("sys_context('USERENV','SESSIONID')")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Another active session of dm2_install_luts was detected in gv$session.  Exiting..."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking for dm_info row to override pause time"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_LUTS"
     AND di.info_name="PAUSE_TIME"
    DETAIL
     dis_pause_time = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET trace = rdbdebug
   CALL dctx_set_context("TRG_LUTS_CHK","NO")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dld_load_curr_txn_table(null)=0)
    RETURN(0)
   ENDIF
   IF ((luts_list->use_txn_table_synonym_ind=1))
    SET dm_err->eproc = "Checking for existence of TXN_STAGING_TABLE synonym"
    SELECT INTO "nl:"
     FROM dba_objects o
     WHERE o.object_name="TXN_STAGING_TABLE"
      AND o.object_type="SYNONYM"
      AND o.owner="V500"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->eproc = "Creating TXN_STAGING_TABLE synonym"
     SET dis_synonym_cmd = concat("rdb create synonym TXN_STAGING_TABLE for V500.",luts_list->
      config_curr_txn_table," go")
     IF (dm2_push_cmd(dis_synonym_cmd,1)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Validating creation of TXN_STAGING_TABLE synonym"
     SELECT INTO "nl:"
      FROM dba_objects o
      WHERE o.object_name="TXN_STAGING_TABLE"
       AND o.object_type="SYNONYM"
       AND o.owner="V500"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (curqual=0)
      CALL disp_msg("TXN_STAGING_TABLE synonym could not be created",dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((luts_list->table_cnt > 0))
    SET dm_err->eproc = "LAST_UTC_TS: Setting resumable for session"
    SET dis_cmd = "rdb ALTER SESSION ENABLE RESUMABLE TIMEOUT 28800 NAME 'DM2_INSTALL_LUTS' go"
    IF (dm2_push_cmd(dis_cmd,1)=0)
     RETURN(0)
    ENDIF
    IF ((dgdt_prefs->context_lock_ind=- (1)))
     IF (ddf_get_context_pkg_data(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    FOR (dis_idx = 1 TO luts_list->table_cnt)
      IF ((((luts_list->qual[dis_idx].diff_ind=1)) OR ((luts_list->qual[dis_idx].diff_txn_ind=1))) )
       SET dm_err->eproc = concat("LAST_UTC_TS: Begin processing table ",luts_list->qual[dis_idx].
        table_name)
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      IF ((((luts_list->qual[dis_idx].add_column_ind=1)) OR ((((luts_list->qual[dis_idx].
      add_txn_column_ind=1)) OR ((luts_list->qual[dis_idx].add_instid_column_ind=1))) )) )
       SET dm_err->eproc = concat("LAST_UTC_TS: Adding columns to table ",luts_list->qual[dis_idx].
        table_name)
       CALL disp_msg("",dm_err->logfile,10)
       IF (dil_exec_command(luts_list->qual[dis_idx].add_combined_column_ddl,luts_list->qual[dis_idx]
        .table_owner,luts_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((((luts_list->qual[dis_idx].set_col_stats_ind=1)) OR ((((luts_list->qual[dis_idx].
      set_txn_col_stats_ind=1)) OR ((luts_list->qual[dis_idx].set_instid_col_stats_ind=1))) )) )
       IF ((dgdt_prefs->context_lock_ind=1))
        SET dis_object_id = 0.0
        IF (ddf_get_object_id(luts_list->qual[dis_idx].table_owner,luts_list->qual[dis_idx].
         table_name,dis_object_id)=0)
         RETURN(0)
        ENDIF
       ENDIF
       IF (dil_set_col_stats(null)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((((luts_list->qual[dis_idx].create_index_ind=1)) OR ((((luts_list->qual[dis_idx].
      create_txn_index_ind=1)) OR ((luts_list->qual[dis_idx].rename_index_ind=1))) )) )
       SET dm_err->eproc = "LAST_UTC_TS: Checking for INSTALL fallout row in DM_INFO"
       SELECT INTO "nl:"
        FROM dm_info di
        WHERE di.info_domain="DM2_INSTALL_LUTS"
         AND di.info_name="FALLOUT"
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSEIF (curqual > 0)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "dm2_install_luts exiting due to fallout row existence"
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF ((luts_list->qual[dis_idx].rename_index_ind=1))
        SET dm_err->eproc = concat("LAST_UTC_TS: Renaming index:",luts_list->qual[dis_idx].index_name
         )
        CALL disp_msg("",dm_err->logfile,10)
        CALL set_client_info(dm_err->eproc)
        IF (dil_exec_command(luts_list->qual[dis_idx].rename_index_ddl,luts_list->qual[dis_idx].
         table_owner,luts_list->qual[dis_idx].table_name)=0)
         RETURN(0)
        ENDIF
       ENDIF
       IF ((luts_list->parallel_degree > 1))
        SET dm_err->eproc = build("Setting parallel degree: ",luts_list->parallel_degree)
        SET dis_cmd = concat("rdb alter session force parallel ddl parallel ",cnvtstring(luts_list->
          parallel_degree)," go")
        IF (dm2_push_cmd(dis_cmd,1)=0)
         RETURN(0)
        ENDIF
       ENDIF
       IF ((luts_list->qual[dis_idx].create_index_ind=1))
        SET dm_err->eproc = concat("LAST_UTC_TS: Creating index:",luts_list->qual[dis_idx].index_name
         )
        CALL disp_msg("",dm_err->logfile,10)
        CALL set_client_info(dm_err->eproc)
        IF (dil_exec_command(luts_list->qual[dis_idx].create_index_ddl,luts_list->qual[dis_idx].
         table_owner,luts_list->qual[dis_idx].table_name)=0)
         RETURN(0)
        ENDIF
        IF ((luts_list->parallel_degree > 1))
         IF (dil_exec_command(concat("alter index ",luts_list->qual[dis_idx].index_name," noparallel"
           ),luts_list->qual[dis_idx].table_owner,luts_list->qual[dis_idx].table_name)=0)
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
       IF ((luts_list->qual[dis_idx].create_txn_index_ind=1))
        SET dm_err->eproc = concat("LAST_UTC_TS: Creating index:",luts_list->qual[dis_idx].
         txn_index_name)
        CALL disp_msg("",dm_err->logfile,10)
        CALL set_client_info(dm_err->eproc)
        IF (dil_exec_command(luts_list->qual[dis_idx].create_txn_index_ddl,luts_list->qual[dis_idx].
         table_owner,luts_list->qual[dis_idx].table_name)=0)
         RETURN(0)
        ENDIF
        IF ((luts_list->parallel_degree > 1))
         IF (dil_exec_command(concat("alter index ",luts_list->qual[dis_idx].txn_index_name,
           " noparallel"),luts_list->qual[dis_idx].table_owner,luts_list->qual[dis_idx].table_name)=0
         )
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
       IF ((luts_list->parallel_degree > 1))
        SET dm_err->eproc = "Setting parallel degree off"
        SET dis_cmd = "rdb alter session force parallel ddl parallel 1 go"
        IF (dm2_push_cmd(dis_cmd,1)=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
      IF (dil_is_11204=1
       AND (((luts_list->qual[dis_idx].set_index_visible_ind=1)) OR ((luts_list->qual[dis_idx].
      set_txn_index_visible_ind=1))) )
       IF ((luts_list->qual[dis_idx].set_index_visible_ind=1))
        IF (dil_exec_command(luts_list->qual[dis_idx].set_index_visible_ddl,luts_list->qual[dis_idx].
         table_owner,luts_list->qual[dis_idx].table_name)=0)
         RETURN(0)
        ENDIF
       ENDIF
       IF ((luts_list->qual[dis_idx].set_txn_index_visible_ind=1))
        IF (dil_exec_command(luts_list->qual[dis_idx].set_txn_index_visible_ddl,luts_list->qual[
         dis_idx].table_owner,luts_list->qual[dis_idx].table_name)=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
      IF ((luts_list->qual[dis_idx].create_del_trigger_ind > 0))
       SET dm_err->eproc = concat("LAST_UTC_TS: Creating Del Trigger:",luts_list->qual[dis_idx].
        del_trigger_name)
       CALL dil_exec_command(luts_list->qual[dis_idx].create_del_trigger_ddl,luts_list->qual[dis_idx]
        .table_owner,luts_list->qual[dis_idx].table_name)
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        IF (findstring("ORA-24344",dm_err->emsg) > 0)
         CALL dil_chk_trig(dis_idx,"DEL")
        ENDIF
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_list->qual[dis_idx].create_trigger_ind > 0))
       SET dm_err->eproc = concat("LAST_UTC_TS: Creating Trigger:",luts_list->qual[dis_idx].
        trigger_name)
       CALL dil_exec_command(luts_list->qual[dis_idx].create_trigger_ddl,luts_list->qual[dis_idx].
        table_owner,luts_list->qual[dis_idx].table_name)
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        IF (findstring("ORA-24344",dm_err->emsg) > 0)
         CALL dil_chk_trig(dis_idx,"LUTS")
        ENDIF
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_list->qual[dis_idx].disable_txn_trigger_ind > 0))
       SET dm_err->eproc = concat("LAST_UTC_TS: Disabling TXN Trigger on :",luts_list->qual[dis_idx].
        table_name)
       IF (dil_exec_command(luts_list->qual[dis_idx].disable_txn_trigger_ddl,luts_list->qual[dis_idx]
        .table_owner,luts_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_list->qual[dis_idx].diff_ind=1))
       SET dm_err->eproc = concat("LAST_UTC_TS: Pausing ",trim(cnvtstring(dis_pause_time)),
        " seconds to allow queries for table ",luts_list->qual[dis_idx].table_name," to reparse.")
       CALL disp_msg(" ",dm_err->logfile,0)
       CALL pause(dis_pause_time)
      ENDIF
      IF (dil_recompile_obj_ind > 0)
       IF ((luts_list->table_diff_txn_cnt=0)
        AND (luts_list->table_diff_cnt=0))
        SET dm_err->eproc = concat(
         "LAST_UTC_TS:  Skipping compile of objects since no schema changes")
        IF ((dm_err->debug_flag > 0))
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ELSE
        IF ((((luts_list->qual[dis_idx].diff_ind=1)) OR ((luts_list->qual[dis_idx].diff_txn_ind=1)))
        )
         SET dm_err->eproc = concat("LAST_UTC_TS:  Compiling invalid dependent objects on: ",
          luts_list->qual[dis_idx].table_name)
         CALL disp_msg("",dm_err->logfile,0)
         EXECUTE dm2_compile_objects "TABLE", luts_list->qual[dis_idx].table_name
         IF ((dm_err->err_ind=1))
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((luts_drop_list->table_cnt > 0))
    FOR (dis_idx = 1 TO luts_drop_list->table_cnt)
      IF ((luts_drop_list->qual[dis_idx].drop_trigger_ind=1))
       SET dm_err->eproc = concat("Drop LUTS trigger for (",luts_drop_list->qual[dis_idx].table_name,
        ").")
       CALL disp_msg(" ",dm_err->logfile,10)
       IF (dil_exec_command(luts_drop_list->qual[dis_idx].drop_trigger_ddl,luts_drop_list->qual[
        dis_idx].table_owner,luts_drop_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_drop_list->qual[dis_idx].drop_del_trigger_ind=1))
       SET dm_err->eproc = concat("Drop DEL trigger for (",luts_drop_list->qual[dis_idx].table_name,
        ").")
       CALL disp_msg(" ",dm_err->logfile,10)
       IF (dil_exec_command(luts_drop_list->qual[dis_idx].drop_del_trigger_ddl,luts_drop_list->qual[
        dis_idx].table_owner,luts_drop_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_drop_list->qual[dis_idx].drop_txn_trigger_ind=1))
       SET dm_err->eproc = concat("Drop SCN trigger for (",luts_drop_list->qual[dis_idx].table_name,
        ").")
       CALL disp_msg(" ",dm_err->logfile,10)
       IF (dil_exec_command(luts_drop_list->qual[dis_idx].drop_txn_trigger_ddl,luts_drop_list->qual[
        dis_idx].table_owner,luts_drop_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_drop_list->qual[dis_idx].drop_txn_pkg_ind=1))
       SET dm_err->eproc = concat("Check if ",luts_drop_list->qual[dis_idx].drop_txn_pkg_name,
        " has dependencies")
       SELECT INTO "nl:"
        FROM dba_dependencies d
        WHERE (d.referenced_name=luts_drop_list->qual[dis_idx].drop_txn_pkg_name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual > 0)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Cannot drop ",luts_drop_list->qual[dis_idx].drop_txn_pkg_name,
         ". Still has dependencies")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Drop SCN package for (",luts_drop_list->qual[dis_idx].table_name,
        ").")
       CALL disp_msg(" ",dm_err->logfile,10)
       IF (dil_exec_command(luts_drop_list->qual[dis_idx].drop_txn_pkg_ddl,luts_drop_list->qual[
        dis_idx].table_owner,luts_drop_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_drop_list->qual[dis_idx].drop_index_ind=1))
       SET dm_err->eproc = concat("Drop LUTS index for (",luts_drop_list->qual[dis_idx].table_name,
        ").")
       CALL disp_msg(" ",dm_err->logfile,10)
       IF (dil_exec_command(luts_drop_list->qual[dis_idx].drop_index_ddl,luts_drop_list->qual[dis_idx
        ].table_owner,luts_drop_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF ((luts_drop_list->qual[dis_idx].drop_txn_index_ind=1))
       SET dm_err->eproc = concat("Drop SCN index for (",luts_drop_list->qual[dis_idx].table_name,
        ").")
       CALL disp_msg(" ",dm_err->logfile,10)
       IF (dil_exec_command(luts_drop_list->qual[dis_idx].drop_txn_index_ddl,luts_drop_list->qual[
        dis_idx].table_owner,luts_drop_list->qual[dis_idx].table_name)=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET dm_err->eproc = concat("LAST_UTC_TS: Pausing ",trim(cnvtstring(dis_pause_time)),
       " seconds to allow queries for table ",luts_drop_list->qual[dis_idx].table_name," to reparse."
       )
      CALL disp_msg(" ",dm_err->logfile,0)
      CALL pause(dis_pause_time)
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dil_chk_trig(dct_idx,dct_trig_type)
   SET dm_err->eproc = "Executing dil_chk_trig to replace invalid trigger "
   DECLARE dct_trig_status = vc WITH protect, noconstant("")
   DECLARE dct_trig_name = vc WITH protect, noconstant("")
   DECLARE dct_prior_debug_flag = i2 WITH protect, noconstant(0)
   SET dct_prior_debug_flag = dm_err->debug_flag
   SET dm_err->debug_flag = 1
   SELECT INTO "nl:"
    d.status
    FROM dba_objects d
    WHERE d.owner="V500"
     AND object_name=evaluate(dct_trig_type,"LUTS",luts_list->qual[dct_idx].trigger_name,luts_list->
     qual[dct_idx].del_trigger_name)
    DETAIL
     dct_trig_status = d.status, dct_trig_name = d.object_name
    WITH nocounter
   ;end select
   IF (dct_trig_status != "VALID")
    CALL dm2_push_cmd(concat("rdb asis(^alter trigger ",luts_list->qual[dct_idx].table_owner,".",
      dct_trig_name," compile ^) go"),1)
   ENDIF
   SELECT INTO "nl:"
    d.status
    FROM dba_objects d
    WHERE (d.owner=luts_list->qual[dct_idx].table_owner)
     AND object_name=evaluate(dct_trig_type,"LUTS",luts_list->qual[dct_idx].trigger_name,luts_list->
     qual[dct_idx].del_trigger_name)
    DETAIL
     dct_trig_status = d.status, dct_trig_name = d.object_name
    WITH nocounter
   ;end select
   IF (dct_trig_status != "VALID")
    IF ((((luts_list->qual[dis_idx].new_trigger_ind=0)
     AND dct_trig_type="LUTS") OR ((luts_list->qual[dis_idx].new_del_trigger_ind=0)
     AND dct_trig_type="DEL")) )
     CALL echo("Replacing invalid trigger with original DDL")
     CALL echo(evaluate(dct_trig_type,"LUTS",luts_list->qual[dct_idx].original_trigger_ddl,luts_list
       ->qual[dct_idx].original_del_trigger_ddl))
     CALL dm2_push_cmd(concat("rdb asis(^",evaluate(dct_trig_type,"LUTS",luts_list->qual[dct_idx].
        original_trigger_ddl,luts_list->qual[dct_idx].original_del_trigger_ddl),"^) go"),1)
     SELECT INTO "nl:"
      d.status
      FROM dba_objects d
      WHERE d.owner="V500"
       AND object_name=evaluate(dct_trig_type,"LUTS",luts_list->qual[dct_idx].trigger_name,luts_list
       ->qual[dct_idx].del_trigger_name)
      DETAIL
       dct_trig_status = d.status, dct_trig_name = d.object_name
      WITH nocounter
     ;end select
     IF (dct_trig_status != "VALID")
      SET dm_err->emsg = concat("Dropping trigger ",luts_list->qual[dct_idx].table_owner,".",
       dct_trig_name," since created as INVALID and unable to replace with original DDL")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL dm2_push_cmd(concat("rdb asis(^drop trigger ",luts_list->qual[dct_idx].table_owner,".",
        dct_trig_name," ^) go"),1)
     ENDIF
    ELSE
     SET dm_err->emsg = concat("Dropping trigger ",luts_list->qual[dct_idx].table_owner,".",
      dct_trig_name," since created as INVALID")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL dm2_push_cmd(concat("rdb asis(^drop trigger ",luts_list->qual[dct_idx].table_owner,".",
       dct_trig_name," ^) go"),1)
    ENDIF
   ENDIF
   SET dm_err->debug_flag = dct_prior_debug_flag
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dil_tspace_needs_prompt(null)
   IF ((dm_err->debug_flag=511))
    SET message = nowindow
   ELSE
    SET message = window
    SET width = 132
   ENDIF
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL box(1,1,24,132)
   CALL text(2,2,"Install LAST_UTC_TS column schema [TSPACE CONFIRM]")
   CALL text(5,2,
    "WARNING! The process detected that there were still tablespace needs for new indexes")
   CALL text(7,2,
    "Consuming all free space in an Oracle table space and/or DiskGroup can cause errors to Millennium Applications, "
    )
   CALL text(8,2,
    "so it is critical to ensure that adequate free table space exists to build the new indexes.")
   CALL text(10,2,
    "Please confirm whether to proceed with the Install or go back to PREVIEW and resolve the table space needs"
    )
   CALL text(12,5,"1. PREVIEW")
   CALL text(13,5,"2. INSTALL ANYWAY")
   CALL text(17,5,"Your Selection (0 to Exit)?")
   CALL accept(17,38,"9;",9
    WHERE curaccept IN (0, 1, 2))
   SET dil_tspace_needs_answer = curaccept
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dil_set_col_stats(null)
   DECLARE dscs_lock_available_ind = i2 WITH protect, noconstant(0)
   DECLARE dscs_lock_obtained_ind = i2 WITH protect, noconstant(0)
   DECLARE dscs_skip_ind = i2 WITH protect, noconstant(0)
   DECLARE dscs_pub_val = vc WITH protect, noconstant("TRUE")
   DECLARE dscs_num_distinct = f8 WITH protect, noconstant(0)
   DECLARE dscs_null_cnt = f8 WITH protect, noconstant(0)
   DECLARE dscs_density = f8 WITH protect, noconstant(0)
   IF ((((luts_list->set_col_stats_cnt > 0)) OR ((((luts_list->set_txn_col_stats_cnt > 0)) OR ((
   luts_list->set_instid_col_stats_cnt > 0))) )) )
    SET dm_err->eproc = "LAST_UTC_TS:  Setting column statistics for tables"
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->eproc = concat("LAST_UTC_TS: Get stats existence for table (",luts_list->qual[dis_idx
     ].table_name,")")
    IF ((((luts_list->qual[dis_idx].set_col_stats_ind=1)) OR ((((luts_list->qual[dis_idx].
    set_txn_col_stats_ind=1)) OR ((luts_list->qual[dis_idx].set_instid_col_stats_ind=1))) )) )
     SELECT INTO "nl:"
      FROM user_tab_col_statistics utcs
      WHERE (utcs.table_name=luts_list->qual[dis_idx].table_name)
       AND utcs.column_name IN ("LAST_UTC_TS", "INST_ID", "TXN_ID_TEXT")
      DETAIL
       IF (utcs.column_name="LAST_UTC_TS")
        luts_list->qual[dis_idx].set_col_stats_ind = 0
       ELSEIF (utcs.column_name="TXN_ID_TEXT")
        luts_list->qual[dis_idx].set_txn_col_stats_ind = 0
       ELSEIF (utcs.column_name="INST_ID")
        luts_list->qual[dis_idx].set_instid_col_stats_ind = 0
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((((luts_list->qual[dis_idx].set_col_stats_ind=1)) OR ((((luts_list->qual[dis_idx].
     set_txn_col_stats_ind=1)) OR ((luts_list->qual[dis_idx].set_instid_col_stats_ind=1))) )) )
      SET dscs_skip_ind = 0
      SET dscs_lock_available_ind = 0
      SET dscs_lock_obtained_ind = 0
      SET dm_err->eproc = concat("LAST_UTC_TS: Check if long parse exists on table (",luts_list->
       qual[dis_idx].table_name,")")
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->eproc = concat("LAST_UTC_TS: Attempt to get a statistics lock for table (",
       luts_list->qual[dis_idx].table_name,")")
      CALL disp_msg(" ",dm_err->logfile,0)
      IF (ddf_context_lock_maint("CHECK","STAT",1,luts_list->qual[dis_idx].table_owner,luts_list->
       qual[dis_idx].table_name,
       dis_object_id,dscs_lock_available_ind)=0)
       RETURN(0)
      ENDIF
      IF (dscs_lock_available_ind=1)
       IF (ddf_context_lock_maint("GET","STAT",2,luts_list->qual[dis_idx].table_owner,luts_list->
        qual[dis_idx].table_name,
        dis_object_id,dscs_lock_obtained_ind)=0)
        RETURN(0)
       ENDIF
      ENDIF
      IF (dscs_lock_obtained_ind=0)
       SET dm_err->eproc = concat("Unable to obtain adjust stats lock. Skipping table (",luts_list->
        qual[dis_idx].table_name,")")
       CALL disp_msg(" ",dm_err->logfile,0)
      ELSE
       SET dm_err->eproc = concat("LAST_UTC_TS: Get publish preference for table (",luts_list->qual[
        dis_idx].table_name,")")
       SET dadt_pub_val = "TRUE"
       SELECT INTO "nl:"
        FROM dba_tab_stat_prefs d
        WHERE (d.owner=luts_list->qual[dis_idx].table_owner)
         AND (d.table_name=luts_list->qual[dis_idx].table_name)
         AND d.preference_name="PUBLISH"
        DETAIL
         dscs_pub_val = trim(cnvtupper(d.preference_value))
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (dscs_pub_val="FALSE")
        SET dm_err->eproc = concat(
         "LAST_UTC_TS: Calling DBMS_STATS.SET_TABLE_PREFS (TRUE) for table (",luts_list->qual[dis_idx
         ].table_name,")")
        CALL disp_msg(" ",dm_err->logfile,0)
        CALL set_table_prefs(luts_list->qual[dis_idx].table_owner,concat('"',luts_list->qual[dis_idx]
          .table_name,'"'),"PUBLISH","TRUE")
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       IF ((luts_list->qual[dis_idx].set_col_stats_ind=1))
        SET dm_err->eproc = concat("LAST_UTC_TS: Calling DBMS_STATS.SET_COLUMN_STATS for table (",
         luts_list->qual[dis_idx].table_name,")")
        CALL disp_msg(" ",dm_err->logfile,0)
        CALL set_column_stats(luts_list->qual[dis_idx].table_owner,luts_list->qual[dis_idx].
         table_name,"LAST_UTC_TS",luts_list->qual[dis_idx].num_rows,1,
         cnvtbool(true),cnvtbool(false))
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       IF ((luts_list->qual[dis_idx].set_instid_col_stats_ind=1))
        SET dm_err->eproc = concat("LAST_UTC_TS: Calling TXN DBMS_STATS.SET_COLUMN_STATS for table (",
         luts_list->qual[dis_idx].table_name,")")
        CALL disp_msg(" ",dm_err->logfile,0)
        SET dscs_num_distinct = luts_list->inst_cnt
        SET dscs_null_cnt = (luts_list->qual[dis_idx].num_rows * 0.90)
        SET dscs_density = (1/ dscs_num_distinct)
        CALL set_column_stats2(luts_list->qual[dis_idx].table_owner,luts_list->qual[dis_idx].
         table_name,"INST_ID",dscs_null_cnt,1,
         dscs_num_distinct,dscs_density,cnvtbool(true),cnvtbool(false))
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       IF ((luts_list->qual[dis_idx].set_txn_col_stats_ind=1))
        SET dm_err->eproc = concat("LAST_UTC_TS: Calling TXN DBMS_STATS.SET_COLUMN_STATS for table (",
         luts_list->qual[dis_idx].table_name,")")
        CALL disp_msg(" ",dm_err->logfile,0)
        SET dscs_num_distinct = dm2ceil((luts_list->qual[dis_idx].num_rows * 0.1))
        SET dscs_null_cnt = (luts_list->qual[dis_idx].num_rows - dscs_num_distinct)
        SET dscs_density = (1/ dscs_num_distinct)
        CALL set_column_stats2(luts_list->qual[dis_idx].table_owner,luts_list->qual[dis_idx].
         table_name,"TXN_ID_TEXT",dscs_null_cnt,1,
         dscs_num_distinct,dscs_density,cnvtbool(true),cnvtbool(false))
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       IF (dscs_pub_val="FALSE")
        SET dm_err->eproc = concat(
         "LAST_UTC_TS: Calling DBMS_STATS.SET_TABLE_PREFS TO (FALSE) for table (",luts_list->qual[
         dis_idx].table_name,")")
        CALL disp_msg(" ",dm_err->logfile,0)
        CALL set_table_prefs(luts_list->qual[dis_idx].table_owner,concat('"',luts_list->qual[dis_idx]
          .table_name,'"'),"PUBLISH","FALSE")
        IF (check_error(dm_err->eproc) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       IF (ddf_context_lock_maint("RELEASE","STAT",2,luts_list->qual[dis_idx].table_owner,luts_list->
        qual[dis_idx].table_name,
        dis_object_id,dscs_lock_obtained_ind)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dil_exec_command(dil_str,dil_owner,dil_table)
   DECLARE dec_str = vc WITH protect, noconstant("")
   IF (findstring("DM2_FINISH_INDEX",dil_str)=0)
    SET dec_str = concat("rdb asis(^",dil_str,"^) go")
   ELSE
    SET dec_str = dil_str
   ENDIF
   SET ddr_ddl_req->ddl_cnt = 0
   SET ddr_ddl_req->ddl_fail_cnt = 0
   SET stat = alterlist(ddr_ddl_req->ddls,0)
   SET ddr_ddl_req->ddl_ignore_failures = 0
   SET ddr_ddl_req->ddl_cnt = (ddr_ddl_req->ddl_cnt+ 1)
   SET stat = alterlist(ddr_ddl_req->ddls,ddr_ddl_req->ddl_cnt)
   SET ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_table_owner = dil_owner
   SET ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_table_name = dil_table
   SET ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_cmd = dec_str
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddr_ddl_req)
   ENDIF
   SET dm_err->eproc = "Executing dm2_run_ddl to execute the DDL(s) "
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_run_ddl
   IF ((ddr_ddl_req->ddl_fail_cnt > 0))
    SET dm_err->eproc = "Executing dm2_run_ddl to execute the DDL(s) "
    SET dm_err->err_ind = 1
    SET dm_err->emsg = ddr_ddl_req->ddls[ddr_ddl_req->ddl_cnt].ddl_status_message
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dil_rdm_validate_schema(null)
   SET dm_err->eproc = "LAST_UTC_TS: Install executed by readme"
   CALL disp_msg("",dm_err->logfile,0)
   IF (dil_reqs_met_ind=1)
    EXECUTE dm2_preview_luts "*", "*", "PREVIEW"
    IF ((dm_err->err_ind > 0))
     SET dm_err->emsg = concat("Error during schema preview dm2_preview_luts. ",dm_err->emsg)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((((luts_list->table_diff_cnt > 0)) OR ((((luts_list->table_diff_txn_cnt > 0)) OR ((
    luts_drop_list->table_cnt > 0))) )) )
     SET dm_err->eproc = "LAST_UTC_TS: Install schema differences"
     CALL disp_msg("",dm_err->logfile,0)
     IF (dil_install_schema(null)=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Error during install schema. ",dm_err->emsg)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "LAST_UTC_TS: All schema was updated successfully"
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ELSE
     SET dm_err->eproc = "LAST_UTC_TS: No Schema changes required"
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DM2_INSTALL_LUTS not currently supported on Oracle versions prior to 11.1"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 IF ((luts_list->install_by_rdm_ind=0))
  CALL clear(1,1)
  SET message = nowindow
 ENDIF
 SET dil_msg = dm_err->emsg
 CALL dctx_set_context("TRG_LUTS_CHK","YES")
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "dm2_install_luts has completed"
 ELSEIF (dil_msg != "")
  SET dm_err->emsg = dil_msg
 ENDIF
 CALL set_module("","")
 CALL final_disp_msg(dil_logfile_prefix)
 SET trace noprogcachesize 75
 SET trace = nordbdebug
END GO
