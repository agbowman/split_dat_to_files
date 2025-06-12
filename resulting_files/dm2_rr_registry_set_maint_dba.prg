CREATE PROGRAM dm2_rr_registry_set_maint:dba
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
 IF ((validate(drsr_reg_sets->set_cnt,- (1))=- (1))
  AND validate(drsr_reg_sets->set_cnt,1)=1)
  FREE RECORD drsr_reg_sets
  RECORD drsr_reg_sets(
    1 set_cnt = i4
    1 current_set_name = vc
    1 sets[*]
      2 set_name = vc
      2 set_desc = vc
      2 date_modified = dq8
      2 property_cnt = i4
  )
  SET drsr_reg_sets->set_cnt = 0
  SET drsr_reg_sets->current_set_name = "DM2NOTSET"
 ENDIF
 IF ((validate(drsr_set_detail->property_cnt,- (1))=- (1))
  AND validate(drsr_set_detail->property_cnt,1)=1)
  FREE RECORD drsr_set_detail
  RECORD drsr_set_detail(
    1 set_name = vc
    1 set_desc = vc
    1 date_modified = dq8
    1 property_cnt = i4
    1 props[*]
      2 prop_name = vc
      2 prop_value = vc
      2 remove_ind = i2
  )
  SET drsr_set_detail->set_name = "DM2NOTSET"
  SET drsr_set_detail->set_desc = "DM2NOTSET"
  SET drsr_set_detail->property_cnt = 0
 ENDIF
 DECLARE drsr_get_set_list(null) = i2
 DECLARE drsr_get_registry_set(null) = i2
 DECLARE drsr_clear_drsr_set_detail(null) = i2
 DECLARE drsr_clear_drsr_reg_sets(null) = i2
 DECLARE drsr_load_reg_set_details(dlsd_set_name=vc) = i2
 DECLARE drsr_insert_set_details(null) = i2
 SUBROUTINE drsr_clear_drsr_reg_sets(null)
   SET drsr_reg_sets->set_cnt = 0
   SET drsr_reg_sets->current_set_name = "DM2NOTSET"
   SET stat = alterlist(drsr_reg_sets->sets,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsr_clear_drsr_set_detail(null)
   SET drsr_set_detail->property_cnt = 0
   SET drsr_set_detail->set_name = ""
   SET drsr_set_detail->set_desc = ""
   SET stat = alterlist(drsr_set_detail->props,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsr_get_set_list(null)
   SET dm_err->eproc =
   "Populating the drsr_reg_sets record structure with list of registry sets from Admin dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring("DM2_REGISTRY_SET(ED)-*")
    ORDER BY di.info_domain
    HEAD REPORT
     drsr_reg_sets->set_cnt = 0, stat = alterlist(drsr_reg_sets->sets,drsr_reg_sets->set_cnt)
    HEAD di.info_domain
     drsr_reg_sets->set_cnt = (drsr_reg_sets->set_cnt+ 1)
     IF (mod(drsr_reg_sets->set_cnt,10)=1)
      stat = alterlist(drsr_reg_sets->sets,(drsr_reg_sets->set_cnt+ 9))
     ENDIF
     drsr_reg_sets->sets[drsr_reg_sets->set_cnt].set_name = replace(di.info_domain,
      "DM2_REGISTRY_SET(ED)-","",1), drsr_reg_sets->sets[drsr_reg_sets->set_cnt].property_cnt = 0
    DETAIL
     IF (di.info_name="REGISTRY_SET_DESCRIPTION")
      drsr_reg_sets->sets[drsr_reg_sets->set_cnt].set_desc = trim(di.info_char), drsr_reg_sets->sets[
      drsr_reg_sets->set_cnt].date_modified = di.info_date
     ELSE
      drsr_reg_sets->sets[drsr_reg_sets->set_cnt].property_cnt = (drsr_reg_sets->sets[drsr_reg_sets->
      set_cnt].property_cnt+ 1)
     ENDIF
    FOOT REPORT
     stat = alterlist(drsr_reg_sets->sets,drsr_reg_sets->set_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drsr_reg_sets)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsr_get_registry_set(null)
   DECLARE dgrs_set_name = vc WITH protect, noconstant("")
   DECLARE dgrs_set_idx = i4 WITH protect, noconstant(0)
   DECLARE dgrs_continue = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Obtaining Registry Set"
   CALL disp_msg("",dm_err->logfile,0)
   SET drsr_reg_sets->current_set_name = "DM2NOTSET"
   IF (drsr_clear_drsr_set_detail(null)=0)
    RETURN(0)
   ENDIF
   SET dgrs_continue = 1
   SET dm_err->eproc = "Verifying at least one registry set exists."
   IF (drsr_get_set_list(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtaining registry set from user..."
   WHILE (dgrs_continue=1)
     IF ((dm_err->debug_flag=722))
      SET message = nowindow
     ELSE
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"REGISTRY SET MAINTENANCE [REGISTRY SET SELECTION]")
     IF ((drsr_reg_sets->set_cnt=0))
      CALL text(5,2,"**No registry sets currently exist. Press <Enter> to Continue")
      CALL accept(5,90,"p;cu"," "
       WHERE curaccept IN (" "))
      SET dgrs_continue = 0
     ELSE
      CALL text(7,2,"Registry Set Name: ")
      SET help = pos(9,2,10,128)
      SET help =
      SELECT INTO "nl:"
       registry_set = substring(1,30,drsr_reg_sets->sets[t.seq].set_name), property_cnt = cnvtstring(
        drsr_reg_sets->sets[t.seq].property_cnt)
       FROM (dummyt t  WITH seq = value(drsr_reg_sets->set_cnt))
       ORDER BY drsr_reg_sets->sets[t.seq].set_name
       WITH nocounter
      ;end select
      CALL accept(7,30,"P(30);CUF")
      SET help = off
      SET dgrs_set_name = trim(curaccept)
      SET dm_err->eproc = "Verifying that registry set exists"
      IF (locateval(dgrs_set_idx,1,drsr_reg_sets->set_cnt,dgrs_set_name,drsr_reg_sets->sets[
       dgrs_set_idx].set_name) > 0)
       SET drsr_reg_sets->current_set_name = dgrs_set_name
       SET dgrs_continue = 0
       CALL clear(5,2,100)
      ELSE
       CALL text(5,2,build("**",dgrs_set_name,
         " does not exist. Please provide another registry set name."))
       SET dgrs_continue = 1
      ENDIF
     ENDIF
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsr_load_reg_set_details(dlsd_set_name)
   DECLARE dlrsd_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Clearing up the drsr_set_detail record structure"
   CALL disp_msg("",dm_err->logfile,0)
   IF (drsr_clear_drsr_set_detail(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving registry set details from dm2_admin_dm_info"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=concat("DM2_REGISTRY_SET(ED)-",dlsd_set_name)
    ORDER BY di.info_name
    HEAD REPORT
     dlrsd_cnt = 0, stat = alterlist(drsr_set_detail->props,dlrsd_cnt)
    DETAIL
     drsr_set_detail->set_name = dlsd_set_name
     IF (di.info_name="REGISTRY_SET_DESCRIPTION")
      drsr_set_detail->set_desc = di.info_char, drsr_set_detail->date_modified = di.info_date
     ELSE
      dlrsd_cnt = (dlrsd_cnt+ 1)
      IF (mod(dlrsd_cnt,10)=1)
       stat = alterlist(drsr_set_detail->props,(dlrsd_cnt+ 9))
      ENDIF
      drsr_set_detail->props[dlrsd_cnt].prop_name = di.info_name, drsr_set_detail->props[dlrsd_cnt].
      prop_value = di.info_char
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat("prop_name = <<",drsr_set_detail->props[dlrsd_cnt].prop_name,">>")),
       CALL echo(concat("prop_value = <<",drsr_set_detail->props[dlrsd_cnt].prop_value,">>")),
       CALL echo(concat("prop_value size = <<",cnvtstring(size(drsr_set_detail->props[dlrsd_cnt].
          prop_value)),">>"))
      ENDIF
     ENDIF
    FOOT REPORT
     drsr_set_detail->property_cnt = dlrsd_cnt, stat = alterlist(drsr_set_detail->props,
      drsr_set_detail->property_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=722))
    CALL echorecord(drsr_set_detail)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsr_insert_set_details(null)
   SET dm_err->eproc = concat("Deleting registry set details for ",drsr_set_detail->set_name,
    " from dm2_admin_dm_info.")
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain=concat("DM2_REGISTRY_SET(ED)-",drsr_reg_sets->current_set_name)
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Inserting registry set details for ",drsr_set_detail->set_name,
    " into dm2_admin_dm_info.")
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = concat("DM2_REGISTRY_SET(ED)-",drsr_set_detail->set_name), di.info_name =
     "REGISTRY_SET_DESCRIPTION", di.info_char = drsr_set_detail->set_desc,
     di.info_date = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF ((drsr_set_detail->property_cnt > 0))
    SET dm_err->eproc = concat("Inserting Individual property details for ",drsr_set_detail->set_name,
     " into dm2_admin_dm_info")
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(drsr_set_detail->property_cnt))
     SET di.info_domain = concat("DM2_REGISTRY_SET(ED)-",drsr_set_detail->set_name), di.info_name =
      drsr_set_detail->props[d.seq].prop_name, di.info_char = drsr_set_detail->props[d.seq].
      prop_value
     PLAN (d
      WHERE d.seq > 0
       AND (drsr_set_detail->props[d.seq].remove_ind=0))
      JOIN (di)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 DECLARE drsm_create_reg_set(null) = i2
 DECLARE drsm_modify_reg_set(null) = i2
 DECLARE drsm_remove_reg_set(null) = i2
 DECLARE drsm_report_reg_set(null) = i2
 DECLARE drsm_update_reg_set_desc(null) = i2
 IF (check_logfile("dm2_reg_set_maint",".log","dm2_rr_registry_set_maint")=0)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag=722))
  SET message = nowindow
 ELSE
  SET message = window
 ENDIF
 SET width = 132
 WHILE (true)
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL box(1,1,24,132)
   CALL text(2,2,"REGISTRY SET MAINTENANCE [MAIN]")
   CALL text(4,4,concat(
     "Registry set maintenance is only for properties residing in the environment specific definitions key"
     ))
   CALL text(5,4,concat(
     "(i.e. \system\environment\<env>\definitions\[aixrs6000|hpuxia64|linuxx86-64]\environment)."))
   CALL text(7,10,"1. Create Registry Set")
   CALL text(9,10,"2. Modify Registry Set")
   CALL text(11,10,"3. Remove Registry Set")
   CALL text(13,10,"4. Report Registry Set")
   CALL text(16,10,"Your Selection (0 to Exit)?")
   CALL accept(16,38,"9;",0
    WHERE curaccept IN (0, 1, 2, 3, 4))
   CASE (curaccept)
    OF 0:
     GO TO exit_program
    OF 1:
     IF (drsm_create_reg_set(null)=0)
      GO TO exit_program
     ENDIF
    OF 2:
     IF (drsm_modify_reg_set(null)=0)
      GO TO exit_program
     ENDIF
    OF 3:
     IF (drsm_remove_reg_set(null)=0)
      GO TO exit_program
     ENDIF
    OF 4:
     IF (drsm_report_reg_set(null)=0)
      GO TO exit_program
     ENDIF
   ENDCASE
 ENDWHILE
 GO TO exit_program
 SUBROUTINE drsm_create_reg_set(null)
   DECLARE dcrs_set_name = vc WITH protect, noconstant("")
   DECLARE dcrs_set_desc = vc WITH protect, noconstant("")
   DECLARE dcrs_preload_set = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dcrs_preload_choice = vc WITH protect, noconstant("")
   DECLARE dcrs_continue = i2 WITH protect, noconstant(1)
   DECLARE dcrs_continue2 = i2 WITH protect, noconstant(1)
   DECLARE dcrs_set_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Creating new registry set"
   CALL disp_msg("",dm_err->logfile,0)
   IF (drsr_get_set_list(null)=0)
    RETURN(0)
   ENDIF
   SET drsr_reg_sets->current_set_name = "DM2NOTSET"
   IF (drsr_clear_drsr_set_detail(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtaining Registry Set from user..."
   WHILE (dcrs_continue=1)
     IF ((dm_err->debug_flag=722))
      SET message = nowindow
     ELSE
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL box(1,1,24,132)
     CALL text(2,2,"REGISTRY SET MAINTENANCE [CREATE NEW REGISTRY SET]")
     SET dcrs_continue2 = 1
     WHILE (dcrs_continue2=1)
       CALL text(7,2,"Registry Set Name: ")
       CALL accept(7,30,"P(30);CU",dcrs_set_name
        WHERE curaccept > " ")
       SET dcrs_set_name = trim(curaccept,3)
       IF (locateval(dcrs_set_idx,1,drsr_reg_sets->set_cnt,dcrs_set_name,drsr_reg_sets->sets[
        dcrs_set_idx].set_name) > 0)
        CALL text(5,2,concat("**",dcrs_set_name," is already in use. Please use another name."))
        SET dcrs_continue2 = 1
       ELSE
        CALL clear(5,2,100)
        SET dcrs_continue2 = 0
       ENDIF
     ENDWHILE
     CALL text(9,2,"Registry Set Description: ")
     CALL accept(9,30,"P(70);C",dcrs_set_desc)
     SET dcrs_set_desc = trim(curaccept,3)
     SET dcrs_continue2 = 1
     WHILE (dcrs_continue2=1)
       CALL text(11,2,"Pre-Load from existing registry set (Y/N):")
       CALL accept(11,45,"p;cu"," "
        WHERE curaccept IN ("Y", "N"))
       SET dcrs_preload_choice = curaccept
       IF (dcrs_preload_choice="Y")
        IF ((drsr_reg_sets->set_cnt=0))
         CALL text(5,2,concat("**","There are no existing registry sets."))
         SET dcrs_continue2 = 1
        ELSE
         CALL clear(5,2,100)
         SET dcrs_continue2 = 0
        ENDIF
       ELSE
        SET dcrs_continue2 = 0
       ENDIF
     ENDWHILE
     SET dcrs_continue2 = 1
     WHILE (dcrs_continue2=1
      AND dcrs_preload_choice="Y")
       CALL text(14,2,"Registry Set to Pre-Load: ")
       SET help = pos(9,2,10,128)
       SET help =
       SELECT INTO "nl:"
        registry_set_name = substring(1,30,drsr_reg_sets->sets[t.seq].set_name), property_cnt =
        cnvtstring(drsr_reg_sets->sets[t.seq].property_cnt)
        FROM (dummyt t  WITH seq = value(drsr_reg_sets->set_cnt))
        ORDER BY drsr_reg_sets->sets[t.seq].set_name
        WITH nocounter
       ;end select
       CALL accept(14,30,"P(30);CUF",dcrs_preload_set
        WHERE curaccept > " ")
       SET help = off
       SET dcrs_preload_set = trim(curaccept,3)
       IF (locateval(dcrs_set_idx,1,drsr_reg_sets->set_cnt,dcrs_preload_set,drsr_reg_sets->sets[
        dcrs_set_idx].set_name)=0)
        CALL text(5,2,concat("**",dcrs_preload_set,
          " does not exist. Please provide an existing registry set to pre-load."))
        SET dcrs_continue2 = 1
       ELSE
        CALL clear(5,2,100)
        SET dcrs_continue2 = 0
       ENDIF
     ENDWHILE
     CALL text(16,2,"(C)ontinue, (M)odify, (B)ack:")
     CALL accept(16,35,"p;cu","C"
      WHERE curaccept IN ("C", "M", "B"))
     SET message = nowindow
     CASE (curaccept)
      OF "B":
       SET drsr_reg_sets->current_set_name = "DM2NOTSET"
       SET dcrs_continue = 0
      OF "M":
       SET dcrs_continue = 1
      OF "C":
       IF (dcrs_preload_choice="Y")
        IF (drsr_load_reg_set_details(dcrs_preload_set)=0)
         RETURN(0)
        ENDIF
       ENDIF
       SET drsr_reg_sets->current_set_name = dcrs_set_name
       SET drsr_set_detail->set_name = dcrs_set_name
       SET drsr_set_detail->set_desc = dcrs_set_desc
       SET drsr_set_detail->date_modified = cnvtdatetime(curdate,curtime3)
       IF (drsr_insert_set_details(null)=0)
        RETURN(0)
       ENDIF
       SET dcrs_continue = 0
     ENDCASE
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drsr_reg_sets->current_set_name != "DM2NOTSET"))
    IF (drsm_modify_reg_set(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsm_modify_reg_set(null)
   DECLARE dmrs_property_name = vc WITH protect, noconstant("")
   DECLARE dmrs_set_desc = vc WITH protect, noconstant("")
   DECLARE dmrs_property_value = vc WITH protect, noconstant("")
   DECLARE dmrs_continue = i2 WITH protect, noconstant(1)
   DECLARE dmrs_continue2 = i2 WITH protect, noconstant(1)
   DECLARE dmrs_prop_idx = i4 WITH protect, noconstant(0)
   DECLARE dmrs_seq = i4 WITH protect, noconstant(1)
   DECLARE dmrs_index = i4 WITH protect, noconstant(1)
   DECLARE dmrs_start = i4 WITH protect, noconstant(1)
   DECLARE dmrs_end = i4 WITH protect, noconstant(1)
   DECLARE dmrs_location = i4 WITH protect, noconstant(0)
   DECLARE dmrs_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dmrs_valid_ind = i2 WITH protect, noconstant(0)
   DECLARE dmrs_increment = i2 WITH protect, noconstant(0)
   DECLARE dmrs_tmp_value = vc WITH protect, noconstant("")
   DECLARE dmrs_from = i2 WITH protect, noconstant(0)
   IF ((drsr_reg_sets->current_set_name="DM2NOTSET"))
    IF (drsr_get_registry_set(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drsr_reg_sets->current_set_name="DM2NOTSET"))
    RETURN(1)
   ENDIF
   IF (drsr_load_reg_set_details(drsr_reg_sets->current_set_name)=0)
    RETURN(0)
   ENDIF
   IF (drsm_update_reg_set_desc(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Modify Registry Set"
   WHILE (dmrs_continue=1)
     IF ((dm_err->debug_flag=722))
      SET message = nowindow
     ELSE
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL box(1,1,24,132)
     CALL text(2,2,"REGISTRY SET MAINTENANCE [MODIFY REGISTRY SET]")
     CALL text(4,2,"Registry Set Name: ")
     CALL text(4,30,drsr_set_detail->set_name)
     CALL text(4,70,"Last Modified:")
     CALL text(4,85,format(cnvtdatetime(drsr_set_detail->date_modified),"DD-MMM-YYYY HH:MM:SS;;D"))
     CALL text(5,2,"Registry Set Description: ")
     CALL text(5,30,drsr_set_detail->set_desc)
     CALL text(7,2,"LINE_NBR")
     CALL text(7,11," ")
     CALL text(7,12,"PROPERTY_NAME")
     CALL text(7,53,"PROPERTY_VALUE")
     CALL text(8,2,fillstring(8,"-"))
     CALL text(8,12,fillstring(40,"-"))
     CALL text(8,53,fillstring(75,"-"))
     SET dmrs_seq = 1
     FOR (dmrs_index = dmrs_start TO least((dmrs_start+ 9),drsr_set_detail->property_cnt))
       CALL text((8+ dmrs_seq),2,concat(build(format(dmrs_index,"###;P0")),") "))
       IF ((drsr_set_detail->props[dmrs_index].remove_ind=1))
        CALL text((8+ dmrs_seq),11,"*")
       ENDIF
       IF (size(drsr_set_detail->props[dmrs_index].prop_name) > 40)
        CALL text((8+ dmrs_seq),12,concat(substring(1,37,drsr_set_detail->props[dmrs_index].prop_name
           ),"..."))
       ELSE
        CALL text((8+ dmrs_seq),12,drsr_set_detail->props[dmrs_index].prop_name)
       ENDIF
       IF (size(drsr_set_detail->props[dmrs_index].prop_value) > 75)
        CALL text((8+ dmrs_seq),53,concat(substring(1,72,drsr_set_detail->props[dmrs_index].
           prop_value),"..."))
       ELSE
        CALL text((8+ dmrs_seq),53,drsr_set_detail->props[dmrs_index].prop_value)
       ENDIF
       SET dmrs_end = (dmrs_start+ dmrs_seq)
       SET dmrs_seq = (dmrs_seq+ 1)
     ENDFOR
     IF ((drsr_set_detail->property_cnt > 10))
      IF (dmrs_start=1)
       CALL text(20,2,"(Beginning of List, use <Down> key to scroll)")
      ELSEIF ((drsr_set_detail->property_cnt >= dmrs_end))
       CALL text(20,2,"(More available, use <Up>/<Down> keys to scroll)")
      ELSEIF ((drsr_set_detail->property_cnt < dmrs_end))
       CALL text(20,2,"(End of List, use <Up> key to scroll)")
      ENDIF
     ENDIF
     IF ((drsr_set_detail->property_cnt > 0))
      CALL text(23,2,
       "(A)dd Property, (U)pdate Property, (V)iew Property, (R)emove Property, (C)onfirm Changes, (B)ack: "
       )
      CALL accept(23,100,"A;CUS"," "
       WHERE curaccept IN ("A", "U", "V", "R", "C",
       "B"))
     ELSE
      CALL text(23,2,"(A)dd Property, (C)onfirm Changes, (B)ack: ")
      CALL accept(23,45,"A;CUS"," "
       WHERE curaccept IN ("A", "C", "B"))
     ENDIF
     CASE (curscroll)
      OF 0:
       CASE (curaccept)
        OF "A":
         IF ((dm_err->debug_flag=722))
          SET message = nowindow
         ELSE
          SET message = window
         ENDIF
         CALL clear(1,1)
         CALL box(1,1,3,132)
         CALL box(1,1,24,132)
         CALL text(2,2,"REGISTRY SET MAINTENANCE [ADD PROPERTY TO REGISTRY SET]")
         CALL text(5,2,"Registry Set Name: ")
         CALL text(5,30,drsr_set_detail->set_name)
         CALL text(5,70,"Last Modified:")
         CALL text(5,85,format(cnvtdatetime(drsr_set_detail->date_modified),"DD-MMM-YYYY HH:MM:SS;;D"
           ))
         CALL text(6,2,"Registry Set Description: ")
         CALL text(6,30,drsr_set_detail->set_desc)
         SET dmrs_exists_ind = 0
         SET dmrs_continue2 = 1
         WHILE (dmrs_continue2=1)
           SET dmrs_valid_ind = 1
           CALL clear(8,2,120)
           CALL text(10,2,"Property Name:")
           CALL accept(10,17,"P(63);C"," "
            WHERE curaccept > " ")
           SET dmrs_property_name = trim(curaccept,3)
           IF (cnvtalphanum(trim(dmrs_property_name,3)) != replace(replace(trim(dmrs_property_name,3),
             "_","",0),"-","",0))
            CALL text(8,2,concat(
              "** Property name can only contain alphanumerics, underscores and hyphens (no spaces). ",
              "Press <Enter> to continue..."))
            CALL accept(8,117,"p;cu"," "
             WHERE curaccept IN (" "))
            SET dmrs_valid_ind = 0
           ENDIF
           IF (dmrs_valid_ind=1)
            IF (locateval(dmrs_index,1,drsr_set_detail->property_cnt,cnvtupper(dmrs_property_name),
             cnvtupper(drsr_set_detail->props[dmrs_index].prop_name)) > 0)
             CALL text(8,2,concat("** ",dmrs_property_name,
               " has already been added to the current registry set. ","Press <Enter> to continue..."
               ))
             CALL accept(8,110,"p;cu"," "
              WHERE curaccept IN (" "))
             SET dmrs_continue2 = 0
             SET dmrs_exists_ind = 1
            ELSE
             SET dmrs_continue2 = 0
            ENDIF
           ENDIF
         ENDWHILE
         IF (dmrs_exists_ind=0)
          SET dmrs_property_value = ""
          CALL text(12,2,"Property Value: ")
          SET dmrs_continue2 = 1
          SET dmrs_line = 12
          SET dmrs_cntr = 0
          SET dmrs_valid_ind = 1
          WHILE (dmrs_continue2=1
           AND dmrs_cntr < 5)
            CALL text(19,2,"Note:  Enter twice when done setting value.")
            CALL clear(8,2,120)
            IF (dmrs_valid_ind=1)
             SET dmrs_cntr = (dmrs_cntr+ 1)
             SET dmrs_line = (dmrs_line+ 1)
            ENDIF
            SET accept = nopatcheck
            CALL accept(dmrs_line,5,"P(102);C","")
            SET accept = patcheck
            IF (curaccept="")
             SET dmrs_continue2 = 0
            ELSE
             IF (findstring('"',curaccept,1,0) > 0)
              CALL text(8,2,concat(
                "** Property value cannot contain double-quotes.  Press <Enter> to continue..."))
              CALL accept(8,117,"p;cu"," "
               WHERE curaccept IN (" "))
              SET dmrs_valid_ind = 0
             ELSE
              SET dmrs_valid_ind = 1
              IF (dmrs_property_value > "")
               SET dmrs_property_value = notrim(concat(notrim(dmrs_property_value),notrim(curaccept))
                )
              ELSE
               SET dmrs_property_value = notrim(curaccept)
              ENDIF
             ENDIF
            ENDIF
          ENDWHILE
          CALL clear(19,2,120)
          CALL text(19,2,"Continue? (Y/N):")
          CALL accept(19,35,"p;cu"," "
           WHERE curaccept IN ("Y", "N"))
          CASE (curaccept)
           OF "N":
            SET dmrs_continue = 1
           OF "Y":
            SET dmrs_continue = 1
            SET dmrs_prop_idx = locateval(dmrs_index,1,drsr_set_detail->property_cnt,
             dmrs_property_name,drsr_set_detail->props[dmrs_index].prop_name)
            IF (dmrs_prop_idx=0)
             SET drsr_set_detail->property_cnt = (drsr_set_detail->property_cnt+ 1)
             SET stat = alterlist(drsr_set_detail->props,drsr_set_detail->property_cnt)
             SET drsr_set_detail->props[drsr_set_detail->property_cnt].prop_name = dmrs_property_name
             SET drsr_set_detail->props[drsr_set_detail->property_cnt].prop_value = trim(
              dmrs_property_value)
            ELSE
             SET drsr_set_detail->props[dmrs_prop_idx].prop_value = trim(dmrs_property_value)
             SET drsr_set_detail->props[dmrs_prop_idx].remove_ind = 0
            ENDIF
          ENDCASE
         ENDIF
        OF "U":
         CALL clear(20,2,129)
         CALL clear(21,2,129)
         CALL text(20,2,"Property to Update, by line number (O to go back): ")
         CALL accept(20,52,"999;H",0
          WHERE curaccept BETWEEN 0 AND drsr_set_detail->property_cnt)
         CALL clear(20,2,129)
         SET dmrs_location = curaccept
         IF (dmrs_location > 0)
          IF ((dm_err->debug_flag=722))
           SET message = nowindow
          ELSE
           SET message = window
          ENDIF
          CALL clear(1,1)
          CALL box(1,1,3,132)
          CALL box(1,1,24,132)
          CALL text(2,2,"REGISTRY SET MAINTENANCE [UPDATE PROPERTY]")
          CALL text(5,2,"Registry Set Name: ")
          CALL text(5,30,drsr_set_detail->set_name)
          CALL text(5,70,"Last Modified:")
          CALL text(5,85,format(cnvtdatetime(drsr_set_detail->date_modified),
            "DD-MMM-YYYY HH:MM:SS;;D"))
          CALL text(6,2,"Registry Set Description: ")
          CALL text(6,30,drsr_set_detail->set_desc)
          CALL text(10,2,"Property Name:")
          CALL text(10,17,drsr_set_detail->props[dmrs_location].prop_name)
          SET dmrs_property_value = drsr_set_detail->props[dmrs_location].prop_value
          CALL text(11,2,"Current Property Value: ")
          SET dmrs_continue2 = 1
          SET dmrs_line = 11
          SET dmrs_cntr = 0
          SET dmrs_increment = 102
          SET dmrs_from = 1
          WHILE (dmrs_continue2=1
           AND dmrs_cntr < 5)
            SET dmrs_cntr = (dmrs_cntr+ 1)
            SET dmrs_line = (dmrs_line+ 1)
            SET dmrs_tmp_value = substring(dmrs_from,dmrs_increment,drsr_set_detail->props[
             dmrs_location].prop_value)
            IF (trim(dmrs_tmp_value,3)="")
             SET dmrs_continue2 = 0
             SET dmrs_line = (dmrs_line - 1)
            ELSE
             CALL text(dmrs_line,5,dmrs_tmp_value)
            ENDIF
            SET dmrs_from = (dmrs_from+ dmrs_increment)
          ENDWHILE
          SET dmrs_line = (dmrs_line+ 1)
          SET dmrs_property_value = ""
          CALL text(dmrs_line,2,"New Property Value: ")
          SET dmrs_continue2 = 1
          SET dmrs_line = dmrs_line
          SET dmrs_cntr = 0
          SET dmrs_valid_ind = 1
          WHILE (dmrs_continue2=1
           AND dmrs_cntr < 5)
            CALL text(23,2,"Note:  Enter twice when done setting value.")
            CALL clear(8,2,120)
            IF (dmrs_valid_ind=1)
             SET dmrs_cntr = (dmrs_cntr+ 1)
             SET dmrs_line = (dmrs_line+ 1)
            ENDIF
            SET accept = nopatcheck
            CALL accept(dmrs_line,5,"P(102);C","")
            SET accept = patcheck
            IF (curaccept="")
             SET dmrs_continue2 = 0
            ELSE
             IF (findstring('"',curaccept,1,0) > 0)
              CALL text(8,2,concat(
                "** Property value cannot contain double-quotes.  Press <Enter> to continue..."))
              CALL accept(8,117,"p;cu"," "
               WHERE curaccept IN (" "))
              SET dmrs_valid_ind = 0
             ELSE
              SET dmrs_valid_ind = 1
              IF (dmrs_property_value > "")
               SET dmrs_property_value = notrim(concat(notrim(dmrs_property_value),notrim(curaccept))
                )
              ELSE
               SET dmrs_property_value = notrim(curaccept)
              ENDIF
             ENDIF
            ENDIF
          ENDWHILE
          CALL clear(23,2,120)
          CALL text(23,2,"Continue? (Y/N):")
          CALL accept(23,35,"p;cu"," "
           WHERE curaccept IN ("Y", "N"))
          IF (curaccept="Y")
           SET drsr_set_detail->props[dmrs_location].prop_value = trim(dmrs_property_value)
          ENDIF
         ENDIF
        OF "V":
         CALL clear(20,2,129)
         CALL clear(21,2,129)
         CALL text(20,2,"Property to View, by line number (O to go back): ")
         CALL accept(20,52,"999;H",0
          WHERE curaccept BETWEEN 0 AND drsr_set_detail->property_cnt)
         CALL clear(20,2,129)
         SET dmrs_location = curaccept
         IF (dmrs_location > 0)
          IF ((dm_err->debug_flag=722))
           SET message = nowindow
          ELSE
           SET message = window
          ENDIF
          CALL clear(1,1)
          CALL box(1,1,3,132)
          CALL box(1,1,24,132)
          CALL text(2,2,"REGISTRY SET MAINTENANCE [VIEW PROPERTY]")
          CALL text(5,2,"Registry Set Name: ")
          CALL text(5,30,drsr_set_detail->set_name)
          CALL text(5,70,"Last Modified:")
          CALL text(5,85,format(cnvtdatetime(drsr_set_detail->date_modified),
            "DD-MMM-YYYY HH:MM:SS;;D"))
          CALL text(6,2,"Registry Set Description: ")
          CALL text(6,30,drsr_set_detail->set_desc)
          CALL text(10,2,"Property Name:")
          CALL text(10,17,drsr_set_detail->props[dmrs_location].prop_name)
          SET dmrs_property_value = drsr_set_detail->props[dmrs_location].prop_value
          CALL text(11,2,"Property Value: ")
          SET dmrs_continue2 = 1
          SET dmrs_line = 11
          SET dmrs_cntr = 0
          SET dmrs_increment = 102
          SET dmrs_from = 1
          WHILE (dmrs_continue2=1
           AND dmrs_cntr < 5)
            SET dmrs_cntr = (dmrs_cntr+ 1)
            SET dmrs_line = (dmrs_line+ 1)
            SET dmrs_tmp_value = substring(dmrs_from,dmrs_increment,drsr_set_detail->props[
             dmrs_location].prop_value)
            IF (trim(dmrs_tmp_value,3)="")
             SET dmrs_continue2 = 0
             SET dmrs_line = (dmrs_line - 1)
            ELSE
             CALL text(dmrs_line,5,dmrs_tmp_value)
            ENDIF
            SET dmrs_from = (dmrs_from+ dmrs_increment)
          ENDWHILE
          CALL text(18,2,concat("** Press <Enter> to continue..."))
          CALL accept(18,37,"p;cu"," "
           WHERE curaccept IN (" "))
         ENDIF
        OF "R":
         CALL clear(20,2,129)
         CALL clear(21,2,129)
         CALL text(20,2,"Property to Remove, by line number (O to go back): ")
         CALL accept(20,54,"999;H",0
          WHERE curaccept BETWEEN 0 AND drsr_set_detail->property_cnt)
         CALL clear(20,2,129)
         SET dmrs_location = curaccept
         IF (dmrs_location > 0)
          IF ((drsr_set_detail->props[dmrs_location].remove_ind=1))
           CALL text(20,2,concat("**Property has already been marked for removal."))
          ELSE
           CALL text(20,2,concat("**Property ",drsr_set_detail->props[dmrs_location].prop_name,
             " will be removed from this list."))
           CALL text(21,2,"Continue? (Y/N): ")
           CALL accept(21,20,"A;CU"," "
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            SET drsr_set_detail->props[dmrs_location].remove_ind = 1
           ENDIF
          ENDIF
         ENDIF
        OF "C":
         IF (drsr_insert_set_details(null)=0)
          RETURN(0)
         ENDIF
         IF (drsr_load_reg_set_details(drsr_reg_sets->current_set_name)=0)
          RETURN(0)
         ENDIF
         CALL text(20,2,"**Changes have been saved. Press <Enter> to continue...")
         CALL accept(20,60,"p;cu"," "
          WHERE curaccept IN (" "))
         SET dmrs_continue = 1
        OF "B":
         SET dmrs_continue = 0
       ENDCASE
      OF 1:
       SET dmrs_start = greatest(least((dmrs_start+ 10),(drsr_set_detail->property_cnt - 9)),1)
      OF 2:
       SET dmrs_start = greatest((dmrs_start - 10),1)
      OF 5:
       SET dmrs_start = greatest((dmrs_start - 10),1)
      OF 6:
       SET dmrs_start = greatest(least((dmrs_start+ 10),(drsr_set_detail->property_cnt - 9)),1)
     ENDCASE
   ENDWHILE
   SET drsr_reg_sets->current_set_name = "DM2NOTSET"
   IF (drsr_clear_drsr_set_detail(null)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsm_remove_reg_set(null)
   IF (drsr_get_registry_set(null)=0)
    RETURN(0)
   ENDIF
   IF ((drsr_reg_sets->current_set_name != "DM2NOTSET"))
    IF (drsr_load_reg_set_details(drsr_reg_sets->current_set_name)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Remove Registry Set"
    IF ((dm_err->debug_flag=722))
     SET message = nowindow
    ELSE
     SET message = window
    ENDIF
    CALL clear(1,1)
    CALL box(1,1,3,132)
    CALL box(1,1,24,132)
    CALL text(2,2,"REGISTRY SET MAINTENANCE [REMOVE REGISTRY SET]")
    CALL text(4,2,"Registry Set Name: ")
    CALL text(4,30,drsr_set_detail->set_name)
    CALL text(4,70,"Last Modified:")
    CALL text(4,85,format(cnvtdatetime(drsr_set_detail->date_modified),"DD-MMM-YYYY HH:MM:SS;;D"))
    CALL text(5,2,"Registry Set Description: ")
    CALL text(5,30,drsr_set_detail->set_desc)
    CALL text(7,2,"The above Registry Set will be completely removed. ")
    CALL text(9,2,"Are you sure you want to continue? (Y/N):")
    CALL accept(9,45,"A;CU"," "
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     DELETE  FROM dm2_admin_dm_info di
      WHERE di.info_domain=concat("DM2_REGISTRY_SET(ED)-",drsr_reg_sets->current_set_name)
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
    SET drsr_reg_sets->current_set_name = "DM2NOTSET"
    IF (drsr_clear_drsr_set_detail(null)=0)
     RETURN(0)
    ENDIF
    IF (drsr_clear_drsr_reg_sets(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsm_update_reg_set_desc(null)
   SET dm_err->eproc = "Update Registry Set Description"
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
   ELSE
    SET message = window
   ENDIF
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL box(1,1,24,132)
   CALL text(2,2,"REGISTRY SET MAINTENANCE [UPDATE REGISTRY SET DESCRIPTION]")
   CALL text(5,2,"Registry Set Name: ")
   CALL text(5,30,drsr_set_detail->set_name)
   CALL text(5,70,"Last Modified:")
   CALL text(5,85,format(cnvtdatetime(drsr_set_detail->date_modified),"DD-MMM-YYYY HH:MM:SS;;D"))
   CALL text(6,2,"Registry Set Description: ")
   CALL text(6,30,drsr_set_detail->set_desc)
   CALL text(8,2,"Update description? (Y/N): ")
   CALL accept(8,35,"p;cu","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SET dmrs_set_desc = drsr_set_detail->set_desc
    CALL text(10,2,"New Registry Set Description: ")
    CALL accept(10,33,"P(70);C",dmrs_set_desc)
    SET dmrs_set_desc = trim(curaccept,3)
    CALL text(12,2,"Continue? (Y/N):")
    CALL accept(12,35,"p;cu"," "
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     SET drsr_set_detail->set_desc = dmrs_set_desc
     UPDATE  FROM dm2_admin_dm_info di
      SET di.info_char = drsr_set_detail->set_desc
      WHERE di.info_domain=concat("DM2_REGISTRY_SET(ED)-",drsr_reg_sets->current_set_name)
       AND di.info_name="REGISTRY_SET_DESCRIPTION"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drsm_report_reg_set(null)
   DECLARE drrs_date_str = vc WITH protect, noconstant("")
   IF (drsr_get_registry_set(null)=0)
    RETURN(0)
   ENDIF
   IF ((drsr_reg_sets->current_set_name != "DM2NOTSET"))
    IF (drsr_load_reg_set_details(drsr_reg_sets->current_set_name)=0)
     RETURN(0)
    ENDIF
    SET drrs_date_str = format(cnvtdatetime(drsr_set_detail->date_modified),"DD-MMM-YYYY HH:MM:SS;;D"
     )
    SET dm_err->eproc = "Report Registry Set"
    CALL echorecord(drsr_set_detail)
    SELECT
     d.seq
     FROM (dummyt d  WITH seq = value(drsr_set_detail->property_cnt))
     WHERE (drsr_set_detail->props[d.seq].prop_name > "")
     ORDER BY drsr_set_detail->props[d.seq].prop_name
     HEAD REPORT
      "Registry Set Report", row + 1,
      "-----------------------------------------------------------------------------",
      row + 1, "Registry Set Name:  ", drsr_set_detail->set_name,
      row + 1, "Last Modified:  ", drrs_date_str,
      row + 1, "Registry Set Description:  ", drsr_set_detail->set_desc,
      row + 2
     HEAD PAGE
      row + 1, col 1, "Property Name",
      col 65, "Property Value", row + 1,
      col 1, "-------------", col 65,
      "--------------", row + 1
     DETAIL
      col 1, drsr_set_detail->props[d.seq].prop_name, col 65,
      drsr_set_detail->props[d.seq].prop_value, row + 1
     WITH nocounter, maxcol = 2000, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 CALL clear(1,1)
 SET message = nowindow
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "dm2_rr_registry_set_maint has completed"
 ENDIF
 CALL final_disp_msg("dm2_reg_set_maint")
END GO
