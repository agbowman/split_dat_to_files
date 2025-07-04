CREATE PROGRAM dm_rmc_create_clobxml_function:dba
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
 DECLARE drcxf_logfile_prefix = vc WITH protect, constant("dm_rmc_clbxml_fn")
 DECLARE drcxf_target = f8 WITH protect, noconstant(0.0)
 DECLARE drcxf_source = f8 WITH protect, noconstant(0.0)
 DECLARE drcxf_mapping = f8 WITH protect, noconstant(0.0)
 DECLARE drcxf_envpair = vc WITH protect, noconstant("")
 DECLARE drcxf_sql = vc WITH protect, noconstant("")
 DECLARE drcxf_xlatf_name = vc WITH protect, noconstant("")
 IF (check_logfile(drcxf_logfile_prefix,".log","DM_RMC_CRE8_CLBXML_FCN Logfile")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning DM_RMC_CREATE_CLOBXML_FUNCTION"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Validating the request structure...."
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((validate(drccf_request->source_env_id,- (1.0))=- (1.0)))
  FREE RECORD drccf_request
  RECORD drccf_request(
    1 source_env_id = f8
    1 target_env_id = f8
  )
  IF (((reflect(parameter(1,0)) != "F*"
   AND reflect(parameter(1,0)) != "I*") OR (reflect(parameter(2,0)) != "F*"
   AND reflect(parameter(2,0)) != "I*")) )
   SET dm_err->err_ind = 1
   SET dm_err->emsg =
   "Expected syntax: dm_rmc_create_clobxml_function <source_env_id>,<target_env_id>"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ELSE
   SET drccf_request->source_env_id =  $1
   SET drccf_request->target_env_id =  $2
  ENDIF
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET drcxf_source = drccf_request->source_env_id
 SET drcxf_target = drccf_request->target_env_id
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("drcxf_source = ",drcxf_source))
  CALL echo(build("drcxf_target = ",drcxf_target))
  CALL echo("The following is the Request structure:")
  CALL echorecord(drccf_request)
 ENDIF
 SET drcxf_envpair = concat(trim(cnvtstring(drcxf_source,20)),"::",trim(cnvtstring(drcxf_target,20)))
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("drcxf_envpair = ",drcxf_envpair))
 ENDIF
 SET dm_err->eproc = "Obtaining Source-Target Mapping from DM_INFO table"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="RDDS ENV PAIR"
   AND di.info_name=drcxf_envpair
  DETAIL
   drcxf_mapping = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "RDDS ENV PAIR mapping number not found, ensure XLAT functions exist prior to creating XLAT_XML functions."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET drcxf_xlatf_name = concat("XLAT_FROM_",trim(cnvtstring(drcxf_mapping,20)))
 SELECT INTO "nl:"
  FROM user_objects o
  WHERE object_name IN (drcxf_xlatf_name, "RDDS_META_DATA", "EVALUATE_PE_NAME", "RDDS_XLAT")
   AND status="VALID"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (curqual < 6)
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "Missing valid objects the RDDS_XLAT_XML function is dependant on, please ensure dependencies are created."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET drcxf_sql = concat("create or replace function rdds_xlat_xml_",trim(cnvtstring(drcxf_mapping,20)
   ),"(i_mode_flag number, i_xml_data XMLtype, ",char(10),
  "i_context_name IN dm_refchg_xlat_ctxt_r.context_name%type default 'NOT SET') return XMLtype is",
  char(10),"  type xlatItem is record (",char(10),"     tab_name varchar2(50)",char(10),
  "    ,col_name varchar2(50)",char(10),"    ,pe_tab_name varchar2(50)",char(10),
  "    ,from_value varchar2(50)",
  char(10),"    ,to_value number",char(10),"  );",char(10),
  "  type xlatSet is table of xlatItem;",char(10),"  xlatList xlatSet;",char(10),
  "  xpath_str varchar2(1000);",
  char(10),"  o_xml_data XMLTYPE;",char(10),"  noxlat_ind number;",char(10),
  "  v_re_name varchar2(30);",char(10),"  v_pe_col varchar2(30);",char(10),"  v_pe_tab varchar2(30);",
  char(10),"  v_xptn_flg number;",char(10),"  v_tab_name varchar2(30);",char(10),
  "  v_noxlat_msg varchar2(4000) := ' ';",char(10),"  v_noxlat_txt varchar2(4000);",char(10),
  "  v_top_col varchar2(30);",
  char(10),"  v_tab_str varchar2(30);",char(10),"begin",char(10),
  "  o_xml_data := i_xml_data;",char(10),"  SELECT",char(10),
  "    extractValue(value(v),'//@DBREF_TABLE_NAME')",
  char(10),"   ,extractValue(value(v), '//@DBREF_COLUMN_NAME')",char(10),
  "   ,extractValue(value(v), '//@DBREF_PARENT_TABLE')",char(10),
  "   ,extractValue(value(v),'//*[@DBREF_TABLE_NAME and @DBREF_COLUMN_NAME]')",char(10),"   ,null",
  char(10),"   -- into tab_name , col_name , pe_tab_name, from_value",
  char(10),"   bulk collect into xlatList",char(10),
  "  FROM table(XMLSequence(o_xml_data.extract('//*[@DBREF_TABLE_NAME]'))) v",char(10),
  "  WHERE 1 = 1;",char(10),"  noxlat_ind := 0;",char(10),"  if xlatList.count>0 then",
  char(10),"    for i in xlatList.first .. xlatList.last loop",char(10),
  "      -- Check for numeric data",char(10),
  "      if rdds_xlat.isnumeric(xlatList(i).from_value) = 1 then",char(10),
  "        if xlatList(i).pe_tab_name is not null then",char(10),"           begin",
  char(10),
  "              v_pe_col := rdds_meta_data.get_parent_entity_col(xlatList(i).tab_name, xlatList(i).col_name);",
  char(10),"           exception when no_data_found then",char(10),
  "              if i_mode_flag in (1,3) then",char(10),
  "                dm2_context_control('CUSTOM_PL_SQL',",char(10),
  "                '<ERROR>NOMV66</ERROR><ERROR_TXT>Invalid table_name/column_name combination ' || ",
  char(10),
  "                 xlatList(i).tab_name ||'.'||  xlatList(i).col_name ||' provided.</ERROR_TXT>');",
  char(10),"                RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",char(10),
  "              else",char(10),"                return(xmltype('<tag>-1</tag>')); ",char(10),
  "              end if;",
  char(10),"           end;",char(10),"           if v_pe_col is not null then",char(10),
  "              v_pe_tab := evaluate_pe_name(xlatList(i).tab_name,xlatList(i).col_name,v_pe_col,xlatList(i).pe_tab_name);",
  char(10),"           else",char(10),"              if i_mode_flag in (1,3) then",
  char(10),"                dm2_context_control('CUSTOM_PL_SQL',",char(10),
  "                '<ERROR>NOMV66</ERROR><ERROR_TXT>Column '||xlatList(i).tab_name||'.'||xlatList(i).col_name||",
  char(10),
  "                   ' is not a parent_entity column.</ERROR_TXT>');",char(10),
  "                RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",char(10),
  "              else",
  char(10),"                return(xmltype('<tag>-1</tag>')); ",char(10),
  "              end if; --i_mode_flag in(1,3)",char(10),
  "           end if; --v_pe_col is not null",char(10),
  "        else --only check root_entity if don't have a pe_tab",char(10),"           begin",
  char(10),
  "              v_re_name := rdds_meta_data.get_root_entity_name(xlatList(i).tab_name, xlatList(i).col_name);",
  char(10),"           exception when no_data_found then",char(10),
  "              if i_mode_flag in (1,3) then",char(10),
  "                dm2_context_control('CUSTOM_PL_SQL',",char(10),
  "                '<ERROR>NOMV66</ERROR><ERROR_TXT>Invalid table_name/column_name combination ' || ",
  char(10),
  "                 xlatList(i).tab_name ||'.'|| xlatList(i).col_name ||' provided.</ERROR_TXT>');",
  char(10),"                RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",char(10),
  "              else",char(10),"                return(xmltype('<tag>-1</tag>')); ",char(10),
  "              end if; --i_mode_flag in (1,3) ",
  char(10),"           end;",char(10),"        end if; --xlatList(i).pe_tab_name is not null",char(10
   ),
  "        --return a nomv for when root_entity or parent_entity doesn't exist.",char(10),
  "        if (rtrim(v_re_name) is null and rtrim(xlatList(i).pe_tab_name) is null) OR",char(10),
  "           (v_pe_tab = 'INVALIDTABLE' and rtrim(xlatList(i).pe_tab_name) is not null) then ",
  char(10),"           if v_pe_tab = 'INVALIDTABLE' then ",char(10),
  "              v_tab_str := 'parent_entity';",char(10),
  "           else",char(10),"              v_tab_str := 'root_entity';",char(10),
  "           end if; --v_pe_tab = 'INVALIDTABLE'",
  char(10),"           if i_mode_flag in (1,3) then",char(10),
  "             dm2_context_control('CUSTOM_PL_SQL',",char(10),
  "             '<ERROR>NOMV66</ERROR><ERROR_TXT>There was no '||v_tab_str||' data for the ' || ",
  char(10),
  "              xlatList(i).tab_name||'.'||xlatList(i).col_name ||' column so a translation could not'||",
  char(10),"              ' be gathered.</ERROR_TXT>');",
  char(10),"             RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",char(10),
  "           else",char(10),
  "             return(xmltype('<tag>-1</tag>')); ",char(10),
  "           end if; --i_mode_flag in (1,3)",char(10),
  "        end if; --(rtrim(v_re_name) is null...",
  char(10),"        --set xlat table_name",char(10),"        if rtrim(v_re_name) is not null then",
  char(10),
  "           v_tab_name := v_re_name; ",char(10),"        elsif rtrim(v_pe_tab) is not null then",
  char(10),"           v_tab_name := v_pe_tab;",
  char(10),"        end if;",char(10),"        --get xlat_col for excptn_flag",char(10),
  "        begin",char(10),"           v_top_col := rdds_meta_data.get_top_level_col(v_tab_name);",
  char(10),"        exception when no_data_found then",
  char(10),"           if i_mode_flag in (1,3) then",char(10),
  "             dm2_context_control('CUSTOM_PL_SQL',",char(10),
  "             '<ERROR>NOMV66</ERROR><ERROR_TXT>Invalid table_name ' || ",char(10),
  "              v_tab_name ||' provided to gather top_level column.</ERROR_TXT>');",char(10),
  "             RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",
  char(10),"           else",char(10),"             return(xmltype('<tag>-1</tag>')); ",char(10),
  "           end if;",char(10),"        end;",char(10),"        if v_top_col is null then",
  char(10),"           if i_mode_flag in (1,3) then",char(10),
  "             dm2_context_control('CUSTOM_PL_SQL',",char(10),
  "             '<ERROR>NOMV66</ERROR><ERROR_TXT>Table '||v_tab_name||",char(10),
  "                ' is not a top-level table.</ERROR_TXT>');",char(10),
  "             RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",
  char(10),"           else",char(10),"             return(xmltype('<tag>-1</tag>')); ",char(10),
  "           end if;",char(10),"        end if; --v_top_COL is null",char(10),"        begin",
  char(10),"           v_xptn_flg := nvl(rdds_meta_data.get_excptn_flag(v_tab_name, v_top_col),0);",
  char(10),"        exception when no_data_found then",char(10),
  "           if i_mode_flag in (1,3) then",char(10),
  "             dm2_context_control('CUSTOM_PL_SQL',",char(10),
  "             '<ERROR>NOMV66</ERROR><ERROR_TXT>Invalid table_name/column_name combination ' || ",
  char(10),"              v_tab_name ||'.'||  v_top_col ||' provided.</ERROR_TXT>');",char(10),
  "             RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",char(10),
  "           else",char(10),"             return(xmltype('<tag>-1</tag>')); ",char(10),
  "           end if;",
  char(10),"        end;",char(10),"        xlatlist(i).to_value := xlat_from_",trim(cnvtstring(
    drcxf_mapping,20)),
  "           (v_tab_name,xlatList(i).from_value,v_xptn_flg,i_context_name);",char(10),
  "        if xlatList(i).to_value > -2 and xlatList(i).to_value < -1 then",char(10),
  "          --use i_mode_flag to determine how to handle the fact that no translation was found",
  char(10),"           if i_mode_flag in (1,3) then",char(10),"              noxlat_ind := 1;",char(
   10),
  "              v_noxlat_txt :=  '<NOXLAT><TABLE_NAME>'||v_tab_name||'</TABLE_NAME><VALUE>'||",char(
   10),
  "              xlatList(i).from_value||'</VALUE><XLAT_RET>'||xlatList(i).to_value||'</XLAT_RET></NOXLAT>';",
  char(10),"              if instr(v_noxlat_msg,v_noxlat_txt) = 0 then",
  char(10),"                 if length(v_noxlat_txt)+length(v_noxlat_msg) < 4000 then",char(10),
  "                    v_noxlat_msg := v_noxlat_msg || v_noxlat_txt;",char(10),
  "                 else",char(10),
  "                    /* Only raise an error if called from the mover */",char(10),
  "                    if i_mode_flag in (1,3) then",
  char(10),"                      dm2_context_control('CUSTOM_PL_SQL', v_noxlat_msg);",char(10),
  "                      RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",char(10),
  "                    else",char(10),"                      return(xmltype('<tag>-1</tag>'));",char(
   10),"                    end if;",
  char(10),"                 end if;",char(10),"                 v_noxlat_msg := trim(v_noxlat_msg);",
  char(10),
  "              end if;",char(10),"           else",char(10),
  "              return(xmltype('<tag>-1</tag>'));",
  char(10),"           end if; --i_mode_flag in (1,3)",char(10),"        else",char(10),
  ^           -- Construct xpath str '//*[@DBREF_TABLE_NAME="CODE_VALUE"]/text()'^,char(10),
  ^           xpath_str := '//*[@DBREF_TABLE_NAME="' || xlatList(i).tab_name || '"';^,char(10),
  "           if xlatList(i).col_name > ' ' then",
  char(10),"             xpath_str := xpath_str || ",char(10),
  ^                          ' and @DBREF_COLUMN_NAME="' || xlatList(i).col_name || '"';^,char(10),
  "           end if;",char(10),"           if xlatList(i).pe_tab_name > ' ' then",char(10),
  "             xpath_str := xpath_str || ",
  char(10),
  ^                          ' and @DBREF_PARENT_TABLE="' || xlatList(i).pe_tab_name || '"';^,char(10
   ),"           end if;        ",char(10),
  ^           xpath_str := xpath_str || ' and text()="' || xlatList(i).from_value || '"]' ;^,char(10),
  "           -- Update xml, add a 'TO' to the front of to_values so 123 from_value doesn't match on 123 to_value ",
  char(10),
  "           select updatexml(o_xml_data, xpath_str||'/text()', 'TO'||to_char(xlatList(i).to_value)) into o_xml_data",
  char(10),"           from dual;",char(10),
  "         end if; --xlatList(i).to_value > -2 and xlatList(i).to_value < -1",char(10),
  "      end if; --rdds_xlat.isnumeric(xlatList(i).from_value)",char(10),"      v_re_name := null;  ",
  char(10),"      v_pe_col := null;   ",
  char(10),"      v_pe_tab := null;   ",char(10),"      v_xptn_flg := null; ",char(10),
  "      v_tab_name := null; ",char(10),"      v_top_col := null;  ",char(10),
  "      v_tab_str := null;  ",
  char(10),"    end loop;",char(10),"    if noxlat_ind = 0 then",char(10),
  "       for i in xlatList.first .. xlatList.last loop",char(10),"         -- Check if to_value set",
  char(10),"         if xlatList(i).to_value is not null then",
  char(10),^           -- Construct xpath str '//*[@DBREF_TABLE_NAME="CODE_VALUE"]/text()'^,char(10),
  ^           xpath_str := '//*[@DBREF_TABLE_NAME="' || xlatList(i).tab_name || '"';^,char(10),
  "           if xlatList(i).col_name > ' ' then",char(10),"             xpath_str := xpath_str || ",
  char(10),^                          ' and @DBREF_COLUMN_NAME="' || xlatList(i).col_name || '"';^,
  char(10),"           end if;",char(10),"           if xlatList(i).pe_tab_name > ' ' then",char(10),
  "             xpath_str := xpath_str || ",char(10),
  ^                          ' and @DBREF_PARENT_TABLE="' || xlatList(i).pe_tab_name || '"';^,char(10
   ),"           end if;        ",
  char(10),"           --remove the 'TO' ",char(10),
  ^           xpath_str := xpath_str || ' and text()="' || 'TO'|| to_char(xlatList(i).to_value) || '"]' ;^,
  char(10),
  "           -- Update xml",char(10),
  "           select updatexml(o_xml_data, xpath_str||'/text()', to_char(xlatList(i).to_value)) into o_xml_data",
  char(10),"           from dual;",
  char(10),"         end if; ",char(10),"       end loop;    ",char(10),
  "     else",char(10),"       /* Only raise an error if called from the mover */",char(10),
  "       if i_mode_flag in (1,3) then",
  char(10),"         dm2_context_control('CUSTOM_PL_SQL', v_noxlat_msg);",char(10),
  "         RAISE_APPLICATION_ERROR(-20210 ,'<ERR>CUSTOM_PL_SQL</ERR>');",char(10),
  "       else",char(10),"         return(xmltype('<tag>-1</tag>'));",char(10),"       end if;",
  char(10),"     end if; --noxlat_ind = 0",char(10),"  end if; --xlatList.count>0",char(10),
  "     return(o_xml_data);",char(10),"end;")
 CALL parser(concat("rdb asis (^",drcxf_sql,"^) go"))
 SELECT INTO "NL:"
  FROM user_objects u
  WHERE u.object_name=concat("RDDS_XLAT_XML_",trim(cnvtstring(drcxf_mapping,20)))
   AND u.object_type="FUNCTION"
   AND status="VALID"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (curqual != 1)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "The RDDS_XLAT_XML function is invalid."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ELSE
  SET dm_err->eproc = "The RDDS_XLAT_XML function was created successfully."
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SET dm_err->eproc = "Creating the RDDS_XML_CLOB_WRP function"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET drcxf_sql = concat("create or replace function rdds_xml_clob_wrp_",trim(cnvtstring(drcxf_mapping,
    20)),"(i_mode_flag number, i_clob_xml CLOB, ",char(10),
  "i_context_name IN dm_refchg_xlat_ctxt_r.context_name%type default 'NOT SET') return CLOB is",
  char(10),"   i_xml_info sys.XMLTYPE;",char(10),"   i_ret_clob CLOB;",char(10),
  "begin",char(10),"   i_xml_info := sys.xmltype(i_clob_xml);",char(10),"   select rdds_xlat_xml_",
  trim(cnvtstring(drcxf_mapping,20)),
  "(i_mode_flag, i_xml_info, i_context_name) into i_xml_info from dual;",char(10),
  "   i_ret_clob := i_xml_info.getClobVal();",char(10),
  "   return(i_ret_clob);",char(10),"end;")
 CALL parser(concat("rdb asis (^",drcxf_sql,"^) go"))
 SELECT INTO "NL:"
  FROM user_objects u
  WHERE u.object_name=concat("RDDS_XML_CLOB_WRP_",trim(cnvtstring(drcxf_mapping,20)))
   AND u.object_type="FUNCTION"
   AND status="VALID"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "The RDDS_XML_CLOB_WRP function is invalid."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ELSE
  SET dm_err->eproc = "The RDDS_XML_CLOB_WRP function was created successfully."
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
#exit_program
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  CALL disp_msg("Errors occurred during execution, check logfile for details",dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "...Ending dm_rmc_create_clobxml_function"
 CALL final_disp_msg("dm_rmc_create_clobxml_function")
END GO
