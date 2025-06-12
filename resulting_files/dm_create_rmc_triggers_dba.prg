CREATE PROGRAM dm_create_rmc_triggers:dba
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
 DECLARE add_cutover_trg(i_table_name=vc) = vc
 DECLARE create_reg_cutover_trg_stmt(i_tab_info=vc(ref),i_rdds_col_str=vc,i_null_info=vc(ref),
  i_soft_cons=vc(ref)) = c1
 DECLARE create_$r_cutover_trg_stmt(i_tab_info=vc(ref),i_rdds_col_str=vc,i_soft_cons=vc(ref)) = c1
 DECLARE create_reg_md_trg_stmt(i_tab_name=vc,i_null_info=vc(ref),i_rdds_col_str=vc,i_soft_cons=vc(
   ref),i_tab_info=vc(ref)) = c1
 DECLARE create_reg_vers_trg_stmt(i_trg_info=vc(ref),i_rdds_col_str=vc,i_null_info=vc(ref),
  i_soft_cons=vc(ref)) = c1
 SUBROUTINE add_cutover_trg(i_table_name)
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
     IF (check_error(
      "Determining whether DM2_DBA_TAB_COLUMNS or DM2_DBA_TAB_COLS views already exist.")=1)
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
      "from dba_tab_columns dc, dba_synonyms ds" ) asis ( "where ds.table_name = dc.table_name" )
      asis ( "  and ds.synonym_name != ds.table_name" ) asis ( "  and not exists " ) asis (
      "     (select c.synonym_name, count(*) " ) asis ( "          from dba_synonyms c " ) asis (
      "          where c.synonym_name = ds.synonym_name " ) asis (
      "          group by c.synonym_name " ) asis ( "          having count(*) > 1) " )
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
     SET select_str = concat('select into "nl:" r.line'," from rtlt r",' where r.line > " "',
      " detail ")
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
     SET foot_str = concat(" foot report"," stat = alterlist(dm2parse->qual, cnt)",
      " with nocounter go")
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
   DECLARE add_stmt(i_str=vc,i_rdb_asis_ind=i2,i_end_ind=i2,i_move_long_str_ind=i2,io_stmt_cnt=i4(ref
     ),
    io_rs_stmts=vc(ref)) = null
   SUBROUTINE add_stmt(i_str,i_rdb_asis_ind,i_end_ind,i_move_long_str_ind,io_stmt_cnt,io_rs_stmts)
     DECLARE s_max_length = i4 WITH protect
     DECLARE s_start = i4 WITH protect
     DECLARE s_str_len = i4 WITH protect
     DECLARE s_str = vc WITH protect, noconstant("")
     SET s_str = i_str
     SET s_max_length = 130
     IF (i_rdb_asis_ind=1)
      SET s_max_length = (s_max_length - 15)
      IF (findstring("v_curdate",s_str) > 0)
       SET s_max_length = (s_max_length - 50)
      ENDIF
     ENDIF
     IF (i_end_ind=1)
      SET s_max_length = (s_max_length - 7)
     ENDIF
     SET s_start = 1
     SET s_str_len = size(s_str,1)
     WHILE (s_start <= s_str_len)
      SET s_break_pos = findstring("<BrEaK>",substring(s_start,s_max_length,s_str),1,0)
      IF (s_break_pos > 0)
       SET s_break_pos = (s_break_pos - 1)
       SET io_stmt_cnt = (io_stmt_cnt+ 1)
       SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
       SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = 0
       SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
       SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
       SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,s_break_pos,s_str)
       SET s_start = ((s_start+ s_break_pos)+ 7)
      ELSEIF ((((s_str_len - s_start)+ 1) <= s_max_length))
       SET io_stmt_cnt = (io_stmt_cnt+ 1)
       SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
       SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,((s_str_len - s_start)+ 1),s_str)
       SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = i_end_ind
       SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
       SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
       SET s_start = (s_str_len+ 1)
      ELSE
       SET s_space_pos = findstring(" ",substring(s_start,s_max_length,s_str),1,1)
       IF (s_space_pos=0)
        CALL echo(substring(s_start,s_max_length,s_str))
        RETURN
       ENDIF
       SET io_stmt_cnt = (io_stmt_cnt+ 1)
       SET stat = alterlist(io_rs_stmts->stmt,io_stmt_cnt)
       SET io_rs_stmts->stmt[io_stmt_cnt].end_ind = 0
       SET io_rs_stmts->stmt[io_stmt_cnt].rdb_asis_ind = i_rdb_asis_ind
       SET io_rs_stmts->stmt[io_stmt_cnt].move_long_str_ind = i_move_long_str_ind
       SET io_rs_stmts->stmt[io_stmt_cnt].str = substring(s_start,s_space_pos,s_str)
       SET s_start = (s_start+ s_space_pos)
      ENDIF
     ENDWHILE
   END ;Subroutine
   IF ((validate(dcrt_list->r_cnt,- (1))=- (1))
    AND (validate(dcrt_list->r_cnt,- (2))=- (2)))
    FREE RECORD dcrt_list
    RECORD dcrt_list(
      1 r_cnt = i4
      1 reg_cnt = i4
      1 md_cnt = i4
      1 vr_cnt = i4
      1 r_list[*]
        2 table_suffix = vc
        2 trigger_name = vc
        2 validate_ind = i2
      1 reg_list[*]
        2 table_suffix = vc
        2 trigger_name = vc
        2 validate_ind = i2
      1 md_list[*]
        2 table_suffix = vc
        2 trigger_name = vc
        2 validate_ind = i2
      1 vr_list[*]
        2 table_suffix = vc
        2 trigger_name = vc
        2 validate_ind = i2
    )
   ENDIF
   DECLARE cutover_tab_name(i_normal_tab_name=vc,i_table_suffix=vc) = vc
   IF ((validate(table_data->counter,- (1))=- (1)))
    FREE RECORD table_data
    RECORD table_data(
      1 counter = i4
      1 qual[*]
        2 table_name = vc
        2 table_suffix = vc
    ) WITH protect
   ENDIF
   SUBROUTINE cutover_tab_name(i_normal_tab_name,i_table_suffix)
     DECLARE s_new_tab_name = vc WITH protect
     DECLARE s_tab_suffix = vc WITH protect
     DECLARE s_lv_num = i4 WITH protect
     DECLARE s_lv_pos = i4 WITH protect
     IF (i_table_suffix > " ")
      SET s_tab_suffix = i_table_suffix
      SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
     ELSE
      SET s_lv_pos = locateval(s_lv_num,1,size(table_data->qual,5),i_normal_tab_name,table_data->
       qual[s_lv_num].table_name)
      IF (s_lv_pos > 0)
       SET s_tab_suffix = table_data->qual[s_lv_pos].table_suffix
       SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
      ELSE
       SELECT INTO "nl:"
        FROM dm_rdds_tbl_doc dtd
        WHERE dtd.table_name=i_normal_tab_name
         AND dtd.table_name=dtd.full_table_name
        HEAD REPORT
         stat = alterlist(table_data->qual,(table_data->counter+ 1)), table_data->counter = size(
          table_data->qual,5)
        DETAIL
         table_data->qual[table_data->counter].table_name = dtd.table_name, table_data->qual[
         table_data->counter].table_suffix = dtd.table_suffix, s_new_tab_name = concat(trim(substring
           (1,14,i_normal_tab_name)),dtd.table_suffix,"$R")
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
     RETURN(s_new_tab_name)
   END ;Subroutine
   DECLARE add_tracking_row(i_source_id=f8,i_refchg_type=vc,i_refchg_status=vc) = null
   DECLARE delete_tracking_row(null) = null
   DECLARE move_long(i_from_table=vc,i_to_table=vc,i_column_name=vc,i_pk_str=vc,i_source_env_id=f8,
    i_status_flag=i4) = null
   DECLARE get_reg_tab_name(i_r_tab_name=vc,i_suffix=vc) = vc
   DECLARE dcc_find_val(i_delim_str=vc,i_delim_val=vc,i_val_rec=vc(ref)) = i2
   DECLARE move_circ_long(i_from_table=vc,i_from_rtable=vc,i_from_pk=vc,i_from_prev_pk=vc,i_from_fk=
    vc,
    i_from_pe_col=vc,i_circ_table=vc,i_circ_column_name=vc,i_circ_fk_col=vc,i_circ_long_col=vc,
    i_source_env_id=f8,i_status_flag=i4) = null
   IF ((validate(table_data->counter,- (1))=- (1)))
    FREE RECORD table_data
    RECORD table_data(
      1 counter = i4
      1 qual[*]
        2 table_name = vc
        2 table_suffix = vc
    ) WITH protect
   ENDIF
   SUBROUTINE add_tracking_row(i_source_id,i_refchg_type,i_refchg_status)
     DECLARE var_process = vc
     DECLARE var_sid = f8
     DECLARE var_serial_num = f8
     SELECT INTO "nl:"
      process, sid, serial#
      FROM v$session vs
      WHERE audsid=cnvtreal(currdbhandle)
      DETAIL
       var_process = vs.process, var_sid = vs.sid, var_serial_num = vs.serial#
      WITH maxqual(vs,1)
     ;end select
     UPDATE  FROM dm_refchg_process
      SET refchg_type = i_refchg_type, refchg_status = i_refchg_status, last_action_dt_tm = sysdate,
       updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
       updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE rdbhandle_value=cnvtreal(currdbhandle)
     ;end update
     COMMIT
     IF (curqual=0)
      INSERT  FROM dm_refchg_process
       SET dm_refchg_process_id = seq(dm_clinical_seq,nextval), env_source_id = i_source_id,
        rdbhandle_value = cnvtreal(currdbhandle),
        process_name = var_process, log_file = dm_err->logfile, last_action_dt_tm = sysdate,
        refchg_type = i_refchg_type, refchg_status = i_refchg_status, updt_cnt = 0,
        updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
        updt_task,
        updt_dt_tm = cnvtdatetime(curdate,curtime3), session_sid = var_sid, serial_number =
        var_serial_num
      ;end insert
      COMMIT
     ENDIF
   END ;Subroutine
   SUBROUTINE delete_tracking_row(null)
    DELETE  FROM dm_refchg_process
     WHERE rdbhandle_value=cnvtreal(currdbhandle)
     WITH nocounter
    ;end delete
    COMMIT
   END ;Subroutine
   SUBROUTINE move_long(i_from_table,i_to_table,i_column_name,i_pk_str,i_source_env_id,i_status_flag)
     RECORD long_col(
       1 data[*]
         2 pk_str = vc
         2 long_str = vc
     )
     SET s_rdds_where_iu_str =
     " rdds_delete_ind = 0 and rdds_source_env_id = i_source_env_id and rdds_status_flag = i_status_flag"
     DECLARE long_str = vc
     CALL parser(" select into 'nl:' ",0)
     CALL parser(concat("        bloblen = textlen(l.",trim(i_column_name),")"),0)
     CALL parser(concat("        , pk_str=",i_pk_str),0)
     CALL parser(concat("   from ",trim(i_from_table)," l "),0)
     CALL parser(concat(" where ",s_rdds_where_iu_str),0)
     CALL parser(" head report ",0)
     CALL parser("   outbuf = fillstring(32767,' ') ",0)
     CALL parser("   long_cnt = 0 ",0)
     CALL parser(" detail ",0)
     CALL parser("   retlen = 0 ",0)
     CALL parser("   offset = 0 ",0)
     CALL parser("   long_str = ' ' ",0)
     CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
     CALL parser("   while (retlen > 0) ",0)
     CALL parser("     if (long_str = ' ') ",0)
     CALL parser("       long_str = notrim(outbuf) ",0)
     CALL parser("     else ",0)
     CALL parser("       long_str = notrim(concat(long_str,substring(1,retlen,outbuf))) ",0)
     CALL parser("     endif ",0)
     CALL parser("     offset = offset + retlen ",0)
     CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
     CALL parser("   endwhile ",0)
     CALL parser("   long_cnt=long_cnt + 1",0)
     CALL parser("   if (mod(long_cnt,50) = 1)",0)
     CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
     CALL parser("   endif",0)
     CALL parser("   long_col->data[long_cnt].pk_str = pk_str",0)
     CALL parser("   long_col->data[long_cnt].long_str = trim(long_str,5)",0)
     CALL parser(" foot report",0)
     CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
     CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
     CALL parser(" go",1)
     FOR (lc_ndx = 1 TO size(long_col->data,5))
       CALL parser(concat("update from ",trim(i_to_table)," set ",trim(i_column_name)),0)
       CALL parser("= long_col->data[lc_ndx].long_str where ",0)
       CALL parser(long_col->data[lc_ndx].pk_str,0)
       CALL parser(" go",1)
     ENDFOR
   END ;Subroutine
   SUBROUTINE get_reg_tab_name(i_r_tab_name,i_suffix)
     DECLARE s_suffix = vc
     DECLARE s_tab_name = vc
     IF (i_suffix > " ")
      SET s_suffix = i_suffix
     ELSE
      SET s_suffix = substring((size(i_r_tab_name) - 5),4,i_r_tab_name)
     ENDIF
     SELECT INTO "nl:"
      dtd.table_name
      FROM dm_rdds_tbl_doc dtd
      WHERE dtd.table_suffix=s_suffix
       AND dtd.table_name=dtd.full_table_name
      DETAIL
       s_tab_name = dtd.table_name
      WITH nocounter
     ;end select
     RETURN(s_tab_name)
   END ;Subroutine
   SUBROUTINE dcc_find_val(i_delim_str,i_delim_val,i_val_rec)
     DECLARE dfv_temp_delim_str = vc WITH constant(concat(i_delim_val,i_delim_str,i_delim_val)),
     protect
     DECLARE dfv_temp_str = vc WITH noconstant(""), protect
     DECLARE dfv_return = i2 WITH noconstant(0), protect
     IF (size(trim(i_delim_str),1) > 0)
      FOR (i = 1 TO i_val_rec->len)
        IF (size(trim(i_val_rec->values[i].str),1) > 0)
         SET dfv_temp_str = concat(i_delim_val,i_val_rec->values[i].str,i_delim_val)
         IF (findstring(dfv_temp_str,dfv_temp_delim_str) > 0)
          SET dfv_return = 1
          RETURN(dfv_return)
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     RETURN(dfv_return)
   END ;Subroutine
   SUBROUTINE move_circ_long(i_from_table,i_from_rtable,i_from_pk,i_from_prev_pk,i_from_fk,
    i_from_pe_col,i_circ_table,i_circ_column_name,i_circ_fk_col,i_circ_long_col,i_source_env_id,
    i_status_flag)
     DECLARE mcl_rdds_iu_str = vc WITH protect, noconstant("")
     DECLARE move_circ_lc_ndx = i4 WITH protect, noconstant(0)
     DECLARE move_circ_long_str = vc WITH protect, noconstant("")
     DECLARE evaluate_pe_name() = c255
     RECORD long_col(
       1 data[*]
         2 long_pk = f8
         2 long_col_fk = f8
         2 long_str = vc
     )
     SET mcl_rdds_iu_str =
     " r.rdds_delete_ind = 0 and r.rdds_source_env_id = i_source_env_id and r.rdds_status_flag = i_status_flag"
     CALL parser(" select into 'nl:' ",0)
     CALL parser(concat("        bloblen = textlen(l.",trim(i_circ_long_col),")"),0)
     CALL parser(concat("   from ",trim(i_circ_table)," l, ",trim(i_from_table)," t, "),0)
     CALL parser(concat("         ",trim(i_from_rtable)," r "),0)
     CALL parser(concat(" where l.",trim(i_circ_column_name)," = t.",i_from_fk),0)
     CALL parser(concat("    and t.",i_from_pk," = r.",i_from_prev_pk),0)
     CALL parser(concat("    and r.",i_from_pk," != r.",i_from_prev_pk),0)
     IF (i_from_pe_col > "")
      CALL parser(concat("    and evaluate_pe_name('",i_from_table,"', '",i_from_fk,"','",
        i_from_pe_col,"', r.",i_from_pe_col,") = '",i_circ_table,
        "'"),0)
     ENDIF
     CALL parser(concat("    and l.",i_circ_column_name," > 0"),0)
     CALL parser(concat("    and ",mcl_rdds_iu_str),0)
     CALL parser(" head report ",0)
     CALL parser("   outbuf = fillstring(32767,' ') ",0)
     CALL parser("   long_cnt = 0 ",0)
     CALL parser(" detail ",0)
     CALL parser("   retlen = 0 ",0)
     CALL parser("   offset = 0 ",0)
     CALL parser("   move_circ_long_str = ' ' ",0)
     CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
     CALL parser("   while (retlen > 0) ",0)
     CALL parser("     if (move_circ_long_str = ' ') ",0)
     CALL parser("       move_circ_long_str = notrim(outbuf) ",0)
     CALL parser("     else ",0)
     CALL parser(
      "       move_circ_long_str = notrim(concat(move_circ_long_str,substring(1,retlen,outbuf))) ",0)
     CALL parser("     endif ",0)
     CALL parser("     offset = offset + retlen ",0)
     CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
     CALL parser("   endwhile ",0)
     CALL parser("   long_cnt=long_cnt + 1",0)
     CALL parser("   if (mod(long_cnt,50) = 1)",0)
     CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
     CALL parser("   endif",0)
     CALL parser(concat("   long_col->data[long_cnt].long_pk = t.",i_from_pk),0)
     CALL parser("   long_col->data[long_cnt].long_str = trim(move_circ_long_str,5)",0)
     CALL parser(concat("   long_col->data[long_cnt].long_col_fk = r.",i_from_fk),0)
     CALL parser(" foot report",0)
     CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
     CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
     CALL parser(" go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(null)
     ENDIF
     FOR (move_circ_lc_ndx = 1 TO size(long_col->data,5))
       CALL parser(concat("update from ",trim(i_circ_table)," t set ",trim(i_circ_long_col)),0)
       CALL parser("= long_col->data[move_circ_lc_ndx].long_str where ",0)
       CALL parser(concat("t.",i_circ_column_name," = ",trim(cnvtstring(long_col->data[
           move_circ_lc_ndx].long_col_fk,20,2))),0)
       CALL parser(" go",1)
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(null)
       ENDIF
     ENDFOR
   END ;Subroutine
   FREE RECORD trg_tab_info
   RECORD trg_tab_info(
     1 table_name = vc
     1 tab_$r = vc
     1 table_suffix = vc
     1 ui_match_str = vc
     1 ui_diff_str = vc
     1 pk_diff_str = vc
     1 pk_match_str = vc
     1 ui_ndx_ind = i2
     1 cust_plsql_ind = i2
     1 md_ind = i2
     1 vers_ind = i2
     1 vers_alg = vc
     1 beg_eff_col = vc
     1 end_eff_col = vc
     1 prev_pk_col = vc
     1 pk[*]
       2 column_name = vc
       2 data_type = vc
       2 not_md_col = i2
     1 ui_col_list = vc
     1 ui[*]
       2 column_name = vc
       2 data_type = vc
     1 distinct_cols[*]
       2 column_name = vc
     1 ndx[*]
       2 match_str = vc
       2 ui_superset_ind = i2
       2 md_superset_ind = i2
       2 pk_superset_ind = i2
       2 ndx_name = vc
       2 cols[*]
         3 column_name = vc
         3 data_type = vc
     1 md[*]
       2 column_name = vc
       2 data_type = vc
   )
   FREE RECORD trg_stmts
   RECORD trg_stmts(
     1 batch_ind = i2
     1 source_env_id = f8
     1 move_long_ind = i2
     1 table_name = vc
     1 stmt[*]
       2 str = vc
       2 end_ind = i2
       2 rdb_asis_ind = i2
       2 move_long_str_ind = i2
   )
   FREE RECORD trg_null_info
   RECORD trg_null_info(
     1 col_cnt = i4
     1 cols[*]
       2 col_name = vc
   )
   FREE RECORD trg_data_type
   RECORD trg_data_type(
     1 col_cnt = i4
     1 cols[*]
       2 col_name = vc
       2 data_type = vc
   )
   FREE RECORD soft_cons
   RECORD soft_cons(
     1 ndx[*]
       2 where_clause = vc
       2 block_where_clause = vc
       2 match_str = vc
       2 ui_superset_ind = i2
       2 ndx_name = vc
       2 reset_status = vc
       2 valid_ind = i2
       2 cols[*]
         3 column_name = vc
         3 data_type = vc
       2 col_cnt = i2
     1 ndx_cnt = i2
   )
   DECLARE get_unique_pk_info(i_table_name=vc,i_unique_ndx=vc(ref),trg_tab_info=vc(ref),trg_null_info
    =vc(ref),i_data_type=vc(ref)) = null
   DECLARE code_value_trg(i_stmt_cnt=i4(ref),i_rdds_col_str=vc,i_tab_name=vc) = c1
   DECLARE unique_check(i_tab_name=vc,i_match_str=vc,i_pk_diff_str=vc,i_ui_diff_str=vc,i_err_str=vc,
    i_stmt_cnt=i4(ref),i_tab_info=vc(ref),i_rdds_col_str=vc,i_ndx_cnt=i4,i_ndx_rec=vc(ref)) = null
   DECLARE trg_start(i_table_suffix=vc,i_trg_suffix=vc,i_update_of_str=vc,i_table_name=vc,i_stmt_cnt=
    i4(ref)) = null
   DECLARE pk_check(i_tab_name=vc,i_ui_match_str=vc,i_pk_diff_str=vc,i_err_str=vc,i_stmt_cnt=i4(ref),
    i_rdds_col_str=vc,i_tab_info=vc(ref)) = null
   DECLARE drop_trigger(i_table_name=vc,i_trigger_flag=i2) = null
   DECLARE reg_pk_check(i_tab_name=vc,i_ui_match_str=vc,i_pk_diff_str=vc,i_err_str=vc,i_stmt_cnt=i4(
     ref),
    i_rdds_col_str=vc,i_tab_info=vc(ref),i_null_info=vc(ref)) = null
   DECLARE reg_unique_check(i_tab_name=vc,i_match_str=vc,i_pk_diff_str=vc,i_ui_diff_str=vc,i_err_str=
    vc,
    i_stmt_cnt=i4(ref),i_tab_info=vc(ref),i_rdds_col_str=vc,i_ndx_cnt=i4,i_ndx_rec=vc(ref),
    i_trig_type_flag=i2) = null
   DECLARE get_vers_info(i_table_name=vc,trg_tab_info=vc(ref),i_data_type=vc(ref)) = i2
   DECLARE check_trigger(i_table_suffix=vc,i_trigger_flag=i2) = c1
   DECLARE get_soft_cons_info(i_soft_cons=vc(ref),i_tab_info=vc(ref),i_null_info=vc(ref),i_data_type=
    vc(ref)) = c1
   DECLARE md_unique_check(i_live_tab_name=vc,i_err_str=vc,i_stmt_cnt=i4(ref),i_trig_cols=vc(ref),
    i_rdds_col_str=vc,
    i_ndx_cnt=i4,i_ndx_rec=vc(ref)) = null
   DECLARE case_insensitive_replace(i_orig_str=vc,i_find_str=vc,i_new_str=vc) = vc
   DECLARE v_ndx_cnt = i4
   DECLARE v_num = i4
   DECLARE v_update_of_str = vc
   DECLARE v_pk_superset_ind = i2
   DECLARE v_rdds_col_str = vc
   DECLARE v_trigger_flag = i4
   DECLARE num = i4
   DECLARE ret = c1 WITH protect, noconstant("")
   DECLARE v_col_idx = i4 WITH protect, noconstant(0)
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE v_col_name = vc WITH protect, noconstant("")
   DECLARE v_vers_ind = i2 WITH protect, noconstant(0)
   DECLARE act_r_tab_name = vc WITH protect, noconstant("")
   DECLARE v_curqual = i4 WITH protect, noconstant(0)
   DECLARE act_ret = c1 WITH protect, noconstant(" ")
   DECLARE act_data_type = vc WITH protect, noconstant(" ")
   SET v_rdds_col_str = " rdds_status_flag < 9000 and rdds_delete_ind = 0 "
   SET trg_stmts->batch_ind = 0
   SET trg_stmts->source_env_id = 0
   SET trg_stmts->move_long_ind = 0
   SET v_trigger_flag = 0
   SET num = 0
   SET act_ret = "F"
   SET trg_tab_info->table_name = i_table_name
   SELECT INTO "nl:"
    FROM dm2_user_notnull_cols d
    WHERE d.table_name=i_table_name
    HEAD REPORT
     v_col_idx = 0
    DETAIL
     v_col_idx = (v_col_idx+ 1)
     IF (mod(v_col_idx,10)=1)
      stat = alterlist(trg_null_info->cols,(v_col_idx+ 9))
     ENDIF
     trg_null_info->cols[v_col_idx].col_name = d.column_name
    FOOT REPORT
     trg_null_info->col_cnt = v_col_idx, stat = alterlist(trg_null_info->cols,trg_null_info->col_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Check for nullable information") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    build(dtal.type,dtal.len), dtal.*
    FROM dtableattr dta,
     dtableattrl dtal
    PLAN (dta
     WHERE dta.table_name=i_table_name)
     JOIN (dtal
     WHERE dtal.structtype="F"
      AND btest(dtal.stat,11)=0)
    DETAIL
     IF (dtal.type="F")
      act_data_type = "F8"
     ELSEIF (dtal.type="I")
      act_data_type = "I4"
     ELSEIF (dtal.type="C")
      IF (btest(dtal.stat,13))
       act_data_type = "VC"
      ELSE
       act_data_type = build(dtal.type,dtal.len)
      ENDIF
     ELSEIF (dtal.type="Q")
      act_data_type = "DQ8"
     ENDIF
     trg_data_type->col_cnt = (trg_data_type->col_cnt+ 1)
     IF (mod(trg_data_type->col_cnt,9)=1)
      stat = alterlist(trg_data_type->cols,(trg_data_type->col_cnt+ 9))
     ENDIF
     trg_data_type->cols[trg_data_type->col_cnt].col_name = dtal.attr_name, trg_data_type->cols[
     trg_data_type->col_cnt].data_type = act_data_type
    FOOT REPORT
     stat = alterlist(trg_data_type->cols,trg_data_type->col_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Gathering data_type") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SET act_r_tab_name = cutover_tab_name(i_table_name,"")
   SELECT INTO "nl:"
    dcd.table_name, dcd.column_name, dcd.unique_ident_ind,
    dtd.table_suffix
    FROM dm_tables_doc_local dtd,
     dm_columns_doc_local dcd
    WHERE ((dtd.reference_ind=1
     AND dtd.mergeable_ind=1) OR (dtd.table_name IN (
    (SELECT
     rt.table_name
     FROM dm_rdds_refmrg_tables rt))))
     AND  NOT (dtd.table_name IN ("TIER_MATRIX", "APPLICATION_TASK"))
     AND  NOT (dtd.table_name IN (
    (SELECT
     display
     FROM code_value
     WHERE code_set=4001912
      AND cdf_meaning="NORDDSTRG"
      AND active_ind=1)))
     AND  NOT (dtd.table_name IN (
    (SELECT
     display
     FROM code_value
     WHERE code_set=255351
      AND cdf_meaning IN ("ALG4", "ALG5")
      AND active_ind=1)))
     AND  NOT (dtd.table_name IN (
    (SELECT
     display
     FROM code_value
     WHERE code_set=4000220
      AND cdf_meaning="INSERT_ONLY")))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_columns_doc_local dcdl
     WHERE dcdl.table_name=dtd.table_name
      AND dcdl.table_name=dcdl.root_entity_name
      AND dcdl.column_name=dcdl.root_entity_attr
      AND dcdl.exception_flg=7)))
     AND dtd.table_name=dtd.full_table_name
     AND dcd.table_name=dtd.table_name
     AND  EXISTS (
    (SELECT
     "x"
     FROM user_tab_cols utc
     WHERE utc.table_name=act_r_tab_name
      AND utc.column_name=dcd.column_name
      AND utc.hidden_column="NO"
      AND utc.virtual_column="NO"))
     AND dtd.table_name=i_table_name
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di
     WHERE di.info_domain="RDDS IGNORE COL LIST:*"
      AND sqlpassthru(" dcd.column_name like di.info_name and dcd.table_name like di.info_char"))))
     AND  NOT ( NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_columns_doc_local dc
     WHERE dc.table_name=dtd.table_name
      AND dc.unique_ident_ind=1)))
     AND  EXISTS (
    (SELECT
     "x"
     FROM dm_columns_doc_local dcdl2
     WHERE dcdl2.table_name=dtd.table_name
      AND dcdl2.table_name=dcdl2.root_entity_name
      AND dcdl2.column_name=dcdl2.root_entity_attr
      AND dcdl2.exception_flg=1)))
    ORDER BY dcd.table_name, dcd.column_name
    HEAD REPORT
     tbl_cnt = 0
    HEAD dcd.table_name
     tbl_cnt = (tbl_cnt+ 1), ui_cnt = 0, md_cnt = 0,
     trg_tab_info->table_name = dcd.table_name, trg_tab_info->table_suffix = dtd.table_suffix,
     trg_tab_info->tab_$r = act_r_tab_name,
     trg_tab_info->md_ind = dtd.merge_delete_ind
    DETAIL
     IF (dcd.unique_ident_ind=1)
      ui_cnt = (ui_cnt+ 1), stat = alterlist(trg_tab_info->ui,ui_cnt), trg_tab_info->ui[ui_cnt].
      column_name = dcd.column_name,
      trg_tab_info->ui_col_list = concat(trg_tab_info->ui_col_list,", ",trim(dcd.column_name,3))
      IF (locateval(v_num,1,trg_null_info->col_cnt,dcd.column_name,trg_null_info->cols[v_num].
       col_name)=0)
       IF (dcd.table_name="PRSNL"
        AND dcd.column_name="USERNAME")
        trg_tab_info->ui_match_str = concat(trg_tab_info->ui_match_str," and (replace(:new.",trim(dcd
          .column_name,3),",'~DM')= replace(r1.",trim(dcd.column_name,3),
         ",'~DM') or (:new.",trim(dcd.column_name,3)," is null and r1.",trim(dcd.column_name,3),
         " is null))"), trg_tab_info->ui_diff_str = concat(trg_tab_info->ui_diff_str,
         " or (replace(:new.",trim(dcd.column_name,3),",'~DM')!= replace(r1.",trim(dcd.column_name,3),
         ",'~DM') or (:new.",trim(dcd.column_name,3)," is null and r1.",trim(dcd.column_name,3),
         " is not null) or (:new.",
         trim(dcd.column_name,3)," is not null and r1.",trim(dcd.column_name,3)," is null))")
       ELSE
        trg_tab_info->ui_match_str = concat(trg_tab_info->ui_match_str," and (:new.",trim(dcd
          .column_name,3),"= r1.",trim(dcd.column_name,3),
         " or (:new.",trim(dcd.column_name,3)," is null and r1.",trim(dcd.column_name,3)," is null))"
         ), trg_tab_info->ui_diff_str = concat(trg_tab_info->ui_diff_str," or (:new.",trim(dcd
          .column_name,3),"!= r1.",trim(dcd.column_name,3),
         " or (:new.",trim(dcd.column_name,3)," is null and r1.",trim(dcd.column_name,3),
         " is not null) or (:new.",
         trim(dcd.column_name,3)," is not null and r1.",trim(dcd.column_name,3)," is null))")
       ENDIF
      ELSE
       trg_tab_info->ui_match_str = concat(trg_tab_info->ui_match_str," and :new.",trim(dcd
         .column_name,3),"= r1.",trim(dcd.column_name,3)), trg_tab_info->ui_diff_str = concat(
        trg_tab_info->ui_diff_str," or :new.",trim(dcd.column_name,3),"!= r1.",trim(dcd.column_name,3
         ))
      ENDIF
      v_idx = locateval(v_num,1,trg_data_type->col_cnt,dcd.column_name,trg_data_type->cols[v_num].
       col_name)
      IF (v_idx > 0)
       trg_tab_info->ui[ui_cnt].data_type = trg_data_type->cols[v_idx].data_type
      ENDIF
     ENDIF
     IF (dcd.merge_delete_ind=1)
      md_cnt = (md_cnt+ 1), stat = alterlist(trg_tab_info->md,md_cnt), trg_tab_info->md[md_cnt].
      column_name = dcd.column_name,
      v_idx = locateval(v_num,1,trg_data_type->col_cnt,dcd.column_name,trg_data_type->cols[v_num].
       col_name)
      IF (v_idx > 0)
       trg_tab_info->md[md_cnt].data_type = trg_data_type->cols[v_idx].data_type
      ENDIF
     ENDIF
    FOOT  dcd.table_name
     IF (dcd.table_name="CODE_VALUE")
      trg_tab_info->ui_col_list =
      "code_set, cdf_meaning, display_key, active_ind, display, definition"
     ELSE
      trg_tab_info->ui_col_list = substring(2,10000,trg_tab_info->ui_col_list)
     ENDIF
     trg_tab_info->ui_match_str = substring(6,10000,trg_tab_info->ui_match_str), trg_tab_info->
     ui_diff_str = substring(5,10000,trg_tab_info->ui_diff_str)
    WITH nocounter
   ;end select
   IF (check_error("Checking to see if table needs triggers") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SET v_curqual = curqual
   IF (get_soft_cons_info(soft_cons,trg_tab_info,trg_null_info,trg_data_type) != "S")
    RETURN("F")
   ENDIF
   IF (v_curqual=0)
    CALL drop_trigger(i_table_name,1)
    CALL drop_trigger(i_table_name,2)
    CALL drop_trigger(i_table_name,3)
    CALL drop_trigger(i_table_name,4)
    IF (check_error("Dropping the triggers") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN("F")
    ENDIF
    RETURN("Z")
   ENDIF
   FREE RECORD unique_ndx
   RECORD unique_ndx(
     1 data[*]
       2 index_name = vc
   )
   CALL get_unique_pk_info(i_table_name,unique_ndx,trg_tab_info,trg_null_info,trg_data_type)
   IF (check_error("Get Unique PK info") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    FROM dm_refchg_sql_obj drso
    WHERE drso.table_name=i_table_name
     AND drso.execution_flag=3
     AND drso.active_ind=1
     AND drso.table_name != "PRSNL"
     AND drso.column_name != "PERSON_ID"
    DETAIL
     trg_tab_info->cust_plsql_ind = 1
    WITH nocounter
   ;end select
   IF (check_error("Setting CUST_PLSQL_IND") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SET act_ret = "F"
   IF ((trg_tab_info->md_ind=1))
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(trg_tab_info)
     CALL echorecord(soft_cons)
    ENDIF
    SET ret = create_reg_md_trg_stmt(i_table_name,trg_null_info,v_rdds_col_str,soft_cons,trg_tab_info
     )
    IF (ret="S")
     EXECUTE dm_rmc_run_stmt  WITH replace("REQUEST","TRG_STMTS")
     SELECT INTO "nl:"
      FROM dm_tables_doc_local dtl
      WHERE dtl.table_name=i_table_name
      DETAIL
       dcrt_list->md_cnt = (dcrt_list->md_cnt+ 1), stat = alterlist(dcrt_list->md_list,dcrt_list->
        md_cnt), dcrt_list->md_list[dcrt_list->md_cnt].table_suffix = dtl.table_suffix
      WITH nocounter
     ;end select
     IF (check_error("Obtaining table suffix") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN("F")
     ENDIF
     IF (check_trigger(dcrt_list->md_list[dcrt_list->md_cnt].table_suffix,3) != "S")
      RETURN("F")
     ENDIF
     CALL drop_trigger(i_table_name,1)
     SET act_ret = "S"
    ELSEIF (ret="Z")
     CALL drop_trigger(i_table_name,3)
     CALL drop_trigger(i_table_name,1)
     CALL drop_trigger(i_table_name,4)
     SET act_ret = "Z"
    ELSEIF (ret="F")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN("F")
    ENDIF
   ELSE
    IF (size(trg_tab_info->ui,5)=0
     AND (trg_tab_info->table_name != "CODE_VALUE"))
     RETURN("Z")
    ENDIF
    SET v_vers_ind = get_vers_info(i_table_name,trg_tab_info,trg_data_type)
    IF (v_vers_ind < 0)
     RETURN("F")
    ELSEIF (v_vers_ind=1)
     CALL drop_trigger(i_table_name,1)
     CALL drop_trigger(i_table_name,3)
    ELSE
     CALL drop_trigger(i_table_name,4)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(trg_tab_info)
     CALL echorecord(soft_cons)
    ENDIF
    IF ((trg_tab_info->cust_plsql_ind=1)
     AND size(trg_tab_info->ndx,5)=0)
     CALL drop_trigger(i_table_name,1)
     CALL drop_trigger(i_table_name,2)
     CALL drop_trigger(i_table_name,3)
     CALL drop_trigger(i_table_name,4)
     RETURN("Z")
    ENDIF
    IF (((size(trg_tab_info->pk,5) > 0) OR (((size(trg_tab_info->ndx,5) > 0) OR ((soft_cons->ndx_cnt
     > 0))) ))
     AND (trg_tab_info->vers_ind=0))
     IF ((((trg_tab_info->table_name != "ACCOUNT")) OR (size(trg_tab_info->ui,5)=2
      AND (trg_tab_info->ui[1].column_name="ACCT_TEMPL_ID")
      AND (trg_tab_info->ui[2].column_name="BILLING_ENTITY_ID"))) )
      IF (create_reg_cutover_trg_stmt(trg_tab_info,v_rdds_col_str,trg_null_info,soft_cons)="S")
       EXECUTE dm_rmc_run_stmt  WITH replace("REQUEST","TRG_STMTS")
       SET dcrt_list->reg_cnt = (dcrt_list->reg_cnt+ 1)
       SET stat = alterlist(dcrt_list->reg_list,dcrt_list->reg_cnt)
       SET dcrt_list->reg_list[dcrt_list->reg_cnt].table_suffix = trg_tab_info->table_suffix
       IF (check_trigger(trg_tab_info->table_suffix,1) != "S")
        RETURN("F")
       ENDIF
       SET act_ret = "S"
      ELSE
       CALL drop_trigger(i_table_name,1)
       IF (check_error("Dropping the triggers") != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN("F")
       ENDIF
      ENDIF
     ELSE
      CALL drop_trigger(i_table_name,1)
      CALL drop_trigger(i_table_name,2)
      IF (check_error("Dropping the triggers") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN("F")
      ENDIF
      SET act_ret = "Z"
     ENDIF
    ELSEIF ((trg_tab_info->vers_ind=1))
     IF (create_reg_vers_trg_stmt(trg_tab_info,v_rdds_col_str,trg_null_info,soft_cons)="S")
      EXECUTE dm_rmc_run_stmt  WITH replace("REQUEST","TRG_STMTS")
      SET dcrt_list->vr_cnt = (dcrt_list->vr_cnt+ 1)
      SET stat = alterlist(dcrt_list->vr_list,dcrt_list->vr_cnt)
      SET dcrt_list->vr_list[dcrt_list->vr_cnt].table_suffix = trg_tab_info->table_suffix
      IF (check_trigger(trg_tab_info->table_suffix,4) != "S")
       RETURN("F")
      ENDIF
      SET act_ret = "S"
     ELSE
      CALL drop_trigger(i_table_name,4)
      IF (check_error("Dropping the triggers") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN("F")
      ENDIF
     ENDIF
    ELSE
     CALL drop_trigger(i_table_name,1)
     CALL drop_trigger(i_table_name,2)
     CALL drop_trigger(i_table_name,4)
     IF (check_error("Dropping the triggers") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN("F")
     ENDIF
     SET act_ret = "Z"
    ENDIF
   ENDIF
   IF (act_ret != "F")
    IF (create_$r_cutover_trg_stmt(trg_tab_info," 1 = 1 ",soft_cons)="S")
     EXECUTE dm_rmc_run_stmt  WITH replace("REQUEST","TRG_STMTS")
     SET dcrt_list->r_cnt = (dcrt_list->r_cnt+ 1)
     SET stat = alterlist(dcrt_list->r_list,dcrt_list->r_cnt)
     SET dcrt_list->r_list[dcrt_list->r_cnt].table_suffix = trg_tab_info->table_suffix
     IF (check_trigger(trg_tab_info->table_suffix,2) != "S")
      RETURN("F")
     ENDIF
    ELSE
     CALL drop_trigger(i_table_name,2)
     IF (check_error("Dropping the triggers") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN("F")
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD trg_stmts
   FREE RECORD trg_tab_info
   FREE RECORD unique_ndx
   FREE RECORD soft_cons
   FREE RECORD trg_data_type
   RETURN("S")
 END ;Subroutine
 SUBROUTINE get_unique_pk_info(i_table_name,i_unique_ndx,i_tab_info,i_null_info,i_data_type)
   DECLARE gupi_num = i4 WITH protect, noconstant(0)
   DECLARE gupi_idx = i4 WITH protect, noconstant(0)
   DECLARE gupi_pk_ui_ind = i2 WITH protect, noconstant(0)
   DECLARE ui_cnt = i4 WITH protect, noconstant(0)
   DECLARE distinct_col_cnt = i4 WITH protect, noconstant(0)
   DECLARE gupi_pk_con = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ucc.column_name
    FROM user_constraints uc,
     user_cons_columns ucc
    WHERE (uc.table_name=i_tab_info->table_name)
     AND uc.constraint_type="P"
     AND uc.constraint_name=ucc.constraint_name
     AND uc.table_name=ucc.table_name
     AND  NOT (uc.table_name IN (
    (SELECT
     utc.table_name
     FROM user_tab_cols utc
     WHERE utc.table_name=ucc.table_name
      AND utc.column_name=ucc.column_name
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" utc.column_name like di.info_name and utc.table_name like di.info_char")))
     )) )) )))
    ORDER BY ucc.table_name, ucc.column_name
    HEAD ucc.table_name
     col_cnt = 0, same_ind = 1
    DETAIL
     i_tab_info->pk_diff_str = concat(i_tab_info->pk_diff_str," or :new.",trim(ucc.column_name,3),
      "!= r1.",trim(ucc.column_name,3)), i_tab_info->pk_match_str = concat(i_tab_info->pk_match_str,
      " and :new.",trim(ucc.column_name,3),"= r1.",trim(ucc.column_name,3)), col_cnt = (col_cnt+ 1),
     gupi_pk_con = 1, stat = alterlist(i_tab_info->pk,col_cnt), i_tab_info->pk[col_cnt].column_name
      = ucc.column_name
     IF (col_cnt <= size(i_tab_info->ui,5))
      IF ((ucc.column_name != i_tab_info->ui[col_cnt].column_name))
       same_ind = 0
      ENDIF
     ENDIF
     gupi_idx = locateval(gupi_num,1,i_data_type->col_cnt,ucc.column_name,i_data_type->cols[gupi_num]
      .col_name)
     IF (gupi_idx > 0)
      i_tab_info->pk[col_cnt].data_type = i_data_type->cols[gupi_idx].data_type
     ENDIF
    FOOT  ucc.table_name
     IF (same_ind=1
      AND col_cnt=size(i_tab_info->ui,5))
      stat = alterlist(i_tab_info->pk,0), i_tab_info->pk_diff_str = "", i_tab_info->pk_match_str = "",
      gupi_pk_ui_ind = 1, gupi_pk_con = 0
     ELSE
      i_tab_info->pk_diff_str = substring(5,10000,i_tab_info->pk_diff_str), i_tab_info->pk_match_str
       = substring(6,10000,i_tab_info->pk_match_str)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Getting pk info") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=patstring(concat("RDDS PK OVERRIDE:",i_tab_info->table_name,"/*"))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di2
     WHERE sqlpassthru("di.info_name like di2.info_char and di.info_char like di2.info_name ")
      AND di2.info_domain="RDDS IGNORE COL LIST:*")))
    ORDER BY di.info_name, di.info_char
    HEAD di.info_name
     IF (gupi_pk_con=0)
      col_cnt = 0, same_ind = 1
     ELSE
      col_cnt = 0, ui_cnt = (ui_cnt+ 1), stat = alterlist(i_tab_info->ndx,ui_cnt),
      start_distinct_cnt = distinct_col_cnt, i_tab_info->ndx[ui_cnt].ndx_name = concat("PK_OVRRD_",
       i_tab_info->table_name)
     ENDIF
    DETAIL
     IF (gupi_pk_con=0)
      i_tab_info->pk_diff_str = concat(i_tab_info->pk_diff_str," or :new.",trim(di.info_char,3),
       "!= r1.",trim(di.info_char,3)), i_tab_info->pk_match_str = concat(i_tab_info->pk_match_str,
       " and :new.",trim(di.info_char,3),"= r1.",trim(di.info_char,3)), col_cnt = (col_cnt+ 1),
      stat = alterlist(i_tab_info->pk,col_cnt), i_tab_info->pk[col_cnt].column_name = di.info_char
      IF (col_cnt <= size(i_tab_info->ui,5))
       IF ((di.info_char != i_tab_info->ui[col_cnt].column_name))
        same_ind = 0
       ENDIF
      ENDIF
      gupi_idx = locateval(gupi_num,1,i_data_type->col_cnt,di.info_char,i_data_type->cols[gupi_num].
       col_name)
      IF (gupi_idx > 0)
       i_tab_info->pk[col_cnt].data_type = i_data_type->cols[gupi_idx].data_type
      ENDIF
     ELSE
      col_cnt = (col_cnt+ 1), stat = alterlist(i_tab_info->ndx[ui_cnt].cols,col_cnt), i_tab_info->
      ndx[ui_cnt].cols[col_cnt].column_name = di.info_char
      IF (locateval(v_num,1,distinct_col_cnt,di.info_char,i_tab_info->distinct_cols[v_num].
       column_name)=0)
       distinct_col_cnt = (distinct_col_cnt+ 1), stat = alterlist(i_tab_info->distinct_cols,
        distinct_col_cnt), i_tab_info->distinct_cols[distinct_col_cnt].column_name = di.info_char
      ENDIF
      IF (locateval(gupi_num,1,i_null_info->col_cnt,di.info_char,i_null_info->cols[gupi_num].col_name
       )=0)
       i_tab_info->ndx[ui_cnt].match_str = concat(i_tab_info->ndx[ui_cnt].match_str," and (:new.",
        trim(di.info_char,3),"= r1.",trim(di.info_char,3),
        " or (:new.",trim(di.info_char,3)," is null and r1.",trim(di.info_char,3)," is null))")
      ELSE
       i_tab_info->ndx[ui_cnt].match_str = concat(i_tab_info->ndx[ui_cnt].match_str," and :new.",trim
        (di.info_char,3),"= r1.",trim(di.info_char,3))
      ENDIF
      gupi_idx = locateval(gupi_num,1,i_data_type->col_cnt,di.info_char,i_data_type->cols[gupi_num].
       col_name)
      IF (gupi_idx > 0)
       i_tab_info->ndx[ui_cnt].cols[col_cnt].data_type = i_data_type->cols[gupi_idx].data_type
      ENDIF
     ENDIF
    FOOT  di.info_name
     IF (gupi_pk_con=0)
      IF (same_ind=1
       AND col_cnt=size(i_tab_info->ui,5))
       stat = alterlist(i_tab_info->pk,0), i_tab_info->pk_diff_str = "", i_tab_info->pk_match_str =
       "",
       gupi_pk_ui_ind = 1
      ELSE
       i_tab_info->pk_diff_str = substring(5,10000,i_tab_info->pk_diff_str), i_tab_info->pk_match_str
        = substring(6,10000,i_tab_info->pk_match_str)
      ENDIF
     ELSE
      i_tab_info->ndx[ui_cnt].match_str = substring(6,10000,i_tab_info->ndx[ui_cnt].match_str)
      IF (size(i_tab_info->ui,5) > 0)
       i_tab_info->ndx[ui_cnt].ui_superset_ind = 1
       FOR (ui_ndx = 1 TO size(i_tab_info->ui,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->ui[ui_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          i_tab_info->ndx[ui_cnt].ui_superset_ind = 0
         ENDIF
       ENDFOR
       IF ((i_tab_info->ndx[ui_cnt].ui_superset_ind=1))
        IF (size(i_tab_info->ui,5)=size(i_tab_info->ndx[ui_cnt].cols,5))
         i_tab_info->ui_ndx_ind = 1
        ENDIF
       ENDIF
      ENDIF
      IF (size(i_tab_info->md,5) > 0)
       i_tab_info->ndx[ui_cnt].md_superset_ind = 1
       FOR (md_ndx = 1 TO size(i_tab_info->md,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->md[md_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          i_tab_info->ndx[ui_cnt].md_superset_ind = 0
         ENDIF
       ENDFOR
      ENDIF
      IF (size(i_tab_info->pk,5) > 0)
       v_pk_superset_ind = 1
       FOR (pk_ndx = 1 TO size(i_tab_info->pk,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->pk[pk_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          v_pk_superset_ind = 0
         ENDIF
       ENDFOR
       IF (v_pk_superset_ind=1)
        ui_cnt = (ui_cnt - 1), stat = alterlist(i_tab_info->ndx,ui_cnt), stat = alterlist(i_tab_info
         ->distinct_cols,start_distinct_cnt),
        distinct_col_cnt = start_distinct_cnt
       ENDIF
      ELSEIF (gupi_pk_ui_ind=1)
       v_pk_superset_ind = 1
       FOR (pk_ndx = 1 TO size(i_tab_info->ui,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->ui[pk_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          v_pk_superset_ind = 0
         ENDIF
       ENDFOR
       IF (v_pk_superset_ind=1)
        ui_cnt = (ui_cnt - 1), stat = alterlist(i_tab_info->ndx,ui_cnt), stat = alterlist(i_tab_info
         ->distinct_cols,start_distinct_cnt),
        distinct_col_cnt = start_distinct_cnt
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Gathering unique index column information") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SET stat = alterlist(unique_ndx->data,0)
   SET v_ndx_cnt = 0
   SELECT INTO "nl:"
    ui.index_name
    FROM user_indexes ui
    WHERE (ui.table_name=i_tab_info->table_name)
     AND ui.uniqueness="UNIQUE"
     AND ui.table_owner="V500"
     AND ui.index_type="NORMAL"
    DETAIL
     v_ndx_cnt = (v_ndx_cnt+ 1), stat = alterlist(unique_ndx->data,v_ndx_cnt), unique_ndx->data[
     v_ndx_cnt].index_name = ui.index_name
    WITH nocounter
   ;end select
   IF (check_error("Gathering index information") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF (v_ndx_cnt > 0)
    SELECT INTO "nl:"
     uic.index_name, uic.column_name
     FROM user_ind_columns uic
     WHERE expand(v_num,1,v_ndx_cnt,uic.index_name,unique_ndx->data[v_num].index_name)
      AND (uic.table_name=i_tab_info->table_name)
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE sqlpassthru("uic.table_name like di.info_char and uic.column_name like di.info_name ")
       AND di.info_domain="RDDS IGNORE COL LIST:*")))
     ORDER BY uic.index_name, uic.column_name
     HEAD REPORT
      ui_cnt = 0, distinct_col_cnt = 0
     HEAD uic.index_name
      ui_cnt = (ui_cnt+ 1), stat = alterlist(i_tab_info->ndx,ui_cnt), col_cnt = 0,
      start_distinct_cnt = distinct_col_cnt, i_tab_info->ndx[ui_cnt].ndx_name = uic.index_name
     DETAIL
      col_cnt = (col_cnt+ 1), stat = alterlist(i_tab_info->ndx[ui_cnt].cols,col_cnt), i_tab_info->
      ndx[ui_cnt].cols[col_cnt].column_name = uic.column_name
      IF (locateval(v_num,1,distinct_col_cnt,uic.column_name,i_tab_info->distinct_cols[v_num].
       column_name)=0)
       distinct_col_cnt = (distinct_col_cnt+ 1), stat = alterlist(i_tab_info->distinct_cols,
        distinct_col_cnt), i_tab_info->distinct_cols[distinct_col_cnt].column_name = uic.column_name
      ENDIF
      IF (locateval(gupi_num,1,i_null_info->col_cnt,uic.column_name,i_null_info->cols[gupi_num].
       col_name)=0)
       i_tab_info->ndx[ui_cnt].match_str = concat(i_tab_info->ndx[ui_cnt].match_str," and (:new.",
        trim(uic.column_name,3),"= r1.",trim(uic.column_name,3),
        " or (:new.",trim(uic.column_name,3)," is null and r1.",trim(uic.column_name,3)," is null))")
      ELSE
       i_tab_info->ndx[ui_cnt].match_str = concat(i_tab_info->ndx[ui_cnt].match_str," and :new.",trim
        (uic.column_name,3),"= r1.",trim(uic.column_name,3))
      ENDIF
      gupi_idx = locateval(gupi_num,1,i_data_type->col_cnt,uic.column_name,i_data_type->cols[gupi_num
       ].col_name)
      IF (gupi_idx > 0)
       i_tab_info->ndx[ui_cnt].cols[col_cnt].data_type = i_data_type->cols[gupi_idx].data_type
      ENDIF
     FOOT  uic.index_name
      i_tab_info->ndx[ui_cnt].match_str = substring(6,10000,i_tab_info->ndx[ui_cnt].match_str)
      IF (size(i_tab_info->ui,5) > 0)
       i_tab_info->ndx[ui_cnt].ui_superset_ind = 1
       FOR (ui_ndx = 1 TO size(i_tab_info->ui,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->ui[ui_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          i_tab_info->ndx[ui_cnt].ui_superset_ind = 0
         ENDIF
       ENDFOR
       IF ((i_tab_info->ndx[ui_cnt].ui_superset_ind=1))
        IF (size(i_tab_info->ui,5)=size(i_tab_info->ndx[ui_cnt].cols,5))
         i_tab_info->ui_ndx_ind = 1
        ENDIF
       ENDIF
      ENDIF
      IF (size(i_tab_info->md,5) > 0)
       i_tab_info->ndx[ui_cnt].md_superset_ind = 1
       FOR (md_ndx = 1 TO size(i_tab_info->md,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->md[md_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          i_tab_info->ndx[ui_cnt].md_superset_ind = 0
         ENDIF
       ENDFOR
      ENDIF
      IF (size(i_tab_info->pk,5) > 0)
       v_pk_superset_ind = 1
       FOR (pk_ndx = 1 TO size(i_tab_info->pk,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->pk[pk_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          v_pk_superset_ind = 0
         ENDIF
       ENDFOR
       IF (v_pk_superset_ind=1)
        ui_cnt = (ui_cnt - 1), stat = alterlist(i_tab_info->ndx,ui_cnt), stat = alterlist(i_tab_info
         ->distinct_cols,start_distinct_cnt),
        distinct_col_cnt = start_distinct_cnt
       ENDIF
      ELSEIF (gupi_pk_ui_ind=1)
       v_pk_superset_ind = 1
       FOR (pk_ndx = 1 TO size(i_tab_info->ui,5))
         IF (locateval(v_num,1,size(i_tab_info->ndx[ui_cnt].cols,5),i_tab_info->ui[pk_ndx].
          column_name,i_tab_info->ndx[ui_cnt].cols[v_num].column_name)=0)
          v_pk_superset_ind = 0
         ENDIF
       ENDFOR
       IF (v_pk_superset_ind=1)
        ui_cnt = (ui_cnt - 1), stat = alterlist(i_tab_info->ndx,ui_cnt), stat = alterlist(i_tab_info
         ->distinct_cols,start_distinct_cnt),
        distinct_col_cnt = start_distinct_cnt
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Gathering unique index column information") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN("F")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE create_reg_cutover_trg_stmt(i_tab_info,i_rdds_col_str,i_null_info,i_soft_cons)
   DECLARE ndx_cnt = i4
   DECLARE crct_stmt_cnt = i4
   DECLARE crct_return_val = c1
   DECLARE cvt_sub_ret = c1
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE crct_data_type = vc WITH protect, noconstant("")
   SET crct_return_val = "F"
   SET crct_stmt_cnt = 0
   SET v_update_of_str = i_tab_info->ui_col_list
   FOR (c_ndx = 1 TO size(i_tab_info->distinct_cols,5))
     IF (locateval(v_num,1,size(i_tab_info->ui,5),i_tab_info->distinct_cols[c_ndx].column_name,
      i_tab_info->ui[v_num].column_name)=0)
      SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->distinct_cols[c_ndx].column_name)
     ENDIF
   ENDFOR
   FOR (c_ndx = 1 TO size(i_tab_info->pk,5))
     IF (locateval(v_num,1,size(i_tab_info->ui,5),i_tab_info->pk[c_ndx].column_name,i_tab_info->ui[
      v_num].column_name)=0
      AND locateval(v_num,1,size(i_tab_info->distinct_cols,5),i_tab_info->pk[c_ndx].column_name,
      i_tab_info->distinct_cols[v_num].column_name)=0)
      SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->pk[c_ndx].column_name)
     ENDIF
   ENDFOR
   CALL trg_start(i_tab_info->table_suffix,"_REG_MC",v_update_of_str,i_tab_info->table_name,
    crct_stmt_cnt)
   IF ((i_tab_info->table_name="CODE_VALUE"))
    SET cvt_sub_ret = code_value_trg(crct_stmt_cnt,i_rdds_col_str,i_tab_info->tab_$r)
    SET crct_return_val = cvt_sub_ret
   ELSE
    IF (size(i_tab_info->pk,5) > 0)
     FOR (c_ndx = 1 TO size(i_tab_info->pk,5))
       CALL add_stmt(concat("  v_pk",trim(cnvtstring(c_ndx))," ",i_tab_info->table_name,".",
         i_tab_info->pk[c_ndx].column_name,"%type;"),1,0,0,crct_stmt_cnt,
        trg_stmts)
     ENDFOR
    ELSE
     FOR (c_ndx = 1 TO size(i_tab_info->ui,5))
       CALL add_stmt(concat("  v_pk",trim(cnvtstring(c_ndx))," ",i_tab_info->table_name,".",
         i_tab_info->ui[c_ndx].column_name,"%type;"),1,0,0,crct_stmt_cnt,
        trg_stmts)
     ENDFOR
    ENDIF
    CALL add_stmt("   v_pkw dm_refchg_rtable_reset.pk_where%type;",1,0,0,crct_stmt_cnt,
     trg_stmts)
    CALL add_stmt("begin ",1,0,0,crct_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0
     AND (i_tab_info->cust_plsql_ind=0))
     CALL reg_pk_check(i_tab_info->tab_$r,i_tab_info->ui_match_str,i_tab_info->pk_diff_str,"-20200",
      crct_stmt_cnt,
      i_rdds_col_str,i_tab_info,i_null_info)
     SET crct_return_val = "S"
    ENDIF
    FOR (ndx_cnt = 1 TO size(i_tab_info->ndx,5))
      IF ((((i_tab_info->ndx[ndx_cnt].ui_superset_ind=0)) OR ((i_tab_info->cust_plsql_ind=1))) )
       CALL reg_unique_check(i_tab_info->tab_$r,i_tab_info->ndx[ndx_cnt].match_str,i_tab_info->
        pk_diff_str,i_tab_info->ui_diff_str,"-20200",
        crct_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_tab_info,
        1)
       SET crct_return_val = "S"
      ENDIF
    ENDFOR
    FOR (ndx_cnt = 1 TO i_soft_cons->ndx_cnt)
     CALL reg_unique_check(i_tab_info->tab_$r,i_soft_cons->ndx[ndx_cnt].match_str,i_tab_info->
      pk_diff_str,i_tab_info->ui_diff_str,"-20200",
      crct_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_soft_cons,
      5)
     SET crct_return_val = "S"
    ENDFOR
    CALL add_stmt(" end; ",1,1,0,crct_stmt_cnt,
     trg_stmts)
   ENDIF
   RETURN(crct_return_val)
 END ;Subroutine
 SUBROUTINE create_$r_cutover_trg_stmt(i_tab_info,i_rdds_col_str,i_soft_cons)
   DECLARE ndx_cnt = i4
   DECLARE crct_stmt_cnt = i4
   DECLARE crct_return_val = c1
   DECLARE cvt_sub_ret = c1
   SET crct_return_val = "F"
   SET crct_stmt_cnt = 0
   IF ((i_tab_info->ui_col_list > " "))
    SET v_update_of_str = concat(" , ",i_tab_info->ui_col_list)
   ENDIF
   FOR (c_ndx = 1 TO size(i_tab_info->distinct_cols,5))
     IF (locateval(v_num,1,size(i_tab_info->ui,5),i_tab_info->distinct_cols[c_ndx].column_name,
      i_tab_info->ui[v_num].column_name)=0)
      SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->distinct_cols[c_ndx].column_name)
     ENDIF
   ENDFOR
   FOR (c_ndx = 1 TO size(i_tab_info->pk,5))
     IF (locateval(v_num,1,size(i_tab_info->ui,5),i_tab_info->pk[c_ndx].column_name,i_tab_info->ui[
      v_num].column_name)=0
      AND locateval(v_num,1,size(i_tab_info->distinct_cols,5),i_tab_info->pk[c_ndx].column_name,
      i_tab_info->distinct_cols[v_num].column_name)=0)
      SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->pk[c_ndx].column_name)
     ENDIF
   ENDFOR
   FOR (c_ndx = 1 TO i_soft_cons->ndx_cnt)
     FOR (v_idx = 1 TO i_soft_cons->ndx[c_ndx].col_cnt)
       IF (locateval(v_num,1,size(i_tab_info->ui,5),i_soft_cons->ndx[c_ndx].cols[v_idx].column_name,
        i_tab_info->ui[v_num].column_name)=0
        AND locateval(v_num,1,size(i_tab_info->distinct_cols,5),i_soft_cons->ndx[c_ndx].cols[v_idx].
        column_name,i_tab_info->distinct_cols[v_num].column_name)=0
        AND locateval(v_num,1,size(i_tab_info->pk,5),i_soft_cons->ndx[c_ndx].cols[v_idx].column_name,
        i_tab_info->pk[v_num].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_soft_cons->ndx[c_ndx].cols[v_idx].
         column_name)
       ENDIF
     ENDFOR
   ENDFOR
   SET v_update_of_str = substring(3,10000,v_update_of_str)
   CALL trg_start(i_tab_info->table_suffix,"_$R_MC",v_update_of_str,i_tab_info->tab_$r,crct_stmt_cnt)
   IF ((i_tab_info->table_name="CODE_VALUE"))
    SET cvt_sub_ret = code_value_trg(crct_stmt_cnt,i_rdds_col_str,i_tab_info->table_name)
    SET crct_return_val = cvt_sub_ret
   ELSE
    CALL add_stmt("begin ",1,0,0,crct_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0
     AND (i_tab_info->ui_ndx_ind=1)
     AND (i_tab_info->cust_plsql_ind=0)
     AND (i_tab_info->md_ind=0))
     CALL pk_check(i_tab_info->table_name,i_tab_info->ui_match_str,i_tab_info->pk_diff_str,"-20201",
      crct_stmt_cnt,
      i_rdds_col_str,i_tab_info)
     SET crct_return_val = "S"
    ENDIF
    FOR (ndx_cnt = 1 TO size(i_tab_info->ndx,5))
      IF ((((((i_tab_info->ndx[ndx_cnt].ui_superset_ind=0)) OR ((((i_tab_info->ui_ndx_ind=0)) OR ((
      i_tab_info->cust_plsql_ind=1))) ))
       AND (i_tab_info->md_ind=0)
       AND (i_tab_info->vers_ind=0)) OR ((((i_tab_info->md_ind=1)
       AND (i_tab_info->ndx[ndx_cnt].md_superset_ind=0)) OR ((i_tab_info->vers_ind=1)
       AND (i_tab_info->ndx[ndx_cnt].pk_superset_ind=0))) )) )
       CALL unique_check(i_tab_info->table_name,i_tab_info->ndx[ndx_cnt].match_str,i_tab_info->
        pk_diff_str,i_tab_info->ui_diff_str,"-20201",
        crct_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_tab_info)
       SET crct_return_val = "S"
      ENDIF
    ENDFOR
    FOR (ndx_cnt = 1 TO i_soft_cons->ndx_cnt)
      IF ((i_soft_cons->ndx[ndx_cnt].valid_ind=1))
       CALL unique_check(i_tab_info->table_name,i_soft_cons->ndx[ndx_cnt].match_str,i_tab_info->
        pk_diff_str,i_tab_info->ui_diff_str,"-20201",
        crct_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_soft_cons)
       SET crct_return_val = "S"
      ENDIF
    ENDFOR
    CALL add_stmt(" end; ",1,1,0,crct_stmt_cnt,
     trg_stmts)
   ENDIF
   RETURN(crct_return_val)
 END ;Subroutine
 SUBROUTINE trg_start(i_table_suffix,i_trg_suffix,i_update_of_str,i_table_name,i_stmt_cnt)
   DECLARE s_when_str = vc
   CALL add_stmt(build("create or replace trigger REFCHG",i_table_suffix,i_trg_suffix),1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat(" before insert or update of ",i_update_of_str),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat(" on ",i_table_name," for each row "),1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (i_table_name="PATHWAY_CATALOG")
    CALL add_stmt(
     " WHEN ((NVL(SYS_CONTEXT( 'CERNER', 'FIRE_RMC_TRG'), 'DM2NULLVAL') != 'NO') and (new.type_mean != 'PHASE')",
     1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(" WHEN ((NVL(SYS_CONTEXT( 'CERNER', 'FIRE_RMC_TRG'), 'DM2NULLVAL') != 'NO') ",1,0,0,
     i_stmt_cnt,
     trg_stmts)
   ENDIF
   IF (i_trg_suffix="_$R_MC")
    CALL add_stmt(" and (new.rdds_delete_ind = 0))  ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(")  ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("declare ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (i_trg_suffix="_$R_MC")
    CALL add_stmt("   pragma autonomous_transaction; ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("  v_cnt_var number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_disp_str varchar2 (500);",1,0,0,i_stmt_cnt,
    trg_stmts)
 END ;Subroutine
 SUBROUTINE pk_check(i_tab_name,i_ui_match_str,i_pk_diff_str,i_err_str,i_stmt_cnt,i_rdds_col_str,
  i_tab_info)
   DECLARE v_r_tab_ind = i2 WITH protect, noconstant(0)
   DECLARE v_rae_r_str = vc WITH protect
   DECLARE v_rae_str = vc WITH protect
   DECLARE v_rae_col_name = vc WITH protect
   DECLARE v_rae_live_pk = vc
   DECLARE v_rae_r_pk = vc
   DECLARE v_rae_rpk_col = vc
   DECLARE v_rae_live_ui = vc
   DECLARE v_rae_r_ui = vc
   DECLARE v_rae_rui_col = vc
   DECLARE v_disp_str = vc
   DECLARE v_rae_ui_match_str = vc
   DECLARE v_rae_pk_match_str = vc
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   IF (i_tab_name=patstring("*$R"))
    SET v_r_tab_ind = 1
   ENDIF
   IF (v_r_tab_ind=0)
    CALL add_stmt("if (:new.rdds_delete_ind = 0 and :new.rdds_status_flag = 0) then ",1,0,0,
     i_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->ui,5) > 0)
     FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
       IF (v_rae_rui_col > " ")
        SET v_rae_col_name = concat(v_rae_col_name,", ",i_tab_info->ui[col_cnt].column_name)
        IF (i_table_name IN ("PRSNL", "PRSNL0386$R")
         AND (i_tab_info->ui[col_cnt].column_name="USERNAME"))
         SET v_rae_rui_col = concat(v_rae_rui_col,"|| ',' ||nvl(to_char(replace(r1.",i_tab_info->ui[
          col_cnt].column_name,",'~DM')),'NULL')")
         SET v_rae_r_ui = concat(v_rae_r_ui,"||' and ",i_tab_info->ui[col_cnt].column_name,
          " ='||nvl(to_char(replace(:new.",i_tab_info->ui[col_cnt].column_name,
          ",'~DM')),'NULL')")
        ELSE
         SET v_rae_rui_col = concat(v_rae_rui_col,"|| ',' ||nvl(to_char(r1.",i_tab_info->ui[col_cnt].
          column_name,"),'NULL')")
         SET v_rae_r_ui = concat(v_rae_r_ui,"||' and ",i_tab_info->ui[col_cnt].column_name,
          " ='||nvl(to_char(:new.",i_tab_info->ui[col_cnt].column_name,
          "),'NULL')")
        ENDIF
        SET v_rae_ui_match_str = concat(v_rae_ui_match_str," , ",i_tab_info->ui[col_cnt].column_name)
       ELSE
        SET v_rae_col_name = i_tab_info->ui[col_cnt].column_name
        SET v_rae_rui_col = concat("nvl(to_char(r1.",i_tab_info->ui[col_cnt].column_name,"),'NULL')")
        SET v_rae_r_ui = concat(i_tab_info->ui[col_cnt].column_name," ='||nvl(to_char(:new.",
         i_tab_info->ui[col_cnt].column_name,"),'NULL')")
        SET v_rae_ui_match_str = i_tab_info->ui[col_cnt].column_name
       ENDIF
     ENDFOR
    ENDIF
    IF (size(i_tab_info->pk,5) > 0)
     SET v_rae_live_pk = "'||v_disp_str||'"
     FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
       IF (v_rae_rpk_col > " ")
        SET v_rae_col_name = concat(v_rae_col_name,", ",i_tab_info->pk[col_cnt].column_name)
        SET v_rae_rpk_col = concat(v_rae_rpk_col,"|| ',' ||r1.",i_tab_info->pk[col_cnt].column_name)
        SET v_rae_r_pk = concat(v_rae_r_pk,"||' and ",i_tab_info->pk[col_cnt].column_name,
         " ='||:new.",i_tab_info->pk[col_cnt].column_name)
        SET v_rae_pk_match_str = concat(v_rae_pk_match_str," and ",i_tab_info->pk[col_cnt].
         column_name," ='||:new.",i_tab_info->pk[col_cnt].column_name,
         "||'")
       ELSE
        SET v_rae_col_name = i_tab_info->pk[col_cnt].column_name
        SET v_rae_rpk_col = concat("r1.",i_tab_info->pk[col_cnt].column_name)
        SET v_rae_r_pk = concat(i_tab_info->pk[col_cnt].column_name," ='||:new.",i_tab_info->pk[
         col_cnt].column_name)
        SET v_rae_pk_match_str = concat(i_tab_info->pk[col_cnt].column_name," ='||:new.",i_tab_info->
         pk[col_cnt].column_name,"||'")
       ENDIF
     ENDFOR
    ENDIF
    SET v_rae_r_str = concat("'Uptime RDDS: Row found in the target where ",v_rae_ui_match_str,
     " and it conflicts with values",
     " attempted to be inserted into the $R table. Primary key for live table is ",v_rae_col_name,
     " with a value of ",v_rae_live_pk,". Primary key for $R row was ",v_rae_r_pk)
   ENDIF
   CALL add_stmt(concat(" select count(*) into v_cnt_var "),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("   from ",i_tab_name," r1 "),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("  where (",trim(i_ui_match_str,3),")"),1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt(concat("    and (",trim(i_rdds_col_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSEIF (v_r_tab_ind=0)
    CALL add_stmt("    and not exists ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("      (select 'x' ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("         from ",i_tab_info->tab_$r," r2 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("        where r2.rdds_status_flag < 9000 ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("         and ",replace(i_tab_info->pk_match_str,":new","r2",0)," )"),1,0,0,
     i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(concat("    and (",trim(i_pk_diff_str,3),");"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" if (v_cnt_var > 0) then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL echo("#030 pk_check - add table suffix")
    CALL add_stmt(concat("   RAISE_APPLICATION_ERROR(",i_err_str),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(",'Uptime RDDS - ",i_tab_info->table_suffix,
      ": Attempted to add a new unique value that RDDS is also going to add.');"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(concat("   select to_char(",v_rae_rpk_col,") into v_disp_str "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   from ",i_tab_name," r1 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("  where (",trim(i_ui_match_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    and not exists ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("      (select 'x' ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("         from ",i_tab_info->tab_$r," r2 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("        where r2.rdds_status_flag < 9000 ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("         and ",replace(i_tab_info->pk_match_str,":new","r2",0)," )"),1,0,0,
     i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("    and (",trim(i_pk_diff_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" and rownum = 1;",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(" Dm2_context_control('R_TRIGGER_ERROR',",v_rae_r_str,");"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   RAISE_APPLICATION_ERROR(",i_err_str),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(",'<err>R_TRIGGER_ERROR</err>');",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(" end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt(" end if;",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
 END ;Subroutine
 SUBROUTINE unique_check(i_tab_name,i_match_str,i_pk_diff_str,i_ui_diff_str,i_err_str,i_stmt_cnt,
  i_tab_info,i_rdds_col_str,i_ndx_cnt,i_ndx_rec)
   DECLARE rmc_ind = i2
   SET rmc_ind = 0
   DECLARE v_rae_str = vc
   DECLARE v_rae_match_str = vc
   DECLARE v_rae_live_pk = vc
   DECLARE v_rae_r_pk = vc
   DECLARE v_rae_pk_start = i4
   DECLARE v_rae_rpk_start = i4
   DECLARE v_rae_pk_end = i4
   DECLARE v_rae_rpk_end = i4
   DECLARE v_rae_rpk_col = vc
   DECLARE v_rae_r_str = vc
   DECLARE v_rae_col_name = vc
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_disp_str = vc
   IF ((trg_stmts->stmt[1].str="*_$R_MC*"))
    SET rmc_ind = 1
   ENDIF
   IF (rmc_ind=1)
    IF (size(i_tab_info->pk,5) > 0)
     SET v_rae_rpk_start = findstring(":new",i_pk_diff_str,1,0)
     SET v_rae_rpk_end = findstring("!=",i_pk_diff_str,v_rae_pk_start,0)
     SET v_rae_pk_start = (v_rae_rpk_end+ 3)
     SET v_rae_pk_end = (size(i_pk_diff_str)+ 1)
     SET v_rae_live_pk = "||v_disp_str||"
     FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
       IF (v_rae_rpk_col > " ")
        SET v_rae_col_name = concat(v_rae_col_name,", ",i_tab_info->pk[col_cnt].column_name)
        SET v_rae_rpk_col = concat(v_rae_rpk_col,"|| ',' ||r1.",i_tab_info->pk[col_cnt].column_name)
        SET v_rae_r_pk = concat(v_rae_r_pk,"||' and ",i_tab_info->pk[col_cnt].column_name,
         " ='||:new.",i_tab_info->pk[col_cnt].column_name)
       ELSE
        SET v_rae_col_name = i_tab_info->pk[col_cnt].column_name
        SET v_rae_rpk_col = concat("r1.",i_tab_info->pk[col_cnt].column_name)
        SET v_rae_r_pk = concat(i_tab_info->pk[col_cnt].column_name," ='||:new.",i_tab_info->pk[
         col_cnt].column_name)
       ENDIF
     ENDFOR
    ELSE
     SET v_rae_rpk_start = findstring(":new",i_ui_diff_str,1,0)
     SET v_rae_rpk_end = findstring("!=",i_ui_diff_str,v_rae_pk_start,0)
     SET v_rae_pk_start = (v_rae_rpk_end+ 3)
     SET v_rae_pk_end = (size(i_ui_diff_str)+ 1)
     SET v_rae_live_pk = "||v_disp_str||"
     FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
       IF (v_rae_rpk_col > " ")
        SET v_rae_col_name = concat(v_rae_col_name,", ",i_tab_info->ui[col_cnt].column_name)
        SET v_rae_rpk_col = concat(v_rae_rpk_col,"|| ',' ||nvl(to_char(r1.",i_tab_info->ui[col_cnt].
         column_name,"),'NULL')")
        SET v_rae_r_pk = concat(v_rae_r_pk,"||' and ",i_tab_info->ui[col_cnt].column_name,
         " ='||nvl(to_char(:new.",i_tab_info->ui[col_cnt].column_name,
         "),'NULL')")
       ELSE
        SET v_rae_col_name = i_tab_info->ui[col_cnt].column_name
        SET v_rae_rpk_col = concat("nvl(to_char(r1.",i_tab_info->ui[col_cnt].column_name,"),'NULL')")
        SET v_rae_r_pk = concat(i_tab_info->ui[col_cnt].column_name," ='||nvl(to_char(:new.",
         i_tab_info->ui[col_cnt].column_name,"),'NULL')")
       ENDIF
     ENDFOR
    ENDIF
    FOR (col_cnt = 1 TO size(i_ndx_rec->ndx[i_ndx_cnt].cols,5))
      IF (v_rae_match_str > " ")
       SET v_rae_match_str = concat(v_rae_match_str,", ",i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].
        column_name)
      ELSE
       SET v_rae_match_str = i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name
      ENDIF
    ENDFOR
    SET v_rae_str = concat("'Uptime RDDS: Row found in the target where ",v_rae_match_str,
     " column(s) conflict with values attempted to be inserted in $R table. Primary key for live table is ",
     v_rae_col_name," with value of '",
     v_rae_live_pk,"'. Primary key for $R row was ",v_rae_r_pk)
    CALL echo(v_rae_str)
    SET v_rae_r_str = concat("'Uptime RDDS: Row found in the target $R where ",v_rae_match_str,
     " column(s) conflict with other values attempted to be inserted in $R table. ",
     "Primary key for blocking row on $R table is ",v_rae_col_name,
     " with value of '",v_rae_live_pk,"'. Primary key for new $R row was ",v_rae_r_pk)
    CALL echo(v_rae_r_str)
   ENDIF
   CALL add_stmt(" begin ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" v_cnt_var := 0; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" select count(*) into v_cnt_var ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("   from ",i_tab_name," r1 "),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("  where (",trim(i_match_str,3),")"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("    and (",trim(i_rdds_col_str,3),")"),1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (size(i_tab_info->pk,5) > 0)
    CALL add_stmt(concat("    and (",trim(i_pk_diff_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(concat("    and (",trim(i_ui_diff_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   IF (rmc_ind=1)
    CALL add_stmt("    and not exists ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("      (select 'x' ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("         from ",i_tab_info->tab_$r," r2 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("        where r2.rdds_status_flag < 9000 ",1,0,0,i_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0)
     CALL add_stmt(concat("         and ",replace(i_tab_info->pk_match_str,":new","r2",0)," );"),1,0,
      0,i_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(concat("         and ",replace(i_tab_info->ui_match_str,":new","r2",0)," );"),1,0,
      0,i_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(" if v_cnt_var = 0 then ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" select count(*) into v_cnt_var ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("    from ",i_tab_info->tab_$r," r1 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   where (",trim(i_match_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("     and ( r1.rdds_status_flag < 9000 )",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("     and ( r1.rdds_delete_ind = 0 )",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("     and (",trim(i_rdds_col_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0)
     CALL add_stmt(concat("     and (",trim(i_pk_diff_str,3),");"),1,0,0,i_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(concat("     and (",trim(i_ui_diff_str,3),");"),1,0,0,i_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(" if v_cnt_var > 0 then ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   select to_char(",v_rae_rpk_col,") into v_disp_str "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("    from ",i_tab_info->tab_$r," r1 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   where (",trim(i_match_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("     and ( r1.rdds_status_flag < 9000 )",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("     and ( r1.rdds_delete_ind = 0 )",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("     and (",trim(i_rdds_col_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0)
     CALL add_stmt(concat("     and (",trim(i_pk_diff_str,3),")"),1,0,0,i_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(concat("     and (",trim(i_ui_diff_str,3),")"),1,0,0,i_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(" and rownum = 1; ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(" Dm2_context_control('R_TRIGGER_ERROR',",v_rae_r_str,");"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   RAISE_APPLICATION_ERROR(",i_err_str),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(",'<err>R_TRIGGER_ERROR</err>');",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" end if; ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" end if; ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(";",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(" if v_cnt_var > 0 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (rmc_ind=1)
    CALL add_stmt(concat("   select to_char(",v_rae_rpk_col,") into v_disp_str "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   from ",i_tab_name," r1 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("  where (",trim(i_match_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("    and (",trim(i_rdds_col_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0)
     CALL add_stmt(concat("    and (",trim(i_pk_diff_str,3),")"),1,0,0,i_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(concat("    and (",trim(i_ui_diff_str,3),")"),1,0,0,i_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt("    and not exists ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("      (select 'x' ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("         from ",i_tab_info->tab_$r," r2 "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("        where r2.rdds_status_flag < 9000 ",1,0,0,i_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0)
     CALL add_stmt(concat("         and ",replace(i_tab_info->pk_match_str,":new","r2",0)," )"),1,0,0,
      i_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(concat("         and ",replace(i_tab_info->ui_match_str,":new","r2",0)," )"),1,0,0,
      i_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(" and rownum = 1;",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(" Dm2_context_control('R_TRIGGER_ERROR',",v_rae_str,");"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(concat("   RAISE_APPLICATION_ERROR(",i_err_str),1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (i_err_str="-20200")
    CALL echo("#030 Unique_check - add table suffix")
    CALL add_stmt(concat(",'Uptime RDDS - ",i_tab_info->table_suffix,
      ": Attempted to add a new unique index value that RDDS is also going to add.');"),1,0,0,
     i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(",'<err>R_TRIGGER_ERROR</err>');",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(" end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" end;",1,0,0,i_stmt_cnt,
    trg_stmts)
 END ;Subroutine
 SUBROUTINE reg_pk_check(i_tab_name,i_ui_match_str,i_pk_diff_str,i_err_str,i_stmt_cnt,i_rdds_col_str,
  i_tab_info,i_null_info)
   DECLARE v_r_tab_ind = i2 WITH protect, noconstant(0)
   DECLARE v_rae_r_str = vc WITH protect
   DECLARE v_rae_str = vc WITH protect
   DECLARE v_rae_col_name = vc WITH protect
   DECLARE v_rae_live_pk = vc
   DECLARE v_rae_r_pk = vc
   DECLARE v_rae_rpk_col = vc
   DECLARE v_rae_live_ui = vc
   DECLARE v_rae_r_ui = vc
   DECLARE v_rae_rui_col = vc
   DECLARE v_disp_str = vc
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_col_str = vc WITH protect, noconstant("")
   DECLARE v_pk_str = vc WITH protect, noconstant("")
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE v_block_stmt = vc WITH protect, noconstant("")
   DECLARE v_col_list = vc WITH protect, noconstant("")
   DECLARE v_null_str = vc WITH protect, noconstant("")
   FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
    IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->ui[col_cnt].column_name,i_null_info->cols[
     v_idx].col_name)=0)
     IF ((i_tab_info->ui[col_cnt].data_type="F*"))
      SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,",-123888.4321)")
     ELSEIF ((i_tab_info->ui[col_cnt].data_type="I*"))
      SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,",-123888)")
     ELSEIF ((i_tab_info->ui[col_cnt].data_type="DQ8"))
      SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,
       ",cnvtdatetime(cnvtdate(07231882),215212))")
     ELSE
      IF (i_tab_name IN ("PRSNL", "PRSNL0386$R")
       AND (i_tab_info->ui[col_cnt].column_name="USERNAME"))
       SET v_null_str = concat("nullval(replace(",i_tab_info->ui[col_cnt].column_name,
        ",''~DM'',''''),''null_vaLue_CHeck_894.3'')")
      ELSE
       SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,
        ",''null_vaLue_CHeck_894.3'')")
      ENDIF
     ENDIF
    ELSE
     SET v_null_str = i_tab_info->ui[col_cnt].column_name
    ENDIF
    IF (col_cnt=1)
     SET v_col_list = concat(" '||'",v_null_str,"'")
    ELSE
     SET v_col_list = concat(v_col_list," ||',",v_null_str,"' ")
    ENDIF
   ENDFOR
   CALL add_stmt(" begin ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  select ",1,0,0,i_stmt_cnt,
    trg_stmts)
   FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
     IF (col_cnt=1)
      SET v_col_str = concat("r1.",i_tab_info->pk[col_cnt].column_name)
      SET v_pk_str = concat("v_pk",trim(cnvtstring(col_cnt)))
     ELSE
      SET v_col_str = concat(v_col_str,", r1.",i_tab_info->pk[col_cnt].column_name)
      SET v_pk_str = concat(v_pk_str,",v_pk",trim(cnvtstring(col_cnt)))
     ENDIF
   ENDFOR
   CALL add_stmt(concat(" ",v_col_str," into ",v_pk_str," "),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("   from ",i_tab_name," r1 "),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("  where (",trim(i_ui_match_str,3),")"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("    and (",trim(i_rdds_col_str,3),")"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("    and (",trim(i_pk_diff_str,3),") and rownum = 1;"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("   if dm_refchg_dual_build_reject = 0 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    select substr(",1,0,0,i_stmt_cnt,
    trg_stmts)
   FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
     IF (col_cnt != 1)
      CALL add_stmt("||' and '||",1,0,0,i_stmt_cnt,
       trg_stmts)
     ENDIF
     CALL add_stmt(concat("'",i_tab_info->pk[col_cnt].column_name,"'||"),1,0,0,i_stmt_cnt,
      trg_stmts)
     IF ((i_tab_info->pk[col_cnt].data_type IN ("VC", "C*")))
      CALL add_stmt(concat("decode(:new.",i_tab_info->pk[col_cnt].column_name,
        ",null,' is null ',chr(0),'=char(0)','='||"," dm_refchg_breakup_str(:new.",i_tab_info->pk[
        col_cnt].column_name,
        "))"),1,0,0,i_stmt_cnt,
       trg_stmts)
     ELSEIF ((i_tab_info->pk[col_cnt].data_type="DQ8"))
      CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->pk[col_cnt].column_name,
        "),null,' is null ',' = cnvtdatetimeutc('||","'^'|| to_char(:new.",i_tab_info->pk[col_cnt].
        column_name,
        ",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,i_stmt_cnt,
       trg_stmts)
     ELSE
      CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->pk[col_cnt].column_name,
        "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(:new.",i_tab_info->pk[col_cnt].column_name,
        "))"),1,0,0,i_stmt_cnt,
       trg_stmts)
     ENDIF
   ENDFOR
   CALL add_stmt(",1,2000) into v_pkw from dual;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("   proc_refchg_ins_drrr('",i_tab_info->table_name,"',v_pkw,2,null,"),1,0,0,
    i_stmt_cnt,
    trg_stmts)
   SET v_block_stmt = concat("'from ",i_tab_name," r where list(",v_col_list,"||')")
   SET v_block_stmt = concat(v_block_stmt," in (select ",v_col_list,"||' from ",i_tab_info->
    table_name,
    " where '||v_pkw||') and ",i_rdds_col_str)
   SET v_block_stmt = concat(v_block_stmt," and not ('||v_pkw||')'")
   CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'UNPROCESSED');"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("   else ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    select substr(",1,0,0,i_stmt_cnt,
    trg_stmts)
   FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
     IF (col_cnt != 1)
      CALL add_stmt("||' and '||",1,0,0,i_stmt_cnt,
       trg_stmts)
     ENDIF
     CALL add_stmt(concat("'",i_tab_info->pk[col_cnt].column_name,"'||"),1,0,0,i_stmt_cnt,
      trg_stmts)
     IF ((i_tab_info->pk[col_cnt].data_type IN ("VC", "C*")))
      CALL add_stmt(concat("decode(v_pk",trim(cnvtstring(col_cnt)),
        ",null,' is null ',chr(0),'=char(0)','='||"," dm_refchg_breakup_str(v_pk",trim(cnvtstring(
          col_cnt)),
        "))"),1,0,0,i_stmt_cnt,
       trg_stmts)
     ELSEIF ((i_tab_info->pk[col_cnt].data_type="DQ8"))
      CALL add_stmt(concat("decode(to_char(v_pk",trim(cnvtstring(col_cnt)),
        "),null,' is null ',' = cnvtdatetimeutc('||","'^'|| to_char(v_pk",trim(cnvtstring(col_cnt)),
        ",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,i_stmt_cnt,
       trg_stmts)
     ELSE
      CALL add_stmt(concat("decode(to_char(v_pk",trim(cnvtstring(col_cnt)),
        "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(v_pk",trim(cnvtstring(col_cnt)),
        "))"),1,0,0,i_stmt_cnt,
       trg_stmts)
     ENDIF
   ENDFOR
   CALL add_stmt(",1,2000) into v_pkw from dual; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("    proc_refchg_ins_drrr_auton('",i_tab_info->table_name,"',v_pkw,2,null,"),
    1,0,0,i_stmt_cnt,
    trg_stmts)
   SET v_block_stmt = concat("'from ",i_tab_name," r where list(",v_col_list,"||')")
   SET v_block_stmt = concat(v_block_stmt," in (select ",v_col_list,"||' from ",i_tab_name,
    " where '||v_pkw||') and ",i_rdds_col_str,"'")
   CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'VIOLATION');"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("    RAISE_APPLICATION_ERROR(",i_err_str),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat(",'Uptime RDDS - ",i_tab_info->table_suffix,
     ": Attempted to add a new unique value that RDDS is also going to add.');"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" exception when no_data_found then null; /* This means no problem was found */",1,0,
    0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" end;",1,0,0,i_stmt_cnt,
    trg_stmts)
 END ;Subroutine
 SUBROUTINE reg_unique_check(i_tab_name,i_match_str,i_pk_diff_str,i_ui_diff_str,i_err_str,i_stmt_cnt,
  i_tab_info,i_rdds_col_str,i_ndx_cnt,i_ndx_rec,i_trig_type_flag)
   DECLARE rmc_ind = i2
   SET rmc_ind = 0
   DECLARE v_rae_str = vc
   DECLARE v_rae_match_str = vc
   DECLARE v_rae_live_pk = vc
   DECLARE v_rae_r_pk = vc
   DECLARE v_rae_pk_start = i4
   DECLARE v_rae_rpk_start = i4
   DECLARE v_rae_pk_end = i4
   DECLARE v_rae_rpk_end = i4
   DECLARE v_rae_rpk_col = vc
   DECLARE v_rae_r_str = vc
   DECLARE v_rae_col_name = vc
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_disp_str = vc
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_col_str = vc WITH protect, noconstant("")
   DECLARE v_pk_str = vc WITH protect, noconstant("")
   DECLARE v_block_stmt = vc WITH protect, noconstant("")
   DECLARE v_ndx_cols = vc WITH protect, noconstant("")
   DECLARE v_null_str = vc WITH protect, noconstant("")
   DECLARE v_no_block_status = vc WITH protect, noconstant("UNPROCESSED")
   DECLARE v_block_where_ind = i2 WITH protect, noconstant(0)
   IF (validate(i_ndx_rec->ndx[i_ndx_cnt].reset_status,"-1") != "-1")
    IF (size(trim(i_ndx_rec->ndx[i_ndx_cnt].reset_status),1) > 0)
     SET v_no_block_status = trim(i_ndx_rec->ndx[i_ndx_cnt].reset_status)
    ENDIF
   ENDIF
   IF (validate(i_ndx_rec->ndx[i_ndx_cnt].block_where_clause,"-1") != "-1")
    IF (size(trim(i_ndx_rec->ndx[i_ndx_cnt].block_where_clause),1) > 0)
     SET v_block_where_ind = 1
    ENDIF
   ENDIF
   FOR (col_cnt = 1 TO size(i_ndx_rec->ndx[i_ndx_cnt].cols,5))
    IF (locateval(v_idx,1,i_null_info->col_cnt,i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name,
     i_null_info->cols[v_idx].col_name)=0)
     IF ((i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].data_type="F*"))
      SET v_null_str = concat("nullval(",i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name,
       ",-123888.4321)")
     ELSEIF ((i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].data_type="I*"))
      SET v_null_str = concat("nullval(",i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name,
       ",-123888)")
     ELSEIF ((i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].data_type="DQ8"))
      SET v_null_str = concat("nullval(",i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name,
       ",cnvtdatetime(cnvtdate(07231882),215212))")
     ELSE
      IF (i_tab_name IN ("PRSNL", "PRSNL0386$R")
       AND (i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name="USERNAME"))
       SET v_null_str = concat("nullval(replace(",i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name,
        ",''~DM'',''''),''null_vaLue_CHeck_894.3'')")
      ELSE
       SET v_null_str = concat("nullval(",i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name,
        ",''null_vaLue_CHeck_894.3'')")
      ENDIF
     ENDIF
    ELSE
     SET v_null_str = i_ndx_rec->ndx[i_ndx_cnt].cols[col_cnt].column_name
    ENDIF
    IF (col_cnt=1)
     SET v_ndx_cols = concat(" '||'",v_null_str,"'")
    ELSE
     SET v_ndx_cols = concat(v_ndx_cols," ||',",v_null_str,"' ")
    ENDIF
   ENDFOR
   CALL add_stmt(" begin ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" select ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (size(i_tab_info->pk,5) > 0)
    FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
      IF (col_cnt=1)
       SET v_col_str = concat("r1.",i_tab_info->pk[col_cnt].column_name)
       SET v_pk_str = concat("v_pk",trim(cnvtstring(col_cnt)))
      ELSE
       SET v_col_str = concat(v_col_str,", r1.",i_tab_info->pk[col_cnt].column_name)
       SET v_pk_str = concat(v_pk_str,",v_pk",trim(cnvtstring(col_cnt)))
      ENDIF
    ENDFOR
   ELSE
    FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
      IF (col_cnt=1)
       SET v_col_str = concat("r1.",i_tab_info->ui[col_cnt].column_name)
       SET v_pk_str = concat("v_pk",trim(cnvtstring(col_cnt)))
      ELSE
       SET v_col_str = concat(v_col_str,", r1.",i_tab_info->ui[col_cnt].column_name)
       SET v_pk_str = concat(v_pk_str,",v_pk",trim(cnvtstring(col_cnt)))
      ENDIF
    ENDFOR
   ENDIF
   CALL add_stmt(concat(" ",v_col_str," into ",v_pk_str," "),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("   from ",i_tab_name," r1 "),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("  where (",trim(i_match_str,3),")"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("    and (",trim(i_rdds_col_str,3),")"),1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (size(i_tab_info->pk,5) > 0)
    CALL add_stmt(concat("    and (",trim(i_pk_diff_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(concat("    and (",trim(i_ui_diff_str,3),")"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(" and rownum = 1;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("   if dm_refchg_dual_build_reject = 0 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    select substr(",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (size(i_tab_info->pk,5) > 0)
    FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
      IF (col_cnt != 1)
       CALL add_stmt("||' and '||",1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
      CALL add_stmt(concat("'",i_tab_info->pk[col_cnt].column_name,"'||"),1,0,0,i_stmt_cnt,
       trg_stmts)
      IF ((i_tab_info->pk[col_cnt].data_type IN ("VC", "C*")))
       CALL add_stmt(concat("decode(:new.",i_tab_info->pk[col_cnt].column_name,
         ",null,' is null ',chr(0),'=char(0)','='||"," dm_refchg_breakup_str(:new.",i_tab_info->pk[
         col_cnt].column_name,
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ELSEIF ((i_tab_info->pk[col_cnt].data_type="DQ8"))
       CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->pk[col_cnt].column_name,
         "),null,' is null ',' = cnvtdatetimeutc('||'^'|| to_char(:new.",i_tab_info->pk[col_cnt].
         column_name,",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,
        i_stmt_cnt,
        trg_stmts)
      ELSE
       CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->pk[col_cnt].column_name,
         "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(:new.",i_tab_info->pk[col_cnt].
         column_name,
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
    ENDFOR
   ELSE
    FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
      IF (col_cnt != 1)
       CALL add_stmt("||' and '||",1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
      CALL add_stmt(concat("'",i_tab_info->ui[col_cnt].column_name,"'||"),1,0,0,i_stmt_cnt,
       trg_stmts)
      IF ((i_tab_info->ui[col_cnt].data_type IN ("VC", "C*")))
       CALL add_stmt(concat("decode(:new.",i_tab_info->ui[col_cnt].column_name,
         ",null,' is null ',chr(0),'=char(0)','='||"," dm_refchg_breakup_str(:new.",i_tab_info->ui[
         col_cnt].column_name,
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ELSEIF ((i_tab_info->ui[col_cnt].data_type="DQ8"))
       CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->ui[col_cnt].column_name,
         "),null,' is null ',' = cnvtdatetimeutc('||'^'|| to_char(:new.",i_tab_info->ui[col_cnt].
         column_name,",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,
        i_stmt_cnt,
        trg_stmts)
      ELSE
       CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->ui[col_cnt].column_name,
         "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(:new.",i_tab_info->ui[col_cnt].
         column_name,
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
    ENDFOR
   ENDIF
   CALL add_stmt(",1,2000) into v_pkw from dual;",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF ((((i_tab_info->table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))) OR ((i_tab_info->vers_alg=
   "ALG2"))) )
    CALL add_stmt(concat("   proc_refchg_ins_drrr_auton('",i_tab_info->table_name,"',v_pkw,",trim(
       cnvtstring(i_trig_type_flag)),",'",
      i_ndx_rec->ndx[i_ndx_cnt].ndx_name,"',"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(concat("   proc_refchg_ins_drrr('",i_tab_info->table_name,"',v_pkw,",trim(
       cnvtstring(i_trig_type_flag)),",'",
      i_ndx_rec->ndx[i_ndx_cnt].ndx_name,"',"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   SET v_block_stmt = concat("'from ",i_tab_name," r where list(",v_ndx_cols,"||')")
   SET v_block_stmt = concat(v_block_stmt," in (select ",v_ndx_cols,"||' from ",i_tab_info->
    table_name,
    " where '||v_pkw||') and ",i_rdds_col_str)
   IF (v_block_where_ind=1)
    SET v_block_stmt = concat(v_block_stmt," and ",i_ndx_rec->ndx[i_ndx_cnt].block_where_clause)
   ENDIF
   SET v_block_stmt = concat(v_block_stmt," and not ('||v_pkw||')")
   SET v_block_stmt = concat(v_block_stmt,"'")
   CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'",v_no_block_status,"');"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("   else ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    select substr(",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (size(i_tab_info->pk,5) > 0)
    FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
      IF (col_cnt != 1)
       CALL add_stmt("||' and '||",1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
      CALL add_stmt(concat("'",i_tab_info->pk[col_cnt].column_name,"'||"),1,0,0,i_stmt_cnt,
       trg_stmts)
      IF ((i_tab_info->pk[col_cnt].data_type IN ("VC", "C*")))
       CALL add_stmt(concat("decode(v_pk",trim(cnvtstring(col_cnt)),
         ",null,' is null ',chr(0),'=char(0)','='||"," dm_refchg_breakup_str(v_pk",trim(cnvtstring(
           col_cnt)),
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ELSEIF ((i_tab_info->pk[col_cnt].data_type="DQ8"))
       CALL add_stmt(concat("decode(to_char(v_pk",trim(cnvtstring(col_cnt)),
         "),null,' is null ',' = cnvtdatetimeutc('||","'^'|| to_char(v_pk",trim(cnvtstring(col_cnt)),
         ",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ELSE
       CALL add_stmt(concat("decode(to_char(v_pk",trim(cnvtstring(col_cnt)),
         "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(v_pk",trim(cnvtstring(col_cnt)),
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
    ENDFOR
   ELSE
    FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
      IF (col_cnt != 1)
       CALL add_stmt("||' and '||",1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
      CALL add_stmt(concat("'",i_tab_info->ui[col_cnt].column_name,"'||"),1,0,0,i_stmt_cnt,
       trg_stmts)
      IF ((i_tab_info->ui[col_cnt].data_type IN ("VC", "C*")))
       CALL add_stmt(concat("decode(v_pk",trim(cnvtstring(col_cnt)),
         ",null,' is null ',chr(0),'=char(0)','='||"," dm_refchg_breakup_str(v_pk",trim(cnvtstring(
           col_cnt)),
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ELSEIF ((i_tab_info->ui[col_cnt].data_type="DQ8"))
       CALL add_stmt(concat("decode(to_char(v_pk",trim(cnvtstring(col_cnt)),
         "),null,' is null ',' = cnvtdatetimeutc('||","'^'|| to_char(v_pk",trim(cnvtstring(col_cnt)),
         ",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ELSE
       CALL add_stmt(concat("decode(to_char(v_pk",trim(cnvtstring(col_cnt)),
         "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(v_pk",trim(cnvtstring(col_cnt)),
         "))"),1,0,0,i_stmt_cnt,
        trg_stmts)
      ENDIF
    ENDFOR
   ENDIF
   CALL add_stmt(",1,2000) into v_pkw from dual;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("    proc_refchg_ins_drrr_auton('",i_tab_info->table_name,"',v_pkw,",trim(
      cnvtstring(i_trig_type_flag)),",'",
     i_ndx_rec->ndx[i_ndx_cnt].ndx_name,"',"),1,0,0,i_stmt_cnt,
    trg_stmts)
   SET v_block_stmt = concat("'from ",i_tab_name," r where list(",v_ndx_cols,"||')")
   SET v_block_stmt = concat(v_block_stmt," in (select ",v_ndx_cols,"||' from ",i_tab_name,
    " where '||v_pkw||') and ",i_rdds_col_str)
   IF (v_block_where_ind=1)
    SET v_block_stmt = concat(v_block_stmt," and ",i_ndx_rec->ndx[i_ndx_cnt].block_where_clause)
   ENDIF
   SET v_block_stmt = concat(v_block_stmt,"'")
   CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'VIOLATION');"),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("   RAISE_APPLICATION_ERROR(",i_err_str),1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL echo("#030 Unique_check - add table suffix")
   CALL add_stmt(concat(",'Uptime RDDS - ",i_tab_info->table_suffix,
     ": Attempted to add a new unique index value that RDDS is also going to add.');"),1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" exception when no_data_found then null; /* This means no problem was found */",1,0,
    0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" end;",1,0,0,i_stmt_cnt,
    trg_stmts)
 END ;Subroutine
 SUBROUTINE code_value_trg(i_stmt_cnt,i_rdds_col_str,i_tab_name)
   DECLARE v_r_tab_ind = i2 WITH protect, noconstant(0)
   DECLARE if_stmt2 = vc WITH protect, noconstant("")
   DECLARE v_block_stmt = vc WITH protect, noconstant("")
   IF (i_tab_name=patstring("*$R"))
    SET v_r_tab_ind = 1
   ENDIF
   DECLARE if_stmt = vc
   SET if_stmt = ""
   CALL add_stmt("  v_dup_str varchar2(2000); ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_SQL_str varchar2(2000); ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  cur number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  ret number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_cdf_meaning_dup_ind number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_display_key_dup_ind number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_active_ind_dup_ind number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_display_dup_ind number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_definition_dup_ind number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt("  v_error_msg varchar2(2000); ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   IF (v_r_tab_ind=1)
    CALL add_stmt("  v_dup_col_list varchar2(250); ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("  v_code_value number; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_continue_ind number := 0; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_error_ind number := 0; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("begin ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt(" if (:new.rdds_delete_ind = 0 and :new.rdds_status_flag = 0) then ",1,0,0,
     i_stmt_cnt,
     trg_stmts)
   ENDIF
   SELECT INTO "NL:"
    dmc.info_name
    FROM dm_info dmc
    WHERE dmc.info_domain="RDDS CODE_VALUES ALLOWED DUPS"
    DETAIL
     IF (trim(if_stmt) > " ")
      if_stmt = concat(if_stmt," and ",":new.code_set != ",dmc.info_name)
     ELSE
      if_stmt = concat(":new.code_set != ",dmc.info_name)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Querying for code_set values that are allowed dups") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF (trim(if_stmt,3) > "")
    CALL add_stmt(concat("  if(",if_stmt,") then"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   IF (v_r_tab_ind=0)
    CALL add_stmt("  select count(*) into v_cnt_var  ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  from code_value  ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  where code_value = :new.code_value;  ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  if(v_cnt_var = 0) then  ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   SET if_stmt2 = ""
   SELECT INTO "NL:"
    di.info_char
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="CKI PATTERN MATCH*"
    DETAIL
     IF (trim(if_stmt2) > " ")
      if_stmt2 = concat(if_stmt2," or :new.cki like '",trim(replace(di.info_char,char(42),"%",0)),
       "'")
     ELSE
      if_stmt2 = concat(" rtrim(:new.cki) > ' ' and (:new.cki like '",trim(replace(di.info_char,char(
          42),"%",0)),"'")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Querying for cki values for pattern match") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF (trim(if_stmt2,3) > "")
    CALL add_stmt(concat("  if",if_stmt2,") then"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("        begin ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat("select r.code_value into v_code_value from ",i_tab_name," r "),1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("        where r.code_set = :new.code_set ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("          and r.cki = :new.cki ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt(" and not exists (select 'x' from CODE_VALUE0619$R r2 ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" where r2.rdds_status_flag < 9000 and r2.code_value = r.code_value) ",1,0,0,
     i_stmt_cnt,
     trg_stmts)
   ELSEIF (v_r_tab_ind=1)
    CALL add_stmt(concat(" and ",trim(i_rdds_col_str,3)),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("          and rownum = 1 ; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("        if v_code_value != :new.code_value then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("          v_error_ind := 1 ; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt("           v_error_msg := 'Uptime RDDS: Row found in target where CKI = '",1,0,0,
     i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("||:new.cki|| ' and it conflicts with values attempted to ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("be inserted in $R table.  Primary key for LIVE tables is '",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("|| v_code_value || ', primary key for $R row was '",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("|| :new.code_value|| '.';",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("        End if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("        exception ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("          when no_data_found then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("            v_continue_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("        end; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      else ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("        v_continue_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      End if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    if v_continue_ind = 1 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    begin ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    "      select cdf_meaning_dup_ind, display_key_dup_ind, active_ind_dup_ind, display_dup_ind, definition_dup_ind ",
    1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    " into v_cdf_meaning_dup_ind, v_display_key_dup_ind, v_active_ind_dup_ind, v_display_dup_ind, v_definition_dup_ind ",
    1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("        from code_value_set where code_set = :new.code_set; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    "      if v_cdf_meaning_dup_ind = 0 and v_display_key_dup_ind = 0 and v_active_ind_dup_ind = 0 and ",
    1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         v_display_dup_ind = 0 and v_definition_dup_ind = 0 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("          v_cdf_meaning_dup_ind := 1;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("          v_display_dup_ind := 1;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("          v_display_key_dup_ind := 1;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    exception ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      when no_data_found then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         v_cdf_meaning_dup_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         v_active_ind_dup_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         v_display_dup_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         v_display_key_dup_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         v_definition_dup_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    end; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      if v_cdf_meaning_dup_ind = 1 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         if :new.cdf_meaning is null then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("            v_dup_str := v_dup_str || 'and r.cdf_meaning is null '; ",1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         else",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    "           v_dup_str := v_dup_str || 'and ''' || replace(:new.cdf_meaning,'''','''''') ||''' = r.cdf_meaning '; ",
    1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt(
     "        v_dup_col_list := v_dup_col_list || ',nullval(CDF_MEANING,''null_vaLue_CHeck_894.3'')';",
     1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("      end if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      if v_display_key_dup_ind = 1 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         if :new.display_key is null then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("            v_dup_str := v_dup_str || 'and r.display_key is null '; ",1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         else",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    "           v_dup_str := v_dup_str || 'and ''' || replace(:new.display_key,'''','''''') ||''' = r.display_key '; ",
    1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt(
     "        v_dup_col_list := v_dup_col_list || ',nullval(DISPLAY_KEY,''null_vaLue_CHeck_894.3'')';",
     1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("      end if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      if v_active_ind_dup_ind = 1 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         if :new.active_ind is null then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("            v_dup_str := v_dup_str || 'and r.active_ind is null '; ",1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         else",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    "          v_dup_str := v_dup_str || 'and ' || :new.active_ind || ' = r.active_ind '; ",1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt("        v_dup_col_list := v_dup_col_list || ',nullval(ACTIVE_IND,-123888)';",1,0,0,
     i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("      end if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      if v_display_dup_ind = 1 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         if :new.display is null then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("            v_dup_str := v_dup_str || 'and r.display is null '; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         else",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    "           v_dup_str := v_dup_str || 'and ''' || replace(:new.display,'''','''''') ||''' = r.display '; ",
    1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt(
     "        v_dup_col_list := v_dup_col_list || ',nullval(DISPLAY,''null_vaLue_CHeck_894.3'')';",1,
     0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("      end if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("      if v_definition_dup_ind = 1 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         if :new.definition is null then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("            v_dup_str := v_dup_str || 'and r.definition is null '; ",1,0,0,
    i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         else",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt(
    "           v_dup_str := v_dup_str || 'and ''' || replace(:new.definition,'''','''''') ||''' = r.definition '; ",
    1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("         end if;",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt(
     "        v_dup_col_list := v_dup_col_list || ',nullval(DEFINITION,''null_vaLue_CHeck_894.3'')';",
     1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("      end if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt("  v_dup_col_list := substr(v_dup_col_list,2);",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(concat("  V_sql_str := 'Select r.code_value from ",i_tab_name,
     " r where ' || :new.code_set || ' = r.code_set ' ||"),1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=1)
    CALL add_stmt(concat("' and (",trim(i_rdds_col_str,3),") ' ||"),1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("  v_dup_str || ' and ' || :new.code_value || ' != r.code_value and rownum=1 ' ",1,0,
    0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt(" ||' and not exists (select ''x'' from CODE_VALUE0619$R r2 ' ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" ||' where r2.rdds_status_flag < 9000 and r2.code_value = r.code_value)'; ",1,0,0,
     i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(" ; ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("  cur := dbms_sql.open_cursor; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  dbms_sql.parse(cur, v_sql_str, 1); ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  dbms_sql.define_column(cur, 1, v_code_value); ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  ret := dbms_sql.execute(cur); ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  IF dbms_sql.fetch_rows(cur)>0 THEN ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    dbms_sql.column_value(cur, 1, v_code_value); ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  END IF; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  dbms_sql.close_cursor(cur); ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  if v_code_value > 0 then ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("  v_error_ind := 1; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt("           v_error_msg := 'Uptime RDDS: Row found in target conflicts on ",1,0,0,
     i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("the dup indicators with values attempted to be inserted in ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("$R table for CODE_SET  = ' ||:new.code_set|| '.  Primary key ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("for LIVE tables is ' || v_code_value || ', primary key for ",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("$R row was ' || :new.code_value|| '.' ;",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt(" end if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   CALL add_stmt("    end if; ",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt("    end if; ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("    if (v_error_ind = 1) then",1,0,0,i_stmt_cnt,
    trg_stmts)
   IF (v_r_tab_ind=0)
    CALL add_stmt(concat(" Dm2_context_control('R_TRIGGER_ERROR',v_error_msg);"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("      RAISE_APPLICATION_ERROR(-20201",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(",'<err>R_TRIGGER_ERROR</err>');",1,0,0,i_stmt_cnt,
     trg_stmts)
   ELSE
    CALL add_stmt(concat("     if dm_refchg_dual_build_reject = 0 and ",
      "NVL(SYS_CONTEXT( 'CERNER', 'DBARCH_PACK_INST'), 'DM2NULLVAL') != 'YES' then "),1,0,0,
     i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(
      "     proc_refchg_ins_drrr('CODE_VALUE','CODE_VALUE ='||:new.code_value||'.0'/* pk_where */,2,null,"
      ),1,0,0,i_stmt_cnt,
     trg_stmts)
    SET v_block_stmt = concat("'from ",i_tab_name," r where list('||v_dup_col_list||')")
    SET v_block_stmt = concat(v_block_stmt," in (select '||v_dup_col_list||' from CODE_VALUE ",
     " where CODE_VALUE ='||:new.code_value||'.0) and ",i_rdds_col_str,"'")
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'UNPROCESSED');"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("     elsif dm_refchg_dual_build_reject = 1 and ",
      "NVL(SYS_CONTEXT( 'CERNER', 'DBARCH_PACK_INST'), 'DM2NULLVAL') != 'YES' then "),1,0,0,
     i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(
      "      proc_refchg_ins_drrr_auton('CODE_VALUE','CODE_VALUE ='||v_code_value||'.0'/* pk_where */,2,null,"
      ),1,0,0,i_stmt_cnt,
     trg_stmts)
    SET v_block_stmt = concat("'from ",i_tab_name," r where list('||v_dup_col_list||')")
    SET v_block_stmt = concat(v_block_stmt," in (select '||v_dup_col_list||' from CODE_VALUE0619$R ",
     " where CODE_VALUE ='||v_code_value||'.0) and ",i_rdds_col_str,"'")
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'VIOLATION');"),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("     end if;",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("     if dm_refchg_dual_build_reject = 1 or ",
      "NVL(SYS_CONTEXT( 'CERNER', 'DBARCH_PACK_INST'), 'DM2NULLVAL') = 'YES' then "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(
      "      RAISE_APPLICATION_ERROR(-20202,'Uptime RDDS(' || v_code_value || '): ",
      "Attempted to add a new unique value that RDDS is also going to add.'); "),1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt("     end if;",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   IF (trim(if_stmt,3) > "")
    CALL add_stmt("    end if; ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   IF (trim(if_stmt2,3) > "")
    CALL add_stmt(" end if; ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   IF (v_r_tab_ind=0)
    CALL add_stmt(" end if;",1,0,0,i_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" rollback; ",1,0,0,i_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("end; ",1,1,0,i_stmt_cnt,
    trg_stmts)
   RETURN("S")
 END ;Subroutine
 SUBROUTINE create_reg_md_trg_stmt(i_tab_name,i_null_info,i_rdds_col_str,i_soft_cons,i_tab_info)
   DECLARE v_update_of_str = vc WITH protect, noconstant("")
   DECLARE crct_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE lv_ndx = i4 WITH protect, noconstant(0)
   DECLARE md_cnt = i4 WITH protect, noconstant(0)
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE v_block_stmt = vc WITH protect, noconstant("")
   DECLARE crmd_col_list = vc WITH protect, noconstant("")
   DECLARE v_null_str = vc WITH protect, noconstant("")
   DECLARE crmt_create_ind = i2 WITH protect, noconstant(0)
   DECLARE ndx_cnt = i4 WITH protect, noconstant(0)
   DECLARE crmt_md_check = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_tables_doc_local dtdl
    WHERE dtdl.merge_delete_ind=1
     AND dtdl.table_name=i_tab_name
     AND  EXISTS (
    (SELECT
     "x"
     FROM code_value cv
     WHERE cv.code_set=4002213
      AND cv.display=i_tab_name
      AND cv.cdf_meaning="MDTRG"
      AND cv.active_ind=1))
    DETAIL
     crmt_create_ind = 1, crmt_md_check = 1
    WITH nocounter
   ;end select
   IF (check_error("Checking if table needs REG_MD_MC trigger") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   FOR (ndx_cnt = 1 TO i_soft_cons->ndx_cnt)
     IF ((i_soft_cons->ndx[ndx_cnt].valid_ind=1))
      SET crmt_create_ind = 1
     ENDIF
   ENDFOR
   FOR (ndx_cnt = 1 TO size(i_tab_info->ndx,5))
     IF ((((i_tab_info->ndx[ndx_cnt].md_superset_ind=0)) OR ((i_tab_info->cust_plsql_ind=1))) )
      SET crmt_create_ind = 1
     ENDIF
   ENDFOR
   IF (crmt_create_ind=1)
    FOR (i = 1 TO size(i_tab_info->md,5))
      SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->md[i].column_name)
    ENDFOR
    IF (size(i_tab_info->pk,5) > 0)
     FOR (i = 1 TO size(i_tab_info->pk,5))
       IF (locateval(lv_ndx,1,size(i_tab_info->md,5),i_tab_info->pk[i].column_name,i_tab_info->md[
        lv_ndx].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->pk[i].column_name)
        SET i_tab_info->pk[i].not_md_col = 1
       ELSE
        SET i_tab_info->pk[i].not_md_col = 0
       ENDIF
     ENDFOR
     FOR (v_idx = 1 TO size(i_tab_info->distinct_cols,5))
       IF (locateval(lv_ndx,1,size(i_tab_info->md,5),i_tab_info->distinct_cols[v_idx].column_name,
        i_tab_info->md[lv_ndx].column_name)=0
        AND locateval(lv_ndx,1,size(i_tab_info->pk,5),i_tab_info->distinct_cols[v_idx].column_name,
        i_tab_info->pk[lv_ndx].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->distinct_cols[v_idx].
         column_name)
       ENDIF
     ENDFOR
    ELSE
     FOR (i = 1 TO size(i_tab_info->ui,5))
       IF (locateval(lv_ndx,1,size(i_tab_info->md,5),i_tab_info->ui[i].column_name,i_tab_info->md[
        lv_ndx].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->ui[i].column_name)
       ENDIF
     ENDFOR
     FOR (v_idx = 1 TO size(i_tab_info->distinct_cols,5))
       IF (locateval(lv_ndx,1,size(i_tab_info->md,5),i_tab_info->distinct_cols[v_idx].column_name,
        i_tab_info->md[lv_ndx].column_name)=0
        AND locateval(lv_ndx,1,size(i_tab_info->ui,5),i_tab_info->distinct_cols[v_idx].column_name,
        i_tab_info->ui[lv_ndx].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->distinct_cols[v_idx].
         column_name)
       ENDIF
     ENDFOR
    ENDIF
    SET v_update_of_str = substring(3,10000,v_update_of_str)
    CALL add_stmt(build("create or replace trigger REFCHG",i_tab_info->table_suffix,"_REG_MD_MC"),1,0,
     0,crct_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(" before insert or delete or update of ",v_update_of_str),1,0,0,
     crct_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(" on ",i_tab_name," for each row "),1,0,0,crct_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" WHEN ((NVL(SYS_CONTEXT( 'CERNER', 'FIRE_RMC_TRG'), 'DM2NULLVAL') != 'NO')) ",1,0,
     0,crct_stmt_cnt,
     trg_stmts)
    CALL add_stmt("declare ",1,0,0,crct_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  v_cnt_var number; ",1,0,0,crct_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   v_pkw dm_refchg_rtable_reset.pk_where%type;",1,0,0,crct_stmt_cnt,
     trg_stmts)
    IF (size(i_tab_info->pk,5) > 0)
     FOR (c_ndx = 1 TO size(i_tab_info->pk,5))
       CALL add_stmt(concat("  v_pk",trim(cnvtstring(c_ndx))," ",i_tab_name,".",
         i_tab_info->pk[c_ndx].column_name,"%type;"),1,0,0,crct_stmt_cnt,
        trg_stmts)
     ENDFOR
    ELSE
     FOR (c_ndx = 1 TO size(i_tab_info->ui,5))
       CALL add_stmt(concat("  v_pk",trim(cnvtstring(c_ndx))," ",i_tab_name,".",
         i_tab_info->ui[c_ndx].column_name,"%type;"),1,0,0,crct_stmt_cnt,
        trg_stmts)
     ENDFOR
    ENDIF
    CALL add_stmt("begin",1,0,0,crct_stmt_cnt,
     trg_stmts)
    IF (crmt_md_check > 0)
     FOR (col_cnt = 1 TO size(i_tab_info->md,5))
      IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->md[col_cnt].column_name,i_null_info->
       cols[v_idx].col_name)=0)
       IF ((i_tab_info->md[col_cnt].data_type="F*"))
        SET v_null_str = concat("nullval(",i_tab_info->md[col_cnt].column_name,",-123888.4321)")
       ELSEIF ((i_tab_info->md[col_cnt].data_type="I*"))
        SET v_null_str = concat("nullval(",i_tab_info->md[col_cnt].column_name,",-123888)")
       ELSEIF ((i_tab_info->md[col_cnt].data_type="DQ8"))
        SET v_null_str = concat("nullval(",i_tab_info->md[col_cnt].column_name,
         ",cnvtdatetime(cnvtdate(07231882),215212))")
       ELSE
        SET v_null_str = concat("nullval(",i_tab_info->md[col_cnt].column_name,
         ",''null_vaLue_CHeck_894.3'')")
       ENDIF
      ELSE
       SET v_null_str = i_tab_info->md[col_cnt].column_name
      ENDIF
      IF (col_cnt=1)
       SET crmd_col_list = concat(" '||'",v_null_str,"'")
      ELSE
       SET crmd_col_list = concat(crmd_col_list," ||',",v_null_str,"' ")
      ENDIF
     ENDFOR
     CALL add_stmt("begin",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("if inserting or (updating and ",1,0,0,crct_stmt_cnt,
      trg_stmts)
     IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->md[1].column_name,i_null_info->cols[v_idx
      ].col_name)=0)
      CALL add_stmt(concat("(:new.",i_tab_info->md[1].column_name," != :old.",i_tab_info->md[1].
        column_name," or (:new.",
        i_tab_info->md[1].column_name," is null and :old.",i_tab_info->md[1].column_name,
        " is not null) or (:new.",i_tab_info->md[1].column_name,
        " is not null and :old.",i_tab_info->md[1].column_name," is null)"),1,0,0,crct_stmt_cnt,
       trg_stmts)
     ELSE
      CALL add_stmt(concat("(:new.",i_tab_info->md[1].column_name," != :old.",i_tab_info->md[1].
        column_name),1,0,0,crct_stmt_cnt,
       trg_stmts)
     ENDIF
     FOR (i = 2 TO size(i_tab_info->md,5))
       IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->md[i].column_name,i_null_info->cols[
        v_idx].col_name)=0)
        CALL add_stmt(concat(" or :new.",i_tab_info->md[i].column_name," != :old.",i_tab_info->md[i].
          column_name," or (:new.",
          i_tab_info->md[i].column_name," is null and :old.",i_tab_info->md[i].column_name,
          " is not null) or (:new.",i_tab_info->md[i].column_name,
          " is not null and :old.",i_tab_info->md[i].column_name," is null)"),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ELSE
        CALL add_stmt(concat(" or :new.",i_tab_info->md[i].column_name," != :old.",i_tab_info->md[i].
          column_name),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
     ENDFOR
     FOR (i = 1 TO size(i_tab_info->pk,5))
       IF ((i_tab_info->pk[i].not_md_col=1))
        CALL add_stmt(concat(" or :new.",i_tab_info->pk[i].column_name," != :old.",i_tab_info->pk[i].
          column_name),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
     ENDFOR
     CALL add_stmt(")) then",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt(concat("   select count(*) into v_cnt_var from ",i_tab_info->tab_$r," r1"),1,0,0,
      crct_stmt_cnt,
      trg_stmts)
     IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->md[1].column_name,i_null_info->cols[v_idx
      ].col_name)=0)
      CALL add_stmt(concat("   where (r1.",i_tab_info->md[1].column_name," = :new.",i_tab_info->md[1]
        .column_name," or (r1.",
        i_tab_info->md[1].column_name," is null and :new.",i_tab_info->md[1].column_name," is null))"
        ),1,0,0,crct_stmt_cnt,
       trg_stmts)
     ELSE
      CALL add_stmt(concat("   where r1.",i_tab_info->md[1].column_name," = :new.",i_tab_info->md[1].
        column_name),1,0,0,crct_stmt_cnt,
       trg_stmts)
     ENDIF
     FOR (i = 2 TO size(i_tab_info->md,5))
       IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->md[i].column_name,i_null_info->cols[
        v_idx].col_name)=0)
        CALL add_stmt(concat("     and (r1.",i_tab_info->md[i].column_name," = :new.",i_tab_info->md[
          i].column_name," or (r1.",
          i_tab_info->md[i].column_name," is null and :new.",i_tab_info->md[i].column_name,
          " is null))"),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ELSE
        CALL add_stmt(concat("     and r1.",i_tab_info->md[i].column_name," = :new.",i_tab_info->md[i
          ].column_name),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
     ENDFOR
     CALL add_stmt("     and rdds_status_Flag < 9000;",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("    select substr(",1,0,0,crct_stmt_cnt,
      trg_stmts)
     FOR (col_cnt = 1 TO size(i_tab_info->md,5))
       IF (col_cnt != 1)
        CALL add_stmt("||' and '||",1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
       CALL add_stmt(concat("'",i_tab_info->md[col_cnt].column_name,"'||"),1,0,0,crct_stmt_cnt,
        trg_stmts)
       IF ((i_tab_info->md[col_cnt].data_type IN ("VC", "C*")))
        CALL add_stmt(concat("decode(:new.",i_tab_info->md[col_cnt].column_name,
          ",null,' is null ',chr(0),'=char(0)','='|| dm_refchg_breakup_str(:new.",i_tab_info->md[
          col_cnt].column_name,"))"),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ELSEIF ((i_tab_info->md[col_cnt].data_type="DQ8"))
        CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->md[col_cnt].column_name,
          "),null,' is null ',' = cnvtdatetimeutc('||'^'|| to_char(:new.",i_tab_info->md[col_cnt].
          column_name,",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,
         crct_stmt_cnt,
         trg_stmts)
       ELSE
        CALL add_stmt(concat("decode(to_char(:new.",i_tab_info->md[col_cnt].column_name,
          "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(:new.",i_tab_info->md[col_cnt].
          column_name,
          "))"),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
     ENDFOR
     CALL add_stmt(",1,2000) into v_pkw from dual;",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("elsif deleting then",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt(concat("   select count(*) into v_cnt_var from ",i_tab_info->tab_$r," r1"),1,0,0,
      crct_stmt_cnt,
      trg_stmts)
     IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->md[1].column_name,i_null_info->cols[v_idx
      ].col_name)=0)
      CALL add_stmt(concat("   where (r1.",i_tab_info->md[1].column_name," = :old.",i_tab_info->md[1]
        .column_name," or (r1.",
        i_tab_info->md[1].column_name," is null and :old.",i_tab_info->md[1].column_name," is null))"
        ),1,0,0,crct_stmt_cnt,
       trg_stmts)
     ELSE
      CALL add_stmt(concat("   where r1.",i_tab_info->md[1].column_name," = :old.",i_tab_info->md[1].
        column_name),1,0,0,crct_stmt_cnt,
       trg_stmts)
     ENDIF
     FOR (i = 2 TO size(i_tab_info->md,5))
       IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->md[i].column_name,i_null_info->cols[
        v_idx].col_name)=0)
        CALL add_stmt(concat("     and (r1.",i_tab_info->md[i].column_name," = :old.",i_tab_info->md[
          i].column_name," or (r1.",
          i_tab_info->md[i].column_name," is null and :old.",i_tab_info->md[i].column_name,
          " is null))"),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ELSE
        CALL add_stmt(concat("     and r1.",i_tab_info->md[i].column_name," = :old.",i_tab_info->md[i
          ].column_name),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
     ENDFOR
     CALL add_stmt("     and rdds_status_Flag < 9000;",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("    select substr(",1,0,0,crct_stmt_cnt,
      trg_stmts)
     FOR (col_cnt = 1 TO size(i_tab_info->md,5))
       IF (col_cnt != 1)
        CALL add_stmt("||' and '||",1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
       CALL add_stmt(concat("'",i_tab_info->md[col_cnt].column_name,"'||"),1,0,0,crct_stmt_cnt,
        trg_stmts)
       IF ((i_tab_info->md[col_cnt].data_type IN ("VC", "C*")))
        CALL add_stmt(concat("decode(:old.",i_tab_info->md[col_cnt].column_name,
          ",null,' is null ',chr(0),'=char(0)','='|| dm_refchg_breakup_str(:old.",i_tab_info->md[
          col_cnt].column_name,"))"),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ELSEIF ((i_tab_info->md[col_cnt].data_type="DQ8"))
        CALL add_stmt(concat("decode(to_char(:old.",i_tab_info->md[col_cnt].column_name,
          "),null,' is null ',' = cnvtdatetimeutc('||'^'|| to_char(:old.",i_tab_info->md[col_cnt].
          column_name,",'DD-MON-YYYY HH24:MI:SS','nls_date_language=american') ||'^'||')')"),1,0,0,
         crct_stmt_cnt,
         trg_stmts)
       ELSE
        CALL add_stmt(concat("decode(to_char(:old.",i_tab_info->md[col_cnt].column_name,
          "),null,' is null ',' ='|| ","dm_refchg_num_to_ccl(:old.",i_tab_info->md[col_cnt].
          column_name,
          "))"),1,0,0,crct_stmt_cnt,
         trg_stmts)
       ENDIF
     ENDFOR
     CALL add_stmt(",1,2000) into v_pkw from dual;",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("end if;",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("if v_cnt_var > 0 then",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("   if dm_refchg_dual_build_reject = 0 then ",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt(concat("   proc_refchg_ins_drrr('",i_tab_name,"',v_pkw,3,null,"),1,0,0,
      crct_stmt_cnt,
      trg_stmts)
     SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where list(",crmd_col_list,"||')")
     SET v_block_stmt = concat(v_block_stmt," in (select ",crmd_col_list,"||' from ",i_tab_name,
      " where '||v_pkw||') and rdds_status_flag < 9000 and rdds_delete_ind = 0'")
     CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'UNPROCESSED');"),1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("   else ",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt(concat("    proc_refchg_ins_drrr_auton('",i_tab_name,"',v_pkw,3,null,"),1,0,0,
      crct_stmt_cnt,
      trg_stmts)
     SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where list(",crmd_col_list,"||')")
     SET v_block_stmt = concat(v_block_stmt," in (select ",crmd_col_list,"||' from ",i_tab_info->
      tab_$r,
      " where '||v_pkw||') and rdds_status_flag < 9000 and rdds_delete_ind = 0'")
     CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'VIOLATION');"),1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("   RAISE_APPLICATION_ERROR(-20204,",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL echo("#030 create_reg_md_trg_stmt - add table suffix")
     CALL add_stmt(concat("'Uptime RDDS - ",i_tab_info->table_suffix,
       ": Attempted to modify a merge delete value that RDDS is also going to modify.');"),1,0,0,
      crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("  end if;",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("end if;",1,0,0,crct_stmt_cnt,
      trg_stmts)
     CALL add_stmt("end;",1,0,0,crct_stmt_cnt,
      trg_stmts)
    ENDIF
    FOR (ndx_cnt = 1 TO size(i_tab_info->ndx,5))
      IF ((((i_tab_info->ndx[ndx_cnt].md_superset_ind=0)) OR ((i_tab_info->cust_plsql_ind=1))) )
       CALL add_stmt("if inserting or updating then ",1,0,0,crct_stmt_cnt,
        trg_stmts)
       CALL reg_unique_check(i_tab_info->tab_$r,i_tab_info->ndx[ndx_cnt].match_str,i_tab_info->
        pk_diff_str,i_tab_info->ui_diff_str,"-20200",
        crct_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_tab_info,
        1)
       CALL add_stmt("end if; ",1,0,0,crct_stmt_cnt,
        trg_stmts)
      ENDIF
    ENDFOR
    FOR (ndx_cnt = 1 TO i_soft_cons->ndx_cnt)
      IF ((i_soft_cons->ndx[ndx_cnt].valid_ind=1))
       CALL add_stmt("if inserting or updating then ",1,0,0,crct_stmt_cnt,
        trg_stmts)
       CALL reg_unique_check(i_tab_info->tab_$r,i_soft_cons->ndx[ndx_cnt].match_str,i_tab_info->
        pk_diff_str,i_tab_info->ui_diff_str,"-20200",
        crct_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_soft_cons,
        5)
       CALL add_stmt("end if; ",1,0,0,crct_stmt_cnt,
        trg_stmts)
      ENDIF
    ENDFOR
    CALL add_stmt("end;",1,1,0,crct_stmt_cnt,
     trg_stmts)
    RETURN("S")
   ELSE
    RETURN("Z")
   ENDIF
 END ;Subroutine
 SUBROUTINE create_reg_vers_trg_stmt(i_tab_info,i_rdds_col_str,i_null_info,i_soft_cons)
   DECLARE v_update_of_str = vc WITH protect, noconstant(" ")
   DECLARE crvt_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE crvt_before_str = vc WITH protect, noconstant("")
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   DECLARE v_idx = i4 WITH protect, noconstant(0)
   DECLARE v_idx2 = i4 WITH protect, noconstant(0)
   DECLARE v_block_stmt = vc WITH protect, noconstant("")
   DECLARE crvt_col_list = vc WITH protect, noconstant("")
   DECLARE v_null_str = vc WITH protect, noconstant("")
   DECLARE crvt_pk_col = vc WITH protect, noconstant("")
   DECLARE i_tab_name = vc WITH protect, noconstant("")
   DECLARE crvt_auton_ind = i2 WITH protect, noconstant(0)
   DECLARE v_ui_match_str = vc WITH protect, noconstant(" ")
   DECLARE v_ui_diff_str = vc WITH protect, noconstant(" ")
   DECLARE v_eff_str = vc WITH protect, noconstant("")
   DECLARE v_ccl_eff_str = vc WITH protect, noconstant("")
   DECLARE v_trig_type = vc WITH protect, noconstant("")
   DECLARE v_replace_str = vc WITH protect, noconstant("")
   DECLARE crvt_data_type = vc WITH protect, noconstant("")
   DECLARE crvt_unq_chk = i2 WITH protect, noconstant(0)
   DECLARE ndx_cnt = i4 WITH protect, noconstant(0)
   DECLARE crvt_ui_add = i2 WITH protect, noconstant(0)
   DECLARE v_ccl_end_eff_str = vc WITH protect, noconstant("")
   SET crvt_pk_col = i_tab_info->pk[1].column_name
   SET i_tab_name = i_tab_info->table_name
   FREE RECORD crvt_sp_cols
   RECORD crvt_sp_cols(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
    IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->ui[col_cnt].column_name,i_null_info->cols[
     v_idx].col_name)=0)
     IF ((i_tab_info->ui[col_cnt].data_type="F*"))
      SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,",-123888.4321)")
     ELSEIF ((i_tab_info->ui[col_cnt].data_type="I*"))
      SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,",-123888)")
     ELSEIF ((i_tab_info->ui[col_cnt].data_type="DQ8"))
      SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,
       ",cnvtdatetime(cnvtdate(07231882),215212))")
     ELSE
      SET v_null_str = concat("nullval(",i_tab_info->ui[col_cnt].column_name,
       ",''null_vaLue_CHeck_894.3'')")
     ENDIF
    ELSE
     SET v_null_str = i_tab_info->ui[col_cnt].column_name
    ENDIF
    IF (col_cnt=1)
     SET crvt_col_list = concat(" '||'",v_null_str,"'")
    ELSE
     SET crvt_col_list = concat(crvt_col_list," ||',",v_null_str,"' ")
    ENDIF
   ENDFOR
   IF ((i_tab_info->vers_alg="ALG2"))
    SET v_update_of_str = concat(i_tab_info->ui_col_list,",",i_tab_info->beg_eff_col,",",i_tab_info->
     end_eff_col,
     ",",i_tab_info->prev_pk_col)
    SET crvt_ui_add = 1
    SET crvt_sp_cols->cnt = 3
    SET stat = alterlist(crvt_sp_cols->qual,crvt_sp_cols->cnt)
    SET crvt_sp_cols->qual[1].column_name = i_tab_info->beg_eff_col
    SET crvt_sp_cols->qual[2].column_name = i_tab_info->end_eff_col
    SET crvt_sp_cols->qual[3].column_name = i_tab_info->prev_pk_col
   ELSEIF ((i_tab_info->table_name="DCP_SECTION_REF"))
    SET v_update_of_str = concat(i_tab_info->ui_col_list,",ACTIVE_IND,DESCRIPTION,DEFINITION")
    SET crvt_ui_add = 1
    SET crvt_sp_cols->cnt = 3
    SET stat = alterlist(crvt_sp_cols->qual,crvt_sp_cols->cnt)
    SET crvt_sp_cols->qual[1].column_name = "ACTIVE_IND"
    SET crvt_sp_cols->qual[2].column_name = "DESCRIPTION"
    SET crvt_sp_cols->qual[3].column_name = "DEFINITION"
   ELSEIF ((i_tab_info->table_name="DCP_FORMS_REF"))
    SET v_update_of_str = concat(i_tab_info->ui_col_list,",ACTIVE_IND,DESCRIPTION")
    SET crvt_ui_add = 1
    SET crvt_sp_cols->cnt = 2
    SET stat = alterlist(crvt_sp_cols->qual,crvt_sp_cols->cnt)
    SET crvt_sp_cols->qual[1].column_name = "ACTIVE_IND"
    SET crvt_sp_cols->qual[2].column_name = "DESCRIPTION"
   ELSEIF ((i_tab_info->vers_alg="ALG6"))
    SET v_update_of_str = concat(i_tab_info->ui_col_list,",ACTIVE_IND,",i_tab_info->beg_eff_col,",",
     i_tab_info->end_eff_col)
    SET crvt_ui_add = 1
    SET crvt_sp_cols->cnt = 3
    SET stat = alterlist(crvt_sp_cols->qual,crvt_sp_cols->cnt)
    SET crvt_sp_cols->qual[1].column_name = "ACTIVE_IND"
    SET crvt_sp_cols->qual[2].column_name = i_tab_info->beg_eff_col
    SET crvt_sp_cols->qual[3].column_name = i_tab_info->end_eff_col
   ELSE
    SET v_update_of_str = concat("ACTIVE_IND")
    SET crvt_sp_cols->cnt = 1
    SET stat = alterlist(crvt_sp_cols->qual,crvt_sp_cols->cnt)
    SET crvt_sp_cols->qual[1].column_name = "ACTIVE_IND"
   ENDIF
   IF ((i_soft_cons->ndx_cnt > 0))
    SET crvt_unq_chk = 1
   ENDIF
   FOR (ndx_idx = 1 TO size(i_tab_info->ndx))
     IF ((((i_tab_info->ndx[ndx_cnt].ui_superset_ind=0)) OR ((((i_tab_info->ui_ndx_ind=0)) OR ((
     i_tab_info->cust_plsql_ind=1))) )) )
      SET crvt_unq_chk = 1
     ENDIF
   ENDFOR
   IF (crvt_unq_chk=1)
    IF (size(i_tab_info->pk,5) > 0)
     FOR (col_cnt = 1 TO size(i_tab_info->pk,5))
       IF (((crvt_ui_add=0) OR (locateval(v_idx,1,size(i_tab_info->ui,5),i_tab_info->pk[col_cnt].
        column_name,i_tab_info->ui[v_idx].column_name)=0))
        AND locateval(v_idx2,1,crvt_sp_cols->cnt,i_tab_info->pk[col_cnt].column_name,crvt_sp_cols->
        qual[v_idx2].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->pk[col_cnt].column_name)
       ENDIF
     ENDFOR
     FOR (col_cnt = 1 TO size(i_tab_info->distinct_cols,5))
       IF (locateval(v_idx,1,size(i_tab_info->pk,5),i_tab_info->distinct_cols[col_cnt].column_name,
        i_tab_info->pk[v_idx].column_name)=0
        AND ((crvt_ui_add=0) OR (locateval(v_idx,1,size(i_tab_info->ui,5),i_tab_info->distinct_cols[
        col_cnt].column_name,i_tab_info->ui[v_idx].column_name)=0))
        AND locateval(v_idx2,1,crvt_sp_cols->cnt,i_tab_info->distinct_cols[col_cnt].column_name,
        crvt_sp_cols->qual[v_idx2].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->distinct_cols[col_cnt].
         column_name)
       ENDIF
     ENDFOR
    ELSE
     IF (crvt_ui_add=0)
      FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
        IF (locateval(v_idx2,1,crvt_sp_cols->cnt,i_tab_info->ui[col_cnt].column_name,crvt_sp_cols->
         qual[v_idx2].column_name)=0)
         SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->ui[col_cnt].column_name)
        ENDIF
      ENDFOR
     ENDIF
     FOR (v_idx = 1 TO size(i_tab_info->distinct_cols,5))
       IF (locateval(v_idx,1,size(i_tab_info->ui,5),i_tab_info->distinct_cols[col_cnt].column_name,
        i_tab_info->ui[v_idx].column_name)=0
        AND locateval(v_idx2,1,crvt_sp_cols->cnt,i_tab_info->distinct_cols[col_cnt].column_name,
        crvt_sp_cols->qual[v_idx2].column_name)=0)
        SET v_update_of_str = concat(v_update_of_str,", ",i_tab_info->distinct_cols[col_cnt].
         column_name)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF ((i_tab_info->vers_alg="ALG2"))
    SET crvt_before_str = " before insert or update of "
    SET crvt_auton_ind = 1
    FOR (col_cnt = 1 TO size(i_tab_info->ui,5))
      IF (locateval(v_idx,1,i_null_info->col_cnt,i_tab_info->ui[col_cnt].column_name,i_null_info->
       cols[v_idx].col_name)=0)
       SET v_ui_match_str = concat(v_ui_match_str," and (:new.",i_tab_info->ui[col_cnt].column_name,
        "= r1.",i_tab_info->ui[col_cnt].column_name,
        " or (:new.",i_tab_info->ui[col_cnt].column_name," is null and r1.",i_tab_info->ui[col_cnt].
        column_name," is null))")
       SET v_ui_diff_str = concat(v_ui_diff_str," or (:new.",i_tab_info->ui[col_cnt].column_name,
        "!= r1.",i_tab_info->ui[col_cnt].column_name,
        " or (:new.",i_tab_info->ui[col_cnt].column_name," is null and r1.",i_tab_info->ui[col_cnt].
        column_name," is not null) or (:new.",
        i_tab_info->ui[col_cnt].column_name," is not null and r1.",i_tab_info->ui[col_cnt].
        column_name," is null))")
      ELSE
       SET v_ui_match_str = concat(v_ui_match_str," and :new.",i_tab_info->ui[col_cnt].column_name,
        "= r1.",i_tab_info->ui[col_cnt].column_name)
       SET v_ui_diff_str = concat(v_ui_diff_str," or :new.",i_tab_info->ui[col_cnt].column_name,
        "!= r1.",i_tab_info->ui[col_cnt].column_name)
      ENDIF
    ENDFOR
    SET v_ui_match_str = substring(6,10000,v_ui_match_str)
    SET v_ui_diff_str = substring(5,10000,v_ui_diff_str)
    SET v_eff_str = concat(" SYSDATE + 1 < l.",i_tab_info->end_eff_col)
    SET v_ccl_eff_str = concat(i_tab_info->beg_eff_col,"<= cnvtdatetime(curdate,curtime3) and ",
     i_tab_info->end_eff_col,">= cnvtdatetime(curdate,curtime3)")
    SET v_trig_type = "ALG2 CHECK1"
   ELSEIF ((i_tab_info->table_name="DCP_SECTION_REF"))
    SET crvt_before_str = " before insert or update of "
    SET crvt_auton_ind = 1
    SET v_ui_match_str = concat(
     "(:new.DESCRIPTION = r1.DESCRIPTION or (:new.DESCRIPTION is null and r1.DESCRIPTION is null))",
     " and (:new.DEFINITION = r1.DEFINITION or (:new.DEFINITION is null and r1.DEFINITION is null))")
    SET v_ui_diff_str = concat(
     "(:new.DESCRIPTION != r1.DESCRIPTION or (:new.DESCRIPTION is null and r1.DESCRIPTION ",
     "is not null) or (:new.DESCRIPTION is not null and r1.DESCRIPTION is null)) or (:new.DEFINITION != r1.DEFINITION or",
     " (:new.DEFINITION is null and r1.DEFINITION is not null) or (:new.DEFINITION is not null and r1.DEFINITION is null))"
     )
    SET v_eff_str = " l.ACTIVE_IND = 1"
    SET v_ccl_eff_str = " ACTIVE_IND = 1"
    SET i_tab_info->prev_pk_col = "DCP_SECTION_REF_ID"
    SET v_trig_type = "ALG1 CHECK2"
    SET crvt_col_list =
    "'||'nullval(DESCRIPTION,''null_vaLue_CHeck_894.3'')' ||',nullval(DEFINITION,''null_vaLue_CHeck_894.3'')'"
   ELSEIF ((i_tab_info->table_name="DCP_FORMS_REF"))
    SET crvt_before_str = " before insert or update of "
    SET crvt_auton_ind = 1
    SET v_ui_match_str = concat(
     "(:new.DESCRIPTION = r1.DESCRIPTION or (:new.DESCRIPTION is null and r1.DESCRIPTION is null))")
    SET v_ui_diff_str = concat(
     "(:new.DESCRIPTION != r1.DESCRIPTION or (:new.DESCRIPTION is null and r1.DESCRIPTION ",
     "is not null) or (:new.DESCRIPTION is not null and r1.DESCRIPTION is null))")
    SET v_eff_str = " l.ACTIVE_IND = 1"
    SET v_ccl_eff_str = " ACTIVE_IND = 1"
    SET i_tab_info->prev_pk_col = "DCP_FORMS_REF_ID"
    SET v_trig_type = "ALG1 CHECK2"
    SET crvt_col_list = "'||'nullval(DESCRIPTION,''null_vaLue_CHeck_894.3'')'"
   ELSEIF ((i_tab_info->vers_alg="ALG6"))
    IF (crvt_unq_chk=0)
     SET crvt_before_str = " before update of "
    ELSE
     SET crvt_before_str = " before insert or update of "
    ENDIF
    IF (curutc=0)
     SET v_eff_str = concat(" :new.",i_tab_info->end_eff_col," <= SYSDATE and SYSDATE + 1 < r1.",
      i_tab_info->end_eff_col)
    ELSE
     SET v_eff_str = concat(" :new.",i_tab_info->end_eff_col,
      " <= SYS_EXTRACT_UTC(SYSTIMESTAMP) and SYS_EXTRACT_UTC(SYSTIMESTAMP) < r1.",i_tab_info->
      end_eff_col)
    ENDIF
    SET v_ccl_eff_str = concat(i_tab_info->end_eff_col," >= cnvtdatetime(curdate,curtime3)")
    SET v_ccl_end_eff_str = concat(i_tab_info->end_eff_col," <= cnvtdatetime(curdate,curtime3)")
   ELSE
    IF (crvt_unq_chk=0)
     SET crvt_before_str = " before update of "
    ELSE
     SET crvt_before_str = " before insert or update of "
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(v_update_of_str)
   ENDIF
   CALL add_stmt(build("create or replace trigger REFCHG",i_tab_info->table_suffix,"_REG_VR_MC"),1,0,
    0,crvt_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat(crvt_before_str," ",v_update_of_str),1,0,0,crvt_stmt_cnt,
    trg_stmts)
   CALL add_stmt(concat(" on ",i_tab_name," for each row "),1,0,0,crvt_stmt_cnt,
    trg_stmts)
   CALL add_stmt(" WHEN ((NVL(SYS_CONTEXT( 'CERNER', 'FIRE_RMC_TRG'), 'DM2NULLVAL') != 'NO')) ",1,0,0,
    crvt_stmt_cnt,
    trg_stmts)
   CALL add_stmt("declare ",1,0,0,crvt_stmt_cnt,
    trg_stmts)
   IF (crvt_auton_ind=1)
    CALL add_stmt("  pragma autonomous_transaction;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
   ENDIF
   CALL add_stmt("  v_pk1 number; ",1,0,0,crvt_stmt_cnt,
    trg_stmts)
   CALL add_stmt("   v_pkw dm_refchg_rtable_reset.pk_where%type;",1,0,0,crvt_stmt_cnt,
    trg_stmts)
   CALL add_stmt("begin",1,0,0,crvt_stmt_cnt,
    trg_stmts)
   IF ((i_tab_info->vers_alg != "ALG2"))
    CALL add_stmt(" begin",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    IF ((i_tab_info->table_name != "DCP_SECTION_REF")
     AND (i_tab_info->table_name != "DCP_FORMS_REF"))
     CALL add_stmt(" if updating then ",1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(concat("  select r1.",crvt_pk_col," into v_pk1"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   from ",i_tab_info->tab_$r," r1 "),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   where :new.",crvt_pk_col," = r1.",crvt_pk_col),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   and :new.ACTIVE_IND = 0 and r1.ACTIVE_IND = 1 ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   and ",trim(i_rdds_col_str,3)," and rownum = 1;"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   if dm_refchg_dual_build_reject = 0 then ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    select substr(",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("'",crvt_pk_col,"'||"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("decode(to_char(:new.",crvt_pk_col,
      "),null,' is null ',' ='|| dm_refchg_num_to_ccl(:new.",crvt_pk_col,"))"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("|| ' and active_ind = 0',1,2000) into v_pkw from dual;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    IF (crvt_auton_ind=0)
     CALL add_stmt("   proc_refchg_ins_drrr(",1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt("    proc_refchg_ins_drrr_auton(",1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ENDIF
    IF ((i_tab_info->vers_alg="ALG6"))
     CALL add_stmt(concat("'",i_tab_name,"',v_pkw,4,'ALG6 CHECK1',"),1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(concat("'",i_tab_name,"',v_pkw,4,'ALG1 CHECK1',"),1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ENDIF
    SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where ",crvt_pk_col,"'|| '")
    SET v_block_stmt = concat(v_block_stmt," in (select ",crvt_pk_col,"' ||' from ",i_tab_name,
     " where '||v_pkw||') and ",i_rdds_col_str,"'")
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'UNPROCESSED');"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   else ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    select substr(",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("'",crvt_pk_col,"'||"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("decode(to_char(v_pk1),null,' is null ',' ='|| ",
      "dm_refchg_num_to_ccl(v_pk1))"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("|| ' and active_ind = 1',1,2000) into v_pkw from dual; ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    IF ((i_tab_info->vers_alg="ALG6"))
     CALL add_stmt(concat("    proc_refchg_ins_drrr_auton('",i_tab_name,"',v_pkw,4,'ALG6 CHECK1',"),1,
      0,0,crvt_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(concat("    proc_refchg_ins_drrr_auton('",i_tab_name,"',v_pkw,4,'ALG1 CHECK1',"),1,
      0,0,crvt_stmt_cnt,
      trg_stmts)
    ENDIF
    SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where ",crvt_pk_col,"'|| '")
    SET v_block_stmt = concat(v_block_stmt," in (select ",crvt_pk_col,"' ||' from ",i_tab_info->
     tab_$r,
     " where '||v_pkw||') and ",i_rdds_col_str,"'")
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'VIOLATION');"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   RAISE_APPLICATION_ERROR(-20205",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(",'Uptime RDDS - ",i_tab_info->table_suffix,
      ": Attempted to inactivate the current version that RDDS is going to modify.');"),1,0,0,
     crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  end if;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    IF ((i_tab_info->table_name != "DCP_SECTION_REF")
     AND (i_tab_info->table_name != "DCP_FORMS_REF"))
     CALL add_stmt("  end if;",1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(" exception when no_data_found then null; /* This means no problem was found */",1,
     0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" end;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
   ENDIF
   IF ((i_tab_info->vers_alg="ALG6"))
    CALL add_stmt(" begin",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" if updating then ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("  select r1.",crvt_pk_col," into v_pk1"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   from ",i_tab_info->tab_$r," r1 "),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   where :new.",crvt_pk_col," = r1.",crvt_pk_col),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   and ",v_eff_str),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   and ",trim(i_rdds_col_str,3)," and rownum = 1;"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   if dm_refchg_dual_build_reject = 0 then ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    select substr(",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("'",crvt_pk_col,"'||"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("decode(to_char(:new.",crvt_pk_col,
      "),null,' is null ',' ='|| dm_refchg_num_to_ccl(:new.",crvt_pk_col,"))"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("|| ' and ",v_ccl_end_eff_str,"',1,2000) into v_pkw from dual;"),1,0,0,
     crvt_stmt_cnt,
     trg_stmts)
    IF (crvt_auton_ind=0)
     CALL add_stmt("   proc_refchg_ins_drrr(",1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt("    proc_refchg_ins_drrr_auton(",1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(concat("'",i_tab_name,"',v_pkw,4,'ALG6 CHECK2',"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where ",crvt_pk_col,"'|| '")
    SET v_block_stmt = concat(v_block_stmt," in (select ",crvt_pk_col,"' ||' from ",i_tab_name,
     " where '||v_pkw||') and ",i_rdds_col_str,"'")
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'UNPROCESSED');"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   else ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    select substr(",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("'",crvt_pk_col,"'||"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("decode(to_char(v_pk1),null,' is null ',' ='|| ",
      "dm_refchg_num_to_ccl(v_pk1))"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("|| ' and ",v_ccl_eff_str,"',1,2000) into v_pkw from dual; "),1,0,0,
     crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("    proc_refchg_ins_drrr_auton('",i_tab_name,"',v_pkw,4,'ALG6 CHECK2',"),1,
     0,0,crvt_stmt_cnt,
     trg_stmts)
    SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where ",crvt_pk_col,"'|| '")
    SET v_block_stmt = concat(v_block_stmt," in (select ",crvt_pk_col,"' ||' from ",i_tab_info->
     tab_$r,
     " where '||v_pkw||') and ",i_rdds_col_str,"'")
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'VIOLATION');"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   RAISE_APPLICATION_ERROR(-20205",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(",'Uptime RDDS - ",i_tab_info->table_suffix,
      ": Attempted to end effective the current version that RDDS is going to modify.');"),1,0,0,
     crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  end if;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  end if;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" exception when no_data_found then null; /* This means no problem was found */",1,
     0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" end;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
   ENDIF
   IF ((((i_tab_info->vers_alg="ALG2")) OR (((i_tab_name="DCP_FORMS_REF") OR (i_tab_name=
   "DCP_SECTION_REF")) )) )
    CALL add_stmt(" begin",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("  select r1.",crvt_pk_col," into v_pk1"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   from ",i_tab_info->tab_$r," r1 where "),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    IF ((i_tab_info->vers_alg="ALG2"))
     CALL add_stmt(concat(" r1.",i_tab_info->prev_pk_col," = r1.",crvt_pk_col),1,0,0,crvt_stmt_cnt,
      trg_stmts)
     CALL add_stmt(concat("   and :new.",i_tab_info->prev_pk_col," = :new.",crvt_pk_col),1,0,0,
      crvt_stmt_cnt,
      trg_stmts)
    ELSE
     CALL add_stmt(" :new.ACTIVE_IND = 1 and r1.ACTIVE_IND = 1 ",1,0,0,crvt_stmt_cnt,
      trg_stmts)
    ENDIF
    CALL add_stmt(concat("   and :new.",i_tab_info->prev_pk_col," != r1.",i_tab_info->prev_pk_col),1,
     0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   and ",v_ui_match_str),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    SET v_replace_str = concat("   and (not exists (select 'x' from ",i_tab_name," l1 where l1.",
     i_tab_info->prev_pk_col," = r1.",
     i_tab_info->prev_pk_col," and ",replace(v_eff_str,"l.","l1.",0),")")
    CALL add_stmt(v_replace_str,1,0,0,crvt_stmt_cnt,
     trg_stmts)
    SET v_replace_str = concat("     or exists (select 'x' from ",i_tab_name," l2 where l2.",
     i_tab_info->prev_pk_col," = r1.",
     i_tab_info->prev_pk_col," and ",replace(v_eff_str,"l.","l2.",0)," and (",replace(v_ui_diff_str,
      ":new.","l2.",0),
     ")))")
    CALL add_stmt(v_replace_str,1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("   and ",trim(i_rdds_col_str,3)," and rownum = 1;"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   if dm_refchg_dual_build_reject = 0 then ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    select substr(",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("'",crvt_pk_col,"'||"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("decode(to_char(:new.",crvt_pk_col,
      "),null,' is null ',' ='|| dm_refchg_num_to_ccl(:new.",crvt_pk_col,"))"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("|| ' and ",v_ccl_eff_str,"',1,2000) into v_pkw from dual;"),1,0,0,
     crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    proc_refchg_ins_drrr_auton(",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("'",i_tab_name,"',v_pkw,4,'",v_trig_type,"',"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where ",v_ccl_eff_str,"'|| ' and list(",
     crvt_col_list,"||')")
    SET v_block_stmt = concat(v_block_stmt," in (select ",crvt_col_list,"||' from ",i_tab_name,
     " where '||v_pkw||') and ",i_rdds_col_str,"'")
    SET v_block_stmt = concat(v_block_stmt," ||' and (NOT EXISTS (select ''x'' from ",i_tab_name,
     " l1 where l1.",i_tab_info->prev_pk_col,
     " = r.",i_tab_info->prev_pk_col," and ",v_ccl_eff_str,")'")
    SET v_block_stmt = concat(v_block_stmt," ||' or EXISTS (select ''x'' from ",i_tab_name,
     " l2 where l2.",i_tab_info->prev_pk_col,
     " = r.",i_tab_info->prev_pk_col," and ",v_ccl_eff_str," and (",
     replace(replace(replace(v_ui_diff_str,":new.","l2.",0),"r1.","r.",0)," or ","' || ' or "),")))'"
     )
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'UNPROCESSED');"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   else ",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("    select substr(",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("'",crvt_pk_col,"'||"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("decode(to_char(v_pk1),null,' is null ',' ='|| ",
      "dm_refchg_num_to_ccl(v_pk1))"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("|| ' and ",v_ccl_eff_str,"',1,2000) into v_pkw from dual; "),1,0,0,
     crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat("    proc_refchg_ins_drrr_auton('",i_tab_name,"',v_pkw,4,'",v_trig_type,"',"
      ),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    SET v_block_stmt = concat("'from ",i_tab_info->tab_$r," r where ",v_ccl_eff_str,"'|| ' and list(",
     crvt_col_list,"||')")
    SET v_block_stmt = concat(v_block_stmt," in (select ",crvt_col_list,"||' from ",i_tab_info->
     tab_$r,
     " where '||v_pkw||') and ",i_rdds_col_str,"'")
    SET v_block_stmt = concat(v_block_stmt," ||' and (NOT EXISTS (select ''x'' from ",i_tab_name,
     " l1 where l1.",i_tab_info->prev_pk_col,
     " = r.",i_tab_info->prev_pk_col," and ",v_ccl_eff_str,")'")
    SET v_block_stmt = concat(v_block_stmt," ||' or EXISTS (select ''x'' from ",i_tab_name,
     " l2 where l2.",i_tab_info->prev_pk_col,
     " = r.",i_tab_info->prev_pk_col," and ",v_ccl_eff_str," and ",
     replace(replace(replace(v_ui_diff_str,":new.","l2.",0),"r1.","r.",0)," or ","' || ' or "),"))'")
    CALL add_stmt(concat("substr(",v_block_stmt,",1,4000),'VIOLATION');"),1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("   RAISE_APPLICATION_ERROR(-20205",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(concat(",'Uptime RDDS - ",i_tab_info->table_suffix,
      ": Attempted to add a new unique version that RDDS is also going to add.');"),1,0,0,
     crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt("  end if;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" exception when no_data_found then null; /* This means no problem was found */",1,
     0,0,crvt_stmt_cnt,
     trg_stmts)
    CALL add_stmt(" end;",1,0,0,crvt_stmt_cnt,
     trg_stmts)
   ENDIF
   FOR (ndx_cnt = 1 TO i_soft_cons->ndx_cnt)
     IF ((i_soft_cons->ndx[ndx_cnt].valid_ind=1))
      CALL reg_unique_check(i_tab_info->tab_$r,i_soft_cons->ndx[ndx_cnt].match_str,concat(":new.",
        crvt_pk_col," != r1.",crvt_pk_col),i_tab_info->ui_diff_str,"-20205",
       crvt_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_soft_cons,
       5)
     ENDIF
   ENDFOR
   FOR (ndx_cnt = 1 TO size(i_tab_info->ndx,5))
     IF ((((i_tab_info->ndx[ndx_cnt].ui_superset_ind=0)) OR ((((i_tab_info->ui_ndx_ind=0)) OR ((
     i_tab_info->cust_plsql_ind=1))) ))
      AND (i_tab_info->ndx[ndx_cnt].pk_superset_ind=0))
      CALL reg_unique_check(i_tab_info->tab_$r,i_tab_info->ndx[ndx_cnt].match_str,i_tab_info->
       pk_diff_str,i_tab_info->ui_diff_str,"-20200",
       crvt_stmt_cnt,i_tab_info,i_rdds_col_str,ndx_cnt,i_tab_info,
       1)
      SET crct_return_val = "S"
     ENDIF
   ENDFOR
   CALL add_stmt("end;",1,1,0,crvt_stmt_cnt,
    trg_stmts)
   RETURN("S")
 END ;Subroutine
 SUBROUTINE drop_trigger(i_table_name,i_trigger_flag)
   DECLARE v_trigger_name = vc
   DECLARE v_r_table_name = vc
   SET v_r_table_name = cutover_tab_name(i_table_name,"")
   CALL echo(i_trigger_flag)
   IF (i_trigger_flag=1)
    SELECT INTO "nl:"
     FROM user_triggers ut
     WHERE ut.table_name=i_table_name
      AND ut.trigger_name="REFCHG*_REG_MC*"
     DETAIL
      v_trigger_name = ut.trigger_name
     WITH nocounter
    ;end select
    IF (check_error("Checking to see if table has REG_MC trigger") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF (curqual != 0)
     CALL parser(concat("rdb drop trigger ",v_trigger_name," go"))
    ENDIF
   ELSEIF (i_trigger_flag=2)
    SELECT INTO "nl:"
     FROM user_triggers ut
     WHERE ut.table_name=v_r_table_name
      AND ut.trigger_name="REFCHG*_$R_MC*"
     DETAIL
      v_trigger_name = ut.trigger_name
     WITH nocounter
    ;end select
    IF (check_error("Checking to see if table has $R_MC trigger") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF (curqual != 0)
     CALL parser(concat("rdb drop trigger ",v_trigger_name," go"))
    ENDIF
   ELSEIF (i_trigger_flag=3)
    SELECT INTO "nl:"
     FROM user_triggers ut
     WHERE ut.table_name=i_table_name
      AND ut.trigger_name="REFCHG*_REG_MD_MC*"
     DETAIL
      v_trigger_name = ut.trigger_name
     WITH nocounter
    ;end select
    IF (check_error("Checking to see if table has REG_MD_MC trigger") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF (curqual != 0)
     CALL parser(concat("rdb drop trigger ",v_trigger_name," go"))
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM user_triggers ut
     WHERE ut.table_name=i_table_name
      AND ut.trigger_name="REFCHG*_REG_VR_MC*"
     DETAIL
      v_trigger_name = ut.trigger_name
     WITH nocounter
    ;end select
    IF (check_error("Checking to see if table has REG_VR_MC trigger") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF (curqual != 0)
     CALL parser(concat("rdb drop trigger ",v_trigger_name," go"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_trigger(i_table_suffix,i_trigger_flag)
   DECLARE v_trigger_name = vc
   DECLARE ct_txt = vc WITH protect, noconstant("")
   IF (i_trigger_flag=1)
    SET v_trigger_name = concat("REFCHG",i_table_suffix,"_REG_MC")
   ELSEIF (i_trigger_flag=2)
    SET v_trigger_name = concat("REFCHG",i_table_suffix,"_$R_MC")
   ELSEIF (i_trigger_flag=3)
    SET v_trigger_name = concat("REFCHG",i_table_suffix,"_REG_MD_MC")
   ELSE
    SET v_trigger_name = concat("REFCHG",i_table_suffix,"_REG_VR_MC")
   ENDIF
   SELECT INTO "nl:"
    FROM user_objects uo
    WHERE uo.object_name=v_trigger_name
     AND uo.object_type="TRIGGER"
     AND uo.status="VALID"
    WITH nocounter
   ;end select
   IF (check_error("Checking to see if MC trigger is valid") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   IF (curqual=0)
    CALL parser(concat("rdb alter trigger ",v_trigger_name," disable go"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("The ",v_trigger_name," trigger is invalid.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SELECT INTO value(dm_err->logfile)
     FROM user_errors ue
     WHERE ue.name=v_trigger_name
     ORDER BY ue.name, ue.sequence
     HEAD REPORT
      "USER_ERROR REPORT FOR TRIGGER ", col + 1, v_trigger_name,
      col + 1
     HEAD ue.name
      row + 2, col 2, ue.name,
      row + 1
     DETAIL
      ct_txt = substring(1,175,ue.text), col 4, ct_txt,
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE get_vers_info(i_table_name,i_tab_info,i_data_type)
   DECLARE gvi_idx = i4 WITH protect, noconstant(0)
   DECLARE gvi_num = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Gathering versioning information."
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=255351
     AND cv.active_ind=1
     AND cv.display=i_table_name
     AND cv.cdf_meaning != "NONE"
    DETAIL
     i_tab_info->vers_ind = 1, i_tab_info->vers_alg = cv.cdf_meaning
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ((i_tab_info->vers_alg IN ("ALG2", "ALG6")))
    SET dm_err->eproc = "Gathering effective column information."
    SELECT INTO "nl:"
     FROM user_tab_columns u
     WHERE u.table_name=i_table_name
      AND u.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
     "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
     "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM", "END_EFFECTIVE_DT_TM",
     "PRSNL_END_EFFECTIVE_DT_TM", "END_EFFECTIVE_UTC_DT_TM",
     "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM")
     DETAIL
      IF (u.column_name="*BEG*")
       i_tab_info->beg_eff_col = u.column_name
      ELSE
       i_tab_info->end_eff_col = u.column_name
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF ((((i_tab_info->beg_eff_col <= " ")) OR ((i_tab_info->end_eff_col <= " "))) )
     SELECT INTO "nl:"
      FROM dm_refchg_attribute dra
      WHERE dra.table_name=i_table_name
       AND dra.attribute_name IN ("BEG_EFFECTIVE COLUMN_NAME_IND", "END_EFFECTIVE COLUMN_NAME_IND")
       AND dra.attribute_value=1
      DETAIL
       IF (dra.attribute_name="BEG_EFFECTIVE COLUMN_NAME_IND")
        i_tab_info->beg_eff_col = dra.column_name
       ELSE
        i_tab_info->end_eff_col = dra.column_name
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
    SET dm_err->eproc = "Gathering PREV pk column information"
    SELECT INTO "nl:"
     FROM dm_columns_doc_local dcd
     WHERE dcd.table_name=i_table_name
      AND dcd.exception_flg=11
      AND  EXISTS (
     (SELECT
      "x"
      FROM dm_columns_doc_local dcd2
      WHERE dcd2.table_name=dcd.table_name
       AND dcd2.column_name=dcd.root_entity_attr
       AND dcd2.column_name=dcd2.root_entity_attr
       AND dcd2.table_name=dcd2.root_entity_name))
     DETAIL
      i_tab_info->prev_pk_col = dcd.column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (curqual=0)
     SELECT INTO "nl:"
      FROM dm_columns_doc_local dcd
      WHERE dcd.table_name=i_table_name
       AND dcd.column_name="PREV*"
       AND  EXISTS (
      (SELECT
       "x"
       FROM dm_columns_doc_local dcd2
       WHERE dcd2.table_name=dcd.table_name
        AND dcd2.column_name=dcd.root_entity_attr
        AND dcd2.column_name=dcd2.root_entity_attr
        AND dcd2.table_name=dcd2.root_entity_name))
      DETAIL
       i_tab_info->prev_pk_col = dcd.column_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   IF ((i_tab_info->vers_ind=1))
    SET stat = alterlist(i_tab_info->pk,1)
    SET dm_err->eproc = "Gathering version pk information."
    SELECT INTO "nl:"
     FROM dm_columns_doc_local dcd
     WHERE dcd.table_name=i_table_name
      AND dcd.table_name=dcd.root_entity_name
      AND dcd.column_name=dcd.root_entity_attr
     DETAIL
      i_tab_info->pk[1].column_name = dcd.column_name, i_tab_info->pk_diff_str = concat(" :new.",trim
       (dcd.column_name,3),"!= r1.",trim(dcd.column_name,3)), i_tab_info->pk_match_str = concat(
       " :new.",trim(dcd.column_name,3),"= r1.",trim(dcd.column_name,3)),
      gvi_idx = locateval(gvi_idx,1,i_data_type->col_cnt,dcd.column_name,i_data_type->cols[gvi_idx].
       col_name)
      IF (gvi_idx > 0)
       i_tab_info->pk[1].data_type = i_data_type->cols[gvi_idx].data_type
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ELSEIF (curqual != 1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("No top level found for versioned table: ",i_table_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    FOR (gvi_idx = 1 TO size(i_tab_info->ndx,5))
      IF (locateval(gvi_num,1,size(i_tab_info->ndx[gvi_idx].cols,5),i_tab_info->pk[1].column_name,
       i_tab_info->ndx[gvi_idx].cols[gvi_num].column_name) > 0)
       SET i_tab_info->ndx[gvi_idx].pk_superset_ind = 1
      ENDIF
    ENDFOR
   ENDIF
   RETURN(i_tab_info->vers_ind)
 END ;Subroutine
 SUBROUTINE get_soft_cons_info(i_soft_cons,i_tab_info,i_null_info,i_data_type)
   FREE RECORD gsci_req
   RECORD gsci_req(
     1 cnt = i4
     1 qual[*]
       2 obj_name = vc
       2 obj_type = vc
       2 obj_nbr = i4
     1 add_on_cnt = i4
     1 add_on_qual[*]
       2 obj_name = vc
       2 obj_type = vc
       2 obj_nbr = i4
       2 chk_cnt = i4
       2 chk_qual[*]
         3 chk_tab = vc
         3 chk_col = vc
   )
   FREE RECORD gsci_rep
   RECORD gsci_rep(
     1 cnt = i4
     1 qual[*]
       2 obj_name = vc
       2 obj_type = vc
       2 obj_nbr = i4
       2 valid_ind = i2
       2 checked_ind = i2
       2 chk_cnt = i4
       2 chk_qual[*]
         3 chk_tab = vc
         3 chk_col = vc
         3 exists_ind = i2
   )
   DECLARE gsci_distinct_col_cnt = i2 WITH protect, noconstant(0)
   DECLARE gsci_ui_cnt = i2 WITH protect, noconstant(0)
   DECLARE gsci_num = i2 WITH protect, noconstant(0)
   DECLARE gsci_col_cnt = i2 WITH protect, noconstant(0)
   DECLARE gsci_ui_ndx = i2 WITH protect, noconstant(0)
   DECLARE gsci_pk_superset_ind = i2 WITH protect, noconstant(0)
   DECLARE gsci_data_type = vc WITH protect, noconstant("")
   DECLARE gsci_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_refchg_soft_constraints drsc,
     dm_refchg_soft_cons_columns drscc
    WHERE (drsc.table_name=i_tab_info->table_name)
     AND drsc.active_ind=1
     AND drsc.dm_refchg_soft_constraints_id=drscc.dm_refchg_soft_constraints_id
    ORDER BY drsc.constraint_name
    HEAD REPORT
     gsci_ui_cnt = 0, gsci_distinct_col_cnt = size(i_tab_info->distinct_cols,5)
    HEAD drsc.constraint_name
     gsci_ui_cnt = (gsci_ui_cnt+ 1), stat = alterlist(i_soft_cons->ndx,gsci_ui_cnt), gsci_col_cnt = 0,
     start_distinct_cnt = gsci_distinct_col_cnt, i_soft_cons->ndx[gsci_ui_cnt].ndx_name = drsc
     .constraint_name, i_soft_cons->ndx[gsci_ui_cnt].where_clause = trim(drsc.where_clause),
     i_soft_cons->ndx[gsci_ui_cnt].block_where_clause = trim(drsc.block_where_clause), i_soft_cons->
     ndx[gsci_ui_cnt].reset_status = drsc.reset_status, i_soft_cons->ndx[gsci_ui_cnt].valid_ind = 1
     IF (size(i_soft_cons->ndx[gsci_ui_cnt].where_clause,1) > 0)
      gsci_req->cnt = (gsci_req->cnt+ 1), stat = alterlist(gsci_req->qual,gsci_req->cnt), gsci_req->
      qual[gsci_req->cnt].obj_name = drsc.constraint_name,
      gsci_req->qual[gsci_req->cnt].obj_type = "SOFT_CONSTRAINT"
     ENDIF
     gsci_req->add_on_cnt = gsci_ui_cnt, stat = alterlist(gsci_req->add_on_qual,gsci_req->add_on_cnt),
     gsci_req->add_on_qual[gsci_req->add_on_cnt].obj_name = drsc.constraint_name,
     gsci_req->add_on_qual[gsci_req->add_on_cnt].obj_type = "SOFT_CONSTRAINT"
    DETAIL
     gsci_col_cnt = (gsci_col_cnt+ 1), stat = alterlist(i_soft_cons->ndx[gsci_ui_cnt].cols,
      gsci_col_cnt), i_soft_cons->ndx[gsci_ui_cnt].cols[gsci_col_cnt].column_name = drscc.column_name,
     i_soft_cons->ndx[gsci_ui_cnt].cols[gsci_col_cnt].data_type = "NOT FOUND", gsci_req->add_on_qual[
     gsci_req->add_on_cnt].chk_cnt = gsci_col_cnt, stat = alterlist(gsci_req->add_on_qual[gsci_req->
      add_on_cnt].chk_qual,gsci_col_cnt),
     gsci_req->add_on_qual[gsci_req->add_on_cnt].chk_qual[gsci_col_cnt].chk_tab = drsc.table_name,
     gsci_req->add_on_qual[gsci_req->add_on_cnt].chk_qual[gsci_col_cnt].chk_col = drscc.column_name
     IF (locateval(gsci_num,1,gsci_distinct_col_cnt,drscc.column_name,i_tab_info->distinct_cols[
      gsci_num].column_name)=0)
      gsci_distinct_col_cnt = (gsci_distinct_col_cnt+ 1), stat = alterlist(i_tab_info->distinct_cols,
       gsci_distinct_col_cnt), i_tab_info->distinct_cols[gsci_distinct_col_cnt].column_name = drscc
      .column_name
     ENDIF
     IF (locateval(gsci_num,1,i_null_info->col_cnt,drscc.column_name,i_null_info->cols[gsci_num].
      col_name)=0)
      IF ((i_tab_info->table_name="PRSNL")
       AND drscc.column_name="USERNAME")
       i_soft_cons->ndx[gsci_ui_cnt].match_str = concat(i_soft_cons->ndx[gsci_ui_cnt].match_str,
        " and (replace(:new.",trim(drscc.column_name,3),",'~DM')= replace(r1.",trim(drscc.column_name,
         3),
        ",'~DM') or (:new.",trim(drscc.column_name,3)," is null and r1.",trim(drscc.column_name,3),
        " is null))")
      ELSE
       i_soft_cons->ndx[gsci_ui_cnt].match_str = concat(i_soft_cons->ndx[gsci_ui_cnt].match_str,
        " and (:new.",trim(drscc.column_name,3),"= r1.",trim(drscc.column_name,3),
        " or (:new.",trim(drscc.column_name,3)," is null and r1.",trim(drscc.column_name,3),
        " is null))")
      ENDIF
     ELSE
      i_soft_cons->ndx[gsci_ui_cnt].match_str = concat(i_soft_cons->ndx[gsci_ui_cnt].match_str,
       " and :new.",trim(drscc.column_name,3),"= r1.",trim(drscc.column_name,3))
     ENDIF
     gsci_idx = locateval(gsci_num,1,i_data_type->col_cnt,drscc.column_name,i_data_type->cols[
      gsci_num].col_name)
     IF (gsci_idx > 0)
      i_soft_cons->ndx[gsci_ui_cnt].cols[gsci_col_cnt].data_type = i_data_type->cols[gsci_idx].
      data_type
     ENDIF
    FOOT  drsc.constraint_name
     i_soft_cons->ndx[gsci_ui_cnt].col_cnt = gsci_col_cnt, i_soft_cons->ndx[gsci_ui_cnt].match_str =
     substring(6,10000,i_soft_cons->ndx[gsci_ui_cnt].match_str)
     IF (size(i_soft_cons->ndx[gsci_ui_cnt].where_clause,1) > 0)
      i_soft_cons->ndx[gsci_ui_cnt].match_str = concat(i_soft_cons->ndx[gsci_ui_cnt].match_str,
       " and ",i_soft_cons->ndx[gsci_ui_cnt].where_clause)
     ENDIF
    FOOT REPORT
     i_soft_cons->ndx_cnt = gsci_ui_cnt
    WITH nocounter
   ;end select
   IF (check_error("Checking for soft_constraints") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF ((i_soft_cons->ndx_cnt > 0))
    EXECUTE dm_rmc_obj_chk  WITH replace("DROC_REQUEST","GSCI_REQ"), replace("DROC_REPLY","GSCI_REP")
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN("F")
    ENDIF
    FOR (gsci_ui_cnt = 1 TO i_soft_cons->ndx_cnt)
      SET gsci_ui_ndx = locateval(gsci_num,1,gsci_rep->cnt,i_soft_cons->ndx[gsci_ui_cnt].ndx_name,
       gsci_rep->qual[gsci_num].obj_name)
      IF (gsci_ui_ndx > 0)
       SET i_soft_cons->ndx[gsci_ui_cnt].valid_ind = gsci_rep->qual[gsci_num].valid_ind
      ENDIF
      IF ((i_soft_cons->ndx[gsci_ui_cnt].valid_ind=1))
       SET gsci_col_cnt = locateval(gsci_num,1,i_soft_cons->ndx[gsci_ui_cnt].col_cnt,"NOT FOUND",
        i_soft_cons->ndx[gsci_ui_cnt].cols[gsci_num].data_type)
       IF (gsci_col_cnt > 0)
        SET i_soft_cons->ndx[gsci_ui_cnt].valid_ind = 0
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE case_insensitive_replace(i_orig_str,i_find_str,i_new_str)
   DECLARE cir_up_str = vc WITH protect, noconstant(cnvtupper(i_orig_str))
   DECLARE cir_up_find = vc WITH protect, constant(cnvtupper(i_find_str))
   DECLARE cir_ndx = i2 WITH protect, noconstant(0)
   DECLARE cir_ret_str = vc WITH protect, noconstant(i_orig_str)
   SET cir_ndx = findstring(cir_up_find,cir_up_str)
   WHILE (cir_ndx > 0)
     SET cir_ret_str = concat(substring(1,(cir_ndx - 1),cir_ret_str),i_new_str,substring((cir_ndx+
       size(i_find_str,1)),(((size(cir_ret_str,1) - cir_ndx) - size(i_find_str,1))+ 1),cir_ret_str))
     SET cir_up_str = cnvtupper(cir_ret_str)
     SET cir_ndx = findstring(cir_up_find,cir_up_str,(cir_ndx+ size(i_new_str,1)))
   ENDWHILE
   RETURN(cir_ret_str)
 END ;Subroutine
 DECLARE cutover_tab_name(i_normal_tab_name=vc,i_table_suffix=vc) = vc
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE cutover_tab_name(i_normal_tab_name,i_table_suffix)
   DECLARE s_new_tab_name = vc WITH protect
   DECLARE s_tab_suffix = vc WITH protect
   DECLARE s_lv_num = i4 WITH protect
   DECLARE s_lv_pos = i4 WITH protect
   IF (i_table_suffix > " ")
    SET s_tab_suffix = i_table_suffix
    SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
   ELSE
    SET s_lv_pos = locateval(s_lv_num,1,size(table_data->qual,5),i_normal_tab_name,table_data->qual[
     s_lv_num].table_name)
    IF (s_lv_pos > 0)
     SET s_tab_suffix = table_data->qual[s_lv_pos].table_suffix
     SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
    ELSE
     SELECT INTO "nl:"
      FROM dm_rdds_tbl_doc dtd
      WHERE dtd.table_name=i_normal_tab_name
       AND dtd.table_name=dtd.full_table_name
      HEAD REPORT
       stat = alterlist(table_data->qual,(table_data->counter+ 1)), table_data->counter = size(
        table_data->qual,5)
      DETAIL
       table_data->qual[table_data->counter].table_name = dtd.table_name, table_data->qual[table_data
       ->counter].table_suffix = dtd.table_suffix, s_new_tab_name = concat(trim(substring(1,14,
          i_normal_tab_name)),dtd.table_suffix,"$R")
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(s_new_tab_name)
 END ;Subroutine
 DECLARE add_tracking_row(i_source_id=f8,i_refchg_type=vc,i_refchg_status=vc) = null
 DECLARE delete_tracking_row(null) = null
 DECLARE move_long(i_from_table=vc,i_to_table=vc,i_column_name=vc,i_pk_str=vc,i_source_env_id=f8,
  i_status_flag=i4) = null
 DECLARE get_reg_tab_name(i_r_tab_name=vc,i_suffix=vc) = vc
 DECLARE dcc_find_val(i_delim_str=vc,i_delim_val=vc,i_val_rec=vc(ref)) = i2
 DECLARE move_circ_long(i_from_table=vc,i_from_rtable=vc,i_from_pk=vc,i_from_prev_pk=vc,i_from_fk=vc,
  i_from_pe_col=vc,i_circ_table=vc,i_circ_column_name=vc,i_circ_fk_col=vc,i_circ_long_col=vc,
  i_source_env_id=f8,i_status_flag=i4) = null
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE add_tracking_row(i_source_id,i_refchg_type,i_refchg_status)
   DECLARE var_process = vc
   DECLARE var_sid = f8
   DECLARE var_serial_num = f8
   SELECT INTO "nl:"
    process, sid, serial#
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    DETAIL
     var_process = vs.process, var_sid = vs.sid, var_serial_num = vs.serial#
    WITH maxqual(vs,1)
   ;end select
   UPDATE  FROM dm_refchg_process
    SET refchg_type = i_refchg_type, refchg_status = i_refchg_status, last_action_dt_tm = sysdate,
     updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE rdbhandle_value=cnvtreal(currdbhandle)
   ;end update
   COMMIT
   IF (curqual=0)
    INSERT  FROM dm_refchg_process
     SET dm_refchg_process_id = seq(dm_clinical_seq,nextval), env_source_id = i_source_id,
      rdbhandle_value = cnvtreal(currdbhandle),
      process_name = var_process, log_file = dm_err->logfile, last_action_dt_tm = sysdate,
      refchg_type = i_refchg_type, refchg_status = i_refchg_status, updt_cnt = 0,
      updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
      updt_task,
      updt_dt_tm = cnvtdatetime(curdate,curtime3), session_sid = var_sid, serial_number =
      var_serial_num
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_tracking_row(null)
  DELETE  FROM dm_refchg_process
   WHERE rdbhandle_value=cnvtreal(currdbhandle)
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE move_long(i_from_table,i_to_table,i_column_name,i_pk_str,i_source_env_id,i_status_flag)
   RECORD long_col(
     1 data[*]
       2 pk_str = vc
       2 long_str = vc
   )
   SET s_rdds_where_iu_str =
   " rdds_delete_ind = 0 and rdds_source_env_id = i_source_env_id and rdds_status_flag = i_status_flag"
   DECLARE long_str = vc
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_column_name),")"),0)
   CALL parser(concat("        , pk_str=",i_pk_str),0)
   CALL parser(concat("   from ",trim(i_from_table)," l "),0)
   CALL parser(concat(" where ",s_rdds_where_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (long_str = ' ') ",0)
   CALL parser("       long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser("       long_str = notrim(concat(long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser("   long_col->data[long_cnt].pk_str = pk_str",0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(long_str,5)",0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   FOR (lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_to_table)," set ",trim(i_column_name)),0)
     CALL parser("= long_col->data[lc_ndx].long_str where ",0)
     CALL parser(long_col->data[lc_ndx].pk_str,0)
     CALL parser(" go",1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_reg_tab_name(i_r_tab_name,i_suffix)
   DECLARE s_suffix = vc
   DECLARE s_tab_name = vc
   IF (i_suffix > " ")
    SET s_suffix = i_suffix
   ELSE
    SET s_suffix = substring((size(i_r_tab_name) - 5),4,i_r_tab_name)
   ENDIF
   SELECT INTO "nl:"
    dtd.table_name
    FROM dm_rdds_tbl_doc dtd
    WHERE dtd.table_suffix=s_suffix
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     s_tab_name = dtd.table_name
    WITH nocounter
   ;end select
   RETURN(s_tab_name)
 END ;Subroutine
 SUBROUTINE dcc_find_val(i_delim_str,i_delim_val,i_val_rec)
   DECLARE dfv_temp_delim_str = vc WITH constant(concat(i_delim_val,i_delim_str,i_delim_val)),
   protect
   DECLARE dfv_temp_str = vc WITH noconstant(""), protect
   DECLARE dfv_return = i2 WITH noconstant(0), protect
   IF (size(trim(i_delim_str),1) > 0)
    FOR (i = 1 TO i_val_rec->len)
      IF (size(trim(i_val_rec->values[i].str),1) > 0)
       SET dfv_temp_str = concat(i_delim_val,i_val_rec->values[i].str,i_delim_val)
       IF (findstring(dfv_temp_str,dfv_temp_delim_str) > 0)
        SET dfv_return = 1
        RETURN(dfv_return)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(dfv_return)
 END ;Subroutine
 SUBROUTINE move_circ_long(i_from_table,i_from_rtable,i_from_pk,i_from_prev_pk,i_from_fk,
  i_from_pe_col,i_circ_table,i_circ_column_name,i_circ_fk_col,i_circ_long_col,i_source_env_id,
  i_status_flag)
   DECLARE mcl_rdds_iu_str = vc WITH protect, noconstant("")
   DECLARE move_circ_lc_ndx = i4 WITH protect, noconstant(0)
   DECLARE move_circ_long_str = vc WITH protect, noconstant("")
   DECLARE evaluate_pe_name() = c255
   RECORD long_col(
     1 data[*]
       2 long_pk = f8
       2 long_col_fk = f8
       2 long_str = vc
   )
   SET mcl_rdds_iu_str =
   " r.rdds_delete_ind = 0 and r.rdds_source_env_id = i_source_env_id and r.rdds_status_flag = i_status_flag"
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_circ_long_col),")"),0)
   CALL parser(concat("   from ",trim(i_circ_table)," l, ",trim(i_from_table)," t, "),0)
   CALL parser(concat("         ",trim(i_from_rtable)," r "),0)
   CALL parser(concat(" where l.",trim(i_circ_column_name)," = t.",i_from_fk),0)
   CALL parser(concat("    and t.",i_from_pk," = r.",i_from_prev_pk),0)
   CALL parser(concat("    and r.",i_from_pk," != r.",i_from_prev_pk),0)
   IF (i_from_pe_col > "")
    CALL parser(concat("    and evaluate_pe_name('",i_from_table,"', '",i_from_fk,"','",
      i_from_pe_col,"', r.",i_from_pe_col,") = '",i_circ_table,
      "'"),0)
   ENDIF
   CALL parser(concat("    and l.",i_circ_column_name," > 0"),0)
   CALL parser(concat("    and ",mcl_rdds_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   move_circ_long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (move_circ_long_str = ' ') ",0)
   CALL parser("       move_circ_long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser(
    "       move_circ_long_str = notrim(concat(move_circ_long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser(concat("   long_col->data[long_cnt].long_pk = t.",i_from_pk),0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(move_circ_long_str,5)",0)
   CALL parser(concat("   long_col->data[long_cnt].long_col_fk = r.",i_from_fk),0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (move_circ_lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_circ_table)," t set ",trim(i_circ_long_col)),0)
     CALL parser("= long_col->data[move_circ_lc_ndx].long_str where ",0)
     CALL parser(concat("t.",i_circ_column_name," = ",trim(cnvtstring(long_col->data[move_circ_lc_ndx
         ].long_col_fk,20,2))),0)
     CALL parser(" go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(null)
     ENDIF
   ENDFOR
 END ;Subroutine
 IF ((validate(dcrt_list->r_cnt,- (1))=- (1))
  AND (validate(dcrt_list->r_cnt,- (2))=- (2)))
  FREE RECORD dcrt_list
  RECORD dcrt_list(
    1 r_cnt = i4
    1 reg_cnt = i4
    1 md_cnt = i4
    1 vr_cnt = i4
    1 r_list[*]
      2 table_suffix = vc
      2 trigger_name = vc
      2 validate_ind = i2
    1 reg_list[*]
      2 table_suffix = vc
      2 trigger_name = vc
      2 validate_ind = i2
    1 md_list[*]
      2 table_suffix = vc
      2 trigger_name = vc
      2 validate_ind = i2
    1 vr_list[*]
      2 table_suffix = vc
      2 trigger_name = vc
      2 validate_ind = i2
  )
 ENDIF
 IF (check_logfile("DM_CREATE_R_TRIGGERS",".log","DM_CREATE_R_TRIGGERS LogFile")=0)
  GO TO exit_main
 ENDIF
 FREE RECORD dcrt_tables
 RECORD dcrt_tables(
   1 cnt = i4
   1 list[*]
     2 table_name = vc
 )
 DECLARE dcrt_table_name = vc
 DECLARE dcrt_i_table = vc
 SET dcrt_i_table = cnvtupper(trim( $1))
 IF (dcrt_i_table=char(42))
  SET dcrt_table_name = "*$R"
 ELSE
  IF (dcrt_i_table="*$R")
   SET dcrt_table_name = dcrt_i_table
  ELSE
   SET dcrt_table_name = cutover_tab_name(dcrt_i_table,"")
  ENDIF
  SELECT INTO "nl:"
   FROM user_tables ut
   WHERE ut.table_name=dcrt_table_name
   WITH nocounter
  ;end select
  IF (check_error("ERROR while validating that the $R table exists") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
  IF (curqual=0)
   CALL echo("******************************************************")
   CALL echo(concat(dcrt_table_name," does not exist in this domain."))
   CALL echo("******************************************************")
   GO TO exit_main
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  dtd.table_name
  FROM dm_tables_doc_local dtd
  WHERE dtd.table_name=dtd.full_table_name
   AND dtd.table_suffix IN (
  (SELECT
   substring((findstring("$R",ut.table_name) - 4),4,ut.table_name)
   FROM user_tables ut
   WHERE ut.table_name=patstring(dcrt_table_name)))
  HEAD REPORT
   dcrt_tables->cnt = 0
  DETAIL
   dcrt_tables->cnt = (dcrt_tables->cnt+ 1)
   IF (dcrt_i_table=char(42))
    IF (mod(dcrt_tables->cnt,100)=1)
     stat = alterlist(dcrt_tables->list,(dcrt_tables->cnt+ 99))
    ENDIF
   ELSE
    stat = alterlist(dcrt_tables->list,dcrt_tables->cnt)
   ENDIF
   dcrt_tables->list[dcrt_tables->cnt].table_name = trim(dtd.table_name)
  FOOT REPORT
   stat = alterlist(dcrt_tables->list,dcrt_tables->cnt)
  WITH nocounter
 ;end select
 IF (check_error("ERROR while trying to obtain the live table names") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 FOR (dcrt_loop = 1 TO dcrt_tables->cnt)
   SET dm_err->eproc = concat("Recreating RMC triggers on ",dcrt_tables->list[dcrt_loop].table_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL add_cutover_trg(dcrt_tables->list[dcrt_loop].table_name)
   IF (check_error("Creating RMC triggers ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    GO TO exit_main
   ENDIF
 ENDFOR
#exit_main
END GO
