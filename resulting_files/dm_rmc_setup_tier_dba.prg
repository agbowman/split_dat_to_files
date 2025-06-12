CREATE PROGRAM dm_rmc_setup_tier:dba
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
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 FREE RECORD drst_master
 RECORD drst_master(
   1 mstr_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 tier = i4
 )
 FREE RECORD drst_pe
 RECORD drst_pe(
   1 pe_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 fk_references = i4
     2 child_ind = i2
     2 done_ind = i2
     2 pe_tab_ind = i2
     2 fk[*]
       3 re_name = vc
       3 pe_col = vc
       3 pei_col = vc
       3 pe_data_cnt = i4
       3 pe_data[*]
         4 pe_value = vc
 )
 FREE RECORD drst_tier_ovr
 RECORD drst_tier_ovr(
   1 ovr_cnt = i4
   1 qual[*]
     2 last_dep_tab_name = vc
     2 primary_tab_name = vc
 )
 FREE RECORD drst_entity_ovr
 RECORD drst_entity_ovr(
   1 ovr_cnt = i4
   1 qual[*]
     2 table_name = vc
 )
 FREE RECORD pe_name_data
 RECORD pe_name_data(
   1 qual[*]
     2 table_name = vc
     2 pe_qual[*]
       3 pe_id = vc
       3 pe_name = vc
       3 val_qual[*]
         4 pe_value = vc
         4 pe_nullind = i2
 )
 DECLARE drst_mstr_cnt = i4
 DECLARE drst_mstr_loop = i4
 DECLARE drst_fk_cnt = i4
 DECLARE drst_cnt = i4
 DECLARE drst_loop = i4
 DECLARE drst_idx = i4
 DECLARE drst_last_cnt = i4
 DECLARE drst_cur_cnt = i4
 DECLARE drst_pe_cnt = i4
 DECLARE drst_pe_loop = i4
 DECLARE drst_tier_cnt = i4
 DECLARE drst_ovr_cnt = i4
 DECLARE drst_pos = i4
 DECLARE drst_num = i4
 DECLARE drst_nvld_ind = i2
 DECLARE drst_start = i4
 DECLARE drst_nvld_tab_name = vc
 DECLARE drst_col_pos = i4
 DECLARE drst_i = i4
 DECLARE drst_first = i2
 DECLARE drst_tgt_env_id = f8
 DECLARE drst_fun_cnt = i4
 DECLARE last_tab_name = vc
 DECLARE tab_cnt = i4
 DECLARE pe_col_cnt = i4
 DECLARE pe_cnt = i4
 DECLARE pe_val_loop = i4
 DECLARE evaluate_pe_name() = c2000
 IF (validate(drst_event_reason,"a")="a"
  AND validate(drst_event_reason,"b")="b")
  DECLARE drst_event_reason = vc
  SET drst_event_reason = "Interactive Run"
 ENDIF
 SET dm_err->eproc = "Starting dm_rmc_setup_tier"
 IF (check_logfile("dm_rmc_setup_tier_",".log","DM_RMC_SETUP_TIER LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Getting current env_id from dm_info"
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   drst_tgt_env_id = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Gathering Top level tables"
 SELECT INTO "NL:"
  FROM dm_tables_doc_local d,
   dm_columns_doc_local c,
   user_tab_columns u
  PLAN (d
   WHERE d.table_name=d.full_table_name
    AND ((d.reference_ind=1
    AND d.mergeable_ind=1) OR (d.table_name IN (
   (SELECT
    rt.table_name
    FROM dm_rdds_refmrg_tables rt))))
    AND  NOT (d.table_name IN ("LONG_TEXT_REFERENCE", "LONG_BLOB_REFERENCE", "LONG_TEXT", "LONG_BLOB"
   )))
   JOIN (c
   WHERE c.table_name=d.table_name
    AND c.table_name=c.root_entity_name
    AND c.column_name=c.root_entity_attr)
   JOIN (u
   WHERE u.table_name=c.table_name
    AND u.column_name=c.column_name
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM code_value cv
    WHERE cv.code_set=4001912
     AND cv.active_ind=1
     AND cv.display=u.table_name)))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di
    WHERE di.info_domain="RDDS IGNORE COL LIST:*"
     AND sqlpassthru(" c.column_name like di.info_name and c.table_name like di.info_char")))))
  HEAD REPORT
   drst_cnt = 0
  DETAIL
   drst_cnt = (drst_cnt+ 1)
   IF (mod(drst_cnt,25)=1)
    stat = alterlist(drst_pe->qual,(drst_cnt+ 24))
   ENDIF
   drst_pe->qual[drst_cnt].table_name = c.table_name
  FOOT REPORT
   drst_pe->pe_cnt = drst_cnt, stat = alterlist(drst_pe->qual,drst_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Gathering Tier Overrides"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="RDDS TIER OVERRIDE"
  HEAD REPORT
   drst_ovr_cnt = 0
  DETAIL
   drst_ovr_cnt = (drst_ovr_cnt+ 1)
   IF (mod(drst_ovr_cnt,25)=1)
    stat = alterlist(drst_tier_ovr->qual,(drst_ovr_cnt+ 24))
   ENDIF
   drst_tier_ovr->qual[drst_ovr_cnt].last_dep_tab_name = d.info_char, drst_tier_ovr->qual[
   drst_ovr_cnt].primary_tab_name = d.info_name
  FOOT REPORT
   stat = alterlist(drst_tier_ovr->qual,drst_ovr_cnt), drst_tier_ovr->ovr_cnt = drst_ovr_cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Gathering Entity Overrides"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="RDDS ENTITY OVERRIDE"
  HEAD REPORT
   drst_ovr_cnt
  DETAIL
   drst_ovr_cnt = (drst_ovr_cnt+ 1)
   IF (mod(drst_ovr_cnt,25)=1)
    stat = alterlist(drst_entity_ovr->qual,(drst_ovr_cnt+ 24))
   ENDIF
   drst_entity_ovr->qual[drst_ovr_cnt].table_name = d.info_name
  FOOT REPORT
   stat = alterlist(drst_entity_ovr->qual,drst_ovr_cnt), drst_entity_ovr->ovr_cnt = drst_ovr_cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 FOR (drst_loop = 1 TO drst_pe->pe_cnt)
   SET drst_ovr_pos = locateval(drst_num,1,drst_tier_ovr->ovr_cnt,drst_pe->qual[drst_loop].table_name,
    drst_tier_ovr->qual[drst_num].primary_tab_name)
   IF (drst_ovr_pos > 0)
    SET drst_pe->qual[drst_loop].fk_references = 1
    SET stat = alterlist(drst_pe->qual[drst_loop].fk,drst_pe->qual[drst_loop].fk_references)
    SET drst_pe->qual[drst_loop].fk[1].re_name = drst_tier_ovr->qual[drst_num].last_dep_tab_name
   ELSE
    SELECT INTO "NL:"
     FROM dm_columns_doc_local c
     WHERE (c.table_name=drst_pe->qual[drst_loop].table_name)
      AND ((c.root_entity_name IS NOT null
      AND  NOT (trim(c.root_entity_name) IN ("", drst_pe->qual[drst_loop].table_name,
     "LONG_TEXT_REFERENCE", "LONG_TEXT", "LONG_BLOB_REFERENCE",
     "LONG_BLOB"))
      AND ((c.root_entity_name IN (
     (SELECT
      table_name
      FROM dm_tables_doc_local
      WHERE reference_ind=1
       AND mergeable_ind=1))) OR (c.root_entity_name IN (
     (SELECT
      rt.table_name
      FROM dm_rdds_refmrg_tables rt))))
      AND  NOT (c.root_entity_name IN (
     (SELECT
      display
      FROM code_value
      WHERE code_set=4001912
       AND active_ind=1)))) OR (c.parent_entity_col IS NOT null
      AND  NOT (trim(c.parent_entity_col) IN ("", " "))))
      AND  EXISTS (
     (SELECT
      "X"
      FROM user_tab_columns utc
      WHERE utc.table_name=c.table_name
       AND utc.column_name=c.column_name))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" c.column_name like di.info_name and c.table_name like di.info_char"))))
     HEAD REPORT
      drst_fk_cnt = 0
     DETAIL
      drst_fk_cnt = (drst_fk_cnt+ 1)
      IF (mod(drst_fk_cnt,25)=1)
       stat = alterlist(drst_pe->qual[drst_loop].fk,(drst_fk_cnt+ 24))
      ENDIF
      IF (c.root_entity_name > " ")
       IF (c.root_entity_name="PERSON")
        drst_pe->qual[drst_loop].fk[drst_fk_cnt].re_name = "PRSNL"
       ELSE
        drst_pe->qual[drst_loop].fk[drst_fk_cnt].re_name = c.root_entity_name
       ENDIF
      ELSE
       drst_pe->qual[drst_loop].fk[drst_fk_cnt].pe_col = c.parent_entity_col, drst_pe->qual[drst_loop
       ].fk[drst_fk_cnt].pei_col = c.column_name, drst_pe->qual[drst_loop].pe_tab_ind = 1
      ENDIF
     FOOT REPORT
      stat = alterlist(drst_pe->qual[drst_loop].fk,drst_fk_cnt), drst_pe->qual[drst_loop].
      fk_references = drst_fk_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
   IF ((drst_pe->qual[drst_loop].fk_references=0))
    SET drst_master->mstr_cnt = (drst_master->mstr_cnt+ 1)
    SET stat = alterlist(drst_master->qual,drst_master->mstr_cnt)
    SET drst_master->qual[drst_master->mstr_cnt].table_name = drst_pe->qual[drst_loop].table_name
    SET drst_master->qual[drst_master->mstr_cnt].tier = 1
    SET drst_pe->qual[drst_loop].done_ind = 1
   ENDIF
 ENDFOR
 FOR (drst_loop = 1 TO drst_pe->pe_cnt)
   IF ((drst_pe->qual[drst_loop].fk_references > 0))
    FOR (drst_idx = 1 TO drst_pe->qual[drst_loop].fk_references)
      IF ((drst_pe->qual[drst_loop].fk[drst_idx].pe_col > ""))
       SET dm_err->eproc = "Gathering Parent Entity information"
       IF ((last_tab_name != drst_pe->qual[drst_loop].table_name))
        SET tab_cnt = (tab_cnt+ 1)
        SET stat = alterlist(pe_name_data->qual,tab_cnt)
        SET pe_name_data->qual[tab_cnt].table_name = drst_pe->qual[drst_loop].table_name
        SET last_tab_name = drst_pe->qual[drst_loop].table_name
        SET pe_col_cnt = 0
       ENDIF
       SET pe_col_cnt = (pe_col_cnt+ 1)
       SET stat = alterlist(pe_name_data->qual[tab_cnt].pe_qual,pe_col_cnt)
       SET pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].pe_id = drst_pe->qual[drst_loop].fk[
       drst_idx].pei_col
       SET pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].pe_name = drst_pe->qual[drst_loop].fk[
       drst_idx].pe_col
       SET pe_cnt = 0
       CALL dm2_push_cmd(concat("select distinct into 'NL:' d.",drst_pe->qual[drst_loop].fk[drst_idx]
         .pe_col),0)
       CALL dm2_push_cmd(concat(" ,n_ind = nullind(d.",drst_pe->qual[drst_loop].fk[drst_idx].pe_col,
         ")"),0)
       CALL dm2_push_cmd(concat(" from ",drst_pe->qual[drst_loop].table_name," d "),0)
       CALL dm2_push_cmd(concat("where d.",drst_pe->qual[drst_loop].fk[drst_idx].pe_col,
         " not in ('LONG_TEXT', 'LONG_TEXT_REFERENCE'"),0)
       CALL dm2_push_cmd(concat(", 'LONG_BLOB','LONG_BLOB_REFERENCE','",drst_pe->qual[drst_loop].
         table_name,"' )"),0)
       CALL dm2_push_cmd(concat(" and d.",drst_pe->qual[drst_loop].fk[drst_idx].pei_col," > 0 "),0)
       CALL dm2_push_cmd(concat(" and d.",drst_pe->qual[drst_loop].fk[drst_idx].pe_col,
         " not in (select display from code_value where code_set = 4001912 and active_ind = 1)"),0)
       CALL dm2_push_cmd(" head report pe_cnt = 0",0)
       CALL dm2_push_cmd(" detail pe_cnt = pe_cnt + 1 ",0)
       CALL dm2_push_cmd(" if(mod(pe_cnt, 25) = 1) ",0)
       CALL dm2_push_cmd(
        " stat = alterlist(pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual, pe_cnt+24) endif",
        0)
       CALL dm2_push_cmd(concat(
         " pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[pe_cnt].pe_value = d.",drst_pe->
         qual[drst_loop].fk[drst_idx].pe_col),0)
       CALL dm2_push_cmd(
        " pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[pe_cnt].pe_nullind = n_ind ",0)
       CALL dm2_push_cmd(
        " foot report stat = alterlist(pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual, pe_cnt)",
        0)
       CALL dm2_push_cmd(" with nocounter go",1)
       FOR (pe_val_loop = 1 TO size(pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual,5))
         CALL dm2_push_cmd("select into 'NL:' func_val = evaluate_pe_name(",0)
         IF ((((pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[pe_cnt].pe_nullind=1)) OR (
         findstring(char(0),pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[pe_val_loop].
          pe_value,1,0) > 0)) )
          CALL dm2_push_cmd(concat("'",pe_name_data->qual[tab_cnt].table_name,"','",pe_name_data->
            qual[tab_cnt].pe_qual[pe_col_cnt].pe_id,"','",
            pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].pe_name,"',NULL)"),0)
         ELSE
          IF (findstring("'",pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[pe_val_loop].
           pe_value,1,0) > 0)
           CALL dm2_push_cmd(concat("'",pe_name_data->qual[tab_cnt].table_name,"','",pe_name_data->
             qual[tab_cnt].pe_qual[pe_col_cnt].pe_id,"','",
             pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].pe_name,"',^",pe_name_data->qual[tab_cnt
             ].pe_qual[pe_col_cnt].val_qual[pe_val_loop].pe_value,"^)"),0)
          ELSE
           CALL dm2_push_cmd(concat("'",pe_name_data->qual[tab_cnt].table_name,"','",pe_name_data->
             qual[tab_cnt].pe_qual[pe_col_cnt].pe_id,"','",
             pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].pe_name,"','",pe_name_data->qual[tab_cnt
             ].pe_qual[pe_col_cnt].val_qual[pe_val_loop].pe_value,"')"),0)
          ENDIF
         ENDIF
         CALL dm2_push_cmd(concat(" from dual d "),0)
         CALL dm2_push_cmd(concat(
           " detail pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[pe_val_loop].pe_value",
           " = func_val with nocounter go "),1)
       ENDFOR
       IF (size(pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual,5) > 0)
        SET drst_fun_cnt = 0
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = size(pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual,5)),
          dm_columns_doc_local t
         PLAN (d)
          JOIN (t
          WHERE (t.table_name=pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[d.seq].
          pe_value)
           AND t.table_name=t.root_entity_name
           AND t.column_name=t.root_entity_attr
           AND ((t.table_name IN (
          (SELECT
           td.table_name
           FROM dm_tables_doc_local td
           WHERE td.reference_ind=1
            AND td.mergeable_ind=1))) OR (t.table_name IN (
          (SELECT
           rt.table_name
           FROM dm_rdds_refmrg_tables rt))))
           AND  NOT ( EXISTS (
          (SELECT
           "x"
           FROM dm_info di
           WHERE di.info_domain="RDDS IGNORE COL LIST:*"
            AND sqlpassthru(" t.column_name like di.info_name and t.table_name like di.info_char"))))
          )
         DETAIL
          drst_fun_cnt = (drst_fun_cnt+ 1), stat = alterlist(drst_pe->qual[drst_loop].fk[drst_idx].
           pe_data,drst_fun_cnt), drst_pe->qual[drst_loop].fk[drst_idx].pe_data[drst_fun_cnt].
          pe_value = pe_name_data->qual[tab_cnt].pe_qual[pe_col_cnt].val_qual[d.seq].pe_value,
          drst_pe->qual[drst_loop].fk[drst_idx].pe_data_cnt = drst_fun_cnt
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET drst_tier_cnt = 2
 SET drst_last_cnt = drst_pe->pe_cnt
 SET drst_cur_cnt = 0
 WHILE (drst_last_cnt != drst_cur_cnt)
   SET drst_last_cnt = drst_cur_cnt
   SET drst_cur_cnt = 0
   FOR (drst_loop = 1 TO drst_pe->pe_cnt)
     IF ((drst_pe->qual[drst_loop].fk_references > 0)
      AND (drst_pe->qual[drst_loop].done_ind=0))
      SET drst_pe->qual[drst_loop].child_ind = 0
      FOR (drst_mstr_loop = 1 TO drst_pe->qual[drst_loop].fk_references)
        IF ((drst_pe->qual[drst_loop].fk[drst_mstr_loop].re_name > ""))
         SET drst_pos = locateval(drst_idx,1,drst_master->mstr_cnt,drst_pe->qual[drst_loop].fk[
          drst_mstr_loop].re_name,drst_master->qual[drst_idx].table_name)
         SET drst_i = locateval(drst_idx,1,drst_entity_ovr->ovr_cnt,drst_pe->qual[drst_loop].fk[
          drst_mstr_loop].re_name,drst_entity_ovr->qual[drst_idx].table_name)
         IF (drst_pos=0)
          IF (drst_i=0)
           SET drst_pe->qual[drst_loop].child_ind = 1
          ENDIF
         ELSEIF ((drst_master->qual[drst_pos].tier >= drst_tier_cnt)
          AND drst_i=0)
          SET drst_pe->qual[drst_loop].child_ind = 1
         ENDIF
        ELSE
         FOR (drst_pe_loop = 1 TO drst_pe->qual[drst_loop].fk[drst_mstr_loop].pe_data_cnt)
           SET drst_pos = locateval(drst_idx,1,drst_master->mstr_cnt,drst_pe->qual[drst_loop].fk[
            drst_mstr_loop].pe_data[drst_pe_loop].pe_value,drst_master->qual[drst_idx].table_name)
           SET drst_i = locateval(drst_idx,1,drst_entity_ovr->ovr_cnt,drst_pe->qual[drst_loop].fk[
            drst_mstr_loop].pe_data[drst_pe_loop].pe_value,drst_entity_ovr->qual[drst_idx].table_name
            )
           IF (drst_pos=0)
            IF (drst_i=0)
             SET drst_pe->qual[drst_loop].child_ind = 1
            ENDIF
           ELSEIF ((drst_master->qual[drst_pos].tier >= drst_tier_cnt)
            AND drst_i=0)
            SET drst_pe->qual[drst_loop].child_ind = 1
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      IF ((drst_pe->qual[drst_loop].child_ind=0))
       SET drst_master->mstr_cnt = (drst_master->mstr_cnt+ 1)
       SET stat = alterlist(drst_master->qual,drst_master->mstr_cnt)
       SET drst_master->qual[drst_master->mstr_cnt].table_name = drst_pe->qual[drst_loop].table_name
       SET drst_master->qual[drst_master->mstr_cnt].tier = drst_tier_cnt
       SET drst_pe->qual[drst_loop].done_ind = 1
      ELSE
       SET drst_cur_cnt = (drst_cur_cnt+ 1)
      ENDIF
     ENDIF
   ENDFOR
   SET drst_tier_cnt = (drst_tier_cnt+ 1)
 ENDWHILE
 SET dm_err->eproc = "Deleting old tier list information for DM_INFO"
 DELETE  FROM dm_info di
  WHERE di.info_domain="RDDS TIER LIST"
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 SET dm_err->eproc = "Inserting tier information into DM_INFO."
 INSERT  FROM dm_info di,
   (dummyt d  WITH seq = value(drst_master->mstr_cnt))
  SET di.info_domain = "RDDS TIER LIST", di.info_name = drst_master->qual[d.seq].table_name, di
   .info_number = drst_master->qual[d.seq].tier,
   di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (di)
  WITH nocounter
 ;end insert
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 SET stat = alterlist(auto_ver_request->qual,1)
 SET auto_ver_request->qual[1].rdds_event = "Tiering Information Loaded"
 SET auto_ver_request->qual[1].event_reason = drst_event_reason
 SET auto_ver_request->qual[1].cur_environment_id = drst_tgt_env_id
 SET auto_ver_request->qual[1].paired_environment_id = 0
 SET stat = alterlist(auto_ver_request->qual[1].detail_qual,0)
 EXECUTE dm_rmc_auto_verify_setup
 IF ((dm_err->debug_flag > 0))
  CALL echo("******************")
  CALL echo("TABLES NOT ADDED")
  CALL echo("******************")
  FOR (drst_loop = 1 TO drst_pe->pe_cnt)
    IF ((drst_pe->qual[drst_loop].fk_references > 0))
     IF (locateval(drst_idx,1,drst_master->mstr_cnt,drst_pe->qual[drst_loop].table_name,drst_master->
      qual[drst_idx].table_name)=0)
      CALL echo(drst_pe->qual[drst_loop].table_name)
      FOR (drst_mstr_loop = 1 TO drst_pe->qual[drst_loop].fk_references)
        IF ((drst_pe->qual[drst_loop].fk[drst_mstr_loop].re_name > ""))
         IF (locateval(drst_idx,1,drst_master->mstr_cnt,drst_pe->qual[drst_loop].fk[drst_mstr_loop].
          re_name,drst_master->qual[drst_idx].table_name)=0)
          CALL echo(concat("    ",drst_pe->qual[drst_loop].fk[drst_mstr_loop].re_name))
         ENDIF
        ELSE
         FOR (drst_pe_loop = 1 TO drst_pe->qual[drst_loop].fk[drst_mstr_loop].pe_data_cnt)
           IF (locateval(drst_idx,1,drst_master->mstr_cnt,drst_pe->qual[drst_loop].fk[drst_mstr_loop]
            .pe_data[drst_pe_loop].pe_value,drst_master->qual[drst_idx].table_name)=0)
            CALL echo(concat("      PE - ",drst_pe->qual[drst_loop].fk[drst_mstr_loop].pe_data[
              drst_pe_loop].pe_value))
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
  ENDFOR
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("******************")
  CALL echo("MASTER TABLE ORDER")
  CALL echo("******************")
  FOR (drst_loop = 1 TO drst_master->mstr_cnt)
    CALL echo(concat(trim(cnvtstring(drst_master->qual[drst_loop].tier)),"     ",drst_master->qual[
      drst_loop].table_name))
  ENDFOR
 ENDIF
#exit_program
 SET dm_err->eproc = "...Ending DM_RMC_SETUP_TIER"
 CALL final_disp_msg("dm_rmc_setup_hier_")
END GO
