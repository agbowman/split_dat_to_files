CREATE PROGRAM dm2_utc_convert_main:dba
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
 IF (validate(dm2rpting->prompt_mode," ")=" ")
  FREE RECORD dm2rpting
  RECORD dm2rpting(
    1 prompt_mode = vc
    1 install_mode = vc
    1 schema_date = vc
    1 package_number = i4
    1 report_option = vc
    1 run_id = f8
    1 gen_dt_tm = dq8
    1 process_option = vc
    1 last_checkpoint = vc
    1 status_criteria = vc
    1 report_name = vc
  )
  SET dm2rpting->prompt_mode = "PROMPT"
  SET dm2rpting->install_mode = "PACKAGE"
  SET dm2rpting->schema_date = " "
  SET dm2rpting->package_number = 0
  SET dm2rpting->report_option = "DM2NOTSET"
  SET dm2rpting->status_criteria = "DM2NOTSET"
  SET dm2rpting->report_name = "DM2NOTSET"
  SET dm2rpting->process_option = "DM2NOTSET"
  SET dm2rpting->run_id = 0.00
 ENDIF
 DECLARE dm2rpt_refresh_from_dm2comprom(null) = null
 SUBROUTINE dm2rpt_refresh_from_dm2comprom(null)
   SET dm2rpting->install_mode = dm2comprom->install_mode
   SET dm2rpting->schema_date = dm2comprom->schema_date
   SET dm2rpting->package_number = dm2comprom->package_number
   SET dm2rpting->run_id = dm2comprom->run_id
   SET dm2rpting->gen_dt_tm = dm2comprom->gen_dt_tm
   SET dm2rpting->process_option = dm2comprom->process_option
   SET dm2rpting->last_checkpoint = dm2comprom->last_checkpoint
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
 FREE RECORD ducm_wrap_text
 RECORD ducm_wrap_text(
   1 initial_text = vc
   1 line_cnt = i4
   1 text[*]
     2 line = vc
 )
 DECLARE ducm_check_date_mode(null) = i2
 DECLARE ducm_initialize(null) = i2
 DECLARE ducm_refresh_status(null) = i2
 DECLARE ducm_display_main_menu(ddmm_menu_option=c1(ref)) = i2
 DECLARE ducm_validate_uptime_step(null) = i2
 DECLARE ducm_validate_downtime_step(null) = i2
 DECLARE ducm_validate_complete_step(null) = i2
 DECLARE ducm_submit_job_to_background(dsjb_file_name=vc(ref),dsjb_logfile_name=vc(ref)) = i2
 DECLARE ducm_prompt_run_uptime(null) = i2
 DECLARE ducm_prompt_run_downtime(null) = i2
 DECLARE ducm_display_status_msg(ddsm_msg=vc) = i2
 DECLARE ducm_wrap_msg_text(dwmt_length=i4,dwmt_initial_text=vc) = i2
 DECLARE ducm_cleanup_schema(null) = i2
 DECLARE ducm_stop_uptime_data_convertion(null) = i2
 DECLARE ducm_display_ddl_reports(null) = i2
 DECLARE ducm_validate_cleanup_step(null) = i2
 DECLARE ducm_cleanup_tmp_cols(dctc_cleanup_done=i2(ref)) = i2
 DECLARE ducm_chk_tmp_notnull(null) = i2
 DECLARE ducm_chk_tmp_default(null) = i2
 DECLARE ducm_logfile_prefix = vc WITH protect, noconstant("dm2_utc_cnvtmn")
 DECLARE ducm_envname = vc WITH protect, noconstant("NOT SET")
 DECLARE ducm_envid = f8 WITH protect, noconstant(0.0)
 DECLARE ducm_loop_ind = i2 WITH protect, noconstant(1)
 DECLARE ducm_menu_option = c1 WITH protect, noconstant("0")
 DECLARE ducm_tmp_schema_changed_ind = i2 WITH protect, noconstant(0)
 DECLARE ducm_cleanup_ind = i2 WITH protect, noconstant(0)
 DECLARE ducm_cleanup_done = i2 WITH protect, noconstant(0)
 DECLARE ducm_dbase_name = vc WITH protect, noconstant("TARGET")
 DECLARE ducm_hold_err_ind = i2 WITH protect, noconstant(0)
 DECLARE ducm_hold_err_proc = vc WITH protect, noconstant(" ")
 DECLARE ducm_hold_err_msg = vc WITH protect, noconstant(" ")
 IF (check_logfile(ducm_logfile_prefix,".log","DM2_UTC_CONVERT LOGFILE")=0)
  GO TO exit_program
 ENDIF
 IF (dctx_set_context("FIRE_REFCHG_TRG","NO")=0)
  GO TO exit_program
 ENDIF
 IF (dctx_set_context("FIRE_EA_TRG","NO")=0)
  GO TO exit_program
 ENDIF
 IF (ducm_initialize(null)=0)
  GO TO exit_program
 ENDIF
 IF (dum_fill_user_list(ducm_dbase_name)=0)
  GO TO exit_program
 ENDIF
 WHILE (ducm_loop_ind=1)
   IF (ducm_refresh_status(null)=0)
    GO TO exit_program
   ENDIF
   IF ( NOT ((dum_utc_data->status IN ("NONE", "SETUP_START"))))
    IF (ducm_status_chk(ducm_dbase_name)=0)
     GO TO exit_program
    ENDIF
   ENDIF
   IF (ducm_display_main_menu(ducm_menu_option)=0)
    GO TO exit_program
   ENDIF
   CASE (ducm_menu_option)
    OF "1":
     IF (ducm_check_date_mode(null)=0)
      GO TO exit_program
     ENDIF
     EXECUTE dm2_utc_setup
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    OF "2":
     IF (ducm_check_date_mode(null)=0)
      GO TO exit_program
     ENDIF
     IF (ducm_validate_uptime_step(null)=1)
      SET ducm_tmp_schema_changed_ind = 0
      IF (dum_check_for_new_run_id(dum_utc_data->downtime_run_id,ducm_tmp_schema_changed_ind,
       ducm_dbase_name)=0)
       GO TO exit_program
      ENDIF
      SET dum_utc_data->schema_changed = ducm_tmp_schema_changed_ind
      IF ((dum_utc_data->schema_changed=1))
       SET dum_utc_data->status = "RESTART"
       UPDATE  FROM dm2_admin_dm_info di
        SET di.info_name = dum_utc_data->status
        WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
           "_UTC_DATA_STATUS")))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        ROLLBACK
        GO TO exit_program
       ENDIF
       COMMIT
      ELSE
       IF ((dum_utc_data->status="HOLD"))
        SET dum_utc_data->status = "UPTIME"
        UPDATE  FROM dm2_admin_dm_info d
         SET d.info_name = dum_utc_data->status
         WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
            "_UTC_DATA_STATUS")))
         WITH nocounter
        ;end update
        IF (check_error("Switching status from HOLD to UPTIME.")=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ELSE
         COMMIT
        ENDIF
       ENDIF
       IF (ducm_prompt_run_uptime(null)=0)
        GO TO exit_program
       ENDIF
      ENDIF
     ELSEIF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    OF "3":
     IF (ducm_check_date_mode(null)=0)
      GO TO exit_program
     ENDIF
     IF (ducm_validate_downtime_step(null)=1)
      SET ducm_tmp_schema_changed_ind = 0
      IF (dum_check_for_new_run_id(dum_utc_data->downtime_run_id,ducm_tmp_schema_changed_ind,
       ducm_dbase_name)=0)
       GO TO exit_program
      ENDIF
      SET dum_utc_data->schema_changed = ducm_tmp_schema_changed_ind
      IF ((dum_utc_data->schema_changed=1))
       SET dm_err->eproc =
       "Schema has changed since setup ran. Checking to see if any downtime schema has completed."
       CALL disp_msg(" ",dm_err->logfile,0)
       SELECT INTO "nl:"
        d.op_id
        FROM dm2_ddl_ops_log d
        WHERE (d.run_id=dum_utc_data->downtime_run_id)
         AND d.status="COMPLETE"
        WITH nocounter, maxqual(d,1)
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ENDIF
       IF (curqual > 0)
        SET dm_err->emsg =
        "Database schema has changed since the Downtime Schema step began. This is a fatal error."
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ELSE
        SET dum_utc_data->status = "RESTART"
        UPDATE  FROM dm2_admin_dm_info di
         SET di.info_name = dum_utc_data->status
         WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
            "_UTC_DATA_STATUS")))
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
         GO TO exit_program
        ENDIF
        COMMIT
        SET dm_err->eproc = "Database schema has changed since the Downtime Schema step began. "
        SET dm_err->user_action = "Select option 1 to reevaluate schema differences."
        IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
         GO TO exit_program
        ENDIF
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
      ELSE
       IF (ducm_prompt_run_downtime(null)=0)
        GO TO exit_program
       ENDIF
      ENDIF
     ELSEIF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    OF "4":
     IF (ducm_validate_complete_step(null)=1)
      SET ducm_tmp_schema_changed_ind = 0
      IF ((dm2_install_schema->process_option != "MIGRATION/UTC"))
       IF (dum_check_for_new_run_id(dum_utc_data->downtime_run_id,ducm_tmp_schema_changed_ind,
        ducm_dbase_name)=0)
        GO TO exit_program
       ENDIF
      ENDIF
      SET dum_utc_data->schema_changed = ducm_tmp_schema_changed_ind
      IF ((dum_utc_data->schema_changed=1))
       SET dm_err->emsg =
       "Database schema has changed since the Downtime Schema step completed. This is a fatal error."
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       GO TO exit_program
      ELSE
       IF (ducm_cleanup_schema(null)=0)
        GO TO exit_program
       ENDIF
       SET dum_utc_data->status = "COMPLETE"
       UPDATE  FROM dm2_admin_dm_info di
        SET di.info_name = dum_utc_data->status
        WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
           "_UTC_DATA_STATUS")))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        ROLLBACK
        GO TO exit_program
       ENDIF
       COMMIT
      ENDIF
     ENDIF
    OF "5":
     IF ((dm_err->debug_flag > 0))
      SET message = nowindow
      CALL echo("Start step 5 Conversion Cleanup")
     ENDIF
     IF (ducm_validate_cleanup_step(null)=1)
      IF (ducm_cleanup_tmp_cols(ducm_cleanup_done)=0)
       GO TO exit_program
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("ducm_cleanup_done = ",ducm_cleanup_done))
      ENDIF
      IF (ducm_cleanup_done=1)
       SET dm_err->eproc = "Update UTC status to indicate Coversion Cleanup is done."
       CALL disp_msg("",dm_err->logfile,0)
       UPDATE  FROM dm2_admin_dm_info di
        SET di.info_name = dum_utc_data->status, di.info_long_id = 1
        WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
           "_UTC_DATA_STATUS")))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        ROLLBACK
        GO TO exit_program
       ENDIF
       COMMIT
      ENDIF
     ENDIF
    OF "A":
     IF (ducm_stop_uptime_data_convertion(null)=0)
      GO TO exit_program
     ENDIF
    OF "B":
     IF (ducm_display_ddl_reports(null)=0)
      GO TO exit_program
     ENDIF
    OF "C":
     SET ducm_loop_ind = 1
    OF "D":
     IF ((((dum_utc_data->in_process=0)) OR ((((dum_utc_data->status IN ("SETUP_START",
     "SETUP_COMPLETE", "RESTART", "SWITCH_START", "COMPLETE",
     "HOLD"))) OR ((((dum_utc_data->uptime_run_id=0.0)) OR ((dum_utc_data->downtime_run_id=0.0))) ))
     )) )
      SET dum_utc_data->status_desc = concat(
       "Start Parallel Runners is not a valid option at this time.",
       "  Do you want to continue to the main menu?")
      IF (ducm_display_status_msg(dum_utc_data->status_desc)=0)
       GO TO exit_program
      ENDIF
     ELSE
      EXECUTE dm2_utc_runner
     ENDIF
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    OF "X":
     SET ducm_loop_ind = 0
   ENDCASE
 ENDWHILE
 GO TO exit_program
 SUBROUTINE ducm_check_date_mode(null)
   DECLARE dcdm_date_mode = vc WITH protect, noconstant("NOT SET")
   SET dcdm_date_mode = trim(logical("DATE_MODE"))
   IF (cnvtupper(dcdm_date_mode)="UTC"
    AND (validate(dm2_utc_convert_mode_override,- (1))=- (1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "This environment is already in UTC mode.  DATE_MODE is set to UTC."
    SET dm_err->eproc = "Checking current configuration."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_initialize(null)
   SET dm_err->eproc = "Getting database information..."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm2_install_schema->dbase_name = ducm_dbase_name
   SET dm2_install_schema->u_name = "V500"
   EXECUTE dm2_connect_to_dbase "PC"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dm2_get_dbase_name(ducm_dbase_name)=0)
    RETURN(0)
   ENDIF
   SET dm2_install_schema->target_dbase_name = cnvtupper(ducm_dbase_name)
   SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
   SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
   IF ((validate(dm2_utc_standalone,- (1))=- (1)))
    SET dm2_install_schema->process_option = "MIGRATION/UTC"
   ELSE
    SET dm2_install_schema->process_option = "UTC"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_refresh_status(null)
   DECLARE drs_applid_status = c1 WITH protect, noconstant("X")
   DECLARE drs_inerror_status = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Refreshing the UTC Conversion status."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    di.info_domain
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
       "_UTC_DATA_STATUS")))
    DETAIL
     dum_utc_data->schema_date = di.info_number, dum_utc_data->appl_id = di.info_char, dum_utc_data->
     status = di.info_name,
     dum_utc_data->in_process = 1, ducm_cleanup_ind = di.info_long_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dum_utc_data->status = "NONE"
    SET dum_utc_data->in_process = 0
   ELSE
    SELECT INTO "nl:"
     FROM dm2_ddl_ops d
     WHERE d.schema_date=cnvtdatetime(dum_utc_data->schema_date)
      AND d.process_option IN ("UTC CONVERSION UPTIME", "UTC CONVERSION DOWNTIME")
     DETAIL
      IF (d.process_option="UTC CONVERSION UPTIME")
       dum_utc_data->uptime_run_id = d.run_id
      ELSE
       dum_utc_data->downtime_run_id = d.run_id
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "UTC CONVERSION status row found in ADMIN dm_info, but no corresponding rows found in dm2_ddl_ops."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(dum_utc_data)
   ENDIF
   IF (dm2_cleanup_stranded_appl(null)=0)
    RETURN(0)
   ENDIF
   IF (dum_cleanup_stranded_appl_id(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Evaluating UTC Conversion Status: ",dum_utc_data->status)
   CALL disp_msg(" ",dm_err->logfile,0)
   CASE (cnvtupper(dum_utc_data->status))
    OF "NONE":
     SET dum_utc_data->status_desc =
     "The UTC Conversion process has not been initiated. Select Step 1 to begin."
    OF "RESTART":
     SET dum_utc_data->status_desc = concat(
      "Schema Changed since UTC Conversion process was intiated. Select ",
      "Step 1 to set up database for UTC conversion again.")
    OF "SETUP_START":
     SET drs_applid_status = dm2_get_appl_status(dum_utc_data->appl_id)
     IF (drs_applid_status="A")
      SET dum_utc_data->status_desc = "Setting up database for UTC Conversion."
     ELSEIF (drs_applid_status="I")
      SET dum_utc_data->status_desc =
      "UTC Conversion Setup has not completed. Select Step 1 to complete the setup process."
     ELSE
      RETURN(0)
     ENDIF
    OF "SETUP_COMPLETE":
     SET dum_utc_data->status_desc =
     "Database set up for UTC Conversion. Select Step 2 to perform uptime data conversion."
    OF "HOLD":
     SET dum_utc_data->status_desc = concat(
      "The Uptime Database Conversion process has been stopped. Select Step 2 to ",
      "restart the process again.")
    OF "UPTIME":
     SET drs_applid_status = dm2_get_appl_status(dum_utc_data->appl_id)
     IF (drs_applid_status="A")
      SET dum_utc_data->status_desc = "Uptime data conversion is currently being executed."
     ELSEIF (drs_applid_status="I")
      SET dm_err->eproc = "Checking for incomplete and in-error operations."
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "nl:"
       d.op_id
       FROM dm2_ddl_ops_log d
       WHERE (d.run_id=dum_utc_data->uptime_run_id)
        AND ((d.status != "COMPLETE") OR (d.status = null))
       DETAIL
        IF (d.status="ERROR")
         drs_inerror_status = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dum_utc_data->status_desc = "Uptime data conversion has completed successfully."
       RETURN(1)
      ELSEIF (drs_inerror_status=1)
       SET dum_utc_data->status_desc = concat(
        "Uptime data conversion has been executed with failures. Select View ",
        "DDL Reports from UTC Conversion Main Menu to view failed operations.")
       RETURN(1)
      ELSE
       SET dum_utc_data->status_desc = concat("The main background session has terminated. ",
        "Select Step 2 again to restart Uptime Data Conversion.")
       RETURN(1)
      ENDIF
     ELSE
      RETURN(0)
     ENDIF
    OF "DOWNTIME":
     SET drs_applid_status = dm2_get_appl_status(dum_utc_data->appl_id)
     IF (drs_applid_status="A")
      SET dum_utc_data->status_desc = "Downtime schema operations are currently being executed."
     ELSEIF (drs_applid_status="I")
      SET dm_err->eproc = "Checking for incomplete and in-error operations."
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "nl:"
       d.op_id
       FROM dm2_ddl_ops_log d
       WHERE (d.run_id=dum_utc_data->downtime_run_id)
        AND ((d.status != "COMPLETE") OR (d.status = null))
       DETAIL
        IF (d.status="ERROR")
         drs_inerror_status = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dum_utc_data->status_desc = "Downtime schema operations are completed."
      ELSEIF (drs_inerror_status=1)
       SET dum_utc_data->status_desc = concat(
        "Downtime schema operations have been executed with failures. ",
        "Select View DDL Reports from UTC Conversion Main Menu to ","view failed operations.")
      ELSE
       SET dum_utc_data->status_desc = concat("The main background session has terminated. ",
        "Select Step 3 again to restart Downtime Schema Operations.")
       RETURN(1)
      ENDIF
     ELSE
      RETURN(0)
     ENDIF
    OF "SWITCH_START":
     SET drs_applid_status = dm2_get_appl_status(dum_utc_data->appl_id)
     IF (drs_applid_status="A")
      SET dum_utc_data->status_desc = "Completing process for UTC Conversion."
     ELSEIF (drs_applid_status="I")
      SET dum_utc_data->status_desc = "UTC Conversion not complete. Select Step 4 to complete."
     ENDIF
    OF "COMPLETE":
     IF (ducm_cleanup_ind=1)
      SET dum_utc_data->status_desc = "UTC Conversion is Complete."
     ELSEIF (ducm_cleanup_ind=0)
      SET dum_utc_data->status_desc =
      "Conversion committed. Cleanup not initiated or ran but failed to complete.  Select Step 5 to complete."
     ENDIF
    ELSE
     SET dm_err->emsg = concat("Unexpected status found: ",dum_utc_data->status,".  Cannot continue."
      )
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_display_main_menu(ddmm_menu_option)
   DECLARE ddmm_cnt = i4 WITH protect, noconstant(0)
   DECLARE ddmm_offset = i4 WITH protect, noconstant(0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL text(2,3,"UTC Conversion Main Menu")
   CALL box(4,1,17,95)
   CALL box(4,97,17,132)
   CALL text(5,3,"Conversion Steps")
   CALL text(5,99,"UTC Conversion Utilities")
   CALL text(7,3,
    "To convert the Cerner Millennium database to UTC, select the following steps in order:")
   CALL text(7,99,"A) Stop Uptime Data Conversion")
   CALL text(8,99,"B) View DDL Reports")
   CALL text(9,5,"1) Set Up Database for UTC Conversion")
   CALL text(9,99,"C) Refresh UTC Conversion Status")
   CALL text(10,5,"2) Perform Uptime Data Conversion")
   CALL text(10,99,"D) Start Parallel Runners")
   CALL text(11,3,
    "----------------------------------- Start of Downtime ------------------------------------")
   CALL text(12,5,"3) Perform Downtime Schema")
   CALL text(13,3,
    "------------------------- End of Downtime / Beginning of Testing -------------------------")
   CALL text(14,5,"4) Complete UTC Conversion")
   CALL text(15,3,
    "------------------------------------ Post Conversion  ------------------------------------")
   CALL text(16,5,"5) Conversion Cleanup")
   IF (ducm_wrap_msg_text(128,concat("UTC Conversion Status: ",dum_utc_data->status_desc))=0)
    RETURN(0)
   ENDIF
   CALL box(18,1,(ducm_wrap_text->line_cnt+ 20),132)
   CALL text(19,3,concat("Database: ",dm2_install_schema->target_dbase_name))
   FOR (ddmm_cnt = 1 TO ducm_wrap_text->line_cnt)
     CALL text((ddmm_cnt+ 19),3,ducm_wrap_text->text[ddmm_cnt].line)
   ENDFOR
   SET ddmm_offset = (ducm_wrap_text->line_cnt+ 22)
   CALL text(ddmm_offset,3,
    ">>> Select an appropriate step or utility from the menus above (X to exit):")
   SET accept = time(60)
   CALL accept(ddmm_offset,81,"X;CU","C"
    WHERE cnvtupper(curaccept) IN ("1", "2", "3", "4", "5",
    "A", "B", "C", "D", "X"))
   SET accept = time(0)
   SET ddmm_menu_option = cnvtupper(curaccept)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
    CALL echo(build("ddmm_menu_option = ",ddmm_menu_option))
   ENDIF
   CALL clear(1,1)
   SET message = nowindow
   IF (check_error("white box")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_validate_uptime_step(null)
   DECLARE dvus_applid_status = c1 WITH protect, noconstant("X")
   SET dm_err->eproc = "Validating menu selection:  Uptime Data Conversion"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dum_utc_data->in_process=0))
    SET dm_err->eproc = "Uptime Data Conversion is not a valid option at this time. "
    SET dm_err->user_action = "Select option 1 to begin converting the database to UTC."
    IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
     RETURN(0)
    ENDIF
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ELSEIF ((dum_utc_data->status IN ("SETUP_START", "DOWNTIME", "RESTART", "SWITCH_START", "COMPLETE"
   )))
    SET dum_utc_data->status_desc = "Uptime Data Conversion is not a valid option at this time."
    CALL ducm_display_status_msg(dum_utc_data->status_desc)
    RETURN(0)
   ELSEIF ((dum_utc_data->status="SETUP_COMPLETE"))
    SET dum_utc_data->status = "UPTIME"
    SET dm_err->eproc = "Updating appl_id and status for the UTC CONVERSION row."
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm2_admin_dm_info d
     SET d.info_name = dum_utc_data->status
     WHERE d.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
        "_UTC_DATA_STATUS")))
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
    RETURN(1)
   ELSEIF ((dum_utc_data->status="UPTIME"))
    SET dvus_applid_status = dm2_get_appl_status(dum_utc_data->appl_id)
    IF (dvus_applid_status="A")
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "Uptime Data Conversion is already in process. This is not a valid option at this time."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    RETURN(1)
   ELSEIF ((dum_utc_data->status="HOLD"))
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE ducm_validate_downtime_step(null)
   DECLARE dvds_inerror_status = i2 WITH protect, noconstant(0)
   DECLARE dvds_applid_status = c1 WITH protect, noconstant("X")
   SET dm_err->eproc = "Validating menu selection:  Perform Downtime Schema"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dum_utc_data->in_process=0))
    SET dm_err->eproc =
    "Perform Downtime Schema is not a valid option at this time. The database has not been set up yet. "
    SET dm_err->user_action = "Select option 1 to begin converting the database to UTC."
    IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
     RETURN(0)
    ENDIF
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ELSEIF ((dum_utc_data->status IN ("SETUP_START", "SETUP_COMPLETE", "RESTART", "SWITCH_START",
   "COMPLETE")))
    SET dm_err->eproc = "Perform Downtime Schema is not a valid option at this time."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (ducm_display_status_msg(dm_err->eproc)=0)
     RETURN(0)
    ENDIF
    RETURN(0)
   ELSEIF ((dum_utc_data->status="UPTIME"))
    SET dvds_applid_status = dm2_get_appl_status(dum_utc_data->appl_id)
    IF (dvds_applid_status="A")
     SET dm_err->eproc = concat(
      "The Uptime Data Conversion has been initiated and is currently running. ",
      "Cannot perform Downtime Schema until the uptime step is complete.")
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (ducm_display_status_msg(dm_err->eproc)=0)
      RETURN(0)
     ENDIF
     RETURN(0)
    ELSEIF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     SELECT INTO "nl:"
      d.op_id
      FROM dm2_ddl_ops_log d
      WHERE (d.run_id=dum_utc_data->uptime_run_id)
       AND ((d.status != "COMPLETE") OR (d.status = null))
      DETAIL
       IF (d.status="ERROR")
        dvds_inerror_status = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dum_utc_data->status = "DOWNTIME"
      UPDATE  FROM dm2_admin_dm_info di
       SET di.info_name = dum_utc_data->status
       WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
          "_UTC_DATA_STATUS")))
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       RETURN(0)
      ENDIF
      COMMIT
      RETURN(1)
     ELSEIF (dvds_inerror_status=1)
      SET dm_err->eproc = "Uptime data conversion has been executed with failures. "
      SET dm_err->user_action =
      "Choose View DDL Reports from UTC Conversion Main Menu to view failed operations."
      IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
       RETURN(0)
      ENDIF
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF ((dum_utc_data->status="DOWNTIME"))
    SET dvds_applid_status = dm2_get_appl_status(dum_utc_data->appl_id)
    IF (dvds_applid_status="A")
     IF (ducm_display_status_msg("Downtime Schema currently is running in another session.")=0)
      RETURN(0)
     ENDIF
     RETURN(0)
    ELSEIF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    RETURN(1)
   ELSEIF ((dum_utc_data->status="HOLD"))
    SET dm_err->eproc = "Uptime Data Conversion was stopped.  "
    SET dm_err->user_action = "Select option 2 again to restart this process."
    IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
     RETURN(0)
    ENDIF
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE ducm_validate_complete_step(null)
   DECLARE dvcs_inerror_status = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "WARNING: This step cannot be reversed.  Are you sure you want to continue?"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (ducm_display_status_msg(dm_err->eproc)=0)
    RETURN(0)
   ENDIF
   IF ((dum_utc_data->in_process=0))
    SET dm_err->eproc =
    "Complete UTC Conversion is not a valid option at this time. The database has not been set up yet. "
    SET dm_err->user_action = "Select option 1 to begin converting the database to UTC."
    IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
     RETURN(0)
    ENDIF
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ELSEIF ((dum_utc_data->status IN ("SETUP_START", "SETUP_COMPLETE", "RESTART", "HOLD", "UPTIME",
   "COMPLETE")))
    SET dm_err->eproc = "Complete UTC Conversion is not a valid option at this time."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (ducm_display_status_msg(dm_err->eproc)=0)
     RETURN(0)
    ENDIF
    RETURN(0)
   ELSEIF ((dum_utc_data->status="DOWNTIME"))
    IF (dm2_get_appl_status(dum_utc_data->appl_id)="A")
     SET dm_err->eproc = concat("Downtime Schema has been initiated and is currently running. ",
      "Cannot Complete UTC Conversion until the downtime step is complete.")
     IF (ducm_display_status_msg(dm_err->eproc)=0)
      RETURN(0)
     ENDIF
     RETURN(0)
    ELSEIF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     SELECT INTO "nl:"
      d.op_id
      FROM dm2_ddl_ops_log d
      WHERE (d.run_id=dum_utc_data->downtime_run_id)
       AND ((d.status != "COMPLETE") OR (d.status = null))
      DETAIL
       IF (d.status="ERROR")
        dvcs_inerror_status = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dum_utc_data->status = "SWITCH_START"
      UPDATE  FROM dm2_admin_dm_info di
       SET di.info_name = dum_utc_data->status, di.info_char = currdbhandle
       WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
          "_UTC_DATA_STATUS")))
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       RETURN(0)
      ENDIF
      COMMIT
      RETURN(1)
     ELSEIF (dvcs_inerror_status=1)
      SET dm_err->eproc = "Downtime Schema has been executed with failures.  "
      SET dm_err->user_action =
      "Select View DDL Reports from UTC Conversion Main Menu to view failed operations."
      IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
       RETURN(0)
      ENDIF
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(0)
     ELSE
      SET dm_err->eproc =
      "Main background runner has stopped, but additional downtime operations remain."
      SET dm_err->user_action = "Select Step 3 to continue processing downtime schema."
      CALL disp_msg(" ",dm_err->logfile,0)
      IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
       RETURN(0)
      ENDIF
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF ((dum_utc_data->status="SWITCH_START"))
    IF (dm2_get_appl_status(dum_utc_data->appl_id)="A")
     SET dm_err->eproc = concat(
      "Complete UTC Conversion has been initiated and is currently running.")
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (ducm_display_status_msg(dm_err->eproc)=0)
      RETURN(0)
     ENDIF
     RETURN(0)
    ELSEIF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     UPDATE  FROM dm2_admin_dm_info di
      SET di.info_char = currdbhandle
      WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
         "_UTC_DATA_STATUS")))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE ducm_validate_cleanup_step(null)
   DECLARE dvcs_inerror_status = i2 WITH protect, noconstant(0)
   IF ((dum_utc_data->in_process=0))
    SET dm_err->eproc =
    "Conversion Cleanup is not a valid option at this time. The database has not been set up yet. "
    SET dm_err->user_action = "Select option 1 to begin converting the database to UTC."
    IF (ducm_display_status_msg(concat(dm_err->eproc,dm_err->user_action))=0)
     RETURN(0)
    ENDIF
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ELSEIF ((dum_utc_data->status IN ("SETUP_START", "SETUP_COMPLETE", "RESTART", "HOLD", "UPTIME",
   "DOWNTIME", "SWITCH_START")))
    SET dm_err->eproc = "Conversion Cleanup is not a valid option at this time."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (ducm_display_status_msg(dm_err->eproc)=0)
     RETURN(0)
    ENDIF
    RETURN(0)
   ELSEIF ((dum_utc_data->status="COMPLETE"))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE ducm_submit_job_to_background(dsjb_file_name,dsjb_logfile_name)
   DECLARE dsjb_delim_pos = i4 WITH protect, noconstant(0)
   DECLARE dsjb_cmd_str = vc WITH protect, noconstant("NOT SET")
   DECLARE dsjb_dcl_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dsjb_tmp_find_str = vc WITH protect, noconstant("NOT_SET")
   DECLARE dsjb_unique_tempstr = vc WITH protect, noconstant(" ")
   SET dsjb_unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
      cnvtdatetime(curdate,000000)) * 864000)))
   IF (cursys="AIX")
    SET dsjb_delim_pos = findstring(":",dsjb_file_name,1)
    SET dsjb_file_name = concat("$CCLUSERDIR/",substring((dsjb_delim_pos+ 1),(size(dsjb_file_name) -
      dsjb_delim_pos),dsjb_file_name))
    SET dsjb_logfile_name = concat(substring(1,(size(trim(dsjb_file_name)) - 4),dsjb_file_name),"_",
     dsjb_unique_tempstr,".out")
    IF (dm2_push_dcl(concat("chmod ugo+x ",dsjb_file_name))=0)
     RETURN(0)
    ENDIF
    SET dsjb_cmd_str = concat("nohup ",dsjb_file_name," > ",dsjb_logfile_name," 2>&1 &")
    CALL dcl(dsjb_cmd_str,size(dsjb_cmd_str),dsjb_dcl_err_ind)
    IF (dsjb_dcl_err_ind=0)
     IF (parse_errfile(dsjb_logfile_name)=0)
      RETURN(0)
     ENDIF
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(
      "An error was encountered. See the following file for more information: ",dsjb_logfile_name)
     SET dm_err->eproc = "Submitting job to background."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (dm2_push_dcl("ps -ef | grep dm2_utc_main_runner | grep -v grep")=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(
      "The background process did not survive. See the following file for more information: ",
      dsjb_logfile_name)
     SET dm_err->eproc = "Checking on background job."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF (cursys="AXP")
    SET dsjb_logfile_name = concat(substring(1,(size(trim(dsjb_file_name)) - 4),dsjb_file_name),"_",
     dsjb_unique_tempstr,".out")
    IF (dm2_push_dcl(concat("set file/prot=(s:RWED, o:RWED, g:RWED, w:RWED) ",dsjb_file_name))=0)
     RETURN(0)
    ENDIF
    IF (dir_setup_batch_queue(dir_batch_queue)=0)
     RETURN(0)
    ENDIF
    SET dsjb_cmd_str = concat("submit /queue=",dir_batch_queue," /log=",dsjb_logfile_name," ",
     dsjb_file_name)
    IF (dm2_push_dcl(dsjb_cmd_str)=0)
     RETURN(0)
    ENDIF
    SET dsjb_cmd_str = concat("$show queue /all_jobs ",dir_batch_queue)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(dsjb_cmd_str)=0)
     IF ((dm_err->err_ind=1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    SET dsjb_tmp_find_str = cnvtupper(dsjb_file_name)
    SET dsjb_tmp_find_str = trim(replace(dsjb_tmp_find_str,".COM"," ",1),3)
    SET dsjb_tmp_find_str = trim(replace(dsjb_tmp_find_str,"CCLUSERDIR:"," ",1),3)
    IF (findstring(dsjb_tmp_find_str,cnvtupper(dm_err->errtext))=0)
     SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
     SET dm_err->emsg = dm_err->disp_msg_emsg
     SET dm_err->eproc = concat("Validating ",trim(dsjb_file_name)," was successfully executed.")
     SET dm_err->err_ind = 1
     CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_prompt_run_uptime(null)
   DECLARE dpru_file_name = vc WITH protect, noconstant("NOT SET")
   DECLARE dpru_logfile_name = vc WITH protect, noconstant("NOT SET")
   DECLARE dpru_msg_str = vc WITH protect, noconstant("NOT SET")
   IF (dum_generate_schema_execution_script(dum_utc_data->uptime_run_id,dm2_install_schema->p_word,
    dm2_install_schema->connect_str,dpru_file_name)=0)
    RETURN(0)
   ENDIF
   IF (ducm_submit_job_to_background(dpru_file_name,dpru_logfile_name)=0)
    RETURN(0)
   ENDIF
   IF (cursys="AIX")
    SET dpru_msg_str = concat("A shell script (",dpru_file_name,
     ") has been executed in the background to initiate uptime schema. ",
     "This process will write all output to a separate log file (",dpru_logfile_name,
     ").")
   ELSEIF (cursys="AXP")
    SET dpru_msg_str = concat("A command procedure (",dpru_file_name,
     ") has been submitted to batch to initiate uptime schema. ",
     "This process will write all output to a separate log file (",dpru_logfile_name,
     ").")
   ENDIF
   IF (ducm_display_status_msg(dpru_msg_str)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_prompt_run_downtime(null)
   DECLARE dprd_file_name = vc WITH protect, noconstant("NOT SET")
   DECLARE dprd_logfile_name = vc WITH protect, noconstant("NOT SET")
   DECLARE dprd_delim_pos = i4 WITH protect, noconstant(0)
   DECLARE dprd_msg_str = vc WITH protect, noconstant("NOT SET")
   DECLARE dprd_cmd_str = vc WITH protect, noconstant("NOT SET")
   DECLARE dprd_logfile_name = vc WITH protect, noconstant("NOT SET")
   DECLARE dprd_dcl_err_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "UTC Conversion Perform Downtime Schema"
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,15,131)
   CALL text(4,45,"UTC Conversion Perform Downtime Schema")
   CALL text(6,3,
    "WARNING!  The UTC conversion downtime schema operations should only be completed when ")
   CALL text(7,3,"the domain is down and users are no longer on the system! ")
   CALL text(9,2,"Proceed with downtime schema conversion (Y/N)? ")
   CALL accept(9,50,"A;CU"," "
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text(11,2,"Are you ABSOLUTELY sure? (A=Absolutely, N=No):")
    CALL accept(11,49,"A;CU"," "
     WHERE curaccept IN ("A", "N"))
    IF (curaccept="N")
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "User chose to quit second confirmation step."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET message = nowindow
     SET dm_err->eproc = "Prompting to run downtime command."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dum_generate_schema_execution_script(dum_utc_data->downtime_run_id,dm2_install_schema->
      p_word,dm2_install_schema->connect_str,dprd_file_name)=0)
      RETURN(0)
     ENDIF
     IF (ducm_submit_job_to_background(dprd_file_name,dprd_logfile_name)=0)
      RETURN(0)
     ENDIF
     IF (cursys="AIX")
      SET dprd_msg_str = concat("A shell script (",dprd_file_name,
       ") has been executed in the background to initiate downtime schema. ",
       "This process will write all output to a separate log file (",dprd_logfile_name,
       ").")
     ELSEIF (cursys="AXP")
      SET dprd_msg_str = concat("A command procedure (",dprd_file_name,
       ") has been submitted batch to initiate downtime ",
       "schema. This process will write all output to a separate log file (",dprd_logfile_name,
       ").")
     ENDIF
     IF (ducm_display_status_msg(dprd_msg_str)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "User chose to quit at first confirmation step."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_display_status_msg(ddsm_msg)
   DECLARE ddsm_cnt = i4 WITH protect, noconstant(0)
   DECLARE ddsm_accept = c1 WITH protect, noconstant("X")
   IF (ducm_wrap_msg_text(128,ddsm_msg)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    SET message = nowindow
    CALL echorecord(ducm_wrap_text)
   ENDIF
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL text(2,3,"UTC Conversion Status")
   FOR (ddsm_cnt = 1 TO ducm_wrap_text->line_cnt)
     CALL text((ddsm_cnt+ 5),3,ducm_wrap_text->text[ddsm_cnt].line)
   ENDFOR
   CALL text((ducm_wrap_text->line_cnt+ 7),3,"Enter (C) to continue or (X) to exit.")
   CALL accept((ducm_wrap_text->line_cnt+ 7),58,"A;CU"," "
    WHERE cnvtupper(curaccept) IN ("C", "X"))
   SET ddsm_accept = cnvtupper(curaccept)
   SET message = nowindow
   IF (ddsm_accept="X")
    SET dm_err->eproc = ddsm_msg
    SET dm_err->emsg = "User chose to quit."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_wrap_msg_text(dwmt_length,dwmt_initial_text)
   DECLARE dwmt_text_pos = i4 WITH protect, noconstant(0)
   DECLARE dwmt_prev_pos = i4 WITH protect, noconstant(0)
   DECLARE dwmt_nextsp_pos = i4 WITH protect, noconstant(0)
   DECLARE dwmt_lastsp_pos = i4 WITH protect, noconstant(0)
   DECLARE dwmt_break_pos = i4 WITH protect, noconstant(0)
   DECLARE dwmt_init_size = i4 WITH protect, constant(size(dwmt_initial_text))
   DECLARE dwmt_lastsp_found = i2 WITH protect, noconstant(0)
   SET ducm_wrap_text->line_cnt = 0
   SET stat = alterlist(ducm_wrap_text->text,ducm_wrap_text->line_cnt)
   IF ((dm_err->debug_flag >= 1))
    CALL echo("*** text to wrap = ")
    CALL echo(dwmt_initial_text)
    CALL echo(build("initsize=",dwmt_init_size,", wrap length=",dwmt_length))
   ENDIF
   WHILE (dwmt_text_pos < dwmt_init_size)
     IF ((dm_err->debug_flag >= 1))
      CALL echo(build("dwmt_text_pos=<",dwmt_text_pos,">"))
     ENDIF
     SET ducm_wrap_text->line_cnt = (ducm_wrap_text->line_cnt+ 1)
     SET stat = alterlist(ducm_wrap_text->text,ducm_wrap_text->line_cnt)
     SET dwmt_prev_pos = dwmt_text_pos
     IF ((dwmt_init_size > (dwmt_prev_pos+ dwmt_length)))
      SET dwmt_text_pos = (dwmt_prev_pos+ dwmt_length)
      IF (substring(dwmt_text_pos,1,dwmt_initial_text)=" ")
       SET dwmt_break_pos = (dwmt_text_pos - 1)
       SET dwmt_text_pos = (dwmt_text_pos+ 1)
      ELSEIF (substring((dwmt_text_pos+ 1),1,dwmt_initial_text)=" ")
       SET dwmt_break_pos = dwmt_text_pos
       SET dwmt_text_pos = (dwmt_text_pos+ 2)
      ELSE
       SET dwmt_lastsp_found = 0
       WHILE (dwmt_lastsp_found=0)
         IF ((dm_err->debug_flag >= 1))
          CALL echo(build("  dwmt_nextsp_pos=<",dwmt_nextsp_pos,">"))
          CALL echo(build("  dwmt_text_pos=<",dwmt_text_pos,">"))
         ENDIF
         SET dwmt_lastsp_pos = dwmt_nextsp_pos
         SET dwmt_nextsp_pos = findstring(" ",dwmt_initial_text,(dwmt_nextsp_pos+ 1),0)
         IF (((dwmt_lastsp_pos > dwmt_nextsp_pos) OR (dwmt_nextsp_pos >= dwmt_text_pos)) )
          SET dwmt_lastsp_found = 1
         ENDIF
       ENDWHILE
       SET dwmt_break_pos = (dwmt_lastsp_pos - 1)
       SET dwmt_text_pos = (dwmt_lastsp_pos+ 1)
      ENDIF
      SET ducm_wrap_text->text[ducm_wrap_text->line_cnt].line = substring(dwmt_prev_pos,(
       dwmt_break_pos - dwmt_prev_pos),dwmt_initial_text)
     ELSE
      SET ducm_wrap_text->text[ducm_wrap_text->line_cnt].line = substring(dwmt_prev_pos,((
       dwmt_init_size - dwmt_prev_pos)+ 1),dwmt_initial_text)
      SET dwmt_text_pos = dwmt_init_size
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_cleanup_schema(null)
   DECLARE dcs_tmp_str = vc WITH protect, noconstant("not set")
   DECLARE dcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dcs_convert_function_exists = i2 WITH protect, noconstant(0)
   DECLARE dcs_reverse_function_exists = i2 WITH protect, noconstant(0)
   DECLARE dcs_cleanup_script = vc WITH protect, noconstant("not set")
   DECLARE dcs_status_msg = vc WITH protect, noconstant("not set")
   DECLARE dcs_cmd_rscbsy_retry_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcs_cmd_rscbsy_error = i2 WITH protect, noconstant(0)
   IF (get_unique_file("dm2utc_dropcol",".ccl")=0)
    RETURN(0)
   ELSE
    SET dcs_cleanup_script = dm_err->unique_fname
   ENDIF
   FREE RECORD dcs_idx
   RECORD dcs_idx(
     1 list_cnt = i4
     1 list[*]
       2 own_name = vc
       2 idx_name = vc
   )
   SET dcs_idx->list_cnt = 0
   FREE RECORD dcs_trg
   RECORD dcs_trg(
     1 list_cnt = i4
     1 list[*]
       2 trg_name = vc
   )
   SET dcs_trg->list_cnt = 0
   FREE RECORD dcs_tbl
   RECORD dcs_tbl(
     1 tbl_cnt = i4
     1 tbl_list[*]
       2 tbl_name = vc
       2 col_cnt = i4
       2 col_list[*]
         3 col_name = vc
   )
   SET dcs_tbl->tbl_cnt = 0
   EXECUTE dm2_set_db_options
   IF ((dm_err->err_ind > 0))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verifying completion of downtime."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    utc.column_name
    FROM dba_tab_columns utc,
     dba_tables dt
    WHERE utc.owner=dt.owner
     AND utc.table_name=dt.table_name
     AND utc.column_name="UTC_TMP1*"
     AND dt.temporary="N"
    DETAIL
     dm_err->err_ind = 1, dm_err->emsg =
     "Found a column that should not exist at this point in the process.  Exiting cleanup process."
    WITH nocounter, maxqual(utc,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    di.index_name
    FROM dba_indexes di
    WHERE di.index_name="ZTC_TMP1*"
    DETAIL
     dm_err->err_ind = 1, dm_err->emsg =
     "Found an index that should not exist at this point in the process.  Exiting cleanup process."
    WITH nocounter, maxqual(ui,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Getting list of temporary indexes to drop."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    di.index_name
    FROM dba_indexes di
    WHERE di.index_name="ZTC*"
    DETAIL
     dcs_idx->list_cnt = (dcs_idx->list_cnt+ 1)
     IF (mod(dcs_idx->list_cnt,1000)=1)
      stat = alterlist(dcs_idx->list,(dcs_idx->list_cnt+ 999))
     ENDIF
     dcs_idx->list[dcs_idx->list_cnt].idx_name = di.index_name, dcs_idx->list[dcs_idx->list_cnt].
     own_name = di.owner
    FOOT REPORT
     stat = alterlist(dcs_idx->list,dcs_idx->list_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Dropping temporary indexes."
   CALL disp_msg(" ",dm_err->logfile,0)
   FOR (dcs_loop = 1 TO dcs_idx->list_cnt)
     SET dcs_tmp_str = concat("rdb asis (^drop index ",dcs_idx->list[dcs_loop].own_name,".",dcs_idx->
      list[dcs_loop].idx_name," ^) go")
     SET dcs_cmd_rscbsy_retry_cnt = 0
     SET dcs_cmd_rscbsy_error = 1
     WHILE (dcs_cmd_rscbsy_error=1
      AND dcs_cmd_rscbsy_retry_cnt < cnvtint(dm2_db_options->resource_busy_maxretry))
       SET dm_err->err_ind = 0
       SET dcs_cmd_rscbsy_error = 0
       EXECUTE dm2_exec_child_cmd "CMD", dcs_tmp_str
       CALL check_error(dm_err->eproc)
       IF ((dm_err->err_ind > 0))
        IF (findstring("ORA-00054",dm_err->emsg) > 0)
         SET dcs_cmd_rscbsy_error = 1
        ELSE
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       IF (dcs_cmd_rscbsy_error=1)
        CALL pause(3)
        SET dcs_cmd_rscbsy_retry_cnt = (dcs_cmd_rscbsy_retry_cnt+ 1)
       ENDIF
     ENDWHILE
     IF (dcs_cmd_rscbsy_error=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Getting list of triggers to drop."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    ut.trigger_name
    FROM user_triggers ut
    WHERE ut.trigger_name="UTC*"
    DETAIL
     dcs_trg->list_cnt = (dcs_trg->list_cnt+ 1)
     IF (mod(dcs_trg->list_cnt,1000)=1)
      stat = alterlist(dcs_trg->list,(dcs_trg->list_cnt+ 999))
     ENDIF
     dcs_trg->list[dcs_trg->list_cnt].trg_name = ut.trigger_name
    FOOT REPORT
     stat = alterlist(dcs_trg->list,dcs_trg->list_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Dropping triggers used during UTC conversion process."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dcs_loop = 0
   FOR (dcs_loop = 1 TO dcs_trg->list_cnt)
    SET dcs_tmp_str = concat("rdb asis (^drop trigger ",dcs_trg->list[dcs_loop].trg_name," ^) go")
    IF (dm2_push_cmd(dcs_tmp_str,1)=0)
     RETURN(0)
    ENDIF
   ENDFOR
   SELECT INTO "nl:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name IN ("DM2_UTC_CONVERT_PKG", "DM2_UTC_REVERSE_PKG")
     AND uo.object_type="PACKAGE"
    DETAIL
     IF (uo.object_name="DM2_UTC_CONVERT_PKG")
      dcs_convert_function_exists = 1
     ELSEIF (uo.object_name="DM2_UTC_REVERSE_PKG")
      dcs_reverse_function_exists = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dcs_convert_function_exists=1)
    SET dm_err->eproc = "Dropping the dm2_utc_convert_pkg package."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_push_cmd("rdb asis (^drop package DM2_UTC_CONVERT_PKG^) go",1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dcs_reverse_function_exists=1)
    SET dm_err->eproc = "Dropping the dm2_utc_reverse_pkg package."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_push_cmd("rdb asis (^drop package DM2_UTC_REVERSE_PKG^) go",1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_stop_uptime_data_convertion(null)
   DECLARE dsudc_runner_cnt = i4 WITH protect, noconstant(0)
   IF ((dum_utc_data->in_process=0))
    SET dum_utc_data->status_desc =
    "Uptime Data Conversion has not started.  Select option 1 to begin this process."
    IF (ducm_display_status_msg(dum_utc_data->status_desc)=0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   IF ((dum_utc_data->in_process=1))
    IF ((dum_utc_data->status IN ("SETUP_START", "SETUP_COMPLETE", "RESTART", "HOLD", "DOWNTIME",
    "SWITCH_START", "COMPLETE")))
     SET dum_utc_data->status_desc = "This is not a valid option for the current status."
     IF (ducm_display_status_msg(dum_utc_data->status_desc)=0)
      RETURN(0)
     ENDIF
     RETURN(1)
    ELSEIF ((dum_utc_data->status="UPTIME"))
     IF (dum_check_concurrent_snapshot("D")=0)
      RETURN(0)
     ENDIF
     IF (dum_cleanup_stranded_appl_id(null)=0)
      GO TO end_program
     ENDIF
     SET dm_err->eproc = "Checking for active runners."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      di.info_domain
      FROM dm_info di
      WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
       AND di.info_number=1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dsudc_runner_cnt = curqual
     IF (curqual=0)
      SET dm_err->eproc = "No runners are currently active."
      CALL disp_msg(" ",dm_err->logfile,0)
     ELSE
      SET dum_utc_data->status_desc = build("There are (",dsudc_runner_cnt,
       ")runners in an active state.  Are you sure you want to stop all runners?.")
      IF (ducm_display_status_msg(dum_utc_data->status_desc)=0)
       RETURN(0)
      ENDIF
      IF (dum_stop_conversion_runner("ALL")=0)
       RETURN(0)
      ENDIF
     ENDIF
     UPDATE  FROM dm2_admin_dm_info di
      SET di.info_name = "HOLD", di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
      WHERE di.info_domain=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,
         "_UTC_DATA_STATUS")))
      WITH nocounter
     ;end update
     IF (check_error("Attempting to put UTC Conversion process on HOLD.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
     SET dm_err->eproc = "UTC Conversion process has been successfully put on HOLD."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_display_ddl_reports(null)
   DECLARE dddr_accept = vc WITH protect, noconstant("NOT_SET")
   DECLARE dddr_run_id = f8 WITH protect, noconstant(0.00)
   DECLARE dddr_gen_dt_tm = dq8 WITH protect, noconstant(0.00)
   DECLARE dddr_process_option = vc WITH protect, noconstant("NOT_SET")
   DECLARE dddr_last_checkpoint = vc WITH protect, noconstant("NOT_SET")
   IF ((((dum_utc_data->in_process=0)) OR ((((dum_utc_data->uptime_run_id=0.0)) OR ((dum_utc_data->
   downtime_run_id=0.0))) )) )
    SET dum_utc_data->status_desc = concat("View DDL Reports is not a valid option at this time.",
     "  Do you want to continue to the main menu?")
    IF (ducm_display_status_msg(dum_utc_data->status_desc)=0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   FREE RECORD dddr_help
   RECORD dddr_help(
     1 help[2]
       2 option = vc
   )
   SET dddr_help->help[1].option = "DOWNTIME"
   SET dddr_help->help[2].option = "UPTIME"
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL text(2,3,"DDL Report Options")
   SET help =
   SELECT
    conversion_mode = dddr_help->help[d.seq].option
    FROM (dummyt d  WITH seq = 2)
    WITH nocounter
   ;end select
   CALL text(5,3,"For which mode do you want to view DDL Reports?")
   CALL accept(5,52,"A(8);CFU"," "
    WHERE curaccept IN ("UPTIME", "DOWNTIME"))
   SET dddr_accept = cnvtupper(curaccept)
   SET help = off
   SET message = nowindow
   IF (dddr_accept="UPTIME")
    SET dddr_run_id = dum_utc_data->uptime_run_id
    CALL echo(build("*** uptime run_id=",dddr_run_id))
   ELSE
    SET dddr_run_id = dum_utc_data->downtime_run_id
    CALL echo(build("*** downtime run_id=",dddr_run_id))
   ENDIF
   SET dm_err->eproc = "Searching for run_id in dm2_ddl_ops."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    ddo.op_id
    FROM dm2_ddl_ops ddo
    WHERE ddo.run_id=dddr_run_id
    DETAIL
     dddr_gen_dt_tm = ddo.gen_dt_tm, dddr_process_option = ddo.process_option, dddr_last_checkpoint
      = ddo.last_checkpoint
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dum_utc_data->status_desc = concat("There are no ddl operations to report for this run id.",
     "  Do you want to continue to the main menu?")
    IF (ducm_display_status_msg(dum_utc_data->status_desc)=0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   SET dm2rpting->prompt_mode = "PROMPT"
   SET dm2rpting->install_mode = "SCHEMA_DATE"
   SET dm2rpting->schema_date = format(dum_utc_data->schema_date,"DD-MMM-YYYY;;D")
   SET dm2rpting->package_number = 0
   SET dm2rpting->run_id = dddr_run_id
   SET dm2rpting->gen_dt_tm = dddr_gen_dt_tm
   SET dm2rpting->process_option = dddr_process_option
   SET dm2rpting->last_checkpoint = dddr_last_checkpoint
   EXECUTE dm2_ddl_reports
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_cleanup_tmp_cols(dctc_cleanup_done)
   DECLARE dctc_str = vc WITH protect, noconstant(" ")
   DECLARE dctc_loop = i4 WITH protect, noconstant(0)
   DECLARE dctc_loop2 = i4 WITH protect, noconstant(0)
   DECLARE dctc_rscbsy_retry = i4 WITH protect, noconstant(0)
   DECLARE dctc_rscbsy_max_retry = i4 WITH protect, constant(3)
   DECLARE dctc_failed_tbls = vc WITH protect, noconstant("")
   FREE RECORD dctc_cols
   RECORD dctc_cols(
     1 cnt = i4
     1 qual[*]
       2 ttbl_name = vc
       2 own_name = vc
       2 cols_cnt = i4
       2 cols[*]
         3 col_name = vc
   )
   FREE RECORD dctc_cons
   RECORD dctc_cons(
     1 cnt = i4
     1 qual[*]
       2 ttbl_name = vc
       2 own_name = vc
       2 cons_cnt = i4
       2 cons[*]
         3 con_name = vc
   )
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   WHILE ((dctc_rscbsy_retry < (dctc_rscbsy_max_retry+ 1)))
    IF (ducm_chk_tmp_notnull(null)=0)
     RETURN(0)
    ENDIF
    IF (dctc_rscbsy_retry <= dctc_rscbsy_max_retry)
     IF ((dctc_cons->cnt > 0))
      SET dm_err->eproc = concat(build(
        "Dropping not null constraints for UTC_TMP2* columns.  Retry : ",dctc_rscbsy_retry))
      CALL disp_msg(" ",dm_err->logfile,0)
      FOR (dctc_loop = 1 TO dctc_cons->cnt)
        SET dctc_str = concat('rdb asis (^alter table "',trim(dctc_cons->qual[dctc_loop].own_name),
         '"."',trim(dctc_cons->qual[dctc_loop].ttbl_name),'"')
        FOR (dctc_loop2 = 1 TO dctc_cons->qual[dctc_loop].cons_cnt)
          SET dctc_str = concat(dctc_str," drop constraint ",trim(dctc_cons->qual[dctc_loop].cons[
            dctc_loop2].con_name))
        ENDFOR
        SET dctc_str = concat(dctc_str," ^) go")
        IF (dm2_push_cmd(dctc_str,1)=0)
         IF ((dm_err->err_ind > 0)
          AND findstring("ORA-00054",dm_err->emsg) > 0)
          SET dm_err->err_ind = 0
         ELSE
          RETURN(0)
         ENDIF
        ENDIF
      ENDFOR
      SET dctc_rscbsy_retry = (dctc_rscbsy_retry+ 1)
     ELSE
      SET dctc_rscbsy_retry = (dctc_rscbsy_max_retry+ 1)
     ENDIF
    ENDIF
   ENDWHILE
   IF ((dctc_cons->cnt > 0))
    IF (ducm_chk_tmp_notnull(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dctc_cons->cnt=0))
    SET dctc_rscbsy_retry = 0
    WHILE ((dctc_rscbsy_retry < (dctc_rscbsy_max_retry+ 1)))
     IF (ducm_chk_tmp_default(null)=0)
      RETURN(0)
     ENDIF
     IF (dctc_rscbsy_retry <= dctc_rscbsy_max_retry)
      IF ((dctc_cols->cnt > 0))
       SET dm_err->eproc = concat(build("Setting UTC_TMP2* columns default to null.  Retry : ",
         dctc_rscbsy_retry))
       CALL disp_msg(" ",dm_err->logfile,0)
       FOR (dctc_loop = 1 TO dctc_cols->cnt)
         SET dctc_str = concat('rdb asis (^alter table "',trim(dctc_cols->qual[dctc_loop].own_name),
          '"."',trim(dctc_cols->qual[dctc_loop].ttbl_name),'" modify (')
         FOR (dctc_loop2 = 1 TO dctc_cols->qual[dctc_loop].cols_cnt)
           SET dctc_str = concat(dctc_str," ",trim(dctc_cols->qual[dctc_loop].cols[dctc_loop2].
             col_name)," default null,")
         ENDFOR
         SET dctc_str = concat(replace(dctc_str,",","",2),") ^) go")
         IF (dm2_push_cmd(dctc_str,1)=0)
          IF ((dm_err->err_ind > 0)
           AND findstring("ORA-00054",dm_err->emsg) > 0)
           SET dm_err->err_ind = 0
          ELSE
           RETURN(0)
          ENDIF
         ENDIF
       ENDFOR
       SET dctc_rscbsy_retry = (dctc_rscbsy_retry+ 1)
      ELSE
       SET dctc_rscbsy_retry = (dctc_rscbsy_max_retry+ 1)
      ENDIF
     ENDIF
    ENDWHILE
    IF ((dctc_cols->cnt > 0))
     IF (ducm_chk_tmp_default(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((((dctc_cons->cnt > 0)) OR ((dctc_cols->cnt > 0))) )
    IF ((dctc_cons->cnt > 0))
     FOR (dctc_loop = 1 TO dctc_cons->cnt)
       IF (dctc_failed_tbls="")
        SET dctc_failed_tbls = concat(dctc_cons->qual[dctc_loop].ttbl_name,","," ")
       ELSE
        SET dctc_failed_tbls = concat(dctc_failed_tbls,dctc_cons->qual[dctc_loop].ttbl_name,","," ")
       ENDIF
     ENDFOR
    ENDIF
    IF ((dctc_cols->cnt > 0))
     FOR (dctc_loop = 1 TO dctc_cols->cnt)
       IF (dctc_failed_tbls="")
        SET dctc_failed_tbls = concat(dctc_cols->qual[dctc_loop].ttbl_name,","," ")
       ELSE
        SET dctc_failed_tbls = concat(dctc_failed_tbls,dctc_cols->qual[dctc_loop].ttbl_name,","," ")
       ENDIF
     ENDFOR
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dctc_failed_tbls = ",dctc_failed_tbls))
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Conversion Cleanup step failed."
    SET dm_err->emsg = concat(
     "Failed to modify UTC_TMP2* columns due to Oracle resource busy error on tables : ",replace(
      dctc_failed_tbls,",",". ",2)," Please Select Step 5 again to complete post conversion cleanup."
     )
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dctc_cleanup_done = 0
    RETURN(0)
   ELSE
    SET dctc_cleanup_done = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_chk_tmp_notnull(null)
   DECLARE dctn_idx = i4 WITH protect, noconstant(0)
   DECLARE dctn_tbl_fnd = i4 WITH protect, noconstant(0)
   SET dctc_cons->cnt = 0
   SET stat = alterlist(dctc_cons->qual,0)
   SET dm_err->eproc = "Get NOT NULL constraints for UTC_TMP2* columns."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_constraints uc,
     dba_cons_columns ucc
    PLAN (uc
     WHERE uc.constraint_type="C")
     JOIN (ucc
     WHERE ucc.constraint_name=uc.constraint_name
      AND ucc.table_name=uc.table_name
      AND ucc.column_name="UTC_TMP2*"
      AND ucc.owner=uc.owner
      AND expand(dctn_idx,1,dus_user_list->own_cnt,uc.owner,dus_user_list->own[dctn_idx].owner_name))
    ORDER BY uc.owner, uc.table_name
    HEAD uc.owner
     row + 0
    HEAD uc.table_name
     row + 0
    DETAIL
     dctc_str = cnvtupper(trim(trim(uc.search_condition,3),4))
     IF (findstring("ISNOTNULL",dctc_str) > 0)
      dctn_tbl_fnd = 0, dctn_tbl_fnd = locateval(dctn_tbl_fnd,1,dctc_cons->cnt,uc.owner,dctc_cons->
       qual[dctn_tbl_fnd].own_name,
       uc.table_name,dctc_cons->qual[dctn_tbl_fnd].ttbl_name)
      IF (dctn_tbl_fnd=0)
       dctc_cons->cnt = (dctc_cons->cnt+ 1)
       IF (mod(dctc_cons->cnt,100)=1)
        stat = alterlist(dctc_cons->qual,(dctc_cons->cnt+ 99))
       ENDIF
       dctc_cons->qual[dctc_cons->cnt].ttbl_name = uc.table_name, dctc_cons->qual[dctc_cons->cnt].
       own_name = uc.owner, dctn_tbl_fnd = dctc_cons->cnt
      ENDIF
      dctc_cons->qual[dctn_tbl_fnd].cons_cnt = (dctc_cons->qual[dctn_tbl_fnd].cons_cnt+ 1), stat =
      alterlist(dctc_cons->qual[dctn_tbl_fnd].cons,dctc_cons->qual[dctn_tbl_fnd].cons_cnt), dctc_cons
      ->qual[dctn_tbl_fnd].cons[dctc_cons->qual[dctn_tbl_fnd].cons_cnt].con_name = uc.constraint_name
     ENDIF
    FOOT REPORT
     stat = alterlist(dctc_cons->qual,dctc_cons->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dctc_cons)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_chk_tmp_default(null)
   DECLARE dctd_tbl_fnd = i4 WITH protect, noconstant(0)
   SET dctc_cols->cnt = 0
   SET stat = alterlist(dctc_cols->qual,0)
   SET dm_err->eproc = "Get defaults for UTC_TMP2* columns."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_tab_columns utc
    WHERE utc.column_name="UTC_TMP2*"
     AND utc.data_default IS NOT null
     AND  EXISTS (
    (SELECT
     "x"
     FROM dba_tables dt
     WHERE utc.owner=dt.owner
      AND utc.table_name=dt.table_name))
    ORDER BY utc.owner, utc.table_name
    HEAD utc.owner
     row + 0
    HEAD utc.table_name
     row + 0
    DETAIL
     IF (trim(cnvtupper(utc.data_default)) != "NULL")
      dctd_tbl_fnd = 0, dctd_tbl_fnd = locateval(dctd_tbl_fnd,1,dctc_cols->cnt,utc.owner,dctc_cols->
       qual[dctd_tbl_fnd].own_name,
       utc.table_name,dctc_cols->qual[dctd_tbl_fnd].ttbl_name)
      IF (dctd_tbl_fnd=0)
       dctc_cols->cnt = (dctc_cols->cnt+ 1)
       IF (mod(dctc_cols->cnt,100)=1)
        stat = alterlist(dctc_cols->qual,(dctc_cols->cnt+ 99))
       ENDIF
       dctc_cols->qual[dctc_cols->cnt].ttbl_name = utc.table_name, dctc_cols->qual[dctc_cols->cnt].
       own_name = utc.owner, dctd_tbl_fnd = dctc_cols->cnt
      ENDIF
      dctc_cols->qual[dctd_tbl_fnd].cols_cnt = (dctc_cols->qual[dctd_tbl_fnd].cols_cnt+ 1), stat =
      alterlist(dctc_cols->qual[dctd_tbl_fnd].cols,dctc_cols->qual[dctd_tbl_fnd].cols_cnt), dctc_cols
      ->qual[dctd_tbl_fnd].cols[dctc_cols->qual[dctd_tbl_fnd].cols_cnt].col_name = utc.column_name
     ENDIF
    FOOT REPORT
     stat = alterlist(dctc_cols->qual,dctc_cols->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dctc_cols)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 IF ((dm_err->debug_flag < 1))
  SET message = noinformation
 ENDIF
 IF ((dm_err->err_ind > 0))
  SET ducm_hold_err_ind = dm_err->err_ind
  SET ducm_hold_err_proc = dm_err->eproc
  SET ducm_hold_err_msg = dm_err->emsg
 ENDIF
 CALL dctx_set_context("FIRE_REFCHG_TRG","YES")
 CALL dctx_set_context("FIRE_EA_TRG","YES")
 SET message = information
 IF (ducm_hold_err_ind > 0)
  SET dm_err->err_ind = ducm_hold_err_ind
  SET dm_err->eproc = ducm_hold_err_proc
  SET dm_err->emsg = ducm_hold_err_msg
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
 ENDIF
 SET dm_err->eproc = "DM2_UTC_CONVERT_MAIN Completed."
 CALL final_disp_msg(ducm_logfile_prefix)
END GO
