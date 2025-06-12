CREATE PROGRAM dm_rmc_create_all_tables:dba
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
 DECLARE dm2_asynch_pre(i_appid=i4,i_taskid=i4,i_reqid=i4,o_happ=i4(ref),o_htask=i4(ref),
  o_hreq=i4(ref)) = i4
 SUBROUTINE dm2_asynch_pre(i_appid,i_taskid,i_reqid,o_happ,o_htask,o_hreq)
   DECLARE s_iret = i2
   SET o_happ = uar_crmgetapphandle()
   IF (o_happ=0)
    SET s_iret = uar_crmbeginapp(i_appid,o_happ)
    CALL echo(s_iret)
    IF (s_iret=0)
     CALL echo(build("Application Handle is: ",o_happ))
     SET s_iret = uar_crmbegintask(o_happ,i_taskid,o_htask)
     IF (((s_iret=0) OR (o_htask != 0)) )
      CALL echo(build("Task Handle is: ",o_htask))
      SET s_iret = uar_crmbeginreq(o_htask,0,i_reqid,o_hreq)
      CALL echo(build("o_hReq = ",o_hreq))
      IF (((s_iret=0) OR (o_hreq != 0)) )
       CALL echo(build("Request Handle is: ",o_hreq))
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (o_hreq > 0)
    SET s_iret = uar_crmendreq(o_hreq)
   ENDIF
   IF (o_htask > 0)
    SET s_iret = uar_crmendtask(o_htask)
   ENDIF
   IF (o_happ > 0)
    SET s_iret = uar_crmendapp(o_happ)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE dm2_asynch_post(i_happ=i4,i_htask=i4,i_hreq=i4) = i4
 SUBROUTINE dm2_asynch_post(i_happ,i_htask,i_hreq)
   DECLARE s_iret = i2
   IF (i_hreq > 0)
    SET s_iret = uar_crmendreq(i_hreq)
   ENDIF
   IF (i_htask > 0)
    SET s_iret = uar_crmendtask(i_htask)
   ENDIF
   IF (i_happ > 0)
    SET s_iret = uar_crmendapp(i_happ)
   ENDIF
   RETURN(1)
 END ;Subroutine
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
 DECLARE check_$r_table(i_table_name=vc,i_r_table_name=vc,i_table_suffix=vc,io_reply=vc(ref)) = vc
 IF ((validate(drtc_request->table_suffix,- (1))=- (1)))
  FREE RECORD drtc_request
  RECORD drtc_request(
    1 table_name = vc
    1 r_table_name = vc
    1 table_suffix = vc
  )
  FREE RECORD drtc_reply
  RECORD drtc_reply(
    1 r_table_ind = i2
    1 r_table_def_ind = i2
    1 r_xpk_ind = i2
    1 r_rmc_trig_ind = i2
  )
 ENDIF
 SUBROUTINE check_$r_table(i_table_name,i_r_table_name,i_table_suffix,io_reply)
   DECLARE crt_lock_check = i2 WITH protect, noconstant(1)
   WHILE (crt_lock_check > 0)
     SET crt_lock_check = 0
     SELECT INTO "nl:"
      FROM gv$session g
      WHERE g.audsid IN (
      (SELECT
       cnvtreal(info_char)
       FROM dm_info d
       WHERE d.info_domain="RDDS $R CREATION"
        AND d.info_name=cnvtupper(i_r_table_name)
        AND d.info_char != currdbhandle))
      DETAIL
       crt_lock_check = 1
      WITH nocounter
     ;end select
     IF (check_error(concat("Checking if table ",i_r_table_name,
       " is in the process of being created by another session")) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN("F")
     ENDIF
     IF (crt_lock_check > 0)
      CALL pause(10)
     ENDIF
   ENDWHILE
   SELECT INTO "NL:"
    ut.table_name
    FROM user_tables ut
    WHERE ut.table_name=i_r_table_name
    WITH nocounter
   ;end select
   IF (curqual=1)
    SET io_reply->r_table_ind = 1
   ENDIF
   IF (check_error("Verify $R table exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    d.table_name
    FROM dtable d
    WHERE d.table_name=i_r_table_name
    WITH nocounter
   ;end select
   IF (curqual=1)
    SET io_reply->r_table_def_ind = 1
   ENDIF
   IF (check_error("Verify $R table CCL Definition exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    ui.index_name
    FROM user_indexes ui
    WHERE ui.index_type="FUNCTION-BASED NORMAL"
     AND ui.table_name=i_r_table_name
    WITH nocounter
   ;end select
   IF (curqual=1)
    SET io_reply->r_xpk_ind = 1
   ENDIF
   IF (check_error("Verify $R table primary key index exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    ut.trigger_name
    FROM user_triggers ut
    WHERE ut.table_name=i_r_table_name
     AND ut.trigger_name=concat("REFCHG",i_table_suffix,"_$R_MC")
     AND ((ut.status != "ENABLED") OR ( EXISTS (
    (SELECT
     "x"
     FROM user_objects o
     WHERE o.object_type="TRIGGER"
      AND o.object_name=ut.trigger_name
      AND o.status != "VALID"))))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET io_reply->r_rmc_trig_ind = 1
   ENDIF
   IF (check_error("Verify valid $R_MC trigger exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    ut.trigger_name
    FROM user_triggers ut
    WHERE ut.table_name=i_table_name
     AND ut.trigger_name=concat("REFCHG",i_table_suffix,"_REG*MC")
     AND ((ut.status != "ENABLED") OR ( EXISTS (
    (SELECT
     "x"
     FROM user_objects o
     WHERE o.object_type="TRIGGER"
      AND o.object_name=ut.trigger_name
      AND o.status != "VALID"))))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET io_reply->r_rmc_trig_ind = 1
   ENDIF
   IF (check_error("Verify valid REG*MC trigger exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   RETURN("S")
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
 DECLARE create_$r_tab(i_tab_name=vc,i_trig_ind=i2) = vc
 DECLARE dcrt_run(i_hreq=i4,i_table_name=vc,i_trig_ind=i2,i_db_name=vc) = vc
 DECLARE drop_$r_tab(i_tab_name=vc) = vc
 DECLARE create_$r_schema(null) = vc
 DECLARE correct_$r_add_ons(cao_tab_name=vc,cao_r_name=vc,cao_suffix=vc,cao_tab_ind=i2,cao_ccl_ind=i2,
  cao_xpk_ind=i2,cao_trig_ind=i2,cao_check_rep=vc(ref)) = i2
 DECLARE create_r_only(cro_tab_name=vc,cro_r_tab_name=vc,cro_trig_ind=i2,cro_remove_lock_ind=i2) = i2
 SUBROUTINE create_$r_tab(i_tab_name,i_trig_ind)
   DECLARE s_$r_tab_name = vc
   DECLARE s_$r_tab_exists = i2
   DECLARE s_live_tab_exists = i2
   DECLARE s_db_name = vc
   DECLARE v_happ = i4
   DECLARE v_htask = i4
   DECLARE v_hreq = i4
   DECLARE s_$r_tab_def = i4
   DECLARE s_$r_lock_attempt = i4
   DECLARE s_tab_suffix = vc
   DECLARE s_r_xpk_ind = i2
   DECLARE s_rmc_trig_ind = i2
   DECLARE s_prev_err_ind = i2 WITH protect, noconstant(0)
   DECLARE s_correct_ind = i2 WITH protect, noconstant(0)
   SET s_$r_tab_exists = 0
   SET s_live_tab_exists = 0
   SET s_$r_tab_name = cutover_tab_name(i_tab_name,"")
   SET s_$r_tab_def = 0
   SET s_$r_lock_attempt = 0
   SET s_tab_suffix = ""
   SET s_r_xpk_ind = 0
   SET s_rmc_trig_ind = 0
   FREE RECORD dcrt_ccl_def_reply
   RECORD dcrt_ccl_def_reply(
     1 status = c1
     1 status_msg = vc
   )
   FREE RECORD dcrt_check_r_table_reply
   RECORD dcrt_check_r_table_reply(
     1 r_table_ind = i2
     1 r_table_def_ind = i2
     1 r_xpk_ind = i2
     1 r_rmc_trig_ind = i2
   )
   IF (s_$r_tab_name <= "")
    SET dm_err->eproc = concat("$R table name could not be created for ",i_tab_name)
    CALL disp_msg("",dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    dtd.table_suffix
    FROM dm_tables_doc_local dtd
    WHERE dtd.full_table_name=i_tab_name
    DETAIL
     s_tab_suffix = dtd.table_suffix
    WITH nocounter
   ;end select
   IF (check_error("Retrieve table suffix") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name=i_tab_name
    DETAIL
     s_live_tab_exists = 1
    WITH nocounter
   ;end select
   IF (check_error("Verifying live tables exists in user_tables") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF (check_$r_table(i_tab_name,s_$r_tab_name,s_tab_suffix,dcrt_check_r_table_reply)="F")
    RETURN("F")
   ENDIF
   SET s_$r_tab_exists = dcrt_check_r_table_reply->r_table_ind
   IF (s_$r_tab_exists=1)
    WHILE (s_$r_lock_attempt < 5
     AND s_$r_tab_def=0)
     SET s_$r_tab_def = dcrt_check_r_table_reply->r_table_def_ind
     IF (s_$r_tab_def=0)
      CALL get_lock("RDDS $R CREATION",s_$r_tab_name,1,dcrt_ccl_def_reply)
      IF ((dcrt_ccl_def_reply->status="F"))
       SET s_$r_lock_attempt = (s_$r_lock_attempt+ 1)
      ELSEIF ((dcrt_ccl_def_reply->status="S"))
       EXECUTE oragen3 s_$r_tab_name
       IF (check_error(concat("Oragen3 process failed for table: ",s_$r_tab_name))=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET s_$r_lock_attempt = 5
        CALL remove_lock("RDDS $R CREATION",s_$r_tab_name,currdbhandle,dcrt_ccl_def_reply)
        RETURN("F")
       ENDIF
       SELECT INTO "nl:"
        FROM dtable d
        WHERE d.table_name=s_$r_tab_name
        DETAIL
         s_$r_tab_def = 1
        WITH nocounter
       ;end select
       IF (check_error("Verifying $R table ccl definition exists after creation") != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET s_$r_lock_attempt = 5
        CALL remove_lock("RDDS $R CREATION",s_$r_tab_name,currdbhandle,dcrt_ccl_def_reply)
        RETURN("F")
       ENDIF
       CALL remove_lock("RDDS $R CREATION",s_$r_tab_name,currdbhandle,dcrt_ccl_def_reply)
       IF ((dcrt_ccl_def_reply->status="F"))
        SET s_$r_lock_attempt = 5
        CALL disp_msg(dcrt_ccl_def_reply->status_msg,dm_err->logfile,1)
        RETURN("F")
       ELSEIF ((dcrt_ccl_def_reply->status="S"))
        SET s_$r_lock_attempt = 5
       ENDIF
      ELSE
       CALL pause(5)
       SELECT INTO "nl:"
        FROM dtable d
        WHERE d.table_name=s_$r_tab_name
        DETAIL
         s_$r_tab_def = 1
        WITH nocounter
       ;end select
       IF (check_error("Verifying $R table ccl definition exists after creation") != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET s_$r_lock_attempt = 5
       ENDIF
       IF (s_$r_tab_def=1)
        SET s_$r_lock_attempt = 5
       ELSE
        SET s_$r_lock_attempt = (s_$r_lock_attempt+ 1)
       ENDIF
      ENDIF
     ENDIF
    ENDWHILE
    SET s_correct_ind = correct_$r_add_ons(i_tab_name,s_$r_tab_name,s_tab_suffix,s_$r_tab_exists,
     s_$r_tab_def,
     dcrt_check_r_table_reply->r_xpk_ind,dcrt_check_r_table_reply->r_rmc_trig_ind,
     dcrt_check_r_table_reply)
    IF (s_correct_ind=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN("F")
    ENDIF
    SET s_r_xpk_ind = dcrt_check_r_table_reply->r_xpk_ind
    SET s_rmc_trig_ind = dcrt_check_r_table_reply->r_rmc_trig_ind
    IF (s_$r_tab_def=1
     AND s_r_xpk_ind=1
     AND s_rmc_trig_ind=1)
     SET dm_err->eproc = concat(s_$r_tab_name," table already exists")
     CALL disp_msg("",dm_err->logfile,0)
     RETURN("S")
    ELSE
     SET dm_err->eproc = concat(s_$r_tab_name," was not created completely.")
     IF (s_$r_tab_exists=0)
      SET dm_err->eproc = concat(dm_err->eproc," The table was NOT created.")
     ELSEIF (s_$r_tab_def=0)
      SET dm_err->eproc = concat(dm_err->eproc," The CCL definition was NOT created.")
     ELSEIF (s_r_xpk_ind=0)
      SET dm_err->eproc = concat(dm_err->eproc," The table is missing the XPK functional index.")
     ELSEIF (s_rmc_trig_ind=0)
      SET dm_err->eproc = concat(dm_err->eproc,
       " The table has one or more invalid or missing REG_MC triggers.")
     ENDIF
    ENDIF
    CALL disp_msg("",dm_err->logfile,1)
    RETURN("F")
   ELSEIF (s_live_tab_exists=0)
    SET dm_err->eproc = "$R table not created since live table does not exist"
    CALL disp_msg("",dm_err->logfile,0)
    RETURN("Z")
   ELSE
    SET s_correct_ind = create_r_only(i_tab_name,s_$r_tab_name,1,0)
    SET s_prev_err_ind = dm_err->err_ind
    SET dm_err->err_ind = 0
    IF (check_$r_table(i_tab_name,s_$r_tab_name,s_tab_suffix,dcrt_check_r_table_reply)="F")
     RETURN("F")
    ENDIF
    SET s_$r_tab_exists = dcrt_check_r_table_reply->r_table_ind
    SET s_$r_tab_def = dcrt_check_r_table_reply->r_table_def_ind
    IF (s_$r_tab_exists=1)
     IF (s_$r_tab_def=0)
      EXECUTE oragen3 s_$r_tab_name
      IF (check_error(concat("Oragen3 process failed for table: ",s_$r_tab_name))=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       CALL drop_$r_tab(i_tab_name)
       CALL remove_lock("RDDS $R CREATION",s_$r_tab_name,currdbhandle,dcrt_ccl_def_reply)
       RETURN("F")
      ENDIF
      SELECT INTO "nl:"
       FROM dtable d
       WHERE d.table_name=s_$r_tab_name
       DETAIL
        s_$r_tab_def = 1
       WITH nocounter
      ;end select
      IF (check_error("Verifying $R table ccl definition exists after creation") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET s_$r_lock_attempt = 5
       CALL drop_$r_tab(i_tab_name)
       CALL remove_lock("RDDS $R CREATION",s_$r_tab_name,currdbhandle,dcrt_ccl_def_reply)
       RETURN("F")
      ENDIF
     ENDIF
    ENDIF
    SET s_correct_ind = correct_$r_add_ons(i_tab_name,s_$r_tab_name,s_tab_suffix,s_$r_tab_exists,
     s_$r_tab_def,
     dcrt_check_r_table_reply->r_xpk_ind,dcrt_check_r_table_reply->r_rmc_trig_ind,
     dcrt_check_r_table_reply)
    SET s_prev_err_ind = s_correct_ind
    SET s_r_xpk_ind = dcrt_check_r_table_reply->r_xpk_ind
    SET s_rmc_trig_ind = dcrt_check_r_table_reply->r_rmc_trig_ind
    IF (s_$r_tab_exists=1
     AND s_$r_tab_def=1
     AND s_r_xpk_ind=1
     AND s_rmc_trig_ind=1)
     SET dm_err->eproc = concat(s_$r_tab_name," table successfully created")
     CALL disp_msg("",dm_err->logfile,0)
     CALL remove_lock("RDDS $R CREATION",s_$r_tab_name,currdbhandle,dcrt_ccl_def_reply)
     SET dm_err->err_ind = s_prev_err_ind
     RETURN("S")
    ELSE
     SET dm_err->eproc = concat(s_$r_tab_name," was not created completely.")
     IF (s_$r_tab_exists=0)
      SET dm_err->eproc = concat(dm_err->eproc," The table was NOT created.")
     ELSEIF (s_$r_tab_def=0)
      SET dm_err->eproc = concat(dm_err->eproc," The CCL definition was NOT created.")
     ELSEIF (s_r_xpk_ind=0)
      SET dm_err->eproc = concat(dm_err->eproc," The table is missing the XPK functional index.")
     ELSEIF (s_rmc_trig_ind=0)
      SET dm_err->eproc = concat(dm_err->eproc,
       " The table has one or more invalid or missing REG_MC triggers.")
     ENDIF
    ENDIF
    CALL disp_msg("",dm_err->logfile,1)
    CALL drop_$r_tab(i_tab_name)
    IF (s_$r_tab_exists=1)
     CALL remove_lock("RDDS $R CREATION",s_$r_tab_name,currdbhandle,dcrt_ccl_def_reply)
    ENDIF
    SET dm_err->err_ind = s_prev_err_ind
    RETURN("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE dcrt_run(i_hreq,i_table_name,i_trig_ind,i_db_name)
   FREE RECORD dcrt_reply
   RECORD dcrt_reply(
     1 status_data
       2 status = c1
       2 logfile = vc
   )
   DECLARE s_hreqstruct = i4
   DECLARE s_srvstat = f8
   DECLARE s_iret = i4
   DECLARE s_hreply = i4
   DECLARE s_hstatus = i4
   DECLARE s_statusvalue = c1
   DECLARE s_statuschild = vc
   SET s_hreqstruct = uar_crmgetrequest(i_hreq)
   CALL uar_srvsetstring(s_hreqstruct,"table_name",nullterm(i_table_name))
   CALL uar_srvsetshort(s_hreqstruct,"trig_ind",i_trig_ind)
   CALL uar_srvsetstring(s_hreqstruct,"database_name",nullterm(i_db_name))
   SET s_iret = uar_crmperform(i_hreq)
   IF (s_iret=0)
    SET s_hreply = uar_crmgetreply(i_hreq)
    SET s_hstatus = uar_srvgetstruct(s_hreply,"status_data")
    SET s_statusvalue = uar_srvgetstringptr(s_hstatus,"status")
    SET s_statuschild = uar_srvgetstringptr(s_hstatus,"logfile")
    SET dm_err->eproc = concat("DM_RMC_CREATE_R_TABLE LogFile.. ",s_statuschild)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(s_statusvalue)
   ELSEIF (s_iret != 0)
    RETURN("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE drop_$r_tab(i_tab_name)
   FREE RECORD drt_request
   RECORD drt_request(
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
   FREE RECORD drt_parse
   RECORD drt_parse(
     1 stmt[*]
       2 str = vc
   )
   DECLARE s_$r_tab_name = vc
   DECLARE s_vers_ret = i4 WITH protect, noconstant(0)
   DECLARE s_tab_suffix = vc
   DECLARE s_drt_stmt_cnt = i4
   DECLARE s_reg_trig_name = vc WITH protect, noconstant("")
   DECLARE drt_fbi_func = vc WITH protect, noconstant("")
   DECLARE drt_drop_func_ind = i2 WITH protect, noconstant(0)
   DECLARE drt_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE drt_retry_max = i2 WITH protect, constant(5)
   SET s_$r_tab_exists = 0
   SET s_drt_stmt_cnt = 0
   SELECT INTO "nl:"
    FROM dm_rdds_tbl_doc dtd
    WHERE dtd.table_name=i_tab_name
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     s_tab_suffix = dtd.table_suffix
    WITH nocounter
   ;end select
   IF (check_error("Retrieving table suffix from dm_rdds_tbl_doc") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SET s_$r_tab_name = cutover_tab_name(i_tab_name,s_tab_suffix)
   SELECT INTO "nl:"
    FROM user_triggers ut
    WHERE ut.trigger_name="REFCHG*REG*MC*"
     AND ut.table_name=i_tab_name
    DETAIL
     s_reg_trig_name = ut.trigger_name
    WITH nocounter
   ;end select
   IF (check_error("Verifying *_REG_MC, *_REG_MD_MC or *$C trigger exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    SET stat = initrec(drt_parse)
    SET stat = alterlist(drt_parse->stmt,1)
    SET drt_parse->stmt[1].str = concat("rdb drop trigger ",s_reg_trig_name," go")
    SET drt_retry_cnt = 0
    WHILE (drt_retry_cnt < drt_retry_max)
     EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DRT_PARSE")
     IF (check_error(concat(" Trigger_Build: Error in dropping trigger ",s_reg_trig_name)) != 0)
      IF (findstring("ORA-00054",dm_err->emsg))
       IF ((drt_retry_cnt >= (drt_retry_max - 1)))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->err_ind = 1
        RETURN("F")
       ELSE
        SET dm_err->user_action =
        "Retrying drop trigger command due to resource busy, error may be ignored."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->user_action = ""
        SET dm_err->err_ind = 0
        SET drt_retry_cnt = (drt_retry_cnt+ 1)
       ENDIF
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       RETURN("F")
      ENDIF
     ELSE
      SET drt_retry_cnt = drt_retry_max
     ENDIF
    ENDWHILE
   ENDIF
   SET s_vers_ret = dm2_get_rdbms_version(null)
   IF (s_vers_ret=0)
    RETURN("F")
   ENDIF
   SET stat = initrec(drt_parse)
   SET stat = alterlist(drt_parse->stmt,1)
   IF ((dm2_rdbms_version->level1 >= 10))
    SET drt_parse->stmt[1].str = concat("rdb drop table ",s_$r_tab_name," purge go")
   ELSE
    SET drt_parse->stmt[1].str = concat("rdb drop table ",s_$r_tab_name," go")
   ENDIF
   SET drt_retry_cnt = 0
   WHILE (drt_retry_cnt < drt_retry_max)
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DRT_PARSE")
    IF (check_error(concat(" Error in dropping table ",s_$r_tab_name)) != 0)
     IF (findstring("ORA-00054",dm_err->emsg))
      IF ((drt_retry_cnt >= (drt_retry_max - 1)))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       RETURN("F")
      ELSE
       SET dm_err->user_action =
       "Retrying drop table command due to resource busy, error may be ignored."
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->user_action = ""
       SET dm_err->err_ind = 0
       SET drt_retry_cnt = (drt_retry_cnt+ 1)
      ENDIF
     ELSE
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      RETURN("F")
     ENDIF
    ELSE
     SET drt_retry_cnt = drt_retry_max
    ENDIF
   ENDWHILE
   SET stat = initrec(drt_parse)
   SET stat = alterlist(drt_parse->stmt,1)
   SET drt_parse->stmt[1].str = concat("drop table ",s_$r_tab_name," go")
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DRT_PARSE")
   IF (check_error("Performing drop CCL table def command") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SET drt_fbi_func = concat("REFCHG_XPK$R_",s_tab_suffix)
   SELECT INTO "nl:"
    FROM user_objects uo
    WHERE uo.object_name=drt_fbi_func
     AND uo.object_type="FUNCTION"
    DETAIL
     drt_drop_func_ind = 1
    WITH nocounter
   ;end select
   IF (check_error("Checking if Function based index function exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF (drt_drop_func_ind=1)
    SET stat = initrec(drt_parse)
    SET stat = alterlist(drt_parse->stmt,1)
    SET drt_parse->stmt[1].str = concat("rdb drop function ",drt_fbi_func," go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DRT_PARSE")
    IF (check_error("Performing drop function command") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name=s_$r_tab_name
    WITH nocounter
   ;end select
   IF (check_error("Validating $R table no longer exists") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = concat(s_$r_tab_name," table was NOT dropped")
    CALL disp_msg("",dm_err->logfile,1)
    RETURN("F")
   ELSE
    SET dm_err->eproc = concat(s_$r_tab_name," table successfully dropped")
    CALL disp_msg("",dm_err->logfile,0)
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE create_$r_schema(null)
   FREE RECORD all_$r_tabs
   RECORD all_$r_tabs(
     1 list[*]
       2 r_tab_name = vc
   )
   DECLARE s_$r_cnt = i4
   DECLARE s_return_status = c1
   DECLARE s_reg_tab_name = vc
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name="*$R"
    DETAIL
     s_$r_cnt = (s_$r_cnt+ 1)
     IF (mod(s_$r_cnt,10)=1)
      stat = alterlist(all_$r_tabs->list,(s_$r_cnt+ 9))
     ENDIF
     all_$r_tabs->list[s_$r_cnt].r_tab_name = ut.table_name
    FOOT REPORT
     stat = alterlist(all_$r_tabs->list,s_$r_cnt)
    WITH nocounter
   ;end select
   IF (check_error("Retrieving all $R tables from user_tables") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("F")
   ENDIF
   SET s_return_status = "S"
   FOR (for_cnt = 1 TO s_$r_cnt)
    SET s_reg_tab_name = get_reg_tab_name(all_$r_tabs->list[for_cnt].r_tab_name,"")
    IF (drop_$r_tab(s_reg_tab_name)="S")
     SET s_return_status = "S"
    ELSE
     SET s_return_status = "F"
     SET for_cnt = s_$r_cnt
    ENDIF
   ENDFOR
   RETURN(s_return_status)
 END ;Subroutine
 SUBROUTINE correct_$r_add_ons(cao_tab_name,cao_r_name,cao_suffix,cao_tab_ind,cao_ccl_ind,cao_xpk_ind,
  cao_trig_ind,cao_check_rep)
   DECLARE cao_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE cao_cro_return = i2 WITH protect, noconstant(0)
   DECLARE cao_check_return = vc WITH protect, noconstant(" ")
   IF (cao_tab_ind=1
    AND cao_ccl_ind=1
    AND ((cao_xpk_ind=0) OR (cao_trig_ind=0)) )
    SELECT INTO "NL:"
     cnt = count(*)
     FROM (parser(cao_r_name) r)
     WHERE rdds_status_flag < 9000
     DETAIL
      cao_row_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error("Querying for uncutover $R rows") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF (cao_row_cnt=0)
     SET cao_cro_return = create_r_only(cao_tab_name,cao_r_name,1,1)
     SET stat = initrec(cao_check_rep)
     SET cao_check_return = check_$r_table(cao_tab_name,cao_r_name,cao_suffix,cao_check_rep)
     IF (cao_check_return="F")
      SET cao_cro_return = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(cao_cro_return)
 END ;Subroutine
 SUBROUTINE create_r_only(cro_tab_name,cro_r_tab_name,cro_trig_ind,cro_remove_lock_ind)
   DECLARE cro_db_name = vc WITH protect, noconstant(" ")
   DECLARE cro_lock_attempt = i4 WITH protect, noconstant(0)
   DECLARE cro_return = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v$database v
    DETAIL
     cro_db_name = v.name
    WITH nocounter
   ;end select
   IF (check_error("Retrieving database name from v$database") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   SET cro_lock_attempt = 0
   WHILE (cro_lock_attempt < 5)
    CALL get_lock("RDDS $R CREATION",cro_r_tab_name,1,dcrt_ccl_def_reply)
    IF ((dcrt_ccl_def_reply->status="F"))
     SET cro_lock_attempt = (cro_lock_attempt+ 1)
    ELSEIF ((dcrt_ccl_def_reply->status="Z"))
     SET cro_lock_attempt = 5
    ELSEIF ((dcrt_ccl_def_reply->status="S"))
     SET cro_lock_attempt = 5
    ENDIF
   ENDWHILE
   IF ((((dcrt_ccl_def_reply->status="Z")) OR ((dcrt_ccl_def_reply->status="F"))) )
    SET dm_err->eproc = concat("$R Creation lock for ",s_$r_tab_name," table could not be achieved.")
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Executing DM_RMC_CREATE_R_TABLE... "
   CALL disp_msg("",dm_err->logfile,0)
   FREE RECORD dcrt_request
   RECORD dcrt_request(
     1 table_name = vc
     1 trig_ind = i2
     1 database_name = vc
   )
   FREE RECORD dcrt_reply
   RECORD dcrt_reply(
     1 status_data
       2 status = c1
       2 logfile = vc
   )
   SET dcrt_request->table_name = cro_tab_name
   SET dcrt_request->trig_ind = cro_trig_ind
   SET dcrt_request->database_name = cro_db_name
   EXECUTE dm_rmc_create_r_table  WITH replace("REQUEST","DCRT_REQUEST"), replace("REPLY",
    "DCRT_REPLY")
   SET dm_err->eproc = concat("DM_RMC_CREATE_R_TABLE LogFile.. ",dcrt_reply->logfile)
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm_err->err_ind=1))
    SET cro_return = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (cro_remove_lock_ind=1)
    CALL remove_lock("RDDS $R CREATION",cro_r_tab_name,currdbhandle,dcrt_ccl_def_reply)
   ENDIF
   RETURN(cro_return)
 END ;Subroutine
 IF (check_logfile("DM_RMC_CREATE_ALL",".log","DM_RMC_CREATE_ALL_TABLES LogFile")=0)
  GO TO exit_program
 ENDIF
 DECLARE v_target_env_id = f8
 DECLARE v_source_chg_log = vc
 DECLARE v_tab_cnt = i4
 DECLARE v_tab_idx = i4
 DECLARE v_$r_status = c1
 SET v_target_env_id =  $1
 SET v_source_chg_log = concat("dm_chg_log", $2)
 SET v_tab_cnt = 0
 FREE RECORD rdds_tables
 RECORD rdds_tables(
   1 list[*]
     2 name = vc
 )
 SELECT DISTINCT INTO "nl:"
  d.table_name
  FROM (parser(v_source_chg_log) d)
  WHERE d.target_env_id=v_target_env_id
   AND d.log_type="REFCHG"
   AND d.table_name > " "
  DETAIL
   v_tab_cnt = (v_tab_cnt+ 1)
   IF (mod(v_tab_cnt,100)=1)
    stat = alterlist(rdds_tables->list,(v_tab_cnt+ 99))
   ENDIF
   rdds_tables->list[v_tab_cnt].name = d.table_name
  WITH nocounter
 ;end select
 IF (check_error("Validating input table_name(s)") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 FOR (drmc_for_cnt = 1 TO v_tab_cnt)
   SET dm_err->eproc = "Calling create_$R_tab subroutine... "
   CALL disp_msg("",dm_err->logfile,0)
   SET v_$r_status = create_$r_tab(rdds_tables->list[drmc_for_cnt].name,1)
   IF (((check_error("Calling create_$R_tab subroutine... ") != 0) OR (v_$r_status="F")) )
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drmc_for_cnt = v_tab_cnt
   ENDIF
 ENDFOR
#exit_program
 FREE RECORD rdds_tables
 SET dm_err->eproc = "...Ending dm_rmc_create_all_tables"
 CALL final_disp_msg("DM_RMC_CREATE_ALL_TABLES")
END GO
