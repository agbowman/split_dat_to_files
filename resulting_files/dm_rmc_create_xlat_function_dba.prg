CREATE PROGRAM dm_rmc_create_xlat_function:dba
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
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE drdc_to_string(dts_num=f8) = vc
 SUBROUTINE drdc_to_string(dts_num)
   DECLARE dts_str = vc WITH protect, noconstant("")
   SET dts_str = trim(cnvtstring(dts_num,20),3)
   IF (findstring(".",dts_str)=0)
    SET dts_str = concat(dts_str,".0")
   ENDIF
   RETURN(dts_str)
 END ;Subroutine
 DECLARE drmmi_set_mock_id(dsmi_cur_id=f8,dsmi_final_tgt_id=f8,dsmi_mock_ind=i2) = i4
 DECLARE drmmi_get_mock_id(dgmi_env_id=f8) = f8
 DECLARE drmmi_backfill_mock_id(dbmi_env_id=f8) = f8
 SUBROUTINE drmmi_set_mock_id(dsmi_cur_id,dsmi_final_tgt_id,dsmi_mock_ind)
   DECLARE dsmi_info_char = vc WITH protect, noconstant("")
   DECLARE dsmi_mock_str = vc WITH protect, noconstant("")
   SET dsmi_info_char = drdc_to_string(dsmi_cur_id)
   SET dm_err->eproc = "Delete current mock setting."
   DELETE  FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dsmi_mock_ind=1)
    SET dsmi_mock_str = "RDDS_MOCK_ENV_ID"
   ELSE
    SET dsmi_mock_str = "RDDS_NO_MOCK_ENV_ID"
   ENDIF
   SET dm_err->eproc = "Inserting new mock setting into dm_info."
   INSERT  FROM dm_info di
    SET di.info_domain = "DATA MANAGEMENT", di.info_name = dsmi_mock_str, di.info_number =
     dsmi_final_tgt_id,
     di.info_char = dsmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Log Mock Copy of Prod Change event."
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Mock Copy of Prod Change"
   SET auto_ver_request->qual[1].cur_environment_id = dsmi_cur_id
   SET auto_ver_request->qual[1].paired_environment_id = dsmi_final_tgt_id
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmmi_get_mock_id(dgmi_env_id)
   DECLARE dgmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgmi_info_char = vc WITH protect, noconstant("")
   IF (dgmi_env_id=0.0)
    SET dm_err->eproc = "Gathering environment_id from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dgmi_env_id = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ELSEIF (dgmi_env_id=0.0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Could not retrieve valid environment_id"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET dgmi_info_char = drdc_to_string(dgmi_env_id)
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dgmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dgmi_mock_id = di.info_number
     ELSE
      dgmi_mock_id = dgmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSEIF (curqual > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid MOCK setup detected."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgmi_mock_id=0.0)
    SET dgmi_mock_id = drmmi_backfill_mock_id(dgmi_env_id)
    IF (dgmi_mock_id < 0.0)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(dgmi_mock_id)
 END ;Subroutine
 SUBROUTINE drmmi_backfill_mock_id(dbmi_env_id)
   DECLARE dbmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dbmi_info_char = vc WITH protect, noconstant("")
   DECLARE dbmi_continue = i2 WITH protect, noconstant(0)
   SET dbmi_info_char = drdc_to_string(dbmi_env_id)
   WHILE (dbmi_continue=0)
     SET drl_reply->status = ""
     SET drl_reply->status_msg = ""
     CALL get_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,0,drl_reply)
     IF ((drl_reply->status="F"))
      CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = drl_reply->status_msg
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSEIF ((drl_reply->status="Z"))
      CALL pause(10)
     ELSE
      SET dbmi_continue = 1
     ENDIF
   ENDWHILE
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dbmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dbmi_mock_id = di.info_number
     ELSE
      dbmi_mock_id = dbmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
    RETURN(- (1))
   ENDIF
   IF (dbmi_mock_id=0.0)
    UPDATE  FROM dm_info di
     SET di.info_char = dbmi_info_char
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS_MOCK_ENV_ID"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
     RETURN(- (1))
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Updating RDDS_NO_MOCK_ENV_ID row."
     UPDATE  FROM dm_info di
      SET di.info_number = 0.0, di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->
       updt_applctx,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = reqinfo->updt_id,
       di.updt_task = reqinfo->updt_task
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_NO_MOCK_ENV_ID"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSE
      COMMIT
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = "Inserting RDDS_NO_MOCK_ENV_ID row."
      INSERT  FROM dm_info di
       SET di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS_NO_MOCK_ENV_ID", di.info_number
         = 0.0,
        di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
       RETURN(- (1))
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dbmi_mock_id = dbmi_env_id
    ELSE
     SET dm_err->eproc = "Querying for mock id."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_MOCK_ENV_ID"
       AND di.info_char=dbmi_info_char
      DETAIL
       dbmi_mock_id = di.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
   RETURN(dbmi_mock_id)
 END ;Subroutine
 DECLARE drcxf_logfile_prefix = vc WITH protect, constant("dm_rmc_xlat_fn")
 DECLARE itgtenvid = f8 WITH protect, noconstant(0.0)
 DECLARE isrcenvid = f8 WITH protect, noconstant(0.0)
 DECLARE imockenvid = f8 WITH protect, noconstant(0.0)
 DECLARE isrctgtmapid = f8 WITH protect, noconstant(0.0)
 DECLARE ifullcircleind = i4 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE senvpair = vc WITH protect, noconstant("")
 DECLARE ssrcenvid = vc WITH protect, noconstant("")
 DECLARE stgtenvid = vc WITH protect, noconstant("")
 DECLARE ssrctgtmapid = vc WITH protect, noconstant("")
 DECLARE ssql = vc WITH protect, noconstant("")
 DECLARE sdb_link = vc WITH protect, noconstant(" ")
 DECLARE drcxf_ctx_ind = i2 WITH protect, noconstant(0)
 DECLARE drcsf_mock_ind = i2 WITH protect, noconstant(0)
 DECLARE drcsf_mock_dt_str = vc WITH protect, noconstant(" ")
 IF ((validate(drdm_debug_row_ind,- (1))=- (1)))
  DECLARE drdm_debug_row_ind = i2 WITH protect, noconstant(0)
 ENDIF
 IF (check_logfile(drcxf_logfile_prefix,".log","DM_RMC_CREATE_XLAT_FUNCTION Logfile")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning DM_RMC_CREATE_XLAT_FUNCTION"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Validating the request structure...."
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((validate(request->source_env_id,- (1.0))=- (1.0)))
  FREE RECORD request
  RECORD request(
    1 source_env_id = f8
    1 target_env_id = f8
  )
  SET request->source_env_id =  $1
  SET request->target_env_id =  $2
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET isrcenvid = request->source_env_id
 SET itgtenvid = request->target_env_id
 SET ssrcenvid = trim(cnvtstring(isrcenvid,20,0),3)
 SET stgtenvid = trim(cnvtstring(itgtenvid,20,0),3)
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("iSrcEnvId = ",isrcenvid))
  CALL echo(build("iTgtEnvId = ",itgtenvid))
  CALL echo(build("sSrcEnvId = ",ssrcenvid))
  CALL echo(build("sTgtEnvId = ",stgtenvid))
  CALL echo("The following is the Request structure:")
  CALL echorecord(request)
 ENDIF
 SET senvpair = concat(ssrcenvid,"::",stgtenvid)
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("sEnvPair = ",senvpair))
 ENDIF
 SET dm_err->eproc = "Obtaining Source-Target Mapping ID from DM_INFO table"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="RDDS ENV PAIR"
   AND di.info_name=senvpair
  DETAIL
   isrctgtmapid = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc =
  "Inserting the Source-Target Mapping ID since it did not exist in DM_INFO table"
  CALL disp_msg(" ",dm_err->logfile,0)
  INSERT  FROM dm_info di
   SET di.info_domain = "RDDS ENV PAIR", di.info_name = senvpair, di.info_number = seq(
     dm_clinical_seq,nextval),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  IF (check_error("Can not load RDDS 'RDDS ENV PAIR' DM_INFO row") != 0)
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET dm_err->err_ind = 1
   GO TO exit_program
  ELSE
   COMMIT
   SELECT INTO "NL:"
    di.info_number
    FROM dm_info di
    WHERE di.info_domain="RDDS ENV PAIR"
     AND di.info_name=senvpair
    DETAIL
     isrctgtmapid = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 SET ssrctgtmapid = trim(cnvtstring(isrctgtmapid,20,0),3)
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("sSrcTgtMapId = ",ssrctgtmapid))
 ENDIF
 SET dm_err->eproc = "Get db_link information"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  FROM dm_env_reltn der
  WHERE der.child_env_id=itgtenvid
   AND der.relationship_type="REFERENCE MERGE"
   AND der.parent_env_id=isrcenvid
  DETAIL
   sdb_link = der.post_link_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (curqual > 0
  AND sdb_link <= " ")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to find valid merge link."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Obtaining Mock Env ID, if it exists"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET imockenvid = drmmi_get_mock_id(itgtenvid)
 IF (imockenvid < 0.0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  IF (itgtenvid != imockenvid)
   SET drcsf_mock_ind = 1
   SET itgtenvid = imockenvid
   SET stgtenvid = cnvtstring(imockenvid,20,0)
  ENDIF
 ENDIF
 IF (drcsf_mock_ind=1)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="RDDS REPLICATE INFO"
    AND di.info_name="DOMAIN REPLICATE SOURCE"
    AND di.info_number=itgtenvid
   DETAIL
    drcsf_mock_dt_str = format(cnvtdatetimerdb(di.updt_dt_tm,1),"DD-MM-YYYY HH:MM:SS;;D")
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ELSEIF (curqual=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg =
   "Invalid configuration detected.  Domain is set up as MOCK but could not find replicate information."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 SET dm_err->eproc = "Determine if Full Circle is set-up"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  FROM dm_env_reltn der
  WHERE der.child_env_id=itgtenvid
   AND der.relationship_type="RDDS MOVER CHANGES NOT LOGGED"
   AND der.parent_env_id=isrcenvid
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc = "Full Circle is not set-up"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET ifullcircleind = 0
 ELSE
  SET dm_err->eproc = "Full Circle is set-up"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET ifullcircleind = 1
 ENDIF
 SET dm_err->eproc = "Querying dm_info for cutover by context setting"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name="CUTOVER BY CONTEXT"
  DETAIL
   drcxf_ctx_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag > 1))
  CALL echo(concat("Cutover by context indicator:",trim(cnvtstring(drcxf_ctx_ind))))
 ENDIF
 SET dm_err->eproc = "Creating the XLAT_TO and XLAT_FROM functions"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET ssql = concat(" create or replace FUNCTION xlat_from_",ssrctgtmapid,"(",char(10),
  "  i_table_name IN dm_merge_translate.table_name%type, ",
  char(10),"  i_from_value IN dm_merge_translate.from_value%type, ",char(10),
  "  i_exception_flg IN dm_columns_doc_local.exception_flg%type, ",char(10),
  "  i_context_name IN dm_refchg_xlat_ctxt_r.context_name%type default 'NOT SET') RETURN number is ",
  char(10),"  v_return_val number := -1.5; ",char(10),"  v_cnt number := 0; ",
  char(10),"  v_status_flag number := 0; ",char(10),
  "  v_context_name dm_refchg_xlat_ctxt_r.context_name%type;",char(10),
  "  FUNCTION reverse_xlat return number is ",char(10),
  "                        v_reverse_return_val number; ",char(10),
  "                        v_reverse_status_flg number; ")
 IF (ifullcircleind=0)
  SET ssql = concat(ssql,char(10),"  begin ",char(10),"    return(-1.5);",
   char(10),"  end reverse_xlat; ")
 ELSE
  SET ssql = concat(ssql,char(10),"  begin ",char(10),
   "    if (i_table_name in ('PRSNL','PERSON')) then ",
   char(10),"      select from_value, nvl(dmt.status_flg,0) ",char(10),
   "               into v_reverse_return_val, v_reverse_status_flg ",char(10),
   "        from dm_merge_translate",sdb_link," dmt ",char(10),
   "       where to_value = i_from_value ",
   char(10),"         and table_name in ('PRSNL','PERSON') ",char(10),"         and env_source_id = ",
   stgtenvid,
   char(10),"         and env_target_id = ",ssrcenvid,char(10))
  IF (drcsf_mock_ind=1)
   SET ssql = concat(ssql,"         and updt_dt_tm <= to_date('",drcsf_mock_dt_str,
    "','DD-MM-YYYY HH24:MI:SS')",char(10))
  ENDIF
  SET ssql = concat(ssql,"         and rownum = 1; ",char(10),
   "            /* This is added in case there are rows with the same to_value or one exists for both PRSNL ",
   char(10),
   "                and PERSON. This shouldn't happen but... */ ",char(10),"    else ",char(10),
   "      select from_value, nvl(dmt.status_flg,0) ",
   char(10),"              into v_reverse_return_val, v_reverse_status_flg ",char(10),
   "        from dm_merge_translate",sdb_link,
   " dmt ",char(10),"       where to_value = i_from_value ",char(10),
   "         and table_name = i_table_name ",
   char(10),"         and env_source_id = ",stgtenvid,char(10),"         and env_target_id = ",
   ssrcenvid,char(10))
  IF (drcsf_mock_ind=1)
   SET ssql = concat(ssql,"         and updt_dt_tm <= to_date('",drcsf_mock_dt_str,
    "','DD-MM-YYYY HH24:MI:SS')",char(10))
  ENDIF
  SET ssql = concat(ssql,"         and rownum = 1; ",char(10),"    end if; ",char(10),
   "    /* See if the translation is invalid */ ",char(10),
   "    if (i_table_name in ('PRSNL','PERSON')) then ",char(10),
   "      select count(*) into v_cnt from dm_refchg_invalid_xlat ",
   char(10),"       where parent_entity_name in ('PRSNL','PERSON') ",char(10),
   "         and parent_entity_id = v_reverse_return_val; ",char(10),
   "    else ",char(10),"      select count(*) into v_cnt from dm_refchg_invalid_xlat ",char(10),
   "       where parent_entity_name = i_table_name ",
   char(10),"         and parent_entity_id = v_reverse_return_val; ",char(10),"    end if; ",char(10),
   "    if (v_cnt > 0) then ",char(10),"      /* Translation is invalid. Send back a -1.6. */ ",char(
    10),"      v_reverse_return_val := -1.6; ",
   char(10))
  IF (drcxf_ctx_ind=0)
   SET ssql = concat(ssql,"    else ",char(10),"      -- Cache this xlat if the flag is under 100 ",
    char(10),
    "      if (v_reverse_status_flg < 100) then ",char(10),"         begin ",char(10),
    "            rdds_xlat.put_cache_item(i_table_name,i_from_value,v_reverse_return_val); ",
    char(10),"         exception ",char(10),
    "           /* Don't fail if an error occurred in the cache routine */",char(10),
    "           when others then ",char(10),"           null; ",char(10),"         end; ",
    char(10),"      end if; ",char(10))
  ENDIF
  SET ssql = concat(ssql,"    end if; ",char(10),"   return(v_reverse_return_val); ",char(10),
   "   exception ",char(10),"    when no_data_found then ",char(10),"    return(-1.5); ",
   char(10),"  end reverse_xlat; ")
 ENDIF
 SET ssql = concat(ssql,char(10),"  begin ",char(10),
  "    if (i_exception_flg = 1 or nvl(i_from_value,0) <= 0 ",
  char(10),"      or i_table_name = 'RDDS:MOVE AS IS' ",char(10),
  "      or (i_table_name = 'APPLICATION_TASK' and i_from_value IN (4200000,4200001))) then ",char(10
   ),
  "    /* if the table's root_entity_att column has an exception_flg = 1 then return the value coming in */ ",
  char(10),"      return(i_from_value); ",char(10),"    else ",
  char(10))
 IF (drcxf_ctx_ind=1)
  SET ssql = concat(ssql,"    if i_context_name = 'NOT SET' then ",char(10),
   "      select nvl(sys_context('CERNER','RDDS_R_CTXT'),'NOT SET') into v_context_name from dual;",
   char(10),
   "    else ",char(10),"      v_context_name := i_context_name;",char(10),"    end if;",
   char(10))
 ENDIF
 IF (drcxf_ctx_ind=0)
  SET ssql = concat(ssql,"      if (NVL(SYS_CONTEXT('CERNER','MVR_DEL_LOOKUP'),'NO') != 'YES') then ",
   char(10))
 ENDIF
 SET ssql = concat(ssql,"    /* See if the from_value is deleted (invalid) in the Source */  ",char(
   10),"        if (i_table_name in ('PRSNL','PERSON')) then ",char(10),
  "          select count(*) into v_cnt from dm_refchg_invalid_xlat",sdb_link," dmt",char(10),
  "          where parent_entity_name in ('PRSNL','PERSON') ",
  char(10),"            and parent_entity_id = i_from_value; ",char(10),"        else ",char(10),
  "          select count(*) into v_cnt from dm_refchg_invalid_xlat",sdb_link," dmt",char(10),
  "          where parent_entity_name = i_table_name ",
  char(10),"            and parent_entity_id = i_from_value; ",char(10),"        end if; ",char(10),
  "        if (v_cnt > 0) then ",char(10))
 IF (drcxf_ctx_ind=1)
  SET ssql = concat(ssql,
   "           if (NVL(SYS_CONTEXT('CERNER','MVR_DEL_LOOKUP'),'NO') = 'YES') then ",char(10),
   "              v_context_name := 'NOT SET';",char(10),
   "           else",char(10),"              return (-1.4); ",char(10),"           end if;",
   char(10))
 ELSE
  SET ssql = concat(ssql,"           return (-1.4); ",char(10))
 ENDIF
 SET ssql = concat(ssql,"        end if; ",char(10))
 IF (drcxf_ctx_ind=0)
  SET ssql = concat(ssql,"      end if; ",char(10))
 ENDIF
 SET ssql = concat(ssql,"      /* If we get here then the Source from_value is not invalid */",char(
   10),"      /* See if the translation is in the cache */ ",char(10),
  "      begin ",char(10),
  "        v_return_val :=  rdds_xlat.get_cache_item(i_table_name,i_from_value); ",char(10),
  "        if (v_return_val > 0) then ",
  char(10))
 IF (drdm_debug_row_ind=1)
  SET ssql = concat(ssql,
   "          begin DM2_CONTEXT_CONTROL('RDDS_XLAT_CACHE_TEST',i_table_name||' '||i_from_value||' '||v_return_val); end;",
   char(10))
 ENDIF
 SET ssql = concat(ssql,char(10),"          return(v_return_val); ",char(10),"        end if; ",
  char(10),"      exception ",char(10),
  "        /* Don't fail if an error occurred in the cache routine */ ",char(10),
  "        when others then ",char(10),"        null; ",char(10),"      end; ",
  char(10),"    end if ; ",char(10),"    if (v_return_val = -1.5) then ",char(10),
  "    /* Translation not in the cache.  Look for it in DMT. */ ",char(10),"      begin ",char(10),
  "        if (i_table_name in ('PRSNL','PERSON')) then ",
  char(10),"          select to_value, nvl(dmt.status_flg,0) ",char(10),
  "                  into v_return_val, v_status_flag ",char(10),
  "          from dm_merge_translate dmt ",char(10),"          where from_value = i_from_value ",char
  (10),"         /* The below appears to perform well even for non-PRSNL/PERSON queries */ ",
  char(10),"            and table_name in ('PRSNL','PERSON') ",char(10),
  "            and env_source_id = ",ssrcenvid,
  char(10),"            and env_target_id = ",stgtenvid,char(10))
 IF (drcxf_ctx_ind=1)
  SET ssql = concat(ssql,"            and (NOT EXISTS(select 'x' from dm_refchg_xlat_ctxt_r drxcr ",
   char(10),
   "                            where drxcr.table_name = 'PRSNL' and drxcr.context_name != v_context_name",
   char(10),
   "                            and drxcr.from_value = dmt.from_value) or ",char(10),
   "                 EXISTS(select 'x' from dm_refchg_xlat_ctxt_r drxcr2",char(10),
   "                        where drxcr2.table_name = 'PRSNL' and drxcr2.context_name = v_context_name",
   char(10),"                        and drxcr2.from_value = dmt.from_value) or ",char(10),
   "                 v_context_name = 'NOT SET')",char(10))
 ENDIF
 SET ssql = concat(ssql,"            and rownum = 1;   ",char(10),
  "         /* This is added in case there are rows for both PRSNL and PERSON. This shouldn't happen but... */ ",
  char(10),
  "        else ",char(10),"          select to_value, nvl(dmt.status_flg,0) ",char(10),
  "                  into  v_return_val, v_status_flag ",
  char(10),"          from dm_merge_translate dmt ",char(10),
  "          where from_value = i_from_value ",char(10),
  "         /* The below appears to perform well even for non-PRSNL/PERSON queries */ ",char(10),
  "            and table_name = i_table_name ",char(10))
 IF (drcxf_ctx_ind=1)
  SET ssql = concat(ssql,"            and (NOT EXISTS(select 'x' from dm_refchg_xlat_ctxt_r drxcr ",
   char(10),
   "                            where drxcr.table_name = dmt.table_name and drxcr.context_name != v_context_name",
   char(10),
   "                            and drxcr.from_value = dmt.from_value) or ",char(10),
   "                 EXISTS(select 'x' from dm_refchg_xlat_ctxt_r drxcr2",char(10),
   "                        where drxcr2.table_name = dmt.table_name and drxcr2.context_name = v_context_name",
   char(10),"                        and drxcr2.from_value = dmt.from_value) or",char(10),
   "                 v_context_name = 'NOT SET')",char(10))
 ENDIF
 SET ssql = concat(ssql,"            and env_source_id = ",ssrcenvid,char(10),
  "            and env_target_id = ",
  stgtenvid,";",char(10),"         end if; ",char(10),
  "         /* Make sure xlat isn't invalid */ ",char(10),
  "         if (i_table_name in ('PRSNL','PERSON')) then ",char(10),
  "           select count(*) into v_cnt from dm_refchg_invalid_xlat ",
  char(10),"           where parent_entity_name in ('PRSNL','PERSON') ",char(10),
  "             and parent_entity_id = v_return_val; ",char(10),
  "         else ",char(10),"           select count(*) into v_cnt from dm_refchg_invalid_xlat ",char
  (10),"           where parent_entity_name = i_table_name ",
  char(10),"             and parent_entity_id = v_return_val; ",char(10),"         end if; ",char(10),
  "         if (v_cnt > 0) then ",char(10),
  "          /* The translation that we found is invalid.  */ ",char(10),
  "           v_return_val := -1.6; ",
  char(10),"         end if; ",char(10))
 IF (drcxf_ctx_ind=0)
  SET ssql = concat(ssql,"         if (v_return_val > 0) then ",char(10),
   "            -- Cache this xlat if the flag is under 100",char(10),
   "            if (v_status_flag < 100) then ",char(10),"               begin ",char(10),
   "                  rdds_xlat.put_cache_item(i_table_name,i_from_value,v_return_val); ",
   char(10),"               exception ",char(10),
   "                  /* Don't fail if an error occurred in the cache routine */ ",char(10),
   "                  when others then ",char(10),"                     null; ",char(10),
   "               end; ",
   char(10),"            end if; ",char(10),"         end if; ",char(10))
 ENDIF
 SET ssql = concat(ssql,"      exception ",char(10),"        when no_data_found then ",char(10),
  "        /* Didn't find a translation.  Look for the reverse translation. */ ",char(10),
  "        v_return_val := reverse_xlat; ",char(10),"      end; ",
  char(10),"    end if; ",char(10),"    return(v_return_val); ",char(10),
  "end xlat_from_",ssrctgtmapid,";")
 CALL parser(concat("rdb asis (^",ssql,"^) go"))
 SET ssql = concat("create or replace FUNCTION xlat_to_",ssrctgtmapid,"  (",char(10),
  "  i_table_name IN dm_merge_translate.table_name%type, ",
  char(10),"  i_to_value IN dm_merge_translate.to_value%type, ",char(10),
  "  i_exception_flg dm_columns_doc_local.exception_flg%type, ",char(10),
  "  i_passive_ind IN number default 0 ) RETURN number is  ",char(10),
  "  v_return_val number := -1.5; ",char(10),"  v_cnt number := 0; ",
  char(10),"  FUNCTION reverse_xlat return number is ",char(10),
  "                        v_reverse_return_val number; ")
 IF (ifullcircleind=0)
  SET ssql = concat(ssql,char(10),"  begin ",char(10),"    return(-1.5);",
   char(10),"  end reverse_xlat; ")
 ELSE
  SET ssql = concat(ssql,char(10),"  begin ",char(10),
   "    if (i_table_name in ('PRSNL','PERSON')) then ",
   char(10),"      select to_value into v_reverse_return_val ",char(10),
   "        from dm_merge_translate",sdb_link,
   " dmt ",char(10),"       where from_value = i_to_value ",char(10),
   "         and table_name in ('PRSNL','PERSON') ",
   char(10),"         and env_source_id = ",stgtenvid,char(10),"         and env_target_id = ",
   ssrcenvid,char(10))
  IF (drcsf_mock_ind=1)
   SET ssql = concat(ssql,"         and updt_dt_tm <= to_date('",drcsf_mock_dt_str,
    "','DD-MM-YYYY HH24:MI:SS')",char(10))
  ENDIF
  SET ssql = concat(ssql,"         and rownum = 1; ",char(10),
   "            /* This is added in case there are rows with the same to_value or one exists for both PRSNL ",
   char(10),
   "                and PERSON. This shouldn't happen but... */ ",char(10),"    else ",char(10),
   "      select to_value into v_reverse_return_val ",
   char(10),"        from dm_merge_translate",sdb_link," dmt ",char(10),
   "       where from_value = i_to_value ",char(10),"         and table_name = i_table_name ",char(10
    ),"         and env_source_id = ",
   stgtenvid,char(10),"         and env_target_id = ",ssrcenvid,char(10))
  IF (drcsf_mock_ind=1)
   SET ssql = concat(ssql,"         and updt_dt_tm <= to_date('",drcsf_mock_dt_str,
    "','DD-MM-YYYY HH24:MI:SS')",char(10))
  ENDIF
  SET ssql = concat(ssql,"         and rownum = 1; ",char(10),"    end if; ",char(10),
   "    /* See if the to_value is deleted (invalid) in the Source */  ",char(10),
   "    if (i_passive_ind != 1 and NVL(SYS_CONTEXT('CERNER','MVR_DEL_LOOKUP'),'NO') != 'YES') then ",
   char(10),"      if (i_table_name in ('PRSNL','PERSON')) then ",
   char(10),"        select count(*) into v_cnt from dm_refchg_invalid_xlat",sdb_link," dmt",char(10),
   "        where parent_entity_name in ('PRSNL','PERSON') ",char(10),
   "          and parent_entity_id = v_reverse_return_val; ",char(10),"      else ",
   char(10),"        select count(*) into v_cnt from dm_refchg_invalid_xlat",sdb_link," dmt",char(10),
   "        where parent_entity_name = i_table_name ",char(10),
   "          and parent_entity_id = v_reverse_return_val; ",char(10),"      end if; ",
   char(10),"      if (v_cnt > 0) then ",char(10),"        v_reverse_return_val := -1.4; ",char(10),
   "      end if; ",char(10),"    end if; ",char(10),"    return(v_reverse_return_val); ",
   char(10),"    exception ",char(10),"     when no_data_found then ",char(10),
   "     return(-1.5); ",char(10),"  end reverse_xlat; ")
 ENDIF
 SET ssql = concat(ssql,char(10),"  begin ",char(10),
  "    if (i_exception_flg = 1 or nvl(i_to_value,0) <= 0 ",
  char(10),"      or i_table_name = 'RDDS:MOVE AS IS'",char(10),
  "      or (i_table_name = 'APPLICATION_TASK' and i_to_value IN (4200000,4200001))) then ",char(10),
  "      /* if the table's root_entity_att column has an exception_flg = 1 then return the value coming in */",
  char(10),"      return(i_to_value); ",char(10),"    else ",
  char(10),
  "      /* We don't check for the to_value being invalid since this shouldn't happen when this is called */",
  char(10),"      /* Translation not in the cache.  Look for it in DMT. */ ",char(10),
  "      if (i_passive_ind != 1) then ",char(10),
  "        /* See if the to_value is deleted (invalid) in the Target */  ",char(10),
  "        if (i_table_name in ('PRSNL','PERSON')) then ",
  char(10),"          select count(*) into v_cnt from dm_refchg_invalid_xlat dmt ",char(10),
  "          where parent_entity_name in ('PRSNL','PERSON') ",char(10),
  "            and parent_entity_id = i_to_value; ",char(10),"        else ",char(10),
  "          select count(*) into v_cnt from dm_refchg_invalid_xlat dmt ",
  char(10),"          where parent_entity_name = i_table_name ",char(10),
  "            and parent_entity_id = i_to_value; ",char(10),
  "        end if; ",char(10),"        if (v_cnt > 0) then ",char(10),"          return (-1.6); ",
  char(10),"        end if; ",char(10),"      end if; ",char(10),
  "      begin ",char(10),"        if (i_table_name in ('PRSNL','PERSON')) then ",char(10),
  "          select from_value into v_return_val ",
  char(10),"            from dm_merge_translate dmt ",char(10),
  "           where to_value = i_to_value ",char(10),
  "             and table_name in ('PRSNL','PERSON') ",char(10),"             and env_source_id = ",
  ssrcenvid,char(10),
  "             and env_target_id = ",stgtenvid,char(10),"             and rownum = 1; ",char(10),
  "             /* This is added in case there are rows for both PRSNL and PERSON. This shouldn't happen but... */ ",
  char(10),"        else ",char(10),"          select from_value into v_return_val ",
  char(10),"            from dm_merge_translate dmt ",char(10),
  "           where to_value = i_to_value ",char(10),
  "             and table_name = i_table_name ",char(10),"             and env_source_id = ",
  ssrcenvid,char(10),
  "             and env_target_id = ",stgtenvid,char(10),"             and rownum = 1; ",char(10),
  "             /* This is added in case there are two rows for the to_value.  This shouldn't happen but... */ ",
  char(10),"        end if; ",char(10),
  "        if (i_passive_ind != 1 and NVL(SYS_CONTEXT('CERNER','MVR_DEL_LOOKUP'),'NO') != 'YES') then ",
  char(10),"          /* Make sure xlat isnt invalid */ ",char(10),
  "          if (i_table_name in ('PRSNL','PERSON')) then ",char(10),
  "            select count(*) into v_cnt from dm_refchg_invalid_xlat",sdb_link," dmt",char(10),
  "             where parent_entity_name in ('PRSNL','PERSON') ",
  char(10),"               and parent_entity_id = v_return_val; ",char(10),"          else ",char(10),
  "            select count(*) into v_cnt from dm_refchg_invalid_xlat",sdb_link," dmt",char(10),
  "             where parent_entity_name = i_table_name ",
  char(10),"               and parent_entity_id = v_return_val; ",char(10),"          end if; ",char(
   10),
  "          if (v_cnt > 0) then ",char(10),
  "            /* Translation is invalid. Send back a -1.4 (invalid in source). */ ",char(10),
  "            v_return_val := -1.4; ",
  char(10),"          end if; ",char(10),"        end if; ",char(10),
  "        exception ",char(10),"        when no_data_found then ",char(10),
  "         /* Didn't find a translation.  Look for the reverse translation. */",
  char(10),"         v_return_val := reverse_xlat; ",char(10),"      end; ",char(10),
  "  end if; ",char(10),"  return(v_return_val); ",char(10),"end xlat_to_",
  ssrctgtmapid,";")
 CALL parser(concat("rdb asis (^",ssql,"^) go"))
 SELECT INTO "NL:"
  FROM user_objects u
  WHERE ((u.object_name=concat("XLAT_TO_",ssrctgtmapid)) OR (u.object_name=concat("XLAT_FROM_",
   ssrctgtmapid)))
   AND u.object_type="FUNCTION"
   AND status="VALID"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual != 2)
  SET dm_err->eproc = "One or both of the functions are invalid."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ELSE
  SET dm_err->eproc = "Both functions were created successfully."
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
#exit_program
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  CALL disp_msg("Errors occurred during execution, check logfile for details",dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "...Ending dm_rmc_create_xlat_function"
 CALL final_disp_msg("dm_rmc_create_xlat_function")
END GO
