CREATE PROGRAM dm_rmc_setup_r_table:dba
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
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 DECLARE drsrt_extent_size = f8 WITH protect, noconstant(0.0)
 DECLARE drsrt_live_tab_name = vc WITH protect, noconstant("")
 DECLARE drsrt_$r_tab_name = vc WITH protect, noconstant("")
 DECLARE drsrt_table_suffix = vc WITH protect, noconstant("")
 DECLARE drsrt_col_cnt = i4 WITH protect, noconstant(0)
 DECLARE drsrt_ind_cnt = i4 WITH protect, noconstant(0)
 DECLARE drsrt_ind_col_cnt = i4 WITH protect, noconstant(0)
 DECLARE drsrt_new_ind_tspace = vc WITH protect, noconstant("")
 DECLARE drsrt_ind_altcnt = i4 WITH protect, noconstant(0)
 DECLARE drsrt_col_ind = i4 WITH protect, noconstant(0)
 DECLARE drsrt_idx = i4 WITH protect, noconstant(0)
 DECLARE drsrt_fbi_ind = i2 WITH protect, noconstant(0)
 DECLARE drsrt_idx_altcnt = i4 WITH protect, noconstant(0)
 DECLARE rem_idx_ind = i2 WITH protect, noconstant(0)
 DECLARE drsrt_ccl_vers = i4 WITH protect, constant((((cnvtint(currev) * 10000)+ (cnvtint(currevminor
   ) * 100))+ cnvtint(currevminor2)))
 DECLARE drsrt_part_tab_ind = i2 WITH protect, noconstant(0)
 DECLARE drsrt_part_def_tspace = vc WITH protect, noconstant(" ")
 DECLARE drsrt_ind_part_ind = i2 WITH protect, noconstant(0)
 DECLARE drsrt_ind_def_tspace = vc WITH protect, noconstant(" ")
 DECLARE drsrt_def_user_tspace = vc WITH protect, noconstant(" ")
 DECLARE drsrt_parse_str = vc WITH protect, noconstant(" 1 = 1 ")
 DECLARE for_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD drsrt_temp
 RECORD drsrt_temp(
   1 tbl[*]
     2 tbl_col_cnt = i4
     2 tbl_col[*]
       3 col_name = vc
     2 rem_col_cnt = i4
     2 rem_col[*]
       3 col_name = vc
 )
 IF (check_logfile("DM_RMC_SETUP_R_TAB",".log","DM_RMC_SETUP_R_TABLE LogFile")=0)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ENDIF
 SET drsrt_live_tab_name = cur_sch->tbl[1].tbl_name
 SELECT INTO "nl:"
  FROM dtableattr a,
   dtableattrl l
  PLAN (a
   WHERE a.table_name="USER_PART_TABLES")
   JOIN (l
   WHERE l.structtype="F"
    AND btest(l.stat,11)=0
    AND l.attr_name="STATUS")
  DETAIL
   drsrt_parse_str = ' p.status = "VALID" '
  WITH nocounter
 ;end select
 IF (check_error("Checking for user_part_tables.status column in ccldef") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM user_part_tables p
  WHERE p.table_name=drsrt_live_tab_name
   AND parser(drsrt_parse_str)
  DETAIL
   drsrt_part_tab_ind = 1, drsrt_part_def_tspace = p.def_tablespace_name
  WITH nocounter
 ;end select
 IF (check_error("Retrieving table partition status from user_part_tables") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dba_users d
  WHERE d.username=currdbuser
  DETAIL
   drsrt_def_user_tspace = d.default_tablespace
  WITH nocounter
 ;end select
 IF (check_error("Retrieving default user tablespace from dba_users") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ENDIF
 SET tgtsch->diff_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name="$R EXTENT_SIZE"
  DETAIL
   drsrt_extent_size = di.info_number
  WITH nocounter
 ;end select
 IF (check_error("Retrieving $R extent size from dm_info") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET drsrt_extent_size = 163840
  INSERT  FROM dm_info di
   SET di.info_domain = "RDDS CONFIGURATION", di.info_name = "$R EXTENT_SIZE", di.info_number =
    163840
   WITH nocounter
  ;end insert
  IF (check_error("Inserting $R extent size from dm_info") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET reply->status_data.status = "F"
   GO TO exit_program
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  WHERE dtd.table_name=drsrt_live_tab_name
   AND dtd.table_name=dtd.full_table_name
  DETAIL
   drsrt_table_suffix = dtd.table_suffix
  WITH nocounter
 ;end select
 IF (check_error("Retrieving table_suffix from dm_tables_doc") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ELSEIF (curqual=0)
  SET dm_err->emsg = concat("Table ",drsrt_live_tab_name,
   " not found in dm_tables_doc, cannot create $R table.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET reply->status_data.status = "F"
  GO TO exit_program
 ENDIF
 SET drsrt_$r_tab_name = cutover_tab_name(drsrt_live_tab_name,drsrt_table_suffix)
 FOR (for_cnt = 1 TO size(cur_sch->tbl[1].tbl_col,5))
   SET cur_sch->tbl[1].tbl_col[for_cnt].nullable = "Y"
 ENDFOR
 SET stat = alterlist(cur_sch->tbl,1)
 SET cur_sch->tbl_cnt = 1
 SET cur_sch->tbl[1].tbl_name = drsrt_$r_tab_name
 SET cur_sch->tbl[1].init_ext = drsrt_extent_size
 SET cur_sch->tbl[1].next_ext = drsrt_extent_size
 IF (drsrt_part_tab_ind=1
  AND daf_is_blank(cur_sch->tbl[1].tspace_name))
  IF (((daf_is_blank(drsrt_part_def_tspace)) OR (drsrt_part_def_tspace=drsrt_def_user_tspace)) )
   SELECT INTO "nl:"
    FROM user_tab_partitions utp
    WHERE utp.table_name=drsrt_live_tab_name
     AND utp.partition_position IN (
    (SELECT
     max(dtp.partition_position)
     FROM user_tab_partitions dtp
     WHERE dtp.table_name=drsrt_live_tab_name))
    DETAIL
     drsrt_part_def_tspace = utp.tablespace_name
    WITH nocounter
   ;end select
   IF (check_error("Retrieving max partition tablespace from user_tab_partitions") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET reply->status_data.status = "F"
    GO TO exit_program
   ENDIF
  ENDIF
  IF (daf_is_blank(drsrt_part_def_tspace))
   SELECT INTO "nl:"
    FROM user_tablespaces
    WHERE tablespace_name="D_RDDS"
    WITH nocounter
   ;end select
   IF (check_error("Checking for D_RDDS tablespace existence") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET reply->status_data.status = "F"
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Data tablespace tablespace D_RDDS not found for table ",
     drsrt_$r_tab_name)
    SET dm_err->user_action = "Please create data tablespace D_RDDS to continue"
    CALL disp_msg("",dm_err->logfile,1)
    SET reply->status_data.status = "F"
    SET dm_err->err_ind = 1
    GO TO exit_program
   ENDIF
   SET drsrt_part_def_tspace = "D_RDDS"
  ENDIF
  SET cur_sch->tbl[1].tspace_name = drsrt_part_def_tspace
 ENDIF
 IF (drsrt_ccl_vers > 80307)
  SET stat = alterlist(drsrt_temp->tbl,1)
  SELECT INTO "nl:"
   FROM user_tab_cols utc
   WHERE utc.table_name=drsrt_live_tab_name
    AND utc.hidden_column="NO"
    AND utc.virtual_column="NO"
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di
    WHERE di.info_domain="RDDS IGNORE COL LIST:*"
     AND sqlpassthru("utc.table_name like di.info_char and utc.column_name like di.info_name "))))
   DETAIL
    drsrt_temp->tbl[1].tbl_col_cnt = (drsrt_temp->tbl[1].tbl_col_cnt+ 1)
    IF (mod(drsrt_temp->tbl[1].tbl_col_cnt,10)=1)
     stat = alterlist(drsrt_temp->tbl[1].tbl_col,(drsrt_temp->tbl[1].tbl_col_cnt+ 9))
    ENDIF
    drsrt_temp->tbl[1].tbl_col[drsrt_temp->tbl[1].tbl_col_cnt].col_name = utc.column_name
   FOOT REPORT
    stat = alterlist(drsrt_temp->tbl[1].tbl_col,drsrt_temp->tbl[1].tbl_col_cnt)
   WITH nocounter
  ;end select
  IF (check_error("Retrieving non-excluded column list from user_tab_cols/dm_info") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET reply->status_data.status = "F"
   GO TO exit_program
  ENDIF
  SET for_cnt = 1
  WHILE ((for_cnt <= cur_sch->tbl[1].tbl_col_cnt))
    SET drsrt_idx = locateval(drsrt_idx,1,drsrt_temp->tbl[1].tbl_col_cnt,cur_sch->tbl[1].tbl_col[
     for_cnt].col_name,drsrt_temp->tbl[1].tbl_col[drsrt_idx].col_name)
    IF (drsrt_idx=0)
     SET drsrt_temp->tbl[1].rem_col_cnt = (drsrt_temp->tbl[1].rem_col_cnt+ 1)
     SET stat = alterlist(drsrt_temp->tbl[1].rem_col,drsrt_temp->tbl[1].rem_col_cnt)
     SET drsrt_temp->tbl[1].rem_col[drsrt_temp->tbl[1].rem_col_cnt].col_name = cur_sch->tbl[1].
     tbl_col[for_cnt].col_name
     SET stat = movereclist(cur_sch->tbl[1].tbl_col,cur_sch->tbl[1].tbl_col,(for_cnt+ 1),for_cnt,(
      cur_sch->tbl[1].tbl_col_cnt - for_cnt),
      0)
     IF ((for_cnt < cur_sch->tbl[1].tbl_col_cnt))
      SET for_cnt = (for_cnt - 1)
     ENDIF
     SET cur_sch->tbl[1].tbl_col_cnt = (cur_sch->tbl[1].tbl_col_cnt - 1)
    ENDIF
    SET for_cnt = (for_cnt+ 1)
  ENDWHILE
  SET stat = alterlist(cur_sch->tbl[1].tbl_col,cur_sch->tbl[1].tbl_col_cnt)
 ENDIF
 SET drsrt_col_cnt = size(cur_sch->tbl[1].tbl_col,5)
 SET stat = alterlist(cur_sch->tbl[1].tbl_col,(drsrt_col_cnt+ 8))
 SET cur_sch->tbl[1].tbl_col_cnt = (cur_sch->tbl[1].tbl_col_cnt+ 8)
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_STATUS_FLAG"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "NUMBER"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "N"
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_SOURCE_ENV_ID"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "NUMBER"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "N"
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_DELETE_IND"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "NUMBER"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "N"
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_DT_TM"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "DATE"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "N"
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_LOG_ID"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "NUMBER"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "N"
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_CONTEXT_NAME"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "VARCHAR2"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_length = 2000
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "Y"
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_PTAM_MATCH_RESULT"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "FLOAT"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "Y"
 SET drsrt_col_cnt = (drsrt_col_cnt+ 1)
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_name = "RDDS_PTAM_MATCH_RESULT_STR"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_type = "VARCHAR2"
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].data_length = 4000
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].col_seq = drsrt_col_cnt
 SET cur_sch->tbl[1].tbl_col[drsrt_col_cnt].nullable = "Y"
 SET cur_sch->tbl[1].cons_cnt = 0
 SET stat = alterlist(cur_sch->tbl[1].cons,0)
 SET drsrt_ind_cnt = size(cur_sch->tbl[1].ind,5)
 IF (drsrt_ccl_vers > 80307)
  FOR (for_cnt = 1 TO drsrt_ind_cnt)
   IF ((cur_sch->tbl[1].ind[for_cnt].index_type != "NORMAL"))
    SET rem_idx_ind = 1
   ELSE
    FOR (another_for = 1 TO cur_sch->tbl[1].ind[for_cnt].ind_col_cnt)
     SET drsrt_idx_altcnt = locateval(drsrt_idx_altcnt,1,drsrt_temp->tbl[1].rem_col_cnt,cur_sch->tbl[
      1].ind[for_cnt].ind_col[another_for].col_name,drsrt_temp->tbl[1].rem_col[drsrt_idx_altcnt].
      col_name)
     IF (drsrt_idx_altcnt > 0)
      SET rem_idx_ind = 1
     ENDIF
    ENDFOR
   ENDIF
   IF (rem_idx_ind > 0)
    SET stat = movereclist(cur_sch->tbl[1].ind,cur_sch->tbl[1].ind,(for_cnt+ 1),for_cnt,(
     drsrt_ind_cnt - for_cnt),
     0)
    IF (for_cnt < drsrt_ind_cnt)
     SET for_cnt = (for_cnt - 1)
    ENDIF
    SET drsrt_ind_cnt = (drsrt_ind_cnt - 1)
    SET rem_idx_ind = 0
   ENDIF
  ENDFOR
  SET cur_sch->tbl[1].ind_cnt = drsrt_ind_cnt
  SET stat = alterlist(cur_sch->tbl[1].ind,drsrt_ind_cnt)
 ENDIF
 FOR (for_cnt = 1 TO drsrt_ind_cnt)
   SET drsrt_ind_part_ind = 0
   SET cur_sch->tbl[1].ind[for_cnt].unique_ind = 0
   SET cur_sch->tbl[1].ind[for_cnt].init_ext = drsrt_extent_size
   SET cur_sch->tbl[1].ind[for_cnt].next_ext = drsrt_extent_size
   SELECT INTO "nl:"
    FROM user_part_indexes dpi
    WHERE (dpi.index_name=cur_sch->tbl[1].ind[for_cnt].ind_name)
    DETAIL
     drsrt_ind_part_ind = 1, drsrt_ind_def_tspace = dpi.def_tablespace_name
    WITH nocounter
   ;end select
   IF (check_error("Retrieving index partitioning status from user_part_indexes") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET reply->status_data.status = "F"
    GO TO exit_program
   ENDIF
   IF (drsrt_ind_part_ind=1
    AND ((daf_is_blank(drsrt_ind_def_tspace)) OR (drsrt_ind_def_tspace=drsrt_def_user_tspace)) )
    SELECT INTO "nl:"
     FROM user_ind_partitions uip
     WHERE (uip.index_name=cur_sch->tbl[1].ind[for_cnt].ind_name)
      AND uip.partition_position IN (
     (SELECT
      max(dip.partition_position)
      FROM user_ind_partitions dip
      WHERE (dip.index_name=cur_sch->tbl[1].ind[for_cnt].ind_name)))
     DETAIL
      drsrt_ind_def_tspace = uip.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error("Retrieving max partition tablespace from user_ind_partitions") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET reply->status_data.status = "F"
     GO TO exit_program
    ENDIF
    IF (daf_is_blank(drsrt_ind_def_tspace))
     SELECT INTO "nl:"
      FROM user_tablespaces
      WHERE tablespace_name="I_RDDS"
      WITH nocounter
     ;end select
     IF (check_error("Checking for I_RDDS tablespace existence") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET reply->status_data.status = "F"
      GO TO exit_program
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = concat("Index tablespace I_RDDS not found for table ",drsrt_$r_tab_name)
      SET dm_err->user_action = "Please create index tablespace I_RDDS to continue"
      CALL disp_msg("",dm_err->logfile,1)
      SET reply->status_data.status = "F"
      SET dm_err->err_ind = 1
      GO TO exit_program
     ENDIF
     SET drsrt_ind_def_tspace = "I_RDDS"
    ENDIF
   ENDIF
   IF (daf_is_blank(cur_sch->tbl[1].ind_tspace))
    SET cur_sch->tbl[1].ind_tspace = drsrt_ind_def_tspace
   ENDIF
   IF (daf_is_blank(cur_sch->tbl[1].ind[for_cnt].tspace_name))
    SET cur_sch->tbl[1].ind[for_cnt].tspace_name = drsrt_ind_def_tspace
    SET cur_sch->tbl[1].ind[for_cnt].tspace_name_ni = 0
   ENDIF
   SET cur_sch->tbl[1].ind[for_cnt].ind_name = concat(trim(substring(1,24,cur_sch->tbl[1].ind[for_cnt
      ].ind_name)),drsrt_table_suffix,"$R")
 ENDFOR
 IF (drsrt_ind_cnt=0)
  SET drsrt_new_ind_tspace = replace(cur_sch->tbl[1].tspace_name,"D_","I_",1)
  SELECT INTO "nl:"
   FROM user_tablespaces u
   WHERE u.tablespace_name=patstring(concat(drsrt_new_ind_tspace,"*"))
   ORDER BY u.tablespace_name
   DETAIL
    drsrt_new_ind_tspace = u.tablespace_name
   WITH nocounter, maxrec = 1
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    FROM user_tablespaces
    WHERE tablespace_name="I_RDDS"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dm_err->eproc = concat("Index tablespace ",drsrt_new_ind_tspace," not found for table ",
     drsrt_$r_tab_name)
    SET dm_err->user_action = "Please create index tablespace I_RDDS to continue"
    CALL disp_msg("",dm_err->logfile,1)
    SET reply->status_data.status = "F"
    SET dm_err->err_ind = 1
    GO TO exit_program
   ENDIF
   SET drsrt_new_ind_tspace = "I_RDDS"
  ENDIF
 ELSE
  SET drsrt_new_ind_tspace = cur_sch->tbl[1].ind[1].tspace_name
 ENDIF
 SET stat = alterlist(cur_sch->tbl[1].ind,(drsrt_ind_cnt+ 2))
 SET drsrt_ind_cnt = (drsrt_ind_cnt+ 1)
 SET cur_sch->tbl[1].ind_cnt = (cur_sch->tbl[1].ind_cnt+ 1)
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].tspace_name = drsrt_new_ind_tspace
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_name = concat("XIE1_$R_",drsrt_table_suffix)
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].unique_ind = 0
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].init_ext = drsrt_extent_size
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].next_ext = drsrt_extent_size
 SET stat = alterlist(cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col,1)
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col_cnt = 1
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col[1].col_name = "RDDS_STATUS_FLAG"
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col[1].col_position = 1
 SET drsrt_ind_cnt = (drsrt_ind_cnt+ 1)
 SET cur_sch->tbl[1].ind_cnt = (cur_sch->tbl[1].ind_cnt+ 1)
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].tspace_name = drsrt_new_ind_tspace
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_name = concat("XIE2_$R_",drsrt_table_suffix)
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].unique_ind = 0
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].init_ext = drsrt_extent_size
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].next_ext = drsrt_extent_size
 SET stat = alterlist(cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col,1)
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col_cnt = 1
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col[1].col_name = "RDDS_PTAM_MATCH_RESULT"
 SET cur_sch->tbl[1].ind[drsrt_ind_cnt].ind_col[1].col_position = 1
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(cur_sch)
 ENDIF
#exit_program
END GO
