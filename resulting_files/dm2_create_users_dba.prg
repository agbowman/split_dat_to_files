CREATE PROGRAM dm2_create_users:dba
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
 DECLARE dcdur_create_db_users(null) = i2
 DECLARE dcdur_report_db_users_diff_tspaces(null) = i2
 DECLARE dcdur_cleanup_pwds(dcp_in_dbname=vc) = i2
 DECLARE dcdur_insert_pwds(dip_in_dbname=vc,dip_in_type=vc,dip_in_user=vc,dip_in_pwd=vc) = i2
 DECLARE dcdur_preserve_pwds(dpp_in_dbname=vc) = i2
 DECLARE dcdur_restore_pwds(drp_in_dbname=vc,drp_in_mode=vc) = i2
 DECLARE dcdur_get_server_users_pwds(dgsup_in_domain=vc) = i2
 DECLARE dcdur_prompt_tspaces(dpt_user_name=vc,dpt_db_name=vc,dpt_user_idx=i4(ref)) = i2
 DECLARE dcdur_user_tspace_cleanup(dutc_user_name=vc,dutc_db_name=vc) = i2
 DECLARE dcdur_user_tspace_load(dutl_db_name=vc) = i2
 DECLARE dcdur_insert_admin_tspace_rows(diatr_user_name=vc,diatr_db_name=vc,diatr_temp_ts=vc,
  diatr_misc_ts=vc) = i2
 DECLARE dcdur_get_db_owner_pwds(dgdop_in_dbname=vc) = i2
 IF (validate(dcdur_input->src_user,"ABC")="ABC"
  AND validate(dcdur_input->src_user,"XYZ")="XYZ")
  FREE RECORD dcdur_input
  RECORD dcdur_input(
    1 src_user = vc
    1 src_pwd = vc
    1 src_cnct_str = vc
    1 tgt_user = vc
    1 tgt_pwd = vc
    1 tgt_cnct_str = vc
    1 user_list = vc
    1 fix_tspaces_ind = c1
    1 default_tspace = vc
    1 temp_tspace = vc
    1 tgt_dbname = vc
    1 connect_back = c1
    1 replace_tspaces = c1
    1 replace_pwds = c1
  )
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_pwd = ""
  SET dcdur_input->src_cnct_str = ""
  SET dcdur_input->tgt_user = ""
  SET dcdur_input->tgt_pwd = ""
  SET dcdur_input->tgt_cnct_str = ""
  SET dcdur_input->fix_tspaces_ind = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->user_list = ""
  SET dcdur_input->tgt_dbname = ""
  SET dcdur_input->connect_back = ""
  SET dcdur_input->replace_tspaces = ""
  SET dcdur_input->replace_pwds = ""
 ENDIF
 IF (validate(dcdur_server_pwds->cnt,1)=1
  AND validate(dcdur_server_pwds->cnt,2)=2)
  FREE RECORD dcdur_server_pwds
  RECORD dcdur_server_pwds(
    1 cnt = i4
    1 qual[*]
      2 server = i4
      2 user = vc
      2 pwd = vc
  )
  SET dcdur_server_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_owner_pwds->cnt,1)=1
  AND validate(dcdur_owner_pwds->cnt,2)=2)
  FREE RECORD dcdur_owner_pwds
  RECORD dcdur_owner_pwds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 owner = vc
      2 pwd = vc
  )
  SET dcdur_owner_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_cmds->cnt,1)=1
  AND validate(dcdur_cmds->cnt,2)=2)
  FREE RECORD dcdur_cmds
  RECORD dcdur_cmds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 name = vc
      2 command = vc
      2 owner = vc
      2 default_tspace = vc
      2 temp_tspace = vc
      2 pwd = vc
      2 default_tspace_quota = vc
  )
  SET dcdur_cmds->cnt = 0
 ENDIF
 IF (validate(dcdur_user_data->misc_tspace_default,"X")="X"
  AND validate(dcdur_user_data->misc_tspace_default,"Y")="Y")
  FREE RECORD dcdur_user_data
  RECORD dcdur_user_data(
    1 misc_tspace_default = vc
    1 temp_tspace_default = vc
    1 misc_tspace_force = vc
    1 temp_tspace_force = vc
    1 user_cnt = i4
    1 users[*]
      2 user = vc
      2 misc_tspace = vc
      2 temp_tspace = vc
    1 tgt_sys_user = vc
    1 tgt_sys_pwd = vc
    1 create_user_method = vc
  )
  SET dcdur_user_data->misc_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->misc_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->tgt_sys_user = "SYS"
  SET dcdur_user_data->tgt_sys_pwd = "DM2NOTSET"
  SET dcdur_user_data->create_user_method = "DM2NOTSET"
  SET dcdur_user_data->user_cnt = 0
 ENDIF
 SUBROUTINE dcdur_create_db_users(null)
   DECLARE dcdu_iter = i4 WITH protect, noconstant(0)
   DECLARE dcdu_beg = i2 WITH protect, noconstant(0)
   DECLARE dcdu_end = i2 WITH protect, noconstant(0)
   DECLARE dcdu_str = vc WITH protect, noconstant(" ")
   DECLARE dcdu_grant_ptr = i2 WITH protect, noconstant(1)
   DECLARE dcdu_start_ptr = i2 WITH protect, noconstant(0)
   DECLARE dcdu_ndx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_index1 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_index2 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_parse_cmd = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_string = vc WITH protect, noconstant("")
   DECLARE dcdu_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_str_length = i4 WITH protect, noconstant(0)
   DECLARE dcdu_user_list = vc WITH protect, noconstant("")
   DECLARE dcdu_fix_tspaces_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_replace_from = vc WITH protect, noconstant("")
   DECLARE dcdu_replace_to = vc WITH protect, noconstant("")
   DECLARE dcdu_func_owner = vc WITH protect, noconstant("")
   DECLARE dcdu_func_name = vc WITH protect, noconstant("")
   DECLARE dcdu_create_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_idx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_db_user_pwd = vc WITH protect, noconstant("")
   DECLARE dcdu_default_tspace = vc WITH protect, noconstant("")
   DECLARE dcdu_role_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_adb_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_owner = vc WITH protect, noconstant("")
   FREE RECORD dcdu_orauser
   RECORD dcdu_orauser(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 default_tspace = vc
       2 temp_tspace = vc
       2 dt_fix_ind = i2
       2 tt_fix_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   SET dcdur_cmds->cnt = 0
   SET stat = alterlist(dcdur_cmds->qual,0)
   SET dcdur_input->connect_back = "N"
   IF (dm2_adb_check("",dcdu_adb_ind)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Creating database users and all dependent objects."
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dcdur_input->src_user))=0) OR (((size(trim(dcdur_input->src_pwd))=0) OR (((size(
    trim(dcdur_input->src_cnct_str))=0) OR (((size(trim(dcdur_input->tgt_user))=0) OR (((size(trim(
     dcdur_input->tgt_pwd))=0) OR (((size(trim(dcdur_input->tgt_cnct_str))=0) OR ((( NOT ((
   dcdur_input->replace_tspaces IN ("Y", "N")))) OR ((( NOT ((dcdur_input->replace_pwds IN ("Y", "N")
   ))) OR ((( NOT ((dcdur_input->fix_tspaces_ind IN ("Y", "N")))) OR ((((dcdur_input->fix_tspaces_ind
   ="Y")
    AND size(trim(dcdur_input->default_tspace))=0) OR ((((dcdur_input->fix_tspaces_ind="Y")
    AND size(trim(dcdur_input->temp_tspace))=0) OR (((trim(dcdur_input->user_list)="") OR (findstring
   ("(",dcdur_input->user_list,1) > 0)) )) )) )) )) )) )) )) )) )) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input variables."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = concat("Using DBMS_METADATA method to create [",trim(dcdur_input->user_list),
    "] users.")
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdur_input->connect_back = "Y"
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"SOURCE"'
   SET dm2_install_schema->u_name = dcdur_input->src_user
   SET dm2_install_schema->p_word = dcdur_input->src_pwd
   SET dm2_install_schema->connect_str = dcdur_input->src_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET stat = alterlist(dcdu_orauser->qual,0)
   SET dcdu_orauser->cnt = 0
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_users du
     WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     ORDER BY du.username
     DETAIL
      dcdu_orauser->cnt = (dcdu_orauser->cnt+ 1), stat = alterlist(dcdu_orauser->qual,dcdu_orauser->
       cnt), dcdu_orauser->qual[dcdu_orauser->cnt].user = du.username,
      dcdu_orauser->qual[dcdu_orauser->cnt].default_tspace = du.default_tablespace, dcdu_orauser->
      qual[dcdu_orauser->cnt].temp_tspace = du.temporary_tablespace, dcdu_orauser->qual[dcdu_orauser
      ->cnt].dt_fix_ind = 0,
      dcdu_orauser->qual[dcdu_orauser->cnt].tt_fix_ind = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdu_orauser)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for role exclusion list override."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.info_name
    FROM dm_info d
    WHERE info_domain="DM2_ROLE_EXLUSION_LIST_OVERRIDE"
    DETAIL
     dcdu_where_clause = concat("r.grantee not in(",d.info_name,")")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdu_where_clause <= "")
    SET dcdu_where_clause = concat(
     "r.grantee not in('CONNECT','RESOURCE','DBA','EXP_FULL_DATABASE','IMP_FULL_DATABASE',",
     "'DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','SELECT_CATALOG_ROLE',",
     "'RECOVERY_CATALOG_OWNER','HS_ADMIN_ROLE','AQ_USER_ROLE','AQ_ADMINISTRATOR_ROLE',",
     "'SNMPAGENT','SCHEDULER_ADMIN')")
   ENDIF
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve Source DDL to create Functions, Profiles, Users, Roles and Grants."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((validate(dm2_bypass_get_pwd_function_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source dependent functions' DDL used in the PASSWORD_VERIFY_FUNCTION function ",
     "of profiles for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.referenced_name, dp.referenced_owner)")
       FROM (
        (
        (SELECT DISTINCT
         d.referenced_name, d.referenced_owner
         FROM dba_profiles p,
          dba_objects o,
          dba_dependencies d
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          du.profile
          FROM dba_users du
          WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
          AND o.object_name=d.name
          AND d.referenced_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
    SET dm_err->eproc = concat(
     "Get all Source PASSWORD_VERIFY_FUNCTION functions' DDL used during create ",
     "profile for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.object_name, dp.owner)")
       FROM (
        (
        (SELECT DISTINCT
         o.object_name, o.owner
         FROM dba_profiles p,
          dba_objects o
         WHERE p.profile != "DEFAULT"
          AND p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_profiles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create/alter profile DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('PROFILE', dp.profile)")
       FROM (
        (
        (SELECT DISTINCT
         p.profile
         FROM dba_profiles p
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))))
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "PROFILE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_users_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create user DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
       WITH sqltype("C32000")))
      a)
     DETAIL
      IF ((dm_err->debug_flag > 4))
       CALL echo(concat("x = ",a.x))
      ENDIF
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),"")
       IF ((dm_err->debug_flag > 4))
        CALL echo(concat("dcdu_cmd_string = ",dcdu_cmd_string))
       ENDIF
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_beg =",dcdu_beg))
          ENDIF
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_grant_ptr =",dcdu_grant_ptr)),
           CALL echo(build("dcdu_start_ptr =",dcdu_start_ptr))
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2)
          IF ((dm_err->debug_flag > 4))
           CALL echo(concat("dcdu_parse_cmd = ",dcdu_parse_cmd))
          ENDIF
          dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,
           dcdur_cmds->qual[dcdu_index2].command)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_index2 = ",dcdu_index2))
          ENDIF
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].owner = dcdur_cmds->qual[dcdur_cmds->cnt].name,
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "USER", dcdur_cmds->qual[dcdur_cmds->cnt].command
            = dcdu_parse_cmd
           IF (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].default_tspace = substring((findstring(
              "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20)+ 1
              )) - (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 20)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].temp_tspace = substring((findstring(
              "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
              + 1)) - (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 22)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(findstring("'",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring("IDENTIFIED BY VALUES '",
               dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)+ 1)) - (findstring(
              "IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
             ),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   SET dcdu_role_where_clause = " 1=1 "
   IF ((dm2_rdbms_version->level1 > 11))
    SET dcdu_role_where_clause = " u.COMMON='NO' "
   ENDIF
   IF ((validate(dm2_bypass_get_roles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get all Source create role DDL (i.e. create role <role>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('ROLE', ROLE)")
       FROM dba_roles u
       WHERE parser(dcdu_role_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2), dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,
           dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "ROLE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_role_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for all roles (i.e. grant <role> to <role>) excluding default roles."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', r.grantee)")
       FROM dba_role_privs r
       WHERE r.grantee IN (
       (SELECT
        x.role
        FROM dba_roles x))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_system_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source system priv grant DDL for all roles (i.e. grant <sys priv> to <role>)",
     "excluding default roles.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', r.grantee)")
       FROM dba_sys_privs r
       WHERE r.grantee IN (
       (SELECT
        u.role
        FROM dba_roles u
        WHERE parser(dcdu_role_where_clause)))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_role_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for user(s) specified (i.e. grant <role> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_role_privs drp
        WHERE drp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT"
           IF (findstring('"DBA"',dcdu_parse_cmd) > 0
            AND dcdu_adb_ind=1)
            dcdu_parse_cmd = replace(dcdu_parse_cmd,'"DBA"','"PDB_DBA"')
           ENDIF
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_system_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source sys priv grant DDL (not role) for user(s) specified (i.e. grant <sys priv> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_sys_privs dsp
        WHERE dsp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_table_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Retrieve Source DDL for SYS object grants on user(s) specified."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tab_privs dtp
     WHERE dtp.owner="SYS"
      AND parser(concat("dtp.grantee in (",dcdur_input->user_list,")"))
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdur_cmds->qual[dcdur_cmds->cnt].type = "TABLE GRANT",
      dcdur_cmds->qual[dcdur_cmds->cnt].owner = dtp.owner, dcdur_cmds->qual[dcdur_cmds->cnt].name =
      dtp.table_name
      IF (dtp.privilege IN ("READ", "WRITE"))
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),
        ' ON DIRECTORY "',trim(dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ELSE
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),' ON "',trim(
         dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for Source users default tablespaces with unlimited quota."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_ts_quotas dtq,
     dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     AND du.username=dtq.username
     AND du.default_tablespace=dtq.tablespace_name
     AND (dtq.max_bytes=- (1))
    DETAIL
     dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,"USER",dcdur_cmds->qual[
      dcdu_index1].type,
      du.username,dcdur_cmds->qual[dcdu_index1].owner,du.default_tablespace,dcdur_cmds->qual[
      dcdu_index1].default_tspace)
     IF (dcdu_index1 > 0)
      dcdur_cmds->qual[dcdu_index1].default_tspace_quota = "Y"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_cmds)
   ENDIF
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"TARGET"'
   SET dm2_install_schema->u_name = dcdur_input->tgt_user
   SET dm2_install_schema->p_word = dcdur_input->tgt_pwd
   SET dm2_install_schema->connect_str = dcdur_input->tgt_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dcdur_input->connect_back = "N"
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieving Target tablespaces from dba_tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     dt.tablespace_name
     FROM dba_tablespaces dt
     DETAIL
      dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
       cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dcdu_iter = 1 TO dcdu_orauser->cnt)
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].
       default_tspace,dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].dt_fix_ind = 1
      ENDIF
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].temp_tspace,
       dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].tt_fix_ind = 1
      ENDIF
    ENDFOR
    IF (dcdu_fix_tspaces_ind=1)
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dcdu_orauser)
     ENDIF
    ELSE
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ENDIF
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,
       " user exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users u
       WHERE u.username=cnvtupper(dcdur_cmds->qual[dcdu_iter].owner)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dcdu_cmd_string = dcdur_cmds->qual[dcdu_iter].command
       IF (dcdu_fix_tspaces_ind=1)
        SET dcdu_ndx = 0
        SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_orauser->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         dcdu_orauser->qual[dcdu_ndx].user)
        IF (dcdu_ndx > 0)
         IF ((dcdu_orauser->qual[dcdu_ndx].dt_fix_ind=1))
          SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           default_tspace,'"')
          SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_input->default_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
         IF ((dcdu_orauser->qual[dcdu_ndx].tt_fix_ind=1))
          SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           temp_tspace,'"')
          SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_input->temp_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
        ENDIF
       ENDIF
       IF ((dcdur_input->replace_tspaces="Y"))
        SET dcdu_idx = 0
        IF (dcdur_prompt_tspaces(dcdur_cmds->qual[dcdu_iter].owner,dcdur_input->tgt_dbname,dcdu_idx)=
        0)
         RETURN(0)
        ENDIF
        SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         default_tspace,'"')
        SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         misc_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
        SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         temp_tspace,'"')
        SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         temp_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
       ENDIF
       IF ((dcdur_input->replace_pwds="Y"))
        SET dcdu_idx = 0
        SET dcdu_idx = locateval(dcdu_idx,1,dir_db_users_pwds->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         replace(dir_db_users_pwds->qual[dcdu_idx].user,"'","",0))
        SET dcdu_db_user_pwd = dir_db_users_pwds->qual[dcdu_idx].pwd
        SET dcdu_cmd_string = replace(dcdu_cmd_string,concat("'",dcdur_cmds->qual[dcdu_iter].pwd,"'"),
         concat('"',dcdu_db_user_pwd,'"'),0)
        SET dcdu_cmd_string = replace(dcdu_cmd_string,"IDENTIFIED BY VALUES","IDENTIFIED BY",0)
       ENDIF
       IF (dm2_push_cmd(build("rdb asis(^",dcdu_cmd_string,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,
         " user already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="ROLE"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
       " role exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_roles u
       WHERE u.role=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name," role already exists in TARGET."
         )
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="PROFILE"))
      SET dcdu_create_ind = 1
      IF (findstring("CREATE PROFILE",dcdur_cmds->qual[dcdu_iter].command,1,0) > 0)
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
        " profile exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_profiles p
        WHERE p.profile=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual > 0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name,
          " profile already exists in TARGET.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="FUNCTION"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
       dcdu_iter].name," function exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_objects o
       WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
        AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        AND o.object_type="FUNCTION"
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[dcdu_iter].
         name," function already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSE
      SET dcdu_create_ind = 1
      IF ((dcdur_cmds->qual[dcdu_iter].type="TABLE GRANT"))
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
        dcdu_iter].name," object exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_objects o
        WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
         AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat("No ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
          dcdu_iter].name," object found in TARGET, skipping TABLE GRANT command.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        SET dm_err->err_ind = 0
        SET dm_err->eproc = "THE ABOVE ERROR MESSAGE IS IGNORABLE"
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER")
      AND (dcdur_cmds->qual[dcdu_iter].default_tspace_quota="Y"))
      SET dm_err->eproc = concat("Obtain default tablespace for [",dcdur_cmds->qual[dcdu_iter].owner,
       "] user.")
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users du
       WHERE (du.username=dcdur_cmds->qual[dcdu_iter].owner)
       DETAIL
        dcdu_default_tspace = du.default_tablespace
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET dm_err->eproc = concat("Give unlimited tablespace quota to ",dcdur_cmds->qual[dcdu_iter].
       owner," user's default tablespace [",trim(dcdu_default_tspace),"].")
      CALL disp_msg(" ",dm_err->logfile,10)
      IF (dm2_push_cmd(concat("rdb asis(^alter user ",dcdur_cmds->qual[dcdu_iter].owner,
        " quota unlimited on ",trim(dcdu_default_tspace),"^) go"),1)=0)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_report_db_users_diff_tspaces(null)
   DECLARE drdudt_ndx = i4 WITH protect, noconstant(0)
   DECLARE drdudt_ndx2 = i4 WITH protect, noconstant(0)
   DECLARE drdudt_diff_tspace = i2 WITH protect, noconstant(0)
   DECLARE drdudt_str = vc WITH protect, noconstant(" ")
   DECLARE drdudt_file = vc WITH protect, noconstant("")
   FREE RECORD drdudt_user_tsp
   RECORD drdudt_user_tsp(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 create_dt_tm = dq8
       2 src_default_tspace = vc
       2 src_temp_tspace = vc
       2 tgt_default_tspace = vc
       2 tgt_temp_tspace = vc
       2 dt_diff_ind = i2
       2 tt_diff_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   IF ((dcdur_input->fix_tspaces_ind != "Y"))
    RETURN(1)
   ENDIF
   IF (((size(trim(dcdur_input->default_tspace))=0) OR (((size(trim(dcdur_input->temp_tspace))=0) OR
   (size(trim(dcdur_input->user_list))=0)) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users@ref_data_link du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_user_tsp->cnt = (drdudt_user_tsp->cnt+ 1), stat = alterlist(drdudt_user_tsp->qual,
      drdudt_user_tsp->cnt), drdudt_user_tsp->qual[drdudt_user_tsp->cnt].user = du.username,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_default_tspace = du.default_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_temp_tspace = du.temporary_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_default_tspace = "",
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_temp_tspace = "", drdudt_user_tsp->qual[
     drdudt_user_tsp->cnt].dt_diff_ind = 0, drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tt_diff_ind
      = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving tablespaces from dba_tablespaces."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    dt.tablespace_name
    FROM dba_tablespaces dt
    DETAIL
     dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
      cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Target custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_ndx = 0, drdudt_ndx = locateval(drdudt_ndx,1,drdudt_user_tsp->cnt,du.username,
      drdudt_user_tsp->qual[drdudt_ndx].user)
     IF (drdudt_ndx > 0)
      drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace = du.default_tablespace, drdudt_user_tsp->
      qual[drdudt_ndx].tgt_temp_tspace = du.temporary_tablespace, drdudt_user_tsp->qual[drdudt_ndx].
      create_dt_tm = du.created,
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_default_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_default_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_default_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace=dcdur_input->default_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].dt_diff_ind = 1
      ENDIF
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_temp_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_temp_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_temp_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_temp_tspace=dcdur_input->temp_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].tt_diff_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drdudt_user_tsp)
   ENDIF
   IF (drdudt_diff_tspace=1)
    IF (get_unique_file("dm2_db_user_tspace",".rpt")=0)
     RETURN(0)
    ENDIF
    SET drdudt_file = dm_err->unique_fname
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET drdudt_file = build(drrr_misc_data->active_dir,drdudt_file)
    ENDIF
    SET dm_err->eproc = concat(
     "Reporting Target Database users having different default/temporary tablespaces then Source (",
     trim(drdudt_file),").")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO value(drdudt_file)
     FROM (dummyt t  WITH seq = drdudt_user_tsp->cnt)
     HEAD REPORT
      col 50, "Database Users Missing Default/Temporary Tablespaces", row + 2,
      row + 1, drdudt_str = concat(
       "The following reports Source database users created in Target with different default and/or ",
       " temporary tablespaces due to the tablespaces not existing in Target."), col 0,
      drdudt_str, row + 2, row + 1,
      col 0, "Missing Default Tablespace replaced with: ", dcdur_input->default_tspace,
      row + 2, col 0, "Missing Temporary Tablespace replaced with: ",
      dcdur_input->temp_tspace, row + 2, row + 1,
      col 0, "A Default/Temporary Tablespace of '-' denotes no differences.", row + 2,
      row + 1, col 0, "User",
      col 35, "Created", col 70,
      "Source Default Tablespace", col 105, "Source Temporary Tablespace",
      row + 1, col 0, "------------------------------",
      col 35, "------------------------------", col 70,
      "------------------------------", col 105, "------------------------------",
      row + 1
     DETAIL
      IF ((((drdudt_user_tsp->qual[t.seq].dt_diff_ind=1)) OR ((drdudt_user_tsp->qual[t.seq].
      tt_diff_ind=1))) )
       drdudt_str = drdudt_user_tsp->qual[t.seq].user, col 0, drdudt_str,
       drdudt_str = format(cnvtdatetime(drdudt_user_tsp->qual[t.seq].create_dt_tm),";;q"), col 35,
       drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].dt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_default_tspace,"-"), col 70, drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].tt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_temp_tspace,"-"), col 105, drdudt_str,
       row + 1
      ENDIF
     WITH nocounter, maxcol = 250, format = variable,
      formfeed = none, maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = concat(
      "Skipping display of Database Users Missing Default/Temporary Tablespaces Report (",trim(
       drdudt_file,3),")")
     CALL disp_msg("",dm_err->logfile,0)
     IF ((drer_email_list->email_cnt > 0))
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was generated at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Please review the report to ensure desired Default/Temporary Tablespaces",
        " are used for each user."),0)
      CALL drer_add_body_text(concat("Report file name is : ",drdudt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
    ELSE
     IF ((dm2_install_schema->process_option="CLIN COPY")
      AND (drer_email_list->email_cnt > 0))
      SET drer_email_det->process = drr_clin_copy_data->process
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "PAUSED"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was displayed at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Return to dm2_domain_maint main session and review ",
        "Database Users Missing Default/Temporary Tablespaces report displayed on the screen.  Press <enter> to continue."
        ),0)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",drdudt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
     IF (dm2_disp_file(drdudt_file,"Database Users Missing Default/Temporary Tablespaces")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_cleanup_pwds(dcp_in_dbname)
   SET dm_err->eproc = concat("Delete password data in Admin DM_INFO for database ",dcp_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
     AND di.info_name=patstring(cnvtupper(build(dcp_in_dbname,"*")))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_insert_pwds(dip_in_dbname,dip_in_type,dip_in_user,dip_in_pwd)
   DECLARE dip_scrambled_pwd = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Insert user password rows for database ",dip_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dip_in_dbname))=0) OR (((size(trim(dip_in_type))=0) OR (((size(trim(dip_in_user))=
   0) OR (size(trim(dip_in_pwd))=0)) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria for insert of password."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dip_scrambled_pwd = dip_in_pwd
   IF (dip_in_type IN ("LOGIN", "SERVER"))
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 1
    SET dm2scramble->in_text = dip_in_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
    SET dip_scrambled_pwd = dm2scramble->out_text
   ENDIF
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
        dip_in_dbname),"-",trim(dip_in_type),"-",trim(dip_in_user))), di.info_char =
     dip_scrambled_pwd,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc) > 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE dcdur_preserve_pwds(dpp_in_dbname)
   DECLARE dpp_idx = i2 WITH protect, noconstant(0)
   DECLARE dpp_cmd_string = vc WITH protect, noconstant("")
   DECLARE dpp_iter = i4 WITH protect, noconstant(0)
   DECLARE dpp_owner = vc WITH protect, noconstant("")
   DECLARE dpp_str = vc WITH protect, noconstant("")
   DECLARE dpp_env = vc WITH protect, noconstant("")
   DECLARE dpp_domain = vc WITH protect, noconstant("")
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve CREATE USER DDL to retrieve password values."
   SELECT INTO "nl:"
    FROM (
     (
     (SELECT
      x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
      FROM dba_users u
      WHERE u.username != "XS$NULL"
      WITH sqltype("C32000")))
     a)
    DETAIL
     IF (findstring(";",trim(a.x,3),1) > 0)
      dpp_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
      dpp_owner = substring((findstring('"',dpp_cmd_string,1)+ 1),((findstring('"',dpp_cmd_string,(
        findstring('"',dpp_cmd_string,1)+ 1)) - findstring('"',dpp_cmd_string,1)) - 1),dpp_cmd_string
       ), dpp_idx = 0,
      dpp_idx = locateval(dpp_idx,1,dcdur_owner_pwds->cnt,dpp_owner,dcdur_owner_pwds->qual[dpp_idx].
       owner)
      IF (dpp_idx=0)
       IF (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1) > 0)
        dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1), stat = alterlist(dcdur_owner_pwds->qual,
         dcdur_owner_pwds->cnt), dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "DB",
        dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dpp_owner, dcdur_owner_pwds->qual[
        dcdur_owner_pwds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
         + 22),(findstring("'",dpp_cmd_string,((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
          + 22)+ 1)) - (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)+ 22)),dpp_cmd_string)
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   SET dm_err->eproc = "Get environment name."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dpp_env = cnvtlower(trim(logical("environment")))
   IF (trim(dpp_env) > " ")
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("ENVIRONMENT LOGICAL:",dpp_env))
    ENDIF
   ELSE
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dpp_str = concat("\\environment\\",dpp_env," Domain")
   IF (ddr_lreg_oper("GET",dpp_str,dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dpp_domain="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve domain name property for ",dpp_env)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdur_get_server_users_pwds(dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dcdur_get_db_owner_pwds(dpp_in_dbname)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_owner_pwds->cnt > 0))
    FOR (dpp_iter = 1 TO dcdur_owner_pwds->cnt)
      IF ((dcdur_owner_pwds->qual[dpp_iter].type IN ("LOGIN", "SERVER")))
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 1
       SET dm2scramble->in_text = dcdur_owner_pwds->qual[dpp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
       SET dcdur_owner_pwds->qual[dpp_iter].pwd = dm2scramble->out_text
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
    IF (dcdur_cleanup_pwds(dpp_in_dbname)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert user password rows for database ",dpp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(dcdur_owner_pwds->cnt))
     SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
         dpp_in_dbname),"-",trim(dcdur_owner_pwds->qual[d.seq].type),"-",trim(dcdur_owner_pwds->qual[
         d.seq].owner))), di.info_char = dcdur_owner_pwds->qual[d.seq].pwd,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d
      WHERE d.seq > 0)
      JOIN (di)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc) > 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_restore_pwds(drp_in_dbname,drp_in_mode)
   DECLARE drp_idx = i2 WITH protect, noconstant(0)
   DECLARE drp_cmd_string = vc WITH protect, noconstant("")
   DECLARE drp_iter = i4 WITH protect, noconstant(0)
   DECLARE drp_str = vc WITH protect, noconstant("")
   DECLARE drp_issue_cmds = i2 WITH protect, noconstant(0)
   DECLARE drp_owner = vc WITH protect, noconstant("")
   DECLARE drp_sea = vc WITH protect, noconstant("")
   DECLARE drp_file = vc WITH protect, noconstant("")
   DECLARE drp_tmp_pwd = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drp_env = vc WITH protect, noconstant("")
   DECLARE drp_domain = vc WITH protect, noconstant("")
   DECLARE drp_ret_val = vc WITH protect, noconstant("")
   DECLARE drp_tmp_owner = vc WITH protect, noconstant("")
   FREE RECORD drp_pwds
   RECORD drp_pwds(
     1 cnt = i4
     1 qual[*]
       2 owner = vc
       2 pwd = vc
   )
   FREE RECORD drp_cmds
   RECORD drp_cmds(
     1 cnt = i4
     1 qual[*]
       2 command = vc
       2 owner = vc
       2 common = vc
       2 oracle_maintained = vc
       2 pwd = vc
       2 issue_cmd = i2
   )
   IF (drp_in_mode IN ("SERVERS", "ALL"))
    SET dm_err->eproc = "Get environment name."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drp_env = cnvtlower(trim(logical("environment")))
    IF (trim(drp_env) > " ")
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("ENVIRONMENT LOGICAL:",drp_env))
     ENDIF
    ELSE
     SET dm_err->emsg = "Environment logical is not valued."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\environment\\",drp_env," Domain")
    IF (ddr_lreg_oper("GET",drp_str,drp_domain)=0)
     RETURN(0)
    ENDIF
    IF (drp_domain="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve domain name property for ",drp_env)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Retrieve server user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-SERVER*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-SERVER-")), drp_owner = replace(di.info_name,drp_sea,
       "",0), drp_pwds->cnt = (drp_pwds->cnt+ 1),
      stat = alterlist(drp_pwds->qual,drp_pwds->cnt), drp_pwds->qual[drp_pwds->cnt].owner = cnvtupper
      (drp_owner), drp_pwds->qual[drp_pwds->cnt].pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_pwds)
    ENDIF
    IF ((drp_pwds->cnt > 0))
     IF (dcdur_get_server_users_pwds(drp_domain)=0)
      RETURN(0)
     ENDIF
     IF ((dcdur_server_pwds->cnt=0))
      SET dm_err->eproc =
      "No existing server 'Rdbms Password' properties to restore preserved passwords against."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ELSE
     SET dm_err->eproc = "No preserved server passwords to restore."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((drp_pwds->cnt > 0)
     AND (dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO drp_pwds->cnt)
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 0
       SET dm2scramble->in_text = drp_pwds->qual[drp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET drp_pwds->qual[drp_iter].pwd = dm2scramble->out_text
     ENDFOR
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(drp_pwds)
     ENDIF
    ENDIF
    IF ((dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO dcdur_server_pwds->cnt)
       SET drp_tmp_owner = cnvtupper(dcdur_server_pwds->qual[drp_iter].user)
       SET drp_idx = 0
       SET drp_idx = locateval(drp_idx,1,drp_pwds->cnt,drp_tmp_owner,drp_pwds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        IF ( NOT ((dcdur_server_pwds->qual[drp_iter].server IN (58, 74))))
         SET dm_err->eproc = concat('Set "Rdbms Password" for server ',trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server)),".")
         CALL disp_msg("",dm_err->logfile,0)
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password" ','"',
          trim(drp_pwds->qual[drp_idx].pwd),'"')
         IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password"')
         IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         IF (trim(drp_ret_val) != trim(drp_pwds->qual[drp_idx].pwd))
          SET dm_err->emsg = concat('Error setting "Rdbms Password" for server ',trim(cnvtstring(
             dcdur_server_pwds->qual[drp_iter].server)),".")
          SET dm_err->err_ind = 1
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->eproc = concat("Skipping update of Rdbms Password for server ",trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server))," as already updated in earlier step.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = "Retrieving preserved password to complete restore."
        SET dm_err->emsg = concat("No preserved password found for server ",trim(cnvtstring(
           dcdur_server_pwds->qual[drp_iter].server))," and user ",trim(dcdur_server_pwds->qual[
          drp_iter].user),".")
        SET dm_err->user_action = concat(
         "After filling in <password> with original Target password, ",
         "execute the following and then rerun restore process: dm2_repl_insert_pwds 'SERVER', '",
         trim(dcdur_server_pwds->qual[drp_iter].user),"', '<password>' go")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL"))
    SET dm_err->eproc = "Retrieve database users."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT
     IF ((dm2_rdbms_version->level1 >= 12))
      FROM (
       (
       (SELECT
        username = x.username, common = x.common, oracle_maintained = x.oracle_maintained
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ELSE
      FROM (
       (
       (SELECT
        username = x.username, common = "NO", oracle_maintained = "N"
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ENDIF
     INTO "nl:"
     du.username, du.common, du.oracle_maintained
     ORDER BY du.username
     DETAIL
      drp_cmds->cnt = (drp_cmds->cnt+ 1), stat = alterlist(drp_cmds->qual,drp_cmds->cnt), drp_cmds->
      qual[drp_cmds->cnt].owner = du.username,
      drp_cmds->qual[drp_cmds->cnt].common = du.common, drp_cmds->qual[drp_cmds->cnt].
      oracle_maintained = du.oracle_maintained, drp_cmds->qual[drp_cmds->cnt].issue_cmd = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    SET dm_err->eproc = concat("Retrieve database user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-DB*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-DB-")), drp_owner = replace(di.info_name,drp_sea,"",0
       ), drp_idx = 0
      IF (drp_owner != "V500")
       drp_idx = locateval(drp_idx,1,drp_cmds->cnt,drp_owner,drp_cmds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        drp_cmds->qual[drp_idx].pwd = di.info_char, drp_cmds->qual[drp_idx].command = concat(
         "ALTER USER ",build('"',trim(drp_cmds->qual[drp_idx].owner),'"')," IDENTIFIED BY VALUES ",
         build("'",trim(drp_cmds->qual[drp_idx].pwd),"'")," account unlock")
        IF ((drp_cmds->qual[drp_idx].common="NO")
         AND (drp_cmds->qual[drp_idx].oracle_maintained="N"))
         drp_cmds->qual[drp_idx].issue_cmd = 1, drp_issue_cmds = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    IF (drp_issue_cmds=1)
     FOR (drp_iter = 1 TO drp_cmds->cnt)
       IF ((drp_cmds->qual[drp_iter].issue_cmd > 0))
        SET dm_err->eproc = concat("Restoring password for database user ",drp_cmds->qual[drp_iter].
         owner)
        CALL disp_msg("",dm_err->logfile,0)
        IF (dm2_push_cmd(build("rdb asis(^",drp_cmds->qual[drp_iter].command,"^) go"),1)=0)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->eproc = concat("Skipping restore password for user ",drp_cmds->qual[drp_iter].
         owner," because either V500, COMMON or Oracle Maintained.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
     ENDFOR
    ELSE
     SET dm_err->eproc = "No preserved database users to restore passwords against."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL", "LOGIN"))
    SET dm_err->eproc = concat("Retrieve login pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-LOGIN*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_tmp_pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drp_tmp_pwd="DM2NOTSET")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating preserved login password in Admin DM_INFO."
     SET dm_err->emsg = "No login password found."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 0
    SET dm2scramble->in_text = drp_tmp_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET drp_tmp_pwd = dm2scramble->out_text
    SET dm_err->eproc = 'Set "Rdbms Password" in registry, for the database property.'
    CALL disp_msg("",dm_err->logfile,0)
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ',
     '"',trim(drp_tmp_pwd),'"')
    IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
    IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (trim(drp_ret_val) != trim(drp_tmp_pwd))
     SET dm_err->emsg = 'Error setting "Rdbms Password" for database property in registry.'
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_server_users_pwds(dgsup_in_domain)
   DECLARE dgsup_idx = i2 WITH protect, noconstant(0)
   DECLARE dgsup_cmd_string = vc WITH protect, noconstant("")
   DECLARE dgsup_iter = i4 WITH protect, noconstant(0)
   DECLARE dgsup_str = vc WITH protect, noconstant("")
   DECLARE dgsup_num = i4 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err1 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err2 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_str = vc WITH protect, noconstant("")
   DECLARE dgsup_err_msg = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms Passwords for all servers."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    HEAD REPORT
     dcdur_server_pwds->cnt = 0, stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt)
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms password",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dcdur_server_pwds->cnt = (
       dcdur_server_pwds->cnt+ 1),
       stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt), dcdur_server_pwds->qual[
       dcdur_server_pwds->cnt].pwd = dgsup_str, dcdur_server_pwds->qual[dcdur_server_pwds->cnt].
       server = dgsup_num,
       dcdur_server_pwds->qual[dcdur_server_pwds->cnt].user = ""
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms User Names for all servers with associated password property."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms user name",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dgsup_idx = 0,
       dgsup_idx = locateval(dgsup_idx,1,dcdur_server_pwds->cnt,dgsup_num,dcdur_server_pwds->qual[
        dgsup_idx].server)
       IF (dgsup_idx > 0)
        dcdur_server_pwds->qual[dgsup_idx].user = dgsup_str
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dcdur_server_pwds->cnt > 0))
    SET dm_err->eproc = "Rolling up Server User Name and Password properties."
    CALL disp_msg("",dm_err->logfile,0)
    FOR (dgsup_iter = 1 TO dcdur_server_pwds->cnt)
      IF ((dcdur_server_pwds->qual[dgsup_iter].user > "")
       AND (dcdur_server_pwds->qual[dgsup_iter].pwd > ""))
       IF ((dcdur_owner_pwds->cnt=0))
        SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
        SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter]
        .user
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
        pwd
       ELSE
        SET dgsup_idx = 0
        SET dgsup_idx = locateval(dgsup_idx,1,dcdur_owner_pwds->cnt,dcdur_server_pwds->qual[
         dgsup_iter].user,dcdur_owner_pwds->qual[dgsup_idx].owner,
         "SERVER",dcdur_owner_pwds->qual[dgsup_idx].type)
        IF (dgsup_idx > 0)
         IF ((dcdur_owner_pwds->qual[dgsup_idx].pwd != dcdur_server_pwds->qual[dgsup_iter].pwd))
          SET dgsup_fatal_err1 = 1
          IF (dgsup_fatal_str="")
           SET dgsup_fatal_str = concat(trim(dcdur_owner_pwds->qual[dgsup_idx].owner),", ")
          ELSE
           SET dgsup_fatal_str = concat(dgsup_fatal_str,trim(dcdur_owner_pwds->qual[dgsup_idx].owner),
            ", ")
          ENDIF
         ENDIF
        ELSE
         SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
         SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter
         ].user
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
         pwd
        ENDIF
       ENDIF
      ELSE
       SET dgsup_fatal_err2 = 1
      ENDIF
    ENDFOR
    IF (((dgsup_fatal_err1=1) OR (dgsup_fatal_err2=1)) )
     IF (dgsup_fatal_err2=1)
      SET dgsup_err_msg = concat(
       "'Rdbms Password' properties found without an associated 'Rdbms User Name' ","property.")
     ENDIF
     IF (dgsup_fatal_err1=1)
      SET dgsup_fatal_str = replace(dgsup_fatal_str,",","",2)
      SET dgsup_err_msg = concat(dgsup_err_msg,
       "   The following is a list of 'Rdbms User Name' property values with ",
       "inconsistent 'Rdbms Password' ","property values: ",trim(dgsup_fatal_str),
       ".")
     ENDIF
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ELSE
      SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ENDIF
     SET dgsup_err_msg = concat(trim(dgsup_err_msg,3),"   Use the following alter_server command to ",
      "reconcile issues:  ",trim(dgsup_cmd_string),".")
     SET dm_err->err_ind = 1
     SET dm_err->emsg = trim(dgsup_err_msg,3)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("No 'Rdbms Passwords' properties found for any servers.")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_load(dutl_db_name)
   DECLARE dutl_info_domain = vc WITH protect, noconstant("")
   DECLARE dutl_len = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dutl_cur_user = vc WITH protect, noconstant("")
   DECLARE dutl_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dutl_ndx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load dcdur_user_data record structure"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dcdur_user_data->user_cnt=0))
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
     SET dm_err->eproc = "Retrieve tablespace mappings for TEMP and MISC"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm2_admin_dm_info d
      WHERE cnvtupper(d.info_domain)=patstring(build("DM2_",cnvtupper(dutl_db_name),
        "_*_TSPACE_MAPPING"))
       AND cnvtupper(d.info_name) IN ("MISC_TSPACE", "TEMP_TSPACE")
      HEAD REPORT
       dcdur_user_data->user_cnt = 0, stat = alterlist(dcdur_user_data->users,dcdur_user_data->
        user_cnt)
      DETAIL
       dutl_cur_idx = 0, dutl_cur_user = "", dutl_info_domain = d.info_domain,
       dutl_len = textlen(trim(dutl_db_name)), dutl_pos = findstring(trim(cnvtupper(dutl_db_name)),
        dutl_info_domain,1,0), dutl_pos = ((dutl_pos+ dutl_len)+ 1),
       dutl_pos2 = findstring("_TSPACE_MAPPING",dutl_info_domain,1,1), dutl_cur_user = substring(
        dutl_pos,(dutl_pos2 - dutl_pos),dutl_info_domain)
       IF ((dcdur_user_data->user_cnt > 0))
        dutl_cur_idx = locateval(dutl_ndx,1,dcdur_user_data->user_cnt,dutl_cur_user,dcdur_user_data->
         users[dutl_ndx].user)
       ENDIF
       IF (dutl_cur_idx=0)
        dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1), stat = alterlist(dcdur_user_data
         ->users,dcdur_user_data->user_cnt), dcdur_user_data->users[dcdur_user_data->user_cnt].user
         = dutl_cur_user
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = d.info_char
        ENDIF
       ELSE
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].temp_tspace = d.info_char
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_user_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_insert_admin_tspace_rows(diatr_user_name,diatr_db_name,diatr_temp_ts,diatr_misc_ts)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
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
    SET dm_err->eproc = concat("Insert tablespace mappings rows into dm2_admin_dm_info for user: ",
     diatr_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = "Insert MISC TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "MISC_TSPACE", d.info_char =
      diatr_misc_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Insert TEMP TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "TEMP_TSPACE", d.info_char =
      diatr_temp_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_prompt_tspaces(dpt_user_name,dpt_db_name,dpt_user_idx)
   DECLARE dpt_temp_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_misc_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_cur_ts_tmp = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_len = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dpt_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dpt_ndx = i4 WITH protect, noconstant(0)
   DECLARE dpt_continue = i2 WITH protect, noconstant(1)
   DECLARE dpt_invalid_misc_ts = i2 WITH protect, noconstant(0)
   DECLARE dpt_invalid_temp_ts = i2 WITH protect, noconstant(0)
   IF (dcdur_user_tspace_load(dpt_db_name)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_user_data->user_cnt > 0))
    SET dpt_cur_idx = locateval(dpt_ndx,1,dcdur_user_data->user_cnt,cnvtupper(dpt_user_name),
     dcdur_user_data->users[dpt_ndx].user)
    IF (dpt_cur_idx > 0)
     SET dpt_user_idx = dpt_cur_idx
     RETURN(1)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verify that current user is a valid user"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE cnvtupper(du.username)=cnvtupper(dpt_user_name)
    DETAIL
     dpt_temp_ts_def = trim(cnvtupper(du.temporary_tablespace)), dpt_misc_ts_def = trim(cnvtupper(du
       .default_tablespace))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")
    SET dpt_misc_ts_def = drrr_rf_data->tgt_default_misc_ts
    SET dpt_temp_ts_def = drrr_rf_data->tgt_default_temp_ts
    IF (((dpt_misc_ts_def="DM2NOTSET") OR (dpt_temp_ts_def="DM2NOTSET")) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if default tablespaces are set in the response file."
     SET dm_err->emsg = concat("Invalid values found for default tablespaces in the response file. ",
      "Please provide valid inputs for s_TGT_DEFAULT_MISC_TS and s_TGT_DEFAULT_TEMP_TS tokens.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((curqual > 0) OR (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")) )
    IF ((dm_err->debug_flag > 0))
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check if override values are set for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->misc_tspace_force) != ""
    AND trim(dcdur_user_data->temp_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->temp_tspace_force) != "")
    SET dpt_misc_ts_def = dcdur_user_data->misc_tspace_force
    SET dpt_temp_ts_def = dcdur_user_data->temp_tspace_force
    IF ((dm_err->debug_flag > 0))
     CALL echo("OVERRIDING VALUES FOR TEMP AND MISC TSPACE MAPPING")
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Set default values for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve MISC tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="MISC"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->misc_tspace_default = "MISC"
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->misc_tspace_default = dcdur_user_data->users[1].misc_tspace
    ENDIF
   ENDIF
   IF (trim(dcdur_user_data->temp_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="TEMP"
      AND dt.contents="TEMPORARY"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->temp_tspace_default = "TEMP"
    ELSE
     SET dm_err->eproc = "Retrieve temp tablespace contents from dba_tablespaces"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dba_tablespaces dt
      WHERE dt.contents="TEMPORARY"
      DETAIL
       dpt_cur_ts_tmp = dt.tablespace_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dcdur_user_data->temp_tspace_default = dpt_cur_ts_tmp
     ENDIF
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->temp_tspace_default = dcdur_user_data->users[1].temp_tspace
    ENDIF
   ENDIF
   SET dm_err->eproc = "Prompt user for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dpt_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"TABLESPACE MAPPING PROMPTS")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),";;Q"))
     IF (dpt_invalid_temp_ts=1
      AND dpt_invalid_misc_ts=1)
      CALL text(5,2,concat(
        "Both MISC and TEMP tablespace mappings provided could not be validated in dba_tablespaces.",
        " Please provide an alternate mappings."))
     ELSEIF (dpt_invalid_temp_ts=1)
      CALL text(5,2,concat(
        "TEMP tablespace provided is not a valid TEMPORARY tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSEIF (dpt_invalid_misc_ts=1)
      CALL text(5,2,concat("MISC tablespace provided is not a valid tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSE
      CALL clear(5,2,100)
     ENDIF
     SET dpt_invalid_temp_ts = 0
     SET dpt_invalid_misc_ts = 0
     CALL text(7,2,concat("MISC Tablespace for ",dpt_user_name,": "))
     CALL text(9,2,concat("TEMP Tablespace for ",dpt_user_name,": "))
     CALL accept(7,40,"P(30);CU",evaluate(dcdur_user_data->misc_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->misc_tspace_default)
      WHERE curaccept != " ")
     SET dpt_misc_ts_def = trim(curaccept)
     CALL accept(9,40,"P(30);CU",evaluate(dcdur_user_data->temp_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->temp_tspace_default)
      WHERE curaccept != " ")
     SET dpt_temp_ts_def = trim(curaccept)
     CALL text(12,2,"(C)ontinue, (M)odify, (Q)uit :")
     CALL accept(12,34,"p;cu","C"
      WHERE curaccept IN ("C", "M", "Q"))
     SET message = nowindow
     CASE (curaccept)
      OF "Q":
       SET dm_err->emsg = "User Quit Process"
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dpt_misc_ts_def = "DM2NOTSET"
       SET dpt_temp_ts_def = "DM2NOTSET"
       SET dpt_continue = 0
       RETURN(0)
      OF "C":
       IF ((((dpt_misc_ts_def != dcdur_user_data->misc_tspace_default)) OR ((dpt_temp_ts_def !=
       dcdur_user_data->temp_tspace_default))) )
        SET dm_err->eproc = "Verifying that MISC and TEMP tablspace mappings provided are valid"
        CALL disp_msg(" ",dm_err->logfile,0)
        SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_temp_ts_def
          AND dt.contents="TEMPORARY"
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_temp_ts = 1
        ENDIF
        SET dm_err->eproc = "Retrieve misc tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_misc_ts_def
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_misc_ts = 1
        ENDIF
        IF (dpt_invalid_misc_ts=0
         AND dpt_invalid_temp_ts=0)
         SET dpt_continue = 0
        ELSE
         SET dpt_continue = 1
        ENDIF
       ELSE
        SET dpt_continue = 0
       ENDIF
      OF "M":
       SET dpt_continue = 1
     ENDCASE
   ENDWHILE
   IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
    RETURN(0)
   ENDIF
   SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
   SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
   SET dpt_user_idx = dcdur_user_data->user_cnt
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_cleanup(dutc_user_name,dutc_db_name)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
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
    SET dm_err->eproc = concat("Cleanup tablespace mappings rows in dm2_admin_dm_info for user: ",
     dutc_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm2_admin_dm_info d
     WHERE d.info_domain=patstring(build("DM2_",cnvtupper(dutc_db_name),"_",cnvtupper(dutc_user_name),
       "_TSPACE_MAPPING"))
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_db_owner_pwds(dgdop_in_dbname)
   DECLARE dgdop_str = vc WITH protect, noconstant("")
   DECLARE dgdop_pwd_val = vc WITH protect, noconstant("")
   DECLARE dgdop_user_val = vc WITH protect, noconstant("")
   SET dm_err->eproc = 'Get "Rdbms User Name" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms User Name" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms User Name" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_user_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_user_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms User Name property for ",trim(dgdop_in_dbname
      ))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dgdop_user_val != "v500")
    SET dm_err->emsg = concat("Retrieved Rdbms User Name for DB ",trim(dgdop_in_dbname)," is ",
     dgdop_user_val," instead of v500")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = 'Get "Rdbms Password" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms Password" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_pwd_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_pwd_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms Password property for ",trim(dgdop_in_dbname)
     )
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
   SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "LOGIN"
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dgdop_user_val
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dgdop_pwd_val
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_adb_check(dac_db_link=vc,dac_adb_ind=i2(ref)) = i2
 SUBROUTINE dm2_adb_check(dac_db_link,dac_adb_ind)
   DECLARE dac_col_cnt = i4 WITH protect, noconstant(0)
   SET dac_adb_ind = 0
   SET dm_err->eproc = "Check if connected to database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (validate(currdbhandle,"")="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "currdbhandle is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if connected to autonomous database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     FROM (parser(concat("dba_tab_columns@",dac_db_link)) dtc)
    ELSE
     FROM dba_tab_columns dtc
    ENDIF
    INTO "nl:"
    dac_col_tmp_cnt = count(*)
    WHERE dtc.owner="SYS"
     AND dtc.table_name="V_$PDBS"
     AND dtc.column_name="CLOUD_IDENTITY"
    DETAIL
     dac_col_cnt = dac_col_tmp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dac_col_cnt > 0)
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM (parser(concat("V$PDBS@",dac_db_link)) x)
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM v$pdbs x
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dcu_cmd = vc WITH protect, noconstant(" ")
 DECLARE dcu_user = vc WITH protect, noconstant(" ")
 DECLARE dcu_standalone = i2 WITH protect, noconstant(0)
 DECLARE dcu_dbname = vc WITH protect, noconstant("")
 DECLARE dcu_user_idx = i2 WITH protect, noconstant(0)
 DECLARE dcu_misc_ts = vc WITH protect, noconstant("")
 DECLARE dcu_temp_ts = vc WITH protect, noconstant("")
 DECLARE dcu_can_use_dbms_metadata = i2 WITH protect, noconstant(0)
 DECLARE dcu_connect_back = i2 WITH protect, noconstant(0)
 DECLARE dcu_connect_str = vc WITH protect, noconstant("")
 DECLARE dcu_idx = i4 WITH protect, noconstant(0)
 DECLARE dcu_db_user_pwd = vc WITH protect, noconstant("")
 DECLARE dcu_stack_idx = i4 WITH protect, noconstant(0)
 DECLARE dcu_tgt_sys_cnct_str = vc WITH protect, noconstant("")
 DECLARE dcu_tgt_adb_ind = i2 WITH protect, noconstant(0)
 DECLARE dcu_src_adb_ind = i2 WITH protect, noconstant(0)
 DECLARE dcu_command = vc WITH protect, noconstant("")
 DECLARE dcu_grant_user = vc WITH protect, noconstant("")
 DECLARE dcu_run_ignorable_cmd(dric_cmd=vc) = i2
 SET dcu_user = trim( $1)
 IF ((dm2_install_schema->curprog="NONE"))
  SET dcu_standalone = 1
 ENDIF
 IF (check_logfile("dm2_create_users",".log","dm2_create_users")=0)
  GO TO exit_script
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(program_stack_rs)
 ENDIF
 IF (validate(drrr_responsefile_in_use,0)=1)
  SET dcu_can_use_dbms_metadata = 1
  IF (locateval(dcu_stack_idx,1,program_stack_rs->cnt,"DM2_CREATE_DB_SHELL",program_stack_rs->qual[
   dcu_stack_idx].name) > 0)
   SET dcdur_user_data->temp_tspace_force = "TEMP"
   SET dcdur_user_data->misc_tspace_force = "MISC"
  ENDIF
 ELSEIF (cnvtupper(program_stack_rs->qual[1].name)="DM2_CREATE_DB_SHELL")
  SET dcdur_user_data->temp_tspace_force = "TEMP"
  SET dcdur_user_data->misc_tspace_force = "MISC"
  SET dcu_can_use_dbms_metadata = 1
 ELSEIF (cnvtupper(program_stack_rs->qual[1].name)="DM2_REFRESH_V500_USER")
  SET dcu_can_use_dbms_metadata = 1
 ELSEIF (validate(dm2_mig_db_ind,- (1))=1)
  SET dcu_can_use_dbms_metadata = 1
 ELSEIF (dcu_standalone=1)
  SET dcu_can_use_dbms_metadata = 1
 ENDIF
 SET dm_err->eproc = "Starting DM2_CREATE_USERS"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (currdb != "ORACLE")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Script is only valid on ORACLE"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dm2_adb_check("",dcu_tgt_adb_ind)=0)
  GO TO exit_script
 ENDIF
 IF ((program_stack_rs->qual[1].name="DM2_REFRESH_V500_USER"))
  SET dcu_tgt_sys_cnct_str = dm2_install_schema->connect_str
 ENDIF
 IF (dcu_standalone=1)
  SET dm2_install_schema->dbase_name = "TARGET"
  IF (dcu_tgt_adb_ind=1)
   SET dm2_install_schema->u_name = "ADMIN"
  ELSE
   SET dm2_install_schema->u_name = "SYS"
  ENDIF
  SET dm2_force_connect_string = 1
  EXECUTE dm2_connect_to_dbase "PC"
  SET dcdur_user_data->tgt_sys_user = dm2_install_schema->u_name
  SET dcdur_user_data->tgt_sys_pwd = dm2_install_schema->p_word
  SET dcu_tgt_sys_cnct_str = dm2_install_schema->connect_str
  SET dm2_force_connect_string = 0
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dm2_get_dbase_name(dcu_dbname)=0)
  GO TO exit_script
 ENDIF
 IF (dcu_dbname="")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to obtain database name"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dm2_get_rdbms_version(null)=0)
  GO TO exit_script
 ENDIF
 IF (validate(drrr_responsefile_in_use,0)=1)
  IF ((drrr_misc_data->tgt_db_user_pwd_map_cnt > 0))
   SET dir_db_users_pwds->cnt = 0
   SET stat = alterlist(dir_db_users_pwds->qual,0)
   FOR (dcu_idx = 1 TO drrr_misc_data->tgt_db_user_pwd_map_cnt)
     SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
     SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
     SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = drrr_misc_data->tgt_db_user_pwd_map[
     dcu_idx].user
     SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = drrr_misc_data->tgt_db_user_pwd_map[
     dcu_idx].pwd
   ENDFOR
  ENDIF
 ELSE
  IF (dcu_user="ALL")
   IF (validate(dm2_mig_db_ind,- (1))=1)
    SET deir_get_pwd = "'V500_EVENT','V500_READ','V500_REF','V500'"
   ELSE
    SET deir_get_pwd = "'V500_EVENT','V500_READ','V500'"
   ENDIF
  ELSE
   SET deir_get_pwd = dcu_user
  ENDIF
  SET dm_err->eproc = "Prompt for user passwords."
  IF (dir_load_users_pwds(deir_get_pwd)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((validate(dm2_manual_create_users,- (1))=- (1))
  AND (validate(dm2_skip_source_processing,- (1))=- (1))
  AND (dm2_rdbms_version->level1 >= 11)
  AND dcu_can_use_dbms_metadata=1)
  SET dcdur_user_data->create_user_method = "DBMS_METADATA_METHOD"
  IF (validate(dm2_mig_db_ind,- (1))=1)
   SET dm2_install_schema->src_v500_p_word = dmr_mig_data->src_v500_pwd
   SET dm2_install_schema->src_v500_connect_str = dmr_mig_data->src_v500_cnct_str
   IF ((dcdur_user_data->tgt_sys_pwd="DM2NOTSET"))
    SET dcdur_user_data->tgt_sys_pwd = dmr_mig_data->tgt_sys_pwd
   ENDIF
   IF (size(trim(dmr_mig_data->tgt_sys_cnct_str,3)) > 0)
    SET dcu_tgt_sys_cnct_str = dmr_mig_data->tgt_sys_cnct_str
   ELSE
    SET dcu_tgt_sys_cnct_str = build("remote_",dcu_dbname,"1")
   ENDIF
  ELSE
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    SET dm2_install_schema->src_v500_p_word = drrr_rf_data->src_db_user_pwd
    SET dm2_install_schema->src_v500_connect_str = drrr_rf_data->src_db_cnct_str
    SET dcu_connect_back = 1
    SET dm2_force_connect_string = 1
    SET dm2_install_schema->dbase_name = '"SOURCE"'
    SET dm2_install_schema->u_name = "V500"
    SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     GO TO exit_script
    ENDIF
    SET dcu_tgt_sys_cnct_str = drrr_rf_data->tgt_db_cnct_str
   ELSE
    IF ((((dm2_install_schema->src_v500_p_word="NONE")) OR ((dm2_install_schema->src_v500_connect_str
    ="NONE"))) )
     SET dcu_connect_back = 1
     SET dm2_install_schema->dbase_name = '"SOURCE"'
     SET dm2_install_schema->u_name = "V500"
     SET dm2_force_connect_string = 1
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      GO TO exit_script
     ENDIF
     SET dm2_force_connect_string = 0
     SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
    ENDIF
    IF (textlen(trim(dcu_tgt_sys_cnct_str,3))=0)
     SET dcu_tgt_sys_cnct_str = build(dcu_dbname,1)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("currdbname:",currdbname))
   ENDIF
   IF (dm2_adb_check("",dcu_src_adb_ind)=0)
    GO TO exit_script
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dcu_src_adb_ind:",dcu_src_adb_ind))
    CALL echo(build("dcu_tgt_adb_ind:",dcu_tgt_adb_ind))
   ENDIF
   IF (dcu_connect_back=1)
    SET dm2_force_connect_string = 1
    SET dm2_install_schema->dbase_name = '"TARGET"'
    SET dm2_install_schema->u_name = dcdur_user_data->tgt_sys_user
    SET dm2_install_schema->p_word = dcdur_user_data->tgt_sys_pwd
    SET dm2_install_schema->connect_str = dcu_tgt_sys_cnct_str
    EXECUTE dm2_connect_to_dbase "CO"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF (dcu_user="ALL")
   IF (validate(dm2_mig_db_ind,- (1))=1)
    SET dcdur_input->user_list = "'V500_EVENT','V500_READ','V500_REF','V500'"
   ELSE
    SET dcdur_input->user_list = "'V500_EVENT','V500_READ','V500'"
   ENDIF
  ELSE
   SET dcdur_input->user_list = build("'",dcu_user,"'")
  ENDIF
  SET dcdur_input->src_user = "V500"
  SET dcdur_input->src_pwd = dm2_install_schema->src_v500_p_word
  SET dcdur_input->src_cnct_str = dm2_install_schema->src_v500_connect_str
  SET dcdur_input->tgt_user = dcdur_user_data->tgt_sys_user
  SET dcdur_input->tgt_pwd = dcdur_user_data->tgt_sys_pwd
  SET dcdur_input->tgt_cnct_str = dcu_tgt_sys_cnct_str
  SET dcdur_input->tgt_dbname = dcu_dbname
  SET dcdur_input->fix_tspaces_ind = "N"
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->temp_tspace = ""
  IF (dcu_tgt_adb_ind=1)
   SET dcdur_input->replace_tspaces = "N"
  ELSE
   SET dcdur_input->replace_tspaces = "Y"
  ENDIF
  SET dcdur_input->replace_pwds = "Y"
  IF (dcdur_create_db_users(null)=0)
   IF ((dcdur_input->connect_back="Y"))
    SET dcu_connect_back = 1
   ENDIF
   GO TO exit_script
  ENDIF
  IF (dm2_get_rdbms_version(null)=0)
   GO TO exit_script
  ENDIF
  IF ((dm2_rdbms_version->level1 >= 12))
   CALL dcu_run_ignorable_cmd("rdb grant manage scheduler to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant create any job to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_lock to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_sql to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_system to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_resumable to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_pipe to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_crypto to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant select on sys.user$ to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant SELECT ANY DICTIONARY to V500 go")
  ENDIF
  IF ((dm_err->debug_flag > 0))
   CALL echo(concat("currdbuser before dm2_grant_sys_privs maybe executed:",currdbuser))
  ENDIF
  IF (validate(drrr_responsefile_in_use,0)=1)
   IF ((validate(dm2_skip_grant_sys_privs,- (1))=- (1))
    AND dcu_tgt_adb_ind=1)
    SET dcu_grant_user = evaluate(dcu_user,"ALL","DEFAULT",dcu_user)
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("dcu_grant_user:",dcu_grant_user))
    ENDIF
    EXECUTE dm2_grant_sys_privs dcu_grant_user, "DEFAULT", "DEFAULT"
    IF ((dm_err->err_ind=1))
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Using manual method to create v500* users."
 CALL disp_msg("",dm_err->logfile,0)
 SET dcdur_user_data->create_user_method = "MANUAL_METHOD"
 IF (dcu_user IN ("ALL", "V500"))
  SET dm_err->eproc = "Check if V500 database user exists."
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dba_users d
   WHERE d.username="V500"
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   IF (dcdur_prompt_tspaces("V500",dcu_dbname,dcu_user_idx)=0)
    GO TO exit_script
   ENDIF
   SET dcu_misc_ts = dcdur_user_data->users[dcu_user_idx].misc_tspace
   SET dcu_temp_ts = dcdur_user_data->users[dcu_user_idx].temp_tspace
   SET dcu_idx = 0
   SET dcu_idx = locateval(dcu_idx,1,dir_db_users_pwds->cnt,"V500",replace(dir_db_users_pwds->qual[
     dcu_idx].user,"'","",0))
   SET dcu_db_user_pwd = dir_db_users_pwds->qual[dcu_idx].pwd
   IF (dm2_push_cmd(concat('rdb asis(^create user V500 identified by "',dcu_db_user_pwd,
     '" default tablespace ',dcu_misc_ts," temporary tablespace ",
     dcu_temp_ts,"^) go"),1)=0)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL dcu_run_ignorable_cmd("rdb GRANT ALTER ANY INDEX to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant ALTER ANY PROCEDURE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant ALTER ANY TABLE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant ALTER ANY TRIGGER to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant ALTER TABLESPACE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant ANALYZE ANY TO V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE ANY INDEX to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE ANY PROCEDURE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE ANY SEQUENCE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE ANY SYNONYM to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE ANY TABLE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE ANY TRIGGER to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE ANY VIEW to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE PUBLIC SYNONYM to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE SESSION to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DELETE ANY TABLE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DROP ANY INDEX to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DROP ANY PROCEDURE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DROP ANY SEQUENCE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DROP ANY SYNONYM to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DROP ANY TABLE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DROP ANY TRIGGER to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant DROP PUBLIC SYNONYM to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant EXECUTE ANY PROCEDURE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant INSERT ANY TABLE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant LOCK ANY TABLE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant SELECT ANY TABLE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant UNLIMITED TABLESPACE to V500 go")
  CALL dcu_run_ignorable_cmd("rdb grant UPDATE ANY TABLE to V500 go")
  IF (dcu_tgt_adb_ind=1)
   CALL dcu_run_ignorable_cmd("rdb grant PDB_DBA to V500 go")
  ELSE
   CALL dcu_run_ignorable_cmd("rdb grant DBA to V500 go")
  ENDIF
  IF ((dm2_rdbms_version->level1 >= 9))
   CALL dcu_run_ignorable_cmd("rdb grant SELECT ANY DICTIONARY to V500 go")
   CALL dcu_run_ignorable_cmd("rdb grant RESUMABLE to V500 go")
  ENDIF
  IF ((dm2_rdbms_version->level1 >= 12))
   CALL dcu_run_ignorable_cmd("rdb grant manage scheduler to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant create any job to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_lock to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_sql to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_system to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_resumable to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_pipe to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant execute on sys.dbms_crypto to v500 go ")
   CALL dcu_run_ignorable_cmd("rdb grant select on sys.user$ to v500 go ")
  ENDIF
 ENDIF
 IF (dcu_user IN ("ALL", "V500_EVENT"))
  SET dm_err->eproc = "Check if V500_EVENT database user exists."
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dba_users d
   WHERE d.username="V500_EVENT"
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   IF (dcdur_prompt_tspaces("V500_EVENT",dcu_dbname,dcu_user_idx)=0)
    GO TO exit_script
   ENDIF
   SET dcu_misc_ts = dcdur_user_data->users[dcu_user_idx].misc_tspace
   SET dcu_temp_ts = dcdur_user_data->users[dcu_user_idx].temp_tspace
   SET dcu_idx = 0
   SET dcu_idx = locateval(dcu_idx,1,dir_db_users_pwds->cnt,"V500_EVENT",replace(dir_db_users_pwds->
     qual[dcu_idx].user,"'","",0))
   SET dcu_db_user_pwd = dir_db_users_pwds->qual[dcu_idx].pwd
   IF (dm2_push_cmd(concat('rdb asis(^create user V500_EVENT identified by "',dcu_db_user_pwd,
     '" default tablespace ',dcu_misc_ts," temporary tablespace ",
     dcu_temp_ts,"^) go"),1)=0)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL dcu_run_ignorable_cmd("rdb grant CREATE SESSION to V500_EVENT go")
 ENDIF
 IF (dcu_user IN ("ALL", "V500_READ"))
  SET dm_err->eproc = "Check if V500_READ database user exists."
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dba_users d
   WHERE d.username="V500_READ"
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   IF (dcdur_prompt_tspaces("V500_READ",dcu_dbname,dcu_user_idx)=0)
    GO TO exit_script
   ENDIF
   SET dcu_misc_ts = dcdur_user_data->users[dcu_user_idx].misc_tspace
   SET dcu_temp_ts = dcdur_user_data->users[dcu_user_idx].temp_tspace
   SET dcu_idx = 0
   SET dcu_idx = locateval(dcu_idx,1,dir_db_users_pwds->cnt,"V500_READ",replace(dir_db_users_pwds->
     qual[dcu_idx].user,"'","",0))
   SET dcu_db_user_pwd = dir_db_users_pwds->qual[dcu_idx].pwd
   IF (dm2_push_cmd(concat('rdb asis(^create user V500_READ identified by "',dcu_db_user_pwd,
     '" default tablespace ',dcu_misc_ts," temporary tablespace ",
     dcu_temp_ts,"^) go"),1)=0)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL dcu_run_ignorable_cmd("rdb grant select any table to V500_READ go")
  CALL dcu_run_ignorable_cmd("rdb grant select_catalog_role to V500_READ go")
  CALL dcu_run_ignorable_cmd("rdb grant CREATE SESSION to V500_READ go")
 ENDIF
 IF (validate(dm2_mig_db_ind,- (1))=1
  AND dcu_user IN ("ALL", "V500_REF"))
  SET dm_err->eproc = "Check if V500_REF database user exists."
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dba_users d
   WHERE d.username="V500_REF"
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   IF (dcdur_prompt_tspaces("V500_REF",dcu_dbname,dcu_user_idx)=0)
    GO TO exit_script
   ENDIF
   SET dcu_misc_ts = dcdur_user_data->users[dcu_user_idx].misc_tspace
   SET dcu_temp_ts = dcdur_user_data->users[dcu_user_idx].temp_tspace
   SET dcu_idx = 0
   SET dcu_idx = locateval(dcu_idx,1,dir_db_users_pwds->cnt,"V500_REF",dir_db_users_pwds->qual[
    dcu_idx].user)
   SET dcu_db_user_pwd = dir_db_users_pwds->qual[dcu_idx].pwd
   IF (dm2_push_cmd(concat('rdb asis(^create user V500_REF identified by "',dcu_db_user_pwd,
     '" default tablespace ',dcu_misc_ts," temporary tablespace ",
     dcu_temp_ts,"^) go"),1)=0)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL dcu_run_ignorable_cmd("rdb grant CREATE SESSION to V500_REF go")
  IF (dcu_tgt_adb_ind=1)
   CALL dcu_run_ignorable_cmd("rdb grant PDB_DBA to V500_REF go")
  ELSE
   CALL dcu_run_ignorable_cmd("rdb grant DBA to V500_REF go")
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE dcu_run_ignorable_cmd(dric_cmd)
  IF (dm2_push_cmd(dric_cmd,1)=0)
   SET dm_err->err_ind = 0
   SET dm_err->eproc = "THE ABOVE ERROR MESSAGE IS IGNORABLE"
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 IF ((dm_err->err_ind=0))
  IF (dcu_tgt_adb_ind=0)
   CALL dcdur_user_tspace_cleanup(evaluate(dcu_user,"ALL","*",dcu_user),dcu_dbname)
  ENDIF
 ENDIF
 IF (dcu_standalone=1)
  CALL parser("free define oraclesystem go",1)
  SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
  CALL disp_msg(" ",dm_err->logfile,0)
  IF ((dm_err->err_ind > 0))
   SET dm_err->eproc = "Evaluate success of script execution."
   SET dm_err->emsg = concat("Errors encountered during standalone execution of dm2_create_users.  ",
    "Review previous error banners for details.")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
 ENDIF
 IF (dcu_connect_back=1
  AND (dm_err->err_ind > 0))
  CALL parser("free define oraclesystem go",1)
  CALL parser(concat("define oraclesystem '",trim(dcdur_user_data->tgt_sys_user),"/",trim(
     dcdur_user_data->tgt_sys_pwd),"@",
    trim(dcu_tgt_sys_cnct_str),"' with sysdba go"),1)
 ENDIF
 SET dm_err->eproc = "Ending DM2_CREATE_USERS"
 CALL final_disp_msg("dm2_create_users")
END GO
